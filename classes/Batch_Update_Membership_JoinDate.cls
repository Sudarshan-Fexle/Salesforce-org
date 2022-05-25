/** 
 * Modified By- Mahendra Swarnkar - 05/01/2020 - CR-20191211-13560 - populate the Join_Date_Most_Recent__c field on membership with start date  on Subscription(SBQQ__StartDate__c)/Contract(Start__c) instead of join_date__c.
 * Modified By- Mahendra Swarnkar - 05/22/2020 - CR-20191211-13560 - Commented out the logic to populate the Join_Date_Most_Recent__c field on membership.  
**/
global class Batch_Update_Membership_JoinDate implements Database.Batchable<sObject>, Database.Stateful {


	//Start method
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator([Select Id, Latest_Contract__c, Latest_Subscription__c , Latest_Contract__r.Start__c,
										Latest_Subscription__r.SBQQ__StartDate__c, Join_Date_Most_Recent__c
										From Membership__c Where ((Latest_Contract__c != null AND Latest_Contract__r.Start__c != null)  
										OR (Latest_Subscription__c != null AND Latest_Subscription__r.SBQQ__StartDate__c != null))]);   
    }
    
	//Execute method
    global void execute(Database.BatchableContext BC, List<Membership__c> memberships){
        /*
		//List of to hold the memberships to be update 
		List<Membership__c> membershipsToBeUpdate = new List<Membership__c>(); 
          
		  for(Membership__c mem : memberships) {
		  
			//Check for Latest Subscription 
			if(mem.Latest_Subscription__c != null  && mem.Latest_Subscription__r.SBQQ__StartDate__c != null && mem.Join_Date_Most_Recent__c != mem.Latest_Subscription__r.SBQQ__StartDate__c)
		  
				//Adding values into the list
				membershipsToBeUpdate.add(new Membership__c(Id = mem.Id, Join_Date_Most_Recent__c = mem.Latest_Subscription__r.SBQQ__StartDate__c));
				
			//Check for Latest Contract ABC 
			else if(mem.Latest_Contract__c != null  && mem.Latest_Contract__r.Start__c != null && mem.Join_Date_Most_Recent__c != mem.Latest_Contract__r.Start__c)
		  
				//Adding values into the list
				membershipsToBeUpdate.add(new Membership__c(Id = mem.Id, Join_Date_Most_Recent__c = mem.Latest_Contract__r.Start__c));
		  }
		  
		  //Size check
		  if(membershipsToBeUpdate.size() > 0)
			update membershipsToBeUpdate;
	*/
            
    }
    
	//Finish Method
    global void finish(Database.BatchableContext BC){
	}
}