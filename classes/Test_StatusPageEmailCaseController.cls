/**
*  Description     :   Class to create the Status page Email Cases. 
*
*  Created By      :   Abhinav Sharma    
* 
*  Created Date    :   01/16/2019
* 
*  Revision Logs   :   V_1.0 - Created - CR-20170526-10962
**/
@Istest(seeAllData = false)
public class Test_StatusPageEmailCaseController {
	
    @testsetup Static void setupData() {
    	
        //Creating Account data.
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;

        //Modified By Dipesh Gupta - 09/26/2019 - CR-20190529-13156 - APS replaced by Tech (SSC) as per Taylor Chatter
        String apsRecordType = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Tech').getRecordTypeId();
       	//Create a Project record
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        Project__c project = new Project__c(Name = 'Test', Institution__c = acc.Id, RecordTypeId = apsRecordType,
                                                Project_Phase__c = '1 - Test'/*, Implementation_Business_Analyst__c = UserInfo.getUserId()*/);
        
        insert project;
 	}
    
    //Method to test the functionality. 
    @istest static void testStatusPageEmailCaseController() {
    	
        //query on the Project records. 
        List<Project__c> proejcts = [Select Id, Name From Project__c];
        
        //Setting the parameters on the apex pages so the conteroller can get it.
        ApexPages.currentPage().getParameters().put('id',proejcts[0].Id);
        
        //Initialising class. 
        StatusPageEmailCaseController controller = new StatusPageEmailCaseController();
        controller.caseSubject = 'Status Page Email Case';
        controller.casePriority = 'Medium';
        controller.caseStatus = 'New Request';
        controller.caseStatusPageEmail = 'Testing Status Page Email Case';
        
        //Calling a method creates the case.'
        controller.doSave();
        
        List<Case> cse = [Select Id, Subject, Priority, Status, Internal_Notes__c From Case];
        
        System.assert(cse.size() ==1);
        System.assertEquals(controller.caseSubject,cse[0].Subject);
        System.assertEquals(controller.casePriority,cse[0].Priority);
        System.assertEquals(controller.caseStatus,cse[0].Status);
        System.assertEquals(controller.caseStatusPageEmail,cse[0].Internal_Notes__c);
    }
}