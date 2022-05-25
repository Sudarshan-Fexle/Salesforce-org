/**
Desription      :   Helper class for the SiteProfile trigger

Created By      :   Victor Hanson

Created Date    :   08/01/2014

Revision Logs   :  v1 - Created
                :  v1.1 - Modified By - Ajit Surana - 02/05/2015 - CR-20141016-7784
                :  v1.2 - Modified By - Ajit Surana - 04-29-2015 - CR-20150415-8874
                :  v1.3 - Modified By - Mark Szurlej - 08-18-2015 - CR-20150414-8873
                :  v1.4 - Modified By - Abhinav Sharma - 11/27/2015 - CR-20151118-9393
                :  v1.5 - Modified By - Mahendra Swarnkar - CR-20160926-10189 - 12/8/2016 - Created a new Method "autoGenerateSubscriptionsOnAutoSubscribeAll"
                :  v1.6 - Modified By - Abhinav Sharma - CR-20151216-9463 - 12/15/2016 = Created a new method "siteProfileDuplicatePreventer"
                :  v1.7 - Modified By - Abhinav Sharma - CR-20160505-9833 - 01/21/2017 - Added Account.Contribution_Category__c to the query
                :  v1.8 - Modified By - Mahendra Swarnkar - CR-20170414-10851 - 04/17/2017 - Modified the method "siteProfileDuplicatePreventer"
                :  v1.9 - Modified By - Abhinav Sharma - 06/25/2018 - CR-20180605-12266 - Replace Con.Email with con.Company_Email__c
        	:  v2.0 - Merged By   - Rajeev Jain - CR-20180605-12266 - 08/31/2018
                :  v2.1 - Modified By - Victor Hanson - 05/28/2019 - CR-20190520-13117 - remove orgStatus check on createSiteProfile()
		:  v2.2 - Modified By - Neha Sharma - CR-20210113-14802 - 1/17/2021
**/ 
public class SiteProfileTriggerHelper {
    
    /** Constants **/
    public final static string NOTIFICATION_TYPE_NEW_USER = 'New User';
    public final static string NOTIFICATION_TYPE_EMAIL_CHANGE = 'Email Change';
    public final static string NOTIFICATION_TYPE_PASSWORD_RESET = 'Password Reset';
    public final static string SITE_PROFILE_STATUS_ACTIVE = 'Active';
    public final static string SITE_PROFILE_STATUS_IN_PROGRESS = 'In Progress';
    public final static string SITE_PROFILE_STATUS_INACTIVE = 'Inactive';
    public final static string SITE_PROFILE_STATUS_HARD_BOUNCE = 'Hard Bounce';
    public final static string ERROR_INVALID_DOMAIN = 'Domain is not eligible for this Site Profile.';
    public final static string SITE_PROFILE_RT_ID_MYROYALL = Schema.SObjectType.Site_Profile__c.getRecordTypeInfosByName().get('MyRoyall').getRecordTypeId();
    public final static string SITE_PROFILE_OBJECT_API_NAME = 'Site_Profile__c';
    
    /**
     * @description:    cache a map of Id to Contacts related to Site Profiles
     * 
     **/
    public static map<Id, Contact> mapSPContacts { get; set; }
    public static map<Id, Contact> getMapSPContacts(list<Site_Profile__c> sProfiles) {
        if (mapSPContacts == null) {
            //get contacts and set verification status
            set<Id> contactIds = new set<Id>();
            for (Site_Profile__c sp : sProfiles) {
                contactIds.add(sp.Contact__c);
            }
            //Modified By Abhinav Sharma - 06/25/2018 - CR-20180605-12266 - Added Company_Email__c in the Query.
            mapSPContacts = new map<Id, Contact>([SELECT Id, Company_Email__c, Email, Contact_Status__c, AccountId, Site_User__c, Bypass_Domain_Validation__c,
                                                  (SELECT Id, Name, Username__c, Status__c, Bypass_Domain_Validation__c, Organization_Status__c, Verify__c, Type__c 
                                                   FROM Site_Profiles__r WHERE Id NOT IN :sProfiles) 
                                                  FROM Contact WHERE Id IN :contactIds]);
        }
        return mapSPContacts;
    }
    
    /**
     * @description:    variable that allows us to bypass the SiteProfile trigger
     * 
     **/
    public static boolean bypassSiteProfileTrigger {
        get {
            if (bypassSiteProfileTrigger == null) bypassSiteProfileTrigger = false;
            return bypassSiteProfileTrigger;
        }
        set;
    }
    
