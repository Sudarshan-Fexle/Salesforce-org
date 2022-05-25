/*
    Purpose         :   This class is helper class for trigger on Opportunity object.
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   04/11/2012
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created  
                        V_1.1 - Modified By - New method added  - CR-20111205-259
                        V_1.2 - Modified By - Bhavi - 11/05/2012 - CR-20120920-1514
                        V_1.3 - Modified By - Bhavi - 11/08/2012 - Added a new Method(PopulateContactData) - CR-20121019-1641
                        V_1.4 - Modified By - Bhavi - 12/12/2012 - Added a new Method(validateAgreementsStatus) - CR-20121106-1687
                        V_1.5 - Modified By - Bhavi - 02/17/2013 - Added a new Method(rollupOppsDataOnAccount) - CR-20130117-2187
                        V_1.6 - Modified By - Bhavi - 04/30/2013 - Added a new Method(populateFieldOnOpportunityWithMembership) - CR-20130408-2835
                        V_1.7 - Modified By - VH    - 10/15/2013 - Checking for null and bypassing triggers in populateContactData - CR-20130624-3196
                        V_1.8 - Modified By - VH    - 11/20/2013 - Added a new method (populateInitialVisitOnEvents) - CR-20130919-3662
                        V_1.9 - Modified By - Bhavi - 01/11/2014 - Added a new method (updateWarmLeadInfoOnOpportunity) - CR-20130417-2892
                        V_2.0 - Modified By - Ajit Surana - 03/13/2014 - Added a new method (updateOpportunityNonSOXFields) - CR-20140205-4458
                        V_2.1 - Modified By - Abhinav Sharma - 07/02/2014 - Added new method (updateOpportunitiesWithDesiredFieldValues) - CR-20140502-5327
                        V_2.2 - Modified By - 08//4/2014 - Modified updateOpportunitiesWithDesiredFieldValues() method - CR-20140731-6814
                        V_2.3 - Modified By - 08/26/2014 - Modified to fix the Too many SOQL queries error - CR-20140808-6940
                        V_2.4 - Modified By - 09/15/2014 - Added new method - (rollUpSummaryFieldValuesOnBundleOpp) - CR-20140429-5272
                        V_2.5 - Modified By - 09/15/2014 - Added new method - (manageBundledOppSiblings) - CR-20140429-5272
                        V_2.6 - Modified By - 09/17/2014 - Added new method - (populateAccountOnBundleOpportunity) - CR-20140429-5272 
                        V_2.7 - Modified By - 09/19/2014 - Added new method - (populateBundleNameOnOpportunities) - CR-20140429-5272
                        V_2.8 - Modified By - 01/22/2015 - Modified the method (populateFieldOnOpporutnityWithmembership) - CR-20141210-8281                            
                        V_2.9 - Modified By - 04/10/2015 - CR-20150220-8700 - Added isDeleted =false and ALL ROWS at line 657
                        V_3.0 - Modified By - 08/25/2015 - CR-20150820-9167 - Added new methods(doCalculationAndPopulateFieldsOnOpportunities, applyValidationsOverOpportunityRecords)
                        V_3.1 - Modified By - Abhinav Sharma - 08/28/2015 - CR-20140613-5790 - Added new methods (populatePAsAndActivityFieldsOnWarmLeadMTMs)
                        V_3.2 - Modified By - Victor Hanson - 10/09/2015 - CR-20151009-9309 - Hypercare fix to bypass superfluous SOQL (populatePAsAndActivityFieldsOnWarmLeadMTMs)
                        V_3.3 - Modified By - Abhinav Sharma - 10/14/2015 - CR-20150831-9204 - CT Assignment Manager - update logic
                        V_3.4 - Modified By - Abhinav Sharma - 10/17/2015 - CR-20151008-9304 - Triggers repetative execution
                        V_3.5 - Modified By - Abhinav Sharma - 12/02/2015 - CR-20151022-9349 - Modified doCalculationAndPopulateFieldsOnOpportunities existing method
                        V_3.6 - Modified By - Mahendra Swarnkar - 12/04/2015 - CR-20151022-9350 -updated the method "opportunityValidationAndFieldUpdated" to update opportunity record type label name from Southwind to 'Consulting & Management'
                        V_3.7 - Modified By - Abhinav Sharma - 05/19/2016 - CR-20160308-9682 - Updated the method "opportunityValidationAndFieldUpdated"
                        V_3.8 - Modified By - Abhinav Sharma - 05/20/2016 - CR-20160308-9682 - Added a method "syncOppMainContactAndPrimayOCR"
                        V_3.9 - Modified By - Subhash Garhwal - 06/16/2016 - CR-20160414-9762 - updated opportunityValidationAndFieldUpdated method to change the opportunity name logic for Contract LOA opps.
                        V_4.0 - Modified By - Subhash Garhwal - 06/16/2016 - CR-20160414-9762 - Added a new method validateProgramOpportunities and  PreventManualDuplicateProgramOpportunities to validate/sync Children Program Opportunity.
                        V_4.1 - Modified By - Subhash Garhwal - 07/14/2016 - CR-20160414-9762 - Added a new method rollupProgramOpps to roll-up Program Opps.
                        V_4.2 - Modified By - Victor Hanson - 8/10/2016 - CR-20160810-10101 - bypassed the auto-naming logic for Royall record type in the 'opportunityValidationAndFieldUpdated' method.
                        V_4.3 - Modified By - Mahnedra Swarnkar - 8/11/2016 - CR-20160810-10101 - Merged the code From RoyallDev SB to Test SB for CR-10101.
                        V_4.4 - Modified By - Mahendra Swarnkar - 10/07/2016 - CR-20160825-10152 - Updated method "updateOpportunityNonSOXFields" added only a check in the If condition to bypass validation for Royall opportunity recordType.
                        V_4.5 - Modified By - Mahnedra Swarnkar - 10/11/2016 - CR-20160801-10076                       
                        V_4.6 - Modified By - 0/12/2016 - Subhash Garhwal -  - Q2C Hypercare of Hypercare
                        V_4.7 - Modified By - Mahendra Swarnakar - 1/2/2017 - CR-20161227-10568 - Update profiles name
                        V_4.8 - Modified By - 1/23/2017 - Abhinav Sharma - CR-20170105-10596 - Added a new method - syncUpMembershipsWithLatestStatus
                        V_4.9 - Modified By - Mahendra Swarnkar - 03/18/2017 - CR-20170216-10694 - Added a new method - updateMainContactsOnCurrentAndFutureOpp
                        V_5.0 - Modified By - Victor Hanson - 04/03/2017 - Added a new method - updatePreviousOppType
                        V_5.1 - Modified By - Subhash Garhwal - 04/06/2017 - Added a new method - updateOriginatingProgramOnAmendmentOpportunity
                        V_5.2 - Modified By - Subhash Garhwal - 04/06/2017 - Added a new method - autoPopulateFieldOnOpportuntiy
                        V_5.3 - Modified By - Subhash Garhwal - 04/06/2017 - Added a new method - preventInitiatingDuplicateOpportunities
                        V_5.4 - Modified By - Subhash Garhwal - 04/13/2017 - Add additional contitional for opportunity Origination Terrain in preventInitiatingDuplicateOpportunities method
                        V_5.5 - Modified By - Subhash Garhwal - 04/14/2017 - Add additional contitional for opportunity new record type naming convenation in opportunityValidationAndFieldUpdated method
                        V_5.6 - Modified By - Subhash Garhwal - 04/28/2017 - CR-20170403-10807 - Added a new method updateOpportunityTopParentInstitution
                        V_5.7 - Modified By - Victor Hanson - 05/15/2017 - CR-20170403-10807 - Updated opportunityValidationAndFieldUpdated so 'Merged' RT is included in auto-name.
                        V_5.8 - Modified By - Saurabh Kumar - 05/24/2017 - CR-20170403-10807 - A new method is added "updateStatusAndAmendmentTypeOnContract" to update 
                        V_5.9 - Modified By - 06/04/2017 - Abhinav Sharma - DS114  - Updated "autoPopulateFieldOnOpportuntiy" method and a new method "updateSubscriptionsWithOpportunityFieldsValues"
                        V_6.0 - Modified By - 06/05/2017 - Deepak Kumawat - Created a new Method 'populateOpportunityAmendment' to update amendment fields on opportunity.
                        V_6.1 - Modified By - Saurabh Kumar - 06/05/2017 - CR-20170403-10808 (DS114) - Fields "Earliest_Subscription__c", "Active_Subscription__c", "Latest_Subscription__c" are added
                        V_6.2 - Modified By - Subhash Garhwal  - 06/06/2017 - CR-20170403-10808(DS151) - Field "Date_first_moved_to_Stage_IV__c" and "Date_First_Moved_to_Fast_Track__c" automation are added
                        V_6.3 - Modified By - Subhash Garhwal  -06/15/2017 - CR-20170403-10808 Added a new method "updateThresholdValueOnOpportunity"
                        V_6.4 - Modified By - Subhash Garhwal - 06/28/2017 - a new method "requiredAnAcitivityForActivityScheduledOppStage"
                        V_6.5 - Modified By - Subhash Garhwal - 06/30/2017 - a new method "populateStartandEndDate"
                        V_6.6 - Modified By - Rajeev Jain - 07/05/2017 - New Method in R58 - populateAssociatePrincipalOnopportunity(V_1.40 - Added by - Mahendra Swarnkar - 05/04/2017 - CR-20170221-10707 - Added a new method - populateAssociatePrincipalOnopportunity)
                        V_6.7 - Modified By - Rajeev Jain - 07/05/2017 - upto here
                        V_6.8 - Modified By - Rajeev Jain - 07/28/2017 - Merged the Release 60 changes with Q2c Beta + Revenue Management - Starts From here
                        V_6.9 - Modified By - Mahendra Swarnkar - 07/05/2017 - CR-20170616-11008 - Added a new method - populateTVMFieldsOnopportunityFromMembership
                        V_7.0 - Modified By - Rajeev Jain - 07/28/2017 - Merged the Release 60 changes with Q2c Beta + Revenue Management - Ends here
                        V_7.1 - Modified By - Subhash Garhwal - 09/12/2017- Commented  a method "requiredAnAcitivityForActivityScheduledOppStage" as per "Issue--CR11183--QA--00005732"
                        V_7.2 - Modified By - Saurabh Kumar - 09/13/2017 - Updated Method updateMainContactsOnCurrentAndFutureOpp as per CR-20170908-11190 
			V_7.3 - Modified By - Mahendra Swarnkar - 10/11/2017 - CR-20170929-11624 - Apollo Release - Added a new method "populateEntityField"
			V_7.4 - Modified By - Modified By Dipesh Gupta - 11/03/2017 - CR-20171101-11753 - Added a logic to add opp team member records if and only if User is Active and user Entity matches with the opportunity's Entity. 
			V_7.5 - Modified By - Merged Q2C Release D-H
			V_7.6 - Modified By - Subhash Garhwal - 09/28/2017 - Issue--CR11458--QA--00005907 - Update preventOpportunityStageNameToChange method - 
			V_7.7 - Modified By - Subhash Garhwal - 02/10/2017 -  Issue--CR11458--QA--00005907 - preventOppToMoveToContractReceivedSentToFinance
			V_7.8 - Modified By - Victor Hanson - 10/17/2017 - Issue--CR11695--QA--00006997 - added nullcheck to populateContactData
			V_7.9 - Modified By - Merged Q2C Release D-H - Upto Here
			V_8.0 - Modified By - Victor Hanson - 11/06/2017 - Issue--CR11624--QA--00007346 - Check for Entity Override
			V_8.1 - Modified By - Subhash Garhwal - 11/07/2017 - Issue--CR11744--QA--00007311 - Added bypass logic to avoid SOQL limit issue (BYPASSOPPORTUNITYTRIGGERFORMERGE)
			V_8.2 - Modified By - Mahendra Swarnkar - 03/09/2018 - CR-20180309-12096 - Updated the Method "populateContactData ()" to check for the max size of Main_Contact__c on Contact
			V_8.3 - Modified By - Abhinav Sharma - 03/28/2018 - CR-20171103-11765 - To remove the Null from the opportunity name - method - opportunityValidationAndFieldUpdated
			V_8.4 - Modified By - Subhash Garhwal - 04/09/2018 CR-20180205-11952 - preventOpportunityStageNameToChange - New Set to to BY pass the Exception for 4 opportunity stage 'Closed Lost', 'Dropped', 'Void', 'Closed'
			V_8.5 - Modified By - Victor Hanson - 04/09/2018 - CR-20170918-11373 - Commented out references to Marketer_Name__c
			V_8.6 - Modified By - Subhash Garhwal - 06/29/2018 - CR-20180627-12306 - Added logic to bypass method to avoid SOQL issue
			V_8.7 - Modified By - Subhash Garhwal - 07/10/2018 - CR-20180205-11986 - Added method 'setPreviosuRecordType' to update 'Previous Record Type' on Opportunuty.
			V_8.8 - Modified By - Subhash Garhwal - 08/27/2018 - CR-20180402-12141 - Added method 'validateOppStage' - This method will check if a user selects the Stage = ‘Sent to Finance - Request Drop’, then all the SPs under the Opp should be in the Stage = ‘Send to Finance - Request Drop’
			V_8.9 - Modified By - Rajeev Jain Up To here - 04/11/2018- CR-20170918-11373 - Deploying this from dev1 to full1 sandbox.
			V_9.0 - Modified By - Rajeev Jain - Deployment of CR-20180821-12512.
			V_9.1 - Modified By - Colin McGloin - 09/04/2018 - CR-20180731-12476 - Commented out all references to Leadership Team Owner, Value Advisor, Value Management Lead, Value Management Director, Practice Partner due to field deletions as part of Lookup Cleanup on Opportunity
			V_9.2 - Modified By - 09/11/2018 - CR-20180910-12583 - updateInitialActivityDatePlanned
			V_9.3 - Modified By - Rajeev Jain - 09/14/2018 - Deployment  CR-20180910-12583 in Production
			V_9.4 - Modified By - Subhash Garhwal - 09/28/2018 - CR-20180720-12456 - updated 'syncUpMembershipsWithLatestStatus' - Added new parameter value in method calling.
			V_9.5 - Modified By - CR-20181016-12674,  New method added - syncSMERequestWithOpportunity
			V_9.6 - Modified By - Rajeev Jain - CR-20181008-12649 addes new method createInitiatingOpportunityName
			V_9.7 - Modified By - Rajeev Jain - 11/14/2018 - CR-20181016-12674 - Deployment.
			V_9.8 - Modified By - Commented out the logic as part of CR-20190104-12805 - Abhinav Sharma. sendOutTechnicalEvaluationToMarketingTeam
			V_9.9 - Modified By - Subhash Garhwal - 12/20/2018  New method added - validateContractSignatureDateForESOpportunties - CR-20181019-12685
			V_10.0 - Modified By - 03/21/2019 - Victor Hanson - Updated autoPopulateFieldOnOpportuntiy() to Set the value of SalesLoft1__Primary_Contact__c = Main_Contact__c
			V_10.1 - Modified By - 03/30/2019 - Rajeev Jain - CR-20190425-13032 - Spring cleanup overlapping and changes - Remove method logic rollupOppsDataOnAccount due to field cleanup
			V_10.2 - Modified By - Rajeev Jain 05/16/2019 CR-20190201-12861
			V_10.3 - Modified By - Dipesh Gupta - CR-20190226-12902 - Added a new Method validateOppFieldOnCloseLost
			V_10.4 - Modified By - Dipesh Gupta -09/25/2019 - CR-20190429-13049 - Added Check for Visit Location as per taylor chatter
			V_10.5 - Modified By - Dipesh Gupta -10/04/2019 - CR-20190429-13049 - Added Check for Event_Purpose__c as per carter chatter
			V_10.6 - Modified By - Rajiv Jain - 02/20/2020 - CR-20200110-13605 -  Remove zzzMarketing Warming Effort(Marketing_Warming_Effort__c) field of opportunity.
			V_10.7 - Modified By - Abhinav sharma - 11/06/2020 - CR-20201102-14656 
			V_10.8 - Modified By - Mahendra Swarnakar - 11/04/2020 - CR-20201029-14646
			V_10.9 - Modified By - Subhash Garhwal 08/12/2020 - CR-20200812-14427
			V_11.0 - Modified By - Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted
			V_11.1 - Modified By - Neha Sharma - 2/03/2021 - CR-20210128-14851
                        V_11.2 - Modified By - Neha Sharma - 2/12/2021 - CR-20200527-14108 - comment the below codition as EvalCompOrRIComp_LastModifiedDate__c field get deleted from the system.
                        V_11.3 - Modified By - Neha Sharma - 9/04/2021 - CR-20210202-14862 - Added new method - used to populate Max Probability Opportunity Reached
			V_11.4 - Modified By - Neha Sharma - CR-20201110-14683
			V_11.5 - Modified By - Neha Sharma - CR-20210630-15264 
            		V_11.6 - Modified By - Nikita Kumari - 08/10/2021 - CR-20210806-15336 - Updated method Opp name formula in opportunityValidationAndFieldUpdated for Legacy Acquisition.
			V_11.7 - Modified By - Nikita Kumari - 10/13/2021 - CR-20211008-15505 - Updated method opportunityValidationAndFieldUpdated - added RT check for Legacy capex and Legacy Acquisition to by pass error.
                        V_11.8 - Modified By - Comment out the methods assignContactToCampaign and getProgAcronym because both the method are not used anywhere.
            		V_11.9 - Modified By - chirag soni - 11/16/2021 - CR-20211112-15582  - Updated method - opportunityValidationAndFieldUpdated(),CreateReviewCall(), 
                                                                                             - CreateCaseUponLostOpportunityAndMarkRenewalCallAsScheduled() 
                                                                                             - legacy cappex record type is deactivated and migrated to legacy Acquisition
    			V_12.0 - Modified By - Mahendra Swarnkar - 08/19/2021 - CR-20210414-15080
                V_12.1 - Modified by - Neha Sharma - 4/26/2022 - CR-20220216-15919 - Comment out method CreateReviewCall() and CreateReviewCalls() in order to prevent Review calls records to be insertion.
                V_12.2 - Modified by - Neha Sharma - 4/26/2022 - CR-20220216-15919 - Comment out Logic which is related to update Review call record in method CreateCaseUponLostOpportunityAndMarkRenewalCallAsScheduled().
    **/  
  
