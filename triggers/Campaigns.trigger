/**
 *	Purpose		:	This trigger is responsible for handling all the pre or post processing for any dml operation for campaign object
 *
 * Create By	:	Mahendra Swarnkar
 *
 * Created Date	:	10/07/2017
 * 
 * Current Version:	v1.0
 * 
 * Revision Log	:	v1.0 - Created - Apollo Release - CR-20170927-11494 -  Added a new call for Entity field.
 * 
 * 
**/
trigger Campaigns on Campaign (before insert, before update) {

    try {
		
		//Check Event type
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            //Mahendra Swarnkar - 10/06/2017 - CR-20170927-11494 - Apollo Release--> Populate Entity from, if Primary_Program__c != null else Owner's Entity 
			CampaignTriggerHelper.populateEntityField(Trigger.New, Trigger.oldMap);
		}
    	
    	//return immediately if method returns true	
    	if(Util.areTriggersOnThisObjectBypassed('Campaign')) return;
                
        //Bypassing trigger according to the flag value
        if (Util.BypassAllTriggers) 
            return;
    
    } catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));

    //Catching all Exceptions
    } catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}