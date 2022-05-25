/**
 *  Purpose         :   Wrapper class to hold the Application Level Properties and all Main Controller Properties. 
 * 
 *  Created By      :   Rajeev Jain
 * 
 *  Created Date    :   02/12/2018
 * 
 * Revision Logs    :   V_1.0 - Created
 *  
 **/ 
public class DeploymentWizardBean {
     
    //Properties
    public String selectedSourceCon{get;set;}
    public String selectedTargetCon{get;set;}
    
    //It will hold the Connection error messages
    public String connectionErrors{get;set;}
    
    //Hold Application State, decide which screen will render.(EnvSetup, Test Run, Package Retrieval, Crosscheck, Validation, Deployment, Deployment Summary etc.)
    public String appState{get;set;}
    public Boolean isEnvSetupCompleted{get;set;}
    
    //Prop to hold the Screen Title Based on Application State, Title on the screen will change as Application State get changed
    public String appScreenTitle{get;set;}
    
    //Properties to hold the Release and Change Request name if populated
    public String releaseName{get;set;}
    public String crName{get;set;}  
    public String deploymentGroupId{get; set;}
    
    //Properties to Hold the CR and Release Status Repectively
    public String releaseStatus{get;set;}
    public String crStatus{get;set;}
    
    //Hold the Force Move Reason which will be used to save the Force Move Results
    public String forceMove{get;set;}
    
    
    
    //It holds the end point of heroku app which handle organisation login when clicking on Source or Target Org Connection
    public String orgLoginEndPoint{
        get{
            if(orgLoginEndPoint == null){
                if(DeploymentWizardHelper.oneClickSettings.containsKey('RedirectToOrg'))
                	orgLoginEndPoint = DeploymentWizardHelper.oneClickSettings.get('RedirectToOrg').Value__c;
            }
            return orgLoginEndPoint;
        }
        set;
    }
    
    public Connection__c sourceConnectionData{
        get{
            if(sourceConnectionData == null && String.isNotBlank(selectedSourceCon)){
				System.debug('Check Source Connection Data ::: ' + selectedSourceCon);
            	return DeploymentWizardHelper.getConnectionData(selectedSourceCon);		    
            }
            return sourceConnectionData;
        }
        set;
    }
    public Connection__c targetConnectionData{
        get{
            if(targetConnectionData == null && String.isNotBlank(selectedTargetCon)){
            	return DeploymentWizardHelper.getConnectionData(selectedTargetCon);		    
            }
            return targetConnectionData;
        }
        set;
    }
    
    //Connection List - Which created through connection Module
    public List<SelectOption> connections{
        get{
            if(connections == null){
                
                connections = new List<SelectOption>();
                
                //Query all on Org Connection Data and Populate it here.
                List<Connection__c> orgConnections = [select Id, Name, Access_Token__c, Instance_URL__c, Organization_Id__c, Org_type__c, Refresh_Token__c 
                                                      from Connection__c where Active__c = false];
                
                //Loop over connections data and populate it.
                connections.add(new SelectOption('--', '--'));
                
                for(Connection__c con : orgConnections){
                    connections.add(new SelectOption(con.Name, con.Name));      
                }
            }
            return connections;
        }
        set;
    }
    //Provide the Progress Options in Select List on - Find A Deployment Screen.
    public List<SelectOption> deploymentProgressOptions{
        get{
            if(deploymentProgressOptions == null){
            	deploymentProgressOptions = new List<SelectOption>();
                deploymentProgressOptions.add(new SelectOption('', '--None--'));
                deploymentProgressOptions.add(new SelectOption('Started', 'Started'));
                deploymentProgressOptions.add(new SelectOption('Not Started', 'Not Started'));
                deploymentProgressOptions.add(new SelectOption('In Progress', 'In Progress'));
                deploymentProgressOptions.add(new SelectOption('Completed', 'Completed'));   
            }
            return deploymentProgressOptions;
        }
        set;
    }
    
    //Constructor to Set Default Values for Properties
    public DeploymentWizardBean(){
        
        //By Default application will alwasy be in new state;
        appState = DeploymentWizardConstants.APP_STATE_NEW;
        appScreenTitle = DeploymentWizardConstants.APP_SCREEN_TITLE_ENV_SETUP;
        releaseName = '';
        crName = '';
    }
}