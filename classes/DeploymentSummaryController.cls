/** 
* Description   :   Contorller for deployment wizard summary component.
*
* Created By    :   Ishan Arora(Simplyforce)
*
* Created Date  :   02/14/2018
*
* Version       :   V1.0 Created
*                   
**/ 
public class DeploymentSummaryController {
	
    //Holding the Reference of the Deployment Track Object
    public Deployment_Track__c deploymentTrackRef{get;set;}
    //Hold the Reference of App Properties
    public DeploymentWizardBean appPropertiesRef{get;set;}
    Public List<Deployment_Process_Summary__c> processSummary{get;set;}
    public Boolean IsBackSyncPageRef {get; set;}
    //Hold to reference for Back Sync
    public Boolean isBackSyncVisible{get;set;}
    public List<BackSyncWrapper> backSyncProcessdetais{get; set;}
    public ChangeRequestDetailWrapper changeRequestWrap {get; set;}
    public String deploymentTrackId{get;set;}   
    Public Boolean isOverlapped {get;set;}
    
    public String FullButtonClicked_DT{get;set;}
    
    //Prop to Hold the Test Run Summary Data
    public Deployment_Process_Summary__c testRunSummary{
        get{
            if(testRunSummary == null && deploymentTrackRef != null && deploymentTrackRef.Recent_Test_Run__c != null)
                return DeploymentWizardHelper.populateDeploymentProcessSummary(deploymentTrackRef.Recent_Test_Run__c);
            else 
                return new Deployment_Process_Summary__c();
        }
        set;
    }
    
    //Prop to Hold the Package Retrieval Summary Data
    public Deployment_Process_Summary__c packageRetrievalSummary{
        get{
            if(packageRetrievalSummary == null && deploymentTrackRef != null && deploymentTrackRef.Recent_Package_Retrieval__c != null)
                return DeploymentWizardHelper.populateDeploymentProcessSummary(deploymentTrackRef.Recent_Package_Retrieval__c);
            else 
                return new Deployment_Process_Summary__c();
        }
        set;
    }
    
    //Prop to hold the crosscheck summary details
    public Deployment_Process_Summary__c crosscheckSummary{
        get{
            if(crosscheckSummary == null && deploymentTrackRef != null && deploymentTrackRef.Recent_Crosscheck__c != null)
                return DeploymentWizardHelper.populateDeploymentProcessSummary(deploymentTrackRef.Recent_Crosscheck__c);
            else 
                return new Deployment_Process_Summary__c();
        }
        set;
    }
    //Prop to hold validation summary data
    public Deployment_Process_Summary__c validationSummary{
        get{
            if(validationSummary == null && deploymentTrackRef != null && deploymentTrackRef.Recent_Validation__c != null)
                return DeploymentWizardHelper.populateDeploymentProcessSummary(deploymentTrackRef.Recent_Validation__c);
            else 
                return new Deployment_Process_Summary__c();
        }
        set;
    }
    
    //Prop to hold deployment summary data
    public Deployment_Process_Summary__c deploymentSummary{
        get{
            if(deploymentSummary == null && deploymentTrackRef != null && deploymentTrackRef.Recent_Deployment__c != null)
                return DeploymentWizardHelper.populateDeploymentProcessSummary(deploymentTrackRef.Recent_Deployment__c);
            else 
                return new Deployment_Process_Summary__c();
        }
        set;
    }
    
    // Property to hold details about manual steps in a CR/Release
    public Deployment_Track__c manualSteps{
        get{
            if( deploymentTrackRef != null)
                return DeploymentWizardHelper.getManualStepsData(deploymentTrackRef);
            else 
                return new Deployment_Track__c();
        }
        set;
    }
    
    public void backSyncListner() {	
       	backSyncProcessdetais = new List<BackSyncWrapper>();
        
       	for(Deployment_Track__c deploymentTrack : [ Select Id, Name, Deployment_Change_Request__c, Deployment_Release_Project__c, 
                                                   Started_By__c, Sandbox_Refresh_Date__c, Source_Org__c, Target_Org__c, Deployment_Process__c, 
                                                   Is_Env_Setup_Completed__c, Recent_Crosscheck__c, Recent_Test_Run__c, Total_CR__c, Total_Non_Overlapping_CR__c, 
                                                   Total_Overlapping_CR__c, 
                                                   Deployment_Type__c, Total_Component__c, Total_Retrieval_Failed_Component__c,
                                                   Recent_Package_Retrieval__c, Recent_Validation__c, Recent_Deployment__c,
                                                   Start_Date__c, End_Date__c, Deployed_By__c, Deployment_Progress__c, 
                                                   Is_Deployment_Completed__c, Deployment_Entity__c, Process_Progress_Status__c,
                                                   Is_Test_Run_Required__c, Deployment_Change_Request__r.Status__c, 
                                                   Deployment_Release_Project__r.Status__c 	
                                                   FROM Deployment_Track__c
                                   
                                   	WHERE Parent_Deployment_Track__c != null AND Parent_Deployment_Track__c =: deploymentTrackRef.Id 
                                    AND Parent_Deployment_Track__r.Available_for_Back_Sync__c = true]) {

            DeploymentWizardBean bean  = new DeploymentWizardBean();
            bean.selectedSourceCon = deploymentTrack.Source_Org__c;
            bean.selectedTargetCon = deploymentTrack.Target_Org__c;
            bean.appState = deploymentTrack.Deployment_Process__c;            
            BackSyncWrapper wrap = new BackSyncWrapper(deploymentTrack, bean);
            backSyncProcessdetais.add(wrap);                                          
        } 
        
        isBackSyncVisible = true;
    }
    
