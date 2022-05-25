/**
 *  Purpose         :   Test code for the ApprovalOverrideController class
 * 
 *  Created By      :   Victor Hanson
 * 
 *  Created Date    :   1/13/2016
 * 
 * Revision Logs    :   V_1.0 - Created
 *
 **/ 
@isTest
public class Test_ApprovalOverrideController {
    
    //setup test data
    @testSetup static void setup() {
        
        util.BypassAllTriggers = true;

        //setup the program collection test data
        Test_ReferenceRequestController.setupTestData();
        

        //create the requesting contact record
        Contact reqContact = TestUtilities.CreateNewContact(false);
        reqContact.lastName = 'reqContact';
        reqContact.recordTypeId = Test_ReferenceRequestController.CONTACT_EXTERNAL_RT_ID;
        insert reqContact;
        
        //get the existing ambassador contact, which was created in testSetup
        Contact ambassadorContact = [SELECT Id FROM Contact WHERE LastName = 'Ambassador'];

        //Insert new Program
        Program__c testProgram = testUtilities.createNewProgram(true);
        
        //create the membership related to the institution
        util.BypassAllTriggers = true;
        Membership__c mem = new Membership__c(Account_Name__c = reqContact.AccountId, Program__c = testProgram.Id);
        insert mem;
        util.BypassAllTriggers = false;
        
    	test.startTest();
        //create the Reference Request
        Reference_Request__c req = new Reference_Request__c(Request_Status__c = 'New',
                                                            Reference_Modules__c = 'CCC',
                                                            Requesting_Contact__c = reqContact.Id,
                                                            Requesting_Institution__c = reqContact.AccountId,
                                                            Source_Membership__c = mem.Id,
                                                            Date_Needed_By__c = Date.today(),
                                                            Number_of_References_Needed__c = 1,
                                                            Reference_Type_Needed__c = 'Individual',
                                                            Submitted_By__c = userInfo.getUserId());
        insert req;
        
        //create the Reference Request Contact
        Reference_Request_Contact__c rrc = new Reference_Request_Contact__c(Reference_Contact__c = ambassadorContact.Id,
                                                                            Reference_Request__c = req.Id,
                                                                            Reference_Modules__c = 'CCC',
                                                                            Approval_Status__c = 'Pending',
                                                                            Reference_Lead__c = userInfo.getUserId());
        insert rrc;
        
        //submit all reference request contacts for approval
        ReferenceRequestContactHelper.submitForApproval(new set<Id>{rrc.Id});
    	test.stopTest();
    }
    
    /**
     * 
     * @description: Approve a reference request contact record.  Verify the comments and approval status are reflected on the record
     * 
     **/
    static testMethod void testApproved() {
        //get the reference request contact that was created in the testSetup method
        List<Reference_Request_Contact__c> rrc = [SELECT Id, Reference_Modules__c, Reference_Attributes__c FROM Reference_Request_Contact__c];
        
        //verify there is an approval pending
        Id pendingApprovalId = ApprovalOverrideController.getWorkItemId(rrc[1].Id);
        system.assertNotEquals(null, pendingApprovalId, 'The Reference Request Contact should have a pending approval');
        
        //set the page reference
        PageReference pageRef = Page.ApprovalOverride;
        test.setCurrentPage(pageRef);
        
        string APPROVAL_INSTRUCTIONS = 'Approving this request will update the Status to Approved and notify the Reference Lead.';
        string approvalComments = 'approved!!';
        boolean isApproved = true;
        		
        //Set currentpage parameters
        ApexPages.currentPage().getParameters().put('recordId', rrc[1].Id);
        ApexPages.currentPage().getParameters().put('objLabel', 'Reference Request Contact');
        ApexPages.currentPage().getParameters().put('fields', 'Submitted_By__r.Name,Reference_Request_Source__c,Reference_Institution__c,Reference_Contact__r.Name,Reference_Modules__c,Reference_Attributes__c');
        ApexPages.currentPage().getParameters().put('commentField', 'Approval_Reason__c');
        ApexPages.currentPage().getParameters().put('instructions', APPROVAL_INSTRUCTIONS);
        
		test.startTest();
		
        //instantiate the controller
        ApprovalOverrideController controller = new ApprovalOverrideController();
        system.assertEquals(6, controller.fieldValueMap.size());
        
        for (ApprovalOverrideController.fld field : controller.flds) {
            if (field.label == 'Reference Modules') system.assertEquals(rrc[1].Reference_Modules__c, field.value);
        }

        //approve
        ApprovalOverrideController.getApprovalResult(rrc[1].Id, isApproved, approvalComments, 'Approval_Reason__c');
        
		test.stopTest();
		
        //get the reference request contact
        rrc = [SELECT Id, Approval_Reason__c, Approval_Status__c FROM Reference_Request_Contact__c WHERE Id = :rrc[1].Id Limit 1];
        //verify the approval comments populated correctly
        system.assertEquals(approvalComments, rrc[0].Approval_Reason__c);
        system.assertEquals('Approved', rrc[0].Approval_Status__c, 'Approval Status should be "Approved" when the reference request contact is approved.');
    }
    
