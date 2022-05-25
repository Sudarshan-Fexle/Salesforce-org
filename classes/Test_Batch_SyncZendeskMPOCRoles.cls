/**
*   Purpose         :   Test class for Batch_SyncZendeskMPOCRoles 
*            
*   Create By       :   Shalu Sharma
* 
*   Created Date    :   11/10/2021
*
*   Revision Log    :   V_1.0 - Created - Shalu Sharma - CR-20210301-14957
*   
*
**/
@isTest(seeAllData=false)
public class Test_Batch_SyncZendeskMPOCRoles 
{
    @testSetup static void dataSetup()
    {
        Util.byPassAllTriggers = true;
        
        Account account = new Account(Name = 'Test Case Account 1', RecordTypeId = Util.recordtypemap('Account').get('US Corporate'), 
                                      Academy_Programs_Available_for_Outreach__c = '', BI_Programs_Available_for_Outreach__c = '', 
                                      Core_Programs_Available_for_Outreach__c = '', Zendesk_Id__c = 12345, Zendesk_Support__c = true);
        insert account;
        
        String randomNumber  = String.valueOf(Integer.valueof((Math.random() * 1000)));
        Contact cont = TestUtilities.CreateNewContact(account, false);
        cont.Contact_Status__c = 'Active';
        cont.Email = 'test'+randomNumber+'@gmail.com';
        insert cont;
        
        List<Program__c> programs = new List<Program__c>();
        programs.add(new Program__c(Name = 'Test Trigger Program', New_Business_Marketer__c = 'RI Marketer', 
                                    Program_Acronym__c = 'YOUVC', Create_memberships__c = 'No', Business_line__c = 'PT'));
        insert programs;
        
        List<Membership__c> memberships = new List<Membership__c>();
        memberships.add(new Membership__c(Name = 'Test Membership', Account_Name__c = account.Id, Program__c = programs[0].Id));
        insert memberships;
        
        List<Membership_Key_Contact__c> membershipKeyContacts = new List<Membership_Key_Contact__c>();
        membershipKeyContacts.add(new Membership_Key_Contact__c(Name='Test 1', Contact__c = cont.id, Role_Type__c = 'PT', Role__c = 'Exec Sponsor', 
                                                                Membership__c = memberships[0].Id, Pubs__c = true, Meetings__c = true,
                                                                Key_Contact_Status__c = 'Active'));
        insert membershipKeyContacts;
        
        Util.byPassAllTriggers = false;
    }
    
    static testMethod void testBatch_SyncZendeskMPOCRoles() 
    {
        Test.startTest();
        
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(ZendeskService.ZENDESK_CALLOUT_PREFIX + Label.Zendesk_Create_or_Update_Many, 'Mock_Callout_Zendesk_User_Sync');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        
        Id jobId = database.executeBatch(new Batch_SyncZendeskMPOCRoles(), 5);
        
        Test.stopTest();
        
        system.assertNotEquals(null, jobId);
        //verify no errors occurred
        system.assertEquals(0, [SELECT Id FROM Web_Service_Log__c].size());
    }
    
}