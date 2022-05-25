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
@isTest(seeAllData = false)
public class Test_IntegratedTriggerHelper {
/**
 *	Description		:   Test class to test the functionality of IntegratedTriggerHelper Trigger
 *            
 *	Create By   	:   Colin
 *
 *  Created Date	:   07/08/2016
 *
 *	Revision Log    :   V_1.0 - Created - CR-20160414-9762 
 *			    V_1.1 - Modified - 07/29/2016 - Subhash Garhwal - CR-20160414-9762 - Update the class to resolve test failure  
                            V_1.2 - Modified - 02/02/2018 - Subhash Garhwal - CR-20180126-11911 - Added a new Method populateIntegratedAccOnQuoteTest
 			    V_1.3 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
 *
 *	Coverage	:   V_1.0 - 100% 
 *			    V_1.1 - 100%
 *
 **/
 
    static testmethod void testPreventEditOfIntegratedAccount () {
        
        //Create test data
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;
        
        //Added - 07/29/2016 - Subhash Garhwal - CR-20160414-9762
        //Query through Opportunity Record Type
        List<RecordType> recordTypes = [Select Id From RecordType Where SobjectType = 'Opportunity' AND DeveloperName = 'EAB_Continuing'];
        
        //Assert
        System.assertEquals(1, recordTypes.size());
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        Opportunity opp1 = new Opportunity();
        opp1.AccountId = acc.Id;
        opp1.Name = 'Test Opp 1';
        opp1.StageName = '0-Exploring';
        opp1.Marketer__c = UserInfo.getUserId();
        opp1.CloseDate = System.today().addDays(8);
        opp1.RecordTypeId = recordTypes[0].Id;
        opp1.Sales_Pursuit_Products__c = 'APS';
        
        //Insert
        insert opp1;
        
        Integrated_Account__c IA = new Integrated_Account__c();
        IA.Integrated_Account__c = acc.id;
        IA.Opportunity__c = opp1.Id;
        insert IA;
        
        Contract_Integrated_Accounts__c CIA = new Contract_Integrated_Accounts__c ();
        CIA.Integrated_Account__c = IA.Id;
        insert CIA;
        
        //Start the Test
        Test.startTest();
        
        //Test 1 - Try modifiying the Integrated Account record and check that the error message is displayed
        
        //Create a new Account && modify Integrated Account Record
        Account acc2 = new Account(Name = 'testacc2', Account_Formal_Name__c = 'testacc2');
        insert acc2;
        
        //Try and Catch used to capture the custom label error message back
        try {
            IA.Integrated_Account__c = acc2.Id;
            update IA; 
        }
        catch (exception e) {
            System.assert(e.getMessage().contains(Label.IntegratedAccountModifyError));
        }
        
        //Test 2 - Delete the CIA record and ensure that the Integrated Account can be modified after this
        
        //Delete the Contract Integrated Account record which references IA record
        Delete CIA;
        
        //Modify the IA record and verify the change processes
        IA.Integrated_Account__c = acc2.Id;
        update IA;
        
        Test.stopTest();
        
        //Query for the IA record and assert that the Integrated Account field was modified
        List<Integrated_Account__c> checkIA = [SELECT Id, Integrated_Account__c, Opportunity__c FROM Integrated_Account__c WHERE Opportunity__c = :opp1.Id];
        system.assertEquals(checkIA[0].Integrated_Account__c, acc2.Id);
        
    }
    