    /**
     * 
     * @description: Reject the approval of a reference request contact record.  Verify the comments and approval status are reflected on the record
     * 
     **/
    static testMethod void testRejected() {
        //get the reference request contact that was created in the testSetup method
        List<Reference_Request_Contact__c> rrc = [SELECT Id, Reference_Modules__c, Reference_Attributes__c FROM Reference_Request_Contact__c];
        
        //verify there is an approval pending
        Id pendingApprovalId = ApprovalOverrideController.getWorkItemId(rrc[1].Id);
        system.assertNotEquals(null, pendingApprovalId, 'The Reference Request Contact should have a pending approval');
        
        //set the page reference
        PageReference pageRef = Page.ApprovalOverride;
        test.setCurrentPage(pageRef);
        
        string APPROVAL_INSTRUCTIONS = 'Approving this request will update the Status to Approved and notify the Reference Lead.';
        string approvalComments = 'Rejected!';
        boolean isApproved = false;
        
        //Set currentpage parameters
        ApexPages.currentPage().getParameters().put('recordId', rrc[1].Id);
        ApexPages.currentPage().getParameters().put('objLabel', 'Reference Request Contact');
        ApexPages.currentPage().getParameters().put('fields', 'Submitted_By__r.Name,Reference_Request_Source__c,Reference_Institution__c,Reference_Contact__r.Name,Reference_Modules__c,Reference_Attributes__c');
        ApexPages.currentPage().getParameters().put('commentField', 'Approval_Reason__c');
        ApexPages.currentPage().getParameters().put('instructions', APPROVAL_INSTRUCTIONS);
        
		test.startTest();
		
        //instantiate the controller
        ApprovalOverrideController controller = new ApprovalOverrideController();
        system.assertEquals(6, controller.fieldValueMap.size());
        
        for (ApprovalOverrideController.fld field : controller.flds) {
            if (field.label == 'Reference Modules') system.assertEquals(rrc[1].Reference_Modules__c, field.value);
        }
		
        //reject the approval request
        ApprovalOverrideController.getApprovalResult(rrc[1].Id, isApproved, approvalComments, 'Approval_Reason__c');
        
		test.stopTest();
		
        //get the reference request contact
        rrc = [SELECT Id, Approval_Reason__c, Approval_Status__c FROM Reference_Request_Contact__c WHERE Id = :rrc[1].Id Limit 1];
        //verify the approval comments populated correctly
        system.assertEquals(approvalComments, rrc[0].Approval_Reason__c);
        system.assertEquals('Denied', rrc[0].Approval_Status__c, 'Approval Status should be "Denied" when the reference request contact is rejected.');
    }
    
}