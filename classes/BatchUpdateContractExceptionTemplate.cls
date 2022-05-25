/**
 *  Description     :  Batch class to Associate CPQ COntract Exception on the update of Master Exception Template as Per the below mentioned logic:-
 *  						When the master template changes, 
 * 							then any CPQ Contract Exceptions that use this master template (Proposal should be in 'Draft', 'In Review', 'Approved' status, CPQ Template Request is in 'Draft' or 'Request Legal Approval' status), 
 * 							should be updated to use the new template/version.
 *
 *  Created By      :  Mahendra Swarnkar
 *
 *  Created Date    :  06/11/2019
 *
 *  Revision Logs   :   V_1.0 - Created - Mahendra Swarnkar - CR-20181019-12685 
 *
 **/   
global class BatchUpdateContractExceptionTemplate implements Database.Batchable<sObject>, Database.Stateful {
    
    
    public final static String EXCEPTION_TEMPLATE_RT_ID = Schema.SObjectType.Exception_Template__c.getRecordTypeInfosByName().get('Version').getRecordTypeId();
    
    public final static Set<String> PROPOSAL_STATUS = new Set<String>{'Draft', 'In Review', 'Approved'};
    public final static Set<String> EXCEPTION_REQUEST_STATUS = new Set<String>{'Draft', 'Request Legal Approval'};
    
    public String queryString;
    
    //String variable to hold the entire log message string value
    global String debugLogStr;
    
    //MAp to hold the Parent Exception ID as a Key and latest exception version record as a value
	public Map<Id, Exception_Template__c> mapParentExceptionTemplateIdWithLatestversion;
    
    //Set to Hold the Master Exception Templates Ids
    public Set<Id> setMasterExceptionIds;

    //Map to hold the membership Id with membership
    //public Map<Id, Membership__c> mapMembershipIdWithMembership = new Map<Id, Membership__c>();
	
	global BatchUpdateContractExceptionTemplate(Set<Id> setMasterExceptionIds){
		
		//Initialize the variables
		mapParentExceptionTemplateIdWithLatestversion = new Map<Id, Exception_Template__c>();
		this.setMasterExceptionIds = new Set<Id>();
		debugLogStr = '';
		
		//Check for size
		if(setMasterExceptionIds.size() > 0){
			
			//Populate the set
			this.setMasterExceptionIds = setMasterExceptionIds;	
			
			//Query over the Exception Template
			for(Exception_Template__c exTemplate : [Select Id, Version__c, Parent_Template__c, Current_Version__c From Exception_Template__c 
													Where Parent_Template__c != null AND Parent_Template__c IN : setMasterExceptionIds 
													AND RecordTypeId =: EXCEPTION_TEMPLATE_RT_ID AND Current_Version__c = true]){
												
				//Check for condition & populate the map		
				if(!mapParentExceptionTemplateIdWithLatestversion.containsKey(exTemplate.Parent_Template__c))
					mapParentExceptionTemplateIdWithLatestversion.put(exTemplate.Parent_Template__c, exTemplate);
			}
		}
		System.debug('### mapParentExceptionTemplateIdWithLatestversion: ' + mapParentExceptionTemplateIdWithLatestversion);
	}
	
    //Batch Start Method
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        //Check for size
        if(String.isBlank(queryString) && setMasterExceptionIds.size() > 0){
        	
        	//Build the Query String
        	queryString = 'Select Id, Exception_Template_Version__c, Exception_Template_Current_Version__c,' 
        					+ ' Exception_Template__c, Exception_Template__r.Parent_Template__c, Proposal__c'
        					+ ' From CPQ_Contract_Exception__c' 
        					+ ' Where Exception_Template__r.Parent_Template__c IN : setMasterExceptionIds AND'
        					+ ' Proposal__c != null AND Proposal__r.SBQQ__Status__c IN : PROPOSAL_STATUS';
        }
        
        System.debug('### Executing Batch for Query: ' + queryString);
        
        return Database.getQueryLocator(queryString);   
    }
    
    //Batch Execute Method
    global void execute(Database.BatchableContext bc, list<Sobject> scope){
		
		//String variable to hold the error message string in case of any failure
        String logMessage = '';
        
		//Set to hold the Proposal Ids
		Set<Id> setProposalIds = new Set<Id>();
		
		//MAp to hold the Proposal ID as a Key and list of CPQ Contract Exceptions as a value
		Map<Id, list<CPQ_Contract_Exception__c>> mapProposalIdWithContractExceptions = new Map<Id, list<CPQ_Contract_Exception__c>>();
		
		//Loop over the Exception template versions (Scope)
		for(CPQ_Contract_Exception__c contractException : (list<CPQ_Contract_Exception__c>) scope){
			
			//Check for proposal
			if(contractException.Proposal__c != null) {
			
				//Popuate the proposal Ids set
				setProposalIds.add(contractException.Proposal__c);
				
				//contains check 
				if(!mapProposalIdWithContractExceptions.containsKey(contractException.Proposal__c))
					mapProposalIdWithContractExceptions.put(contractException.Proposal__c, new list<CPQ_Contract_Exception__c>());
				
				//popuate the map
				mapProposalIdWithContractExceptions.get(contractException.Proposal__c).add(contractException);	
			}
		}
		
		//Check for size
		if(setProposalIds.size() > 0){
			
			//Map to hold the Priposal Id as key and CPQ Exception Request as value.
			Map<Id, list<CPQ_Exception_Request__c>> mapProposalIdWithExceptionRequests = new Map<Id, list<CPQ_Exception_Request__c>>();
			
			//Query over the CPQ Exception Request
			for(CPQ_Exception_Request__c exRequest : [Select Id, Proposal__c From CPQ_Exception_Request__c 
														Where Status__c IN : EXCEPTION_REQUEST_STATUS AND Proposal__c != null 
														AND Proposal__c IN : setProposalIds 
														AND Proposal__r.SBQQ__Status__c IN : PROPOSAL_STATUS]){
				
				//contains check
				if(!mapProposalIdWithExceptionRequests.containsKey(exRequest.Proposal__c))
					mapProposalIdWithExceptionRequests.put(exRequest.Proposal__c, new List<CPQ_Exception_Request__c>());
				
				//Populate the map
				mapProposalIdWithExceptionRequests.get(exRequest.Proposal__c).add(exRequest);
			}
			
			//Check for size
			if(mapProposalIdWithExceptionRequests.size() > 0){
				
				//List to hold the contract Exception records to be updated
				List<CPQ_Contract_Exception__c> listContractExceptionsToBeUpdated = new List<CPQ_Contract_Exception__c>();
				
				//loop over the proposal Ids
				for(Id propId : mapProposalIdWithExceptionRequests.keySet()){
					
					//check for size/contains check
					if(mapProposalIdWithExceptionRequests.get(propId) != null && mapProposalIdWithExceptionRequests.get(propId).size() > 0
						&& mapProposalIdWithContractExceptions.size() > 0 && mapProposalIdWithContractExceptions.containsKey(propId) 
						&& mapProposalIdWithContractExceptions.get(propId) != null && mapProposalIdWithContractExceptions.get(propId).size() > 0){
						
						//Loop over the Contract Exceptions
						for(CPQ_Contract_Exception__c contractExcept : mapProposalIdWithContractExceptions.get(propId)){
							
							//Check for size
							if(contractExcept.Exception_Template__r.Parent_Template__c != null && mapParentExceptionTemplateIdWithLatestversion != null 
								&& mapParentExceptionTemplateIdWithLatestversion.size() > 0 && mapParentExceptionTemplateIdWithLatestversion.containsKey(contractExcept.Exception_Template__r.Parent_Template__c)
								&& mapParentExceptionTemplateIdWithLatestversion.get(contractExcept.Exception_Template__r.Parent_Template__c) != null){
								
								//Hold the latest exception Template verssion
								Exception_Template__c latestExceptionTemplateVersion = mapParentExceptionTemplateIdWithLatestversion.get(contractExcept.Exception_Template__r.Parent_Template__c);
								
								//Check if Contract Exception is associated with Latest Exception Template version record if not then associate it with the latest exception template version
								if(contractExcept.Exception_Template_Version__c != null && contractExcept.Exception_Template_Version__c != latestExceptionTemplateVersion.Version__c)
									listContractExceptionsToBeUpdated.add(new CPQ_Contract_Exception__c(Id = contractExcept.Id, Exception_Template__c = latestExceptionTemplateVersion.Id ));	
							}
						}
					}
				}
				
				//Check for size()
				if(listContractExceptionsToBeUpdated.size() > 0){
					
					//Making a try to update the list of records and recording error messages will be emailed to the SFAdmin 
		            logMessage = Util.createLog(Database.update((listContractExceptionsToBeUpdated),false));
		            
		            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
		            if(logMessage != '') 
		                debugLogStr += logMessage; 
				}
				
			}
		}
    }

	//Batch Finish Method
    global void finish(Database.BatchableContext bc){
    	
    	//Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '') {
            
            //Send log to admin
            Util.sendBatchStatus(bc.getJobId(), 'BatchUpdateContractExceptionTemplate', debugLogStr, Label.SF_ADMIN_EMAIL);
        }

	}
}