/**
*   Description     :   This is helper class for Trigger_ABCRevenue trigger. Class contains the logic to handle the 
                        functionalities on ABC_Revenue object.
                
*   Created by      :   Saurabh Kumar
*
*   Created Date    :   02/14/2017
*
*   Revision Log    :   V1.0 - Created - CR-20161102-10316
*          	    :   V1.1 - Modified By - 06/19/2017(Issue--CR10991--UAT--00004672) - Rev Management Phase2 - UAT Fix, change the Line Status to Pending, in case if any field which is applicable for Change reason code get change.
*                       V1.2 - Modified By - Colin McGloin - CR-20181212-12784 - Commented out Class as part of the sunsetting of ABC Revenue Line and added populateSiteLiveOnABCRevenue method
*			V1.3 - Modified By - Colin McGloin - CR-20181212-12784 - Added List Price Calculation Method
                        V1.4 - Modified By - Colin McGloin - CR-20191023-13454 - Modified code which checks Bypass_Trigger_Logic__c before running Change Reason code
*			V1.5 - Modified By - Mahendra Swarnakr - 12/26/2019 - CR-20191122-13532
*			V1.6 - Modified By - Dipesh Gupta - 03/05/2020 - CR-20191223-13575 - populateSiteLiveOnABCRevenue
*			V1.7 - Modified By - Neha Sharma - 1/17/2021 - CR-20210113-14803
*			V1.8 - Modified By - Mahendra Swarnkar - 01/05/2021 - CR-20200615-14184 - Validation Rule for Deployments on revenue lines
*                       V1.9 - Modified By - Nikita Kumari - 07/26/2021 - CR-20201217-14749 - Replace Recognized_to_Date_GAAP__c field with the POLI: Recognized Revenue (POLI_Recognized_Revenue__c)   
*			V2.0 - Modified By - Nikita Kumari - 11/10/2021 - CR-20210908-15415 - Added validateTemplateBasedFields method
*			V2.1 - Modified By - Colin McGloin - 04/01/2022 - CR-20220331-16052
*/
public class ABCRevenueTriggerHelper {
    
    //Flag to bypass syncABCRevenueLineAndParent method of ABCRevenueLineTriggerHelper class
    public static boolean isByPass_syncABCRevenueLineAndParent = false;
    
    /**
    *   Description     :   This method is used to update Parent fields with the sum of all children. GAAP_Amount__c, Negotiated_Amount__c these two fields are in scope.
    *
    *   @argu           :   List<Trigger_ABC_Revenue>, Map<Id, Trigger_ABC_Revenue>
    *
    *   @return type    :   Void
    *
    *   Version         :   V1.0 Created - CR-20161102-10316
    **/
    public static void syncABCRevenuesAndTheirChildren(List<ABC_Revenue__c> aBCRevenues, Map<Id, ABC_Revenue__c> mapOldABCRevenues){
        
        //List to hold ABC Revenues for update
        List<ABC_Revenue__c> listABCRevenue = new List<ABC_Revenue__c>();
        
        //Processing on new records
        for(ABC_Revenue__c abcRevenue : aBCRevenues){
            
            //Checking for update case
            if(mapOldABCRevenues != null 
               &&(abcRevenue.Recognition_Start_Date__c != mapOldABCRevenues.get(abcRevenue.Id).Recognition_Start_Date__c
                  || abcRevenue.Recognition_End_Date__c != mapOldABCRevenues.get(abcRevenue.Id).Recognition_End_Date__c
                  || abcRevenue.Negotiated_Amount__c != mapOldABCRevenues.get(abcRevenue.Id).Negotiated_Amount__c
                  || abcRevenue.Expected_Amount_to_Recognize__c != mapOldABCRevenues.get(abcRevenue.Id).Expected_Amount_to_Recognize__c
                  || abcRevenue.GAAP_Amount__c != mapOldABCRevenues.get(abcRevenue.Id).GAAP_Amount__c
                  || abcRevenue.Secured_Amount__c != mapOldABCRevenues.get(abcRevenue.Id).Secured_Amount__c
                  //Added new scenario
                  ||
                  (abcRevenue.Rev_Rec_Complete__c == true &&
                   abcRevenue.Actual_Recognized_to_Date__c != abcRevenue.GAAP_Amount__c)
                  ||
                  abcRevenue.Line_Status__c == System.Label.LINE_STATUS_VOID
                 )
              ){
                  
                  abcRevenue.Rev_Rec_Complete__c = false;
              }
        }
        
        //Set the bypass
        ABCRevenueTriggerHelper.isByPass_syncABCRevenueLineAndParent = true;
        
    }
    
