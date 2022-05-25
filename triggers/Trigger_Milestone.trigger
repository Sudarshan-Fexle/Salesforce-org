//Updated by Abhinav Sharma - CR-20180917-12599 - 09/29/2018 added a new method - updateNameForPSAMileStone
trigger Trigger_Milestone on pse__Milestone__c (before insert, before Update, after insert, after update, after delete) {

	try { 

		//return immediately if method returns true
        if(Util.areTriggersOnThisObjectBypassed('pse__Milestone__c')) return;
		
        //Checking for the Before Case
        if(Trigger.isBefore) {
            
            //Check for the Insert Case
            if(trigger.isInsert || trigger.isupdate) {
            	MilestoneTriggerHelper.updateNameForPSAMileStone(trigger.New);        
            }
		}
        
        if (Trigger.isAfter){

        		//Update the Deployment Sign Off for Capitalization Checkbox on project based on Milestone updates
        		MilestoneTriggerHelper.updateDeploymentSignOffOnProject(Trigger.new, Trigger.oldMap);

        	}

	}

	//Catching DML Exceptions
    catch(DMLException e) {

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