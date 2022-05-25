/*
 * Purpose          :   Test class for MailroomInventoryTriggerHelper 
 * 
 * CreatedDate      :   07/16/2021
 * 
 * RevisionLog      :   V_1.0 - Created - Subhash Garhwal - CR-20210722-15306
 * 
 * Code Coverage    :   93%
 * */
@IsTest
private class Test_MailroomInventoryTriggerHelper 
{   
    //Setup data
    @testSetup static void testSetupData()
    {
        //Bypass Dupeblocker
        Util.IsTest(true);
        //Bypass Triggers
        Util.BypassAllTriggers = true;
        
        //Create a user for running the process
        Profile specialistProfile = [SELECT Id FROM Profile WHERE Name = 'Specialist' LIMIT 1];
        //Create a user for running the process
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        //Create Users
        User user1 = testUtilities.CreateNewUser(specialistProfile, false);
        user1.LastName = 'SpecialistUser';
        insert user1;
        
        User sFAdminUser = testUtilities.CreateNewUser(sysAdminProfile, false);
        sFAdminUser.LastName = 'SystemAdminUserLastName';
        insert sFAdminUser;
        
        //List to hold mailPackages
        List<Mailroom_Inventory__c> mailPackages  = new List<Mailroom_Inventory__c>();
        mailPackages.add(new Mailroom_Inventory__c(OwnerId = user1.Id, Name = 'DC-MAIL-000101', CurrencyIsoCode = 'USD',
                                                   Recipient__c = sFAdminUser.Id, Package_Type__c = 'Mail', Carrier__c = 'USPS',
                                                   Sender__c = 'University of Nebraska-Lincoln',Bin__c = 'DC-BIN-0001',
                                                   Status__c = 'Waiting for user'));
        
        mailPackages.add(new Mailroom_Inventory__c(OwnerId = user1.Id, Name = 'DC-MAIL-000102', CurrencyIsoCode = 'USD',
                                                   Recipient__c = sFAdminUser.Id, Package_Type__c = 'Mail', Carrier__c = 'USPS',
                                                   Sender__c = 'University of Nebraska-Lincoln',Bin__c = 'DC-BIN-0001',
                                                   Status__c = 'New'));
        
        mailPackages.add(new Mailroom_Inventory__c(OwnerId = user1.Id, Name = 'DC-MAIL-000102', CurrencyIsoCode = 'USD',
                                                   Recipient__c = sFAdminUser.Id, Package_Type__c = 'Mail', Carrier__c = 'USPS',
                                                   Sender__c = 'University of Nebraska-Lincoln',Bin__c = 'DC-BIN-0001',
                                                   Status__c = 'Waiting-Scanning'));
        
        //Insert mailPackages
        insert mailPackages;
        Util.bypassAllTriggers = false;
    } 

    //07/16/2021 - Subhash Garhwal - test sendNotificationToEmployee
    @IsTest 
    static void testSendNotificationToEmployee() 
    {
        //Set Mock callout
        MailPackageMock mailPackage = new MailPackageMock();
        Test.setMock(HttpCalloutMock.class, mailPackage);
        
        List<Mailroom_Inventory__c> mailPackages = [Select Id, status__c From Mailroom_Inventory__c Order BY Name ASC];
        //Start Testing
        Test.startTest();
        //Update Mail Packages
        mailPackages[0].status__c = 'Completed-Picked up';
        mailPackages[1].status__c = 'Waiting for user';
        mailPackages[2].status__c = 'Waiting for user';
        update mailPackages;
        
        //Set Mock callout
        MailPackageMock mailPackage1 = new MailPackageMock();
        //Set MailPackage Response to 1 
        mailPackage1.responseNumber = 1;
        Test.setMock(HttpCalloutMock.class, mailPackage1);
        

        Test.stopTest();
        
        //Fetch Web Service log
        List<Web_Service_Log__c> webServiceLog = [Select Id, Requested_By__c,Response_Message_Log__c,Response_Message__c,
                                                  Request_Message_Log__c, Request_Sent__c, Mailroom_Inventory__c From Web_Service_Log__c
                                                  Order BY Mailroom_Inventory__r.Name ASC];
        
        system.assert(webServiceLog.size()>0);
        System.assertEquals(3, webServiceLog.size());
        System.assertEquals(mailPackages[0].Id, webServiceLog[0].Mailroom_Inventory__c);
        System.assertEquals(mailPackages[1].Id, webServiceLog[1].Mailroom_Inventory__c);
        System.assertEquals(mailPackages[2].Id, webServiceLog[2].Mailroom_Inventory__c);
        System.assertEquals('200', webServiceLog[0].Response_Message__c);
        System.assertEquals('200', webServiceLog[1].Response_Message__c);
        System.assertEquals('200', webServiceLog[2].Response_Message__c);
    }
    
    
    @isTest
    static void test_populateOperatorFieldOnMailroomInventory(){
        Util.IsTest(true);
        //Bypass Triggers
        Util.BypassAllTriggers = true;
        
        //Create a user for running the process
        Profile specialistProfile = [SELECT Id FROM Profile WHERE Name = 'Specialist' LIMIT 1];
        //Create a user for running the process
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        //Create Users
        User user1 = testUtilities.CreateNewUser(specialistProfile, false);
        user1.LastName = 'SpecialistUser';
        insert user1;
        
        User sFAdminUser = testUtilities.CreateNewUser(sysAdminProfile, false);
        sFAdminUser.LastName = 'SystemAdminUserLastName';
        insert sFAdminUser;
        
        Util.BypassAllTriggers = false;
        
        //List to hold mailPackages
        List<Mailroom_Inventory__c> mailPackages  = new List<Mailroom_Inventory__c>();
        mailPackages.add(new Mailroom_Inventory__c(OwnerId = user1.Id, Name = 'DC-MAIL-000102', CurrencyIsoCode = 'USD',
                                                   Recipient__c = sFAdminUser.Id, Package_Type__c = 'Mail', Carrier__c = 'USPS',
                                                   Sender__c = 'University of Nebraska-Lincoln',Bin__c = 'DC-BIN-0001',
                                                   Status__c = 'New'));
                
        test.startTest();
        
        //Insert mailPackages
        insert mailPackages;
        
        mailPackages = [Select Id, Operator__c From Mailroom_Inventory__c Where Id IN: mailPackages];
        
        System.assertEquals(UserInfo.getUserId(), mailPackages[0].Operator__c);
            
        test.stopTest();
    }
    
}