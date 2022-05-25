/**
*  Purpose         :  This Class is having all the automation logic to create the back sync deployment track and their respective cross check summeries. 
* 
*  Created By      :   Rajeev Jain
*
*  Created Date    :   07/27/2020
*
*  Revision Logs   :   V_1.0 - Created
**/
public without sharing class AutomatedValidationForBackSync {
    

    public static void doValidation(String deploymentTrackId) {

        //Retrieve Deployment Tracks 
        List<Deployment_Track__c> deploymentTrack = [Select Id, Deployment_Change_Request__c, 
                                                    Deployment_Release_Project__c, Is_Back_Sync__c,
                                                    Recent_Package_Retrieval__c,
                                                    Deployment_Group__c, Recent_Validation__c,
                                                    Deployment_Change_Request__r.name, 
                                                    Deployment_Release_Project__r.Name ,
                                                    Source_Org__c, Target_Org__c From Deployment_Track__c Where Id =: deploymentTrackId]; 

        //Check for the size.
        if(deploymentTrack != null && deploymentTrack.size() > 0) {

            //Calling validation code that will start the valdation to the target Sandbox. 
            ValidationController controller =  new ValidationController();
            controller.deploymentTrackRef = deploymentTrack[0];
           
            //Since this is a Sandbox Deployment
            controller.fullValidate();
            
            deploymentTrack[0].Deployment_Process__c = DeploymentWizardConstants.APP_STATE_VALIDATION;
            
            update deploymentTrack[0];
		}
    }
    
    public static void runTargetBackup(String deploymentTrackId) {
    	
        //Retrieve Deployment Tracks 
        List<Deployment_Track__c> deploymentTrack = [Select Id, Deployment_Change_Request__c, 
                                                    Deployment_Release_Project__c, Is_Back_Sync__c,
                                                    Recent_Package_Retrieval__c,
                                                    Deployment_Group__c, Recent_Validation__c,
                                                    Deployment_Change_Request__r.name, 
                                                    Deployment_Release_Project__r.Name ,
                                                    Source_Org__c, Target_Org__c From Deployment_Track__c Where Id =: deploymentTrackId]; 

    
    	//Check for the size.
        if(deploymentTrack != null && deploymentTrack.size() > 0) {

            //Calling validation code that will start the valdation to the target Sandbox. 
            ValidationController controller =  new ValidationController();
            controller.deploymentTrackRef = deploymentTrack[0];
           
            //run the Traget org Backup. 
            controller.runTargetBackup();
		}
    }

}