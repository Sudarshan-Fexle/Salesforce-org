trigger Trigger_ChatterRollup on FeedItem (after insert) {

    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('FeedItem')) return;

    try {

        // bypass flag
        if (Util.BypassAllTriggers) return;
        
        //Calling Helper Class Method
        ChatterRollupHelper.processRollups(Trigger.new);
    
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