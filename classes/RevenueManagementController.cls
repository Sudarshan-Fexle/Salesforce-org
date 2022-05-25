/**
 *  Purpose         :   This class is holding all the logic for Revenue Managment. For more details refer Revenue Management Solution Design document    
 *
 *  Created By      :   Subhash Garhwal
 *
 *  Created Date    :   02/07/2017
 *
 *  Revision Log    :   V_1.0 - Created - CR-20161102-10316 - Revenue Management
 *		    		:   V_1.1 - Modified - CR-20170302-10729 - Made changes according to Solution design 1.4
 *		    		:   V_1.2 - Modified - Abhinav Sharma - 5/15/2017 - CR-20170508-10923 - Program name change linkage
 *		    		:   V_1.3 - Modified - Abhinav Sharma - 5/16/2017 - CR-20170508-10914 - Create new fields on ABC Revenue Line - Ex. Three new fields for RISK
 *		    		:   V_1.4 - Modified - Abhinav Sharma - 5/18/2017 - CR-20170508-10905 - "Change Reason Code" (picklist) and validation around it
 *		    		:   V_1.5 - Modified - Subhash Garhwal - 08/11/2017 - Issue--CR11136--QA--00005403 - Changed template logic
 *		    		:   V_1.6 - Modified - Subhash Garhwal - 08/14/2017 - Issue--CR11136--QA--00005401 - Added ABC Revenue Record Type assignment logic.  
 *		    		:   V_1.7 - Modified - Abhinav Sharma - 08/16/2017 - Issue--CR11136--QA--00005401 - Implemented changes for fixes
 *		    		:   V_1.8 - Modified - Victor Hanson - 11/01/2017 - Issue--CR11742--UAT--00007271 - Added hasAccess method to verify the user has access to the record
 *		    		:   V_1.9 - Modified - Abhinav Sharma - 12/06/2018 - CR-20180918-12607.
 *		    		:   V_2.0 - Modified - Dipesh Gupta - 09/19/2019 - CR-20190904-13311 - Added these fields Integrated_for_Revenue_Purposes__c,Integrated_Account_Name__c in the query   
 *		    		:   V_2.1 - Modified - Dipesh Gupta - 11/20/2019 - CR-20191119-13522 - Added new line and commented old one As per work order
 *		    		:   V_2.2 - Modified - Victor Hanson - 05/13/2020 - CR-20200512-14039 - updated doSave() to include negotiated and secured amt
 *		    		:   V_2.3 - Modified - Neha Sharma -  2/1/2021 - CR-20200819-14443 - Remove the none option from the lineStatusOptions picklist
 *		    		:   V_2.4 - Modified - Mahendra Swarnkar -  02/09/2021 - CR-20210901-15401 - Added Contracted_Quantity__c,Actual_Quantity__c, Actual_Hours__c, Contracted_Hours__c, Performance_Obligation_Complete__c, Complete_Recognition_Amount__c in the query
 *		    		:   V_2.5 - Modified - Mahendra Swarnkar - 06/23/2021 - CR-20210325-15033 - Update Template on RR lines
**/
public class RevenueManagementController {
    
    //Properties
    public boolean editorAddRevenueLine {get;set;}
    
    //Wrapper instance to hold the parent object record details
    public RevenueManagementParentObjectWrapper parentObjectWrapper {get;set;}
    
    //List to manage ABC Revenue data and calculation 
    public List<RevenueManagementWrapper> aBCrevenues {get;set;}
    
    //Variable to identify the User Permission
    public String abcRevenueAccess {get;set;}
    
    //Variable to Show the parent object Lookup on when Clone from parent object options is selected
    public RevenueManagementWrapper revenuemManagementWrap {get;set;}
    public ABC_Revenue__c aBCRevenue {get;set;}
    
    //Variable to hold the index for ABC Revenue to remove
    public Integer revenueIndex {get;set;}
    public Integer revenueHighlighIndex {get;set;}
    
    //vairables to control the operations visibility
    public String selectedOperation {get;set;}
 
    
    //Options list to provide the all the possiable options to user
    public List<SelectOption> operationOptions {
        
        get {
            
            if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CONTRACT_ABC_OBJ_API_NAME))
                return RMConstants.OPERATION_OPTIONS;
            
