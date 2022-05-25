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
 * 	Description     :   This class is for test triggers of Account.
 *            
 *  Create By       :   Sudarshan Singh
 *
 *  Created Date    :   03/03/2022 
 *
 *  Revision Log    :   V_1.0 - Created - Fexle service
 *
 *  Coverage        :   100%
 *
 **/
@isTest(seeAllData = false)
public without sharing class Test_Account {
    
    /**
    * 
    *   @description    :   In this method test updated account number using rating field input. 
    *
    *   @args           :   none
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 03/01/2022 - Sudarshan singh - Comment
    * 
    **/
    @isTest 
    static void updateAccountNumberTest(){
        
        //List to store accounts.
        List<Account> listOfAccount = new List<Account>();
        listOfAccount.add(new Account(Name = 'Test 1', Rating = 'Hot'));
        listOfAccount.add(new Account(Name = 'Test 2', Rating = 'Cold'));
        listOfAccount.add(new Account(Name = 'Test 3', Rating = ''));

        //Test start here.
        Test.startTest();

        //Insert accounts to database. 
        insert listOfAccount;

        //Fetch updated accounts from database
        List<Account> updatedListOfAccount = [SELECT AccountNumber FROM Account WHERE Id IN: listOfAccount];
        System.assertEquals('1', updatedListOfAccount[0].AccountNumber);
        System.assertEquals('1234', updatedListOfAccount[1].AccountNumber);
        System.assertEquals('0', updatedListOfAccount[2].AccountNumber);

        updatedListOfAccount[0].Rating = '';
        updatedListOfAccount[1].Rating = 'Hot';
        updatedListOfAccount[2].Rating = 'Warm';

        update updatedListOfAccount;
        
        //Test stop here
        Test.stopTest();

        List<Account> newUpdatedListOfAccount = [SELECT AccountNumber FROM Account WHERE Id IN: listOfAccount];
        System.assertEquals('0', newUpdatedListOfAccount[0].AccountNumber);
        System.assertEquals('1', newUpdatedListOfAccount[1].AccountNumber);
        System.assertEquals('0', newUpdatedListOfAccount[2].AccountNumber);

    }

    /**
    * 
    *   @description    :   In this method test In Active Reason field is required if active field is false. 
    *
    *   @args           :   List<Account>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 03/01/2022 - Sudarshan singh - Comment
    * 
    **/
    @isTest
    static void makeInActiveReasonFieldRequiredTest(){

        //List to store new Accounts
        List<Account> listOfAccount = new List<Account>();
        listOfAccount.add(new Account(Name = 'Test 1', Active__c = 'True'));
        listOfAccount.add(new Account(Name = 'Test 2', Active__c = 'False'));
        listOfAccount.add(new Account(Name = 'Test 3', Active__c = 'False', In_Active_Reason__c = 'Test 3'));

        //Test start here
        Test.startTest();

        try {

            //Insert accounts
            Database.insert(listOfAccount, False);  
        } catch (Exception e) {
            //Check the error message is shown or not.
            Boolean expectedExceptionThrown =  (e.getMessage().contains('Please select In Active Reason for the Account')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
        }
        
        List<Account> updatedAccount = [SELECT Active__c FROM Account ORDER BY Name];

        //This is for test 1 account
        System.AssertEquals('True', updatedAccount[0].Active__c);

        //This is for test 3 account
        System.AssertEquals('False', updatedAccount[1].Active__c);

        //Update test 1 account active field
        updatedAccount[0].Active__c = 'False';

        try {

            //Update accounts
            update updatedAccount;   
        } catch (Exception e) {

            //Check the error message is shown or not.
            Boolean expectedExceptionThrown =  (e.getMessage().contains('Please select In Active Reason for the Account')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
        }

        //Test stop here
        Test.stopTest();

        List<Account> newUpdatedAccount = [SELECT Active__c FROM Account ORDER BY Name];
        System.assertEquals('True', newUpdatedAccount[0].Active__c);

    }

    @isTest
    static void createContactUnderAccountTest(){

        List<Account> listOfAccount = new List<Account>();
        listOfAccount.add(new Account(Name = 'Test 1', Contact_Details__c = 'FirstName = Test 1, LastName = Contact 1, Email = test1@test.com \r\n FirstName = Test 2, LastName = Contact 2, Email = test2@test.com', Contact_Details_1__c = 'FirstName = Test 3, LastName = Contact 3, Email = test3@test.com'));
        listOfAccount.add(new Account(Name = 'Test 2', Contact_Details__c = 'FirstName = Test 4, LastName = Contact 4, Email = test4@test.com', Contact_Details_1__c = 'FirstName = Test 4, LastName = Contact 4, Email = test4@test.com \r\n FirstName = Test 5, LastName = Contact 5, Email = test5@test.com'));
        listOfAccount.add(new Account(Name = 'Test 3', Contact_Details__c = '', Contact_Details_1__c = 'FirstName = Test 6, LastName = Contact 6, Email = test6@test.com \r\n FirstName = Test 7, LastName = Contact 7, Email = test7@test.com'));
        listOfAccount.add(new Account(Name = 'Test 4', Contact_Details__c = 'FirstName = Test 11, LastName = Contact 11, Email = test11@test.com \r\n FirstName = Test 12, LastName = Contact 12, Email = test12@test.com', Contact_Details_1__c = '', Move_To_Contacts__c = 'FirstName = Test 7, LastName = Contact 7, Email = test7@test.com'));
    
        //Test start here
        Test.startTest();

        try {

            //Insert accounts
            Database.insert(listOfAccount, false);  

        } catch (Exception e) {
            //Check the error message is shown or not.
            Boolean expectedExceptionThrown =  (e.getMessage().contains('No contact found to move')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
        }

        //Loop for check number of contacts
        for (AggregateResult arResult : [SELECT COUNT(Id) totalCount, AccountId FROM Contact WHERE AccountId IN: listOfAccount GROUP BY AccountId]) {
            
            //Check contact on test 1
            if ((Id)arResult.get('AccountId') == listOfAccount[0].Id) {
                
                //There are 3 contacts => contact 1, contact 2, contact 3
                System.assertEquals(3, (Integer)arResult.get('totalCount'));
            }

            //Check contact on test 2
            if ((Id)arResult.get('AccountId') == listOfAccount[1].Id) {

                //There are 2 contacts => contact 4, contact 5
                System.assertEquals(2, (Integer)arResult.get('totalCount'));
            }

            //Check contact on test 3
            if ((Id)arResult.get('AccountId') == listOfAccount[2].Id) {

                //There are 2 contacts => contact 6, contact 7
                System.assertEquals(2, (Integer)arResult.get('totalCount'));
            }
        }

        //Fetch updated accounts
        List<Account> listOfUpdatedAccount = [SELECT Id, Name, Move_To_Account__c, Contact_Details__c, Contact_Details_1__c, Move_To_Contacts__c FROM Account WHERE Id IN: listOfAccount ORDER BY Name];
        
        //Update move to account and move to contacts
        listOfUpdatedAccount[0].Move_To_Account__c = listOfUpdatedAccount[1].Id;
        listOfUpdatedAccount[0].Move_To_Contacts__c = 'FirstName = Test 1, LastName = Contact 1, Email = test1@test.com \r\n FirstName = Test 2, LastName = Contact 2, Email = test2@test.com';
        
        //Update move to account, move to contacts and contact details
        listOfUpdatedAccount[1].Contact_Details__c = 'FirstName = Test 4, LastName = Contact 4, Email = test4@test.com \r\n FirstName = Test 8, LastName = Contact 8, Email = test8@test.com';
        listOfUpdatedAccount[1].Move_To_Contacts__c = 'FirstName = Test 4, LastName = Contact 4, Email = test4@test.com \r\n FirstName = Test 5, LastName = Contact 5, Email = test5@test.com';
        listOfUpdatedAccount[1].Move_To_Account__c = listOfUpdatedAccount[2].Id;
        
        //Update move to account and move to contacts
        listOfUpdatedAccount[2].Move_To_Contacts__c = 'FirstName = Test 6, LastName = Contact 6, Email = test6@test.com \r\n FirstName = Test 7, LastName = Contact 7, Email = test7@test.com';
        listOfUpdatedAccount[2].Move_To_Account__c = listOfUpdatedAccount[1].Id;

        //Update list of accounts
        update listOfUpdatedAccount;

        //Create a  contact where previous account is null
        Contact con = new Contact(AccountId = listOfUpdatedAccount[2].Id, FirstName = 'ssc', LastName = 'ss', Email = 'ssc@gmail.com', Previous_Account__c = null);
        insert con;

        //Loop for check number of contacts 
        for (AggregateResult arResult : [SELECT COUNT(Id) totalCount, AccountId FROM Contact WHERE AccountId IN: listOfUpdatedAccount GROUP BY AccountId]) {
            
            //Check contact on test 1
            if ((Id)arResult.get('AccountId') == listOfUpdatedAccount[0].Id) {

                //There is 1 contacts => contact 3
                System.assertEquals(1, (Integer)arResult.get('totalCount'));
            }

            //Check contact on test 2
            if ((Id)arResult.get('AccountId') == listOfUpdatedAccount[1].Id) {

                //There are 5 contacts => contact 1, contact 2, contact 8, contact 6, contact 7
                System.assertEquals(5, (Integer)arResult.get('totalCount'));
            }

            //Check contact on test 3
            if ((Id)arResult.get('AccountId') == listOfUpdatedAccount[2].Id) {

                //There are 3 contacts => contact 4, contact 5, ssc
                System.assertEquals(3, (Integer)arResult.get('totalCount'));
            }
        }

        List<Account> listOfUpdatedAccountUpdatedAccount = [SELECT Id, Name, Move_To_Account__c, Contact_Details__c, Contact_Details_1__c, Move_To_Contacts__c FROM Account WHERE Id IN: listOfUpdatedAccount ORDER BY Name];
        
        //Change move to account and update move to contact values 
        listOfUpdatedAccountUpdatedAccount[0].Move_To_Account__c = listOfUpdatedAccountUpdatedAccount[2].Id;
        listOfUpdatedAccountUpdatedAccount[0].Move_To_Contacts__c = 'FirstName = Test 1, LastName = Contact 1, Email = test1@test.com \r\n FirstName = Test 3, LastName = Contact 3, Email = test3@test.com';
        
        //Change move to account and update move to contacts.
        listOfUpdatedAccountUpdatedAccount[1].Move_To_Contacts__c = 'FirstName = Test 4, LastName = Contact 4, Email = test4@test.com \r\n FirstName = Test 8, LastName = Contact 8, Email = test8@test.com';
        listOfUpdatedAccountUpdatedAccount[1].Move_To_Account__c = listOfUpdatedAccountUpdatedAccount[2].Id;
        
        //Change move to account to null 
        listOfUpdatedAccountUpdatedAccount[2].Move_To_Contacts__c = '';

        //Update list of accounts
        update listOfUpdatedAccountUpdatedAccount;

        //Loop for check number of contacts
        for (AggregateResult arResult : [SELECT COUNT(Id) totalCount, AccountId FROM Contact WHERE AccountId IN: listOfUpdatedAccountUpdatedAccount GROUP BY AccountId]) {
            
            //Check contact on test 1
            if ((Id)arResult.get('AccountId') == listOfUpdatedAccount[0].Id) {

                //There is 1 contact => contact 2
                System.assertEquals(1, (Integer)arResult.get('totalCount'));
            }

            //Check contact on test 2
            if ((Id)arResult.get('AccountId') == listOfUpdatedAccount[1].Id) {

                //There is 1 contact => contact 5 
                System.assertEquals(1, (Integer)arResult.get('totalCount'));
            }

            //Check contact on test 3
            if ((Id)arResult.get('AccountId') == listOfUpdatedAccount[2].Id) {

                //There are 6 contacts => contact 1, contact 3, contact 4, contact 8, contact 6, contact 7 and ssc is deleted because previous account field is null 
                System.assertEquals(6, (Integer)arResult.get('totalCount'));
            }
        }

        //Test end here
        Test.stopTest();
        
    }
}