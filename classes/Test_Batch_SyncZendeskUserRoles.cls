/**
 *  Description     :   unit tests for the Batch_SyncZendeskUserRoles class
 *
 *  Created By      :	Victor Hanson
 *
 *  Created Date    :   09/01/2018
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
@isTest
public class Test_Batch_SyncZendeskUserRoles {
    
    static testmethod void testBatch_SyncZendeskUserRoles() {
        
        //create program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Program_Acronym__c = 'BHGFAD';
        prog.Integration_Support__c = Constants.ZENDESK;
        util.bypassAllTriggers = true;
        insert prog;
        
        //create test account
        Account acc = testUtilities.CreateNewAccount('US Education', false);
        acc.Account_Formal_Name__c = 'West Virginia University - Morgantown - WV';
        acc.Name = 'West Virginia University - Morgantown - WV';
        acc.Zendesk_Id__c = 123;
        acc.Zendesk_Support__c = true;
        util.bypassAllTriggers = true;
        insert acc;
        
        //create test contact for the requester
        Contact requesterContact = testUtilities.CreateNewContact(acc, false);
        requesterContact.Email = 'akdebastiani@testmail.wvu.edu';
        insert requesterContact;
        
        //Modified By Dipesh Gupta - 09/26/2019 - CR-20190529-13156 - APS replaced by Tech (SSC) as per Taylor Chatter
        //create a project for GradesFirst -> BHGFAD
        Project__c proj = TestUtilities.createProject(false);
        proj.Institution__c = acc.Id;
        proj.Product__c = prog.Id;
		proj.RecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Tech').getRecordTypeId();
		
        util.bypassAllTriggers = true;
        insert proj;
        
        Project_Role__c pRole = new Project_Role__c(Project_Type__c='SSC',
                                                   Role__c='Other',
                                                   Contact__c=requesterContact.Id,
                                                   Project__c=proj.Id,
                                                   Name='test SSC project role',
                                                   Notes__c='test notes');
        insert pRole;
        
        test.startTest();
        
        // Use MultiStaticResourceCalloutMock to
        // specify fake response for a certain endpoint and 
        // include response body in a static resource.    
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(ZendeskService.ZENDESK_CALLOUT_PREFIX + Label.Zendesk_Create_or_Update_Many, 'Mock_Callout_Zendesk_User_Sync');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
        
        Id jobId = database.executeBatch(new Batch_SyncZendeskUserRoles(), 5);
        
        test.stopTest();
        
        system.assertNotEquals(null, jobId);
        
        //verify no errors occurred
        system.assertEquals(0, [SELECT Id FROM Web_Service_Log__c].size());
    }
}