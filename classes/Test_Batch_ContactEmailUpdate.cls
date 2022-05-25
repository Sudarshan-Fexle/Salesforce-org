/**
 *  Purpose         :   Class is used to test the Functionality Batch_ContactEmailUpdate
 *
 *  Created By      :   Abhinav Sharma
 *
 *  Created Date    :   07/18/2018
 *
 *  Revision Logs   :   V_1.0 - Created- CR-20180605-12266
 *                     
**/
@isTest(seeAllData=false)
public class Test_Batch_ContactEmailUpdate {
	
    testmethod static void test_MyUnitTest() { 
    	
        //Creating Contact
        ////Creating the contact
        Contact con = new Contact();
        
        con.LastName = 'Test';
        con.Email = 'Test@test.com';
		con.Email = 'Test'+Math.random()+'@eab.com';
		con.Title = 'Test';
		con.Phone = '614-555-8855';
		
        insert con;
        
        Test.startTest();
        	Batch_ContactEmailUpdate b = new Batch_ContactEmailUpdate();
        	Id jobId = Database.executeBatch(b, 10);
       	Test.stopTest();
       
    }
}