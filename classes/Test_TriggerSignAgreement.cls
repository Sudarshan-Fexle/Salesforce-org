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
@isTest
private class Test_TriggerSignAgreement {
/*
    Purpose         :   Test class for Trigger_SignAgreement
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   12/20/2012
    
    Current Version :   V1.0
    
    Revision Log    :   V1.0 - Created
                        V1.1 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes

    Coverage        :   Trigger_SignAgreement - 100%
                        AgreementTriggerHelper - 100%
*/	
	//test method for Agreement trigger
    static testMethod void myUnitTest() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
    
        //Test Contract "Negotiated By" assignment
        Util.IsTesting = true;
        
        Map<String, Id> rtmap = Util.recordtypemap('Opportunity');
        if (rtmap == null) {
            
            // ensure that the record type custom setting has been updated with the correct values
            Util.resetRecordtypeSettings();
            rtmap = Util.recordtypemap('Opportunity');
        }
        
        String RenewalRecordTypeId = rtmap.get('PT Contract Renewal');
        
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        Util.BypassAllTriggers = true;
        insert acc;
        
       // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        // Test Class Fix Start Here 07/19/20 By: Mahendra Swarnakar -CR-20200218-13783
        //Creating Contact record 
        Contact con = TestUtilities.CreateNewContact(false);
        con.AccountId = acc.Id;
        insert con ;
        // Test Class Fix end Here 07/19/20 By: Mahendra Swarnakar
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
        
        
        Util.BypassAllTriggers = false;
        
        Program__c testProg1 = new Program__c(Name='Test Trigger Program', New_Business_Marketer__c = 'RI Marketer', Program_Acronym__c='ZZZ', Create_memberships__c='No', Business_line__c = 'PT');
        insert testProg1;
            
	string recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royall').getRecordTypeId();
	//Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test';
        opp.StageName = 'Pending';
        opp.CloseDate = System.today();
        opp.Program__c = testProg1.Id;
	opp.RecordTypeId = recordTypeId;
        opp.Main_Contact__c = con.Id;
	opp.Sales_Pursuit_Products__c = 'APS';
        insert opp;
        
        //Attach the Agreement records
        echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c(Name='test', echosign_dev1__Account__c=acc.Id, 
        																					echosign_dev1__Status__c = Constants.STATUS_AGREEMENT_OUT_FOR_SIGNATURE, 
        																					echosign_dev1__Opportunity__c=opp.Id, 
        																					Contract_Document_Type__c='Terms of Agreement');
        
        //Start test from here
        Test.startTest();
        
        //insert agreement record
        insert agreement;
        
        
        //Assert for the contact data
        opp = [Select LOA_Sent_Date__c from Opportunity where Id =: opp.Id limit 1];
        //System.assertEquals(Date.today(), opp.LOA_Sent_Date__c);
        
        //Set the opportunity LOA_Sent_Date__c flag manually
        opp.LOA_Sent_Date__c = Date.today() + 1;
        update opp;
        
        //insert a new agreement
        insert new echosign_dev1__SIGN_Agreement__c(Name='test', echosign_dev1__Account__c=acc.Id, 
        																					echosign_dev1__Status__c = Constants.STATUS_AGREEMENT_OUT_FOR_SIGNATURE, 
        																					echosign_dev1__Opportunity__c=opp.Id, 
        																					Contract_Document_Type__c='Terms of Agreement');
        //Assert for the contact data
        opp = [Select LOA_Sent_Date__c from Opportunity where Id =: opp.Id limit 1];
        System.assertEquals(Date.today()+1, opp.LOA_Sent_Date__c);
        
        //Stop test here
        Test.stopTest();
    }
}