    /**
    *   Description     :   Require user to select a reason for change when modifying an ABC revenue detail line (status PENDING) 
    *                       and include in history tracking. The expected outcome is to record a reason as well as who changed in 
    *                       history each time a line is changed.
    *
    *   @args           :   List<ABC_Revenue__c>, Map<Id, ABC_Revenue__c>
    *
    *   @return type    :   Void
    *
    *   @Revision Log   :   V1.0 Created - CR-20170508-10905
    *                       V1.1 - Modified by - Colin McGloin - 10/28/2019 - CR-20191023-13454 - Modified check for Bypass_Trigger_Logic__c field before evaluating Change Reason Code
    **/
    public static void validateForChangeReasonCode(List<ABC_Revenue__c> aBCRevenueLines, Map<Id, ABC_Revenue__c> mapOldABCRevenueLines) {
        
        //List of custom metadata records which is holding fields related information
        List<Fields_Changes_Configuration_Manager__mdt> listOfFieldsDetailsNeedToBeValidated = new List<Fields_Changes_Configuration_Manager__mdt>([SELECT ID, Active__c, Field_API_Name__c, 
                                                                                                                                                    Object_API_Name__c, Field_API_Name_Old_Value__c,
                                                                                                                                                    Field_API_Name_New_Value__c,
                                                                                                                                                    Not_Validate_For_Field_Change__c,
                                                                                                                                                    Consider_For_Line_Status_Change__c
                                                                                                                                                    FROM Fields_Changes_Configuration_Manager__mdt
                                                                                                                                                    WHERE Object_API_Name__c = 'ABC_Revenue__c' 
                                                                                                                                                    AND Active__c = true
                                                                                                                                                    AND Field_API_Name__c != null
                                                                                                                                                    AND Field_API_Name__c != '']);
         
        //Checking list for it's size
        if(listOfFieldsDetailsNeedToBeValidated.size() > 0) {
            
            //Map to hold the ABC Revenue record ID as key and it is eligible for change reason code error boolean as value
            Map<Id, Boolean> mapOfABCRevenueWithChangeReasonCodeErrorCheck = new Map<Id, Boolean>();
            Map<Id, Boolean> mapOfABCRevenueEligibleForChangeReasonRecordCreate = new Map<Id, Boolean>();
            Map<Id, ABC_Revenue__c> mapOfABCRevenueEligibleForLineStatusUpdates = new Map<Id, ABC_Revenue__c>();
            
            //Loop through ABC revenue records
            for(ABC_Revenue__c aBCRevenue : aBCRevenueLines) {
                
                //Temp. Boolean flag
                Boolean byPassChangeReasonCodeError = false;
                
                //Subhash Garhwal - 10/24/2017 - Issue--CR11185--QA--00007038
                //Check for Site live date
                if(aBCRevenue.Site_Live_Date__c != null && mapOldABCRevenueLines.get(aBCRevenue.Id).Site_Live_Date__c == null){
                    abcRevenue.Change_Reason_Code__c = 'Site Live Date Achieved';
                    byPassChangeReasonCodeError = true;
                }
                
                else if(aBCRevenue.Site_Live_Date__c != mapOldABCRevenueLines.get(aBCRevenue.Id).Site_Live_Date__c && mapOldABCRevenueLines.get(aBCRevenue.Id).Site_Live_Date__c != null){
                    abcRevenue.Change_Reason_Code__c = 'Site Live Date Changed';
                    byPassChangeReasonCodeError = true;
                }
                
                //Checking if line change reason code validation need to bypass in case recursion happens due to WF rule based update
                //Modified by Colin McGloin - 10/28/2019 - CR-20191023-13454
                if(aBCRevenue.Bypass_Trigger_Logic__c /*&& !mapOldABCRevenueLines.get(aBCRevenue.Id).Bypass_Trigger_Logic__c*/) {
                    byPassChangeReasonCodeError = true;
                    aBCRevenue.Bypass_Trigger_Logic__c = false;
                }
                
                //Loop through metadata records
                for(Fields_Changes_Configuration_Manager__mdt fCCM : listOfFieldsDetailsNeedToBeValidated) {
                    
                    //Checking record instance for it's eligibility and populating map accordingly
                    if((!fCCM.Not_Validate_For_Field_Change__c)
                       && (aBCRevenue.get(fCCM.Field_API_Name__c) != mapOldABCRevenueLines.get(aBCRevenue.Id).get(fCCM.Field_API_Name__c))
                       && (String.isBlank(aBCRevenue.Change_Reason_Code_Clone__c))
                       && (!byPassChangeReasonCodeError)
                      ) {
                          mapOfABCRevenueWithChangeReasonCodeErrorCheck.put(aBCRevenue.Id, true);
                          
                      }
                    else if((aBCRevenue.get(fCCM.Field_API_Name__c) != mapOldABCRevenueLines.get(aBCRevenue.Id).get(fCCM.Field_API_Name__c))
                            && String.isNotBlank(aBCRevenue.Change_Reason_Code_Clone__c)
                            && fCCM.Field_API_Name__c != 'Change_Reason_Code__c'
                            && fCCM.Field_API_Name__c != 'Line_Status__c'
                           ) {
                               mapOfABCRevenueEligibleForChangeReasonRecordCreate.put(aBCRevenue.Id, true);
                               
                               //Checking if record is eligible for line status updates
                               if(fCCM.Consider_For_Line_Status_Change__c 
                                  && (
                                      String.isNotBlank(aBCRevenue.Line_Status__c)
                                      &&
                                      (
                                          aBCRevenue.Line_Status__c.equalsIgnoreCase(System.Label.LINE_STATUS_REVIEWED)
                                          ||
                                          aBCRevenue.Line_Status__c.equalsIgnoreCase(System.Label.LINE_STATUS_VOID)
                                      )
                                  )
                                 ) {
                                     mapOfABCRevenueEligibleForLineStatusUpdates.put(aBCRevenue.ID, aBCRevenue);
                                 }
                           }
                }
            }
            
            //List of change reason records
            List<Change_Reason__c> listOfChangeReasonRecords = new List<Change_Reason__c>();
            
            //ABC Revenue Object scheme details
            Map<String, Schema.SObjectField> abcRevenueSchema = Schema.SObjectType.ABC_Revenue__c.fields.getMap();
            
            //Loop through ABC revenue records
            for(ABC_Revenue__c aBCRev : aBCRevenueLines) {
                
                //Checking for the key existance in the map
                if(mapOfABCRevenueEligibleForChangeReasonRecordCreate.containsKey(aBCRev.Id)) {
                    
                    //V2.0 - Modified - 06/19/2017(Issue--CR10991--UAT--00004672) - Rajeev Jain - Uncommented Code
                    //Change for requirement #2.3 commented out after Kip/Heather confirmation
                    //Checking for the key presence in the map
                    if(mapOfABCRevenueEligibleForLineStatusUpdates.containsKey(aBCRev.ID))
                        aBCRev.Line_Status__c = System.Label.Line_Status_Pending;
                    //V2.0 - Modified - 06/19/2017 - Rajeev Jain - Uncommented Code - upto Here
                    
                    //Change Reason record instance
                    Change_Reason__c changeReason = new Change_Reason__c();
                    
                    //Loop through metadata records
                    for(Fields_Changes_Configuration_Manager__mdt fCCMt : listOfFieldsDetailsNeedToBeValidated) {
                        
                        //Check if fied is custom and not a calculation
                        Schema.DescribeFieldResult describedElement = abcRevenueSchema.get(fCCMt.Field_API_Name__c.toLowerCase()).getDescribe();
                        
                        //Check if target is not a formula field and Data type matches for source and target
                        if(describedElement.getType() == Schema.DisplayType.TextArea
                           || describedElement.getType() == Schema.DisplayType.STRING
                           || describedElement.getType() == Schema.DisplayType.PICKLIST
                           || describedElement.getType() == Schema.DisplayType.EMAIL
                           || describedElement.getType() == Schema.DisplayType.MULTIPICKLIST
                          ) {
                              
                              //Checking if field is change reason code
                              if(fCCMt.Field_API_Name__c == 'Change_Reason_Code__c') {
                                  
                                  //Populating old values fields
                                  if(String.isNotBlank(fCCMt.Field_API_Name_Old_Value__c))
                                      changeReason.put(fCCMt.Field_API_Name_Old_Value__c, (string) mapOldABCRevenueLines.get(aBCRev.Id).get(fCCMt.Field_API_Name__c));
                                  
                                  //Populating new values fields
                                  if(String.isNotBlank(fCCMt.Field_API_Name_New_Value__c))
                                      changeReason.put(fCCMt.Field_API_Name_New_Value__c, (string) aBCRev.get(fCCMt.Field_API_Name__c));
                                  
                              } else {
                                  
                                  //Checking for the field values differences
                                  if(mapOldABCRevenueLines.get(aBCRev.Id).get(fCCMt.Field_API_Name__c) != aBCRev.get(fCCMt.Field_API_Name__c)) {
                                      
                                      //Populating old values fields
                                      if(String.isNotBlank(fCCMt.Field_API_Name_Old_Value__c))
                                          changeReason.put(fCCMt.Field_API_Name_Old_Value__c, (string) mapOldABCRevenueLines.get(aBCRev.Id).get(fCCMt.Field_API_Name__c));
                                      
                                      //Populating new values fields
                                      if(String.isNotBlank(fCCMt.Field_API_Name_New_Value__c))
                                          changeReason.put(fCCMt.Field_API_Name_New_Value__c, (string) aBCRev.get(fCCMt.Field_API_Name__c));        
                                  }        
                              }
                              
                          } else if(describedElement.getType() == Schema.DisplayType.DATETIME) {
                              
                              //Checking for the field values differences
                              if(mapOldABCRevenueLines.get(aBCRev.Id).get(fCCMt.Field_API_Name__c) != aBCRev.get(fCCMt.Field_API_Name__c)) {
                                  
                                  //Populating old values fields
                                  if(String.isNotBlank(fCCMt.Field_API_Name_Old_Value__c))
                                      changeReason.put(fCCMt.Field_API_Name_Old_Value__c, (DATETIME) mapOldABCRevenueLines.get(aBCRev.Id).get(fCCMt.Field_API_Name__c));
                                  
                                  //Populating new values fields
                                  if(String.isNotBlank(fCCMt.Field_API_Name_New_Value__c))
                                      changeReason.put(fCCMt.Field_API_Name_New_Value__c, (DATETIME) aBCRev.get(fCCMt.Field_API_Name__c));
                              }
                              
                          } else if(describedElement.getType() == Schema.DisplayType.Date) {
                              
                              //Checking for the field values differences
                              if(mapOldABCRevenueLines.get(aBCRev.Id).get(fCCMt.Field_API_Name__c) != aBCRev.get(fCCMt.Field_API_Name__c)) {
                                  
                                  //Populating old values fields
                                  if(String.isNotBlank(fCCMt.Field_API_Name_Old_Value__c))
                                      changeReason.put(fCCMt.Field_API_Name_Old_Value__c, (date) mapOldABCRevenueLines.get(aBCRev.Id).get(fCCMt.Field_API_Name__c));
                                  
                                  //Populating new values fields
                                  if(String.isNotBlank(fCCMt.Field_API_Name_New_Value__c))
                                      changeReason.put(fCCMt.Field_API_Name_New_Value__c, (date) aBCRev.get(fCCMt.Field_API_Name__c));
                              }    
                              
                          } else if(describedElement.getType() == Schema.DisplayType.CURRENCY
                                    ||
                                    describedElement.getType() == Schema.DisplayType.PERCENT
                                   ) {
                                       
                                       //Checking for the field values differences
                                       if(mapOldABCRevenueLines.get(aBCRev.Id).get(fCCMt.Field_API_Name__c) != aBCRev.get(fCCMt.Field_API_Name__c)) {
                                           
                                           //Populating old values fields
                                           if(String.isNotBlank(fCCMt.Field_API_Name_Old_Value__c))
                                               changeReason.put(fCCMt.Field_API_Name_Old_Value__c, (decimal) mapOldABCRevenueLines.get(aBCRev.Id).get(fCCMt.Field_API_Name__c));
                                           
                                           //Populating new values fields
                                           if(String.isNotBlank(fCCMt.Field_API_Name_New_Value__c))
                                               changeReason.put(fCCMt.Field_API_Name_New_Value__c, (decimal) aBCRev.get(fCCMt.Field_API_Name__c));
                                       }
                                       
                                   } else if(describedElement.getType() == Schema.DisplayType.INTEGER) {
                                       
                                       //Checking for the field values differences
                                       if(mapOldABCRevenueLines.get(aBCRev.Id).get(fCCMt.Field_API_Name__c) != aBCRev.get(fCCMt.Field_API_Name__c)) {
                                           
                                           //Populating old values fields
                                           if(String.isNotBlank(fCCMt.Field_API_Name_Old_Value__c))
                                               changeReason.put(fCCMt.Field_API_Name_Old_Value__c, (INTEGER) mapOldABCRevenueLines.get(aBCRev.Id).get(fCCMt.Field_API_Name__c));
                                           
                                           //Populating new values fields
                                           if(String.isNotBlank(fCCMt.Field_API_Name_New_Value__c))
                                               changeReason.put(fCCMt.Field_API_Name_New_Value__c, (INTEGER) aBCRev.get(fCCMt.Field_API_Name__c));
                                       }
                                       
                                   } else if(describedElement.getType() == Schema.DisplayType.Boolean) {
                                       
                                       //Checking for the field values differences
                                       if(mapOldABCRevenueLines.get(aBCRev.Id).get(fCCMt.Field_API_Name__c) != aBCRev.get(fCCMt.Field_API_Name__c)) {
                                           
                                           //Populating old values fields
                                           if(String.isNotBlank(fCCMt.Field_API_Name_Old_Value__c))
                                               changeReason.put(fCCMt.Field_API_Name_Old_Value__c, (Boolean) mapOldABCRevenueLines.get(aBCRev.Id).get(fCCMt.Field_API_Name__c));
                                           
                                           //Populating new values fields
                                           if(String.isNotBlank(fCCMt.Field_API_Name_New_Value__c))
                                               changeReason.put(fCCMt.Field_API_Name_New_Value__c, (Boolean) aBCRev.get(fCCMt.Field_API_Name__c));
                                       }
                                       
                                   } else if((describedElement.getType() == Schema.DisplayType.ID) || (describedElement.getType() == Schema.DisplayType.Reference)) {
                                       
                                       //Checking for the field values differences
                                       if(mapOldABCRevenueLines.get(aBCRev.Id).get(fCCMt.Field_API_Name__c) != aBCRev.get(fCCMt.Field_API_Name__c)) {
                                           
                                           //Populating old values fields
                                           if(String.isNotBlank(fCCMt.Field_API_Name_Old_Value__c))
                                               changeReason.put(fCCMt.Field_API_Name_Old_Value__c, (ID) mapOldABCRevenueLines.get(aBCRev.Id).get(fCCMt.Field_API_Name__c));
                                           
                                           //Populating new values fields
                                           if(String.isNotBlank(fCCMt.Field_API_Name_New_Value__c))
                                               changeReason.put(fCCMt.Field_API_Name_New_Value__c, (ID) aBCRev.get(fCCMt.Field_API_Name__c));
                                           
                                       } else if(String.isNotBlank(fCCMt.Field_API_Name_New_Value__c) 
                                                 && fCCMt.Field_API_Name_New_Value__c == 'ABC_Revenue__c'
                                                ) {
                                                    //Populating new values fields
                                                    if(String.isNotBlank(fCCMt.Field_API_Name_New_Value__c))
                                                        changeReason.put(fCCMt.Field_API_Name_New_Value__c, (ID) aBCRev.get(fCCMt.Field_API_Name__c));
                                                }
                                   }
                    }    
                    
                    //Populating list with instances
                    listOfChangeReasonRecords.add(changeReason);
                    
                }
            }
            
            //Checking list for it's size
            if(listOfChangeReasonRecords.size() > 0) {
                Util.byPassAllTriggers = true;
                insert listOfChangeReasonRecords;
                Util.BypassAllTriggers = false;
            }
            
            //Loop through ABC revenue records
            for(ABC_Revenue__c aBCRev : aBCRevenueLines) {
                
                //Checking for key existance in the map
                if(mapOfABCRevenueWithChangeReasonCodeErrorCheck.containsKey(aBCRev.Id))
                    aBCRev.addError(System.Label.PLEASE_POPULATE_CHANGE_REASON_CODE);
            }        
        }
    }
    
