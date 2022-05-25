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
@isTest(seeAllData = false)
public class Test_ContactSiteHelper {
	
/**
    Purpose         :   Test class for ContactSiteHelper
                
    Created By      :	
    
    Created Date    :	1/9/2015   
    
    Revision Log    :   v1.0 - Created - 1/9/2015
                        v1.1 - Modified - Abhinav Sharma - CR-20160812-10112 - 01/20/2017
			v1.2 - Modified - Subhash - CR-20211012-15511 - 10/12/2021
*                        
**/
	
    //Test method to test out institution change based functionality
    static testmethod void Test_checkInstitutionChange() {
      
    	//Bypass Dupeblocker
        Util.IsTest(true);
      
      	//skip all triggers temporarily so we can setup test data
        Util.BypassAllTriggers = true;
        
        //create a parent and child institution
        Account account1 = TestUtilities.CreateNewAccount(false);
        account1.r_School_Id__c = 12332; 
    	insert account1;
    
	    //Eligible domain record
	    Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'royall.com', Account__c = account1.Id);
        insert domain;
    	
        //Account
    	Account account2 = TestUtilities.CreateNewAccount(true);
    
        //Profile    
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        //Create the User
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey = 'GMT', UserName=Math.random() + '@test.com');
        
        //Insert the user
        insert user;
        
        //Setup test data for the contact
        Contact contact1 = TestUtilities.CreateNewContact(account1, false);
	//Modified - Subhash - CR-20211012-15511 - 10/12/2021
        contact1.Email = 'test_inactive@gmail.com';
        contact1.Marketing_Hard_Bounce_Email__c = 'test_inactive@gmail.com';
        contact1.OwnerId =  user.Id;
        
        Contact contact2 = TestUtilities.CreateNewContact(account1, false);
        contact2.Email = 'nike@gmail.com';
        
        //List to hold the contact records 
        List<Contact> contactlist = new List<Contact>();
        
        //Add the contact records 
        contactlist.add(contact1);
        contactlist.add(contact2);
        
        //Insert the contact list
        insert contactlist;
        
        //create site profile
        Site_Profile__c site_Profile = new Site_Profile__c(Status__c = 'Active',
                                                           Username__c = 'mike@royall.com', 
                                                           Password__c = 'test',
                                                           Site_User__c = null,
                                                           Verify__c = '2',
                                                           Contact__c = contactlist[0].Id,
                                                           r_Institution__c = account1.Id,
                                                           RecordTypeId = Test_SiteProfileActionController.SITE_PROFILE_RT_ID_ROYALL,
                                                           Type__c = SiteUserHelper.SITE_ROYALL);
                                                           
        //Insert the site profile records
        insert site_Profile;
        
        //Test start  here 
        Test.startTest();
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        
        //Update the contact's institute
        contactlist[0].AccountId = account2.Id;
        contactlist[0].Company_Email__c = 'test@test.com';
        contactlist[0].Bypass_Domain_Validation__c = true;
	//Modified - Subhash - CR-20211012-15511 - 10/12/2021
        contactlist[0].Marketing_Hard_Bounce_Email__c = 'test@test.com';
        update contactlist[0];
        
        //Updated by Subhash - CR-20211012-15511
        ContactSiteHelper.DeactivateEmailString(contact1.Email);
        
        //Query through the contact record and Asserting for the results
        contactlist = [SELECT Id 
                       FROM Contact WHERE Email = 'test_inactive@gmail.com'];
	System.assertEquals(1, contactlist.size());        
        /*contactlist = [SELECT Id 
                       FROM Contact WHERE SIAM_Email_Old__c = 'test@gmail.com'];
        System.assertEquals(1, contactlist.size());*/
        
        //Test stop here
        Test.stopTest();    
    }
}