    //
    /**
     * @description:    executes whenever a site profile is created internally.  Checks to see if the domain is valid for the username specified.
     *
     * @revision log:   Modified - 05/28/2019 - Victor Hanson - CR-20190520-13117 - remove orgStatus check
    **/
    public static void createSiteProfile(list<Site_Profile__c> newListSiteProfiles) {
        
        //list of site users to insert
        list<Site_User__c> siteUsers = new list<Site_User__c>();
        
        //list of contacts to update
        map<Id, Contact> mapContactsToUpdate = new map<Id, Contact>();
        
        //get the account w/eligible domains
        set<Id> accountIds = new set<Id>();
        
        //get related contact ids
        set<Id> contactIdSet = new set<Id>();
        for (Site_Profile__c sProfile : newListSiteProfiles) {
            contactIdSet.add(sProfile.Contact__c);
            if (sProfile.r_Institution__c != null) accountIds.add(sProfile.r_Institution__c);
        }
        
        //get the contact including all related site profiles
        map<Id, Contact> contacts =  new map<Id, Contact>((List<Contact>)database.query(SiteUserHelper.CONTACTBASEQUERY + ' WHERE  Id IN :contactIdSet'));
        
        
        for (Contact c : contacts.values()) accountIds.add(c.AccountId);
        map<Id, Account> accountMap = getAccountsWithEligibleDomains(accountIds);
        
        //loop through each profile, pull the contact, and determine if they are eligible
        for (Site_Profile__c sProfile : newListSiteProfiles) {
            
            //get the related contact w/site profiles
            Contact c = contacts.get(sProfile.Contact__c);
            
            //vh 6/23/16: set the account based on the contact, unless the SP (royall) institution lookup is populated
            Account a = accountMap.get(c.AccountId);
            if (sProfile.r_Institution__c != null) a = accountMap.get(sProfile.r_Institution__c);
            
            //verify the contact isn't already associated with a Site Profile of the same type
            for (Site_Profile__c existingSiteProfile : c.Site_Profiles__r) {
                if (existingSiteProfile.Type__c == sProfile.Type__c && sProfile.RecordTypeId != SITE_PROFILE_RT_ID_MYROYALL) 
                    sProfile.addError(SiteUserHelper.ERROR_DUPLICATE_SITE_PROFILE_TYPE, false);
            }
            
            //get the organization status
            string orgStatus;
            if(a != null) {
                if (sProfile.Type__c.equalsIgnoreCase(SiteUserHelper.SITE_ADVISORY)) {
                    if (a.Advisory_com_Organization_Status__c != null) {
                        orgStatus = a.Advisory_com_Organization_Status__c;
                    }
                }
                else if (sProfile.Type__c.equalsIgnoreCase(SiteUserHelper.SITE_EAB)) {
                    if (a.EAB_com_Organization_Status__c != null) {
                        orgStatus = a.EAB_com_Organization_Status__c;
                    }
                }    
            }
            
            //vh 05/28/2019 - CR-20190520-13117: Commented out below to allow the creation of Site Profiles on Instiuttions without active memberships
            //vh 6/23/16: bypass this validation for MyRoyall record type
            //if the organization status != active, return an error
            /*if ((orgStatus == null || !orgStatus.equalsIgnoreCase('Active')) && sProfile.RecordTypeId != SITE_PROFILE_RT_ID_MYROYALL) {
                sProfile.addError(Label.Site_Profile_Organization_Status_Not_Active);
            }*/
            
            SiteUser sUser = new SiteUser();
            sUser.Email_Address = sProfile.Username__c;
            sUser.site_Profile = sProfile;
            sUser.Site = sProfile.Type__c;
            
            //only set status to in progress if the status is null            
            if (sProfile.Password__c != null
                && sProfile.Status__c == null && sProfile.RecordTypeId != SITE_PROFILE_RT_ID_MYROYALL) 
            {
                sProfile.Status__c = SITE_PROFILE_STATUS_IN_PROGRESS;
            }
            
            sUser = SiteUserHelper.getSiteUser(c, sUser, false, false);
            
            //check domain eligibility
            boolean isEligible = SiteUserHelper.hasEligibleDomain(a, sUser);
            if (!isEligible) {
                sProfile.addError('The email address provided does not contain a valid domain for that institution.');
            }
            
            //if the domain is eligible, check to see if there is already a Site Profile -- if not, create one
            if (c.Site_User__c == null) {
                Site_User__c siteUser = SiteUserHelper.createNewSite_User(true);
                
                //set the new site user id on the contact and site profile
                c.Site_User__c = siteUser.Id;
                sProfile.Site_User__c = siteUser.Id;
                
            } else {
                sProfile.Site_User__c = c.Site_User__c;
            }
            
            //vh 6/23/16: bypass default settings if this is a myRoyall Site Profile
            if (sProfile.RecordTypeId != SITE_PROFILE_RT_ID_MYROYALL) {
                // set some default values on the contact
                c = SiteUserHelper.UpdateDefaultUserSettings(c, sUser);
                //get the updated status code
                SiteUserHelper.getStatusCode(sUser);
            }
            
            if (!mapContactsToUpdate.containsKey(c.Id))
                mapContactsToUpdate.put(c.Id, c);
        }
        
        
        if (mapContactsToUpdate.size() > 0) {
            Util.BypassAllTriggers = true;
            update mapContactsToUpdate.values();
            Util.BypassAllTriggers = false;
        }
    }
    
    @future
    public static void sendVerificationEmail(set<Id> siteProfileIds) {
        
        if(siteProfileIds != null && siteProfileIds.size() > 0){
            
            list<Site_Profile__c> sProfiles = [SELECT Id, Password__c, Username__c, User_Id__c, Type__c, Status__c, User_Id_Override__c FROM Site_Profile__c WHERE Id IN :siteProfileIds];
            
            if(sProfiles != null && sProfiles.size() > 0){  
                //if the site profile's password is set and status is active, don't reset their password as part of the initial insert in to the system.
                for (integer i = 0; i < sProfiles.size(); i++) {
                    if (sProfiles[i].Password__c != null
                        && sProfiles[i].Status__c != null
                        //&& sProfiles[i].Status__c.equalsIgnoreCase(SiteProfileTriggerHelper.SITE_PROFILE_STATUS_ACTIVE)
                       ) 
                    {
                        sProfiles.remove(i);
                    }
                }
            }
            
            if (sProfiles.size() > 0)
                sendVerificationEmail(sProfiles, NOTIFICATION_TYPE_NEW_USER, true);
        }
    }
    
    /**
     * @description:    Send verification email to the Site Profile email address when a new Site Profile is created.
     * 
     * @params:         Valid notification types: 'New User', 'Email Change', 'Password Reset'
     */
    public static void sendVerificationEmail(list<Site_Profile__c> newListSiteProfiles, string notificationType, boolean updateSiteProfile) {
        
        //Check for null
        if(newListSiteProfiles != null && newListSiteProfiles.size() > 0){
            
           for (Site_Profile__c sProfile : newListSiteProfiles) {
            
            SiteUser sUser = new SiteUser();
            sUser.Site = sProfile.Type__c;
            sUser.Email_Address = sProfile.Username__c;
            // set the password reset URL
            string pwResetURL = SiteUserHelper.createPWResetURL(sUser, string.valueOf(sProfile.User_Id__c));
            sProfile.Send_Password_Notification__c = notificationType;
            sProfile.Password_Reset_Token__c = pwResetURL;
        }
        
        if (updateSiteProfile) 
            update newListSiteProfiles;
        }
    }
    
    
    // get the associated Account record
    public static map<Id, Account> getAccountsWithEligibleDomains(set<Id> acctIdSet) {
        return new map<Id, Account>([SELECT Name, Id, Organization_Id__c, Advisory_com_Organization_Status__c, EAB_com_Organization_Status__c,
                                    (Select Id, Qualified_Domain__c, Is_Included__c FROM Eligible_Domains__r WHERE Is_Included__c = true)
                                    FROM Account WHERE Id IN :acctIdSet]);
    }
    
