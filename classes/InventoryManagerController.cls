/**
*  Description     :    This controller is used to Manage Inventory on Job Ticket level.
*
*  Created By      :    Shalu Sharma   
* 
*  Created Date    :    10/07/2021 
* 
*  Revision Logs   :    V_1.0 Created - Shalu Sharma - 10/07/2021 - CR-20210924-15459 - Print Inventory Management 2.0
*
*/
public without sharing class InventoryManagerController 
{
    public static List<String> listOfEligibleComponentType = System.Label.Eligible_Component_Type_For_Inventory_Manager.split(',');
    public static Set<String> setOfEligibleComponentType = new Set<String>(listOfEligibleComponentType);
    public static final String getBaseUrl = URL.getSalesforceBaseUrl().toExternalForm();
    public static final String INVENTORY_TRACKING_RT_ID_ADJUSTMENT_REQUEST = Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByDeveloperName().get('Adjustment_Request').getRecordTypeId();
    //Method to have reterive the existing Job Ticket Components - using for dynamically drawing tabsets
    @AuraEnabled(cacheable=true)
    public static LightningResponseEntity getExistingJobTicketMtMAndComponents(String currentJTRecordId) 
    {
        LightningResponseEntity res = new LightningResponseEntity();
        try
        {
            if(String.isNotBlank(currentJTRecordId)) 
            {
                List<JobTicketMtMAndComponentWrapper> jobTicketMtMAndComponentWrapperList = new List<JobTicketMtMAndComponentWrapper>();
                for (Job_Ticket_MtM__c  jTM : [SELECT Id, Name, Job_Ticket__c, Job_Ticket__r.Name, Job_Ticket_Component__c, 
                                               Job_Ticket_Component__r.Name, Job_Ticket_Component__r.Component__c
                                               FROM Job_Ticket_MtM__c 
                                               WHERE Job_Ticket__c =: currentJTRecordId 
                                               	AND Job_Ticket_Component__r.Component__c IN :setOfEligibleComponentType 
                                               ORDER BY Job_Ticket_Component__r.Component__c ASC]) 
                {
                    String tabName = '';
                    if(jTM.Job_Ticket_Component__c != null) 
                    {
                        tabName = jTM.Job_Ticket_Component__r.Name.length() >= 50 ? jTM.Job_Ticket_Component__r.Name.substring(0,50) +'...' : jTM.Job_Ticket_Component__r.Name;
                        JobTicketMtMAndComponentWrapper newWrapper = new JobTicketMtMAndComponentWrapper(jTM.Id, jTM.Name,
                                                                                                         jTM.Job_Ticket__c, jTM.Job_Ticket__r.Name,
                                                                                                         jTM.Job_Ticket_Component__c,
                                                                                                         jTM.Job_Ticket_Component__r.Name, 
                                                                                                         jTM.Job_Ticket_Component__r.Component__c,
                                                                                                         tabName);
                        jobTicketMtMAndComponentWrapperList.add(newWrapper);
                    }
                    else 
                    {
                        JobTicketMtMAndComponentWrapper newWrapper = new JobTicketMtMAndComponentWrapper(jTM.Id, jTM.Name, 
                                                                                                         jTM.Job_Ticket__c, jTM.Job_Ticket__r.Name,
                                                                                                         null, 
                                                                                                         null,
                                                                                                         null,
                                                                                                         tabName);
                        jobTicketMtMAndComponentWrapperList.add(newWrapper);
                    }
                }
                if(jobTicketMtMAndComponentWrapperList.size() > 0)
                {
                    res.setBody(jobTicketMtMAndComponentWrapperList);
                    res.setSuccess(true);
                    return res;
                }
                else
                {
                    res.setMessage(System.Label.No_Eligible_Component_Type_Message);
                    res.setSuccess(true);
                    return res;
                }
            } 
            else 
            {
                res.setError(Label.Insufficient_Access_To_RecordId); 
                return res;     
            }    
        }
        catch (Exception e) 
        {
            res.setError(e.getMessage());
            return res;  
        }
    }
    
    //Method to reterive the existing Prior/Current Inventories for specific JTM
    @AuraEnabled(cacheable=true)
    public static LightningResponseEntity getPriorInventory(String selecetedJTMId)
    {
        LightningResponseEntity res = new LightningResponseEntity();
        try
        {
            if(String.isNotBlank(selecetedJTMId)) 
            {
                Set<String> setOfInventoryComponentCode = new Set<String>();
                List<PriorInventoryWrapper> listOfPriorInventory = new List<PriorInventoryWrapper>();
                
                for(Job_Ticket_MtM__c jtmRec : [SELECT Id, Job_Ticket__r.Name, Job_Ticket__r.Fiscal_Year__c, Component_Code__c 
                                                FROM Job_Ticket_MtM__c 
                                                WHERE Id =: selecetedJTMId])
                {
                    
                    if(jtmRec.Job_Ticket__c != null && String.isNotBlank(jtmRec.Job_Ticket__r.Name) 
                       && jtmRec.Job_Ticket__r.Name.split('-').size() > 2 
                       && jtmRec.Job_Ticket__r.Name.split('-')[2] != 'null')
                    {
                        String priorInvCompCode = jtmRec.Job_Ticket__r.Name.replace(jtmRec.Job_Ticket__r.Name.split('-')[2], 
                                                                                    String.valueOf(Integer.valueOf(jtmRec.Job_Ticket__r.Name.split('-')[2]) - 1));
                        setOfInventoryComponentCode.add(priorInvCompCode +'-'+jtmRec.Component_Code__c ); 
                        setOfInventoryComponentCode.add(jtmRec.Job_Ticket__r.Name +'-'+jtmRec.Component_Code__c); 
                    }   
                }

                if(setOfInventoryComponentCode.size() > 0) 
                {
                    for(Inventory__c inventory :  [SELECT Id, Name, Quantity_in_Inventory__c, Job_Ticket_MtM__r.Job_Ticket__r.Name,
                                                   Assigned_Vendor__c, Assigned_Vendor__r.Name, Production_Tracking__c, Job_Ticket_MtM__r.Job_Ticket__c,
                                                   Job_Ticket_MtM__c
                                                   FROM Inventory__c     
                                                   WHERE Quantity_in_Inventory__c > 0 
                                                   AND Available_for_Future_Use__c = true 
                                                   AND Inventory_Control_Number__c IN : setOfInventoryComponentCode])
                    {
                        listOfPriorInventory.add(new PriorInventoryWrapper(inventory.Id, inventory.Name, getBaseUrl+'/'+inventory.Id, 
                                                                           inventory.Quantity_in_Inventory__c, 'Available',
                                                                           inventory.Assigned_Vendor__c, inventory.Assigned_Vendor__r.Name, 
                                                                           inventory.Production_Tracking__c, inventory.Job_Ticket_MtM__r.Job_Ticket__r.Name,
                                                                           inventory.Job_Ticket_MtM__c));
                    }
                    if(listOfPriorInventory.size() > 0)
                    {
                        res.setBody(listOfPriorInventory);
                        res.setSuccess(true);
                        return res;                    
                    }
                    else
                    {
                        res.setMessage(System.Label.No_Prior_Inventory_Record_To_Display_Msg);
                        res.setSuccess(true);
                        return res;
                    }
                }
                else
                {
                    res.setMessage(System.Label.No_Prior_Inventory_Record_Exist_With_Component_Code_Msg);
                    res.setSuccess(true);
                    return res;
                }
            }
            else 
            {
                res.setError(Label.Insufficient_Access_To_RecordId); 
                return res;     
            }
        }
        catch (Exception e) 
        {
            res.setError(e.getMessage());
            return res;  
        }
    }
    
    //Method to have update the Inventory
    @AuraEnabled(cacheable=false)
    public static LightningResponseEntity updateInventoryRecord(String inventoryId)
    {  
        LightningResponseEntity res = new LightningResponseEntity();
        try
        {
            if(String.isNotBlank(inventoryId)) 
            {
                List<Inventory__c> listOfInventoryToBeUpdate = new List<Inventory__c>();
                for(Inventory__c inv : [SELECT Id, Available_for_Future_Use__c 
                                        FROM Inventory__c 
                                        WHERE Id =: inventoryId])
                {
                    listOfInventoryToBeUpdate.add(new Inventory__c(Id = inv.Id, Available_for_Future_Use__c = false));    
                }
                
                if(listOfInventoryToBeUpdate.size() > 0)
                {
                    Util.byPassAllTriggers = true;
                    update listOfInventoryToBeUpdate;
                    Util.byPassAllTriggers = false;
                    res.setBody(listOfInventoryToBeUpdate);
                    res.setSuccess(true);
                    return res;      
                }
                else
                {
                    res.setMessage(System.Label.No_Prior_Inventory_Record_To_Be_Updated_Msg);
                    res.setSuccess(true);
                    return res;    
                }
            }
            else 
            {
                res.setError(Label.Insufficient_Access_To_RecordId); 
                return res;     
            } 
        }
        catch (Exception e) 
        {
            res.setError(e.getMessage());
            return res;  
        }
    }
    
    //Method to reterive the all vendors like Cenveo, Darwill and Sepire relatied details
   	@AuraEnabled(cacheable=true)
    public static LightningResponseEntity getTreeGridData(String selectedJTMtMId)
    {
        LightningResponseEntity res = new LightningResponseEntity();
        try
        {
            //When a valid record ID exists
            if(String.isNotBlank(selectedJTMtMId)) 
            {
                //Collection to have inventory manager metadata related details
                Map<String, Inventory_Wizard_Manager__mdt> mapOfInvManager = new Map<String, Inventory_Wizard_Manager__mdt>();
                Set<String> setOfVendorsName = new Set<String>();
                Map<String, String> mapOfVendorNameWithLabel = new Map<String, String>();
                
                for(Inventory_Wizard_Manager__mdt invManager : [SELECT ID, Vendor_Label__c, Vendor_Name__c
                                                                FROM Inventory_Wizard_Manager__mdt
                                                                WHERE Active__c = true 
                                                                AND Category__c = 'Vendors Table'
                                                                AND Vendor_Label__c != null AND Vendor_Label__c != ''
                                                                AND Vendor_Name__c != null AND Vendor_Name__c != ''
                                                                ORDER BY Vendor_Label__c ASC
                                                               ]
                ) 
                {
                	mapOfInvManager.put(invManager.Vendor_Name__c, invManager);
                    setOfVendorsName.add(invManager.Vendor_Name__c);
                    mapOfVendorNameWithLabel.put(invManager.Vendor_Name__c, invManager.Vendor_Label__c);
                }
                
                //Checking for the vendor(s) existance
                if(mapOfInvManager.values().size() > 0) 
                {
                    Map<Id, Inventory__c> mapOfEligibleInventories = new  Map<Id, Inventory__c>();
                    Map<Id, List<Inventory_Transaction__c>> mapOfInventoryIdWithInvTxns = new Map<Id, List<Inventory_Transaction__c>>();
                    
                    Map<String, List<InventoryWrapper>> mapOfVendorLabelWithOrWithoutInventories = new Map<String, List<InventoryWrapper>>();
                    Map<String, List<InventoryWrapper>> tempMapOfVendorLabelWithOrWithoutInventories = new Map<String, List<InventoryWrapper>>();
                    Map<String, List<InventoryWrapper>> mapOfVendorLabelWithInventories = new Map<String, List<InventoryWrapper>>();
                    
                    //Loop over invemtory records associated with job ticket record
                    for(Inventory__c inventory :  [SELECT Id, Name, Quantity_in_Inventory__c, Assigned_Vendor__c, 
                                                   Assigned_Vendor__r.Account_Formal_Name__c, 
                                                   Production_Tracking__c, Current_Available_Amount__c
                                                   FROM Inventory__c 
                                                   WHERE Assigned_Vendor__c != null
                                                   AND Job_Ticket_MtM__c != null
                                                   AND Job_Ticket_MtM__c =: selectedJTMtMId
                                                   AND Current_Mail_Drops_Closed__c = false
                                                   ORDER By Assigned_Vendor__r.Account_Formal_Name__c ASC
                                                  ])
                    {
                        String inventoryAssignedVendorName = inventory.Assigned_Vendor__r.Account_Formal_Name__c;
                        
                        if(mapOfInvManager.containsKey(inventoryAssignedVendorName)) 
                        {
                            mapOfEligibleInventories.put(inventory.Id, inventory);
                            setOfVendorsName.remove(inventoryAssignedVendorName);
                        }
                    }
                    
                    //Checking that for the current job ticket record, do we have any inventory
                    if(mapOfEligibleInventories.values().size() > 0) 
                    {
                        for(Inventory_Transaction__c invTxn : [SELECT Id, Name, Status__c, Inventory__c, Quantity__c, Rollup_Quantity__c 
                                                               FROM Inventory_Transaction__c 
                                                               WHERE Inventory__c IN : mapOfEligibleInventories.keySet()])
                        {
                            if(!mapOfInventoryIdWithInvTxns.containsKey(invTxn.Inventory__c))
                            {
                                mapOfInventoryIdWithInvTxns.put(invTxn.Inventory__c, new List<Inventory_Transaction__c>()); 
                            }
                            mapOfInventoryIdWithInvTxns.get(invTxn.Inventory__c).add(invTxn);
                        }
                        
                        Decimal QtySum = 0;
                        for(Inventory__c inv : mapOfEligibleInventories.values())
                        {
                            InventoryWrapper invWrap = new InventoryWrapper();
                            invWrap.id = inv.Id;
                            invWrap.name = inv.Name;
                            invWrap.nameUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + inv.Id;
                            invWrap.inventoryQuantityInInventory = inv.Current_Available_Amount__c;
                            invWrap.inventoryAssignedVendorId = inv.Assigned_Vendor__c;
                            invWrap.inventoryAssignedVendorName = inv.Assigned_Vendor__r.Account_Formal_Name__c;
                            invWrap.selectedInventoryPTRecordId = inv.Production_Tracking__c;
                            invWrap.status = inv.Current_Available_Amount__c > 0 ? 'Inventory Available' : (inv.Current_Available_Amount__c < 0 ? 'Inventory Needed' : '');
                            invWrap.inventoryAmountCss = inv.Current_Available_Amount__c < 0 ? 'amountTextBoldWithColorCss' : 'amountTextBoldCss';
                            invWrap.inventoryStatusCss = inv.Current_Available_Amount__c > 0 ? 'statusTextBoldWithGreenColor' : (inv.Current_Available_Amount__c < 0 ? 'statusTextBoldWithRedColor' : '');
                            if(mapOfVendorNameWithLabel.containsKey(invWrap.inventoryAssignedVendorName))
                            {
                                QtySum += inv.Current_Available_Amount__c;
                            	invWrap.totalAvailableQuantity = QtySum;    
                            }
                            List<Items> inventoryTransactions = new List<Items>();
                            if(mapOfInventoryIdWithInvTxns.containsKey(inv.Id))
                            {
                                for(Inventory_Transaction__c txn : mapOfInventoryIdWithInvTxns.get(inv.Id))
                                {
                                    Items txnWrap = new Items();
                                    txnWrap.id = txn.Id;
                                    txnWrap.name = txn.Name;
                                    txnWrap.nameUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/'+txn.Id;
                                    txnWrap.status = txn.Status__c;
                                    txnWrap.inventoryQuantityInInventory = txn.Rollup_Quantity__c;
                                    inventoryTransactions.add(txnWrap);
                                }
                            }
                            if(inventoryTransactions.size() > 0) 
                            {
                                invWrap.childrenExists = true;
                                invWrap.items = inventoryTransactions;
                            }
                            else 
                            {
                                invWrap.childrenExists = false;
                            }
                            
                            if(!mapOfVendorLabelWithInventories.containsKey(invWrap.inventoryAssignedVendorName))
                            {
                                mapOfVendorLabelWithInventories.put(mapOfVendorNameWithLabel.get(invWrap.inventoryAssignedVendorName), new List<InventoryWrapper>());
                            }
                            mapOfVendorLabelWithInventories.get(mapOfVendorNameWithLabel.get(invWrap.inventoryAssignedVendorName)).add(invWrap);
                        }
                    }    
                    
                    //Loop over vendors with inventories
                    if(mapOfVendorLabelWithInventories.values().size() > 0) 
                    {
                        for(String vendorLabel : mapOfVendorLabelWithInventories.keySet()) 
                        {
                            tempMapOfVendorLabelWithOrWithoutInventories.put(vendorLabel, mapOfVendorLabelWithInventories.get(vendorLabel));
                        }
                    }
                    
                    for(String key : InventoryManagerController.getSortedKeyset(tempMapOfVendorLabelWithOrWithoutInventories)) 
                    {
                        mapOfVendorLabelWithOrWithoutInventories.put(key, tempMapOfVendorLabelWithOrWithoutInventories.get(key));
                    }
                    
                    //loop over vendors that are not having inventory records
                    if(setOfVendorsName.size() > 0) 
                    {
                        Set<String> setOfVendorsLabels = new Set<String>();
                        for(String vendorName : setOfVendorsName) 
                        {
                            if(mapOfVendorNameWithLabel.get(vendorName) != null) 
                            {
                            	setOfVendorsLabels.add(mapOfVendorNameWithLabel.get(vendorName));    
                            }
                        }
                        if(setOfVendorsLabels.size() > 0) 
                        {
                    		List<String> listOfVendorsLabels = new List<String>();
                            listOfVendorsLabels.addAll(setOfVendorsLabels);
                            listOfVendorsLabels.sort();
                            for(String vendorLabel : listOfVendorsLabels) 
                            {
                                mapOfVendorLabelWithOrWithoutInventories.put(vendorLabel, new List<InventoryWrapper>());  
                            }
                            setOfVendorsLabels = new Set<String>();
                            listOfVendorsLabels = new List<String>();        
                        }
                    }
                    
                    tempMapOfVendorLabelWithOrWithoutInventories = new Map<String, List<InventoryWrapper>>(); 
                    mapOfVendorLabelWithInventories = new Map<String, List<InventoryWrapper>>();
                    setOfVendorsName = new Set<String>();
                    
                    res.setBody(mapOfVendorLabelWithOrWithoutInventories);
                    res.setSuccess(true);
                    return res;  
                }
                else
                {
                    res.setMessage('No eligible vendor exists.');
                    res.setSuccess(true);
                    return res;  
                }
            } 
            else
            {
                res.setError(Label.Insufficient_Access_To_RecordId); 
                return res;                
            }
        }
        catch (Exception e) 
        {
            res.setError(e.getMessage());
            return res;  
        }
    }
    
    public static List<String> getSortedKeyset(Map<String, List<InventoryWrapper>> dataMap) 
    {
        List<String> keySetList = new List<String>();
        keySetList.addAll(dataMap.keySet());
        keySetList.sort();
        return keySetList;
	}
    
    //Method to create Inventory and Inventory Txns records
    @AuraEnabled(cacheable=false)
    public static LightningResponseEntity createInventoryAndTxnRecord(String inventoryDetailJson)
    {
        LightningResponseEntity res = new LightningResponseEntity();
        try
        {
            if(String.isNotBlank(inventoryDetailJson))
            {
                List<Inventory__c> listOfInventoryToBeInserted = new List<Inventory__c>();
                List<Inventory_Transaction__c> listOfInventoryTxnToBeInserted = new List<Inventory_Transaction__c>();
                
                PriorInventoryWrapper inventoryDetail = (PriorInventoryWrapper)System.JSON.deserialize(inventoryDetailJson, PriorInventoryWrapper.class);
                if(inventoryDetail != null)
                {
                    List<Job_Ticket_MtM__c> jobTicketMtMs = [SELECT Id, Job_Ticket__r.Project__r.Institution__c FROM Job_Ticket_MtM__c WHERE Id =: inventoryDetail.jobTicketMtMId]; 
                    
                    listOfInventoryToBeInserted.add(new Inventory__c(Name = 'Auto Populate', Production_Tracking__c = inventoryDetail.inventoryProductionTrackingId,
                                                                     Assigned_Vendor__c = inventoryDetail.inventoryAssignedVendorId, Job_Ticket_MtM__c = inventoryDetail.jobTicketMtMId,
                                                                     Institution__c = jobTicketMtMs[0].Job_Ticket__r.Project__r.Institution__c)); 
                    if(listOfInventoryToBeInserted.size() > 0)
                    {
                        insert listOfInventoryToBeInserted;
                        listOfInventoryTxnToBeInserted.add(new Inventory_Transaction__c(Inventory__c = listOfInventoryToBeInserted[0].Id, 
                                                                                        Production_Tracking__c = inventoryDetail.inventoryProductionTrackingId,
                                                                                        Job_Ticket_MtM__c = inventoryDetail.jobTicketMtMId,
                                                                                        Quantity__c = inventoryDetail.quantityInInventory,
                                                                                        Status__c = 'Transferred - Prior Inventory',
                                                                                        Transaction_Type__c = 'Prior Inventory Request (from EAB)',
                                                                                        Requested_By__c = UserInfo.getUserId(),
                                                                                        Original_Vendor__c = inventoryDetail.inventoryAssignedVendorId,
                                                                                        RecordTypeId = INVENTORY_TRACKING_RT_ID_ADJUSTMENT_REQUEST));
                        if(listOfInventoryTxnToBeInserted.size() > 0)
                        {   
                            insert listOfInventoryTxnToBeInserted;
                        }
                        res.setBody(listOfInventoryToBeInserted);
                        res.setSuccess(true);
                        return res; 
                    }
                    else
                    {
                        res.setMessage('No Inventory record to be inserted.');
                        res.setSuccess(true);
                        return res;
                    }
                }
                else
                {
                    res.setMessage('inventoryDetail wrapper can not be null');
                    res.setSuccess(true);
                    return res; 
                }
            }
            else
            {
                res.setError('inventoryDetailJson can not be null'); 
                return res;
            }
        }
        catch (Exception e) 
        {   
            res.setError(e.getMessage());
            return res;  
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static LightningResponseEntity createInventoryTransactionRecord(String selectedRowDetailJson)
    {
        LightningResponseEntity res = new LightningResponseEntity();
        try
        {
            if(String.isNotBlank(selectedRowDetailJson))
            {
                List<Inventory__c> listOfInventoryToBeUpdated = new List<Inventory__c>();
                List<Inventory__c> listOfInventoryToBeInserted = new List<Inventory__c>();
                List<Inventory_Transaction__c> listOfInventoryTxnToBeInserted = new List<Inventory_Transaction__c>();
                JsonToApex selectedRowDetails = (JsonToApex)System.JSON.deserialize(selectedRowDetailJson, JsonToApex.class);
                if(selectedRowDetails != null)
                {
                    List<Inventory__c> inventorys = [SELECT Job_Ticket_MtM__c, Job_Ticket_MtM__r.Job_Ticket__r.Project__r.Institution__c FROM Inventory__c WHERE Id =: selectedRowDetails.inventory];
                    
                    if(selectedRowDetails.actionName == 'add_new')
                    {
                        listOfInventoryTxnToBeInserted.add(new Inventory_Transaction__c(Inventory__c = selectedRowDetails.inventory,
                                                                                        Production_Tracking__c = selectedRowDetails.productionTracking,
                                                                                        Job_Ticket_MtM__c = inventorys[0].Job_Ticket_MtM__c,
                                                                                        Original_Vendor__c = selectedRowDetails.printVendor,
                                                                                        Quantity__c = selectedRowDetails.quantity,
                                                                                        Quantity_Requested__c = selectedRowDetails.quantity,
                                                                                        Status__c = selectedRowDetails.status,
                                                                                        Transaction_Type__c = selectedRowDetails.transactionType,
                                                                                        Requested_By__c = selectedRowDetails.requestedBy,
                                                                                        RecordTypeId = InventoryTransactionTriggerHelper.INVENTORY_TRACKING_RT_ID_PRINT_REQUEST
                                                                                       ));
                    }
                    else if(selectedRowDetails.actionName == 'transfer')
                    { 
                        listOfInventoryTxnToBeInserted.add(new Inventory_Transaction__c(Inventory__c = selectedRowDetails.inventory,
                                                                                        Production_Tracking__c = selectedRowDetails.productionTracking,
                                                                                        Job_Ticket_MtM__c = inventorys[0].Job_Ticket_MtM__c,
                                                                                        Original_Vendor__c = selectedRowDetails.printVendor,
                                                                                        Target_Vendor__c = selectedRowDetails.mailVendor,
                                                                                        Quantity__c = selectedRowDetails.quantity * -1,
                                                                                        Status__c = selectedRowDetails.status,
                                                                                        Transaction_Type__c = selectedRowDetails.transactionType,
                                                                                        Requested_By__c = selectedRowDetails.requestedBy,
                                                                                        RecordTypeId = InventoryTransactionTriggerHelper.INVENTORY_TRACKING_RT_ID_TRANSFER_REQUEST
                                                                                       ));
                        if(selectedRowDetails.mailVendor != null)
                        {
                            List<Inventory__c> existingInventorys = [SELECT Id, Job_Ticket_MtM__c, Production_Tracking__c FROM Inventory__c 
                                                                     WHERE Assigned_Vendor__c =: selectedRowDetails.mailVendor AND Production_Tracking__c =: selectedRowDetails.productionTracking];
                            if(existingInventorys.size() > 0 )
                            {
                                listOfInventoryTxnToBeInserted.add(new Inventory_Transaction__c(Inventory__c = existingInventorys[0].Id,
                                                                                                Production_Tracking__c = selectedRowDetails.productionTracking,
                                                                                                Job_Ticket_MtM__c = existingInventorys[0].Job_Ticket_MtM__c,
                                                                                                Original_Vendor__c = selectedRowDetails.printVendor,
                                                                                                Target_Vendor__c = selectedRowDetails.mailVendor,
                                                                                                Quantity__c = selectedRowDetails.quantity,
                                                                                                Status__c = selectedRowDetails.status,
                                                                                                Transaction_Type__c = selectedRowDetails.transactionType,
                                                                                                Requested_By__c = selectedRowDetails.requestedBy,
                                                                                                RecordTypeId = InventoryTransactionTriggerHelper.INVENTORY_TRACKING_RT_ID_TRANSFER_REQUEST,
                                                                                                Old_Inventory__c = selectedRowDetails.inventory));
                            }
                            else
                            {
                                listOfInventoryToBeInserted.add(new Inventory__c(Name = 'Auto-Populate', 
                                                                                 Job_Ticket_MtM__c = inventorys[0].Job_Ticket_MtM__c, 
                                                                                 Production_Tracking__c = selectedRowDetails.productionTracking,
                                                                                 Assigned_Vendor__c = selectedRowDetails.mailVendor,
                                                                                 Institution__c = inventorys[0].Job_Ticket_MtM__r.Job_Ticket__r.Project__r.Institution__c));
                                if(listOfInventoryToBeInserted.size() > 0)
                                {
                                    insert listOfInventoryToBeInserted;
                                    
                                    listOfInventoryTxnToBeInserted.add(new Inventory_Transaction__c(Inventory__c = listOfInventoryToBeInserted[0].Id,
                                                                                                    Production_Tracking__c = selectedRowDetails.productionTracking,
                                                                                                    Job_Ticket_MtM__c = inventorys[0].Job_Ticket_MtM__c,
                                                                                                    Original_Vendor__c = selectedRowDetails.printVendor,
                                                                                                    Target_Vendor__c = selectedRowDetails.mailVendor,
                                                                                                    Quantity__c = selectedRowDetails.quantity,
                                                                                                    Status__c = selectedRowDetails.status,
                                                                                                    Transaction_Type__c = selectedRowDetails.transactionType,
                                                                                                    Requested_By__c = selectedRowDetails.requestedBy,
                                                                                                    RecordTypeId = InventoryTransactionTriggerHelper.INVENTORY_TRACKING_RT_ID_TRANSFER_REQUEST,
                                                                                                    Old_Inventory__c = selectedRowDetails.inventory
                                                                                                   ));
                                }           
                            }
                        }
                    }                    
                    else if(selectedRowDetails.actionName == 'recycle')
                    { 
                        listOfInventoryToBeUpdated.add(new Inventory__c(Id = selectedRowDetails.inventory, Recycled__c = true));
                        listOfInventoryTxnToBeInserted.add(new Inventory_Transaction__c(Inventory__c = selectedRowDetails.inventory,
                                                                                        Production_Tracking__c = selectedRowDetails.productionTracking,
                                                                                        Job_Ticket_MtM__c = inventorys[0].Job_Ticket_MtM__c,
                                                                                        Original_Vendor__c = selectedRowDetails.printVendor,
                                                                                        Quantity_to_Recycle__c = selectedRowDetails.quantity,
                                                                                        Status__c = selectedRowDetails.status,
                                                                                        Transaction_Type__c = selectedRowDetails.transactionType,
                                                                                        Requested_By__c = selectedRowDetails.requestedBy,
                                                                                        RecordTypeId = InventoryTransactionTriggerHelper.INVENTORY_TRACKING_RT_ID_ADJUSTMENT_REQUEST
                                                                                        ));
                    }
                    
                    if(listOfInventoryToBeUpdated.size() > 0)
                    {
                        Util.byPassAllTriggers = true;
                        update listOfInventoryToBeUpdated;
                        Util.byPassAllTriggers = false;
                    }
                    
                    if(listOfInventoryTxnToBeInserted.size() > 0)
                    {
                        insert listOfInventoryTxnToBeInserted;
                        listOfInventoryTxnToBeInserted = [SELECT Id, Name FROM Inventory_Transaction__c WHERE Id IN : listOfInventoryTxnToBeInserted];
                        res.setBody(listOfInventoryTxnToBeInserted);
                        res.setSuccess(true);
                        return res;
                    }
                    else
                    {
                        res.setMessage('No Inventory Transaction record to be inserted.');
                        res.setSuccess(true);
                        return res;
                    }
                }
                else
                {
                    res.setMessage('"selectedRowDetails" wrapper can not be null.');
                    res.setSuccess(true);
                    return res;
                }
            }
            else
            {
                res.setError('selectedRowDetailJson parameter can not be null.'); 
                return res;
            }
        }
        catch (Exception e) 
        {	
            res.setError(e.getMessage());
            return res;  
        }
    }  
    
    //Job Ticket MtM and Component Wrapper
    public class JobTicketMtMAndComponentWrapper 
    {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String jobTicketMtMName {get;set;}  
        @AuraEnabled public String jobTicketId{get;set;}
        @AuraEnabled public String jobTicketName {get;set;}
        @AuraEnabled public String jobComponentId{get;set;}
        @AuraEnabled public String jobComponentName {get;set;}
        @AuraEnabled public String jobComponentType {get;set;}
        @AuraEnabled public String jobComponentNameForTab {get;set;}
        
        public JobTicketMtMAndComponentWrapper (String id, String jobTicketMtMName, String jobTicketId, String jobTicketName, 
                                                String jobComponentId, String jobComponentName, String jobComponentType, String jobComponentNameForTab) 
        {
            this.id = id;
            this.jobTicketMtMName = jobTicketMtMName;
            this.jobTicketId = jobTicketId;
            this.jobTicketName = jobTicketName;
            this.jobComponentId = jobComponentId;
            this.jobComponentName = jobComponentName;
            this.jobComponentType = jobComponentType;
            this.jobComponentNameForTab = jobComponentNameForTab;
        }
    }
    
    //Prior Inventory Wrapper
    public class PriorInventoryWrapper
    {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String inventoryName {get;set;}
        @AuraEnabled public String inventoryNameUrl {get;set;}
        @AuraEnabled public Decimal quantityInInventory {get;set;}
        @AuraEnabled public String inventoryStatus {get;set;}
        @AuraEnabled public String inventoryAssignedVendorId {get;set;}
        @AuraEnabled public String inventoryAssignedVendorName {get;set;}
        @AuraEnabled public String inventoryProductionTrackingId {get;set;}
        @AuraEnabled public String jobTicketName {get;set;}
        @AuraEnabled public String jobTicketMtMId {get;set;}
        public PriorInventoryWrapper(String id, String inventoryName, String inventoryNameUrl, Decimal quantityInInventory, String inventoryStatus,
                                     String inventoryAssignedVendorId, String inventoryAssignedVendorName, String inventoryProductionTrackingId, String jobTicketName,
                                     String jobTicketMtMId)
        {
            this.id = id;
            this.inventoryName = inventoryName;
            this.inventoryNameUrl = inventoryNameUrl;
            this.quantityInInventory = quantityInInventory;
            this.inventoryStatus = inventoryStatus;
            this.inventoryAssignedVendorId = inventoryAssignedVendorId;
            this.inventoryAssignedVendorName = inventoryAssignedVendorName;
            this.inventoryProductionTrackingId = inventoryProductionTrackingId;
            this.jobTicketName = jobTicketName;
            this.jobTicketMtMId = jobTicketMtMId;
        }
    }
    
    //Inventory and Inventory Transaction Grid Wrapper
    public Class InventoryWrapper
    {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String nameUrl {get;set;}
        @AuraEnabled public Decimal inventoryQuantityInInventory {get;set;}
        @AuraEnabled public String  inventoryAssignedVendorId {get;set;}
        @AuraEnabled public String  inventoryAssignedVendorName {get;set;} //Sepire, Darwill, ColorArt
        @AuraEnabled public String  selectedInventoryPTRecordId {get;set;}
        @AuraEnabled public Boolean childrenExists {get;set;}
        @AuraEnabled public Decimal totalAvailableQuantity {get;set;}
        @AuraEnabled public String inventoryAmountCss {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String inventoryStatusCss {get;set;}
        @AuraEnabled public List<Items> items {get;set;}
        public InventoryWrapper()
        {
			this.totalAvailableQuantity = 0;
			//inventoryAmountCss = 'amountTextBoldCss';          
        }
    }    
    
    public Class Items  
    {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String nameUrl {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public Decimal inventoryQuantityInInventory {get;set;}
        @AuraEnabled public List<Items> items {get;set;}
        @AuraEnabled public String cssClassForAction {get;set;}
        
        public Items() 
        {
        	cssClassForAction = 'hideActionButton';   
        }
    }
    
    public Class JsonToApex
    {
        @AuraEnabled public String inventory {get;set;}
        @AuraEnabled public String printVendor {get;set;}
        @AuraEnabled public String mailVendor {get;set;}
        @AuraEnabled public String productionTracking {get;set;}
        @AuraEnabled public String requestedBy {get;set;}
        @AuraEnabled public String transactionType {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public Decimal quantity {get;set;}
        @AuraEnabled public String actionName {get;set;}
    }
}