    //This method is used to get the Change request which is associtated to deployment group to get the overlapping and non overlapping details. 
    public void getOverlappedAndNonOverlappedCR()
    {	
        
        if(String.isBlank(deploymentTrackId)){
            return;
        }
        //Map to hold the CRs
        Map<String, SFDC_Change_Request__c> mapOfChangeRequests = new Map<String, SFDC_Change_Request__c>();
        
        changeRequestWrap = new ChangeRequestDetailWrapper();
        changeRequestWrap.sfdcChangeReqests_NonOverlapped = new List<SFDC_Change_Request__c>();
        changeRequestWrap.sfdcChangeReqests_Overlapped = new List<SFDC_Change_Request__c>();
        
        //Get the Deployment group. 
        List<Deployment_Track__c> deploymentTracks = [SELECT Id, Deployment_Release_Project__c, Deployment_Change_Request__c,
                                                      Name, Deployment_Group__c 
                                                      FROM  Deployment_Track__c 
                                                      Where Id =: deploymentTrackId  AND Deployment_Group__c != null];
        
        if(deploymentTracks.size() > 0 ){
        	
            if(String.isNotBlank(deploymentTracks[0].Deployment_Release_Project__c)){
                
                for(SFDC_Change_Request__c cr : [Select Id, Name, Title__c
                                                From SFDC_Change_Request__c 
                                                Where Release__c =: deploymentTracks[0].Deployment_Release_Project__c]){
                	
                	mapOfChangeRequests.put(cr.Name, cr);
                }
            }
            
            if(String.isNotBlank(deploymentTracks[0].Deployment_Change_Request__c)){
            	
				for(SFDC_Change_Request__c cr : [Select Id, Name, Title__c
                                                From SFDC_Change_Request__c 
                                                Where Id =: deploymentTracks[0].Deployment_Change_Request__c]){
                	
                	mapOfChangeRequests.put(cr.Name, cr);
                }           
            }
            
            //Check for the size of map. 
            if(mapOfChangeRequests.size() > 0) {
            	
                Set<String> SetOfDeploymentGroupCRs = DeploymentWizardHelper.fetchCRNumbersOfAGroup(deploymentTracks[0].Deployment_Group__c);
            	
                for(String crNumber : mapOfChangeRequests.keyset()){
                       
                    if(SetOfDeploymentGroupCRs.contains(crNumber)){
                    	changeRequestWrap.sfdcChangeReqests_NonOverlapped.add(mapOfChangeRequests.get(crNumber));
                    }else{
                        changeRequestWrap.sfdcChangeReqests_Overlapped.add(mapOfChangeRequests.get(crNumber));
  					}
                }
            }
        }
                        
       	isOverlapped = true;                                       
    }
    
    public Double offset{ 
        get{
            
            TimeZone tz = UserInfo.getTimeZone();
            //Milliseconds to Day
            return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    	}
    }
    
    
    public DeploymentSummaryController() {
        
        appPropertiesRef = new DeploymentWizardBean();
        appPropertiesRef.selectedSourceCon = '';
        appPropertiesRef.selectedTargetCon = '';
        isBackSyncVisible = false;
        isOverlapped = false;
        deploymentTrackId = '';
        FullButtonClicked_DT = '';  
        backSyncProcessdetais = new List<BackSyncWrapper>();
    }
    
    public void cancelListner() {
        isBackSyncVisible = false;
    }
    
    //Class to back sync.
    public Class BackSyncWrapper{    
        
        public Deployment_Track__c deploymentTrack {get; set;}  
       	public DeploymentWizardBean appProperty {get; set;}
        
        public BackSyncWrapper(Deployment_Track__c deploymentTrack, DeploymentWizardBean appProperty) {
            this.deploymentTrack = deploymentTrack;
            this.appProperty = appProperty;
        }
    } 
    
    Public Class ChangeRequestDetailWrapper{
        
        public List<SFDC_Change_Request__c> sfdcChangeReqests_Overlapped{get; set;}
        public List<SFDC_Change_Request__c> sfdcChangeReqests_NonOverlapped{get; set;}
        
        public ChangeRequestDetailWrapper() {
            sfdcChangeReqests_Overlapped = new List<SFDC_Change_Request__c>();
            sfdcChangeReqests_NonOverlapped = new List<SFDC_Change_Request__c>();
        }
    }
    
    /**
     * @Description :   Method used null out all the related process summaries and set the status to pacakge retrieval as well as null the group from the deployment track. 
     * 
     * @Modifcation :   Added By - Rajeev jain
     * 
     * @args        :   Deployment Track Id. 
     *    
     * @Return      :  
     * */
    public void resetDeploymentTrack_FullButtonBackSync(){
        
        if(String.isNotBlank(FullButtonClicked_DT)) {   
        	
            //Delete Deployment Process Summeries. 
			Deployment_Track__c dt = new Deployment_Track__c(Id = FullButtonClicked_DT);
            
            //Set null to following fields.
            dt.Recent_Crosscheck__c = null;
            dt.Recent_Deployment__c = null;
            dt.Recent_Package_Retrieval__c = null;
            dt.Recent_Test_Run__c = null;
            dt.Recent_Validation__c = null;
            dt.Deployment_Group__c = null;
            dt.Deployment_Process__c = DeploymentWizardConstants.PROCESS_PACKAGE_RETRIEVAL;
            
            update dt;
        }
    }
    
    public void partialButtonHandler() {
        
    }
}