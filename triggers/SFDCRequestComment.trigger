//V1.0 - Created
//V1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
//V1.2 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
trigger SFDCRequestComment on SFDC_Request_Comment__c (after insert, after update) {
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('SFDC_Request_Comment__c')) return;

    try {
    
        // update the associated Change Request so that it contains the proper IS_Team_Involved members
        ChangeRequestUtilities.UpdateISTeamInvolved(trigger.new);
        
    //Catching DML Exceptions
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