    /**
    *   Description     :   This method is used to populate the fields Project, Site Live Date, Deployment on Revenue records upon insert
    *
    *   @args           :   List<ABC_Revenue__c>>
    *
    *   @return type    :   Void
    *
    *   @Revision Log   :   V1.0 - Created - Colin McGloin
    *                   :   V1.1 - Modified - Colin McGloin - Added in filter on Deployment Query to skip records where Non_Revenue__c = True
    *            	:   V1.2 - Modified - Mahendra Swarnkar - 12/26/2019 - CR-20191122-13532
    *			:   V1.3 - Modified By - Dipesh Gupta - CR-20200221-13792 - 04/24/2020 - Added Es Deployment to the Set. 
    *			:   V1.4 - Modified By - Mahendra Swarnkar - CR-20200615-14184 - 01/05/2021 - Validation Rule for Deployments on revenue lines
    **/
    public static void populateSiteLiveOnABCRevenue(List<ABC_Revenue__c> aBCRevenues, Map<Id, ABC_Revenue__c> oldRevenue) {
        
        //Set containing our Program Subscription Ids
        Set<Id> progrSubIDs = new Set<Id>();

        //Set containing our Program IDs
        Set<Id> programIds = new Set<Id>();

        //Set to hold the Enrollment Program Subscription Ids. 
        Set<Id> SetOfProgramSubscriptionIds = new Set<Id>();

        //Map for mapping our unique Identifier of Institution/Program to the Program Subscription for later
        Map <Id, String> mapProgSubToAccProgCombo = new Map <Id, String>();

        //Map for associating our UniqueIdentifier with Projects
        Map <String, List <Deployment__c>> mapUniqIdToDepl = new Map <String, List <Deployment__c>>();

        //Map to hold the List of Job Tickets with UniqueIdentifier. 
        Map<String, List <Job_Ticket__c>> mapUniqueKeyToJobTickets = new Map<String, List <Job_Ticket__c>>();

        //Modified By Dipesh Gupta - CR-20200221-13792 - 04/24/2020 - Added Es Deployment to the Set. 
        //List of relevant Deployment record types we want to include in Search
        //Modified by Colin McGloin - 05/16/2019 - Removed Compass Connect RT & added SSC_Navigate_Deployment RT
        Set<String> deploymentRecordTypes = new Set<String>{'APS_Deployment', 'SSC_Deployment', 'SSC_Navigate_Deployment', 'Transfer_Consulting_and_Transfer_Portal', 'SSC_Navigate_Deployment', 'Compass_Deployment','EDH','ES_Deployment'};
        
        //Modified value: X-Duplicate/Cancelled to X - Cancelled/Duplicate  - Mahendra Swarnkar - 04/21/2020 - CR-20191122-13532
        //List of Deployment Phases to disregard in Query
        Set<String> cancelStatuses = new Set<String>{'6 - Contract Drop Pending', '7 - Contract Dropped', 'X - Cancelled/Duplicate'};
        
        //Added by Mahendra Swarnakr - 12/26/2019 - CR-20191122-13532 - Start Here
        //Boolean to check Integrated Account Id.
        Boolean IsIntegratedAccountID = false;
        
        //Map of Program Sub ID to the Integrated Account: Integrated Account Id
        Map<Id, Id> mapProgramSubscriptionToIntegratedAccountId =new Map<Id, Id>();
        
        //Map of Program Sub ID to the Boolean Value
        Map<Id, Boolean> mapProgramSubscriptionWithBooleanValue = new Map<Id, Boolean>();
        
        //Set to hold Ids of Integrated Account: Integrated Account Id
        Set<Id> setIntegratedAccountId = new Set<Id>();
        
        Map<Id, SBQQ__Subscription__c> mapProgramsDetails = new Map<Id, SBQQ__Subscription__c>();
        
        //Added by Mahendra Swarnakr - 12/26/2019 - CR-20191122-13532 - End Here
        
        //START - Loop over the ABC Revenue records
        for(ABC_Revenue__c abcRev : aBCRevenues != null ? aBCRevenues : oldRevenue.values()) {
            
            //Insert scenario - get the Program Subscription
            if(abcRev.Program_Subscription__c != null && oldRevenue == null){
                progrSubIDs.add(abcRev.Program_Subscription__c);
            }
            
            //Update Scenario - only run if Deployment/JOb Ticket is blank
            if(oldRevenue != null && abcRev.Program_Subscription__c != null && (abcRev.Deployment__c == null || abcRev.Job_Ticket__c == null) && abcRev.Site_Live_Date__c == null && oldRevenue.get(abcRev.Id) != null){
                progrSubIDs.add(abcRev.Program_Subscription__c);
            }
            
            //Added by Mahendra Swarnakr - 12/26/2019 - CR-20191122-13532 - Start Here
            //Insert scenario - get the Program Subscription
            //Commented out by Colin McGloin - 04/01/2022 - Phoenix - We're not using this code downstream anymore and we need to reduce formula references
            /*if(oldRevenue == null && abcRev.Program_Subscription__c != null ){
                if(abcRev.Integrated_Account_Integrated_AccountId__c !=null){
                    IsIntegratedAccountID = true;
                    mapProgramSubscriptionToIntegratedAccountId.put(abcRev.Program_Subscription__c, abcRev.Integrated_Account_Integrated_AccountId__c);
                    mapProgramSubscriptionWithBooleanValue.put(abcRev.Program_Subscription__c, IsIntegratedAccountID);
                }
                else{
                    IsIntegratedAccountID = false;
                    mapProgramSubscriptionToIntegratedAccountId.put(abcRev.Program_Subscription__c, abcRev.Integrated_Account_Integrated_AccountId__c);
                    mapProgramSubscriptionWithBooleanValue.put(abcRev.Program_Subscription__c, IsIntegratedAccountID);
                }
            }
            
            //Update Scenario
            if(oldRevenue != null && oldRevenue.get(abcRev.Id) != null && (abcRev.Deployment__c == null && abcRev.Site_Live_Date__c == null)
               && (abcRev.Program_Subscription__c != null || abcRev.Program_Subscription__c != oldRevenue.get(abcRev.Id).Program_Subscription__c)){
                   
                   if(abcRev.Integrated_Account_Name__c != null && 
                      abcRev.Integrated_Account_Name__c != oldRevenue.get(abcRev.Id).Integrated_Account_Name__c){
                          IsIntegratedAccountID = true;
                          mapProgramSubscriptionToIntegratedAccountId.put(abcRev.Program_Subscription__c, abcRev.Integrated_Account_Integrated_AccountId__c);
                          mapProgramSubscriptionWithBooleanValue.put(abcRev.Program_Subscription__c, IsIntegratedAccountID);
                      }
                   else{
                       IsIntegratedAccountID = false;
                       mapProgramSubscriptionToIntegratedAccountId.put(abcRev.Program_Subscription__c, abcRev.Integrated_Account_Integrated_AccountId__c);
                       mapProgramSubscriptionWithBooleanValue.put(abcRev.Program_Subscription__c, IsIntegratedAccountID);
                   }
               }*/
            //Added by Mahendra Swarnakr - 12/26/2019 - CR-20191122-13532 - End Here
            
        }
        
        
        //If we have records to query with then proceed
        if (progrSubIDs.size() > 0){
            
            //Added Product family Field to the Query. - Dipesh Gupta - CR-20200221-13792 - 04/24/2020.
            //Query to get the relevant Program Subscriptions and their details
            List<SBQQ__Subscription__c> relatedProgSubs =   [SELECT Id, Name, SBQQ__Account__c, Program__c, 
                                                             SBQQ__Product__c, SBQQ__Product__r.Family 
                                                             FROM SBQQ__Subscription__c
                                                             WHERE Id IN :progrSubIDs];            
            
            //Set to hold the program subscription's Product ids . 
            Set<Id> setOfProductWhereProductIsEnrollmentServices = new Set<Id>();
            
            //If we have Subscriptions records then proceed
            if (relatedProgSubs.size() > 0) {
                
                //Loop through our Program Subscriptions and get the Programs
                for (SBQQ__Subscription__c pS : relatedProgSubs){
                    
                    //CR-20200221-13792 - Added By Dipesh Gupta.Check for Enrollment Services Products.
                    if(String.isNotBlank(pS.SBQQ__Product__c) && pS.SBQQ__Product__r.Family == 'Enrollment Services') {
                        
                        setOfProductWhereProductIsEnrollmentServices.add(pS.SBQQ__Product__c);
                        SetOfProgramSubscriptionIds.add(pS.Id);
                        
                    }else{
                        //Add our Program Id to the Set for query later
                        if (pS.Program__c != null){
                            programIds.add(pS.Program__c);
                            mapProgramsDetails.put(pS.Id, pS);
                        }
                    }
                }
                
                //If we have Programs to use in our Query then proceed
                if (programIds.size() > 0){
                    
                    
                    //Query for our Deployments which have meet our Status, Record Type and Program criteria
                    List<Deployment__c> associatedDeployments = [SELECT Id, Deployment_Phase__c, Project__c, Project__r.Institution__c, Name, Program__c, 
                                                                 Site_Live_Actual__c, Site_Live_Expected__c, C_A_DC__c, RecordType.DeveloperName, Non_Revenue__c
                                                                 FROM Deployment__c
                                                                 WHERE Program__c IN :programIds
                                                                 AND Project__r.Institution__c != null
                                                                 AND RecordType.DeveloperName IN :deploymentRecordTypes  
                                                                 AND Deployment_Phase__c NOT IN :cancelStatuses
                                                                 AND Non_Revenue__c != TRUE];
                    
                    
                    //If we have Deployments records then proceed
                    if (associatedDeployments.size() > 0) {
                        
                        
                        //Loop through our Deployment records
                        for (Deployment__c depl : associatedDeployments){
                            
                            //Create our Identifier for the Deployment
                            String uniqueIdentifier = depl.Project__r.Institution__c + '-' + depl.Program__c;
                            
                            
                            //Check our Map for the Unique Identifier and related Deployments and add to list
                            if (mapUniqIdToDepl.get(uniqueIdentifier) != null){
                                List <Deployment__c> deplList = mapUniqIdToDepl.get(uniqueIdentifier);
                                deplList.add(depl);
                                mapUniqIdToDepl.put(uniqueIdentifier, deplList);
                            }
                            else {
                                List <Deployment__c> deplList = new List <Deployment__c>();
                                deplList.add(depl);
                                mapUniqIdToDepl.put(uniqueIdentifier, deplList);
                            }
                            
                        }
                    }
                }
                
                //Added By Dipesh - CR-20200221-13792 - Job Ticket logic.
                if(setOfProductWhereProductIsEnrollmentServices.size() > 0 ) {
                    
                    //Query on the Job Tickets. 
                    for(Job_Ticket__c jobTicket : [Select Id,Project__c,  Project__r.Institution__c, Fiscal_Year__c, 
                                                   Project__r.Product2__c, Drop_1_Actual_Mail_Date__c From Job_Ticket__c
                                                   Where  Project__c != null 
                                                   AND Project__r.Product2__c IN: setOfProductWhereProductIsEnrollmentServices]) 
                    {
                        
                        //Adding the unique key.                            
                        String uniqueKey = jobTicket.Project__r.Product2__c + '-' + jobTicket.Project__r.Institution__c + '-' + jobTicket.Fiscal_Year__c;
                        
                        if(!mapUniqueKeyToJobTickets.containsKey(uniqueKey))
                            mapUniqueKeyToJobTickets.put(uniqueKey, new List<Job_Ticket__c>());
                        
                        mapUniqueKeyToJobTickets.get(uniqueKey).add(jobTicket);
                    }
                    
                }
            }
        }
        
        //Loop back through our original Revenue Records
        for(ABC_Revenue__c abcRevenue : aBCRevenues) {
            
            //Variable to hold our Identifier
            String uniqId;
            //Check if the Abc Revenue's Program Subscription is of Enrollment Type. 
            if(SetOfProgramSubscriptionIds.contains(abcRevenue.Program_Subscription__c) && abcRevenue.Job_Ticket__c == null) {
                
                
                //Check the below fields are not null.  
                if(String.isNotBlank(abcRevenue.Product__c) && String.isNotBlank(abcRevenue.Institution__c) 
                   && abcRevenue.Revenue_Start_Date__c != null )
                    uniqId = abcRevenue.Product__c + '-' + abcRevenue.Institution__c + '-' + abcRevenue.Revenue_Start_Date__c.year();
                
            }else{
                
                //Get the Identifier in our Map
                if(mapProgramsDetails != null && mapProgramsDetails.get(abcRevenue.Program_Subscription__c) != null){
                    
                    String accId = abcRevenue.Integrated_Account_Name__c != null ? abcRevenue.Integrated_Account_Name__c : mapProgramsDetails.get(abcRevenue.Program_Subscription__c).SBQQ__Account__c;
                    uniqId = accId + '-' + mapProgramsDetails.get(abcRevenue.Program_Subscription__c).Program__c;
                }
            }

            //Check to see if we have a Identifier then proceed
            if (uniqId != null){
                //Check to see if we have records in our Membership to Deployment Map
                if (mapUniqIdToDepl.get(uniqId) != null){
                    
                    //Get our List of Deployments
                    List<Deployment__c> deplList = mapUniqIdToDepl.get(uniqId);
                    
                    
                    //Check to see if there is only one matching Deployment
                    if (deplList.size() == 1){
                        
                        //Add our Project to the Revenue record
                        abcRevenue.Project__c = deplList[0].Project__c;
                        //Add our Site Live Date to the Revenue record
                        if(deplList[0].C_A_DC__c != null)
                            abcRevenue.Site_Live_Date__c = deplList[0].C_A_DC__c;
                        //Add our Deployment record to the Revenue record
                        abcRevenue.Deployment__c = deplList[0].Id;
                        
                    }
                    
                }else {
                    
                    //Checking if the job ticket find with this unique Key and only one job ticket exist with that configuration.SELECT  FROM ${1||}
                    if(mapUniqueKeyToJobTickets.get(uniqId) != null && mapUniqueKeyToJobTickets.get(uniqId).size() == 1 ) {
                        abcRevenue.Job_Ticket__c = mapUniqueKeyToJobTickets.get(uniqId)[0].Id;
                        abcRevenue.Project__c =  mapUniqueKeyToJobTickets.get(uniqId)[0].Project__c;
                        abcRevenue.Site_Live_Date__c = mapUniqueKeyToJobTickets.get(uniqId)[0].Drop_1_Actual_Mail_Date__c;
                    }
                }
            }
            
            //Modified By - Mahendra Swarnkar - 01/05/2021 - CR-20200615-14184 - Validation Rule for Deployments on revenue lines
            //update Site Live Date if Deployment on Revenue is blank (only in update case) 
            if(oldRevenue != null && abcRevenue.Deployment__c == null && abcRevenue.Site_Live_Date__c != null) {
                abcRevenue.Site_Live_Date__c = null;
            }
            //if condition ends here
        }
        
    }
    
