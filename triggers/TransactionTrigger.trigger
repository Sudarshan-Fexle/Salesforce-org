//Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
//Modified By - Colin McGloin - 03/26/2018 - CR-20170905-11177 - Moved the Populate CINV ID logic to code due to Process Builder/Flow SOQL Limit Issues
trigger TransactionTrigger on c2g__codaTransaction__c (after insert, after update) {
	
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('c2g__codaTransaction__c')) return;

    Util.IsTrigger_Invoice = true;
    
    Set<Id> cInvIdSet = new Set<Id>();
    
    // if the sales invoice is paid or amt = 0, add the related consolidated invoice Id to our set of Ids
    for (c2g__codaTransaction__c invc : Trigger.new) {
        
        cInvIdSet.add(invc.Id);
    }

    // get all consolidated invoices and update them
    List<ConsolidatedInvoiceLineItem__c> cInvsToUpdate = [SELECT Id FROM ConsolidatedInvoiceLineItem__c WHERE Invoice__r.c2g__Transaction__c IN :cInvIdSet AND Invoice__r.c2g__InvoiceStatus__c = 'Complete'];
    if (cInvsToUpdate.size() > 0)
        update cInvsToUpdate;

    Set<Id> ContractIDs = new Set<Id>();
    Set<Id> TransactionIDs = new Set<Id>();
    if (trigger.isInsert) {
        for (c2g__codaTransaction__c s : trigger.new) {
            TransactionIDs.add(s.Id);
        }
    }

    if (trigger.isUpdate) {
        for (Integer i = 0; i < trigger.new.size(); i++) {
            if (trigger.new[i].c2g__DocumentOutstandingTotal__c != trigger.old[i].c2g__DocumentOutstandingTotal__c) {
                TransactionIDs.add(trigger.new[i].Id);
            }
        }
    }
	
	//List of c2g__codaInvoice__c
	List<c2g__codaInvoice__c> invoices = new List<c2g__codaInvoice__c>();
	
    for (c2g__codaInvoice__c s : [select ContractABC__c, Program_Subscription__c, c2g__NetTotal__c from c2g__codaInvoice__c where c2g__Transaction__c in :TransactionIds]) {
        If (s.ContractABC__c != null) {ContractIDs.add(s.ContractABC__c);}
        
        //Add record in list
        invoices.add(s);
    }
	
	//Check for size
	if(invoices.size() > 0)
		InvoiceTriggerHelper.rollupInvoiceTotal(invoices, null);
	
	if (ContractIDs.size() > 0) {
        List<Contract__c> updCon = InvoiceTriggerHelper.RollupInvoiceAmtOnContract(ContractIDs, false);
        Database.Saveresult[] sr = database.update(updcon,false);
    }

    //Logic used to populate the CINV ID on the Transaction
    TransactionTriggerHelper.updateTransactionCINV(Trigger.new, Trigger.oldMap);

}