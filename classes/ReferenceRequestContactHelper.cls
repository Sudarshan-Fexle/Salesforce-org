//10/10/2017 - CR-20170928-11609 -  Added the validateEntity method
public without sharing class ReferenceRequestContactHelper {
    
    /**
     * @description: Submit all Reference Request Contacts for approval
     * 
     *  
     **/
    public static void submitForApproval(set<Id> referenceRequestContactIds) {
        for (Id rrcId : referenceRequestContactIds) {
            
            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
            app.setObjectId(rrcId);
            Approval.ProcessResult result = Approval.process(app);
        }
    }
    
    /**
     * @description: populate the Approver field on all Reference Request Contacts
     * 
     * 
     **/
    public static void populateApprover(list<Reference_Request_Contact__c> refReqContacts) {
        //set of contact ids
        set<Id> contactIds = new set<Id>();
        set<string> applicableModules = new set<string>();
        for (Reference_Request_Contact__c rrc : refReqContacts) {
            contactIds.add(rrc.Reference_Contact__c);
            if (rrc.Reference_Modules__c != null) {
                list<string> modules = rrc.Reference_Modules__c.split('\r\n');
                applicableModules.addAll(modules);
            }
        }
        
        //get all contacts with applicable references
        map<Id, Contact> contactMap = new map<Id, Contact>([SELECT Id, Name, (SELECT Id, Dedicated_Advisor__c, NASA_Principal__c, Reference_Module__c FROM Reference_Modules__r 
                                                                        WHERE Reference_Module__c IN :applicableModules AND Reference_Module__c != null)
                                                            FROM Contact 
                                                            WHERE Id IN :contactIds]);// AND Id IN (SELECT Contact_Name__c FROM Reference__c) [vh commented out 2/2/16]
        
        //match the reference request contact to the related reference
        for (Reference_Request_Contact__c rrc : refReqContacts) {
            Contact c;
            if (contactMap != null)
                c = contactMap.get(rrc.Reference_Contact__c);
            //throw an error if the reference request contac does not have any applicable references
            if (c == null || c.Reference_Modules__r.size() == 0) {
                string name;
                if (c != null && c.Name != null) name = string.escapeSingleQuotes(c.Name);
                rrc.addError('The Contact \'' + name + '\' does not have any applicable references');
            }
            else {
                rrc.Approver__c = c.Reference_Modules__r[0].Dedicated_Advisor__c;
            }
        }
    }
    
    /**
     *  @description    :   This method use to populate most recent "Date Reference Call Completed" Date of RRC record on contact records
     *
     *  @arg            :   List<Reference_Request_Contact__c>, Map<Id, Reference_Request_Contact__c>
     *
     *  @return         :   void
     *
     **/
    //Added By - Mahendra Swarnkar - 10/22/2016 - CR-20160414-9766  
    /*public static void populateMostRecentLastUseDateOnContact(List<Reference_Request_Contact__c> rRContacts, Map<Id, Reference_Request_Contact__c> oldrRContactsMap){
    	
    	//Set to hold contact IDs
    	Set<Id> setContactIds = new Set<Id>();
    	
    	//Loop ove new RRC records
    	for(Reference_Request_Contact__c rrc : rRContacts){
    		
    		//Check for COntact no null
    		if(rrc.Reference_Contact__c != null)
    			setContactIds.add(rrc.Reference_Contact__c);
    	}
    	
    	//Check for set size
    	if(setContactIds.size() > 0 ){
    		
    		//List to hold Contact to update
    		List<Contact> contactsToUpdate = new List<Contact>();
    	
    		//Query on Contact to get records
	    	for(Contact con : [SELECT Id, Last_Use_Date__c, (Select Id,Date_Reference_Call_Completed__c FROM Reference_Request_Contacts__r 
                                                             ORDER By Date_Reference_Call_Completed__c DESC NULLS LAST LIMIT 1) FROM Contact WHERE Id IN: setContactIds]){
	    		
	    		//Check for related records list size and populate list
	    		if(con.Reference_Request_Contacts__r.size() > 0)
	    			contactsToUpdate.add(new Contact(Id = con.Id, Last_Use_Date__c = con.Reference_Request_Contacts__r[0].Date_Reference_Call_Completed__c));
	    			
	    	}
	    	
	    	//Check for list size
	    	if(contactsToUpdate.size() > 0)
	    		update contactsToUpdate;
    	}
    }*/
    
    /**
     *  @description    :   This method use to validate Entity field from Related Reference Request.Account's Entity
     *
     *  @arg            :   List<Reference_Request_Contact__c>, Map<Id, Reference_Request_Contact__c>
     *
     *  @return         :   void
     *
     *	@Revision Log	:	V1.0 - 10/10/2017 - Subhash Garhwal - CR-20170928-11609 -  Added	
     **/
	public static void validateEntity(List<Reference_Request_Contact__c> rRContacts, Map<Id, Reference_Request_Contact__c> mapOldRRContacts) {
		
		//Set to hold the Reference Request Ids
		Set<Id> setReferenceRequestIds = new Set<Id>();
		
		//Loop over the RRC
		for(Reference_Request_Contact__c rRC : rRContacts) {
			
			setReferenceRequestIds.add(rRC.Reference_Request__c);	
		}
		
		//Check for size
		if(setReferenceRequestIds.size() > 0) {
			
			//Map to hold the Reference_Request__c
			Map<Id, Reference_Request__c> mapReferenceRequests = new Map<Id, Reference_Request__c>([Select Id, Requesting_Institution__c, Requesting_Institution__r.Entity__c From Reference_Request__c Where Id IN : setReferenceRequestIds]);
			
			//Loop over the RRC
			for(Reference_Request_Contact__c rRC : rRContacts) {
				
				//Check appropriate condition to fire trigger
				if(rRC.Reference_Request__c != null && mapReferenceRequests.containsKey(rRC.Reference_Request__c) && mapReferenceRequests.get(rRC.Reference_Request__c).Requesting_Institution__c != null)
					rRC.Entity__c = mapReferenceRequests.get(rRC.Reference_Request__c).Requesting_Institution__r.Entity__c;
			}	
		}
	}
}