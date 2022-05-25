/**
 *  Description     :  Helper class for Line Item Schedule object trigger.
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  06/09/2017
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
 *			V_1.1 - Modified - Subhash Garhwal - CR-20180607-12270
 * 			V_1.2 - Modified - Shalu Sharma - CR-20210528-15187 - Added new "populateLineItemScheduleTotalOnContractABC" method to populate Line_Item_Schedule_Total__c on Contract ABC
 **/
public without sharing class LineItemScheduleTriggerHelper {
    
    //CR-20180607-12270
    public Static Boolean byPassLineItemScheduleTriggerHelper = false;
    
    /**
     * 
     *  @description    :   This method is used to update the Contract ABC on the Line Item schedule if Program Subscriptions are updated
     *
     *  @args           :   List<Line_Item_Schedule__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/09/2017 - Subhash Garhwal
     * 
     **/
    public static void updateContractABC(List<Line_Item_Schedule__c> lineItemSchedules) {
        
        //CR-20180607-12270
        if(byPassLineItemScheduleTriggerHelper)
        	return;
        
        //Set to hold the Program Subscription Ids
        Set<Id> setProgramSubscriptionIds = new Set<Id>();
        
        //Loop over the Line Item Schedule
        for(Line_Item_Schedule__c lIS : lineItemSchedules) {
            
            //Check for Program Subscription
            if(lIS.Program_Subscription__c != null && lIS.Contract__c == null)
                setProgramSubscriptionIds.add(lIS.Program_Subscription__c); 
        }           
        
        //Check for set size
        if(setProgramSubscriptionIds.size() > 0) {
            
            //SOQL over the subscription
            Map<Id, SBQQ__Subscription__c> mapSubscriptions = new Map<Id, SBQQ__Subscription__c>([Select Id, Shadow_Contract_ABC__c, Invoice_Billing_Schedule__c
                                                                                                         From SBQQ__Subscription__c Where Id IN : setProgramSubscriptionIds
                                                                                                              AND Shadow_Contract_ABC__c != null]);
                
            //Loop over th LIS
            for(Line_Item_Schedule__c lIS : lineItemSchedules) {
                
                //Check for Program Subscription
                if(lIS.Program_Subscription__c != null && mapSubscriptions.containsKey(lIS.Program_Subscription__c))
                    lIS.Contract__c = mapSubscriptions.get(lIS.Program_Subscription__c).Shadow_Contract_ABC__c; 
            }
        }
    }
    
    /**
     * 
     *  @description    :   This method is used to update the Program Subscriptions on the related Sales Service and Credit notes
     *
     *  @args           :   List<Line_Item_Schedule__c>, Map<Id, Line_Item_Schedule__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/09/2017 - Subhash Garhwal
     * 
     **/
    public static void updateProgramSubscriptionOnSalesInvoiceAndCreditNote(List<Line_Item_Schedule__c> lineItemSchedules, Map<Id, Line_Item_Schedule__c> mapOldLineItemSchedules) {
        
        //Map to update the Sales Invoice records
        Map<String, c2g__codaInvoice__c> mapSalesInvoices = new Map<String, c2g__codaInvoice__c>();
        
        //Map to update the Credit Notes records
        Map<String, c2g__codaCreditNote__c> mapCreditNotes = new Map<String, c2g__codaCreditNote__c>();
        
        //Loop over the Line Item Schedule
        for(Line_Item_Schedule__c lIS : lineItemSchedules) {
            //Check for Program Subscription
            if(lIS.Program_Subscription__c != null) {
                
                //Check for Sales Invoice
                if(lIS.Sales_Invoice__c != null)
                    mapSalesInvoices.put(lIS.Sales_Invoice__c, new c2g__codaInvoice__c(Id = lIS.Sales_Invoice__c, Program_Subscription__c = lIS.Program_Subscription__c));
                
                //Check for Sales Credit Notes
                if(lIS.SalesCreditNote__c != null)
                    mapCreditNotes.put(lIS.SalesCreditNote__c, new c2g__codaCreditNote__c(Id = lIS.SalesCreditNote__c, Program_Subscription__c = lIS.Program_Subscription__c)); 
            }
        }
        
        //Check for sales invoice map size
        if(mapSalesInvoices.size() > 0)
            update mapSalesInvoices.values();
        
        //Check for credit invoice map size
        if(mapCreditNotes.size() > 0)
            update mapCreditNotes.values();             
    }
    
    /**
     * 
     *  @description    :   This method is used to populate Line_Item_Schedule_Total__c on Contract ABC
     *
     *  @args           :   List<Line_Item_Schedule__c>, Map<Id, Line_Item_Schedule__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/24/2021 - Shalu Sharma
     * 
     **/
    public static void populateLineItemScheduleTotalOnContractABC(List<Line_Item_Schedule__c> newLineItemSchedules, 
                                                                  Map<Id, Line_Item_Schedule__c> mapOldLineItemSchedules) 
    { 
        Set<Id> setOfContractABCIds = new Set<Id>();
        
        List<Contract__c> contractABCToBeUpdated = new  List<Contract__c>();
        
        Map<Id,Double> mapOfContractWithAmount = new Map<Id,Double>();
        
        for(Line_Item_Schedule__c lIS : newLineItemSchedules != null ? newLineItemSchedules : mapOldLineItemSchedules.values()) 
        {
            if(lIS.Contract__c != null &&  lIS.Amount__c != null 
               && (newLineItemSchedules == null || mapOldLineItemSchedules == null 
                   || ( newLineItemSchedules != null && mapOldLineItemSchedules != null 
                       && (lIS.Contract__c != mapOldLineItemSchedules.get(lIS.Id).Contract__c 
                           || lIS.Amount__c != mapOldLineItemSchedules.get(lIS.Id).Amount__c ))))
            {
                setOfContractABCIds.add(lIS.Contract__c);
            }
        } 
        
        if(setOfContractABCIds.size() > 0)
        {
            AggregateResult[] aggResult = [Select Contract__c, SUM(Amount__c) sumOfAmount 
                                           FROM Line_Item_Schedule__c WHERE Contract__c != null AND Contract__c IN : setOfContractABCIds Group By Contract__c];
            
            //If aggregate result is greater than 0 means exits Line Item Schedule with amount
            if(aggResult.size() > 0)
            {
                for(AggregateResult agg : aggResult)
                {
                    if(agg.get('sumOfAmount') != null)
                    {
                        mapOfContractWithAmount.put((Id)agg.get('Contract__c'),(Double)agg.get('sumOfAmount'));      
                    }    
                }
            }
            else
            {
                for(Id contractABCIds : setOfContractABCIds )
                {
                    mapOfContractWithAmount.put(contractABCIds,0);        
                }
            }
            
            for(Contract__c contract : [Select Id, Line_Item_Schedule_Total__c from Contract__c WHERE Id IN : setOfContractABCIds])
            {
                if(mapOfContractWithAmount.containsKey(contract.Id) && mapOfContractWithAmount.get(contract.Id) != null)
                {
                    contract.Line_Item_Schedule_Total__c = (Double)mapOfContractWithAmount.get(contract.id);
                    contractABCToBeUpdated.add(contract);
                }
            }
            
            if(contractABCToBeUpdated.size() > 0)
            {
                Util.BypassAllTriggers = true;
                update contractABCToBeUpdated;
                Util.BypassAllTriggers = false;
            }
        }
    }
}