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
 *  Description     :   test class to test the functionality of Batch_UpdateInActiveOwnershipToSFAdmin
 * 
 *  Created By      :   Dipesh Gupta  
 * 
 *  Created Date    :   08/18/2017
 * 
 *  Revision Logs   :   V_1.0 - Created --CR-20170412-10836
 *
 **/ 
 
@istest(seeAllData=false)
public class Batch_UpdateInActiveOwnershipToSFAdTest {
	
	
	/*@testSetup static void setUp () {
		
		//Inserting the User records.
		//Bypass Dupeblocker
	    Util.IsTest(true);
	
	    //Bypass Triggers
	    Util.BypassAllTriggers = true;
	    
	    //Create a user for running the process
        Profile specialistProfile = [SELECT Id FROM Profile WHERE Name = 'Specialist' LIMIT 1];
        
        //Create a user for running the process
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        
        User user1 = testUtilities.CreateNewUser(specialistProfile, false);
        user1.LastName = 'SpecialistUser';
        insert user1;
        
        
        User sFAdminUser = testUtilities.CreateNewUser(sysAdminProfile, false);
        sFAdminUser.LastName = 'SystemAdminUserLastName';
        insert sFAdminUser;
        
        //inserting the custom setting data 
        User_InActive_Ownership_To_SFAdmin__c userInactiveSetting = new User_InActive_Ownership_To_SFAdmin__c();
       
        userInactiveSetting.Batch_Size__c = 200;
        userInactiveSetting.Last_N_Hours__c = 1;
        userInactiveSetting.SFAdmin_Id__c = sFAdminUser.Id;
        
        insert userInactiveSetting;
        
        //Enable Triggers
	    Util.BypassAllTriggers = false;
    }*/
    
    /**
	 *  Description     :   test class to test the functionality of Batch_UpdateInActiveOwnershipToSFAdmin - Calling batch but no user is Inactive
	 * 
	 *  Created By      :   Dipesh Gupta  
	 * 
	 *  Created Date    :   08/18/2017
	 * 
	 *  Revision Logs   :   V_1.0 - Created
	 *
	 **/ 
	/*static testmethod void myUnitTest() {
    	
    	//Query on the user
        List<User> users = [Select Id, IsActive, LastName From User Where Profile.Name =: 'Specialist' AND LastName =: 'SpecialistUser'];
        
        //Asserts on Results
        System.assert(users != null);
        System.assertEquals(1, users.size());
        System.assert((users[0].IsActive == true));
        
        system.runAs(users[0]) {	
        	
            //Bypass Triggers
	    	Util.BypassAllTriggers = true;
	    
        	//Inserting Account
    		Account acc = TestUtilities.CreateNewAccount(true);
    		
        	//Creating contact for the user
        	List<Contact> con = New List<Contact>();
        	con.add(new Contact (LastName = 'Test-1' , AccountId = acc.Id, Primary_Address_Line_1__c = '103/71', 
        					Primary_City__c = 'Test_City', Primary_Postal_Code__c = '1000', Primary_Country__c = 'Brazil'));
			con.add(new Contact (LastName = 'Test-2' , AccountId = acc.Id, Primary_Address_Line_1__c = '103/71', 
							Primary_City__c = 'Test_City', Primary_Postal_Code__c = '1000', Primary_Country__c = 'Brazil'));
			con.add(new Contact (LastName = 'Test-3' , AccountId = acc.Id, Primary_Address_Line_1__c = '103/71', 
							Primary_City__c = 'Test_City', Primary_Postal_Code__c = '1000', Primary_Country__c = 'Brazil'));
							
			insert con;
            
            //Enable Triggers
	    	Util.BypassAllTriggers = false;
	    
        }

        //List to hold the contact to checj the owner of contact
        List<Contact> contacts = [Select Id, OwnerId From Contact order by CreatedDate];
        
        //Asserts on Results
        system.AssertEquals(users[0].Id,contacts[0].OwnerId);
        system.AssertEquals(users[0].Id,contacts[1].OwnerId);
        system.AssertEquals(users[0].Id,contacts[2].OwnerId);
        
        //Test Starts from here
        Test.startTest();
        
        	//Calling battch which changes the user deactived in last 24 hours, change the related owened contact with the salesforce administrator Id.
        	Id JobId = dataBase.executeBatch(new Batch_UpdateInActiveOwnershipToSFAdmin() , 200);
        
        //Test Ends here
        Test.stopTest();
        
        //Query on the contact
        contacts = [Select Id, OwnerId From Contact order by CreatedDate];
        
        //Asserts on Results
        system.assertEquals(3, contacts.size());
        system.AssertEquals(users[0].Id,contacts[0].OwnerId);
        system.AssertEquals(users[0].Id,contacts[1].OwnerId);
        system.AssertEquals(users[0].Id,contacts[2].OwnerId);
        
    }*/
    
