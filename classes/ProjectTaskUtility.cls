/**
 *  Description     :   Apex class to hold Utilities methods associated with pse (namespace) objects. 
 * 
 *  Created By      :   Colin McGloin  
 * 
 *  Created Date    :   
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20201218-14755
 *		    :	V_1.1 - Modified By - Colin McGloin - CR-20210120-14821 - 01/20/2020
 * 		
**/ 
public class ProjectTaskUtility {
    public static void normalizeTaskStructureForProject(Id projectId) {
        new ProjectTaskUtility().normalizeTaskStructureForProjectInternal(projectId);
    }
   
    private Map<String, pse__Project_Task__c> tasksByWbs = new Map<String, pse__Project_Task__c>();
    
    private ProjectTaskUtility() {}
    
    private void normalizeTaskStructureForProjectInternal(Id projectId) {
         List<pse__Project_Task__c> tasks = [
            SELECT  	pse__Order__c,
                    	pse__Hierarchy_Depth__c,
                    	WBS_External_Source__c
            FROM    	pse__Project_Task__c
            WHERE   	pse__Project__c = :projectId
            ORDER BY 	pse__Hierarchy_Depth__c DESC
        ];
        
        // This needs to be a two-step process.
        // We first need to map each task by their respective WBS number, so that each task can easily refer back to it's parent. We'll set the peer order and hierarchy depth at the same time.
        // We then circle back around a second time to assign them their parents.
        
        // Step 1 - Cache up the tasks by their WBS, and set peer order/depth
        for (pse__Project_Task__c task : tasks) {
            normalizeDepthAndPeerOrderForTask(task);
        }
        
        // Step 2 - Re-visit the tasks that were assigned a depth and peer order, then see if we can resolve their parent/top level tasks.
        for (pse__Project_Task__c task : tasks) {
            normalizeParentForTask(task);
        }
        
        update tasks;
    }
    
    private void normalizeDepthAndPeerOrderForTask(pse__Project_Task__c task) {
        String wbs = task.WBS_External_Source__c;
        if (String.isBlank(wbs))
            return;
        List<String> parts = wbs.split('\\.');
        
        if (parts.size() < 1)
            return;
        Integer depth = parts.size() - 1;
        Integer order = -1;
        try {
            String lastPart = parts[parts.size() - 1];
            order = Integer.valueOf(lastPart);
        } catch (Exception e) {
            return;
        }
        
        task.pse__Order__c = order;
        task.pse__Hierarchy_Depth__c = depth;
        tasksByWbs.put(wbs, task);
    }
    
    private void normalizeParentForTask(pse__Project_Task__c task) {
        
        List<String> parts = new List<String>();
        
        if (task.WBS_External_Source__c != null){
            String wbs = task.WBS_External_Source__c;
            
            parts = wbs.split('\\.');
            
            if (parts.size() < 2)
            return;
            
        } else {
            return;
        }
        
        if (parts.size() == 0){
            return;
        }
        
        List<String> parentParts = new List<String>(parts);
        
        // Pluck the last element of the WBS number to get the parent WBS.
        parentParts.remove(parentParts.size() - 1);
        
        String parentWbs = String.join(parentParts, '.');
        String topLevelWbs = parentParts[0];
        pse__Project_Task__c parentTask = tasksByWbs.get(parentWbs);
        pse__Project_Task__c topLevelParentTask = tasksByWbs.get(topLevelWbs);
        
        if (parentTask != null)
            task.pse__Parent_Task__c = parentTask.Id;
        
        if (topLevelParentTask != null)
            task.pse__Top_level_Parent_Task__c = topLevelParentTask.Id;
    }
}