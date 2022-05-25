/**
 *	Purpose			:	Controller class for the Approval Override VF Page.
 *						Overrides the standard SF Approval page so users can approve records on objects they don't have access to.
 * 
 * 	Created By		:	Victor Hanson
 * 
 * 	Created Date	:	12/16/2015
 * 
 * Revision Logs	:	V_1.0 - Created
 *
 **/ 
public without sharing class ApprovalOverrideController {
    
    public static final string NO_PENDING_APPROVALS_FOUND = 'No pending approvals found with id';
    public static final string RECORD_DOES_NOT_EXIST = 'Record does not exist with Id';
    public static final string NO_FIELD_WITH_API_NAME = 'No field with the API Name';
    
    // stores the ordered-list of feld-value pairs.  If sort order didn't matter, we would use the fieldValueMap instead
    public list<fld> flds { get; set; }
    public boolean hasErrors {
        get {
            if (hasErrors == null) hasErrors = false;
            return hasErrors;
        }
        set;
    }
    
    /**
     * 
     **/
    public ApprovalOverrideController() {
        flds = new list<fld>();
        
        try {
            for (string key : fieldValueMap.keySet()) {
                flds.add(new fld(key, fieldValueMap.get(key)));
                //get the work item id.  If no record is found, this will display an error
                Id workItemId = getWorkItemId(recordId);
                if (workItemId == null) {
                    apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, NO_PENDING_APPROVALS_FOUND + ' <a href="/' + recordId + '">' + recordId + '</a>'));
                    hasErrors = true;
                }
            }
        }
        catch(Exception e) {
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + '\r\n' + e.getStackTraceString()));
            hasErrors = true;
        }
    }
    
    /**
     * @description: get the record id from the url
     **/
    public Id recordId {
        get {
            if (recordId == null) {
                recordId = ApexPages.currentPage().getParameters().get('recordId');
            }
            return recordId;
        }
        set;
    }
    
    /**
     * @description: get the fields that need to be displayed
     **/
    public list<string> fields {
        get {
            if (fields == null) {
                fields = new list<string>();
                string f = ApexPages.currentPage().getParameters().get('fields');
                if (f != null)
                    fields = f.split(',');
                else
                    apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The parameter \'fields\' is required'));
            }
            return fields;
        }
        set;
    }
    
    /**
     * @description: the generic sObject record based on the recordId provided.
     **/
    public SObject sobj {
        get {
            if (sobj == null) {
                //query for the sobject
                list<sObject> records = database.query('SELECT Id, ' + string.join(fields, ',') + ' FROM ' + objectAPIName + ' WHERE Id = \'' + recordId + '\'');
                if (records.size() > 0)
                    sobj = records[0];
                else
                    apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, RECORD_DOES_NOT_EXIST + ' ' + recordId + ' on Object ' + objectAPIName));
            }
            return sobj;
        }
        set;
    }    
    
    
    /**
     * @description: approve the request
     **/
    @RemoteAction
    public static void getApprovalResult(string recordId, boolean isApproved, string comments, string commentField) {
        
        //update the record with the comments provided
        if (comments != '' && commentField != '') {
            string objAPIName = getAPINameFromId(recordId);
            list<sObject> records = database.query('SELECT Id, ' + commentField + ' FROM ' + objAPIName + ' WHERE Id = \'' + recordId + '\'');
            if (records.size() > 0)
                records[0].put(commentField, comments);
            update records[0];
        }
        
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        
        //approve or deny the request
        if (isApproved)
            req.setAction('Approve');
        else
            req.setAction('Reject');
        
        //set the comments
        req.setComments(comments);
        
        Id workItemId = getWorkItemId(recordId); 
        req.setWorkitemId(workItemId);
        //submit the request for approval
        Approval.ProcessResult result =  Approval.process(req);
    }
    
    /**
     * @description: get the work item id
     **/
    public static Id getWorkItemId(Id targetObjectId)
    {
        Id retVal = null;
        
        for(ProcessInstanceWorkitem workItem  : [SELECT Id FROM ProcessInstanceWorkitem
                                                 WHERE ProcessInstance.TargetObjectId =: targetObjectId
                                                AND (ProcessInstance.Status = 'Submitted' OR ProcessInstance.Status = 'Pending')])
        {
            retVal  =  workItem.Id;
        }
        
        return retVal;
    }
    
    /**
     * @description: 
     **/
    public map<string, string> fieldValueMap {
        get {
            if (fieldValueMap == null) {
                fieldValueMap = new map<string, string>();
                
                //place all field names with their corresponding value in the map
                for (string fld : fields) {
                    
                    //get value
                    string value;
                    if (fld.contains('.')) {
                        list<string> strs = fld.split('\\.');
                        if (sobj.getSObject(strs[0]) != null)
                        	value = getStringValue(sobj.getSObject(strs[0]).get(strs[1]));
                    }
                    else {
                        value = getStringValue(sobj.get(fld));
                    }
                    
                    //get label
                    string label;
                    string tempFieldLabel = fld;
                    if (tempFieldLabel.contains('.')) {
                        fld = tempFieldLabel.split('\\.')[0].replace('__r', '__c');
                    }
                    if (fldToLabelMap.containsKey(fld.toLowerCase())) {
                        label = fldToLabelMap.get(fld.toLowerCase());
                    }
                    else {
                        throw new customException(NO_FIELD_WITH_API_NAME + ' "' + fld + '" on the "' + objectAPIName + '" object.');
                    }
                    
                    //put label and value in our map
                    fieldValueMap.put(label, value);
                }
            }
            return fieldValueMap;
        }
        set;
    }
    
    /**
     * @description: return string value of an object
     **/
    public static string getStringValue(Object o) {
        string str;
        
        if (o instanceOf date) {
            Date d = (Date) o;
            str = d.format();
        }
        else if (o instanceof dateTime) {
            DateTime dt = (dateTime) o;
            str = dt.format();
        }
        else if (o instanceOf boolean) {
            str = ((Boolean) o) ? 'true' : 'false';
        }
        else {
            str = string.valueOf(o);
        }
        return str;
    }
    
    
    //get the object name
    private string objectAPIName {
        get {
            if (objectAPIName == null) {
                objectAPIName = getAPINameFromId(recordId);
            }
            return objectAPIName;
        }
        set;
    }
    
    public map<string, string> fldToLabelMap {
        get {
            if (fldToLabelMap == null) {
                fldToLabelMap = getFieldAPIToLabelMap(objectAPIName);
            }
            return fldToLabelMap;
        }
        set;
    }
    
    /**
     * @description: 
     **/
    public static map<string, string> getFieldAPIToLabelMap(string objAPIName) {
        map<string, string> fieldAPIToLabelMap = new map<string, string>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objSchema = schemaMap.get(objAPIName);
        Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
        
        for (String fieldName: fieldMap.keySet()) {
            fieldAPIToLabelMap.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());
        }
        return fieldAPIToLabelMap;
    }
    
    /**
     * 
     * @description: return the API Name of an object based on its ID
     * 
	**/
    public static String getAPINameFromId(Id objectId) {
        //get all of the objects from your org
        map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        map<String, String> KeyPrefixMap = new map<String, String>();
        //get the prefix of the objects in Ids
        Set<String> keyPrefixSet = gd.keySet();
        for(String sObj : keyPrefixSet)
        {
            Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
            String tempName = r.getName();
            String tempPrefix = r.getKeyPrefix();
            //in this map, all the Objects with their prefixes will be stored
            KeyPrefixMap.put(tempPrefix,tempName);
        }
        
        String tPrefix = objectId;
        tPrefix = tPrefix.subString(0,3);
        //get the type of your specified object
        String objectType = keyPrefixMap.get(tPrefix);
        return objectType;
    }
    
    /**
     * @description: this class is used to keep the key value pairs for fields
     **/
    public class fld {
        public string label { get; set; }
        public string value { get; set; }
        public fld(string label, string value) {
            this.label = label;
            this.value = value;
        }
    }
}