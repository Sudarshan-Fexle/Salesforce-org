/**
 *  Purpose         :   Helper class for Review call trigger
 *
 *  Created By      :   Neha Sharma
 *
 *  Created Date    :   11/6/2020
 *
 *  Revision Logs   :   V_1.0 - Created By - Neha Sharma - CR-20201029-14646
 *        
 * */
public class ReviewCallTriggerHelper {

    public static void CreateActionPlan(List<Review_Call__c> newReviewCallList, Map<Id,Review_Call__c> oldMapReviewCall){
        List<Task> taskList = new List<Task>();  
        Map<Id,Review_Call__c> mapOfReviewCall = new Map<Id,Review_Call__c>();

        for (Review_Call__c reviewCall : newReviewCallList)
        {
            if(reviewCall.Renewal_Issue_Identified__c && (oldMapReviewCall ==  null || (oldMapReviewCall != null && oldMapReviewCall.get(reviewCall.Id).Renewal_Issue_Identified__c != reviewCall.Renewal_Issue_Identified__c)))
            {
                if(reviewCall.Membership__c != null)
                {   
                	mapOfReviewCall.put(reviewCall.Membership__c,reviewCall);
                }
            }
        }
        
         // Check to see if any existing Action Plans are still incomplete for this account. If there is an active Action Plan, do not create another one. 
         // If there are no Action Plans for this account or if there are and they are completed, go ahead and create another one.
        if(mapOfReviewCall.size() > 0){
            for(Membership__c mem : [Select Id,(SELECT Id FROM Tasks WHERE RecordTypeId =: constants.RECORD_TYPE_ID_ACTION_PLANS
                                                       AND status != 'Completed') 
                                                       from Membership__c where Id In: mapOfReviewCall.keyset()])
            {
                if((mem.Tasks).size() == 0 )
                {

                  taskList.add(new Task(RecordTypeId = Constants.RECORD_TYPE_ID_ACTION_PLANS ,WhatId = mem.Id,Priority = 'Urgent', 
                                        subject = mapOfReviewCall.get(mem.Id).Renewal_Issue_Reason__c, 
                                        Event_Purpose__c = mapOfReviewCall.get(mem.Id).Renewal_Issue_Reason__c,
										Description = mapOfReviewCall.get(mem.Id).Renewal_Issue_Description__c));  
                }     
            } 
        }
                 
        if (taskList.size() > 0 ) {                                 
           insert taskList;
        }
    }
}