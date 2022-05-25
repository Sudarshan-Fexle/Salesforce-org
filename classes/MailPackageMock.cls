/**
*  Description     :    mocking class for MailPackages 
*
*  Created By      :    Subhash Garhwal
*
*  Created Date    :    07/22/2021   
* 
*  Revision Logs   :    V_1.0 - Created - CR-20210722-15306
*                      
**/
@isTest
global class MailPackageMock implements HttpCalloutMock {
    
    public static final String MOCK_MAILPACKAGE_ID = '123456789';
    public integer responseNumber = 0;
    
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        if(responseNumber == 1)
        {
            String bodyStr = '{"id": "' + MOCK_MAILPACKAGE_ID + '",' + '"attachments" : "NEW|ALL"}';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(bodyStr);
            res.setStatusCode(200);
            return res;
        }
        else{
            
            String bodyStr = '{"id": "' + MOCK_MAILPACKAGE_ID + '"}';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(bodyStr);
            res.setStatusCode(200);
            return res;
        }
        
    }
}