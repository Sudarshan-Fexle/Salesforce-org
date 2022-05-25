/**
 *  Description     :   Helper class for Sales credit Note triggers 
 * 
 *  Created By      :   Neha Sharma
 * 
 *  Created Date    :   07/12/2021
 * 
 *  Revision Logs   :   V1.0 - Created - CR-20201113-14692
 *                      
**/ 
public with sharing class SalesCreditNoteTriggerHelper {
	/**
      * 
      *  @description	:   Added method to update the contract on Sales Credit Note from Invoice Billing Schedule 
      *
      *  @args		:   List<c2g__codaCreditNote__c>, Map<Id, c2g__codaCreditNote__c>
      *
      *  @return	:   void
      *
      *  @revision Log	:   V1.0 - Created - 07/12/2020 - Neha Sharma - CR-20201113-14692               
      * 
    **/
    public static void populateContractOnSalesCreditNote(List<c2g__codaCreditNote__c> salesCreditNotelist,Map<Id, c2g__codaCreditNote__c> mapOldSalesCreditNote){
        
        set<Id> setOfInvoiceBillingScheduleId = new set<Id>();
        Map<Id,Invoice_Billing_Schedule__c> mapOfInvoiceBillingSch = new Map<Id,Invoice_Billing_Schedule__c>();
        
        //Iterate the loop to the invoice billing schedule Id from sales credit note
        for(c2g__codaCreditNote__c salesCredit : salesCreditNotelist){
           
            if(mapOldSalesCreditNote == null || (mapOldSalesCreditNote != null && salesCredit.InvoiceBillingSchedule__c != mapOldSalesCreditNote.get(salesCredit.Id).InvoiceBillingSchedule__c) ){
               
                if(salesCredit.InvoiceBillingSchedule__c != null){
                    setOfInvoiceBillingScheduleId.add(salesCredit.InvoiceBillingSchedule__c);
                }
                else{
                    salesCredit.Contract__c = null;
                }
            }
        }
        
        //using setOfInvoiceBillingScheduleId fill the map of InvoiceBillingSchedule
        if(setOfInvoiceBillingScheduleId.size() > 0){
            for(Invoice_Billing_Schedule__c ibs : [Select Id,Standard_Contract__c from Invoice_Billing_Schedule__c 
                                                   where Id IN: setOfInvoiceBillingScheduleId AND Standard_Contract__c != null])
            {
                mapOfInvoiceBillingSch.put(ibs.Id,ibs);
            }
        }
        
        for(c2g__codaCreditNote__c salesCredit : salesCreditNotelist){
            
            //If InvoiceBillingSchedule != null on SalesCreditNote then populate the contract as same as the InvoiceBillingSchedule Contract
            if(salesCredit.InvoiceBillingSchedule__c != null){
                if(mapOfInvoiceBillingSch.containskey(salesCredit.InvoiceBillingSchedule__c)){
                    salesCredit.Contract__c = mapOfInvoiceBillingSch.get(salesCredit.InvoiceBillingSchedule__c).Standard_Contract__c;
                }
            }
        }

    }
}