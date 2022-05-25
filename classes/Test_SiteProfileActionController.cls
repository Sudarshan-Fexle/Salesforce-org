/**
Desription      :   unit tests for the SiteProfileResetPasswordController class

Created By      :   Victor Hanson

Created Date    :   08/26/2014

Revision Logs   :   v1 - Created
					v2
**/ 
@isTest
public class Test_SiteProfileActionController {
	
    public final static Id SITE_PROFILE_RT_ID_ACTIVE = Schema.SObjectType.Site_Profile__c.RecordTypeInfosByName.get('EAB and Advisory').RecordTypeId;
    public final static Id SITE_PROFILE_RT_ID_ROYALL = Schema.SObjectType.Site_Profile__c.RecordTypeInfosByName.get('MyRoyall').RecordTypeId;
    public final static Id SITE_PROFILE_RT_ID_INACTIVE = Schema.SObjectType.Site_Profile__c.RecordTypeInfosByName.get('Inactive').RecordTypeId;
    
    /**
     * @description: 	Step 1: Create a Contact, Site User, and Site Profile with eligible domain for Advisory.com
     * 					Step 2: Go to the SiteProfileQuickAction VF Page with parameter to deactivate the site profile
     * 					Step 3: Verify that the site profile was successfully activated
     **/
    static testmethod void testActivateUser() {
        //Modified by - Subhash garhwal - 02/22/2018 - Solve the production test failures
        //setup the sitecore settings 
        Sitecore_Settings__c settings = new Sitecore_Settings__c(EAB_com_SF_URL__c = 'https://www.eab.com/');
        insert settings;
        
        // setup an account and contact
        Account acct = Test_SiteUserHelper.createNewAccount(true);
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(acct, SiteUserHelper.SITE_EAB, false);
        sProfile.Status__c = 'Inactive';
        insert sProfile;
        // set the page reference
        PageReference pageRef = Page.SiteProfileQuickAction;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('id', sProfile.Id);
        ApexPages.currentPage().getParameters().put('Action', SiteProfileActionController.QUICK_ACTION_ACTIVATE);
        
        // site profile action controller
        SiteProfileActionController controller = new SiteProfileActionController();
        controller.execute();
        
        system.debug('@@ApexPages.getMessages():' + ApexPages.getMessages());
        system.assertEquals(new list<ApexPages.Message>(), ApexPages.getMessages());
        system.assertEquals(0, ApexPages.getMessages().size());
        
        //get the updated site profile and verify it has been activated
        sProfile = [SELECT Id, Status__c, Password__c, Status_Code__c, RecordTypeId FROM Site_Profile__c WHERE Id = :sProfile.Id];
        system.assertEquals(SiteProfileTriggerHelper.SITE_PROFILE_STATUS_IN_PROGRESS, sProfile.Status__c);
        //system.assertEquals('R3', sProfile.Status_Code__c);
        system.assertEquals(SITE_PROFILE_RT_ID_ACTIVE, sProfile.RecordTypeId);
    }
    
    /**
     * @description: 	Step 1: Create a Contact, Site User, and Site Profile with eligible domain for Advisory.com
     * 					Step 2: Go to the SiteProfileQuickAction VF Page with parameter to deactivate the site profile
     * 					Step 3: Verify that the site profile was successfully deactivated
     **/
    static testmethod void testDeactivateUser() {
        
        //setup the sitecore settings
        Sitecore_Settings__c settings = new Sitecore_Settings__c(Advisory_com_SF_URL__c = 'https://www.advisory.com/');
        insert settings;
        
        // setup an account and contact
        Account acct = Test_SiteUserHelper.createNewAccount(true);
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(acct, SiteUserHelper.SITE_ADVISORY, true);
        // set the page reference
        PageReference pageRef = Page.SiteProfileQuickAction;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('id', sProfile.Id);
        ApexPages.currentPage().getParameters().put('Action', SiteProfileActionController.QUICK_ACTION_DEACTIVATE);
        
        // site profile action controller
        SiteProfileActionController controller = new SiteProfileActionController();
        controller.execute();
        
        system.debug('@@ApexPages.getMessages():' + ApexPages.getMessages());
        system.assertEquals(0, ApexPages.getMessages().size());
        
        //get the updated site profile and verify it has been deactivated
        sProfile = [SELECT Id, Status__c, Password__c, Status_Code__c, RecordTypeId FROM Site_Profile__c WHERE Id = :sProfile.Id];
        system.assertEquals(SiteProfileTriggerHelper.SITE_PROFILE_STATUS_INACTIVE, sProfile.Status__c);
        system.assertEquals('E2', sProfile.Status_Code__c);
        system.assertEquals(SITE_PROFILE_RT_ID_INACTIVE, sProfile.RecordTypeId);
    }
    
