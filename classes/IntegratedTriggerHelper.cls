/*
    Purpose         :   This class is the helper class for Trigger_IntegratedAccount trigger
                
    Created By      :   Colin McGloin
    
    Created Date    :   06/24/16
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created - Colin McGloin - 06/24/16
    			V_1.1 - Modified - Subhash Garhwal - 04/27/2018 - CR-20180427-12188 - Modified populateIntegratedAccountOnProposal method
			V_1.2 - Modified Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Contract LOA From Opportunity
                        
*/

public class IntegratedTriggerHelper {
    
    
    /* @description: Prevents the user from modifying the Integrated Account record if it has a 
    *                Contract Integrated Account record which references it
	* 
	* @revisions:	06/24/16 - CM - Created
	**/
    
    public static void preventEditOfIntegratedAccount(List<Integrated_Account__c> newIntegratedAccounts, Map <Id, Integrated_Account__c> oldIntegratedAccounts){
        
		//Add List for the CIA query
        List<Contract_Integrated_Accounts__c> associatedCIAs = new List <Contract_Integrated_Accounts__c>();
        
        if (oldIntegratedAccounts != null){
            
            for (Integrated_Account__c intAcc : newIntegratedAccounts){
                
                Integrated_Account__c oldIntAcc = (Integrated_Account__c)trigger.OldMap.get(intAcc.Id);
                
                //If the Integrated Account field is changed on the Integrated Account record then run logic
                if(intAcc.Integrated_Account__c != oldIntAcc.Integrated_Account__c){
                    
                    //Query to see if there are any CIA records which reference the IA record
                    associatedCIAs = [SELECT Id, Name, Integrated_Account__c FROM Contract_Integrated_Accounts__c WHERE Integrated_Account__c = :intAcc.Id];
                    
                    //If there are CIA records which reference the IA record then add error on page
                    if (associatedCIAs.size() > 0){
                        intAcc.adderror(Label.IntegratedAccountModifyError);
                    }
                    //If there are no CIA records associated with the IA record then exit
                    return;
                }               
            }    
        } 
    }
    
    /* @description: Prevents the user from deleting the Integrated Account record if it has a 
    *                Contract Integrated Account record which references it unless they are in a profile of ABC Dataloader, System Administrator or Finance Ops
	* 
	* @revisions:	06/24/16 - CM - Created
	**/
    
    public static void preventDeleteOfIntegratedAccount(List<Integrated_Account__c> deletedIntegratedAccounts){
        
        //Grab the Three Profile Ids and add these into a Set for checking against before the deletion
        Set<Id> setProfileIds = new Set<Id>();
        for (Profile a : [SELECT Id FROM Profile WHERE Name IN ('System Administrator','Finance Ops','ABC Dataloader')]){
            setProfileIds.add(a.id);
        }
        
        //Add List for the CIA query
        List<Contract_Integrated_Accounts__c> associatedCIAs = new List <Contract_Integrated_Accounts__c>();
        
        for (Integrated_Account__c intAccount : deletedIntegratedAccounts){
            
            //Query to see if there are any CIA records which reference the IA record
            associatedCIAs = [SELECT Id, Name, Integrated_Account__c FROM Contract_Integrated_Accounts__c WHERE Integrated_Account__c = :intAccount.Id];
            
            if (associatedCIAs.size() > 0){
                //Get the profile Id of the Current User
                Id currentUserId = userinfo.getProfileId();
                //If the Set of Profile IDs is not in a profile of ABC Dataloader, System Administrator or Finance Ops then run prevent logic
                if (!setProfileIds.contains(currentUserId)){       
                    intAccount.adderror(Label.IntegratedAccountDeleteError);
                }       
            }
            //If there are no CIA records associated with the IA record then exit
            return;
        }
    }
    
    /**
	 *	@description		:	This method is used to prevent deletion or creation of Integrated account if there is any approved and in review Proposal exists on
	 *					related Contract LOA Opp.
	 *	Original Requirement 	:	Need to lock down the Integrated Accounts records once an Approved quote exists on an Opp.
	 					This can be accomplished using a BEFORE DELETE trigger on the Integrated Account object that will
						check if there are any Proposals linked to the Contract LOA opportunity that are in the 'Approved'
						or 'In Review' status.
	 *						
	 *
	 *	@args			:	List<Integrated_Account__c>
	 *
	 *	@return			:	void
	 *
	 *	@revision Log		:	V_1.0 - Created - 08/17/2016 - Subhash Garhwal - CR-20160414-9762
	 *
	 **/
    	//Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Contract LOA From Opportunity.
	/*public static void preventIntegratedAccountDeletionCreation(List<Integrated_Account__c> integratedAccounts) {
		
		//Set to hold the Opportunity Ids
		Set<Id> setContractLOAOppIds = new Set<Id>();
		
		//Loop over the Integrated Account list
		for(Integrated_Account__c iA : integratedAccounts) {
			
			//Check for Opportunity and add Id in set
			if(iA.Opportunity__c != null)
				setContractLOAOppIds.add(iA.Opportunity__c);
		}
		
		//Check for set size
		if(setContractLOAOppIds.size() > 0) {
			
			//Query through the Proposals/Quotes
			List<SBQQ__Quote__c> quotes = [Select Id From SBQQ__Quote__c Where SBQQ__Opportunity2__c IN : setContractLOAOppIds
																		       AND SBQQ__Opportunity2__r.RecordType.DeveloperName =: CPQConstants.OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_CONTRACT_LOA
																		       AND SBQQ__Status__c IN : CPQConstants.SET_QUOTE_STATUS_VALUES LIMIT 1];
			
			//Check for size
			if(quotes.size() > 0)
				throw new CustomException(Label.PROPOSAL_INTEGRATED_ACCOUNT_DELETE_ERROR);
		}
	}*/
	
