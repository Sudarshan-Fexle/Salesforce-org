/**
 *  Description     :  To Check the Functionality of Trigger Email Message
 * 
 *  Created By      :  Abhinav sharma
 * 
 *  Created Date    :   05/07/2018
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20180502-12201 - 05/08/2018

 *                      
 **/ 
@istest(SeeAllData = false)
public class Test_TriggerEmailMessage {
	
    testmethod static void myUnitTest() {
    	
        //Query on the Record Type
        List<RecordType> rdType = [SELECT ID FROM RecordType Where sObjectType = 'Case' AND IsActive = true 
                                                AND DeveloperName = 'EAB_Custom'];
        
        //Creating Account 
       	Account acc = TestUtilities.CreateNewAccount(true);
        
         //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        Case aCase = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', Subject = 'out of office', 
                                Description = 'out of office', AccountId = acc.Id);
                                
        insert aCase;
        
        Test.startTest();
        
        //Inserting a Email Message Record Under this 
        EmailMessage em = new EmailMessage();
        
        em.ParentId = aCase.Id;
        em.FromAddress = 'test@Test.com';
        em.FromName = 'Test class';
        em.HtmlBody = 'Test---------------Notes from Research Associate[ref:';
        em.TextBody = 'Test---------------Notes from Research Associate[ref:';
        em.ToAddress = 'test@test.com';
        
        insert em;
        
        Test.StopTest();
        
        //Asserts
        List<EmailMessage> ems = [Select Id, Notes_From_Research_Associate__c From EmailMessage Where Id  =: em.Id];   
    }    
}