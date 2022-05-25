/*
*	Description		:	This is constants class to hold constants properties which are going to use in auto deployment project.
*
*	Created by		:	Saurabh Kumar
*
*	Created Date	:	04/22/2017
*
*	Revision Log	:	V1.0 Created
*						V1.0 Modified By Saurabh Kumar 08/31/2017 - CR-20170821-11154
*						V1.1 Modified By Saurabh Kumar 09/16/2017 - More values are added in mapOfObjectTypes.
*/
public with sharing class DeploymentConstants {
    
    //Map to hold Mapping of Object Type–What Advisory system have object type on the Is System component is different and what ANT script is understand, is different.
    public static Map<String, String> mapOfObjectTypes = 
    													new Map<String,String>{'Action' => 'QuickAction',
		            									  'Apex Class' => 'ApexClass',
		            									  'Apex Sharing Reason' => 'ApexSharingReason',
		            									  'Apex Trigger' => 'ApexTrigger',
		            									  'App' => 'CustomApplication',
		            									  'Approval Process' => 'ApprovalProcess',
		         										  'Assignment Rule' => 'AssignmentRules',
		            									  'Auth Provider' => 'AuthProvider',
		            									  'Auto-Response Rule' => 'AutoResponseRule',
		            									  'Button/Link' => 'WebLink',
														  'Button or Link' => 'WebLink',
		            									  'Compact Layout' => 'CompactLayout',
		            									  'Custom Console Component' => 'CustomConsoleComponent',
		                                                  'Custom Field' => 'CustomField',
		            									  'Custom Label' => 'CustomLabel',
		            									  'Custom Metadata Type' => 'CustomMetadata',
		            									  'Custom Object' => 'CustomObject',
		            									  'Custom Permission' => 'CustomPermission',
		            									  'Custom Report Type' => 'ReportType',
		            									  'Custom Setting' => 'CustomSetting',
		            									  'Dashboard' => 'Dashboard',
		            									  'Document' => 'Document',
		            									  'Email Template' => 'EmailTemplate',
		            									  'External Data Source' => 'ExternalDataSource',
		            									  'Field Set' => 'FieldSet',
		            									  'Flow Definition' => 'Flow',
		            									  'Flow Trigger' => 'FlowTrigger',
		            									  'Folder' => 'Folder',
		            									  'Group' => 'Group',
		            									  'Home Page Action' => 'HomePageAction',
		            									  'Home Page Component' => 'HomePageComponent',
														  'Home Page Layout' => 'HomePageLayout',
		            									  'Knowledge Action' => 'KnowledgeAction',
		            									  'Letterhead' => 'Letterhead',
		            									  'Lightning Component Bundle' => 'LightningComponentBundle',
		            									  'Lightning Page' => 'FlexiPage',
		            									  'List View' => 'ListView',
		            									  'Live Agent Configuration' => 'LiveAgentConfiguration',
		            									  'Live Chat Blocking Rule' => 'LiveChatBlockingRule',
		            									  'Live Chat Deployment' => 'LiveChatDeployment',
		            									  'Matching Rule' => 'MatchingRule',
		            									  'Named Credential' => 'NamedCredential',
		            									  'Page Layout' => 'Layout',
		            									  'Layout' => 'Layout',
		            									  'Permission Set' => 'PermissionSet',
		            									  'Post Template' => 'PostTemplate',
		            									  'Process Builder Process' => 'Flow',
		            									  'Process Builder' => 'Flow',
		            									  'Profile' => 'Profile',
		            									  'Queue' => 'Queue',
		            									  'Record Type' => 'RecordType',
		            									  'Remote Site' => 'RemoteSiteSetting',
		            									  'Report' => 'Report',
		            									  'Reporting Snapshot' => 'ReportingSnapshot',
		            									  'Role' => 'Role',
		            									  'Send Action' => 'SendAction',
		            									  'Sharing Criteria Rule' => 'SharingCriteriaRule',
		            									  'Sharing Owner Rule' => 'SharingOwnerRule',
		            									  'Sharing Set' => 'SharingSetting',
		            									  'Site.com' => 'Site',
		            									  'Skill' => 'Skill',
		            									  'Static Resource' => 'StaticResource',
		            									  'Tab' => 'CustomTab',
		            									  'Validation Rule' => 'ValidationRule',
		            									  'Visualforce Component' => 'ApexComponent',
		            									  'Visualforce Page' => 'ApexPage',
		            									  'Workflow Email Alert' => 'WorkflowAlert',
		            									  'Workflow Field Update' => 'WorkflowFieldUpdate',
		            									  'Workflow Outbound Message' => 'WorkflowOutboundMessage',
		            									  'Workflow Rule' => 'WorkflowRule',
		            									  'Workflow Task' => 'WorkflowTask',
		            									  'Zone' => 'Zone',
		            									  'Other' => 'Other',
		            									  'Generic Object' => 'GenericObject',
		            									  'App Menu' => 'AppMenu',
		            									  'Community' => 'Community',
		            									  'Connected App' => 'ConnectedApp',
		            									  'Custom Site' => 'CustomSite',
		            									  'Chat Button' => 'WebLink',
		            									  'Portal' => 'Other',
		            									  'Page Layouts' => 'Layout',
		            									  'Flow' => 'Flow',
		            									  'Field' => 'CustomField',
		            									  'Custom Button' => 'WebLink',
		            									  'Button' => 'WebLink',
		            									  'Email Alert' => 'WorkflowAlert',
		            									  'Aura Definition Bundle' => 'AuraDefinitionBundle',
                                                          'PathAssistant' => 'PathAssistant', 
                                                           'Global Value Set' => 'GlobalValueSet', 
                                                            'Connected App' => 'ConnectedApp'
                                                            };
      
    
    //==========================Constants for both (Crosscheck & Package)==========================  
    //=========================Cross Check Selected category constants====================================
	public static final String ONE_CLICK_SELECTED_CATEGORY_INDIVIDUAL_CROSSCHECK = 'individualCrosscheck';
	public static final String ONE_CLICK_SELECTED_CATEGORY_GROUP_CROSSCHECK = 'groupCrosscheck';

    //=========================Cross Check constants====================================
	public static final String ONE_CLICK_ACTION_TYPE_CROSSCHECK_AND_ATTACH = 'CrosscheckAndAttach';
	public static final String ONE_CLICK_ACTION_TYPE_CROSSCHECK_AND_EMAIL = 'CrosscheckAndEmail';
	public static final String ONE_CLICK_ACTION_TYPE_CROSSCHECK_AND_DISPLAY = 'CrosscheckAndDisplay';
	
	//========================Package constants=============================
	
	public static final String ONE_CLICK_ACTION_TYPE_PACKAGE_AND_ATTACH = 'PackageAndAttach';
	public static final String ONE_CLICK_ACTION_TYPE_PACKAGE_AND_EMAIL = 'PackageAndEmail';
	public static final String ONE_CLICK_ACTION_TYPE_PACKAGE_AND_DISPLAY = 'PackageAndDisplay';
	
	//===========================Selected Category==============================
	public static final String ONE_CLICK_SELECTED_CATEGORY_INDIVIDUAL_PACKAGE = 'individualPackage';
	public static final String ONE_CLICK_SELECTED_CATEGORY_GROUP_PACKAGE = 'groupPackage';

	//===========================OBJECT NAME==============================
	public static final String ONE_CLICK_SFDC_RELEASE = 'SFDC_Release__c';
	public static final String ONE_CLICK_SFDC_CHANGE_REQUEST  = 'SFDC_Change_Request__c';
	public static final String ONE_CLICK_IS_SYSTEM_MODIFICATION = 'IS_System_Modification__c';
	public static final String ONE_CLICK_SELECTED_TAB_CROSSCHECKBLOCK = '#CrosscheckBlock';


	//===================================Generic Methods=======================================================
    /*
    *   Description     :   The method is used to validate email address
    *
    *   @args           :   String email address
    *
    *   @return         :   Boolean
    *
    *   Revision Log    :   V1.0 Created
    */
    public static  Boolean validateEmail (String emailAddress) {
    	
    	//Default set as true
    	Boolean returnValue = true;
    	
    	//Regex for email address
    	String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';//'([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
    	
    	//Make the pattern
    	Pattern emailPattern = Pattern.compile(emailRegex);
		
		//Match the string
    	Matcher matcher = emailPattern.matcher(emailAddress);

    	if (!matcher.matches()) {
        	returnValue = false;
        }
    	return returnValue;
	}
}