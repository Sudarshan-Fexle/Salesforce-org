/**
 *  Purpose         :   This Class is used to handle all the manipulation of VF page - VF_UpdateContactInstitutionRole.
 *
 *  Create By       :   Dipesh Gupta
 *
 *  Created Date    :   03/28/2019
 *
 *  Revision Logs   :   V_1.0 - Created.
 * 						V_1.1 - Modified by Neha Sharma - 04/14/2022 - CR-20220301-15947 - Updated method fetchSSCGridDataInformation() & addNewLine()
 *                      
 **/
public class SSCProjectGridController {
    
    Public Static Boolean byPass_DeploymentTrigger = false;
	
    //Class Varible.
    //Variable that holds the Project Ids
    public String projectId {get; set;}
    
    //Boolean flags.
    public Boolean isSuccess {get; set;}
    public Boolean isError {get; set;}
    public String Message{get;set;}
    public Boolean isReadOnly{get;set;}
    public Boolean isDeleteSelected{get;set;}
      
    public List<SSCGridWrapper> sscGridWrapper {get; set;}
    
    //Constructor.
    public SSCProjectGridController(ApexPages.StandardController controller) {
        
        isSuccess = false;
        isError = false;
        Message = '';
        isReadOnly = true;
        isDeleteSelected = false;
        sscGridWrapper = new List<SSCGridWrapper>();
        projectId = ApexPages.CurrentPage().getparameters().get('id');
    }
    
    //Modified by Neha Sharma - 04/14/2022 - CR-20220301-15947 - added Services_Consultant__c field in query.
    //Method that retrives the SSC Project Grid data and Stores in the variable.
    public void fetchSSCGridDataInformation() {
    	
        //Wrapper to initialise again.
        sscGridWrapper = new List<SSCGridWrapper>();
        
        //Check for the Project Id
        if(String.isNotBlank(projectId)) {
        	
            //Modified by Neha Sharma - 04/14/2022 - CR-20220301-15947 - added Services_Consultant__c field in query.
            //Query on the deployent records and fetch the appropriate deployment fields.
            List<Deployment__c> deployments = [Select Id, Module__c, Start_Date__c, Go_Live__c, End_Date__c, 
                                            Phase__c, Health__c, Services_Consultant__c From Deployment__c Where Project__c =: projectId 
                                            AND RecordType.DeveloperName = 'SSC_Grid'];
                                                
            //Check id List size is greater than 0. 
            if(deployments.size() > 0) {
          		
                //Loop on the deployment list.
                for(Deployment__c dep : deployments) {
                    
                    //Filling the wrapper with the appropriate properties.
                	sscGridWrapper.add(new SSCGridWrapper(false, dep));    
                }
            }                              
        }
    }
    
    //This method is used to save the Project. 
    public void doSave() {
        
        Boolean isUserSelectedAnything = false;
        
        //List to hold the Deployment object Records. 
        List<Deployment__c> deploymentToBeSaved = new List<Deployment__c>();
            
        //Check for the wrapper values. 
        if(sscGridWrapper != null && sscGridWrapper.size() > 0) {
            
        	//Check to see which record is selected and need to save in the data base.
            for(SSCGridWrapper wrap : sscGridWrapper) {

                //Check for rhe isSelected.
                if(wrap.isSelected) {
                    
                    //Deployment record added to the grid.
                	deploymentToBeSaved.add(wrap.gridRecord);
                    wrap.isSelected = false;
                    isUserSelectedAnything = true;  
				}
            }
            
            if(!isUserSelectedAnything) {
                isError = true;
                Message = 'Please select at least one row before save.';
            }
                
            
            //Check for the list size.
            if(deploymentToBeSaved.size() > 0) {
                
                //Bypassing the trigger.
                Util.BypassAlltriggers = true;
                SSCProjectGridController.byPass_DeploymentTrigger = true;
                upsert deploymentToBeSaved;
				Util.BypassAlltriggers = false;
                
                isError = false;
                isSuccess = true;
                isReadOnly = true;
                Message = 'Records have been Saved successfully.';
            }
		}
    }
    
    //This method is used to save the Project. 
    public void doDelete() {
        
        //Boolean to hold the selected flag.
        Boolean isUserSelectedAnything = false;
        
        //List to hold the Deployment object Records that is going to be deleted. 
        List<Deployment__c> deploymentToBeDeleted = new List<Deployment__c>();
            
        //Check for the wrapper values. 
        if(sscGridWrapper != null && sscGridWrapper.size() > 0) {
            
        	//Check to see which record is selected and need to save in the data base.
            for(SSCGridWrapper wrap : sscGridWrapper) {

                //Check for rhe isSelected.
                if(wrap.isSelected) {
                    
                    //Deployment record added to the grid.
                	deploymentToBeDeleted.add(wrap.gridRecord);
                    wrap.isSelected = false;
                    isUserSelectedAnything = true;  
				}
            }
            
            if(!isUserSelectedAnything) {
                isError = true;
                Message = 'Please select at least one row to delete.';
            }
                
            
            //Check for the list size.
            if(deploymentToBeDeleted.size() > 0) {
                
                //Bypassing the trigger.
                Util.BypassAlltriggers = true;
                SSCProjectGridController.byPass_DeploymentTrigger = true;
                delete deploymentToBeDeleted;
				Util.BypassAlltriggers = false;
                isSuccess = true;
                isReadOnly = true;
                Message = 'Records have been deleted successfully.';
                
               	fetchSSCGridDataInformation();
            }
		}
    }
    
    //Method to show the Editable list
    public void changeReadToEditMode () {
        
        //Flag set as false.
        isReadOnly = false;
        isDeleteSelected = false;
        isError = false;
        isSuccess = false;
        Message = '';

    }
    
    public void changeReadToEditModeWithDeleted () {
        
        //Flag set as false.
        isReadOnly = false;
        isDeleteSelected = true;
        isError = false;
        isSuccess = false;
        Message = '';
    }
    
    //Modified by Neha Sharma - 04/14/2022 - CR-20220301-15947 - added Services_Consultant__c field.
    //Method to include the new instance to the Wrapper
    public void addNewLine() {
        
        Date d;
		
		Id sscGridRTypeId = Schema.SObjectType.Deployment__c.getRecordTypeInfosByName().get('SSC - Grid').getRecordTypeId();
        
        Deployment__c newDeployment = new Deployment__c(Project__c = projectId, RecordTypeId = sscGridRTypeId);
        
        //Modified by Neha Sharma - 04/14/2022 - CR-20220301-15947 - added Services_Consultant__c field.
        
        //Adding the new Blank Instance. (Setting the default values)
        newDeployment.Module__c = '';
        newDeployment.Start_Date__c = d;
        newDeployment.Go_Live__c = d;
        newDeployment.End_Date__c = d;
        newDeployment.Phase__c = '';
       	newDeployment.Health__c = '';
        newDeployment.Services_Consultant__c = null;
       
        //Adding that Instance to the Wrapper.(Default selected)
        sscGridWrapper.add(new SSCGridWrapper(true, newDeployment));
        isError = false;
    }
    
    //Wrapper class.
    public class SSCGridWrapper {
        
        //Class Variables.
        public Boolean isSelected {get; set;}
        public Deployment__c gridRecord {get; set;}
        
        public SSCGridWrapper(Boolean isSelected, Deployment__c gridRecord) {
        	
            this.isSelected = isSelected;
            this.gridRecord = gridRecord;
        }
    }
}