/**
Desription      :   This class is used on the main Site pages and contains methods for site functionality (ie: EAB.com/Advisory.com).

Created By      :   Victor Hanson

Created Date    :   07/29/2014

Revision Logs   :   V1.1 - Created
                    V1.2 - Modified by Mahendra Swarnkar - 12/07/2016 - CR-20160328-9718
                    V1.3 - Commented By - Neha Sharma - 05/19/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
**/ 
public class SiteController {
    
    public final static String ADVISORY_SITE_USER_TYPE = 'Guest';
    public final static String UNSUBSCRIBE_BY_MEMBER = 'Inactive - Unsubscribed by Member';
    public final static String UNSUBSCRIBE_BY_SF_USER = 'Inactive - Unsubscribed by ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
    public final static String SUBSCRIPTION_ACTIVE = 'Active';
    public final static String SUBSCRIPTION_CATEGORY_PRODUCT = 'EMAIL_WATCH';
    public final static String SUBSCRIPTION_CATEGORY_DAILY = 'EMAIL_DAILY';
    public final static String SUBSCRIPTION_CATEGORY_BLOG = 'EMAIL_BLOG';
    public final static String SUBSCRIPTION_CATEGORY_TOPIC = 'EMAIL_TOPICS';
    
    public boolean 	isOrgSearch 			{ get; set; }
    public boolean 	SaveSuccessful 			{ get; set; }    
    public String 	SaveMessage 			{ get; set; }
    public String 	InstitutionId 			{ get; set; }
    public string 	encryptedRequest 		{ get; set; }
    public boolean 	sidebar 				{ get; set; }
    public boolean 	showHeader 				{ get; set; }
    public string 	JSONResponse 			{ get; set; }
    public String 	SectionName 			{ get; set; }
    public String 	SectionType 			{ get; set; }
    public Id 		TempSubscriptionId 		{ get; set; }
    public boolean 	TempSubscriptionCreate 	{ get; set; }
    
    // list of contacts to return
    public List<Contact> Contacts { get; set; }
    
    //constructor
    public SiteController() {
        
        // get the encrypted request
        encryptedRequest = ApexPages.currentPage().getParameters().get('req');
        try {
            
            // if this is an internal request, get the contact via the Id
            string conId = ApexPages.currentPage().getParameters().get('id');
            if (conId != null && conId != '') {
                conId = conId.subString(0, 15);
                sidebar = true;
                showHeader = true;
                string queryString = SiteUserHelper.CONTACTBASEQUERY + ' WHERE Id = \'' + conId + '\'';
                Contact con = database.query(queryString);
                mainContact = new SiteControllerHelper.ContactWrapper(con, true);
            }
            
            //decode the request
            if (encryptedRequest != null) {
                
                sUser = SiteUserHelper.getSiteUser(encryptedRequest);
                siteProfileLogger.originalSiteUser = sUser.clone();
                
                if (sUser.command.equalsIgnoreCase('userDetails') && sUser.ContactWrappers.size() > 0) {
                    mainContact = sUser.ContactWrappers[0];
                    //assign the proper site profile based on the user id provided
                    for (Site_Profile__c sProfile : mainContact.con.Site_Profiles__r) {
                        if (integer.valueOf(sProfile.User_Id__c) == sUser.User_Id) {
                            sUser.Site_Profile = sProfile;
                            break;
                        }
                    }
                    //perform the action
                    sUser = SiteUserHelper.PerformAction(sUser);
                }
            }
        }
        catch(Exception e) {
            sUser.Response = 'Error: ' + e.getMessage() + ' on line number: ' + e.getLineNumber() + '  Stack:' + e.getStackTraceString();
        }
    }
    
