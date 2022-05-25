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
 *  Purpose         :   Test class for IntranetUserInfoClass
 * 
 *  Created By      :   
 * 
 *  Created Date    :   09/24/2014
 * 
 *  Revision Logs   :   Created
 * 					:	V1.0 - Modified By - Rajeev Jain - CR-7579	- 09/03/2015 - Increase code coverage and code indentation, improve asserts
 * 
 *  Coverage        :   96%
 **/    
@isTest
private class Test_IntranetUserInfo {
    
    static testMethod void myUnitTest() {       
        
        //Start Test
        Test.startTest();
        
        //Query to Get user
        List<User> userList = [select Id, Name, FirstName, LastName, Title, Email, 
                               Phone, SmallPhotoUrl, ManagerId, Manager.Name, Workspace_Number__c, 
                               Office__c, ABC_Department__c from User where Id = : UserInfo.getUserId()];
        
        IntranetUserInfo controller = new IntranetUserInfo(userList[0]);
        controller.ToString('Test');
        controller.SortOrder = '1';
        
        //Assert to check same user name as current logged in user name
        System.assertEquals(UserInfo.getFirstName(), controller.FirstName);
        System.assertEquals(UserInfo.getUserId(), controller.UserId);
        
        IntranetUserInfo controller2 = new IntranetUserInfo(new User(Id = UserInfo.getUserId()));
        controller2.SortOrder = '2';
        
        //Cover Sort Method
        List<IntranetUserInfo> listController = new List<IntranetUserInfo>();
        listController.add(controller);
        listController.add(controller2);
        listController.sort();
              
        //Stop Test
        Test.stopTest();
    }
}