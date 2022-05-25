/*
    Purpose         :   This class is the helper class for CR Action Item trigger
                
    Create By       :   The Advisory Board Company
    
    Created Date    :   31/03/16
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created - Jason Bennett - 03/31/16
						V_1.1 Modified By - Mahendra Swarnkar - 07/04/2017 - Added a new Method "beforeEventLogic"
						V_1.2 Modified by - Saurabh Kumar - 09/08/2017 - CR-20170907-11182 - A new method is added "rollupFieldsOnROllup"
                        
*/
public class CRActionItemTriggerHelper {
        
	/** 
     * description 
     *              : This method returns a list of SFDC Change Request Ids for a given list of CR Action Items, based on 
     * 					the hierarchy at a given starting parent field
     * 					for example:  'ISMod' => CR_Action_Item__c.IS_System_Modification__c.Change_Request__c
     * @param - 1) list of CR Action Items
     *              : List of CR Action Items currently in context
     * 			2) string parent
     * 				: Valid options =>
     * 					a.  ISMod - hierarchy starting at CR_Action_Item__c.IS_System_Modification__c.Change_Request__c
     * 					c.	ActionItem - hierarchy starting at CR_Action_Item__c.Change_Request__c
     * @return 
     *              : List of SFDC Change Request Ids
     */
    public static Set<Id> getParentChangeRequestIds(List<CR_Action_Item__c> actions, string parent) {

        //Create empty sets to hold the Ids
        Set<Id> crIds = new Set<Id>();
        Set<Id> craIds = new Set<Id>();
        
        //Get the Ids for the CR Action Item records, which will be used in a SOQL query
        for(CR_Action_Item__c a : actions){
            craIds.add(a.Id);
        }
        system.debug('CRActionItemTriggerHelper.getParentChangeRequestIds - craIds: ' + craIds);

        //Run a query to get the requested Id fields
        List<CR_Action_Item__c> craParentIds = new list<CR_Action_Item__c>(
            [SELECT IS_System_Modification__r.Change_Request__c,
             		Change_Request__c
             FROM CR_Action_Item__c 
             WHERE Id in :craIds]);
                
        //Loop through the query results to get the requested Change Request Ids
        for(CR_Action_Item__c c : craParentIds){
            if(parent == 'ISMod'){
                system.debug('CRActionItemTriggerHelper.getParentChangeRequestIds - c.IS_System_Modification__r.Change_Request__c: ' + c.IS_System_Modification__r.Change_Request__c);
            	if(c.IS_System_Modification__r.Change_Request__c != null){
                	crIds.add(c.IS_System_Modification__r.Change_Request__c);
            	}
            }else if(parent == 'ActionItem'){
                system.debug('CRActionItemTriggerHelper.getParentChangeRequestIds - c.Change_Request__c: '+ c.Change_Request__c);
                if(c.Change_Request__c != null){
                	crIds.add(c.Change_Request__c);
            	}
        	}
        }
        system.debug('CRActionItemTriggerHelper.getParentChangeRequestIds - crIds: ' + crIds);
        
        return crIds;
    }
	
