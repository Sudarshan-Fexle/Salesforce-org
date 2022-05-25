/**
 * Desription      :   	Created test class with name Test_DashboardHelper
 * 
 * Created By      :   	
 * 
 * Created Date    :   	
 * 
 * Revision Logs   :   	V1.0 - Created
 * 		   :	V1.1 - Modified By - Shalu Sharma - 31/08/2021 - CR-20210827-15386 - Salesforce Platform API Versions 21.0 through 30.0 Retirement (Update "services/Soap/u/22.0" to "services/Soap/u/52.0")
 *                 :	V1.2 - Modified by - Prateek Pan - 30/09/2021 increase SessionHelper class coverage
 **/
@isTest
private class Test_DashboardHelper {
    
    //random dashboard id - not real, only used for testing purposes.
    private static string dashboardId = '01ZC0000000nixbMAA';
    
    /**
     * @description: verify that the session and server url are retreived via callout
     **/
    static testMethod void testSessionLogin_Success() {
        Test.setMock(HttpCalloutMock.class, new apiMock(mockLoginResponse, 200));
        SessionHelper helper = new SessionHelper();
        system.assertNotEquals(null, helper.SessionId);
        system.assertNotEquals(null, helper.ServerURL);
    }
    
    /**
     * @description: verify that an exception is returned when response code is 401 (unauthorized)
     **/
    static testMethod void testSessionLogin_Fail() {
        Test.setMock(HttpCalloutMock.class, new apiMock(mockLoginResponse_Fail, 500));
        SessionHelper helper = new SessionHelper();
        helper.resBody = mockLoginResponse_Fail;
        helper.getErrors();
    }
    
    
    /**
     * @description: simulate a dashboard refresh and copy
     **/
    @isTest(seeAllData=true)
    static void testDashboardHelper_copyDashboard() {
        //query for a real dashboard
        dashboardId = [SELECT Id FROM Dashboard WHERE Id NOT IN :DashboardHelper.sharedDashboardMap.keySet() LIMIT 1].Id;
        //refresh dashboard
        Test.setMock(HttpCalloutMock.class, new apiMock(mockRefreshResponse, 200));
        DashboardHelper dh = new DashboardHelper();
        dh.dashboardId = dashboardId;
        dh.doRefresh(dashboardId);
        //copy the dashboard html
        Test.setMock(HttpCalloutMock.class, new apiMock(mockGetDashboardHTMLResponse, 200));
        dh.createDashboardHTMLDocument();
        list<Document> documents = [SELECT Id FROM Document WHERE Name = :dashboardId + '.html'];
        system.assertEquals(0, documents.size());
        //copy the dashboard components - this inserts the component images and dashboard html
        dh.copyImages();
        documents = [SELECT Id FROM Document WHERE Name = :dashboardId + '.html'];
        system.assertEquals(1, documents.size(), 'The dashboard\'s html document was not generated.');
        
        //get the dashboard component image documents
        list<Document> imageDocs = [SELECT Id FROM Document WHERE Name IN :dh.attachmentNames];
        system.assertEquals(dh.attachmentNames.size(), imageDocs.size(), 'There should be a document for each dashboard component.');
    }
    
    /**
     * @description: create a shared dashboard record, execute the refresh batch job
     **/
    @isTest(seeAllData=true)
    static void testBatchRefreshDashboards() {
        Test.setMock(HttpCalloutMock.class, new apiMock(mockLoginResponse, 200));
        dashboardId = [SELECT id FROM Dashboard LIMIT 1].Id;
        //delete any existing shared dashboard records
        delete Shared_Dashboard__c.getall().values();
        //create a share dashboard record
        Shared_Dashboard__c sd = new Shared_Dashboard__c(name = dashboardId,
                                                        Is_Shared__c = true);
        insert sd;
        
        test.startTest();
        System.schedule('Batch_RefreshDashboards_Test', '0 0 3 * * ?', new Batch_RefreshDashboards() );
        database.executeBatch(new Batch_RefreshDashboards(), 1);
        test.stopTest();
    }
    
    /**
     * @description: create a shared dashboard record, execute the job to copy dashboard/component info and store them as documents
     **/
    @isTest(seeAllData=true)
    static void testBatchCopyDashboards() {
        Test.setMock(HttpCalloutMock.class, new apiMock(mockLoginResponse, 200));
        dashboardId = [SELECT id FROM Dashboard LIMIT 1].Id;
        //delete any existing shared dashboard records
        delete Shared_Dashboard__c.getall().values();
        //create a share dashboard record
        Shared_Dashboard__c sd = new Shared_Dashboard__c(name = dashboardId,
                                                        Is_Shared__c = true);
        insert sd;
        
        test.startTest();
        database.executeBatch(new Batch_CopyDashboards(), 1);
        test.stopTest();
        
        list<Document> documents = [SELECT Id FROM Document WHERE Name = :dashboardId + '.html'];
        system.assertEquals(1, documents.size(), 'The dashboard\'s html document was not generated.');
    }
    
