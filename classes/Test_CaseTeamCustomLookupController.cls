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
private class Test_CaseTeamCustomLookupController {
     /**
   *  Purpose         :  Test class for CaseTeamCustomLookupController
   *               
   *  Created By      :  
   *   
   *  Created Date    :   
   *   
   *  Revision Log    :   v1.0 - Created - 
   *                       
   *  Coverage        :   v_1.0 - 
   **/
    
    @testSetup static void setup() {
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> rdType = [SELECT ID FROM RecordType Where sObjectType = 'Case' AND IsActive = true 
                                                AND DeveloperName = 'Member_Employee_Support'];
                
        //Query for queue                                
        List<QueueSobject> lstQueues = [SELECT Id, queue.Name, QueueId FROM QueueSobject 
                                            WHERE SobjectType = 'Case' and queue.name= 'Events & Member Support'];
        
        //Assert for the results
        System.assert(rdType != null);
        System.assert(lstQueues != null);
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Create an institution
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        acct_1.Description = 'Testing RIAMLargeContract Testing';
        
        //Create an institution
        Account acct_2 = TestUtilities.CreateNewAccount(false);
        acct_2.Description = 'RIAMLargeContract';
        
        //Create an institution
        Account acct_3 = TestUtilities.CreateNewAccount(false);
        acct_3.Description = 'Testing RIAM';
        
        //Populating list with account records
        accounts.add(acct_1); accounts.add(acct_2); accounts.add(acct_3);
        
        //Insert accounts
        insert accounts;
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert 
        Case aCase = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', Subject = 'out of office', 
                                OwnerId = lstQueues[0].QueueId, Description = 'out of office');
                                
        //Create a sample case record to insert
        Case aCase_1 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', Subject = 'Test 1', 
                                Description = 'test 1', AccountId = accounts[0].Id);
                                
        //Create a sample case record to insert 
        Case aCase_2 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Phone', Subject = 'Test 2', 
                                Description = 'test 2', AccountId = accounts[1].Id);
                                
        //Create a sample case record to insert
        Case aCase_3 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Web', Subject = 'Test 3', 
                                Description = 'test 3', AccountId = accounts[2].Id);
                                
        //Create a sample case record to insert 
        Case aCase_4 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', Subject = 'Test OOO', 
                                OwnerId = lstQueues[0].QueueId, Description = 'Test 4');
                                
        //Create a sample case record to insert 
        Case aCase_5 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', Subject = 'Test Out of Offices', 
                                OwnerId = lstQueues[0].QueueId, Description = 'Test 5');
                                
        //Create a sample case record to insert
        Case aCase_6 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', Subject = 'Test 6', 
                                OwnerId = lstQueues[0].QueueId, Description = 'Test out of the Office');
                                
        //Create a sample case record to insert 
        Case aCase_7 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', Subject = 'Automatic reply : Test', 
                                OwnerId = lstQueues[0].QueueId, Description = 'Test 6');
        
        //Populating list with records instances
        cases.add(aCase);   cases.add(aCase_1); cases.add(aCase_2); cases.add(aCase_3);
        cases.add(aCase_4); cases.add(aCase_5); cases.add(aCase_6); cases.add(aCase_7);
        
        
        //Enabling triggers so then helper class written logic can be execute on DML event
        Util.byPassAllTriggers = false;
        
        //Insert Case
        insert cases;
        
        //Custom setting record
        ShipIt_Settings__c setting = new ShipIt_Settings__c();
        setting.Name = 'ContactSearchLimit';
        setting.Value__c = '1000000';
        insert setting ;
    }
    
    @isTest static void test_CaseTeamCustomLookupControllerMethod(){
        List<Case> caseList = [Select id,Subject From Case];
    
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.CaseTeamCustomLookup')); 
        System.currentPageReference().getParameters().put('lksrch', caseList[0].Subject);
        System.currentPageReference().getParameters().put('parentRecordId',caseList[0].Id);
        System.currentPageReference().getParameters().put('objectType', 'CaseTeam');
        
        //ApexPages.standardController stc = new ApexPages.StandardController(contacts[0]);
        CaseTeamCustomLookupController ctrl = new CaseTeamCustomLookupController();
        PageReference pge = ctrl.search();
        ctrl.clearSearchResults();
        ctrl.getFormTag();
        ctrl.getTextBox();
        
        system.assertEquals(caseList[0].Subject ,ctrl.searchString);
        system.assertEquals(false,ctrl.isAnyListPopulated);
        system.assertEquals('CaseTeam',ctrl.objectType);
        
       
        
        Test.stopTest();
    }
    
    @isTest static void test_CaseTeamCustomLookupControllerMethodWithCaseTeamTemplate(){
        
        List<CaseTeamTemplate> caseTempList = [Select Id,Name,Description From CaseTeamTemplate];
        
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.CaseTeamCustomLookup')); 
        System.currentPageReference().getParameters().put('lksrch', caseTempList[0].Name);
        System.currentPageReference().getParameters().put('parentRecordId', caseTempList[0].Id);
        System.currentPageReference().getParameters().put('objectType', 'CaseTeamTemplate');
     
        
        //ApexPages.standardController stc = new ApexPages.StandardController(contacts[0]);
        CaseTeamCustomLookupController ctrl = new CaseTeamCustomLookupController();
        PageReference pge = ctrl.search();
        ctrl.clearSearchResults();
        ctrl.getFormTag();
        ctrl.getTextBox();
        
        system.assertEquals(caseTempList[0].Name,ctrl.searchString);
        system.assertEquals(false,ctrl.isAnyListPopulated);
        system.assertEquals('CaseTeamTemplate',ctrl.objectType);
        
        Test.stopTest();
    }
    
    @isTest static void test_CaseTeamCustomLookupControllerMethodWithBlankSearch(){
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.CaseTeamCustomLookup'));
        System.currentPageReference().getParameters().put('lksrch', '');
        System.currentPageReference().getParameters().put('searchString', '');
        System.currentPageReference().getParameters().put('objectType','Test');
        System.currentPageReference().getParameters().put('results','');
        
        CaseTeamCustomLookupController ctrl = new CaseTeamCustomLookupController();
        PageReference pge = ctrl.search();
        ctrl.clearSearchResults();
        ctrl.getFormTag();
        ctrl.getTextBox();
        Test.stopTest();
    }
}