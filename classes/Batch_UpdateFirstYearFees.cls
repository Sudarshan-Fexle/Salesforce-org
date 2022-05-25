/**
 *  Description     :  Batch class to update First Year Type in Proposal Line hand historical data of Proposals.
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  08/09/2018
 *
 */
global class Batch_UpdateFirstYearFees implements Database.Batchable<SObject> {
        
    //Start Method
    global Database.Querylocator start(Database.BatchableContext BC) {
    	
        
        //Retrieving and returning Proposal Line records
        return Database.getQueryLocator([Select Id, X1st_Year_Type__c, SBQQ__Quote__c, SBQQ__StartDate__c, SBQQ__CustomerTotal__c 
        								 From SBQQ__QuoteLine__c Where X1st_Year_Type__c  != null ORDER BY SBQQ__StartDate__c ASC, SBQQ__Quote__c ASC]);
    }
    
    //Execute Method
    global void execute(Database.BatchableContext BC, List<SBQQ__QuoteLine__c> quoteLines) {
		
		//List to hold Proposal Lines to be update 
		List<SBQQ__QuoteLine__c> quoteLinesToBeUpdate = new List<SBQQ__QuoteLine__c>();
		
		//Map of Proposals
		Map<Id,  SBQQ__Quote__c> mapOfProposals = new Map<Id, SBQQ__Quote__c>();
		
		//Map to hold the Proposal Ids with is first Proposal Line Start Date
		Map<Id, Date> mapOfProposalIdWithStartDate = new Map<Id, Date>();
		
		//Loop ovet the Proposal Lines
		for(SBQQ__QuoteLine__c qL : quoteLines) {
	
			//Add values into the List to be update 
			quoteLinesToBeUpdate.add(new SBQQ__QuoteLine__c(Id = qL.Id, X1st_Year_Type__c = '')); 
	
			//Blank check for Proposal over Proposal Line
			if(!String.isBlank(qL.SBQQ__Quote__c)){
	
				//Contains check
				if(!mapOfProposalIdWithStartDate.containsKey(qL.SBQQ__Quote__c)) {
					
					//Add values into the map
					mapOfProposalIdWithStartDate.put(qL.SBQQ__Quote__c, qL.SBQQ__StartDate__c);
										
					//Add proposal value
					SBQQ__Quote__c proposal = new SBQQ__Quote__c();
					proposal.Id  = qL.SBQQ__Quote__c ;
					proposal.First_Year_Annual__c = null;
					proposal.First_Year_Travel__c = null;
					proposal.First_Year_Implementation__c = null;
					
					//Check if First Year Type is Annual
					if(qL.X1st_Year_Type__c == 'Annual')
						proposal.First_Year_Annual__c = qL.SBQQ__CustomerTotal__c;
					
					//Check if First Year Type is Travel	
					if(qL.X1st_Year_Type__c == 'Travel')
						proposal.First_Year_Travel__c = qL.SBQQ__CustomerTotal__c;
					
					//Check if First Year Type is Implementation
					if(qL.X1st_Year_Type__c == 'Implementation')
						proposal.First_Year_Implementation__c = qL.SBQQ__CustomerTotal__c;
						
					//Put values into the map
					mapOfProposals.put(qL.SBQQ__Quote__c, proposal);
					
					//Check if Proposal Lines have same start date over same Proposal
				} else if(mapOfProposalIdWithStartDate.get(qL.SBQQ__Quote__c) == qL.SBQQ__StartDate__c){
				
					//Check if First Year Type is Annual
					if(qL.X1st_Year_Type__c == 'Annual' && mapOfProposals.get(qL.SBQQ__Quote__c).First_Year_Annual__c == null)
						mapOfProposals.get(qL.SBQQ__Quote__c).First_Year_Annual__c = qL.SBQQ__CustomerTotal__c;
						
					//Check if First Year Type is Travel
					if(qL.X1st_Year_Type__c == 'Travel' && mapOfProposals.get(qL.SBQQ__Quote__c).First_Year_Travel__c == null)
						mapOfProposals.get(qL.SBQQ__Quote__c).First_Year_Travel__c = qL.SBQQ__CustomerTotal__c;
					
					//Check if First Year Type is Implementation
					if(qL.X1st_Year_Type__c == 'Implementation' && mapOfProposals.get(qL.SBQQ__Quote__c).First_Year_Implementation__c == null)
						mapOfProposals.get(qL.SBQQ__Quote__c).First_Year_Implementation__c = qL.SBQQ__CustomerTotal__c;		
				}
			} 
		}
	
		//Null and Size check
		if(mapOfProposals != null && mapOfProposals.size() > 0) {
	
			//Bypass all Triggers
			Util.ByPassAllTriggers = true;
			
			//Update Proposals
			update mapOfProposals.values();
	
			//Bypass all Triggers
			Util.ByPassAllTriggers = false;
		}
	
		//Size check
		if(quoteLinesToBeUpdate.size() > 0) {
	
			//Bypass all Triggers
			Util.ByPassAllTriggers = true;
			
			//Update Proposal Lines
			update quoteLinesToBeUpdate;
	
			//Bypass all Triggers
			Util.ByPassAllTriggers = false;
		}
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC) {
   
    }
}