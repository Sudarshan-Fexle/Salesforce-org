/**
 * 
 *  Description     :  Extension class for the ReferenceModule VF Page
 *
 *  Revision Logs   :   v1.0 - Created - Victor Hanson - 02/01/2017 - Reference Tracking project (CR-20170217-10703)
 * 
 **/
public class TimeTrackingController {
    
    //final strings for css alert
    public static final string ALERT_ERROR = 'error';
    public static final string ALERT_WARNING = 'warning';
    public static final string ALERT_SUCCESS = 'success';
    
    public string idString { get; set; }
    public transient string saveMessage { get; set; }
    public transient string msgSeverity { get; set; }
    public string objectLabel { get; set; }
    public boolean isLightningUI { get; set; }
    
    public Id etechRTId {
        get {
            if (etechRTId == null) etechRTId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('eTech').getRecordTypeId();
            return etechRTId;
        }
        set;
    }
    
    /**
     * 
     * @description: User record.
     * 
     **/
    private User usr {
        get {
            datetime qryStart = datetime.now();
            usr = (User)Cache.Session.get('local.Default.usr');
            if (usr == null) {
                usr = [SELECT Id, Employee_Contact_RecordID__c FROM User WHERE Id = :userInfo.getUserId()];
                Cache.Session.put('local.Default.usr', usr);
            }
            return usr;
        }
        set;
    }
    
    /**
     * 
     * @description: User's Contact Record
     * 
     **/
    public Contact userContact {
        get {
            userContact = (Contact)Cache.Session.get('local.Default.userContact');
            if (userContact == null) {
                if (user.Employee_Contact_RecordID__c != null) {
                    list<Contact> contacts = [SELECT Id, Title FROM Contact WHERE Counter_Id__c = :usr.Employee_Contact_RecordID__c];
                    if (contacts.size() > 0) {
                        userContact = contacts[0];
                        Cache.Session.put('local.Default.userContact', contacts[0]);
                    }
                }
            }
            return userContact;
        }
        set;
    }
    
    /**
     * 
     * @description: create the task and set field defaults
     * 
     **/
    public Task task {
        get {
            Id userContactId;
            if (userContact != null) userContactId = userContact.Id;
            if (task == null) task = new Task(ActivityDate = date.today(),
                                              WhoId = userContactId,
                                              recordTypeId = etechRTId,
                                             Status = 'Completed');
            if (recordId != null) {
                if (task.WhatId == null && isEligibleRecord) task.WhatId = recordId;
            }
            return task;
        }
        set;
    }
    
    /**
     * 
     * @description: constructor
     * 
     **/
    public TimeTrackingController() {
        //VH 2/12/2018: Get Id from url param
        idString = ApexPages.currentPage().getParameters().get('id');
        if (ApexPages.currentPage().getParameters().get('LightningUI') == '1')
            isLightningUI = true;
        else isLightningUI = false;
        
        checkSurvey();
    }
    
    /**
     * 
     * @description: return the record id, which was retreived from the parent's URL
     * 
     **/
    public string recordId {
        get {
            if (recordId == null) {
                if (idString != null && idString instanceOf Id)
                    recordId = idString;
            }
            return recordId;
        }
        set;
    }
    
    /**
     * 
     * @description: resets any existing values, so the getters/setters fire again when "idString" is populated with the updated whatId
     * 
     **/
    public void setLookup() {
        recordId = null;
        objectAPIName = null;
        objectLabel = null;
        task.WhatId = null;
        typeOptions = null;
    }
    
    /**
     * 
     * @description: save the task.  If successful, reset the task data.  Otherwise, display error
     * 
     **/
    public pageReference save() {
        saveMessage = null;
        msgSeverity = null;
        try {
            //validate 
            validateTask();
            
            //set the subject like "Time Entry - Case"
            string taskSubject = 'Time Entry';
            if (objectLabel != null) taskSubject += ' - ' + objectLabel;
            task.Subject = taskSubject.abbreviate(80);
            
            //insert the task
            insert task;
            
            //if this is a Change Request, create an IS Dev Activity record
            if (objectAPIName == 'SFDC_Change_Request__c') {
                createDevActivity();
            }
            
            //reset task and page variables
            task = null;
            totalHours = null;
            
            //set default value based on the type of object
            setDefaultType();
            
            //add success message
            saveMessage = 'Success';
            msgSeverity = 'confirm';
        }
        catch(DMLException ex) {
            //Return DML errors to the VF Page
			saveMessage = ex.getDMLMessage(0);
            msgSeverity = 'error';
        }
        catch(Exception ex) {
            //Return any errors to the VF Page
			saveMessage = ex.getMessage();
            msgSeverity = 'error';
        }
        return null;
    }
    
