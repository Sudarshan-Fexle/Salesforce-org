/** 
* Description   :   Controller for handling the Deployment Application Navigation and Maintaining Application State.
*
* Created By    :   Rajeev Jain(Simplyforce)
*
* Created Date  :   02/14/2018
*
* Version       :   V1.0 Created
*                   
**/   
public class DeploymentWizardController {
    
    //=============== Controller Properties ============================================================
    public DeploymentWizardBean appProperties {get;set;}
    
    public String conName{get;set;}
    
    //Hold the Deployment Track Object Instance
    public Deployment_Track__c deploymentTrack{get;set;}
    
    public List<Deployment_Track__c> existingSimilarDTs {get; set;}
    public Boolean isExistingNotFound{get; set;}
    public String selectedDeploymentTrackId{get;set;}
    public DateTime refereshDate{get;set;}
    
    public String ConnectionError{get;set;}
   
    //Constructor
    public DeploymentWizardController(){
        
        //Get Deployment Id
        String deploymentId = ApexPages.currentPage().getParameters().get('deploymentId');
        
        //Getting the parameter, in case there it was clicked from the back sync records and type of full and partial was sent. 
        String deploymentType = ApexPages.currentPage().getParameters().get('type');
        
        //Initialize all App level properties in onece through Bean Class
        appProperties = new DeploymentWizardBean();
                
        if(String.isNotBlank(deploymentId)){
            //To DO - Query and Populate DeploymentTrack instance overhere
            deploymentTrack = DeploymentWizardHelper.populateDeploymentTrack(deploymentId);
            
            //To do - Later handle if Deployment Instance is not found based on passed Id

            //Decide Application state and Populate App Data
            DeploymentWizardHelper.populateApplicationProperties(deploymentTrack, appProperties);
            
        }else{
            deploymentTrack = new Deployment_Track__c();    
        }
        
        existingSimilarDTs = new List<Deployment_Track__c>();
        isExistingNotFound = false;
        selectedDeploymentTrackId = '';
    }
    
    public void checkExistingRecordWithSameConfiguration(){
        
        //Initialize
     	existingSimilarDTs =  new List<Deployment_Track__c>();
        isExistingNotFound = false;
                
        List<Deployment_Track__c> deploymentTrack_Existing = [Select Id, Name, Source_Org__c, Target_Org__c, Deployment_Change_Request__c, Available_for_Back_Sync__c,
                                                              Deployment_Process__c, Is_Back_Sync__c From Deployment_Track__c
                                                              Where Source_Org__c =: appProperties.selectedSourceCon 
                                                              AND Target_Org__c =: appProperties.selectedTargetCon
                                                              AND Available_For_Back_Sync__c =: deploymentTrack.Available_For_Back_Sync__c
                                                              AND ((Deployment_Change_Request__c != null 
                                                                   AND Deployment_Change_Request__c =: deploymentTrack.Deployment_Change_Request__c)
                                                              OR (Deployment_Release_Project__c != null  
                                                                   AND Deployment_Release_Project__c =: deploymentTrack.Deployment_Release_Project__c) )
                                                             ];
        
        //Check if there is any records created for this. 
        if(deploymentTrack_Existing.size() > 0 ) {
            existingSimilarDTs =  deploymentTrack_Existing;
        }else
            isExistingNotFound = true;
    }
    
