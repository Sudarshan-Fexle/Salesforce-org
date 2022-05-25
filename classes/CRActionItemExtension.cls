public class CRActionItemExtension {
    
    public CR_Action_Item__c crai {get;set;}
    public static final Id RECORD_TYPE_ID_DEPLOYMENT_STEP = Schema.SObjectType.CR_Action_Item__c.getRecordTypeInfosByName().get('Deployment Plan Step').getRecordTypeId();
    public static final Id RECORD_TYPE_ID_ISSUE = Schema.SObjectType.CR_Action_Item__c.getRecordTypeInfosByName().get('Issue').getRecordTypeId();
    String currentTheme;
    /**
    * 
    * @description: constructor
    * 
    **/
    public CRActionItemExtension(ApexPages.StandardController controller) {
        //Initialize record variable
        crai = (CR_Action_Item__c)controller.getRecord(); 
        currentTheme = UserInfo.getUiThemeDisplayed();
    }
    
    public PageReference redirect() {
        
        //create a new page reference
        PageReference pageRef;
        
        //get record type
        map<string,string> params = ApexPages.currentPage().getParameters();
        Id rtId = params.get('RecordType');
        
        //Check the record type and redirect as needed
        if(rtId == RECORD_TYPE_ID_ISSUE)
        {
            //Redirect to a custom page
            pageRef = page.CRActionItem_Issue_New;
            pageRef.getParameters().putAll(params);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else 
        {
            if(currentTheme == 'Theme2' || currentTheme == 'Theme3') 
            {
                //Redirect to the standard edit page
                string objPrefix = CR_Action_Item__c.sObjecttype.getDescribe().getKeyPrefix();
                pageRef = new PageReference('/'+objPrefix+'/e');
                params.remove('sfdc.override');
                params.remove('save_new');
                pageRef.getParameters().putAll(params);
                pageRef.getParameters().put('nooverride', '1');
                pageRef.setRedirect(true);
                return pageRef;
            }
            else if(currentTheme == 'Theme4d') 
            {
                String navigateURL = '/apex/URLNavigator?operationtype=createRecord&entityName=CR_Action_Item__c&recordTypeSelection=false&' +
                    'recordTypeId=' + rtId + 
                    '&fields=Change_Request__c&defaults=' + crai.Change_Request__c + 
                    '&returnURL=' + crai.Change_Request__c;
                pageRef = new PageReference(navigateURL);
                return pageRef;
            }
        }
        
        return null;
    }
}