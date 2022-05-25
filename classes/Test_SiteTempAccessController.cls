//Modified by - Rajeev Jain - 11/08/2017 - Too many SOQL Error fix(Rev Mgmt 606 deployment to prod) - Applied by pass trigger flag and reset start and stop test flag on testTempAccessController_Save method
//Modified by -Dipesh Gupta - 2/22/2017 -Q2C enhacement bugs
//Code Coverage => 81%
//Modifed By Dipesh Gupta - CR-20190726-13240 - 08/06/2019 - Remove the reference of Temporary_Program_Access__c
//Modified By - Chirag Soni - 04/14/2022 - CR-20220310-16004 - Updated methods testTempAccessController_Save - Commented references for zzzAdvAdmin_ManageSubscriptions vf page 
@isTest
public class Test_SiteTempAccessController {
    
    /**
     * @description:	
     * 
     **/
    static testMethod void testSiteTempAccessController() {
        
        Id USHCIC = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'External'].Id;
        // setup an account and contact
        Account a = Test_SiteUserHelper.createNewAccount(false);
        a.RecordTypeId = USHCIC;
        insert a;
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(a, SiteUserHelper.SITE_ADVISORY, true);
        
        //get the site profile and contact info
        sProfile = [SELECT Id, Contact__c FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
        test.startTest();
        
        // create a new program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Applicable_Segments__c = 'US HCIC';
        prog.Create_memberships__c = 'Yes';
        insert prog;
        test.stopTest();
        
        List<Membership__c> memberships = [SELECT Id, Membership_Status__c FROM Membership__c WHERE Account_Name__c = :a.Id];
       // system.assertNotEquals(0, memberships.size());
        //system.assertEquals(memberships[0].Membership_Status__c, 'Prospect - Pure');
        
        // create a web program record
        Web_Program_Access__c webProg = new Web_Program_Access__c();
        webProg.A_com_Program_Id__c = 123;
        webProg.Advisory_com_CS_Role__c = 'abc';
        webProg.Description__c = 'test';
        insert webProg;
        
        // create a web program record
        Web_Program_Access__c webProg2 = new Web_Program_Access__c();
        webProg2.A_com_Program_Id__c = 222;
        webProg2.Advisory_com_CS_Role__c = 'abc';
        webProg2.Description__c = 'test';
        insert webProg2;
        
        // create a web program access MtM record
        Web_Program_Access_MTM__c webMtM = new Web_Program_Access_MTM__c();
        webMtM.Membership_Program__c = prog.Id;
        webMtM.Web_Program__c = webProg.Id;
        insert webMtM;
        
        // create a web program access MtM record
        Web_Program_Access_MTM__c webMtM2 = new Web_Program_Access_MTM__c();
        webMtM2.Membership_Program__c = prog.Id;
        webMtM2.Web_Program__c = webProg2.Id;
        insert webMtM2;
        
        //Comment out the SiteTempAccess Page - CR-20190726-13240 - 08/06/2019 - Remove the reference of Temporary_Program_Access__c
        // set the page reference
        /*PageReference pageRef = Page.SiteTempAccess;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('Id', sProfile.Contact__c);
        
        // instantiate the controller
        SiteTempAccessController controller = new SiteTempAccessController();
        
        //system.assertEquals(1, controller.mapTempAccess.get(SiteTempAccessController.STRING_ADVISORY).size());*/
    }
    
    /**
     * description: 	Create a site profile and save temp access
     * 
     **/
    static testMethod void testTempAccessController_Save() {
    	
        //Bypass the entity population Logic  
     	Util.bypassEntityPopulation = true;
        
        //By Pass All other trigger which are not needed to run here
        Util.ByPassAllTriggers = true;
        
    	// setup an account and contact
        Id USHCIC = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'External'].Id;
        Account a = Test_SiteUserHelper.createNewAccount(false);
        a.RecordTypeId = USHCIC;
        insert a;
        
