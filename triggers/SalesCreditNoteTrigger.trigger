//V1.1 - Modified By - Subhash Garhwal - Q2C Phase 2 - 06/07/2017
//V1.2 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
//V1.3 - Modified By - Neha Sharma - 07/12/2020  - CR-20201113-14692 
trigger SalesCreditNoteTrigger on c2g__codaCreditNote__c (after insert, after update, before insert, before update) {
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('c2g__codaCreditNote__c')) return;		

    try {
		
		//Bypass flag
        if(Util.BypassAllTriggers) return;
        
		Util.IsTrigger_Invoice = true;
    	
    	//Check for trigger context
    	if(Trigger.isAfter) {
    		
    		//Check for trigger event
    		if(Trigger.isInsert || Trigger.isUpdate) {
    			
    			//Call helper class method
    			InvoiceTriggerHelper.rollupAmountCreditedTotal(Trigger.new, Trigger.oldMap);
    		}
    	}
        
        //Check for trigger context - Neha Sharma - CR-20201113-14692  
    	if(Trigger.isBefore) {
    		
    		//Check for trigger event
    		if(Trigger.isInsert || Trigger.isUpdate) {
    			
    			//Call helper class method
    			SalesCreditNoteTriggerHelper.populateContractOnSalesCreditNote(Trigger.new, Trigger.oldMap);
    		}
    	}
	    
	    Set<Id> ContractIDs = new Set<Id>();
	    if (trigger.isInsert) {
	        for (c2g__codaCreditNote__c s : trigger.new) {
	            If (s.ContractABC__c != null) {ContractIDs.add(s.ContractABC__c);}
	        }
	    }
	
	    if (trigger.isUpdate) {
	        for (Integer i = 0; i < trigger.new.size(); i++) {
	            if (trigger.new[i].c2g__NetTotal__c != trigger.old[i].c2g__NetTotal__c) { 
	                if (trigger.new[i].ContractABC__c != null) {ContractIDs.add(trigger.new[i].ContractABC__c);}
	            }
	        }
	    }
	    
	    if (ContractIDs.size() > 0) {
	        List<Contract__c> updCon = InvoiceTriggerHelper.RollupInvoiceAmtOnContract(ContractIDs, true);
	        Database.Saveresult[] sr = database.update(updcon,false);
	    }    	
    //Catching DML Exception
    } catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));

    //Catching all Exceptions
    } catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}