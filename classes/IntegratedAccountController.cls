/**
*  Description     :  Controller class for Integrated Account New, Edit and View 
*
*  Created By      :  Subhash Garhwal
*
*  Created Date    :  06/04/2017
*
*  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20170403-10807
*                      
**/
public with sharing class IntegratedAccountController {
    
    //Instance of Integrated Account
    public Integrated_Account__c integratedAccount {get;set;}
    
    //Variable to hold the account Id
    public String accountId {get;set;}
    
    //Controller
    public IntegratedAccountController(ApexPages.StandardController controller) {
        
        //Get record
        integratedAccount = (Integrated_Account__c)controller.getRecord();
        
        //call inIt method
        inIt();
    }
    
    //inIt method
    public void inIt() {
        
        //Get Opportunity Id
        String oppId = System.currentPageReference().getParameters().get('oppId');
        
        //Check for Opp Id
        if(oppId != null)
            integratedAccount.Opportunity__c = oppId;
        
        //Check for Integrated Account
        accountId = integratedAccount.Integrated_Account__c;
        
        //Get the Opportunity
        if(integratedAccount.Opportunity__c != null && integratedAccount.Integrated_Account__c == null) {
            
            //Get the Account Id
            List<Opportunity> opp = [Select Id, AccountId From Opportunity Where Id =: integratedAccount.Opportunity__c AND AccountId != null];
            
            //Check for opp
            if(opp.size() > 0)
                accountId = opp[0].AccountId;	
        }
    }
    
    /**
    *	@Description	:	Method to update the accountId.
    *
    *	@args			:	
    *
    *	@return			:	void
    *
    *	@Revision Log	:	V1.0 - 06/04/2017 - Subhash Garhwal - Created
    *
    **/
    public void populateAccountId() {
        
        //Set Account
        integratedAccount.Integrated_Account__c = accountId;
    }
    
    /**
    *	@Description	:	Save and new method
    *
    *	@args			:	
    *
    *	@return			:	void
    *
    *	@Revision Log	:	V1.0 - 06/04/2017 - Subhash Garhwal - Created
    *
    **/
    public PageReference doSaveAndNew() {
        
        //Check for record
        if(integratedAccount != null) {
            
            //Insert 
            insert integratedAccount;
            
            PageReference pg = new PageReference('/apex/IntegratedAccountNewAndEdit?oppId=' +integratedAccount.Opportunity__c);
            pg.setRedirect(true);
            
            //Return
            return pg;
        }
        
        //Return
        return null;
    }
}