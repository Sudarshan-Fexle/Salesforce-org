/**
    Desription      :   This class is used to store the Site Helper methods for site functionality (ie: EAB.com/Advisory.com).
  
    Created By      :   Victor Hanson
  
    Created Date    :   07/29/2014
  
    Revision Logs   :   V1.0 - Created
                        V1.1 - Modified By - Abhinav Sharma - 22-01-2015 - CR-20141007-7689
        		V1.2 - Modified By - Abhinav Sharma - 03-25-2015 - CR-20150305-8733
        		V1.3 - Modified By - Ajit Surana - 04-29-2015 - CR-20150415-8874
        		V1.4 - Modified By - Ajit Surana - 05-04-2015 - CR-20150414-8872
        		V1.5 - Modified By - Victor Hanson - 10-01-2015 - CR-20150330-8821 - added ownerId and account.ownerId to contactbasequery.  Only add sharing record for users that do not have dataloader or sfadmin profiles
        		V1.6 - Modified By - Abhinav Sharma - 11/27/2015 - CR-20151118-9393 
        		V1.7 - Modified By - Mahendra Swarnkar - CR-20160926-10189 - 12/8/2016 - Updated to replace the "Eligible_Subscription_Option__c.Key_Contact_Auto_Subscribe__c" References 
            											 with "Eligible_Subscription_Option__c.Auto_Subscribe__c" field, where Auto_Subscribe__c =: Label.Auto_Subscribe_Key_Contact ( Label.Auto_Subscribe_Key_Contact = "Key Contact")
        		V1.8 - Modified By - Abhinav Sharma - 1/18/2017 - CR-20160505-9833  -  Add the Account.Contribution_Category__c field to the ContactBaseQuery  
                        								    -  Update the getSiteUser method            
        		V1.9 - Modified By - Victor Hanson - 1/25/2017 - CR-20161102-10332  -  Commented out all references to DB_Globals (dupeblocker)
        		V1.10 - Modified By - Mahendra Swarnkar - 4/27/2017 - CR-20170310-10747  - updated the method "Action_Register()" and "CreateWebConference()" to remove the single quote on user input data for Advisory/EAB sites, which are based on the query.
        		V1.11 - Modified By - Mahendra Swarnkar - 07/06/2017 - CR-20170524-10956 - Commented the method "createAccountAndContactSharing".            
        		V1.12 - Modified By - Victor Hanson - 12/14/2017 - CR-20171214-11856 - Modified institutionUpsertToSiteDatabase by only completing EAB / ADV callouts if there is a value in the corresponding Sitecore Admin URL
        		V1.13 - Modified By Abhinav Sharma - 06/25/2018 - CR-20180605-12266 - Replace Con.Email with con.Company_Email__c
        		V1.14 - Merged by Rajeev jain - Deployment CR-20180605-12266 - 08/31/2018.
        		V1.15 - Modified By Abhinav sharma - CR-20180809-12495 - Issue--CR12495--QA--00008452 - CreateAutoSubscriptions
        		V1.16 - Modified By - Victor Hanson - 09/11/2018 - CR-20180911-12587 - updated logic to populate Contact.Email field in some scenarios
        		V1.17 - Merged By Rajeev Jain - BOSS Project: Account Merge - 10/24/2018
        		V1.18 - Modified By - Seemu Saikia - 05/20/2019 - CR-20190520-13118
        		V1.19 - Modified - 05/28/2019 - Victor Hanson - CR-20190520-13117 - do not return E3 when Institution's Org Status <> Active
        		V1.20 - Modified - 07/15/2019 - Victor Hanson - CR-20190627-13200 - added functionality to return productRecommendations
        		V1.21 - Modifed By Dipesh Gupta - CR-20190726-13240 - 08/06/2019 - Remove the reference of Temporary_Program_Access__c
        		V1.22 - Modified By Colin McGloin - CR-20190306-12917 - Removed references to getTypeFromApplicableSegment method and replaced with references to SITE_EAB constant - no longer need to account for Advisory Site Profiles
			V1.23 - Modified By Victor Hanson - CR-20190823-13279 - Removed two bits of unnecessary code from Action_SiteTokenAvailability & Action_SavedPostListener
			V1.24 - Modified By Victor Hanson - CR-20190827-13289 - 08/27/2019 - Updated Action_UserTokenAvailabilityCheck to record Web Program Access Ids
			V1.25 - Modified By Victor Hanson - CR-20190904-13309 - removed reference to active directory & advisory.com send pw fields on Contact from contact base query
			V1.26 - Modified By Victor Hanson - CR-20190820-13270 - added reference to Membership_Key_Contacts__r in the query and getUser method
			V1.27 - Modified by Dipesh Gupta - CR-20191016-13431 - 10/18/2019 - method Action_GetUser - Added a condition to retrive contact based in sUer.UniqueId (Contact Id)
			V1.28 - Modified by Dipesh Gupta - CR-20191011-13407 - 01/30/2020 - Added new method 'ACTION_UpsertDeleteMenuCustomization' and some additional checks
			V1.29 - Modified by Dipesh Gupta - CR-20200207-13710 - 02/11/2020 - Added Meeting__r.Meeting_GUID__c in the contactBaseQuery variable. 
			V1.30 - Modified By - Dipesh Gupta - CR-20191011-13407 - 30/01/2020
                        V1.31 - Modified By - Abhinav Sharma - CR-20200714-14306 - 8/13/2020 - Check the Company Email on related contact & update the code for the searchOrganization command
                        V1.32 - Modified By - Neha Sharma - 12/1/2020 - CR-20201019-14613 - Added the functionality to send the payer status with web program access in the login response
			V1.33 - Modified By -  Neha Sharma - 01/12/2020 - CR-20201201-14714 - Updates to login callout response to include additional
			V1.34 - Modified By - Abhinav Sharma - 02/04/2020 - CR-20200814-14436
                        V1.35 - Modified by - Neha Sharma - 02/04/2021 - CR-20200527-14108 - Field:Advisory_Board_Fellow__c is deleted from Contact so removed from the query string.
                        V1.36 - Modified By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
			V1.37 - Modified By - Neha Sharma - 08/23/2021 - CR-20210823-15372 - Added Greenlight Institution recordTypeId references
**/ 
public class SiteUserHelper {
    
    //VH Added 7/15/2019 for Recommended Product functionality - CR-20190627-13200
    public static final String CAMPAIGN_RT_ID_RECOMMENDED_PRODUCT = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Recommended_Product_Campaign').getRecordTypeId();
    
    //Added Company_Email__c into the Query - Abhinav Sharma - 06/25/2018 - CR-20180605-12266.
    //Modify By - Abhinav Sharma - 02/04/2020 - CR-20200814-14436 - Finish Deleting Fields from Oct 2020 Release (Remove Provider_Type__c on the Account from Query at line no 63)
    //Modified by - Neha Sharma - 02/04/2021 - CR-20200527-14108 - Field:Advisory_Board_Fellow__c is deleted from Contact so removed from the query string.
    //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
    //Modify By - Neha Sharma - 29/7/21 - CR-20210721-15304 - Add the Account.Enrollment_Scenario_Explorer_access__c field in the query
    public final static String CONTACTBASEQUERY = 'SELECT  Account.Enrollment_Scenario_Explorer_access__c, Company_Email__c, Site_User__c,Account.Contribution_Category__c, Account.Advisory_com_Organization_Status__c, Account.Organization_Id__c, Account.EAB_com_Organization_Status__c,' +
        'OwnerId,Account.OwnerId,Account.Bed_Size__c,' +
        'Advisory_com_LinkedIn__c,Advisory_com_Twitter__c,Advisory_com_Pinterest__c,Advisory_com_Name_Tag__c,Advisory_com_Organization_Name_Tag__c, EAB_Role__c, EAB_Department__c, ' +
        'Advisory_com_Share_Image__c,Advisory_com_Share_Fax__c,Advisory_com_Share_Facebook__c,Advisory_com_Interests__c,Advisory_com_Share_Email__c,' +
        'Advisory_com_Share_Twitter__c,Advisory_com_Share_Pinterest__c,Advisory_com_Share_Phone__c,Advisory_com_Share_LinkedIn__c,Advisory_com_Share_Interests__c,Advisory_com_Share_Information__c,' +
        'Account.Name,Legacy_Contact_ID__c,Primary_Address_Line_2__c,Suffix__c,CreatedById,Department_Code__c,Bypass_Domain_Validation__c,RecordTypeId,' +
        'Primary_City__c,Primary_State_Province__c,CreatedDate,Employee_ID__c,LastModifiedById,LastName,Secondary_State_Province__c,' +
        'Previous_Institution_Record__c,Title,Middle_Name__c,Record_Type__c,Expert__c,Department_Description__c,Primary_Address_Line_3__c,FirstName,' +
        'Secondary_Postal_Code__c,Primary_Country__c,Account.Principal__r.Email,' +
        'Account.APS_Consultant__r.Email,Account.r_Account_FA__r.Email,Account.Transfer_Strategic_Leader__r.Email,Account.EAB_Relationship_Status_Text__c,Account.YouVisit_Partner_Success_Manager__r.Email,Account.Cappex_Partner_Success_Manager__r.Email,' +
        'Salutation,Secondary_Address_Name__c,Phone,Secondary_Address_Line_3__c,OtherState,Asst_Email__c,' +
        'Description,Contact_Status__c,Counter_ID__c,Management_Level__c,Employee_User_Record__c,Account.Principal__c,' +
        'Email,Secondary_City__c,MailingState,Contact_Restriction_Status_2__c,Secondary_Country__c,' +
        'Primary_Address_Line_1__c,Fax,Department,Department_External_Description__c,Contact_Restriction_Status__c,' +
        'LastModifiedDate,Id,Asst_Notes__c,Primary_Postal_Code__c,Name,AccountId,Historical_Linker__c, Secondary_Address_Line_1__c,Nickname__c,' +
        'GUID__c,Secondary_Address_Line_2__c,Account.Historical_Linker__c,MailingCity,Function__c,Account.Research_Strategic_Leader__r.Email,Account.Student_Success_Strategic_Leader__r.Email,' +
        'Account.Strategic_Account_Segment__c, Account.Tokens__c, Account.Tokens_Available__c,Account.Status__c, Account.RecordType.Name, Account.Account_Formal_Name__c,' +
        'Account.Adult_Learner_Strategic_Leader__r.Email,Account.Advancement_Strategic_Leader__r.Email,Account.Enrollment_Undergrad_Strategic_Leader__r.Email,' +
        '(SELECT Start_Date__c, Owner.Name, End_Date__c, CreatedBy.Name, Web_Program__r.Advisory_com_CS_Role__c, Web_Program__r.Program_Acronym__c, Web_Program__r.Program_Formal_Name__c, Web_Program__r.Web_Program__r.Description__c, Web_Program__r.Web_Program__r.Program_Code_to_Member__c, Web_Program__r.Web_Program__r.Advisory_com_CS_Role__c, Web_Program__r.Web_Program__r.A_com_Program_ID__c, Program_Acronym__c, Program_Formal_Name__c, Web_Program__r.Adv_com_Program_Id__c, Web_Program_Name__c, Site_Program_Id__c FROM Temporary_Program_Access__r WHERE Start_Date__c <= TODAY AND End_Date__c >= TODAY limit 1000),' +
        '(SELECT Id, Start_Date__c, End_Date__c, Status__c, EventID__c FROM Meeting_Utilization__r WHERE Start_Date__c >= TODAY),' +
        '(SELECT Id, Start_Date__c, End_Date__c, Status__c, EventID__c FROM Meeting_Utilization1__r WHERE Start_Date__c >= TODAY),' +
        /*'(SELECT Auto_Subscribed__c,  Subscription_Id__r.Program__r.Applicable_Segments__c, Subscription_Status__c, Activation_Date__c, Subscription_ID__r.Name, Subscription_ID__r.Related_Subscription__r.Description__c, Subscription_ID__r.Program__c, Subscription_Name__c, Subscription_ID__r.Name__c, Subscription_ID__r.Related_Subscription__r.Subscription_Category__c, Subscription_ID__r.Related_Subscription__r.Name, Subscription_ID__r.Related_Subscription__r.Subscription_Status__c, Subscription_ID__r.Related_Subscription__r.Subscription_Name_Ext__c, ' +
        'Subscription_ID__r.Related_Subscription__r.Legacy_Subscription_ID__c, Termination_Date__c FROM Subscriptions__r WHERE Termination_Date__c = null AND Subscription_ID__r.Related_Subscription__r.Subscription_Status__c = \'Active\' LIMIT 1000), ' +*/
        '(SELECT Id, Password__c, Password_Reset_Token__c, CreatedBy.Name, CreatedDate, LastModifiedDate, LastModifiedBy.Name, Bypass_Domain_Validation__c, Last_Access__c, Send_Password_Notification__c, Site_User__c, Verify__c, Verify_Date__c, Status__c, Status_Code__c, Type__c, User_Id__c, Username__c, Status_Code_Description__c, Tokens__c,Menu_Customizations__c, Tokens_Available__c, contact__r.Account.Advisory_com_Organization_Status__c FROM Site_Profiles__r ORDER BY Status__c DESC), ' +
        '(SELECT Id, Contact__c, Expiration_Date__c, Site_Content__c, Site_Content__r.GUID__c, Site_Profile__c, Status__c From Site_Tokens__r where Status__c = \'Active\' ORDER BY CreatedDate DESC),'+
        '(SELECT Id, Contact__c, Site_Content__r.GUID__c, Type__c, Site_Profile__c From Site_Preferences__r Where Site_Content__c != null AND Site_Profile__c != null), '+
        '(SELECT Id, Contact__c, Site_Content__c , Site_Content__r.GUID__c, Site_Profile__c From Site_Content_Recommendations__r), ' +
        '(SELECT Id, Status__c, EAB_Event__c, EAB_Event__r.Begins__c, EAB_Event__r.Meeting_GUID__c FROM Registrations__r WHERE EAB_Event__r.Begins__c >= TODAY), ' +
        '(SELECT Id, Campaign.Primary_Program__c, Campaign.Primary_Program__r.Web_Program_Access_Ids__c FROM CampaignMembers WHERE Campaign.RecordTypeId = \'' + CAMPAIGN_RT_ID_RECOMMENDED_PRODUCT + '\'), ' +
        '(SELECT Id, Assignment_Role__r.Name FROM Institution_Roles__r), ' +
        '(SELECT Id, Name, toLabel(Role__c), Contact__r.Name, Membership__r.Name, Membership__r.Program_Acronym__c FROM Membership_Key_Contacts__r WHERE Membership__r.Membership_Status__c LIKE \'Member%\') ' +
        'FROM Contact';  
    
    //constants
    public static final String ERROR_EXISTING_ACTIVE_USER = 'Error_Existing_Active_User';
    public static final String ERROR_EXISTING_INACTIVE_USER = 'Error_Existing_Inactive_User';
    public static final string ERROR_INVALID_DOMAIN_USER_MESSAGE = 'Email address contains an invalid domain';
    public static final String ERROR_INVALID_DOMAIN = 'Error_Invalid_Domain';
    public static final String ERROR_STYLE_PREFIX = '<font color="red"><h3>';
    public static final String ERROR_STYLE_SUFFIX = '</h3></font>';
    public static final String ERROR_CHANGE_REQUEST_EMAIL_HANDLER_NO_USER_EXITS = 'No user exist with this email Id';
    public static final string SITE_ADVISORY = 'advisory.com';
    public static final string SITE_EAB = 'eab.com';
    public static final string SITE_ROYALL = 'Royall.com';
    public static final string ERROR_DUPLICATE_SITE_PROFILE_TYPE = 'Another Site Profile already exists for that site type.';
    public static final string ADVISORY_COM_ORG_ID_API_NAME = 'Advisory_com_Organization_ID__c';
    public static final string STATUS_ACTIVE = 'Active';
    public static final string RESPONSE_SUCCESS = 'Success';
    public Static boolean REUPDATE_SITE_PROFILE = false;
    public static final String SITE_TOKEN_FLAG_SITE_PROFILE = 'No Tokens - Site Profile';
    public static final String SITE_TOKEN_FLAG_INSTITUTION = 'No Tokens - Institution';
    
    //Added By - Neha Sharma - 12/1/2020 - CR-20201019-14613  
    public static Map<String,String> mapOfprogwithPayerStatus = new Map<String,String>();
    
    //public variables
    public static boolean IsTriggerContact = false;
    public SiteTempAccessController accessController { get; set; }
    
    //private variables
    //Neha Sharma - 08/23/2021 - CR-20210823-15372 - Added Greenlight Institution recordTypeId references
    public static Set<Id> validAccountRecordTypeIds {
        get {
            if (validAccountRecordTypeIds == null) {
                validAccountRecordTypeIds = new Set<Id> { Constants.ACCOUNT_RT_ID_US_EDUCATION, Constants.ACCOUNT_RT_ID_GREENLIGHT, Constants.ACCOUNT_RT_ID_US_INDEPENDENT_SCHOOL, Constants.ACCOUNT_RT_ID_INTERNATIONAL_EDUCATION };
                    }
            return validAccountRecordTypeIds;
        }
        set;
    }
    
    /**
     * @description:    return an error containing hte duplicate Site Profile / Contact information.
     * 
     **/
    public static string ERROR_DUPLICATE_SITE_PROFILE(Site_Profile__c sProfile) {
        return 'A site profile already exists with the same Username and Type.'
             + '<br>Site Profile:<a href="/' + sProfile.Id + '">' + sProfile.Name
             +'</a> <br/>Contact:<a href="/' + sProfile.Contact__c + '">' + sProfile.Contact__r.Name + '</a>';
    }
    
    
    /**
     * @description:    decrypt the encrypted site user  (previously RETREIVEADVUSER)
     * 
     **/
    public static SiteUser getSiteUser(string encryptedRequest) {
        
        SiteUser sUser = new SiteUser();
        blob reqBlob = EncodingUtil.base64Decode(encryptedRequest);
        String decryptedRequest = EncryptionHelper.decrypt(reqBlob);
        
        //VH 05/16/2019: remove any carriage returns and "id" values
        decryptedRequest = decryptedRequest.replaceAll('\n', '').replaceAll('"id":', '"id_x":');
        
        // try to validate the user data
        try {
            sUser = EncryptionHelper.deserializeSiteUser(decryptedRequest);
        }
        catch(Exception ex) {
            sUser.Response = 'Error: ' + ex.getMessage() + ' on line number: ' + ex.getLineNumber() + '  Stack:' + ex.getStackTraceString();
        }
        
        // only perform action in the constructor if it is one of these special commands
        // because DML statements aren't required by these commands
        if (sUser.Command != null && 
            (sUser.Command.equalsIgnoreCase('search') || 
            sUser.Command.equalsIgnoreCase('searchOrganization') ||
            sUser.Command.equalsIgnoreCase('userDetails') ||
            sUser.Command.equalsIgnoreCase('userProgramDetails'))) 
        {
            performAction(sUser);
        }
       
        return sUser;
    }
    
