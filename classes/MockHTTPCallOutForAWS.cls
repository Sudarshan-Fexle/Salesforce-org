@isTest
global class MockHTTPCallOutForAWS implements HttpCalloutMock {

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        //System.assertEquals('https://' + LOA_Generator_Settings__c.getInstance().Domain_Name__c + '/api/Calculator', req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
    }
}