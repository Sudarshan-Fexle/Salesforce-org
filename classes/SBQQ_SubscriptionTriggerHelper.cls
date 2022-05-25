/**
 *  Description     :  Helper class for SBQQ_SubscriptionTrigger trigger.
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  06/30/2016
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762 
 *                      V_1.1 - Modified By - 08/01/2016 - Subhash Garhwal - CR-20160414-9762 - Added new method validateProgramOpportunities
 *                      V_1.2 - Modified By - 09/13/2016 - Subhash Garhwal - CR-20160830-10158 - Updated syncProgramOppsWithSubscriptions method to change
 *                                                                                            calculations for Previous Year Negotiated field value.
 *                      V_1.3 - Modified By - 09/27/2016 - Subhash Garhwal - CR 10158 - Populateed LOA_Contract__c field
 *                      V_1.4 - Modified By - 10/12/2016 - Subhash Garhwal - Q2C Hypercare of Hypercare
 *                      V_1.5 - Modified By - 04/26/2017 - Victor Hanson   - CR-20170403-10807
 *                      V_1.6 - Modified By - 05/10/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807 - Added new Method populateSubscriptionFieldsBasedOnMembership
 *                      V_1.7 - Modified By - 5/11/2017  - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807 - Added new Method updateRenewalSubscriptionOnContract
 *                      V_1.8 - Modified By - 05/17/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807 - New methods are added populateProgramSubscription & calculateACVAndProfit
 *                      V_1.9 - Modified By - 05/19/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807 - Added new method populateJoiningDateOfPreviousSubscription
 *                      V_2.0 - Modified By - 05/24/2017 - Saurabh Kumar   - Q2C Phase 2 - CR-20170403-10807 - Added a new method populateProductCode on the parent(Contract) 
 *                      V_2.1 - Modified By - 05/24/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807 - Added a new method populateRecordTypeOnSubscription
 *                      V_2.2 - Modified By - 05/24/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807 - Added a new method createSubscriptionPeriodforUniqueComponent
 *                      V_2.3 - Modified By - 05/30/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807 - Added a new method automationSubscription
 *                      V_2.4 - Modified By - 05/30/2017 - Saurabh Kumar   - Q2C Phase 2 - CR-20170403-10807 - Updated method "populateProgramCode" to check insert case.
 *                      V_2.5 - Modified By - 06/01/2017 - Saurabh Kumar   - Q2C Phase 2 - CR-20170403-10807 - Added a new method "populateDefaultFieldValue" to set initial value
 *                      V_2.6 - Modified By - 06/02/2017 - Abhinav Sharma  - DS114  - Added "populateFieldsValueOnCases" method
 *                      V_2.7 - Modified By - 06/05/2017 - Saurabh Kumar   - CR-20170403-10807 - (DS104.1) - Added new method "rollupNegotiatedAmountPeriodOnSubscriptionPeriod" 
 *                      V_2.8 - Modified By - 06/06/2017 - Saurabh Kumar   - CR-20170403-10807 - (DS114) A new method is added "updateMembershipStatusBySubscription"
 *                      V_2.9 - Modified By - 06/0/62017 - Subhash Garhwal - CR-20170403-10807 - A new method is added "populateTypeOnContract"
 *                      V_3.0 - Modified By - 06/07/2017 - Deepak kumar    - CR-20170403-10807 - A new methos is added "updateLISWithProgramSubscriptionIBS"
 *                      V_3.1 - Modified By - 06/07/2017 - Saurabh Kumar   - CR-20170403-10807 (DS073.2) - New methods are added "isActiveSubscriptionStatus" 
 *                      V_3.2 - Modified By - 06/08/2017 - Saurabh Kumar   - CR-20170403-10807 (DS073.2) - New method is added "updateOpportunityFields"
 *                      V_3.3 - Modified By - 06/08/2017 - Deepak Kumawat  - a new method added "validateIBSIdForProgramSubscription"
 *                      V_3.4 - Modified By - 06/08/2017 - Subhash Garhwal - a new method added "populateRenewalFieldOnSubscription"
 *                      v_3.5 - Modified By - 06/15/2017 - Subhash Garhwal - update a method "validatePreviousSubscriptionNegotiated"
 *                      v_3.6 - Modified By - 07/10/2017 - Subhash Garhwal - Added a method "populateOptOutDetails"
 *                      V_3.7 - Modified By - 07/11/2017 - Saurabh Kumar   - Q2C Phase (Issue--CR10807--QA--00004745) - Updated method "createSubscriptionPeriodforUniqueComponent"
 *                      V_3.8 - Modified By - 07/11/2017 - Colin McGloin   - Q2C Phase (Issue--CR10808--QA--00004850) - Updated method "createSubscriptionPeriodforUniqueComponent"
 *                      V_3.9 - Modified By - 07/20/2017 - Saurabh Kumar   - Q2C Phase2 - Changed the field from SBQQ__Subscription__c.Segment_Index__c to SBQQ__Subscription__c.SBQQ__SegmentIndex__c
 *                      V_4.0 - Modified By - 07/21/2017 - Saurabh Kumar   - Q2C Phase2 (Issue--CR10808--QA--00004854) - Added a method "populatePreviousPeriodNegotiatedOnSubPeriod"
 *                      V_4.1 - Modified By - 07/21/2017 - Colin McGloin   - Q2C Phase2 (Issue--CR10808--QA--00005046) - Added the following new methods: syncProgSubToShadowContractABC, recordNeedsSynced, populateSourceFieldsToTarget, convertSourceFieldValue
 *                      V_4.2 - Modified By - 07/25/2017 - Subhash Garhwal - Issue--CR10808--QA--00005099 - updated updateMembershiponProgramSubscription method
 *                      V_4.3 - Modified By - 07/26/2017 - Saurabh Kumar   - Issue--CR10808--QA--00005099 - A method is added "populateSubscriptionFieldsOnMembership"
 *                      V_4.4 - Modified By - 08/10/2017 - Deepak Kumar    - Issue--CR11094--QA--00005406 - Modified the method "populateSubscriptionFieldsBasedOnMembership"
 *                      V_4.5 - Modified By - 08/10/2017 - Colin McGloin   - Issue--CR11094--QA--00005378 - Modified the "populateRenewalFieldOnSubscription" method
 *                      V_4.6 - Modified By - 08/11/2017 - Subhash Garhwal - Issue--CR11094--UAT--00005349 - Modified the "updateTravelandAnnualFeesonComponentSubscription" method
 *                      V_4.7 - Modified By - 08/14/2017 - Subhash Garhwal - Issue--CR11094--QA--00005436 - Modified the "createSubscriptionPeriodforUniqueComponent" method
 *                      V_4.8 - Modified By - 08/16/2017 - Subhash Garhwal - Issue--CR11094--UAT--00005488 - Modified the "updateSubscriptionPeriodFields" method
 *                      V_4.9 - Modified By - 08/25/2017 - Subhash Garhwal - Issue--CR10808--QA--00005222 - Removed SBQQ__Product__r.Program_Family__c field from query
 *                      V_5.0 - Modified By - 09/02/2017 - Subhash Garhwal - Issue--CR11062--QA--00005609 - Removed existing Negotiated amount (Period) field logic for pending Subscription Period and added a new one.
 *                      V_5.1 - Modified By - 09/20/2017 - Victor Hanson   - Issue--CR11375--QA--00005830 - Added new method "setProposalAndLineByPassFlag"
 *                      V_5.2 - Modified By - 10/09/2017 - Victor Hanson   - Issue--CR11062--QA--00006691 - Updated updateMembershiponProgramSubscription method
 *                      V_5.3 - Modified By - 11/07/2017 - Subhash Garhwal - Issue--CR11744--QA--00007311 - Added bypass logic to avoid SOQL limit issue (BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE)
 *                      V_5.4 - Modified By - 11/14/2017 - Victor Hanson   - Issue--CR11094--QA--00005364 - Commented out code that was setting Decision Type=Fixed Term
 *                                                                                                       on 1st segment of renewal subscription periods.
 *                      V_5.5 - Modified By - 12/06/2017 - Mahendra Swarnkar  - CR-20171204-11830
 *                      V_5.6 - Modified By -		 - Subhash Garhwal - updateContractABCRenewalOpportunity - CR-20180126-11910 
 *                      V_5.7 - Modified By - 02/06/2018 - Subhash Garhwal - CR-20180126-11912 Added a new Method  populateOwnerManagerEmailToSubPeriod
 *                      V_5.8 - Modified By - 02/09/2018 - Subhash Garhwal - CR-20180131-11927 - Added a new Method - updateProposalValueForFutureSubPeriod, updateProposalvalue
 *                      V_5.9 - Modified By - 02/09/2018 - Subhash Garhwal - CR-20180207-12036 - Modified method - updatePendingSPNegotiatedAmountPeriod
 *                      V_6.0 - Modified By - 02/09/2018 - Subhash Garhwal - CR-20180226-12084 - updatePendingSPNegotiatedAmountPeriod
 *                      V_6.1 - Modified By - 03/05/2018 - Abhishek Mishra - Modified method to save the query - populateSubscriptionFields - "201 too Many Soql Error"
 *                      V_6.2 - Modified By - 03/06/2018 - Subhash Garhwal - CR-20180301-12089 - Modified class to avoid SOQL limit issue 
 *                      V_6.3 - Modified By - 03/26/2018 - Subhash Garhwal - CR-20180313-12103 - Modified populateSubscriptionFieldsBasedOnMembership method.
 *                      V_6.4 - Modified By - 03/27/2018 - Subhash Garhwal - CR-20180212-12039 - Modified Record Type Assignment logic.
 *                      V_6.5 - Modified By - 04/09/2018 - Subhash Garhwal - CR-20180326-12126 - Modified  method createSubscriptionPeriodforUniqueComponent.
 *                      V_6.6 - Modified By - 04/10/2018 - Subhash Garhwal - New Method added checkComponentSubscription.
 *                      V_6.7 - Modified By - 04/19/2018 - Subhash Garhwal - CR-20180417-12170 - Updated 'createSubscriptionPeriodforUniqueComponent' method to change the record type automation from 'HC' to 'EAB' on Subscription Period objet. 
 *                      V_6.8 - Modified By - 05/10/2018 - Subhash Garhwal - CR-20180508-12214 - Updated createSubscriptionPeriodforUniqueComponent to remove creation of Pending SP if Product sType - One Time
 *                      V_6.9 - Modified By - 07/03/2018 - Rajeev Jain 
 *                      V_7.0 - Modified By - 07/05/2018 - Subhash Garhwal - CR-20180323-12122 - Updated automationSubscription method, added the logic to update these fields on Subscription From Program 
 *                      V_7.1 - Modified By - 5/31/2018  - Abhinav sharma  - CR-20180501-12196 - Updated validateContractABC method 
 *                      V_7.2 - Modified By - 07/19/2018 - Rajeev Jain     - L2 Release - July 2018 - Deployment
 *                      V_7.3 - Modified By - 07/23/2018 - Subhash Garhwal - CR-20180607-12272 - New Method Added - updateCurrentYearFeesOnMembership
 *                      V_7.4 - Modified By - 07/12/2018 - Subhash Garhwal - CR-20180504-12213 - Added 'updateCurrentYearFeesOnMembership' method to update Membership current annual fee and travel fee.                       
 *                      V_7.5 - Modified By - 07/27/2018 - Victor Hanson   - CR-20180607-12270 - added reparentComponentSubscriptionsOnAmendment
 *                      V_7.6 - Modified By - 08/19/2018 - Subhash Garhwal - CR-20180920-12613 - Added extra check in 'updateSubscriptionPeriodFields'
 *                      V_7.7 - Modified By - 09/25/2018 - Subhash Garhwal - CR-20180607-12270 - added 'updateStatusForAmendment'
 *                      V_7.8 - Modified By - 10/11/2018 - Subhash Garhwal - CR-20180720-12456 - Made changes in different method to reduce the SOQL count while while commiting Revenu Recognition Transaction.
 *                      V_7.9 - Modified By - 10/22/2018 - Subhash Garhwal - CR-20180917-12596 - Made changes in populateProductCode.
 *                      V_8.0 - Modified By - 12/03/2018 - Subhash Garhwal - CR-20180726-12469 - Added new Method calculateNextDecisionDate.
 *                      V_8.1 - Modified By - 12/19/2018 - Subhash Garhwal - Modified populateProgramSubscription and createSubscriptionPeriodforUniqueComponent.
 *                      V_8.2 - Modified By - 12/20/2018 - Subhash Garhwal - Modify the method "populateSubscriptionFields" to populate the "Contract Signature Date" on Components.
 *                      V_8.3 - Modified By - 01/11/2019 - Subhash Garhwal - CR-20181019-12685 - Added a new method "syncProgramPackages"
 *                      V_8.4 - Modified By - 01/11/2019 - Victor Hanson   - CR-20181019-12685 - modified populateRenewalPriceFieldOnCompSubscription, updateMembershiponProgramSubscription
 *                      V_8.5 - Modified By - 01/23/2019 - Subhash Garhwal - CR-20181019-12685 - Added a new method "syncTotalContractQuantity"
 *                      V_8.6 - Modified By - 01/30/2019 - Subhash Garhwal - CR-20181019-12685 - Added a new method "populatePreviousCurrentNextYearProgramCost"
 *                      V_8.7 - Modified By - 01/31/2019 - Victor Hanson   - CR-20181019-12685 - Added a new method 'populateAmendmentPriceOverride'
 *                      V_8.8 - Modified By - 02/04/2019 - Abhinav Sharma  - CR-20180521-12237  
 *                      V_8.9 - Modified By - 02/07/2019 - Victor Hanson   - CR-20190104-12807 -Modified reparentComponentSubscriptionsOnAmendment 
 *                      V_9.0 - Modified By - 02/21/2019 - Victor Hanson   - a.  Added variable called subscriptionFutureUpdateCount.
 *                      V_9.1 - Modified By - 02/22/2019 - Subhash Garhwal - a.  Added a new method rollupDetailsonProgramSubscriptionFromComponentSubscription.
 *                                                                        b. Added a new method populateStdContractFields.
 *                                                                        c. Added a new method rollupCompSubToSubPeriod.
 *                      V_9.2 - Modified By - 02/22/2019 - Subhash Garhwal - CR-20190215-12886 - Modify the method populateSubscriptionFieldsOnMembership and updateMembershipStatusBySubscription.
 *          		V_9.3 - Modified By - 02/28/2019 - Subhash Garhwal - CR-20181019-12685 - Modified "populateProgramSubscription" method.
 *          		V_9.4 - Modified By - 03/05/2019 - Colin McGloin   - CR-20180918-12607 - Added goUpdateListPriceOnRevenueRecords method to update related Revenue records as needed
 *          		V_9.5 - Modified By - 03/25/2019 - Mahendra Swarnkar - CR-20181019-12685 - updated "syncTotalContractQuantity" method to populate the SP fields:- "Total_Paper_only_Contract_Quantity__c" and "Total_e_only_Contract_Quantity__c"
 *          		V_9.6 - Modified By - 06-26-2019 - Subhash Garhwal - CR-20190626-13196 - updateCurrentYearFeesOnMembership
 *          		V_9.7 - Modified By - 08/06/2019 - Colin McGloin   - CR-20190724-13232 - Commented out updateLISWithProgramSubscriptionIBS method
 * 			V_9.8 - Modified By - 08/29/2019 - Victor Hanson   - CR-20190829-13297 - populateRenewalPriceFieldOnCompSubscription(): commented out renewalPrice calculation that subtracted renewal uplift
 * 			V_9.9 - Modified By - 09/04/2019 - Victor Hanson   - CR-20190904-13310 - Updated syncTotalContractQuantity(): Added quantity to the contract/paper/e-only quantity calculations
 *			V_10.0 - Modified By - 08/29/2019 - Dipesh Gupta   - CR-20190620-13190 - method populateSubscriptionFieldsOnMembership
 *          		V_10.1 - Modified By - 10/29/2019 - Victor Hanson  - CR-20191028-13469 - Reverted Product MtM changes to populateSubscriptionFieldsOnMembership
 *            		V_10.2 - Modified By - 10/31/2019 - Victor Hanson  - CR-20191031-13488 - Updated populateSubscriptionFieldsOnMembership to work with Global Memberships
 *	      		V_10.3 - Modified By - 02/26/2020 - Mahendra Swarnkar - CR-20200114-13623- Updated populateSubscriptionFieldsOnMembership to work with Global Memberships
 *	      		V_10.4 - Modified By - 06/15/2020 - Mahendra Swarnkar - CR-20200610-14172
 *			V_10.5 - Modified By - 06/26/2020 - Mahendra Swarnkar - CR-20200609-14162 - Issue--CR14162--QA--00009945
 *			V_10.6 - Modified By - 08/12/2020 - Abhinav Sharma    - CR-20190826-13286 - MS 2: Change to Pending Future Start Date value
 *			V_10.7 - Modified By - 09/17/2020 - Subhash Garhwal   - CR-20200701-14248
 *			V_10.8 - Modified By - 09/15/2020 - Subhash Garhwal   - CR-20200914-14503 - Added code logic to modify the start date of the ESYO Sub Products.
 *			V_10.9 - Modified By - 08/31/2020 - Subhash Garhwal   - CR-20200825-14471
 *			V_11.0 - Modified By - 10/19/2020 - Neha Sharma       - CR-20200910-14498 - Update YouVisit Package value of Subscription Period with CPQ Subscription's You Visit package value
 *			V_11.1 - Modified By - 10/27/2020 - Victor Hanson     - CR-20201013-14598 - modified query with reference to the cost product codes instead of just Program Costs
 *			V_11.2 - Modified By - 11/03/2020 - Neha Sharma       - CR-20200930-14569 - Commented out all values which update Membership Owner
 *			V_11.3 - Modified By - 11/25/2020 - Mahendra Swarnkar - CR-20201105-14668
 *			V_11.4 - Modified By - Victor Hanson - CR-20210107-14791 - Set the date the twin fields were populated
 *			V_11.5 - Modified By - 12/20/2020 - Subhash Garhwal - CR-20201215-14746
 *  			V_11.6 - Modified By - 2/16/2020 - Neha shaarma - remove the comment out code method
 *                      V_11.7 - Modified By - 05/21/2021 - Neha Sharma  CR-20210113-14804 - 'Current Period Annual Fee' and 'Current Year Travel Fee' fields on Membership will be calculated by taking the SUM of all applicable customer amounts.
 *			V_11.8 - Modified By - 05/21/2021 - Neha Sharma - CR-20210105-14771  Update Virtual Tour Package Type Lookup
 *                      V_11.9 - Modified By - 07/15/2021 - Mahendra Swarnkar - CR-20210715-15290 - Added the fields Total_Program_Cost__c,Total_Postage_Cost__c,Total_Media_Cost__c for the SP in the map.
 *			V_12.0 - Modified By - 08/02/2021 - Mahendra Swarnkar - CR-20210727-15318  - Modified the Key to include the Program Subscription id as well, so that in case of mutiple instances, SP can be created for each instance\
 *			V_12.1 - Modified By - 24/08/2021 - Mahendra Swarnkar - CR-20210812-15350
 *			V_12.2 - Modified By - 09/17/2020 - Subhash Garhwal - CR-20210817-15358
 **/   
   
public without sharing class SBQQ_SubscriptionTriggerHelper {
    
    public static Boolean POPULATE_GAAP_FIELDS = false;
    
    //Flag to contol the trigger execution 
    public static Boolean BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE = false;
    
    //Added By Mahendra Swarnkar - 03/05/2018 - CR-20180301-12089
    //Flag to contol the trigger execution 
    public static Boolean BYPASS_MULTIPLE_EXECUTION_OF_updateLISWithProgramSubscriptionIBS = false;
    //Added By Mahendra Swarnkar - 03/05/2018 - CR-20180301-12089 - Ends 
  
    //V_2.8 - Modofoed - 06/05/2017 - Saurabh Kumar - CR-20170403-10807 - (DS114)
    //variable to stop the recursive execution of th trigger
    public static Boolean isSubscriptionTriggerExecuted = false; 
    
    //Added by - Subhash Garhwal - 03/06/2018 - CR-20180301-12089 - Veriable to control the method execution on creation of Subscription Periods and update of the Subscriotions in same call.
    public static Boolean BYPASS_FOR_SUBSCRIPTION_PERIOD_CREATION_PROCESS = false;
    
    //Aded By - Subhash Garhwal - 03/26/2018 - CR-20180313-12103 - Flag to update the GAAP_Negotiated_Amount__c field with Negotiated_Amount_Subscription__c when a Subscription record insertted and in call call updated.
    public static Boolean IS_INSERT_CASE = false;
    
    //Added by - Victor Hanson - 07/27/2018 - CR-20180607-12270 - Veriable to control method execution
    public static Boolean BYPASS_MULTIPLE_EXECUTION_OF_reparentComponentSubscriptionsOnAmendment = false;
    public static Boolean BYPASS_SCHEDULER_FOR_SUBSCRIPTION_PERIOD = false;
   
    public static Boolean IS_STATUS_CHANGED_FOR_REPARENTING = false;
    
    public static Boolean IS_RUNNING_FROM_CPQ_CONTRACTED_JOB = false;
    
    //Map to hold map to hold Component Subscription
    public static Map<String,SubscriptionPeriodAutomationWrapper> mapUniqueKeySubscriptionPeriodAutomationFinal = new Map<String,SubscriptionPeriodAutomationWrapper>();
    
    //Map to hold Program Subscription Id as key and value as key
    public static Map<Id, Set<String>> mapProgramSubscriptionwithUniqueKeyFinal = new Map <Id,Set<String>>();
    
    /*This map will fill once. It is used to reduce the SOQL on Product.
    Added by Subhash Garhwal - 07/25/2018 - CR-20180720-12454*/
    public Static Map<Id, Product2> mapProductIdWithTypeStatic = new Map<Id, Product2>();

    //Flag to contol the trigger execution 
    public static Boolean SYNC_SHADOW_ABC_WITH_SUBSCRIPTION = false;
    
    //VH 7/5/17: populate the quantity based on the segmentQuantity field, because it's not auto-populating for Subscription years 2+
    public static void populateQuantity(List<SBQQ__Subscription__c> subscriptions) {
        
        for (SBQQ__Subscription__c subscription : subscriptions) {
            
            //Modified by Mahendra - CR-20210613-15207 - 06/13/2021 - Only populte Quantity if it is null or equals to zero
            //only update the quantity if the segmentQuantity is populated
            if ((subscription.SBQQ__Quantity__c == null || subscription.SBQQ__Quantity__c == 0) && subscription.SBQQ__SegmentQuantity__c != null)
                subscription.SBQQ__Quantity__c = subscription.SBQQ__SegmentQuantity__c;
        }
    }
    
    /**
     *  @description    :  Method to check if future is running from CPQ Contracted future job and bypass Subscription trigger if it is running and call a schduler to perform all the updates.
     *
     *  @args           :  List<SBQQ__Subscription>   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 03/05/2019 - Subhash Garhwal - CR-20181019-12685
     * 
     **/
    public static void validateCPQProcessAndByPassTrigger(List<SBQQ__Subscription__c> subscriptions, Boolean isInsertCase) {
      
      //SOQL over the AsyncApexJob to get the future job details
      List<AsyncApexJob> asyncApexJob = [Select Id From AsyncApexJob Where Status = 'Processing' AND ApexClass.Name = 'OpportunityService' AND MethodName = 'contractQuotesDeferred' LIMIT 1];
      
      List<AsyncApexJob> subTriggerAsyncApexJob = [Select Id From AsyncApexJob Where ApexClass.Name = 'Sched_SubscriptionTrigger' AND Status NOT IN ('Failed', 'Completed', 'Aborted') LIMIT 1];

      
      //Check for size
      if(asyncApexJob.size() > 0 && subTriggerAsyncApexJob.size() == 0) {
        
        //Set variable to true
        IS_RUNNING_FROM_CPQ_CONTRACTED_JOB = true;
        
        //Call Scheduler from here
        Sched_SubscriptionTrigger.scheduleSubscriptionTrigger(subscriptions, isInsertCase);
      }
    }
    
    /**
     *  @description    :  Method to set the BYPASS_PROPOSAL_AND_LINES_TRIGGER variable value when Customer Price is updated
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 09/20/2017 - Victor Hanson - Issue--CR11375--QA--00005830
     * 
     **/
    public static void setProposalAndLineByPassFlag(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
      
      //Loop over the SBQQ__Subscription__c
      for(SBQQ__Subscription__c subscription : subscriptions) {
      
            //Check for Customer Price change
            if(mapOldSubscriptions != null && mapOldSubscriptions.containsKey(subscription.Id) && subscription.SBQQ__CustomerPrice__c != mapOldSubscriptions.get(subscription.Id).SBQQ__CustomerPrice__c)
                ContractTriggerHelper.BYPASS_PROPOSAL_AND_LINES_TRIGGER = true;
      }
    }
    
    /**
     * 
     *  @description    :   Method to populate "Previous Component Subscription" so we can reference the prior segment's values.
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/23/2017 - Victor Hanson - CPQ10
     *                      V_1.1 - Modified - 3/06/2018 - Subhash Garhwal - CR-20180301-12089
     *          	    V_1.2 - Modified By Abhinav Sharma - CR-20180521-12237 - 02/04/2019
     * 
     **/
    public static void populatePrevComponentSubscription(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriotions) {
    
        //map<ContractID + RequiredByID + ProductID + StartYear, SBQQ__Subscription__c>
        Map<string, SBQQ__Subscription__c> mapKeyToComponentSubscription = new Map<string, SBQQ__Subscription__c>();
        set<Id> contractIds = new set<Id>();
        
	for (SBQQ__Subscription__c subscription : subscriptions) {
          
	    //03/06/2018 - CR-20180301-12089 - Added check to avoid too many SOQL issue
            if(subscription.RecordTypeId == CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT && 
              (mapOldSubscriotions == null || subscription.SBQQ__Contract__c != mapOldSubscriotions.get(subscription.Id).SBQQ__Contract__c
                || subscription.SBQQ__RequiredByProduct__c != mapOldSubscriotions.get(subscription.Id).SBQQ__RequiredByProduct__c
                || subscription.SBQQ__Product__c != mapOldSubscriotions.get(subscription.Id).SBQQ__Product__c
                || subscription.SBQQ__SegmentStartDate__c != mapOldSubscriotions.get(subscription.Id).SBQQ__SegmentStartDate__c)) {
                  
		//get all contract ids
                contractIds.add(subscription.SBQQ__Contract__c);
                
                //add component subscriptions to the map
                mapKeyToComponentSubscription.put(getSubscriptionKey(subscription, null), subscription);
                      
	      }
        }
        
	if (contractIds.size() > 0) {
            
          //get all component subscriptions on the contract
            mapKeyToComponentSubscription = getComponentSubscriptionsFromContracts(contractIds);
            
            //loop through subscriptions and populate the previous component subscription
            for (SBQQ__Subscription__c subscription : subscriptions) {
              
	      	if (subscription.SBQQ__SegmentStartDate__c != null && mapKeyToComponentSubscription != null) {
                
			SBQQ__Subscription__c prevSubscription = mapKeyToComponentSubscription.get(getSubscriptionKey(subscription, subscription.SBQQ__SegmentStartDate__c.Year()-1));
                    
		    	//Modified By Abhinav Sharma - CR-20180521-12237 - 02/04/2019 - 
			//Added a another condition - prevSubscription.Id != subscription.Id to fix the circular Bug. 
			if (prevSubscription != null && prevSubscription.Id != subscription.Id) {
                      		subscription.Previous_Component_Subscription__c = prevSubscription.Id;
                    	}
		}
            }
        }
    }
    
  //get a map of component subscriptions
  //returns map<ContractID + RequiredByProduct + ProductID + StartYear, Subscription>
  public static map<string, SBQQ__Subscription__c> getComponentSubscriptionsFromContracts(set<Id> contractIds) {
    
    map<string, SBQQ__Subscription__c> mapKeyToComponentSubscription = new map<string, SBQQ__Subscription__c>();
        
        //get all component subscriptions on the contract
        for (SBQQ__Subscription__c subscription : [SELECT Id, SBQQ__SegmentStartDate__c, SBQQ__Contract__c, Customer_Amount__c, SBQQ__ListPrice__c,
                                                    Program_Subscription__c, SBQQ__Product__c, SBQQ__RequiredByProduct__c
                                                    FROM SBQQ__Subscription__c 
                                                    WHERE SBQQ__Contract__c IN :contractIds AND RecordTypeId = :CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT AND SBQQ__Quantity__c >= 1]) {
            
            mapKeyToComponentSubscription.put(getSubscriptionKey(subscription, null), subscription);
        }
        
        return mapKeyToComponentSubscription;
    }
    
    /**
     * 
     *  @description    :   Helper method to assist with creating a unique key to identify subscriptions
     *
     *  @args           :   List<SBQQ__Subscription__c>, decimal
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/23/2017 - Victor Hanson - CPQ10
     * 
     **/
    public static string getSubscriptionKey(SBQQ__Subscription__c subscription, integer startYear) {
        
        if (startYear == null) {
            if (subscription.SBQQ__SegmentStartDate__c != null)
              startYear = subscription.SBQQ__SegmentStartDate__c.Year();
        }
        return subscription.SBQQ__Contract__c + '-' + subscription.SBQQ__RequiredByProduct__c + '-' + subscription.SBQQ__Product__c + '-' + startYear;
    }
    
    /**
     * 
     *  @description    :   Method to populate "Renewal_Date1__c" field on case records associated with memberships, due to formula reference limit.
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/22/2017 - Abhinav Sharma - DS114
     * 
     **/
    public static void populateFieldsValueOnCases(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
        
        //populate program and membership ids from the subscriptions
        Map<Id, SBQQ__Subscription__c> mapOfEligibleSubscriptions = new Map<Id, SBQQ__Subscription__c>();
        
        //Checking for update use case
        if(subscriptions != null && mapOldSubscriptions != null) {
        
            //Loop through Subscription records
            for (SBQQ__Subscription__c sub : subscriptions) {
                    
                //Checking for field value changes
                if(mapOldSubscriptions == null || sub.SBQQ__SubscriptionEndDate__c != mapOldSubscriptions.get(sub.Id).SBQQ__SubscriptionEndDate__c)
                    mapOfEligibleSubscriptions.put(sub.Id, sub);
            }
            
            //Checking set for its size
            if(mapOfEligibleSubscriptions.values().size() > 0) {
                    
                //List of cases to be updated
                Map<Id, Case> mapOfCasesToBeUpdated = new Map<Id, Case>();
                    
                //Loop through case records
                for(Case cs : [SELECT ID, Renewal_Date1__c, Membership__r.Latest_Subscription__r.SBQQ__SubscriptionEndDate__c,
                               Membership__r.Latest_Subscription__r.SBQQ__Contract__c,
                               Membership__r.Latest_Subscription__r.SBQQ__Contract__r.EndDate
                               FROM Case
                               WHERE Membership__c != null
                               AND Membership__r.Latest_Subscription__c != null
                               AND Membership__r.Latest_Subscription__c IN : mapOfEligibleSubscriptions.keySet()
                              ]
                ) {
                    
                    //Checking if "SBQQ__SubscriptionEndDate__c" is having non null value with it
                    if(cs.Membership__r.Latest_Subscription__r.SBQQ__SubscriptionEndDate__c != null) {
                        
                        //Checking for values difference and accordingly adding instances to the collection
                        if(cs.Renewal_Date1__c != cs.Membership__r.Latest_Subscription__r.SBQQ__SubscriptionEndDate__c) {
                            cs.Renewal_Date1__c = cs.Membership__r.Latest_Subscription__r.SBQQ__SubscriptionEndDate__c;
                            mapOfCasesToBeUpdated.put(cs.Id, cs);   
                        }
                    } else {
                        
                        //Checking contract reference for non null value
                        if(cs.Membership__r.Latest_Subscription__r.SBQQ__Contract__c != null) {
                            if(cs.Renewal_Date1__c != cs.Membership__r.Latest_Subscription__r.SBQQ__Contract__r.EndDate) {
                                cs.Renewal_Date1__c = cs.Membership__r.Latest_Subscription__r.SBQQ__Contract__r.EndDate;
                                mapOfCasesToBeUpdated.put(cs.Id, cs);
                            }
                        } else {
                            if(cs.Renewal_Date1__c != null) {
                                cs.Renewal_Date1__c = null;
                                mapOfCasesToBeUpdated.put(cs.Id, cs);
                            }
                        }
                    }
                }
                    
                //Checking map for its size
                if(mapOfCasesToBeUpdated.values().size() > 0) {
                    
                    //Bypassing triggers
                    Util.byPassAllTriggers = true;
                    
                    //Update cases
                    update mapOfCasesToBeUpdated.values();
                    
                    //Enabling triggers
                    Util.byPassAllTriggers = false;
                }                                               
            }
        }       
    }
    
    /**
     * 
     *  @description    :   populate subscription fields based on relationship records, due to formula reference limit
     *
     *  @args           :   List<SBQQ__Subscription__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 04/26/2017 - Victor Hanson - CR-20170403-10807
     *                      V_1.1 - Modified By - 03/05/2018 - Abhishek Mishra - CR-20180301-12089 - Commented out few lines to save the query
     *              	    V_1.2 - Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
     * 
    **/
    public static void populateSubscriptionFields(List<SBQQ__Subscription__c> subscriptions, map<Id, SBQQ__Subscription__c> oldSubscriptionMap) {
        
        //populate program and membership ids from the subscriptions
        set<Id> programIds = new set<Id>();
        set<Id> membershipIds = new set<Id>();
        set<Id> programSubscriptionIds = new set<Id>();
        Set<Id> setRenewalOpportunitiesIds = new Set<Id>();
        Set<Id> setSourceOpportunitiesIds = new Set<Id>();
        set<Id> setQuoteLines = new set<Id>();
        
        for (SBQQ__Subscription__c sub : subscriptions) {
            
            //get old subscription
            SBQQ__Subscription__c oldSub;
            
            if (oldSubscriptionMap != null) oldSub = oldSubscriptionMap.get(sub.Id);
            
            if (sub.Program__c != null && (oldSub == null || oldSub != null && sub.Program__c != oldSub.Program__c)) 
                programIds.add(sub.Program__c);
            
            if (sub.Membership__c != null && (oldSub == null || oldSub != null && sub.Membership__c != oldSub.Membership__c)) 
                membershipIds.add(sub.Membership__c);
            
            if (sub.Program_Subscription__c != null && (oldSub == null || oldSub != null && sub.Program_Subscription__c != oldSub.Program_Subscription__c)) 
                programSubscriptionIds.add(sub.Program_Subscription__c);
            
            if (Sub.Renewal_Opportunity__c != null) 
                setRenewalOpportunitiesIds.add(sub.Renewal_Opportunity__c);
            
            if (sub.Source_Opportunity__c != null && (oldSub == null || oldSub != null && sub.Source_Opportunity__c != oldSub.Source_Opportunity__c)) 
                setSourceOpportunitiesIds.add(sub.Source_Opportunity__c);
            
            //VH updated 3/13/18 - Only add the quote line if it's a Component Subscription
            if (sub.SBQQ__QuoteLine__c != null
                && sub.RecordTypeId == Constants.RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT
                && (sub.SBQQ__SegmentStartDate__c == null || sub.SBQQ__SegmentIndex__c == null)) 
            {
                setQuoteLines.add(sub.SBQQ__QuoteLine__c);
            }
            
        }
            
        //create a map of programs, subscriptions, memberships
        map<Id, Program__c> programMap = new map<Id, Program__c>();
        map<Id, SBQQ__Subscription__c> subscriptionMap = new map<Id, SBQQ__Subscription__c>();
        map<Id, Membership__c> membershipMap = new map<Id, Membership__c>();
        
        if (programIds.size() > 0)
          programMap = new map<Id, Program__c>([SELECT Id, Account_Management_Reporting_Group__c FROM Program__c WHERE Id IN :programIds]);
        
        //Modified BY - Mahendra Swarnkar - 12/06/2017 - CR-20171204-11830 - Starts from here
        //Updated the if condition to checck for the programSubscriptionIds and membershipIds size, instead of subscriptionMap size and membershipMap size respectively
        if (programSubscriptionIds.size() > 0)
            subscriptionMap = new map<Id, SBQQ__Subscription__c>([SELECT Id, Program__r.Name, SBQQ__CustomerPrice__c, Status__c FROM SBQQ__Subscription__c WHERE Id IN :programSubscriptionIds]);
        
        //Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
        if (membershipIds.size() > 0)
            membershipMap = new map<Id, Membership__c>([SELECT Id, DA_Assignment_Text__c, Dedicated_Advisor_Pod_Lead__c/*,
            						/*Delivery_Manager__c, Delivery_Manager__r.FirstName, Delivery_Manager__r.LastName*/
                                                        FROM Membership__c WHERE Id IN :membershipIds]);
        //Modified BY - Mahendra Swarnkar - 12/06/2017 - CR-20171204-11830 -- Ends here
        
        map<Id, SBQQ__QuoteLine__c> quoteLineMap;
        
        //get map of quote lines
        if (setQuoteLines.size() > 0) {
            quoteLineMap = new map<Id, SBQQ__QuoteLine__c>([SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SegmentIndex__c,
                                                            SBQQ__SegmentLabel__c, SBQQ__SegmentKey__c
                                                            FROM SBQQ__QuoteLine__c 
                                                            WHERE Id IN :setQuoteLines]);
        }
        
        //Map of opportunities
        Map<Id, Opportunity> mapOfRenewalOpportunities = new Map<Id, Opportunity>();
        Map<Id, Opportunity> mapOfSourceOpportunities = new Map<Id, Opportunity>();
    
        //Modified By Abhishek Mishra - CR-20180301-12089 - Commented above logic and added this Logic to save the Query - Resolving the Too Many SOQL - 201 Error 
        //Check the size of Set
        if(setRenewalOpportunitiesIds.size() > 0 || setSourceOpportunitiesIds.size() > 0) {        
       
            //query on the Opportunity
            for(Opportunity opp : [SELECT ID, CloseDate, Decision_Type__c, End__c, Name, Probability, Main_Contact__c, Main_Contact__r.FirstName, 
                                            Main_Contact__r.LastName,OwnerID, Owner.Name,
                                            Renewal_Credit__c, Amount, Stagename, Start__c, Proposal_Value_Read__c,
                                            Pool_Year__c, Pool_Month__c
                                            FROM Opportunity  WHERE ID IN : setSourceOpportunitiesIds OR ID IN: setRenewalOpportunitiesIds] ) {
                                                                     
                //Check for the set ID and fill the Map, if condition match
                if(setRenewalOpportunitiesIds.contains(opp.Id)) {
                    mapOfRenewalOpportunities.put(opp.Id, opp);
                }
                
                //Check for the Set and fil the Map if condition Match
                if(setSourceOpportunitiesIds.contains(opp.Id)) {
                    mapOfSourceOpportunities.put(opp.Id, opp);
                }
            }
        }
        //CR-20180301-12089 - ends Here 
        
        //populate the fields on subscription
        for (SBQQ__Subscription__c sub : subscriptions) {
            
            if (sub.Program__c != null && programMap.containsKey(sub.Program__c)) {
                sub.Account_Management_Reporting_Group__c = programMap.get(sub.Program__c).Account_Management_Reporting_Group__c;
            }
            
            /*if (sub.Program_Subscription__c != null && subscriptionMap.containsKey(sub.Program_Subscription__c)) {
                sub.Program_Subscription_Name__c = subscriptionMap.get(sub.Program_Subscription__c).Program__r.Name;
            } */
            
            if (sub.Membership__c != null && membershipMap.containsKey(sub.Membership__c)) {
                Membership__c membership = membershipMap.get(sub.Membership__c);
                sub.DA__c = membership.DA_Assignment_Text__c;
                sub.Dedicated_Advisor_Pod_Lead__c = membership.Dedicated_Advisor_Pod_Lead__c;
                //Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
                /* if (membership.Delivery_Manager__c != null)
                    sub.Delivery_Manager__c = membership.Delivery_Manager__r.FirstName + ' ' + membership.Delivery_Manager__r.LastName;*/
            }
            
            //on amendments, we need to populate fields on the subscription that don't carry over from related quoteLine
            if (quoteLineMap != null && quoteLineMap.containsKey(sub.SBQQ__QuoteLine__c)) {
                SBQQ__QuoteLine__c qL = quoteLineMap.get(sub.SBQQ__QuoteLine__c);
                sub.SBQQ__SegmentStartDate__c = qL.SBQQ__StartDate__c;
                sub.SBQQ__SegmentEndDate__c = qL.SBQQ__EndDate__c;
                sub.SBQQ__SegmentIndex__c = qL.SBQQ__SegmentIndex__c;
                sub.SBQQ__SegmentLabel__c = qL.SBQQ__SegmentLabel__c;
                sub.SBQQ__SegmentKey__c = qL.SBQQ__SegmentKey__c;
            }
            
            //Checking for the null value
            if(sub.Renewal_Opportunity__c != null && mapOfRenewalOpportunities.containsKey(sub.Renewal_Opportunity__c)) {
                sub.Renewal_Opp_Stage__c = mapOfRenewalOpportunities.get(sub.Renewal_Opportunity__c).StageName;
                
                //Checking if main contact exists on subscription record
                if(mapOfRenewalOpportunities.get(sub.Renewal_Opportunity__c).Main_Contact__c != null) {
                    
                    String mainContactName = '';
                
                    if(String.isNotBlank(mapOfRenewalOpportunities.get(sub.Renewal_Opportunity__c).Main_Contact__r.FirstName))
                        mainContactName += mapOfRenewalOpportunities.get(sub.Renewal_Opportunity__c).Main_Contact__r.FirstName + ' ';
                        
                    mainContactName += mapOfRenewalOpportunities.get(sub.Renewal_Opportunity__c).Main_Contact__r.LastName;
                    
                    sub.Renewal_Opportunity_Main_Contact__c = mainContactName;
                
                } else {
                    sub.Renewal_Opportunity_Main_Contact__c = '';
                }
                
                //Checking for the field value
                if(mapOfRenewalOpportunities.get(sub.Renewal_Opportunity__c).OwnerID != null)
                    sub.Renewal_Opportunity_Owner_Name__c = mapOfRenewalOpportunities.get(sub.Renewal_Opportunity__c).Owner.Name;
                else
                    sub.Renewal_Opportunity_Owner_Name__c = '';
                
            } else {
                sub.Renewal_Opp_Stage__c = '';
                sub.Renewal_Opportunity_Main_Contact__c = '';
                sub.Renewal_Opportunity_Owner_Name__c = '';
            }
                
            //Checking for the null value 
            if(sub.Source_Opportunity__c != null && mapOfSourceOpportunities.containsKey(sub.Source_Opportunity__c)) {
                sub.Source_Opportunity_Close_Date__c = mapOfSourceOpportunities.get(sub.Source_Opportunity__c).CloseDate;
                sub.Source_Opportunity_Decision_Type__c = mapOfSourceOpportunities.get(sub.Source_Opportunity__c).Decision_Type__c;
                sub.Source_Opportunity_End_Date__c = mapOfSourceOpportunities.get(sub.Source_Opportunity__c).End__c;
                sub.Source_Opportunity_Name__c = mapOfSourceOpportunities.get(sub.Source_Opportunity__c).Name;
                sub.Source_Opportunity_Probability__c = mapOfSourceOpportunities.get(sub.Source_Opportunity__c).Probability;
                sub.Source_Opportunity_Proposal_Value_Read__c = mapOfSourceOpportunities.get(sub.Source_Opportunity__c).Proposal_Value_Read__c;
                sub.Source_Opportunity_Stagename__c = mapOfSourceOpportunities.get(sub.Source_Opportunity__c).Stagename;
                sub.Source_Opportunity_Start__c = mapOfSourceOpportunities.get(sub.Source_Opportunity__c).Start__c;
                sub.Source_Opportunity_Pool_Year__c = mapOfSourceOpportunities.get(sub.Source_Opportunity__c).Pool_Year__c;
                sub.Source_Opportunity_Pool_Month__c = mapOfSourceOpportunities.get(sub.Source_Opportunity__c).Pool_Month__c;
            }
            else {
                sub.Source_Opportunity_Close_Date__c = null;
                sub.Source_Opportunity_Decision_Type__c = '';
                sub.Source_Opportunity_End_Date__c = null;
                sub.Source_Opportunity_Name__c = '';
                sub.Source_Opportunity_Probability__c = null;
                sub.Source_Opportunity_Proposal_Value_Read__c = null;
                sub.Source_Opportunity_Stagename__c = '';
                sub.Source_Opportunity_Start__c = null;
                sub.Source_Opportunity_Pool_Year__c = null;
                sub.Source_Opportunity_Pool_Month__c = null;
            }
        }
    }
    
    /**
     * 
     *  @description    :   populate Value Management Director, Value Management Lead of Membership on Subscription
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created - 05/10/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807
     *             	    V1.2 - Modified -08/10/2017 - Deepak Kumar - Issue--CR11094--QA--00005406
     *            	    V1.3 - Modified - 03/26/2018 - Subhash Garhwal - CR-20180313-12103 - Modify "populateSubscriptionFieldsBasedOnMembership" method of the SBQQ_SubscriptionTriggerHelper to update the "GAAP_Negotiated_Amount__c" field with Negotiated_Amount_Subscription__c in case of the insert only.
     * 			    V1.4 - Modified - 07/04/2019 - Mahendra Swarnkar - CR-20181019-12685 - Commented the code "population of 'GAAP_Negotiated_Amount__c'" in the method "rollupDetailsonProgramSubscriptionFromComponentSubscription"  
     *
     **/
     public static void populateSubscriptionFieldsBasedOnMembership(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
		/*
        //Set to hold Membership
        Set<Id> setMembershipId = new Set<Id>();

        //Loop through the Subscription
        for(SBQQ__Subscription__c subscription : subscriptions){

            //Check for Membership
            if(subscription.Membership__c != null &&(mapOldSubscriptions == null || subscription.Membership__c != mapOldSubscriptions.get(subscription.Id).Membership__c))
                setMembershipId.add(Subscription.Membership__c);
    
        }

        //Process if Size is greater than zero
        if(setMembershipId.Size() > 0) {

            //Map to hold MemberShip
            Map<Id,MemberShip__c> mapOfMemberships = new Map<Id, MemberShip__c >([Select Id From Membership__c Where Id IN: setMembershipId]);
			
            //Commented via spring cleanup wave 3 - Starts from here
            
            //Loop through Subscription
            //for(SBQQ__Subscription__c subscription : subscriptions) {

                //Modified by Subhash Gharwal 04/29/2019 - Spring cleanup - CR-20190425-13035  
                //Process if Membership contain in Map
                //  if(mapOfMemberships.containsKey(subscription.Membership__c)) {

                //Update value
                //    subscription.Value_Management_Director__c = mapOfMemberships.get(subscription.Membership__c).Value_Management_Director__c;
                //   subscription.Value_Management_Lead__c = mapOfMemberships.get(subscription.Membership__c).Value_Management_Lead__c;
                //}
            //}
            //Commented via spring cleanup wave 3 - Ends here
        }
        
        //Added by: Deepak Kumar - Issue--CR11094--QA--00005406 (GAAP Negotiated Amount field should equal whatever the Negotiated Amount (CPQ Subscription) field)
        //Loop through the subscriptions records 
        for (SBQQ__Subscription__c subscription : subscriptions) {
            
            //Subhash Garhwal - 03/26/2018 - CR-20180313-12103 - Added check for insert case
            if(mapOldSubscriptions == null || IS_INSERT_CASE) {
              
            //Populate the GAAP_Negotiated_Amount__c on the basis of Negotiated_Amount_Subscription__c field value 
            subscription.GAAP_Negotiated_Amount__c = subscription.Negotiated_Amount_Subscription__c;      
            }
        }
        */
    }
    
    /**
     * 
     *  @description    :   This method is used to populate Previous Subscription Negotiated field value.
     *                      Rule: If Previous Contract ABC has a value, then use Previous Contract ABC.Negotiated Amount, else if Previous Subscription
     *                            has a value, use Previous Subscription.Negotited Amount, else 0
     *                            Autopopulate Renewal_Type__c on subscription 
     *                            If Previous Program Subscription is blank AND Previous Contract ABC is blank, then 'Initial' else 'Continuing'
     *
     *
     *  @args           :   List<SBQQ__Subscription__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created - 05/11/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807
     *                      V1.2 - Updated - 06/15/2017 - Subhash Garhwal - Q2C Phase 2  
     *
     **/
    public static void validatePreviousSubscriptionNegotiated(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions ) {
        
        //Set to hold the Previous Contract ABC Ids
        Set<Id> setContractABCIds = new Set<Id>();
        
        //Set to hold the Previous Subscription Ids
        Set<Id> setPreviousSubscriptionIds = new Set<Id>();
        
        //Loop over the subscriptions
        for(SBQQ__Subscription__c sub : subscriptions) {
            
            //Check for Contract ABC
            if(sub.Previous_Contract_ABC__c != null && (mapOldSubscriptions == null || sub.Previous_Contract_ABC__c !=  mapOldSubscriptions.get(sub.Id).Previous_Contract_ABC__c))
                setContractABCIds.add(sub.Previous_Contract_ABC__c); 
            
            //Check for Previous Subscription
            if(sub.Previous_Program_Subscription__c != null && (mapOldSubscriptions == null || sub.Previous_Program_Subscription__c !=  mapOldSubscriptions.get(sub.Id).Previous_Program_Subscription__c))
                setPreviousSubscriptionIds.add(sub.Previous_Program_Subscription__c);

            //Check for Contract ABC and Previous Subscription
            if(sub.Previous_Program_Subscription__c == null && sub.Previous_Contract_ABC__c == null  &&
              (mapOldSubscriptions == null || sub.Previous_Contract_ABC__c !=  mapOldSubscriptions.get(sub.Id).Previous_Contract_ABC__c ||
              sub.Previous_Program_Subscription__c !=  mapOldSubscriptions.get(sub.Id).Previous_Program_Subscription__c)) {

                    sub.Renewal_Type__c = CPQCONSTANTS.SUBSCRIPTION_RENEWAL_TYPE_INITIAL ;
            }
            else
                sub.Renewal_Type__c = CPQCONSTANTS.SUBSCRIPTION_RENEWAL_TYPE_CONTINUING;
        }
        
        //Check for set size
        if(setContractABCIds.size() > 0 || setPreviousSubscriptionIds.size() > 0) {
            
            //Map to hold the Contract ABC
            Map<Id, Contract__c> mapContractABCs = new Map<Id, Contract__c>([Select Id, Negotiated_Amount__c, Term_Type__c From Contract__c Where Id IN : setContractABCIds]);
            
            //Map to hold the Previous Subscriptions
            Map<Id, SBQQ__Subscription__c> mapPreviousSubscriptions = new Map<Id, SBQQ__Subscription__c>([Select Id, Negotiated_Amount_Subscription__c, Term_Type__c From SBQQ__Subscription__c Where Id IN : setPreviousSubscriptionIds]);
            
            //Loop over the subscriptions
            for(SBQQ__Subscription__c sub : subscriptions) {

                //Check for previous subscription           
                if(sub.Previous_Program_Subscription__c != null && mapPreviousSubscriptions.containsKey(sub.Previous_Program_Subscription__c)) {
                    sub.Previous_Subscription_Negotiated_Amount__c =  mapPreviousSubscriptions.get(sub.Previous_Program_Subscription__c).Negotiated_Amount_Subscription__c;

                    //V_2.3 - Modified - 05/30/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807 - Added a new method automationSubscription
                    if(mapPreviousSubscriptions.get(sub.Previous_Program_Subscription__c).Term_Type__c == CPQConstants.TERM_TYPE_FIXED_TERM )
                        sub.Previous_Subscription_Type__c = CPQConstants.PREVIOUS_SUBSCRIPTION_TYPE_YEAR_FIXED_TERM;
                    else
                        sub.Previous_Subscription_Type__c = CPQConstants.PREVIOUS_SUBSCRIPTION_TYPE_TERM_YEAR_OPT;
                    
                }
                //Check for Contract ABC
                else if(sub.Previous_Contract_ABC__c != null && mapContractABCs.containsKey(sub.Previous_Contract_ABC__c)) {
                    sub.Previous_Subscription_Negotiated_Amount__c =  mapContractABCs.get(sub.Previous_Contract_ABC__c).Negotiated_Amount__c;

                    //V_2.3 - Modified - 05/30/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807 - Added a new method automationSubscription
                    if(mapContractABCs.get(sub.Previous_Contract_ABC__c).Term_Type__c == CPQConstants.TERM_TYPE_FIXED_TERM)
                        sub.Previous_Subscription_Type__c = CPQConstants.PREVIOUS_SUBSCRIPTION_TYPE_YEAR_FIXED_TERM;
                    else
                        sub.Previous_Subscription_Type__c =  CPQConstants.PREVIOUS_SUBSCRIPTION_TYPE_TERM_YEAR_OPT;
                }
            }
        }
    }
    
    /**
     * 
     *  @description    :   When a Subscription's Stage is updated to Void or Dropped, 
     *                      Subscriptions related to the Contract that there is at least one that is not Void/Dropped.
     *                      If all Subscriptions on the contract are void/dropped, update the related Renewal Opportunity's stage to Closed Lost.
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created - 05/12/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807
     * 
     **/
    public static void updateRenewalSubscriptionStageNameOfContract(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {

        //Map to hold Contract Id and Boolean
        Map<Id, Boolean> mapofContractIdWithBoolean =  new Map<Id, Boolean>();

        //Map to hold opportunity Id with opportunity
        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>();

        //Loop through subscription
        for(SBQQ__Subscription__c sub : subscriptions) {

            //Check For COndition
            if(sub.SBQQ__Contract__c != null && CPQConstants.SUBSCRIPTION_STAGE.contains(sub.Stage_Period__c) 
                && (mapOldSubscriptions == null || sub.Stage_Period__c !=  mapOldSubscriptions.get(sub.Id).Stage_Period__c))

                //Check for contract Id
                mapofContractIdWithBoolean.put(sub.SBQQ__Contract__c,false);
        }

        //Query through the Subscriptions 
        for(SBQQ__Subscription__c sub : [Select Id, SBQQ__Contract__c, SBQQ__Contract__r.SBQQ__RenewalOpportunity__c , Stage_Period__c,
                                                    SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.StageName From SBQQ__Subscription__c 
                                                    Where SBQQ__Contract__c IN : mapofContractIdWithBoolean.keySet() 
                                                    AND SBQQ__Contract__r.SBQQ__RenewalOpportunity__c != null
                                                    AND Stage_Period__c NOT IN : CPQConstants.SUBSCRIPTION_STAGE]) {
            
            mapofContractIdWithBoolean.put(sub.SBQQ__Contract__c,true);
        }
        
        //Set to hold the Opportunity Id
        Set<Id> setTempOppIds = new Set<Id>();
        
        //Query through Contract
        for(Contract con : [Select Id, SBQQ__RenewalOpportunity__c From Contract Where Id IN : mapofContractIdWithBoolean.keySet()
                                        AND SBQQ__RenewalOpportunity__c != null]) {
            
            //Check for Opportunity Id in map
            if(!mapOpportunities.containsKey(con.SBQQ__RenewalOpportunity__c) && !setTempOppIds.contains(con.SBQQ__RenewalOpportunity__c)
                && !mapofContractIdWithBoolean.get(con.Id))
                mapOpportunities.put(con.SBQQ__RenewalOpportunity__c , new Opportunity(Id = con.SBQQ__RenewalOpportunity__c,
                                                                                        StageName = CPQConstants.OPPORTUNITY_STAGENAME_CLOSED));
            
            //Check if Contract have a non void subscription
            if(mapofContractIdWithBoolean.get(con.Id) && mapOpportunities.containsKey(con.SBQQ__RenewalOpportunity__c)) {
                
                //Remove Opportunity from map
                mapOpportunities.remove(con.SBQQ__RenewalOpportunity__c);
                
                //Add Opp Id in map
                setTempOppIds.add(con.SBQQ__RenewalOpportunity__c);
            }
        }

        //Check for size
        if(mapOpportunities.Size()>0) {
            Util.byPassAllTriggers = true;
            update mapOpportunities.Values();
            Util.byPassAllTriggers = false;
        }
    }
    
    /**
     * 
     *  @description    :   When Component Subscription is created or Component Subscription's Parent Product is updated and 
                            Product on Program Subscription on the same Contract is equals to Component Subscription's Parent Product
                            then populate Program_Subscription__c on the current Subscription = Id of Program Subscription.
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created - 05/17/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807
     *                      V1.2 - Modified By - Subhash Garhawal - 10/11/2018 - CR-20180720-12456
     *                      V1.3 - Modified By - Subhash Garhawal - 12/05/2018 - CR-20181120-12756
     *                      V1.3 - Modified By - Subhash Garhawal - 12/19/2018 - Modified method for new "Enrollment Services" setup.
     *                      V1.3 - Modified By - Victor Hanson - 01/02/2018 - Populate Program Subscription on Enrollment Services program subscriptions 
     *                                                                         with a parent program subscription.  IE: Inquiry Pool has a Parent Prog Sub of ESAM
     *            	    V1.4 - Modified By - Subhash Garhwal - 02/28/2019 - CR-20181019-12685 - Populate Top Related Product field on the Component Subscriptions.
     *                                                                                              IE: Program Costs Comp --> Inquiry Pool Progam Sub. --> ESAM
     *                                                                                              than Program Costs will hold ESAM value.
     *            	    V1.5 - Modified By - Subhash Garhawal - 03/11/2019 - Program Subscriptions are not poulating correcttly on the Component Subscriptions
     *                                                                           so changed code logic.
     
     * 
     **/
    public static void populateProgramSubscription(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions){
        
        //Set to hold the component Sub Ids
        Set<Id> setCompSubscriptionIds = new Set<Id>();
        
        //Set to hold the Required by Subscription Id
        Set<Id> setRequiredBySubId = new Set<Id>();

        //Processing on the new records
        for(SBQQ__Subscription__c subscription : subscriptions){

            //Checking whether record is inserting or updating and processing on it accordingly
            //Subhash Garhwal - 12/19/2018 - ES - Removed "subscription.RecordTypeId == componentRecordType &&" check to work it for ES Products as well
            if(subscription.SBQQ__RequiredById__c != null && (mapOldSubscriptions == null || subscription.SBQQ__RequiredById__c != mapOldSubscriptions.get(subscription.Id).SBQQ__RequiredById__c)){
                
                //Add Required by in set
                setRequiredBySubId.add(subscription.SBQQ__RequiredById__c);
                
                //Add Comp Sub Id in map
                setCompSubscriptionIds.add(subscription.Id);
      }   
        }
        
        //Checking set size
        if(setRequiredBySubId.size() > 0){

            //Map to hold the program record types
            Map<Id, SBQQ__Subscription__c> mapProgramSubscriptions = new Map<Id, SBQQ__Subscription__c>([Select Id, SBQQ__Contract__c, SBQQ__Contract__r.Status, SBQQ__Product__c, SBQQ__Product__r.Name,
                                                                           SBQQ__Product__r.Family, SBQQ__RequiredByProduct__c, SBQQ__RequiredByProduct__r.Name
                                                                           From SBQQ__Subscription__c Where Id IN : setRequiredBySubId AND SBQQ__Quantity__c >= 0 AND Status__c != 'Void'
                                                                           ORDER BY CreatedDate DESC]);
            
            //Checking Program Subscription records are selected
            if(mapProgramSubscriptions.size() > 0) {
                
                //List to update Component Subscription
                List<SBQQ__Subscription__c> compSubscriptionsToUpdate = new List<SBQQ__Subscription__c>();
                
                //Processing on the new Subscriptions and update Program Subscription field on it
                for(SBQQ__Subscription__c compSub : [Select Id, Program_Subscription__c, SBQQ__Product__c, SBQQ__RequiredByProduct__c, SBQQ__RequiredById__c, SBQQ__Contract__c, RecordTypeId,
                                        RecordType.DeveloperName, Type__c From SBQQ__Subscription__c
                                                         Where Id IN : setCompSubscriptionIds ORDER BY RecordType.DeveloperName DESC]) {
                                                       
          
                    //Checking whether Product and Parent Product are the same on Program Subscription and new Subscription respectively
                    if(mapProgramSubscriptions.containsKey(compSub.SBQQ__RequiredById__c)) {
                        
                        //Get Program Subscription
			SBQQ__Subscription__c proSub = mapProgramSubscriptions.get(compSub.SBQQ__RequiredById__c);
                        //Update Program subscription
                        compSub.Program_Subscription__c = proSub.Id;
                        
                        //Subhash Garhwal - 02/28/2019 - Added code to populate Top_Related_Product__c
                        if(proSub.SBQQ__RequiredByProduct__c != null)
                          compSub.Top_Related_Product__c = proSub.SBQQ__RequiredByProduct__r.Name;
                        else if(proSub.SBQQ__Product__c != null)
                          compSub.Top_Related_Product__c = proSub.SBQQ__Product__r.Name;   
                        
                        //Check record type
                        if(compSub.Type__c != 'Upsell' && compSub.RecordType.DeveloperName == CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT) {
                          
                          //Check if Contract is amended
                          if(proSub.SBQQ__Contract__c != null && proSub.SBQQ__Contract__r.Status == CPQConstants.CONTRACT_STATUS_ACTIVATED_AMENDED) {
                            
                            //Check for ES Products
                            if(proSub.SBQQ__Product__c != null && (proSub.SBQQ__Product__r.Family == CPQConstants.ES_PRODUCT_FAMILY || proSub.SBQQ__Product__r.Family == CPQConstants.ES_ALR_PRODUCT_FAMILY))
                              compSub.Type__c = 'Amendment- Re-engagement';
                            else
                              compSub.Type__c = 'Amendment';
                          
                          } else if(proSub.SBQQ__Product__c != null && (proSub.SBQQ__Product__r.Family == CPQConstants.ES_PRODUCT_FAMILY || proSub.SBQQ__Product__r.Family == CPQConstants.ES_ALR_PRODUCT_FAMILY))
                            compSub.Type__c = 'Re-engagement';  
                          
                        }
                        
                        //Add in list
                        compSubscriptionsToUpdate.add(compSub);
                    }
                }
                
                //Check for size
                if(compSubscriptionsToUpdate.size() > 0) {
                    //Util.byPassAllTriggers = true;
                    update compSubscriptionsToUpdate;
                    //Util.byPassAllTriggers = false;
                }
            }
        }
    }
    
    /**
     * 
     *  @description    :   When Component Subscription is created or Annualized Contract Value or Profit is updated rollup 
                            the fields value on the parent record that's Program Subscription
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created - 05/17/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807
     *                      V1.2 - Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
     **/
    public static void calculateACVAndProfit(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions){
        
        //Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
        //Get all record types of SBQQ__Subscription__c
        Map<String, Id> mapSubscriptionRecordTypes = new Map<String, Id>();
        mapSubscriptionRecordTypes = Constants.MAP_SUBSCRIPTION_RTYPE;
        
        //Component Record Type
        String componentRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT);
        
        //Map to hold parent records
        Map<Id, SBQQ__Subscription__c> mapProgramSubscriptions = new Map<Id, SBQQ__Subscription__c>();
            
        //Checking whether records are inserting or updating
        for(SBQQ__Subscription__c subscription : subscriptions != null ? subscriptions : mapOldSubscriptions.values()){
            
            //If Subscription Record Type is not equal to Component Record Type then skip the process
            if(subscription.RecordTypeId != componentRecordType)
                continue;
            
            //Checking for insert case
            if(mapOldSubscriptions == null && subscription.Program_Subscription__c != null && ( subscription.Annualized_Contract_Value__c != null || subscription.Profit_m__c != null))
                mapProgramSubscriptions.put(subscription.Program_Subscription__c, new SBQQ__Subscription__c(Id = subscription.Program_Subscription__c, Annualized_Contract_Value__c = 0, Profit_m__c = 0));
            
            //Checking for update case
            else if(mapOldSubscriptions != null && subscription.Program_Subscription__c != null &&
                    (subscription.Program_Subscription__c != mapOldSubscriptions.get(subscription.Id).Program_Subscription__c
                        ||
                     subscription.Annualized_Contract_Value__c != mapOldSubscriptions.get(subscription.Id).Annualized_Contract_Value__c
                        ||
                     subscription.Profit_m__c != mapOldSubscriptions.get(subscription.Id).Profit_m__c)) {
                        
                //New Parent record
                mapProgramSubscriptions.put(subscription.Program_Subscription__c, new SBQQ__Subscription__c
                                            (Id = subscription.Program_Subscription__c, Annualized_Contract_Value__c = 0,Profit_m__c = 0));
                
                if(mapOldSubscriptions.containsKey(subscription.Id) && mapOldSubscriptions.get(subscription.Id).Program_Subscription__c != null)
                   //Old Parent record
                   mapProgramSubscriptions.put(mapOldSubscriptions.get(subscription.Id).Program_Subscription__c, new SBQQ__Subscription__c(
                                            Id = mapOldSubscriptions.get(subscription.Id).Program_Subscription__c, Annualized_Contract_Value__c = 0, Profit_m__c = 0));    
          }
          
         //Checking for delete for case
         if(subscriptions == null && subscription.Program_Subscription__c != null)
              mapProgramSubscriptions.put(subscription.Program_Subscription__c,new SBQQ__Subscription__c (Id = subscription.Program_Subscription__c, Annualized_Contract_Value__c = 0,Profit_m__c = 0));
        }
        
        //Checking for map size
        if(mapProgramSubscriptions.size() > 0){
            
            //Aggregate query
            for(AggregateResult result : [Select Program_Subscription__c programSubscription,SUM(Annualized_Contract_Value__c) totalACV, SUM(Profit_m__c) totalProfit
                                                    FROM SBQQ__Subscription__c Where Program_Subscription__c != null AND Program_Subscription__c IN: mapProgramSubscriptions.keySet()
                                                    GROUP BY Program_Subscription__c]) {
                
                //Get the Program Subscription Id
                Id proSubscriotionId =  (Id)result.get('programSubscription');
                                                                    
                
                //mapProgramSubscriptions.get((Id)result.get('programSubscription')).add(Annualized_Contract_Value__c = (Decimal)(result.get('totalACV')),Profit__c = (Decimal)(result.get('Profit__c')));
                mapProgramSubscriptions.get(proSubscriotionId).Annualized_Contract_Value__c = (Decimal)(result.get('totalACV'));
                mapProgramSubscriptions.get(proSubscriotionId).Profit_m__c = (Decimal)(result.get('totalProfit'));
            } 
        }
        
        //Checking for map size
        if(mapProgramSubscriptions.size() > 0){
            
            //Bypass the trigger
            Util.BypassAllTriggers = true;
            
            update mapProgramSubscriptions.values();
            
            //Reset the flag
            Util.BypassAllTriggers = false;
            
        }
    }
   /**
    * 
    *   @description    :   This method used to populate joining date of Subscription based on Previous Subscription
    *
    *   @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created - 05/19/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807
    * 
    **/
    public static void populateJoiningDateOfPreviousSubscription(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions){

        //Set to hold Id
        Set<Id> setOfSubscriptionIds = new Set<Id>();

        //Loop through Subscription
        for(SBQQ__Subscription__c subscription : subscriptions ) {  

            //Check for Subscription
            If(subscription.Previous_Program_Subscription__c != null && (mapOldSubscriptions == null || 
                    subscription.Previous_Program_Subscription__c != mapOldSubscriptions.get(subscription.Id).Previous_Program_Subscription__c)) {
                    setOfSubscriptionIds.add(subscription.Previous_Program_Subscription__c );

            }
        }       

        //Check For Set size
        if(setOfSubscriptionIds.Size() > 0) {

            //Map to hold Subscription 
            Map<Id,SBQQ__Subscription__c> mapofPreviousSubscription = new Map<Id,SBQQ__Subscription__c>([Select Id, Join_Date__c  From SBQQ__Subscription__c Where Id IN : setOfSubscriptionIds ]);

            //Loop through New Subscription
            for(SBQQ__Subscription__c subscription : subscriptions) {

                //Check Map contains set
                if(mapofPreviousSubscription.ContainsKey(subscription.Previous_Program_Subscription__c))
                    subscription.Join_Date__c = mapofPreviousSubscription.get(subscription.Previous_Program_Subscription__c).Join_Date__c;
            }
        }
    }
    
    /**
    * 
    *   @description    :   This method used to populate Product Code from all Program Subscriptions to their parent i.e. Contract.
                            Product Code should be qnique
    *
    *   @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created - 05/24/2017 - Saurabh Kumar - Q2C Phase 2 - CR-20170403-10807
    *                       V1.2 - Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
    *                       V1.3 - Modified By Subhash Garhawal - 10/22/2018 - CR-20180917-12596
    * 
    **/
    public static void populateProductCode(List<SBQQ__Subscription__c> newSubscriptions, Map<Id, SBQQ__Subscription__c> oldMapSubscriptions){
        //Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
        //Get all record types of SBQQ__Subscription__c
        Map<String, Id> mapSubscriptionRecordTypes = new Map<String, Id>();
        mapSubscriptionRecordTypes = Constants.MAP_SUBSCRIPTION_RTYPE;
        
        //Component Record Type
        String programRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM);
        //Map to hold Contract Id and it's parent
        Map<Id, Contract> mapContracts = new Map<Id, Contract>();
        
        //Set to hold parent Id (Contract Id)
        Set<Id> setContractId = new Set<Id>();
        
        //Processing the new records in case of insert and update, processing on old records in case of delete
        for(SBQQ__Subscription__c subscription : newSubscriptions != null ? newSubscriptions : oldMapSubscriptions.values()){
            //Checking for record type. Skip the process if record type is not equal to Program
            //Replacing by below code : Based On CR-20190517-13115 on 06/19/2019
            if(subscription.RecordTypeId != programRecordType)
                
                //CR-20180917-12596
                continue;

            //Checking for insert case only
            if(oldMapSubscriptions == null && subscription.Product_Code__c != null && subscription.SBQQ__Contract__c != null){
                mapContracts.put(subscription.SBQQ__Contract__c, new Contract(Id = subscription.SBQQ__Contract__c, List_Of_Product_Codes__c = null));
                setContractId.add(subscription.SBQQ__Contract__c);
            }   
           
            
            //Checking for update case
            else if(newSubscriptions != null && oldMapSubscriptions != null  && (subscription.Product_Code__c != oldMapSubscriptions.get(subscription.Id).Product_Code__c
                                                    || subscription.SBQQ__Contract__c != oldMapSubscriptions.get(subscription.Id).SBQQ__Contract__c)){
                 
                 //New record detail
                mapContracts.put(subscription.SBQQ__Contract__c, new Contract(Id = subscription.SBQQ__Contract__c, List_Of_Product_Codes__c = null));
                setContractId.add(subscription.SBQQ__Contract__c);
                
                if(oldMapSubscriptions.containsKey(subscription.Id) && oldMapSubscriptions.get(subscription.Id) != null && oldMapSubscriptions.get(subscription.Id).SBQQ__Contract__c != null ){
                    
                    //Old record detail
                    mapContracts.put(subscription.SBQQ__Contract__c, new Contract(Id = oldMapSubscriptions.get(subscription.Id).SBQQ__Contract__c, List_Of_Product_Codes__c = null));
                    setContractId.add(oldMapSubscriptions.get(subscription.Id).SBQQ__Contract__c);  
                }
                  
            }
            
            //Checking for delete case
            else if(newSubscriptions == null && subscription.SBQQ__Contract__c != null){
                
                mapContracts.put(subscription.SBQQ__Contract__c, new Contract(Id = subscription.SBQQ__Contract__c, List_Of_Product_Codes__c = null));
                setContractId.add(subscription.SBQQ__Contract__c);  
            }
         }
        
        
        //Checking for map size
        if(mapContracts.size() > 0){
            
            //Set that hold the value = "ContractID + Product Code" that make the uniqness of the product code
            Set<String> setContractIdAndProductCode = new Set<String>();
            
            //Query on the Program Subscription
            for(SBQQ__Subscription__c subscription : [Select Id, SBQQ__Contract__c, Product_Code__c From SBQQ__Subscription__c
                                                      Where SBQQ__Contract__c IN : setContractId 
                                                      AND RecordTypeId =: programRecordType AND Product_Code__c != null]){
                 
                if(setContractIdAndProductCode.contains(subscription.SBQQ__Contract__c + '' + subscription.Product_Code__c))
                    continue;
                
                //Add UK in set    
                setContractIdAndProductCode.add(subscription.SBQQ__Contract__c + '' + subscription.Product_Code__c);
                
                if(mapContracts.containsKey(subscription.SBQQ__Contract__c) && mapContracts.get(subscription.SBQQ__Contract__c).List_Of_Product_Codes__c != null) {
                    
                                       
                    //Get existing value
                    String productCodes = (mapContracts.get(subscription.SBQQ__Contract__c).List_Of_Product_Codes__c + '-'+ subscription.Product_Code__c);
                    
                    //Add values in map
                    mapContracts.get(subscription.SBQQ__Contract__c).List_Of_Product_Codes__c = productCodes;
                    
                } else if(mapContracts.containsKey(subscription.SBQQ__Contract__c))
                    mapContracts.get(subscription.SBQQ__Contract__c).List_Of_Product_Codes__c = subscription.Product_Code__c;
            }
            //Checcking for list size
            if(mapContracts.size() > 0) {
                Util.byPassAllTriggers = true;                
                update mapContracts.values();
                Util.byPassAllTriggers = false;
            }
        }
    }
    
  /**
    * 
    *   @description    :   This method used to populate Record type on Subscription
    *
    *   @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.0 - Created - 05/23/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807
    *                       V1.1 - Modified - 06/28/2017 - Subhash Garhwal - Q2C Phase 2 - Issue--CR10808--QA--00004753
    *                       V1.2 - Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
    *			    V1.3 - Modified By - Subhash Garhwal - 09/15/2020 - CR-20200914-14503 - Added code logic to modify the start date of the ESYO Sub Products.
    * 
    **/
    public static void populateRecordTypeOnSubscription(List<SBQQ__Subscription__c> subscriptions){
        
        //Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
        //Get all record types of SBQQ__Subscription__c
        Map<String, Id> mapSubscriptionRecordTypes = new Map<String, Id>();
        mapSubscriptionRecordTypes = Constants.MAP_SUBSCRIPTION_RTYPE;
        
        //Get Record Type
        String componentRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT);
        String programRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM);
        String offerRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_OFFER);
        
        //09/15/2020 - Subhash Garhwal - CR-20200914-14503
        //Set to hold the ESYO sub products for which Start/End dates are changed. 
        Set<String> setStartEndDateChangeProducts = new Set<String>{'Program Costs - Financial Aid Optimization - Yield Optimization',
                                                                        'Program Costs - Financial Aid Descriptive Analysis - Yield Optimization',
                                                                        'Program Costs - Full Budget Model - Yield Optimization',
                                                                        'Program Costs - Four-Year Net Tuition Revenue Model - Yield Optimization',
                                                                        'Program Costs - Inquiry Scoring - Yield Optimization',
                                                                        'Program Costs - Retention Analysis - Yield Optimization',
                                                                        'Program Costs - Transfer Financial Aid Optimization - Yield Optimization'};
        
        //Set to hold Product Id
        Set<Id> productIds = new Set<Id>();
        
        //Set to hold the Contrat Id
        Set<Id> setContractIds = new Set<Id>();
        
        //Set to hold the Proposal Line Ids
        Set<Id> setProposalLineIds = new Set<Id>();
        
        //Loop through List of Sibscription
        for(SBQQ__Subscription__c subscription : subscriptions) {
            
            //Check for insert case
            if(subscription.SBQQ__Product__c != null) {
                
                //Add Id of product to list
                productIds.add(subscription.SBQQ__Product__c);
                
                //Add Contract Id
                setContractIds.add(subscription.SBQQ__Contract__c);
                
                //Check for Proposal Line
                if(subscription.SBQQ__QuoteLine__c != null)
                    setProposalLineIds.add(subscription.SBQQ__QuoteLine__c);  
            }
        }
        
        //Map to hold Product
        Map<Id,Product2> mapOfProduct = new Map<Id,Product2>([SELECT Id, SBQQ__Component__c, Offer__c, Program__c 
                                                              FROM Product2 
                                                              WHERE Id IN :productIds]);
        
        //Map to hold Contracts
        Map<Id,Contract> mapContracts = new Map<Id,Contract>([Select Id, SBQQ__Opportunity__c, SBQQ__Opportunity__r.Contract_Signature_Date__c, AccountId, Invoice_Contact__c, Status, (Select Id, Contract_Signature_Date__c From SBQQ__AmendmentOpportunities__r Where SBQQ__Contracted__c = true ORDER BY LastModifiedDate DESC LIMIT 1) From Contract Where Id IN : setContractIds]);
        
        //Map to hold the Proposal Lines
        Map<Id, SBQQ__QuoteLine__c> mapProposalLines = new Map<Id, SBQQ__QuoteLine__c>([Select Id, Reward_Expiration_Date__c, Reward_Product_s__c, Reward_Cash_In_Amount__c, Reward_Credit__c, 
                                                                                        Hotel_Nights__c, Number_of_Meetings__c, Number_of_Employees__c, Number_of_Onsites__c,
                                                                                        Onsite_Kickoff_Date__c, Days_Notice__c, Penalty_Fee_Amount__c,  Upfront_Fee__c
                                                                                        From SBQQ__QuoteLine__c Where Id IN : setProposalLineIds]);
        
        //Loop through List of Sibscription
        for(SBQQ__Subscription__c subscription : subscriptions) {
            
            //Check contain in map then record type is component
            if(mapOfProduct.Size() > 0) {
                
                //Check for Offer Record Type
                if(mapOfProduct.containsKey(subscription.SBQQ__Product__c) && mapOfProduct.get(subscription.SBQQ__Product__c).Offer__c) {
                    
                    //Set Offer values
                    subscription.RecordTypeId = offerRecordType;
                    subscription.Status__c = 'Offered';
                    subscription.Source_Opportunity__c = mapContracts.containsKey(subscription.SBQQ__Contract__c) && mapContracts.get(subscription.SBQQ__Contract__c).SBQQ__Opportunity__c != null ? mapContracts.get(subscription.SBQQ__Contract__c).SBQQ__Opportunity__c : subscription.Source_Opportunity__c;
                    
                    //Check for Proposal Line Id
                    if(subscription.SBQQ__QuoteLine__c != null && mapProposalLines.size() > 0 && mapProposalLines.containsKey(subscription.SBQQ__QuoteLine__c)) {
                        
                        //Get Proposa line
                        SBQQ__QuoteLine__c offerPL = mapProposalLines.get(subscription.SBQQ__QuoteLine__c);
                        
                        //Set values from Proposal Line
                        subscription.Reward_Expiration_Date__c = offerPL.Reward_Expiration_Date__c;
                        subscription.Hotel_Nights_m__c = offerPL.Hotel_Nights__c;  
                        subscription.Number_of_Meetings_m__c = offerPL.Number_of_Meetings__c;
                        subscription.Number_of_Employees_m__c = offerPL.Number_of_Employees__c;
                        subscription.Number_of_Onsites_m__c = offerPL.Number_of_Onsites__c;
                        subscription.Reward_Credit_m__c = offerPL.Reward_Credit__c;
                        subscription.Reward_Cash_In_Amount_m__c = offerPL.Reward_Cash_In_Amount__c;
                        subscription.Upfront_Fee_m__c = offerPL.Upfront_Fee__c;
                        subscription.Reward_Product_s__c = offerPL.Reward_Product_s__c;
                        subscription.Onsite_Kickoff_Date__c = offerPL.Onsite_Kickoff_Date__c;
                        subscription.Days_Notice__c = offerPL.Days_Notice__c;
                        subscription.Penalty_Fee_Amount__c = offerPL.Penalty_Fee_Amount__c;
                        
                    }
                    
                    //Subhash Garhwal - 03/27/2018 - CR-20180212-12039 - Added Program check here
                    //Check for Component Record Type  
                } else if(mapOfProduct.containsKey(subscription.SBQQ__Product__c) && mapOfProduct.get(subscription.SBQQ__Product__c).SBQQ__Component__c && mapOfProduct.get(subscription.SBQQ__Product__c).Program__c == null) {
                    
                    //Set Source Opportunity, Status and RecordType
                    subscription.RecordTypeId = componentRecordType;
                    subscription.Status__c = 'Committed';
                    
                    //09/15/2020 - Subhash Garhwal - CR-20200914-14503 - Start
                    //Check for Parent Product
                    /*if(subscription.Related_Product_with_Parent_Product__c != null && setStartEndDateChangeProducts.contains(subscription.Related_Product_with_Parent_Product__c)) {
                    	
                    	//Check if Start date lies in between 7/1 to 8/1 then set the start date to 8/1
                		if(subscription.SBQQ__SegmentStartDate__c != null && (subscription.SBQQ__SegmentStartDate__c.month() == 7 || (subscription.SBQQ__SegmentStartDate__c.month() == 8 && subscription.SBQQ__SegmentStartDate__c.day() < 2 ))) {
                    		subscription.SBQQ__SegmentStartDate__c = Date.newInstance(subscription.SBQQ__SegmentStartDate__c.Year(), 8, 1);
                		}
                		
                		if(subscription.SBQQ__SegmentEndDate__c != null) {
                    
		                    Date endDate = date.newInstance(subscription.SBQQ__SegmentEndDate__c.Year(), 7, 31);
		                    
		                    if(endDate <= subscription.SBQQ__EndDate__c && subscription.SBQQ__SegmentEndDate__c != endDate){
		                        subscription.SBQQ__SegmentEndDate__c = endDate;
		                    	
		                    }
                		}
                    } */
                    //09/15/2020 - Subhash Garhwal - CR-20200914-14503 - End
                    
                    //Check for Amended Opportunity
                    if(mapContracts.containsKey(subscription.SBQQ__Contract__c) && mapContracts.get(subscription.SBQQ__Contract__c).SBQQ__AmendmentOpportunities__r != null
                       && mapContracts.get(subscription.SBQQ__Contract__c).SBQQ__AmendmentOpportunities__r.size() > 0) {
                        
                        //Get Amended Opportunity
                        Opportunity amendedOpp = mapContracts.get(subscription.SBQQ__Contract__c).SBQQ__AmendmentOpportunities__r[0];
                        
                        //Update Contract_Signature_Date__c
                        ////Added by Mahendra Swarnkar - 05/11/2020 - CR-20200508-14032
                        if(SubscriptionAdjustmentHelper.hasExecutedSubAdjustment == false)
                        	subscription.Contract_Signature_Date__c = amendedOpp.Contract_Signature_Date__c;
                    }
                    else if(mapContracts.containsKey(subscription.SBQQ__Contract__c) && mapContracts.get(subscription.SBQQ__Contract__c).SBQQ__Opportunity__c != null
                            && mapContracts.get(subscription.SBQQ__Contract__c).SBQQ__Opportunity__r.Contract_Signature_Date__c != null) 
                    {
                        //Added by Mahendra Swarnkar - 05/11/2020 - CR-20200508-14032
                        if(SubscriptionAdjustmentHelper.hasExecutedSubAdjustment == false)
                            subscription.Contract_Signature_Date__c = mapContracts.get(subscription.SBQQ__Contract__c).SBQQ__Opportunity__r.Contract_Signature_Date__c; 
                    }
                    
                    //Otherwise record type is program
                } else if(mapOfProduct.containsKey(subscription.SBQQ__Product__c)) {
                    
                    //Set values
                    subscription.RecordTypeId = programRecordType;
                    subscription.Source_Opportunity__c = mapContracts.containsKey(subscription.SBQQ__Contract__c) && mapContracts.get(subscription.SBQQ__Contract__c).SBQQ__Opportunity__c != null ? mapContracts.get(subscription.SBQQ__Contract__c).SBQQ__Opportunity__c : subscription.Source_Opportunity__c;
                    subscription.SBQQ__Account__c = mapContracts.containsKey(subscription.SBQQ__Contract__c) && mapContracts.get(subscription.SBQQ__Contract__c).AccountId != null ? mapContracts.get(subscription.SBQQ__Contract__c).AccountId : subscription.SBQQ__Account__c;
                    subscription.Status__c = 'Committed';
                    subscription.Stage_Period__c = CPQConstants.SUBSCRIPTION_STAGE_ATL;
                    subscription.Invoice_Contact__c = mapContracts.containsKey(subscription.SBQQ__Contract__c) && mapContracts.get(subscription.SBQQ__Contract__c).Invoice_Contact__c != null ? mapContracts.get(subscription.SBQQ__Contract__c).Invoice_Contact__c : subscription.Invoice_Contact__c;
                }      
            }    
        }
    }
    
  /**
    * 
    *   @description    :   This method used to Create Subscription for each Unique Component Subscription
    *
    *   @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created - 05/24/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807
    *                       V1.2 - Modified - 07/11/2017 - Saurabh Kumar - Q2C Phase (Issue--CR10807--QA--00004745) - Updated method "createSubscriptionPeriodforUniqueComponent". 
    *                             Update Updated_By_Code__c = true while major insert/update and after that again reset Updated_By_Code__c = false. It bypass the validation
    *                             rule and update the successfull via if running from code.
    *                       V1.3 - Modified - 07/13/2017 - Colin McGloin - Q2C Phase 2 (Issue--CR10808--QA--00004850) - Updated method "createSubscriptionPeriodforUniqueComponent"
    *                                                      Updated Stage population logic so that it factors Opt Outs into how the Stage field is populated in Subscription Periods to be inserted
    *                       V1.4 - Modified - 08/02/2017 - Colin McGloin - Q2C Phase 2 (Issue--CR10808--QA--00005159) - Updated how the UniqueKey is being built at the start to add the Segment Label Index back
    *                                                      in so that the record is found when we loop through the Renewed Contract Start records and search for contains (-1)
    *                       V1.5 - Modified - 08/14/2017 - Subhash Garhwal - Q2C Phase 2 (Issue--CR11094--QA--00005436)
    *                       V1.6 - Modified - 11/14/2017 - Victor Hanson - Issue--CR11094--QA--00005364 - Commented out code that was setting Decision Type=Fixed Term
    *                                                    on 1st segment of renewal subscription periods.
    *                       V1.7 - Modified - 03/06/2018 - Subhash Garhwal - Modified method to avoid SOQL issue
    *                       v1.8 - Modified - 04/09/2018 - Subhash Garhwal - Updated method "createSubscriptionPeriodforUniqueComponent to add condition for segment start date & segment end date as per CR-20180326-12126 
    *                       V1.9 - Modified - 04/19/2018 - Subhash Garhwal -  CR-20180417-12170 - Updated 'createSubscriptionPeriodforUniqueComponent' method to change the record type automation from 'HC' to 'EAB' on Subscription Period objet.
    *                       V2.0 - Modified - 05/10/2018 - Subhash Garhwal - CR-20180508-12214 - Updated createSubscriptionPeriodforUniqueComponent to remove creation of Pending SP if Product sType - One Time
    *                       V2.1 - Modified - 10/11/2018 - Subhash Garhawal - CR-20180720-12456
    *                       V2.2 - Modified - 12/19/2018 - Subhash Garhawal - ES - Added additonal OR check for ES Products to avoid Pending Subscription Periods for Top Parent Program Subscription
    *                       
    **/
    public static void createSubscriptionPeriodforUniqueComponent(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions){
    
        //Subhash Garhwal - CR-20180301-12089 - set BYPASS_FOR_SUBSCRIPTION_PERIOD_CREATION_PROCESS value
        //BYPASS_FOR_SUBSCRIPTION_PERIOD_CREATION_PROCESS = false;
        
        //Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
        //Get all record types of SBQQ__Subscription__c
        Map<String, Id> mapSubscriptionRecordTypes = new Map<String, Id>();
        mapSubscriptionRecordTypes = Constants.MAP_SUBSCRIPTION_RTYPE;
        
        //Get Record Type
        String componentRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT);
        String programRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM);
        
        //Get all record types of Subscription_Period__c
        Map<String, Id> mapSubscriptionPeriodRecordTypes = Util.recordtypemap(CPQConstants.OBJECT_SUBSCRIPTION_PERIOD);
        
        //Get Record Type
        String eABRecordType = mapSubscriptionPeriodRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_PERIOD_RECORD_TYPE_DEVELOPERNAME_EAB);
        
        //Subhash Garhwal - 04/19/2018 - CR-20180417-12170 comment out the 'HC' recod type automation on Subscription Period object
        //String hCRecordType = mapSubscriptionPeriodRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_PERIOD_RECORD_TYPE_DEVELOPERNAME_HC);
        
        //Set to hold Contract
        Set<Id> setContractIds = new Set<Id>();
        
        //Map to hold map to hold Component Subscription
        Map<String,SubscriptionPeriodAutomationWrapper> mapUniqueKeySubscriptionPeriodAutomation = new Map<String,SubscriptionPeriodAutomationWrapper>();
        
        //Map to hold Program Subscription Id as key and value as key
        Map<Id, Set<String>> mapProgramSubscriptionwithUniqueKey = new Map <Id,Set<String>>();
                
        //Subhash Garhwal - CR-20180131-11927
        //Flag for Pending Subscription Period
        Boolean isPendingSubscriptionPeriods = false;
        
        //Set to hold the Program Subscription Ids
        Set<Id> setProgramSubscriptions = new Set<Id>();
        
        //Modify by Subhash Garhwal - 05/10/2018 - CR-20180508-12214 - Start here -
        //Map to hold the Product Id and its Subscription type
        Map<Id, Product2> mapProductIdWithType = new Map<Id, Product2>();

        //Modify by Mahendra Swarnkar - 24/08/2021 - CR-20210812-15350
        //hold the Product Name for Prevent ByPass the Pending Subscription Period of Three Level Products based on Product Name
        String preventProductName = System.Label.PRODUCT_FAMILY_BYPASS_PENDING_SP_CREATION;
        
        //Loop through Subscription
        for(SBQQ__Subscription__c subscription : subscriptions ){
            
            //Check if the product is not null
            if(String.isNotBlank(subscription.SBQQ__Product__c))
                mapProductIdWithType.put(subscription.SBQQ__Product__c, new Product2(Id = subscription.SBQQ__Product__c));
        }
        //Check for map size
        if(mapProductIdWithType.size() > 0 && (mapProductIdWithTypeStatic.size() == 0 || mapProductIdWithTypeStatic.size() != mapProductIdWithType.size())) {
            //Query on the Product to get the Subscription Type 
            //Added an Field API name in query by Mahendra Swarnkar - 24/08/2021 - CR-20210812-15350
            for(Product2 prdct : [Select Id, SBQQ__SubscriptionType__c, Family, SBQQ__ExternallyConfigurable__c, ProductCode, Name From Product2 Where Id IN: mapProductIdWithType.KeySet()]) {
            
                mapProductIdWithType.put(prdct.Id, prdct);
                
                /*This map will fill once. It is used to reduce the SOQL on Product.
                Added by Subhash Garhwal - 07/25/2018 - CR-20180720-12454*/
                mapProductIdWithTypeStatic.put(prdct.Id, prdct);
            }
        } else {
            
            mapProductIdWithType.putAll(mapProductIdWithTypeStatic);
        }
        //Modify by Subhash Garhwal - 05/10/2018 - CR-20180508-12214 - Ends here -
  	//Loop through Subscription
        for(SBQQ__Subscription__c subscription : subscriptions ){
  
     	    //Check Upcoming subscription record type is Component , Contract is not null , Quantity greater than zero
            //Subhash Garhwal - 04/09/2018 - Added condition for segment start date < segment end date as per CR-20180326-12126
            if(subscription.SBQQ__Contract__c != null && subscription.RecordTypeId == componentRecordType && subscription.SBQQ__SegmentStartDate__c != null
                && subscription.SBQQ__SegmentEndDate__c != null && subscription.SBQQ__SegmentStartDate__c < subscription.SBQQ__SegmentEndDate__c 
                && subscription.Segment_Label_Index__c != null
                && subscription.Program_Subscription__c != null
                &&(mapOldSubscriptions == null || subscription.SBQQ__Contract__c != mapOldSubscriptions.get(subscription.Id).SBQQ__Contract__c
                    || subscription.Program_Subscription__c != mapOldSubscriptions.get(subscription.Id).Program_Subscription__c)) {
        
	        BYPASS_SCHEDULER_FOR_SUBSCRIPTION_PERIOD = true;
                        
                //Modified By Mahendra - CR-20210727-15318- 08/02/2021 - Modified the Key to include the Program Subscription id as well, so that in case of mutiple instances, SP can be created for each instance
                //Hold Unique Key Parent Product + Segment Start Date + Segment End Date + Segment Index + Contract
                String uniqueKey = subscription.SBQQ__Contract__c + '-' + subscription.Program_Products__c + '-'
                                 + subscription.SBQQ__SegmentStartDate__c + '-' + subscription.Segment_Label_Index__c + subscription.Program_Subscription__c;
                
                //Check if data is already not procced 
                if(!mapUniqueKeySubscriptionPeriodAutomationFinal.containsKey(uniqueKey)) {
                    
                    //Process if Key Contain in Map
                    if(!mapUniqueKeySubscriptionPeriodAutomation.containsKey(uniqueKey)) {
                        
                        //Variable or Subscription Period
                        SubscriptionPeriodAutomationWrapper sPeriod = new SubscriptionPeriodAutomationWrapper();
                        
                        //Hold Variable
                        sPeriod.periodStartDate = subscription.SBQQ__SegmentStartDate__c;
                        sPeriod.periodEndDate = subscription.SBQQ__SegmentEndDate__c;
                        sPeriod.uniqueKey = uniqueKey;
                        sPeriod.SubscriptionPeriodType = CPQConstants.SUBSCRIPTION_PERIOD_COMPONENT_TYPE;
                        sPeriod.SegmentIndex = subscription.Segment_Label_Index__c;//VH modified 7/5/17 due to amendment scenario
                        sPeriod.Stage = CPQConstants.SUBSCRIPTION_PERIOD_STAGE_ATL;
                        sPeriod.Contract = subscription.SBQQ__Contract__c;
                        sPeriod.programSubscription.Id = subscription.Program_Subscription__c;
                        sPeriod.RecordType = eABRecordType;
                        
                        sPeriod.componentSubscription.add(subscription);
                        mapUniqueKeySubscriptionPeriodAutomation.put(uniqueKey,sPeriod);
        
                    } else
                        mapUniqueKeySubscriptionPeriodAutomation.get(uniqueKey).componentSubscription.add(subscription);
                    
                    //Check unique key in map
                    if(!mapProgramSubscriptionwithUniqueKey.containsKey(subscription.Program_Subscription__c))
                        mapProgramSubscriptionwithUniqueKey.put(subscription.Program_Subscription__c, new Set<String>());
                    
                    //Add unique key in map
                    mapProgramSubscriptionwithUniqueKey.get(subscription.Program_Subscription__c).add(uniqueKey);
                }
                
                //Add Contract Id to set
                setContractIds.add(subscription.SBQQ__Contract__c);  
                
            //Check For Program Subscription record type
            }else if(subscription.SBQQ__Contract__c != null && subscription.RecordTypeId == programRecordType 
                        && subscription.SBQQ__StartDate__c != null && subscription.SBQQ__EndDate__c != null
                        && mapOldSubscriptions == null && (mapProductIdWithType.get(subscription.SBQQ__Product__c).ProductCode != 'ESCAS')) {
                
                //Added By Subhash garhwal - 05/10/2018 - CR-20180508-12214
                //Check if the Subscription--Product is of 'One time' then no need to create pending SPs - continuing the loop 
                //12/19/2018 - Subhash Garhwal - ES - Added additonal OR check for ES Products to avoid Pending Subscription Periods for Top Parent Program Subscription
		//Added additional AND check to prevent bypass for three level products. - Mahendra Swarnkar - 24/08/2021 - CR-20210812-15350
                if((subscription.SBQQ__Product__c != null && mapProductIdWithType != null && mapProductIdWithType.containsKey(subscription.SBQQ__Product__c)
                    && (mapProductIdWithType.get(subscription.SBQQ__Product__c).SBQQ__SubscriptionType__c == 'One-time'
                        || (CPQConstants.THREE_LEVEL_PRODUCT_FAMILY_BYPASS_PENDING_SP_CREATION.contains(mapProductIdWithType.get(subscription.SBQQ__Product__c).Family)
                            && mapProductIdWithType.get(subscription.SBQQ__Product__c).SBQQ__ExternallyConfigurable__c == true
                            && !(mapProductIdWithType.get(subscription.SBQQ__Product__c).Name).contains(preventProductName))))) {
                    continue;
                }   
                
		//Modified By Mahendra - CR-20210727-15318- 08/02/2021 - Modified the Key to include the Program Subscription id as well so that in case of mutiple instances pending SP can be created for each instance
                //Hold Unique Key Parent Product + Segment End Date
                String uniqueKey = subscription.Program_Products__c + '-' + subscription.SBQQ__Contract__c + '-' + subscription.SBQQ__EndDate__c + subscription.ID;
                   
                //Check if data is already not procced
                if(!mapUniqueKeySubscriptionPeriodAutomationFinal.containsKey(uniqueKey)) {
                    
                    //Variable or Subscription Period
                    SubscriptionPeriodAutomationWrapper sPeriod = new SubscriptionPeriodAutomationWrapper();
                    
                    //Hold Variable
                    sPeriod.periodStartDate = subscription.SBQQ__EndDate__c.addDays(1);
                    sPeriod.periodEndDate = subscription.SBQQ__EndDate__c.addYears(1);
                    sPeriod.SubscriptionPeriodType = CPQConstants.SUBSCRIPTION_PERIOD_RENEWAL_TYPE;
                    sPeriod.Stage = CPQConstants.RENEWAL_SUBSCRIPTION_PERIOD_STAGE_PENDING;
                    sPeriod.uniqueKey = uniqueKey;
                    sPeriod.Contract = subscription.SBQQ__Contract__c;
                    sPeriod.programSubscription = subscription;
                    sPeriod.RecordType = eABRecordType;
                    isPendingSubscriptionPeriods = true;
                    setProgramSubscriptions.add(subscription.Id);
                    
                    //Add to Map
                    mapUniqueKeySubscriptionPeriodAutomation.put(uniqueKey, sPeriod);
                    
                    //Check unique key in map
                    if(!mapProgramSubscriptionwithUniqueKey.containsKey(subscription.Id))
                        mapProgramSubscriptionwithUniqueKey.put(subscription.Id, new Set<String>());
                    
                    //Add unique key in map
                    mapProgramSubscriptionwithUniqueKey.get(subscription.Id).add(uniqueKey);
                }
                
                //Add Contract Id to set
                setContractIds.add(subscription.SBQQ__Contract__c);  
            }               
        }
        
        //Check for size
        if(mapProgramSubscriptionwithUniqueKey.Size() > 0) {
            
            mapUniqueKeySubscriptionPeriodAutomationFinal.putAll(mapUniqueKeySubscriptionPeriodAutomation);
            mapProgramSubscriptionwithUniqueKeyFinal.putAll(mapProgramSubscriptionwithUniqueKey);
            
            List<AsyncApexJob> subTriggerAsyncApexJob = [Select Id,Status From AsyncApexJob Where Status IN ('Queued', 'Processing') AND ApexClass.Name = 'Sched_SubscriptionTrigger' ORDER BY CreatedDate DESC LIMIT 1];
            
            //Added schedules job for CR-20180720-12454
            if (!system.isScheduled() || subTriggerAsyncApexJob.size() > 0) {
                
                dateTime sysTime = dateTime.now().addSeconds(10);
                String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
                
    Sched_SubscriptionPeriodCreation job = new Sched_SubscriptionPeriodCreation(mapUniqueKeySubscriptionPeriodAutomation, mapProgramSubscriptionwithUniqueKey, setContractIds);
                System.schedule('SBQQ_SubscriptionTrigger' + sysTime.getTime(),chron_exp, job);
            }
        }
        
        //Check for size
        /*if(mapProgramSubscriptionwithUniqueKey.Size() > 0) {
            
            //Map to hold the Contract + Product with Subscription Period unique identifier
            Map<String, String> mapPreviousSubIdentifierWithSubPeriodIdentifier = new Map<String, String>();
            
            //Set to hold the Renewed contract
            Set<Id> setPreviousRenewedContracts = new Set<Id>();
            
            //Set to hold the Product Id
            Set<Id> setProductIds = new Set<Id>();
    
            //Loop through Program Subscription
            //)8/25/2017 - Subhash Garhwal - Issue--CR10808--QA--00005222 - Removed SBQQ__Product__r.Program_Family__c field from query
            for(SBQQ__Subscription__c subscription : [Select Id, SBQQ__Account__c, Source_Opportunity__c, Source_Opportunity__r.SBQQ__RenewedContract__c, SBQQ__SegmentIndex__c,
                                                                 SBQQ__Product__c, SBQQ__Product__r.Program_Family__c , SBQQ__Contract__c, Product_Code__c,
                                                                 SBQQ__Contract__r.AccountId, Segment_Label_Index__c,
                                                                 SBQQ__Account__r.Name, Source_Opportunity__r.RecordType.DeveloperName,
                                                                 Early_Termination_Date__c, Opt_Out__c From SBQQ__Subscription__c //Added Early Termination Date & Opt Out Type by Colin McGloin - Issue--CR10808--QA--00004850
                                                                 Where Id IN: mapProgramSubscriptionwithUniqueKey.keySet()]) {
                
                //Check unique key in map
                if(mapProgramSubscriptionwithUniqueKey.containsKey(subscription.Id)) {
                    
                    //Loop over the unique key
                    for(String uK : mapProgramSubscriptionwithUniqueKey.get(subscription.Id)) {
                        
                        
                        //Check for Renewed Contract
                        if(subscription.Source_Opportunity__c != null && subscription.Source_Opportunity__r.SBQQ__RenewedContract__c != null && uK.endsWithIgnoreCase('-1')) {
                            
                            //Add Contract id
                            setPreviousRenewedContracts.add(subscription.Source_Opportunity__r.SBQQ__RenewedContract__c);
                            
                            //Add Product Id
                            setProductIds.add(subscription.SBQQ__Product__c);
                            
                            //Create a unique key for Previous Subscription Period 
                            String previousSubPeriodUK = subscription.Source_Opportunity__r.SBQQ__RenewedContract__c + '-' + subscription.SBQQ__Product__c;
                            
                            //Add subscriptions period unique indentifier with previous Sub. Period identifier
                            mapPreviousSubIdentifierWithSubPeriodIdentifier.put(previousSubPeriodUK, uK);
                        }
        
                        //Add Program Subscription details
                        mapUniqueKeySubscriptionPeriodAutomation.get(uK).programSubscription = subscription;
                        mapUniqueKeySubscriptionPeriodAutomation.get(uK).RecordType = eABRecordType;
                        
                        if(subscription.Source_Opportunity__c != null && subscription.Source_Opportunity__r.RecordType.DeveloperName.contains('HC_'))
                            mapUniqueKeySubscriptionPeriodAutomation.get(uK).RecordType = eABRecordType;
                
                        else if(subscription.Source_Opportunity__c != null && subscription.Source_Opportunity__r.RecordType.DeveloperName.contains('EAB_'))
                            mapUniqueKeySubscriptionPeriodAutomation.get(uK).RecordType = eABRecordType;
                    }
                }
            }
            
            /*******************      This code is to get the Renewed Contract Start  ********************/
            
            //Map to hold the Renewal Subscriotion Period from Previous Contract with new Subscription Identifier
            /*Map<String, Id> mapRenewalSubPeriodWithubscriptionPeriodIdentifier = new Map<String, Id>();
            
            //Modified By - Suhash Garhawal - 28/06/2018 - CR-20180627-12306 - Added size check
            if(setPreviousRenewedContracts.size() > 0 && setProductIds.size() > 0 ) {
            
              //RENEWAL_SUBSCRIPTION_PERIOD_STAGE_PENDING, Stage__c
              for(Subscription_Period__c subPeriod : [Select Id, Contract__c, Program_Subscription__c, Program_Subscription__r.SBQQ__Product__c,
                                  Program_Subscription__r.SBQQ__Contract__c, Program_Subscription__r.SBQQ__Contract__r.AccountId
                                  From Subscription_Period__c
                                                      Where Contract__c IN : setPreviousRenewedContracts AND Program_Subscription__r.SBQQ__Product__c IN : setProductIds
                                                            AND Stage__c =: CPQConstants.RENEWAL_SUBSCRIPTION_PERIOD_STAGE_PENDING ORDER BY Period_Start_Date__c DESC]) { 
                  
                  //Create Unique Identifier
                  String renewalUK = subPeriod.Contract__c + '-' + subPeriod.Program_Subscription__r.SBQQ__Product__c;
                  
                  //Check Product in map
                  if(mapPreviousSubIdentifierWithSubPeriodIdentifier.containsKey(renewalUK)) {
                      
                      //Get New Subscription Period Identifier
                      String newSubPeriodIdentifier = mapPreviousSubIdentifierWithSubPeriodIdentifier.get(renewalUK);
                      
                      //Check in map
                      if(!mapRenewalSubPeriodWithubscriptionPeriodIdentifier.containsKey(newSubPeriodIdentifier))
                          mapRenewalSubPeriodWithubscriptionPeriodIdentifier.put(newSubPeriodIdentifier, subPeriod.Id);           
                  } 
              }
            }
            
            /*******************      This code is to get the Renewed Contract   End  ********************/
            
            //Map to hold the Contract + Product combination with list of related Subscription Periods
            /*Map<String, List<Subscription_Period__c>> mapSubscriptionPeriodsWithRelatedContract = new Map<String, List<Subscription_Period__c>>();
                 
            //Modified By - Suhash Garhawal - 28/06/2018 - CR-20180627-12306 - Added size check
            if(setContractIds.size() > 0 ) {
                 
              //Loop through Subscription Period
              for(Subscription_Period__c subscriptionPeriod : [Select Id, Program_Subscription__c, Program_Subscription__r.SBQQ__Contract__c,
                                       Program_Subscription__r.SBQQ__Contract__r.AccountId,
                                            Contract__c, Segment_Index__c, Period_Start_Date__c,
                                                                          Product__c, Period_End_Date__c, Program_Subscription__r.SBQQ__Product__c
                                                                          From Subscription_Period__c Where Contract__c IN : setContractIds AND
                                                                          Program_Subscription__c IN : mapProgramSubscriptionwithUniqueKey.KeySet() ORDER BY Period_End_Date__c ASC]) {
                  
                  //Create a unique key
                  String uK = subscriptionPeriod.Contract__c + '-' + subscriptionPeriod.Program_Subscription__r.SBQQ__Product__c;
                  
                  //Check the key in map
                  if(!mapSubscriptionPeriodsWithRelatedContract.containsKey(uK))
                      mapSubscriptionPeriodsWithRelatedContract.put(uK, new List<Subscription_Period__c>());
                  
                  //Add Subscription Period in map
                  mapSubscriptionPeriodsWithRelatedContract.get(uK).add(subscriptionPeriod);
                  
                  //Unique Key
                  /*String uKey = subscriptionPeriod.Contract__c + '-' + subscriptionPeriod.Program_Subscription__c + '-'
                                + subscriptionPeriod.Segment_Index__c + '-' + subscriptionPeriod.Period_Start_Date__c ;
      
                  //Check For Map contian Key
                  if(!mapSubscriptionPeriodToBeInserted.containsKey(uKey)) 
                      mapSubscriptionPeriodToBeInserted.put(uKey, subscriptionPeriod);
          
              }
            }*/
            
            //Set to hold the Id of already added Subscription Periods
            /*Set<Id> setExistingAddedSubPeriodIds = new Set<Id>();
            //Loop through key set of mapUniqueKeySubscriptionPeriodAutomation (Unique Identifier)
            for(String uniqueIdent : mapUniqueKeySubscriptionPeriodAutomation.keySet()) {


                //If Subscription Period not contian in map of mapSubscriptionPeriodToBeInserted
                if(!mapSubscriptionPeriodToBeInserted.ContainsKey(uniqueIdent)) {

                    if(mapUniqueKeySubscriptionPeriodAutomation.get(uniqueIdent).programSubscription.Id != null ) {
                        
                        //Hold Start Year
                        Integer Year = mapUniqueKeySubscriptionPeriodAutomation.get(uniqueIdent).periodStartDate.Year();
                        
                        //Variable to check the existing Subscription Period
                        Boolean isExistingSubPeriod = false;
                        
                        //Instance of SubscriptionPeriodAutomationWrapper
                        SubscriptionPeriodAutomationWrapper sPeriod = mapUniqueKeySubscriptionPeriodAutomation.get(uniqueIdent);
                        
                        //Instance of Subscription Period
                        Subscription_Period__c subPeriod = new Subscription_Period__c();
                         
                        //Create a unique Key
                        String existingSubPeriodUK = sPeriod.contract + '-' + sPeriod.programSubscription.SBQQ__Product__c;
                        
                        //Check UK in map
                        if(mapSubscriptionPeriodsWithRelatedContract.containsKey(existingSubPeriodUK) && mapSubscriptionPeriodsWithRelatedContract.get(existingSubPeriodUK) != null) {
                            
                            //Loop over the Existing Subscription Periods
                            for(Subscription_Period__c sP : mapSubscriptionPeriodsWithRelatedContract.get(existingSubPeriodUK)) {
                                
                                //Check for Subscription End Date 
                                if(sP.Period_End_Date__c >= sPeriod.periodEndDate && sP.Period_Start_Date__c < sPeriod.periodEndDate && !setExistingAddedSubPeriodIds.contains(sP.Id)) {
                                        
                                    //Add Sub Period Id in set
                                    setExistingAddedSubPeriodIds.add(sp.Id);
                                    
                                    //Add Id for record
                                    subPeriod.Id = sP.Id;
                                    if (sP.Segment_Index__c != null)
                                      subPeriod.Segment_Index__c = sP.Segment_Index__c;
                                    subPeriod.Amendment_Opportunity__c = sPeriod.programSubscription.Source_Opportunity__c;
                                    subPeriod.Program_Subscription__c = sPeriod.programSubscription.Id;
                                    subPeriod.Period_End_Date__c = sPeriod.periodEndDate;
                                    subPeriod.Institution__c = sPeriod.programSubscription.SBQQ__Contract__r.AccountId;
                                    subPeriod.Updated_By_Code__c = true;
                                    //Set flag
                                    isExistingSubPeriod = true;
                                    
                                    break;
                                }
                            }   
                        }
                        
                        //Check for existing subscription
                        if(!isExistingSubPeriod) {
                            
                            //Set field values
                            subPeriod.Period_Start_Date__c = sPeriod.periodStartDate;
                            subPeriod.Period_End_Date__c = sPeriod.periodEndDate;
                            subPeriod.Contract__c = sPeriod.contract;
                            subPeriod.Program_Subscription__c = sPeriod.programSubscription.Id;
                            subPeriod.Source_Opportunity__c = sPeriod.programSubscription.Source_Opportunity__c;
                            if (sPeriod.segmentIndex != null)
                                subPeriod.Segment_Index__c = sPeriod.segmentIndex;
                            subPeriod.Institution__c = sPeriod.programSubscription.SBQQ__Contract__r.AccountId;
                            subPeriod.Updated_By_Code__c = true;
                            
                            //Integer
                            Integer accountNameLength = 11;
                            
                            //Check for sPeriod.programSubscription.Product_Code__c
                            if(sPeriod.programSubscription.Product_Code__c != null)
                              accountNameLength += sPeriod.programSubscription.Product_Code__c.length();
                             
                             Integer actualAccountNameLength = 79 - accountNameLength;
                             
                            subPeriod.Name = 'SP' + '--' + (sPeriod.programSubscription.SBQQ__Account__r.Name).left(actualAccountNameLength) +'--'+ 
                                     sPeriod.programSubscription.Product_Code__c + '-' + year;
                            subPeriod.RecordTypeId = sPeriod.recordType;
                            subPeriod.Stage__c = sPeriod.stage;

                            //Added by Colin McGloin - 7/13/2017 - Issue--CR10808--QA--00004850
                            //Add Stage Logic to account for Opt Outs
                            //Scenario One - Early Termination Date - (Types: One Point in Time Opt Out With Penalty Fee, One Point in Time Opt Out Without Penalty Fee, Board Approval Opt Out)
                            //If the Opt Out date occurs within or before the Subscription Period timespan then mark the Subscription Period as Pending
                            if (sPeriod.programSubscription.Early_Termination_Date__c != null){
                                if (sPeriod.periodStartDate >= sPeriod.programSubscription.Early_Termination_Date__c ||
                                    (sPeriod.periodEndDate >= sPeriod.programSubscription.Early_Termination_Date__c &&
                                      sPeriod.periodStartDate <= sPeriod.programSubscription.Early_Termination_Date__c)){
                                    subPeriod.Stage__c = CPQConstants.RENEWAL_SUBSCRIPTION_PERIOD_STAGE_PENDING;
                                   
                                }
                            }

                            //Scenario Two - Opt Out after First Year (Types: Opt Out after First Year in Membership With Penalty Fee, Opt Out after First Year in Membership Without Penalty Fee,
                            // Annual Opt Out on Anniversary with penalty fee, Annual Opt Out on Anniversary without penalty fee, Funds Appropriation Opt Out)
                            Set <String> FirstYearOptOuts = new Set<String>();
                            FirstYearOptOuts.addAll(System.label.ProgSub_OptOutAfterFirstYear.split(';'));
                            if (sPeriod.ProgramSubscription.Opt_Out__c != null){
                                if (FirstYearOptOuts.contains(sPeriod.ProgramSubscription.Opt_Out__c) && sPeriod.segmentIndex != 1){
                                    subPeriod.Stage__c = CPQConstants.RENEWAL_SUBSCRIPTION_PERIOD_STAGE_PENDING;
                                    
                                }
                            }

                        }
                        
                        //Check for Renewal Subscription Period
                        if(sPeriod.segmentIndex == 1 &&  mapRenewalSubPeriodWithubscriptionPeriodIdentifier.containsKey(uniqueIdent)){
                            subPeriod.Id = mapRenewalSubPeriodWithubscriptionPeriodIdentifier.get(uniqueIdent);
                            
                            //Commented out by Victor Hanson - 11/14/2017 - Issue--CR11094--QA--00005364
                            //Added by Colin McGloin - 08/11/2017 - Issue--CR11094--QA--00005364
                            //Changed Decision Type Logic in SubscriptionPeriodTriggerHelper so need to update the Pending record Decision Type now while it is being upserted
                            //SubPeriod.Decision_Type__c = 'Fixed Term';
                        }
                        
                        //Subscription Period to be inserted
                        mapSubscriptionPeriodToBeInserted.put(uniqueIdent, subPeriod);

                    }
                }
            }
            
            try {
                //Check for Size 
                if(mapSubscriptionPeriodToBeInserted.Size()>0)
                    upsert mapSubscriptionPeriodToBeInserted.values();
            } catch(Exception e){
                
            }
            //List to update the Component Subscriptions
            List<SBQQ__Subscription__c> componentSubscriptopnToBeUpdated = new List<SBQQ__Subscription__c>();
    
            //Update Parent of Component Subscription
            for(String uniqueIdent : mapUniqueKeySubscriptionPeriodAutomation.keySet()) {
    
                for(SBQQ__Subscription__c componentSubscription : mapUniqueKeySubscriptionPeriodAutomation.get(uniqueIdent).componentSubscription ) {
    
                    //Check Subscription Period and update same on Comp. Subscription
                    if(mapSubscriptionPeriodToBeInserted.containsKey(uniqueIdent))
                        componentSubscriptopnToBeUpdated.add(new SBQQ__Subscription__c(Id = componentSubscription.Id, Subscription_Period__c = mapSubscriptionPeriodToBeInserted.get(uniqueIdent).Id, Program_Subscription__c = mapSubscriptionPeriodToBeInserted.get(uniqueIdent).Program_Subscription__c));
                }
            }
            
            //Check For Size
            if(componentSubscriptopnToBeUpdated.Size() > 0) {
                Util.byPassAllTriggers = true;
                
                //Bypass BYPASS_FOR_SUBSCRIPTION_PERIOD_CREATION_PROCESS
                BYPASS_FOR_SUBSCRIPTION_PERIOD_CREATION_PROCESS = true;
                update componentSubscriptopnToBeUpdated;
                
                //Call method
                //Subhash Garhwal - 03/06/2018 - CR-20180301-12089
                updatePendingSPNegotiatedAmountPeriod(componentSubscriptopnToBeUpdated, null);
                
                update mapSubscriptionPeriodToBeInserted.values();
                
                //Subhash Garhwal - CR-20180131-11927 
                List<SBQQ__Subscription__c> compSubs = [Select Id, RecordTypeId, Subscription_Period__c, Program_Subscription__c, SBQQ__CustomerPrice__c, SBQQ__Quantity__c From SBQQ__Subscription__c Where Id IN : componentSubscriptopnToBeUpdated];
                
                //Call method to update Proposal value on Subscription Period
                updateProposalvalue(compSubs, null);
                updatePendingSPNegotiatedAmountPeriod(compSubs, null); //VH 3/13/18 - updated from updateProposalValueForFutureSubPeriod() to updatePendingSPNegotiatedAmountPeriod()
                
                Util.byPassAllTriggers = false;
            }
            
            //VH 3/13/18 - updated from updateProposalValueForFutureSubPeriod() to updatePendingSPNegotiatedAmountPeriod()
            //Check for Pending SP
            if(isPendingSubscriptionPeriods && setProgramSubscriptions.size() > 0)
              updatePendingSPNegotiatedAmountPeriod([Select Id, RecordTypeId, Subscription_Period__c, Program_Subscription__c, SBQQ__CustomerPrice__c, SBQQ__Quantity__c From SBQQ__Subscription__c Where Program_Subscription__c IN : setProgramSubscriptions], null);
              
            //V1.2 - Modified - 07/11/2017 - Saurabh Kumar - Q2C Phase (Issue--CR10807--QA--00004745) - Set Updated_By_Code__c = false for future check - Strat from here
            
            //Bypass the trigger
            Util.byPassAllTriggers = true;
            
            //Map to hold Subscription Period records which should be Updated_By_Code__c = false
            Map<Id, Subscription_Period__c> mapSubscriptionPeriods = new Map<Id, Subscription_Period__c>();
            
            //Processing on the Subscription Period records which are just updated/inserted
            for(Subscription_Period__c subsPeriod : mapSubscriptionPeriodToBeInserted.values())
              mapSubscriptionPeriods.put(subsPeriod.Id, new Subscription_Period__c(Id = subsPeriod.Id, Updated_By_Code__c = false));
              
             if(mapSubscriptionPeriods.size() > 0)
               update mapSubscriptionPeriods.values();
            
            //Bypass the trigger
            Util.byPassAllTriggers = false;
            //V1.2 - Modified - 07/11/2017 - Saurabh Kumar - Q2C Phase (Issue--CR10807--QA--00004745) - Set Updated_By_Code__c = false for future check - Upto here
       }*/
    }
    
    /**
     * 
     *  @description    :   Update subscription period fields when Subscription is inserted or Subscription.Subscription_Period__c is changed (ie: amendment scenario)
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.0 - Created - 07/06/2017 - Victor Hanson - Q2C Phase 2 - CR-20170403-10807
     *            	    V1.1 - Modified By - Subhash Garhwal - 08/16/2017 - Issue--CR11094--UAT--00005488 - Added bypass flag
     *            	    V1.2 - Modified By - Subhash Garhwal - 08/19/2018 - CR-20180920-12613
     * 
     **/
    public static void updateSubscriptionPeriodFields(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
        
        set<Id> subscriptionPeriodIds = new set<Id>();
        
        //if subscription is being inserted, or subscription.Subscription_Period__c is changed, add subscription period to the set of IDs
        for (SBQQ__Subscription__c subscription : subscriptions) {
            if (mapOldSubscriptions == null || (mapOldSubscriptions.get(subscription.Id).Subscription_Period__c != subscription.Subscription_Period__c)) {
                if (subscription.Subscription_Period__c != null)
                    subscriptionPeriodIds.add(subscription.Subscription_Period__c);
            }
        }
        
        if (subscriptionPeriodIds.size() > 0) {
            
            //get subscription periods
            map<Id, Subscription_Period__c> mapSubPeriods = new map<Id, Subscription_Period__c>([SELECT Id, Segment_Index__c, Status__c, Period_Start_Date__c, Period_End_Date__c,
                                                                                                 Program_Subscription__r.Early_Termination_Date__c
                                                                                                 FROM Subscription_Period__c 
                                                                                                 WHERE Id IN :subscriptionPeriodIds]);
            //boolean indicating if there are subscription periods that need to be updated
            boolean sPeriodsNeedUpdated = false;
            
            for (SBQQ__Subscription__c subscription : subscriptions) {
                
                //get the associated subscription period and update the segment index & status accordingly
                if (mapSubPeriods.containsKey(subscription.Subscription_Period__c)) {
                    
                    Subscription_Period__c sP = mapSubPeriods.get(subscription.Subscription_Period__c);
                    if (sP.Segment_Index__c == null || sP.Status__c != CPQConstants.SUBSCRIPTION_PERIOD_STAGE_ATL) {
                        //get the segment label (ie: Year  5) and take just the numeric portion by splitting the double-space "  "
                        if (subscription.SBQQ__SegmentLabel__c != null && subscription.SBQQ__SegmentLabel__c.split('  ').size() > 1)
                          sP.Segment_Index__c = integer.valueOf(subscription.SBQQ__SegmentLabel__c.split('  ')[1]);
                        
                        if (sP.Segment_Index__c == null) throw new customException('@@!!subscription!!:' + subscription);
                        
                        //Added checks as per requirements on CR-20180920-12613
                        if(sP.Period_End_Date__c < sP.Program_Subscription__r.Early_Termination_Date__c)
                            sP.Stage__c = CPQConstants.SUBSCRIPTION_PERIOD_STAGE_ATL;
                        
                        sPeriodsNeedUpdated = true;
                    }
                }
            }
            
            if (sPeriodsNeedUpdated) {
	        //VH 2/21/2019 - this method executes outside of the bypassAllTriggers flag, so we need to store the bypass value and reset it
                boolean triggerBypassSetting = util.BypassAllTriggers;
              
		//Bypass all triggers
		Util.BypassAllTriggers = true;
                    
                update mapSubPeriods.values();
                
                //Reset the flag to whatever it was originally
                Util.BypassAllTriggers = triggerBypassSetting;
            }
        }
    }
    
    /**
     * 
     *  @description    :   Auto Populate Subscription fields. And also used to populate the Previous Subscription on the Program Subscription record.
     *                          Rule: If from a Continuing Opp, get the Renewed Contract from the Source Opportunity, and then find the
     *                          Program Subscription for the same Product and link that Program Subscription here.
     *                              If from an Initiating Opp, field is blank
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created - 05/30/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807
     *                      V1.2 - Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
     *                      V1.3 - Modified By Subhash Garhawal - 12/05/2018 - CR-20181120-12756
     *                      V1.4 - Modified By Mahendra Swarnkar - 05/13/2018 - CR-20190315-12946 - to populate the Type field correctly.
     * 
     **/
    public static void automationSubscription(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {

        //Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
        //Map to hold record type of subscription
        Map<String, Id> mapSubscriptionRecordTypes = new Map<String, Id>();
        mapSubscriptionRecordTypes = Constants.MAP_SUBSCRIPTION_RTYPE;

        //Get Record Type
        String programRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM);
        String componentRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT);
    
        //Set to hold opportunity id
        Set<Id> setOpportunitiyIds = new set<Id>();

        //Set to hold program id
        Set<Id> setProgramIds = new set<Id>();
        
        //Set to hold the Products
        Set<Id> setProductIds = new Set<Id>();
        
        //Map to hold the Opportunity Id and Subscription Id
        Map<Id, Id> mapOfOppIdAndSubId = new Map<Id, Id> ();
        
        //Map to hold MemberShip
        Map<Id,Opportunity> mapOfOpportunities = new Map<Id, Opportunity >();

        //Loop through the Subscription
        for(SBQQ__Subscription__c subscription : subscriptions){

            if(mapOldSubscriptions == null && subscription.recordTypeId == componentRecordType) {
                
                subscription.Finance_Status__c = 'Active';
            }
                
            //Check for opportunity
            if(subscription.Source_Opportunity__c != null &&(mapOldSubscriptions == null || subscription.Source_Opportunity__c != mapOldSubscriptions.get(subscription.Id).Source_Opportunity__c))
                setOpportunitiyIds.add(Subscription.Source_Opportunity__c);

            //Check for program
            //Modified By Subhash Garhwal - 07/05/2018 - CR-20180323-12122 - Added extra fields check
            if(subscription.Program__c != null && (mapOldSubscriptions == null || subscription.Program__c != mapOldSubscriptions.get(subscription.Id).Program__c
               /*Modified By Subhash Garhwal - 07/05/2018 - CR-20180323-12122 - Checks start from here*/
               || subscription.Account_Management_Group__c != mapOldSubscriptions.get(subscription.Id).Account_Management_Group__c 
               || subscription.Account_Management_Reporting_Business__c != mapOldSubscriptions.get(subscription.Id).Account_Management_Reporting_Business__c
               || subscription.Account_Management_Reporting_Vertical__c != mapOldSubscriptions.get(subscription.Id).Account_Management_Reporting_Vertical__c 
               || subscription.Account_Management_Reporting_Group__c != mapOldSubscriptions.get(subscription.Id).Account_Management_Reporting_Group__c
               || subscription.New_Business_Marketer__c != mapOldSubscriptions.get(subscription.Id).New_Business_Marketer__c 
               || subscription.New_Business_Group__c != mapOldSubscriptions.get(subscription.Id).New_Business_Group__c))
                setProgramIds.add(Subscription.Program__c);
                
            //Check for Opportunity
            if(subscription.RecordTypeId == programRecordType && subscription.SBQQ__Product__c != null && subscription.Source_Opportunity__c != null
              && subscription.Previous_Program_Subscription__c == null && (mapOldSubscriptions == null || subscription.SBQQ__Product__c != mapOldSubscriptions.get(subscription.Id).SBQQ__Product__c
                || subscription.Source_Opportunity__c != mapOldSubscriptions.get(subscription.Id).Source_Opportunity__c)) {
                
                //Add opportunity and product ids
                mapOfOppIdAndSubId.put(subscription.Source_Opportunity__c, subscription.Id);
                setProductIds.add(subscription.SBQQ__Product__c); 
            }                
        }
        
        //Process if Size is greater than zero
        if(setOpportunitiyIds.Size() > 0) {

            //Map to hold the Opportunity with Contracts
            Map<Id, Id> mapOppWithContracts = new Map<Id, Id>();
            
            //Map to hold the Contract with Program Subscription
            Map<String, Id> mapContractWithProgramSubscriptions = new Map<String, Id>();
      
            //Map to hold MemberShip
            for(Opportunity opp : [Select Id, Account_Management_Group__c, Account_Management_Reporting_Business__c, SBQQ__RenewedContract__c,
                                                                                Account_Management_Reporting_Vertical__c, /*Nursing_Masters_Member__c,*/ RecordType.DeveloperName,
                                                                                Program_Abbreviation__c, Program_Acronym__c, Program_Group__c, Program_Line__c,
                                                                                Program_Name__c, Start_Year__c, Business_Line__c
                                                                                From Opportunity Where Id IN: setOpportunitiyIds]) {
              //Put values into the map                                                                    
              mapOfOpportunities.put(opp.Id, Opp);
              
              //If opportunity contains into the mapOfOppIdAndSubId
              if(mapOfOppIdAndSubId.containsKey(opp.Id) && CPQConstants.SET_OPP_CONTINUING_RECORDTYPES.contains(opp.RecordType.DeveloperName)) {
                
                //Put value into the mapOppWithContracts
                mapOppWithContracts.put(opp.Id, opp.SBQQ__RenewedContract__c);
              }                                                                    
            }
            
            //Check for map
            if(mapOppWithContracts.size() > 0) {
                
                //Query through the Program Subscription
                for(SBQQ__Subscription__c pS : [Select Id, SBQQ__Product__c, SBQQ__Contract__c From SBQQ__Subscription__c
                                                Where SBQQ__Product__c IN : setProductIds AND SBQQ__Product__c != null AND SBQQ__Contract__c IN : mapOppWithContracts.values() AND SBQQ__Contract__c != null
                                                      ORDER BY CreatedDate DESC]) {
                    
                    //Create UK
                    String uniqueKey = pS.SBQQ__Contract__c + '-' + pS.SBQQ__Product__c;
                    
                    //Updated - By Mahendra Swarnkar - 05/13/2018 - CR-20190315-12946 -- added "not" condition befor contains check, so that map can be filled with values.
                    //Add Program Subscription in map
                    if(!mapContractWithProgramSubscriptions.containsKey(uniqueKey))
                        mapContractWithProgramSubscriptions.put(uniqueKey, pS.Id);  
                }
            }

            //Loop through Subscription
            for(SBQQ__Subscription__c subscription : subscriptions) {

                //Check for Opportunity
                if(subscription.RecordTypeId == programRecordType && subscription.SBQQ__Product__c != null && subscription.Source_Opportunity__c != null) {
                    
                    //Get the Contract from Opportunity map
                    if(mapOppWithContracts.containsKey(subscription.Source_Opportunity__c)) {
                        
                        //Create unique key
                        String uniqueKey = mapOppWithContracts.get(subscription.Source_Opportunity__c) + '-' + subscription.SBQQ__Product__c;
                        
                        //Check for Program subscription
                        if(mapContractWithProgramSubscriptions.containsKey(uniqueKey)){
                            subscription.Previous_Program_Subscription__c = mapContractWithProgramSubscriptions.get(uniqueKey);
                            
                        }
                    }
                }
                
                //Process if opportunity contain in Map
                if(mapOfOpportunities.containsKey(subscription.Source_Opportunity__c)) {
 
                    //Update value
                    /* Modified By Subhash Garhwal - 07/05/2018 - CR-20180323-12122 - comment out the these field update logic on Subscription From Opportunity 
                    subscription.Account_Management_Group__c = mapOfOpportunities.get(subscription.Source_Opportunity__c).Account_Management_Group__c;
                    subscription.Account_Management_Reporting_Business__c = mapOfOpportunities.get(subscription.Source_Opportunity__c).Account_Management_Reporting_Business__c;
                    subscription.Account_Management_Reporting_Vertical__c = mapOfOpportunities.get(subscription.Source_Opportunity__c).Account_Management_Reporting_Vertical__c;*/
                    
                    //subscription.Nursing_Masters_Member__c = mapOfOpportunities.get(subscription.Source_Opportunity__c).Nursing_Masters_Member__c;
                    //These field has changed from text to formula, and populate by formula , can not be populate by code.
                    //subscription.Program_Abbreviation__c = mapOfOpportunities.get(subscription.Source_Opportunity__c).Program_Abbreviation__c;
                    //subscription.Program_Acronym__c = mapOfOpportunities.get(subscription.Source_Opportunity__c).Program_Acronym__c;
                    //subscription.Program_Group__c = mapOfOpportunities.get(subscription.Source_Opportunity__c).Program_Group__c;
                    //subscription.Program_Line__c = mapOfOpportunities.get(subscription.Source_Opportunity__c).Program_Line__c;
                    //subscription.Program_Name__c = mapOfOpportunities.get(subscription.Source_Opportunity__c).Program_Name__c;
                    subscription.Start_Year__c = mapOfOpportunities.get(subscription.Source_Opportunity__c).Start_Year__c;

                    if(mapOfOpportunities.get(subscription.Source_Opportunity__c).Program_Acronym__c == null)
                        subscription.Acronym_Record_Type__c = mapOfOpportunities.get(subscription.Source_Opportunity__c).RecordType.DeveloperName;
                    else
                        subscription.Acronym_Record_Type__c = mapOfOpportunities.get(subscription.Source_Opportunity__c).Program_Acronym__c + '-' +  mapOfOpportunities.get(subscription.Source_Opportunity__c).RecordType.DeveloperName;

                    //Updated - By Mahendra Swarnkar - 05/13/2018 - CR-20190315-12946 - added condition to check for continuing record type and checking previous program Subscription then populate the Type field accordingly 
                    //Check source opportunity record type id
                    if(CPQConstants.SET_OPP_INITIATING_RECORDTYPES.contains(mapOfOpportunities.get(subscription.Source_Opportunity__c).RecordType.DeveloperName))
                        subscription.Type__c = CPQConstants.TYPE_NBB; 
                    
                    else {
                        //Check for continuing record type
                        if(CPQConstants.SET_OPP_CONTINUING_RECORDTYPES.contains(mapOfOpportunities.get(subscription.Source_Opportunity__c).RecordType.DeveloperName)){
                            
                            //Check the previous program subscription
                            if(subscription.Previous_Program_Subscription__c == null)
                                subscription.Type__c = CPQConstants.TYPE_NBB;
                            else
                                subscription.Type__c = CPQConstants.Type_RENEWAL;
                        }
                    }
                }
            }
        }

        //Process if Size is greater then zero
        if(setProgramIds.Size() > 0) {

            //Map to hold Program fields
            Map<Id,Program__c> mapOfProgram = new Map<Id,Program__c>([Select Id, New_Business_Vertical__c, New_Business_Marketer__c, New_Business_Group__c, Business_Line__c,
                                                                        Account_Management_Group__c, Account_Management_Reporting_Business__c, Account_Management_Reporting_Vertical__c,
                                                                        Account_Management_Reporting_Group__c From Program__c Where Id IN: setProgramIds]);

            //Loop through Subscription
            for(SBQQ__Subscription__c subscription : subscriptions) {

                //Process if Program contain in Map
                if(mapOfProgram.containsKey(subscription.Program__c)) {

                    //Populate filed of subscription from program
                    //subscription.New_Business_Vertical__c = mapOfProgram.get(subscription.Program__c).New_Business_Vertical__c;
                    
                    //Modified By Subhash Garhwal - 07/05/2018- CR-20180323-12122 - added the logic to update these fields on Subscription From Program 
                    subscription.Account_Management_Group__c = mapOfProgram.get(subscription.Program__c).Account_Management_Group__c;
                    subscription.Account_Management_Reporting_Business__c = mapOfProgram.get(subscription.Program__c).Account_Management_Reporting_Business__c;
                    subscription.Account_Management_Reporting_Vertical__c = mapOfProgram.get(subscription.Program__c).Account_Management_Reporting_Vertical__c;
                    subscription.Account_Management_Reporting_Group__c = mapOfProgram.get(subscription.Program__c).Account_Management_Reporting_Group__c;
                    
                    subscription.New_Business_Marketer__c = mapOfProgram.get(subscription.Program__c).New_Business_Marketer__c;
                    subscription.New_Business_Group__c = mapOfProgram.get(subscription.Program__c).New_Business_Group__c;
                    //subscription.Business_Line__c = mapOfProgram.get(subscription.Program__c).Business_Line__c;
                }
            }           
        }
    }
    
    /**
    * 
    *   @description    :   This method used to roll up Total Paid of component subscription where Product.Product Category = 'Travel Fee'
    *
    *   @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created - 05/30/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807
    *                       V1.2 - Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
    * 
    **/
    public static void rollUpTotalPaidSubscription(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions){

        //Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
        //Map to hold record type of subscription
        Map<String, Id> mapSubscriptionRecordTypes = new Map<String, Id>();
        mapSubscriptionRecordTypes = Constants.MAP_SUBSCRIPTION_RTYPE;

        //Get Record Type
        String componentRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT);
        String programRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM);

        //Map to hold Contract 
        Map<Id,Contract> mapContractIdsWithContract = new Map<Id,Contract>();

        //Loop through the Subscription
        for(SBQQ__Subscription__c subscription : subscriptions != null ? subscriptions : mapOldSubscriptions.values() ){

            //Check for insert case
            if(subscription.SBQQ__Contract__c != null && mapOldSubscriptions == null && componentRecordType == subscription.RecordTypeId  
                && subscription.SBQQ__Product__c != null && subscription.Total_Paid__c != null)
                mapContractIdsWithContract.put(subscription.SBQQ__Contract__c, new Contract(Id = subscription.SBQQ__Contract__c ,Total_Travel__c = 0));

            //Check for update casse
            if(subscriptions != null && mapOldSubscriptions != null && 
                    (subscription.SBQQ__Contract__c != mapOldSubscriptions.get(subscription.Id).SBQQ__Contract__c 
                    || subscription.SBQQ__Product__c != mapOldSubscriptions.get(subscription.Id).SBQQ__Product__c 
                    || subscription.Total_Paid__c != mapOldSubscriptions.get(subscription.Id).Total_Paid__c)
                    && componentRecordType == subscription.RecordTypeId ) {

                //Check new updated values not equal to null
                if(subscription.SBQQ__Contract__c != null )
                    mapContractIdsWithContract.put(subscription.SBQQ__Contract__c, new Contract(Id = subscription.SBQQ__Contract__c ,Total_Travel__c = 0));

                //Check for old 
                if(mapOldSubscriptions.get(subscription.Id).SBQQ__Contract__c != null)
                    mapContractIdsWithContract.put(mapOldSubscriptions.get(subscription.Id).SBQQ__Contract__c, new Contract(Id = mapOldSubscriptions.get(subscription.Id).SBQQ__Contract__c,Total_Travel__c = 0));
            }

            //Check for delete case
            if(subscriptions == null && componentRecordType == subscription.RecordTypeId && subscription.SBQQ__Product__c != null && subscription.SBQQ__Contract__c != null
                    && subscription.Total_Paid__c != null)
                mapContractIdsWithContract.put(subscription.SBQQ__Contract__c, new Contract(Id = subscription.SBQQ__Contract__c ,Total_Travel__c = 0));
        }

        //process if size greater than zero
        if(mapContractIdsWithContract.Size() > 0) {

            //Loop through aggreagate query
            for(AggregateResult aResult : [SELECT sum(Total_Paid__c) totalPaid, SBQQ__Contract__c cId FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: mapContractIdsWithContract.keySet()
                                            AND SBQQ__Product__r.Product_Category__c =: CPQConstants.QUOTE_LINE_PROGRAM_SUBSCRIPTIONCATEGORY_TRAVEL_FEE AND RecordType.DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT
                                            GROUP BY SBQQ__Contract__c]) {
                //Id of contract
                Id contractId = Id.valueOf(String.valueof(aResult.get('cId')));

                //Hold total paid amount
                Decimal paidAmount = (Decimal) aResult.get('totalpaid');

                //Process if map contain key
                if(mapContractIdsWithContract.ContainsKey(contractId))
                    mapContractIdsWithContract.get(contractId).Total_Travel__c = paidAmount;
            }
            //Updates values
            if(mapContractIdsWithContract.size() > 0) {
                Util.byPassAllTriggers = true;
                update mapContractIdsWithContract.values();
                Util.byPassAllTriggers = false;
                
            }
        }
    }
    
     /**
     * 
     *  @description    :   The method is used to populate the Previous Subscription on the Program Subscription record.
     *                      Rule: If from a Continuing Opp, get the Renewed Contract from the Source Opportunity, and then find the
     *                            Program Subscription for the same Product and link that Program Subscription here.
     *                            If from an Initiating Opp, field is blank
     *
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/01/2017 - Subhash Garhwal - CR-20170403-10807
     *                      V_1.1 - Modified - 03/06/2018 - Subhash Garhwal - CR-20180301-12089
   * 
     **/
     //Logic of this method is moved to 'automationSubscription' this method
    /*public static void populatePreviousSubscription(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
        
        //Map to hold record type of subscription
        Map<String,Id> mapSubscriptionRecordTypes = Util.recordtypemap(CPQConstants.OBJECT_SBQQ_SUBSCRIPTION);

        //Get Record Type
        String programRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM);
        
        //Set to hold the Opportunity Ids
        Set<Id> setOppIds = new Set<Id>();
        
        //Set to hold the Products
        Set<Id> setProductIds = new Set<Id>();
        
        //Loop over the subscriptions
        for(SBQQ__Subscription__c subscr : subscriptions) {
            
            //Check for Opportunity
            if(subscr.RecordTypeId == programRecordType && subscr.SBQQ__Product__c != null && subscr.Source_Opportunity__c != null
              && subscr.Previous_Program_Subscription__c == null && (mapOldSubscriptions == null || subscr.SBQQ__Product__c != mapOldSubscriptions.get(subscr.Id).SBQQ__Product__c
                || subscr.Source_Opportunity__c != mapOldSubscriptions.get(subscr.Id).Source_Opportunity__c)) {
                
                //Add opportunity and product ids
                setOppIds.add(subscr.Source_Opportunity__c);
                setProductIds.add(subscr.SBQQ__Product__c); 
            }
        }
        
        //Check for set size
        if(setOppIds.size() > 0 && setProductIds.size() > 0) {
            
            //Map to hold the Opportunity with Contracts
            Map<Id, Id> mapOppWithContracts = new Map<Id, Id>();
            
            //Map to hold the Contract with Program Subscription
            Map<String, Id> mapContractWithProgramSubscriptions = new Map<String, Id>();
            
            //Query through the Opportunity
            for(Opportunity opp : [Select Id, SBQQ__RenewedContract__c From Opportunity Where Id IN : setOppIds AND RecordType.DeveloperName IN : CPQConstants.SET_OPP_CONTINUING_RECORDTYPES])
                mapOppWithContracts.put(opp.Id, opp.SBQQ__RenewedContract__c);
            
            //Check for map
            if(mapOppWithContracts.size() > 0) {
                
                //Query through the Program Subscription
                for(SBQQ__Subscription__c pS : [Select Id, SBQQ__Product__c, SBQQ__Contract__c From SBQQ__Subscription__c
                                                Where SBQQ__Product__c IN : setProductIds AND SBQQ__Product__c != null AND SBQQ__Contract__c IN : mapOppWithContracts.values() AND SBQQ__Contract__c != null]) {
                    
                    //Create UK
                    String uniqueKey = pS.SBQQ__Contract__c + '-' + pS.SBQQ__Product__c;
                    
                    //Add Program Subscription in map
                    mapContractWithProgramSubscriptions.put(uniqueKey, pS.Id);  
                }
                
                //Loop over the subscriptions
                for(SBQQ__Subscription__c subscr : subscriptions) {
                    
                    //Check for Opportunity
                    if(subscr.RecordTypeId == programRecordType && subscr.SBQQ__Product__c != null && subscr.Source_Opportunity__c != null) {
                        
                        //Get the Contract from Opportunity map
                        if(mapOppWithContracts.containsKey(subscr.Source_Opportunity__c)) {
                            
                            //Create unique key
                            String uniqueKey = mapOppWithContracts.get(subscr.Source_Opportunity__c) + '-' + subscr.SBQQ__Product__c;
                            
                            //Check for Program subscription
                            if(mapContractWithProgramSubscriptions.containsKey(uniqueKey))
                                subscr.Previous_Program_Subscription__c = mapContractWithProgramSubscriptions.get(uniqueKey);
                        }
                    }
                }
            }
        }
    }*/
    
    /**
     * 
     *  @description    :   The method is used to populate "Negotiated Amount (Period)" field on the Subscription Period object.
                            Rollup of "Customer Price" from Component Subscription to "Negotiated Amount (Period)"
     *
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c> 
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/0/2017 - Saurabh Kumar - CR-20170403-10807 (DS104.1)
     * 
     **/
    public static void rollupNegotiatedAmountPeriodOnSubscriptionPeriod(List<SBQQ__Subscription__c> newSubscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions){
        
        //Get all record types of SBQQ__Subscription__c
        /*Map<String, Id> mapSubscriptionRecordTypes = Util.recordtypemap(CPQConstants.OBJECT_SBQQ_SUBSCRIPTION);
        
        //Component Record Type
        String componentRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT);
        
        //Map to hold parent records (Subscription Period)
        Map<Id, Subscription_Period__c> mapSubscriptionPeriods = new Map<Id, Subscription_Period__c>();
        
        //Checking whether records are inserting or updating
        for(SBQQ__Subscription__c subscription : newSubscriptions != null ? newSubscriptions : mapOldSubscriptions.values()) {
            
            //If Subscription Record Type is not equal to Component Record Type then skip the process
            if(subscription.RecordTypeId != componentRecordType)
                continue;
                
            //Checking for insert case only
            if(mapOldSubscriptions == null && subscription.Subscription_Period__c != null && subscription.SBQQ__CustomerPrice__c != null)
                mapSubscriptionPeriods.put(subscription.Subscription_Period__c, new Subscription_Period__c(Id = subscription.Subscription_Period__c, Negotiated_Amount_Period__c = 0));
            
            //Checking for update case only
            else if(newSubscriptions != null && mapOldSubscriptions != null && subscription.Subscription_Period__c != null && (subscription.Subscription_Period__c != mapOldSubscriptions.get(subscription.Id).Subscription_Period__c
                                                                                            || subscription.SBQQ__CustomerPrice__c != mapOldSubscriptions.get(subscription.Id).SBQQ__CustomerPrice__c)){
                
                //New parent record
                mapSubscriptionPeriods.put(subscription.Subscription_Period__c, new Subscription_Period__c(Id = subscription.Subscription_Period__c, Negotiated_Amount_Period__c = 0)); 
                
                //Old parent record
                if(mapOldSubscriptions.get(subscription.Id).Subscription_Period__c != null)
                    mapSubscriptionPeriods.put(mapOldSubscriptions.get(subscription.Id).Subscription_Period__c, new Subscription_Period__c(Id = mapOldSubscriptions.get(subscription.Id).Subscription_Period__c,
                                                                        Negotiated_Amount_Period__c = 0));
            }
            //Checking for delete case only
            else if(newSubscriptions == null && subscription.Subscription_Period__c != null)
                mapSubscriptionPeriods.put(subscription.Subscription_Period__c, new Subscription_Period__c(Id = subscription.Subscription_Period__c, Negotiated_Amount_Period__c = 0));
                
        }
        
        //Checking for map size
        if(mapSubscriptionPeriods.size() > 0) {
            
            //Aggregate query
            for(AggregateResult result : [Select Subscription_Period__c subscriptionPeriod, SUM(SBQQ__CustomerPrice__c) customerPrice From SBQQ__Subscription__c
                                         Where Subscription_Period__c != null AND Subscription_Period__c IN : mapSubscriptionPeriods.keySet() GROUP BY Subscription_Period__c]) {
                                            
                
                //Get the Sub. Period Id
                Id subPeriodId = (Id)result.get('subscriptionPeriod');
                
                //Check value in map
                if(mapSubscriptionPeriods.containsKey(subPeriodId))
                    mapSubscriptionPeriods.get(subPeriodId).Negotiated_Amount_Period__c = (Decimal)result.get('customerPrice');
                                                
            }
                
            //Bypass the trigger
            Util.BypassAllTriggers = true;
            
            update mapSubscriptionPeriods.values();
            
            //Reset the flag
            Util.BypassAllTriggers = false;
        }*/
    }
    
    /**
     * 
     *  @description    :   This method is used to populate Final Period Negotiated field on Program Subscription
     *                      Rule:
     *                          Populate with sum of Customer Amount from related Subscription (Component) records  from the final period in the
     *                          contract (greatest Segment Index)
     *
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c> 
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/04/2017 - Subhash Garhwal - CR-20170403-10807 (DS104.1)
     * 
     **/
    public static void validateFinalPeriodNegotiatedOnProgramSubscription(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapoldSubscriptions) {
        
        //Set to hold the Program Subscription Id
        Set<Id> setProSubIds = new Set<Id>();
        
        //Loop over the subscriptions
        for(SBQQ__Subscription__c sub : subscriptions) {
            
            //Check for appropriate condition to fire trigger
            if(sub.Program_Subscription__c != null && (mapoldSubscriptions == null || sub.SBQQ__SegmentIndex__c != mapoldSubscriptions.get(sub.Id).SBQQ__SegmentIndex__c
                || sub.SBQQ__CustomerPrice__c != mapoldSubscriptions.get(sub.Id).SBQQ__CustomerPrice__c || sub.Program_Subscription__c != mapoldSubscriptions.get(sub.Id).Program_Subscription__c)) {
                    
                //Add Program Subscription Id in set
                setProSubIds.add(sub.Program_Subscription__c);
                
                //Check for old
                if(mapoldSubscriptions != null && mapoldSubscriptions.get(sub.Id).Program_Subscription__c != null)
                    setProSubIds.add(mapoldSubscriptions.get(sub.Id).Program_Subscription__c);      
            }
        }
        
        //Check for set size
        if(setProSubIds.size() > 0) {
            
            //List to update the Program Subscriptions
            List<SBQQ__Subscription__c> programSubscriptions = new List<SBQQ__Subscription__c>();
            
            //SOQL on the Program Subscription
            for(SBQQ__Subscription__c sub : [Select Id, Previous_Period_Negotiated__c, (Select Id, SBQQ__CustomerPrice__c From Subscriptions1__r Where SBQQ__SegmentIndex__c != null ORDER BY SBQQ__SegmentIndex__c DESC LIMIT 1)
                                                        From SBQQ__Subscription__c Where Id IN : setProSubIds]) {
                
                //Check for Component Subscription
                if(sub.Subscriptions1__r != null && sub.Subscriptions1__r.size() > 0 && sub.Previous_Period_Negotiated__c != sub.Subscriptions1__r[0].SBQQ__CustomerPrice__c) {
                    
                    //Check for Final Period Negotiated
                    sub.Previous_Period_Negotiated__c = sub.Subscriptions1__r[0].SBQQ__CustomerPrice__c;
                    
                    //Add Program Subscription in list to update
                    programSubscriptions.add(sub);
                }   
            }
            
            //Check for size
            if(programSubscriptions.size() > 0) {
                Util.byPassAllTriggers = true;
                update programSubscriptions;
                Util.byPassAllTriggers = false;
            }
        }
    }
    
    /**
     * 
     *  @description    :   This method is used to populate Program
     *                      Rule:
     *                          Use the related Product to get the linked Program, and populate the link to the Product here
     *
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c> 
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 06/04/2017 - Created - Subhash Garhwal - CR-20170403-10807 (DS104.1)
     *                      V_1.1 - 10/11/2018 - Modified By Subhash Garhawal - CR-20180720-12456
     *                      V_1.2 - 12/06/2018 - Modified By Victor Hanson - CR-20181019-12685
     * 
     **/    
    public static void populateProgram(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
        
        //Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
        //Map to hold record type of subscription
        Map<String, Id> mapSubscriptionRecordTypes = new Map<String, Id>();
        mapSubscriptionRecordTypes = Constants.MAP_SUBSCRIPTION_RTYPE;
        
        //Getting record type Id
        String programRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM);
        
        //Set to hold the Product
        Set<Id> setProductIds = new Set<Id>();
        
        //Processing on the new records
        for(SBQQ__Subscription__c subscription : subscriptions){
            
            //Checking of Program record type
            if(subscription.RecordTypeId == programRecordType && subscription.SBQQ__Product__c != null && (mapOldSubscriptions == null
                || subscription.SBQQ__Product__c != mapOldSubscriptions.get(subscription.Id).SBQQ__Product__c))
            {
                setProductIds.add(subscription.SBQQ__Product__c);
                
                //check for top parent product (CR-20181019-12685)
                if (subscription.Top_Parent_Product__c != null)
                {
                    setProductIds.add(subscription.Top_Parent_Product__c);
                }
        
            }
        }
        
        //Check for Products
        if(setProductIds.size() > 0) {
            
            //Map to hold the Products
            Map<Id, Product2> mapProducts = new Map<Id, Product2>([Select Id, Program__c, Family From Product2 Where Id IN : setProductIds AND Program__c != null]);
            
            //Processing on the new records
            for(SBQQ__Subscription__c subscription : subscriptions){
                
                //Checking of Program record type
                if(subscription.RecordTypeId == programRecordType && subscription.SBQQ__Product__c  != null && mapProducts.containsKey(subscription.SBQQ__Product__c))
                    subscription.Program__c = mapProducts.get(subscription.SBQQ__Product__c).Program__c;
                
                if(subscription.RecordTypeId == programRecordType && subscription.Top_Parent_Product__c  != null && mapProducts.containsKey(subscription.Top_Parent_Product__c))
                    subscription.Parent_Program__c = mapProducts.get(subscription.Top_Parent_Product__c).Program__c;
        
            }
        }
    }
    
    
    /**
     * 
     *  @description    :   This method is used to call Subscription Period logic when Contract ABC is changed
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c> 
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/06/2017 - Subhash Garhwal - CR-20170403-10807 (DS104.1)
     * 
     **/
    public static void validateSubscriptionPeriods(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
        
        //Set to hold the Program Subscription values
        Set<Id> setProSubIds = new Set<Id>();
        
        //Loop over the Subsription
        for(SBQQ__Subscription__c sub : subscriptions) {
            
            //Check for Contract ABC
            if(sub.Previous_Contract_ABC__c != null && (mapOldSubscriptions == null || sub.Previous_Contract_ABC__c != mapOldSubscriptions.get(sub.Id).Previous_Contract_ABC__c))
                setProSubIds.add(sub.Previous_Contract_ABC__c); 
        }
        
        //Check for set size
        if(setProSubIds.size() > 0) {
            
            //SOQL over the Subscription Periods
            List<Subscription_Period__c> subscriptionPeriods = [Select Id, Previous_Subscription_Period__c,Program_Subscription__c From Subscription_Period__c Where 
                                                                        Program_Subscription__c IN : setProSubIds AND Previous_Subscription_Period__c = null];
            
            //Check for size
            if(subscriptionPeriods.size() > 0)
                SubscriptionPeriodTriggerHelper.populatePreviousPeriodNegotiated(subscriptionPeriods, null);
        }
    }
    
    
    /**
     * 
     *  @description    :   This method is used to update membership on the Progra Subscription
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c> 
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/06/2017 - Subhash Garhwal - CR-20170403-10807 (DS104.1)
     *              	    V_1.1 - 10/09/2017 - Modified - Victor Hanson - Issue--CR11062--QA--00006691 - autopopulate Membership_Lookup__c field
     *              	    V_1.2 - 12/05/2018 - Modified - Victor Hanson - For Enrollment Services products, Populate Membership based on Parent Product
     *              	    V_1.3 - 12/06/2018 - Modified - Victor Hanson - CR-20181019-12685
     * 
     **/
    public static void updateMembershiponProgramSubscription(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
        
        //Set to hold the Program Id
        Set<Id> setProgramIds = new Set<Id>();
        
        //Set to hold the account Ids
        Set<Id> setAccountIds = new Set<Id>();
        
        //Set to hold the subscription ids
        Set<Id> setSubscriptionIds = new Set<Id>();
        
        //Loop over the Subscription
        for(SBQQ__Subscription__c sub : subscriptions) {
            
            //Check for appropriate condition to execute trigger
            if(sub.Program__c != null && sub.SBQQ__Account__c != null && (mapOldSubscriptions == null || sub.Program__c != mapOldSubscriptions.get(sub.Id).Program__c 
                || sub.SBQQ__Account__c != mapOldSubscriptions.get(sub.Id).SBQQ__Account__c || sub.Stage_Period__c != mapOldSubscriptions.get(sub.Id).Stage_Period__c))
            {
                
                //Add Program and account ids in map
                setProgramIds.add(sub.Program__c);
                
                //get parent program if available
                if (sub.Parent_Program__c != null) {
                    setProgramIds.add(sub.Parent_Program__c);
                }
                
                setAccountIds.add(sub.SBQQ__Account__c);    
                setSubscriptionIds.add(sub.Id); 
            }
        }
        
  //Check for size
        if(setProgramIds.size() > 0 && setAccountIds.size() > 0) {
            
            //Map to hold the membership
            Map<String, Id> mapMemeships = new Map<String, Id>();
            
            //SOQL on the memership
            for(Membership__c mem : [Select Id, Program__c, Account_Name__c, Program_Business_Line__c, OwnerId
                                        From Membership__c Where Program__c IN : setProgramIds AND Account_Name__c IN : setAccountIds]) {

                //Create a unique key
                String uK = mem.Account_Name__c + '-' + mem.Program__c; 
                
                //Add Membership
                mapMemeships.put(uK, mem.Id);
            }
            
            //Check memership size
            if(mapMemeships.size() > 0) {

                //List to update SBQQ__Subscription__c
                List<SBQQ__Subscription__c> subscriptionsToUpdate = new List<SBQQ__Subscription__c>();
                
                //list to update Subscription_Period__c
                List<Subscription_Period__c> subscriptionPeriodsToUpdate = new List<Subscription_Period__c>();
                
                //Loop over the Subscriptions
                for(SBQQ__Subscription__c sub : [Select Id, Program__c, SBQQ__Account__c, Membership__c, Parent_Program__c,
                                                 (SELECT Id, Membership_Lookup__c FROM Program_Subscriptions__r) 
                                                 From SBQQ__Subscription__c 
                                                 Where Id IN : setSubscriptionIds 
                                                 AND RecordType.DeveloperName = 'Program']) 
                {
                    
                    Id programKey = sub.Program__c;
                    if (sub.Parent_Program__c != null) {
                        programKey = sub.Parent_Program__c;
                    }
                    //Create unique key
                    String uK = sub.SBQQ__Account__c + '-' + programKey;
                    
                    //Check uk in map
                    if(mapMemeships.containsKey(uK) && sub.Membership__c != mapMemeships.get(uK)) {
                        
                        //Update Membership
                        sub.Membership__c = mapMemeships.get(uK);
                                                
                        //Add subscription in list
                        subscriptionsToUpdate.add(sub);
                        
                        //Set the Membership Lookup on all child Subscription Periods
                        if (sub.Program_Subscriptions__r != null) {
                            for (Subscription_Period__c sp : sub.Program_Subscriptions__r) {
                                
                                sp.Membership_Lookup__c = sub.Membership__c;
                                subscriptionPeriodsToUpdate.add(sp);
                            }
                        }
                    }
                }
                
    //Check for size
                if(subscriptionsToUpdate.size() > 0) {
                    Util.byPassAllTriggers = true;
                    update subscriptionsToUpdate;
                    Util.byPassAllTriggers = false;
                }
                
                //update subscription periods
                if (subscriptionPeriodsToUpdate.size() > 0) {
                    Util.byPassAllTriggers = true;
                    update subscriptionPeriodsToUpdate;
                    Util.byPassAllTriggers = false;
                }
            }
        }
    }
    
    /**
     * 
     *  @description    :   This method is used to update membership status when ever Subscription update
     *
     *  @args           :   Map<Id, SBQQ__Subscription__c> 
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/04/2017 - Saurabh Kumar - CR-20170403-10807 (DS114)
     *          	    V_1.1 - Modified - Subhash Garhwal - 02/22/2019  - CR-20190215-12886
     * 
    **/
    public static void updateMembershipStatusBySubscription(List<SBQQ__Subscription__c> newsubscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {  

        //Checking for update use case
        if(newsubscriptions != null && mapOldSubscriptions != null) {
            
            //Set of eligible subscriptions
            Set<Id> setOfEligibleSubscriptions = new Set<Id>();
            
            //Loop through subscription records
            for(SBQQ__Subscription__c con : newsubscriptions) {
                //Checking for field value changes
                if(mapOldSubscriptions == null || con.SBQQ__StartDate__c != mapOldSubscriptions.get(con.ID).SBQQ__StartDate__c
                    ||
                    con.SBQQ__EndDate__c != mapOldSubscriptions.get(con.ID).SBQQ__EndDate__c
                    ||
                    con.Status__c != mapOldSubscriptions.get(con.ID).Status__c
                    ||
                    con.Renewal_Opp_Stage__c != mapOldSubscriptions.get(con.ID).Renewal_Opp_Stage__c
                    ||
                    con.SBQQ__Account__c != mapOldSubscriptions.get(con.ID).SBQQ__Account__c
                ) {  
                    setOfEligibleSubscriptions.add(con.Id);     
                }
            }
            
            //Checking set for it's size
            if(setOfEligibleSubscriptions.size() > 0) {
                
                //Set to hold Subscription Ids related to Membership
                Set<Id> setSubscriptionIds = new Set<Id>();
                
                //Map of memberships
                Map<Id, Membership__c> mapMemberships = new Map<Id, Membership__c>();   
                
                //Create a set of Contract Ids related with membership records
                Set<Id> contracts = new Set<Id>();
                
		//Added By Subhash Garhwal - on 2/15/2019 - CR-20190215-12886 - there are 2 same checks for Earliest_Subscription__c in the where clause, so replaced one check with Active_Subscription__c 
                //Loop through the membership records and prepare the data set to be updated
                for(Membership__c membership : [SELECT Id, Payer_Status__c, Active_Contract_Idenfied__r.Status__c, Active_Contract_Idenfied__r.Start__c, 
                                                    Latest_Contract__r.Status__c, Membership_Status__c, Program__c,
                                                    Earliest_Contract__r.Start__c, Latest_Contract__r.Start__c, Account_Name__c,
                                                    Active_Contract_Idenfied__r.End__c, Latest_Contract__r.Payer_Account__c, 
                                                    Active_Contract_Idenfied__r.Payer_Account__c, Program_Business_Line__c,Membership_Status_Text__c,
                                                    Latest_Contract__r.Renewal_Opp_Status__c, Earliest_Contract__r.Status__c, Latest_Contract__r.End__c,
                                                    Earliest_Subscription__c, Active_Subscription__c, Latest_Subscription__c 
                                                    FROM Membership__c 
                                                    WHERE (Active_Subscription__c != null AND Active_Subscription__c IN : setOfEligibleSubscriptions)
                                                            OR 
                                                            (Earliest_Subscription__c != null AND Earliest_Subscription__c IN : setOfEligibleSubscriptions)
                                                            OR 
                                                            (Latest_Subscription__c != null AND Latest_Subscription__c IN : setOfEligibleSubscriptions)]) {
                    
                    //Checking for the null and populating set with values                                          
                    if(membership.Earliest_Subscription__c != null)
                        setSubscriptionIds.add(membership.Earliest_Subscription__c);
                    if(membership.Active_Subscription__c != null)
                        setSubscriptionIds.add(membership.Active_Subscription__c);
                    if(membership.Latest_Subscription__c != null)
                        setSubscriptionIds.add(membership.Latest_Subscription__c);
                    
                    //Add Active_Contract_Idenfied__c in set if not null
                    if(membership.Active_Contract_Idenfied__c != null)
                        contracts.add(membership.Active_Contract_Idenfied__c);
                   
                    //Add Earliest_Contract__c in set if not null
                    if(membership.Earliest_Contract__c != null)
                        contracts.add(membership.Earliest_Contract__c);
                    
                    //Add Latest_Contract__c in set if not null
                    if(membership.Latest_Contract__c != null)
                        contracts.add(membership.Latest_Contract__c);
                
                    //map of membership
                    mapMemberships.put(membership.Id, membership);
                }
                
                //Checking map for its size
                if(mapMemberships.values().size() > 0) {
                    
                    //Map to hold Subscription records 
                    Map<Id, SBQQ__Subscription__c> mapSubscriptions = new Map<Id, SBQQ__Subscription__c>();
                    
                    //Map of contracts
                    Map<Id, Contract__c> mapContract = new Map<Id, Contract__c>();
                    
                    //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114)
                    //Checking for map size
                    if(setSubscriptionIds.size() > 0){
                        
                        mapSubscriptions = new Map<Id, SBQQ__Subscription__c>([Select Id, SBQQ__StartDate__c, SBQQ__EndDate__c, 
                                                                               Renewal_Opp_Stage__c, Status__c, Program__c,
                                                                               SBQQ__Account__c 
                                                                               From  SBQQ__Subscription__c 
                                                                                Where Id IN : setSubscriptionIds]);
                    }
                    //Checking set for size value
                    else if(contracts.size() > 0) {
                
                        //fetch related data from database from Contract ABC object
                        mapContract = new Map<Id, Contract__c>([Select Id, Start__c, End__c, Status__c, Renewal_Opp_Status__c, 
                                                                    Payer_Account__c 
                                                                    from Contract__c
                                                                    where ID IN: contracts]);
                    }
                    
                    //Temporary variable to hold the membership status
                    String memberShipStatus;
                    
                    //Map of membership to be updated
                    Map<Id, Membership__c> mapOfMembershipsToBeUpdated = new Map<Id, Membership__c>();
                    
                    //Loop through the membership records and prepare the data set to be updated
                    for(Membership__c membership : mapMemberships.values()) {
            
                        //skip Royall memberships.  Royall memberships are populated based on Program Packages
                        if (membership.Program_Business_Line__c == Label.Royall_Business_Line) continue;
                        
                        //reset membership status text
                        memberShipStatus = '';
                        
                        //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114)
                        //Checking for map size. If Subscription records are exist then process on the Subsription otherwise process on the Contract
                        if(mapSubscriptions.values().size() > 0){
                
                            //Check if Earliest_Subscription__r.SBQQ__StartDate__c is smaller then equals to today's date then set the Membership status as "Prospect - Pending Future Start Date"
                            if(membership.Earliest_Subscription__c != null && mapSubscriptions.containsKey(membership.Earliest_Subscription__c) 
                                    && (mapSubscriptions.get(membership.Earliest_Subscription__c).SBQQ__StartDate__c == null 
                                        || mapSubscriptions.get(membership.Earliest_Subscription__c).SBQQ__StartDate__c > Date.today())) {
                                memberShipStatus = Constants.PROSPECT_PENDING_FUTURE_START_DATE;
                            }
                            //If Active Subscription's SBQQ__EndDate__c is greater then today's date
                            else if(membership.Active_Subscription__c != null && mapSubscriptions.containsKey(membership.Active_Subscription__c) 
                                    && mapSubscriptions.get(membership.Active_Subscription__c).SBQQ__EndDate__c != null 
                                    && mapSubscriptions.get(membership.Active_Subscription__c).SBQQ__EndDate__c >= Date.today()) {
                                    if(mapSubscriptions.get(membership.Active_Subscription__c).Status__c != null 
                                       && mapSubscriptions.get(membership.Active_Subscription__c).Status__c == Constants.HONORARY) {
                                        memberShipStatus = Constants.MEMBER_HONORARY;
                                    } else if(membership.Payer_Status__c != null && membership.Payer_Status__c == Constants.PAYER){
                                        memberShipStatus = Constants.MEMBER_PAYER;
                                    }
                                    else if(membership.Payer_Status__c != null && membership.Payer_Status__c == 'Integrated - Global') { 
                                        memberShipStatus = Constants.MEMBER_PAYER_INTEGRATED_GLOBAL; 
                                    } 
                                    /*else if(membership.Program__c != mapSubscriptions.get(membership.Active_Subscription__c).Program__c){ //if program isn't related, it must be integrated global
                                        memberShipStatus = Constants.MEMBER_PAYER_INTEGRATED_GLOBAL; //NOTE: MEMBER_PAYER_INTEGRATED_GLOBAL = 'Member - Integrated (Global)'
                                    }*/
                                    else {
                                        memberShipStatus = Constants.MEMBER_INTEGRATED;
                                    }
                            } else if(membership.Latest_Subscription__c != null && mapSubscriptions.containsKey(membership.Latest_Subscription__c) 
                                && mapSubscriptions.get(membership.Latest_Subscription__c).SBQQ__EndDate__c != null 
                                && mapSubscriptions.get(membership.Latest_Subscription__c).SBQQ__EndDate__c < Date.today() 
                                && mapSubscriptions.get(membership.Latest_Subscription__c).Renewal_Opp_Stage__c != null 
                                && mapSubscriptions.get(membership.Latest_Subscription__c).Renewal_Opp_Stage__c != ''
                                && (mapSubscriptions.get(membership.Latest_Subscription__c).Renewal_Opp_Stage__c.toLowerCase().contains(Constants.PENDING)
                                    || mapSubscriptions.get(membership.Latest_Subscription__c).Renewal_Opp_Stage__c.toLowerCase().contains(Constants.CONTRACT_RECEIVED))
                                ) {
                                    if (mapSubscriptions.get(membership.Latest_Subscription__c).Status__c  == Constants.HONORARY) {
                                        memberShipStatus = Constants.MEMBER_HONORARY_GRACE;
                                    } else if(mapSubscriptions.get(membership.Latest_Subscription__c).SBQQ__Account__c != null 
                                            && mapSubscriptions.get(membership.Latest_Subscription__c).SBQQ__Account__c == membership.Account_Name__c) {
                                        memberShipStatus = Constants.MEMBER_PAYER_GRACE;
                                    } else {
                                        memberShipStatus = Constants.MEMBER_INTEGRATED_GRACE;
                                    }
                            }else if(membership.Latest_Subscription__c != null && mapSubscriptions.containsKey(membership.Latest_Subscription__c) 
                                    && mapSubscriptions.get(membership.Latest_Subscription__c).SBQQ__EndDate__c < Date.today() 
                                    && mapSubscriptions.get(membership.Latest_Subscription__c).SBQQ__EndDate__c > (Date.today() - 270)
                                    && (mapSubscriptions.get(membership.Latest_Subscription__c).Renewal_Opp_Stage__c == Constants.DROPPED
                                        || mapSubscriptions.get(membership.Latest_Subscription__c).Renewal_Opp_Stage__c == Constants.VOIDER)) {
                                memberShipStatus = Constants.PROSPECT_RECENT_DROP;
                            } else if(membership.Earliest_Subscription__c != null && mapSubscriptions.containsKey(membership.Earliest_Subscription__c) 
                                    && mapSubscriptions.get(membership.Earliest_Subscription__c).SBQQ__StartDate__c >= date.newInstance(1960,01,01)) {
                                if(membership.Active_Subscription__c != null && mapSubscriptions.containsKey(membership.Active_Subscription__c) 
                                        && mapSubscriptions.get(membership.Active_Subscription__c).SBQQ__StartDate__c > Date.today()) {
                                    memberShipStatus = Constants.PROSPECT_PENDING_FUTURE_START_DATE; //Modified - Abhinav Sharma - 08/12/2020 - CR-20190826-13286
                                } else {
                                    memberShipStatus = Constants.PROSPECT_PAST_MEMBER;
                                }   
                            } else {
                                memberShipStatus = Constants.PROSPECT_PURE;
                            }
                        }
                        //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114) - Upto here
                        else if(mapContract.values().size() > 0){
                
                            //Check if Earliest_Contract__r.Start__c is smaller then equals to today's date then set the Membership status as "Prospect - Pending Future Start Date"
                            if(membership.Earliest_Contract__c != null && mapContract.containsKey(membership.Earliest_Contract__c) 
                                    && (mapContract.get(membership.Earliest_Contract__c).Start__c == null 
                                        || mapContract.get(membership.Earliest_Contract__c).Start__c > Date.today())) {
                                memberShipStatus = Constants.PROSPECT_PENDING_FUTURE_START_DATE;
                            } 
                            //If Active contract's end date is greater then today's date
                            else if(membership.Active_Contract_Idenfied__c != null && mapContract.containsKey(membership.Active_Contract_Idenfied__c) 
                                    && mapContract.get(membership.Active_Contract_Idenfied__c).End__c != null 
                                    && mapContract.get(membership.Active_Contract_Idenfied__c).End__c >= Date.today()) {
                                    if(mapContract.get(membership.Active_Contract_Idenfied__c).Status__c != null 
                                       && mapContract.get(membership.Active_Contract_Idenfied__c).Status__c == Constants.HONORARY) {
                                        memberShipStatus = Constants.MEMBER_HONORARY;
                                    } else if(membership.Payer_Status__c != null && membership.Payer_Status__c == Constants.PAYER){
                                        memberShipStatus = Constants.MEMBER_PAYER;
                                    } else {
                                        memberShipStatus = Constants.MEMBER_INTEGRATED;
                                    }
                            } else if(membership.Latest_Contract__c != null && mapContract.containsKey(membership.Latest_Contract__c) 
                                && mapContract.get(membership.Latest_Contract__c).End__c != null 
                                && mapContract.get(membership.Latest_Contract__c).End__c < Date.today() 
                                && mapContract.get(membership.Latest_Contract__c).Renewal_Opp_Status__c != null 
                                && mapContract.get(membership.Latest_Contract__c).Renewal_Opp_Status__c != ''
                                && (mapContract.get(membership.Latest_Contract__c).Renewal_Opp_Status__c.toLowerCase().contains(Constants.PENDING)
                                    || mapContract.get(membership.Latest_Contract__c).Renewal_Opp_Status__c.toLowerCase().contains(Constants.CONTRACT_RECEIVED))
                            ) {
                                if (mapContract.get(membership.Latest_Contract__c).Status__c  == Constants.HONORARY) {
                                    memberShipStatus = Constants.MEMBER_HONORARY_GRACE;
                                } else if(mapContract.get(membership.Latest_Contract__c).Payer_Account__c != null 
                                        && mapContract.get(membership.Latest_Contract__c).Payer_Account__c == membership.Account_Name__c) {
                                    memberShipStatus = Constants.MEMBER_PAYER_GRACE;
                                } else {
                                    memberShipStatus = Constants.MEMBER_INTEGRATED_GRACE;
                                }
                            } else if(membership.Latest_Contract__c != null && mapContract.containsKey(membership.Latest_Contract__c) 
                                        && mapContract.get(membership.Latest_Contract__c).End__c < Date.today() 
                                        && mapContract.get(membership.Latest_Contract__c).End__c > (Date.today() - 270)
                                        && (mapContract.get(membership.Latest_Contract__c).Renewal_Opp_Status__c == Constants.DROPPED
                                            || mapContract.get(membership.Latest_Contract__c).Renewal_Opp_Status__c == Constants.VOIDER)) {
                                memberShipStatus = Constants.PROSPECT_RECENT_DROP;
                            } else if(membership.Earliest_Contract__c != null && mapContract.containsKey(membership.Earliest_Contract__c) 
                                    && mapContract.get(membership.Earliest_Contract__c).Start__c >= date.newInstance(1960,01,01)) {
                                if(membership.Active_Contract_Idenfied__c != null && mapContract.containsKey(membership.Active_Contract_Idenfied__c) 
                                        && mapContract.get(membership.Active_Contract_Idenfied__c).Start__c > Date.today()) {
                                    memberShipStatus = Constants.PROSPECT_PENDING_FUTURE_START_DATE; //Modified - Abhinav Sharma - 08/12/2020 - CR-20190826-13286
                                } else {
                                    memberShipStatus = Constants.PROSPECT_PAST_MEMBER;
                                }   
                            } else {
                                memberShipStatus = Constants.PROSPECT_PURE;
                            }   
                        }
                        
                        //Checking for difference in between statuses
                        if(memberShipStatus != null && memberShipStatus != '') {
                            if (membership.Membership_Status_Text__c != memberShipStatus) {
                                membership.Membership_Status_Change_Date__c = system.today();
                                membership.Membership_Status_Text__c = memberShipStatus;
                                mapOfMembershipsToBeUpdated.put(membership.Id, membership);
                            }
                        }
                    }
        
                    //Check for the list size and update the recors if needed
                    if(mapOfMembershipsToBeUpdated.size() > 0) {
                        Util.byPassAllTriggers = true;
                        update mapOfMembershipsToBeUpdated.values();
                        Util.byPassAllTriggers = false;
                    }       
                }
            }
        }
    }
    
    /**
     * 
     *  @description    :   This method is used to update Final Period + Uplift on the Program Subscription.
     *                      Rule: 
     *                      Get all subscription components related to the Program Subscription with the greatest Segment Index, and add all of the
     *                      SBQQ__CustomerPrice__c values.
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c> 
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/06/2017 - Subhash Garhwal - CR-20170403-10807 (DS114)
     *                      V_1.1 - Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
     * 
     **/
    public static void updateFinalPeriodUpliftonProgramSubscription(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
        
        //Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
        //Map to hold record type of subscription
        Map<String, Id> mapSubscriptionRecordTypes = new Map<String, Id>();
        mapSubscriptionRecordTypes = Constants.MAP_SUBSCRIPTION_RTYPE;

        //Get Record Type
        String componentRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT);
        String programRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM);
        
        //Set to hold the Program Subscription Ids
        Set<Id> setProgramSubscriptions = new Set<Id>();
        
        //Loop over the Subscriptions
        for(SBQQ__Subscription__c sub : subscriptions) {
            
            //Check appropriate condition to fire the trigger logic
            if(sub.SBQQ__SegmentIndex__c != null && sub.RecordTypeId == componentRecordType && sub.Program_Subscription__c != null && (mapOldSubscriptions == null
                || sub.Program_Subscription__c != mapOldSubscriptions.get(sub.Id).Program_Subscription__c
                || sub.SBQQ__CustomerPrice__c != mapOldSubscriptions.get(sub.Id).SBQQ__CustomerPrice__c)) {
                    
                //Add Program Subscription Id
                setProgramSubscriptions.add(sub.Program_Subscription__c);       
            }
        }
        
        //Check for set size
        if(setProgramSubscriptions.size() > 0) {
            
            //Map to hold the greatest Segment Index on the Program Subscription
            Map<Id, Decimal> mapProSubWithGreatestSegmentIndex = new Map<Id, Decimal>();
            
            //Map to update the Program Subscriptions
            Map<Id, SBQQ__Subscription__c> mapProgramSubscriptions = new Map<Id, SBQQ__Subscription__c>();
            
            //SOQL on the Component Subscriptions
            for(SBQQ__Subscription__c compSub : [Select Id, SBQQ__SegmentIndex__c, SBQQ__CustomerPrice__c, Program_Subscription__c From SBQQ__Subscription__c Where RecordTypeId =: componentRecordType
                                                        AND Program_Subscription__c IN : setProgramSubscriptions AND SBQQ__SegmentIndex__c != null
                                                        ORDER BY SBQQ__SegmentIndex__c DESC, Program_Subscription__c]) {
                
                //Check Program Subscription in map
                if(!mapProSubWithGreatestSegmentIndex.containsKey(compSub.Program_Subscription__c)) {
                    
                    //Add Program Subscription in map
                    mapProSubWithGreatestSegmentIndex.put(compSub.Program_Subscription__c, compSub.SBQQ__SegmentIndex__c);
                    
                    //Update Final Period + Uplift
                    mapProgramSubscriptions.put(compSub.Program_Subscription__c, new SBQQ__Subscription__c(Id = compSub.Program_Subscription__c, Previous_Period_Plus_Uplift__c = compSub.SBQQ__CustomerPrice__c != null ? compSub.SBQQ__CustomerPrice__c : 0));
                
                } else if(mapProSubWithGreatestSegmentIndex.get(compSub.Program_Subscription__c) == compSub.SBQQ__SegmentIndex__c) {
                    
                    //Check for Customer Price
                    if(compSub.SBQQ__CustomerPrice__c != null) {
                        
                        //Get the Final Period + Uplift value
                        Decimal finalPeriodUplift = mapProgramSubscriptions.get(compSub.Program_Subscription__c).Previous_Period_Plus_Uplift__c + compSub.SBQQ__CustomerPrice__c;
                        
                        //Update Final Period values
                        mapProgramSubscriptions.get(compSub.Program_Subscription__c).Previous_Period_Plus_Uplift__c = finalPeriodUplift;
                    }
                }           
            }
            
            //Update
            if(mapProgramSubscriptions.size() > 0) {
                
                //Update
                update mapProgramSubscriptions.values();
                
                //List to update Pending Subscription Period
               /* List<Subscription_Period__c> pendingSubscriptionPeriods = new List<Subscription_Period__c>();
                
                //SOQL over Pending Subscription Period
                for(Subscription_Period__c sP : [Select Id, Negotiated_Amount_Period__c, Program_Subscription__c,Period_End_Date__c From Subscription_Period__c
                                                        Where Program_Subscription__c IN : mapProgramSubscriptions.keySet() AND Segment_Index__c = null
                                                        AND Stage__c = 'Pending' ORDER BY Period_End_Date__c DESC]) {
                    //Update the Negotiated_Amount_Period__c
                    sP.Negotiated_Amount_Period__c = mapProgramSubscriptions.get(sP.Program_Subscription__c).Previous_Period_Plus_Uplift__c;
                    
                    //Add Subscription Period in list
                    pendingSubscriptionPeriods.add(sP);
                }
                
                //Update
                if(pendingSubscriptionPeriods.size() > 0) {
                    Util.byPassAllTriggers = true;
                    update pendingSubscriptionPeriods;
                    Util.byPassAllTriggers = false;
                } */
            }
        }   
    }
    /**
     * 
     *  @description	:   Method to populate "Tye__C" field on contract records associated with program subscription
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 06/06/2017 - Subhash Garhwal - 6/6/2017
     *                      V_1.1 - Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
     * 
     **/

    public static void populateTypeOnContract(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {

        //Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
        //Get all record types of SBQQ__Subscription__c
        Map<String, Id> mapSubscriptionRecordTypes = new Map<String, Id>();
        mapSubscriptionRecordTypes = Constants.MAP_SUBSCRIPTION_RTYPE;
        
        //Get Record Type
        String componentRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT);
        String programRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM);
 
        //Set to hold program
        Set<Id> setOfprogramIds = new Set<Id>();

        //Loop through Subscription records
        for (SBQQ__Subscription__c subscription: subscriptions) {

            //Process if condition are true
            if( subscription.SBQQ__Contract__c != null && (mapOldSubscriptions == null ||  subscription.SBQQ__Contract__c != mapOldSubscriptions.get(subscription.Id).SBQQ__Contract__c)
                 && subscription.Program__c != null && subscription.RecordTypeId == programRecordType)
                setOfprogramIds.add(subscription.Program__c);
        }
 
        //Process if size is greater than zero
        if(setOfprogramIds.Size() > 0 ) {

            //Map to hold program
            Map<Id,Program__c> mapOfProgram = new Map<Id,Program__c>([Select Id, Renewable__c From Program__c where Id IN : setOfprogramIds AND Renewable__c = true ]);
            
            //Map to hold the Contract
            Map<Id, Contract> mapContracts = new Map<Id, Contract>();
            
            //Loop through Subscription records
            for (SBQQ__Subscription__c subscription: subscriptions) {

                //Check for contract
                if(subscription.SBQQ__Contract__c != null &&  subscription.RecordTypeId == programRecordType) {

                    //Instance of contract
                    Contract con = new Contract();
            
           	   /*
                    //Commented: Issue--CR10808--QA--00004686
                    //Check product contain in map or not
                    if(mapOfProgram.containsKey(subscription.Program__c)) {
                        
                        //Add Contract in map
                        mapContracts.put(subscription.SBQQ__Contract__c, new Contract(Id = subscription.SBQQ__Contract__c, Type__C = CPQConstants.Type_RENEWAL));
                    }
                    
                    //Else NBB
                    else if(!mapContracts.containsKey(subscription.SBQQ__Contract__c)) {
                        
                        //Add Contract in map
                        mapContracts.put(subscription.SBQQ__Contract__c, new Contract(Id = subscription.SBQQ__Contract__c, Type__C = CPQConstants.Type_NBB));
                    }
                    */
                }
            }
            
            //Update
            if(mapContracts.Size() > 0) {
                
                //Bypass trigger
                Util.BypassAllTriggers = true;
                
                //Update
                //update mapContracts.values();
                
                //Reset
                Util.BypassAllTriggers = false;
            }
        }
    }
/**
    * 
    *   @description    :   This method used to roll up the Total_Negotiated_Amount__c of subscription to Total_Negotiated_Amt_SC__c of Invoice billing schedule
    *
    *   @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created - 06/7/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807
    *                       V1.2 - Modified - 08/10/2017  Colin McGloin - Commented out code since that field is being populated solely from the Contract ABC now
    * 
    **/
    /*public static void rollUpNegotiationAmountSubscription(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions){

        //Map to hold record type of subscription
        Map<String,Id> mapSubscriptionRecordTypes = Util.recordtypemap(CPQConstants.OBJECT_SBQQ_SUBSCRIPTION);

        //Get Record Type
        String componentRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT);
        String programRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM);

        //Map to hold Invoice scheduling
        Map<Id,Invoice_Billing_Schedule__c> mapInvoiceBillingSchedule = new Map<Id,Invoice_Billing_Schedule__c>();

        //Loop through the Subscription
        for(SBQQ__Subscription__c subscription : subscriptions != null ? subscriptions : mapOldSubscriptions.values() ){

            //Check for insert case
            if(subscription.Invoice_Billing_Schedule__c != null && mapOldSubscriptions == null && subscription.RecordTypeId == programRecordType  && subscription.Negotiated_Amount_Subscription__c != null)
                mapInvoiceBillingSchedule.put(subscription.Invoice_Billing_Schedule__c, new Invoice_Billing_Schedule__c (Id = subscription.Invoice_Billing_Schedule__c, 
                                                Total_Negotiated_Amt__c = 0));
 
            //Check for update casse
            if(subscriptions != null && mapOldSubscriptions != null && subscription.RecordTypeId == programRecordType
                && (subscription.Negotiated_Amount_Subscription__c != mapOldSubscriptions.get(subscription.Id).Negotiated_Amount_Subscription__c 
                || subscription.Invoice_Billing_Schedule__c != mapOldSubscriptions.get(subscription.Id).Invoice_Billing_Schedule__c)) {

                //Check new updated values not equal to null
                if(subscription.Invoice_Billing_Schedule__c != null )
                    mapInvoiceBillingSchedule.put(subscription.Invoice_Billing_Schedule__c, new Invoice_Billing_Schedule__c (Id = subscription.Invoice_Billing_Schedule__c, 
                                                Total_Negotiated_Amt__c = 0 ));  

                //Check for old 
                if(mapOldSubscriptions.get(subscription.Id).Invoice_Billing_Schedule__c != null)
                    mapInvoiceBillingSchedule.put(mapOldSubscriptions.get(subscription.Id).Invoice_Billing_Schedule__c, 
                                                new Invoice_Billing_Schedule__c (Id = mapOldSubscriptions.get(subscription.Id).Invoice_Billing_Schedule__c, 
                                                Total_Negotiated_Amt__c = 0 ));
            }

            //Check for delete case
            if(subscriptions == null && subscription.RecordTypeId == programRecordType  && subscription.Negotiated_Amount_Subscription__c != null 
                && subscription.Invoice_Billing_Schedule__c != null )
                mapInvoiceBillingSchedule.put(subscription.Invoice_Billing_Schedule__c, new Invoice_Billing_Schedule__c (Id = subscription.Invoice_Billing_Schedule__c, 
                                                Total_Negotiated_Amt__c = 0)); 
        }

        //process if size greater than zero
        if(mapInvoiceBillingSchedule.Size() > 0) {
        
            //Loop through aggreagate query
            for(AggregateResult aResult : [SELECT SUM(Negotiated_Amount_Subscription__c) totalNegoAmount, Invoice_Billing_Schedule__c cInvoiceBill 
                                            FROM SBQQ__Subscription__c 
                                            WHERE Invoice_Billing_Schedule__c IN: mapInvoiceBillingSchedule.keyset()
                                            AND RecordType.DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM
                                            GROUP BY Invoice_Billing_Schedule__c]) {

                //Id of invoice billing schedule
                Id invoiceId = Id.valueOf(String.valueof(aResult.get('cInvoiceBill')));

                //Hold total negotiation amount
                Decimal totalNegAmount = (Decimal) aResult.get('totalNegoAmount');

                //Process if map contain key
                if(mapInvoiceBillingSchedule.ContainsKey(invoiceId))
                    mapInvoiceBillingSchedule.get(invoiceId).Total_Negotiated_Amt__c = totalNegAmount;

            }

            //Loop through aggreagate query
            for(AggregateResult aResult : [SELECT SUM(Negotiated_Amount__c) totalNegoAmount, Invoice_Billing_Schedule__c cInvoiceBill 
                                            FROM Contract__C 
                                            WHERE Invoice_Billing_Schedule__c IN: mapInvoiceBillingSchedule.keyset()
                                            GROUP BY Invoice_Billing_Schedule__c]) {

                //Id of invoice billing schedule
                Id invoiceId = Id.valueOf(String.valueof(aResult.get('cInvoiceBill')));

                //Hold total negotiation amount
                Decimal totalNegAmount = (Decimal) aResult.get('totalNegoAmount');

                //Process if map contain key
                if(mapInvoiceBillingSchedule.ContainsKey(invoiceId) && mapInvoiceBillingSchedule.get(invoiceId).Total_Negotiated_Amt__c != null)
                    mapInvoiceBillingSchedule.get(invoiceId).Total_Negotiated_Amt__c += totalNegAmount;

            }

            //Updates values
            if(mapInvoiceBillingSchedule.values().size() > 0) {
                Util.byPassAllTriggers = true;
                update mapInvoiceBillingSchedule.values();
                Util.byPassAllTriggers = false;
            }
        }
    }*/
    
    /**
    * 
    *   @description    :   This method used to update Subscription' child line item schedules with the invoice billing schedule
    *
    *   @args           :   List<SBQQ__Subscription__c>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created - 06/7/2017 - Deepak Kumar - Q2C Phase 2 - CR-20170403-10807
    * 
    **/
    public static void updateLISWithProgramSubscriptionIBS(List<SBQQ__Subscription__c> subscriptions) { 
        
        if (BYPASS_MULTIPLE_EXECUTION_OF_updateLISWithProgramSubscriptionIBS) return;
        
        //Variable to hold the clone of Line Item schedule
        List<Line_Item_Schedule__c>  lineItemScheduleClone = new List<Line_Item_Schedule__c>();
        
        //Variable to hold the master Line Item schedule
        List<Line_Item_Schedule__c>  lisToBeDeleted = new List<Line_Item_Schedule__c>();
        
        //Checking list for null and size value
        if(subscriptions != null && subscriptions.size() > 0) {
            
            //retrive all the LIS records related to Subscriptions
            //inner query to fetch all trhe LIS item related with Subscriptions
            //update the LIS's IBS id if it's different
            for(SBQQ__Subscription__c sbqqSub : [SELECT Id, Invoice_Billing_Schedule__c, 
                                           (SELECT Contract__c, Invoice_Billing_Schedule_del__c, Amount__c, 
                                            Invoice_Comment__c, Invoice_Date__c, Type__c from Line_Item_Schedules__r) 
                                           FROM SBQQ__Subscription__c WHERE Id IN : subscriptions 
                                           AND RecordType.DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM]) {
                                               
                //loop through the lis records
                if(sbqqSub.Line_Item_Schedules__r != null && sbqqSub.Line_Item_Schedules__r.size() > 0) {
                                                   
                    //create a temporary list to add te records to be deleted
                    List<Line_Item_Schedule__c>  tempListToBeDeleted = new List<Line_Item_Schedule__c>();
                                                   
                    //loop through the related Subscriptions and create a list to be deleted
                    for(Line_Item_Schedule__c lisRecord : sbqqSub.Line_Item_Schedules__r) {
                                                       
                        //check if contract's IBS is different then LIS IBS id then update the LIS record with the same id
                        if(sbqqSub.Invoice_Billing_Schedule__c != null 
                           && lisRecord.Invoice_Billing_Schedule_del__c != sbqqSub.Invoice_Billing_Schedule__c) {
                               tempListToBeDeleted.add(lisRecord);
                           }
                    }
                                                   
                    //Create a clone of teh contracts records
                    List<Line_Item_Schedule__c>  cloneList = tempListToBeDeleted.deepClone(false);
                    
                    //Loop through line item schedules
                    for(Line_Item_Schedule__c lisRecord : cloneList) {
                        
                        //check if contract's IBS is different then LIS IBS id then update the LIS record with the same id
                        if(sbqqSub.Invoice_Billing_Schedule__c != null && lisRecord.Invoice_Billing_Schedule_del__c != sbqqSub.Invoice_Billing_Schedule__c) {
                            lisRecord.Invoice_Billing_Schedule_del__c = sbqqSub.Invoice_Billing_Schedule__c;
                            lineItemScheduleClone.add(lisRecord);
                        }
                    }
                                                   
                    //add the master LIS in the list to be deleted
                    lisToBeDeleted.addAll(tempListToBeDeleted);
                }
            }
            
            //update the LIS records
            if(lineItemScheduleClone.size() > 0) {
                Util.byPassAllTriggers = true;
                insert lineItemScheduleClone;
                Util.byPassAllTriggers = false;
            }
                
            //delete the master Contract records
            if(lisToBeDeleted.size() > 0) 
                delete lisToBeDeleted;
        
      //Added By Mahendra Swarnkar - 03/05/2018 - CR-20180301-12089
          BYPASS_MULTIPLE_EXECUTION_OF_updateLISWithProgramSubscriptionIBS = true;
            //Added By Mahendra Swarnkar - 03/05/2018 - CR-20180301-12089 - Ends here
        }
    }
    
    /**
    * 
    *   @description    :   This method used to 
    *
    *   @args           :   List<SBQQ__Subscription__c>, 
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created - 06/7/2017 - Deepak Kumar - Q2C Phase 2 - CR-20170403-10807
    * 			    V1.2 - Modified By Mahendra - 11/25/2020 - CR-20201105-14668 
    * 
    **/
    public static void createMembershipWithCIA(List<SBQQ__Subscription__c> subscriptions) {  
    
        //Set to the hold Standard Contract
        Set<Id> setContractIds = new Set<Id>();
        
        //Modified By Mahendra - 11/25/2020 - CR-20201105-14668 - Starts from here
        for( SBQQ__Subscription__c sub : subscriptions) {
            
            if(sub.RecordTypeId == CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM && sub.SBQQ__Contract__c != null)
            	setContractIds.add(sub.Id);
        }
        
        /*
        //List to hold the Contract Integrated Account 
        List<Contract_Integrated_Accounts__c> listOfContractIntegratedAccount = new List<Contract_Integrated_Accounts__c>();
        
        //Loop the Subscriptions records 
        for(SBQQ__Subscription__c sbqq : [SELECT Id, SBQQ__Contract__c
                                         FROM SBQQ__Subscription__c WHERE Id IN : subscriptions 
                                         AND RecordType.DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM
                                         AND SBQQ__Contract__c != null]) {
                
                //Populate the contract set
                setContractIds.add(sbqq.SBQQ__Contract__c);
        }
        */
        //Check for the size 
        if(setContractIds.size() > 0) {
        	
            //List to hold the Contract Integrated Account 
            List<Contract_Integrated_Accounts__c> listOfContractIntegratedAccount = new List<Contract_Integrated_Accounts__c>();
        
            //Query through the Contract Integrated Account record
            for(Contract_Integrated_Accounts__c cIA : [Select Id, Account__c, LOA_Contract__c From Contract_Integrated_Accounts__c 
                                                        Where LOA_Contract__c != null AND LOA_Contract__c IN: setContractIds]) {
                //Populate the list
                listOfContractIntegratedAccount.add(cIA);
            }
            
            //Check for the size, call the ContractIntegratedAccountsTriggerHelper.createMemberships method
            if(listOfContractIntegratedAccount.size() > 0) 
                ContractIntegratedAccountsTriggerHelper.createMemberships(listOfContractIntegratedAccount);
        }
        
        //Check for the size, call the ContractIntegratedAccountsTriggerHelper.createMemberships method
        //if(listOfContractIntegratedAccount.size() > 0) 
        //    ContractIntegratedAccountsTriggerHelper.createMemberships(listOfContractIntegratedAccount);
        
        //Modified By Mahendra - 11/25/2020 - CR-20201105-14668 - Ends here
    }
    
    /**
     * 
     *  @description:       The method is used to calculate whether Subscription Status is active 
     *
     *  @args           :   String
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Saurabh Kumar - 06/07/2017 - CR-20170403-10807 (DS073.2)
     * 
     **/
    public static Boolean isActiveSubscriptionStatus(String subscriptionStatus){
        
        Boolean isActive = true;
        if (subscriptionStatus != null && (subscriptionStatus.toLowerCase() == CPQConstants.SBQQ_SUBSCRIPTION_STATUS_VOID || 
            subscriptionStatus.toLowerCase() == CPQConstants.SBQQ_SUBSCRIPTION_STATUS_CLOSED || 
            subscriptionStatus.toLowerCase() == CPQConstants.SBQQ_SUBSCRIPTION_STATUS_PENDING)) {
                isActive = false;
        }
        return isActive;
    }
    
    /**
     * 
     *  @description:       The method is used to update Renewal_Contract_Type__c field if Renewal Type is updated 
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Saurabh Kumar - 06/08/2017 - CR-20170403-10807 (DS073.2)
     *                      V_1.1 - Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
     * 
     **/
    public static void updateOpportunityFields(List<SBQQ__Subscription__c> newSubscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
        
        //Checking for the update use cases
        if(newSubscriptions != null && mapOldSubscriptions != null) {
            
            //Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
            //Get all record types of SBQQ__Subscription__c
            Map<String, Id> mapSubscriptionRecordTypes = new Map<String, Id>();
            mapSubscriptionRecordTypes = Constants.MAP_SUBSCRIPTION_RTYPE;
            String programRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM);
            
            //Set of opportunity IDs
            Set<Id> setOfContractsIDs = new Set<Id>();
            
            //Map to hold contract ID as key and most latest subscription record as value
            Map<Id, SBQQ__Subscription__c> mapContractIdWithLatestSubscription = new Map<Id, SBQQ__Subscription__c>();
            
            //Processing on the newn records
            for(SBQQ__Subscription__c subscription : newSubscriptions) {
                
                //Checking for record typw
                if(subscription.RecordTypeId != programRecordType)
                    continue;
                
                //Checking for update case and bypass blank update
                if(subscription.SBQQ__Contract__c != null 
                    && (mapOldSubscriptions == null || subscription.Renewal_Type__c != mapOldSubscriptions.get(subscription.Id).Renewal_Type__c)) {
                    setOfContractsIDs.add(subscription.SBQQ__Contract__c);
                    mapContractIdWithLatestSubscription.put(subscription.SBQQ__Contract__c, subscription);
                }
            }
            
            //Checking set for it's size
            if(setOfContractsIDs.size() > 0) {
                
                //Map of opportunities going to be update to keep the fields in sync
                Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>();
                
                //Loop through opportunity records and populating map accordingly
                for(Opportunity o : [SELECT ID, LOA_Contract__c, Renewal_Contract_Type__c
                                        FROM Opportunity
                                        WHERE LOA_Contract__c != null 
                                        AND LOA_Contract__c IN : setOfContractsIDs]) {
                                            
                    //Checking for field value differences                      
                    if(o.Renewal_Contract_Type__c != mapContractIdWithLatestSubscription.get(o.LOA_Contract__c).Renewal_Type__c) {
                        o.Renewal_Contract_Type__c = mapContractIdWithLatestSubscription.get(o.LOA_Contract__c).Renewal_Type__c;
                        mapOpportunities.put(o.Id, o);
                    }
                }
                
                //Checking for map size
                if(mapOpportunities.size() > 0){
                    
                    Util.byPassAllTriggers = true;
                    update mapOpportunities.values();
                    Util.byPassAllTriggers = false;
                }   
            }
        }
    }     
    
    /*V_3.3*/
     /**
     *  @description    :   This method is to check wheather LIS is associated with the subscription record, if yes then don't allow IBS id as null
     *
     *  @args           :   List<SBQQ__Subscription__c> newSubscription, Map<SBQQ__Subscription__c> oldSubscription
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Deepak Kumawat - 06/07/2017 - DS146
     *
     **/
     public static void validateIBSIdForProgramSubscription (List<SBQQ__Subscription__c> newRecords, Map<Id, SBQQ__Subscription__c> mapOldSubscription) {
        
        //Create a collection of the records to be processed
        Set<Id> setIBSSubscription = new Set<Id>();
        
        //loop through the sunscription records and create a collection of subscription having IBS as Null
        for(SBQQ__Subscription__c subscription : newRecords) {
            
            //check if IBS is null then add teh record in list
            if(subscription.Invoice_Billing_Schedule__c == null && (mapOldSubscription == null || mapOldSubscription.get(subscription.Id).Invoice_Billing_Schedule__c != subscription.Invoice_Billing_Schedule__c)) {
                setIBSSubscription.add(subscription.Id);
            }
        }
        
        //Checking list for size value
        if(setIBSSubscription.size() > 0) {
        
            //Query on Line item schedules to check subscription records has IS associated with them or not
            //if yes then throw the exception that IBS cannot be null for contracts having LIS associated with them.
            List<Line_Item_Schedule__c> lineItemSch = [Select Id From Line_Item_Schedule__c Where Program_Subscription__c IN: setIBSSubscription Limit 1];
                
            //check for the Line_Item_Schedule__c size
            if(lineItemSch.size() > 0 ) {
                throw new CustomException('You cannot remove the Invoice Billing Schedule link for subscription that have Line Item Schedules.'
                                            + 'To remove the Invoice Billing Schedule link you must first delete all child Line Item Schedules.');
            }
        }        
    }

    /**
     * 
     *  @description    :   This method is used to update the Renewal pricing fields on the Subscription Component records based
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c> 
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/04/2017 - Subhash Garhwal - CR-20170403-10807 (Work Order 103.4)
     *                      V_1.1 - Modified - 08/10/2017 - Colin McGloin - Issue--CR11094--QA--00005378 (Updated to pull previous Uplift from each Quote Line rather than blanket applying Quote uplift of 5%)
     *                      V_1.2 - Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
     **/    
    public static void populateRenewalFieldOnSubscription(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {

        //Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
        //Map to hold record type of subscription
        Map<String, Id> mapSubscriptionRecordTypes = new Map<String, Id>();
        mapSubscriptionRecordTypes = Constants.MAP_SUBSCRIPTION_RTYPE;

        //Get Record Type
        String componentRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT);

        //Set for holding our Quote Line IDs
        Set<Id> setQuoteLines = new Set<Id>();

        //Map for easily finding out with Quote maps with which Quote Line
        Map<String, Id> mapQLtoQuote = new Map<String, Id>();

        //Map for mapping the last Uplift value to the Quote Line
        Map<String, Decimal> quoteRenewalUprate = new Map<String, Decimal>();

        //Loop through the Subscription
        for(SBQQ__Subscription__c subscription : subscriptions) {

            //Process if condition is true
            if(subscription.SBQQ__QuoteLine__c != null && subscription.RecordTypeId == componentRecordType && subscription.Product_Category__c == CPQConstants.PRODUCT_CATEGORY_ANNUAL_FEE &&
                    (mapOldSubscriptions == null || subscription.SBQQ__QuoteLine__c != mapOldSubscriptions.get(subscription.Id).SBQQ__QuoteLine__c)) {
                setQuoteLines.add(subscription.SBQQ__QuoteLine__c);
            }   
        }

        //Check for Set size
        if(setQuoteLines.size() > 0) {

            //Set of Quote IDs
            Set<Id> setQuotes = new Set <Id>();

            //Query for our Quote Lines passed through from the Subscription
            List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, Name, SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE Id IN :setQuoteLines];

            //Loop through and get our Parent Quote which we'll pop into a Set for a follow up Query
            for (SBQQ__QuoteLine__c qL : quoteLines){
                setQuotes.add(qL.SBQQ__Quote__c);
            }

            if (setQuotes.size() >0){

                //Loop through all applicable Quote Line records from the Quote
                for (SBQQ__QuoteLine__c qL : [SELECT Id, Name, SBQQ__Uplift__c, Product_Category__c, SBQQ__Quote__c, SBQQ__SegmentIndex__c, SBQQ__Product__c, Related_Product__c 
                                              FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :setQuotes 
                                              AND Product_Category__c = :CPQConstants.QUOTE_LINE_PROGRAM_SUBSCRIPTIONCATEGORY_ANNUAL_FEE
                                              ORDER BY SBQQ__SegmentIndex__c DESC]){

                    //Create a unique Identifier for Quote Line by Product
                    String uniqueIdent = String.valueOf(qL.SBQQ__Product__c) + '-' + String.valueOf(qL.Related_Product__c);

                    //Populate our Map with the first Uplift value since it will be the value from the last Quote Line due to the query parameters
                    if (quoteRenewalUprate.get(uniqueIdent) == null){
                        quoteRenewalUprate.put(uniqueIdent, qL.SBQQ__Uplift__c);
                    }

                }

            }

        }

        //Check for size of map
        if(quoteRenewalUprate.size() > 0) {

            //Loop through Subscription
            for(SBQQ__Subscription__c subscription : subscriptions) {

                //Create our Identifier for grabbing the value from the Map
                String subUniqIdent = String.valueOf(subscription.SBQQ__Product__c) + '-' + String.valueOf(subscription.Related_Product__c);

                //Populate the Renewal Uplift Rate field with the correct value for that Quote Line/Quote
                if(quoteRenewalUprate.containsKey(subUniqIdent)){
                    subscription.SBQQ__RenewalUpliftRate__c = quoteRenewalUprate.get(subUniqIdent);
                }

                    //Check Subscription stage is pending   
                    //if(subscription.Status__c == CPQConstants.SBQQ_SUBSCRIPTION_STATUS_PENDING)                   
                        //subscription.SBQQ__RenewalPrice__c = subscription.Negotiated_Amount_Subscription__c;
                    
                }
            }
        }
    
    /**
     *  @description    :   Whenever a new Subscription is Inserted (after insert) or the Start/End date fields are changed (after update) 
     *                      and the related Program's Business Line = RI, perform an update on all Cases related to that Institution. 
     * 
     *  @args           :   List of new subscription records, Map of old subscription records
     * 
     *  @return         :   void
     * 
    **/
    public static void populateFieldsOnCaseFromSubscription(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
        /* Spring CleanUp
        //Set to hold the parent account IDs
        Set<Id> parentAccountIds = new Set<Id>();
        
        //Set to hold the Subscription IDs
        Set<Id> setSubscriptionIds = new Set<Id>();
        
        //Loop through contract records
        for(SBQQ__Subscription__c sub : subscriptions) {
            
            //populating setSubscriptionIds
            if(mapOldSubscriptions == null || (mapOldSubscriptions != null && sub.SBQQ__EndDate__c != mapOldSubscriptions.get(sub.Id).SBQQ__EndDate__c))
                setSubscriptionIds.add(sub.Id);
            
            //Checking for fields values
            if(sub.SBQQ__Account__c != null) {
                    
                //Checking for the event type (Insert and Update case)
                if(mapOldSubscriptions == null || (mapOldSubscriptions != null && subscriptions !=  null
                                                && 
                                                (sub.SBQQ__Account__c != mapOldSubscriptions.get(sub.Id).SBQQ__Account__c
                                                || 
                                                sub.Business_Line__c != mapOldSubscriptions.get(sub.Id).Business_Line__c
                                                ||
                                                sub.Type__c != mapOldSubscriptions.get(sub.Id).Type__c
                                                ||
                                                sub.SBQQ__StartDate__c != mapOldSubscriptions.get(sub.Id).SBQQ__StartDate__c
                                                ||
                                                sub.SBQQ__EndDate__c != mapOldSubscriptions.get(sub.Id).SBQQ__EndDate__c
                                                 ||
                                                sub.Program__c != mapOldSubscriptions.get(sub.Id).Program__c
                                                )
                                              ) 
                ) { 
                    parentAccountIds.add(sub.SBQQ__Account__c);     
                    
                    //Old Account record Id value (In case account got changed on subscription record)
                    if(mapOldSubscriptions != null && mapOldSubscriptions.get(sub.Id).SBQQ__Account__c != null)
                        parentAccountIds.add(mapOldSubscriptions.get(sub.Id).SBQQ__Account__c);
                }
            }
        }
        
        //List to hold the case records to be Updated 
        Map<Id, Case> mapCasesToBeUpdated = new Map<Id, Case>();
        
        //Check for Size
        if(setSubscriptionIds.size() > 0) {
            
            //Query through Case records 
            for(Case tdCase : [Select Id, Project_Year__c, Project_Source_MS__c, Project_Source_MS__r.Name, 
                               //Program_Subscription__c, 
                               Program_Subscription__r.SBQQ__EndDate__c
                                From Case 
                                WHERE RecordTypeId =: Util.RecordTypeId('Case', 'Talent Development') 
                                        AND Program_Subscription__c != null AND Program_Subscription__c IN : setSubscriptionIds]) {
                
                //Checking for the null value
                if(tdCase.Project_Source_MS__c != null) {
                    
                    if(tdCase.Program_Subscription__c != null && tdCase.Program_Subscription__r.SBQQ__EndDate__c != null )
                        tdCase.Project_Year__c =  tdCase.Project_Source_MS__r.Name + ' - ' + tdCase.Program_Subscription__r.SBQQ__EndDate__c.year();
                    else
                        tdCase.Project_Year__c =  tdCase.Project_Source_MS__r.Name + ' - null';
                }
                else{
                    
                    if(tdCase.Program_Subscription__c != null && tdCase.Program_Subscription__r.SBQQ__EndDate__c != null )
                        tdCase.Project_Year__c =  'null - ' + tdCase.Program_Subscription__r.SBQQ__EndDate__c.year();
                    else
                        tdCase.Project_Year__c =  'null - null';
                }
                
                //Populating map with field values
                mapCasesToBeUpdated.put(tdCase.Id, tdCase);
            }   
        }
        
        //Map to hold  account Id as a key and list of related subscriptions as values
        Map<Id, List<SBQQ__Subscription__c>> mapAccountWithSubscriptions = new Map<Id, list<SBQQ__Subscription__c>>();
        
        //Checking set for size value
        if(parentAccountIds.size() > 0) {
        
            //Loop through contract records
            for(SBQQ__Subscription__c sub : [SELECT ID, Program_Acronym__c, SBQQ__Account__c, SBQQ__StartDate__c, 
                                                    SBQQ__EndDate__c, Business_Line__c
                                                    FROM SBQQ__Subscription__c
                                                    WHERE SBQQ__Account__c != null 
                                                    AND SBQQ__Account__c IN : parentAccountIds
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
        }
        
        //Get all record types on case object
        Map<String, Id> caseRecordTypesMap = Util.recordtypemap(Constants.CASE_OBJECT);
        
        //Set to hold the eligible record type IDs
        Set<Id> eligibleCaseRecordTypes = new Set<Id>();
        
        //Map to hold the case record type Id as key and correspodning record type label as value
        Map<Id, String>  mapRecordTypes = new Map<Id, String>();
        
        //Looping over map keyset and accordingly populating collection with map retrieved values
        for(String recordTypeLabel : caseRecordTypesMap.keySet()) {
            if(recordTypeLabel != null 
               && (
                    recordTypeLabel.equalsIgnoreCase(System.Label.CASE_NEW_MEMBER_RECORD_TYPE)
                    || recordTypeLabel.equalsIgnoreCase('Talent Development')
                  )
               && caseRecordTypesMap.get(recordTypeLabel) != null   
              )
                eligibleCaseRecordTypes.add(caseRecordTypesMap.get(recordTypeLabel));
                
            //Populating map to hold the case record type Id as key and correspodning record type label as value
            if(String.isNotBlank(recordTypeLabel) 
               && caseRecordTypesMap.containsKey(recordTypeLabel)
               && caseRecordTypesMap.get(recordTypeLabel) != null)
                mapRecordTypes.put(caseRecordTypesMap.get(recordTypeLabel), recordTypeLabel);       
        }
        
        //Checking if eligible case record type exists or not
        if(eligibleCaseRecordTypes != null && eligibleCaseRecordTypes.size() > 0 
           && parentAccountIds != null && parentAccountIds.size() > 0) {
                
            //Map of cases
            Map<Id, Case> mapOfCases = new Map<Id, Case>([SELECT ID, AccountID, New_Member_Programs_RI__c, New_Member_Programs_TD__c, 
                                                            CreatedDate, RecordTypeId  
                                                            FROM Case 
                                                              WHERE AccountId != null
                                                              AND AccountId IN : parentAccountIds
                                                              AND RecordTypeId IN: eligibleCaseRecordTypes]);  
                                                                
            //Checking if eligible cases are associated with the contract records
            if(mapOfCases != null && mapOfCases.keySet().size() > 0) {
                
                //Loop over case records
                for(Case c : mapOfCases.values()) {
                        
                    //Temporary variable to hold the contracts program acronyms Concatenated string literal value
                    String programAcromyms = '';
                    String programAcromymsForTD = '';   
                
                    //Checking for eligible subscription records presence and then accordingly concatenating "Program Acronyms" string literal
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
                        
                        //Removing additional "," from the end of concatenated string literal (if exists)
                        if(programAcromymsForTD != '') {
                               
                            //Trim the white spaces
                            programAcromymsForTD = programAcromymsForTD.trim();
                               
                            //Checking if last character of string literal is "Comma" or not
                            if(programAcromymsForTD.substring((programAcromymsForTD.length()-1), programAcromymsForTD.length()) == Constants.COMMA)
                                programAcromymsForTD = programAcromymsForTD.removeEnd(Constants.COMMA);
                        }
                        
                    } else {
                        programAcromyms = '';
                        programAcromymsForTD = '';
                    }
                    
                    //First checking for the difference in between new and old value and accordingly Setting field value on the case records
                    if(c.New_Member_Programs_RI__c != programAcromyms) {
                        c.New_Member_Programs_RI__c = programAcromyms;
                        
                        //Checking for key existance in map
                        if(mapCasesToBeUpdated.containsKey(c.Id))
                            mapCasesToBeUpdated.get(c.Id).New_Member_Programs_RI__c = c.New_Member_Programs_RI__c;
                        else
                            mapCasesToBeUpdated.put(c.Id, c);  
                    }
                    
                    //First checking for the difference in between new and old value and accordingly Setting field value on the case records
                    if(c.New_Member_Programs_TD__c != programAcromymsForTD ) {
                        c.New_Member_Programs_TD__c = programAcromymsForTD ;  
                        
                        //Checking for key existance in map
                        if(mapCasesToBeUpdated.containsKey(c.Id))
                            mapCasesToBeUpdated.get(c.Id).New_Member_Programs_TD__c = c.New_Member_Programs_TD__c;
                        else
                            mapCasesToBeUpdated.put(c.Id, c);
                    }                           
                }
            }                                   
        }
        
        //Checking for size value
        if(mapCasesToBeUpdated.values().size() > 0) {
            Util.byPassAlltriggers = true;
            update mapCasesToBeUpdated.values();
            Util.byPassAlltriggers = false;
        }
    */
    }
    
    /**
     * 
     *  @description    :   This method is used to update the Renewal pricing fields on the Subscription Component records based
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c> 
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created  - 06/09/2017 - Subhash Garhwal - CR-20170403-10807 (Work Order 103.4)
     *                      V_1.2 - Modified - 10/11/2018 - Subhash Garhawal - CR-20180720-12456
     *                      V_1.3 - Modified - 01/10/2019 - Victor Hanson - CR-20181019-12685 - Fixed compSub query.  Originally it never returned any records.  Replaced ID with Program_Subscription__c in where clause
     *                      V_1.4 - Modified - 08/29/2019 - Victor Hanson - CR-20190829-13297 - commented out renewalPrice calculation that subtracted renewal uplift
     * 
     **/    
    public static void populateRenewalPriceFieldOnCompSubscription(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
        
        //Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
        //Map to hold record type of subscription
        Map<String, Id> mapSubscriptionRecordTypes = new Map<String, Id>();
        mapSubscriptionRecordTypes = Constants.MAP_SUBSCRIPTION_RTYPE;
        //Get Record Type
        String componentRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT);
        
        //Set to hold id of product
        Set<Id> setProductIds = new Set<Id>();
        Set<Id> setContractIds = new Set<Id>();
        
        //Set to hold the Program Subscriptions Ids
        Set<Id> setProSubIds = new Set<Id>();
        
        //Loop through the Subscription
        for(SBQQ__Subscription__c subscription : subscriptions) {
            //Process if condition is true
            if(subscription.Program_Subscription__c != null && subscription.SBQQ__Product__c != null && subscription.SBQQ__Contract__c != null && subscription.RecordTypeId == componentRecordType &&
               (mapOldSubscriptions == null || subscription.SBQQ__Product__c != mapOldSubscriptions.get(subscription.Id).SBQQ__Product__c 
                || subscription.SBQQ__Contract__c != mapOldSubscriptions.get(subscription.Id).SBQQ__Contract__c
               || subscription.SBQQ__RenewalPrice__c != null)) {
                    
                    //Add Product and Contract
                    setProductIds.add(subscription.SBQQ__Product__c);       
                    setContractIds.add(subscription.SBQQ__Contract__c);
                    
                    //Add Program Subscription
                    setProSubIds.add(subscription.Program_Subscription__c);
                }   
        }
        
        //Check for Set size
        if(setProductIds.Size() > 0 && setContractIds.Size()>0) {
            
            //comp subs that are not part of the trigger.new list
            List<SBQQ__Subscription__c> allCompSubs = new List<SBQQ__Subscription__c>();
            
            //map of UK -> List<CompSub>
            Map<String, List<SBQQ__Subscription__c>> ukToListCompSub = new Map<String, List<SBQQ__Subscription__c>>();
            Map<String, Map<String, List<SBQQ__Subscription__c>>> ukToMaxIndexMapCompSub = new Map<String, Map<String, List<SBQQ__Subscription__c>>>();
            
            //Map to hold the Subscription Component with max index component subcription where renewalprice is summary of all products for the final period of the same type
            Map<String, SBQQ__Subscription__c> mapUKToMaxRenewalSub = new Map<String, SBQQ__Subscription__c>();
            
            for(SBQQ__Subscription__c compSub : [SELECT Id, SBQQ__SegmentIndex__c, Program_Subscription__c, SBQQ__CustomerPrice__c, SBQQ__Product__c, 
                                                 SBQQ__Contract__c, SBQQ__RenewalUpliftRate__c, RecordTypeId,SBQQ__Product__r.Name, 
                                                 SBQQ__RequiredByProduct__c, SBQQ__RequiredByProduct__r.Family
                                                 FROM SBQQ__Subscription__c
                                                 WHERE Program_Subscription__c IN : setProSubIds 
                                                 AND SBQQ__SegmentIndex__c != null 
                                                 ORDER BY SBQQ__SegmentIndex__c DESC]) 
            {
                String ukMax = compSub.SBQQ__SegmentIndex__c + '-' + compSub.Program_Subscription__c + '-' + compSub.SBQQ__Product__c;
                String uk = compSub.Program_Subscription__c + '-' + compSub.SBQQ__Product__c;
                
                //map max component subscriptions
                List<SBQQ__Subscription__c> tempMaxSubList = new List<SBQQ__Subscription__c>();
                Map<String, List<SBQQ__Subscription__c>> tempMaxSubMap = ukToMaxIndexMapCompSub.get(uk);
                if (tempMaxSubMap == null) {
                    tempMaxSubMap = new Map<String, List<SBQQ__Subscription__c>>();
                    tempMaxSubMap.put(ukMax, tempMaxSubList);
                    ukToMaxIndexMapCompSub.put(uk, tempMaxSubMap);
                }
                
                if (tempMaxSubMap.containsKey(ukMax)) {
                    tempMaxSubList = tempMaxSubMap.get(ukMax);
                    //add compSub to our list
                    tempMaxSubList.add(compSub);
                    
                    //calculate the renewal amount max index for this product
                    Decimal renewalAmtMax = 0;
                    for (SBQQ__Subscription__c maxCompSub : tempMaxSubList) {
                        if (maxCompSub.SBQQ__CustomerPrice__c != null)
                            renewalAmtMax += maxCompSub.SBQQ__CustomerPrice__c;
                    }
                    
                    
                    //set renewal price on all related products
                    for (SBQQ__Subscription__c maxCompSub : tempMaxSubList) {
                        maxCompSub.SBQQ__RenewalPrice__c = renewalAmtMax;
                        mapUKToMaxRenewalSub.put(uk, maxCompSub);
                    }
                    //add to map
                    tempMaxSubMap.put(ukMax, tempMaxSubList);
                    ukToMaxIndexMapCompSub.put(uk, tempMaxSubMap);
                }
                
                //map of all component subscriptions
                List<SBQQ__Subscription__c> tempSubList = ukToListCompSub.get(uk);
                if (tempSubList == null) {
                    tempSubList = new List<SBQQ__Subscription__c>();
                }
                
                tempSubList.add(compSub);
                ukToListCompSub.put(uk, tempSubList);
                
            }
            
            
            
            //Hold product data
            Map<Id,Product2> mapProduct = new Map<Id,Product2>([Select Id, Product_Category__c From Product2 Where Product_Category__c =: CPQConstants.QUOTE_LINE_PROGRAM_SUBSCRIPTIONCATEGORY_ANNUAL_FEE
                                                                AND Id IN : setProductIds]);
            
            //Check for size of MAp
            if(mapProduct.Size() >0 ) {
                
                //List to update the Comp. Subscriptions
                List<SBQQ__Subscription__c> compSubscriptions = new List<SBQQ__Subscription__c>();
                
                //Loop through Subscription
                for(List<SBQQ__Subscription__c> subList : ukToListCompSub.values()) {
                    for (SBQQ__Subscription__c compSub : subList) {
                        
                        //Process if condition is true
                        if(compSub.Program_Subscription__c != null && compSub.SBQQ__Product__c != null && compSub.SBQQ__Contract__c != null 
                           && compSub.RecordTypeId == componentRecordType)
                        {
                            String uk = compSub.Program_Subscription__c + '-' + compSub.SBQQ__Product__c;
                            //Check for max comp. Subscription amount
                            if(mapUKToMaxRenewalSub.containsKey(uk)) {
                                SBQQ__Subscription__c subscription = mapUKToMaxRenewalSub.get(uk);
                                Decimal renewalPrice;
                                renewalPrice = subscription.SBQQ__RenewalPrice__c;
                                
                                //VH 4/2/2019 - fixing a bug where some renewal prices are set to zero which is causing issues on renewals
                                if(subscription.SBQQ__RenewalPrice__c == 0) continue;
                                
                                //VH 08/29/2019 - CR-20190829-13297 - commented out renewalPrice change below
                                //Check for Uplift
                                /*if(subscription.SBQQ__RenewalUpliftRate__c != null)
                                    renewalPrice -= (renewalPrice*subscription.SBQQ__RenewalUpliftRate__c)/100;*/
                                
                                //Add Renewal Price
                                compSubscriptions.add(new SBQQ__Subscription__c(Id = compSub.Id, SBQQ__RenewalPrice__c = renewalPrice));
                            }
                        }
                    }
                }
                
                
                //Check for size
                if(compSubscriptions.size() > 0) {
                    
                    //Bypassing triggers
                    Util.byPassAllTriggers = true;
                    
                    //Update cases
                    update compSubscriptions;
                    
                    //Enabling triggers
                    Util.byPassAllTriggers = false; 
                }
            }
        }
    }
    
    /**
     * 
     *  @description    :   This method is used to update the Invoice contact fields on the Subscription program records based
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c> 
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/09/2017 - Deepak kumar - CR-20170403-10807 (Work Order 146.1)
     *                      V_1.1 - Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
     * 
     **/    
     public static void populateInvoiceContactFieldsOnSubscription(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
             
        //Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
        //Map to hold record type of subscription
        Map<String, Id> mapSubscriptionRecordTypes = new Map<String, Id>();
        mapSubscriptionRecordTypes = Constants.MAP_SUBSCRIPTION_RTYPE;
        //Get Record Type
        String programRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM);
    
        //Set to hold id of Contact
        Set<Id> setContactIds = new Set<Id>();
        
        //Loop through the Subscription
        for(SBQQ__Subscription__c subscription : subscriptions) {
    
            //Process if condition is true
            if(subscription.Invoice_Contact__c != null && subscription.RecordTypeId == programRecordType &&
                    (mapOldSubscriptions == null || subscription.Invoice_Contact__c != mapOldSubscriptions.get(subscription.Id).Invoice_Contact__c)) {
                
                //Populate the setContactIds
                setContactIds.add(subscription.Invoice_Contact__c);       
            }   
        }
    
        //Check for Set size
        if(setContactIds.Size() > 0 ) { 
    
            //Hold Contact data
            Map<Id,Contact> mapContact = new Map<Id,Contact>([Select Id, Email, Title From Contact Where Id IN: setContactIds]);
    
            //Check for size of MAp
            if(mapContact.Size() >0 ) {
    
                
                //Loop through Subscription
                for(SBQQ__Subscription__c subscription : subscriptions) {
    
                    //Process if Contact and Proposal comntain in map
                    if(mapContact.containsKey(subscription.Invoice_Contact__c)) {
                        
                        //Populate the subscription contact's Email and title fields  
                        subscription.Invoice_Contact_Email__c = mapContact.get(subscription.Invoice_Contact__c).Email;
                        subscription.Invoice_Contact_Title__c = mapContact.get(subscription.Invoice_Contact__c).Title;
                        
                    }
                }
            }
        }
    }
    
    /**
     * 
     *  @description    :   This method is used to create/update dummy Contract ABC on the Program Subscription when Invoice Billing Schedule
     *                      is changed on Program Subscription.
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c> 
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/09/2017 - Subhash Garhwal - CR-20170403-10807 (Work Order 146.2)
     * 			:   V_1.1 - Modified By - Dipesh Gupta - CR-20191029-13473 - 14/11/2019
     * 
     **/
    public static void validateContractABC(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
        
        //Set to hold the subscription ids
        Set<Id> setSubIds = new Set<Id>();
        
        //Set to hold the dummy contract abc Ids to delete the record
        Set<Id> setDummyContractABCIds = new Set<Id>();
        
        //Loop over the Subscription
        for(SBQQ__Subscription__c sub : subscriptions != null ? subscriptions : mapOldSubscriptions.values()) {
            
            //Check appropriate condition to execute logic
            
            //Insert/Update case
            if(sub.Invoice_Billing_Schedule__c != null && (mapOldSubscriptions == null || sub.Invoice_Billing_Schedule__c != mapOldSubscriptions.get(sub.Id).Invoice_Billing_Schedule__c
                || sub.Invoice_Contact__c != mapOldSubscriptions.get(sub.Id).Invoice_Contact__c))
                setSubIds.add(sub.Id);
            
            //Check for update case
            if(subscriptions == null && sub.Invoice_Billing_Schedule__c != null)
                setDummyContractABCIds.add(sub.Shadow_Contract_ABC__c);
        }
        
        //Check for subscription
        if(setSubIds.size() > 0) {
            
            //Map to hold the Contrat ABC with Related Program Subscription
            Map<Id, Contract__c> mapContractABCWithProSubId = new Map<Id, Contract__c>();
            
            //Map to hold the Subscription details
            Map<Id, SBQQ__Subscription__c> mapProgramSubscriptions = new Map<Id, SBQQ__Subscription__c>([Select Id, Invoice_Billing_Schedule__c, SBQQ__Contract__c, SBQQ__Contract__r.SBQQ__RenewalOpportunity__c, Invoice_Contact__c, SBQQ__StartDate__c, SBQQ__EndDate__c, 
                                                                                                                Invoice_Billing_Schedule__r.Institution__c, Program__c, Source_Opportunity__c, Invoicing_Arrangement__c,
                                                                                                                Start_Year__c, Type__c, Status__c,Term_Type__c, Years_in_Term__c, CurrencyIsoCode, Shadow_Contract_ABC__c,
                                                                                                             Negotiated_Amount_Subscription__c, Join_Date__c
                                                                                                         From SBQQ__Subscription__c 
                                                                                                         Where Id IN : setSubIds 
                                                                                                           AND RecordType.DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM]);
            
            //Map to upsert dummy Contract BC records
            Map<Id, Contract__c> mapDummyContractABCWithProgramSub = new Map<Id, Contract__c>();
            
            //Loop over the Program Subscriptions
            for(SBQQ__Subscription__c sub : mapProgramSubscriptions.values()) {
                
                //Instane of Contract ABC
                Contract__c contractABC = new Contract__c();
                
                //Check for Dummy Contract ABC
                if(sub.Shadow_Contract_ABC__c != null)
                    contractABC.Id = sub.Shadow_Contract_ABC__c;
                else
                  contractABC.Payer_Account__c = sub.Invoice_Billing_Schedule__r.Institution__c;
                
                //Update field vlaues
                contractABC.Invoice_Billing_Schedule__c = sub.Invoice_Billing_Schedule__c;
                //Modified By -Subhash Garhwal - CR-20180126-11910 - 02/01/2018 - added logic to add master program subscription
                contractABC.Contract_Renewal_Opportunity__c = sub.SBQQ__Contract__c != null ? sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c : null;
                contractABC.Master_Program_Subscription__c = sub.Id;
                contractABC.Invoice_Contact__c = sub.Invoice_Contact__c;
                // Modified By - Dipesh Gupta - CR-20191029-13473 - 14/11/2019 
                if(contractABC.Main_Contact__c == null)
                    contractABC.Main_Contact__c = sub.Invoice_Contact__c;
                
                contractABC.Start__c = sub.SBQQ__StartDate__c;
                contractABC.End__c = sub.SBQQ__EndDate__c;
                contractABC.Program__c = sub.Program__c;
                contractABC.Source_Opportunity__c = sub.Source_Opportunity__c;
                contractABC.Invoicing_Arrangement__c = sub.Invoicing_Arrangement__c;
                contractABC.Year__c = sub.Start_Year__c != null ? String.valueOf(sub.Start_Year__c) : contractABC.Year__c;
                contractABC.Type__c = sub.Type__c;
                contractABC.Term_Type__c = sub.Term_Type__c;
                contractABC.Years_in_Term__c = sub.Years_in_Term__c;
                //Modified by Abhinav sharma - 5/31/2018 - CR-20180501-12196
                //contractABC.Contract_Currency__c = sub.CurrencyIsoCode;
                if(sub.CurrencyIsoCode == 'USD')
                    contractABC.Contract_Currency__c = 'USD - US Dollar';
                else
                    contractABC.Contract_Currency__c = sub.CurrencyIsoCode;
                
                contractABC.Record_Source__c = CPQConstants.RECORD_SOURCE_PLACEHOLDER; //VH Added 7/14/17: Issue--CR10808--QA--00004966
                contractABC.Negotiated_Amount__c = sub.Negotiated_Amount_Subscription__c;
                contractABC.Join_Date__c = sub.Join_Date__c;
                
                //Add Program Subscriptions 
                mapDummyContractABCWithProgramSub.put(sub.Id, contractABC);
            }
            
            //Check for size
            if(mapDummyContractABCWithProgramSub != null && mapDummyContractABCWithProgramSub.size() > 0) { 

                //Added by Colin McGloin - 07/27/2017 - Static Value to allow us to bypass unnecessary Membership Trigger logic since it's a Shadow Contract ABC
                Util.isShadowContractABC = true; 
                
                //Upsert
                upsert mapDummyContractABCWithProgramSub.values();
                
                //List to update the Program Subscription
                List<SBQQ__Subscription__c> programSubscriptionsToUpdate = new List<SBQQ__Subscription__c>();
                
                //Loop over the Program Subscriptions
                for(Id pSId : mapDummyContractABCWithProgramSub.keySet()) {
                    
                    //Add record in list
                    programSubscriptionsToUpdate.add(new SBQQ__Subscription__c(Id = pSId, Shadow_Contract_ABC__c = mapDummyContractABCWithProgramSub.get(pSId).Id));
                }
                
                //Check for size
                if(programSubscriptionsToUpdate.size() > 0) {
                    
                    //Bypassing triggers
                    Util.byPassAllTriggers = true;
                    
                    //Update cases
                    update programSubscriptionsToUpdate;
                    
                    //Enabling triggers
                    Util.byPassAllTriggers = false;
                }
            }
        }
    }
    
    /**
     * 
     *  @description    :   This method is used to update Opt out details on the Program Subscription from related Opt Out Component Subs.
     *            	    Opt Out Subscription: Product.ProductOption.Feature.Category = Opt Out.
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c> 
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 07/10/2017 - Subhash Garhwal - Issue--CR10808--QA--00004850
     * 
     **/
    /*public static void populateOptOutDetails(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
      
      //Set to hold the Program Subscription Id
      Set<Id> setProgramSubsIds = new Set<Id>();
      
      //Loop over the new Subscriptions
      for(SBQQ__Subscription__c sub : subscriptions) {
        
        //Check for appropriate condition to execute the trigger logic
        if(sub.Program_Subscription__c != null && (mapOldSubscriptions == null || sub.Program_Subscription__c != mapOldSubscriptions.get(sub.Id).Program_Subscription__c)) {
          
          //Get Program Subscription Id
          setProgramSubsIds.add(sub.Program_Subscription__c);
        }
      }
      
      //Check for set size
      if(setProgramSubsIds.size() > 0) {
        
        //Map to update the Program Subscription records
        Map<Id, SBQQ__Subscription__c> mapProgramSubscriptions = new Map<Id, SBQQ__Subscription__c>();
        
        //SOQL over the Opt Out Subscriptions
        for(SBQQ__Subscription__c optOutSub : [Select Id, Program_Subscription__c, Opt_Out__c, Board_Notification_Date__c, Days_Notice__c, Penalty_Fee_Amount__c,
                                Early_Termination_Date__c, Opt_Out_of_SLSA__c From SBQQ__Subscription__c Where Program_Subscription__c IN : setProgramSubsIds
                                AND SBQQ__QuoteLine__r.SBQQ__ProductOption__r.SBQQ__Feature__r.SBQQ__Category__c = 'Opt Out']) {
                                  
          //Check Program Subscription Id in map
          if(!mapProgramSubscriptions.containsKey(optOutSub.Program_Subscription__c)) {
            
            //Instance of Program Subscription
            SBQQ__Subscription__c proSub = new SBQQ__Subscription__c(Id = optOutSub.Program_Subscription__c);
            
            //Add field values
            proSub.Opt_Out__c = optOutSub.Opt_Out__c;
            proSub.Board_Notification_Date__c = optOutSub.Board_Notification_Date__c;
            proSub.Days_Notice__c = optOutSub.Days_Notice__c;
            proSub.Penalty_Fee_Amount__c = optOutSub.Penalty_Fee_Amount__c;
            proSub.Early_Termination_Date__c = optOutSub.Early_Termination_Date__c;
            proSub.Opt_Out_of_SLSA__c = optOutSub.Opt_Out_of_SLSA__c;
            
            //Add Program Subscription in map
            mapProgramSubscriptions.put(optOutSub.Program_Subscription__c, proSub);  
          }
        }
        
        //Check map size
        if(mapProgramSubscriptions.size() > 0) {
          
          //Bypassing triggers
                Util.byPassAllTriggers = true;
                
                //Update cases
                //update mapProgramSubscriptions.values();
                
                //Enabling triggers
                Util.byPassAllTriggers = false;
        }
      }  
    } */
    
    /**
     * 
     *  @description    :   The method is used to sync Previous_Period_Negotiated__c amount on related subscription period record.
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c> 
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 07/21/2017 - Subhash Garhwal - Issue--CR10808--QA--00004854
     * 
     **/
    public static void syncPreviousPeriodNegotiatedOnSubPeriod(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions){
        
        //Set to hold Subscription Id
        Set<Id> setSubscriptionIds = new Set<Id>();
        
        //Processing on new records
        for(SBQQ__Subscription__c subscription : subscriptions){
          
            //Checking for update case only and bypass blank update
            if(subscription.Previous_Contract_ABC__c != null && (mapOldSubscriptions == null || subscription.Previous_Contract_ABC__c != mapOldSubscriptions.get(subscription.Id).Previous_Contract_ABC__c))
                setSubscriptionIds.add(subscription.Id);
        }
        
        //Checking for set size
        if(setSubscriptionIds != null && setSubscriptionIds.size() > 0){
            
            //Query on the Subscription Period record
            List<Subscription_Period__c> subscriptionPeriods = [Select Id, Name, Previous_Subscription_Period__c, Program_Subscription__c,
                                                               Negotiated_Amount_Period__c, Previous_Period_Negotiated__c From Subscription_Period__c
                                                               Where Program_Subscription__c IN : setSubscriptionIds];
            
            //Checking for list size and calling the method to sync Previous_Period_Negotiated__c on the Subscription Period
            if(subscriptionPeriods != null && subscriptionPeriods.size() > 0)
                SubscriptionPeriodTriggerHelper.populatePreviousPeriodNegotiated(subscriptionPeriods, null);
        }
        
    }

    /**
     * 
     *  @description    :   The method is used to sync Program Subscription records with the Shadow Contract ABC. This process is used to sync
     *                      values between Case and Member Support records currently (CaseTriggerHelper) so this process recreates and uses some
     *                      of that existing functionality.
     *
     *  @revision Log   :   V_1.0 - Created - 07/21/2017 - Colin McGloin - Issue--CR10808--QA--00005046
     * 
     **/

    private static object convertSourceFieldValue(string sourceObjType, string targetObjType, string sourceFieldAPIName, sobject sourceObj) {

        string sourceRecordTypeId = (string) sourceObj.get('RecordTypeId');
        
        string sourceFieldValue;
        object sourceFieldValue_object;
        
        try {
            //If this is an instance of a string, convert it and continue processing
            if (sourceObj.get(sourceFieldAPIName) instanceOf string)
                sourceFieldValue = (string) sourceObj.get(sourceFieldAPIName);
            else { //If it is not a string, leave it as an object and return if not auto-populated via the custom process below
                sourceFieldValue_object = sourceObj.get(sourceFieldAPIName);
            }
        }
        catch(exception ex) {
            system.debug('Error Converting value to string:' + ex + '  sourceFieldAPIName:' + sourceFieldAPIName + '---VALUE:' + sourceObj.get(sourceFieldAPIName));
        }
        
        if (sourceFieldValue != null) 
            sourceFieldValue_object = (object) sourceFieldValue;
        return sourceFieldValue_object;

    }

    /**
     * 
     *  @description    :   Populate the targetRecord with the corresponding sourceRecord's field values and return the targetObject.
     *                      This is used in conjunction with the Sync Field Custom Setting.
     *
     *  @revision Log   :   V_1.0 - Created - 07/21/2017 - Colin McGloin - Issue--CR10808--QA--00005046
     * 
     **/

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

    /**
     * 
     *  @description    :   Check the fields that sync from Program Subscription -> Contract ABC and determine if the related Contract ABC record should be updated.
     *
     *  @revision Log   :   V_1.0 - Created - 07/21/2017 - Colin McGloin - Issue--CR10808--QA--00005046
     * 
     **/

    public static boolean recordNeedsSynced(sObject newSourceObj, sObject oldSourceObj) {
        
        boolean isChanged = false;
        
        //Get the list of sync fields
        list<Sync_Field__c> syncFieldList = Constants.SYNC_FIELDS_LIST;
        
        //Get the source sObject types
        string sourceObjAPIName = newSourceObj.getSObjectType().getDescribe().getName();
        
        //Get the Source's record type developer name
        string sourceObjRTDevName;
        try {
            sourceObjRTDevName = Schema.getGlobalDescribe().get(sourceObjAPIName).getDescribe().getRecordTypeInfosById().get((string)newSourceObj.get('RecordTypeId')).getDeveloperName();
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
  
    public static map<Id, Contract__c> contractABCMap {
        get {
            if (contractABCMap == null) {
                contractABCMap = new map<Id, Contract__c>();
            }
            return contractABCMap;
        }
        set;
    }
      
    
    /**
     * 
     *  @description    :   Sync a Contract ABC record with it's Master Program Subscription.
     *
     *  @revision Log   :   V_1.0 - Created - 07/21/2017 - Colin McGloin - Issue--CR10808--QA--00005046
     * 
     **/

    public static void syncProgSubToShadowContractABC(list<SBQQ__Subscription__c> newSubs, map<Id, SBQQ__Subscription__c> mapOldSubs) {
        
        //List for update process at end of method
        Map<Id, Contract__c> contractABCToUpdate = new Map<Id, Contract__c>();
        //Set for Contract ABC query
        set<Id> contractABCIdSet = new set<Id>();
        //Set for Subscription Related Field queries
        Set<Id> subscriptionIds = new Set <Id>();
        //Variable for checking if we can proceed with Sync
        Boolean checkSync = false;
        
        //Get a map of related Contract ABC records
        for (SBQQ__Subscription__c nS : newSubs) {
                if (nS.Shadow_Contract_ABC__c != null){
                    contractABCIdSet.add(nS.Shadow_Contract_ABC__c);
                    subscriptionIds.add(nS.Id);
                }
        }

        
    
        //only query contract ABC if it doesn't exist in the map already
        boolean queryContractABCs = false;
        for (Id i : contractABCIdSet) {
            if (!contractABCMap.containsKey(i)) {
                queryContractABCs = true;
                break;
            }
        }
            
        //SOQL Queries for checks later
        if (queryContractABCs) {
            contractABCMap = new map<Id, Contract__c>([SELECT Id, Exchange_Rate__c, Payer_Account__c,  Main_Contact_Name__c
                                                       FROM Contract__c
                                                       WHERE Id IN :contractABCIdSet]);
        }

        

        /*map<Id, SBQQ__Subscription> subMap = new map<Id, SBQQ__Subscription>([SELECT Id, SBQQ__Contract__c, SBQQ__Contract__r.Account, Invoice_Contact__r.Name
                                                                              FROM SBQQ__Subscription
                                                                              WHERE Id IN :subscriptionIds]);*/
        
            //Iterate over each Subscription to determine if a Contract ABC record sync is necessary
            for (SBQQ__Subscription__c nS : newSubs) {
                
                //Get the old Subscription
                SBQQ__Subscription__c oldSub;
                if (mapOldSubs != null) oldSub = mapOldSubs.get(nS.Id);
                
                Contract__c contractABC;
                
                //If this is an update and the  record exists in our map, get the existing member support record
                if (nS.Shadow_Contract_ABC__c != null && contractABCMap.containsKey(nS.Shadow_Contract_ABC__c)) {
                    contractABC = contractABCMap.get(nS.Shadow_Contract_ABC__c);

                    //This field should always have a default value of 1
                    if (contractABC.Exchange_Rate__c != 1){
                        contractABC.Exchange_Rate__c = 1;
                        //Add the updated Contract ABC record to the update list
                        contractABCToUpdate.put(contractABC.Id, contractABC);
                    }
                    //Set our boolean to allow for Sync check to happen
                    checkSync = true;
                }
                
                if (checkSync){
                    //If certain Subscription fields were modified - mirror changes to related Shadow Contract ABC record
                    if (recordNeedsSynced((sObject) nS, (sObject) oldSub)){
                    
                    //Populate Subscription field values to the Shadow Contract ABC record
                    contractABC = (Contract__c) populateSourceFieldsToTarget((sObject) oldSub, (sObject) nS, (sObject) contractABC);
                        
                    //Add the updated Contract ABC record to the update list
                    contractABCToUpdate.put(contractABC.Id, contractABC);

                    }

                    //Logic for passing through Reference Values outside of the Custom Setting
                    if (nS.SBQQ__Contract__r.Account != oldSub.SBQQ__Contract__r.Account && nS.SBQQ__Contract__r.Account != null){

                        //Grab our Contract and update the field
                        contractABC = contractABCToUpdate.get(nS.Shadow_Contract_ABC__c);
                        contractABC.Payer_Account__c = nS.SBQQ__Contract__r.Account.Id;

                        //Pop our record back into the map for updating
                        contractABCToUpdate.put(contractABC.Id, contractABC);                     
                    }
                    else if (nS.Invoice_Contact__r.Name != oldSub.Invoice_Contact__r.Name && nS.Invoice_Contact__r.Name != null){
                        
                        //Grab our Contract and update the field
                        contractABC = contractABCToUpdate.get(nS.Shadow_Contract_ABC__c);
                        contractABC.Main_Contact_Name__c = nS.Invoice_Contact__r.Name;
                        
                        //Pop our record back into the map for updating
                        contractABCToUpdate.put(contractABC.Id, contractABC);
                    }

                }
                    
            }
        
            if (contractABCToUpdate.values().size() > 0) {
            Util.BypassAllTriggers = true;
            string errorMsg;
            
            try {
                update contractABCToUpdate.values();
            }
            catch(DMLException ex) {
                errorMsg = ex.getDMLMessage(0);
            }
            catch(Exception ex) {
                errorMsg = ex.getMessage() + ex.getStackTraceString();
            }
            
            if (errorMsg != null && trigger.isExecuting) {
                //if we are inside a trigger, return a user-friendly error message to the page
                if (trigger.IsExecuting) newSubs[0].addError(errorMsg);
            }
            else if (errorMsg != null && !trigger.isExecuting) {
                throw new customException(errorMsg);
            }
            
            Util.BypassAllTriggers = false;
        }
    }

   /**  
    *  Description   :  Returns a map of Constituent Products for Global Membership logic.
    *
    *  Created by    :  Victor Hanson
    *
    *  @return       :  Map<Id, Set<Id>>
    *
    *  @Revision Log  :  V1.0 - 10/31/2019 - Victor Hanson - CR-20191031-13488 - Created
    *
    **/
    public static Map<Id, Set<Id>> mapConstituentProductToProgramIds {
        get {
            if (mapConstituentProductToProgramIds == null) {
                mapConstituentProductToProgramIds = new Map<Id, Set<Id>>();
                for(Product_MtM__c pTM : [Select Id, Related_Product__r.Program__c, Source_Product__c, Source_Product__r.Program__c
                                    From Product_MtM__c 
                                    Where Related_Product__c != null 
                                    AND Related_Product__r.Program__c != null AND Source_Product__c != null
                                    AND Type__c = 'Constituent Product' ]) 
                {
                    if (!mapConstituentProductToProgramIds.containsKey(pTM.Source_Product__c))
                        mapConstituentProductToProgramIds.put(pTM.Source_Product__c, new Set<Id>());

                    Set<Id> programIds = mapConstituentProductToProgramIds.get(pTM.Source_Product__c);
                    programIds.add(pTM.Related_Product__r.Program__c);
                    
                    //Added by Mahendra Swarnkar - CR-20200318-13862 - 03/20/2020 
                    //Add the Source Program in the list.
                    if(pTM.Source_Product__r.Program__c != null && !programIds.contains(pTM.Source_Product__r.Program__c))
                        programIds.add(pTM.Source_Product__r.Program__c);

                    mapConstituentProductToProgramIds.put(pTM.Source_Product__c, programIds);
                }
                            
            }
            return mapConstituentProductToProgramIds;
        }
        set;
    }
    
  /**  Description    :  The method is used to populate Subscription fields on Membership same as populated Contract fields on membership in ContractUtilities.PopulateContractFields method.
   *
   *  Created by    :  Saurabh Kumar
   *
   *  Created Date  :  07/26/2017
   *
   *  @args      :  List<SBQQ__Subscription__c>
   *
   *  @return      :  Void
   *
   *  @Revision Log  :  V1.0 - Created
   *            	V1.1 - Modified - Subhash Garhwal - 03/28/2018 - Issue--CR12039--QA--00007920
   *            	V1.2 - Modified - Subhash Garhawal - 10/28/2018 - CR-20180504-12213
   *            	V1.3 - Modified - Subhash Garhawal - 10/08/2018 - CR-20180720-12456
   *            	V1.4 - Modified - Victor Hanson - 02/21/2019  - Added logic so Membership is only updated if one of the fields has changed
   *            	V1.5 - Modified - Subhash Garhwal - 02/22/2019  - CR-20190215-12886.
   *            	V1.6 - Modified - Victor Hanson - 10/31/2019 - CR-20191031-13488 - added logic for Product MtM Global Memberships
   *
   **/
    public static void populateSubscriptionFieldsOnMembership(List<SBQQ__Subscription__c> subscriptions, map<Id, SBQQ__Subscription__c> mapOldSubs){
      
        //Define Properties
      
        //Set to hold the Account Ids
        Set<Id> setAccIds = new Set<Id>();
      
        //Set to hold the Program Ids
        Set<Id> setProgramIds = new Set<Id>();
      
        //Set to hold the Std. Contract Id
        Set<Id> setStdContractIds = new Set<Id>();
      
        //Set to hold the inactive Subscription Ids
        Set<Id> setInactiveSubIds = new Set<Id>();
      
        //Map to hold the CIA records with Parent Std. Contract
        Map<Id, List<Contract_Integrated_Accounts__c>> mapCIAsWithStdContract = new Map<Id, List<Contract_Integrated_Accounts__c>>();

        //VH 11/11/2019 - get all subscriptions related to these institutions so the logic is able to compare all Subscriptions to determine the proper Status
        Set<Id> acctIds = new Set<Id>();
        for (SBQQ__Subscription__c sub : subscriptions) {
            acctIds.add(sub.SBQQ__Account__c);
        }
        
        List<SBQQ__Subscription__c> allSubscriptions = [SELECT Id, name, SBQQ__Account__c, Program__c, SBQQ__Contract__c, Status__c, Parent_Program__c, SBQQ__Product__c 
                                                        FROM SBQQ__Subscription__c 
                                                        WHERE SBQQ__Account__c IN :acctIds AND Status__c IN :Batch_NightlyMembershipSubUpdate.applicableStatuses];

        //Loop over the Program Subscriptions
        for(SBQQ__Subscription__c sub : allSubscriptions) {
		
            //Added By Subhash Garhawal - 10/08/2018 - CR-20180720-12456
            //Checks for Account, Program, Contract and Status 
            if(sub.SBQQ__Account__c != null && sub.Program__c != null && sub.SBQQ__Contract__c != null && sub.Status__c != null 
            && (mapOldSubs == null || (mapOldSubs != null && mapOldSubs.get(sub.Id) != null 
                && (sub.SBQQ__Account__c  != mapOldSubs.get(sub.Id).SBQQ__Account__c
                || sub.Program__c  != mapOldSubs.get(sub.Id).Program__c
                || sub.SBQQ__Contract__c  != mapOldSubs.get(sub.Id).SBQQ__Contract__c
                || sub.Status__c  != mapOldSubs.get(sub.Id).Status__c
                || sub.Parent_Program__c  != mapOldSubs.get(sub.Id).Parent_Program__c))))  {
       
                    
                    //Check for Account Id
                    if(sub.SBQQ__Account__c != null)
                        setAccIds.add(sub.SBQQ__Account__c);
                    
                    //Check for Program
                    if(sub.Program__c != null)
                        setProgramIds.add(sub.Program__c);
                    
                    //Check for Parent Program
                    if(sub.Parent_Program__c != null)
                        setProgramIds.add(sub.Parent_Program__c);
                    
                    //Check for Std. Contract
                    if(sub.SBQQ__Contract__c != null)
                        setStdContractIds.add(sub.SBQQ__Contract__c);
                    
                    //Check for Status
                    if(!IsActiveSubscriptionStatus(sub.Status__c))
                        setInactiveSubIds.add(sub.Id);       
            } 
        }
		
      	
        //Added By Dipesh Gupta - 08/29/2019 - CR-20190620-13190. 
        //Check for the map size. 
        if(mapConstituentProductToProgramIds != null && mapConstituentProductToProgramIds.size() > 0) {

            //Added by Victor Hanson - 10/31/2019 - CR-20191031-13488
            for (Set<Id> ids : mapConstituentProductToProgramIds.values()) {
                //Adding the Programs so all the membership can be retrived related to these Program
                setProgramIds.addAll(ids);
            }
                    
        }
      
        //Check for Set size
        if(setStdContractIds.size() > 0) {
            
            //03/17/2021 - CR-20210317-15003 - Victor Hanson - added setAccIds to where clause
            //Added By Subhash Garhwal - 02/22/2019 - CR-20190215-12886 - Starts from here 
            for(SBQQ__Subscription__c sub : [Select SBQQ__Contract__c From SBQQ__Subscription__c Where Program__c IN : setProgramIds AND RecordType.DeveloperName = 'Program' AND SBQQ__Contract__c != null AND SBQQ__Account__c IN : setAccIds])
                  setStdContractIds.add(sub.SBQQ__Contract__c);       
            //Added By Subhash Garhwal - 02/22/2019 - CR-20190215-12886 - ends here 
                
            //SOQL query over the CIA
            for(Contract_Integrated_Accounts__c cIA : [Select Id, Account__c, LOA_Contract__c From Contract_Integrated_Accounts__c Where 
                                    (Account__c IN : setAccIds OR LOA_Contract__c IN : setStdContractIds)
                                    AND LOA_Contract__c != null]) {
                                      
                //Add Account Id in set
                setAccIds.add(cIA.Account__c);
          
                //Add CIA with Std. Contract in map
                if(!mapCIAsWithStdContract.containsKey(cIA.LOA_Contract__c))
                    mapCIAsWithStdContract.put(cIA.LOA_Contract__c, new List<Contract_Integrated_Accounts__c>());
          
                //Add CIA with Std. Contract in map
                mapCIAsWithStdContract.get(cIA.LOA_Contract__c).add(cIA);
                              
            }
        
            //SOQL query over the Membership
            List<Membership__c> memberships = [Select Id, Account_Name__c, Program__c, Active_Subscription__c, Earliest_Subscription__c, 
                                        Earliest_Subscription__r.SBQQ__StartDate__c, Earliest_Subscription__r.SBQQ__EndDate__c, Active_Subscription__r.Program__c,Active_Subscription__r.SBQQ__EndDate__c,
                                        Latest_Subscription__c, Latest_Subscription__r.SBQQ__StartDate__c,Latest_Subscription__r.SBQQ__EndDate__c, Active_Subscription__r.SBQQ__Product__c  
                                      From Membership__c Where Program__c IN : setProgramIds and Account_Name__c IN : setAccIds];
        
            //Set to hold the Memberships unique identifiers
            Set<String> setMembershipUniqueIdentifiers = new Set<String>();
        
            //Loop over the Membership
            for(Membership__c mem : memberships) {
                setMembershipUniqueIdentifiers.add(mem.Account_Name__c + '-' + mem.Program__c);
            }
        
            //Map to hold all Program Subscriptions with Account
            Map<Id, List<SBQQ__Subscription__c>> mapProSubsWithAccount = new Map<Id, List<SBQQ__Subscription__c>>();
        
            //Subhash GArwal - 10/28/2018 - CR-20180504-12213 - Added 'SBQQ__Quantity__c' and 'Committed-Amended' in Status check in the query
            //Subhash Garhwal - 03/28/2018 - Issue--CR12039--QA--00007920 - Change Status Where clouse from NOT IN to IN
            //SOQL query over the Program Subscriptions
            //Added SBQQ__Product__c field in the query. Dipesh Gupta  CR-20190620-13190
            for(SBQQ__Subscription__c pS : [Select Id, Name, SBQQ__Contract__c, SBQQ__Account__c, Program__c, Parent_Program__c, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__Quantity__c, CreatedDate ,
                                               SBQQ__Product__c From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Program' AND ((SBQQ__Account__c IN : setAccIds AND Program__c IN : setProgramIds)
                                                    OR SBQQ__Contract__c IN : mapCIAsWithStdContract.keySet()) AND Status__c IN ('ATL', 'Honorary', 'Dropped', 'Committed', 'Committed-Amended')
                                                    ORDER BY CreatedDate DESC]) {
                
                //Get Program Id
                Id programId = pS.Program__c;
              
                if(pS.Parent_Program__c != null)
                    programId = pS.Parent_Program__c;
          
                //Check Account Id and Program Id
                if((setAccIds.contains(pS.SBQQ__Account__c) && setProgramIds.contains(programId))
                    || setMembershipUniqueIdentifiers.contains(pS.SBQQ__Account__c + '-' + programId)) {
                  
                    //Check Account Id in map
                    if(!mapProSubsWithAccount.containsKey(pS.SBQQ__Account__c))
                      mapProSubsWithAccount.put(pS.SBQQ__Account__c, new List<SBQQ__Subscription__c>());
                
                    //Add Program Subscription in map
                    mapProSubsWithAccount.get(pS.SBQQ__Account__c).add(pS);  
                        
                    //Map to check if it contains the Product Id.  Added By Dipesh Gupta - CR-20190620-13190
                    if(mapConstituentProductToProgramIds.containsKey(pS.SBQQ__Product__c))
                        mapConstituentProductToProgramIds.get(pS.SBQQ__Product__c).add(programId);
                     
                }
          
                //Check Std. Contract
                if(mapCIAsWithStdContract.containsKey(pS.SBQQ__Contract__c)) {
                
                    //Loop over the CIA
                    for(Contract_Integrated_Accounts__c cIA : mapCIAsWithStdContract.get(pS.SBQQ__Contract__c)) {
                      
                        //Check Account Id and Program Id
                        if((setAccIds.contains(cIA.Account__c) && setProgramIds.contains(pS.Program__c))
                            || setMembershipUniqueIdentifiers.contains(cIA.Account__c + '-' + pS.Program__c)) {
                             
                            //Check Account Id in map
                            if(!mapProSubsWithAccount.containsKey(cIA.Account__c))
                                mapProSubsWithAccount.put(cIA.Account__c, new List<SBQQ__Subscription__c>());
                             
                            //Add Program Subscription in map
                            mapProSubsWithAccount.get(cIA.Account__c).add(pS);      
                        }
                    }
                }
            }
        
        

        //List to update the membership
        List<Membership__c> membershipsToUpdate = new List<Membership__c>();
        
            //Loop over the Memberships
            for(Membership__c mem : memberships) {
          
                //Variables to hold the Subscription
                SBQQ__Subscription__c earliestSubscription;
                SBQQ__Subscription__c latestSubscription;
                SBQQ__Subscription__c activeSubscription;
                SBQQ__Subscription__c earliestFutureSubscription;
                
                //Check account Id in map
                if(mapProSubsWithAccount.containsKey(mem.Account_Name__c) && mapProSubsWithAccount.get(mem.Account_Name__c) != null) {
            
                //Loop over the Program Subscription
                for(SBQQ__Subscription__c pS : mapProSubsWithAccount.get(mem.Account_Name__c)) {
                    
                    //Get Program Id
                    Id programId = pS.Program__c;
                  
                    if(pS.Parent_Program__c != null)
                        programId = pS.Parent_Program__c;
                    
                    //Check for Program
                    //Modified By Dipesh Gupta - 08/29/2019 - CR-20190620-13190. Added the additional check if the 
                    if(mem.Program__c != programId) {
                        
                        if(!mapConstituentProductToProgramIds.containsKey(pS.SBQQ__Product__c)  || mapConstituentProductToProgramIds.get(pS.SBQQ__Product__c) == null || mapConstituentProductToProgramIds.get(pS.SBQQ__Product__c).size() == 0)
                           continue; 

                    	if(!mapConstituentProductToProgramIds.get(pS.SBQQ__Product__c).contains(programId)) 
                            continue;

                        //Added by Victor Hanson - 10/31/2019 - CR-20191031-13488
                        if (!mapConstituentProductToProgramIds.get(pS.SBQQ__Product__c).contains(mem.Program__c))
                            continue;
                    }
                    
                    

                    //Earliest Program Subscription
                    if ((pS.SBQQ__StartDate__c != null) && (earliestSubscription == null || pS.SBQQ__StartDate__c < earliestSubscription.SBQQ__StartDate__c)) 
                        earliestSubscription = pS;
                        
                    //Latest Program Subscription
                    if ((pS.SBQQ__EndDate__c != null) && (latestSubscription == null || pS.SBQQ__EndDate__c > latestSubscription.SBQQ__EndDate__c))
                        latestSubscription = pS;
                        
                    //Subhash GArwal - 02/22/2019 - CR-20190215-12886 -- Commented the check for pS.SBQQ__Quantity__c > 0
                    //Subhash GArwal - 10/28/2018 - CR-20180504-12213 - Added SBQQ__Quantity__c and CreatedDate check 
                    //Active Subscription idenfied
                    if(pS.SBQQ__StartDate__c != null && pS.SBQQ__EndDate__c != null && pS.SBQQ__StartDate__c <= System.today()
                        && pS.SBQQ__EndDate__c >= System.today() //&& pS.SBQQ__Quantity__c > 0
                        && (activeSubscription == null || (pS.SBQQ__EndDate__c != null && pS.SBQQ__EndDate__c >= System.today() && pS.SBQQ__EndDate__c > activeSubscription.SBQQ__EndDate__c)))
                        activeSubscription = pS;
              
                    //earliest Future Contract (to use for Active Contract Idenfied if there is none found within its dates)
                    if (pS.SBQQ__StartDate__c != null && pS.SBQQ__EndDate__c != null && pS.SBQQ__StartDate__c > System.today()
                        && (earliestFutureSubscription == null || (pS.SBQQ__StartDate__c != null && pS.SBQQ__StartDate__c > System.today() && pS.SBQQ__StartDate__c < earliestFutureSubscription.SBQQ__StartDate__c)))
                        earliestFutureSubscription = pS;
                }
              
                //VH 2/21/2019 - added so we only update membership if one of these fields has been updated
                boolean addMembershipToList = false;
            
                //If this is no "Active" Subscription, is there one in the future? We could use that in a pinch
                if ((activeSubscription == null) && (earliestFutureSubscription != null)) {
                    activeSubscription = earliestFutureSubscription;
                    addMembershipToList = true;
                }
            
                //Check for earliest Subscription
                if(earliestSubscription != null && earliestSubscription.Id != mem.Earliest_Subscription__c) {
                    mem.Earliest_Subscription__c = earliestSubscription.Id;
                    addMembershipToList = true;
                }
            
                //Check for latest Subscription
                if(latestSubscription != null && latestSubscription.Id != mem.Latest_Subscription__c) {
                    mem.Latest_Subscription__c = latestSubscription.Id;
                    addMembershipToList = true;
                }
            
                //Check for active Subscription
                if(activeSubscription != null && activeSubscription.Id != mem.Active_Subscription__c) {
                    mem.Active_Subscription__c = activeSubscription.Id;
                    addMembershipToList = true;
                }
            
                //Added By Dipesh Gupta - CR-20190826-13285 - Added a logic to nullify the subscription. 
                //Check for the null condition, if membership Active subsciption is not null but now the subscription ended and no active subscription exist. 
                if(mem.Active_Subscription__c != null && activeSubscription == null){
                    //updated by mahendra Swarnkar - 02/26/2020 - CR-20200114-13623 - Starts from here
                    if(mem.Active_Subscription__r.Program__c == mem.Program__c 
                    	|| (mem.Active_Subscription__r.Program__c != mem.Program__c && mem.Active_Subscription__r.SBQQ__Product__c != null  
                        	&& (mapConstituentProductToProgramIds == null 
                            	|| mapConstituentProductToProgramIds.size() == 0
                                || !mapConstituentProductToProgramIds.containsKey(mem.Active_Subscription__r.SBQQ__Product__c)
                                || mapConstituentProductToProgramIds.get(mem.Active_Subscription__r.SBQQ__Product__c) == null
                                || mapConstituentProductToProgramIds.get(mem.Active_Subscription__r.SBQQ__Product__c).size() == 0
                                || !mapConstituentProductToProgramIds.get(mem.Active_Subscription__r.SBQQ__Product__c).contains(mem.Active_Subscription__r.Program__c)
                                || !mapConstituentProductToProgramIds.get(mem.Active_Subscription__r.SBQQ__Product__c).contains(mem.Program__c)
                            )))
					{
                	mem.Active_Subscription__c = null;  
                    addMembershipToList = true;
                    }
                    //updated by mahendra Swarnkar - 02/26/2020 - CR-20200114-13623 - Ends here
                }
				// CR-20190826-13285 - Ends here. 
                
                    
                //Add record in list to update if one of the subscription fields needs to be updated
                if (addMembershipToList) {
                    membershipsToUpdate.add(mem);
                }
            }
        }
	
        //Check for list size
        if(membershipsToUpdate.size() > 0) {
          
            //Set flags to fire trigger
            Util.IsTrigger_ContractFieldUpdate = false;
            Util.IsTrigger_Opportunity_ValidationAndFieldUpdates = false;
          
            //Update 
            update membershipsToUpdate;
        }
        
        //Check for set
        if(setInactiveSubIds.size() > 0) {
          
            //Clear the list
            membershipsToUpdate.clear();
          
            //SOQL over the Membership
            for (Membership__c mem : [select Id, Active_Subscription__c, Earliest_Subscription__c, Earliest_Subscription__r.Status__c,
                                        Latest_Subscription__c, Latest_Subscription__r.Status__c, Active_Subscription__r.Status__c
                                        From Membership__c Where Active_Subscription__c IN : setInactiveSubIds]) {
            
                if (mem.Active_Subscription__c != null && !IsActiveSubscriptionStatus(mem.Active_Subscription__r.Status__c)) 
                    mem.Active_Subscription__c = null;
                if (mem.Latest_Subscription__c != null && !IsActiveSubscriptionStatus(mem.Latest_Subscription__r.Status__c))
                    mem.Latest_Subscription__c = null;
                if (mem.Earliest_Subscription__c != null && !IsActiveSubscriptionStatus(mem.Earliest_Subscription__r.Status__c))
                    mem.Earliest_Subscription__c = null;
                
                //Add records in lsit
                membershipsToUpdate.add(mem);
            }
          
            //Check for list size
            if(membershipsToUpdate.size() > 0) {
            
                //Set flags to fire trigger
                Util.IsTrigger_ContractFieldUpdate = false;
                Util.IsTrigger_Opportunity_ValidationAndFieldUpdates = false;
            
                //Update 
                update membershipsToUpdate;
            }
        }
    } 
  }

  /**  Description    :  The method is used to rollup Component Subscription fields on program subscription
   *
   *  Created by    :  Subhash Garhwal
   *
   *  Created Date  :  08/11/2017
   *
   *  @args      :  List<SBQQ__Subscription__c>, Map<Id,SBQQ__Subscription__c>
   *
   *  @return      :  Void
   *                    V_1.1 - Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
   **/
  public static void updateTravelandAnnualFeesonComponentSubscription(List<SBQQ__Subscription__c> newsubscriptions, Map<Id,SBQQ__Subscription__c> oldMapSubscription) {

    //Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
    //Get all record types of SBQQ__Subscription__c
    Map<String, Id> mapSubscriptionRecordTypes = new Map<String, Id>();
    mapSubscriptionRecordTypes = Constants.MAP_SUBSCRIPTION_RTYPE;      
    //Component Record Type
    String componentRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT);

    //Hold Map of programSubscription
    Map<Id,SBQQ__Subscription__c> mapProgramSubscriptionTobeUpdate = new Map<Id,SBQQ__Subscription__c>();

    //Map to hold porogram subscription
    Map<String,SBQQ__Subscription__c> mapProgramSubscription = new Map<String,SBQQ__Subscription__c>();

    //Loop through Subscription__c
    for(SBQQ__Subscription__c subscription : newsubscriptions != null ? newsubscriptions : oldMapSubscription.values()) {

      //Check for insert case
      if(oldMapSubscription == null && subscription.Customer_Amount__c != null && subscription.RecordTypeId == componentRecordType && 
        subscription.SBQQ__Product__c != null && subscription.Program_Subscription__c != null && subscription.SBQQ__SegmentIndex__c != null) {

        //Unique Key
        String uniqueKey = subscription.Program_Subscription__c + '_' + subscription.SBQQ__Product__c + '_' + subscription.SBQQ__SegmentIndex__c;

        //Put into Map 
        mapProgramSubscription.put(uniqueKey, new SBQQ__Subscription__c(Id = subscription.Program_Subscription__c,
                      Period_1_Annual_Fees__c = 0, Period_1_Travel_Fees__c = 0,
                      Period_2_Annual_Fees__c = 0, Period_2_Travel_Fees__c = 0,
                      Period_3_Annual_Fees__c = 0, Period_3_Travel_Fees__c = 0,
                      Period_4_Annual_Fees__c = 0, Period_4_Travel_Fees__c = 0,
                      Period_5_Annual_Fees__c = 0, Period_5_Travel_Fees__c = 0,
                      Total_Annual_Fees__c = 0,Total_Travel_Fees__c = 0,
                      Total_Set_Up_Fees__c = 0
                      ));
        
      }
      //Check For Update case
      else if(newsubscriptions != null && oldMapSubscription != null && subscription.RecordTypeId == componentRecordType && subscription.SBQQ__Product__c != null 
                      && subscription.SBQQ__SegmentIndex__c != null  &&
                      (subscription.Customer_Amount__c  != oldMapSubscription.get(subscription.Id).Customer_Amount__c
                       || subscription.Program_Subscription__c != oldMapSubscription.get(subscription.Id).Program_Subscription__c 
                       || subscription.SBQQ__SegmentIndex__c != oldMapSubscription.get(subscription.Id).SBQQ__SegmentIndex__c
                       || subscription.SBQQ__Product__c != oldMapSubscription.get(subscription.Id).SBQQ__Product__c) ) {

        //Check If Product is nopt equal to null  
        if( subscription.Program_Subscription__c != null && subscription.SBQQ__Product__c != null ) {

          //Unique Key
          String uniqueKey = subscription.Program_Subscription__c + '_' + subscription.SBQQ__Product__c + '_' + subscription.SBQQ__SegmentIndex__c;

          //Put into MAp
          mapProgramSubscription.put(uniqueKey, new SBQQ__Subscription__c(Id = subscription.Program_Subscription__c,
                      Period_1_Annual_Fees__c = 0, Period_1_Travel_Fees__c = 0,
                      Period_2_Annual_Fees__c = 0, Period_2_Travel_Fees__c = 0,
                      Period_3_Annual_Fees__c = 0, Period_3_Travel_Fees__c = 0,
                      Period_4_Annual_Fees__c = 0, Period_4_Travel_Fees__c = 0,
                      Period_5_Annual_Fees__c = 0, Period_5_Travel_Fees__c = 0,
                      Total_Annual_Fees__c = 0,Total_Travel_Fees__c = 0,
                      Total_Set_Up_Fees__c = 0
                      ));
          
                       
        }

        //Check if old Component subscription product is not equal to null
        if(oldMapSubscription.get(subscription.Id).Program_Subscription__c != null && oldMapSubscription.get(subscription.Id).SBQQ__Product__c != null) {

          //Unique Key
          String uniqueKey = oldMapSubscription.get(subscription.Id).Program_Subscription__c + '_' + subscription.SBQQ__Product__c + '_' + subscription.SBQQ__SegmentIndex__c;

          //Put into Map
          mapProgramSubscription.put(uniqueKey, 
                      new SBQQ__Subscription__c(Id = oldMapSubscription.get(subscription.Id).Program_Subscription__c,
                      Period_1_Annual_Fees__c = 0, Period_1_Travel_Fees__c = 0,
                      Period_2_Annual_Fees__c = 0, Period_2_Travel_Fees__c = 0,
                      Period_3_Annual_Fees__c = 0, Period_3_Travel_Fees__c = 0,
                      Period_4_Annual_Fees__c = 0, Period_4_Travel_Fees__c = 0,
                      Period_5_Annual_Fees__c = 0, Period_5_Travel_Fees__c = 0,
                      Total_Annual_Fees__c = 0,Total_Travel_Fees__c = 0,
                      Total_Set_Up_Fees__c = 0
                      ));
        
        }
      }
  
      //Check for delete case
      if(newsubscriptions == null && oldMapSubscription != null && subscription.Customer_Amount__c  != null && subscription.RecordTypeId == componentRecordType &&
        subscription.SBQQ__Product__c != null && subscription.Program_Subscription__c != null  && subscription.SBQQ__SegmentIndex__c != null ) {

          //Unique Key
          String uniqueKey = subscription.Program_Subscription__c + '_' + subscription.SBQQ__Product__c + '_' + subscription.SBQQ__SegmentIndex__c;

          //Put into Map
          mapProgramSubscription.put(uniqueKey, 
                      new SBQQ__Subscription__c(Id = subscription.Program_Subscription__c,
                      Period_1_Annual_Fees__c = 0, Period_1_Travel_Fees__c = 0,
                      Period_2_Annual_Fees__c = 0, Period_2_Travel_Fees__c = 0,
                      Period_3_Annual_Fees__c = 0, Period_3_Travel_Fees__c = 0,
                      Period_4_Annual_Fees__c = 0, Period_4_Travel_Fees__c = 0,
                      Period_5_Annual_Fees__c = 0, Period_5_Travel_Fees__c = 0,
                      Total_Annual_Fees__c = 0,Total_Travel_Fees__c = 0,
                      Total_Set_Up_Fees__c = 0
                      ));      
      }
    }


    //Check for condition
    if(mapProgramSubscription.size() > 0) {

      //Loop through Unique key
      for(String uK : mapProgramSubscription.keySet()) {
  
        //List to hoold Program subscription ids
        List<String> programSubscriptionId = uK.split('_');

        //Check for condition
        if(!mapProgramSubscriptionTobeUpdate.containskey(programSubscriptionId[0]))
           mapProgramSubscriptionTobeUpdate.put(programSubscriptionId[0], new SBQQ__Subscription__c(Id = programSubscriptionId[0],
                        Period_1_Annual_Fees__c = 0, Period_1_Travel_Fees__c = 0,
                        Period_2_Annual_Fees__c = 0, Period_2_Travel_Fees__c = 0,
                        Period_3_Annual_Fees__c = 0, Period_3_Travel_Fees__c = 0,
                        Period_4_Annual_Fees__c = 0, Period_4_Travel_Fees__c = 0,
                        Period_5_Annual_Fees__c = 0, Period_5_Travel_Fees__c = 0,
                        Total_Annual_Fees__c = 0,Total_Travel_Fees__c = 0,
                        Total_Set_Up_Fees__c = 0));  
      }
    }
    //Check for size
    if(mapProgramSubscription.Size() > 0 ) {
  
      //Loop through Subscription
      for(SBQQ__Subscription__c subscription :[Select Id, Program_Subscription__c,
                    SBQQ__SegmentIndex__c,
                    Customer_Amount__c,
                    SBQQ__Product__r.Product_Category__c
                    From SBQQ__Subscription__c Where 
                    Program_Subscription__c IN: mapProgramSubscriptionTobeUpdate.keyset() AND
                    SBQQ__Product__r.Product_Category__c != null AND
                    RecordTypeId =: componentRecordType ]) {

        //Check if Map contain Program subscription Id
        if(mapProgramSubscriptionTobeUpdate.containsKey(subscription.Program_Subscription__c)) {
  
          //Check for Product Category is Annual fees
          if(subscription.SBQQ__Product__r.Product_Category__c == CPQConstants.PRODUCT_CATEGORY_ANNUAL_FEE) {

            //Check for Segment Index 
            if( subscription.SBQQ__SegmentIndex__c == 1)
              mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Period_1_Annual_Fees__c  += subscription.Customer_Amount__c;
            else if(subscription.SBQQ__SegmentIndex__c == 2)
              mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Period_2_Annual_Fees__c  += subscription.Customer_Amount__c;
            else if(subscription.SBQQ__SegmentIndex__c == 3)
              mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Period_3_Annual_Fees__c  += subscription.Customer_Amount__c;
            else if(subscription.SBQQ__SegmentIndex__c == 4)
              mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Period_4_Annual_Fees__c  += subscription.Customer_Amount__c;
            else if(subscription.SBQQ__SegmentIndex__c == 5)
                mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Period_5_Annual_Fees__c  += subscription.Customer_Amount__c;

            //Add value to Map
            mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Total_Annual_Fees__c = 
                          mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Period_1_Annual_Fees__c +
                          mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Period_2_Annual_Fees__c +
                          mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Period_3_Annual_Fees__c +
                          mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Period_4_Annual_Fees__c +
                          mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Period_5_Annual_Fees__c ;
          }
          
          //Check if Product category is Travel fees
          else if(subscription.SBQQ__Product__r.Product_Category__c == CPQConstants.PRODUCT_CATEGORY_TRAVEL_FEE) {

            //Check for Segment Index 
            if( subscription.SBQQ__SegmentIndex__c == 1)
              mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Period_1_Travel_Fees__c  += subscription.Customer_Amount__c;
            else if(subscription.SBQQ__SegmentIndex__c == 2)
              mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Period_2_Travel_Fees__c  += subscription.Customer_Amount__c;
            else if(subscription.SBQQ__SegmentIndex__c == 3)
              mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Period_3_Travel_Fees__c  += subscription.Customer_Amount__c;
            else if(subscription.SBQQ__SegmentIndex__c == 4)
              mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Period_4_Travel_Fees__c  += subscription.Customer_Amount__c;
            else if(subscription.SBQQ__SegmentIndex__c == 5)
              mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Period_5_Travel_Fees__c  += subscription.Customer_Amount__c;

            //Add value to Map
            mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Total_Travel_Fees__c = 
                      mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Period_1_Travel_Fees__c +
                      mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Period_2_Travel_Fees__c +
                      mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Period_3_Travel_Fees__c +
                      mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Period_4_Travel_Fees__c +
                      mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Period_5_Travel_Fees__c ;
            
          }

          //Check if Product Category is 'Implementation Fee' or 'Initiation Fee'
          else if(subscription.SBQQ__Product__r.Product_Category__c == CPqConstants.PRODUCT_CATEGORY_IMPLEMENTATION_FEE || subscription.SBQQ__Product__r.Product_Category__c == CPQConstants.PRODUCT_CATEGORY_INITIATION_FEE) {
            mapProgramSubscriptionTobeUpdate.get(subscription.Program_Subscription__c).Total_Set_Up_Fees__c +=  subscription.Customer_Amount__c;
          }
        }
      }

      //Check for Condition
      if(mapProgramSubscriptionTobeUpdate.values().size() > 0 ) {

        //Bypassing triggers
        Util.byPassAllTriggers = true;

        //Update
        update mapProgramSubscriptionTobeUpdate.Values();

        //Bypassing triggers
        Util.byPassAllTriggers = false;
      }
    }
  }
  
  /**
   *  @Description       :  The method is used to Negotiated amount (Period) on the Pending Subscription Period with the Uplift logic.
   *
   *  @args      	 :  List<SBQQ__Subscription__c>, Map<Id,SBQQ__Subscription__c>
   *
   *  @return      	 :  Void
   *
   *  @Revision Log      :  V1.0 - 09/02/2017 - Subhash Garhwal - Issue--CR11062--QA--00005609
                            V1.1 - 02/09/2018 - Subahsh Garhwal - CR-20180207-12036 - New Check in the query  Subscription_Period__r.Is_Full_Year__c = 1 in Query of Subscription
                            V1.2 - 02/27/2018 - Subahsh Garhwal - CR-20180226-12084
                            V1.3 - Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
   *
   **/
  public static void updatePendingSPNegotiatedAmountPeriod(List<SBQQ__Subscription__c> subscriptions, Map<Id,SBQQ__Subscription__c> mapOldSubscriptions) {
    
    //Modified By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
    //Get all record types of SBQQ__Subscription__c
    Map<String, Id> mapSubscriptionRecordTypes = new Map<String, Id>();
    mapSubscriptionRecordTypes = Constants.MAP_SUBSCRIPTION_RTYPE;      
    //Component Record Type
    String componentRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT);
    
    //Set to hold the Program Subscription Ids
    Set<Id> setProSubIds = new Set<Id>();
    
    //Loop over the Subscriptions
    for(SBQQ__Subscription__c sub : subscriptions) {
      
      //Check for record type
            if(sub.RecordTypeId == componentRecordType && sub.Subscription_Period__c != null && sub.Program_Subscription__c != null
               && (mapOldSubscriptions == null || sub.Subscription_Period__c != mapOldSubscriptions.get(sub.Id).Subscription_Period__c
                   || sub.SBQQ__CustomerPrice__c != mapOldSubscriptions.get(sub.Id).SBQQ__CustomerPrice__c || sub.SBQQ__Quantity__c != mapOldSubscriptions.get(sub.Id).SBQQ__Quantity__c)) {
        
        //Add Program Subscription in set
        setProSubIds.add(sub.Program_Subscription__c);
      }
    }
    
    //Check for size
    if(setProSubIds.size() > 0) {
            
            //Map to hold the Program Subscription with Pending Subscription Period calculations
            Map<Id, Decimal> mapProgramSubWithPendingProposalValue = new Map<Id,Decimal>();
            
            //Map to hold the greatest Segment Index on the Program Subscription
            Map<Id, Decimal> mapProSubWithGreatestSegmentIndex = new Map<Id, Decimal>();
            
            //SOQL on the Component Subscriptions
            //Additional Check  Subscription_Period__r.Is_Full_Year__c = 1 - Subahsh Garhwal - 02/09/2018
            for(SBQQ__Subscription__c compSub : [Select Id, SBQQ__SegmentIndex__c, SBQQ__CustomerPrice__c, Program_Subscription__c, Customer_Amount__c, SBQQ__SegmentUplift__c
                                                 From SBQQ__Subscription__c Where RecordTypeId =: componentRecordType
                                                 AND Program_Subscription__c IN : setProSubIds AND SBQQ__SegmentIndex__c != null
                                                 ORDER BY Subscription_Period__r.Is_Full_Year__c  DESC, SBQQ__SegmentIndex__c DESC, Program_Subscription__c]) {
                                                     
                                                     //Check Program Subscription in map
                                                     if(!mapProSubWithGreatestSegmentIndex.containsKey(compSub.Program_Subscription__c)) {
                                                         
                                                         //Add Program Subscription in map
                                                         mapProSubWithGreatestSegmentIndex.put(compSub.Program_Subscription__c, compSub.SBQQ__SegmentIndex__c);
                                                         
                                                         //Check for uplift
                                                         if(compSub.SBQQ__SegmentUplift__c != null && compSub.SBQQ__SegmentUplift__c > 0 && compSub.Customer_Amount__c != null
                                                            && compSub.Customer_Amount__c > 0) {
                                                                
                                                                //Perform the calculation
                                                                Decimal pendingNAPAmount = compSub.Customer_Amount__c + ((compSub.Customer_Amount__c * compSub.SBQQ__SegmentUplift__c)/100);
                                                                
                                                                //Add amount in map
                                                                mapProgramSubWithPendingProposalValue.put(compSub.Program_Subscription__c, pendingNAPAmount);
                                                                
                                                            } else
                                                                mapProgramSubWithPendingProposalValue.put(compSub.Program_Subscription__c, compSub.Customer_Amount__c);
                                                         
                                                     } else if(mapProSubWithGreatestSegmentIndex.get(compSub.Program_Subscription__c) == compSub.SBQQ__SegmentIndex__c) {
                                                         
                                                         //Check for uplift
                                                         if(compSub.Customer_Amount__c != null && compSub.Customer_Amount__c > 0) {
                                                             
                                                             //Perform the calculation
                                                             Decimal pendingNAPAmount = compSub.Customer_Amount__c;
                                                             
                                                             if(compSub.SBQQ__SegmentUplift__c != null && compSub.SBQQ__SegmentUplift__c > 0 )
                                                                 pendingNAPAmount += ((compSub.Customer_Amount__c * compSub.SBQQ__SegmentUplift__c)/100);
                                                             
                                                             //Check Program Subscription Id in map
                                                             if(mapProgramSubWithPendingProposalValue.containsKey(compSub.Program_Subscription__c) && mapProgramSubWithPendingProposalValue.get(compSub.Program_Subscription__c) != null) {
                                                                 
                                                                 //Add overall NAP
                                                                 Decimal finalPendingNAPAmount = mapProgramSubWithPendingProposalValue.get(compSub.Program_Subscription__c) + pendingNAPAmount;
                                                                 
                                                                 //Add amount in map
                                                                 mapProgramSubWithPendingProposalValue.put(compSub.Program_Subscription__c, finalPendingNAPAmount);
                                                             } 
                                                         }
                                                     }           
                                                 }
            
            //Check for size
            if(mapProgramSubWithPendingProposalValue.size() > 0) {
                
                //List to update Pending Subscription Period
                Map<Id, Subscription_Period__c> mapPendingSubscriptionPeriodsWithProgramSub = new Map<Id, Subscription_Period__c>();
                
                //CR-20180226-12084 - Removed Segment_Index__c = null and added Decision_Type__c = �Need New LOA� checkcheck
                //SOQL over Pending Subscription Period
                for(Subscription_Period__c sP : [Select Id, Name, Decision_Type__c, Proposal_Value_Number__c, Negotiated_Amount_Period__c, Program_Subscription__c,Period_End_Date__c From Subscription_Period__c
                                                 Where Program_Subscription__c IN : mapProgramSubWithPendingProposalValue.keySet()
                                                 AND Stage__c = 'Pending' ORDER BY Period_Start_Date__c DESC]) 
                {
                    
                    //Check the Program Subscription in map
                    if(!mapPendingSubscriptionPeriodsWithProgramSub.containsKey(sP.Program_Subscription__c) &&
                       mapProgramSubWithPendingProposalValue.containsKey(sP.Program_Subscription__c)) {
                           
                           //Update the Proposal_Value_Number__c
                           sP.Proposal_Value_Number__c = mapProgramSubWithPendingProposalValue.get(sP.Program_Subscription__c);
                           
                           if (sP.Decision_Type__c == 'Need New LOA') {
                               //Update the Negotiated_Amount_Period__c
                               sP.Negotiated_Amount_Period__c = mapProgramSubWithPendingProposalValue.get(sP.Program_Subscription__c);
                           }
                           
                           //Add record in map
                           mapPendingSubscriptionPeriodsWithProgramSub.put(sP.Program_Subscription__c, sP);
                       }        
                }
                
                //Update
                if(mapPendingSubscriptionPeriodsWithProgramSub.size() > 0) {
                    Util.byPassAllTriggers = true;
                    update mapPendingSubscriptionPeriodsWithProgramSub.values();
                    Util.byPassAllTriggers = false;
                }
            }
        }
  }
    
    /**
     *  @description    : This Method is used to Populate the renewal opportunity on Contract ABC
     * 
     *  @args           : List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
     * 
     *  @return         : void
     * 
     *  @revision log   : V1.0 - Created - Subhash Garhwal - CR-20180126-11910 
     *                    
     **/
    public static void updateContractABCRenewalOpportunity(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
    
        //Set to hold the Subscription Ids
        Set<Id> setproSubscriptionIds = new Set<Id>();
        
        //Loop through the new Contract List
        for(SBQQ__Subscription__c pS : subscriptions) {
            
            //Check for condition
            if(mapOldSubscriptions == null || pS.SBQQ__Contract__c != mapOldSubscriptions.get(pS.Id).SBQQ__Contract__c || pS.Shadow_Contract_ABC__c != mapOldSubscriptions.get(pS.Id).Shadow_Contract_ABC__c)
            setproSubscriptionIds.add(pS.Id);        
        }
    
        //Check for contracts
        if(setproSubscriptionIds.size() > 0) {
            
            //Map to update the Contract ABC
            Map<Id, Contract__c> mapContractsABC = new Map<Id, Contract__c>();
            
            //SOQL over the Program Subscription
            for(SBQQ__Subscription__c proSub : [Select Id, SBQQ__Contract__c, SBQQ__Contract__r.SBQQ__RenewalOpportunity__c, Shadow_Contract_ABC__c From SBQQ__Subscription__c
                                                           Where Id IN : setproSubscriptionIds AND Shadow_Contract_ABC__c != null
                                                            AND RecordType.DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM]) {
                
                //Update Renewal Opportunity on Contract ABC
                mapContractsABC.put(proSub.Shadow_Contract_ABC__c, new Contract__c(Id = proSub.Shadow_Contract_ABC__c, Contract_Renewal_Opportunity__c = proSub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c));    
            }
            
            //Check for map size
            if(mapContractsABC.size() > 0) {
                
                //Bypass Trigger
                Util.BypassAllTriggers = true;
                
                //Update
                update mapContractsABC.values();
                 
                //Bypass Trigger
                Util.BypassAllTriggers = false;        
            }
        }
    }
    
    /**
     *  @description    : This Method is used to Populate the Owner's Manager to the Subscription Period 
     * 
     *  @args           : List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
     * 
     *  @return         : void
     * 
     *  @revision log   : V1.0 - Created - Subhash Garhwal - CR-20180126-11912 
     *                    
     **/
    public static Void populateOwnerManagerEmailToSubPeriod(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscription) {
      
      //Map to hold the Ids of subscriiption with its OwnerId
      Map<Id, Id> MapSubIdWithOwnerId = new Map<Id, Id>();
      
      //Map to hold the User Id With the His Manager Email 
      Map<Id, String> mapUserIdWIthMangerEMail = new Map<Id, String>();
      
      //List to update the Subscription Period 
      List<Subscription_Period__c> subPeriodToBeUpdate = new List<Subscription_Period__c>();
      
      //Loop on the new List of Subscription
      for(SBQQ__Subscription__c subs : subscriptions) {
        
        //Check for the Update case only - This Method only fire when the Update call is going
        if(mapOldSubscription == null || subs.OwnerId != mapOldSubscription.get(subs.Id).OwnerId)   {
          
          //Filling the Set with the Subscription Ids 
          MapSubIdWithOwnerId.put(subs.Id, subs.OwnerId);  
        }
      }
      
      //Check the Size of Set
      if(MapSubIdWithOwnerId.size() > 0) {
            
            //Query on the User to get the Manager
        for(User usr : [Select Id, Manager.Email From User Where ManagerId != null AND Id IN: MapSubIdWithOwnerId.values()]) 
          mapUserIdWIthMangerEMail.put(usr.Id, usr.Manager.Email);
        
        //Query on the Subscription Period 
        for(Subscription_Period__c subPeriod : [Select Id, Owner_Manager_Email__c, Program_Subscription__r.OwnerId From Subscription_Period__c 
                              Where Program_Subscription__c IN: MapSubIdWithOwnerId.keySet()] ) {
          
          
          //Check if the Manager Email is not populated Right
          if(mapUserIdWIthMangerEMail.containsKey(subPeriod.Program_Subscription__r.OwnerId) 
            && mapUserIdWIthMangerEMail.get(subPeriod.Program_Subscription__r.OwnerId) != subPeriod.Owner_Manager_Email__c)  {
            
            //Filing the List with the New Manager EMail Addresas
            subPeriodToBeUpdate.add(new Subscription_Period__c(Id = subPeriod.Id, Owner_Manager_Email__c = mapUserIdWIthMangerEMail.get(subPeriod.Program_Subscription__r.OwnerId) ));
          }
        }
        
        //Bypass All triggers
        Util.ByPassAllTriggers = true;
        
        //Check for the Size of list
        if(subPeriodToBeUpdate.size() > 0)
          update subPeriodToBeUpdate;
          
        //Bypass All triggers
        Util.ByPassAllTriggers = false;
      }
    }
    
    /**
     *  @description    :  This Method is used to Populate Proposal_Value_Number Field on the Subscription period (Parent of Component Subscription)
     * 
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>  
     * 
     *  @return         :   void
     * 
     *  @revision log   :  V1.0 - Created - Subhash Garhwal - CR-20180131-11927
     *           	:  V1.1 - Updated By Mahendra Swarnkar - 04/03/2019 - CR-20181019-12685
     *                    
     **/
    public static void updateProposalvalue(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscription) {
      
        	//Map to hold the Subscription Period that is Going to update 
		Map<Id, Subscription_Period__c> mapSubPeriodToBeUpdate = new Map<Id, Subscription_Period__c>();
      
		//Set to hold the Program Subscription Ids
		Set<Id> setProgramSubsIds = new Set<Id>();
      
		//Loop to iterate the subscription
		for(SBQQ__Subscription__c subscription : subscriptions != null ? subscriptions : mapOldSubscription.values()) {
        
			//Check for insert case
			if(mapOldSubscription == null && subscription.Program_Subscription__c != null && subscription.Subscription_Period__c != null) {
          
			//Add Program Subscription in set
			setProgramSubsIds.add(subscription.Program_Subscription__c);
        
			//Add Sub. Period
			mapSubPeriodToBeUpdate.put(subscription.Subscription_Period__c, new Subscription_Period__c(Id = subscription.Subscription_Period__c, Proposal_Value_Number__c = 0));
			}
        
			//Update Case
			if(subscriptions != null && mapOldSubscription != null && subscription.Program_Subscription__c != null
				&& (mapOldSubscription == null || mapOldSubscription.get(subscription.Id).Subscription_Period__c != subscription.Subscription_Period__c
				|| mapOldSubscription.get(subscription.Id).SBQQ__CustomerPrice__c != subscription.SBQQ__CustomerPrice__c
				|| mapOldSubscription.get(subscription.Id).SBQQ__Quantity__c != subscription.SBQQ__Quantity__c)) {
            
				//Add Program Subscription in set
				setProgramSubsIds.add(subscription.Program_Subscription__c);

                		//Add Sub. Period
				//Check for new value
				if(subscription.Subscription_Period__c != null)
					mapSubPeriodToBeUpdate.put(subscription.Subscription_Period__c, new Subscription_Period__c(Id = subscription.Subscription_Period__c, Proposal_Value_Number__c = 0));
        
				//Check for old SP
				if(mapOldSubscription.get(subscription.Id).Subscription_Period__c != null)
					mapSubPeriodToBeUpdate.put(mapOldSubscription.get(subscription.Id).Subscription_Period__c, new Subscription_Period__c(Id = mapOldSubscription.get(subscription.Id).Subscription_Period__c, Proposal_Value_Number__c = 0));    
			}
      
			//Delete case for insert case
			if(subscriptions == null && subscription.Subscription_Period__c != null) {
          
				//Add Program Subscription in set
				setProgramSubsIds.add(subscription.Program_Subscription__c);
        
				//Add Sub. Period
				mapSubPeriodToBeUpdate.put(subscription.Subscription_Period__c, new Subscription_Period__c(Id = subscription.Subscription_Period__c, Proposal_Value_Number__c = 0));
			}
          
		}
      
		//check the size of Set
		if(mapSubPeriodToBeUpdate.size() > 0 ) {
        
			//Map to hold the Future Subscription Period for Program Subscription
			Map<Id, Id> mapFutureSubPeriodWithProgramSubs = new Map<Id, Id>();

			//Modified By - Suhash Garhawal - 28/06/2018 - CR-20180627-12306 - Added size check           
			if(setProgramSubsIds.size() > 0) {
            
				//SOQL over the Subscription Periods
				for(Subscription_Period__c sP : [Select Id, Program_Subscription__c
								From Subscription_Period__c
								Where Program_Subscription__c IN : setProgramSubsIds AND Stage__c = 'Pending'
								ORDER BY Period_Start_Date__c DESC, Program_Subscription__c]) {
            
                                                           
					//Check Prgoram Subscription Id in map
					if(!mapFutureSubPeriodWithProgramSubs.containsKey(sP.Program_Subscription__c)) {
              
						//Add value in map
						mapFutureSubPeriodWithProgramSubs.put(sP.Program_Subscription__c, sP.Id);
              
						//Check Future Sub Period in SP map
						if(mapSubPeriodToBeUpdate.containsKey(sP.Id))
							mapSubPeriodToBeUpdate.remove(sP.Id);  
					}
				}
			}
         
			//Updated By Mahendra Swarnkar - 04/03/2019 - CR-20181019-12685 - Commented the Postage cost and media cost product code check
			//Query to get the Subscription periods's related component Subscription
			AggregateResult[] compSubPeriodsum = [SELECT SUM(Customer_Amount__c) cusPrice, Subscription_Period__c sP FROM SBQQ__Subscription__c
								Where RecordType.DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT 
								AND Subscription_Period__c IN: mapSubPeriodToBeUpdate.keySet() //AND Product_Code__c NOT IN ('Postage Costs', 'Media Costs')
								GROUP BY Subscription_Period__c];

			//loop to get the 
			for (AggregateResult ar : compSubPeriodsum) {
        
			//get Id
			Id sPId = (Id)ar.get('sP');
        
			//Check Id in map
			if(mapSubPeriodToBeUpdate.containsKey(sPId))
				mapSubPeriodToBeUpdate.get(sPId).Proposal_Value_Number__c = (Decimal)ar.get('cusPrice');  
			}
      
			//Check the Size of sub Period List
			if(mapSubPeriodToBeUpdate.size() > 0) {
        
				//Bypass All Trigger
				Util.ByPassAllTriggers = true;
        
				//Update the subscription period List
				update mapSubPeriodToBeUpdate.values();
        
				//Reset the Bypss of trigger      
				Util.ByPassAllTriggers = false;
			}
		}      
            
    }
    
    /**
   *  @Description  :  The method is used to Proposal Value Number on the Pending Subscription Period with the Uplift logic.
   *
   *  @args         :  List<SBQQ__Subscription__c>, Map<Id,SBQQ__Subscription__c>
   *
   *  @return       :  Void
   *
   *  @Revision Log :  V1.0 - 09/02/2017 - Subhash Garhwal - CR-20180131-11927
   *                   V1.1 - 03/13/2018 - Victor Hanson - Commented out, because it's essentially a duplicate of updatePendingSPNegotiatedAmountPeriod().
   *
   **/
   /*public static void updateProposalValueForFutureSubPeriod(List<SBQQ__Subscription__c> subscriptions, Map<Id,SBQQ__Subscription__c> mapOldSubscriptions) {
    
		//Get all record types of SBQQ__Subscription__c
		Map<String, Id> mapSubscriptionRecordTypes = Util.recordtypemap(CPQConstants.OBJECT_SBQQ_SUBSCRIPTION);
          
		//Component Record Type
		String componentRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT);
    
		//Set to hold the Program Subscription Ids
		Set<Id> setProSubIds = new Set<Id>();
    
		//Loop over the Subscriptions
		for(SBQQ__Subscription__c sub : subscriptions) {
      
			//Check for record type
			if(sub.RecordTypeId == componentRecordType && sub.Subscription_Period__c != null && sub.Program_Subscription__c != null
			&& (mapOldSubscriptions == null || sub.Subscription_Period__c != mapOldSubscriptions.get(sub.Id).Subscription_Period__c
			|| sub.SBQQ__CustomerPrice__c != mapOldSubscriptions.get(sub.Id).SBQQ__CustomerPrice__c || sub.SBQQ__Quantity__c != mapOldSubscriptions.get(sub.Id).SBQQ__Quantity__c)) {
           
				//Add Program Subscription in set
				setProSubIds.add(sub.Program_Subscription__c);
			}
		}
    
		//Check for size
		if(setProSubIds.size() > 0) {
      
			//Map to hold the Program Subscription with Pending Subscription Period calculations
			Map<Id, Decimal> mapProgramSubWithPendingProposalValue = new Map<Id,Decimal>();
      
			//Map to hold the greatest Segment Index on the Program Subscription
            		Map<Id, Decimal> mapProSubWithGreatestSegmentIndex = new Map<Id, Decimal>();
            
			//SOQL on the Component Subscriptions
           		for(SBQQ__Subscription__c compSub : [Select Id, SBQQ__SegmentIndex__c, SBQQ__CustomerPrice__c, Program_Subscription__c, Customer_Amount__c, SBQQ__SegmentUplift__c
								From SBQQ__Subscription__c
								Where RecordTypeId =: componentRecordType AND Program_Subscription__c IN : setProSubIds AND SBQQ__SegmentIndex__c != null
								ORDER BY Subscription_Period__r.Is_Full_Year__c DESC, SBQQ__SegmentIndex__c DESC, Program_Subscription__c]) {
                
                //Check Program Subscription in map
                if(!mapProSubWithGreatestSegmentIndex.containsKey(compSub.Program_Subscription__c)) {
                  
                    //Add Program Subscription in map
                    mapProSubWithGreatestSegmentIndex.put(compSub.Program_Subscription__c, compSub.SBQQ__SegmentIndex__c);
                    
                    //Check for uplift
                    if(compSub.SBQQ__SegmentUplift__c != null && compSub.SBQQ__SegmentUplift__c > 0 && compSub.Customer_Amount__c != null
                      && compSub.Customer_Amount__c > 0) {
                      
                                //Perform the calculation
                                Decimal pendingNAPAmount = compSub.Customer_Amount__c + ((compSub.Customer_Amount__c * compSub.SBQQ__SegmentUplift__c)/100);
                      
                                //Add amount in map
                                mapProgramSubWithPendingProposalValue.put(compSub.Program_Subscription__c, pendingNAPAmount);
                    
                    } else
                    	mapProgramSubWithPendingProposalValue.put(compSub.Program_Subscription__c, compSub.Customer_Amount__c);
                
                } else if(mapProSubWithGreatestSegmentIndex.get(compSub.Program_Subscription__c) == compSub.SBQQ__SegmentIndex__c) {
                    
                    //Check for uplift
                    if(compSub.Customer_Amount__c != null && compSub.Customer_Amount__c > 0) {
                      
                        //Perform the calculation
                        Decimal pendingNAPAmount = compSub.Customer_Amount__c;
                      
                        if(compSub.SBQQ__SegmentUplift__c != null && compSub.SBQQ__SegmentUplift__c > 0 )
                            pendingNAPAmount += ((compSub.Customer_Amount__c * compSub.SBQQ__SegmentUplift__c)/100);
                      
                        //Check Program Subscription Id in map
                        if(mapProgramSubWithPendingProposalValue.containsKey(compSub.Program_Subscription__c) && mapProgramSubWithPendingProposalValue.get(compSub.Program_Subscription__c) != null) {
                        
                            //Add overall NAP
                            Decimal finalPendingNAPAmount = mapProgramSubWithPendingProposalValue.get(compSub.Program_Subscription__c) + pendingNAPAmount;
                        
                            //Add amount in map
                            mapProgramSubWithPendingProposalValue.put(compSub.Program_Subscription__c, finalPendingNAPAmount);
                        } 
                    }
                }           
            }
            
            //Check for size
            if(mapProgramSubWithPendingProposalValue.size() > 0) {
              
	      //List to update Pending Subscription Period
                Map<Id, Subscription_Period__c> mapPendingSubscriptionPeriodsWithProgramSub = new Map<Id, Subscription_Period__c>();
                
                //SOQL over Pending Subscription Period
                for(Subscription_Period__c sP : [Select Id, Name, Proposal_Value_Number__c, Program_Subscription__c,Period_End_Date__c From Subscription_Period__c
                                                Where Program_Subscription__c IN : mapProgramSubWithPendingProposalValue.keySet()
                                                AND Stage__c = 'Pending' ORDER BY Period_Start_Date__c DESC]) {
           
                    //Check the Program Subscription in map
                    if(!mapPendingSubscriptionPeriodsWithProgramSub.containsKey(sP.Program_Subscription__c) &&
                       mapProgramSubWithPendingProposalValue.containsKey(sP.Program_Subscription__c)) {
                      
                        //Update the Proposal_Value_Number__c
                        sP.Proposal_Value_Number__c = mapProgramSubWithPendingProposalValue.get(sP.Program_Subscription__c);
                      
                        //Add record in map
                        mapPendingSubscriptionPeriodsWithProgramSub.put(sP.Program_Subscription__c, sP);
                    }        
                }
                
                //Update
                if(mapPendingSubscriptionPeriodsWithProgramSub.size() > 0) {
                    Util.byPassAllTriggers = true;
                    update mapPendingSubscriptionPeriodsWithProgramSub.values();
                    Util.byPassAllTriggers = false; 
                }
            }
		}
	}*/
    
  /**
   *  @Description	:	The method is used to identify the Component subscription and pass the component subscription to the future Method.
   *
   *  @args      	:	List<SBQQ__Subscription__c>, Map<Id,SBQQ__Subscription__c>
   *
   *  @return      	:	Void
   *
   *  @Revision Log	:	V1.0 - Created - Subhash Garhwal - 04/10/2018
   *  				V1.0 - Modified By - Subhash Garhwal - 01/05/2021 - CR-20210105-14767
   *
   **/
  public static void checkComponentSubscription(List<SBQQ__Subscription__c> newSubscriptions, Map<Id,SBQQ__Subscription__c> oldMapSubscription) {
    
      //Set to hold the Component Subscription ids 
      Set<Id> setComSubIds = new Set<Id>();
      
      //Loop on the List Of Subscription.
      for(SBQQ__Subscription__c subscription : newSubscriptions) {
        
        //Check for the recordTypeId - Wether its a component or Not or Start Date or End Date Changed and Start Date is greatet than end Date
        if((oldMapSubscription == null || oldMapSubscription.get(subscription.Id).SBQQ__SegmentStartDate__c != subscription.SBQQ__SegmentStartDate__c 
               || oldMapSubscription.get(subscription.Id).SBQQ__SegmentEndDate__c != subscription.SBQQ__SegmentEndDate__c) &&
                subscription.RecordTypeId == Constants.RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT 
                 && subscription.SBQQ__SegmentStartDate__c != null && subscription.SBQQ__SegmentEndDate__c != null && subscription.SBQQ__SegmentStartDate__c > subscription.SBQQ__SegmentEndDate__c)  
          
                //Adding Subscripotion Ids to the Set
               setComSubIds.add(subscription.Id);
      }
      
       //Check thee Size of Set - if greater than call a method to delete the comp. subscription for those End date is less than start date
        if(setComSubIds.size() > 0) {
      		//System.enqueueJob(new DeleteCompSubscriptionEnquueJob(setComSubIds));
      		dateTime sysTime = dateTime.now().addSeconds(2);
            	String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            
            	DeleteCompSubscriptionEnquueJob job = new DeleteCompSubscriptionEnquueJob(setComSubIds);
            	System.schedule('DeleteCompSubscriptionEnquueJob' + sysTime.getTime(),chron_exp, job);
        }
    }
    
    
    /**
     *  @description    :   Method is used to populate the 'Current Period Annual Fee' and 'Current Year Travel Fee' fields on Membership .
     *
     *  @args           :   List<SBQQ__Subscription__c> newSubscriptions, Map<Id,SBQQ__Subscription__c> oldMapSubscription
     *
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created - Subhash Garhwal - 07/12/2018 - CR-20180504-12213
     *                      V1.1 - Modified - Subhash Garhwal -06-26-2019 - CR-20190626-13196 - Added new check
     *                      V1.2 - Modified - Victor Hanson - 11/05/2019 - CR-20191031-13488 - Added to exclude global memberships from receiving annual/travel fees
     *                      V1.3 - Modified By - Neha Sharma - 5/21/21 - CR-20210113-14804 - 'Current Period Annual Fee' and 'Current Year Travel Fee' fields on Membership will be calculated by taking the SUM of all applicable customer amounts.
     *
     **/
    public static void updateCurrentYearFeesOnMembership(List<SBQQ__Subscription__c> newSubscriptions, Map<Id,SBQQ__Subscription__c> oldMapSubscription) {
    
        //List to hold the membership to be updated.
        List<Membership__c> membershipsToBeUpdated = new List<Membership__c>();
        
        Map<Id,List<SBQQ__Subscription__c>> mapOfProgSubsWithCompSubs = new Map<Id, List<SBQQ__Subscription__c>>();
        Set<Id> programSubscriptionIds = new set<Id>();
       
        
        //Loop over newSubscriptions
        for(SBQQ__Subscription__c sub : newSubscriptions) {
          
            //Check for Customer Amount
            if(sub.RecordTypeId == CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT 
                && sub.Program_Subscription__c != null && sub.SBQQ__Quantity__c != null && sub.SBQQ__CustomerPrice__c != null
                && sub.SBQQ__SegmentStartDate__c != null && sub.SBQQ__SegmentEndDate__c != null
                && sub.SBQQ__SegmentStartDate__c <= Date.today() && sub.SBQQ__SegmentEndDate__c >= Date.today() && sub.SBQQ__Product__c != null 
                && (oldMapSubscription == null
                  || oldMapSubscription.get(sub.Id).SBQQ__CustomerPrice__c != sub.SBQQ__CustomerPrice__c 
                  ||  oldMapSubscription.get(sub.Id).SBQQ__Quantity__c != sub.SBQQ__Quantity__c
                  ||  oldMapSubscription.get(sub.Id).SBQQ__Product__c != sub.SBQQ__Product__c
                  ||  oldMapSubscription.get(sub.Id).SBQQ__SegmentStartDate__c != sub.SBQQ__SegmentStartDate__c
                  ||  oldMapSubscription.get(sub.Id).SBQQ__SegmentEndDate__c != sub.SBQQ__SegmentEndDate__c)) {
                
                      if(sub.Program_Subscription__c != null && (sub.Product_Category__c == CPQConstants.PRODUCT_CATEGORY_ANNUAL_FEE || sub.Product_Category__c == CPQConstants.PRODUCT_CATEGORY_TRAVEL_FEE)){
                          programSubscriptionIds.add(sub.Program_Subscription__c);
                      }
            }
        }
        
        if(programSubscriptionIds.size() > 0){
           
           for(SBQQ__Subscription__c compSub : [Select Id,  SBQQ__Product__c, Product_Category__c,SBQQ__Product__r.Name, Customer_Amount__c, SBQQ__SegmentStartDate__c, 
                                                             SBQQ__SegmentEndDate__c, Program_Subscription__c From SBQQ__Subscription__c 
                                                             Where Program_Subscription__c != null AND Program_Subscription__c IN : programSubscriptionIds 
                                                             AND SBQQ__SegmentStartDate__c != null AND SBQQ__SegmentEndDate__c != Null AND SBQQ__Product__c != Null 
                                                             AND RecordType.DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT 
                                                               
                                                             ORDER BY SBQQ__SegmentStartDate__c ASC , Program_Subscription__c ASC])
           {
               if(!mapOfProgSubsWithCompSubs.containskey(compSub.Program_Subscription__c))
               {
                   mapOfProgSubsWithCompSubs.put(compSub.Program_Subscription__c,new List<SBQQ__Subscription__c>{});
               }
               mapOfProgSubsWithCompSubs.get(compSub.Program_Subscription__c).add(compSub);
           }
            
            List<Membership__c> membershipList = [Select Id, Current_Year_Annual_Fee__c, Current_Year_Travel_Fee__c, Membership_Status_Text__c,
                                                 Active_Subscription__c, Active_Subscription__r.SBQQ__Product__c 
                                                 From Membership__c 
                                    			 Where Active_Subscription__c IN : programSubscriptionIds];
            if(membershipList.size() > 0){
                for(Membership__c mem : membershipList)
                {
                    if(mem.Membership_Status_Text__c != Constants.MEMBER_PAYER_INTEGRATED_GLOBAL && mapOfProgSubsWithCompSubs.containskey(mem.Active_Subscription__c)){
                        
                        Decimal annualFeeAmount = 0.0;
                        Decimal travelFeeAmount = 0.0;
                        for(SBQQ__Subscription__c sub : mapOfProgSubsWithCompSubs.get(mem.Active_Subscription__c))
                        { 
                            if(sub.SBQQ__SegmentStartDate__c <= Date.today() && sub.SBQQ__SegmentEndDate__c >= Date.today()){
                                if(sub.Product_Category__c == CPQConstants.PRODUCT_CATEGORY_ANNUAL_FEE)
                                {
                                    annualFeeAmount += sub.Customer_Amount__c;
                                }
                                if(sub.Product_Category__c == CPQConstants.PRODUCT_CATEGORY_TRAVEL_FEE){
                                    travelFeeAmount += sub.Customer_Amount__c;
                                }
                                mem.Current_Period_Start_Date__c = sub.SBQQ__SegmentStartDate__c;
                                mem.Current_Period_End_Date__c = sub.SBQQ__SegmentEndDate__c;
                            }
                        }
                        if(annualFeeAmount > 0.0)
                        	mem.Current_Year_Annual_Fee__c = annualFeeAmount;
                        
                        if(travelFeeAmount > 0.0)
                        	mem.Current_Year_Travel_Fee__c = travelFeeAmount;
                        
                        membershipsToBeUpdated.add(mem);
                    }
                    else if(mem.Membership_Status_Text__c == Constants.MEMBER_PAYER_INTEGRATED_GLOBAL)
                    {
                       mem.Current_Year_Annual_Fee__c = null;
                       mem.Current_Year_Travel_Fee__c = null;
                       membershipsToBeUpdated.add(mem);
                    }
                }
            }												 
        }
        
         //Size check
        if(membershipsToBeUpdated.size() > 0) {
        
            //Enable all triggers
            Util.BypassAllTriggers = true;
        
            Util.ByPassDLRSMembershipTrigger = false;
        
            //Update Membership
            update membershipsToBeUpdated;
            
            Util.ByPassDLRSMembershipTrigger = true;
            
            //Enable all triggers
            Util.BypassAllTriggers = false;
        }
    }
    
    /**
     *  @description    :   Method is used to populate the 'Join Date-Most Recent' field on Membership .
     *
     *  @args           :   Map<Id,SBQQ__Subscription__c> newMapSubscription, Map<Id,SBQQ__Subscription__c> oldMapSubscription
     *
     *  @return         :   void
     *
     *  @Revision Log  	:   V1.0 - Created - Subhash Garhwal - 07/23/2018 - CR-20180607-12272
     * 		            V1.1 - Updated By- Mahendra Swarnkar - 05/01/2020 - CR-20191211-13560 - populate the Join_Date_Most_Recent__c field on membership with start date  on Subscription(SBQQ__StartDate__c)/Contract(Start__c) instead of join_date__c.
     * 			    V1.2 - Modified By- Mahendra Swarnkar - 05/22/2020 - CR-20191211-13560 - Commented out the logic to populate the Join_Date_Most_Recent__c field on membership.
     *
     **/
    public static void updateJoinDateMostRecentOnMembership(Map<Id,SBQQ__Subscription__c> newMapSubscription, Map<Id,SBQQ__Subscription__c> oldMapSubscription) {
      /*
      //Set to hold the Latest Subscription Ids
      Set<Id> setSubscriptionIdWithJoinDate = new Set<Id>();
      
      //Set to hold the Latest Contract Ids
      Set<Id> setSubscriptionIdWithoutJoinDate = new Set<Id>();
      
      //List of Membership to be updated
      List<Membership__c> membershipsToBeUpdated = new List<Membership__c>();
    
      //Loop over the new subscriptions
      for(SBQQ__Subscription__c sub : newMapSubscription.values()) {
        
        //Check for Join Date 
        if(sub.SBQQ__StartDate__c  != null && (oldMapSubscription == null || sub.SBQQ__StartDate__c != oldMapSubscription.get(sub.Id).SBQQ__StartDate__c ))
        
          //Add value into the set
          setSubscriptionIdWithJoinDate.add(sub.Id);
          
        else if(sub.SBQQ__StartDate__c == null & oldMapSubscription != null && sub.SBQQ__StartDate__c != oldMapSubscription.get(sub.Id).SBQQ__StartDate__c)
        
          setSubscriptionIdWithoutJoinDate.add(sub.Id);
      }
      
      //Size check
      if(setSubscriptionIdWithJoinDate.size() > 0 || setSubscriptionIdWithoutJoinDate.size() > 0) {
      
        //Query over Membership
	for(Membership__c mem : [Select Id, Join_Date_Most_Recent__c, Latest_Subscription__c, Latest_Contract__c, Latest_Contract__r.Start__c
				From Membership__c
				Where Latest_Subscription__c IN :  setSubscriptionIdWithJoinDate OR Latest_Subscription__c IN :  setSubscriptionIdWithoutJoinDate])  {
          
          //Check for subscription join date
          if(setSubscriptionIdWithJoinDate.contains(mem.Latest_Subscription__c))
          
            //Add value into the list 
            membershipsToBeUpdated.add(new Membership__c(Id = mem.Id, Join_Date_Most_Recent__c = newMapSubscription.get(mem.Latest_Subscription__c).SBQQ__StartDate__c));
        
          //Check for subscription join date updating to null
          else if(setSubscriptionIdWithoutJoinDate.contains(mem.Latest_Subscription__c) && mem.Latest_Contract__c != null && mem.Latest_Contract__r.Start__c != null)
          
            //Add value into the list 
            membershipsToBeUpdated.add(new Membership__c(Id = mem.Id, Join_Date_Most_Recent__c = mem.Latest_Contract__r.Start__c));
          
          //Check for subscription join date updating to null and contract Join date is null  
          else if(setSubscriptionIdWithoutJoinDate.contains(mem.Latest_Subscription__c) && (mem.Latest_Contract__c == null || mem.Latest_Subscription__r.SBQQ__StartDate__c == null))
          
            //Add value into the list 
            membershipsToBeUpdated.add(new Membership__c(Id = mem.Id, Join_Date_Most_Recent__c = null));
        }
      }
      
      //Size check
      if(membershipsToBeUpdated.size() > 0) {
      
        //Enable all triggers
        Util.BypassAllTriggers = true;
      
        //Update Membership
        update membershipsToBeUpdated;
        
        //Enable all triggers
        Util.BypassAllTriggers = false;
      }
       */
    }
    
    /**
    * 
    *   @description    :   If a Program Subscription is created as part of an amendment, reparent any Component Subscriptions to the newly created Program Subscription
    *
    *   @args           :   List<SBQQ__Subscription__c>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - 07/27/2018 - Created - Victor Hanson - CR-20180607-12270
    *            	    V1.2 - 12/05/2018 - Modified - Subhash Garhawal - CR-20181120-12756
    *            	    V1.3 - 02/15/2019 - Modified - Victor Hanson - CR-20190104-12807
    *            	    V1.4 - 08/09/2019 - Modified - Colin McGloin - CR-20190724-13232 - Commented out Revenue/LIS cloning
    * 
    **/
    /*public static void reparentComponentSubscriptionsOnAmendment(List<SBQQ__Subscription__c> subscriptions) {
        
        //get the program subscription record type id
        Id programSubRTId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        
        //Map to hold the contract and Program Subscription Ids
        Map<Id, Set<Id>> mapOfContractAndSubscriptions = new Map<Id, Set<Id>>();
        
        //check the Contract to determine if this is an Amendment
        Set<Id> contractIds = new Set<Id>();
        
        Set<Id> voidAmendedSubscriptionIds = new Set<Id>();
        
        //Loop over the Subscriptions
        for (SBQQ__Subscription__c sub : subscriptions) {
            
            //Commented/Added By mahendra Swarnkar - 09/19/2019 - Since componented are not reparenting in case of Amendement. Starts from Here
            if(sub.Status__c != null && sub.Status__c == 'Void-Amended' ) {
            
                contractIds.add(sub.SBQQ__Contract__c);
                voidAmendedSubscriptionIds.add(sub.Id); 
            }
        }
        
        Map<Id, SBQQ__Subscription__c> allContractSubs = new Map<Id, SBQQ__Subscription__c>();
        
        //Subhash Garhwal-12/05/2018 - Changes made for amendment issue
        //Query over the CPQ Subscriptions
        if(contractIds.size() > 0)
          allContractSubs = new Map<Id, SBQQ__Subscription__c>([SELECT Id, Name, RecordTypeId, SBQQ__Product__c, Program_Products__c, SBQQ__Contract__c, SBQQ__Quantity__c, CreatedDate, LastmodifiedDate,
                                                                                           Program_Subscription__c, Program_Subscription__r.SBQQ__Product__c, Program_Subscription__r.Program_Products__c
                                                                                           FROM SBQQ__Subscription__c 
                                                                                           WHERE SBQQ__Contract__c IN : contractIds
                                                                                           AND SBQQ__Contract__r.Status = 'Activated_Amended' ORDER BY CreatedDate DESC]);
        
        
        //Size check
        if (allContractSubs.size() > 0) {
            
            //Set save point to control the transaction
            //Savepoint sp = Database.setSavepoint();
            
            //try{
                                
                //Map to hold the cpq component subscriptions to update
                Map<Id, SBQQ__Subscription__c> mapComponentSubsToUpdate = new Map<Id, SBQQ__Subscription__c> (); 
                             
                //create a map to hold the most recently created ProgramSubscription map<uK, ProgramSubscription>
                Map<String, Id> keyToLatestProgramSubscriptionId = new Map<String, Id>();
                
                //Map to hold the latest program Subscription
                Map<Id, Id> mapOfLatestProgramSubscriptionIds = new Map<Id, Id>();
               
                //Set to hold the contract Ids
                Set<Id> setOfContractIds = new Set<Id>();
                
                //get subscriptions and create a map of most recent program subscriptions
                for (SBQQ__Subscription__c sub : allContractSubs.values()) {
                    
                    //Added condition that only commited Ammended subscriptions can be marked as latest subscriptions
                    if (sub.RecordTypeId == programSubRTId /*&& voidAmendedSubscriptionIds.size() > 0 && voidAmendedSubscriptionIds.contains(sub.Id)*/ /*){
                        if (!keyToLatestProgramSubscriptionId.containsKey(sub.SBQQ__Contract__c + '-' + sub.Program_Products__c)) {
                            keyToLatestProgramSubscriptionId.put(sub.SBQQ__Contract__c + '-' + sub.Program_Products__c, sub.Id);
                        }
                    }
                }
                
                //check if we need to move any component subscriptions to the newest program subscription
                for (SBQQ__Subscription__c sub : allContractSubs.values()) {
                  
                    if (sub.RecordTypeId != programSubRTId) {
                        
                        
                        //String uniqueKey = sub.Program_Subscription__c != null ? sub.SBQQ__Contract__c + '-' + sub.Program_Subscription__r.Program_Products__c : sub.SBQQ__Contract__c + '-' + sub.Program_Products__c; 
                        String uniqueKey = sub.SBQQ__Contract__c + '-' + sub.Program_Subscription__r.Program_Products__c; 
                        if (keyToLatestProgramSubscriptionId.containsKey(uniqueKey)) {
                            
                            Id latestProgramSubscription = keyToLatestProgramSubscriptionId.get(uniqueKey);
                            
                            //if the component subscription's program subscription isn't the latest, update it
                            if (sub.Program_Subscription__c != latestProgramSubscription) {
                                sub.Program_Subscription__c = latestProgramSubscription;
                                sub.Finance_Status__c = 'Inactive';
                                //sub.Type__c = 'Amendment- Re-engagement';
                                mapComponentSubsToUpdate.put(sub.Id, sub);
                            }
                        }
                    } 
                }

            	//Size Check
                if (mapComponentSubsToUpdate.size() > 0 && mapComponentSubsToUpdate.values() != null && mapComponentSubsToUpdate.values().size() > 0) {
                    util.bypassAllTriggers = true;
                    update mapComponentSubsToUpdate.values();
                    util.bypassAllTriggers = false;
                }
                
                
            //}catch(Exception e) {
            //    Database.rollback(sp);
            //    throw new customException(e.getMessage() + ' \r\n' + e.getStackTraceString());
            //}
        }
    }
    */
    
    /**
    * 
    *   @description    :   If a Program Subscription is created as part of an amendment, reparent any Component Subscriptions to the newly created Program Subscription
    *
    *   @args           :   List<SBQQ__Subscription__c>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - 11/27/2019 - Created -  Mahendra Swarnakr
    * 
    **/
    public static void reparentComponentSubscriptionsOnAmendmentFromCAtoVA(List<SBQQ__Subscription__c> subscriptions) {
        
        //get the program subscription record type id
        Id programSubRTId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        
        //Map to hold the contract and Program Subscription Ids
        Map<Id, Set<Id>> mapOfContractAndSubscriptions = new Map<Id, Set<Id>>();
        
        //Map to hold the cpq component subscriptions to update
        Map<Id, SBQQ__Subscription__c> mapComponentSubsToUpdate = new Map<Id, SBQQ__Subscription__c> ();
        
        //check the Contract to determine if this is an Amendment
        Set<Id> contractIds = new Set<Id>();
        
        //set of voidAmended
        Set<Id> voidAmendedSubscriptionIds = new Set<Id>();
        
        //Loop over the Subscriptions
        for(SBQQ__Subscription__c sub : subscriptions) {
            
            if(sub.Status__c != null && sub.Status__c == 'Void-Amended' ) {
                contractIds.add(sub.SBQQ__Contract__c);
                voidAmendedSubscriptionIds.add(sub.Id);
            }
        }
        
        //Loop over void-amended Subscription to make all the related component subscription, Finance_Status__c = 'Inactive'.
        for(SBQQ__Subscription__c sub : [Select Id, Program_Subscription__c, Finance_Status__c , Subscription_Period__c 
                                         From SBQQ__Subscription__c Where Program_Subscription__c IN :voidAmendedSubscriptionIds 
                                         And Finance_Status__c  = 'Active' ]){
            
            sub.Finance_Status__c = 'Inactive';
            //Modified by Subhash Garhwal - 02/03/2020 - Start here
            sub.Subscription_Period__c = null;
            //Modified by Subhash Garhwal - 02/03/2020 - End here
            mapComponentSubsToUpdate.put(sub.Id, sub);    
        }
        
        Map<Id, SBQQ__Subscription__c> allContractSubs = new Map<Id, SBQQ__Subscription__c>();
        
        //Query over the CPQ Subscriptions
        if(contractIds.size() > 0)
            allContractSubs = new Map<Id, SBQQ__Subscription__c>([SELECT Id, Name, RecordTypeId, SBQQ__Product__c, Program_Products__c, SBQQ__Contract__c, SBQQ__Quantity__c, CreatedDate, LastmodifiedDate,
                                                                  Program_Subscription__c, Program_Subscription__r.SBQQ__Product__c, Program_Subscription__r.Program_Products__c, Status__c, Subscription_Period__c,
                                                                  SBQQ__Product__r.Family, SBQQ__RequiredByProduct__c, SBQQ__Product__r.ProductCode, SBQQ__RequiredById__c
                                                                  FROM SBQQ__Subscription__c 
                                                                  WHERE SBQQ__Contract__c IN : contractIds
                                                                  AND SBQQ__Contract__r.Status = 'Activated_Amended' ORDER BY CreatedDate DESC]);
        
        //Size check
        if (allContractSubs.size() > 0) {
             
            //create a map to hold the most recently created ProgramSubscription map<uK, ProgramSubscription>
            Map<String, Id> keyToLatestProgramSubscriptionId = new Map<String, Id>();
            
            //Set to hold the contract Ids
            Set<Id> setOfContractIds = new Set<Id>();
            
            //Set of requireById
            Set<Id> setRequiredById = new Set<Id>();
            
            //get subscriptions and create a map of most recent program subscriptions
            for (SBQQ__Subscription__c sub : allContractSubs.values()) {
                
                //Added condition that only void-Ammended subscriptions can be marked as latest subscriptions
                if (sub.RecordTypeId == programSubRTId && voidAmendedSubscriptionIds.size() > 0 && voidAmendedSubscriptionIds.contains(sub.Id)) {
                    
                    if (!keyToLatestProgramSubscriptionId.containsKey(sub.SBQQ__Contract__c + '-' + sub.Program_Products__c)) {
                        keyToLatestProgramSubscriptionId.put(sub.SBQQ__Contract__c + '-' + sub.Program_Products__c, sub.Id);
                    }
                }
                
                if (sub.RecordTypeId != programSubRTId && sub.SBQQ__Quantity__c == -1) {
                    setRequiredById.add(sub.SBQQ__RequiredById__c);
                }
                
            }
            //List of program subscription with program product
            Map<Id,SBQQ__Subscription__c> mapProgramSubscriptions = new Map<Id,SBQQ__Subscription__c>([Select Id, Program_Products__c From SBQQ__Subscription__c Where Id IN :setRequiredById]);
                        
            for (SBQQ__Subscription__c sub : allContractSubs.values()) {
                //check if we need to move any component subscriptions to the newest program subscription
                if (sub.RecordTypeId != programSubRTId && sub.SBQQ__Quantity__c == -1) {
                    String uniqueKey = sub.SBQQ__RequiredById__c != null ? sub.SBQQ__Contract__c + '-' + mapProgramSubscriptions.get(sub.SBQQ__RequiredById__c).Program_Products__c : sub.SBQQ__Contract__c + '-' + sub.Program_Products__c; 
                    //String uniqueKey = sub.Program_Subscription__c != null ? sub.SBQQ__Contract__c + '-' + sub.Program_Subscription__r.Program_Products__c : sub.SBQQ__Contract__c + '-' + sub.Program_Products__c; 
                    //String uniqueKey = sub.SBQQ__Contract__c + '-' + sub.Program_Subscription__r.Program_Products__c; 
                    
                    if (keyToLatestProgramSubscriptionId.containsKey(uniqueKey)) {
                        Id latestProgramSubscription = keyToLatestProgramSubscriptionId.get(uniqueKey);
                        
                        //if the component subscription's program subscription isn't the latest, update it
                        if (/*sub.Program_Subscription__r.Status__c == 'Committed-Amended' &&*/ sub.Program_Subscription__c != latestProgramSubscription ) {
                            sub.Program_Subscription__c = latestProgramSubscription;
                            sub.Finance_Status__c = 'Inactive';
                            //Modified by Subhash Garhwal - 11/25/2019
                            //Modified by Subhash Garhwal - 02/03/2020 - Start here
                            sub.Subscription_Period__c = null;
                            //Modified by Subhash Garhwal - 02/03/2020 - End here
                            mapComponentSubsToUpdate.put(sub.Id, sub);
                        }
                    }
                } 
            }
            //System.assert(false,'mapComponentSubsToUpdate::::::' +mapComponentSubsToUpdate);
            //Size Check
            if (mapComponentSubsToUpdate.size() > 0 && mapComponentSubsToUpdate.values() != null && mapComponentSubsToUpdate.values().size() > 0) {
                util.bypassAllTriggers = true;
                update mapComponentSubsToUpdate.values();
                util.bypassAllTriggers = false;
            } 
        }
    }
    
  /**
     * 
     *   @description    :   If a Program Subscription is created as part of an amendment, then update the Program Subscription Status accordingly
     *			     And whenever status is 'Void-Amended' update Negotiated Amount on Invoice Billing Schedule and Shadow Contract ABC
     *
     *   @args           :   List<SBQQ__Subscription__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V_1.0 - Created - 09/25/2018 - Subhash Garhwal - CR-20180607-12270
     * 
     * 
     **/
  public static void updateStatusForAmendment(List<SBQQ__Subscription__c> subscriptions) {
        
      	//Set to hold the subscription Ids
        Set<Id> setOfSubscriptionIds = new Set<Id>();
        
        //Set to hold the Contract Ids
        Set<Id> setOfContractIds = new Set<Id>();
                
        //Set to hold the Upgraded Subscription Id on Proposal Lines
        Set<Id> SetOfUpgradedSubscriptionIds = new Set<Id>();
        
        //List to hold the Program Subscription to be updated
        List<SBQQ__Subscription__c> programSubscriptionsToBeUpdated = new List<SBQQ__Subscription__c>();
        
        //Loop over Program Subscription
        for(SBQQ__Subscription__c sub : subscriptions) {
            
            //Record Type check 
            if(sub.RecordTypeId == CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM ) {
            
                //Add Contract Ids into the set 
                setOfContractIds.add(sub.SBQQ__Contract__c);
                setOfSubscriptionIds.add(sub.Id);
            }
        }
        
    //Size Check 
        if(setOfContractIds.size() > 0) {
            
          //Map to hold the Contract Id and Product Id as unique key and its Program Subcription Where Status need to be updated.
          Map<String, List<SBQQ__Subscription__c>> mapOfContractIdAndProSubscriptions = new Map<String, List<SBQQ__Subscription__c>>();
            
      	 //Querey over the Standard Contract
         for(SBQQ__Subscription__c sub : [Select Id, RecordTypeId, SBQQ__Quantity__c, SBQQ__Contract__c, SBQQ__Contract__r.SBQQ__RenewalOpportunity__c, SBQQ__Product__c,Program_Products__c, Converted_Contract_ABC__c, Renewal_Opportunity__c
         				  From SBQQ__Subscription__c Where SBQQ__Contract__c IN : setOfContractIds 
                                          AND SBQQ__Contract__r.Status =: CPQConstants.CONTRACT_STATUS_ACTIVATED_AMENDED
                                          AND RecordTypeId =: CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM ORDER BY SBQQ__Contract__c, CreatedDate DESC]) {
                
                //Create a UK to idenfity the Parent
                String uniqueKey = sub.SBQQ__Contract__c + '-' + sub.Program_Products__c;
                
                //Check for Quantity
                if(sub.SBQQ__Quantity__c > 0) {
                    
                    if(!mapOfContractIdAndProSubscriptions.containsKey(uniqueKey)) {
                        
                        mapOfContractIdAndProSubscriptions.put(uniqueKey, new List<SBQQ__Subscription__c>());
                        
                        //Update Subscription Status 
                        sub.Status__c = 'Committed-Amended';
                        
                        //Update Renewal Opportunity
                        if(sub.Renewal_Opportunity__c == null && sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c != null)
                            sub.Renewal_Opportunity__c = sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c;
                        
                        //Add Sub in map
                        mapOfContractIdAndProSubscriptions.get(uniqueKey).add(sub);
                    
                        
          } else if(mapOfContractIdAndProSubscriptions.get(uniqueKey) != null && mapOfContractIdAndProSubscriptions.get(uniqueKey).size() == 1) {
                    	
                    	
                    	
                        //Add Progra Subscription into the map
                        sub.Status__c = 'Void-Amended';
                        sub.Negotiated_Amount_Subscription__c = 0;
              			
             		//Modified by - Mahendra  Swarnkar - CR-20190919-13356 - 09/25/2019 - added checke for Admin User
              		//Check for Current user profile and allow to update the  subscription type for Admin user only
              		if (UserInfo.getProfileId() == Label.System_Admin_Profile_Id) {
                        	sub.SBQQ__ProductSubscriptionType__c = 'One-time';
                        	sub.SBQQ__SubscriptionType__c = 'One-time';
                        }
              
                        //Update Renewal Opportunity
                        if(sub.Renewal_Opportunity__c == null && sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c != null)
                            sub.Renewal_Opportunity__c = sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c;
                        
                        mapOfContractIdAndProSubscriptions.get(uniqueKey).add(sub);
                    }
                } else {
                    
                    //Change Program Sub to Void
                    sub.Status__c = 'Void';
                    
                    //Add value into the list to be updated
                    programSubscriptionsToBeUpdated.add(sub);
                }
            }
            
            //Loop over the map to add the value into a single list to update the Program Subscription.
            for(String uK: mapOfContractIdAndProSubscriptions.KeySet()){
                
                //Size check
                if(mapOfContractIdAndProSubscriptions.get(uK).size() > 1)
                
                    //Add Values into the list
                    programSubscriptionsToBeUpdated.addAll(mapOfContractIdAndProSubscriptions.get(uK));
                    
                else if(mapOfContractIdAndProSubscriptions.get(uK).size() == 1 && setOfSubscriptionIds.contains(mapOfContractIdAndProSubscriptions.get(uK)[0].Id))
                
                    //Add Values into the list
                    programSubscriptionsToBeUpdated.addAll(mapOfContractIdAndProSubscriptions.get(uK));
            }
        }
        
        //Size Check
        if (programSubscriptionsToBeUpdated.size() > 0) { 
            
            //SBQQ_SubscriptionTriggerHelper.reparentComponentSubscriptionsOnAmendment(programSubscriptionsToBeUpdated);
            
            SBQQ_SubscriptionTriggerHelper.reparentComponentSubscriptionsOnAmendmentFromCAtoVA(programSubscriptionsToBeUpdated);
            SBQQ_SubscriptionTriggerHelper.updateContractABC(programSubscriptionsToBeUpdated, null);
            
            util.bypassAllTriggers = true;
            update programSubscriptionsToBeUpdated;
            util.bypassAllTriggers = false;
        }
    }
    
    /**
    * 
    *   @description    :   Method to update the 'Converted Contract ABC' From 'Void-Amended' to 'Committed-Amended' Program Subscription 
    *
    *   @args           :   List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> oldMapSubscription
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created - 09/25/2018 - Subhash Garhwal - CR-20180607-12270
    * 
    **/
    public static void updateContractABC(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> oldMapSubscription) {
    
        //Set to hold the Contract Ids
        Set<Id> setOfContractIds = new Set<Id>();
        
        //Set to hold the Program Ids
        Set<Id> setOfProductIds = new Set<Id>();
        
        //Map to hold the Contract and Program as a unique key and Program Subscription.
        Map<String, SBQQ__Subscription__c> mapOfProgramContractAndSubs = new Map<String, SBQQ__Subscription__c>();
    
        //List to hold the Program Subscriptions to be updated 
        List<SBQQ__Subscription__c> programSubscriptionsToUpdate = new List<SBQQ__Subscription__c>();
    
        //Loop over the subscriptions
        for(SBQQ__Subscription__c sub : subscriptions) {
            
            //Check if  'Converted Contract ABC' is updating on Program Subscription.
            if(sub.Converted_Contract_ABC__c != null && sub.Status__c != null && sub.Status__c == 'Void-Amended'
                && (oldMapSubscription == null || sub.Converted_Contract_ABC__c != oldMapSubscription.get(sub.Id).Converted_Contract_ABC__c)) {
                
                //Add value into the set
                setOfContractIds.add(sub.SBQQ__Contract__c);
                setOfProductIds.add(sub.SBQQ__Product__c);
                
                //Put value into the map.
                mapOfProgramContractAndSubs.put(sub.SBQQ__Contract__c + '-' + sub.Program_Products__c, sub);
            }
        }   
        //Size Check
        if(setOfContractIds.size() > 0 && setOfProductIds.size() > 0 && mapOfProgramContractAndSubs.size() > 0)
        
            //Loop over the Program Subscriptions
            for(SBQQ__Subscription__c sub : [Select Id, SBQQ__Contract__c, SBQQ__Product__c, Program_Products__c, Status__c From SBQQ__Subscription__c Where SBQQ__Contract__c IN : setOfContractIds
                                             AND SBQQ__Product__c IN : setOfProductIds AND SBQQ__Contract__r.Status =: CPQConstants.CONTRACT_STATUS_ACTIVATED_AMENDED 
                                             AND SBQQ__Quantity__c > 0 AND Status__c != 'Void-Amended'
                                             AND RecordTypeId =: CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM ORDER BY SBQQ__Contract__c, CreatedDate DESC]) {
                                                
                //Check for unique key
                if(mapOfProgramContractAndSubs.containsKey(sub.SBQQ__Contract__c + '-' + sub.Program_Products__c)) {
                    
                    //Add value into the list to be updated 
                    programSubscriptionsToUpdate.add(new SBQQ__Subscription__c(Id = sub.Id, Converted_Contract_ABC__c = mapOfProgramContractAndSubs.get(sub.SBQQ__Contract__c + '-' + sub.Program_Products__c).Converted_Contract_ABC__c));
                }                                   
            }
        
        //Size Check
        if(programSubscriptionsToUpdate.size() > 0) {
            
            util.bypassAllTriggers = true;
            update programSubscriptionsToUpdate;
            util.bypassAllTriggers = false;
        }
    }
    
    /**
    *   @Description    :   This method is to Calcuate the Next Decission Date on the Membership.
    *
    *   @args           :   List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> oldMapSubscription
    *
    *   @return         :   void
    *
    *   @Revision Log   :   V1.1 - Created - 12/03/2018 - Subhash Garhwal - CR-20180726-12469
    *
    **/
    public static void calculateNextDecisionDate(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> oldMapSubscription) {
    
        Map<Id, Membership__c> mapMemberships = New Map<Id, Membership__c>();
        
        //Loop over the subscriptions
        for(SBQQ__Subscription__c sub : subscriptions) {
            
            //Check if Early_Termination_Date__c is cchanged
            if(sub.recordTypeId == CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM 
                && sub.Membership__c != null
                && (oldMapSubscription == null || (sub.Early_Termination_Date__c != oldMapSubscription.get(sub.Id).Early_Termination_Date__c
                                  && sub.Membership__c != oldMapSubscription.get(sub.Id).Membership__c))) {
                
                if(!mapMemberships.containsKey(sub.Membership__c))
                    mapMemberships.put(sub.Membership__c, New Membership__c(Id = sub.Membership__c, Next_Decision_Date__c = null));
            }
        }
        
        if(mapMemberships.size() > 0) {
            
            //Method call
            mapMemberships = SubscriptionPeriodTriggerHelper.calculateNextDecisionDate(mapMemberships);
            
            //Check for size
            if(mapMemberships != null && mapMemberships.size() > 0 && mapMemberships.values().size() > 0 ){
            
                //disable all triggers to execute
                Util.BypassAllTriggers = true;
                
                // Update Memberships
                update mapMemberships.values();
                
                //Enable all trigger 
                Util.BypassAllTriggers = false; 
            }
        }
    }
    
    /**
     *  @Description    :   This method is used to sync Custom Amout details on Program Packages
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
     *
     *  @return         :   void
     *
     *  @Revision Log   :   V1.1 - Created - 01/11/2019 - Subhash Garhwal - CR-20181019-12685
     *           	:   V1.2 - Modified By -  Mahendra Swarnkar - 04/03/2019 - CR-20181019-12685
     *
    **/
    public static void syncProgramPackages(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> oldMapSubscription) {
        
        //Added by Subhash Garhwal - 01/17/2020
        //Set to hold the Subscription Period Ids
        Set<Id> setSubscriptionPeriodIds = new Set<Id>();
        
        //Map to hold the Membership Periods
        Map<Id, Program_Package__c> mapMembershipPeriods = new Map<Id, Program_Package__c>();
        
        //Loop over the Subscriptions
        for(SBQQ__Subscription__c subscription : subscriptions) {
            
            //Updated By Mahendra Swarnkar - 04/03/2019 - CR-20181019-12685 - to include the Postage cost and media cost fields in the conditions
            //Check appropriate condition to execute trigger
            if((oldMapSubscription == null /*&& subscription.Membership_Period__c != null*/ 
                && ((subscription.Customer_Amount__c != null && subscription.Customer_Amount__c > 0)
                  || (subscription.Postage_Costs_m__c != null && subscription.Postage_Costs_m__c > 0)
                  || (subscription.Media_Costs_m__c != null && subscription.Media_Costs_m__c > 0)
                  || (subscription.Paper_New_Names_m__c != null && subscription.Paper_New_Names_m__c > 0)
                  || (subscription.Paper_Inquiry_Pool_m__c != null && subscription.Paper_Inquiry_Pool_m__c > 0)
                  || (subscription.Paper_PRE_Names_m__c != null && subscription.Paper_PRE_Names_m__c > 0)
                  || (subscription.E_Only_New_Names_m__c != null && subscription.E_Only_New_Names_m__c > 0)
                  || (subscription.E_Only_Inquiry_Pool_m__c != null && subscription.E_Only_Inquiry_Pool_m__c > 0)
                  || (subscription.E_Only_PRE_Names_m__c != null && subscription.E_Only_PRE_Names_m__c > 0)
                  ))
                || (oldMapSubscription != null && (subscription.Membership_Period__c != oldMapSubscription.get(subscription.Id).Membership_Period__c
                    || subscription.Customer_Amount__c != oldMapSubscription.get(subscription.Id).Customer_Amount__c
                    || subscription.Postage_Costs_m__c != oldMapSubscription.get(subscription.Id).Postage_Costs_m__c
                    || subscription.Media_Costs_m__c != oldMapSubscription.get(subscription.Id).Media_Costs_m__c
                    || subscription.Paper_New_Names_m__c != oldMapSubscription.get(subscription.Id).Paper_New_Names_m__c
                    || subscription.Paper_Inquiry_Pool_m__c != oldMapSubscription.get(subscription.Id).Paper_Inquiry_Pool_m__c
                    || subscription.Paper_PRE_Names_m__c != oldMapSubscription.get(subscription.Id).Paper_PRE_Names_m__c
                    || subscription.E_Only_New_Names_m__c != oldMapSubscription.get(subscription.Id).E_Only_New_Names_m__c
                    || subscription.E_Only_Inquiry_Pool_m__c != oldMapSubscription.get(subscription.Id).E_Only_Inquiry_Pool_m__c
                    || subscription.E_Only_PRE_Names_m__c != oldMapSubscription.get(subscription.Id).E_Only_PRE_Names_m__c
					|| subscription.Subscription_Period__c != oldMapSubscription.get(subscription.Id).Subscription_Period__c
                    ))
            ) {
                        
                //Check membership period
                if(subscription.Membership_Period__c != null)
                    mapMembershipPeriods.put(subscription.Membership_Period__c, new Program_Package__c(Id = subscription.Membership_Period__c, Total_Contracted_Program_Annual_Cost__c = 0,
                                                                                     Total_Contracted_Postage_Cost_CPQ__c = 0, Total_Contracted_Media_Cost_CPQ__c = 0,
                                                                                     Total_Contracted_Contact_Qty_CPQ__c = 0));
                
                //Check for old Sp
                if(oldMapSubscription != null && oldMapSubscription.get(subscription.Id).Membership_Period__c != null)
                    mapMembershipPeriods.put(oldMapSubscription.get(subscription.Id).Membership_Period__c, new Program_Package__c(Id = oldMapSubscription.get(subscription.Id).Membership_Period__c, Total_Contracted_Program_Annual_Cost__c = 0,
                                                                                     Total_Contracted_Postage_Cost_CPQ__c = 0, Total_Contracted_Media_Cost_CPQ__c = 0,
                                                                                     Total_Contracted_Contact_Qty_CPQ__c = 0));  
                
                //Added by Subhash Garhwal - 01/17/2020 - Start Here
		if(subscription.Membership_Period__c == null && subscription.Subscription_Period__c != null  
                   	//&& subscription.SBQQ__ProductName__c == 'Program Costs'
                   	&& CPQConstants.CPQ_ES_PRODUCT_CODES.contains(subscription.Product_Code__c)
                  	&& subscription.RecordTypeId == Constants.RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT){
                	setSubscriptionPeriodIds.add(subscription.Subscription_Period__c);
                }
                //Added by Subhash Garhwal - 01/17/2020 - End Here
            }
        }
        //Added by Subhash Garhwal - 01/17/2020 - Start Here
        if(setSubscriptionPeriodIds.size() > 0) {
            
            //Set of membershipId
            Set<Id> setMembershipIds = new Set<Id>();
            
            //Set of Fiscal Year
            Set<String> setFiscalYears = new Set<String>();
            
            //Get all the Subscription Periods
            for(Subscription_Period__c subPeriod : [Select Id, Program_Subscription__c, Program_Subscription__r.Membership__c, Period_End_Date__c From Subscription_Period__c Where Id IN : setSubscriptionPeriodIds]){
                
                //Check for end date and populate the set
                if(subPeriod.Period_End_Date__c != null)
                	setFiscalYears.add( String.valueOf((subPeriod.Period_End_Date__c).year()));
                
                //Check for Membership and populate the set
                if(subPeriod.Program_Subscription__c != null && subPeriod.Program_Subscription__r.Membership__c != null)
                	setMembershipIds.add(subPeriod.Program_Subscription__r.Membership__c);
            }
            
            //Check for size
            if(setMembershipIds.size() > 0 && setFiscalYears.size() > 0) {
                
                //Get all the Membership periods with matching membership periods and fiscal year
                for(Program_Package__c programPackage : [SELECT Id FROM Program_Package__c WHERE Membership__c IN : setMembershipIds AND Fiscal_Year__c IN : setFiscalYears]) {
                    //Populate the map
                    mapMembershipPeriods.put(programPackage.Id, new Program_Package__c(Id = programPackage.Id, Total_Contracted_Program_Annual_Cost__c = 0, 
                                                                           Total_Contracted_Postage_Cost_CPQ__c = 0, Total_Contracted_Media_Cost_CPQ__c = 0,
                                                                           Total_Contracted_Contact_Qty_CPQ__c = 0));
            	}
            }
        }
        //Added by Subhash Garhwal - 01/17/2020 - End Here
        
        //Check Membership Periods
        if(mapMembershipPeriods.size() > 0) {
            ProgramPackageRoyallTriggerHelper.populateRollUpFields(mapMembershipPeriods);
        }
    }
    
    /**
     *  @Description    :   This method is used to sync  Total_Contract_Quantity__c field on the Subscription Period
     *
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
     *
     *  @return         :   void
     *
     *  @Revision Log   :   V1.1 - Created - 01/23/2019 - Subhash Garhwal - CR-20181019-12685
     *             	    V1.2 - Updated By Mahendra Swarnkar - 03/25/2019 - CR-20181019-12685 - populate the fields on SP "Total_Paper_only_Contract_Quantity__c" and "Total_e_only_Contract_Quantity__c"
     *             	    V1.3 - Updated By Victor Hanson - 04/03/2019 - CR-20181019-12685 - populate Total_Program_Cost__c, Total_Postage_Cost__c, Total_Media_Cost__c
     * 			    V1.4 - Updated By Victor Hanson - 09/04/2019 - CR-20190904-13310 - added quantity to the contract/paper/e-only quantity calculations below
     *			    V1.5 - Modified By - Subhash Garhwal - 8/31/2020 - CR-20200825-14471 - Added logic to update the ESYRS Logic
     *			            Logic Details:
     *			            On the Subscription Period for New Names (ESYRS only) — Change the roll ups for Total (Paper only) Contract Quantity, Total (e-only) Contract Quantity so that instead of rolling up values from just Paper New Names and E-only New Names it should roll up All Paper, E-only fields for New Names, Inquiry Pool and Pre Names
     *			    	    On the Subscription Period for Inquiry Pool and Pre Names (ESYRS only) --- Change the roll ups for Total (Paper only) Contract Quantity and Total (e-only) Contract Quantity to show 0
     *
    **/
    public static void syncTotalContractQuantity(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
        
        //Map to update the Subscription Periods
        Map<Id, Subscription_Period__c> mapSubscriptionPeriods = new Map<Id, Subscription_Period__c>();
        
        //Set to hold the COntract Id
        Set<Id> setContractIds = new Set<Id>();
        
        //Loop over the Subscriptions
        for(SBQQ__Subscription__c subsc : subscriptions != null ? subscriptions : mapOldSubscriptions.values()) {
            
            //Add Contract Id in set
            setContractIds.add(subsc.SBQQ__Contract__c);
            
            //Check for appropriate condition to execute logic
            
            //Insert case
            if(mapOldSubscriptions == null && subsc.Subscription_Period__c != null)
                mapSubscriptionPeriods.put(subsc.Subscription_Period__c, new Subscription_Period__c(Id = subsc.Subscription_Period__c, 
                                                                                                    Total_Contract_Quantity__c = 0, 
                                                                                                    Total_e_only_Contract_Quantity__c = 0, 
                                                                                                    Total_Paper_only_Contract_Quantity__c = 0,
                                                                                                    Total_Program_Cost__c = 0,
                                                                                                    Total_Postage_Cost__c = 0,
                                                                                                    Total_Media_Cost__c = 0));
            
            //Update Case
            if(mapOldSubscriptions != null && subscriptions != null && (subsc.Subscription_Period__c != mapOldSubscriptions.get(subsc.Id).Subscription_Period__c
                || subsc.Paper_New_Names_m__c != mapOldSubscriptions.get(subsc.Id).Paper_New_Names_m__c || subsc.E_Only_New_Names_m__c != mapOldSubscriptions.get(subsc.Id).E_Only_New_Names_m__c
                || subsc.Paper_Inquiry_Pool_m__c != mapOldSubscriptions.get(subsc.Id).Paper_Inquiry_Pool_m__c || subsc.E_Only_Inquiry_Pool_m__c != mapOldSubscriptions.get(subsc.Id).E_Only_Inquiry_Pool_m__c
                || subsc.Paper_PRE_Names_m__c != mapOldSubscriptions.get(subsc.Id).Paper_PRE_Names_m__c || subsc.E_Only_PRE_Names_m__c != mapOldSubscriptions.get(subsc.Id).E_Only_PRE_Names_m__c
                || subsc.Paper_Quantity_Fulfillment_m__c != mapOldSubscriptions.get(subsc.Id).Paper_Quantity_Fulfillment_m__c || subsc.E_Only_Quantity_Fulfillment_m__c != mapOldSubscriptions.get(subsc.Id).E_Only_Quantity_Fulfillment_m__c
                || subsc.Paper_Transfer_Marketing_m__c != mapOldSubscriptions.get(subsc.Id).Paper_Transfer_Marketing_m__c || subsc.E_Only_Transfer_Marketing_m__c != mapOldSubscriptions.get(subsc.Id).E_Only_Transfer_Marketing_m__c
                || subsc.Media_Costs_m__c != mapOldSubscriptions.get(subsc.Id).Media_Costs_m__c || subsc.Postage_Costs_m__c != mapOldSubscriptions.get(subsc.Id).Postage_Costs_m__c
                || subsc.SBQQ__CustomerPrice__c != mapOldSubscriptions.get(subsc.Id).SBQQ__CustomerPrice__c
                || subsc.E_Only_Client_Provided_Inquiries_m__c != mapOldSubscriptions.get(subsc.Id).E_Only_Client_Provided_Inquiries_m__c || subsc.E_Only_EAB_Generated_Inquiries_m__c != mapOldSubscriptions.get(subsc.Id).E_Only_EAB_Generated_Inquiries_m__c
                || subsc.Paper_Client_Provided_Inquiries_m__c != mapOldSubscriptions.get(subsc.Id).Paper_Client_Provided_Inquiries_m__c || subsc.Paper_EAB_Generated_Inquiries_m__c != mapOldSubscriptions.get(subsc.Id).Paper_EAB_Generated_Inquiries_m__c)) {
                    
                
                //Check for new Subscription Period
                if(subsc.Subscription_Period__c != null)
                    mapSubscriptionPeriods.put(subsc.Subscription_Period__c, new Subscription_Period__c(Id = subsc.Subscription_Period__c, 
                                                                                                        Total_Contract_Quantity__c = 0, 
                                                                                                        Total_e_only_Contract_Quantity__c = 0, 
                                                                                                        Total_Paper_only_Contract_Quantity__c = 0,
                                                                                                        Total_Program_Cost__c = 0,
                                                                                                        Total_Postage_Cost__c = 0,
                                                                                                        Total_Media_Cost__c = 0));
                
                //CR-20210715-15290 - Mahendra Swarnkar - 07/15/2021 - Added the fields Total_Program_Cost__c,Total_Postage_Cost__c,Total_Media_Cost__c for the SP in the map.
                //Check for hold SP
                if(subsc.Subscription_Period__c != mapOldSubscriptions.get(subsc.Id).Subscription_Period__c && mapOldSubscriptions.get(subsc.Id).Subscription_Period__c != null)            
                    mapSubscriptionPeriods.put(mapOldSubscriptions.get(subsc.Id).Subscription_Period__c, new Subscription_Period__c(Id = mapOldSubscriptions.get(subsc.Id).Subscription_Period__c, Total_Contract_Quantity__c = 0, Total_e_only_Contract_Quantity__c = 0, Total_Paper_only_Contract_Quantity__c = 0, Total_Program_Cost__c = 0, Total_Postage_Cost__c = 0, Total_Media_Cost__c = 0)); 
            }
            
            //Delete case
            if(subscriptions == null && subsc.Subscription_Period__c != null)
                mapSubscriptionPeriods.put(subsc.Subscription_Period__c, new Subscription_Period__c(Id = subsc.Subscription_Period__c, 
                                                                                                    Total_Contract_Quantity__c = 0, 
                                                                                                    Total_e_only_Contract_Quantity__c = 0, 
                                                                                                    Total_Paper_only_Contract_Quantity__c = 0,
                                                                                                    Total_Program_Cost__c = 0,
                                                                                                    Total_Postage_Cost__c = 0,
                                                                                                    Total_Media_Cost__c = 0));
        }
        
        //Check for map size
        if(mapSubscriptionPeriods.size() > 0) {
            
            //Map to hold the Product Names with relate field names to update the Contracted Contact Qty field
            Map<String, Set<String>> mapProductsWithRelatedFields = CPQConstants.MAP_PRODUCTS_WITH_SUB_FIELD_DETAILS;
            
            //8/31/2020 - Subhash Garhwal - CR-20200825-14471 - Added logic to update the ESYRS Logic
            
            //Map to hold the ESYRS related SubscriptionPeriods Details
            Map<String, Id> mapSubscriptionPeriodsWithESYRSProduct = new Map<String, Id>();
            
            //Map to hold the ROllup of the All Paper, E-only fields for New Names, Inquiry Pool and Pre Names
            Map<String, Decimal> mapPaperAndEOnlyFieldsRollupsWithESYRSProduct = new Map<String,Decimal>();
            
            //SOQL over the Component Subscription
            for(SBQQ__Subscription__c compSub : [Select Id, Subscription_Period__c, Subscription_Period__r.Period_Start_Date__c, Paper_New_Names_m__c, E_Only_New_Names_m__c, Paper_Inquiry_Pool_m__c,
                                                 E_Only_Inquiry_Pool_m__c, Paper_PRE_Names_m__c, E_Only_PRE_Names_m__c, Related_Product__c,
                                                 Paper_Quantity_Fulfillment_m__c, E_Only_Quantity_Fulfillment_m__c, SBQQ__Quantity__c,
                                                 Paper_Transfer_Marketing_m__c, E_Only_Transfer_Marketing_m__c, Program_Subscription__r.SBQQ__ProductName__c,Program_Subscription__r.Program_Subscription__r.Product_Code__c,
                                                 Media_Costs_m__c, Postage_Costs_m__c, SBQQ__ListPrice__c, SBQQ__CustomerPrice__c, E_Only_Client_Provided_Inquiries_m__c,
                                                 E_Only_EAB_Generated_Inquiries_m__c, Paper_Client_Provided_Inquiries_m__c, Paper_EAB_Generated_Inquiries_m__c, SBQQ__ProductName__c
                                                 FROM SBQQ__Subscription__c
                                                 WHERE Program_Subscription__r.SBQQ__ProductName__c IN : mapProductsWithRelatedFields.keySet() 
                                                 AND SBQQ__Contract__c IN : setContractIds AND Subscription_Period__c != null
                                                 AND Program_Subscription__r.SBQQ__ProductName__c != null /*AND SBQQ__Quantity__c > 0 */ AND Status__c != 'Void-Amended'
                                                 AND RecordTypeId =: CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT]) 
            {
                //Check Subscription Period in map
                if(!mapSubscriptionPeriods.containsKey(compSub.Subscription_Period__c))
                    mapSubscriptionPeriods.put(compSub.Subscription_Period__c, new Subscription_Period__c(Id = compSub.Subscription_Period__c, Total_Contract_Quantity__c = 0,Total_e_only_Contract_Quantity__c = 0, 
											                                                                                                    Total_Paper_only_Contract_Quantity__c = 0,
											                                                                                                    Total_Program_Cost__c = 0,
											                                                                                                    Total_Postage_Cost__c = 0,
											                                                                                                    Total_Media_Cost__c = 0));
                
                //populate Total Program/Postage/Media
                if(compSub.SBQQ__CustomerPrice__c != null && mapSubscriptionPeriods.containsKey(compSub.Subscription_Period__c))
                    mapSubscriptionPeriods.get(compSub.Subscription_Period__c).Total_Program_Cost__c += compSub.SBQQ__CustomerPrice__c;
                
                if(compSub.Postage_Costs_m__c != null && mapSubscriptionPeriods.containsKey(compSub.Subscription_Period__c))
                    mapSubscriptionPeriods.get(compSub.Subscription_Period__c).Total_Postage_Cost__c += compSub.Postage_Costs_m__c;
                
                if(compSub.Media_Costs_m__c != null && mapSubscriptionPeriods.containsKey(compSub.Subscription_Period__c))
                    mapSubscriptionPeriods.get(compSub.Subscription_Period__c).Total_Media_Cost__c += compSub.Media_Costs_m__c;
                
                //Check Product in map
                if(mapProductsWithRelatedFields.containsKey(compSub.Program_Subscription__r.SBQQ__ProductName__c)) {
                    
                    //Modified by Victor Hanson - 09/04/2019 - CR-20190904-13310 - added quantity to the contract/paper/e-only quantity calculations below
                    //Loop over the fields
                    for(String productSpecField : mapProductsWithRelatedFields.get(compSub.Program_Subscription__r.SBQQ__ProductName__c)) { 
                    	
                    	//8/31/2020 - Subhash Garhwal - CR-20200825-14471 - Added logic to update the ESYRS Logic
                    	//Check for ESYRS Product
                    	if(compSub.Program_Subscription__r.Program_Subscription__c != null && compSub.Program_Subscription__r.Program_Subscription__r.Product_Code__c == 'ESYRS'
                    		&& CPQConstants.SET_ESYRS_SUB_PRODUCTS.contains(compSub.Program_Subscription__r.SBQQ__ProductName__c)) {
                    		
                    		//Unique Key to add the details in map
                    		String eSYRSWithYear = compSub.Program_Subscription__r.Program_Subscription__c + '-' +compSub.Program_Subscription__r.Program_Subscription__r.Product_Code__c + '-' + compSub.Subscription_Period__r.Period_Start_Date__c;
                    		
                    		//Check value in map
                    		if(!mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.containsKey(eSYRSWithYear + ' - PaperOnly'))
                    			mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.put(eSYRSWithYear + ' - PaperOnly',0);
							
				//Check value in map
                    		if(!mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.containsKey(eSYRSWithYear + ' - EOnly'))
                    			mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.put(eSYRSWithYear + ' - EOnly',0);
                    		
                    		//Check for field value
                    		if(CPQConstants.PAPER_ONLY_FIELDS.contains(productSpecField) && compSub.get(productSpecField) != null)
                    			mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.put(eSYRSWithYear + ' - PaperOnly', mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.get(eSYRSWithYear + ' - PaperOnly') + ((Decimal) compSub.get(productSpecField) * (Decimal) compSub.get('SBQQ__Quantity__c')));
				
				//Check for field value
                    		if(CPQConstants.E_ONLY_FIELDS.contains(productSpecField) && compSub.get(productSpecField) != null)
                    			mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.put(eSYRSWithYear + ' - EOnly', mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.get(eSYRSWithYear + ' - EOnly') + ((Decimal) compSub.get(productSpecField) * (Decimal) compSub.get('SBQQ__Quantity__c')));
                    		
                    		//Check for Sub Product
                    		if(compSub.Program_Subscription__r.SBQQ__ProductName__c == 'New Names – Search')
                    			mapSubscriptionPeriodsWithESYRSProduct.put(eSYRSWithYear, compSub.Subscription_Period__c);
                    			
                    	} else {
                    		
                    		//Check field value
	                        if(compSub.get(productSpecField) != null && mapSubscriptionPeriods.containsKey(compSub.Subscription_Period__c))
	                            mapSubscriptionPeriods.get(compSub.Subscription_Period__c).Total_Contract_Quantity__c += ((Decimal) compSub.get(productSpecField) * (Decimal) compSub.get('SBQQ__Quantity__c'));
	                        
	                        //Added By Mahendra Swarnkar - 03/25/2019 - CR-20181019-12685 - Starts from here
	                        //Check field value 
	                        if(CPQConstants.PAPER_ONLY_FIELDS.contains(productSpecField) && compSub.get(productSpecField) != null && mapSubscriptionPeriods.containsKey(compSub.Subscription_Period__c))
	                            mapSubscriptionPeriods.get(compSub.Subscription_Period__c).Total_Paper_only_Contract_Quantity__c += ((Decimal) compSub.get(productSpecField) * (Decimal) compSub.get('SBQQ__Quantity__c'));
	                        
	                        //Check field value
	                        if(CPQConstants.E_ONLY_FIELDS.contains(productSpecField) && compSub.get(productSpecField) != null && mapSubscriptionPeriods.containsKey(compSub.Subscription_Period__c))
	                            mapSubscriptionPeriods.get(compSub.Subscription_Period__c).Total_e_only_Contract_Quantity__c += ((Decimal) compSub.get(productSpecField) * (Decimal) compSub.get('SBQQ__Quantity__c'));
	                        //Added By Mahendra Swarnkar - 03/25/2019 - CR-20181019-12685 - Ends here	 
                    	}
                    }
                }
            }
	    
            //Loop over the ESYRS Specific Products
            for(String eSYRSProd : mapSubscriptionPeriodsWithESYRSProduct.keySet()) {
            	
            	//Instance of the Subscription Period
            	Subscription_Period__c sP = new Subscription_Period__c(Id = mapSubscriptionPeriodsWithESYRSProduct.get(eSYRSProd));
            	
            	//Check if map already contansSP to update
            	if(mapSubscriptionPeriods.containsKey(mapSubscriptionPeriodsWithESYRSProduct.get(eSYRSProd)))
            		sP = mapSubscriptionPeriods.get(mapSubscriptionPeriodsWithESYRSProduct.get(eSYRSProd));
            	
            	//Set Paper only quantity
            	if(mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.containsKey(eSYRSProd + ' - PaperOnly')) {
            		
            		//Set Paper field value
            		sP.Total_Paper_only_Contract_Quantity__c = mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.get(eSYRSProd + ' - PaperOnly');
            		sP.Total_Contract_Quantity__c += mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.get(eSYRSProd + ' - PaperOnly');
            	}
            	
            	//Set E-Only only quantity
            	if(mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.containsKey(eSYRSProd + ' - EOnly')) {
            		
            		//Set Paper field value
            		sP.Total_e_only_Contract_Quantity__c = mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.get(eSYRSProd + ' - EOnly');
            		sP.Total_Contract_Quantity__c += mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.get(eSYRSProd + ' - EOnly');
            	}
            	//Put SP in Map to update
            	mapSubscriptionPeriods.put(sP.Id, sP);
            }
            
            //Disable all triggers
            //Util.BypassAllTriggers = true;
            
            //Update Program Package
            update mapSubscriptionPeriods.values();
            
            //Enable all triggers 
            //Util.BypassAllTriggers = false;
        }
    }
    
    /**
     *  @description    :   This method is used to populate 'Previous Year - Program Cost (CPQ)[Previous_Year_Program_Cost_CPQ__c]', 'Current Year - Program Cost (CPQ)[Current_Year_Program_Cost_CPQ__c]', 'Next Year - Program Cost (CPQ)[Next_Year_Program_Cost_CPQ__c]', with the program cost from related SP's
     * 
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
     *
     *  @return         :   void
     *
     *  @Version        :   V1.0 - Created By - Subhash Garhawal - 01/30/2018 - CR-20181019-12685
    **/
    public static void populatePreviousCurrentNextYearProgramCost(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
        
        //set to hold the subscription period Ids
        Set<Id> setSubscriptionPeriodIds = new Set<Id>();
        
        //Loop over the Subscription 
        for(SBQQ__Subscription__c sub : subscriptions != null ? subscriptions : mapOldSubscriptions.values()) {
            
            //Check for record Type
            if(sub.RecordTypeId == CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT){
            
                //Insert Case/Delete case
                if((mapOldSubscriptions == null || subscriptions == null ) && sub.Subscription_Period__c != null)
                    setSubscriptionPeriodIds.add(sub.Subscription_Period__c);
                    
                //Check for update case
                if(subscriptions != null && mapOldSubscriptions != null && (sub.Subscription_Period__c != mapOldSubscriptions.get(sub.Id).Subscription_Period__c || sub.Customer_Amount__c != mapOldSubscriptions.get(sub.Id).Customer_Amount__c)) {
                    
                    //Check for new Membership
                    if(sub.Subscription_Period__c != null)
                        setSubscriptionPeriodIds.add(sub.Subscription_Period__c);
                    
                    //CHeck for hold membership
                    if(mapOldSubscriptions.get(sub.Id).Subscription_Period__c != null && sub.Subscription_Period__c != mapOldSubscriptions.get(sub.Id).Subscription_Period__c)
                        setSubscriptionPeriodIds.add(mapOldSubscriptions.get(sub.Id).Subscription_Period__c);
                }   
            }
        }
        
        //Check memberships
        if(setSubscriptionPeriodIds.size() > 0) {
            
            //Map to hold the Memberships
            Map<Id, Membership__c> mapMemberships = new Map<Id, Membership__c>();
                
            
            //Populate the set Membershipids 
            for(Subscription_Period__c sp :[Select Id, Membership_Lookup__c from Subscription_Period__c where ID IN : setSubscriptionPeriodIds AND Membership_Lookup__c != null] ){
                mapMemberships.put(sp.Membership_Lookup__c, new Membership__c(Id = sp.Membership_Lookup__c, Previous_Year_Program_Cost_CPQ__c = 0, Current_Year_Program_Cost_CPQ__c = 0, Next_Year_Program_Cost_CPQ__c = 0));
            }
            
            //Check for size
            if(mapMemberships.size() > 0){
            
                //10/27/2020 - CR-20201013-14598 - Victor Hanson - modified query with reference to the cost product codes
                //SOQL over the Component Subscriptions
                for(SBQQ__Subscription__c compSub : [Select Id, Customer_Amount__c, Subscription_Period__r.Membership_Lookup__c, Subscription_Period__r.Period_Start_Date__c,
                                                            Subscription_Period__r.Period_End_Date__c From SBQQ__Subscription__c
                                                            Where RecordTypeId =: CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT AND Product_Code__c IN :CPQConstants.CPQ_ES_PRODUCT_CODES
                                                            AND Subscription_Period__r.Membership_Lookup__c IN : mapMemberships.keySet() AND Customer_Amount__c > 0]) {
                    
                    //11/05/2020 - CR-20201013-14598 - Victor Hanson - if statements below to fix a bug
                    //Check for SP Start and End Date and Add values on Membership
                    if(compSub.Subscription_Period__r.Period_End_Date__c != null && compSub.Subscription_Period__r.Period_End_Date__c < Date.today() && compSub.Subscription_Period__r.Period_End_Date__c > Date.today().addYears(-1))
                        mapMemberships.get(compSub.Subscription_Period__r.Membership_Lookup__c).Previous_Year_Program_Cost_CPQ__c += compSub.Customer_Amount__c;
                    else if(compSub.Subscription_Period__r.Period_Start_Date__c != null && compSub.Subscription_Period__r.Period_Start_Date__c > Date.today() && compSub.Subscription_Period__r.Period_Start_Date__c < Date.today().addYears(1))
                        mapMemberships.get(compSub.Subscription_Period__r.Membership_Lookup__c).Next_Year_Program_Cost_CPQ__c += compSub.Customer_Amount__c;
                    else if (compSub.Subscription_Period__r.Period_End_Date__c != null && compSub.Subscription_Period__r.Period_Start_Date__c != null && compSub.Subscription_Period__r.Period_Start_Date__c <= Date.today() && compSub.Subscription_Period__r.Period_End_Date__c >= Date.today())
                        mapMemberships.get(compSub.Subscription_Period__r.Membership_Lookup__c).Current_Year_Program_Cost_CPQ__c += compSub.Customer_Amount__c;
                }
                
                //Check for size
                if(mapMemberships.size() > 0) {
                    
                    //Bypass all triggers
                    Util.BypassAllTriggers = true;
                    
                    //Update Memberships
                    update mapMemberships.values();
                    
                    //Enable all triggers
                    Util.BypassAllTriggers = false;
                }
            }
        }   
    }
    
    public static void populateAmendmentPriceOverride(List<SBQQ__Subscription__c> subscriptions) {
        
        //map of all Component Subscriptions by ParentProduct/Product/SegmentIndex
        Map<String, Decimal> mapUKToTotalPrice = new Map<String, Decimal>();
        
        Set<Id> subscriptionPeriodIds = new Set<Id>();
        List<SBQQ__Subscription__c> allSubscriptions = new List<SBQQ__Subscription__c>();
        List<SBQQ__Subscription__c> subscriptionToUpdate = new List<SBQQ__Subscription__c>();
        
        //get all other subscritions for these Products/Segments
        for (SBQQ__Subscription__c sub : subscriptions) {
          
          //02/19/2019 - Subhash Garhwal - Added Null check
          if(sub.Subscription_Period__c != null)
              subscriptionPeriodIds.add(sub.Subscription_Period__c);
        }
        
        //Check subscription periods
        if(subscriptionPeriodIds.size() > 0) {
        
        Map<Id, SBQQ__Subscription__c> existingSubMap = new Map<Id, SBQQ__Subscription__c>([SELECT Id, SBQQ__SegmentIndex__c,Top_Parent_Product__c, SBQQ__RequiredByProduct__c, 
                                                                                              SBQQ__Product__c, Subscription_Period__c, SBQQ__CustomerPrice__c, Amendment_Price_Override_m__c
                                                                                              FROM SBQQ__Subscription__c 
                                                                                              WHERE Id NOT IN :subscriptions AND Subscription_Period__c IN :subscriptionPeriodIds]);
          allSubscriptions.addAll(subscriptions);
          allSubscriptions.addAll(existingSubMap.values());
          
          //populate the map of uKey to List Subscriptions
          for (SBQQ__Subscription__c sub : allSubscriptions) {
              
              //get unique key
              String uk = getUK(sub);
              Decimal tempTotal = mapUKToTotalPrice.get(uk);
              
              //add the customer price
              if (tempTotal == null) tempTotal = 0;
              
              if (sub.SBQQ__CustomerPrice__c != null)
                  tempTotal += sub.SBQQ__CustomerPrice__c;
              
              mapUKToTotalPrice.put(uk, tempTotal);
          }
          
          for (SBQQ__Subscription__c sub : subscriptions) {
              if (sub.Amendment_Price_Override_m__c != mapUKToTotalPrice.get(getUK(sub))) {
                  sub.Amendment_Price_Override_m__c = mapUKToTotalPrice.get(getUK(sub));
              }
          }
          
          /*for (SBQQ__Subscription__c sub : allSubscriptions) {
              if (sub.Amendment_Price_Override__c != mapUKToTotalPrice.get(getUK(sub))) {
                  sub.Amendment_Price_Override__c = mapUKToTotalPrice.get(getUK(sub));
                  //if this is an existing subscriptions that are not part of the trigger context, add to the list to update
                  if (existingSubMap.containsKey(sub.Id) && sub.Id != null && sub.Type__c != 'Upsell') {
                      subscriptionToUpdate.add(sub);
                  }
              }
          }
          
          if (subscriptionToUpdate.size() > 0) {
              util.BypassAllTriggers = true;
              try{
                  database.update(subscriptionToUpdate, false);
              }
              catch (Exception e) {
                  
              }
              util.BypassAllTriggers = false;
          }*/      
          
        }
    }
    
    public static String getUK(SBQQ__Subscription__c sub) {
        
        return sub.Subscription_Period__c + '-' + sub.Top_Parent_Product__c + '-' + sub.SBQQ__RequiredByProduct__c + '-' + sub.SBQQ__Product__c + '-' + sub.SBQQ__SegmentIndex__c;
        
    }
    
    /**
     *  @description    :   This method is used to rollup the data from Component Subscription's Direct Parent Program Subscription
     *                      Moved These DLRS to trigger
     *                      Rollup Total Annual PI on Program Sub
     *                      Rollup_Comp_To_Program_Subscription
     *                      Rollup_List_Price_to_Pro_Sub
     *                      Rollup_Setup_In_Negotiated_To_Prob_Subs  
     * 
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
     *
     *  @return         :   void
     *
     *  @Version        :   V1.0 - Created By - Subhash Garhawal - 02/22/2018 - CR-20181019-12685
     *                      V1.1 - Modified By - Colin McGloin - 08/29/2019 - CR-20190829-13298 - Commented out Finance Status as a criteria in AggregateResult and removed Insert only logic for GAAP_Negotiated_Amount__c, GAAP_Negotiated_Amount_Postage_Cost__c, GAAP_Negotiated_Amount_Media_Cost__c
     *                      V1.2 - Modified By - Colin McGloin - 05/28/2020 - CR-20200415-13946 - Negative values are possible in fields so removing criteria where it must be greater than 0
     *
    **/
    public static void rollupDetailsonProgramSubscriptionFromComponentSubscription(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
    
        //flag to check insert case
        Boolean isInsertCase = ((mapOldSubscriptions == null || SBQQ_SubscriptionTriggerHelper.IS_INSERT_CASE) && !SubscriptionAdjustmentHelper.BYPASS_GAAP_NEGOTIATION_AMOUNT_POSTAGE_MEDIA) ? true : false;
        
        //Map to hold the ultimate Program Subscription values
        Map<Id, SBQQ__Subscription__c> mapProgramSubscriptions = new Map<Id, SBQQ__Subscription__c>();
      
        //Loop over the subscriptions
        for(SBQQ__Subscription__c subsc : subscriptions != null ? subscriptions : mapOldSubscriptions.values()) {
        	

            //Insert and delete case
            if(((mapOldSubscriptions == null && subsc.Program_Subscription__c != null && subsc.RecordTypeId == CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT)
                || (subscriptions == null && subsc.Program_Subscription__c != null && subsc.RecordTypeId == CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT))
                && ((subsc.Setup_in_Negotiated__c != null) || (subsc.SBQQ__ListPrice__c != null)
                    || (subsc.Customer_Amount__c != null) || (subsc.Component_PI__c != null)
                    || (subsc.Postage_Costs_m__c != null)
                    || (subsc.Media_Costs_m__c != null))) 
            {
                mapProgramSubscriptions.put(subsc.Program_Subscription__c, new SBQQ__Subscription__c(Id = subsc.Program_Subscription__c, Total_Annual_PI__c = 0, Negotiated_Amount_Subscription__c = 0,
                                                        SBQQ__ListPrice__c = 0, Setup_in_Negotiated__c = 0, Negotiated_Amt_CPQ_Subs_Postage_Cost__c = 0, Negotiated_Amt_CPQ_Subs_Media_Cost__c = 0));                                  
            }
      
            //Update Case
            if(mapOldSubscriptions != null && subscriptions != null != null && subsc.RecordTypeId == CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT
                && (subsc.Program_Subscription__c != mapOldSubscriptions.get(subsc.Id).Program_Subscription__c
                    || subsc.RecordTypeId != mapOldSubscriptions.get(subsc.Id).RecordTypeId
                    || subsc.Setup_in_Negotiated__c != mapOldSubscriptions.get(subsc.Id).Setup_in_Negotiated__c
                    || subsc.SBQQ__ListPrice__c != mapOldSubscriptions.get(subsc.Id).SBQQ__ListPrice__c
                    || subsc.Customer_Amount__c != mapOldSubscriptions.get(subsc.Id).Customer_Amount__c
                    || subsc.Component_PI__c != mapOldSubscriptions.get(subsc.Id).Component_PI__c
                    || subsc.Postage_Costs_m__c != mapOldSubscriptions.get(subsc.Id).Postage_Costs_m__c
                    || subsc.Media_Costs_m__c != mapOldSubscriptions.get(subsc.Id).Media_Costs_m__c)) 
            {
            
                //Check for Ultimate Program Subscription
                if(subsc.Program_Subscription__c != null)
                    mapProgramSubscriptions.put(subsc.Program_Subscription__c, new SBQQ__Subscription__c(Id = subsc.Program_Subscription__c, Total_Annual_PI__c = 0, Negotiated_Amount_Subscription__c = 0, SBQQ__ListPrice__c = 0, Setup_in_Negotiated__c = 0, Negotiated_Amt_CPQ_Subs_Postage_Cost__c = 0, Negotiated_Amt_CPQ_Subs_Media_Cost__c = 0));
            
                //Check old Ultimate Program Subscription
                if(subsc.Program_Subscription__c != mapOldSubscriptions.get(subsc.Id).Program_Subscription__c && mapOldSubscriptions.get(subsc.Id).Program_Subscription__c != null)
                    mapProgramSubscriptions.put(mapOldSubscriptions.get(subsc.Id).Program_Subscription__c, new SBQQ__Subscription__c(Id = mapOldSubscriptions.get(subsc.Id).Program_Subscription__c, Total_Annual_PI__c = 0, Negotiated_Amount_Subscription__c = 0, SBQQ__ListPrice__c = 0, Setup_in_Negotiated__c = 0, Negotiated_Amt_CPQ_Subs_Postage_Cost__c = 0, Negotiated_Amt_CPQ_Subs_Media_Cost__c = 0));
            }
        }
        //Check if Program Membership need to update
        if(mapProgramSubscriptions.size() > 0) {
      
            //Updated By Mahendra Swarnkar - 04/03/2019 - CR-20181019-12685 - Comment out the Postage cost and media cost product code check
            //Aggregate SOQL over the Component Subscriptions
            for(AggregateResult aR : [Select Program_Subscription__c proSub, SUM(Customer_Amount__c) custAmout, SUM(SBQQ__ListPrice__c) listPri,
                                             SUM(Postage_Costs_m__c) postageCost, SUM(Media_Costs_m__c) mediaCost From SBQQ__Subscription__c
                                                Where Program_Subscription__c IN : mapProgramSubscriptions.keySet() AND RecordTypeId =: CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT
                                                /*AND SBQQ__Quantity__c > 0 AND Finance_Status__c = 'Active'*/ GROUP BY Program_Subscription__c]) {
          
                //Get Program Subscriptin Id
                Id proSubId = (Id) String.valueOf(ar.get('proSub'));
          
                //Check Id in Parent map
                if(mapProgramSubscriptions.containsKey(proSubId)) {
            
                    //Get Program Subscription
                    SBQQ__Subscription__c programSub = mapProgramSubscriptions.get(proSubId);
              
                    //Update rollup details on fields
                    programSub.Negotiated_Amount_Subscription__c = (Decimal) ar.get('custAmout');
                    programSub.SBQQ__ListPrice__c = (Decimal) ar.get('listPri');
                    programSub.Negotiated_Amt_CPQ_Subs_Postage_Cost__c = (Decimal) ar.get('postageCost');
                    programSub.Negotiated_Amt_CPQ_Subs_Media_Cost__c = (Decimal) ar.get('mediaCost');
                    
                    
                    
                    
                    //Check for Insert case.
                    //Removed Insert only logic - CR-20190829-13298
                    //if(isInsertCase){
                        
                        programSub.GAAP_Negotiated_Amount__c = (Decimal) ar.get('custAmout');
                        programSub.GAAP_Negotiated_Amount_Postage_Cost__c = (Decimal) ar.get('postageCost');
                        programSub.GAAP_Negotiated_Amount_Media_Cost__c = (Decimal) ar.get('mediaCost');
                    //}
                    
                    //Add Reocrd in map
                    mapProgramSubscriptions.put(proSubId,programSub);
                }                   
            }
        
            //SOQL over the Component Subscriptions to get the calculate Setup_in_Negotiated__c and Total_Annual_PI__c on Program Subscription
            for(SBQQ__Subscription__c compSub : [Select Id, Program_Subscription__c, Component_PI__c, Setup_in_Negotiated__c, Product_Category__c, Product_Code__c
                                                        From SBQQ__Subscription__c Where Program_Subscription__c IN : mapProgramSubscriptions.keySet()
                                                        AND RecordTypeId =: CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT
                                                        AND (Product_Category__c = 'Implementation Fee' OR Product_Code__c = 'AnnualFee')]) {
            
                //Check Program Subscription in map
                if(mapProgramSubscriptions.containsKey(compSub.Program_Subscription__c)) {
              
                    //Check Implementation Fee Product and add amount
                    if(compSub.Product_Category__c == 'Implementation Fee' && compSub.Setup_in_Negotiated__c != null)
                        mapProgramSubscriptions.get(compSub.Program_Subscription__c).Setup_in_Negotiated__c += compSub.Setup_in_Negotiated__c;
              
                    //Check Annual Fee Product and add amount
                    if(compSub.Product_Code__c == 'AnnualFee' && compSub.Component_PI__c != null)
                        mapProgramSubscriptions.get(compSub.Program_Subscription__c).Total_Annual_PI__c += compSub.Component_PI__c;   
                }                                
            }
        
            //Bypass all triggers
            Util.BypassAllTriggers = true;

            //Set Contract ABC Sync Flag
            SYNC_SHADOW_ABC_WITH_SUBSCRIPTION = true;
        
            //Update Ultimate Program Subscription records
            update mapProgramSubscriptions.values();

            //Set Flag back to False
            SYNC_SHADOW_ABC_WITH_SUBSCRIPTION = false;
        
            //Resume all triggers
            Util.BypassAllTriggers = false;
          
            //Code to perform update on Ultimate Parent Program Subscription and Std. Contract
          
            //List of Program Subscriptions
            List<SBQQ__Subscription__c> programSubscriptions = [Select Id, Name, Program_Subscription__c, RecordTypeId, GAAP_Amount_Rev_Rec__c, Line_Item_Schedule_Total_Subscription__c, Recognized_to_Date_Negotiated__c,
                                         Negotiated_Amount_Subscription_Rev_Rec__c, Negotiated_Amount_Subscription__c, Recognized_to_Date_GAAP__c,
                                         Secured_Amount_GAAP__c, Secured_Amount_Negotiated__c, Setup_in_Negotiated__c, Total_Annual_PI__c, SBQQ__ListPrice__c, Negotiated_Amt_CPQ_Subs_Postage_Cost__c,
                                         Negotiated_Amt_CPQ_Subs_Media_Cost__c, GAAP_Negotiated_Amount_Postage_Cost__c, GAAP_Negotiated_Amount_Media_Cost__c, GAAP_Negotiated_Amount__c From SBQQ__Subscription__c
                                         Where Id IN : mapProgramSubscriptions.keySet() AND Program_Subscription__c != null AND RecordType.DeveloperName = 'Program'];
										 
            //Call Ultimate Parent method to update details on ultimate parent
            if(programSubscriptions.size() > 0)
                rollupDetailsOnUltimateProgramSubscriptionFromDirectProgramSubs(programSubscriptions, null);
          
            else if(programSubscriptions.size() == 0) {
            
                //SOQL over the Program Subscription
                List<SBQQ__Subscription__c> directProgramSubscriptions = [Select Id, Name, SBQQ__Contract__c, RecordTypeId, Customer_Amount__c, Amount_Credited_Total__c,
                                            Credit_Note_Total__c, Deferred_Revenue_GAAP__c, Deferred_Revenue_Negotiated__c, GAAP_Amount_Rev_Rec__c,
                                            GAAP_Negotiated_Amount__c, Invoice_Total__c, SBQQ__ListPrice__c, Negotiated_Amount_Subscription__c,
                                            Negotiated_Amount_Subscription_Rev_Rec__c, Net_Invoiced__c, Recognized_to_Date_Negotiated__c, 
                                            Recognized_to_Date_GAAP__c, Secured_Amount_GAAP__c, Secured_Amount_Negotiated__c, Setup_in_Negotiated__c,Negotiated_Amt_CPQ_Subs_Postage_Cost__c,
                                            Negotiated_Amt_CPQ_Subs_Media_Cost__c, GAAP_Negotiated_Amount_Postage_Cost__c, GAAP_Negotiated_Amount_Media_Cost__c From SBQQ__Subscription__c
                                            Where Id IN : mapProgramSubscriptions.keySet() AND Program_Subscription__c = null AND RecordType.DeveloperName = 'Program'];
        
                //Call Std. Contract method
                if(directProgramSubscriptions.size() > 0)
                    populateStdContractFields(directProgramSubscriptions, null);
            }
        }
    }
    
    
    /**
     *  @description    :   This method is used to rollup the data from Component Subscription's Direct Parent Program Subscription to Ultimate Program Subscription
     * 
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
     *
     *  @return         :   void
     *
     *  @Version        :   V1.0 - Created By - Subhash Garhawal - 02/12/2018 - CR-20181019-12685
     *
    **/
    public static void rollupDetailsOnUltimateProgramSubscriptionFromDirectProgramSubs(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
      
        //Map to hold the ultimate Program Subscription values
        Map<Id, SBQQ__Subscription__c> mapUltimateProgramSubscriptions = new Map<Id, SBQQ__Subscription__c>();
    
        //Loop over the subscriptions
        for(SBQQ__Subscription__c subsc : subscriptions != null ? subscriptions : mapOldSubscriptions.values()) {
      
            //Insert case/Delete case
            if(((mapOldSubscriptions == null && subsc.Program_Subscription__c != null && subsc.RecordTypeId == CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM)
                || (subscriptions == null && subsc.Program_Subscription__c != null && subsc.RecordTypeId == CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM))
                && ((subsc.GAAP_Amount_Rev_Rec__c != null && subsc.GAAP_Amount_Rev_Rec__c > 0) || (subsc.Line_Item_Schedule_Total_Subscription__c != null && subsc.Line_Item_Schedule_Total_Subscription__c > 0)
                    || (subsc.Recognized_to_Date_Negotiated__c != null && subsc.Recognized_to_Date_Negotiated__c > 0) || (subsc.Negotiated_Amount_Subscription_Rev_Rec__c != null && subsc.Negotiated_Amount_Subscription_Rev_Rec__c > 0)
                    || (subsc.Negotiated_Amount_Subscription__c != null && subsc.Negotiated_Amount_Subscription__c >= 0) || (subsc.Recognized_to_Date_GAAP__c != null && subsc.Recognized_to_Date_GAAP__c > 0)
                    || (subsc.Secured_Amount_GAAP__c != null && subsc.Secured_Amount_GAAP__c > 0) || (subsc.Secured_Amount_Negotiated__c != null && subsc.Secured_Amount_Negotiated__c > 0)
                    || (subsc.Setup_in_Negotiated__c != null && subsc.Setup_in_Negotiated__c > 0) || (subsc.Total_Annual_PI__c != null && subsc.Total_Annual_PI__c > 0)
                    || (subsc.SBQQ__ListPrice__c != null && subsc.SBQQ__ListPrice__c > 0) || (subsc.Negotiated_Amt_CPQ_Subs_Postage_Cost__c != null && subsc.Negotiated_Amt_CPQ_Subs_Postage_Cost__c > 0)
                    || (subsc.Negotiated_Amt_CPQ_Subs_Media_Cost__c != null && subsc.Negotiated_Amt_CPQ_Subs_Media_Cost__c > 0)
                    || (subsc.GAAP_Negotiated_Amount_Postage_Cost__c != null && subsc.GAAP_Negotiated_Amount_Postage_Cost__c > 0)
                    || (subsc.GAAP_Negotiated_Amount_Media_Cost__c != null && subsc.GAAP_Negotiated_Amount_Media_Cost__c > 0)
                    || (subsc.GAAP_Negotiated_Amount__c != null && subsc.GAAP_Negotiated_Amount__c > 0) ))
                
                mapUltimateProgramSubscriptions.put(subsc.Program_Subscription__c, new SBQQ__Subscription__c(Id = subsc.Program_Subscription__c, GAAP_Amount_Rev_Rec__c = 0,
                            Line_Item_Schedule_Total_Subscription__c = 0, Recognized_to_Date_Negotiated__c = 0, Negotiated_Amount_Subscription_Rev_Rec__c = 0,
                            Negotiated_Amount_Subscription__c = 0, Recognized_to_Date_GAAP__c = 0, Secured_Amount_GAAP__c = 0,
                            Secured_Amount_Negotiated__c = 0, Setup_in_Negotiated__c = 0, Total_Annual_PI__c = 0, SBQQ__ListPrice__c = 0,
                            Negotiated_Amt_CPQ_Subs_Postage_Cost__c = 0, Negotiated_Amt_CPQ_Subs_Media_Cost__c = 0,
                            GAAP_Negotiated_Amount_Postage_Cost__c = 0, GAAP_Negotiated_Amount_Media_Cost__c = 0, GAAP_Negotiated_Amount__c = 0));
        
            //Update Case
            if(mapOldSubscriptions != null && subscriptions != null && subsc.RecordTypeId == CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM
                && (subsc.Program_Subscription__c != mapOldSubscriptions.get(subsc.Id).Program_Subscription__c || subsc.GAAP_Amount_Rev_Rec__c != mapOldSubscriptions.get(subsc.Id).GAAP_Amount_Rev_Rec__c
                || subsc.Line_Item_Schedule_Total_Subscription__c != mapOldSubscriptions.get(subsc.Id).Line_Item_Schedule_Total_Subscription__c
                || subsc.Recognized_to_Date_Negotiated__c != mapOldSubscriptions.get(subsc.Id).Recognized_to_Date_Negotiated__c
                || subsc.Negotiated_Amount_Subscription_Rev_Rec__c != mapOldSubscriptions.get(subsc.Id).Negotiated_Amount_Subscription_Rev_Rec__c
                || subsc.Negotiated_Amount_Subscription__c != mapOldSubscriptions.get(subsc.Id).Negotiated_Amount_Subscription__c
                || subsc.Recognized_to_Date_GAAP__c != mapOldSubscriptions.get(subsc.Id).Recognized_to_Date_GAAP__c
                || subsc.Secured_Amount_GAAP__c != mapOldSubscriptions.get(subsc.Id).Secured_Amount_GAAP__c
                || subsc.Secured_Amount_Negotiated__c != mapOldSubscriptions.get(subsc.Id).Secured_Amount_Negotiated__c
                || subsc.Setup_in_Negotiated__c != mapOldSubscriptions.get(subsc.Id).Setup_in_Negotiated__c
                || subsc.Total_Annual_PI__c != mapOldSubscriptions.get(subsc.Id).Total_Annual_PI__c
                || subsc.SBQQ__ListPrice__c != mapOldSubscriptions.get(subsc.Id).SBQQ__ListPrice__c
                || subsc.Negotiated_Amt_CPQ_Subs_Postage_Cost__c != mapOldSubscriptions.get(subsc.Id).Negotiated_Amt_CPQ_Subs_Postage_Cost__c
                || subsc.Negotiated_Amt_CPQ_Subs_Media_Cost__c != mapOldSubscriptions.get(subsc.Id).Negotiated_Amt_CPQ_Subs_Media_Cost__c
                || subsc.GAAP_Negotiated_Amount_Postage_Cost__c != mapOldSubscriptions.get(subsc.Id).GAAP_Negotiated_Amount_Postage_Cost__c
                || subsc.GAAP_Negotiated_Amount_Media_Cost__c != mapOldSubscriptions.get(subsc.Id).GAAP_Negotiated_Amount_Media_Cost__c
                || subsc.GAAP_Negotiated_Amount__c != mapOldSubscriptions.get(subsc.Id).GAAP_Negotiated_Amount__c)) {
              
      
                //Check for Ultimate Program Subscription
                if(subsc.Program_Subscription__c != null)
                    mapUltimateProgramSubscriptions.put(subsc.Program_Subscription__c, new SBQQ__Subscription__c(Id = subsc.Program_Subscription__c, GAAP_Amount_Rev_Rec__c = 0,
                                  Line_Item_Schedule_Total_Subscription__c = 0, Recognized_to_Date_Negotiated__c = 0, Negotiated_Amount_Subscription_Rev_Rec__c = 0,
                                  Negotiated_Amount_Subscription__c = 0, Recognized_to_Date_GAAP__c = 0, Secured_Amount_GAAP__c = 0,
                                  Secured_Amount_Negotiated__c = 0, Setup_in_Negotiated__c = 0, Total_Annual_PI__c = 0, SBQQ__ListPrice__c = 0,
                                  Negotiated_Amt_CPQ_Subs_Postage_Cost__c = 0, Negotiated_Amt_CPQ_Subs_Media_Cost__c = 0,
                                  GAAP_Negotiated_Amount_Postage_Cost__c = 0, GAAP_Negotiated_Amount_Media_Cost__c = 0, GAAP_Negotiated_Amount__c = 0));
              
                //Check old Ultimate Program Subscription
                if(subsc.Program_Subscription__c != mapOldSubscriptions.get(subsc.Id).Program_Subscription__c && mapOldSubscriptions.get(subsc.Id).Program_Subscription__c != null)
                    mapUltimateProgramSubscriptions.put(mapOldSubscriptions.get(subsc.Id).Program_Subscription__c, new SBQQ__Subscription__c(Id = mapOldSubscriptions.get(subsc.Id).Program_Subscription__c, GAAP_Amount_Rev_Rec__c = 0,
                                  Line_Item_Schedule_Total_Subscription__c = 0, Recognized_to_Date_Negotiated__c = 0, Negotiated_Amount_Subscription_Rev_Rec__c = 0,
                                  Negotiated_Amount_Subscription__c = 0, Recognized_to_Date_GAAP__c = 0, Secured_Amount_GAAP__c = 0,
                                  Secured_Amount_Negotiated__c = 0, Setup_in_Negotiated__c = 0, Total_Annual_PI__c = 0, SBQQ__ListPrice__c = 0,
                                  Negotiated_Amt_CPQ_Subs_Postage_Cost__c = 0, Negotiated_Amt_CPQ_Subs_Media_Cost__c = 0,
                                  GAAP_Negotiated_Amount_Postage_Cost__c = 0, GAAP_Negotiated_Amount_Media_Cost__c = 0, GAAP_Negotiated_Amount__c = 0));
            }
        }
        //Check fir Ultimate Program Subscription
        if(mapUltimateProgramSubscriptions.size() > 0) {
        
            //Aggregate SOQL over the First Level Parent (Direct Parent of Comp. Subsscriptions)
            for(AggregateResult aR : [Select Program_Subscription__c uPS, SUM(GAAP_Amount_Rev_Rec__c) gARR, SUM(Line_Item_Schedule_Total_Subscription__c) lTSTS, SUM(Recognized_to_Date_Negotiated__c) rTDN,
                                             SUM(Negotiated_Amount_Subscription_Rev_Rec__c) nASRR, SUM(Negotiated_Amount_Subscription__c) nAS, SUM(Recognized_to_Date_GAAP__c) rTDG, SUM(Secured_Amount_GAAP__c) sAG,
                                             SUM(Secured_Amount_Negotiated__c) sAN, SUM(Setup_in_Negotiated__c)  sIN, SUM(Total_Annual_PI__c) tAPI, SUM(SBQQ__ListPrice__c) listPrice,
                                             SUM(Negotiated_Amt_CPQ_Subs_Postage_Cost__c) postageCost, SUM(Negotiated_Amt_CPQ_Subs_Media_Cost__c) mediaCost,
                                             SUM(GAAP_Negotiated_Amount_Postage_Cost__c) gaapPostageCost, SUM(GAAP_Negotiated_Amount_Media_Cost__c) gaapMediaCost, SUM(GAAP_Negotiated_Amount__c) gaapNegotiatedAmount From SBQQ__Subscription__c
                                             Where Program_Subscription__c IN : mapUltimateProgramSubscriptions.keySet() AND RecordTypeId =: CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM
                                             AND Program_Subscription__r.Program_Subscription__c = null AND Program_Subscription__r.RecordTypeId =: CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM
                                             GROUP BY Program_Subscription__c]) {
          
                //Get Ultimate Parent Id
                Id uParentPSId = (Id) String.valueOf(ar.get('uPS'));
          
                //Check Id in Ultimate Parent map
                if(mapUltimateProgramSubscriptions.containsKey(uParentPSId)) {
            
                    //Get Ultimate Program Subscription
                    SBQQ__Subscription__c ultimatePS = mapUltimateProgramSubscriptions.get(uParentPSId);
            
                    //Update rollup details on fields
                    ultimatePS.GAAP_Amount_Rev_Rec__c = (Decimal) ar.get('gARR');
                    ultimatePS.Line_Item_Schedule_Total_Subscription__c = (Decimal) ar.get('lTSTS');
                    ultimatePS.Recognized_to_Date_Negotiated__c = (Decimal) ar.get('rTDN');
                    ultimatePS.Negotiated_Amount_Subscription_Rev_Rec__c = (Decimal) ar.get('nASRR');
                    ultimatePS.Negotiated_Amount_Subscription__c = (Decimal) ar.get('nAS');
                    ultimatePS.Recognized_to_Date_GAAP__c = (Decimal) ar.get('rTDG');
                    ultimatePS.Secured_Amount_GAAP__c = (Decimal) ar.get('sAG');
                    ultimatePS.Secured_Amount_Negotiated__c = (Decimal) ar.get('sAN');
                    ultimatePS.Setup_in_Negotiated__c = (Decimal) ar.get('sIN');
                    ultimatePS.Total_Annual_PI__c = (Decimal) ar.get('tAPI');
                    ultimatePS.SBQQ__ListPrice__c = (Decimal) ar.get('listPrice');
                    ultimatePS.Negotiated_Amt_CPQ_Subs_Postage_Cost__c = (Decimal) ar.get('postageCost');
                    ultimatePS.Negotiated_Amt_CPQ_Subs_Media_Cost__c = (Decimal) ar.get('mediaCost');
                    
                    ultimatePS.GAAP_Negotiated_Amount_Postage_Cost__c = (Decimal) ar.get('gaapPostageCost');
                    ultimatePS.GAAP_Negotiated_Amount_Media_Cost__c = (Decimal) ar.get('gaapMediaCost');
                    ultimatePS.GAAP_Negotiated_Amount__c = (Decimal) ar.get('gaapNegotiatedAmount');
                    
                    //Add Reocrd in map
                    mapUltimateProgramSubscriptions.put(uParentPSId,ultimatePS);
                }                   
            }
            
            
            
            //Bypass all triggers
            Util.BypassAllTriggers = true;
        
            //Update Ultimate Program Subscription records
            update mapUltimateProgramSubscriptions.values();
        
            //Code to rollup details on Std Contract
      
            //SOQL over the Program Subscription
            List<SBQQ__Subscription__c> programSubscriptions = [Select Id, Name, SBQQ__Contract__c, RecordTypeId, Customer_Amount__c, Amount_Credited_Total__c,
                                                                       Credit_Note_Total__c, Deferred_Revenue_GAAP__c, Deferred_Revenue_Negotiated__c, GAAP_Amount_Rev_Rec__c,
                                                                       GAAP_Negotiated_Amount__c, Invoice_Total__c, SBQQ__ListPrice__c, Negotiated_Amount_Subscription__c,
                                                                       Negotiated_Amount_Subscription_Rev_Rec__c, Net_Invoiced__c, Recognized_to_Date_Negotiated__c, 
                                                                       Recognized_to_Date_GAAP__c, Secured_Amount_GAAP__c, Secured_Amount_Negotiated__c, Setup_in_Negotiated__c,
                                                                       Negotiated_Amt_CPQ_Subs_Postage_Cost__c, Negotiated_Amt_CPQ_Subs_Media_Cost__c, GAAP_Negotiated_Amount_Postage_Cost__c,
                                                                       GAAP_Negotiated_Amount_Media_Cost__c From SBQQ__Subscription__c
                                                                       Where Id IN : mapUltimateProgramSubscriptions.keySet() AND Program_Subscription__c = null AND RecordType.DeveloperName = 'Program'];
        
            //Call Std. Contract method
            if(programSubscriptions.size() > 0)
                populateStdContractFields(programSubscriptions, null);
        
            //Resume all triggers
            Util.BypassAllTriggers = false;
        }
    }
  
    /**
     *  @description    :   This method is used to rollup the data from Subscriptions To Std. Contract
     *                      Moved following DLRS to this method:
     *            
     *                      Subscriptions to Std. Contract
     *                      Rollup 1st Year Annual on Contract
     *                      Rollup X1st Year Initiation on Contract
     *                      Rollup X1st Year Travel on Contract
     *                      Rollup_Amount_Credited_To_Contract
     *                      RollUp_Contract_Total_Annual_Fee
     *                      RollUp_Contract_Total_Travel_Fee
     *                      Rollup_Credit_Note_To_Contract
     *                      Rollup_Deferred_Revenue_GAAP_To_Contract  
     *                      Rollup_Deferred_Revenue_Neg_Contract
     *                      Rollup_GAAP_Amount_Rev_Rec_To_Contract
     *                      Rollup_GAAP_Negotiated_Amont_To_Contract
     *                      Rollup_Invoice_Total_To_Contract
     *                      Rollup_List_Price_To_Contract
     *                      RollUp_Negotiated_Amount_Contract
     *                      Rollup_Negotiated_Amount_To_Contract
     *                      Rollup_Net_Invoiced_Contract_To_Contract
     *                      Rollup_Recognized_to_Date_Neg_Contract
     *                      Rollup_Recognized_to_Date_To_Contract
     *                      Rollup_Secured_Amount_GAAP_To_Contract
     *                      Rollup_Secured_Amount_Nego_To_Contract
     *                      Rollup_Setup_In_Negotiated_To_Contract
     *
     * 
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
     *
     *  @return         :   void
     *
     *  @Version        :   V1.0 - Created By - Subhash Garhawal - 02/22/2018 - CR-20181019-12685
     *
    **/
  public static void populateStdContractFields(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
    
    
      
    //Map to hold the Std. Contract
    Map<Id, Contract> mapStdContracts = new Map<Id, Contract>();
    
    //Loop over the Subscription
    for(SBQQ__Subscription__c subsc : subscriptions != null ? subscriptions : mapOldSubscriptions.values()) {
      
      //Modified by Mahendra Swarnkar - 05/03/2020 - CR-20200325-13888 - Added these new conditions
      //subsc.GAAP_Negotiated_Amount_Postage_Cost__c > 0,subsc.GAAP_Negotiated_Amount_Media_Cost__c > 0,subsc.Negotiated_Amt_CPQ_Subs_Postage_Cost__c > 0,subsc.Negotiated_Amt_CPQ_Subs_Media_Cost__c > 0
      //Insert and Delete Case
      if(((mapOldSubscriptions == null && subsc.SBQQ__Contract__c != null ) || (subscriptions == null && subsc.SBQQ__Contract__c != null))
        && (subsc.Customer_Amount__c > 0 || subsc.Amount_Credited_Total__c > 0 || subsc.Credit_Note_Total__c > 0 || subsc.Deferred_Revenue_GAAP__c > 0
          || subsc.Deferred_Revenue_Negotiated__c > 0 || subsc.GAAP_Amount_Rev_Rec__c > 0 || subsc.GAAP_Negotiated_Amount__c > 0
          || subsc.Invoice_Total__c > 0 || subsc.SBQQ__ListPrice__c > 0 || subsc.Negotiated_Amount_Subscription__c > 0
          || subsc.Negotiated_Amount_Subscription_Rev_Rec__c > 0 || subsc.Net_Invoiced__c > 0 || subsc.Recognized_to_Date_Negotiated__c > 0
          || subsc.Recognized_to_Date_GAAP__c > 0 || subsc.Secured_Amount_GAAP__c > 0 || subsc.Secured_Amount_Negotiated__c > 0
          || subsc.Setup_in_Negotiated__c > 0
          || subsc.GAAP_Negotiated_Amount_Postage_Cost__c > 0 || subsc.GAAP_Negotiated_Amount_Media_Cost__c >0 
          || subsc.Negotiated_Amt_CPQ_Subs_Postage_Cost__c > 0 || subsc.Negotiated_Amt_CPQ_Subs_Media_Cost__c > 0))
        mapStdContracts.put(subsc.SBQQ__Contract__c, new Contract(Id = subsc.SBQQ__Contract__c, X1st_year_Annual__c = 0, X1st_Year_Initiation_or_Imp__c = 0, X1st_Year_Travel__c = 0,
                                    Amount_Credited_Total_All_Products__c = 0, Total_Annual_Fee__c = 0, Total_Travel_Fee__c = 0,
                                    Credit_Note_Total_All_Products__c = 0, Deferred_Revenue_GAAP_Total__c = 0, Deferred_Revenue_Negotiated_Total__c = 0,
                                    GAAP_Amount_Rev_Rec_Total__c = 0, GAAP_Negotiated_Amount_Total__c = 0, Invoice_Total_All_Products__c = 0, List_Grand_Total__c = 0,
                                    Negotiated_Amount_Contract__c = 0, Negotiated_Amount_Contract_Rev_Rec__c = 0, Net_Invoiced_Contract__c = 0,
                                    Recognized_to_Date_Negotiated_Total__c = 0, Recognized_to_Date_GAAP_Total__c = 0, Secured_Amount_GAAP_Total__c = 0, 
                                    Secured_Amount_Negotiated_Total__c = 0, Setup_in_Negotiated_Total__c = 0,
                                    GAAP_Negotiated_Amount_Postage_Cost__c = 0, GAAP_Negotiated_Amount_Media_Cost__c = 0, 
                                    Negotiated_Amt_CPQ_Subs_Postage_Cost__c = 0, Negotiated_Amt_CPQ_Subs_Media_Cost__c = 0));
      
      //Modified by Mahendra Swarnkar - 05/03/2020 - CR-20200325-13888
      //Update Case
      if(mapOldSubscriptions != null && subscriptions != null
        && (subsc.SBQQ__Contract__c !=  mapOldSubscriptions.get(subsc.Id).SBQQ__Contract__c || subsc.RecordTypeId !=  mapOldSubscriptions.get(subsc.Id).RecordTypeId
          || subsc.Customer_Amount__c !=  mapOldSubscriptions.get(subsc.Id).Customer_Amount__c || subsc.Amount_Credited_Total__c !=  mapOldSubscriptions.get(subsc.Id).Amount_Credited_Total__c
          || subsc.Credit_Note_Total__c !=  mapOldSubscriptions.get(subsc.Id).Credit_Note_Total__c || subsc.Deferred_Revenue_GAAP__c !=  mapOldSubscriptions.get(subsc.Id).Deferred_Revenue_GAAP__c
          || subsc.Deferred_Revenue_Negotiated__c !=  mapOldSubscriptions.get(subsc.Id).Deferred_Revenue_Negotiated__c || subsc.GAAP_Amount_Rev_Rec__c !=  mapOldSubscriptions.get(subsc.Id).GAAP_Amount_Rev_Rec__c
          || subsc.GAAP_Negotiated_Amount__c !=  mapOldSubscriptions.get(subsc.Id).GAAP_Negotiated_Amount__c || subsc.Invoice_Total__c !=  mapOldSubscriptions.get(subsc.Id).Invoice_Total__c
          || subsc.SBQQ__ListPrice__c !=  mapOldSubscriptions.get(subsc.Id).SBQQ__ListPrice__c || subsc.Negotiated_Amount_Subscription__c !=  mapOldSubscriptions.get(subsc.Id).Negotiated_Amount_Subscription__c
          || subsc.Negotiated_Amount_Subscription_Rev_Rec__c !=  mapOldSubscriptions.get(subsc.Id).Negotiated_Amount_Subscription_Rev_Rec__c
          || subsc.Net_Invoiced__c !=  mapOldSubscriptions.get(subsc.Id).Net_Invoiced__c || subsc.Recognized_to_Date_Negotiated__c !=  mapOldSubscriptions.get(subsc.Id).Recognized_to_Date_Negotiated__c
          || subsc.Recognized_to_Date_GAAP__c !=  mapOldSubscriptions.get(subsc.Id).Recognized_to_Date_GAAP__c || subsc.Secured_Amount_GAAP__c !=  mapOldSubscriptions.get(subsc.Id).Secured_Amount_GAAP__c
          || subsc.Secured_Amount_Negotiated__c !=  mapOldSubscriptions.get(subsc.Id).Secured_Amount_Negotiated__c || subsc.Setup_in_Negotiated__c !=  mapOldSubscriptions.get(subsc.Id).Setup_in_Negotiated__c
          || subsc.GAAP_Negotiated_Amount_Postage_Cost__c != mapOldSubscriptions.get(subsc.Id).GAAP_Negotiated_Amount_Postage_Cost__c || subsc.GAAP_Negotiated_Amount_Media_Cost__c != mapOldSubscriptions.get(subsc.Id).GAAP_Negotiated_Amount_Media_Cost__c 
          || subsc.Negotiated_Amt_CPQ_Subs_Postage_Cost__c != mapOldSubscriptions.get(subsc.Id).Negotiated_Amt_CPQ_Subs_Postage_Cost__c || subsc.Negotiated_Amt_CPQ_Subs_Media_Cost__c != mapOldSubscriptions.get(subsc.Id).Negotiated_Amt_CPQ_Subs_Media_Cost__c)) {
        
        //Check for New Std. Contract and Add Contract in map to update
        if(subsc.SBQQ__Contract__c != null)
          mapStdContracts.put(subsc.SBQQ__Contract__c, new Contract(Id = subsc.SBQQ__Contract__c, X1st_year_Annual__c = 0, X1st_Year_Initiation_or_Imp__c = 0, X1st_Year_Travel__c = 0,
                                    Amount_Credited_Total_All_Products__c = 0, Total_Annual_Fee__c = 0, Total_Travel_Fee__c = 0,
                                    Credit_Note_Total_All_Products__c = 0, Deferred_Revenue_GAAP_Total__c = 0, Deferred_Revenue_Negotiated_Total__c = 0,
                                    GAAP_Amount_Rev_Rec_Total__c = 0, GAAP_Negotiated_Amount_Total__c = 0, Invoice_Total_All_Products__c = 0, List_Grand_Total__c = 0,
                                    Negotiated_Amount_Contract__c = 0, Negotiated_Amount_Contract_Rev_Rec__c = 0, Net_Invoiced_Contract__c = 0,
                                    Recognized_to_Date_Negotiated_Total__c = 0, Recognized_to_Date_GAAP_Total__c = 0, Secured_Amount_GAAP_Total__c = 0, 
                                    Secured_Amount_Negotiated_Total__c = 0, Setup_in_Negotiated_Total__c = 0,GAAP_Negotiated_Amount_Postage_Cost__c = 0,GAAP_Negotiated_Amount_Media_Cost__c = 0,
                                    Negotiated_Amt_CPQ_Subs_Postage_Cost__c = 0,Negotiated_Amt_CPQ_Subs_Media_Cost__c = 0));
        
        //Check if Contract get changed and add old Contract in map to update
        if(mapOldSubscriptions.get(subsc.Id).SBQQ__Contract__c != null && subsc.SBQQ__Contract__c !=  mapOldSubscriptions.get(subsc.Id).SBQQ__Contract__c)
          mapStdContracts.put(mapOldSubscriptions.get(subsc.Id).SBQQ__Contract__c, new Contract(Id = mapOldSubscriptions.get(subsc.Id).SBQQ__Contract__c, X1st_year_Annual__c = 0, X1st_Year_Initiation_or_Imp__c = 0, X1st_Year_Travel__c = 0,
                                    Amount_Credited_Total_All_Products__c = 0, Total_Annual_Fee__c = 0, Total_Travel_Fee__c = 0,
                                    Credit_Note_Total_All_Products__c = 0, Deferred_Revenue_GAAP_Total__c = 0, Deferred_Revenue_Negotiated_Total__c = 0,
                                    GAAP_Amount_Rev_Rec_Total__c = 0, GAAP_Negotiated_Amount_Total__c = 0, Invoice_Total_All_Products__c = 0, List_Grand_Total__c = 0,
                                    Negotiated_Amount_Contract__c = 0, Negotiated_Amount_Contract_Rev_Rec__c = 0, Net_Invoiced_Contract__c = 0,
                                    Recognized_to_Date_Negotiated_Total__c = 0, Recognized_to_Date_GAAP_Total__c = 0, Secured_Amount_GAAP_Total__c = 0, 
                                    Secured_Amount_Negotiated_Total__c = 0, Setup_in_Negotiated_Total__c = 0,GAAP_Negotiated_Amount_Postage_Cost__c = 0,GAAP_Negotiated_Amount_Media_Cost__c = 0,
                                    Negotiated_Amt_CPQ_Subs_Postage_Cost__c = 0,Negotiated_Amt_CPQ_Subs_Media_Cost__c = 0));
      }
    }
    
   
    //Check if need to execute next step code
    if(mapStdContracts.size() > 0) {
      
      //Modified by Mahendra Swarnkar - 05/03/2020 - CR-20200325-13888
      //SOQL over the Program Subscriptions to rollup the data Program Subscription specific data to Std. Contract
      for(AggregateResult aR : [Select SBQQ__Contract__c stdContract, SUM(Amount_Credited_Total__c) amtCreTotl, SUM(Credit_Note_Total__c) creditNoteTotal,
                       SUM(Deferred_Revenue_GAAP__c) deferreRevenueGAAP, SUM(Deferred_Revenue_Negotiated__c) defRevNegotiated,
                       SUM(GAAP_Amount_Rev_Rec__c) gAAPAmtRevRec, SUM(GAAP_Negotiated_Amount__c) gAAPNegoAmt, SUM(Invoice_Total__c) totalInvoice,
                       SUM(SBQQ__ListPrice__c) listPrice, SUM(Negotiated_Amount_Subscription__c)  negoAmtSub,
                       SUM(Negotiated_Amount_Subscription_Rev_Rec__c) negoAmtSubRevRec, SUM(Net_Invoiced__c) netInvoice,
                       SUM(Recognized_to_Date_Negotiated__c) recoDateNego, SUM(Recognized_to_Date_GAAP__c) recoDateGAAP,
                       SUM(Secured_Amount_GAAP__c) securedAmtGaap, SUM(Secured_Amount_Negotiated__c) secAmtNego,
                       SUM(Setup_in_Negotiated__c) setupNego, SUM(GAAP_Negotiated_Amount_Postage_Cost__c) gaapNegoPostageCost,SUM(GAAP_Negotiated_Amount_Media_Cost__c) gaapNegoMediaCost,
		       SUM(Negotiated_Amt_CPQ_Subs_Postage_Cost__c) negoCPQSubsPostageCost, SUM(Negotiated_Amt_CPQ_Subs_Media_Cost__c) negoCPQSubsMediaCost         
                       From SBQQ__Subscription__c
                       Where SBQQ__Contract__c IN : mapStdContracts.keySet() AND RecordTypeId =: CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM
                       AND Program_Subscription__c = null GROUP BY SBQQ__Contract__c]) {
       
        //Get Contract Id
        Id stdContrId = (Id) String.valueOf(ar.get('stdContract'));
            
            //Check Id in Contract map
            if(mapStdContracts.containsKey(stdContrId)) {
              
          	//Get Contract from map
                Contract stdContract = mapStdContracts.get(stdContrId);
              
                //Update Contract fields with newly rollup values
                stdContract.Amount_Credited_Total_All_Products__c = (Decimal) ar.get('amtCreTotl');
                stdContract.Credit_Note_Total_All_Products__c = (Decimal) ar.get('creditNoteTotal');
                stdContract.Deferred_Revenue_GAAP_Total__c = (Decimal) ar.get('deferreRevenueGAAP');
                stdContract.Deferred_Revenue_Negotiated_Total__c = (Decimal) ar.get('defRevNegotiated');
                stdContract.GAAP_Amount_Rev_Rec_Total__c = (Decimal) ar.get('gAAPAmtRevRec');
                stdContract.GAAP_Negotiated_Amount_Total__c = (Decimal) ar.get('gAAPNegoAmt');
                stdContract.Invoice_Total_All_Products__c = (Decimal) ar.get('totalInvoice');
                stdContract.List_Grand_Total__c = (Decimal) ar.get('listPrice');
                stdContract.Negotiated_Amount_Contract__c = (Decimal) ar.get('negoAmtSub');
                stdContract.Negotiated_Amount_Contract_Rev_Rec__c = (Decimal) ar.get('negoAmtSubRevRec');
                stdContract.Net_Invoiced_Contract__c = (Decimal) ar.get('netInvoice');
                stdContract.Recognized_to_Date_Negotiated_Total__c = (Decimal) ar.get('recoDateNego');
                stdContract.Recognized_to_Date_GAAP_Total__c = (Decimal) ar.get('recoDateGAAP');
                stdContract.Secured_Amount_GAAP_Total__c = (Decimal) ar.get('securedAmtGaap');
                stdContract.Secured_Amount_Negotiated_Total__c = (Decimal) ar.get('secAmtNego');
                stdContract.Setup_in_Negotiated_Total__c = (Decimal) ar.get('setupNego');
                
                stdContract.GAAP_Negotiated_Amount_Postage_Cost__c = (Decimal) ar.get('gaapNegoPostageCost');
		stdContract.GAAP_Negotiated_Amount_Media_Cost__c = (Decimal) ar.get('gaapNegoMediaCost');
		stdContract.Negotiated_Amt_CPQ_Subs_Postage_Cost__c = (Decimal) ar.get('negoCPQSubsPostageCost');
		stdContract.Negotiated_Amt_CPQ_Subs_Media_Cost__c = (Decimal) ar.get('negoCPQSubsMediaCost');
              
                //Add Reord in map
                mapStdContracts.put(stdContrId, stdContract);
        }
      }
      
      //10/27/2020 - CR-20201013-14598 - Victor Hanson - updated query to include cappex service cost
      //SOQL over the Component Subscriptions to rollup the data Component Subscription specific data to Std. Contract
      for(SBQQ__Subscription__c compSub : [Select Id, SBQQ__Contract__c, Product_Code__c, SBQQ__SegmentIndex__c, Customer_Amount__c 
                              From SBQQ__Subscription__c Where SBQQ__Contract__c IN : mapStdContracts.keySet() AND RecordTypeId =: CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT
                              AND Product_Code__c IN ('AnnualFee', 'TravelFee', 'ImplementationFee','ImplementationFeeSS', 'Implementation', :CPQConstants.PRODUCT_CODE_PROGRAM_COSTS, :CPQConstants.PRODUCT_CODE_CAPPEX_SERV_COST)]) {
        
            //Check Id in Contract map
            if(mapStdContracts.containsKey(compSub.SBQQ__Contract__c)) {
                
                //Get Category
                String proCat = compSub.Product_Code__c;
                
                //10/27/2020 - CR-20201013-14598 - Victor Hanson - updated to check for Program Costs OR Cappex Service Costs
                //Check Product Category and add rollup in fields
                if(proCat == 'AnnualFee' || CPQConstants.COST_PRODUCT_CODES.contains(proCat)) {
                  
                  //Check Index
                  if(compSub.SBQQ__SegmentIndex__c != null && compSub.SBQQ__SegmentIndex__c == 1)
                    mapStdContracts.get(compSub.SBQQ__Contract__c).X1st_year_Annual__c += compSub.Customer_Amount__c;
                  
                  //Add Total in toal field
                  mapStdContracts.get(compSub.SBQQ__Contract__c).Total_Annual_Fee__c += compSub.Customer_Amount__c;
                
                } else if(proCat == 'TravelFee') {
                  
                  //Check Index
                  if(compSub.SBQQ__SegmentIndex__c != null && compSub.SBQQ__SegmentIndex__c == 1)
                    mapStdContracts.get(compSub.SBQQ__Contract__c).X1st_Year_Travel__c += compSub.Customer_Amount__c;
                  
                  //Add Total in toal field
                  mapStdContracts.get(compSub.SBQQ__Contract__c).Total_Travel_Fee__c += compSub.Customer_Amount__c;
                
                } else if((proCat == 'ImplementationFee' || proCat == 'Implementation' || proCat == 'ImplementationFeeSS')&& compSub.SBQQ__SegmentIndex__c != null && compSub.SBQQ__SegmentIndex__c == 1) {
                  mapStdContracts.get(compSub.SBQQ__Contract__c).X1st_Year_Initiation_or_Imp__c += compSub.Customer_Amount__c;
                }
            }
      }
      
      //Bypass all triggers
        Util.BypassAllTriggers = true;
       
        //Update Std Contract
        update mapStdContracts.values();
          
        //Resume all triggers
        Util.BypassAllTriggers = false;
    }
  }
  
   
    
    
    
    
    /**
     *  @description    :   This method is used to rollup the data from Component Subscriptions To Subscription Periods
     *                      Moved following DLRS to this method:
     *            
     *                      Rollup_Profit_On_Subscription_Period
     *                      Rollup_Negotiated_Amt_Period_On_SP
     * 
     *  @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
     *
     *  @return         :   void
     *
     *  @Version        :   V1.0 - Created By - Subhash Garhawal - 02/22/2018 - CR-20181019-12685
     *
    **/
    public static void rollupCompSubToSubPeriod(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
    
        //Map to hold the Subscription Periods
        Map<Id, Subscription_Period__c> mapSubscriptionPeriods = new Map<Id, Subscription_Period__c>();
    
        //Loop over the Subscription
        for(SBQQ__Subscription__c subsc : subscriptions != null ? subscriptions : mapOldSubscriptions.values()) {
      
            //Insert/ delete case
            if(((mapOldSubscriptions == null || subscriptions == null) && subsc.Subscription_Period__c != null)
                && (subsc.Profit_m__c > 0 || subsc.Customer_Amount__c > 0))
                mapSubscriptionPeriods.put(subsc.Subscription_Period__c, new Subscription_Period__c(Id = subsc.Subscription_Period__c, Negotiated_Amount_Period__c = 0, Profit_Period__c = 0));
      
      //Update case
      if(mapOldSubscriptions != null && subscriptions != null && (subsc.Subscription_Period__c != mapOldSubscriptions.get(subsc.Id).Subscription_Period__c
        || subsc.Profit_m__c != mapOldSubscriptions.get(subsc.Id).Profit_m__c || subsc.Customer_Amount__c != mapOldSubscriptions.get(subsc.Id).Customer_Amount__c)) {
          
        
        //Add Sub Period in map to update
        if(subsc.Subscription_Period__c != null)
          mapSubscriptionPeriods.put(subsc.Subscription_Period__c, new Subscription_Period__c(Id = subsc.Subscription_Period__c, Negotiated_Amount_Period__c = 0, Profit_Period__c = 0));
        
        //Check if Sub Period is changed
        if(mapOldSubscriptions.get(subsc.Id).Subscription_Period__c != null && subsc.Subscription_Period__c != mapOldSubscriptions.get(subsc.Id).Subscription_Period__c)
          mapSubscriptionPeriods.put(mapOldSubscriptions.get(subsc.Id).Subscription_Period__c, new Subscription_Period__c(Id = mapOldSubscriptions.get(subsc.Id).Subscription_Period__c, Negotiated_Amount_Period__c = 0, Profit_Period__c = 0));
      }  
    }
    
    //Check if need to execute next code log
    if(mapSubscriptionPeriods.size() > 0) {
      
      //SOQL over the Component Subscriptions
      for(AggregateResult aR : [Select Subscription_Period__c sP, SUM(Profit_m__c) profit, SUM(Customer_Amount__c) custAmt From SBQQ__Subscription__c
                       Where Subscription_Period__c IN : mapSubscriptionPeriods.keyset() AND Subscription_Period__c != null  GROUP BY Subscription_Period__c]) {
        
        //Get Subscription Period Id
        Id subPeriodId = (Id) String.valueOf(ar.get('sP'));
        
        //Check Sub Period Id in map
        if(mapSubscriptionPeriods.containsKey(subPeriodId)) {
          
          //Get Sub Period
          Subscription_Period__c subPeriod = mapSubscriptionPeriods.get(subPeriodId);
          
          //Update field values
          subPeriod.Profit_Period__c = (Decimal) ar.get('profit');
          
          mapSubscriptionPeriods.put(subPeriodId, subPeriod);
        }                    
      }
      
            //Updated By Mahendra Swarnkar - 04/03/2019 - CR-20181019-12685 - Commented te Postage cost and media cost product code check
      //SOQL over the Component Subscriptions
      for(AggregateResult aR : [Select Subscription_Period__c sP, SUM(Customer_Amount__c) custAmt From SBQQ__Subscription__c
                       Where Subscription_Period__c IN : mapSubscriptionPeriods.keyset() AND Subscription_Period__c != null
                       AND ((Subscription_Period__r.Stage__c != 'Pending' OR (Subscription_Period__r.Stage__c = 'Pending' AND Subscription_Period__r.Decision_Type__c != 'Need New LOA'))
                           AND Customer_Amount__c != null //AND Product_Code__c NOT IN ('Postage Costs', 'Media Costs')
                                                 ) GROUP BY Subscription_Period__c]) {
        
        //Get Subscription Period Id
        Id subPeriodId = (Id) String.valueOf(ar.get('sP'));
        
        //Check Sub Period Id in map
        if(mapSubscriptionPeriods.containsKey(subPeriodId)) {
          
          //Get Sub Period
          Subscription_Period__c subPeriod = mapSubscriptionPeriods.get(subPeriodId);
          
          //Update field values
          subPeriod.Negotiated_Amount_Period__c = (Decimal) ar.get('custAmt');
          
          mapSubscriptionPeriods.put(subPeriodId, subPeriod);
        }                    
      }
      
      //Bypass all triggers
        Util.BypassAllTriggers = true;
          
        //Update Std Contract
        update mapSubscriptionPeriods.values();
        
        //Call method - Mahendra Swarnkar - 05/10/2019 - CR-20181019-12685
        //populate the previous period negotiated fields on the subscription period trigger helper. 
        SubscriptionPeriodTriggerHelper.populatePreviousPeriodNegotiated(mapSubscriptionPeriods.values(),null);
        
        //Resume all triggers
        Util.BypassAllTriggers = false;
    }
  }
  
    /**
     *  @description    :   If certain values change on the Subscription and there are related Revenue records, then go update the List Price on Revenue
     *
     *  @args           :   List<SBQQ__Subscription__c> subscriptions, Map<Id,SBQQ__Subscription__c> oldMapSubscription
     *
     *  @return         :   void
     *
     *  @Revision Log   :  V1.0 - Created - Colin McGloin - 03/04/2019 - CR-20180918-12607
     
     *
     **/
    
    public static void goUpdateListPriceOnRevenueRecords (List<SBQQ__Subscription__c> subscriptions, Map<Id,SBQQ__Subscription__c> oldMapSubscription){
        
        //Set of Ids of Program Subscriptions to pass through for future processing
        List<Id> progSubIds = new List<Id>();
        
        //Update Scenario
        if (subscriptions != null && oldMapSubscription != null){
            
            //Loop through our records
            for (SBQQ__Subscription__c sub : subscriptions){
                
                //Check to see if this is a Component record, is committed and one of the following fields has changed
                if (sub.Program_Subscription__c != null && oldMapSubscription != null &&
                    (sub.SBQQ__SegmentStartDate__c != oldMapSubscription.get(sub.Id).SBQQ__SegmentStartDate__c ||
                     sub.SBQQ__SegmentEndDate__c != oldMapSubscription.get(sub.Id).SBQQ__SegmentEndDate__c ||
                     sub.SBQQ__ListPrice__c != oldMapSubscription.get(sub.Id).SBQQ__ListPrice__c)){
                         progSubIds.add(sub.Program_Subscription__c);                   
                     }                
            }          
        }
        
        //If we have Program Subscriptions to check
        if (progSubIds.size() > 0){
            
            //Pass through our Ids to Future Method to check for Revenue records and re-calculate List Price on Revenue records as needed      
            System.enqueueJob(new Enqueue_CheckForRevenueRecords(progSubIds));        
        }
    }
    
    //Variable to control the Custom Twin functionality execution (Proposal Line to Subscription)
    public static Boolean hasExecutedTwinFields = false;
    
    /**
     *  @description    :   Custom Twining functionality to move data from Proposal Line to Subscription
   * 
     *  @args           :   Map<Id, SBQQ__Subscription__c> subscriptionMap
     *
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created By - Victor Hanson - CR-20181019-12685
     *
    **/
    public static void twinFields(List<SBQQ__Subscription__c> subscriptions) {
	
        //only run once
        // if (hasExecutedTwinFields) return;
        hasExecutedTwinFields = true;
        
        //get all quoteline ids
        Set<Id> qlIds = new Set<Id>();
        for (SBQQ__Subscription__c sub : subscriptions) {
            if (sub.SBQQ__QuoteLine__c != null) qlIds.add(sub.SBQQ__QuoteLine__c);
        }
        

        if (qlIds.size() > 0) {
            //build query
            String qryString = 'SELECT Id, Twin_Fields_Date_Time__c, ' 
                + String.join(New List<String>(FieldMappingHelper.getFields('QuoteLine_to_Subscription')), ',')
                + ' FROM SBQQ__QuoteLine__c WHERE Id IN :qlIds';

            Map<Id, SBQQ__QuoteLine__c> qlMap = new Map<Id, SBQQ__QuoteLine__c>((List<SBQQ__QuoteLine__c>)database.query(qryString));
            
            FieldMappingHelper.mapFields(subscriptions, qlMap);
        }
    }
    
    /**
     *  @description    :   Custom Twin field values from Original Subscriptions to Renewal/Amended subscriptions
   * 
     *  @args           :   List<SBQQ__QuoteLine__c>
     *
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created By - Victor Hanson - CR-20181019-12685
     *
    **/
    public static void twinFields(List<SBQQ__QuoteLine__c> quoteLines) {
        
        //Set to hold all the Renewal or Amended subscription
        Set<Id> setSubIds = new Set<Id>();
        
        for (SBQQ__QuoteLine__c ql : quoteLines) {
            
            if (ql.SBQQ__RenewedSubscription__c != null) {
                setSubIds.add(ql.SBQQ__RenewedSubscription__c);
                //01/14/2021 - CR-20210107-14791 - Victor Hanson - set the date the twin fields were populated
                ql.Twin_Fields_Date_Time__c = dateTime.now();
            }
            if (ql.SBQQ__UpgradedSubscription__c != null)
                setSubIds.add(ql.SBQQ__UpgradedSubscription__c);
        }
    
    
        if (setSubIds.size() > 0) {
            
            //build query
            String qryString = 'SELECT Id, ' + String.join(New List<String>(FieldMappingHelper.getFields('Subscription_to_QuoteLine')),
                                                           ',')
                + ' FROM SBQQ__Subscription__c WHERE Id IN :setSubIds';
                
            Map<Id, SBQQ__Subscription__c> subMap = new Map<Id, SBQQ__Subscription__c>((List<SBQQ__Subscription__c>)database.query(qryString));
            
            //Call Field Mapping call to move Custom Twin fields value from Original Subscriptions to Renewal/Amended subscriptions
            FieldMappingHelper.mapFields(quoteLines, subMap);
        }
    }
    
    /**
     *  @description    :   Populates the child program Subscription records with the opt out details.
     * 
     *  @args           :   List New Subscriptions, Map Old subscriptions 
     *
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created By - Mahendra Swarnkar - CR-20181019-12685 - 06/17/2019.
     *
    **/
    public static void populateOptOutDetailsOnChildProgramSubscriptions(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
        
        //Set to hold the Top parent Program Subscriptions
        set<Id> setProgramSubscriptionIds = new set<Id>();
        
        //if Opt out subscription is being inserted, or subscription.Program_Subscription__c is changed, add program subscription to the set of IDs
        for (SBQQ__Subscription__c subscription : subscriptions) {
            
            //Check for conditions
            if ( subscription.RecordTypeId == CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT && subscription.Subscription_Period__c == null && (mapOldSubscriptions == null || (mapOldSubscriptions.get(subscription.Id).Program_Subscription__c != subscription.Program_Subscription__c))) {
                
                //Populate the set
                if (subscription.Program_Subscription__c != null)
                    setProgramSubscriptionIds.add(subscription.Program_Subscription__c);
            }
        }
        
        //Check for size
        if (setProgramSubscriptionIds.size() > 0) {
            
            //List to hold the child program Subscriptions to be updated
            List<SBQQ__Subscription__c> listChildProgramSubscriptionsToBeUpdated = new List<SBQQ__Subscription__c>();
            
            //get child Program subscription 
            for(SBQQ__Subscription__c subscription : [SELECT Id, Opt_Out__c, Board_Notification_Date__c, Days_Notice__c,
                                                        Early_Termination_Date__c,Term_Type__c, Official_Drop_Date__c,
                                                        Program_Subscription__r.Early_Termination_Date__c, Program_Subscription__r.Opt_Out__c, Program_Subscription__r.Board_Notification_Date__c, 
                                                        Program_Subscription__r.Term_Type__c, Program_Subscription__r.Official_Drop_Date__c, Program_Subscription__r.Days_Notice__c
                                                        FROM SBQQ__Subscription__c 
                                                        WHERE RecordTypeId =: CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM AND Program_Subscription__c != null 
                                                            AND Program_Subscription__c IN :setProgramSubscriptionIds]){
                
                //Flag for change
                Boolean isUpdate = false;
                
                //Populates the Early_Termination_Date__c
                if(subscription.Program_Subscription__r.Early_Termination_Date__c != null){
                    subscription.Early_Termination_Date__c = subscription.Program_Subscription__r.Early_Termination_Date__c;
                    isUpdate = true;
                }
                
                //Populates the Opt_Out__c
                if(subscription.Program_Subscription__r.Opt_Out__c != null){
                    subscription.Opt_Out__c = subscription.Program_Subscription__r.Opt_Out__c;
                    isUpdate = true;
                }
                
                //Populates the Board_Notification_Date__c
                if(subscription.Program_Subscription__r.Board_Notification_Date__c != null){
                    subscription.Board_Notification_Date__c = subscription.Program_Subscription__r.Board_Notification_Date__c;
                    isUpdate = true;
                }
                
                //Populates the Term_Type__c
                if(subscription.Program_Subscription__r.Term_Type__c != null){
                    subscription.Term_Type__c = subscription.Program_Subscription__r.Term_Type__c;
                    isUpdate = true;
                }
                
                //Populates the Official_Drop_Date__c
                if(subscription.Program_Subscription__r.Official_Drop_Date__c != null){
                    subscription.Official_Drop_Date__c = subscription.Program_Subscription__r.Official_Drop_Date__c;
                    isUpdate = true;
                }
                
                //Populates the Days_Notice__c
                if(subscription.Program_Subscription__r.Days_Notice__c != null){
                    subscription.Days_Notice__c = subscription.Program_Subscription__r.Days_Notice__c;
                    isUpdate = true;
                }
				
                
                //Populates the child program subscriptions to be updated
                if(isUpdate)
                    listChildProgramSubscriptionsToBeUpdated.add(new SBQQ__Subscription__c(Id = subscription.Id, Early_Termination_Date__c = subscription.Early_Termination_Date__c, 
                                                                         Opt_Out__c = subscription.Opt_Out__c, Board_Notification_Date__c = subscription.Board_Notification_Date__c,
                                                                         Term_Type__c = subscription.Term_Type__c, Official_Drop_Date__c = subscription.Official_Drop_Date__c, Days_Notice__c = subscription.Days_Notice__c));
            }
            
            //Check for size
            if (listChildProgramSubscriptionsToBeUpdated.size() > 0 ) {
                
                //this method executes outside of the bypassAllTriggers flag, so we need to store the bypass value and reset it
                boolean triggerBypassSetting = util.BypassAllTriggers;
              
                //Bypass all triggers
                Util.BypassAllTriggers = true;
                    
                //Updates the Child program subscriptions
                update listChildProgramSubscriptionsToBeUpdated;
                
                //Reset the flag to whatever it was originally
                Util.BypassAllTriggers = triggerBypassSetting;
            }
        }
    }
    
    /**
     *  @description    :   Populates the GAAP fields with the values same as the value before Amendment, on the committed amended program Subscriptions.
     * 
     *  @args           :   List New Subscriptions, Map Old subscriptions 
     *
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created By - Mahendra Swarnkar - CR-20181019-12685 - 07/19/2019.
     *
    **/
    public static void populateGAAPFieldsOnAmendment(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
    	
        
			
        //Set to hold the Contract Ids
        Set<Id> contractIds = new Set<Id>();
        
        //Loop over the Subscriptions
        for (SBQQ__Subscription__c sub : subscriptions) {
            
            //Check for the status
            if(sub.Status__c != null && (sub.Status__c == 'Void-Amended' || sub.Status__c == 'Committed-Amended')) {
                
                //Populate the set
                contractIds.add(sub.SBQQ__Contract__c);
            }
        }   	
        
        //Query over the CPQ Subscriptions
        if(contractIds.size() > 0){
            
            //Program_Subscription__c, Program_Subscription__r.SBQQ__Product__c, Program_Subscription__r.Program_Products__c,
            Map<Id, SBQQ__Subscription__c> mapSubscriptions = new Map<Id, SBQQ__Subscription__c>([SELECT Id, Program_Products__c, SBQQ__Contract__c, Status__c,
                                                                                                  GAAP_Negotiated_Amount_Postage_Cost__c, GAAP_Negotiated_Amount_Media_Cost__c, GAAP_Negotiated_Amount__c
                                                                                                  FROM SBQQ__Subscription__c 
                                                                                                  WHERE SBQQ__Contract__c != null AND SBQQ__Contract__c IN : contractIds AND SBQQ__Contract__r.Status = 'Activated_Amended' 
                                                                                                  AND RecordType.ID =: CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM AND Status__c IN ('Void-Amended','Committed-Amended')
                                                                                                  ORDER BY CreatedDate DESC]);
            
            //Check for size
            if(mapSubscriptions.size() > 0){
                
                //map to hold the void Amended Program Subscriptions with unique key (COntract-Program_Products)
                Map<String, SBQQ__Subscription__c> keyToVoidAmendedProgramSubscription = new Map<String, SBQQ__Subscription__c>();
                
                //map to hold the committed Amended ProgramSubscriptions with unique key (COntract-Program_Products)
                Map<String, SBQQ__Subscription__c> keyToCommittedAmendedProgramSubscription = new Map<String, SBQQ__Subscription__c>();
                
                //set to hold unique Key (COntract-Program_Products) for all the subscriptions
                Set<String> setProgramSubscriptionUniqueKey = new Set<String>();
                
                //Loop over the queried subscription records 
                for (SBQQ__Subscription__c sub : mapSubscriptions.values()) {
                    
                    //Populate the set of unique key
                    if(!setProgramSubscriptionUniqueKey.contains(sub.SBQQ__Contract__c + '-' + sub.Program_Products__c))
                        setProgramSubscriptionUniqueKey.add(sub.SBQQ__Contract__c + '-' + sub.Program_Products__c);
                    
                    //Check for status and populate the map for void_Amended/committed_Amended Program Subscriptions with unique key
                    if(sub.Status__c == 'Void-Amended' ){
                        
                        if (!keyToVoidAmendedProgramSubscription.containsKey(sub.SBQQ__Contract__c + '-' + sub.Program_Products__c)) {
                            
                            keyToVoidAmendedProgramSubscription.put(sub.SBQQ__Contract__c + '-' + sub.Program_Products__c, sub);
                        }	
                    } else if(sub.Status__c == 'Committed-Amended'){
                        
                        if (!keyToCommittedAmendedProgramSubscription.containsKey(sub.SBQQ__Contract__c + '-' + sub.Program_Products__c)) {
                            
                            keyToCommittedAmendedProgramSubscription.put(sub.SBQQ__Contract__c + '-' + sub.Program_Products__c, sub);
                        }	
                    }
                }
                
                //Check for size
                if(setProgramSubscriptionUniqueKey.size() > 0 && keyToVoidAmendedProgramSubscription.size() > 0 && keyToCommittedAmendedProgramSubscription.size() > 0) {
                    
                    //List to hold the program subscriptions to be update
                    List<SBQQ__Subscription__c> listSubscriptionsToUpdate = new List<SBQQ__Subscription__c>();
                    
                    //Loop over the unique Keys
                    for(String uniqueKey : setProgramSubscriptionUniqueKey){
                        
                        //Check for key in the maps for void_Amended/committed_Amended Program Subscriptions
                        if(keyToVoidAmendedProgramSubscription.containsKey(uniqueKey) && keyToVoidAmendedProgramSubscription.get(uniqueKey) != null 
                           && keyToCommittedAmendedProgramSubscription.containsKey(uniqueKey) && keyToCommittedAmendedProgramSubscription.get(uniqueKey) != null){
                               
                               //Get the Committed_Amended subscription
                               SBQQ__Subscription__c committedSubscription = keyToCommittedAmendedProgramSubscription.get(uniqueKey);
                               
                               //Update the GAAP field values with the values before amendment
                               committedSubscription.GAAP_Negotiated_Amount__c = keyToVoidAmendedProgramSubscription.get(uniqueKey).GAAP_Negotiated_Amount__c;
                               committedSubscription.GAAP_Negotiated_Amount_Postage_Cost__c = keyToVoidAmendedProgramSubscription.get(uniqueKey).GAAP_Negotiated_Amount_Postage_Cost__c;
                               committedSubscription.GAAP_Negotiated_Amount_Media_Cost__c = keyToVoidAmendedProgramSubscription.get(uniqueKey).GAAP_Negotiated_Amount_Media_Cost__c;
                               
                               //Populate the list
                               listSubscriptionsToUpdate.add(committedSubscription);
                           }
                    }
                    
                    //Check for size
                    if(listSubscriptionsToUpdate.size() > 0){
                        
                        //Bypass all triggers
                        Util.BypassAllTriggers = true;
                        
                        //Update the subscriptions
                        update listSubscriptionsToUpdate;
                        
                        //Bypass all triggers
                        Util.BypassAllTriggers = false;
                    }	
                }
            }
        }
                                                                      	
    }
    
  /**  Description  :  The method is used to populate Subscription fields on New Membership.
   *
   *  Created by    :  Dipesh Gupta
   *
   *  Created Date  :  09/05/2019
   *
   *  @args         :  List<Membership__c>
   *
   *  @return       :  Void
   *
   *  @Revision Log  :  V1.0 - Created
   *
   **/
    public static void populateSubscriptionFieldsonNewMembership(List<Membership__c> memberships){
        
        //Set to hold the Account Ids
        Set<Id> setAccIds = new Set<Id>();
        
        //Loop over the New Membership
        for(Membership__c mem : memberships) {
            if(mem.Account_Name__c != null){
                //Add Account Id in set
                setAccIds.add(mem.Account_Name__c);
            }
        }
        
        //Size check
        if(setAccIds.size() > 0){
            
            //SOQL query over the CIA
            for(Contract_Integrated_Accounts__c cIA : [SELECT Account__c FROM Contract_Integrated_Accounts__c WHERE Account__c IN : setAccIds]) {
                //Null check
                if(cIA.Account__c != null){
                    //Add Account Id in set
                    setAccIds.add(cIA.Account__c);
                }
            }   
            
            //Map to hold all Program Subscriptions with Account
            Map<Id, List<SBQQ__Subscription__c>> mapProSubsWithAccount = new Map<Id, List<SBQQ__Subscription__c>>();               
                                    
            for(SBQQ__Subscription__c pS : [SELECT Id, SBQQ__Account__c, Program__c, SBQQ__Contract__c,Status__c, SBQQ__Product__c, Parent_Program__c
                                            FROM SBQQ__Subscription__c WHERE RecordType.DeveloperName = 'Program' AND SBQQ__Account__c IN : setAccIds ]) {
                   
            
                   //Check Account Id in map
                   if(!mapProSubsWithAccount.containsKey(pS.SBQQ__Account__c))
                      mapProSubsWithAccount.put(pS.SBQQ__Account__c, new List<SBQQ__Subscription__c>());
                                                
                   //Add Program Subscription in map
                   mapProSubsWithAccount.get(pS.SBQQ__Account__c).add(pS);
                                                
             }
            For(List<SBQQ__Subscription__c> listOfAllProgSubscriptions : mapProSubsWithAccount.values()){
                
                //To execute existing logic 
                SBQQ_SubscriptionTriggerHelper.populateSubscriptionFieldsOnMembership(listOfAllProgSubscriptions, null);
            }
        }
    }
   /**
    *
    *   @description    :   This used to populate List price equals to 0, if its value is null.
    *
    *   @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V_1.0 - Created - Subhash Garhwal
    *
    **/
    public static void populateListPriceOnComponentSubscription(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions){

        //Loop over the Subscription
        for(SBQQ__Subscription__c sub : subscriptions){
            
            //Check for conditions
            if(sub.RecordTypeId == CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT && sub.SBQQ__ListPrice__c == null/* &&
               (mapOldSubscriptions == null || sub.SBQQ__ListPrice__c != mapOldSubscriptions.get(sub.Id).SBQQ__ListPrice__c )*/)
                sub.SBQQ__ListPrice__c = 0;
        }
    }
     /**
      * 
      *  @description	:   Added method to validate the Program Subscription
      *
      *  @args		:   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
      *
      *  @return	:   void
      *
      *  @revision Log	:   V1.1 - Created - 06/15/2020 - Mahendra Swarnkar - CR-20200610-14172 - Before delete validate Contratany Program Subscription is having the revenue records
      * 
     **/
    public static void validateSubscription(List<SBQQ__Subscription__c> newSubsriptionList, Map<Id, SBQQ__Subscription__c> mapOldSubscription) {
    	//Get all record types of SBQQ__Subscription__c
        Map<String, Id> mapSubscriptionRecordTypes = new Map<String, Id>();
        mapSubscriptionRecordTypes = Constants.MAP_SUBSCRIPTION_RTYPE;
        
        String programRecordType = mapSubscriptionRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM);
        
        set<Id> setOfSubscriptionId = new set<Id>();
        Map<Id,ABC_Revenue__c> mapOfSubsWithRevenue = new Map<Id,ABC_Revenue__c>();
        
       
        for(SBQQ__Subscription__c subs : newSubsriptionList != null ? newSubsriptionList : mapOldSubscription.values()) {
            
            if(newSubsriptionList == null && mapOldSubscription !=  null) {
                if(mapOldSubscription.get(subs.Id).RecordTypeId == programRecordType)
                    setOfSubscriptionId.add(subs.Id);
                if(mapOldSubscription.get(subs.Id).RecordTypeId != programRecordType && subs.Program_Subscription__c != null)
                    setOfSubscriptionId.add(subs.Program_Subscription__c);
            }    
        }
        
        if(setOfSubscriptionId.size() > 0){
            
            for(ABC_Revenue__c revenue : [select Id,Program_Subscription__c From ABC_Revenue__c
                                                  WHERE Program_Subscription__c =:setOfSubscriptionId ]){
                mapOfSubsWithRevenue.put(revenue.Program_Subscription__c,revenue);
            }
        }
        
         for(SBQQ__Subscription__c subs : newSubsriptionList != null ? newSubsriptionList : mapOldSubscription.values()) {
            if((subs.Program_Subscription__c != null && mapOfSubsWithRevenue.containsKey(subs.Program_Subscription__c)
                || mapOfSubsWithRevenue.containsKey(subs.Id) )){
                throw new CustomException('You can not delete this record, as revenue records are exit on Program Subscription.');
            }
         }
    }
    
       
   /**
    *
    *   @description    :   This used to populate Start date and end date for Yield Optimization (ESYO)  sub product.
    *
    *   @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V_1.0 - Created - Subhash Garhwal 6/29/2020
    *			    V_1.1 - Modified By - Subhash Garhwal - 9/17/2020 - CR-20200701-14248 - Added Subscription Period update logic
    * 			    V_1.2 - Modified By - Subhash Garhwal - 12/20/2020 - CR-20201215-14746 
    *
    **/
    public static void populateStartEndDateOnESYOComponentSubscription(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
		
        //Set to hold the ESYO sub products for which Start/End dates will change.
        Set<String> setDefaultANDStartEndDateChangeProducts = CPQConstants.setDefaultANDStartEndDateChangeProducts;
            
        //Set to hold the ESYO sub products for which Start/End dates are changed. 
        Set<String> setStartEndDateChangeProducts = CPQConstants.setStartEndDateChangeProducts;
		//09/17/2020 - Subhash Garhwal - CR-20200701-14248
		//Map to update Subscription Periods
		Map<Id, Subscription_Period__c> mapSubscriptionPeriods = new Map<Id, Subscription_Period__c>();
        
		// set of Program subscription 
		Set<Id> setOfContractId = new Set<Id>();
        
    	       //Loop on the subscriptions. 
    	       for(SBQQ__Subscription__c sub : subscriptions) {
            
    		   //insert or update case
        	   if(sub.RecordTypeId == CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT && sub.SBQQ__Contract__c != null && sub.Related_Product_with_Parent_Product__c != null && setStartEndDateChangeProducts.contains(sub.Related_Product_with_Parent_Product__c)) {
            	   setOfContractId.add(sub.SBQQ__Contract__c);
	      }
    	}
        if(setOfContractId.size() > 0){
            
            /*List<SBQQ__Subscription__c> listProgramSubscriptionOtherThanFAO = new List<SBQQ__Subscription__c> ();
            
			listProgramSubscriptionOtherThanFAO = [SELECT ID FROM SBQQ__Subscription__c 
                                                       WHERE RecordTypeId = : CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM 
                                                        AND SBQQ__Contract__c != null AND SBQQ__Contract__c IN : setOfContractId 
                                                        AND SBQQ__Product__c != null AND SBQQ__Product__r.ProductCode NOT IN : setDefaultANDStartEndDateChangeProducts ];
            */
	    
            Map<Id, List<SBQQ__Subscription__c>> mapContractIdWithListProgramSubscriptionOtherThanFAO = new  Map<Id, List<SBQQ__Subscription__c>>();
            for(SBQQ__Subscription__c subscrip : [SELECT ID, SBQQ__Contract__c  FROM SBQQ__Subscription__c 
                                                   WHERE RecordTypeId = : CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM 
                                                   AND SBQQ__Contract__c != null AND SBQQ__Contract__c IN : setOfContractId 
                                                  AND SBQQ__Product__c != null AND SBQQ__Product__r.ProductCode NOT IN : setDefaultANDStartEndDateChangeProducts ])
            {
                if(!mapContractIdWithListProgramSubscriptionOtherThanFAO.containsKey(subscrip.SBQQ__Contract__c))
            		mapContractIdWithListProgramSubscriptionOtherThanFAO.put(subscrip.SBQQ__Contract__c, new List<SBQQ__Subscription__c>());
                mapContractIdWithListProgramSubscriptionOtherThanFAO.get(subscrip.SBQQ__Contract__c).add(subscrip);
				                
            }
            //if(listProgramSubscriptionOtherThanFAO != null && listProgramSubscriptionOtherThanFAO.size() > 0){
            if(mapContractIdWithListProgramSubscriptionOtherThanFAO.size() > 0){
                //Loop over the new Subscriptions
                for(SBQQ__Subscription__c sub : subscriptions){
                   
                    //Check for conditions
                    if( sub.RecordTypeId == CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT 
                       	&& sub.Related_Product_with_Parent_Product__c != null && sub.SBQQ__Contract__c != null
                        && setStartEndDateChangeProducts.contains(sub.Related_Product_with_Parent_Product__c) 
                        && mapContractIdWithListProgramSubscriptionOtherThanFAO.containsKey(sub.SBQQ__Contract__c)
                        && mapContractIdWithListProgramSubscriptionOtherThanFAO.get(sub.SBQQ__Contract__c) != null
                        && mapContractIdWithListProgramSubscriptionOtherThanFAO.get(sub.SBQQ__Contract__c).size() > 0
			) {
						
                        //Check if Start date lies in between 7/1 to 8/1 then set the start date to 8/1
                        if(sub.SBQQ__SegmentStartDate__c != null && (sub.SBQQ__SegmentStartDate__c.month() == 7 || (sub.SBQQ__SegmentStartDate__c.month() == 8 && sub.SBQQ__SegmentStartDate__c.day() < 2 ))) {
                            sub.SBQQ__SegmentStartDate__c = date.newInstance(sub.SBQQ__SegmentStartDate__c.Year(), 8, 1);
                        }
                        
                        if(sub.SBQQ__SegmentEndDate__c != null) {
                            
                            /*
                            Date endDate = date.newInstance(sub.SBQQ__SegmentEndDate__c.Year(), 7, 31);
                            
                            if(!(sub.SBQQ__SegmentEndDate__c == sub.SBQQ__EndDate__c && endDate < sub.SBQQ__EndDate__c) 
                               	&& endDate <= sub.SBQQ__EndDate__c && sub.SBQQ__SegmentEndDate__c != endDate)
                            {
                                sub.SBQQ__SegmentEndDate__c = endDate;
                            }
                            
                            if( sub.SBQQ__SegmentEndDate__c == sub.SBQQ__EndDate__c && endDate > sub.SBQQ__EndDate__c ){
                                
                                //Update the End Date on the Subscription
                                sub.SBQQ__SegmentEndDate__c = endDate;
                                
                                //update the end date on the Sub Period
                                if(sub.Subscription_Period__c != null)
                                    mapSubscriptionPeriods.put(sub.Subscription_Period__c, new Subscription_Period__c(Id = sub.Subscription_Period__c, Period_End_Date__c = endDate));
                            }
                            */
                            //09/17/2020 - Subhash Garhwal - CR-20210817-15358
		            //Update End Date and Segment End Date
                            Date endDate = date.newInstance(sub.SBQQ__EndDate__c.Year(), 7, 31);
                            Date startRangeDate = date.newInstance(sub.SBQQ__EndDate__c.Year(), 6, 30);
                            
                            if( sub.SBQQ__EndDate__c >= startRangeDate && sub.SBQQ__EndDate__c <= endDate ){
                                Date sEndDate = date.newInstance(sub.SBQQ__SegmentEndDate__c.Year(), 7, 31);
                                //Update the End Date on the Subscription
                                sub.SBQQ__SegmentEndDate__c = sEndDate;
                                
                                //update the end date on the Sub Period
                                if(sub.Subscription_Period__c != null)
                                    mapSubscriptionPeriods.put(sub.Subscription_Period__c, new Subscription_Period__c(Id = sub.Subscription_Period__c, Period_End_Date__c = endDate));
                            }
                        }
                    }
                }
                
                //Check for Subscription Periods
                if(mapSubscriptionPeriods.size() > 0)
                    update mapSubscriptionPeriods.values();
            }
        }
    }
    
 
    
       /**
        *  @description    :  This method is used to populate start date and end date for ESFAO program subscription
        * 
        *  @args           :   List of subscriptions, Map of subscription
        * 
        *  @return         :   void
        * 
        * Created By       :   Subhash Garhwal 08/18/2020 CR-20200701-14248
        **/
    public static void populateStartEndDateOnESFOProgramSubscription(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
        
        //Modified By - Subhash Garhwal - 09/09/2020 - CR-20200701-14248 - Added the products ('ESFAD', 'ESFBM', 'ESFYT', 'ESIQS', 'ESRTA', 'ESTFAO') in the set
        //Set to hold the ESYO sub products for which Start/End dates will change. 
        Set<String> setStartEndDateChangeProducts = new Set<String>{'ESFAO','ESFAD', 'ESFBM', 'ESFYT', 'ESIQS', 'ESRTA', 'ESTFAO'};
            
        // set of Program subscription 
        Set<Id> setOfProgSubscriptionId = new Set<Id>();
        
        //Loop on the subscriptions. 
        for(SBQQ__Subscription__c sub : subscriptions) {
            
            //insert or update case
            if(sub.RecordTypeId == CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT && sub.Program_Subscription__c != null 
                && sub.SBQQ__SegmentStartDate__c != null && sub.SBQQ__SegmentEndDate__c != null 
                && ( mapOldSubscriptions == null || ( mapOldSubscriptions != null 
                                                     && ( mapOldSubscriptions.get(sub.Id).Program_Subscription__c != sub.Program_Subscription__c
                                                         || mapOldSubscriptions.get(sub.Id).SBQQ__SegmentStartDate__c != sub.SBQQ__SegmentStartDate__c
                                                         || mapOldSubscriptions.get(sub.Id).SBQQ__SegmentEndDate__c != sub.SBQQ__SegmentEndDate__c)
			))){
				setOfProgSubscriptionId.add(sub.Program_Subscription__c);
			}
        }
        
        // size check
        if(setOfProgSubscriptionId.size() > 0 ) {
            
            map<Id, SBQQ__Subscription__c> mapProgSubscriptionToBeUpdate = new map<Id, SBQQ__Subscription__c>();
            
            //Aggregate query
            for(AggregateResult result : [Select Program_Subscription__c programSubscription, MAX(SBQQ__SegmentEndDate__c) latestDate, MIN(SBQQ__SegmentStartDate__c) earliestDate
                                          FROM SBQQ__Subscription__c 
                                          Where RecordTypeId = :CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT 
                                          AND Program_Subscription__c != null AND Program_Subscription__c IN : setOfProgSubscriptionId
                                          AND Program_Code__c != null AND Program_Code__c IN :setStartEndDateChangeProducts
                                          GROUP BY Program_Subscription__c])
            {
                //Get the Program Subscription Id
                Id proSubscriotionId =  (Id)result.get('programSubscription');
                
                if(proSubscriotionId != null){
                    
                    if(!mapProgSubscriptionToBeUpdate.containsKey(proSubscriotionId))
                        mapProgSubscriptionToBeUpdate.put(proSubscriotionId, new SBQQ__Subscription__c (Id = proSubscriotionId));
                    
                    if((Date) result.get('earliestDate') != null )
                        mapProgSubscriptionToBeUpdate.get(proSubscriotionId).SBQQ__SubscriptionStartDate__c = (Date)(result.get('earliestDate'));
                    
                    if((Date) result.get('latestDate') != null )
                        mapProgSubscriptionToBeUpdate.get(proSubscriotionId).SBQQ__SubscriptionEndDate__c = (Date)(result.get('latestDate'));
                }
            }
            
            //Checking for map size
            if(mapProgSubscriptionToBeUpdate.size() > 0 && mapProgSubscriptionToBeUpdate.values() != null && mapProgSubscriptionToBeUpdate.values().size() > 0) {
                
                //Bypass the trigger
                Util.BypassAllTriggers = true;
                
                update mapProgSubscriptionToBeUpdate.values();
                
                //Reset the flag
                Util.BypassAllTriggers = false;
            }
        }        
    }
    
    /**
    *
    *   @description    :   This used to populate invoice arrangement on program subscription if blank.
    *
    *   @args           :   List<SBQQ__Subscription__c>, Map<Id, SBQQ__Subscription__c>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V_1.0 - Created - Mahendra Swarnakar   -  06/26/2020 Issue--CR14162--QA--00009945 (CR-20200609-14162) 
    *
    **/
    public static void populateIvoiceArrangementProgSubscription(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions){

        Set<Id> setOfContractIds = new set<Id>();
        Map<Id,Contract> mapOfContract = new Map<Id,Contract>();
        
        //Loop over the Subscription
        for(SBQQ__Subscription__c sub : subscriptions){
            
            //Check for conditions
            if(sub.RecordTypeId == CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM  && (mapOldSubscriptions == null || (mapOldSubscriptions != null
               	&& sub.Invoicing_Arrangement__c != mapOldSubscriptions.get(sub.Id).Invoicing_Arrangement__c))){
                //hold contract id tag on subscription in set
                if(sub.SBQQ__Contract__c != null && string.isBlank(sub.Invoicing_Arrangement__c)){
                    setOfContractIds.add(sub.SBQQ__Contract__c);
                }
            }            
        }
        
        //query on contract to get the Invoicing_Arrangement__c details
        if(setOfContractIds.size() > 0){
            for(Contract con : [Select Id,Invoicing_Arrangement__c From Contract where Id IN: setOfContractIds]){
                mapOfContract.put(con.Id,con);
            }
        }
        
        //update the Invoicing_Arrangement__c field of subscription with contract if it it blank
        for(SBQQ__Subscription__c sub : subscriptions){
            if(mapOfContract.containsKey(sub.SBQQ__Contract__c) && string.isBlank(sub.Invoicing_Arrangement__c)){
                sub.Invoicing_Arrangement__c = mapOfContract.get(sub.SBQQ__Contract__c).Invoicing_Arrangement__c;
            }
        }
	}

       /**
        *  @description    :  This method is used to populate youvisit on subscription period from program subscription having below condition
        *                     a). Recordtype = 'Component Record Type'
        *                     b). SBQQ__ProductName__c on subscription == 'Program Costs'
        * 
        *  @args           :   List of subscriptions, Map of subscription
        * 
        *  @return         :   void
        * 
        * Created By       :   Neha Piproniyan - CR-20200910-14498 - 10/19/2020
        * 		       Modified by - Neha Sharma - CR-20210105-14771 - 05/21/2021 - Update Virtual Tour Package Type Lookup
        **/
    	    public static void UpdateYouVisitFromCPQSubscription(List<SBQQ__Subscription__c> subscriptions, Map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
        
        //Modified by - Neha Sharma - CR-20200910-14498 - 10/19/2020 - List of  Subscription Period to be updated
        //Map<Id,Subscription_Period__c> mapOfSubscriptionPeriod = new Map<Id,Subscription_Period__c>();
        
        //Modified by - Neha Sharma - CR-20210105-14771 - 05/21/2021 - List of Program Subscription to be updated
        Set<ID> setProgramSubscriptionIDs = new Set<Id>();
        
        //Loop over the Subscription
        for(SBQQ__Subscription__c sub : subscriptions){
            
            //Check Component Record Type and Product on CPQ Subscription
            /*if(sub.Subscription_Period__c != null && sub.RecordTypeId == CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT && (mapOldSubscriptions == null || (mapOldSubscriptions != null
            && sub.Subscription_Period__c != mapOldSubscriptions.get(sub.Id).Subscription_Period__c
            || sub.You_Visit_Package_Type_m__c != mapOldSubscriptions.get(sub.Id).You_Visit_Package_Type_m__c)))
            {
            //Update YouVisit Package value of Subscription Period with CPQ Subscription's You Visit package value
            if(sub.SBQQ__Product__c != null && sub.SBQQ__ProductName__c == label.Product_Used_For_YouVisit_Field) {
            
            if(sub.Subscription_Period__c != null && !mapOfSubscriptionPeriod.containsKey(sub.Subscription_Period__c) ){
            
            mapOfSubscriptionPeriod.put(sub.Subscription_Period__c,new Subscription_Period__c(Id = sub.Subscription_Period__c, YouVisit_Package_Type__c = sub.You_Visit_Package_Type_m__c));
            }
            }
            }*/
            
            //Added by - Neha Sharma - CR-20210105-14771 - 05/21/2021 - Update Virtual Tour Package Type Lookup
            //check component record type and product
            if(/*sub.You_Visit_Package_Type_m__c != null &&*/ sub.RecordTypeId == CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT 
               && sub.SBQQ__Product__c != null && sub.SBQQ__ProductName__c == label.Product_Used_For_YouVisit_Field
               && (mapOldSubscriptions == null 
                   || (mapOldSubscriptions != null
                   		&& (sub.You_Visit_Package_Type_m__c != mapOldSubscriptions.get(sub.Id).You_Visit_Package_Type_m__c 
                        	|| sub.Program_Subscription__c != mapOldSubscriptions.get(sub.Id).Program_Subscription__c
                            || sub.SBQQ__SegmentIndex__c != mapOldSubscriptions.get(sub.Id).SBQQ__SegmentIndex__c
                           )))) 
			{
                if(sub.Program_Subscription__c != null )
                	setProgramSubscriptionIDs.add(sub.Program_Subscription__c);
                
                if(mapOldSubscriptions != null && mapOldSubscriptions.get(sub.Id).Program_Subscription__c != null )
                	setProgramSubscriptionIDs.add(mapOldSubscriptions.get(sub.Id).Program_Subscription__c);
                
                
                /*if(sub.Program_Subscription__c != null && !mapOfProgSubscriptionWithSegIndex.containsKey(sub.Program_Subscription__c))
                    mapOfProgSubscriptionWithSegIndex.put(sub.Program_Subscription__c, sub.SBQQ__SegmentIndex__c +','+sub.You_Visit_Package_Type_m__c);
                
                else if(sub.Program_Subscription__c != null && sub.SBQQ__SegmentIndex__c > Integer.valueOf(mapOfProgSubscriptionWithSegIndex.get(sub.Program_Subscription__c).split(',')[0])){
                    mapOfProgSubscriptionWithSegIndex.put(sub.Program_Subscription__c, sub.SBQQ__SegmentIndex__c +','+sub.You_Visit_Package_Type_m__c);
                }*/
                
            }
        }
        
        //Added by - Neha Sharma - CR-20210105-14771 - 05/21/2021 - Update Virtual Tour Package Type Lookup
        //Check for the size
        if(setProgramSubscriptionIDs.size() > 0) {
            
            //Map Program Subscriptions to be updated
            Map<ID, SBQQ__Subscription__c> mapProgramSubscriptions = new Map<ID, SBQQ__Subscription__c>();
            //to hold Program Subscription Ids which is not going to update
            Id programSubscriptionIds;
            //Query over the Component Subscriptions and populating the Map  mapProgramSubscriptions which will have the You_Visit_Package_Type_m__c field value to be update on the Program Subscription
            for(SBQQ__Subscription__c  sub : [Select ID, SBQQ__SegmentIndex__c, You_Visit_Package_Type_m__c, Program_Subscription__c, Program_Subscription__r.You_Visit_Package_Type_m__c 
                                              From SBQQ__Subscription__c
                                              Where Program_Subscription__c != null AND Program_Subscription__c IN : setProgramSubscriptionIDs 
                                              AND You_Visit_Package_Type_m__c != null AND SBQQ__SegmentIndex__c != null AND RecordTypeId = : CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT 
                                              ORDER BY Program_Subscription__c,SBQQ__SegmentIndex__c DESC ] ) 
            {
                if(sub.You_Visit_Package_Type_m__c == sub.Program_Subscription__r.You_Visit_Package_Type_m__c)
                    programSubscriptionIds = sub.Program_Subscription__c;
                
                if(programSubscriptionIds != sub.Program_Subscription__c && !mapProgramSubscriptions.containsKey(sub.Program_Subscription__c) && sub.You_Visit_Package_Type_m__c != sub.Program_Subscription__r.You_Visit_Package_Type_m__c  )
            		mapProgramSubscriptions.put(sub.Program_Subscription__c, new SBQQ__Subscription__c(ID = sub.Program_Subscription__c, You_Visit_Package_Type_m__c = sub.You_Visit_Package_Type_m__c ));             
            }
            
            //Check for size
            if(mapProgramSubscriptions.size() > 0) {
                    
                //Bypassing triggers && Update the Program Subscriptions.
                Util.byPassAllTriggers = true;
                Update mapProgramSubscriptions.values();
                Util.byPassAllTriggers = false;
                
                //to hold subscription periods that going to be updated
                List<Subscription_Period__c> subscriptionPeriodToBeUpdate = new List<Subscription_Period__c>();
                
                //get all Program Subscription releated subscription periods 
                for(Subscription_Period__c subPeriod : [Select Id, Program_Subscription__c, Program_Subscription__r.You_Visit_Package_Type_m__c,YouVisit_Package_Type__c 
                                                        From Subscription_Period__c 
                                                        Where Program_Subscription__c != null And Program_Subscription__c IN: mapProgramSubscriptions.keySet()])
                {
                    if(mapProgramSubscriptions.containsKey(subPeriod.Program_Subscription__c)){
                    	
                        //Update You Visit package Type value  on the SP record                               
                    	subscriptionPeriodToBeUpdate.add(new Subscription_Period__c(Id = subPeriod.Id, YouVisit_Package_Type__c = mapProgramSubscriptions.get(subPeriod.Program_Subscription__c).You_Visit_Package_Type_m__c));
                    }
                }
                
                //check for size
                if(subscriptionPeriodToBeUpdate.size() > 0){
                    
                    //Bypassing triggers and update the SP records.
                    Util.byPassAllTriggers = true;
                    Update subscriptionPeriodToBeUpdate;
                    Util.byPassAllTriggers = false;
                }
            }
        }
              
    }
}