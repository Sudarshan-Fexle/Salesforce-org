/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest(seeAllData=false)
private class Test_SiteUser {
    
    /**
        Purpose         :   Test class for SiteUser Class
                    
        Create By       :   Abhinav Sharma
        
        Created Date    :   12/11/2015
        
        Revision Log    :   v1.0 - Created - Abhinav Sharma - CR-20151118-9393 - 12/11/2015 - 100% code coverage
							v1.01 - Modified By - Seemu Saikia -CR-20190501-13072- 05/08/2019 - #Spring CleanUp
                        :   Modifed By Dipesh Gupta - CR-20190726-13240 - 08/06/2019 - Remove the reference of Temporary_Program_Access__c
    **/

    //Common test data setup for entire test class
    @testSetup static void setup() {
        
        //Bypassing triggers
        Util.isTest(true);
        Util.byPassAllTriggers = true;
    	
        //Create test data
        Account account = Test_SiteUserHelper.createNewAccount(true);
        
        //Program
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //Contract
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = account.Id, Program__c = program.Id, 
                                               	Start__c = System.Today().addDays(-10), 
                                                End__c = System.Today().addDays(355));
        insert contract;
        
        //Membership
        Membership__c member = new Membership__c(Name = 'Test Membership', Account_Name__c = account.Id, Program__c = program.Id, 
                                                    Active_Contract_Idenfied__c = contract.Id);
        insert member;
        
        //Site Profile
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(account, SiteUserHelper.SITE_EAB, false);
        sProfile.Bypass_Domain_Validation__c = true;
        insert sProfile;
        
        //Contact
        Contact contact = [SELECT Id, Name FROM Contact WHERE Id = :sProfile.Contact__c];
        
        //Subscription_Option__c record
        //Spring CleanUp
        //Subscription_Option__c sOption = new Subscription_Option__c(Name = 'Test');
        //insert sOption;
        
        //Insert Subscription record
        //Eligible_Subscription_Option__c eSOption = new Eligible_Subscription_Option__c(Program__c = program.Id,Related_Subscription__c = sOption.Id);
        //insert eSOption;
        
        //Create a web program record
        Web_Program_Access__c webProg = new Web_Program_Access__c();
        webProg.A_com_Program_Id__c = 123;
        webProg.Advisory_com_CS_Role__c = 'abc';
        webProg.Description__c = 'test';
        webProg.Program_Code_to_Member__c = 'test';
        insert webProg;
        
        // create a web program access MtM record
        Web_Program_Access_MTM__c webMtM = new Web_Program_Access_MTM__c();
        webMtM.Membership_Program__c = program.Id;
        webMtM.Web_Program__c = webProg.Id;
        insert webMtM;
		