    //some actions require DML statements, which are not allowed in the constructor, so they have to occur during initialization
    public void Initialize() {
        if (sUser != null) {
            if (sUser.Response == null) {
                try {
                    sUser = SiteUserHelper.PerformAction(sUser);
                    if (sUser.Command != null && sUser.command.equalsIgnoreCase('searchOrganization'))
                        isOrgSearch = true;
                } catch(Exception ex) {
                    sUser.Response = 'Error: ' + ex.getMessage() + ' on line number: ' + ex.getLineNumber() + '  Stack:' + ex.getStackTraceString();
                }
            }
            
            JSONResponse = EncryptionHelper.Encrypt(sUser);
        }
        SiteProfileLogger.Log(sUser);
    }
    
    //Site User
    public SiteUser sUser {
        get {
            if (sUser == null) sUser = new SiteUser();
            /*sUser.User_Id = integer.valueOf(mainContact.Con.Advisory_com_User_Id__c);
            sUser = SiteUserHelper.Action_getUser(sUser, false);*/
            return sUser;
        }
        set;
    }
    
    //contact wrapper
    public SiteControllerHelper.ContactWrapper mainContact {
        get {
            if (MainContact == null) {
                MainContact = new SiteControllerHelper.ContactWrapper();
            }
            return MainContact;
        }
        set;
    }
    
    public boolean showDebugInfo {
        get{
            if (showDebugInfo == null) {
                string debug = ApexPages.currentPage().getParameters().get('debug');
                if (debug != null && debug.equalsIgnoreCase('TRUE')) {
                    showDebugInfo = true;
                }
            }
            return showDebugInfo;
        }
        set;
    }
    
    //debugging methods
    public string str { get; set; }
    public string retVal { get; set; }
    public string retVal_URLEncode { get; set; }
    public pageReference encrypt() {
        retVal = EncryptionHelper.EncryptString(str);
        retVal_URLEncode = EncodingUtil.urlEncode(retVal, 'UTF-8');
        return null;
    }
    
    public pageReference decrypt() {
        try {
        	retVal = EncryptionHelper.Decrypt(EncodingUtil.base64Decode(str));
        }
        catch(Exception e) {
            //try urldecoding first
            retVal = EncodingUtil.urlDecode(EncryptionHelper.Decrypt(EncodingUtil.base64Decode(str)), 'UTF-8');
        }
        return null;
    }
    
    // Website integration settings for EAB.com / Advisory.com
    public Sitecore_Settings__c sitecoreSettings {
        get {
            if (sitecoreSettings == null) {
                sitecoreSettings = SiteUserHelper.sitecoreSettings;
            }
            return sitecoreSettings;
        }
        set;
    }
    
    /**
     * @description:	find all contacts for a given institution
     * 
     **/
    public PageReference FindInstitutionContacts() {
        
        // set this to false because you will no longer be on the organization search results
        isOrgSearch = false;
        
        string queryString = SiteUserHelper.CONTACTBASEQUERY + ' WHERE AccountId = :InstitutionId AND Id IN (SELECT Contact__c FROM Site_Profile__c) LIMIT 100';
        
        List<Contact> Contacts = database.query(queryString);
        
        // clear any existing contact wrappers
        sUser.ContactWrappers.clear();
        
        for (Contact c : contacts)
            sUser.ContactWrappers.add(new SiteControllerHelper.ContactWrapper(c, false));
        
        return null;
    }
    
    /**
     * @description:	
     * 
     **/
    public String UnsubscribeStatus {
        get {
            if (UnsubscribeStatus == null) {
                if (UserInfo.getUserType().equalsIgnoreCase(ADVISORY_SITE_USER_TYPE))
                    UnsubscribeStatus = UNSUBSCRIBE_BY_MEMBER;
                else
                    UnsubscribeStatus = UNSUBSCRIBE_BY_SF_USER;
            }
            return UnsubscribeStatus;
        }
        set;
    }
    