public without sharing class OpportunityTriggerHelper {
    
    //Mahendra Swarnkar - 04/11/2019 - CR-20181008-12649 - Flag to controll the trigger execution when "Opportunity Product" is updated from Opportunity Product DLRS
    public static Boolean BYPASSFOROPPORTUNITYPRODUCTUPDATEFROMDLRS = false;
    
    //Subhash Garhwal - 06/29/2018 - CR-20180627-12306 - Flag to contol the trigger execution when opportunity is contracted
    public static Boolean BYPASSFORCONTRACTED = false;
    
    //Flag to contol the trigger execution 
    public static Boolean BYPASSOPPORTUNITYTRIGGERFORMERGE = false;
    
    //Static variable to hold the opportuny records to be updated
    public static Map<Id, Opportunity> opportunities;
    public static Boolean DO_NOT_OVERWRITE_INITIAL_VISIT_DATE = false;
    
    //Flag to bypass Entity logic
    public static Boolean BYPASSENTITYLOGIC = false;
    
    //V_1.39 - Added by - Mahendra Swarnkar - 03/18/2017 - CR-20170216-10694 -          
    public static Boolean DO_NOT_EXECUTE_OCR_SYNC_TRIGGER_LOGIC = false;

    //Boolean flag for testing purpose
    @TestVisible static Boolean IsEmailInvocationHappen = false;
    
    //Modified by - Mahnedra Swarnkar - 8/11/2016 - CR-20160810-10101 - Merged the code From RoyallDev SB to Test SB for CR-10101. - Starts from here
    public static final string OPPORTUNITY_ROYALL_RT_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royall').getRecordTypeId();    
    //Modified by - Mahnedra Swarnkar - 8/11/2016 - CR-20160810-10101 - Merged the code From RoyallDev SB to Test SB for CR-10101. - Ends here
    
    //Added By - Abhinav Sharma - 08/26/2014
    //Start from here
    //Static variables responsible to control the order of execution
    public static Boolean EXECUTE_TRIGGER_BEFORE_UPDATE = true;
    public static Boolean EXECUTE_TRIGGER_AFTER_UPDATE = true;
    //Upto Here
    
    //Added by Mahendra swarnakar 
    //Static variables 
    public static final string OBJECT_OPPORTUNITY  = 'Opportunity'; 
    public static final string RECORD_TYPE_OPPORTUNITY_PT_MARKETING = 'PT Marketing';
    //public static final string RECORD_TYPE_OPPORTUNITY_PROGRAM_PT_MARKETING  = 'Program – PT Marketing';
    public static final string OBJECT_EVENT = 'Event';
    public static final string RECORD_TYPE_EVENT_PT_MARKETING = 'PT Marketing';
    public static final string EVENT_TYPE_PHONE_APPOINTMENT = 'Phone Appointment';
    public static final string EVENT_PURPOSE_TECHNICAL_CALL = 'Technical Call';
    public final static String RECORD_TYPE_OPPORTUNITY_DEVELOPER_NAME_PT_MARKETING = 'BI_Marketing';
    //Upto Here  
   
    //Flag helpful in determining the initial invocation point in "Membership Status" field update based code logic
    public static Boolean OPPORTUNITY_STATUS_FIELD_CHANGE_IS_THE_EVENT = false;
    
    //Modified by rajeev jain 05/16/2019 CR-20190201-12861
    static List<Profile> oRGProfiles = [Select Id, Name From Profile];

    
     /**
      * 
      *   @description  :   Added method to set BYPASSFORCONTRACTED flag value to true if Opportunity is contracted
      *
      *  @args           :   List<Opportunity>, Map<Id, Opportunity>
      *
      *  @return         :   void
      *
      *  @revision Log   :   V1.0 - Created - 06/29/2018 - Subhash Garhwal - CR-20180627-12306
      * 
      **/
    public static void opportunityContractedCheck(List<Opportunity> newOppList, Map<Id, Opportunity> mapOldOpps) {
      
      //Loop over the Opportunitirs
      for(Opportunity opp : newOppList) {
        
        //Check for Contracted
        if(opp.SBQQ__Contracted__c && (opp.SBQQ__Contracted__c != mapOldOpps.get(opp.Id).SBQQ__Contracted__c || opp.LOA_Contract__c != mapOldOpps.get(opp.Id).LOA_Contract__c))
          BYPASSFORCONTRACTED = true;  
      }  
    }
    
    /**
     * 
     * @description: populate the previous opportunity field, based on the Renewal Contract's Opportunity
     *
     *  @args           :   List<Opportunity>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.0 - Created - 04/13/2017 - Victor Hanson - CR-20170403-10807
     * 
     **/
    public static void updatePreviousOpportunity(list<Opportunity> newOppList) {
        //get a set of renewal contract ids
        set<Id> renewalContractIds = new set<Id>();
        for (Opportunity newOpp : newOppList) {
            if (newOpp.SBQQ__RenewedContract__c != null) renewalContractIds.add(newOpp.SBQQ__RenewedContract__c);
        }
        
        //if there are any records, get a map of contracts
        if (renewalContractIds.size() > 0) {
            map<Id, Contract> contractMap = new map<Id, Contract>([SELECT Id, SBQQ__Opportunity__c FROM Contract WHERE Id IN :renewalContractIds]);
            for (Opportunity newOpp : newOppList) {
                //place the renewal contract's opportunity in the Previous Opp field on the renewal (Continuing) opp
                if (newOpp.SBQQ__RenewedContract__c != null && contractMap.containsKey(newOpp.SBQQ__RenewedContract__c)) {
                    newOpp.Previous_Opportunity__c = contractMap.get(newOpp.SBQQ__RenewedContract__c).SBQQ__Opportunity__c;
                }
            }
        }
    }
    
    /**
     * 
     * @description: When an opportunity is created or its previous opp is modified, update the Previous Opportunity Type field
     *              to show if previous Opp was Initial Term, Continuing - First Time Renewal, or Continuing - Tenured Renewal
     *
     *  @args           :   List<Opportunity>, Map<Id, Opportunity>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.0 - Created - 04/13/2017 - Victor Hanson - CR-20170403-10807
     * 
     **/
    public static void updatePreviousOppType(list<Opportunity> newOppList, map<Id, Opportunity> oldOppMap) {
        
        //Victor Hanson - 04/03/2017 - CR-20170403-10807 - populate the previous opportunity field
        OpportunityTriggerHelper.updatePreviousOpportunity(newOppList);
        
        //Only populate these fields in the insert use cases
        if(newOppList != null && oldOppMap == null) {
            // Modified By - Neha Sharma - CR-20201110-14683
            //Loop through opportunity records
            for(Opportunity newOpp : newOppList) {
                if(newOpp.SBQQ__RenewedContract__c != null) {
                    newOpp.SBQQ__Renewal__c = true;
                    newOpp.Decision_Type__c = 'Need New LOA';
                    //newOpp.Sales_Pursuit_Products__c = 'Not Applicable - Admin Use Only';
                }
            }
        }
        
        //get a list of all previous opportunities
        set<Id> previousOppIds = new set<Id>();
        for (Opportunity newOpp : newOppList) {
            Opportunity oldOpp;
            //get the old opp if this is an update
            if (oldOppMap != null) oldOpp = oldOppMap.get(newOpp.Id);
            if (newOpp.Previous_Opportunity__c != null)
            {
                previousOppIds.add(newOpp.Previous_Opportunity__c);
            }
            else if (newOpp.Previous_Opportunity__c == null) 
            {//if the previous opp is null, set the original opportunity recordType to match the current recordType
                newOpp.Original_Opportunity_RecordTypeId__c = newOpp.RecordTypeId;
            }
        }
        
        map<Id, Opportunity> previousOppMap = new map<Id, Opportunity>();
        
        if (previousOppIds.size() > 0) {
            previousOppMap = new map<Id, Opportunity>([SELECT Id, RecordTypeId, RecordType.Name, 
                                                       Original_Opportunity_RecordTypeId__c, Previous_Opportunity__r.RecordTypeId, Years_on_the_Contract__c
                                                                           FROM Opportunity WHERE Id IN :previousOppIds]);
            for (Opportunity newOpp : newOppList) {
                Opportunity previousOpp = previousOppMap.get(newOpp.Previous_Opportunity__c);
                if (previousOpp != null) {
                    if (CPQConstants.OPP_INITIATING_RT_ID_SET.contains(previousOpp.RecordTypeId)) {
                        //if previous opportunity record type is one of the Initiating types, set Previous Opp Type = Initial Term
                        newOpp.Previous_Opportunity_Type__c = CPQConstants.OPP_TYPE_INITIAL_TERM;
                    }
                    else if (CPQConstants.OPP_CONTINUING_RT_ID_SET.contains(previousOpp.RecordTypeId) && CPQConstants.OPP_INITIATING_RT_ID_SET.contains(previousOpp.Previous_Opportunity__r.RecordTypeId)) {
                        //if previous opportunity record type is Continuing and it's previous opp is one of the Initiating types, set Previous Opp Type = Continuing - First Time Renewal
                        newOpp.Previous_Opportunity_Type__c = CPQConstants.OPP_TYPE_CONTINUING_FIRST_RENEWAL;
                    }
                    else if (CPQConstants.OPP_CONTINUING_RT_ID_SET.contains(previousOpp.RecordTypeId) && CPQConstants.OPP_CONTINUING_RT_ID_SET.contains(previousOpp.Previous_Opportunity__r.RecordTypeId)) {
                        //if previous opportunity record type is Continuing and it's previous opp is also continuing, set Previous Opp Type = Continuing - Tenured Renewal
                        newOpp.Previous_Opportunity_Type__c = CPQConstants.OPP_TYPE_CONTINUING_TENURED_RENEWAL;
                    }
                }
                else {
                    //if there is no previous opp, previous opp type should be null
                    newOpp.Previous_Opportunity_Type__c = null;
                }
            }
        }
        
        //popuate the # Years on the Contract field based on previous opps + Number of years in to the new contract
        populateNumYearsOnContract(newOppList, previousOppMap);
    }
    
    /**
     * 
     * @description: Calculate the "# Years on the Contract" field based on previous opp and current contract.
     *                  for example; if the last contract was 3 years and this is year 2 of another 3 year contract, then total time is 5 years.
     *
     *  @args           :   List<Opportunity>, Map<Id, Opportunity>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.0 - Created - 06/07/2017 - Victor Hanson - CR-20170403-10808
     * 
     **/
    public static void populateNumYearsOnContract(list<Opportunity> newOppList, map<Id, Opportunity> previousOppMap) {
        for (Opportunity newOpp : newOppList) {
            decimal numYrsIntoContract = 0;
            
            //get the previous opp if there is one
            Opportunity previousOpp = previousOppMap.get(newOpp.Id);
            if (previousOpp != null) numYrsIntoContract = previousOpp.Years_on_the_Contract__c;
            
            //get the number of years on the current contract.
            if (newOpp.Start__c != null && newOpp.End__c != null && Date.today() > newOpp.Start__c) {
                Date startDate = newOpp.Start__c;
                Date endDate = newOpp.End__c;
                if (Date.today() < endDate) endDate = Date.today();
                //round to zero decimals
                decimal yrsOnCurrentContract = math.floor((startDate.monthsBetween(endDate)/12))+1;
                //add number of years in to the current contract
                numYrsIntoContract += yrsOnCurrentContract;
            }
            newOpp.Years_on_the_Contract__c = numYrsIntoContract;
        }
    }
    
    //Added By - Deepak Kumawat - 06/04/2017
    /**
     * 
     * @description     :   When an opportunity is created, its Origination Terrain isn populated on the that opportunity
     *
     *  @args           :   List<Opportunity>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.0 - Created - 06/04/2017 - Deepak Kumawat
     * 
     **/
     public static void populateOpportunityAmendment (List<Opportunity> newOppList, map<Id, Opportunity> oldOppMap) {
        
        //get a list of all previous opportunities
        set<Id> previousOppIds = new set<Id>();
        
        for (Opportunity newOpp : newOppList) {
           
            //Instance of Opportunity
            Opportunity oldOpp;
            
            //get the old opp if this is an update
            if (oldOppMap != null) oldOpp = oldOppMap.get(newOpp.Id);
            
            if (oldOpp == null && newOpp.Previous_Opportunity__c != null || (oldOpp != null && oldOpp.Previous_Opportunity__c != newOpp.Previous_Opportunity__c)) {
                previousOppIds.add(newOpp.Previous_Opportunity__c);
            }
            else if (newOpp.Previous_Opportunity__c == null) {
                
                //if the previous opp is null, set the original opportunity recordType to match the current recordType
                newOpp.Original_Opportunity_RecordTypeId__c = newOpp.RecordTypeId;
            }
        }
        
        //Check the size of previous opportunity
        if (previousOppIds.size() > 0) {
            map<Id, Opportunity> previousOppMap = new map<Id, Opportunity>([SELECT Id, RecordTypeId, RecordType.Name, Original_Opportunity_RecordTypeId__c, Previous_Opportunity__r.RecordTypeId
                                                                           FROM Opportunity WHERE Id IN :previousOppIds]);
            
            //Loop through opportunity list.
            for(Opportunity newOpp : newOppList)    {
                
                //Getting value from the map 
                Opportunity preOpp = previousOppMap.get(newOpp.Previous_Opportunity__c);
                
                //carry the originating program and Original RecordType on to subsequent opportunities, for use on Amendment opps
                newOpp.Original_Opportunity_RecordTypeId__c = preOpp.Original_Opportunity_RecordTypeId__c;
            }
        }
     }
            
    //Added By - Abhinav Sharma - 05/20/2016 - CR-20160308-9682
    /**
     *  @description    :   Method to keep opportunity "Main Contact" field and associated Opportunity Contact Role records. 
     *                      in sync.
     * 
     *  @args           :   List of opportunities, Map of old opprtunities
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.1 - Mahendra Swarnkar - 03/18/2017 - CR-20170216-10694
     * 
    **/
    public static void syncOppMainContactAndPrimayOCR(List<Opportunity> newOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        /************       Mahendra Swarnkar - 03/18/2017 - CR-20170216-10694    Start ************/
        
        if(!DO_NOT_EXECUTE_OCR_SYNC_TRIGGER_LOGIC) {
            
            //Set to hold the eligible opportunity records IDs
            Set<Id> setOpportunitiesIds = new Set<Id>();
            
            //loop through opportunity records
            for(Opportunity opp : newOpportunities) {
                
                //Insert use case
                if(newOpportunities != null && mapOldOpportunities == null) {
                    if(opp.Main_Contact__c != null)
                        setOpportunitiesIds.add(opp.Id);
                }
                
                //Update use case
                if(newOpportunities != null && mapOldOpportunities != null) {
                    if(opp.Main_Contact__c != mapOldOpportunities.get(opp.Id).Main_Contact__c)
                        setOpportunitiesIds.add(opp.Id);
                }
            }
            DO_NOT_EXECUTE_OCR_SYNC_TRIGGER_LOGIC = true;
            OpportunityTriggerHelper.syncOppMainContactAndPrimayOCR(setOpportunitiesIds, newOpportunities);
            
        }
        
    }
    
    //Added By - Abhinav Sharma - 10/14/2015 - CR-20150831-9204 - CT Assignment Manager - update logic
    /**
     *  @description    :   Method to populate CT Assignment's Manager field. 
     *                      Whenever the related CT Assignment field gets populated or changed. 
     * 
     *  @args           :   List of opportunities
     * 
     *  @return         :   void
     * 
    **/
    public static void populateCTAssignmentManagerEmail(List<Opportunity> listOpportunities) {
        
        //Set to users ids
        Set<Id> setUsersIds = new Set<Id>();
        
        //Loop through oportunity records
        for(Opportunity opp : listOpportunities) {
            if(opp.CT_Assignment__c != null)
                setUsersIds.add(opp.CT_Assignment__c);
        }
        
        //Map of users
        Map<Id, User> mapUsers = new Map<Id, User>();
        
        //Checking set for size value
        if(setUsersIds.size() > 0) {
            
            //Map to hold the opportunity ID as key and CT Assignment Manager email as value
            mapUsers = new Map<Id, User>([SELECT ID, ManagerId, Manager.Email FROM User
                                                            WHERE ID IN: setUsersIds]);
            
        }
        
        //Loop through new version of opportunity records and updating/populating CT Assignment's Manager 
        //field with value
        for(Opportunity op : listOpportunities) {
            
            //Checking for CT Assignment value
            if(op.CT_Assignment__c != null) {
                
                if(mapUsers.containsKey(op.CT_Assignment__c)
                   && mapUsers.get(op.CT_Assignment__c) != null
                   && mapUsers.get(op.CT_Assignment__c).ManagerId != null) {
                       if(op.CT_Assignment_s_Manager__c != mapUsers.get(op.CT_Assignment__c).Manager.Email)    
                           op.CT_Assignment_s_Manager__c = mapUsers.get(op.CT_Assignment__c).Manager.Email;
                   }        
                else
                    op.CT_Assignment_s_Manager__c = null;
                
            } else {
                op.CT_Assignment_s_Manager__c = null;
            }
        }
    }
     
    //Commented origination_channel__c, originator__c - By Mahendra Swarnkar - spring clean up - 04/29/2019
    //Modified By - Abhinav Sharma - 12/02/2015 - CR-20151022-9349
    //Added By - Abhinav Sharma - CR-20150820-9167 - 08/25/2015 - Exceeded the Spanning Relationship limit on Opportunities
    /**
     *  @description    :   This method to populate fields on opportunity records, while those were committing to the database. (On before event)
     * 
     *  @args           :   List of opportunities, Map of Opportunities
     * 
     *  @return         :   void
     * 
    **/
    public static void doCalculationAndPopulateFieldsOnOpportunities(List<Opportunity> listOpportunities, Map<Id, Opportunity> mapOpportunities) {
        
        //Set to hold opportunity Ids having "not null" value for Marketer__c lookup field
        Set<Id> setOppIdsHavingNotNullMarketer = new Set<Id>();
        
        //Set to hold the opportunity Ids having "not null" value for Signed_Opportunity_Contract__c lookup field
        Set<Id> setOppIdsHavingNotNullSignedOpportunityContract = new Set<Id>();
        
        //Set to hold the opportunity Ids having "not null" value for "Parent_Opportunity__c" lookup field
        Set<Id> setOppIdsWIthNotNullParentOpportunity = new Set<Id>();
        
        //Map to hold the opportunity records on whom marketer field got changed
        Map<Id, Opportunity> mapOpportunityWithMarketerChange = new Map<Id, Opportunity>();
   
        //Set to hold the marketer and originator Ids
        Set<Id> setUsersIds = new Set<Id>();
        
        //Loop through opportunity records
        for(Opportunity opp : listOpportunities) {
            
            //Checking marketer field for null value
            if(opp.Marketer__c != null)
                setOppIdsHavingNotNullMarketer.add(opp.Marketer__c);
            
            //Checking signed opportunity contract field for null value
            if(opp.Signed_Opportunity_Contract__c != null)
                setOppIdsHavingNotNullSignedOpportunityContract.add(opp.Signed_Opportunity_Contract__c);

            //Checking parent opportunity field for null value            
            if(opp.Parent_Opportunity__c != null)
                setOppIdsWIthNotNullParentOpportunity.add(opp.Parent_Opportunity__c);
            
            //Checking for marketer field value change and populating map with instances accordingly
            if(mapOpportunities != null 
                && 
                (opp.Marketer__c != mapOpportunities.get(opp.Id).Marketer__c
                ||
                opp.OwnerId != mapOpportunities.get(opp.Id).OwnerId)
            )               
                mapOpportunityWithMarketerChange.put(opp.Id, opp);
            
            //Checking for the field value and populating collection with value
            if(opp.Marketer__c != null)
                setUsersIds.add(opp.Marketer__c);
            
            //Checking for the owner value and populating collection with it's value
            if(opp.OwnerId != null)
                setUsersIds.add(opp.OwnerId);
            
            //Checking for the field value and populating collection with value
            if(mapOpportunities != null && mapOpportunities.get(opp.Id).Marketer__c != null)
                setUsersIds.add(mapOpportunities.get(opp.Id).Marketer__c);
            
            //Checking for the owner value and populating collection with it's value
            if(mapOpportunities != null && mapOpportunities.get(opp.Id).OwnerId != null)
                setUsersIds.add(mapOpportunities.get(opp.Id).OwnerId);
        }
        
        //Map of users
        Map<Id, User> mapOfUsers = new Map<Id, User>();
        
        //Checking set for size value
        if(setUsersIds.size() > 0) {
            mapOfUsers = new Map<Id, User>([SELECT ID, C_M_Channel__c FROM User 
                                            WHERE IsActive = true AND ID IN : setUsersIds]);
        }
            
        //Map of Marketers
        Map<Id, User> mapMarketers = new Map<Id, User>();
        
        //Map of Signed Opportunity Contracts
        Map<Id, Contract__c> mapSignedOppContracts = new Map<Id, Contract__c>();
        
        //Map of parent opportunities
        Map<Id, Opportunity> mapParentOpportunities = new Map<Id, Opportunity>();
        
        //Checking set for size value
        if(setOppIdsHavingNotNullMarketer.size() > 0) {
            
            //Loop through marketers and populating map with appropriate key-value pair value
            for(User u :  [SELECT ID, FirstName, LastName FROM User
                            WHERE ID IN : setOppIdsHavingNotNullMarketer])
                mapMarketers.put(u.Id, u);
        }
        
        //Checking set for size value
        if(setOppIdsHavingNotNullSignedOpportunityContract.size() > 0) {
            
            //Loop through signed opp contracts and populating map accordingly
            for(Contract__c con : [SELECT ID, Type__c FROM Contract__c 
                                   WHERE ID IN : setOppIdsHavingNotNullSignedOpportunityContract])
               mapSignedOppContracts.put(con.Id, con); 
        }
        
        //Checking set for size value
        if(setOppIdsWIthNotNullParentOpportunity.size() > 0) {
            
            //Loop through parent opportunities and populating map accordingly
            for(Opportunity op : [SELECT ID, Chairman_s_Team_Rep__c FROM Opportunity 
                                   WHERE ID IN : setOppIdsWIthNotNullParentOpportunity])
               mapParentOpportunities.put(op.Id, op);
        }
        
        //Loop through opportunity records
        for(Opportunity o : listOpportunities) {
                        
            //Renewal Contract Type (Renewal_Contract_Type__c)
            if(o.Signed_Opportunity_Contract__c != null 
                && mapSignedOppContracts.containsKey(o.Signed_Opportunity_Contract__c)
                && mapSignedOppContracts.get(o.Signed_Opportunity_Contract__c) != null   
            ) {
                o.Renewal_Contract_Type__c = mapSignedOppContracts.get(o.Signed_Opportunity_Contract__c).Type__c;
            } else {
                o.Renewal_Contract_Type__c = null;
            }
            
            //Renewed from Chairman’s Team (Renewed_from_Chairman_s_Team__c)
            if(o.Parent_Opportunity__c != null 
                && mapParentOpportunities.containsKey(o.Parent_Opportunity__c)
                && mapParentOpportunities.get(o.Parent_Opportunity__c) != null   
            ) {
                if(String.isBlank(mapParentOpportunities.get(o.Parent_Opportunity__c).Chairman_s_Team_Rep__c))
                    o.Renewed_from_Chairman_s_Team__c = 'No';
                else
                    o.Renewed_from_Chairman_s_Team__c = 'Yes';           
            } else {
                o.Renewed_from_Chairman_s_Team__c = null;
            }
            
            //Added By - Abhinav Sharma - 12/02/2015 - CR-20151022-9349
            //Start from here
            //Logic to populate "Ownership Channel" and "Origination Channel" fields
            //Insert event - Use cases
            if(listOpportunities != null && mapOpportunities == null) {
                
                //Insert use case default logic:- 
                //IF Marketer__c is NULL, THEN Owner.C_M_Channel__c ELSE Mareter__c.C_M_Channel__c
                if(o.Marketer__c == null) {
                    if(mapOfUsers != null && mapOfUsers.containsKey(o.OwnerId) && mapOfUsers.get(o.OwnerId) != null)
                        o.Ownership_Channel__c = mapOfUsers.get(o.OwnerId).C_M_Channel__c;
                    else
                        o.Ownership_Channel__c = null;
                } else {
                    if(mapOfUsers != null && mapOfUsers.containsKey(o.Marketer__c) && mapOfUsers.get(o.Marketer__c) != null)
                        o.Ownership_Channel__c = mapOfUsers.get(o.Marketer__c).C_M_Channel__c;
                    else
                        o.Ownership_Channel__c = null;
                }
            }
            
            //Update event - Use cases
            if(listOpportunities != null && mapOpportunities != null) {
                
                //IF value in Marketer__c is changed then only update the Ownership Channel field with value 
                //as per above mentioned if logic.
                //Otherwise, Users should be able to update the value in this field.
                //So if a user updates the value, that value stays unless the Marketer__c field is updated.
                if(mapOpportunityWithMarketerChange.containsKey(o.Id) && mapOpportunityWithMarketerChange.get(o.Id) != null) {
                    if(o.Marketer__c == null) {
                        if(mapOfUsers != null && mapOfUsers.containsKey(o.OwnerId) && mapOfUsers.get(o.OwnerId) != null)
                            o.Ownership_Channel__c = mapOfUsers.get(o.OwnerId).C_M_Channel__c;
                        else
                            o.Ownership_Channel__c = null;
                    } else {
                        if(mapOfUsers != null && mapOfUsers.containsKey(o.Marketer__c) && mapOfUsers.get(o.Marketer__c) != null)
                            o.Ownership_Channel__c = mapOfUsers.get(o.Marketer__c).C_M_Channel__c;
                        else
                            o.Ownership_Channel__c = null;
                    }
                }
                
            }
        }
    }    
    
    //Added By - Abhinav Sharma - CR-20150820-9167 - 08/25/2015 - Exceeded the Spanning Relationship limit on Opportunities
    /**
     *  @description    :   This method is apply validations over opportunity records, while those were committing to the database. 
     * 
     *  @args           :   List of opportunities, Map of Opportunities
     * 
     *  @return         :   void
     * 
    **/
    public static void applyValidationsOverOpportunityRecords(List<Opportunity> listOpportunities, Map<Id, Opportunity> mapOpportunities) {
        
        //Current logged in user Id
        Id loggedInUserProfileId = Userinfo.getProfileId();
        
        //Map of profiles will be helpful in bypassing of validation logic for few specific profiles
        Map<Id, String> mapOfProfiles = new Map<Id, String>();
        
        //Modified by rajeev jain 05/16/2019 CR-20190201-12861
        //Retrieving administrator type profiles and populating set with their Ids
        for(Profile pR : oRGProfiles) {
            
            //Check Profile Name
            if(pR.Name == 'System Administrator' || pR.Name == 'Finance Ops')
                mapOfProfiles.put(pr.Id, pr.Name);
        }
      
        //Will satisfied to true only on Insert of record(s)
        if(listOpportunities != null && mapOpportunities == null) {
            
            //Bypassing validation logic for administrator type profiles
            if(loggedInUserProfileId != null && !mapOfProfiles.containsKey(loggedInUserProfileId)) {
                
                //Map of records types
                Map<Id, RecordType> mapRecordTypes = new Map<Id, RecordType>();
                
                //Loop through opportunity active record types and populating the map accordingly
                for(RecordType rd : [SELECT ID, DeveloperName FROM RecordType WHERE IsActive = true 
                                     AND sObjectType = 'Opportunity'])
                    mapRecordTypes.put(rd.Id, rd);
        
                //loop through opportunity records
                for(Opportunity opp : listOpportunities) {
                    
                    //Your profile is not allowed to create Account Management Opportunities.
                    if(opp.RecordTypeId != null 
                        && mapRecordTypes.containsKey(opp.RecordTypeId)
                        && mapRecordTypes.get(opp.RecordTypeId) != null
                        && mapRecordTypes.get(opp.RecordTypeId).DeveloperName != null) {
                        
                        //Subhash Garhwal - 07/13/2016 - CR-20160414-9762 - Added new check for Program Opps record types
                        //Will add error on record if record type equals 
                        //RI AM Standard Opp or RI AM First Year Opp or PT Contract Maintenance or PT Contract Renewal
                        if(CPQConstants.SET_PROGRAM_OPP_RENEWAL_MAINTENANCE_RECORDTYPE_DN.contains(mapRecordTypes.get(opp.RecordTypeId).DeveloperName))
                            opp.addError(System.Label.Error_Create_Account_Management_Opportunity);      
                    }
                }
            }        
        } 
        
        //Set to hold the "Rate Card Set" records Ids 
        Set<Id> setRateCardSets = new Set<Id>();
        
        //Loop through opportunities and populating set with parent rate card set id values
        for(Opportunity o : listOpportunities) {
            
            //Checking if "Rate Card Set" field for null value
            if(o.pse__Rate_Card_Set__c != null)
                setRateCardSets.add(o.pse__Rate_Card_Set__c);
        }
        
        //Checking set for size value
        if(setRateCardSets.size() > 0) {
            
            //Map of Rate Card Sets
            Map<Id, pse__Rate_Card_Set__c> mapRateCardSets = new Map<Id, pse__Rate_Card_Set__c>([SELECT ID, CurrencyIsoCode 
                                                                                                FROM pse__Rate_Card_Set__c
                                                                                                WHERE ID IN : setRateCardSets]);
        
            //Opp_Rate_Card_Set_Currency_Mismatch
            for(Opportunity op : listOpportunities) {
                
                if(op.pse__Rate_Card_Set__c != null 
                    && 
                    (
                        op.CurrencyIsoCode == ''
                        ||
                        (mapRateCardSets.containsKey(op.pse__Rate_Card_Set__c) 
                         && mapRateCardSets.get(op.pse__Rate_Card_Set__c) != null
                         && mapRateCardSets.get(op.pse__Rate_Card_Set__c).CurrencyIsoCode == ''
                        )
                        ||
                        (mapRateCardSets.containsKey(op.pse__Rate_Card_Set__c) 
                         && mapRateCardSets.get(op.pse__Rate_Card_Set__c) != null
                         && mapRateCardSets.get(op.pse__Rate_Card_Set__c).CurrencyIsoCode != op.CurrencyIsoCode
                        )
                    )
                )       
                op.addError(System.Label.Error_Opp_Rate_Card_Set_Currency_Mismatch);
            }
        }
    }
    
    //This method is to rollup the opportunity info on account level
    public static void rollupOppsDataOnAccount(List<Opportunity> listOpportunities) {}        
    
    // This method is to update the Initial Visit Date on opportunity object with the most recent active event
    //if no active event is there flag will be false
    public static void updateInitialVisitDateByEventDate(Map<Id, Opportunity> mapOpportunities){
        
        //Check if Opportunity initial visit date need to be modified
        if(DO_NOT_OVERWRITE_INITIAL_VISIT_DATE == false) {
       
            //Map to hold the Opportunity ID as key and corresponding event record as value
            Map<Id, Event> mapOppIdWithEvent = new Map<Id, Event>();
            
            //Loop through events
            for(Event evt : [Select Id, StartDateTime, Event_Purpose__c from Event where Cancelled_Did_Not_Occur__c = false  
                             AND IsDeleted = false AND WhatId != null AND WhatId IN : mapOpportunities.keySet() 
                             AND (Event_Type__c =: Constants.EVENT_TYPE_OPPORTUNITY_VISIT_FOR_OPPORTUNITY_GOAL 
                              OR (Event_Type__c =: Constants.EVENT_TYPE_IN_PERSON_VISIT AND 
                                  (Event_Purpose__c =: Constants.EVENT_PURPOSE_INITIAL  /*OR Event_Purpose__c =: Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT*/)) 
                              OR Event_Type__c =: Constants.EVENT_TYPE_PROSPECT_MEETING_ATTENDEE_COUNT_AS_VISIT) 
                             ORDER BY CreatedDate DESC limit 1 ALL ROWS]) {
                if(!mapOppIdWithEvent.containsKey(evt.WhatId))
                    mapOppIdWithEvent.put(evt.WhatId, evt);
            }
            
            //if(DO_NOT_EXECUTE == false) {
            //fecth all the events associated with the opportunities
            //and loop through the records to get the lastest active event
            //11/05/2012 - Bhavi - CR-20120920-1514
            if(mapOpportunities.keySet().size() > 0) {
                
                //Loop through opportunity records
                for(Opportunity opp : [Select Id, Initial_Visit_Date__c from Opportunity where Id IN: mapOpportunities.keySet()]) {
                
                    //Check if there is any active event is assciated 
                    if(mapOppIdWithEvent != null && mapOppIdWithEvent.values().size() > 0 
                        && mapOppIdWithEvent.containsKey(opp.Id) && mapOppIdWithEvent.get(opp.Id) != null
                        && mapOppIdWithEvent.get(opp.Id).StartDateTime != null) {
                        
                        //Not Cancelled latest event: So copy this date to opportunity's Initial Visit Date
                        mapOpportunities.get(opp.Id).Initial_Visit_Date__c = Date.valueOf(opp.Events[0].StartDateTime);
                    
                    } else {
                    
                        //No events associted with this opportunity record or all events have been cancelled so mark Initial Visit Date as null
                        mapOpportunities.get(opp.Id).Initial_Visit_Date__c = null;
                    }
                }        
            }
        }
    }
    
    //Modified By - Nikita Kumari - 10/13/2021 - CR-20211008-15505 - Comment out the methods unwanted/unused methods assignContactToCampaign() and getProgAcronym() -- Starts here
    // associate a given contact record to a given campaign 
    // by creating a campaign member record for it
    /*public static CampaignMember assignContactToCampaign(String contactId, String campaignId, Opportunity oppty) {
        
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = campaignId;
        cm.ContactId = contactId;
        cm.Opportunity__c = oppty.Id;
        cm.Status = 'Warm From Opp';
        cm.Marketer_Assignment__c = oppty.Marketer__c;
        cm.MA_Assignment__c = oppty.Marketing_Associate__c;
        return cm;
    }
        
    public static Set<String> getProgAcronym(String programs) {

        // if programs is null, return immediately
        if (programs == null) return null;
        
        String acronym = '';
        Set<String> acronyms = new Set<String>();
        // get the program acronym from the prog name which is like "HCAB - Health care advisory board"
        List<String> progNames = programs.split(';');
        for (String prog : progNames) {
            List<String> parts = prog.split(' ');
            
            if (parts.size() > 0) {
                acronym = parts[0];
                acronyms.add(acronym);
            }
        }
        
        return acronyms;
    } *///Modified By - Nikita Kumari - 10/13/2021 -CR-20211008-15505 - Comment out the methods unwanted/unused methods assignContactToCampaign() and getProgAcronym() -- Ends here
        
    //This method is to set the Agreement status to cancelled for agreements if the Opportunity status dropped/lost/void
    public static void validateAgreementsStatus(Map<Id, Opportunity> mapNewOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        //Create a set to hold the opprotunities id where status has been changed and set to dropped/lost/void
        Set<Id> setOpportunityIDs = new Set<Id>();
        
        //Loop though the Opportunities
        for(Opportunity opp : mapNewOpportunities.values()) {
            
            //If the Opportunity status has been changed and set to dropped/lost/void
            if(opp.StageName != null && opp.StageName != Constants.BLANK && opp.StageName != mapOldOpportunities.get(opp.Id).StageName
                && (Constants.STAGE_OPPORTUNITY_CLOSED_LOST.equalsIgnoreCase(opp.StageName)
                    || Constants.STAGE_OPPORTUNITY_VOID.equalsIgnoreCase(opp.StageName)
                    || Constants.STAGE_OPPORTUNITY_DROPPED.equalsIgnoreCase(opp.StageName))
                ) {
                
                //add opportunity id in set
                setOpportunityIDs.add(opp.Id);
            }
        }
        
        //Check if there are opportunities to process
        if(setOpportunityIDs.size() > 0) {
            
            //Create a list to hold the Agreement records to be updated
            List<echosign_dev1__SIGN_Agreement__c> agreements = new List<echosign_dev1__SIGN_Agreement__c>();
            
            //Query all the agreements related to the opportunities records and not having cancelled status
            for(echosign_dev1__SIGN_Agreement__c agreement : [Select Id from echosign_dev1__SIGN_Agreement__c where echosign_dev1__Status__c !=: Constants.STATUS_AGREEMENT_CANCELLED_DECLINED AND echosign_dev1__Opportunity__c IN: setOpportunityIDs]) {
                
                //Set the Agreement status
                agreement.echosign_dev1__Status__c = Constants.STATUS_AGREEMENT_CANCELLED_DECLINED;
                
                //Add record in list
                agreements.add(agreement);
            }
            
            //Check if tehre are records to update
            if(agreements.size() > 0)
                update agreements;
        }
    }
    
    //This method is to update the related Main Contact  field on Contact
    //Subhash Garhwal - 05/02/2017 - Updated method to The Main_Contact__c field should be populated with the Program Acronym of all related
    //Opportunity Products where the Product’s Component field is false (ie: OpportunityProduct.Product.SBQQ__Component__c = false).
    public static void populateContactData(Map<Id, Opportunity> mapNewOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        //Get all the opportunity record types for record Type Like Renewal
        Set<String> setRecordTypeName = new Set<String>();
        setRecordTypeName.add(Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_MAINTENANCE);
        setRecordTypeName.add(Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_RENEWAL);
        
        //Add New record Types (Initiating and Continuing)
        setRecordTypeName.addAll(CPQConstants.SET_OPPORTUNITY_RECORDTYPE_NAMES);
        
        // get all record types on opportunity object
        Map<String, Id> oppRecordTypeMap = Util.recordtypemap('Opportunity');
        
        // get opportunity record types
        Map<Id, String> mapRecordTypes = new Map<Id, String>();
        for (String rtName : setRecordTypeName) {
            mapRecordTypes.put(oppRecordTypeMap.get(rtName), rtName);
        }
        
        //Loop through the opportunity records and create a set of appropriate records
        Set<Id> oppIds = new Set<Id>();
        
        //Create a Map to hold teh Contact records
        Set<Id> mainContacts = new Set<Id>();
        
        //Map to hold contacts
        Map<Id, Contact> mapContact = new Map<Id, Contact>();
        
        //Set to hold thee Opportunity Id
        Set<Id> setOpportunityIds = new Set<Id>();
        
        //Check for teh update and delete case
        if(mapOldOpportunities != null) {
            
            //loop through the Old records
            for(Opportunity opportunity : mapOldOpportunities.values()) {
            
                //Check for the conditions
                if(mapRecordTypes.containsKey(opportunity.RecordTypeId) 
                    && opportunity.CloseDate != null && opportunity.CloseDate.year() == Date.today().year() 
                    && opportunity.StageName != null && (opportunity.StageName.toLowerCase().contains(Constants.PENDING.toLowerCase()) 
                                                            || opportunity.StageName.toLowerCase().contains(Constants.STATUS_ATL.toLowerCase())
                                                            || opportunity.StageName.toLowerCase().contains(Constants.STAGE_OPPORTUNITY_VOID.toLowerCase())
                                                            || opportunity.StageName.toLowerCase().contains(Constants.STAGE_OPPORTUNITY_DROPPED.toLowerCase()))) {
                    
                    setOpportunityIds.add(opportunity.Id);
                    
                    //Check if record has Main Contact
                    if(opportunity.Main_Contact__c != null)
                        mainContacts.add(opportunity.Main_Contact__c);
                }
            }
        }
        
        //Check for the insert and update case
        if(mapNewOpportunities != null) {
        
            //loop through the new records
            for(Opportunity opportunity : mapNewOpportunities.values()) {
            
                //Check for the conditions
                if(mapRecordTypes.containsKey(opportunity.RecordTypeId) 
                    && opportunity.CloseDate != null && opportunity.CloseDate.year() == Date.today().year() 
                    && opportunity.StageName != null && (opportunity.StageName.toLowerCase().contains(Constants.PENDING.toLowerCase()) 
                                                            || opportunity.StageName.toLowerCase().contains(Constants.STATUS_ATL.toLowerCase())
                                                            || opportunity.StageName.toLowerCase().contains(Constants.STAGE_OPPORTUNITY_VOID.toLowerCase())
                                                            || opportunity.StageName.toLowerCase().contains(Constants.STAGE_OPPORTUNITY_DROPPED.toLowerCase()))) {
                    
                    setOpportunityIds.add(opportunity.Id);
                    
                    //Check if record has Main Contact
                    if(opportunity.Main_Contact__c != null)
                        mainContacts.add(opportunity.Main_Contact__c);
                }
            }
        }
        
        //Check if there are Main Contacts to Process
        if(mainContacts.size() > 0) {
            
            //Fecth all the Contact records
            Map<Id, Contact> mapMainContacts = new Map<Id, Contact>([Select Id, Main_Contact__c from Contact where Id IN: mainContacts]);
            
            //Map to hold the Opportunity with related Program Acronym
            Map<Id, String> mapOppIdWithProgramAcronyms = new Map<Id, String>();
            
            //SOQL Query on the Opportunity Product
            for(OpportunityLineItem oLI : [Select Id, Product2.Program__r.Program_Acronym__c, OpportunityId From OpportunityLineItem
                                                  Where OpportunityId IN : setOpportunityIds AND Product2.SBQQ__Component__c = false AND Product2.Program__r.Program_Acronym__c != null]) {
                                                    
                //Check Opportunity Id in map
                if(!mapOppIdWithProgramAcronyms.containsKey(oLI.OpportunityId))
                    mapOppIdWithProgramAcronyms.put(oLI.OpportunityId, '');
                
                //Get Existing Program Acronym
                String programAcronym = mapOppIdWithProgramAcronyms.get(oLI.OpportunityId);
                
                //Add Addition value
                programAcronym += oLI.Product2.Program__r.Program_Acronym__c + Constants.COMMA + Constants.SPACE;
                
                //Add values in map
                mapOppIdWithProgramAcronyms.put(oLI.OpportunityId, programAcronym);
            }
            
            
            //Check for the update and delete case
            if(mapOldOpportunities != null) {
            
                //Loop through the Old records first and Update the Main 
                for(Opportunity opportunity : mapOldOpportunities.values()) {
                    
                    //Check for the opportunity.Main_Contact__c
                    if(opportunity.Main_Contact__c != null) {
                    
                        //Contact cloneContact
                        Contact cloneContact;
                        
                        //Check for the contact and update contact's data
                        if(mapContact.containsKey(opportunity.Main_Contact__c)) {
                            
                            //Get the contact record from map
                            cloneContact = mapContact.get(opportunity.Main_Contact__c);
                        } else if(mapMainContacts.containsKey(opportunity.Main_Contact__c)) {
                            
                            //Create a contact clone
                            cloneContact = new Contact(Id = opportunity.Main_Contact__c, 
                                                        Main_Contact__c = mapMainContacts.get(opportunity.Main_Contact__c).Main_Contact__c);
                        }
                        
                        // if cloneContact wasn't found -- continue to the next record
                        if (cloneContact == null) continue;
                        
                        if(cloneContact.Main_Contact__c != null && cloneContact.Main_Contact__c != '' 
                                /*&& cloneContact.Main_Contact__c.contains(opportunity.Program_Acronym__c)*/ && mapOppIdWithProgramAcronyms.containsKey(opportunity.Id)) {
                                
                            //Set program acronym in cloneContact
                            cloneContact.Main_Contact__c = cloneContact.Main_Contact__c.replace(mapOppIdWithProgramAcronyms.get(opportunity.Id), '');
                                                                                /*.replace(Constants.COMMA + Constants.SPACE + opportunity.Program_Acronym__c, '')
                                                                                .replace(opportunity.Program_Acronym__c, '');*/
                        }
                        
                        //Updated by - Saurabh Kumar - 07/03/2017 - Checking for null check to remove null pointer exception
                        if(String.isNotBlank(cloneContact.Main_Contact__c))
                          //make sure the main_contact__c string is at or less than the max 255 chars
                          cloneContact.Main_Contact__c = cloneContact.Main_Contact__c.abbreviate(255);
                        
                        //Put the contact record in map
                        mapContact.put(opportunity.Main_Contact__c, cloneContact);
                    }
                }
            }
            
            //Check for the Insert and Update
            if(mapNewOpportunities != null) {
            
                //Loop through the New records
                for(Opportunity opportunity : mapNewOpportunities.values()) {
                    
                    //Check for the opportunity.Main_Contact__c
                    if(opportunity.Main_Contact__c != null) {
                    
                        //Contact cloneContact
                        Contact cloneContact;
                        
                        //Check for the contact and update contact's data
                        if(mapContact.containsKey(opportunity.Main_Contact__c)) {
                            
                            //Get the contact record from map
                            cloneContact = mapContact.get(opportunity.Main_Contact__c);
                        } else if(mapMainContacts.containsKey(opportunity.Main_Contact__c)) {
                            
                            //Create a contact clone
                            cloneContact = new Contact(Id = opportunity.Main_Contact__c, 
                                                        Main_Contact__c = mapMainContacts.get(opportunity.Main_Contact__c).Main_Contact__c);
                        }
                        
                        // if cloneContact wasn't found -- continue to the next record
                        if (cloneContact == null) continue;
                        
                        if(cloneContact.Main_Contact__c != null && cloneContact.Main_Contact__c != '') {
                                
                            //Check if Contact doesn't have this already
                            if(mapOppIdWithProgramAcronyms.containsKey(opportunity.Id) && !cloneContact.Main_Contact__c.contains(mapOppIdWithProgramAcronyms.get(opportunity.Id))) {
                                    
                                //Set program acronym in cloneContact
                                cloneContact.Main_Contact__c += mapOppIdWithProgramAcronyms.get(opportunity.Id); /*Constants.COMMA + Constants.SPACE + opportunity.Program_Acronym__c;*/
                            }
                        } else {
                                
                            //Set program acronym in cloneContact
                            cloneContact.Main_Contact__c = mapOppIdWithProgramAcronyms.get(opportunity.Id);
                        }
                        
                        //Check for void and droppped opportunities
                        if(opportunity.StageName.toLowerCase().contains(Constants.STAGE_OPPORTUNITY_VOID.toLowerCase())
                            || opportunity.StageName.toLowerCase().contains(Constants.STAGE_OPPORTUNITY_DROPPED.toLowerCase())) {
                            
                            //Remove Program acronym from Main Contact 
                            if(cloneContact.Main_Contact__c != null && cloneContact.Main_Contact__c != '' 
                                && opportunity.Program_Acronym__c != null
                                && cloneContact.Main_Contact__c.contains(opportunity.Program_Acronym__c)
                                && mapOppIdWithProgramAcronyms.containsKey(opportunity.Id)) {
                                
                                //Set program acronym in cloneContact
                                cloneContact.Main_Contact__c = cloneContact.Main_Contact__c
                                                                                    .replace(mapOppIdWithProgramAcronyms.get(opportunity.Id), '');
                            }
                        }
                        
                        //V_1.66 - Modified By - Mahendra Swarnkar - 03/09/2018 - CR-20180309-12096 - starts from here 
                        //make sure the main_contact__c string is at or less than the max 255 chars
                        if(String.isNotBlank(cloneContact.Main_Contact__c))
                          cloneContact.Main_Contact__c = cloneContact.Main_Contact__c.abbreviate(255);
                        //V_1.66 - Modified By - Mahendra Swarnkar - 03/09/2018 - CR-20180309-12096 - Ends from here
                        
                        //Put the contact record in map
                        mapContact.put(opportunity.Main_Contact__c, cloneContact);
                    }
                }
            }
            
            //Check if there are records to update
            if(mapContact.size() > 0) {
                // bypass triggers when updating the contact's Main_Contact__c field
                Util.BypassAllTriggers = true;
                update mapContact.values();
                Util.BypassAllTriggers = false;
            }
        }
    }
    
    public static void populateInitialVisitOnActivities(list<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap) {
        
        // set of opp ids to update
        set<Id> oppIdSet = new set<Id>();
        
        map<Id, Opportunity> oppMap = new map<Id, Opportunity>();
        
        // figure out which opportunities need to be updated
        for (Opportunity opp : newOppList) {
            
            Opportunity oldOpp = oldOppMap.get(opp.Id);
            
            if (opp.Initial_Visit_Date__c != oldOpp.Initial_Visit_Date__c) {
                
                oppMap.put(opp.Id, opp);
                oppIdSet.add(opp.Id);
            }
        }
        
        //Checking for size value
        if (oppIdSet.size() > 0) {
            
            if (system.isFuture() || system.isBatch()) {
                
                // update opp initial visit date on related events when the opportunity initial visit date is updated
                OpportunityTriggerHelper.populateInitialVisitOnEvents(oppMap);
                
                // update opp initial visit date on related events when the opportunity initial visit date is updated
                OpportunityTriggerHelper.populateInitialVisitOnTasks(oppMap);
            }
            else if (!Util.isPopulateInitVisitOnActivities_Future) {
                
                // set this to true to prevent recursive updates
                Util.isPopulateInitVisitOnActivities_Future = true;
                
                // if this is being triggered by a 
                populateInitialVisitOnActivities_Future(oppIdSet);
            }
        }
    }
    
    @future
    public static void populateInitialVisitOnActivities_Future(set<Id> oppIds) {
        
        //Checking for size and null value
        if(oppIds != null && oppIds.size() > 0) {
        
            // get a map of opportunities
            map<Id, Opportunity> oppMap = new map<Id, Opportunity>([SELECT Id, Initial_Visit_Date__c FROM Opportunity WHERE Id IN :oppIds]);
            
            // update opp initial visit date on related events when the opportunity initial visit date is updated
            OpportunityTriggerHelper.populateInitialVisitOnEvents(oppMap);
            
            // update opp initial visit date on related events when the opportunity initial visit date is updated
            OpportunityTriggerHelper.populateInitialVisitOnTasks(oppMap);
        }
    }
    
    // when the Initial Visit Date is updated on the Opportunity, update the Opp Initial Visit Date field on all related Events
    public static void populateInitialVisitOnEvents(Map<Id,Opportunity> oppMap) {
        
        //Checking for null and size value
        if(oppMap != null && oppMap.keySet().size() > 0) {
        
            // list to hold events that will be updated
            list<Event> eventsToUpdate = new list<Event>();
            
            // map of Opp Id to list of Events
            map<Id, list<Event>> oppToEventsMap = new map<Id, list<Event>>();
        
            // loop through each event and add to a map
            for (Event evt : [SELECT Id, Opp_Initial_Visit_Date__c, WhatId FROM Event 
                                WHERE IsDeleted = false AND WhatId IN :oppMap.keySet() ALL ROWS]) {
                
                // see if the list already exists
                list<Event> eventList = oppToEventsMap.get(evt.WhatId);
                if (eventList == null) eventList = new list<Event>();
                
                eventList.add(evt);
                
                // add the updated list back to the map
                oppToEventsMap.put(evt.whatId, eventList);
            }
        
            for (Opportunity opp : oppMap.values()) {
                
                // get the events for this opp
                list<Event> events = oppToEventsMap.get(opp.Id);
                
                // make sure event is not null
                if (events != null) {
                
                    for (Event evt : events) {
                        
                        // update the opp initial visit date on the event
                        evt.Opp_Initial_Visit_Date__c = opp.Initial_Visit_Date__c;
                        
                        // add to list of events to update
                        eventsToUpdate.add(evt);
                    }
                }
            }
        
            if (eventsToUpdate.size() > 0) {
                
                // update events
                util.BypassAllTriggers = true;
                update eventsToUpdate;
                util.BypassAllTriggers = false;
            }
        }        
    }
    
    // when the Initial Visit Date is updated on the Opportunity, update the Opp Initial Visit Date field on all related Events
    public static void populateInitialVisitOnTasks(Map<Id,Opportunity> oppMap) {
        
        // list to hold Tasks that will be updated
        list<Task> TasksToUpdate = new list<Task>();
        
        // map of Opp Id to list of Tasks
        map<Id, list<Task>> oppToTasksMap = new map<Id, list<Task>>();
        
        //Checking map for size and null value
        if(oppMap != null && oppMap.size() > 0) {
        
            // loop through each Task and add to a map
            for (Task tsk : [SELECT Id, Opp_Initial_Visit_Date__c, WhatId FROM Task WHERE WhatId IN :oppMap.keySet()]) {
                
                // see if the list already exists
                list<Task> TaskList = oppToTasksMap.get(tsk.WhatId);
                if (TaskList == null) TaskList = new list<Task>();
                
                TaskList.add(tsk);
                
                // add the updated list back to the map
                oppToTasksMap.put(tsk.whatId, TaskList);
            }
            
            for (Opportunity opp : oppMap.values()) {
                
                // get the Tasks for this opp
                list<Task> Tasks = oppToTasksMap.get(opp.Id);
                
                // make sure Task is not null
                if (Tasks != null) {
                
                    for (Task tsk : Tasks) {
                        
                        // update the opp initial visit date on the Task
                        tsk.Opp_Initial_Visit_Date__c = opp.Initial_Visit_Date__c;
                        
                        // add to list of Tasks to update
                        TasksToUpdate.add(tsk);
                    }
                }
            }
        
            if (TasksToUpdate.size() > 0) {
            
                // update Tasks
                util.BypassAllTriggers = true;
                update TasksToUpdate;
                util.BypassAllTriggers = false;
            }
        }        
    }
    
    //This method to update and populate the Opportunity Field Active Renewal according to associated Membership
    public static void populateFieldOnOpportunityWithMembership(List<Opportunity> newListOpportunities, Map<Id,Opportunity> oldMapOpportunities) {
        
        //Set of Membership associate with Opportunities
        Set<Id> setMembership = new Set<Id>();
        
        //Set of Record type Name
        Set<String> setRecordTypeName = new Set<String>();
        setRecordTypeName.add(Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_MAINTENANCE);
        setRecordTypeName.add(Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_RENEWAL);
        //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Program_RI_Renewal,RI AM Standard Opp
        //setRecordTypeName.add(Constants.RECORD_TYPE_OPPORTUNITY_RI_AM_FIRST_YEAR_OPP);
        //setRecordTypeName.add(Constants.RECORD_TYPE_OPPORTUNITY_RI_AM_STANDARD_OPP);
        
        // get all record types on opportunity object
        Map<String, Id> oppRecordTypeMap = Util.recordtypemap('Opportunity');
        
        // get opportunity record types
        Map<Id, String> mapRecordTypes = new Map<Id, String>();
        for (String rtName : setRecordTypeName)
            mapRecordTypes.put(oppRecordTypeMap.get(rtName), rtName);
        
        //Loop through the trigger.new
        for(Opportunity opp : newListOpportunities) {
            
            //Check criteria
            if(!opp.IsClosed && opp.Membership__c != null && opp.Pool_Date__c != null && mapRecordTypes.containsKey(opp.RecordTypeId)) {
                
                //Add Membership in set    
                setMembership.add(opp.Membership__c);
            }
        }
        
        //Check set size
        if(setMembership.size() > 0) {
            
            //Map to hold the existing active opportunities with Memnbership ids
            Map<Id, Opportunity> mapExistingActiveOpportunities = new Map<Id, Opportunity>();
            
            //Loop through list of Opportunities
            for(Opportunity opportunity : [SELECT Id, Name, Membership__c, Active_Renewal__c,IsClosed, Pool_Date__c FROM Opportunity 
                                                    WHERE Id NOT IN: Trigger.New AND Membership__c != null AND Membership__c IN: setMembership
                                                    AND Active_Renewal__c = true ]){
                
                //Put data in Map
                mapExistingActiveOpportunities.put(opportunity.Membership__c, opportunity);
            }
            
            //List to hold the opportunities to be updated'
            map<Id, Opportunity> opportunitiesToBeUpdated = new map<Id, Opportunity>();
            
            //Loop through the trigger.new
            for(Opportunity opp : newListOpportunities) {
                
                //Check criteria
                if(!opp.IsClosed && opp.Membership__c != null && opp.Pool_Date__c != null && mapRecordTypes.containsKey(opp.RecordTypeId)) {
                    
                    //Check if memship already has active opportunity
                    if(mapExistingActiveOpportunities.containsKey(opp.Membership__c)) {
                        
                        //Initialize opportunity record
                        Opportunity existingOpportunity = mapExistingActiveOpportunities.get(opp.Membership__c);
                        
                        //Check if exisitng opportunity is in the current year
                        //Exsiting record is in past and greater than new opportunity record
                        //Exsiting record is in future and smaller than new opportunity record
                        //do nothing
                        if(!existingOpportunity.IsClosed &&
                            (existingOpportunity.Pool_Date__c.year() == Date.today().year() 
                                || (existingOpportunity.Pool_Date__c.year() < Date.today().year() && (opp.Pool_Date__c.year() > Date.today().year() || existingOpportunity.Pool_Date__c.year() > opp.Pool_Date__c.year()))
                                || (existingOpportunity.Pool_Date__c.year() > Date.today().year() && existingOpportunity.Pool_Date__c.year() < opp.Pool_Date__c.year())))
                            continue;
                        else {
                            
                            //Mark is Active on currect record
                            opp.Active_Renewal__c = true;
                            
                            //Remove active flag from existing record
                            existingOpportunity.Active_Renewal__c = false;
                            
                            //add in list to be updated
                            opportunitiesToBeUpdated.put(existingOpportunity.Id, existingOpportunity);
                        }
                    } else {
                        
                        //Mark is Active on currect record
                        //opp.Trigger_Update__c = true;
                        opp.Active_Renewal__c = true;
                    }
                }
            }
            
            //Modified By - Ajit Surana - 01/22/2015 - CR-20141210-8281   
            //String to hold the log message
            String logMessage = '';
            
            //Check for the size and update the records
            if(opportunitiesToBeUpdated.size() > 0) {
                Util.BypassAllTriggers = true;
                Database.SaveResult[] results = database.update(opportunitiesToBeUpdated.values(), false);
                logMessage = Util.createLog(results); 
                Util.BypassAllTriggers = false;
            }
            
            //Checking if log message is there in case of error
            if(logMessage != '') {
                
                //User Instance
                List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' 
                                            AND IsActive = true AND Profile.Name = 'System Administrator' 
                                            AND Email != null LIMIT 1];
            
                //Send log to admin
                if(sfAdminUser.size() > 0)
                    EmailHandler.sendEmail(sfAdminUser[0].Email, System.Label.Error_OpportunityUpdate, logMessage);
            }
        }
    }
    
    //Method modified by Ajit Surana - 08/14/2014 - CR-20140731-6814
    //Added By - Abhinav Sharma - CR-20140502-5327 - 07/02/2014
    /**
     *  @description    :   This method is to update the Membership record with associated opportunity records fields value.
     *                      (i) Method to populate "Active Renewal Opportunity" field on membership record with opportunity Id value 
     * 
     *  @args           :   List of opportunities, Map of Opportunities
     * 
     *  @return         :   void
     * 
    **/ 
    public static void updateOpportunitiesWithDesiredFieldValues(List<Opportunity> newListOpportunities, Map<Id,Opportunity> oldMapOpportunities) {
        
        //Set of Membership associate with Opportunities
        Set<Id> setMembership = new Set<Id>();
        
        //Modified By - Ajit Surana - 08/14/2014 - CR-20140731-6814 - Use Map instead of List
        //Map to hold the membership records to be updated with appropriate values
        Map<Id, Membership__c> mapMembershipsGoingToBeUpdate = new Map<Id, Membership__c>();
        
        //Loop through the trigger.new
        for(Opportunity opp : newListOpportunities) {
            
            //Check criteria and then populate the set with Id values
            if(opp.Membership__c != null)
                setMembership.add(opp.Membership__c);
        }
        
        //Map to hold the Membership records to be updated
        Map<Id, Membership__c> mapMemberships = new Map<Id, Membership__c>();
        
        //Checking set for size value
        if(setMembership.size() > 0) {
        
            //Map to hold the Membership records to be updated
            mapMemberships = new Map<Id, Membership__c>([Select ID, Active_Renewal_Opportunity__c FROM Membership__c 
                                                            WHERE ID IN : setMembership]);
        }
        
        //Checking map for size value
        if(mapMemberships.keySet().size() > 0) {
            
            //Loop through the trigger.new
            for(Opportunity op : [SELECT Id, Name, Membership__c, Active_Renewal__c,IsClosed, Pool_Date__c, RecordTypeId FROM Opportunity 
                                               WHERE Membership__c != null AND Membership__c IN: mapMemberships.keySet()
                                               AND Active_Renewal__c = true]) {
                
                    
                //Proceed further only and only if we are having differences in between values for the field on membership record
                if(mapMemberships != null && mapMemberships.get(op.Membership__c) != null && op.Id != mapMemberships.get(op.Membership__c).Active_Renewal_Opportunity__c) {
                        
                    //Updating field values on membership record and then adding it to the list to be update
                    mapMemberships.get(op.Membership__c).Active_Renewal_Opportunity__c = op.Id;
                    mapMembershipsGoingToBeUpdate.put(op.Membership__c, mapMemberships.get(op.Membership__c));           
                }
            }
            
            //Check for the size and update the records
            if(mapMembershipsGoingToBeUpdate.size() > 0) {
                Util.BypassAllTriggers = true;
                update mapMembershipsGoingToBeUpdate.values();
                Util.BypassAllTriggers = false;
            }
        }            
   }
    
    /**
     *  @description    :   This method is to update the Warm lead counter information on opportunities
     * 
     *  @args           :   List of opportunities, Map of Opportunities
     * 
     *  @return         :   void
     * 
     **/ 
    public static void updateWarmLeadInfoOnOpportunity(List<Opportunity> newOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        //Set of opportunities Ids to hold the records where Initial visit date has been changed
        Set<Id> oppIds = new Set<Id>();
        
        //Loop through the opportunities
        for(Opportunity opportunity : newOpportunities) {
            
            //Check if initial data is not equals to old Initial date
            //Only include these opportunities to update
            if(opportunity.Initial_Visit_Date__c != mapOldOpportunities.get(opportunity.Id).Initial_Visit_Date__c) {
                
                //Add opportunity in set to be processed
                oppIds.add(opportunity.Id);
            }
        }
        
        //Check if set has opportunities to process
        if(oppIds.size() > 0) {
            
            //Call method to update these opportunities
            WarmLeadMtMTriggerHelper.updateWarmLeadInfoOnOpportunity(oppIds);
        }
    }
    
    //Added by Ajit Surana - 03/13/2014 - CR-20140205-4458
    /**
     *  @description    :   This method is to allow users to edit Non-SOX fields on Opportunity.
     * 
     *  @args           :   List of opportunities, Map of Opportunities
     * 
     *  @return         :   void
     * 
     **/ 
    public static void updateOpportunityNonSOXFields(List<Opportunity> newOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        Profile currentUserProfile;
        //Modified by Rajeev Jain 05/16/2019 CR-20190201-12861
        //Query to retreive current logged-in user Profile name 
        for(Profile pR : oRGProfiles) {
            
            //Check if
            if(pR.Id == UserInfo.getProfileId())
                currentUserProfile = pR;
        }
        
        String currentUserProfileName = currentUserProfile.Name.toLowerCase();
        
        //Variable to hold config manager data
        Map<String, Set<String>> MAP_Config_Manager = Constants.MAP_CONFIGURATION_MANAGER;     
        
        //JRB 2014-04-17 No longer using as criteria per hypercare update to CR-21040205-4458
        //Set to hold Profile names
        //Set<String> profilesAllowedForEditFields = new Set<String>();
        //if(MAP_Config_Manager.containsKey(Constants.PROFILE_EDIT_FIELDS_WHEN_OPP_IS_CLOSED))
        //  profilesAllowedForEditFields = MAP_Config_Manager.get(Constants.PROFILE_EDIT_FIELDS_WHEN_OPP_IS_CLOSED);
            
        //Set to hold Field values
        Set<String> fieldsAllowedForEdit = new Set<String>();
        if(MAP_Config_Manager.containsKey(Constants.EDITABLE_FIELD_AFTER_OPP_IS_CLOSED))
            fieldsAllowedForEdit = MAP_Config_Manager.get(Constants.EDITABLE_FIELD_AFTER_OPP_IS_CLOSED);
         
        /*  Modified by - Mahendra Swarnakar - 1/2/2017 - CR-20161227-10568 
        *  a) Moved the following profiles names into the CUstom label "Record_Level_Editable_Profiles", 
        *    so that we can save efforts to update "opportunityTriggerHelper" class for profile related changes. 
    	*    Profiles:- "[finance ops,financialforce accountant - restricted,system administrator,abc dataloader,
    	*                 financialforce ap operations - restricted, financialforce ar operations, 
    	*                 financialforce controller - restricted,financialforce read only - restricted]"
    	*   
    	*  b) As per the QA Notes On 1/06/2017:-Removing the references of below mentioned profiles (all financilforce profiles except "FinancialFprce AR Operations")
        *    from the all validation rule on opportunity as well as from the code (for opportunity validation).
        *    Since these profiles are now having the read only object access for the opportunity object.
    	*    Profiles:- "[financialforce accountant - restricted, financialforce ap operations - restricted
        *                 financialforce controller - restricted, financialforce read only - restricted]"
        */
    	//Code for Validation Rule - 'Only_Finance_Ops_can_close_an_Opp' and 'Only_Finance_Ops_can_edit'
        //Set to hold Validation related Profile names
        Set<String> setRecordLevelEditableProfiles = new Set<String>(); 
        String ProfileName = System.Label.Record_Level_Editable_Profiles;

        for(String ps : ProfileName.split(',')) {
            if(String.isNotBlank(ps)){
                ps = ps.trim();
                setRecordLevelEditableProfiles.add(ps);
            }
        }
        //Modified by - Mahendra Swarnakar - 1/2/2017 - CR-20161227-10568 - Ends here
        
        //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Initiating, HC Continuing,Core_AM_First_Year_Opp,Core_AM_Standard_Opp From Opportunity.
        //Set to hold Validation related Opportunity Record Type names
        //Subhash Garhwal - 05/01/2017 - CR-20170403-10807 - Added new Initiating and Continuing Record types (HC/EAB Initiating & HB/EAB Continuing)
        Set<String> setRecordLevelEditableRecordTypes = new Set<String> {/*'Core_AM_First_Year_Opp', 'Core_AM_Standard_Opp',*/ 'BI_Contract_Maintenance', 'BI_Contract_Renewal', 'EAB_Continuing', 'EAB_Initiating'/*, 'HC_Continuing', 'HC_Initiating'*/};
        Set<Id> setCoreRecordTypes = new Set<Id>();

        for(String rTypeDevName : Util.sobjectRecordTypeId('Opportunity').keyset()) {
            if(setRecordLevelEditableRecordTypes.contains(rTypeDevName)){
              setCoreRecordTypes.add(Util.sobjectRecordTypeId('Opportunity').get(rTypeDevName));
            }
        }
        /*Added by Subhash Garhwal - 07/25/2018 - CR-20180720-12454 Start here*/
        //VH 6/28/17 - Issue--CR10810--QA--00004794
        //bypass validation on closed opportunities for users with CPQ Admin custom permission
        //VH 09/06/2019 - CR-20190906-13321 - Victor Hanson - added customPermissions cache to reduced SOQL
        boolean isCPQAdmin;
        
        //Only get the value from the seeion when it is not from the asyncronus jobs since the Cache.Session is supported in these kind of jobs 
        if(!Test.isRunningTest() && !(System.isQueueable() || System.isBatch() || System.isFuture() || System.isScheduled())
            && UserInfo.getSessionId() != null && Cache.Session.contains('local.Default.isCPQAdmin')) {
                
                isCPQAdmin = (boolean)Cache.Session.get('local.Default.isCPQAdmin');
        }
            
        //if the value hasn't been cached, get it and place it in the session cache
        if (isCPQAdmin == null) {

            isCPQAdmin = FeatureManagement.checkPermission('CPQ_Admin_ABC');
            
            //Only set the value in the seeion when it is not from the asyncronus jobs since the Cache.Session is supported in these kind of jobs 
            if(!Test.isRunningTest() && !(System.isQueueable() || System.isBatch() || System.isFuture() || System.isScheduled()) && UserInfo.getSessionId() != null ){
                //set to expire after 8 hours (28,800  seconds)
                Cache.Session.put('local.Default.isCPQAdmin', isCPQAdmin, 28800 );
             }
        }
        
    
    	//JRB 2014-04-17  Hypercare fix.  The original coded logic displayed the wrong error message for users in profiles that could edit fields after Opp Close
        //Check if user is in a profile that allows an Opp to be Closed IngnoreCase
        Boolean isFinanceOpsUser = setRecordLevelEditableProfiles.contains(currentUserProfileName);
        
        //Subhash Garhwal - 6/25/2017
        List<PermissionSetAssignment> cPQBookingPS = [Select PermissionSetId From PermissionSetAssignment Where AssigneeId =: UserInfo.getUserId() AND PermissionSet.Name = 'CPQ_Opp_Booking' LIMIT 1];
        
        //Loop through all Opps being updated
        for(Opportunity opp : newOpportunities){
            
            if(!isFinanceOpsUser){
                
                Boolean fieldChangeNotAllowed;
                //check if the StageName field changed, which would indicate the opp might be being closed.  Also check other specific criteria.
                if(opp.StageName != mapOldOpportunities.get(opp.Id).StageName){
                  
                    //check that previous value of StageName was not set to a Closed value
                    //Subhash Garhwal - Uncomment Closed Won, DROPPED and Void Opportunity condition - Issue--CR10808--QA--00004956
                    if(mapOldOpportunities.get(opp.Id).StageName != Constants.CLOSED_WON   
                        && mapOldOpportunities.get(opp.Id).StageName != Constants.STAGE_OPPORTUNITY_DROPPED
                        && mapOldOpportunities.get(opp.Id).StageName != Constants.HONORARY
                        //&& mapOldOpportunities.get(opp.Id).StageName != Constants.STAGE_OPPORTUNITY_SENT_TO_FINANCE_OPP_REJECTED
                        && mapOldOpportunities.get(opp.Id).StageName != Constants.STAGE_OPPORTUNITY_VOID
                        && mapOldOpportunities.get(opp.Id).StageName != Constants.STATUS_ATL
                        && mapOldOpportunities.get(opp.Id).StageName != Constants.CLOSED
                       ) {
                            
                            //check if new value of StageName is being set to a Closed value
                            //Subhash Garhwal - Uncomment Closed Won, DROPPED and Void Opportunity condition - Issue--CR10808--QA--00004956
                            if(opp.StageName == Constants.CLOSED_WON
                               || opp.StageName == Constants.STAGE_OPPORTUNITY_DROPPED
                               || opp.StageName == Constants.HONORARY
                                //|| opp.StageName == Constants.STAGE_OPPORTUNITY_SENT_TO_FINANCE_OPP_REJECTED
                                || opp.StageName == Constants.STAGE_OPPORTUNITY_VOID
                                || opp.StageName == Constants.STATUS_ATL
                                || opp.StageName == Constants.CLOSED
                               ) {
                                   //Modified By Mahendra Swarnkar - 10/07/2016 - CR-20160825-10152 - added only a check in the If condition to bypass validation for Royall opportunity recordType.
                                   //These conditions indicate the Opp is going from an Open status to a Closed status.
                                   if(opp.Trigger_Update__c == mapOldOpportunities.get(opp.Id).Trigger_Update__c 
                                        && ((!setCoreRecordTypes.contains(opp.RecordTypeId))
                                            || (setCoreRecordTypes.contains(opp.RecordTypeId) 
                                                && opp.Editable_by_Finance_Ops_Only__c == false))
                                        && opp.RecordTypeId != OPPORTUNITY_ROYALL_RT_ID
                                     ) {
                                          
                                        //Generate error since user is not a Finance Ops user
                                        throw new CustomException(Label.ERROR_ONLY_FINANCE_OPS_CAN_CLOSE_AN_OPP); 
                                     }
                               }
                           }
                } else
                    
                    //StageName did not changed.  Check if Opp is currently in a Closed status & user is not a CPQ Admin
                    if(!isCPQAdmin
                       && (opp.StageName == Constants.CLOSED_WON 
                           || opp.StageName == Constants.STAGE_OPPORTUNITY_DROPPED
                           || opp.StageName == Constants.HONORARY
                           || opp.StageName == Constants.STAGE_OPPORTUNITY_VOID
                           || opp.StageName == Constants.STATUS_ATL
                           || opp.StageName == Constants.CLOSED)
                      ) {
                          fieldChangeNotAllowed = false;
                          
                          //Populate map with all Opportunity fields
                          Map<String, Schema.SObjectField> mapObjectFields = Schema.SobjectType.Opportunity.fields.getMap();
                          
                          //Loop through all field values      
                          for(String fieldName : mapObjectFields.KeySet()) {
                              
                              fieldName = fieldName.toLowerCase();
                              
                              //Check if field value is updated or not
                              if((opp.get(fieldName) != null 
                                  && mapOldOpportunities.get(opp.Id).get(fieldName) != null 
                                  && String.valueOf(opp.get(fieldName)).trim() != String.valueOf(mapOldOpportunities.get(opp.Id).get(fieldName)).trim())
                                 || opp.get(fieldName) != mapOldOpportunities.get(opp.Id).get(fieldName)
                                ) {
                                    
                                    //Check if the field is allowed for Editing 
                                    if(!fieldsAllowedForEdit.contains(fieldName)) { 
                                        
                                        //Check CPQ Booking PS
                                        //set flag for error message to generate
                                        if(cPQBookingPS.size() == 0 || !fieldName.equalsIgnoreCase('OwnerId'))
                                            fieldChangeNotAllowed = true;
                                        
                                        //Generate the error message
                                        //throw new CustomException(Label.ERROR_CLOSED_OPP_INVALID_PROFILE); 
                                    }
                                }
                          }
                      }
                
                //check if the error should be generated
                if(fieldChangeNotAllowed == true){                    
                    throw new CustomException(Label.ERROR_CLOSED_OPP_INVALID_PROFILE);
                }
            }
        
        }
    }
    
    //Modified By - Abhinav Sharma - 05/19/2016 - CR-20160308-9682
    /**
     *  @description    :   A custom validation rule should not allow saving under the following conditions:
     *                      StageName = ‘Contract Received – Send to Finance’
     *                      AND
     *                      (Main_Contact__c == null) OR (there is no “LOA” Contract Document record connected to this Opp through the Contract_Docs_to_Opps_MtM__c intersection object)
     *      
     *                      An LOA Contract Document is one that has Type__c in this list:
     *                          Letter of Agreement (Standard Terms)
     *                          Letter of Agreement (W/O Standard Terms)
     *                          Engagement Agreement
     *      
     *                      Opportunity record field updates:
     *                      Name
     *                      If NBB
     *                        [Account Name] - [Program Acronym] - [Year of Close Date] NBB
     *                      If Renewal (else)
     *                        [Account Name] - [Program Acronym] - [Pool Year] Renewal
     *                      Membership__c = Membership with same Program__c and same Account_Name__c as Opportunity
     *                      Main_Contact__c = First Opportunity Contact Role where IsPrimary = True
     *                      REMOVED 2013-12-16 CR-20130912-3630 - Owner_Name__c = Name from User that's the Owner of the Opp - 
     *      
     *                      Attached Membership record (through Opp.Membership__c) field updates
     *                      Most_Recent_Opportunity_Close_Date__c: Of all attached Opps, the latest CloseDate
     *                      Most_Recent_Lost_Opportunity_Close_Date__c: Of all Lost attached Opps (StageName in ( 'Dropped', 'Closed Lost', 'Void', 'Sent to Finance - Request Drop') ), the latest CloseDate
     *                      Opportunity_in_Outreach__c: If any attached NBB Opps have StageName in  { 'Outreach', 'Prospect' }, this is 'Yes'
     *                      Opportunity_in_Prospect__c: If any attached NBB Opps have StageName in { 'Sent to Finance', 'Verbal Yes', 'Active in SlowTrack', 'Active in FastTrack', 'Prewire', 'Initial Visit Scheduled' }, this is 'Yes'
     *
     *  @args           :   List of opportunities
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.0 - Created - Angela Williams (SAP)) - 11/2011
     *                      V1.1 - Modified By - JN Edited Trigger for clarity and performance. Added this header and verified test coverage. JN 1/24/2011
     *                      V1.2 - Modified By - NB-2011-02-09) - Added line 22 in the header Purpose for informational purposes.
     *                                                            Added Purpose: "Main_Contact__c = First Opportunity Contact Role where IsPrimary = True"
     *                      V1.3 - Modified By - JN 2/15/2011 - Added condition to not trigger if Util.IsTrigger_NBBOppFields
     *                                                        - Fixed naming convention to run on every save
     *                                                        - Fixed Main Contact and Chairman's Team Rep to default to null unless there is a contact role / OpportunityTeamMember
     *                      V1.4 - Modified By - Bhavi - 02/01/2013 - Modified UpdateRelationshipGradeNotes method to execute only when required - CR-20130131-2377
     *                      V1.5 - Modified By - Bhavi - 03/23/2013) - CR-20130301-2625
     *                      V1.6 - Modified By - Bhavi - 05/02/2013) - CR-20121226-1993
     *                      V1.7 - Modified By - Bhavi - 10/22/2013) - CR-20130625-3205
     *                      V1.8 - Modified By - Jason - 12/16/2013) - CR-20130912-3630 - Removed update to Owner_Name__c field
     *                      V1.9 - Modified By - Ajit Surana - 03/13/2014) - CR-20140205-4458
     *                      V2.0 - Modified By - Subhash Garhwal - 06/16/2016 - CR-20160414-9762
     *                      V2.1 - Modified By - Subhash Garhwal - 04/14/2017 - Add additional contitional for opportunity new record type (HC Initiating, EAB Initiating, HC Continuing & EAB Continuing) naming convenation
     *                      V2.2 - Modified By - Victor Hanson - 05/15/2017 - CR-20170403-10807 - Method is updated to correct auto populate Name field for "Merged" record type
     *            	    V2.3 - Modified By - Abhinav Sharma - 03/28/2018 - CR-20171103-11765 - To remove the Null from the opportunity name 
     *         		    V2.4 - Modified By - Victor hanson - 08/21/2018 - CR-20180821-12512 - removed references to prospectStages & outreachStages that are being retired
     *          	    V2.5 - Modified By - Subhash Gharwal -04-29-2019 - Spring cleanup - CR-20190425-13035  
     *                      V2.6 - Modified By - Nikita Kumari - 08/10/2021 - CR-20210806-15336 - Updated Opportunity name formula  for Legacy Acquisition record type.
     * 			    V2.7 - Modified By - Nikita Kumari - 10/13/2021 -CR-20211008-15505 - Updated method opportunityValidationAndFieldUpdated - added RT check for Legacy capex and Legacy Acquisition to by pass error.
     *                      V2.8 - Modified By - chirag soni - 11/16/2021 - CR-20211112-15582  - Updated method - legacy cappex record type is deactivated and migrated to legacy Acquisition
     **/
    public static void opportunityValidationAndFieldUpdated(List<Opportunity> lstOpportunities, Map<Id, Opportunity> mapNewOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        // NB20110114 - Added condition to prevent duplicate execution
        try {
                
            Map<String, Id> rtmap = Util.recordtypemap('Opportunity');
            String NBBRecordTypeId1 = rtmap.get('RI Marketing');
            String NBBRecordTypeId2 = rtmap.get('PT Marketing');
            
            //Modified By - Nikita Kumari - 08/10/2021 - CR-20210806-15336 - created new variable
            Id OppLegacyAcquisition_RT_Id = rtmap.get('Legacy Acquisition');
             
            //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Consulting & Management, Program – PT Marketing,PROGRAM_RI_MARKETING From Opportunity.
            //Add All the NBB record types in set
            Set<id> NBBRecordtypeIDs = new set<id>{ NBBRecordTypeId1, NBBRecordTypeId2/*, NBBRecordTypeId3, NBBRecordTypeId4,NBBRecordTypeId5*/}; 
                
            Set<String> closedlostStages = new Set<String>{ 'Dropped', 'Closed Lost', 'Void', 'Sent to Finance - Request Drop'};
        
            List<Id> oppIdList = new List<Id>();
            set<id> valruleids = new set<id>();
            set<id> ownerids = new set<id>();
            set<id> idsForContractStrategyOutcome = new set<id>();
                
            //Added by Colin McGloin - 06/28/2016 - CR-20160414-9762
            Set <String> programOppIds = new Set <String>();
            
            //Added by Subhash Garhwal - 06/30/2016 - CR-20160414-9762
            Set<String> setRenewalAndMaintenanceRTIds = new Set<String>();
            
            Set<Id> setContinuingRecordTypes = new Set<Id>();
	    // Modified By - Abhinav Sharma - CR-20201102-14656 - 11/6/2020
            //Modified by - Chirag Soni - CR-20211112-15582 - 11/18/2021 - Commented Cappex Record type is deactivated
            //Set<Id> setLegacyCappexRecordTypes = new Set<Id>();
            
            //Add Continuing record types
            //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Continuing From Opportunity.
            //setContinuingRecordTypes.add(rtmap.get(CPQConstants.OPP_RECORD_TYPE_NAME_HC_CONTINUING));
            setContinuingRecordTypes.add(rtmap.get(CPQConstants.OPP_RECORD_TYPE_NAME_EAB_CONTINUING));
            // Modified By - Abhinav Sharma - CR-20201102-14656 - 11/6/2020
            //Modified by  -  chirag soni - CR-20211112-15582 - 11/16/2021 - Commented Cappex Record type is deactivated
            //setLegacyCappexRecordTypes.add(rtmap.get('Legacy Cappex')); 
            
            //Loop through opportunity records
            for(Opportunity opp: lstOpportunities) {
                    
                oppIdList.add(opp.Id);
                ownerids.add(opp.OwnerID);
        
                //Requirements to run Validation on this opp: complicated.
                if( //Must be one of these: (RI Marketing OR PT Marketing) Recordtype OR Decision Type == 'Need New LOA'
                    ((NBBRecordtypeIDs.contains(opp.RecordtypeID)) || (opp.Decision_Type__c == 'Need New LOA'))
                    &&
                    //Either new record or Stage was just changed
                    ((Trigger.IsInsert) || ((Trigger.IsUpdate) && (opp.StageName != mapOldOpportunities.get(opp.id).StageName)))
                    &&
                    //Stage is 'Contract Received - Send to Finance'. This is split up because the '-' in the middle is actually a 'long dash' rather than a hyphen.
                    ((opp.StageName.startswith('Contract Received ')) && (opp.StageName.endswith(' Send to Finance'))))
                    {
                        valruleids.add(opp.Id);
                    } 
            }
                    
            //Only run validation if one of the Opps might be affected
            if (valruleids.size() > 0 ) {
                
                List<Contract_Docs_to_Opps_MtM__c> listContracts = [select Id, Opportunity__c, Contract_Documents__r.Type__c
                                                                    from Contract_Docs_to_Opps_MtM__c
                                                                    where Opportunity__c != null AND Opportunity__c IN: valruleids 
                                                                    And
                                                                    Contract_Documents__r.Type__c IN ('Letter of Agreement (Standard Terms)','Letter of Agreement (W/O Standard Terms)','Engagement Agreement')];
                
                Map<Id, boolean> oppContractMap = new Map<Id, boolean>();
    
                //Loop through contract docs
                for(Contract_Docs_to_Opps_MtM__c obj: listContracts)
                {
                    oppContractMap.put(obj.Opportunity__c, true);
                }
    
                //Code added - Bhavi Sharma - 10/22/2013 - CR-20130625-3205
                //Loop through Trigger.new
                for(Opportunity opp: lstOpportunities) {
                    
                    if(opp.StageName.startswith('Contract Received ') 
                        && opp.StageName.endswith(' Send to Finance') 
                        && (opp.Main_Contact__c == null || oppContractMap.get(opp.Id) == null)
                        
                    ) {
                        
                        //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Initiating, RI AM Standard Opp From Opportunity.
                        //Check if opportunity is related to specific record types
                        //Modified By - Nikita Kumari - 10/13/2021 - CR-20211008-15505 - added RT check for Legacy capex and Legacy Acquisition to by pass error.
                        //Modified by - Chirag Soni - CR-20211112-15582 - 11/18/2021 - Commented setLegacyCappexRecordTypes - Cappex Record type is deactivated - From Here
                        if((opp.Contract_Strategy_Outcome__c == null || opp.Contract_Strategy_Outcome__c == '') /*&& !setLegacyCappexRecordTypes.contains(opp.RecordTypeId)*/
                           && OppLegacyAcquisition_RT_Id != opp.RecordTypeId /*&& (opp.RecordTypeId == riAMFirstYrRTID || opp.RecordTypeId == riAMStandardRTID)*/)
                        {
                            opp.addError('The Stage you have selected requires an LOA, Main Contact and Contract Strategy Outcome');
                        }
                        else if (/*!setInitiatingRecordTypes.contains(opp.RecordTypeId) &&*/ !setContinuingRecordTypes.contains(opp.RecordTypeId) /*&& 
                                 !setLegacyCappexRecordTypes.contains(opp.RecordTypeId) */&& 
                                 OppLegacyAcquisition_RT_Id != opp.RecordTypeId)
                        {
                            opp.addError('The Stage you have selected requires an LOA and a Main Contact'); 
                        }
                        //Modified by - Chirag Soni - CR-20211112-15582 - 11/18/2021 - Commented setLegacyCappexRecordTypes - Cappex Record type is deactivated - Till Here
                    }
                }
            }
            /* End */
    
                   
            set<Id> newnameaccids = new set<Id>();
            set<id> progids = new set<id>();
            set<id> accids = new set<id>();
            
            //Subhash Garhwal - 05/02/2017 - CR-20170403-10807 - Set to hold the Origination Program Id
            Set<Id> setOriginationProgramIds = new Set<Id>();  
            
            //Loop through opportunity records
            for(Opportunity opp: lstOpportunities) {
                
                Opportunity oldopp;
                if (Trigger.IsUpdate) oldopp = mapOldOpportunities.get(opp.id);
    
                if (opp.Program__c != null)
                    progids.add(opp.Program__c);
    
                if (opp.AccountID != null && !ContractTriggerHelper.mapAccounts.containsKey(opp.AccountID))
                    accids.add(opp.AccountID);
                    
            }
        
            String teamRole1 = 'RI - Chairman\'s Team';
            String teamRole2 = 'PT - Chairman\'s Team';
        
            /* Begin Opp Naming Convention */
            map<id, Program__c> progid2progmap = new map<id, Program__c>();
            
            //Subhash Garhwal - 05/02/2017 - CR-20170403-10807 - Map to hold the 
            Map<Id, Product2> mapProducts = new Map<Id, Product2>();
            
            //Checking set for size value
            if(accids.size() > 0)
                ContractTriggerHelper.mapAccounts.putAll([select id, Name, Account_Formal_Name__c from Account where id in :accids]);
                
            //Checking set for size value
            if(progids.size() > 0)
                progid2progmap = new map<id, Program__c>([select Program_Acronym__c, Program_Abbreviation__c from Program__c where id in :progids]);
        
            //Loop through opportunity records
            for(Opportunity opp: lstOpportunities) {
                
                //Modified by - Mahnedra Swarnkar - 8/11/2016 - CR-20160810-10101 - Merged the code From RoyallDev SB to Test SB for CR-10101. - Starts from here
                //VH 8/10/16: bypass opportunity auto-name logic for Royall opps.
                if (opp.RecordTypeId == OPPORTUNITY_ROYALL_RT_ID) continue;
                //Modified by - Mahnedra Swarnkar - 8/11/2016 - CR-20160810-10101 - Merged the code From RoyallDev SB to Test SB for CR-10101. - Ends here
                
                //Calculate Name
                Integer maxaccnamelength = 55;
                String nameSuffix = '';
                String acronym = ' - - ';
    
                //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Initiating From Opportunity.
                //Checking program for null value
                //Subhash Garhwal - 04/14/2017 - Added additional condition to bypass the logic for new record types HC Initiating, EAB Initiating, HC Continuing and EAB Continuing
                if(/*!setInitiatingRecordTypes.contains(opp.RecordTypeId) &&*/ !setContinuingRecordTypes.contains(opp.RecordTypeId)
                    && opp.Program__c != null) {
                    if(progid2progmap.containsKey(opp.Program__c) && progid2progmap.get(opp.Program__c) != null
                    && progid2progmap.get(opp.Program__c).Program_Acronym__c != null)
                    acronym = ' - ' + progid2progmap.get(opp.Program__c).Program_Acronym__c + ' - ';
                    
                    //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756
                    //Check for Opportunity Record types
                    if(programOppIds.contains(opp.RecordTypeId) /*|| setRenewalAndMaintenanceRTIds.contains(opp.RecordTypeId)*/) {
                        
                        //Check for Program
                        if(progid2progmap.containsKey(opp.Program__c) && progid2progmap.get(opp.Program__c) != null
                            && progid2progmap.get(opp.Program__c).Program_Abbreviation__c != null)
                            acronym = ' - ' + progid2progmap.get(opp.Program__c).Program_Abbreviation__c + ' - ';    
                    }
                }
    
                String accname = ' ';
                
               //Modified By - Nikita Kumari - 08/10/2021 - CR-20210806-15336 - retrive account formal name if account id is not null and RT is Legacy Acquisition
                if(opp.AccountId != null && opp.RecordTypeId == OppLegacyAcquisition_RT_Id)
                    accname = ContractTriggerHelper.mapAccounts.get(opp.AccountId).Account_Formal_Name__c;
                //Checking account Id for null value
                else if (opp.AccountId != null)
                    accname = ContractTriggerHelper.mapAccounts.get(opp.AccountId).Name; 
                
                Integer maxnamelength = Opportunity.Name.getDescribe().getLength();
                
                //Modified By Abhinav Sharma - 03/28/2018 - CR-20171103-11765 - To remove the Null from the opportunity name 
                String yearsuffix = '';
                String monthsuffix;
    
                //Determine NBB or Renewal and construct last part of oppname
                if (NBBRecordtypeIDs.contains(opp.RecordtypeID)) {
                    
                    if(opp.CloseDate != null)
                        nameSuffix = opp.CloseDate.year() + ' ';
                        
                    nameSuffix += 'NBB';
                
                //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Initiating From Opportunity.
                //Subhash Garhwal - 04/14/2017 - Added code block for Initiating record type
                } 
                //Subhash Garhwal - 04/14/2017 - Added code block for Continuing record type
                else if(setContinuingRecordTypes.contains(opp.RecordTypeId)) {
                    
                    //Add namesuffix
                    nameSuffix += CPQConstants.OPP_CONTINUING_RECORD_TYPE_SUFFIX;
                }
                else if (opp.RecordTypeId == CPQConstants.OPP_RT_ID_MERGED) {
                    
                    //Add namesuffix
                    nameSuffix += CPQConstants.OPP_MERGED_RECORD_TYPE_SUFFIX;
                }
                
                //Modified By - Nikita Kumari - 08/10/2021 - CR-20210806-15336 - added condition for Legacy Acquisition RT
                else if (opp.RecordTypeId == OppLegacyAcquisition_RT_Id){
                    acronym = ' - ';
                    nameSuffix = opp.Source_Business__c+' - '+opp.Opp_Type_CX__c;
                    yearsuffix = String.valueOf(opp.CloseDate.year());
                }
                
                else {
                    
                    if (opp.Pool_Year__c != null)
                        nameSuffix = opp.Pool_Year__c;
                    
                  nameSuffix += ' Renewal';
                }
                
                //see how much of the account name we can use
                Integer maxaccountnamelength = 55;
    
                //truncate account name if necessary
                accname = accname.substring(0,Math.min(accname.length(), maxaccountnamelength));
                
                //Update month siffix for new Record Types (CPQ)
                if(opp.CloseDate != null)
                    monthsuffix = String.valueOf(opp.CloseDate.month()).length() == 1 ? '0' + String.valueOf(opp.CloseDate.month()) : String.valueOf(opp.CloseDate.month());
                
                //Update Naming for Program Opp records
                if(programOppIds.contains(opp.RecordTypeId)){
                    if(opp.SBQQ__Renewal__c == True){
                        nameSuffix = monthsuffix + '-' + yearsuffix;  
                    }
                    else {
                        nameSuffix = yearsuffix + ' ' + 'NBB';
                    }
                } 
                //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756
                /*else if(setRenewalAndMaintenanceRTIds.contains(opp.RecordTypeId)) {
                    //Check for Renewal Opp
                    if(opp.SBQQ__Renewal__c)
                        nameSuffix = monthsuffix + '-' + yearsuffix;
                    else
                        nameSuffix = yearsuffix + ' ' + 'Renewal';
                }*/
                
                //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Initiating From Opportunity.
                //Subhash Garhwal - 04/14/2017 - Continuing and Initiating record type
                if(/*setInitiatingRecordTypes.contains(opp.RecordTypeId) ||*/ setContinuingRecordTypes.contains(opp.RecordTypeId)){
                    acronym = ' - ';
                    //Add in Year Suffix population
                    yearsuffix = String.valueOf(opp.CloseDate.year());
                }
                
                Integer acronymlength;
		// Modified By - Abhinav Sharma - CR-20201102-14656 - 11/6/2020
                //Modified by - Chirag Soni - CR-20211112-15582 - 11/18/2021 - Commented setLegacyCappexRecordTypes and If condition  - Cappex Record type is deactivated - From Here
                //if(!setLegacyCappexRecordTypes.contains(opp.RecordTypeId)){
                    //build final name
                    //Modified by Colin McGloin - for Issue--CR10808--QA--00004979
                    //Scenario 1 - Q2C Records (Initiating, Continuing)
                    if (String.isNotEmpty(yearsuffix)){
                        //Get length of Opportunity Name to get Account name
                        acronymlength = 79 - (acronym + nameSuffix + ' - ' + yearsuffix).length();
                        opp.Name = accname.left(acronymlength) + acronym + nameSuffix + ' - ' + yearsuffix;
                    } 
                    //Scenario 2 - Non Q2C Records
                    else {
                        //Get length of Opportunity Name to get Account name
                        acronymlength = 79 - (acronym + nameSuffix).length();
                        opp.Name = accname.left(acronymlength) + acronym + nameSuffix;
                    }
                //}
               //Modified by - Chirag Soni - CR-20211112-15582 - 11/18/2021 - Commented setLegacyCappexRecordTypes - Cappex Record type is deactivated - Till Here
               
                 if(Trigger.isInsert || Trigger.isUpdate){
                    // Modified by - Rajeev Jain - CR-20181008-12649 
                    createInitiatingOpportunityName(lstOpportunities,mapOldOpportunities);
                    
                }//End of Contract LOA naming
                
            } //end for opp in Trigger.new
            /* End Naming Convention*/
    
            if (Trigger.IsUpdate) {
                
                map<Id, Opportunity> oppid2oppmap = new map<id, Opportunity>();
                
                //Checking for size value
                if(mapNewOpportunities.keyset().size() > 0) {
                    
                    oppid2oppmap = new map<id, Opportunity>([select id, AccountID, Account.Name,
                                                             Membership__c, Membership__r.Program__c, Membership__r.Account_Name__c, Program__c, Program__r.Program_Acronym__c, Recordtype.Name, CloseDate,
                                                             (select TeamMemberRole, UserId from OpportunityTeamMembers where TeamMemberRole =: teamRole1 or TeamMemberRole =: teamRole2),
                                                             (select ContactId, Role from OpportunityContactRoles where IsPrimary = true)
                                                             from Opportunity where id in : mapNewOpportunities.keyset()]);
                }
                
                //Get whole list of Memberships based on matching Account and/or Program (Can't do it if we don't have a Program and an Account)
                list<Membership__c> membersList0 = new list<Membership__c>();
    
                //Checking for size value
                if ((progids.size() >0) && (accids.size() > 0)) {
                    
                    membersList0 = [SELECT id, Account_Name__c, Program__c FROM Membership__c
                        WHERE Account_Name__c != null AND Program__c != null 
                        AND Program__c in :progids and Account_Name__c in :accids];
                }
    
                //Loop through opportunity records
                for(Opportunity opp: lstOpportunities) {
                    
                    //Checking for value in map
                    if(oppid2oppmap.containsKey(opp.id) && oppid2oppmap.get(opp.id) != null) {
                    
                        Opportunity queriedOpp = oppid2oppmap.get(opp.id);
        
                        //Chairmans Team Rep defaults to null unless this is an insert or there's an otm for it.
                        if (Trigger.IsUpdate) opp.Chairman_s_Team_Rep__c = null;
                        if (queriedOpp.OpportunityTeamMembers.size() > 0)
                            opp.Chairman_s_Team_Rep__c = queriedOpp.OpportunityTeamMembers[0].UserID;
        
                        //Assign Membership__c if necessary
                        if ((opp.Program__c != null) && (opp.AccountId !=null)
                            && ((opp.Membership__c == null)
                            || ((queriedOpp.Membership__r.Program__c != opp.Program__c) || (queriedOpp.Membership__r.Account_Name__c != opp.AccountID))))
                        {
                            for(Membership__c mem: membersList0)
                            {
                                if((mem.Account_Name__c == opp.AccountId) && (mem.Program__c == opp.Program__c)) {
                                    opp.Membership__c = mem.Id;
                                    break;
                                }
                            }
                        }
                    }        
                }
            }
            else if (Trigger.IsInsert) {
                    
                list<Membership__c> membersList0 = new List<Membership__c>();
                
                //Checking for size value
                if ((progids.size() >0) && (accids.size() > 0)) {
                    
                    //Query for membership records
                    membersList0 = [select id, Account_Name__c, Program__c from Membership__c
                                        where Program__c  != null AND Account_Name__c != null 
                                                            AND Program__c in :progids and Account_Name__c in :accids];
                }    

                //Map of opportunities
                map<id, Membership__c> membersmap = new map<id, Membership__c>();
                
                //Checking for size value
                if(membersList0.size() > 0)
                    membersmap = new map<id, Membership__c>(membersList0);
                
                //Loop through opportunity records
                for(Opportunity opp: lstOpportunities) {
    
                    //Assign Membership if necessary if (Has Program AND Has Account)
                    if ((opp.Program__c != null) && (opp.AccountId !=null)) {
                        
                        for(Membership__c mem: membersList0) {
                            
                            if((mem.Account_Name__c == opp.AccountId) && (mem.Program__c == opp.Program__c)) {
                                
                                opp.Membership__c = mem.Id;
                                break;
                            }
                        }
                    }//end if membership update needed
                }
            } //end if isUpdate, IsInsert
    
            /* Membership Field Updates
    
            Requirements:
            1. Membership
                a) Update Most Recent Lost Opportunity Close Date on Membership
                    1) On update with Stage changed to Closed Lost
                        a) Of all Closed Lost Opportunities on Membership, MAX(CloseDate)
    
                b) Most Recent Opportunity Close Date
                    (1) if this closedate is more recent than Membership's Most Recent close date
                        (a) Update Membership with most recent closedate
    
                c) Opportunity in Outreach
                    1) If Open NBB-Type Opportunity(see above) on Membership with Stage = "Outreach" OR "Prospect"
                        Yes
                    Else
                        No
    
                d) Opportunity in Prospect
                    (1) If Open NBB-Type Opportunity on Membership with Stage = "Active in Fast Track", "Active in Slow Track", "Verbal Yes", "Sent to Finance"
                        Yes
                    Else
                        No
    
                e) Owner
                    Same as Owner of Renewal Opp from Active Contract Identified
            */
        
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
            Map<id, list<Opportunity>> memid2opplistmap = new map<id, list<Opportunity>>();
            List<Id> membershipIdList = new List<Id>();
        
            //loop through opportunity record
            for(Opportunity opp: lstOpportunities) {
                
                membershipIdList.add(opp.Membership__c);
                
                if (opp.Membership__c != null)
                {
                    //get map of lists of inserted opps to compare to what's on the Membership already
                    if (memid2opplistmap.containsKey(opp.Membership__c))
                    {
                        memid2opplistmap.get(opp.Membership__c).add(opp);
                    }
                    else
                    {
                        memid2opplistmap.put(opp.Membership__c, new list<Opportunity>{ opp});
                    }
                }
            }
        
            Map<Id, Membership__c> memRecordsToUpdate = new Map<Id, Membership__c>();
            set<Id> triggeringids = new set<Id>();
        
            if (Trigger.IsUpdate)
                triggeringids = mapNewOpportunities.keyset();
        
            //List of memberships    
            List<Membership__c> membershipList = new  List<Membership__c>();
                
            //Checking for size value
            if(membershipIdList.size() > 0) {
                //Modified by Subhash Gharwal -04-29-2019 - Spring cleanup - CR-20190425-13035  
                //V_1.51 - Modified by - Saurabh Kumar - 06/05/2017 - CR-20170403-10808 (DS114) - Fields "Earliest_Subscription__c", "Active_Subscription__c", "Latest_Subscription__c" are added
                //Query membership with existing Opps (that aren't being updated)
                membershipList = [select Id, Most_Recent_Opportunity_Close_Date__c, Most_Recent_Lost_Opportunity_Close_Date__c,
                                    Opportunity_in_Outreach__c, Opportunity_in_Prospect__c, Active_Contract_Idenfied__c, Active_Subscription__c,
                                    Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__c,
                                    Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerID, /*Relationship_Grade_Notes__c,*/
                                    (select id, IsWon, IsClosed, StageName, CloseDate, Recordtype.Name from Opportunities__r
                                        where id not in :triggeringids)
                                    from Membership__c where ID IN: membershipIdList
                                    ];
            }     
        
            //Added by Bhavi - 02/01/2013 - CR-20130131-2377
            //Check if Trigger is before Update]
            if(Trigger.isBefore && Trigger.isUpdate) {
    
                //Create a map of Mameberships
                Map<Id, Membership__c> mapMembership = new Map<Id, Membership__c>(membershipList);
    
                //Check if there are records to process
                if(mapMembership.size() > 0) {
    
                    //Loop through the new Opportunities
                    for(Opportunity opp : lstOpportunities) {
    
                        //Check if Membership is not null on records
                        if(opp.Membership__c != null && mapMembership.containsKey(opp.Membership__c)) {
    
                        }
                    }
                }
            }
        
            //Loop through membership records
            for(Membership__c membr: membershipList) {
                
                //queried opps
                List<Opportunity> oppList0 = membr.Opportunities__r;
    
                //also go through inserted/updated opps
                if(memid2opplistmap.containsKey(membr.id)) 
                    oppList0.addall(memid2opplistmap.get(membr.id));
    
                Membership__c member0 = memRecordsToUpdate.get(membr.Id);
                
                if(member0 == null) 
                    member0 = new Membership__c(Id = membr.Id);
    
                member0.Opportunity_in_Prospect__c = 'No';
                member0.Opportunity_in_Outreach__c = 'No';
                
                //Loop through opportunity records
                for(Opportunity opp0: oppList0)
                {
                    //Most_Recent_Lost_Opportunity_Close_Date__c
                    if(closedlostStages.contains(opp0.StageName))
                    {
                        if(member0.Most_Recent_Lost_Opportunity_Close_Date__c == null ||  member0.Most_Recent_Lost_Opportunity_Close_Date__c < opp0.CloseDate)
                            member0.Most_Recent_Lost_Opportunity_Close_Date__c = opp0.CloseDate;
                    }
    
                    if(member0.Most_Recent_Opportunity_Close_Date__c == null || member0.Most_Recent_Opportunity_Close_Date__c < opp0.CloseDate)
                        member0.Most_Recent_Opportunity_Close_Date__c = opp0.CloseDate;
    
                } //end for opp0 : oppList0
                //Put this member in list to be updated.
                memRecordsToUpdate.put(membr.Id, member0);
            }
        
            //Update all membership records
            if(memRecordsToUpdate.values().size()>0) {
    
                //Do not fire memebrship method which updates opportunity
                MembershipTriggerHelper.EXECUTE_UPDATE_RELATIONSHIP_GRADE_NOTES = false;
                update memRecordsToUpdate.values();
            }
                
            //Setting flag value
            Util.IsTrigger_Opportunity_ValidationAndFieldUpdates = false;
        } catch (Exception e) {
            
            Trigger.New[0].addError(e.getMessage());
        }
    }
    
    /**
     *  @description    :   Opportunity Signed Contract
     * 
     *  @args           :   List on new and old opportunities
     * 
     *  @return         :   Void
     * 
     **/
    public static void opportunitySignedContract(List<Opportunity> lstNewOpportunities, List<Opportunity> lstOldOpportunities) {
        
        Map<String, Id> rtmap = Util.recordtypemap('Opportunity');
        String NBBRecordTypeId1 = rtmap.get('RI Marketing');
        String NBBRecordTypeId2 = rtmap.get('PT Marketing');
        
        /* 
        1. Contract : Signed Opportunity Contract
        If one of these fields changed: (RecordtypeID, Marketer__c, OwnerId)
            a) Negotiated By
                (1) If  Marketer, Owner on Opp changes
                    (a) If Opportunity NBB type
                        (i) Marketer on Opportunity
                    (b) If Renewal type
                        (i) Owner of Opp
        */
        
        List<Contract__c> contractsToUpdate = new List<Contract__c>();
        integer i=0;
        for(Opportunity opp: lstNewOpportunities){
            if(opp.Signed_Opportunity_Contract__c !=null){
                if(Trigger.isUpdate){
                    if( (lstOldOpportunities[i].RecordTypeId != lstNewOpportunities[i].RecordTypeId) || (lstOldOpportunities[i].Marketer__c != lstNewOpportunities[i].Marketer__c) || (lstOldOpportunities[i].OwnerId != lstNewOpportunities[i].OwnerId)) {     
                        If ((opp.RecordTypeId == NBBRecordTypeId1 || opp.RecordTypeId == NBBRecordTypeId2) && opp.Signed_Opportunity_Contract__c != null) { //NBB type
                            Contract__c cnt = new Contract__c(Id = opp.Signed_Opportunity_Contract__c);
                            cnt.Negotiated_By__c = opp.Marketer__c;
                            contractsToUpdate.add(cnt);
                        }else{
                            Contract__c cnt = new Contract__c(Id = opp.Signed_Opportunity_Contract__c);
                            cnt.Negotiated_By__c = opp.OwnerId;
                            contractsToUpdate.add(cnt);
                        }
                    }
                }else{
                    If ((opp.RecordTypeId == NBBRecordTypeId1 || opp.RecordTypeId == NBBRecordTypeId2) && opp.Signed_Opportunity_Contract__c != null) { //NBB type
                        Contract__c cnt = new Contract__c(Id = opp.Signed_Opportunity_Contract__c);
                        cnt.Negotiated_By__c = opp.Marketer__c;
                        contractsToUpdate.add(cnt);
                    }else{
                        Contract__c cnt = new Contract__c(Id = opp.Signed_Opportunity_Contract__c);
                        cnt.Negotiated_By__c = opp.OwnerId;
                        contractsToUpdate.add(cnt);
                    }
                }
            }
            i++;
        }
        
        if(contractsToUpdate.size()>0){
            // CR-2879 bypass all triggers when updating the Negotiated_By__c field on Contracts associated with this opp
            Util.BypassAllTriggers = true;
            update contractsToUpdate;
            Util.BypassAllTriggers = false;
        }
    }
    
    /**
     *  @description    :   Update role on Sales Team
     *
     *  @args           :   Map of new and Old opporutnities
     *
     *  @return         :   void
     * 
     *  @Version        :   V_1.1 - Modified By Dipesh Gupta - 11/03/2017 - CR-20171101-11753
     *
     **/
    public static void updateSalesTeamRole(Map<Id, Opportunity> mapNewOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        /* 
        Requirements - 
        Sales Teams
            a) Leadership Team Owner
                (1) If changed on Opportunity field, replace that Role in Sales Team
            b) Marketer
                (1) If changed on Opportunity field, replace that Role in Sales Team
            c) Marketing Associate
                (1) If changed on Opportunity field, replace that Role in Sales Team
        
        */
        
        Map<String, Id> rtmap = Util.recordtypemap('Opportunity');
        String NBBRecordTypeId1 = rtmap.get('RI Marketing');
        String NBBRecordTypeId2 = rtmap.get('PT Marketing');

        String thisrole;
        map<id, String> backmap = new map<id, String>();
        for (String rtname : rtmap.keyset()) {
            backmap.put(rtmap.get(rtname), rtname);
        }
        
        List<OpportunityTeamMember> otmsToInsert = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> otmsToDelete = new List<OpportunityTeamMember>();
        
        // Modified by Dipesh Gupta - CR-20171101-11753 - Added Entity, UserId, User.Entity__c, User.IsActive, User.UserType,  from the Query.
        map<id, Opportunity> oppmap = new map<id, Opportunity>([select id, RecordtypeId, Owner.IsActive, Marketer__c, Marketer__r.IsActive, 
                                                                Marketer__r.UserType, Marketer__r.Entity__c,
                                      Marketing_Associate__c, Marketing_Associate__r.IsActive, 
                                                                Marketing_Associate__r.UserType, 
                                                                Marketing_Associate__r.Entity__c, /*Leadership_Team_Owner__c, 
                                                                Leadership_Team_Owner__r.IsActive, /*Leadership_Team_Owner__r.Entity__c, 
                                                                Leadership_Team_Owner__r.UserType,*/  Entity__c,
            (select Id, UserId, User.Entity__c, User.IsActive, User.UserType, OpportunityId, TeamMemberRole from OpportunityTeamMembers) from Opportunity where id in : mapNewOpportunities.keyset()]);
        
        for (Id oppid : oppmap.keyset()) {
            Opportunity opp = oppmap.get(oppid);
            Opportunity oldopp = (Trigger.isUpdate) ? mapOldOpportunities.get(oppid) : null;
            
            //Can't make changes to an Opp with an inactive Owner
            if (opp.Owner.IsActive) {
                //Marketer
                if ((opp.Marketer__c != null) && (opp.Marketer__r.IsActive)
                    && ((Trigger.IsInsert) || (opp.Marketer__c != oldopp.Marketer__c))) {
                    thisrole = 'PT - Marketer';
                    //Code merged by - Saurabh Kumar - 11/09/2016 - CPQ Overlapping mod from FFDC1 to test sandbox
                    if (String.isNotBlank(backmap.get(opp.RecordtypeId)) && (backmap.get(opp.RecordtypeId).startswith('RI')
                        || backmap.get(opp.RecordtypeId).startswith('Program – RI')))
                        thisrole = 'RI - Marketer';
                
                    for (OpportunityTeamMember otm : oppmap.get(opp.id).OpportunityTeamMembers) {
                        if (otm.TeamMemberRole == thisrole || otm.User.Entity__c != oppmap.get(opp.id).Entity__c || 
                            otm.User.IsActive != true || otm.User.UserType != 'Standard') {
                            otmstodelete.add(otm);
                        }
                    }    
                    //Modified By Dipesh Gupta - 11/03/2017 - CR-20171101-11753 - Updated the manual sharing condition based on the Entity field of user and opportunity and user should be Active and user type should be standard.
                    //Check for the Entity, IsActive, and UserType of Team Member user.
                    if(opp.Marketer__r.Entity__c == oppmap.get(opp.id).Entity__c && opp.Marketer__r.IsActive == true 
                       && opp.Marketer__r.UserType == 'Standard') {
                            
                       otmsToInsert.add(new OpportunityTeamMember(
                          OpportunityId = opp.Id, 
                            UserId=opp.Marketer__c, 
                            TeamMemberRole = thisrole ));
                    }    
                    
                }
                //Marketing Associate
                if ((opp.Marketing_Associate__c != null) && (opp.Marketing_Associate__r.IsActive)
                    && ((Trigger.IsInsert) || (opp.Marketing_Associate__c != oldopp.Marketing_Associate__c))) {
                    thisrole = 'PT - Marketing Associate';
                    //Code merged by - Saurabh Kumar - 11/09/2016 - CPQ Overlapping mod from FFDC1 to test sandbox
                    if (String.isNotBlank(backmap.get(opp.RecordtypeId)) && (backmap.get(opp.RecordtypeId).startswith('RI')
                        || backmap.get(opp.RecordtypeId).startswith('Program – RI')))
                        thisrole = 'RI - Marketing Associate';
                        
                    for (OpportunityTeamMember otm : oppmap.get(opp.id).OpportunityTeamMembers) {
                        if (otm.TeamMemberRole == thisrole || otm.User.Entity__c != oppmap.get(opp.id).Entity__c || otm.User.IsActive != true || otm.User.UserType != 'Standard') 
                            otmstodelete.add(otm);
                    }    
                    //Modified By Dipesh Gupta - 11/03/2017 - CR-20171101-11753 - Updated the manual sharing condition based on the Entity field of user and opportunity and user should be Active and user type should be standard.
                    //Check for the Entity, IsActive, and UserType of Team Member user.
                     if(opp.Marketing_Associate__r.Entity__c == oppmap.get(opp.id).Entity__c && opp.Marketing_Associate__r.IsActive == true 
                           && opp.Marketing_Associate__r.UserType == 'Standard') {
                            
                            //Inserting the Opportunity member Records
                            otmsToInsert.add(new OpportunityTeamMember(
                                OpportunityId = opp.Id, 
                                UserId=opp.Marketing_Associate__c, 
                                TeamMemberRole = thisrole ));
                        }
                    
                }
                
            } //end if Owner IsActive
        }
        
        if (otmsToDelete.size() > 0) {
            Util.byPassAllTriggers = true;
            delete otmsToDelete;
            Util.byPassAllTriggers = false;
        }
        
        if (otmsToInsert.size() > 0) {
            Util.byPassAllTriggers = true;
            insert otmsToInsert;
            Util.byPassAllTriggers = false;
        }
    }
    
    /**
     * 
     *
     *
     *
     **/
    public static void populateInitialVisitDate(Map<Id, Opportunity> mapNewOpportunities) {
        
        /*
        Requirements:
        
        1. Warm Lead (through Warm Lead MtM)
            a) Initial Visit Date
                (1) Should be earliest Initial Visit Date of all connected (through WarmLeadMtM) Opportunities
        
        Warm_Lead__c Object
            Initial Visit Date > Initial_Visit_Date__c
        
        Warm_Lead_MtM__c Object
            Opportunity__c
            Warm_Lead__c
        
        */
        
        List<Id> oppIdList = new List<Id>();
        for(Opportunity opp: mapNewOpportunities.values()){
            oppIdList.add(opp.Id);
        }
        
        List<Warm_Lead__c> warmLeadsToUpdate = new List<Warm_Lead__c>();
        List<Warm_Lead__c> wllist = new List<Warm_Lead__c>();
        
        //Checking for size value
        if(wllist.size() > 0) {
        
            wllist = [select Id, Initial_Visit_Date__c, 
                (select Id, Opportunity__r.Initial_Visit_Date__c from Warm_Leads_MtM__r where Opportunity__c != null) 
                from Warm_Lead__c 
                where id in (select Warm_Lead__c from Warm_Lead_MtM__c where Opportunity__c IN :oppIdList)];
        }
        
        for (Warm_Lead__c wl: wllist) {
            Boolean IsUpdate = false;
            Warm_Lead__c wlObj = new Warm_Lead__c(Id = wl.Id);
            wlObj.Initial_Visit_Date__c = wl.Initial_Visit_Date__c;
            
            for (Warm_Lead_MtM__c wlmtm : wl.Warm_Leads_MtM__r) {
                
                //If this wlmtm is connected to a triggering record, take the new version of it. If not, take the queried version
                Date oppInitialVisit = (mapNewOpportunities.keyset().contains(wlmtm.Opportunity__c)) 
                    ? mapNewOpportunities.get(wlmtm.Opportunity__c).Initial_Visit_Date__c 
                    : wlmtm.Opportunity__r.Initial_Visit_Date__c;
                if (oppInitialVisit == null) continue;
                
                if(wlObj.Initial_Visit_Date__c == null || ( oppInitialVisit < wlObj.Initial_Visit_Date__c)){
                    wlObj.Initial_Visit_Date__c = oppInitialVisit;
                    IsUpdate = true;
                }
            }
    
            if (IsUpdate) warmLeadsToUpdate.add(wlObj);
        }
    
        if(warmLeadsToUpdate.size()>0) {
            Util.byPassAlltriggers = true;  
            update warmLeadsToUpdate;
            Util.byPassAlltriggers = false; 
        }
    }
    
    /**
     *  @description    :   membershipOwnerCheckfromOpps
     *
     *  @args           :   List of opprotunities
     *
     *  @return         :   void
     *
     **/
    public static void membershipOwnerCheckfromOpps(List<Opportunity> lstOpportunities) {
        
        //Opp Ids
        set<id> selectoppids = new set<id>();
        
        //filter list to exclude the ones that aren't even on a Contract
        for (Opportunity o : lstOpportunities) {
            if (o.Previous_Contract__c != null) selectoppids.add(o.id);//Membership__c);
        }
        
        //Call @future method to update Membership owners
        if (!Util.IsTesting) {
            
            //Bhavi Sharma - 04/26/2013 - CR-20130227-2597 - Added condition to make the callout only if not current context is not batch or future
            if(!System.isFuture() && !System.isBatch()) {
                
                Util.membershipOwnerCheckfromOpps(selectoppids);
            }
        }
        Util.TestVariable += 'Util.membershipOwnerCheckfromOpps '; // demonstrate to unit test that we got here.
    }
    
    //Added By - Abhinav Sharma - 08/28/2015 - CR-20140613-5790
    /**
     *  @description    :   Method to populate "Opportunity Initial PA Date" and "Initial Activity Date" fields on "Warm "
     *
     *  @args           :   Set<Id> setWarmLeadIds
     *
     *  @return         :   void
     *
    **/
    public static void populatePAsAndActivityFieldsOnWarmLeadMTMs(List<Opportunity> newOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        //Set to hold the opportunity Ids
        Set<Id> setOpportunities = new Set<Id>();
        
        //Loop through opportunity records
        for(Opportunity opp : newOpportunities) {
            
            if(mapOldOpportunities != null 
                && (
                    mapOldOpportunities.get(opp.Id).Initial_PA_Date__c != opp.Initial_PA_Date__c
                    ||
                    mapOldOpportunities.get(opp.Id).Initial_Activity_Date__c != opp.Initial_Activity_Date__c
                )
            ) {
                setOpportunities.add(opp.Id);        
            }
        } 
        
        //Map to hold the opportunity Id with with list of Warm Lead MTMs
        Map<Id, List<Warm_Lead_MtM__c>> mapWarmLeadMTMs = new Map<Id, List<Warm_Lead_MtM__c>>();
        
        //Map of warm Lead Mtms
        Map<id, Warm_Lead_MtM__c> mapWLMtms = new Map<id, Warm_Lead_MtM__c>();
        
        //Added by VH - 10/09/2015 - CR-20151009-9309
        if (setOpportunities.size() > 0) {
        
            //Loop through warm lead MTm records records associated to opportunity record and populating set accordingly
            for(Warm_Lead_MtM__c wlm : [SELECT ID, Opportunity__c, Opportunity_Initial_PA__c, Opportunity_Initial_Activity__c
                                        FROM Warm_Lead_MtM__c
                                        WHERE Opportunity__c != null 
                                        AND Opportunity__c IN : setOpportunities]) {
                
                //Checking for key in map                            
                if(mapWarmLeadMTMs.containsKey(wlm.Opportunity__c)) {  
                    
                    //Get the Values of the Map and add Id to it.  
                    mapWarmLeadMTMs.get(wlm.Opportunity__c).add(wlm);  
                    
                } else {  
                    
                    //Creat a new Set at values and add Id to it.  
                    mapWarmLeadMTMs.put(wlm.Opportunity__c, new List<Warm_Lead_MtM__c>{wlm});           
                }
            }
            
            //Loop through opportunity records
            for(Opportunity op : newOpportunities) {
                
                //Checking for key in map and if exist getting associated Warm lead MTMs
                if(mapWarmLeadMTMs.containsKey(op.id) && mapWarmLeadMTMs.get(op.id) != null
                   && mapWarmLeadMTMs.get(op.id).size() > 0) {
                       
                       //Loop through warm lead MTm records and populating fields values on them from Opportunity
                       for(Warm_Lead_MtM__c wlms : mapWarmLeadMTMs.get(op.id)) {
                           wlms.Opportunity_Initial_PA__c = op.Initial_PA_Date__c;  
                           wlms.Opportunity_Initial_Activity__c = op.Initial_Activity_Date__c;    
                           mapWLMtms.put(wlms.Id, wlms);
                       }            
                   }
            }
        }   
        
        //Intentionally not by passing triggers
        //Checking map for values
        if(mapWLMtms.values().size() > 0)
            update mapWLMtms.values();
    }
        
    /**
     *  @description    :   When a renewal Opportunity's Status changes and the opportunity is related to a Contract, 
     *                      all related Memberships (Latest Contract & Earliest Contract) should have their Membership Status recalculated.
     *                      This method is to hold the logic behind it.
     *
     *  @args           :   List<Opportunity>, Map<Id, Opportunity>
     *
     *  @return         :   void
     *
     *  @revision Log   :   Added By - 1/23/2017 - Abhinav Sharma - CR-20170105-10596
     *            V1.0 - Modified By - Subhash Garhwal - 09/28/2018 - CR-20180720-12456 - Added new parameter value in method calling.
     *
     **/
    public static void syncUpMembershipsWithLatestStatus(List<Opportunity> newOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        //Set to hold Opportunity Ids
        Set<Id> setOfEligibleOpportunityIds = new Set<Id>();
        
        //Loop over Opportunities records
        for(Opportunity opp : newOpportunities){
                
            //Checking opportunity record for it's status field change
            if(mapOldOpportunities != null 
                && String.IsNotBlank(opp.Status__c) 
                && opp.Status__c != mapOldOpportunities.get(opp.Id).Status__c
            )
                setOfEligibleOpportunityIds.add(opp.Id);
        }
        
        //Check set for it's size
        if(setOfEligibleOpportunityIds.size() > 0 ){
            
            //Map to hold the membership records need to be updated for "Membership Status" re-calculation
            Map<Id, Membership__c> mapOfMembershipsToBeUpdated = new Map<Id, Membership__c>();
            
            //V_1.51 - Modified by - Saurabh Kumar - 06/05/2017 - CR-20170403-10808 (DS114) - Fields "Earliest_Subscription__c", "Active_Subscription__c", "Latest_Subscription__c" are added
            //Loop over Contract record to whom the eligible opportunities are associated as parent
            for(Contract__c con : [SELECT Id, Contract_Renewal_Opportunity__c,
                                       (SELECT Id, Membership_Status_Text__c, Active_Contract_Idenfied__c, Active_Subscription__c, Latest_Contract__c, Latest_Subscription__c, Earliest_Contract__c, Earliest_Subscription__c, Payer_Status__c, Account_Name__c, Membership_Status_Change_Date__c, 
                                        Program_Business_Line__c,Program__c FROM Memberships__r 
                                        WHERE Earliest_Contract__c != null OR Earliest_Subscription__c != null
                                       ),
                                       (SELECT Id, Membership_Status_Text__c, Active_Contract_Idenfied__c, Active_Subscription__c, Latest_Contract__c, Latest_Subscription__c, Earliest_Contract__c, Earliest_Subscription__c, Payer_Status__c, Account_Name__c, Membership_Status_Change_Date__c, 
                                        Program_Business_Line__c,Program__c FROM Memberships1__r 
                                        WHERE Latest_Contract__c != null OR Latest_Subscription__c != null
                                       ),
                                       (SELECT Id, Membership_Status_Text__c, Active_Contract_Idenfied__c, Active_Subscription__c, Latest_Contract__c, Latest_Subscription__c, Earliest_Contract__c, Earliest_Subscription__c, Payer_Status__c, Account_Name__c, Membership_Status_Change_Date__c, 
                                        Program_Business_Line__c,Program__c FROM Memberships2__r 
                                        WHERE Active_Contract_Idenfied__c != null OR Active_Subscription__c != null
                                       )
                                   FROM Contract__c 
                                   WHERE Contract_Renewal_Opportunity__c != null
                                   AND Contract_Renewal_Opportunity__c IN : setOfEligibleOpportunityIds]){
                
                //Checking children memberships for there presence 
                if(con.Memberships__r != null && con.Memberships__r.size() > 0) {
                    for(Membership__c m : con.Memberships__r)
                        mapOfMembershipsToBeUpdated.put(m.Id, m);
                }
                
                if(con.Memberships1__r != null && con.Memberships1__r.size() > 0) {
                    for(Membership__c m1 : con.Memberships1__r)
                        mapOfMembershipsToBeUpdated.put(m1.Id, m1);
                }
                
                if(con.Memberships2__r != null && con.Memberships2__r.size() > 0) {
                    for(Membership__c m2 : con.Memberships2__r)
                        mapOfMembershipsToBeUpdated.put(m2.Id, m2);
                }
            }
            
            //Check map for it's size
            if(mapOfMembershipsToBeUpdated.values().size() > 0){
                
                //Set flag true to update membership 
                OPPORTUNITY_STATUS_FIELD_CHANGE_IS_THE_EVENT = true;
                
                //Added new parameter value in method calling - Modified by Subhash Garhawal - 09/28/2018 - CR-20180720-12456
                //Calling helper class method that is having re-calculation based logic with it
                MembershipTriggerHelper.updateMembershipStatusByContracts(mapOfMembershipsToBeUpdated.values());
            }
        }
    }
    
    /**
     *  @description    :   When main conrtact got changed and it's pool year is current year and Insitution and Program are not blank then update all opportunities 
                            main contact which are having same institution and program and their pool year either current year or future year.
     *
     *  @args           :   List<Opportunity>, Map<Id, Opportunity>
     *
     *  @return         :   void
     *
     *  @revision Log   :   Added By - Mahendra Swarnkar - 03/18/2017 - CR-20170216-10694 - V_1.39
     *                      Modified By - Saurabh Kumar - 09/13/2017 - To by pass VR_Restrict_Main_Contact as per issue CR-20170908-11190 - V_1.60
     *
     **/
    public static void updateMainContactsOnCurrentAndFutureOpp(List<Opportunity> newOpportunities, Map<Id, Opportunity> mapOldOpportunities){
        
        //Map to hold AccountId + Program__c as KEY and Opportunity as VALUE
        Map<String, Opportunity> mapOpportunities = new Map<String, Opportunity>();
        
        //Set to hold Institution Ids
        Set<Id> setInstitutionIds = new Set<Id>();
        
        //Set to hold Program Ids
        Set<Id> setProgramIds = new Set<Id>();
        
        //Map to hold opportunities to be update
        Map<Id, Opportunity> mapOpportunitiesToUpdate = new Map<Id, Opportunity>();

    //Set to hold Contact ids
    Set<Id> setContactIds = new Set<Id>();

        //Processing on new Opportunities
        for(Opportunity opportunity : newOpportunities){
            
            if(mapOldOpportunities != null 
                && opportunity.Main_Contact__c != mapOldOpportunities.get(opportunity.Id).Main_Contact__c
                && opportunity.Pool_Year__c == String.valueOf(Date.today().year())
                && opportunity.AccountId != null
                && opportunity.Program__c != null
                && opportunity.Main_Contact__c != null){
                    
                    mapOpportunities.put(opportunity.AccountId+''+opportunity.Program__c, opportunity);
                    setInstitutionIds.add(opportunity.AccountId);
                    setProgramIds.add(opportunity.Program__c);
           setContactIds.add(opportunity.Main_Contact__c);
            }   
        }
        
        //Checking for map size
        if(mapOpportunities.size() > 0 && setContactIds.Size()> 0){

        //Addded By - Saurabh Kumar - 09/13/2017 - To hold contact details in map - V_1.60
        Map<Id,Contact> mapOfContact  = new Map <Id,Contact>([Select Id, Contact_Status__c, AccountId From Contact Where Id IN: setContactIds]);

            //Processing on selected Opportunities and update Main Contact
            //Modified by Saurabh Kumar - 09/13/2017 - to add more field in query  - V_1.60
            for(Opportunity opportunity: [Select Id, Main_Contact__c, Main_Contact__r.Contact_Status__c, RecordType.DeveloperName,
                            Main_Contact__r.AccountId, AccountId, Program__c, Pool_Year__c, SBQQ__RenewedContract__r.SBQQ__DefaultRenewalContactRoles__c
                                            From Opportunity 
                                            Where AccountId IN : setInstitutionIds
                                            AND Program__c IN : setProgramIds]){
                
                //Checking whethet Pool Year is current and future year
                //Modified - Saurabh Kumar - 09/13/2017 - added condition to bypass VR_Restrict_Main_Contact V_1.60 
                if(opportunity.Pool_Year__c != null && 
                   Integer.valueOf(opportunity.Pool_Year__c) > = Date.today().year()
                  && mapOpportunities.containsKey(opportunity.AccountId+''+opportunity.Program__c)
                  && mapOpportunities.get(opportunity.AccountId+''+opportunity.Program__c) != null
                  && (
                      !CPQConstants.SET_OPPORTUNITY_RECORDTYPE_DEVELOPERNAMES.contains(opportunity.RecordType.DeveloperName)
                      ||
                      CPQConstants.SET_OPPORTUNITY_RECORDTYPE_DEVELOPERNAMES.contains(opportunity.RecordType.DeveloperName)
                      && mapOfContact.containsKey(mapOpportunities.get(opportunity.AccountId+''+opportunity.Program__c).Main_Contact__c)
                      && mapOfContact.get(mapOpportunities.get(opportunity.AccountId+''+opportunity.Program__c).Main_Contact__c).Contact_Status__c == 'Active'
                      && mapOfContact.get(mapOpportunities.get(opportunity.AccountId+''+opportunity.Program__c).Main_Contact__c).AccountId == opportunity.AccountId
                     )
                  ){
                     
                    mapOpportunitiesToUpdate.put(opportunity.Id, new Opportunity(Id = opportunity.Id, 
                                            Main_Contact__c = mapOpportunities.get(opportunity.AccountId+''+opportunity.Program__c).Main_Contact__c));
                }
            }   
        }
        
        //Checking for map size
        if(mapOpportunitiesToUpdate.size() > 0){
            
            //Bypassing Triggers so then test data can be created easily
            Util.byPassAllTriggers = true;
            DO_NOT_EXECUTE_OCR_SYNC_TRIGGER_LOGIC = true;
            
            update mapOpportunitiesToUpdate.values();
            OpportunityTriggerHelper.syncOppMainContactAndPrimayOCR(mapOpportunitiesToUpdate.keySet(), mapOpportunitiesToUpdate.values());
            
            //Reset the flag
            Util.byPassAllTriggers = false; 
        }
    }
    
    /**
     *  @description    :   Method to keep opportunity "Main Contact" field and associated Opportunity Contact Role records. 
     *                      in sync.
     * 
     *  @args           :   Set<Id> setOpportunitiesIds, List<Opportunity> newOpportunities
     * 
     *  @return         :   void
     *
     *  @revision Log   :   Added By - Mahendra Swarnkar - 03/18/2017 - CR-20170216-10694 - V_1.39
     *            V1.1 - Modified - Subhash Garhwal - 08/18/2017 - Issue--CR11094--UAT--00005382 - Added logic to avoid the duplicate OpportunityContactRoles
     * 
    **/
    public static void syncOppMainContactAndPrimayOCR(Set<Id> setOpportunitiesIds, List<Opportunity> newOpportunities){

        //Checking set for size value
        if(setOpportunitiesIds.size() > 0) {
            
            /*****************     Start       *********************/
            //Added - Subhash Garhwal - Issue--CR11094--UAT--00005382
            //Map to hold the Current opportunity with Previous Opportunity Id
            Map<Id, Set<Id>> mapCurrentOppsWithPreviousOpp = new Map<Id, Set<Id>>();
            
            //Map to hold the Opportunity with CreatedDate
            Map<Id, DateTime> mapCurrentOppWithCreatedDate = new Map<Id, DateTime>();
            
            //SOQL over the current opportunity
            for(Opportunity opp : [Select Id, CreatedDate, LastModifiedDate, Previous_Opportunity__c, SBQQ__RenewedContract__c From Opportunity Where Id IN : setOpportunitiesIds
                              AND SBQQ__RenewedContract__r.SBQQ__DefaultRenewalContactRoles__c = true AND Previous_Opportunity__c != null]) {

              //Check Previous Opp Id in map
              if(!mapCurrentOppsWithPreviousOpp.containsKey(opp.Previous_Opportunity__c))
                mapCurrentOppsWithPreviousOpp.put(opp.Previous_Opportunity__c, new Set<Id>());

              //Add Oppp Id in set
              mapCurrentOppsWithPreviousOpp.get(opp.Previous_Opportunity__c).add(opp.Id); 

              //Populate created date map
              if(opp.LastModifiedDate <= opp.CreatedDate.addMinutes(5))
                mapCurrentOppWithCreatedDate.put(opp.Id, opp.CreatedDate);  

      }
        
      
      //Map to hold the Current Opportunity Previous Opp's OCRs Contact Ids
      Map<Id, Set<Id>> mapCurrentOppWithExistingOCRs = new Map<Id, Set<Id>>();
      
      //Map to check hold the previous Opp's Primary OCR flag
      Map<Id, Boolean> mapCurrentOppWithPreOppOCRPrimary = new Map<Id, Boolean>();
      
      //Check for size
      if(mapCurrentOppWithCreatedDate.size() > 0 && mapCurrentOppsWithPreviousOpp.size() > 0) {
        
        //Map to hold the Opportunity Id with OCR
        Map<Id, List<OpportunityContactRole>> mapPreviousOppWithOCRs = new Map<Id, List<OpportunityContactRole>>();
        
        //SOQL over the OCR
        for(OpportunityContactRole oCR : [SELECT Id, CreatedDate, ContactId, IsPrimary, OpportunityId FROM OpportunityContactRole 
                                                     WHERE OpportunityId != null AND OpportunityId IN : mapCurrentOppsWithPreviousOpp.keySet()
                                                       ORDER BY CreatedDate DESC]) {

          //Check Opportunity id in map
          if(!mapPreviousOppWithOCRs.containsKey(oCR.OpportunityId))
            mapPreviousOppWithOCRs.put(oCR.OpportunityId, new List<OpportunityContactRole>());

          //Add OCR in map
          mapPreviousOppWithOCRs.get(oCR.OpportunityId).add(oCR);    

        }
        
        //Check for size
        if(mapPreviousOppWithOCRs.size() > 0) {
          
          //Loop over the new Opp
          for(Id preOppId : mapCurrentOppsWithPreviousOpp.keySet()) {
            
            //Check map
            if(mapPreviousOppWithOCRs.containsKey(preOppId)) {
              
              //Loop over the new Opps
              for(Id newOppId : mapCurrentOppsWithPreviousOpp.get(preOppId)) {
                
                //Loop over the OCR
                for(OpportunityContactRole oCR : mapPreviousOppWithOCRs.get(preOppId)) {
                  
                  //Check for created date
                  if(!mapCurrentOppWithCreatedDate.containsKey(newOppId) || (mapCurrentOppWithCreatedDate.containsKey(newOppId) && mapCurrentOppWithCreatedDate.get(newOppId) < oCR.CreatedDate))
                    break;
                  
                  //Check current opp Id in map
                  if(!mapCurrentOppWithExistingOCRs.containsKey(newOppId))
                    mapCurrentOppWithExistingOCRs.put(newOppId, new Set<Id>());
                  
                  //Add Id in map
                  mapCurrentOppWithExistingOCRs.get(newOppId).add(oCR.ContactId);
                  
                  //Check for Primary flag
                  if(oCR.IsPrimary)
                    mapCurrentOppWithPreOppOCRPrimary.put(newOppId, true);    
                }
              }    
            }
          }                                
        }
      } 
      
      /*****************     End       *********************/  
      
            //Map to hold the opportunity record Id as key and associated opportunity contact role records list as value
            Map<Id, List<OpportunityContactRole>> mapOppIdWithOCRs = new Map<Id, List<OpportunityContactRole>>();
            
            //Map to hold the Opportunity Id as key and associated primary opportunity contact role as value
            Map<Id, OpportunityContactRole> mapOppIdWithPrimaryOCR = new Map<Id, OpportunityContactRole>();
            
            //Retreving associated "Opportunity Contact Role" records from the database
            for(OpportunityContactRole oCR : [SELECT Id, ContactId, OpportunityId, IsPrimary 
                                              FROM OpportunityContactRole 
                                              WHERE OpportunityId != null
                                              AND OpportunityId IN : setOpportunitiesIds]) {
                if(mapOppIdWithOCRs.containsKey(oCR.OpportunityId))
                    mapOppIdWithOCRs.get(oCR.OpportunityId).add(oCR);
                else
                    mapOppIdWithOCRs.put(oCR.OpportunityId, new List<OpportunityContactRole>{oCR});
                                
                if(oCR.IsPrimary)                                  
                    mapOppIdWithPrimaryOCR.put(oCR.OpportunityId, oCR);                                  
            }
                
            //List of OpportunityContactRole records (Will insert)
            List<OpportunityContactRole> oCRsListToBeInserted = new List<OpportunityContactRole>();
            
            //List of OpportunityContactRole records (Will Update)
            Map<Id, OpportunityContactRole> oCRsListToBeUpdated = new Map<Id, OpportunityContactRole>();
            
            //Loop through trigger.new instance and populating main contact field with contact reference
            //a) When the Main Contact field on Opportunity is updated via field edit, this will also set the Primary flag 
            //on the contact in the Contact Roles list.
            //b) If the contact set in Main Contact is not in the current Contact Roles, add the contact to Contact Roles
            //and set the contact as Primary.
            //c) This function must also still allow the Primary Contact to be set by updating the Contact Role record. 
            //Therefore, the Primary Contact can be set either by setting Main Contact on the Opportunity, 
            //or by setting the Primary flag on the Contact Role. (Handled by opportunity page inline VF page)
            for(Opportunity oppt : newOpportunities) {
                
                //Checking if no OCR record is associated with Opportunity record
                if(!mapOppIdWithOCRs.containsKey(oppt.Id)) {
                    
                    //Checking for "Main Contact" field value on the opportunity record
                    //Subhash Garhwal - 8/18/2017 - Added additional condition
                    if(oppt.Main_Contact__c != null && (!mapCurrentOppWithExistingOCRs.containsKey(oppt.Id)
                      || !mapCurrentOppWithExistingOCRs.get(oppt.Id).contains(oppt.Main_Contact__c))) {
            
                        //Opportunity Contact Role record instance
                        OpportunityContactRole oCRoleInsert = new OpportunityContactRole();
                        
                        //Populating OCR instance with field values
                        oCRoleInsert.ContactId = oppt.Main_Contact__c;
                        oCRoleInsert.IsPrimary = !mapCurrentOppWithPreOppOCRPrimary.containsKey(oppt.Id) ? true : false; // Subhash Garhwal - Added map check
                        oCRoleInsert.OpportunityId = oppt.Id;
                        oCRoleInsert.Role = System.Label.OCR_CONATCT_DEFAULT_ROLE;
                        
                        //Adding instance into the list to be inserted
                        oCRsListToBeInserted.add(oCRoleInsert);
                    
                    } else {
                        //Do nothing
                    }
                
                //If OCR record(s) is already associated with opportunity record    
                } else {
                        
                    //Checking if "Main Contact" field is having a contact reference with it
                    if(oppt.Main_Contact__c != null) {
                            
                        //Boolean variable helpful in making decision about any existing OCR 
                        //with matching contact exists or not
                        Boolean isMatchingOCRExists = false;
                        
                        //Loop through OCR records and seraching out that if we are having any existing matching OCR
                        for(OpportunityContactRole oCRole : mapOppIdWithOCRs.get(oppt.Id)) {
                            if(oCRole.ContactId == oppt.Main_Contact__c)
                                isMatchingOCRExists = true;
                        }
                        
                        //Subhash Garhwal - 08/18-2017 - Check Contract Role for Previous Opps
                        if(mapCurrentOppWithExistingOCRs.containsKey(oppt.Id)
                          && mapCurrentOppWithExistingOCRs.get(oppt.Id).contains(oppt.Main_Contact__c))
                      isMatchingOCRExists = true;
                        
                        //If Main contact based OCR is not exists 
                        if(!isMatchingOCRExists) {
                            
                            //Opportunity Contact Role record instance
                            OpportunityContactRole oCRoleInsert1 = new OpportunityContactRole();
                            
                            //Populating OCR instance with field values
                            oCRoleInsert1.ContactId = oppt.Main_Contact__c;
                            oCRoleInsert1.IsPrimary = !mapCurrentOppWithPreOppOCRPrimary.containsKey(oppt.Id) ? true : false; // Subhash Garhwal - Added map check
                            oCRoleInsert1.OpportunityId = oppt.Id;
                            oCRoleInsert1.Role = System.Label.OCR_CONATCT_DEFAULT_ROLE;
                            
                            //Adding instance into the list to be inserted
                            oCRsListToBeInserted.add(oCRoleInsert1);
                            
                            //Updating existing OCR to mark it as non-primary
                            if(mapOppIdWithPrimaryOCR.containsKey(oppt.Id)
                                && mapOppIdWithPrimaryOCR.get(oppt.Id) != null) {
                                   
                                //Opportunity Contact Role record instance
                                OpportunityContactRole oCRoleUpdate = new OpportunityContactRole();
                                oCRoleUpdate = mapOppIdWithPrimaryOCR.get(oppt.Id);
                                oCRoleUpdate.IsPrimary = false;
                                oCRsListToBeUpdated.put(oCRoleUpdate.Id, oCRoleUpdate);
                                    
                            } else {
                                //Do nothing
                            }
                        } else {
                            
                            //Loop through OCR records and seraching out that if we are having any existing matching OCR
                            for(OpportunityContactRole oCRole1 : mapOppIdWithOCRs.get(oppt.Id)) {
                                if(oCRole1.ContactId == oppt.Main_Contact__c) {
                                    oCRole1.IsPrimary = true;
                                    oCRsListToBeUpdated.put(oCRole1.Id, oCRole1);        
                                }
                            }
                            
                            //Updating existing OCR to mark it as non-primary
                            if(mapOppIdWithPrimaryOCR.containsKey(oppt.Id)
                                && mapOppIdWithPrimaryOCR.get(oppt.Id) != null) {
                                   
                                //Opportunity Contact Role record instance
                                OpportunityContactRole oCRoleUpdate2 = new OpportunityContactRole();
                                oCRoleUpdate2 = mapOppIdWithPrimaryOCR.get(oppt.Id);
                                oCRoleUpdate2.IsPrimary = false;
                                oCRsListToBeUpdated.put(oCRoleUpdate2.Id, oCRoleUpdate2);
                                    
                            } else {
                                //Do nothing
                            }
                        }
                    } else {
                        
                        //Updating existing OCR to mark it as non-primary
                        if(mapOppIdWithPrimaryOCR.containsKey(oppt.Id)
                            && mapOppIdWithPrimaryOCR.get(oppt.Id) != null) {
                               
                            //Opportunity Contact Role record instance
                            OpportunityContactRole oCRoleUpdate3 = new OpportunityContactRole();
                            oCRoleUpdate3 = mapOppIdWithPrimaryOCR.get(oppt.Id);
                            oCRoleUpdate3.IsPrimary = false;
                            oCRsListToBeUpdated.put(oCRoleUpdate3.Id, oCRoleUpdate3);
                               
                        } else {
                            //Do nothing
                        }
                    }
                }
            }
                        
            //Checking for the size value
            if(oCRsListToBeUpdated.values().size() > 0) {
                Util.byPassAllTriggers = true;
                update oCRsListToBeUpdated.values();
                Util.byPassAllTriggers = false;
            }
                
            
            //Checking for the size value
            if(oCRsListToBeInserted.size() > 0) {
                Util.byPassAllTriggers = true;
                insert oCRsListToBeInserted;
                Util.byPassAllTriggers = false;
            }
        }
    }
        
    /**
     *  @description    :   Method to sync up field values on subscription records, if changes happens on the correspodning fields of Opportunity.
     *
     *  @args           :   List<Opportunity>, Map<Id, Opportunity>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.0 - Created - 06/04/2017 - Abhinav Sharma - DS114
     *
     **/
    public static void updateMembershipsWithOpportunityFieldsValues(List<Opportunity> newOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        //Checking for the update use case
        if(newOpportunities != null && mapOldOpportunities != null) {
         
            //Map of eligible opportunities
            Map<Id, Opportunity> mapOfEligibleOpportunities = new Map<Id, Opportunity>();
            
            //Loop through opportunity records
            for(Opportunity opp : newOpportunities) {
                
                //Checking for the field values changes
                if(opp.Main_Contact__c != mapOldOpportunities.get(opp.Id).Main_Contact__c)
                    mapOfEligibleOpportunities.put(opp.Id, opp);
            }
        
            //Checking for size of set
            if(mapOfEligibleOpportunities.values().size() > 0) {
                
                //Map of memberships
                Map<Id, Membership__c> mapOfMemberships = new Map<Id, Membership__c>();
                
                //Loop through Subscription records
                for(Membership__c me : [SELECT ID, Active_Renewal_Opp_Main_Contact_Name__c, Active_Renewal_Opportunity_Main_Contact__c, 
                                            Active_Renewal_Opportunity__c,
                                            Active_Renewal_Opportunity__r.Main_Contact__c,
                                            Active_Renewal_Opportunity__r.Main_Contact__r.Firstname,
                                            Active_Renewal_Opportunity__r.Main_Contact__r.Lastname
                                            FROM Membership__c
                                            WHERE Active_Renewal_Opportunity__c != null
                                            AND Active_Renewal_Opportunity__c IN : mapOfEligibleOpportunities.keySet()]) {
                                            
                    //Boolean to validate for change
                    Boolean isOpportunityNeedToBeUpdated = false;
                                                
                    //Checking for existance of main contact
                    if(me.Active_Renewal_Opportunity__r.Main_Contact__c != null) {
                        
                        //Checking for fields value differences
                        if(me.Active_Renewal_Opportunity_Main_Contact__c != me.Active_Renewal_Opportunity__r.Main_Contact__c) {
                            me.Active_Renewal_Opportunity_Main_Contact__c = me.Active_Renewal_Opportunity__r.Main_Contact__c;
                            isOpportunityNeedToBeUpdated = true;
                        }
                            
                        String mainContactName = '';
                
                        if(String.isNotBlank(me.Active_Renewal_Opportunity__r.Main_Contact__r.Firstname))
                            mainContactName += me.Active_Renewal_Opportunity__r.Main_Contact__r.Firstname + ' ';
                            
                        mainContactName += me.Active_Renewal_Opportunity__r.Main_Contact__r.Lastname;
                        
                        //Checking for field value differences
                        if(me.Active_Renewal_Opp_Main_Contact_Name__c != mainContactName) {
                            me.Active_Renewal_Opp_Main_Contact_Name__c = mainContactName;   
                            isOpportunityNeedToBeUpdated = true;
                        }
                        
                        //Populating map with values
                        if(isOpportunityNeedToBeUpdated)
                            mapOfMemberships.put(me.Id, me);
                            
                    } else {
                    
                        if(String.isNotBlank(me.Active_Renewal_Opp_Main_Contact_Name__c)
                            ||
                            me.Active_Renewal_Opportunity_Main_Contact__c != null
                        ) {
                            me.Active_Renewal_Opp_Main_Contact_Name__c = '';
                            me.Active_Renewal_Opportunity_Main_Contact__c = null;
                            mapOfMemberships.put(me.Id, me);     
                        }
                    }
                }
                
                //Checking for size value
                if(mapOfMemberships.values().size() > 0) {
                    Util.byPassAllTriggers = true;
                    update mapOfMemberships.values();
                    Util.byPassAllTriggers = false;
                }        
            }
        }                       
    }
    
    /**
     *  @description    :   Method to sync up field values on subscription records, if changes happens on the correspodning fields of Opportunity.
     *
     *  @args           :   List<Opportunity>, Map<Id, Opportunity>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.0 - Created - 06/04/2017 - Abhinav Sharma - DS114
     *                      V1.1 - Modified by Rajeev Jain 05/16/2019 CR-20190201-12861
     *
     **/
     public static void updateSubscriptionsWithOpportunityFieldsValues(List<Opportunity> newOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        //Checking for the update use case
        if(newOpportunities != null && mapOldOpportunities != null) {
         
            //Map of eligible opportunities
            Map<Id, Opportunity> mapOfEligibleOpportunities = new Map<Id, Opportunity>();
            
            //Loop through opportunity records
            for(Opportunity opp : newOpportunities) {
                
                //Checking for the field values changes
                if(opp.StageName !=  mapOldOpportunities.get(opp.Id).StageName
                    ||
                    opp.CloseDate !=  mapOldOpportunities.get(opp.Id).CloseDate
                    ||
                    opp.Decision_Type__c !=  mapOldOpportunities.get(opp.Id).Decision_Type__c
                    ||
                    opp.End__c != mapOldOpportunities.get(opp.Id).End__c
                    ||
                    opp.Name != mapOldOpportunities.get(opp.Id).Name
                    ||
                    opp.Probability != mapOldOpportunities.get(opp.Id).Probability
                    ||
                    opp.Renewal_Credit__c != mapOldOpportunities.get(opp.Id).Renewal_Credit__c
                    ||
                    opp.Amount != mapOldOpportunities.get(opp.Id).Amount
                    ||
                    opp.Stagename != mapOldOpportunities.get(opp.Id).Stagename
                    ||
                    opp.Start__c != mapOldOpportunities.get(opp.Id).Start__c
                    ||
                    opp.Pool_Year__c != mapOldOpportunities.get(opp.Id).Pool_Year__c
                    ||
                    opp.Pool_Month__c != mapOldOpportunities.get(opp.Id).Pool_Month__c
                    ||
                    opp.Main_Contact__c != mapOldOpportunities.get(opp.Id).Main_Contact__c
                    ||
                    opp.OwnerID != mapOldOpportunities.get(opp.Id).OwnerID
                )
                    mapOfEligibleOpportunities.put(opp.Id, opp);
            }
        
            //Updated by Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830
            //Checking for size of set
            if(mapOfEligibleOpportunities.size() > 0) {
                
                //Map of Subscription
                Map<Id, SBQQ__Subscription__c> mapOfSubscriptions = new Map<Id, SBQQ__Subscription__c>();
                
                //Loop through Subscription records
                for(SBQQ__Subscription__c ss : [SELECT ID, Renewal_Opp_Stage__c, Renewal_Opportunity__c,
                                                Renewal_Opportunity_Main_Contact__c,
                                                Renewal_Opportunity_Owner_Name__c,
                                                Renewal_Opportunity__r.OwnerId,
                                                Renewal_Opportunity__r.Owner.Name
                                                FROM SBQQ__Subscription__c
                                                WHERE Renewal_Opportunity__c != null
                                                AND Renewal_Opportunity__c IN : mapOfEligibleOpportunities.keySet()]) {
                                                    
                    //Boolean to validate whether an update is needed or not
                    Boolean isUpdateIsNeededOnRenewalSubscriptions = false;
                        
                    if(ss.Renewal_Opp_Stage__c != mapOfEligibleOpportunities.get(ss.Renewal_Opportunity__c).StageName) {
                        ss.Renewal_Opp_Stage__c = mapOfEligibleOpportunities.get(ss.Renewal_Opportunity__c).StageName;
                        isUpdateIsNeededOnRenewalSubscriptions = true;
                    }
                                                    
                    //Checking for null/blank value
                    if(ss.Renewal_Opportunity_Main_Contact__c != mapOfEligibleOpportunities.get(ss.Renewal_Opportunity__c).Main_Contact_Name_Text__c) {
                        ss.Renewal_Opportunity_Main_Contact__c = mapOfEligibleOpportunities.get(ss.Renewal_Opportunity__c).Main_Contact_Name_Text__c;
                        isUpdateIsNeededOnRenewalSubscriptions = true;
                    }
                    
                    //Checking for null/blank value
                    if(ss.Renewal_Opportunity__r.OwnerId != null) {
                        
                        if(ss.Renewal_Opportunity_Owner_Name__c != ss.Renewal_Opportunity__r.Owner.Name) {
                            ss.Renewal_Opportunity_Owner_Name__c = ss.Renewal_Opportunity__r.Owner.Name;
                            isUpdateIsNeededOnRenewalSubscriptions = true;
                        }   
                    } else {
                        if(String.isNotBlank(ss.Renewal_Opportunity_Owner_Name__c)) {
                            ss.Renewal_Opportunity_Owner_Name__c = '';
                            isUpdateIsNeededOnRenewalSubscriptions = true;
                        }
                    }
                     
                    //Checking for flag value
                    if(isUpdateIsNeededOnRenewalSubscriptions)        
                        mapOfSubscriptions.put(ss.Id, ss);  
                }
                
                //Loop through Subscription records
                for(SBQQ__Subscription__c ss : [SELECT ID, Source_Opportunity__c,
                                                Source_Opportunity_Close_Date__c,
                                                Source_Opportunity_Decision_Type__c, 
                                                Source_Opportunity_End_Date__c,
                                                Source_Opportunity_Name__c,
                                                Source_Opportunity_Probability__c,
                                                Source_Opportunity_Proposal_Value_Read__c,
                                                Source_Opportunity_Stagename__c,
                                                Source_Opportunity_Start__c,
                                                Source_Opportunity_Pool_Month__c,
                                                Source_Opportunity_Pool_Year__c
                                                FROM SBQQ__Subscription__c
                                                WHERE Source_Opportunity__c != null
                                                AND Source_Opportunity__c IN : mapOfEligibleOpportunities.keySet()]) {
                                                    
                    //Boolean to validate whether an update is needed or not
                    Boolean isUpdateIsNeededOnSubscriptions = false;                                
                        
                    //Checking for differences in between values
                    if(ss.Source_Opportunity_Close_Date__c != mapOfEligibleOpportunities.get(ss.Source_Opportunity__c).CloseDate) {
                        ss.Source_Opportunity_Close_Date__c = mapOfEligibleOpportunities.get(ss.Source_Opportunity__c).CloseDate;
                        isUpdateIsNeededOnSubscriptions = true;
                    }   
                                                    
                    //Checking for differences in between values
                    if(ss.Source_Opportunity_Decision_Type__c != mapOfEligibleOpportunities.get(ss.Source_Opportunity__c).Decision_Type__c) {
                        ss.Source_Opportunity_Decision_Type__c = mapOfEligibleOpportunities.get(ss.Source_Opportunity__c).Decision_Type__c;
                        isUpdateIsNeededOnSubscriptions = true;
                    }
                        
                    //Checking for differences in between values    
                    if(ss.Source_Opportunity_End_Date__c != mapOfEligibleOpportunities.get(ss.Source_Opportunity__c).End__c) {
                        ss.Source_Opportunity_End_Date__c = mapOfEligibleOpportunities.get(ss.Source_Opportunity__c).End__c;
                        isUpdateIsNeededOnSubscriptions = true;
                    }
                            
                    //Checking for differences in between values    
                    if(ss.Source_Opportunity_Name__c != mapOfEligibleOpportunities.get(ss.Source_Opportunity__c).Name) {
                        ss.Source_Opportunity_Name__c = mapOfEligibleOpportunities.get(ss.Source_Opportunity__c).Name;
                        isUpdateIsNeededOnSubscriptions = true;
                    }
                        
                    //Checking for differences in between values    
                    if(ss.Source_Opportunity_Probability__c != mapOfEligibleOpportunities.get(ss.Source_Opportunity__c).Probability) {
                        ss.Source_Opportunity_Probability__c = mapOfEligibleOpportunities.get(ss.Source_Opportunity__c).Probability;
                        isUpdateIsNeededOnSubscriptions = true;
                    }
                            
                    //Checking for differences in between values    
                    if(ss.Source_Opportunity_Proposal_Value_Read__c != mapOfEligibleOpportunities.get(ss.Source_Opportunity__c).Proposal_Value_Read__c) {
                        ss.Source_Opportunity_Proposal_Value_Read__c = mapOfEligibleOpportunities.get(ss.Source_Opportunity__c).Proposal_Value_Read__c;
                        isUpdateIsNeededOnSubscriptions = true;
                    }
                    
                    //Checking for differences in between values    
                    if(ss.Source_Opportunity_Stagename__c != mapOfEligibleOpportunities.get(ss.Source_Opportunity__c).StageName) {
                        ss.Source_Opportunity_Stagename__c = mapOfEligibleOpportunities.get(ss.Source_Opportunity__c).StageName;  
                        isUpdateIsNeededOnSubscriptions = true;
                    } 
                    
                    //Checking for differences in between values    
                    if(ss.Source_Opportunity_Start__c != mapOfEligibleOpportunities.get(ss.Source_Opportunity__c).Start__c) {
                        ss.Source_Opportunity_Start__c = mapOfEligibleOpportunities.get(ss.Source_Opportunity__c).Start__c;
                        isUpdateIsNeededOnSubscriptions = true;
                    }
                    
                    //Checking for differences in between values    
                    if(ss.Source_Opportunity_Pool_Month__c != mapOfEligibleOpportunities.get(ss.Source_Opportunity__c).Pool_Month__c) {
                        ss.Source_Opportunity_Pool_Month__c = mapOfEligibleOpportunities.get(ss.Source_Opportunity__c).Pool_Month__c;
                        isUpdateIsNeededOnSubscriptions = true;
                    }
                    
                    //Checking for differences in between values    
                    if(ss.Source_Opportunity_Pool_Year__c != mapOfEligibleOpportunities.get(ss.Source_Opportunity__c).Pool_Year__c) {
                        ss.Source_Opportunity_Pool_Year__c = mapOfEligibleOpportunities.get(ss.Source_Opportunity__c).Pool_Year__c;
                        isUpdateIsNeededOnSubscriptions = true;
                    }
                    
                    //Checking boolean for it's value
                    if(isUpdateIsNeededOnSubscriptions) {
                        
                        //Checking if key already exists in map
                        if(mapOfSubscriptions.containsKey(ss.Id)) {
                            mapOfSubscriptions.get(ss.Id).Source_Opportunity_Close_Date__c = ss.Source_Opportunity_Close_Date__c;
                            mapOfSubscriptions.get(ss.Id).Source_Opportunity_Decision_Type__c = ss.Source_Opportunity_Decision_Type__c;
                            mapOfSubscriptions.get(ss.Id).Source_Opportunity_End_Date__c = ss.Source_Opportunity_End_Date__c;
                            mapOfSubscriptions.get(ss.Id).Source_Opportunity_Name__c = ss.Source_Opportunity_Name__c;
                            mapOfSubscriptions.get(ss.Id).Source_Opportunity_Probability__c = ss.Source_Opportunity_Probability__c;
                            mapOfSubscriptions.get(ss.Id).Source_Opportunity_Proposal_Value_Read__c = ss.Source_Opportunity_Proposal_Value_Read__c;
                            mapOfSubscriptions.get(ss.Id).Source_Opportunity_Stagename__c = ss.Source_Opportunity_Stagename__c;
                            mapOfSubscriptions.get(ss.Id).Source_Opportunity_Start__c = ss.Source_Opportunity_Start__c;
                            mapOfSubscriptions.get(ss.Id).Source_Opportunity_Pool_Month__c = ss.Source_Opportunity_Pool_Month__c;
                            mapOfSubscriptions.get(ss.Id).Source_Opportunity_Pool_Year__c = ss.Source_Opportunity_Pool_Year__c;
                        } else {
                            mapOfSubscriptions.put(ss.Id, ss);
                        }       
                    }
                }
                
                Map<Id, Contract__c> mapContracts = new Map<Id, Contract__c>();
                //starts here  Modified by Rajeev Jain 05/16/2019 CR-20190201-12861
                Map<Id, Contract__c> SourceOpportunityMap = new Map<Id, Contract__c>();
                Map<Id, Contract__c> ContractRenewalOpportunityMap = new Map<Id, Contract__c>();
                
                for(Contract__c con : [SELECT ID, Contract_Renewal_Opportunity__c,
                                       Renewal_Opp_Owner__c,
                                       Contract_Renewal_Opportunity__r.OwnerId,
                                       Contract_Renewal_Opportunity__r.Owner.Name, 
                                       Source_Opportunity__c,
                                       Source_Opportunity_Close_Date__c,
                                       Source_Opportunity_Decision_Type__c, 
                                       Source_Opportunity_End_Date__c  
                                       FROM Contract__c
                                       WHERE (Source_Opportunity__c != null AND Source_Opportunity__c IN : mapOfEligibleOpportunities.keySet() )
                                       OR (Contract_Renewal_Opportunity__c != null AND Contract_Renewal_Opportunity__c IN : mapOfEligibleOpportunities.keySet())]){
                                           
                                           if (con.Source_Opportunity__c != null &&  mapOfEligibleOpportunities.containsKey(con.Source_Opportunity__c))
                                               SourceOpportunityMap.put(con.Id, con);
                                           
                                           if (con.Contract_Renewal_Opportunity__c != null && mapOfEligibleOpportunities.containsKey(con.Contract_Renewal_Opportunity__c))
                                               ContractRenewalOpportunityMap.put(con.Id, con);
                                           
                                       }
                
                //Map of contracts ABC
               For(Contract__c con : SourceOpportunityMap.values()){
                                                    
                    //Boolean to vaalidate whether update is required on contract or not
                    Boolean isUpdateIsNeededOnContracts = false;
                        
                    //Checking for differences in between values
                    if(con.Source_Opportunity_Close_Date__c != mapOfEligibleOpportunities.get(con.Source_Opportunity__c).CloseDate) {
                        con.Source_Opportunity_Close_Date__c = mapOfEligibleOpportunities.get(con.Source_Opportunity__c).CloseDate;
                        isUpdateIsNeededOnContracts = true;
                    }
                                                        
                    //Checking for differences in between values
                    if(con.Source_Opportunity_Decision_Type__c != mapOfEligibleOpportunities.get(con.Source_Opportunity__c).Decision_Type__c) {
                        con.Source_Opportunity_Decision_Type__c = mapOfEligibleOpportunities.get(con.Source_Opportunity__c).Decision_Type__c;
                        isUpdateIsNeededOnContracts = true;
                    }
                    
                    //Checking for differences in between values    
                    if(con.Source_Opportunity_End_Date__c != mapOfEligibleOpportunities.get(con.Source_Opportunity__c).End__c) {
                        con.Source_Opportunity_End_Date__c = mapOfEligibleOpportunities.get(con.Source_Opportunity__c).End__c;
                        isUpdateIsNeededOnContracts = true;
                    }
                    
                    //Checking for the boolean flag value and then populating collection accordingly
                    if(isUpdateIsNeededOnContracts) 
                        mapContracts.put(con.Id, con);  
                }
                
                For(Contract__c con : ContractRenewalOpportunityMap.values()){
                                                    
                    //Boolean to vaalidate whether update is required on contract or not
                    Boolean isUpdateIsNeededOnContractsRecords = false;
                    
                    //Checking for the owner ID
                    if(mapOfEligibleOpportunities.get(con.Contract_Renewal_Opportunity__c).OwnerId != null) {
                            
                        //Checking for differences in between values    
                        if(con.Renewal_Opp_Owner__c != con.Contract_Renewal_Opportunity__r.Owner.Name) {
                            con.Renewal_Opp_Owner__c = con.Contract_Renewal_Opportunity__r.Owner.Name;
                            isUpdateIsNeededOnContractsRecords = true;
                        }
                        
                    } else {
                        
                        if(String.isNotBlank(con.Renewal_Opp_Owner__c)) {
                            con.Renewal_Opp_Owner__c = '';
                            isUpdateIsNeededOnContractsRecords = true;
                        }
                    }
                    
                    //Checking boolean for it's value
                    if(isUpdateIsNeededOnContractsRecords) {
                        
                        //Checking if key already exists in map
                        if(mapContracts.containsKey(con.Id)) {
                            mapContracts.get(con.Id).Renewal_Opp_Owner__c = con.Renewal_Opp_Owner__c;
                        } else {
                            mapContracts.put(con.Id, con);
                        }
                    }
                } 
                //ends here  Modified by Rajeev Jain 05/16/2019 CR-20190201-12861
                //Checking map for its size
                if(mapOfSubscriptions.values().size() > 0) {
                    Util.byPassAllTriggers = true;
                    update mapOfSubscriptions.values();
                    Util.byPassAllTriggers = false;
                }
                
                //Checking map for its size
                if(mapContracts.values().size() > 0) {
                    Util.byPassAllTriggers = true;
                    update mapContracts.values();
                    Util.byPassAllTriggers = false;
                }
            }
        }        
    }
    
    /**
     *  @description    :   Auto Populate opportunity Date/time field  when opportunity stageName changes to either 
     *                      Contract Received - Sent to Finance/Credited or Contract Received - Sent to Finance/Booked
     *
     *  @args           :   List<Opportunity>, Map<Id, Opportunity>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.0 - Created - 04/06/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807
     *                      V1.1 - Modified - 06/06/2017- Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807
     *                      V1.2 - Modified - 03/21/2019 - Victor Hanson - Set the value of SalesLoft1__Primary_Contact__c = Main_Contact__c
     *
     **/
     public static void autoPopulateFieldOnOpportuntiy(List<Opportunity> newOpportunities, Map<Id, Opportunity> mapOldOpportunities) {

        //Get all the record types
        Map<String, Id> mapOpportunityRecordTypes = Util.recordtypemap('Opportunity');

        //Set of users
        Set<Id> setOfUsers = new Set<Id>();
        
        //Set of contacts
        Set<Id> setContactsIds = new Set<Id>();

        //Loop through new opportunity
        for(Opportunity opp : newOpportunities) {
            
            //Checking for the null value
            if(opp.OwnerId != null)
                setOfUsers.add(opp.OwnerId); 
                
            //Checking for the null value
            if(opp.Main_Contact__c != null) {
                setContactsIds.add(opp.Main_Contact__c);
                //VH added 3/21/2019 - CR-20190321-12957
                opp.SalesLoft1__Primary_Contact__c = opp.Main_Contact__c;
            }

            //Check for Insert and upadate case
            if(mapOldOpportunities == null || opp.StageName != mapOldOpportunities.get(opp.Id).StageName ){

                //Check for opp stage Name equal to "Contract Received - Sent to Finance/Credited"
                if(opp.StageName == CPQConstants.OPP_STAGE_SENT_TO_CREDITED)
                    opp.Credited_Date_Time__c = System.Now();

                //Check for opp stage Name equal to "Contract Received - Sent to Finance/Booked"
                if(opp.StageName == CPQConstants.OPP_STAGE_SENT_TO_BOOKED)
                    opp.Booked_Date_Time__c = System.Now();

            }


        }
        
        //Map of users
        Map<Id, user> mapOfUsers = new Map<Id, User>();
        
        //Checking set for it's size
        if(setOfUsers.size() > 0) {
            mapOfUsers = new Map<Id, User>([SELECT ID, Name 
                                                FROM User
                                                WHERE ID IN : setOfUsers 
                                            ]);
        }
        
        //Map of main Contacts
        Map<Id, Contact> mapOfContacts = new Map<Id, Contact>();
         
        //Checking set for it's size
        if(setContactsIds.size() > 0) {
            mapOfContacts = new Map<Id, Contact>([SELECT ID, Firstname, lastName 
                                                    FROM Contact
                                                    WHERE ID IN : setContactsIds 
                                            ]);
        }
        
        //Loop through opportunity records
        for(Opportunity op : newOpportunities) {
            if(op.OwnerId != null && mapOfUsers.containsKey(op.OwnerId))
                op.Owner_Name__c = mapOfUsers.get(op.OwnerId).Name;
            else
                op.Owner_Name__c = '';
                
            String mainContactName = '';    
                
            if(op.Main_Contact__c != null && mapOfContacts.containsKey(op.Main_Contact__c)) {
                
                if(String.isNotBlank(mapOfContacts.get(op.Main_Contact__c).FirstName))
                    mainContactName += mapOfContacts.get(op.Main_Contact__c).FirstName + ' ';
                    
                mainContactName += mapOfContacts.get(op.Main_Contact__c).Lastname;
                
                op.Main_Contact_Name_Text__c = mainContactName;
            }
            else
                op.Main_Contact_Name_Text__c = '';   
        }
    }

    
    /**
     *  @description    :   This method used to update OpportunityTopParentInstitution
     *
     *  @args           :   List<Opportunity> newopportunities
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - 04/28/2017 - CR-20170403-10807 
     *
     **/
    public static void updateOpportunityTopParentInstitution(List<Opportunity> newopportunities ,Map<Id, Opportunity> mapOldOpportunities ) {

        //Set to hold account Id
        Set<Id> setAccountId = new Set<Id>();

        //Loop through new opportunity
        for(Opportunity opp : newopportunities){

            //Check for  accountId in newly inserted opportunity and old opportunity
            if(opp.AccountId != null && (mapOldOpportunities == null || opp.AccountId != mapOldOpportunities.get(opp.Id).AccountId))
                setAccountId.add(opp.AccountId);
        }

        //Process if size greater than zero         
        if(setAccountId.size() >0 ) {

            //Map to hold Account 
            Map<Id, Account> mapOfAccount = new Map<Id, Account>([Select Id , Associate_Principal__c, Associate_Principal__r.Name, Top_Parent_Institution__c From Account Where Id IN : setAccountId]);

            //Loop through new opportunity
            for(Opportunity opp : newopportunities){
    
                //If Map contain accountId
                if(mapOfAccount.containsKey(opp.AccountId)) {
    
                    //Check if account Top_Parent_Institution__c equal to null
                    if( mapOfAccount.get(opp.AccountId).Top_Parent_Institution__c == null )
                        opp.Top_Parent_Institution_ID__c = opp.AccountId;
    
                    else
                        opp.Top_Parent_Institution_ID__c  = mapOfAccount.get(opp.AccountId).Top_Parent_Institution__c;
                }
                
                //Added the logic of 'populateAssociatePrincipalOnopportunity' method in here to reduce the SOQL query
                 //Check for size
          if(opp.AccountId != null && mapOfAccount.get(opp.AccountId).Associate_Principal__c != Null 
            && mapOfAccount.size() > 0 
            && mapOfAccount.containsKey(opp.AccountId)
            && mapOfAccount.get(opp.AccountId) != null
              && mapOfAccount.get(opp.AccountId).Associate_Principal__c != null
          ) {
            //Populate Associate_Principal__c on opportunity
            opp.Associate_Principal__c = mapOfAccount.get(opp.AccountId).Associate_Principal__r.Name;
          }
          else {
            //Populate Associate_Principal__c on opportunity
              opp.Associate_Principal__c = '';
          }
            }
        }
    }
    
    /**
     *  @description    :   This method is used to prevent the user to move Opportunity to Contract Received - Sent to Finance If
     *                      RecordType is HC_Continuing, HC_Initiating, EAB_Initiating and EAB_Continuing
     *                      SBQQ__PrimaryQuote__r.SBQQ__DocumentStatus__c != Signed OR Signed - Manual Upload
     *                      Stage is Contract Received - Sent to Finance/Booked or Contract Received - Sent to Finance/Credited
     *
     *  @args           :   List<Opportunity>, Map<Id, Opportunity>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - 05/11/2017 - CR-20170403-10807 
   *            V_1.1 - Modified - Subhash Garhwal - 02/10/2017 -To bypass validation rule
     *
     **/
    public static void preventOppToMoveToContractReceivedSentToFinance(List<Opportunity> newOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        //Set to hold the Primary Proposal Ids
        Set<Id> setPrimaryProposalIds = new Set<Id>();

        //Get User Id
        Id currentUserProfileId = Userinfo.getProfileId();

    //MAp to hold Profile id and their name
    Map<Id,String> mapOfProfiles = new Map<Id,String>();
    
    //Loop over profile
       for(Profile pr : [Select Id, Name From profile Where Name != null AND Name = 'Finance Ops'])
            mapOfProfiles.put(pr.Id, pr.Name);
        
        //Get all record types on opportunity object
        Map<String, Id> mapOppRecordTypes = Util.recordtypemap('Opportunity');
        
        //Set to hold the HC and EAB record type Ids
        Set<Id> setOppRecordTypeIds = new Set<Id>();
        
        //Loop over HC and EBA reord type names
        for(String hCEABRT : CPQConstants.SET_OPPORTUNITY_RECORDTYPE_NAMES)
            setOppRecordTypeIds.add(mapOppRecordTypes.get(hCEABRT));    
        
        
        //Loop over the new Opportunities
        for(Opportunity opp : newOpportunities) {
            
            //Check for Opportunity Stage
            if(setOppRecordTypeIds.contains(opp.RecordTypeId) && CPQConstants.SET_OPP_STAGE_CONTRACT_RECEIVED_SENT_TO_FINANCE_VALUES.contains(opp.StageName)
                && (mapOldOpportunities == null || opp.StageName != mapOldOpportunities.get(opp.Id).StageName)) {
                
                //Check for Primary Proposal
                if(opp.SBQQ__PrimaryQuote__c == null && currentUserProfileId != null && !mapOfProfiles.containsKey(currentUserProfileId))
                    throw new CustomException(Label.CONTRACT_RECEIVED_SENT_TO_FINANCE_MSG);               
                else
                    setPrimaryProposalIds.add(opp.SBQQ__PrimaryQuote__c);           
            }
        }
        
        //Check for set size
        if(setPrimaryProposalIds.size() > 0) {
            
            //Map to hold the Primary Proposals
            Map<Id, SBQQ__Quote__c> mapPrimaryProposals = new Map<Id, SBQQ__Quote__c>([Select Id, SBQQ__DocumentStatus__c 
                                                                                        From SBQQ__Quote__c 
                                                                                        Where Id IN : setPrimaryProposalIds
                                                                                            AND
                                                                                            (
                                                                                                SBQQ__DocumentStatus__c =: CPQConstants.PROPOSAL_DOCUMENTSTATUS_SIGNATURE
                                                                                                OR
                                                                                                (
                                                                                                    SBQQ__DocumentStatus__c =: CPQConstants.DOCUMENT_STATUS_SIGNED_MANUAL_UPLOAD
                                                                                                    AND 
                                                                                                    (
                                                                                                        SBQQ__Status__c =: CPQConstants.PROPOSAL_STATUS_APPROVED
                                                                                                        OR 
                                                                                                        SBQQ__Status__c = :CPQConstants.PROPOSAL_STATUS_LOCKED
                                                                                                    )
                                                                                            
                                                                                                )
                                                                                            )
                                                                                     ]);
            //Loop over the new Opportunities
            for(Opportunity opp : newOpportunities) {
                
                //Check for Opportunity Stage
                if(setOppRecordTypeIds.contains(opp.RecordTypeId) && CPQConstants.SET_OPP_STAGE_CONTRACT_RECEIVED_SENT_TO_FINANCE_VALUES.contains(opp.StageName)
                    && (mapOldOpportunities == null || opp.StageName != mapOldOpportunities.get(opp.Id).StageName)
                    && opp.SBQQ__PrimaryQuote__c != null && !mapPrimaryProposals.containsKey(opp.SBQQ__PrimaryQuote__c)
                     //Added condition to bypass validation for profile 
                    && currentUserProfileId != null && !mapOfProfiles.containsKey(currentUserProfileId))
                    throw new CustomException(Label.CONTRACT_RECEIVED_SENT_TO_FINANCE_MSG);
                
            }
        }
    }
    
    /**
     *  @description    :   The method is used to update Amendment Type = 'Upsell' and Status = 'Activated Amended' when Opportunity is 
                            created via Amend button on Contract object (or Opportunity is created with Amended Contract).
     *
     *  @args           :   List<Opportunity>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - 05/11/2017 - CR-20170403-10807 
     *
     **/
    public static void updateStatusAndAmendmentTypeOnContract(List<Opportunity> newOpportunities){
        
        //Map to hold Contract records which should be update
        Map<Id, Contract> mapContracts = new Map<Id, Contract>();
        
        //Processing on the new records
        for(Opportunity opportunity : newOpportunities){
            
            //Checking whether Amended Contract is not null
            if(opportunity.SBQQ__AmendedContract__c != null)
                mapContracts.put(opportunity.SBQQ__AmendedContract__c, new Contract(Id = opportunity.SBQQ__AmendedContract__c,
                                                                        Amendment_Type__c = CPQConstants.CONTRACT_AMENDMENT_TYPE_UPSELL, Status = CPQConstants.CONTRACT_STATUS_ACTIVATED_AMENDED));
        }
        //Checking for map size
        if(mapContracts.size() > 0)
            update mapContracts.values();
    }
    
    /**
     *  @description    :   HC or EAB Continuation Opp is created:
     *                      Determine the record type of the selection for 'Previous Opportunity' (required field).  
     *                      If it is an HC or EAB Initiating or Continuation record type, copy the value of LOA Contract to the 'Renewed Contract' field.  This shoud be a Standard Contract record.
     *                      If it is an older record type, copy the value of Signed Opportunity Contract to the 'Previous Contract' field.  This should be a Contract ABC record."
     *
     *  @args           :   List<Opportunity>, Map<Id, Opportunity>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - 05/30/2017 - CR-20170403-10807 
     *
     **/    
    public static void updateRenewedContractAndPreviousContractOnContinuationOpp(List<Opportunity> newOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        //Get the Opportunity Record Types
        Map<String, Id> oppRecordTypeMap = Util.recordtypemap('Opportunity');
        
        //Set to hold the continuing record types
        Set<Id> setContinuingRecordTypes = new Set<Id>();
        
        //Get Continuing record types
        //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Continuing From Opportunity.
        //setContinuingRecordTypes.add(oppRecordTypeMap.get(CPQConstants.OPP_RECORD_TYPE_NAME_HC_CONTINUING));
        setContinuingRecordTypes.add(oppRecordTypeMap.get(CPQConstants.OPP_RECORD_TYPE_NAME_EAB_CONTINUING));
        
        //Set to hold the Previous Opportunity Ids
        Set<Id> setPreviousOppIds = new Set<Id>();
        
        //Loop over the new records
        for(Opportunity opp : newOpportunities) {
            
            //Check for appropriate condition to fire the trigger
            if(setContinuingRecordTypes.contains(opp.RecordTypeId) && opp.Previous_Opportunity__c != null
                && (mapOldOpportunities == null || opp.Previous_Opportunity__c != mapOldOpportunities.get(opp.Id).Previous_Opportunity__c))
                setPreviousOppIds.add(opp.Previous_Opportunity__c);
        }
        
        //Check for set
        if(setPreviousOppIds.size() > 0) {
            
            //Set to hld the all the new record types (continuing and initiating)
            Set<Id> setOppHCAndEABRecordTypes = new Set<Id>();
            
            //Get HC and EAB record types
            for(String hCAndEABRT : CPQConstants.SET_OPPORTUNITY_RECORDTYPE_NAMES)
                setOppHCAndEABRecordTypes.add(oppRecordTypeMap.get(hCAndEABRT));
        
        
            //SOQL over the Previous opportunity 
            Map<Id, Opportunity> mapPreviousOpportunities = new Map<Id, Opportunity>([Select Id, LOA_Contract__c, Signed_Opportunity_Contract__c,
                                                               RecordTypeId, RecordType.DeveloperName From Opportunity Where Id IN : setPreviousOppIds]);
            
            //Loop over the new records
            for(Opportunity opp : newOpportunities) {
                
                //Check for appropriate condition to fire the trigger
                if(setContinuingRecordTypes.contains(opp.RecordTypeId) && opp.Previous_Opportunity__c != null && mapPreviousOpportunities.containsKey(opp.Previous_Opportunity__c)) {
                    
                    //Get Previous Opportunity 
                    Opportunity previousOpp = mapPreviousOpportunities.get(opp.Previous_Opportunity__c);
                    
                    //Check record type
                    if(setOppHCAndEABRecordTypes.contains(previousOpp.RecordTypeId))
                        opp.SBQQ__RenewedContract__c = previousOpp.LOA_Contract__c;
                    else
                        opp.Previous_Contract__c = previousOpp.Signed_Opportunity_Contract__c;
                }
            }
        }
    }
    
     /**
     *  @description    :   
     * 
     *  @args           :   List<Opportunity>, Map<Id, Opportunity>
     *
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - 6/8/2017 - Abhinav Sharma - Q2C Phase 2 
     *
     **/  
     public static void updateActiveSubscriptionPeriodRenewalFieldValues(List<Opportunity> newListOpportunities, Map<Id,Opportunity> mapOldOpportunities) {
        
        //Set to hold RenewedContract ID
        Set<Id> setRenewedContractIds = new Set<Id>();
        
        //Set of Membership associate with Opportunities
        Set<Id> setMembership = new Set<Id>();        
        
        //Map to hold the Membership records to be updated
        Map<Id, Membership__c> mapMemberships = new Map<Id, Membership__c>();
        
        //Map to hold the Subscription Period records
        Map<Id, Subscription_Period__c> mapofContractrelatedSubscriptionPeriod = new Map<Id, Subscription_Period__c>(); 
        
        //Map of membership to update
        Map<Id, Membership__c> mapMembershipsGoingToBeUpdate = new Map<Id, Membership__c>();
      
        //Loop through the trigger.new
        for(Opportunity opp : newListOpportunities) {
            
            //Check criteand then populate the set with Id values
            if (opp.SBQQ__RenewedContract__c != null && opp.Membership__c != null && (opp.SBQQ__RenewedContract__c != mapOldOpportunities.get(opp.Id).SBQQ__RenewedContract__c
                || opp.Membership__c != mapOldOpportunities.get(opp.Id).Membership__c)) {
                setRenewedContractIds.add(opp.SBQQ__RenewedContract__c);
                setMembership.add(opp.Membership__c);
            }
        }
        
        //Checking set for size value
        if(setMembership.size() > 0) {
            //Map to hold the Membership records to be updated
            mapMemberships = new Map<Id, Membership__c>([Select ID, Active_Subscription_Period_Renewal__c FROM Membership__c 
                                                            WHERE ID IN : setMembership]);
        }
           
        //Checking set for size value
        if(setRenewedContractIds.size() > 0) {
            
            //Query on Subscription Period associated with Contracts
            for(Subscription_Period__c sb : [Select ID, Contract__c , Period_Start_Date__c, Period_End_Date__c
                                             FROM Subscription_Period__c 
                                             WHERE Contract__c IN : setRenewedContractIds
                                             ORDER BY CreatedDate ASC ]) {
                If(sb.Period_Start_Date__c <= System.Today() && sb.Period_End_Date__c >= System.Today()) 
                    mapofContractrelatedSubscriptionPeriod.put(sb.Contract__c, sb);                              
            }
        }
           
        //Checking map for size value
        if(mapMemberships.keySet().size() > 0) {
            
            //Loop through the trigger.new
            for(Opportunity op : [SELECT Id, Name, Membership__c, Active_Renewal__c, SBQQ__RenewedContract__c 
                                               FROM Opportunity 
                                               WHERE Membership__c != null 
                                               AND SBQQ__RenewedContract__c != null
                                               AND Membership__c IN: mapMemberships.keySet()
                                               AND Active_Renewal__c = true]) {
                
                       
                //Proceed further only and only if we are having differences in between values for the field on membership record
                if(mapMemberships != null && mapMemberships.get(op.Membership__c) != null 
                    && mapofContractrelatedSubscriptionPeriod.containsKey(op.SBQQ__RenewedContract__c) &&  
                    mapofContractrelatedSubscriptionPeriod.get(op.SBQQ__RenewedContract__c).Id != mapMemberships.get(op.Membership__c).Active_Subscription_Period_Renewal__c) {
                
                    //Updating field values on membership record and then adding it to the list to be update
                    mapMemberships.get(op.Membership__c).Active_Subscription_Period_Renewal__c = mapofContractrelatedSubscriptionPeriod.get(op.SBQQ__RenewedContract__c).Id;
                    mapMembershipsGoingToBeUpdate.put(op.Membership__c, mapMemberships.get(op.Membership__c));           
                }
            }

            //Check for the size and update the records
            if(mapMembershipsGoingToBeUpdate.values().size() > 0) {
                Util.BypassAllTriggers = true;
                update mapMembershipsGoingToBeUpdate.values();
                Util.BypassAllTriggers = false;
            }
        }              
    }
  /**
    * 
    *   @description    :   This method used to populate Program_Threshold_Value__c on opportunity 
    *
    *   @args           :   List<Opportunity> opportunities, Map<Id,Opportunity> mapOldOpportunity)
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created - 06/15/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807
    * 
    **/
    public static void updateThresholdValueOnOpportunity(List<Opportunity> opportunities, Map<Id,Opportunity> mapOldOpportunity) {
    
        //Set to hold product id
        Set<Id> setProposalIds = new Set<Id>();

        //Map to hold opportunity
        Map<Id,Opportunity> mapOfOpportunity = new Map<Id,Opportunity>();

        //Set of Record type Name
        Set<String> setRecordTypeName = new Set<String>();
        //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Initiating From Opportunity.
        //setRecordTypeName.add(CPQConstants.OPP_RECORD_TYPE_NAME_HC_INITIATING);
        setRecordTypeName.add(CPQConstants.OPP_RECORD_TYPE_NAME_EAB_INITIATING);
        //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Continuing From Opportunity.
        //setRecordTypeName.add(CPQConstants.OPP_RECORD_TYPE_NAME_HC_CONTINUING);
        setRecordTypeName.add(CPQConstants.OPP_RECORD_TYPE_NAME_EAB_CONTINUING);
        
        // get all record types on opportunity object
        Map<String, Id> oppRecordTypeMap = Util.recordtypemap('Opportunity');
        
        // get opportunity record types
        Map<Id, String> mapRecordTypes = new Map<Id, String>();
        for (String rtName : setRecordTypeName)
            mapRecordTypes.put(oppRecordTypeMap.get(rtName), rtName);

        //Loop[ through quotes lines
        for(Opportunity oppo : opportunities) {
    
            //Check condition
            if(oppo.SBQQ__PrimaryQuote__c != null && mapRecordTypes.containskey(oppo.recordTypeId) 
                && (mapOldOpportunity == null || oppo.SBQQ__PrimaryQuote__c != mapOldOpportunity.get(oppo.Id).SBQQ__PrimaryQuote__c ))
                setProposalIds.add(oppo.SBQQ__PrimaryQuote__c);
            
        }

        //Process if size is greater than zero
        if(setProposalIds.Size() >0) {

            //Map to hold quotes lines
            List<SBQQ__QuoteLine__c> existingquoteLines = [Select Id, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Primary__c, SBQQ__Product__c,
                                                                                        SBQQ__Product__r.Program__c, SBQQ__Product__r.Program__r.Large_Contract_Threshold__c,
                                                                                        SBQQ__Quote__r.SBQQ__Opportunity2__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.RecordType.DeveloperName
                                                                                        From SBQQ__QuoteLine__c Where SBQQ__Quote__c IN : setProposalIds 
                                                                                        AND SBQQ__Quote__r.SBQQ__Primary__c = true  
                                                                                        AND SBQQ__Product__r.Program__c != null 
                                                                                        Order by SBQQ__Product__r.Program__r.Large_Contract_Threshold__c  DESC ];

            //Process if size is greater than zero
            if(existingquoteLines.Size() >0) {

                //Loop through quote lines
                for(SBQQ__QuoteLine__c qL : existingquoteLines) {
    
                    if(!mapOfOpportunity.containsKey(qL.SBQQ__Quote__r.SBQQ__Opportunity2__c))
                        mapOfOpportunity.put(qL.SBQQ__Quote__r.SBQQ__Opportunity2__c, new Opportunity(Id =  qL.SBQQ__Quote__r.SBQQ__Opportunity2__c, Program_Threshold_Value__c = qL.SBQQ__Product__r.Program__r.Large_Contract_Threshold__c));
                    
                }
    
                //Process if size of map is greater than zero
                if(mapOfOpportunity.Size()>0) {
                    
                    //Bypassing triggers
                    Util.byPassAllTriggers = true;
                    
                    //Update cases
                    update mapOfOpportunity.values();

                    //Enabling triggers
                    Util.byPassAllTriggers = false;                 
                }
            }   
        }
    }
  
  /**
   * 
   *   @description    :   This method used to populate start date and end date 
   *
   *   @args           :  List<Opportunity> opportunities, Map<Id,Opportunity> mapOfOpportunity)
   *
   *   @return         :   void
   *
   *   @revision Log   :   V1.1 - Created - 06/30/2017 - Subhash Garhwal 
   * 
   **/
  public static void populateStartandEndDate(List<Opportunity> opportunities, Map<Id,Opportunity> mapOfOpportunity) {
    
      //Get the Opportunity Record Types
      Map<String, Id> oppRecordTypeMap = Util.recordtypemap('Opportunity');
        
      //Set to hold the continuing/Initiating record types
      Set<Id> setOppContinuingInitiatingRecordTypes = new Set<Id>();
        
      //Get Continuing record types
      //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Continuing From Opportunity.
      //setOppContinuingInitiatingRecordTypes.add(oppRecordTypeMap.get(CPQConstants.OPP_RECORD_TYPE_NAME_HC_CONTINUING));
      setOppContinuingInitiatingRecordTypes.add(oppRecordTypeMap.get(CPQConstants.OPP_RECORD_TYPE_NAME_EAB_CONTINUING));
      //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Initiating From Opportunity.
      //setOppContinuingInitiatingRecordTypes.add(oppRecordTypeMap.get(CPQConstants.OPP_RECORD_TYPE_NAME_HC_INITIATING));
      setOppContinuingInitiatingRecordTypes.add(oppRecordTypeMap.get(CPQConstants.OPP_RECORD_TYPE_NAME_EAB_INITIATING));

      //Set to hold LOA  contract Is
      Set<Id> setContractLOAIds = new Set<Id>(); 

      //Loop through Opportunity
      for(Opportunity opp : opportunities) {
		
		//Process If condition is true
          	if(opp.LOA_Contract__c != null && setOppContinuingInitiatingRecordTypes.contains(opp.recordTypeId)
        	&& (mapOfOpportunity == null || opp.LOA_Contract__c != mapOfOpportunity.get(opp.Id).LOA_Contract__c ))
            		setContractLOAIds.add(opp.LOA_Contract__c);
      	}
    
      	//Process if Condition is true
      	if(setContractLOAIds.Size() > 0 ) {
  
		//Map to hold Contract
          	Map<Id, Contract> mapContracts = new Map<Id, Contract>([Select Id, StartDate, EndDate From Contract Where Id IN : setContractLOAIds ]);
      
          	//Loop through Opportunity
          	for(Opportunity opp : opportunities) {
  
        		//Process if condition is true
            		if(mapContracts.containsKey(opp.LOA_Contract__c)) {  
          
          			opp.Start__c = mapContracts.get(opp.LOA_Contract__c).StartDate;
                		opp.End__c = mapContracts.get(opp.LOA_Contract__c).EndDate;
        		}
          	}
      	  }
  }
  
  //V_1.56 - Merged By - Rajeev Jain - 07/05/2017 - Upto Here 
  /**
     * 
     *   @description    :   This method used to thrown an error if no any proposal is there ,while changing stageName on opportunity
     *
     *   @args           :   List<Opportunity> opportunities, Map<Id,Opportunity> mapOfOpportunity)
     *
     *   @return         :   void
     *
     *   @revision Log   :   V1.1 - Created - 07/13/2017 - Subhash Garhwal
     *                       V1.2 - Modified - 08/01/2017 - Colin McGloin - Issue--CR10808--QA--00005272 - Corrected Issue where new Opps could skip Stage validation (Added logic on Insert as well as Update)
     *             V1.3 - Modified By - Subhash Garhwal - 09/28/2017 - Issue--CR11458--QA--00005907 - Bypass validation for Continuing Opportunities
     *              V1.4 - Modified By - Subhash garhwal - 04/09/2017 - Bypass the validation for 'Closed Lost', 'Dropped', 'Void', 'Closed' Stage. 
     *        V1.5 - Modified By - Victor Hanson - 08/22/2018 - Bypass the validatoin for MQL, MQL Rejected, Honorary, Merged, Closed Won, Closed Lost
     **/
   public static void preventOpportunityStageNameToChange(List<Opportunity> newOpportunities, Map<Id,Opportunity> mapOldOpportunities) {  

    //Set to hold opportunity Id
    set<Id> setOpportunityId = new set<Id>();

      //Get all record types on opportunity object
      Map<String, Id> mapOppRecordTypes = Util.recordtypemap('Opportunity');

      //IDs for checking against in Insert Scenarios
      Id eabInitID = mapOppRecordTypes.get(CPQConstants.OPP_RECORD_TYPE_NAME_EAB_INITIATING);
      
      //Subhash Garhwal - 09/28/2017 - Issue--CR11458--QA--00005907 - Comment
      //Id eabContID = mapOppRecordTypes.get(CPQConstants.OPP_RECORD_TYPE_NAME_EAB_CONTINUING);
        
      //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Initiating From Opportunity.
      //Add all Ids into one set for comparing on update scenario
      //Subhash Garhwal - 09/28/2017 - Issue--CR11458--QA--00005907 - Comment
      Set<Id> q2cOppIds = new set<Id> {eabInitID /*, eabContID, hcInitID , hcContID*/};
         
    //Loop through Opportunity
    for(Opportunity opp : newOpportunities) {
            
        if (opp.StageName != null && !CPQConstants.OPP_STAGES_WITHOUT_PROPOSAL.contains(opp.StageName)) {
          //Insert Scenarios first
          if (mapOldOpportunities == null){
  
            //EAB Initiating Opp Insert Scenario
            if(opp.RecordTypeId != null && eabInitID == opp.RecordTypeId && opp.SBQQ__AmendedContract__c == null) {
              setOpportunityId.add(opp.Id);
            }
          }
  
          else if (mapOldOpportunities != null){
  
            //EAB Update Scenario
            if(opp.RecordTypeId != null && q2cOppIds.contains(opp.RecordTypeId)
              && opp.SBQQ__AmendedContract__c == null && opp.StageName != mapOldOpportunities.get(opp.Id).StageName) 
            {
                setOpportunityId.add(opp.Id);
            }
  
          }
        }
    } 

    //Process if condition is true
    if(setOpportunityId.Size() > 0) {
        
       //CR-20180205-11952 - Modified By Subhash Garhwal - 04/09/2018 - Start From here 
       //Set to hold the Opportunity Stage for those we need to bypass the custom Exception - 
       Set<String> setOppStageToBeBypassed = new Set<String>{'Closed Lost', 'Dropped', 'Void', 'Closed'};
        
       //Loop thorigh quote
        for(Opportunity opportunity : [Select Id, (select Id from SBQQ__Quotes2__r Limit 1) From Opportunity
                         Where Id IN: setOpportunityId 
                           AND StageName NOT IN :CPQConstants.OPP_STAGES_WITHOUT_PROPOSAL]){
        
            //CR-20180205-11952 - Modified By Subhash Garhwal - 04/09/2018 - End  here 
            
      if(opportunity.SBQQ__Quotes2__r.Size() == 0)
        throw new customException(Label.PROPOSAL_REQUIRED_TO_CHANGED_STAGE_ON_OPPORTUNITY);
        }
    }
   }
   
  //Commented Relationship_Advisor__c(Commented the whole Method) - By Mahendra Swarnkar - spring clean up - 04/29/2019
  //V_1.58 - Merged By - Rajeev Jain - 07/28/2017 - Merged the Release 60 changes with Q2c Beta + Revenue Management - Starts here
  //V_1.57 - Added by - Mahendra Swarnkar - 07/05/2017 - CR-20170616-11008 - Added a new method - populateTVMFieldsOnopportunityFromMembership
    /**
     *  @description    :   Method to populate TVM fields On opportunity record from the related Membership record. 
     * 
     *  @args           :   List of opportunities, Map of old opprtunities
     * 
     *  @return         :   void
     * 
    **/
    public static void populateTVMFieldsOnOpportunityFromMembership(List<Opportunity> newOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
      
    }
    //V_1.58 - Merged By - Rajeev Jain - 07/28/2017 - Merged the Release 60 changes with Q2c Beta + Revenue Management - Ends here

    /**
     *  @description    :   Method used to populate the Entity field value
     *                      1) Populate the Entity__c = HC for following Member Support record types:- 
     *                          HC Continuing, HC Initiating 
     *                      2) Populate the Entity__c = EAB for following Member Support record types:- 
     *                           EAB Continuing, EAB Initiating, Royall 
     *                      3) Populate the Entity__c = Owner.Entity__c for following Opportunity record types:- 
     *                          Contract LOA 
     *                      4) Related Program - Share based on the Entity set on related Program(using an Entity field on Opportunity set via automation):
     *                          Consulting & Management', 'PT Contranct Maintenance', 'PT Contract Renewal', 'PT Marketing', 'RI AM First Year Opp', 'RI AM Standard Opp', 'RI Marketing', 'TD AM Standard Opp 
     *                      5) Parent Opportunity - Share based on the Entity field set on the parent Opportunity record (using an Entity field on Opportunity set via automation): 
     *                          'Merged/Migrated', Program - Consulting & Management', 'Program - PT Contract Maintenance', 'Program - PT Contract Renewal', 'Program - PT Marketing', 'Program - RI AM First Year Opp', 'Program - RI AM Standard Opp', 'Program - RI Marketing'
     * 
     *  @args           :   List of new Opportunity records, Map of old Opportunity records
     * 
     *  @return         :   void
     * 
     *  @Revision Log   :   V1.0 - Created By - Mahendra Swarnkar - 10/09/2017 - CR-20170929-11624 - Apollo Release
     **/
    public static void populateEntityField(List<Opportunity> newOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        
        //return immediately if we are bypassing entity population
        if (BYPASSENTITYLOGIC || Util.bypassEntityPopulation) return;
        
        //Set to hold the Opportunity record type names for EAB
        Set<String> setRTypeNameForEAB = new Set<String>{'EAB Continuing', 'EAB Initiating', 'Royall'} ;
                    
        //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Consulting & Management,RI AM First Year Opp,  RI AM Standard Opp,TD AM Standard Opp From Opportunity.
        //Set to hold the Opportunity record type names for which ENtity will be populated on the base of Owner Entity
        Set<String> setRTypeForRelatedProgram = new Set<String>{/*'Consulting & Management',*/ 'PT Contract Maintenance', 'PT Contract Renewal', 'PT Marketing', /*'RI AM First Year Opp', 'RI AM Standard Opp',*/ 'RI Marketing'/*, 'TD AM Standard Opp'*/};
                    
        //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : Program – Consulting & Management, Program – PT Contract Maintenance,Program – PT Contract Renewal,Program – PT Marketing,Program – RI Marketing,Program – RI AM First Year Opp,Program – RI AM Standard Opp From Opportunity.
        //Set to hold the Opportunity record type names for which ENtity will be populated on the base of Owner Entity
        Set<String> setRTypeForRelatedOpportunity = new Set<String>{'Merged/Migrated'/*, 'Program – Consulting & Management', 'Program – PT Contract Maintenance', 'Program – PT Contract Renewal', 'Program – PT Marketing', 'Program – RI AM First Year Opp', 'Program – RI AM Standard Opp', 'Program – RI Marketing'*/};
                        
        //Set Opportunity Ids
        Set<Id> setOppIds = new Set<Id>(); 
        
        //Map to hold the Opportunity RecordTypeId with recordType Name
        Map<Id, String> mapRTypeIdWithRTypeDeveloperName = Util.mapRecordTypes('Opportunity');
        
        //Set to hold the Program Ids
        Set<Id> setProgramIds = new Set<Id>();
        
        //Set to hold the Owner Ids
        Set<Id> setOwnerIds = new Set<Id>();
        
        //Set to hold the Parent Opp Ids
        Set<Id> setParentOppIds = new Set<Id>();
        
        //Loop over the new Opportunity records
        for(Opportunity oppor : newOpportunities) {
            
            //Check for Program
            if(oppor.Program__c != null)
                setProgramIds.add(oppor.Program__c);
            
            //Check for Owner
            if(oppor.OwnerId != null)
                setOwnerIds.add(oppor.OwnerId);  
            
            //Check for Parent Opps
            if(oppor.Parent_Opportunity__c != null)
                setParentOppIds.add(oppor.Parent_Opportunity__c);    
        }
        
        //Added By Subhash garhwal - 05/28/2020 - 101 Issue on Amendment --- Starts from here 
        //Map to hold the Programs
        Map<Id, Program__c> mapPrograms = new Map<Id, Program__c>();
        if(setProgramIds.size() > 0)
            mapPrograms = new Map<Id, Program__c>([Select Id, Entity__c From Program__c Where Id IN : setProgramIds]);
        
        //Map to hold the User
         Map<Id, User> mapUsers = new Map<Id, User>();
        if(setOwnerIds.size() > 0)
            mapUsers = new Map<Id, User>([Select Id, Entity__c From User Where Id IN : setOwnerIds]);
        
        //Map to hold the Parent Opp
        Map<Id, Opportunity> mapParentOpps = new Map<Id, Opportunity>();
        if(setParentOppIds.size() > 0)
            mapParentOpps = new Map<Id, Opportunity>([Select Id, Entity__c From Opportunity Where Id IN : setParentOppIds]);
        //Added By Subhash garhwal - 05/28/2020 - 101 Issue on Amendment --- End here 
        
        //Loop over the new Opportunity records
        for(Opportunity oppo : newOpportunities) {
            
            //VH 11/6/17 - Issue--CR11624--QA--00007346 - Check for Entity Override
            if(String.isNotBlank(oppo.Entity_Override__c)) {
                oppo.Entity__c = oppo.Entity_Override__c;
            }
            else {
                //Check for the record type
                if(mapRTypeIdWithRTypeDeveloperName != null && mapRTypeIdWithRTypeDeveloperName.size() > 0 && oppo.RecordTypeId != null && mapRTypeIdWithRTypeDeveloperName.containsKey(oppo.RecordTypeId) ) {
                    
                    
                    //2) setRTypeNameForEAB
                    if(setRTypeNameForEAB.contains(mapRTypeIdWithRTypeDeveloperName.get(oppo.RecordTypeId)))
                        oppo.Entity__c = 'EAB';
                    
                    //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Contract LOA From Opportunity.
                    //3) setRTypeForOwnerEntity
                    /*if(setRTypeForOwnerEntity.contains(mapRTypeIdWithRTypeDeveloperName.get(oppo.RecordTypeId)) && mapUsers.containsKey(oppo.OwnerId))
                        oppo.Entity__c = mapUsers.get(oppo.OwnerId).Entity__c;*/
                    
                    //4) setRTypeForRelatedProgram
                    if(setRTypeForRelatedProgram.contains(mapRTypeIdWithRTypeDeveloperName.get(oppo.RecordTypeId)) && mapPrograms.containsKey(oppo.Program__c))
                        oppo.Entity__c = mapPrograms.get(oppo.Program__c).Entity__c;
                    
                    //5) setRTypeForRelatedOpportunity
                    if(setRTypeForRelatedOpportunity.contains(mapRTypeIdWithRTypeDeveloperName.get(oppo.RecordTypeId)) && oppo.Parent_Opportunity__c != null && mapParentOpps.containsKey(oppo.Parent_Opportunity__c))
                        oppo.Entity__c = mapParentOpps.get(oppo.Parent_Opportunity__c).Entity__c;
                }
            }
        }
        
        BYPASSENTITYLOGIC = true;
    } 
    
    /**
     * 
     *   @description    :   This method will check if Opportunity record type is changed set Previous record type name in Previous Record Type field.
     *
     *   @args           :   List<Opportunity> opportunities, Map<Id,Opportunity> mapOfOpportunity)
     *
     *   @return         :   void
     *
     *   @revision Log   :   V1.1 - Created - 07/10/2018 - Subhash Garhwal - CR-20180205-11986
     **/
   public static void setPreviosuRecordType(List<Opportunity> newOpportunities, Map<Id,Opportunity> mapOldOpportunities) {  
   
       //Map to hold the Opportunity RecordTypeId with recordType Name
        Map<Id, String> mapRTypeIdWithRTypeDeveloperName = Util.mapRecordTypes('Opportunity');
        
       //Loop over the opportunities
       for(Opportunity opp : newOpportunities) {
         
         //Check for Record Type change to merged/migrated
         if(opp.RecordTypeId != null && mapOldOpportunities != null && opp.RecordTypeId == CPQConstants.OPP_RT_ID_MERGED && opp.RecordTypeId != mapOldOpportunities.get(opp.Id).RecordTypeId) {
           
           //Update Previous Record Type field on Opportunity
           opp.Previous_Record_Type__c = mapRTypeIdWithRTypeDeveloperName.get(mapOldOpportunities.get(opp.Id).RecordTypeId);
         } else if(opp.RecordTypeId != CPQConstants.OPP_RT_ID_MERGED)
           opp.Previous_Record_Type__c = null;
       }
   }

    
   /**
     *  @description    :   Method to Populate the Initial Activity Date (Planned) Field on the Opportunity.
     * 
     *  @args           :   List of opportunities
     * 
     *  @return         :   void
     * 
     * Created By       :   Abhinav Sharma - 09/11/2018 - CR-20180910-12583
    **/
    public static void updateInitialActivityDatePlanned(List<Opportunity> newOpps) {
    
        //Checking the size of the List
        if(newOpps != null && newOpps.size() > 0) {
            
            //Loop through the List
            for(Opportunity opp : newOpps) {
                
                //checking for the Initial visit Date
                if(opp.Initial_Activity_Date__c != null && opp.Initial_Activity_Date_Planned__c == null) {
                  
                    //This logic should run for a record only when it got the First Activity on it.
                    //Just Update the Initial activity Date Planned. 
                    opp.Initial_Activity_Date_Planned__c = opp.Initial_Activity_Date__c;
                } 
            }
        }        
    }
    
    /**
     *  @description    :   Method to Check if the 3 Fields on Opportunity got changed. 
     * 
     *  @args           :   List of opportunities, Map of Opportunity
     * 
     *  @return         :   void
     * 
     * Created By       :   Created By Abhinav sharma - CR-20181016-12674 - 10/17/2018 
    **/
    public static void syncSMERequestWithOpportunity(List<Opportunity> newOpps, Map<Id,Opportunity> oldMapOpportunities ) {
        
        //Set to hold the opportunity ids
        set<Id> setOpportunityIds = new set<Id>();
        
        //Check for the size of the list 
        if(newOpps != null && newOpps.size() > 0) {
        
            //loop through the opportunity
            for(Opportunity opp : newOpps) {
            
                //Checking for the changes values. 
                if(oldMapOpportunities != null 
                 && (oldMapOpportunities.get(opp.Id).AccountId != opp.AccountId
                 ||  oldMapOpportunities.get(opp.Id).Program__c != opp.Program__c
                 ||  oldMapOpportunities.get(opp.Id).Membership__c != opp.Membership__c)) {
                           
                    //Filling set with the Opportubnity ids on which the Account/Membership or program changed. 
                     setOpportunityIds.add(opp.Id);             
               }
            }
            
            //List to hold the PSS Request that needs to be updated. 
            List<Pss_Request__c> pssRequestToBeUpdated = new List<Pss_Request__c>();
                
            //check the size of set
            if(setOpportunityIds != null && setOpportunityIds.size() > 0) {
                
               //loop on the Opportunity. 
               for(Opportunity op : [Select Id, AccountId, Membership__c, Program__c, 
                                    (Select Id, Institution__c, Membership__c, Program__c From PSS_Requests__r) 
                                     From Opportunity where Id IN: setOpportunityIds]) {
                
                    //Checking for the null of Pss Request
                    if(op.PSS_Requests__r != null && op.PSS_Requests__r.size() > 0) {
                        
                        //Loop on the PSS request
                        for(Pss_Request__c pssRequest :  op.PSS_Requests__r) {
                            
                            //Add the Values in the List of PSS  
                            pssRequestToBeUpdated.add(new Pss_Request__c (Id = pssRequest.ID, Institution__c = op.AccountId, 
                                                      Membership__c = op.Membership__c, 
                                                     Program__c = op.Program__c));
                        }
                   }
               }
                
                //Check the size of variable - pssRequestToBeUpdated
                if(pssRequestToBeUpdated != null && pssRequestToBeUpdated.size() > 0) {
                    //Bypassing all the triggers =
                    Util.ByPassAllTriggers = true; 
                    update pssRequestToBeUpdated;
                    Util.ByPassAllTriggers = false;
                }
            }
        }
    }
    
   /**
     *  @description    :   Method to Check if Contract Signature Date is blank while contracting ES opportunity, Then throw error message. 
     * 
     *  @args           :   List of opportunities, Map of Opportunity
     * 
     *  @return         :   void
     * 
     * Created By       :   Created By Subhash Garhwal - 12/20/2018 - CR-20181019-12685
    **/
    public static void validateContractSignatureDateForESOpportunties(List<Opportunity> newOpps, Map<Id,Opportunity> oldMapOpportunities ) {
   
     //Set of proposal Ids
     Set<Id> setProposalIds = new Set<Id> ();
     
     //Opportunity stages while contracting opportiny
     //Set<String> setOpportunityStageForContract = new Set<String> {'Contract Received - Send to Finance', 'Contract Received - Sent to Finance/Credited', 'Contract Received - Sent to Finance/Booked'};
     
     //Check for the size of the list 
        if(newOpps != null && newOpps.size() > 0) {
          
          //loop through the opportunity
            for(Opportunity opp : newOpps) {
            
                //Checking for the Conditions. 
                if( opp.Contract_Signature_Date__c == null && opp.SBQQ__PrimaryQuote__c != null && opp.SBQQ__Contracted__c == true //&& setOpportunityStageForContract.contains(opp.StageName)
                  && (opp.RecordTypeId == CPQConstants.OPP_RT_ID_EAB_INITIATING || opp.RecordTypeId == CPQConstants.OPP_RT_ID_EAB_CONTINUING)
                  && oldMapOpportunities != null && opp.SBQQ__Contracted__c != oldMapOpportunities.get(opp.Id).SBQQ__Contracted__c ) {
                           
          //Populate the set with the Proposal Ids. 
          setProposalIds.add(opp.SBQQ__PrimaryQuote__c);
               }
            }
        }
        
        //Check for size
      if(setProposalIds.size() > 0){
        
        //Flag to check if opportunity belongs to Enrollment Services products.
        Boolean IsBelongsToEnRollmentServices = false;
        
        //query main Quotelines on the proposals
        for(SBQQ__QuoteLine__c qLine : [Select Id, SBQQ__ProductFamily__c From SBQQ__QuoteLine__c Where SBQQ__Quote__c IN : setProposalIds AND SBQQ__RequiredBy__c = null]){
          
          //Check for the Product Family
          if(qLine.SBQQ__ProductFamily__c != null && (qLine.SBQQ__ProductFamily__c == CPQConstants.ES_PRODUCT_FAMILY || qLine.SBQQ__ProductFamily__c == CPQConstants.ES_ALR_PRODUCT_FAMILY)) {
            
            //Set flag to true
            IsBelongsToEnRollmentServices = true;
            
            //Break the loop
            break;
          }  
        }  
        
        //Throw Error message to user if Contract Signature Date is blank while contracting ES opportunity
        if(IsBelongsToEnRollmentServices ){
          throw new CustomException('Please populate the \"Contract Signature Date\" before contracting the opportunity');
        }
      }
    }
    
    /**
    *  @description    :  Method to update opportunity name in case of EAb initiating record type
    * 
    *  @args           :   List of opportunities, Map of Opportunity
    * 
    *  @return         :   void
    * 
    * Created By       :   Created By Rajeev jain - CR-20181008-12649 - 13/03/2019
    **/
    
    public static integer count =0;
    public static void createInitiatingOpportunityName(List<Opportunity> newOpps, Map<Id,Opportunity> oldMapOpportunities){
        count++;
        if(AccountTriggerHelper.bypass_createInitiatingOpportunityName == false){
            
            Set<Id> accountIds = new Set<Id>();
            
            Map<Id, Account> mapAccounts;
            
            Map<Id, User> mapUser;
            
            Set<Id> users = new Set<Id>();
            
            Final String seperator = ' - ';
            
            
            //get account and user realted to Opportunity
            for(Opportunity opp : newOpps){
                
                If(opp.RecordTypeId == CPQConstants.OPP_RT_ID_EAB_INITIATING ){
                    
                    if(oldMapOpportunities == null ||oldMapOpportunities.get(opp.id).AccountId != opp.AccountId 
                       || oldMapOpportunities.get(opp.id).Opportunity_Products__c != opp.Opportunity_Products__c
                       || oldMapOpportunities.get(opp.id).OwnerId != opp.OwnerId || oldMapOpportunities.get(opp.id).CloseDate != opp.CloseDate  
                       || opp.RecordTypeId != oldMapOpportunities.get(opp.Id).RecordTypeId ||
                       (opp.name !=  null && opp.name != '' && opp.name.contains(CPQConstants.OPP_INITIATING_RECORD_TYPE_SUFFIX) == false) ){
                                                      
                           accountIds.add(opp.AccountId);  
                           users.add(opp.OwnerId);
                           
                       }
                }
            }
            
            //Get list of account for respective opportunities
            if(accountIds.size() > 0)
                mapAccounts = new Map<Id, Account>([SELECT Id , Account_Formal_Name__c,Primary_State_Province__c FROM Account WHERE Id IN : accountIds ]);
            
            If(users.size() > 0)  
                mapUser = new Map<id, User>([SELECT Id , lastName FROM User WHERE Id IN : users ]); 
            
            for(Opportunity opp : newOpps){
                
                //Check for update and insert 
                If(opp.RecordTypeId == CPQConstants.OPP_RT_ID_EAB_INITIATING  ){

                    if(oldMapOpportunities == null ||oldMapOpportunities.get(opp.Id).AccountId != opp.AccountId 
                       || oldMapOpportunities.get(opp.Id).Opportunity_Products__c != opp.Opportunity_Products__c
                       || oldMapOpportunities.get(opp.Id).OwnerId != opp.OwnerId || oldMapOpportunities.get(opp.Id).CloseDate != opp.CloseDate 
                       || oldMapOpportunities.get(opp.Id).Opportunity_Products__c != opp.Opportunity_Products__c
                       || opp.RecordTypeId != oldMapOpportunities.get(opp.Id).RecordTypeId
                       || (opp.name !=  null && opp.name != '' && opp.name.contains(CPQConstants.OPP_INITIATING_RECORD_TYPE_SUFFIX) == false) ){
                           
                           String opportunityName = '';
                           
                           //Add account formal name
                           if(mapAccounts.containsKey(opp.AccountId) && mapAccounts.get(opp.AccountId).Account_Formal_Name__c != null 
                              && mapAccounts.get(opp.AccountId).Account_Formal_Name__c != ''){
                                  
                                  
                                  if(mapAccounts.get(opp.AccountId).Account_Formal_Name__c.length() <= 50){
                                      
                                      opportunityName += mapAccounts.get(opp.AccountId).Account_Formal_Name__c + seperator;
                                  }
                                  else{
                                      
                                      opportunityName += mapAccounts.get(opp.AccountId).Account_Formal_Name__c.mid(0, 50)+ seperator;
                                  }
                              }
                           
                           //Add Account Primary_State_Province__c
                           if( mapAccounts.containsKey(opp.AccountId) && mapAccounts.get(opp.AccountId).Primary_State_Province__c != null 
                              && mapAccounts.get(opp.AccountId).Primary_State_Province__c != ''){
                                  
                                  if(mapAccounts.get(opp.AccountId).Primary_State_Province__c.length() <= 2){
                                      
                                      if(mapAccounts.containsKey(opp.AccountId))
                                          opportunityName += mapAccounts.get(opp.AccountId).Primary_State_Province__c + seperator;
                                      
                                  }
                                  else{
                                      
                                      if(mapAccounts.containsKey(opp.AccountId))
                                          opportunityName += mapAccounts.get(opp.AccountId).Primary_State_Province__c.mid(0, 2) + seperator;
                                  }
                              }
                           
                           //Add record type name
                           opportunityName += CPQConstants.OPP_INITIATING_RECORD_TYPE_SUFFIX + seperator;
                           
                           //System.assert(false,opp.OwnerId);
                           
                           //Adding last name of owner 
                           if(opp.OwnerId != null ){
                               
                               
                               if(mapUser.containsKey(opp.OwnerId)){
                                   
                                   String ownerLastName = mapUser.get(opp.OwnerId).lastName;
                                   
                                   if(ownerLastName.length() < 15)                        
                                       opportunityName +=  ownerLastName + seperator;
                                   else
                                       opportunityName +=  ownerLastName.mid(0, 15) + seperator;
                                   
                               }
                           }
                           
                           //Add opportunity product
                           if(opp.Opportunity_Products__c != null && opp.Opportunity_Products__c != ''){
                               
                               String[] oppProducts = opp.Opportunity_Products__c.split(';');
                               
                               if(oppProducts.size() == 1){
                                   
                                   opportunityName += oppProducts[0] + seperator;
                                   
                               }
                               else{
                                   
                                   opportunityName += 'Multi ('+oppProducts[0]+ '+)'+ seperator;
                               }
                           }
                           
                           //Add close date year
                           if(opp.CloseDate != null ){
                               
                               opportunityName += opp.CloseDate.year();
                           }
                           
                           opp.name = opportunityName;
                           
                           
                       }
                }
            }
        }
    } 

