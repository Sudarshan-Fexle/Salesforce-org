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
    Purpose         :   Test class for CaseRequestController
                
    Create By       :   Abhinav Sharma
    
    Created Date    :   02/25/2015
    
    Revision Log    :   v1.0 - Created - Abhinav Sharma - CR-20150113-8543
    
    Coverage        :   v1.0 - CaseRequestController - 97% - 02/25/2015
					:	v1.1 - Modified by - Subhash Garhwal - 01/31/2017 - CR-20160121-9555
                        
**/
@isTest(seeAllData=false)
private class Test_CaseRequestController {

    static testMethod void myUnitTest() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> rdTypes = [SELECT ID FROM RecordType Where sObjectType = 'Case' AND IsActive = true 
                                                AND DeveloperName = 'eTech_Support'];
                                                
        //Checking record types list for size value
        if(rdTypes.size() > 0) {
            
            //Profile    
            Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
            System.assert(p != null);
            
            //User
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                                TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com', Employee_ID__c = '43435354545454545454545');
        
            //The following code runs as user 'u'  
            System.runAs(u) {
            
                //Create dummy data for testing Purpose
                Account acc = new Account();
                acc.Name = 'Test Account';
                insert acc;
           
                //Create a list of Contact records
                List<Contact> conList = new List<Contact>();
            
                //Querying Details for "Member & Employee Support" record type on Case Object
                List<RecordType> contactRdTypes = [SELECT ID FROM RecordType Where sObjectType = 'Contact' AND IsActive = true 
                                                    AND DeveloperName = 'Employee'];
                                                    
                //Assert for the result
                System.assert(contactRdTypes != null);
            
                //create new Contact
                Contact con1 = new Contact(FirstName = 'Test', LastName = 'Contact1', Email = 'test1@test.com',
                                            Phone = '21212121', AccountId = acc.Id, RecordTypeId = contactRdTypes[0].ID, Employee_Id__c = '43435354545454545454545');
                
                //create new Contact
                Contact con2 = new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'test2@test.com',
                                            Phone = '31313131', AccountId = acc.Id, RecordTypeId = contactRdTypes[0].ID, Employee_Id__c = '43435354545454545454546');
                
                //create new Contact
                Contact con3 = new Contact(FirstName = 'Test', LastName = 'Contact3', Email = 'test3@test.com',
                                            Phone = '41414141', AccountId = acc.Id, RecordTypeId = contactRdTypes[0].ID, Employee_Id__c = '43435354545454545454547');
                
                //create new Contact
                Contact con4 = new Contact(FirstName = 'Test', LastName = 'Contact4', Email = 'test4@test.com',
                                            Phone = '51515151', AccountId = acc.Id, RecordTypeId = contactRdTypes[0].ID, Employee_Id__c = '43435354545454545454548');
            
                conList.add(con1);
                conList.add(con2);
                conList.add(con3);
                conList.add(con4);
                insert conList;
                
                //Querying contact details
                List<Contact> contacts = [SELECT ID, Name FROM Contact WHERE ID IN : conList ORDER BY LastName ASC];
            
                //Assert for the results
                System.assert(contacts != null);
                System.assertEquals(4, contacts.size());
                
                //Start Test from here
                Test.startTest();
                
                //Loading the VF page
                CaseRequestController controller = new CaseRequestController ();
                
                //Populating inputs on the VF page
                controller.usersAffected = 'Individual User';
                controller.individualUserSelectedID = contacts[0].Id;
                controller.individualUserSelectedName = contacts[0].Name;
                controller.userToCloneID = contacts[1].Id;
                controller.userToCloneName = contacts[1].Name;
                controller.whatvalue = 'Testing 1';
                controller.businsesCase = 'Testing 2';
                controller.reason = 'Testing 3';
                controller.requestedCompletionDate = System.today();
                controller.dummyIndividualUserSelectedID = contacts[2].ID;
                controller.dummyIndividualUserSelectedName = contacts[2].Name;
                controller.dummyUserToCloneID = contacts[3].ID;
                controller.dummyUserToCloneName = contacts[3].Name;
                
                //v1.1 - Added by - Subhash Garhwal - 01/31/2017 - CR-20160121-9555 - Start from here
                
                List<IS_System__c> isSystems = new List<IS_System__c>();
                
                //Creating Is System records
                isSystems.add(new IS_System__c(Name = Label.Is_System_Name, Short_Name__c = Label.Is_System_Name, Status__c = 'Active'));
                isSystems.add(new IS_System__c(Name = 'Sales', Short_Name__c = 'Sales', Status__c = 'Active'));
                
                insert isSystems;
                //v1.1 - Added by - Subhash Garhwal - 01/31/2017 - CR-20160121-9555 - Upto here
                
                //Click on the submit button
                controller.submit();
                
                //v1.1 - Updated by - Subhash Garhwal - 01/31/2017 - CR-20160121-9555 - IS_System__c is added to query
                //List to hold the case records
                List<Case> cases = new List<Case>();
                cases = [SELECT ID, contactId, Individual_User_Affected__c, User_to_Clone__c, Description, Origin, Priority, Status, 
                         	Subject, Case_Category__c, Type, 
                            Requested_Completion_Date__c, Users_Affected__c, RecordTypeID, IS_System__c 
                         FROM Case LIMIT 2];
                
                //Applying asserts
                System.assertEquals(1, cases.size());
                System.assertEquals(rdTypes[0].ID, cases[0].RecordTypeId);
                System.assertEquals(contacts[1].Id, cases[0].User_to_Clone__c);
                System.assertEquals(contacts[0].Id, cases[0].Individual_User_Affected__c);
                System.assertEquals(contacts[0].Id, cases[0].ContactID);
                
                //v1.1 - Added by - Subhash Garhwal - 01/31/2017 - CR-20160121-9555 - Assertions 
                System.assertEquals(isSystems[0].ID, cases[0].IS_System__c);
                System.assertEquals('Application Support', cases[0].Type);
                
                //Delete case record
                delete cases;
                
                //Loading the VF page
                CaseRequestController controller2 = new CaseRequestController ();
                
                //Populating inputs on the VF page
                controller2.usersAffected = 'Individual User';
                controller2.individualUserSelectedID = contacts[0].Id;
                controller2.individualUserSelectedName = contacts[0].Name;
                controller2.userToCloneID = contacts[1].Id;
                controller2.userToCloneName = contacts[1].Name;
                String moreThan255CharString = 'Testingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
                moreThan255CharString += 'hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh';
                moreThan255CharString += 'hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh';
                moreThan255CharString += 'hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh';
                moreThan255CharString += 'hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh';
                moreThan255CharString += 'hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh';
                moreThan255CharString += 'hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh';
                controller2.whatvalue = moreThan255CharString;
                controller2.businsesCase = 'Testing 2';
                controller2.reason = 'Testing 3';
                controller2.requestedCompletionDate = System.today();
                controller2.dummyIndividualUserSelectedID = contacts[2].ID;
                controller2.dummyIndividualUserSelectedName = contacts[2].Name;
                controller2.dummyUserToCloneID = contacts[3].ID;
                controller2.dummyUserToCloneName = contacts[3].Name;
                
                //Click on the submit button
                controller2.submit();
                
                //List to hold the case records
                cases = [SELECT ID, contactId, Individual_User_Affected__c, User_to_Clone__c, Description, Origin, Priority, Status, Subject, Case_Category__c, Type, 
                            Requested_Completion_Date__c, Users_Affected__c, RecordTypeID FROM Case LIMIT 2];
                
                //Applying asserts
                System.assertEquals(1, cases.size());
                System.assertEquals(rdTypes[0].ID, cases[0].RecordTypeId);
                System.assertEquals(contacts[1].Id, cases[0].User_to_Clone__c);
                System.assertEquals(contacts[0].Id, cases[0].Individual_User_Affected__c);
                System.assertEquals(contacts[0].Id, cases[0].ContactID);
                System.assertEquals(255, cases[0].subject.trim().length());
                
                //Loading the VF page
                CaseRequestController controller3 = new CaseRequestController ();
                List<SelectOption> selectOptionsList = new List<SelectOption>();
                selectOptionsList = controller3.usersAffectedOptions;
                
                //Populating inputs on the VF page
                controller3.usersAffected = 'Individual User';
                controller3.userToCloneID = contacts[1].Id;
                controller3.userToCloneName = contacts[1].Name;
                controller3.whatvalue = 'Testing';
                controller3.businsesCase = 'Testing 2';
                controller3.reason = 'Testing 3';
                controller3.requestedCompletionDate = System.today();
                controller3.dummyIndividualUserSelectedID = contacts[2].ID;
                controller3.dummyIndividualUserSelectedName = contacts[2].Name;
                controller3.dummyUserToCloneID = contacts[3].ID;
                controller3.dummyUserToCloneName = contacts[3].Name;
                
                //Click on the submit button
                try {
                    controller3.submit();
                } catch(Exception ex) {
                }
                
                //Loading the VF page
                CaseRequestController controller4 = new CaseRequestController ();
                
                //Populating inputs on the VF page
                controller4.usersAffected = 'test';
                controller4.whatvalue = 'Testing';
                controller4.businsesCase = 'Testing 2';
                controller4.reason = 'Testing 3';
                
                //Click on the submit button
                try {
                    controller4.submit();
                } catch(Exception ex) {
                }
                
                //Stop Test here
                Test.stopTest();
            }           
        }
    }
}