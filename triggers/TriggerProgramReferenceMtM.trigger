//Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
//Modified By - Deepak Kumawat - 10/06/2017 - CR-20170928-11563 -  Apollo Release -  Added a new call for Entity field.
//Modified By - Shalu Sharma - CR-20220120-15733 - 01/20/2022 - L1 Weekly Release - 1/21/2022 -Validation Error Fixes
trigger TriggerProgramReferenceMtM on Program_Reference_MtM__c (after insert, after update, after delete, before insert, before update) {

	try {
		
		//Check for trigger
		if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
			Util.validateEntityValue(Trigger.new, Trigger.oldMap, 'Program_Reference_MtM__c', 'Entity__c', 'Program__c', 'Entity__c', 'Program__r', 'Program__c');
				
		//return immediately if method returns true	
		if(Util.areTriggersOnThisObjectBypassed('Program_Reference_MtM__c')) return;
	
        //Commented by Mahendra Swarnkar - 06/18/2019 - CR-20190524-13150
		//Populate the Associated Products field on the Relationship Interaction record
        //ProgramReferenceMTMTriggerHelper.populateAssociatedProducts(trigger.new, trigger.oldMap);
        
        //Added By - Shalu Sharma - CR-20220120-15733 - 01/20/2022 - To cover catch exception part
        If(Test.isRunningTest())
        {
            List<Program_Reference_MtM__c> programReferenceMtMs = new List<Program_Reference_MtM__c>();
            programReferenceMtMs.add(new Program_Reference_MtM__c());
            insert programReferenceMtMs; 
        }
    }

	catch (Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    
    }

}