//Opp
    public static void updateaOpportunityPrimaryOnContact(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldMapOpportunities) {
        
        //Set to hold the Contact Id (Opportunity.Main_Contact__c)
        Set<Id> setContactIds = new Set<Id>();
        
        
        //loop on the Opportunity.
        for(Opportunity opp : newOpportunities != null ? newOpportunities : oldMapOpportunities.values()) {
            
            //check for Insert, Update, delete case. 
            if(oldMapOpportunities == null || (oldMapOpportunities.get(opp.Id).IsClosed != opp.IsClosed 
                || oldMapOpportunities.get(opp.Id).Main_Contact__c != opp.Main_Contact__c 
                                                || newOpportunities == null)) {
                                                    
                //Fill the set with the Main contact Id.
                setContactIds.add(opp.Main_Contact__c);
                                                    
               //Check for the Main Contact Change so we can make the relevent updates on the older Contact as well. 
               if(oldMapOpportunities != null && oldMapOpportunities.get(opp.Id).Main_Contact__c != opp.Main_Contact__c)
                   setContactIds.add(oldMapOpportunities.get(opp.Id).Main_Contact__c);
            }
        }
        
        //Check the size of set. 
        if(setContactIds.size() > 0) {
            
            //Enqueuing Job.
            System.enqueueJob(new Enqueue_CheckContactPrimaryOpportunity(setContactIds));  
        }    
    }
    
    /**
        *  @description    :  This method is used to check the Opportunity - Closed_Opp_Comments__c  
        *                       Field value when Opp stage is Changing to close lost. 
        * 
        *  @args           :   List of opportunities, Map of Opportunity
        * 
        *  @return         :   void
        * 
        * Created By       :   Created By Dipesh Gupta - 07/02/2019 - CR-20190226-12902
        *                      Modified By - Neha Sharma - 2/03/2021 - CR-20210128-14851
    **/    
    public static void validateOppFieldOnCloseLost (List<Opportunity> newOpps, Map<Id, Opportunity> oldMapOpps) {
        
        String EAB_INITIATING_RTYPE = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('EAB Initiating').getRecordTypeId();
        String ROYALL_RTYPE = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royall').getRecordTypeId();
        //Modified By - Neha Sharma - 2/03/2021 - CR-20210128-14851 - check for custom permission
        Boolean hasPermission = CoreUtilities.getCompVisibility('Initiating_Opp_Dataloader_Permission'); 
        
        //Check for the Stage change of Opportunity. 
        for(Opportunity opp : newOpps) {
            
            //Modified By - Neha Sharma - 2/03/2021 - CR-20210128-14851 - Added the check of custom permission
            //Check for the Stage change. 
            if((opp.RecordtypeId == EAB_INITIATING_RTYPE || opp.RecordtypeId == ROYALL_RTYPE) && hasPermission == false && opp.StageName == 'Closed Lost'
                 && (oldMapOpps == null || ( oldMapOpps !=null    
                                            && opp.StageName != oldMapOpps.get(opp.Id).StageName))) {
                
                //Check for the Closed_Opp_Comments__c if null then Diff Message 
                //and if the length is lesser than 50 char then show a diff Message. 
                if(String.isBlank(opp.Closed_Opp_Comments__c))  
                    opp.Closed_Opp_Comments__c.addError(Label.Closed_Opp_Comments_Rqd);
                                                
                if(String.isNotBlank(opp.Closed_Opp_Comments__c) && opp.Closed_Opp_Comments__c.length() <= 50 )  
                    opp.Closed_Opp_Comments__c.addError(Label.Closed_Opp_Comments_Min_Length);
             }
        }    
    }
    
    //Added By Abhinav Sharma - 07/10/2020 - CR-20200710-14288  - Taking logic from PB_Opportunity Process Builder to the trigger.  
    //Method to populate the Opportunity Probability Date. 
    public static void updateProbabilityDate(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldMapOpportunities) {
        
        Set<Integer> setOfProbabilities = new Set<Integer>{5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 70, 80, 90, 100 };
        Set<String> setRenewalLikelyHood = new Set<String> {'0%', '20%', '40%', '60%', '80%', '95%'};
	String OPP_RECORDTYPE_ROYALL =  Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royall').getRecordTypeId();
        
        //Loop on the Opportunity. 
        for(Opportunity opp : newOpportunities) {
            
            //Check if the Renewal Likelyhood. 
            if(String.isNotBlank(opp.Renewal_Likelihood__c) && setRenewalLikelyHood.contains(opp.Renewal_Likelihood__c) && !opp.IsWon && opp.RecordTypeId !=  OPP_RECORDTYPE_ROYALL){
            	
                Integer probability = null;
                
                //Check Renewal Likelyhood and Do the needfuls. 
                if(opp.Renewal_Likelihood__c == '0%')
                    probability = 0;
                else if(opp.Renewal_Likelihood__c == '20%')
                    probability = 20;
                else if(opp.Renewal_Likelihood__c == '40%')
                    probability = 40;
                else if(opp.Renewal_Likelihood__c == '60%')
                    probability = 60;
                else if(opp.Renewal_Likelihood__c == '80%')
                    probability = 80;
                else if(opp.Renewal_Likelihood__c == '95%')
                    probability = 95;
                
                if(probability != null)
                    opp.Probability = probability;
            }
             
            if(oldMapOpportunities == null || (oldMapOpportunities != null && oldMapOpportunities.get(opp.Id).Probability != opp.Probability)) {
                
                Integer prob = Integer.valueOf(opp.Probability);
                
                //Check conditions for the Probability. 
                if(setOfProbabilities.contains(prob))
                    opp.Probability_Field_Update__c = Date.Today();
            }
        }
    }

    /**
     *  @description    :  This method is used to populate various opportunity fields. this is the replacement of PB_OPportunity Process Builder Due to SOQL 101 Error.
     * 
     *  @args           :   List of opportunities, Map of Opportunity
     * 
     *  @return         :   void
     * 
     * Created By       :   Subhash Garhwal 08/12/2020 - CR-20200812-14427 
    **/   
    public static void populateOpportunityFieldsOnBeforeTrigger(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldMapOpportunities) {
    	
        // set of stages name
        Set<String> setOpportunityStageNames = new Set<String>{CPQConstants.OPPORTUNITY_STAGE_CLOSED_WON, CPQConstants.OPPORTUNITY_STAGE_HONORARY,
                                                        CPQConstants.OPPORTUNITY_STAGENAME_CLOSED, CPQConstants.OPPORTUNITY_STAGE_CLOSED_LOST, 
                                                        Constants.STAGE_OPPORTUNITY_DROPPED, Constants.STAGE_OPPORTUNITY_VOID,
                                                        Constants.DISQUALIFIED, Constants.STATUS_ATL 
            							                };
		
	Set<Id> setContractIds = new Set<Id>();
		
	Set<Id> setOfMembershipIds = new Set<Id>();
        
        // set of ownerId
        Set<Id> ownerIds = new Set<Id>();
		
        //Loop on the Opportunity. 
        for(Opportunity opp : newOpportunities){
        	
        	
            
            if((oldMapOpportunities == null || oldMapOpportunities.get(opp.Id).Month_80_50__c != opp.Month_80_50__c 
            	|| oldMapOpportunities.get(opp.Id).StageName != opp.StageName || oldMapOpportunities.get(opp.Id).RecordTypeId != opp.RecordTypeId)
            	&& opp.StageName != Constants.DISQUALIFIED && opp.StageName != Constants.CLOSED_LOST 
            	&&  opp.RecordTypeId != Constants.RECORD_TYPE_ID_OPPORTUNITY_ROYALL
		&& (opp.Month_80_50__c == 'Wildcard'|| opp.Month_80_50__c == '80' || opp.Month_80_50__c == '50' ))
            {
                opp.Forecasted__c = true;
            }
            
            // populate Initial_Fast_Track_Value__c
            if((oldMapOpportunities == null || oldMapOpportunities.get(opp.Id).Initial_Fast_Track_Value__c != opp.Initial_Fast_Track_Value__c
            	|| oldMapOpportunities.get(opp.Id).StageName != opp.StageName) 
            	&& opp.Initial_Fast_Track_Value__c == null 
            	&& (opp.StageName == CPQConstants.OPPORTUNITY_STAGE_EVALUATING
                   || opp.StageName == CPQConstants.OPPORTUNITY_STAGE_CONFIRMING
                   || opp.StageName == CPQConstants.OPPORTUNITY_STAGE_SELECTED)
	    ){
                opp.Initial_Fast_Track_Value__c = opp.Opportunity_Amount__c;
            }
            
            if(oldMapOpportunities == null || oldMapOpportunities.get(opp.Id).IsClosed != opp.IsClosed 
            	|| oldMapOpportunities.get(opp.Id).RecordTypeId != opp.RecordTypeId ){
            	
            	// populate Calculated_Close_Date__c, Editable_by_Finance_Ops_Only__c
                if(opp.IsClosed && opp.RecordTypeId == Constants.RECORD_TYPE_ID_OPPORTUNITY_ROYALL) {
                	
                    opp.Calculated_Close_Date__c = system.today();
                    opp.Editable_by_Finance_Ops_Only__c = true;
                }
                
                // populate Editable_by_Finance_Ops_Only__c
                if(!opp.IsClosed && opp.Editable_by_Finance_Ops_Only__c && opp.RecordTypeId == Constants.RECORD_TYPE_ID_OPPORTUNITY_ROYALL)
                    opp.Editable_by_Finance_Ops_Only__c = false;
                
                if(opp.IsClosed && opp.RecordTypeId != Constants.RECORD_TYPE_ID_OPPORTUNITY_ROYALL) {
                	
                    opp.Projection_Liklihood__c = null;
                	opp.Program_Rate_Projections__c = null;
                }	
            }
            
            if((oldMapOpportunities == null || oldMapOpportunities.get(opp.Id).Initial_Visit_Date__c != opp.Initial_Visit_Date__c
            	|| oldMapOpportunities.get(opp.Id).RecordTypeId != opp.RecordTypeId || oldMapOpportunities.get(opp.Id).StageName != opp.StageName) 
            	&& opp.RecordTypeId != Constants.RECORD_TYPE_ID_OPPORTUNITY_ROYALL && opp.Initial_Visit_Date__c == null 
            	&& opp.StageName == Constants.STAGE_OPPORTUNITY_INITIAL_VISIT_SCHEDULED)
            {
                opp.StageName = Constants.STAGE_OPPORTUNITY_OUTREACH;
            }
            
            if( (oldMapOpportunities == null || oldMapOpportunities.get(opp.Id).Evaluated__c != opp.Evaluated__c 
            	 || oldMapOpportunities.get(opp.Id).Initial_Visit_Date__c != opp.Initial_Visit_Date__c || oldMapOpportunities.get(opp.Id).IsWon != opp.IsWon
            	 || oldMapOpportunities.get(opp.Id).RecordTypeId != opp.RecordTypeId || oldMapOpportunities.get(opp.Id).StageName != opp.StageName)
            	&& (opp.Evaluated__c == null || opp.Evaluated__c == 0)
            	&&
            	( 
            	  ( opp.RecordTypeId != Constants.RECORD_TYPE_ID_OPPORTUNITY_ROYALL 
                	&& (( opp.IsWon == true && opp.Initial_Visit_Date__c != null )
                	|| opp.StageName == CPQConstants.OPPORTUNITY_STAGE_EVALUATING
                     	|| opp.StageName == CPQConstants.OPPORTUNITY_STAGE_CONFIRMING
                     	|| opp.StageName == CPQConstants.OPPORTUNITY_STAGE_SELECTED
                     	|| opp.StageName == CPQConstants.OPPORTUNITY_STAGE_CLOSING )
                  )
                  || 
                  ( opp.RecordTypeId == Constants.RECORD_TYPE_ID_OPPORTUNITY_ROYALL 
                	&& ( opp.StageName == Constants.STAGE_OPPORTUNITY_OPPORTUNITY_IDEBTIFIED || opp.StageName == Constants.STAGE_OPPORTUNITY_PROPOSAL_UNDER_REVIEW || opp.StageName == Constants.STAGE_OPPORTUNITY_CONTRACT_UNDER_REVIEW)
                  )
		)
	    ){
		  	opp.Evaluated__c = 1 ;
	    }
			
	    if(oldMapOpportunities == null || oldMapOpportunities.get(opp.Id).Counter_ID__c != opp.Counter_ID__c){
					
                Date checkDate = Date.newInstance(2011,07,13);
                if(opp.CreatedDate > checkDate && (String.isBlank(opp.Historical_Linker__c) || opp.Historical_Linker__c != opp.Counter_ID__c))
                {
                    opp.Historical_Linker__c = opp.Counter_ID__c ;
                }
            }
            
            if((oldMapOpportunities == null || oldMapOpportunities.get(opp.Id).RecordTypeId != opp.RecordTypeId 
            	 || oldMapOpportunities.get(opp.Id).StageName != opp.StageName) 
            	&& opp.RecordTypeId != Constants.RECORD_TYPE_ID_OPPORTUNITY_ROYALL &&  !(setOpportunityStageNames.contains(opp.StageName) 
            	&& opp.StageName != CPQConstants.OPPORTUNITY_STAGE_CONTRACT_REC_SEND_TO_FINANCE)){
				
			opp.Amount = opp.Posted_Proposal_Value__c;
			}
            
            if((oldMapOpportunities == null || oldMapOpportunities.get(opp.Id).RecordTypeId != opp.RecordTypeId 
	    	|| oldMapOpportunities.get(opp.Id).IsClosed != opp.IsClosed
		|| oldMapOpportunities.get(opp.Id).IsWon != opp.IsWon)    
		&& opp.IsClosed && opp.IsWon
		&& (opp.RecordTypeId == Constants.RECORD_TYPE_ID_OPPORTUNITY_PT_MARKETING
		|| opp.RecordTypeId == Constants.RECORD_TYPE_ID_OPPORTUNITY_RI_MARKETING))
	    {
	    	opp.Amount = opp.NBB__c;
	    }
			
	    if((oldMapOpportunities == null || oldMapOpportunities.get(opp.Id).RecordTypeId != opp.RecordTypeId || oldMapOpportunities.get(opp.Id).StageName != opp.StageName)){
				
            	if( setOpportunityStageNames.contains(opp.StageName) && (opp.RecordTypeId == Constants.RECORD_TYPE_ID_OPPORTUNITY_PT_CONTRACT_MAINTENANCE || opp.RecordTypeId == Constants.RECORD_TYPE_ID_OPPORTUNITY_PT_CONTRACT_RENEWAL))
			opp.Amount = opp.Renewal_Credit__c;
				
		if(opp.StageName == Constants.CLOSED_WON && opp.RecordTypeId != Constants.RECORD_TYPE_ID_OPPORTUNITY_ROYALL)
                	opp.Month_80_50__c = 'Won';
	    }
			
            //Modified By - Neha Sharma - 2/12/2021 - CR-20200527-14108 - comment the below codition as EvalCompOrRIComp_LastModifiedDate__c field get deleted from the system.
            /*if((oldMapOpportunities == null && opp.RecordTypeId != Constants.RECORD_TYPE_ID_OPPORTUNITY_ROYALL 
            	 && (String.isNotBlank(opp.Is_the_Evaluation_Competitive__c) || String.isNotBlank(opp.R_I_Competitors__c)))
            	|| (oldMapOpportunities != null && (opp.Is_the_Evaluation_Competitive__c != oldMapOpportunities.get(opp.Id).Is_the_Evaluation_Competitive__c  
            	|| opp.R_I_Competitors__c  !=  oldMapOpportunities.get(opp.Id).R_I_Competitors__c))
            ){
                opp.EvalCompOrRIComp_LastModifiedDate__c = system.today();
            }*/
            
            if(oldMapOpportunities == null && opp.RecordTypeId != Constants.RECORD_TYPE_ID_OPPORTUNITY_ROYALL){
            	if(opp.RecordTypeId == Constants.RECORD_TYPE_ID_OPPORTUNITY_PT_MARKETING || opp.RecordTypeId == Constants.RECORD_TYPE_ID_OPPORTUNITY_RI_MARKETING || opp.RecordTypeId == CPQConstants.OPP_RT_ID_EAB_INITIATING)
                	opp.Program_Rate_Projections__c = '';
            }
            
            if(oldMapOpportunities == null || (oldMapOpportunities != null
                                               && (oldMapOpportunities.get(opp.Id).StageName != opp.StageName
                                                   || oldMapOpportunities.get(opp.Id).Previous_Contract__c != opp.Previous_Contract__c
                                                   || oldMapOpportunities.get(opp.Id).RecordTypeId != opp.RecordTypeId
                                                   || oldMapOpportunities.get(opp.Id).Decision_Type__c != opp.Decision_Type__c)))
            {
                
                if(opp.Previous_Contract__c != null ) {
                    setContractIds.add(opp.Previous_Contract__c);
                }
            }
            
            if(oldMapOpportunities == null || (oldMapOpportunities != null && (oldMapOpportunities.get(opp.Id).Membership__c != opp.Membership__c))) {
                
                if(opp.Membership__c != null)
                    setOfMembershipIds.add(opp.Membership__c);
            }
            
            if(oldMapOpportunities == null || (oldMapOpportunities != null && oldMapOpportunities.get(opp.Id).OwnerId != opp.OwnerId )) {
                
                if(opp.OwnerId != null)
                    ownerIds.add(opp.OwnerId);
            }
        }
        
        if(setContractIds.size() > 0 ) {
        	
            map<Id, Contract__c> mapContracts = new map<Id, Contract__c>([SELECT Id, Start__c FROM Contract__c WHERE Id IN :setContractIds AND Start__c != null]);
            
            if(mapContracts != null && mapContracts.size() > 0 ){
                
                for(Opportunity opp : newOpportunities) {
                    
                    if(opp.Previous_Contract__c != null && mapContracts.containsKey(opp.Previous_Contract__c) 
                        && mapContracts.get(opp.Previous_Contract__c).Start__c != null
                        && opp.CloseDate != mapContracts.get(opp.Previous_Contract__c).Start__c
                        && ( opp.RecordTypeId == Constants.RECORD_TYPE_ID_OPPORTUNITY_PT_CONTRACT_MAINTENANCE 
                             || opp.RecordTypeId == Constants.RECORD_TYPE_ID_OPPORTUNITY_PT_CONTRACT_RENEWAL)
                        && ( opp.Decision_Type__c == Constants.DECISION_TYPE_OPPORTUNITY_OPT_OUT
                             || opp.StageName == Constants.STAGE_OPPORTUNITY_PENDING_RENEWAL_CALL_COMP_EVALUATING
                             || opp.StageName == Constants.STAGE_OPPORTUNITY_PENDING_RENEWAL_CALL_COMP_CONTRACTING
                             || opp.StageName == CPQConstants.OPPORTUNITY_STAGE_PENDING_RENEWAL_CALL_NOT_YET_OCCURED
                             || opp.StageName == CPQConstants.OPPORTUNITY_STAGE_PENDING
                           )
                    ) {
                        opp.CloseDate = mapContracts.get(opp.Previous_Contract__c).Start__c;
                    }
                }
            }
        }
        if(setOfMembershipIds.size() > 0) {
        	
            map<Id, Membership__c> membershipMap = new map<Id, Membership__c>([SELECT Id, Notes_Dedicated_Advisor__c FROM Membership__c WHERE Id IN :setOfMembershipIds]);
            
            if(membershipMap != null && membershipMap.size() > 0){
            	for(Opportunity opp : newOpportunities){
            	
	                if(opp.Membership__c != null && membershipMap.containsKey(opp.Membership__c))
	                {
	                    opp.Notes_Dedicated_Advisor__c = membershipMap.get(opp.Membership__c).Notes_Dedicated_Advisor__c;
	                }
	            }
            }
        }
        
        // size check
        if(ownerIds.size() > 0) {
            
            map<Id, User> mgrUserMap = new map<Id, User>([SELECT Id, manager.email FROM User WHERE Id IN :ownerIds AND managerID != null]);
            
            if(mgrUserMap != null && mgrUserMap.size() > 0){
             	
                for(Opportunity opp : newOpportunities) {
                
                    if(opp.OwnerId != null && mgrUserMap.containsKey(opp.OwnerId) && mgrUserMap.get(opp.OwnerId) != null 
                        && String.isNotBlank(mgrUserMap.get(opp.OwnerId).manager.email)
                        && opp.Owner_Manager_Email__c != mgrUserMap.get(opp.OwnerId).manager.email)
                    {
                        opp.Owner_Manager_Email__c = mgrUserMap.get(opp.OwnerId).manager.email;
                    }
                }
            }
        }
    }
    
   /**
    *  @description    :  This method is used to populate Trigger Update field on opportunity. this is the replacement of PB_OPportunity Process Builder Due to SOQL 101 Error.
    * 
    *  @args           :   List of opportunities, Map of Opportunity
    * 
    *  @return         :   void
    * 
    * Created By       :   Subhash Garhwal 08/12/2020 - CR-20200812-14427 -- Should be add in the last in after insert/update.
    **/
    public static void populateTriggerUpdate(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldMapOpportunities) {
        
        List<Opportunity> listopportunityToupdate = new List<Opportunity>();
        
        //Loop on the Opportunity. 
        for(Opportunity opp : newOpportunities) {
            
            if(oldMapOpportunities == null || (oldMapOpportunities != null && (oldMapOpportunities.get(opp.Id).Trigger_Update__c != opp.Trigger_Update__c))) {
            	
            	if(opp.Trigger_Update__c) {
                    opp.Trigger_Update__c = false;
                    listopportunityToupdate.add(opp);
                }
            }
        } 
        if(listopportunityToupdate.size() > 0){
        	
            Util.BypassAllTriggers = true;
            update listopportunityToupdate;
            Util.BypassAllTriggers = false;
        }
    }
       /**
        *  @description    :  This method is used to validate the contact on opportunity while insert and update.
        * 
        *  @args           :   List of opportunities
        * 
        *  @return         :   void
        * 
        * Created By       :   Created By Abhinav Sharma - 07/10/2020 - CR-20200218-13783
       **/    
    public static void validateContact(List<Opportunity> newOpps, Map<Id, Opportunity> oldMapopps) {
     
        set<Id> setOfContactIds = new Set<Id>();
        set<Id> setOfParentChildAccountIds = new set<Id>();
        set<Id> setOAccountIds = new set<Id>();
        set<Id> setofConAccountIds = new set<Id>();
        Map<Id,Id> mapOfContactIdWithAccount = new Map<Id,Id>();
        
        String EAB_INITIATING_RTYPE = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('EAB Initiating').getRecordTypeId();
        String ROYALL_RTYPE = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royall').getRecordTypeId();
        String EAB_CONTINUING_RTYPE = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('EAB Continuing').getRecordTypeId();

            
        for(Opportunity opp : newOpps){  
            if(opp.Main_Contact__c != null 
               && (opp.RecordtypeId == EAB_INITIATING_RTYPE 
                   || opp.RecordtypeId == ROYALL_RTYPE 
                   || opp.RecordtypeId == EAB_CONTINUING_RTYPE) 
               	   && (oldMapopps == null || (oldMapopps != null && oldMapopps.get(opp.Id).Main_Contact__c != opp.Main_Contact__c ))){
                
                    setOfContactIds.add(opp.Main_Contact__c);
                    
                    if(opp.AccountId != null ){
                       setOAccountIds.add(opp.AccountId);  
            	    }
                    if(opp.Top_Parent_Institution_ID__c != null ){
                       setOAccountIds.add(opp.Top_Parent_Institution_ID__c);  
            	    }
        	}
        }
        
        if(setOAccountIds.size() > 0){
          
            for(Account acc : [Select Id,Name,
                              Top_Parent_Institution__c,ParentId,
                              (Select Id From Accounts__r) From Account where Id IN: setOAccountIds]){
                
                setOfParentChildAccountIds.add(acc.Id);
                
                if(String.isNotBlank(acc.Top_Parent_Institution__c))
                	setOfParentChildAccountIds.add(acc.Top_Parent_Institution__c);
                 if(String.isNotBlank(acc.ParentId))
                	setOfParentChildAccountIds.add(acc.ParentId);
                
                for(account acct : acc.Accounts__r){
                	setOfParentChildAccountIds.add(acct.Id);
                }
            }
        }
        
        if(setOfContactIds.size() > 0){
            
            for(Contact con : [Select Id, accountId, Contact_Status__c, Name From Contact where Id IN: setOfContactIds]){
                if(con.Contact_Status__c ==  'Active' && setOfParentChildAccountIds.contains(con.accountId)){
                    mapOfContactIdWithAccount.put(con.Id,con.accountId);
                }
            }
        
        
        
        for(Opportunity opp : newOpps){
            if(opp.Main_Contact__c != null){
                if(!mapOfContactIdWithAccount.containsKey(opp.Main_Contact__c) && (opp.RecordtypeId == EAB_INITIATING_RTYPE || opp.RecordtypeId == ROYALL_RTYPE || opp.RecordtypeId == EAB_CONTINUING_RTYPE)){
                    opp.addError('Add the contact which is related to the parent or child institution and must be active.');
                }
            }
        }
        }
    }
    
    /**
        *  @description    :  This method is used to create the case when cappex opportunity set to closed
        *                     Find all renewal calls within 120 days  of the due date that aren't
        *                     canceled or completed and haven't been scheduled yet and schedule it.                     
        *  
        *  @args           :   List of opportunities
        * 
        *  @return         :   void
        * 
        * Created By       :   Created By Mahendra Swarnakar - 11/04/2020 - CR-20201029-14646
        *                  :   Modified by -  chirag soni - 11/16/2021 - CR-20211112-15582  - Updated method - legacy cappex record type is deactivated and migrated to legacy Acquisition
        *                  :   Modified by - Neha Sharma - 4/26/2022 - CR-20220216-15919 - Comment out Logic which is related to update Review call record.
    **/    
    public static void CreateCaseUponLostOpportunityAndMarkRenewalCallAsScheduled (List<Opportunity> newOpps, Map<Id, Opportunity> oldMapopps) {
        List<Case> cases = new List<Case>();  
        Set<Id> opportunityIds = new Set<Id>();
        Map<Id,Opportunity> mapOfOpportunity = new Map<Id,Opportunity>();
        
        //Modified by - Neha Sharma - 4/26/2022 - CR-20220216-15919 - Comment out Logic which is related to update Review call record.
        //List<Review_Call__c> referenceCalls = new List<Review_Call__c>();
        

        //List<Review_Call__c> reviewCallToBeUpdated = new List<Review_Call__c>();
        //Set<Id> accountIds = new Set<Id>();
        
        //Modified by - Chirag Soni - 11/16/2021 - CR-20211112-15582 - Modified the record type from legacy cappex to legacy acquisition
        for (Opportunity opp : newOpps)
        {
            if(opp.RecordtypeId == Constants.RECORD_TYPE_ID_LEGACY_ACQUISITION  
               && opp.Opp_Type_CX__c == 'Renewal'
               && (oldMapopps == null || 
                   (oldMapopps != null 
                    && (oldMapopps.get(opp.Id).Opp_Type_CX__c != opp.Opp_Type_CX__c
                        || oldMapopps.get(opp.Id).stageName != opp.stageName ))))
            {
                if(opp.stageName == 'Closed Lost')
                {
                    mapOfOpportunity.put(opp.Id,opp);
                }
                //Modified by - Neha Sharma - 4/26/2022 - CR-20220216-15919 - Comment out Logic which is related to update Review call record.
                /*
                if(opp.stageName == 'Presentation Scheduled')
                {
                    accountIds.add(opp.accountId);
                } */
                
            }
            
        }
        
        if(mapOfOpportunity.size() > 0){
            for (Opportunity opport : [Select Id,Name,OwnerId,AccountId,Account.Name,description from opportunity where id IN : mapOfOpportunity.keySet()])
            {
                cases.add (new Case (Reason = 'Make Inactive',
                                     Deadline__c = system.today(),
                                     AccountId = opport.AccountId,
                                     Origin = 'Workflow',
                                     RecordTypeId = Constants.CASE_CAPPEX_REQUESTS_RT_ID,
                                     Type = 'Cappex - Client Support',
                                     Description = '*** Case added by workflow *** Notes from the Opportunity: ' + opport.description,
                                     Subject = 'Make ' + opport.Account.Name + ' Inactive'));
            }
        } 
        
        //Modified by - Neha Sharma - 4/26/2022 - CR-20220216-15919 - Comment out Logic which is related to update Review call record.
        /*
        if(accountIds.size() > 0)
        {
            for(Review_Call__c referenceCall : [SELECT Id FROM Review_Call__c WHERE Type__c = 'Annual Review' 
                                                AND Account__c IN: accountIds 
                                                AND Completed__c = false 
                                                AND Canceled__c = false 
                                                AND Scheduled__c = false
                                                AND Review_Call_Due_Date__c >= LAST_N_DAYS:120
                                                AND Review_Call_Due_Date__c <= NEXT_N_DAYS:120])
            {
                referenceCall.Scheduled__c = true;
                reviewCallToBeUpdated.add(referenceCall);
            }
        } */

        
        if(cases.size() > 0) {
            util.BypassAllTriggers = true;
            insert cases;
            util.BypassAllTriggers = false;
        }
        
        //Modified by - Neha Sharma - 4/26/2022 - CR-20220216-15919 - Comment out Logic which is related to update Review call record.
        /*
        if(reviewCallToBeUpdated.size() > 0) {
            util.BypassAllTriggers = true;
            update reviewCallToBeUpdated;
            util.BypassAllTriggers = false;
        } */
        
    }

    
    /**
        *  @description    :  This method is used to create the review call record on opportunity fields update
        * 
        *  @args           :   List of opportunities
        * 
        *  @return         :   void
        * 
        * Created By       :   Created By Mahendra Swarnakar - 11/04/2020 - CR-20201029-14646
        *                  :   Modified by -  chirag soni - 11/16/2021 - CR-20211112-15582  - Updated method - legacy cappex record type is deactivated and migrated to legacy Acquisition
        *                  :   Modified by - Neha Sharma - 4/26/2022 - CR-20220216-15919 - Comment out method CreateReviewCall() and CreateReviewCalls() in order to prevent Review calls records to be inserted.
        **/ 
    /*   
    public static void  CreateReviewCall (List<Opportunity> newOpps, Map<Id, Opportunity> oldMapopps) {
       
        List<Review_Call__c> insertReviewCall = new List<Review_Call__c>();
        Set<String> setOfOppTypeCX = new Set<String>{'New','Renewal'};
        Set<ID> setAccountsIDs = new Set<ID>();
        List<Opportunity> oppThirtydays = new List<Opportunity>();
        List<Opportunity> oppHalfWaydays = new List<Opportunity>();
        Map<Id,List<membership__c>> mapOfaccountWithmembership = new Map<Id,List<membership__c>>();
        
        for (Opportunity opp : newOpps)
        {
            //Modified by - Chirag Soni - 11/16/2021 - CR-20211112-15582 - Modified the record type from legacy cappex to legacy acquisition
            if((setOfOppTypeCX.contains(opp.Opp_Type_CX__c))
               && opp.RecordtypeId == Constants.RECORD_TYPE_ID_LEGACY_ACQUISITION 
               && opp.stageName == Constants.CLOSED_WON
               && (oldMapopps != null 
                    && (oldMapopps.get(opp.Id).Opp_Type_CX__c != opp.Opp_Type_CX__c
                    || oldMapopps.get(opp.Id).stageName != opp.stageName )))
            {
                if(opp.AccountId !=  null ){
                    setAccountsIDs.add(opp.AccountId);
                }
                if(opp.Opp_Type_CX__c == 'New' ){
                    oppThirtydays.add(opp);
                }
                if(opp.Opp_Type_CX__c == 'Renewal'){
                    oppHalfWaydays.add(opp);
                }
            }   
            
            if(setAccountsIDs.size() > 0){
                for(Membership__c mem : [Select Id,Account_Name__c from membership__c where Account_Name__c IN : setAccountsIDs 
                                          AND Program_Acronym__c =: Constants.PROGRAM_ACRONYM_CXCN])
                {
                    if(!mapOfaccountWithmembership.containsKey(mem.Account_Name__c)){
                        mapOfaccountWithmembership.put(mem.Account_Name__c,new List<Membership__c>()); 
                    }
                    mapOfaccountWithmembership.get(mem.Account_Name__c).add(mem);                           
                }
            }       
                   
            if(oppThirtydays.size() > 0){
                insertReviewCall.addAll(createReviewCalls(oppThirtydays, true,mapOfaccountWithmembership));
            }
            if(oppHalfWaydays.size() > 0){
                insertReviewCall.addAll(createReviewCalls(oppHalfWaydays, false,mapOfaccountWithmembership));
            }      
        } 
        
        
        if(insertReviewCall.size() > 0){
            util.BypassAllTriggers = true;
            insert insertReviewCall;
            util.BypassAllTriggers = false;
        }
    }
    
   
    private static List<Review_Call__c> createReviewCalls(List<Opportunity> oppList, Boolean isNew,Map<Id,List<Membership__c>> mapOfAccWithMembership){
        
        List<Review_Call__c> reviewCallToBeInsert = new List<Review_Call__c>();
        Id membershipId = null;
        for(Opportunity opp : oppList){
            
           // reinstate the 30-day call for new clients ONLY. not renewals.
           Date startDate =  Date.valueOf(opp.CreatedDate);
            if(mapOfAccWithMembership.containsKey(opp.AccountId)){
              membershipId = opp.membership__c;  
            }
            
            if(opp.AccountId != null && mapOfAccWithMembership.ContainsKey(opp.AccountId)){
                for(Membership__c mem : mapOfAccWithMembership.get(opp.AccountId))
                {
                    if(isNew)
                    { 
                        Review_Call__c revCall_30Days = new Review_Call__c(membership__c = mem.Id);
                        revCall_30Days.Name = '30Call ' + String.valueOf(startDate.addDays(30));
                        revCall_30Days.Review_Call_Due_Date__c = startDate.addDays(30);
                        revCall_30Days.Type__c = 'Initial 30-Day Review'; 
                        revCall_30Days.Account__c = opp.AccountId; 
                        reviewCallToBeInsert.add(revCall_30Days);
                        
                        Review_Call__c revCall_90Days = new Review_Call__c(membership__c = mem.Id);
                        revCall_90Days.Name = '90Call ' + String.valueOf(startDate.addDays(90));
                        revCall_90Days.Review_Call_Due_Date__c = startDate.addDays(90);
                        revCall_90Days.Type__c = 'New Client 90-Day Review';
                        revCall_90Days.Account__c = opp.AccountId;
                        reviewCallToBeInsert.add(revCall_90Days);
                        
                    }
                    if(!isNew)
                    {
                        // Renewal contract. Insert a review call halfway between now and the 155 day point in their contract.
                        Review_Call__c revCall_renewal = new Review_Call__C(membership__c = mem.Id);
                        Integer daysBetween = (date.today().daysBetween(startDate.addDays(155)));             
                        Integer targetDays = (daysBetween / 2);             
                        revCall_renewal.Review_Call_Due_Date__c = date.today().addDays(targetDays);
                        revCall_renewal.Name = 'Post-Renewal Review';
                        revCall_renewal.Type__c = 'Post Renewal Review'; 
                        revCall_renewal.Account__c = opp.AccountId;
                        reviewCallToBeInsert.add(revCall_renewal);
                    }
            
                    Review_Call__c revCall_155Half = new Review_Call__c(membership__c = mem.Id);
                    revCall_155Half.Name = '155Half ' + String.valueOf(startDate.addDays(155));
                    revCall_155Half.Review_Call_Due_Date__c = startDate.addDays(155);
                    revCall_155Half.Type__c = '1/2 Way Review';
                    revCall_155Half.Account__c = opp.AccountId;
                    reviewCallToBeInsert.add(revCall_155Half);
                    
                    Review_Call__c revCall_275Renewal = new Review_Call__c(membership__c = mem.Id);
                    revCall_275Renewal.Name = '275Renewal ' + String.valueOf(startDate.addDays(275));
                    revCall_275Renewal.Review_Call_Due_Date__c = startDate.addDays(275);
                    revCall_275Renewal.Type__c = 'Annual Review';
                    revCall_275Renewal.Account__c = opp.AccountId;
                    reviewCallToBeInsert.add(revCall_275Renewal);
                    
                    Review_Call__c revCall_AccountAudit = new Review_Call__c(membership__c = mem.Id);
                    revCall_AccountAudit.Name = 'AccountAudit ' + String.valueOf(startDate.addDays(182));
                    revCall_AccountAudit.Review_Call_Due_Date__c = startDate.addDays(182);
                    revCall_AccountAudit.Type__c = 'Account Audit';
                    revCall_AccountAudit.RecordTypeId = Constants.REVIEW_CALL_RT_ID;
                    revCall_AccountAudit.Account__c = opp.AccountId;
                    reviewCallToBeInsert.add(revCall_AccountAudit);  
                }  
            }

        }
         
        return reviewCallToBeInsert;
    } */
    
    /**
        *  @description    :  This method is used to populate the highest value ever in the Probability field. 
        * 
        *  @args           :   List of opportunities
        * 
        *  @return         :   void
        * 
        * Created By       :   Created By Neha Sharma - 9/04/2021 - CR-20210202-14862
    **/    
    public static void  populateMaxProbabilityOppReached (List<Opportunity> newOpportunities, Map<Id, Opportunity> oldMapOpportunities) {
        
        //Loop on the Opportunity. 
        for(Opportunity opp : newOpportunities) {
            
            if(opp.Probability != null && (oldMapOpportunities == null || (oldMapOpportunities != null 
                                               && (oldMapOpportunities.get(opp.Id).Probability != opp.Probability)))) 
            {
                
                if(opp.Max_Probability__c != null && opp.Max_Probability__c < opp.Probability)
                {
                    opp.Max_Probability__c = opp.Probability;
                }
                else if(opp.Max_Probability__c == null ){
                    opp.Max_Probability__c = opp.Probability;
                }
            }
        } 
    }    
    /**
    *  @description    :  This method is used if the Account on the Opportunity is changed, 
    *                     then the Account on the associated proposal(s) should also be automatically changed.
    * 
    *  @args           :  List of opportunities
    * 
    *  @return         :  void
    * 
    * Created By       :  Created By - Mahendra Swarnkar - 08/19/2021 - CR-20210414-15080 - Institution on the proposal always matches the institution on the opportunity
    **/    
    public static void updateAccountOnProposal(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldMapOpportunities) {
        
        //to hold Opportunity Ids along with Account Ids
        Map<Id, Id> mapOfOppIdWithAccountId = new Map<Id, Id>();
        
        //Loop on the Opportunity. 
        for(Opportunity opp : newOpportunities) {
            
            //update case
            if(oldMapOpportunities != null && oldMapOpportunities.get(opp.Id).AccountId != opp.AccountId) 
            {
                //put Opportunity and Account Ids
                mapOfOppIdWithAccountId.put(opp.Id, opp.AccountId);
            }
        }
        
        //check map size
        if(mapOfOppIdWithAccountId.size() > 0 && mapOfOppIdWithAccountId.keySet().size() > 0){
            
            //to hold proposals on which Institution is going to update
            List<SBQQ__Quote__c> proposalsToBeUpdate = new List<SBQQ__Quote__c>();
            
            //proposal related to Opportunity
            for(SBQQ__Quote__c proposal : [Select Id, SBQQ__Opportunity2__c, SBQQ__Account__c from SBQQ__Quote__c 
                                           Where SBQQ__Opportunity2__c != null And SBQQ__Opportunity2__c IN :mapOfOppIdWithAccountId.keySet()]) 
            {
                //check map contains opportunity & reflact Account Id on Proposals
                if(mapOfOppIdWithAccountId.containsKey(proposal.SBQQ__Opportunity2__c))
                    proposalsToBeUpdate.add(new SBQQ__Quote__c(Id = proposal.Id, SBQQ__Account__c = mapOfOppIdWithAccountId.get(proposal.SBQQ__Opportunity2__c)));
            }
            
            //check list size
            if(proposalsToBeUpdate.size() > 0){
                
                util.BypassAllTriggers = true;
                Update proposalsToBeUpdate;
                util.BypassAllTriggers = false;
            }
        }
    }
}