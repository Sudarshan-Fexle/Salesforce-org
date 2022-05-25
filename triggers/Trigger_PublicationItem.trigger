/** 
  * Description     :   Trigger is reponsible to haldle various events on Contract_Document__c object
  *
  * Created By      :   Subhash Garhwal
  *
  * Created Date    :   10/09/2017
  *
  * Revision Log    :   V1.0 Created - CR-20170928-11603
  *                    
  *         
**/
trigger Trigger_PublicationItem on Publication_Item__c (before insert, before update) {
      
      try {
        
        //Check Event type
        if(Trigger.isBefore) {
            
            //Check for request type
            if(Trigger.isInsert || Trigger.isUpdate){
                
                //Subhash Garhwal - 10/09/2017 - CR-20170928-11603 - Apollo Release
                Util.validateEntityValue(Trigger.new, Trigger.oldMap, 'Publication_Item__c', 'Entity__c', 'OwnerId', 'Entity__c', 'Owner', 'User');
            }
        }
        
        //Bypass flag
        if(Util.BypassAllTriggers || Util.areTriggersOnThisObjectBypassed('Publication_Item__c ')) return;
        
        
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