    /**
     * @description: simulate what happens when a user shares a dashboard
     **/
    static testMethod void testDashboardQuickAction_ShareDashboard() {
        //set the page reference
        PageReference pageRef = Page.DashboardQuickAction;
        //add dashboard and sharedBy ids
        pageRef.getParameters().put('id', dashboardId);
        test.setCurrentPage(pageRef);
        
        //instantiate the controller and set the page
        DashboardQuickActionController controller = new DashboardQuickActionController();
        
        test.startTest();
        controller.toggleShareDashboard();
        test.stopTest();
        
        DashboardHelper.sharedDashboardMap = null;
        system.assertEquals(1, DashboardHelper.sharedDashboardMap.size());
        system.assertEquals(true, controller.isShared);
    }
    
    /**
     * 
     * @description: simulate what happens when a user removes sharing from a dashboard
     * 
     **/
    static testMethod void testDashboardQuickAction_Remove_Sharing() {
        Shared_Dashboard__c sd = new Shared_Dashboard__c(name = dashboardId,
                                                        Is_Shared__c = true);
        insert sd;
        
        //set the page reference
        PageReference pageRef = Page.DashboardQuickAction;
        //add dashboard and sharedBy ids
        pageRef.getParameters().put('id', dashboardId);
        test.setCurrentPage(pageRef);
        
        //instantiate the controller and set the page
        DashboardQuickActionController controller = new DashboardQuickActionController();
        
        test.startTest();
        controller.toggleShareDashboard();
        test.stopTest();
        
        DashboardHelper.sharedDashboardMap = null;
        system.assertEquals(1, DashboardHelper.sharedDashboardMap.size());
        system.assertEquals(false, controller.isShared);
    }
    
    /**
     * @description: mock class to test http callouts
     **/
    public class apiMock implements HttpCalloutMock {
        private String testResponse;
        private Integer testStatusCode;

        public apiMock(String testResponse, Integer testStatusCode){
            this.testResponse = testResponse;
            this.testStatusCode = testStatusCode;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody(testResponse);
            res.setStatusCode(testStatusCode);
            return res;
        }
    }
    
    /**
     * @description: example of a successful login response
     **/
    //Modified By - Shalu Sharma - 31/08/2021 - CR-20210827-15386 - Salesforce Platform API Versions 21.0 through 30.0 Retirement (Update "services/Soap/u/22.0" to "services/Soap/u/52.0")
    private static String mockLoginResponse =
        '<?xml version="1.0" encoding="UTF-8"?>' +
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="urn:partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
        '<soapenv:Body>' +
            '<loginResponse>' +
                '<result>' +
                    '<metadataServerUrl>https://advisory--Dev1.cs7.my.salesforce.com/services/Soap/m/22.0/00DM0000001f657</metadataServerUrl>' +
                    '<passwordExpired>false</passwordExpired>' +
                    '<sandbox>true</sandbox>' +
                    '<serverUrl>https://advisory--Dev1.cs7.my.salesforce.com/services/Soap/u/52.0/00DM0000001f657</serverUrl>' +
                    '<sessionId>00DM0000001f657!ARMAQKVd43tVQmIWPcZcV7xOr4WgrjQhG.ULvIWEM1UKNKAupM0CIXJaIGnzo1fyKqjwbD8_H5PKuKVMIkAxAN.O8m9l_wDG</sessionId>' +
                    '<userId>005C0000003wpb1IAA</userId>' +
                    '<userInfo>' +
                        '<accessibilityMode>false</accessibilityMode>' +
                        '<currencySymbol xsi:nil="true"/>' +
                        '<orgAttachmentFileSizeLimit>15728640</orgAttachmentFileSizeLimit>' +
                        '<orgDefaultCurrencyIsoCode xsi:nil="true"/>' +
                        '<orgDisallowHtmlAttachments>false</orgDisallowHtmlAttachments>' +
                        '<orgHasPersonAccounts>false</orgHasPersonAccounts>' +
                        '<organizationId>00DM0000001f657MAA</organizationId>' +
                        '<organizationMultiCurrency>true</organizationMultiCurrency>' +
                        '<organizationName>The Advisory Board Company</organizationName>' +
                        '<profileId>00eC0000001CQdyIAG</profileId>' +
                        '<roleId>00EC0000001ADdVMAW</roleId>' +
                        '<sessionSecondsValid>3600</sessionSecondsValid>' +
                        '<userDefaultCurrencyIsoCode>USD</userDefaultCurrencyIsoCode>' +
                        '<userEmail>hansonv@advisory.com</userEmail>' +
                        '<userFullName>IS Salesforce Automation</userFullName>' +
                        '<userId>005C0000003wpb1IAA</userId>' +
                        '<userLanguage>en_US</userLanguage>' +
                        '<userLocale>en_US</userLocale>' +
                        '<userName>indigo@advisory.com.abc.dev1</userName>' +
                        '<userTimeZone>America/New_York</userTimeZone>' +
                        '<userType>Standard</userType>' +
                        '<userUiSkin>Theme3</userUiSkin>' +
                    '</userInfo>' +
                '</result>' +
            '</loginResponse>' +
        '</soapenv:Body>' +
        '</soapenv:Envelope>';

