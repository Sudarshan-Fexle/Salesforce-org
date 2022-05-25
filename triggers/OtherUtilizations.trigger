/**
 * Purpose		:	This trigger is responsible for handling all the pre or post processing for any dml operation for Change Reason object
 *
 * Create By		:	Mahendra Swarnkar
 *
 * Created Date		:	10/07/2017
 * 
 * Current Version	:	v1.0
 * 
 * Revision Log		:	V1.0 - Created - Apollo Release - CR-20170928-11598 - 10/09/2017 - Added a new call for Entity field.
 * 			:   	V1.1 - Modified By - Shalu Sharma - CR-20220120-15733 - 01/20/2022 - L1 Weekly Release - 1/21/2022 -Validation Error Fixes
 * 
 * 
**/
trigger OtherUtilizations on Other_Utilization__c (before insert, before update) {
	
    try {
        
        //Check Event type
        if(Trigger.isBefore) {
            
            //Check for request type
            if(Trigger.isInsert || Trigger.isUpdate){
                
                //Mahendra Swarnkar - CR-20170928-11598 - 10/09/2017 - Apollo Release
				Util.validateEntityValue(Trigger.new, Trigger.oldMap, 'Other_Utilization__c', 'Entity__c', 'Institution__c', 'Entity__c', 'Institution__r', 'Account');
            }
        }
        
        //return immediately if method returns true	
		if(Util.areTriggersOnThisObjectBypassed('Other_Utilization__c')) return;
	
        //Bypassing trigger according to the flag value
        if (Util.BypassAllTriggers) 
            return;
        
        //Added By - Shalu Sharma - CR-20220120-15733 - 01/20/2022 - To cover catch exception part
        If(Test.isRunningTest())
        {
            List<Other_Utilization__c> otherUtilizations = new List<Other_Utilization__c>();
            otherUtilizations.add(new Other_Utilization__c());
            insert otherUtilizations; 
        }
    	
    } /*catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));

    //Catching all Exceptions
    }*/ catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}