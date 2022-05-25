/*
Purpose         :   Apex Class for Export Test coverage details (Dynamic Related List)
Created By      :   Abhinav Sharma
Created Date    :   11/11/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 11/11/2021
*/
public without sharing class dynlistExportTestCoverage
{
    public CoverageWrapper cw {get;set;}
    
    public dynlistExportTestCoverage()
    {
        HttpRequest req = new HttpRequest();
        req.setHeader(dynlistConstants.CHAR_AUTHORIZATION, dynlistConstants.CHAR_BEARER + dynlistConstants.CHAR_BLANK_SPACE + UserInfo.getSessionID());
        req.setHeader(dynlistConstants.CHAR_CONTENT_TYPE, dynlistConstants.CHAR_APPLICATION_JSON);
        req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + System.Label.DYNLIST_EXPORT_TEST_ENDPOINT);
        req.setMethod(dynlistConstants.HTTP_GET_METHOD);
        Http h = new Http();
        HttpResponse resp = h.send(req);
        if(resp.getStatusCode() == dynlistConstants.HTTP_CALLOUT_SUCCESS_STATUS_CODE)
        {
            cw  = (CoverageWrapper)JSON.deserialize(resp.getBody(),CoverageWrapper.class);
        }
    }
    
    public class Attributes 
    {
        public String type {get;set;}
        public String url {get;set;}
    }
    
    public class Records 
    {
        public Attributes attributes {get;set;}
        public String Id {get;set;}
        public ApexClassOrTrigger ApexClassOrTrigger {get;set;}
        public Integer NumLinesCovered {get;set;}
        public Integer NumLinesUncovered {get;set;}
    }
    
    public class ApexClassOrTrigger 
    {
        public Attributes attributes {get;set;}
        public String Name{get;set;}
    }
    
    public class CoverageWrapper
    {
        public Integer size {get;set;}
        public Integer totalSize {get;set;}
        public Boolean done {get;set;}
        public Object queryLocator {get;set;}
        public String entityTypeName {get;set;}
        public List<Records> records{get;set;}
    }
}