            if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CPQ_SUBSCRIPTION_OBJ_API_NAME))
                return RMConstants.OPERATION_OPTIONS_SUBSCRIPTIONS;
            
            //Added By Abhinav Sharma  - 12/03/2018 - CR-20180918-12607 - Check for the standard Contract Object, 
            //if Yes than only show the related value in the Drop down on Manage Revenue page
            if(parentObjectAPIName.equalsIgnoreCase(RMConstants.STANDARD_Contract_OBJ_API_NAME))
                return RMConstants.OPERATION_OPTIONS_STANDARD_CONTRACT;
            
            return RMConstants.OPERATION_OPTIONS;
        }
        set;
    }
    
    //Variable to hold the total no of new lines to add
    public String totalNewLines {get;set;}
    
    //Options list to provide the all the possiable options to user
    public List<SelectOption> blankLines {
        
        get {
            
            List<SelectOption> blankLinesTemp = new List<SelectOption>();
            
            //Loop
            for(Integer i = 1; i <= Integer.valueOf(System.Label.ADD_LINES_MAX_NUMBER); i++)
                blankLinesTemp.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
            
            return blankLinesTemp;
        }
        set;
    }
    
    //variables to hold the template details
    List<SelectOption> primaryTemplates;
    Map<Id, ffrr__Template__c> mapTemplates;
    
    //Variables to hold the ABC Revenue Lines with related ABC Revenue
    //private Map<Id, List<ABC_Revenue_Line__c>> mapABCRevenueLinesWithABCRevenue { get; set; }
    
    //Variable to control the mode of the VF page
    public String viewMode {get;set;}
    
    //Variable to hold the Product
    Product2 product;
    
    //Vairable to hold the value of Template
    String defaultTemplate;
    
    //Vairable to hold the default record types
    String defaultABCRevenueRecordType;
    
    //List to hold the Line Status
    List<SelectOption> lineStatusOptions;
    
    //Set to hold the avaiable values
    Set<String> lineStatusValues;
    
    String ROW_NUMBER = 'Row # ';
    
    //Attribute to hold the parent object properties
    private ID parentObjectID;
    String parentObjectAPIName;
    
    //Boolean to hold true if atleast one program sub. is associated with the ABC revenue before.  
    public boolean isABCRevenueProcessedEarlierForContract {get; set;}
    
    //Constructor
    public RevenueManagementController() {
        
        //Call inIt
        inIt();
    }
    
    //inIt method to load all the properties
    public void inIt() {
        
        //Initialize properties
        aBCrevenues = new List<RevenueManagementWrapper>();
        abcRevenueAccess = RMConstants.ABC_REVENUE_NO_ACCESS;
        aBCRevenue = new ABC_Revenue__c();
        primaryTemplates = new List<SelectOption>();
        mapTemplates = new Map<Id, ffrr__Template__c>();
        //mapABCRevenueLinesWithABCRevenue = new Map<Id, List<ABC_Revenue_Line__c>>();
        viewMode = RMConstants.REVENUE_MANAGEMENT_PAGE_VIEW_MODE_REVIEW;
        product = new Product2();
        totalNewLines = '3';
        defaultTemplate = '';
        defaultABCRevenueRecordType = '';
        selectedOperation = '';
        lineStatusValues = new Set<String>();
        isABCRevenueProcessedEarlierForContract = false;
        
        //Original Line Status options
        lineStatusOptions = lineStatusOptions();
        
        //Added - Subhash Garhwal - 08/14/2017 - Issue--CR11136--QA--00005401 - Added Std Contract Record Type check
        //Query through RecordType
        List<RecordType> aBCRevenueRT = [Select Id From RecordType 
                                         Where SobjectType =: RMConstants.ABC_REVENUE_OBJECT 
                                         AND (DeveloperName =: RMConstants.ABC_REVENUE_RECORD_TYPE_CONTRACT_ABC 
                                              OR DeveloperName =: RMConstants.ABC_REVENUE_RECORD_TYPE_STANDARD_CONTRACT
                                             )
                                         ORDER BY DeveloperName ASC];
        
        //Check for RecordType
        if(aBCRevenueRT.size() > 0)
            defaultABCRevenueRecordType = aBCRevenueRT[0].Id;
        
        //Populate Template values
        RMUtility.populateTemplateDetails(primaryTemplates, mapTemplates);
        
        //Checking for the parent ID in the URL
        if(String.isNotBlank(Apexpages.currentPage().getParameters().get(RMConstants.URL_PARAM_PARENTID))) {
            
            //Parent Object record ID
            parentObjectID = ID.valueOf(Apexpages.currentPage().getParameters().get(RMConstants.URL_PARAM_PARENTID));
            
            //Parent Object API Name
            parentObjectAPIName = parentObjectID.getSobjectType().getDescribe().getName();
            
            //Added - Subhash Garhwal - 08/14/2017 - Issue--CR11136--QA--00005401 - Added Std Contract Record Type check
            if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CONTRACT_ABC_OBJ_API_NAME))
                defaultABCRevenueRecordType = aBCRevenueRT[0].Id;
            else if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CPQ_SUBSCRIPTION_OBJ_API_NAME) 
                    || 
                    parentObjectAPIName.equalsIgnoreCase(RMConstants.STANDARD_Contract_OBJ_API_NAME))
                defaultABCRevenueRecordType = aBCRevenueRT[1].Id;
            
            //Map to hold the field API Name with respect to index number
            Map<Integer, String> mapOfIndexNoWithFieldAPIName = new Map<Integer, String>();
            
            //Map to hold the SOQL Query string as value and parent object API Name as key
            Map<String, String> mapParentObjectAPINameWithSOQLQueryStr = new Map<String, String>();
            
            //Loop through metadata records which is holding the field mapping details
            for(Rev_Rec_Parent_Field_Mapping_Setting__mdt revRecFieldsMapping : [SELECT ID, Field_API_Name__c, Index__c, SOQL_Query__c,
                                                                                 Parent_Object_API_Name__c
                                                                                 FROM Rev_Rec_Parent_Field_Mapping_Setting__mdt
                                                                                 WHERE Parent_Object_API_Name__c != null
                                                                                 AND Parent_Object_API_Name__c != ''
                                                                                 ORDER By Index__c ASC NULLS LAST
                                                                                ]) {
                                                                                    
                                                                                    //Cheecking if SOQL Query field is having null/blank value with it
                                                                                    if(String.isBlank(revRecFieldsMapping.SOQL_Query__c) 
                                                                                       && String.isNotBlank(revRecFieldsMapping.Field_API_Name__c)
                                                                                       && revRecFieldsMapping.Index__c != null
                                                                                      ) {
                                                                                          
                                                                                          //Checking if fields mapping exists for this object in the metadata or not
                                                                                          //and accordingly populating collection with values which willbe helpful in populating wrapper instance
                                                                                          if(revRecFieldsMapping.Parent_Object_API_Name__c.equalsIgnoreCase(parentObjectAPIName.trim()))
                                                                                              mapOfIndexNoWithFieldAPIName.put(Integer.valueOf(revRecFieldsMapping.Index__c), revRecFieldsMapping.Field_API_Name__c);
                                                                                          
                                                                                      }
                                                                                    
                                                                                    //Checking for the "SOQL Query" field value
                                                                                    if(String.isNotBlank(revRecFieldsMapping.SOQL_Query__c))                                                                    
                                                                                        mapParentObjectAPINameWithSOQLQueryStr.put(revRecFieldsMapping.Parent_Object_API_Name__c.toLowerCase(), revRecFieldsMapping.SOQL_Query__c);    
                                                                                }
            
            //Checking map for its size
            if(mapOfIndexNoWithFieldAPIName.values().size() > 0) {
                
                //Populating wrapper instance with parent details
                parentObjectWrapper = new RevenueManagementParentObjectWrapper(mapOfIndexNoWithFieldAPIName, parentObjectAPIName, parentObjectID, mapParentObjectAPINameWithSOQLQueryStr);
                
                //Get the Product from Program Record
                List<Product2> products = new List<Product2>();
                
                //Checking for program ID in the wrapper instance
                if(String.isNotBlank(parentObjectWrapper.programID)) {
                    //Modified - Subhash Garhwal - 08/11/2017 - Issue--CR11136--QA--00005403 - Added Rev_Rec_Template_CPQ_Contract__c in SOQL query
                    //Retrieving product details
                    products = [Select Id, Name, Rev_Rec_Template__c, Rev_Rec_Template__r.Name, Rev_Rec_Template_CPQ_Contract__c,
                                Rev_Rec_Template_CPQ_Contract__r.Name, Rev_Rec_Template_CPQ_Contract__r.Template_A__c,
                                Rev_Rec_Template_CPQ_Contract__r.Template_A__r.Name , Rev_Rec_Template__r.Template_A__c, 
                                Rev_Rec_Template__r.Template_A__r.Name 
                                FROM Product2 
                                WHERE Program__c != null 
                                AND Program__c =: parentObjectWrapper.programID];        
                }
                
                //Check for Product size
                if(products.size() > 0) {
                    
                    //Set Product record
                    product = products[0];
                    
                    //Check for Parent object
                    //Modified - Subhash Garhwal - 08/11/2017 - Issue--CR11136--QA--00005403 - Added Check for Parent object to get the Template for
                    //Contract ABC or Standard Contract (Program Subscription)
                    if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CONTRACT_ABC_OBJ_API_NAME)) {
                        
                        //Populate default template id
                        defaultTemplate = product.Rev_Rec_Template__c;
                        
                    } else if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CPQ_SUBSCRIPTION_OBJ_API_NAME)) {
                        
                        //Populate default template id
                        defaultTemplate = product.Rev_Rec_Template_CPQ_Contract__c;
                    }
                    
                    //Check for Default Template
                    if(String.isNotBlank(defaultTemplate)) {
                        
                        
                        
                        //Query through the Template
                        ffrr__Template__c template = [Select Id, Name, Template_A__c, Template_A__r.Name From ffrr__Template__c 
                                                      Where Id =: defaultTemplate];
                        
                        //Check default Template in map
                        if(!mapTemplates.containsKey(defaultTemplate)) {
                            
                            //Add Template in options
                            primaryTemplates.add(new SelectOption(template.Id, template.Name));
                            
                            //Add values in map as well
                            mapTemplates.put(template.Id, template);
                        }
                    }
                }
                
                //Initialize properties
                revenuemManagementWrap = new RevenueManagementWrapper(new ABC_Revenue__c(), primaryTemplates, '', false, true, lineStatusOptions);
                
                //Check user permission - Modified by Colin McGloin - 04/21/2017 - CR-20170418-10859
                List<ObjectPermissions> abcRevenuePermission = [Select Id, SObjectType, PermissionsRead, PermissionsCreate, PermissionsEdit, ParentId FROM
                                                                ObjectPermissions Where (ParentId IN (Select PermissionSetId FROM PermissionSetAssignment Where AssigneeId =:UserInfo.getUserId()))
                                                                AND SobjectType =: RMConstants.ABC_REVENUE_OBJECT
                                                                AND (Parent.ProfileId = NULL OR (Parent.Profile.Name =: RMConstants.ABC_REVENUE_ADMIN OR Parent.Profile.Name =: RMConstants.ABC_REVENUE_ABC_DATALOADER))];
                System.debug('@@@@@ abcRevenuePermission ' + abcRevenuePermission);
                
                //Check for Permission
                if(abcRevenuePermission.size() > 0) {
                    
                    //Check for permission
                    if(abcRevenuePermission[0].PermissionsRead)
                        abcRevenueAccess =  RMConstants.ABC_REVENUE_READ_ACCESS;
                    
                    if(abcRevenuePermission[0].PermissionsCreate) {
                        abcRevenueAccess =  RMConstants.ABC_REVENUE_CREATE_ACCESS;
                        viewMode = RMConstants.REVENUE_MANAGEMENT_PAGE_VIEW_MODE_MANAGE;
                    }
                }
                
                System.debug('zzzAccess' + abcRevenueAccess);
                
                //Check if the Parent Object is Standard Contract  then Only call this method. 
                if(parentObjectAPIName.equalsIgnoreCase(RMConstants.STANDARD_Contract_OBJ_API_NAME))
                	checkABCRevenueCreatedOnProgramSubscription();
                    
                //Load ABCRevenue records
                loadABCRevenue();
            }
        }
    }
    
    /**
    *  @description    :   This method is used to load/add new ABC Revenue record on page load
    *
    *  @args           :   
    *
    *  @return         :   void
    *
    *  @Revision Log   :   V1.0 - Created - CR-20161102-10316
    *
    **/
    public void loadABCRevenue() {
        
        //Initialize properties
        aBCrevenues = new List<RevenueManagementWrapper>();
        //mapABCRevenueLinesWithABCRevenue = new Map<Id, List<ABC_Revenue_Line__c>>();
        revenuemManagementWrap = new RevenueManagementWrapper(new ABC_Revenue__c(), primaryTemplates, '', false, true, lineStatusOptions);
        
        //Map to hold the Revenue with Template editable flag
        Map<Id, Boolean> mapABCRevenueWithTemplateEditAccess = new Map<Id, Boolean>();
        
        //Map to hold the ABC Revenue with ABC RevenueLine Wrapper
        //Map<Id, List<RevenueManagementWrapper.ABCRevenueLineWrapper>> mapABCRevenueLinesWrapper = new Map<Id, List<RevenueManagementWrapper.ABCRevenueLineWrapper>>();
        
        //List of ABC Revenue lines
        List<ABC_Revenue_Line__c> listOfABCRevenueLines = new List<ABC_Revenue_Line__c>();
        
        //Checking for object type
        if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CONTRACT_ABC_OBJ_API_NAME)) {
            
            //Retrieving revenue lines asscoiated with the contract ABC records
            listOfABCRevenueLines = [Select Id, Name, ABC_Revenue__c, ffrrtemplate__c, ffrrtemplate__r.Name, Include_in_Rev_Rec__c, 
                                     Rev_Rec_Complete__c, Rev_Rec_Posted_Date__c 
                                     From ABC_Revenue_Line__c 
                                     Where ABC_Revenue__r.Contract_ABC__c  =: parentObjectWrapper.parentRecordID 
                                     ORDER BY Name ASC];
            
        } else if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CPQ_SUBSCRIPTION_OBJ_API_NAME)) {
            
            //Retrieving revenue lines asscoiated with the Subscription records
            listOfABCRevenueLines = [Select Id, Name, ABC_Revenue__c, ffrrtemplate__c, ffrrtemplate__r.Name, Include_in_Rev_Rec__c, 
                                     Rev_Rec_Complete__c, Rev_Rec_Posted_Date__c
                                     From ABC_Revenue_Line__c 
                                     Where ABC_Revenue__r.Program_Subscription__c  =: parentObjectWrapper.parentRecordID 
                                     ORDER BY Name ASC];
        }
        
        //Loop over the ABC Revenue Lines
        /*for(ABC_Revenue_Line__c aBCRL : listOfABCRevenueLines) {
            
            //Check ABC Revenue in map
            if(!mapABCRevenueLinesWithABCRevenue.containsKey(aBCRL.ABC_Revenue__c))
                mapABCRevenueLinesWithABCRevenue.put(aBCRL.ABC_Revenue__c, new List<ABC_Revenue_Line__c>());
            
            //Add ABC Revenue Line in map   
            mapABCRevenueLinesWithABCRevenue.get(aBCRL.ABC_Revenue__c).add(aBCRL);
            
            //Set Template Editiable
            mapABCRevenueWithTemplateEditAccess.put(aBCRL.ABC_Revenue__c, true);
            
            //Check ABC Revenue Line
            if(!mapABCRevenueLinesWrapper.containsKey(aBCRL.ABC_Revenue__c))
                mapABCRevenueLinesWrapper.put(aBCRL.ABC_Revenue__c, new List<RevenueManagementWrapper.ABCRevenueLineWrapper>());
            
            //Check for ABC Revenue Record size
            if(mapABCRevenueLinesWrapper.get(aBCRL.ABC_Revenue__c).size() < 2)
                mapABCRevenueLinesWrapper.get(aBCRL.ABC_Revenue__c).add(new RevenueManagementWrapper.ABCRevenueLineWrapper(aBCRL));
        }*/
        
        integer s = 1;
        
        //List of ABC revenue records
        List<ABC_Revenue__c> listOfABCRevenues = new List<ABC_Revenue__c>();
        
        //Checking for object type
        if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CONTRACT_ABC_OBJ_API_NAME)) {
            
            //Modified By - Mahendra Swarnkar -  02/09/2021 - CR-20210901-15401 - Added Contracted_Quantity__c,Actual_Quantity__c, Actual_Hours__c, Contracted_Hours__c, Performance_Obligation_Complete__c, Complete_Recognition_Amount__c in the query
            //Remove the reference of "Clarizen_First_Go_Live_Complete__c" - By abhinav Sharma - 7/6/2020 - CR-20200204-13690
            //Added these fields Integrated_for_Revenue_Purposes__c ,Integrated_Account_Name__c in the query -  By Dipesh Gupta - 09/19/2019 - CR-20190904-13311
            //Retrieving revenue lines asscoiated with the contract ABC records
            listOfABCRevenues = [Select Id, Name, Account_Formal_Name__c, Comments__c, Contract__c, Contract_ABC__c, Expected_Amount_to_Recognize__c, ffrrtemplate__c,
                                 Fee_Type__c, GAAP_Amount__c, Include_in_Rev_Rec__c, Institution__c, Line_Status__c, List_Price__c, Product__c,
                                 Program_Code__c, Recognition_End_Date__c, Recognition_Start_Date__c, Rev_Rec_Complete__c, Rev_Rec_Posted_Date__c, 
                                 Negotiated_Amount__c, Rev_Rec_Template_Selected__c,
                                 Rev_Rec_Templates__c, Rev_Rec_Template_Ids__c, Risk_Type__c, Risk_Status__c, Risk_Due_Date__c,Integrated_for_Revenue_Purposes__c ,Integrated_Account_Name__c/*,Contract_Type__c*/, Secured_Amount__c,
                                 Cost_Center__c, Program__c, Recognized_to_Date__c, Site_Live_Date__c, Revenue_Recognition_Account__c, 
                                 RecordTypeId, Risk_Maximum_Potential__c, Revenue_Start_Date_Override__c, Project__c,
                                 Risk_Expected__c, Risk_Estimated__c, Change_Reason_Code__c, Change_Reason_Code_Clone__c, Program__r.Name,
                                 Recognized_to_Date_GAAP__c, Recognized_to_Date_Negotiated__c, Secured_Amount_GAAP__c, Deferred_Revenue_Negotiated__c, 
                                 Deferred_Revenue_GAAP__c, Deployment__c, Deployment__r.Name, /*Clarizen_First_Go_Live_Complete__c,*/ Include_In_Rev_Recx__c,
                                 Revenue_End_Date_Override__c, Final_Invoice__c,Contracted_Quantity__c,Actual_Quantity__c, 
                                 Actual_Hours__c, Contracted_Hours__c, Performance_Obligation_Complete__c, Complete_Recognition_Amount__c
                                 FROM ABC_Revenue__c 
                                 Where Contract_ABC__c =: parentObjectWrapper.parentRecordID
                                 ORDER BY Name ASC];
            //Modified by - Mahendra Swarnakar - 05-27-2020 - CR-20200518-14065      
            editorAddRevenueLine = true;
            
        } else if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CPQ_SUBSCRIPTION_OBJ_API_NAME)) {
            
            //Modified By - Mahendra Swarnkar -  02/09/2021 - CR-20210901-15401 - Added Contracted_Quantity__c,Actual_Quantity__c, Actual_Hours__c, Contracted_Hours__c, Performance_Obligation_Complete__c, Complete_Recognition_Amount__c in the query
             //Remove the reference of "Clarizen_First_Go_Live_Complete__c" - By abhinav Sharma - 7/6/2020 - CR-20200204-13690
            //Added these fields Integrated_for_Revenue_Purposes__c ,Integrated_Account_Name__c in the query -  By Dipesh Gupta - 09/19/2019 - CR-20190904-13311
            //Retrieving revenue lines asscoiated with the Subscription records
            listOfABCRevenues = [Select Id, Name, Account_Formal_Name__c, Comments__c, Contract__c, Contract_ABC__c, Expected_Amount_to_Recognize__c, ffrrtemplate__c,
                                 Fee_Type__c, GAAP_Amount__c, Include_in_Rev_Rec__c, Institution__c, Line_Status__c, List_Price__c, Product__c,
                                 Program_Code__c, Recognition_End_Date__c, Recognition_Start_Date__c, Rev_Rec_Complete__c, Rev_Rec_Posted_Date__c, 
                                 Negotiated_Amount__c, Rev_Rec_Template_Selected__c,
                                 Rev_Rec_Templates__c, Rev_Rec_Template_Ids__c, Risk_Type__c, Risk_Status__c, Risk_Due_Date__c, Integrated_for_Revenue_Purposes__c, Integrated_Account_Name__c, Secured_Amount__c,
                                 Cost_Center__c, Program__c, Recognized_to_Date__c, Site_Live_Date__c, Revenue_Recognition_Account__c, 
                                 RecordTypeId, Risk_Maximum_Potential__c, Revenue_Start_Date_Override__c, 
                                 Risk_Expected__c, Risk_Estimated__c, Change_Reason_Code__c, Change_Reason_Code_Clone__c, Program__r.Name,
                                 Recognized_to_Date_GAAP__c, Recognized_to_Date_Negotiated__c, Secured_Amount_GAAP__c, Deferred_Revenue_Negotiated__c, 
                                 Deferred_Revenue_GAAP__c, Deployment__c, Deployment__r.Name, Include_In_Rev_Recx__c,
                                 Project__c, Revenue_End_Date_Override__c, Final_Invoice__c,Program_Subscription__c,Program_Subscription__r.SBQQ__Product__r.Product_Not_Used_in_Revenue__c,
                                 Contracted_Quantity__c,Actual_Quantity__c, Actual_Hours__c, Contracted_Hours__c, Performance_Obligation_Complete__c, Complete_Recognition_Amount__c
                                 FROM ABC_Revenue__c 
                                 Where Program_Subscription__c =: parentObjectWrapper.parentRecordID
                                 ORDER BY Name ASC];
            
            //Modified by - Mahendra Swarnakar - 05-27-2020 - CR-20200518-14065      
            List<SBQQ__Subscription__c> subscriptionList = [Select Id,SBQQ__Product__r.Product_Not_Used_in_Revenue__c From SBQQ__Subscription__c where Id =: parentObjectWrapper.parentRecordID];
            
            if(listOfABCRevenues.size() > 0  && listOfABCRevenues[0].Program_Subscription__r.SBQQ__Product__r.Product_Not_Used_in_Revenue__c == true){
                editorAddRevenueLine = false;
            }
            else if(subscriptionList.size() > 0 && subscriptionList[0].SBQQ__Product__r.Product_Not_Used_in_Revenue__c == true){
                editorAddRevenueLine = false;
            }
            else{
                editorAddRevenueLine = true;
            }                     
                    
        }
        
        //SOQL query through ABC Revenue to get all the Revenue records for Contract ABC
        //Modified By - Abhinav Sharma - 5/15/2017 - CR-20170508-10923 - Added Program__r.Name in the query
        //Modified By - Abhinav Sharma - 5/16/2017 - CR-20170508-10914 - Added Risk_Maximum_Potential__c, Risk_Expected__c, Risk_Estimated__c fields
        for(ABC_Revenue__c rev : listOfABCRevenues) {
            
            //Check for ABC Revenue
            if(aBCRevenue != null && aBCRevenue.Id != null && aBCRevenue.Id == rev.Id)
                aBCRevenue = rev;
            
            //List to hold the final LineStatus values
            List<SelectOption> finalLineStatusValues = new List<SelectOption>();
            finalLineStatusValues.addAll(lineStatusOptions);
            
            if(lineStatusOptions.size() <= 0){
                
                //Check for Line Status value
                if(String.isNotBlank(rev.Line_Status__c) && !lineStatusValues.contains(rev.Line_Status__c))
                    finalLineStatusValues.add(new SelectOption(rev.Line_Status__c, rev.Line_Status__c));
            }
            RevenueManagementWrapper rMW = new RevenueManagementWrapper();
            //Added new line and commented old one CR-20191119-13522 - As per work order 
            if(Test.isrunningTest())
                rMW = new RevenueManagementWrapper(rev, primaryTemplates, String.isNotBlank(rev.Rev_Rec_Template_Ids__c) ? rev.Rev_Rec_Template_Ids__c.split(',')[0] : defaultTemplate, false, mapABCRevenueWithTemplateEditAccess.containsKey(rev.Id) ? mapABCRevenueWithTemplateEditAccess.get(rev.Id) : true, finalLineStatusValues);
            else
            	rMW = new RevenueManagementWrapper(rev, primaryTemplates, String.isNotBlank(rev.ffrrtemplate__c) ? rev.ffrrtemplate__c : defaultTemplate, false, mapABCRevenueWithTemplateEditAccess.containsKey(rev.Id) ? mapABCRevenueWithTemplateEditAccess.get(rev.Id) : true, finalLineStatusValues);            //Add ABC Revenue Lines
            
            /*if(mapABCRevenueLinesWrapper.containsKey(rev.Id))
                rMW.abcRevenueLineWrapper = mapABCRevenueLinesWrapper.get(rev.Id);*/
            
            //Setting row number                                 
            rMW.currentRowNo = s;                                 
            
            //Add Revenue record in wrapper
            aBCrevenues.add(rMW);
            
            //increment the variable count by 1
            s++;                                 
        }
        
        //Loop through ABC revenue records and initializing values for some other variables
        for(RevenueManagementWrapper rmWW : aBCrevenues){
            rmWW.errorMessage = '';
        }
        
        System.debug('@@@@@ RevenueManagementWrapper ' + aBCrevenues);
        System.debug('@@@@@ RevenueManagementWrapperSize ' + aBCrevenues.size());
        System.debug('@@@@@ RevenueManagementParentObjectWrapper ' + parentObjectWrapper);
    }
    
    /**
    *  @description    :   This method is used to generates lines from Contract according to field values on Contract ABC
    *                      Condtions: Term Type = 'Fixed'
    *                                 If Setup in Negotiated has value, create two ABC Revenue
    *                                 Else create one ABC Revenue
    *                  
    *  @args           :   
    *
    *  @return         :   void
    *  
    *  @Revision Log   :   V1.0 - 2/8/2017 - Created - CR-20161102-10316 - Subhash Garhwal 
    *
    **/
    public void generateABCRevenues() {
        
        try {
            
            //Check for term type
            if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CONTRACT_ABC_OBJ_API_NAME)) {
                if(parentObjectWrapper.contractABC.Term_Type__c == null || parentObjectWrapper.contractABC.Term_Type__c != RMConstants.CONTRACT_ABC_FIXED_TERM) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.GENERATE_REVENUE_TERM_TYPE_MSG));
                    return;
                }
            }
            
            //Check for term type
            if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CPQ_SUBSCRIPTION_OBJ_API_NAME)) {
                if(parentObjectWrapper.sBQQSubcription.Term_Type__c == null || parentObjectWrapper.sBQQSubcription.Term_Type__c != RMConstants.CONTRACT_ABC_FIXED_TERM) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.GENERATE_REVENUE_TERM_TYPE_MSG));
                    return;
                }
            }       
            
            //Check for required field values
            if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CONTRACT_ABC_OBJ_API_NAME)) {
                if(parentObjectWrapper.contractABC.Payer_Account__c == null || parentObjectWrapper.contractABC.Program__c == null || parentObjectWrapper.contractABC.Start__c == null || parentObjectWrapper.contractABC.End__c == null
                   || parentObjectWrapper.contractABC.Negotiated_Amount__c == null || parentObjectWrapper.contractABC.Term_Type__c == null) {
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.GENERATE_LINES_MSG));
                       return;
                   }   
            }
            
            //Check for required field values
            if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CPQ_SUBSCRIPTION_OBJ_API_NAME)) {
                if(parentObjectWrapper.sBQQSubcription.SBQQ__Account__c == null || parentObjectWrapper.sBQQSubcription.Program__c == null || parentObjectWrapper.sBQQSubcription.SBQQ__StartDate__c == null || parentObjectWrapper.sBQQSubcription.SBQQ__EndDate__c == null
                   || parentObjectWrapper.sBQQSubcription.Negotiated_Amount_Subscription__c == null || parentObjectWrapper.sBQQSubcription.Term_Type__c == null) {
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.GENERATE_LINES_MSG));
                       return;
                   }   
            }
            
            //Check for term type
            if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CONTRACT_ABC_OBJ_API_NAME)) {
                
                //Check for Term Type
                if(String.isNotBlank(parentObjectWrapper.contractABC.Term_Type__c) && parentObjectWrapper.contractABC.Term_Type__c == RMConstants.CONTRACT_ABC_FIXED_TERM) {
                    
                    //Check for Setup in Negotiated values and add new ABC Revenue record
                    if(parentObjectWrapper.contractABC.Setup_in_Negotiated__c != null && parentObjectWrapper.contractABC.Setup_in_Negotiated__c > 0) {      
                        aBCrevenues.add(new RevenueManagementWrapper(RMUtility.popuateRevenue(parentObjectWrapper.contractABC, null, RMConstants.ABC_REVENUE_FEE_TYPE_SETUP, product.Id, defaultABCRevenueRecordType),primaryTemplates, defaultTemplate, true, true, lineStatusOptions));
                        aBCrevenues[aBCrevenues.size()-1].currentRowNo = aBCrevenues.size();
                    }   
                    
                    //Add fixed term ABC Revenue record
                    aBCrevenues.add(new RevenueManagementWrapper(RMUtility.popuateRevenue(parentObjectWrapper.contractABC, null, RMConstants.ABC_REVENUE_FEE_TYPE_ANNUAL, product.Id, defaultABCRevenueRecordType), primaryTemplates, defaultTemplate, true, true, lineStatusOptions));
                    aBCrevenues[aBCrevenues.size()-1].currentRowNo = aBCrevenues.size();
                }   
            }
            
            //Check for term type
            if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CPQ_SUBSCRIPTION_OBJ_API_NAME)) {
                
                //Check for Term Type
                if(String.isNotBlank(parentObjectWrapper.sBQQSubcription.Term_Type__c) && parentObjectWrapper.sBQQSubcription.Term_Type__c == RMConstants.CONTRACT_ABC_FIXED_TERM) {
                    
                    //Check for Setup in Negotiated values and add new ABC Revenue record
                    if(parentObjectWrapper.sBQQSubcription.Setup_in_Negotiated__c != null && parentObjectWrapper.sBQQSubcription.Setup_in_Negotiated__c > 0) {      
                        aBCrevenues.add(new RevenueManagementWrapper(RMUtility.popuateRevenue(null, parentObjectWrapper.sBQQSubcription, RMConstants.ABC_REVENUE_FEE_TYPE_SETUP, product.Id, defaultABCRevenueRecordType),primaryTemplates, defaultTemplate, true, true, lineStatusOptions));
                        aBCrevenues[aBCrevenues.size()-1].currentRowNo = aBCrevenues.size();
                    }
                    
                    //Add fixed term ABC Revenue record
                    aBCrevenues.add(new RevenueManagementWrapper(RMUtility.popuateRevenue(null, parentObjectWrapper.sBQQSubcription, RMConstants.ABC_REVENUE_FEE_TYPE_ANNUAL, product.Id, defaultABCRevenueRecordType), primaryTemplates, defaultTemplate, true, true, lineStatusOptions));
                    aBCrevenues[aBCrevenues.size()-1].currentRowNo = aBCrevenues.size();
                }   
            }   
            
        } catch(Exception e) {
            
            //Add Error on page
            ApexPages.addMessages(e);
        }
    }
    
    /**
    *  @description    :   This method is used to clone the ABC Revenue records from selected Contract ABC record
    *                                 
    *                  
    *  @args           :   
    *
    *  @return         :   void
    *  
    *  @Revision Log   :   V1.0 - 2/8/2017 - Created - CR-20161102-10316 - Subhash Garhwal 
    *
    **/
    public void cloneABCRevenueFromContractABC() {
        
        try {
            
            //Check for Contract Records
            if(revenuemManagementWrap.aBCRevenue.Contract_ABC__c != null) {
                
                //Check for same contract
                if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CONTRACT_ABC_OBJ_API_NAME)) {
                    if(revenuemManagementWrap.aBCRevenue.Contract_ABC__c == parentObjectWrapper.contractABC.Id) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.UNABLE_TO_CLONE_ERROR));
                        return;
                    }   
                }
                
                //Global describe
                Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
                
                //Query through the ABC Revenue
                List<ABC_Revenue__c> originalABCRevenues = new List<ABC_Revenue__c>();
                
                //Checking for object name before retrieving the records
                if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CONTRACT_ABC_OBJ_API_NAME))
                    originalABCRevenues = (List<ABC_Revenue__c>)Database.query(RMUtility.buildSOQL(globalDescribe, 'ABC_Revenue__c') + ' Where Contract_ABC__c = \'' + revenuemManagementWrap.aBCRevenue.Contract_ABC__c + '\'');
                
                //Pre Clone condition
                if(originalABCRevenues.size() == 0 && parentObjectAPIName.equalsIgnoreCase(RMConstants.CONTRACT_ABC_OBJ_API_NAME)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.CLONE_LINES_MSG));
                    return;
                }
                
                //Check for size
                if(originalABCRevenues.size() > 0) {
                    
                    //Clone ABC Revenue Record
                    List<ABC_Revenue__c> clonedABCRevenues = originalABCRevenues.deepClone(false,true);
                    
                    //Loop over the cloned Revenues
                    for(ABC_Revenue__c revenue : clonedABCRevenues) {
                        
                        //Call Utility Method to update the field values on cloned revenue record according to current Contract ABC
                        revenue.RecordTypeId = defaultABCRevenueRecordType;
                        
                        if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CONTRACT_ABC_OBJ_API_NAME))
                            revenue = RMUtility.updateClonedRevenues(revenue, parentObjectWrapper.contractABC, null, product.Id);
                        
                        //List to hold the final LineStatus values
                        List<SelectOption> finalLineStatusValues = new List<SelectOption>();
                        
                        finalLineStatusValues.addAll(lineStatusOptions);
                        
                        if(lineStatusOptions.size() <= 0){
                            
                            //Check for Line Status value
                            if(String.isNotBlank(revenue.Line_Status__c) && !lineStatusValues.contains(revenue.Line_Status__c))
                                finalLineStatusValues.add(new SelectOption(revenue.Line_Status__c, revenue.Line_Status__c));
                        }
                        
                        //Add Records in wrapper to display
                        aBCrevenues.add(new RevenueManagementWrapper(revenue, primaryTemplates, String.isNotBlank(revenue.Rev_Rec_Template_Ids__c) ? revenue.Rev_Rec_Template_Ids__c.split(',')[0] : defaultTemplate, true, true, finalLineStatusValues));
                        aBCrevenues[aBCrevenues.size()-1].currentRowNo = aBCrevenues.size();
                    }
                }
            } else if(revenuemManagementWrap.aBCRevenue.Program_Subscription__c != null) {
                
                //Check for same subscription
                if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CPQ_SUBSCRIPTION_OBJ_API_NAME)) {
                    if(revenuemManagementWrap.aBCRevenue.Program_Subscription__c == parentObjectWrapper.sBQQSubcription.Id) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.UNABLE_TO_CLONE_SUBSCRIPTION_ERROR));
                        return;
                    }   
                }
               
                //Global describe
                Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
                
                //Query through the ABC Revenue
                List<ABC_Revenue__c> originalABCRevenues = new List<ABC_Revenue__c>();
                
                //Checking for object name before retrieving the records
                if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CPQ_SUBSCRIPTION_OBJ_API_NAME))
                    originalABCRevenues = (List<ABC_Revenue__c>)Database.query(RMUtility.buildSOQL(globalDescribe, 'ABC_Revenue__c') + ' Where Program_Subscription__c = \'' + revenuemManagementWrap.aBCRevenue.Program_Subscription__c + '\'');
                
                //Pre Clone condition
                if(originalABCRevenues.size() == 0 && parentObjectAPIName.equalsIgnoreCase(RMConstants.CPQ_SUBSCRIPTION_OBJ_API_NAME)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.CLONE_LINE_MSG_SUBSCRIPTION));
                    return;
                }
                
                //Check for size
                if(originalABCRevenues.size() > 0) {
                    
                    //Clone ABC Revenue Record
                    List<ABC_Revenue__c> clonedABCRevenues = originalABCRevenues.deepClone(false,true);
                    
                    //Loop over the cloned Revenues
                    for(ABC_Revenue__c revenue : clonedABCRevenues) {
                        
                        //Call Utility Method to update the field values on cloned revenue record according to current Contract ABC
                        revenue.RecordTypeId = defaultABCRevenueRecordType;
                        
                        if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CPQ_SUBSCRIPTION_OBJ_API_NAME))
                            revenue = RMUtility.updateClonedRevenues(revenue, null, parentObjectWrapper.sBQQSubcription, product.Id);
                        
                        //List to hold the final LineStatus values
                        List<SelectOption> finalLineStatusValues = new List<SelectOption>();
                        
                        finalLineStatusValues.addAll(lineStatusOptions);
                        
                        if(lineStatusOptions.size() <= 0){
                            
                            //Check for Line Status value
                            if(String.isNotBlank(revenue.Line_Status__c) && !lineStatusValues.contains(revenue.Line_Status__c))
                                finalLineStatusValues.add(new SelectOption(revenue.Line_Status__c, revenue.Line_Status__c));
                        }
                        //Add Records in wrapper to display
                        aBCrevenues.add(new RevenueManagementWrapper(revenue, primaryTemplates, String.isNotBlank(revenue.Rev_Rec_Template_Ids__c) ? revenue.Rev_Rec_Template_Ids__c.split(',')[0] : defaultTemplate, true, true, finalLineStatusValues));
                        aBCrevenues[aBCrevenues.size()-1].currentRowNo = aBCrevenues.size();
                    }
                }
                
            } else {
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.UNABLE_TO_CLONE_LINES_ERROR));
                return;
                
            }
            
        } catch(Exception e) {
            
            //Add Error on page
            ApexPages.addMessages(e);
        }
    }
    
    /**
    *  @description    :   This method is used to copy the selected ABC Revenues records from current Contract ABC 
    *                                  
    *  @args           :   
    *
    *  @return         :   void
    *  
    *  @Revision Log   :   V1.0 - 2/8/2017 - Created - CR-20161102-10316 - Subhash Garhwal 
    *
    **/
    public void copyABCRevenueFromCurrentContractABC() {
        
        try {
            
            //variable to check if any record is selected or not
            Boolean isSelected = false;
            
            //Check for ABCRevenue wrapper class
            if(aBCrevenues.size() > 0) {
                
                //Temp list of Revenue wrapper
                List<RevenueManagementWrapper> tempRevenueWrapper = new List<RevenueManagementWrapper>();
                
                //Loop over the ABC Revenue wrapper
                for(RevenueManagementWrapper rMW : aBCrevenues) {
                    
                    
                    //Check for selected record
                    if(rMW.selected) {
                        
                        //Set flag value to bypass validation
                        isSelected = true;
                        
                        //Clone the selected record
                        ABC_Revenue__c copyRevenue = rMW.aBCRevenue.clone();
                        copyRevenue.RecordTypeId = defaultABCRevenueRecordType;
                        
                        //Modified By - Abhinav Sharma - 5/15/2017 - CR-20170508-10923
                        //Call utility method to update copied records values
                        if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CONTRACT_ABC_OBJ_API_NAME))
                            copyRevenue = RMUtility.updateCopiedRevenues(copyRevenue, parentObjectWrapper.contractABC, null, product.Id, rMW);
                        
                        //Call utility method to update copied records values
                        if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CPQ_SUBSCRIPTION_OBJ_API_NAME))
                            copyRevenue = RMUtility.updateCopiedRevenues(copyRevenue, null, parentObjectWrapper.sBQQSubcription, product.Id, rMW);
                        
                        
                        //List to hold the final LineStatus values
                        List<SelectOption> finalLineStatusValues = new List<SelectOption>();
                        
                        finalLineStatusValues.addAll(lineStatusOptions);
                        
                        if(lineStatusOptions.size() <= 0){
                            
                            //Check for Line Status value
                            if(String.isNotBlank(copyRevenue.Line_Status__c) && !lineStatusValues.contains(copyRevenue.Line_Status__c))
                                finalLineStatusValues.add(new SelectOption(copyRevenue.Line_Status__c, copyRevenue.Line_Status__c));
                        }
                        
                        RevenueManagementWrapper tempRev = new RevenueManagementWrapper(copyRevenue, primaryTemplates, rMW.selectedTemplate, true, true, finalLineStatusValues);
                        tempRev.isCopied = true;
                        tempRevenueWrapper.add(tempRev);        
                    }
                }
                
                //Add All the copied records in main revenue wrapper
                aBCrevenues.addAll(tempRevenueWrapper);
            }
            
            //Check for value
            if(!isSelected) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.UNABLE_TO_COPY_LINES_ERROR));
                return;
            }
            
        } catch(Exception e) {
            
            //Add Error on page
            ApexPages.addMessages(e);
        }
    }
    
    /**
    *  @description    :   This method is used to add new Blank ABC Revenue records according to provided number 
    *                                  
    *  @args           :   
    *
    *  @return         :   void
    *  
    *  @Revision Log   :   V1.0 - 2/8/2017 - Created - CR-20161102-10316 - Subhash Garhwal 
    *
    **/
    public void addBlankABCRevenue() {
        
        try {
            
            //Check for Integer
            if(totalNewLines != null && Integer.valueOf(totalNewLines) > 0) {
                
                //Loop to total number of new lines
                for(Integer i = 0; i < Integer.valueOf(totalNewLines); i++) {
                    
                    //Add Revenue record in list
                    if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CONTRACT_ABC_OBJ_API_NAME))
                        aBCrevenues.add(new RevenueManagementWrapper(RMUtility.updateNewRevenues(parentObjectWrapper.contractABC, null, product.Id, defaultABCRevenueRecordType), primaryTemplates, defaultTemplate, true, true, lineStatusOptions));
                    
                    //Call utility method to update copied records values
                    if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CPQ_SUBSCRIPTION_OBJ_API_NAME))
                        aBCrevenues.add(new RevenueManagementWrapper(RMUtility.updateNewRevenues(null, parentObjectWrapper.sBQQSubcription, product.Id, defaultABCRevenueRecordType), primaryTemplates, defaultTemplate, true, true, lineStatusOptions));
                    
                    aBCrevenues[aBCrevenues.size()-1].currentRowNo = aBCrevenues.size();
                }
            }
            
        } catch(Exception e) {
            
            //Add Error on page
            ApexPages.addMessages(e);
        }
    }
    
    /**
    *  @description    :   This method is used to edit the added ABC Revenues  
    *                                  
    *  @args           :   
    *
    *  @return         :   void
    *  
    *  @Revision Log   :   V1.0 - 2/8/2017 - Created - CR-20161102-10316 - Subhash Garhwal            
    *
    **/
    public void massEditABCRevenue() {
        
        try {
            
            //variable to check if any record is selected or not
            Boolean isSelected = false;
            
            //Check for ABCRevenue wrapper class
            if(aBCrevenues.size() > 0) {
                
                //Loop over the ABC Revenue wrapper
                for(RevenueManagementWrapper rMW : aBCrevenues) {
                    
                    //Check for selected record
                    if(rMW.selected) {
                        
                        //Set selected flag
                        isSelected = true;
                        
                        //Call Utility method to edit the values
                        RMUtility.massEditRevenues(rMW, revenuemManagementWrap, mapTemplates);
                    }
                }
            }
            
            //Check for value
            if(!isSelected) {
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.PLEASE_SELECT_ONE_RECORD_ERROR));
                return;
                
            }
            
        } catch(Exception e) {
            
            //Add Error on page
            ApexPages.addMessages(e);
        }
    }
    
    /**
    *  @description    :   This method is used to edit the single ABC Revenue    
    *                                  
    *  @args           :   
    *
    *  @return         :   void
    *  
    *  @Revision Log   :   V1.0 - 2/15/2017 - Created - CR-20161102-10316 - Subhash Garhwal 
    *
    **/
    public void singleEditABCRevenue() {
        
        try {
            
            //Check for Index and Utility method to edit the values
            if(revenueIndex != null && aBCrevenues.size() >= revenueIndex)
                RMUtility.massEditRevenues(aBCrevenues[revenueIndex], null, mapTemplates);
            
        } catch(Exception e) {
            
            //Add Error on page
            ApexPages.addMessages(e);
        }
    }
    
    //Added By Rajeev - 09/28/2017 - Hold on the fly Deployment Clarizen Selected Value
    public Date depClarizenValue {get;set;}
    
    /**
    *  @description    :   This method is used to edit the single ABC Revenue    
    *                                  
    *  @args           :   
    *
    *  @return         :   void
    *  
    *  @Revision Log   :   V1.0 - 09/28/2017 - Created - Rajeev Jain
    *            	   V1.1 - 10/03/2017 - Modified - Subhash Garhwal - CR-20170907-11185 - Added logic to pass value in wrapper
    *                      V1.2 - Remove the reference of "Clarizen_First_Go_Live_Complete__c" - By abhinav Sharma - 7/6/2020 - CR-20200204-13690
    *
    **/
    public void populateClarizenValue(){
        
        //Check for Index and Utility method to edit the values
        if(revenueIndex != null && aBCrevenues.size() >= revenueIndex && aBCrevenues[revenueIndex].aBCRevenue != null && aBCrevenues[revenueIndex].aBCRevenue.Deployment__c != null){
            //Query on Deployment Object and Populate ABC Revenue Clarizen Value
            List<Deployment__c> deployments = [select Id /*,Clarizen_First_Go_Live_Complete__c*/ from Deployment__c where Id = :aBCrevenues[revenueIndex].aBCRevenue.Deployment__c];              
           // depClarizenValue = deployments.size() > 0 ? deployments[0].Clarizen_First_Go_Live_Complete__c : null;
           depClarizenValue = null;
            
            //Check for value
            if(depClarizenValue != null) {
                
                //Update values
                aBCrevenues[revenueIndex].aBCRevenue.Site_Live_Date__c = depClarizenValue;
                aBCrevenues[revenueIndex].isSiteLiveDateChangedFromDeployment = true;
            }
            System.debug('#########aBCrevenues[revenueIndex].aBCRevenue.Site_Live_Date__c : ' +aBCrevenues[revenueIndex].aBCRevenue.Site_Live_Date__c); 
            
        } else
            depClarizenValue = null;  
        
        //Set Date in Wrapper instance
        aBCrevenues[revenueIndex].clarizenFirstGoLiveComplete = depClarizenValue;
        
    }
    
    /**
    *  @description    :   This method is used to Remove the unsave ABC Revenue  
    *                                  
    *  @args           :   
    *
    *  @return         :   void
    *  
    *  @Revision Log   :   V1.0 - 2/8/2017 - Created - CR-20161102-10316 - Subhash Garhwal 
    *
    **/
    public void removeABCRevenue() {
        
        try {
            
            //Check for Index
            if(revenueIndex != null && aBCrevenues.size() >= revenueIndex) {
                
                //Check for Id
                if(aBCrevenues[revenueIndex].aBCRevenue.Id == null)
                    aBCrevenues.remove(revenueIndex);
            }
            
            //Loop through list size and updating row number of wrapper instance
            for(Integer u=0; u<aBCrevenues.size(); u++)
                aBCrevenues[u].currentRowNo = (u+1);
            
            revenueIndex = null;
            
        } catch(Exception e) {
            
            //Add Error on page
            ApexPages.addMessages(e);
        }
    }
    
    /**
    *  @description    :   This method is used to save the ABC Revenue record  
    *                                  
    *  @args           :   
    *
    *  @return         :   void
    *  
    *  @Revision Log   :   V1.0 - 2/8/2017 - Created - CR-20161102-10316 - Subhash Garhwal 
    *                      V1.1 - 05/13/2020 - CR-20200512-14039 - Victor Hanson - include negotiated and secured amt as required fields
    *                      V1.2 - Modified By - Mahendra Swarnkar - 06/23/2021 - CR-20210325-15033 - Update Template on RR lines
    *
    **/
    public void doSave() {
        
        try {
            
            //Check for Revenue record
            if(aBCrevenues.size() > 0) {
                
                System.debug('#######aBCrevenues : ' +aBCrevenues);
                //Temp variable
                transient integer j=1;
                
                //Loop over the Revenue wrapper
                for(RevenueManagementWrapper rMW : aBCrevenues) {
                    
                    //Initializing error message instance
                    rMW.errorMessage = '';
                    rMW.currentRowNo = j;
                    
                    //Modified By - Mahendra Swarnkar - 06/23/2021 - CR-20210325-15033 - Update Template on RR lines
                    //Check for all the required fields
                    if(/*String.isBlank(rMW.selectedTemplate) ||*/ (!rMW.isLineStatusNotMatches && String.isBlank(rMW.aBCRevenue.Line_Status__c)) || rMW.aBCRevenue.Recognition_Start_Date__c == null
                       || rMW.aBCRevenue.Recognition_End_Date__c == null || String.isBlank(rMW.aBCRevenue.Fee_Type__c) || rMW.aBCRevenue.Negotiated_Amount__c == null
                       || String.isBlank(rMW.aBCRevenue.Risk_Type__c) || rMW.aBCRevenue.Expected_Amount_to_Recognize__c == null || rMW.aBCRevenue.Secured_Amount__c == null
                       || rMW.aBCRevenue.Secured_Amount_GAAP__c == null || String.isBlank(rMW.aBCRevenue.Risk_Status__c))
                        rMW.errorMessage += '<b>' + ROW_NUMBER + rMW.currentRowNo + ' : </b> ' + System.Label.PLEASE_POPULATE_ALL_REQUIRED_FIELDS_ERROR + '<br/>';
                    
                    //Increment the counter by 1
                    j++;
                }
                
                //List of ABC Revenue management
                transient List<ABC_Revenue__c> aBCRevenueToUpsert = new List<ABC_Revenue__c>();
                
                //List to hold the row numbers
                List<Integer> listOfSucceededABCRevenues = new List<Integer>();
                
                //Loop through ABC Revenue records and checking for the error message
                for(RevenueManagementWrapper rMWW : aBCrevenues) {
                    
                    //Checking for the error message
                    if(String.isBlank(rMWW.errorMessage)) {
                        
                        //Check for template
                        if(String.isNotBlank(rMWW.selectedTemplate)) {
                            
                            //Check Template in map
                            if(mapTemplates.containsKey(rMWW.selectedTemplate)) {
                                
                                //Reinitialize templates list
                                rMWW.templates = new List<String>();
                                
                                //Get Template Name
                                rMWW.aBCRevenue.Rev_Rec_Templates__c = mapTemplates.get(rMWW.selectedTemplate).Name + (mapTemplates.get(rMWW.selectedTemplate).Template_A__c != null ? ';' + mapTemplates.get(rMWW.selectedTemplate).Template_A__r.Name : '');
                                rMWW.aBCRevenue.Rev_Rec_Template_Ids__c = mapTemplates.get(rMWW.selectedTemplate).Id + (mapTemplates.get(rMWW.selectedTemplate).Template_A__c != null ? ',' + mapTemplates.get(rMWW.selectedTemplate).Template_A__c : '');

                                
                                //Populate values in wrapper variables
                                rMWW.templates.add(mapTemplates.get(rMWW.selectedTemplate).Name);
                                rMWW.templates.add(mapTemplates.get(rMWW.selectedTemplate).Template_A__c != null ? ';' + mapTemplates.get(rMWW.selectedTemplate).Template_A__r.Name : '');
                            }
                        }
                        
                        //Populate list with row no value
                        if(rMWW.currentRowNo != null)
                            listOfSucceededABCRevenues.add(rMWW.currentRowNo);
                        
                        //Populating "Change Reason Code" with the value of "Change_Reason_Code_Clone__c"
                        if(String.isNotBlank(rMWW.aBCRevenue.Change_Reason_Code_Clone__c))
                            rMWW.aBCRevenue.Change_Reason_Code__c = rMWW.aBCRevenue.Change_Reason_Code_Clone__c;
                        
                        //Checking for the selected template value
                        if(String.isNotBlank(rMWW.selectedTemplate))
                            rMWW.aBCRevenue.Rev_Rec_Template_Selected__c = rMWW.selectedTemplate;
                            //Added by Colin McGloin - CR-20180918-12607 - directly populating since we only need one Template now
                            rMWW.aBCRevenue.ffrrtemplate__c = rMWW.selectedTemplate;
                        
                        //Checking for wrapper properties and set line status accordingly
                        if(rmWW.isLineStatusNotMatches && String.isBlank(rmWW.aBCRevenue.Line_Status__c)) {
                            if(String.isNotBlank(rmWW.lineStatusOldValue))
                                rmWW.aBCRevenue.Line_Status__c = rmWW.lineStatusOldValue;
                        }
                        System.debug(' Row Number ::: ' + rMWW.currentRowNo + 'Check if Item is to upsert in list ::: ' + rMWW.aBCRevenue);    
                        //Add Revenue record in list
                        aBCRevenueToUpsert.add(rMWW.aBCRevenue);
                    }
                }
                
                //Check for Revenue record
                if(aBCRevenueToUpsert.size() > 0) {
                    
                    //Temp integer variable
                    transient integer m = 0;
                    
                    //List of successfully upsert revenue row numbers
                    List<Integer> listOfSuccessfullyUpsertedRevenues = new List<Integer>();
                    
                    //Map to hold the revenue ID as key and corresponding row number as value
                    transient Map<Id, Integer> mapRevenueIDWithRowNo = new Map<Id, Integer>();
                    
                    //Iterate through each returned result
                    for(Database.UpsertResult upsertResult : Database.upsert(aBCRevenueToUpsert, false)) {
                        
                        //Check for success
                        if (!upsertResult.isSuccess()) {
                            
                            //Operation failed, so get all errors
                            for(Database.Error err : upsertResult.getErrors()) {
                                
                                //setting error message
                                if(listOfSucceededABCRevenues.get(m) != null) 
                                    aBCrevenues[m].errorMessage += '<b>' + ROW_NUMBER + listOfSucceededABCRevenues.get(m) + ' : </b> ' +  err.getMessage() + '<br/>';
                                else
                                    aBCrevenues[m].errorMessage += err.getMessage() + '<br/>';
                            }
                            
                        } else {
                            
                            //Populating list with values
                            if(listOfSucceededABCRevenues.get(m) != null)
                                listOfSuccessfullyUpsertedRevenues.add(listOfSucceededABCRevenues.get(m));
                            
                            //Populating map with values
                            mapRevenueIDWithRowNo.put(upsertResult.getId(), m);
                        }
                        
                        //Increasing the counter by 1
                        m++;
                    }
                    
                    //Added these fields Integrated_for_Revenue_Purposes__c ,Integrated_Account_Name__c in the query -  By Dipesh Gupta - 09/19/2019 - CR-20190904-13311
                    //List of ABC revenue got succeeded in the upsert operation
                    //Query through the ABCRenueLines
                    transient List<ABC_Revenue__c> aBCRevenueGotUpsertedSuccessfully = new List<ABC_Revenue__c>([Select Id, Name, Account_Formal_Name__c, Comments__c, 
                                                                                                                 Contract__c, Contract_ABC__c, Expected_Amount_to_Recognize__c,
                                                                                                                 Fee_Type__c, GAAP_Amount__c, Include_in_Rev_Rec__c, Institution__c, Line_Status__c, List_Price__c, Product__c,
                                                                                                                 Program_Code__c, Recognition_End_Date__c, Recognition_Start_Date__c, Rev_Rec_Complete__c, Rev_Rec_Posted_Date__c, 
                                                                                                                 Negotiated_Amount__c, Rev_Rec_Template_Selected__c,
                                                                                                                 Rev_Rec_Templates__c, Rev_Rec_Template_Ids__c, Risk_Type__c, Risk_Status__c, Risk_Due_Date__c, Integrated_for_Revenue_Purposes__c,Integrated_Account_Name__c, Secured_Amount__c,
                                                                                                                 Cost_Center__c, Program__c, Recognized_to_Date__c, Site_Live_Date__c, Revenue_Recognition_Account__c, 
                                                                                                                 RecordTypeId, Risk_Maximum_Potential__c,
                                                                                                                 Risk_Expected__c, Risk_Estimated__c, Change_Reason_Code__c, Change_Reason_Code_Clone__c, Program__r.Name,
                                                                                                                 Recognized_to_Date_GAAP__c, Recognized_to_Date_Negotiated__c, Secured_Amount_GAAP__c, Deferred_Revenue_Negotiated__c, 
                                                                                                                 Deferred_Revenue_GAAP__c From ABC_Revenue__c Where Id IN : mapRevenueIDWithRowNo.keySet()]);
                    
                    //List of ABC Revenue Lines to upsert
                    //transient List<ABC_Revenue_Line__c> aBCRevenueLinesToUpsert = new List<ABC_Revenue_Line__c>();
                    
                    //List of ABC Revenue Lines to delete
                    //transient List<ABC_Revenue_Line__c> aBCRevenueLinesDelete = new List<ABC_Revenue_Line__c>();
                    
                    //List of charactors for naming
                    //transient List<String> aBCRevenueLineNamingChar = new List<String>{'A','B', 'C', 'D'};
                        
                    //List of ABC Revenue lines
                    //List<ABC_Revenue_Line__c> listOfABCRevenueLines = new List<ABC_Revenue_Line__c>();
                    //mapABCRevenueLinesWithABCRevenue = new Map<Id, List<ABC_Revenue_Line__c>>();
                    //Map<Id, ABC_Revenue_Line__c> mapOfRevenueLines = new Map<Id, ABC_Revenue_Line__c>();
                    
                    //Checking for object type
                    /*if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CONTRACT_ABC_OBJ_API_NAME)) {
                        
                        //Retrieving revenue lines asscoiated with the contract ABC records
                        listOfABCRevenueLines = [Select Id, Name, ABC_Revenue__c, ffrrtemplate__c, ffrrtemplate__r.Name, Include_in_Rev_Rec__c, 
                                                 Rev_Rec_Complete__c, Rev_Rec_Posted_Date__c 
                                                 From ABC_Revenue_Line__c 
                                                 Where ABC_Revenue__r.Contract_ABC__c  =: parentObjectWrapper.parentRecordID 
                                                 ORDER BY Name ASC];
                        
                    } else if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CPQ_SUBSCRIPTION_OBJ_API_NAME)) {
                        
                        //Retrieving revenue lines asscoiated with the Subscription records
                        listOfABCRevenueLines = [Select Id, Name, ABC_Revenue__c, ffrrtemplate__c, ffrrtemplate__r.Name, Include_in_Rev_Rec__c,
                                                 Rev_Rec_Complete__c, Rev_Rec_Posted_Date__c 
                                                 From ABC_Revenue_Line__c 
                                                 Where ABC_Revenue__r.Program_Subscription__c  =: parentObjectWrapper.parentRecordID 
                                                 ORDER BY Name ASC];
                    }*/
                    
                    //Loop over the ABC Revenue Lines
                    /*for(ABC_Revenue_Line__c aBCRL : listOfABCRevenueLines) {
                        
                        //Check ABC Revenue in map
                        if(!mapABCRevenueLinesWithABCRevenue.containsKey(aBCRL.ABC_Revenue__c))
                            mapABCRevenueLinesWithABCRevenue.put(aBCRL.ABC_Revenue__c, new List<ABC_Revenue_Line__c>());
                        
                        //Add ABC Revenue Line in map   
                        mapABCRevenueLinesWithABCRevenue.get(aBCRL.ABC_Revenue__c).add(aBCRL);
                        
                        mapOfRevenueLines.put(aBCRL.ID, aBCRL);
                    }*/
                    
                    //Loop over the ABC Revenues
                    for(ABC_Revenue__c revenue : aBCRevenueGotUpsertedSuccessfully) {
                        
                        //Updating properties in wrapper instance
                        if(aBCrevenues.size() >= mapRevenueIDWithRowNo.values().size()) {
                            if(mapRevenueIDWithRowNo.containsKey(revenue.ID) && aBCrevenues[mapRevenueIDWithRowNo.get(revenue.ID)] != null) {
                                if(String.isBlank(aBCrevenues[mapRevenueIDWithRowNo.get(revenue.ID)].errorMessage)) {
                                    
                                    aBCrevenues[mapRevenueIDWithRowNo.get(revenue.ID)].aBCRevenue.Line_Status__c = revenue.Line_Status__c;
                                    aBCrevenues[mapRevenueIDWithRowNo.get(revenue.ID)].aBCRevenue.Site_Live_Date__c = revenue.Site_Live_Date__c;
                                }
                            }
                        }
                        
                        //Spacial char index
                        Integer aBCRLCharIndex = 0;
                        
                        //Check for Template in list
                        /*if(revenue.Rev_Rec_Template_Ids__c != null) {
                            
                            //List of template Ids
                            List<String> templateIds = revenue.Rev_Rec_Template_Ids__c.split(',');
                            
                            //Loop to create/update ABC Revenue Lines according to selected templates
                            for(Integer i = 0; i < 2; i++) {
                                
                                //Check for Existing lines
                                if(mapABCRevenueLinesWithABCRevenue.containsKey(revenue.Id) 
                                   && mapABCRevenueLinesWithABCRevenue.get(revenue.Id).size() > i) {
                                       
                                       //Check for template
                                       if(templateIds.size() > i) {
                                           
                                           //Update Template
                                           mapABCRevenueLinesWithABCRevenue.get(revenue.Id)[i].ffrrtemplate__c = templateIds[i];
                                           
                                           //Add Record in list
                                           aBCRevenueLinesToUpsert.add(mapABCRevenueLinesWithABCRevenue.get(revenue.Id)[i]);   
                                           
                                           aBCRLCharIndex++;
                                           
                                       } else
                                           aBCRevenueLinesDelete.add(mapABCRevenueLinesWithABCRevenue.get(revenue.Id)[i]);
                                       
                                   } else if(templateIds.size() > i) {
                                       
                                       //Insert a new record
                                       ABC_Revenue_Line__c aBCRL = new ABC_Revenue_Line__c();
                                       
                                       //Populate field values
                                       aBCRL.Name = revenue.Name.replace('RR', 'RRL');
                                       
                                       //Check for Primary
                                       if(i == 1)
                                           aBCRL.Name += '-A';
                                       
                                       aBCRL.ABC_Revenue__c =  revenue.Id;
                                       aBCRL.ffrrtemplate__c = templateIds[i];
                                       
                                       //Add Line in list
                                       aBCRevenueLinesToUpsert.add(aBCRL);
                                       
                                       aBCRLCharIndex++;
                                   }
                            }
                            
                            //Delete all the exising Lines
                        } else if(mapABCRevenueLinesWithABCRevenue.containsKey(revenue.Id))
                            aBCRevenueLinesDelete.addAll(mapABCRevenueLinesWithABCRevenue.get(revenue.Id));*/
                    }
                    
                    //Temp integer variable
                    transient integer n = 0;
                    
                    //Set of revenue lines got upserted successfully
                    //Set<Id> setOfRevLinesUpsertedSuccessfully = new Set<Id>();
                    
                    //Upsert revenue records
                    /*if(aBCRevenueLinesToUpsert.size() > 0) {
                        
                        //Iterate through each returned result
                        for(Database.UpsertResult upsertResult1 : Database.upsert(aBCRevenueLinesToUpsert, false)) {
                            
                            //Check for success
                            if (!upsertResult1.isSuccess()) {
                                
                                //Operation failed, so get all errors
                                for(Database.Error err1 : upsertResult1.getErrors()) {
                                    
                                    //create log message
                                    if(listOfSuccessfullyUpsertedRevenues.get(n) != null) 
                                        aBCrevenues[n].errorMessage += '<b>' + ROW_NUMBER + listOfSuccessfullyUpsertedRevenues.get(n) + ' : </b> ' +  err1.getMessage() + '<br/>';
                                    else
                                        aBCrevenues[n].errorMessage += err1.getMessage() + '<br/>';
                                }
                            } else {
                                setOfRevLinesUpsertedSuccessfully.add(upsertResult1.getId());
                            }
                            
                            //increment the counter by 1
                            n++;
                        }
                    }*/
                    
                    //Temp variable
                    transient integer l=1;
                    
                    //Popuating set with the successive indexes
                    transient Set<Integer> setOfRevenueSuccessiveIndexes = new Set<Integer>();
                    if(listOfSuccessfullyUpsertedRevenues.size() > 0)
                        setOfRevenueSuccessiveIndexes.addAll(listOfSuccessfullyUpsertedRevenues);

                    //Checking set for it's size
                    /*if(setOfRevLinesUpsertedSuccessfully.size() > 0) {
                        
                        //Retrieving updated data from the database for the successive records
                        mapOfRevenueLines = new Map<Id, ABC_Revenue_Line__c>([Select Id, Name, ABC_Revenue__c, ffrrtemplate__c, 
                                                                              ffrrtemplate__r.Name, Include_in_Rev_Rec__c,
                                                                              Rev_Rec_Complete__c, Rev_Rec_Posted_Date__c 
                                                                              From ABC_Revenue_Line__c 
                                                                              Where ID IN : setOfRevLinesUpsertedSuccessfully 
                                                                              ORDER BY Name ASC]);
                        
                    }*/
                    
                    //Map to hold the ABC Revenue with ABC RevenueLine Wrapper
                    //Map<Id, List<RevenueManagementWrapper.ABCRevenueLineWrapper>> mapABCRevenueLinesWrapper = new Map<Id, List<RevenueManagementWrapper.ABCRevenueLineWrapper>>();
                    
                    //Loop over the ABC Revenue Lines
                    /*for(ABC_Revenue_Line__c aBCRL : mapOfRevenueLines.values()) {
                        
                        //Check ABC Revenue Line
                        if(!mapABCRevenueLinesWrapper.containsKey(aBCRL.ABC_Revenue__c))
                            mapABCRevenueLinesWrapper.put(aBCRL.ABC_Revenue__c, new List<RevenueManagementWrapper.ABCRevenueLineWrapper>());
                        
                        //Check for ABC Revenue Record size
                        if(mapABCRevenueLinesWrapper.get(aBCRL.ABC_Revenue__c).size() < 2)
                            mapABCRevenueLinesWrapper.get(aBCRL.ABC_Revenue__c).add(new RevenueManagementWrapper.ABCRevenueLineWrapper(aBCRL));
                    }*/
                    
                    //Loop through wrapper list and populating page message list with all the error messages
                    /*for(RevenueManagementWrapper r : aBCrevenues) {
                        
                        if(r.aBCRevenue != null 
                           && r.aBCRevenue.Id != null
                           && mapABCRevenueLinesWrapper.containsKey(r.aBCRevenue.Id)
                          ) {
                              r.abcRevenueLineWrapper = mapABCRevenueLinesWrapper.get(r.aBCRevenue.Id);
                          }
                    }*/
                    
                    //Loop through wrapper list and populating page message list with all the error messages
                    for(RevenueManagementWrapper rMWWW : aBCrevenues) {
                        
                        //Checking if error message exists on current wrapper instance
                        if(String.isNotBlank(rMWWW.errorMessage))
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, rMWWW.errorMessage));
                        
                        //Blank out "Change Reason Code Clone" for the succeeded records 
                        if(setOfRevenueSuccessiveIndexes.contains(l))
                            rMWWW.aBCRevenue.Change_Reason_Code_Clone__c = null;
                        
                        //increment the counter by 1
                        l++;
                    }
                }
            }
            
        } catch(Exception e) {
            
            //Add Error on page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }       
    
    /**
    *  @description    :   Save and Close method  
    *                                  
    *  @args           :   
    *
    *  @return         :   Pagereference
    *  
    *  @Revision Log   :   V1.0 - 2/8/2017 - Created - CR-20161102-10316 - Subhash Garhwal 
    *
    **/
    public Pagereference saveAndClose() {
        
        try {
            
            //Save the entire request
            doSave();
            
            //return to the page reference
            return cancel();
            
        } catch(Exception e) {
            
            //Add Error on page
            ApexPages.addMessages(e);
            return null;
        }
        
	// Comment By - Rajeev Jain - CR-20200217-13763 - 06/15/2020
        //return null;
    }
    
    /**
    *  @description    :   Method to check the Manage Revenue page mode  
    *                                  
    *  @args           :   
    *
    *  @return         :   void
    *  
    *  @Revision Log   :   V1.0 - 2/8/2017 - Created - CR-20161102-10316 - Subhash Garhwal 
    *
    **/
    public void switchToManageMode() {
        
        viewMode = RMConstants.REVENUE_MANAGEMENT_PAGE_VIEW_MODE_MANAGE;
        
        //Uncheck the selected Record
        aBCRevenue = new ABC_Revenue__c();
        revenueHighlighIndex = null;
        
    }
    
    /**
    *  @description    :   Method to check the Manage Revenue page mode  
    *                                  
    *  @args           :   
    *
    *  @return         :   void
    *  
    *  @Revision Log   :   V1.0 - 2/8/2017 - Created - CR-20161102-10316 - Subhash Garhwal 
    *
    **/
    public void switchToViewMode() {
        
        viewMode = RMConstants.REVENUE_MANAGEMENT_PAGE_VIEW_MODE_REVIEW;
        
        //Uncheck the selected Record
        revenueHighlighIndex = null;
        
        inIt();
    }
    
    public void placeHolder() {}
    
    /**
    *  @description    :   Method to display ABC Revenue in detail mode  
    *                                  
    *  @args           :   
    *
    *  @return         :   void
    *  
    *  @Revision Log   :   V1.0 - 2/11/2017 - Created - CR-20161102-10316 - Subhash Garhwal 
    *
    **/
    public void aBCRevenueDetail() {
        
        //Check for Index
        if(revenueIndex != null && aBCrevenues.size() >= revenueIndex) {
            
            //Check for already selected record
            if(aBCrevenues[revenueIndex].aBCRevenue.Id != null && aBCrevenues[revenueIndex].aBCRevenue.Id == aBCRevenue.Id) {
                
                aBCRevenue = new ABC_Revenue__c();
                revenueHighlighIndex = null;
                
            } else {
                
                aBCRevenue = aBCrevenues[revenueIndex].aBCRevenue;
                revenueHighlighIndex = revenueIndex;
            }
        }
    }
    
    /**
    *  @description    :   Method to display ABC Revenue in detail mode  
    *                                  
    *  @args           :   
    *
    *  @return         :   void
    *  
    *  @Revision Log   :   V1.0 - 3/20/2017 - Created - CR-20170302-10729 - Issue--CR10729--UAT--00003766 - Subhash Garhwal 
    *                      V2.0 -  2/1/2021 - Modified By - Neha Sharma - CR-20200819-14443 - Remove the none option from the lineStatusOptions picklist
    *
    **/
    public List<SelectOption> lineStatusOptions() {
        
        //Original Line Status options
        List<SelectOption> lineStatusOptions = new List<SelectOption>();
        
        //Modified By - Neha Sharma -2/1/2021 - CR-20200819-14443 - Remove the none option from the lineStatusOptions picklist
        lineStatusOptions.add(new SelectOption('', '--None--'));
        //lineStatusOptions.add(new SelectOption('Pending', 'Pending'));
        
        //Original Picklist values
        Set<String> setLineStatusvalues = new Set<String>();
        
        //Map to hold the PL values
        Map<String,String> mapLineStatus = new Map<String, String>();
        
        //Describe the Line Status field to get picklist values
        List<Schema.PicklistEntry> describeLineStatusValues = ABC_Revenue__c.Line_Status__c.getDescribe().getPicklistValues();
        
        //Set to hold the Permission Set Name and Profile Name
        Set<String> setPermissionSetName = new Set<String>();
        Set<String> setProfileName = new Set<String>();
        
        //Loop over the PL values
        for(Schema.PicklistEntry f : describeLineStatusValues) {
            
            setLineStatusvalues.add(f.getLabel());
            mapLineStatus.put(f.getLabel(), f.getValue());
        }
        
        //Loop over the assigned Permission Set
        for(PermissionSetAssignment pSA : [Select Id, PermissionSetId, PermissionSet.Name From PermissionSetAssignment Where AssigneeId =: UserInfo.getUserId()])
            setPermissionSetName.add(pSA.PermissionSet.Name);
        
        //Get Profile Name
        setProfileName.add([Select Name From Profile Where Id =: UserInfo.getProfileId()].Name);
        
        //List to hold the available list options
        List<String> filteredValues = Util.getPicklistValues(setProfileName, setPermissionSetName, 'ABC_Revenue__c', 'Line_Status__c', setLineStatusvalues);
        List<String> tempLineStatusvalues = new List<String>();
        tempLineStatusvalues.addAll(setLineStatusvalues);
        
        //Loop over the Picklist values
        for(String lSV : filteredValues.size() > 0 ? filteredValues : tempLineStatusvalues) {
            
            //Check Label in map
            if(mapLineStatus.containsKey(lSV)) {
                
                lineStatusOptions.add(new SelectOption(mapLineStatus.get(lSV), lSV));
                lineStatusValues.add(lSV);
            }
        }
        
        //Return
        return lineStatusOptions;
    }
    
    public Pagereference cancel() {
        
        if(ApexPages.hasMessages(ApexPages.Severity.ERROR))
            return null;
        
        //return
        if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CONTRACT_ABC_OBJ_API_NAME))
            return new Pagereference('/' + parentObjectWrapper.contractABC.Id);
        
        //Call utility method to update copied records values
        if(parentObjectAPIName.equalsIgnoreCase(RMConstants.CPQ_SUBSCRIPTION_OBJ_API_NAME))
            return new Pagereference('/' + parentObjectWrapper.sBQQSubcription.Id);
        
        return null;
    }
    
    /**
    *  @description    :   Verify that the current user has read access to the record.  If they don't have read access, an error is displayed on the VF page.
    *                                  
    *  @args           :   
    *
    *  @return         :   boolean
    *  
    *  @Revision Log   :   V1.0 - 11/01/2017 - Created - Issue--CR11742--UAT--00007271 - Victor Hanson
    *
    **/
    public boolean hasAccess {
        get {
            if (hasAccess == null) {
                hasAccess = true;
                
                //if the user doesn't have access to the parent record, display an error
                if (parentObjectID != null) {
                    
                    list<UserRecordAccess> recordAccess = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :parentObjectID];
                    
                    if (recordAccess.size() > 0) {
                        
                        if (recordAccess[0].HasReadAccess == false)
                            hasAccess = false;
                    }
                }
                
                //if the user doesn't have access to the related ABC Revenue Line record, display an error
                if (revenuemManagementWrap != null) {
                    ABC_Revenue__c revRecord = revenuemManagementWrap.aBCRevenue;
                    list<UserRecordAccess> recordAccess = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :revRecord.Id];
                    
                    if (recordAccess.size() > 0) {
                        
                        if (recordAccess[0].HasReadAccess == false)
                            hasAccess = false;
                    }
                }
            }
            return hasAccess;
        }
        set;
    }
    
    /**
    *  @description    :   This method is used to create the ABC revenue records under the Program SUB for related contract.            
    *  @args           :   
    *
    *  @return         :   
    *  
    *  @Revision Log   :   Created by Abhinav sharma - FFDC Relaunch - CR-20180918-12607 - 12/04/2018.
    *
    **/
    public void  checkABCRevenueCreatedOnProgramSubscription() {
		
        //Check if contract's Program subsciption are previosuly associated with ABC revenue. 
        if(String.isNotBlank(parentObjectID)) {
    		
            //Query on the program subscription. where Contract is parentObjectID. 
            for(SBQQ__Subscription__c programSubscriptions : [Select Id, SBQQ__Contract__c, (Select Id From ABC_Revenue__r) From SBQQ__Subscription__c 
                                                              Where SBQQ__Contract__c =: parentObjectID AND RecordType.DeveloperName = 'Program']) {
             	
                //Check for the size of list - If we get atleast one Program sub where ABC revenue created then update the flag.to show a message on page. 
                if(programSubscriptions.ABC_Revenue__r != null && programSubscriptions.ABC_Revenue__r.size() > 0) {
                	
                    isABCRevenueProcessedEarlierForContract = true;
                    break;
                }                                                     
            }
        }
    }
    
    /**
     *  @description    :   This method is used to create the ABC revenue records under the Program SUB for related contract.            
     *
     *  @args           :   
     *
     *  @return         :   
     *  
     *  @Revision Log   :   Created by Abhinav sharma - FFDC Relaunch - CR-20180918-12607 - 12/04/2018.
     *
    **/
    public void generateABCRevenueForStandardContract() {
		
		        
    }
}