	/**
	 *	@description	:	Method is used to update the proposal Integrated Account Field whenever a Integrated Account is Created/Updated/Deleted 					
	 *
	 *	@args			:	List<Integrated_Account__c>, Map<Id, Integrated_Account__c>
	 *
	 *	@return			:	void
	 *
	 *	@revision Log	:	V_1.0 - Created By - Subhash Garhwal - 02/02/2018 
	 *						V_1.1 - Modified - Subhash Garhwal - 04/27/2018 - CR-20180427-12188 - Change code to update Integrated Accounts
	 *
	 **/
	 public static void populateIntegratedAccountOnProposal(List<Integrated_Account__c> integratedAccounts, Map<Id, Integrated_Account__c> mapOldIntegratedAccounts) {
	 	
	 	//Map to hold the Id of opportunity with Set of String (Name of Integrated Account)
	 	Map<Id, Set<String>> mapAccountFormalNameOfIntegratedAccount = new Map<Id, Set<String>>();
	 	
	 	//List to hold the quotes
	 	List<SBQQ__Quote__c> quoteToUpdate = new List<SBQQ__Quote__c>();
	 	
	 	//Loop through the List of quote
	 	for(Integrated_Account__c iA : integratedAccounts != null ? integratedAccounts : mapOldIntegratedAccounts.values()) {
	 		
	 		//Map to hold the opportunity with the Set String
	 		mapAccountFormalNameOfIntegratedAccount.put(iA.Opportunity__c, new Set<String>());
	 		
	 		//Additional check for the update case if opp changes 
	 		if(mapOldIntegratedAccounts != null && mapOldIntegratedAccounts.get(iA.Id).Opportunity__c != iA.Opportunity__c)
	 			mapAccountFormalNameOfIntegratedAccount.put(mapOldIntegratedAccounts.get(iA.Id).Opportunity__c, new Set<String>());
	 	}
	 	
	 	//Check for the size of List
	 	if(mapAccountFormalNameOfIntegratedAccount.size() > 0 ) {
	 		
	 		//Query on the Integrated Account 
	 		for(Integrated_Account__c inteAcc : [Select Id, Account_Formal_Name__c, Opportunity__c
	 										 From Integrated_Account__c Where Opportunity__c IN : mapAccountFormalNameOfIntegratedAccount.keyset()] ) {
	 			
	 			//Check if map contains the Key 
		 		if(mapAccountFormalNameOfIntegratedAccount.containsKey(inteAcc.Opportunity__c))
		 			mapAccountFormalNameOfIntegratedAccount.get(inteAcc.Opportunity__c).add(inteAcc.Account_Formal_Name__c);
		 	}
	 		
	 		//Query Quotes for the Specific opportunity
	 		for(SBQQ__Quote__c proposal : [Select Id, SBQQ__Opportunity2__c, Primary_Contact_Institution__c, Integrated_Accounts__c, Proposal_Version__c From SBQQ__Quote__c Where SBQQ__Opportunity2__c IN: mapAccountFormalNameOfIntegratedAccount.keyset() ]) {
                
	 			//Check if the Map contain the Opportunity
	 			if(mapAccountFormalNameOfIntegratedAccount.containsKey(proposal.SBQQ__Opportunity2__c)) {
	 				
	 				//String to hold the integrated ABC in line sepereated
	 				String integratedAccount = '';
	 				
	 				//loop on the Map to get the set from its Values
	 				for(String integratedAcc : mapAccountFormalNameOfIntegratedAccount.get(proposal.SBQQ__Opportunity2__c))	
	 					integratedAccount += integratedAcc + '\n' ;
	 				
	 				//Check for Primary_Contact_Institution__c
	 				if(String.isNotBlank(proposal.Primary_Contact_Institution__c))
						proposal.Integrated_Accounts__c = proposal.Primary_Contact_Institution__c + '\n';
						
                    //Check if the Primary contact contains integrated Account
			    	if(String.isNotBlank(integratedAccount) && String.isNotBlank(proposal.Primary_Contact_Institution__c) &&!integratedAccount.contains(proposal.Primary_Contact_Institution__c))
		    			proposal.Integrated_Accounts__c = proposal.Primary_Contact_Institution__c + '\n' + integratedAccount.removeEnd('\n');
		    		else if(String.isNotBlank(integratedAccount))
		    			proposal.Integrated_Accounts__c = integratedAccount.removeEnd('\n');
		    		
                    Integer proVersion = 0;
                    
		    		//Check for Proposal Version
		    		if(proposal.Proposal_Version__c != null)
		    			proVersion = Integer.valueOf(proposal.Proposal_Version__c);
		    			
		    		//Adding those Proposal to the another list
		    		quoteToUpdate.add(new SBQQ__Quote__c (Id = proposal.Id, Integrated_Accounts__c = proposal.Integrated_Accounts__c, Proposal_Version__c = String.valueOf(proVersion + 1)));
                }
	 		}
	 		//ByPass All Trigger
	 		Util.BypassAllTriggers = true;
            
	 		//Check for the Size of the List
	 		if(quoteToUpdate.size() > 0)
	 			update quoteToUpdate;

            //ByPass All Trigger
	 		Util.BypassAllTriggers = false;
	 	}	
	 }
}