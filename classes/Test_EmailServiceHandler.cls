/**
 *    Purpose			:	Test Class for EmailServiceHandler
 *   
 *    Create By			:	Nikita Kumari - CR-20211005-15489 - 07-06-2021
 *    
 *    Current Version		:	v1.0
 *    
 *    Revision Log		:	Created.
 **/
@isTest(seeAllData = false)
public with sharing class Test_EmailServiceHandler 
{        
    static testMethod void Test_handleInboundEmail() 
    {
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.byPassAlltriggers = true;
        
        Account account = TestUtilities.CreateNewAccount(true);
        
        //insert restricted data
        Restrictions__c restriction = new Restrictions__c(Name = 'Test Restrictions', Category__c = 'Restricted: Permission Required', Source_Department__c = 'EA', Expiration_Date__c = Date.today().addDays(1));
        insert restriction;
        
        //Restricted_MtM__c test data
        insert new Restricted_MtM__c(Restriction__c = restriction.Id, Account__c = account.Id );
        
        //insert restricted data
        restriction = new Restrictions__c(Name = 'Test Restrictions', Expiration_Date__c = Date.today().addDays(1), Category__c = 'Restricted: Permission Required', Source_Department__c = 'AE');
        insert restriction;
        
        //Restricted_MtM__c test data
        insert new Restricted_MtM__c(Restriction__c = restriction.Id, Account__c = account.Id);
        
        // retire restriction
        restriction = [SELECT Expiration_Date__c FROM Restrictions__c WHERE Id = :restriction.Id];
        restriction.Expiration_Date__c = system.today().addDays(-1);
        update restriction;
        
        // create the user
        User user = TestUtilities.CreateNewUser(false);
        user.IsActive = true;
        insert user;
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // setup the data for the email
        email.subject = 'test Email';
        email.plainTextBody = 'this is test Execute_Batch_PopulateRNIAMRestrictionsOnAccount';
        env.fromAddress = user.Email;
        
        Util.byPassAlltriggers = false;
        
        // call the email service class and test it with the data in the testMethod
        EmailServiceHandler emailHandler = new EmailServiceHandler();
        
        //Start Test from Here
        Test.startTest();
        
        emailHandler.handleInboundEmail(email, env);
        
        //Stop Test Here
        Test.stopTest();
        
        Account acct = [Select RNI_AM_Restrictions__c from Account];
        System.assertEquals(1, acct.RNI_AM_Restrictions__c);
    }
}