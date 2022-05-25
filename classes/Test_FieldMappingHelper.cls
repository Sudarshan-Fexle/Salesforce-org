@isTest
public class Test_FieldMappingHelper {
	
    /**
     * 
     * Description: Create a Member Support record and verify the Status Group is updated properly
     * 				This unit test uses "Another ticket pending" -> "Issues in migration" as the example
     * 
     * */
    public static testmethod void testMapMemSupportFields() {
        //create a project
        Project__c p = TestUtilities.createProject(true);
        //create the member support record
        Site_Issue__c sI = TestUtilities.createSiteIssue(p.Id, false);
        sI.Site_Issue_Close_Date__c = null;
        sI.Status__c = 'Another ticket pending';
        insert sI;
        
        //get the sI value and verify it was updated correctly
        sI = [SELECT Id, Status_Group__c FROM Site_Issue__c WHERE Id = :sI.Id];
        system.assert(sI.Status_Group__c.equalsIgnoreCase('Issues in migration'), 'The Status Group contains \'' + sI.Status_Group__c + '\' instead of \'Issues in Migration\'.');
    }
    
    /**
     * 
     * Description: Create a Case record and verify the Status Group is updated properly
     * 				This unit test uses "Another ticket pending" -> "Issues in migration" as the example
     * 
     * */
    public static testmethod void testMapCaseSupportFields() {
        //create contact
        Contact con = TestUtilities.CreateNewContact(true);
        
        //create the Case record
        Case c = new Case(ContactId = con.Id, Subject = 'Test', Status = '01-New',
                          Priority = 'Low', Description = 'test',
                          recordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ask EAB').getRecordTypeId());
        insert c;
        
        //get the sI value and verify it was updated correctly
        c = [SELECT Id, Member_Portal_Status__c FROM Case WHERE Id = :c.Id];
        system.assert(c.Member_Portal_Status__c.equalsIgnoreCase('01-New'), 'The Member Portal Status contains \'' + c.Member_Portal_Status__c + '\' instead of \'01-New\'.');
        
        //update the status to 
        c.Status='03-In Progress';
        update c;
        //get the sI value and verify it was updated correctly
        c = [SELECT Id, Member_Portal_Status__c FROM Case WHERE Id = :c.Id];
        system.assert(c.Member_Portal_Status__c.equalsIgnoreCase('03-In Progress'), 'The Member Portal Status contains \'' + c.Member_Portal_Status__c + '\' instead of \'03-In Progress\'.');
    }
    	
}