/**
*  Description     :   This call will create a new slack post
* 
*  Revision Logs   :   V1.0 - 09/22/2020 - CR-20200731-14394 - Victor Hanson - Created
*		       V1.1 - 10/19/2020 - CR-20201012-14597 - updated postSlack method
* 
**/
public class PostToSlackAction {
    
    /**
     *  Purpose         :	Loop through each request and post to slack
     *
     *  Revision Logs   :	V_1.0 - 09/22/2020 - CR-20200731-14394 - Victor Hanson - Created
     *                     
    **/
    @InvocableMethod(label='Post to Slack')
    public static void postToSlack(List<PostToSlackActionRequest> requests) {
        if (!System.isFuture() && !System.isQueueable()) {
            for (PostToSlackActionRequest request : requests) {
                postSlack(JSON.serialize(request));
            }
        }
    }
    
    /**
     *  Purpose         :	Send an alert to Slack Channel
     *
     *  Revision Logs   :	V_1.0 - 09/22/2020 - CR-20200731-14394 - Victor Hanson - Created
     * 				V_1.1 - 10/19/2020 - CR-20201012-14597 - updated to post to either production or sandbox slack channel
     *                     
    **/
    @future (callout=true)
    public static void postSlack(String jsonReq) {
        
        //convert json to object
        PostToSlackActionRequest request = (PostToSlackActionRequest)JSON.deserialize(jsonReq, PostToSlackActionRequest.class);
        
        //holds the custom metadata type with the slack details
        Slack_Callouts__mdt slackSandboxCallout;
        
        //10/19/2020 - CR-20201012-14597 - added to post to either production or sandbox slack channel
        String slackCalloutMetadataDevName = request.slackCalloutMetadataName;
        if (SessionHelper.isSandbox()) {
            slackCalloutMetadataDevName = 'Production_Tracking_Error_Sandbox';
        }
        
        //10/19/2020 - CR-20201012-14597 - updated with slackCalloutMetadataDevName
        //Query for our Slack Callout Details
        List<Slack_Callouts__mdt> slackSandboxCallouts = [SELECT Label, DeveloperName, API_Method__c, Image_URL__c, Slack_Channel__c, Slack_Token__c
                                                   	  FROM Slack_Callouts__mdt
                                                          WHERE DeveloperName = :slackCalloutMetadataDevName];
        
        //make sure a callout was returned, otherwise throw an error
        if (slackSandboxCallouts.size() > 0)
            slackSandboxCallout = slackSandboxCallouts[0];
        else
            Throw new customException('No Slack Callout with DeveloperName \'' + request.slackCalloutMetadataName + '\'');
        
        //Build our JSON for the callout
        Map<String, String> slackCalloutData = new Map<String, String>();
        slackCalloutData.put('channel', slackSandboxCallout.Slack_Channel__c);
        String formattedMessage = request.message
            .replaceAll('<br>','\n')
            .replaceAll('</p><p>','\n')
            .replaceAll('<p>',' ')
            .replaceAll('</p>',' ')
            .replaceAll('<b>',' *')
            .replaceAll('</b>','* ')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>')
            .replaceAll('\\{(url|URL)\\}', URL.getSalesforceBaseUrl().toExternalForm());
        slackCalloutData.put('text', formattedMessage);
        
        //Declare our Http, HttpRequest & Response records
        Http slackHttp = new Http();
        HttpRequest slackCalloutRequest = new HttpRequest();
        HttpResponse slackResponseBody = new HttpResponse();
        
        //Define the specifics needed for the Slack API Method
        slackCalloutRequest.setHeader(Constants.CONTENT_TYPE, Constants.CONTENT_TYPE_APP_JSON);
        slackCalloutRequest.setHeader(Constants.AUTHORIZATION, 'Bearer ' + slackSandboxCallout.Slack_Token__c);
        slackCalloutRequest.setMethod(Constants.HTTP_REQUEST_POST_TYPE);
        slackCalloutRequest.setEndpoint(slackSandboxCallout.API_Method__c);
        slackCalloutRequest.setBody(JSON.serialize(slackCalloutData));
        system.debug('@@:' + JSON.serialize(slackCalloutData));
        if(Test.isRunningTest()){
            return;
        }
        
        //Get our Response Record back
        slackResponseBody = slackHttp.send(slackCalloutRequest);
        
        //If our message fails to send to Slack then send an email to SF Admin account to notify
        if (slackResponseBody.getStatusCode() != 200){
            
            // Create and send an email with the results of the Callout
            String emailBody = 'The callout to Slack failed with the following errors:' + '\n' + 'Status Code: ' + slackResponseBody.getStatusCode() + '\n' + 'Error Body: ' + slackResponseBody.getBody();
            EmailHandler.createEmail(new String[] {'sfadmin@eab.com'}, 'Post to Slack action failed', emailBody, emailBody, true);
        }
    }
    
    public class PostToSlackActionRequest {
        @InvocableVariable(required=true)
        public ID webServiceLogId;
        
        @InvocableVariable(required=true)
        public String slackCalloutMetadataName;
        
        @InvocableVariable(required=true)
        public String message;
        
    }
    
}