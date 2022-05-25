/**
 * Purpose            :    Test class for Sched_Batch_TokenUsedChatterOnAcc
 * 
 * Created By         :    Abhishek Mishra
 * 
 * Current Version    :    V_1.0
 *
 * Revision Log       :    V_1.0 - Abhishek Mishra - CR-20211005-15489 - 07/06/2021
 **/
@isTest
private class Test_Sched_Batch_TokenUsedChatterOnAcc 
{ 
    @isTest
    static void  test_Sched_Batch_TokenUsedChatterOnAccount()
    {
        Util.bypassAllTriggers = true; 
        
        //Create User
        User u = TestUtilities.CreatenewUser(true);
        
        //Create Institution
        Account acct = TestUtilities.CreateNewAccount(true);
        acct.Tokens__c = 5;
        acct.Research_Strategic_Leader__c = u.Id;
        update acct;
        
        Account eligibleParentAcct = TestUtilities.CreateNewAccount(false);
        eligibleParentAcct.r_School_Id__c = 12332;
        insert eligibleParentAcct;
        
        //Create Program
        Program__c testProg1 = TestUtilities.CreateNewRIProgram(false);
        testProg1.Program_Acronym__c='ZZZ';
        insert testProg1; 
        
        Membership__c member = TestUtilities.CreateNewMembership(acct.Id, testProg1.Id, true);
        
        //Create Web_Program_Access__c
        Web_Program_Access__c webPrgmAcc = new Web_Program_Access__c();
        webPrgmAcc.Name = 'Test';
        webPrgmAcc.Description__c = 'Testing';
        insert webPrgmAcc;
        
        //Create Web_Program_Access_MTM__c
        Web_Program_Access_MTM__c webPrgmAccMTM = new  Web_Program_Access_MTM__c();
        webPrgmAccMTM.Membership_Program__c = testProg1.Id;
        webPrgmAccMTM.Web_Program__c = webPrgmAcc.Id;
        insert webPrgmAccMTM ;
        
        //Create contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = 'mike@royall.com';
        c.AccountId = acct.Id;
        c.Company_Email__c = 'mike@royall.com';
        c.Bypass_Domain_Validation__c = true;
        insert c;
        
        //Create Site Profile
        Site_Profile__c site_Profile = Test_SiteUserHelper.createSiteProfile(eligibleParentAcct.Id,false);
        site_Profile.Username__c = c.Company_Email__c;
        site_Profile.Site_User__c = null;
        site_Profile.Contact__c = c.Id;
        site_Profile.r_Institution__c = eligibleParentAcct.Id;
        site_Profile.RecordTypeId = Test_SiteProfileActionController.SITE_PROFILE_RT_ID_ROYALL;
        site_Profile.Type__c = SiteUserHelper.SITE_ROYALL;
        site_Profile.Token_s_Pending_For_Chatter__c = true;
        
        SiteUserHelper.IsTriggerContact = false; //Reset this so the code is triggered correctly
        insert site_Profile; 
        
        //Create Site_Content__c
        Site_Content__c site_Content = new Site_Content__c( Name = 'Test Insight Name',
                                                           GUID__c = '23085',
                                                           Title__c = 'Test Insight title',
                                                           URL__c = 'https://eabwpedevelop.wpengine.com/?p=23085');
        insert site_Content; 
        
        //Create Site_Token__c
        List<Site_Token__c> site_Tokens = new List<Site_Token__c>();
        site_Tokens.add(new Site_Token__c(Site_Content__c = site_Content.Id, Site_Profile__c = site_Profile.Id,Contact__c = c.Id,Expiration_Date__c = system.today()));
        site_Tokens.add(new Site_Token__c(Site_Content__c = site_Content.Id, Site_Profile__c = site_Profile.Id,Contact__c = c.Id,Expiration_Date__c = system.today()));
        site_Tokens.add(new Site_Token__c(Site_Content__c = site_Content.Id, Site_Profile__c = site_Profile.Id,Contact__c = c.Id,Expiration_Date__c = system.today()));
        site_Tokens.add(new Site_Token__c(Site_Content__c = site_Content.Id, Site_Profile__c = site_Profile.Id,Contact__c = c.Id,Expiration_Date__c = system.today()));
        site_Tokens.add(new Site_Token__c(Site_Content__c = site_Content.Id, Site_Profile__c = site_Profile.Id,Contact__c = c.Id,Expiration_Date__c = system.today()));
        insert site_Tokens;
        
        Util.bypassAllTriggers = false;
        
        Test.startTest();
        
        Datetime sysTime = DateTime.now().addMinutes(5);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
        //Schedule the Job
        System.Schedule('Test Sched_Batch_TokenUsedChatterOnAcc',chron_exp, new Sched_Batch_TokenUsedChatterOnAcc());
        
        Test.stopTest();
        
        //Checking the Schedule Job
        List<AsyncApexJob> asyncApexJob = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals('Sched_Batch_TokenUsedChatterOnAcc', asyncApexJob[0].ApexClass.Name);
    }
}