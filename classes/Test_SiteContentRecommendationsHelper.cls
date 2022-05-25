@isTest(SeeAllData=false)
public class Test_SiteContentRecommendationsHelper {
    @testSetup static void testSetupMethod(){
        
        //Bypassing the triggers. 
        util.bypassAllTriggers = true;
        
        //create Institute
        Account acct = TestUtilities.CreateNewAccount(true);
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
        
         //Bypassing the triggers. 
        util.bypassAllTriggers = false;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = 'mike@royall.com';
        c.Company_Email__c = 'mike@royall.com';
        c.Bypass_Domain_Validation__c = true;
        insert c;
        
        //create site profile
        Site_Profile__c site_Profile = new Site_Profile__c(Status__c = 'Active',
                                                           Username__c = c.Company_Email__c,
                                                           Password__c = 'test',
                                                           Site_User__c = null,
                                                           Verify__c = '2',
                                                           Contact__c = c.Id,
                                                           r_Institution__c = eligibleParentAcct.Id,
                                                           RecordTypeId = Test_SiteProfileActionController.SITE_PROFILE_RT_ID_ACTIVE,
                                                           Type__c = SiteUserHelper.SITE_EAB);
        
        
        SiteUserHelper.IsTriggerContact = false; //reset this so the code is triggered correctly
        insert site_Profile; 
        
        //Updating the contact with the  newly created site profile. 
        c.EAB_com_Site_Profile__c = site_Profile.Id;
        update c;
        
        //create Site_Content__c
        Site_Content__c site_Content = new Site_Content__c( Name = 'Test Insight Lorem Ipsum Lorem Ipsum Lorem Ipsum',
                                                           GUID__c = '23085',
                                                           Title__c = 'Test Insight Lorem Ipsum Lorem Ipsum Lorem Ipsum',
                                                           URL__c = 'https://eabwpedevelop.wpengine.com/?p=23085');
        insert site_Content; 

        //create Site_Content_Recommendation__c
        Site_Content_Recommendation__c site_Content_Recommendation  = new Site_Content_Recommendation__c(Contact__c = c.Id,
                                                                                                         Site_Content__c = site_Content.Id,
                                                                                                         Site_Profile__c = site_Profile.Id);
        insert site_Content_Recommendation;
        
    }
    
