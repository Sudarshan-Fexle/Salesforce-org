//Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
//Merged by Dipesh Gupta for CR-20170926-11418 overlapping
trigger SFDCModification on IS_System_Modification__c (before insert, before update, before delete, after delete, after update) {
    
     //Bypass All Triggers
    if(Util.BypassAllTriggers == true)
        return;
	
     /*Merged by Dipesh Gupta for CR-20170926-11418 overlapping - start here*/
     //return immediately if method returns true	
    	if(Util.areTriggersOnThisObjectBypassed('IS_System_Modification__c')) return;	
     /*Merged by Dipesh Gupta for CR-20170926-11418 overlapping - ends here*/
    
    try {
        
        if (Trigger.isBefore) {
            
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Added By Mahendra Swarnakar - CR-20170119-10628 - 7/22/2017 - Added method to validate the Mods with CR-status deployed.
                SFDCModificationHelper.validateDeployedMods(Trigger.new, Trigger.oldMap);
                
                //flag mods with the same component on the CR or Release
                SFDCModificationHelper.flagDuplicateMods(Trigger.new, Trigger.oldMap);
                
                //Check for the request type
                SFDCModificationHelper.preventFieldEdits(Trigger.New, Trigger.oldMap);
                
                //Update the SOX Object field as needed.  
				SFDCModificationHelper.SOXObjectFieldUpdate(Trigger.new);
            }
            
            if (Trigger.isUpdate) {
                
                //verify all related action items have been deployed to the environments specified on the modification
                SFDCModificationHelper.verifyDeployedTo(Trigger.newMap, Trigger.oldMap);
            }
            
            if (Trigger.isDelete) {
                
                SFDCModificationHelper.deleteISMod (Trigger.Old);
            }
        }
        
        if (trigger.isAfter) {
            
            if(Trigger.isInsert || Trigger.isUpdate){
                
                //SFDCModificationHelper.addDeleteMention(Trigger.New, Trigger.OldMap);
                
            }
            
            if (Trigger.isDelete) {
                
                //flag mods with the same component on the CR or Release
                SFDCModificationHelper.flagDuplicateMods(Trigger.new, Trigger.oldMap);
            }
                
        }
    }
    
    catch(DMLException e) {
        
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0) + e.getStackTraceString());
        else
            Trigger.New[0].addError(e.getDmlMessage(0) + e.getStackTraceString());
        
        //Catching all Exceptions
    } catch(Exception e) {
        
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage() + e.getStackTraceString());
        else
            Trigger.New[0].addError(e.getMessage() + e.getStackTraceString());
    }
    
}