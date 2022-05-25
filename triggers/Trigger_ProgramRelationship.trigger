/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Program Relationship
 *
 *  Created By      :   Subhash Garhwal
 *
 *  Created Date    :   06/25/2015
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20150618-9013
 *						V_1.1 - Modified - Subhash Garhwal - CR-20150618-9013 - new call added validateCPCs
 *						V_1.2 - Code Added - Subhash Garhwal - CR-20150729-9114 - New incentiveChangeLog method called.
 *						V_1.3 - Code Modified - Subhash Garhwal - 10/15/2015 - CR-20151015-9325
 *						V_1.4 - Modified - Subhash Garhwal - Issue--CR10808--QA--00005222 - 08/25/2017 - Added a new call validateProgramFamily method.
 *						V_1.5 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *                  
 **/
trigger Trigger_ProgramRelationship on Program_Relationship__c (after update, before delete, before insert, before update, after insert) {
    
   
   //return immediately if method returns true	
   if(Util.areTriggersOnThisObjectBypassed('Program_Relationship__c')) return;

   try {
    
        //Bypass flag
        if (Util.BypassAllTriggers) return;
        
        //Check for trigger context
        if(Trigger.isBefore) {
            
            //Check for trigger event
            if(Trigger.isDelete) {
                
                //Call helper class method
                //This method is used to check related Program Perspective's In Use values count and if values > 0, than throw an exception
                ProgramRelationshipTriggerHelper.validateBeforeDelete(Trigger.old); 
                
                //Call helper class method
                //Method to notify related Program Perspective's Business Owner, when new record inserted or update occurs to the following fields:
                //Name, Effective_Start__c, Effective_End__c or record is deleted.
                ProgramRelationshipTriggerHelper.keyInformationChangedNotification(Trigger.new, Trigger.oldMap);
                
                //Call helper class method
                //This method will delete all the CC record under the CPC
                ProgramRelationshipTriggerHelper.deleteCollectionContents(Trigger.old);
            }
            
            //Check for trigger event
            if(Trigger.isInsert || Trigger.isUpdate) {
            	
            	//Code Added - Padmesh Soni - 08/12/2015 - CR-20150729-9114 - New method renameCPC called .
            	//Call helper class method
                //This method is to rename CPC
      			ProgramRelationshipTriggerHelper.renameCPC(Trigger.new, Trigger.oldMap);
      			
            	//Call helper class method
            	//This methiod is to validate the data before inserting into database. If there is any Duplicate, display error message to user.
            	ProgramRelationshipTriggerHelper.validateCPCs(Trigger.new, Trigger.oldMap);
            }
        }
        
        //Check for trigger context
        if(Trigger.isAfter) {
            
            //Check for trigger events
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method
                //Method to notify related Program Perspective's Business Owner, when new record inserted or update occurs to the following fields:
                //Name, Effective_Start__c, Effective_End__c or record is deleted.
                ProgramRelationshipTriggerHelper.keyInformationChangedNotification(Trigger.new, Trigger.oldMap);
                
                //Code added - Padmesh Soni (07/10/2015) - CR-20150618-9014
                //Call helper class method
                //Method to create Collection Contents on CPC on creation and delete existing on updation
                ProgramRelationshipTriggerHelper.associateCollectionContentsOnCPC(Trigger.new, Trigger.oldMap);
                
                //Code added - Subhash Garhwal - 7/29/2015 - CR-20150618-9014
            	//Call helper class method
                //Method to create Collection Contents on CPC on creation
                ProgramRelationshipTriggerHelper.validateCollectionContentsOnCPC(Trigger.new, Trigger.oldMap);
            
            	//Code Added - Subhash Garhwal - 08/04/2015 - CR-20150729-9114 - New method incentiveChangeLog called .
            	//Call helper class method
                //This method is to LogChanges
      			//ProgramRelationshipTriggerHelper.incentiveChangeLog(Trigger.new, Trigger.oldMap);
      			
      			//08/25/2017 - Subhash Garhwal - Issue--CR10808--QA--00005222
                ProgramRelationshipTriggerHelper.validateProgramFamily(Trigger.new, Trigger.oldMap);
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