    //============== Controller Methods ===============================================================
    /**
    * @Description	:	Continue Method for Application Navigation and changing the application state.
    * 
    * @arg			:	
    * 
    * @Return		:	Void
    * 
    **/
    public void moveNext(){
        
        try{
            
            System.debug('enter the states');
            //Check Application State, based on it take next action
            if(appProperties.appState == DeploymentWizardConstants.APP_STATE_NEW){
                
                System.debug('enter the state');
                //Validate Source and Target Org Connection
                ValidateConnection validateCon = new ValidateConnection();
                appProperties.connectionErrors = validateCon.getAndParse(appProperties);
                
                //Check if Cr/Release has any mods 
                List<IS_System_Modification__c> mods = Database.query(DeploymentWizardHelper.getBaseQueryForIsSystemMod(deploymentTrack));
                System.debug(mods);
                if( mods == null || mods.size() == 0 ){
                    //Check if it's CR
					if(deploymentTrack.Deployment_Change_Request__c != null || deploymentTrack.Deployment_Change_Request__c != '' )                    
                    appProperties.connectionErrors =  Label.CR_WITHOUT_MODS ;
                    //Check if it's Release
                   if(deploymentTrack.Deployment_Release_Project__c != null || deploymentTrack.Deployment_Release_Project__c != '' )                    
                    appProperties.connectionErrors = Label.RELEASE_WITHOUT_MODS ;
                    
                    return; 
                }
                
                system.debug('appProperties.connectionErrors'+appProperties.connectionErrors);
                //Check for sanfbox refresh date if in future
                if(deploymentTrack.Sandbox_Refresh_Date__c > Date.today()){
                    //Error
                    appProperties.connectionErrors = Label.ERROR_FUTURE_SANDBOX_REFRESH_DATE;
                    return; 
                }
                else if(appProperties.connectionErrors != null && appProperties.connectionErrors != '') {
                    return;
                }
                else{
                    //Update Env Setup Details
                    DeploymentWizardHelper.updatedEnvDetails(deploymentTrack, appProperties);
                }
            }else if(appProperties.appState == DeploymentWizardConstants.APP_STATE_TEST_RUN){
                DeploymentWizardHelper.updatedTestRunDetails(deploymentTrack, appProperties);   
            }else if(appProperties.appState == DeploymentWizardConstants.APP_STATE_PACKAGE_RETRIEVAL){
                DeploymentWizardHelper.updatedPackageRetrievalDetails(deploymentTrack, appProperties);   		    
            }else if(appProperties.appState == DeploymentWizardConstants.APP_STATE_CROSSCHECK){
                DeploymentWizardHelper.updatedCrosscheckDetails(deploymentTrack, appProperties);   		    
            }else if(appProperties.appState == DeploymentWizardConstants.APP_STATE_VALIDATION){
                DeploymentWizardHelper.updatedValidationDetails(deploymentTrack, appProperties);   		    
            }else if(appProperties.appState == DeploymentWizardConstants.APP_STATE_DEPLOYMENT){
                DeploymentWizardHelper.updatedDeploymentDetails(deploymentTrack, appProperties);	    
            }else if(appProperties.appState == DeploymentWizardConstants.APP_STATE_MANUAL_MODS){
                DeploymentWizardHelper.updatedDeploymentDetails(deploymentTrack, appProperties);	    
            }
        }catch(Exception e){
            
        }        
    }
    
    /**
    * @Description	:	Populate Sandbox Refresh date on Selection of Source Sandbox
    * 
    * @arg			:	
    * 
    * @Return		:	Void
    * 
    **/
    public void populateSandboxRefreshDate(){
        
        //Check for source connection is null
        if(appProperties.selectedSourceCon != null && appProperties.selectedSourceCon != '' && appProperties.selectedSourceCon != '--' ){
            
            //Get connextion data
            Connection__c con = [Select Name, Sandbox_Refresh_Date__c From Connection__c where Name=:appProperties.selectedSourceCon Limit 1];
            
            //Populate sandbox refresh date
            deploymentTrack.Sandbox_Refresh_Date__c = con.Sandbox_Refresh_Date__c;  
        }
        else{
            //if source connection is null
            deploymentTrack.Sandbox_Refresh_Date__c = null;
        }
     }
    
    Public void cleanUp_DT() {
      
        //Check if the deployment tracks id is present. 
        if(String.isNotBlank(selectedDeploymentTrackId)) {
            
            //Get all child process summaeries and Back sync deployment records. 
            List<Deployment_Process_Summary__c> deploymentSummeries = [Select Id
                                                                       From Deployment_Process_Summary__c 
                                                                       where Deployment_Track__c =: selectedDeploymentTrackId 
                                                                       OR Deployment_Track__r.Parent_Deployment_Track__c =: selectedDeploymentTrackId];
        	
            List<Deployment_Track__c> backSync_deploymentTracks = [Select Id From Deployment_Track__c 
                                                                    Where Parent_Deployment_Track__c =: selectedDeploymentTrackId];
            
            
            Util.BypassAllTriggers = true; 
            
            //Check if the we have recordsa in above list then delete them. 
            if(deploymentSummeries != null && deploymentSummeries.size() > 0) {
                delete deploymentSummeries;
            }
            
            if(backSync_deploymentTracks != null && backSync_deploymentTracks.size() > 0) {
                delete backSync_deploymentTracks;
            }
             
            Util.BypassAllTriggers = false;     
            
            
            //Now update the screen of Deployment track with Environment setup. 
            Deployment_Track__c dT = new Deployment_Track__c (Id = selectedDeploymentTrackId, 
                                                              Deployment_Process__c = DeploymentWizardConstants.PROCESS_TEST_RUN,
                                                             Back_Sync_Records_Created__c = false);
            update dT;
           }
    }
    
    
}