/**
 *  Description     :   unit tests for the ZendeskService class
 *
 *  Created By      :	Victor Hanson
 *
 *  Created Date    :   09/01/2018
 *
 *  Revision Logs   :   V_1.0 - Created
 *
**/
@isTest
public class Test_ZendeskService {
    
    // Init Test Data
    @TestSetup
    static void initData() {
        
        //create program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Program_Acronym__c = 'BHGFAD';
        prog.Integration_Support__c = Constants.ZENDESK;
        util.bypassAllTriggers = true;
        insert prog;
        util.bypassAllTriggers = false;
        
        //create test account
        Account acc = testUtilities.CreateNewAccount('US Education', false);
        acc.Account_Formal_Name__c = 'West Virginia University - Morgantown - WV';
        acc.Name = 'West Virginia University - Morgantown - WV';
        //acc.Zendesk_Id__c = 123;
        acc.Zendesk_Support__c = true;
        util.bypassAllTriggers = true;
        insert acc;
        
        //create a project for GradesFirst -> BHGFAD
        Project__c proj = TestUtilities.createProject(false);
        proj.Institution__c = acc.Id;
        proj.Product__c = prog.Id;
        insert proj;
        
        //create test contact for the requester
        Contact requesterContact = testUtilities.CreateNewContact(acc, false);
        requesterContact.Email = 'akdebastiani@testmail.wvu.edu';
        insert requesterContact;
        
        //create user for the assignee
        Profile specialistProfile = [SELECT Id FROM Profile WHERE Name = 'Specialist' LIMIT 1];
        User assigneeUser = testUtilities.CreateNewUser(specialistProfile, false);
        assigneeUser.FirstName = 'Stephen';
        assigneeUser.LastName = 'Brown';
        assigneeUser.Email = 'sbrown@testeab.com';
        insert assigneeUser;
        
        //create sync field
        Sync_Field__c syncField = new Sync_Field__c(Name='zdTicket.Product->Case.Product Name',
                                                    Source_Object_API_Name__c='Ticket',
                                                    Source_Field_API_Name__c='27198298',
                                                    Source_Record_Type_Developer_Name__c='N/A',
                                                    Target_Field_API_Name__c='Product_Name__c',
                                                    Target_Object_API_Name__c='Case',
                                                    Target_Field_Type__c='String'
                                                   );
        insert syncField;
    }
    
    static testmethod void testMultipleTicketsToZendesk() {
        
        Integer MOCK_TICKET_ID_89 = 89;
        Integer MOCK_TICKET_ID_90 = 90;
        
        //instantiate the zendesk service
        ZendeskService zdService = new ZendeskService();
        zdService.syncSinceDate = System.today(); //Date.newInstance(2015, 08, 12);
        test.startTest();
        // Use MultiStaticResourceCalloutMock to
        // specify fake response for a certain endpoint and 
        // include response body in a static resource.    
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(zdService.getSearchURL(), 'Mock_Callout_Zendesk_Ticket_Search'); //returns 2 tickets with ids 89 & 90
        //add ticket ids to the zdTicketIdsToSync
        //zdService.zdTicketIdsToSync = new List<String> { '89', '90' };
        multimock.setStaticResource(zdService.getTicketURL(), 'Mock_Callout_Zendesk_Ticket');
        multimock.setStaticResource(zdService.getTicketCommentURL(MOCK_TICKET_ID_89), 'Mock_Callout_Zendesk_Ticket_Comments_89');
        multimock.setStaticResource(zdService.getTicketCommentURL(MOCK_TICKET_ID_90), 'Mock_Callout_Zendesk_Ticket_Comments_90');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
                
        //get the tickets
        zdService.getTickets();
        
        //assertions
        system.assertEquals(2, zdService.zdWrapper.tickets.size());
        system.assertEquals(2, zdService.casesToUpsert.size());
        
        //upsert the cases
        List<Database.UpsertResult> upsertResults = zdService.upsertCases();
        
        //get case comments
        zdService.populateCaseCommentMap();
        
        //upsert the comments
        List<Database.UpsertResult> commentUpsertResults = zdService.upsertCaseComments();
        
        //Added By -  Chirag Soni - 10/28/2021 - CR-20210301-14957 - code coverage increase. 
        zdService.upsertMemberSupport();
        
        test.stopTest();
        
        //get case
        List<Case> cases = [SELECT Id, Zendesk_Ticket_Id__c, Owner.Email, Type, Status, Subject, 
                            (SELECT Id, CommentBody FROM CaseComments) 
                            FROM Case WHERE Zendesk_Ticket_Id__c = :zdService.zdWrapper.tickets[0].id];
        
        //Case assertions
        system.assertEquals(upsertResults[0].isSuccess(), true);
        system.assertEquals(1, cases.size());
        system.assertNotEquals(null, cases[0].Type);
        system.assertNotEquals(null, cases[0].status);
        
        //Case Comment assertions (note: the Mock REST response used in this example has 6 ticket comments)
        system.assertEquals(commentUpsertResults[0].isSuccess(), true);
        system.assertEquals(1, cases[0].CaseComments.size());
    }
    
