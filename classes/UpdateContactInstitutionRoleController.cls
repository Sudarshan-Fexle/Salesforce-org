/**
*  Purpose         :   This Class is used to handle all the manipulation of VF page - VF_UpdateContactInstitutionRole.
*
*  Create By       :   Dipesh Gupta
*
*  Created Date    :   03/28/2019
*
*  Revision Logs   :   V_1.0 - Created.
*                      
**/
public class UpdateContactInstitutionRoleController {
    
    //Class Variable to interact with VF Pages.
    public List<InstitionRoleWrapper> institutionRoleWrapper {get; set;}
    
    //Variable that holds the Contact Ids
    public String contactId {get; set;}
    
    //Boolean flags.
    public Boolean isSuccess {get; set;}
    public Boolean isError {get; set;}
    public String errorMessage{get;set;}
    public Boolean isTableVisible{get;set;}
    public string uITheme {get; set;}
    
    
    //Constructor. 
    public UpdateContactInstitutionRoleController(ApexPages.StandardController controller) {
        
        //Initializing the properties.
        institutionRoleWrapper = new List<InstitionRoleWrapper>();     
        contactId = '';
        isSuccess = false;
        isError = false;
        errorMessage = '';
        isTableVisible = true;
        uITheme = '';
        
        //Getting the Contact id. 
        contactId = ApexPages.CurrentPage().getparameters().get('id');
        
        uITheme = UserInfo.getUiThemeDisplayed(); 
        
        //Check for the contact Id String. 
        if(String.isNotBlank(contactId))
            detailedInstutionRoleInformation();
        
        
    }
    
    //Method that pulls all the institution roles that associated with Contact Institution Role. 
    public void detailedInstutionRoleInformation() {
        
        //Query on the contact object to know that is the contact is active.
        List<Contact> listOfContacts = [Select Id, Contact_Status__c, AccountId From Contact Where Id =: contactId];
        
        //Checking for the Active Contact. 
        if(listOfContacts != null && listOfContacts[0].Contact_Status__c == 'Active' && listOfContacts[0].AccountId != null) {
            
            //Getting the Account Id. 
            for(Institution_Roles__c iRole : [Select Id, Name, Assignment_Role__c,Institution__c, Contact__c 
                                              From Institution_Roles__c 
                                              Where Institution__c =: listOfContacts[0].AccountId]) {
                                                  
                                                  //Adding the Institution Role in the list of Wrapper.
                                                  institutionRoleWrapper.add(new InstitionRoleWrapper(iRole, false));
                                              }
            
            //Check for the Wrapper size. 
            if(institutionRoleWrapper.size() == 0) {
                isError = true;
                errorMessage = 'Institution has no Institution Roles to display';                
            }
        }else{
            isError = true;
            if(listOfContacts[0].Contact_Status__c == 'Active')
                errorMessage = 'Contact is inactive.';    
            else 
                errorMessage = 'Contact has no Institution.';
        }
    }
    
    //Method that calls when save botton is hit. 
    public void doSave() {
        
        isSuccess = false;
        isError = false;
        errorMessage = '';
        
        //List to hold the Institution Roles
        List<Institution_Roles__c> institutionRolesToBeUpdated = new List<Institution_Roles__c>();
        
        //Check for the list size. 
        if(institutionRoleWrapper != null && institutionRoleWrapper.size() > 0) {
            
            //Loop on the Institution Roles. 
            for(InstitionRoleWrapper iRoleWrapoer :  institutionRoleWrapper) {
                
                //Check if the Wrapper instance is checked. 
                if(iRoleWrapoer.isChecked) {
                    
                    if(String.isNotBlank(iRoleWrapoer.institutionRole.Assignment_Role__c))
                        //Adding the Instance to the List. 
                        institutionRolesToBeUpdated.add(new Institution_Roles__c(Id = iRoleWrapoer.institutionRole.Id, 
                                                                                 Assignment_Role__c = iRoleWrapoer.institutionRole.Assignment_Role__c, 
                                                                                 Contact__c = contactId));
                    else {
                        isError = true;
                        errorMessage = 'Assignment Role is required to update selected Instituion Roles.';
                        return;
                    }
                }
            }
            
            //Check for the List Size. 
            if(institutionRolesToBeUpdated.size() > 0) {
                
                try {
                    //Bypassing All Triggers
                    Util.ByPassAllTriggers = true;
                    update institutionRolesToBeUpdated;
                    Util.ByPassAllTriggers = false;
                    isSuccess = true;
                    isTableVisible = false;
                    institutionRolesToBeUpdated = new List<Institution_Roles__c>();
                    
                }catch(Exception e) {
                    //Error to show on page.
                    isError = true;
                    errorMessage = e.getMessage();
                }
            }else{
                isSuccess = false;
                isError = true;
                errorMessage = 'Please select at least one institution role.';
            }
        }
    }
    
    //Wrapper class. 
    public Class InstitionRoleWrapper {
        
        public Institution_Roles__c institutionRole{get; set;}
        public Boolean isChecked {get; set;}
        
        //Constructor
        public InstitionRoleWrapper(Institution_Roles__c institutionRole, Boolean isChecked) {
            this.institutionRole = institutionRole;
            this.isChecked = isChecked;
        }
    }
}