    /**
     * @description:    this determines what is being returned via JSONResponse string
     *                  V1.0 Updated By - Abhinav Sharma - CR-20200714-14306 - 8/13/2020 - Check the Company Email on related contact & update the code for the searchOrganization command
     * 
     **/
    public static SiteUser PerformAction(SiteUser sUser) {
        
        if (sUser.Command == null ) {
            sUser.Response = 'Invalid Command: null';
        }
        else if (sUser.Command.equalsIgnoreCase('login')) {
            
            sUser = Action_Login(sUser);
        }
        else if (sUser.Command.equalsIgnoreCase('getUser_updateLastAccess')) {
            sUser = Action_GetUser(sUser, true);
        }
        else if (sUser.Command.equalsIgnoreCase('getUser')) {
            sUser = Action_GetUser(sUser, false);
        }
        else if (sUser.Command.equalsIgnoreCase('register')) {
            sUser = Action_Register(sUser);
        }
        else if (sUser.Command.equalsIgnoreCase('updateUser')) {
            sUser = Action_UpdateUser(sUser);
        }
        else if (sUser.Command.equalsIgnoreCase('sendPasswordResetEmail')) {
            sUser = Action_SendPasswordResetEmail(sUser);
        }
        else if (sUser.command.equalsIgnoreCase('search')) {
            List<Contact> contacts = FindContacts(sUser);
            for (Contact c : contacts) {
                for (Site_Profile__c sProfile : c.Site_Profiles__r) {
                    sUser.site_Profiles.add(sProfile);
                }
            }
        }
        else if (sUser.command.equalsIgnoreCase('searchOrganization')) {
            //Added by Abhinav Sharma - CR-20200714-14306 - 8/13/2020 - Start 
            if(String.isNotBlank(sUser.email)) {
                String response = checkEmailRelatedExisting_ContactOrSPs(sUser);
                if(String.isNotBlank(response)) {
                    sUser.response = response;
                }else{
                    sUser.Institutions = FindInstitutions(sUser);
                }
            }else{
                sUser.Institutions = FindInstitutions(sUser);   
            }
            //Added by Abhinav Sharma - CR-20200714-14306 - 8/13/2020 - End
            
        }
        else if (sUser.command.equalsIgnoreCase('userDetails')) {
            List<Contact> contacts = FindContacts(sUser);
            
            for (Contact c : contacts) {
                sUser.ContactWrappers.add(new SiteControllerHelper.ContactWrapper(c, true));
            }
        }
        else if (sUser.command.equalsIgnoreCase('SendWebConferenceConfirmation')) {
            sUser = Action_SendWebConferenceConfirmation(sUser);
        }
        else if (sUser.Command.equalsIgnoreCase('upsertContact')) {
            sUser = Action_UpsertContact(sUser);
        }
        else if(sUser.Command.equalsIgnoreCase('addSavedPost') || sUser.Command.equalsIgnoreCase('removeSavedPost')) {
            sUser = Action_SavedPostListener(sUser);
            
        }
        else if(sUser.Command.equalsIgnoreCase('useToken')) {
            sUser = Action_UserTokenAvailabilityCheck(sUser);
        }
	//V1.27 - Created By - Dipesh Gupta - CR-20191011-13407 - 30/01/2020
        else if (sUser.Command.equalsIgnoreCase('updateMenuCustomization')) {

            suser.Site = 'EAB.com';
            sUser = ACTION_UpsertDeleteMenuCustomization(sUser);
        }
        else {
            sUser.Response = 'Unrecognized command:' + sUser.Command;
        }
        
        return sUser;
    }
    
    /**
     * @description:    verify that the username and password are valid
     * 
     **/
    public static SiteUser Action_Login(SiteUser sUser) {
        
        string queryString = CONTACTBASEQUERY
            + ' WHERE Id IN (SELECT Contact__c FROM Site_Profile__c WHERE Username__c = \'' + String.escapeSingleQuotes(sUser.username) + '\' '
            + ' AND (Password__c = \'' + sUser.password + '\' OR (Impersonate_User__c = true AND Alternate_Password__c = \'' + SiteUserHelper.sitecoreSettings.Master_Password__c + '\')) '
            + ' AND Type__c = \'' + sUser.Site + '\')';
        List<Contact> contacts =  database.query(queryString);
        
        if (contacts.size() > 0) {
            
            //populate the SiteUser record from fields on the contact
            sUser = getSiteUser(contacts[0], sUser, false);
            
            //if there are errors, return the site user immediately
            if (hasErrors(contacts[0], sUser)) return sUser;
            
            //update the Site Profile information
            sUser.site_Profile.Last_Access__c = system.now();
            sUser.site_Profile.Status_Code__c = sUser.Status_Code;
            String contentVersionId = '';
            
            updateLastAccess(contacts[0], sUser.Site_Profile);
            sUser.Response = 'Success';
             //Modify By - Neha Sharma - 29/7/21 - CR-20210721-15304 - add the HasEseAccess value in the login command - start from here 
            if(contacts[0].Account.Enrollment_Scenario_Explorer_access__c == false)
            {
            	sUser.HasEseAccess = '0';   
            }
            else{
               sUser.HasEseAccess = '1';    
            }
            //end here
        }
        else {
            //get the site profile that this request is most-likely related to so we can log the failed login attempt
            queryString = CONTACTBASEQUERY
            + ' WHERE Id IN (SELECT Contact__c FROM Site_Profile__c WHERE Username__c = \'' + String.escapeSingleQuotes(sUser.username) + '\' '
            + ' AND Type__c = \'' + sUser.Site + '\') ORDER BY LastModifiedDate DESC';
            contacts =  database.query(queryString);
            if (contacts.size() > 0) {
                sUser = getSiteUser(contacts[0], sUser, false);
                //Modify By - Neha Sharma - 29/7/21 - CR-20210721-15304 - add the HasEseAccess value in the login command - start from here 
                if(contacts[0].Account.Enrollment_Scenario_Explorer_access__c == false)
                {
                    sUser.HasEseAccess = '0';   
                }
                else{
                    sUser.HasEseAccess = '1';    
                }
                //end here
            }
            
            sUser.Response = 'invalid login';
        }
        return sUser;
    }
    
    /**
     * @description:    return the user information
     * 
     * Version : - Modified by Dipesh Gupta - CR-20191016-13431 - 10/18/2019 - Added a condition to retrive contact based in sUer.UniqueId (Contact Id)
     **/
    public static SiteUser Action_GetUser(SiteUser sUser, boolean updateLastAccessDate) {
        //v1.10 - Modified By - Mahendra Swarnkar - 4/27/2017 - CR-20170310-10747 - Commenting out the code as these lines are producing a double-escaped quote, which causes an error - Starts from here
        /*
        // escape any single quotes that haven't been escaped already
        if (sUser.Username != null && !sUser.Username.contains('\\\''))
            sUser.Username = sUser.Username.replace('\'','\\\'');
        */
        //v1.10 - Modified By - Mahendra Swarnkar - 4/27/2017 - CR-20170310-10747 - Commenting out the code as these lines are producing a double-escaped quote, which causes an error - Ends here
        
        string queryString = CONTACTBASEQUERY;
        if (sUser.User_Id != null) {
            // We don't filter by create adv user = true because we need to find out if there is an inactive user in some scenarios.
            // Filtering by create adv user DESC brings the active user to the top of the list in the scenarios where there
            // is an inactive and active contact with the same user id. (CR-4478 is an example of this)
            queryString += ' WHERE Id IN (SELECT Contact__c FROM Site_Profile__c WHERE User_Id__c = \'' + sUser.User_Id + '\')';
        }
        else if (sUser.Username != null && sUser.Username != '') {
            queryString += ' WHERE Id IN (SELECT Contact__c FROM Site_Profile__c WHERE Username__c = \'' + string.escapeSingleQuotes(sUser.Username) + '\' ' 
                + ' AND Type__c = \'' + sUser.Site + '\')';
        }
        //Modified By Abhinav Sharma - 06/25/2018 - CR-20180605-12266 - Replace Contact__c.Email with Contact__c.Company_Email__c
        else if (sUser.Email_Address != null && sUser.Email_Address != '')
            queryString += ' WHERE Contact__c.Company_Email__c  = \'' + string.escapeSingleQuotes(sUser.Email_Address) + '\'';
        
        //Added By Dipesh Gupta - 10/18/2019 - CR-20191016-13431. 
        else if (String.isNotBlank(sUser.UniqueId)) {
            queryString += ' WHERE Id = \'' + string.escapeSingleQuotes(sUser.UniqueId) + '\' ';
        }
        
        
        List<Contact> contacts =  database.query(queryString);
        if (contacts.size() > 0) {
            // populate the sUser record from fields on the contact
            sUser = getSiteUser(contacts[0], sUser, false);
            
            //if there are errors, return the site user immediately
            if (hasErrors(contacts[0], sUser)) return sUser;
            
            if (updateLastAccessDate) updateLastAccess(contacts[0], sUser.Site_Profile);
            
            // 1/17/13 bug fix
            if (sUser.Username == null && sUser.Email_Address != null)
                sUser.Username = sUser.Email_Address;
            if (sUser.Response == null)
                sUser.Response = 'Success';
        }
        else {
            sUser.Response = 'invalid username';
        }
        return sUser;
    }
    
    public static void updateLastAccess(Contact c, Site_Profile__c sProfile) {
        Datetime dtNow = system.now();
        sProfile.Last_Access__c = dtNow;
        update sProfile;
    }
    
    /**
     * @description:    Create a new site user record.  This record will then be referenced from a Contact and one or many Site Profiles.
     * 
     **/
    public static Site_User__c createNewSite_User(boolean createAndInsert) {
        Site_User__c siteUser = new Site_User__c();
        if (createAndInsert) insert siteUser;
        return siteUser;
    }
    
    /**
     * @description:    Create a site profile based on the Contact, SiteUser, and SiteUserId
     * 
     **/
    public static Site_Profile__c createNewSite_Profile(Contact con, SiteUser sUser, Id siteUserId) {
        
        //create a new site_user record if one is not present
        if (sUser.Site_User == null && siteUserId == null) {
            Site_User__c site_User = createnewSite_User(true);
            sUser.site_User = site_User;
            siteUserId = site_User.Id;
        }
        
        Site_Profile__c site_Profile = new Site_Profile__c(Status__c = 'Active',
                                  Type__c = sUser.Site,
                                  Username__c = sUser.Email_Address,
                                  Site_User__c = siteUserId);
        
        //Modified By Abhinav Sharma - 06/25/2018 - CR-20180605-12266 - Replace Con.Email with con.Company_Email__c
        //make sure the username matches the contact's email
        if (con != null) {
            if (site_Profile.Username__c == null && con.Company_Email__c != null) site_Profile.Username__c = con.Company_Email__c;
            if (site_Profile.Contact__c == null && con.Id != null) site_Profile.Contact__c = con.Id;
        }
        
        return site_Profile;
    }
    
    /**
     * @description:    used to allow chatter plus users to add/update non-adv.com contacts
     * 
     **/
    public static SiteUser Action_UpsertContact(SiteUser sUser) {
        boolean isNewContact = false;
        // create a new Contact for us to work with
        Contact conToUpsert = new Contact();
        
        // if the uniqueId is missing, this is a new contact that we need to configure
        if (sUser.UniqueId == null) {
            isNewContact = true;
            // set the proper record type
            conToUpsert.RecordTypeId = Util.RecordTypeId('Contact', 'External');
            conToUpsert.OwnerId = Label.Salesforce_Admin_Id;
        }
        
        if (!isNewContact) {
            // 1) find the contact or determine if this is a new contact that needs created
            String queryString = CONTACTBASEQUERY + ' WHERE Id =  \'' + sUser.UniqueId + '\'';
            List<Contact> contacts =  database.query(queryString);
            if (contacts.size() > 0) {
                conToUpsert = contacts[0];
            }
            else {
                sUser.Response = 'Error: No contact with Id: ' + sUser.UniqueId;
            }
        }
        
        // 2) find the account
        List<Account> accts = [SELECT Name, Id
                              FROM Account WHERE Id = :sUser.AccountId];
        
        if (accts.size() > 0) {
            // 3) match the sUser with any missing data from the contact
            if (!isNewContact)
                sUser = getSiteUser(conToUpsert, sUser, true);
            
            // Based on the SiteUser, populate all of the necessary fields on the contact 
            conToUpsert = ReturnContactFromSiteUser_NoAdvAccount(conToUpsert, sUser);
            
            try {
                // 4) Upsert the contact
                upsert conToUpsert;
                sUser.UniqueId = conToUpsert.Id;
                sUser.Response = 'Success';
            }
            catch(DMLException ex) {
                sUser.Response = 'Error: ' + ex.getDMLMessage(0);
            }
            catch(Exception ex) {
                sUser.Response = 'Error: ' + ex.getMessage();
            }
        }
        else {
            sUser.Response = 'No Account Found with Id: ' + sUser.AccountId;
        }
        
        return sUser;
    }
    
    /**
     * @description:    update a Site Profile.
     * 
     **/
    public static SiteUser Action_UpdateUser(SiteUser sUser) {
        
        // if ID is null, return error immediately
        if (sUser.User_Id == null) {
            sUser.Response = 'Invalid user id: NULL';
            return sUser;
        }
        
        string queryString;
        if (test.isRunningTest()) {
            if (sUser.User_Id == null)
                queryString = CONTACTBASEQUERY 
                + ' WHERE Id IN (SELECT Contact__c FROM Site_Profile__c WHERE Username__c = \'' + string.escapeSingleQuotes(sUser.Username) + '\' ' 
                + ' AND Type__c = \'' + sUser.Site + '\')';
            else
                queryString = CONTACTBASEQUERY 
                + ' WHERE Id IN (SELECT Contact__c FROM Site_Profile__c WHERE User_Id__c = \'' + sUser.User_Id + '\' ' 
                + ' AND Type__c = \'' + sUser.Site + '\')';
        }
        else {
            queryString = CONTACTBASEQUERY 
                + ' WHERE Id IN (SELECT Contact__c FROM Site_Profile__c WHERE User_Id__c = \'' + sUser.User_Id + '\' ' 
                + ' AND Type__c = \'' + sUser.Site + '\')';
        }
        List<Contact> contacts =  database.query(queryString);
        
        if (contacts.size() > 0) {
            
            if (contacts[0].AccountId != null) {
                
                //get all the Site Profile / Contact details
                sUser = getSiteUser(contacts[0], sUser, true);
                
                /* VH 08/06/2019 - avatar is stored in WP now, so we're commenting out this functionality for now.  might be phase 2 feature later
                // Modified by - Victor Hanson - 06/27/2019 - CR-20190520-13118 - avatarImage is now sent as a URL and we need to download the file to insert in SF
                // Added by - Seemu Saikia - 05/20/2019 - CR-20190520-13118
                // Set all Contact Version ids from site profiles 
                if(String.isNotBlank(sUser.avatarImage)) {
                
                updateSiteProfileAvatar(sUser.User_Id, sUser.avatarImage);
                }*/
                
                //if there are errors, return the site user immediately
                if (hasErrors(contacts[0], sUser)) return sUser;
                
                // Perform the user update
                sUser.Response = UpdateContactFromSiteUser(contacts[0], sUser);
                
                
                
            }
            else {
                sUser.Response = 'No Account Found';
            }
        }
        else {
            sUser.Response = 'invalid user Id: ' + sUser.User_Id;
        }
        
        if (sUser.Response.equalsIgnoreCase('Success')) {
            sUser = Action_GetUser(sUser, false);
        }
        
        return sUser;
    }

    /**
     * @description:    register a new Site User
     * 
     * @revision log:   Modified - 06/27/2019 - Victor Hanson - CR-20190520-13118 - send callout to wordpress site to get user's avatar image file and save to SF
     *                  Modified - 08/06/2019 - Victor Hanson - avatar is stored in WP, so we're commenting out this functionality for now.  might be phase 2 feature later
     *
     **/
     /*@future (callout=true)
    public static void updateSiteProfileAvatar(Integer userId, String imageURL) {

        //parse endpoint from imageURL
        String endpoint = imageURL;
        //TODO: PARSE ENDPOINT FROM IMAGE URL

        //setup our Request
        HttpRequest req = siteContentRecommendationsHelper.buildWordpressHTTPCallout('GET', endpoint);
        //set our Http
        Http http = new Http();

        if(Test.isRunningTest()) {
            return;
        }

        //send callout
        HttpResponse response = http.send(req);
        
        //get image info
        Blob imageBlob = response.getBodyAsBlob();
        
        //If our message fails to send to Wordpress then send an email to SF Admin account to notify
        if (response.getStatusCode() != 200){
            
            // Create and send an email with the results of the Callout
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
            //Set our Mail 
            mail.setToAddresses(new String[] {Label.Salesforce_Admin_Email});
            mail.setReplyTo(Label.Salesforce_Admin_Email);
            mail.setSenderDisplayName('Save avatar image failed');
            mail.setSubject('Save avatar image failed');
            mail.setPlainTextBody('The callout to Wordpress failed with the following errors:' + '\n' + 'Status Code: ' + response.getStatusCode() + '\n\n' + 
                                    'Error Body: ' + response.getBody() + '\n\n' +
                                    'endpoint: ' + endpoint);
            
            //Send our email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
            
        }

        //Set to hold the content Version ids.
        Set<Id> contentVersionIdSet = new Set<Id>();
        
        //List to hold the content version object
        List<ContentVersion> cVersionsToBeUpdated = new List<ContentVersion>();
        
        //get the site profiles
        List<Site_Profile__c> sProfiles = [SELECT Id, Avatar_Content_Version_Id__c FROM Site_Profile__c WHERE User_Id__c = :String.valueOf(userId)];

        //Loop on the site profile to get the id from Avatar_Content_Version_Id__c from Site Profile.
        for(Site_Profile__c sp : sProfiles) {
            if(sp.Avatar_Content_Version_Id__c != null)
                contentVersionIdSet.add(sp.Avatar_Content_Version_Id__c);
        
        }

        //get the site profiles
        List<ContentVersion> cVersions = [SELECT Id,ContentDocumentId from ContentVersion where Id IN: contentVersionIdSet];
        
        //Check the size of set. 
        if(contentVersionIdSet.size() > 0) {
            
            //Content version initialisation.
            ContentVersion newCVersion = new ContentVersion();
            
            //Loop on the content version. 
            for(ContentVersion contentVersion : cVersions) {
                newCVersion.ContentDocumentId = contentVersion.ContentDocumentId;
                newCVersion.VersionData =  imageBlob; //TODO: NEEDS TO BE REPLACED WITH DATA RETURNED FROM CALLOUT
                cVersionsToBeUpdated.add(newCVersion); 
            }
        }
        
        //Checking the list size of content version.
        if(cVersionsToBeUpdated.size() > 0) {
            
            insert cVersionsToBeUpdated;
            
            //For loop on the site profile and update the Avatar_Content_Version_Id__c on Site Profile.
            for(Site_Profile__c sp : sProfiles) {
                sp.Avatar_Content_Version_Id__c = cVersionsToBeUpdated[0].Id;
            }   
        }
    }*/
    
