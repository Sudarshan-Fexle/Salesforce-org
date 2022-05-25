//V1.0 - 08/05/2019 - Modified - Subhash Garhwal - CR-20181019-12685 - Added try catch hack for unable to lock row issue
public with sharing class QuoteExtController {
    private Id quoteId;
    public SBAA__Approval__c[] approvals {get; set;}
    
    public QuoteExtController(ApexPages.StandardController stdController) {
        quoteId = stdController.getId();
    }
    
    //V1.0 - 08/05/2019 - Modified - Subhash Garhwal - CR-20181019-12685 - Added try catch hack for unable to lock row issue
    public PageReference onSubmit() {
        
        try {
            if (quoteId != null) {
                SBAA.ApprovalAPI.submit(quoteId, SBAA__Approval__c.Quote__c);
            }
        
        } catch(Exception e){
                
            //Check for UNABLE_TO_LOCK_ROW error
            if(e.getmessage().contains('UNABLE_TO_LOCK_ROW')) {
                    
                if (quoteId != null)
                    SBAA.ApprovalAPI.submit(quoteId, SBAA__Approval__c.Quote__c);
            } else {
                //system.debug('@@@ exception ' + (e.getMessage()) +'@@@ Stack Trac ' + (e.getStackTraceString())  );
                ApexPages.addMessages(e);
                return null;
            }
        }
        return new PageReference('/' + quoteId);
    }
    
    //Modified by Colin McGloin - 7/28 to add Opportunity Stage validation
    public PageReference onRecall() {
        
        //Get the Quote Record and associated Opportunity    
        SBQQ__Quote__c recordQuote = [SELECT Id, SBQQ__Opportunity2__c FROM SBQQ__Quote__c  WHERE Id = :quoteId];
        
        for (Opportunity opp : [SELECT Id, StageName From Opportunity WHERE Id = :recordQuote.SBQQ__Opportunity2__c]){
            
            //Check to see if the Stage is equal to 'Contract Received - Send to Finance' - if it is then add error and return null so the user sees the error message on the VF page
            if (opp.StageName == CPQConstants.OPPORTUNITY_STAGE_CONTRACT_REC_SEND_TO_FINANCE || opp.StageName == CPQConstants.OPPORTUNITY_STAGE_CLOSED_WON || opp.StageName == CPQConstants.OPPORTUNITY_STAGE_CLOSED_LOST){
                recordQuote.addError(Label.RecallQuoteError);
                return null;
            }
            
            else {
                if (quoteId != null) {
                    SBAA.ApprovalAPI.recall(quoteId, SBAA__Approval__c.Quote__c);
                }
                return new PageReference('/' + quoteId);
                
            }
            
        }
        return new PageReference('/' + quoteId);
    }
    
    public PageReference onPreview() {
        if (quoteId != null) {
            approvals = SBAA.ApprovalAPI.preview(quoteId,
                                                 SBAA__Approval__c.Quote__c);
        }
        return null;
    }
}