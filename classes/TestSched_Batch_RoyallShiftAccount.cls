/**
 *  Description     :   Test Class for Scheduler_Batch_RoyallShiftAccountStatus
 *
 *  Created By      :   Abhishek Mishra
 *
 *  Created Date    :   07/09/2021
 *
 *  Revision Logs   :   V_1.0 - Created - 07/09/2021 - CR-20211005-15489
 * 
 *  Code Coverage   :   100%   
 *
 **/
@isTest(seeAllData = false)
private class TestSched_Batch_RoyallShiftAccount 
{
    @testsetup static void testSetupData() 
    {
        Util.BypassAllTriggers = true;
        
        //Create custom setting default so the trigger will fire to auto-populate programPackage fields
        Account_Status_Management__c acctStatusMgmt = new Account_Status_Management__c(Enable_Update_Account_Status_Trigger__c=true);
        insert acctStatusMgmt;
        
        Id PP_Royall_RT_Id = Schema.SObjectType.Program_Package__c.getRecordTypeInfosByName().get('Royall').getRecordTypeId();
        Id PP_HD_RT_Id = Schema.SObjectType.Program_Package__c.getRecordTypeInfosByName().get('Hardwick Day').getRecordTypeId();
        
        //Account data
        Account acct = TestUtilities.CreateNewAccount(true);
        acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Graduate Education').getRecordTypeId();
        update acct;
        
        Integer currentFY = shift_get_fiscal_year.current();  
        
        //Query list of Accounts
        acct = [Select Id, r_Current_Year_Status__c, r_Previous_Year_Status__c, r_Next_Year_Status__c, r_Current_Year_Account_Status__c,
                r_Previous_Year_Account_Status__c, r_Next_Year_Account_Status__c,r_HD_Previous_Year_Engagement_Status__c,
                r_HD_Current_Year_Engagement_Status__c, r_HD_Next_Year_Engagement_Status__c, r_HD_Previous_Year_Account_Status__c,
                r_hd_current_year_account_status__c, r_HD_Next_Year_Account_Status__c from Account WHERE Id = :acct.Id];
        System.assertEquals(null,acct.r_Previous_Year_Account_Status__c);
        
        //List of program Package						
        List<Program_Package__c> progPacks = new List<Program_Package__c>();
        progPacks.add(new Program_Package__c(Name = 'PackageT1', Account__c = acct.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY - 1)),
                                             Client_Status_New__c = 'At Risk', Account_Status__c = 'Existing Client', RecordTypeId = PP_Royall_RT_Id));
        progPacks.add(new Program_Package__c(Name = 'PackageT2', Account__c = acct.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY)),
                                             Client_Status_New__c = 'Secured', Account_Status__c = 'Existing Client', RecordTypeId = PP_Royall_RT_Id));
        progPacks.add(new Program_Package__c(Name = 'PackageT3', Account__c = acct.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY + 1)),
                                             Client_Status_New__c = 'Committed', Account_Status__c = 'New Client', RecordTypeId = PP_Royall_RT_Id));
        
        //HD Type Program Package
        progPacks.add(new Program_Package__c(Name = 'TestHd1', Account__c = acct.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY)),
                                             Client_Status_New__c = 'Secured', Account_Status__c = 'Existing Client', RecordTypeId = PP_HD_RT_Id));
        progPacks.add(new Program_Package__c(Name = 'TestHd2', Account__c = acct.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY + 1)),
                                             Client_Status_New__c = 'Committed', Account_Status__c = 'New Client', RecordTypeId = PP_HD_RT_Id));
        
        insert progPacks;
        
        Util.BypassAllTriggers = false; 
    }
    
    static testMethod void testSched_Batch_RoyallShiftAccountStatus() 
    {    
        Test.startTest();
        
        //After 1 min. batch will run
        Datetime sysTime = DateTime.now();
        sysTime = sysTime.addMinutes(5);
        
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        //Schedule the scheduler
        Scheduler_Batch_RoyallShiftAccountStatus sch = new Scheduler_Batch_RoyallShiftAccountStatus();
        System.Schedule('Schedular 1',chron_exp,sch);
        
        Test.stopTest();	
        
        List<AsyncApexJob> asyncApexJob = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        List<AsyncApexJob> batchApexJob = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
        //Asserts
        System.assertEquals('Scheduler_Batch_RoyallShiftAccountStatus', asyncApexJob[0].ApexClass.Name);
        System.assertEquals('Batch_RoyallShiftAccountStatus', batchApexJob[0].ApexClass.Name);
    }
}