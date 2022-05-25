/**
*  Purpose         :   Batch class is used to update the Opportunity Initial Visit Date.
*
*  Created By      :   Dipesh Gupta
*
*  Created Date    :   10/04/2019
*
*  Revision Logs   :   V_1.0 - Created  - CR-20190429-13049
*                     
**/
global class Batch_InitialVisitDateUpdate implements Database.Batchable<sObject>{
    
    
    //Start Method 
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id, WhatId from Event WHERE WhatId != null AND WhatId IN (SELECT Id FROM Opportunity)';
                query+=' AND Cancelled_Did_Not_Occur__c = false AND (Event_Type__c =\'' +Constants.EVENT_TYPE_OPPORTUNITY_VISIT_FOR_OPPORTUNITY_GOAL+'\'' ; 
                query+=' OR (Event_Type__c = \''+Constants.EVENT_TYPE_IN_PERSON_VISIT+'\'  AND(Event_Purpose__c =\''+Constants.EVENT_PURPOSE_INITIAL+'\' OR Event_Purpose__c =\'' +Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT+'\'';
                query+=')) OR Event_Type__c = \''+Constants.EVENT_TYPE_PROSPECT_MEETING_ATTENDEE_COUNT_AS_VISIT+'\')';
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext BC, List<Event> scope){
        
        //Create a list of opportunities to be updated  
        Map<Id, Opportunity> mapOpportunitiesToBeUpdated = new Map<Id, Opportunity>();
       
        // Loop thru events and build Map of Opportunity
        for(Event evnt : scope){
            
            //Blank Check if blank then nothing happen. 
            if(String.isNotBlank(evnt.WhatId)) {
                
                //Check the What Id SObjectType. 
                if(evnt.WhatId.getSObjectType() == Schema.Opportunity.sObjectType)
                    mapOpportunitiesToBeUpdated.put(evnt.whatId, new Opportunity(Id = evnt.whatId));
            }
        }
        
        //Copy mapOpportunitiesToBeUpdated map to OpportunityTriggerUtilities opportunities
        OpportunityTriggerUtilities.opportunities = mapOpportunitiesToBeUpdated;
        //Update the list of opportunities
        if(OpportunityTriggerUtilities.opportunities.size() > 0) {
            
            //call the helper class method to update the Initial data
            OpportunityTriggerUtilities.updateInitialVisitDateByEventDate(OpportunityTriggerUtilities.opportunities);
            System.debug('Data To Be Update ---->>>'+OpportunityTriggerUtilities.opportunities.values());
            
            //Update Opportunities
            Database.update(OpportunityTriggerUtilities.opportunities.values(),false);
        }        
    }
    
    global void finish(Database.BatchableContext BC){
        
        //Query over apex Job to get the status and number of  failures.
        AsyncApexJob aJob = [Select Id, Status,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String[] toAddresses = new String[] {aJob.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Batch is ' + aJob.Status);
        mail.setPlainTextBody('Records processed ' + aJob.TotalJobItems +   'with '+ aJob.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
}