/**
*   Description     :   This is helper class for Inventory Transaction object.
*
*   Revision Log    :   V1.0 - 04/22/2021 - CR-20210325-15027 - Victor Hanson - Created
*                       V_1.1 - Modified By Abhinav Sharma - 05/12/2021 - CR-20210310-14983 - Include component_code__c and status__c in the callout (InventoryTransferRequest)
*			V_1.2 - Modified By Abhinav Sharma - 06/04/2021 - CR-20210524-15178 - OE/BRE-Automation QA/Issues Fixes
*			V_1.3 - Modified By Abhinav Sharma - 06/17/2021 - CR-20210525-15180 - Add new "populateLocationOnInventory" method to populate Location on the Inventory 
*  			V_1.4 - Modified By Subhash Garhwal - 10/20/2021 - CR-20210924-15459 - Added new method "checkAddNewInventoryRequest"
*			V_1.5 - Modified By Shalu Sharma - 10/20/2021 - CR-20210924-15459 - Added new method "rollupAvailableAmountOnInventory" and modify "checkInventoryTransferRequest" method
*/
public without sharing class InventoryTransactionTriggerHelper 
{
    //Added By - Shalu Sharma - 10/18/2021 - CR-20210924-15459 - Added a property for 'Transfer Requested'
    public static final String INVENTORY_TRANSACTION_STATUS_TRANSFER_REQUESTED = 'Transfer Requested';
    public static final String INVENTORY_TRANSACTION_STATUS_REQUESTED = 'Requested';
    public static final String INVENTORY_TRANSACTION_STATUS_TRANSFERRED = 'Transferred';
    public static final String INVENTORY_TRACKING_RT_ID_PRINT_REQUEST = Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByDeveloperName().get('Print_Request').getRecordTypeId();
    public static final String INVENTORY_TRACKING_RT_ID_TRANSFER_REQUEST = Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByDeveloperName().get('Transfer_Request').getRecordTypeId();
    public static final String INVENTORY_TRACKING_RT_ID_ADJUSTMENT_REQUEST = Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByDeveloperName().get('Adjustment_Request').getRecordTypeId();
    
    public static final String INVENTORY_TRANSACTION_STATUS_MAILED = 'Mailed';
    public static final String INVENTORY_TRANSACTION_STATUS_SPOILED = 'Spoiled';
    public static final String INVENTORY_TRANSACTION_STATUS_ALLOCATED = 'Allocated';
    
    //When certain status values are reached, send callout to Original / Target vendor
    public static void checkInventoryTransferRequest(List<Inventory_Transaction__c> newITransactions, Map<Id, Inventory_Transaction__c> oldITransactionsMap) 
    {        
        //Modified By Abhinav Sharma - 05/12/2021 - CR-20210310-14983 - Include component_code__c and status__c in the callout (InventoryTransferRequest)
        //get a map of all Inventory Transactions so we can pull additional details (ie: job ticket id)
        //Modified By Abhinav Sharma - 06/04/2021 - CR-20210524-15178 - Include Id, Name, Quantity, Job Ticket Name, School__c, Ship_Date__c, Arrival_Date_Anticipated__c,Shipping_Method__c, and Tracking_Number__c in the callout (InventoryTransferRequest)
        Map<Id, Inventory_Transaction__c> invTransactionMap = new Map<Id, Inventory_Transaction__c>([SELECT Id, Name, Production_Tracking__r.Job_Ticket__c, Production_Tracking__c, Target_Vendor__c, 
                                                                                                     Original_Vendor__c, Target_Vendor_Name__c, Original_Vendor_Name__c, Quantity__c, 
                                                                                                     Component_Code__c, Inventory__c, Status__c, Production_Tracking__r.Job_Ticket__r.Name, 
                                                                                                     Production_Tracking__r.Job_Ticket__r.School__c, Ship_Date__c, Arrival_Date_Anticipated__c,
                                                                                                     Shipping_Method__c, Tracking_Number__c
                                                                                                     FROM Inventory_Transaction__c WHERE Id IN :newITransactions]);
        for (Inventory_Transaction__c iTransaction : newITransactions) {
            Inventory_Transaction__c oldITransaction;
            if (oldITransactionsMap != null) 
                oldITransaction = oldITransactionsMap.get(iTransaction.Id);
            
            //if target vendor is populated and target vendor or status is updated, check if one of the callouts below needs to be sent
            if (iTransaction.Target_Vendor__c != null &&  
                (oldITransaction == null || oldITransaction.Target_Vendor__c == null || iTransaction.Status__c != oldITransaction.Status__c)) 
            {
                Inventory_Transaction__c invTransactionWithDetails = invTransactionMap.get(iTransaction.Id);
                if (invTransactionWithDetails != null && invTransactionWithDetails.Production_Tracking__c != null && invTransactionWithDetails.Production_Tracking__r.Job_Ticket__c != null ) {
                    
                    InventoryTransactionWrapper itw = new InventoryTransactionWrapper();
                    itw.InventoryTransactions = new List<Inventory_Transaction__c>();
                    itw.InventoryTransactions.add(invTransactionWithDetails);
                    
                    //Modified By Abhinav Sharma - 06/04/2021 - CR-20210524-15178 - Add Name and School in InventoryTransactionWrapper   
                    itw.School = invTransactionWithDetails.Production_Tracking__r.Job_Ticket__r.School__c;
                    itw.JobTicket = invTransactionWithDetails.Production_Tracking__r.Job_Ticket__r.Name;
                    
                    String jsonString = JSON.serialize(itw, false);

                    //if status is Requested, send 'inventoryTransferRequest' callout to original vendor
                    //Modified By - Shalu Sharma - 10/18/2021 - CR-20210924-15459 - change "Requested" to "Transafer Requested" in condition
                    if (iTransaction.Status__c == INVENTORY_TRANSACTION_STATUS_TRANSFER_REQUESTED && iTransaction.Target_Vendor__c != iTransaction.Original_Vendor__c) {
                        
                        //send callout to Original Vendor so they can ship the request
                        sendCallout(iTransaction.Original_Vendor__c, ProductionTrackingTriggerHelper.COMMAND_INVENTORY_TRANSFER_REQUEST, invTransactionWithDetails, jsonString);
                    }
                    //if status is Transfer In Progress, send 'inventoryShippedNotification' to the target vendor
                    else if (iTransaction.Status__c == JobTicketService.INVENTORY_TRANSACTION_STATUS_TRANSFER_IN_PROGRESS) {
                        
                        //send callout to Target Vendor, providing them with details about the inventory shipped to them
                        sendCallout(iTransaction.Target_Vendor__c, ProductionTrackingTriggerHelper.COMMAND_INVENTORY_SHIPPED_NOTIFICATION, invTransactionWithDetails, jsonString);
                    }
                }
            }
        }
    }
    
    public static void sendCallout(Id vendorId, String command, Inventory_Transaction__c iTransaction, String jsonString) 
    {
        //send callout to Target Vendor, providing them with details about the inventory shipped to them
        ProductionTrackingTriggerHelper.sendVendorCallout(vendorId, 
                                                          iTransaction.Production_Tracking__c, 
                                                          iTransaction.Production_Tracking__r.Job_Ticket__c,
                                                          iTransaction.Id,
                                                          jsonString,
                                                          command,
                                                          ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL);
    }
    
    //Added By Abhinav Sharma - 06/17/2021 - CR-20210525-15180 - Method to populate Location field on the Inventory 
    public static void populateLocationOnInventory(List<Inventory_Transaction__c> newITransactions, Map<Id, Inventory_Transaction__c> oldITransactionsMap) 
    {
        Set<Id> setOfInventoryIds = new Set<Id>();
        List<Inventory__c> inventoryToBeUpdated = new List<Inventory__c>();
        for (Inventory_Transaction__c iTransaction : newITransactions != null ? newITransactions : oldITransactionsMap.values()) 
        {
            if(iTransaction.Inventory__c != null && (newITransactions == null || oldITransactionsMap == null || 
                                                     (newITransactions != null && oldITransactionsMap != null && 
                                                      iTransaction.Original_Vendor__c != oldITransactionsMap.get(iTransaction.Id).Original_Vendor__c)))
            {
                setOfInventoryIds.add(iTransaction.Inventory__c);
            } 
        }
        
        if(setOfInventoryIds.size() > 0)
        {
            Set<Id> setOfPrintVendorIds = new Set<Id>();
            Map<Id,Id> mapOfInventoryIdWithPrintVendorId = new Map<Id,Id>();
            
            for(Inventory_Transaction__c invTransaction : [Select Id, Inventory__c, Original_Vendor__c 
                                                           From Inventory_Transaction__c 
                                                           Where Inventory__c IN : setOfInventoryIds 
                                                           AND Original_Vendor__c != null])
            {
                setOfPrintVendorIds.add(invTransaction.Original_Vendor__c);
                if(!mapOfInventoryIdWithPrintVendorId.containsKey(invTransaction.Inventory__c))
                {
                    mapOfInventoryIdWithPrintVendorId.put(invTransaction.Inventory__c, invTransaction.Original_Vendor__c);
                }
            }
            
            if(mapOfInventoryIdWithPrintVendorId.size() > 0)
            {
                for(Id invId : mapOfInventoryIdWithPrintVendorId.KeySet())
                {
                    Inventory__c inv = new Inventory__c(Id = invId);
                    for(Id pVIDs : setOfPrintVendorIds)
                    {
                        if(pVIDs == mapOfInventoryIdWithPrintVendorId.get(inv.Id))
                        {
                            inv.Location__c = Label.Location_Same;    
                        }
                        else
                        {
                            inv.Location__c = Label.Location_Multiple;  
                        }
                    }
                    inventoryToBeUpdated.add(inv);
                }          
            }
            else
            {
                for(Inventory__c inv : [Select Id, Location__c From Inventory__c Where Id IN :setOfInventoryIds])
                {
                    Inventory__c inventory = new Inventory__c(Id = inv.Id, Location__c = null);
                    inventoryToBeUpdated.add(inventory);
                } 
            }
            
            if(inventoryToBeUpdated.size() > 0)
            {
                Util.byPassAllTriggers = true;
                update inventoryToBeUpdated;
                Util.byPassAllTriggers = false;
            }
        }
    }
    
    //Added By Subhash Garhwal - 10/20/2021 - CR-20210924-15459 - Added new method "checkAddNewInventoryRequest"
    public static void checkAddNewInventoryRequest(List<Inventory_Transaction__c> newITransactions, 
                                                   Map<Id, Inventory_Transaction__c> oldITransactionsMap)
    {
        Map<Id, Map<Id, Set<Id>>> mapOfInventoryWithPTIds = new Map<Id, Map<Id, Set<Id>>>();
        Set<Id> setOfInventoryTxIds = new Set<Id>();
        
        //Collection to have inventory manager vendors name
        Set<String> setOfVendorsName = new Set<String>();
        
        for(Inventory_Wizard_Manager__mdt invManager : [SELECT ID, Vendor_Label__c
                                                        FROM Inventory_Wizard_Manager__mdt
                                                        WHERE Active__c = true 
                                                        AND Enable_AddNewInventory__c = true
                                                        ORDER BY Vendor_Label__c ASC
                                                       ]
           ) 
        {
            setOfVendorsName.add(invManager.Vendor_Label__c);
        }
        
        if(setOfVendorsName.size() > 0)
        {
            for (Inventory_Transaction__c iTransaction : newITransactions) 
            {   
                if (iTransaction.Original_Vendor__c != null 
                    && setOfVendorsName.contains(iTransaction.Original_Vendor_Name__c)
                    && iTransaction.Inventory__c != null
                    && iTransaction.Status__c == INVENTORY_TRANSACTION_STATUS_REQUESTED
                    && (oldITransactionsMap == null || (oldITransactionsMap != null && (oldITransactionsMap.get(iTransaction.Id).Original_Vendor__c == null))))
                { 
                    if(!mapOfInventoryWithPTIds.containsKey(iTransaction.Inventory__c))
                        mapOfInventoryWithPTIds.put(iTransaction.Inventory__c, new Map<Id, Set<Id>>());
                    
                    if(!mapOfInventoryWithPTIds.get(iTransaction.Inventory__c).containsKey(iTransaction.Production_Tracking__c))
                        mapOfInventoryWithPTIds.get(iTransaction.Inventory__c).put(iTransaction.Production_Tracking__c, new Set<Id>());
                    
                    mapOfInventoryWithPTIds.get(iTransaction.Inventory__c).get(iTransaction.Production_Tracking__c).add(iTransaction.Id);
                    
                    setOfInventoryTxIds.add(iTransaction.Id);
                }
            }
            
            if(mapOfInventoryWithPTIds.size() > 0 && mapOfInventoryWithPTIds.keySet().size() > 0 && setOfInventoryTxIds.size() > 0){
                
                Set<Id> setOfPrintPTIds = new Set<Id>();
                Map<Id, Set<Id>> mapOfPrintPTWithInvTxns = new Map<Id, Set<Id>>();
                
                for(Inventory_Transaction__c invTx : [Select Id, Inventory__c From Inventory_Transaction__c 
                                                      Where Id NOT IN :setOfInventoryTxIds
                                                      AND Inventory__c != null AND Inventory__c IN :mapOfInventoryWithPTIds.keySet()])
                {
                    if(mapOfInventoryWithPTIds.containsKey(invTx.Inventory__c))
                    {
                        for(Id printPTId : mapOfInventoryWithPTIds.get(invTx.Inventory__c).keySet())
                        {
                            if(!mapOfPrintPTWithInvTxns.containsKey(printPTId))
                                mapOfPrintPTWithInvTxns.put(printPTId, new Set<Id>());
                            
                            mapOfPrintPTWithInvTxns.get(printPTId).addAll(mapOfInventoryWithPTIds.get(invTx.Inventory__c).get(printPTId));
                            
                        }
                        
                        setOfPrintPTIds.addAll(mapOfInventoryWithPTIds.get(invTx.Inventory__c).keySet());
                    }
                }
                
                if(setOfPrintPTIds.size() > 0){
                    for(Production_Tracking__c printPT : [SELECT Id, Name, Art_File_Name__c, Status__c, 
                                                          Status_Detail__c, Job_Ticket__c
                                                          FROM Production_Tracking__c 
                                                          WHERE Id IN: setOfPrintPTIds])
                    {
                        sendAddNewInventoryRequest(printPT, mapOfPrintPTWithInvTxns);
                    }
                }
            }
        }
    }
    
    public static void sendAddNewInventoryRequest(Production_Tracking__c pTracking, Map<Id, Set<Id>> mapOfPrintPTWithInvTxns) 
    {
        //get map of artifact transfers
        Map<String, Artifact_Transfer__c> mapJTArtifactTx = ProductionTrackingTriggerHelper.getMapJTArtifactTransfers(new List<Production_Tracking__c>{pTracking});
        
        //get job ticket details
        List<Job_Ticket__c> jTickets = ProductionTrackingTriggerHelper.getJobTicketDetails(pTracking);
        
        if (jTickets.size() > 0) 
        {
            //send each job ticket and artifacts transfer to the future method for vendor callout
            for (Job_Ticket__c jt : jTickets) 
            { 
                if(mapOfPrintPTWithInvTxns.containsKey(pTracking.Id)){
                    
                    //get the json body
                    Map<String, Object> deserializedJT = ProductionTrackingTriggerHelper.getJobTicketJSONWithArtifactTx(jt, mapJTArtifactTx, pTracking, Constants.ARTIFACT_TYPE_ARTWORK, Constants.ARTIFACT_TRANSFER_DIRECTION_PUSH, false);
                    
                    for(Id invTxId : mapOfPrintPTWithInvTxns.get(pTracking.Id)){
                        
                        List<Inventory_Transaction__c> invTransactions = getInventoryTransactions(pTracking, invTxId);
                        
                        if (invTransactions.size() > 0) 
                        {
                            deserializedJT.put('inventoryTransactions', invTransactions);
                        }
                        
                        //send callout to Vendor & write response back to web service log
                        ProductionTrackingTriggerHelper.sendCallout(pTracking.Id, JSON.serialize(deserializedJT, false), ProductionTrackingTriggerHelper.COMMAND_ADD_NEW_INVENTORY, ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL);
                    }
                }
            }
        }
    }    
    
    /**
    *  Purpose         :    dynamically get fields from field sets on Inventory Transaction records as per Inv Id
    * 
    *  Revision Logs   :    Added By - Subhash Garhwal - 10/20/2021 - CR-20210924-15459 
    *                     
    **/
    public static List<Inventory_Transaction__c> getInventoryTransactions(Production_Tracking__c pt, Id invTxId) {
        String invTransactionQuery = 'SELECT ' + JobTicketService.setToCommaDelim(util.getFieldSetFieldsAPINames('Inventory_Transaction__c', 'Inv_Transaction_Callout_Field_Set')) 
            + ' FROM Inventory_Transaction__c ';
        invTransactionQuery += ' WHERE Production_Tracking__c != null AND Production_Tracking__c=\'' + pt.Id + '\' AND Id =\'' + invTxId + '\'';
        return database.query(invTransactionQuery);
    }
    
    
    
    //Modified By Shalu Sharma - 10/29/2021 - CR-20210924-15459 - Added new method "rollupAvailableAmountOnInventory"
    public static void rollupAvailableAmountOnInventory(List<Inventory_Transaction__c> newITransactions, 
                                                        Map<Id, Inventory_Transaction__c> oldITransactionsMap)
    {
        Map<Id, Inventory__c> mapOfInventoryToUpdate = new Map<Id, Inventory__c>();
        for (Inventory_Transaction__c iTransaction : newITransactions != null ? newITransactions : oldITransactionsMap.values()) 
        {
            if(iTransaction.Inventory__c != null && (newITransactions == null || oldITransactionsMap == null || 
                                                     (newITransactions != null && oldITransactionsMap != null && 
                                                      (iTransaction.Inventory__c != oldITransactionsMap.get(iTransaction.Id).Inventory__c
                                                       || iTransaction.Status__c != oldITransactionsMap.get(iTransaction.Id).Status__c
                                                       || iTransaction.Rollup_Quantity__c != oldITransactionsMap.get(iTransaction.Id).Rollup_Quantity__c
                                                      )))
              )
            {
                mapOfInventoryToUpdate.put(iTransaction.Inventory__c, new Inventory__c(Id = iTransaction.Inventory__c, Current_Available_Amount__c = 0));
                
                if(oldITransactionsMap != null && oldITransactionsMap.get(iTransaction.Id).Inventory__c != null)
                {
                    Id oldInvTxId = oldITransactionsMap.get(iTransaction.Id).Inventory__c;
                    mapOfInventoryToUpdate.put(oldInvTxId, new Inventory__c(Id = oldInvTxId, Current_Available_Amount__c = 0)); 
                }
            } 
        }
        
        Set<String> setOfStatusesToSkip = new Set<String>();
        setOfStatusesToSkip.add('Transfer Requested');
        setOfStatusesToSkip.add('Transfer In Progress');
        setOfStatusesToSkip.add('Requested');
        setOfStatusesToSkip.add('Allocated');
        setOfStatusesToSkip.add('Mailed');
        setOfStatusesToSkip.add('Spoiled');
        
        if(mapOfInventoryToUpdate.size() > 0 && mapOfInventoryToUpdate.keySet().size() > 0)
        {
            for(AggregateResult invTxWithSum : [SELECT Inventory__c inventoryId, SUM(Rollup_Quantity__c) sumOfQuantity 
                                                FROM Inventory_Transaction__c 
                                                Where Inventory__c != null 
                                                	AND Inventory__c IN : mapOfInventoryToUpdate.keySet()
                                                	AND (
                                                        Status__c NOT IN  : setOfStatusesToSkip 
                                                     	OR (
                                                            (
                                                             Status__c = 'Transfer Requested' 
                                                             OR 
                                                             Status__c = 'Transfer In Progress'
                                                            ) 
                                                            AND Rollup_Quantity__c < 0
                                                        )
                                                    )
                                                Group By Inventory__c
                                               ]
               )
            {
                if(invTxWithSum.get('sumOfQuantity') != null && mapOfInventoryToUpdate.containsKey((Id)invTxWithSum.get('inventoryId')))
                {
                    mapOfInventoryToUpdate.get((Id)invTxWithSum.get('inventoryId')).Current_Available_Amount__c = (Double)invTxWithSum.get('sumOfQuantity');
                }
            }
            
            Set<String> setOfStatusesToInclude = new Set<String>();
            setOfStatusesToInclude.add('Allocated');
            setOfStatusesToInclude.add('Mailed');
            setOfStatusesToInclude.add('Spoiled');
            
            Map<Id, Map<String, Double>> mapOfInvIdWithTxStatusAndAmount = new Map<Id, Map<String, Double>>();
            for(Inventory_Transaction__c invTx : [SELECT Inventory__c, Rollup_Quantity__c, Status__c
                                                  FROM Inventory_Transaction__c 
                                                  Where Inventory__c != null 
                                                  AND Inventory__c IN :mapOfInventoryToUpdate.keySet()
                                                  AND Status__c IN :setOfStatusesToInclude])
            {
                if(!mapOfInvIdWithTxStatusAndAmount.containsKey(invTx.Inventory__c))
                    mapOfInvIdWithTxStatusAndAmount.put(invTx.Inventory__c, new Map<String, Double>());
                if(!mapOfInvIdWithTxStatusAndAmount.get(invTx.Inventory__c).containsKey(invTx.Status__c))
                    mapOfInvIdWithTxStatusAndAmount.get(invTx.Inventory__c).put(invTx.Status__c, invTx.Rollup_Quantity__c);
                else{
                    Double totalAmount = mapOfInvIdWithTxStatusAndAmount.get(invTx.Inventory__c).get(invTx.Status__c) + invTx.Rollup_Quantity__c;
                    mapOfInvIdWithTxStatusAndAmount.get(invTx.Inventory__c).put(invTx.Status__c, totalAmount);
                }
            }
            
            Boolean isMailedInvTxAvailable = false;
            for(Id invId : mapOfInventoryToUpdate.keySet()){
                
                if(mapOfInvIdWithTxStatusAndAmount.containsKey(invId)){
                    isMailedInvTxAvailable = false;
                    if(mapOfInvIdWithTxStatusAndAmount.get(invId).containsKey('Mailed'))
                    {
                        mapOfInventoryToUpdate.get(invId).Current_Available_Amount__c += mapOfInvIdWithTxStatusAndAmount.get(invId).get('Mailed');
                        isMailedInvTxAvailable = true;
                    }
                    if(mapOfInvIdWithTxStatusAndAmount.get(invId).containsKey('Spoiled'))
                    {
                        mapOfInventoryToUpdate.get(invId).Current_Available_Amount__c += mapOfInvIdWithTxStatusAndAmount.get(invId).get('Spoiled');
                        isMailedInvTxAvailable = true;
                    }
                    if(!isMailedInvTxAvailable && mapOfInvIdWithTxStatusAndAmount.get(invId).containsKey('Allocated'))
                    {
                        mapOfInventoryToUpdate.get(invId).Current_Available_Amount__c += mapOfInvIdWithTxStatusAndAmount.get(invId).get('Allocated');
                    }
                }
            }
            
            if(mapOfInventoryToUpdate.values().size() > 0)
            {
                Util.BypassAllTriggers = true;
                update mapOfInventoryToUpdate.values();
                Util.BypassAllTriggers = false;
            }
        }
    }
    
    //Modified By Abhinav Sharma - 06/04/2021 - CR-20210524-15178 - Include Name and School in InventoryTransactionWrapper
    public class InventoryTransactionWrapper 
    {
        public List<Inventory_Transaction__c> InventoryTransactions { get; set; }
        Public String School {get;set;}
        Public String JobTicket {get;set;}
    }
}