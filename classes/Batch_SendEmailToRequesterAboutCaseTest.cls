/**
 *  Desription      :   This class is Used to test the Functionality of Batch_SendEmailToRequesterAboutCase
 * 
 *  Created By      :   Abhinav Sharma
 * 
 *  Created Date    :   01/25/2018
 * 
 *  Revision Logs   :                 
 **
**/
@isTest(SeeAllData = false)
public class Batch_SendEmailToRequesterAboutCaseTest {
    
    //Test method to Test the functionality 
    testMethod static void myUnitTest() {
    	
        //Inset Contact
        Contact c = new Contact();
        c.Firstname = 'Test';
        c.LastName = 'Test';
        
        c.Email = 'Test@test.com';
        c.Title = 'Test';
		c.Phone = '614-555-8855';
        insert c;
        
        //Insert case
        List<Case> cases = new list<Case>();
        
        //query on Record Type
        List<RecordType> recordType = [Select id From RecordType Where SobjectType = 'Case' AND Name = 'eTech Support'];
        cases.add(new Case(Subject = 'Test-1', Status = 'Submitted', Member_Impacting__c = 'No', Origin = 'Other', RecordTypeId = recordType[0].Id, Stakeholder__c =  UserInfo.getUserId(), ContactId = c.id));
        cases.add(new Case(Subject = 'Test-2', Status = 'Submitted', Member_Impacting__c = 'No', Origin = 'Other', RecordTypeId = recordType[0].Id, Stakeholder__c =  UserInfo.getUserId(), ContactId = c.id));
        cases.add(new Case(Subject = 'Test-3', Status = 'Submitted', Member_Impacting__c = 'No', Origin = 'Other', RecordTypeId = recordType[0].Id, Stakeholder__c =  UserInfo.getUserId(), ContactId = c.id));
		cases.add(new Case(Subject = 'Test-4', Status = 'Submitted', Member_Impacting__c = 'No', Origin = 'Other', RecordTypeId = recordType[0].Id, Stakeholder__c =  UserInfo.getUserId(), ContactId = c.id));
        cases.add(new Case(Subject = 'Test-5', Status = 'Submitted', Member_Impacting__c = 'No', Origin = 'Other', RecordTypeId = recordType[0].Id, Stakeholder__c =  UserInfo.getUserId(), ContactId = c.id));
        cases.add(new Case(Subject = 'Test-6', Status = 'Submitted', Member_Impacting__c = 'No', Origin = 'Other', RecordTypeId = recordType[0].Id, Stakeholder__c =  UserInfo.getUserId(), ContactId = c.id));
        cases.add(new Case(Subject = 'Test-7', Status = 'Submitted', Member_Impacting__c = 'No', Origin = 'Other', RecordTypeId = recordType[0].Id, Stakeholder__c =  UserInfo.getUserId(), ContactId = c.id));
        
        //Util.Bypass all trigger
        Util.ByPassAllTriggers = true;
        insert cases;
        
        //Updating the Status of case  - Not changing the Status and date simulaneous because a workflow behind the Scene is updating the Case Status Change Date
        cases[0].Status = 'New';
        cases[1].Status = 'In Progress';
        cases[2].Status = 'Waiting on response from requester';
        cases[3].Status = 'Pending User Verification';
        cases[3].Resolution__c = 'CR Deployed';
        cases[4].Status = 'Waiting on response from requester';
        cases[5].Status = 'Waiting on response from requester';
        cases[6].Status = 'Pending User Verification';
        cases[6].Resolution__c = 'CR Deployed';
        
        Update cases;
        
        //Now Updating the Status Change Date 
        cases[0].Status_Changed_Date__c = Date.Today().addDays(-2);
        cases[1].Status_Changed_Date__c = Date.Today().addDays(-2);
        cases[2].Status_Changed_Date__c = Date.Today().addDays(-7);
        cases[3].Status_Changed_Date__c = Date.Today().addDays(-13);
        cases[4].Status_Changed_Date__c = Date.Today().addDays(-13);
        cases[5].Status_Changed_Date__c = Date.Today().addDays(-9);
        cases[6].Status_Changed_Date__c = Date.Today().addDays(-7);
        Update cases;
        
        Set<String> setIDs = New Set<String> {cases[3].Id, cases[4].Id};
        
        //Starting Test
        Test.startTest();
        
        //Call batch to send Emails 
        Batch_SendEmailToRequesterAboutCase b = new Batch_SendEmailToRequesterAboutCase();
        String JobiD = dataBase.executeBatch(b, 10);
        
        //Stop Test
        Test.StopTest();
            
        List<Case> case1 = [Select Id, Status, StatusAge__c From Case Where ID IN: setIDs];
        
        //Check the Status Of both Should be Closed
        System.assertEquals('Closed',case1[0].Status);
        System.assertEquals('Closed',case1[1].Status);
	}
}