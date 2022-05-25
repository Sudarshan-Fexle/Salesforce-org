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
/**
  *   Purpose         :     Test class for IssueTrackingExtension
  *            
  *   Create By       :     Saurabh Kumar  
  * 
  *   Created Date    :     02/15/2017
  *
  *   Revision Log    :     V_1.0 - Created - CR-20170216-10698
  * 						
  *   Coverage        :     100%
  **/
@isTest(seeAllData = false)
private class Test_IssueTrackingExtension {
	
    /**
     * 	Description	:	Test method to test functionality of IssueTrackingExtension 
     * 
     * 	@argu		:	
     * 
     * 	@return		:	Void
     **/
    static testMethod void unitTest(){
        
        //Query on record types for Is System
        List<RecordType> recordTypesOfIsSystem = [Select Id, DeveloperName From RecordType Where sObjectType = 'IS_System__c'
                                                 AND DeveloperName = 'System'];
        System.assert(recordTypesOfIsSystem != null);
        
        //Creating records of Is System
        List<IS_System__c> isSystems = new List<IS_System__c>();
        isSystems.add(new Is_System__c(RecordTypeId = recordTypesOfIsSystem[0].Id, Name = 'Test', Short_Name__c = 'Test', 
                                      Status__c = 'Active'));
        
        insert isSystems;
        
        //Query on record types for Change Request
        List<RecordType> recordTypesOfCR = [Select Id, DeveloperName From RecordType Where sObjectType = 'SFDC_Change_Request__c'
                                       Order by DeveloperName ASC];
        
        System.assert(recordTypesOfCR != null);
        System.assertEquals(6, recordTypesOfCR.size());
        System.assertEquals('App_Update', recordTypesOfCR[0].DeveloperName);
        System.assertEquals('Level_I', recordTypesOfCR[1].DeveloperName);
        System.assertEquals('Level_II', recordTypesOfCR[2].DeveloperName);
        System.assertEquals('Level_III', recordTypesOfCR[3].DeveloperName);
        System.assertEquals('Salesforce_Help', recordTypesOfCR[4].DeveloperName);
        System.assertEquals('System_Outage', recordTypesOfCR[5].DeveloperName);
        
        //Creating records of Change Request
        List<SFDC_Change_Request__c> changeRequests = new List<SFDC_Change_Request__c>();
        changeRequests.add(new SFDC_Change_Request__c(RecordTypeId = recordTypesOfCR[2].Id, Title__c = 'Test', 
                                                      IS_System__c = isSystems[0].Id, Users_Affected__c = 'Single Division',
                                                     Request_Description__c = 'Testing', Business_Justification__c = 'Cover Test Class'));
        
        insert changeRequests;
            
        //Start testing from here
        Test.startTest();
        
        //Initialization of standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(new CR_Action_Item__c());
        
        //Set ApexPages parameters
        ApexPages.currentPage().getParameters().put('retURL','test');
        ApexPages.currentPage().getParameters().put('RecordType', recordTypesOfCR[2].Id);
        
        //Instantiate the controller
        IssueTrackingExtension extension = new IssueTrackingExtension(sc);
        
        //Set controller getter setter
        extension.crID = changeRequests[0].Id;
        
        //Set variable value
        String url = extension.retURL;
        System.assert(url != null);
        
        //Assertions
        System.assertEquals(System.today(), extension.issue.Issue_Date__c);
        System.assertEquals('QA', extension.issue.Type__c);
        //System.assertEquals('Bug', extension.issue.Classification__c);
        System.assertEquals('New', extension.issue.Action_Item_Status__c);
        System.assertEquals(recordTypesOfCR[2].Id, extension.issue.RecordTypeId);
        System.assertEquals(UserInfo.getUserId(), extension.issue.Reported_By__c);
        System.assertEquals('Project Manager', extension.issue.Assigned_To_Role__c);
        System.assertEquals(null, extension.issue.Change_Request__c);
        
        ApexPages.currentPage().getParameters().put('ChangeRequest', changeRequests[0].Id);
        
        //Re-instantiate the controller
        extension = new IssueTrackingExtension(sc);
        System.assertEquals(changeRequests[0].Id, extension.issue.Change_Request__c);
        
        //Stop testing here
        Test.stopTest();
    }
}