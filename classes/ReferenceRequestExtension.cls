/**
 * 
 *  Description     :  Extension class used on the ReferenceFulfillment VF Page
 *
 *  Revision Logs   :   v1.0 - 12/17/2015 - Created - Victor Hanson - Reference Tracking project (CR-20150826-9191)
 *                      v1.1 - Modified By - Abhinav Sharma - 04/11/2016 - CR-20160204-9586
 * 
 **/
public class ReferenceRequestExtension {
    
    //public variables
    public Reference_Request__c req { get; set; }
    public boolean saveAndSend { get; set; }
    
    public list<string> refModules {
        get {
            if (refModules == null) {
                refModules = new list<string>();
                if (req != null) refModules = req.Reference_Modules__c.split(ReferenceRequestController.DELIMITER);
            }
            return refModules;
        }
        set;
    }
    
    //static variables
    public static final string STATUS_RECOMMENDED = 'Recommended';
    public static final string APPROVAL_STATUS_PENDING = 'Pending';
    
    public ReferenceRequestExtension(ApexPages.StandardController controller) {
    
        //Initialize record
        req = (Reference_Request__c)controller.getRecord();
        
        //default save & send to false
        saveAndSend = false;
    }
    
    /**
     * 
     * @description: custom save method to save the Reference Request Contact changes
     * 
     **/
    public pageReference save() {
        
        string oldStatus = req.Request_Status__c;
        
        //set a save point
        Savepoint sp = Database.setSavepoint();
        
        try {
            
            //if the use clicked the "Send Recommendations" button, change the Status and Submitted By fields on the Reference Request
            if (saveAndSend) {
                req.Request_Status__c = STATUS_RECOMMENDED;
                req.Recommendations_Provided_By__c = UserInfo.getUserId();
                update req;
            }
            
            //validate records
            validateReferenceContacts();
            
            //insert records
            if (refConsToUpsert.size() > 0)
                upsert refConsToUpsert;
            
            else {
                Database.rollback(sp); //rollback save
                throw new customException(System.Label.ERROR_REFERENCE_REQUEST_CONTACT_MUST_BE_CHOSEN);
            }
            
            if (reqContactsToDelete.size() > 0)
                delete reqContactsToDelete;
        }
        
        catch(DMLException ex) {
        
            Database.rollback(sp); //rollback save
            req.Request_Status__c = oldStatus;
            req.Recommendations_Provided_By__c = null;
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, ex.getDMLMessage(0) ) );
            system.debug('@@DML Exception:' + ex + '  - ' + ex.getStackTraceString());
            return null;
        }
        
        catch(Exception ex) {
            Database.rollback(sp); //rollback save
            req.Request_Status__c = oldStatus;
            req.Recommendations_Provided_By__c = null;
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, ex.getMessage() ) );
            system.debug('@@Exception:' + ex + '  - ' + ex.getStackTraceString());
            return null;
        }
        
        return new PageReference('/' + req.Id);
    }
    
    /**
    * 
    * @description: verify Contact is present on all records being upserted
    * 
    **/
    public void validateReferenceContacts() {
        
        //Looping over Reference Request Contacts
        for (Reference_Request_Contact__c refCon : refConsToUpsert) {
            
            //Checking for null/blank value
            if (String.isBlank(refCon.Reference_Contact__c))
                throw new customException(System.Label.ERROR_CONTACT_IS_REQUIRED);
        }
    }
    
    /**
     * 
     * @description: list of leads to upsert once the user clicks save
     * 
     **/
    public list<Reference_Request_Contact__c> refConsToUpsert {
        
        get {
            
            refConsToUpsert = new list<Reference_Request_Contact__c>();
        
            for (referenceContactWrapper w : refConWrappers) refConsToUpsert.add(w.referenceRequestContact);
            
            //remove the last warm lead because that will never be inserted - it's there as a placeholder
            refConsToUpsert.remove(refConsToUpsert.size()-1);
            return refConsToUpsert;
        }
        set;
    }
    
    /**
     * 
     * @description: list of records related to the Reference Request
     * 
     **/
    public list<referenceContactWrapper> refConWrappers {
        get {
        
            if (refConWrappers == null) {
            
                refConWrappers = new list<referenceContactWrapper>();
                
                list<Reference_Request_Contact__c> refContacts = [SELECT Id, Name, Reference_Contact__c, 
                                                                  Reference_Contact__r.Name, 
                                                                  Reference_Contact__r.Title, 
                                                                  Reference_Contact__r.Account.Name, 
                                                                  Reference_Attributes__c, Reference_Modules__c, 
                                                                  Approval_Status__c, Approval_Reason__c, 
                                                                  Approval_Status_Date__c, Date_Reference_Released__c, 
                                                                  Reference_Contact_Comments__c
                                                                  FROM Reference_Request_Contact__c 
                                                                  WHERE Reference_Request__c = :req.Id 
                                                                  ORDER BY CreatedDate ASC];
                
                set<Id> contactIds = new set<id>();
                
                for (Reference_Request_Contact__c rc : refContacts) contactIds.add(rc.Reference_Contact__c);
                
                map<Id, Contact> contactMap = new map<Id, Contact>([SELECT Id, Name, Title, Account.Name 
                                                                    FROM Contact 
                                                                    WHERE Id IN :contactIds]);
                
                //Added By - Abhinav Sharma - 04/11/2016 - CR-20160204-9586
                //start from here
                //Set to hold the "Reference Contact" Ids which are currently having pending approval request                
                set<Id> existingApprovalsSet = new set<Id>();

                //Checking list for null and size value
                if(refContacts != null && refContacts.size() > 0) {
                    
                    //Retrieving existing approvals
                    list<ProcessInstance> existingApprovals = [SELECT Id, TargetObjectId
                                            FROM ProcessInstance 
                                            WHERE TargetObjectId IN :refContacts];
                    
                    //Populating set to hold records Ids
                    if(existingApprovals != null && existingApprovals.size() > 0) {
                        for(ProcessInstance e : existingApprovals)
                        existingApprovalsSet.add(e.TargetObjectId);
                    }
                }
                //Upto here
               
                //get all existing reference contacts
                for (Reference_Request_Contact__c rrc : refContacts) {
                    
                    referenceContactWrapper wrapper = new referenceContactWrapper(rrc, existingApprovalsSet.contains(rrc.Id));
                
                    if (contactMap.containsKey(rrc.Reference_Contact__c)) {
                        wrapper.contact = contactMap.get(rrc.Reference_Contact__c);  
                        wrapper.selectedConName = contactMap.get(rrc.Reference_Contact__c).Name; 
                    } 
                    
                    refConWrappers.add(wrapper);
                }
                        
                //if editable, add additional row so the user sees the green plus icon
                if (isEditable) {
                    
                    //if no records exist, add the first row  [if (refConWrappers.size() == 0) ]
                    refConWrappers.add(createReqContact());
                    refConWrappers.add(createReqContact());
                }
            }
            return refConWrappers;
        }
        set;
    }
    
    /**
     * 
     * @description: return a new Reference Request Contact
     * 
     **/
    public referenceContactWrapper createReqContact() {
        return new referenceContactWrapper(
            new Reference_Request_Contact__c(RecordTypeId=Schema.SObjectType.Reference_Request_Contact__c.getRecordTypeInfosByName().get('Reference Contact').getRecordTypeId(),
                                             Approval_Status__c = APPROVAL_STATUS_PENDING,
                                             Reference_Request__c = req.Id), false);
        
    }
    
    /**
     * 
     * @description: add a Reference Request Contact to the list
     * 
     **/
    public void addRefContact() {
        refConWrappers.add(createReqContact());
    }
    
    /**
     * 
     * @description: Get the index (row number) of the selected record
     * 
     **/
    public integer indexVal {
        get {
            try {
                indexVal = Integer.valueof(System.currentpagereference().getparameters().get('index'));
            }
            catch(exception e) {
                if (indexVal == null) indexVal = 0;
            }
            return indexVal;
        }
        set;
    }
    
    /**
     * 
     * @description: remove the selected row and add record to deletion list if applicable
     * 
     **/
    public void removeRefContact() {
        
        referenceContactWrapper wrapper = refConWrappers.get(indexVal-1);
        
        //if it has already been inserted, add to deletion list
        if (wrapper.referenceRequestContact.Id != null) {
            reqContactsToDelete.add(wrapper.referenceRequestContact);
        }
        
        refConWrappers.remove(indexVal-1);
    }
    
    /**
     * 
     * @description: list of records to delete once the user clicks save
     * 
     **/
    public list<Reference_Request_Contact__c> reqContactsToDelete {
        get {
            if (reqContactsToDelete == null) reqContactsToDelete = new list<Reference_Request_Contact__c>();
            return reqContactsToDelete;
        }
        set;
    }
    
    public void identifyContact() {
        
        //get the reference request contact
        referenceContactWrapper wrapper = refConWrappers.get(indexVal-2);
        wrapper.contact = new Contact();
        wrapper.selectedConName = '';
        
        //query the contact info
        if (wrapper.referenceRequestContact.Reference_Contact__c != null) {
        
            List<Contact> contactsList = [SELECT Id, Name, Title, Account.Name,
                         (SELECT Id, Reference_Module__c, 
                          Attribute_A__c, Attribute_B__c, Attribute_C__c, Attribute_D__c, 
                          Attribute_E__c, Attribute_F__c, Attribute_G__c, Attribute_H__c, Attribute_I__c, Attribute_J__c
                          FROM Reference_Modules__r WHERE IsActive__c = true AND Reference_Module__c IN :refModules) 
                         FROM Contact WHERE Id = :wrapper.referenceRequestContact.Reference_Contact__c];
            
            //Checking for the size and null value
            if(contactsList != null && contactsList.size() > 0){
                
                //put the contact info in the wrapper
                wrapper.contact = contactsList[0];
                wrapper.selectedConName = contactsList[0].Name;
                
                //seperate reference modules
                wrapper.referenceRequestContact.Reference_Modules__c = getReferenceModules(contactsList[0]);
                
                //set the reference attributes
                wrapper.referenceRequestContact.Reference_Attributes__c = getReferenceAttributes(contactsList[0]);
            }
        }
    }
    
    /**
     * @description: returns the list of reference modules seperated by line breaks
    **/
    public static string getReferenceModules(Contact c) {
    
        //set the reference modules
        list<string> refModules = new list<string>();
        
        for (Reference__c reference : c.Reference_Modules__r)
            refModules.add(reference.Reference_Module__c);
        
        return string.join(refModules, '\r\n').abbreviate(255);
    }
    
    /**
     * @description: 
     **/
    public static string getReferenceAttributes(Contact c) {
        
        //set the reference modules
        list<string> refAttributes = new list<string>();
        
        for (Reference__c reference : c.Reference_Modules__r) {
            if (reference.Attribute_A__c != null) refAttributes.add(reference.Attribute_A__c);
            if (reference.Attribute_B__c != null) refAttributes.add(reference.Attribute_B__c);
            if (reference.Attribute_C__c != null) refAttributes.add(reference.Attribute_C__c);
            if (reference.Attribute_D__c != null) refAttributes.add(reference.Attribute_D__c);
            if (reference.Attribute_E__c != null) refAttributes.add(reference.Attribute_E__c);
            if (reference.Attribute_F__c != null) refAttributes.add(reference.Attribute_F__c);
            if (reference.Attribute_G__c != null) refAttributes.add(reference.Attribute_G__c);
            if (reference.Attribute_H__c != null) refAttributes.add(reference.Attribute_H__c);
            if (reference.Attribute_I__c != null) refAttributes.add(reference.Attribute_I__c);
            if (reference.Attribute_J__c != null) refAttributes.add(reference.Attribute_J__c);
        }
        
        return string.join(refAttributes, '\r\n').abbreviate(255);
    }
    
    /**
     * 
     **/
    public class referenceContactWrapper {
        
        public Contact contact { get; set; }
        public Reference_Request_Contact__c referenceRequestContact { get; set; }
        public boolean isSubmitted { get; set; }
        public string selectedConName {get; set;}
        
        public referenceContactWrapper(Reference_Request_Contact__c referenceRequestContact, boolean isSubmitted) {
            if (referenceRequestContact != null) {
                this.referenceRequestContact = referenceRequestContact;
            }
            else {
                referenceRequestContact = new Reference_Request_Contact__c();
                contact = new Contact();
            }
            this.isSubmitted = isSubmitted;
        }
    }
    
    public boolean isEditable {
        get {
            return (req.Request_Status__c == 'New' || req.Request_Status__c == 'Search');
        }
        set;
    }
}