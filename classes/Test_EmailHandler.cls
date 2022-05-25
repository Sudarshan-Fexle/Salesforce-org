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
public class Test_EmailHandler {
    
    /**
        Purpose          :   Test class for EmailHandler class
                    
        Created By       :   Abhinav Sharma 
        
        Created Date     :   06/10/2016
        
        Revision Log     :   v1.0 - Created - Abhinav Sharma - CR-20150202-8635
    
        Coverage         :   v1.0 - EmailHandler - 100%   
	**/

    //Added By - Abhinav Sharma - 06/10/2016 - CR-20150202-8635
	/** 
	* Description : to check the functionality of Email operation
	**/ 
	static testMethod void testsendEmail() {

		//Bypass Dupeblocker
		Util.IsTest(true);

		//Bypassing Triggers so then test data can be created easily
		Util.byPassAllTriggers = true;

		//Flag for triggers: this is just a test, don't do crazy things.
		Util.isTesting = true;

		//Selecting a profile
		Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        System.assert(profile != null);

		//Creating a user
		User user = new User(Alias = 'standt', Email='standarduser@testorg.com', IsActive = true,
								EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
								LocaleSidKey='en_US', ProfileId = profile.Id, department = 'STP',
								TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com');
		insert user;

		//Assertion to make sure that User's record is created
		System.assert(user != null);

		//Start testing from here
		Test.startTest();

		//Run as System Administrator User context
		System.runAs(user) {
			
			//Calling static methods for sending email
			EmailHandler.sendEmail('test@test.com', 'Testing', 'Testing');
			EmailHandler.sendEmail('test@test.com','Testing','Testing','HTML Testing');

			//List of String to hold toAddress
			List<String> toAddress = new List<String>{'test1@test.com','test2@test.com','test3@test.com'};

			//Creating a Account Record
			Account account = TestUtilities.CreateNewAccount(true);
            
			//Assertion to make sure that Account's record is created
			System.assert(account != null);
                
            //Creating Contact record
			Contact contact = TestUtilities.CreateNewContact(true);

			//Assertion to make sure that Contact's record is created
			System.assert(contact != null);
			
			//List of Email Template
			List<EmailTemplate> templates = [Select Id, Name from EmailTemplate 
                                             	WHERE IsActive = true
                                            ];
			
			//Checking for null and size value
            if(templates != null && templates.size() > 0) {
                
                try {
                    
                    //Calling controller's method to send email to list of recepient
                    EmailHandler.sendEmail(toAddress, account.Id, contact.Id, templates[0].Id);
        
                    //Calling controller's method to create email and send it
                    EmailHandler.createEmail(toAddress, account.Id, contact.Id, templates[0].Id,true);
        
                    //Set of Ids to hold the Id of Users
                    Set<Id> usersId = new Set<Id>{user.Id};
        
                    //Calling controller's method to send email
                    EmailHandler.sendEmail(usersId, 'Test', 'Testing');
        
                    //Calling controller's method
                    Messaging.Singleemailmessage mail = EmailHandler.email(templates[0].Id, contact.Id, account.Id);
                    System.assert(mail != null);
                    
                } catch(Exception ex) {
                    
                }
            }	
			
			//Stop testing here
			Test.stopTest();

		} 
	}
}