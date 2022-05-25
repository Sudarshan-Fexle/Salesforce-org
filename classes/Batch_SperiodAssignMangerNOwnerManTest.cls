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
 
 /*
    Purpose         :   Test class is Used to test the Functionality of Batch_SperiodAssignMangerNOwnerManEmail
                
    Create By       :   Subhash Garhwal
    
    Created Date    :   02/05/2018
    
    Revision Log    :   V_1.1 Created
*/
@isTest
private class Batch_SperiodAssignMangerNOwnerManTest {

    static testMethod void myUnitTest() {
        
        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
        
        //create Test data for Account object as an institute
        Account account = new Account(Name = 'AccountTest1');
        insert account;

        //Create contact
         Contact contact = new Contact(LastName = 'TestingABC', AccountId = account.Id, Email = 'Test'+Math.random()+'@eab.com', 
                                        Title = 'Test',
                                        Phone = '614-555-8855');
        insert contact;

        //create Contract ABC test data
        Contract__c contractABC = new Contract__c(Name = 'TestContract1', Invoicing_Arrangement__c = 'Special', Payer_Account__c = account.Id,
                                                Year__c = '2017', Type__c = 'NBB', Main_Contact__c = contact.Id, Invoice_Contact__c = contact.Id,
                                                Negotiated_Amount__c = 12 );

        //Insert the contract ABC
        insert contractABC;

        //List to hold subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();  

        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));
        //Insert
        insert subscriptions;    
        
        List<Profile> profiles = [Select Id From Profile Where Name = 'Specialist'];
        
       
        //Creating a User 
        User usr = TestUtilities.CreatenewUser(profiles[0], false);    
        usr.ManagerId = UserInfo.getUserId();
        insert usr;
        
         //Enabling triggers
        Util.byPassAllTriggers = true; 
        
        //List to hold the Subscription Period records
        List<Subscription_Period__c> listSusbcriptionPeriod  = new List<Subscription_Period__c>();
        
        //Add the new 
        listSusbcriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[0].Id, Period_Start_Date__c = Date.Today(), 
                                                                Stage__c = CPQConstants.SUBSCRIPTION_PERIOD_STAGE_DROPPED, Opt_Out_Date__c =  Date.Today(),
                                                               CT_Assignment__c = usr.Id ));
        
        
         //Insert the listOfSubscriptionPeriod
        insert listSusbcriptionPeriod;
        
        //Test Start here 
        Test.startTest();
        
        //Set To Hold the Id If user
        Set<Id> setuserId = new Set<Id> {UserInfo.getUserId()};
        Database.executeBatch(new Batch_SperiodAssignMangerNOwnerManEmail(setuserId),100);
        
        //Test Start here 
        Test.stopTest();
        
        //List to hold the user and Subsbcription period.
        List<Subscription_Period__c> sPeriod = [Select Id, CT_Assignment_s_Manager_Email__c From Subscription_Period__c LIMIT 1];
        
        System.assertEquals(UserInfo.getUserEmail(), sPeriod[0].CT_Assignment_s_Manager_Email__c);
        
        
    }
}