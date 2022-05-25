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
 *  Description     :   This class is to test the functionality of CaseCreationOnRegistraionCreated
 * 
 *  Created By      :   Dipesh Gupta
 * 
 *  Created Date    :   11/30/2017
 * 
 *  Revision Log    :	V1.1 Modified by Saurabh Kumar - 10/13/2020 - CR-20200819-14447: Replaced Meeting with EAB Event
 * 		    :	V1.2 Modified by Saurabh Kumar - 11/09/2020 - CR-20201105-14664: Replaced EAB Event's Type with EAB Event's Event Type
 *                  :   V1.3 Modified by Saurabh Kumar - 11/10/2020 - Replaced Status 'Scheduled' with 'Registration Requested'
 *		    :   V1.4 Modified by Chirag Soni   - 06/22/2021 - MRS 2.0 Phase 2 (Test class fixes)
 **/
@isTest(SeeAlldata=false)
public class Test_CaseCreationOnRegistraionCreated {
    
     static testmethod void MyUnitTest() { 
         
         // Modified by Chirag Soni   - 06/22/2021 - MRS 2.0 Phase 2 (Test class fixes)
         MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
         Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
         
         // create the meeting
         //Meeting__c meeting = new Meeting__c();
         Advisory_Event__c eabEvent = new Advisory_Event__c();
         eabEvent.Begins__c = System.today();
         eabEvent.Event_Type__c = 'Research Working Sessions';
         eabEvent.Public_Name__c = 'Test';
	 eabEvent.Short_Name__c = 'Test';
	 eabEvent.Status__c = 'Open - Registration';
         eabEvent.Ends__c = System.today();
         
         insert eabEvent;
         
         //Contact Insert 
         Contact newContact = testUtilities.CreateNewContact(true);
         
         //List to hold the Registration
         list<ID> registrationIDS = new list<Id>();
         
         // create the registration
         Registration__c registration = new Registration__c();
         registration.Contact__c = newContact.Id;
         registration.EAB_Event__c = eabEvent.Id;
         //Modified by Saurabh Kumar - 11/10/2020 - Replaced Status 'Scheduled' to 'Registration Requested'
         registration.Status__c = 'Registration Requested';
         insert registration;
         
         registrationIDS.add(registration.Id);
         
         //Test starts here
         test.startTest();
         
         CaseCreationOnRegistraionCreated.createNewCaseOnRegistrationChanges(registrationIDS);
         
         //Test stops here
         test.stopTest();
         
     }
}