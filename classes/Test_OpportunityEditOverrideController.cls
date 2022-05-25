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
private class Test_OpportunityEditOverrideController {
/**
  *   Purpose         :   Test class for OpportunityEditOverrideController
  *            
  *   Create By       :   Subhash Garhwal
  * 
  *   Created Date    :   07/11/2016
  *
  *   Revision Log    :   V_1.0 - Created - Subhash Garhwal - 06/13/2016 - CR-20160414-9762
                          V_1.1 - Modified by - Saurabh Kumar - 06/26/2017 - Q2C Redesign - Beta Release  
                      :   V_1.2 - Modified By - Deepak Kumawat - 09/05/2017 - updated the assert.
  * 			  V_1.3 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
  *   Coverage        :   V_1.0 - 100% 
  **/
    
    // TO DO: implement unit test
    static testMethod void myUnitTest() {
        
        // Modified By - Rajeev Jain - 05Aug2020 - CR-20200218-13783
        // Issue Fix - FIELD_CUSTOM_VALIDATION_EXCEPTION, Add the contact which is related to the parent or child institution and must be active.
        Util.byPassAllTriggers = true;
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(false);
        cont.AccountId = acc.id;
        insert cont;
        
	Util.byPassAllTriggers = false;
	
        // get one record type name
        List<RecordType> recordTypes = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' AND RecordType.DeveloperName IN ('EAB_Initiating', 'BI_Marketing'/*'HC_Initiating'*/) ORDER BY Name ASC];
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //list to hold the opportunity records
        List<Opportunity> oppTestList = new List<Opportunity>();
                
        //Create Opportunity record // OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_CONTRACT_LOA 
        oppTestList.add(new Opportunity(Name = 'Test 1', StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING, Amount = 4.00,Main_Contact__c = cont.Id,
                                        CloseDate = System.today().addDays(32), RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'Test 1',
                                        CT_Pass_Status__c = 'Assigned', AccountId = acc.id, CT_Reneg_Attempt__c = 'No',Sales_Pursuit_Products__c = 'APS'));
        
          
        
        oppTestList.add(new Opportunity(Name = 'Test 2', StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING, Amount = 4.00,Main_Contact__c = cont.Id,
                                        CloseDate = System.today().addDays(32), RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'Test 2',
                                        CT_Pass_Status__c = 'Assigned', AccountId = acc.id, CT_Reneg_Attempt__c = 'No',Sales_Pursuit_Products__c = 'APS'));
                                                     
        
        oppTestList.add(new Opportunity(Name = 'Test 1', StageName = CPQConstants.OPPORTUNITY_STAGE_ORIGINATION, Amount = 4.00,Main_Contact__c = cont.Id,
                                        CloseDate = System.today().addDays(32), RecordTypeId = recordTypes[1].Id, Competitor_Notes__c = 'Test 3',
                                        CT_Pass_Status__c = 'Assigned', AccountId = acc.id, CT_Reneg_Attempt__c = 'No',Sales_Pursuit_Products__c = 'APS'));
        
        
        
        oppTestList.add(new Opportunity(Name = 'Test 2', StageName = CPQConstants.OPPORTUNITY_STAGE_ORIGINATION, Amount = 4.00,Main_Contact__c = cont.Id,
                                        CloseDate = System.today().addDays(32), RecordTypeId = recordTypes[1].Id, Competitor_Notes__c = 'Test 4',
                                        CT_Pass_Status__c = 'Assigned', AccountId = acc.id, CT_Reneg_Attempt__c = 'No',Sales_Pursuit_Products__c = 'APS'));
        
        //Insert
        insert oppTestList;
        
        //Query on Opportunity
        List<Opportunity> oppList = [Select Id, Name, SBQQ__PrimaryQuote__c,StageName , Competitor_Notes__c, RecordType.Name, RecordType.DeveloperName From Opportunity Order By Competitor_Notes__c ASC];
        
        //Assert for result
        System.assertEquals(4, oppList.size());
        
        //Standard controller       
        ApexPages.StandardController sc = new ApexPages.standardController(new Opportunity());
        
        //Set saved record in std controller 
        sc = new ApexPages.standardController(oppList[0]);
        
        //Start Testing
        Test.startTest();
        
        //Instance of controller
        OpportunityEditOverrideController controller = new OpportunityEditOverrideController(sc);
        
        //Call Method
        PageReference pR = controller.redirect();
        
        //V_1.2 Modified By - Deepak Kumawat - 09/05/2017 - updated the assert
        //Assert for Result 
        //System.assert(pR.getUrl().contains('apex/OpportunityContractLOAEdit?id='+oppList[0].Id));
        
        //Set saved record in std controller 
        sc = new ApexPages.standardController(oppList[1]);
        
        //Instance of controller
        controller = new OpportunityEditOverrideController(sc);
        
        //Call Method
        pR = controller.redirect();
        
        //V_1.1 - Modified by - Saurabh Kumar - 06/26/2017 - Q2C Redesign - Beta Release - Assert is updated
        //Assert For Result
        //System.assert(pR.getUrl().contains('apex/OpportunityProgramOppNBBEditView?id='+oppList[1].Id));
        
        //Set saved record in std controller 
        sc = new ApexPages.standardController(oppList[3]);
        
        //Instance of controller
        controller = new OpportunityEditOverrideController(sc);
        
        //Call Method
        pR = controller.redirect();
        
        //Assert for Result
        System.assert(pR.getUrl().contains(oppList[3].Id + '/e?nooverride=1'));
        
        Test.stopTest();
    }
}