        //create 2 site profiles associated with the same Contact (one for EAB, one for Advisory)
        //Site_Profile__c sProfile_Advisory = Test_SiteUserHelper.createSiteProfile(a, SiteUserHelper.SITE_ADVISORY, false);
        Site_Profile__c sProfile_EAB = Test_SiteUserHelper.createSiteProfile(a, SiteUserHelper.SITE_EAB, false);
        //sProfile_EAB.Contact__c = sProfile_Advisory.Contact__c;
        //sProfile_EAB.Username__c = sProfile_Advisory.Username__c;
        list<Site_Profile__c> sProfileList = new list<Site_Profile__c> {  sProfile_EAB };
        insert sProfileList;
        
        Util.ByPassAllTriggers = false;
        
        // create 2 new programs
        Program__c prog_Advisory = TestUtilities.CreateNewProgram(false);
        prog_Advisory.Applicable_Segments__c = 'US HCIC';
        prog_Advisory.Create_memberships__c = 'Yes';
        Program__c prog_EAB = TestUtilities.CreateNewProgram(false);
        prog_EAB.Program_Acronym__c = 'HICA';
        prog_EAB.Applicable_Segments__c = 'US Education';
        prog_EAB.Create_memberships__c = 'Yes';
        
        list<Program__c> progs = new list<Program__c> { prog_Advisory, prog_EAB };
        
        test.startTest();
        Util.ByPassAllTriggers = true;
        insert progs;
        Util.ByPassAllTriggers = false;
        test.stopTest();
        
        //insert a membership for the EAB Program
        Membership__c m = TestUtilities.CreateNewMembership(a.Id, prog_EAB.Id, true);
        
        //create a web program for the EAB program
        Util.ByPassAllTriggers = true;
        Web_Program_Access_MTM__c wpa_EAB = Test_SiteUserHelper.CreateWebProgramAccessMtM(null, false);
        wpa_EAB.Membership_Program__c = prog_EAB.Id;
        insert wpa_EAB;
        Util.ByPassAllTriggers = false;
        
        // create a web program record
        Web_Program_Access__c webProg = new Web_Program_Access__c();
        webProg.A_com_Program_Id__c = 125;
        webProg.Advisory_com_CS_Role__c = 'abc';
        webProg.Description__c = 'test';
        insert webProg;
        
        // create a web program record
        Web_Program_Access__c webProg2 = new Web_Program_Access__c();
        webProg2.A_com_Program_Id__c = 222;
        webProg2.Advisory_com_CS_Role__c = 'abc';
        webProg2.Description__c = 'test';
        insert webProg2;
        
        // create a web program access MtM record
        Web_Program_Access_MTM__c webMtM = new Web_Program_Access_MTM__c();
        webMtM.Membership_Program__c = prog_Advisory.Id;
        webMtM.Web_Program__c = webProg.Id;
        insert webMtM;
        
        // create a web program access MtM record
        Web_Program_Access_MTM__c webMtM2 = new Web_Program_Access_MTM__c();
        webMtM2.Membership_Program__c = prog_Advisory.Id;
        webMtM2.Web_Program__c = webProg2.Id;
        insert webMtM2;
        
        //Modified By - Chirag Soni - 04/14/2022 - CR-20220310-16004 -commented AdvAdmin_TemporaryAccess page reference  
        // set the page reference
        //PageReference pageRef = Page.AdvAdmin_TemporaryAccess;
        //Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('Id', sProfile_EAB.Contact__c);
        
        // instantiate the controller
        SiteTempAccessController controller = new SiteTempAccessController();
        
        //verify our EAB program is in the list
        system.assertEquals(1, controller.mapTempAccess.get(SiteTempAccessController.STRING_EAB).size());
        
        // give access to the web program
       // controller.mapTempAccess.get(SiteTempAccessController.STRING_ADVISORY)[0].HasAccess = true;
        //controller.mapTempAccess.get(SiteTempAccessController.STRING_ADVISORY)[0].StartDate = system.today().addDays(-1).format();
        //controller.mapTempAccess.get(SiteTempAccessController.STRING_ADVISORY)[0].Expiration_Date = system.today().addDays(1).format();
        //controller.SaveTempAccess();

