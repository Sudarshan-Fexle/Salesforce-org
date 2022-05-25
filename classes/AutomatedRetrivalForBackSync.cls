public without sharing class AutomatedRetrivalForBackSync {
    
    public Static void retrieveForBackSyncDeployment(Id deploymentTrackId) {
        
        //Calling Retrival Classes that will do all the necessary Job here. 

        if(String.isNotBlank(deploymentTrackId)) {

            //Getting Deployment Track. 
            List<Deployment_Track__c> deploymentTrack = [Select Id, Deployment_Change_Request__c, 
                                                            Deployment_Release_Project__c, Recent_Package_Retrieval__c,
                                                            Deployment_Group__c, Is_Back_Sync__c,
                                                            Deployment_Change_Request__r.name, 
                                                            Deployment_Release_Project__r.Name ,
                                                            Source_Org__c, Target_Org__c From Deployment_Track__c
                                                            Where  Id =: deploymentTrackId];

            if(deploymentTrack != null && deploymentTrack.size() > 0) {

                DeploymentWizardBean appProperty = new DeploymentWizardBean();
                appProperty.deploymentGroupId = deploymentTrack[0].Deployment_Group__c;
                if(String.isNotBlank(deploymentTrack[0].Deployment_Release_Project__c))
                	appProperty.releaseName  = deploymentTrack[0].Deployment_Release_Project__r.Name;
                if(String.isNotBlank(deploymentTrack[0].Deployment_Change_Request__c))
                	appProperty.crName = deploymentTrack[0].Deployment_Change_Request__r.name;
                  
                appProperty.selectedSourceCon = deploymentTrack[0].Source_Org__c;
                appProperty.selectedTargetCon = deploymentTrack[0].Target_Org__c;
                                                                     
                //Calling Retrival.
                PackageRetrievalController controller = new PackageRetrievalController();
                controller.deploymentTrackRef = deploymentTrack[0];
                controller.appPropertiesRef = appProperty; 

                //Calling the actual method that will retrieve the package. 
                controller.retrievePackage();
                
                deploymentTrack[0].Deployment_Process__c = DeploymentWizardConstants.APP_STATE_PACKAGE_RETRIEVAL;
                update deploymentTrack[0];
			}
        }
    }
}