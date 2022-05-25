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
@isTest(seeAllData=false)
private class MemberSupportControllerTest {
    
    /**
    Purpose         :   Test class for MemberSupportController
                
    Create By       :   Abhinav Sharma
    
    Created Date    :   04/06/2016
    
    Revision Log    :   v1.0 - Created - CR-20160224-9632 - 04/06/2016
                        v1.1 - Created - CR-20200520-14075 - 06/12/2020
    **/
    @testSetup static void dataSetup()
    {
        //Bypass all triggers
        Util.BypassAllTriggers = true;
        
        //Create test data for the Sync Fields custom setting that syncs Case -> Mem Support fields
        TestUtilities.createSyncFields();
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        
        //Create a project
        Project__c project = TestUtilities.CreateProject(false);
        project.Project_Manager__c = UserInfo.getUserId();
        Insert project;
        
        // site Issue
        Site_Issue__c siteIssue = TestUtilities.createSiteIssue(project.Id, true);
        
        String ask_EAB_RTYPE = Schema.SObjectType.CASE.getRecordTypeInfosByName().get('Ask EAB').getRecordTypeId(); 
        
        //Create a sample case record associated with the Member Support record
        Case aCase = new Case(Subject = 'testSubject',
                              Status = '01-New',
                              Tier_I_Support_Analyst__c = UserInfo.getUserId(),
                              Priority = 'Low',
                              Origin = 'Incoming Call',
                              ContactId = contact.Id,
                              Description = 'Test Description',
                              RecordTypeId = ask_EAB_RTYPE, 
                              Current_Results__c = 'test current results',
                              Expected_Results__c = 'test expected results',
                              Project_Source_MS__c = project.Id,
                              Member_Support_Ticket__c = siteIssue.Id,
                              Steps_to_Reproduce_MS__c = 'test steps to reproduce');
        //Spring CleanUp                      
        //Button_Used__c = true);
        
        //Perform the test by inserting the contact
        test.startTest();
        
        //Enabling triggers
        Util.BypassAllTriggers = false;

        //Insert Case
        insert aCase;
        System.assert(aCase != null);
        
    }
    
    static testmethod void test_Constructor() 
    {
        
        List<Site_Issue__c> memberSupports = [SELECT ID, Tier__c FROM Site_Issue__c];
        System.assert(memberSupports != null);
        System.assert(memberSupports.size() == 1);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(memberSupports[0]);
        MemberSupportController obj = new MemberSupportController(sc);
        try {
            Boolean res = obj.acceptButtonError;
            Id res2 = obj.projectManagerId;
            String str = obj.projectTPM;
            
        } catch(Exception ex) {
            
            //Asserting for the results
            System.assert(ex.getMessage().contains(System.Label.ERROR_TIER_I_ACCEPT_BUTTON));
        }
        
    }
    
    static testmethod void test_acceptIssue() 
    {
        List<Site_Issue__c> memberSupports = [SELECT ID, Tier__c FROM Site_Issue__c];
        System.assert(memberSupports != null);
        System.assert(memberSupports.size() == 1);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(memberSupports[0]);
        MemberSupportController obj = new MemberSupportController(sc);
        
        try {
            obj.acceptIssue();
        } catch(Exception e){
            
        }
    }
    
    
}