    /**
	 *  Description     :   test class to test the functionality of Batch_UpdateInActiveOwnershipToSFAdmin - changing the inactive user Contactr owner 
	 * 
	 *  Created By      :   Dipesh Gupta  
	 * 
	 *  Created Date    :   08/18/2017
	 * 
	 *  Revision Logs   :   V_1.0 - Created
	 *
	 **/ 
	/*static testmethod void myUnitTest1() {
    	
    	 //Query on the user
        List<User> users = [Select Id, Profile.Name, IsActive, LastName From User where LastName =: 'SpecialistUser' AND Profile.Name =: 'Specialist' ];
        System.assert((users != null));
        System.assertEquals(1, users.size() );
        
        system.runAs(users[0]) {	
        	
            //Bypass Triggers
	    	Util.BypassAllTriggers = true;
	    
        	//Inserting Account
    		Account acc = TestUtilities.CreateNewAccount(true);
    		
    		//Creating contact for the user
        	List<Contact> con = New List<Contact>();
        	con.add(new Contact (LastName = 'Test-1' , AccountId = acc.Id, Primary_Address_Line_1__c = '103/71', 
        					Primary_City__c = 'Test_City', Primary_Postal_Code__c = '1000', Primary_Country__c = 'Brazil'));
			con.add(new Contact (LastName = 'Test-2' , AccountId = acc.Id, Primary_Address_Line_1__c = '103/71', 
							Primary_City__c = 'Test_City', Primary_Postal_Code__c = '1000', Primary_Country__c = 'Brazil'));
			con.add(new Contact (LastName = 'Test-3' , AccountId = acc.Id, Primary_Address_Line_1__c = '103/71', 
							Primary_City__c = 'Test_City', Primary_Postal_Code__c = '1000', Primary_Country__c = 'Brazil'));
							
			insert con;
        
            //Enables all Triggers
	    	Util.BypassAllTriggers = false;
        }
        
        //List to hold the contact to checj the owner of contact
        List<Contact> contacts = [Select Id, OwnerId From Contact order by CreatedDate];
        
        //Asserts on Results
        system.AssertEquals(users[0].Id,contacts[0].OwnerId);
        system.AssertEquals(users[0].Id,contacts[1].OwnerId);
        system.AssertEquals(users[0].Id,contacts[2].OwnerId);
        
        
        //Enables all Triggers
	   	Util.BypassAllTriggers = true;
        
        //Update User to InActive
        users[0].IsActive = false;
        update users[0];
        
        //Enables all Triggers
	    Util.BypassAllTriggers = false;
        
        //Test Starts from here
        Test.startTest();
        
        	//Calling battch which changes the user deactived in last 24 hours, change the related owened contact with the salesforce administrator Id.
        	Id JobId = dataBase.executeBatch(new Batch_UpdateInActiveOwnershipToSFAdmin() , 200);
        
        //Test Ends here
        Test.stopTest();
        
        //Get Custom Setting record
        User_InActive_Ownership_To_SFAdmin__c mc = User_InActive_Ownership_To_SFAdmin__c.getOrgDefaults();
		system.assert(mc != null);
        system.assert(mc.SFAdmin_Id__c != null);
        
        //Query on the contact
        contacts =  [Select Id, OwnerId From Contact order by CreatedDate];
        
        //Asserts on Results
        system.assertEquals(3, contacts.size());*/
        
        /*
        system.AssertEquals(mc.SFAdmin_Id__c,contacts[0].OwnerId);
        system.AssertEquals(mc.SFAdmin_Id__c,contacts[1].OwnerId);
        system.AssertEquals(mc.SFAdmin_Id__c,contacts[2].OwnerId);
		*/
    //}
}