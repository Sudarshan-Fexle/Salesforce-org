/*
*   Description     :   Class to send callout for org comaprision
*
*   Created by      :   Rajeev Jain
*
*   Created Date    :   01/28/2020
*
*   Revision Log    :                   
*/
public class OrgComparisionUtility {
	
    //Map to Hold the object/Component Types like Apex Class, Apex Trigger etc.
    public static Map<String, String> mapAllComponentTypes { 
        set; 
        get{ 
            if(mapAllComponentTypes == null){
                mapAllComponentTypes = new Map <String, String> {
                                            'Action' => 'QuickAction', 'Apex Class' => 'ApexClass', 'Apex Sharing Reason' => 'ApexSharingReason', 
                                            'Apex Trigger' => 'ApexTrigger', 'App' => 'CustomApplication', 'Approval Process' => 'ApprovalProcess', 
                                            'Assignment Rule' => 'AssignmentRule', 'Auth Provider' => 'AuthProvider', 'Auto-Response Rule' => 'AutoResponseRule',
                                            'Button/Link' => 'WebLink', 'Compact Layout' => 'CompactLayout', 
                                            'Custom Console Component' => 'CustomConsoleComponent', 'Custom Field' => 'CustomField', 
                                            'Custom Label' => 'CustomLabel', 'Custom Metadata Type' => 'CustomMetadata', 'Custom Object' => 'CustomObject', 
                                            'Custom Permission' => 'CustomPermission', 'Custom Report Type' => 'ReportType', 'Custom Setting' => 'CustomSetting', 
                                            'Dashboard' => 'Dashboard', 'Document' => 'Document', 'Email Template' => 'EmailTemplate', 
                                            'External Data Source' => 'ExternalDataSource', 'Field Set' => 'FieldSet', 'Flow' => 'Flow', 'Flow Definition' => 'FlowDefinition', 
                                            'Flow Trigger' => 'FlowTrigger', 'Folder' => 'Folder', 'Group' => 'Group', 'Home Page Action' => 'HomePageAction', 
                                            'Home Page Component' => 'HomePageComponent', 'Home Page Layout' => 'HomePageLayout', 'Knowledge Action' => 'KnowledgeAction', 
                                            'Letterhead' => 'Letterhead', 'Lightning Component Bundle' => 'LightningComponentBundle', 'Lightning Page' => 'FlexiPage', 
                                            'List View' => 'ListView', 'Live Agent Configuration' => 'LiveAgentConfiguration', 
                                            'Live Chat Blocking Rule' => 'LiveChatBlockingRule', 'Live Chat Deployment' => 'LiveChatDeployment', 
                                            'Matching Rule' => 'MatchingRule', 'Named Credential' => 'NamedCredential', 'Page Layout' => 'Layout', 
                                            'Permission Set' => 'PermissionSet', 'Post Template' => 'PostTemplate', 'Profile' => 'Profile', 'Queue' => 'Queue', 
                                            'Record Type' => 'RecordType', 'Remote Site' => 'RemoteSiteSetting', 'Report' => 'Report', 
                                            'Reporting Snapshot' => 'ReportingSnapshot', 'Role' => 'Role', 'Send Action' => 'SendAction', 
                                            'Sharing Criteria Rule' => 'SharingCriteriaRule', 'Sharing Owner Rule' => 'SharingOwnerRule', 'Sharing Set' => 'SharingSetting', 
                                            'Site.com' => 'Site', 'Skill' => 'Skill', 'Static Resource' => 'StaticResource', 'Tab' => 'CustomTab', 
                                            'Validation Rule' => 'ValidationRule', 'Visualforce Component' => 'ApexComponent', 'Visualforce Page' => 'ApexPage', 
                                            'Workflow Email Alert' => 'WorkflowAlert', 'Workflow Field Update' => 'WorkflowFieldUpdate', 
                                            'Workflow Outbound Message' => 'WorkflowOutboundMessage', 'Workflow Rule' => 'WorkflowRule', 'Workflow Task' => 'WorkflowTask', 
                                            'Zone' => 'Zone', 'App Menu' => 'AppMenu', 'Community' => 'Community', 
                                            'Connected App' => 'ConnectedApp', 'Custom Site' => 'CustomSite', 'Portal' => 'Portal',   
                                            'Aura Definition Bundle' => 'AuraDefinitionBundle',
                                            'Action Link Template' => 'ActionLinkGroupTemplate', 'Reporting Snapshot' => 'AnalyticSnapshot',
                                            'Business Process' => 'BusinessProcess', 'Call Center' => 'CallCenter', 'Canvas Metadata' => 'CanvasMetadata',
											'Communication Channel Layout' => 'ChannelLayout', 'CORS whitelist Origin' => 'CorsWhitelistOrigin',
                                            'Custom Console Component' => 'CustomApplicationComponent', 'CustomObjectTranslation' => 'CustomObjectTranslation',
                                            'Home Page Component Link' => 'CustomPageWebLink', 'Data Category Group' => 'DataCategoryGroup',
                                            'Escalation Rule' => 'EscalationRule', 'Installed Package' => 'InstalledPackage',
                                            'Live Chat Agent Config' => 'LiveChatAgentConfig', 'Live Chat Button' => 'LiveChatButton', 
                                            'Mobile Application Detail' => 'MobileApplicationDetail', 'Path Assistant' => 'PathAssistant', 
                                            'SAML Single Sign-On configuration' => 'SamlSsoConfig', 'Settings' => 'Settings', 'Apex sharing Reason' => 'SharingReason', 
                                            'Sharing Set' => 'SharingSet', 'SiteDotCom' => 'SiteDotCom', 'Synonym Dictionary' => 'SynonymDictionary', 
                                            'Translations' => 'Translations', 'Workflow Flow Action' => 'WorkflowFlowAction'};
                
            }
            return mapAllComponentTypes;
        } 
    }
    
