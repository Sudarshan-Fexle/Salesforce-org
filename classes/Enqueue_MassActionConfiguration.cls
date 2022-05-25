/**
 *  Description     :   Enqueue Class is used to execute the Mass Action Configuration. 
 * 						This will run on every night via Batch_MassActionConfiguration
 *                      Logic : 
 *                      When Invite List & Mass Action Configuration fields are both populated
                        1) Query for the Mass Action Configuration record where Id = EABEvent.Mass_Action_Configuration__c
                        2) Update the Mass Action Configuration's dca_mass_action__Target_Apex_Script__c with the code below
                        note: when populating the apex script field, replace the following text values:
                        1) Replace CAMPAIGN_ID with the Id of the EABEvent.Invite_List__c campaign
                        2) Replace REPORT_C﻿OLUMN_NAME with the value from the MassActionConfiguration.dca_mass_action__Source_Report_Column_Name__c
 *
 *  Created By      :   Saurabh Kumar
 *
 *  Created Date    :   11/24/2020
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20201117-14698
 *                      
 **/
public class Enqueue_MassActionConfiguration implements Queueable{
	
    //Variable to hold EAB Event which should be enque
    public Advisory_Event__c eabEventToEnqueue;
    
    public Enqueue_MassActionConfiguration(Advisory_Event__c eabEventToEnqueue){
        
        this.eabEventToEnqueue = eabEventToEnqueue;
    }
    
    //Method to enqueue the jobs
    public void execute(QueueableContext context) {
        
        if(eabEventToEnqueue == null)
            return;
        //create list of mass action scheduler confriguration requests to execute
        List<dca_mass_action.MA_RunConfigInvocable.Request> requests = new List<dca_mass_action.MA_RunConfigInvocable.Request>();
        
        //process a single Mass Action Configuration in the execute method of the batch just in case there are errors
        dca_mass_action.MA_RunConfigInvocable.Request req = new dca_mass_action.MA_RunConfigInvocable.Request();
        req.configId = eabEventToEnqueue.Mass_Action_Configuration__c;
        requests.add(req);
        
        //execute the request and get the response
        try {
            if(!Test.isRunningTest())
            	dca_mass_action.MA_RunConfigInvocable.execute(requests);
        }
        catch(Exception ex) {
            //Checking Error Message emailed it to SFAdmin.
            Util.sendBatchStatus('Batch_MassActionConfiguration', ex.getMessage(), Label.Salesforce_Admin_Email); 
        }
    }
}