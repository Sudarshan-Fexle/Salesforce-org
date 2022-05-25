/**
*   Purpose         :   Test class for SandboxCreateAndRefreshManager
*            
*   Create By       :   Abhinav Sharma
* 
*   Created Date    :   02/05/2020
*
*   Revision Log    :   V_1.0 - Created - Abhinav Sharma 
*                       V_1.1 - Modified by- Abhinav Sharma - 09/15/2020 - CR-20200728-14372 - Added test data for the Institution and Contact for Assigning site content recommendation
*   Coverage        :   V_1.0
                 
*
**/
@isTest(seeAllData = false)
private class Test_SandboxCreateAndRefreshManager 
{
    @testSetup static void testSetupData()
    {
        Util.BypassAllTriggers = true;
        Account acct = TestUtilities.CreateNewAccount(true);
        Account acc = TestUtilities.CreateNewAccount(true);
        List<Create_Sandbox_Request__c> sandboxRefreshDetails = new List<Create_Sandbox_Request__c>();
        sandboxRefreshDetails.add(new Create_Sandbox_Request__c(Sandbox_Name__c = 'TestOnly',
                                                                 Sandbox_Description__c = 'TestDes',
                                                                 Selected_Account__c = acct.Id,
                                                                 Auto_Activate__c = false));
        insert sandboxRefreshDetails;
        
        //Modified By - Abhinav Sharma - CR-20200728-14372 - 9/16/2020 - Added the functionality on the basis of multiple Memnership Key Contact
       	acct.Research_Strategic_Leader__c = UserInfo.getUserId();
        update acct;
        
        Contact cont = TestUtilities.CreateNewContact(acct, true);
        
        List<Site_User__c> siteUsers = new List<Site_User__c>();
        siteUsers.add(new Site_User__c());
        insert siteUsers;
        
        List<Site_Profile__c> siteProfiles = new List<Site_Profile__c>();
        siteProfiles.add(new Site_Profile__c(Contact__c = cont.Id, r_Institution__c = acct.Id, Type__c = 'EAB.com', 
                                             Username__c = cont.Email, Site_User__c = siteUsers[0].Id));
        insert siteProfiles;
        
       
        //End here
        
        Util.BypassAllTriggers = false;
    }
    
    static testMethod void test_SandboxRefRecords()
    { 
        String acctIcon = 'standard:account';
        List<Create_Sandbox_Request__c> listOfSandboxDetails = [SELECT Id, Sandbox_Name__c, Sandbox_Description__c, 
                                                                Selected_Account__c, Auto_Activate__c
                                                                FROM Create_Sandbox_Request__c];
        System.assertEquals(1,listOfSandboxDetails.size());
        
        List<String> acctsIds = new List<String>();
        acctsIds.add('\''+listOfSandboxDetails[0].Selected_Account__c+'\'');
        
        //Start test from here
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(listOfSandboxDetails[0].Id));
        ApexPages.StandardController sc = new ApexPages.standardController(listOfSandboxDetails[0]);
        SandboxCreateAndRefreshManager controller = new SandboxCreateAndRefreshManager(sc);
        PageReference responsePageAction = controller.createAndRefreshSandboxPageAction();
        
    	Boolean getPermission = SandboxCreateAndRefreshManager.getCompVisibility();

        List<Create_Sandbox_Request__c> listOfSB = SandboxCreateAndRefreshManager.createRecordSandboxRefreshDetails(listOfSandboxDetails[0].Sandbox_Name__c,listOfSandboxDetails[0].Sandbox_Description__c,
                                                                         											  acctsIds,listOfSandboxDetails[0].Auto_Activate__c);
        System.assertEquals(1,listOfSB.size());
        
        // Modify by Rajeev Jain - 07/06/2020 - CR-20200728-14372 (RunAllTest Bug Fix)
        List<SandboxCreateAndRefreshManager.LookupSearchResult> sBresult = SandboxCreateAndRefreshManager.doSearchRecords('TestH',acctsIds,'Account','Name','Phone',1,acctIcon,Null);  
		System.assertEquals(1, sBresult.size());
        
        //Modified by- Abhinav Sharma - CR-20200728-14372 - 09/15/2020 - Added test data for the Institution and Contact for Assigning site content recommendation
        List<SandboxCreateAndRefreshManager.LookupSearchResult> contactSearchResult = SandboxCreateAndRefreshManager.doSearchRecords('Joe',acctsIds,'Contact','Name','EAB_com_Site_Profile__c, Account.Name',
                                                                                                                              1,acctIcon, 'Name != null');
        System.assertEquals(1, contactSearchResult.size());
        
        //End here 
        
        //Set Mock callout
        MockHTTPResponseGenerator mHRG = new MockHTTPResponseGenerator();
        mHRG.responseNumber = 1;
        Test.setMock(HttpCalloutMock.class, mHRG);
        
        //Making a callout to create a new sandbox
        SandboxCreateWrapper sCW = new SandboxCreateWrapper();
        sCW.cSRequest.Id = listOfSandboxDetails[0].Id;
		SandboxCreateAndRefreshManager sBCR = new SandboxCreateAndRefreshManager();
        SandboxCreateWrapper sCWrap = sBCR.createAndRefreshSandbox(sCW,null,null,true);
        
        List<SandboxCreateWrapper> listOfSBCreateWrap = new List<SandboxCreateWrapper>();
        listOfSBCreateWrap.add(sCWrap);
        
        //Set Mock callout
        MockHTTPResponseGenerator mHttpRG = new MockHTTPResponseGenerator();
        mHRG.responseNumber = 2;
        Test.setMock(HttpCalloutMock.class, mHttpRG);
        
        /*HTTPCalloutUtilities.setOfSandboxInfoIds(listOfSBCreateWrap);
        Queuable_BatchSBCreateRequestProcess que = new Queuable_BatchSBCreateRequestProcess(listOfSBCreateWrap);
        que.execute(null);*/
        
        
        //Stop Test here
      	Test.stopTest();
    }
    
    static testMethod void test_NegCaseSBRecords()
    {
        String recordId = null;
        List<Account> accounts = [SELECT Id FROM Account];
        ApexPages.currentPage().getParameters().put('id', String.valueOf(accounts[0].Id));
        String recordIdCSR = ApexPages.CurrentPage().getparameters().get('id');

        Test.startTest();
       	try
        {
            SandboxCreateAndRefreshManager sc= new SandboxCreateAndRefreshManager();
            sc.createAndRefreshSandboxPageAction();
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.Valid_Record_Id) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    static testMethod void test_NegSBCRequest()
    {
        Test.startTest();
        try
        {
            SandboxCreateAndRefreshManager sc= new SandboxCreateAndRefreshManager();
            sc.createAndRefreshSandboxPageAction();
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.No_Sandbox_Create_Request_Record_Exists) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();

    }
}