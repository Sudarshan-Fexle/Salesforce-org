/**
 *  Purpose         :   Trigger for the Custom Lookup Data object
 *
 *  Created By      :   Victor Hanson
 *
 *  Created Date    :   04/26/2018
 *
 *  Revision Logs   :   V_1.0 - Created
 * 						V_1.1 - Modified - 04/03/2019 - Victor Hanson - added bypass code to trigger
 *
 **/ 
trigger CustomLookupData on Custom_Lookup_Data__c (before insert, before update) {
	
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Custom_Lookup_Data__c')) return;	
    
    //if bypass all triggers is set to true, return without processing
    if (Util.BypassAllTriggers) return;
    
    if (trigger.isBefore) {
        
        //populate the URL Encoded Name
        CustomLookupDataTriggerHelper.populateURLEncodedName(Trigger.new);
        
        if (trigger.isUpdate) {
            
            //recalculate proposal grades if necessary
            CustomLookupDataTriggerHelper.recalculateProposalGrades(Trigger.new, Trigger.oldMap);
        }
    }
}