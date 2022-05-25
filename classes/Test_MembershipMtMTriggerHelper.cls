//Modifed by - Saurabh Kumar - 10/10/2020 - CR-20200819-14447: Removed Meeting reference
@isTest(seeAllData=false)
public class Test_MembershipMtMTriggerHelper {
    
    static User usr = [select id from User where isActive = true AND UserType = 'Standard' limit 1];
    private static String meetingGUID = '000-000-001';
    
    /*
    Purpose         :   Test class for Trigger_MembershipMtM
                
    Create By       :   Saurabh Kumar
    
    Created Date    :   10/06/2020
    
    Current Version :   V1.0
    
    Revision Log    :   V1.0 - Created
    			V1.1 - Modified By - Chirag Soni - CR-20210510-15128 - initialize mock response
           
    Coverage        :   Trigger_MembershipMtM - 
                        MembershipMtMTriggerHelper - 
    */
	static testmethod void testUpdateRegistrationEligibility() { 
        
        // Modified By - Chirag Soni - CR-20210510-15128 - initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        util.bypassAllTriggers = true;
        
        //Create the new account record
        Account account = TestUtilities.CreateNewAccount(true);
        
        List<Contact> contacts = new List<Contact>();
        
        //Create the new contact record
        Contact contact = testUtilities.CreateNewContact(false);
        contact.AccountId = account.Id;
        contacts.add(contact);
        contact = testUtilities.CreateNewContact(false);
        contact.AccountId = account.Id;
        contacts.add(contact);
        contact = testUtilities.CreateNewContact(false);
        contact.AccountId = account.Id;
        contacts.add(contact);
        insert contacts;
        
        //Create the new program record
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //Create the new event record
        Advisory_Event__c eSeries = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        eSeries.Event_Type__c = 'Research Working Sessions';
        eSeries.Primary_Program__c  = program.Id;
        eSeries.Rules_Programs__c = 'Establish independent rules';
        eSeries.Event_Type__c = 'Research Working Sessions';
        eSeries.Public_Name__c = 'Test';
		eSeries.Short_Name__c = 'Test';
		eSeries.Status__c = 'Open - Registration';
		eSeries.Begins__c = System.today();
		eSeries.Ends__c = System.today();
        insert eSeries;
        
        //Create meetings that correspond to the advisory event structure that was just created
        /*Meeting__c parentMeeting = Test_SiteMeetingController.CreateMeeting(false);
        parentMeeting.EAB_Event__c = eSeries.Id;
        parentMeeting.Meeting_GUID__c = meetingGUID;
        insert parentMeeting;*/
	
        //Create the new rule record
        Rule__c rule = new Rule__c();
        rule.Advisory_Event__c = eSeries.Id;
        rule.Program__c = program.Id;
        rule.Primary__c = true;
        insert rule;
        
        //Create the new opp record
        Opportunity testOpp = TestUtilities.CreateNewOpportunity(account.Id, false);
        testOpp.Main_Contact__c = contact.Id;
        insert testOpp;
        
        test.startTest();
        
        //Create the new contract record
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = account.Id, Program__c = program.Id, 
            Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355),
            Contract_Renewal_Opportunity__c = testOpp.Id
            );
            
        insert testContract1;
        
        //Create the new Membership records
        List<Membership__c> memberships = new List<Membership__c>();
        Membership__c member1 = new Membership__c( Name = 'Test Membership 1', Account_Name__c = account.Id,
                                                   Program__c = program.Id, Active_Contract_Idenfied__c =
                                                   testContract1.Id, Membership_Status_Text__c = 'Member -001');
        memberships.add(member1);
        
        Membership__c member2 = new Membership__c( Name = 'Test Membership 2', Account_Name__c = account.Id,
            									   Program__c = program.Id, Assigned_Marketer__c = usr.Id,
                                                   Membership_Status_Text__c = 'Member -002');
        memberships.add(member2);
        insert memberships;
        
        //Create the new Registration Mtm records
        List<Registration__c> registrationsToCreate = new List<Registration__c>();
        Registration__c registration_01 = new Registration__c();
        registration_01.Contact__c = contacts[0].Id;
        //registration_01.Meeting__c = parentMeeting.Id;
        registration_01.EAB_Event__c = eSeries.Id;
        registrationsToCreate.add(registration_01);
        
        Registration__c registration_02 = new Registration__c();
        registration_02.Contact__c = contacts[1].Id;
        //registration_02.Meeting__c = parentMeeting.Id;
        registration_02.EAB_Event__c = eSeries.Id;
        registrationsToCreate.add(registration_02);
        
        Registration__c registration_03 = new Registration__c();
        registration_03.Contact__c = contacts[2].Id;
        //registration_03.Meeting__c = parentMeeting.Id;
        registration_03.EAB_Event__c = eSeries.Id;
        registrationsToCreate.add(registration_03);
        
        insert registrationsToCreate;
        
        util.bypassAllTriggers = false;
        
        //Create the new Membership Mtm records
        List<Membership_MtM__c> memshipMtmsToCreate = new List<Membership_MtM__c>();
        
        Membership_MtM__c membershipMtm_01 = new Membership_MtM__c();
        membershipMtm_01.Membership__c = memberships[0].Id;
        membershipMtm_01.Registration__c = registrationsToCreate[0].Id;
        memshipMtmsToCreate.add(membershipMtm_01);
        
        Membership_MtM__c membershipMtm_02 = new Membership_MtM__c();
        membershipMtm_02.Membership__c = memberships[1].Id;
        membershipMtm_02.Registration__c = registrationsToCreate[1].Id;
        memshipMtmsToCreate.add(membershipMtm_02);
        
        Membership_MtM__c membershipMtm_03 = new Membership_MtM__c();
        membershipMtm_03.Membership__c = memberships[1].Id;
        memshipMtmsToCreate.add(membershipMtm_03);
      
        insert memshipMtmsToCreate;
        
        List<Registration__c> registrations = [SELECT ID FROM Registration__c WHERE ID =: registrationsToCreate[0].Id];
        //Assert for Partner Status
        //System.assertEquals('Partner',registrations[0].Eligibility__c);
       
        delete memshipMtmsToCreate[1];
        registrations = [SELECT ID FROM Registration__c WHERE ID =: registrationsToCreate[1].Id];
        //Assert for Prospect Status
        //System.assertEquals('Prospect',registrations[0].Eligibility__c);
        
        memshipMtmsToCreate[2].Registration__c = registrationsToCreate[2].Id;
        update memshipMtmsToCreate[2];
        registrations = [SELECT ID FROM Registration__c WHERE ID =: registrationsToCreate[2].Id];
        //Assert for Prospect Status
        //System.assertEquals('Partner',registrations[0].Eligibility__c);
        
        test.stopTest();
    }
}