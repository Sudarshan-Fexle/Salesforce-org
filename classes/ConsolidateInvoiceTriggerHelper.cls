/**
  * Purpose         :   This class is helper class for trigger on Consolidated Invoices object.
  *             
  * Create By       :   Abhinav Sharma
  * 
  * Created Date    :   06/23/2015
  * 
  * Current Version :   v1.0
  * 
  * Revision Log    :   V_1.0 Created 
  *
**/

public class ConsolidateInvoiceTriggerHelper {
    
    /**
     *  @description    :   This mthod is to synchronize the values from activities(Task) histories.
     *
     *  @args       :   List of consolidatedInvoices records(Trigger.New)
     *
     *  @return     :   void
     *  
     **/ 
    
    public static void syncValuesFromActivityHistories(List<ConsolidatedInvoice__c> consolidatedInvoices) {

        //Set to hold the consolidated invoices IDs
        Set<Id> setConsolidatedInvoicesIds = new Set<Id>();

        //Loop through consolidated invoice records
        for(ConsolidatedInvoice__c cI : consolidatedInvoices)
            setConsolidatedInvoicesIds.add(cI.Id);

        //Checking set for size value
        if(setConsolidatedInvoicesIds != null && setConsolidatedInvoicesIds.size() > 0) {

            //Map to hold the consolidated invoice Id as key and associated most recent activity history as value
            Map<Id, ActivityHistory> mapCInvoiceIdWithActivityHistory = new Map<Id, ActivityHistory>();

            //Loop through opportunity records
            for(ConsolidatedInvoice__c con : [SELECT ID, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c,
                            (SELECT ID, LastmodifiedDate, Subject FROM ActivityHistories
                                WHERE IsTask = true ORDER BY LastmodifiedDate DESC LIMIT 1)
                                FROM ConsolidatedInvoice__c 
                                WHERE ID IN : setConsolidatedInvoicesIds]) {
            
                //Check for ActivityHistories size
                //Popoulate mapCInvoiceIdWithActivityHistory map
                if(con.ActivityHistories != null && con.ActivityHistories.size() > 0)
                    mapCInvoiceIdWithActivityHistory.put(con.Id, con.ActivityHistories[0]);                    
            }
            
            //loop through new records and updating them with fields value
            for(ConsolidatedInvoice__c cInv : consolidatedInvoices) {

                //Check for Activity History records availability
                if(mapCInvoiceIdWithActivityHistory.containsKey(cInv.Id) 
                    && mapCInvoiceIdWithActivityHistory.get(cInv.Id) != null) {
                    
                    //Updating field values
                    cInv.Last_Follow_Up_Date__c = Date.valueOf(mapCInvoiceIdWithActivityHistory.get(cInv.Id).LastModifiedDate);
                    cInv.Last_Follow_Up_Note__c = mapCInvoiceIdWithActivityHistory.get(cInv.Id).Subject;
                } else {
                    
                    //Assigning the default values to fields 
                    cInv.Last_Follow_Up_Date__c = null;
                    cInv.Last_Follow_Up_Note__c = null;
                }
        	}
        }
    }
}