    static testmethod void testPreventDeleteOfIntegratedAccount () {
        
        //Create test data
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;
        
        //Added - 07/29/2016 - Subhash Garhwal - CR-20160414-9762
        //Query through Opportunity Record Type
        List<RecordType> recordTypes = [Select Id From RecordType Where SobjectType = 'Opportunity' AND DeveloperName = 'EAB_Continuing'];
        
        //Assert
        System.assertEquals(1, recordTypes.size());
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        Opportunity opp1 = new Opportunity();
        opp1.AccountId = acc.Id;
        opp1.Name = 'Test Opp 1';
        opp1.StageName = '0-Exploring';
        opp1.Marketer__c = UserInfo.getUserId();
        opp1.CloseDate = System.today().addDays(8);
        opp1.RecordTypeId = recordTypes[0].Id;
        opp1.Sales_Pursuit_Products__c = 'APS';
        
        //Insert
        insert opp1;
        
        Integrated_Account__c IA = new Integrated_Account__c();
        IA.Integrated_Account__c = acc.id;
        IA.Opportunity__c = opp1.Id;
        insert IA;
        
        Contract_Integrated_Accounts__c CIA = new Contract_Integrated_Accounts__c ();
        CIA.Integrated_Account__c = IA.Id;
        insert CIA;
        
        //Get SysAdmin Profile Id
        List<Profile> sysProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        //Get Test Profile where delete is not allowed
        List<Profile> testProfiles = [SELECT Id From Profile WHERE Name = 'Marketing Associates'];
        Profile testProfile = testProfiles[0];
        
        //Query for Permission Set which grants object permission to delete Integrated Account
        List<PermissionSet> testPS = [SELECT Id From PermissionSet WHERE Name = 'Audit_Field_Access_Modify_All_Data_Audit_Fields_Set_Inactive_Owner'];
        PermissionSet testPS1 = testPS[0];
        
        //Utill BY Pass trigger
        Util.BypassAllTriggers = true;
        
        //Create a user which cannot delete the IA record
        User User1 = TestUtilities.CreatenewUser(testProfile, true);
        
        //Utill BY Pass trigger = false
        Util.BypassAllTriggers = false;
        
        //Need to run insert of permission set as SystemRunAs due to mixed dml error
        User thisUser = [SELECT Id FROM User WHERE ProfileId = :sysProfile[0].Id AND IsActive = True LIMIT 1];
        
        System.runAs(thisUser){
      
        	//Assign User1 a permission set which gives them the object permissions to delete the IA
        	PermissionSetAssignment assignPS = new PermissionSetAssignment (AssigneeId = User1.Id, PermissionSetId = testPS1.Id);
            insert assignPS;
        }
        
        //Test 1 - Try to delete the Integrated Account record associated with the CIA while logged in as a Profile which should be prevented from deleting
        
        System.runAs(User1){
            
            System.Test.startTest();
            
            //Query all Integrated Accounts
            List <Integrated_Account__c> allIntegratedAccounts = [SELECT Id, Integrated_Account__c, Opportunity__c FROM Integrated_Account__c WHERE Opportunity__c = :opp1.Id];
            
            //Assert that the correct error message is presented
            try {
                delete allIntegratedAccounts;
            }
            catch (exception e) {
                System.assert(e.getMessage().contains(Label.IntegratedAccountDeleteError));
            }
            
            //Query all Integrated Accounts after deletion attempt
            List <Integrated_Account__c> allIntegratedAccounts2 = [SELECT Id, Integrated_Account__c, Opportunity__c FROM Integrated_Account__c WHERE Opportunity__c = :opp1.Id];
            System.assertEquals(1, allIntegratedAccounts2.size());
            
        }
        
        //Test 2 - Try to delete the Integrated Account record associated with the CIA while logged in as a Profile which should not be prevented from deleting
        
        System.runAs(thisUser){
            
            //Query all Integrated Accounts
            List <Integrated_Account__c> allIntegratedAccounts = [SELECT Id, Integrated_Account__c, Opportunity__c FROM Integrated_Account__c WHERE Opportunity__c = :opp1.Id];
            
            //Delete the Integrated Account record
            try {
                delete allIntegratedAccounts;
            }
            catch (exception e) {
                
            }
            
            //Query all Integrated Accounts after deletion attempt
            List <Integrated_Account__c> allIntegratedAccounts2 = [SELECT Id, Integrated_Account__c, Opportunity__c FROM Integrated_Account__c WHERE Opportunity__c = :opp1.Id];
            System.assertEquals(0, allIntegratedAccounts2.size());
            
            System.Test.stopTest();
        }
    }
     /**
    *
    *   @description    :   Method to Test the Functionality of Quotes to update the Integrated Account Field accordingly on insert/Update/Delete of IA
    * 
    *   @revision Log   :   V_1.0 - Created - Subhash Garhwal - 02/02/2018
    *
    **/
    testmethod static void populateIntegratedAccOnQuoteTest() {
    	
        //Bypassind all trigger
        Util.BypassAllTriggers = true;
        
        //Creating the opportunity
        //Creating account record
        Account account = TestUtilities.CreateNewAccount(false);
        account.Account_Formal_Name__c = 'testacc';
        insert account;
        
        System.assert(account.Id != null);
        
        //Create a new opportunity
     	Opportunity  opportunity = TestUtilities.CreateNewOpportunity(true);
        
        //Create a new opportunity
     	Opportunity  opportunity2 = TestUtilities.CreateNewOpportunity(true);
        
        //Creating a Quote under the opportunty
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        insert quote;
        
        //Creating a Quote under the opportunty
        SBQQ__Quote__c quote1 = TestUtilities.createNewSbqqQuote(false);
        quote1.SBQQ__Opportunity2__c = opportunity2.Id;
        insert quote1;
       
        //Utill byPassALltrigger false
        Util.BypassAllTriggers = false;
        
        Test.startTest();
        
        //Integrated Account Insert
        Integrated_Account__c IA = new Integrated_Account__c();
        IA.Integrated_Account__c = account.id;
        IA.Opportunity__c =  opportunity.Id;
        insert IA;
        
        //Query on the  Quotes
        List<SBQQ__Quote__c> q1 = [Select Id, Integrated_Accounts__c From SBQQ__Quote__c Where SBQQ__Opportunity2__c =: opportunity.Id];
        
        System.assert(q1.size() == 1);
        

        Test.stopTest();
    }
}