    /**
     * @description:	
     * Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
     **/
    /*public Map<Id, SiteSubscriptionHelper.SubscriptionWrapper> SubscriptionWrapperMap {
        get {
            if (SubscriptionWrapperMap == null) {
                SubscriptionWrapperMap = new Map<Id, SiteSubscriptionHelper.SubscriptionWrapper>();
                for (SiteSubscriptionHelper.SubscriptionWrapper subWrapper : MainContact.EligibleSubscriptions) {
                    SubscriptionWrapperMap.put(subWrapper.EligibleSubscriptionId, subWrapper);
                }
            }
            return SubscriptionWrapperMap;
        }
        set;
    }*/
    
    /**
     * @description:	subscribe to all eligible sub options in a given section  ie: Subscribe to all "Blog Alerts"
     * 
     **/
    public void SubscribeAll() {
        //Commented By - Neha Sharma - 05/19/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        // get all active subscriptions
        /*List<Subscription__c> activeSubscriptions = [SELECT Id, Subscription_ID__c 
                                                     FROM Subscription__c 
                                                     WHERE Contact__c = :MainContact.Con.Id AND Subscription_Status__c = :SUBSCRIPTION_ACTIVE];
        // make a set of subscription option ids
        Set<Id> subscriptionOptionIdSet = new Set<Id>();
        for (Subscription__c sub : activeSubscriptions) subscriptionOptionIdSet.add(sub.Subscription_ID__c);
        
        if (SectionType == SiteUserHelper.SITE_EAB && MainContact.mapTypeToSubscriptionList_EAB.get(SectionName) != null) {
            for (SiteSubscriptionHelper.SubscriptionWrapper wrapper : MainContact.mapTypeToSubscriptionList_EAB.get(SectionName)) {
                // if they are already subscribed, continue to the next record
                if (wrapper.IsSubscribed || subscriptionOptionIdSet.contains(wrapper.EligibleSubscriptionId)) continue;
                
                Subscription__c tempSubscription = new Subscription__c();
                tempSubscription.Contact__c = MainContact.Con.Id;
                tempSubscription.Subscription_ID__c = wrapper.EligibleSubscriptionId;
                tempSubscription.Send_Notification_Email__c = true;
                tempSubscription.Activation_Date__c = system.now();
                tempSubscription.Subscription_Status__c = SUBSCRIPTION_ACTIVE;
                
                SubscriptionsAdd.put(wrapper.EligibleSubscriptionId, tempSubscription);
            }
        }
                     
        if (SectionType == SiteUserHelper.SITE_ADVISORY && MainContact.mapTypeToSubscriptionList_Advisory.get(SectionName) != null) {
        	for (SiteSubscriptionHelper.SubscriptionWrapper wrapper : MainContact.mapTypeToSubscriptionList_Advisory.get(SectionName)) {
	            // if they are already subscribed, continue to the next record
	            if (wrapper.IsSubscribed || subscriptionOptionIdSet.contains(wrapper.EligibleSubscriptionId)) continue;
	            
	            Subscription__c tempSubscription = new Subscription__c();
	            tempSubscription.Contact__c = MainContact.Con.Id;
	            tempSubscription.Subscription_ID__c = wrapper.EligibleSubscriptionId;
	            tempSubscription.Send_Notification_Email__c = true;
	            tempSubscription.Activation_Date__c = system.now();
	            tempSubscription.Subscription_Status__c = SUBSCRIPTION_ACTIVE;
	            
	            SubscriptionsAdd.put(wrapper.EligibleSubscriptionId, tempSubscription);
	        }
        }*/
        
        // submit the subscription
        SubmitSubscriptions();
    }
    
