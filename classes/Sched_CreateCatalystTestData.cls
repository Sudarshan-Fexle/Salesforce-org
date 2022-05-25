/**
 *  Description     :  Scheduler class (Main class) of PrintMIS Catalyst Utility
 *
 *  Created By      :  Mahendar Swarnkar
 *
 *  Created Date    :  09/22/2021
 *
 *  Revision Logs   :   V_1.0 - Created By - Mahendar Swarnkar - CR-20210909-15418
 *
 **/
global without sharing class Sched_CreateCatalystTestData implements Schedulable {
    
    public Map<Integer, Id> mapCounterWithRecordId {get; set;} 
    public String uniquePrintData {get; set;}
    public Boolean isException = false;
    public Boolean executeCreativePackageBatch = false;
    public String errorMessage ='';
    
    public Integer currentIndex {
        set; 
        get{
            if(currentIndex == null) {
        		currentIndex = 0;
            }
            return currentIndex;
        } 
    }
    
    public Map<String, ID> mapUniqueKeyWithRecordId {
		set; 
        get{ 
            if(mapUniqueKeyWithRecordId == null){
                mapUniqueKeyWithRecordId = new Map<String, ID>();
            }
            return mapUniqueKeyWithRecordId;
        } 
    }
    
    public Set<Id> quoteLineRecordIds{
    	set; 
        get{ 
            if(quoteLineRecordIds == null){
                quoteLineRecordIds = new Set<Id>();
            }
            return quoteLineRecordIds;
        } 
    }
    
    public List<sObject> approvedByPartnerRecords{
    	set; 
        get{ 
            if(approvedByPartnerRecords == null){
                approvedByPartnerRecords  =  new List<sObject>();
            }
            return approvedByPartnerRecords;
        } 
    }
    
    // Constructor called from UI Console with instance of Wrapper 
    public Sched_CreateCatalystTestData(CatalystPrintDataUtilityWrapper printWrapper) {
        
        if(mapCounterWithRecordId == null) {
            currentIndex = 1;
             
            // map which contains metadata record Id with index number  
            mapCounterWithRecordId = new Map<Integer, Id>();
            
            Integer counter = 1;
            // Query all the metadata record and add record with respect to index in map.

            for(Create_Dev_Sandbox_Record__mdt createDevData : [SELECT ID, MasterLabel, DeveloperName, Child_Record__c, Object_API_Name__c, Parent_Field_API_Name__c, 
                                                                Record_Level__c, Order__c, Parent_Object_API_Name__c, Records__c
                                                                FROM Create_Dev_Sandbox_Record__mdt
                                                                WHERE Active__c =: true AND Process_Belongs_To__c = :Constants.PRINT_PROCESS_OE_CAT
                                                                ORDER By Record_Level__c ASC, Order__c ASC])
            {
                mapCounterWithRecordId.put(counter, createDevData.Id); 
                
                counter++;
                
                if(createDevData.DeveloperName == 'Proposal_Line_Grand_Child_Catalyst' || createDevData.DeveloperName == 'Proposal_Line_Child_Catalyst')
                    quoteLineRecordIds.add(createDevData.Id);
            }
            
            // Convert unqiue wrapper data in Json String so it can pass to future method 
            if(printWrapper!=null)
                uniquePrintData = JSON.serialize(printWrapper);
        }
    }
    
    // Constructor called scheduleAfterMinutes method with Json string of unique data 
    public Sched_CreateCatalystTestData(String uniquePrintData) {
        this.uniquePrintData = uniquePrintData;
    }
    
    global void execute(SchedulableContext ctx) {
        
        try{
            
            // Update job tickets record status to Approved by partner 
            if (approvedByPartnerRecords.size() > 0)
            {
                Set<ID> setJobTicketIdsToCreateCreativePackageBoxFolder = new Set<Id>();
                
                //integer i = 1;
                for(sObject jobTicket : approvedByPartnerRecords)
                {
                    setJobTicketIdsToCreateCreativePackageBoxFolder.add(jobTicket.Id);
                    jobTicket.put('Status__c', Constants.JT_FIELD_STATUS_APPROVED_BY_PARTNER);
                    
                }
                // update job ticket status to approved by partner
                update approvedByPartnerRecords;
                
                if(executeCreativePackageBatch && setJobTicketIdsToCreateCreativePackageBoxFolder.size() > 0){
                	Batch_CreateBoxFolderForCreativePackage batchCreativePackage = new Batch_CreateBoxFolderForCreativePackage(setJobTicketIdsToCreateCreativePackageBoxFolder);
            		Database.executeBatch(batchCreativePackage, Integer.valueOf(Label.ProductionTracking_BoxBatchSize));
                    executeCreativePackageBatch = false;
                }
                currentIndex ++; // check for next meta data record 
                
                // If next index record found then schedule it for next 5  min  
                if(mapCounterWithRecordId.containsKey(currentIndex) && mapCounterWithRecordId.get(currentIndex) != null )
                    scheduleAfterMinutes(0, 5, mapCounterWithRecordId, currentIndex, mapUniqueKeyWithRecordId, quoteLineRecordIds, new List<sObject>(), uniquePrintData, executeCreativePackageBatch);
            }  
            // call future method createUtilityRecords if Job ticket records not created yet 
            else if(currentIndex > 0 && mapCounterWithRecordId != null && mapCounterWithRecordId.size() > 0 && mapCounterWithRecordId.containsKey(currentIndex) && mapCounterWithRecordId.get(currentIndex) != null) {
                createUtilityRecords(mapCounterWithRecordId, currentIndex, mapUniqueKeyWithRecordId, quoteLineRecordIds, uniquePrintData);
            }
            
        } catch (Exception ex){
            isException = true;
            errorMessage = ex.getMessage()+' '+ex.getStackTraceString();
            
            CatalystPrintDataUtilityWrapper printWrapper =  (CatalystPrintDataUtilityWrapper)JSON.deserialize(uniquePrintData, CatalystPrintDataUtilityWrapper.class);
			
            //Send Exception Email To Current Logged in User 
            sendFinalDetailedEmail (null , null, null,/* null, null, null,*/ null, printWrapper.JT_Mail_Vendor, isException, errorMessage);
            
        }
        
    }
    
     /**
    *  @description    :  This future method is used to create/update utility record, schedule the class for next run.                         
    * 
    *  @args           :   Map<Integer, Id> mapCounterWithRecordId, Integer currentIndex ,Map<String, ID> mapUniqueKeyWithRecordId, Set<Id> quoteLineRecordIds, String uniquePrintData
    * 
    *  @return         :   void 
    * 
    *  @revision Log   :   V1.0 - Created By - Mahendar Swarnkar  - 09/22/2021 - CR-20210909-15418
    * 
    * */
    
    @future(callout = true) // future method to create utility records 
    public static void createUtilityRecords(Map<Integer, Id> mapCounterWithRecordId, Integer currentIndex ,Map<String, ID> mapUniqueKeyWithRecordId, Set<Id> quoteLineRecordIds, String uniquePrintData)
    {
        //set to hold parent field api names 
        Set<String> setRelationshipFieldAPInames = new Set<String>();
        //set to hold Obj uniue field api names 
        Set<String> setObjUniqueFieldAPInames = new Set<String>();
        
        //Exception related fields 
        Boolean isException = false;
        String errorMessage ='';
        
        Boolean isExecuteCreativePackagebatch = false;
        Boolean isSendEmail = false;
        
        // This Id is used as ownerId in some of the records 
        Id SALESFORCE_ADMINISTRATOR_ID = System.Label.Saleforce_Administrator_ID_15_Digit;
        
        //boolean check for bypass trigger only in insert case 
        Boolean doBypass = true ;
               
        CatalystPrintDataUtilityWrapper printUniqueData ;
        
        //boolean check for time long scheduling
        Boolean isSalesFinanceProcessStarted = false;
        
        // map to hold  unique key and record 
        Map<String, sObject> maprecordUniqueKeyWithRecords;
        
        // Set to hold API names which used in case of multiple  record insertion without metadata 
        Set<String> setToAvoidObjApiNames = new Set<String>{Constants.ACCOUNT_API_NAME, Constants.OPPORTUNITY_API_NAME};
        
		Set<String> setObjectToBypassDependsOnJobTicket = new Set<String>{Constants.JOB_TICKET_MTM_API_NAME, Constants.CREATIVE_PACKAGE_OBJECT_API_NAME,  Constants.INVENTORY_API_NAME, Constants.INVENTORY_TRANSACTION_API_NAME};
        
        try    
         { 
            if(currentIndex > 0  && mapCounterWithRecordId != null && mapCounterWithRecordId.size() > 0 && mapCounterWithRecordId.containsKey(currentIndex) && mapCounterWithRecordId.get(currentIndex) != null && uniquePrintData!= null && String.isNotBlank(uniquePrintData)){
                
                //Query individual meta  data record by record Id 
                List<Create_Dev_Sandbox_Record__mdt> listmetadataRecord = [SELECT ID, Object_Unique_Fields__c, DeveloperName, Child_Record__c,IS_Update__c, Object_API_Name__c, Parent_Field_API_Name__c, 
                                                                 Record_Level__c, Order__c, Parent_Object_API_Name__c, Records__c
                                                                 FROM Create_Dev_Sandbox_Record__mdt
                                                                 WHERE Active__c =: true AND Id = :mapCounterWithRecordId.get(currentIndex) AND Process_Belongs_To__c = :Constants.PRINT_PROCESS_OE_CAT];
                
                
                Create_Dev_Sandbox_Record__mdt metadataRecord;
                
                if(listmetadataRecord != null && listmetadataRecord.size() > 0 ){
                    metadataRecord = listmetadataRecord[0];
                }
                if(metadataRecord != null)
                {
                    
                    // Get object API name & Developer name from metadata record 
                    String objectAPIName = metadataRecord.Object_API_Name__c ;   
                    String developerName = metadataRecord.DeveloperName;
                    
                    // Get JSON record data in form of Unique key and SObject Value Map
                    maprecordUniqueKeyWithRecords = (Map<String, sObject>) CreateCatalystTestDataRecordUtil.parseJSONstring(metadataRecord.Records__c, objectAPIName);
                    
                    
                    //This condition used to Split comma separated parent field API Names to set of strings
                    if(metadataRecord.Parent_Field_API_Name__c != null && String.isNotBlank(metadataRecord.Parent_Field_API_Name__c))
                    {
                        List<String> listOfRelationShipFields = metadataRecord.Parent_Field_API_Name__c.replaceAll('\\s','').split(',');
                        setRelationshipFieldAPInames.addAll(listOfRelationShipFields);
                    }
                    
                    //This condition is used to split comma seperated unqiue fields and populat them with the values that user have provided 
                    if(metadataRecord.Object_Unique_Fields__c != null && String.isNotBlank(metadataRecord.Object_Unique_Fields__c)){
                        
                        //Convert Unique data json to Wrapper Type 
                        printUniqueData =  (CatalystPrintDataUtilityWrapper)JSON.deserialize(uniquePrintData, CatalystPrintDataUtilityWrapper.class);
                        
                        List<String> listOfObjUniqueFields = metadataRecord.Object_Unique_Fields__c.replaceAll('\\s','').split(',');
                        setObjUniqueFieldAPInames.addAll(listOfObjUniqueFields);
                        
                        // populate unique fields on record 
                        if(setObjUniqueFieldAPInames.size()>0)
                        {
                            for(String uniquekey : maprecordUniqueKeyWithRecords.keyset()){
                                sObject dataRecord = maprecordUniqueKeyWithRecords.get(uniquekey);
                                
                                for(String uniqueField : setObjUniqueFieldAPInames)
                                {
                                    String randomString = generateRandomString(4);
                                    
                                    //---------Populate Account unique fields---------//
                                    if(objectAPIName == Constants.ACCOUNT_API_NAME){
                                        
                                        if(uniqueField == Constants.ACCOUNT_FIELD_NAME)
                                            dataRecord.put(uniqueField, 'Test Catalyst Utility '+randomString); 
                                        
                                        if(uniqueField == Constants.ACCOUNT_FIELD_ACC_FORMAL_NAME)
                                            dataRecord.put(uniqueField, 'Catalyst Utility '+randomString);
                                        
                                        if(uniqueField == Constants.ACCOUNT_FIELD_SCHOOL_CODE)
                                            dataRecord.put(uniqueField, generateRandomString(4));
                                        
                                        if(uniqueField == Constants.ACCOUNT_FIELD_CEEB_CODE)
                                            dataRecord.put(uniqueField, generateRandomString(4));
                                        
                                        dataRecord.put(Constants.OWNER_ID_FIELD, SALESFORCE_ADMINISTRATOR_ID);// Populate OwnerId 
                                    }
                                    //---------Populate Contact unique fields---------//
                                    else if (objectAPIName == Constants.CONTACT_API_NAME){  
                                        
                                        if(uniqueField == Constants.CONTACT_FIELD_FIRST_NAME)
                                            dataRecord.put(uniqueField, randomString);
                                        
                                        if(uniqueField == Constants.CONTACT_FIELD_EMAIL)
                                            dataRecord.put(uniqueField, randomString+'catalyst@Test.com');
                                        
                                       dataRecord.put(Constants.OWNER_ID_FIELD, SALESFORCE_ADMINISTRATOR_ID); // Populate OwnerId 
                                    }
                                    //---------Populate Opportunity unique fields---------//
                                    else if (objectAPIName == Constants.OPPORTUNITY_API_NAME){
                                        
                                        if(uniqueField == Constants.OPPORTUNITY_FIELD_CLOSED_DATE)
                                            dataRecord.put(uniqueField, Date.today().addMonths(1));
                                        
                                        dataRecord.put(Constants.OWNER_ID_FIELD, SALESFORCE_ADMINISTRATOR_ID);// Populate OwnerId 
                                    }
                                    //---------Populate Job Ticket unique fields---------// 
                                    else if (objectAPIName == Constants.JOB_TICKET_API_NAME){
                                        
                                        if(uniqueField == Constants.JT_FIELD_DROP_TYPE)
                                            dataRecord.put(uniqueField, printUniqueData.JT_Drop_Type != null ? printUniqueData.JT_Drop_Type : 'On Demand');
                                        
                                        if(uniqueField == Constants.JT_FIELD_VENDOR_TYPE){
											dataRecord.put(uniqueField, printUniqueData.JT_Vendor_Type != null ? printUniqueData.JT_Vendor_Type : 'Digital'); 
                                        	
                                            if(printUniqueData.JT_Vendor_Type != null && printUniqueData.JT_Vendor_Type == 'Offset'){
                                                dataRecord.put('Vendor_Type_Reason__c', 'Test Offset Reason');
                                            }
                                        }
                                            
                                        if(uniqueField == Constants.JT_FIELD_MAIL_VENDOR)
                                            dataRecord.put(uniqueField, printUniqueData.JT_Mail_Vendor != null ? printUniqueData.JT_Mail_Vendor : '0010400000xAA1nAAG');
                                        if(uniqueField == Constants.JT_FIELD_NO_OF_DROPS) // # of Drops   
                                            dataRecord.put(uniqueField, printUniqueData.JT_No_Of_Drop != null ? Integer.valueOf(printUniqueData.JT_No_Of_Drop) : 1);
                                        if(uniqueField == Constants.JT_FIELD_PROJECT_ID)
                                            dataRecord.put(uniqueField, printUniqueData.JT_Project_ID != null ? printUniqueData.JT_Project_ID : '29694');
                                        
                                        if(uniqueField == Constants.JT_FIELD_MAIL_DATE)
                                            dataRecord.put(uniqueField, Date.today().addMonths(1));
                                        
                                        if(uniqueField == Constants.JT_FIELD_ART_DIRECTOR)
                                            dataRecord.put(uniqueField, UserInfo.getUserId());
                                        if(uniqueField == Constants.JT_FIELD_PRODUCTION_MANAGER)
                                            dataRecord.put(uniqueField, UserInfo.getUserId());
                                        if(uniqueField == Constants.JT_FIELD_PROJECT_MANAGER)
                                            dataRecord.put(uniqueField, UserInfo.getUserId());
                                        
                                        dataRecord.put(Constants.OWNER_ID_FIELD, SALESFORCE_ADMINISTRATOR_ID);// Populate OwnerId 
                                    }
                                    
                                    //---------Populate Production tracking unique fields---------// 
                                    else if (objectAPIName == Constants.PRODUCTION_TRACKING_API_NAME){
                                        if(uniqueField == Constants.PT_FIELD_MAIL_SHOPE_VENDOR) // Assigned job ticket mail vendor 
                                            dataRecord.put(uniqueField, printUniqueData.JT_Mail_Vendor != null ? printUniqueData.JT_Mail_Vendor : '0010400000xAA1nAAG'); 
                                        if(uniqueField == Constants.PT_FIELD_DROP_NO)
                                            dataRecord.put(uniqueField, printUniqueData.JT_No_Of_Drop != null ? Integer.valueOf(printUniqueData.JT_No_Of_Drop) : 1);
                                        if(uniqueField ==  Constants.PT_FIELD_PLANNED_MAIL_DATE)
                                            dataRecord.put(uniqueField, Date.today().addMonths(1));
                                        
                                       dataRecord.put(Constants.OWNER_ID_FIELD, SALESFORCE_ADMINISTRATOR_ID);// Populate OwnerId 
                                    }
                                    
                                    //---------Populate Production tracking unique fields---------// 
                                    else if (objectAPIName ==  Constants.PROPOSAL_LINE_API_NAME) {
                                        
                                        if(uniquekey.containsIgnoreCase('Proposal_Line_Parent')){
                                         	
                                            if(uniqueField == Constants.PROPOSAL_LINE_FIELD_PRODUCT && printUniqueData.Parent_QL_Product != null){
                                                dataRecord.put(uniqueField, printUniqueData.Parent_QL_Product);
                                            }
                                            if(uniqueField == Constants.PROPOSAL_LINE_FIELD_TOP_PARETN_PRODUCT && printUniqueData.Parent_QL_TopParentProduct != null){
                                                dataRecord.put(uniqueField, printUniqueData.Parent_QL_TopParentProduct);
                                            }
                                            if(uniqueField == Constants.PROPOSAL_LINE_FIELD_PRICEBOOK_ENTRY && printUniqueData.Parent_QL_PricebookEntry != null){
                                                dataRecord.put(uniqueField, printUniqueData.Parent_QL_PricebookEntry);
                                            }
                                            
                                        }
                                       
                                        if(uniquekey.containsIgnoreCase('Proposal_Line_Child')){
                                            
                                            if(uniqueField == Constants.PROPOSAL_LINE_FIELD_PRODUCT && printUniqueData.Child_QL_Product != null){
                                                dataRecord.put(uniqueField, printUniqueData.Child_QL_Product);
                                            }
                                            if(uniqueField == Constants.PROPOSAL_LINE_FIELD_TOP_PARETN_PRODUCT && printUniqueData.Child_QL_TopParentProduct != null){
                                                dataRecord.put(uniqueField, printUniqueData.Child_QL_TopParentProduct);
                                            }
                                            if(uniqueField == Constants.PROPOSAL_LINE_FIELD_PRICEBOOK_ENTRY && printUniqueData.Child_QL_PricebookEntry != null){
                                                dataRecord.put(uniqueField, printUniqueData.Child_QL_PricebookEntry);
                                            }
                                            if(uniqueField == Constants.PROPOSAL_LINE_FIELD_PRODUCT_OPTION && printUniqueData.Child_QL_ProductOption != null){
                                                dataRecord.put(uniqueField, printUniqueData.Child_QL_ProductOption);
                                            }
                                            if(uniqueField == Constants.PROPOSAL_LINE_FIELD_DYNAMIC_OPTION_ID && printUniqueData.Child_QL_DynamicOptionId != null){
                                                dataRecord.put(uniqueField, printUniqueData.Child_QL_DynamicOptionId);
                                            }
                                            	
                                        }
                                        
                                        if(uniquekey.containsIgnoreCase('Proposal_Line_Grand_Child')){
                                            if(uniqueField == Constants.PROPOSAL_LINE_FIELD_PRODUCT && printUniqueData.Grand_QL_Product != null){
                                                dataRecord.put(uniqueField, printUniqueData.Grand_QL_Product);
                                            }
                                            if(uniqueField == Constants.PROPOSAL_LINE_FIELD_TOP_PARETN_PRODUCT && printUniqueData.Grand_QL_TopParentProduct != null){
                                                dataRecord.put(uniqueField, printUniqueData.Grand_QL_TopParentProduct);
                                            }
                                            if(uniqueField == Constants.PROPOSAL_LINE_FIELD_PRICEBOOK_ENTRY && printUniqueData.Grand_QL_PricebookEntry != null){
                                                dataRecord.put(uniqueField, printUniqueData.Grand_QL_PricebookEntry);
                                            }
                                            if(uniqueField == Constants.PROPOSAL_LINE_FIELD_PRODUCT_OPTION && printUniqueData.Grand_QL_ProductOption != null){
                                                dataRecord.put(uniqueField, printUniqueData.Grand_QL_ProductOption);
                                            }
                                            if(uniqueField == Constants.PROPOSAL_LINE_FIELD_DYNAMIC_OPTION_ID && printUniqueData.Grand_QL_DynamicOptionId != null){
                                                dataRecord.put(uniqueField, printUniqueData.Grand_QL_DynamicOptionId);
                                            }
                                            if(uniqueField == Constants.PROPOSAL_LINE_FIELD_DIMENSION && printUniqueData.Grand_QL_Dimension != null){
                                                dataRecord.put(uniqueField, printUniqueData.Grand_QL_Dimension);
                                            }
                                        }
                                    }
                                    
                                    else if (objectAPIName == 'SBQQ__Quote__c'){
                                        dataRecord.put(Constants.OWNER_ID_FIELD, SALESFORCE_ADMINISTRATOR_ID);// Populate OwnerId 
                                    }
                                }
                            }
                        }
                    }
                    
                    // This condition will execute when contact and opportunity records will be inserted  
                    if(metadataRecord.Child_Record__c && !metadataRecord.IS_Update__c && !setObjectToBypassDependsOnJobTicket.contains(objectAPIName)){
                        
                        for(String uniquekey : maprecordUniqueKeyWithRecords.keyset()){
                            
                            // get the record from unqiue key
                            sObject dataRecord = maprecordUniqueKeyWithRecords.get(uniquekey);
                            
                            for(String relationshipField : setRelationshipFieldAPInames){
                                String relationshipUniqueKey = (String) dataRecord.get(relationshipField);
                                
                                // check if parent record unique key is exist in map if exist add it to relationship fields else add null to it 
                                if(mapUniqueKeyWithRecordId != null && mapUniqueKeyWithRecordId.size() > 0 && mapUniqueKeyWithRecordId.containsKey(relationshipUniqueKey) && mapUniqueKeyWithRecordId.get(relationshipUniqueKey) != null){
                                    dataRecord.put(relationshipField, mapUniqueKeyWithRecordId.get(relationshipUniqueKey));
                                } else{
                                    dataRecord.put(relationshipField, null);
                                }
                             }
                        }
                    }
                    // This condition will be execute when opportunity record is updated (When opportunity will be contracted)
                    else if (metadataRecord.IS_Update__c && setToAvoidObjApiNames.contains(objectAPIName)) //to update exisitng records 
                    {
                        for(String recordIdToUpdate : maprecordUniqueKeyWithRecords.keySet())
                        {
                            // get the record from unqiue key
                            sObject dataRecord = maprecordUniqueKeyWithRecords.get(recordIdToUpdate);
                            if(mapUniqueKeyWithRecordId != null && mapUniqueKeyWithRecordId.size() > 0 && mapUniqueKeyWithRecordId.containsKey(recordIdToUpdate) && mapUniqueKeyWithRecordId.get(recordIdToUpdate) != null){
                                dataRecord.put('Id', mapUniqueKeyWithRecordId.get(recordIdToUpdate));
                            }
                        }
                        
                        if(objectAPIName == Constants.OPPORTUNITY_API_NAME)
                            isSalesFinanceProcessStarted = true; 
                        
                        //avoid bypassing the trigger in update case
                        doBypass = false;
                    }
                    
                    //This condition will be execute when Job ticket record will be updated, Job Ticket MTM, production tracking, Inventory, Inventory Transaction records will be created 
                    else if(!setToAvoidObjApiNames.contains(objectAPIName))
                    {    
                        // Get Oppportunity Record Ids from mapUniqueKeyWithRecordId
                        Set<Id> opportunityIds =  new Set<Id>();
                        
                        for(String oppUniqueKey : mapUniqueKeyWithRecordId.keySet())
                        {
                            if(oppUniqueKey.contains('Opportunity_'))
                                opportunityIds.add(mapUniqueKeyWithRecordId.get(oppUniqueKey));
                        }
                        
                        //List to insert/update records 
                        List<sObject> sObjectRecords = new List<sObject>();
                       
                        // Maps and set to generate URLs in email------------------//
                        Map<Id, Project__c> mapIdWithProject = new Map<Id, Project__c>();
                        Map<Id, List<Job_Ticket__c>> mapProjIdWithJtList = new Map<Id, List<Job_Ticket__c>>();
                        Map<Id, List<Production_Tracking__c>> mapJobTicketIdWithPTList = new  Map<Id, List<Production_Tracking__c>>();
                        Map<Id, Creative_Package__c> mapJobTicketIdWithCreativePackage = new Map<Id, Creative_Package__c>();
                        //Set to hold production tracking ids for email
                        Set<Id> productionTrackingIds = new Set<Id>();
                         // Maps and set to generate URLs in email------------------//
                        
                        // sobject Record whose status needs to update Approved by partner Job ticket records 
                        List<sObject> approvedByPartnerRecords  = new List<sObject>();

                        // Query contracts on Opportunity Id
                        Set<Id> contractIds = (new Map<Id,SObject>([SELECT Id FROM Contract WHERE SBQQ__Opportunity__c IN :opportunityIds])).keySet();
                        
                        //Different component code for Job ticket MTM 
                        String jTMTMComponentCode = generateRandomString(4);
                        
                        if(contractIds != null && contractIds.size() > 0)
                        {
                            Integer i = 0;
                            // Query projects record based on contract ids
                            for(Project__c project : [SELECT Id, Name, (SELECT Id, Name, Status__c, CEEB_Code__c, Project_ID__c FROM Job_Tickets__r) FROM Project__c WHERE Contract2__c IN :contractIds])
                            { 
                                for(Job_Ticket__c jobTicket : project.Job_Tickets__r)
                                {
                                    i++;
                                    
                                    //Commented - 10/20/2021 - comment out the Inventory and Inventory Transaction records creation as these will create automatically via PT status update.
                                    //Fill Map For Email--------------------------------------------------------------------------------------------------------//
                                    //if(objectAPIName == Constants.INVENTORY_TRANSACTION_API_NAME){
                                        
                                        // fill the map of project id with project records 
                                        if(!mapIdWithProject.containsKey(project.Id))
                                            mapIdWithProject.put(project.Id, project);
                                        
                                       // fill the map of project id with List of job tickets records 
                                        if(!mapProjIdWithJtList.containsKey(project.Id))
                                            mapProjIdWithJtList.put(project.Id, new List<Job_Ticket__c>());
                                        
                                        mapProjIdWithJtList.get(project.Id).add(jobTicket);
                                    //}
                                    //Fill Map For Email--------------------------------------------------------------------------------------------------------//
                                    
                                    //fill the mapUniqueKeyWithRecordId with unqiue key and jobticket Id  
                                    String JobticketUniqueKey = 'Job Ticket '+i;
                                    if(!mapUniqueKeyWithRecordId.containsKey(JobticketUniqueKey))
                                        mapUniqueKeyWithRecordId.put(JobticketUniqueKey, jobTicket.Id);
                                    
                                    approvedByPartnerRecords.add(jobTicket);
                                    
                                    if(objectAPIName == Constants.JOB_TICKET_API_NAME || objectAPIName == Constants.JOB_TICKET_MTM_API_NAME || objectAPIName == Constants.CREATIVE_PACKAGE_OBJECT_API_NAME){
                                        
                                        for(String uniquekey : maprecordUniqueKeyWithRecords.keyset())
                                        {
                                            // get the record from unqiue key
                                            sObject dataRecord = maprecordUniqueKeyWithRecords.get(uniquekey);
                                            
                                            // update multiple job ticket default fields 
                                            if(objectAPIName == Constants.JOB_TICKET_API_NAME){
                                                
                                                dataRecord.put('Id', jobTicket.Id);
                                                
                                                //clone the record so that instance will not overlapper - to prevent error "before insert or upsert list must not have two identically equal elements"
                                                sObjectRecords.add(dataRecord.clone(true, true, false, false)); 
                                                doBypass = false;
                                            } 
                                            
                                            //create multiple job ticket mtm records for each of the job ticket 
                                            else if(objectAPIName == Constants.JOB_TICKET_MTM_API_NAME)
                                            {
                                                for(String relationshipField : setRelationshipFieldAPInames){
                                                    
                                                    //String relationshipUniqueKey = (String) dataRecord.get(relationshipField);
                                                    String relationshipUniqueKey = JobticketUniqueKey;
                                                    
                                                    if(mapUniqueKeyWithRecordId != null && mapUniqueKeyWithRecordId.size() > 0 && mapUniqueKeyWithRecordId.containsKey(relationshipUniqueKey) && mapUniqueKeyWithRecordId.get(relationshipUniqueKey) != null){
                                                        dataRecord.put(relationshipField, mapUniqueKeyWithRecordId.get(relationshipUniqueKey));
                                                        dataRecord.put('Component_Code__c',jTMTMComponentCode);
                                                        dataRecord.put('Job_Ticket__c', jobTicket.Id);
                                                    } else{
                                                        dataRecord.put(relationshipField, null);
                                                    }
                                                   
                                                    //clone the record so that instance will not overlapper - to prevent error "before insert or upsert list must not have two identically equal elements"
                                                    sObjectRecords.add(dataRecord.clone(true, true, false, false)); 
                                                    dataRecord.put(relationshipField, relationshipUniqueKey);
                                                }
                                            }
                                            //create Creative Package record for each of the job ticket 
                                            else if(objectAPIName == Constants.CREATIVE_PACKAGE_OBJECT_API_NAME)
                                            {
                                                for(String relationshipField : setRelationshipFieldAPInames){
                                                    
                                                    //String relationshipUniqueKey = (String) dataRecord.get(relationshipField);
                                                    String relationshipUniqueKey = JobticketUniqueKey;
                                                    
                                                    if(mapUniqueKeyWithRecordId != null && mapUniqueKeyWithRecordId.size() > 0 && mapUniqueKeyWithRecordId.containsKey(relationshipUniqueKey) && mapUniqueKeyWithRecordId.get(relationshipUniqueKey) != null){
                                                        dataRecord.put(relationshipField, mapUniqueKeyWithRecordId.get(relationshipUniqueKey));
                                                        dataRecord.put('Job_Ticket__c', jobTicket.Id);
                                                        dataRecord.put('Art_File_Name__c', jobTicket.Name + jobTicket.Project_ID__c+ 'Artwork_1.zip');
                                                    } else{
                                                        dataRecord.put(relationshipField, null);
                                                    }
                                                   
                                                    //clone the record so that instance will not overlapper - to prevent error "before insert or upsert list must not have two identically equal elements"
                                                    sObjectRecords.add(dataRecord.clone(true, true, false, false)); 
                                                    dataRecord.put(relationshipField, relationshipUniqueKey);
                                                    doBypass = true;
                                                    isExecuteCreativePackagebatch = true;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            //Commented - 10/20/2021 - comment out the Inventory and Inventory Transaction records creation as these will create automatically via PT status update.
                            // Condition when we updating default fields of production tracking 
                            if((objectAPIName == Constants.PRODUCTION_TRACKING_API_NAME /*|| objectAPIName == Constants.INVENTORY_API_NAME || objectAPIName == Constants.INVENTORY_TRANSACTION_API_NAME */) && approvedByPartnerRecords.size()>0)
                            {
                                //Fill Map for Email----------------------------------------------//
                                Integer j =1 ;
                                for(Production_Tracking__c prodTrack : [SELECT Id, Name, Drop__c, RecordType.DeveloperName, Job_Ticket_MtM__c, Job_Ticket_MtM__r.Component_Code__c, Job_Ticket__r.Project__c, Job_Ticket__r.Project__r.Name, Job_Ticket__c, Job_Ticket__r.Name , JT_Project_ID__c, (Select ID from Inventory__r ) FROM Production_Tracking__c WHERE Job_Ticket__c IN :approvedByPartnerRecords])
                                {
                                    if(objectAPIName == Constants.PRODUCTION_TRACKING_API_NAME){
                                    	
                                        for(String uniquekey : maprecordUniqueKeyWithRecords.keyset()) {
                                            
                                            sObject dataRecord = maprecordUniqueKeyWithRecords.get(uniquekey);
                                            dataRecord.put('Id', prodTrack.Id);
                                            
                                            if(prodTrack.RecordType.DeveloperName == 'Print'){
                                                dataRecord.put(Constants.PT_FIELD_PROOF_GENERATION, 'External');
                                            }
                                            else{
                                                dataRecord.put(Constants.PT_FIELD_PROOF_GENERATION, 'Internal');
                                            }
                                            
                                            dataRecord.put(Constants.PT_FIELD_INTERNAL_DROP, printUniqueData.JT_No_Of_Drop != null ? Integer.valueOf(printUniqueData.JT_No_Of_Drop) : prodTrack.Drop__c);
                                            
                                            // add unique formatted art file name on production tracking record 
                                            dataRecord.put('Art_File_Name__c', prodTrack.Job_Ticket__r.Name+'_'+prodTrack.JT_Project_ID__c+'__'+'Artwork_'+dataRecord.get('Drop__c')+'.zip');
                                            
                                            //clone the record so that instance will not overlapper - to prevent error "before insert or upsert list must not have two identically equal elements"
                                            sObjectRecords.add(dataRecord.clone(true, true, false, false)); 
                                            doBypass = false;
                                        }
                                        // Add Production Tracking records id with unique key in map so that it can be use in email body 
                                        mapUniqueKeyWithRecordId.put('Production Tracking '+j, prodTrack.Id);
                                        j++;
                                    }
                                    
                                }
                            }
                        } 
                        // throw custom exception and send email to user 
                        else{
                            String errMessage = 'We are getting the error while contracting Opportunity process, which needs a developer to look into.';
                            throw new CustomException(errMessage);
                        }
                        
                           //Condition will work when we insert/update Job Ticket,  JobTicketMTM, ProductionTracking, Associated Feature, and Send final record detail email to users
						if(sObjectRecords.size()>0) {
                            
                        	Util.BypassAllTriggers = doBypass;
                            upsert sObjectRecords;
                            
                            // When job ticket MTM is inserted create  associated feautre records for each of the job ticket 
                            if(objectAPIName == Constants.JOB_TICKET_MTM_API_NAME) 
                            {
                                ID recordTypeID = DatabaseUtilities.getRecordTypeIdForObject('Associated_Features__c', 'Color');
                                List<Associated_Features__c> createAssociatedFeatureRecords = new List<Associated_Features__c>();
                                
                                Integer i = 1;
                                for(sObject jtMtm : sObjectRecords)
                                {
                                	createAssociatedFeatureRecords.add(new Associated_Features__c(RecordTypeId = recordTypeID, 
                                																Feature_Type__c = 'Color', 
                                                                                                Color_Placement__c = 'Front', 
                                                                                                PMS__c = 'TEXT',
                                                                                                Job_Ticket_MtM__c = jtMtm.Id));
									
                                    // Add job ticket mtm records id with unique key in map so that it can be use in email body 
                                    mapUniqueKeyWithRecordId.put('Job Ticket MTM '+i, jtMtm.Id);
                                    i++;
								}
                                    
                                    // Insert associated feature records 
                                if(createAssociatedFeatureRecords != null && createAssociatedFeatureRecords.size() > 0){
                                
                                	// Insert associated feature records 
                                	Util.BypassAllTriggers = true;
                                    insert createAssociatedFeatureRecords;
                                    Util.BypassAllTriggers= false;
									    
								}
                                    
                                scheduleAfterMinutes(3, 0, mapCounterWithRecordId, currentIndex, mapUniqueKeyWithRecordId, quoteLineRecordIds, approvedByPartnerRecords, uniquePrintData, isExecuteCreativePackagebatch);
                                return;
							}
                                
                            if(objectAPIName == Constants.CREATIVE_PACKAGE_OBJECT_API_NAME)
                            {
                                //Added/Commented - 10/20/2021 - comment out the Inventory and Inventory Transaction records creation as these will create automatically via PT status update.
                                //Fill Map for Email----------------------------------------------//
                                for(Creative_Package__c cp: [Select Id, Name, Job_Ticket__c From Creative_Package__c Where Job_Ticket__c IN :approvedByPartnerRecords ]){
                                    if(!mapJobTicketIdWithCreativePackage.containsKey(cp.Job_Ticket__c)){
                                        mapJobTicketIdWithCreativePackage.put(cp.Job_Ticket__c, cp);
                                    }
                                }
                                
                            	List<Mail_Copy__c> createMailCopyRecords = new List<Mail_Copy__c>();
                            
                            	Integer i = 1;
                                for(sObject CreativePackageRecords : sObjectRecords)
                                {
                                	createMailCopyRecords.add(new Mail_Copy__c(Name = 'MailCopy '+i, Creative_Package__c = CreativePackageRecords.Id));
									i++;
                                }
                                
                                // Insert associated feature records 
                                if(createMailCopyRecords.size() > 0)
                                {
                                	// Insert associated feature records 
                                    Util.BypassAllTriggers = true;
                                        
                                    insert createMailCopyRecords;
                                    
                                    List<Mail_Package__c> createMailPackageRecords = new List<Mail_Package__c>();
                                    for(Mail_Copy__c mc : createMailCopyRecords) {
                                    	createMailPackageRecords.add(new Mail_Package__c(Creative_Package__c = mc.Creative_Package__c, Mail_Copy__c = mc.Id ));
									}
                                        
                                    // Insert associated feature records 
                                    if(createMailPackageRecords.size() > 0) 
                                    {
                                    	insert createMailPackageRecords;
										
                                        List<Mail_Package__c> listCreateMailPackageRecords =  [Select Id, Creative_Package__r.Job_Ticket__c From Mail_Package__c Where Creative_Package__c != null AND Creative_Package__r.Job_Ticket__c != null AND ID IN : createMailPackageRecords];                                   
                                        
                                        List<Package_Component_MtM__c> createPackageComponentMtMRecords = new List<Package_Component_MtM__c>();
                                        
                                        for(Job_Ticket_MtM__c jMtM : [Select ID, Job_Ticket__c From Job_Ticket_MtM__c where Job_Ticket__c != null AND Job_Ticket__c IN : approvedByPartnerRecords]){
                                        
                                        	for(Mail_Package__c mPackage : listCreateMailPackageRecords) {
                                                if(jMtM.Job_Ticket__c == mPackage.Creative_Package__r.Job_Ticket__c ){
                                                    createPackageComponentMtMRecords.add(new Package_Component_MtM__c(Mail_Package__c = mPackage.Id, Job_Ticket_MtM__c = jMtM.Id ));
                                                }
                                            }
                                        }
                                            
                                        // Insert associated feature records 
                                        if(createPackageComponentMtMRecords.size() > 0){
                                        	insert createPackageComponentMtMRecords;
										}    
									}
                                    Util.BypassAllTriggers = false;
								}
                                    
                                isSendEmail = true;
                                scheduleAfterMinutes(3, 0, mapCounterWithRecordId, currentIndex, mapUniqueKeyWithRecordId, quoteLineRecordIds, approvedByPartnerRecords, uniquePrintData, isExecuteCreativePackagebatch);
                                //return; 
							}
                            
                                                   
                            Util.BypassAllTriggers= false;
                            
                            if(printUniqueData == null){
                                printUniqueData =  (CatalystPrintDataUtilityWrapper)JSON.deserialize(uniquePrintData, CatalystPrintDataUtilityWrapper.class);
                            }
                            
                            if(isSendEmail && printUniqueData != null && printUniqueData.emailList != null && printUniqueData.emailList.size() > 0){
                            	sendFinalDetailedEmail (printUniqueData.emailList , mapIdWithProject, mapProjIdWithJtList,/* mapJobTicketIdWithPTList, mapPtIdwithInventries, mapInventtryIdwithInventoryTransactions,*/ mapJobTicketIdWithCreativePackage, printUniqueData.JT_Mail_Vendor, false, null);
                                isSendEmail = false;    
                            }
                            
                            //end of record hierarchies insert/update SO clear out the Map.
							maprecordUniqueKeyWithRecords.clear();
						}
					}
                }
                
                //Condition will work when we insert/update Account,  Contact, Opportunity, Proposal, Proposal Line
                if(maprecordUniqueKeyWithRecords != null && maprecordUniqueKeyWithRecords.size() > 0  && maprecordUniqueKeyWithRecords.values() != null && maprecordUniqueKeyWithRecords.values().size()>0){
                    
                    // only bypass the trigger when inserting new record 
                    Util.BypassAllTriggers= doBypass;
                    upsert maprecordUniqueKeyWithRecords.values();
                    Util.BypassAllTriggers= false;
                    
                    for(String uniquekey : maprecordUniqueKeyWithRecords.keySet()){
                        
                        // condition to check if record is updated 
                        if(mapUniqueKeyWithRecordId != null && !mapUniqueKeyWithRecordId.containsKey(uniquekey)) 
                            mapUniqueKeyWithRecordId.put(uniquekey, maprecordUniqueKeyWithRecords.get(uniquekey).Id);
                    }
                }
                
                currentIndex ++;
                
                // Condition to check if next indexed record is exist or not is exist, it will schedule it accordingly 
                
                if(mapCounterWithRecordId != null && mapCounterWithRecordId.size() > 0 && mapCounterWithRecordId.containsKey(currentIndex) && mapCounterWithRecordId.get(currentIndex) != null ){
                    
                    //When quoteline records are inserted schedule for 5 min later  
                    if(quoteLineRecordIds != null && quoteLineRecordIds.size() > 0 &&  quoteLineRecordIds.contains(mapCounterWithRecordId.get(currentIndex))){
                        scheduleAfterMinutes(0, 6, mapCounterWithRecordId, currentIndex, mapUniqueKeyWithRecordId, quoteLineRecordIds, new List<sObject>(), uniquePrintData, isExecuteCreativePackagebatch);
                    }
                    // When Opportunity is contracted schedule it for 45 min later 
                    else if (isSalesFinanceProcessStarted){
                        scheduleAfterMinutes(0, 35, mapCounterWithRecordId, currentIndex, mapUniqueKeyWithRecordId, quoteLineRecordIds, new List<sObject>(), uniquePrintData, isExecuteCreativePackagebatch);
                    }
                    // When inserting other object records account, contact, Opportunity, Proposal
                    else {
                        scheduleAfterMinutes(3, 0, mapCounterWithRecordId, currentIndex, mapUniqueKeyWithRecordId, quoteLineRecordIds, new List<sObject>(), uniquePrintData, isExecuteCreativePackagebatch);
                    }
                }
			}
        
        }//Try block ends here 
		catch (Exception ex){
            isException = true;
            errorMessage = ex.getMessage()+' '+ex.getStackTraceString();
            
            CatalystPrintDataUtilityWrapper printWrapper =  (CatalystPrintDataUtilityWrapper)JSON.deserialize(uniquePrintData, CatalystPrintDataUtilityWrapper.class);
            //Send Exception Email To Current Logged in User 
            sendFinalDetailedEmail (null , null, null,/* null, null, null,*/ null, printWrapper.JT_Mail_Vendor, isException, errorMessage);
            
        }
    }
    

     /**
    *  @description    :  This method is used to send final email with all the records url                            
    * 
    *  @args           :   List<String> emailsList , Map<String, ID> mapUniqueKeyWithRecordId
    * 
    *  @return         :   void 
    * 
    *  @revision Log   :   V1.0 - Created By - Mahendar Swarnkar - 09/22/2021 - CR-20210909-15418
    * 
    * */
                         
    public static void sendFinalDetailedEmail (List<String> emailsList ,Map<Id, Project__c> mapIdWithProject, Map<Id, List<Job_Ticket__c>> mapProjIdWithJtList,/*Map<Id, List<Production_Tracking__c>> mapJobTicketIdWithPTList, Map<Id, List<Inventory__c>> mapPtIdwithInventries,  Map<Id, List<Inventory_Transaction__c>> mapInventtryIdwithInventoryTransactions,*/ Map<Id, Creative_Package__c> mapJobTicketIdWithCreativePackage, String assignedVendor, Boolean isException, String errorMessage)
    {
        // email list is null then send email to current logged in user only 
        if(emailsList == null || emailsList.size() == 0){
            emailsList = new List<String>();   
        }
        emailsList.add(UserInfo.getUserEmail()); 
        
        if(emailsList.size() > 0)
        {
            String vendorName = '';
            // Get vendor name from Account.
            if(assignedVendor != null && String.isNotBlank(assignedVendor))
            {
                vendorName = [SELECT Name FROM Account WHERE Id = :assignedVendor].Name;  
            }
            String emailBody ='';
            String emailSubject = '';
            
            // If any exceptions occured 
            if(isException && errorMessage != null && errorMessage.length()>0){
                
                //List to hold user ids of public group
                List<String> userIds = new List<String>();
                Group OEBREGroup = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name = 'Catalyst: OE/BRE Test Data Utility User'];
                
                for (GroupMember grupMember : OEBREGroup.groupMembers) {
                    userIds.add(grupMember.userOrGroupId);
                }
                
                if(userIds.size()>0)
                {
                    //Query emails of user in public group  
                    for(User user : [SELECT email FROM user WHERE id IN :userIds]) {
                        if(!emailsList.contains(user.email))
                            emailsList.add(user.email);
                    } 
                }
                
                emailSubject = 'Failed: Catalyst Test Data Records Process Stopped';
                emailBody = 'Hi All,<br><br>/: Catalyst Testing record process for <b>'+vendorName+'</b> has been failed. Please find the Error mentioned below :- <br><br><b>ERROR:</b> '+errorMessage; 
                emailBody = emailBody+'<br><br>Thanks!'; 
            }
            else{
                
                // Get Base url  
                String baseURL = system.URL.getSalesforceBaseUrl().toExternalForm()+'/';
                
                emailSubject = 'Catalyst Records Created Successfully';
                emailBody = 'Hi,<br><br>Catalyst Testing records have been created succesfully for <b>'+vendorName+'</b>. Please refer to the below-mentioned record URL details:- <br><br>';
                
                //String urlsEmail  = '';
                Integer i = 1;
                
                if (mapIdWithProject != null && mapProjIdWithJtList != null /*&& mapJobTicketIdWithPTList != null && mapPtIdwithInventries != null && mapInventtryIdwithInventoryTransactions != null*/){
                    
                    for(Id projectId : mapIdWithProject.keySet())
                    {  // Add Project in email body
                        emailBody = emailBody+'&nbsp<b>('+i+') Project</b>: <a href='+baseURL+projectId+'>'+mapIdWithProject.get(projectId).Name+'</a> <br>';
                        i++;
                        if(mapProjIdWithJtList.get(projectId) != null && mapProjIdWithJtList.get(projectId).size()>0)
                        {  // Add Job Ticket in email body
                            for(Job_Ticket__c jobTicket : mapProjIdWithJtList.get(projectId))
                            {
                                emailBody = emailBody+'&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Job Ticket</b>: <a href='+baseURL+jobTicket.Id+'>'+jobTicket.Name+'</a> <br>';
                                                                
                                // Add creative package link in mail body.
                                if(mapJobTicketIdWithCreativePackage != null && mapJobTicketIdWithCreativePackage.size() > 0 && mapJobTicketIdWithCreativePackage.containsKey(jobTicket.Id) ){
                                    Creative_Package__c creativePackage = mapJobTicketIdWithCreativePackage.get(jobTicket.Id);
                                    emailBody = emailBody+'&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>Creative Package</b>: <a href='+baseURL+creativePackage.Id+'>'+creativePackage.Name+'</a> <br>';
                                }
                            }
                        } 
                        emailBody = emailBody+'<br><br>'; 
                    }
                }
                emailBody = emailBody+'Thanks!' ;
                //emailBody = emailBody+urlsEmail+'Thanks!';
            }
            
            // Send email 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(emailsList);
            mail.setSubject(emailSubject);
            mail.setHtmlBody(emailBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    
    /**
    *  @description    :  This method is used generate random alphanumeric string of given length as an argument                      
    * 
    *  @args           :   Integer len
    * 
    *  @return         :   String 
    * 
    *  @revision Log   :   V1.0 - Created By - Mahendar Swarnkar - 09/22/2021 - CR-20210909-15418
    * 
    * */
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
     /**
    *  @description    :  This method is used to schedule the job after n minutes of time with some exisitng and some unique parameters                                       
    * 
    *  @args           :   Integer seconds, Integer minutes, Map<Integer, Id> mapCounterWithRecordId, Integer currentIndex, 
    *                      Map<String, ID> mapUniqueKeyWithRecordId, Set<Id> quoteLineRecordIds, List<sObject> approvedByPartnerRecords, String uniquePrintData
    * 
    *  @return         :   void 
    * 
    *  @revision Log   :   V1.0 - Created By - Mahendar Swarnkar - 09/22/2021 - CR-20210909-15418
    * 
    * */
    public static Sched_CreateCatalystTestData scheduleAfterMinutes (Integer seconds, Integer minutes, Map<Integer, Id> mapCounterWithRecordId, Integer currentIndex, Map<String, ID> mapUniqueKeyWithRecordId, Set<Id> quoteLineRecordIds, List<sObject> approvedByPartnerRecords, String uniquePrintData, Boolean executeCreativePackageBatch) {
        
        //Clear all the completed Jobs
        List<CronTrigger> jobsToAbort = [select Id from CronTrigger where CronJobDetail.JobType = '7' AND State IN ('COMPLETE', 'DELETED') AND CronJobDetail.Name like 'Sched_CreateCatalystTestData%' Order BY CreatedDate Desc limit 149];
        for (CronTrigger job : jobsToAbort) 
        { 
            System.abortJob(job.Id); 
        }
        
        //Reschedule the Job after n minutes
        DateTime sysTime = dateTime.now();
        
        if(minutes > 0)
            sysTime = sysTime.addMinutes(minutes);
        
        if(seconds > 0)
            sysTime = sysTime.addSeconds(seconds);
        
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        Sched_CreateCatalystTestData sched_Job = new Sched_CreateCatalystTestData(uniquePrintData);
        if(mapCounterWithRecordId != null)
        {
            sched_Job.mapCounterWithRecordId = mapCounterWithRecordId;
            sched_Job.mapUniqueKeyWithRecordId = mapUniqueKeyWithRecordId;
            sched_Job.currentIndex = currentIndex;
            sched_Job.quoteLineRecordIds = quoteLineRecordIds;
            sched_Job.approvedByPartnerRecords = approvedByPartnerRecords;
            sched_Job.executeCreativePackageBatch = executeCreativePackageBatch;
        }
        System.schedule('Sched_CreateCatalystTestData' + String.valueOf(Math.random()), chron_exp, sched_Job);
        return sched_Job;
    }
}