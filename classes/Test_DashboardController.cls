@isTest
private class Test_DashboardController {
    
    /**
     * 
     * @description: simulate what happens when a user views a dashboard that has been shared
     * 
     **/
    static testMethod void testGetDashboardHTML() {
        
        string dashboardId = '01ZC0000000nixbMAA';
        
        Shared_Dashboard__c sd = new Shared_Dashboard__c(name = dashboardId,
                                                        Is_Shared__c = true);
        insert sd;
        
        //create a fake html document for the dashboard
        Document doc = new Document();
        doc.Name = dashboardId + '.html';
        doc.Type = 'text/html';
        doc.FolderId = UserInfo.getUserId();
        doc.AuthorId = UserInfo.getUserId();
        doc.Body = Blob.valueOf(rawHTML);
        insert doc;
        list<Document> docs = [SELECT body FROM Document WHERE Name = '01ZC0000000nixbMAA.html'];
        system.assertEquals(1, docs.size());
        
        //set the page reference
        PageReference pageRef = Page.DashboardViewer;
        //add dashboard and sharedBy ids
        pageRef.getParameters().put('id', dashboardId);
        pageRef.getParameters().put('ud', userInfo.getUserId());
        test.setCurrentPage(pageRef);
        
        //instantiate the controller and set the page
        DashboardController controller = new DashboardController();
        
        system.assertEquals(userInfo.getUserId(), controller.sharedBy.Id, 'The sharedBy user Id should match the current user because that is what was passed in to the "ud" param.');
        system.assertEquals(dashboardId, controller.dashboardId);
        system.assertEquals(true, controller.isShared, 'The dashboard should be shared due to the Shared_Dashboard__c custom setting value that is set to Is_Shared__c = true.');
        system.assertEquals(0, controller.dashboardComponents.size());
        system.assertEquals(0, controller.componentIdToDocMap.size());
        system.assertEquals(parsedHTML + controller.getDashboardHtmlAdditions(), controller.getDashHTML());
    }
    
    /**
     * 
     * @description: simulate what happens when a user attempts to view a dashboard that is no longer shared
     * 
     **/
    static testMethod void testGetDashboardHTML_Error() {
        
        string dashboardId = '01ZC0000000nixbMAA';
        
        Shared_Dashboard__c sd = new Shared_Dashboard__c(name = dashboardId,
                                                        Is_Shared__c = false);
        insert sd;
        
        //create a fake html document for the dashboard
        Document doc = new Document();
        doc.Name = dashboardId + '.html';
        doc.Type = 'text/html';
        doc.FolderId = UserInfo.getUserId();
        doc.AuthorId = UserInfo.getUserId();
        doc.Body = Blob.valueOf(rawHTML);
        insert doc;
        list<Document> docs = [SELECT body FROM Document WHERE Name = '01ZC0000000nixbMAA.html'];
        system.assertEquals(1, docs.size());
        
        //set the page reference
        PageReference pageRef = Page.DashboardViewer;
        //add dashboard and sharedBy ids
        pageRef.getParameters().put('id', dashboardId);
        pageRef.getParameters().put('ud', userInfo.getUserId());
        test.setCurrentPage(pageRef);
        
        //instantiate the controller and set the page
        DashboardController controller = new DashboardController();
        
        system.assertEquals(userInfo.getUserId(), controller.sharedBy.Id, 'The sharedBy user Id should match the current user because that is what was passed in to the "ud" param.');
        system.assertEquals(dashboardId, controller.dashboardId);
        system.assertEquals(false, controller.isShared, 'The dashboard should not be shared due to the Shared_Dashboard__c custom setting value that is set to Is_Shared__c = false.');
    }
    
    public static string rawHTML = '<html>' +
                                    '<script>' +
                                        'alert("TEST");' +
                                    '</script>' +
                                    'Test' +
                                    '</html>';
    
    public static string parsedHTML = '<html>' +
                                        'Test' +
                                    '</html>';
}