    /**
     * 
     * @description: if we're logging time on a Change Request, create a related IS Dev Activity record.
     * 
     **/
    private void createDevActivity() {
        SFDC_Request_Comment__c devActivity = new SFDC_Request_Comment__c(Activity_Date__c = Task.ActivityDate,
                                                                          Activity_Type__c = Task.Type,
                                                                          Comment__c = Task.Description,
                                                                          SFDC_Change_Request__c = Task.WhatId,
                                                                          Task_ID__c = task.Id,
                                                                          Time__c = Task.Duration_in_Hours__c,
                                                                          User__c = UserInfo.getUserId());
        //bypass triggers
        Util.BypassAllTriggers = true;
        insert devActivity;
    }
    
    /**
     * 
     * @description: verify the required fields were populated.
     * 
     **/
    private void validateTask() {
        list<string> requiredFields = new list<string>();
        if (task.WhatId == null) throw new customException('Related record required. Click the lookup button to select a record');
        if (task.ActivityDate == null) requiredFields.add('Activity Date');
        if (task.Duration_in_Hours__c == null || task.Duration_in_Hours__c <= 0) requiredFields.add('Duration (hrs) must be greater than 0');
        if (requiredFields.size() > 0) throw new customException('Required: ' + string.join(requiredFields,','));
    }
    
    /**
     * 
     * @description: return the total hours the current user has logged today
     * 
     **/
    public double totalHours {
        get {
            if (totalHours == null) {
                totalHours = 0;
                //get aggregate results
                List<aggregateResult> results = [select SUM(Duration_in_Hours__c) totalHours
                                                 FROM Task 
                                                 WHERE OwnerId = :UserInfo.getUserId() AND ActivityDate = TODAY AND Duration_in_Hours__c != null
                                                 GROUP BY OwnerId];
                if (results != null) {
                    for (AggregateResult ar : results)  
                        totalHours += (double) ar.get('totalHours');
                }
            }
            return totalHours;
        }
        set;
    }
    
    /**
     * 
     * @description: some records cannot be associated with tasks.
     * 
     **/
    public boolean isEligibleRecord {
        get {
            return objectsWithActivitiesEnabled.contains(objectAPIName);
        }
        set;
    }
    
    /**
     * 
     * @description: returns a set of object API Names that have Activities enabled
     * 
     **/
    private set<string> objectsWithActivitiesEnabled {
        get {
            if (objectsWithActivitiesEnabled == null) {
                objectsWithActivitiesEnabled = (set<string>)Cache.Org.get('local.Default.objectsWithActivitiesEnabled');
                //if the value hasn't been cached, get it and place it in the cache
                if (objectsWithActivitiesEnabled == null) {
                    objectsWithActivitiesEnabled = new set<string>();
                    String objectNames = '';
                    for (Schema.SObjectType objectType : Event.WhatId.getDescribe().getReferenceTo()) {
                        objectsWithActivitiesEnabled.add(string.valueOf(objectType));
                    }
                    Cache.Org.put('local.Default.objectsWithActivitiesEnabled', objectsWithActivitiesEnabled);
                }
            }
            return objectsWithActivitiesEnabled;
        }
        set;
    }
    
    /**
     * 
     * @description: get the object api name from the recordId
     * 
     **/
    public string objectAPIName {
        get {
            if (recordId != null && objectAPIName == null) {
                Id rId = recordId;
                Schema.SObjectType sobjectType = rId.getSObjectType();
                objectAPIName = sobjectType.getDescribe().getName();
                objectLabel = sobjectType.getDescribe().getLabel();
                //set default value based on the type of object
                setDefaultType();
            }
            return objectAPIName;
        }
        set;
    }
    
