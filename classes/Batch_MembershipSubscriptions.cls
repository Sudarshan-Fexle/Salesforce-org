/*
    Purpose         :   batch class to update member subscriptions
                
    Create By       :   Victor Hanson
    
    Created Date    :   3/13/2013
    
    Revision Log    :   V1.0 Created
    			V1.1 - Modified By - Abhinav Sharma - 04/22/2014 - CR-20140331-4909 - Updates to batch failure process
			V1.2 - Modified By - Victor Hanson - 10/15/2015 - CR-20140407-4977 -  Updated the process that gets eligible subscription options by 
			                                                        only querying once and storing in a map.
										Also deleted old commented-out code.
			V1.3 - Modified By - Abhinav Sharma - 10/30/2015 - CR-20140407-4977 - Replace SOQL queries inside a for loop and placed appropriate logic in place
										to have a same logic with the help of collection 
										(Also have updated the work order of this CR to have description of additional made changes)
			V1.4 - Modified By - Seemu Saikia - CR-20190501-13072- 05/08/2019 - #Spring CleanUp
			V1.5 - Modified By - Neha Sharma - 05/19/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
    
*/
global class Batch_MembershipSubscriptions implements Database.Batchable<SObject>, Database.Stateful {
    
    //CR-20140407-4977 - 10/30/2015 - Abhinav Sharma - Removed unnecessary variables from the class
    //Variables to hold the query string literal
    public String Query = null;
    
    //Added By Abhinav Sharma - 04/18/2014 - CR-20140331-4909
    //String variable to hold the entire log message string value
    global String debugLogStr;
    
    //Constructor
    global Batch_MembershipSubscriptions() {
        
        //Initialization of variable
        debugLogStr = '';
        
        //Checking string literal of null value
        if(Query == null) {
        	
        	//CR-20140407-4977 - 10/30/2015 - Abhinav Sharma - Included Membership_Status__c in the query string
            //SOQL filter. By default, only look at Contracts that just ended yesterday.
            Query =  'SELECT Id, Account_Name__c, Program__c, Membership_Status__c FROM Membership__c ';
            Query += 'WHERE Membership_Status_Change_Date__c >= YESTERDAY '; /// anything that dropped yesterday or today
            Query += 'AND (NOT Membership_Status__c LIKE \'Member%\') '; // just in case we have a membership that is honorary or grace status
            Query += 'ORDER BY createddate desc';
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
    	
        //Translate the Query from the QueryLocator into a list of Memberships
        List<Membership__c> membershipsDroppedYesterday = (list<Membership__c>)scope;                                                          
        
        //Create a list of subscriptions to upsert
        //Spring CleanUp
        //List<Subscription__c> subscriptionsToUpdate = new List<Subscription__c>();
        //List<Subscription__c> keyConSubscriptionsToUpdate =  new List<Subscription__c>();
        List<Membership_Key_Contact__c> allKeyConsForDelete = new List<Membership_Key_Contact__c>();
        
        //String variable to hold the error message string in case of any failure
        String logMessage = '';
        
        //CR-20140407-4977 - 10/30/2015 - Added By - Abhinav Sharma - memory allocation to collections useful for bulk processing of records
        //Start from here
        //Set to hold the dropped memberships account Ids
	//Commented By - Neha Sharma - 05/19/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        //Set<Id> setAccountsIds = new Set<Id>();
        
        //Map of dropped memberships
        Map<Id, Membership__c> mapMemberships = new Map<Id, Membership__c>();
        
        //Set to hold the dropped membership program Ids
	//Commented By - Neha Sharma - 05/19/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        //Set<Id> setProgramIds = new Set<Id>();
        //Upto here
        
        //CR-20140407-4977 - 10/30/2015 - Modfiied By - Abhinav Sharma - To eliminate the SOQL queries inside the for loop 
        //to avoid governer limits and with this added null and size check where applicable to make queries more restrictive
        //and to stop un-necessary execution of code
        //Start from here
        //Loop through membership record are in current scope
        for(Membership__c mem : membershipsDroppedYesterday) {
        	
        	//Checking fields for null value and populating collections with appropriate values
        	if(mem.Account_Name__c != null && mem.Program__c != null && String.isNotBlank(mem.Membership_Status__c)) {
        		//Commented By - Neha Sharma - 05/19/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
			//setAccountsIds.add(mem.Account_Name__c);
        		mapMemberships.put(mem.Id, mem);
        		//setProgramIds.add(mem.Program__c);
        	}
        }
        
        //Checking map for size value
        if(mapMemberships.keySet().size() > 0) {
        	
		//Commented By - Neha Sharma - 05/19/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        	/*//Create a set of program ids that are active
        	Set<Id> activeProgramIdSet = new Set<Id>();
        
	        //Get a list of all other active memberships on the corresponding institution's 
	        for(Membership__c m : [SELECT Id, Program__c 
		                            FROM Membership__c 
		                            WHERE Id NOT IN : mapMemberships.keySet()
		                            AND Account_Name__c IN : setAccountsIds
		                            AND Program__c != null
		                            AND Membership_Status__c LIKE 'Member%'])                   	
	        	activeProgramIdSet.add(m.Program__c);
            
            	// Map<SubscriptionOptionId, EligibleSubOptionId>
           	Map<Id, Id> subOptionTOeligibleSubOption = new Map<Id, Id>();*/
        	
        	//Checking set for size value
        	/* Spring Cleanup
        	if(activeProgramIdSet.size() > 0) {
        		
        		//Loop through eligible subscription option records
            	for (Eligible_Subscription_Option__c eligSubOption :  [SELECT Id, Related_Subscription__c 
            															FROM Eligible_Subscription_Option__c
                                                                    	WHERE Program__c != null 
                                                                    	AND Related_Subscription__c != null
                                                                    	AND Program__c IN :activeProgramIdSet]) {
            		
        			//ELigible Subscription record Id value
        			Id eligibleSubOptionId = subOptionTOeligibleSubOption.get(eligSubOption.Related_Subscription__c);
            		
            		//Populating map with appropriate values in case of null value for the Id
            		if (eligibleSubOptionId == null) 
                		subOptionTOeligibleSubOption.put(eligSubOption.Related_Subscription__c, eligSubOption.Id);				
        		}
            }   */
            
            //Checking set for size value
            /*Spring CleanUp
            if(setProgramIds.size() > 0 && setAccountsIds.size() > 0) {
				             	
                // get all active subscriptions for that program on that institution
                for (Subscription__c sub : [SELECT Id, Subscription_ID__c, Subscription_Status__c, 
                                            Subscription_ID__r.Related_Subscription__c, 
                                            Subscription_ID__r.Program__c, Subscription_ID__r.Program__r.Program_Acronym__c
                                            FROM Subscription__c
                                            WHERE Termination_Date__c = null
                                            AND Contact__c != null
                                            AND Contact__r.AccountId != null
                                            AND Contact__r.AccountId IN : setAccountsIds
                                            AND Subscription_ID__c != null
                                            AND Subscription_ID__r.Program__c != null
                                            AND Subscription_ID__r.Program__c IN : setProgramIds]) {
                
                    // see if we still have an active membership that would allow us to continue that subscription on another program
                    Id eligibleSubscriptionOptionId = subOptionTOeligibleSubOption.get(sub.Subscription_Id__r.Related_Subscription__c);
                
                    //Checking for null value
                    if (eligibleSubscriptionOptionId == null) {
                    
                        // add a termination date of today to the subscription
                        sub.Subscription_Status__c = 'Inactive - No Eligible Memberships - ' + sub.Subscription_ID__r.Program__r.Program_Acronym__c;
                        sub.Termination_Date__c = system.now();
                        subscriptionsToUpdate.add(sub);
                		
                	} else {
		                    
                        // update the eligible subscription option to match the ESO of the program whose membership is still active
                        sub.Subscription_ID__c = eligibleSubscriptionOptionId;
                        subscriptionsToUpdate.add(sub);
                	}
            	}
            }    
			*/
            /** start key contact logic **/
            // 1) get any key contacts associated with this membership where the con.accountId != membership.AccountId
            allKeyConsForDelete = [SELECT Id, Contact__r.AccountId 
            						FROM Membership_Key_Contact__c
                                    WHERE Membership__c != null 
                                    AND Membership__c IN : mapMemberships.keySet()];
                                    
			// put the key contact institution ids in a set
			Set<Id> keyContactInstIdSet = new Set<Id>();
			
			//List of Membership key contacts
			List<Membership_Key_Contact__c> keyContactsDiffInst = new List<Membership_Key_Contact__c>();
			
			//Loop through membersjip record are in current scopr
			for (Membership__c membership : membershipsDroppedYesterday) {
				
				//Loop through membership key contacts associated to these membership records
				for (Membership_Key_Contact__c mkc : allKeyConsForDelete) {
					
					//Checking if there is a difference exists for account reference
					//In case yes, populating collections with appreopriate value
					if (mkc.Contact__r.AccountId != membership.Account_Name__c) {
            			keyContactsDiffInst.add(mkc);
            			keyContactInstIdSet.add(mkc.Contact__r.AccountId);
        			}
    			}
			}
			
			//Checking set for the size value
			if(keyContactInstIdSet.size() > 0) {
				
				// 2) get a list of all active memberships on these institutions
            	List<Account> acctWithActiveMemberships = [SELECT Id, 
                                                    		(SELECT Id, Account_Name__c, Program__c FROM Memberships__r 
                                                    			WHERE Membership_Status__c LIKE 'Member%')
                                                    		FROM Account WHERE Id IN :keyContactInstIdSet];
                                                    		
				// 3) get all eligible subscription options for each institution and put them in a map
            	Map<Id, Map<Id, Id>> acctIdToEligSubOptions = new Map<Id, Map<Id, Id>>();
            
				//VH updated as part of CR-20140407-4977
				// get all active programs for accts
            	//Spring CLeanup
            	/*
            	 map<Id, list<Eligible_Subscription_Option__c>> progIdToEligSubOptions = new map<Id, list<Eligible_Subscription_Option__c>>();
            
            	//Loop through retrieved account records
            	for (Account keyConAcct : acctWithActiveMemberships) {
                	for (Membership__c m : keyConAcct.Memberships__r) 
                		progIdToEligSubOptions.put(m.Program__c, new list<Eligible_Subscription_Option__c>());
            	}
            	
            	//Checking for size value
            	if(progIdToEligSubOptions.keySet().size() > 0) {
            		
             		//Update map
					for (Eligible_Subscription_Option__c eso : [SELECT Id, Related_Subscription__c, Program__c 
																FROM Eligible_Subscription_Option__c
                                                         		WHERE Program__c != null 
                                                         		AND Program__c IN :progIdToEligSubOptions.keySet()]) {
						list<Eligible_Subscription_Option__c> esoList = progIdToEligSubOptions.get(eso.Program__c);
						esoList.add(eso);
						progIdToEligSubOptions.put(eso.Program__c, esoList);
					}
					
					//VH updated as part of CR-20140407-4977
            		for(Account keyConAcct : acctWithActiveMemberships) {
                
                		//Memory allocation to the list of eligible subscription options 
                		List<Eligible_Subscription_Option__c> keyConEligSubOpList = new List<Eligible_Subscription_Option__c>();
                
                		//Loop through membership records
                		for (Membership__c m : keyConAcct.Memberships__r) 
                			keyConEligSubOpList.addAll(progIdToEligSubOptions.get(m.Program__c));
                
                		//Map to hold the contact subscription Id as key amd Eligible subscription record Id value
                		Map<Id, Id> keyConSubToEligSubOption = new Map<Id, Id>();
		                
		                //Loop through eligible subscription options
		                for (Eligible_Subscription_Option__c keyConEligSubOp : keyConEligSubOpList) {
		                    keyConSubToEligSubOption.put(keyConEligSubOp.Related_Subscription__c, keyConEligSubOp.Id);
		                }
                		
                		//Populating map with updated value
                		acctIdToEligSubOptions.put(keyConAcct.Id, keyConSubToEligSubOption);
            		}
            */
		            // 4) determine which subscriptions need to be terminated and which can be re-associated with another active eligible subscription option
		            /* Spring CleanUp
                    for (Subscription__c sub : [SELECT Id, Subscription_ID__c, Contact__r.AccountId, Subscription_Status__c, 
                                                	Subscription_ID__r.Related_Subscription__c, Subscription_ID__r.Program__c, 
                                                	Subscription_ID__r.Program__r.Program_Acronym__c
				                                    FROM Subscription__c
				                                    WHERE Termination_Date__c = null 
				                                    AND Contact__r.AccountId IN :keyContactInstIdSet 
				                                    AND Subscription_ID__r.Program__c IN : setProgramIds]) {
				                  
		                //Retrieval of values from the map                    	
                		Map<Id, Id> keyConSubToEligSubOption = acctIdToEligSubOptions.get(sub.Contact__r.AccountId);
                		String keyConEligSubOptionId = keyConSubToEligSubOption.get(sub.Subscription_ID__r.Related_Subscription__c);
                
                		//Checking for the null value
		                if (keyConEligSubOptionId == null) {
		                    
		                    // add a termination date of today to the subscription
		                    sub.Subscription_Status__c = 'Inactive - No Eligible Memberships - ' + sub.Subscription_ID__r.Program__r.Program_Acronym__c;
		                    sub.Termination_Date__c = system.now();
		                    keyConSubscriptionsToUpdate.add(sub);
		                
		                } else {
		                
		                    // update the eligible subscription option to match the ESO of the program whose membership is still active
		                    sub.Subscription_ID__c = keyConEligSubOptionId;
		                    keyConSubscriptionsToUpdate.add(sub);
		                }
            		}*/
            		/** end key contacts logic **/
            	//}
        	}
            //Upto here
            
        	// try to upsert the results for normal subscriptions
        	/* Spring CleanUp
        	if (subscriptionsToUpdate.size() > 0) {
        
	            //Added By Abhinav Sharma - 04/22/2014 - CR-20140331-4909
	            //Making a try to update the list of records and recording error messages will be wmailed to the SFAdmin 
	            logMessage = Util.createLog(Database.update((subscriptionsToUpdate),false));
            
	            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
	            if(logMessage != '') 
	                debugLogStr += logMessage; 
        	}*/
        
	        // try to upsert the results for KEY CONTACT subscriptions
	        /* Spring CLeanup
	        if (keyConSubscriptionsToUpdate.size() > 0) {
        
	            //Added By Abhinav Sharma - 04/22/2014 - CR-20140331-4909
	            //Making a try to update the list of records and recording error messages will be wmailed to the SFAdmin 
	            logMessage = Util.createLog(Database.update((keyConSubscriptionsToUpdate),false));
	            
	            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
	            if(logMessage != '') 
	                debugLogStr += logMessage; 
        	}*/
        
	        // Delete all of the membership key contacts that are associated with the membership that dropped.
	        // this used to happen on the membership trigger but needs to occur on this batch now because we need
	        //  the membership key contacts to remain until the batch runs
	        if (allKeyConsForDelete.size() > 0) {
            
	            //Added By Abhinav Sharma - 04/22/2014 - CR-20140331-4909
	            //Making a try to update the list of records and recording error messages will be wmailed to the SFAdmin 
	            logMessage = Util.createLog(Database.update((allKeyConsForDelete),false));
            
	            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
	            if(logMessage != '') 
	                debugLogStr += logMessage; 
	        }
    	}
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC) {
    
        //Added By Abhinav Sharma - 04/22/2014 - Emailing recorded errors details to SFAdmin. - CR-20140331-4909
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '') {
            
            //User Instance
            //Refactored By Doug Roberts - 08/31/2015 - Remove query for SF user email and change to custom label
            //List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
            
            //Send log to admin
            //if(sfAdminUser.size() > 0)
                Util.sendBatchStatus(BC.getJobId(), 'Batch_MembershipSubscriptions', debugLogStr, Label.Salesforce_Admin_Email);
        }
    }
}