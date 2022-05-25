//V1.1 - Modified By - Subhash Garhwal - Q2C Phase 2 - 06/08/2017
//V1.2 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
trigger SalesInvoiceTrigger on c2g__codaInvoice__c (before update, after insert, after update,before delete,before insert) {
	
	//return immediately if method returns true	
        if(Util.areTriggersOnThisObjectBypassed('c2g__codaInvoice__c')) return;	

	//Bypass trigger
	if(Util.BypassAllTriggers) return;
	
    Util.IsTrigger_Invoice = true;
    
    //Added in by Colin McGloin - 03/25/2019
    if (Trigger.isBefore){

        if(Trigger.isUpdate) {

            //Added for Billing Schedule Update Project
            InvoiceTriggerHelper.updateAssociatedBillingSchedulePeriod(Trigger.new, Trigger.oldMap);
        }
        
	 //Created - 06/12/2020 - Mahendra Swarnkar - CR-20200605-14145
        //Check for trigger event
		if(Trigger.isInsert || Trigger.isUpdate) {
		
			//Call helper class method
			InvoiceTriggerHelper.populateCreditManagePhone(Trigger.new, Trigger.oldMap);
		}
    }
	
	//Check for trigger context
	if(Trigger.isAfter) {
		
		//Check for trigger event
		if(Trigger.isInsert || Trigger.isUpdate) {
			
			//Call helper class method
			InvoiceTriggerHelper.rollupInvoiceTotal(Trigger.new, Trigger.oldMap);
		}
	}
	
    Set<Id> ContractIDs = new Set<Id>();
    if (trigger.isInsert) {
        for (c2g__codaInvoice__c s : trigger.new) {
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
        AggregateResult[] r = [select ContractABC__c, sum(c2g__NetTotal__c) NT, sum(c2g__Transaction__r.c2g__DocumentOutstandingTotal__c) AC 
        	from c2g__codaInvoice__c where ContractABC__c != null and ContractABC__c in :ContractIDs group by ContractABC__c];
    
        List<Contract__c> updcon = new List<Contract__c>();
        Decimal NT, AC;
        for (Integer i = 0; i < r.size(); i++) {
            NT = 0;
            AC = 0;
    
            if (r[i].get('NT') != null) {
                NT = Decimal.valueOf(String.valueOf(r[i].get('NT')));
            }
    
            if (r[i].get('AC') != null) {
                AC = Decimal.valueOf(String.valueOf(r[i].get('AC')));
            }
    
            updcon.add(new Contract__c(
                Id = String.valueOf(r[i].get('ContractABC__c')), 
                    Invoice_Total__c = NT, 
                    Amount_Credited_Total__c = NT - AC
                ));

        }
        
        // Bypass all triggers prior to updating the contracts (CR-)
        Util.BypassAllTriggers = true;
		Database.Saveresult[] sr = database.update(updcon,false);
    }

}