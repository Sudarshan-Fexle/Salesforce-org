@isTest
global class MockHTTPResponseGenerator implements HttpCalloutMock 
{
    public integer responseNumber = 0;
    global HttpResponse respond(HttpRequest req) 
    {   
        if(responseNumber == 1)
        {
            String bodyStr = '{"ApexClassId": "' + System.Label.Post_Sandbox_Refresh_Class_ID + '",' 
                + '{"AutoActivate" : true,' 
                + '"Description": "From tooling API",'
                +'"LicenseType": "DEVELOPER",'
                +'"SandboxName": "STP"'
                +'}';
            HttpResponse res = new HttpResponse();
            res.setBody(bodyStr);
            res.setStatusCode(200);
            return res;
        }
        else if(responseNumber == 2)
        {
            String body = '{"size" : 47,'
              +'"totalSize" : 47,'
              +'"done" : true,'
              +'"queryLocator" : null,'
              +'"entityTypeName" : "SandboxProcess",'
              +'"records" : [{'
       			+'"attributes" : {'
                  +'"type" : "SandboxProcess",'
                  +'"url" : "/services/data/v47.0/tooling/sobjects/SandboxProcess/0GR1C000000fzLhWAI"'
                +'},'
                +'"Id" : "0GR1C000000fzLhWAI",'
                +'"SandboxName" : "POC1",'
                +'"SandboxOrganization" : "00Dc0000003lTtQ",'
                +'"Status" : "Completed"'
              +'}]'
			+'}';
            
            HttpResponse res = new HttpResponse();
            res.setBody(body);
            res.setStatusCode(200);
            return res;    
        }
        else
        {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res; 
        }
    }
}