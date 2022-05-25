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
* Description   :   Test class to test GenericHistoryComponentController
*
* Created By    :   Rajeev Jain
*
* Created Date  :   22/08/2018
*
* Version       :   V1.0 Created
*             
**/ 
@isTest
private class Test_genericHistoryComponentController {
    
    static testMethod void testGenericHistoryComponentController() {
        
        Util.IsTest(true);
        //Create data 
        Account acct = TestUtilities.CreateNewAccount(true);
        Program__c prog = TestUtilities.CreateNewProgram(true);
        Membership__c membership = TestUtilities.CreateNewMembership(acct.Id, prog.Id, true);
        
        //Initialize class to test
        GenericHistoryComponentController obj = new GenericHistoryComponentController();
        //Adding member record to attribute
        obj.myObject = membership;
        //Update member to create history
        Membership__c memberUpdate = new Membership__c(Id=membership.Id , MH_Grade__c = 'Monitor');
        update memberUpdate;
        
        //Insert record in member_history object
        Membership__History objectHistory = new Membership__History(ParentId = membership.Id, Field = 'MH_Grade__c');
        insert objectHistory;

        //get list of history tracking data
        List<GenericHistoryComponentController.objectHistoryLine> listOfHistoryDetails = obj.getObjectHistory();
        
        //Calling method for non covered cases
        GenericHistoryComponentController.returnFieldLabel('MH_Grade__c');
        
        //Assert o check if history tracking data is created and displayed
        System.assert(listOfHistoryDetails.size() > 0);
        
        GenericHistoryComponentController.returnFieldLabel('test__c');
        GenericHistoryComponentController.returnFieldLabel(null);
        
       
    }  
}