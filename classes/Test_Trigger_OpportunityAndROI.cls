@istest
public class Test_Trigger_OpportunityAndROI {
    
    testMethod static void updateProjectWithROI() {
        
      	//Bypass Dupeblocker
        Util.IsTest(true);

        //Test Name (Renewal), Membership__c, owner name
        Util.IsTesting = true;
        Util.BypassAllTriggers = true;

        //delete acc.Memberships__r;
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;

        //Program__c prog = [select id from Program__c limit 1];
        Program__c prog = new Program__c(Name = 'testprog', Program_Acronym__c = 'TEST', Status__c = 'Active', Create_Memberships__c = 'Yes');
        insert prog;

        //Create membership data
        Membership__c mem = new Membership__c(Account_Name__c = acc.id, Program__c = prog.id);
        insert mem;

        //Create a Project record
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        Project__c project = new Project__c(Name = 'Test', Institution__c = acc.Id, Primary_Paid_Membership__c = mem.Id, 
                                                Project_Phase__c = '1 - Test'/*, Implementation_Business_Analyst__c = UserInfo.getUserId()*/);
		insert project;
        
        Util.BypassAllTriggers = false;

        //Start testing here
        Test.startTest();
        		
        	Opportunity_and_ROI__C oppROIs = new Opportunity_and_ROI__C();	
            oppROIs.name = '(A) Impact';
            oppROIs.Project__c = project.id;
            oppROIs.RecordTypeId = Schema.SObjectType.Opportunity_and_ROI__C.getRecordTypeInfosByName().get('CCC/CCR').getRecordTypeId();
            oppROIs.Dedicated_Advisor__c = UserInfo.getUserId();  
        	insert oppROIs;
        
        	Opportunity_and_ROI__C oppROIs1 = new Opportunity_and_ROI__C();	
            oppROIs1.name = '(B) Impact';
            oppROIs1.Project__c = project.id;
            oppROIs1.RecordTypeId = Schema.SObjectType.Opportunity_and_ROI__C.getRecordTypeInfosByName().get('CCC/CCR').getRecordTypeId();
            oppROIs1.Dedicated_Advisor__c = UserInfo.getUserId();  
        	insert oppROIs1;
        
        Test.stoptest();
   	}

}