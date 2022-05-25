/**
*  Purpose         :  This Class is having all the automation logic method on Deployment Process Summary object.
* 
*  Created By      :   Rajeev Jain
*
*  Created Date    :   07/27/2020
*
*  Revision Logs   :   V_1.0 - Created
**/
public class DeploymentProcessSummaryTriggerHelper
{   
  
    public final static Id DEPLOYMENT_PROCESS_SUMMARY_RT_ID = Schema.SObjectType.Deployment_Process_Summary__c.getRecordTypeInfosByDeveloperName().get(DeploymentWizardConstants.DEPLOYMENT_PROCESS_DEPLOYMENT_SUMMARY).getRecordTypeId();
    public final static Id DEPLOYMENT_PROCESS_VALIDATION_RT_ID = Schema.SObjectType.Deployment_Process_Summary__c.getRecordTypeInfosByDeveloperName().get(DeploymentWizardConstants.DEPLOYMENT_PROCESS_VALIDATION_SUMMARY).getRecordTypeId();
    public final static Id DEPLOYMENT_PROCESS_PACKAGE_RETRIVAL_RT_ID = Schema.SObjectType.Deployment_Process_Summary__c.getRecordTypeInfosByDeveloperName().get(DeploymentWizardConstants.DEPLOYMENT_PROCESS_PACKAGE_RETRIEVAL_SUMMARY).getRecordTypeId();

    public static void checkProcessSummaryUpdates(List<Deployment_Process_Summary__c> newDeploymentProcessSummary, Map<Id, Deployment_Process_Summary__c> mapOldDeploymentProcessSummaries)
    {   
        Set<Id> setOfDeploymentTrackIdsDeploymentSummary = new Set<Id>();
        Set<Id> setOfDeploymentTrackIdsValidation = new Set<Id>();
        Set<Id> setofDeploymentTrackValidation_Passed = new Set<Id>();
        Set<Id> setOfDeploymentTrackIdsDeploymentSummary_Passed = new set<Id>();
        
        for(Deployment_Process_Summary__c deployPS : newDeploymentProcessSummary)   
        {
            if(String.isNotBlank(deployPS.Status__c) && !deployPS.is_Back_Sync__c)
            {   
                if(deployPS.RecordTypeId == DEPLOYMENT_PROCESS_SUMMARY_RT_ID) {   
                    
                    /*if(mapOldDeploymentProcessSummaries != null 
                       && mapOldDeploymentProcessSummaries.get(deployPS.Id).Deployment_Status__c != deployPS.Deployment_Status__c && 
                       deployPS.Deployment_Status__c == 'Pass'){
                        setOfDeploymentTrackIdsDeploymentSummary_Passed.add(deployPS.Deployment_Track__c);
                    }else*/ 
                    if(deployPS.Status__c == DeploymentWizardConstants.DEPLOYMENT_PROCESS_STATUS_STARTED ) {
                        setOfDeploymentTrackIdsDeploymentSummary.add(deployPS.Deployment_Track__c); 
                    }
                }else if(deployPS.RecordTypeId == DEPLOYMENT_PROCESS_VALIDATION_RT_ID && mapOldDeploymentProcessSummaries != null) {
                    
                    if(mapOldDeploymentProcessSummaries.get(deployPS.Id).Validation_Status__c != deployPS.Validation_Status__c 
                       && deployPS.Validation_Status__c == 'Pass') {
                   
                        setofDeploymentTrackValidation_Passed.add(deployPS.Deployment_Track__c);
                    
                    }else if(mapOldDeploymentProcessSummaries.get(deployPS.Id).Status__c != deployPS.Status__c && 
                             deployPS.Status__c == DeploymentWizardConstants.DEPLOYMENT_PROCESS_STATUS_IN_PROGRESS){
                        setOfDeploymentTrackIdsValidation.add(deployPS.Deployment_Track__c);
                    }
                } 
            }
        }
        
        //Set to hold the temp values of another sets. 
        Set<Id> setTempDeploymentTracks = new Set<Id>();
        setTempDeploymentTracks.addAll(setofDeploymentTrackValidation_Passed);   
        setTempDeploymentTracks.addAll(setOfDeploymentTrackIdsDeploymentSummary);  
        //setTempDeploymentTracks.addAll(setOfDeploymentTrackIdsDeploymentSummary_Passed);
        //setTempDeploymentTracks.addAll();
        
                
        if(setTempDeploymentTracks.size() > 0)
        {
            List<Deployment_Track__c> listOfDeploymentTrack = [SELECT Id, Name, Deployment_Process__c, 
                                                               (SELECT Id, Name, Deployment_Process__c FROM Deployment_Tracks__r) 
                                                               FROM Deployment_Track__c 
                                                               WHERE Id IN : setTempDeploymentTracks AND Available_For_Back_Sync__c = true];
            if(listOfDeploymentTrack.size() > 0)
            {
                for(Deployment_Track__c dPTrack : listOfDeploymentTrack)
                {
                    if(dPTrack.Deployment_Tracks__r.size() > 0)
                    {   
                        for(Deployment_Track__c dT : dPTrack.Deployment_Tracks__r) {
                            
                            String processName = '';
                            
                            //Checking condition and accordingly invloking the method to handle next tasks. 
                            if(setofDeploymentTrackValidation_Passed.contains(dPTrack.Id) ) {
                                processName = 'backSync_PackageRetrival';
                            }  
                            
                            //Checking condition and accordingly invloking the method to handle next tasks. 
                            if(setOfDeploymentTrackIdsDeploymentSummary.contains(dPTrack.Id)) {
                                processName = 'backSync_PackageValidation';
                            }
                                
                            //Checking condition and accordingly invloking the method to handle next tasks. 
                            if(setOfDeploymentTrackIdsDeploymentSummary_Passed.contains(dPTrack.Id)) {
                                processName = 'backSync_PackageDeployment';
                            }
                            
                            if(String.isNotBlank(processName)){
                                System.enqueueJob(new Enqueue_ProcessSummariesActions(dT.Id, processName));  
                            }
                        }   
                    }
                }
            }
        }

        if(setOfDeploymentTrackIdsValidation.size() > 0) {
            //Calling a seperate class that have logic to create the back sync records. 
            AutomatedCrossCheckForBackSync.doCrossCheckAndCreatebackSyncRecords(setOfDeploymentTrackIdsValidation);
        }
   }
   
    //This Method is used to retrieve the target Org Back Up. 
    public static void runTargetOrgBackupForBackSyncWhenValidationPassed(List<Deployment_Process_Summary__c> newDeploymentProcessSummary, 
                                                                         Map<Id, Deployment_Process_Summary__c> mapOldDeploymentProcessSummaries) {
            
        String processName = 'backSync_TargetBackup';                                                                     
        for(Deployment_Process_Summary__c processSummary : newDeploymentProcessSummary ) {
            
            //Check if the processs summmary is Back sync and validation status is complete and pass, then run the automated target backup. 
            if(mapOldDeploymentProcessSummaries != null && processSummary.Is_Back_Sync__c
               && processSummary.Validation_Status__c == 'Pass' 
               && mapOldDeploymentProcessSummaries.get(processSummary.Id).Validation_Status__c != processSummary.Validation_Status__c ) {
                
               //Enqueue Job calling. 
               System.enqueueJob(new Enqueue_ProcessSummariesActions(processSummary.Deployment_Track__c, processName));
                   
            }
        }
    }
}