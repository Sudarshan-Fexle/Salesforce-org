/**
 *	Purpose			:	To update the newly created field on the Institution (Web program Access). This is a one time data update batch. 
 *						
 *
 *	Rivision Log	:	V_1.1 - Created - 06/09/2019 - Dipesh Gupta
 *
 **/

global class Batch_WebProgAccOnInstitution implements Database.Batchable<sObject>, Database.Stateful{
	
    public string queryString;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        if(queryString == null)
            queryString = 'Select Id From Account Where Entity__c != \'HC\'';
        
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        
        //Map to hold the Account Id with the Set<Id> (Program ids)
        Map<Id, Set<Id>> mapAccountWithProgramIds = new Map<Id, Set<Id>>();
        
        //Map to hold the Program with the Web Program Access Ids. 
        Map<Id, Set<String>> mapProgramWithWebProgramAccessIds = new Map<Id, Set<String>>();
        
        //Map to hold the Account Ids and Account Instance. 
        Map<Id, Account> mapAccounts = new map<Id, Account>();
 
        //Set to hold the Id of Programs
        Set<Id> setProgramIds = new Set<Id>();
        
        //Set to hold the Account Ids. 
        Set<Id> setAccIds = new Set<Id>();
        
        //Loop on the Scope To Get the Accont Ids. 
        for(Account acc : scope) {
            setAccIds.add(acc.Id);
        }

        //Check the size of the Set. 
        if(setAccIds != null && setAccIds.size() > 0) {
            
            //Query on Membership to get the Active Membership. 
            for(Membership__c paidMembership : [SELECT Id, Name, Program__c, Account_Name__c
                                               	FROM Membership__c WHERE Member__c = TRUE
                                                AND Account_Name__c = : setAccIds] ) {
            	
            	//Adding values to the Map. 
            	if(!mapAccountWithProgramIds.containsKey(paidMembership.Account_Name__c))	
                    mapAccountWithProgramIds.put(paidMembership.Account_Name__c, new Set<Id>());
                        
                //If already contains the account Id the get and update.
                mapAccountWithProgramIds.get(paidMembership.Account_Name__c).add(paidMembership.Program__c); 
                                                    
               	//Filling the set with a programs. 
               	setProgramIds.add(paidMembership.Program__c);
        	}
            
            //Check the size of set. 
            if(setProgramIds.size() > 0 ) {
            	
                //Query for our Programs and Web Program Access MTM records
                for(Program__c progs : [SELECT Id, Name, (SELECT Id, Adv_com_Program_ID__c FROM Web_Program_Access_MTM__r 
                                                          Where Adv_com_Program_ID__c != null)
                                        				  FROM Program__c WHERE Id IN :setProgramIds]) {
                    //Adding values to the Map. 
                    if(!mapProgramWithWebProgramAccessIds.containsKey(progs.Id))	
                    	mapProgramWithWebProgramAccessIds.put(progs.Id, new Set<String>());
                            
                	//Check the size of chile Related Web Program Access Records. 
                    if(progs.Web_Program_Access_MTM__r != null && progs.Web_Program_Access_MTM__r.size() > 0) {
                    	
                    	//Loop on the web program access 
                        for(Web_Program_Access_MTM__c webAccess : progs.Web_Program_Access_MTM__r)  {
                        	
                            //If already contains the account Id the get and update.
                            mapProgramWithWebProgramAccessIds.get(progs.Id).add(String.valueOf(webAccess.Adv_com_Program_ID__c)); 
                        }  
                    }
                }
                
                //Check for the Map size.
                if(mapProgramWithWebProgramAccessIds != null && mapProgramWithWebProgramAccessIds.size() > 0 
                   && mapAccountWithProgramIds != null && mapAccountWithProgramIds.size() > 0) {
                	
                    //Loop on the Map of Accont. 
                    for(Id accId : mapAccountWithProgramIds.keyset()) {
                   		
                        String webProgramAccessIds = '';
                        
                        //Check for the Map have some values. 
                        if(mapAccountWithProgramIds.get(accId).size() > 0) {
                        	
                            //Loop on the set of Program Ids.
                            for(Id pgramId : mapAccountWithProgramIds.get(accId)) {
                            	
                                if(mapProgramWithWebProgramAccessIds.containsKey(pgramId)) {
                                    for(String str : mapProgramWithWebProgramAccessIds.get(pgramId))
                                        webProgramAccessIds += str+',';
                                }
         					}
                            
                            webProgramAccessIds = webProgramAccessIds.removeEnd(',');
                            
                            //Adding the values in the Account Map. 
                           // mapAccounts.put(accId, new Account(Id = accId, Web_Program_Access__c = webProgramAccessIds));
                        }
                    }
                       
                    //Check for the size of the Map. 
                    if(mapAccounts != null && mapAccounts.size() > 0) {
                    	Util.ByPassAllTriggers = true;
                        update mapAccounts.values();
                        Util.ByPassAllTriggers = false;
                    }
                }
            }
        }
     }
    
    global void finish(Database.BatchableContext BC){

    }
}