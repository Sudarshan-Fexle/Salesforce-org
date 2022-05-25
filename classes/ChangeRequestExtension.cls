//Modify By - Abhinav Sharma - 10/18/2014 - CR-20140709-6141
/**
    Class used to override the standard edit page for Change Requests of the Record Type 'System Outage'
**/
public with sharing class ChangeRequestExtension {
    
    // override the standard save functionality
    public PageReference SaveOverride() {
        try {
            // trim any extra ", " delimiters off of the end
            if (ChangeRequest.IS_Team_Involved__c != null && ChangeRequest.IS_Team_Involved__c.trim().endsWith(',')) {
                integer lastPos = ChangeRequest.IS_Team_Involved__c.length() - 2;
                ChangeRequest.IS_Team_Involved__c = ChangeRequest.IS_Team_Involved__c.substring(0, lastPos);
            }
            
            // make sure there aren't any duplicate names in the IS Teams Involved Field
            if (!IsValid()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorString));
                return null;
            }
            
            upsert ChangeRequest;
        }
        catch(DMLException ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDMLMessage(0)));   
            return null;
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
        
        //Conditionally Redirecting user to detail page 
        PageReference pg = redirectToView();
        return pg;
    }
    
    //Added By - Abhinav Sharma - 10/18/2014 - CR-20140709-6141
    /**
     *  @description    :   Redicts the user to the appropriate case detail page.
     *
     *  @args           :
     *
     *  @return         :   PageReference
     *
     **/
    public PageReference redirectToView() {
        
        //Create a new Pagereference instance
        PageReference pageRef;
        
        //Setting VF page reference
        pageRef = Page.ChangeRequest_NoOverride;
        pageRef.getParameters().put('id', ChangeRequest.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }

    // the main change request record
    public SFDC_Change_Request__c ChangeRequest {
        get {
            if (ChangeRequest == null) {
                ChangeRequest = new SFDC_Change_Request__c();
                if (RecordTypeId != null && RecordTypeId != '')
                    ChangeRequest.RecordTypeId = RecordTypeId;
            }
            return ChangeRequest;
        }
        set;
    }
    
    // string of errors produced by the ValidateISTeam method
    public String errorString { get; set; }
    
    // 
    private boolean IsValid() {
        boolean isValid = true;
        // setup some lists/sets to store our name data
        Set<String> uniqueNames = new Set<String>();
        Set<String> duplicateNames = new Set<String>();
        List<String> duplicateList = new List<String>();
        List<String> names = new List<String>();
        // if the IS Team Involved is not null, make sure all values are unique
        if (ChangeRequest.IS_Team_Involved__c != null) {
            names = ChangeRequest.IS_Team_Involved__c.ToLowerCase().trim().split(', ');
            for (String name : names) {
                if (uniqueNames.contains(name)) {
                    duplicateNames.add(name);
                }
                else {
                    uniqueNames.add(name);
                }
            }
            system.debug('@@isValid duplicateNames:' + duplicateNames);
            if (duplicateNames.size() > 0) {
                // return false, because there are duplicates, so it is not valid
                isValid = false;
                errorString = '<b>';
                duplicateList.addAll(duplicateNames);
                for (integer i = 0; i < duplicateList.size(); i++) {
                    errorString += duplicateList[i];
                    if (i < duplicateList.size()-1)
                        errorString += ', ';
                }
                if (duplicateNames.size() == 1)
                    errorString += '</b> Appears';
                else
                    errorString += '</b> Appear';
                errorString += ' in the IS Team Involved list more than once.';
            
            }
        }
        
        return isValid;
    }
    
    public List<String> AllUsers {
        get {
            if (AllUsers == null) {
                AllUsers = new List<String>();
                
                //Updated by Ajit Surana -02/12/2014 - CR-20121212-1891
                //In query filter criteria replaced RecordTypeId = '012C0000000BkFB' with RecordType.DeveloperName = 'Employee'
                List<Contact> contacts = [SELECT Name FROM Contact WHERE Contact_Status__c = 'Active' AND RecordType.DeveloperName =: Constants.RECORD_TYPE_CONTACT_NAME_EMPLOYEE ORDER BY Name ASC LIMIT 1000];
                for (Contact con : contacts) {
                    AllUsers.add(con.Name);
                }
            }
            system.debug('@@AllUsers: ' + AllUsers);
            return AllUsers;
        }
        set;
    }
    
    
    // this is so you will know if the record is new or not -- this effects the Redirect() method
    public boolean IsNew {
        get {
            if (IsNew == null) {
                String newString = ApexPages.currentPage().getParameters().get('save_new');
                if (newString == '1')
                    IsNew = true;
                else
                    IsNew = false;
            }
            return IsNew;
        }
        set;
    }
    
    // if this is a System Outage record type, go to special VF page
    // otherwise, go to the standard edit page
    public PageReference redirect() {
        boolean redirectNow = false;
        PageReference retUrl;
        
        // see if this is a new record
        if (!IsSystemOutage && !IsLevel2 && !IsLevel3) {
            redirectNow = true;
            
            //Updated by Ajit Surana -02/12/2014 - CR-20121212-1891
            //Replace retUrl with ChangeRequest.Id == null 
            if (ChangeRequest.Id == null)
                retUrl = new PageReference('/a0U/e');
            else
                retUrl = new PageReference('/' + ChangeRequest.Id + '/e');
            
            if (RecordTypeId != '')
                retUrl.getParameters().put('RecordType', RecordTypeId);
            retUrl.getParameters().put('retURL', ReturnURL);
            retUrl.getParameters().put('nooverride', '1');
        }
        
        if (redirectNow)
            return retUrl;
        
        return null;
    }
    
    // determine whether or not this is a system outage record type
    public boolean IsSystemOutage {
        get {
            if (IsSystemOutage == null) {
                Id systemOutageId = Util.recordtypemap('SFDC_Change_Request__c').get('System Outage');
                if (RecordTypeId != '' && (systemOutageId == ChangeRequest.RecordTypeId || systemOutageId == RecordTypeId)) {
                    IsSystemOutage = true;
                }
                else {
                    IsSystemOutage = false;
                }
            }
            return IsSystemOutage;
        }
        set;
    }
    
    // determine whether or not this is a Level2 record type
    public boolean IsLevel2 {
        get {
            if (IsLevel2 == null) {
                Id level2Id = Util.RecordTypeId('SFDC_Change_Request__c', 'SFDC Change Request');
                if (RecordTypeId != '' && level2Id == RecordTypeId) {
                    IsLevel2 = true;
                }
                else {
                    IsLevel2 = false;
                }
            }
            return IsLevel2;
        }
        set;
    }
    
    // determine whether or not this is a Level2 record type
    public boolean IsLevel3 {
        get {
            if (IsLevel3 == null) {
                Id level3Id = Util.RecordTypeId('SFDC_Change_Request__c', 'Level III');
                if (RecordTypeId != '' && level3Id == RecordTypeId) {
                    IsLevel3 = true;
                }
                else {
                    IsLevel3 = false;
                }
            }
            return IsLevel3;
        }
        set;
    }
    
    // constructor
    public ChangeRequestExtension(ApexPages.StandardController controller) {
        // get the change request record id and query all fields
        Id ChangeRequestId = controller.getId();
        if (ChangeRequestId != null) {
            Set<String> additionalFields = new Set<String>();
            additionalFields.add('Owner.Name');
            string queryString = FieldDescribes.FullItemBaseQuery('SFDC_Change_Request__c', additionalFields) + ' WHERE Id = \'' + ChangeRequestId + '\'';
            ChangeRequest = database.query(queryString);
        }
    }
    
    // the return URL
    public String ReturnURL {
        get {
            if(ReturnURL == null) {
                ReturnURL = '';
                ReturnURL = ApexPages.currentPage().getParameters().get('retURL');
                if (ReturnURL == null)
                    ReturnURL = '/';
            }
            return ReturnURL;
        }
        set;
    }
    
    // the Record Type
    public String RecordTypeId {
        get {
            if(RecordTypeId == null) {
                RecordTypeId = '';
                RecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
                    
                system.debug('@@RecordTypeId = ' + RecordTypeId);
                
                if (RecordTypeId != null) {
                    ChangeRequest.RecordTypeId = RecordTypeId;
                }
                if (RecordTypeId == null && ChangeRequest != null) {
                    //RecordTypeId = ChangeRequest.RecordTypeId;
                    
                    //Updated by Ajit Surana -02/12/2014 - CR-20121212-1891
                    //Wrap code within try-catch block and put RecordTypeId = '' in catch block
                    try { 
                            if (ChangeRequest.RecordTypeId != null)
                                RecordTypeId = String.valueOf(ChangeRequest.RecordTypeId).substring(0,15);
                            else // there is a problem
                                RecordTypeId = '';
                    } catch (exception e) {
                        
                        RecordTypeId = '';
                    }
                }
                    
            }
            
            return RecordTypeId;
        }
        set;
    }
}