    /**
    *  @description     :	Method to have following logic:-
    * 						a) if all the manual steps has been complete/performed in the
    * 						   production (Check "Step Complete in Production = true" on
    * 						   CR action Items), then set below field values on the
    * 						   CR Status = Deployed and Stage = Complete.
    * 						b) if there is at least a manual steps exist which is still not complete/performed 
    * 						   in the production (Check "Step Complete in Production = false" on CR action Items) 
    * 						   on the CR, then set below field values on the CR
							   Status = Deployed and Stage = Pending manual steps.
    *
    *  @args           :   List<CR_Action_Item__c> actions, Map<Id, CR_Action_Item__c>
    *
    *  @return         :   void
    *
    *  @revision Log   :   V_1.0 - Dipesh Gupta - 11/14/2019 - CR-20191018-13439
    * 
    **/
    public static void validateAndUpdateCRStatus(List<CR_Action_Item__c> newCRActionItems, Map<Id, CR_Action_Item__c> oldMapCrActionItems)
    {
        //Create empty sets to hold the Ids
        Set<Id> setOfCrIds = new Set<Id>();
        
        List<SFDC_Change_Request__c> crToUpdate = new List<SFDC_Change_Request__c>();
        
        for(CR_Action_Item__c crActItem : newCRActionItems)
        {
            if(newCRActionItems!= null && oldMapCrActionItems!= null
               && (crActItem.Action_Item_Status__c != oldMapCrActionItems.get(crActItem.Id).Action_Item_Status__c
                   || crActItem.Step_Complete_in_Production__c != oldMapCrActionItems.get(crActItem.Id).Step_Complete_in_Production__c
                   || crActItem.IS_System_Modification__c != oldMapCrActionItems.get(crActItem.Id).IS_System_Modification__c
                   || crActItem.Change_Request__c != oldMapCrActionItems.get(crActItem.Id).Change_Request__c))
            {
                if(crActItem.Change_Request__c != null) 
                {
                    setOfCrIds.add(crActItem.Change_Request__c);
                }
                if(oldMapCrActionItems.get(crActItem.Id).Change_Request__c != null) 
                {
                    setOfCrIds.add(oldMapCrActionItems.get(crActItem.Id).Change_Request__c);
                }
            }
            else
            {
                if(crActItem.Change_Request__c != null) 
                {
                    setOfCrIds.add(crActItem.Change_Request__c);
                }
            }
        }
        if(setOfCrIds.size()>0)
        {
            for(id crIds:setOfCrIds)
            {
                List<CR_Action_Item__c> crActionItems = [SELECT Id, Step_Complete_in_Production__c, Change_Request__c, IS_System_Modification__c,
                                                         Change_Request__r.Status__c, Change_Request__r.Stage__c, Action_Item_Status__c
                                                         FROM CR_Action_Item__c
                                                         WHERE Change_Request__c =: crIds
                                                         AND IS_System_Modification__c != null
                                                         AND IS_System_Modification__r.RecordType.Name = 'Complex'
                                                         AND Change_Request__r.Status__c != null];
                if(crActionItems.size()>0)
                {
                    Integer totalNoOfManualStepCount = crActionItems.size();
                    Integer completedCrActItemCount = 0;
                    Integer cancelledCrActItemCount = 0;
                    Integer otherCrActItemCount = 0;
                    for(CR_Action_Item__c crAIInstance: crActionItems)
                    {
                        if(String.isNotBlank(crAIInstance.Action_Item_Status__c) && String.isNotBlank(crAIInstance.Step_Complete_in_Production__c))
                        {
                            if(crAIInstance.Action_Item_Status__c.equalsIgnoreCase('Completed')
                               && crAIInstance.Step_Complete_in_Production__c.equalsIgnoreCase(System.Label.Step_Complete_In_Production)
                              )
                            {
                                completedCrActItemCount++; 
                            }
                            else if(crAIInstance.Action_Item_Status__c.equalsIgnoreCase('Cancelled'))
                            {
                                cancelledCrActItemCount++;
                            }
                            else
                            {
                                otherCrActItemCount++;
                            }
                        }
                    }
                    if(String.isNotBlank(crActionItems[0].Change_Request__r.Status__c)
                       && String.isNotBlank(crActionItems[0].Change_Request__r.Stage__c)
                       && crActionItems[0].Change_Request__r.Status__c.equalsIgnoreCase(System.Label.Deployed_CR_Status)
                       && crActionItems[0].Change_Request__r.Stage__c!= System.Label.CR_Complete_Stage
                       && totalNoOfManualStepCount == (completedCrActItemCount + cancelledCrActItemCount))
                    {
                        SFDC_Change_Request__c crObj = new SFDC_Change_Request__c(Id = crIds);
                        crObj.stage__c = System.Label.CR_Complete_Stage;
                        crToUpdate.add(crObj);
                    }
                }
            }
        }
        if(crToUpdate.size() > 0)
        {
            Util.byPassAlltriggers = true;
            update crToUpdate;
            Util.byPassAlltriggers = false;
        }
    }
    
