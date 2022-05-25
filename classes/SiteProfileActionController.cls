/**
    Desription      :   Site Profile Quick Action Controller
    
    Created By      :   Victor Hanson
    
    Created Date    :   10/24/2014
    
    Revision Logs   :   v1 - Created
**/ 
public without sharing class SiteProfileActionController {
	
    //variables
    public string siteProfileId { get; set; }
    private Site_Profile__c sProfile { get; set; }
    private string action { get; set; }
    @TestVisible private string body { get; set; }
    public static final string QUICK_ACTION_ACTIVATE = 'Activate';
    public static final string QUICK_ACTION_DEACTIVATE = 'Deactivate';
    public static final string QUICK_ACTION_PASSWORD_RESET = 'Password_Reset';
    String currentTheme;
    
    public SiteProfileActionController() {
        siteProfileId = ApexPages.currentPage().getParameters().get('Id');
        action = ApexPages.currentPage().getParameters().get('action');
        currentTheme = UserInfo.getUiThemeDisplayed();
    }
    
    /**
     * @description: execute is called when the page loads, performing the requested action
     * 
     **/
    public Pagereference execute() {
        try {
            //get the site profile
            sProfile = [SELECT Id, Contact__c, Username__c, User_Id_Override__c, Contact__r.Contact_Status__c, Contact__r.Account.Advisory_com_Organization_Status__c, Contact__r.Account.EAB_com_Organization_Status__c, 
                        User_Id__c, Type__c, Verify__c, Bypass_Domain_Validation__c, Status__c 
                        FROM Site_Profile__c WHERE Id = :siteProfileId];
            list<Contact> cons = database.query(SiteUserHelper.CONTACTBASEQUERY + ' WHERE Id = \'' + sProfile.Contact__c + '\'');
            
            if (action.equalsIgnoreCase(QUICK_ACTION_ACTIVATE)) {
                
                //don't allow a hard bounce or inactive contact to be reactivated via the site profile
            	if (sProfile.Status__c == SiteProfileTriggerHelper.SITE_PROFILE_STATUS_HARD_BOUNCE) {
            		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Site Profile cannot be activated while the Contact is a Hard Bounce'));
            		return null;
            	}
            	else if (sProfile.Contact__r.Contact_Status__c != null && sProfile.Contact__r.Contact_Status__c.containsIgnoreCase('INACTIVE')) {
            		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Site Profile cannot be activated while the Contact is Inactive'));
            		return null;
            	}
                
                SiteUserHelper.SendVerificationEmail(cons[0], sProfile, 'sendNewUserEmail', false);
            }
            else if (action.equalsIgnoreCase(QUICK_ACTION_DEACTIVATE)) {
                sProfile.Status__c = SiteProfileTriggerHelper.SITE_PROFILE_STATUS_INACTIVE;
            }
            else if (action.equalsIgnoreCase(QUICK_ACTION_PASSWORD_RESET)) {
            	
            	//don't send password reset to hard bounce or inactive contact
            	if (sProfile.Contact__r.Contact_Status__c != null && sProfile.Contact__r.Contact_Status__c.containsIgnoreCase('INACTIVE')) {
		            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Cannot reset password for a Site Profile associated with an Inactive contact'));
		            return null;
		        }
		        else if (sProfile.Status__c == SiteProfileTriggerHelper.SITE_PROFILE_STATUS_HARD_BOUNCE) 
		        {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Cannot reset password for a Site Profile with a Hard Bounce Email'));
		        	return null;
		        }
            	
                SiteUserHelper.SendVerificationEmail(cons[0], sProfile, 'sendPasswordResetEmail', false);
            }
            
            //update the status code and site profile
            sProfile.Status_Code__c = SiteUserHelper.getStatusCode(sProfile);
            update sProfile;
            
            if(currentTheme == 'Theme2' || currentTheme == 'Theme3') 
            {
                Pagereference pg = new Pagereference('/' + sProfile.Id);
                pg.setRedirect(true);
                return pg;
            }
            else 
            {
                String navigateURL = '/apex/URLNavigator?operationtype=navigatetosobject&recordId=' + sProfile.Id;
                Pagereference pageRef = new PageReference(navigateURL);
                pageRef.setRedirect(true);
                return pageRef; 
            }
            return null;
        }
        catch(DMLException ex) {
            // add any error to the result that is returned on the VF page.
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getDMLMessage(0)));
            return null;
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage() + '\r\n' + ex.getStackTraceString()));
        	return null;
        }
        
    }
    
    @TestVisible private string encryptedRequest {
        get {
            if (encryptedRequest == null) {
                //get the site profile details
                sProfile = [SELECT Id, Username__c, User_Id__c, Type__c FROM Site_Profile__c WHERE Id = :siteProfileId LIMIT 1];
                
                //create our site user
                SiteUser sUser = new SiteUser();
                sUser.Command = 'sendPasswordResetEmail';
                sUser.User_Id = integer.valueOf(sProfile.User_Id__c);
                sUser.Site = sProfile.Type__c;
                sUser.Username = sProfile.Username__c;
                
                // set the Modified By to the current user's email address so the system doesn't think this update
                // came from the actual site user
                sUser.Modified_By = UserInfo.getUserEmail();
                // encrypt the SiteUser
                encryptedRequest = EncryptionHelper.encrypt(sUser);
                
            }
            return encryptedRequest;
        }
        set;
    }
    
    public boolean hasError {
        get {
            return (apexPages.getMessages().size() > 0);
        }
        set;
    }
}