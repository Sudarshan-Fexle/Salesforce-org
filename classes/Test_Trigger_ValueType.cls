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
private class Test_Trigger_ValueType {
	
/**
  *   Purpose         :   Test class for Trigger_ValueType
  *            
  *   Create By       :   Subhash Garhwal
  *
  *   Created Date    :   09/10/2015
  *
  *   Revision Log    :	  V_1.0 - Created - CR-20150825-9182 
  *						
  *	  Coverage		  :	  100%
  *					
  **/
  	
  	//Test method for testing the functionality of reNameStaffHistory method
    static testMethod void myUnitTest() {
    	
    	//Create an institution
		Account account = TestUtilities.CreateNewAccount(false);
		
		//Insert
		insert account;
		
		//Create a Contact
		Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId());
		
		//Insert
		insert contact;
		
		//Listt of Value Type
		List<Value_Type__c> valueTypes = new List<Value_Type__c>();
		
		valueTypes.add(new Value_Type__c(Name = 'Title', Values_Permitted__c = 'Date',Category__c = 'Business Title', Active__c = true,Use_As_Value__c = false, 
										 Rule__c = 'Staff member may have unlimited, overlapping records for this attribute' ));
		valueTypes.add(new Value_Type__c(Name = 'TestVT2', Values_Permitted__c = 'Text', Category__c = 'Position Details', Active__c = true,Use_As_Value__c = false,
										 Rule__c = 'Staff member may have unlimited, overlapping records for this attribute'));
		valueTypes.add(new Value_Type__c(Name = 'TestVT3', Values_Permitted__c = 'Text', Category__c = 'Position Details', Active__c = true,Use_As_Value__c = false,
										 Rule__c = 'Staff member may have unlimited, overlapping records for this attribute'));
		valueTypes.add(new Value_Type__c(Name = 'TestVT4', Values_Permitted__c = 'Text', Category__c = 'Position Details', Active__c = true,Use_As_Value__c = false,
										 Rule__c = 'Staff member may have unlimited, overlapping records for this attribute'));
		
		//Insert
		insert valueTypes;
             
		//Test start here
        Test.startTest();
        
        //Update
        valueTypes[1].Use_As_Value__c = true;
        valueTypes[1].Name = 'ChangedVT1';
        
        //Update
        update valueTypes[1];
        
     	//Negative Use Case And Update 
     	valueTypes[1].Use_As_Value__c = false;
     	valueTypes[1].Name = 'VTFalse';
        
     	//Update
        update valueTypes;
        
        //Test stop here
        Test.stopTest();    
    }
}