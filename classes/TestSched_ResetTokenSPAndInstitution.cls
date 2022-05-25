/**
 *  Description     :   Test Class for Schedule_ResetTokenSPAndInstitution
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
@isTest(SeeAllData=false)
public class TestSched_ResetTokenSPAndInstitution
{
    public static String OHIO_STATE = 'The Ohio State University';
    public static Integer TOKENS_ACCT = 5;
    public static Integer TOKENS_SITE_PROFILE = 4;
    
    @testsetup static void testSetupData() 
    {
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Bypass the entity population Logic  
        Util.bypassEntityPopulation = true;
        
        //create Account
        Account acct = TestUtilities.createNewAccount('US Education', false);
        acct.Account_Formal_Name__c = OHIO_STATE;
        acct.Tokens__c = TOKENS_ACCT;
        insert acct;
        
        //Create Contacts
        Contact c1 = TestUtilities.CreateAdvUserContact(acct, false);
        Contact c2 = TestUtilities.CreateAdvUserContact(acct, false);
        List<Contact> contacts = new List<Contact>{ c1, c2 };
            insert contacts;
        
        contacts[0].Contact_Status__c = 'Active';
        contacts[1].Contact_Status__c = 'Active';
        update contacts;
        
        //Create Site Profiles
        List<Site_Profile__c> sProfiles = new List<Site_Profile__c>();
        for (Contact c : contacts) {
            sProfiles.add(new Site_Profile__c(Contact__c = c.Id, Type__c = 'EAB.com', Username__c = c.Email, Status__c = 'Active'));
        }
        insert sProfiles;
        
        //Update contact and adding EAB_com_Site_Profile__c
        contacts[0].EAB_com_Site_Profile__c = sProfiles[0].Id;
        contacts[1].EAB_com_Site_Profile__c = sProfiles[1].Id;
        update contacts;
        
        //get site profiles and set the default Tokens count
        sProfiles = [SELECT Id, Tokens__c FROM Site_Profile__c WHERE Id IN :sProfiles];
        system.assertEquals(2, sProfiles.size());
        for (Site_Profile__c sp : sProfiles) {
            sp.Tokens__c = TOKENS_SITE_PROFILE;
        }
        update sProfiles;
        
        //Create Site Content
        List<Site_Content__c> sContents = new List<Site_Content__c>();
        sContents.add(new Site_Content__c(GUID__c='a123', Title__c='content1', URL__c='http://www.eab.com/content1'));
        sContents.add(new Site_Content__c(GUID__c='b456', Title__c='content2', URL__c='http://www.eab.com/content2'));
        insert sContents;
        
        //Create Site Tokens
        List<Site_Token__c> sTokens = new List<Site_Token__c>();
        sTokens.add(new Site_Token__c(Contact__c=c1.Id, Site_Content__c=sContents[0].Id, Site_Profile__c=sProfiles[0].Id, Expiration_Date__c=Date.today().addDays(30)));
        sTokens.add(new Site_Token__c(Contact__c=c2.Id, Site_Content__c=sContents[1].Id, Site_Profile__c=sProfiles[1].Id, Expiration_Date__c=Date.today().addDays(30)));
        insert sTokens;
        
        Util.BypassAllTriggers = false;
    }
    
    @isTest static void test_Sched_ResetTokenSPAndInstitution()
    {
        Test.startTest();
        
        //After 1 min. batch will run
        Datetime sysTime = DateTime.now();
        sysTime = sysTime.addMinutes(5);
        
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
        //Schedule the scheduler
        Schedule_ResetTokenSPAndInstitution sch = new Schedule_ResetTokenSPAndInstitution();
        System.Schedule('Schedular 1',chron_exp,sch);
        
        Test.stopTest();
        
        List<AsyncApexJob> asyncApexJob = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        List<AsyncApexJob> batchApexJob = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
        
        //Asserts
        System.assertEquals('Schedule_ResetTokenSPAndInstitution', asyncApexJob[0].ApexClass.Name);
        System.assertEquals('Batch_ResetSiteTokenOnSPAndInstitution', batchApexJob[0].ApexClass.Name);
    }
}