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
 @isTest
private class Test_TriggerContact {
/**
    Purpose     :   Test class for Trigger_Contact.
                
    Create By   :   Bhavi
    
    Created Date:   12/28/2011
    
    Revision Log:   V1.1 - Created
                    V1.2 - Test method added - Bhavi Sharma - 11/14/2013 -  CR-20130419-2900
                    V1.3 - Test method added - Subhash Garhwal - 07/03/2015 - CR-20150618-9014
                    V1.4 - Test method added - Padmesh Soni - 09/08/2015 - CR-20150729-9114
                    Manual Merger By - Rajeev Jain - In test sandbox - In order to conflict found with Release 50 CR-20160315-9697
                    V1.5 - Modifeid - Rajeev Jain - 05/05/2016 - Improved asserts in testCreateIncentiveChangeLog method
                    V1.6 - Modified By - Mahendra Swarnkar - CR-20161102-10332 - 1/2/2017  
		    		V1.7 - Test method added - Mahendra Swarnkar - 1/21/2017 - CR-20160907-10171 				
    
	Coverage    :   100%
**/
    
    static testMethod void myUnitTest(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        // Create a restricted account
        Account account = new Account(Name = 'Test Case Account 1', 
                                      Account_Restriction_Status__c = 'Restricted: Permission Required');
        insert account;
        
        // List to store test Contacts
        List<Contact> contacts = new List<Contact>();
        
        //Create a list of contacts to be inserted
        for(Integer i = 0; i < 2; i++) {
            contacts.add(new Contact(LastName = 'Test', Primary_Country__c = 'USA', AccountId = account.Id, 
                                     Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', Create_Advisory_com_User_Account__c = true));
        }
        
        //Enabling triggers again
        Util.BypassAllTriggers = false;
        
        //insert contacts
        insert contacts;
        
        //Start Testing from here
        Test.startTest();
        
        //Delete contact records
        try {
            
            delete contacts;
        
        } catch(Exception e) {
            
            //Assert for the result
            contacts = [Select Id from Contact where ID IN: contacts];
            System.assertEquals(2, contacts.size());
            
        }
        
        //Stop testing here
        Test.stopTest();
    }
    
    
    //Test method added - Bhavi Sharma - 11/14/2013 -   CR-20130419-2900
    //Test method to test the Primary Address field are populated or not of Contact
    /*commented out 12/12/13 pending further discussion on how to implement
    static testmethod void testPopulateContactPrimaryAddress() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        
        // Create a restricted account
        Account account = new Account(Name = 'Test Case Account 1', Account_Restriction_Status__c = 'Restricted: Permission Required',
                                        Primary_Address_Line_1__c = 'Testing Street', Primary_City__c = 'Testing City', Primary_Country__c = 'Test Country', 
                                        Primary_Postal_Code__c = '234567', Primary_State_Province__c = 'CA');
        insert account;
        
        
        // List to store test Contacts
        List<Contact> contacts = new List<Contact>();
        
        //Create a list of contacts to be inserted
        for(Integer i = 0; i < 2; i++) {
            contacts.add(new Contact(LastName = 'Test', AccountId = account.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', Create_Advisory_com_User_Account__c = true, Advisory_com_Uncheck_Domain__c = true));
        }
        
        //Test starts here
        Test.startTest();
        
        //insert contacts
        insert contacts;
        
        //Query result of Contacts
        contacts = [SELECT Id, Primary_Address_Line_1__c, Primary_City__c, Primary_Country__c, Primary_Postal_Code__c, Primary_State_Province__c 
                        FROM Contact WHERE Id IN: contacts];
            
        //Loop through Queried Contact          
        for(Contact contact : contacts) {
            
            System.assertEquals(account.Primary_Address_Line_1__c, contact.Primary_Address_Line_1__c);
            System.assertEquals(account.Primary_City__c, contact.Primary_City__c);
            System.assertEquals(account.Primary_Postal_Code__c, contact.Primary_Postal_Code__c);
            System.assertEquals(account.Primary_State_Province__c, contact.Primary_State_Province__c);
            System.assertEquals(account.Primary_Country__c, contact.Primary_Country__c);
        }
        
        //Test stops here
        Test.stopTest();
    } 
    */
    
    //Added by - Subhash Garhwal
    //Test method to test updateStaffAssignment methods functionality
    static testMethod void updateStaffAssignment() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        //Create account 
        //List to hold Account records
        List<Account> accounts = new List<Account>();
        
        //Add accounts in list
        accounts.add(new Account(Name = 'Test Account1'));
        accounts.add(new Account(Name = 'Test Account2'));
        accounts.add(new Account(Name = 'Test Account3'));
        
        //Insert 
        insert accounts;
        
        //Create contact
        //List to hold contact records
        List<Contact> contacts = new List<Contact>();
        
        //Add new contacts in list
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1',Employee_User_Record__c = Userinfo.getUserId(), Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = accounts[0].Id,Active_PSS__c = true));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 2',Employee_User_Record__c = Userinfo.getUserId(), Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = accounts[1].Id,Active_PSS__c = true));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 3',Employee_User_Record__c = Userinfo.getUserId(), Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = accounts[2].Id,Active_PSS__c = true));
    