    /**
     * @description:	used on the AdvAdmin_ManageSubscriptions sites page
     * 
     **/
    public void ToggleTempSubscription() {
        
        //Commented By - Neha Sharma - 05/19/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        /*SiteSubscriptionHelper.SubscriptionWrapper subWrapper = SubscriptionWrapperMap.get(TempSubscriptionId);
        
        // see if the subscription already exists in one of our lists -- if so, remove it and add it to the most recent list
        Subscription__c sub = SubscriptionsAdd.get(TempSubscriptionId);
        
        if (sub != null)
            SubscriptionsAdd.remove(TempSubscriptionId);
        
        sub = SubscriptionsRemove.get(TempSubscriptionId);
        
        if (sub != null)
            SubscriptionsRemove.remove(TempSubscriptionId);
        
        // if there is already an active subscription for this contact associated with this esoId, return immediately
        // this is used to avoid dupes (part of CR-3226)
        if (TempSubscriptionCreate) {
            Set<Id> esoIdSet = new Set<Id>();
            
            for (Id esoId : subWrapper.EligibleSubscriptionIdList) {
                esoIdSet.add(esoId);
            }
            List<Subscription__c> existingActiveSubscriptions = [SELECT Id FROM Subscription__c
                                                                 WHERE Contact__c = :MainContact.Con.Id
                                                                 AND Subscription_ID__c = :esoIdSet AND Termination_Date__c = null];
            if (existingActiveSubscriptions.size() > 0) return;
        }
        
        // create the subscription and add it to either the add or remove list
        if (TempSubscriptionCreate) {
            for (Id esoId : subWrapper.EligibleSubscriptionIdList) {
                Subscription__c tempSubscription = new Subscription__c();
                tempSubscription.Contact__c = MainContact.Con.Id;
                tempSubscription.Subscription_ID__c = esoId;
                tempSubscription.Send_Notification_Email__c = true;
                tempSubscription.Activation_Date__c = system.now();
                tempSubscription.Subscription_Status__c = SUBSCRIPTION_ACTIVE;
                
                SubscriptionsAdd.put(esoId, tempSubscription);
            }
        }
        else {
            for (Id esoId : subWrapper.EligibleSubscriptionIdList) {
                Subscription__c tempSubscription = new Subscription__c();
                tempSubscription.Contact__c = MainContact.Con.Id;
                tempSubscription.Subscription_ID__c = esoId;
                SubscriptionsRemove.put(esoId, tempSubscription);
            }
        }*/
        
        // submit the subscription
        SubmitSubscriptions();
    }
    
    /**
     * @description:	list of temporary subscriptions
     * 
     **/
    //Commented By - Neha Sharma - 05/19/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
    /*public Map<Id, Subscription__c> SubscriptionsAdd {
        get {
            if (SubscriptionsAdd == null) {
                SubscriptionsAdd = new Map<Id, Subscription__c>();
            }
            return SubscriptionsAdd;
        }
        set;
    }*/
    
    /**
     * @description:	list of temporary subscriptions
     * 
     **/
    //Commented By - Neha Sharma - 05/19/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
    /*public Map<Id, Subscription__c> SubscriptionsRemove {
        get {
            if (SubscriptionsRemove == null) {
                SubscriptionsRemove = new Map<Id, Subscription__c>();
            }
            return SubscriptionsRemove;
        }
        set;
    }*/
    