    /**
     * @description:    register a new Site User
     * 
     **/
    public static SiteUser Action_Register(SiteUser sUser) {
        // bypass the siteProfileTrigger
        SiteProfileTriggerHelper.bypassSiteProfileTrigger = true;
        
        // if the email is null, return immediately
        if (sUser.Email_Address == null) {
            sUser.Response = 'Email address is required for Advisory.com Users';
            return sUser;
        }
        
        //duplicate profiles on other institutions with same username and site.
        //we must run this query seperate from 'dupeContacts' because subqueries must be at the top level of the where clause.
        string dupeConsByProfQryStr = 'SELECT Id FROM Contact WHERE Account.Organization_Id__c != ' + sUser.Organization_Id + ' AND Id IN '
            + ' (SELECT Contact__c FROM Site_Profile__c WHERE Username__c = \'' + String.escapeSingleQuotes(sUser.Email_Address) + '\' AND Type__c = \'' + sUser.Site + '\')';
        
        map<Id, Contact> dupeConsByProfile = new map<Id, Contact>((list<Contact>) database.query(dupeConsByProfQryStr) );
        set<Id> dupeConIdsByProfile = dupeConsByProfile.keySet();
        
        // contact that corresponds to adv user
        Contact conToUpdate;
        
        //Modified By Abhinav Sharma - 06/25/2018 - CR-20180605-12266 - Replace Email with Company_Email__c
        //v1.10 - Modified By - Mahendra Swarnkar - 4/27/2017 - CR-20170310-10747 - removing the user inputed single quotes in the Email address
        string queryString = CONTACTBASEQUERY +
                            ' WHERE Account.Organization_Id__c = ' + sUser.Organization_Id
                            + ' AND (Id IN :dupeConIdsByProfile'
                            + ' OR Company_Email__c = \''+ String.escapeSingleQuotes(sUser.Email_Address) + '\')';
        
        List<Contact> contacts =  database.query(queryString);
        
        String contactId;
        if (contacts.size() > 0) contactId = contacts[0].Id;
        // first name Last Name
        String sUserFullName = sUser.First_Name + ' ' + sUser.Last_Name;
        
        // check to make sure this isn't a duplicate
        string dupeContactsQryStr = 'SELECT Id, Email, (SELECT Id, Type__c, Status__c FROM Site_Profiles__r) FROM Contact '
            + 'WHERE Id != :contactId '
            + 'AND (Id IN :dupeConIdsByProfile OR (Account.Organization_Id__c = ' + sUser.Organization_Id + ' AND Name = :sUserFullName) )';
        List<Contact> dupeContacts = database.query(dupeContactsQryStr);
        
        if (dupeContacts.size() > 0) {
            if (dupeContacts[0].Site_Profiles__r.size() > 0 && dupeContacts[0].Site_Profiles__r[0].Status__c != null) {
                if (dupeContacts[0].Site_Profiles__r[0].Status__c.equalsIgnoreCase('Inactive') || dupeContacts[0].Site_Profiles__r[0].Status__c.equalsIgnoreCase('In Progress'))
                    sUser.Response = ERROR_EXISTING_INACTIVE_USER;
                else if (dupeContacts[0].Site_Profiles__r[0].Status__c.equalsIgnoreCase('Active'))
                    sUser.Response = ERROR_EXISTING_ACTIVE_USER;
            }
            else {
                sUser.Response = 'Duplicate Contact Found';
            }
            
            return sUser;
        }
        
        
        if (contacts.size() > 0) {
            
            // set the conToUpdate
            conToUpdate = contacts[0];
            
            // populate the sUser record from fields on the contact
            sUser = getSiteUser(contacts[0], sUser, true);
            if (sUser.site_Profile.Status__c != null && sUser.site_Profile != null && sUser.site_Profile.Status__c.toLowerCase().contains('inactive') && sUser.Site_Profile.Id != null) {
                sUser.Response = ERROR_EXISTING_INACTIVE_USER;
            }
            else if (sUser.site_Profile.Status__c != null && sUser.site_Profile != null && sUser.site_Profile.Status__c.toLowerCase().contains('active') && sUser.Site_Profile.Id != null) {
                sUser.Response = ERROR_EXISTING_ACTIVE_USER;
            }
            else if (sUser.site_Profile != null && sUser.Site_Profile.Id == null) { // the contact exists but is not an active user yet.
                
                // attempt to create the user
                string userCreationMessage = CreateNewUser(contacts[0], sUser, true, false);
                if (userCreationMessage.toLowerCase().contains('success')) {
                    sUser.Username = sUser.Email_Address; // set the username equal to email address so the getUser method returns the correct user
                    sUser = Action_GetUser(sUser, false);
                }
                else
                    sUser.Response = userCreationMessage;
            }
        }
        else {
            // attempt to create the user
            string userCreationMessage = CreateNewUser(sUser);
            if (userCreationMessage.toLowerCase() == 'success') {
                
                sUser.Username = sUser.Email_Address; // set the username equal to email address so the getUser method returns the correct user
                sUser = Action_GetUser(sUser, false);
                // get the newly created contact
                string qry = CONTACTBASEQUERY +
                    ' WHERE Id = \'' + sUser.UniqueId + '\'';
                List<Contact> cons = database.query(qry);
                // set the conToUpdate
                if (cons.size() > 0) {
                    conToUpdate = cons[0];
                }
                    
            }
            else
                sUser.Response = userCreationMessage;
        }
        
        // if the user was registered successfully, send a verification email to set their password
        if (sUser.Response != null && sUser.Response.equalsIgnoreCase('success')) {
            sUser.Command = 'sendNewUserEmail';
            SendVerificationEmail(conToUpdate, sUser);
            /* VH MS commented out on 7/30/14 because EAB/ADV will rely on SF as the only source of info
             * ContactTriggerUtilities.UpdateAdvUserFromContact(new list<Contact> { conToUpdate }, false);
             **/
        }
        else if (sUser.Response == null) {
            
            //Modified By Abhinav Sharma - 06/25/2018 - CR-20180605-12266 - Replace Email with Company_Email__c in the Query.
            // find whether the email is active or inactive
            List<Contact> dupeCons = [SELECT Id, Company_Email__c, (SELECT Id, Status__c, Type__c FROM Site_Profiles__r) FROM Contact WHERE Email = :sUser.Email_Address LIMIT 1];
            if (dupeCons.size() > 0) {
                for (Site_Profile__c sp : dupeCons[0].Site_Profiles__r) {
                    if (sp.Type__c == sUser.Site) {
                        if (dupeCons[0].Site_Profiles__r[0].Status__c == STATUS_ACTIVE || sp.Status__c == SiteProfileTriggerHelper.SITE_PROFILE_STATUS_IN_PROGRESS)
                            sUser.Response = ERROR_EXISTING_ACTIVE_USER;
                        else
                            sUser.Response = ERROR_EXISTING_INACTIVE_USER;
                    }
                }
            }
        }
        
        
        return sUser;
    }
    
    /**
     * @description:    send a password reset email
     *
     * @revision log:   Modified - 05/28/2019 - Victor Hanson - CR-20190520-13117 - return error response when org status <> active 
     **/
    public static SiteUser Action_SendPasswordResetEmail(SiteUser sUser) {
        // escape any single quotes
        string queryString = CONTACTBASEQUERY
            + ' WHERE Id IN (SELECT Contact__c FROM Site_Profile__c WHERE Username__c = \'' + string.escapeSingleQuotes(sUser.Username) + '\' ' 
            + ' AND Type__c = \'' + sUser.Site + '\')';
        List<Contact> contacts =  database.query(queryString);
        if (contacts.size() > 0) {
            Contact conToUpdate = contacts[0];
            // populate the sUser record from fields on the contact
            sUser = getSiteUser(contacts[0], sUser, true);
            
            //if there are errors, return the site user immediately
            if (hasErrors(contacts[0], sUser)) return sUser;
            
            // set this command so we know the request came from Adv.com which means we don't update the Verify flag or Status
            sUser.Command = 'sendPasswordResetEmail';
            
            //if there are no issues with the contact and site user, send the verification email and success response
            SendVerificationEmail(conToUpdate, sUser);
            sUser.Response = 'Success';
            
        }
        else {
            sUser.Response = 'invalid username';
        }
        return sUser;
    }
    
    /**
     * @description: check the site user for errors and update if necessary
     * 
     **/
    public static boolean hasErrors(Contact con, SiteUser sUser) {
        //validate that the site profile is eligible to have their password reset
        if (sUser.Email_Address == null || sUser.Email_Address == '') {
            sUser.Response = 'Invalid email address';
            return true;
        }
        else if (con.Contact_Status__c != null && con.Contact_Status__c.toLowerCase().contains('inactive')) {
            sUser.Response = 'Site Profile associated with an Inactive contact.';
            sUser.Status_Code = 'E2';
            sUser.Site_Profile.Status_Code__c = 'E2';
            return true;
        }
        //Modified By Abhinav Sharma - 06/25/2018 - CR-20180605-12266 - Replace Con.Email with con.Company_Email__c
        else if (sUser.Site_Profile.Status__c == SiteProfileTriggerHelper.SITE_PROFILE_STATUS_INACTIVE 
              || (sUser.Site_Profile.Status__c == SiteProfileTriggerHelper.SITE_PROFILE_STATUS_HARD_BOUNCE && sUser.Email_Address == con.Company_Email__c)) 
        { //status is inactive or hard bounce & email isn't being updated
            sUser.Response = 'User contains ' + sUser.Site_Profile.Status__c + ' status.';
            return true;
        }
        //Modified - 05/29/2019 - Victor Hanson - CR-20190520-13117 - do not return error when organization status is inactive
        /*
        else if (sUser.Organization_Status != null && sUser.Organization_Status.containsIgnoreCase('INACTIVE')) {
            sUser.Response = 'Organization status is inactive.';
            //update site profile so it contains the new status code
            update sUser.Site_Profile;
            return true;
        }*/
        
        //Check for domain eligibility
        map<Id, Account> acctMap = SiteProfileTriggerHelper.getAccountsWithEligibleDomains(new set<Id> { con.AccountId });
        boolean isEligible = hasEligibleDomain(acctMap.get(con.AccountId), sUser);
        if (!isEligible) {
            sUser.Response = ERROR_INVALID_DOMAIN;
            sUser.Status_Code = 'E2';
            sUser.Site_Profile.Status_Code__c = 'E2';
            update sUser.Site_Profile;
            return true;
        }
        
        return false;
    }
    
    /**
     * @description:    Return a list of Institutions based on the current site user.
     * 
     **/
    public static List<Account> FindInstitutions(SiteUser sUser) {
               
        Set<Id> rtIds = SiteUserHelper.validAccountRecordTypeIds;
        
        // build a custom where string to query
        String whereString = '';
        if (sUser.Org_Name != null && sUser.Org_Name != '') {
            if (whereString != '') whereString += ' AND ';
            whereString += 'Name LIKE \'%' + sUser.Org_Name + '%\'';
        }
         
        if (sUser.UniqueId != null && sUser.UniqueId != '')  {
            if (whereString != '') whereString += ' AND ';
            whereString += 'Historical_Linker__c LIKE \'%' + sUser.UniqueId + '%\'';
        }
        
        if (sUser.City != null && sUser.City != '') {
            if (whereString != '') whereString += ' AND ';
            whereString += 'Primary_City__c LIKE \'%' + sUser.City + '%\'';
        }
        
        if (sUser.State != null && sUser.State != '') {
            if (whereString != '') whereString += 'AND ';
            whereString += 'Primary_State_Province__c LIKE \'%' + sUser.State + '%\'';
        }
        
        if (sUser.Country != null && sUser.Country != '') {
            if (whereString != '') whereString += 'AND ';
            whereString += 'Primary_Country__c LIKE \'%' + sUser.Country + '%\'';
        }
        
        if (whereString != '') {
            
            //VH 05/17/2019: Added filter for only certain record types
            whereString += ' AND RecordTypeId IN :rtIds AND Status__c = \'Active\' AND Id IN (SELECT Account__c FROM Eligible_Domain__c) ';
            whereString = 'WHERE ' + whereString;
        }
        else {
            throw new customException('At least one of the following fields are required: Organization Name, UniqueId, City, State, Country');
        }
        
        Set<Id> accountIds = new Set<Id>();
        List<Account> accounts = database.query('SELECT Id, Organization_Id__c, Name, Primary_City__c, Account_Formal_Name__c, Primary_State_Province__c FROM Account ' + whereString + ' ORDER BY Name ASC LIMIT 700');
        
        return accounts;
    }
    
    /**
     * @description:    Return a Contact based on the Site User
     * 
     **/
    public static Contact ReturnContactFromSiteUser(Contact con, SiteUser sUser) {
        //con.Advisory_com_Modified_Date__c = system.now();
        
        // adv.com microsite fields
        if (sUser.LinkedIn != null)
            con.Advisory_com_LinkedIn__c = sUser.LinkedIn;
        if (sUser.Twitter != null)
            con.Advisory_com_Twitter__c = sUser.Twitter;
        if (sUser.PInterest != null)
            con.Advisory_com_PInterest__c = sUser.PInterest;
        if (sUser.NameTag != null)
            con.Advisory_com_Name_Tag__c = sUser.NameTag;
        if (sUser.OrganizationNameTag != null)
            con.Advisory_com_Organization_Name_Tag__c = sUser.OrganizationNameTag;
        if (sUser.Interests != null)
            con.Advisory_com_Interests__c = sUser.Interests;
        if (sUser.ShareInformation != null)
            con.Advisory_com_Share_Information__c = sUser.ShareInformation;
        if (sUser.ShareEmail != null)
            con.Advisory_com_Share_Email__c = sUser.ShareEmail;
        if (sUser.ShareFacebook != null)
            con.Advisory_com_Share_Facebook__c = sUser.ShareFacebook;
        if (sUser.ShareFax != null)
            con.Advisory_com_Share_Fax__c = sUser.ShareFax;
        if (sUser.SharePhone != null)
            con.Advisory_com_Share_Phone__c = sUser.SharePhone;
        if (sUser.ShareLinkedIn != null)
            con.Advisory_com_Share_LinkedIn__c = sUser.ShareLinkedIn;
        if (sUser.SharePInterest != null)
            con.Advisory_com_Share_PInterest__c = sUser.SharePInterest;
        if (sUser.ShareImage != null)
            con.Advisory_com_Share_Image__c = sUser.ShareImage;
        if (sUser.ShareTwitter != null)
            con.Advisory_com_Share_Twitter__c = sUser.ShareTwitter;
        if (sUser.ShareInterests != null)
            con.Advisory_com_Share_Interests__c = sUser.ShareInterests;
        
        if (sUser.Office_Phone != null) {
            con.Phone = sUser.Office_Phone;
            
        }
        
        if (sUser.Fax_Phone != null) {
            //con.Advisory_com_Fax_Phone__c = sUser.Fax_Phone;
            con.Fax = sUser.Fax_Phone;
        }
        
        if (sUser.Phone != null) {
            con.Phone = sUser.Phone;
            
        }
            
        if (sUser.Address1 != null) {
            con.Primary_Address_Line_1__c = sUser.Address1;
        }
            
        if (sUser.Address2 != null) {
            con.Primary_Address_Line_2__c = sUser.Address2;
            
        }
            
        if (sUser.Address3 != null) {
            con.Primary_Address_Line_3__c = sUser.Address3;
            
        }
            
        if (sUser.City != null) {
            
            con.Primary_City__c = sUser.City;
        }
            
        if (sUser.State != null) {
            
            con.Primary_State_Province__c = sUser.State;
        }
            
        if (sUser.Zip != null) {
            
            con.Primary_Postal_Code__c = sUser.Zip;
        }
            
        if (sUser.Country != null) {
            
            con.Primary_Country__c = sUser.Country;
        }
            
        if (sUser.Prefix != null) {
            
            con.Salutation = sUser.Prefix;
        }
            
        if (sUser.First_Name != null) {
            
            con.FirstName = sUser.First_Name;
        }
       
        if (sUser.Last_Name != null) {
            
            con.LastName = sUser.Last_Name;
        }
            
        if (sUser.Middle_Initial != null) {
            
            con.Middle_Name__c = sUser.Middle_Initial;
        }
            
        if (sUser.Suffix != null)
            con.Suffix__c = sUser.Suffix;
            
        if (sUser.Job_Function != null) 
            con.Management_Level__c = sUser.Job_Function;
        
        if (sUser.EAB_Role != null) 
            con.EAB_Role__c = sUser.EAB_Role;
            
        if (sUser.Title != null) {
            //con.Advisory_com_Title__c = sUser.Title;
            con.Title = sUser.Title;
        }
            
        if (sUser.Department != null)
            con.Function__c = sUser.Department;
        
        if (sUser.EAB_Department != null)
                con.EAB_Department__c = sUser.EAB_Department;
        
        //Added by Victor Hanson - 06/18/2019
        //Check for the Menu Custominzation. 
        if(String.isNotBlank(sUser.menuCustomization))
            sUser.site_Profile.Menu_Customizations__c = sUser.menuCustomization;
        
        
        //Added by Abhinav sharma - 06/27/2018 - CR-20180605-12266 - Updated the contact updation logic.  - Starts here.
        //Check for the Primary and Secondary email update Scenario on the EAB.Com site.
        if(sUser.Email_Address != null && con.Company_Email__c != sUser.Email_Address) {
            
            con.Company_Email__c = sUser.Email_Address;
        }
        
        //Check for the Secondary email update on the EAB.com Site - If the Secondary email update.
        if(String.isnotBlank(sUser.Email_Address2)  && con.Email != sUser.Email_Address2) {
          con.Email = sUser.Email_Address2;
            REUPDATE_SITE_PROFILE = true;
        }
        else if (con.Email == null && sUser.Email_Address != null) {
            con.Email = sUser.Email_Address;
        }
        //CR-20180605-12266 - Ends Here 
        
        if (sUser.Email_Address != null) {
            // VRH added 11/13/12
            //Modified By Abhinav Sharma - 06/25/2018 - CR-20180605-12266 - Replace Con.Email with con.Company_Email__c
            if(con.Company_Email__c != sUser.Email_Address && sUser.Email_Address != null && con.Company_Email__c != null) {
                // verify the email address isn't in use on another account
                List<Contact> consWithSameEmail = [SELECT Id, Name, Company_Email__c FROM Contact WHERE Id != :con.Id AND Company_Email__c = :sUser.Email_Address];
                // if contacts are found, return the contact immediately without updating the email address.
                if (consWithSameEmail.size() > 0) {
                    for (Contact c : consWithSameEmail) {
                        for (Site_Profile__c sp : c.Site_Profiles__r) {
                            if (sp.Type__c == sUser.Site) {
                                //throw new customException('An Advisory.com User with that email address already exists:' + sUser.Email_Address);
                                if (sp.Status__c == STATUS_ACTIVE || sp.Status__c == SiteProfileTriggerHelper.SITE_PROFILE_STATUS_IN_PROGRESS)
                                    throw new customException(ERROR_EXISTING_ACTIVE_USER);
                                else
                                    throw new customException(ERROR_EXISTING_INACTIVE_USER);
                            }
                        }
                    }
                }
                // send verificatoin email
                String advUniqueId = FindUniqueId(con, sUser);
                
                // delete the existing password
                sUser.site_Profile.Password__c = null;
                sUser.Password = null;
                
                // generate the password reset url
                string pwResetURL = CreatePWResetURL(sUser, advUniqueId);
                sUser.site_Profile.Password_Reset_Token__c = pwResetURL;
                sUser.site_Profile.Send_Password_Notification__c = SiteProfileTriggerHelper.NOTIFICATION_TYPE_EMAIL_CHANGE;
                setVerificationStatus(con, sUser);
            }
            
            if (sUser.site_Profile == null) sUser.site_Profile = createNewSite_Profile(con, sUser, null);
            //Modified By Abhinav Sharma - 06/25/2018 - CR-20180605-12266 - Replace Con.Email with con.Company_Email__c
            sUser.site_Profile.Username__c = sUser.Email_Address;
            con.Company_Email__c = sUser.Email_Address;
            con.Member_Verified_Date__c = Date.today();
            
        }
        
        //Updated by Ajit Surana - 02/13/2014 - CR-20131205-4086
        //Check if Advisory.com User password is not Null and is not equal to contact corresponds to Advisory.com User
        if (sUser.Password != null && sUser.Password != '' && sUser.Password != sUser.site_Profile.Password__c) {
            
            if (sUser.site_Profile == null) {
                
                //check to see if a new site user should be created
                if (sUser.site_User == null) {
                    //upsert a new Site_User
                    sUser.site_User = createNewSite_User(true);
                }
                
                //upsert the new site profile
                sUser.site_Profile = createNewSite_Profile(con, sUser, sUser.site_User.Id);
            }
            
            //point the contact to the newly created site user
            con.Site_User__c = sUser.site_User.Id;
            
            // update the password
            sUser.site_Profile.Password__c = sUser.Password;
            
            // when the password is updated, as long as verify != 4, change the verification date to today and set the verification flag to 2
            if (sUser.site_Profile.Verify__c != '4') {
                
                //Spring clean up - con.Advisory_com_Verify_Date__c = system.Now();
                sUser.site_Profile.Verify_Date__c = system.Now();
                sUser.site_Profile.Verify__c = '2';
                sUser.site_Profile.Status__c = SiteProfileTriggerHelper.SITE_PROFILE_STATUS_ACTIVE;
                
                sUser.Verify = '2';
                sUser.User_Status = SiteProfileTriggerHelper.SITE_PROFILE_STATUS_ACTIVE;
                sUser.site_Profile.Status_Code__c = getStatusCode(sUser);
            }
        }
        
        // Modified By - Ajit Surana - 05/06/2015-  CR-20150414-8872 
        // Start from here
        //if (sUser.User_Status != null && sUser.site_Profile.Type__c == SiteUserHelper.SITE_ADVISORY) {
            //con.Advisory_com_User_Status__c = sUser.User_Status;
        //}
        //Upto here
            
        return con;
    }
    
    /**
     * @description:    
     * 
     **/
  @TestVisible
  private static Contact ReturnContactFromSiteUser_NoAdvAccount(Contact con, SiteUser sUser) {
        con.Phone = sUser.Office_Phone;
        con.Fax = sUser.Fax_Phone;
        con.Phone = sUser.Phone;
        
        con.Primary_Address_Line_1__c = sUser.Address1;
        con.Primary_Address_Line_2__c = sUser.Address2;
        con.Primary_Address_Line_3__c = sUser.Address3;
        con.Primary_City__c = sUser.City;
        con.Primary_State_Province__c = sUser.State;
        con.Primary_Postal_Code__c = sUser.Zip;
        con.Primary_Country__c = sUser.Country;
        con.Salutation = sUser.Prefix;
        con.FirstName = sUser.First_Name;
        con.LastName = sUser.Last_Name;
        con.Middle_Name__c = sUser.Middle_Initial;
        con.Title = sUser.Title;
        //con.Advisory_com_Preferred_Email_Address__c = sUser.Email_Address2;
        con.Function__c = sUser.Department;
        con.EAB_Department__c = sUser.EAB_Department;
        con.EAB_Role__c = sUser.EAB_Role;
        con.Management_Level__c = sUser.Job_Function;
         
        //Modified By Abhinav Sharma - 06/25/2018 - CR-20180605-12266 - Replace Con.Email with con.Company_Email__c
        // if the email is changed, update email and username
        if (con.Company_Email__c != sUser.Email_Address && sUser.Site_Profile.Username__c != null)
            sUser.Site_Profile.Username__c = sUser.Email_Address;
        
        if (sUser.Role != null) {
            /*if (sUser.Site == SiteUserHelper.SITE_ADVISORY)
                con.Advisory_com_Role__c = sUser.Role;
            else*/ if (sUser.Site == SiteUserHelper.SITE_EAB)
                con.EAB_Role__c = sUser.Role;
        }
        
        con.Company_Email__c = sUser.Email_Address;
        if (con.Email == null) con.Email = sUser.Email_Address;
        con.Nickname__c = sUser.Nickname;
        con.MobilePhone = sUser.Mobile;
        con.Record_Type__c = sUser.ContactRecordType;
        con.Secondary_Address_Name__c = sUser.SecondaryAddressName;
        con.Secondary_Address_Line_1__c = sUser.SecondaryAddress1;
        con.Secondary_Address_Line_2__c = sUser.SecondaryAddress2;
        con.Secondary_Address_Line_3__c = sUser.SecondaryAddress3;
        con.Secondary_City__c = sUser.SecondaryCity;
        con.Secondary_State_Province__c = sUser.SecondaryState;
        con.Secondary_Postal_Code__c = sUser.SecondaryPostalCode;
        con.Secondary_Country__c = sUser.SecondaryCountry;
        con.Description = sUser.Description;
        con.AccountId = sUser.AccountId;
        con.HasOptedOutOfEmail = sUser.EmailOptOut;
        con.AssistantName = sUser.Assistant;
        con.AssistantPhone = sUser.AssistantPhone;
        con.Asst_Email__c = sUser.AssistantEmail;
        con.ReportsToId = sUser.ReportsToId;
        con.Previous_Institution_Record__c = sUser.PrevAccountId;
            
        return con;
    }
    