    /** 
     * description 
     *              : This method returns a list of SFDC Release Ids for a given list of CR Action Items, based on 
     * 					the hierarchy at a given starting parent field
     * 					for example:  'ISMod' => CR_Action_Item__c.IS_System_Modification__c.Change_Request__c.Release__c
     * @param - 1) list of CR Action Items
     *              : List of CR Action Items currently in context
     * 			2) string parent
     * 				: Valid options =>
     * 					a.  ISMod - hierarchy starting at CR_Action_Item__c.IS_System_Modification__c.Change_Request__c.Release__c
     * 					b.  CR - hierarchy starting at CR_Action_Item__c.Change_Request__c.Release__c
     * 					c.	ActionItem - hierarchy starting at CR_Action_Item__c.Release__c
     * @return 
     *              : Set of SFDC Release Ids
     */
    public static Set<Id> getParentReleaseIds(List<CR_Action_Item__c> actions, string parent) {
        
        //Create empty sets to hold the Ids
        Set<Id> relIds = new Set<Id>();
        Set<Id> craIds = new Set<Id>();
        
        //Get the Ids for the CR Action Item records, which will be used in a SOQL query
        for(CR_Action_Item__c a : actions){
            craIds.add(a.Id);
        }
        system.debug('CRActionItemTriggerHelper.getParentReleaseIds - craIds: ' + craIds);

        //Run a query to get the requested Id fields
        List<CR_Action_Item__c> craParentIds = new list<CR_Action_Item__c>(
            [SELECT IS_System_Modification__r.Change_Request__r.Release__c,
             		Change_Request__r.Release__c,
             		Release__c
             FROM CR_Action_Item__c 
             WHERE Id in :craIds]);
                
        //Loop through the query results to get the requested Release Ids
        for(CR_Action_Item__c c : craParentIds){
            if(parent == 'ISMod'){
                system.debug('CRActionItemTriggerHelper.getParentReleaseIds - c.IS_System_Modification__r.Change_Request__r.Release__c: ' + c.IS_System_Modification__r.Change_Request__r.Release__c);
            	if(c.IS_System_Modification__r.Change_Request__r.Release__c != null){
                	relIds.add(c.IS_System_Modification__r.Change_Request__r.Release__c);
            	}
            }else if(parent == 'CR'){
                system.debug('CRActionItemTriggerHelper.getParentReleaseIds - c.Change_Request__r.Release__c: '+ c.Change_Request__r.Release__c);
                if(c.Change_Request__r.Release__c != null){
                	relIds.add(c.Change_Request__r.Release__c);
            	}
            }else if(parent == 'ActionItem'){
                system.debug('CRActionItemTriggerHelper.getParentReleaseIds - c.Release__c: '+ c.Release__c);
                if(c.Release__c != null){
                	relIds.add(c.Release__c);
            	}
        	}
        }
        system.debug('CRActionItemTriggerHelper.getParentReleaseIds - relIds: ' + relIds);
        
        return relIds;
    }
    
    /** 
     * description 
     *              : This method calls a process in @Future context to recalculate the IS Mod Manual Steps on related Release records.
     * 					This method runs in @Future after the records have been deleted, so the calculations are correct.
     * @param - 1) set of Release Ids
     *              : Set of Release Ids to be recalculated
     * @return 
     *              : nothing
     */
    @future public static void recalculateManualStepsOnReleases(Set<Id> releaseIds) {
        //Call helper class method here to roll up data on SFDC Release
        SFDCChangeRequestTriggerHelper.rollUpDataOnSFDCRelease(releaseIds);
        
    }
        
