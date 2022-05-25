/**
 *	Purpose			:	This batch class is used for update Membership's fields values.
 *
 *	Created By		:	Bhavi Sharma
 *
 *	Created Date	:	06/14/2013
 *
 *	Current Version	:	v1.0
 * 
 *	Revision Logs	:	v1.0 - Created - CR-20130411-2851 
 **/
global class Batch_UpdateMembershipOwnerAssociate implements Database.Batchable<sObject>, Database.Stateful {
	
	//Map with Key = UserID & Value = User record
	global Map<Id, User> mapUser;
	
	//constructor for batch
	global Batch_UpdateMembershipOwnerAssociate(Map<Id, User> mapUsr){
		
		this.mapUser = mapUsr;
	}
	
	//start method
	global Database.Querylocator start(Database.BatchableContext BC) {
		
		return Database.getQueryLocator([Select Id, OwnerId, Owner_Associate__c from Membership__c where OwnerId IN: mapUser.keySet()]);
	}
	
	//execute method
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		
		//List of Memberships
		List<Membership__c> memberships = (List<Membership__c>) scope;
		
		//List of Memberships to be update
		List<Membership__c> membershipsToUpdate = new List<Membership__c>();
		
		//Loop through list of Membership record
		for(Membership__c membership : memberships) {
			
			//Check for old and existing data
			if(mapUser.containsKey(membership.OwnerId) && (mapUser.get(membership.OwnerId).Associate__c != membership.Owner_Associate__c)){
				
				//assign User's field value to Membership's field value 
				membership.Owner_Associate__c = mapUser.get(membership.OwnerId).Associate__c;
				
				//add membership into list of Memberships to update
				membershipsToUpdate.add(membership);
			}
		}
		
		//Check for size of Membership's list to update
		if(membershipsToUpdate.size() > 0 ) {
			
			//Update records
			Util.BypassAllTriggers = true;
			update membershipsToUpdate;
		}
	}
	
	//finish method
	global void finish(Database.BatchableContext ctx) {
		
		AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedBy.Email 
              					FROM AsyncApexJob WHERE id = :ctx.getJobId()];
        
        String emailMessage = 
            'Your batch job \"Batch_UpdateMembershipOwnerAssociate\" has finished.  It processed ' + a.JobItemsProcessed + ' records in ' 
            + a.totalJobItems +
            ' batches processed without any exceptions thrown and ' 
            + a.numberOfErrors 
            + ' batches threw unhandled exceptions.<br/><br/>';
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.email};
        
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('noreply@salesforce.com');
        mail.setSenderDisplayName('Salesforce Batch'); 
        mail.setSubject('Batch_UpdateMembershipOwnerAssociate job completed');
        mail.setPlainTextBody(emailMessage);
        mail.setHtmlBody(emailMessage);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}