    /**
     * 
     * @description: Added By - Abhinav Sharma - 07/27/2015 - CR-20150629-9034
     *          Populate the Site Profile Created By field
     * 
     **/
    public static void updateSiteProfileCreatedBy(list<Site_Profile__c> newListSiteProfiles) {
        
        for (Site_Profile__c sProfile : newListSiteProfiles) {
            if (SiteControllerHelper.IsGuestUser)
                sProfile.Site_Profile_Created_By__c = sProfile.Username__c;
            else
                sProfile.Site_Profile_Created_By__c = UserInfo.getName();
        }
    }
    
    /**
     * @description: check for duplicate site profiles with the same username and type.
     * 
     **/
    public static void siteProfileDupeCheck(list<Site_Profile__c> newListSiteProfiles) {
        //get related contact ids
        set<string> sProfileUsernames = new set<string>();
        set<Id> sProfileIds = new set<Id>();
        for (Site_Profile__c sProfile : newListSiteProfiles) {
            sProfileUsernames.add(sProfile.Username__c);
            sProfileIds.add(sProfile.Id);
        }
        
        //create a map of [Username]+[Type], [SiteProfile] (ie: tUser1@abington.orgAdvisory.com, [Site Profile])
        map<string, Site_Profile__c> emailToSiteProfile = new map<string, Site_Profile__c>();
        //get the profiles with that username. check the username for null to restrict results and prevent query exceptions
        list<Site_Profile__c> siteProfiles = [SELECT Id, RecordTypeId, Name, Username__c, Type__c, Contact__c, Contact__r.Name FROM Site_Profile__c WHERE Username__c != null AND Username__c IN :sProfileUsernames AND Id NOT IN :sProfileIds];
        for (Site_Profile__c sp : siteProfiles) {
            emailToSiteProfile.put(sp.Username__c + sp.Type__c, sp);
        }
        
        for (Site_Profile__c sProfile : newListSiteProfiles) {
            //check for existing site profile with the same username + type
            Site_Profile__c duplicateSiteProfile = emailToSiteProfile.get(sProfile.Username__c+sProfile.Type__c);
            if (duplicateSiteProfile != null && duplicateSiteProfile.RecordTypeId != SITE_PROFILE_RT_ID_MYROYALL) {
                sProfile.addError(SiteUserHelper.ERROR_DUPLICATE_SITE_PROFILE(duplicateSiteProfile), false);
            }
        }
    }
    
    public static boolean hasSynchronizedSiteProfile {
        get {
            if (hasSynchronizedSiteProfile == null) hasSynchronizedSiteProfile = false;
            return hasSynchronizedSiteProfile;
        }
        set;
    }
    
    /**
     * @description:    synchronize differences from the contact to the site profile
     *                  (ie: Bypass domain flag on Contact is checked, make sure the new site profile also gets the bypass domain flag checked)
     * 
     **/
    public static void synchronizeContactWithSiteProfile(list<Site_Profile__c> newListSiteProfiles, map<Id, Site_Profile__c> oldMapSiteProfiles) {
        
        //get contact map
        map<Id, Contact> mapContacts = getMapSPContacts(newListSiteProfiles);
        
        for (Site_Profile__c sp : newListSiteProfiles) {
            //get the old site profile if present
            Site_Profile__c oldSP;
            if (oldMapSiteProfiles != null) oldSP = oldMapSiteProfiles.get(sp.Id);
            //get the related contact
            Contact c = mapContacts.get(sp.Contact__c);
            
            if (oldSP == null 
                && c.Bypass_Domain_Validation__c == true 
                && sp.Bypass_Domain_Validation__c == false) 
            {
                sp.Bypass_Domain_Validation__c = c.Bypass_Domain_Validation__c;
            }
        }
    }
    