    static testmethod void testOrganizationCalloutToZendesk() {
        
        //get the account that was created
        Account acct = [SELECT Id, Counter_Id__c FROM Account WHERE Zendesk_Support__c = true LIMIT 1];
        
        //instantiate the zendesk service
        ZendeskService zdService = new ZendeskService();
        
        test.startTest();
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, new apiMock(getMockOrganizationResponse(acct.Counter_Id__c), 200));
        
        //get the organizations
        zdService.syncOrganizations();
        
        test.stopTest();
        
        //Get the account
        acct = [SELECT Id, Zendesk_Id__c FROM Account WHERE Id = :acct.Id];
        
        //Verify Zendesk_Id__c
        system.assertNotEquals(null, acct.Zendesk_Id__c);
        
    }
    
    //test callout error handling
    static testmethod void testCalloutError() {
        
        //instantiate the zendesk service
        /*ZendeskService zdService = new ZendeskService();
        zdService.syncSinceDate = Date.newInstance(2015, 08, 12);
        zdService.zdWrapper = new ZendeskWrapper();*/
        
        //setup the mock callout
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_Callout_Zendesk_Error');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        
        //enqueue the job to get tickets, which should return an error response
        ZendeskService zdService = new ZendeskService();
	zdService.syncSinceDate = system.today();
        QueueableZendeskSync q = new QueueableZendeskSync(zdService, ZendeskService.SYNC_TYPE_TICKETS);          
        system.enqueueJob(q);
        
        test.stopTest();
        
        //verify a web service log was created for the error
        List<Web_Service_Log__c> wsLogs = [SELECT Id FROM Web_Service_Log__c];
        system.assertEquals(1, wsLogs.size());
    }
    
    //test callout error handling
    static testmethod void testCalloutError2() {
        
        //instantiate the zendesk service
        /*ZendeskService zdService = new ZendeskService();
        zdService.syncSinceDate = Date.newInstance(2015, 08, 12);*/
        
        //setup the mock callout
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_Callout_Zendesk_Error');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');
        
        
        test.startTest();
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        //enqueue the job to get tickets, which should return an error response
        ZendeskService zdService = new ZendeskService();
	zdService.syncSinceDate = system.today();
        QueueableZendeskSync q2 = new QueueableZendeskSync(null, ZendeskService.SYNC_TYPE_TICKETS);
        system.enqueueJob(q2);
        
        test.stopTest();
        
        //verify a web service log was created for the error
        List<Web_Service_Log__c> wsLogs = [SELECT Id FROM Web_Service_Log__c];
        system.assertEquals(1, wsLogs.size());
    }
    
    //test callout error handling
    static testmethod void testCalloutError3() {
        
        //instantiate the zendesk service
        /*ZendeskService zdService = new ZendeskService();
        zdService.syncSinceDate = Date.newInstance(2015, 08, 12);*/
        
        //setup the mock callout
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_Callout_Zendesk_Error');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');
        
        
        test.startTest();
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        //enqueue the job to get tickets, which should return an error response
        ZendeskService zdService = new ZendeskService();
	zdService.syncSinceDate = Date.newInstance(2015, 08, 12);
        QueueableZendeskSync q = new QueueableZendeskSync(zdService, ZendeskService.SYNC_TYPE_TICKETS);
        system.enqueueJob(q);
        
        test.stopTest();
        
        //verify a web service log was created for the error
        List<Web_Service_Log__c> wsLogs = [SELECT Id FROM Web_Service_Log__c];
        system.assertEquals(1, wsLogs.size());
    }
    
     // Added By -  Chirag Soni - 10/28/2021 - CR-20210301-14957 - code coverage increase. 
    static testmethod void testSyncProjectRoles()
    {
        Util.BypassAllTriggers = true;
        
        Account acc = [SELECT Id, Zendesk_Id__c FROM Account LIMIT 1];
        acc.Zendesk_Id__c = 123;
        update acc;
        
        Contact contact = [SELECT Id FROM Contact Limit 1];
        
        Project__c proj = [SELECT Id, RecordTypeId FROM Project__c LIMIT 1];
        proj.RecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Tech').getRecordTypeId();
        update proj;
        
        Project_Role__c pRole = new Project_Role__c(Project_Type__c='SSC',
                                                    Role__c='Other',
                                                    Contact__c=contact.Id,
                                                    Project__c=proj.Id,
                                                    Name='test SSC project role',
                                                    Notes__c='test notes');
        insert pRole;
        
        Util.BypassAllTriggers = false;
        
        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(ZendeskService.ZENDESK_CALLOUT_PREFIX + Label.Zendesk_Create_or_Update_Many, 'Mock_Callout_Zendesk_User_Sync');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        
        Test.setMock(HttpCalloutMock.class, multimock);
        
        ZendeskService zdService = new ZendeskService();
        zdService.syncProjectRoles(new Set<Id>{contact.Id});
        
        Test.stopTest();
        
        //verify no errors occurred
        system.assertEquals(0, [SELECT Id FROM Web_Service_Log__c].size());
        
    }
    
    
    private static String getMockOrganizationResponse(String counterId) {
        return '{' +
            '"organizations": [' +
            '        {' +
            '            "url": "https://gradesfirst1437647639.zendesk.com/api/v2/organizations/360054545114.json",' +
            '            "id": 360054545114,' +
            '            "name": "10583942468_deleted_University of Maine at Machias",' +
            '            "shared_tickets": false,' +
            '            "shared_comments": false,' +
            '            "external_id": null,' +
            '            "created_at": "2018-09-07T13:20:51Z",' +
            '            "updated_at": "2018-09-11T17:30:23Z",' +
            '            "domain_names": [],' +
            '            "details": "",' +
            '            "notes": "",' +
            '            "group_id": null,' +
            '            "tags": [' +
            '                "pod_4"' +
            '            ],' +
            '            "organization_fields": {' +
            '                "date": null,' +
            '                "high_touch": null,' +
            '                "membership_status": "[BHCS - Student Success Collaborative (SSC) - Navigate - Member - Integrated]",' +
            '                "multi_line_text": null,' +
            '                "numeric": null,' +
            '                "salesforce_id": "' + counterId + '"' +
            '            }' +
            '        }' +
            '    ],' +
            '    "next_page": "https://gradesfirst1437647639.zendesk.com/api/v2/organizations.json?page=2",' +
            '    "previous_page": null,' +
            '    "count": 1289' +
            '}';
    }
	
	/**
     * @description: mock class to test http callouts
     **/
    public class apiMock implements HttpCalloutMock {
        private String testResponse;
        private Integer testStatusCode;

        public apiMock(String testResponse, Integer testStatusCode){
            this.testResponse = testResponse;
            this.testStatusCode = testStatusCode;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody(testResponse);
            res.setStatusCode(testStatusCode);
            return res;
        }
    }    
    
}