        //temporary program access
		// create a temp access record for the contact
      /*  Temporary_Program_Access__c tempAccess1 = new Temporary_Program_Access__c();
        tempAccess1.Web_Program__c = webMtM.Id;
        tempAccess1.Contact__c = sProfile.Contact__c;
        tempAccess1.Start_Date__c = system.now().addDays(-2);
        tempAccess1.End_Date__c = system.now().addDays(1);
        insert tempAccess1;*/
    }
    
    //test method to get the desired coverage for the siteuser class 
    //because this class is basically there to hold various variables and properties related to Adv.com/EAB.com site funcationlity.
    //Modified By - Seemu Saikia -CR-20190501-13072- 05/08/2019 - #Spring CleanUp

    @isTest static void testUnitCases() {
        
        //Bypassing triggers
        Util.isTest(true);
        Util.byPassAllTriggers = true;
        
        //Start test from here
        Test.startTest();
        
        //Calling constructor
        SiteUser controller = new SiteUser();
            
        //Setting a value for the class string variables
        controller.accountStatus = 'Test';
        controller.accountRecordType = 'Test';
        controller.accountFormalName = 'Test';
        controller.strategicAccountSegment = 'Test';
        controller.ProviderType = 'Test';
        controller.BedSize = 'Test';
        controller.RMRI = 'Test';
        controller.Principal = 'Test';
        controller.Site = 'Test';
        controller.UniqueId = 'Test';
        controller.InstitutionUniqueId = 'Test';
        controller.Username = 'Test';
        controller.PasswordResetUrl = 'Test';
        controller.Phone = 'Test';
        controller.Response = 'Test';
        controller.Old_User_Id = 'Test';
        controller.Password = 'Test';
        controller.Job_Function = 'Test';
        controller.Department = 'Test';
        controller.EAB_Department = 'Test';
        controller.EAB_Role = 'Test';
        controller.First_Name = 'Test';
        controller.Middle_Initial = 'Test';
        controller.Last_Name = 'Test';
        controller.Prefix = 'Test';
        controller.Suffix = 'Test';
        controller.Title = 'Test';
        controller.Address1 = 'Test';
        controller.Address2 = 'Test';
        controller.Address3 = 'Test';
        controller.City = 'Test';
        controller.State = 'Test';
        controller.Zip = 'Test';
        controller.Country = 'Test';
        controller.Office_Phone = 'Test';
        controller.Office_Phone_Ext = 'Test';
        controller.Fax_Phone = 'Test';
        controller.Email_Address = 'Test';
        controller.User_Status = 'Test';
        controller.Last_Access = 'Test';
        controller.Created_By = 'Test';
        controller.Created_Date = 'Test';
        controller.Modified_By = 'Test';
        controller.Modified_Date = 'Test';
        controller.Role = 'Test';
        controller.Email_Address2 = 'Test';
        controller.Verify = 'Test';
        controller.Verify_Date = 'Test';
        controller.Command = 'Test';
        controller.Status_Code = 'Test';
        controller.SFDateTime = 'Test';
        controller.OneDayAccessGrantedDate = 'Test';
        controller.DomainStillValid = 'Test';
        controller.Org_Name = 'Test';
        controller.Organization_Status = 'Test';
        controller.Passcode = 'Test';
        controller.AccountManagerFullName = 'Test';
        controller.AccountManagerEmail = 'Test';
        controller.AccountManagerPhoneNumber = 'Test';
        controller.ChimpId = 'Test';
        controller.Browser_Type = 'Test';
        controller.ClientId = 'Test';
        controller.OrganizationName = 'Test';
        controller.ProgramId = 'Test';
        controller.Comments = 'Test';
        controller.LeadChannel = 'Test';
        controller.RequestPage = 'Test';
        controller.RequestURL = 'Test';
        controller.RequestObjectType = 'Test';
        controller.EndpointURL     = 'Test';
        controller.LinkedIn = 'Test';
        controller.Facebook = 'Test';
        controller.Twitter = 'Test';
        controller.Pinterest = 'Test';
        controller.NameTag = 'Test';
        controller.OrganizationNameTag = 'Test';
        controller.Interests     = 'Test';
        controller.Nickname = 'Test';
        controller.Mobile = 'Test';
        controller.ContactRecordType = 'Test';
        controller.SecondaryAddressName = 'Test';
        controller.SecondaryAddress1 = 'Test';
        controller.SecondaryAddress2 = 'Test';
        controller.SecondaryAddress3 = 'Test';
        controller.SecondaryCity = 'Test';
        controller.SecondaryState = 'Test';
        controller.SecondaryPostalCode = 'Test';
        controller.SecondaryCountry = 'Test';
        controller.Description = 'Test';
        controller.AccountId = 'Test';
        controller.Assistant = 'Test';
        controller.AssistantPhone = 'Test';
        controller.AssistantEmail = 'Test';
        controller.ReportsToId = 'Test';
        controller.PrevAccountId     = 'Test';
        controller.MicrositeID = 'Test';
        controller.PresentationID = 'Test';
        controller.EventID = 'Test';  
        
        //Setting a value for the class boolean variables
        controller.RegisterOther = false;
        controller.HasRegisteredAlready = false;
        controller.Temporary_User = false;
        controller.ProgressTracking = false;
        controller.RecognitionProgram = false;
        controller.ProgressTrackingNotification = false;
        controller.IgnoreLDD = false;
        controller.IsApproved = false;
        controller.IsOnline = false;
        controller.AuthenticateDomain = false;
        controller.OneDayAccessGranted = false;
        controller.Options_Change = false;
        controller.PasscodeSent = false;
        controller.Profile_Change = false;
        controller.ReAuthEmailSent = false;
        controller.ShareInformation = false;
        controller.ShareEmail = false;
        controller.ShareFacebook = false;
        controller.ShareFax = false;
        controller.SharePhone = false;
        controller.ShareLinkedIn = false;
        controller.SharePinterest = false;
        controller.ShareInterests = false;
        controller.ShareImage = false;
        controller.ShareTwitter = false;
        controller.EmailOptOut = false;
        
        //Setting a value for the class integer/decimal variables
        controller.User_Id = 1;
		controller.Organization_Id = 8;
		controller.PTRecognitionProgramId = 2;
        controller.rITDRenewalCV = 10.1;
        
        //Setting Wrapper class properties
        SiteUser.WebConference inner_cls_webconf = new SiteUser.WebConference();
        inner_cls_webconf.Name = 'test';
        inner_cls_webconf.URL = 'https://www.google.com';
        inner_cls_webconf.StartDate = String.valueOf(System.today());
        inner_cls_webconf.EndDate = String.valueOf(System.today().addDays(2));
        inner_cls_webconf.IsCanceled = false;
        inner_cls_webconf.Origin = 'test';
        inner_cls_webconf.MessageType = 'test';
        
        //Setting Wrapper class properties
        SiteUser.WebConferenceAttendee inner_cls_webconf_attendee = new SiteUser.WebConferenceAttendee();
        inner_cls_webconf_attendee.User_Id = 'Test';
        inner_cls_webconf_attendee.Prefix = 'Mr';
        inner_cls_webconf_attendee.FirstName = 'Test';
        inner_cls_webconf_attendee.LastName = 'Test';
        inner_cls_webconf_attendee.MiddleInitial = 'Test';
        inner_cls_webconf_attendee.Suffix = 'Test';
        inner_cls_webconf_attendee.Phone = '2583698502';
        inner_cls_webconf_attendee.Fax = '4569871235';
        inner_cls_webconf_attendee.Email = 'test5446657676@advisory.com';
        
        //Setting Wrapper class properties
        SiteUser.WebConferenceRegisteredBy inner_cls_webconf_registerBy = new SiteUser.WebConferenceRegisteredBy();
        inner_cls_webconf_registerBy.User_Id = 'Test';
        inner_cls_webconf_registerBy.Prefix = 'Mr';
        inner_cls_webconf_registerBy.FirstName = 'Test4545';
        inner_cls_webconf_registerBy.LastName = 'Test65656';
        inner_cls_webconf_registerBy.MiddleInitial = 'Test';
        inner_cls_webconf_registerBy.Suffix = 'Test';
        inner_cls_webconf_registerBy.Phone = '2583698502';
        inner_cls_webconf_registerBy.Fax = '4569871235';
        inner_cls_webconf_registerBy.Email = 'test54466576765657766@advisory.com';
        
        //List of Web_Program_Access_MTM__c
        List<Web_Program_Access_MTM__c> webProgramMtms = [SELECT ID, Adv_com_Program_Id__c, 
                                                          	Web_Program__r.Program_Code_to_Member__c, 
                                                          	Web_Program__r.Description__c
                                                         	FROM Web_Program_Access_MTM__c];
        
        //List of Temporary_Program_Access__c
       /* List<Temporary_Program_Access__c> tempProgramAccess = [SELECT ID, Site_Program_ID__c, 
                                                          		Web_Program__r.Web_Program__r.Program_Code_to_Member__c, 
                                                              	Web_Program__r.Web_Program__r.Description__c
                                                         		FROM Temporary_Program_Access__c]; */
        
        //Asserting for the results
        System.assert(webProgramMtms != null);
        System.assert(webProgramMtms.size() > 0);
        //System.assert(tempProgramAccess != null);
        //System.assert(tempProgramAccess.size() > 0);
        
        //Setting Wrapper class properties
        SiteUser.WebProgramAccess inner_cls_webconf_webprogramAccess = new SiteUser.WebProgramAccess(webProgramMtms[0]);
        //SiteUser.WebProgramAccess inner_cls_webconf_webprogramAccess_1 = new SiteUser.WebProgramAccess(tempProgramAccess[0]);
        
        //Setting wrapper instances
        controller.WebEvent = inner_cls_webconf;
        controller.Attendee = inner_cls_webconf_attendee;
        controller.RegisteredBy = inner_cls_webconf_registerBy;
        
        //getters
        Boolean domain_validation = controller.Bypass_Domain_Validation;
        List<Account> institution_List = controller.Institutions;
        List<SiteControllerHelper.ContactWrapper> wrap_List = controller.ContactWrappers;
		List<Meeting_Utilization__c> meetingUtilizationsList = controller.MeetingUtilizations;
        List<SiteUser.WebProgramAccess> webProgramAccessList = controller.webProgramAccessList;
        //SPring CLeanup
        //List<Eligible_Subscription_Option__c> eligibleSubscriptionsList = controller.EligibleSubscriptions;
        //Spring CleanUp
        //List<Subscription__c> subscriptionsList = controller.Subscriptions;
        //List<Temporary_Program_Access__c> temporaryProgramAccessList = controller.TemporaryProgramAccess;
        Site_User__c sU = controller.site_User;
        Site_Profile__c sP = controller.site_Profile;
   		List<Site_Profile__c> sProfiles = controller.site_Profiles;
        
        //Retrieving the site profile details
        sProfiles = [SELECT ID, Bypass_Domain_Validation__c FROM Site_Profile__c];
        
        //Asserting for the results
        System.assert(sProfiles != null);
        System.assert(sProfiles.size() > 0);
		
        //Calling getter
        controller.site_Profile = sProfiles[0];
        domain_validation = controller.Bypass_Domain_Validation;
        
        //Stop test here
        Test.stopTest();
    }        
}