/** 
* Description   :   Controller to show .
*				:	Used in DeploymentWizard App - OneClick Deploy
*
* Created By    :   Ishan Arora
*
* Created Date  :   05/21/2018
*
* Version       :   V1.0 Created
*                   
**/
public class ManualStepController {
    
    //================= Validation Screen Properties ========================================
    //Holding the Reference of the Deployment Track Object
    public Deployment_Track__c deploymentTrackRef{get;set;}
    
    //Hold the Reference of App Properties
    public DeploymentWizardBean appPropertiesRef{get;set;}
    
    public Boolean checkManualStepsPerformed {
        get;
        set;
    }
    
    //Get Deployment Process Summary Instance
    public Deployment_Process_Summary__c processSummary{
        get{
            //If Instance is null then instantiate it.
            if(processSummary == null){
                
                //Check if Deployment Track Record Exist in the Database
                if(deploymentTrackRef != null && deploymentTrackRef.Id != null){
                    
                    //if Validation has run at least one time on the screen, then it must have Validation Summary Populated on it.
                    if(deploymentTrackRef.Recent_Validation__c != null){
                        processSummary = DeploymentWizardHelper.populateDeploymentProcessSummary(deploymentTrackRef.Recent_Validation__c);                        
                    }else
                        //If There is no attempt to run the Validation
                        processSummary = new Deployment_Process_Summary__c(); 
                    
                    //Populate Deployment Track Ref Record on the Process Summary Record
                    processSummary.Deployment_Track__c = deploymentTrackRef.Id;
                    
                    //Populate Validation Summary Record Type Id
                    processSummary.RecordTypeId = processRecordTypeId;
                }
            } 
            return processSummary;
        }                                            
        set;
    }
    
    //Get Process Record Type Id
    private Id processRecordTypeId{
        get{
            if(processRecordTypeId == null){
                return DeploymentWizardHelper.getRecordTypeId('Deployment_Process_Summary__c', DeploymentWizardConstants.DEPLOYMENT_PROCESS_VALIDATION_SUMMARY);    
            }
            return processRecordTypeId;
        }
        set;
    }
    //Report Link for Manual Step, Populate Dynamically
    public String reportURL{
        get{
            if(String.isBlank(reportURL)){
                reportURL = DeploymentWizardHelper.getManualStepReportLink(deploymentTrackRef, DeploymentWizardConstants.MANUAL_STEPS_ALL);
            }
            return reportURL;
        }
        set;
    }
    //Constructor
    public ManualStepController(){
        
        checkManualStepsPerformed = false;
    }
    
    
    public void manualStepCheckbox(){
        
        deploymentTrackRef.Performed_By__c = UserInfo.getUserId();
       // System.assert(false,  processSummary.Manual_Steps_Performed__c
        
        If( processSummary.Manual_Steps_Performed__c == true)
            checkManualStepsPerformed =  true;
        else
            checkManualStepsPerformed = false;
        
    }
    
    
    
}