    /**
     * @description:    return the advisory site settings custom setting.
     * 
     **/
   //Commented out the code as to delete Advisory_com_Site__c custom setting - by Mahendra swarnkar - CR-20140811-6954 - 09/04/2015
   /* public static Advisory_com_Site__c AdvisorySiteSettings {
        get {
            if (AdvisorySiteSettings == null) {
                AdvisorySiteSettings = Advisory_com_Site__c.getInstance();
            }
            return AdvisorySiteSettings;
        }
        set;
    }
    */
    
    /**
     * @description:    updates a contact's info from a site user request
     * 
     **/
    private static String UpdateContactFromSiteUser(Contact conToUpdate, SiteUser sUser) {
        String retString = '';
        try {
            List<Contact> potentialDuplicates = new List<Contact>();
            // replace any single quotes
            sUser.Email_Address = sUser.Email_Address.replace('\\\'', '\'');
            if(sUser.Email_Address2 != null)
              sUser.Email_Address2 = sUser.Email_Address2.replace('\\\'', '\'');
            // see if there is already an active user with that email address
            // Updated the Query By Abhinav Sharma- CR-20180605-12266 - to add the Email check scenario where secondary email has changed.
            if ((sUser.Email_Address != null)){
                
                //Check if primary Email is changed
                if(sUser.Email_Address != conToUpdate.Company_Email__c) {
                  potentialDuplicates = [SELECT Id, Create_Advisory_com_User_Account__c, Company_Email__c,Email FROM Contact WHERE Company_Email__c = :sUser.Email_Address];                
                }
                
                //Check for the Secondary Email cASE  
                if(String.isNotBlank(sUser.Email_Address2) && sUser.Email_Address2 != conToUpdate.Email) {
                  potentialDuplicates = [SELECT Id, Create_Advisory_com_User_Account__c, Company_Email__c, Email FROM Contact WHERE Email = :sUser.Email_Address2 AND Email != null];                
          }
                
                if (potentialDuplicates.size() >0) {
                    if (potentialDuplicates[0].Create_Advisory_com_User_Account__c == true)
                        return ERROR_EXISTING_ACTIVE_USER;
                    else
                        return ERROR_EXISTING_INACTIVE_USER;
                }
            }
                           
            //keep the original email
            string originalEmail = conToUpdate.Company_Email__c;
            
            // try to synchronize contact with sUser data and return contact without upserting immediately
            try {
                // this is an existing contact
                conToUpdate = ReturnContactFromSiteUser(conToUpdate, sUser);
            }
            catch(Exception ex) {
                if (ex.getMessage().contains(ERROR_EXISTING_ACTIVE_USER))
                    return ERROR_EXISTING_ACTIVE_USER;
                else if (ex.getMessage().contains(ERROR_EXISTING_INACTIVE_USER))
                    return ERROR_EXISTING_INACTIVE_USER;
                else
                    return 'Error:' + ex.getMessage();
            }
            
            update conToUpdate;
            
            //only update the site profile if the email address wasn't changed.
            //because when the email changes, Contact has to be updated first and the contact trigger updates all related site profiles and sent the necessary emails
            if (originalEmail == sUser.site_profile.Username__c  && !REUPDATE_SITE_PROFILE)
                update sUser.site_Profile;
            
            REUPDATE_SITE_PROFILE = false;
            retString = 'Success';   
        }
        catch(Exception ex) {
            retString = ex.getMessage() + '  ' + ex;
        }
        return retString;
    }
    
    /**
     * @description:    create the new Site User
     * 
     **/
    private static String CreateNewUser(SiteUser sUser) {
        String retVal = '';
        
        try {
            
            // get the contact's Account info
            string acctsQryStr = 'SELECT Name, Id,'
                                 + '(Select Id, Qualified_Domain__c, Is_Included__c FROM Eligible_Domains__r)'
                                 + 'FROM Account WHERE Account.Organization_Id__c = ' + sUser.Organization_Id;
            List<Account> accts = database.query(acctsQryStr);
            
            if (accts.size() > 0) {
                Account acct = accts[0];
                boolean isEligible = hasEligibleDomain(acct, sUser);
                
                // if this is not an eligible user, immediately send back the error
                if (!isEligible)
                    return ERROR_INVALID_DOMAIN;
                                    
                // create a new contact
                Contact conToUpdate = new Contact(AccountId = acct.Id);
                
                try {
                    // this is an existing contact
                    conToUpdate = ReturnContactFromSiteUser(conToUpdate, sUser);
                    // set some default values on the contact
                    conToUpdate = UpdateDefaultUserSettings(conToUpdate, sUser);
                    // CR-3304
                    conToUpdate.OwnerId = Label.Salesforce_Admin_Id;
                    conToUpdate.Contact_Status__c = 'Active';
                }
                catch(Exception ex) {
                    if (ex.getMessage().contains(ERROR_EXISTING_ACTIVE_USER))
                        return ERROR_EXISTING_ACTIVE_USER;
                    else if (ex.getMessage().contains(ERROR_EXISTING_INACTIVE_USER))
                        return ERROR_EXISTING_INACTIVE_USER;
                    else
                        return 'Error:' + ex.getMessage() + '   StackTrace:' + ex.getStackTraceString();
                }
                
                // make sure the uniqueId is present
                String advUniqueId = FindUniqueId(conToUpdate, sUser);
                
                if (advUniqueId.toLowerCase().contains('error'))
                    retVal = advUniqueId;
                else
                    retVal = 'Success';
                
            }
            else {
                retVal = 'error: there is no account with the Organization Id ' + sUser.Organization_Id;
            }
            
        } catch(Exception ex) {
            // return the proper error message
            retVal = CreateErrorResponse(ex);
        }
        
        return retVal;
    }
    
    /**
     * @description:    create the new Site User
     * 
     **/
    public static String CreateNewUser(Contact conToUpdate, SiteUser sUser, boolean CreateAndInsert, boolean SendNewUserEmail) {
        String retVal = '';
        
        try {
            
            List<Contact> potentialDuplicates = new List<Contact>();
            // see if there is already an active user with that email address
            if (sUser.Email_Address != null && sUser.Email_Address != conToUpdate.Company_Email__c) {
                potentialDuplicates = [SELECT Id, Company_Email__c FROM Contact WHERE Company_Email__c = :sUser.Email_Address];
                if (potentialDuplicates.size() >0) {
                    if (potentialDuplicates[0].Create_Advisory_com_User_Account__c == true)
                        return ERROR_EXISTING_ACTIVE_USER;
                    else
                        return ERROR_EXISTING_INACTIVE_USER;
                }
            }
            
            // get the contact's Account info to check if the domain is valid
            string acctsQryStr = 'SELECT Name, Id,'
                                 + '(Select Id, Qualified_Domain__c, Is_Included__c FROM Eligible_Domains__r)'
                                 + 'FROM Account WHERE Organization_Id__c = ' + sUser.Organization_Id;
            List<Account> accts = database.query(acctsQryStr);
            
            if (accts.size() > 0 && conToUpdate.Bypass_Domain_Validation__c == false) {
                boolean isEligible = hasEligibleDomain(accts[0], sUser);
                // if this is not an eligible user, immediately send back the error
                if (!isEligible)
                    return ERROR_INVALID_DOMAIN;
            }
            
            try {
                // this is an existing contact
                conToUpdate = ReturnContactFromSiteUser(conToUpdate, sUser);
                // set some default values on the contact
                conToUpdate = UpdateDefaultUserSettings(conToUpdate, sUser);
                conToUpdate.Contact_Status__c = 'Active';
            }
            catch(Exception ex) {
                if (ex.getMessage().contains(ERROR_EXISTING_ACTIVE_USER))
                    return ERROR_EXISTING_ACTIVE_USER;
                else if (ex.getMessage().contains(ERROR_EXISTING_INACTIVE_USER))
                    return ERROR_EXISTING_INACTIVE_USER;
                else
                    return 'Error:' + ex.getMessage();
            }
            
            /* VRH added 11/15/12
            if (SendNewUserEmail) {
                // make sure the uniqueId is present
                String advUniqueId = FindUniqueId(conToUpdate, sUser);
                
                // set the password reset URL
                string pwResetURL = CreatePWResetURL(sUser, advUniqueId);
                conToUpdate.Advisory_com_Send_Password_Notification__c = 'New User';
                conToUpdate.Advisory_com_Password_Reset_Token__c = pwResetURL;
            }
            */
            
            if (CreateAndInsert) {
                
                //Modified By Bhavi Sharma - 04/05/2014 - CR-20140204-4450
                //Exeute Contact triggers so restriction status can be updated on contact from related account
                Util.BypassAllTriggers = false;
                
                //upsert the Site_User
                if (sUser.site_User == null) {
                        sUser.site_User = createNewSite_User(true);
                    
                    
                }
                
                //Sync the Contact's Site User with the Site Profile's Site User
                if (conToUpdate.Site_User__c == null && sUser.site_User != null) {
                    conToUpdate.Site_User__c = sUser.site_User.Id;
                }
                
                //upsert the contact
                upsert conToUpdate;
                
                //upsert the new site profile
                sUser.site_Profile = createNewSite_Profile(conToUpdate, sUser, sUser.site_User.Id);
                insert sUser.site_Profile;
            }
            

            retVal = 'Success';
            
        } catch(Exception ex) {
            // return the proper error message
            retVal = CreateErrorResponse(ex);
        }
        
        return retVal;
    }
    
    /**
     * @description:    based on the contact and sUser details, determine if this is an eligible user
     * 
     **/
    public static boolean hasEligibleDomain(Account acct, SiteUser sUser) {
        
        boolean isEligible = true;
        
        if (sUser.Email_Address != null && sUser.Bypass_Domain_Validation == false) {
            
            isEligible = hasEligibleDomain(acct, sUser.Email_Address);
        }
        
        return isEligible;
    }
    
    /**
     * @description:    based on email address, determine if this is an eligible user
     * 
     **/
    public static boolean hasEligibleDomain(Account acct, string email) {
        
        boolean isEligible = false;
        
        if (email != null && acct != null) {
            
            // get the email domain
            String emailDomain = email.split('@')[1];
            emailDomain = emailDomain.toLowerCase();
            
            for (Eligible_Domain__c domain : acct.Eligible_Domains__r) {
                
                // turn eligible domain to all lower case
                domain.Qualified_Domain__c = domain.Qualified_Domain__c.toLowerCase();
                if (domain.Is_Included__c == true && emailDomain == domain.Qualified_Domain__c.toLowerCase()) {
                    isEligible = true;
                    break;
                }
            }
        }
        
        return isEligible;
    }
    
    /**
     * @description:    set the contact's verification status back to in progress
     * 
     **/
    public static void setVerificationStatus(Contact con, SiteUser sUser) {
        
        sUser.Site_Profile = setVerificationStatus(con, sUser.Site_Profile);
        sUser.Verify = '1';
        sUser.User_Status = SiteProfileTriggerHelper.SITE_PROFILE_STATUS_IN_PROGRESS;
        getStatusCode(sUser);
    }
    
    /**
     * @description:    set the contact's verification status back to in progress.
     * 
     **/
    public static Site_Profile__c setVerificationStatus(Contact con, Site_Profile__c sProfile) {
        
        //New condition added - Bhavi Sharma - CR-20130523-3072 - 09/18/2013
        //Check if contact Status contains Inactive, then do nothing
        if((con.Contact_Status__c != null && con.Contact_Status__c.containsIgnoreCase('Inactive'))
            || (sProfile.Status__c != null && sProfile.Status__c.containsIgnoreCase('Inactive')) )
            return sProfile;
            
        // if verify = 4, return the contact with status = 'Active' without updating the verification status
        if (sProfile.Verify__c == '4') {
            sProfile.Status__c = SiteProfileTriggerHelper.SITE_PROFILE_STATUS_ACTIVE;
            return sProfile;
        }
        
        sProfile.Verify__c = '1';
        sProfile.Verify_Date__c = null;
        sProfile.Status__c = SiteProfileTriggerHelper.SITE_PROFILE_STATUS_IN_PROGRESS;
        sProfile.Password__c = null;
        
        //get the site user
        SiteUser sUser = new SiteUser();
        sUser.User_Status = sProfile.Status__c;
        sUser.Bypass_Domain_Validation = sProfile.Bypass_Domain_Validation__c;
        sUser.Verify = sProfile.Verify__c;
        sUser.Email_Address =  con.Company_Email__c;
        sUser.UniqueId = sProfile.Id;
        sUser.Site = sProfile.Type__c;
        sUser.Site_Profile = sProfile;
        
        if (sUser.Site != null && sUser.Site.containsIgnoreCase(SITE_EAB)) {
            sUser.Organization_Status = con.Account.EAB_com_Organization_Status__c;
        }
        
        //update the status
        sProfile.Status_Code__c = getStatusCode(sUser);
          
        return sProfile;
    }
    
    /**
     * @description:    update the default user settings on the contact and site profile.
     * 
     **/
    public static Contact UpdateDefaultUserSettings(Contact con, SiteUser sUser) {
        
        //update the Contact's advisory fields if the site profile is Advisory
        if (sUser.Site == SiteUserHelper.SITE_ADVISORY) {
            //SC - con.Advisory_com_Created_Date__c = system.now();
            con.Create_Advisory_com_User_Account__c = true;
            /*if (SiteControllerHelper.IsGuestUser) {
                con.Advisory_com_Created_By__c = sUser.Email_Address;
            }
            else {
                con.Advisory_com_Created_By__c = UserInfo.getName();
            }*/
        }
        
        if (sUser.Password != null && trigger.isExecuting && trigger.isInsert) {
            system.debug('@@@Password:' + sUser.Password);
        }
        else {
            // set the verification settings
            setVerificationStatus(con, sUser);
        }
        
        //set the verify field on sUser to match what's on the SiteProfile
        sUser.Verify = sUser.Site_Profile.Verify__c;
        sUser.User_Status = sUser.Site_Profile.Status__c;
        
        // set the External record type id
        Id externalRTId = Util.RecordTypeId('Contact', 'External - Site User');
        Id employeeRTId = Util.RecordTypeId('Contact', 'Employee');
        if (con.RecordTypeId != employeeRTId)
            con.RecordTypeId = externalRTId;
        
        return con;
    }
    
    /**
     * @description:    Determine if the Contact has been changed for a Membership Key Contact record.
     * 
     **/
    public static boolean ContactHasChanged(Membership_Key_Contact__c newKeyContact, Membership_Key_Contact__c oldKeyContact) {
        if (oldKeyContact == null || (newKeyContact.Contact__c != oldKeyContact.Contact__c))
            return true;
        
        return false;
    }
    
    /**
     * @description:    create special payload in the format: sUser.PasswordResetURL/?payload=ValidUntil=2014-01-01T10:10:00&Email=sunj@advisory.com
     * 
     **/
    public static String CreatePWResetURL(SiteUser sUser, String user_Id) {
        
        // get specially formatted date
        String dtString = dateTime.now().addDays(3).format('yyyy-MM-dd HH:mm:ss');
        dtString = dtString.replace(' ', 'T');
        
        // make sure the unique id is not null
        if (user_Id == null && sUser.User_Id != null)
            user_Id = string.valueOf(sUser.User_Id);
        
        // make sure that the email address is only escaped once
        if(sUser.Email_Address != null)
        sUser.Email_Address = sUser.Email_Address.replace('\\\'', '\'');
        
        // first create the encrypted payload (ie: ValidUntil=2014-01-01T10:10:00&Email=sunj@advisory.com)
        string payload = 'ValidUntil=' + dtString + '&Email=' + sUser.Email_Address + '&UniqueId=' + user_Id;
        
        // get the password reset custom setting
        String pwResetURL;
        if (sUser.PasswordResetUrl != null) 
            pwResetURL = sUser.PasswordResetUrl;
        else if (sUser.Site != null && sUser.Site.equalsIgnoreCase(SITE_EAB))
            pwResetURL = sitecoreSettings.EAB_Password_Reset_URL__c;
        else if (sUser.Site != null && sUser.Site == SITE_Advisory) 
            pwResetURL = sitecoreSettings.Advisory_Password_Reset_URL__c;
        else 
            pwResetURL = sitecoreSettings.Advisory_Password_Reset_URL__c;
        
        // encrypt + urlEncode the payload
        payload = EncryptionHelper.encryptString(payload);
        pwResetURL += '?payload=' + EncodingUtil.urlEncode(payload, 'UTF-8');
        return pwResetURL;
    }
    
    
    public static void SendVerificationEmail(Contact con, SiteUser sUser) {
        SendVerificationEmail(con, sUser, true, true);
    }
    
    public static void SendVerificationEmail(Contact con, Site_Profile__c sProfile, string verificationType, boolean updateSiteProfile) {
        
       
        //set the verification status
        if (sProfile.Verify__c != '4') {
            sProfile.Verify__c = '1';
            sProfile.Verify_Date__c = null;
            sProfile.Status__c = SiteProfileTriggerHelper.SITE_PROFILE_STATUS_IN_PROGRESS;
        }
        
        //Modified By Abhinav Sharma - 06/25/2018 - CR-20180605-12266 - Replace Con.Email with con.Company_Email__c
        //get the site user, set the verificaiton type, and call the method to send the verificationemail
        SiteUser sUser = new SiteUser();
        sUser.User_Status = sProfile.Status__c;
        sUser.Bypass_Domain_Validation = sProfile.Bypass_Domain_Validation__c;
        sUser.Verify = sProfile.Verify__c;
        sUser.Email_Address =  con.Company_Email__c;
        
        if (sProfile.User_Id_Override__c != null)
            sUser.User_Id = integer.valueOf(sProfile.User_Id_Override__c);
        else
            sUser.User_Id = integer.valueOf(sProfile.User_Id__c);
        
        if (sProfile.Type__c.containsIgnoreCase(SITE_EAB)) {
            sUser.Organization_Status = con.Account.EAB_com_Organization_Status__c;
        }
        else if (sProfile.Type__c.containsIgnoreCase(SITE_ADVISORY)) {
            sUser.Organization_Status = con.Account.Advisory_com_Organization_Status__c;
        }
        
        sUser.UniqueId = sProfile.Id;
        sUser.Site = sProfile.Type__c;
        sUser.Site_Profile = sProfile;
        sUser.Command = verificationType;
        sendVerificationEmail(con, sUser, updateSiteProfile, false);
    }
    
