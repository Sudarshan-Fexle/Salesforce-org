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
public class Test_DefineRollup {
	//V1.2 - Modified By - Mahendra SwarnKar - 05/01/2019 - Commented the method as per Spring Clean up - CR-20190501-13061
    
	static testmethod void testDefineRollupClass() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Get profile list
        List<Profile> testProfile = [Select Id, Name from Profile where Name = 'System Administrator'];
        
        //Assert for results
        System.assert(testProfile != null);
        System.assert(testProfile.size() > 0);
        
        //Test User Create
        List<User> userList = new List<User>();
        
        //Insert users
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User1', 
                              FirstName='Test1', Email='testuser1@test.com',
                              Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', 
                              ProfileId=testProfile[0].Id, timezonesidkey='America/Los_Angeles', localesidkey='en_US', 
                              EmployeeNumber = '12121212', IsActive = true));
        insert userList;
        
        //Run as system administrator
        System.runAs(userList[0]) {
      
            DefineRollUp obj = new DefineRollUp();
            obj.rollupName = 'testRollup';
            obj.cancel();
            obj.selectedChildObject = 'Contract';
            obj.getFields();
            obj.selectedChildObject = 'Case';
            obj.getFields();
            obj.selectedChildObject = 'Opportunity';
            obj.getFields();
            obj.selectedField = 'Amount';
            obj.getFunctionByField();
            obj.selectedFunction = 'sum';
            obj.save();
            obj.lstAddCriteria[0].selectedCriteriaField = 'CloseDate';
            obj.lstAddCriteria[0].selectedOperator = 'equals';
            obj.lstAddCriteria[0].value = '2011/11/11';
            obj.lstAddCriteria[1].selectedCriteriaField = 'Amount';
            obj.lstAddCriteria[1].selectedOperator = 'equals';
            obj.save();
            obj.lstAddCriteria[1].selectedCriteriaField = 'Name';
            obj.lstAddCriteria[1].selectedOperator = 'None';
            obj.save();
            obj.selectedChildObject = 'Case';
            obj.getFields();
            obj.selectedField = 'CaseId';
            obj.selectedFunction = 'Count';
            obj.getOperatorByField();
            for(DefineRollUp.AddCriteria obj1 : obj.lstAddCriteria)
            {
                obj1.selectedCriteriaField = 'isclosed';
                obj.getOperatorByField();
            }
            obj.save();
            
            //Start test from here
            Test.startTest();
            
            obj.lstAddCriteria[0].selectedCriteriaField = 'None';
            obj.getOperatorByField();
            for(DefineRollUp.AddCriteria obj1 : obj.lstAddCriteria)
            {
                obj1.selectedCriteriaField = 'description';
                obj.getOperatorByField();
                obj1.value = 'testDescription';
            }
            obj.lstAddCriteria[0].selectedOperator = 'starts with';
            obj.save();
            for(DefineRollUp.AddCriteria obj1 : obj.lstAddCriteria)
            {
                obj1.selectedCriteriaField = 'type';
                obj.getOperatorByField();
                obj1.value = 'testType1, testType2';
            }
            obj.save();
            for(DefineRollUp.AddCriteria obj1 : obj.lstAddCriteria)
            {
                obj1.selectedCriteriaField = 'closeddate';
                obj.getOperatorByField();
                obj1.selectedOperator = 'equals';
                obj1.value = '2011/11/11';
            }
            obj.selectedField = 'Id';
            obj.selectedFunction = 'Count';
            obj.save();
            for(DefineRollUp.AddCriteria obj1 : obj.lstAddCriteria)
            {
                obj1.selectedCriteriaField = 'closeddate';
                obj.getOperatorByField();
                obj1.selectedOperator = 'equals';
                obj1.value = '2011/11/11';
            }
            obj.filter = '1 and 2 and 3 and 4 and 5 and 6';
            obj.save();
            obj.addRow();
            obj.removeRow();
            DefineRollUp obj1 = new DefineRollUp();
            obj1.rollupName = 'testRollup';
            obj1.selectedChildObject = 'Opportunity';
            obj1.getFields();
            obj1.selectedField = 'Id';
            obj1.getFunctionByField();
            obj1.selectedFunction = 'Count';
            obj1.lstAddCriteria[0].selectedCriteriaField = 'CloseDate';
            obj1.getOperatorByField();
            obj1.lstAddCriteria[0].selectedOperator = 'equals';
            obj1.lstAddCriteria[0].value = '2011/11/11';
            obj1.lstAddCriteria[1].selectedCriteriaField = 'Amount';
            obj1.getOperatorByField();
            obj1.lstAddCriteria[1].selectedOperator = 'equals';
            obj1.lstAddCriteria[1].value = '1000';
            obj1.save();
            DefineRollUp obj2 = new DefineRollUp();
            obj2.rollupName = 'testRollup';
            obj2.selectedChildObject = 'Case';
            obj2.getFields();
            obj2.selectedField = 'Id';
            obj2.getFunctionByField();
            obj2.selectedFunction = 'Count';
            obj2.lstAddCriteria[0].selectedCriteriaField = 'isclosed';
            obj2.getOperatorByField();
            obj2.lstAddCriteria[0].selectedOperator = 'equals';
            obj2.save();
            system.assertEquals(obj2.rollupName,obj1.rollupName);
            /*** Spring CleanUp CR-20190501-13061 ***
            List<Rollup_Definition__c> lstRollup = new List<Rollup_Definition__c>();
            for(Integer i = 0;i<55;i++)
            {
                Rollup_Definition__c objRollup = new Rollup_Definition__c(Name__c = 'test10'+string.Valueof(i), Object_Aggregated__c = 'Case', Field_Aggregated__c = 'CaseId',Aggregate_Function__c = 'Count',Criteria__c = 'IsClosed = true');
                lstRollup.add(objRollup);
            }
            insert lstRollup;
            */
            DefineRollUp obj3 = new DefineRollUp();
            
            //Stop test here
            Test.stopTest();
        }        
	}
}