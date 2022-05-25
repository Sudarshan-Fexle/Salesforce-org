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
public class SP_SalesPlanValidations_Test {
    
    public static final String TEST_CUSTOM_PERMISSION = 'VVS_Sales_Coach';
    
    @Testsetup
    public static void setUpTestData() {
        
        // Modified By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
       
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName=Math.random()+'@testorg.com');
        insert u;
        
        system.runAs(u){
        // Create PermissionSet with Custom Permission and asisgn to test user
        PermissionSet ps = new PermissionSet();
        ps.Name = 'VVS_Sales_CoachCustomPermissionTest';
        ps.Label = 'VVS_Sales_CoachCustomPermissionTest';
        insert ps;
        
        List<CustomPermission> listCustomPermission = [select Id, DeveloperName from CustomPermission where DeveloperName =: TEST_CUSTOM_PERMISSION];
        SetupEntityAccess sea = new SetupEntityAccess(ParentId = ps.Id, SetupEntityId = listCustomPermission[0].Id);
        insert sea;
        
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        }
        
    }
    //Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
    public static testMethod void testAdvanceStage() {
        // Modified By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020
        User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Testing' Limit 1];
        
       System.runAs(user1) {

        // Set up test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Id PRODUCTSANDSERVRTYPE = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products and Services').getRecordTypeId();
        
        //Modify By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c 
        //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
        Opportunity opp = new Opportunity(Name = 'Test Oppty', Sales_Pursuit_Products__c  = 'APS',recordTypeID=PRODUCTSANDSERVRTYPE, AccountId = acc.id, StageName = '1 - Plan', Order_Type__c = 'New', CloseDate = Date.Today());
        insert opp;
        
        Schema.DescribeFieldResult F = Opportunity.Stagename.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();  

        map<integer,string> pMap = new map<integer,string>();

        list<string> pVal = new list<string>();
        for(Schema.PicklistEntry o: P){
            pVal.add(o.getValue());   
        }
        system.assertEquals(true, (pVal.size() > 0));
        SP_SalesPlanValidations.pValues(pVal[0]);
        
        for(integer i = 0; i<pVal.size() ;i++){
               pMap.put(i+1,pVal[i]);            
        }
        List<Opportunity_Stage__c> stgList = new List<Opportunity_Stage__c>();
        for(Integer seq : pMap.keySet()) {
            Opportunity_Stage__c stg = new Opportunity_Stage__c(Name = pMap.get(seq), Stage_Number__c = seq);
            stgList.add(stg);
        }
        insert stgList;
        //Opportunity_Stage__c stg1 = new Opportunity_Stage__c(Name = '1 - Plan', Stage_Number__c = 1);
        //Opportunity_Stage__c stg2 = new Opportunity_Stage__c(Name = '2 - Create', Stage_Number__c = 2);
        //Opportunity_Stage__c stg3 = new Opportunity_Stage__c(Name = '3 - Qualify', Stage_Number__c = 3);
        
        Stage_Objective__c obj1 = new Stage_Objective__c(Name = 'Objective 1', Opportunity_Stage__c = stgList[0].Id, Order__c = 1);
        Stage_Objective__c obj2 = new Stage_Objective__c(Name = 'Objective 2', Opportunity_Stage__c = stgList[1].Id, Order__c = 2);
        Stage_Objective__c obj3 = new Stage_Objective__c(Name = 'Objective 3', Opportunity_Stage__c = stgList[2].Id, Order__c = 3);
        List<Stage_Objective__c> objList = new List<Stage_Objective__c>();
        objList.add(obj1);
        objList.add(obj2);
        objList.add(obj3);
        insert objList;
        
        Objective_Action__c act1 = new Objective_Action__c(Name = 'Not Required Action', Order__c = 1, Stage_Objective__c = obj1.Id);
        Objective_Action__c act2 = new Objective_Action__c(Name = 'Required Action', Order__c = 2, Stage_Objective__c = obj2.Id, Action_Type__c = 'Required', Opportunity_Order_Type__c = 'New');
        act2.Opportunity_Record_Type__c = 'Products and Services';
        List<Objective_Action__c> actList = new List<Objective_Action__c>();
        actList.add(act1);
        actList.add(act2);
        insert actList;
        
        // Begin test
        Test.startTest();
        
        opp.StageName = pMap.get(2);
        update opp;
        
        System.assertEquals(pMap.get(2), opp.StageName);
        
        opp.StageName = pMap.get(3);
        try {
            update opp;
        }
        catch (Exception e) {
            System.debug('Caught exception');
        }
        
        Opportunity getOpp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        System.assertNotEquals(pMap.get(3), getOpp.StageName);
        
        Task tsk = new Task(WhatId = opp.Id, StageObjectiveId__c = obj2.Id, ObjectiveActionID__c = act2.Id);
        tsk.Status = 'Completed';
        insert tsk;
        
        update opp;
        
        getOpp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        System.assertEquals(pMap.get(3), getOpp.StageName);
        
       
        
        Test.stopTest();
        }
    
    }

}