    /**
    *   Description     :   This method is used to validate "Revenue Line" records fields values and to populate them as per business logics.
    *
    *   @args           :   List<ABC_Revenue_Line__c>, Map<Id, ABC_Revenue_Line__c>
    *
    *   @return type    :   Void
    *
    *   @Revision Log   :   V1.0 Created - Rev Rec Phase 2
    *                       V1.1 - Modified By - Nikita Kumari - 07/26/2021 - CR-20201217-14749 - Replace Recognized_to_Date_GAAP__c field with the POLI: Recognized Revenue (POLI_Recognized_Revenue__c)   
    **/
    public static void beforeEventsLogicHandler(List<ABC_Revenue__c> aBCRevenueLines, Map<Id, ABC_Revenue__c> mapOldABCRevenueLines) {
        
        //Loop through revenue lines
        for(ABC_Revenue__c aRL : aBCRevenueLines) {
            
            //Checking for the business logic before populating the fields on ABC Revenue Lines
            //CHecking if “Line Status” is Reviewed or Void and 2) “Rev Rec Complete” is FALSE
            if(String.isNotBlank(aRL.Line_Status__c)
               &&
               (
                   aRL.Line_Status__c.equalsIgnoreCase(System.Label.LINE_STATUS_REVIEWED)
                   ||
                   aRL.Line_Status__c.equalsIgnoreCase(System.Label.LINE_STATUS_VOID)
               )
               //&& (!aRL.Include_In_Rev_Recx__c)
              ) {
                  
                  //3)“Risk Status” is “None or Complete” or blank/null (1 and 2 and 3)
                  if((aRL.Risk_Status__c == null
                      ||
                      (
                          aRL.Risk_Status__c != null
                          &&
                          (
                              aRL.Risk_Status__c.equalsIgnoreCase(RMConstants.ABC_REVENUE_RISK_TYPE_NONE)
                              ||
                              aRL.Risk_Status__c.equalsIgnoreCase(RMConstants.ABC_REVENUE_RISK_TYPE_COMPLETE)
                              ||
                              aRL.Risk_Status__c.equalsIgnoreCase(RMConstants.ABC_REVENUE_RISK_TYPE_BLANK)
                          )
                      )
                     )
                     
                    )
                      
                  {
                      
                      //Populating "Include in Rev Rec" field with value equals to true
                      aRL.Include_In_Rev_Recx__c = true;
                      
                  } else {
                      
                      //Checking for the risk status field value
                      //Modified By - Nikita Kumari - 07/26/2021 - CR-20201217-14749 - Replace Recognized_to_Date_GAAP__c field with the POLI: Recognized Revenue (POLI_Recognized_Revenue__c)
                      if(
                            (
                                aRL.POLI_Recognized_Revenue__c != null
                                && aRL.POLI_Recognized_Revenue__c != 0.00
                                && aRL.POLI_Recognized_Revenue__c != 0
                            )
                      ) {
                          
                          //Populating "Include in Rev Rec" field with value equals to true
                          aRL.Include_In_Rev_Recx__c = true;
                          
                      } else {
                          
                          //Populating "Include in Rev Rec" field with value equals to false
                          aRL.Include_In_Rev_Recx__c = false;
                          
                      }
                  }
              } else {
                  
                  //Populating "Include in Rev Rec" field with value equals to false
                  aRL.Include_In_Rev_Recx__c = false;
                  
              }
        }        
    }
    
