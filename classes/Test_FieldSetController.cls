/**
    Purpose         :   Generic Field Set Component Controller class (Test Class)
    
    Created By      :   Abhinav Sharma
    
    Created Date    :   12/21/2019
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created - Abhinav Sharma - 12/21/2019
**/
@IsTest
private class Test_FieldSetController 
{
    @IsTest(seeAllData=false)
    static void testMetadata() 
    {
        
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(FirstName='Test', LastName='Name', AccountId=testAccount.Id, Email = 'T@test.com', Title = 'test', Phone ='13456');
        insert testContact;
                
        //Bypass Flags
        Util.IsTest(false);
        Util.isTesting = false;
        Util.byPassAllTriggers = false;
        
        //Start test here
        Test.startTest();
        
        FieldSetController.MetadataResponse resp = FieldSetController.getObjectMetadata(testAccount.Id);
        System.assertEquals('Account', resp.sObjectName, 'Expected the correct SObject Type to be returned');
        
        resp = FieldSetController.getObjectMetadata(testContact.Id);
        System.assertEquals('Contact', resp.sObjectName, 'Expected the correct SObject Type to be returned');
        
        resp = FieldSetController.getFieldSetMetadata(testAccount.Id, 'Account_Fields_Set');
        System.assertEquals('Account', resp.sObjectName, 'Expected the correct SObject Type to be returned');
        System.assertNotEquals(null, resp.fieldSetLabel, 'Expected to have a field set name');
        System.assertNotEquals(true, resp.fieldsMetadata.isEmpty(), 'Expected to have fields for the field set');
        
        resp = FieldSetController.getFieldSetMetadata(testContact.Id, 'Contact_Fields_Set');
        System.assertEquals('Contact', resp.sObjectName, 'Expected the correct SObject Type to be returned');
        System.assertNotEquals(null, resp.fieldSetLabel, 'Expected to have a field set name');
        System.assertNotEquals(true, resp.fieldsMetadata.isEmpty(), 'Expected to have fields for the field set');
        
        try 
        {
            resp = FieldSetController.getFieldSetMetadata(null, null);
            System.assertEquals(true, false, 'Expected the test not to continue');
        } 
        catch (AuraHandledException ex) 
        {
            System.assertEquals(true, true, 'Expected the test to encounter an AuraHandledException');
        }
        
        try 
        {
            resp = FieldSetController.getFieldSetMetadata(testAccount.Id, null);
            System.assertEquals(true, false, 'Expected the test not to continue');
        } 
        catch (AuraHandledException ex) 
        {
            System.assertEquals(true, true, 'Expected the test to encounter an AuraHandledException');
        }
        
        try 
        {
            resp = FieldSetController.getFieldSetMetadata(testAccount.Id, 'FakeFieldSetNameForTest');
            System.assertEquals(true, false, 'Expected the test not to continue');
        } 
        catch (AuraHandledException ex) 
        {
            System.assertEquals(true, true, 'Expected the test to encounter an AuraHandledException');
        }
        
        //Stop test here
        Test.stopTest();
    }

    /**
    *  @description    :  This method is used to Insert Data for testing purpose.  
    * 
    *  @args           :   
    * 
    *  @return         :   void
    *
    *	@Revision Log	:	V1.0 - 12/13/2019 - Abhishek Mishra - Created
    *
    **/ 
    @TestSetUp Static void testSetUpData(){
        //Bypassing trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //create the opportunity
        TestUtilities.CreateNewOpportunity(true);
        
    }
    
    
    static testmethod void test_FieldSet () {
        
        //Fetching Opportunities
        List<Opportunity> opps = [Select Id from Opportunity];
        
		//Calling Controller class method 
       	List<String> apiNames = FieldSetController.getFields('Opportunity', 'Proposal_Details').fields;
       	//Assert
        System.assert(apiNames.size() > 0);
        
        //Calling Controller class method 
        List<Opportunity> oppList = FieldSetController.getOpportuntiyDetail(opps[0].Id);
        
        //Asserts
        System.assertEquals(opps.size(), oppList.size());        
        System.assertEquals(null, FieldSetController.getFields('', 'Proposal_Details'));

    }
 
}