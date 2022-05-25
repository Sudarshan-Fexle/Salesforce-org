/**
*  Description     :    Execute setup steps after sandbox refresh
*                       
*  Created By      :    Victor Hanson
* 
*  Created Date    :    03/21/2018
* 
*  Revision Logs   :    V_1.0 - Created
		   :    V_1.1 - CR-20200313-13851 - Dipesh Gupta
		   :	V_1.2 - Added By - Neha Sharma - 02/03/2021 - CR-20200625-14228 - pass a parameter to check it's going to scramble email for Entity HC or not
**/
global class SandboxSetup implements SandboxPostCopy {
    
    public static final string JOB_TYPE_REPORT_RUN = '8';
    public static final string JOB_TYPE_DASHBOARD_REFRESH = '3';
    public static final string JOB_TYPE_ANALYTICS_NOTIFICATION = 'A';
    
    global void runApexClass(SandboxContext context) {
        
        //1) update user emails to they can login
        updateUserEmails();
        
        //2) Update sitecore settings
        updateSitecoreSettings(context.sandboxName());
        
        //3) start the Email scramble jobs
        startEmailScramble();
        
        //4) Add some basic sandbox data (dev sandboxes only)
        addSandboxData();
        
        //5) Delete scheduled reports
        deleteScheduledReports();
        
        //6) Send Alert to Slack that the Sandbox is ready
        sendAlertToSlack(context.sandboxName());
        //7) Calling method to schedule run all test. 
        scheduleRunAllTest();
    }
    
    /**
     * 
     * @description: Update admin user emails so they can login
     * 
     **/
    private void updateUserEmails() {
        
        //We can add/remove users as applicable to the Group for Resetting Emails for Admins
        List<User> users = [SELECT Id, Email, ProfileId FROM User WHERE Id IN (SELECT UserorGroupId from GroupMember WHERE Group.DeveloperName = :Label.Sandbox_Refresh_Group_Name) AND Name != 'Salesforce Administrator'];
        //System admin Ids 
        String systemAdminId = [Select Id From Profile where Name =: Label.PROFILE_NAME_SYSTEM_ADMINISTRATOR LIMIT 1].Id;
        
        IF (users.size() > 0){
            for ( User u : users ) {
                 u.email = u.email.replace('@example.com', '').replace('=', '@').replace('.invalid', '');
                 u.ProfileId  = systemAdminId;  
            }
               
            update users;       
        }

    }
    
    /**
     * 
     * @description: Update the Sitecore Settings.  has to be a future method to avoid mixed dml
     * 
     **/
    @future
    public static void updateSitecoreSettings(string sandboxName) {
        
        Sitecore_Settings__c siteCoreSettings = Sitecore_Settings__c.getOrgDefaults();
        if(siteCoreSettings == null)
            siteCoreSettings = new Sitecore_Settings__c();
        
        //get the sandbox instance (ie: cs22) 
        String instance = [SELECT InstanceName FROM Organization].InstanceName;
        
        //Set parameters
        siteCoreSettings.EAB_Password_Reset_URL__c = Label.Sandbox_Sitecore_PW_Reset_URL;
        siteCoreSettings.Advisory_Password_Reset_URL__c = siteCoreSettings.EAB_Password_Reset_URL__c;
        siteCoreSettings.AdvAdmin_URL__c = 'http://northpole2.eab.com:8008/Tab1/Index/';
        siteCoreSettings.EAB_com_SF_URL__c = 'http://' + sandboxName + '--eab.' + instance + '.force.com/EABQuery';
        siteCoreSettings.Advisory_com_SF_URL__c = siteCoreSettings.EAB_com_SF_URL__c;
        siteCoreSettings.Encryption_Key__c = null;
        upsert siteCoreSettings;
    }
    
    /**
     * 
     * @description: executes 3 batches to scramble emails on Lead, Contact, and Site Profile
     * 
     **/
    public void startEmailScramble() {
        
        //define a few extra email fields to scramble on contact
        Set<Schema.SObjectField> additionalContactEmailFields = new Set<Schema.SObjectField>();
        additionalContactEmailFields.add(Contact.Asst_Email__c);
        //Added as part of CR-20200313-13851 - Dipesh Gupta
        additionalContactEmailFields.add(Contact.Company_Email__c);
        
        //Modified By - Neha Sharma - 02/03/2021 - CR-20200625-14228 - pass a parameter to check it's going to scramble email for Entity HC or not
        //scramble Contact emails
        database.executeBatch(new ScrambleSObjectEmail(Contact.SObjectType, Contact.Email, additionalContactEmailFields, '@', '@junkEAB', null, false));
        
        //scramble Site Profile emails
        database.executeBatch(new ScrambleSObjectEmail(Site_Profile__c.SObjectType, Site_Profile__c.Username__c, null, '@', '@junkEAB', null, false));
        
        //scramble lead emails
        database.executeBatch(new ScrambleSObjectEmail(Lead.SObjectType, Lead.Email, null, '@', '@junkEAB', null, false));
        
        //End here
    }
    
    /**
     * 
     * @description: add sandbox data
     * 
     **/
    private void addSandboxData() {
        
        //see if this is a dev sandbox
        boolean isDevSandbox = false;
        List<DP_Picklist__c> picklists = [SELECT Id FROM DP_Picklist__c];
        if (picklists.size() == 0) isDevSandbox = true;
        
        //only create additional sandbox data if none exists
        if (isDevSandbox) {
            
            //create test data (Picklists / General Ledgers) (static resource name=SandboxData_Picklists_GenLedgers)
            createTestData('SandboxData_Picklists_GenLedgers');
        }
    }
    
    /**
     * 
     * @description: creates test data based on a static resource file
     * 
     **/
    @future
    public static void createTestData(string staticResourceName) {
        
        StaticResource sr = [select id,body from StaticResource Where Name = :staticResourceName];
        String contents = sr.body.toString();
        
        //VH commented out savepoint temporarily.
        //This will allow some records to be created, even if other records are prevented from insert
        //Savepoint sp = Database.setSavepoint(); //create savepoint
        
        try {
            Util.BypassAllTriggers = true;
            Set<Id> recordAIds =
                SObjectDataLoader.deserialize(contents, new ApplyStandardPricebook());
        }
        catch(Exception e) {
            //rollback on error
            //Database.rollback(sp);
            system.debug('@@:' + e);
        }
    }
    
    /**
    * Test implemetnation of IDeserializeCallback, automatically applies Standard Pricebook to new PricebookEntry's
    **/
    public class ApplyStandardPricebook implements SObjectDataLoader.IDeserializeCallback
    {
        private Pricebook2 standardPricebook;
        
        public ApplyStandardPricebook()
        {
            standardPricebook = [select Id from Pricebook2 where IsStandard = true];                
        }
        
        public void unresolvedReferences(Schema.SObjectType sObjectType, List<SObjectDataLoader.UnresolvedReferences> unresolvedReferences)
        {
            if(sObjectType == PricebookEntry.sObjectType) { // PricebookEntry object?
                for(SObjectDataLoader.UnresolvedReferences unresolvedReference : unresolvedReferences)
                    if(unresolvedReference.References.contains(PricebookEntry.Pricebook2Id)) // Pricebook2Id field?
                    unresolvedReference.Record.put(PricebookEntry.Pricebook2Id, standardPricebook.id); // Set Standard Pricebook
            }
            else {
                
                system.debug('@@sObjectType:' +sObjectType);
                for (SObjectDataLoader.UnresolvedReferences unresolvedReference2 : unresolvedReferences)
                    system.debug('@@unresolvedReference:' +unresolvedReference2);
            }
        }       
    }
    
    /**
    *  Delete scheduled report/dashboard jobs from sandboxes (NOTE: Needs to be a batch job because there are more than 150 jobs to delete)
    **/
    @future
    public static void deleteScheduledReports() {
        list<CronTrigger> jobs = [SELECT Id FROM CronTrigger 
                                  WHERE CronJobDetail.JobType = :JOB_TYPE_REPORT_RUN 
                                  OR CronJobDetail.JobType = :JOB_TYPE_DASHBOARD_REFRESH 
                                  OR CronJobDetail.JobType = :JOB_TYPE_ANALYTICS_NOTIFICATION 
                                  LIMIT 150];
        
        if (jobs.size() > 0) {
            for (CronTrigger job : jobs)
                system.abortJob(job.Id);
        }
    }
    
    /**
    *  Send an alert to Slack Channel to let the team know that the Sandbox process has completed
    **/
    @future (callout=true)
    public static void sendAlertToSlack (string sandboxName) {
        
        
        //Query for our Slack Callout Details
        Slack_Callouts__mdt slackSandboxCallout = [SELECT Label, DeveloperName, API_Method__c, Image_URL__c, Slack_Channel__c, Slack_Token__c
                                                   FROM Slack_Callouts__mdt
                                                   WHERE DeveloperName = 'Sandbox_Refresh_Completed'];
        
        //Let's build our message we need to send to Slack in JSON
        String textAlert = '<!channel>' + ' The Sandbox ' + sandboxName + ' has completed all of the post refresh steps needed. :victorelf:';
        
        //Build our JSON for the callout
        Map<String, String> slackCalloutData = new Map<String, String>();
        slackCalloutData.put('channel', slackSandboxCallout.Slack_Channel__c);
        slackCalloutData.put('text', textAlert);
        String jstr = Json.serialize(slackCalloutData);
        
        //Declare our Http, HttpRequest & Response records
        Http slackHttp = new Http();
        HttpRequest slackCalloutRequest = new HttpRequest();
        HttpResponse slackResponseBody = new HttpResponse();
        
        //Define the specifics needed for the Slack API Method
        slackCalloutRequest.setHeader('Content-Type', 'application/json');
        slackCalloutRequest.setHeader('Authorization', 'Bearer ' + slackSandboxCallout.Slack_Token__c);
        slackCalloutRequest.setMethod('POST');
        slackCalloutRequest.setEndpoint(slackSandboxCallout.API_Method__c);
        slackCalloutRequest.setBody(jstr);
        
        if(Test.isRunningTest()){
            return;
        }
        
        
        //Get our Response Record back
        slackResponseBody = slackHttp.send(slackCalloutRequest);
        
        //If our message fails to send to Slack then send an email to SF Admin account to notify
        if (slackResponseBody.getStatusCode() != 200){
            
            // Create and send an email with the results of the Callout
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
            //Set our Mail 
            mail.setToAddresses(new String[] {'sfadmin@eab.com'});
            mail.setReplyTo('sfadmin@eab.com');
            mail.setSenderDisplayName('Slack Sandbox Refresh Complete Failed');
            mail.setSubject('Slack Sandbox Refresh Complete Failed');
            mail.setPlainTextBody('The callout to Slack failed with the following errors:' + '\n' + 'Status Code: ' + slackResponseBody.getStatusCode() + '\n' + 'Error Body: ' + slackResponseBody.getBody());
            
            //Send our email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
            
        }
        
    }
    
    //This method is used to invoke the run test.
    public void scheduleRunAllTest() {
	
        Sched_ExecuteRunAllTests runTest = new Sched_ExecuteRunAllTests(); 
        
        //Scheduling the class for every day at 7 PM. 
        System.schedule('RunTestDaily', '0 0 19 ? * * *' , runTest);            
     }
}