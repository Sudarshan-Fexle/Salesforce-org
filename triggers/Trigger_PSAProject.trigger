/**
    *  @description    :   Trigger to Insert the manipulation on the Pse__Project Objec
    * 
    * Created By       :   Abhinav Sharma 
    * 
    * Revision Log     :   Created Abhinav Sharma - 09/19/2018 - CR-20180917-12599.
**/

trigger Trigger_PSAProject on pse__Proj__c (before insert, before update) {
	
    try { 
       
        //Calling Methods.
        //return immediately if method returns true
        if(Util.areTriggersOnThisObjectBypassed('pse__Proj__c')) return;
		
        //Another Bypass
        if(Util.ByPassAllTriggers) return;
        
        //Calling methods - 
        if(trigger.isBefore) {
        	
            //Check for the is insert Case
            if(trigger.isInsert || trigger.isUpdate) {
                PSAProjectTriggerHelper.handleBeforeLogics(trigger.new);
            }
        }
    }catch(DMLException e) {

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