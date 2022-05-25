/**
 *  Purpose         :   Helper class for BillingScheduleHeader trigger
 *
 *  Create By       :   Neha Sharma
 *
 *  Created Date    :   07/12/2021
 *
 *  Revision Logs   :   V_1.0 - Created - Neha Sharma - 07/08/2021 - CR-20210209-14889 
 *                 
 **/
public without sharing class BillingScheduleHeaderHelper {
    
    /**
     *  @description    :   This method is to update Invoice Bundle field on all associated BSL's (through the BSP's)
     * 
     *  @args           :   List of new BillingScheduleHeader , Map of old BillingScheduleHeader
     * 
     *  @return         :   void
     * 
     * Revision Logs    :   Added By - Neha Sharma - 07/08/2021 - CR-20210209-14889 
     * 
     **/
    public static void  updateInvoiceBundleOnBSL(List<Billing_Schedule_Header__c> newBillingScheduleHeaders, Map<Id, Billing_Schedule_Header__c> mapOldBillingScheduleHeaders) {
        
        Set<Id> setOfBillingScheduleHeaderIds = new Set<Id>();
        List<Billing_Schedule_Line__c> bslToBeUpdated  = new List<Billing_Schedule_Line__c>();
        
        //Loop through BillingScheduleHeader records (update case)
        for(Billing_Schedule_Header__c bsh : newBillingScheduleHeaders) {
            //Update case
            if(mapOldBillingScheduleHeaders != null && bsh.Invoice_Bundle__c != mapOldBillingScheduleHeaders.get(bsh.Id).Invoice_Bundle__c) {
                   setOfBillingScheduleHeaderIds.add(bsh.Id);
               }
        }
        
        //check set size
        if(setOfBillingScheduleHeaderIds.size() > 0)
        {
            for(Billing_Schedule_Line__c bsl : [Select Id,Billing_Schedule_Period__r.Billing_Schedule_Header__c,Billing_Schedule_Period__r.Billing_Schedule_Header__r.Invoice_Bundle__c,Invoice_Bundle__c 
                                                from Billing_Schedule_Line__c
                                                where Billing_Schedule_Period__c != null
                                                AND Billing_Schedule_Period__r.Billing_Schedule_Header__c != null
                                                AND Billing_Schedule_Period__r.Billing_Schedule_Header__c IN: setOfBillingScheduleHeaderIds])
            {
                //set invoice bundle value from BSH level to BSL level                                    
                bsl.Invoice_Bundle__c = bsl.Billing_Schedule_Period__r.Billing_Schedule_Header__r.Invoice_Bundle__c;
                bslToBeUpdated.add(bsl);
            }
        }
        
        if(bslToBeUpdated.size() > 0){
            //bypass trigger before update
            util.BypassAllTriggers = true;
            Update bslToBeUpdated;
            util.BypassAllTriggers = false; 
        }
    }
        
}