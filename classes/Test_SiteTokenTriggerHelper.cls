/**
 * Description		:	Test classs for the code coverage of 
 * 
 * Created By 		:	
 * 
 * Created Date		: 	27/11/2019
 * 
 * RevisionLog   	:   V_1.0 - Created 
 *		    		:   V_1.1 - Modified by Neha Sharma - 06/21/2021 - CR-20210517-15150 - To increase code coverage
 *		    		:   V_1.2 - Modified by Nikita Kumari - 07/30/2021 - CR-20200520-14074 - Test populateTokenOnWarmLead method of SiteTokenTriggerHelper
**/
@isTest(SeeAllData=false)
public class Test_SiteTokenTriggerHelper {
    
    @testSetup static void testSetupMethod(){
        Util.bypassAllTriggers = true; 
        //Create User
        User u = new User(Alias = 'standtq', Email='test123456@abc.com', 
        		  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = '00eC00000016HQP', 
                          TimeZoneSidKey='America/Los_Angeles', UserName=Math.random()+'@testorg.com');
		
        insert u;
        
        //create Institute
        Account acct = TestUtilities.CreateNewAccount(true);
        acct.Tokens__c = 5;
        acct.Research_Strategic_Leader__c = u.Id;
        update acct;
        Account eligibleParentAcct = TestUtilities.CreateNewAccount(false);
        eligibleParentAcct.r_School_Id__c = 12332;
        insert eligibleParentAcct;
        
        //create Program__c
        Program__c testProg1 = new Program__c(Name='Test Trigger Program',
                                              New_Business_Marketer__c = 'RI Marketer', 
                                              Program_Acronym__c='ZZZ', Create_memberships__c='No',
                                              Business_line__c = 'PT');
        insert testProg1; 
        
        //create Membership__c
        Membership__c member = new Membership__c( 	Name = 'Test Membership',
                                                 Account_Name__c = acct.Id,
                                                 Program__c = testProg1.Id);
        insert member ;
        
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
        c.Company_Email__c = 'mike@royall.com';
        c.Bypass_Domain_Validation__c = true;
        insert c;
        
        //create site profile
        //Modified site profile by populating Token_s_Pending_For_Chatter__c and Tokens_Used_YTD__c fields - Neha Sharma - 06/18/2021 - CR-20210517-15150
        Site_Profile__c site_Profile = new Site_Profile__c(Status__c = 'Active',
                                                           Username__c = c.Company_Email__c,
                                                           Password__c = 'test',
                                                           Site_User__c = null,
                                                           Verify__c = '2',
                                                           Contact__c = c.Id,
                                                           r_Institution__c = eligibleParentAcct.Id,
                                                           RecordTypeId = Test_SiteProfileActionController.SITE_PROFILE_RT_ID_ROYALL,
                                                           Type__c = SiteUserHelper.SITE_ROYALL,
                                                           Tokens__c = 5,
                                                           Token_s_Pending_For_Chatter__c = True 
                                                           /*Tokens_Used_YTD__c = 10*/);
        
        
        SiteUserHelper.IsTriggerContact = false; //reset this so the code is triggered correctly
        insert site_Profile; 
        
        //create Site_Content__c
        Site_Content__c site_Content = new Site_Content__c( Name = 'Test Insight Lorem Ipsum Lorem Ipsum Lorem Ipsum',
                                                           GUID__c = '23085',
                                                           Title__c = 'Test Insight Lorem Ipsum Lorem Ipsum Lorem Ipsum',
                                                           URL__c = 'https://eabwpedevelop.wpengine.com/?p=23085');
        insert site_Content; 
        
        //create Site_Token__c
        //Modified siteTokens by adding Chatter_Posted_For_This_Token__c field - Neha Sharma - 06/18/2021 - CR-20210517-15150
        List<Site_Token__c> site_Tokens = new List<Site_Token__c>();
        site_Tokens.add(new Site_Token__c(Site_Content__c = site_Content.Id, Site_Profile__c = site_Profile.Id,Contact__c = c.Id, Chatter_Posted_For_This_Token__c = True));
        site_Tokens.add(new Site_Token__c(Site_Content__c = site_Content.Id, Site_Profile__c = site_Profile.Id,Contact__c = c.Id, Chatter_Posted_For_This_Token__c = True));
        site_Tokens.add(new Site_Token__c(Site_Content__c = site_Content.Id, Site_Profile__c = site_Profile.Id,Contact__c = c.Id, Chatter_Posted_For_This_Token__c = True));
        site_Tokens.add(new Site_Token__c(Site_Content__c = site_Content.Id, Site_Profile__c = site_Profile.Id,Contact__c = c.Id, Chatter_Posted_For_This_Token__c = True));
        site_Tokens.add(new Site_Token__c(Site_Content__c = site_Content.Id, Site_Profile__c = site_Profile.Id,Contact__c = c.Id, Chatter_Posted_For_This_Token__c = True));
        
        insert site_Tokens;
    }
    
