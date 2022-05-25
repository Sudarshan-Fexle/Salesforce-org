/**
 *  Description     :   This class is to Create a HTTP request
 *
 *  Created By      :  Ishan Arora
 *
 *  Created Date    :   01/04/2018
 * 
 * @revision Log	:	V_1.0 - 01/04/2018 - Created - Ishan Arora
 * 			:	V_1.1 - 24/07/2018 - Modified - Ishan Arora.
 *                      :       V_1.2 - 19/03/2018 - Modified - Dipesh Gupta - CR-20180717-12442
 *
**/
public with sharing class OneClick_HttpRequestBuilder {
    
    /**
	 *	@description	:	Method to create HttpRequest request To Heroku Server for OneClick Deploy Operations 
	 *						
	 *	@args		:	String, String, String, String, Integer
	 *
	 *	@return		:	HttpRequest
	 *
	 *	@revision Log	:	V_1.0 - 03/20/2018 - Created - Rajeev jain
	 *				V_1.1 - 24/07/2018 - Modified - Ishan Arora - CR-20180717-12442
	 *
	 **/
    public static HttpRequest CreateRequest(String requestType, Deployment_Track__c trackRef, Deployment_Process_Summary__c processRef) {
      
        //Http Request Object
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');   
        request.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());        
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID()); 
        
        //Getting Connection Details
        String sourceConnection = trackRef.Source_Org__c;
        String targetConnection = trackRef.Target_Org__c;
               
        //Boolean Variable to Decide the Flag that If Self Connection is Selected as Source Or Target Connection then mark these flags as True
        Map<String, Connection__c> mapConnections = new Map<String, Connection__c>();
        
        //Iterate on all connection 
        for(Connection__c con : Database.query(DeploymentWizardConstants.CONNECTION_SOQL)) {
            mapConnections.put(con.Name, con);
        }
        
        //This variable is used to hold the target connection org type is Sb or not
        Boolean targetOrgIsSB = mapConnections != null && mapConnections.size() > 0 && mapConnections.get(targetConnection) != null && mapConnections.get(targetConnection).Org_Type__c == 'Sandbox' ? true : false; 
        
        //Hold the Local/Self or Controlling Org Connection Details
        Connection__c localConnection = mapConnections.size() > 0 ? mapConnections.get(DeploymentWizardConstants.CONNECTION_NAME_LOCAL_ORG) : null;
        
         //Boolean flag to Identify that if Local Connections is selected as Source Or Target Connection By User.
         Boolean isSourceMatching = false;
        Boolean isTargetMatching = false;
        
         if(localConnection != null && sourceConnection == localConnection.Name)
          isSourceMatching = true;
        else if(localConnection != null && targetConnection == localConnection.Name)
            isTargetMatching = true;
        //String packageRetrievalEndPoint = 'https://validateanddeploypackage.herokuapp.com/retrievePackage?';
        String packageRetrievalEndPoint = DeploymentWizardHelper.oneClickSettings.get(DeploymentWizardConstants.PACKAGE_RETRIEVAL_ENDPOINT).value__c;
        //String validationEndPoint = 'https://validateanddeploypackage.herokuapp.com/validatePackage?';
        String validationEndPoint = DeploymentWizardHelper.oneClickSettings.get(DeploymentWizardConstants.PACKAGE_VALIDATION_ENDPOINT).value__c;
        String testRunEndPoint = DeploymentWizardHelper.oneClickSettings.get(DeploymentWizardConstants.RUN_TEST_ENDPOINT).value__c;
        //String retrievebackup = 'https://validateanddeploypackage.herokuapp.com/retrieveTargetBackup?';
        String retrievebackup = DeploymentWizardHelper.oneClickSettings.get(DeploymentWizardConstants.TARGET_ORG_BACKUP_ENDPOINT).value__c;
        //String deploymentEndPoint = 'https://validateanddeploypackage.herokuapp.com/deployPackage?';
        String deploymentEndPoint = DeploymentWizardHelper.oneClickSettings.get(DeploymentWizardConstants.PACKAGE_DEPLOYMENT_ENDPOINT).value__c;
        //Add Source and Target Connection
        String serviceEndPoint = 'sourceOrgName=' + EncodingUtil.urlEncode(sourceConnection, 'UTF-8') + '&targetOrgName=' + EncodingUtil.urlEncode(targetConnection,'UTF-8');
        
        //Add Logic If Source or Target is Matching with Local or Controlling Org
        serviceEndPoint = serviceEndPoint + '&isTargetMatching=' + isTargetMatching + '&isSourceMatching=' + isSourceMatching;
        
        //Provide Local Org Info
        if(localConnection != null)
          serviceEndPoint = serviceEndPoint + '&localRefreshToken=' + EncodingUtil.urlEncode(localConnection.Refresh_Token__c,'UTF-8') + '&localOrgType=' + EncodingUtil.urlEncode(localConnection.Org_type__c,'UTF-8');
        
        request.setTimeout(120000);
        
        //Handling Null Pointer Exception occruance before hitting to the WebService End Point
        String releaseId = trackRef.Deployment_Release_Project__c != null ? String.valueOf(trackRef.Deployment_Release_Project__c) : '';
    	String crId = trackRef.Deployment_Change_Request__c != null ? String.valueOf(trackRef.Deployment_Change_Request__c) : '';
        String validationId = String.isNotBlank(processRef.ValidationId__c) ? processRef.ValidationId__c : '';
        Boolean isAvailableForQuickDeploy = processRef.Available_for_Quick_Deploy__c != null ? processRef.Available_for_Quick_Deploy__c : false;
        String specificTestRun = processRef.Specific_Test_Run_Classes__c;
        Boolean defaultRun = processRef.Default_Run__c;
        specificTestRun = specificTestRun == null ? '' :  specificTestRun;
        defaultRun = defaultRun == null ? false : defaultRun;
        
        Boolean isTestNeeded = DeploymentWizardHelper.checkIfSingleApexAdded(crId, releaseId);
        Boolean isAllConfig = isTestNeeded ? false : true;
        
        String retrivalAPIVersion = Label.DEPLOYMENT_PACKAGE_FILE_VERSION;
        Boolean isBackSync = trackRef.Is_Back_Sync__c;
        Boolean packageManuallyUploaded = processRef.Is_Package_Manually_Uploaded__c;
       
        
        if(requestType == DeploymentWizardConstants.DEPLOYMENT_PROCESS_REQUEST_TYPE_PECKAGE_RETRIEVAL){
          
            serviceEndPoint = packageRetrievalEndPoint + serviceEndPoint + '&deploymentSummaryRecordId=' + processRef.Id; 
            serviceEndPoint = serviceEndPoint + '&retrivalAPIVersion='+retrivalAPIVersion;
            
        } else if(requestType == DeploymentWizardConstants.DEPLOYMENT_PROCESS_REQUEST_TYPE_VALIDATE_PARTIAL){
          
            serviceEndPoint = validationEndPoint + serviceEndPoint + '&deploymentSummaryRecordId=' + processRef.Id; 
            serviceEndPoint = serviceEndPoint + '&release_ID=' + releaseId;
            serviceEndPoint = serviceEndPoint + '&CR_ID=' + crId;
            serviceEndPoint = serviceEndPoint + '&manualTestClasses='+ specificTestRun;
            serviceEndPoint = serviceEndPoint + '&defaultRun=' + defaultRun+ '&isPartialValidation=true';
            serviceEndPoint = serviceEndPoint + '&isBackSync=' + isBackSync;
            
            
            
        } else if(requestType == DeploymentWizardConstants.DEPLOYMENT_PROCESS_REQUEST_TYPE_VALIDATE_FULL){
            
      		serviceEndPoint = validationEndPoint + serviceEndPoint + '&deploymentSummaryRecordId=' + processRef.Id + '&release_ID=&CR_ID=' + '&isPartialValidation=false';  
            serviceEndPoint = serviceEndPoint + '&manualTestClasses=&defaultRun=';
            serviceEndPoint = serviceEndPoint + '&isBackSync=' + isBackSync;
            serviceEndPoint = serviceEndPoint + '&targetOrgIsSB=' + targetOrgIsSB;
            serviceEndPoint = serviceEndPoint + '&isAllConfig=' + isAllConfig;
            
            
        } else if(requestType == DeploymentWizardConstants.DEPLOYMENT_PROCESS_REQUEST_TYPE_TEST_RUN){
            
            serviceEndPoint = testRunEndPoint + serviceEndPoint + '&changeRequest=' + crId;
            serviceEndPoint = serviceEndPoint + '&release=' + releaseId;
            serviceEndPoint = serviceEndPoint + '&testSummaryLookup=' + processRef.Id;
            serviceEndPoint = serviceEndPoint + '&asynchronous=false';
            serviceEndPoint = serviceEndPoint + '&getHierarchyData=false';
            
        }else if(requestType == DeploymentWizardConstants.DEPLOYMENT_PROCESS_REQUEST_TYPE_TARGET_BACKUP){
          serviceEndPoint = retrievebackup + serviceEndPoint + '&deploymentSummaryRecordId=' + processRef.Id; 
          serviceEndPoint = serviceEndPoint + '&packageManuallyUploaded=' + packageManuallyUploaded;
            
        }else if(requestType == DeploymentWizardConstants.DEPLOYMENT_PROCESS_REQUEST_TYPE_QUICK_DEPLOY){
            serviceEndPoint = deploymentEndPoint + serviceEndPoint + '&recentValidationId=' + validationId;
            serviceEndPoint = serviceEndPoint + '&deploymentSummaryRecordId=' + processRef.Id;
            serviceEndPoint = serviceEndPoint + '&availableForQuickDeploy=' + isAvailableForQuickDeploy;
            
        }else 
            //Modified - Ishan Arora 
            //Modified By Dipesh Gupta - CR-20180717-12442
            if(requestType == DeploymentWizardConstants.DEPLOYMENT_PROCESS_REQUEST_TYPE_DEPLOY){
            serviceEndPoint = deploymentEndPoint + serviceEndPoint + '&recentValidationId=' + validationId;
            serviceEndPoint = serviceEndPoint + '&deploymentSummaryRecordId=' + processRef.Id;
            serviceEndPoint = serviceEndPoint + '&availableForQuickDeploy=false';
            serviceEndPoint = serviceEndPoint + '&isAllConfig=' + isAllConfig;
        }
        System.debug('Check End Point for ' + requestType + ' :: ' + serviceEndPoint); 
        request.setEndpoint(serviceEndPoint);
        return request;
    }
}