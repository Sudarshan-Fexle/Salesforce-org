//Modified By - Bhavi SFContractor - 05/17/2012 - CR-20111227-292 - Customized the DML error message
//Modified By - Bhavi SFContractor - 06/20/2012 - CR-20120302-530
//Modified By - Ajit Surana - 03/1/2014 - CR-20140204-4450 - Update the restrictionController to withoutSharing mode.
//Modified by - Mahendra Swarnakar - CR-20161102-10332 - 12/20/2016 - Comment out "CRMfusionDBR101.DB_Globals.triggersDisabled" flag

public without sharing class RestrictionController {
    // the restriction record
    public Restrictions__c Restriction {
        get {
            if (Restriction == null) {
                Restriction = new Restrictions__c();
                Restriction.Name = '[Subject is auto-populated]';
            }
            return Restriction;
        }
        set;
    }
    
    public String ReturnURL { get; set; }
    
    public PageReference Save() {
        // disable dupeblocker triggers
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        
        Restrictions__c restrictionClone = Restriction.clone();
        
        // set a save point in case thes save fails
        System.SavePoint sp = database.setSavepoint();
        
        // try to save the Restriction
        try {
            Util.BypassAllTriggers = true;
            Util.IsBatch = true;
            upsert Restriction;
            Util.BypassAllTriggers = false;
            Util.IsBatch = false;
        }
        catch(DMLException ex) { //Added By - Bhavi SFContractor - 05/17/2012 - CR-20111227-292 - Customized the DML error message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDMLMessage(0)));   
            return null;
        }
        catch(Exception ex) { // if there was an error, return null and display the error to the user
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));   
            return null;
        }
        
        // create a Restriction MTM list to hold the records we will update
        List<Restricted_MtM__c> mtmList = new List<Restricted_MtM__c>();
        List<Restricted_MtM__c> mtmDeleteList = new List<Restricted_MtM__c>();
        
        // check to see if any existing Restriction MTM records were deleted -- if so, commit that delete to the DB
        for (RestrictionMTMWrapper mtm : RestrictionMTMList) {
            if (mtm.IsDeleted == true && mtm.RestrictionMTM.Id != null) {
                mtmDeleteList.add(mtm.RestrictionMTM);
            }
        }
        
        // if this is a new Restriction MTM record, assign it the Restriction Id and save
        for (RestrictionMTMWrapper mtmWrapper : RestrictionMTMsForDisplay) {
            if (mtmWrapper.RestrictionMTM.Restriction__c == null && (mtmWrapper.RestrictionMTM.Account__c  != null || mtmWrapper.RestrictionMTM.Contact__c  != null) ) {
                mtmWrapper.RestrictionMTM.Restriction__c = Restriction.Id;
                mtmList.add(mtmWrapper.RestrictionMTM);
            }
        }
        
        // try to save the associated Restriction MTM records
        try {
            // insert/update existing records
            if (mtmList.size() > 0) {
                Util.BypassAllTriggers = true;
                upsert mtmList;
            }
            
            // delete selected mtms
            if (mtmDeleteList.size() > 0) {
                //Util.BypassAllTriggers = true;
                delete mtmDeleteList;
            }
            
            //Check if restriction's Email Renewal Opportunity Owners Summary is checked, then send notofication to active opportunities owners
            if(Restriction.Email_Renewal_Opportunity_Owners_Summary__c == true) {
                
                Boolean isNotified = notifyActiveOpportunitiesOwners(Restriction);
                
                if(isNotified == false)
                    return null;
            }
        }
        catch(Exception ex) {
            // rollback changes
            database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));   
            Restriction = restrictionClone;
            return null;
        }
        
        // After the Restriction__c record is updated, it will kick off a batch job to update all Restriction MTM records so that all of their associated Institutions/Contacts can be updated
        // without hitting SOQL, DML, or Script Stmt limits
        Util.IsBatch = false;
        Util.BypassAllTriggers = false;
        update Restriction;
        
        return new PageReference(ReturnURL);
    }
    
    //This method is send teh email notification to all the current year Active opportunities owners - CR-20120302-530
    private List<String> prepareToAddresses(Restrictions__c restriction) {
        
        //Create a set of Account Ids, this set will be used in to fetch all current year active opportunities
        Set<Id> accountIds = new Set<Id>();
        
        System.debug('Sending notification for RestrictionId:' + restriction.Id);
        
        //loop through the MtM records
        for(Restricted_MtM__c rMtM : [Select Account__c, Contact__r.AccountId from Restricted_MtM__c where Restriction__c =: restriction.Id]) {
            
            //Check for the account id and add in set. If account Id is null the add accountId related to the contact
            if(rMtm.Account__c != null)
                accountIds.add(rMtM.Account__c);
            else if(rMtM.Contact__r.AccountId != null)
                accountIds.add(rMtM.Contact__r.AccountId);
        }
        
        //Create the Set of owners
        Set<Id> ownerIds = new Set<Id>();
        
        if(accountIds.size() > 0) {
            //Fetch all the active opportunities using this account Ids set
            for(Opportunity opp : [Select Id, OwnerId from Opportunity where AccountId IN: accountIds AND StageName !=: Constants.CLOSED_WON 
                                    AND StageName !=: Constants.CLOSED_LOST AND StageName !=: Constants.DISQUALIFIED AND CloseDate = THIS_YEAR]) {
                
                //add opportunity owners in set
                ownerIds.add(opp.OwnerId);
                    
            }
            
            //Create a set to hold the owners ids
            Set<String> ownersEmails = new Set<String>();
            
            //Loop through the owner records
            for(User user : [Select Email from User where Id IN: ownerIds AND IsActive = true]) {
                
                //Add email in set
                ownersEmails.add(user.Email);
            }
        
            return new List<String>(ownersEmails);
        }
        
        return null;
    }
    
    //This method is send teh email notification to all the current year Active opportunities owners - CR-20120302-530
    private Boolean notifyActiveOpportunitiesOwners(Restrictions__c restriction) {
        
        //get the email template id
        List<EmailTemplate> emailTemplates = [Select Id from EmailTemplate where DeveloperName =: Constants.RESTRICTION_UPDATED_NOTIFICATION AND IsActive = true];
        
        //IF email template is defined
        if(emailTemplates.size() > 0) {
            
            //Create list of toAddresses
            List<String> toAddresses = prepareToAddresses(restriction);
            
            if(toAddresses == null || toAddresses.size() == 0)
                return false;
            else {
                
                System.debug('Sending email to: ' + toAddresses);
                
                //Dummy Contact
                Contact dummyContact = CaseEmailController.CreateDummyContact(toAddresses[0]);
                
                //Send Notification Email
                EmailHandler.sendEmail(toAddresses, restriction.Id, dummyContact.Id, emailTemplates[0].Id);
                
                //delete dummy Contact
                delete dummyContact;
                
                return true;
            }
        } else {
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Constants.ERROR_NO_RESTRICTION_EMAIL_TEMPLATE_DEFINED));
            return false;
        }
    }
    
    /* VRH commented out on 3/2/12 -- this is being moved to CR-530
    public static Set<String> BuildEmailSet(List<Restricted_MtM__c> rMTMs) {
        Set<String> retVal = new Set<String>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        
        for (Restricted_MtM__c mtm : rMTMs) {// see if the Account__c field is filled in -- if not, find the account from the contact
            if (mtm.Account__c != null) accountIds.add(mtm.Account__c);
            else if (mtm.Contact__c != null) contactIds.add(mtm.Contact__c);
        }
        // get all of the contacts and their associated account ids
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds];
        for (Contact c : contacts) accountIds.add(c.AccountId);
        
        // now get all associated renewal opportunities
        List<Opportunity> opportunities = [SELECT Name, Id, OwnerId FROM Opportunity
                                            WHERE StageName != 'Closed Won' AND StageName != 'Closed Lost' AND
                                            StageName != 'Disqualified' AND AccountId IN :accountIds];
        
        for (Opportunity opp : opportunities)
            userIds.add(opp.OwnerId);
            
        List<User> users = [SELECT Id, Email FROM User WHERE Id IN :userIds];
        
        for (User u : users)
            retVal.add(u.Email);
        
        return retVal;
    }
    
    public static void SendOppNotificationEmails(List<Restrictions__c> triggerNew, Map<Id, Restrictions__c> oldMap) {
        List<Restrictions__c> restrictionList = new List<Restrictions__c>();
        for (Restrictions__c r : triggerNew) {
            // determine if the emails should be sent -- if so, get the restriction MTM records
            List<Restricted_MtM__c> tempRestrictions = new List<Restricted_MtM__c>();
            Restrictions__c oldRestriction = oldMap.get(r.Id);
            if (oldRestriction == null && (r.Email_Renewal_Opportunity_Owners_Summary__c == true || r.Email_Marketing_Program_Leader_Summary__c == true)) {
                if (r.Email_Marketing_Program_Leader_Summary__c == true)
                    tempRestrictions = [SELECT Name, Id, Account__c, Contact__c, Restrictions__c FROM Restricted_MtM__c WHERE Restrictions__c = :r.Id];
            }
            else if (r.Email_Marketing_Program_Leader_Summary__c == true && oldRestriction.Email_Marketing_Program_Leader_Summary__c == false) {
                
            }
        }
            
        // set to hold all of the unique email addresses that must be notified
        Set<String> notificationEmailSet = BuildEmailSet(rMTMs);
        // turn the set in to a list
        List<String> notificationEmailList = new List<String>();
        notificationEmailList.addAll(notificationEmailSet);
        EmailHandler.sendEmail(notificationEmailList, 'test', 'test');
        
    }*/
    
    public PageReference Cancel() {
        return new PageReference(ReturnURL);
    }
    
    // list of restriction mtm records
    public List<RestrictionMTMWrapper> RestrictionMTMList {
        get {
            if (RestrictionMTMList == null)
                RestrictionMTMList = new List<RestrictionMTMWrapper>();
            return RestrictionMTMList;
        }
        set;
    }
    
    // This is used to display the data grid because it is careful not to show deleted items.
    public List<RestrictionMTMWrapper> RestrictionMTMsForDisplay {
        get
        {
            List<RestrictionMTMWrapper> retVal = new List<RestrictionMTMWrapper>();
            for(RestrictionMTMWrapper i : RestrictionMTMList)
                if(i.IsDeleted == false || i.IsDeleted == null) retVal.add(i);
            return retVal;
        }
        set;
    }
    
    // controller extension
    public RestrictionController(ApexPages.StandardController stdController) {
        Id RestrictionId = stdController.getId();
        if (RestrictionId != null) {
            string queryString = FieldDescribes.FullItemBaseQuery('Restrictions__c', null) + ' WHERE Id = \'' + RestrictionId + '\'';
            system.debug('@@QueryString: ' + queryString);
            Restriction = database.query(queryString);
        }
        
        if (Restriction.Name == null)
            Restriction.Name = '[Subject will auto-populate]';
        RelatedToId = ApexPages.currentPage().getParameters().get('RelatedToId');
        ReturnURL = ApexPages.currentPage().getParameters().get('retURL');
        if (ReturnURL == null)
             ReturnURL = '/';
        // if this is an existing restriction, find all of the Restriction MTMs that are associated with it
        if (Restriction.Id != null) {
            List<Restricted_MtM__c> existingRestrictions = [SELECT Id, Account__c, Contact__c, Restriction__c FROM Restricted_MtM__c
                                                            WHERE Restriction__c = :Restriction.Id];
            for (Restricted_MtM__c restrictionMTM : existingRestrictions)
                AddRestrictionMTM(restrictionMTM);
        }
        else {
            // if there is a related to record, add it to the mtm list
            AddRestrictionMTM(RelatedToId);
        }
    }
    
    public pageReference AddRestrictionMTM() {
        //AddRestrictionMTM(null);
        RestrictionMTMWrapper mtm = new RestrictionMTMWrapper();
        RestrictionMTMList.add(mtm);
        return null;
    }
    
    public void AddRestrictionMTM(Restricted_MtM__c restrictionMTM) {
        RestrictionMTMWrapper mtm = new RestrictionMTMWrapper(restrictionMTM);
        RestrictionMTMList.add(mtm);
    }
    
    public void AddRestrictionMTM(Id recordId) {
        RestrictionMTMWrapper mtm = new RestrictionMTMWrapper();
        if (recordId != null) {
            String objectType = FindObjectType(recordId);
            if (objectType.toLowerCase() == 'contact') {
                mtm.RestrictionMTM.Contact__c = recordId;
                mtm.ObjectType = 'Contact';
            }
            else if (objectType.toLowerCase() == 'account') {
                mtm.RestrictionMTM.Account__c = recordId;
                mtm.ObjectType = 'Account';
            }
        }
        
        RestrictionMTMList.add(mtm);
    }
    
    public Id RelatedToId { get; set; }
    
    public Map<String, String> KeyPrefixMap { get; set; }
    
    public String FindObjectType(Id objectId) {
        if (KeyPrefixMap == null) {
            //get all of the objects from your org
            Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
            KeyPrefixMap = new Map<String, String>{};
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
        }
        
        String tPrefix = objectId;
        tPrefix = tPrefix.subString(0,3);
        //get the type of your specified object
        String objectType = keyPrefixMap.get(tPrefix);
        return objectType;
    }
    
    public List<SelectOption> ObjectTypes {
        get {
            if (ObjectTypes == null) {
                ObjectTypes = new List<SelectOption>();
                ObjectTypes.add(new SelectOption('Contact', 'Contact'));
                ObjectTypes.add(new SelectOption('Account', 'Institution'));
            }
            return ObjectTypes;
        }
        set;
    }
    
    public static map<String, Id> RTMap {
        get {
            if (RTMap == null) {
                 RTMap = Util.recordtypemap('Restricted_MtM__c');
            }
            return RTMap;
        }
        set;
    }
    
    /** Restriction wrapper **/
    public class RestrictionMTMWrapper {
        
        public RestrictionMTMWrapper(Restricted_MtM__c restriction) {
            RestrictionMTM = restriction;
            if (RestrictionMTM.Account__c != null) {
                ObjectType = 'Account';
                // set the record type id to the Account redord type
                RestrictionMTM.RecordTypeId = rtmap.get('Account Restriction');
                RestrictionMTM.Account__c = restriction.Account__c;
            }
            else if (RestrictionMTM.Contact__c != null) {
                ObjectType = 'Contact';
                RestrictionMTM.RecordTypeId = rtmap.get('Contact Restriction');
                RestrictionMTM.Contact__c = restriction.Contact__c;
            }
        }
        
        public boolean IsDeleted { get; set; }
        
        // empty constructor
        public RestrictionMTMWrapper() {
            RestrictionMTM = new Restricted_MtM__c();
        }
        
        public Restricted_MtM__c RestrictionMTM { get; set; }
        
        public String ObjectType {
            get {
                if (ObjectType == null)
                    ObjectType = 'Contact';
                return ObjectType;
            }
            set;
        }
        
        
    }
    
    
}