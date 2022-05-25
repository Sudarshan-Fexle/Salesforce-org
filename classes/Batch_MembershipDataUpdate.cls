/*
    Purpose         :   batch class to update memberShip and membershipPeriod
                
    Create By       :   Mahendra Swarnkar
    
    Created Date    :   12/09/2019
    
    Revision Log    :   V1.0 Created
						
    
*/
global class Batch_MembershipDataUpdate implements Database.Batchable<SObject>, Database.Stateful {
    
    //Variables to hold the query string literal
    public String Query = null;
    
    //String variable to hold the entire log message string value
    global String debugLogStr;
    
    //Set of FAO product
    //public static final Set<String> setOfFAOProduct = new Set<String>{'ESFAO-ESYO', 'ESIQS-ESYO', 'ESRTA-ESYO', 'ESTFAO-ESYO', 'ESFAD-ESYO', 'ESFBM-ESYO', 'ESFYT-ESYO', 'ESNPC-ESYO'};
    //'ESXFRR',
    public static final Set<String> setOfFAOProduct = new Set<String>{ 'ESXFR-ESXFRR', 'ESCXFR-ESXFRR', 'ESTDIQ-ESXFRR'};
	
    //Constructor
    global Batch_MembershipDataUpdate() {
        
        //Initialization of variable
        debugLogStr = '';
        
        //Checking string literal of null value
        if(Query == null) {
            //SOQL filter for program subscription for FAO product
            Query =  'Select Id, Product_Code__c, Membership__c, SBQQ__Account__c, Top_Parent_Product__c, RecordType.Developername, Job_No_Product_Code_Combination_m__c From SBQQ__Subscription__c ';
            Query += 'Where Job_No_Product_Code_Combination_m__c IN: setOfFAOProduct And RecordType.Developername = \'Program\'';
        }
    }
    
    //Start Method
    global Database.Querylocator start(Database.BatchableContext BC) {
    	
    	//Debugging query string literal   
        system.debug('@@Query:' + Query);
        
        //Retrieving and returning membership records
        return Database.getQueryLocator(Query);
    }
    
    //Execute Method
    global void execute(Database.BatchableContext BC, SObject[] scope) {
        
        //Translate the Query from the QueryLocator into a list of subscription
        List<SBQQ__Subscription__c> programSubscription = (list<SBQQ__Subscription__c>)scope;
        System.debug('programSubscription ::::::' +programSubscription.size());
        
        //List of programSubscription to update
        List<SBQQ__Subscription__c> programSubscriptionToUpdate = new List<SBQQ__Subscription__c>();
        
        //List of subscriptionPeriod to update
        List<Subscription_Period__c> subscriptionPeriodToUpdate = new List<Subscription_Period__c>();

		//List of component subsciption to update
		List<SBQQ__Subscription__c> componentSubscriptionToUpdate = new List<SBQQ__Subscription__c>();

        //Set of account Ids
        Set<Id> accountIds = new Set<Id>();
        
        //Set of programSubscriptionId
        Set<Id> programSubscriptionIds = new Set<Id>();

		//Set of subscriptionPeriodIds
		Set<Id> subscriptionPeriodIds = new Set<Id>();
        
        //Map of FAO mambership with accountId as key
        Map<Id, Id> mapOfAccountWithFAOMembership = new Map<Id, Id>();
        
        //Loop over program subscription
        for(SBQQ__Subscription__c sub : programSubscription){
            accountIds.add(sub.SBQQ__Account__c);
            programSubscriptionIds.add(sub.Id);
        }

        if(accountIds.size() > 0){
            //Loop over membership
            for(Membership__c mem : [Select Id, Program_Acronym__c, Account_Name__c From Membership__c Where Account_Name__c IN: accountIds And Program_Acronym__c = 'RYFA']){
                if(!mapOfAccountWithFAOMembership.containsKey(mem.Account_Name__c))
                    mapOfAccountWithFAOMembership.put(mem.Account_Name__c, mem.Id);
            }
            
            //Loop over program subscription
            for(SBQQ__Subscription__c sub : programSubscription){
                if(mapOfAccountWithFAOMembership.containsKey(sub.SBQQ__Account__c)){
                    programSubscriptionToUpdate.add(new SBQQ__Subscription__c(Id = sub.Id, Top_Parent_Product__c = '01tC0000002r15oIAA', Membership__c = mapOfAccountWithFAOMembership.get(sub.SBQQ__Account__c)));
                }
            }
            
            //Size check
            if(programSubscriptionToUpdate.size() > 0){
                //update
                update programSubscriptionToUpdate;
            }
            
        }
        
        if(programSubscriptionIds.size() > 0){
            
            //List of subscriptionPeriod
            List<Subscription_Period__c> subscriptionPeriods = [Select Id, Program_Subscription__c, Membership_Lookup__c, Program_Package__c, Institution__c, 
                                                                Period_End_Date__c, Program_Subscription__r.SBQQ__Product__c,Program_Subscription__r.SBQQ__Product__r.ProductCode  
                                                                from Subscription_Period__c Where Program_Subscription__c IN :programSubscriptionIds];
            
            //Loop over subsciptionPeriod
            for(Subscription_Period__c sP  : subscriptionPeriods){
                if(mapOfAccountWithFAOMembership.containsKey(sP.Institution__c)){
					subscriptionPeriodIds.add(sP.Id);
                    subscriptionPeriodToUpdate.add(new Subscription_Period__c(Id = sP.Id, Membership_Lookup__c = mapOfAccountWithFAOMembership.get(sP.Institution__c)));
                }
            }
            
            //Size check
            if(subscriptionPeriodToUpdate.size() > 0){
                //Update
                update subscriptionPeriodToUpdate;
            }

			for(SBQQ__Subscription__c sub : [Select Id, Program_Subscription__c, Top_Parent_Product__c, Membership_Period__c, Subscription_Period__c 
											 From SBQQ__Subscription__c Where Program_Subscription__c IN :programSubscriptionIds And RecordType.Developername = 'Component']){

				componentSubscriptionToUpdate.add(new SBQQ__Subscription__c(Id = sub.Id, Top_Parent_Product__c = '01tC0000002r15oIAA'));
            }
            
            if(componentSubscriptionToUpdate.size() > 0){
                
                //Update
                update componentSubscriptionToUpdate;
            }
            
            Sched_ProgramPackageCreation sch = new Sched_ProgramPackageCreation(subscriptionPeriodToUpdate);
            sch.setProgramPackageOnSP();
        }
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC) {
    
        
    }
}