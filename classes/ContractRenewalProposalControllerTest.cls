@isTest
public class ContractRenewalProposalControllerTest {
	
    /**
     * Setup the test data by assigning the Contract Renewal Permission set to the current user
     **/
    @testSetup static void testData() {
        // Create PermissionSet with Custom Permission and asisgn to test user
        PermissionSet ps = new PermissionSet();
        ps.Name = 'ContractRenewalPermissionTest';
        ps.Label = 'ContractRenewalPermissionTest';
        insert ps;
        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = ps.Id;
        sea.SetupEntityId = [select Id from CustomPermission where DeveloperName = :CPQConstants.CUSTOM_PERMISSION_RENEWAL_PROPOSAL_BUTTON][0].Id;
        insert sea;
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = UserInfo.getUserId();
        psa.PermissionSetId = ps.Id;
        insert psa;
    }
    
    @IsTest
	private static void testContractRenewalProposalActive() {
		
        //create an account
        Account a = TestUtilities.CreateNewAccount(true);
        
		//create a contract that hasn't been activated
		util.bypassAllTriggers = true;
		Contract contract = TestUtilities.createNewStandardContract(a.Id, true);
		util.bypassAllTriggers = false;
        
        //update contract to Activated
        contract.Status = 'Activated';
        
		util.bypassAllTriggers = true;
        update contract;
		util.bypassAllTriggers = false;
        
        //set the page reference
        Test.setCurrentPageReference(new PageReference('Page.ContractRenewalProposal'));
        System.currentPageReference().getParameters().put('id', contract.Id);
        
        //Initialization of controller
        ContractRenewalProposalController controller = new ContractRenewalProposalController();
        
        //update the contract
        controller.updateContract();
        
        //verify the proper error is returned
        system.assertEquals(true, ApexPages.hasMessages(), 'A page message should have returned');
        
        system.assertEquals(Label.RENEWAL_SUCCESS, ApexPages.getMessages()[0].getDetail());
	}
    
    @IsTest
	private static void testContractRenewalProposalInactive() {
		
        //create an account
        Account a = TestUtilities.CreateNewAccount(true);
        
		//create a contract that hasn't been activated
		Contract contract = TestUtilities.createNewStandardContract(a.Id, true);
        
        //set the page reference
        Test.setCurrentPageReference(new PageReference('Page.ContractRenewalProposal'));
        System.currentPageReference().getParameters().put('id', contract.Id);
        
        //Initialization of controller
        ContractRenewalProposalController controller = new ContractRenewalProposalController();
        
        //update the contract
        controller.updateContract();
        
        //verify the proper error is returned
        system.assertEquals(true, ApexPages.hasMessages(), 'Message should have returned due to the contract not being activated');
        system.assertEquals(Label.RENEWAL_CONTRACT_NOT_ACTIVATED, ApexPages.getMessages()[0].getDetail());
		
	}

	/*@IsTest
	private static void testCustomPermissionNotAssigned() {

		// Assert the CustomPermissionsReader confirms custom permission not assigned
		System.assertEquals(false, new CustomPermissionsReader().hasPermission(TEST_CUSTOM_PERMISSION));
	}*/
}