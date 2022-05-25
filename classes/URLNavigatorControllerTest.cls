@isTest(seeAllData = false)
public class URLNavigatorControllerTest {  
    
    @testSetUp static void testSetupData()
    {
        // Create an Account
        Account acc = TestUtilities.CreateNewAccount(true);
        
        Contact con = new Contact();
        
        con.LastName = 'Test';
        con.Email = 'Test@test.com';
        con.Email = 'Test'+Math.random()+'@eab.com';
        con.Title = 'Test';
        con.Phone = '614-555-8855';
        
        insert con;
    }
    
    static testMethod void testBack() 
    {      
        Test.StartTest(); 
        
        //Setting page paramters
        Test.setCurrentPageReference(new PageReference('Page.URLNavigator'));
        System.currentPageReference().getParameters().put('operationtype', 'BACK' );
        System.currentPageReference().getParameters().put('retURL', 'https://eab--full2.cs40.my.salesforce.com' );
        System.currentPageReference().getParameters().put('refresh', 'True' );
        URLNavigatorController navController = new URLNavigatorController();
        navController.redirect();
        
        Test.StopTest();
        
        String operationtype = ApexPages.currentPage().getParameters().get('operationtype');
        system.assertEquals('BACK', operationtype);
        
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        system.assertEquals('https://eab--full2.cs40.my.salesforce.com', retURL);
        
        Boolean refresh = Boolean.valueOf(ApexPages.currentPage().getParameters().get('refresh'));
        system.assertEquals(true, refresh);
    }
    
    static testMethod void testNAVIGATETOSOBJECT()
    {
        Account acct = [SELECT Id FROM Account LIMIT 1];
        system.assert(acct != null);
        Test.StartTest(); 
        
        //Setting page paramters
        Test.setCurrentPageReference(new PageReference('Page.URLNavigator'));
        System.currentPageReference().getParameters().put('operationtype', 'NAVIGATETOSOBJECT' );
        System.currentPageReference().getParameters().put('recordId', acct.Id);
        URLNavigatorController navController = new URLNavigatorController();
        navController.redirect();
        
        Test.StopTest();
        
        String operationtype = ApexPages.currentPage().getParameters().get('operationtype');
        system.assertEquals('NAVIGATETOSOBJECT', operationtype);
        
        Boolean recordId = Boolean.valueOf(ApexPages.currentPage().getParameters().get('recordId'));
        system.assertEquals(true, recordId != null);
    }
    
    static testMethod void testNAVIGATETOURL()
    {
        Test.StartTest(); 
        
        //Setting page paramters
        Test.setCurrentPageReference(new PageReference('Page.URLNavigator'));
        System.currentPageReference().getParameters().put('operationtype', 'NAVIGATETOURL' );
        System.currentPageReference().getParameters().put('url', 'https://eab--full2.cs40.my.salesforce.com');
        System.currentPageReference().getParameters().put('isredirect', 'true');
        URLNavigatorController navController = new URLNavigatorController();
        navController.redirect();
        
        Test.StopTest();
        
        String operationtype = ApexPages.currentPage().getParameters().get('operationtype');
        system.assertEquals('NAVIGATETOURL', operationtype);
        
        String url = ApexPages.currentPage().getParameters().get('url');
        system.assertEquals('https://eab--full2.cs40.my.salesforce.com', url);
        
        Boolean isredirect = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isredirect'));
        System.assertEquals(true, isredirect);
    }
    
    static testMethod void testNAVIGATETOFEED()
    {
        Test.StartTest(); 
        
        //Setting page paramters
        Test.setCurrentPageReference(new PageReference('Page.URLNavigator'));
        System.currentPageReference().getParameters().put('operationtype', 'NAVIGATETOFEED' );
        URLNavigatorController navController = new URLNavigatorController();
        navController.redirect();
        
        Test.StopTest();
        
        String operationtype = ApexPages.currentPage().getParameters().get('operationtype');
        system.assertEquals('NAVIGATETOFEED', operationtype);
    }
    
    static testMethod void testNAVIGATETOFEEDITEMDETAIL()
    {
        Account acct = [SELECT Id FROM Account LIMIT 1];
        system.assert(acct != null);
        Test.StartTest(); 
        
        //Setting page paramters
        Test.setCurrentPageReference(new PageReference('Page.URLNavigator'));
        System.currentPageReference().getParameters().put('operationtype', 'NAVIGATETOFEEDITEMDETAIL' );
        System.currentPageReference().getParameters().put('feedItemId', acct.Id);
        URLNavigatorController navController = new URLNavigatorController();
        navController.redirect();
        
        Test.StopTest();
        
        String operationtype = ApexPages.currentPage().getParameters().get('operationtype');
        system.assertEquals('NAVIGATETOFEEDITEMDETAIL', operationtype);
        
        Boolean feedItemId = Boolean.valueOf(ApexPages.currentPage().getParameters().get('feedItemId'));
        system.assertEquals(true, feedItemId != null);
    }
    
