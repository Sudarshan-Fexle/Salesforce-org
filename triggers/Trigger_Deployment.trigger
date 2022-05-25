/**
*   Purpose         :   This Tirgger is used for update Project object fields which are have 
*                       lookup relationship with Deployment object with Deployment object fields.
*
*   Created By      :   Bhavi Sharma
* 
*   Created Date    :   05/25/2013
* 
*   Current Version :   V1.0 - Created  -   CR-20130328-2773
*                       V1.1 - Modified - CR-20130829-3543 - CMA - Elapsed Time Field - Moved to Prod Team - (Abhinav Sharma - 03-03-2014)
*                       V1.2 - Modified - Abhinav Sharma - 05/01/2014 - CR-20140408-5000
*                       V1.3 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
*                       V1.4 - Modified By - Abhinav Sharma - 10/17/2014 - CR-20140826-7138
*                       V1.5 - Modified BY - Abhinav Sharma - 02/03/2015 - CR-20141218-8365 - CPRM Deployment Milestone Updates
*            		V1.6 - Modified By - Subhash Garhwal - 09/12/2017 - CR-20170907-11185 - call method updateSiteLiveDateOnABCRevenue
*			V1.7 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
*            		V1.8 - Modified By - Deepak Kumawat - 10/06/2017 - Apollo Release -  Added a new call for Entity field.
*			V1.9 - Modified By - Abhinav sharma - CR-20180504-12211 - 08/20/2018 method Called populateAPSDeploymentDataOnAPSProject
*			V2.0 - Modified By - Dipesh Gupta - 11/19/2019 - CR-20190904-13311 - Added new method 'validateDeployment'
*			V2.1 - Modified By - Dipesh Gupta - 03/05/2020 - CR-20191223-13575 - Added  a new method - populateDeploymentFieldsFromProject
*			V2.2 - Modified By - Mahendra Swarnkar - 01/05/2021 - CR-20200615-14184 - Added  a new method - populateSiteLiveDateOnRevenue

**/
trigger Trigger_Deployment on Deployment__c (before insert, before update, before delete, after insert, after update, after delete) {

  
  try {
        
        //Check for trigger
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
            //Modified by Colin McGloin - 10/19 - Issue 11572-037 - Use Project as the provider of Entity since Account is not used on Deployment frequently
            Util.validateEntityValue(Trigger.new, Trigger.oldMap, 'Deployment__c', 'Entity__c', 'Project__c', 'Entity__c', 'Project__r', 'Project__c');
        
        //return immediately if method returns true  
        if(Util.areTriggersOnThisObjectBypassed('Deployment__c')) return;
        //Check for requests
        if (Trigger.isBefore) {
            
            // check for event
            if (Trigger.isInsert || Trigger.isUpdate) {
                DeploymentTriggerHelper.updateDeploymentStatus(Trigger.new);
                
                //Added By - Abhinav Sharma - 02/03/2015 - CR-20141218-8365 - CPRM Deployment Milestone Updates
                DeploymentTriggerHelper.updateCalculatedDateFields(Trigger.new);
		
		//Add a new Method. Dipesh Gupta - CR-20191223-13575
                DeploymentTriggerHelper.populateDeploymentFieldsFromProject(Trigger.New, Trigger.OldMap);

            }
            
            //Check for event
            if(Trigger.isUpdate || Trigger.isDelete) {
                
                //Added By - Dipesh Gupta - 11/19/2019 - CR-20190904-13311 - validateDeployment
                DeploymentTriggerHelper.validateDeployment(Trigger.new, Trigger.oldMap);
                
                //check for event
                if(Trigger.isDelete) {
                    //Added By - Mahendra Swarnkar - 01/05/2021 - CR-20200615-14184 - Validation Rule for Deployments on revenue lines
                    DeploymentTriggerHelper.populateSiteLiveDateOnRevenue(trigger.oldMap);
                }
            }
            
            //Check if the code is executed only on the test class. There is no other option to cover the Catch part of trigger. So the Best approch is this to throw a custom exception only for test class. 
            If(Test.isRunningTest() && ProgramTriggerHelper.CHECK_TRIGGER_EXCEPTION) {
                ProgramTriggerHelper.CustomExceptiontoCoverCatch();            
            }
            
        }
        if(Trigger.isAfter) {
            
            //Check for event
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Rollup field of Project through Deployment object fields
                DeploymentTriggerHelper.rollupDeploymentDataOnProject(Trigger.new, Trigger.oldMap);
                
                // CR-20180504-12211 - 08/20/2018 - Abhinav Sharma 
                //Calling a method to populate the Deployment Data to the Project. \
                //(Although we Can use rollupDeploymentDataOnProject but this will increase the Complexity on this Method so thought to seprate out those)
                DeploymentTriggerHelper.populateAPSDeploymentDataOnAPSProject(Trigger.new, Trigger.oldMap);
            }
            
            //Check for event
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
            
                //Added By - Abhinav Sharma - 03-03-2014 - CR-20130829-3543 - CMA - Elapsed Time Field - Moved to Prod Team 
                //Set First_Deployment_Signed_Off__c field on the Project with the earliest value from the "Deployment Sign Off (Actual)" field on the associated Deployment records 
                DeploymentTriggerHelper.populateFirstDeploymentSignedOff(Trigger.new, Trigger.oldMap);
                
                //Added By - Abhinav Sharma - 10/17/2014 - CR-20140826-7138
                //Call helper class method here to find Oldest Deployment Sign Off on Project record
                DeploymentTriggerHelper.populateDeploymentSignOffOldestOnProject(Trigger.new, Trigger.oldMap);
              
                //Check for event
                if(Trigger.isUpdate) {
                    
                    //Added By - Subhash Garhwal - 09/12/2017 - CR-20170907-11185
                    //Call helper class method here to populate the Site Live Date field value on all related ABC Revenue records 
                    DeploymentTriggerHelper.updateSiteLiveDateOnABCRevenue(Trigger.new, Trigger.oldMap);
                    
                    if(!SSCProjectGridController.byPass_DeploymentTrigger)
                      //Added by Abhinav Sharma - CR-20180917-12599 - 10/04/2018
                      DeploymentTriggerHelper.syncDeploymentWithMilestone(Trigger.new, Trigger.oldMap);
                }
                
                if(trigger.isInsert) {
                    
                    if(!SSCProjectGridController.byPass_DeploymentTrigger)
                        //New Method Call 
                        DeploymentTriggerHelper.createMilestoneOnDeploymentCreation(Trigger.new);
            	}
                
            
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