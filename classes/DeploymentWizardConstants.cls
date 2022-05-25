/**
 *	Purpose			:	Constant Class to Hold the All Application Constants. Mainly user on "DeploymentWizardController" class.
 * 
 * 	Created By		:	Rajeev Jain
 * 
 * 	Created Date	:	02/12/2018
 * 
 * Revision Logs	:	V_1.0 - Created
 *
 **/ 
public class DeploymentWizardConstants {
	 
    //Contants for Connection Validate
    public static String CONNECTION_SOQL = 'Select Id , Name , Access_Token__c , Refresh_Token__c , Org_type__c FROM Connection__c ';
    public static String CONNECTION_FILTER = 'WHERE Name = \'Self Connection\'';
    
    //OneClick Settings - Key Constants 
    public static final String APPLICATION_PAGE_NAME = 'ApplicationPageName';
    public static final String CLIENT_ID = 'ClientId';
    public static final String CLIENT_SECRET = 'ClientSecret';
    public static final String LOCAL_CONNECTION_NAME = 'LocalConnectionName';
    public static final String LOCAL_ORG_TYPE = 'LocalOrgType';
    public static final String LOCAL_REFRESH_TOKEN = 'LocalRefreshToken';
    public static final String PACKAGE_FILE_NAME = 'PackageFileName';
    public static final String PACKAGE_RETRIEVAL_ENDPOINT = 'PackageRetrievalEndPoint';
    public static final String PACKAGE_VALIDATION_ENDPOINT = 'PackageValidationEndPoint';
    public static final String PACKAGE_DEPLOYMENT_ENDPOINT = 'PackageDeploymentEndPoint';
    public static final String RUN_TEST_ENDPOINT = 'RunTestEndPoint';
    public static final String REDIRECT_URL = 'RedirectUrl';
    public static final String RETRIEVED_PACKAGE_NAME = 'RetrievedPackageName';
    public static final String TARGET_ORG_BACKUP_ENDPOINT = 'TargetOrgBackupEndPoint';
    public static final String TARGET_ORG_RETRIEVAL_PACKAGE_NAME = 'TargetOrgRetrivalPackageName';
    
    //Hold the Quick Deployment Deadline, At present it is 10days after Successfull Validation
    public final static Decimal QUICK_DEPLOYMENT_OPTION_DAYS_LIMIT = 10.0;
    
    //Constant to Hold the Local or Self Connection Unique Name, This will be only for Application wide and would be the name of the connection,
    //which will tread as Controlling org, where Application will run, Mods and CRs would be tracked and application wide summary data would be stored
    public final static String CONNECTION_NAME_LOCAL_ORG = DeploymentWizardHelper.oneClickSettings.get(DeploymentWizardConstants.LOCAL_CONNECTION_NAME).value__c;
    
    //Constants For Application State
    public final static String APP_STATE_NEW = 'Env Setup';
    public final static String APP_STATE_TEST_RUN = 'Test Run';
    public final static String APP_STATE_CROSSCHECK = 'Crosscheck';
    public final static String APP_STATE_PACKAGE_RETRIEVAL = 'Package Retrieval';
    public final static String APP_STATE_VALIDATION = 'Validation';
    public final static String APP_STATE_DEPLOYMENT = 'Deployment';
    public final static String APP_STATE_DEPLOYMENT_SUMMARY = 'Deployment Summary';
     public final static String APP_STATE_MANUAL_MODS = 'Manual Mods';
    
    //Constants for Deployment Process
    public final static String PROCESS_ENV_SETUP = 'Env Setup';
    public final static String PROCESS_TEST_RUN = 'Test Run';
    public final static String PROCESS_PACKAGE_RETRIEVAL = 'Package Retrieval';
    public final static String PROCESS_CROSSCHECK = 'Crosscheck';
    public final static String PROCESS_VALIDATION = 'Validation';
    public final static String PROCESS_DEPLOYMENT = 'Deployment';
    public final static String PROCESS_DEPLOYMENT_SUMMARY = 'Deployment Summary';
    
    //Constants for App Screen Titles
   	public final static String APP_SCREEN_TITLE_ENV_SETUP = 'Environment Setup';
    public final static String APP_SCREEN_TITLE_TEST_RUN = 'Test Run';
    public final static String APP_SCREEN_TITLE_PACKAGE_RETRIEVAL = 'Package Retrieval';
    public final static String APP_SCREEN_TITLE_CROSSCHECK = 'Crosscheck';
    public final static String APP_SCREEN_TITLE_VALIDATION = 'Validation';
    public final static String APP_SCREEN_TITLE_DEPLOYMENT = 'Deployment';
    public final static String APP_SCREEN_TITLE_DEPLOYMENT_SUMMARY = 'Deployment Summary';
     public final static String APP_SCREEN_TITLE_MANUAL_MODS = 'Manual Mods';
    
