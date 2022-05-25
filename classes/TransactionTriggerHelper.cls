public with sharing class TransactionTriggerHelper {
    
    public TransactionTriggerHelper() {
        
    }
    
    
    /**
    *  @description    :   Method to quickly evaluate if we need to populate CINV ID field on Transaction and pass values to Future Method
    * 
    *  @args           :   List of Transactions/Map of Old Transactions
    *
    *  @return         :   void
    *
    *  Added By		   :   Colin McGloin - 03/26/2018 - CR-20170905-11177
    *  Modified By	   :   Colin McGloin - 04/26/2018 - CR-20180426-12185 - Modified from @future method due to Payment Batch Issues
    *
    **/
    
    public static void updateTransactionCINV (List<c2g__codaTransaction__c> newTransactions, Map<Id, c2g__codaTransaction__c> oldMapTransactions){
        
        //Our Set which we'll use in our Future Method for the field updates
        Set<ID> transactionIDs = new Set<ID>();
        
        //List to update
        List<c2g__codaTransaction__c> transRecordsToUpdate = new List<c2g__codaTransaction__c>();
        
        //Loop through our records from the Trigger
        for (c2g__codaTransaction__c trans : newTransactions){
            
            //If our Transaction has been updated to have a CINV value but no ID, then pass into our Set
            if (trans.CINV__c != null && trans.CINV_ID__c == null){
                transactionIDs.add(trans.Id);
            }
            
            //If our CINV has been changed then re-run our process
            if (oldMapTransactions == null || (trans.CINV__c != null && trans.CINV__c != oldMapTransactions.get(trans.Id).CINV__c)) {
                transactionIDs.add(trans.Id);
            }
            
        }
        
        //If we have records, then kick off our future process
        if (transactionIDs.size() > 0){
            
            //Map for Name to ID for CINV records
            Map<String, Id> nameToIdMap = new Map<String, Id>();
            
            //Set for use in our CINV query
            Set<String> CINVNames = new Set<String>();
            
            //Grab our Transaction records
            List <c2g__codaTransaction__c> transRecords = [SELECT Id, CINV__c, CINV_ID__c FROM c2g__codaTransaction__c WHERE Id IN :transactionIDs];
            
            //Loop Through our Transaction records if we have them and add CINV name to our Set
            for (c2g__codaTransaction__c trans : transRecords){
                if (trans.CINV__c != null){
                    CINVNames.add(trans.CINV__c);
                }
            }
            
            //Run our query if we have records
            if (CINVNames.size() > 0) {
                for (ConsolidatedInvoice__c cinv : [SELECT Id, Name FROM ConsolidatedInvoice__c WHERE Name IN :CINVNames]){
                    if (nameToIdMap.get(cinv.Name) == null){
                        nameToIdMap.put(cinv.Name, cinv.Id);
                    }
                }
            }
            
            //Loop back through our Transaction records finally
            if (transRecords.size() > 0){
                for (c2g__codaTransaction__c trans : transRecords){
                    //If we have a record in our Map then populate the CINV ID field on the Transaction
                    if (nameToIdMap.get(trans.CINV__c) != null){
                        trans.CINV_ID__c = nameToIdMap.get(trans.CINV__c);
                        transRecordsToUpdate.add(trans);
                    }
                }
            }
            
            //If we have records to update then proceed
            if (transRecordsToUpdate.size() > 0){
                update transRecordsToUpdate;
            }
            
        }
        
    }    
    
}