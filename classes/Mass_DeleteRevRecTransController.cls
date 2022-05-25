public with sharing class Mass_DeleteRevRecTransController {
    Public Boolean errorMsg {Get; Set;}
    private ApexPages.StandardSetController standardController;
    
    public Mass_DeleteRevRecTransController(ApexPages.StandardSetController standardController) {
        errorMsg = true;
        this.standardController = standardController;
    }
    
    public PageReference deleteRevenueRecognition() {
        
        errorMsg = false;
        
        Set<Id> setOfSelectedIds = new Map<Id, SObject>(standardController.getSelected()).keySet();        
		        
        try{
                  
            delete [SELECT Id FROM ffrr__RevenueRecognitionTransaction__c WHERE Id in :setOfSelectedIds];  
            return standardController.cancel(); 
        }
        catch(DMLException de) {
            
            Apexpages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.FATAL, de.getDmlMessage(0)));
            return NULL;
        }
        catch(Exception e) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.FATAL, e.getMessage()));
            return NULL;
        }
    }
}