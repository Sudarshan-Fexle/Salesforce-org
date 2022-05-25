/**
*   Purpose         :   Test class for InventoryTransactionTriggerHelper
*            
*   Create By       :   Abhinav Sharma
* 
*   Created Date    :   05/13/2021
*
*   Revision Log    :   V_1.0 - Created - Abhinav Sharma
*                   
*   Coverage        :   100%
*		    :   V_1.1 - Modified by - Abhinav Sharma - 06/14/2021 - CR-20210525-15180 - Print Inventory Field additions (Make "Production Tracking" as master-detail on Inventory)
*		    :	V_1.2 - Modified By Abhinav Sharma - 06/17/2021 - CR-20210525-15180 - Add new "test_populateLocationOnInventory" to increase the coverage of "populateLocationOnInventory"
*           	    :   V_1.3 - Modified By Shalu Sharma - 10/20/2021 -  CR-20210924-15459  - Add new "test_checkAddNewInventoryRequest" to increase the coverage of "checkAddNewInventoryRequest"
**/
@isTest(seeAllData = false)
public class Test_InventoryTransactionTriggerHelper  
{
    @testSetup static void dataSetup()
    {
        Util.BypassAllTriggers = true;
        //Create Account
        Account inst = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Vendor_Type__c = 'Vendor', 
                                   Vendor_Sub_Type__c = Constants.VENDOR_TYPE_DIGITAL, 
                                   Name = 'Test1', r_School_Code__c='abc12', r_CEEB_Code__c='AE');
        insert inst;
        
