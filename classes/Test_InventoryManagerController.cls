/**
*   Purpose         :   Test class for InventoryManagerController
*            
*   Create By       :   Shalu Sharma
* 
*   Created Date    :   10/18/2021
*
*   Revision Log    :   V_1.0 - Created - Shalu Sharma - CR-20210924-15459 - Print Inventory Management 2.0
*   
*   Coverage        :   92%
**/
@IsTest
private class Test_InventoryManagerController 
{
    @testSetup static void setupTestData()
    {
        Util.BypassAllTriggers = true;
        
        //Create Account
        Account inst = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Vendor_Type__c = 'Vendor', 
                                   Vendor_Sub_Type__c = Constants.VENDOR_TYPE_DIGITAL,  Account_Formal_Name__c = 'ColorArt',
                                   Name = 'Test1', r_School_Code__c='abc12', r_CEEB_Code__c='MI00', Status__c = 'Active');
        insert inst;
        System.assert(inst.Id != null);
        
        //Create Project
        Project__c proj = TestUtilities.createProject(false);
        proj.Institution__c = inst.Id;
        insert proj;
        System.assert(proj.id != null);
        
        //Create Job Ticket
        Job_Ticket__c jobTicket = PrintManagementTestDataFactory.CreateNewJobTicket(false);
        jobTicket.Name = 'NO-1555-2021-ESFUL';
        jobTicket.Fiscal_Year__c = '2021';
        jobTicket.Drop_Type__c = 'Pre Planned';
        jobTicket.Project__c = proj.Id;
        insert jobTicket;
        System.assert(jobTicket.Id != null);
        
        //Create Job Ticket Component
        Job_Ticket_Component__c jobTicketComponent = PrintManagementTestDataFactory.CreateNewJobTicketComponent(false);
        jobTicketComponent.Component__c = 'Envelope';
        insert jobTicketComponent;
        System.assert(jobTicketComponent.Id != null);
        
        //Create Job Ticket MtM
        Job_Ticket_MtM__c jobTickectMTM = new Job_Ticket_MtM__c();
        jobTickectMTM.Job_Ticket__c = jobTicket.Id;
        jobTickectMTM.Job_Ticket_Component__c = jobTicketComponent.Id;
        jobTickectMTM.Component_Type__c = Constants.COMPONENT_TYPE_BRE;
        jobTickectMTM.Component_Code__c = 'A1';
        insert jobTickectMTM;
        System.assert(jobTickectMTM.Id != null);
        
        //Create Production Tracking
        Id RECORD_TYPE_ID_PRODUCTION_TRACKING_PRINT = Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByDeveloperName().get('Print').getRecordTypeId();
        List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
        pTrackings.add(new Production_Tracking__c(Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,
                                                  Job_Ticket__c = jobTicket.Id, Job_Ticket_MtM__c = jobTickectMTM.Id, RecordTypeId = RECORD_TYPE_ID_PRODUCTION_TRACKING_PRINT, 
                                                  Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, 
                                                  Internal_Data_Drop__c = 1, Art_File_Name__c = 'Art.zip'));
        insert pTrackings;
        System.assert(pTrackings[0].Id != null);
        
        //Create Inventory
        Inventory__c inventory = new Inventory__c(Assigned_Vendor__c = inst.Id ,Job_Ticket_MtM__c = jobTickectMTM.Id, Available_for_Future_Use__c = true,
                                                  Inventory_Control_Number__c = 'MI00', Production_Tracking__c = pTrackings[0].Id);
        insert inventory;
        System.assert(inventory.Id != null);
        
        //Create Inventory Transaction
        List<Inventory_Transaction__c> inventoryTransactions = new List<Inventory_Transaction__c>();
        Inventory_Transaction__c invTxn = new Inventory_Transaction__c(Inventory__c = inventory.Id, Quantity_Printed__c	=10,
                                                                       Production_Tracking__c = pTrackings[0].Id, Effective_Quantity__c = 10000,  
                                                                       Quantity__c = 5000, Ship_Date__c = System.today(), Arrival_Date_Anticipated__c = System.today(),
                                                                       Shipping_Method__c = 'UPS', Tracking_Number__c = '1Z8999999999999998');
        inventoryTransactions.add(invTxn);
        insert inventoryTransactions;
        System.assert(inventoryTransactions[0].Id != null);
        
