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
public class Test_CloneWithItemsController {
/**
 *  Purpose         :   Test class for CloneWithItemsController
 *               
 *  Created By      :   Abhinav Sharma
 *   
 *  Created Date    :   08/01/2016
 *   
 *  Revision Log    :   v1.0 - Created - Abhinav Sharma - In order to fix the test failure.
 *                       
 *  Coverage        :   v_1.0 - CloneWithItemsController - 60%
**/
    
    //Modified by - Abhinav Sharma - To fix out the test failure
    /** Description : Method to test out CloneWithItemsController class related logic and functionality.               
    **/
    static testMethod void testCloneWithItemsController() {
        
            
            //Bypass Dupeblocker
            Util.IsTest(true);
            
            //Bypassing Triggers so then test data can be created easily
            Util.byPassAllTriggers = true;
            
            //Flag for triggers: this is just a test, don't do crazy things.
            Util.isTesting = true;
            
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
                
                //Creating test data
                
                //List of clone child item settings
                List<CloneChildItemSettings__c> cloneChildItemSettings = new List<CloneChildItemSettings__c>();
                
                //CloneChildItemSettings__c record instance
                CloneChildItemSettings__c set1 = new CloneChildItemSettings__c(Name = 'test setting 1', Parent_Object__c = 'Account', 
                                                                               Child_Object__c = 'Contact', Active__c=true, 
                                                                               Lookup_Field_Name__c='AccountId');
                
                //Adding elements into the list
                cloneChildItemSettings.add(set1);
                insert cloneChildItemSettings;
                
                //Asserting for the results
                System.assert(cloneChildItemSettings != null);
                System.assert(cloneChildItemSettings.size() > 0);
                System.assertEquals(1, cloneChildItemSettings.size());
                
                //List of CloneIgnoredFieldsSettings__c records
                List<CloneIgnoredFieldsSettings__c> cloneIgnoredFieldsSettings = new List<CloneIgnoredFieldsSettings__c>();
                
                //Creating record instances
                CloneIgnoredFieldsSettings__c set2 = new CloneIgnoredFieldsSettings__c(Name ='test setting 2', Object__c = 'Account', 
                                                                                       Field__c = 'Description');
                CloneIgnoredFieldsSettings__c set3 = new CloneIgnoredFieldsSettings__c(Name ='test setting 3', Object__c = 'Contact', 
                                                                                       Field__c = 'Email');
                
                //Adding records into the list
                cloneIgnoredFieldsSettings.add(set2);
                cloneIgnoredFieldsSettings.add(set3);
                insert cloneIgnoredFieldsSettings;
                    
                //Asserting for the results
                System.assert(cloneIgnoredFieldsSettings != null);
                System.assert(cloneIgnoredFieldsSettings.size() > 0);
                System.assertEquals(2, cloneIgnoredFieldsSettings.size()); 
                
                // create account
                Account a = new Account(Name = 'test account', Description='tobecleared');
                insert a;
                
                // create contact
                Contact c = new Contact(LastName = 'Test', AccountId = a.Id, Email='tobecleared@email.com',Title = 'Director' ,Phone = '345678998');
                insert c;
                
                //Start test from here
                Test.startTest();
                
                //Loading VF page
                ApexPages.standardController stc = new ApexPages.StandardController(a);
                ClonewithItemsController ctrl = new ClonewithItemsController(stc);
                PageReference pge = ctrl.cloneWithItems();
                
                //Stop test here
                Test.stopTest();
            }       
        
    } 
}