    private static String mockLoginResponse_Fail =
        '<?xml version="1.0" encoding="UTF-8"?>' +
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sf="urn:fault.partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
        '<soapenv:Body>' +
            '<soapenv:Fault>' +
                '<faultcode>INVALID_LOGIN</faultcode>' +
                '<faultstring>INVALID_LOGIN: Invalid username, password, security token; or user locked out.</faultstring>' +
                '<detail>' +
                    '<sf:LoginFault xsi:type="sf:LoginFault">' +
                        '<sf:exceptionCode>INVALID_LOGIN</sf:exceptionCode>' +
                        '<sf:exceptionMessage>Invalid username, password, security token; or user locked out.</sf:exceptionMessage>' +
                    '</sf:LoginFault>' +
                '</detail>' +
            '</soapenv:Fault>' +
        '</soapenv:Body>' +
        '</soapenv:Envelope>';

    //Modified By - Shalu Sharma - 31/08/2021 - CR-20210827-15386 - Salesforce Platform API Versions 21.0 through 30.0 Retirement (Update "services/Soap/u/22.0" to "services/Soap/u/52.0")
    private static String mockRefreshResponse =
        '<?xml version="1.0" encoding="UTF-8"?>' +
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="urn:partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
        '<soapenv:Body>' +
            '<loginResponse>' +
                '<result>' +
                    '<metadataServerUrl>https://advisory.my.salesforce.com/services/Soap/m/22.0/00DC0000000QHC4</metadataServerUrl>' +
                    '<passwordExpired>false</passwordExpired>' +
                    '<sandbox>false</sandbox>' +
                    '<serverUrl>https://advisory.my.salesforce.com/services/Soap/u/52.0/00DC0000000QHC4</serverUrl>' +
                    '<sessionId>00DC0000000QHC4!ARcAQOnjMbGIVG0LDza88cOHyJuG.qXETnxGs.hoprwIX9gWitWSNq6MSo1bofrQG_2ohOWzT.CjCdrgnzvEW17Cio9txV3F</sessionId>' +
                    '<userId>005C0000003xxEsIAI</userId>' +
                    '<userInfo>' +
                        '<accessibilityMode>false</accessibilityMode>' +
                        '<currencySymbol xsi:nil="true"/>' +
                        '<orgAttachmentFileSizeLimit>15728640</orgAttachmentFileSizeLimit>' +
                        '<orgDefaultCurrencyIsoCode xsi:nil="true"/>' +
                        '<orgDisallowHtmlAttachments>false</orgDisallowHtmlAttachments>' +
                        '<orgHasPersonAccounts>false</orgHasPersonAccounts>' +
                        '<organizationId>00DC0000000QHC4MAO</organizationId>' +
                        '<organizationMultiCurrency>true</organizationMultiCurrency>' +
                        '<organizationName>The Advisory Board Company</organizationName>' +
                        '<profileId>00eC0000001CSxsIAG</profileId>' +
                        '<roleId>00EC0000001ADeyMAG</roleId>' +
                        '<sessionSecondsValid>3600</sessionSecondsValid>' +
                        '<userDefaultCurrencyIsoCode>USD</userDefaultCurrencyIsoCode>' +
                        '<userEmail>hansonv@advisory.com</userEmail>' +
                        '<userFullName>Victor Hanson</userFullName>' +
                        '<userId>005C0000003xxEsIAI</userId>' +
                        '<userLanguage>en_US</userLanguage>' +
                        '<userLocale>en_US</userLocale>' +
                        '<userName>hansonv@advisory.com.abc</userName>' +
                        '<userTimeZone>America/New_York</userTimeZone>' +
                        '<userType>Standard</userType>' +
                        '<userUiSkin>Theme3</userUiSkin>' +
                    '</userInfo>' +
                '</result>' +
            '</loginResponse>' +
        '</soapenv:Body>' +
        '</soapenv:Envelope>';
    
    private static String mockGetDashboardHTMLResponse =
        '<!DOCTYPE html>' +
        '<html>' +
            '<script>' +
                'alert("test");' +
            '</script>' +
            '<body>' +
                'test dashboard html' +
            '</body>' +
        '</html>';
    
}