    //Added by - Nikita Kumari - 07/30/2021 - CR-20200520-14074 - Test populateTokenOnWarmLead method of SiteTokenTriggerHelper
    @isTest
    static void test_populateTokenOn1EABLead(){
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Get the Site Content 
        Site_Content__c siteContent = [Select Id,Name,Title__c From Site_Content__c];
        
        //Get the Profile
        Site_Profile__c sProfile = [SELECT Id, Tokens__c, Tokens_Available__c, Contact__c, Contact__r.AccountId FROM Site_Profile__c Limit 1];
                
        //List of Program
        List<Program__c> programs = new List<Program__c>();
        
        //Add new Programs in list
        programs.add(new Program__c(Name = 'Test Program 1', Status__c = 'Active',Marketable__c = true));
        programs.add(new Program__c(Name = 'Test Program 2', Status__c = 'Active',Marketable__c = true));
        
        //Insert
        insert programs;
        
        //Create restricted accounts
        List<Contact> contacts = [Select Id, AccountId from Contact];
        
        //create Opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PT Marketing').getRecordTypeId();
        opp.Name = 'test' + crypto.getRandomInteger();
        opp.AccountId = contacts[0].AccountId;
        opp.StageName = 'Pending- Renewal Call Not Yet Occured';
        opp.Amount = 100;
        opp.CloseDate = system.today().addDays(32);
        opp.Pricebook2Id = Test.getStandardPricebookId();
        opp.Main_Contact__c = contacts[0].Id;
        opp.Sales_Pursuit_Products__c = 'APS';
        opportunities.add(opp);
        
        //Insert Opportunity Data
        insert opportunities;
        
        List<Product_Lead__c> productLeadList = new List<Product_Lead__c>();
        productLeadList.add(new product_lead__c (Name = 'Test1',Contact__c = opportunities[0].Main_Contact__c, Program__c = programs[0].Id,Stage__c = 'Inquiry'));
        productLeadList.add(new product_lead__c (Name = 'Test1',Contact__c = opportunities[0].Main_Contact__c, Program__c = programs[1].Id,Stage__c = 'Inquiry'));
        
        insert productLeadList;
       
        List<X1EAB_Lead__c> eabLeadList = new List<X1EAB_Lead__c>();
        eabLeadList.add(new X1EAB_Lead__c(Name = 'Test1', Contact__c = opportunities[0].Main_Contact__c,Primary_Program__c =programs[0].Id,
                                          PDE_Assignment__c= UserInfo.getUserId(), PDR_PDA_Assignment__c = UserInfo.getUserId(), 
                                          Primary_Lead_Passer__c = UserInfo.getUserId(), Opportunity__c = opportunities[0].Id));
        eabLeadList.add(new X1EAB_Lead__c(Name = 'Test1', Contact__c = opportunities[0].Main_Contact__c,Primary_Program__c =programs[1].Id,
                                          PDE_Assignment__c= UserInfo.getUserId(), PDR_PDA_Assignment__c = UserInfo.getUserId(), 
                                          Primary_Lead_Passer__c = UserInfo.getUserId(), Opportunity__c = opportunities[0].Id));
       
        insert eabLeadList;
        
        Util.byPassAllTriggers = false;
         
        List<Site_Token__c> siteToken = new List<Site_Token__c>();
        siteToken.add(new Site_Token__c(Site_Content__c = siteContent.Id, Site_Profile__c = sProfile.Id,Contact__c = opportunities[0].Main_Contact__c, Lead__c = eabLeadList[0].Id, Lead_Generated__c = 'Yes'));
        siteToken.add(new Site_Token__c(Site_Content__c = siteContent.Id, Site_Profile__c = sProfile.Id,Contact__c = opportunities[0].Main_Contact__c, Lead__c = eabLeadList[1].Id, Lead_Generated__c = 'Yes'));
  
        Test.startTest();
    
        //insert site tokens 
        insert siteToken;
        
        eabLeadList = [Select Id, Token__c,Content_Accessed_To_Drive_Lead__c from X1EAB_Lead__c Where Id IN :eabLeadList ORDER BY NAME ASC];
       
        System.assertEquals(siteToken[1].Id, eabLeadList[0].token__c);
        System.assertEquals(siteToken[0].Id, eabLeadList[1].token__c);
        System.assertEquals(siteContent.Title__c, eabLeadList[0].Content_Accessed_To_Drive_Lead__c);
        System.assertEquals(siteContent.Title__c, eabLeadList[1].Content_Accessed_To_Drive_Lead__c);
        
        siteToken[0].Lead_Generated__c = 'No - Already Vetted - Not Interested in Membership';
        siteToken[0].Lead__c = null;
        siteToken[1].Lead__c = eabLeadList[0].Id;
        
        update siteToken; 
        
        eabLeadList = [Select Id, Token__c,Content_Accessed_To_Drive_Lead__c from X1EAB_Lead__c Where Id IN :eabLeadList ORDER BY NAME ASC];
       
        System.assertEquals(siteToken[1].Id, eabLeadList[0].token__c);
        System.assertEquals(null, eabLeadList[1].token__c);
        
        Test.stopTest();
    }
    
