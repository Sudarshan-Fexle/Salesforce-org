/**
 *	Purpose			:	Test the Batch_TokenReset class
 *
 *	Rivision Log	:	v1.0 - Created - 05/31/2019 - Victor Hanson - CR-20190520-13117
 *
 **/
@isTest
private class Test_Batch_TokenReset {
	
    public static String OHIO_STATE = 'The Ohio State University';
    public static Integer TOKENS_ACCT = 25;
    public static Integer TOKENS_SITE_PROFILE = 5;
    
    //setup the test data
    @testsetup
    static void setup() {
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Bypass the entity population Logic  
        Util.bypassEntityPopulation = true;
        
        //create Account
        Account acct = TestUtilities.createNewAccount('US Education', false);
        acct.Account_Formal_Name__c = OHIO_STATE;
        acct.Tokens__c = TOKENS_ACCT;
        insert acct;
        
        //create Program
        Program__c program1 = TestUtilities.CreateNewProgram(false);
        program1.Program_Acronym__c = 'BHGCL';
        Program__c program2 = TestUtilities.CreateNewProgram(false);
        program2.Program_Acronym__c = 'EDAF';
        List<Program__c> programs = new List<Program__c>{ program1, program2 };
        insert programs;
        
        //create a membership
        List<Membership__c> memberships = new List<Membership__c>();
        Membership__c mem1 = TestUtilities.CreateNewMembership(acct.Id, program1.Id, false);
        Membership__c mem2 = TestUtilities.CreateNewMembership(acct.Id, program2.Id, false);
        mem1.Membership_Status_Text__c = Constants.MEMBER_PAYER;
        mem2.Membership_Status_Text__c = Constants.MEMBER_PAYER;
        memberships.add(mem1);
        memberships.add(mem2);
        insert memberships;
        
        //create contacts
        Contact c1 = TestUtilities.CreateAdvUserContact(acct, false);
        Contact c2 = TestUtilities.CreateAdvUserContact(acct, false);
        List<Contact> contacts = new List<Contact>{ c1, c2 };
        insert contacts;
        
        //create site profiles
        List<Site_Profile__c> sProfiles = new List<Site_Profile__c>();
        for (Contact c : contacts) {
            sProfiles.add(new Site_Profile__c(Contact__c = c.Id, Type__c = 'EAB.com', Username__c = c.Email));
        }
        insert sProfiles;
        
        //get site profiles and set the default Tokens count
        sProfiles = [SELECT Id, Tokens__c FROM Site_Profile__c WHERE Id IN :sProfiles];
        system.assertEquals(2, sProfiles.size());
        for (Site_Profile__c sp : sProfiles) {
            sp.Tokens__c = TOKENS_SITE_PROFILE;
        }
        update sProfiles;
        
        //create site content
        List<Site_Content__c> sContents = new List<Site_Content__c>();
        sContents.add(new Site_Content__c(GUID__c='a123', Title__c='content1', URL__c='http://www.eab.com/content1'));
        sContents.add(new Site_Content__c(GUID__c='b456', Title__c='content2', URL__c='http://www.eab.com/content2'));
        insert sContents;
        
        //create Site Tokens
        List<Site_Token__c> sTokens = new List<Site_Token__c>();
        sTokens.add(new Site_Token__c(Contact__c=c1.Id, Site_Content__c=sContents[0].Id, Site_Profile__c=sProfiles[0].Id, Expiration_Date__c=Date.today().addDays(30)));
        sTokens.add(new Site_Token__c(Contact__c=c2.Id, Site_Content__c=sContents[1].Id, Site_Profile__c=sProfiles[1].Id, Expiration_Date__c=Date.today().addDays(30)));
        insert sTokens;
    }
    
    /**
     * @description: 	when the last active membership on an Institution is dropped, verify that the tokens fields on Institution & Site Profile are reset to zero
     * 
     * @revision log: 	Created - 05/31/2019 - Victor Hanson - CR-20190520-13117
     * 
     **/
    static testmethod void testResetToken() {
        
        //get site profile and Institution to verify Tokens fields have values
        List<Site_Profile__c> sProfiles = [SELECT Id, Tokens__c, Contact__r.Account.Tokens__c FROM Site_Profile__c WHERE Contact__r.Account.Account_Formal_Name__c = :OHIO_STATE];
        system.assertEquals(2, sProfiles.size());
        for (Site_Profile__c sp : sProfiles) {
            system.assertEquals(TOKENS_SITE_PROFILE, sp.Tokens__c);
        }
        
        //get memberships
        List<Membership__c> memberships = [SELECT Id, Membership_Status_Text__c FROM Membership__c WHERE Account_Name__r.Account_Formal_Name__c = :OHIO_STATE];
        system.assertEquals(2, memberships.size());
        
        //update both memberships so they are no longer active
        for (Membership__c m : memberships) {
            m.Membership_Status_Text__c = Constants.PROSPECT_PAST_MEMBER;
        }
        
        test.startTest();
        
        update memberships;
        
        test.stopTest();
        
        //verify the batch job executed
        List<AsyncApexJob> jobs = [select ApexClassId, ApexClass.Name, Id, JobItemsProcessed, JobType, 
                                   Status, NumberOfErrors, MethodName 
                                   from AsyncApexJob  
                                   where ApexClass.Name = 'Batch_TokenReset'];
        system.assertNotEquals(0, jobs.size());
        system.assertEquals(0, jobs[0].NumberOfErrors);
        system.assertEquals('Completed', jobs[0].Status);
        
        //get the active memberships at the institution
        List<Membership__c> activeMemberships = [SELECT Id FROM Membership__c WHERE Membership_Status_Text__c LIKE 'Member%' AND Account_Name__r.Account_Formal_Name__c = :OHIO_STATE];
        system.assertEquals(0, activeMemberships.size());
        
        //get the Site Pofiles and related Institution tokens
        sProfiles = [SELECT Id, Tokens__c, Contact__r.Account.Tokens__c FROM Site_Profile__c WHERE Id IN :sProfiles];        
        for (Site_Profile__c sp : sProfiles) {
            system.assertEquals(0, sp.Tokens__c);
            system.assertEquals(0, sp.Contact__r.Account.Tokens__c);
        }
    }

    @isTest
    static void testBatch_TokenDataUpdate() {

        //Inserting custom settings. 
        Sitecore_Settings__c siteCoreSettings = new Sitecore_Settings__c(Tokens_Default_Site_Profile__c = 5, Tokens_Default_Institution__c = 25); 
        insert siteCoreSettings;

        //Since the all the data is created already in the setup so just calling the batch. 
        Test.startTest();

        Batch_TokenDataUpdate batch = new Batch_TokenDataUpdate();
        Database.executeBatch(batch, 10);

        Test.stopTest();
        //Check for the asserts. 
        for(Site_Profile__c siteprofile : [Select Id, Tokens__c, Contact__r.Account.Tokens__c From Site_Profile__c]) {

            System.assertEquals(5, siteprofile.Tokens__c);
            System.assertEquals(25,  siteprofile.Contact__r.Account.Tokens__c);
        }
    }
}