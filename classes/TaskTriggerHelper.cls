/*
    Purpose         :   This class is helper class for trigger on Task object.
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   11/03/2011
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.1 Created
                        V_1.2 - 03/07/2014 - Bhavi Sharma - New Method Added(postMemberImpactStory) - CR-20140214-4512
                        V_1.3 - 04/18/2014 - Bhavi Sharma - Modfied(postMemberImpactStory) - CR-20140414-5064
                        V_1.4 - Modified by - Ajit Surana - 02/25/2015 - CR-20140605-5714 - Commented the populateActivityDateCopy method
                        V_1.5 - Modified By - Abhinav Sharma - 06/15/2015 - CR-20150416-8890 - Added new method (populateFieldsOnConsolidatedInvoice)
                        V_1.6 - Modified By - Mahendra Swarnakar - 10/24/2016 - CR-20160414-9766 - Added new method (updateNameAndRRStatus)
                        V_1.7 - Modified By - Rajeev jain - 03/03/2017 - CR-20170217-10703 - Added new method (updateFieldsOnDevActivity) from VHDev Sandbox to Test
                        V_1.8 - Modified By - Subhash Garhwal - - 02/17/2017 - CR-20170403-10807 -- primaryProposalRequiredForTask(work order DS157)
                        V_1.9 - Modified By - Dipesh Gupta - 09/12/2017 - CR-20170907-11182- Created a new Method populateReleaseActualHours.
                        V_2.0 - Modified By - Saurabh Kumar - 09/13/2017 - CR-20170907-11182 - New method is created "rollupOnChangeRequest"
                        V_2.1 - Modified By - Subhash Garhwal - 11/07/2017 - Issue--CR11744--QA--00007311 - Added bypass logic to avoid SOQL limit issue (BYPASS_TASK_TRIGGER_FOR_MERGE)
                        V_2.2 - Modified By  - Dipesh Gupta CR-20171009-11683 11/08/2017 - updated the method 'populateReleaseActualHours' .
                        V_2.3 - Modified By - Abhianv sharma - CR-20171108-11769 - updated the method 'populateReleaseActualHours'.
                        V_2.4 - Modified By - Subhash Garhwal - 04/25/2018 - CR-20180205-11952 - updated method "primaryProposalRequiredForTask", restrict Task Creation Under an opp. where no Primary Proposal and proposal Lines.
                        V_2.5 - Modified By - Abhinav sharma  - 06/05/2018 - CR-20160809-10094 - Create a new Future method to uodate the Story size calculation on Release.
                        V_2.6 - Modified By - Abhinav sharma - 02/04/2019 - CR-20181008-12647 - new methods added - updateProductLead_OutReachInCycle,  updateProductLead.
                        V_2.7 - Modified By - Victor Hanson - 04/16/2019 - CR-20190416-13005 - Updated createProductLeadsForTaskContact to fix bug
                        V_2.8 - Modified By - Mahendra Swarnkar - 02/14/2019 - CR-20190204-12863 - Added New Method - populateRelatedTypeField
                        V_2.9 - Modified By - Colin McGloin - 04/25/2019 - CR-20190419-13015 - Modified createProductLeadsForTaskContact method / CR-20190419-13016 - Added new saleloftTaskNotRelatedToProductLead method
                        V_3.0 - Modified By - Colin McGloin - 05/09/2019 - CR-20190501-13075 - Modified saleloftTaskNotRelatedToProductLead method
                        V_3.1 - Modified By - Dipesh Gupta - CR-20190514-13107 - 05/15/2019 - Commented method -  notifyTaskCretor and senEmail.
			V_3.2 - Modified By - Colin McGloin - CR-20190507-13095 - 05/15/2019 - Added saleloftTaskRelatedToContact method & saleloftTaskRelatedToMembership method//Refactored saleloftTaskNotRelatedToProductLead method
                        V_3.3 - Modified By - Colin McGloin - 07/03/2019 - CR-20190624-13193 - Modified how the saleloftTaskRelatedToContact evaluates Membership related Salesloft Tasks and modified related methods slightly
                        V_3.4 - Modified By - Colin McGloin - 10/03/2019 - CR-20190924-13360 - Modified the saleloftTaskRelatedToContact and saleloftTaskNotRelatedToProductLead methods
                        V_3.5 - Modified By - Dipesh Gupta -12/30/2019 - CR-20191023-13455 -- added new method "updateSalesInvoice"
			V_3.6 - Modified By - Dipesh Gupta - CR-20200406-13906 - updated the logic for lower case program acronym. createProductLeadsForTaskContact
			V_3.7 - Modified By - Neha  Sharma - CR-20200518-14064 - 01/04/2021 - Not needed 'Salesloft Unrelated' further
*/
public without sharing class TaskTriggerHelper {
    
    //Flag to contol the trigger execution 
    public static Boolean BYPASS_TASK_TRIGGER_FOR_MERGE = false;
    
    //final variables
    public final static String STATUS_COMPLETED = 'Completed';
    public final static String SENDER_DISPLAY_NAME = 'Advisory Support';
    public static Map<Id, User> mapUser = new Map<Id, User>();
    public final static Id RECORD_TYPE_ID_TASK_PT_MARKETING = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Task_BI_Marketing').getRecordTypeId();
    
    //Addded By - Mahendra Swarnakar - 10/24/2016 - CR-20160414-9766 - Starts from here
    public final static String SUBJECT_FOR_REFERENCE_REQUEST = 'Schedule & Perform the Reference Call';
    //Addded By - Mahendra Swarnakar - 10/24/2016 - CR-20160414-9766 - Ends here
    
    //This method is to send teh email to Task creatot if task status is completed
    //and Notify Task Owner check box is true.
    //Dipesh Gupta - CR-20190514-13107 - 05/15/2019 - Commented method -  notifyTaskCretor.
    /* public static void notifyTaskCretor(List<Task> oldRecords, List<Task> newRecords) {
        
       //Create a set of user ids to fetch teh user information as the relationship fields can not be tracked directly
        Set<Id> userIds = new Set<Id>();
        
        //loop through the records
        for(Task task : newRecords) {
            userIds.add(task.OwnerId);
            userIds.add(task.CreatedById);
        }
        
        //fetch the user data
        mapUser = new Map<Id, User>([Select Id, Name, Email from User where Id IN: userIds]);
        
        //loop through the tasks
        for(Integer i = 0; i < newRecords.size(); i++) {
            
            //check if task status was not "Completed" and "Notify Task Creator" was unchecked
            if(oldRecords != null && oldRecords.size() > 0) {
                if(newRecords[i].Status != null && newRecords[i].Status != '' 
                    && STATUS_COMPLETED.equalsIgnoreCase(newRecords[i].Status) 
                    //&& newRecords[i].Notify_Task_Creator__c == true
                    && (newRecords[i].Status != oldRecords[i].Status 
                    //|| newRecords[i].Notify_Task_Creator__c != oldRecords[i].Notify_Task_Creator__c
                    )) {
                    
                    //send email to task creator
                    senEmail(newRecords[i]);
                }
            } else if(newRecords[i].Status != null && newRecords[i].Status != '' 
                    && STATUS_COMPLETED.equalsIgnoreCase(newRecords[i].Status) 
                    //&& newRecords[i].Notify_Task_Creator__c == true
                    ) {
                    senEmail(newRecords[i]); 
            }
        }
        
    }*/
    
    //Commented by - Ajit Surana - 02/25/2015 - CR-20140605-5714  
    public static void populateActivityDateCopy(list<Task> newTaskList) {
        
        // loop through each task and populate the activity date copy
       /* for (Task tsk : newTaskList) {
            
            // update the activity date copy field
            tsk.Activity_Date_Copy__c = tsk.ActivityDate;
        }*/
    }
    
    //Dipesh Gupta - CR-20190514-13107 - 05/15/2019 - Commented method -  notifyTaskCretor.
    //method to send an email to task creator
    /*private static void senEmail(Task task) {
        
        // Create a new single email message object
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        //check if user exists in map
        if(mapUser.containsKey(task.CreatedById)) {
            
            // Strings to hold the email address to which we are sending the email.
            List<String> toAddresses = new List<String>{mapUser.get(task.CreatedById).Email};
            
            // Assign the addresses for the To and CC lists to the mail object.
            mail.setToAddresses(toAddresses);
            
            // Specify the name used as the display name.
            mail.setSenderDisplayName(SENDER_DISPLAY_NAME);
            
            // Specify the subject line for your email address.
            mail.setSubject(' A Task you created is now complete'); 
            
            // Specify the text content of the email.
            String emailBody;
            
            emailBody = task.Subject + ', assigned to ' + mapUser.get(task.OwnerId).Name + ' is complete.' +
                         '<BR/><a href=\'' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + task.Id + '\'>Click here to view the task</a>' ;
            
            //set html plain body
            mail.setHtmlBody(emailBody);
            
            // Send the email you have created.
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }*/
    
    /**
     *  @description    :   This method is to check if the Testimonial task is being created, then create a new Feed item with user story
     *
     *  @args           :   List of New Tasks
     *
     *  @retun          :   void
     *
     **/
    public static void postMemberImpactStory(List<Task> tasks) {
        
        //Get the Testimonial Record Type
        List<RecordType> recordTypes = [Select Id from RecordType where Name =: Constants.RECORD_TYPE_TASK_DEVELOPER_NAME_TESTIMONIALS AND SObjectType = 'Task'];
        if(recordTypes.size() == 0)
            throw new CustomException('Testimonials Record Type not found.');
        
        //Added By Bhavi Sharma - 04/18/2014 - CR-20140414-5064
        //Set to hold the account Ids
        Set<Id> accountIds = new Set<Id>();
        
        //Loop through the task over here and populate the account Id set
        for(Task t : tasks) {
            
            //Check if it's Member Impact Story
            if(t.RecordTypeId == recordTypes[0].Id && t.Subject == Constants.TASK_SUBJECT_MEMBER_IMPACT_STORY && t.WhatId != null && t.WhatId.getSobjectType() == Schema.Account.sObjectType) {
                
                //Populate account id in set
                accountIds.add(t.WhatId);   
            }
        }    
                
        //Don't do anything if set is blank
        if(accountIds.size() == 0)
            return;
        
        //Fetch account records from database along with Record Type
        Map<Id, Account> mapAccounts = new Map<Id, Account>([Select Id, RecordType.DeveloperName from Account 
                                                                    where Id IN: accountIds AND RecordType.DeveloperName IN (:Constants.RECORD_TYPE_ACCOUNT_DEVELOPER_NAME_US_EDUCATION, :Constants.RECORD_TYPE_ACCOUNT_DEVELOPER_NAME_INTERNATIONAL_EDUCATION)]);
        
        //List of feed items
        List<FeedItem> feedItems = new List<FeedItem>();
        
        //Loop through the list of Task and check if it's a Member Sgare Story
        for(Task t : tasks) {
            
            //Check if it's Member Impact Story
            if(t.RecordTypeId == recordTypes[0].Id && t.Subject == Constants.TASK_SUBJECT_MEMBER_IMPACT_STORY && t.WhatId != null && t.WhatId.getSobjectType() == Schema.Account.sObjectType) {
                
                String submittedBy = UserInfo.getUserName();
                
        		/*Modified By Dipesh Gupta -CR-20190524-13153 - Date-06/13/2019 */
                /*if(!String.IsBlank(t.Additional_ABC_Attendees__c)) {
                    
                    //Add Submitted By
                    submittedBy = t.Additional_ABC_Attendees__c.subStringBefore('(').subStringBefore('-');
                } */
                
                //Variable to hold task body
                String body; 
                
                //Check if task description is not null
                if(!String.IsBlank(t.Description)) {
                    
                    //Check if Description is more that 4800 chanracters, than append a Suffix in last to tell user to go the the task detail record to read the complete story
                    if(t.Description.length() > 4800) {
                        
                        body = t.Description.subString(0, 4800) + '.....\r\n';
                        body += 'Go to the task record to read the complete story.';
                    } else {
                        body = t.Description;
                    }
                    
                    //Added By Bhavi Sharma - 04/18/2014 - CR-20140414-5064
                    //Variable to Hold HASH TAG
                    String HASH_TAG = '#HCMemberImpact';
                    
                    //Check if what Id is in Account map, then it's a edication account and assign it #EABMemberImpactStory tag
                    //Else #HCMemberImpactStory
                    if(mapAccounts.containsKey(t.WhatId))
                        HASH_TAG = '#EABMemberImpact';
                    
                    //Add Hash Tag and Submitter Name
                    body = HASH_TAG + ' submitted by ' + submittedBy + '\r\n' + body;
                    System.debug('Body:::::' + body);
                    
                    //Create a new Feed Item
                    String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + t.Id;
                    feedItems.add(new FeedItem(ParentId = t.WhatId, Body = body, LinkUrl = fullRecordURL, Type = 'LinkPost', Title = Constants.TASK_SUBJECT_MEMBER_IMPACT_STORY ));
                }
            }
        }
        
        //Post feeds
        if(feedItems.size() > 0)
            insert feedItems;
    }
    
    /**
     *  @description    :   This method is to update the related IS Dev Activity
     *             if the Task is related to a CR.
     *
     *  @args           :   Map of New Tasks, Map of old tasks
     *
     *  @retun          :   void
     *
    **/
    public static void updateFieldsOnDevActivity(map<Id, Task> mapNewTasks, Map<Id, Task> mapOldTasks) {
        
        //set of task ids.  Used to query related Dev Activities.
        set<Id> taskIdsToCheck = new set<Id>();
        list<SFDC_Request_Comment__c> devActivitiesToUpdate = new list<SFDC_Request_Comment__c>();
        
        //get the tasks
        map<Id, Task> mapTasks = (mapNewTasks != null) ? mapNewTasks : mapOldTasks;
        //Loop through task records
        for(Task tsk : mapTasks.values()) {
            //if the relatedTo is a change request, put the task id in the set
            if(tsk.WhatId != null 
               && tsk.WhatId.getSObjectType() == Schema.SFDC_Change_Request__c.SobjectType)
                taskIdsToCheck.add(tsk.Id);
        }
        
        //return immediately if there are no tasks related to Change Requests
        if (taskIdsToCheck.size() == 0) return;
        
        //query for the related Dev Activities
        list<SFDC_Request_Comment__c> devActivities = [SELECT Id, Activity_Date__c, Activity_Type__c, Comment__c, Time__c, Task_ID__c
                                                       FROM SFDC_Request_Comment__c 
                                                       WHERE Task_ID__c IN :taskIdsToCheck];
        for (SFDC_Request_Comment__c da : devActivities) {
            //get the related task
            Task tsk = mapTasks.get(da.Task_ID__c);
            if (tsk != null && 
                 (trigger.isDelete ||
                   trigger.isUpdate && 
                   (tsk.Duration_in_Hours__c != da.Time__c || 
                    tsk.Type != da.Activity_Type__c || 
                    tsk.ActivityDate != da.Activity_Date__c || 
                    tsk.Description != da.Comment__c)
                 )
               ) 
            {
                da.Time__c = (trigger.isDelete) ? 0 : tsk.Duration_in_Hours__c;
                da.Activity_Type__c = tsk.Type;
                da.Activity_Date__c = tsk.ActivityDate;
                da.Comment__c = tsk.Description;
                devActivitiesToUpdate.add(da);
            }
        }
        
        //update dev activities
        if (devActivitiesToUpdate.size() > 0) update devActivitiesToUpdate;
    }
                            
                            
    
    //Added By - Abhinav Sharma - 06/15/2015 - CR-20150416-8890
    /**
     *  @description    :   This method is to pull out the most recent "Last Modified Date" value from 
     *             the most recent activity task in "Activity History". 
              Then there to populate “Last Follow-Up Date” on consolidate invoice.  
              Similarly, will pull out the associated task/subject that corresponds with 
              the "Last Modified Date" pulled into the “Last Follow Up Note” field on consolidated. 
     *
     *  @args           :   List of New Tasks, Map of old tasks
     *
     *  @retun          :   void
     *
    **/
    public static void populateFieldsOnConsolidatedInvoice(List<Task> tasks, Map<Id, Task> mapOldTasks) {

        //Map of consolidated invoices
        Map<Id, ConsolidatedInvoice__c> mapConsolidatedInvoices = new Map<Id, ConsolidatedInvoice__c>();

        //Checking new record list for null value
        if(tasks != null) {
    
            //Loop through task records
            for(Task tsk : tasks) {
    
                //Insert case
                if(mapOldTasks == null) {
    
                    if(tsk.Status == TaskTriggerHelper.STATUS_COMPLETED 
                        && tsk.WhatId != null 
                        && tsk.WhatId.getSObjectType() == Schema.ConsolidatedInvoice__c.SobjectType)
                        mapConsolidatedInvoices.put(tsk.WhatId, new ConsolidatedInvoice__c(ID = tsk.WhatId, Last_Follow_Up_Date__c = null, Last_Follow_Up_Note__c = null));
                }
            
              //Update use case
              if(mapOldTasks != null) {
    
                    //Checking for the field value change on task record update
                    if(tsk.WhatId != mapOldTasks.get(tsk.Id).WhatId
                        || tsk.Status != mapOldTasks.get(tsk.Id).Status
                        || tsk.LastModifiedDate != mapOldTasks.get(tsk.Id).LastModifiedDate) {
        
                        //Checking and validating task records for fields values   
                        if(tsk.Status == TaskTriggerHelper.STATUS_COMPLETED 
                            && tsk.WhatId != null 
                            && tsk.WhatId.getSObjectType() == Schema.ConsolidatedInvoice__c.SobjectType)
                            mapConsolidatedInvoices.put(tsk.WhatId, new ConsolidatedInvoice__c(ID = tsk.WhatId, Last_Follow_Up_Date__c = null, Last_Follow_Up_Note__c = null));
        
                        if(mapOldTasks.get(tsk.Id).Status == TaskTriggerHelper.STATUS_COMPLETED
                            && mapOldTasks.get(tsk.Id).WhatID != null
                            && mapOldTasks.get(tsk.Id).WhatId.getSObjectType() == Schema.ConsolidatedInvoice__c.SobjectType)
                            mapConsolidatedInvoices.put(mapOldTasks.get(tsk.Id).WhatID, new ConsolidatedInvoice__c(ID = mapOldTasks.get(tsk.Id).WhatID, Last_Follow_Up_Date__c = null, Last_Follow_Up_Note__c = null));
                    }       
              }
            }        
        }  
  
        //Delete use cases
        else {
    
            //Loop through old records
            for(Task tk : mapOldTasks.values()) {
    
                if(mapOldTasks.get(tk.Id).Status == TaskTriggerHelper.STATUS_COMPLETED
                    && mapOldTasks.get(tk.Id).WhatID != null
                    && mapOldTasks.get(tk.Id).WhatId.getSObjectType() == Schema.ConsolidatedInvoice__c.SobjectType)
                    mapConsolidatedInvoices.put(mapOldTasks.get(tk.Id).WhatID, new ConsolidatedInvoice__c(ID = mapOldTasks.get(tk.Id).WhatID, Last_Follow_Up_Date__c = null, Last_Follow_Up_Note__c = null));
            }
        }   

        //Checking set for size value
        if(mapConsolidatedInvoices != null && mapConsolidatedInvoices.size() > 0) {
    
            //Loop through opportunity records
            for(ConsolidatedInvoice__c con : [SELECT ID, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c,
                                                (SELECT ID, LastmodifiedDate, Subject FROM ActivityHistories
                                                ORDER BY LastmodifiedDate DESC LIMIT 1)
                                                FROM ConsolidatedInvoice__c 
                                                WHERE ID IN : mapConsolidatedInvoices.keySet()]) {
    
                //Checking if map contains the consolidated invoice record
                if(mapConsolidatedInvoices.containsKey(con.Id) && mapConsolidatedInvoices.get(con.Id) != null) {
          
                    //Checking for associated ActivityHistories list size value
                    if(con.ActivityHistories != null 
                         && con.ActivityHistories.size() > 0
                        && con.ActivityHistories[0].LastModifiedDate != null) {
                       mapConsolidatedInvoices.get(con.Id).Last_Follow_Up_Date__c = Date.valueof(con.ActivityHistories[0].LastModifiedDate);
                        mapConsolidatedInvoices.get(con.Id).Last_Follow_Up_Note__c = con.ActivityHistories[0].Subject;
                   } else {
                      mapConsolidatedInvoices.get(con.Id).Last_Follow_Up_Date__c = null;
                      mapConsolidatedInvoices.get(con.Id).Last_Follow_Up_Note__c = null;
                    }    
                }
            }
    
            //Updating consolidated invoice records
            Util.BypassAllTriggers = true;
            update mapConsolidatedInvoices.values();
            Util.BypassAllTriggers = false;
        }
    }  
    
    /**
     *  @description    :   When a "Schedule & Perform the Reference Call" task's Status changes to 'Completed', 
     *            check to see if all other tasks related to that Reference Request also have the Status of "Completed".  
     *            If so, then update the Refeference Request Status to "Completed" 
     *
     *  @args           :   List of New Tasks, Map of old tasks
     *
     *  @retun          :   void
     *
    **/
    //Added By - Mahendra Swarnakar - 10/24/2016 - CR-20160414-9766
    public static void updateNameAndRRStatus(List<Task> tasks, Map<Id, Task> mapOldTasks) { 
      
        //Set to hold Reference Request Ids
      Set<Id> setReferenceRequestIds = new Set<Id>();
        
        //Set to hold Contact ids(Who Id)
      Set<Id> setContactIds = new Set<Id>();
        
        //Set to hold Project ids(What Id)
      Set<Id> setProjectIds = new Set<Id>();
        
        //Set to hold Membership ids(What Id)
      Set<Id> setMembershipIds = new Set<Id>();
        
        //Set to hold Opportunity ids(What Id)
      Set<Id> setOpportunityIds = new Set<Id>();
      
        
        
      //loop over new records
      for(Task task : tasks){

        //Check task parent is Reference records
        if( mapOldTasks != null 
               && String.IsNotBlank(task.Subject) && task.Subject == SUBJECT_FOR_REFERENCE_REQUEST 
           && task.Status == TaskTriggerHelper.STATUS_COMPLETED && task.Status != mapOldTasks.get(task.id).Status
               && task.WhatId !=null ){
                   //task.WhatId.getSObjectType() == Schema.Reference_Request__c.SobjectType
                   
        //Check for the Contact Tasks 
                if(task.WhoId != null 
                   && task.WhoId.getSObjectType() == Schema.Contact.SobjectType) {
                    
          //Populate set for Project ID
                    setContactIds.add(task.WhoId);   
                }
                       
        //Check for the Project Tasks 
                if(task.WhatId.getSObjectType() == Schema.Project__C.SobjectType){
                    
                    //Populate set for Project ID
                    setProjectIds.add(task.WhatId);   
                }
                   
        //Check for the Membership Tasks 
                if(task.WhatId.getSObjectType() == Schema.Membership__c.SobjectType){
                        
                    //Populate set for Membership ID
                    setMembershipIds.add(task.WhatId);   
                }
          
        //Check for the Opportunity Tasks 
                if(task.WhatId.getSObjectType() == Schema.Opportunity.SobjectType){
                        
                  //Populate set for Opportunity ID
                    setOpportunityIds.add(task.WhatId);   
        }
      }
      }
        if(setContactIds.size() > 0){
          
            //loop over new records
            for(Reference_Request_Contact__c rRC : [Select Id, Reference_Contact__c, Reference_Request__c From Reference_Request_Contact__c 
                                                        where Reference_Request__c != null 
                                                        AND Reference_Contact__c != null 
                                                        AND Reference_Contact__c IN : setContactIds
                                                   ]
      ){
                if(rRC.Reference_Request__c != null)
                  setReferenceRequestIds.add(rRC.Reference_Request__c);
            }   
        }
        
        //Check for set 
      if(setReferenceRequestIds.size() > 0 
           &&(setMembershipIds.size() > 0 
               || setProjectIds.size() > 0 
               || setOpportunityIds.size() > 0 
             )
        ){
        //List to update reference records
        List<Reference_Request__c> referenceRequestsToUpdate = new List<Reference_Request__c>();
            
            //Loop over Reference record
        for(Reference_Request__c rr : [SELECT Id, (SELECT Id FROM Tasks 
                                                           WHERE Status != null
                                                           AND Status !=: TaskTriggerHelper.STATUS_COMPLETED
                                                           Limit 1
                                                          ), Request_Status__c
                                             FROM Reference_Request__c WHERE Request_Status__c !=: TaskTriggerHelper.STATUS_COMPLETED
                                                AND Id != null 
                                               AND Id IN : setReferenceRequestIds 
                                                AND (
                                                   Source_Project__c IN: setProjectIds
                                                   OR Source_Membership__c IN: setMembershipIds
                                                   OR Source_Opportunity__c IN: setOpportunityIds
                                               )
                                          ]
      ){    
                System.debug('####rr.Tasks ' + rr.Tasks + ' @@@@ ' + rr);    
                //throw new CustomException('####rr.Tasks ' + rr.Tasks + ' @@@@ ' + rr);
                if(rr.Tasks!= null && rr.Tasks.size() == 1  ){
                      continue;
                }else {
                    
                    //Set reference Request status to completed
                    rr.Request_Status__c = STATUS_COMPLETED;
                    
                   //populate the list of reference requests to be updated
          referenceRequestsToUpdate.add(rr); 
                }
        }
            System.debug('@@@@@ '+ referenceRequestsToUpdate);
            //throw new customException('@@@@@ '+ referenceRequestsToUpdate);
            //Check size and update reference request records
            if(referenceRequestsToUpdate.size() > 0)
                
                // Update the reference request records
                update referenceRequestsToUpdate;
      }
    }
    /**
     * 
     *  @description    :   This method is used to prevents an activity from being saved on the opportunity without the opportunity having an active primary proposal
     *
     *  @args           :   List<Task> tasks, Map<Id, Task> mapOldTasks
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/09/2017 - Subhash Garhwal - CR-20170403-10807 (Work Order DS157)
     *                      V_1.01 - Modified By Subhash Garhwal - 04/25/2018 - CR-20180205-11952 - Added the logic to through error on Task creation if there is no Proposal Line on Proposal under the opportunity
     * 
     **/   
     /*public static void primaryProposalRequiredForTask(List<Task> tasks, Map<Id, Task> mapOldTasks) { 
       
       //bypass validation if this is a merge operation
       if (OpportunityMergeController.isOpportunityMerge) return;

        //Set to hold opportunity id
        Set<id> WhatIds = new Set<Id>();
    
        //Check for condition
        for(Task task : tasks) {
    
            //Check for particular condition
            if(task.WhatId != null && (mapOldTasks == null || task.WhatId != mapOldTasks.get(task.Id).WhatId) 
             && string.valueOf(task.WhatId).startsWith(CPQConstants.OPPORTUNITY_OBJECT_PREFIX)) 
            {
            
                //Add opportunity id to set
                WhatIds.add(task.WhatId);
            
            }
        }
    
        //Check for the size of opportunity id
        if(whatIds.Size()>0) {
        
            //Map to hold opportunity data
            Map<Id, Opportunity> mapOpportunity = new Map<Id,Opportunity>([ Select Id, SBQQ__PrimaryQuote__r.SBQQ__Primary__c, RecordTypeId,
                                                                            RecordType.DeveloperName,
                                                                            SBQQ__PrimaryQuote__c From Opportunity Where Id IN: whatIds 
                                                                            AND RecordType.DeveloperName  IN: CPQConstants.SET_OPP_INITIATING_RECORDTYPES
                                                                            AND (SBQQ__PrimaryQuote__r.SBQQ__Primary__c = false 
                                                                                OR SBQQ__PrimaryQuote__r.SBQQ__LineItemCount__c = 0)
                                                                          ]);
            if(mapOpportunity.Size()>0 ) {

                for(Task tk : tasks) {
        
                    //Check WhatId contain in mapOldTasks
                    if(mapOpportunity.containsKey(tk.WhatId))
                      tk.addError(Label.Activity_Cannot_Be_Saved);
                } 
            }
        }
    }*/
    
    /**
    * 
    *  @description    :   This method is used to update the release time on the Total_Actual_Hrs_Release__c field 
    *
    *  @args           :   List<Task> tasks, Map<Id, Task> mapOldTasks
    *
    *  @return         :   void
    *
    *  @revision Log   :   V_1.0 - Created - 09/12/2017 - CR-20170907-11182 PM Tool - Dipesh Gupta
    *                      V_1.1 - Modified By  - Dipesh Gupta CR-20171009-11683 - PM Tool Hypercare
    *                      V_1.2-  Modified By - Abhianv sharma - CR-20171108-11769 - Additonal check on deletion case - mapOldTasks.get(taskId) != null && mapOldTasks.get(taskId).WhatId != Null 
    *                       
    **/
    public static void populateReleaseActualHours(List<Task> tasks, Map<Id, Task> mapOldTasks) {
        
        //Set to hold the releaseId
        Set<Id> setReleaseId = new Set<Id>();
        
        //Check for the Tasks deletion case
        if(tasks == null && mapOldTasks != null) {
            
            //For loop on the task old map
            for(Id taskId : mapOldTasks.keySet()) {
                
                //V_1.2-  Modified By - Abhianv sharma - CR-20171108-11769 
                //Check for the task if it is related to relase or not
                if(mapOldTasks.get(taskId) != null && mapOldTasks.get(taskId).WhatId != Null 
                   && mapOldTasks.get(taskId).WhatId.getSObjectType() == Schema.SFDC_Release__c.SobjectType ) {
                    setReleaseId.add(mapOldTasks.get(taskId).WhatId);    
                } 
            }
        }
        
        //Check for the task list is not null
        if(tasks != null) {
            
            //Set to hold the Ids of Release
            for(Task tsk : tasks) {
                
                //check if the what id is null for task.
                if(tsk.WhatId == null)
                    continue;   
                
                //Check from the old map and new List comparison
                //Check if the sObject Type, if it is Release  
                if(tsk.WhatId.getSObjectType() == Schema.SFDC_Release__c.SobjectType 
                   && tsk.Duration_in_Hours__c != null && Integer.valueOf(tsk.Duration_in_Hours__c) > 0) {
                       
                       //Check for the new task records
                       if(mapOldTasks == null)
                           setReleaseId.add(tsk.WhatId);
                       
                       //Update case
                       if(mapOldTasks != null 
                          && mapOldTasks.containsKey(tsk.Id)
                          && mapOldTasks.get(tsk.Id).WhatId.getSObjectType() == Schema.SFDC_Release__c.SobjectType
                          &&
                          (
                              mapOldTasks.get(tsk.Id).Duration_in_Hours__c != tsk.Duration_in_Hours__c
                              ||
                              mapOldTasks.get(tsk.Id).type != tsk.type
                          )
                         ) {
                             setReleaseId.add(tsk.WhatId);
                             setReleaseId.add(mapOldTasks.get(tsk.Id).WhatId);
                         }
                   }
            }
        }
        
        system.debug('setReleaseId----'+setReleaseId);
        
        //List to hold the sfdc release
        List<SFDC_Release__c> sfdcReleaseToBeUpdated = new List<SFDC_Release__c>();
        
        //Check the size of Set
        if(setReleaseId.size() > 0) {
            
            //V_1.1 - Modified By  - Dipesh Gupta CR-20171009-11683 - Start here - additional null checkk.
            //For loop on tasks
            for(SFDC_Release__c sfdcRelease : [Select Id, Total_Actual_Hrs_Release__c, Post_Project_Closure_Support_Actual_Hr__c,
                                               Project_Management_Actual_Hrs__c, Deployment_Execution_Actual_Hrs__c, Deployment_Preparation_Actual_Hrs__c,
                                               Regression_Testing_Actual_Hrs__c, Requirements_Gathering_Actual_Hrs_Rel__c , 
                                               Meetings_Communications_Actual_Hrs_Rel__c, 
                                               Design_Actual_Hrs_Rel__c,
                                               UAT_Support_Actual_Hrs_Rel__c,
                                               (Select Id, Duration_in_Hours__c, Type From Tasks where Duration_in_Hours__c != null AND Duration_in_Hours__c !=  0) 
                                               From SFDC_Release__c 
                                               Where ID IN: setReleaseId]) {
                                                   
              //V_1.1 - Modified By  - Dipesh Gupta CR-20171009-11683 - End here                                       
                //Integer to hold the release hours
                Decimal timeDurationOnRelease = 0; 
                Decimal timeRegTestingOnRelease = 0;
                Decimal timeDeployPrepOnRelease = 0;
                Decimal timeDeployExeOnRelease = 0;                                  
                Decimal timeProjectManagementOnRelease = 0;
                Decimal timePostProjectClosureSupportOnRelease = 0;
                                                   
                Decimal timeRequirementGatheringOnRelease = 0;
                Decimal timeMeetingCommunicationActualOnRelease = 0;
                Decimal timeDesignActualOnRelease = 0;
                Decimal timeUATSupportActualHrsOnRelease = 0;
                                                   
               //for loop on tasks
                for(Task tsk : sfdcRelease.Tasks) {
                    
                    system.debug('TestTAsk----' + tsk);
                    
                    //Project Management
                    if(tsk.Type == 'Project Management')
                        timeProjectManagementOnRelease += tsk.Duration_in_Hours__c;
                    
                    //Deployment/Execution
                    if(tsk.Type == 'Deployment Execution')
                        timeDeployExeOnRelease += tsk.Duration_in_Hours__c;
                    
                    //Deployment/Prepration
                    if(tsk.Type == 'Deployment Preparation')
                        timeDeployPrepOnRelease += tsk.Duration_in_Hours__c;
                    
                    //Regression Testing
                    if(tsk.Type == 'Regression Testing')
                        timeRegTestingOnRelease += tsk.Duration_in_Hours__c;
                    
                    //Post project Closure Support
                    if(tsk.Type == 'Post Project Closure Support')
                        timePostProjectClosureSupportOnRelease += tsk.Duration_in_Hours__c;
                    
                    //Check for the requirement Gathring.
                    if(tsk.Type == 'Requirements Gathering')
                      timeRequirementGatheringOnRelease  += tsk.Duration_in_Hours__c;    
                    
                    //Check for the Meeting Communication
                    if(tsk.Type == 'Meetings/Communications' || tsk.Type == 'Communications')
                      timeMeetingCommunicationActualOnRelease += tsk.Duration_in_Hours__c;  
                    
                    
                    //Check for the Analysis/Design
                    if(tsk.Type == 'Analysis/Design')
                      timeDesignActualOnRelease += tsk.Duration_in_Hours__c;  
                    
                    //Check for the UAT
                    if(tsk.Type == 'UAT Support')
                      timeUATSupportActualHrsOnRelease += tsk.Duration_in_Hours__c;  
                    
                   
                    //adding the all release locked  time.
                    timeDurationOnRelease += tsk.Duration_in_Hours__c;
                    
                }
                                                   
                sfdcReleaseToBeUpdated.add(new SFDC_Release__c( Id = sfdcRelease.Id, 
                                                                Total_Actual_Hrs_Release__c = timeDurationOnRelease,
                                                                Project_Management_Actual_Hrs__c = timeProjectManagementOnRelease,
                                                                Deployment_Execution_Actual_Hrs__c = timeDeployExeOnRelease,
                                                                Deployment_Preparation_Actual_Hrs__c = timeDeployPrepOnRelease,
                                                                Regression_Testing_Actual_Hrs__c = timeRegTestingOnRelease,
                                                                Post_Project_Closure_Support_Actual_Hr__c = timePostProjectClosureSupportOnRelease,
                                                                Requirements_Gathering_Actual_Hrs_Rel__c = timeRequirementGatheringOnRelease,
                                                                Meetings_Communications_Actual_Hrs_Rel__c = timeMeetingCommunicationActualOnRelease,
                                                                Design_Actual_Hrs_Rel__c = timeDesignActualOnRelease,
                                                                UAT_Support_Actual_Hrs_Rel__c = timeUATSupportActualHrsOnRelease
                                                          
                                                              ));
            }
        }
        
        //Check the size of list
        if(sfdcReleaseToBeUpdated.size() > 0) {
            Util.byPassAllTriggers = true;
            update sfdcReleaseToBeUpdated;
            Util.byPassAllTriggers = false;
        }
     }
    
    /**
    * 
    *  @description    :   This method is used to rollup time on the Change Request object
    *
    *  @args           :   List<Task> tasks, Map<Id, Task> mapOldTasks
    *
    *  @return         :   void
    *
    *  @revision Log   :   V_1.0 - Created - 09/12/2017 - CR-20170907-11182 - Saurabh Kumar
    * 
    **/
    public static void rollupOnChangeRequest(List<Task> tasks, Map<Id, Task> mapOldTasks){
        
         //Map to hold Change request records
         Map<Id, SFDC_Change_Request__c> mapChangeRequest = new Map<Id, SFDC_Change_Request__c>();
        
         //Processing on the new records in insert or update case and processing on the old records in case of delete case
        for(Task tsk : tasks != null ? tasks : mapOldTasks.values()){
            
            //Checking for the what id is Change request then only proceed otherwise skip the record
            if(String.isNotBlank(tsk.WhatId) && tsk.WhatId.getSObjectType() != Schema.SFDC_Change_Request__c.SobjectType)
                continue;
            
            //Checking for the insert case
            if(mapOldTasks == null && tsk.Type != null && String.isNotBlank(tsk.WhatId))
                mapChangeRequest.put(tsk.WhatId, new SFDC_Change_Request__c(Id = tsk.WhatId, Meetings_Communications_Actual_Hrs__c = 0,
                                                                            UAT_Support_Actual_Hrs__c = 0));
            
            //Checking for the update case
            if(mapOldTasks != null && (tsk.WhatId != mapOldTasks.get(tsk.Id).WhatId || tsk.Type != mapOldTasks.get(tsk.Id).Type
                                      || tsk.Duration_in_Hours__c != mapOldTasks.get(tsk.Id).Duration_in_Hours__c)){
                                          
                //Put in the map for new CR if new CR not null
                if(String.isNotBlank(tsk.WhatId))
                    mapChangeRequest.put(tsk.WhatId, new SFDC_Change_Request__c(Id = tsk.WhatId, Meetings_Communications_Actual_Hrs__c = 0,
                                                                                UAT_Support_Actual_Hrs__c = 0));
                 //Put in the map for old record if old old CR is not null
                 if(mapOldTasks.get(tsk.Id).WhatId != null)
                     mapChangeRequest.put(mapOldTasks.get(tsk.Id).WhatId, new SFDC_Change_Request__c(Id = mapOldTasks.get(tsk.Id).WhatId, Meetings_Communications_Actual_Hrs__c = 0,
                                                                            UAT_Support_Actual_Hrs__c = 0));
                
            }
            
            //Checking for the delete case
            if(mapOldTasks != null && tasks == null && String.isNotBlank(tsk.WhatId))
                mapChangeRequest.put(tsk.WhatId, new SFDC_Change_Request__c(Id = mapOldTasks.get(tsk.Id).WhatId, Meetings_Communications_Actual_Hrs__c = 0,
                                                                            UAT_Support_Actual_Hrs__c = 0));
                
        }
        
        //Checking for the map size
        if(mapChangeRequest != null && mapChangeRequest.size() > 0){
            
            //Query on the Task and total the values on the CR
            for(Task tsk : [Select Id, Duration_in_Hours__c, WhatId, Type From Task Where WhatId IN : mapChangeRequest.keySet()]){
                
                //Checking for key
                if(mapChangeRequest.containsKey(tsk.WhatId)){
                    
                    //Checking for the Meetings/Communications
                   if(tsk.Type == 'Meetings/Communications')
                        mapChangeRequest.get(tsk.WhatId).Meetings_Communications_Actual_Hrs__c += tsk.Duration_in_Hours__c;
                    
                    //Checking for the UAT Support type
                    if(tsk.Type == 'UAT Support')
                        mapChangeRequest.get(tsk.WhatId).UAT_Support_Actual_Hrs__c += tsk.Duration_in_Hours__c;
                    
                }
            }
            
            //Bypass all the triggers and update the release
            Util.byPassAllTriggers = true;
            update mapChangeRequest.values();
            Util.byPassAllTriggers = false;
            
            //Calling a Method to update the SFDC Release      
            rollUpCRStorySizeToSFDCRelease(mapChangeRequest.keyset());
        }
    }
    
    /**
    * 
    *  @description    :   This method is used to just call the method of Change request
    *
    *  @args           :   List<Task> tasks, Map<Id, Task> mapOldTasks
    *
    *  @return         :   void
    *
    *  @revision Log   :   V_1.0 - Created - Abhinav sharma - CR-20160809-10094
    * 
    **/  
    @future
    private static void rollUpCRStorySizeToSFDCRelease(Set<Id> setCRIds) {
    
        //Check the size of Set
        if(setCRIds.size() > 0) {
        
            //Query the CR 
            List<SFDC_Change_Request__c> cRs =  [Select Id, Release__c, StorySizeEst__c, StorySizeAct__c 
                                                From SFDC_Change_Request__c where Id IN : setCRIds];
                                                
            //Check the CR Size
            if(cRs.size() > 0 )
            
                //Calling method to rollup the release
                SFDCChangeRequestTriggerHelper.rollUpStorySizeDataOnSFDCRelease(cRs, null);
        }
    }  
    
   
     /**
    * 
    *  @description    :   Method to create Product Lead records while inserting the Task records. 
    *
    *  @args           :   List<Task> tasks
    * 
    *  @revision Log   :   V_1.0 - Created - Abhinav Sharma - Sales loft. 
    *                      V_1.1 - Modified - Victor Hanson - CR-20190416-13005
    *                      V_1.2 - Modified - Colin McGloin - CR-20190419-13015 - Modified logic so that it fires based on SalesLoft_External_ID__c or Program Acronym at start of SalesLoft_Email_Template_Title__c
    * 			   V_1.3 - Modified by Dipesh Gupta - CR-20200406-13906 - updated the logic for lower case program acronym. 
    **/
    public static void createProductLeadsForTaskContact(List<Task> newTasks) {
    	
        //set To hold the Task Id
        set<Id> setTasksIds = new set<Id>();
        
        //Map to hold the Task with the Task Ids
        map<Id, Set<String>> mapOfcontactIdWithProgramAcronym = new map<Id, set<String>>();
        
       
        //Map to hold the string with String. 
        Map<String, String> mapProgramWithAcronym = new Map<String, String>();
        Map<String, String> mapAcronymWithProgram = new Map<String, String>();
        
        //List of product lead to be inserted. 
        List<Product_Lead__c> prodctLeadsToBeInserted = new List<Product_Lead__c>();
        List<Product_Lead__c> prodctLeadsExistingToBeUpdated = new List<Product_Lead__c>();
        
        //Map to hold the Tasks with their Contact. 
        Map<Id, List<Task>> mapContactsWithTasks = new Map<Id, List<Task>>();
        
        //List to hold the tasks.
        List<Task> taskToBeUpdated = new List<Task>();
        
        //Modified by Mahendra Swarnkar - 04/30/2020 - CR-20200129-13676 - Start Here
        //String to hold the Record Type 
        //String TASK_PT_MARKETING_RTYPE_ID = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Task PT Marketing').getRecordTypeId();
         String TASK_PT_MARKETING_RTYPE_ID = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Outreach').getRecordTypeId();
        //Modified by Mahendra Swarnkar - 04/30/2020 - CR-20200129-13676 - End Here
        
    	//Check for the Task fields which is related to the Sales Loft to get the program acronym. 
    	for(Task tsk : newTasks){
            
            //check if the essential Contact fields are not blank. 
            if(tsk.WhoId != null && tsk.WhoId.getSObjectType() == Schema.Contact.SobjectType && tsk.Event_Purpose__c != 'Meeting Recruitment') {

                //Establish if either of our SalesLoft fields are populated
                String productIdentifier = '';

                //Check for null strings
                if (tsk.SalesLoft_External_ID__c != null || tsk.SalesLoft1__SalesLoft_Email_Template_Title__c != null){

                    if (String.isNotBlank(tsk.SalesLoft_External_ID__c))
                        productIdentifier = tsk.SalesLoft_External_ID__c;
                    else if (tsk.SalesLoft1__SalesLoft_Email_Template_Title__c.subStringBefore('_') != null)
                        productIdentifier = tsk.SalesLoft1__SalesLoft_Email_Template_Title__c.subStringBefore('_');

                }

                //If Product Identifier is populated then proceed
                if (!String.isEmpty(productIdentifier)) {
            		
                    //CR-20200406-13906- Added by Dipesh Gupta - 04/06/2020
                    //Changing the Identifier to the UpperCase so no matter what is selected on the Salesloft cadence. We have the right value here. 
                    productIdentifier = productIdentifier.toUpperCase();
                    
                    //Check for the Map is containing the Task Ids. 
                    if(!mapOfcontactIdWithProgramAcronym.containsKey(tsk.WhoId))
                        mapOfcontactIdWithProgramAcronym.put(tsk.WhoId, new set<String>());
                    
                    //Map to fill the Salesloft Exter Id with the respective Contact. 
                    mapOfcontactIdWithProgramAcronym.get(tsk.WhoId).add(productIdentifier);
                    
                    //Filling the map with the Program Acronym. 
                    mapProgramWithAcronym.put(productIdentifier, '');
                    
                    setTasksIds.add(tsk.Id);

                }
            }
        }
        
        //Checking for the set size. 
        if(mapOfcontactIdWithProgramAcronym.size() > 0) {
           
			//Query on the programs
            for(Program__c prgm : [Select Id, Program_Acronym__c From Program__c 
                                   Where Program_Acronym__c IN: mapProgramWithAcronym.keyset()]) {
                                       
            	//Filling Map. 
            	mapProgramWithAcronym.put(prgm.Program_Acronym__c, prgm.Id);
                mapAcronymWithProgram.put(prgm.Id, prgm.Program_Acronym__c);
           }
            
           //Query on the Contact. 
            for(Contact con : [Select Id, (Select Id, Program__c, Program__r.Program_Acronym__c, Contact__c, Stage__c, Outreach_Type__c, 
                                           Ownerid, Action__c, Name From Product_Lead_Stages__r
                                          WHERE Program__r.Program_Acronym__c IN :mapProgramWithAcronym.keyset()) 
                               From Contact Where Id IN: mapOfcontactIdWithProgramAcronym.keySet()]) {
            	
                //Set to  hold the Program Acronym. 
                set<String> setExistingPLeadProgramAcronym = new set<String>();
                
                //check for the size of product Lead List.
                if(con.Product_Lead_Stages__r != null && con.Product_Lead_Stages__r.size() > 0) {
            		
                    //Loop through the Product lead records.
                    for(Product_Lead__c pLead : con.Product_Lead_Stages__r) {
                		setExistingPLeadProgramAcronym.add(pLead.Program__r.Program_Acronym__c);    
                        prodctLeadsExistingToBeUpdated.add(pLead);
                    }
                }
                
                //Returns a set of acronym which task is trying to insert.
                Set<String> setPLeadsAcronyms = mapOfcontactIdWithProgramAcronym.get(con.Id);
                
                //Loop on the setPLeadsAcronyms
                for(String acrnym : setPLeadsAcronyms) {
            		
                    //Updated by Dipesh Gupta - CR-20200406-13906
                    //Check for the acronym. 
                    if(!setExistingPLeadProgramAcronym.contains(acrnym) && String.isNotEmpty(mapProgramWithAcronym.get(acrnym))) {
                        
                        //Instantiate the Product Leads.
                    	Product_Lead__c Plead = new Product_Lead__c();
                        
                        //Filling the Object. 
                        Plead.Contact__c = con.Id;
                        Plead.Program__c = mapProgramWithAcronym.get(acrnym);
                        Plead.Name = 'Will Auto Populate';
                        
                        //Modify By - Dipesh Gupta - CR-20200205-13700 - 5/1/2020 - Comment the Plead.OwnerId and add ne logic for this
                        //Set the Owner - SF ADMIN - CR-20181211-12779
                        //Plead.OwnerId = Label.Salesforce_Admin_Id;
                       
                        
                        /*****End ******/
                        Plead.Stage__c = 'TGL';
                        plead.Outreach_Type__c = 'TGL';
                        plead.Action__c = 'Accept - Promote to TGL';
                        
                        //Inserting Product Lead to a List.
                        prodctLeadsToBeInserted.add(Plead);
                    }
                }
            }
            
            //Product Lead to be insert - If new and update - if Exist.
            List<Product_Lead__c> productLeadToBeUpserted = new List<Product_Lead__c>();

            //Size check
            if(prodctLeadsExistingToBeUpdated.Size() > 0){
                
                //for loop on the Product Lead. 
                for(Product_Lead__c pL : prodctLeadsExistingToBeUpdated) {
                    
                    //Check the stage. 
                    //if the stage is AQL then update the stage with the TAL
                    //if stage is Inquiry then update the stage with the TGL
                    if(pL.Stage__c == 'AQL' || pL.Stage__c == 'Inquiry') {
                        
                        //If the stage is AQL.
                        if(pL.Stage__c == 'AQL') {
                            pL.Stage__c = 'TAL';
                            pL.Outreach_Type__c = 'TAL';
                            pL.Action__c = 'Accept - Promote to TAL';
                        }
                        
                        //If the stage is AQL.
                        if(pL.Stage__c == 'Inquiry') {
                            pL.Stage__c = 'TGL';
                            pL.Outreach_Type__c = 'TGL';
                            pL.Action__c = 'Accept - Promote to TGL';
                        }
                    }
                    //Adding the instance to the list
                    productLeadToBeUpserted.add(pL);
                }
            }
            
            //Checking for the size of List. 
            if(prodctLeadsToBeInserted.size() > 0 || productLeadToBeUpserted.size() > 0)  {

                if(prodctLeadsToBeInserted.size() > 0) {
               	 	productLeadToBeUpserted.addAll(prodctLeadsToBeInserted);
                }
                
                //Checking for the List size
                if(productLeadToBeUpserted.size() > 0)
               		upsert productLeadToBeUpserted;
                
               	//Loop on the Tasks.
             	for(Task t : [Select Id, Event_Type__c, Event_Purpose__c,  
                              Program__c, WhatId, WhoId, Product_Lead__c, Subject, 
                              SalesLoft1__SalesLoft_Step_Day__c, SalesLoft_External_ID__c,
                              SalesLoft1__SalesLoft_Type__c, SalesLoft1__SalesLoft_Email_Template_Title__c,
                              RecordTypeId From Task
                              Where Id IN: setTasksIds]) {
                                  
                      //Filling the Map. 
                      if(!mapContactsWithTasks.containsKey(t.WhoId)) 
                      	mapContactsWithTasks.put(t.WhoId, new List<Task>());
                      mapContactsWithTasks.get(t.WhoId).add(t);            
                }
                
                //Looping through the List of Products Leads
                for(Product_Lead__c pLd : productLeadToBeUpserted) {
                	
                	//Check if there is any tasks related to the COntact.
                	if(mapContactsWithTasks.containsKey(pLd.Contact__c) && mapContactsWithTasks.get(pLd.Contact__c) != null 
                       && mapContactsWithTasks.get(pLd.Contact__c).size() > 0) {
                		
                    	List<Task> tasks = mapContactsWithTasks.get(pLd.Contact__c);
                           
                           for(Task t : tasks) {
                               
                               //String for establishing our Identifier
                               String uniqueIdentifier = '';

                               //Check to see if External ID is populated, if not then use our Template Name
                               if(t.SalesLoft_External_ID__c != null){
                                   uniqueIdentifier = t.SalesLoft_External_ID__c;
                               } else {
                                   uniqueIdentifier = t.SalesLoft1__SalesLoft_Email_Template_Title__c.subStringBefore('_');
                               }
                               
                               //Check if Product Lead and Tasks acronyms are same. 
                               if(uniqueIdentifier == mapAcronymWithProgram.get(pLd.Program__c)) {
                        	      
                                   t.WhatId = pLd.Id;
                                   t.Product_Lead__c = pLd.Id;
                                   
                                   if(t.SalesLoft1__SalesLoft_Step_Day__c == 1)
                                   	t.Event_Purpose__c = 'Initial';
                                   else
                                    t.Event_Purpose__c = 'Follow Up'; 
                                   
                                   //Populataing Event Type.
                                   if(t.SalesLoft1__SalesLoft_Type__c == 'Email')
                                   	t.Event_Type__c = 'Email'; 	 
                                   
                                   if(t.SalesLoft1__SalesLoft_Type__c == 'Call')
                                   	t.Event_Type__c = 'Phone Call'; 	 
                                   
                                   if(t.SalesLoft1__SalesLoft_Type__c == 'Other')
                                   	t.Event_Type__c = 'Other'; 	 
                                   
                                   //Adding the Record type Information. 
                                   if(t.RecordTypeId != TASK_PT_MARKETING_RTYPE_ID)
                                       t.RecordTypeId = TASK_PT_MARKETING_RTYPE_ID;
                                   
                                   //Adding it to the List.
                                   taskToBeUpdated.add(t);
                             }
                        }
                    } 
                }
            }
        }
        
        //Updated by Dipesh Gupta - CR-20200406-13906 - Start here
        for(Task tsk : newTasks){
            if(tsk.WhoId != null && tsk.WhoId.getSObjectType() == Schema.Contact.SobjectType && tsk.SalesLoft_Initiated__c == true 
               && mapContactsWithTasks.size() == 0){
                System.debug('step1:::::::');
                Task t = new Task(Id = tsk.Id);
                
                if(tsk.SalesLoft1__SalesLoft_Step_Day__c == 1)
                    t.Event_Purpose__c = 'Initial';
                else
                    t.Event_Purpose__c = 'Follow Up'; 
                
                //Populataing Event Type.
                if(tsk.SalesLoft1__SalesLoft_Type__c == 'Email')
                    t.Event_Type__c = 'Email'; 	 
                
                if(tsk.SalesLoft1__SalesLoft_Type__c == 'Call')
                    t.Event_Type__c = 'Phone Call'; 	 
                
                if(tsk.SalesLoft1__SalesLoft_Type__c == 'Other')
                    t.Event_Type__c = 'Other'; 	 
                
                //Adding the Record type Information. 
                if(tsk.RecordTypeId != TASK_PT_MARKETING_RTYPE_ID)
                    t.RecordTypeId = TASK_PT_MARKETING_RTYPE_ID;
                
                taskToBeUpdated.add(t);
            }  
        }
        System.debug('taskToBeUpdated:::::::' +taskToBeUpdated);
        //Check the List size.
        if(taskToBeUpdated != null && taskToBeUpdated.size() > 0){
            Util.BYPassAlltriggers = true;
            update taskToBeUpdated;
            Util.BYPassAlltriggers = false;
        }
        //Updated by Dipesh Gupta - CR-20200406-13906 - Start here
    }
     /**
    * 
    *  @description    :   This method is used to update the product leads record which is parent to task
    *
    *  @args           :   List<Task> tasks, Map<Id, Task> mapOldTasks
    *
    *  @return         :   void
    *
    *  @revision Log   :   V_1.0 - Created - Abhinav sharma - CR-20181008-12647
    * 
    **/  
    
    public static void updateProductLead(List<Task> newTasks, Map<Id, Task> oldMapTasks) {
        
        //Set to hold the Product Lead Ids.
        set<Id> setProductLeadIds = new set<Id>();
        
            //Check for the Related To Field on tasks.
            for(Task t : newTasks != null ? newTasks : oldMapTasks.values() ) {
                
                if(oldMapTasks == null || (oldMapTasks != null && (oldMapTasks.get(t.Id).Status != t.Status 
                                                                   || oldMapTasks.get(t.Id).WhatId != t.WhatId )))
                
                //Check for the sObject type.
                if(t.WhatId != null && t.WhatId.getSObjectType() == Schema.Product_Lead__c.SobjectType) {
                    //set to hold the product lead Ids.
                    setProductLeadIds.add(t.WhatId);                
                }
                
                //Check for the case when previously we have other What id and updated as diff what id.
                if(oldMapTasks != null && oldMapTasks.get(t.Id).WhatId != t.WhatId) {
                    
                    //Check if the SObject Type is Product Lead.
                    if(oldMapTasks.get(t.Id).WhatId != null && oldMapTasks.get(t.Id).WhatId.getSObjectType() == Schema.Product_Lead__c.SobjectType)
                      setProductLeadIds.add(oldMapTasks.get(t.Id).WhatId);
                }
                
                //checking for the deletion object.                 
                if(oldMapTasks != null && newTasks == null) {
                    
                    //Check if the SObject Type is Product Lead.
                    if(oldMapTasks.get(t.Id).WhatId != null && oldMapTasks.get(t.Id).WhatId.getSObjectType() == Schema.Product_Lead__c.SobjectType)
                      setProductLeadIds.add(oldMapTasks.get(t.Id).WhatId);
                }
                
            }
            //Check the size of set. 
            if(setProductLeadIds.size() > 0)
                //Call method. 
                updateProductLead_OutReachInCycle(setProductLeadIds);
        
    }
    
    /**
    * 
    *  @description    :   This method is used to update the Product Leads Outreachin cycle 
    *                      (Task records count where status = completed and Task created Date > = Last Out Reach date on product lead)
    *
    *  @args           :   set<Id> productLeadIds
    *
    *  @return         :   void
    *
    *  @revision Log   :   V_1.0 - Created - Abhinav sharma - CR-20181008-12647
    * 
    **/
    
    public static void updateProductLead_OutReachInCycle(set<Id> setProductLeadIds){
                
        //map to hold the Product lead with the Completed Task count. 
        Map<Id, List<Task>> mapProductLeadWithCompletedTasks = new Map<Id, List<Task>>();
        
        //Check for the set size. 
        if(setProductLeadIds != null && setProductLeadIds.size() > 0) {
            
            //Map to hold the Product leads.
            Map<Id, Product_Lead__c> mapProductLeads = new Map<Id, Product_Lead__c> ([Select Id, Last_Outreach_Start__c From Product_Lead__c 
                                                                                      Where Id IN: setProductLeadIds]);
            
            //Loop on the Map of Product leads. 
            for(Id pLId : mapProductLeads.keyset()) {
                
                //Initializing the Product lead so each PL has 0 task in the initial. 
                mapProductLeadWithCompletedTasks.put(pLId, new List<Task>());
            }

            
            //Query on the task that is related to the Product Leads. 
            for(Task task : [Select Id, Status, CreatedDate, WhatId From 
                             Task Where WhatId =: setProductLeadIds AND Status = 'Completed' Order By WhatId]) {
                
                //Check for the task that meets the below creiteria.
                if(mapProductLeads != null && mapProductLeads.containsKey(task.WhatId)
                   && task.CreatedDate >= mapProductLeads.get(task.WhatId).Last_Outreach_Start__c) {
                        
                       //Filling the Map. 
                       if(mapProductLeadWithCompletedTasks.containsKey(task.WhatId)) 
                            mapProductLeadWithCompletedTasks.get(task.WhatId).add(task);
                }
            }
            
            //Loop on the Map. 
            if(mapProductLeadWithCompletedTasks != null && mapProductLeadWithCompletedTasks.size() > 0) {
                
                //Product Lead List. 
                List<Product_Lead__c> productLeadsToBeUpdated = new List<Product_Lead__c>();
                
                //loop on the map. 
                for(Id productLeadId : mapProductLeadWithCompletedTasks.keyset()) {
                    
                    productLeadsToBeUpdated.add(new Product_Lead__c(Id = productLeadId, 
                                                Outreach_In_Cycle__c = mapProductLeadWithCompletedTasks.get(productLeadId).size()));
                }
                
                //Bypassing the triggers.
                Util.ByPassAllTriggers = true; 
                update productLeadsToBeUpdated;
                util.ByPassAllTriggers = false;
            }
        }   
    }
    
    /**
     *  @description    :   Method to populate Related Type field on Task with object API name of record in WhatId
     *
     *  @args           :   List<Task>, Map<Id, Task>
     *
     *  @return         :   void
     * 
     *  @revision Log   :   V_1.0 - Created - By Mahendra Swarnkar - 02/14/2019 - CR-20190204-12863
     *
    **/
    public static void populateRelatedTypeField(List<Task> newtasks, Map<Id, Task> mapOldTasks) {
        
        //Loop over the new events
        for(Task task : newtasks) {
            
            //Check for conditions
            if(task.WhatId !=  null && (task.Related_Type__c == null || mapOldTasks == null || (mapOldTasks != null && task.WhatId != mapOldTasks.get(task.Id).WhatId))){
                
                //Populate the related Type on event
                task.Related_Type__c = task.WhatId.getsobjecttype().getDescribe().getName();
            }
        }
    }

    /**
     *  @description    :   Method to modify the Task record to match SalesLoft record type if it comes from SalesLoft
     *
     *  @args           :   List<Task>
     *
     *  @return         :   void
     * 
     *  @revision Log   :   V_1.0 - Created - By Colin McGloin - 04/25/2019 - CR-20190419-13016
     *                      V_1.1 - Modified By - Colin McGloin - 05/09/2019 - CR-20190501-13075
     *                      V_1.2 - Modified By - Colin McGloin - 07/03/2019 - CR-20190624-13193 - Modified logic so it checks for Cadences related to MS instead of MS ID on Contact
     * 						V_1.3 - Modified By - Colin McGloin - 07/03/2019 - CR-20190807-13258 - Added null check on SalesLoft1__SalesLoft_Cadence_Name__c field
     *                      V_1.4 - Modified By - Colin McGloin - 10/01/2019 - CR-20190924-13360 - Removed checks against the Membership field on the Related Contact
     *
    **/

    public static void saleloftTaskRelatedToContact (List<Task> newTasks) {

        //Set used for Contact Check
        Set<Id> contactCheck = new Set<Id>();

        //Map for checking Contacts later
        Map<Id, Contact> conIdToContact = new Map<Id, Contact>();
        
        //Map for Membership Logic method
        Map<Id, List<Task>> membershipRelatedTasks = new Map<Id, List<Task>>();
        
        //List for Opportunity/No Related Record Logic method
        List<Task> unRelatedTasks = new List<Task>();
        
        //Check for the Task fields which is related to the Sales Loft to get the program acronym. 
        for(Task tsk : newTasks){
            
            //check if the essential Contact fields are not blank and our SalesLoft criteria is met
            if(tsk.WhoId != null && tsk.WhoId.getSObjectType() == Schema.Contact.SobjectType && tsk.SalesLoft_Initiated__c == true) {

                //Grab our Contact record and pop into a Set for our Membership search
                contactCheck.add(tsk.WhoId);

            }

        }

        //Commented out by Colin McGloin - CR-20190924-13360
        //If we have records in the Map then proceed with the SOQL Query on Contact
        /*if (contactCheck.size() > 0){
                
                //Grab our fields to check from the Contact
                List<Contact> contactsToCheck = [SELECT Id, Salesloft_MembershipID__c 
                                                 FROM Contact
                                                 WHERE Id IN :contactCheck];

                //If we have records then run through List and add to Map
                if (contactsToCheck.size() > 0){
                    //Loop through our Contacts
                    for (Contact con : contactsToCheck){
                        //Add our Contact to our Map for use later
                        conIdToContact.put(con.Id, con);
                    }
                    
                }

        }*/

        //Loop through our  
        for(Task tsk : newTasks){
            
            //check if the essential Contact fields are not blank and our SalesLoft criteria is met
            if(tsk.WhoId != null && tsk.WhoId.getSObjectType() == Schema.Contact.SobjectType && tsk.SalesLoft_Initiated__c == true) {
                
                System.debug('# SalesLoft Cadence ' + tsk.SalesLoft1__SalesLoft_Cadence_Name__c);
                
                //Check to see if our Cadence field is populated and if it's a Membership related one
                if (tsk.SalesLoft1__SalesLoft_Cadence_Name__c != null){
                    if (tsk.SalesLoft1__SalesLoft_Cadence_Name__c.subStringBefore('_') != null){
                        if (tsk.SalesLoft1__SalesLoft_Cadence_Name__c.subStringBefore('_') == 'MS'){
                            
                            //Grab our Contact record and pop into a Map along with the Relevant Tasks
                            if (membershipRelatedTasks.get(tsk.WhoId) != null){
                                List<Task> existingTasks = membershipRelatedTasks.get(tsk.WhoId);
                                existingTasks.add(tsk);
                                membershipRelatedTasks.put(tsk.WhoId, existingTasks);
                            } else {
                                List<Task> existingTasks = new List<Task>();
                                existingTasks.add(tsk);
                                membershipRelatedTasks.put(tsk.WhoId, existingTasks);
                            }
                        }
                    }
                }
                
                //Commented out by Colin McGloin - CR-20190924-13360
                //Check to see if we have a Related Contact with a Membership ID
                /*if (conIdToContact.get(tsk.WhoId) != null){
                    System.debug('# Membership ID ' + conIdToContact.get(tsk.WhoId).Salesloft_MembershipID__c);
                    if (conIdToContact.get(tsk.WhoId).Salesloft_MembershipID__c != null) {
                        
                        //Grab our Contact record and pop into a Map along with the Relevant Tasks
                        if (membershipRelatedTasks.get(tsk.WhoId) != null){
                            List<Task> existingTasks = membershipRelatedTasks.get(tsk.WhoId);
                            existingTasks.add(tsk);
                            membershipRelatedTasks.put(tsk.WhoId, existingTasks);
                        } else {
                            List<Task> existingTasks = new List<Task>();
                            existingTasks.add(tsk);
                            membershipRelatedTasks.put(tsk.WhoId, existingTasks);
                        }
                    }
                }*/ 
                
                //If it was not entered into Membership logic, then submit to Unrelated List
                if (membershipRelatedTasks.get(tsk.WhoId) == null ||
                    membershipRelatedTasks.get(tsk.WhoId).contains(tsk) == false) {
                    System.debug('Entered If Statement');
                    //Add to our list for the Unrelated Task method
                    unRelatedTasks.add(tsk);
                }
            }
            
        }
            
        System.debug('# unrelatedTask Size: ' + unRelatedTasks.size());
        System.debug('# membershipRelatedTasks Size: ' + membershipRelatedTasks.size());
            
        //If we have unrelated records then pass along to our subsequent Methods
        if(unRelatedTasks.size() > 0){
            saleloftTaskNotRelatedToProductLead(unRelatedTasks);
        }
            
        //If we have Membership related records then pass along to our subsequent Method
        if(membershipRelatedTasks.size() > 0){
            saleloftTaskRelatedToMembership(membershipRelatedTasks);
        }

    }    
            
     /**
     *  @description    :   Method to modify the Task record to match SalesLoft record type if it comes from SalesLoft but is not linked to Membership or Product Lead
     * 						This is called from saleloftTaskRelatedToContact method once we do some pre-logic
     *
     *  @args           :   List<Task>
     *
     *  @return         :   void
     * 
     *  @revision Log   :   V_1.0 - Created - By Colin McGloin - 04/25/2019 - CR-20190419-13016
     *                      V_1.1 - Modified By - Colin McGloin - 05/09/2019 - CR-20190501-13075
     * 						V_1.2 - Modified By - Colin McGloin - 05/15/2019 - CR-20190507-13095
     *                      V_1.3 - Modified By - Colin McGloin - 10/01/2019 - CR-20190924-13360
     *
    **/
    
    public static void saleloftTaskNotRelatedToProductLead (List<Task> newTasks) {
        
        //Modified by Mahendra Swarnkar - 04/30/2020 - CR-20200129-13676 - Start Here
        //String to hold the Record Type 
        //String TASK_PT_MARKETING_RTYPE_ID = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Task PT Marketing').getRecordTypeId();
        String TASK_PT_MARKETING_RTYPE_ID = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Outreach').getRecordTypeId();
        //Modified by Mahendra Swarnkar - 04/30/2020 - CR-20200129-13676 - End Here
        
        //Loop through our records 
        for(Task tsk : newTasks){
            
            //Check to make sure it meets our criteria
            if(tsk.SalesLoft_External_ID__c == null && tsk.SalesLoft1__SalesLoft_Email_Template_Title__c == null){
                
                //Set our Event Purpose
                if(tsk.SalesLoft1__SalesLoft_Step_Day__c == 1)
                    tsk.Event_Purpose__c = 'Initial';
                else
                    tsk.Event_Purpose__c = 'Follow Up';
                
                //Populataing Event Type.
                if(tsk.SalesLoft1__SalesLoft_Type__c == 'Email')
                    tsk.Event_Type__c = 'Email'; 	 
                
                if(tsk.SalesLoft1__SalesLoft_Type__c == 'Call')
                    tsk.Event_Type__c = 'Phone Call'; 	 
                
                if(tsk.SalesLoft1__SalesLoft_Type__c == 'Other')
                    tsk.Event_Type__c = 'Other';
                
                //Adding the Record type Information
                if(tsk.RecordTypeId != TASK_PT_MARKETING_RTYPE_ID)
                    tsk.RecordTypeId = TASK_PT_MARKETING_RTYPE_ID;
                
                //Added by Colin McGloin - CR-20190501-13075
                //Check to see if the Related To record is an Opportunity and remove in this scenario
                if (tsk.WhatId != null){
                    if (tsk.WhatId.getSobjectType() == Schema.Opportunity.SObjectType){
                        tsk.WhatId = null;
                    }
                }

                //Commented By Neha  Sharma - CR-20200518-14064 - 01/04/2021
                //Added by Colin McGloin - CR-20190924-13360
                /*if (tsk.SalesLoft1__Call_Disposition__c != null){
                    String disposition = tsk.SalesLoft1__Call_Disposition__c;
                    disposition += '. Salesloft Unrelated';
                    tsk.SalesLoft1__Call_Disposition__c = disposition;
                } else {
                    tsk.SalesLoft1__Call_Disposition__c = 'Salesloft Unrelated';
                }*/

            }
            
        }
        
    }
    
    /**
     *  @description    :   Method to modify the Task record to set values and to link the record to a Membership record
     * 						This is called from saleloftTaskRelatedToContact method once we do some pre-logic
     *
     *  @args           :   List<Task>
     *
     *  @return         :   void
     * 
     *  @revision Log   :   V_1.0 - Created - By Colin McGloin - 05/15/2019 - CR-20190507-13095
     *                      V_1.1 - Modified By - Colin McGloin - 07/03/2019 - CR-20190624-13193 - Added Contact Query to method/Removed logic which clears out Membership ID on Contact
     *
    **/
    
    public static void saleloftTaskRelatedToMembership (Map<Id, List<Task>> mapContactTasks) {

        //Run a quick query for our Contact Information
        List<Contact> relevantContacts = [SELECT Id, Salesloft_MembershipID__c 
                                          FROM Contact
                                          WHERE Id IN :mapContactTasks.keyset()];
        
        //String to hold the Record Type 
        String TASK_RI_AM_RTYPE_ID = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Task RI AM').getRecordTypeId();

        //Double check our List is not Empty
        if (relevantContacts.size() > 0){
        
            //Loop through our Contacts and all Tasks
            for (Contact con : relevantContacts){
                
                //Check for the Task fields which is related to the Sales Loft to get the program acronym. 
                for(Task tsk : mapContactTasks.get(con.Id)){
                
                    //Set our Event Purpose
                    tsk.Event_Purpose__c = 'Meeting Recruitment';
                    
                    //Set our Related To record to the Membership
                    if (con.Salesloft_MembershipID__c != null)
                        tsk.WhatId = con.Salesloft_MembershipID__c;
                    
                    //Populataing Event Type.
                    if(tsk.SalesLoft1__SalesLoft_Type__c == 'Email')
                        tsk.Event_Type__c = 'Email'; 	 
                    
                    if(tsk.SalesLoft1__SalesLoft_Type__c == 'Call')
                        tsk.Event_Type__c = 'Phone Call'; 	 
                    
                    if(tsk.SalesLoft1__SalesLoft_Type__c == 'Other')
                        tsk.Event_Type__c = 'Other';
                    
                    //Adding the Record type Information
                    if(tsk.RecordTypeId != TASK_RI_AM_RTYPE_ID)
                        tsk.RecordTypeId = TASK_RI_AM_RTYPE_ID;
                    
                }
                
            }
        }
       
    }
    /*
     * @Description		: 	This method is used to create a Campaign Member record for the contact tagged in Product Lead 
     * 						that does'nt have a campaign member for the campaign that matches the SL Cadence name in task
     * 
     * @ Args			: 	List<Task> newtasks, Map<Id, Task> mapOldTasks
     * 
     * @ Return Type	: 	void
     * 
     * @ RevisionLog	:	V_1.0 - Created By - Dipesh Gupta - CR-20190703-13207 - 05/11/2019
	*/
    
    public static void createMembershipForContactTaggedInProductLead(List<Task> newtasks, Map<Id, Task> mapOldTasks)
    {
        // Chk if newtasks
        if(newtasks != null)
        {
            //Set to hold the Task Ids 
            Set<Id> setTaskIds = new Set<Id>();
            
            // Loop Over new task
            for(Task tsk : newtasks)
            {
                
                // Chk for SalesLoft1__SalesLoft_Cadence_Name__c 
                if(String.isNotBlank(tsk.SalesLoft1__SalesLoft_Cadence_Name__c))
                {
                    setTaskIds.add(tsk.Id);
                }
            }
            if(!setTaskIds.isEmpty())
            {
                System.enqueueJob(new Enqueue_CreateCMForPLContacts(setTaskIds));
            }
        }
    }
    
    /*
     * @Description		: 	This method is update task Record type if the Membership field is populate
     * 
     * @ Args			: 	List<Task> newtasks
     * 
     * @ Return Type	: 	void 
     * 
     * @ RevisionLog	:	V_1.0 - Created By - Dipesh Gupta - CR-20191115-13515 - 12/23/2019
	*/
    
    public static void updateTaskRTAsPerMembershipField(List<Task> newtasks)
    {
        
        //String to hold the Record Type 
        String TASK_RI_AM_RTYPE_ID = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Task RI AM').getRecordTypeId();
        
        //Loop over new Task list
        for(Task tsk : newtasks)
        {
            //What id null check 
            if(tsk.WhatId != null && tsk.SalesLoft_Initiated__c == true) 
            {
                
                //Check for Object
                if(tsk.WhatId.getSObjectType() == Schema.Membership__c.SobjectType)
                {
       
                    //Set our Event Purpose
                    tsk.Event_Purpose__c = 'Meeting Recruitment';
                    //Populataing Event Type.
                    if(tsk.SalesLoft1__SalesLoft_Type__c == 'Email')
                        tsk.Event_Type__c = 'Email'; 
                    if(tsk.SalesLoft1__SalesLoft_Type__c == 'Call')
                        tsk.Event_Type__c = 'Phone Call';  
                    if(tsk.SalesLoft1__SalesLoft_Type__c == 'Other')
                        tsk.Event_Type__c = 'Other';
                    //Adding the Record type Information
                    if(tsk.RecordTypeId != TASK_RI_AM_RTYPE_ID)
                        tsk.RecordTypeId = TASK_RI_AM_RTYPE_ID;
                }
            }
        }
    }
    
    /**
    * 
    *  @description    :   This method is used to update the Sales Invoice record 
    *
    *  @args           :   List<Task> tasks, Map<Id, Task> mapOldTasks
    *
    *  @return         :   void
    *
    *  @revision Log   :   V_1.0 - Created - Dipesh Gupta - CR-20191023-13455 -- updateSalesInvoice
    * 
    **/  
    
    public static void updateSalesInvoice(List<Task> newTasks, Map<Id, Task> oldMapTasks) {
        
        //Finance record type Id on Task Object
        Id fianceRTId = Util.RecordTypeId('Task', 'Finance');
            
        //Map to hold the sales Invoice. 
        Map<Id, c2g__codaInvoice__c> mapSalesInvoice = new Map<Id, c2g__codaInvoice__c>();
        c2g__codaInvoice__c salesInvoiceBlankInstance = new c2g__codaInvoice__c(Last_Follow_Up_Date__c = null, Last_Follow_Up_Note__c = null, 
                                                                                Grade__c = null, Grading_Notes__c = null, Follow_Up_Status__c = null,
                                                                               Follow_Up_Status_Notes__c = null);
        
        
        //Check for the Related To Field on tasks.
        for(Task t : newTasks != null ? newTasks : oldMapTasks.values() ) {
            
            
            //Check for the sObject type.
            if(t.WhatId != null && t.WhatId.getSObjectType() == Schema.c2g__codaInvoice__c.SobjectType) {
                
                //Check for insert Update case
                if(oldMapTasks == null || (oldMapTasks != null && (oldMapTasks.get(t.Id).ActivityDate != t.ActivityDate 
                                                                   || oldMapTasks.get(t.Id).Subject != t.Subject 
                                                                   || oldMapTasks.get(t.Id).Grade__c != t.Grade__c 
                                                                   || oldMapTasks.get(t.Id).CallDisposition != t.CallDisposition 
                                                                   || oldMapTasks.get(t.Id).Status__c != t.Status__c 
                                                                   || oldMapTasks.get(t.Id).Next_Steps__c != t.Next_Steps__c
                                                                   || oldMapTasks.get(t.Id).WhatId != t.WhatId
                                                                   || oldMapTasks.get(t.Id).RecordTypeId != t.RecordTypeId))){
                                                                       
                		//set to hold the task Ids.
                        if(oldMapTasks != null && oldMapTasks.get(t.Id).WhatId != t.WhatId )   {
                            salesInvoiceBlankInstance.Id = oldMapTasks.get(t.Id).WhatId; 
                            mapSalesInvoice.put(oldMapTasks.get(t.Id).WhatId, salesInvoiceBlankInstance);       
                            salesInvoiceBlankInstance = new c2g__codaInvoice__c();
                        }      
                           
                        salesInvoiceBlankInstance.Id = t.WhatId;                                               
                        mapSalesInvoice.put(t.WhatId, salesInvoiceBlankInstance);
                        salesInvoiceBlankInstance = new c2g__codaInvoice__c();  
                                               
                }
                
                //Check for delete case
                if(newTasks == null || oldMapTasks != null){
                    salesInvoiceBlankInstance.Id = oldMapTasks.get(t.Id).WhatId; 
                    mapSalesInvoice.put(oldMapTasks.get(t.Id).WhatId, salesInvoiceBlankInstance);       
                    salesInvoiceBlankInstance = new c2g__codaInvoice__c();
                }
            }
        }
        
        System.debug('mapSalesInvoice=-====='+mapSalesInvoice);
        
        if(!mapSalesInvoice.IsEmpty()){
            
            
            //Map of Sales Invoice with related latest Task
            Map<Id, Task> mapOfSalesInvoiceWithTasks  = new Map<Id, Task>(); 
            
            //Loop over Task
            for(Task t : [SELECT Id, WhatId, ActivityDate, Subject, Grade__c, CallDisposition, Status__c, Next_Steps__c 
                          FROM Task WHERE WhatId IN :mapSalesInvoice.keySet() AND RecordTypeId =: fianceRTId ORDER BY CreatedDate DESC]){

                //Contains check and putting values into Map - We only need the latest task so this should run for the first iteration to get the latest task.
                if(!mapOfSalesInvoiceWithTasks.containsKey(t.WhatId))
                    MapOfSalesInvoiceWithTasks.put(t.WhatId, t);
            }
            
            //Empty check on Map
            if(!mapSalesInvoice.IsEmpty()){
                
                //Loop Over key Set 
                for(c2g__codaInvoice__c salesInvoice : mapSalesInvoice.values()){
                    
                    //Check if map has the key. 
                    if(mapOfSalesInvoiceWithTasks.containsKey(salesInvoice.Id)) {
                    	
                        salesInvoice.Last_Follow_Up_Date__c	= mapOfSalesInvoiceWithTasks.get(salesInvoice.Id).ActivityDate;
                        salesInvoice.Last_Follow_Up_Note__c	= mapOfSalesInvoiceWithTasks.get(salesInvoice.Id).Subject;
                        salesInvoice.Grade__c	= mapOfSalesInvoiceWithTasks.get(salesInvoice.Id).Grade__c;
                        salesInvoice.Grading_Notes__c	= mapOfSalesInvoiceWithTasks.get(salesInvoice.Id).CallDisposition;
                        salesInvoice.Follow_Up_Status__c	= mapOfSalesInvoiceWithTasks.get(salesInvoice.Id).Status__c ;
                        salesInvoice.Follow_Up_Status_Notes__c	= mapOfSalesInvoiceWithTasks.get(salesInvoice.Id).Next_Steps__c;
                    }
                }
                
                 
                System.debug('mapSalesInvoice??????-====='+mapSalesInvoice);
                
                //Empty check on list which has to be update
                if(!mapSalesInvoice.IsEmpty()){
                    
                    //Bypassing the triggers.
                    Util.ByPassAllTriggers = true; 
                    update mapSalesInvoice.values();
                    util.ByPassAllTriggers = false;
                    
                }
            }
        }
    }
    
    /**
     *  @description    :   Method to update the contact field Protocoled? (Task PT marketing) .The value should be true if there is any upcoming Sales event 
     * 						records tagged to the contact, and then remain true for 14 days after the date of that event.
     * 						The checkbox should be reverted to false if there is no longer an event or task matching the above criteria.
     * 
     *  @args           :   List<Task>, Map<Id, Task>
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created - Mahendra Swarnkar - CR-20200122-13648. 
     **/
    public static void updateContactProtocoledField(List<Task> newTasks, Map<Id, Task> OldMapOfTasks) {
        
        //Modified by Mahendra Swarnkar - 04/30/2020 - CR-20200129-13676 - Start Here
        //Get Record Type
        //Id taskPTMarketingRecordType = Util.RecordTypeId('Task', 'Task PT Marketing');
        Id taskPTMarketingRecordType = Util.RecordTypeId('Task', 'Sales Outreach');
        //Modified by Mahendra Swarnkar - 04/30/2020 - CR-20200129-13676 - Start Here
    
        //List to update contact
        Map<Id, Contact> mapContactsToUpdate = new Map<Id, Contact>();
        
        //Set of Task Ids
        Set<Id> setTaskIds = new Set<Id>();
        
        for(Task tsk : newTasks){
           
            //check for insert and update case
            if(tsk.WhoId != null && tsk.WhoId.getSObjectType() == Contact.sObjectType && (tsk.RecordTypeId == taskPTMarketingRecordType) 
               && tsk.ActivityDate != null /*&& evnt.Who.Type == 'Contact'*/ 
               && (OldMapOfTasks == null  
               	|| (tsk.ActivityDate != OldMapOfTasks.get(tsk.Id).ActivityDate 
                ||  tsk.WhoId != OldMapOfTasks.get(tsk.Id).WhoId
                ||  tsk.Event_Type__c != OldMapOfTasks.get(tsk.Id).Event_Type__c
                ||  tsk.Event_Purpose__c != OldMapOfTasks.get(tsk.Id).Event_Purpose__c
                ||  tsk.Cancelled_Did_Not_Occur__c != OldMapOfTasks.get(tsk.Id).Cancelled_Did_Not_Occur__c ))) {
                
               //mapContactsToUpdate.put(tsk.WhoId, new Contact(Id = tsk.WhoId, Protocoled_Sales__c = false));
                	setTaskIds.add(tsk.Id);
                /*if(!System.isBatch()){
                    if(OldMapOfTasks != null && tsk.WhoId != OldMapOfTasks.get(tsk.Id).WhoId){
                        
                        mapContactsToUpdate.put(OldMapOfTasks.get(tsk.Id).WhoId, new Contact(Id = OldMapOfTasks.get(tsk.Id).WhoId,  Protocoled_Sales__c = false));
                    }
                }*/
            }  
        }

        if(setTaskIds.size() > 0){
            
            //Set of contact ids
            List<Id> contactIds = new List<Id>();
            
            //Loop over EventWhoRelation   
            for(TaskWhoRelation taskWhoRel: [SELECT RelationId, TaskId FROM TaskWhoRelation WHERE TaskId IN: setTaskIds ]){
                contactIds.add(taskWhoRel.RelationId);
            }
            
            if(contactIds.size() > 0){
                fututeUpdateContactProtocoledField(contactIds);
            }
        }
    }
    
    @future
    public static void fututeUpdateContactProtocoledField(List<Id> listContactIds) {
        
        Set<Id> contactIds = new Set<Id>();
        contactIds.addAll(listContactIds);
        
        if(contactIds.size() > 0){
            GenericEventTaskClass.genericUpdateContactProtocoledField(contactIds);
        }
    }
}