    /**
     * 
     * @description: default the Type based on the Time Tracking Defaults, 
     * 				 which are pulled based on either the Org-wide default, or the User.
     * 
     **/
    private void setDefaultType() {
        //default the Task.Type if it's a Case, CR, or Release object
        if (objectAPIName != null && (objectAPIName.equalsIgnoreCase('Case') || objectAPIName.equalsIgnoreCase('SFDC_Change_Request__c') || objectAPIName.equalsIgnoreCase('SFDC_Release__c'))) 
        {
            Time_Tracking_Defaults__c ttDefaults = Time_Tracking_Defaults__c.getInstance(UserInfo.getUserId());
            //if no Time Tracking Default is specified for the user, get the generic org instance instead
            if (ttDefaults == null) ttDefaults = Time_Tracking_Defaults__c.getInstance();
            if (objectAPIName.equalsIgnoreCase('Case'))
                Task.Type = ttDefaults.Activity_Type_Case__c;
            else if (objectAPIName.equalsIgnoreCase('SFDC_Change_Request__c'))
                Task.Type = ttDefaults.Activity_Type_Change_Request__c;
            else if (objectAPIName.equalsIgnoreCase('SFDC_Release__c'))
                Task.Type = ttDefaults.Activity_Type_Release__c;
        }
    }
    
    /**
     * 
     * @description: select options for the given object
     * 
     **/
    public list<selectOption> typeOptions {
        get {
            if (typeOptions == null || recordId != task.WhatId || typeOptions.size() == 0) {
                if (typeOptions == null) typeOptions = new list<selectOption>();
                set<string> picklistValues = new set<string>();
                //if the target object has a custom picklist, display its options
                if (picklistDependencyMap.containsKey(objectAPIName)) {
                    for (PicklistHelper.PicklistWrapper pWrapper : picklistDependencyMap.get(objectAPIName)) {
                        typeOptions.add(new selectOption(pWrapper.displayName, pWrapper.displayName));
                        picklistValues.add(pWrapper.displayName);
                    }
                    //this was added so we can default task type based on a value that isn't a typical option for the given option
                    if (!picklistValues.contains(Task.Type) && Task.Type != null) typeOptions.add(new selectOption(Task.Type, Task.Type));
                }
            }
            return typeOptions;
        }
        set;
    }
    
    /**
     * 
     * @description: returns a map of picklist wrappers
     * 
    **/
    private map<string, list<PicklistHelper.PicklistWrapper>> picklistDependencyMap {
        get {
            if (picklistDependencyMap == null) {
                picklistDependencyMap = (map<string, list<PicklistHelper.PicklistWrapper>>)Cache.Org.get('local.Default.picklistDependencyMapTimeTracking');
                if (picklistDependencyMap == null) {
                    picklistDependencyMap = new PicklistHelper('Task', 'Type', 'Picklist Usage').getWrapperMap();
                    Cache.Org.put('local.Default.picklistDependencyMapTimeTracking', picklistDependencyMap);
                }
            }
            return picklistDependencyMap;
        }
        set;
    }
    
    /**
     * @description: determines the highlight color of the time section
    **/
    public string alertClass {
        get {
            if (totalHours >= 2 && totalHours < 5) alertClass = ALERT_WARNING;
            else if (totalHours >= 5) alertClass = ALERT_SUCCESS;
            else alertClass = ALERT_ERROR;
            return alertClass;
        } 
        set;
    }
    
    public void checkSurvey() {
        Boolean previousTheme = (boolean)Cache.Session.get('local.Default.isLightning');
        
        if (previousTheme == true && !isLightningUI && previousTheme != isLightningUI)
            startSurvey = true;
        else startSurvey = false;
        
        system.debug('@@@OLD:' + previousTheme + '  isLightningUI:' + isLightningUI + ' NEW:' + startSurvey);
        
        // Add cache value to the partition
        Cache.Session.put('local.Default.isLightning', isLightningUI);
    }
    
    public Boolean startSurvey { get; set; }
}