        //Create Account
        Account inst1 = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Status__c = 'Active',
                                   Name = 'Test Account 2', r_School_Code__c='abc11', r_CEEB_Code__c='AB');
        insert inst1;
        
        //Create Project
        Project__c proj = TestUtilities.createProject(false);
        proj.Institution__c = inst.Id;
        insert proj;
        
        //Create a user for running the process
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User user1 = testUtilities.CreateNewUser(sysAdminProfile, false);
        user1.LastName = 'sysAdminUser';
        insert user1;
        
        //Creating Job Ticket record 
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Name = 'GW-5242-2021-ESNN-2', Project__c = proj.Id, Status__c = 'Draft', Project_Manager__c = user1.Id, 
                                         Descriptive_Name__c = 'Test Desciptive', Art_Director__c = user1.Id, Mail_Quantity__c = 100,
                                         Change_Reason__c = 'Testing before update', Project_ID__c = 'Test', Fiscal_Year__c='2020', Drop_Type__c = 'Pre Planned'));
        insert jobTickets;
        
        Job_Ticket_Component__c jobTctComponet = PrintManagementTestDataFactory.CreateNewJobTicketComponent(false);
        jobTctComponet.Component__c = 'BRE';
        insert jobTctComponet;
        
        Job_Ticket_MtM__c jobTickectMTMs = PrintManagementTestDataFactory.CreateNewJobTicketMTM(false);
        jobTickectMTMs.Job_Ticket_Component__c = jobTctComponet.Id;
        jobTickectMTMs.Job_Ticket__c = jobTickets[0].Id;
        jobTickectMTMs.Component_Code__c = 'AE0012';
        insert jobTickectMTMs;
        
        Id RECORD_TYPE_ID_PRODUCTION_TRACKING_PRINT = Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByDeveloperName().get('Print').getRecordTypeId();
        
        List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,
                                                  Job_Ticket__c = jobTickets[0].Id, Job_Ticket_MtM__c = jobTickectMTMs.Id, RecordTypeId = RECORD_TYPE_ID_PRODUCTION_TRACKING_PRINT, 
                                                  Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, 
                                                  Internal_Data_Drop__c = 1, Art_File_Name__c = 'Art.zip'));
        insert pTrackings;
        
        //Modify by - Abhinav Sharma - 06/14/2021 - CR-20210525-15180 - Print Inventory Field additions (Make "Production Tracking" as master-detail on Inventory)
        Inventory__c inventory = new Inventory__c(Institution__c = inst.Id ,Job_Ticket_MtM__c = jobTickectMTMs.Id, 
                                                  Inventory_Control_Number__c = 'AE0012', Production_Tracking__c = pTrackings[0].Id);
        insert inventory;
        
        List<Inventory_Transaction__c> inventoryTransactions = new List<Inventory_Transaction__c>();
        Inventory_Transaction__c invTxn = new Inventory_Transaction__c(Inventory__c = inventory.Id, Original_Vendor__c = inst1.Id, Target_Vendor__c = inst1.Id,
                                                                       Production_Tracking__c = pTrackings[0].Id, Effective_Quantity__c = 10000, 
                                                                       Quantity__c = 5000, Ship_Date__c = System.today(), Arrival_Date_Anticipated__c = System.today(),
                                                                       Status__c = '--None--', Shipping_Method__c = 'UPS', Tracking_Number__c = '1Z8999999999999998');
        inventoryTransactions.add(invTxn);
        insert inventoryTransactions;
        
        Util.BypassAllTriggers = false;
        
    }
    
    static testMethod void test_checkInventoryTransferRequest()
    {
        List<Inventory_Transaction__c> inventoryTransactions = [SELECT Id, Name, Target_Vendor__c FROM Inventory_Transaction__c];
        System.assert(inventoryTransactions.size() > 0);
        Test.startTest();
        
        try{
            inventoryTransactions[0].Status__c = InventoryTransactionTriggerHelper.INVENTORY_TRANSACTION_STATUS_REQUESTED;
            update inventoryTransactions;
        } Catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('No API Endpoint where Related Record Id') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);	  
            
            //check web service logs
            Web_Service_Log__c webServiceLog = [Select Id,Web_Service_Method__c,Inventory_Transaction__c From Web_Service_Log__c];
            
            //asserts on result
            System.assertNotEquals(null, webServiceLog);
            System.assertEquals('inventoryTransferRequest', webServiceLog.Web_Service_Method__c);
        }
        
        Test.stopTest();
        
        inventoryTransactions[0].Status__c = JobTicketService.INVENTORY_TRANSACTION_STATUS_TRANSFER_IN_PROGRESS;
        update inventoryTransactions;
    }
    
    static testMethod void test_populateLocationOnInventory()
    {
        List<Account> accounts = [SELECT Id FROM Account WHERE Name = 'Test Account 2'];
        System.assert(accounts.size() > 0);
        
        List<Production_Tracking__c> pTrackings = [SELECT Id FROM Production_Tracking__c];
        System.assert(pTrackings.size() > 0);
        
        List<Inventory__c> inventorys = [SELECT Id FROM Inventory__c];
        System.assert(inventorys.size() > 0);
        
        Test.startTest();
        
        List<Inventory_Transaction__c> inventoryTransactions = new List<Inventory_Transaction__c>();
        inventoryTransactions.add(new Inventory_Transaction__c(Inventory__c = inventorys[0].Id, Original_Vendor__c = accounts[0].Id, Target_Vendor__c = accounts[0].Id,
                                                               Production_Tracking__c = pTrackings[0].Id, Effective_Quantity__c = 10000, 
                                                               Quantity__c = 5000, Ship_Date__c = System.today(), Arrival_Date_Anticipated__c = System.today(),
                                                               Status__c = '--None--', Shipping_Method__c = 'UPS', Tracking_Number__c = '1Z8999999999999998'));
        inventoryTransactions.add(new Inventory_Transaction__c(Inventory__c = inventorys[0].Id, Original_Vendor__c = accounts[0].Id, Target_Vendor__c = accounts[0].Id,
                                                               Production_Tracking__c = pTrackings[0].Id, Effective_Quantity__c = 10000, 
                                                               Quantity__c = 5000, Ship_Date__c = System.today(), Arrival_Date_Anticipated__c = System.today(),
                                                               Status__c = '--None--', Shipping_Method__c = 'UPS', Tracking_Number__c = '1Z8999999999999998'));
        insert inventoryTransactions;
        List<Inventory__c> listOfInventorys = [SELECT Id, Location__c FROM Inventory__c WHERE Id =: inventorys[0].Id];
        System.assertEquals('Same', listOfInventorys[0].Location__c);
        
        //Delete all the Inventory Transactions
        List<Inventory_Transaction__c> listOfInventoryTransactions = [SELECT Id FROM Inventory_Transaction__c WHERE Inventory__c =: inventorys[0].Id];
        Delete listOfInventoryTransactions;
        
        List<Inventory__c> listOfInventorysAfterDelete = [SELECT Id, Location__c FROM Inventory__c WHERE Id =: inventorys[0].Id];        
        System.assertEquals(null, listOfInventorysAfterDelete[0].Location__c);
        
        Test.stopTest();
    }
    
    //Added By Shalu Sharma - 10/20/2021 -  CR-20210924-15459
    static testMethod void test_checkAddNewInventoryRequest()
    {
        List<Account> accounts = [SELECT Id FROM Account WHERE Name = 'Test Account 2'];
        accounts[0].Account_Formal_Name__c = 'ColorArt';
        Util.BypassAllTriggers = true;
        update accounts;
        Util.BypassAllTriggers = false;
        System.assert(accounts.size() > 0);
        
        List<Production_Tracking__c> pTrackings = [SELECT Id FROM Production_Tracking__c];
        System.assert(pTrackings.size() > 0);
        
        List<Inventory__c> inventorys = [SELECT Id FROM Inventory__c];
        System.assert(inventorys.size() > 0);
        
        Test.startTest();
        
        List<Inventory_Transaction__c> inventoryTransactions = new List<Inventory_Transaction__c>();
        inventoryTransactions.add(new Inventory_Transaction__c(Inventory__c = inventorys[0].Id, Original_Vendor__c = accounts[0].Id, Target_Vendor__c = accounts[0].Id,
                                                               Production_Tracking__c = pTrackings[0].Id, Effective_Quantity__c = 10000, 
                                                               Quantity__c = 5000, Ship_Date__c = System.today(), Arrival_Date_Anticipated__c = System.today(),
                                                               Status__c = 'Requested', Shipping_Method__c = 'UPS', Tracking_Number__c = '1Z8999999999999998'));
        inventoryTransactions.add(new Inventory_Transaction__c(Inventory__c = inventorys[0].Id, Original_Vendor__c = accounts[0].Id, Target_Vendor__c = accounts[0].Id,
                                                               Production_Tracking__c = pTrackings[0].Id, Effective_Quantity__c = 10000, 
                                                               Quantity__c = 5000, Ship_Date__c = System.today(), Arrival_Date_Anticipated__c = System.today(),
                                                               Status__c = 'Requested', Shipping_Method__c = 'UPS', Tracking_Number__c = '1Z8999999999999998'));
        insert inventoryTransactions;
        
        Test.stopTest();
        
        //check web service logs
        List<Web_Service_Log__c> webServiceLog = [Select Id, Web_Service_Method__c,Inventory_Transaction__c From Web_Service_Log__c];
        //System.assertEquals('AddNewInventory', webServiceLog[0].Web_Service_Method__c);
    }
    
    //Added By Shalu Sharma - 10/20/2021 -  CR-20210924-15459
    static testMethod void test_rollupAvailableAmountOnInventory()
    {
        Util.BypassAllTriggers = true;
        
        List<Account> accounts = [SELECT Id FROM Account WHERE Name = 'Test Account 2'];
        accounts[0].Account_Formal_Name__c = 'ColorArt';
        Util.BypassAllTriggers = true;
        update accounts;
        Util.BypassAllTriggers = false;
        System.assert(accounts.size() > 0);
        
        //Create Account
        Account inst1 = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Status__c = 'Active',
                                    Name = 'Sepire', r_School_Code__c='RFE12', r_CEEB_Code__c = 'DR',
                                    Account_Formal_Name__c = 'Sepire');
        insert inst1;
        
        List<Inventory__c> listOfInventory = [SELECT Id FROM Inventory__c];
        System.assert(listOfInventory.size() > 0);
        
        List<Production_Tracking__c> listOfPTs = [SELECT Id FROM Production_Tracking__c];
        System.assert(listOfPTs.size() > 0);
        
        List<Inventory_Transaction__c> inventoryTransactions = new List<Inventory_Transaction__c>(); 
        inventoryTransactions.add(new Inventory_Transaction__c(Inventory__c = listOfInventory[0].Id, Original_Vendor__c = inst1.Id, 
                                                               Target_Vendor__c = accounts[0].Id, Production_Tracking__c = listOfPTs[0].Id,
                                                               Quantity__c = -1000,Status__c = 'Transfer Requested'));
        Util.BypassAllTriggers = false;
        
        Test.startTest();
        //Insert Use Case
        insert inventoryTransactions;
        
        List<Inventory__c> listOfInventorys = [SELECT Id, Current_Available_Amount__c FROM Inventory__c WHERE Id =: listOfInventory[0].Id];
        System.assertEquals(-1000, listOfInventorys[0].Current_Available_Amount__c);
        
        //Update Use Case
        List<Inventory_Transaction__c> listOfInventoryTxns = [SELECT Id, Status__c, Quantity__c FROM Inventory_Transaction__c 
                                                              WHERE Status__c = '--None--'];
        listOfInventoryTxns[0].Status__c = 'Transfer Requested';
        listOfInventoryTxns[0].Quantity__c = -5000;
        update listOfInventoryTxns;
        
        List<Inventory__c> listOfInventoryAfterUpdate = [SELECT Id, Current_Available_Amount__c 
                                                         FROM Inventory__c WHERE Id =: listOfInventory[0].Id];
        System.assertEquals(-6000, listOfInventoryAfterUpdate[0].Current_Available_Amount__c);
       
        //Delete Use Case
        List<Inventory_Transaction__c> listOfInventoryTrans = [SELECT Id, Status__c, Quantity__c FROM Inventory_Transaction__c 
                                                               WHERE Quantity__c = -5000];
        delete listOfInventoryTrans;
        List<Inventory__c> listOfInventoryAfterDelete = [SELECT Id, Current_Available_Amount__c 
                                                         FROM Inventory__c WHERE Id =: listOfInventory[0].Id];
        System.assertEquals(-1000, listOfInventoryAfterDelete[0].Current_Available_Amount__c);
        
        Test.stopTest();
    }
    
    //Added By Shalu Sharma - 10/20/2021 -  CR-20210924-15459
    static testMethod void test_getExceptionInvTx()
    {
        List<Account> accounts = [SELECT Id FROM Account WHERE Name = 'Test Account 2'];
        accounts[0].Account_Formal_Name__c = 'ColorArt';
        Util.BypassAllTriggers = true;
        update accounts;
        Util.BypassAllTriggers = false;
        System.assert(accounts.size() > 0);
        
        List<Production_Tracking__c> pTrackings = [SELECT Id FROM Production_Tracking__c];
        System.assert(pTrackings.size() > 0);
        
        List<Inventory__c> inventorys = [SELECT Id FROM Inventory__c];
        System.assert(inventorys.size() > 0);
        
        Test.startTest();
        try{
            List<Inventory_Transaction__c> inventoryTransactions = new List<Inventory_Transaction__c>();
            inventoryTransactions.add(new Inventory_Transaction__c(Original_Vendor__c = accounts[0].Id, Target_Vendor__c = accounts[0].Id,
                                                                   Production_Tracking__c = pTrackings[0].Id, Effective_Quantity__c = 10000, 
                                                                   Quantity__c = 5000, Ship_Date__c = System.today(), Arrival_Date_Anticipated__c = System.today(),
                                                                   Status__c = 'Requested', Shipping_Method__c = 'UPS', Tracking_Number__c = '1Z8999999999999998'));
            inventoryTransactions.add(new Inventory_Transaction__c(Original_Vendor__c = accounts[0].Id, Target_Vendor__c = accounts[0].Id,
                                                                   Production_Tracking__c = pTrackings[0].Id, Effective_Quantity__c = 10000, 
                                                                   Quantity__c = 5000, Ship_Date__c = System.today(), Arrival_Date_Anticipated__c = System.today(),
                                                                   Status__c = 'Requested', Shipping_Method__c = 'UPS', Tracking_Number__c = '1Z8999999999999998'));
            
            insert inventoryTransactions;  
        }
        catch(Exception ex)
        {
            System.assertEquals(true, ex.getMessage().contains('REQUIRED_FIELD_MISSING'));
        }
        
        Test.stopTest();
        
    }
}