        Util.BypassAllTriggers = false;
    }
    
    static testMethod void test_getExistingJobTicketMtMAndComponents()
    {
        Util.BypassAllTriggers = true;
        
        //Query Job Ticket record.
        List<Job_Ticket__c> jt = [Select Id, Name From Job_Ticket__c];
        System.assertEquals(1, jt.size());
        
        //Query Job Ticket MtM record
        List<Job_Ticket_MtM__c> jtMtM = [Select Id, Name, Job_Ticket__c, Job_Ticket__r.Name, Job_Ticket_Component__c, 
                                         Job_Ticket_Component__r.Name, Job_Ticket_Component__r.Component__c From Job_Ticket_MtM__c];
        System.assertEquals(1, jtMtM.size());
        
        Util.BypassAllTriggers = false;
        
        Test.startTest();
        
        //Call getExistingJobTicketMtMAndComponents method. - SUCCESS
        LightningResponseEntity response = InventoryManagerController.getExistingJobTicketMtMAndComponents(jt[0].Id);
        System.assert(response != null);
        System.assertEquals('success', response.status);
        System.assertEquals(true, response.isSuccess);
        
        List<InventoryManagerController.JobTicketMtMAndComponentWrapper> wr = (List<InventoryManagerController.JobTicketMtMAndComponentWrapper>)response.body;
        System.assert(wr != null);
        System.assertEquals(jtMtM[0].Id, wr[0].Id);
        System.assertEquals(jtMtM[0].Name, wr[0].jobTicketMtMName);
        System.assertEquals(jtMtM[0].Job_Ticket__c, wr[0].jobTicketId);
        System.assertEquals(jtMtM[0].Job_Ticket__r.Name, wr[0].jobTicketName);
        System.assertEquals(jtMtM[0].Job_Ticket_Component__c, wr[0].jobComponentId);
        System.assertEquals(jtMtM[0].Job_Ticket_Component__r.Name, wr[0].jobComponentName);
        System.assertEquals(jtMtM[0].Job_Ticket_Component__r.Component__c, wr[0].jobComponentType);
        System.assertEquals(jtMtM[0].Job_Ticket_Component__r.Name, wr[0].jobComponentNameForTab);
	        
        //Call getExistingJobTicketMtMAndComponents method. - When no Job Ticket Component exists.
        List<Job_Ticket_Component__c> jtc = [Select Id From Job_Ticket_Component__c];
        System.assertEquals(1, jtc.size());
        
        //Delete Job Ticket Component
        delete jtc;
        
        response = InventoryManagerController.getExistingJobTicketMtMAndComponents(jt[0].Id);
        System.assert(response != null);
        System.assertEquals('success', response.status);
        System.assertEquals(true, response.isSuccess);
        
        wr = (List<InventoryManagerController.JobTicketMtMAndComponentWrapper>)response.body;
        System.assert(wr == null);
        
        //When Job Ticket Id id blank
        response = InventoryManagerController.getExistingJobTicketMtMAndComponents('');
        System.assert(response != null);
        System.assertEquals('error', response.status);
        System.assertEquals(false, response.isSuccess);
        System.assertEquals(Label.Insufficient_Access_To_RecordId, response.message);
        
        Test.stopTest();
    }
    
    static testMethod void test_getPriorInventory()
    {
        Util.BypassAllTriggers = true;
        
        //Query Job Ticket MtM
        List<Job_Ticket_MtM__c> jtMtM = [Select Id, Name, Job_Ticket__c, Job_Ticket__r.Name, Job_Ticket_Component__c, Component_Code_Formula__c,
                                         Job_Ticket_Component__r.Name, Job_Ticket_Component__r.Component__c From Job_Ticket_MtM__c];
        System.assertEquals(1, jtMtM.size());
        
        List<Inventory__c> inventory =  [SELECT Id, Name, Quantity_in_Inventory__c, Job_Ticket_MtM__r.Job_Ticket__r.Name,
                                                   Assigned_Vendor__c, Assigned_Vendor__r.Name, Production_Tracking__c, Job_Ticket_MtM__r.Job_Ticket__c,
                                                   Job_Ticket_MtM__c, Available_for_Future_Use__c, Inventory_Control_Number__c
                                                   FROM Inventory__c];
        Util.BypassAllTriggers = false;
        
        Test.startTest();
        
        //Call getPriorInventory method. - SUCCESS
        LightningResponseEntity response = InventoryManagerController.getPriorInventory(jtMtM[0].Id);
        System.assert(response != null);
        System.assertEquals('success', response.status);
        System.assertEquals(true, response.isSuccess);
        
        List<InventoryManagerController.PriorInventoryWrapper> wr = (List<InventoryManagerController.PriorInventoryWrapper>)response.body;
        System.assert(wr != null);
        InventoryManagerController.PriorInventoryWrapper PriorInventoryWrapper = wr[0];
        System.assertEquals(inventory[0].Id, PriorInventoryWrapper.Id);
        System.assertEquals(inventory[0].Name, PriorInventoryWrapper.inventoryName);
        System.assert(PriorInventoryWrapper.inventoryNameUrl != null);
        System.assertEquals(inventory[0].Quantity_in_Inventory__c, PriorInventoryWrapper.quantityInInventory);
        System.assertEquals('Available', PriorInventoryWrapper.inventoryStatus);
        System.assertEquals(inventory[0].Assigned_Vendor__c, PriorInventoryWrapper.inventoryAssignedVendorId);
        System.assertEquals(inventory[0].Assigned_Vendor__r.Name, PriorInventoryWrapper.inventoryAssignedVendorName);
        System.assertEquals(inventory[0].Production_Tracking__c, PriorInventoryWrapper.inventoryProductionTrackingId);
        System.assertEquals(inventory[0].Job_Ticket_MtM__r.Job_Ticket__r.Name, PriorInventoryWrapper.jobTicketName);
        System.assertEquals(inventory[0].Job_Ticket_MtM__c, PriorInventoryWrapper.jobTicketMtMId);
        
        //Call getPriorInventory method. - No inventory found;
        delete inventory;
        
        response = InventoryManagerController.getPriorInventory(jtMtM[0].Id);
        System.assert(response != null);
        System.assertEquals('success', response.status);
        System.assertEquals(true, response.isSuccess);
        System.assertEquals(System.Label.No_Prior_Inventory_Record_To_Display_Msg, response.message);
        
        //Call getPriorInventory method. - When not jobTicketMTM record exist
        Id jtMTMID= jtMtM[0].Id;
        delete jtMtM;
        response = InventoryManagerController.getPriorInventory(jtMTMID);
        System.assert(response != null);
        System.assertEquals('success', response.status);
        System.assertEquals(true, response.isSuccess);
        System.assertEquals(System.Label.No_Prior_Inventory_Record_Exist_With_Component_Code_Msg, response.message);
            
        //Send bank as parameter.
        response = InventoryManagerController.getPriorInventory('');
        System.assert(response != null);
        System.assertEquals('error', response.status);
        System.assertEquals(false, response.isSuccess);
        System.assertEquals(Label.Insufficient_Access_To_RecordId, response.message);
        
        Test.stopTest();
    }
    
    static testMethod void test_updateInventoryRecord()
    {
        Util.BypassAllTriggers = true;
        
        //Query Inventory record.
        List<Inventory__c> inventory =  [SELECT Id, Name FROM Inventory__c ];
        System.assert(inventory[0].Id != null);
        
        Util.BypassAllTriggers = false;
        
        Test.startTest();
        
        //Call updateInventoryRecord method. - SUCCESS
        LightningResponseEntity response = InventoryManagerController.updateInventoryRecord(inventory[0].Id);
        System.assert(response != null);
        System.assertEquals('success', response.status);
        System.assertEquals(true, response.isSuccess);
        
        inventory = [Select Id, Available_for_Future_Use__c From Inventory__c Where Id = :inventory[0].Id];
        System.assertEquals(false, inventory[0].Available_for_Future_Use__c);
        
        //Call updateInventoryRecord method. - No inventory found;
        Id inventoryId = inventory[0].Id;
        delete inventory;
        
        response = InventoryManagerController.updateInventoryRecord(inventoryId);
        System.assert(response != null);
        System.assertEquals('success', response.status);
        System.assertEquals(true, response.isSuccess);
        System.assertEquals(System.Label.No_Prior_Inventory_Record_To_Be_Updated_Msg, response.message);
        
        //Send blank as parameter.
        response = InventoryManagerController.updateInventoryRecord('');
        System.assert(response != null);
        System.assertEquals('error', response.status);
        System.assertEquals(false, response.isSuccess);
        System.assertEquals(Label.Insufficient_Access_To_RecordId, response.message);
        
        Test.stopTest();
    }
    
    static testMethod void test_getTreeGridData()
    {
        Util.BypassAllTriggers = true;
        
        //Query Job Ticket record.
        List<Job_Ticket__c> jt = [Select Id, Name From Job_Ticket__c];
        System.assertEquals(1, jt.size());
        
        Util.BypassAllTriggers = false;
        
        Test.startTest();
        
        //Call getTreeGridData method. - SUCCESS
        List<Inventory__c> inventory =  [SELECT Id, Name, Quantity_in_Inventory__c, Assigned_Vendor__c, Assigned_Vendor__r.Account_Formal_Name__c, 
                                         Production_Tracking__c, Current_Available_Amount__c, Job_Ticket_MtM__c 
                                         FROM Inventory__c];

        LightningResponseEntity response = InventoryManagerController.getTreeGridData(inventory[0].Job_Ticket_MtM__c);
        System.assert(response != null);
        System.assertEquals('success', response.status);
        System.assertEquals(true, response.isSuccess);
        System.assert(response.body != null);
        
        //When Job Ticket Id is blank
        response = InventoryManagerController.getTreeGridData('');
        System.assert(response != null);
        System.assertEquals('error', response.status);
        System.assertEquals(false, response.isSuccess);
        System.assertEquals(Label.Insufficient_Access_To_RecordId, response.message);
        
        Test.stopTest();
    }
    
    static testMethod void test_createInventoryAndTxnRecord()
    {
        //Query Job Ticket MtM
        List<Job_Ticket_MtM__c> jtMtM = [Select Id, Name, Job_Ticket__c, Job_Ticket__r.Name, Job_Ticket_Component__c, Component_Code_Formula__c,
                                         Job_Ticket_Component__r.Name, Job_Ticket_Component__r.Component__c, Job_Ticket__r.Project__r.Institution__c
                                         From Job_Ticket_MtM__c];
        System.assertEquals(1, jtMtM.size());
        
        List<Inventory__c> inventory =  [SELECT Id, Name, Quantity_in_Inventory__c, Job_Ticket_MtM__r.Job_Ticket__r.Name,
                                         Assigned_Vendor__c, Assigned_Vendor__r.Name, Production_Tracking__c, Job_Ticket_MtM__r.Job_Ticket__c,
                                         Job_Ticket_MtM__c, Available_for_Future_Use__c, Inventory_Control_Number__c
                                         FROM Inventory__c];
        Id productionTrackingId = inventory[0].Production_Tracking__c;
        
        InventoryManagerController.PriorInventoryWrapper wr = new InventoryManagerController.PriorInventoryWrapper(
        null, inventory[0].Name, null, inventory[0].Quantity_in_Inventory__c, 'Available', null, null,
        inventory[0].Production_Tracking__c, inventory[0].Job_Ticket_MtM__r.Job_Ticket__r.Name, jtMtM[0].id);
        
        String priorInventoryAsString = JSON.serialize(wr);
        delete inventory;
        
        Test.startTest();
        
        LightningResponseEntity response = InventoryManagerController.createInventoryAndTxnRecord(priorInventoryAsString);
        System.assert(response != null);
        System.assertEquals('success', response.status);
        System.assertEquals(true, response.isSuccess);
        
        //Query Inventory record.
        inventory = [Select Id, Name, Job_Ticket_MtM__c, Production_Tracking__c, Institution__c From Inventory__c];
        System.assertEquals(1, inventory.size());
        System.assertEquals(jtMtM[0].Id, inventory[0].Job_Ticket_MtM__c);
        System.assertEquals(jtMtM[0].Job_Ticket__r.Project__r.Institution__c, inventory[0].Institution__c);
        System.assertEquals(productionTrackingId,  inventory[0].Production_Tracking__c);
        
        //Query created Inventory Transaction
        List<Inventory_Transaction__c> it = [Select Id, Name From Inventory_Transaction__c Where Inventory__c=: inventory[0].Id AND Transaction_Type__c = 'Prior Inventory Request (from EAB)'];
        System.assertEquals(1, it.size());
        
        response = InventoryManagerController.createInventoryAndTxnRecord('');
        System.assert(response != null);
        System.assertEquals('error', response.status);
        System.assertEquals(false, response.isSuccess);
        System.assertEquals('inventoryDetailJson can not be null', response.message);
        
        wr = null;
        priorInventoryAsString = JSON.serialize(wr);
        response = InventoryManagerController.createInventoryAndTxnRecord(priorInventoryAsString);
        System.assert(response != null);
        System.assertEquals('success', response.status);
        System.assertEquals(true, response.isSuccess);
        System.assertEquals('inventoryDetail wrapper can not be null', response.message);
        
        Test.stopTest();
    }
    
    static testMethod void test_createInventoryTransactionRecord()
    {
        Util.BypassAllTriggers = true;
        
        //Query Account record.
        Account acc = [ SELECT Id, Name FROM Account LIMIT 1];
        
        //Query Inventory record.
        List<Inventory__c> inventory =  [SELECT Id, Name, Quantity_in_Inventory__c, Job_Ticket_MtM__r.Job_Ticket__r.Name,
                                                   Assigned_Vendor__c, Assigned_Vendor__r.Name, Production_Tracking__c, Job_Ticket_MtM__r.Job_Ticket__c,
                                                   Job_Ticket_MtM__c, Available_for_Future_Use__c, Inventory_Control_Number__c
                                                   FROM Inventory__c ];
        
        //Query Inventory Transaction record.
        List<Inventory_Transaction__c> inventoryTransactions = [Select Id From Inventory_Transaction__c];
        delete inventoryTransactions;
        
        List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
        Id RECORD_TYPE_ID_PRODUCTION_TRACKING_PRINT = Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByDeveloperName().get('Print').getRecordTypeId();
        pTrackings.add(new Production_Tracking__c(Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,
                                                  RecordTypeId = RECORD_TYPE_ID_PRODUCTION_TRACKING_PRINT, 
                                                  Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, 
                                                  Internal_Data_Drop__c = 1, Art_File_Name__c = 'Art.zip'));
        insert pTrackings;
        
        Util.BypassAllTriggers = false;
        
        Test.startTest();
        
        String thisRowDetails = '{'+
                                    '"inventory": "'+inventory[0].Id+'",'+
                                    '"printVendor": null,'+
                                    '"mailVendor": " ",'+
                                    '"productionTracking":"'+inventory[0].Production_Tracking__c+'",'+
                                    '"requestedBy":"'+UserInfo.getUserId()+'",'+
                                    '"transactionType":"Print Confirmation",'+
                                    '"status": "Requested",'+
                                    '"quantity":10,'+
                                    '"actionName":"add_new"'+
                                '}';
        
        LightningResponseEntity response = InventoryManagerController.createInventoryTransactionRecord(thisRowDetails);
        System.assert(response != null);
        System.assertEquals('success', response.status);
        System.assertEquals(true, response.isSuccess);
        
        inventoryTransactions = [Select Id, Name From Inventory_Transaction__c Where Inventory__c=:inventory[0].Id ];
        System.assertEquals(1, inventoryTransactions.size());
        System.assert(inventoryTransactions[0].Id != null);
        
        thisRowDetails = '{'+
                            '"inventory": "'+inventory[0].Id+'",'+
                            '"printVendor": null,'+
                            '"mailVendor":  "'+ acc.Id +'",'+
                            '"productionTracking":"'+pTrackings[0].Id+'",'+
                            '"requestedBy":"'+UserInfo.getUserId()+'",'+
                            '"transactionType":"Print Confirmation",'+
                            '"status": "Requested",'+
                            '"quantity":10,'+
                            '"actionName":"transfer"'+
                            '}';
        response = InventoryManagerController.createInventoryTransactionRecord(thisRowDetails);
        System.assert(response != null);
        
        thisRowDetails = '{'+
                            '"inventory": "'+inventory[0].Id+'",'+
                            '"printVendor": null,'+
                            '"mailVendor":  "'+ acc.Id +'",'+
                            '"productionTracking":"'+inventory[0].Production_Tracking__c+'",'+
                            '"requestedBy":"'+UserInfo.getUserId()+'",'+
                            '"transactionType":"Print Confirmation",'+
                            '"status": "Requested",'+
                            '"quantity":10,'+
                            '"actionName":"transfer"'+
                            '}';
        response = InventoryManagerController.createInventoryTransactionRecord(thisRowDetails);
        System.assert(response != null);
        
        inventoryTransactions = [Select Id, Name From Inventory_Transaction__c Where Inventory__c=:inventory[0].Id ];
        
        thisRowDetails = '{'+
                            '"inventory": "'+inventory[0].Id+'",'+
                            '"printVendor": null,'+
                            '"mailVendor":  null,'+
                            '"productionTracking":"'+inventory[0].Production_Tracking__c+'",'+
                            '"requestedBy":"'+UserInfo.getUserId()+'",'+
                            '"transactionType":"Print Confirmation",'+
                            '"status": "Requested",'+
                            '"quantity":10,'+
                            '"actionName":"recycle"'+
                            '}';
        response = InventoryManagerController.createInventoryTransactionRecord(thisRowDetails);
        System.assert(response != null);
        System.assertEquals('success', response.status);
        System.assertEquals(true, response.isSuccess);
        
        inventoryTransactions = [Select Id, Name, Inventory__r.Recycled__c From Inventory_Transaction__c Where Inventory__c=:inventory[0].Id AND  Quantity_to_Recycle__c != NULL];
        System.assertEquals(1, inventoryTransactions.size());
        System.assert(inventoryTransactions[0].Id != null);
        System.assertEquals(true, inventoryTransactions[0].Inventory__r.Recycled__c);
       
        thisRowDetails = '{'+
                            '"inventory": "'+inventory[0].Id+'",'+
                            '"printVendor": null,'+
                            '"mailVendor":  null,'+
                            '"productionTracking":"'+inventory[0].Production_Tracking__c+'",'+
                            '"requestedBy":"'+UserInfo.getUserId()+'",'+
                            '"transactionType":"Print Confirmation",'+
                            '"status": "Requested",'+
                            '"quantity":10,'+
                            '"actionName":"test"'+
                            '}';

        response = InventoryManagerController.createInventoryTransactionRecord(thisRowDetails);
        System.assert(response != null);
        System.assertEquals('success', response.status);
        System.assertEquals(true, response.isSuccess);
        System.assert(response.message.contains('No Inventory Transaction record to be inserted.'));
        
        //Set blank as a parameter
        response = InventoryManagerController.createInventoryTransactionRecord('');
        System.assert(response != null);
        System.assertEquals('error', response.status);
        System.assertEquals(false, response.isSuccess);
        System.assertEquals('selectedRowDetailJson parameter can not be null.', response.message);
        
        //Set null    
        InventoryManagerController.JsonToApex wr = null;
        String data = JSON.serialize(wr);
        response = InventoryManagerController.createInventoryTransactionRecord(data);
        System.assert(response != null);
        System.assertEquals('success', response.status);
        System.assertEquals(true, response.isSuccess);
        System.assert(response.message.contains('"selectedRowDetails" wrapper can not be null.'));
        
        Test.stopTest();
    }
}