    /**
    *  @description    :   This method is used to calculate the List Price for the Revenue records
    *
    *  @return         :   void
    *
    *  @Revision Log   :   V1.0 - 3/4/2019 - Created - CR-20180918-12607 - Colin McGloin
    *                      V1.1 - 05/10/2019 - Modified - CR-20190506-13092 - Colin McGloin
    *                      V1.1 - 05/14/2020 - Modified - CR-20200415-13946 - Mahendra Swarnkar
    *
    **/
    public static void calculateListPriceRevenueRecord (List<ABC_Revenue__c> revenueRecords, Map<Id, ABC_Revenue__c> oldRevenue, Boolean runFromTrigger){
        
        //Map for storing our original Program Subscription and associated components
        Map<Id, List<SBQQ__Subscription__c>> mapComponentSubscriptionsToPS = new Map <Id, List<SBQQ__Subscription__c>>();
        //List for Revenue records which are related to Program Subscription
        List<ABC_Revenue__c> relevantRevenues = new List<ABC_Revenue__c>();
        //List for updating records if not run from Trigger
        List<ABC_Revenue__c> finalUpdateRevs = new List<ABC_Revenue__c>();
        
        //Loop througn our records and establish if an update is needed
        for (ABC_Revenue__c abcRev : revenueRecords != null ? revenueRecords : oldRevenue.values()){
            
            //If it meets our initial entry requirement, then add to Map so we can go search for Components
            if (abcRev.Program_Subscription__c != null){
                //Add our Record to our Map for our Component Search
                if (mapComponentSubscriptionsToPS.get(abcRev.Program_Subscription__c) == null){
                    mapComponentSubscriptionsToPS.put(abcRev.Program_Subscription__c, new List<SBQQ__Subscription__c>());
                }
                //Add our Revenue record for processing through later
                relevantRevenues.add(abcRev);
            }
        }
        
        //Added Revenue_Matching_End_Date__c in the query -By Mahendra Swarnkar - 04/20/2020 - CR-20200415-13946
        //Added Type__c in the query - 05/12/2020
        //Go off and get our Component Subscription records
        List<SBQQ__Subscription__c> relatedSubscriptions = [SELECT Id, Name, SBQQ__SegmentStartDate__c, SBQQ__SegmentEndDate__c, SBQQ__Product__c,
                                                            SBQQ__Product__r.Revenue_Matching_End_Date__c, Type__c,Contract_Signature_Date__c,
                                                            Term_Type__c, Years_in_Term__c, SBQQ__ListPrice__c, Product_Category__c, Program_Subscription__c
                                                            FROM SBQQ__Subscription__c
                                                            WHERE Program_Subscription__c = :mapComponentSubscriptionsToPS.keyset()];
        
        //If we have related records then proceed
        if (relatedSubscriptions.size() > 0){
            
            //Loop through our Component records and add to the Map
            for (SBQQ__Subscription__c subscription : relatedSubscriptions){
                if (mapComponentSubscriptionsToPS.get(subscription.Program_Subscription__c) != null){
                    List <SBQQ__Subscription__c> compSubs = mapComponentSubscriptionsToPS.get(subscription.Program_Subscription__c);
                    compSubs.add(subscription);
                    mapComponentSubscriptionsToPS.put(subscription.Program_Subscription__c, compSubs);
                }
            }
            
        }
        
        //Modified - Mahendra Swarnkar - 04/20/2020 - CR-20200415-13946 - Modify "Annual" to "Annual - Program" for both Annual Fee and Travel Fee values
        //Map our Product Category to the Revenue Fee Type  
        Map<String, String> mapSubProdCatToRevenueFeeType = new Map<String, String>{'Annual Fee' => 'Annual - Program','Travel Fee' => 'Annual - Program','Implementation Fee' => 'Setup_Implementation' };
            
            //Set Revenue Fee Type
            Set<String> setRevenueFeeForGAAPTotal = new Set<String>{'Annual - Media', 'Annual - Postage','Final Invoice - Media', 'Final Invoice - Postage', 'Upsell - Media', 'Upsell - Postage'};
                Set<String> setByPassComponentTypeListCalculation = new Set<String>{'Final Invoice Adjustment', 'Upsell', 'Final Adjustment'};
                    //Loop through our Revenue Records again
                    for (ABC_Revenue__c revenue : relevantRevenues){
                        
                        //Variable for storing our List Price after looping through all the records
                        Decimal combinedListPrice = 0;
                        
                        //Create a List of related Component Subscriptions which we will loop through 
                        List <SBQQ__Subscription__c> compSubs = new List<SBQQ__Subscription__c>();
                        
                        //Go get our List Price calculation if the record is not Void
                        if (revenue.Line_Status__c != 'Void'){
                            
                            //New logic for GAAP - Mahendra Swarnkar - 04/20/2020 - CR-20200415-13946
                            if(String.isNotBlank(revenue.Fee_Type__c) && setRevenueFeeForGAAPTotal.contains(revenue.Fee_Type__c))
                            {
                                combinedListPrice += revenue.GAAP_Amount__c;
                            }
                            //Go get our List of Component records
                            if (mapComponentSubscriptionsToPS.get(revenue.Program_Subscription__c) != null){
                                compSubs = mapComponentSubscriptionsToPS.get(revenue.Program_Subscription__c);
                            }
                            
                            //If we have records then proceed
                            if (compSubs.size() > 0){
                                
                                //Loop through out Subscription records
                                for (SBQQ__Subscription__c sub : compSubs){
                                    
                                    //If the Categories match
                                    if (revenue.Fee_Type__c == mapSubProdCatToRevenueFeeType.get(sub.Product_Category__c) && ( !setByPassComponentTypeListCalculation.contains(sub.Type__c)) ){
                                        
                                        
                                        //Calculate our List Price Amount per Day
                                        //Modified in CR-20190506-13092 - Adding an extra day
                                        Integer daysOfSegment = 0;
                                        if (sub.SBQQ__SegmentStartDate__c != null && sub.SBQQ__SegmentEndDate__c != null){
                                            daysOfSegment = sub.SBQQ__SegmentStartDate__c.daysBetween(sub.SBQQ__SegmentEndDate__c + 1);
                                        }
                                        Decimal DailyListPriceAmount = 0;
                                        
                                        //DailyListPrice Calculation
                                        if(daysOfSegment != 0 && sub.SBQQ__ListPrice__c != null){
                                            DailyListPriceAmount = sub.SBQQ__ListPrice__c/daysOfSegment;
                                        }
                                        //Modified By Mahendra Swarnkar - 04/20/2020 - CR-20200415-13946
                                        Date newRevenueRecognitionDate = null;
                                        if(sub.SBQQ__Product__r.Revenue_Matching_End_Date__c != null && revenue.Recognition_End_Date__c != sub.SBQQ__Product__r.Revenue_Matching_End_Date__c ){
                                            integer dayValue = (sub.SBQQ__Product__r.Revenue_Matching_End_Date__c).day();
                                            integer monthValue = (sub.SBQQ__Product__r.Revenue_Matching_End_Date__c).month();
                                            integer yearValue = (revenue.Recognition_End_Date__c).year();
                                            
                                            newRevenueRecognitionDate = date.newinstance(yearValue, monthValue, dayValue);
                                        }
                                        //Calculate if we have an overlap
                                        if (revenue.Recognition_Start_Date__c <= sub.SBQQ__SegmentEndDate__c && (newRevenueRecognitionDate != null ? newRevenueRecognitionDate : revenue.Recognition_End_Date__c) >= sub.SBQQ__SegmentStartDate__c){                                  
                                            
                                            //Variable for storing our Overlap days
                                            Integer overlapDays = 0;
                                            
                                            //Replaced Recognition_End_Date__c with newRevenueRecognitionDate when it is assigned to overlapDays variable - Mahendra Swarnkar- 04/20/2020 - Recognition_End_Date__c
                                            //Specific Overlap scenarios
                                            //Modified in CR-20190506-13092 - Adding an extra day in these scenarios
                                            if (revenue.Recognition_Start_Date__c < sub.SBQQ__SegmentStartDate__c && (newRevenueRecognitionDate != null ? newRevenueRecognitionDate : revenue.Recognition_End_Date__c) <= sub.SBQQ__SegmentEndDate__c){
                                                if(newRevenueRecognitionDate != null)
                                                    overlapDays = sub.SBQQ__SegmentStartDate__c.daysBetween(newRevenueRecognitionDate) + 1;
                                                else
                                                    overlapDays = sub.SBQQ__SegmentStartDate__c.daysBetween(revenue.Recognition_End_Date__c) + 1;
                                            } else if (revenue.Recognition_Start_Date__c >= sub.SBQQ__SegmentStartDate__c && (newRevenueRecognitionDate != null ? newRevenueRecognitionDate : revenue.Recognition_End_Date__c) <= sub.SBQQ__SegmentEndDate__c){
                                                if(newRevenueRecognitionDate != null)
                                                    overlapDays = revenue.Recognition_Start_Date__c.daysBetween(newRevenueRecognitionDate) + 1;
                                                else
                                                    overlapDays = revenue.Recognition_Start_Date__c.daysBetween(revenue.Recognition_End_Date__c) + 1;
                                            } else if (revenue.Recognition_Start_Date__c >= sub.SBQQ__SegmentStartDate__c && (newRevenueRecognitionDate != null ? newRevenueRecognitionDate : revenue.Recognition_End_Date__c) > sub.SBQQ__SegmentEndDate__c){
                                                overlapDays = revenue.Recognition_Start_Date__c.daysBetween(sub.SBQQ__SegmentEndDate__c) + 1;
                                            } else if (revenue.Recognition_Start_Date__c < sub.SBQQ__SegmentStartDate__c && (newRevenueRecognitionDate != null ? newRevenueRecognitionDate : revenue.Recognition_End_Date__c) > sub.SBQQ__SegmentEndDate__c){
                                                overlapDays = sub.SBQQ__SegmentStartDate__c.daysBetween(sub.SBQQ__SegmentEndDate__c) + 1;
                                            }
                                            
                                            
                                            //Calculate the Amount field
                                            if (DailyListPriceAmount != 0){
                                                Decimal rangelistPrice = DailyListPriceAmount*overlapDays;
                                                combinedListPrice += rangelistPrice;
                                            }
                                            
                                        }
                                        
                                    }
                                    //New logic for calculating List Price - Fee Type equal to "Upsell - Amendment" - Mahendra Swarnkar - CR-20200415-13947
                                    //New logic for calculating List Price - Fee Type equal to "Upsell - Program" - Mahendra Swarnkar - 04/20/2020
                                    if(revenue.Fee_Type__c == 'Upsell - Program' || revenue.Fee_Type__c == 'Final Invoice - Program' || revenue.Fee_Type__c == 'Upsell - Amendment'){
                                        
                                        //Added by Mahendra Swarnkar - 05/12/2020 - CR-20200415-13946
                                        if (revenue.Recognition_Start_Date__c == sub.Contract_Signature_Date__c && 
                                            revenue.Recognition_End_Date__c == sub.SBQQ__SegmentEndDate__c)
                                        {
                                            combinedListPrice += sub.SBQQ__ListPrice__c;
                                        }    
                                    }
                                    
                                }//for end of cmpSub
                                
                            }
                            
                        }
                        
                        //Set the Revenue fake list Price
                        Revenue.List_Price__c = combinedListPrice;
                        finalUpdateRevs.add(Revenue);
                        
                    }
        
        //Run List Update if not run from Trigger
        if (runFromTrigger == false && finalUpdateRevs.size() > 0){
            update finalUpdateRevs;
        }
        
    }
    
