/**
*  Purpose         :  This Class is having all the automation logic to create the back sync deployment track and their respective cross check summeries. 
* 
*  Created By      :   Rajeev Jain
*
*  Created Date    :   07/27/2020
*
*  Revision Logs   :   V_1.0 - Created
**/
public without sharing class AutomatedCrossCheckForBackSync {
    
    //This method is used to do cross check with respect to full Sandboxes and check the results 
    //if there are any overlapping then no deployment will be performed and if there are no overlapps then there will be automatic deployment will be performed. 
    public static void doCrossCheckAndCreatebackSyncRecords(Set<Id> setOfDeploymentTracks) {

        if(setOfDeploymentTracks != null && setOfDeploymentTracks.size() > 0) {
            
            //Map to hold the Deployment track.
            Map<String, Connection__c> mapOfConnections = new Map<String, Connection__c>();
            List<Deployment_Track__c> deploymenttracksToBeInserted = new List<Deployment_Track__c>();
            List<Deployment_Track__c> deploymentTrackToBeUpdated = new List<Deployment_Track__c>();
            System.debug('Connections 1 : '+[SELECT ID, Sandbox_Type__c  FROM Connection__c]);
            //Get all the connections where Sandbox types is full so we can do cross check around it. 
            for(Connection__c con : [Select Id, Name, Sandbox_Type__c,  Sandbox_Refresh_Date__c From Connection__c Where  Sandbox_Type__c = 'Full']) {
                mapOfConnections.put(con.Name, con);  
            }

            //Getting the deploymentTrack. 
            for(Deployment_Track__c dTrack : [Select Id, Deployment_Change_Request__c, Deployment_Release_Project__c, Is_Back_Sync__c,
                                              Source_Org__c, Target_Org__c From Deployment_Track__c
                                              Where Id IN: setOfDeploymentTracks AND  Back_Sync_Records_Created__c = false AND Available_For_Back_Sync__c = true])   {
                
                for(Connection__c con : mapOfConnections.values()) {

                    /*Since in the org we assume that all the deployment path will be From Full SB to Production so there will be 1 Full Sb 
                    always there from where deployment originate so we should exclude that this sb from our back sync */
                    if(con.Name == dTrack.Source_Org__c){
                        continue;
                    }

                    //Creating the Deployment track records under the main deployment track these are actually back sync records.
                    Deployment_Track__c deploymentTrack = new Deployment_Track__c();
                    deploymentTrack.Source_Org__c = dTrack.Source_Org__c;
                    deploymentTrack.Target_Org__c = con.Name;
                    deploymentTrack.Deployment_Change_Request__c = dTrack.Deployment_Change_Request__c;
                    deploymentTrack.Deployment_Release_Project__c = dTrack.Deployment_Release_Project__c;
                    deploymentTrack.Deployment_Process__c = DeploymentWizardConstants.APP_STATE_NEW;
                    deploymentTrack.Start_Date__c = DateTime.now();
                    deploymentTrack.Started_By__c = UserInfo.getUserId();
                    deploymentTrack.Parent_Deployment_Track__c = dTrack.Id;
                    deploymentTrack.Is_Env_Setup_Completed__c = true;
                    deploymentTrack.Sandbox_Refresh_Date__c = con.Sandbox_Refresh_Date__c;
                    DeploymentWizardHelper.updateMaualStepsDetails(deploymentTrack);
                    
                    deploymenttracksToBeInserted.add(deploymentTrack);
                }

                deploymentTrackToBeUpdated.add(new Deployment_Track__c (Id = dTrack.Id, Back_Sync_Records_Created__c = true));
            }
            
            if(deploymenttracksToBeInserted.size() > 0) {

                insert deploymenttracksToBeInserted;
                update deploymentTrackToBeUpdated;

                
                //Deployment Process to be Inserted Instance
                Map<Id, Deployment_Process_Summary__c> mapOfdeploymentProcessSummeries = new Map<Id, Deployment_Process_Summary__c>();

                //Creating the Process Summaries record now. In back sync process we will directly take the user to the Crossc check and avoid test pages. 
                Id crossCheckrecordTypeId = Schema.SObjectType.Deployment_Process_Summary__c.getRecordTypeInfosByDeveloperName().get(DeploymentWizardConstants.DEPLOYMENT_PROCESS_CROSSCHECK_SUMMARY).getRecordTypeId();
                
                for(Deployment_Track__c dT : deploymenttracksToBeInserted) {
                    
                    Deployment_Process_Summary__c processSummary = new Deployment_Process_Summary__c();
                    processSummary.Deployment_Track__c = dT.Id;
                    processSummary.RecordTypeId = crossCheckrecordTypeId;
                    processSummary.Run_By__c = UserInfo.getUserId();
                    processSummary.Start_Date__c = DateTime.now();
                    processSummary.Release_Project__c = dT.Deployment_Release_Project__c;
                    processSummary.Change_Request__c = dT.Deployment_Change_Request__c;
                    processSummary.Status__c = DeploymentWizardConstants.DEPLOYMENT_PROCESS_STATUS_STARTED;

                    //Populate Cr and Releaase Status
                    DeploymentWizardHelper.populateCRAndReleaseStatus(dT, processSummary);
                    mapOfdeploymentProcessSummeries.put(dT.Id, processSummary);
                }
                
                system.debug('@@ mapOfdeploymentProcessSummeries before @@ '+mapOfdeploymentProcessSummeries);
             
                //Check the size of list and insert
                if(mapOfdeploymentProcessSummeries.size() > 0){
                    
                    insert mapOfdeploymentProcessSummeries.values();
            
                        system.debug('@@ mapOfdeploymentProcessSummeries.values() after  @@ '+mapOfdeploymentProcessSummeries.values());
                       
                        
                    for(Deployment_Track__c dT  : deploymenttracksToBeInserted) {

                        String deploymentTrack = JSON.serialize(dT);
                        String processSummaries = JSON.serialize(mapOfdeploymentProcessSummeries.get(dT.Id));
                        system.debug('@@ processSummaries  @@ '+processSummaries );
                       
                        //Calling a future Method to avoid sOQL issue if there are n number of record comes at the same time. 
                        crossCheckAndSaveDetailsToProcessSummary(deploymentTrack, processSummaries);  
                             
                    }
                }
            }
        }
    }

    @future
    public static void crossCheckAndSaveDetailsToProcessSummary(String deploymentTrack, String crossCheckSummary) {

        //Deserializing both the values
        Deployment_Track__c dT = String.isNotBlank(deploymentTrack) ? (Deployment_Track__c) JSON.deserialize(deploymentTrack, Deployment_Track__c.class) : null;
        Deployment_Process_Summary__c deploymentSummary = String.isNotBlank(deploymentTrack) ? (Deployment_Process_Summary__c) JSON.deserialize(crossCheckSummary, Deployment_Process_Summary__c.class) : null;
    
        //Calling a method that will check for cross check. 
        List<CrosscheckResultsWrapper>  resultsWrapper = CrosscheckHelper.runAndSaveCrosscheckResults(dT, deploymentSummary);

        system.debug('@@ resultsWrapper resultsWrapper  @@ '+resultsWrapper );
        //Checking for the size of the wrapper to get the details of overlapping modification and related CR details. 
        //If we found the CR overlapped then we will leave this as it is but if there is any CR without the overlapp we will stamp the Deployment group on that CR. 
        if(String.isNotBlank(dT.Deployment_Release_Project__c) && resultsWrapper.size() > 0) {
            
            List<SFDC_Change_Request__c> changeRequestToBeUpdatedWithGroups = new List<SFDC_Change_Request__c>();

            integer totalCRs = 0;
            integer totalOverlappedCRs = 0;
            integer totalNonOVerlappedCRs = 0;
            
            //Get the details of the CRs for this Release. 
            for(SFDC_Change_Request__c cR : [Select Id, Name From SFDC_Change_Request__c Where Release__c =: dT.Deployment_Release_Project__c ]) {

                Boolean isCROvelappedWithOtherOnes = false;

                for(CrosscheckResultsWrapper result : resultsWrapper) {

                    //Checking if the CR found overlapped?
                    if(result.mainMod != null && String.isNotBlank(result.mainMod.CR_Number__c) && result.mainMod.CR_Number__c == cR.Id) {
                        isCROvelappedWithOtherOnes = true;
                    } 
                }

                //Check if the CR is not matched with any of the other ones then we are good to go and add it to the related Deployment Group. 
                if(!isCROvelappedWithOtherOnes) {
                    changeRequestToBeUpdatedWithGroups.add(new SFDC_Change_Request__c(Id = cR.Id));
                    totalNonOVerlappedCRs++;
                    
                }else{
                    totalOverlappedCRs++;
                }

                totalCRs++;
            }   

            dT.Total_CR__c = totalCRs;
            dT.Total_Overlapping_CR__c = totalOverlappedCRs;
            dT.Total_Non_Overlapping_CR__c = totalNonOVerlappedCRs;

            //Check the size of perticular list to know if there are any CRs with no overlapping? if yes then cfreate a group and assign non overlapp Cr to this group.
            if(changeRequestToBeUpdatedWithGroups.size() > 0) {

                //Getting Record Types for the Deployment Group. There are 2 Record Type One is for Parent and One is for Child. 
                String cONTAINERRECORDTYPE = Schema.SObjectType.Deployment_Group__c.getRecordTypeInfosByDeveloperName().get('Container').getRecordTypeId();
                String sUBGROUPRECORDTYPE = Schema.SObjectType.Deployment_Group__c.getRecordTypeInfosByDeveloperName().get('Sub_Group').getRecordTypeId();

                Deployment_Group__c depGroup = new Deployment_Group__c();
                depGroup.RecordTypeId = cONTAINERRECORDTYPE;
                depGroup.Total_Number_Of_Change_Request__c = changeRequestToBeUpdatedWithGroups.size();
                insert depGroup;

                //List tp hold the Deployment Groups that holds the Change Request and create the sub Group records with parent container Group. 
                List<Deployment_Group__c> deploymentSubGroups = new List<Deployment_Group__c>();
                
                //Now we have the inserted group with us, we can update this to the non overlapped CRs. 
                for(SFDC_Change_Request__c cR : changeRequestToBeUpdatedWithGroups) {

                    deploymentSubGroups.add(new Deployment_Group__c(Parent_Deployment_Group__c = depGroup.Id, Change_Request__c = cR.Id, RecordTypeId = sUBGROUPRECORDTYPE));
                }
                
                //Adding this group to the deployment Track as well. 
                dT.Deployment_Group__c = depGroup.Id;

                insert deploymentSubGroups;
            }
        }
                        
        //Update the Process Summary Records As Well
        deploymentSummary.Total_Overlapping_found__c = resultsWrapper.size();
        deploymentSummary.End_Date__c = DateTime.now();
        deploymentSummary.Status__c = DeploymentWizardConstants.DEPLOYMENT_PROCESS_STATUS_COMPLETED;
        
        dT.Recent_Crosscheck__c =  deploymentSummary.Id;
        dT.Deployment_Process__c = DeploymentWizardConstants.APP_STATE_CROSSCHECK;
        
        update deploymentSummary;
        system.debug('@@ deploymentSummary @@ '+deploymentSummary);
        update dT;
        system.debug('@@ dT @@ '+dT);
    }
}