    /**
     * @description:    synchronize any username updates back to the Contact and to all related Site Profiles.
     *                  Also, if the bypass domain validation flag is unchecked, check domain eligibility.
     * 
     **/
    public static void synchronizeSiteProfileWithContact(list<Site_Profile__c> newListSiteProfiles, map<Id, Site_Profile__c> oldMapSiteProfiles) {
        system.debug('@@@@@synchronizeSiteProfileWithContact.hasSynchronizedSiteProfile:' + hasSynchronizedSiteProfile);
        if (hasSynchronizedSiteProfile) return;
        hasSynchronizedSiteProfile = true;
        
        //get contact map
        map<Id, Contact> mapContacts = getMapSPContacts(newListSiteProfiles);
        
	// Modified By - Neha Sharma - CR-20210113-14802 - 1/17/2021
        //set of all site profile ids that have a new email
        list<Site_Profile__c> sProfilesNeedSync = new list<Site_Profile__c>();
        list<Site_Profile__c> relatedSiteProfilesToUpdate = new list<Site_Profile__c>();
        map<Id, Contact> contactsToUpdate = new map<Id, Contact>();
        Set<Id> setOfContactIds = new Set<Id>();
        
        for (Site_Profile__c sp : newListSiteProfiles) {
            Contact c = mapContacts.get(sp.Contact__c);
            Site_Profile__c oldSP;
            if (oldMapSiteProfiles != null) oldSP = oldMapSiteProfiles.get(sp.Id);
            
            //Modified By Abhinav Sharma - 06/25/2018 - CR-20180605-12266 - Replace Con.Email with con.Company_Email__c
            //verify the username matches the Contact's Email Address
            if ((oldSP == null && sp.Username__c != c.Company_Email__c) ||
                (oldSP != null && oldSP.Username__c != sp.Username__c) && sp.Username__c != c.Company_Email__c) {
                sp.addError('Username must match the Contact\'s Company Email address.');
            }
            
            //scenarios that will trigger the SiteProfile to sync with the contact:
            //1. Bypass domain validation flag is set from True to False
            //2. Status is changed from Hard Bounce to In Progress
            //3. Type = Advisory.com and Status id changed
            if ((oldSP == null && sp.Bypass_Domain_Validation__c == true) 
                || (oldSP != null 
                    && (oldSP.Bypass_Domain_Validation__c != sp.Bypass_Domain_Validation__c
                        || oldSP.Status__c == SiteProfileTriggerHelper.SITE_PROFILE_STATUS_HARD_BOUNCE && sp.Status__c == SiteProfileTriggerHelper.SITE_PROFILE_STATUS_IN_PROGRESS)
                   )
                || (oldSP != null && sp.Type__c == SiteUserHelper.SITE_ADVISORY && oldSP.Status__c != sp.Status__c)
               )
            {
                sProfilesNeedSync.add(sp);
                setOfContactIds.add(sp.Contact__r.Id);
            }
        }
        system.debug('@@sProfilesNeedSync:' + sProfilesNeedSync);
        
        Map<Id,Contact> mapOfContactfromSP = new map<Id,Contact>();
        for(Contact con : [Select Id,AccountId,Account.EAB_com_Organization_Status__c,Company_Email__c,Contact_Status__c From Contact where Id IN: setOfContactIds]){
            mapOfContactfromSP.put(con.Id,con);
        }
        
        if (sProfilesNeedSync.size() > 0) {
            
            for (Site_Profile__c sp : sProfilesNeedSync) {
                
                Site_Profile__c oldSP;
                if (oldMapSiteProfiles != null) oldSP = oldMapSiteProfiles.get(sp.Id);
                
                //get the related contact and set the verification status
                Contact c = mapContacts.get(sp.Contact__c);
                
                //Modified By Abhinav Sharma - 06/25/2018 - CR-20180605-12266 - Replace Con.Email with con.Company_Email__c
                //make the contact's bypass flag = true if the site profile's flag is set to true
                //check to see if the Site Profile Username is different than the Contact Email
                if (sp.Username__c != c.Company_Email__c
                   || sp.Bypass_Domain_Validation__c != c.Bypass_Domain_Validation__c
                   || (oldSP != null && oldSP.Status__c != sp.Status__c)) 
                {
                    c.Bypass_Domain_Validation__c = sp.Bypass_Domain_Validation__c;
                    //c.Advisory_com_User_Status__c = sp.Status__c;
                    contactsToUpdate.put(c.Id, c);
                }
                
                string errMsg;
                
                //update any related site profiles that also need their username or bypass flag updated
                if (c.Site_Profiles__r != null) {
                    for (Site_Profile__c rsp : c.Site_Profiles__r) {
                        if (rsp.Username__c != sp.Username__c || rsp.Bypass_Domain_Validation__c != sp.Bypass_Domain_Validation__c) {
                            
                            if(rsp.Username__c != sp.Username__c) {
                                //update username & set verification status
                                rsp.Username__c = sp.Username__c;
                                if(mapOfContactfromSP.containskey(c.Id))
                                	rsp = SiteUserHelper.setVerificationStatus(mapOfContactfromSP.get(c.Id), rsp);
                            }
                            
                            if(rsp.Bypass_Domain_Validation__c != sp.Bypass_Domain_Validation__c) 
                                rsp.Bypass_Domain_Validation__c = sp.Bypass_Domain_Validation__c;
                            
                            
                            
                            relatedSiteProfilesToUpdate.add(rsp);
                        }
                    }
                }
                
                //if the username or status changes from hard bounce to in progress, set verification status and send reset pw email.
                if (oldSP != null 
                    && (oldSP.Username__c != sp.Username__c
                        || (oldSP.Status__c == SiteProfileTriggerHelper.SITE_PROFILE_STATUS_HARD_BOUNCE && sp.Status__c == SiteProfileTriggerHelper.SITE_PROFILE_STATUS_IN_PROGRESS)
                       )
                   )
                {
                    //set verification status
                    sp = SiteUserHelper.setVerificationStatus(c, sp);
                    string notificationType = NOTIFICATION_TYPE_EMAIL_CHANGE;
                    
                    //if the status was updated but the username was not, send the password reset email
                    if(oldSP.Status__c == SiteProfileTriggerHelper.SITE_PROFILE_STATUS_HARD_BOUNCE && sp.Status__c == SiteProfileTriggerHelper.SITE_PROFILE_STATUS_IN_PROGRESS
                        && oldSP.Username__c == sp.Username__c) 
                    {
                        notificationType = NOTIFICATION_TYPE_PASSWORD_RESET;
                    }
                    
                    //send password reset email to the site profile(s) affected by the trigger
                    sendVerificationEmail(sProfilesNeedSync, notificationType, false);
                    
                    //send pw reset email to the other site profiles related to the contact
                    sendVerificationEmail(relatedSiteProfilesToUpdate, notificationType, false);
                }
            }
            
            
            //update the related site profiles that also need their username(s) updated
            if (relatedSiteProfilesToUpdate.size() > 0) {
                util.BypassAllTriggers = true;
                update relatedSiteProfilesToUpdate;
                util.BypassAllTriggers = false;
            }
            
            if (contactsToUpdate.size() > 0 && !SiteUserHelper.IsTriggerContact) {
                util.BypassAllTriggers = true;
                update contactsToUpdate.values();
                util.BypassAllTriggers = false;
            }
        }
    }
    