    //V_1.1 Added By Mahendra Swarnkar - CR-20170119-10628 - 07/04/2017
    /** 
     * description	: This method is to validate the CR Action Items for different-2 use cases 
     * 
     * @param		: list of CRAs, map of Old CRAs, a boolean flag for delete operation
     *              
     * @return		: void 
     */
    public static void beforeEventLogic(List<CR_Action_Item__c> newCRAs, Map<Id, CR_Action_Item__c> mapOldCRA, Boolean IsDelete) {
        
        //Loop Over the new list
        for(CR_Action_Item__c cra : newCRAs!= null ? newCRAs : mapOldCRA.values()) {
            
            //Insert Use case
            if(newCRAs != null && mapOldCRA == null ) {
                
                sObject sObjCRA = cra;  
                
                //Check for the Issue is cloned and then restrict the user to clone the issue if the CR status is depoyed
                if(sObjCRA.isClone() 
                    && cra.RecordTypeId == Util.RecordTypeId('CR_Action_Item__c', 'Issue') 
                    && String.isNotBlank(cra.CR_Status__c) 
                   	&& cra.CR_Status__c == '12-Deployed' ) {
					
					// Error Message
					cra.addError('You can not clone the Issue, if Related CR is deployed.');
                }
            }
            
            //Delete Use case
            //restrict the user to delete an issue, if the CR status is depoyed
            if( IsDelete == true
                && cra.RecordTypeId == Util.RecordTypeId('CR_Action_Item__c', 'Issue')
              	&& String.isNotBlank(cra.CR_Status__c) 
                && cra.CR_Status__c == '12-Deployed'){
            	
				// Error Message
				cra.addError('You can not delete the issue, if Related CR is deployed.');    
            }
        }
    }
    
