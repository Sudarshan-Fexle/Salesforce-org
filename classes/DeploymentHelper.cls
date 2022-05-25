/** 
* Description   :   Helper class for the Find a deployment in FindAdeploymetController - Oneclick deployment
*
* Created By    :   Rajeev Jain(Simplyforce)
*
* Created Date  :   03/05/2018
*
* Version       :   V1.0 Created
*                   
**/  
public class DeploymentHelper {
    
    //Default Page Size while Page Load
    public final static Integer DEFAULT_PAGE_SIZE = 10;
    
    //Defaul SOSL (Later it can be mover in custom Label)
    public static final String defaultSOSLFields = 'id, Name, Deployment_Change_Request__c, Deployment_Change_Request__r.Name,'
	+ 'Deployment_Release_Project__c, Deployment_Release_Project__r.Name,Sandbox_Refresh_Date__c,' 
	+ 'Source_Org__c, Target_Org__c, Deployment_Process__c, Is_Env_Setup_Completed__c, Recent_Crosscheck__c,' 
    + 'Recent_Test_Run__c, Recent_Package_Retrieval__c, Recent_Validation__c, Recent_Deployment__c,' 
	+ 'Recent_Crosscheck__r.Status__c, Recent_Test_Run__r.Status__c, Recent_Package_Retrieval__r.Status__c, Recent_Validation__r.Status__c, Recent_Deployment__r.Status__c,'
    + 'Start_Date__c, End_Date__c, Deployed_By__c, Deployment_Progress__c, Is_Deployment_Completed__c, Deployment_Entity__c, Process_Progress_Status__c';
    
    //Error Message
    //Rajeev Jain - 04/29/2015 : updated text in constants
    public static final String START_DATE_MUST_BE_LESS_THEN_END_DATE = Label.END_DATE_ERROR_MESSAGE;
    public static final String START_DATE_MUST_BE_GREATER_THEN_TODAY = Label.START_DATE_ERROR_MESSAGE;
    
    //This method is to create a select option list for given Picklist Entries
    public static List<SelectOption> getSelectOptionListByField(String objectName, String fieldName) {
        
        //Describe field and create a list of select options  
        List<SelectOption> listOptions = new List<SelectOption>();
        
        //loop throough the picklist entries and populate select list
        for (Schema.PicklistEntry pE : Schema.getGlobalDescribe().get('Deployment_Track__c').getDescribe().fields.getMap().get(fieldName).getDescribe().getPickListValues()) {
         
            //Populate the select list with values
            listOptions.add(new SelectOption(pE.getValue() , pE.getLabel()));  
        }
        
        //Return list
        return listOptions;
    }
    
    /**
     *  @description    :   Method to return most recently deployment Records, no filter criteria is applied.
     *
     *  @args           :	Deployment Track Object ,deployment Category(My Deployment or All Deployment)
     *
     *  @return         :   Search Results List
     *
     **/
    public static List<Deployment_Track__c> searchDefaultDeployments(Integer searchLimit){
        
        //(04/29/2015 Rajeev Jain) Updated Search Criteria to include records where source = 'ShipIt'
        List<Deployment_Track__c> deployments = [select id, Name, Deployment_Change_Request__c, Deployment_Change_Request__r.Name, 
                                                 Deployment_Release_Project__c, Deployment_Release_Project__r.Name,Sandbox_Refresh_Date__c, 
                                                 Source_Org__c, Target_Org__c, Deployment_Process__c, Is_Env_Setup_Completed__c, Recent_Crosscheck__c, 
                                                 Recent_Test_Run__c, Recent_Package_Retrieval__c, Recent_Validation__c, Recent_Deployment__c, 
                                                 Start_Date__c, End_Date__c, Deployed_By__c, Deployment_Progress__c, Is_Deployment_Completed__c, 
                                                 Deployment_Entity__c, Process_Progress_Status__c, Available_for_Back_Sync__c, Is_Back_Sync__c from Deployment_Track__c 
                                                 where ownerId = :UserInfo.getUserId() AND Is_Back_Sync__c = false order by CreatedDate DESC];
        	
        return deployments;
    }
    
