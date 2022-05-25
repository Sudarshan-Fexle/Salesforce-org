/*
Purpose         :   Mock class for HTTP Callouts (Dynamic Related List)
Created By      :   Abhinav Sharma
Created Date    :   08/13/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 08/13/2021
*/
@isTest(seeAllData=false)
global without sharing class dynlistMockHttpCallout implements HttpCalloutMock 
{
    private String[] responses;
    private Integer index = 0;
    
    global dynlistMockHttpCallout() 
    {
        this(new String[]{});
    }
    
    global dynlistMockHttpCallout(String resp) 
    {
        this(new String[]{resp});
    }
    
    global dynlistMockHttpCallout(String resp, String resp2) 
    {
        this(new String[]{resp, resp2});
    }
    
    global dynlistMockHttpCallout(String[] resps) 
    {
        responses = resps;
    }
    
    global HTTPResponse respond(HTTPRequest req) 
    {
        HttpResponse resp = new HttpResponse();
        try
        {
            if(responses != null && index < responses.size()) 
            {
                resp.setBody(responses[index]);
                index++;
            }
        } 
        catch(Exception e) 
        {
            System.debug('Mock failed!');
        }        
        resp.setStatusCode(200);
        return resp;
    }
}