    static testMethod void testNAVIGATETORELATEDLIST()
    {
        Account acct = [SELECT Id FROM Account LIMIT 1];
        system.assert(acct != null);
        // Create a Contact
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        System.assert(con != null);
        Test.StartTest(); 
        
        //Setting page paramters
        Test.setCurrentPageReference(new PageReference('Page.URLNavigator'));
        System.currentPageReference().getParameters().put('operationtype', 'NAVIGATETORELATEDLIST' );
        System.currentPageReference().getParameters().put('parentRecordId', acct.Id);
        System.currentPageReference().getParameters().put('relatedListId', con.Id);
        URLNavigatorController navController = new URLNavigatorController();
        navController.redirect();
        
        Test.StopTest();
        
        String operationtype = ApexPages.currentPage().getParameters().get('operationtype');
        system.assertEquals('NAVIGATETORELATEDLIST', operationtype);
        
        Boolean parentRecordId = Boolean.valueOf(ApexPages.currentPage().getParameters().get('parentRecordId'));
        system.assertEquals(true, parentRecordId != null);
        
        Boolean relatedListId = Boolean.valueOf(ApexPages.currentPage().getParameters().get('relatedListId'));
        system.assertEquals(true, relatedListId != null);
    }
    
    static testMethod void testNAVIGATETOLIST()
    {
        String ListViewId;
        String SOQLQuery = 'SELECT Name FROM Account LIMIT 1';
        ApexPages.StandardSetController acc = new ApexPages.StandardSetController(Database.getQueryLocator(SOQLQuery));
        List<SelectOption> ListViews = acc.getListViewOptions();
        for(SelectOption w : ListViews ){
            ListViewId = w.getValue().left(15);
        }
        
        System.assert(ListViewId != null);
        Test.StartTest(); 
        
        //Setting page paramters
        Test.setCurrentPageReference(new PageReference('Page.URLNavigator'));
        System.currentPageReference().getParameters().put('operationtype', 'NAVIGATETOLIST' );
        System.currentPageReference().getParameters().put('scope', 'Account');
        System.currentPageReference().getParameters().put('listViewId', ListViewId);
		URLNavigatorController navController = new URLNavigatorController();
        navController.redirect();
        
        Test.StopTest();
        
        String operationtype = ApexPages.currentPage().getParameters().get('operationtype');
        system.assertEquals('NAVIGATETOLIST', operationtype);
        
        String scope = ApexPages.currentPage().getParameters().get('scope');
        system.assertEquals('Account', scope);
        
        Boolean chklistViewId = Boolean.valueOf(ApexPages.currentPage().getParameters().get('listViewId'));
        system.assertEquals(true, chklistViewId != null);
    }
 	
    static testMethod void testCREATERECORD()
    {
        List<String> fields = new List<String>{'Name', 'Phone', 'Email'};
        System.assert(fields.size() > 0);
        Test.StartTest(); 
        
        //Setting page paramters
        Test.setCurrentPageReference(new PageReference('Page.URLNavigator'));
        System.currentPageReference().getParameters().put('operationtype', 'CREATERECORD' );
        System.currentPageReference().getParameters().put('classicfieldsid', JSON.serialize(fields)); 
        System.currentPageReference().getParameters().put('entityName', 'Account');
        System.currentPageReference().getParameters().put('recordTypeId', 'Account');
        System.currentPageReference().getParameters().put('defaults', 'Test');
        URLNavigatorController navController = new URLNavigatorController();
        navController.redirect();
        
        Test.StopTest();
        
        String operationtype = ApexPages.currentPage().getParameters().get('operationtype');
        system.assertEquals('CREATERECORD', operationtype);
        
        List<String> classicfieldsid = (List<String>)JSON.deserialize(ApexPages.currentPage().getParameters().get('classicfieldsid'), List<String>.class);
        system.assertEquals(3, classicfieldsid.size());
    }
    
    static testMethod void testEDITRECORD()
    {
        Account acct = [SELECT Id FROM Account LIMIT 1];
        system.assert(acct != null);
        Test.StartTest();
        
        //Setting page paramters
        Test.setCurrentPageReference(new PageReference('Page.URLNavigator'));
        System.currentPageReference().getParameters().put('operationtype', 'EDITRECORD' );
        System.currentPageReference().getParameters().put('recordId', acct.Id);
        URLNavigatorController navController = new URLNavigatorController();
        navController.redirect();
        
        Test.StopTest();
        
        String operationtype = ApexPages.currentPage().getParameters().get('operationtype');
        system.assertEquals('EDITRECORD', operationtype);
        
        Boolean recordId = Boolean.valueOf(ApexPages.currentPage().getParameters().get('recordId'));
        system.assertEquals(true, recordId != null);
    }
}