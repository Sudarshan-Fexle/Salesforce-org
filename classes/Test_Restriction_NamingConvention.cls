@isTest
private class Test_Restriction_NamingConvention 
{
    /*
    Purpose:    Test Trigger Restrictions_NamingConvention
    
    Create By:  Mike Lofquist (SAP)         
    
    Last Modified By:   Nathan Banas (SAP) - 1/24/2011
    
    Current Version:    v1.1
    
    Revision Log:       v1.0 - (AW) Created code
                        v1.1 - (NB-2011-01-24) Added header, code comments, and reviewed code coverage
                        v1.2 - Modified by - Mahendra Swarnakar - CR-20161102-10332 - 12/20/2016 - Comment out "CRMfusionDBR101.DB_Globals.triggersDisabled" flag
    
    Code Coverage as of 1/24/2011: 100%
    */
    /*  
    static testMethod void myUnitTest() 
    {
        Util.IsTesting = true;
        
        //Define a Profile ID and Role
        Profile p = [SELECT id FROM profile WHERE name='Standard User'];
        
        //Define a User
        User testUser = new User (LastName = 'Test', FirstName = 'User', Alias = 'Test',  
             username = 'test@advisory.com', CommunityNickname = 'TestExample', Email = 'test@advisory.com',
             ProfileId = p.id, EmailEncodingKey = 'ISO-8859-1',
             TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US',
             LanguageLocaleKey = 'en_US');
        
        //Inserting the user and run as the newly created user
        insert testUser;
        
        testUser = [SELECT id, name FROM User WHERE id = :testUser.id];
        
        System.runAs(testUser)
        {             
            //Create a record that will be used to verify Trigger functionality
            Restrictions__c testRestriction1 = new Restrictions__c (category__c = 'Test', OwnerID = testUser.id, Name = 'A', Reason__c = 'Other', 
                Source_Department__c = 'Other', Expiration_Date__c = System.today()+1);
                
            insert testRestriction1;
            
            testRestriction1 = [SELECT id, name, category__c FROM Restrictions__c WHERE id = :testRestriction1.id];
    
            System.AssertEquals(testRestriction1.category__c + '-' + testUser.name, testRestriction1.name); 
        }    
    } 
    */
    static testmethod void testbeforeTrig()
    {
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        Util.IsTesting = true;
        
        Restrictions__c newrestriction = new Restrictions__c(
            category__c = 'Restricted: Permission Required', 
            Name = 'A', 
            Reason__c = 'Other', 
            Source_Department__c = 'Other', 
            Expiration_Date__c = System.today().addDays(1)
            );
        insert newrestriction;
        
        Account a = new Account(
            Name = 'testacct'
            );
        insert a;
        
        Recordtype rt = [select id from Recordtype where SObjectType = 'Restricted_MtM__c' and Name = 'Account Restriction' limit 1];
        Restricted_MtM__c newrmtm = new Restricted_MtM__c(
            RecordtypeId = rt.id,
            Restriction__c = newrestriction.id,
            Account__c = a.id
            );
        
        Util.BypassAllTriggers = true;
        insert newrmtm;
        Util.BypassAllTriggers = false;
        
        newrestriction.Run_Trigger__c = true;
        newrestriction.Expiration_Date__c = system.today().addDays(-1);
test.startTest();
system.debug('\n\n82 update');      
        update newrestriction;
test.stopTest();
        //newrestriction = [select Run_Trigger__c from Restrictions__c where id = :newrestriction.id];
        //system.assertEquals(false, newrestriction.Run_Trigger__c);
        
        a = [select Account_Restriction_Status__c from Account where id = :a.id];
        system.assertEquals(null, a.Account_Restriction_Status__c);
    }
}