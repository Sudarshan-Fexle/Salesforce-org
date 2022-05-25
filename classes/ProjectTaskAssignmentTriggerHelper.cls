/**
 *  Description     :   Helper Class for the trigger "Trigger_ProjectTaskAssignment"
 * 
 *  Created By      :   Mahendra Swarnkar
 * 
 *  Created Date    :   11/04/2020
 * 
 *  Revision Logs   :   V1.0 - Created - CR-20201020-14618
 * 
 **/
public class ProjectTaskAssignmentTriggerHelper {

    /**
     * 
     *  @description    :   This method is used to create the Assignment record for related Resource for relatd Project if there is not already exist.
     *
     *  @args           :   List<pse__Project_Task_Assignment__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 11/04/2020 - Mahendra Swarnkar - CR-20201020-14618
     *                      V_1.1 - Modified - 03/11/2021 - Colin McGloin - CR-20210311-14989 - Duplicates being created if multiple PTAs created in one transaction
     * 
    **/
    public static void createAssignmentForResourceProject(List<pse__Project_Task_Assignment__c> projectTaskAssignments, map<Id, pse__Project_Task_Assignment__c> oldprojectTaskAssignmentMap) {
        
        //set to hold the resource Ids
        Set<Id> setResourceIds = new Set<Id>();
        
        //Set to Hold the Project Ids
        Set<Id> setProjectIds = new Set<Id>();
        
        //Map to hold the Project Assignment Id as a key and a string key (pse__Resource__c-pse__Project_ID__c) as a value
        Map<Id,String> mapProjectTaskAssignmentWithKey = new Map<Id,String>();
        
        // new Project_Task_Assignment map
        Map<Id, pse__Project_Task_Assignment__c> mapNewProjectTaskAssignments = new Map<Id, pse__Project_Task_Assignment__c>(projectTaskAssignments);
        //mapNewProjectTaskAssignments.putAll(projectTaskAssignments);
        
        for(pse__Project_Task_Assignment__c pta : projectTaskAssignments) {
            
            //Check for conditions
            if(oldprojectTaskAssignmentMap == null || pta.pse__Resource__c != oldprojectTaskAssignmentMap.get(pta.Id).pse__Resource__c 
               ||  pta.pse__Project_Task__c != oldprojectTaskAssignmentMap.get(pta.Id).pse__Project_Task__c){
            	
                // Check for resource & populate the resource set
		if(pta.pse__Resource__c != null)
                	setResourceIds.add(pta.pse__Resource__c);
                
                // Check for Project & populate the project set
                if(pta.pse__Project_ID__c != null)
                	setProjectIds.add(pta.pse__Project_ID__c);
                   
                //Populate the Map
                if(pta.pse__Resource__c != null && pta.pse__Project_ID__c != null)
                    mapProjectTaskAssignmentWithKey.put(pta.Id, (pta.pse__Resource__c + '-' + pta.pse__Project_ID__c));
            }
        }
        
        //chek for size
        if(setResourceIds.size() > 0 && setProjectIds.size() > 0){
            
            //Map to hold a string key (pse__Resource__c-pse__Project_ID__c) as a key and list of Assignments as a value
            Map<String,List<pse__Assignment__c>> mapUniqueKeyWithAssignments = new Map<String,List<pse__Assignment__c>>();
            
            //Query over the Assignment records
            for(pse__Assignment__c assignment : [Select Id, pse__Project__c, pse__Resource__c from pse__Assignment__c where pse__Project__c != null AND pse__Project__c IN : setProjectIds AND pse__Resource__c != null AND pse__Resource__c IN : setResourceIds ]){
                
                //Check for conditions
                if(assignment.pse__Project__c != null && assignment.pse__Resource__c != null ) {

                    //Cut our Project ID down to 15 digit ID
                    String projID = String.valueOf(assignment.pse__Project__c).left(15);
                    
                    //Unique key
                    String key = assignment.pse__Resource__c + '-' + projID;
                    system.debug('key' + key);
                    
                    //populate the map mapUniqueKeyWithAssignments
                    if(!mapUniqueKeyWithAssignments.containsKey(key))
                    	mapUniqueKeyWithAssignments.put(key, new List<pse__Assignment__c>());
                   
                    mapUniqueKeyWithAssignments.get(key).add(assignment); 
                }
            }
            
            //Chekc for size
            if(mapProjectTaskAssignmentWithKey.size() > 0){
            	
                //Map to hold the PTA Id as key and schedule to be inserted
                Map<Id, pse__Schedule__c> mapProjectTaskAssignmentWithScheduleToInsert = new Map<Id, pse__Schedule__c>();
                
                //Map to hold the PTA Id as key and Assignment to be inserted
                Map<Id, pse__Assignment__c> mapProjectTaskAssignmentWithAssignmentToInsert = new Map<Id, pse__Assignment__c>();
                 
                for(Id projTaskAssignId : mapProjectTaskAssignmentWithKey.keySet()) {
                    
                    //check for the unique key
                    if(String.isNotBlank(mapProjectTaskAssignmentWithKey.get(projTaskAssignId))){
                        
                        //get the unique key
                        String uniqueKey = mapProjectTaskAssignmentWithKey.get(projTaskAssignId);
                        System.debug ('find key: ' + uniqueKey);
                        
                        //Check if project and resource is already having the Assignment. if yes, then do nothing
                        if(mapUniqueKeyWithAssignments.size() > 0 && mapUniqueKeyWithAssignments.containsKey(uniqueKey) 
                           	&& mapUniqueKeyWithAssignments.get(uniqueKey) != null && mapUniqueKeyWithAssignments.get(uniqueKey).size() > 0 )
                            continue;
                        
                        System.debug ('Create Logic Entered');
                        System.debug ('Map Contains Unique Key: ' + mapUniqueKeyWithAssignments.containsKey(uniqueKey));
                        if (mapUniqueKeyWithAssignments.get(uniqueKey) != null){
                            System.debug ('Assignments for Unique Key: ' + mapUniqueKeyWithAssignments.get(uniqueKey).size());
                        }
                        
                        //Create the Schedule record
			pse__Schedule__c sched = new pse__Schedule__c( pse__Start_Date__c = mapNewProjectTaskAssignments.get(projTaskAssignId).pse__Project_Task_Start_Date__c, 
                                                                       pse__End_Date__c = mapNewProjectTaskAssignments.get(projTaskAssignId).pse__Project_Task_End_Date__c, 
                                                                       pse__Action_Force_Schedule_Refresh__c = true);    
                        
                        mapProjectTaskAssignmentWithScheduleToInsert.put(projTaskAssignId, sched);
                        
                        //Create the Assignment record
			pse__Assignment__c assign = new pse__Assignment__c( Name = 'Will Auto-Populate', pse__Schedule__c = null, pse__Status__c = 'Scheduled',
                                                                            pse__Bill_Rate__c = 0.00, pse__Is_Billable__c = false, Budgeted_Hours_Assignment__c = 0.00,  
                                                                            pse__Resource__c = mapNewProjectTaskAssignments.get(projTaskAssignId).pse__Resource__c,
                                                                            pse__Project__c = mapNewProjectTaskAssignments.get(projTaskAssignId).pse__Project_ID__c,
                                                                            //Added by Colin McGloin
                                                                            pse__Role__c = 'Auto-Generated');    
                        
                        mapProjectTaskAssignmentWithAssignmentToInsert.put(projTaskAssignId, assign);

                        //Added by Colin McGloin - CR-20210311-14989
                        //Add the Key and the Assignment to the Map so that duplicates are not created in the single transaction if multiple new PTA's with same Resources are created at once
                        List<pse__Assignment__c> assignments = new List<pse__Assignment__c>{assign};
                        mapUniqueKeyWithAssignments.put(uniqueKey, assignments);

                    }     
                }
                
                //Check for size
                if(mapProjectTaskAssignmentWithScheduleToInsert.size() > 0 
                   	&& mapProjectTaskAssignmentWithScheduleToInsert.values() != null 
                    && mapProjectTaskAssignmentWithScheduleToInsert.values().size() > 0) 
                {
                    //insert the schedule records
                    insert mapProjectTaskAssignmentWithScheduleToInsert.values();
                    
		    for(Id pTAId : mapProjectTaskAssignmentWithScheduleToInsert.keySet()) {
                        
                        //Populate the Schedule field value on the related Assignment to be inserted
                        if(mapProjectTaskAssignmentWithScheduleToInsert.get(pTAId).Id != null 
                           	&& mapProjectTaskAssignmentWithAssignmentToInsert.containsKey(pTAId)
                          	&& mapProjectTaskAssignmentWithAssignmentToInsert.get(pTAId) != null)
                            
			    mapProjectTaskAssignmentWithAssignmentToInsert.get(pTAId).pse__Schedule__c = mapProjectTaskAssignmentWithScheduleToInsert.get(pTAId).Id;
                    }
                    
                    //Insert the Assignment records.
                    if(mapProjectTaskAssignmentWithAssignmentToInsert.size() > 0 
                       	&& mapProjectTaskAssignmentWithAssignmentToInsert.values() != null 
                        && mapProjectTaskAssignmentWithAssignmentToInsert.values().size() > 0 )
                    {
		    	insert mapProjectTaskAssignmentWithAssignmentToInsert.values();
		    }
                }
            }
        }
    }
}