    /**
     * 	Description		:	The method is used to rollup Config_Steps_Total__c, Code_Steps_Total__c, Data_Steps_Total__c and Other_Steps_Total__c
     * 						on modification
     * 
     * Created by		:	Saurabh Kumar
     * 
     * Created Date		:	09/08/2017
     * 
     * @args			:	List<CR_Action_Item__c> newCRAs, Map<Id, CR_Action_Item__c> mapOldCRAs
     * 
     * @return			:	Void
     * 
     * @revision log	:	V1.0 Created - CR-20170907-11182
     * 
     * */
    public static void rollupFieldsOnROllup(List<CR_Action_Item__c> newCRAs, Map<Id, CR_Action_Item__c> mapOldCRAs){
        
        //Getting CRA record type id
        Id craRecordTypeId = Util.RecordTypeId('CR_Action_Item__c', 'Deployment Plan Step');
        
        //Checking whether record type id is null then return
        if(craRecordTypeId == null)
            return;
        
        //Map to hold parent records (Modification)
        Map<Id, IS_System_Modification__c> mapMods = new Map<Id, IS_System_Modification__c>();
            
        //Processing on the new records if not null otherwise on old records
        for(CR_Action_Item__c crActionItem : newCRAs != null ? newCRAs : mapOldCRAs.values()){
            
            //Checking whether Record Type is not 'Deployment Plan Step' then continue
            if(crActionItem.RecordTypeId != craRecordTypeId)
                continue;
            
            //Checking for insert case only
            if(mapOldCRAs == null && String.isNotBlank(crActionItem.Type__c) && String.isNotBlank(crActionItem.IS_System_Modification__c)){
                
                //Adding modification record with the initial values as 0
                mapMods.put(crActionItem.IS_System_Modification__c, new IS_System_Modification__c(Id = crActionItem.IS_System_Modification__c,
                           Config_Steps_Total__c = 0, Code_Steps_Total__c = 0, Data_Steps_Total__c = 0, Other_Steps_Total__c = 0));
            }
            //Checking for the update case
            if(mapOldCRAs != null && newCRAs != null && (crActionItem.Type__c != mapOldCRAs.get(crActionItem.Id).Type__c || 
                                     crActionItem.IS_System_Modification__c != mapOldCRAs.get(crActionItem.Id).IS_System_Modification__c)){
                                         
             	//Adding record for new modification if modication as parent is not null
             	if(String.isNotBlank(crActionItem.IS_System_Modification__c))
                    mapMods.put(crActionItem.IS_System_Modification__c, new IS_System_Modification__c(Id = crActionItem.IS_System_Modification__c,
                           Config_Steps_Total__c = 0, Code_Steps_Total__c = 0, Data_Steps_Total__c = 0, Other_Steps_Total__c = 0));
                
                //Adding record for the old modification if modification as parent was not null
                if(String.isNotBlank(mapOldCRAs.get(crActionItem.Id).IS_System_Modification__c))
                    mapMods.put(mapOldCRAs.get(crActionItem.Id).IS_System_Modification__c, new IS_System_Modification__c(Id = crActionItem.IS_System_Modification__c,
                           Config_Steps_Total__c = 0, Code_Steps_Total__c = 0, Data_Steps_Total__c = 0, Other_Steps_Total__c = 0));
                
            }
            //Checking for delete case
            if(newCRAs == null && String.isNotBlank(crActionItem.Type__c) && String.isNotBlank(crActionItem.IS_System_Modification__c)){
                
                //Adding modification record
                mapMods.put(crActionItem.IS_System_Modification__c, new IS_System_Modification__c(Id = crActionItem.IS_System_Modification__c,
                           Config_Steps_Total__c = 0, Code_Steps_Total__c = 0, Data_Steps_Total__c = 0, Other_Steps_Total__c = 0));
            }
        }
        
        //Checking for the map size
        if(mapMods != null && mapMods.size() > 0){
            
            //Aggregate query on the CR Action Item
            for(CR_Action_Item__c crActionItem : [Select Id, Type__c, IS_System_Modification__c 
                                                  	From CR_Action_Item__c 
                                                  	Where IS_System_Modification__c != null 
                                                  	AND Type__c != null
                                                  	AND RecordType.DeveloperName =: PMToolConstants.CR_ACTION_ITEM_RECORD_TYPE_DEVELOPER_NAME_DEPLOYMENT_PLAN_STEP
                                                 	AND IS_System_Modification__c IN : mapMods.keySet()]){
                
                 //Checking for config type
                 if(crActionItem.Type__c == PMToolConstants.CR_ACTION_ITEM_TYPE_CONFIGURATION){
                 	
                     //Checking for key if exist then increase the counter
                     if(mapMods.containsKey(crActionItem.IS_System_Modification__c))
                         mapMods.get(crActionItem.IS_System_Modification__c).Config_Steps_Total__c += 1;
                 }
                 //Checking for code type
                 if(crActionItem.Type__c == PMToolConstants.CR_ACTION_ITEM_TYPE_CODE){
                 	
                     //Checking for key if exist then increase the counter
                     if(mapMods.containsKey(crActionItem.IS_System_Modification__c))
                         mapMods.get(crActionItem.IS_System_Modification__c).Code_Steps_Total__c += 1;
                 }
                                                        
                 //Checking for data type
                 if(crActionItem.Type__c == PMToolConstants.CR_ACTION_ITEM_TYPE_DATA){
                 	
                     //Checking for key if exist then increase the counter
                     if(mapMods.containsKey(crActionItem.IS_System_Modification__c))
                         mapMods.get(crActionItem.IS_System_Modification__c).Data_Steps_Total__c += 1;
                 }
                                                        
                 //Checking for other type
                 if(crActionItem.Type__c == PMToolConstants.CR_ACTION_ITEM_TYPE_OTHER){
                 	
                     //Checking for key if exist then increase the counter
                     if(mapMods.containsKey(crActionItem.IS_System_Modification__c))
                         mapMods.get(crActionItem.IS_System_Modification__c).Other_Steps_Total__c += 1;
                 }
            }
            
            //Update the map values
            if(mapMods.values().size() > 0) {
        		Util.BypassAllTriggers = true;
                update mapMods.values();
                Util.BypassAllTriggers = false;
            }
        }
    }
}