    /**
     * @description: 	Step 1: Create a Contact, Site User, and Site Profile with eligible domain for Advisory.com
     * 					Step 2: Go to the SiteProfileQuickAction VF Page
     * 					Step 3: Verify that the site profile's password reset email is sent and web service log confirms it was sent.
     **/
    static testmethod void testSendPasswordReset() {
        
        //setup the sitecore settings
        Sitecore_Settings__c settings = new Sitecore_Settings__c(Advisory_com_SF_URL__c = 'https://www.advisory.com/');
        insert settings;
        
        // setup an account and contact
        Account acct = Test_SiteUserHelper.createNewAccount(true);
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(acct, SiteUserHelper.SITE_ADVISORY, true);
        // set the page reference
        PageReference pageRef = Page.SiteProfileQuickAction;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('id', sProfile.Id);
        ApexPages.currentPage().getParameters().put('Action', SiteProfileActionController.QUICK_ACTION_PASSWORD_RESET);
        
        // site profile action controller
        SiteProfileActionController controller = new SiteProfileActionController();
        
        //setup the encrypted callout info and send to the site controller
        SiteController siteController = new SiteController();
        
        SiteUser sUser = SiteUserHelper.getSiteUser(controller.encryptedRequest);
        siteController.sUser = sUser;
        siteController.initialize();
        
        controller.body = siteController.JSONResponse;
        controller.execute();
        
        system.debug('@@ApexPages.getMessages():' + ApexPages.getMessages());
        system.assertEquals(0, ApexPages.getMessages().size());
        
        //get the web service logs and make sure the requested by value = current user's email
        list<Web_Service_Log__c> wsLogs = [SELECT Id, Requested_By__c, Response_Message__c, Web_Service_Method__c FROM Web_Service_Log__c WHERE Site_Profile__c = :sProfile.Id];
        system.assertEquals(1, wsLogs.size());
        system.assertEquals(SiteUserHelper.RESPONSE_SUCCESS, wsLogs[0].Response_Message__c);
        system.assertEquals(UserInfo.getUserEmail(), wsLogs[0].Requested_By__c);
    }
    
