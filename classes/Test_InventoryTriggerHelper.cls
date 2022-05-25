/**
*   Purpose         :   Test class for InventoryTriggerHelper 
*            
*   Create By       :   Abhinav Sharma
* 
*   Created Date    :   10/29/2021
*
*   Revision Log    :   V_1.0 - Created By - Shalu Sharma - 10/20/2021 -  CR-20210924-15459
*		    :   V_1.1 - Modified By - Shalu Sharma - 22/12/2021 - CR-20211213-15624 - Added new method "test_sendEmailWhenQtyInInventoryIsLessThanPrintQtyContracted"
*		    :   V_1.2 - Modified By - Shalu Sharma - 19/01/2021 - CR-20220105-15694 - Update method "test_sendEmailWhenQtyInInventoryIsLessThanPrintQtyContracted".
*					
**/
@isTest(seeAllData = false)
public class Test_InventoryTriggerHelper 
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
        
        Job_Ticket_Component__c jobTctComponetEnv = PrintManagementTestDataFactory.CreateNewJobTicketComponent(false);
        jobTctComponetEnv.Component__c = 'Envelope';
        insert jobTctComponetEnv;
        
        Job_Ticket_MtM__c jobTickectMTMs = PrintManagementTestDataFactory.CreateNewJobTicketMTM(false);
        jobTickectMTMs.Job_Ticket_Component__c = jobTctComponet.Id;
        jobTickectMTMs.Job_Ticket__c = jobTickets[0].Id;
        jobTickectMTMs.Component_Code__c = 'AE0012';
        insert jobTickectMTMs;
        
        Job_Ticket_MtM__c jobTickectMTMEnv = PrintManagementTestDataFactory.CreateNewJobTicketMTM(false);
        jobTickectMTMEnv.Job_Ticket_Component__c = jobTctComponetEnv.Id;
        jobTickectMTMEnv.Job_Ticket__c = jobTickets[0].Id;
        jobTickectMTMEnv.Component_Code__c = 'AE0013';
        insert jobTickectMTMEnv;
        
        Id RECORD_TYPE_ID_PRODUCTION_TRACKING_PRINT = Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByDeveloperName().get('Print').getRecordTypeId();
        Id RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP = Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByDeveloperName().get('Mail_Shop').getRecordTypeId();

        List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,
                                                  Job_Ticket__c = jobTickets[0].Id, Job_Ticket_MtM__c = jobTickectMTMs.Id, RecordTypeId = RECORD_TYPE_ID_PRODUCTION_TRACKING_PRINT, 
                                                  Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, 
                                                  Internal_Data_Drop__c = 1, Art_File_Name__c = 'Art.zip'));
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,
                                                  Job_Ticket__c = jobTickets[0].Id, RecordTypeId = RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, 
                                                  Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL, 
                                                  Internal_Data_Drop__c = 1, Art_File_Name__c = 'Art1.zip'));
        insert pTrackings;
        
        List<Inventory__c> inventorys = new List<Inventory__c>();
        inventorys.add(new Inventory__c(Institution__c = inst.Id ,Job_Ticket_MtM__c = jobTickectMTMs.Id, 
                                        Inventory_Control_Number__c = 'AE0012', Production_Tracking__c = pTrackings[0].Id));
        insert inventorys;
        
        List<Inventory_Transaction__c> inventoryTransactions = new List<Inventory_Transaction__c>();
        inventoryTransactions.add(new Inventory_Transaction__c(Inventory__c = inventorys[0].Id, Original_Vendor__c = inst1.Id, Target_Vendor__c = inst1.Id,
                                                               Production_Tracking__c = pTrackings[0].Id, Effective_Quantity__c = 10000, 
                                                               Quantity__c = 5000, Ship_Date__c = System.today(), Arrival_Date_Anticipated__c = System.today(),
                                                               Status__c = 'Requested', Shipping_Method__c = 'UPS', Tracking_Number__c = '1Z8999999999999998',
                                                               Mailshop_Production_Tracking__c = pTrackings[1].Id));
        
        insert inventoryTransactions;
        
        Util.BypassAllTriggers = false; 
    }
    
    static testMethod void test_updateInsufficientInventoryOnRelatedMailShopPTs()
    {
        List<Inventory__c> inventorys = [SELECT Id, Name, Current_Available_Amount__c  FROM Inventory__c];
        System.assert(inventorys.size() > 0);
        
        List<Inventory_Transaction__c> inventoryTransactions = [SELECT Id, Name, Quantity__c, Status__c  FROM Inventory_Transaction__c];
        System.assert(inventoryTransactions.size() > 0);
        
        Test.startTest();
        //If the value of Current Available Inventory moves from a figure of positive/0 to a value in minus figures (less than 0)
        inventorys[0].Current_Available_Amount__c = -500;
        update inventorys[0];
        List<Inventory_Transaction__c> inventoryTransactionList = [SELECT Id, Mailshop_Production_Tracking__r.Insufficient_Inventory__c  
                                                                   FROM Inventory_Transaction__c];
        System.assertEquals(true, inventoryTransactionList[0].Mailshop_Production_Tracking__r.Insufficient_Inventory__c);
        
        //If the value of Current Available Inventory moves from a figure of negative to a value in plus figures (greater than 0),
		inventorys[0].Current_Available_Amount__c = 600;
        update inventorys[0];
        List<Inventory_Transaction__c> inventoryTransactionAfterUpdate = [SELECT Id, Mailshop_Production_Tracking__r.Insufficient_Inventory__c  
                                                                   		  FROM Inventory_Transaction__c];
        System.assertEquals(false, inventoryTransactionAfterUpdate[0].Mailshop_Production_Tracking__r.Insufficient_Inventory__c);
        Test.stopTest();
    }
    
    //Added By - Shalu Sharma - 22/12/2021 - CR-20211213-15624 - Added new method "test_sendEmailWhenQtyInInventoryIsLessThanPrintQtyContracted"
    //Modified By - Shalu Sharma - 19/01/2021 - CR-20220105-15694 - Update method "test_sendEmailWhenQtyInInventoryIsLessThanPrintQtyContracted"
    static testMethod void test_sendEmailWhenQtyInInventoryIsLessThanPrintQtyContracted()
    {
        Util.BypassAllTriggers = true;
        
        List<Account> accounts = [SELECT Id FROM Account];
        
        Program__c prog = TestUtilities.createNewProgram(null, 'ESNN', 'No', 'Enrollment Services', false);
        insert prog;
        
        List<Membership__c> memberships = new List<Membership__c>();
        memberships.add(new Membership__c(Name = 'Test Membership 1', Account_Name__c = accounts[0].Id,
                                          Program__c = prog.Id, Account_AM__c = UserInfo.getUserId()));
        insert memberships;
        
        List<Project__c> projects = [SELECT Id, Primary_Paid_Membership__c FROM Project__c];
        projects[0].Primary_Paid_Membership__c = memberships[0].Id;
        update projects;
        
        List<Job_Ticket__c> jobTickets = [SELECT Id, Mail_Quantity__c FROM Job_Ticket__c];
        jobTickets[0].Mail_Quantity__c = 80000;
        jobTickets[0].Program_Type__c = 'AMS - FAL';
        update jobTickets;
        
        List<Production_Tracking__c> productionTrackings = [SELECT Id, Print_Quantity_Contracted__c  FROM Production_Tracking__c];
        System.assert(productionTrackings.size() > 0);
        
        List<Inventory_Transaction__c> inventoryTransactions = [SELECT Id, Quantity_Printed__c  FROM Inventory_Transaction__c];
        inventoryTransactions[0].Quantity_Printed__c = 6000;
        update inventoryTransactions;
        
        Util.BypassAllTriggers = false;
        
        Test.startTest();
        
        List<Inventory__c> inventorys = [SELECT Id, PT_Print_Quantity_Contracted__c FROM Inventory__c];
        inventorys[0].PT_Print_Quantity_Contracted__c = 80000;
        update inventorys;
        
        Test.stopTest();
    }
}