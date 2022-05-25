/**
 *  Purpose         :   Helper class for teh Trigger Event
 *
 *  Created By      :   
 *
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.1 - Modified By - Neha Sharma - 09/02/2021 - CR-20210804-15331 - On mass edit error occurs : Too many SOQL queries
 **/
public with sharing class ProjectTaskTriggerHelper {

    //Added By - Neha Sharma - 09/02/2021 - CR-20210804-15331 - On mass edit error occurs : Too many SOQL queries
    public static Boolean bypassCalculateTaskCompletion = false;
    public static Boolean bypassCalculateHoursCompleteToProjectRollup = false;
    
    public static void calculateTaskCompletion (List<pse__Project_Task__c> newProjTasks, Map<Id, pse__Project_Task__c> oldProjTasks){
		
        //Added By - Neha Sharma - 09/02/2021 - CR-20210804-15331 - On mass edit error occurs : Too many SOQL queries
        if(bypassCalculateTaskCompletion) return;
        
        List<Id> parentIds = new List<Id>();

        //Map for Associating Parent Completion Value with Parent Task ID
        Map<Id, Decimal> mapParentTaskToCompletionPercent = new Map<Id, Decimal>();

        //Map of Records to Update
        Map<Id, pse__Project_Task__c> mapIdToProjectTasks = new Map<Id, pse__Project_Task__c>();

        //Loop through our Project Tasks
        for (pse__Project_Task__c pTask : newProjTasks){

            if (pTask.pse__Parent_Task__c != null && pTask.Task_Completion__c != null &&
            (oldProjTasks == null || oldProjTasks.get(pTask.Id).pse__Parent_Task__c != pTask.pse__Parent_Task__c || oldProjTasks.get(pTask.Id).Task_Completion__c != pTask.Task_Completion__c)){

                //Add the Parent Task to the List for our Aggregate Result Query
                parentIds.add(pTask.pse__Parent_Task__c);

            } else if (pTask.pse__Parent_Task__c == null && pTask.Parent_Task_Completion__c != null) {
                //We want to set the Parent Task Completion to null instead of 0% if there are no Parent Tasks associated
                mapParentTaskToCompletionPercent.put(pTask.Id, null);
            }

        }

        if (parentIds.size() > 0){

            for (AggregateResult projTask : [SELECT Count(Id) countId, pse__Parent_Task__c parentId, SUM (Task_Completion__c) taskCompletion
                                                        FROM pse__Project_Task__c
                                                        WHERE pse__Parent_Task__c IN :parentIds
                                                        GROUP BY pse__Parent_Task__c]){

                                                            //Getting count values from Aggregate result
                                                            Integer totalCount = (Integer) projTask.get('countId');

                                                            //Getting Task Completion Value
                                                            Decimal totalCompletionPercent = (Decimal) projTask.get('taskCompletion');

                                                            //Getting ParentId from aggregate result
                                                            String parentId = String.valueOf(projTask.get('parentId'));

                                                            //Check to see we do not have more than 100 per task
                                                            if ((totalCount != null || totalCount == 0) && (totalCompletionPercent != null)){
                                                                if (totalCompletionPercent > (totalCount * 100)){
                                                                    totalCompletionPercent = totalCount * 100;
                                                                }
                                                            }

                                                            //Calculate Parent Completion 
                                                            Decimal parentCompletionPercent = (totalCompletionPercent/totalCount);

                                                            //Add record to the Map
                                                            mapParentTaskToCompletionPercent.put(parentId, parentCompletionPercent);
                                        
                                                        }

        }

        //Check for Parent Values to Update
        if (mapParentTaskToCompletionPercent.keyset().size() > 0){

            //Query for all our Parent Project Task records
            for (pse__Project_Task__c parentTask : [SELECT Id, Task_Completion__c, Parent_Task_Completion__c FROM pse__Project_Task__c WHERE Id IN :mapParentTaskToCompletionPercent.keyset()]){

                if (mapParentTaskToCompletionPercent.get(parentTask.Id) != null){

                    Decimal parentTaskComp = mapParentTaskToCompletionPercent.get(parentTask.Id);
                    parentTask.Parent_Task_Completion__c = parentTaskComp;
                    parentTask.Task_Completion__c = null;

                    //Check our Map for the record
                    if (mapIdToProjectTasks.get(parentTask.Id) != null){
                        pse__Project_Task__c pTask = mapIdToProjectTasks.get(parentTask.Id);
                        pTask.Parent_Task_Completion__c = parentTask.Parent_Task_Completion__c;
                        mapIdToProjectTasks.put(pTask.Id, pTask);
                    } else {
                        mapIdToProjectTasks.put(parentTask.Id, parentTask);
                    }

                } else {

                    //Set our Parent Task Completion to Null
                    parentTask.Parent_Task_Completion__c = null;

                    //Check our Map for the record
                    if (mapIdToProjectTasks.get(parentTask.Id) != null){
                        pse__Project_Task__c pTask = mapIdToProjectTasks.get(parentTask.Id);
                        pTask.Parent_Task_Completion__c = parentTask.Parent_Task_Completion__c;
                        mapIdToProjectTasks.put(pTask.Id, pTask);
                    } else {
                        mapIdToProjectTasks.put(parentTask.Id, parentTask);
                    }

                }

            }

        }

        //if we have records to update
        if (mapIdToProjectTasks.values().size() > 0){
            //Added By - Neha Sharma - 09/02/2021 - CR-20210804-15331 - On mass edit error occurs : Too many SOQL queries
            bypassCalculateTaskCompletion = true;
            update mapIdToProjectTasks.values();
        }

    }

    public static void calculateHoursCompleteToProjectRollup (List<pse__Project_Task__c> newProjTasks, Map<Id, pse__Project_Task__c> oldProjTasks) {

        //Added By - Neha Sharma - 09/02/2021 - CR-20210804-15331 - On mass edit error occurs : Too many SOQL queries
        if(bypassCalculateHoursCompleteToProjectRollup) return;
        
        //List of Project Ids
        List<Id> parentIds = new List<Id>();

        //Projects to Update
        List<pse__Proj__c> projsToUpdate = new List<pse__Proj__c>();

        //Loop through our Project Tasks
        for (pse__Project_Task__c pTask : newProjTasks){

            if (pTask.pse__Project__c != null && pTask.Task_Completion__c != null &&
            (oldProjTasks == null || oldProjTasks.get(pTask.Id).pse__Project__c != pTask.pse__Project__c || oldProjTasks.get(pTask.Id).Task_Completion__c != pTask.Task_Completion__c)){

                //Add the Parent Task to the List for our Aggregate Result Query
                parentIds.add(pTask.pse__Project__c);

            }

        }

        if (parentIds.size() > 0){

            for (AggregateResult projTask : [SELECT Count(Id) countId, pse__Project__c parentId, SUM (Task_Completion_Estimated_Hours__c) taskCompletionHours
                                                        FROM pse__Project_Task__c
                                                        WHERE pse__Project__c IN :parentIds
                                                        GROUP BY pse__Project__c]){

                                                            //Getting Task Completion Value
                                                            Decimal totalCompletionHours = (Decimal) projTask.get('taskCompletionHours');

                                                            //Getting ProjectID from aggregate result
                                                            Id parentId = Id.valueOf(String.valueOf(projTask.get('parentId')));

                                                            //Set the Hours at the Project level
                                                            pse__Proj__c projectRecord = new pse__Proj__c(Id = parentId, Completed_Hours_Project_Task__c = totalCompletionHours);
                                                            projsToUpdate.add(projectRecord);

            }

        }

        //Check to see if we have Projects to update
        if (parentIds.size() > 0){
            //Added By - Neha Sharma - 09/02/2021 - CR-20210804-15331 - On mass edit error occurs : Too many SOQL queries
            bypassCalculateHoursCompleteToProjectRollup = true;
            update projsToUpdate;
        }

    }

}