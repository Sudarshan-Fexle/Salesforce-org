/**
*  Description     :   Helper class for case object trigger
* 
*  Created By      :   Bhavi Sharma    
* 
*  Created Date    :   03/23/2013
* 
*  Revision Logs   :   V_1.0 - Created
                       V_1.1 - Modified By - Abhinav Sharma - 05/21/2014 - CR-20140108-4238        
*                      V_1.2 - Modified By - Ajit Surana - 05/24/2014 - CR-20140512-5440
*                      V_1.3 - Modified By - Victor Hanson 6/01/2014 - CR-4283
*                      V_1.4 - Modified By - Abhinav Sharma - 06/19/2014 - CR-20140417-5120
*                      V_1.5 - Modified By - Abhinav Sharma - CR-20140618-5845 - 07/03/2014 - Added new method - beforeEventsLogicHandler
*                      V_1.6 - Modified By - Abhinav Sharma - CR-20140629-6015 - 07/04/2014 - Modified existing method - beforeEventsLogicHandler
*                      V_1.7 - Modified By - Abhinav Sharma - CR-20140707-6093 - 08/06/2014 - Modified existing method - deletedOutOutOfOfficeCases
*                      V_1.8 - Modified By - Ajit Surana - CR-20140812-6973 - 09/10/2014 - Modified existing method - populateCaseFromEmailToCase
*                      V_1.9 - Modified By - Abhinav Sharma - CR-20140827-7164 - 10/08/2014 - Modified existing method - deletedOutOutOfOfficeCases and populateCaseFromEmailToCase
*                      V_2.0 - Modified By - Abhinav Sharma - CR-20141001-7574 -10/15/2014 - Added new method - manageTasksForSyndicatedServiceCases
*                      V_2.1 - Modified By - Ajit Surana - 11/16/2014 - CR-20141105-7987 - Modified method (populateCaseFromEmailToCase)
*                      V_2.2 - Modified By - Ajit Surana - 11/17/2014 - CR-20141105-7992 - Modified method (populateCaseFromEmailToCase)
*                      V_2.3 - Modified By - Ajit Surana - 11/22/2014 - CR-20140625-5930
*                      V_2.4 - Modified By - Ajit Surana - CR-20141103-7949 - 12/4/2014 - Modified to comment and De-comment out of Member_Facing_Resolution_Summary__c reference
*                      V_2.5 - Modified By - Abhinav Sharma - 11/26/2015 - CR-20151118-9394 - Modified the method beforeEventsLogicHandler
*                      V_2.6 - Modified By - Abhinav Sharma - 12/01/2015 - CR-20150616-9006 - Modified existing method - deletedOutOutOfOfficeCases and populateCaseFromEmailToCase 
*                      V_2.7 - Modified By - Mahendra Swarnakar - 12/02/2015 - CR-20151118-9397 - Modified existing method - deletedOutOutOfOfficeCases and populateCaseFromEmailToCase
*                      V_2.8 - Modified By - Abhinav Sharma - 02/11/2016 - CR-20150925-9267 - Modified existing method - beforeEventsLogicHandler
*                      V_2.9 - Modified By - Victor Hanson - 02/19/2016 - CR-20160113-9507 - Modified existing method - convertSourceFieldValue
*                      V_3.0 - Modified By - Abhinav Sharma - 03/31/2016 - CR-20160224-9632 - Modified existing method - beforeEventsLogicHandler
*                      V_3.1 - Modified By - Mahendra Swarnkar - 07/05/2016 - CR-20160229-9651 - Added a new method "populateCaseFields" and modify the "beforeEventsLogicHandler" method
*                      V_3.2 - Modified By - Mahendra Swarnkar - 07/07/2016 - CR-20160609-9913 - Modified the existing method "beforeEventsLogicHandler", existing deadline field population logic.
*                      V_3.3 - Modified By - MAhendra Swarnkar - CR-20160803-10082 - 08/23/2016 -  Modified the existing method "beforeEventsLogicHandler" to have logic to populate the Priority field on the case for Expert Center record type. Updating the logic of default value for deadline field and added validation logic for Deadine Reason field requiredness for syndicated case record type.
*                      V_3.4 - Modified By - Abhinav Sharma - 08/30/2016 - CR-20160114-9520 - Added a new method "updateFirstCommentDateTimeOnMS"
*                      V_3.5 - Modified By - Abhinav Sharma - 09/29/2016 - CR-20160916-10182
*                      V_3.6 - Modified By - Rajeev Jain - 10/19/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
*                      V_3.7 - Modified By - Mahendra Swarnkar - 10/10/2016 - CR-20160607-9905
*                      V_3.8 - Modified By - Mahendra Swarnkar - 10/17/2016 - CR-20160726-10065
*                      V_3.9 - Modified By - Mahendra Swarnkar - 10/20/2016 - CR-20160209-9593 - Created a new method "sentEmailToParentCaseOwnerOnChildClosed".
*                      V_4.0 - Modified By - Mahendra Swarnkar - 11/17/2016 - CR-20161019-10240
*                      V_4.1 - Modified By - Rajeev Jain - 11/21/2016 - Services Excellence UAT Issue fix - Populate MS.StatusDateTimeInProgress field when populating from case
*                      V_4.2 - Modified By - Rajeev Jain - CR-20161209-10535 - Services Excellence HyperCare A - fixed the case dealine logic, by adding new business hours calculation logic
*                      V_4.3 - Modified By - Subhash Garhwal - CR-20161130-10509 - 12/21/2016 - manageTasksForSyndicatedServiceCases method
*                      V_4.4 - Modified By - Mahendra Swarnkar - CR-20161102-10332 - 1/19/2017 - Comment out "CRMfusionDBR101.DB_Globals.triggersDisabled"
*                      V_4.5 - MOdified By - Subhash Garhwal - CR-20160224-9628 - 02/07/2017 - populateCaseFromEmailToCase method updated
*                      V_4.6 - Modified By - Mahendra Swarnkar - CR-20170217-10702 - 03/18/2017 - manageTasksForSyndicatedServiceCases, beforeEventsLogicHandler method updated
*                      V_4.7 - Modified By - Abhinav Sharma - DS114 - 06/02/2017 - updated "beforeEventsLogicHandler" method
                       V_4.8 - Modified By - Rajeev Jain - 07/05/2017(In order of migration tasks of - Releases after Q2CDev3 sandbox refresh date[04/07/2017] in Q2CDev3 sandbox from Test sandbox in order to sync with Q2c Beta Release and Revenue Management
                       V_4.9 - Modified By - Abhinav Sharma - CR-20170222-10716 -4/24/2017 -  manageTasksForSyndicatedServiceCases, beforeEventsLogicHandler method updated
*                                               										   -  Check for the International - Speaker Request cases
*                      V_5.0 - Modified By - Rajeev Jain - 07/05/2017 - Upto Here
*                      V_5.1 - Modified By - Rajeev Jain - 07/28/2017 - Release 60 deployment - Starts Here
*                      V_5.2 - Modified By - Mahendra Swarnkar - CR-20170519-10949 -07/06/2017 -  updated the beforeEventsLogicHandler method to replace the reference of "Platinum Services" field to the "Research Platform" field = Accelerator Member (when "Platinum Services" = checked).
*                      V_5.3 - Modified By - Rajeev Jain - 07/28/2017 - Release 60 deployment - Ends Here
*                      V_5.4 - Modified By - Dipesh Gupta - 08/10/2017- CR-20170705-11059- updated "beforeEventsLogicHandler" method for the Phone Appointment Request and changed the deadlinne filed value accordingly.
*                      V_5.5 - Modified By - Mahendra Swarnkar - 10/12/2017 - CR-20170929-11625 - Apollo Release - Added a new method "populateEntityField"
*                      V_5.6 - Modified By - Victor Hanson - 11/07/2017 - Issue--CR11625--QA--00007247 - Apollo Release - Added populateOwner() method
*                      V_5.7 - Modified By - Subhash Garhwal - 12/08/2017 - CR-20171208-11837 - Update Entitiy logic - 
*                      V_5.8 - Modified By - Abhinav sharma - 10/11/2018 - CR-20180928-12623 checkIfCaseIsWebHelp
*                      V_5.9 - Modified By - Rajeev Jain - 12/12/2018 - CR-20180928-12623 Deployment. 
*                      V_6.0 - Modified By - Victor Hanson - CR-20190429-13055 - commented out reference to syncCaseToMemberSupport
*                      V_6.1 - Modified By - Victor Hanson - CR-20200331-13896 - added updateRegistration method
*                      V_6.2 - Modified By - Abhinav Sharma - 08/13/2020 - CR-20200729-14382 - updated updateRegistration method to add check for Event Type "Cohort" to determine Registration Status
*                      V_6.3 - Modified By - Abhinav Sharma - CR-20200318-13865
*                      V_6.4 - Modified By - Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756
*                      V_6.5 - Modified By - Rajeev Jain - 01/06/2021 - CR-20201207-14727 - Cappex users need to be able to take ownership over cases
*                      V_6.6 - Modified By - Colin McGloin - 01/26/2021 - CR-20210126-14845 - Commented out Code - no longer needed after CR-20200217-13756 changes
*                      V_6.7 - Modified By - Neha Sharma - 03/24/2021 - CR-20210324-15019 - comment the logic which run on the basis 'Rachel Brink', 'Andrea Alvarez' user 
*                      V_6.8 - Modified By - Neha Sharma   - 03/09/2021 - CR-20201207-14726 - Populate the cappex partner success manager on case  
*                      V_6.9 - Modified By - Ayush Gupta - 07/15/2021 - CR-20210625-15243 - Develop automation related to Cases
*                      V_7.0 - Modified By - Ayush Gupta - 07/27/2021 - CR-20210526-15183 - Salesforce Surveys setup
*                      V_7.1 - Modified By - Ayush Gupta - 08/19/2021 - Added new method - notifyAccountOwner
*                      V_7.2 - Modified By - Ayush Gupta - CR-20211018-15525
*		       V_7.3 - Modified By - Ayush Gupta - CR-20211020-15532
*		       V_7.4 - Modified By - Ayush Gupta - CR-20211111-15577
*		       V_7.5 - Modified By - Mahendra Swarnkar - 10/25/2021  - CR-20211018-15522 - Refactor the code of method
*		       V_7.6 - Modified By - Mahendra Swarnkar- CR-20211203-15614
*	               V_7.7 - Modified By - Neha Sharma - CR-20211130-15607
*		       V_7.8 - Modified By - Nikita Kumari - CR-20220119-15720 - 01/20/2022  
**/  
public without sharing class CaseTriggerHelper {
    
    //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: Syndicated Services
    //Static variables
    //public final static String SYNDICATED_SERVICES_CASE_RECORD_TYPE = 'Syndicated Services';
    public final static String ETECH_SUPPORT_CASE_RECORD_TYPE = 'eTech Support';
    
    public static Boolean BYPASS_SURVEY_INVITATION_HELPER = false;
    
    //Merged By - Rajeev Jain - 07/05/2017
    //Added By -Abhinav Sahrma - CR-20170222-10716 - 4/24/2017
    //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756 : International - Speaker Request recordType is deleted.
    //public final static String INTERNATIONAL_SPEAKER_REQUEST = 'International - Speaker Request';
    //Merged By - Rajeev Jain - 07/05/2017 - upto Here
    
    //Added By - Mahendra Swarnkar - 10/20/2016 - CR-20160209-9593 - Starts
    Public static List<Contact> listDummyContact;
    public static Boolean IS_ALREADY_SENT_EMAIL_ONCE = false;
    //Added By - Mahendra Swarnkar - 10/20/2016 - CR-20160209-9593 - Ends here
    
    //Added By - Mahendra Swarnkar - 10/10/2016 - CR-20160607-9905 - Static variable
    public final static String EAB_ONSITE_REQUEST_CASE_RECORD_TYPE = 'EAB Onsite Request';

    //Commented by Mahendra Swarnakr - 03/04/2020 - CR-20200217-13756 - Expert Center, IRC Request
    //Added By - Mahendra Swarnkar - 07/07/2016 - CR-20160609-9913 - Starts From here
    //public final static String EXPERT_CENTER_CASE_RECORD_TYPE = 'Expert Center';
    //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: Talent Development 
    //public final static String TALENT_DEVELOPMENT_CASE_RECORD_TYPE = 'Talent Development';
    //public final static String IRC_REQUEST_CASE_RECORD_TYPE = 'IRC Request';
    
    //Modified By - Mahendra Swarnkar - CR-20170217-10702 - 03/18/2017 - as per the UAT changes updated value From International to 'ABI Research Requests' 
    public final static String INTERNATIONAL_CASE_RECORD_TYPE = 'ABI Research Requests';
    //Modified By - Mahendra Swarnkar - CR-20170217-10702 - 03/18/2017 - Ends here.
    
    //Added By - Mahendra Swarnkar - 07/07/2016 - CR-20160609-9913 -Ends Here
    
    public final static String CASE_STATUS_TENTATIVE = 'Tentative';
    public static Boolean IS_ALREADY_EXECUTED_ONCE = false;
    public static Boolean IS_UPDATE_HAPPENS_ON_INSERT_EVENT = false;
    public static final string CASE_ORIGIN_WEB = 'Web';
    
    //Added By - Abhinav Sharma - 09/29/2016 - CR-20160916-10182
    //Start from here
    public static Boolean IS_RECURSIVE_ACTION_HAPPENS = false;
    //Upto here
    
    //Commented by Mahendra Swarnakr - 03/04/2020 - CR-20200217-13756
    //Added By - Mahendra Swarnkar - 10/17/2016 - CR-20160726-10065
    //public final static String CASE_RECORD_TYPE_EXPERT_CENTER_NAME = 'Expert Center';
    
    //Added by Victor Hanson - CR-20200331-13896
    public static final String CASE_STATUS_CLOSED = 'Closed';

    //Added by Colin McGloin - CR-20211014-15517
    //Flag to contol the trigger execution for Entity Process
    public static Boolean BYPASS_TRIGGER_CASE_ENTITY_POPULATION = false;

    //Added by Colin McGloin - CR-20211014-15517
    //Flag to contol the trigger execution for UpdateSupportProduct Process
    public static Boolean BYPASS_TRIGGER_CASE_UPDATE_SUPPORT_PRODUCT = false;

    //Modified By - Abhinav Sharma - 03/31/2016 - CR-20160224-9632
    //Modified By - Abhinav Sharma - 02/11/2016 - CR-20150925-9267
    //Added By - Abhinav Sharma - CR-20140618-5845 - 07/03/2014
    /**
    *  @description    :   This method is to there to update & validate case records on before events of trigger.
    *                      (i) Method to populate "Member Type" field on case with "RIAMLargeContract" value 
    *			   if Key Notes on Institution record contains 'RIAMLargeContract.  
    * 
    *  @args           :   List of cases, Map of Cases
    * 
    *  @return         :   void
    * 
    **/ 
    public static void beforeEventsLogicHandler(List<Case> newCases, Map<Id,Case> oldMapCases) {

        //Modified by Colin McGloin - CR-20211014-15517 - Too Many SOQL Queries Issue on Email to Case for Intersect & Starfish

        //CR-20140618-5845 changes - Start Here
        //Set to hold the parent Account Id values
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setContactIds = new Set<Id>();
        Set<Id> setMembershipIds = new Set<Id>();
        
        //Loop through new case records
        for(Case cs : newCases) {
            if(cs.AccountId != null)
                setAccountIds.add(cs.AccountId);
            if(cs.ContactId != null)
                setContactIds.add(cs.ContactId);
            if(cs.Membership__c != null)
                setMembershipIds.add(cs.Membership__c);    
        }

        //Added by Colin McGloin - CR-20211014-15517 - Too Many SOQL Queries Issue on Email to Case for Intersect & Starfish
        //Loop through Case Records and see if the logic should run for this Case based on Record Type
        Boolean continueWithLogic = false;

        //Check to see if any of our Sets are populated
        if (setAccountIds.size() > 0){
            continueWithLogic = true;
        }
        if (setContactIds.size() > 0){
            continueWithLogic = true;
        }
        if (setMembershipIds.size() > 0){
            continueWithLogic = true;
        }

        //Check to see if we should continue
        if (continueWithLogic == false){
            return;
        }

        //Set Flag to false before evaluating Record Types
        if (continueWithLogic == true){
            continueWithLogic = false;
        }

        //Moved the logic to check for eligible Case Record Types to the Top
        //Get all record types on case object
        //Map<String, Id> allRecordTypesMap = Util.recordtypemap(Constants.CASE_OBJECT);

        //Add the Map used in Logic
        Map<String, Id> caseRecordTypesMap = Util.recordtypemap(Constants.CASE_OBJECT);

        //Loop through and add the record Types used in Logic to the caseRecordTypesMap
        /*for (String recordTypeLabel : allRecordTypesMap.keySet()){

            //Add the record types we care about
            if (recordTypeLabel.equalsIgnoreCase(System.Label.CASE_NEW_MEMBER_RECORD_TYPE) ||
                recordTypeLabel.equalsIgnoreCase(INTERNATIONAL_CASE_RECORD_TYPE) ||
                recordTypeLabel.equalsIgnoreCase(EAB_ONSITE_REQUEST_CASE_RECORD_TYPE)
            ){
                caseRecordTypesMap.put(recordTypeLabel, allRecordTypesMap.get(recordTypeLabel));
            }

        }*/

        //Debug log to confirm Map Size
        //Set to hold the eligible record type IDs
        Set<Id> eligibleCaseRecordTypes = new Set<Id>();
        Set<Id> otherEligibleCaseRecordTypes = new Set<Id>();

        //Map to hold Other Records Types for Logic in the Method
        Map<Id, String> mapRecordTypes = new Map<Id, String>();
        
        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: Talent Development 
        //Modified By - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651- populating eligibleCaseRecordTypes WITH TD record type Id
        //Looping over map keyset and accordingly populating collection with map retrieved values
        for(String recordTypeLabel : caseRecordTypesMap.keySet()) {
            if(recordTypeLabel != null 
                && (recordTypeLabel.equalsIgnoreCase(System.Label.CASE_NEW_MEMBER_RECORD_TYPE)
                    /*|| recordTypeLabel.equalsIgnoreCase('Talent Development')*/)
                && caseRecordTypesMap.get(recordTypeLabel) != null  
                )
                eligibleCaseRecordTypes.add(caseRecordTypesMap.get(recordTypeLabel));       
            
            //Populating map to hold the case record type Id as key and correspodning record type label as value
            if(String.isNotBlank(recordTypeLabel) 
                && caseRecordTypesMap.containsKey(recordTypeLabel)
                && caseRecordTypesMap.get(recordTypeLabel) != null)
                mapRecordTypes.put(caseRecordTypesMap.get(recordTypeLabel), recordTypeLabel);
                //otherEligibleCaseRecordTypes.add(caseRecordTypesMap.get(recordTypeLabel));
        }

        /*for (Case c : newCases){
            if (eligibleCaseRecordTypes.contains(c.RecordTypeId)){
                continueWithLogic = true;
            }
            if (otherEligibleCaseRecordTypes.contains(c.RecordTypeId)){
                continueWithLogic = true;
            }
        }*/

        //Check to see if we should continue
        /*if (continueWithLogic == false){
            return;
        }*/
        
        //Map to hold the Account records
        Map<Id, Contact> mapContacts = new Map<Id, Contact>();
        
        //Modified By - Mahendra Swarnkar - CR-20170519-10949 -07/06/2017 -  updated the query to replace the reference of "Platinum Services" field to the "Research Platform" field = Accelerator Member (when "Platinum Services" = checked).-- Starts from here
        //Checking for the size value
        if(setContactIds.size() > 0){
            mapContacts = new Map<Id, Contact>([Select Id, Name, AccountId, Account.Research_Platform__c 
                                                From Contact 
                                                WHERE Id IN : setContactIds]);
        }
        //Modified By - Mahendra Swarnkar - CR-20170519-10949 -07/06/2017 -  updated the query to replace the reference of "Platinum Services" field to the "Research Platform" field = Accelerator Member (when "Platinum Services" = checked).-- Ends here
        
        //Map to hold the Account records
        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        
        //Map to hold the account ID as key and associated contract records list as value
        Map<Id, List<Contract__c>> mapAccountWithContracts = new Map<Id, List<Contract__c>>();
        
        //Map to hold the account ID as key and associated subscription records list as value
        Map<Id, List<SBQQ__Subscription__c>> mapAccountWithSubscriptions = new Map<Id, List<SBQQ__Subscription__c>>();
        
        //Checking for the size value
        if(setAccountIds.size() > 0) {
            
            //Modified By - Mahendra Swarnkar - CR-20170519-10949 -07/06/2017 -  updated the query to replace the reference of "Platinum Services" field to the "Research Platform" field = Accelerator Member (when "Platinum Services" = checked).-- Starts from here
            //Added By - Mahendra Swarnkar - 07/07/2016 - CR-20160609-9913 - Added account field 'Platinum_Services__c' in the Query to fetch its value -Starts From here
            //Map to hold the Account records
            mapAccounts = new Map<Id, Account>([SELECT ID, Description, Research_Platform__c, ParentId, Primary_Country__c 
                                                FROM Account 
                                                WHERE ID IN : setAccountIds]);
            //Modified By - Mahendra Swarnkar - CR-20170519-10949 -07/06/2017 -  updated to replace the reference of "Platinum Services" field to the "Research Platform" field = Accelerator Member (when "Platinum Services" = checked). - Ends here
            
            //Loop through subscription records and populating map accordingly
            for(SBQQ__Subscription__c sub : [SELECT ID, Program_Acronym__c, SBQQ__Account__c, SBQQ__StartDate__c, 
                                             SBQQ__EndDate__c, Business_Line__c
                                             FROM SBQQ__Subscription__c
                                             WHERE SBQQ__Account__c != null 
                                             AND SBQQ__Account__c IN : setAccountIds
                                             AND Renewal_Type__c =: System.Label.RENEWAL_TYPE_INITIAL 
                                             AND (
                                                 Business_Line__c =: System.Label.CASE_NEW_MEMBER_PROGRAMS_TYPE 
                                                 OR Business_Line__c =: System.Label.CASE_TD_PROGRAM_TYPE 
                                             )
                                             AND SBQQ__StartDate__c != null
                                             AND SBQQ__EndDate__c != null
                                             AND RecordTypeID != null
                                             AND RecordType.DeveloperName = 'Program'
                                             ORDER By SBQQ__EndDate__c DESC]) { 
                                                 //Checking for parent account presence and populating map accordingly                       
                                                 if(mapAccountWithSubscriptions.containsKey(sub.SBQQ__Account__c)) 
                                                     mapAccountWithSubscriptions.get(sub.SBQQ__Account__c).add(sub);  
                                                 else   
                                                     mapAccountWithSubscriptions.put(sub.SBQQ__Account__c, new List<SBQQ__Subscription__c>{sub});   
                                             }
            
            //Added By - Mahendra Swarnkar - 07/07/2016 - CR-20160609-9913 - Added account field 'Platinum_Services__c' in the Query to fetch its value - Ends here
            
            //Modified By - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651 - Updated the query to also fetch the Contract records whose Busines line is TD                                        
            //Added By - Abhinav Sharma - 02/11/2016 - CR-20150925-9267
            //Start from here
            //Loop through contract records and populating map accordingly
            for(Contract__c cABC : [SELECT ID, Program_Acronym__c, Payer_Account__c, Start__c, End__c, Business_Line__c
                                    FROM Contract__c
                                    WHERE Payer_Account__c != null 
                                    AND Payer_Account__c IN : setAccountIds
                                    AND Type__c =: Constants.CONTRACT_TYPE_NBB 
                                    AND (
                                        Business_Line__c =: System.Label.CASE_NEW_MEMBER_PROGRAMS_TYPE 
                                        OR Business_Line__c = 'TD' 
                                    )
                                    AND Start__c != null
                                    AND End__c != null
                                    ORDER By End__c DESC]) { 
                                        //Checking for parent account presence and populating map accordingly                       
                                        if(mapAccountWithContracts.containsKey(cABC.Payer_Account__c)) 
                                            mapAccountWithContracts.get(cABC.Payer_Account__c).add(cABC);  
                                        else   
                                            mapAccountWithContracts.put(cABC.Payer_Account__c, new List<Contract__c>{cABC});   
                                    }
            //Upto Here
        }
        
        //Map to hold the account ID as key and associated contract records list as value
        Map<Id, Membership__c> mapOfMemberships = new Map<Id, Membership__c>();
        
        //Checking for set size
        if(setMembershipIds.size() > 0) {
            
            mapOfMemberships = new Map<Id, Membership__c>([SELECT ID, End_Date_on_Last_Contract__c
                                                           FROM Membership__c
                                                           WHERE ID IN : setMembershipIds
                                                          ]);
        }
        
        //Modifed by Colin McGloin - 10/14/2021 - CR-20211014-15517 - Moved Logic to the top of the Class to limit SOQL Queries Usage
        //Get all record types on case object
        //Map<String, Id> caseRecordTypesMap = Util.recordtypemap(Constants.CASE_OBJECT);
        
        //Set to hold the eligible record type IDs
        //Set<Id> eligibleCaseRecordTypes = new Set<Id>();
        
        //Get case record types
        // Map<Id, String> mapRecordTypes = new Map<Id, String>();
        
        // //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: Talent Development 
        // //Modified By - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651- populating eligibleCaseRecordTypes WITH TD record type Id
        // //Looping over map keyset and accordingly populating collection with map retrieved values
        // for(String recordTypeLabel : caseRecordTypesMap.keySet()) {
        //     if(recordTypeLabel != null 
        //        && (recordTypeLabel.equalsIgnoreCase(System.Label.CASE_NEW_MEMBER_RECORD_TYPE)
        //            /*|| recordTypeLabel.equalsIgnoreCase('Talent Development')*/)
        //        && caseRecordTypesMap.get(recordTypeLabel) != null  
        //       )
        //         eligibleCaseRecordTypes.add(caseRecordTypesMap.get(recordTypeLabel));       
            
        //     //Populating map to hold the case record type Id as key and correspodning record type label as value
        //     if(String.isNotBlank(recordTypeLabel) 
        //        && caseRecordTypesMap.containsKey(recordTypeLabel)
        //        && caseRecordTypesMap.get(recordTypeLabel) != null)
        //         mapRecordTypes.put(caseRecordTypesMap.get(recordTypeLabel), recordTypeLabel);
        // }            
        
        //Loop through case new records
        for(Case c : newCases) {
            
            //Checking if we are having any record in map corresponding to the case record parent account Id value or not
            //In case if record exist in map then populate "Member Type" field on case with "RIAMLargeContract" value 
            //if Key Notes on Institution record contains 'RIAMLargeContract'.  
            if(c.AccountId != null) {
                
                //Checking for value in the map
                if(mapAccounts != null && mapAccounts.get(c.AccountId) != null) {
                    
                    //Checking for the description field value and accordingly populating "Member Type" field
                    if(mapAccounts.get(c.AccountId).Description != null 
                       && mapAccounts.get(c.AccountId).Description.contains(Constants.RIAM_LARGE_CONTRACTS)) {
                           c.Member_Type__c = Constants.RIAM_LARGE_CONTRACTS;
                       } else {
                           c.Member_Type__c = '';
                       }
                    
                    //Added By - Abhinav Sharma - CR-20170217-10702
                    //Start from here
                    //Checking for "Parent Account" field value
                    //If "Institution Name" is having a "Parent Account" associated on it then 
                    //populate case "Parent System" field with "Parent Account" reference 
                    //otherwise will have null as a value.
                    if(mapAccounts.get(c.AccountId).ParentId != null) {
                        c.Parent_System__c = mapAccounts.get(c.AccountId).ParentId;     
                    } else {
                        c.Parent_System__c = null;
                    }
                    
                    //Populate "Country" field with associated institution fetched "Primary Country" field value
                    if(String.isNotBlank(mapAccounts.get(c.AccountId).Primary_Country__c)) {
                        c.Country__c = mapAccounts.get(c.AccountId).Primary_Country__c;
                    } else {
                        c.Country__c = '';
                    }
                    //Upto here
                    
                } else {
                    c.Member_Type__c = '';
                    c.Parent_System__c = null;
                    c.Country__c = '';
                }
                
                //Modified By - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651
                //Added By - Abhinav Sharma - 02/11/2016 - CR-20150925-9267
                //Start from here
                //Temporary variable to hold the contracts program acronyms Concatenated string literal value
                String programAcromyms = '';
                String programAcromymsForTD = '';   
                
                //Checking for the eligible case record types
                if(eligibleCaseRecordTypes != null && eligibleCaseRecordTypes.size() > 0
                   && eligibleCaseRecordTypes.contains(c.RecordTypeId)) {
                       
                       //Checking for the eligibility
                       if(mapAccountWithSubscriptions != null && mapAccountWithSubscriptions.containsKey(c.AccountId) 
                          && mapAccountWithSubscriptions.get(c.AccountId) != null 
                          && mapAccountWithSubscriptions.get(c.AccountId).size() > 0) {
                              
                              //Checking case "CreatedDate" field for null value
                              if(c.CreatedDate != null) {
                                  
                                  //getting created date GTM time zone value (for comparision in between value)    
                                  Date myDate = Date.newInstance(c.CreatedDate.year(), c.CreatedDate.month(), c.CreatedDate.day());
                                  Time myTime = Time.newInstance(0, 0, 0, 0);
                                  DateTime dt = DateTime.newInstanceGMT(myDate, myTime);
                                  
                                  //Loop through subscription records
                                  for(SBQQ__Subscription__c sub : mapAccountWithSubscriptions.get(c.AccountId)) {
                                      
                                      //Checking and validating contract "Start" and "End" dates with respect to the case record 
                                      //which is in current context
                                      if(sub.SBQQ__StartDate__c <= dt && sub.SBQQ__EndDate__c >= dt) {
                                          
                                          if(mapRecordTypes.get(c.RecordTypeId).equalsIgnoreCase(System.Label.CASE_NEW_MEMBER_RECORD_TYPE) 
                                             && sub.Business_Line__c == System.Label.CASE_NEW_MEMBER_PROGRAMS_TYPE)
                                              programAcromyms += sub.Program_Acronym__c + Constants.COMMA;
                                          
                                          if(mapRecordTypes.get(c.RecordTypeId).equalsIgnoreCase(System.Label.CASE_TALENT_DEVELOPMENT_RECORD_TYPE) 
                                             && sub.Business_Line__c == System.Label.CASE_TD_PROGRAM_TYPE)
                                              programAcromymsForTD += sub.Program_Acronym__c + Constants.COMMA;    
                                      }
                                  }
                              } else {
                                  
                                  //Loop through contract records
                                  for(SBQQ__Subscription__c ss : mapAccountWithSubscriptions.get(c.AccountId)) {
                                      
                                      //Checking and validating contract "Start" and "End" dates with respect to the case record 
                                      //which is in current context
                                      if(ss.SBQQ__StartDate__c <= System.today() && ss.SBQQ__EndDate__c >= System.today()) {
                                          if(mapRecordTypes.get(c.RecordTypeId).equalsIgnoreCase(System.Label.CASE_NEW_MEMBER_RECORD_TYPE))
                                              programAcromyms += ss.Program_Acronym__c + Constants.COMMA;  
                                          
                                          if(mapRecordTypes.get(c.RecordTypeId).equalsIgnoreCase(System.Label.CASE_TALENT_DEVELOPMENT_RECORD_TYPE))
                                              programAcromymsForTD += ss.Program_Acronym__c + Constants.COMMA;
                                      }
                                  }
                              }
                              
                              //Removing additional "," from the end of concatenated string literal (if exists)
                              if(programAcromyms != '') {
                                  
                                  //Trim the white spaces
                                  programAcromyms = programAcromyms.trim();
                                  
                                  //Checking if last character of string literal is "Comma" or not
                                  if(programAcromyms.substring((programAcromyms.length()-1), programAcromyms.length()) == Constants.COMMA)
                                      programAcromyms = programAcromyms.removeEnd(Constants.COMMA);
                              }
                              if(programAcromymsForTD != '') {
                                  
                                  //Trim the white spaces
                                  programAcromymsForTD = programAcromymsForTD.trim();
                                  
                                  //Checking if last character of string literal is "Comma" or not
                                  if(programAcromymsForTD.substring((programAcromymsForTD.length()-1), programAcromymsForTD.length()) == Constants.COMMA)
                                      programAcromymsForTD = programAcromymsForTD.removeEnd(Constants.COMMA);
                              }
                          }  else {
                              
                              //Checking for eligible contract records presence and then accordingly concatenating "Program Acronyms" string literal
                              if(mapAccountWithContracts != null && mapAccountWithContracts.containsKey(c.AccountId) 
                                 && mapAccountWithContracts.get(c.AccountId) != null 
                                 && mapAccountWithContracts.get(c.AccountId).size() > 0) {
                                     
                                     //Checking case "CreatedDate" field for null value
                                     if(c.CreatedDate != null) {
                                         
                                         //getting created date GTM time zone value (for comparision in between value)    
                                         Date myDate = Date.newInstance(c.CreatedDate.year(), c.CreatedDate.month(), c.CreatedDate.day());
                                         Time myTime = Time.newInstance(0, 0, 0, 0);
                                         DateTime dt = DateTime.newInstanceGMT(myDate, myTime);
                                         
                                         //Loop through contract records
                                         for(Contract__c conABC : mapAccountWithContracts.get(c.AccountId)) {
                                             
                                             //Checking and validating contract "Start" and "End" dates with respect to the case record 
                                             //which is in current context
                                             if(conABC.Start__c <= dt && conABC.End__c >= dt) {
                                                 
                                                 if(mapRecordTypes.get(c.RecordTypeId).equalsIgnoreCase(System.Label.CASE_NEW_MEMBER_RECORD_TYPE) && conABC.Business_Line__c == 'RI')
                                                     programAcromyms += conABC.Program_Acronym__c + Constants.COMMA;
                                                 
                                                 //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: Talent Development 
                                                 if(/*mapRecordTypes.get(c.RecordTypeId).equalsIgnoreCase('Talent Development') &&*/ conABC.Business_Line__c == 'TD')
                                                     programAcromymsForTD += conABC.Program_Acronym__c + Constants.COMMA;    
                                             }
                                         }
                                     } else {
                                         
                                         //Loop through contract records
                                         for(Contract__c coABC : mapAccountWithContracts.get(c.AccountId)) {
                                             
                                             //Checking and validating contract "Start" and "End" dates with respect to the case record 
                                             //which is in current context
                                             if(coABC.Start__c <= System.today() && coABC.End__c >= System.today()) {
                                                 if(mapRecordTypes.get(c.RecordTypeId).equalsIgnoreCase(System.Label.CASE_NEW_MEMBER_RECORD_TYPE))
                                                     programAcromyms += coABC.Program_Acronym__c + Constants.COMMA;  
                                                 
                                                 //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: Talent Development 
                                                 /*if(mapRecordTypes.get(c.RecordTypeId).equalsIgnoreCase('Talent Development'))
                                                     programAcromymsForTD += coABC.Program_Acronym__c + Constants.COMMA;*/
                                             }
                                         }                            
                                     }    
                                     
                                     //Removing additional "," from the end of concatenated string literal (if exists)
                                     if(programAcromyms != '') {
                                         
                                         //Trim the white spaces
                                         programAcromyms = programAcromyms.trim();
                                         
                                         //Checking if last character of string literal is "Comma" or not
                                         if(programAcromyms.substring((programAcromyms.length()-1), programAcromyms.length()) == Constants.COMMA)
                                             programAcromyms = programAcromyms.removeEnd(Constants.COMMA);
                                     }
                                     if(programAcromymsForTD != '') {
                                         
                                         //Trim the white spaces
                                         programAcromymsForTD = programAcromymsForTD.trim();
                                         
                                         //Checking if last character of string literal is "Comma" or not
                                         if(programAcromymsForTD.substring((programAcromymsForTD.length()-1), programAcromymsForTD.length()) == Constants.COMMA)
                                             programAcromymsForTD = programAcromymsForTD.removeEnd(Constants.COMMA);
                                     }
                                 }
                          }
                   }    
                
                //Populating "New_Member_Programs_RI__c" field with "Program Acronym" concatenated string literal value
                c.New_Member_Programs_RI__c = programAcromyms;
                //Spring CleanUp
                //c.New_Member_Programs_TD__c = programAcromymsForTD;
                
                //Upto here
                
            } else {
                c.Member_Type__c = '';
                c.New_Member_Programs_RI__c = '';
                //Spring CleanUp
                //c.New_Member_Programs_TD__c = '';
            } 
            //Upto Here
            
            
            //Added by - Abhinav Sharma - 06/02/2017 - DS114
            //Start from here
            //Populating "Renewal_Date__c" field value on the case instance
            //Checking if membership reference is populated on the case instance or not
            if(c.Membership__c != null && mapOfMemberships.containsKey(c.Membership__c))
                c.Renewal_Date1__c = mapOfMemberships.get(c.Membership__c).End_Date_on_Last_Contract__c;
            else
                c.Renewal_Date1__c = null;
            //Upto here
            
            //Merged By - Rajeev Jain - 07/05/2017
            //Added By - Abhinav Sharma - 4/24/2017 - CR-20170222-10716 - Start here
            //Populating Deadline field value for ABI Research Requests record types as follows:-
            //Setting for the Deadline fields based on the "Request Type" field value
            if(caseRecordTypesMap.containsKey(INTERNATIONAL_CASE_RECORD_TYPE)
               && caseRecordTypesMap.get(INTERNATIONAL_CASE_RECORD_TYPE) != null 
               && c.RecordTypeId == caseRecordTypesMap.get(INTERNATIONAL_CASE_RECORD_TYPE)
               && String.isNotBlank(c.Request_Type__c)  
              ) {
                  
                  //Check for Request_Type__c field value is "Strategic Mapping Request"
                  if(c.Request_Type__c.equalsIgnoreCase(System.Label.Request_Type_Strategic_Mapping_Request)) 
                      
                      //Populate Deadline value
                      c.Deadline__c = Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.ABI_Research_Requests_DeadLine3));
                  
                  //Check for Request_Type__c field value is "Expert Call"
                  else if(c.Request_Type__c.equalsIgnoreCase(System.Label.Request_Type_Expert_Call))  
                      
                      //Populate Deadline value
                      c.Deadline__c = Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.ABI_Research_Requests_DeadLine1));
                  
                  //Check for Request_Type__c field value is "Check-in Call"  
                  else if(c.Request_Type__c.equalsIgnoreCase(System.Label.Request_Type_Check_In_Call))  
                      
                      //Populate Deadline value
                      c.Deadline__c = Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.ABI_Research_Requests_DeadLine1));
                  
                  //Check for Request_Type__c field value is "Webinar"
                  else if(c.Request_Type__c.equalsIgnoreCase(System.Label.Request_Type_Webinar))  
                      
                      //Populate Deadline value
                      c.Deadline__c = Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.ABI_Research_Requests_DeadLine1));
                  
                  //Check for Request_Type__c field value is "Document Review"      
                  else if(c.Request_Type__c.equalsIgnoreCase(System.Label.Request_Type_Document_Review))  
                      
                      //Populate Deadline value
                      c.Deadline__c = Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.ABI_Research_Requests_DeadLine4));  
                  
                  //Check for Request_Type__c field value is "Networking Request"  
                  else if(c.Request_Type__c.equalsIgnoreCase(System.Label.Request_Type_Networking_Request))  
                      
                      //Populate Deadline value
                      c.Deadline__c = Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.ABI_Research_Requests_DeadLine2));
                  
                  //Check for Request_Type__c field value is "Onboarding Call"  
                  else if(c.Request_Type__c.equalsIgnoreCase(System.Label.Request_Type_Onboarding_Call))  
                      
                      //Populate Deadline value
                      c.Deadline__c = Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.ABI_Research_Requests_DeadLine1));  
                  
                  //Check for Request_Type__c field value is "Other"
                  else if(c.Request_Type__c.equalsIgnoreCase(System.Label.Request_Type_Other))  
                      
                      //Populate Deadline value
                      c.Deadline__c = Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.ABI_Research_Requests_DeadLine2));                        
              }
            //Added By - Abhinav Sharma - 4/24/2017 - CR-20170222-10716 - Stop here
            //Merged By - Rajeev Jain - 07/05/2017 - upto here
        }
        
        //CR-20140629-6015 - Changes Start From Here
        //Code will only be executed for case record "Insert" event
        if(oldMapCases == null) {
            
            //Perform the below logic only & only if above queries record type exists in the system
            if(caseRecordTypesMap != null && caseRecordTypesMap.size() > 0) {
                
                //Modified By - Mahendra Swarnkar- CR-20160609-9913 - 7/7/2016 - 
                //Starts from here - Added the following logic:-
                //1) Pass the company holidays as an argument in the AddBusinessDays method
                //and extnding the deadline functionality for expert center and Talent Development Case record types
                //2) Setting Deadline to 3 business days for "Syndicated Services" and "Expert Cnter" Case type records
                //Loop through new case records
                for(Case c : newCases) {
                    
                    //Check for Record type 
                    if(c.RecordTypeId != null){
                        
                        //Commneted by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756
                        //Setting Deadline to 3 business days for records of "IRC Request" Case record types,
                        /*if(caseRecordTypesMap.containsKey(IRC_REQUEST_CASE_RECORD_TYPE)
                           && caseRecordTypesMap.get(IRC_REQUEST_CASE_RECORD_TYPE) != null 
                           && c.RecordTypeId == caseRecordTypesMap.get(IRC_REQUEST_CASE_RECORD_TYPE)
                          ) {
                              c.Deadline__c = Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.IRC_DeadLine_Default));
                          }*/
                        
                        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: Talent Development 
                        //Modified By - Mahendra Swarnkar - CR-20170519-10949 -07/06/2017 -  updated to replace the reference of "Platinum Services" field to the "Research Platform" field = Accelerator Member (when "Platinum Services" = checked).-- Starts from here
                        //Modified By - Mahendra Swarnkar - CR-20160803-10082 - 08/23/2016 - Starts from here
                        //Setting Deadline to 3 business days for records of Talent Development record types, 
                        //if Platinum Services on related Account is true
                        /*if(caseRecordTypesMap.containsKey(TALENT_DEVELOPMENT_CASE_RECORD_TYPE)
                           && caseRecordTypesMap.get(TALENT_DEVELOPMENT_CASE_RECORD_TYPE) != null 
                           && c.RecordTypeId == caseRecordTypesMap.get(TALENT_DEVELOPMENT_CASE_RECORD_TYPE)
                           && 
                           (
                               (c.AccountId != null
                                && mapAccounts != null 
                                && mapAccounts.size() > 0 
                                && mapAccounts.containsKey(c.AccountId)
                                && mapAccounts.get(c.AccountId) != null
                                && mapAccounts.get(c.AccountId).Research_Platform__c == 'Accelerator Member'
                               )
                               || 
                               (c.ContactId != null
                                && mapContacts != null 
                                && mapContacts.size() > 0 
                                && mapContacts.containsKey(c.ContactId)
                                && mapContacts.get(c.ContactId) != null
                                && mapContacts.get(c.ContactId).AccountId != null
                                && mapContacts.get(c.ContactId).Account.Research_Platform__c == 'Accelerator Member'
                               )
                           )
                          ) {
                              c.Deadline__c = Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.TalentDevelopment_DeadLine_Platinum_True_Default));
                          }*/
                        //Modified By - Mahendra Swarnkar - CR-20170519-10949 -07/06/2017 -  updated to replace the reference of "Platinum Services" field to the "Research Platform" field = Accelerator Member (when "Platinum Services" = checked).-- Ends here
                        
                        //Populating Deadline field value for Syndicated services record types as follows:-
                        //if Platinum Services on related Account is true, then Setting Deadline to 3 business days after 
                        //else set to 7 business days after, as default value
                        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: Syndicated Services - Start Here
                        /*if(caseRecordTypesMap.containsKey(SYNDICATED_SERVICES_CASE_RECORD_TYPE)
                           && caseRecordTypesMap.get(SYNDICATED_SERVICES_CASE_RECORD_TYPE) != null 
                           && c.RecordTypeId == caseRecordTypesMap.get(SYNDICATED_SERVICES_CASE_RECORD_TYPE)
                          ){
                              //Modified By - Mahendra Swarnkar - CR-20170519-10949 -07/06/2017 -  updated to replace the reference of "Platinum Services" field to the "Research Platform" field = Accelerator Member (when "Platinum Services" = checked).-- Starts from here
                              if(
                                  (c.AccountId != null
                                   && mapAccounts != null 
                                   && mapAccounts.size() > 0 
                                   && mapAccounts.containsKey(c.AccountId)
                                   && mapAccounts.get(c.AccountId) != null
                                   && mapAccounts.get(c.AccountId).Research_Platform__c == 'Accelerator Member'
                                  )
                                  || 
                                  (c.ContactId != null
                                   && mapContacts != null 
                                   && mapContacts.size() > 0 
                                   && mapContacts.containsKey(c.ContactId)
                                   && mapContacts.get(c.ContactId) != null
                                   && mapContacts.get(c.ContactId).AccountId != null
                                   && mapContacts.get(c.ContactId).Account.Research_Platform__c == 'Accelerator Member'
                                  )
                              ) {
                                  c.Deadline__c = Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.SyndicatedServices_DeadLine_Platinum_True_Default));
                              }
                              //Modified By - Mahendra Swarnkar - CR-20170519-10949 -07/06/2017 -  updated to replace the reference of "Platinum Services" field to the "Research Platform" field = Accelerator Member (when "Platinum Services" = checked).-- Ends here
                              
                              else{
                                  
                                  c.Deadline__c = Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.SyndicatedServices_DeadLine_Platinum_False_Default));
                              }
                          }*/
                        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: Syndicated Services - END HERE
                        
                        //Modified By - Mahendra Swarnkar - 11/17/2016 - CR-20161019-10240 - Commented out the code since no deadline auto population required - Starts from here 
                        /*
                        //Populating Deadline field value for Expert Center record types as follows:-
                        //if Platinum Services on related Account is true, then Setting Deadline to 3 business days after 
                        //else if origin is Member Priority then, set to 7 business days after
                        //else set to 5 business days after, as a default value
                        if(caseRecordTypesMap.containsKey(EXPERT_CENTER_CASE_RECORD_TYPE)
                        && caseRecordTypesMap.get(EXPERT_CENTER_CASE_RECORD_TYPE) != null 
                        && c.RecordTypeId == caseRecordTypesMap.get(EXPERT_CENTER_CASE_RECORD_TYPE)    
                        ){
                        if(
                        (c.AccountId != null
                        && mapAccounts != null 
                        && mapAccounts.size() > 0 
                        && mapAccounts.containsKey(c.AccountId)
                        && mapAccounts.get(c.AccountId) != null
                        && mapAccounts.get(c.AccountId).Platinum_Services__c == true
                        )
                        || 
                        (c.ContactId != null
                        && mapContacts != null 
                        && mapContacts.size() > 0 
                        && mapContacts.containsKey(c.ContactId)
                        && mapContacts.get(c.ContactId) != null
                        && mapContacts.get(c.ContactId).AccountId != null
                        && mapContacts.get(c.ContactId).Account.Platinum_Services__c == true
                        )
                        ) {
                        //Added as per the UAT Changes -CR-20160803-10082-:- the condition to auto populate the deadline if it is not < 3 Businesss days
                        if(c.Deadline__c >= Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.ExpertCenter_NoOfBusinessDaysToDeadLine_Priorty_Platinum_True) , null))
                        c.Deadline__c = Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.ExpertCenter_DeadLine_Platinum_True_Default));
                        }
                        else {
                        
                        //Check for Case requested from ie. if origin of Case request is from Member Priority
                        if(String.isNotBlank(c.Origin) 
                        && c.Origin == System.Label.ORIGIN_MEMBER_PRIORITY) {
                        
                        //Added as per the UAT Changes -CR-20160803-10082-:- the condition to auto populate the deadline if it is not < 7 Businesss days
                        if(c.Deadline__c >= Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.ExpertCenter_NoOfBusinessDaysToDeadLine_Priorty_MemberPriority) , holidays))
                        c.Deadline__c = Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.ExpertCenter_DeadLine_Platinum_False_MemberPriority_Default), holidays);
                        }
                        
                        //Check for Case requeste is a Inbound Request ie. if origin of request is not Member Priority
                        else {
                        
                        //Added as per the UAT Changes -CR-20160803-10082-:- the condition to auto populate the deadline if it is not < 5 Businesss days
                        if(c.Deadline__c >= Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.ExpertCenter_NoOfBusinessDaysToDeadLine_Priorty_Inbound) , holidays))
                        c.Deadline__c = Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.ExpertCenter_DeadLine_Platinum_False_Inbound_Default), holidays);
                        }
                        }
                        }
                        */
                        
                        //Modified By - Mahendra Swarnkar - CR-20160803-10082 - 08/23/2016 - Ends here
                        //Modified By - Mahendra Swarnkar - 11/17/2016 - CR-20161019-10240 - Commented out the code since no deadline auto population required - Ends here
                    }
                }
                //Modified By - Mahendra Swarnkar- CR-20160609-9913 -passes the company holidays as an argument in the AddBusinessDays method and extnding the deadline functionality for expert center and Talent Development Case record types - 7/7/2016 -Ends here
            }
            
            //Setting flag value to true
            IS_UPDATE_HAPPENS_ON_INSERT_EVENT = true;
        }
        //Upto Here
        
        //Added By - Abhinav Sharma - 11/26/2015 - CR-20151118-9394
        //Start from here         
        //Apply this logic only to the record type Syndicated Services.
        //a) On Case record(s) insert:-
        //If Status = Tentative AND "Date of Presentation" is having non-null value with it.
        //then populate " Hold Expires" field with a value 10 business days from today.
        //b) On Case record(s) update:-
        //If the "Date of Presentation" field is updated while the Status=Tentative, the expiration date should also 
        //be updated accordingly.
        //If the Status is set to anything other than Tentative, the expiration date should be cleared out.
        //Set to hold the eligible record type Ids
        Set<Id> setOfEligibleRecordTypes = new Set<Id>();
        
        //Merged By - Rajeev Jain - 07/05/2017
        //Added By - Abhinav Sharma - CR-20170222-10716 - For checking for "INTERNATIONAL_SPEAKER_REQUEST" cases
        //Commnetd by Mahendra Sarnkar - 02/04/2020 - CR-20200217-13756  : INTERNATIONAL SPEAKER REQUEST recordType is deleted
        /*if(caseRecordTypesMap != null
           && caseRecordTypesMap.containsKey(INTERNATIONAL_SPEAKER_REQUEST)
           && caseRecordTypesMap.get(INTERNATIONAL_SPEAKER_REQUEST) != null)
            setOfEligibleRecordTypes.add(caseRecordTypesMap.get(INTERNATIONAL_SPEAKER_REQUEST));*/
        //Merged By - Rajeev Jain - 07/05/2017 - upto here  
        
        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: Syndicated Services
        //Checking for key presence in the map and then adding corresponding record type Id value in the set
        /*if(caseRecordTypesMap != null 
           && caseRecordTypesMap.containsKey(SYNDICATED_SERVICES_CASE_RECORD_TYPE)
           && caseRecordTypesMap.get(SYNDICATED_SERVICES_CASE_RECORD_TYPE) != null)
            setOfEligibleRecordTypes.add(caseRecordTypesMap.get(SYNDICATED_SERVICES_CASE_RECORD_TYPE));
        */
        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: Syndicated Services
        
        //Added By - Mahendra Swarnkar - 10/10/2016 - CR-20160607-9905 - One more record type "EAB Onsite Request" in the set to populate Hold_Expires__c
        if(caseRecordTypesMap != null
           && caseRecordTypesMap.containsKey(EAB_ONSITE_REQUEST_CASE_RECORD_TYPE)
           && caseRecordTypesMap.get(EAB_ONSITE_REQUEST_CASE_RECORD_TYPE) != null)
            setOfEligibleRecordTypes.add(caseRecordTypesMap.get(EAB_ONSITE_REQUEST_CASE_RECORD_TYPE));
        
        //Checking set for size value
        if(setOfEligibleRecordTypes.size() > 0) {
            
            //Loop through case records
            for(Case ca : newCases) {
                
                //Check for record type SYNDICATED SERVICES on case 
                if(ca.RecordTypeId != null && setOfEligibleRecordTypes.contains(ca.RecordTypeId)) {
                    
                    //Check for case status to tentative
                    if(String.isNotBlank(ca.Status) && ca.Status == CASE_STATUS_TENTATIVE) {
                        
                        //Insert OR Update use case
                        if(oldMapCases == null
                           || 
                           (
                               oldMapCases != null 
                               && 
                               (ca.Date_of_Presentation__c != oldMapCases.get(ca.Id).Date_of_Presentation__c
                                ||
                                ca.Hold_Expires__c != oldMapCases.get(ca.Id).Hold_Expires__c
                                ||
                                ca.Status != oldMapCases.get(ca.Id).Status
                               )
                           ) 
                          ) {
                              
                              //Check for null for Date of presentation
                              //Populate the Hold Expire field value on case
                              if(ca.Date_of_Presentation__c != null) {
                                  //Modified By - Mahendra Swarnkar- CR-20160609-9913 -passes the company holidays as an argument in the AddBusinessDays method - 7/7/2016 -Starts from here
                                  //Modified By - Mahendra Swarnkar- CR-20211203-15614 - Update the Add business days to 7 from 10 - 06/12/2021
                                  ca.Hold_Expires__c = Util.AddBusinessDays(System.today(), 7);
                              }
                              //Modified By - Mahendra Swarnkar- CR-20160609-9913 -passes the company holidays as an argument in the AddBusinessDays method - 7/7/2016 -Ends here
                              else {
                                  ca.Hold_Expires__c = null;
                              }
                              
                          }
                    } else {
                        ca.Hold_Expires__c = null;
                    }
                }
            }
        }
        //Upto here
        
        //Added By - Abhinav Sharma - 03/31/2016 - CR-20160224-9632
        //Start from here        
        //This code will only execute in the update use cases
        if(oldMapCases != null && !IS_ALREADY_EXECUTED_ONCE && !IS_UPDATE_HAPPENS_ON_INSERT_EVENT) {
            
            // get the ABC Dataloader profile id
            Id dataloaderProfileId = label.ABC_Dataloader_Profile_Id;
            
            //Bypass the below written logic for ABC Dataloader profile users
            //This way data update can take place over the existing records
            if (dataloaderProfileId != null 
                && UserInfo.getProfileId() == dataloaderProfileId) {
                    
                    //Do nothing and just bypass the validation logic        
                    
                } else {
                    
                    //Setting flag value to true
                    IS_ALREADY_EXECUTED_ONCE = true;
                    
                    //Modified By - Rajeev Jain - 01/06/2021 - CR-20201207-14727 - Cappex users need to be able to take ownership over cases
                    //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT Support Request
                    //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT Data Load
                    //Loop through case records
                    /*for(Case cse : newCases) {
                        
                        //Checking record for eligibilty and throwing an error accordingly
                        if(cse.RecordTypeId != null 
                           && mapRecordTypes.containsKey(cse.RecordTypeId)
                           && mapRecordTypes.get(cse.RecordTypeId) != null
                           //&& (mapRecordTypes.get(cse.RecordTypeId) == Constants.RECORD_TYPE_CASE_PT_DATA_LOAD
                              // || mapRecordTypes.get(cse.RecordTypeId) == Constants.RECORD_TYPE_CASE_PT_SUPPORT_REQUEST)
                            //Spring CleanUp
                           // && cse.Button_Used__c == false
                           && (
                               (
                                   oldMapCases.get(cse.Id).Status == System.Label.CASE_NEW_STATUS_PT_SUPPORT_REQUEST
                                   &&
                                   cse.Status != oldMapCases.get(cse.Id).Status
                               )
                               || (cse.OwnerId != oldMapCases.get(cse.Id).OwnerId)
                               || (cse.Tier_I_Support_Analyst__c != oldMapCases.get(cse.Id).Tier_I_Support_Analyst__c)
                           )
                          ) {
                              cse.addError(System.Label.ERROR_CASE_DIRECT_FIELDS_CHANGES);                    
                          } 
                        
                        //Spring CleanUp
                        //if(cse.Button_Used__c == true)
                          //  cse.Button_Used__c = false; 
                        
                    }*/ // End Here
                } 
        }
        //Upto Here
        
        //Added By -Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651 - Starts from here
        //Method Call to populate the Case fields on before event
        populateCaseFields(newCases, oldMapCases);
        //Added By -Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651 - Ends here
        
        //Modified By - Rajeev Jain - CR-20161209-10535 - Services Excellence HyperCare A - fixed the case dealine logic and commentout below method
        //Calling method to validate case deadline and Populate #Business Days to Deadline
        //validateAndPopulateCaseData(newCases, oldMapCases);
        
        //Replaced this variable in order to check case dealine with
        //cs.Num_Business_Days_to_Deadline__c
        Integer businessDays = 0;     
        
        //Added By - Mahendra Swarnkar- CR-20160609-9913 - 7/12/2016
        //Starts from here
        //Loop through new case records for porforming validation over them
        for(Case cs : newCases) {
            
            //Calculate business Days In Between of Case Created date and Deadline Date
            //Decide Start date in order to calculate days difference beween
            Date createdDate;
            
            //If case is newly creating or inserting created date will be today
            if(oldMapCases == null)
                createdDate = Date.today().addDays(Integer.valueOf(System.Label.ExpertCenter_AddOn_To_BusinessDaysCalculation));
            else
                createdDate = cs.CreatedDate.date().addDays(Integer.valueOf(System.Label.ExpertCenter_AddOn_To_BusinessDaysCalculation));
            
            //Calculate Business Days only if Dealine field is not null
            if(cs.Deadline__c != null){   
                businessDays = Util.CalculateBusinessDays(createdDate, cs.Deadline__c, true, false);
                
                //populate No of Business Days
                cs.Num_Business_Days_to_Deadline__c = businessDays;
            }
            //Modified By - Rajeev Jain - CR-20161209-10535 - Services Excellence HyperCare A - fixed the case dealine logic - upto here 
            
            //Commented by Mahendra Swarnkar -03/04/2020 - CR-20200217-13756 - 	Expert Center
            //Checking if case is of expert center/international record type
            if(
                /*(
                    caseRecordTypesMap.containsKey(EXPERT_CENTER_CASE_RECORD_TYPE)
                    && caseRecordTypesMap.get(EXPERT_CENTER_CASE_RECORD_TYPE) != null 
                    && cs.RecordTypeId == caseRecordTypesMap.get(EXPERT_CENTER_CASE_RECORD_TYPE)
                )
                ||*/
                (
                    caseRecordTypesMap.containsKey(INTERNATIONAL_CASE_RECORD_TYPE)
                    && caseRecordTypesMap.get(INTERNATIONAL_CASE_RECORD_TYPE) != null 
                    && cs.RecordTypeId == caseRecordTypesMap.get(INTERNATIONAL_CASE_RECORD_TYPE)
                )
            ) {
                //Checking for the conditions when the deadline field based validation logic
                
                
                //will bypass for expert center/international cases
                if(cs.AccountId != null) {
                    
                    //Modified By - Mahendra Swarnkar - CR-20170519-10949 -07/06/2017 -  updated to replace the reference of "Platinum Services" field to the "Research Platform" field = Accelerator Member (when "Platinum Services" = checked).-- Starts from here
                    //Bypass the valiation logic if parent institution is of "Platinum Services" type
                    if(mapAccounts != null 
                       && mapAccounts.size() > 0 
                       && mapAccounts.containsKey(cs.AccountId)
                       && mapAccounts.get(cs.AccountId) != null
                       && mapAccounts.get(cs.AccountId).Research_Platform__c == 'Accelerator Member'
                      )
                        continue;
                } else {
                    
                    //Bypass the valiation logic if parent institution is of "Platinum Services" type
                    if(cs.ContactId != null
                       && mapContacts != null 
                       && mapContacts.size() > 0 
                       && mapContacts.containsKey(cs.ContactId)
                       && mapContacts.get(cs.ContactId) != null
                       && mapContacts.get(cs.ContactId).AccountId != null
                       && mapContacts.get(cs.ContactId).Account.Research_Platform__c == 'Accelerator Member'
                      )
                        continue; 
                    //Modified By - Mahendra Swarnkar - CR-20170519-10949 -07/06/2017 -  updated to replace the reference of "Platinum Services" field to the "Research Platform" field = Accelerator Member (when "Platinum Services" = checked).-- Ends here
                }
                
                //Moified By - Mahendra Swarnkar - CR-20170217-10702 - Start here
                //Deadline_Reason_required
                
                //Merged By - Rajeev Jain - 07/05/2017
                //Modified By - Abhinav Sharma - CR-20170222-10716 - Bypass logic of the Deadline_Reason_required for INTERNATIONAL_CASE_RECORD_TYPE
                //Commented by Mahendra Swarnkar -03/04/2020 - CR-20200217-13756 - Start Here
                /*if (
                    String.isBlank(cs.Deadline_Reason__c)
                    && cs.Deadline__c != null
                    && cs.RecordTypeId == caseRecordTypesMap.get(EXPERT_CENTER_CASE_RECORD_TYPE)
                    && businessDays <= Integer.valueOf(System.Label.DAYS_Deadline_Reason_required)
                    //Added by Dipesh Gupta 
                    && cs.Phone_Appointment__c == false 
                )
                    //Merged By - Rajeev Jain - 07/05/2017 - upto here
                    cs.addError(System.Label.ERROR_Deadline_Reason_required);
                //Modified By - Mahendra Swarnkar - CR-20170217-10702 - Ends here
                */
                //Commented by Mahendra Swarnkar -03/04/2020 - CR-20200217-13756 - Start Here
            } 
        }
        //Upto here
        
        //Modified By - Mahendra Swarnkar - CR-20160803-10082 - 08/23/2016
        //Populating Priority field for Expert center case record type
        //Starts from here
        //Loop through new case records
        for(Case cas : newCases) {
            
            //Commneted by Mahendra Swarnakr - 03/04/2020 - CR-20200217-13756: Expert Center
            // Check for expert center record type
            /*if(caseRecordTypesMap.containsKey(EXPERT_CENTER_CASE_RECORD_TYPE)
               && caseRecordTypesMap.get(EXPERT_CENTER_CASE_RECORD_TYPE) != null 
               && cas.RecordTypeId == caseRecordTypesMap.get(EXPERT_CENTER_CASE_RECORD_TYPE)
              ) {
                  
                  //Modified By - Dipesh Gupta - 08/10/2017- CR-20170705-11059
                  if(cas.Phone_Appointment__c == false) {
                      
                      //Modified By - Mahendra Swarnkar - CR-20170519-10949 -07/06/2017 -  updated to replace the reference of "Platinum Services" field to the "Research Platform" field = Accelerator Member (when "Platinum Services" = checked).-- Starts from here
                      //Check for platinum services on the related institution/Account record
                      if(
                          (cas.AccountId != null
                           && mapAccounts != null 
                           && mapAccounts.size() > 0 
                           && mapAccounts.containsKey(cas.AccountId)
                           && mapAccounts.get(cas.AccountId) != null
                           && mapAccounts.get(cas.AccountId).Research_Platform__c == 'Accelerator Member'
                          )
                          || 
                          (cas.ContactId != null
                           && mapContacts != null 
                           && mapContacts.size() > 0 
                           && mapContacts.containsKey(cas.ContactId)
                           && mapContacts.get(cas.ContactId) != null
                           && mapContacts.get(cas.ContactId).AccountId != null
                           && mapContacts.get(cas.ContactId).Account.Research_Platform__c == 'Accelerator Member'
                          )
                      ){
                          //Modified By - Mahendra Swarnkar - 11/17/2016 - CR-20161019-10240 - Updated the if condition logic to check the no of business days on the basis of today's date instead of created date.
                          //Check if the no of business days to deadline is less than 3 business days 
                          //then set Case priority as urgent else standard
                          if(cas.Deadline__c != null
                             && businessDays <= Integer.valueOf(System.Label.ExpertCenter_NoOfBusinessDaysToDeadLine_Priorty_Platinum_True)) { 
                                 
                                 //Populating the priority as urgent
                                 cas.Priority = System.Label.CASE_PRIORITY_URGENT_TYPE;
                                 
                             } else {
                                 cas.Priority = System.Label.CASE_PRIORITY_STANDARD_TYPE;
                             }
                          
                          if(cas.Priority == System.Label.CASE_PRIORITY_URGENT_TYPE && String.isBlank(cas.Deadline_Reason__c)){
                              cas.addError(System.Label.ERROR_Deadline_Reason_Reqd_for_Platinum_Type_ExpertCenter_Case);
                              
                          }
                      }
                      //Modified By - Mahendra Swarnkar - CR-20170519-10949 -07/06/2017 -  updated to replace the reference of "Platinum Services" field to the "Research Platform" field = Accelerator Member (when "Platinum Services" = checked).-- Ends here
                      
                      //Modified By - Mahendra Swarnkar - CR-20170217-10702 - 03/18/2017 - Start here 
                      //If platinum services is false on the related Institution record then
                      else {
                          
                          //Check if the no of business days to deadline is less than 5 business days then set Case priority as urgent else standard
                          if(cas.Deadline__c != null
                             && businessDays <= Integer.valueOf(System.Label.ExpertCenter_NoOfBusinessDaysToDeadLine_Priorty_Inbound)) { 
                                 
                                 //Populating the priority as urgent
                                 cas.Priority = System.Label.CASE_PRIORITY_URGENT_TYPE;
                             }
                          else {
                              cas.Priority = System.Label.CASE_PRIORITY_STANDARD_TYPE;
                          }
                          
                      }
                      
                      //Modified By - Mahendra Swarnkar - CR-20170217-10702 - 03/18/2017 - Stop here 
                  }
                  //Modified By - Dipesh Gupta - 08/10/2017- CR-20170705-11059
                  else {
                        
                        
                      //Update the deadline field  with today+2 date.     
                      cas.Deadline__c = Util.AddBusinessDays(Date.Today(), 2);      
                      cas.Priority = System.Label.CASE_PRIORITY_STANDARD_TYPE;
                      
                  }
              }*/
        }
        //Modified By - Mahendra Swarnkar - CR-20160803-10082 - 08/23/2016 - 
        //Populating Priority field for Expert center case record type - Ends here
    }
    
    //V1.33 - Rajeev Jain - 12/12/2016 - CR-20161209-10535 - This code logic is migrated from validateAndPopulateCaseData - upto here
    //Validate case deadline and Populate #Business Days to Deadline
    /*public static void validateAndPopulateCaseData(List<Case> newCases, Map<Id, Case> mapOldCases) {

        //Get all Blackout Days
        List<Case_Blackout_Days__c> listCaseBlackoutDays = [Select Id, Type__c, Blackout_Begin_Date__c, Blackout_End_Date__c, User__c from Case_Blackout_Days__c
        where Blackout_Begin_Date__c != null 
        AND Blackout_End_Date__c != null];
        
        //Added by Ajit Surana - - 05/24/2014 - CR-20140512-5440
        //Set to hold Record Type Ids
        Set<Id> setRTypeIds = new Set<Id>();
        
        //Fetch Expert Center record type
        for(RecordType rec : [Select Id from RecordType 
        where (DeveloperName = 'Expert_Center' OR DeveloperName = 'International') 
        AND SObjectType = 'Case' AND IsActive = true]){
        setRTypeIds.add(rec.Id);
        }
        
        //Check if record type exists
        if(setRTypeIds.size() == 0)
        return;
        
        //Universal start date
        Date universalStartDate = date.newInstance(0001, 1, 1); 
        
        //Loop through the case records
        for(Case caseObj : newCases) {
        
        //Check if case deadline doesn't fall during blackout
        if(setRTypeIds.contains(caseObj.RecordTypeId) && caseObj.Deadline__c != null 
        && (mapOldCases == null || caseObj.Deadline__c != mapOldCases.get(caseObj.Id).Deadline__c)) {
        
        //Variable to hold the created date
        Date createdDate;
        
        if(mapOldCases == null)
        createdDate = Date.today();
        else 
        createdDate = caseObj.CreatedDate.date();
        
        //Find day number of start date
        Integer startDay = Math.mod(universalStartDate.daysBetween(createdDate), 7);
        
        //Find day number of start date
        Integer endDay = Math.mod(universalStartDate.daysBetween(caseObj.Deadline__c), 7);
        
        //Days between Start date and end Date
        Integer ageInDays = createdDate.daysBetween(caseObj.Deadline__c);
        
        //variable to hold the age in hours
        Integer daysOfDeadline;
        
        //Skip Weekends
        if(createdDate == caseObj.Deadline__c) {
        
        //deadline is on the same day
        daysOfDeadline = ageInDays;
        } else if(startDay > endDay) {
        
        //Aging Hours
        daysOfDeadline = ageInDays - (2*((ageInDays+7)/7));
        } else {
        
        //Aging Hours
        daysOfDeadline = ageInDays - (2*(ageInDays/7));
        }
        
        //Loop through the blackout days
        for(Case_Blackout_Days__c cBD : listCaseBlackoutDays) {
        //Check is deadline falls during Black out days
        if(cBD.Blackout_Begin_Date__c <= caseObj.Deadline__c && cBD.Blackout_End_Date__c >= caseObj.Deadline__c
        && (cBD.User__c == caseObj.OwnerId || cBD.User__c == null)) {
        //V_1.1 - Modified By Abhinav Sharma - 05/21/2014 - CR-20140108-4238
        //Throw exception
        caseObj.addError('Selected deadline date is conflicting with some Case Blackout Days records. To see the records, Please ' + '<a href="" onclick=\"window.open(\'/apex/Blackout_Records_For_Case?deadLine=' + caseObj.Deadline__c + '&ownerId=' + caseObj.ownerId + '&inline=1\', \'Search\',\'dialogWidth:580px;dialogHeight:400px; dialogLeft:200px; dialogTop:200px; center:1; resizable: no;\');return false;\">Click Here</a>', false);
        //throw new CustomException('Selected deadline date is conflicting with some Case Blackout Days records. To see the records, Please ' + '<a href="" onclick=\"window.open(\'/apex/Blackout_Records_For_Case?deadLine=' + caseObj.Deadline__c + '&ownerId=' + caseObj.ownerId + '&inline=1\', \'Search\',\'dialogWidth:580px;dialogHeight:400px; dialogLeft:200px; dialogTop:200px; center:1; resizable: no;\');return false;\">Click Here</a>');
        
        } else {
        //Check for the blackout days
        if(cBD.Blackout_Begin_Date__c >= createdDate && cBD.Blackout_End_Date__c <= caseObj.Deadline__c) {
        
        //Black out start date
        Integer blackOutStartDay = Math.mod(universalStartDate.daysBetween(cBD.Blackout_Begin_Date__c), 7);
        
        //Find day number of start date
        Integer blackOutEndDay = Math.mod(universalStartDate.daysBetween(cBD.Blackout_End_Date__c), 7);
        
        //Remove Weekends from blackout days and this has already been removed from above calculation
        //Days between Start date and end Date
        Integer blackOutAgeInDays = cBD.Blackout_Begin_Date__c.daysBetween(cBD.Blackout_End_Date__c);
        
        //variable to hold the age in hours
        Integer daysOfBO;
        
        //Skip Weekends
        if(cBD.Blackout_Begin_Date__c == cBD.Blackout_End_Date__c) {
        
        //deadline is on the same day
        daysOfBO = blackOutAgeInDays;
        } else if(blackOutStartDay > blackOutEndDay) {
        
        //Aging days
        daysOfBO = blackOutAgeInDays - (2*((blackOutAgeInDays+7)/7));
        } else {
        
        //Aging Days
        daysOfBO = blackOutAgeInDays - (2*(blackOutAgeInDays/7));
        }
        
        //Subtract blackoutDuration from daysOfDeadline
        if(daysOfBO != null)
        daysOfBO += 1;
        daysOfDeadline = daysOfDeadline - daysOfBO;
        }
        }   
        }
        
        //Set blackout days
        if(daysOfDeadline != null)
        daysOfDeadline += 1;
        
        //Check if it was saturday
        if(endDay == 0)
        daysOfDeadline += 1;
        
        caseObj.Num_Business_Days_to_Deadline__c = daysOfDeadline;
        
        }       
        }
    }*/
    
    
    /**
    * 
    * @description: get the record type ids that are available for sync
    * 
    **/
    public static set<Id> syncRecordTypeIds { get; set; }
    public static set<Id> getSyncRecordTypeIds(string objectName) {
        if (syncRecordTypeIds == null) {
            syncRecordTypeIds = new set<Id>();
            set<string> rtDevNameSet = new set<string>();
            set<string> objNameSet = new set<string>();
            for (Sync_Field__c s : Constants.SYNC_FIELDS_LIST) rtDevNameSet.add(s.Source_Record_Type_Developer_Name__c);
            if (rtDevNameSet.size() > 0) {
                map<Id, RecordType> syncRecordTypeMap = new map<Id, RecordType>([SELECT Id FROM RecordType 
                                                                                 WHERE DeveloperName IN :rtDevNameSet 
                                                                                 AND SobjectType = :objectName 
                                                                                 AND IsActive = true]);
                syncRecordTypeIds = syncRecordTypeMap.keySet();
            }
        }
        return syncRecordTypeIds;
    }
    
    //V_1.32 - Modified By - Rajeev Jain - 11/21/2016 - Services Excellence UAT Issue fix  
    //Determine if a member support record needs to be created or synchronized.  CR-4283
    public static void syncCaseToMemberSupport(list<Case> newCases, map<Id, Case> mapOldCases) {
        
        //Spring clean Up - Method removed.   
        
    }
    
    //Populate the targetRecord with the corresponding sourceRecord's field values and return the targetObject.  CR-4283
    public static sObject populateSourceFieldsToTarget(sObject sourceObj_Old, sObject sourceObj, sObject targetObj) {
        
        //Get the list of sync fields
        list<Sync_Field__c> syncFieldList = Constants.SYNC_FIELDS_LIST;
        
        //Get the source/target sObject types
        string sourceObjAPIName = sourceObj.getSObjectType().getDescribe().getName();
        string targetObjAPIName = targetObj.getSObjectType().getDescribe().getName();
        
        //Get the Source's record type developer name
        string sourceObjRTDevName;
        try {
            
            sourceObjRTDevName = [SELECT Id, DeveloperName FROM RecordType WHERE Id = :(string)sourceObj.get('RecordTypeId')].DeveloperName;
        }
        catch(Exception ex) {
            
            throw new customException(ex.getMessage() + '  Stack:' + ex.getStackTraceString());
        }
        
        boolean isNewSourceObj = (sourceObj_Old == null || sourceObj_Old.get('Id') == null);
        boolean isNewTargetObj = (targetObj.get('Id') == null);
        
        //Map the source fields to target record
        for (Sync_Field__c syncField : syncFieldList) {
            
            if (syncField.Source_Object_API_Name__c == sourceObjAPIName
                && syncField.Target_Object_API_Name__c == targetObjAPIName
                && (isNewSourceObj
                    || isNewTargetObj
                    || sourceObj_Old.get(syncField.Source_Field_API_Name__c) != sourceObj.get(syncField.Source_Field_API_Name__c))
                && (syncField.Source_Record_Type_Developer_Name__c == sourceObjRTDevName))
            {
                //Sometimes the source value will need to be converted
                //For instance, the status '01-New' from Case is converted to '01 - Issue Reported' for Member Support
                object sourceFieldValue = convertSourceFieldValue(syncField.Source_Object_API_Name__c,
                                                                  syncField.Target_Object_API_Name__c,
                                                                  syncField.Source_Field_API_Name__c,
                                                                  sourceObj);
                
                //if the field being synched is a boolean type, replace null values w/false (this is to resolve a SF field type error)
                if (sourceFieldValue == null) 
                {
                    if (Schema.DisplayType.Boolean == targetObj.getSObjectType().getDescribe().Fields.getMap().get(syncField.Target_Field_API_Name__c).getDescribe().getType()) {
                        sourceFieldValue = false;
                    }
                }
                
                
                targetObj.put(syncField.Target_Field_API_Name__c, sourceFieldValue);
            }
        }
        
        return targetObj;
    }
    
    private static object convertSourceFieldValue(string sourceObjType, string targetObjType, string sourceFieldAPIName, sobject sourceObj) {
        
        string sourceRecordTypeId = (string) sourceObj.get('RecordTypeId');
        
        string sourceFieldValue;
        object sourceFieldValue_object;
        
        try {
            //CR-20160113-9507 if this is an instance of a string, convert it and continue processing
            if (sourceObj.get(sourceFieldAPIName) instanceOf string)
                sourceFieldValue = (string) sourceObj.get(sourceFieldAPIName);
            else { //CR-20160113-9507 if it is not a string, leave it as an object and return if not auto-populated via the custom process below
                sourceFieldValue_object = sourceObj.get(sourceFieldAPIName);
            }
        }
        catch(exception ex) {
            system.debug('Error Converting value to string:' + ex + '  sourceFieldAPIName:' + sourceFieldAPIName + '---VALUE:' + sourceObj.get(sourceFieldAPIName));
        }
        
        if (sourceObjType.equalsIgnoreCase('Case') 
            && targetObjType.equalsIgnoreCase('Site_Issue__c') 
            && sourceFieldAPIName.equalsIgnoreCase('Status'))
        {
            //V_1.27 - Modified By - Rajeev Jain - 10/19/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
            /*vh commented out 6/1/16 because the values will populate exactly as they are between Case and Member Support. CR-20160519-9863
            if (sourceRecordTypeId == Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT
            && caseToMemSupportStatus_SupportRT_Map.containsKey(sourceFieldValue))
            {
            sourceFieldValue = caseToMemSupportStatus_SupportRT_Map.get(sourceFieldValue);
            }
            else if*/
            //V_1.27 - Modified By - Rajeev Jain - 10/19/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb. - upto here
            //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT DataLoad
            if(/*sourceRecordTypeId == Constants.RECORD_TYPE_ID_CASE_PT_DATA_LOAD
                &&*/ caseToMemSupportStatus_DataLoadRT_Map.containsKey(sourceFieldValue))
            {
                sourceFieldValue = caseToMemSupportStatus_DataLoadRT_Map.get(sourceFieldValue);
            }
        }
        else if (sourceObjType.equalsIgnoreCase('Site_Issue__c') 
                 && targetObjType.equalsIgnoreCase('Case') 
                 && sourceFieldAPIName.equalsIgnoreCase('Status__c'))
        {
            ////V_1.27 - Modified By - Rajeev Jain - 10/19/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
            /*vh commented out 6/1/16 because the values will populate exactly as they are between Case and Member Support. CR-20160519-9863
            if (sourceRecordTypeId == Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST
            && memSupportToCaseStatus_SupportRT_Map.containsKey(sourceFieldValue))
            {
            
            sourceFieldValue = memSupportToCaseStatus_SupportRT_Map.get(sourceFieldValue);
            }
            else if*/
            //V_1.27 - Modified By - Rajeev Jain - 10/19/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb. - upto here
            if(sourceRecordTypeId == Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_DATA_LOAD
               && memSupportToCaseStatus_DataLoadRT_Map.containsKey(sourceFieldValue))
            {
                
                sourceFieldValue = memSupportToCaseStatus_DataLoadRT_Map.get(sourceFieldValue);
            }
            
        }
        else if (sourceObjType.equalsIgnoreCase('Site_Issue__c') 
                 && targetObjType.equalsIgnoreCase('Case') 
                 && sourceFieldAPIName.equalsIgnoreCase('Site_Issue_Priority__c'))
        {
            
            if (memSupportToCasePriority_Map.containsKey(sourceFieldValue))
            {
                sourceFieldValue = memSupportToCasePriority_Map.get(sourceFieldValue);
            }
        }
        else if (sourceObjType.equalsIgnoreCase('Case') 
                 && targetObjType.equalsIgnoreCase('Site_Issue__c') 
                 && sourceFieldAPIName.equalsIgnoreCase('Priority'))
        {
            
            if (caseToMemSupportPriority_Map.containsKey(sourceFieldValue))
            {
                sourceFieldValue = caseToMemSupportPriority_Map.get(sourceFieldValue);
            }
        }
        else if (sourceObjType.equalsIgnoreCase('Site_Issue__c') 
                 && targetObjType.equalsIgnoreCase('Case') 
                 && (  sourceFieldAPIName.equalsIgnoreCase('Data_Load_Period_Begin__c') 
                     || sourceFieldAPIName.equalsIgnoreCase('Data_Load_Period_End__c')))
        {
            
            date dBegin = (date) sourceObj.get('Data_Load_Period_Begin__c');
            date dEnd = (date) sourceObj.get('Data_Load_Period_End__c');
            
            if (dBegin != null && dEnd != null) {
                
                //CCA Dataload tickets map Site Issue DL dates to the Case Description
                sourceFieldValue = 'Data Load for '
                    + dBegin.format()
                    + ' to '
                    + dEnd.format();
            }
        }
        
        if (sourceFieldValue != null) 
            sourceFieldValue_object = (object) sourceFieldValue;
        return sourceFieldValue_object;
    }
    
    //Check the fields that sync from Case -> MS and determine if the related MS record should be updated.  CR-4283
    public static boolean recordNeedsSynced(sObject newSourceObj, sObject oldSourceObj) {
        
        boolean isChanged = false;
        
        //Get the list of sync fields
        list<Sync_Field__c> syncFieldList = Constants.SYNC_FIELDS_LIST;
        
        //Get the source sObject types
        string sourceObjAPIName = newSourceObj.getSObjectType().getDescribe().getName();
        
        //Get the Source's record type developer name
        string sourceObjRTDevName;
        try {
            sourceObjRTDevName = [SELECT Id, DeveloperName FROM RecordType WHERE Id = :(string)newSourceObj.get('RecordTypeId')].DeveloperName;
        }
        catch(Exception ex) {
            system.debug('@@exception:' + ex);
        }
        
        //Go through each field value via dynamic dml and see if there was a change
        if (oldSourceObj != null) {
            
            for (Sync_Field__c syncField : syncFieldList) {
                
                if (syncField.Source_Object_API_Name__c == sourceObjAPIName
                    && syncField.Source_Record_Type_Developer_Name__c == sourceObjRTDevName) 
                {
                    
                    object newVal = convertSourceFieldValue(syncField.Source_Object_API_Name__c,
                                                            syncField.Target_Object_API_Name__c,
                                                            syncField.Source_Field_API_Name__c,
                                                            newSourceObj);
                    object oldVal = convertSourceFieldValue(syncField.Source_Object_API_Name__c,
                                                            syncField.Target_Object_API_Name__c,
                                                            syncField.Source_Field_API_Name__c,
                                                            oldSourceObj);
                    if (oldVal != newVal) {
                        isChanged = true;
                        break;
                    }
                }
            }
        }
        else {
            isChanged = true;
        }
        
        return isChanged;
    }
    
    //V_1.27 - Modified By - Rajeev Jain - 10/19/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
    //Map Case Status => Member Support status equivalent for the Crimson Support Record Type
    /*public static map<string, string> caseToMemSupportStatus_SupportRT_Map {
    get {
    if (caseToMemSupportStatus_SupportRT_Map == null) {
    caseToMemSupportStatus_SupportRT_Map = new map<string, string> {
    '01-New' => '01- Issue Reported',
    '03-In Progress' => '02- Working on Issue',
    '04.2-Response needed - External' => '03.1 - Member Input Required',
    '09-Pending Closed' => '05 - Issue Resolved - Request to Close Ticket',
    '10-Closed' => '06 - Issue Resolved - Ticket Closed'
    };
    }
    return caseToMemSupportStatus_SupportRT_Map;
    }
    set;
    }*/
    
    //Map Member Support Status => Case status equivalent
    /*public static map<string, string> memSupportToCaseStatus_SupportRT_Map {
    get {
    if (memSupportToCaseStatus_SupportRT_Map == null) {
    memSupportToCaseStatus_SupportRT_Map = new map<string, string> {
    '01- Issue Reported' => '01-New',
    '01 - Awaiting Files' => '04.2-Response needed - External',
    '01- Waiting for Files' => '04.2-Response needed - External',
    '02 - Awaiting BA response' => '03-In Progress',
    '02- Working on Issue' => '03-In Progress',
    '2.5 - Waiting on Data Analyst Response' => '03-In Progress',
    '03 - Need more information' => '04.2-Response needed - External',
    '03.1 - Member Input Required' => '04.2-Response needed - External',
    '03.5 - Need More Information' => '04.1-Response needed - Internal',
    '04 - Issue Resolved in Test - BA Response Needed' => '03-In Progress',
    '4.5 - Issue Resolved in Test - Dedicated Advisor Response Required' => '03-In Progress',
    '05- Issue Resolved in Production - Request to Close Ticket' => '09-Pending Closed',
    '05 - Issue Resolved - Request to Close Ticket' => '09-Pending Closed',
    '05.1 - Awaiting Verification from Dedicated Advisor' => '03-In Progress',
    '06 - Issue Resolved - Ticket Closed' => '10-Closed',
    'X - Duplicate/Cancelled' => '10-Closed'
    };
    }
    return memSupportToCaseStatus_SupportRT_Map;
    }
    set;
    }*/
    
    //Map Case Status => Member Support status equivalent for the CCA Data Load Record Type
    public static map<string, string> caseToMemSupportStatus_DataLoadRT_Map {
        get {
            if (caseToMemSupportStatus_DataLoadRT_Map == null) {
                caseToMemSupportStatus_DataLoadRT_Map = new map<string, string> {
                    '01-New' => 'Waiting for files',
                        '03-In Progress' => 'Files Received',
                        '04.1-Response needed - Internal' => 'Files Received',
                        '04.2-Response needed - External' => 'Member Input Required',
                        '05.1-Escalated - Services/Delivery' => 'Diagnostics ready',
                        '05.2-Escalated - Data Analyst' => 'Diagnostics approved',
                        '05.3-Escalated to Dev' => 'Diagnostics approved',
                        '09-Pending Closed' => 'Migration complete',
                        '10-Closed' => 'Closed',
                        'X-Cancelled' => 'Duplicate/Cancelled',
                        'Z-On Hold' => 'Diagnostics ready'
                        };
                            }
            return caseToMemSupportStatus_DataLoadRT_Map;
        }
        set;
    }
    
    //Map Member Support Status => Case status equivalent
    public static map<string, string> memSupportToCaseStatus_DataLoadRT_Map {
        get {
            if (memSupportToCaseStatus_DataLoadRT_Map == null) {
                memSupportToCaseStatus_DataLoadRT_Map = new map<string, string> {
                    'Waiting for files' => '04.2-Response needed - External',
                        'Files Received' => '03-In Progress',
                        'Member Input Required' => '04.2-Response needed - External',
                        'Diagnostics ready' => '03-In Progress',
                        'Diagnostics approved' => '03-In Progress',
                        'In smoke test' => '03-In Progress',
                        'In QA test' => '03-In Progress',
                        'Ready for Migration' => '03-In Progress',
                        'Migration complete' => '10-Closed',
                        'Closed' => '10-Closed',
                        'Duplicate/Cancelled' => 'X-Cancelled'
                        };
                            }
            return memSupportToCaseStatus_DataLoadRT_Map;
        }
        set;
    }
    //Modified By - Rajeev Jain - 10/19/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb. - upto here 
    //Map Case Priority => Member Support Priority equivalent
    public static map<string, string> caseToMemSupportPriority_Map {
        get {
            if (caseToMemSupportPriority_Map == null) {
                caseToMemSupportPriority_Map = new map<string, string> {
                    'Low' => 'Normal',
                        'Medium' => 'Normal',
                        'High' => 'High'
                        };
                            }
            return caseToMemSupportPriority_Map;
        }
        set;
    }
    
    //Map MS Priority => Case Priority equivalent
    public static map<string, string> memSupportToCasePriority_Map {
        get {
            if (memSupportToCasePriority_Map == null) {
                memSupportToCasePriority_Map = new map<string, string> {
                    'Normal' => 'Low',
                        'High' => 'High',
                        'Critical' => 'High'
                        };
                            }
            return memSupportToCasePriority_Map;
        }
        set;
    }
    
    //Modified By - Abhinav Sharma - 09/29/2016 - CR-20160916-10182
    /**
    *
    *   Description: If the Resolution Summary field is updated and Status = 'Solution Provided', post the resolution to comments
    *                This method also calls caseCommentNotify, which will send a notification email to the member.
    *
    **/
    //Modified By - Mahendra Swarnakar - 08/31/2016 - CR-20160715-10014
    public static void postResolutionToComments(list<Case> newCases, map<Id, Case> mapOldCases) {
        
        list<CaseComment> commentsToInsert = new list<CaseComment>();
        Case oldCase;
        
        //get all contacts so we can reference their name in the email that is sent
        set<Id> contactIds = new set<Id>();
        for (Case c : newCases) contactIds.add(c.ContactId);
        map<Id, Contact> contactMap = new map<Id, Contact>([SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id IN :contactIds]);
        
        for (Case newCase : newCases) {
            
            if (mapOldCases != null) oldCase = mapOldCases.get(newCase.Id);
            
            //V_1.27 - Modified By - Rajeev Jain - 10/20/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb. - upto here
            if (String.isNotBlank(newCase.Status) && (newCase.Status.equalsIgnoreCase('09-Pending Closed') || newCase.Status.equalsIgnoreCase('10-Closed')) 
                && newCase.Member_Facing_Resolution_Summary__c != oldCase.Member_Facing_Resolution_Summary__c) 
            {
                
                //Added By - Abhinav Sharma - 09/29/2016 - CR-20160916-10182
                //Start from here
                if(!IS_RECURSIVE_ACTION_HAPPENS) {
                    //Upto here 
                    
                    string bodyText = '[Case Close Resolution]\r\n' + newCase.Member_Facing_Resolution_Summary__c;
                    CaseComment comment = new CaseComment(ParentId = newCase.Id,
                                                          CommentBody = bodyText,
                                                          isPublished = true);
                    
                    commentsToInsert.add(comment);
                    
                    //caseCommentController.caseCommentNotify(newCase, comment, contactMap.get(newCase.ContactId));
                    
                    //Commented By - Abhinav Sharma - 09/29/2016 - CR-20160916-10182
                    //Start from here  
                    //Commented because "populateCaseCommentNotify" method of "CaseCommentTriggerHelper" class is 
                    //also populating this field with the same time stamp 
                    //and due to that "Crimson: Case Comment Notice to Contact" WF rule is sending recursive emails.
                    //newCase.Case_Comment_Notification__c = system.now();
                    //Upto here
                    
                    //Added By - Abhinav Sharma - 09/29/2016 - CR-20160916-10182
                    //Start from here
                    //Setting the flag value to true, in order to stop recurssion
                    IS_RECURSIVE_ACTION_HAPPENS = true;
                    //upto here
                }        
            }
        }
        
        if (commentsToInsert.size() > 0) insert commentsToInsert;
    }
    
    /**
     *  @description    :   Set of Origin values referenced by multiple methods within this Class
     * 
     *  @return         :   Set<String>
     * 
     *  @Revision Log   :   V1.0 - Created By - Victor Hanson - 11/07/2017 - Issue--CR11625--QA--00007247 - Apollo Release
     **/
    private static Set<String> setOrigins {
        get {
            if (setOrigins == null) {
                setOrigins = new Set<String>();
                setOrigins.add(Constants.CASE_ORIGIN_MEETINGS);
                setOrigins.add(Constants.CASE_ORIGIN_WEBCONFERENCES);
                setOrigins.add(Constants.CASE_ORIGIN_CONFERENCE_ROOM_REQUESTS);
                setOrigins.add(Constants.CASE_ORIGIN_TRAVEL);
                setOrigins.add(Constants.CASE_ORIGIN_VOICE_MAIL);
                setOrigins.add(Constants.CASE_ORIGIN_ADVISORY);
                setOrigins.add(Constants.CASE_ORIGIN_EAB);
                setOrigins.add(Constants.CASE_ORIGIN_ABI);
                setOrigins.add(Constants.CASE_ORIGIN_EMAIL_TO_CASE_DATA_INTEGRATIONS);
                setOrigins.add(Constants.CASE_ORIGIN_EAB_MEETINGS);
                setOrigins.add(CaseTriggerHelper.CASE_ORIGIN_WEB);
            }
            return setOrigins;
        }
        set;
    } 
    
    /**
     *  @description    :   Method used to populate the Case Owner to a queue if Origin or Entity are changed
     * 
     *  @args           :   List of new Case records, Map of old Case records
     * 
     *  @return         :   void
     * 
     *  @Revision Log   :   V1.0 - Created By - Victor Hanson - 11/07/2017 - Issue--CR11625--QA--00007247 - Apollo Release
     **/
    public static void populateOwner(list<Case> newCases, map<Id, Case> mapOldCases) {
        
        Set<Id> caseIds = new Set<Id>();
        boolean isInsert = (mapOldCases == null);
        
        for (Case c : newCases) {
            
            Case oldCase;
            if (mapOldCases != null && mapOldCases.size() > 0) oldCase = mapOldCases.get(c.Id);
            
            //if it's an insert (ie: oldCase == null) OR (origin is in the set of origins that determine queue ownership AND (origin or entity are updated)), add to list of cases
            if (oldCase == null ||
                (oldCase.Origin != null && CaseTriggerHelper.setOrigins.contains(c.Origin) && (oldCase.Origin != c.Origin || oldCase.Entity__c != c.Entity__c))) 
            {
                caseIds.add(c.Id);
            }
        }
        
        //if there are ids in the list, and this isn't a future/scheduled job, execute the future method to populate Case Owner
        if (caseIds.size() > 0
            && !system.isBatch()
            && !system.isFuture()
            && !system.isQueueable()
            && !system.isScheduled()) 
        {
            populateCaseFromEmailToCase(caseIds, isInsert);
        }
    }
    
    //Modified By - Mahendra Swarnakar - 12/02/2015 - CR-20151118-9397
    //Modified By - Abhinav Sharma - 12/01/2015 - CR-20150616-9006
    //Modified By - Ajit Surana - 11/17/2014 - CR-20141105-7992
    //Modified By - Ajit Surana - 11/16/2014 - CR-20141105-7987
    //Modified By - Ajit Surana - 09/10/2014 - CR-20140812-6973
    //Added By - Abhinav Sharma - 06/19/2014 - CR-20140417-5120
    //Validate and Populate case record fields with desired values in case when it is coming via Email to Case functionality
    //Modified By - Abhinav Sharma - 10-08-2014 - CR-20140827-7164
    //Modified By - Mahendra Swarnakar - 08/31/2016 - CR-20160715-10014
    @future (callout=false)
    public static void populateCaseFromEmailToCase(Set<Id> caseIds, boolean isInsert) {
        
        //Added By - Subhash Garhwal - CR-20160224-9628 - 02/07/2017 - Member_Support_Ticket__c added to query
        //Modified By - Ajit Surana - 11/16/2014 - CR-20141105-7987 - Removed Record Type check from the query
        //Query Cases
        List<Case> newCases = [SELECT Id, Origin, RecordTypeId, Description, Member_Support_Ticket__c, Entity__c FROM Case 
                               WHERE Id IN: caseIds 
                               AND Origin IN : CaseTriggerHelper.setOrigins];
        
        //Check for the size
        if(newCases.size() == 0)
            return;
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        Map<Id, RecordType> mapCaseRecordTypes = new Map<Id, RecordType>([SELECT ID, DeveloperName FROM RecordType 
                                                                          Where sObjectType =: Constants.CASE_OBJECT 
                                                                          AND IsActive = true 
                                                                          AND (
                                                                              DeveloperName =: Constants.CASE_RECORD_TYPE_MEMBER_EMPLOYEE_SUPPORT
                                                                              OR
                                                                              DeveloperName =: Constants.CASE_RECORD_TYPE_WEBHELP
                                                                          )
                                                                         ]);
        
        //Map of queues
        Map<String, Id> mapQueues = new Map<String, Id>();
        
        //Loop through Queue records
        for(QueueSobject que : [SELECT Id, queue.DeveloperName, QueueId FROM QueueSobject 
                                WHERE SobjectType =: Constants.CASE_OBJECT
                                AND queue.DeveloperName != null
                                AND (
                                    queue.DeveloperName =: Constants.QUEUE_NAME_EVENTS_MEMBER_SUPPORT
                                    OR
                                    queue.DeveloperName =: Constants.QUEUE_NAME_WEBHELP
                                    OR
                                    queue.DeveloperName =: Constants.QUEUE_NAME_EVENTS_MEMBER_SUPPORT_HC
                                    OR
                                    queue.DeveloperName =: Constants.QUEUE_NAME_WEBHELP_HC
                                )
                                ORDER By queue.DeveloperName ASC]
           ) {
               if(que.QueueId != null)
                   mapQueues.put(que.queue.DeveloperName, que.QueueId);                           
           }      
        
        //Proceed further only and only if record type and queue are there as specified
        if(mapCaseRecordTypes != null && mapCaseRecordTypes.values().size() > 0 
           && mapQueues != null && mapQueues.values().size() > 0) {
               
               //Loop through case records
               for(Case cas : newCases) {
                   
                   //only update Status / Description on afterInsert
                   if (isInsert) {
                       
                       //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT Support Request
                       //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT DataLoad
                       //Checking for the 'PT Support Request"/"PT Data Load" Record type  
                       /*if(Util.RecordTypeId(Constants.CASE_OBJECT, Constants.RECORD_TYPE_CASE_PT_SUPPORT_REQUEST) == cas.RecordTypeId
                        ||
                        Util.RecordTypeId(Constants.CASE_OBJECT, Constants.RECORD_TYPE_CASE_PT_DATA_LOAD) == cas.RecordTypeId
                        ) {
                        
                        //Populate the status field value  
                        cas.Status = '01-New';
                        
                        //Checking for the "eTech SUpport" record type    
                        } else*/ 
                       if(Util.RecordTypeId(Constants.CASE_OBJECT, ETECH_SUPPORT_CASE_RECORD_TYPE) == cas.RecordTypeId) {
                           
                           //Populate the status field value
                           cas.Status = 'Submitted';
                           
                       } else {
                           
                           //Populating case record with fields values
                           cas.Status = System.Label.E2C_BY_DEFAULT_CASE_STATUS;
                           
                       }
                       
                       //Strip out the html tags from the Case description field value
                       //Modified by - mahendra swarnakar - 10/18/2016 - Applied a check for null/blank condition only as a part of  CR-20160209-9593 
                       if(String.isNotBlank(cas.Description))
                           cas.Description = cas.Description.replaceAll('\\<.*?\\>', '');
                   }
                   
                   //Added By - Ajit Surana - 11/16/2014 - CR-20141105-7987
                   //Update the Owner of case if case RecordType equals Member Employee Support
                   If(cas.RecordTypeId != null
                      && mapCaseRecordTypes.containsKey(cas.RecordTypeId)
                      && mapCaseRecordTypes.get(cas.RecordTypeId) != null
                      && mapCaseRecordTypes.get(cas.RecordTypeId).DeveloperName != null) {
                          
                          //Populating owner field on the case object    
                          if(mapCaseRecordTypes.get(cas.RecordTypeId).DeveloperName == Constants.CASE_RECORD_TYPE_MEMBER_EMPLOYEE_SUPPORT) {
                              if (cas.Entity__c == 'EAB') {
                                  if(mapQueues.containsKey(Constants.QUEUE_NAME_EVENTS_MEMBER_SUPPORT) && mapQueues.get(Constants.QUEUE_NAME_EVENTS_MEMBER_SUPPORT) != null)
                                      cas.OwnerId = mapQueues.get(Constants.QUEUE_NAME_EVENTS_MEMBER_SUPPORT);
                              }
                              else if (cas.Entity__c == 'HC') {
                                  if(mapQueues.containsKey(Constants.QUEUE_NAME_EVENTS_MEMBER_SUPPORT_HC) && mapQueues.get(Constants.QUEUE_NAME_EVENTS_MEMBER_SUPPORT_HC) != null)
                                      cas.OwnerId = mapQueues.get(Constants.QUEUE_NAME_EVENTS_MEMBER_SUPPORT_HC);
                              }
                          }    
                          else if(mapCaseRecordTypes.get(cas.RecordTypeId).DeveloperName == Constants.CASE_RECORD_TYPE_WEBHELP) {
                              if (cas.Entity__c == 'EAB') {
                                  if(mapQueues.containsKey(Constants.QUEUE_NAME_WEBHELP) && mapQueues.get(Constants.QUEUE_NAME_WEBHELP) != null)
                                      cas.OwnerId = mapQueues.get(Constants.QUEUE_NAME_WEBHELP);
                              }
                              if (cas.Entity__c == 'HC') {
                                  if(mapQueues.containsKey(Constants.QUEUE_NAME_WEBHELP_HC) && mapQueues.get(Constants.QUEUE_NAME_WEBHELP_HC) != null)
                                      cas.OwnerId = mapQueues.get(Constants.QUEUE_NAME_WEBHELP_HC);
                              }
                          }
                      }
                   
                   //only update Type on afterInsert
                   if (isInsert) {
                       
                       //Checking and validating for sender's email address and then populating field values on case record
                       if(cas.Origin == Constants.CASE_ORIGIN_MEETINGS)
                           cas.Type = Constants.CASE_ORIGIN_MEETINGS;
                       else if(cas.Origin == Constants.CASE_ORIGIN_WEBCONFERENCES)
                           cas.Type = Constants.CASE_ORIGIN_WEBCONFERENCES;
                       else if(cas.Origin == Constants.CASE_ORIGIN_CONFERENCE_ROOM_REQUESTS)
                           cas.Type = Constants.CASE_ORIGIN_CONFERENCE_ROOM_REQUESTS;
                       else if(cas.Origin == Constants.CASE_ORIGIN_TRAVEL)
                           cas.Type = Constants.CASE_ORIGIN_TRAVEL;
                       else if(cas.Origin == Constants.CASE_ORIGIN_VOICE_MAIL)
                           cas.Type = Constants.CASE_ORIGIN_VOICE_MAIL;
                       else if(cas.Origin == Constants.CASE_ORIGIN_ADVISORY)
                           cas.Type = Constants.CASE_ORIGIN_ADVISORY;
                       else if(cas.Origin == Constants.CASE_ORIGIN_EAB)
                           cas.Type = Constants.CASE_ORIGIN_EAB;
                       else if(cas.Origin == Constants.CASE_ORIGIN_ABI)
                           cas.Type = Constants.CASE_ORIGIN_ABI;
                       else if(cas.Origin == Constants.CASE_ORIGIN_EMAIL_TO_CASE_DATA_INTEGRATIONS)
                           cas.Type = Constants.CASE_ORIGIN_DATA_INTEGRATIONS;
                       else if(cas.Origin == Constants.CASE_ORIGIN_EAB_MEETINGS)
                           cas.Type = Constants.CASE_ORIGIN_MEETINGS;
                       else {}
                   }
               }
               
               //Added By - Subhash Garhwal - CR-20160224-9628 - 02/07/2017
               //Set to hold the Member Support IDs
               Set<Id> setMemberSupportIDs = new Set<Id>();    
               
               //only update Type on afterInsert
               if (isInsert) {
                   
                   //Setting back the case origin to email    
                   for(Case c : newCases) {
                       
                       //Added By - Subhash Garhwal - CR-20160224-9628 - 02/07/2017
                       //Checking if member support is associated with the case record
                       //Accordingly populating collection to have it's ID
                       if(c.Member_Support_Ticket__c != null)
                           setMemberSupportIDs.add(c.Member_Support_Ticket__c);
                       
                       if(c.Origin != Constants.CASE_ORIGIN_EAB_MEETINGS 
                          && c.Origin != Constants.CASE_ORIGIN_VOICE_MAIL
                          && c.Origin != CaseTriggerHelper.CASE_ORIGIN_WEB
                         )
                           c.Origin = Constants.EMAIL;    
                   }
               }
               
               //Checking list for it size value
               if(newCases.size() > 0) {
                   Util.byPassAllTriggers = true;
                   update newCases;
                   Util.byPassAllTriggers = false;
               }
               
               //Added By - Subhash Garhwal - CR-20160224-9628 - 02/07/2017 - Start from here
               //Checking set for it's size
               if(setMemberSupportIDs.size() > 0) {
                   
                   //Map to hold the member support records (TO be updated)
                   Map<Id, Site_Issue__c> mapSiteIssues = new Map<Id, Site_Issue__c>();
                   
                   //loop through member support records IDs
                   for(ID mID : setMemberSupportIDs) {
                       Site_Issue__c sI = new Site_Issue__c(ID = mID);
                       sI.Interaction_Type__c = 'Email to Case';
                       mapSiteIssues.put(sI.Id, sI);
                   } 
                   
                   //Checking map values for its size
                   if(mapSiteIssues.values().size() > 0) {
                       Util.byPassAlltriggers = true;
                       update mapSiteIssues.values();
                       Util.byPassAlltriggers = false;
                   }
               }
               //Added By - Subhash Garhwal - CR-20160224-9628 - 02/07/2017 - Upto here
               
               //Set to hold the case records Id values
               Set<Id> setCases = new Set<Id>();
               
               //only update Type on afterInsert
               if (isInsert) {
                   
                   //Loop through case records and populating set with ID values    
                   for(Case cs : newCases)    
                       setCases.add(cs.Id);    
                   
                   //Calling method to delete the cases    
                   if(setCases.size() > 0)
                       deletedOutOutOfOfficeCases(setCases);    
               }
           }
    }
    
    //Modified By - Abhinav Sharma - 12/01/2015 - CR-20150616-9006
    //Modified By - Abhinav Sharma - 08/06/2014 - CR-20140707-6093
    //Added By - Abhinav Sharma - 06/19/2014 - CR-20140417-5120
    //Method to deleted out the case record after insertion of it, if is of "Out of Office" type
    //Modified By - Abhinav Sharma - 10-08-2014 - CR-20140827-7164
    public static void deletedOutOutOfOfficeCases(Set<Id> setCaseIds) {
        
        //List to hold the case record going to be delete and if of "Out Of Office" type
        List<Case> casesToBeDeleted = new List<Case>();
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        Map<Id, RecordType> mapCaseRecordTypes = new Map<Id, RecordType>([SELECT ID, DeveloperName FROM RecordType 
                                                                          Where sObjectType =: Constants.CASE_OBJECT 
                                                                          AND IsActive = true 
                                                                          AND (
                                                                              DeveloperName =: Constants.CASE_RECORD_TYPE_MEMBER_EMPLOYEE_SUPPORT
                                                                              OR
                                                                              DeveloperName =: Constants.CASE_RECORD_TYPE_WEBHELP
                                                                              OR
                                                                              DeveloperName =: Constants.CASE_RECORD_TYPE_ETECH_SUPPORT
                                                                          )
                                                                         ]);
        
        //Query for queue                                
        Map<Id, QueueSobject> mapQueues = new Map<Id, QueueSobject>();
        
        //Loop through queue list and populating it with appropriate combination of values
        for(QueueSobject qs : [SELECT Id, queue.DeveloperName, QueueId FROM QueueSobject 
                               WHERE SobjectType =: Constants.CASE_OBJECT
                               AND queue.DeveloperName != null
                               AND (
                                   queue.DeveloperName =: Constants.QUEUE_NAME_EVENTS_MEMBER_SUPPORT
                                   OR
                                   queue.DeveloperName =: Constants.QUEUE_NAME_WEBHELP
                                   OR
                                   queue.DeveloperName =: Constants.QUEUE_NAME_DATA_INTEGRATIONS
                               )
                              ]) {
                                  if(qs.QueueId != null)
                                      mapQueues.put(qs.QueueId, qs);
                              }
        
        //Misslenious Properties
        Set<String> setoutOfOfficesStrings = Constants.SET_OOO_AND_AUTOMATIC_REPLY;
        
        //Added By - Abhinav Sharma - 10-08-2014 - CR-20140827-7164
        //Start from here
        //Set to hold the email addresses should be filtered out
        Set<String> setOfEmailsToBeFiltered = new Set<String>();
        setOfEmailsToBeFiltered.add(Constants.MAILER_DAEMON_ADVISORY_COM);
        setOfEmailsToBeFiltered.add(Constants.SPAM_FILTER_ADVISORY_COM);
        //Upto here
        
        //Proceed further only and only if record type and queue are there as specified
        if(mapCaseRecordTypes != null && mapCaseRecordTypes.values().size() > 0 
           && mapQueues != null && mapQueues.values().size() > 0 
           && setoutOfOfficesStrings != null && setoutOfOfficesStrings.size() > 0) {
               
               //Loop throuh case records
               for(Case c : [SELECT ID, RecordTypeId, OwnerId, Subject, Description, Origin, SuppliedEmail 
                             FROM Case WHERE ID IN : setCaseIds]) {
                                 
                                 //Boolean variable helpful in making decision about record fiteration
                                 Boolean isOutOfOffices = false;
                                 
                                 //Checking Case record for its Owner, Origin, Record type and then for "Out of Office" string in subject and description
                                 //Add it to the list going to be delete if satisfies all of the desired conditions
                                 if(mapCaseRecordTypes.containsKey(c.RecordTypeId)
                                    && mapCaseRecordTypes.get(c.RecordTypeId) != null 
                                    && mapQueues.containsKey(c.OwnerId)
                                    && mapQueues.get(c.OwnerId) != null
                                    && (c.Origin == Constants.EMAIL || c.Origin == Constants.CASE_ORIGIN_EAB_MEETINGS || c.Origin == Constants.CASE_ORIGIN_VOICE_MAIL || c.Origin == CaseTriggerHelper.CASE_ORIGIN_WEB)) {
                                        
                                        //If case record is having "Out of offices" in Subject or Body will need to be filtered out.
                                        if(!String.isBlank(c.Subject)) {
                                            for(String outOfOffices : setoutOfOfficesStrings) {
                                                if(c.Subject.toLowerCase().trim().contains(outOfOffices))
                                                    isOutOfOffices = true;  
                                            }  
                                        }
                                        
                                        //Added By - Abhinav Sharma - 10-08-2014 - CR-20140827-7164
                                        //Start from here
                                        //If case record having filtered out emails with it them also consider it for deletion
                                        if(!String.isBlank(c.SuppliedEmail)) {
                                            if(setOfEmailsToBeFiltered.contains(c.SuppliedEmail.toLowerCase().trim()))
                                                isOutOfOffices = true;  
                                        }
                                        //Upto here
                                        
                                        //Checking for boolean variable value and if it is true it means that record will be deleted in future
                                        //Since of "Out of Offices" type
                                        if(isOutOfOffices)
                                            casesToBeDeleted.add(c);
                                    }
                             }
           }
        
        //Checking list for it size value'
        if(casesToBeDeleted.size() > 0) {
            Util.byPassAllTriggers = true;
            delete casesToBeDeleted;
            Util.byPassAllTriggers = false;
        }
    }
    
    /**
    *  @description    :   Method to manage the tasks for the Syndicated Service type cases on insert and update.
    * 
    *  @args           :   List of cases, Map of Cases
    * 
    *  @return         :   void
    * 
    *  @revision Log   :   V1.0 - Added By - Abhinav Sharma - CR-20141001-7574 - 10/15/2014
    *                      V1.1 - Modified By - Subhash Garhwal - CR-20161130-10509 - 12/21/2016 
    *             	   V1.2 - Modified By - Abhinav Sharma - CR-20170222-10716 - 4/24/2017 
    * 			   V1.3 - Modified By - Colin McGloin - CR-20210126-14845 - 01/26/2021 - Commented out Code - no longer needed after CR-20200217-13756 changes 
    *  
    **/ 
    //Added By - Abhinav Sharma - CR-20141001-7574 - 10/15/2014
    /*public static void manageTasksForSyndicatedServiceCases(List<Case> newCases, Map<Id, Case> mapOldCases) {
        
        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: Syndicated Services
        //Query for the record type
        //Id caseSyndicatedServiceRTId = Util.RecordTypeId(Constants.CASE_OBJECT, 'Syndicated Services');
        Id taskGeneralRTId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        //Commented By mahendra Swarnkar - 03/04/2020 - CR-20200217-13756 : RecordType deleted
        //Merged By - Rajeev Jain - 07/05/2017
        //Added By - Abhinav Sharma - CR-20170222-10716 - For International - Speaker Request cases
        //Id caseInternationalSpeakerRequestId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International - Speaker Request').getRecordTypeId();
        
        
        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: Syndicated Services
        //Checking if record type exists or not
        //Modified By - Abhinav Sharma - CR-20170222-10716 - For International - Speaker Request cases
        if(/*(caseSyndicatedServiceRTId != null || caseInternationalSpeakerRequestId != null) && taskGeneralRTId != null) {
            //Merged By - Rajeev Jain - 07/05/2017 - upto here
            
            //Set to hold the case records Ids
            Map<Id, Case> mapCasesForTasksInsert = new Map<Id, Case>();
            Map<string, List<Task>> mapCasesForTasksUpdate = new Map<string, List<Task>>();
            
            //List of tasks to be deleted
            List<Task> tasksToBeDeleted = new List<Task>();
            
            //Modified By - Mahendra Swarnkar - CR-20170217-10702 - 03/18/2017 - Start here 
            //Set to hold the applicable subjects for the tasks
            Set<string> setCaseSubjects = new Set<String>();
            setCaseSubjects.add(System.Label.Syndicated_Cases_Tasks_1);
            setCaseSubjects.add(System.Label.Syndicated_Cases_Tasks_2);
            setCaseSubjects.add(System.Label.Syndicated_Cases_Tasks_3);
            setCaseSubjects.add(System.Label.Syndicated_Cases_Tasks_4);
            setCaseSubjects.add(System.Label.Syndicated_Cases_Tasks_5);
            setCaseSubjects.add(System.Label.Syndicated_Cases_Tasks_6);
            setCaseSubjects.add(System.Label.Syndicated_Cases_Tasks_7);
            
            //Modified By - Mahendra Swarnkar - CR-20170217-10702 - 03/18/2017 - Stop here  
            
            //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: Syndicated Services
            //Loop through case records
            //Merged By - Rajeev Jain - 07/05/2017 - upto here
            //Modified By - Abhinav Sharma - CR-20170222-10716 - Add condition for the International - Speaker Request cases
            for(Case c : [SELECT ID, OwnerId, RecordTypeId, ContactId,
                          (SELECT ID,OwnerId FROM Tasks WHERE Subject IN : setCaseSubjects AND Status != 'Completed' AND Status != 'Cancelled') 
                          FROM Case WHERE ID IN : newCases AND /*(RecordTypeId =: caseSyndicatedServiceRTId OR RecordTypeId =: caseInternationalSpeakerRequestId) AND OwnerId != null]) {
                              
                              //Insert Case
                              if(mapOldCases == null && (String.valueOf(c.OwnerId).startsWith('005')))
                                  mapCasesForTasksInsert.put(c.Id, c);
                              //Merged By - Rajeev Jain - 07/05/2017 - upto here   
                              //Update Case
                              if(mapOldCases != null && c.OwnerId != mapOldCases.get(c.Id).OwnerId && String.valueOf(c.OwnerId).startsWith('005')) {
                                  
                                  //Insert new tasks if not already exists
                                  if(c.tasks != null && c.tasks.size() > 0) {
                                      for(Task t : c.tasks) {     
                                          if(mapCasesForTasksUpdate.containsKey(c.Id + '-' + c.OwnerId))
                                              mapCasesForTasksUpdate.get(c.Id + '-' + c.OwnerId).add(t);
                                          else
                                              mapCasesForTasksUpdate.put(c.Id + '-' + c.OwnerId, new List<Task>{t}); 
                                      }    
                                  } else {
                                      mapCasesForTasksInsert.put(c.Id, c);
                                  }   
                              }
                              
                              if(mapOldCases != null && c.OwnerId != mapOldCases.get(c.Id).OwnerId && String.valueOf(c.OwnerId).startsWith('00G')) {
                                  if(c.tasks != null && c.tasks.size() > 0)
                                      tasksToBeDeleted.addAll(c.tasks);
                              }
                          }
            
            //Checking for size of list
            if(tasksToBeDeleted.size() > 0) {
                Util.byPassAllTriggers = true;
                delete tasksToBeDeleted;
                Util.byPassAllTriggers = false;
            }
            
            //List to hold the task records
            List<Task> tasks = new List<Task>();
            
            //Checking for the map value
            if(mapCasesForTasksInsert.values().size() > 0) {
                
                //Loop through case records
                for(Case cas : mapCasesForTasksInsert.values()) {
                    
                    //Creating and populating task new instances with field values and then additing to the list for inertion
                    Task task_1 = new Task();
                    task_1.WhatId = cas.id;
                    task_1.OwnerId = cas.OwnerId;
                    task_1.Status = 'Not Started';
                    task_1.Priority = 'Normal';
                    task_1.RecordTypeId = taskGeneralRTId; 
                    task_1.ActivityDate = System.today();
                    task_1.WhoId = cas.ContactId;
                    task_1.Subject = System.Label.Syndicated_Cases_Tasks_1;
                    
                    //Added by Subhash Garhwal CR-20161130-10509 - 12/21/2016
                    task_1.Event_Type__c = 'Member Request';
                    //End
                    
                    Task task_2 = new Task();
                    task_2.WhatId = cas.id;
                    task_2.OwnerId = cas.OwnerId;
                    task_2.Status = 'Not Started';
                    task_2.Priority = 'Normal';
                    task_2.RecordTypeId = taskGeneralRTId; 
                    task_2.ActivityDate = System.today();
                    task_2.WhoId = cas.ContactId;
                    task_2.Subject = System.Label.Syndicated_Cases_Tasks_2;
                    
                    //Added by Subhash Garhwal CR-20161130-10509 - 12/21/2016
                    task_2.Event_Type__c = 'Member Request';
                    //End
                    
                    Task task_3 = new Task();
                    task_3.WhatId = cas.id;
                    task_3.OwnerId = cas.OwnerId;
                    task_3.Status = 'Not Started';
                    task_3.Priority = 'Normal';
                    task_3.RecordTypeId = taskGeneralRTId; 
                    task_3.ActivityDate = System.today();
                    task_3.WhoId = cas.ContactId;
                    task_3.Subject = System.Label.Syndicated_Cases_Tasks_3;
                    
                    //Added by Subhash Garhwal CR-20161130-10509 - 12/21/2016
                    task_3.Event_Type__c = 'Member Request';
                    //End
                    
                    Task task_4 = new Task();
                    task_4.WhatId = cas.id;
                    task_4.OwnerId = cas.OwnerId;
                    task_4.Status = 'Not Started';
                    task_4.Priority = 'Normal';
                    task_4.RecordTypeId = taskGeneralRTId; 
                    task_4.ActivityDate = System.today();
                    task_4.WhoId = cas.ContactId;
                    task_4.Subject = System.Label.Syndicated_Cases_Tasks_4;
                    
                    //Added by Subhash Garhwal CR-20161130-10509 - 12/21/2016
                    task_4.Event_Type__c = 'Member Request';
                    //End
                    
                    Task task_5 = new Task();
                    task_5.WhatId = cas.id;
                    task_5.OwnerId = cas.OwnerId;
                    task_5.Status = 'Not Started';
                    task_5.Priority = 'Normal';
                    task_5.RecordTypeId = taskGeneralRTId; 
                    task_5.ActivityDate = System.today();
                    task_5.WhoId = cas.ContactId;
                    task_5.Subject = System.Label.Syndicated_Cases_Tasks_5;
                    
                    //Added by Subhash Garhwal CR-20161130-10509 - 12/21/2016
                    task_5.Event_Type__c = 'Member Request';
                    //End
                    
                    Task task_6 = new Task();
                    task_6.WhatId = cas.id;
                    task_6.OwnerId = cas.OwnerId;
                    task_6.Status = 'Not Started';
                    task_6.Priority = 'Normal';
                    task_6.RecordTypeId = taskGeneralRTId; 
                    task_6.ActivityDate = System.today();
                    task_6.WhoId = cas.ContactId;
                    task_6.Subject = System.Label.Syndicated_Cases_Tasks_6;
                    
                    //Added by Subhash Garhwal CR-20161130-10509 - 12/21/2016
                    task_6.Event_Type__c = 'Member Request';
                    //End
                    
                    Task task_7 = new Task();
                    task_7.WhatId = cas.id;
                    task_7.OwnerId = cas.OwnerId;
                    task_7.Status = 'Not Started';
                    task_7.Priority = 'Normal';
                    task_7.RecordTypeId = taskGeneralRTId; 
                    task_7.ActivityDate = System.today();
                    task_7.WhoId = cas.ContactId;
                    task_7.Subject = System.Label.Syndicated_Cases_Tasks_7;
                    
                    //Added by Subhash Garhwal CR-20161130-10509 - 12/21/2016
                    task_7.Event_Type__c = 'Member Request';
                    //End
                    
                    //Adding task records to the list
                    tasks.add(task_1); tasks.add(task_2); tasks.add(task_3);
                    tasks.add(task_4); tasks.add(task_5); tasks.add(task_6);
                    tasks.add(task_7);
                }
                
                //Checking for the size value
                if(tasks.size() > 0) {
                    Util.byPassAllTriggers = true;
                    insert tasks;
                    Util.byPassAllTriggers = false;
                }
            }
            
            //Re-Intializing the list of tasks
            tasks = new List<Task>();
            
            //Checking for the map value
            if(mapCasesForTasksUpdate.values().size() > 0) {
                
                //Loop through map keyset
                for(String keyString : mapCasesForTasksUpdate.keySet()) {
                    
                    //Owner Id stamped on the case record
                    String ownerId = keyString.split('-')[1];
                    
                    //Loop through corresponding tasks records
                    for(Task tas : mapCasesForTasksUpdate.get(keyString)) {
                        if(tas.ownerId != ownerId) { 
                            tas.OwnerId = ownerId;
                            tasks.add(tas);
                        }
                    }
                }
                
                //Updating owner Id on the associated tasks
                if(tasks.size() > 0) {
                    Util.byPassAllTriggers = true;
                    update tasks;
                    Util.byPassAllTriggers = false; 
                }
            }
        }
    }*/
    
    //Added By - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651
    /**
    *  @description    :   Method to populate the cases fields for the Talent development type cases on insert and update events.
    * 
    *  @args           :   List of cases, Map of Cases
    * 
    *  @return         :   void
    * 
    **/ 
    public static void populateCaseFields(List<Case> newCases, Map<Id, Case> mapOldCases) {
        
        //Set to hold the Project Ids
        Set<ID> setProjectIds = new Set<ID>();
        
        //Set to hold the All Project Ids
        Set<ID> setAllProjectIds = new Set<ID>();
        
        //Set to hold All Contract Ids
        Set<ID> setContractIds = new Set<ID>();
        
        //Set to hold the subscriptions
        Set<ID> setSubscriptionIDs = new Set<Id>();
        
        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: Talent Development 
        //Case Talent Development Record Type Id
        //Id caseTalentDevelopmentRecordType= Util.RecordTypeId('Case', 'Talent Development');
        
        //Populate the Set 
        for(Case tdCase :newCases) {
            
            //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: Talent Development 
            //Insert and update case
            //Check for the Talent Development record type and Project Source on the Cases
            if(tdCase.RecordTypeId != null /*&& tdCase.RecordTypeId == caseTalentDevelopmentRecordType */){
                
                if( tdCase.Project_Source_MS__c != null){
                    
                    setAllProjectIds.add(tdCase.Project_Source_MS__c);
                    
                    //Populate the Set "setProjectIds"
                    if(mapOldCases == null 
                       || (mapOldCases != null && tdCase.Project_Source_MS__c != mapOldCases.get(tdCase.Id).Project_Source_MS__c ))
                        setProjectIds.add(tdCase.Project_Source_MS__c);
                }
                
                /* Spring CleanUp
                if(tdCase.Contract__c != null)
                setContractIds.add(tdCase.Contract__c);
                
                if(tdCase.Program_Subscription__c != null)
                setSubscriptionIDs.add(tdCase.Program_Subscription__c);
                */
            }   
        }
        
        //Map of contracts
        Map<Id,Contract__c> mapContracts = new Map<Id, Contract__c>();
        
        //Checking set for it's size
        if(setContractIds.size() > 0 )
            mapContracts = new Map<Id,Contract__c>([Select Id, End__c From Contract__c Where Id IN : setContractIds]);
        
        //Map of projects
        Map<Id,Project__c> mapProjects = new Map<Id, Project__c>();
        
        //Check for Size
        if(setAllProjectIds.size() > 0) {
            
            //Map to hold the Project records
            // Comment Out Fields for - CR-20200318-13865
            //Query through Project records
            mapProjects = new Map<Id,Project__c>([Select Id, Name, /*Membership_Advisor_Relationship_Manager__r.Name,*/ Dedicated_Advisor__r.Name/*, Program_Associate__r.Name, 
                                                  Contract_Start_Date__c, 
                                                  Internal_Strat_Session_NPI_Actual__c */
                                                  From Project__c 
                                                  Where Id IN : setAllProjectIds]);
        }
        
        //Map of Subscriptions
        Map<Id, SBQQ__Subscription__c> mapSubscriptions = new Map<Id, SBQQ__Subscription__c>();
        
        //Checking fir its size
        if(setSubscriptionIDs.size() > 0)
            mapSubscriptions = new Map<Id, SBQQ__Subscription__c>([SELECT ID, SBQQ__EndDate__c FROM SBQQ__Subscription__c
                                                                   WHERE ID IN : setSubscriptionIDs]);
        
        //Loop through Case records
        for(Case tdCas :newCases) {
            
            //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: Talent Development 
            //Check for the "Talent Development" Record type 
            if(tdCas.RecordTypeId != null /*&& tdCas.RecordTypeId == caseTalentDevelopmentRecordType*/){
                
                //Check for the Project Source on the case and in the map "mapProjects"
                if(tdCas.Project_Source_MS__c != null) {
                    if( setProjectIds.size() > 0 && setProjectIds.contains(tdCas.Project_Source_MS__c) 
                       && mapProjects != null
                       && mapProjects.size() > 0 
                       && mapProjects.containsKey(tdCas.Project_Source_MS__c) 
                       && mapProjects.get(tdCas.Project_Source_MS__c) != null){
                           
                           //Populate the Case fields
                           //tdCas.RM__c = mapProjects.get(tdCas.Project_Source_MS__c).Membership_Advisor_Relationship_Manager__r.Name;
                           tdCas.DA__c = mapProjects.get(tdCas.Project_Source_MS__c).Dedicated_Advisor__r.Name;
                           // comment Out for CR-20200318-13865
                           //tdCas.Associate__c = mapProjects.get(tdCas.Project_Source_MS__c).Program_Associate__r.Name;
                           
                           //Spring Clean Up - tdCas.No_of_Participants__c = mapProjects.get(tdCas.Project_Source_MS__c).No_of_Participants__c;
                           // tdCas.Cohort_ID__c = mapProjects.get(tdCas.Project_Source_MS__c).Cohort_ID_s__c;
                           
                           /*if(mapProjects.get(tdCas.Project_Source_MS__c).X1_2_Day__c != null)
                            tdCas.Half_Day_or_Full_Day__c = '1/2 Day';
                            else {
                            if(mapProjects.get(tdCas.Project_Source_MS__c).Full_Day__c != null)
                            tdCas.Half_Day_or_Full_Day__c = 'Full Day';
                            else
                            tdCas.Half_Day_or_Full_Day__c = null;
                            }*/
                           
                           //tdCas.Contract_Service_Start__c = mapProjects.get(tdCas.Project_Source_MS__c).Contract_Start_Date__c;
                           //Spring clean up - tdCas.Contract_Service_End__c = mapProjects.get(tdCas.Project_Source_MS__c).Internal_Strat_Session_NPI_Actual__c;
                           //tdCas.Service_Start__c = mapProjects.get(tdCas.Project_Source_MS__c).Service_Date_Start__c; 
                       }
                    
                    //Checking for key existance in the map
                    if(mapProjects.containsKey(tdCas.Project_Source_MS__c)) {
                        
                        //Checking for fields values and key existance in the map
                        //Spring CleanUp
                        /*
                        if(tdCas.Program_Subscription__c != null
                        &&  mapSubscriptions.containsKey(tdCas.Program_Subscription__c)
                        )
                        tdCas.Project_Year__c =  mapProjects.get(tdCas.Project_Source_MS__c).Name +' - ' + mapSubscriptions.get(tdCas.Program_Subscription__c).SBQQ__EndDate__c.year(); 
                        else if(tdCas.Contract__c != null
                        && mapContracts.containsKey(tdCas.Contract__c))
                        tdCas.Project_Year__c =  mapProjects.get(tdCas.Project_Source_MS__c).Name +' - ' + mapContracts.get(tdCas.Contract__c).End__c.year();
                        else
                        tdCas.Project_Year__c =  mapProjects.get(tdCas.Project_Source_MS__c).Name +' - null' ;
                        */
                    } 
                }
                else {
                    
                    //Populate the case fields to default values.
                    //tdCas.RM__c = null;
                    tdCas.DA__c = null;
                    tdCas.Associate__c = null;
                    //Spring Clean Up - tdCas.No_of_Participants__c = null;
                    //tdCas.Cohort_ID__c = null;
                    //tdCas.Half_Day_or_Full_Day__c = null;
                    //tdCas.Contract_Service_Start__c = null;
                    //Spring clean up - tdCas.Contract_Service_End__c = null;
                    //tdCas.Service_Start__c = null;
                    
                    //Checking for fields values and key existance in the map
                    /* Spring CleanUp
                    if(tdCas.Program_Subscription__c != null
                    &&  mapSubscriptions.containsKey(tdCas.Program_Subscription__c)
                    )
                    tdCas.Project_Year__c =  'null -' + mapSubscriptions.get(tdCas.Program_Subscription__c).SBQQ__EndDate__c.year();
                    else if(tdCas.Contract__c != null
                    && mapContracts.containsKey(tdCas.Contract__c)
                    )
                    tdCas.Project_Year__c =  'null -' + mapContracts.get(tdCas.Contract__c).End__c.year();
                    else
                    tdCas.Project_Year__c =  'null - null' ;
                    */
                }
            }   
        }
    }
    
    /**
    *  @description    :   Method to have logic to count the distinct number of TEC Cases associated with a parent contact 
    *            (including the current one)
    * 
    *  @args           :   List of cases, Map of Cases
    * 
    *  @return         :   void
    * 
    **/ 
    //Commented by Mahendra Swarnkar - 03/04/2020 - CR-20200217-13756
    //Added By - Mahendra Swarnkar - 10/17/2016 - CR-20160726-10065
    /*public static void updateContactTECCasesCount(List<Case> newCases) {
        
        //Case Talent Development Record Type I
        Map<String, Id> caseRecordTypesMap = Util.recordtypemap(Constants.CASE_OBJECT);
        //Id caseECRecordType = caseRecordTypesMap.get(CASE_RECORD_TYPE_EXPERT_CENTER_NAME);
        
        //Set to hold Cases Id 
        Map<Id, Contact> mapContactsToUpdate = new Map<Id, Contact>();
        
        //Loop over new records
        for(Case cs : newCases){
            
            //Check for respective RecordType and casse should be related to Contact
            if(cs.RecordTypeId != null && cs.RecordTypeId == caseECRecordType && cs.ContactId != null ){
                
                //Added case Id in Set 
                mapContactsToUpdate.put(cs.ContactId, new Contact(Id = cs.ContactId, TEC_Cases_Count__c = 0));
            }
        }
        
        //Check for map size
        if(mapContactsToUpdate.size() > 0){
            
            //Loop over Contact to get related case related to tha contact.
            for(AggregateResult cse : [SELECT Count(Id) countId, ContactId conId 
                                       FROM Case 
                                       WHERE RecordTypeId =: caseECRecordType 
                                       AND ContactId != null 
                                       AND ContactId IN: mapContactsToUpdate.KeySet() 
                                       GROUP BY ContactId]){
                                           
                                           //Getting ContactId from aggregate result
                                           String conId = String.valueOf(cse.get('conId'));
                                           
                                           //Getting  count values from Aggregate result
                                           Integer totalCount = (Integer) cse.get('countId');
                                           
                                           //update map's Contact instance
                                           mapContactsToUpdate.get(conId).TEC_Cases_Count__c = totalCount;
                                       }
            
            //Check for map and update map contact value
            if(mapContactsToUpdate.size() > 0) {
                Util.byPassAllTriggers = true;
                update mapContactsToUpdate.values();
                Util.byPassAllTriggers = false;
            }
        }
    }*/
    
    /**
    *  @description    :   Method to Sent an email to parent case owner  whenever the child case is closed (only for eTech Support record Type) 
    *                      
    * 
    *  @args           :   List of new cases, Map of old Cases
    * 
    *  @return         :   void
    * 
    **/ 
    //Added By - Mahendra Swarnkar - 10/20/2016 - CR-20160209-9593
    public static void sentEmailToParentCaseOwnerOnChildClosed(List<Case> newCases, Map<Id, Case> oldMapCases) {
        if(!IS_ALREADY_SENT_EMAIL_ONCE){
            
            //Set of Eligible caseIds which are clsed and related to eTech Support record type
            Set<Id> setEligibleCaseIds = new Set<Id>();
            
            //Loop over the new case
            for(Case cas : newCases){
                
                //Check for record type
                if(cas.RecordTypeId != null 
                   && cas.RecordTypeId == Util.RecordTypeId('Case', 'eTech Support')){
                       
                       //Insrt and update case
                       if(
                           oldMapCases == null 
                           || 
                           (
                               oldMapCases != null 
                               && cas.isClosed != oldMapCases.get(cas.Id).isClosed
                           )
                       ){
                           //Populate the set for eligible cases id
                           if(cas.isClosed && cas.ParentId != null)
                               setEligibleCaseIds.add(cas.Id);
                       }
                   }
            }
            
            //Check for size
            if(setEligibleCaseIds.size() > 0){
                
                //List of eligible cases to be sent an email to their parent case owner
                List<Case> listEligibleCases = new List<Case> ();
                
                //Map parent owner Id with it's emailId
                Map<Id, String> mapParentCaseOwnerIdWithEmail = new Map<Id, String>();
                
                //Query through the case records to fetch those case records and parent case records details
                for(Case cas1: [Select Id, ParentId, Parent.OwnerId, Parent.Owner.Name , Parent.Owner.Email, Subject, Status, Description
                                From Case where RecordType.DeveloperName = 'eTech_Support' 
                                AND ParentId != null AND Id != null AND Id IN : setEligibleCaseIds]
                   ) {
                       
                       // Populate the list of eligible cases  and mapParentCaseOwnerIdWithEmail 
                       if(cas1.Parent.OwnerId != null && String.isNotBlank(cas1.Parent.Owner.Email)){  
                           listEligibleCases.add(cas1);
                           mapParentCaseOwnerIdWithEmail.put(cas1.ParentId, cas1.Parent.Owner.Email ); 
                       }
                   }
                
                //Fetch the Email Template "Child_Case_Completed" record
                List<EmailTemplate> emailTemplates = [Select Id From EmailTemplate where DeveloperName = 'Child_Case_Completed' AND IsActive = true];
                
                Map<String, Contact> mapUserEmailwithContact;
                
                if(mapParentCaseOwnerIdWithEmail != null 
                   && mapParentCaseOwnerIdWithEmail.size() > 0
                   && mapParentCaseOwnerIdWithEmail.values() != null
                   && mapParentCaseOwnerIdWithEmail.values().size() > 0
                  ){
                      mapUserEmailwithContact  = CreateDummyContact(mapParentCaseOwnerIdWithEmail.values());
                  }
                
                //check for size
                if(emailTemplates != null 
                   && emailTemplates.size() > 0
                   && listEligibleCases.size() > 0
                   && mapUserEmailwithContact != null
                   && mapUserEmailwithContact.size() > 0
                  ) {     
                      
                      //Fetch From Address 
                      List<OrgWideEmailAddress> listOrgWideEmailAdd = [select Id from OrgWideEmailAddress where Address = 'applicationsupport@advisory.com'];
                      
                      //Create a list of SingleEmailMessage instance
                      List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                      
                      //Loop through case records
                      for(Case ca : listEligibleCases) {
                          
                          //Set to hold the Email address of all parent case Owners
                          List<String> toAddressParentCaseOwnerEmail = new List<String>();
                          
                          //Check for parent case owner email
                          if( ca.ParentId != null
                             && mapParentCaseOwnerIdWithEmail != null 
                             && mapParentCaseOwnerIdWithEmail.size() > 0
                             && mapParentCaseOwnerIdWithEmail.containsKey(ca.ParentId)
                             && String.IsNotBlank(mapParentCaseOwnerIdWithEmail.get(ca.ParentId))
                             && mapUserEmailwithContact.containsKey(mapParentCaseOwnerIdWithEmail.get(ca.ParentId))
                             && mapUserEmailwithContact.get(mapParentCaseOwnerIdWithEmail.get(ca.ParentId)) != null
                            ){
                                //Populating the List of to address
                                toAddressParentCaseOwnerEmail.add(mapParentCaseOwnerIdWithEmail.get(ca.ParentId));
                                
                                //Create an Email by providing various details like template Id, to address, target Object Id etc.
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                mail.setTemplateId(emailTemplates[0].Id);
                                mail.setToAddresses(toAddressParentCaseOwnerEmail);
                                mail.setWhatId(ca.Id);
                                
                                mail.setTargetObjectId(mapUserEmailwithContact.get(mapParentCaseOwnerIdWithEmail.get(ca.ParentId)).Id);
                                
                                //Set the false so that no activity records can be created when an email is sent 
                                mail.setSaveAsActivity(false);
                                
                                //Setting From Address
                                if(listOrgWideEmailAdd != null && listOrgWideEmailAdd.size() > 0 )
                                    mail.setOrgWideEmailAddressId(listOrgWideEmailAdd[0].Id);
                                
                                //Populating the emails
                                emails.add(mail);
                            }
                      }
                      
                      //Check for size
                      if(emails.size() > 0){
                          
                          //Send emails to respective emails addresses
                          Messaging.sendEmail(emails);
                          
                          //Once the email sent successfully then delete all the dummy contact that are created via CreateDummyContact
                          if(listDummyContact != null && listDummyContact.size() > 0) {
                              Util.byPassAllTriggers = true;
                              delete listDummyContact;
                              Util.byPassAllTriggers = false;
                              
                              //Re initialise the cummy contact list.
                              listDummyContact = new List<Contact>();
                          }
                      }
                  }
            }
            
            //Set the boolean flag
            IS_ALREADY_SENT_EMAIL_ONCE = True;
        }
    }
    
    /**
    *  @description    :   Method to create dummy contact if no contact is there in the org with the provided emailId 
    * 
    *  @args           :   List Email IDs
    * 
    *  @return         :   Map of EmailIds as a key and contact as value
    * 
    **/ 
    //Added By - Mahendra Swarnkar - 10/20/2016 - CR-20160209-9593
    public static Map<String,Contact> CreateDummyContact(List<String> EmailAddress) {
        
        //MAp to hold the User emails as a key and its relaed conact as value
        Map<String, Contact> mapUserEmailwithContact = new Map<String, Contact>();
        
        //List to hold the Dummy contacts (these will be created for those Users whose related contact is not found in the database)
        listDummyContact = new List<Contact>();
        
        //Check for size
        if(EmailAddress != null && EmailAddress.size() > 0){
            
            //Query through contact records means contact with matching emails 
            for(Contact con : [SELECT Id, Email FROM Contact WHERE Email != null AND Email IN : EmailAddress]){
                
                //check for null/blank and then populate the map mapUserEmailwithContact if contacts are found
                if(String.isNotBlank(con.Email)){
                    mapUserEmailwithContact.put(con.Email,con);
                }
            }
            
            //Loop over the list of all emails and create the dummy contacts for those emails which are not found on any of the contact on any of the conatct in the system.
            for(String ema : EmailAddress){
                
                //check if map have the key value for the email if so then continue
                if(mapUserEmailwithContact.size() > 0 && mapUserEmailwithContact.containsKey(ema))
                    continue;
                
                // create the dummy contact for the email.
                else{
                    contact con = new contact();            
                    con.LastName = ema;
                    con.Email = ema;
                    //Added phone and title to resolve validation error
                    con.Phone = '614-555-8855';
                    con.Title = 'CEO';
                    con.Description = '@@ Contact auto-created from CaseEmailController for purposes of data integrity (Activity would not be generated if there was no contact to associate the email to)';        
                    listDummyContact.add(con);
                }
            }
            
            //check for the size 
            if(listDummyContact.size() > 0){
                
                //Insert Dummy contacts
                Util.byPassAllTriggers = true;
                insert listDummyContact;
                Util.byPassAllTriggers = false;
                
                //populate the map for dummy contact
                for(Contact cont : listDummyContact){
                    if( String.isNotBlank(cont.Email) && cont.Id != null)
                        mapUserEmailwithContact.put(cont.Email, cont);
                }
            }
        }
        
        //return the map
        return mapUserEmailwithContact;
    }
    
    
    /**
     *  @description    :   Method used to populate the Entity field value
     *                      1) Populate the Entity__c = HC for following Case record types:- 
     *                          ABI Research Requests, Consulting & Management Request, Expert Center, International - Speaker Request, PIC Support, PT Data Load, PT Support Request, Syndicated Services, Talent Development
     *                      2) Populate the Entity__c = EAB for following Case record types:- 
     *                           Ask EAB, EAB Onsite Request
     *                      3) For Record Type = Member & Employee Support :- 
     *                          if Origin = EAB Meetings, then Entity=EAB, Else Entity=HC 
     *                      4) For Record Type = WebHelp :- 
     *                          if 'Type = EAB' OR 'Web Email contains @EAB.com', then Entity=EAB, Else Entity=HC  
     *                      5) For Record Type = 'IRC Request' OR 'eTech Support' :- 
     *                          if Web Email contains 'Advisory.com', then Entity=HC, Else Entity=EAB 
     * 
     *  @args           :   List of new Case records, Map of old Case records
     * 
     *  @return         :   void
     * 
     *  @Revision Log   :   V1.0 - Created By - Mahendra Swarnkar - 10/12/2017 - CR-20170929-11625 - Apollo Release
     *                      V1.1 - Created By - Subhash Garhwal - 10/12/2017 - CR-20171208-11837 - Update Entity logic
     **/
    public static void populateEntityField(List<Case> newCases, Map<Id, Case> mapOldCases) {
        
        //Commented by Mahendra Swarnkar - 03/04/2020 - CR-20200217-13756 : PIC_Support, Syndicate Services
        //Set to hold the Case record type names for HC
        Set<String> setRTypeForHC = new Set<String>{'International', /*'Consulting_Management_Request',*/ 'Expert_Center', 'International_Speaker_Request', /*'PIC_Support',*/ 'PT_Data_Load', 'PT_Support_Request', /*'Syndicated_Services',*/ 'Talent_Development'};
            
        //Set to hold the HC Record Type Ids
        Set<Id> setRTypeIdForHC = new Set<Id>();
        
        //Set to hold the Case record type names for EAB
        Set<String> setRTypeNameForEAB = new Set<String>{'EAB_Custom', 'EAB_Onsite_Request'} ;
            
        //Set to hold the HC Record Type Ids
        Set<Id> setRTypeIdForEAB = new Set<Id>();
        
        //Map to hold the Case Record Types
        Map<Id, RecordType> mapCaseRecordTypes = new Map<Id, RecordType>([Select Id, Name, DeveloperName From RecordType Where SobjectType = 'Case']);
        
        //get map of all related accounts, so we can use the related Account.Entity__c to determine entity value
        Set<Id> acctIds = new Set<Id>();
        Map<Id, Account> acctMap;
        for (Case c : newCases) {
            if (c.AccountId != null) acctIds.add(c.AccountId);
        }
        if (acctIds.size() > 0) acctMap = new Map<Id, Account>([SELECT Id, Entity__c FROM Account WHERE Id IN :acctIds]);
        
        //Loop over the record Types
        for(RecordType rT : mapCaseRecordTypes.values()) {
            
            //Check Record Type Name in set
            if(setRTypeForHC.contains(rT.DeveloperName))
                setRTypeIdForHC.add(rT.Id);
            
            //Check Record Type Name in set
            if(setRTypeNameForEAB.contains(rT.DeveloperName))
                setRTypeIdForEAB.add(rT.Id);    
        }
        
        //Query on Cases
        for(Case cas : newCases) {
            
            // VH 10/20/17 - Issue--CR11625--QA--00007063 - Determine case sharing by Account.Entity, if it's populated.
            if (acctMap != null && cas.AccountId != null && acctMap.containsKey(cas.AccountId)) {
                Account acct = acctMap.get(cas.AccountId);
                if (acct.Entity__c == 'EAB' || acct.Entity__c == 'HC') {
                    cas.Entity__c = acct.Entity__c;
                    continue;
                }
            }
            
            //Check for record Type
            if(cas.RecordTypeId != null) {
                
                if(setRTypeIdForHC != null && setRTypeIdForHC.contains(cas.RecordTypeId)) {
                    
                    //Update the ENtity to HC
                    cas.Entity__c = 'HC';
                }
                
                //check for the recordType
                if(setRTypeIdForEAB != null && setRTypeIdForEAB.contains(cas.RecordTypeId)) {
                    
                    //Update the ENtity to EAB
                    cas.Entity__c = 'EAB';
                }
                
                //check for the recordType
                if(mapCaseRecordTypes.containsKey(cas.RecordTypeId) && mapCaseRecordTypes.get(cas.RecordTypeId).DeveloperName == 'Member_Employee_Support') {
                    
                    //Check for origin
                    if(String.isNotBlank(cas.Origin) && cas.Origin == 'EAB Meetings'){
                        
                        //Update the ENtity to EAB
                        cas.Entity__c = 'EAB';   
                    } else {
                        
                        //Update the ENtity to HC
                        cas.Entity__c = 'HC';
                    }
                }
                
                //check for the recordType
                if(mapCaseRecordTypes.containsKey(cas.RecordTypeId) && mapCaseRecordTypes.get(cas.RecordTypeId).DeveloperName == 'WebHelp') {
                    
                    String WebEmail = cas.SuppliedEmail;
                    
                    //Check for '@eab.com'
                    //Subhash Garhwal - 12/08/2017 - CR-20171208-11837 - Added Origin condition
                    if((String.isNotBlank(cas.Type) && cas.Type == 'EAB') || (String.IsNotBlank(WebEmail) && WebEmail.containsIgnoreCase('@EAB.com')) || (String.isNotBlank(cas.Origin) && cas.Origin == 'EAB')){
                        
                        //Update the ENtity to EAB
                        cas.Entity__c = 'EAB';    
                    } 
                    else {
                        
                        //Update the ENtity to HC
                        cas.Entity__c = 'HC';
                    }
                }
                
                //Commented by Mahendar Swarnkar - 03/05/2020 - CR-20200217-13756 : IRC Request
                //check for the recordType
                if(mapCaseRecordTypes.containsKey(cas.RecordTypeId) && (/*mapCaseRecordTypes.get(cas.RecordTypeId).DeveloperName == 'IRC_Request' ||*/ mapCaseRecordTypes.get(cas.RecordTypeId).DeveloperName == 'eTech_Support')) {
                    
                    //String to hold the SuppliedEmail
                    String WebEmail = cas.SuppliedEmail;
                    
                    //Check for '@Advisory.com'
                    if(String.IsNotBlank(WebEmail) && WebEmail.containsIgnoreCase('@Advisory.com')){
                        
                        //Update the ENtity to HC
                        cas.Entity__c = 'HC';    
                    } 
                    else {
                        
                        //Update the ENtity to EAB
                        cas.Entity__c = 'EAB';
                    }
                }
            }
        }
        
        //Added by Colin McGloin -  - Set Flag to True to avoid recursion for SOQL Consumption
        BYPASS_TRIGGER_CASE_ENTITY_POPULATION = true;
        
    }
    
    /**
     *  @description    :   Method used to send an email alert, if the contact created
     *                      
     *  @args           :   List of new Case records
     * 
     *  @return         :   void
     * 
     *  @Revision Log   :   Created by Abhinav sharma - 10/11/2018 - CR-20180928-12623
     **/
    public static void checkIfCaseIsWebHelp(List<Case> newCases) {
        
        //Set to hold the case which is web help type. 
        Set<Id> setWebHelpCaseContactIds = new Set<Id>();
        Set<String> setWebHelpCaseWebEmail = new Set<String>();
        
        //Checking for the new List of contact. 
        for(Case cse :  newCases) {
            
            //checking for the record type Id, where contact Id is not null.
            if(cse.RecordTypeId == Constants.CASE_WEBHELP_RT_ID && (String.isNotBlank(cse.ContactId) || String.isNotBlank(cse.SuppliedEmail))) {
                setWebHelpCaseContactIds.add(cse.ContactId);
                setWebHelpCaseWebEmail.add(cse.SuppliedEmail);
            }
            
        }   
        //Checking for the set size. 
        if((setWebHelpCaseContactIds != null && setWebHelpCaseContactIds.size() > 0) 
           || (setWebHelpCaseWebEmail != null && setWebHelpCaseWebEmail.size() > 0))
            //Calling a future method that will check how many cases  this contact created in the current month, 
            sendEmailToWebHelpManagers(setWebHelpCaseContactIds, setWebHelpCaseWebEmail);
    }
    
    /**
     *  @description    :   Method used to send an email alert to the webhelp case
     *                      
     *  @args           :   Set of case ids.
     * 
     *  @return         :   void
     * 
     *  @Revision Log   :   Created by Abhinav sharma - 10/11/2018 - CR-20180928-12623
     **/
    @future
    public static void sendEmailToWebHelpManagers(Set<Id> setWebHelpCaseContactIds, Set<String> setWebHelpCaseWebEmail) {
        
        //Map to hold the Contact Ids with the Case Ids which were created in the particular case. 
        map<Id, List<Case>> mapLastMonthWebHelpCaseWithContactIds = new map<Id, List<Case>>();
        map<String, List<Case>> mapLastMonthWebHelpCaseWithWebEmailAddress = new map<String, List<Case>>();
        
        //Map to hold the Contact information with the id as a Key
        map<Id, String> mapContactDetails = new map<Id, String>();
        
        //map to hold the Institution name with the Web Email address. 
        map<String, String> mapWebEmailWithInstituion = new map<String, String>();
        
        //check for the set size. 
        if((setWebHelpCaseContactIds != null && setWebHelpCaseContactIds.size() > 0) || (setWebHelpCaseWebEmail != null && setWebHelpCaseWebEmail.size() >0)) {
            
            //Loop on the Cases to get all the case details with respect to the Contact. for Current Month 
            for(Case cse : [Select Id, SuppliedEmail,  ContactId, Contact.Name, Account.Name, CaseNumber From Case 
                            Where (ContactId IN: setWebHelpCaseContactIds OR SuppliedEmail IN : setWebHelpCaseWebEmail) 
                            AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_WEBHELP 
                            AND CreatedDate = LAST_N_DAYS:30 order By ContactId ]) {
                                
                                //Check for the ContactId is blank.
                                if(String.isNotBlank(cse.ContactId)) {
                                    
                                    //Check for the Map which contains the valid ids
                                    if(!mapLastMonthWebHelpCaseWithContactIds.containsKey(cse.ContactId) )
                                        //Map to hold the Last Month WebHelp Case for the perticular Contact        
                                        mapLastMonthWebHelpCaseWithContactIds.put(cse.ContactId, new List<Case>());
                                    
                                    //Adding value to the map.
                                    mapLastMonthWebHelpCaseWithContactIds.get(cse.ContactId).add(cse);
                                }else if(String.isNotBlank(cse.SuppliedEmail)){
                                    
                                    //Check for the Map which contains the valid ids
                                    if(!mapLastMonthWebHelpCaseWithWebEmailAddress.containsKey(cse.SuppliedEmail) )
                                        //Map to hold the Last Month WebHelp Case for the perticular Contact        
                                        mapLastMonthWebHelpCaseWithWebEmailAddress.put(cse.SuppliedEmail, new List<Case>());
                                    
                                    //Adding value to the map.
                                    mapLastMonthWebHelpCaseWithWebEmailAddress.get(cse.SuppliedEmail).add(cse);
                                }
                                
                                //Checking if the map is containing contact Id previously
                                if(!mapContactDetails.containsKey(cse.ContactId) && String.isNotBlank(cse.ContactId))
                                    mapContactDetails.put(cse.ContactId, cse.Contact.Name + '@@@@' + cse.Account.Name);
                                
                                //Check for the mapWebEmailWithInstituion contains and WebEmail Address is not blank. 
                                if(String.isNotBlank(cse.SuppliedEmail) &&  String.isBlank(cse.ContactId))
                                    mapWebEmailWithInstituion.put(cse.SuppliedEmail, '');
                                
                            }
            
            //Check for the mapWebEmailWithInstituion size
            if(mapWebEmailWithInstituion.size() > 0) {
                
                //set to hold the Domians. 
                set<String> setDomains = new set<String>();
                
                for(String mail : mapWebEmailWithInstituion.keyset()) {
                    
                    //Check if email contains @
                    if(String.isNotBlank(mail) && mail.contains('@'))
                        setDomains.add(mail.split('@')[1]);
                }
                
                
                Map<String, List<Eligible_Domain__c>> mapEligibleDomains = new Map<String, List<Eligible_Domain__c>>();
                
                //Query on the Instituion and Parent Institution to get the info. 
                for(Eligible_Domain__c eD : [Select Id, Account__c, Account__r.Name, Account__r.ParentId, Account__r.Parent.Name, Qualified_Domain__c From Eligible_Domain__c
                                             Where Is_Included__c = true AND Qualified_Domain__c IN :setDomains ]) {
                                                 
                                                 //Checking for the 
                                                 if(!mapEligibleDomains.containsKey(eD.Qualified_Domain__c))
                                                     mapEligibleDomains.put(eD.Qualified_Domain__c, new List<Eligible_Domain__c>());
                                                 
                                                 //Adding values to the map
                                                 mapEligibleDomains.get(eD.Qualified_Domain__c).add(eD); 
                                                 
                                             }
                
                //Loop on the map. 
                for(String email : mapWebEmailWithInstituion.keySet()) {
                    
                    //check if map contains this 
                    for(String domain  : mapEligibleDomains.keyset()) {
                        //check if the Email contains the domain 
                        if(email.contains(domain) && email.endsWith(domain) && mapEligibleDomains.get(domain) != null && mapEligibleDomains.get(domain).size() == 1) 
                            mapWebEmailWithInstituion.put(email, mapEligibleDomains.get(domain)[0].Account__r.Name);    
                        
                        
                    }
                }
            }
            
            //List to send the Email instances
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            
            //Check the size of Map 
            if(mapLastMonthWebHelpCaseWithContactIds != null && mapLastMonthWebHelpCaseWithContactIds.size() > 0 
               && mapContactDetails != null && mapContactDetails.size() > 0) {
                   
                   //Loop on the map. 
                   for(Id ContactId : mapLastMonthWebHelpCaseWithContactIds.keySet()) {
                       
                       //Single Instance for the Email
                       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                       
                       //Check for th map if the map contains the Contact ID
                       if(mapContactDetails.containsKey(ContactId) && mapContactDetails.get(ContactId) != null && mapContactDetails.get(ContactId).contains('@@@@') 
                          && mapLastMonthWebHelpCaseWithContactIds.get(ContactId) != null && mapLastMonthWebHelpCaseWithContactIds.get(ContactId).size() >= 3) {
                              
                              
                              //String to hold the Email Body send to the Contacts. 
                              String emailBody = createEmailBody(mapContactDetails.get(ContactId).split('@@@@')[0], 
                                                                 mapContactDetails.get(ContactId).split('@@@@')[1],  
                                                                 mapLastMonthWebHelpCaseWithContactIds.get(ContactId));    
                              
                              //Setting the To Address             
                              mail.setToAddresses(getReceipientForWelHelpCasesIncreaseCount(mapLastMonthWebHelpCaseWithContactIds.get(ContactId).size()));
                              //Setting the Subject
                              mail.setSubject('Urgent: ' + mapLastMonthWebHelpCaseWithContactIds.get(ContactId).size() + ' cases for a contact within a month');
                              mail.setPlainTextBody(emailBody);
                              allmsg.add(mail);
                          }
                   }   
               }
            
            
            //Check the size of Map 
            if(mapLastMonthWebHelpCaseWithWebEmailAddress != null && mapLastMonthWebHelpCaseWithWebEmailAddress.size() > 0 
               && mapWebEmailWithInstituion != null && mapWebEmailWithInstituion.size() > 0) {
                   
                   //loop on the mapLastMonthWebHelpCaseWithWebEmailAddress if it contains the web Address?
                   for(String webAddress : mapLastMonthWebHelpCaseWithWebEmailAddress.keyset()) {
                       
                       //Single Instance for the Email
                       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                       
                       if(mapWebEmailWithInstituion != null && mapWebEmailWithInstituion.containsKey(webAddress) 
                          && mapWebEmailWithInstituion.get(webAddress) != null &&  mapLastMonthWebHelpCaseWithWebEmailAddress.get(webAddress).size() >= 3) {
                              
                              //String to hold the Email Body send to the Contacts. 
                              String emailBody = createEmailBody(webAddress, 
                                                                 mapWebEmailWithInstituion.get(webAddress),  
                                                                 mapLastMonthWebHelpCaseWithWebEmailAddress.get(webAddress));    
                              //Check for the Email Body is blank
                              if(String.isBlank(emailBody))
                                  continue;
                              
                              //Setting the To Address               
                              mail.setToAddresses(getReceipientForWelHelpCasesIncreaseCount(mapLastMonthWebHelpCaseWithWebEmailAddress.get(webAddress).size()));
                              
                              //Setting the Subject
                              mail.setSubject('Urgent: ' + mapLastMonthWebHelpCaseWithWebEmailAddress.get(webAddress).size() + ' cases for a contact within a month');
                              mail.setPlainTextBody(emailBody);
                              allmsg.add(mail);                           
                          }
                   }   
               }
            
            //Checking the size of the list
            if(allmsg != null && allmsg.size() > 0)
                Messaging.sendEmail(allmsg);
        }   
    }
     
     /**
     *  @description    :   Method used to create the Email Body. 
     *                      
     *  @args           :  
     * 
     *  @return         :   void
     * 
     *  @Revision Log   :   Created by Abhinav sharma - 10/11/2018 - CR-20180928-12623
     **/
    public static String createEmailBody(String contactName, String accountName, List<Case> cases) {
        
        //String that hold the Final Message in this Variable.
        String FINAL_MESSAGE = '';
        
        //Check that we have enough info to create the message.
        if(String.isNotBlank(contactName) && cases != null && cases.size() > 0) {
            
            //variables to hold the basic Information. 
            String HELLO_MESSAGE = 'Hello,\n\n';
            String MESSAGE_Line1 = 'As of today it appears that ';
            String MESSAGE_Line2 = 'with  ';
            String MESSAGE_LINE3 = 'now has had ';
            String MESSAGE_LINE4 = 'submitted cases within this month.  Please review the attached cases and reach out to the member as necessary.\n';  
            String CASE_LINK  = ''; 
            String BLANK_SPACE = ' ';
            String THANK_YOU = 'Thank You';
            String BASE_URL =  System.URL.getSalesforceBaseURL().toExternalForm();
            String INSTITUTION_NAME = '';
            
            //For loop on the Case Records.     
            for(Case webhelpCase : cases) {
                
                //Creating the Case links for the Email Body.
                CASE_LINK += webhelpCase.CaseNumber + ' - ' + BASE_URL + '/' + webhelpCase.Id + '\n\n'; 
            }
            
            //Check for the institution Name.
            if(String.isNotBlank(accountName))
                INSTITUTION_NAME =  MESSAGE_Line2 + '"'  + accountName + '"' + BLANK_SPACE;
            
            //Creating the Final message and merge all the variables. 
            FINAL_MESSAGE = HELLO_MESSAGE + MESSAGE_Line1 + '"' + contactName + '"'  + BLANK_SPACE + INSTITUTION_NAME 
                            + MESSAGE_LINE3 + cases.size() + BLANK_SPACE + MESSAGE_LINE4 + '\n' + CASE_LINK + '\n\n' + THANK_YOU;  
        }
        
        
        return FINAL_MESSAGE;
    }
     /**
     *  @description    :   Method used to create the receipient List
     *                      
     *  @args           :  
     * 
     *  @return         :   void
     * 
     *  @Revision Log   :   Created by Abhinav sharma - 10/11/2018 - CR-20180928-12623
     **/
    private static List<String> getReceipientForWelHelpCasesIncreaseCount(Integer casesThisMonth) {
        
        //List to hold the final list of receipient as per the case count. 
        List<String> recipientEmails = new List<String>();
        
        //check for the incoming caseCountThis Month
        if(casesThisMonth == 3) {
            //Adding the Email receipient.    
            recipientEmails.add(Label.WEB_HELP_3_CASES_IN_MONTH_RECEIPIENT);
        }else if(casesThisMonth == 4) {
            //Adding the Email receipient.              
            recipientEmails.add(Label.WEB_HELP_3_CASES_IN_MONTH_RECEIPIENT);
            recipientEmails.add(Label.WEB_HELP_4_CASES_IN_MONTH_RECEIPIENT);
            recipientEmails.add(Label.WEB_HELP_4_CASES_IN_MONTH_RECEIPIENT_2);  
        }else if(casesThisMonth >= 5) {
            //Adding the Email receipient.              
            recipientEmails.add(Label.WEB_HELP_3_CASES_IN_MONTH_RECEIPIENT);
            recipientEmails.add(Label.WEB_HELP_4_CASES_IN_MONTH_RECEIPIENT);    
            recipientEmails.add(Label.WEB_HELP_4_CASES_IN_MONTH_RECEIPIENT_2);
            recipientEmails.add(Label.WEB_HELP_5_CASES_IN_MONTH_RECEIPIENT);    
            
        }
        
        return recipientEmails; 
    }

    /**
     *  @description    :   Method used to popolate fields(Website_Content_Owner__c, Website_Feature_Owner__c) if field is null.
     *                      
     *  @args           :   List of new Case records
     * 
     *  @return         :   void
     * 
     *  @Revision Log   :   Created by Abhinav sharma - 09/06/2019
     *                      Modified by Neha Sharma - 03/24/2021 - CR-20210324-15019 - comment the logic which run on the basis 'Rachel Brink', 'Andrea Alvarez' user
     *                      Modified by Neha Sharma   - 03/09/2021 - CR-20201207-14726 - Populate the cappex partner success manager on case
     **/
    public static void populateLookupFields(List<Case> newCases, Map<Id,Case> oldMapOfCase) {
        
        //Set decleared to store Related Account Id
        Set<Id> setOfRelatedAccId = new Set<Id>();
        
        // to hold cappex case ids
        Map<Id, List<Case>> mapOfAccountIdWithCases = new Map<Id, List<Case>>();
        
        //Modified by Neha Sharma - 03/24/2021 - CR-20210324-15019 - comment the logic which run on the basis 'Rachel Brink', 'Andrea Alvarez' user                
        //List of users
        //List<User> users = [Select Id, Name from User Where Name IN ('Rachel Brink', 'Andrea Alvarez')];
        
        //Loop over the Cases
        for(Case theCase : newCases){
            // Modified by Neha Sharma - 03/24/2021 - CR-20210324-15019 - comment the logic which run on the basis 'Rachel Brink', 'Andrea Alvarez' user
            // Start here
            //Insert Use Case
            /*if(oldMapOfCase == Null){
            for(User usr : users){
            if(theCase.Website_Content_Owner__c == null && theCase.RecordTypeId == constants.CASE_WEBHELP_RT_ID && usr.Name == 'Rachel Brink'){
            theCase.Website_Content_Owner__c = usr.Id;
            }
            
            if(theCase.Website_Feature_Owner__c == null && theCase.RecordTypeId == constants.CASE_WEBHELP_RT_ID && usr.Name == 'Andrea Alvarez'){
            theCase.Website_Feature_Owner__c = usr.Id;
            }
            }
            }*/
            //End here - CR-20210324-15019
            
            //insert/update use case
            if(theCase.RecordTypeId == constants.CASE_CAPPEX_REQUESTS_RT_ID && (oldMapOfCase == null || (oldMapOfCase != null && (oldMapOfCase.get(theCase.Id).RecordTypeId != theCase.RecordTypeId
                                                                                                                                  || oldMapOfCase.get(theCase.Id).Cappex_Partner_Success_Manager_Email__c != theCase.Cappex_Partner_Success_Manager_Email__c
                                                                                                                                  || oldMapOfCase.get(theCase.Id).AccountId != theCase.AccountId || theCase.Status != oldMapOfCase.get(theCase.Id).Status) ))){
                                                                                                                                      
                                                                                                                                      if(!mapOfAccountIdWithCases.containsKey(theCase.AccountId)) {
                                                                                                                                          mapOfAccountIdWithCases.put(theCase.AccountId, new List<Case>{theCase});
                                                                                                                                      }
                                                                                                                                      else
                                                                                                                                          mapOfAccountIdWithCases.get(theCase.AccountId).add(theCase);
                                                                                                                                  }
        }    
        if(mapOfAccountIdWithCases.size() > 0 && mapOfAccountIdWithCases.KeySet().size() > 0) {
            
            for(Account acc : [SELECT Id, Cappex_Partner_Success_Manager__c,Cappex_Partner_Success_Manager__r.Email
                               FROM Account  Where Id IN : mapOfAccountIdWithCases.keySet() AND Cappex_Partner_Success_Manager__c != null
                               AND Cappex_Partner_Success_Manager__r.Email != null]
                
               ) {
                   if(mapOfAccountIdWithCases.containsKey(acc.Id) && mapOfAccountIdWithCases.get(acc.Id).size() > 0) {
                       
                       for(Case newCase  :  mapOfAccountIdWithCases.get(acc.Id)) {
                           
                           newCase.Cappex_Partner_Success_Manager_Email__c = acc.Cappex_Partner_Success_Manager__r.Email;
                       }
                   }
               }
        }    
    }
    
    /**
     *  @description    :   Method used to popolate case owner and send an email alert, if the contact owner is changed
     *                      
     *  @args           :   List<Case>, Map<Id, Case>
     * 
     *  @return         :   void
     * 
     *  @Revision Log   :   Created by Abhinav sharma - 09/06/2019
     **/
    public static void populateCaseOwner(List<Case> newCases, Map<Id, Case> mapOldCases) {
        
        //Get Record Type
        Id caseWebHelpRecordType = TestUtilities.FindRecordTypeId('Case', 'WebHelp');
        
        // set DML options to send email
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = true;
        
        //List of case to update
        List<Case> casesToUpdate = new List<Case>();
        
        //Map of userId where key is case Id.
        Map<String, String> mapCaseIdWithUserId  = new Map<String, String>();
        
        //Map of Case with boolean value
        Map<String,Boolean> mapCaseIdWithBoolean = new Map<String,Boolean>();
        
        for(Case theCase : newCases){
            
            //Check for insert and update case for Case Category = "Website Content Request/Issue"
            if(theCase.RecordTypeId == caseWebHelpRecordType  && theCase.Case_Category__c == 'Website Content Request/Issue' 
               && (newCases != null || (newCases == null && theCase.Case_Category__c != mapOldCases.get(theCase.Id).Case_Category__c 
                                        && theCase.OwnerId != mapOldCases.get(theCase.Id).OwnerId))){
                                            
                                            //Adding into map
                                            if(!mapCaseIdWithUserId.containsKey(theCase.Id))
                                                mapCaseIdWithUserId.put(theCase.Id, '');
                                            
                                            mapCaseIdWithUserId.put(theCase.Id, theCase.Website_Content_Owner__c);
                                        }
            
            //For Case Category = "Website Feature Request"
            else if(theCase.RecordTypeId == caseWebHelpRecordType && theCase.Case_Category__c == 'Website Feature Request' 
                    && (newCases != null || (newCases == null && theCase.Case_Category__c != mapOldCases.get(theCase.Id).Case_Category__c
                                             && theCase.OwnerId != mapOldCases.get(theCase.Id).OwnerId))){
                                                 
                                                 //Adding into map
                                                 if(!mapCaseIdWithUserId.containsKey(theCase.Id))
                                                     mapCaseIdWithUserId.put(theCase.Id, '');
                                                 
                                                 mapCaseIdWithUserId.put(theCase.Id, theCase.Website_Feature_Owner__c);
                                             }
            
            //For Case Category = "Website Issues"
            else if(theCase.RecordTypeId == caseWebHelpRecordType && theCase.Case_Category__c == 'Website Issues' 
                    && (newCases != null || (newCases == null && theCase.Case_Category__c != mapOldCases.get(theCase.Id).Case_Category__c
                                             && theCase.OwnerId != mapOldCases.get(theCase.Id).OwnerId))){
                                                 
                                                 if(!mapCaseIdWithBoolean.containsKey(theCase.Id))               
                                                     mapCaseIdWithBoolean.put(theCase.Id, true);
                                                 
                                             }
        }
        
        //Size check
        if(mapCaseIdWithUserId.size() > 0 || mapCaseIdWithBoolean.size() > 0){
            //Map of User with UserId.
            Map<Id, User> mapOfActiveUsers = new Map<Id, User>([Select Id ,isActive From User Where Id IN: mapCaseIdWithUserId.values() And isActive = true]);
            
            //Id of queue.
            Id queueId = [Select Id From Group Where Type = 'Queue' AND DeveloperNAME = 'Application_Support'].Id;
            
            for(String caseId : mapCaseIdWithUserId.keySet()){
                if(mapOfActiveUsers.containsKey(mapCaseIdWithUserId.get(caseId))){
                    Case c = new Case(Id = caseId, OwnerId = mapCaseIdWithUserId.get(caseId));
                    //c.setOptions(dlo);                                                
                    casesToUpdate.add(c);
                }
                else{
                    newCases[0].addError(System.Label.USER_IS_INACTIVE);
                }
            }
            
            for(String caseId : mapCaseIdWithBoolean.keySet()){
                if(mapCaseIdWithBoolean.get(caseId) == true){
                    Case c = new Case(Id = caseId, OwnerId = queueId);                                                
                    casesToUpdate.add(c); 
                }
            }
        }
        
        
        //Size check
        if(casesToUpdate.size() > 0){
            
            //Bypass all logic
            Util.byPassAllTriggers = true;
            
            //update
            update casesToUpdate; 
            
            Util.byPassAllTriggers = false;
        }
    }
    
    /**
     *  @description    :   If the Case has a Registration with specific values, auto-approve it
     *                      
     *  @args           :   List<Case>
     * 
     *  @return         :   void
     * 
     *  @Revision Log   :   03/31/2020 - CR-20200331-13896 - Victor Hanson - created
     *                      08/13/2020 - Abhinav sharma - CR-20200729-14382 - added check for Event Type "Cohort" to determine Registration Status 
     *			    10/08/2020 - CR-20200819-14447 - Saurabh Kumar : Replaced Meeting with EAB Event
     **/
    public static void updateRegistration(List<Case> cases) {
        Set<Id> regIds = new Set<Id>();
        List<Registration__c> regs = new List<Registration__c>();
        for (Case c : cases) {
            if (c.Registration__c != null && c.Status != CASE_STATUS_CLOSED)
                regIds.add(c.Registration__c);
        }
        //08/13/2020 - Abhinav sharma -CR-20200729-14382 - added "Cohort" value to the where clause of the query
        //that will basically make it eligible for the auto-approved logic.
        if (regIds.size() > 0) {
            //get registrations where the related event type is one of the specified values
            Map<Id, Registration__c> regMap = new Map<Id, Registration__c>([SELECT Id, Status__c, Approval_Status__c 
                                                                            FROM Registration__c
                                                                            WHERE Id IN :regIds
                                                                            AND EAB_Event__r.Event_Type__c 
                                                                            IN ('Research Working Sessions', 'Prospect Webinar', 'Research Webinar','Cohort')]);
            
            for (Case c : cases) {
                Registration__c reg = regMap.get(c.Registration__c);
                //if registration matches the soql criteria, auto-approve
                if (reg != null) {
                    c.Status = CASE_STATUS_CLOSED;
                    reg.Approval_Status__c = 'Approved';
                    reg.Status__c = RegistrationHelper.STATUS_REGISTERED;
                    regs.add(reg);
                }
            }
            
            //update registrations
            if (regs.size() > 0)
                update regs;
        }
    }

    /**
     *  @description    :   This method is used to populate Support Product and GD Component on case
     * 
     *  @return         :   Void
     * 
     *  @Revision Log   :   V1.0 - Created By - Ayush Gupta - 07/15/2021 - CR-20210625-15243 - Develop automation related to Cases
     * 			:   V1.1 - Modified By - Mahendra Swarnkar - 10/25/2021  - CR-20211018-15522 - Refactor the code of method 
     **/
    
    public static void updateSupportProduct(List<Case> newCases, Map<Id, Case> oldMapOfCases) {
     
        // This method is calling from Trigger.isupdate (i.e. in after update event) so oldMapOfCases will not be null in any case 
        
        // Set to hold case Ids 
        Set<Id> caseIds = new Set<Id>();
        
        // List of cases to be updated 
        Map<Id,Case> mapOfCaseWithId = new  Map<Id,Case>();
        
        //set to hold bussiness hour names 
        Set<String> setOfBusinessHourNames = new Set<String>();
        
        for(Case cs  : newCases)
        {
            if(cs.Status == Constants.CASE_STATUS_ESCALATED_TO_TECH_SUPPORT && cs.Status != oldMapOfCases.get(cs.Id).Status){
                
                if(!mapOfCaseWithId.containsKey(cs.Id)){
                    mapOfCaseWithId.put(cs.Id, new Case(Id = cs.Id, RecordTypeId = Constants.CASE_RT_ID_TECH_SUPPORT));
                }
                else{
                    mapOfCaseWithId.get(cs.Id).RecordTypeId = Constants.CASE_RT_ID_TECH_SUPPORT;
                }
                    
                BYPASS_TRIGGER_CASE_UPDATE_SUPPORT_PRODUCT = true;
                
            }
            else if(cs.Status == Constants.CASE_STATUS_ESCALATED_TO_APS && (cs.RecordTypeId == Constants.CASE_RT_ID_STARFISH) && cs.Status != oldMapOfCases.get(cs.Id).Status){
                
                if(!mapOfCaseWithId.containsKey(cs.Id)){
                    mapOfCaseWithId.put(cs.Id, new Case(Id = cs.Id, RecordTypeId = Constants.CASE_RT_ID_APS_REVIEW)); 
                }
                else{
                    mapOfCaseWithId.get(cs.Id).RecordTypeId = Constants.CASE_RT_ID_APS_REVIEW;
                }
                    
                BYPASS_TRIGGER_CASE_UPDATE_SUPPORT_PRODUCT = true;
            } 
            
            // Conditions to check if business hours needed or not
            if((cs.Last_Support_Rep_Comment__c || cs.Initial_Response_Time2__c == true) && cs.InitialResponseTimeUpdated__c == False)
            {
                caseIds.add(cs.Id);
                if(cs.RecordTypeId ==Constants.CASE_RT_ID_INTERSECT || cs.RecordTypeId == Constants.CASE_RT_ID_INTERSECT_APS 
                   || cs.RecordTypeId == Constants.CASE_RT_ID_COUNSELOR_COMMUNITY)
                {
                    setOfBusinessHourNames.add(Constants.BUSINESS_HOURS_NAME_INTERSECT_COUNSELOR_COMM);
                } else if(cs.RecordTypeId == Constants.CASE_RT_ID_STARFISH) {
                    setOfBusinessHourNames.add(Constants.BUSINESS_HOURS_NAME_STARFISH);
                } 
            }
        }
        
        if(caseIds.size() > 0 && setOfBusinessHourNames.size()>0)
        {
           
            
            DateTime dateTimeNow = DateTime.now();        
            
            BusinessHours bh = new BusinessHours();
            
            List<Profile> profile = new List<Profile>();
            Map<String, BusinessHours> mapOfBHIdWithBusinessHours = new Map<String, BusinessHours>();
            
	    //Modified By - Neha Sharma - CR-20211130-15607
            List<Case> cases = [SELECT Id,CreatedBy.username ,CreatedBy.ProfileId,RecordTypeId,CreatedDate,Origin,Last_Support_Rep_Comment__c,Status,Initial_Response_Time2__c,InitialResponseTimeUpdated__c,
                                Number_Of_Execution__c FROM Case WHERE Id IN: caseIds];
            
            //Get System Admin profile list
            profile = [select Id, Name From Profile Where Name = 'System Administrator'];
            String communityUserName = '@eab.community.com';
            
            for(BusinessHours bhrs : [SELECT Id,Name FROM BusinessHours WHERE Name IN :setOfBusinessHourNames]) 
            {
                if(bhrs.Name == Constants.BUSINESS_HOURS_NAME_STARFISH) {
                    mapOfBHIdWithBusinessHours.put(bhrs.Name, bhrs);
                } else if(bhrs.Name == Constants.BUSINESS_HOURS_NAME_INTERSECT_COUNSELOR_COMM) {
                    mapOfBHIdWithBusinessHours.put(bhrs.Name, bhrs);
                }
            }
            
            for(Case c  : cases)
            {
                if(c.RecordTypeId ==Constants.CASE_RT_ID_INTERSECT || c.RecordTypeId == Constants.CASE_RT_ID_INTERSECT_APS 
                   || c.RecordTypeId == Constants.CASE_RT_ID_COUNSELOR_COMMUNITY) 
                {
                    bh = mapOfBHIdWithBusinessHours.get(Constants.BUSINESS_HOURS_NAME_INTERSECT_COUNSELOR_COMM);
                    
                } else if(c.RecordTypeId == Constants.CASE_RT_ID_STARFISH) {
                    bh = mapOfBHIdWithBusinessHours.get(Constants.BUSINESS_HOURS_NAME_STARFISH);
                }
                
                //Modified By - Ayush Gupta --- CR-20211020-15532          
                Integer count =0;
                
                if(c.Origin == 'Email To Case' && c.Number_Of_Execution__c == 1){
                    count =1;
                }
		
                if ((c.Last_Support_Rep_Comment__c || c.Initial_Response_Time2__c == true) && bh.Id != null && c.InitialResponseTimeUpdated__c == False && (( !((c.CreatedBy.username).contains(communityUserName)) /*profile.size()>0 && c.CreatedBy.ProfileId == profile[0].Id*/ && c.Number_Of_Execution__c == 1 && count != 1 ) || c.Number_Of_Execution__c == 0)) {  
                    
                    Double diff = BusinessHours.diff(bh.Id, c.CreatedDate, dateTimeNow);
                    Double response = diff / 1000 / 3600;
                    
                    if(!mapOfCaseWithId.containsKey(c.Id)){
                        mapOfCaseWithId.put(c.Id, new Case(Id = c.Id, Initial_Response_Time__c = response,InitialResponseTimeUpdated__c = true));
                    }
                    else{
                        mapOfCaseWithId.get(c.Id).Initial_Response_Time__c = response;
                        mapOfCaseWithId.get(c.Id).InitialResponseTimeUpdated__c = true;   
                    }
                        
                    
                    //Added by Colin McGloin - CR-20211014-15517
                    BYPASS_TRIGGER_CASE_UPDATE_SUPPORT_PRODUCT = true;
                    
                }else{
                    
                    if(c.Initial_Response_Time2__c == true){
                        //Modified By - Ayush Gupta --- CR-20211018-15525                  
                        count = 0;
                       
                        if(!mapOfCaseWithId.containsKey(c.Id)){
                            mapOfCaseWithId.put(c.Id, new Case(Id = c.Id, Number_Of_Execution__c = 0,Initial_Response_Time2__c = false));
                        }
                        else{
                            mapOfCaseWithId.get(c.Id).Number_Of_Execution__c = 0;
                            mapOfCaseWithId.get(c.Id).Initial_Response_Time2__c = false;
                        }
                           
                        //Added by Colin McGloin - CR-20211014-15517
                        BYPASS_TRIGGER_CASE_UPDATE_SUPPORT_PRODUCT = true;
                        
                    }
                }
            }
            
        }
        
        if(mapOfCaseWithId.values().size()>0){
            update mapOfCaseWithId.values();
        }
        
    }
    
    public static void updateIntersectPartnerEmail(List<Case> newCases, Map<Id, Case> oldMapOfCases) {
        
        Set<Id> accountIds = new Set<Id>();
        Map<Id,String> mapAccIdwithManagerEmail = new Map<Id,String>();
        for(Case cs : newCases){
            if(cs.AccountId != null){
                accountIds.add(cs.AccountId);
            }
        }
        
        if(accountIds.size() > 0){
            for(Account acc :[SELECT Id,Intersect_Partner_Success_Manager__r.Email From Account where Id IN: accountIds]){
                mapAccIdwithManagerEmail.put(acc.Id,acc.Intersect_Partner_Success_Manager__r.Email);
            }
        }
        for(Case cc : newCases){
            if(mapAccIdwithManagerEmail.containskey(cc.AccountId)){
                cc.Intersect_Partner_Success_Manager_Email__c = mapAccIdwithManagerEmail.get(cc.AccountId);
            }
        }
    }
    
    //Created By - Ayush Gupta - 07/27/2021 - CR-20210526-15183 - Salesforce Surveys setup
    //Modified By - Ayush Gupta - CR-20211111-15577
    public static void sentSurveyToUsers(Map<Id, Case> mapOfNewCases, Map<Id, Case> oldMapOfCases) {
       
        for(Case cs : mapOfNewCases.values()){ 
            
           
            if(cs.Status == 'Closed' && mapOfNewCases.get(cs.Id).Status != oldMapOfCases.get(cs.Id).Status){
                
                //call helper class for sending survey to the related contacts
                
                SurveyInvitationHelper.sentSurveyToUsers(mapOfNewCases, oldMapOfCases);
            }
        }
    }
    
    /**
     *  @description    :   This method is to Notify the Account Owner when a Case is created
     * 
     *  @return         :   Void
     * 
     *  @Revision Log   :   V1.0 - Created By - Ayush Gupta - 08/19/2021 
     * 			:   V1.1 - Modified By - Nikita Kumari - 01/20/2022 - CR-20220119-15720 - Error being thrown when Community SU tries to create case
     * */
    public static void notifyAccountOwner(List<Case> newCase){
        
        //Added By - Nikita Kumari - 01/20/2022 - CR-20220119-15720 - to get the Profile Names with comma seprated formate
        String profileNamesWithCommaSeprated = System.Label.Profile_Name_To_Skip_Account_Owner_Notification; 
        
        //Added By - Nikita Kumari - 01/20/2022 - CR-20220119-15720 - to hold list of Profile Names
        List<String> listOfProfileNameToSkipEmailSend = new List<String>();
        listOfProfileNameToSkipEmailSend.addAll(profileNamesWithCommaSeprated.split(','));
        
        //query on template object
        EmailTemplate et=[Select id from EmailTemplate where name='New Case notification for Account Manager'];
        
        //list of emails
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        //Modified By - Nikita Kumari - 01/20/2022 - CR-20220119-15720 - Get profiles list for which the email needs to skip
        Set<Id> setOfProfileIds = new Set<Id>();
        for(Profile pro : [select Id, Name From Profile 
                           Where Name != null AND Name IN: listOfProfileNameToSkipEmailSend]
           )
        {
            setOfProfileIds.add(pro.Id);
        }
        
        //set of Id of filtred case on the basis of recordtype
        Set<Id> setOfCase = new Set<Id>();
        
        for(Case cases : newCase){
            if(cases != null && cases.RecordTypeId == Constants.CASE_RT_ID_STARFISH ||  cases.RecordTypeId == Constants.CASE_RT_ID_APS_REVIEW){
                setOfCase.add(cases.Id);
            }
        }
        
        for(Case cse : [Select Id,Account.Owner.ProfileId,Account.Owner.Email,ContactId From Case Where Id IN :setOfCase]){
          
            //Modified By - Nikita Kumari - 01/20/2022 - CR-20220119-15720 - check profile id shouldn't contains in setOfProfileIds 
            if(setOfProfileIds.size() == 0 || 
               (setOfProfileIds.size() > 0 && !setOfProfileIds.contains(cse.Account.Owner.ProfileId))
              ){
                  //initiallize messaging method
                  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  
                  // Set list of people who should get the email
                  List<String> sendTo = new List<String>();
                  
                  if(String.isNotBlank(cse.Account.Owner.Email)){
                      sendTo.add(cse.Account.Owner.Email);
                      
                      //Recipients of mail
                      mail.setToAddresses(sendTo);
                      
                      //Modified By - Nikita Kumari - 01/20/2022 - CR-20220119-15720 - Started from here
                      //commented by - Nikita - 01/20/2022 - CR-20220119-15720
                      //set object Id
                      //mail.setTargetObjectId(cse.Id);
                      
                      //Additional changes Added By - Nikita Kumari - 01/20/2022 - CR-20220119-15720
                      mail.setTargetObjectId(cse.ContactId);
                      mail.setWhatId(cse.Id);
                      //Modified By - Nikita Kumari - 01/20/2022 - CR-20220119-15720 - Ended here
                      
                      //set template Id
                      mail.setTemplateId(et.Id);
                      
                      //add mail
                      emails.add(mail);
                  }
            }
        }
        if(emails.size() > 0){
            //send mail
            Messaging.sendEmail(emails);
        }  
    }
}