/**
*  Description     :    This is controller class for MailRoomManagementSystemController
*
*  Created By      :    Subhash Gharwal
*
*  Created Date    :    07/26/2021   
* 
*  Revision Logs   :    V_1.0 - Created - CR-20210722-15306
*		   :    V_1.1 - Modified By - Shalu Sharma - 02/11/2022 - CR-20220125-15748 - Mailroom Management App - Create Tab Structure based on Status 
*                      
**/
@isTest(seeAllData = false)
public class Test_MailRoomManagementSystemController 
{
   @testSetup static void dataSetup()
    { 
        Util.byPassAllTriggers = true;
          
        List<Mailroom_Inventory__c> mailPackages = new List<Mailroom_Inventory__c>();
        mailPackages.add(new Mailroom_Inventory__c (Name = 'DC-MAIL-000101', Carrier__c = 'USPS', Package_Type__c = 'Mail',
                                                    Sender__c = 'University of Nebraska-Lincoln', Status__c = 'Waiting-Scanning',
                                                    Bin__c = 'DC-BIN-0001', Recipient__c = UserInfo.getUserId()));
        mailPackages.add(new Mailroom_Inventory__c (Name = 'DC-MAIL-000102', Carrier__c = 'USPS', Package_Type__c = 'Mail',
                                                    Sender__c = 'University of Nebraska-Lincoln', Status__c = 'Completed-Picked up',
                                                    Bin__c = 'DC-BIN-0002', Recipient__c = UserInfo.getUserId())); 
        mailPackages.add(new Mailroom_Inventory__c (Name = 'DC-MAIL-000103', Carrier__c = 'USPS', Package_Type__c = 'Mail',
                                                    Sender__c = 'University of Nebraska-Lincoln', Status__c = 'Waiting-Picking up',
                                                    Bin__c = 'DC-BIN-0003', Recipient__c = UserInfo.getUserId())); 
        mailPackages.add(new Mailroom_Inventory__c (Name = 'DD-MAIL-000104', Carrier__c = 'USPS', Package_Type__c = 'Mail',
                                                    Sender__c = 'University of Nebraska-Lincoln', Status__c = 'Waiting for user',
                                                    Bin__c = 'DD-BIN-0004', Recipient__c = UserInfo.getUserId())); 
        insert mailPackages;
        Util.byPassAllTriggers = false;
    }
       
    static testMethod void test_fetchMailroomOptionDetails()
    {
        String envirnmentMgrId='%'+Label.Environment_Manager_Email_Id +'%';
        User adminUser = [Select Id, username, name from User Where Email LIKE : envirnmentMgrId];
        
        Test.startTest();
        
        System.RunAs(adminUser) {
            LightningResponseEntity res = MailRoomManagementSystemController.fetchMailroomOptionDetails();
        }
        
        Test.stopTest();
    }
    
    //Modified By - Shalu Sharma - 02/11/2022 - CR-20220125-15748
    static testMethod void test_fetchMailPackageDetails()
    { 
        String mailRoomManagementWrap = ' {"mailroomOptionsWrapper":[{"label":"All","value":"All"}],"mailroomsRecDetailWarpper":[],"mapOfMailroomPrefixAndDevName":{},"userAllowedToAccessMailroom":true,"userResponseRecDetailWarpper":[]}';
        LightningResponseEntity res = MailRoomManagementSystemController.fetchMailPackageDetails(mailRoomManagementWrap, 'in_Inventory');
        
        System.assertEquals(true, res.message.contains('eabMailroomManagmentWrapper can not be null'));
        
        mailRoomManagementWrap = ' {"mailroomOptionsWrapper":[{"label":"All","value":"All"}],"mailroomsRecDetailWarpper":[],"mapOfMailroomPrefixAndDevName":{"DL%":"DL_Mailroom"},"userAllowedToAccessMailroom":true,"userResponseRecDetailWarpper":[]}';
        res = MailRoomManagementSystemController.fetchMailPackageDetails(mailRoomManagementWrap, 'in_Inventory');
        
        System.assertEquals(true, res.message.contains('No record(s) to display.'));
        
        mailRoomManagementWrap = ' {"mailroomOptionsWrapper":[{"label":"All","value":"All"},{"label":"DC Mailroom","value":"DC_Mailroom"},{"label":"DD Mailroom","value":"DD_Mailroom"}],"mailroomsRecDetailWarpper":[],"mapOfMailroomPrefixAndDevName":{"DC%":"DC_Mailroom","DD%":"DD_Mailroom"},"userAllowedToAccessMailroom":true,"userResponseRecDetailWarpper":[]}';
        res = MailRoomManagementSystemController.fetchMailPackageDetails(mailRoomManagementWrap, 'in_Inventory');
    }
    
    static testMethod void test_fetchMailPackageHistoryDetails()
    {
        List<Mailroom_Inventory__c> mailPackages = [SELECT Id, Status__c FROM Mailroom_Inventory__c];
        System.assertEquals(4, mailPackages.size());
        
        mailPackages[0].Status__c = 'Waiting-Picking up';
        update mailPackages[0];
        
        Test.startTest();
        
        LightningResponseEntity res = MailRoomManagementSystemController.fetchMailPackageHistoryDetails(mailPackages[0].Id);
        
        Test.stopTest();
    }
    
    static testMethod void test_NegUseCases()
    {
        String mailPackageId = '';
        String mailRoomManagementWrap = '';
        try
        {
            MailRoomManagementSystemController.fetchMailPackageDetails(mailRoomManagementWrap, '');
            MailRoomManagementSystemController.fetchMailPackageHistoryDetails(mailPackageId);
        }
        Catch(Exception e){ }
    }
}