    /**
     *  @description    :   Method to Search Deployment record based on criteria passed to it using SOSl.
     *
     *  @args           :	Deployment Object instanct Deployment Category(My Deployment or All Deployment)
     *
     *  @return         :   Search Results List
     *
     **/ 
	public static List<Deployment_Track__c> searchFilteredDeployments(Deployment_Track__c deploymentTrackRef, String deploymentCategory){
        
        system.debug('deploymentTrackRef----'+deploymentTrackRef);
        String fullSOSL = DeploymentHelper.defaultSOSLFields;
          
        //Add Defualt Where clause
        fullSOSL += ' where Name != null ';
        
        String searchSOSL = '';  
        
        //Set the deployment process value because in dynamic query we can not use direct object value
        String deploymentProcess = deploymentTrackRef.Deployment_Process__c;
        ///Check if process Status is applied 
        if(deploymentProcess != null){
            fullSOSL =  fullSOSL + ' AND Deployment_Process__c = \'' + deploymentProcess + '\'';   
        }
        
        //Set the deployment process value because in dynamic query we can not use direct object value
        String deploymentProcessProgress = deploymentTrackRef.Process_Progress_Status__c;
        ///Check if process Status is applied 
        if(deploymentProcessProgress != null && deploymentProcessProgress != ''){
            fullSOSL =  fullSOSL + ' AND Process_Progress_Status__c = :deploymentProcessProgress';   
        }
        
        //Set the deployment process value because in dynamic query we can not use direct object value
        String deploymentProgress = deploymentTrackRef.Deployment_Progress__c;
        ///Check if process Status is applied 
        if(deploymentProgress != null && deploymentProgress != ''){
            fullSOSL =  fullSOSL + ' AND Deployment_Progress__c = :deploymentProgress';   
        }

		//Set the deployment process value because in dynamic query we can not use direct object value
        String deploymentChangeRequest = deploymentTrackRef.Deployment_Change_Request__c;
        ///Check if process Status is applied 
        if(deploymentChangeRequest != null && deploymentChangeRequest != ''){
            fullSOSL =  fullSOSL + ' AND Deployment_Change_Request__c = :deploymentChangeRequest';   
        }
        
        //Set the deployment process value because in dynamic query we can not use direct object value
        String deploymentRelease = deploymentTrackRef.Deployment_Release_Project__c;
        ///Check if process Status is applied 
        if(deploymentRelease != null && deploymentRelease != ''){
            fullSOSL =  fullSOSL + ' AND Deployment_Release_Project__c = :deploymentRelease';   
        }
       
        //Check for If Deployment Category is not null
        if(String.isNotBlank(deploymentCategory)){
            
            //Check if Shipment Category is personal or my shipment 
            if(deploymentCategory.equals('My Deployment')){
            	
                //This Filter Later will be implemented
                fullSOSL = fullSOSL + ' AND OwnerId = \'' + UserInfo.getUserId() + '\'';       
            }
        }

        //Set the deployment process value because in dynamic query we can not use direct object value
		String deployedBy = deploymentTrackRef.Deployed_By__c;
        system.debug('deployedBy--'+deployedBy);
        ///Check if process Status is applied 
        if(deployedBy != null){
            fullSOSL =  fullSOSL + ' AND Deployed_By__c = :deployedBy';   
        }
        
        //Set the deployment process value because in dynamic query we can not use direct object value
        String sourceOrg = deploymentTrackRef.Source_Org__c;
        ///Check if process Status is applied 
        if(!sourceOrg.contains('--')){
            fullSOSL =  fullSOSL + ' AND Source_Org__c = :sourceOrg';   
        }
        
        
        //Set the deployment process value because in dynamic query we can not use direct object value
        String targetOrg = deploymentTrackRef.Target_Org__c;
        ///Check if process Status is applied 
        if(!targetOrg.contains('--')){
            fullSOSL =  fullSOSL + ' AND Target_Org__c = :targetOrg';   
        }
        
        //Set the deployment process value because in dynamic query we can not use direct object value
        DateTime deploymentStartDate = deploymentTrackRef.Start_Date__c;
        system.debug('deploymentStartDate---'+deploymentTrackRef.Start_Date__c);
        ///Check if process Status is applied 
        if(deploymentStartDate != null){
            
            //Check that start date is greater than current time or not
            if(deploymentStartDate > System.Now()) {
                //Display Message in case of From date is greate then to Data or today
            	DeploymentHelper.displayErrorMessages(DeploymentHelper.START_DATE_MUST_BE_GREATER_THEN_TODAY);
                return null;
            }
            else
            	fullSOSL =  fullSOSL + ' AND Start_Date__c >= :deploymentStartDate';   
        }
        
        //Set the deployment process value because in dynamic query we can not use direct object value
        DateTime deploymentEndDate = deploymentTrackRef.End_Date__c;
        
        if(deploymentEndDate !=null && deploymentStartDate != null && deploymentEndDate < deploymentStartDate) {
            //Display Message in case of From date is greate then to Data or today
            DeploymentHelper.displayErrorMessages(DeploymentHelper.START_DATE_MUST_BE_LESS_THEN_END_DATE);
        }
        ///Check if process Status is applied 
        if(deploymentEndDate != null){
            fullSOSL =  fullSOSL + ' AND End_Date__c <= :deploymentEndDate';   
        }
        
        
        
        //Final SOSL with all filter criteria
		//Bhavi Sharma - 03/28/2015 - If searchText is blank, then execute the SOQL based on the parameters added above
		//Else execute SOSL
		system.debug('fullSOSL---'+fullSOSL);
		if(!String.IsBlank(fullSOSL)) {
	        
			//JRB String SOQL = 'Select ' + fullSOSL.replace('where', 'from Deployment_Track__c where') + ' order by Ship_Date__c DESC Limit :searchLimit';
			String SOQL = 'Select ' + fullSOSL.replace('where', 'from Deployment_Track__c where Is_Back_Sync__c = false AND ') + ' order by CreatedDate DESC';
			system.debug('SOQL---'+SOQL);
            return (List<Deployment_Track__c>) database.query(SOQL);
			//system.debug('database.query(SOQL)'+database.query(SOQL));
		} 
        return null;
    }
    
    /**
     *  @description    :   These method is used to display Error Messages on Page.
     *
     *  @args           :	Error Message as a String
     *
     *  @return         :   void
     *
     **/
     public static void displayErrorMessages(String msg){
        
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,msg);            
        ApexPages.addMessage(myMsg);        
     } 

}