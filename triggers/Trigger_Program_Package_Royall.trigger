/* 
* Name          : shiftMassUpdatePrograms 
* Author        : Shift CRM
* Description   : Mass Updates programs of a Program Package who status was changed to Lost
*
* Maintenance History: 
* Date ------------ Name  ----  Version --- Remarks 
* 09/08/2013        Edward         1.0        Initial
* 20/08/2013        Edward         1.1        Update code to display error when update fails
* 24/06/2016        Rajeev         1.2        Royall SFDC Schema release - Manual code migration.
*                                              - Recreated By -  Rajeev Jain - To standarise and follow Advisory best practices
*                                              - Created new trigger and merge code of shift_mass_update_programs trigger on Program Package from Royall Instance to Corporate Instance
*                                              - Created new additional helper class, and moved whole code from Trigger to helper class.
*                                              - Merged from following two triggers : shift_mass_update_programs, Shift_ProgramPackage
*  
*  09/20/2016   Subhash            1.3        CR-20160817-10134
*  03/20/2017   Victor             1.4        CR-20170110-10605 - Added reference to updateMembershipStatus_Royall()
*  08/20/2017   Dipesh Gupta       1.5        CR-20170221-10712 - calling a new method updateRoyallProgramJobNo.
*  09/27/2017  Subhash Garhwal     1.6        CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
*  09/30/2018  Abhinav Sharma      1.7        CR-20180809-12494 - new Method Called  updateProgramPackageOnMembership
*  11/27/2018  Subhash Garhwal     1.8        CR-20181113-12746 - Commented out the method "updateMembershipStatus_Royall" invocation
*  01/08/2021  Mahendra Swarnkar   1.9	      CR-20201204-14725
*/
trigger Trigger_Program_Package_Royall on Program_Package__c (before insert, before update, after insert, after update, after delete, after undelete) {
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Program_Package__c')) return;	

    try{
        // if a trigger bypass is active, return immediately without processing
        if (Util.BypassAllTriggers) return;
        
        //Check for the request Type
        if(Trigger.isBefore) {
            
            if (Account_Status_Management__c.getOrgDefaults().Enable_Update_Account_Status_Trigger__c) {
                System.debug('############1');
                //update account status
                Shift_StatusRollup_Handler.setAccountStatus(trigger.new);
            }
        }
        if (Trigger.IsAfter) {
            
            //Commented - 9/20/2016 - Subhash Garhwal - CR-20160817-10134
            //Check for All three operation on after event
            if (Account_Status_Management__c.getOrgDefaults().Enable_Update_Account_Status_Trigger__c) {
                
                /**Commented by - Subhash - CR-20181113-12746 - 11/27/2018 -- Starts from here*/ 
                /*
                //update the related parent institution's royall memberships - CR-20170110-10605
                ProgramPackageRoyallTriggerHelper.updateMembershipStatus_Royall(trigger.old, trigger.new);
                */
                /**Commented by - Subhash - CR-20181113-12746 - 11/27/2018 -- Starts from here*/ 
                //Added - 9/20/2016 - Subhash Garhwal - CR-20160817-10134
                
                //Check for event
                if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete || Trigger.isUnDelete) {
                	
                	System.debug('############2');
                    Shift_StatusRollup_Handler.accountRollupsRoyal(Trigger.new, Trigger.oldMap);
                }
                
            }
            
            //Check if Update
            if(Trigger.isUpdate)  {
            	
            	System.debug('############3');      
                ProgramPackageRoyallTriggerHelper.massUpdatePrograms(Trigger.New, Trigger.oldMap);
                System.debug('############4');
                //Calling a new Method to update the Job Number field on the royall program.
                ProgramPackageRoyallTriggerHelper.updateRoyallProgramJobNo(Trigger.New, Trigger.oldMap);  
            	System.debug('############5');
                
                //Added By - Mahendra Swarnkar - 01/08/2021 - CR-20201204-14725
                //Calling a new Method to update the Program Cost on the Membership.
                ProgramPackageRoyallTriggerHelper.updateProgramCostOnMembership(Trigger.New, Trigger.oldMap);
            }
            
            //Check for the trigger case after insert/update/Delete
            if(trigger.isInsert || trigger.isUpdate || trigger.isDelete) {
            	System.debug('############6');
                ProgramPackageRoyallTriggerHelper.updateProgramPackageOnMembership(trigger.new, trigger.oldMap);
            }
        }
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