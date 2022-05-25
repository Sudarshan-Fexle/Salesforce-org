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
/** Description		:	Test Class for Intranet_Birthdays Controller class.
  * 
  * Created Date	:	
  *
  * Created By		:   
  *  
  * Current vision	:	v1.0
  *  
  * Revision Logs	:	v1.0 - Created
  * 					V2.0 - Modified By - Rajeev Jain - CR-7579 - 09/14/2015 
  **/
@isTest(seeAllData=false)
private class Test_IntranetBirthDays {

    static testMethod void testBirthDaysCache() { 
        
        //Create an Intranet Item record for birthDays
        //Record Type
        RecordType settingCatogary = [Select Name, Id From RecordType where sObjectType='Intranet_Item__c' AND isActive=true AND DeveloperName = 'Settings_Category' LIMIT 1];
        Intranet_Item__c intranetItem = new Intranet_Item__c(Name= 'Test', CurrencyIsoCode = 'USD', RecordTypeId = settingCatogary.Id, Category_Name__c = 'A',
        															Item_Type__c = 'Birthdays', Active_Status__c = 'Active', Approval_Status__c = 'Approved', 
        															Configuration_Item__c = true, Change_Configuration_Item__c  = true );
		insert intranetItem;
		
		//Create a New Contact Record and Attach it with current User Id and Update the Birthday = Today
		Contact contact = new Contact(LastName = 'TEST', BirthDate = Date.today(), Employee_User_Record__c = UserInfo.getUserId(), 
			Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855' );
		insert contact;
		
		//Start Testing from here
		Test.startTest();
		
		//Execute Scheduler
		Intranet_Birthdays sched = new Intranet_Birthdays();
		String CRON_EXP = '20 30 8 10 2 ?';
		String jobID = System.schedule('TEST-00001', CRON_EXP, sched);
		
		//Stop Test hete
		Test.stopTest();
		
		//extract intranetItem record
		intranetItem = [Select BirthDays_Cache__c from Intranet_Item__c where Id =: intranetItem.Id];
		
		//get User records
		List<User> users = (List<User>)JSON.deserialize(intranetItem.BirthDays_Cache__c, List<User>.class);
		System.assertEquals(1, users.size());
		System.assertEquals(UserInfo.getUserId(), users[0].Id);
	}
}