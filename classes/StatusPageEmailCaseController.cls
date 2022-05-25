/**
*  Description     :   Class to create the Status page Email Cases. 
*
*  Created By      :   Abhinav Sharma    
* 
*  Created Date    :   01/16/2019
* 
*  Revision Logs   :   V_1.0 - Created - CR-20170526-10962
**/  
public without sharing class StatusPageEmailCaseController {
    
    //Class property
    public String caseSubject {get; set;}
    public String casePriority {get; set;}
    public String caseStatus {get; set;}
    public String caseStatusPageEmail {get; set;}
    public String ProjectName {get; set;}
    public String projectId {get;set;}
    
    
    //Boolean Variable
    public boolean isSuccess {get; set;}
    public boolean isError {get; set;}
    public String errorMessage {get; set;}
    List<Project__c> projects = new List<Project__c>();
    
	//Constructor
    public StatusPageEmailCaseController() {
    	
        //Initialising property
        caseSubject = 'Status Page Email Request';
        casePriority = '';
        caseStatus = '';
		caseStatusPageEmail = '';
		isSuccess = false; 
        isError = false;
        errorMessage = '';
        projectId = ApexPages.CurrentPage().getparameters().get('id');
        
        //Project query to get the project Name. 
        projects = [Select Id, Institution__c, Name From Project__c Where Id =: projectId];
        If(projects.Size() > 0)
        ProjectName = projects[0].Name;
        
    }
    
    /**
    *  Description     :   This method is used to insert the case for the given object.  
    *
    *  Created By      :   Abhinav Sharma    
    * 
    *  Created Date    :   01/16/2019
    * 
    *  Revision Logs   :   V_1.0 - Created - CR-20170526-10962
	**/  
    public void doSave() {
        
        //Try block
        try {
        	
			//if condition to check the parameters. 
            if(String.isNotBlank(caseSubject) && String.isNotBlank(casePriority) 
           		&& String.isNotBlank(caseStatus) && String.isNotBlank(caseStatusPageEmail)) {
        		
               List<Group> groups = [Select Id From Group where DeveloperName = 'EAB_Tech_Support'];
               //Creating a new case. 
               Case c = new Case();
               c.Subject = caseSubject;
               c.Status = caseStatus;
               c.Priority = casePriority;
               c.Internal_Notes__c = caseStatusPageEmail;
               c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Status Page Email Request').getRecordTypeId();
               c.OwnerId = groups[0].Id;
               c.Project_Source_MS__c = projectId;
               c.AccountId = projects[0].Institution__c;
               insert c;
              
              isSuccess = true;
              isError = false;
                }else {
                    
                    throw new customException('Required fields are missing.');
                }
        }catch(Exception e) {
        	
            isError =true;
            isSuccess = false;
			errorMessage = e.getmessage();            
         }
	}
}