    /**
     * @description:    send a verification email to the newly registered user to reset their password
     * 
     **/
    public static void SendVerificationEmail(Contact con, SiteUser sUser, boolean updateSiteProfile, boolean setVerificationStatus) {
        
        
        String advUniqueId = FindUniqueId(con, sUser);
	
        // if this is a password reset, set the contact flags
        if (con != null && verificationIdSet.contains(sUser.UniqueId) == false) {
            
            // get the latest contact
            string pwResetURL = CreatePWResetURL(sUser, advUniqueId);
            
            // update the verify flag on contact and remove the verification date
            if (sUser.Command.equalsIgnoreCase('sendPasswordResetEmail')) {
                sUser.site_Profile.Send_Password_Notification__c = SiteProfileTriggerHelper.NOTIFICATION_TYPE_PASSWORD_RESET;
            }
            else if (sUser.Command.equalsIgnoreCase('sendNewEmailVerification')) {
                sUser.site_Profile.Send_Password_Notification__c = SiteProfileTriggerHelper.NOTIFICATION_TYPE_EMAIL_CHANGE;
            }
            else if (sUser.Command.equalsIgnoreCase('sendNewUserEmail')) {
                sUser.site_Profile.Send_Password_Notification__c = SiteProfileTriggerHelper.NOTIFICATION_TYPE_NEW_USER;
            }
            else if (sUser.site_Profile.Send_Password_Notification__c == null){
                sUser.site_Profile.Send_Password_Notification__c = SiteProfileTriggerHelper.NOTIFICATION_TYPE_PASSWORD_RESET;
            }
            
	    if (setVerificationStatus)
                setVerificationStatus(con, sUser);
            
            sUser.site_Profile.Password_Reset_Token__c = pwResetURL;
            SiteUserHelper.getStatusCode(sUser);
            
            //v1.11 - Modified By - Mahendra Swarnkar - 07/06/2017 - CR-20170524-10956 - Commented the method "createAccountAndContactSharing".
            // update the site profile
            //CR-20140911-7334 - Added By Bhavi : 10/30/2014 - Create a sharing record for user
            //CR-20150330-8821 - Added By VH : 11/4/2015 - Only add sharing record for users that do not have dataloader or sfadmin profiles
            /*if (userinfo.getProfileId() != Label.ABC_Dataloader_Profile_Id && userinfo.getProfileId() != Label.System_Admin_Profile_Id) {
                createAccountAndContactSharing(con);
            }
            */
            //v1.11 - Modified By - Mahendra Swarnkar - 07/06/2017 - CR-20170524-10956 - Commented the method "createAccountAndContactSharing". - Ends here
            
            //add the site profile id to the set of ids we have sent verification emails to
            verificationIdSet.add(sUser.UniqueId);
        }
        
        //Added By Abhinav Sharma - CR-20170609-10984 - 12/26/2018 - Take this out from the above if condition. 
        if (updateSiteProfile) {
            update sUser.site_Profile;
        }
    }
    
    /**
     * @description:    Find the User Id for the Site User.
     * 
     **/
    public static String FindUniqueId(Contact con, SiteUser sUser) {
        String advUniqueId;
        Site_Profile__c siteProfile;
        // get the advisory.com unique id and set it for the contact
        if (sUser.UniqueId == null && con != null) {
            
            if (sUser.UniqueId == null || (sUser.site_Profile == null && sUser.site_User == null)) {
                try {
                    
                    con.Company_Email__c = con.Company_Email__c.replace('\\\'', '\'');
                    // upsert the contact and find the unique id
                    
                    //create the new site user & profile if they do not already exist
                    if (sUser.site_User == null) {
                        if (con.Site_User__c != null) {
                            sUser.site_User = new Site_User__c(Id = con.Site_User__c);
                        }
                        else {
                            sUser.site_User = createNewSite_User(false);
                        }
                    }
                    upsert sUser.site_User;
                    
                    //Modified By Bhavi Sharma - 04/05/2014 - CR-20140204-4450
                    //Exeute Contact triggers so restriction status can be updated on contact from related account
                    Util.BypassAllTriggers = false;
                    con.Site_User__c = sUser.site_User.Id;
                    upsert con;
                    
                    if (sUser.site_Profile == null)
                        sUser.site_Profile = createNewSite_Profile(con, sUser, sUser.site_User.Id);
                    sUser.site_Profile.Contact__c = con.Id;
                    upsert sUser.site_Profile;
                    
                    siteProfile = [SELECT Id, User_Id__c FROM Site_Profile__c WHERE Id = :sUser.site_Profile.Id];
                }
                catch(Exception ex) {
                    // return the proper error message
                    return CreateErrorResponse(ex);
                }
            }
            sUser.UniqueId = siteProfile.Id;
            sUser.User_Id = integer.valueOf(siteProfile.User_Id__c);
        }
        return string.valueOf(sUser.User_Id);
    }
    
    /**
     * @description:    create a user-friendly error response.
     * 
     **/
    private static String CreateErrorResponse(Exception ex) {
        // try to determine if the error is from dupeblocker
        if (ex.getMessage().toLowerCase().contains('potential duplicate'))
            return ERROR_EXISTING_INACTIVE_USER;
        else // otherwise return the actual error message
            return 'error:' + ex.getMessage() + '   StackTrace:' + ex.getStackTraceString();
    }
    
    /**
     * @description:    create webconference record and send confirmation.
     * 
     **/
    public static SiteUser Action_SendWebConferenceConfirmation(SiteUser sUser) {
        
        try {
            
            // create a new Web Conference
            Web_Conference__c webConference = CreateWebConference(sUser);
            
            // only insert if its not a duplicate
            //if (!sUser.HasRegisteredAlready)
            upsert webConference;
            
            // if we got here, send successful response
            sUser.Response = 'Success';
        }
        catch(Exception ex) {
            sUser.Response = 'Error:' + ex.getMessage() + '   StackTrace:' + ex.getStackTraceString();
        }
        
        return sUser;
    }
     
    /**
     * @description:    create a new meeting utilization record based on the webConference object.
     * 
     **/
    public static Web_Conference__c CreateWebConference(SiteUser sUser) {
        Web_Conference__c webConference = new Web_Conference__c();
        Map<String, Contact> sProfileIdToContactMap = FindSiteUserContacts(sUser.Attendee.User_Id, sUser.RegisteredBy.User_Id);
        
        if (sUser.Attendee.User_Id != null || sUser.Attendee.Email != null) {
            // find original Web Conference if this is an update
            try {
                Contact contactAttendee;
                if (sProfileIdToContactMap != null && sProfileIdToContactMap.size() > 0)
                    contactAttendee = sProfileIdToContactMap.get(sUser.Attendee.User_Id);
                
                // build the query string based on the info we have about the attendee
                String queryString = 'SELECT Id FROM Web_Conference__c WHERE Event_Name__c = \'' + sUser.WebEvent.Name + '\'  AND Canceled__c = false AND ';
                if (contactAttendee != null) {
                    queryString += 'Advisory_com_Attendee_User__c = \'' + contactAttendee.Id + '\'';
                }
                else
                    //v1.10 - Modified By - Mahendra Swarnkar - 4/27/2017 - CR-20170310-10747 - removing the user inputed single quotes in the Email address
                    queryString += 'Attendee_Email__c = \'' + string.escapeSingleQuotes(sUser.Attendee.Email) + '\'';
                
                List<Web_Conference__c> webConferences = database.query(queryString);
                    
                if (webConferences.size() > 0)
                    webConference = webConferences[0];
            }
            catch(Exception ex) {
                //throw new customException('No Advisory.com User with Id:' + sUser.Attendee.User_Id);
            }
        }
        
        // enter the general event info
        integer GMTtoET = 5;
        webConference.Start_Date__c = DateTime.parse(sUser.WebEvent.StartDate).addHours(GMTtoET);
        webConference.End_Date__c = DateTime.parse(sUser.WebEvent.EndDate).addHours(GMTtoET);
        webConference.Event_Name__c = sUser.WebEvent.Name;
        webConference.Event_URL__c = sUser.WebEvent.Url;
        webConference.Site__c = sUser.Site;
        if (sUser.WebEvent.IsCanceled != null) WebConference.Canceled__c = sUser.WebEvent.IsCanceled;
        if (sUser.WebEvent.Origin != null) WebConference.Canceled_By__c = sUser.WebEvent.Origin;
        if (sUser.RegisterOther != null) webConference.Register_Other__c = sUser.RegisterOther;
        
        // get the site profile ids of the attendee and register user
        if (sProfileIdToContactMap != null && sUser.Attendee.User_Id != null && sUser.Attendee.User_Id != '') {
            try {
                Contact attendeeContact = sProfileIdToContactMap.get(sUser.Attendee.User_Id);
                if (attendeeContact != null && attendeeContact.Site_Profiles__r != null) {
                    webConference.Advisory_com_Attendee_User__c = attendeeContact.Id;
                    for (Site_Profile__c sp : attendeeContact.Site_Profiles__r) {
                        if (sp.Type__c.equalsIgnoreCase(sUser.Site)) {
                            webConference.Attendee_Site_Profile__c = sp.Id;
                        }
                    }
                }
            }
            catch(Exception ex) {
                throw new customException('No Site Profile with Id:' + sUser.Attendee.User_Id + ex.getStackTraceString());
            }
        }
        
        if (sProfileIdToContactMap != null && sUser.RegisteredBy.User_Id != null && sUser.RegisteredBy.User_Id != '') {
            try {
                Contact registeredByContact = sProfileIdToContactMap.get(sUser.RegisteredBy.User_Id);
                webConference.Advisory_com_Registered_By_User__c = registeredByContact.Id;
                for (Site_Profile__c sp : registeredByContact.Site_Profiles__r) {
                    if (sp.Type__c.equalsIgnoreCase(sUser.Site)) {
                        webConference.Registered_By_Site_Profile__c = sp.Id;
                    }
                }
            }
            catch(Exception ex) {
                throw new customException('No Site Profile with Id:' + sUser.RegisteredBy.User_Id);
            }
        }
            
        if (sUser.WebEvent.IsCanceled != true) {
            // enter the attendee information
            webConference.Attendee_Email__c = sUser.Attendee.Email;
            webConference.Attendee_Fax__c = sUser.Attendee.Fax;
            webConference.Attendee_First_Name__c = sUser.Attendee.FirstName;
            webConference.Attendee_Last_Name__c = sUser.Attendee.LastName;
            webConference.Attendee_Middle_Initial__c = sUser.Attendee.MiddleInitial;
            webConference.Attendee_Phone__c = sUser.Attendee.Phone;
            webConference.Attendee_Prefix__c = sUser.Attendee.Prefix;
            webConference.Attendee_Suffix__c = sUser.Attendee.Suffix;
            
            // check to see if we can find the attendee's adv.com user
            if (webConference.Attendee_Email__c != null && webConference.Advisory_com_Attendee_User__c == null) {
                List<Contact> contacts = [SELECT Id, Email, Create_Advisory_com_User_Account__c FROM Contact WHERE Create_Advisory_com_User_Account__c = true AND Email = :webConference.Attendee_Email__c LIMIT 1];
                if (contacts.size() > 0) {
                    webConference.Advisory_com_Attendee_User__c = contacts[0].Id;
                }
            }
                    
            //Added By - Abhinav Sharma - 07/08/2014 - CR-20140228-4676 - Advisory.com Create new Webconference Registration email for ABI
            //Populating Message Type field on "Webconference" record instance with the corresponding parameter value
            webConference.Message_Type__c = sUser.WebEvent.MessageType;
        }
        return webConference;
    }
    
    /**
     * @description:    find the contact records for webconference attendee and registrant
     * 
     **/
    public static Map<String, Contact> FindSiteUserContacts(String attendeeId, String registrantId) {
        Map<String, Contact> sProfileIdToContactMap = new Map<String, Contact>();
        
        string whereClause = 'Id IN (SELECT Contact__c FROM Site_Profile__c WHERE User_Id__c = ';
        if (attendeeId != null && attendeeId != '') {
            whereClause += '\'' + attendeeId + '\'';
        }
        
        if (registrantId != null && registrantId != '') {
            if (attendeeId != null)  {
                whereClause += ' OR ';
                whereClause += 'User_Id__c = \'' + registrantId + '\' ';
            }
            else {
                whereClause += '\'' + registrantId + '\'';
            }
            
            
        }
        whereClause += ')';
        whereClause += ' LIMIT 2';
        
        string queryString = CONTACTBASEQUERY + ' WHERE ' + whereClause;
        List<Contact> contacts =  database.query(queryString);
        
        for (Contact contact : contacts) {
            for (Site_Profile__c sp : contact.Site_Profiles__r) {
                sProfileIdToContactMap.put(sp.User_Id__c, contact);
            }
        }
        
        return sProfileIdToContactMap;
    }
    
