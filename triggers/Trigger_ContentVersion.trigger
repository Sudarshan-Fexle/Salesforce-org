/**
 *   Purpose         :  This trigger to handle all the processing for ContentVersion object.
 *               
 *   Created By      :  Abhinav Sharma
 *   
 *   Created Date    :  09/01/2016
 *   
 *   Revision Logs   :  V_1.0 - Created - CR-20160224-9640
 *                      V_1.1 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *                      V_1.2 - Modified By - Subhash Garhwal - 05/29/2019 - CR-20181019-12685 -  Added a new call pushCalculatorToProposal
 *                      V_1.3 - Modified By - Victor Hanson - 09/13/2019 - CR-20181019-12685 - Added populateLogoOnAccount
 *
**/
trigger Trigger_ContentVersion on ContentVersion (after insert, after update) {
    
    //return immediately if method returns true 
    if(Util.areTriggersOnThisObjectBypassed('ContentVersion')) return;  

    try {
        
        //Bypass trigger logic if Util.byPassAllTriggers = true
        if (Util.BypassAllTriggers) 
            return;
        
        //Checking for the event type
        if (trigger.isAfter) {
            
            //Checking for the request type
            if(Trigger.isInsert) {
                
                //Calling helper class method
                ContentVersionTriggerHelper.grantAdditionalSharingonFiles(trigger.new);
                
                //05/29/2019 - Subhash Garhwal - 05/29/2019 - CR-20181019-12685 -  Added new call
                ContentVersionTriggerHelper.pushCalculatorToProposal(Trigger.new);
                
                //06/13/2019 - Mahendra Swarnkar - added new method
                ContentVersionTriggerHelper.grantPublicSharingOnFilesForCPQExceptionRequest(Trigger.new);
            }
            
            //Checking for update request type
            if (Trigger.isInsert || Trigger.isUpdate) {
                
                //09/13/2019 - Victor Hanson - CR-20181019-12685
                ContentVersionTriggerHelper.populateLogoOnAccount(Trigger.new);
            }
        }
        
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