    //Set to hold the Set of the Exclude components which should not be part of the Crosscheck Reporting or Results
    public static Set<String> excludeIsSystemComponentSet = new Set<String>{'Generic_Salesforce_Config_Object',
        																	'Generic_Salesforce_Data_Update',
        																	'Generic_Object',
        																	'Generic_Validation_Rule',
        																	'Generic_Salesforce_Code_Object',
        																	'Generic_Page Layout'};
   
	//Deployment Process Summary Record Type Constants
	public final static String DEPLOYMENT_PROCESS_CROSSCHECK_SUMMARY = 'Crosscheck_Summary';
    public final static String DEPLOYMENT_PROCESS_DEPLOYMENT_SUMMARY = 'Deployment_Summary';
    public final static String DEPLOYMENT_PROCESS_PACKAGE_RETRIEVAL_SUMMARY = 'Package_Retrieval_Summary';
    public final static String DEPLOYMENT_PROCESS_TEST_RUN_SUMMARY = 'Test_Run_Summary';
    public final static String DEPLOYMENT_PROCESS_VALIDATION_SUMMARY = 'Validation_Summary';
 	
    //Constants for Deployment Process Status
    public final static String DEPLOYMENT_PROCESS_STATUS_STARTED = 'Started';
    public final static String DEPLOYMENT_PROCESS_STATUS_NOT_STARTED = 'Not Started';
    public final static String DEPLOYMENT_PROCESS_STATUS_IN_PROGRESS = 'In Progress';
    public final static String DEPLOYMENT_PROCESS_STATUS_COMPLETED = 'Completed';
    
    public final static String DEPLOYMENT_PROCESS_REQUEST_TYPE_VALIDATE_PARTIAL = 'Partial';
    public final static String DEPLOYMENT_PROCESS_REQUEST_TYPE_VALIDATE_FULL = 'Full';
    public final static String DEPLOYMENT_PROCESS_REQUEST_TYPE_PECKAGE_RETRIEVAL = 'Package Retrieval';
    public final static String DEPLOYMENT_PROCESS_REQUEST_TYPE_DEPLOY = 'Deploy';
    public final static String DEPLOYMENT_PROCESS_REQUEST_TYPE_QUICK_DEPLOY = 'Quick Deploy';
    public final static String DEPLOYMENT_PROCESS_REQUEST_TYPE_TARGET_BACKUP = 'Target Backup';
    public final static String DEPLOYMENT_PROCESS_REQUEST_TYPE_TEST_RUN = 'Run Test';
    
    //Hold the Id of Manual Steps Report - To Do - Move it to the Custom Label in later phase
    public final static String MANUAL_STEPS_BLUE_PRINT_REPORT_BASE_URL = '/lightning/r/Report/00OC0000006psBC/view';
    
    //Manual Steps timing steps - Pre Validation, Pre Deployment and Post Deployment steps
    public final static String MANUAL_STEP_TIMING_PRE_VALIDATION = 'Pre-Validation';
    public final static String MANUAL_STEP_TIMING_PRE_DEPLOYMENT = 'Pre-Deployment';
    public final static String MANUAL_STEP_TIMING_POST_DEPLOYMENT = 'Post-Deployment';
    public final static String MANUAL_STEP_TIMING_OTHER = 'OTHER';
    public final static String MANUAL_STEPS_ALL = MANUAL_STEP_TIMING_PRE_VALIDATION +', '+ MANUAL_STEP_TIMING_PRE_DEPLOYMENT +', '+ MANUAL_STEP_TIMING_POST_DEPLOYMENT +', '+ MANUAL_STEP_TIMING_OTHER;
    
    public final static String DEPLOYMENT_PACKAFE_ATTACHMENT_NAME = DeploymentWizardHelper.oneClickSettings.get(DeploymentWizardConstants.RETRIEVED_PACKAGE_NAME).value__c;
    public final static String DEPLOYMENT_PACKAFE_TARGET_BACKUP_NAME = DeploymentWizardHelper.oneClickSettings.get(DeploymentWizardConstants.TARGET_ORG_RETRIEVAL_PACKAGE_NAME).value__c;
    public final static String DEPLOYMENT_PACKAGE_XML = DeploymentWizardHelper.oneClickSettings.get(DeploymentWizardConstants.PACKAGE_FILE_NAME).value__c;
    
    //Other constants used in one click classess and pages
    public final static String DEPLOYMENT_PROCESS_STATUS_FAIL = 'Fail';
    
	//Heroku End Points
	//To do - Move these end points later on to Custom Setting or Custom label
	
    //Method to hold the Set of Apex Based Components
    public final static Set<String> apexBasedComponents = new Set<String>{'Apex Class', 'Apex Trigger'};
}