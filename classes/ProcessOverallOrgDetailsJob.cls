/**
*  Purpose      :   Queueable Job class to process and retrieve overall org coverage related details
*  Created By   :   Abhinav Sharma
**/
public with sharing class ProcessOverallOrgDetailsJob implements Queueable, Database.AllowsCallouts 
{
    public RunAllTestsResultsWrapper sEW;
    public ProcessOverallOrgDetailsJob(RunAllTestsResultsWrapper sEW) 
    {
        this.sEW = sEW;    
    }
    public void execute(QueueableContext context)
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + System.Label.OverallOrgCoverageDetails);
        req.setMethod(Constants.HTTP_REQUEST_GET_TYPE); 
        req.setHeader(Constants.CONTENT_TYPE, Constants.CONTENT_TYPE_APP_JSON);
        req.setHeader(Constants.AUTHORIZATION, Constants.BEARER + Constants.CHAR_BLANK_SPACE + UserInfo.getSessionID());
        Http httpreq = new Http();
        HttpResponse res = httpreq.send(req);
        
        OverallOrgCodeCoverageDetailsWrapper overallOrgRelatedDetails = (OverallOrgCodeCoverageDetailsWrapper)JSON.deserialize(res.getBody(), OverallOrgCodeCoverageDetailsWrapper.class);
        
        if(overallOrgRelatedDetails != null) 
        {
            if(overallOrgRelatedDetails.records != null && overallOrgRelatedDetails.records.size() > 0) 
            {
                sEW.emailBodyOverallCodeCoverageDetails += 'Total Coverage (%) ' + Constants.CHAR_COMMA + overallOrgRelatedDetails.records[0].PercentCovered + Constants.CHAR_NEW_LINE;
            }
            
            // Chain this job to get apex classes wise code coverage details and send email with all the files
            if(!Test.isRunningTest()) {
            System.enqueueJob(new ProcessApexClassesWiseDetailsJob(sEW));
            }
        }
    }
}