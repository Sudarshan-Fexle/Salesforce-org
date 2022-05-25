/**
 *  Desription      :   This class is Used test the functionality of Test_ClearHardBounceWizardController
 * 
 *  Created By      :   Abhinav Sharma
 * 
 *  Created Date    :   07/09/2018
 * 
 *  Revision Logs   :   V1.1 - Created
 * 						
**/
@istest(seeAllData=false)
public class Test_ClearHardBounceWizardController {
	
    testMethod static void myUnitTest() {
    	
        //Creating the contact
        Contact con = new Contact();
        
        con.LastName = 'Test';
        con.Marketing_Hard_Bounce_Reason__c = 'test';
        con.Marketing_Hard_Bounce_Date__c = Date.today();
        con.Marketing_Hard_Bounce_Email__c = 'test@test.com';
        con.ByPass_Domain_Validation__c = true;
		con.Email = 'Test'+Math.random()+'@eab.com';
		con.Title = 'Test';
		con.Phone = '614-555-8855';
		
		insert con;
        
        List<Contact> cons = [Select Id, Name, Marketing_Hard_Bounce_Date__c, 
                      Marketing_Hard_Bounce_Reason__c, 
                      Marketing_Hard_Bounce_Email__c 
                      From Contact Where Id =: con.Id];
       
        Test.startTest();
        
        ClearHardBounceWizardController controller = new ClearHardBounceWizardController();
        controller.selectedOne = 'Screen1';
        controller.conId = con.Id;
        controller.conRec = cons[0];
        List<SelectOption> sO = controller.getHardBounceOptions();
        controller.goNextScreen1();	
        
        
        System.assertEquals(true,controller.isSuccess);
        System.assertEquals(true,controller.isWizardComplete);
        
        Contact con1 = [Select Id, Marketing_Hard_Bounce_Date__c, 
                      	Marketing_Hard_Bounce_Reason__c, 
                      	Marketing_Hard_Bounce_Email__c  
                      	From Contact where Id =: con.Id];
        
        System.assertEquals(null, con1.Marketing_Hard_Bounce_Date__c);
        System.assertEquals(null, con1.Marketing_Hard_Bounce_Reason__c);
        System.assertEquals(null, con1.Marketing_Hard_Bounce_Email__c);
        
        
        //check scree 2 
        ClearHardBounceWizardController controller1 = new ClearHardBounceWizardController();
        controller1.selectedOne = 'Screen2';
        controller1.conId = con.Id;
        controller1.conRec = cons[0];
        controller1.newEmail = 'test1@test.com';
        controller1.goNextScreen2();	
        
        Contact con2 = [Select Id,Email, Marketing_Hard_Bounce_Date__c, 
                      	Marketing_Hard_Bounce_Reason__c, 
                      	Marketing_Hard_Bounce_Email__c  
                      	From Contact where Id =: con.Id];
        
        System.assertEquals(true,controller1.isSuccess);
        System.assertEquals(true,controller1.isWizardComplete);
        
        System.assertEquals('test1@test.com', con2.Email);
        System.assertEquals(null, con2.Marketing_Hard_Bounce_Date__c);
        System.assertEquals(null, con2.Marketing_Hard_Bounce_Reason__c);
        System.assertEquals(null, con2.Marketing_Hard_Bounce_Email__c);
        
       	//Errror Case - to cover Catch
		 //check scree 2 
        ClearHardBounceWizardController controller2 = new ClearHardBounceWizardController();
        controller2.selectedOne = 'Screen2';
        controller2.conId = con.Id;
        controller2.conRec = cons[0];
        controller2.newEmail = 'test';
        controller2.goNextScreen2();		
        
        Test.StopTest();
    }
}