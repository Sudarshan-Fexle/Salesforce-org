/**
 *  Description     :  Batch executes nightly to update all Memberships where Next Decision Date < TODAY.
 * 						Next decision date is replaced with the nearest decision date based on opps or subscription periodswe "Pending" stage.
 *
 *  Created By      :  
 *
 *  Created Date    :  03/28/2012
 *
 *  Revision Logs   :   V_2.0 - Modified by Victor Hanson - 08/17/2017 - Issue--CR11106--QA--00005464 - Next decision date now populates properly on Memberships using the new CPQ architecture
 * 						V_2.1 -Modified By - Subhash Garhwal - 12/03/2018 - CR-20180726-12469 - Commented the "UpdateNextDecisionDate" and "calcNextDecisionDateFromCPQOpps" Method invocation via this batch.
 * 								And update the code logic of this batch to work with the new logic as mentioned in the Method "SubscriptionPeriodTriggerHelper.calculateNextDecisionDate()" 
 * 
 **/
global class Batch_MembershipNextActivityDate implements Database.Batchable<SObject>, Database.Stateful {
    
    //Commented By - Subhash Garhwal - 12/03/2018 - CR-20180726-12469 - Starts from here
    /*global final String Entity;
    global final String Field;
    global final String Value;
    */
    //Commented By - Subhash Garhwal - 12/03/2018 - CR-20180726-12469 - Ends here
    
    //String variable to hold the entire log message string value
    global String debugLog;
    global final String Query;
    
    //Constructor
    global Batch_MembershipNextActivityDate(String q)
    {
        Date dt = Date.today();
        String datetoday = String.valueof(dt);
        Query = q;
        debugLog = '';
        if (Query == null) {
        	//Commented By - Subhash Garhwal - 12/03/2018 - CR-20180726-12469
            /*Query='SELECT Id, Account_Name__c, Program__c, Next_Decision_Date__c, (SELECT Id, Start__c, Opt_Out_Date__c FROM Opportunities__r WHERE Status__c = \'Pending\' '+
                'AND Start__c >= ' + datetoday + 'ORDER BY Start__c ASC) FROM Membership__c ' +
                'WHERE Next_Decision_Date__c != null AND Next_Decision_Date__c < ' + datetoday;
			*/
            
            Query = 'SELECT Id FROM Membership__c where (Next_Decision_Date__c = null AND Membership_Status_Text__c != \'Prospect - Pure\') OR (Next_Decision_Date__c != null AND Next_Decision_Date__c < ' + datetoday+')';
        }
    } 
    
    //Batch starts Method 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(Query);
    }
    
    //Batch Execute Method
    global void execute(Database.BatchableContext BC,List<sObject> scope)
    {
        
    	//Added By - Subhash Garhwal - 12/03/2018 - CR-20180726-12469 - Starts from here
    	//Map to hold the Memberships
    	Map <Id, Membership__c> mapMemberships = New Map <Id, Membership__c>();
    	
    	//Loop over the queried results
    	for(Membership__c mem : (List<Membership__c>) scope){
    		
    		//populate the amp
			if(!mapMemberships.containsKey(mem.Id))
    			mapMemberships.put(mem.Id, new Membership__c(Id = mem.Id, Next_Decision_Date__c = null ));
    	}
    	
    	//Check for size
    	if(mapMemberships.size() > 0){
    		
    		//Method call
    		mapMemberships = SubscriptionPeriodTriggerHelper.calculateNextDecisionDate(mapMemberships);
    		
    		//Check for size
    		if(mapMemberships != null && mapMemberships.size() > 0 && mapMemberships.values().size() > 0 ){
    			
                //disable all triggers to execute
                Util.BypassAllTriggers = true;
                
    			//Update the Membership records
    			debugLog += Util.createLog(Database.update(mapMemberships.values(),false));
    			
                //Enable all trigger 
                Util.BypassAllTriggers = false;		
    		}
    	}
    	//Added By - Subhash Garhwal - 12/03/2018 - CR-20180726-12469 - Ends here
        
        
        //Commented By - Subhash Garhwal - 12/03/2018 - CR-20180726-12469 - Starts from here
        /*List<Membership__c> memberships = (List<Membership__c>)scope;
        
        //Added By Abhinav Sharma - 02/12/2014 - Modify Batch_MembershipNextActivityDate to it uses System.Update() with AllOrNone = false so one failure won't cause the entire batch to fail.
        //Also, if there are failures in the database.saveResults[], they should be recorded and emailed to SFAdmin. - CR-20130718-3280
       
        String logMessage = OpportunityTriggerUtilities.UpdateNextDecisionDate(memberships);
        
        //VH 8/17/2017 - 
        //get the set of account and program ids
        Set<String> ukAccountProgramOnMembership = new Set<String>();
        Set<Id> programIds = new set<Id>();
        Set<Id> accountIds = new set<Id>();
        for (Membership__c m : memberships)
        {
            
            ukAccountProgramOnMembership.add(m.Account_Name__c + '-' + m.Program__c);
            accountIds.add(m.Account_Name__c);
            programIds.add(m.Program__c);
        }
        
        //update the next decision date and log the response
       	
        logMessage = OpportunityTriggerUtilities.calcNextDecisionDateFromCPQOpps(ukAccountProgramOnMembership, programIds, accountIds);
        debugLog += logMessage; 
        */
        //Commented By - Subhash Garhwal - 12/03/2018 - CR-20180726-12469 - Ends here
    } 
    
    global void finish(Database.BatchableContext BC)
    {
        // find all scheduled jobs with no Next Fire date and un-schedule them.
        Util.unscheduleJobsWithoutNextFireDate();
            
        //Also, if there are failures in the database.saveResults[], they should be recorded and emailed to SFAdmin. - CR-20130718-3280
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLog != '') {
            
            //Send log to admin
            Util.sendBatchStatus(BC.getJobId(), 'Batch_MembershipNextActivityDate', debugLog, Label.Salesforce_Admin_Email);
        }
        
        // VRH 4/9/12 - start the next batch by kicking off a scheduled job
        System.schedule('Sched_MeetingUtilizations' + System.now().getTime(), Util.getChronExpressionFromDateTime(System.now().addSeconds(20)), new Sched_MeetingUtilizations());
    }
}