        // verify both temp access records are on the contact
        //List<Temporary_Program_Access__c> tempAccessList = [SELECT Id, Web_Program__c FROM Temporary_Program_Access__c WHERE Contact__c = :sProfile_EAB.Contact__c];

		////Modified by -Dipesh Gupta - 2/22/2017 -Q2C enhacement bugs 
        //system.assertEquals(2, tempAccessList.size());
    }   
    
    /**
     * description: 	1. Create a site profile + temp access
     * 					2. Remove temp access
     * 					3. Verify temp access is accurate
     * 
     **/
    static testMethod void testTempAccessController_Delete() {
        Id USHCIC = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'External'].Id;
        // setup an account and contact
        Account a = Test_SiteUserHelper.createNewAccount(false);
        a.RecordTypeId = USHCIC;
        insert a;
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(a, SiteUserHelper.SITE_ADVISORY, true);
        
        //get the site profile and contact info
        sProfile = [SELECT Id, Contact__c FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
        test.startTest();
        
        // create a new program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Applicable_Segments__c = 'US HCIC';
        prog.Create_memberships__c = 'Yes';
        insert prog;
        test.stopTest();
        
        // create a web program record
        Web_Program_Access__c webProg = new Web_Program_Access__c();
        webProg.A_com_Program_Id__c = 123;
        webProg.Advisory_com_CS_Role__c = 'abc';
        webProg.Description__c = 'test';
        insert webProg;
        
        // create a web program record
        Web_Program_Access__c webProg2 = new Web_Program_Access__c();
        webProg2.A_com_Program_Id__c = 222;
        webProg2.Advisory_com_CS_Role__c = 'abc';
        webProg2.Description__c = 'test';
        insert webProg2;
        
        // create a web program access MtM record
        Web_Program_Access_MTM__c webMtM = new Web_Program_Access_MTM__c();
        webMtM.Membership_Program__c = prog.Id;
        webMtM.Web_Program__c = webProg.Id;
        insert webMtM;
        
        // create a web program access MtM record
        Web_Program_Access_MTM__c webMtM2 = new Web_Program_Access_MTM__c();
        webMtM2.Membership_Program__c = prog.Id;
        webMtM2.Web_Program__c = webProg2.Id;
        insert webMtM2;
        
        //Modified By - Chirag Soni - 04/14/2022 - CR-20220310-16004 -commented AdvAdmin_TemporaryAccess page reference 
        // set the page reference
        //PageReference pageRef = Page.AdvAdmin_TemporaryAccess;
        //Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('Id', sProfile.Contact__c);
        
        // instantiate the controller
        SiteTempAccessController controller = new SiteTempAccessController();
        
        // give access to the web program
        //controller.mapTempAccess.get(SiteTempAccessController.STRING_EAB)[0].HasAccess = true;
        //controller.mapTempAccess.get(SiteTempAccessController.STRING_EAB)[0].StartDate = system.today().addDays(-1).format();
        //controller.mapTempAccess.get(SiteTempAccessController.STRING_EAB)[0].Expiration_Date = system.today().addDays(1).format();
        //controller.SaveTempAccess();
        
        //controller.mapTempAccess.get(SiteTempAccessController.STRING_EAB)[0].HasAccess = false;
        //controller.SaveTempAccess();
        
        // verify both temp access records are on the contact
        List<Temporary_Program_Access__c> tempAccessList = [SELECT Id, Web_Program__c FROM Temporary_Program_Access__c WHERE Contact__c = :sProfile.Contact__c];
        system.assertEquals(0, tempAccessList.size());
    }
    
    /**
     * description: 	1. Create a site profile + temp access
     * 					2. Verify temp access is accurate
     * 
     **/
    static testMethod void testTempAccessController_ExistingTempAccess() {
        Id USHCIC = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'External'].Id;
        // setup an account and contact
        Account a = Test_SiteUserHelper.createNewAccount(false);
        a.RecordTypeId = USHCIC;
        insert a;
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(a, SiteUserHelper.SITE_ADVISORY, true);
        
        //get the site profile and contact info
        sProfile = [SELECT Id, Contact__c FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
        test.startTest();
        
        // create a new program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Applicable_Segments__c = 'US HCIC';
        prog.Create_memberships__c = 'Yes';
        insert prog;
        test.stopTest();
        
        // create a web program record
        Web_Program_Access__c webProg = new Web_Program_Access__c();
        webProg.A_com_Program_Id__c = 123;
        webProg.Advisory_com_CS_Role__c = 'abc';
        webProg.Description__c = 'test';
        insert webProg;
        
        // create a web program record
        Web_Program_Access__c webProg2 = new Web_Program_Access__c();
        webProg2.A_com_Program_Id__c = 222;
        webProg2.Advisory_com_CS_Role__c = 'abc';
        webProg2.Description__c = 'test';
        insert webProg2;
        
        // create a web program access MtM record
        Web_Program_Access_MTM__c webMtM = new Web_Program_Access_MTM__c();
        webMtM.Membership_Program__c = prog.Id;
        webMtM.Web_Program__c = webProg.Id;
        insert webMtM;
        
        // create a web program access MtM record
        Web_Program_Access_MTM__c webMtM2 = new Web_Program_Access_MTM__c();
        webMtM2.Membership_Program__c = prog.Id;
        webMtM2.Web_Program__c = webProg2.Id;
        insert webMtM2;
        
         //Modifed By Dipesh Gupta - CR-20190726-13240 - 08/06/2019 - Remove the reference of Temporary_Program_Access__c
        // create a temp access record for the contact
        /*Temporary_Program_Access__c tempAccess1 = new Temporary_Program_Access__c();
        tempAccess1.Web_Program__c = webMtM.Id;
        tempAccess1.Contact__c = sProfile.Contact__c;
        tempAccess1.Start_Date__c = system.now().addDays(-2);
        tempAccess1.End_Date__c = system.now().addDays(1);
        insert tempAccess1;
        
        // create a temp access record for the contact
        Temporary_Program_Access__c tempAccess2 = new Temporary_Program_Access__c();
        tempAccess2.Web_Program__c = webMtM2.Id;
        tempAccess2.Contact__c = sProfile.Contact__c;
        tempAccess2.Start_Date__c = system.now().addDays(-2);
        tempAccess2.End_Date__c = system.now().addDays(1);
        insert tempAccess2;*/
        
        //Modified By - Chirag Soni - 04/14/2022 - CR-20220310-16004 -commented AdvAdmin_TemporaryAccess page reference 
        // set the page reference
        //PageReference pageRef = Page.AdvAdmin_TemporaryAccess;
        //Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('Id', sProfile.Contact__c);
        
        // instantiate the controller
        SiteTempAccessController controller = new SiteTempAccessController();
        controller.FindAccess();
        
        // verify that the start date is not editable
        //system.assertEquals(null, controller.mapTempAccess.get(SiteTempAccessController.STRING_ADVISORY)[0].StartIsEditable);
        
    }
    
    //Added By Ajit Surana -02/15/2014 - CR-20130528-3087
    /**
     * description: 	1. Create a site profile + temp access
     * 					2. Verify temp access is accurate
     * 
     **/
    static testMethod void testCreateTempProgAccessForUniqueProgramAcronym() {          
      	
        Util.BypassAllTriggers = true;
        
        Id USHCIC = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'External'].Id;
        // setup an account and contact
        Account a = Test_SiteUserHelper.createNewAccount(false);
        a.RecordTypeId = USHCIC;
        insert a;
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(a, SiteUserHelper.SITE_ADVISORY, true);
        
        //get the site profile and contact info
        sProfile = [SELECT Id, Contact__c FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
        //Create a new program
        Program__c program1 = TestUtilities.CreateNewProgram(false);
        program1.Name = 'Tested - Test-Program1';
        program1.Status__c = 'Active';
        program1.Program_Formal_Name__c = 'Test-Program1';
        program1.Applicable_Segments__c = 'US HCIC';
        program1.Create_memberships__c = 'Yes';
        program1.Program_Acronym__c = 'Test';
        insert program1;
      
        //Create a new program
        Program__c program2 = TestUtilities.CreateNewProgram(false);
        program2.Name = 'Test - Test-Program2';
        program2.Status__c = 'Active';
        program2.Program_Formal_Name__c = 'Test-Program2';
        program2.Applicable_Segments__c = 'US HCIC';
        program2.Create_memberships__c = 'Yes';
        program2.Program_Acronym__c = 'Tested';
        insert program2;
      
        //Insert Membership record
        Membership__c membership1 = TestUtilities.CreateNewMembership(a.Id, program1.Id, true);
        Membership__c membership2 = TestUtilities.CreateNewMembership(a.Id, program2.Id, true);
      
        //Create a web program record
        Web_Program_Access__c webProgram1 = new Web_Program_Access__c(Name = 'WP1', A_com_Program_Id__c = 901, Advisory_com_CS_Role__c = 'QA', Description__c = 'test');
        insert webProgram1;
      
        //Create a web program record
        Web_Program_Access__c webProgram2 = new Web_Program_Access__c(Name = 'WP2', A_com_Program_Id__c = 902, Advisory_com_CS_Role__c = 'QA1', Description__c = 'test WP');
        insert webProgram2;
        
        //Create a web program record
        Web_Program_Access__c webProgram3 = new Web_Program_Access__c(Name = 'WP2', A_com_Program_Id__c = 322, Advisory_com_CS_Role__c = 'QA2', Description__c = 'testing');
        insert webProgram3;
        
        //Create a web program access MtM record
        Web_Program_Access_MTM__c webMtM1 = new Web_Program_Access_MTM__c(Membership_Program__c = program1.Id, Web_Program__c = webProgram1.Id);
        insert webMtM1;
      
        //Create a web program access MtM record     
        Web_Program_Access_MTM__c webMtM2 = new Web_Program_Access_MTM__c(Membership_Program__c = program2.Id, Web_Program__c = webProgram2.Id);
        insert webMtM2;
        
        //Create a web program access MtM record     
        Web_Program_Access_MTM__c webMtM3 = new Web_Program_Access_MTM__c(Membership_Program__c = program2.Id, Web_Program__c = webProgram3.Id);
        insert webMtM3;
        
        //Cretae Temporary Program Access record
        //Temporary_Program_Access__c tempAccess1 = Test_SiteUserHelper.CreateTempProgAccess(webMtM1.Id, sProfile, true);
        //Temporary_Program_Access__c tempAccess2 = Test_SiteUserHelper.CreateTempProgAccess(webMtM2.Id, sProfile, true);
        
        Util.BypassAllTriggers = false;
        
        //Test starts from here
        Test.startTest();
        
        //Modified By - Chirag Soni - 04/14/2022 - CR-20220310-16004 -commented AdvAdmin_TemporaryAccess page reference 
        //Set the page reference
        //PageReference pageRef = Page.AdvAdmin_TemporaryAccess;
        //Test.setCurrentPage(pageRef);
        
        //Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('Id', sProfile.Contact__c);
        
        //Instantiate the controller
        SiteTempAccessController controller = new SiteTempAccessController();
      
        //Give access to the web program
       /* controller.mapTempAccess.get(SiteTempAccessController.STRING_ADVISORY)[0].HasAccess = true;
        controller.mapTempAccess.get(SiteTempAccessController.STRING_ADVISORY)[0].StartDate = system.today().addDays(-1).format();
        controller.mapTempAccess.get(SiteTempAccessController.STRING_ADVISORY)[0].Expiration_Date = system.today().addDays(1).format(); 
        */
        //controller.SaveTempAccess();    
           
        //Verify both temp access records are on the contact    
        /*List<Temporary_Program_Access__c> tempAccessList = [SELECT Id, Web_Program__c FROM Temporary_Program_Access__c WHERE Contact__c = :sProfile.Contact__c];
        System.assertEquals(2, tempAccessList.size());*/
      
        //Test stops here
        test.stopTest();
    }
}