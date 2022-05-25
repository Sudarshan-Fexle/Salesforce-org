/*
    Purpose         :   Class is used to provide coverage and test the functionality of testUtilities
                
    Create By       :   Rajeev Jain
    
    Created Date    :   10/04/2018
    
    Revision Log    :   V1.0 Created
						v1.01 Modified By - Seemu Saikia -CR-20190501-13072- 05/06/2019 - #Spring CleanUp
*/
@istest
public class Test_TestUtilities {

    @testSetup static void testMyUnitTest() {
        
        //BYpassing all triggers
        Util.BypassAllTriggers = true;
        
        
        
    }
    
    @isTest static void myUnitTest() {
        
        //BYpassing all triggers
        Util.BypassAllTriggers = true;
        
        Id rTypeId = TestUtilities.FindRecordTypeId('Account', 'Vendor');
        System.assertEquals('012C0000000URbq', rTypeId);
        
        //Creating opportunity
        Opportunity opp = TestUtilities.CreateNewOpportunity(true);
        System.assert(opp != null);
        
        //Change request Creation
        SFDC_Change_Request__c cRs = TestUtilities.CreateChangeRequest(true);
        System.assert(cRs != null);
        
        TestUtilities.CreateAdvUserContact(true);
        //TestUtilities.CreateRequestComment(true);
        TestUtilities.CreateNewEvent(true);
        TestUtilities.CreatenewUser(true);
        
        //test start
        Test.startTest();
            
        	//Creating the Memebership record 
            Membership__c mem = TestUtilities.CreateNewMembership(TestUtilities.CreateNewAccount(true).Id, TestUtilities.CreateNewProgram(true).Id, true);
            System.assert(mem != null);
        
        	//Creating the Subscription/Subsctiption period 
        	TestUtilities.createNewSubscriptionPeriod(TestUtilities.createNewSubscription(mem.Id, true).Id, true);
        	//Creating Quote
        	TestUtilities.createNewSbqqQuote(true);
        	
        	//Creating the Content/Attachment/Document records.
        	TestUtilities.createNewAttachment(mem.Id, true);
        	TestUtilities.createNewDocument(true);
        	TestUtilities.createNewContentVersion(true);
        
        	//Creating the contact
        	TestUtilities.CreateNewContact(true);
            Program__c prgm = TestUtilities.CreateNewRIProgram(true);
            System.assert(prgm != null);
        	
        	//Creating the Standard Account. 
        	TestUtilities.createNewStandardContract(TestUtilities.CreateNewAccount('Vendor', true).Id, true);
        	
        	//Creating Contract ABc Record 
        	TestUtilities.CreateNewContract(true);  
        
        	//Creating the Product
        	TestUtilities.createNewProduct(prgm.Id, true);
        	
        	//Creating subscription option records.
        	/* Spring CleanUp
        	TestUtilities.CreateNewSubscriptionOption(true);  
        	TestUtilities.CreateNewEligibleSubscriptionOption(TestUtilities.CreateNewSubscriptionOption(true), true);
        	
			TestUtilities.CreateNewEligibleSubscriptionOption(prgm, true);  
            TestUtilities.CreateNewEligibleSubscriptionOption(true);    
            */
        	TestUtilities.resetOpportunityTriggerFlags();
            System.assertEquals(Util.ByPassAllTriggers, false);
            
            /*//BypassAll triggers
            Util.ByPassAllTriggers = true;
        	TestUtilities.createBudgetAllocation(TestUtilities.createBudget(TestUtilities.createDepartment(true).Id, true).Id,
                                                 TestUtilities.createPurchaseRequest(true).Id, null, true);
			*/
            //TestUtilities.CreateNewCreditCard(true);  
           // TestUtilities.CreateCreditCardSettings();
        Test.stopTest();
        
        //TestUtilities.CreateCreditCardSettings();
        TestUtilities.createSiteIssue(TestUtilities.createProject(true).Id,true);
        TestUtilities.createSyncFields();
        
        
        
        //Set to hold the profile ids 
        set<String> setProfileIds = new set<String>{'Admin'};
        
        //Creating the Modification on the CR
        TestUtilities.createModifications(cRs.Id, setProfileIds, 'Profile access Changed');
        
    }
}