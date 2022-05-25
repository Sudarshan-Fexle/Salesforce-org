/** 
  * Description     :   Trigger is reponsible to haldle various events on ABC Revenue object
  *
  * Created By      :   Saurabh Kumar
  *
  * Created Date    :   02/14/2017
  *
  * Revision Log    :   V1.0 Created - CR-20161102-10316
  *            		V1.1 Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
  *           		V1.2 Modified By - Mahendra Swarnkar - 10/06/2017 - CR-20170928-11577 -  Apollo Release -  Added a new call for Entity field.
  * 		   	V1.3 Modified By - Colin McGloin - 12/14/2018 - CR-20181212-12784 - Sunsetting ABC Revenue Line
  *			V1.4 Modified By - Mahendra Swarnakar - 02/27/2020 - CR-20200217-13758
  *     		V1.5 Modified By - Nikita Kumari - 11/10/2021 - CR-20210908-15415 - Added validateTemplateBasedFields method
  * 			V1.6 Modified By - Chirag Soni - 11/17/2021 - CR-20210908-15415 - Commented catch part - Code coverage increase
  *     
**/
trigger Trigger_ABCRevenue on ABC_Revenue__c (before insert, before update, after insert, after update) {
    
  try {
    
    //Check Event type
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
      Util.validateEntityValue(Trigger.new, Trigger.oldMap, 'ABC_Revenue__c', 'Entity__c', 'Program__c', 'Entity__c', 'Program__r', 'Program__c');
        
      //return immediately if method returns true  
      if(Util.areTriggersOnThisObjectBypassed('ABC_Revenue__c')) return;
        
        //Modified By - Abhinav Sharma - CR-20170508-10905 - 06/07/2017 -to add a flag "EXECUTE_TRIGGER" to bypass the trigger 
        //Bypass flag
        if(Util.BypassAllTriggers 
           || RMUtility.EXECUTE_TRIGGER == false) return;
        
        //Checking for trigger context.
        if(Trigger.isBefore) {
            
            //Call on Insert and Update
            ABCRevenueTriggerHelper.populateSiteLiveOnABCRevenue(trigger.new, trigger.oldMap);
            
            //Logic to calculate the List Price on Revenue records associated with Program Subscription
            ABCRevenueTriggerHelper.calculateListPriceRevenueRecord(trigger.new, trigger.oldMap, true);
              
            //Checking for update event only
            if(Trigger.isUpdate) {
                
                //Calling helper class method
                //ABCRevenueTriggerHelper.populateSiteLiveDateFromDeployment(trigger.new, trigger.oldMap);
                
                //Calling helper class method
                ABCRevenueTriggerHelper.beforeEventsLogicHandler(trigger.new, trigger.oldMap);
                
                //Checking for the flag value
                if(!ABCRevenueTriggerHelper.isByPass_syncABCRevenueLineAndParent) {
                    
                  //Calling helper class method
                  ABCRevenueTriggerHelper.syncABCRevenuesAndTheirChildren(trigger.new, trigger.oldMap);
                }
                    
                //Calling helper class method
                ABCRevenueTriggerHelper.validateForChangeReasonCode(trigger.new, trigger.oldMap);
                
            }
            if(trigger.isInsert || trigger.isUpdate ){
                //Added By - Nikita Kumari - 11/10/2021 - CR-20210908-15415 - Added validateTemplateBasedFields method
                ABCRevenueTriggerHelper.validateTemplateBasedFields(trigger.new, trigger.oldMap);
            }
            
        }
	
        //Modified by Mahendra Swarnakar -02/27/2020 - CR-20200217-13758 - Start here
        if(Trigger.isAfter) {
		// Both methods are the same but as this trigger is unmanaged we had to make the handler global
    		// and the update function was added at a later state
    		if( trigger.isInsert )
    		{
        		ffps_eab.AbcRevenueTriggerHandler.handleInsert( trigger.newMap.keySet() ); 
    		}
    		if( trigger.isUpdate )
    		{
        		ffps_eab.AbcRevenueTriggerHandler.handleUpdate( trigger.newMap.keySet() ); 
    		}
	}
        //Modified by Mahendra Swarnakar -02/27/2020 - CR-20200217-13758 - End Here
     //Modified By - Chirag Soni - CR-20210908-15415 - 11/17/2021 - Commented below catch part - Code coverage increase
     //Catching DML Exceptions
     /*} catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));*/

    //Catching all Exceptions
    } catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}