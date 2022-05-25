/**
 * 	Description     :   This is the controller class for CRActionItem_Issue_New vf page.
 * 
 * 	Created by      :   
 *
 * 	Created Date    :   
 *
 * 	Revision Log    :   V1.1 - Created - 
 *   			    V1.2 - Modified by - Abhinav Sharma - CR-20170807-11128 - 08/31/2017 - Addded doCancel method
 * 			    V1.3 - Modified by - Mahendra Swarnkar - 12/23/2019 - CR-20191217-13566 - Commented the "issue.Classification__c = 'Bug'".
**/
public class IssueTrackingExtension {
    
    public CR_Action_Item__c issue {get; set;}
    public String crID {get; set;}
    String currentTheme;
    
    private ApexPages.StandardController stdController { get; set; }
    
    public boolean isNew {
        get {
            return issue.Id == null;
        }
        set;
    }
    
    //return url
    @testVisible
    private string retURL {
        get {
            if (retURL == null) {
                retURL = ApexPages.currentPage().getParameters().get('retURL');
                if (retURL == null) retURL = '/'; //if there is no return url -- set the default
            }
            return retURL;
        }
        set;
    }
    
    private string ChangeRequest {
        get {
            if (ChangeRequest == null) {
                ChangeRequest = ApexPages.currentPage().getParameters().get('ChangeRequest');
                if (ChangeRequest == null) ChangeRequest = '';
            }
            return ChangeRequest;
        }
        set;
    }
    
    /**
     * @description: constructor
     **/
    public IssueTrackingExtension(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        //setup the initial reference perk
        issue = (CR_Action_Item__c)stdController.getRecord();
        currentTheme = UserInfo.getUiThemeDisplayed();
        
        if (isNew) {
            setFieldDefaults();
            if (ChangeRequest != ''){
                issue.Change_Request__c = ChangeRequest;
            }
        }
    }
    
    public void setFieldDefaults(){
        issue.Issue_Date__c = system.today();
        issue.Type__c = 'QA';
        //Commented the "issue.Classification__c = 'Bug'" by Mahendra Swarnkar - 12/23/2019 - CR-20191217-13566
        //issue.Classification__c = 'Bug';
        issue.Action_Item_Status__c = 'New';
        
        //Deeksha Sachdeva - 02/09/2017 - Check if the URL is having specific Record type, set that else default will go on
        String recTypeId = ApexPages.currentPage().getParameters().get('RecordType');
        if(recTypeId != null && recTypeId instanceOf Id)
            issue.RecordTypeId = recTypeId;
        
        //Deeksha Sachdeva - 02/08/2017 as per Karl mail request
        //issue.Stage__c = 'Triage';
        
        issue.Reported_By__c = UserInfo.getUserId();
        issue.Assigned_To_Role__c = 'Project Manager';
    }
    
    public Pagereference doCancel() {
		if(currentTheme == 'Theme2' || currentTheme == 'Theme3') 
        {
            Pagereference pg = new Pagereference('/' + issue.Change_Request__c);
            pg.setRedirect(true);
            return pg; 
        }
		else
        {
            String navigateURL = '/apex/URLNavigator?operationtype=navigatetosobject&recordId=' + issue.Change_Request__c;
            Pagereference pageRef = new PageReference(navigateURL);
            return pageRef;
        }    
    }
}