    //test the batch job that chatters when a Site Profile or Account runs out of Tokens
    @isTest
    static void testBatch_TokenChatterOnAccountAndContact() {
        
        //get the site profile
        Site_Profile__c sProfile = [SELECT Id, Tokens__c, Tokens_Available__c, Contact__c, Contact__r.AccountId FROM Site_Profile__c];
        
        //update tokens to zero
        sProfile.Tokens__c = 0;
		
	Util.bypassAllTriggers = true; 
		
        update sProfile;
        Util.bypassAllTriggers = false; 
		
        //set updated site profile
        sProfile = [SELECT Id, Tokens__c, Tokens_Available__c, Contact__c, Contact__r.AccountId FROM Site_Profile__c];
        system.assertEquals(0, sProfile.Tokens_Available__c);
        
        //populate Research_Strategic_Leader__c
        Account a = new Account(Id = sProfile.Contact__r.AccountId,
                                Research_Strategic_Leader__c = UserInfo.getUserId());
        util.bypassAllTriggers = true;
        update a;
        
        // Modified By Rajeev Jain - 30July2020 - change from (new Batch_TokenUsedChatterOnAccount(), 1) to (new Batch_TokenUsedChatterOnAccount()
        test.startTest();
        //execute the batch job to chatter
        database.executeBatch(new Batch_TokenUsedChatterOnAccount());
        test.stopTest();
        
        /*List<FeedItem> feedItems = [SELECT Id, Body FROM FeedItem WHERE ParentId = :sProfile.Contact__c];
        system.assertEquals(1, feedItems.size());*/
    }
    
    //Added by Neha Sharma - 06/18/2021  - CR-20210517-15150 - To increase code coverage
    @isTest
    static void testUpdateSiteProfileWhenTokenChatterPosted()
    {
        test.startTest();
        
        //Fetch SOQL to get Site Tokens
        List<Site_Token__c> siteTokens = [Select Id, Chatter_Posted_For_This_Token__c From Site_Token__c];
        
        //Assert
        System.assertEquals(5, siteTokens.size());
        
        siteTokens[0].Chatter_Posted_For_This_Token__c = False;
        siteTokens[1].Chatter_Posted_For_This_Token__c = False;
        siteTokens[2].Chatter_Posted_For_This_Token__c = False;
        siteTokens[3].Chatter_Posted_For_This_Token__c = False;
        siteTokens[4].Chatter_Posted_For_This_Token__c = False;
        //update Site Tokens
        update siteTokens;
        
        //Delete Site Token
        delete siteTokens[1];
        test.stopTest();      
    }
}