    @isTest static void testController(){
        
        siteContentRecommendationsHelper testsiteContentRecommendationsHelper = new siteContentRecommendationsHelper();
        testsiteContentRecommendationsHelper.inIt();
        
        //Getting Site profile details
        List<Site_Profile__c> site_Profiles =[SELECT Id, Name, Contact__c, Contact__r.Name, Contact__r.Account.Name, Contact__r.AccountId
                                              FROM Site_Profile__c LIMIT 1];
        
        //Method that search for Contact.
        //siteContentRecommendationsHelper.searchDataForLookUp('Test', null, 'Contact', null);
        
        //creating data in to serialised form 
        String siteProfileDetails ='{"accountFormalName":"' + site_Profiles[0].Contact__r.Account.Name + 
                                    '","siteProfileContactName":"'+ site_Profiles[0].Contact__c +
                                    '","siteProfileId":"' + site_Profiles[0].Id +
                                    '","siteProfileName":"' + site_Profiles[0].Contact__r.Name + '"}';
        
        //creating data in to serialised form for update
		String jsonFormattedData2 ='[{"guid":"11192","siteContentId":"null","title":"Test Insight","url":"https://eabwpedevelop.wpengine.com/?p=192","webProgramAccessIds":["311"]}]';
        
        //Method that search for Contact.
        siteContentRecommendationsHelper.searchDataForLookUp('Joe', new List<String>(), 'Contact', jsonFormattedData2);
        
        //Calling getSiteProfileInfo(String siteProfileId)
        siteContentRecommendationsHelper.SiteProfileWrapper getSiteProfileInfoData = siteContentRecommendationsHelper.getSiteProfileInfo(site_Profiles[0].Id);
        System.assertEquals(site_Profiles[0].Contact__r.Account.Name, getSiteProfileInfoData.accountFormalName);
        System.assertEquals(site_Profiles[0].Contact__c, getSiteProfileInfoData.siteProfileContactName);
        System.assertEquals(site_Profiles[0].Id, getSiteProfileInfoData.siteProfileId);
        System.assertEquals(site_Profiles[0].Contact__r.Name, getSiteProfileInfoData.siteProfileName);
        
        Web_Program_Access__c webProgramAcc = [SELECT Program_Id_Autonumber__c  FROM Web_Program_Access__c];
        //Calling getInstitutionWebPrograms(String siteProfileId)
        String institutionData = siteContentRecommendationsHelper.getInstitutionWebPrograms(site_Profiles[0].Id);
        System.assertEquals(String.valueOf(webProgramAcc.Program_Id_Autonumber__c ), institutionData);
        
        //Getting Site contents data through site content recommendation
        List<Site_Content_Recommendation__c> site_Contents = [Select Id, Site_Content__r.GUID__c, Site_Content__r.Title__c, 
                                                              Site_Content__r.URL__c From Site_Content_Recommendation__c 
                                                              Where Site_Profile__c =: site_Profiles[0].Id];  
        
        //Calling getRelatedSiteContentRecords(String siteProfileId)
        List<siteContentRecommendationsHelper.SiteContentWrapper> getRelatedSiteContentRecordsData =siteContentRecommendationsHelper.getRelatedSiteContentRecords(site_Profiles[0].Id);
        System.assertEquals(site_Contents[0].Site_Content__r.GUID__c, getRelatedSiteContentRecordsData[0].guid);
        System.assertEquals(site_Contents[0].Site_Content__r.Title__c, getRelatedSiteContentRecordsData[0].title);
        System.assertEquals(site_Contents[0].Site_Content__r.URL__c, getRelatedSiteContentRecordsData[0].url);
        
        //Calling a method that is filling the endpoint. 
        HttpRequest req = siteContentRecommendationsHelper.buildWordpressHTTPCallout('GET', 'https//:www.Testwp.com');
        System.assert(req.getMethod() == 'GET');
		System.debug(req.getEndpoint());
        
        
        Test.startTest();
        String selectedAcc = '[{"id":"'+ site_Profiles[0].Contact__c + '","sObjectType":"Contact","icon":"standard:contact","title":"Syracuse University - Syracuse - NY","subtitle":"Syracuse University"}]';
        
        //Site Profile content Recommendations creation method that needs to be called directly. (From page it is called by Save button)
		siteContentRecommendationsHelper.createSiteContentRecommendationForMultipleSiteProfiles(selectedAcc, jsonFormattedData2);
		
        Test.StopTest();
    }
   
    @isTest
    Static void testController2() {
		
        //List to hold the accounts. 
        List<Account> acc = [Select Id, Name From Account];
        
		//In the context of Institution. 
		siteContentRecommendationsHelper accButtonController = new siteContentRecommendationsHelper();
        accButtonController.inIt();  
        
        Account a = siteContentRecommendationsHelper.getOriginalAccountInfo(acc[0].Id);
        System.assertEquals(acc[0].Name, a.Name);
        
        Boolean isClassic =  siteContentRecommendationsHelper.getIsUserInClassic();
        //VH 08/24/2019 - commented out getPermissionToAccess reference
        //Boolean userHavePermission = siteContentRecommendationsHelper.getPermissionToAccess();        
        
        String jsonFormattedData2 ='[{"guid":"11192","siteContentId":"null","title":"Test Insight","url":"https://eabwpedevelop.wpengine.com/?p=192","webProgramAccessIds":["311"]}]';
       
        //Method that search for Contact.
        siteContentRecommendationsHelper.searchDataForLookUp('Test', new List<String>(), 'Account', jsonFormattedData2);
       
        Test.startTest();  
        String selectedAcc = '[{"id":"'+ acc[0].Id + '","sObjectType":"Account","icon":"standard:account","title":"Syracuse University - Syracuse - NY","subtitle":"Syracuse University"}]';
        
        //Site Profile content Recommendations creation method that needs to be called directly. (From page it is called by Save button)
		siteContentRecommendationsHelper.createSiteContentRecommendationsForMultipleAccounts(selectedAcc, jsonFormattedData2);
		
        Test.StopTest();
    }
}