    /**
     * @description: 	Step 1: Create a Contact, Site User, and Site Profile with eligible domain for Advisory.com
     * 					Step 2: Make the contact's email hard-bounce
     * 					Step 3: Go to the SiteProfileQuickAction VF Page
     * 					Step 4: Verify that no reset password email was able to be sent due to the hard bounce status.
     **/
    static testmethod void testSendPasswordReset_HardBounce() {
        
        //setup the sitecore settings
        Sitecore_Settings__c settings = new Sitecore_Settings__c(Advisory_com_SF_URL__c = 'https://www.advisory.com/');
        insert settings;
        
        // setup an account and contact
        Account acct = Test_SiteUserHelper.createNewAccount(true);
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(acct, SiteUserHelper.SITE_ADVISORY, true);
        
        //set the contact's eloqua hard bounce email to the current email - essentially making the Site Profile's status = Hard Bounce
        Contact c = [SELECT Id, Email FROM Contact WHERE Id = :sProfile.Contact__c];
        //c.Eloqua_Hard_Bounce_Email__c = c.Email;
        Util.BypassAllTriggers = false;
        SiteProfileTriggerHelper.bypassSiteProfileTrigger = false;
        update c;
        
        //get the site profile and verify the status was updated to hard bounce
        sProfile = [SELECT Id, Status__c FROM Site_Profile__c WHERE Id = :sProfile.Id];
        //system.assertEquals(SiteProfileTriggerHelper.SITE_PROFILE_STATUS_HARD_BOUNCE, sProfile.Status__c);
        
        // set the page reference
        PageReference pageRef = Page.SiteProfileQuickAction;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('id', sProfile.Id);
        ApexPages.currentPage().getParameters().put('Action', SiteProfileActionController.QUICK_ACTION_PASSWORD_RESET);
        
        // site profile action controller
        SiteProfileActionController controller = new SiteProfileActionController();
        /*
        //setup the encrypted callout info and send to the site controller
        SiteController siteController = new SiteController();
        
        SiteUser sUser = SiteUserHelper.getSiteUser(controller.encryptedRequest);
        siteController.sUser = sUser;
        siteController.initialize();
        
        controller.body = siteController.JSONResponse;*/
        
        controller.execute();
        
        system.debug('@@ApexPages.getMessages():' + ApexPages.getMessages());
        //system.assertEquals(1, ApexPages.getMessages().size(), 'There should be an error returned due to the fact that the Status is Hard Bounce.');
        //system.assertEquals('Cannot reset password for a Site Profile with a Hard Bounce Email', ApexPages.getMessages()[0].getDetail());
    }
    
    /**
     * @description: 	Step 1: Create a Contact, Site User, and Site Profile with eligible domain for Advisory.com
     * 					Step 2: Make site profile's status inactive
     * 					Step 3: Go to the SiteProfileQuickAction VF Page
     * 					Step 4: Verify that no reset password email was able to be sent due to the inactive status.
     **/
    static testmethod void testSendPasswordReset_Inactive() {
        
        //setup the sitecore settings
        Sitecore_Settings__c settings = new Sitecore_Settings__c(Advisory_com_SF_URL__c = 'https://www.advisory.com/');
        insert settings;
        
        // setup an account and contact
        Account acct = Test_SiteUserHelper.createNewAccount(true);
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(acct, SiteUserHelper.SITE_ADVISORY, true);
        
        //set the contact status to inactive
        Contact c = [SELECT Id, Email, Contact_Status__c FROM Contact WHERE Id = :sProfile.Contact__c];
        c.Contact_Status__c = 'Inactive - Moved Institutions';
        Util.BypassAllTriggers = false;
        SiteProfileTriggerHelper.bypassSiteProfileTrigger = false;
        update c;
        
        // set the page reference
        PageReference pageRef = Page.SiteProfileQuickAction;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('id', sProfile.Id);
        ApexPages.currentPage().getParameters().put('Action', SiteProfileActionController.QUICK_ACTION_PASSWORD_RESET);
        
        // site profile action controller
        SiteProfileActionController controller = new SiteProfileActionController();
        
        //setup the encrypted callout info and send to the site controller
        SiteController siteController = new SiteController();
        
        SiteUser sUser = SiteUserHelper.getSiteUser(controller.encryptedRequest);
        siteController.sUser = sUser;
        siteController.initialize();
        
        controller.body = siteController.JSONResponse;
        controller.execute();
        
        system.debug('@@ApexPages.getMessages():' + ApexPages.getMessages());
        system.assertEquals(1, ApexPages.getMessages().size(), 'There should be an error returned due to the fact that the Contact Status is Inactive.');
        system.assertEquals('Cannot reset password for a Site Profile associated with an Inactive contact', ApexPages.getMessages()[0].getDetail());
    }
    
}