    /**
    *  @description    :   This future method is called from Subscription Trigger (intention is to lessen impact on Governor Limits on Subscription side)
    *
    *  @return         :   void
    *
    *  @Revision Log   :   V1.0 - 3/4/2019 - Created - CR-20180918-12607 - Colin McGloin
    * 		       :   V1.1 - 3/8/2019 - Removed the future annotation, because we are executing this from a enqueue job.
     *		       :   V1.2 - Modified By - Neha Sharma - 1/17/2021 - CR-20210113-14803
    *
    **/
    
    public static void checkForRevenueRecords (List<Id> progSubs) {
        
        //Query for our Revenue Records
        List<ABC_Revenue__c> relatedRevenue = [SELECT ID, Name, Program_Subscription__c, GAAP_Amount__c,Fee_Type__c, Recognition_Start_Date__c, Recognition_End_Date__c, List_Price__c, Line_Status__c 
                                               FROM ABC_Revenue__c
                                               WHERE Program_Subscription__c IN :progSubs];
        
        //If there are records to calculate
        if (relatedRevenue.size() > 0){
            
            //Pass our records through to the Calculate Method
            calculateListPriceRevenueRecord(relatedRevenue, null, false);
        }
        
    }
    
     /**
    *  @description    :   This method is used to calculate the List Price for the Revenue records
    *
    *  @return         :   void
    *
    *  @Revision Log   :   V1.0 - 11/10/2021 - Created - CR-20210908-15415 - Nikita Kumari
    *
    **/
    public static void validateTemplateBasedFields(List<ABC_Revenue__c> revenueRecords, Map<Id, ABC_Revenue__c> oldRevenue) {
        
        Set<String> setRevRecTemplateIds = new Set<String>();
        
        //loop through revenue
        for(ABC_Revenue__c abcRevenue : revenueRecords) {
            if(String.isNotBlank(abcRevenue.Rev_Rec_Template_Selected__c) 
               && (oldRevenue == null 
                	|| (oldRevenue != null 
				  		&& (oldRevenue.get(abcRevenue.Id).Rev_Rec_Template_Selected__c != abcRevenue.Rev_Rec_Template_Selected__c
                     		|| (abcRevenue.Contracted_Quantity__c == null && oldRevenue.get(abcRevenue.Id).Contracted_Quantity__c != abcRevenue.Contracted_Quantity__c)
                            || (abcRevenue.Contracted_Hours__c == null && oldRevenue.get(abcRevenue.Id).Contracted_Hours__c != abcRevenue.Contracted_Hours__c)))
               ))
            {
				setRevRecTemplateIds.add(abcRevenue.Rev_Rec_Template_Selected__c);
            }
        }
        
        if(setRevRecTemplateIds.size() > 0) {
        	
            //map of custom metadata records which is holding fields related information
            Map<String, List<Revenue_Template_Related_Field_Mapping__mdt>> mapOfFieldsDetailsNeedToBeValidated = new Map<String, List<Revenue_Template_Related_Field_Mapping__mdt>>();
            Map<String, Set<String>> mapTemplateIdsWithOptionalRevenueFields = new Map<String, Set<String>>();
            
            for(Revenue_Template_Related_Field_Mapping__mdt revFieldMap : [SELECT ID, IsActive__c, Revenue_Field_API_Name__c, Revenue_Field_Label__c, Source_Object_API_Name__c,
                                                                           Target_Object_API_Name__c, Template_Id__c,Template_Name__c, Optional_Revenue_Field__c
                                                                           FROM Revenue_Template_Related_Field_Mapping__mdt
                                                                           WHERE Source_Object_API_Name__c = 'ABC_Revenue__c' AND IsActive__c = true
                                                                           AND Revenue_Field_API_Name__c != null AND Template_Id__c != '' 
                                                                           AND Template_Id__c IN : setRevRecTemplateIds])
            {
                if(!mapOfFieldsDetailsNeedToBeValidated.containsKey(revFieldMap.Template_Id__c)){
                    mapOfFieldsDetailsNeedToBeValidated.put(revFieldMap.Template_Id__c, new List<Revenue_Template_Related_Field_Mapping__mdt>());
                }  
                mapOfFieldsDetailsNeedToBeValidated.get(revFieldMap.Template_Id__c).add(revFieldMap);
                
			}
             
            if(mapOfFieldsDetailsNeedToBeValidated.size() > 0  && mapOfFieldsDetailsNeedToBeValidated.keySet().size() > 0) {
                
                String errorMessageOnRev ='';
                String errorMessageOnRevOptional ='';
                Boolean addErrorOnRev = false;
                Boolean ErrorOnOptionalFieldsValiation = true;
                
                //loop through revenue
                for(ABC_Revenue__c abcRevenue : revenueRecords) {
                    
                    if(String.isNotBlank(abcRevenue.Rev_Rec_Template_Selected__c) 
                       && (oldRevenue == null 
                           || (oldRevenue != null 
                               && (oldRevenue.get(abcRevenue.Id).Rev_Rec_Template_Selected__c != abcRevenue.Rev_Rec_Template_Selected__c
                                  || (abcRevenue.Contracted_Quantity__c == null && oldRevenue.get(abcRevenue.Id).Contracted_Quantity__c != abcRevenue.Contracted_Quantity__c)
                            	  || (abcRevenue.Contracted_Hours__c == null && oldRevenue.get(abcRevenue.Id).Contracted_Hours__c != abcRevenue.Contracted_Hours__c)))
                       ))
                    {
                        //check templates id in metadata records before validate
                        if(mapOfFieldsDetailsNeedToBeValidated.keySet().contains(abcRevenue.Rev_Rec_Template_Selected__c)) {
							errorMessageOnRev = System.Label.Rev_Template_Error_Message;
                            errorMessageOnRevOptional = System.Label.Rev_Template_Error_Message_Optional;
                            addErrorOnRev = false;
                        	ErrorOnOptionalFieldsValiation = true;
                            
							for(Revenue_Template_Related_Field_Mapping__mdt fields : mapOfFieldsDetailsNeedToBeValidated.get(abcRevenue.Rev_Rec_Template_Selected__c))
                            {
                                if(String.isNotBlank(fields.Optional_Revenue_Field__c)) 
                                {
                                    
                                    for(String optField : ((String) (fields.Optional_Revenue_Field__c)).trim().split(',')) {
                                        
                        				if(String.isBlank(optField.trim()))
                                            continue;
                                            
                                        if(String.isNotBlank(String.valueOf(abcRevenue.get(optField.trim())))) {
                                            ErrorOnOptionalFieldsValiation = false;
                                            break;    
                                        } else{
                                            errorMessageOnRevOptional += optField.trim() + ', ' ;    
                                        }
                                    }
                                } else {
                                    if(String.isBlank(String.valueOf(abcRevenue.get(fields.Revenue_Field_API_Name__c)))) {
                                        addErrorOnRev = true;
                                        errorMessageOnRev += (String.isNotBlank(fields.Revenue_Field_Label__c) ?fields.Revenue_Field_Label__c + ', ' : fields.Revenue_Field_API_Name__c + ', ');
                                    }
                                }
                            }
                            if(addErrorOnRev || ErrorOnOptionalFieldsValiation) {
                                
                                String finalError = '';
                                
                                if(ErrorOnOptionalFieldsValiation ) {
                                    finalError += errorMessageOnRevOptional.removeEnd(', ') + '<br/>';
                                }
                                
                                if(addErrorOnRev ){
                                    finalError += errorMessageOnRev.removeEnd(', ');
                            	}
                                
                                abcRevenue.addError(finalError.removeEnd('<br/>'));
                            }
                        }
                    }
                }
            }
        }
    }
}