    //Modified By Abhinav Sharma - 06/25/2018 - CR-20180605-12266 - Added Company_Email__c to the Query. 
    //Modified By - Abhinav Sharma - 11/27/2015 - CR-20151118-9393 - Updated contact query to include additional fields
    //Modified By - Ajit Surana - 02/05/2015 - CR-20141016-7784 - Updated Contact query
    /**
     * @description:    validate that the email contains a valid domain unless bypass domain validation is checked.
     *
     *
     **/
    public static void validateEligibleDomain(list<Site_Profile__c> newListSiteProfiles, map<Id, Site_Profile__c> oldMapSiteProfiles) {
        //set of all site profile ids that have a new email
        list<Site_Profile__c> sProfilesNeedValidated = new list<Site_Profile__c>();
        set<id> siteProfileIdSet = new set<Id>();
        
        for (Site_Profile__c sp : newListSiteProfiles) {
            Site_Profile__c oldSP;
            if (oldMapSiteProfiles != null) oldSP = oldMapSiteProfiles.get(sp.Id);
            
            siteProfileIdSet.add(sp.Id);
            
            //scenarios that will trigger the site profile to be validated:
            //1. Username has changed
            //2. Bypass domain validation flag is changed
            //3. Status is changed from Hard Bounce to In Progress
            //4. User resets password
            if ((oldSP == null && sp.Bypass_Domain_Validation__c == true) 
                || (oldSP != null 
                    && (oldSP.Username__c != sp.Username__c
                        || (oldSP.Bypass_Domain_Validation__c != sp.Bypass_Domain_Validation__c)
                        || (oldSP.Status__c == SiteProfileTriggerHelper.SITE_PROFILE_STATUS_HARD_BOUNCE && sp.Status__c == SiteProfileTriggerHelper.SITE_PROFILE_STATUS_IN_PROGRESS)
                        || (oldSP.Send_Password_Notification__c == null && sp.Send_Password_Notification__c != null))
                   )
               )
            {
                sProfilesNeedValidated.add(sp);
            }
        }
        system.debug('@@sProfilesNeedValidated:' + sProfilesNeedValidated);
        
        //set of contact ids
        set<Id> contactIds = new set<Id>();
        if (sProfilesNeedValidated.size() > 0) {
            //get accounts with eligible domains
            set<Id> accountIds = new set<Id>();
            
            for (Site_Profile__c sp : sProfilesNeedValidated) {
                contactIds.add(sp.Contact__c);
                if (sp.r_Institution__c != null) accountIds.add(sp.r_Institution__c);
            }
            
            //Modified By Abhinav Sharma - 06/25/2018 - CR-20180605-12266 - Added Company_Email__c in the Query. 
            //Modified By - Abhinav Sharma - 01-21-2017 - CR-20160505-9833 - Added Account.Contribution_Category__c to the query
            //Modified By - Ajit Surana - 04-29-2015 - CR-20150415-8874 - Added Account.Strategic_Account_Segment__c to the query
            //get contacts and set verification status
            /*map<Id, Contact> mapContacts = new map<Id, Contact>([SELECT Id, Email, Company_Email__c, Contact_Status__c, AccountId, Account.Name, Account.Organization_Id__c, Site_User__c, Account.Contribution_Category__c,
                                                                 Account.Status__c, Account.RecordType.Name, Account.Account_Formal_Name__c, 
                                                                 EAB_Department__c, EAB_Role__c,
                                                                 Account.EAB_com_Organization_Status__c, Bypass_Domain_Validation__c, Account.Advisory_com_Organization_Status__c, Account.Strategic_Account_Segment__c,
                                                                 Account.Provider_Type__c, Account.Bed_Size__c, Account.Principal__c,
                                                                 FirstName,
                                                                 (SELECT Id, Name, Username__c, Status__c, Bypass_Domain_Validation__c, Last_Access__c, Verify_Date__c, 
                                                                  Organization_Status__c, Verify__c, Password__c, Type__c, User_Id__c 
                                                                  FROM Site_Profiles__r WHERE Id NOT IN :siteProfileIdSet) 
                                                                 FROM Contact WHERE Id IN :contactIds]);*/
            //VH 05/17/2019: converted to use the existing contactBaseQuery string so we don't have to update the query every time a field is added
            map<Id, Contact> mapContacts = new map<Id, Contact>((List<Contact>)database.query(SiteUserHelper.CONTACTBASEQUERY + ' WHERE Id IN :contactIds'));
            
            for (Contact c : mapContacts.values()) accountIds.add(c.AccountId);
            map<Id, Account> accountMap = getAccountsWithEligibleDomains(accountIds);
            for (Site_Profile__c sp : sProfilesNeedValidated) {
                
                Site_Profile__c oldSP;
                if (oldMapSiteProfiles != null) oldSP = oldMapSiteProfiles.get(sp.Id);
                
                //get the related contact and set the verification status
                Contact c = mapContacts.get(sp.Contact__c);
                
                //vh 6/23/16: set the account based on the contact, unless the SP (royall) institution lookup is populated
                Account acct = accountMap.get(c.AccountId);
                if (sp.r_Institution__c != null) acct = accountMap.get(sp.r_Institution__c);
                
                string errMsg;
                
                //update any related site profiles that also need their username updated
                if (c.Site_Profiles__r != null) {
                    for (Site_Profile__c rsp : c.Site_Profiles__r) {
                        if (rsp.Username__c != sp.Username__c && !siteProfileIdSet.contains(rsp.Id) ) {
                            rsp.Username__c = sp.Username__c;
                            rsp.Bypass_Domain_Validation__c = sp.Bypass_Domain_Validation__c;
                            
                            //get the site user so we can validate the domain
                            SiteUser relatedSiteUser = SiteUserHelper.getSiteUser(c, rsp);
                            
                            if (!SiteUserHelper.hasEligibleDomain(acct, relatedSiteUser)) {
                                errMsg = 'Domain is not eligible for Site Profile <a href="/' + rsp.Id + '">' + rsp.Name + '</a>';
                            }
                        }
                    }
                }
                
                //get the site user so we can validate the domain
                SiteUser sUser = SiteUserHelper.getSiteUser(c, sp);
                
                if (!SiteUserHelper.hasEligibleDomain(acct, sUser))
                    errMsg = ERROR_INVALID_DOMAIN;
                
                //if there was an error, add it to the record and return immediately
                if (errMsg != null) {
                    sp.addError(errMsg, false);
                    return;
                }
            }
        }
        
        //null the contact map so it will pull a fresh list of contacts during the next trigger run (used for unit tests)
        mapSPContacts = null;
    }
    
