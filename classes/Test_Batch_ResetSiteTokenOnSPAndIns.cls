/**
  *  Description     :   Class is used to  test 'Batch_ResetSiteTokenOnSPAndInstitution' 
  *			 which is used to update token details on Account and Site Profile .
  *
  *  Created By      :   Dipesh Gupta
  *
  *  Created Date    :   06/26/2019
  *
  *  Revision Logs   :   V_1.0 - Created - Eab.com Rebuild - CR-20190510-13101
  *		     :   V_1.1 - Modified - Abhishek Mishra - 07/09/21 - CR-20211005-15489 - Increase Test Coverage - Start Here
  *                      
  **/
@isTest(SeeAllData=false)
public class Test_Batch_ResetSiteTokenOnSPAndIns{
    
    public static String OHIO_STATE = 'The Ohio State University';
    public static Integer TOKENS_ACCT = 5;
    public static Integer TOKENS_SITE_PROFILE = 5;
    
    //setup the test data
    //Modified By - Abhishek Mishra - CR-20211005-15489 - 07/09/21 - Increase Test Coverage - Start Here
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
        
        //create contacts
        Contact c1 = TestUtilities.CreateAdvUserContact(acct, false);
        Contact c2 = TestUtilities.CreateAdvUserContact(acct, false);
        List<Contact> contacts = new List<Contact>{ c1, c2 };
            insert contacts;
        //Added By -  Abhishek Mishra - CR-20211005-15489 - 07/09/21 - Increase Test Coverage - Start Here
        contacts[0].Contact_Status__c = 'Active';
        contacts[1].Contact_Status__c = 'Active';
        update contacts;
        //Added By -  Abhishek Mishra - CR-20211005-15489 - 07/09/21 - Increase Test Coverage - Till Here
        
        //create site profiles
        List<Site_Profile__c> sProfiles = new List<Site_Profile__c>();
        for (Contact c : contacts) {
            //Modified By -  Abhishek Mishra - CR-20211005-15489 - 07/09/21 - Added status='Active' - increase test class code coverage
            sProfiles.add(new Site_Profile__c(Contact__c = c.Id, Type__c = 'EAB.com', Username__c = c.Email,Status__c = 'Active'));
        }
        insert sProfiles;
        
        //Added By -  Abhishek Mishra - CR-20211005-15489 - 07/09/21 - Increase Test Coverage - Start Here
        contacts[0].EAB_com_Site_Profile__c = sProfiles[0].Id;
        contacts[1].EAB_com_Site_Profile__c = sProfiles[1].Id;
        update contacts;
        //Added By -  Abhishek Mishra - CR-20211005-15489 - 07/09/21 - Increase Test Coverage - Till Here
        
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
    
    @isTest static void testController(){
        
        Test.startTest();
        Database.executeBatch(new Batch_ResetSiteTokenOnSPAndInstitution(), 50);
        Test.stopTest();
        
    }
}