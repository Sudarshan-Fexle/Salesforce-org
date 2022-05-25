/**
 *  Description     :  Scheduler class to execute the Subscription trigger
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  03/08/2018
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
 *                      V_1.1 - Modified - Colin McGloin - Commented out updateLISWithProgramSubscriptionIBS method - CR-20190724-13232
 * 			V_1.2 - 09/04/2019 - Victor Hanson - CR-20190904-13310: Updated scheduleSubscriptionTrigger()
 *                      V_1.3 - 09/13/2019 - Colin McGloin - CR-20190829-13298 - Removed call to populateGAAPFieldsOnAmendment method
 *			V_1.4 - Modified By - Mahendra Swarnkar - 05/22/2020 - CR-20191211-13560 - Commented out the logic to populate the Join_Date_Most_Recent__c field on membership
 *			V_1.5 - Modified By - Subhash Garhwal - 08/18/2020 - CR-20201215-14746
 *
 **/
global class Sched_SubscriptionTrigger implements Schedulable {
	
	//Variables
	public List<SBQQ__Subscription__c> subscriptions;
    
    //Variables for trigger.IsInsert case
	public Boolean isInsertCase;
	
	//Constructor
    public Sched_SubscriptionTrigger(List<SBQQ__Subscription__c> subscriptions, Boolean isInsertCase) {
        this.subscriptions = subscriptions;
        this.isInsertCase = isInsertCase;
    }
    
    //Execute method to process the Subscription Trigger
    global void execute(SchedulableContext ctx) {
    	
    	//Set to hold the Sub Ids
		Set<Id> setSubscriptionIds = new Set<Id>();
		
		for(SBQQ__Subscription__c sub : subscriptions)
        	setSubscriptionIds.add(sub.Id);
        	
    	//Call method 
        executeSubscriptionTrigger(setSubscriptionIds, isInsertCase);
    }
    
    /**
     *  @description		:	Schedules the job that execute Subscription after triggers
     *  
     *	@args           	:       List<SBQQ__Subscription__c>
     *
     *  @return         	:   	void
     * 
     *  @Revision Logs		:	V1.1 - 03/08/2018 - Created - Subscription - CR-20181019-12685
     * 				        V1.2 - 09/04/2019 - Victor Hanson - CR-20190904-13310: Increase delay from 2min to 5mins
     *
    **/
    
    public static void scheduleSubscriptionTrigger(List<SBQQ__Subscription__c> subscriptions, Boolean isInsertCase) {
    	
    	//Schedule the job
        DateTime sysTime = DateTime.now().addMinutes(5);

        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        Sched_SubscriptionTrigger subTriggerJob = new Sched_SubscriptionTrigger(subscriptions, isInsertCase);
        System.schedule('Sched_SubscriptionTrigger' + sysTime.getTime(),chron_exp, subTriggerJob);
    }
    
    /**
     *  @description		:	Execute Subscription trigger methods.
     *  
     *	@args           	:   Set<Id>
     *
     *  @return         	:   void
     * 
     *  @Revision Logs		:	V1.1 - 03/08/2018 - Created - Subscription - CR-20181019-12685
     *
    **/
    @future
    public static void executeSubscriptionTrigger(Set<Id> setSubscriptionIds, Boolean isInsertCase) {
			
    	//SOQL over the Subscriptions
	List<SBQQ__Subscription__c> subscriptions = Database.query(buildSOQL(setSubscriptionIds));
	Map<Id, SBQQ__Subscription__c> mapSubscriptions = new Map<Id, SBQQ__Subscription__c>(subscriptions);
		
        if(isInsertCase){
            SBQQ_SubscriptionTriggerHelper.IS_INSERT_CASE = true;
        }
        
        //Call Subscription after trigger method
        SBQQ_SubscriptionTriggerHelper.createMembershipWithCIA(subscriptions);  
        SBQQ_SubscriptionTriggerHelper.updateStatusForAmendment(subscriptions);
        SBQQ_SubscriptionTriggerHelper.populateProgramSubscription(subscriptions, null);
        
	// Added by Subhsh Garhwal 08/18/2020 - CR-20201215-14746
        //SOQL over the Subscriptions
	subscriptions = Database.query(buildSOQL(setSubscriptionIds));
	mapSubscriptions = new Map<Id, SBQQ__Subscription__c>(subscriptions);
        
        SBQQ_SubscriptionTriggerHelper.populateStartEndDateOnESFOProgramSubscription(subscriptions, null);
        
        SBQQ_SubscriptionTriggerHelper.updateMembershiponProgramSubscription(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.createSubscriptionPeriodforUniqueComponent(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.populateRenewalPriceFieldOnCompSubscription(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.validateFinalPeriodNegotiatedOnProgramSubscription(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.updateFinalPeriodUpliftonProgramSubscription(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.populateTypeOnContract(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.validateContractABC(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.populateSubscriptionFieldsOnMembership(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.updatePendingSPNegotiatedAmountPeriod(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.checkComponentSubscription(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.syncProgramPackages(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.calculateNextDecisionDate(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.updateCurrentYearFeesOnMembership(subscriptions, null);
        
        //Commented By- Mahendra Swarnkar - 05/22/2020 - CR-20191211-13560 - Commented out the logic to populate the Join_Date_Most_Recent__c field on membership.
	//SBQQ_SubscriptionTriggerHelper.updateJoinDateMostRecentOnMembership(mapSubscriptions, null);
		
        SBQQ_SubscriptionTriggerHelper.updateContractABC(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.populateFieldsValueOnCases(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.validateSubscriptionPeriods(subscriptions, null);
        //SBQQ_SubscriptionTriggerHelper.updateLISWithProgramSubscriptionIBS(subscriptions);
	SBQQ_SubscriptionTriggerHelper.updateMembershipStatusBySubscription(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.updateOpportunityFields(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.populateFieldsOnCaseFromSubscription(subscriptions, null);
        
        //By pass the validation for insert usecase.
	if( !isInsertCase){
		SBQQ_SubscriptionTriggerHelper.validateIBSIdForProgramSubscription(subscriptions, null);
        }
        
        SBQQ_SubscriptionTriggerHelper.syncPreviousPeriodNegotiatedOnSubPeriod(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.updateContractABCRenewalOpportunity(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.populateOwnerManagerEmailToSubPeriod(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.calculateACVAndProfit(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.populateProductCode(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.rollUpTotalPaidSubscription(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.rollupNegotiatedAmountPeriodOnSubscriptionPeriod(subscriptions, null);
	SBQQ_SubscriptionTriggerHelper.updateTravelandAnnualFeesonComponentSubscription(subscriptions,null);
	SBQQ_SubscriptionTriggerHelper.updateProposalvalue(subscriptions,null);
	SBQQ_SubscriptionTriggerHelper.syncTotalContractQuantity(subscriptions,null);
	SBQQ_SubscriptionTriggerHelper.populatePreviousCurrentNextYearProgramCost(subscriptions,null);
	SBQQ_SubscriptionTriggerHelper.rollupDetailsonProgramSubscriptionFromComponentSubscription(subscriptions,null);
        SBQQ_SubscriptionTriggerHelper.rollupDetailsOnUltimateProgramSubscriptionFromDirectProgramSubs(subscriptions,null);
	SBQQ_SubscriptionTriggerHelper.populateStdContractFields(subscriptions,null);
	SBQQ_SubscriptionTriggerHelper.rollupCompSubToSubPeriod(subscriptions,null);
        //Removed call to this method as part of CR-20190829-13298
        //SBQQ_SubscriptionTriggerHelper.populateGAAPFieldsOnAmendment(subscriptions,null);
    }
    
    /**
     *  @description    :   This method is used to build the SOQL query String.
     *
     *  @args           :   Set<Id> setSubscriptionIds
     *
     *  @return         :   String
     *
     **/
    public static String buildSOQL(Set<Id> setSubscriptionIds) {
        
        //SOQL query
        String SOQL = 'Select ';
        
        //Get Subscription fields
        Map<String, Schema.SObjectField> subFields = Schema.SObjectType.SBQQ__Subscription__c.fields.getMap();
         
        //Get the field of the object'
        for(String field : subFields.keySet())
            SOQL += field + ',';
        
        //Remove extra elements and add object
        SOQL = SOQL.removeEnd(',') + ' From SBQQ__Subscription__c Where Id IN : setSubscriptionIds';
        
        //Return 
        return SOQL;
        
    }
}