     //Get All the defaults from the "Org Comparison Configuration Manager" custom Metadata Type.
    public static List<Org_Comparison_Configuration_Manager__mdt> orgComparisionDefaults { 
        set; 
        get{ 
            if(orgComparisionDefaults == null){
                orgComparisionDefaults = new List<Org_Comparison_Configuration_Manager__mdt>();
                //List<OrgComparisonDefault> listOrgComparisionDefaults = new List<OrgComparisonDefault>();
                for(Org_Comparison_Configuration_Manager__mdt orgdefault : [Select Id, DeveloperName, Component_Type__c, Team_Members__c, 
                                                                            Type_Operation__c,Email_Receivers__c, Base_URL__c 
                                                                            From Org_Comparison_Configuration_Manager__mdt 
                                                                            Where DeveloperName = 'Org_Comparison_Defaults'] ){
                    orgComparisionDefaults.add(orgdefault);
                }
            }
            return orgComparisionDefaults;
        } 
    }
    
    //Return the Semi colon seperated String of user's Ids
    public Static String getUserString(String stringOfName){
        
        //String to hold the coma seperated User's ids
        String returnString = '';
        
        Set<String> setTeamMemberNames = new Set<String>();
        
        if(String.isNotBlank(stringOfName)){
            for(String tMemberName : stringOfName.split(';')){
                if(String.isNotBlank(tMemberName))
                    setTeamMemberNames.add(tMemberName);
            }
        }
        
        //get values from defaults
        if(orgComparisionDefaults.size() > 0){
            
            for(Org_Comparison_Configuration_Manager__mdt orgdef : orgComparisionDefaults){
                
                if(String.isNotBlank(orgdef.Team_Members__c)){
                    
                    for(String teamMemberName : (orgdef.Team_Members__c).split(';')){
                        if(String.isNotBlank(teamMemberName))
                            setTeamMemberNames.add(teamMemberName);
                    }
                }
            }
        }
        
        //Check for size
        if(setTeamMemberNames.size() > 0){
            
            //Query over the User records
            for(User userRecord : [Select Id, IsActive From User where Name IN : setTeamMemberNames AND IsActive=true])
                returnString += userRecord.Id+';';  
            
            //Remove the semi colon in the last
            returnString = returnString.removeEndIgnoreCase(';');
        }
        
        //Return Statememt
        return returnString;
        
    }
    
