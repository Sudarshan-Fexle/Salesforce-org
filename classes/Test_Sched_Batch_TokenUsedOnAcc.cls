/**
 * 
 * Desription      :    Test class for the Batch_TokenUsedChatterOnAccount class
 * 
 * Revision Logs   :    V_1.0 - Created
 *		   :	V_1.1 - Modified By - Nikita kumari - CR-20211005-15489 - 07/07/2021 - Test code covrage increase
 * 
 * 
 **/
@isTest
public class Test_Sched_Batch_TokenUsedOnAcc {
    
    //Modified By - Nikita kumari - 07/07/2021 - CR-20211005-15489 - Test code covrage increase
    @isTest
    static void  testBatch_TokenChatterOnAccountAndContact(){
        
        Util.bypassAllTriggers = true; 
        //modified by Nikita Kumari - 07/07/2021
        //Create User       
        User u = TestUtilities.CreatenewUser(true);
        
        //create Institute
        Account acct = TestUtilities.CreateNewAccount(true);
        acct.Tokens__c = 5;
        acct.Research_Strategic_Leader__c = u.Id;
        update acct;
        Account eligibleParentAcct = TestUtilities.CreateNewAccount(false);
        eligibleParentAcct.r_School_Id__c = 12332;
        insert eligibleParentAcct;
        
        //modified by Nikita Kumari - 07/07/2021
        //create Program__c
        Program__c testProg1 = TestUtilities.CreateNewRIProgram(false);
        testProg1.Program_Acronym__c='ZZZ';
        insert testProg1; 
        
        //create Membership__c
        Membership__c member = TestUtilities.CreateNewMembership(acct.Id, testProg1.Id, true);
        
        //create Web_Program_Access__c
        Web_Program_Access__c webPrgmAcc = new Web_Program_Access__c();
        webPrgmAcc.Name = 'Test';
        webPrgmAcc.Description__c = 'Testing';
        insert webPrgmAcc;
        
        //create Web_Program_Access_MTM__c
        Web_Program_Access_MTM__c webPrgmAccMTM = new  Web_Program_Access_MTM__c();
        webPrgmAccMTM.Membership_Program__c = testProg1.Id;
        webPrgmAccMTM.Web_Program__c = webPrgmAcc.Id;
        insert webPrgmAccMTM ;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = 'mike@royall.com';
        c.AccountId = acct.Id;
        c.Company_Email__c = 'mike@royall.com';
        c.Bypass_Domain_Validation__c = true;
        insert c;
        
        //create site profile
        //modified by Nikita Kumari - 07/07/2021        
        Site_Profile__c site_Profile = Test_SiteUserHelper.createSiteProfile(eligibleParentAcct.Id,false);
        site_Profile.Username__c = c.Company_Email__c;
        site_Profile.Site_User__c = null;
        site_Profile.Contact__c = c.Id;
        site_Profile.r_Institution__c = eligibleParentAcct.Id;
        site_Profile.RecordTypeId = Test_SiteProfileActionController.SITE_PROFILE_RT_ID_ROYALL;
        site_Profile.Type__c = SiteUserHelper.SITE_ROYALL;
        site_Profile.Token_s_Pending_For_Chatter__c = true;
        
        
        SiteUserHelper.IsTriggerContact = false; //reset this so the code is triggered correctly
        insert site_Profile; 
        
        //create Site_Content__c
        Site_Content__c site_Content = new Site_Content__c( Name = 'Test Insight Lorem Ipsum Lorem Ipsum Lorem Ipsum',
                                                           GUID__c = '23085',
                                                           Title__c = 'Test Insight Lorem Ipsum Lorem Ipsum Lorem Ipsum',
                                                           URL__c = 'https://eabwpedevelop.wpengine.com/?p=23085');
        insert site_Content; 
        
        //create Site_Token__c
        List<Site_Token__c> site_Tokens = new List<Site_Token__c>();
        site_Tokens.add(new Site_Token__c(Site_Content__c = site_Content.Id, Site_Profile__c = site_Profile.Id,Contact__c = c.Id,Expiration_Date__c = system.today()));
        site_Tokens.add(new Site_Token__c(Site_Content__c = site_Content.Id, Site_Profile__c = site_Profile.Id,Contact__c = c.Id,Expiration_Date__c = system.today()));
        site_Tokens.add(new Site_Token__c(Site_Content__c = site_Content.Id, Site_Profile__c = site_Profile.Id,Contact__c = c.Id,Expiration_Date__c = system.today()));
        site_Tokens.add(new Site_Token__c(Site_Content__c = site_Content.Id, Site_Profile__c = site_Profile.Id,Contact__c = c.Id,Expiration_Date__c = system.today()));
        site_Tokens.add(new Site_Token__c(Site_Content__c = site_Content.Id, Site_Profile__c = site_Profile.Id,Contact__c = c.Id,Expiration_Date__c = system.today()));
        
        insert site_Tokens;
        
        test.startTest();
        //execute the batch job to chatter
        database.executeBatch(new Batch_TokenUsedChatterOnAccount());
        test.stopTest();
        
        //Added by Nikita Kumari - 07/07/2021
        site_Tokens = [Select Id,Site_Content__c,Chatter_Posted_For_This_Token__c,Site_Profile__c,Contact__c From Site_Token__c];
        System.assertEquals(true, site_Tokens[0].Chatter_Posted_For_This_Token__c);
        System.assertEquals(true, site_Tokens[1].Chatter_Posted_For_This_Token__c);
        System.assertEquals(true, site_Tokens[2].Chatter_Posted_For_This_Token__c);
        System.assertEquals(true, site_Tokens[3].Chatter_Posted_For_This_Token__c);
        System.assertEquals(true, site_Tokens[4].Chatter_Posted_For_This_Token__c);
    }
}