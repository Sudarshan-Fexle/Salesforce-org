public with sharing class ContractDocument_Con
{
  	/*
	Purpose: 	Controller for a Visualforce page that combines creation of a Contract_Document__c record with attachment of a file to the newly-created record.
					Page: ContractDocumemt
	
	Create By: 	Yogesh (Synaptic) - 12/2010
	
	Last Modified By: 	Jeremy Nottingham (Synaptic) - 1/20/2011
	
	Current Version: 	v1.1
	
	Revision Log:		v1.0 - (Yogesh) Created this controller class and accompanying test and VF modules
						v1.1 - (Jeremy) Added comments and this header
	*/
	
	// public propertise
	public Opportunity CurrentOpportunity {get;set;}
	public Contract_Document__c CurrentContractDocument {get;set;}
	public Attachment CDAttachment {get;set;}
	public Contract_Docs_to_Opps_MtM__c ContractDocToOpp {get;set;}
	  
	// constructor
	public ContractDocument_Con()
	{
		// Initialize all properties
	  	CurrentOpportunity = new Opportunity();
	  	CurrentContractDocument = new Contract_Document__c();
	  	CDAttachment = new Attachment();
	  	ContractDocToOpp = new Contract_Docs_to_Opps_MtM__c();
	  	 
	  	// Fetch opportunity coming from
	  	if(ApexPages.CurrentPage().getParameters().get('id') != null)
		{
			for(Opportunity opp : [Select Id, AccountId, Account.Name From Opportunity Where Id = : ApexPages.CurrentPage().getParameters().get('id')])
			{
	  	 		CurrentOpportunity = opp;
	  	 		ContractDocToOpp.Opportunity__c = opp.Id;
	  	 		CurrentContractDocument.Account__c = opp.AccountId;
	  	 	}
	  	}
	}	  
	  
	// Save action 
	public PageReference DoSave()
	{
		PageReference pr = null;
	  	
	  	try
	  	{
	  		// If the Contract Document Attachment Name is null, return an error to the user
	        if(CDAttachment.Name == null )
	        {
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select contract document attachment')); 
	        	return null;
	        }
	        
	        // Set the Current Contract Document Name
	        CurrentContractDocument.Name = CDAttachment.Name;
	        CurrentContractDocument.Name__c = CDAttachment.Name;
	        
	        
	        // Insert contract document
			database.insert(CurrentContractDocument,true);
	  		
	  		// Insert contract document attachment
	  		if(CDAttachment.Name != null)
	  		{
	  			CDAttachment.ParentId = CurrentContractDocument.Id;
	  			
	  			database.insert(CDAttachment,true);
	  		}
	  		
	  		// Insert Contract_Docs_to_Opps_MtM__c
	  		ContractDocToOpp.Contract_Documents__c = CurrentContractDocument.Id;
	  		
	  		database.insert(ContractDocToOpp,true);
	  		
	  		pr = new PageReference('/' + CurrentContractDocument.Id);
	  	}
	  	catch(Exception ex)
	  	{
	  		// Return error to user
	  		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));   
	  	}
	  	
		return pr;
	}
  
	// Cancel action
	public PageReference DoCancel()
	{
		// return back to opportunity
		return new PageReference('/' + CurrentOpportunity.Id);
	}
}