/*
    Purpose         :   Batch job to update Subscription Period CT Manager and Owner Email address.
                
    Create By       :   Subhash Garhwal
    
    Created Date    :   02/05/2018
    
    Revision Log    :   V_1.1 Created
*/

global class Batch_SperiodAssignMangerNOwnerManEmail implements Database.Batchable<SObject>, Database.Stateful {
	
	//Set to hold the ids of user
	Set<Id> setuserIds  = new Set<Id>();
	
	//Constructor
	global Batch_SperiodAssignMangerNOwnerManEmail(Set<Id> setuserIds) {
		
		this.setuserIds = setuserIds;
	}  
	
	/**
     * 
     * @description: start Method
     * 
     **/
    global Database.Querylocator start(Database.BatchableContext BC)  {
    	
    	return Database.getQueryLocator([Select Id, CT_Assignment__c, CT_Assignment__r.Manager.Email, CT_Assignment_s_Manager_Email__c,  
	     	                                     Program_Subscription__r.OwnerId,  Owner_Manager_Email__c From Subscription_Period__c
	     										 Where CT_Assignment__c IN: setuserIds 
	     										 OR Program_Subscription__r.OwnerId IN: setuserIds]);
    }
    
    
    /**
     * 
     * @description: execute method
     * 
     **/
      global void execute(Database.BatchableContext BC, List<Subscription_Period__c> scope) {
      	
      	//Map to hold the Email of manager with respact to User id 
      	Map<Id, String> mapuserWithManagerEmail = new map<Id, String> ();
      	
      	//Loop on the Sub Period to get the User Ids and fil to the map which contains User id and his Manager Email Address
      	for(Subscription_Period__c sP : scope)
      		mapuserWithManagerEmail.put(sP.Program_Subscription__r.OwnerId, '');
      	
      	//Loop on the user to get the Manager Email Id and Fill 
      	for(User u : [Select Id, Manager.Email From User Where Id IN : mapuserWithManagerEmail.keySet()])
      		mapuserWithManagerEmail.put(u.Id, u.Manager.Email);
      	
      	//List to hold the Subscription Period 
      	List<Subscription_Period__c> subscriptionPeriodToBeUpdate = new List<Subscription_Period__c> ();
      	
      	//Loop on the list of Speriod 
      	for(Subscription_Period__c sPeriod : scope) {
      		
      		//Check if the Owner email and CT Manager are Different than the Email Address 
      		if(sPeriod.CT_Assignment_s_Manager_Email__c != sPeriod.CT_Assignment__r.Manager.Email 
      			|| sPeriod.Owner_Manager_Email__c != mapuserWithManagerEmail.get(sPeriod.Program_Subscription__r.OwnerId))	 {
      			
      			
      			//Fill the Right Email Address on both of the speriod.
	      		sPeriod.CT_Assignment_s_Manager_Email__c = sPeriod.CT_Assignment__r.Manager.Email ;
	      		
	      		//Check for the map if it contains the user Id 
	      		if(mapuserWithManagerEmail.containsKey(sPeriod.Program_Subscription__r.OwnerId))
	      			sPeriod.Owner_Manager_Email__c = mapuserWithManagerEmail.get(sPeriod.Program_Subscription__r.OwnerId);
	      		
	      		subscriptionPeriodToBeUpdate.add(new Subscription_Period__c(Id = sPeriod.Id, 
	      																	CT_Assignment_s_Manager_Email__c = sPeriod.CT_Assignment_s_Manager_Email__c,
	      																	Owner_Manager_Email__c = sPeriod.Owner_Manager_Email__c ));
      		}
      }	
      
      //bypass all triggers when making this update
      Util.BypassAllTriggers = true;
            
      //Check for the size of List
      if(subscriptionPeriodToBeUpdate.size() > 0)
      	update subscriptionPeriodToBeUpdate;
      	
      //bypass all triggers when making this update
      Util.BypassAllTriggers = false;
            
	}
	
	/**
     * 
     * @description: finish method
     * 
     **/
    global void finish(Database.BatchableContext BC) {
        
    }
    
}