    /**
     * @description: 	updates the site profile count
     * 
     * @revisions: 		07/23/2019 - CR-20190627-13200 - Victor Hanson - Modified so it only updates Contact when necessary
     * 
     **/
    public static void updateSiteProfileCount(list<Site_Profile__c> newListSiteProfiles, map<Id, Site_Profile__c> oldMapSiteProfiles) {
        //set of contact ids
        set<Id> contactIds = new set<Id>();
        list<Contact> contactsToUpdate = new list<Contact>();
        
        //figure out which list of site profiles we should use for counting site profiles on contact
        list<Site_Profile__c> siteProfiles = newListSiteProfiles;
        if (trigger.isDelete) siteProfiles = oldMapSiteProfiles.values();
        
        for (Site_Profile__c sp : siteProfiles) contactIds.add(sp.Contact__c);
        
        //get all site profiles by contact
        List<Contact> contacts = [SELECT Id, EAB_com_Site_Profile_Count__c, Royall_com_Site_Profile_Count__c, (SELECT Id, Type__c, Contact__c FROM Site_Profiles__r) FROM Contact WHERE Id IN :contactIds];
        
        for (Contact c : contacts)  {
            //reset counts to zero
            integer count_EAB = 0;
            integer count_Royall = 0;
            
            for(Site_Profile__c sp : c.Site_Profiles__r) {
                
                if (sp.Type__c == SiteUserHelper.SITE_EAB) count_EAB++;
                else if (sp.Type__c == SiteUserHelper.SITE_ROYALL) count_Royall++;
            }
            
            //07/23/2019 - CR-20190627-13200 - Victor Hanson - added the if statements below so it only updates Contact when necessary
            if (count_EAB == 0) count_EAB = null;
            if (count_Royall == 0) count_Royall = null;
            if (c.EAB_com_Site_Profile_Count__c != count_EAB || c.Royall_com_Site_Profile_Count__c != count_Royall) {
                contactsToUpdate.add(c);
                
                if (c.EAB_com_Site_Profile_Count__c != count_EAB) {
                    if (count_EAB > 0) c.EAB_com_Site_Profile_Count__c = count_EAB;
                    else c.EAB_com_Site_Profile_Count__c = null;
                }
                
                if (c.Royall_com_Site_Profile_Count__c != count_Royall) {
                    if (count_Royall > 0) c.Royall_com_Site_Profile_Count__c = count_Royall;
                    else c.Royall_com_Site_Profile_Count__c = null;
                }
            }
        }
        
        if (contactsToUpdate.size() > 0 && !SiteUserHelper.IsTriggerContact) {
            util.BypassAllTriggers = true;
            update contactsToUpdate;
            util.BypassAllTriggers = false;
        }
    }
    
