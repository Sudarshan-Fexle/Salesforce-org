public with sharing class AutomatedDeploymentForBackSync {
    public AutomatedDeploymentForBackSync() {

    }

    public static void doDeployment(Id deploymentTrackId) {  
       
                                                                      
        //Retrieve Deployment Tracks 
        List<Deployment_Track__c> deploymentTrack = [Select Id, Deployment_Change_Request__c, 
                                                    Deployment_Release_Project__c,
                                                    Recent_Package_Retrieval__c,Is_Back_Sync__c,
                                                    Deployment_Group__c, Recent_Validation__c, Recent_Deployment__c,
                                                    Deployment_Change_Request__r.name, 
                                                    Deployment_Release_Project__r.Name ,
                                                    Source_Org__c, Target_Org__c From Deployment_Track__c 
                                                    Where Id =: deploymentTrackId AND Recent_Validation__r.Status__c = 'Completed' 
                                                    AND Recent_Validation__r.Validation_Status__c = 'Pass'];
                                                    

        //Check for the size.
        if(deploymentTrack != null && deploymentTrack.size() > 0) {


            PackageDeploymentController controller = new PackageDeploymentController();

            //Set the value on the variables. 
            controller.deploymentTrackRef = deploymentTrack[0];

            //Get the latest Validation Summary for the same deployment track. 
            controller.validationSummary = DeploymentWizardHelper.populateDeploymentProcessSummary(deploymentTrack[0].Recent_Validation__c);

            //Check on the validation summarry if the Quick deploy is availble then do the quick deployment else do the simple deployment. 
            if(controller.validationSummary != null && controller.validationSummary.Available_for_Quick_Deploy__c){
                controller.doQuickDeployment();
            }else{
                controller.doFullDeployment();
            }
            
            deploymentTrack[0].Deployment_Process__c = DeploymentWizardConstants.APP_STATE_DEPLOYMENT;
            update deploymentTrack[0];  

        }   
    }
}