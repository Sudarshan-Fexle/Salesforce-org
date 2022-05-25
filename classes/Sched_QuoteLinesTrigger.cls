/**
 *  Description     :  Scheduler class to execute the Quoteline trigger(Insert Case only)
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  01/06/2020
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20200116-13628
 *			V_1.1 - Modified By Subhash Garhwal - 04/16/2020 - CR-20200409-13923
 *
 **/
global class Sched_QuoteLinesTrigger implements Schedulable{
	
    //Variables
	public List<SBQQ__QuoteLine__c> quoteLines;
    
    //Variables
	public Map<Id, SBQQ__QuoteLine__c> mapOldProposalLines;
    
    //Variables
	public boolean BYPASS_SORT_ORDER_METHOD; 
    
    //Variables
	public boolean BYPASS_UPDATEPREVIOUSSEGMENTPRICE; 
    
    //Variables
	public boolean BYPASS_POPULATEAMENDPROPOSALLINESLISTPRICE;
    
    //Variables
	public boolean executeSyncProgramOpportunitiesLogic;
    //Variables
	public boolean IsInsert;
    
    //Variables
	public boolean isUpdate;
    public static boolean quoteLineTriggerFromScheduler = false;
    public Set<Id> setProposalIds;
    
    //Constructor
    public Sched_QuoteLinesTrigger(Set<Id> setProposalIds, List<SBQQ__QuoteLine__c> quoteLines, boolean BYPASS_SORT_ORDER_METHOD, boolean BYPASS_UPDATEPREVIOUSSEGMENTPRICE, boolean BYPASS_POPULATEAMENDPROPOSALLINESLISTPRICE, boolean executeSyncProgramOpportunitiesLogic, boolean IsInsert, boolean isUpdate) {
        
        system.debug('@@@@@ In Sched_QuoteLinesTriggers Constructor  ');
        this.setProposalIds = setProposalIds;
        this.quoteLines = quoteLines;
        this.BYPASS_SORT_ORDER_METHOD = BYPASS_SORT_ORDER_METHOD;
        this.BYPASS_UPDATEPREVIOUSSEGMENTPRICE = BYPASS_UPDATEPREVIOUSSEGMENTPRICE;
        this.BYPASS_POPULATEAMENDPROPOSALLINESLISTPRICE = BYPASS_POPULATEAMENDPROPOSALLINESLISTPRICE;
        this.executeSyncProgramOpportunitiesLogic = executeSyncProgramOpportunitiesLogic;
        this.IsInsert = IsInsert;
        this.isUpdate = isUpdate;
        
    }
    
    //Execute method to process the quoteline Trigger
    global void execute(SchedulableContext ctx) {
    	system.debug('@@@@@ In Sched_QuoteLinesTriggers scheduler execute method  ');
    	//Set to hold the Sub Ids
		Set<Id> setQuotelineIds = new Set<Id>();
		
		for(SBQQ__QuoteLine__c qline : quoteLines)
        	setQuotelineIds.add(qline.Id);
        
        try{
        	//Call method 
        	executeQuotelineTrigger(setProposalIds, setQuotelineIds, BYPASS_SORT_ORDER_METHOD, BYPASS_UPDATEPREVIOUSSEGMENTPRICE, BYPASS_POPULATEAMENDPROPOSALLINESLISTPRICE, executeSyncProgramOpportunitiesLogic, IsInsert, isUpdate);    
        
        } catch(Exception e){
            if(e.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW') || e.getMessage().containsIgnoreCase('Too many queueable jobs')) {
                
                system.debug('@@@@@@@ ' + e.getMessage());
                
                //Call Scheduler from here
            	Sched_QuoteLinesTrigger.scheduleQuotelineTrigger(setProposalIds, quoteLines, BYPASS_SORT_ORDER_METHOD, BYPASS_UPDATEPREVIOUSSEGMENTPRICE, BYPASS_POPULATEAMENDPROPOSALLINESLISTPRICE, executeSyncProgramOpportunitiesLogic, IsInsert, isUpdate);
            }
        }
    }
    
    
    /**
     *  @description		:	Schedules the job that execute Subscription after triggers
     *  
     *	@args           	:   List<SBQQ__QuoteLine__c>
     *
     *  @return         	:   void
     * 
     *  @Revision Logs		:	V1.1 - 01/07/2020 - Created 
     *
    **/
    
    public static void scheduleQuotelineTrigger(Set<Id> setProposalIds, List<SBQQ__QuoteLine__c> quoteLines, boolean BYPASS_SORT_ORDER_METHOD, boolean BYPASS_UPDATEPREVIOUSSEGMENTPRICE, boolean BYPASS_POPULATEAMENDPROPOSALLINESLISTPRICE, boolean executeSyncProgramOpportunitiesLogic, boolean IsInsert,boolean isUpdate ) {
    	system.debug('@@@@@ In scheduleQuotelineTrigger method: Scheduling the Quoteline trigger ');
    	//Schedule the job
        DateTime sysTime = DateTime.now().addMinutes(5); 
        
        System.debug('######sysTime: ' +sysTime);
        
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        System.debug('######chron_exp: ' +chron_exp);
        
        Sched_QuoteLinesTrigger quotelineTriggerJob = new Sched_QuoteLinesTrigger( setProposalIds, quoteLines, BYPASS_SORT_ORDER_METHOD, BYPASS_UPDATEPREVIOUSSEGMENTPRICE, BYPASS_POPULATEAMENDPROPOSALLINESLISTPRICE, executeSyncProgramOpportunitiesLogic, IsInsert, isUpdate);
        
        System.schedule('Sched_QuoteLinesTrigger' + sysTime.getTime(),chron_exp, quotelineTriggerJob);
        
        System.debug('######subTriggerJob: ' +quotelineTriggerJob);
        
    }
    
    
    /**
     *  @description		:	Execute Quoteline trigger methods (Before Insert case only).
     *  
     *	@args           	:   Set<Id>
     *
     *  @return         	:   void
     * 
     *  @Revision Logs		:	V1.1 - 01/07/2020 - Created - 
     *
    **/
    @future
	public static void executeQuotelineTrigger(Set<Id> setProposalIds, Set<Id> setQuotelineIds, boolean BYPASS_SORT_ORDER_METHOD, boolean BYPASS_UPDATEPREVIOUSSEGMENTPRICE, boolean BYPASS_POPULATEAMENDPROPOSALLINESLISTPRICE, boolean executeSyncProgramOpportunitiesLogic, boolean IsInsert,boolean isUpdate) {
        
        system.debug('@@@@@ In executeQuotelineTrigger future method ');
        //SBQQ_QuoteLineTriggerHelper.RENEWAL_PROPOSALLINE_FROM_SCHEDULER = true; 
        
        quoteLineTriggerFromScheduler = true;
        SBQQ_QuoteLineTriggerHelper.BYPASS_SORT_ORDER_METHOD = BYPASS_SORT_ORDER_METHOD;
        SBQQ_QuoteLineTriggerHelper.BYPASS_UPDATEPREVIOUSSEGMENTPRICE = BYPASS_UPDATEPREVIOUSSEGMENTPRICE;
        SBQQ_QuoteLineTriggerHelper.BYPASS_POPULATEAMENDPROPOSALLINESLISTPRICE = BYPASS_POPULATEAMENDPROPOSALLINESLISTPRICE;
        SBQQ_QuoteLineTriggerHelper.executeSyncProgramOpportunitiesLogic = executeSyncProgramOpportunitiesLogic;
        
        //SOQL over the Subscriptions
		List<SBQQ__QuoteLine__c> quotelines = Database.query(buildSOQL(setQuotelineIds, setProposalIds));
		Map<Id, SBQQ__QuoteLine__c> mapQuotelines = new Map<Id, SBQQ__QuoteLine__c>(quotelines);
		
        /** Before Insert Methods starts from here **/
        
        SBQQ_SubscriptionTriggerHelper.twinFields(quoteLines);
        
        SBQQ_QuoteLineTriggerHelper.populateESLinesOnAmendment(quoteLines);
        
        SBQQ_QuoteLineTriggerHelper.populateQuoteLineFieldsForCPQ(quoteLines);
        
        SBQQ_QuoteLineTriggerHelper.updateProrateMultiplier(quoteLines);
        
        SBQQ_QuoteLineTriggerHelper.populatePreviousContractLastYearQuantity(quoteLines);
        
        SBQQ_QuoteLineTriggerHelper.updateFieldsForMainProductLines(quoteLines);
        
	//Updated by Subhash Garhwal - 04/16/2020 - CR-20200409-13923 - Start here
        //SBQQ_QuoteLineTriggerHelper.syncPHCustomerTotal(quoteLines);
	//Updated by Subhash Garhwal - 04/16/2020 - CR-20200409-13923 - Ends here
        
        SBQQ_QuoteLineTriggerHelper.blankOptOutAndEarlyTerminationDateOnMainProposalLine(quoteLines, true);
                    
        SBQQ_QuoteLineTriggerHelper.updateStandardPricing(quoteLines, null);
        
        if(!SBQQ_QuoteLineTriggerHelper.BYPASS_SORT_ORDER_METHOD)
            SBQQ_QuoteLineTriggerHelper.syncSortOrder(quoteLines);
                    
        SBQQ_QuoteLineTriggerHelper.updateSegmentLabel(quoteLines);
        
        if(!SBQQ_QuoteLineTriggerHelper.BYPASS_UPDATEPREVIOUSSEGMENTPRICE)
            SBQQ_QuoteLineTriggerHelper.updatePreviousSegmentPrice(quoteLines);
        
        if(!SBQQ_QuoteLineTriggerHelper.BYPASS_POPULATEAMENDPROPOSALLINESLISTPRICE)
            SBQQ_QuoteLineTriggerHelper.populateAmendProposalLinesListPrice(quoteLines, null, IsInsert, isUpdate); 
        
        SBQQ_QuoteLineTriggerHelper.updateQuantityOnAmendmentQuoteLines(quoteLines);
        
        SBQQ_QuoteLineTriggerHelper.checkRenewalsForRoundingBug(quoteLines, null);
        
        SBQQ_QuoteLineTriggerHelper.updateQuantity(quoteLines);
        
        SBQQ_QuoteLineTriggerHelper.populateSpecialPriceType(quoteLines, null);
        
        
        //Util.BypassAllTriggers = true;
        update quoteLines;
        //Util.BypassAllTriggers = false;
        
        /** Before Insert Methods Ends here **/
        
        /** After Insert Methods starts from here **/
        
        SBQQ_QuoteLineTriggerHelper.updateThresholdValueOnOpportunity(quoteLines);
        
        SBQQ_QuoteLineTriggerHelper.validateAutomatedProductCreationProcess(quoteLines);
        
        SBQQ_QuoteLineTriggerHelper.rollUpCreditAndProfitAdjustment(quoteLines, null);
        
        if(SBQQ_QuoteLineTriggerHelper.executeSyncProgramOpportunitiesLogic)
            SBQQ_QuoteLineTriggerHelper.validateQuoteYearOneDiscount(quoteLines, null);
        
        SBQQ_QuoteLineTriggerHelper.validateGradeCriteriaCommittedTermLength(quoteLines, null);
        
        SBQQ_QuoteLineTriggerHelper.populateTopParentOnQuoteLines(quoteLines);
        
        SBQQ_QuoteLineTriggerHelper.ValidateESAMAndESOAMProducts(quoteLines, null);
        
        SBQQ_QuoteLineTriggerHelper.updateOptOutOnMainProposalLine(quoteLines, null);
        
        SBQQ_QuoteLineTriggerHelper.syncupProgramPackages(quoteLines, null);
        
        SBQQ_QuoteLineTriggerHelper.updateOpportunityPrimaryProposal(setProposalIds);
        
		
        /** After Insert Methods Ends here **/
    }
    
    /**
     *  @description    :   This method is used to build the SOQL query String.
     *
     *  @args           :   Set<Id> setSubscriptionIds
     *
     *  @return         :   String
     *
     **/
    public static String buildSOQL(Set<Id> setQuotelineIds, Set<Id>  setProposalIds) {
        
        //SOQL query
        String SOQL = 'Select ';
        
        //Get Subscription fields
        Map<String, Schema.SObjectField> subFields = Schema.SObjectType.SBQQ__Quoteline__c.fields.getMap();
         
        //Get the field of the object'
        for(String field : subFields.keySet())
            SOQL += field + ',';
        
        //Remove extra elements and add object
        //SOQL = SOQL.removeEnd(',') + ' From SBQQ__Quoteline__c Where Id IN : setQuotelineIds';
        SOQL = SOQL.removeEnd(',') + ' From SBQQ__Quoteline__c Where SBQQ__Quote__c IN : setProposalIds';
        
        //Return 
        return SOQL;
        
    }
    
}