    //v1.8 - Modified By - MAhendra Swarnkar - CR-20170414-10851 - 04/17/2017 - Modified the method "siteProfileDuplicatePreventer" 
    //- So that it can check for duplicacy when Status__c is blank or null. rule will fire for My Royalls
    //Added by Abhinav Sharma - CR-20151216-9463 - 12/15/2016
    /**
     *  @description    :   This method will ensure the uniqueness for the site profile record with respect to
     *                      following criteria:-
     *                      Scenario 1: Advisory.com / EAB.com site profiles
     *                          When RecordType = "EAB and Advisory", the combination of (Username__c & Type__c) must be unique
     *                      Scenario 2: MyRoyall site profiles
     *                          When RecordType = "MyRoyall", the combination of (Username__c + Type__c + r_Institution__c) must be unique  
     * 
     *  @args           :   List of Site Profiles, old map of Site Profiles
     * 
     *  @return         :   none
     * 
    **/
    public static void siteProfileDuplicatePreventer(List<Site_Profile__c> newSiteProfiles, Map<Id, Site_Profile__c> mapOldSiteProfiles) {
        
        //EAB and Advisory Record Type ID
        Id eABAndAdvidoryRdTypeId = Util.RecordTypeId(SiteProfileTriggerHelper.SITE_PROFILE_OBJECT_API_NAME, System.Label.EAB_AND_ADVISORY_RECORD_TYPE_LABEL);
       
        //MyRoyall Record Type ID
        Id royallRdTypeId = Util.RecordTypeId(SiteProfileTriggerHelper.SITE_PROFILE_OBJECT_API_NAME, System.Label.SITE_PROFILE_MYROYALL_RECORD_TYPE_LABEL);
        
        //Map of Site profiles
        Map<String, Site_Profile__c> mapOfSiteProfiles = new Map<String, Site_Profile__c>();
        
        //Set to hold the usernames
        Set<String> setOfUserNames = new Set<String>();
        
        //Set to hold the Types
        Set<String> setOfTypes = new Set<String>();
        
        //Map of Site profiles
        Map<String, Site_Profile__c> mapOfSiteProfilesForMyRoyall = new Map<String, Site_Profile__c>();
        
        //Set to hold the Institution
        Set<Id> setOfInstitutionIds = new Set<Id>();
        
        //Set to hold the site profiles Ids
        Set<Id> siteProfileIds = new Set<Id>();
        
        //Loop through site profile records
        for (Site_Profile__c sp : newSiteProfiles) {
        
            //Checking for the record type
            //Scenario 1: Advisory.com / EAB.com site profiles
            //When RecordType = "EAB and Advisory", the combination of (Username__c & Type__c) must be unique
            if(sp.RecordTypeId != null && sp.RecordTypeId == eABAndAdvidoryRdTypeId) {
                
                //Checking for key fields value
                if((sp.Username__c != null) 
                    && 
                    (sp.Type__c != null) 
                    && 
                    (sp.Status__c != null)
                    && 
                    (
                        (mapOldSiteProfiles == null)
                        ||
                        (
                            (
                                mapOldSiteProfiles != null 
                                &&
                                (
                                    (sp.Username__c != mapOldSiteProfiles.get(sp.Id).Username__c)
                                    ||
                                    (sp.Type__c != mapOldSiteProfiles.get(sp.Id).Type__c)
                                    ||
                                    (sp.Status__c != mapOldSiteProfiles.get(sp.Id).Status__c)
                                    ||
                                    (sp.Contact__c != mapOldSiteProfiles.get(sp.Id).Contact__c)
                                    ||
                                    (sp.Institution__c != mapOldSiteProfiles.get(sp.Id).Institution__c)
                                )
                            )        
                        )
                    )
                ) {
                    //Make sure another new scope isn't also a duplicate
                    if(mapOfSiteProfiles.containsKey(sp.Username__c.trim().toLowerCase() + '-' + sp.Type__c.trim().toLowerCase()))
                        sp.addError(System.Label.ERROR_ANOTHER_SITE_PROFILE_HAS_SAME_USERNAME_AND_TYPE);
                    else
                        mapOfSiteProfiles.put(sp.Username__c.trim().toLowerCase() + '-' + sp.Type__c.trim().toLowerCase(), sp);
                
                    //Populating collections
                    setOfUserNames.add(sp.Username__c);
                    setOfTypes.add(sp.Type__c);
                    siteProfileIds.add(sp.Id);
                }
            }
            
            //Scenario 2: MyRoyall site profiles
            //When RecordType = "MyRoyall", the combination of (Username__c + Type__c + r_Institution__c) must be unique  
            if(sp.RecordTypeId != null && sp.RecordTypeId == royallRdTypeId) {
                
                //Checking for key fields value
                if((sp.Username__c != null) 
                    && 
                    (sp.Type__c != null) 
                
                //v1.8 - Modified By - MAhendra Swarnkar - CR-20170414-10851 - 04/17/2017 - Commented the code - Starts from here
                /*
                    && 
                    (sp.Status__c != null)
        */
                //v1.8 - Modified By - MAhendra Swarnkar - CR-20170414-10851 - 04/17/2017 - Commented the code - Ends here
                
                    &&
                    (sp.r_Institution__c != null)
                    &&
                    (
                        (mapOldSiteProfiles == null)
                        ||
                        (
                            (
                                mapOldSiteProfiles != null 
                                &&
                                (
                                    (sp.Username__c != mapOldSiteProfiles.get(sp.Id).Username__c)
                                    ||
                                    (sp.Type__c != mapOldSiteProfiles.get(sp.Id).Type__c)
                      
                //v1.8 - Modified By - MAhendra Swarnkar - CR-20170414-10851 - 04/17/2017 - Commented the code - Starts from here
                        /*
                                    ||
                                    (sp.Status__c != mapOldSiteProfiles.get(sp.Id).Status__c)
                                //v1.8 - Modified By - MAhendra Swarnkar - CR-20170414-10851 - 04/17/2017 - Commented the code - Ends here
                        */
                  ||
                                    (sp.r_Institution__c != mapOldSiteProfiles.get(sp.Id).r_Institution__c)
                                    ||
                                    (sp.Contact__c != mapOldSiteProfiles.get(sp.Id).Contact__c)
                                )
                            )        
                        )
                    )
                ) {
                
                    //Make sure another new scope isn't also a duplicate
                    if(mapOfSiteProfilesForMyRoyall.containsKey(sp.Username__c.trim().toLowerCase() + '-' + sp.Type__c.trim().toLowerCase() + '-' + sp.r_Institution__c))
                        sp.addError(System.Label.ERROR_ANOTHER_SITE_PROFILE_HAS_SAME_USERNAME_AND_TYPE_AND_INSTITUTION);
                    else
                        mapOfSiteProfilesForMyRoyall.put(sp.Username__c.trim().toLowerCase() + '-' + sp.Type__c.trim().toLowerCase() + '-' + sp.r_Institution__c, sp);
                
                    //Populating collections
                    setOfUserNames.add(sp.Username__c);
                    setOfTypes.add(sp.Type__c);
                    setOfInstitutionIds.add(sp.r_Institution__c);
                    siteProfileIds.add(sp.Id);
                }
            }
        }
            
        //Checking collection for their size value
        if(setOfUserNames.size() > 0 && setOfTypes.size() > 0) {
            
            //v1.8 - Modified By - MAhendra Swarnkar - CR-20170414-10851 - 04/17/2017 - Removed the Status null/blank check from the query So that 
            //-it can also check duplicacy for those My Royall type records which are having status field value as blank/null. - Starts from here
            //Using a single database query, find all the site profile in 
            //the database that have the same username and key as any 
            //of the site profiles being inserted or updated. 
            for (Site_Profile__c s : [SELECT Type__c, Username__c, Status__c, ID, r_Institution__c, RecordTypeId 
                                        FROM Site_Profile__c 
                                        WHERE Username__c != null AND Username__c != '' 
                                        AND Type__c != null AND Type__c != ''
                                        //AND Status__c != null AND Status__c != ''
                                        AND Status__c !=: System.Label.SITE_PROFILE_INACTIVE_STATUS 
                                        AND Username__c IN : setOfUserNames
                                        AND Type__c IN : setOfTypes
                                       AND ID NOT IN : siteProfileIds]) {
                
                //Checking for key presence and for the correspodning value in the map
                //Accordingly adding error message on the record instance
                if(s.RecordTypeId != null && s.RecordTypeId == eABAndAdvidoryRdTypeId) {
                  if(mapOfSiteProfiles.containsKey(s.Username__c.trim().toLowerCase() + '-' + s.Type__c.trim().toLowerCase())
                      && mapOfSiteProfiles.get(s.Username__c.trim().toLowerCase() + '-' + s.Type__c.trim().toLowerCase()) != null 
                    ) {
                        Site_Profile__c newSiteProfile = mapOfSiteProfiles.get(s.Username__c.trim().toLowerCase() + '-' + s.Type__c.trim().toLowerCase());
                        if(newSiteProfile != null)
                            newSiteProfile.addError(System.Label.ERROR_A_SITE_PROFILE_WITH_SAME_USERNAME_AND_TYPE_ALREADY_EXIST);      
                    }
                }
                                            
                //Checking for key presence and for the correspodning value in the map
                //Accordingly adding error message on the record instance
                if(s.RecordTypeId != null && s.RecordTypeId == royallRdTypeId) {
                if(setOfInstitutionIds.contains(s.r_Institution__c)) {
                        if(mapOfSiteProfilesForMyRoyall.containsKey(s.Username__c.trim().toLowerCase() + '-' + s.Type__c.trim().toLowerCase() + '-' + s.r_Institution__c)
                            && mapOfSiteProfilesForMyRoyall.get(s.Username__c.trim().toLowerCase() + '-' + s.Type__c.trim().toLowerCase() + '-' + s.r_Institution__c) != null 
                        ) {
                            Site_Profile__c newSiteProfile1 = mapOfSiteProfilesForMyRoyall.get(s.Username__c.trim().toLowerCase() + '-' + s.Type__c.trim().toLowerCase() + '-' + s.r_Institution__c);
                            if(newSiteProfile1 != null)
                                newSiteProfile1.addError(System.Label.ERROR_A_SITE_PROFILE_WITH_SAME_USERNAME_TYPE_AND_INSTITUTION_ALREADY_EXIST);      
                        }                                    
                  }                                    
                }
            }        
        }
    }
    
