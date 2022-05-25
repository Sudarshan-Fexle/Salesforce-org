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

/**
 * 	Description     :   This class is for test checking duplicate contacts using schedule process.
 *            
 *  Create By       :   Sudarshan Singh
 *
 *  Created Date    :   03/26/2022 
 *
 *  Revision Log    :   V_1.0 - Created - Fexle service
 *
 *  Coverage        :   100%
 *
 **/
@isTest
public with sharing class CheckDuplicateContact_ScheduleTest {

    @TestSetup
    static void setUp(){

        List<Account> listOfAccount = new List<Account>();
        listOfAccount.add(new Account(Name = 'Test 1'));
        listOfAccount.add(new Account(Name = 'Test 2'));
        listOfAccount.add(new Account(Name = 'Test 3'));
        
        insert listOfAccount;

        List<Contact> listOfContact = new List<Contact>();
        for (Integer i = 0; i < 6; i++) {
            Contact con =new Contact();
            con.AccountId = listOfAccount[0].Id;
            con.LastName = 'Test ' + i;
            con.Email = 'test'+i+'@fexle.com';
            listOfContact.add(con);
        }
        for (Integer i = 0; i < 4; i++) {
            Contact con =new Contact();
            con.AccountId = listOfAccount[1].Id;
            con.LastName = 'Test ' + i;
            con.Email = 'test'+i+'@fexle.com';
            listOfContact.add(con); 
        }
        for (Integer i = 0; i < 2; i++) {
            Contact con =new Contact();
            con.AccountId = listOfAccount[2].Id;
            con.LastName = 'Test ' + i;
            con.Email = 'test'+i+'@fexle.com';
            listOfContact.add(con); 
        }

        insert listOfContact;

    }

    @isTest 
    static void test(){

        Test.startTest();

        String cronExp = '0 32 16 30 3 ?';
        String jobId = System.schedule('Check Duplicate Contact', cronExp, new CheckDuplicateContact_Schedule());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(cronExp, ct.CronExpression);
        
        System.assertEquals(0, ct.TimesTriggered);
        
        System.assertEquals('2022-03-30 16:32:00', String.valueOf(ct.NextFireTime));

        
        Test.stopTest();
        
    }
}