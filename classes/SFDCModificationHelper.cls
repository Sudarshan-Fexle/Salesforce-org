/*
Purpose         :   This class is helper class for  SFDCModification Trigger & CRActionItem Trigger.
Project/CR: CR-20151020-9340

Created By       :   Colin McGloin

Created Date    :   27/10/2015

Current Version :   v1.0
		    v1.1 - Modified By Mahendra Swarnakar - CR-20170119-10628 - 7/22/2017 - Added a new method "validateDeployedMods" to validate the Mods with CR-status deployed.
		    v1.2 - Modified By Saurabh Kumar - CR-20170907-11182 - 09/07/2017 - recalculateManualStepsTime method is updated. Type is removed from the group by clause
		    v1.3 - Modified By Victor Hanson - CR-20180220-12078 - 03/26/2018 - removed references to addDeleteMention
                    v1.4 - Modified By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020 -
*/

public without sharing class SFDCModificationHelper {
	
    //v1.1 - Added By Mahendra Swarnakar - CR-20170119-10628 - 7/22/2017 - Starts from here
    //Static variables
    public final static String SETUP_ENTITY_TYPE = 'CustomPermission';
    public final static String CUSTOM_PERMISSION_APINAME_Release_Management_Modify_Locked_Fields = 'Release_Management_Modify_Locked_Fields';
    public final static String SFDC_MOD_FIELD_APINAME_IS_System_Component = 'IS_System_Component__c';
	public final static String SFDC_MOD_CR_TYPE  = '12-Deployed';    
	public final static String ERROR_MESSAGE_FOR_DEPLOYED_MOD  = 'Deployed modifications can not be modified. You are only allowed to edit the field "Updates After Initial Deploy"';    
    public final static String ERROR_MESSAGE_FOR_DEPLOYED_MOD_WITH_PERMISSION_ASSIGNED  = ' and "Is System Component".';
	//v1.1 - Added By Mahendra Swarnakar - CR-20170119-10628 - 7/22/2017 - Ends here
    
    /* @description: if CR Action Item is added, rollup Time from the record to the associated Modification record. This should also
    *  check the relevant flag on the Modification record for what type of change it is (i.e Pre-Validation or Pre-Deployment)
	* 
	* @revisions:	11/01/2015 - CM - Created
	**/
    
    public static void recalculateManualStepsTime(List <CR_Action_Item__c> crActionList){
        
        //Add list to capture all the Associated Modification records
        Set<Id> modIds = new Set<Id>();
        List<IS_System_Modification__c> loopMods = new List <IS_System_Modification__c>();
        List<CR_Action_Item__c> crActionItems = new List<CR_Action_Item__c>();
        List<IS_System_Modification__c> updateMod = new List <IS_System_Modification__c>();
        Map<Id, IS_System_Modification__c> mapISModIDs = new Map<Id, IS_System_Modification__c>();
        
        //Fire on all Trigger activity
        if (Trigger.isInsert || Trigger.isUndelete || Trigger.isUpdate || Trigger.isDelete){
            
            for(CR_Action_Item__c crActions : crActionList){
                //Add the associated Mods from the CR Action Item to the list
                if(crActions.IS_System_Modification__c != null)
                    modIds.add(crActions.IS_System_Modification__c);      
            }
            
        }
        
        //If there are associated Mods then kick the aggregating process off
        if(modIds.size() > 0){
            
            loopMods = [SELECT Id, Name
                        FROM IS_System_Modification__c
                        WHERE Id IN :modIds];
            
            if (loopMods.size() >0){
                
                for (IS_System_Modification__c isMod : loopMods){
                    
                    crActionItems = [SELECT Id, Timing__c, Type__c, IS_System_Modification__c
                                     FROM CR_Action_Item__c
                                     WHERE IS_System_Modification__c = :isMod.Id];
                    
                    isMod.Pre_Validation_Estimate_Mins__c = 0;
                    isMod.Pre_Deployment_Estimate_Mins__c = 0;
                    isMod.Post_Deployment_Estimate_Mins__c = 0;
                    isMod.Other_Manual_Steps_Estimate_Mins__c = 0;
                    isMod.Has_Pre_Validation_Steps__c = False;
                    isMod.Has_Pre_Deployment_Steps__c = False;
                    isMod.Has_Post_Deployment_Steps__c = False;
                    isMod.Has_Other_Deployment_Steps__c = False;
                    isMod.Has_Data_Modification__c = False;
                    
                    
                    for (CR_Action_Item__c CRActTiming: crActionItems){
                        if(CRActTiming.Timing__c == 'Pre-Validation'){
                            isMod.Has_Pre_Validation_Steps__c = True;
                        }
                        if(CRActTiming.Timing__c == 'Pre-Deployment'){
                            isMod.Has_Pre_Deployment_Steps__c = True;
                        }
                        if(CRActTiming.Timing__c == 'Post-Deployment'){
                            isMod.Has_Post_Deployment_Steps__c = True;
                        }
                        if(CRActTiming.Timing__c == 'Other'){
                            isMod.Has_Other_Deployment_Steps__c = True;
                        }
                        if(CRActTiming.Type__c == 'Data'){
                            isMod.Has_Data_Modification__c = True;
                        }
                        mapISModIDs.put(isMod.Id, isMod);
                        
                    }
                    
                } 
            }
            
            //v1.2 - Modified By Saurabh Kumar - CR-20170907-11182 - 09/07/2017 - . Type is removed from the group by clause
            //Grab all the necessary records for the Time Estimate Aggregation
            List<AggregateResult> aggregateResultsForCRAction = [Select Count(ID) recordCount, Timing__c timing, IS_System_Modification__c isSysMod, SUM(Time_Estimate_Mins__c) totalTimeEstimateMins
                                                                 From CR_Action_Item__c where IS_System_Modification__c IN: modIds
                                                                 GROUP BY Timing__c, IS_System_Modification__c];

            
            if(aggregateResultsForCRAction.size() > 0) {
                
                IS_System_Modification__c isMod;
                
                for(AggregateResult aR : aggregateResultsForCRAction){
                    
                    //If our Mod is not null then we start the process
                    if(aR.get('isSysMod') != null) {
                        
                        Id modId = Id.valueOf(String.valueOf(aR.get('isSysMod')));
                        
                        if(!mapISModIDs.containsKey(modId))
                            mapISModIDs.put(modId, new IS_System_Modification__c(Id = modId));
                        
                        isMod = mapISModIDs.get(modId);
                        
                    }
                    
                    //Loops through the values and populates the associated Total Time Estimate Sum - verify if we can hardcode this or not
                    //Checks the relevant Steps box as True if the Timing matches the Steps type
                    if (String.valueof(aR.get('timing'))=='Pre-Validation'){
                        isMod.Pre_Validation_Estimate_Mins__c = Double.valueOf(aR.get('totalTimeEstimateMins'));
                        mapISModIDs.put(isMod.Id, isMod);
                        
                    } if (String.valueof(aR.get('timing'))=='Pre-Deployment'){
                        isMod.Pre_Deployment_Estimate_Mins__c = Double.valueOf(aR.get('totalTimeEstimateMins'));
                        mapISModIDs.put(isMod.Id, isMod);
                        
                    } if (String.valueof(aR.get('timing'))=='Post-Deployment'){
                        isMod.Post_Deployment_Estimate_Mins__c = Double.valueOf(aR.get('totalTimeEstimateMins'));
                        mapISModIDs.put(isMod.Id, isMod);
                        
                    } if (String.valueof(aR.get('timing'))=='Other'){
                        isMod.Other_Manual_Steps_Estimate_Mins__c = Double.valueOf(aR.get('totalTimeEstimateMins'));
                        mapISModIDs.put(isMod.Id, isMod);
                    }
                }
            }                                   
            
            for (Id issystemMod : modIds) {
                
                if(!mapISModIDs.containsKey(issystemMod))
                    mapISModIDs.put(issystemMod, new IS_System_Modification__c(Id = issystemMod, Pre_Validation_Estimate_Mins__c = 0,
                                                                               Pre_Deployment_Estimate_Mins__c = 0,
                                                                               Post_Deployment_Estimate_Mins__c = 0,
                                                                               Other_Manual_Steps_Estimate_Mins__c = 0,
                                                                               Has_Pre_Validation_Steps__c = False,
                    														   Has_Pre_Deployment_Steps__c = False,
                    														   Has_Post_Deployment_Steps__c = False,
                    														   Has_Other_Deployment_Steps__c = False,
                    														   Has_Data_Modification__c = False));
            }
            
        }
        
        if(mapISModIDs.size() > 0) {
            //Update the values on the Mod after all calculations are completed
            update mapISModIDs.values();
        }
        
        
    }
    
    /* @description: Prevents the user from deleting the Modification record if it has been deployed to a Sandbox
	* 
	* @revisions:	11/01/2015 - CM - Created
	**/

    
    public static void deleteISMod(List <IS_System_Modification__c> deletedMod) {
        
        Map<Id, IS_System_Modification__c> modsForDeletion = new Map<Id, IS_System_Modification__c>();
        for(IS_System_Modification__c isMod : deletedMod){
            
            if(isMod.Deployed_To__c != null && (isMod.Deployed_To__c.containsIgnoreCase('None') || isMod.Deployed_To__c != Null)) {
                
                isMod.adderror(Label.ISModDeletion);
                
            }
            
        }
        
    }
    
    /* @description: if CR Action Item is added, rollup Time from the record to the associated Modification record. This should also
    *  check the relevant flag on the Modification record for what type of change it is (i.e Pre-Validation or Pre-Deployment)
	* 
	* @revisions:	11/01/2015 - CM - Created
	**/
    
    
    public static void preventFieldEdits (List <IS_System_Modification__c> newMods, Map <Id, IS_System_Modification__c> oldMods){
        
        Map<Id, IS_System_Modification__c> mapIsMod = new Map<Id, IS_System_Modification__c>();
        
        if (oldMods != null){
            
            for (IS_System_Modification__c sysMod : newMods){
                
                IS_System_Modification__c oldMod = (IS_System_Modification__c)trigger.OldMap.get(sysMod.Id);
                system.debug('zzzzzoldMod' + oldMod.Id);
                
                    if(sysMod.Update_Original_Steps_Redeploy__c == False){
                        if(sysMod.Deployed_To__c != null){
                            if(sysMod.Deployed_To__c.containsIgnoreCase('Rehearse') || sysMod.Deployed_To__c.containsIgnoreCase('UAT')){
                                if(sysMod.Delete_from_Design__c != oldMod.Delete_from_Design__c
                                   || sysMod.Dependency_Notes__c != oldMod.Dependency_Notes__c
                                   || sysMod.Description__c  != oldMod.Description__c 
                                   || sysMod.Double_Deployment__c != oldMod.Double_Deployment__c
                                   || sysMod.High_Impact_Mod__c != oldMod.High_Impact_Mod__c
                                   || sysMod.High_Impact_Mod_Type__c != oldMod.High_Impact_Mod_Type__c
                                   || sysMod.Include_in_Change_Set__c != oldMod.Include_in_Change_Set__c
                                   || sysMod.IS_System_Component__c != oldMod.IS_System_Component__c
                                   || sysMod.New_Field_Length__c != oldMod.New_Field_Length__c
                                   || sysMod.New_Field_Type__c != oldMod.New_Field_Type__c
                                   || sysMod.New_Object_API_Name__c != oldMod.New_Object_API_Name__c
                                   || sysMod.New_Object_Label__c != oldMod.New_Object_Label__c
                                   || sysMod.Other_Configuration__c != oldMod.Other_Configuration__c
                                   || sysMod.Reason_for_Deleting__c != oldMod.Reason_for_Deleting__c
                                   //|| sysMod.RecordTypeId != oldMod.RecordTypeId
                                   || sysMod.See_Dependencies__c != oldMod.See_Dependencies__c
                                   || sysMod.Type_of_Modification__c != oldMod.Type_of_Modification__c){
                                       
                                       sysMod.adderror(Label.ISModFieldEdits);
                                   }
                            }
                        }
                    }
               
                else if (oldMod.Update_Original_Steps_Redeploy__c == True || sysMod.Update_Original_Steps_Redeploy__c == True){

                        sysMod.Update_Original_Steps_Redeploy__c = False;
                    if(sysMod.Deployed_To__c != null){
                        sysMod.Deployed_To__c = sysMod.Deployed_To__c.replaceAll(';?UAT;?','');
                        sysMod.Deployed_To__c = sysMod.Deployed_To__c.replaceAll(';?Rehearse;?','');
                    }
                        
                        Map<Id, CR_Action_Item__c> crActions = new map<Id, CR_Action_Item__c>([SELECT Id FROM CR_Action_Item__c WHERE IS_System_Modification__c = :sysMod.Id]);
                        Set <Id> CRActionItemSet = crActions.keyset();
                        
                        if(CRActionItemSet != null){
                            
                            updateFieldEditsCRActions(CRActionItemSet);
                            
                        }
                    } 
                }
            }
            
        }
    
/**
 * @description: Verifies the SOX Object checkbox field matches the value on the parent IS System Component record, and updates it if needed.  The
 * 				 actual value must be updated in code so the roll-up summary on Change Request can access the value.
 * 
 * @revisions:	 12/1/2015 - JRB - Created
 **/
    public static void SOXObjectFieldUpdate(List<IS_System_Modification__c> newMods){
        //get the IS System Component Ids
        set<Id> ISCids = new set<Id>();
        for(IS_System_Modification__c ism : newMods){
            ISCids.add(ism.IS_System_Component__c);
        }
        system.debug('SFDCModificationHelper.SOXObjectFieldUpdate - ISCids:'+ISCids);
        
        //query to get the values of the SOX Object field on the IS Component record 
        map<Id,IS_System_Component__c> ISCs = new map<Id,IS_System_Component__c>([select Id, SOX_Object__c from IS_System_Component__c where Id in :ISCids]);
        system.debug('SFDCModificationHelper.SOXObjectFieldUpdate - ISCs:'+ISCs);
        
       	//check if the value on the newMods records is different
        for(IS_System_Modification__c i : newMods){
            //if different, update the value
            if(i.SOX_Object__c != ISCs.get(i.IS_System_Component__c).SOX_Object__c){
                i.SOX_Object__c = ISCs.get(i.IS_System_Component__c).SOX_Object__c;
            }
        }
    }
    
    
    /**
* @description: if Deploy To field is updated with a new value, check through all CR Action Item records
* 				 to verify the Step Complete In [XX] field for the same environment is set to Yes or N/A on all records.  If not, show an error.
* 
* @revisions:	11/11/2015 - VH - Created
**/
    public static void verifyDeployedTo(Map <Id, IS_System_Modification__c> newModMap, Map <Id, IS_System_Modification__c> oldModMap) {
        set<Id> modIdsToCheck = new set<Id>();
        for (IS_System_Modification__c mod : newModMap.values()) {
            //get the old mod
            IS_System_Modification__c oldMod = oldModMap.get(mod.Id);
            //if the deployed to value changed, add to the list of records to check
            if (mod.Deployed_To__c != null && mod.Deployed_To__c != oldMod.Deployed_To__c) modIdsToCheck.add(mod.Id);
        }
        
        if (modIdsToCheck.size() > 0) {
            //get all mods to verify, including CR action items
            Map <Id, IS_System_Modification__c> oldModsWithActionItems
                = new Map <Id, IS_System_Modification__c>([SELECT Id, 
                                                           (SELECT Id, Name, Step_Complete_In_QA__c, Step_Complete_In_UAT__c, Step_Complete_In_Rehearse__c, 
                                                            Step_Complete_In_Production__c, Step_Complete_In_Alternate__c FROM CR_Action_Items__r) 
                                                           FROM IS_System_Modification__c 
                                                           WHERE Id IN :modIdsToCheck]);
            
            
            
            set<string> validDeployValues = new set<string> {'Yes', 'N/A'};
                
                for (IS_System_Modification__c oldModWithActionItems : oldModsWithActionItems.values()) {
                    //get the new mod record to find out where it has been deployed to
                    IS_System_Modification__c newMod = newModMap.get(oldModWithActionItems.Id);
                    list<string> deployedToList = newMod.Deployed_To__c.split(';');
                    
                    boolean hasError = false;
                    string errorMessage = Label.Modification_Deploy_To_Error + deployedToList + ' :</br>';
                    
                    for (CR_Action_Item__c isActionItem : oldModWithActionItems.CR_Action_Items__r) {
                        for (string deployedToVal : deployedToList) {
                            if (!validDeployValues.contains((string) isActionItem.get(ValToFieldName.get(deployedToVal)))) {
                                hasError = true;
                                errorMessage += '<a href="/' + isActionItem.Id + '/e?retURL=' + newMod.Id + '">' + isActionItem.Name + '</a><br/>';
                                break;
                            }
                        }
                    }
                    
                    if (hasError) newMod.addError(errorMessage, false);
                }
        }
        
    }
    
    /**
    * @description: maps a Deployed_To__c picklist value to the corresponding Action Item.Step_Completed_In_[xx]__c field
    **/
    public static map<string, string> ValToFieldName {
        get {
            if (ValToFieldName == null) ValToFieldName = new map<string, string>{'QA' => 'Step_Complete_In_QA__c', 'UAT' => 'Step_Complete_In_UAT__c', 
                'Rehearse' => 'Step_Complete_In_Rehearse__c', 'Production' => 'Step_Complete_In_Production__c', 'Alternate' => 'Step_Complete_In_Alternate__c'};
                    return ValToFieldName;
        }
        set;
    }
    
	//bypass the flagDuplicateMods future method if this has already been executed once
    public static boolean hasCheckedDupes = false;
                
   /**
    * @description: check for duplicate mods on the CR and Release.
    * 
    * @revisions:	11/11/2015 - VH - Created
    **/
    public static void flagDuplicateMods(list<IS_System_Modification__c> newMods, map<Id, IS_System_Modification__c> oldMods) {
        set<Id> oldComponentIdSet = new set<Id>();
        set<Id> modIdSet = new set<Id>();
        set<Id> componentIdSet = new set<Id>();
        set<Id> releaseIdSet = new set<Id>(); //track the unique releases related to the update so we can refine the release dupe checking process
        list<IS_System_Modification__c> mods = newMods;
        if (trigger.isDelete) mods = oldMods.values();
        
        //get the related change request for each mod so we can find out the release id
        set<Id> crIds = new set<Id>();
        
        //put all the parents in a map <Component.Id -> parent.Id>
        map<Id, list<IS_System_Modification__c>> componentIdToModsMap = new map<Id, list<IS_System_Modification__c>>();
        for (IS_System_Modification__c mod : mods) {
            
            //if the mod's component is updated, add the old component id to a list to check
            if (newMods != null && oldMods != null) {
                IS_System_Modification__c oldMod = oldMods.get(mod.Id);
                if (mod.IS_System_Component__c != oldMod.IS_System_Component__c) oldComponentIdSet.add(oldMod.IS_System_Component__c);
            }
            
            crIds.add(mod.Change_Request__c);
            componentIdSet.add(mod.IS_System_Component__c);
            //create the list of mods being updated for this component (as long as this isn't a delete operation)
            if (!trigger.isDelete) {
                list<IS_System_Modification__c> modList = componentIdToModsMap.get(mod.IS_System_Component__c);
                if (modList == null) modList = new list<IS_System_Modification__c>();
                modList.add(mod);
                componentIdToModsMap.put(mod.IS_System_Component__c, modList);
            }
        }
        
        map<Id, SFDC_Change_Request__c> changeRequestMap = new map<Id, SFDC_Change_Request__c>([SELECT Id, Release__c FROM SFDC_Change_Request__c WHERE Id IN :crIds]);
        
        map<Id, Id> modIdToReleaseIdMap = new map<Id, Id>();
        for (IS_System_Modification__c mod : mods) {
            SFDC_Change_Request__c cr = changeRequestMap.get(mod.Change_Request__c);
            modIdToReleaseIdMap.put(mod.Id, cr.Release__c);
            releaseIdSet.add(cr.Release__c);
        }
        
        //get the mods related to these CRs or Releases to see if there are dupes
        list<IS_System_Modification__c> duplicateMods = [SELECT Id, IS_System_Component__c, Change_Request__c, Change_Request__r.Release__c, Duplicate_Mod_on_CR__c, Duplicate_Mod_on_Release__c
                                                         FROM IS_System_Modification__c 
                                                         WHERE IS_System_Component__c IN :componentIdSet AND Id NOT IN :mods
                                                         AND (Change_Request__c IN :crIds OR Change_Request__r.Release__c IN : modIdToReleaseIdMap.values())];
        map<Id, IS_System_Modification__c> duplicateModsMap = new map<Id, IS_System_Modification__c>(duplicateMods);
        map<Id, list<IS_System_Modification__c>> duplicateComponentIdToModMap = new map<Id, list<IS_System_Modification__c>>();
        for (IS_System_Modification__c mod : duplicateMods) {
            //create the list of mods being updated for this component
            list<IS_System_Modification__c> modList = duplicateComponentIdToModMap.get(mod.IS_System_Component__c);
            if (modList == null) modList = new list<IS_System_Modification__c>();
            modList.add(mod);
            duplicateComponentIdToModMap.put(mod.IS_System_Component__c, modList);
        }
        
        
        //perform the duplicate check
        for (IS_System_Modification__c mod : mods) {
            //reset dupe values to false
            if (!trigger.isDelete) {
                mod.Duplicate_Mod_on_CR__c = false;
                mod.Duplicate_Mod_on_Release__c = false;
            }
            
            //get the releaseId for this mod
            Id releaseId = modIdToReleaseIdMap.get(mod.Id);
            
            if (duplicateComponentIdToModMap != null && duplicateComponentIdToModMap.containsKey(mod.IS_System_Component__c)) {
                //get the list of mods
                for (IS_System_Modification__c dupe : duplicateComponentIdToModMap.get(mod.IS_System_Component__c)) {
                    if (trigger.isDelete || mod.Change_Request__c == dupe.Change_Request__c || releaseId == dupe.Change_Request__r.Release__c) {
                        if (!trigger.isDelete) {
                            if (mod.Change_Request__c == dupe.Change_Request__c) mod.Duplicate_Mod_on_CR__c = true;
                            if (releaseId == dupe.Change_Request__r.Release__c) mod.Duplicate_Mod_on_Release__c = true;
                        }
                        if (
                            (!trigger.isDelete && (mod.Duplicate_Mod_on_CR__c != dupe.Duplicate_Mod_on_CR__c || mod.Duplicate_Mod_on_Release__c != dupe.Duplicate_Mod_on_Release__c)) 
                            || (trigger.isDelete && !oldMods.containsKey(dupe.Id))){
                            modIdSet.add(dupe.Id);
                        }
                    }
                    
                }
            }
            system.debug('@@@modIdSet:' + modIdSet);
            //check for potential dupes within the records being updated
            if (componentIdToModsMap != null && componentIdToModsMap.containsKey(mod.IS_System_Component__c) && componentIdToModsMap.get(mod.IS_System_Component__c).size() > 1) {
                for (IS_System_Modification__c dupe : componentIdToModsMap.get(mod.IS_System_Component__c)) {
                    if (mod.Id == dupe.Id || mod == dupe) continue; 
                    if (mod.Change_Request__c == dupe.Change_Request__c) {
                        mod.Duplicate_Mod_on_CR__c = true;
                        mod.Duplicate_Mod_on_Release__c = true;
                    }
                    else if (releaseId == dupe.Change_Request__r.Release__c) mod.Duplicate_Mod_on_Release__c = true;
                }
            }
        }
        
        if (oldComponentIdSet.size() > 0) {
            for(IS_System_Modification__c otherOldComponentMod : [SELECT Id FROM IS_System_Modification__c 
                                                                  WHERE IS_System_Component__c IN :oldComponentIdSet 
                                                                  AND Release__c IN :releaseIdSet 
                                                                  AND Id NOT IN :mods]) {
                modIdSet.add(otherOldComponentMod.Id);
            }
        }
        
        if (modIdSet.size() > 0 && !hasCheckedDupes && !system.isBatch() && !system.isFuture()) updateMods(modIdSet);
        hasCheckedDupes = true;
    }
    
    @future
    public static void updateMods(set<Id> modIdSet) {
        list<IS_System_Modification__c> modsToUpdate = new list<IS_System_Modification__c>();
        for (string modId : modIdSet) {
            modsToUpdate.add(new IS_System_Modification__c(Id = modId));
        }
        update modsToUpdate;
    }
    
    @future
    public static void updateFieldEditsCRActions(Set <Id> crActionsSet){
        
        List<CR_Action_Item__c> updateCRActions = new List<CR_Action_Item__c>();
        
        for(String crActID : crActionsSet){
            updateCRActions.add(new CR_Action_Item__c(Id = crActID, Step_Complete_in_UAT__c = 'No', Step_Complete_in_Rehearse__c = 'No'));
                }
        update updateCRActions;  
    }
    
    //v1.1 - Added By Mahendra Swarnakar - CR-20170119-10628 - 7/22/2017 - Added method to validate the Mods with CR-status deployed.
    public static void validateDeployedMods (List <IS_System_Modification__c> newMods, Map <Id, IS_System_Modification__c> oldMods) {
		
        //Check for size
		if(oldMods != null) {
			
			//Flag for User Permission
			Boolean isHavingPermissionToEditField = false;
			
            //List to hold the Setup Entity access records. 
            //This (query)will return the record if the user is having the custom permission "Release_Management_Modify_Locked_Fields" assigned to them.
	    // Modified By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020
	    /*List<SetupEntityAccess> listCustomPermissions = [SELECT ParentId 
	    							FROM SetupEntityAccess 
								WHERE SetupEntityType = : SETUP_ENTITY_TYPE
								AND SetupEntityId IN 
									(
										SELECT Id 
										FROM CustomPermission 
										WHERE DeveloperName = : CUSTOM_PERMISSION_APINAME_Release_Management_Modify_Locked_Fields
									)
								AND ParentId IN 
	    								(
										SELECT PermissionSetId 
										FROM PermissionSetAssignment 
										WHERE AssigneeId =: UserInfo.getUserId()
									)
	    							];*/
	    //Modified By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020 - 
            //Check for the size of listCustomPermissions. then set the isHavingPermissionToEditField flag  
            //if(listCustomPermissions != null && listCustomPermissions.size() > 0)
		    isHavingPermissionToEditField = FeatureManagement.checkPermission(CUSTOM_PERMISSION_APINAME_Release_Management_Modify_Locked_Fields);
			
			//Set to hold the fields to be allowed to Edit
	        Set<String> setFieldsToBeAllowedToUpdate = new Set<String>();
	        
	        //get the Fields from the FieldSet FieldsAllowedToUpdateAfterDeployment that contains the fields to be allowed for update for deployed mods.
	        List<Schema.FieldSetMember> fieldsAllowedToBeUpdate = Schema.SObjectType.IS_System_Modification__c.fieldSets.FieldsAllowedToUpdateAfterDeployment.getFields();
	        
	        //Check for the size
	        if(fieldsAllowedToBeUpdate != null && fieldsAllowedToBeUpdate.size() > 0){
	        	
	            //Populate the setFieldsToBeAllowedToUpdate
	            for(Schema.FieldSetMember f : fieldsAllowedToBeUpdate){
	            	setFieldsToBeAllowedToUpdate.add(f.getFieldPath());
	        	}    
	        }
	        
	        //Map of all fields on the IS_System_Modification__c
	        Map <String, Schema.SObjectField> mapModsFields = Schema.SObjectType.IS_System_Modification__c.fields.getMap();
	        
	        //Loop over the Modifications
	        for(IS_System_Modification__c mod : newMods){
	        	
                //Check for the deployed CR
	        	if(mod.CR_Status__c == SFDC_MOD_CR_TYPE){
	        		
	        		//Flag for field is allowed to edit
		        	Boolean isFieldEditable = true;
		        	
                    //Loop over all the SFDC modification fields (API names) 
		        	for(Schema.SObjectField allfield : mapModsFields.values())
                    {
                        //Describe the field schema 
                    	Schema.DescribeFieldResult dfield = allfield.getDescribe();
		        		
                        //get the field api name
                        String fieldAPIName = dfield.getName();
		        		
                        //check if the field is in the set setFieldsToBeAllowedToUpdate
                        // and check if user having the permission to edit 'IS_System_Component__c' field on Mods
		        		if(setFieldsToBeAllowedToUpdate.contains(fieldAPIName)
                           	&& !isHavingPermissionToEditField 
							&& fieldAPIName == SFDC_MOD_FIELD_APINAME_IS_System_Component
							&& mod.get(fieldAPIName) != oldMods.get(mod.id).get(fieldAPIName)
		        		) {
                            //set the flag
							isFieldEditable = false;
		        		}
		        		
                        //Check if any other field is changes 
                        //( Except "Updates After Initial Deploy" for all users having the fls to edit it 
                        //  and 'IS_System_Component__c' for all users having the custom permission "Release_Management_Modify_Locked_Fields" asigned to them)
		        		if(!setFieldsToBeAllowedToUpdate.contains(fieldAPIName)
		        			&& mod.get(fieldAPIName) != oldMods.get(mod.id).get(fieldAPIName)
		        		){
                            //Set the flag
		        			isFieldEditable = false;
                            System.debug('@@@fieldAPIName' +  fieldAPIName);
		        		}
		        	}
		        	
                    //Throw the error if field is not allowed to edit by the user.
		        	if(!isFieldEditable)
		        		mod.addError(ERROR_MESSAGE_FOR_DEPLOYED_MOD + (isHavingPermissionToEditField? ERROR_MESSAGE_FOR_DEPLOYED_MOD_WITH_PERMISSION_ASSIGNED :'.') );
	        	}
	        }
		}
    }
}