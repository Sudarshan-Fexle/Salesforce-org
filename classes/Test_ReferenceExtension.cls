/**
 *	Purpose			:	Test code for the ReferenceExtension class
 * 
 * 	Created By		:	Victor Hanson
 * 
 * 	Created Date	:	1/13/2016
 * 
 * Revision Logs	:	V_1.0 - Created
 * 					:   V_1.1 - Modified by Dipesh Gupta - 11/08/2017 - Rev Mgmt 606 - Validation Failure error fixes Method - 'testSetDedicatedAdvisor'. 
 *					:	V_1.2 - Commented By Dipesh Gupta - 01/10/2019 - CR-20190523-13127 - For removing the dependency
 **/ 
@isTest
public class Test_ReferenceExtension {
	
    //setup test data
    @testSetup static void setup() {
        /**
         * @description:1) Setup 3 users with related contacts
         * 				2) Create Program Collections/Collection Perspectives/Collection Perspective Children
         * 				3) Create an Ambassador reference for a contact
         **/
        Test_ReferenceRequestController.setupTestData();
        
        //create dynamic picklist records
        Test_PicklistHelper.createDynamicPicklist();
    }
    
    static testMethod void testReferenceExtension() {
        //create the reference record
        Reference__c ref = new Reference__c();
        
        // Commented By Dipesh Gupta - 01/10/2019 - CR-20190523-13127 - For removing the dependency
        //set the page reference
        /*PageReference pageRef = Page.Reference_Edit;
        test.setCurrentPage(pageRef);*/
        
        //pass PT recordType in params
        ApexPages.currentPage().getParameters().put('RecordType', Schema.SObjectType.Reference__c.getRecordTypeInfosByName().get(Label.PT).getRecordTypeId());
        
        //instantiate the controller
        ReferenceExtension controller = new ReferenceExtension(new ApexPages.standardController(ref));
        system.assertEquals(Schema.SObjectType.Reference__c.getRecordTypeInfosByName().get(Label.PT).getRecordTypeId(), controller.recordTypeId);
        system.assertEquals('PT', controller.recordTypeName);
        
        //get the existing ambassador contact
        Contact c = [SELECT Id, AccountId, Account.Principal__c, Account.Associate_Principal__c FROM Contact WHERE lastName = 'Ambassador'];
        
        controller.reference.Contact_Name__c = c.Id;
        controller.setInstitution();
        
        //create dedicated advisor user
        util.BypassAllTriggers = true;
        User dedicatedAdvisor = TestUtilities.CreatenewUser(true);
        
        //create the program
        util.BypassAllTriggers = true;
        Program__c prog = TestUtilities.CreateNewProgram(true);
        //create a Project
        Project__c proj = TestUtilities.createProject(false);
        proj.Dedicated_Advisor__c = dedicatedAdvisor.Id;
        util.BypassAllTriggers = true;
        insert proj;
        //create the membership
        Membership__c mem = TestUtilities.CreateNewMembership(c.AccountId, prog.Id, false);
        mem.Primary_Project__c = proj.Id;
        util.BypassAllTriggers = true;
        insert mem;
        
        controller.reference.Membership__c = mem.Id;
        controller.setDedicatedAdvisor();
        system.assertEquals(dedicatedAdvisor.Id, controller.reference.Dedicated_Advisor__c);
        
        controller.reference.Projected_Vetting_Date__c = date.today();
        controller.reference.Reference_Module__c = 'CCC';
        
        system.assertEquals(c.AccountId, controller.reference.Institution__c);
        //system.assertEquals(c.Account.Principal__c, controller.reference.NASA_Principal__c);
        //system.assertEquals(c.Account.Associate_Principal__c, controller.reference.NASA_Associate_Principal__c);
        
        //verify the reference module attributes values are in the attributes list
        system.assertEquals(true, controller.attributes.contains('Multi/Regional Health System'));
        
        //save the reference request
        controller.save();
        
      /*  //verify there are no errors
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            if (msg.getSeverity() == ApexPages.Severity.ERROR) {
                //if there is an error, make sure it causes the test to fail
                system.assertEquals('ERROR', msg.getSummary());
            }
        }
        
        system.assertEquals('/', controller.retURL); */
    }
    
    //Modified By Dipesh Gupta - Rev Mgmt 606 Production validation failure fixes. 11/08/2017 - used Util.ByPassAllTrigger flag to avoid unwanted code run.
	static testMethod void testSetDedicatedAdvisor() {
        
        //By pass all triggers
        Util.BypassAllTriggers = true;
        
        //create a dedicated advisor user
        User dedicatedAdvisor = TestUtilities.CreatenewUser(true);
        //create a program
        Program__c p = TestUtilities.CreateNewProgram(true);
        system.assertNotEquals(null, p.Id);
        //create the payer institution
        Account payerInstitution = TestUtilities.CreateNewAccount(true);
        //create a project and relate it to the member payer
        Project__c proj = TestUtilities.createProject(false);
        proj.Dedicated_Advisor__c = dedicatedAdvisor.Id;
        insert proj;
        system.assertNotEquals(null, proj.Id);
        //create a contract abc
        Contract__c contract = TestUtilities.CreateNewContract(payerInstitution.Id, null, p.Id, true);
        //create 2 memberships
        list<Membership__c> memberships = new list<Membership__c>();
        Membership__c memberPayer = TestUtilities.CreateNewMembership(payerInstitution.Id, p.Id, false);
        memberPayer.Primary_Project__c = proj.Id;
        memberships.add(memberPayer);
        Membership__c memberIntegrated = TestUtilities.CreateNewMembership(payerInstitution.Id, p.Id, false);
        memberIntegrated.Active_Contract_Idenfied__c = contract.Id;
        memberships.add(memberIntegrated);
        util.BypassAllTriggers = true;
        insert memberships;
        system.assertNotEquals(null, memberPayer.Id);
        
        //By pass all trigger is false.
        Util.BypassAllTriggers = false;
        
        //instantiate the reference extension
        Reference__c ref = new Reference__c();
        ReferenceExtension controller = new ReferenceExtension(new ApexPages.standardController(ref));
        controller.reference.Membership__c = memberIntegrated.Id; //set the membership to the integrated member
        
        test.startTest();
        
        //call the method to populate the dedicated advisor
        controller.setDedicatedAdvisor();
        system.assertEquals(dedicatedAdvisor.Id, controller.reference.Dedicated_Advisor__c, 'The dedicated advisor should have been pulled from the Member - Payer memberships Primary Program');
        test.stopTest();
    }
}