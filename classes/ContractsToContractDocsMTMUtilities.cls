//v1.0 - Created
//v1.1 - Modified By - Mahendra Swarnkar - 10/11/2017 - CR-20170928-11580 - Apollo Release - Added new method "populateEntityField"
public without sharing class ContractsToContractDocsMTMUtilities {
	
	// create Contract Doc MTM records on associated Opportunities
	public static void AddDocsToOpps(Map<Id, Contracts_to_Contract_Docs_MtM__c> newMap) {
		Set<Id> contractIds = new Set<Id>();
		for (Contracts_to_Contract_Docs_MtM__c conToConDoc : newMap.values())
			contractIds.add(conToConDoc.Contracts_ABC__c);
		
		// create a list to store our contract docs to be added
		List<Contract_Docs_to_Opps_MtM__c> contractDocsToOppsMTMRecords = new List<Contract_Docs_to_Opps_MtM__c>();
		
		// get all opps associated with the contract and the opp's Contract Doc MTMs
		Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Name, Id, AccountId,
													(SELECT Id, Contract_Documents__c, Contract_Documents__r.Account__c FROM Contract_Docs_to_Opps_MtMs__r)
																FROM Opportunity WHERE (Signed_Opportunity_Contract__c IN :contractIds)]);
																// VRH removed 'Previous_Contract__c IN :contractIds OR ' so opps booked from the contract do not get docs
		
		for (Opportunity opp : oppMap.values()) {
			set<Id> contractDocIds = new Set<Id>();
			
			// create a list of contract doc ids
			for (Contract_Docs_to_Opps_MtM__c contractDocOpp : opp.Contract_Docs_to_Opps_MtMs__r) {
				contractDocIds.add(contractDocOpp.Contract_Documents__c);
			}
			
			for (Contracts_to_Contract_Docs_MtM__c newDoc : newMap.values()) {
				if (!contractDocIds.contains(newDoc.Contract_Docs__c) && newDoc.Contract_Docs__r.Account__c == opp.AccountId) {
					// create a new contract document to opportunity MTM record
					contractDocsToOppsMTMRecords.add(CreateNewContractDocFromOpp(newDoc, opp.Id));
				}
			}
			
		}
		
		if (contractDocsToOppsMTMRecords.size() > 0)
			insert contractDocsToOppsMTMRecords;
		
	}
	
	// check to see if any updated opportunities need to have their docs added to a contract
	public static void CheckOppsForDocChanges(List<Opportunity> triggerNew, Map<Id, Opportunity> oldMap) {
		// contract id set
		Set<Id> contractIds = new Set<Id>();
		for (Opportunity newOpp : triggerNew) {
			// get the old opportunity
			Opportunity oldOpp;
			if (oldMap != null)
				oldOpp = oldMap.get(newOpp.Id);
			
			if (oldMap == null && newOpp.Signed_Opportunity_Contract__c != null) { // if the newopp has a signed contract, add it to set
				contractIds.add(newOpp.Signed_Opportunity_Contract__c);
			}
			else if (oldOpp != null) { // if an opp has a new value in the signed_Opp_contract field, add it to our set to be processed
				if (oldOpp.Signed_Opportunity_Contract__c != newOpp.Signed_Opportunity_Contract__c &&
					newOpp.Signed_Opportunity_Contract__c != null) {
						contractIds.add(newOpp.Signed_Opportunity_Contract__c);
					}
			}
		}
		
		if (contractIds.size() > 0) // if there are contract ids in our Set, process them
			AddDocsToContract(contractIds);
	}
	
	// create contract doc mtm records on Contract associated with the Signed or previous Opportunity Contract
	public static void AddDocsToContract(Set<Id> ContractIds) {
		// get the Signed Opportunity Contract record
		List<Contract__c> contracts = [SELECT Name, Id, (SELECT Name, Id, Signed_Opportunity_Contract__c FROM Opportunities__r),
									(SELECT Id, Contract_Docs__c FROM Contracts_to_Contract_Docs_MtMs__r) 
									FROM Contract__c WHERE Id IN :ContractIds];
		// if we didn't find any contracts, return without processing anything
		if (contracts.size() == 0) return;
		
		// get all opps associated with the contract and the opp's Contract Doc MTMs
		Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Name, Id, Signed_Opportunity_Contract__c, AccountId,
													(SELECT Id, Contract_Documents__c, Contract_Documents__r.Account__c FROM Contract_Docs_to_Opps_MtMs__r)
																FROM Opportunity WHERE Signed_Opportunity_Contract__c IN :contractIds]);
		
		// list of new Contract docs to Contracts mtm records
		List<Contracts_to_Contract_Docs_MtM__c> consToConsDocsMTM = new List<Contracts_to_Contract_Docs_MtM__c>();
		
		// process each contract
		for (Contract__c con : contracts) {
			Set<Id> docIds = new Set<Id>();
			
			// add doc ids to our set
			for (Contracts_to_Contract_Docs_MtM__c conDoc : con.Contracts_to_Contract_Docs_MtMs__r) {
				docIds.add(conDoc.Contract_Docs__c);
			}
			
			// move to the next contract if there are no opps
			if (con.Opportunities__r.size() == 0) continue;
			
			for (Opportunity conOpp : con.Opportunities__r) {
				Opportunity opp = oppMap.get(conOpp.id);
				// add each doc on the opp
				for (Contract_Docs_to_Opps_MtM__c oppDoc : opp.Contract_Docs_to_Opps_MtMs__r) {
					// make sure the account matches
					if (!docIds.contains(oppDoc.Contract_Documents__c) &&  oppDoc.Contract_Documents__r.Account__c == opp.AccountId) {
							Contracts_to_Contract_Docs_MtM__c newDoc = new Contracts_to_Contract_Docs_MtM__c();
							newDoc.Contract_Docs__c = oppDoc.Contract_Documents__c;
							newDoc.Contracts_ABC__c = con.Id;
							consToConsDocsMTM.add(newDoc);
					}
					
				}
			}
		}
		
		if (consToConsDocsMTM.size() > 0)
			insert consToConsDocsMTM;
		
	}
	
	public static Contract_Docs_to_Opps_MtM__c CreateNewContractDocFromOpp(Contracts_to_Contract_Docs_MtM__c contractDoc, Id oppId) {
		Contract_Docs_to_Opps_MtM__c retVal = new Contract_Docs_to_Opps_MtM__c();
		retVal.Opportunity__c = oppId;
		retVal.Contract_Documents__c = contractDoc.Contract_Docs__c;
		return retVal;
	}
    
    
    
    /**
     *  @description    :   Method used to populate the Entity field value from the Related Contracts_ABC__c.Payer_Account__c's Entity field value
     * 
     *  @args           :   List of new Contracts_to_Contract_Docs_MtM__c records, Map of old Contracts_to_Contract_Docs_MtM__c records
     * 
     *  @return         :   void
     * 
     *  @Revision Log   :   V1.0 - Created By - Mahendra Swarnkar - 10/11/2017 - CR-20170928-11580 - Apollo Release
     **/
    public static void populateEntityField(List<Contracts_to_Contract_Docs_MtM__c> newContractsToContractDocsMtMs, Map<Id, Contracts_to_Contract_Docs_MtM__c> mapOldContractsToContractDocsMtMs) {
    
        //Set to hold the Contact ABC Ids
        Set<Id> setContractABCIds = new Set<Id>(); 
        
        //Loop over the new Contracts_to_Contract_Docs_MtM__c records
        for(Contracts_to_Contract_Docs_MtM__c conToMtm : newContractsToContractDocsMtMs) {
            
            //Check for related Contract ABC
            if(conToMtm.Contracts_ABC__c != null)
            	setContractABCIds.add(conToMtm.Contracts_ABC__c);
		}
        
        //Check for size
        if(setContractABCIds.size() > 0) {
            
            //Map to hold the Contract ABC
            Map<Id, Contract__c> mapContractABCs = new Map<Id, Contract__c>([Select Id, Payer_Account__c, Payer_Account__r.Entity__c From Contract__c Where Id IN : setContractABCIds AND Payer_Account__r.Entity__c != null]);
            
            //Loop over the new Contracts_to_Contract_Docs_MtM__c records
            for(Contracts_to_Contract_Docs_MtM__c contToConMtm : newContractsToContractDocsMtMs) {
				
				//Check for Contract ABC
				if(contToConMtm.Contracts_ABC__c != null && mapContractABCs.containsKey(contToConMtm.Contracts_ABC__c))
					contToConMtm.Entity__c = mapContractABCs.get(contToConMtm.Contracts_ABC__c).Payer_Account__r.Entity__c;
				else
					contToConMtm.Entity__c = null;
			}
        }
    }
}