    //Build the URL to hit the heroku  
    public static OrgComparisionWrapper createOrgComparisionWrapperInstance (Org_Comparision__c orgComp, Integer recordNumber) {
    	
        OrgComparisionWrapper orgCompWrapper;
        
        if(orgComp != null){
            
            Integer index = recordNumber != null ? recordNumber : 1;
            
            //Base URL(Sandbox End Point)
            String requestSite = 'https://testorgcomparision.herokuapp.com/compareOrgs?';
            
            //Base URL(Production End Point, Just for Information)
            //public String requestSite = 'https://create-components-changes-logs.herokuapp.com/compareOrgs?';
         
            //Check if Custom Metadata populated with base URL
            if(orgComparisionDefaults.size() > 0 && String.isNotBlank(orgComparisionDefaults[0].Base_URL__c))
                requestSite = orgComparisionDefaults[0].Base_URL__c;
            //String requestSite = 'https://create-components-changes-logs.herokuapp.com/compareOrgs?';
            
            String OrgComparisionId = orgComp.Id;
            String OrgComparisionStatus = 'Will Start';
            String OrgComparisionReleaseId = orgComp.Release__c != null ? orgComp.Release__c : '';
            
            String productionRefreshToken =  orgComp.Source_of_Truth__c != null && orgComp.Source_of_Truth__r.Refresh_Token__c != null ? orgComp.Source_of_Truth__r.Refresh_Token__c : '';
            String productionOrgType = orgComp.Source_of_Truth__c != null &&  orgComp.Source_of_Truth__r.Org_type__c != null ? orgComp.Source_of_Truth__r.Org_type__c : '';
            
            String sandboxRefreshToken = orgComp.Comparison_Org__c != null && orgComp.Comparison_Org__r.Refresh_Token__c != null ? orgComp.Comparison_Org__r.Refresh_Token__c : '';
            String sandboxOrgType = orgComp.Comparison_Org__c != null && orgComp.Comparison_Org__r.Org_type__c != null ? orgComp.Comparison_Org__r.Org_type__c : '';
            
            String createdDateBarier = orgComp.Created_Date_Bar__c != null ? orgComp.Created_Date_Bar__c.format() : '';
            String lastModifiedBarier = orgComp.Last_Modified_Date_Bar__c != null ? orgComp.Last_Modified_Date_Bar__c.format() : '';
            String lastModifiedEndBar = orgComp.Compare_between_last_modified_dates__c && orgComp.Last_Modified_Date_End_Bar__c != null ? (orgComp.Last_Modified_Date_End_Bar__c.addDays(1)).format() : '';
            
            String saveToThirdOrg = orgComp.Save_Mods_To_Different_Org__c ? 'true' : 'false';
            String createAdditiveMods = orgComp.Create_Additive_Mods__c ? 'true' : 'false';
            String rangeComparision = orgComp.Compare_between_last_modified_dates__c ? 'true' : 'false';
            String createDestructiveMods = orgComp.Create_destructive_mods__c ? 'true' : 'false';
            
            String modSaveOrg = orgComp.Save_Mods_To_Different_Org__c && orgComp.Save_Mods_To__c != null && orgComp.Save_Mods_To__r.Refresh_Token__c != null ? orgComp.Save_Mods_To__r.Refresh_Token__c : '';
            String modSaveOrgType = orgComp.Save_Mods_To_Different_Org__c && orgComp.Save_Mods_To__c != null && orgComp.Save_Mods_To__r.Org_type__c != null ? orgComp.Save_Mods_To__r.Org_type__c : '';
            
            String includeMetadata = String.IsNotBlank(orgComp.Component_Types__c) ? orgComp.Component_Types__c : '';
            String userFilterSet = String.IsNotBlank(orgComp.User_Filter__c) ? orgComp.User_Filter__c : '';
            
            
            orgCompWrapper = new OrgComparisionWrapper(index, requestSite , productionRefreshToken, productionOrgType, 
                                                           sandboxRefreshToken, sandboxOrgType, createdDateBarier, lastModifiedBarier, 
                                                           OrgComparisionId, saveToThirdOrg, createAdditiveMods, rangeComparision, 
                                                           createDestructiveMods, modSaveOrg, modSaveOrgType, lastModifiedEndBar,
                                                           includeMetadata, userFilterSet, OrgComparisionStatus, OrgComparisionReleaseId);
            orgCompWrapper.auditStartDateTime = orgComp.Last_Modified_Date_Bar__c != null ? String.valueOf(orgComp.Last_Modified_Date_Bar__c) : '';
            orgCompWrapper.auditEndDateTime = orgComp.Compare_between_last_modified_dates__c && orgComp.Last_Modified_Date_End_Bar__c != null ? String.valueOf((orgComp.Last_Modified_Date_End_Bar__c.addDays(1))) : '';
            orgCompWrapper.refreshDateOfConnectionSB = String.valueOf(orgComp.Comparison_Org__r.Sandbox_Refresh_Date__c.format());
        }
        
        return orgCompWrapper;
        
    }
}