        //Enabling triggers again
        Util.BypassAllTriggers = false;
        
        //Insert
        insert contacts;
        
        //Create Team Role (Assignment Role)
        //List of Team Role 
        List<Team_Role__c> staffRole = new List<Team_Role__c>();
        
        //Add new team Role in list
        staffRole.add(new Team_Role__c(Name = 'Test1', Active__c = true, Institution__c = true));
        
        //Insert
        insert staffRole;
        
        //Create Staff Assignment 
        List<Team_Membership__c> staffAssignments = new List<Team_Membership__c>();
        
        //Record Types
        List<RecordType> tmRecordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                            AND IsActive = true 
                                            AND DeveloperName = 'Assigned'];
        System.assert(tmRecordTypes != null);
        
        //Add Staff Assignment in list
        staffAssignments.add(new Team_Membership__c(Name = 'Test As 1',Staff_member__c = contacts[0].Id, 
                                                    Role__c = staffRole[0].Id, Institution__c = accounts[0].Id , 
                                                    Start_date__c = System.today().addDays(-3), 
                                                    End_date__c = System.today().addDays(+5),
                                                    RecordTypeId = tmRecordTypes[0].Id));
        staffAssignments.add(new Team_Membership__c(Name = 'Test As 2',Staff_member__c = contacts[1].Id, 
                                                    Role__c = staffRole[0].Id, Institution__c = accounts[1].Id , 
                                                    Start_date__c = System.today().addDays(-3), 
                                                    End_date__c = System.today().addDays(+5),
                                                    RecordTypeId = tmRecordTypes[0].Id));
        staffAssignments.add(new Team_Membership__c(Name = 'Test As 3',Staff_member__c = contacts[2].Id, 
                                                    Role__c = staffRole[0].Id, Institution__c = accounts[2].Id , 
                                                    Start_date__c = System.today().addDays(-3), 
                                                    End_date__c = System.today().addDays(+5),
                                                    RecordTypeId = tmRecordTypes[0].Id));
        
        //Insert
        insert staffAssignments; 
        
        // Test start here
        Test.startTest();
        
        //Query through Staff Assignment
        List<Team_Membership__c> teamMemberships = [Select Id, Name From Team_Membership__c ORDER BY CreatedDate ASC];
        
        //Assert for result
        System.assertEquals(3, teamMemberships.size());
        System.assertEquals('Test Contact 1-Test1', teamMemberships[0].Name);
        System.assertEquals('Test Contact 2-Test1', teamMemberships[1].Name);
        System.assertEquals('Test Contact 3-Test1', teamMemberships[2].Name);
        
        //Update contact
        contacts[0].Email = 'testing@test.com';
        
        //Update
        update contacts;
        
        //Query through Staff Assignment
        teamMemberships = [Select Id, Name From Team_Membership__c ORDER BY CreatedDate ASC];
        
        //Assert for result
        System.assertEquals(3, teamMemberships.size());
        System.assertEquals('Test Contact 1-Test1', teamMemberships[0].Name);
        System.assertEquals('Test Contact 2-Test1', teamMemberships[1].Name);
        System.assertEquals('Test Contact 3-Test1', teamMemberships[2].Name);
        
        //Update contact
        contacts[0].FirstName = 'FirstName';
        contacts[1].LastName = 'LastName';
        
        // Update
        update contacts;
        
        //Query through TeamMembership 
        teamMemberships = [Select Id,  Name From Team_Membership__c ORDER BY CreatedDate ASC];
        
        //Assert for result
        System.assertEquals(3,teamMemberships.size());
        System.assertEquals('FirstName Contact 1-Test1', teamMemberships[0].Name);
        System.assertEquals('Test LastName-Test1', teamMemberships[1].Name);
        System.assertEquals('Test Contact 3-Test1', teamMemberships[2].Name);

        //Method stop here
        Test.stopTest(); 
    }
    
    
    //Added By - Mahendra Swarnkar - CR-20161102-10332 - 1/2/2017
    //Test method to test PopulateTopParentInstitutionOnContacts methods functionality
    static testMethod void testPopulateTopParentInstitutionOnContacts() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        // Create a restricted account
        Account acc = new Account(Name = 'Test Case Account 1');
        insert acc;
        
        //Create account 
        //List to hold Account records
        List<Account> accounts = new List<Account>();
        
        //Add accounts in list
        accounts.add(new Account(Name = 'Test Account0', Top_Parent_Institution__c = acc.Id));
        accounts.add(new Account(Name = 'Test Account1'));
        accounts.add(new Account(Name = 'Test Account2' , Top_Parent_Institution__c = acc.Id));
        
        //Insert 
        insert accounts;
        
        //Asserting for the results
        System.assert(accounts.size() > 0);
        
        //Create contact
        //List to hold contact records
        List<Contact> contacts = new List<Contact>();
        
        //Add new contacts in list
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1',Employee_User_Record__c = Userinfo.getUserId(), 
                                 Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = accounts[0].Id, Contact_Status__c = 'Active'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 2',Employee_User_Record__c = Userinfo.getUserId(), 
                                 Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = accounts[0].Id, Contact_Status__c = 'Active'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 3',Employee_User_Record__c = Userinfo.getUserId(), 
                                 Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = accounts[1].Id, Contact_Status__c = 'Active'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 4',Employee_User_Record__c = Userinfo.getUserId(), 
                                 Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', Contact_Status__c = 'InActive - Other'));
    
        //Enabling triggers again
        Util.BypassAllTriggers = false;
        
        //Insert  
        insert contacts;
        
        //Enabling triggers again
        Util.BypassAllTriggers = true;        
    
        // Test start here
        Test.startTest();
        
        //Retrive contact updated values
        List<Contact> ContactList = [Select ID,Top_Parent_Institution__c 
                                       From Contact 
                                       ORDER BY LastName ASC];
        
        //Assert for results
        System.assert(ContactList.size() > 0);
        System.assertEquals(4, ContactList.size());
        System.assertEquals(acc.Id, ContactList[0].Top_Parent_Institution__c);
        System.assertEquals(acc.Id, ContactList[1].Top_Parent_Institution__c);
        System.assertEquals(accounts[1].Id, ContactList[2].Top_Parent_Institution__c);
        System.assertEquals(null, ContactList[3].Top_Parent_Institution__c);
        
        //Set top Parent values
        ContactList[0].Top_Parent_Institution__c = null;
        
        //Enabling triggers again
        Util.BypassAllTriggers = false;
        
        //Update contact
        Update ContactList[0];
        
        //Retrive contact updated values
        ContactList = [Select ID,Top_Parent_Institution__c From Contact ORDER BY LastName ASC];
        
        //Assert for results
        System.assert(ContactList.size() > 0);
        System.assertEquals(4, ContactList.size());
        System.assertEquals(acc.Id, ContactList[0].Top_Parent_Institution__c);
        
        //Set top Parent values
        ContactList[3].Contact_Status__c = 'Active';
        
        //Enabling triggers again
        Util.BypassAllTriggers = false;
        
        //Update contact
        Update ContactList[3];
        
        //Retrive contact updated values
        ContactList = [Select ID,Top_Parent_Institution__c From Contact ORDER BY LastName ASC];
        
        //Assert for results
        System.assert(ContactList.size() > 0);
        System.assertEquals(4, ContactList.size());
        System.assertEquals(null, ContactList[3].Top_Parent_Institution__c);
        
        //Method stop here
        Test.stopTest(); 
    }
	
	//Added By - Mahendra Swarnkar - 1/21/2017 - CR-20160907-10171 
    //Test method to test  updateMKCRecords method functionality
    static testMethod void testupdateMKCRecords() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;

        //Create account 
        List<Account> accounts = new List<Account>();

        //Add accounts in list
        accounts.add(new Account(Name = 'Test Account1'));
        accounts.add(new Account(Name = 'Test Account2'));
        accounts.add(new Account(Name = 'Test Account3'));

        //Insert 
        insert accounts;

        //Create contact
        List<Contact> contacts = new List<Contact>();

        //Add new contacts in list
        contacts.add(new Contact(FirstName = 'Test1', LastName = 'Contact 1',
                                 Employee_User_Record__c = Userinfo.getUserId(), Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', 
                                 AccountId = accounts[0].Id, Contact_Status__c = 'Active'));
        contacts.add(new Contact(FirstName = 'Test2', LastName = 'Contact 2',
                                 Employee_User_Record__c = Userinfo.getUserId(), Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', 
                                 AccountId = accounts[1].Id, Contact_Status__c = 'Inactive – Other'));
        contacts.add(new Contact(FirstName = 'Test3', LastName = 'Contact 3',
                                 Employee_User_Record__c = Userinfo.getUserId(), Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', 
                                 AccountId = accounts[2].Id, Contact_Status__c  = 'Active'));

        //Insert
        insert contacts;
        
          Program__c program = new Program__c(
            Name = 'Test Program',
            Create_memberships__c = 'No',
            Status__c = 'Active'
        );

        insert program;
        
        //Create the Membership record 
        List<Membership__c> memberships = new List<Membership__c>();
        
        
        //Add new Membership in the list
        memberships.add(new Membership__c(Name = 'Test Membership1', Account_Name__c = accounts[0].Id, Program__c = program.Id));
        memberships.add(new Membership__c(Name = 'Test Membership2', Account_Name__c = accounts[1].Id, Program__c = program.Id));
        memberships.add(new Membership__c(Name = 'Test Membership3', Account_Name__c = accounts[1].Id, Program__c = program.Id));
        
        //Insert the membership records
        insert memberships;
        
        //List to hold the Membership_Key_Contact records
        List<Membership_Key_Contact__c> mKCs = new List<Membership_Key_Contact__c>();
        
        //Add new Membership key contact record
		mKCs.add(new Membership_Key_Contact__c(Contact__c = contacts[0].Id, Name='Test 1', Membership__c = memberships[0].Id, 
                                               Pubs__c = true, Meetings__c = true, Key_Contact_Status__c = 'Active'));
		mKCs.add(new Membership_Key_Contact__c(Contact__c = contacts[0].Id, Name='Test 1', Membership__c = memberships[1].Id, 
                                               Pubs__c = true, Meetings__c = true, Key_Contact_Status__c = 'Inactive'));
		mKCs.add(new Membership_Key_Contact__c(Contact__c = contacts[1].Id, Name='Test 1', Membership__c = memberships[2].Id, 
                                               Pubs__c = true, Meetings__c = true, Key_Contact_Status__c = 'Active'));
		
		//Insert the Membership Key Contact records
		insert mKCs;
        
        //Test start here
        Test.startTest();
        
        //Enabling triggers again
        Util.BypassAllTriggers = false;
        
        //Update  
        contacts[0].Contact_Status__c = 'Inactive - No Activity';
        
        //Update
        update contacts;
        
        //Query through the updated contacts
        contacts = [Select Id, Contact_Status__c From Contact Where Id =: contacts[0].Id];
        
        //Assert for contact's Contact Status field value 
        System.assertEquals('Inactive - No Activity', contacts[0].Contact_Status__c);
        
        //Query through the Membership key contact record
        mKCs = [Select Id, Pubs__c, Meetings__c, Key_Contact_Status__c 
                	From Membership_Key_Contact__c 
                	Where Contact__c =: contacts[0].Id];        
        
        //Assert for result
        System.assertEquals(2, mKCs.size());
        System.assertEquals(false, mKCs[0].Pubs__c);
        System.assertEquals(false, mKCs[0].Meetings__c);
        System.assertEquals('Inactive', mKCs[0].Key_Contact_Status__c);
        System.assertEquals(false,  mKCs[1].Pubs__c);
        System.assertEquals(false, mKCs[1].Meetings__c); 
        System.assertEquals('Inactive', mKCs[1].Key_Contact_Status__c);
        
        //Test stop here
        Test.stopTest(); 
    }
}