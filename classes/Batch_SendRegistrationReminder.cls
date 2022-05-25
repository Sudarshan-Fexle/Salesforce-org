/**
 * 
 * 	Description	:	Batch class to send registration reminder emails x hours before meeting
 * 
 * 	Revision Logs	:	v1.0 - 07/20/2020 - CR-20200708-14279 - Victor Hanson - Created
 *                      	v1.1 - 07/29/2020 - CR-20200729-14380 - Victor Hanson - Updated to remove references to MeetingId and update query
 *                      	v1.2 - 08/04/2020 - CR-20200729-14380 - Victor Hanson - added ' AND CreatedDate < TODAY' to prevent unnecessary reminder emails
 *                              v1.3 - 02/11/2021 - CR-20210211-14908 - Victor Hanson - updated query by replacing Meeting__c with EAB_Event__c
 **/ 
global class Batch_SendRegistrationReminder implements database.batchable<sobject>, Database.AllowsCallouts, Schedulable {
	public string queryString;
    
    global Batch_SendRegistrationReminder() {

    }
    
    global database.querylocator start(database.batchableContext bc) {
        DateTime dtNow = dateTime.now();
        DateTime dtNowPlusFour = dateTime.now().addHours(4);
        if (queryString == null) {
            
            queryString = 'SELECT Id, EAB_Event__r.Begins__c, Zoom_Participant_URL__c, Zoom_Reminder_Email_Sent__c, '
                        + ' EAB_Event__r.Zoom_Meeting_ID__c, Contact__r.Account.Time_Zone_ID__c, EAB_Event__r.Public_Name__c, '
                        + ' Contact__c, Contact__r.Email '
                        + ' FROM Registration__c WHERE EAB_Event__r.Begins__c >= :dtNow AND EAB_Event__r.Begins__c <= :dtNowPlusFour AND '
                        + ' Zoom_Reminder_Email_Sent__c = null AND Status__c = \'Registered\' AND Zoom_Participant_URL__c != null AND CreatedDate < TODAY';
        }
        return database.getquerylocator(QueryString);
    }
    
    global void execute(database.batchablecontext bd, list<sobject> sc) {
        list<Registration__c> registrations = (list<Registration__c>) sc;
        
        //get email template id
        Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName='Day_of_Event_Zoom_Notification'].Id;
        //get email address
        List<OrgWideEmailAddress> owea = [select Id from OrgWideEmailAddress where Address = :Label.Zoom_Reminder_Email_Address];
        
        if (registrations.size() > 0) {
            
            //list to hold email messages
            List<Messaging.SingleEmailMessage> listEmails = new List<Messaging.SingleEmailMessage>();
            
            for (Registration__c reg : registrations) {
                
                Messaging.SingleEmailMessage email = EmailHandler.createEmail(new List<String> { reg.Contact__r.Email }, 
                                                                              reg.Id, 
                                                                              reg.Contact__c, 
                                                                              templateId, 
                                                                              false);
                email.setSaveAsActivity(false);
                if (owea.size() > 0)
                	email.setOrgWideEmailAddressId(owea[0].Id);
                
                //add email to list
                listEmails.add(email);
                reg.Zoom_Reminder_Email_Sent__c = dateTime.now();
            }
            
            //send the reminder emails
            Messaging.sendEmail(listEmails);
            
            //bypass all triggers and update the registrations with the date/time of the reminder email
            util.BypassAllTriggers = true;
            update registrations;
        }
    }
    
    global void finish(database.batchableContext bc) {
        
    }
    
    public void execute(SchedulableContext ctx) {
        // execute the job
        Database.executeBatch(new Batch_SendRegistrationReminder(), Integer.valueOf(Label.Batch_SendRegistrationReminder_Size));
    }
}