/*
Purpose         :   Mock class for Tooling API Callouts (Dynamic Related List)
Created By      :   Abhinav Sharma
Created Date    :   08/13/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 08/13/2021
*/
@isTest(seeAllData=false)
global without sharing class dynlistMockHttpResponseGenerator implements HttpCalloutMock 
{
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) 
    {
        String ORG_INSTANCE = dynlistUtilities.getMySalesforceInstance();
        String TOOLINGAPI_ENDPOINT = dynlistConstants.CHAR_HTTPS + ORG_INSTANCE + '.salesforce.com' + System.Label.DYNLIST_TEST_CLASS_TOOLING_API;
        
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assert(req.getEndpoint()!=null);
        System.assertEquals(dynlistConstants.HTTP_GET_METHOD, req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader(dynlistConstants.CHAR_CONTENT_TYPE, dynlistConstants.CHAR_APPLICATION_JSON);
        res.setBody('{"Name":"test"}');
        res.setStatusCode(dynlistConstants.HTTP_CALLOUT_SUCCESS_STATUS_CODE);
        return res;
    }
}