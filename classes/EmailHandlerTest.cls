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
public class EmailHandlerTest {
    
/**
    Purpose         :   Test class for EmailHandler
                
    Created By       :  Abhinav Sharma
    
    Created Date    :   07/06/2017
    
    Revision Log    :   v1.0 - Created - Abhinav Sharma - Q2C Beta Release
 
    Coverage        :   v1.0 - EmailHandler - 
**/
    
    static testmethod void myUnitTest1() { 
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Start test from here
        Test.startTest();
        
        List<String> toAddresses = new List<String>();
        toAddresses.add('test@advisory.com');
        
        //Calling class static method
        try {
            EmailHandler.sendEmail(toAddresses[0], 'Test', 'Test');
        } catch(Exception ex) {}
        
        //Stop Test here
        Test.stopTest();
    }
    
    static testmethod void myUnitTest2() { 
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Start test from here
        Test.startTest();
        
        List<String> toAddresses = new List<String>();
        toAddresses.add('test@advisory.com');
        
        //Calling class static method
        try {
            EmailHandler.sendEmail(toAddresses[0], 'Test', 'Test', 'Test');
        } catch(Exception ex) {}
        
        //Stop Test here
        Test.stopTest();
    }
    
    static testmethod void myUnitTest3() { 
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Start test from here
        Test.startTest();
        
        List<String> toAddresses = new List<String>();
        toAddresses.add('test@advisory.com');
        
        //Calling class static method
        try {
            EmailHandler.createEmail(toAddresses, 'Test', 'Test', 'Test', true);
        } catch(Exception ex) {}
        
        //Stop Test here
        Test.stopTest();
    }
    
    static testmethod void myUnitTest4() { 
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Start test from here
        Test.startTest();
        
        List<String> toAddresses = new List<String>();
        toAddresses.add('test@advisory.com');
        
        //Calling class static method
        try {
            EmailHandler.sendEmail(toAddresses, null, null, null);
        } catch(Exception ex) {}
        
        //Stop Test here
        Test.stopTest();
    }
    
    static testmethod void myUnitTest5() { 
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Start test from here
        Test.startTest();
        
        List<String> toAddresses = new List<String>();
        toAddresses.add('test@advisory.com');
        
        //Calling class static method
        try {
            list<Messaging.EmailFileAttachment> attachments = new list<Messaging.EmailFileAttachment>();
            EmailHandler.createEmail(toAddresses, null, null, null, attachments);
        } catch(Exception ex) {}
        
        //Stop Test here
        Test.stopTest();
    }
    
    static testmethod void myUnitTest6() { 
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Start test from here
        Test.startTest();
        
        Account acc = new Account(Name = 'Test');
        insert acc;
        
        //Calling class static method
        try {
            EmailHandler.createEmailAttachment('Test.csv', Blob.valueOf('Test'));
            Set<Id> userIds = new Set<Id>();
            userIds.add(ID.valueOf(UserInfo.getUserId()));
            EmailHandler.email(null, null, acc.Id);
            EmailHandler.sendEmail(userIds, 'Test', 'Test');
        } catch(Exception ex) {}
        
        //Stop Test here
        Test.stopTest();
    }
    
    static testmethod void myUnitTest7() { 
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Start test from here
        Test.startTest();
        
        List<String> toAddresses = new List<String>();
        toAddresses.add('test@advisory.com');
        
        Account acc = new Account(Name = 'Test');
        insert acc;
        
        //Calling class static method
        try {
            list<Messaging.EmailFileAttachment> attachments = new list<Messaging.EmailFileAttachment>();
            EmailHandler.createEmail(toAddresses, acc.Id, null, null, true);
        } catch(Exception ex) {}
        
        //Stop Test here
        Test.stopTest();
    }
}