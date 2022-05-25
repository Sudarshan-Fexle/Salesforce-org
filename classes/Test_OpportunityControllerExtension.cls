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
private class Test_OpportunityControllerExtension {
/**
    Purpose         :   Test class for CaseTriggerHelper
                
    Create By       :   Abhinav Sharma
    
    Created Date    :   05/20/2016
    
    Revision Log    :   V1.0 - Created - Abhinav Sharma - CR-20160308-9682
                        V1.1 - Modified - Saurabh kumar - updateMainContactsOnCurrentAndFutureOpp as per CR-20170908-11190
    			V1.2 - Modified - Deepak kumar - 1/09/2018 - Increase the test coverage
			V1.3 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes

  Coverage Log  :  v1.0 - OpportunityControllerExtension - 90%
                          
**/
    
    //Common test data setup for entire test class
    @testSetup static void setupTestData() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        //Account
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;
        System.assert(acc != null);
        
        //Program
        Program__c testProg1 = new Program__c(Name='Test Trigger Program', New_Business_Marketer__c = 'RI Marketer', 
                                              Program_Acronym__c='ZZZ', Create_memberships__c='No', Business_line__c = 'PT');
        insert testProg1;
    System.assert(testProg1 != null);
        
        //Contact
        Contact con = new Contact(FirstName = 'First', LastName = 'Last', Contact_Status__c = 'Active', AccountId = acc.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert con;
        System.assert(con != null);

        //List of Opportunities
        list<Opportunity> opps = new list<Opportunity>();
        
        //Retreiving "PT Contract Renewal" Record type for Opportunity object
        List<RecordType> oppRecordTypes = [SELECT ID, DeveloperName FROM RecordType 
                                             WHERE SobjectType = 'Opportunity' 
                                             AND IsActive = true 
                                             AND DeveloperName = 'BI_Contract_Renewal'];
        
        //Asserting for the results
        System.assert(oppRecordTypes != null);
        System.assert(oppRecordTypes.size() > 0);

        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Opportunity
        Opportunity opp1 = new Opportunity();
        opp1.AccountId = acc.Id;
        opp1.Name = 'Test';
        opp1.StageName = 'Pending1';
        opp1.CloseDate = System.today();
        opp1.RecordTypeId = oppRecordTypes[0].Id;
        opp1.Main_Contact__c = con.Id;
        opp1.Program__c = testProg1.Id;
        opp1.Sales_Pursuit_Products__c = 'APS';
        
        //Opportunity Instance
        Opportunity opp2 = new Opportunity();
        opp2.AccountId = acc.Id;
        opp2.Name = 'Test';
        opp2.StageName = 'Pending2';
        opp2.CloseDate = System.today();
        opp2.RecordTypeId = oppRecordTypes[0].Id;
        opp2.Main_Contact__c = con.Id;//null;
        opp2.Program__c = testProg1.Id;
        opp2.Sales_Pursuit_Products__c = 'APS';
        
        //Adding opportunity record instance into the list
        opps.add(opp1);
        opps.add(opp2);
        
        //Enabling triggers
        Util.BypassAllTriggers = false;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Insert opportunities
        insert opps;
    }
    
  static testmethod void myUnitTest() { 
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //List of opportunity
        List<Opportunity> opportunities = [SELECT ID, Main_Contact__c, StageName 
                                             FROM Opportunity ORDER BY StageName ASC];
        System.assert(opportunities != null);
        System.assertEquals(2, opportunities.size());
        System.assertEquals('Pending1', opportunities[0].Stagename);
        System.assertEquals('Pending2', opportunities[1].Stagename);
        System.assert(opportunities[0].Main_Contact__c != null);
        //System.assert(opportunities[1].Main_Contact__c == null);
        
        //List of Opportunity Contact Roles
        List<OpportunityContactRole> opportunityContactRoles = [SELECT ID, OpportunityId, ContactId, IsPrimary 
                                                                FROM OpportunityContactRole];
        System.assert(opportunityContactRoles != null);
        //System.assertEquals(1, opportunityContactRoles.size());
        System.assertEquals(true, opportunityContactRoles[0].IsPrimary);
        System.assertEquals(opportunities[0].Id, opportunityContactRoles[0].OpportunityId);
        
        //Start test from here
        Test.startTest();
        
        //Setting current pagereference
        PageReference pageRef = Page.Opp_Ext_Invoke_OCR_Onview_Trigger;
        pageRef.getParameters().put('id', String.valueOf(opportunities[0]));
        Test.setCurrentPage(pageRef);
        
        //Standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(opportunities[0]);
        OpportunityControllerExtension controller = new OpportunityControllerExtension(sc);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Updating Main Contact field on opportunity to unsync it with respect to OCR records
        opportunities[0].Main_Contact__c = null;
        opportunities[1].Main_Contact__c = null;
        update opportunities;
        
        //Calling action method responsible for invoking OCR Onview trigger future method
        controller.rollupOpportunityContactRoles();
        controller.showMore();
        Integer totalProductCountValue = controller.totalProductCount;
        List<OpportunityLineItem> listOppProductsValue = controller.listOppProducts;
        
        //Stop Test here
        Test.stopTest();
        
        //Asserting for the results
        opportunities = [SELECT ID, Main_Contact__c, StageName 
                                             FROM Opportunity ORDER BY StageName ASC];
        System.assert(opportunities != null);
        System.assertEquals(2, opportunities.size());
        System.assertEquals('Pending1', opportunities[0].Stagename);
        System.assertEquals('Pending2', opportunities[1].Stagename);
        System.assert(opportunities[0].Main_Contact__c != null);
        System.assert(opportunities[1].Main_Contact__c == null);
  }
}