/**
*    Purpose         :   Controller class for "Manage Cases" VF page, to close the selected Cases  
*                
*    Create By       :   Mahendra Swarnkar
*    
*    Created Date    :   09/05/2016
*    
*    Revision Log    :   V1.0 - Created By - Mahendra Swarnkar - CR-9802 - 
*                        V1.1 - Modified By - Ayush Gupta - CR-20210826-15383
**/
public with sharing class ManageCasesController {
    
    public static final String NONE = '--None--';
     
    //Standard controller variable
    private ApexPages.StandardSetController standardController;
    
    //Holds the Comments Added by the User
    Public String caseInternalComments {get;set;}
    
    //Holds the status of case selecled by the User
    Public String selectedStatus {get;set;}
    
    //Holds the selecled Reason due to which case has been closed
    Public String selectedReason {get;set;}
    
    //List to hold the selected Case records for closing 
    Public List<Case> selectedCases {get;set;}
    
    //variable for rendering the page 
    Public Boolean isEligible {get{
        if(isEligible == null)
            isEligible = true;
        return isEligible;
    }set;}
    
    //Selection options for the Case status 
    public List<SelectOption> CaseStatusOptions{
        get{
            //Check for Close case options if list is empty then Query the Case Close status
            if(CaseStatusOptions == null) {
                
                //Instantiate the close options list 
                CaseStatusOptions = new List<SelectOption>();
                
                //The default value for the list
                CaseStatusOptions.add(new SelectOption(NONE, NONE));
                //CaseStatusOptions.add(new SelectOption(System.Label.CASE_STATUS_90_Closed, System.Label.CASE_STATUS_90_Closed));
                
                //Fetch all the close case options from the status field 
                //Populate the close options list
                for(CaseStatus closeOptions : [Select Id, MasterLabel From CaseStatus Where IsClosed = true])
                	CaseStatusOptions.add(new SelectOption(closeOptions.MasterLabel , closeOptions.MasterLabel ));
            }
            return CaseStatusOptions;
        } set;}
    
    // Modified By - Ayush Gupta - CR-20210826-15383
    //Selection Options for the case reasons
    public List<SelectOption> CaseReasonOptions{
        get{
            if(CaseReasonOptions == null) {
                CaseReasonOptions = new List<SelectOption>();
                CaseReasonOptions.add(new SelectOption(NONE, NONE));
                CaseReasonOptions.add(new SelectOption(System.Label.CASE_Reason_USER_DIDNT_ATTEND_TRAINING, System.Label.CASE_Reason_USER_DIDNT_ATTEND_TRAINING));
                CaseReasonOptions.add(new SelectOption(System.Label.CASE_Reason_COMPLEX_FUNCTIONALITY, System.Label.CASE_Reason_COMPLEX_FUNCTIONALITY));
                CaseReasonOptions.add(new SelectOption(System.Label.CASE_Reason_EXISTING_PROBLEM, System.Label.CASE_Reason_EXISTING_PROBLEM));
                CaseReasonOptions.add(new SelectOption(System.Label.CASE_Reason_INSTRUCTIONS_NOT_CLEAR, System.Label.CASE_Reason_INSTRUCTIONS_NOT_CLEAR));
                CaseReasonOptions.add(new SelectOption(System.Label.CASE_Reason_NEW_PROBLEM, System.Label.CASE_Reason_NEW_PROBLEM));
                CaseReasonOptions.add(new SelectOption(System.Label.CASE_Reason_EXPERT_CENTER, System.Label.CASE_Reason_EXPERT_CENTER));
                CaseReasonOptions.add(new SelectOption(System.Label.CASE_Reason_SPAM, System.Label.CASE_Reason_SPAM));
            }
            return CaseReasonOptions;
        } set;}
    
    //Standard Controller Constructor
    public ManageCasesController(ApexPages.StandardSetController standardController)
    {	
        this.standardController = standardController;
        selectedStatus = '';
        selectedReason = '';
        caseInternalComments = '';
        
    }
    
    //Method to populate the Selected Case list
    public PageReference selectedCasesOnFromListView()
    {   
        
        //Getting Instance from the Custom setting to get the User level access to close a case
        Mass_Close_Case__c closeCaseEligibilityList = Mass_Close_Case__c.getInstance();
        
        //Profile based access
        Mass_Close_Case__c closeCaseEligibilityListProfile = Mass_Close_Case__c.getInstance(UserInfo.getProfileId());
        
        //User based access
        Mass_Close_Case__c closeCaseEligibilityListUser = Mass_Close_Case__c.getInstance(UserInfo.getUserId());
        
        
        //Check for Accessbility of the User to close a case.
        if(
            (
                closeCaseEligibilityList.Id != null 
                && closeCaseEligibilityList.Close_Cases_Permitted__c == true
            )
            ||
            (
                closeCaseEligibilityListProfile.Id != null 
                && closeCaseEligibilityListProfile.Close_Cases_Permitted__c == true
            )
            ||
             (
                closeCaseEligibilityListUser.Id != null 
                && closeCaseEligibilityListUser.Close_Cases_Permitted__c == true
            )
          ) {
            
            // Get the selected records
            // Check for the size
            if( !(standardController.getSelected().size() > 0)){
                
                //Show the Error Message to selecte at least a case record for closing te case
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , System.Label.CASE_CLOSE_ERROR_MESSAGE_NO_SELECTED_CASES));
                
                //Set the flag
                isEligible = false;
            }
            //Else Populate the selected List of cases
            else{
                selectedCases = (List<Case>) standardController.getSelected();   
            }
        }
        else {
            
            //Show the Error Message to Users for Insufficient priviledge to close a case
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , System.Label.CASE_CLOSE_ERROR_MESSAGE_NO_PRIVILEGE_PERMISSION ));
            
            //Set the flag
            isEligible = false;
        }
        return null;        
    }

    //Method to updated the those Case records which will be closed By the User 
    public PageReference updateCases() {   
            
        //Check for the required conditions
        if(String.isNotBlank(selectedStatus) 
           && String.isNotBlank(selectedReason) 
           && !(selectedStatus.endsWithIgnoreCase(NONE))
           && !(selectedReason.endsWithIgnoreCase(NONE))){
			
			//Loop over selected close cases in order to set the Status, Case Reason and Case Comment field on the case
            for(Case selectedCase : selectedCases) {
                   
                   //Populating fields on the cases
                   CaseComment cComment = new CaseComment(CommentBody = caseInternalComments, ParentId = selectedCase.Id ); 
                   selectedCase.status = selectedStatus;
                   selectedCase.Reason = selectedReason;
            }
		}
        else{
            //Show the Error Message to Users for Insufficient priviledge to close a case
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , System.Label.CASE_CLOSE_ERROR_MESSAGE_REQUIRED_FIELDS_STATUS_REASON ));
            return null;
        } 
        
        //Save and returned to the List view of cases
        return standardController.save();   
    }
    
    //Cancel button to redirect the User to Case list view
    public PageReference cancel()
    {       
        return standardController.cancel();   
    }
}