    //Modified By Abhinav sharma - CR-20180809-12495 - Issue--CR12495--QA--00008452 
    public static void CreateAutoSubscriptions(List<Membership_Key_Contact__c> triggerNew, Map<Id, Membership_Key_Contact__c> oldMap) {
        
        //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        // list of subscriptions to insert
        //list<Subscription__c> subscriptionsToInsert = new list<Subscription__c>();
        Set<id> contactIds = new Set<Id>();
        Set<id> membershipIds = new Set<Id>();
        Set<id> programIds = new Set<Id>();
        
        for (Membership_Key_Contact__c newKeyContact : triggerNew) {
            contactIds.add(newKeyContact.Contact__c);
            membershipIds.add(newKeyContact.Membership__c);
        }
        
        //Added By Abhinav sharma - CR-20180809-12495 - Issue--CR12495--QA--00008452 - Added a field in the query
        // get the associated memberships with program id
        Map<Id, Membership__c> membershipMap = new Map<Id, Membership__c>([SELECT Id, Program__c, RecordType.DeveloperName FROM Membership__c WHERE ID IN :membershipIds]);
        for (Membership__c membership : membershipMap.values()) {
            if (membership.Program__c != null) programIds.add(membership.Program__c);
        }
        
        //if no program ids are returned, return immediately
        if(programIds.size() == 0) return;
        
        //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        //Modified By Mahendra Swarnkar - CR-20160926-10189 - 12/8/2016 -Updated the Query to replace the "Eligible_Subscription_Option__c.Key_Contact_Auto_Subscribe__c" References 
        //with "Eligible_Subscription_Option__c.Auto_Subscribe__c" field, where Auto_Subscribe__c =: Label.Auto_Subscribe_Key_Contact ( Label.Auto_Subscribe_Key_Contact = "Key Contact")
        // get all programs and their associated Eligible Subscription Options
        Map<Id, Program__c> programMap = new Map<Id, Program__c>([SELECT Id, Applicable_Segments__c /*, (SELECT Id, Auto_Subscribe__c, Related_Subscription__c FROM Eligible_Subscription_Options__r WHERE Auto_Subscribe__c =: Label.Auto_Subscribe_Key_Contact)*/ 
                                                                  FROM Program__c 
                                                                  WHERE Id IN :programIds]);
        
        //Modified By Abhinav Sharma - 06/25/2018 - CR-20180605-12266 - Replace Email with Company_Email__c.
        // get a map of all contacts
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name, Email, Company_Email__c,  (SELECT Id, Type__c FROM Site_Profiles__r) FROM Contact WHERE Id IN :contactIds]);
        
        // if we return no contacts, return immediately
        if (contactMap == null) return;
        
        for (Membership_Key_Contact__c newKeyContact : triggerNew) {
            
            //Added By Abhinav sharma - CR-20180809-12495 - Issue--CR12495--QA--00008452 - Stats here
            Boolean IS_ENROLLMENT_RTYPE = false;
            
            /*Checking for the Membership Key contact's Membership Record type OR Role type is Enrollment ??*/
            if((membershipMap != null 
               && membershipMap.containsKey(newKeyContact.Membership__c)
               && membershipMap.get(newKeyContact.Membership__c).RecordType.DeveloperName == 'Enrollment') || newKeyContact.Role_Type__c == 'Enrollment' ) {
                   
                   //set the boolean true
                   IS_ENROLLMENT_RTYPE = true;    
               }
               
            //Added By Abhinav sharma - CR-20180809-12495 - Issue--CR12495--QA--00008452 - Ends here.
            
            Membership_Key_Contact__c oldKeyContact;
            if (oldMap != null) oldKeyContact = oldMap.get(newKeyContact.Id);
            
            // check to see if the contact is being added for the first time or if the contact has changed
            if (ContactHasChanged(newKeyContact, oldKeyContact)) {
                // get the associated contact so we can check for errors (ie: no email address, not adv.com user, etc)
                Contact con = contactMap.get(newKeyContact.Contact__c);
                if (con == null) return;
                
                // get the associated membership so we can pull the program id
                Membership__c keyContactMembership = membershipMap.get(newKeyContact.Membership__c);
                // get the program with related eligible subscriptions
                Program__c program = programMap.get(keyContactMembership.Program__c);
                
                //check if we need to create a new site profile
                boolean hasSiteProfile = false;
                
                //Added By Abhinav sharma - CR-20180809-12495 - Issue--CR12495--QA--00008452
                //If the Membership record type is Enrollment then no need to create site profile. 
                if(!IS_ENROLLMENT_RTYPE) {
                  
                    string sProfileType = SITE_EAB;
                for (Site_Profile__c sProfile : con.Site_Profiles__r) {
                    if (sProfile.Type__c.containsIgnoreCase(sProfileType)) 
                        hasSiteProfile = true;
                }
                
                if (con.Email == null) {
                    newKeyContact.addError('<a href="/' + con.Id + '">' + con.Name + '</a> must contain a valid Email address.', false);
                }
                else if (!hasSiteProfile) {
                    
                    string siteType = SiteUserHelper.SITE_ADVISORY;
                    if (sProfileType.containsIgnoreCase(SiteTempAccessController.STRING_EAB))  
                        siteType = SiteUserHelper.SITE_EAB;
                    Site_Profile__c sProfileToInsert = new Site_Profile__c(Contact__c = con.Id,
                                                                           Username__c = con.Company_Email__c,
                                                                           Type__c = siteType);
                    
                    try {
                        
                        // attempt to update the contact and catch any errors to display to the user
                        insert sProfileToInsert;
                    }
                    catch(DMLException ex) {
                        
                        triggerNew[0].addError(ex.getDMLMessage(0), false);
                    }
                    catch(Exception ex) {
                        
                        triggerNew[0].addError(ex.getMessage());
                    }
                }
                
                //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
                // get all subscriptions to insert
                //subscriptionsToInsert = getSubscriptionsToInsert(con.Id, program.Eligible_Subscription_Options__r);
                }
             }
        }
        
        //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        /*if (subscriptionsToInsert.size() > 0) {
            
            try {
                
                // try to insert the subscriptions and catch any errors so we can display them to the user
                insert subscriptionsToInsert;
            }
            catch(DMLException ex) {
                
                triggerNew[0].addError(ex.getDMLMessage(0), false);
            }
            catch(Exception ex) {
                
                triggerNew[0].addError(ex.getMessage());
            }
        }*/
        
    }
    
    // Auto-subscribe project role contacts for PT programs.  CR-3785
    public static void CreateAutoSubscriptions_ProjectRoles(List<Project_Role__c> triggerNew, Map<Id, Project_Role__c> oldMap) {
        
        //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        // list of subscriptions to insert
        //list<Subscription__c> subscriptionsToInsert = new list<Subscription__c>();
        set<id> contactIds = new set<Id>();
        set<id> programIds = new set<Id>();
        set<Id> projectIdSet = new set<Id>();
        
        for (Project_Role__c newProjectRole : triggerNew) {
            
            projectIdSet.add(newProjectRole.Project__c);
            contactIds.add(newProjectRole.Contact__c);
        }
        
        // get Project info so we can get the program details
        Project__c project = [SELECT Id, Product__c, Institution__c FROM Project__c WHERE Id IN :projectIdSet LIMIT 1];
        
        // get a list of active memberships for this program
        list<Membership__c> activeMemberships = [SELECT Id 
                                                 FROM Membership__c 
                                                 WHERE Membership_Status__c LIKE 'Member%' 
                                                 AND Program__c != null
                                                 AND Program__c = :project.Product__c
                                                 AND Account_Name__c != null
                                                 AND Account_Name__c = :project.Institution__c];
        
        // if there is not an active membership for this program, return immediately
        if (activeMemberships.size() == 0) return;
        //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        //Modified By Mahendra Swarnkar - CR-20160926-10189 - 12/8/2016 -Updated the Query to replace the "Eligible_Subscription_Option__c.Key_Contact_Auto_Subscribe__c" References 
        //with "Eligible_Subscription_Option__c.Auto_Subscribe__c" field, where Auto_Subscribe__c =: Label.Auto_Subscribe_Key_Contact ( Label.Auto_Subscribe_Key_Contact = "Key Contact")
        // get all programs and their associated Eligible Subscription Options
        Map<Id, Program__c> programMap = new Map<Id, Program__c>([SELECT Id, Business_Line__c, Applicable_Segments__c
        							     /*(SELECT Id, Auto_Subscribe__c, Related_Subscription__c 
                                                                     FROM Eligible_Subscription_Options__r WHERE Auto_Subscribe__c =: Label.Auto_Subscribe_Key_Contact ) */
                                                                  FROM Program__c 
                                                                  WHERE Id = :project.Product__c]);
        
        // get a map of all contacts
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name, Email, Company_Email__c, (SELECT Id, Type__c, Username__c, Status__c FROM Site_Profiles__r) 
                                                            FROM Contact WHERE Id IN :contactIds]);
        
        // if we return no contacts, return immediately
        if (contactMap == null) return;
        
        for (Project_Role__c newProjectRole : triggerNew) {
            
            Project_Role__c oldProjectRole;
            if (oldMap != null) oldProjectRole = oldMap.get(newProjectRole.Id);
            
            // get the program with related eligible subscriptions
            Program__c program = programMap.get( project.Product__c );
            
            if (program != null && program.Business_Line__c == 'PT') {
                
                // check to see if the contact is being added for the first time or if the contact has changed
                if (ContactHasChanged(newProjectRole, oldProjectRole)) {
                    
                    // get the associated contact so we can check for errors (ie: no email address, etc)
                    Contact con = contactMap.get(newProjectRole.Contact__c);
                    
                    // if the contact is null, return immediately
                    if (con == null) return;
                    
                    if (con != null) {
                        
                        //check if we need to create a new site profile
                        boolean hasSiteProfile = false;
                        string sProfileType = SITE_EAB;
                        for (Site_Profile__c sProfile : con.Site_Profiles__r) {
                            if (sProfile.Type__c.containsIgnoreCase(sProfileType)) 
                                hasSiteProfile = true;
                        }
                        
                        if (con.Email == null) {
                            
                            newProjectRole.addError('<a href="/' + con.Id + '">' + con.Name + '</a> must contain a valid Email address.', false);
                        }
                        else if (!hasSiteProfile) {
                            
                            string siteType = SiteUserHelper.SITE_ADVISORY;
                            if (sProfileType.containsIgnoreCase(SiteTempAccessController.STRING_EAB))  
                                siteType = SiteUserHelper.SITE_EAB;
                            Site_Profile__c sProfileToInsert = new Site_Profile__c(Contact__c = con.Id,
                                                                                   Username__c = con.Company_Email__c,
                                                                                   Type__c = siteType);
                            
                            try {
                                
                                // attempt to update the contact and catch any errors to display to the user
                                insert sProfileToInsert;
                            }
                            catch(DMLException ex) {
                                
                                triggerNew[0].addError(ex.getDMLMessage(0), false);
                            }
                            catch(Exception ex) {
                                
                                triggerNew[0].addError(ex.getMessage());
                            }
                        }
                    }
                    
                    //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
                    // get all subscriptions to insert
                    //subscriptionsToInsert = getSubscriptionsToInsert(con.Id, program.Eligible_Subscription_Options__r);
                    
                }
            }
        
        }
        
        //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        /*if (subscriptionsToInsert.size() > 0) {
            
            try {
                
                // try to insert the subscriptions and catch any errors so we can display them to the user
                insert subscriptionsToInsert;
            }
            catch(DMLException ex) {
                
                triggerNew[0].addError(ex.getDMLMessage(0), false);
            }
            catch(Exception ex) {
                
                triggerNew[0].addError(ex.getMessage());
            }
        }*/

    }
    
    //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
    /*private static list<Subscription__c> getSubscriptionsToInsert(Id contactId, list<Eligible_Subscription_Option__c> eligSubOptions) {
        
        // list of subscriptions to return
        list<Subscription__c> subscriptionsToReturn = new list<Subscription__c>();
        
        // get any current subscriptions for this program
        Set<Id> subOptionIdSet = new Set<Id>();
        List<Subscription__c> activeSubscriptions = [SELECT Id, Subscription_ID__c, Subscription_Status__c, Subscription_ID__r.Related_Subscription__c
                                                    FROM Subscription__c 
                                                    WHERE Contact__c = :contactId AND Termination_Date__c = null];
        // get all of the subscription option ID's for active subscriptions so we don't create dupes.
        for (Subscription__c sub : activeSubscriptions) {
            subOptionIdSet.add(sub.Subscription_ID__r.Related_Subscription__c);
        }

        // for each eligible subscription option, create a subscription if the Subscription Option is not in our set
        for (Eligible_Subscription_Option__c eligibleSubscription : eligSubOptions) {
            if (subOptionIdSet.contains(eligibleSubscription.Related_Subscription__c)) continue;
            else {
                Subscription__c newSubscription = new Subscription__c();
                newSubscription.Contact__c = contactId;
                newSubscription.Send_Notification_Email__c = true;
                newSubscription.Activation_Date__c = system.now();
                newSubscription.Subscription_ID__c = eligibleSubscription.Id;
                newSubscription.Auto_Subscribed__c = true;
                newSubscription.Subscription_Status__c = SiteController.SUBSCRIPTION_ACTIVE;
                subscriptionsToReturn.add(newSubscription);
                // add this subscription option to the list of active subscriptions so we don't inset dupes
                subOptionIdSet.add(eligibleSubscription.Related_Subscription__c);
            }
        }

        return subscriptionsToReturn;
    }*/
    
    // see if the role is valid for subscriptions
    private static boolean isValidProjRole(Project_Role__c projectRole) {
        //Modified by - Dipesh Gupta - 05-26-2020 - CR-20200519-14068  
        List<string> rolelist = new List<string>();
        set<string> validProjRoles = new set<string> { 'Physician Champion', 'Value Leader', 'Project Sponsor', 'Executive Sponsor', 'Value Stream Leader', 'IT Lead' };
        
             
            if(projectRole != null && String.isNotBlank(projectRole.Role__c) && (projectRole.Role__c).contains(';')){
                rolelist = (projectRole.Role__c).split(';');
            }
            else if(projectRole != null && String.isNotBlank(projectRole.Role__c) && !(projectRole.Role__c).contains(';')){
                rolelist.add(projectRole.Role__c);
            }
        
        
        if (projectRole != null ) {
            for(String role : rolelist){
                if(validProjRoles.contains(projectRole.Role__c)){
                    return true;
                }
            }
            
        }
        
        return false;
    }
    
    // if the role wasn't valid previously and is valid now, return true
    private static boolean isNewlyValidProjRole(Project_Role__c newProjectRole, Project_Role__c oldProjectRole) {
        
        if (isValidProjRole(newProjectRole) &&
           (oldProjectRole == null || (oldProjectRole != null && !isValidProjRole(oldProjectRole))))
        {
            
            return true;
        }
        
        return false;
    }
    
    // see if the contact has changed and the project role is valid for auto subscribing
    public static boolean ContactHasChanged(Project_Role__c newProjectRole, Project_Role__c oldProjectRole) {
        
        if (isNewlyValidProjRole(newProjectRole, oldProjectRole) && 
           (oldProjectRole == null || ((newProjectRole.Contact__c != oldProjectRole.Contact__c) || (newProjectRole.Role__c != oldProjectRole.Role__c))))
        {
            
            return true;
        }
        
        return false;
    }
    
    /**
     * @description:    return the status code (previously FINDSTATUSCODE)
     *
     * @revision log:   Modified - 05/28/2019 - Victor Hanson - CR-20190520-13117 - do not return E3 when Institution's Org Status <> Active
    **/
    public static String getStatusCode(SiteUser sUser) {
        String statusCode = '';
        if (sUser.User_Status == null || (sUser.User_Status.toLowerCase() != 'active' && sUser.User_Status.toLowerCase() != 'inactive' &&
        sUser.User_Status.toLowerCase() != 'in progress')) {
            statusCode = 'E1';
        }
        else if (sUser.User_Status.equalsIgnoreCase('INACTIVE')) {
            statusCode = 'E2';
        }
        //VH 05/28/2019: Commented out below, because we allow Site Profiles to be created institutions without memberships
        /*else if ((sUser.User_Status.equalsIgnoreCase('ACTIVE') || sUser.User_Status.equalsIgnoreCase('IN PROGRESS')) &&
        (sUser.Organization_Status == null || (sUser.Organization_Status != null && !sUser.Organization_Status.equalsIgnoreCase('ACTIVE')))) {
                statusCode = 'E3';
        }*/
        else {
            if (sUser.Bypass_Domain_Validation == true) {
                statusCode = 'L1';
            }
            else if (sUser.Verify == null) {
                statusCode = 'R1';
            }
            else if (sUser.Verify == '0' || sUser.Verify == '1') {
                statusCode = 'R3';
            }
            else if (sUser.Verify == '2') {
                statusCode = 'L2';
            }
            else if (sUser.Verify == '3' || sUser.Verify == '4') {
                statusCode = 'R1';
            }
        }
        
        sUser.Status_Code = statusCode;
        sUser.site_Profile.Status_Code__c = statusCode;
        return statusCode;
    }
    
    //return the status code from a site profile
    public static string getStatusCode(Site_Profile__c sProfile) {
        
        //get the site user
        SiteUser sUser = new SiteUser();
        sUser.User_Status = sProfile.Status__c;
        sUser.Bypass_Domain_Validation = sProfile.Bypass_Domain_Validation__c;
        sUser.Verify = sProfile.Verify__c;
        sUser.UniqueId = sProfile.Id;
        sUser.Site = sProfile.Type__c;
        sUser.Site_Profile = sProfile;
        
        if (sUser.Site != null && sUser.Site.containsIgnoreCase(SITE_EAB)) {
            sUser.Organization_Status = sProfile.contact__r.Account.EAB_com_Organization_Status__c;
        }
        else if (sUser.Site != null && sUser.Site.containsIgnoreCase(SITE_ADVISORY)) {
            sUser.Organization_Status = sProfile.contact__r.Account.Advisory_com_Organization_Status__c;
        }
        
        //update the status
        sProfile.Status_Code__c = getStatusCode(sUser);
        return sProfile.Status_Code__c;
    }
    
    //populate the SiteUser based on the Contact (Previously POPULATEADVUSER)
    public static SiteUser getSiteUser(Contact con, SiteUser sUser, boolean updateExistingData) {
        
        return getSiteUser(con, sUser, updateExistingData, true);
    }
    
    //populate siteuser based on the contact.  
    //Note: getting web program access is expensive, so we skip this when a new siteProfile is being inserted, since its not necessary for that process.
    public static SiteUser getSiteUser(Contact con, SiteUser sUser, boolean updateExistingData, boolean getWebProgAccess) {
        
        if (con != null) {
            
            //populate the unique id
            sUser.UniqueId = con.Id;
            
            //if the contact's site_user__c field is populated, update the site_user variable on the sUser
            if (con.Site_User__c != null)
                sUser.site_User = new Site_User__c(Id = con.Site_User__c);
            
            //assign the appropriate site profile
            if (con.Site_Profiles__r != null && con.Site_Profiles__r.size() > 0) {
                for (Site_Profile__c sProfile : con.Site_Profiles__r) {
                    
                    if (sProfile.Type__c == sUser.Site) {
                        
                        sUser.site_Profile = sProfile;
                    }
                }
            }
            
            //Added By - Abhinav Sharma - 1/18/2017 - CR-20160505-9833
            if(con.AccountId != null) {
          if (!updateExistingData || (updateExistingData && sUser.contributionCategory == null)) {
              if(String.isnotBlank(sUser.Site) && sUser.Site.containsIgnoreCase(SITE_EAB))
                   sUser.contributionCategory = con.Account.Contribution_Category__c;
        }
            }
            
            //if there is no site profile associated with this contact -- create one
            if (sUser.site_Profile == null) 
                sUser.site_Profile = createNewSite_Profile(con, sUser, null);
            
            //Modified By Abhinav Sharma - 06/25/2018 - CR-20180605-12266 - Replace Con.Email with con.Company_Email__c
            //if the site profile username is null but the contact email is populated, set the site username = con.email
            if (con != null && con.Company_Email__c != null  && sUser.username == null)
                sUser.Username = con.Company_Email__c;
            
            if (sUser.site_Profile != null) {
                if (sUser.site_Profile.User_Id__c != null && (!updateExistingData || (updateExistingData && sUser.User_Id == null)))
                    sUser.User_Id = Integer.valueOf(sUser.site_Profile.User_Id__c);
                if (!updateExistingData || (updateExistingData && sUser.Organization_Id == null)) {
                    sUser.Organization_Id = Integer.valueOf(con.Account.Organization_ID__c);
                }
                if (!updateExistingData || (updateExistingData && sUser.Last_Access == null))
                    sUser.Last_Access = String.valueOf(sUser.site_Profile.Last_Access__c);
                if (!updateExistingData || (updateExistingData && sUser.Verify == null))
                    sUser.Verify = sUser.site_Profile.Verify__c;
                if (!updateExistingData || (updateExistingData && sUser.Verify_Date == null))
                    sUser.Verify_Date = String.valueOf(sUser.site_Profile.Verify_Date__c);
                if (!updateExistingData || (updateExistingData && sUser.Bypass_Domain_Validation == null))
                    sUser.Bypass_Domain_Validation = sUser.site_Profile.Bypass_Domain_Validation__c;
                if (!updateExistingData || (updateExistingData && sUser.Username == null)) {
                    sUser.Username = sUser.site_Profile.Username__c;
                     //Modified By Abhinav Sharma - 06/25/2018 - CR-20180605-12266 - Replace Con.Email with con.Company_Email__c
                    //if the site profile's username is updated, trigger an update to the contact email.
                    con.Company_Email__c = sUser.site_Profile.Username__c;
                }
                if (!updateExistingData || (updateExistingData && sUser.Password == null))
                    sUser.Password = sUser.site_Profile.Password__c;
            }
            else {
                //if the contact contains a site user, set the sUser's site_user id so a duplicate site_user isn't created
                if (con.Site_User__c != null)
                    sUser.Site_User = new Site_User__c(Id = con.Site_User__c);
            }
            
            if (!updateExistingData || (updateExistingData && sUser.First_Name == null))
                sUser.First_Name = con.FirstName;
            if (!updateExistingData || (updateExistingData && sUser.Middle_Initial == null))
                sUser.Middle_Initial = con.Middle_Name__c;
            if (!updateExistingData || (updateExistingData && sUser.Last_Name == null))
                sUser.Last_Name = con.LastName;
            if (!updateExistingData || (updateExistingData && sUser.Suffix == null))
                sUser.Suffix = con.Suffix__c;
            if (!updateExistingData || (updateExistingData && sUser.Title == null))
                sUser.Title = con.Title;
            if (!updateExistingData || (updateExistingData && sUser.Address1 == null))
                sUser.Address1 = con.Primary_Address_Line_1__c;
            if (!updateExistingData || (updateExistingData && sUser.Address2 == null))
                sUser.Address2 = con.Primary_Address_Line_2__c;
            if (!updateExistingData || (updateExistingData && sUser.Address3 == null))
                sUser.Address3 = con.Primary_Address_Line_3__c;
            if (!updateExistingData || (updateExistingData && sUser.City == null))
                sUser.City = con.Primary_City__c;
            if (!updateExistingData || (updateExistingData && sUser.State == null))
                sUser.State = con.Primary_State_Province__c;
            if (!updateExistingData || (updateExistingData && sUser.Zip == null))
                sUser.Zip = con.Primary_Postal_Code__c;
            if (!updateExistingData || (updateExistingData && sUser.Country == null))
                sUser.Country = con.Primary_Country__c;
            if (!updateExistingData || (updateExistingData && sUser.Office_Phone == null))
                sUser.Office_Phone = con.Phone;
            if (!updateExistingData || (updateExistingData && sUser.Fax_Phone == null))
                sUser.Fax_Phone = con.Fax;
            if (!updateExistingData || (updateExistingData && sUser.Email_Address == null)) 
                sUser.Email_Address = con.Company_Email__c;
            if (!updateExistingData || (updateExistingData && sUser.InstitutionUniqueId == null))
                sUser.InstitutionUniqueId = con.AccountId;
            if (!updateExistingData || (updateExistingData && sUser.ClientId == null))
                sUser.ClientId = con.Historical_Linker__c;
            if (!updateExistingData || (updateExistingData && sUser.Job_Function == null))
                sUser.Job_Function = con.Management_Level__c;
            if (!updateExistingData || (updateExistingData && sUser.EAB_Role == null))
                sUser.EAB_Role = con.EAB_Role__c;
            if (!updateExistingData || (updateExistingData && sUser.Department == null))
                sUser.Department = con.Function__c;
            if (!updateExistingData || (updateExistingData && sUser.EAB_Department == null))
                sUser.EAB_Department = con.EAB_Department__c;
            if (!updateExistingData || (updateExistingData && sUser.Prefix == null))
                sUser.Prefix = con.Salutation;
            if (!updateExistingData || (updateExistingData && sUser.User_Status == null))
                sUser.User_Status = sUser.site_Profile.Status__c;
            if (!updateExistingData || (updateExistingData && sUser.Modified_By == null))
                sUser.Modified_By = con.Company_Email__c;
            if (!updateExistingData || (updateExistingData && sUser.Org_Name == null))
                sUser.Org_Name = con.Account.Name;
            
            //get the org status and id depending on the site type
            if (!updateExistingData || (updateExistingData && sUser.Organization_Status == null)) {
                
                if (sUser.Site != null && sUser.Site.containsIgnoreCase(SITE_EAB)) {
                    sUser.Organization_Status = con.Account.EAB_com_Organization_Status__c;
                }
                else if (sUser.Site != null && sUser.Site.containsIgnoreCase(SITE_ADVISORY)) {
                    sUser.Organization_Status = con.Account.Advisory_com_Organization_Status__c;
                }
            }
            
            // Fields used by the Microsite project cr-1714
            if (!updateExistingData || (updateExistingData && sUser.LinkedIn == null))
                sUser.LinkedIn = con.Advisory_com_LinkedIn__c;
            if (!updateExistingData || (updateExistingData && sUser.Twitter == null))
                sUser.Twitter = con.Advisory_com_Twitter__c;
            if (!updateExistingData || (updateExistingData && sUser.Pinterest == null))
                sUser.Pinterest = con.Advisory_com_Pinterest__c;
            if (!updateExistingData || (updateExistingData && sUser.NameTag == null))
                sUser.NameTag = con.Advisory_com_Name_Tag__c;
            if (!updateExistingData || (updateExistingData && sUser.OrganizationNameTag == null))
                sUser.OrganizationNameTag = con.Advisory_com_Organization_Name_Tag__c;
            if (!updateExistingData || (updateExistingData && sUser.Interests == null))
                sUser.Interests = con.Advisory_com_Interests__c;
            if (!updateExistingData || (updateExistingData && sUser.ShareInformation == null))
                sUser.ShareInformation = con.Advisory_com_Share_Information__c;
            if (!updateExistingData || (updateExistingData && sUser.ShareEmail == null))
                sUser.ShareEmail = con.Advisory_com_Share_Email__c;
            if (!updateExistingData || (updateExistingData && sUser.ShareFacebook == null))
                sUser.ShareFacebook = con.Advisory_com_Share_Facebook__c;
            if (!updateExistingData || (updateExistingData && sUser.ShareFax == null))
                sUser.ShareFax = con.Advisory_com_Share_Fax__c;
            if (!updateExistingData || (updateExistingData && sUser.SharePhone == null))
                sUser.SharePhone = con.Advisory_com_Share_Phone__c;
            if (!updateExistingData || (updateExistingData && sUser.ShareLinkedIn == null))
                sUser.ShareLinkedIn = con.Advisory_com_Share_LinkedIn__c;
            if (!updateExistingData || (updateExistingData && sUser.SharePinterest == null))
                sUser.SharePinterest = con.Advisory_com_Share_Pinterest__c;
            if (!updateExistingData || (updateExistingData && sUser.ShareImage == null))
                sUser.ShareImage = con.Advisory_com_Share_Image__c;
            if (!updateExistingData || (updateExistingData && sUser.ShareTwitter == null))
                sUser.ShareTwitter = con.Advisory_com_Share_Twitter__c;
            if (!updateExistingData || (updateExistingData && sUser.ShareInterests == null))
                sUser.ShareInterests = con.Advisory_com_Share_Interests__c;
                
            //Added By - Abhinav Sharma - 22-01-2015 - CR-20141007-7689 
            //Start FROM Here
            if (!updateExistingData || (updateExistingData && sUser.AccountStatus == null))
                sUser.AccountStatus = con.Account.Status__c;
            
            if (!updateExistingData || (updateExistingData && sUser.AccountRecordType == null))
                sUser.AccountRecordType = con.Account.RecordType.Name;
            
            if (!updateExistingData || (updateExistingData && sUser.AccountFormalName == null))    
                sUser.AccountFormalName = con.Account.Account_Formal_Name__c;
            //Upto here
                
             //Added by Dipesh Gupta - 05/17/2019 - EAB.com Rebuild. - CR-20190510-13101
            //Starts here.
            if(sUser.site_Profile.Tokens_Available__c > 0 && con.Account.Tokens_Available__c > 0)
                sUser.TokensAvailable = true;
            else
                sUser.TokensAvailable = false;
                
            //Adding the site content GUID to the Site user. site token variable.    
            for(Site_Token__c sP : con.Site_Tokens__r)
                sUser.siteTokens.add(sP.Site_Content__r.GUID__c);
            
            //Adding the Site Content GUID from the Site Content Recommendations
            for(Site_Content_Recommendation__c sConRec : con.Site_Content_Recommendations__r)
                sUser.siteContentRecommentations.add(sConRec.Site_Content__r.GUID__c);

            //Adding Registration details
            for (Registration__c registration : con.Registrations__r) {
                sUser.registrations.add(new SiteMeeting.Registration(registration));
            }
            
            //Adding the Product Recommendation Campaign Members Web Program Access
            for (CampaignMember cm : con.CampaignMembers) {
                
                //check program is populated
                if (cm.Campaign.Primary_Program__c != null && cm.Campaign.Primary_Program__r.Web_Program_Access_Ids__c != null) {
                    sUser.recommendedProducts.addAll(cm.Campaign.Primary_Program__r.Web_Program_Access_Ids__c.split(','));
                }
            }
            
            //Adding the Institution Roles
            for (Institution_Roles__c iRole : con.Institution_Roles__r) {
                sUser.Institution_Roles.add(iRole.Assignment_Role__r.Name);
            }
            
            //Added by Victor Hanson - 07/24/2019 - Include strategic leader emails
            //Added By Neha Sharma - 01/12/2020 - CR-20201201-14714 - Updates to login callout response to include additional
            Set<String> setOfEmail = new Set<String>();
            Set<String> oppPDEEmail = new Set<String>();
            Set<String> memRenewalOwnerEmail = new Set<String>();
            Set<String> userName = new Set<String>();
            Set<String> setOfOppStage = new Set<String>{Constants.STAGE_OPPORTUNITY_VOID,Constants.CLOSED_WON,Constants.CLOSED_LOST};

            if(con.Account.EAB_Relationship_Status_Text__c == Constants.KEYWORD_MEMBER)
            {
                for(Membership__c mem : [Select Id,Renewal_Opp_Owner__c From Membership__c where 
                                         Renewal_Opp_Owner__c != null AND membership_status__c =: Constants.MEMBER_PAYER 
                                         AND Account_Name__c =: con.AccountId ])
                {
                    userName.add(mem.Renewal_Opp_Owner__c);
                }
                if(userName.size() > 0){
                    for(User u  : [Select Email From User Where Name IN: userName]){
                        setOfEmail.add(u.Email);
                    } 
                } 
            }

            if(con.Account.EAB_Relationship_Status_Text__c == Constants.REGISTRATION_PARTNER_STATUS_PROSPECT) {
                if (con.Account.Principal__r.Email != null)
                    setOfEmail.add(con.Account.Principal__r.Email); 
                
                for(Opportunity opp : [ Select Id,Marketer__r.Email From Opportunity Where CloseDate > TODAY and StageName NOT IN :setOfOppStage
                                       AND Marketer__c != null AND Marketer__r.Email != null and AccountId =: con.AccountId ])
                {
                    setOfEmail.add(opp.Marketer__r.Email);    
                } 
            }
            else if(con.Account.EAB_Relationship_Status_Text__c == Constants.KEYWORD_MEMBER){
                
                if (con.Account.Research_Strategic_Leader__r.Email != null)
                    setOfEmail.add(con.Account.Research_Strategic_Leader__r.Email);
                
                if (con.Account.Student_Success_Strategic_Leader__r.Email != null)
                    setOfEmail.add(con.Account.Student_Success_Strategic_Leader__r.Email);
                
                if (con.Account.Adult_Learner_Strategic_Leader__r.Email != null)
                    setOfEmail.add(con.Account.Adult_Learner_Strategic_Leader__r.Email);
                
                if (con.Account.Advancement_Strategic_Leader__r.Email != null)
                    setOfEmail.add(con.Account.Advancement_Strategic_Leader__r.Email);
                
                if (con.Account.Enrollment_Undergrad_Strategic_Leader__r.Email != null)
                    setOfEmail.add(con.Account.Enrollment_Undergrad_Strategic_Leader__r.Email);
                
                if (con.Account.APS_Consultant__r.Email != null)
                    setOfEmail.add(con.Account.APS_Consultant__r.Email);
                
                if (con.Account.r_Account_FA__r.Email != null)
                    setOfEmail.add(con.Account.r_Account_FA__r.Email);
                
                if (con.Account.Transfer_Strategic_Leader__r.Email != null)
                    setOfEmail.add(con.Account.Transfer_Strategic_Leader__r.Email);
                
                if (con.Account.YouVisit_Partner_Success_Manager__r.Email != null)
                    setOfEmail.add(con.Account.YouVisit_Partner_Success_Manager__r.Email);
                
                if (con.Account.Cappex_Partner_Success_Manager__r.Email != null)
                    setOfEmail.add(con.Account.Cappex_Partner_Success_Manager__r.Email);
                
                if (con.Account.Principal__r.Email != null)
                    setOfEmail.add(con.Account.Principal__r.Email); 
            }
            
            if(setOfEmail.size() >0){
                for(String emailadd : setOfEmail)
                {
                    sUser.strategicLeaderEmails.add(emailAdd); 
                }
            }
            
            
                
            //CR-20190510-13100
            if (!updateExistingData || (updateExistingData && sUser.menuCustomization == null))    
                sUser.menuCustomization = sUser.Site_Profile.Menu_Customizations__c;
            
            //Loop on the site preference. - CR-20190517-13116
            for(Site_Preference__c sPreference : con.Site_Preferences__r) {
                
                //Check for the Type us Saved.
                if(sPreference.Type__c == 'Saved')
                    sUser.savedPosts.add(sPreference.Site_Content__r.GUID__c);
             }
            //Upto here - EAB.com Rebuild.

            //Added By - Ajit Surana - 04-29-2015 - CR-20150415-8874 
            //Start FROM Here
            if (!updateExistingData || (updateExistingData && sUser.strategicAccountSegment == null))
                sUser.strategicAccountSegment = con.Account.Strategic_Account_Segment__c;
            //Upto here
            
            //Added By - Abhinav Sharma - 11/27/2015 - CR-20151118-9393
            //Start from here
            
            //Set to hold the users Ids
            Set<Id> setOfUsersIds = new Set<Id>();
            
            
            if(con.AccountId != null && con.Account.Principal__c != null)
                setOfUsersIds.add(con.Account.Principal__c);
            
            //Map of users
            Map<Id, User> mapUsers = new Map<Id, User>();
            
            //Checking set for size value
            if(setOfUsersIds.size() > 0) {
                
                //Populating map to hold the users details
                mapUsers = new Map<Id, User>([SELECT ID, Name FROM User WHERE ID IN : setOfUsersIds]);
            }
            
            //Checking for null value and populating properties with correspodning field values.
            //Will be used by microsite
            if(con.AccountId != null) {
                
                //Provider Type
                //Modify By - Abhinav Sharma - 02/04/2020 - CR-20200814-14436 - Finish Deleting Fields from Oct 2020 Release [Start]
                //if (!updateExistingData || (updateExistingData && sUser.ProviderType == null))
                    //sUser.ProviderType = con.Account.Provider_Type__c; End
                
                //Bed Size
                /*if (!updateExistingData || (updateExistingData && sUser.BedSize == null)) {
                    if(con.Account.Bed_Size__c != null)
                        sUser.BedSize= String.valueOf(con.Account.Bed_Size__c);
                }*/
                    
                //Principle
                if (!updateExistingData || (updateExistingData && sUser.Principal== null)) {
                    if(con.Account.Principal__c != null 
                       && mapUsers.containsKey(con.Account.Principal__c)
                       && mapUsers.get(con.Account.Principal__c) != null
                    )
                        sUser.Principal= mapUsers.get(con.Account.Principal__c).Name;    
                }
            }
            //upto Here
            
            // populate the Meeting Utilization data for this sUser cr-3166
            if (con.Meeting_Utilization__r != null)
                sUser.MeetingUtilizations = con.Meeting_Utilization__r;
            if (con.Meeting_Utilization1__r != null)
                sUser.MeetingUtilizations.addAll(con.Meeting_Utilization1__r);
            
            try {
                if (con.Temporary_Program_Access__r != null) {
                    sUser.TemporaryProgramAccess = con.Temporary_Program_Access__r;
                }
            }
            catch(Exception e) {
                if (e.getMessage().containsIgnoreCase('Aggregate query has too many rows')) {

                //Modifed By Dipesh Gupta - CR-20190726-13240 - 08/06/2019 - Remove the reference of Temporary_Program_Access__c
                   /* sUser.TemporaryProgramAccess = [SELECT Start_Date__c, Owner.Name, End_Date__c, CreatedBy.Name, Web_Program__r.Advisory_com_CS_Role__c, 
                                                    Web_Program__r.Program_Acronym__c, Web_Program__r.Program_Formal_Name__c, Web_Program__r.Web_Program__r.Description__c, 
                                                    Web_Program__r.Web_Program__r.Program_Code_to_Member__c, Web_Program__r.Web_Program__r.Advisory_com_CS_Role__c, 
                                                    Web_Program__r.Web_Program__r.A_com_Program_ID__c, Program_Acronym__c, Program_Formal_Name__c, Web_Program__r.Adv_com_Program_Id__c, 
                                                    Web_Program_Name__c, Site_Program_Id__c FROM Temporary_Program_Access__c 
                                                    WHERE Contact__c = :con.Id AND Start_Date__c <= TODAY AND End_Date__c >= TODAY];*/
                }
                else {
                    throw new customException(e.getMessage() + e.getStackTraceString());
                }
            }
            
            if (getWebProgAccess) {
                // set the web program access list
                sUser.webProgramAccessList = getWebProgramAccess(con, sUser);
            }
            
            sUser.SFDateTime = String.valueOf(system.now());
        }
        
        // get the user status
        getStatusCode(sUser);
        
        return sUser;
    }
    
    /**
     * @description:    get site user from Contact and Site Profile
     * 
     **/
    public static SiteUser getSiteUser(Contact c, Site_Profile__c sProfile) {
        SiteUser sUser = new SiteUser();
        sUser.Site_Profile = sProfile;
        sUser.Site = sProfile.Type__c;
        return getSiteUser(c, sUser, false, false);
    }
    
    //sitecore custom setting
    public static Sitecore_Settings__c sitecoreSettings {
        get {
            if (sitecoreSettings == null) {
                sitecoreSettings = Sitecore_Settings__c.getInstance();
            }
            return sitecoreSettings;
        }
        set;
    }
    
    /**
     * @description:    get all of the web programs for active memberships + temp access
     * 
     **/    
    public static List<SiteUser.WebProgramAccess> getWebProgramAccess(Contact con, SiteUser sUser) {
        List<SiteUser.WebProgramAccess> WebProgramAccess = new List<SiteUser.WebProgramAccess>();

        //Modifed By Dipesh Gupta - CR-20190726-13240 - 08/06/2019 - Remove the reference of Temporary_Program_Access__c
        // temp access
        /*for (Temporary_Program_Access__c tempAccess : sUser.TemporaryProgramAccess) {
            WebProgramAccess.add(new SiteUser.WebProgramAccess(tempAccess));
        }*/

        
        //Modified By - Abhinav Sharma - CR-20201019-14613 - 12/1/2020 - Added the functionality to send the payer status with web program access in the login response
         
         // get the contact

         List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE Id = :sUser.UniqueId];
        
        // get all web programs for active memberships
        for (Web_Program_Access_MTM__c webProgAccessMtM : getWebProgramAccessMTM(con, sUser)) {
            
             if(contacts.size() > 0 && mapOfprogwithPayerStatus.containsKey(webProgAccessMtM.Membership_Program__c+'-'+contacts[0].accountId))
            {
                WebProgramAccess.add(new SiteUser.WebProgramAccess(webProgAccessMtM,
                mapOfprogwithPayerStatus.get(webProgAccessMtM.Membership_Program__c+'-'+contacts[0].accountId)));

            }
        }
        return WebProgramAccess;
    }
    
    /**
     * @description:    get all of the web programs for active memberships
     * 
     **/    
    public static List<Web_Program_Access_MTM__c> getWebProgramAccessMTM(Contact con, SiteUser sUser) {
        
        List<Web_Program_Access_MTM__c> webProgAccessMTMList  = new List<Web_Program_Access_MTM__c>();
        Contact c;
        // get the contact
        List<Contact> contacts = [SELECT Id, AccountId 
                                  FROM Contact 
                                  WHERE Id = :sUser.UniqueId LIMIT 1];
        if (contacts.size() > 0) c = contacts[0];
        else throw new CustomException('No Contact found with ID: ' + sUser.UniqueId);
        // get the memberships
        List<Membership__c> activeMemberships = [SELECT Id, Membership_Status__c, Program__c, Program_Acronym__c,Account_Name__c,Payer_Status__c,
                                                 Active_Contract_Idenfied__r.Main_Contact__c, Active_Subscription__r.SBQQ__Contract__r.Main_Contact__c
                                                 FROM Membership__c 
                                                 WHERE Account_Name__c = :c.AccountId 
                                                 AND Program__c != null
                                                 AND Membership_Status__c LIKE 'Member%' LIMIT 500];
        
        // get all web program access associated with these programs
        Set<id> programsForActiveMemberships = new Set<Id>();
        for (Membership__c mem : activeMemberships) {
            programsForActiveMemberships.add(mem.Program__c);
            
             //Modified By - Abhinav Sharma - CR-20201019-14613 - 12/1/2020 - Added the functionality to send the payer status with web program access
           
            if(mem.program__c != null && mem.Account_Name__c != null &&
               !mapOfprogwithPayerStatus.containsKey(mem.program__c+'-'+mem.Account_Name__c))

           {
                mapOfprogwithPayerStatus.put(mem.program__c+'-'+mem.Account_Name__c,mem.Payer_status__c);

           }
            
            //10/14/2019 - CR-20190820-13270 - Victor Hanson - track membership main contacts
            if (mem.Active_Subscription__r.SBQQ__Contract__r.Main_Contact__c != null) {
                sUser.membershipMainContacts.add(new SiteUser.MembershipMainContact(mem.Program_Acronym__c, mem.Active_Subscription__r.SBQQ__Contract__r.Main_Contact__c));
            }
            else if (mem.Active_Contract_Idenfied__r.Main_Contact__c != null) {
                sUser.membershipMainContacts.add(new SiteUser.MembershipMainContact(mem.Program_Acronym__c, mem.Active_Contract_Idenfied__r.Main_Contact__c));
            }
        }
        
        //
        string queryString = 'SELECT Id, Adv_com_Program_Id__c, Membership_Program__c,Web_Program__r.Program_Code_to_Member__c, Web_Program__r.Description__c '
            + ' FROM Web_Program_Access_MTM__c '
            + ' WHERE Membership_Program__c IN :programsForActiveMemberships ';
        
        if (con.RecordTypeId == Schema.SObjectType.Contact.RecordTypeInfosByName.get('Employee').RecordTypeId) {
            queryString += ' AND Web_Program__r.ABC_Restricted__c = false';
        }
        
        queryString += ' LIMIT 500';
        
        // get the web program access associated with these programs
        webProgAccessMTMList = database.query(queryString);
        
        return webProgAccessMTMList;
    }
    
    /**
    * @description:     find Contacts with site profiles and subscriptions.
    *
    *
    **/
    public static List<Contact> FindContacts(SiteUser sUser) {
        
        // build a custom where string to query
        
        String whereString = '';
        String sProfileWhereString = '';
        if (sUser.First_Name != null && sUser.First_Name != '') {
            if (whereString != '') whereString += ' AND ';
            whereString += 'Contact__r.FirstName LIKE \'%' + String.escapeSingleQuotes(sUser.First_Name) + '%\'';
        }
         
        if (sUser.Last_Name != null && sUser.Last_Name != '')  {
            if (whereString != '') whereString += ' AND ';
            whereString += 'Contact__r.LastName LIKE \'%' + String.escapeSingleQuotes(sUser.Last_Name) + '%\'';
        }
        
        if (sUser.Email_Address != null && sUser.Email_Address != '') {
            if (whereString != '') whereString += ' AND ';
            whereString += 'Contact__r.Company_Email__c LIKE \'%' + String.escapeSingleQuotes(sUser.Email_Address) + '%\'';
        }
        
        if (sUser.City != null && sUser.City != '') {
            if (whereString != '') whereString += ' AND ';
            whereString += 'Contact__r.Primary_City__c LIKE \'%' + String.escapeSingleQuotes(sUser.City) + '%\'';
        }
        
        if (sUser.State != null && sUser.State != '') {
            if (whereString != '') whereString += 'AND ';
            whereString += 'Contact__r.Primary_State_Province__c LIKE \'%' + String.escapeSingleQuotes(sUser.State) + '%\'';
        }
        
        if (sUser.Country != null && sUser.Country != '') {
            if (whereString != '') whereString += 'AND ';
            whereString += 'Contact__r.Primary_Country__c LIKE \'%' + String.escapeSingleQuotes(sUser.Country) + '%\'';
        }
        
        if (sUser.User_Id != null) {
            if (whereString != '') whereString += 'AND ';
            whereString += 'User_Id__c = \'' + sUser.User_Id + '\' ';
            sProfileWhereString = 'User_Id__c = \'' + sUser.User_Id + '\' ';
        }
        
        if (sUser.User_Status != null && sUser.User_Status != '') {
            if (sProfileWhereString != '') sProfileWhereString += ' AND ';
            if (sUser.User_Status.equalsIgnoreCase('non-inactive')) sProfileWhereString += 'Status__c != \'Inactive\' ';
            else sProfileWhereString += 'Status__c = \'' + String.escapeSingleQuotes(sUser.User_Status) + '\'';
        }
        
        if (sUser.Site != null && sUser.Site != '') {
            if (sProfileWhereString != '') sProfileWhereString += ' AND ';
            sProfileWhereString += 'Type__c = \'' + String.escapeSingleQuotes(sUser.Site) + '\' ';
        }
        
        if (sProfileWhereString != '') sProfileWhereString = ' WHERE ' + sProfileWhereString;
        
        //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        //Modified By Abhinav Sharma - 06/25/2018 - CR-20180605-12266 - Replace Con.Email with con.Company_Email__c
        string contactSiteProfileQuery = 'SELECT Id, Company_Email__c,   FirstName, LastName, Contact_Status__c, Email, Primary_City__c, Management_Level__c, Function__c, Primary_State_Province__c, Organization_Id__c, Primary_Country__c, '
            + 'AccountId, Account.Name,'
            /*+ '(SELECT Auto_Subscribed__c,  Subscription_Id__r.Program__r.Applicable_Segments__c, Subscription_Status__c, Activation_Date__c, Subscription_ID__r.Name, Subscription_ID__r.Related_Subscription__r.Description__c, Subscription_ID__r.Program__c, Subscription_Name__c, Subscription_ID__r.Name__c, Subscription_ID__r.Related_Subscription__r.Subscription_Category__c, Subscription_ID__r.Related_Subscription__r.Name, Subscription_ID__r.Related_Subscription__r.Subscription_Status__c, Subscription_ID__r.Related_Subscription__r.Subscription_Name_Ext__c, '
            + 'Subscription_ID__r.Related_Subscription__r.Legacy_Subscription_ID__c, Termination_Date__c FROM Subscriptions__r WHERE Termination_Date__c = null AND Subscription_ID__r.Related_Subscription__r.Subscription_Status__c = \'Active\' LIMIT 1000), '*/
            + '(SELECT Id, User_Id__c, Status__c, Status_Code_Description__c, Type__c, Verify__c, Contact__r.AccountId, Contact__r.Account.Name, Contact__r.Account.Historical_Linker__c, Last_Access__c, '
            + 'Verify_Date__c, Status_Code__c, Contact__c,'
            + 'Contact__r.Name, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.Primary_City__c, Contact__r.Primary_State_Province__c, Contact__r.Primary_Country__c, Bypass_Domain_Validation__c'
            + ' FROM Site_Profiles__r ' + sProfileWhereString + ') '
            + ' FROM Contact';
        
        string queryString = contactSiteProfileQuery + ' WHERE Id IN (SELECT Contact__c FROM Site_Profile__c WHERE ' + whereString + ') '
                            + ' AND (NOT Contact_Status__c LIKE \'%Inactive%\') LIMIT 200';

        List<Contact> contacts = database.query(queryString);
        
        return Contacts;
    }
    
    /**
     * @description:    when an institution is modified, send a callout to our sites DB with the institution info
     * 
     **/
    public static void institutionUpsertToSiteDatabase(list<Account> listAccounts, map<Id, Account> oldMapAccounts) {
        
        //only process if there is one instutition being upserted - don't want to hit the callout limit
        if (listAccounts.size() == 1) {
            
            Account acct = listAccounts[0];
            
            //get the old account if this is an update
            Account oldAcct;
            if (oldMapAccounts != null) oldAcct = oldMapAccounts.get(acct.Id);
            
            if ((oldAcct == null && acct.EAB_com_Organization_Status__c != null && acct.Advisory_com_Organization_Status__c != null)
               || (oldAcct != null 
                   && (acct.Organization_Id__c != oldAcct.Organization_Id__c
                       || acct.Account_Formal_Name__c != oldAcct.Account_Formal_Name__c
                       || acct.Primary_Address_Line_1__c != oldAcct.Primary_Address_Line_1__c
                       || acct.Primary_City__c != oldAcct.Primary_City__c
                       || acct.Primary_State_Province__c != oldAcct.Primary_State_Province__c
                       || acct.Primary_Postal_Code__c != oldAcct.Primary_Postal_Code__c
                       || acct.Phone != oldAcct.Phone
                       || acct.Primary_Country__c != oldAcct.Primary_Country__c
                       || acct.Advisory_com_Organization_Status__c != oldAcct.Advisory_com_Organization_Status__c
                       || acct.EAB_com_Organization_Status__c != oldAcct.EAB_com_Organization_Status__c)
                  )
               ) 
            {
                //upsert EAB.com Institution
                if (sitecoreSettings.EAB_Admin_URL__c != null && (acct.EAB_com_Organization_Status__c != null || oldAcct.EAB_com_Organization_Status__c != null)) {
                    //don't execute the callout if the process updating the record is a Unit test, batch, or future method
                    if (!test.isRunningTest() && !system.isBatch() && !system.isFuture())
                        GlobalUtilities.siteCallout_UpsertOrganization(acct.Id, acct.EAB_com_Organization_Status__c, SiteUserHelper.SITE_EAB);
                }
                
                //upsert Advisory.com Institution
                if (sitecoreSettings.AdvAdmin_URL__c != null && (acct.Advisory_com_Organization_Status__c != null || oldAcct.Advisory_com_Organization_Status__c != null)) {
                    //don't execute the callout if the process updating the record is a Unit test, batch, or future method
                    if (!test.isRunningTest() && !system.isBatch() && !system.isFuture())
                        GlobalUtilities.siteCallout_UpsertOrganization(acct.Id, acct.Advisory_com_Organization_Status__c, SiteUserHelper.SITE_Advisory);
                }
                
            }
        }
    }
    
    /**
     * @description:    create and send the callout to upsert EAB/Adviory.com institution information.
     * 
     **/
    public static string getInstitutionSiteUser(Id accountId, string status, string site) {
        
        //get the institution
        Account acct = [SELECT Id, Organization_Id__c, Account_Formal_Name__c, Primary_City__c, Primary_State_Province__c, Primary_Postal_Code__c,  
                        Phone, Primary_Country__c, Primary_Address_Line_1__c FROM Account WHERE Id = :accountId];
        
        SiteUser sUser = new SiteUser();
        sUser.Site = site;
        sUser.Organization_Status  = status;
        sUser.Organization_ID  = integer.valueOf(acct.Organization_Id__c);
        sUser.Org_Name  = acct.Account_Formal_Name__c;
        sUser.City  = acct.Primary_City__c;
        sUser.State = acct.Primary_State_Province__c;
        sUser.Zip = acct.Primary_Postal_Code__c;
        sUser.Phone = acct.Phone;
        sUser.Country = acct.Primary_Country__c;
        sUser.Address1 = acct.Primary_Address_Line_1__c;
        sUser.AuthenticateDomain = true;
        //sUser.Modified_Date = ???;
        
        return JSON.serialize(sUser);
    }
    
    /**
     * @description:    track the site profiles that have been sent password notifications so we don't send duplicate requests
     *
     **/
     public static set<Id> verificationIdSet {
        get {
            if (verificationIdSet == null) verificationIdSet = new set<Id>();
            return verificationIdSet;
        }
        set;
     }
    
    //v1.11 - Modified By - Mahendra Swarnkar - 07/06/2017 - CR-20170524-10956 - Commented the method "createAccountAndContactSharing". Starts from here
    /**
     *  @description    :   This method is to create a sharing record for the Site user for the Contact and Account Record, So email template can access the fields 
     * 
     *  @args           :   Contact record
     * 
     *  @return         :   none
     * 
     **/
    /*private static void createAccountAndContactSharing(Contact contactToShare) {
        
        //Check for the Contact Id
        if(contactToShare.Id != null) {
            
            //commented out as part of CR-20150330-8821 - OwnerId is now queried in CONTACTBASEQUERY 
            //  and Account.OwnerId is always Salesforce Admin due to WF_UpdateAccountOwner, so the query is not necessary
            //Fetch Current Owner
            //contactToShare = [Select Id, OwnerId, Account.OwnerId from Contact where Id =: contactToShare.Id];
            if(contactToShare.OwnerId != UserInfo.getUserId()) {
                
                //insert sharing record
                insert new ContactShare(ContactId = contactToShare.Id, UserOrGroupId = UserInfo.getUserId(), ContactAccessLevel = 'Edit');
            }
            if(contactToShare.AccountId != null) {
                
                if (contactToShare.Account.OwnerId != UserInfo.getUserId()) {
                    //insert sharing record
                    insert new AccountShare(AccountId = contactToShare.AccountId, UserOrGroupId = UserInfo.getUserId(), AccountAccessLevel = 'Edit', CaseAccessLevel = 'Read', OpportunityAccessLevel = 'Read', ContactAccessLevel = 'Edit');
                }
            }
        }
    }
    */
    //v1.11 - Modified By - Mahendra Swarnkar - 07/06/2017 - CR-20170524-10956 - Commented the method "createAccountAndContactSharing". Ends here
    
    /**
     *  @description    :  Method used to populate the Entity field value on the following basis :
     *             associated child "Site Profile" type field value
     *             1) Type => 'EAB.com  then Entity => 'EAB'  
     *             2) Type => 'Advisory.com' then Entity => 'HC' 
     *             3) Type => 'EAB.com' and 'Royall.com' then Entity => 'All'   
     *
     *  @args           :  List of new Site User records, Map of old Site User records
     * 
     *  @return         :  void
     * 
     *   @Revision Log   :  V1.0 - Created By - Deepak Kumawat - 10/09/2017 - CR-20170927-11503 - Apollo Release
     **/
     public static void populateEntityField(List<Site_User__c> newSiteUsers, Map<Id, Site_User__c> mapOldSiteUsers) {
      
       //Set to hold the Site User
        Set<Id> setSiteUserIds =  new Set<Id>();
         
        //List to hold the site user records
        List<Site_User__c> listOfSiteUsers = new List<Site_User__c>(); 
        
        //Loop over the Site User
        for(Site_User__c siteUser : newSiteUsers) {
            
            //Check for Entity Update
            if(mapOldSiteUsers != null){
                
                //Populate the set for Contact Id
                setSiteUserIds.add(siteUser.Id);
            }
        } 
         
        //Check for size
        if(setSiteUserIds.size() > 0) {
            
          //Call the validateEntityFieldsForSiteUserObjects, to populate the entity field value
            SiteProfileTriggerHelper.validateEntityFieldsForSiteUserObjects(setSiteUserIds);
        }
     } 
    
    /**
     *  @description    : This method is used to listen the command and insert/delete site preferences records.  
     *
     *  @args           :  
     * 
     *  @return         :  void
     * 
     *   @Revision Log   :  V1.0 - Created By - Dipesh Gupta - CR-20190517-13116 - 05/21/2019.
     **/
    
    public Static SiteUser Action_SavedPostListener (SiteUser sUser) {
      
        //List to hold the site Preference records.
        List<Site_Preference__c> sitepreferencesToBeInserted = new List<Site_Preference__c>();
        
        string queryString = CONTACTBASEQUERY 
                + ' WHERE Id IN (SELECT Contact__c FROM Site_Profile__c WHERE User_Id__c = \'' + sUser.User_Id + '\' ' 
                + ' AND Type__c = \'' + sUser.Site + '\')';
        
        List<Contact> contacts =  database.query(queryString);
        

        if (contacts.size() > 0) {
            
            // populate the sUser record from fields on the contact
            sUser = getSiteUser(contacts[0], sUser, true);
            
            //Check for the command.
            if(sUser.command == 'addSavedPost') {
                
               SiteContentHelper sch = new SiteContentHelper(sUser, sUser.post.id_x);
               Site_Content__c siteContent = sch.siteContent;
	       
                //Create New Site Preference Record.
                Site_Preference__c sitePreference = new Site_Preference__c();
                sitePreference.Contact__c = contacts[0].Id;
                sitePreference.Site_Content__c = siteContent.Id;
                sitePreference.Site_Profile__c = sUser.Site_Profile.Id;
                
                //Check for the type. 
                if(sUser.command == 'addSavedPost')
                    sitePreference.Type__c = 'Saved';
                            
                //Adding a site preference instance to the list.
                sitepreferencesToBeInserted.add(sitePreference);
                
                if(sitepreferencesToBeInserted.size() > 0)
                    insert sitepreferencesToBeInserted;       
            }
            
            //Delete the 
            //Check for the Command - removeSavedPost
            if(sUser.command == 'removeSavedPost') {
                
                String checkType = '';
                
                //Check for the command.
                if(sUser.command == 'removeSavedPost')
                    checkType = 'Saved';
                
                if(String.isNotBlank(checkType)) {
                    
                    //List of site preferences that needs to be deleted
                    List<Site_Preference__c> sPreferences = [SELECT Id, Site_Content__c, Site_Profile__c From Site_Preference__c 
                                                            WHERE Site_Content__r.GUID__c =: sUser.post.id_x 
                                                             AND Type__c =: checkType
                                                             AND Site_Profile__c = :sUser.Site_Profile.Id];
                    
                    if(sPreferences.size() > 0) {               
                        delete sPreferences;
                        
                        //remove the post from the list of posts on the site user
                        if (sUser.savedPosts.indexOf(sUser.post.id_x ) != -1) {
                            sUser.savedPosts.remove(sUser.savedPosts.indexOf(sUser.post.id_x ));
                        }
                    }
                }   
            }

            //populate the SiteUser record from fields on the contact
            sUser = getUpdatedSiteUserDetails(contacts[0].Id, sUser);
            sUser.Response = RESPONSE_SUCCESS;
        }
        else {
            sUser.Response = 'invalid user Id: ' + sUser.User_Id;
        }
        
        return sUser;
    }
    
    /**
     *  @description    : This method is used to listen the command "UserToken" and check if the related Site profile and Institution has token available.
     *
     *  @args           :  
     * 
     *  @return         :  void
     * 
     *   @Revision Log   :  V1.0 - Created By - Dipesh Gupta - CR-20190510-13101 - 05/23/2019.
     *                      V1.1 - Modified By - Victor Hanson - CR-20190510-13101 - 06/17/2019 - prevent duplicate active tokens for the same Site Content
     *                      V1.2 - Modified By - Victor Hanson - CR-20190827-13289 - 08/27/2019 - updated to record Web Program Access Ids
     **/
    public static SiteUser Action_UserTokenAvailabilityCheck(SiteUser sUser) {
        
       //Query contact based on the Contact. 
       string queryString = CONTACTBASEQUERY 
                + ' WHERE Id IN (SELECT Contact__c FROM Site_Profile__c WHERE User_Id__c = \'' + sUser.User_Id + '\' ' 
                + ' AND Type__c = \'' + sUser.Site + '\')';
        
        List<Contact> contacts =  database.query(queryString); 
        
        //Check if the contact is not null.
        if(contacts != null && contacts.size() > 0) {
                
            // populate the sUser record from fields on the contact
            sUser = getSiteUser(contacts[0], sUser, true);
            
            //VH 08/27/2019 - updated to add site content via siteContentHelper
            SiteContentHelper sch = new SiteContentHelper(sUser, sUser.post.id_x);
            Site_Content__c siteContent = sch.siteContent;
            
            //Check for the Site Core Setting 
            Integer numOfDaysToAdd = Sitecore_Settings__c.getInstance().Num_Days_Site_Tokens_Valid__c != null ? Integer.valueOf(Sitecore_Settings__c.getInstance().Num_Days_Site_Tokens_Valid__c) : 0;
            
            //Create a site Token Records.
            Site_Token__c siteToken = new Site_Token__c();
            siteToken.Site_Content__c = siteContent.Id;
            siteToken.Site_Profile__c = sUser.Site_Profile.Id;
            siteToken.Contact__c = contacts[0].Id;
            siteToken.Expiration_Date__c = Date.today().addDays(numOfDaysToAdd);
            
            
            //Check for the Tokens. If no tokens available, create the Site Token record but flag it as no tokens available and remove the expiration date
            if(!sUser.tokensAvailable) {
                siteToken.Expiration_Date__c = null;
                
                //Check for the Site profile and Account. 
                if(sUser.site_Profile.Tokens_Available__c < 1) {
                    siteToken.Flag__c = SITE_TOKEN_FLAG_SITE_PROFILE;
                    sUser.Response = 'ERROR_NO_TOKENS_AVAILABLE_FOR_USER';
                    return sUser;
                }
                
                if(contacts[0].Account.Tokens_Available__c < 1) {
                    siteToken.Flag__c = SITE_TOKEN_FLAG_INSTITUTION;
                    sUser.Response = 'ERROR_NO_TOKENS_AVAILABLE_FOR_INSTITUTION';
                    return sUser;
                }
                
            }
            
            //verify there isn't already an active token for this site profile & site content
            List<Site_Token__c> duplicateActiveTokens = [SELECT Id FROM Site_Token__c 
                                                         WHERE Site_Profile__c = :sUser.Site_Profile.Id 
                                                         AND Site_Content__c = :siteContent.Id
                                                        AND Status__c = 'Active'];
            
            //insert token if there are no duplicate tokens for this site profile
            if (duplicateActiveTokens.size() == 0) {
                insert siteToken;
            }
            
            //populate the SiteUser record from fields on the contact
            sUser = getUpdatedSiteUserDetails(contacts[0].Id, sUser);
            
            if (String.isBlank(sUser.Response)) {
                sUser.Response = RESPONSE_SUCCESS;
            }
            
        }
        else {
            sUser.Response = 'invalid user Id: ' + sUser.User_Id;
        }
        
        return sUser;
    }


    

    /**
     *  @description    : This method is used to listen the command "UserToken" and check if the related Site profile and Institution has token available.
     * 
     *  @return         :  SiteUser
     * 
     *   @Revision Log   :  V1.0 - Created By - Victor Hanson - CR-20190510-13101 - 06/17/2019.
     **/
    public static SiteUser getUpdatedSiteUserDetails(Id contactId, SiteUser sUser) {
        List<Contact> contacts =  database.query(CONTACTBASEQUERY  + ' WHERE Id = \'' + contactId + '\'');
        
        //VH 08/02/2019 - reset site user so we don't return duplicate savedPosts to Wordpress
        SiteUser sUserTemp = new SiteUser();
        sUserTemp.User_Id = sUser.User_Id;
        sUserTemp.Command = sUser.command;
        sUserTemp.Site_Profile = sUser.Site_Profile;
        
        //populate the SiteUser record from fields on the contact
        sUser = getSiteUser(contacts[0], sUserTemp, false);

        //if there are errors, return the site user immediately
        if (hasErrors(contacts[0], sUser)) return sUser;
        return sUser;
    }
    /**
     *  @description    : This method is used to listen the command and insert/delete site preferences records.  
     *
     *  @args           :  
     * 
     *  @return         :  void
     * 
     *   @Revision Log   :  V1.0 - Created By - Dipesh Gupta - CR-20191011-13407 - 30/01/2020.
     **/
    public Static SiteUser ACTION_UpsertDeleteMenuCustomization (SiteUser sUser) {        //List to hold the site Preference records which has to be insert.
        List<Site_Preference__c> sitepreferencesToBeInserted = new List<Site_Preference__c>();
        //List to hold the site Preference records which has to be delete.
        List<Site_Preference__c> sitepreferencesToBeDeleted = new List<Site_Preference__c>();
        //Map of guid with wrapper class which hold Id and post title 
        Map<String, SitePostWrapper> mapOfIdsWithMenuCustomization = new Map<String,SitePostWrapper>();
        //Map of guid with Site content
        Map<String, Site_Content__c> mapSiteContent = new Map<String, Site_Content__c>();
        string queryString = CONTACTBASEQUERY 
                            + ' WHERE Id IN (SELECT Contact__c FROM Site_Profile__c WHERE User_Id__c = \'' + sUser.User_Id + '\' ' 
                            +')';
        List<Contact> contacts =  database.query(queryString);
        if (contacts.size() > 0) {
            // populate the sUser record from fields on the contact
            sUser = getSiteUser(contacts[0], sUser, true);
            //Check for the command.
            if(sUser.command == 'updateMenuCustomization') 
            {
                //Loop to itterate list of menu customization 
                for(SitePostWrapper menuCustomization : sUser.MenuCustomizations)
                {
                    //Adding Menu Customization Ids with instance
                    mapOfIdsWithMenuCustomization.put(menuCustomization.id_x,menuCustomization);
                }
                if(mapOfIdsWithMenuCustomization.size() > 0)
                {
                    //Getting Site content 
                   SiteContentHelper sch = new SiteContentHelper(sUser, mapOfIdsWithMenuCustomization);
                   mapSiteContent = sch.mapSiteContent;
                }
                if(mapSiteContent.size() > 0 )
                {   
                    //Set to hold GUID
                    Set<String> setContentGUIDs = new Set<String>();
                    Set<String> setExistingGUIDPrefernce = new Set<String>();
                    
                    //Loop on the map to get the GUID of Site content. 
                    for(Site_Content__c sC : mapSiteContent.values()) {
                        setContentGUIDs.add(sC.GUID__c);
                    }
                    
                    //Query on the site preference to know the site preferece. 
                    for(Site_Preference__c sP : [Select Id, Site_Content__r.GUID__c 
                                                 From Site_Preference__c 
                                                 Where Site_Profile__c =: sUser.Site_Profile.Id
                                                AND Type__c = 'Menu Customization']) {
                        
                        setExistingGUIDPrefernce.add(sP.Site_Content__r.GUID__c);    
                    }
                    
                     //Loop over site content
                    for(String id_x : mapSiteContent.keySet()){
                        
                        if(!setExistingGUIDPrefernce.contains(id_x)) {
                            //Create New Site Preference Record.
                            Site_Preference__c sitePreference = new Site_Preference__c();
                            sitePreference.Contact__c = contacts[0].Id;
                            sitePreference.Site_Content__c = mapSiteContent.get(id_x).Id;
                            sitePreference.Site_Profile__c = sUser.Site_Profile.Id;
                            sitePreference.Type__c = 'Menu Customization';
                            
                            //Adding site preference to be insert          
                            sitepreferencesToBeInserted.add(sitePreference);
                            
                            setExistingGUIDPrefernce.add(id_x);
                        }
                    }
                }
                //List of site preferences that needs to be deleted
                for(Site_Preference__c sPreferences : [SELECT Id, Site_Content__c, Site_Profile__c From Site_Preference__c 
                                                       WHERE Site_Content__r.GUID__c NOT IN : mapOfIdsWithMenuCustomization.keySet()
                                                       AND Type__c = 'Menu Customization'
                                                       AND Site_Profile__c = :sUser.Site_Profile.Id])
                {
                    //Adding site preference to be delete          
                    sitepreferencesToBeDeleted.add(sPreferences);
                }
                if(sitepreferencesToBeInserted.size() > 0)
                {
                    //Inserting
                    insert sitepreferencesToBeInserted;       
                }
                if(sitepreferencesToBeDeleted.size() > 0)
                {
                    //Deleting
                    delete sitepreferencesToBeDeleted;       
                }   
                //populate the SiteUser record from fields on the contact
                sUser = getUpdatedSiteUserDetails(contacts[0].Id, sUser);
                    sUser.Response = RESPONSE_SUCCESS;
            }
        }
        else 
        {
            sUser.Response = 'invalid user Id: ' + sUser.User_Id;
        }
        return sUser;
    }
    
    /**
    *  @description    : This method is used to listen the command and insert site profile records on check of company Email for 
    *                    Related or Existing Contact.  
    *
    *  @args           :  SiteUser
    * 
    *  @return         :  String
    * 
    *   @Revision Log  :  V1.0 - Abhinav Sharma - CR-20200714-14306 - 8/13/2020 
    **/ 
    public static String checkEmailRelatedExisting_ContactOrSPs(SiteUser sUser){
        
        String response  = '';
        If(String.isNotBlank(sUser.email)){
            boolean isEligibleDomain = false;
            List<Contact> listOfContacts = [Select Id,Name,Company_Email__c,EAB_com_Site_Profile__c,accountId From Contact Where Company_Email__c =: sUser.email];
            if(listOfContacts != null && listOfContacts.size() == 1 && String.isNotBlank(listOfContacts[0].EAB_com_Site_Profile__c)){
                    response = System.Label.Contains_Site_Profile;
              
            }
            
        }
        return response;
    }
}