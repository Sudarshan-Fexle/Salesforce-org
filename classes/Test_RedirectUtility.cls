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
private class Test_RedirectUtility {
    
    /**
        Purpose         :   Test class for RedirectUtility
                
        Create By       :   Abhinav Sharma
    
        Created Date    :   01/27/2015
    
        Revision Log    :   v1.0 - Created
    
        Coverage        :   90% - RedirectUtility
    **/
    
    static testMethod void myUnitTest() {
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Getting Record Type Id for Account
        ID accRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Account' and Name = 'External' AND IsActive = true].Id;
        
        //Account
        Account acc = new Account(Name='tempname', Account_Formal_Name__c = 'test', RecordTypeId = accRecordTypeId );
        insert acc;
          
        //Setting page paramters
        Pagereference pageRef = new Pagereference('/apex/RedirectWithVariables?def_account_id=' + acc.ID + '&RecordType=' + accRecordTypeId);
        Test.setCurrentPage(pageRef);
        
        //Setting varibles and calling methods
        sObject sObj = acc.Id.getsObjectType().newSobject(acc.Id);
        Map<String, String> allParams = new Map<String, string>();
        allParams.put('name', 'name');
        allParams.put('Account Plan Last Updated', String.valueOf(System.today()));
        allParams.put('CreatedDate', String.valueOf(System.now()));
        allParams.put('Active in MRS', 'true');
        allParams.put('Active CM Memberships', 'yes');
        allParams.put('parentid', '001M000000hCdcLIAS');
        allParams.put('RecordTypeId', String.valueOf(accRecordTypeId));
        
        //Start Test from here
        Test.startTest();
        
        //Calling method
        RedirectUtility.createLabelParameters(null, sObj, allParams);
        System.assert(RedirectUtility.createLabelParameters(null, sObj, allParams) != null);
        
        RedirectUtility.getLabel('account', 'name');
        System.assert(RedirectUtility.getLabel('account', 'name') == 'Institution Name');
        
        //Stop Test here
        Test.stopTest();
    }
}