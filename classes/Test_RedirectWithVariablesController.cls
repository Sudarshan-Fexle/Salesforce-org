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
private class Test_RedirectWithVariablesController {

    /**
        Purpose         :   Test class for RedirectWithVariablesController
                    
        Create By       :   Abhinav Sharma
        
        Created Date    :   01/27/2015
        
        Revision Log    :   v1.0 - Created
        
        Coverage        :   100% - RedirectWithVariablesController
    
    **/
    
    static testMethod void myUnitTest() {
    
        //Pagereference varible
        Pagereference pageRef;
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Getting Record Type Id for Account
        ID accRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Account' and Name = 'External' AND IsActive = true].Id;
          
        //Account
        Account acc = testUtilities.CreateNewAccount(true);
        
        //Start Test from here
        Test.startTest();
        
        //Setting page paramters
        pageRef = new Pagereference('/apex/RedirectWithVariables?newid=001M000000hCdcLIAS&retURL=test&saveURL=test&redirect=object--account!!id--001M000000XRQwgIAH');
        Test.setCurrentPage(pageRef);
         
        //Loading the VF page
        RedirectWithVariablesController controller_1 = new RedirectWithVariablesController();
        controller_1.redirectUser();
        System.assert(controller_1.redirectUser() != null);
        
        //Setting page paramters
        pageRef = new Pagereference('/apex/RedirectWithVariables?newid=001M000000hCdcLIAS&retURL=test&saveURL=test&redirect=object--account!!name--test');
        Test.setCurrentPage(pageRef);
        
        //Loading the VF page
        RedirectWithVariablesController controller_2 = new RedirectWithVariablesController();
        controller_2.redirectUser();
        System.assert(controller_2.redirectUser() != null);
        
        //Setting page paramters
        pageRef = new Pagereference('/apex/RedirectWithVariables?newid=001M000000hCdcLIAS&retURL=test&saveURL=test&redirect=object--account!!returnURL--test');
        Test.setCurrentPage(pageRef);
        
        //Loading the VF page
        RedirectWithVariablesController controller_3 = new RedirectWithVariablesController();
        controller_3.redirectUser();
        System.assert(controller_3.redirectUser() != null);
        
        //Setting page paramters
        pageRef = new Pagereference('/apex/RedirectWithVariables?newid=001M000000hCdcLIAS&retURL=test&saveURL=test&redirect=object--account!!afterSaveURL--test');
        Test.setCurrentPage(pageRef);
        
         //Loading the VF page
        RedirectWithVariablesController controller_4 = new RedirectWithVariablesController();
        controller_4.redirectUser();
        System.assert(controller_4.redirectUser() != null);
        
        //Setting page paramters
        pageRef = new Pagereference('/apex/RedirectWithVariables?newid=001M000000hCdcLIAS&retURL=test&saveURL=test&redirect=object--account!!recordTypeName--US_Corporate');
        Test.setCurrentPage(pageRef);
        
        //Loading the VF page
        RedirectWithVariablesController controller_5 = new RedirectWithVariablesController();
        controller_5.redirectUser();
        System.assert(controller_5.redirectUser() != null);
        
        //Setting page paramters
        pageRef = new Pagereference('/apex/RedirectWithVariables?newid=001M000000hCdcLIAS&retURL=test&saveURL=test&redirect=object--account!!allowRTS--true');
        Test.setCurrentPage(pageRef);
        
        //Loading the VF page
        RedirectWithVariablesController controller_6 = new RedirectWithVariablesController();
        controller_6.redirectUser();
        System.assert(controller_6.redirectUser() != null);
        
        //Setting page paramters
        pageRef = new Pagereference('/apex/RedirectWithVariables?newid=001M000000hCdcLIAS&retURL=test&saveURL=test&redirect=object--project__c!!allowRTS--true');
        Test.setCurrentPage(pageRef);
        
        //Loading the VF page
        RedirectWithVariablesController controller_7 = new RedirectWithVariablesController();
        controller_7.redirectUser();
        System.assert(controller_7.redirectUser() != null);
        
        //Setting page paramters
        pageRef = new Pagereference('/apex/RedirectWithVariables?newid=001M000000hCdcLIAS&retURL=test&saveURL=test&redirect=object--account!!allowRTS--false');
        Test.setCurrentPage(pageRef);
        
        //Loading the VF page
        RedirectWithVariablesController controller_8 = new RedirectWithVariablesController();
        controller_8.redirectUser();
        System.assert(controller_8.redirectUser() != null);
        
        //Setting page paramters
        pageRef = new Pagereference('/apex/RedirectWithVariables?newid=001M000000hCdcLIAS&retURL=test&saveURL=test&redirect=object-account!!allowRTS--false');
        Test.setCurrentPage(pageRef);
        
        //Loading the VF page
        RedirectWithVariablesController controller_9 = new RedirectWithVariablesController();
        controller_9.redirectUser();
        System.assert(controller_9.redirectUser() == null);
        
        //Setting page paramters
        String accId = acc.Id;
        pageRef = new Pagereference('/apex/RedirectWithVariables?newid=001M000000hCdcLIAS&retURL=test&saveURL=test&redirect=object--account!!parentid--' + accId);
        Test.setCurrentPage(pageRef);
        
        //Loading the VF page
        RedirectWithVariablesController controller_10 = new RedirectWithVariablesController();
        controller_10.redirectUser();
        System.assert(controller_10.redirectUser() != null);
        
        //Setting page paramters
        pageRef = new Pagereference('/apex/RedirectWithVariables?newid=null&retURL=test&saveURL=test&redirect=object--account!!allowRTS--false');
        Test.setCurrentPage(pageRef);
        
        //Loading the VF page
        RedirectWithVariablesController controller_11 = new RedirectWithVariablesController();
        controller_11.redirectUser();
        System.assert(controller_11.redirectUser() != null);
        
        //Stop Test here
        Test.stopTest();
    }
}