/** 
  * Description     :   Trigger is reponsible to haldle various events on Contract_Document__c object
  *
  * Created By      :   Subhash Garhwal
  *
  * Created Date    :   10/09/2017
  *
  * Revision Log    :   V1.0 Created - CR-20170928-11578
  * 			V1.1 - Modified By - Dipesh Gupta - 04/06/2020 - CR-20200403-13902 - Create new field on Membership period.
  *                    
  *         
**/
trigger Trigger_ContractDocument on Contract_Document__c (before insert, before update, after insert, after delete) {

    try {
        
         //Bypass flag
        if(Util.BypassAllTriggers || Util.areTriggersOnThisObjectBypassed('Contract_Document__c')) return;
        
        //Check Event type
        if(Trigger.isBefore) {
            
            //Check for request type
            if(Trigger.isInsert || Trigger.isUpdate){
                
                //Subhash Garhwal - 10/09/2017 - CR-20170928-11578 - Apollo Release
                Util.validateEntityValue(Trigger.new, Trigger.oldMap, 'Contract_Document__c', 'Entity__c', 'Account__c', 'Entity__c', 'Account__r', 'Account');
            }
        }
        
        //Modified By - Dipesh Gupta - 04/06/2020 - CR-20200403-13902 - Create new field on Membership period.
        if(Trigger.isAfter)
        {
        	if(Trigger.isInsert || Trigger.isDelete)
            {
            	ContractDocumentTriggerHelper.populateUserOfLatestContractDocument(Trigger.new,Trigger.oldMap);    
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