    /**
     * @description:	
     * 
     **/
    // submit subscriptions
    public void SubmitSubscriptions() {

        //Commented By - Neha Sharma - 05/19/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        /*List<Subscription__c> subscriptionsToUpsert = new List<Subscription__c>();
        Set<Id> subscriptionsToAddIds = new Set<Id>();
        
        // insert them first because we only send emails on Subscription Upsert -- this is so we can put additions and removals in one email
        if (SubscriptionsAdd.size() > 0) {
            subscriptionsToUpsert.addAll(SubscriptionsAdd.values());
        }
        
        // get a list of subscriptions to remove
        Set<Id> subscriptionIdSet = new Set<Id>();
        for (Subscription__c sub : SubscriptionsRemove.values())
            subscriptionIdSet.add(sub.Subscription_Id__c);
        List<Subscription__c> subscriptionsToAddTerminationDate = [SELECT id, Termination_date__c FROM Subscription__c WHERE Contact__c = :MainContact.Con.Id AND Subscription_Id__c IN :subscriptionIdSet AND Termination_Date__c = null];
        
        // add a termination date
        for (Subscription__c sub : subscriptionsToAddTerminationDate) {
            sub.Send_Notification_Email__c = true;
            sub.Termination_Date__c = system.now();
            sub.Subscription_Status__c = UnsubscribeStatus;
            subscriptionsToUpsert.add(sub);
        }
        
        //subscriptionsToUpsert.addAll(SubscriptionsAdd.values());
        
        if (subscriptionsToUpsert.size() > 0) {
            try {
                upsert subscriptionsToUpsert;
            }
            catch(Exception ex) {
                SaveMessage = ex.getMessage();
                SaveSuccessful = false;
                return;
            }
        }*/
        
        SaveSuccessful = true;
        SaveMessage = 'Saved Successfully';
        
        // refresh the MainContact and associated records
        string queryString = SiteUserHelper.CONTACTBASEQUERY + ' WHERE Id = \'' + MainContact.Con.Id + '\'';
        System.debug('queryString->'+ queryString);
        System.debug('MainContact.Con.Id->'+ MainContact.Con.Id);
        Contact con = database.query(queryString);
        
        //Commented By - Neha Sharma - 05/19/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        // clear the SubscriptionsAdd list
        /*SubscriptionsAdd.clear();
        SubscriptionsRemove.clear();
        SubscriptionWrapperMap = null;*/
        MainContact = new SiteControllerHelper.ContactWrapper(con, true);
        
    }
    
    /**
     * @description:	
     * 
     **/
    public boolean isUpdate {
        get {
            if (isUpdate == null) {
                isUpdate = false;
            }
            return isUpdate;
        }
        set;
    }
    
    //Modified by Mahendra Swarnkar - 12/07/2016 - CR-20160328-9718 - to include Applicable_For__c in query
    /**
     * @description:SUNJ: CR-20130920-3674 - Twitter Feed edits on Subscription Page	
     * 
     **/
    public List<Advisory_Twitter_Feed__c> TwitterFeeds {
        get {
            if (TwitterFeeds == null) {
                TwitterFeeds  = database.query('SELECT Name, Twitter_Username__c, Applicable_For__c ' +
                                               'FROM Advisory_Twitter_Feed__c WHERE Active__c = true ORDER BY Position__c');
            }
            return TwitterFeeds;
        }
        set;
    }
    
    
    public map<string, string> categoryToDisplayName {
    	get {
    		if (categoryToDisplayName == null) {
    			categoryToDisplayName = new map<string, string>();
    			categoryToDisplayName.put('EMAIL_DAILY', 'News');
    			categoryToDisplayName.put('EMAIL_TOPICS', 'Topic Alerts');
    			categoryToDisplayName.put('EMAIL_WATCH', 'Product or Membership Email');
    			categoryToDisplayName.put('EMAIL_BLOG', 'Blog Alerts');
    		}
    		return categoryToDisplayName;
    	}
    	set;
    }
    
    /**
     * @description:	determines if the current user is a guest or not.  If not, it means they are an internal SF user.
     * 
     **/
    public boolean isGuestUser {
        get {
            if (isGuestUser == null) {
                isGuestUser = SiteControllerHelper.IsGuestUser;
            }
            return isGuestUser;
        }
        set;
    }
    
    /**
     * @description:	
     * 
     **/
    public integer countAdvisorySubscriptions {
        get {
            //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
            //if (countAdvisorySubscriptions == null) countAdvisorySubscriptions = mainContact.mapTypeToSubscriptionList_Advisory.size();
            return countAdvisorySubscriptions;
        }
        set;
    }
    
    /**
     * @description:	
     * 
     **/
    public integer countEABSubscriptions {
        get {
            //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
            //if (countEABSubscriptions == null) countEABSubscriptions = mainContact.mapTypeToSubscriptionList_EAB.size();
            return countEABSubscriptions;
        }
        set;
    }
	
}