    /**
     *  @description    :  Method used to populate the Entity field value
     *             Populate the Entity__c = HC on the associated parent "Site User"
     *             1) Type => 'EAB.com  then Entity => 'EAB'  
     *             2) Type => 'Advisory.com' then Entity => 'HC' 
     *             3) Type => 'EAB.com' and 'Royall.com' then Entity => 'All'   
     *
     *  @args           :  List of new Site_Profile__c records, Map of old Site_Profile__c records
     * 
     *  @return         :  void
     * 
     *   @Revision Log   :  V1.0 - Created By - Deepak Kumawat - 10/10/2017 - CR-20170927-11503 - Apollo Release
     **/
     public static void populateEntityFieldOnAssociatedSiteUser(List<Site_Profile__c> newSiteProfiles, Map<Id, Site_Profile__c> mapOldSiteProfiles) {
         
       //Set to hold the site user
        Set<Id> setSiteUserIds = new Set<Id>();
        
        //List to hold the site user records
        List<Site_User__c> listOfSiteUsers = new List<Site_User__c>(); 
         
        //Loop over the Site User
        for(Site_Profile__c siteProfile : newSiteProfiles) {
            
          //Populate the set of SiteUser
            setSiteUserIds.add(siteProfile.Site_User__c);
        }
         
        //Check for size
    if(setSiteUserIds.size() > 0) {
             
             //Call the validateEntityFieldsForSiteUserObjects, to populate the entity field value
             validateEntityFieldsForSiteUserObjects(setSiteUserIds);
         }
     }

     /**
     *  @description    :   Method to update Entity field 
     * 
     *  @args           :   Set<Id>
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created By - Deepak Kumawat - 10/10/2017 - CR-20170927-11503 - Apollo Release
     * 						V1.1 - Modified By - Victor Hanson - 07/23/2019 - CR-20190627-13200 - Only update entity if required
     * 
     **/    
     public static void validateEntityFieldsForSiteUserObjects(Set<Id> setSiteUserIds) {    
        
         //List to hold the site user records
         List<Site_User__c> listOfSiteUsers = new List<Site_User__c>(); 
          
         //Fetch the all site user with related child "site profiles"
         List<Site_User__c> siteUsers = [Select Id, Entity__c, (Select Id, Type__c From Site_Profiles__r) From Site_User__c Where Id IN : setSiteUserIds];
         
         //Check for size
         if(siteUsers.size() > 0 ) { 
             
             //Loop through the site user 
             for(Site_User__c siteUser : siteUsers) {
                 
                 //Set to hold the value of the type value
                 Set<String> setOfTypeValue = new Set<String>();
                 
                 if(siteUser.Site_Profiles__r != null && siteUser.Site_Profiles__r.size() > 0 ) {
                     
                     String entity = '';
                     
                     //loop through the site profiles
                     for(Site_Profile__c siteProfile : siteUser.Site_Profiles__r) {
                         
                         //Check for condition
                         if(siteProfile.Type__c.equalsIgnoreCase('EAB.com')) {
                             
                             //Populate the entity value
                             entity = 'EAB';
                             
                             //Populate the setOfTypeValue
                             setOfTypeValue.add(siteProfile.Type__c);
                             
                         }  else if (siteProfile.Type__c.equalsIgnoreCase('Advisory.com')) {
                             
                             //Populate the entity 
                             entity = 'HC';
                             
                         } else if (siteProfile.Type__c.equalsIgnoreCase('Royall.com')){
                             
                             //Populate the entity value
                             entity = 'Royall';
                             
                             //Populate the setOfTypeValue
                             setOfTypeValue.add(siteProfile.Type__c);
                         }
                     }
                     
                     //Check for size
                     if(setOfTypeValue.size() > 1) {
                         
                         //Populate the entity 
                         entity = 'All';
                     }
                     
                     //VH updated 7/23/2019 - only add to list of updates if necessary
                     if (siteUser.Entity__c != entity) {
                         siteUser.Entity__c = entity;
                         //Populate the listOfSiteUsers that updated to entity field 
                         listOfSiteUsers.add(siteUser);
                     }
                 }
             }
        } 
        
        //Check for size
        if(listOfSiteUsers.size() > 0) {
             
          //By pass all triggers
            Util.BypassAllTriggers = true;
             
            //Update the Site User records
            update listOfSiteUsers ;
             
            //Enable all triggers
            Util.BypassAllTriggers = false;
         }
     }
    
}