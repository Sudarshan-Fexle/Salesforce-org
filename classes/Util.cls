public class Util {
    /*
    Purpose:    Utility class to serve as a class to store methods that are commonly used as well as provide static variables to bypass triggers when necessary.
    
    Create By:          Jeremy Nottingham (SAP)
    
    Last Modified By:   Jeremy Nottingham (SAP) - 5/13/2011
    
    Current Version:    V1.1
    
    Revision Log:       V1.0 - (NB) Created code
                        V1.1 - (NB-2011-01-27) Added header, code comments, and reviewed code coverage
                        V1.2 - (JN 5/13/11) Removed call to reset recordtypes settings from recordtypemap()
                        V1.3 - (Bhavi 02/07/2012) Added a new flag "IsMembershipOwnerTrigger"
                        V1.4 - (Bhavi 07/12/2013) Added new Key & values in map (makeMembershipsforAccounts) - CR-20130531-3103
                        V1.5 - (Abhinav Sharma 02/12/2014) - If there are failures in the database.saveResults[], they should be recorded and emailed to SFAdmin.  (sendBatchStatus) - CR-20130718-3280
                        v1.6 -  Added new methods (IsWeekendDay & AddBusinessDays) - Abhinav Sharma - 07/04/2014 - CR-20140629-6015
                        V1.7 -  Modified By - Subhash Garhwal - 07/06/2015 - CR-20150618-9014 - New method added - parseNull
                        V1.8 -  Modified By - Mahendra Swarnkar - 12/07/2015 - CR-20151109-9376 - New method added - formatToAlphabatical
                        V1.9 -  Modified By - Mahendra Swarnkar- CR-20160428-9806 - 5/9/2016 - Transformed makeMembershipsforAccounts method into a simple apex method 
                                    that will call Batch_Create_Memberships batch to create memberships
                        V1.10 -  Modified By - Mahendra Swarnkar- CR-20160425-9796 - 5/23/2016 - updated teh getter/setter method "accountRT2SegmentMap" to add "US Independent School" => "US Independent School".
                        V1.11 -  Modified By - Mahendra Swarnkar- CR-20160609-9913 - 7/7/2016 - Added method "companyHolidays" and "IsNotACompanyHoliday" and modify the existing method "AddBusinessDays".
                        V1.12 -  Modified By - Abhinav Sharma - CR-20160114-9520 - 08/23/2016 - Added following three methods.
                                               1 - "IsACompanyHoliday" - To check whether company holiday
                                               2 - "calculateBusinessHoursInMinute" - To calculate business hours
                                               3 - " businessHoursForStartAndEndDate" - To calculate business hours b/w two dates
                        V1.13 -  Modified By - Mahendra Swarnkar - CR-20160729-10075 - 08/27/2016 - Added a new method "isProductionInstance" to identify SB/Production Instance.
                        V1.14 -  Modified By - Rajeev Jain - CR-20161209-10535 - Services Excellence - Hypercare A - 12/12/2016 - Added new Method to Calculate Business Days between two dates
                        V1.15 -  Modified By - Abhinav Sharma - 12/09/2016 - CR-20160111-9502 - Added a new method - HtmlToText
                        V1.16 -  Modified By - Mahendra Swarnkar - CR-20161102-10332 - 1/19/2017 - Comment out "CRMfusionDBR101.DB_Globals.triggersDisabled"
                        V1.17 -  Modified By - Subhash Garhwal - 02/01/2017 - CR-20160509-9842
                        V1.18 - Manual Merged By - Rajeev Jain - 03/28/2016 - Revenue/Rec Deployment to Prod
                        V1.19 - Modified By - Subhash Garhwal - CR-20170302-10729 - Issue--CR10729--UAT--00003766 - 03/20/2017 - Added new method getPicklistValues
                        V1.20 - Modified By - Abhinav Sharma - CR-20170508-10905 - Added new method/variable - EXECUTE_TRIGGER, getConfigManagerByParameterKeyAndValue, MAP_CONFIGURATION_MANAGER
                        V1.21 - Modified by - Saurabh Kumar - 06/05/2017 - CR-20170403-10808 (DS114) - Method "membershipOwnerCheckfromOpps" , "membershipOwnerCheckfromMemberships" updated
                        V1.22 - Modified By - Colin McGloin - 08/28/2017 - Issue--CR11156--QA--00005594 - Added areTriggersOnThisObjectBypassed to allow certain trigger processes to be bypassed
                        V1.23 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Updated the "areTriggersOnThisObjectBypassed" to add bypass logic to all triggers
                        V1.24 - Modified By - Subhash Garhwal - 10/06/2017 - Apollo Release - Added a generic method to update Entity field.
    			V1.25 - Modified By - Abhinav Sharma - CR-20180813-12500. - New mapping added - Graduate Education => Graduate Education  accountRT2SegmentMap
    			V1.26 - Modified By - Subhash Garhawal - 10/11/2018 - CR-20180720-12456
    			V1.27 - Modified By - Subhash Garhwal - 11/14/2018 - CR-20180504-12213 - Added flag ByPassDLRSMembershipTrigger
    			V1.28 - Modified By - Victor Hanson - 04/07/2020 - CR-20200304-13828 - Added sobjectFieldSetNameWithSetOfFieldsAPIName
			V1.29 - Modified By - Abhinav Sharma - CR-20200717-14331
			V1.30 - Modified By - Neha Sharma - 11/03/2020 - CR-20200930-14569 - Commented out membershipOwnerCheckfromMemberships which is used to update Membership Owner
			V1.31 - Modified By - Mahendra Swarnkar - 03/04/2020 - CR-20200217-13756 : 'US Provider - System','US Provider Strategic', US Provider - Hospital
			V1.32 - Modified By - Saurabh Kumar - 12/07/2020 - MRS2.0
            		V1.33 - Modified By - Neha Sharma - 10/03/2021 - CR-20200814-14435 - Remove the Commented out membershipOwnerCheckfromMemberships which is used to update Membership Owner
			V1.34 - Modified By - Saurabh Kumar - 03/30/2021  - CR-20201116-14696 - Added method getExistingRegistrationOrCampaignMember()
            		V1.35 -  Modified By - Chirag Soni - 10/26/2021 - CR-20211025-15548 - Added new variables IsInviteSent and IsRegisteredOnZoom.
					V1.36 - Modified By - Chirag Soni - 05/11/2022 - CR-20220429-16152 - Modified method getExistingRegistrationOrCampaignMember, Added new set of contact ids and added 

	*/
    
    public class CustomException extends Exception {}
    public static Boolean IsTesting = false; //flag for triggers: this is just a test, don't do crazy things.
    public static Boolean IsBatch = false; // calling trigger from a batch, no reaction necessary
    public static Boolean IsBreakMe = false; // for testing, request to throw an exception
    public static Boolean ScheduleHasRun = false; //testing Scheduled Apex 
    public static Boolean TrackHistoryHasRun = false;
    public static String TestVariable = ''; //testing various

    //Added By - Chirag Soni - 10/26/2021 - CR-20211025-15548 -
    public static Boolean IsInviteSent = false;
    public static Boolean IsRegisteredOnZoom = false;

        
    //Added By - Subhash Garhawal - 10/11/2018 - CR-20180720-12456
    public static Boolean BYPASS_DLRS_ABC_REVENUE_RECOGNITION_BATCH = false;
    public static Boolean BYPASS_CONTRACT_TRIGGER = false;
    public static Boolean BYPASS_SUBSCRIPTION_TRIGGER = false;
    
    // V1.23 - Modified By - Subhash Garhwal - 10/06/2017
    public static Boolean IsBypassEntityLogic = false; //flag for Entity Method to bypass
    
    //Various trigger flags to avoid unnecessary cascades
    public static Boolean IsMembershipOwnerAssociateTrigger = false;
    public static Boolean IsTrigger_WarmLeadMtM = false;
    public static Boolean IsTrigger_EventPrewire = false;
    public static Boolean IsTrigger_EventUpdateFields = false;
    public static Boolean IsTrigger_NBBOppFields = false;
    public static Boolean IsTrigger_ContractFieldUpdate = false;
    public static Boolean IsTrigger_ContractIntegratedAcctRunning = false;
    public static Boolean IsTestingContractIntegratedAcct = false; // Used in Test Method for Contract Integrated Accounts Update Fields and related trigger
    public static Boolean IsTrigger_AccountNameEAMemberships = false;
    public static Boolean IsTrigger_Opportunity_ValidationAndFieldUpdates = false;
    public static Boolean IsTrigger_Task_PopulateNoOfRevisitField = false;
    public static Boolean BypassAllTriggers = false;
    public static Boolean BypassContactRestrictionTrigger = false;
    public static Boolean IsTrigger_Invoice = false; // FOR FFDC fix
    public static Boolean isPopulateInitVisitOnActivities_Future = false;
    public static Boolean isShadowContractABC = false; //Added by Colin McGloin 07/27/2017 - Issue--CR11081--QA--00005146 - Skip various Membership Trigger work is this is related to a Shadow Contract ABC
    public static boolean bypassEntityPopulation = false;//Added by VH 10/20/2017 - Issue--CR11556--QA--00007048
    
    //V_1.22 Added by Dipesh Gupta - 09/28/2017 - CR-20170907-11182
    public static Boolean ByPassDLRSForTest = false;
    
    //Added By Subhash Garhwal - 11/14/2018 - CR-20180504-12213
    public static Boolean ByPassDLRSMembershipTrigger = true;
    
    // Modified By - Saurabh Kumar - 12/07/2020 MRS2.0
    public static Boolean byPassFromCustomComponent = false;
    
    public static void IsTest(boolean isRunningTest) {
        if (isRunningTest) {
            // bypass dupeblocker and other triggers
            //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
            Util.IsTesting = true;
        }
        else {
            // don't bypass dupeblocker
            //CRMfusionDBR101.DB_Globals.triggersDisabled = false;
            Util.IsTesting = false;
        }
    }
    
    public static void disableDupeBlocker(boolean disableDB) {
        if (disableDB) {
            // bypass dupeblocker
            //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        }
        else {
            // don't bypass dupeblocker
            //CRMfusionDBR101.DB_Globals.triggersDisabled = false;
        }
    }
    
    public static map<String, Id> recordtypemap(String Obj) 
    {
        map<String, Id> returnmap = new map<String, Id>();
        Map<String,Schema.RecordTypeInfo> mapRecordTypeInfo = Schema.getGlobalDescribe().get(Obj).getDescribe().getRecordTypeInfosByName();
        for(Schema.RecordTypeInfo rTypeInfo : mapRecordTypeInfo.values()) {
                
                returnmap.put(rTypeInfo.getName() , rTypeInfo.getRecordTypeId());
            }
        return returnmap;   
    }
    
    //Subhash Garhwal - 10/06/2017 - Apollo
    public static Map<Id, String> mapRecordTypes(String Obj) {
        
        //Map to hold record Types
        Map<Id, String> mapRecordTypes = new Map<Id, String>();
        Map<String,Schema.RecordTypeInfo> mapRecordTypeInfo = Schema.getGlobalDescribe().get(Obj).getDescribe().getRecordTypeInfosByName();
        for(Schema.RecordTypeInfo rTypeInfo : mapRecordTypeInfo.values()) {
                
                mapRecordTypes.put(rTypeInfo.getRecordTypeId(), rTypeInfo.getName());
            }
        return mapRecordTypes;
    }
    
    public static Id RecordTypeId(String Obj, String RecordTypeName) 
    {   
        //Added If Condition to check if the record type name is changes we do not get the Null Pointer Exception. - Dipesh Gupta - 05/03/2019
        if(Schema.getGlobalDescribe().get(Obj).getDescribe().getRecordTypeInfosByName().get(RecordTypeName) != null){
            Id rTypeId = Schema.getGlobalDescribe().get(Obj).getDescribe().getRecordTypeInfosByName().get(RecordTypeName).getRecordtypeId();               
            return rTypeId;
        }
        
        return null;
            
    }
    
    public static void resetRecordtypeSettings(){}
    
    //Commented by Mahendra Swarnkar - 03/04/2020 - CR-20200217-13756 : 'US Provider - System','US Provider Strategic', US Provider - Hospital
    //US Physician Practice, US HCIC, International Provider, International Physician Practice
    //Updated By Abhinav Sharma - CR-20180813-12500. - New mapping added - Graduate Education => Graduate Education  accountRT2SegmentMap
    // Account Record Type to Applicable Segment Map
    public static map<string, string> accountRT2SegmentMap {
        get {
            
            if (accountRT2SegmentMap == null) {
                
                //Modified By -Mahendra Swarnkar- CR-20160425-9796 - 5/23/2016 Added the Mapping ['US Independent School'=>'US Independent School']  
                accountRT2SegmentMap = new map<string, string> {
                    'International Corporate'=>'International Corporate',
                    'International Education'=>'International Education',
                    //'International HCIC'=>'International HCIC',
                    //'International Physician Practice'=>'International Physician Practice',
                    //'International Provider'=>'International Hospital',
                    'US Corporate'=>'US Corporate',
                    'US Education'=>'US Education',
                    //'US HCIC'=>'US HCIC',
                    'US Provider'=>'US Hospital',
                    //'US Provider - System'=>'US Hospital',
                    //'US Provider - Hospital'=>'US Hospital',
                    //'US Provider Strategic'=>'US Hospital',
                    //'US Physician Practice'=>'US Physician Practice',
                    'US Independent School'=>'US Independent School',
                    'Other'=>'Other',
                    //'US Physician Practice - Network'=>'US Physician Practice - Network',
                    //Added a new mapping - CR-20180813-12500.
                    'Graduate Education' => 'Graduate Education'
                 };
            }
            
            return accountRT2SegmentMap;
        }
        set;
    }
    
    /*Updated By -Mahendra Swarnkar- CR-20160428-9806 - 5/9/2016 - Transformed this method into a simple apex method 
     *   that calls Batch_Create_Memberships batch to create memberships 
    */
    //Code modified By - Bhavi Sharma - CR-20130531-3103
    //Key and Value('US Provider Strategic'=>'US Hospital') assign in map instance for generate Membership record
    //on Account of "US Provider Strategic" type
    public static void makeMembershipsforAccounts(set<id> accountIds) {
        
        //String to hold the Coma saparated Account Ids
        String idString = '';
        
        //Check for Size
        if(accountIds != null && accountIds.size() > 0){
             
            //Loop through Acount Ids 
            for(ID str : accountIds)
                idString += '\'' + String.valueof(str) + '\',';
    
            idString = idString.lastIndexOf(',') > 0 ? '(' + idString.substring(0,idString.lastIndexOf(',')) + ')' : idString ;
            
            //Check for emptyness of string
            if(String.isNotEmpty(idString)) {
                
                //Query string for Batch
                String queryStr = 'Select ID, Name, Recordtype.Name FROM Account WHERE ID != null AND ID IN ' + idString;
                
                //Batch Instance 
                Batch_Create_Memberships con = new Batch_Create_Memberships();
                con.soqlstr = queryStr;
                
                //Execute the batch to create the Membership records
                Database.executeBatch(con, Integer.valueOf(System.Label.SIZE_FOR_BATCH_CREATE_MEMBERSHIPS));   
            }
        }
    }
    
    @future 
    public static void deleteMemberships(set<id> MembershipIds)
    {
        list<Membership__c> membershipstodelete = [select id from Membership__c where id in :MembershipIds];
        delete membershipstodelete;
    }
    
    @future
    public static void membershipOwnerCheckfromOpps(set<id> selectoppids) {
        
        //Checking set for its size
        if(selectoppids.size() > 0) {
            
            //For the Opportunity IDs presented, if it is a Renewal Opportunity on a Contract that is Active_Contract_Idenfied__c on a (Prospect Status) Membership, 
            //change the owner on that Membership to be the owner on the renewal Opportunity
        
            //V1.20 - Modified by - Saurabh Kumar - 06/05/2017 - CR-20170403-10808 (DS114)
            List<Membership__c> memstocheck = new List<Membership__c>();
            List<Membership__c> memberships = new List<Membership__c>();
        
            //Get list of Memberships by querying Subscription and then Memberships
            Map<Id, SBQQ__Subscription__c> mapSubscriptions = new Map<Id, SBQQ__Subscription__c>([SELECT ID, Renewal_Opportunity__r.Membership__c 
                                                                                                    FROM SBQQ__Subscription__c
                                                                                                    WHERE Renewal_Opportunity__c != null
                                                                                                    AND Renewal_Opportunity__c IN : selectoppids]);
            
            //Checking for map size
            if(mapSubscriptions.size() > 0) {
                
                memberships = [SELECT ID, Assigned_Marketer__r.IsActive, Membership_Status__c, OwnerID, Active_Contract_Idenfied__c, 
                                    Active_Subscription__c, Active_Subscription__r.Renewal_Opportunity__c, 
                                    Active_Subscription__r.Renewal_Opportunity__r.OwnerID, Active_Subscription__r.Renewal_Opportunity__r.StageName, Assigned_Marketer__c, 
                                    Active_Subscription__r.Renewal_Opportunity__r.Owner.IsActive
                                FROM Membership__c
                                WHERE Active_Subscription__c != null AND Active_Subscription__c IN :mapSubscriptions.keySet()]; 
            }
            
            //V1.20 - Modified by - Saurabh Kumar - 06/05/2017 - CR-20170403-10808 (DS114) - Upto here
            else {
            
                //Get list of Memberships by querying Contracts and then Memberships
                Map<Id, Contract__c> cons = new Map<Id, Contract__c>([SELECT ID, Contract_Renewal_Opportunity__r.Membership__c 
                                                                        FROM Contract__c 
                                                                        WHERE Contract_Renewal_Opportunity__c != null 
                                                                            AND Contract_Renewal_Opportunity__c IN : selectoppids]);
                
            
                memstocheck = [SELECT ID, Assigned_Marketer__r.IsActive, Membership_Status__c, OwnerID, Active_Contract_Idenfied__c, Active_Subscription__c, 
                                    Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__c, 
                                    Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerID, 
                                    Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.StageName, Assigned_Marketer__c, 
                                    Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.Owner.IsActive
                                FROM Membership__c
                                WHERE Active_Contract_Idenfied__c != null AND Active_Contract_Idenfied__c IN : cons.keySet()];  
            }  

            //Map of membership to update
            Map<Id, Membership__c> memstoupdate = new Map<Id, Membership__c>();
            
            //V1.20 - Modified by - Saurabh Kumar - 06/05/2017 - CR-20170403-10808 (DS114)
            //Processing on the memberships which were extracted via Subscription otherwise processing on the memberships which were extrated via Contract
            if(memberships.size() > 0){
            
                //Go through Memberships to see if any need changed
                for (Membership__c membership : memberships) {
                    
                    // Set the Membership's Owner equal to the Active Contract's Renewal Opp Owner, if there is an active contract with a renewal Opp.
                    if ((membership.Active_Subscription__c != null) && (membership.Active_Subscription__r.Renewal_Opportunity__c != null))
                    {
                        if ((membership.Membership_Status__c.toLowerCase() == Constants.MEMBER_INTEGRATED_GRACE ||
                                membership.Membership_Status__c.toLowerCase() == Constants.MEMBER_PAYER_GRACE || membership.Membership_Status__c.toLowerCase().contains('prospect')) &&
                                !membership.Active_Subscription__r.Renewal_Opportunity__r.stageName.toLowerCase().contains('pending')) {
                            
                            //Sets the Owner equal to the Assigned Marketer, if there is one.
                            if ((membership.Assigned_Marketer__c != null) && (membership.OwnerID != membership.Assigned_Marketer__c)) {
                                
                                if (membership.Assigned_Marketer__r.IsActive) {
                                    membership.OwnerID = membership.Assigned_Marketer__c;
                                    memstoupdate.put(membership.Id, membership);        
                                }
                            }
                        }
                        else if (membership.Active_Subscription__r.Renewal_Opportunity__r.Owner.IsActive) {
                            if(membership.OwnerID != membership.Active_Subscription__r.Renewal_Opportunity__r.OwnerID) {
                                membership.OwnerID = membership.Active_Subscription__r.Renewal_Opportunity__r.OwnerID;
                                memstoupdate.put(membership.Id, membership);            
                            }
                        }
                    }
                }   
            }
        
            //V1.20 - Modified by - Saurabh Kumar - 06/05/2017 - CR-20170403-10808 (DS114) - Upto here
            else {
                
                //Go through Memberships to see if any need changed
                for (Membership__c m : memstocheck) {
                    
                    // Set the Membership's Owner equal to the Active Contract's Renewal Opp Owner, if there is an active contract with a renewal Opp.
                    if ((m.Active_Contract_Idenfied__c != null) && (m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__c != null))
                    {
                        //V1.20 - Modified by - Saurabh Kumar - 06/05/2017 - CR-20170403-10808 (DS114) -- Added a condition for "Membership_Status__c" to check for blank/null 
                        if (
                            String.isNotBlank( m.Membership_Status__c)
                            &&
                            (
                                m.Membership_Status__c.toLowerCase() == Constants.MEMBER_INTEGRATED_GRACE 
                                || m.Membership_Status__c.toLowerCase() == Constants.MEMBER_PAYER_GRACE 
                                || m.Membership_Status__c.toLowerCase().contains('prospect')
                            ) 
                            &&
                            !m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.stageName.toLowerCase().contains('pending')
                        ) {
                                    
                            //Sets the Owner equal to the Assigned Marketer, if there is one.
                            if ((m.Assigned_Marketer__c != null) && (m.OwnerID != m.Assigned_Marketer__c)) {
                                if (m.Assigned_Marketer__r.IsActive) {
                                    m.OwnerID = m.Assigned_Marketer__c;
                                    memstoupdate.put(m.Id, m);
                                }
                            }
                        }
                        else if (m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.Owner.IsActive) {
                            if(m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerID != m.OwnerID) {
                                m.OwnerID = m.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerID;
                                memstoupdate.put(m.Id, m);
                            }
                        }
                    }
                }
            }
        
            if (memstoupdate.size() > 0) {
                Util.byPassAlltriggers = true;
                update memstoupdate.values();
                Util.byPassAlltriggers = false;     
            }
        }
    }
     
    
    public static Messaging.SingleEmailMessage createSingleEmail(List<String> recipients, String replyTo, String SenderName, String subject, String message)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        try
        {
            for(String recipient : recipients)
            {
                if(!isValidEmailAddress(recipient))
                {
                    throw new CustomException(recipient + ' is not a valid email address.');
                }
            }
            if(!isValidEmailAddress(replyTo))
            {
                throw new CustomException(replyTo + ' is not a valid email address.');
            }
            mail.setToAddresses(recipients);
            mail.setReplyTo(replyTo);
            mail.setSenderDisplayName(SenderName); 
            mail.setSubject(subject);
            mail.setPlainTextBody(message);
            mail.setHtmlBody(message);
            return mail;
         }
            catch(CustomException e)
            {
                System.debug('***** Error in createSingleEmail: ' + e.getMessage());
                return null;
            }
    }
    
    public static boolean sendSingleEmail(Messaging.SingleEmailMessage email)
    {
        try
        {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            if(results.get(0).isSuccess())
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        catch(System.EmailException e)
        {
            System.debug('***** Error in sendSingleEmail: ' + e.getMessage());
            return false;
        }
    }
    
    // make sure that this is a valid email address
    public static boolean isValidEmailAddress(String emailAddress)
    {
        Pattern emailRegex = Pattern.compile('[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}');
        Matcher regexMatcher = emailRegex.matcher(emailAddress);
        if(regexMatcher.matches())
        {
            return true;
        }
        else
        {
            return false;
        }
    } 
    
    // verify that the user has the required permissions on the object
    // @param accessLevel can be: PermissionsRead, PermissionsCreate, PermissionsDelete
    public static Map<String, String> CheckUserPermission(String userId, List<String> objectNames, String accessLevel) {
        // add all object names to the map and associated set (used for query)
        Map<String, String> objToAccessMap = new Map<String, String>();
        for (String objName : objectNames) objToAccessMap.put(objName, '');
        Set<String> objectNameSet = objToAccessMap.keySet();
        Set<String> validAccessLevelOptions = new Set<String> { 'PermissionsRead', 'PermissionsCreate', 'PermissionsDelete' };
        if (userId == null || ObjectNames == null || ObjectNames.size() == 0 || !validAccessLevelOptions.contains(accessLevel)) {
            objToAccessMap = new Map<String, String> { 'Error' => 'invalid data' };
            return objToAccessMap;
        }
        
        boolean isRead, isCreate, isDelete;
        if (accessLevel.contains('PermissionsRead')) isRead = true;
        else if (accessLevel.contains('PermissionsCreate')) isCreate = true;
        else if (accessLevel.contains('PermissionsDelete')) isDelete = true;
        
        try {
            List<User> users = [SELECT Id, ProfileID, Name FROM User WHERE Id = :userId and IsActive = true LIMIT 1];
            if (users.size() == 0){
                objToAccessMap = new Map<String, String> { 'Error' => 'Invalid User Id:' + userId };
                return objToAccessMap;
            }
            
            // set of all unique permission set ids
            Set<Id> permSetIdSet = new Set<Id>();
            // get permission set assignments for one-off permission sets
            List<PermissionSetAssignment> psAssignments = [SELECT AssigneeId, PermissionSetId 
                                                           FROM PermissionSetAssignment 
                                                           WHERE AssigneeId = :users[0].Id];
            for (PermissionSetAssignment psa : psAssignments) permSetIdSet.add(psa.PermissionSetId);
            //get all profile permissions
            map<Id, PermissionSet> profPermissionSets = new map<Id, PermissionSet>([select id from permissionset where PermissionSet.ProfileId = :users[0].ProfileId]);
            permSetIdSet.addAll(profPermissionSets.keySet());
            
            // get the user's object level permissions
            Id profileId = users[0].ProfileId;
            String permissionQuery = 'SELECT Id, SObjectType, PermissionsRead, PermissionsCreate, PermissionsDelete ' +
                                 'FROM ObjectPermissions ' +
                                 'WHERE parentId IN :permSetIdSet ' +
                                 ' AND sObjectType IN :objectNameSet AND ' + accessLevel + ' = true';
            
            // query for object permissions for this user's profile
            List<ObjectPermissions> ops = database.query(permissionQuery);
            system.debug('@@op:' + ops);
            for (ObjectPermissions op : ops) {
                if (op.PermissionsRead && isRead) {
                    objToAccessMap.put(op.SObjectType, 'true');
                }
                else if (op.PermissionsCreate && isCreate) {
                    objToAccessMap.put(op.SObjectType, 'true');
                }
                else if (op.PermissionsDelete && isDelete) {
                    objToAccessMap.put(op.SObjectType, 'true');
                }
                else {
                    objToAccessMap.put(op.SObjectType, 'false');
                }
            }
        }
        catch(exception ex) {
            objToAccessMap.put('Error', ex.getMessage() + '  Stack Trace:' + ex.getStackTraceString());
        }
        
        return objToAccessMap;
        
    }
    
    //Code added by - Bhavi Sharma - 07/11/2013
    //Method for create log of DML insert or update opertion
    public Static String createLog(Database.SaveResult[] saveResults) {
        
        //String to hold Log message
        String logMessage = '';
            
        // Iterate through each returned result
        for (Database.SaveResult saveResult : saveResults) {
            
            //Check for successing
            if (!saveResult.isSuccess()) {
                
                //Operation failed, so get all errors
                for(Database.Error err : saveResult.getErrors()) {
                    
                    //create log message 
                    logMessage += err.getStatusCode() + '&nbsp;' + err.getMessage() + '<br>';
                }
            }
        }
        
        //return logmessage
        return logMessage;
    }
    
    //Code added by - Bhavi Sharma - 07/11/2013
    //Method for create log of DML delete opertion
    public Static String createLog(Database.DeleteResult[] deleteResults) {
        
        //String to hold Log message
        String logMessage = '';
        
        //Iterate through each returned result
        for(Database.DeleteResult deleteResult : deleteResults) {
            
            //Check for success
            if (!deleteResult.isSuccess()) {
            
                //Operation failed, so get all errors
                for(Database.Error err : deleteResult.getErrors()) {
                    
                    //create log message 
                    logMessage += err.getStatusCode() + '&nbsp;' + err.getMessage() + '<br>';
                }
            }
        }
        
        //return logmessage
        return logMessage;
    }
    
    //Code added by - Bhavi Sharma - 07/11/2013
    //Method for create log of DML upsert opertion
    public Static String createLog(Database.UpsertResult[] upsertResults) {
        
        //String to hold Log message
        String logMessage = '';
        
        //Iterate through each returned result
        for(Database.UpsertResult upsertResult : upsertResults) {
            
            //Check for success
            if (!upsertResult.isSuccess()) {
            
                //Operation failed, so get all errors
                for(Database.Error err : upsertResult.getErrors()) {
                    
                    //create log message 
                    logMessage += err.getStatusCode() + '&nbsp;' + err.getMessage() + '<br>';
                }
            }
        }
        
        //return logmessage
        return logMessage;
    }
    
    /**
     *  @description    :   Method for create log of DML opertion errors in HTML format.
     *
     *  @args           :   Database.Errors[]
     *
     *  @return         :   String
     *
     **/
    public Static String errorHTMLLog(Database.Error [] errors) {

        //String to hold Log message
        String errorHTMLLogs = '';

        //Operation failed, so get all errors
        for(Database.Error err : errors) {

            //create log message
            errorHTMLLogs += '<tr><td>' + err.getStatusCode() + '</td><td>' + err.getMessage() + '</td></tr>';
        }

        //Check if error log is not null
        if(errorHTMLLogs != '')
            errorHTMLLogs = '<table border="1"><tr><th>StatusCode</th><th>Message</th></tr>' + errorHTMLLogs + '</table>';

        //return logmessage
        return errorHTMLLogs;
    }

    /**
     *  @description    :   This method is to send the batch status email
                            Example:
                            global void finish(Database.BatchableContext ctx) {
     *
     *                          Utility.sendBatchStatus(ctx.getJobId(), 'Batch_Example', errors);
     *                      }
     *
     *  @args           :   Batch Id, Batch Name, message
     *
     *  @return         :
     *
     **/
    public Static void sendBatchStatus(Id batchJobId, String batchName, String errors) {

        //Query the asynchronous jobs results
        AsyncApexJob aSyncJob = [SELECT Id, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedBy.Email FROM AsyncApexJob
                            WHERE id = :batchJobId];

        // Send email indicating the completion of this batch
        String emailMessage = 'Your batch job \"' + batchName + '\" has finished.  It processed job items'
                    + aSyncJob.totalJobItems +
                    ' batches.  Of which, '
                    + aSyncJob.JobItemsProcessed
                    + ' processed without any exceptions thrown and '
                    + aSyncJob.numberOfErrors
                    + ' batches threw unhandled exceptions.' + '<br>' + errors;

            //Send batch status to the person who executed this batch
        EmailHandler.sendEmail(aSyncJob.CreatedBy.Email, batchName + ' has been completed', emailMessage, errors);
    }
    
    //Added By - Abhinav Sharma - If there are failures in the database.saveResults[], they should be recorded and emailed to SFAdmin. - CR-20130718-3280
    /**
     *  @description    :   This method is to send the batch status email
                            Example:
                            global void finish(Database.BatchableContext ctx) {
     *
     *                          Utility.sendBatchStatus(ctx.getJobId(), 'Batch_Example', errors, 'test@test.com');
     *                      }
     *
     *  @args           :   Batch Id, Batch Name, message, emailRecipient
     *
     *  @return         :   void
     *
     **/
    public Static void sendBatchStatus(Id batchJobId, String batchName, String errors, String emailRecipient) {

        //Query the asynchronous jobs results
        AsyncApexJob aSyncJob = [SELECT Id, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedBy.Email FROM AsyncApexJob
                            WHERE id = :batchJobId];

        // Send email indicating the completion of this batch
        String emailMessage = 'Your batch job \"' + batchName + '\" has finished.  It processed job items'
                    + aSyncJob.totalJobItems +
                    ' batches.  Of which, '
                    + aSyncJob.JobItemsProcessed
                    + ' processed without any exceptions thrown and '
                    + aSyncJob.numberOfErrors
                    + ' batches threw unhandled exceptions.' + '<br>' + errors;

        //Send batch status to the person who executed this batch
        EmailHandler.sendEmail(emailRecipient, batchName + ' has been completed', '', emailMessage);
    }    
    
    //Added By - Abhinav Sharma - CR-20140629-6015 - 07/04/2014
    /**
     *  @description    :   This method will return true in case when date passed to it belongs to weekend.
     *
     *  @args           :   Date dateParam
     *
     *  @return         :   boolean
     *
     **/
    public static boolean IsWeekendDay(Date dateParam) {
        
        //Boolean variable will be set to true for weekend date
        Boolean result = false;
        
        //Recover the starting day of the week
        Date startOfWeek = dateParam.toStartOfWeek();
        
        //Days difference count in between the dates
        Integer dayOfWeek  = startOfWeek.daysBetween(dateParam);
        
        //Making decision on the basis of days difference count and accordingly setting the boolean variable 
        result = dayOfWeek == 0 || dayOfWeek == 6 ? true : false;
        
        //Returning resultant boolean value
        return result;
    }
    
    // Modified By - Mahendra Swarnakar - CR-20160609-9913 - 7/7/2016- Addedd logic to included the Company holidays to decide the deadline dates on records 
    //Added By - Abhinav Sharma - CR-20140629-6015 - 07/04/2014
    /**
     *  @description    :   Method responsible to add specific bussiness dayes in a date passed by user to it.
     *                      Will be helpful in setting deadline dates on records.
     *
     *  @args           :   Date startDate, Integer bussinessDaysToAdd
     *
     *  @return         :   Date
     *
    **/
    public static Date AddBusinessDays(Date startDate, Integer bussinessDaysToAdd) {
    
        //Checking variables for null value
        if(startDate != null && bussinessDaysToAdd != null) {
      
            //Add or decrease in BusinessDaysToAdd days 
            Date finalDate = StartDate;
            
            //Addition Direction
            Integer direction = bussinessDaysToAdd < 0 ? -1 : 1;

            //Making the days related calculations        
            while(bussinessDaysToAdd != 0) {
        
                //Adding days in user passed date value
                finalDate = finalDate.addDays(direction);
                
                //Modified By - Mahendra Swarnakar - CR-20160609-9913 - 7/7/2016 - Added an extra check to check for the Company holiday 
                //In case of week days reducing the count by direction value               
                if (!isWeekendDay(finalDate)  && IsNotACompanyHoliday(finalDate)) {
                    bussinessDaysToAdd -= direction;
                }
            }
            
            //Returning finally constructed date value
            return finalDate;
        }
        
        return null;
   }
   
    /**
     *  @description    :   This method is to get the Department Division Functions by Cost Center values
     *
     *  @args           :   Set of cost centers
     *
     *  @return         :   Map of Department_Division_Function__c
     *
     **/
    public static Map<String, Department_Division_Function__c> getDepartmentDivisionFunctionByCostCenter(Set<String> setCostCenter) {
        
        //Create a Map to hold the Custom Setting data
        Map<String, Department_Division_Function__c> mapDepartmentDivisionFunction = new Map<String, Department_Division_Function__c>();
        
        //Check for the settings
        if(setCostCenter == null || setCostCenter.size() == 0)
            return mapDepartmentDivisionFunction;
        
        //Get Custom Setting Data 
        for(Department_Division_Function__c dDF : [Select Id, Cost_Center__c, Intranet_Department__c, Intranet_Division__c, Intranet_Function__c from Department_Division_Function__c where Cost_Center__c != null AND Cost_Center__c IN: setCostCenter]) {
            
            //Add in map
            if(!mapDepartmentDivisionFunction.containsKey(dDF.Cost_Center__c))
                mapDepartmentDivisionFunction.put(dDF.Cost_Center__c, dDF);
        }
        
        //return mapDepartmentDivisionFunction
        return mapDepartmentDivisionFunction;
    }  
    
    //Added By - Abhinav Sharma - CR-20141218-8363 - 06/02/2015
    /**
     *  @description    :   Method to determine day value for a date
     *
     *  @args           :   Date dateValue
     *
     *  @return         :   String
     *
    **/
    public static String calculateDayOfDate(Date dateValue) {
        
        //String to hold the day value
        String dayValue = '';
        
        //Starting date
        Date startDate = date.newInstance(0001, 1, 1); 
        
        //List to hold the all days
        List<String> listDay = new List<String>{'Saturday' , 'Sunday' , 'Monday' , 'Tuesday' , 'Wednesday' , 'Thursday' , 'Friday'};
        
        //Determining day value for the date field
        Integer remainder = Math.mod(startDate.daysBetween(dateValue) , 7);
        dayValue = listDay.get(remainder);
        
        //returning day value
        return dayValue;
    } 
    
    //Added By - Abhinav Sharma - CR-20141218-8363 - 06/02/2015
    /**
     *  @description    :   Method to determine the difference in between two dates excluding weekends.
     *
     *  @args           :   Date sdate, Date edate
     *
     *  @return         :   Integer
     *
    **/
    public static integer bussinessDaysDifferenceInBetweenDates(Date sdate, Date edate) {
    
      //Processing dates for weekends
      if(Util.calculateDayOfDate(edate) == 'Saturday')
          edate = edate.addDays(+2);
          
      if(Util.calculateDayOfDate(edate) == 'Sunday')
          edate = edate.addDays(+1);
          
      if(Util.calculateDayOfDate(sdate) == 'Saturday')
          sdate = sdate.addDays(-1);
          
      if(Util.calculateDayOfDate(sdate) == 'Sunday')
          sdate = sdate.addDays(-2);
      
      //Total Days in between dates
      integer wDay = sdate.daysBetween(edate) ;
      
      //Weekends days
      integer count = 0;
      
      //Positive use cases
      if(sdate < edate) {
          while (sdate < edate) {
              if (Util.IsWeekendDay(sdate))
                  count = count + 1;
              sdate = sdate.addDays(1);
          }
      }
      
      //Negative use cases
      if(sdate > edate) {
          while (edate < sdate) {
              if (Util.IsWeekendDay(edate))
                  count = count + 1;
              edate = edate.addDays(1);
          }
      }
     
     //Returning the bussiness days difference in between two dates
     if(wDay > 0)
         return (wDay-count);
     else if(wDay < 0)
         return (wDay+count);
     else
         return 0;
    }
    
    /**
      * @Description    :   Check for Null and if yes, then return blank
      *
      * @args           :   String
      *
      * @return         :   string
      *
      **/
    public static String parseNull(String value) {
     
        //Return blank if value is null
        if(value == null)
            return '';
  
        //return original value
        return value;
    }
    
    /**
      * @Description    :   Remove the special characters and digits, then return the formatted value
      *
      * @args           :   String
      *
      * @return         :   string
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - 12/07/2015 - CR-20151109-9376
      **/
    public static String formatToAlphabatical(String value) {
        if(String.isNotBlank(value))
            return (value.replaceAll('-', ' ')).replaceAll('[^a-zA-Z ]','');
        return value;
    }
    
    /**
      * @Description    :   Method to check that the respective date is a company holiday or not.
      *
      * @args           :   date,List<Case_Blackout_Date__c>
      *
      * @return         :   boolean
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - CR-20160609-9913 - 7/7/2016
      **/
    public static boolean IsNotACompanyHoliday(Date currentDate) {
        return true;
    }
    
    //Added By - Abhinav Sharma - 08/23/2016 - CR-20160114-9520
    /**
      * @Description    :   Method to check whether the respective date is a company holiday or not.
      * 
      * @args           :   Date currentDate
      *
      * @return         :   boolean
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - CR-20160114-9520 - 08/23/2016
    **/
    public static boolean IsACompanyHoliday(Date currentDate) {
        return false;
    }

    //Added By - Abhinav Sharma - 08/23/2016 - CR-20160114-9520
    /**
      * @Description    :   Method to calculate total of business hours in minute for Any time passed in ('8:30 AM/PM') format
      *
      * @args           :   Time in Local Time zone format (String businessTime)
      *
      * @return         :   Integer
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - CR-20160114-9520 - 08/23/2016
    **/
    //Calculate Business Hours in Minute
    public static Integer calculateBusinessHoursInMinute(String businessTime){
        
        //Split and identify AM and PM
        List<String> splittedBusinessTime = businessTime.split(' ');
        
        //Now split time in Hours and in Minute(e.g. 8:30 AM, here 8 is hour and 30 is minute)
        List<String> splittedTime = splittedBusinessTime[0].split(':');
        
        Integer totalHours = 0;
        
        ////8*60 - Minute
        //Calcualte Hours in minute based on AM and PM
        if(splittedBusinessTime[1].equalsIgnoreCase('AM') && splittedTime[0] != '12')
            totalHours = (Integer.valueOf(splittedTime[0])*60) + Integer.valueOf(splittedTime[1]);
        else if(splittedBusinessTime[1].equalsIgnoreCase('AM') && splittedTime[0] == '12')
            totalHours = Integer.valueOf(splittedTime[1]);
        
        ////(5+12)*60+30 - Minute*/             
        else if(splittedBusinessTime[1].equalsIgnoreCase('PM') && splittedTime[0] != '12')
            totalHours = ((Integer.valueOf(splittedTime[0])+12)*60) + Integer.valueOf(splittedTime[1]);
        else if(splittedBusinessTime[1].equalsIgnoreCase('PM') && splittedTime[0] == '12')
            totalHours = (12*60) + Integer.valueOf(splittedTime[1]);
            
        return totalHours;
    }
    
    //Added By - Abhinav Sharma - 08/23/2016 - CR-20160114-9520
    /**
      * @Description    :   Method to calculate total of business hours in minute for Start Date and End Date
      *
      * @args           :   Start DateTime, EndDateTime, Start BusinessHours In A DAY(e.g. 8:30 AM), 
      *                     End BusinessHours In A Day(e.g. 5:30PM)
      *
      * @return         :   Integer
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - CR-20160114-9520 - 08/23/2016
    **/
    public static Integer businessHoursForStartAndEndDate(DateTime startDateTime, DateTime endDateTime){
        
        Integer totalBusinesHoursMinute = 0;
        
        Integer startBuinessHoursMinute = Util.calculateBusinessHoursInMinute(Constants.START_BUSINESS_HOURS);
        Integer endBusinessHoursMinute = Util.calculateBusinessHoursInMinute(Constants.END_BUSINESS_HOURS);
        
        //Now loop between these days and calculate total business days
        for(Date init = startDateTime.date().addDays(1); init<endDateTime.date(); init = init.addDays(1)){
            
            //Skip any calculation if Date is in Weekday or Black Out day/Holiday
            if(Util.IsWeekendDay(init) || Util.IsACompanyHoliday(init))
                continue;
            
            totalBusinesHoursMinute += (endBusinessHoursMinute-startBuinessHoursMinute);
        }
        
        //Set Start Date Null if Start Date is in weekday and black out day
        startDateTime = Util.IsWeekendDay(startDateTime.date()) || Util.IsACompanyHoliday(startDateTime.date()) ? null : startDateTime;
        endDateTime = Util.IsWeekendDay(endDateTime.date()) || Util.IsACompanyHoliday(endDateTime.date()) ? null : endDateTime;
        
        //Check if Start Date Time and End Date Time Matches
        if(startDateTime != null && endDateTime != null && startDateTime.date() == endDateTime.date()){
            
            List<String> formatedStartDateTime = startDateTime.format().split(' ');
            Integer startTimeMinute = calculateBusinessHoursInMinute(formatedStartDateTime[1]+ ' ' + formatedStartDateTime[2]);
            
            List<String> formatedEndDateTime = endDateTime.format().split(' ');
            Integer endTimeMinute = calculateBusinessHoursInMinute(formatedEndDateTime[1] + ' ' + formatedEndDateTime[2]);
            
            //Add start date hourss
            if(startTimeMinute <= startBuinessHoursMinute && endTimeMinute >= endBusinessHoursMinute)
                totalBusinesHoursMinute += (endBusinessHoursMinute - startBuinessHoursMinute);
            else if(startTimeMinute <= startBuinessHoursMinute && endTimeMinute > startBuinessHoursMinute && endTimeMinute < endBusinessHoursMinute)
                totalBusinesHoursMinute += (endTimeMinute - startBuinessHoursMinute);
            else if(startTimeMinute > startBuinessHoursMinute && startTimeMinute < endBusinessHoursMinute && endTimeMinute >= endBusinessHoursMinute)
                totalBusinesHoursMinute += (endBusinessHoursMinute - startTimeMinute);
            else if(startTimeMinute > startBuinessHoursMinute && startTimeMinute < endBusinessHoursMinute && endTimeMinute > startBuinessHoursMinute && endTimeMinute < endBusinessHoursMinute)
                totalBusinesHoursMinute += (endTimeMinute - startTimeMinute);
                
        } else {
            
            //Calculalte if startDateTime is not null
            if(startDateTime != null){
                
                List<String> formatedStartDateTime = startDateTime.format().split(' ');
                Integer startTimeMinute = calculateBusinessHoursInMinute(formatedStartDateTime[1]+ ' ' + formatedStartDateTime[2]);
                
                //Add start date hourss
                if(startTimeMinute <= startBuinessHoursMinute)
                    totalBusinesHoursMinute += (endBusinessHoursMinute - startBuinessHoursMinute);
                else if(startTimeMinute > startBuinessHoursMinute && startTimeMinute < endBusinessHoursMinute)
                    totalBusinesHoursMinute += (endBusinessHoursMinute - startTimeMinute);
            }
            
            if(endDateTime != null){
                
                List<String> formatedEndDateTime = endDateTime.format().split(' ');
                
                Integer endTimeMinute = calculateBusinessHoursInMinute(formatedEndDateTime[1] + ' ' + formatedEndDateTime[2]);
                
                //Add End date hourss
                if(endTimeMinute >= endBusinessHoursMinute)
                    totalBusinesHoursMinute += (endBusinessHoursMinute - startBuinessHoursMinute);
                else if(endTimeMinute < endBusinessHoursMinute && endTimeMinute > startBuinessHoursMinute)
                    totalBusinesHoursMinute += (endTimeMinute - startBuinessHoursMinute);
                
            }   
        }
        
        return totalBusinesHoursMinute;
    }
     
    /**
      * @Description    :   Method to Identify for the Production OR Sandbox Instance.
      *
      * @args           :   
      *
      * @return         :   Boolean
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - CR-20160729-10075 - 08/27/2016
    **/
    public static Boolean IS_PRODUCTION_INSTANCE {

        get {
            Boolean IS_PRODUCTION_INSTANCE1;
            //Checking for the null value
            if(IS_PRODUCTION_INSTANCE1 == null) {
                
                //Setting flag value to false
                IS_PRODUCTION_INSTANCE1 = false;
            
                //Fetching organization related details
                List<Organization> organizations = [SELECT Id, IsSandbox  
                                                    FROM Organization 
                                                    LIMIT 1];
                
                //Checking for the list size and value
                if(organizations != null 
                   && organizations.size() > 0 
                   && organizations[0].IsSandbox == false)
                    IS_PRODUCTION_INSTANCE1 = true;   
        
            }
            
            //Return value
            return IS_PRODUCTION_INSTANCE1;
        }
    }
    
     
    
    /**
      * @Description    :   Calculate total no of business days between two dates. 
      *                     This method bypass Weekend days and Blackout days for actual business days calculation. 
      *                     We have to introduce this method, however there are already two methods to calculate business days.
      *                     Limitation to use those are as given below.
      *                     businessHoursForStartAndEndDate : This method calculate business days in roundoff and based on time to time
      *                     So we can't use this for calcualting actual business hours
      *                     bussinessDaysDifferenceInBetweenDates : This is only bypassing Weekend days, not company holidays
      *                     isHolidayNeededInCalulation(Added this flag - To do not give the responsibility to developer for querying holidays externally,
      *                     This will help us to save many holiday queries if same method is called multiple times in the Same Transactionss)
      *                     
      *
      * @args           :   
      *
      * @return         :   Boolean
      *
      * @Version        :   V1.0 - Created By - Rajeev Jain - CR-20161209-10535 - 12/12/2016
    **/
    public static Integer CalculateBusinessDays(Date startDate, Date endDate, Boolean isHolidayNeededInCalulation, Boolean excludeUserSpecificHoliday){
        
        //Hold Total No of days
        Integer businessdays = 0;
            
        //Check if Dealine field is not null then calculate business days difference
        //Now loop between these days and calculate total business days
        for(Date init = startDate; init<=endDate; init = init.addDays(1)){
            
            //Skip any calculation if Date is in Weekday or Black Out day/Holiday
            if(Util.IsWeekendDay(init) || (isHolidayNeededInCalulation && Util.IsACompanyHoliday(init)))
                continue;
            
            //Rest of the dates are valid dates for Working Business Day so, increase the counter
            businessDays++;
        }
        
        //Return calculated Business days to Calling Routin
        return businessDays;
    }
    
     //Added By - Abhinav Sharma - 12/09/2016 - CR-20160111-9502
    /**
      * @Description    :   Method to convert a HTML text into a plain text. Normally, it is useful in email handlers.
      *
      * @args           :   string htmlStr
      *
      * @return         :   string
      *
    **/
    public static string HtmlToText(string htmlStr){
   
        //replace all <BR> tags with \n to support new lines
        String result = htmlStr.replaceAll('<br/>', '\n');
        result = result.replaceAll('<br />', '\n');

        //all HTML/XML tags
        string HtmlPattern = '<.*?>';
    
        //Matcher Class
        Matcher match =  Pattern.compile(HtmlPattern).matcher(result);

        //remove the tags and return string     
        return match.replaceAll('');
    } 
   
    /**
      * @Description    :   Method to Identify for the Production OR Sandbox Instance.
      *
      * @args           :   Set<String> set of profiles names, Set<String> set of permission Set names, String object APN Name, String field API Name, Set<String> originalPicklist values
      *
      * @return         :   List<String>
      *
      * @Revision Log   :   V1.0 - Created By - Subhash Garhwal  - CR-20170302-10729 - Issue--CR10729--UAT--00003766 - 03/20/2017
    **/
    public static List<String> getPicklistValues(Set<String> setProfileNames, Set<String> setPermissionSetNames, String objectAPIName, String fieldAPIName, Set<String> originalPicklistValues) {
        
        //List to retrurn
        List<String> filteredPicklistValues = new List<String>();
        
        //Loop over the custom metadata
        for(Picklist_Value__mdt pLV : [Select Id, Field_API_Name__c, Field_Values__c, Object_API_Name__c, Profile_Permission_Set__c, Type__c From Picklist_Value__mdt
                                              Where Object_API_Name__c =: objectAPIName AND Field_API_Name__c =: fieldAPIName
                                                    AND Profile_Permission_Set__c IN : setPermissionSetNames AND Type__c = 'Permission Set']) {
            
            //Check for Field values
            if(String.isNotBlank(pLV.Field_Values__c)) {
                
                //Loop over the Field values
                for(String fV : pLV.Field_Values__c.split(',')) {
                    
                    //Check for valid picklist value
                    if(originalPicklistValues.contains(fV))
                        filteredPicklistValues.add(fV);
                }
            }                                                   
        }
        
        //Loop over the custom metadata
        for(Picklist_Value__mdt pLV : [Select Id, Field_API_Name__c, Field_Values__c, Object_API_Name__c, Profile_Permission_Set__c, Type__c From Picklist_Value__mdt
                                              Where Object_API_Name__c =: objectAPIName AND Field_API_Name__c =: fieldAPIName
                                                    AND Profile_Permission_Set__c IN : setProfileNames AND Type__c = 'Profile' ]) {
            
            //Check for Field values
            if(String.isNotBlank(pLV.Field_Values__c)) {
                
                //Loop over the Field values
                for(String fV : pLV.Field_Values__c.split(',')) {
                    
                    //Check for valid picklist value
                    if(originalPicklistValues.contains(fV))
                        filteredPicklistValues.add(fV);
                }
            }                                                   
        }
        
        //Return
        return filteredPicklistValues;
    }
    
    /**
      * @Description    :   Method to return a chron expression to run a job once.
      *                     This is frequently used in Batch jobs that are chained together.
      *
      * @args           :   DateTime, for the scheduled job to execute
      *
      * @return         :   String, Chron Expression representing a one-time execution of a job
      *
      * @Revision Log   :   V1.0 - Created By - 08/17/2017 - Victor Hanson
    **/
    public static string getChronExpressionFromDateTime(DateTime dt) {
        return '' + dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
    }
    
    /**
      * @Description    :   Unschedule all jobs with no Next Fire date, and un-schedule them.
      *
      * @args           :   
      *
      * @return         :   void
      *
      * @Revision Log   :   V1.0 - Created By - 08/17/2017 - Victor Hanson
    **/
    public static void unscheduleJobsWithoutNextFireDate() {
        List<CronTrigger> jobs = [SELECT Id, NextFireTime FROM CronTrigger WHERE NextFireTime = null LIMIT : Limits.getLimitDMLStatements()];
        for (CronTrigger job : jobs) {
            try {
                system.abortJob(job.Id);
            } catch(Exception ex) {
                if(ex.getMessage().contains('Invalid parameter value'))
                    continue;
                else if(ex.getMessage().contains('Job does not exist or is already aborted'))
                    continue;
                else if(ex.getMessage().contains('Job object is locked and currently processing'))
                    continue;
                else
                    throw new CustomException(ex.getMessage());
            }
        }
    }

        /**
      * @Description    :   Check to see if Triggers are bypassed on this object
      *
      * @args           :   
      *
      * @return         :   void
      *
      * @Revision Log   :   V1.0 - Created By - 08/28/2017 - Colin McGloin
      *                     V1.1 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 
    **/

    public static boolean areTriggersOnThisObjectBypassed( String objectName) {

        //Get the Bypass Custom Setting record for this user
        Bypass_Logic__c bypassLogic = Bypass_Logic__c.getInstance(UserInfo.getUserId());

        //Set a variable
        Boolean bypassTrigger = false;

        //Check to see if our Bypass Object field on Custom Setting is populated & we're bypassing Triggers
        if (String.isNotEmpty(bypassLogic.Objects_to_Bypass__c) && bypassLogic.Bypass_Triggers__c == true){
            
            //Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418, to add bypass logic to all triggers
            //Check to see if this object is bypassed
            if (bypassLogic.Objects_to_Bypass__c.contains(objectName) || bypassLogic.Objects_to_Bypass__c.equalsIgnoreCase('ALL')){

                bypassTrigger = true;

            }

        }
        return bypassTrigger;

    }
    
    /**
    * 
    *   @description    :   This can help us keep track of code that has already executed,
    *                       without having to create a static boolean variable for each method.
    * 
    *   @args           :   
    *
    *   @return         :   void
    *
    *   @Revision Log   :   V1.0 - Created By - 08/31/2017 - Victor Hanson
    * 
   **/
    public static codeBypassHelper codeBypass {
        get {
            if (codeBypass == null) codeBypass = new codeBypassHelper();
            return codeBypass;
        }
        set;
    }
    
   /**
    * 
    *   @description    :   Class to help us keep track of code that has already executed,
    *                       without having to create a static boolean variable for each method.
    *                       Managing this via its own class should make it more flexible.
    *
    *   @Revision Log   :   V1.0 - Created By - 08/31/2017 - Victor Hanson
    * 
   **/
    public class codeBypassHelper {
        
        //constructor
        public codeBypassHelper() {}
        
        //map of identifiers that have already been executed
        public Set<String> mapIdentifiers {
            get {
                if (mapIdentifiers == null) mapIdentifiers = new Set<String>();
                return mapIdentifiers;
            }
            set;
        }
        
        //add a method or other identifier to the list of executed code
        public void add(string identifier) {
            mapIdentifiers.add(identifier);
        }
        
        //see if the provided identifier has already been executed once
        public boolean contains(string identifier) {
            
            //skip if this is within a unit test.  This can be modified later to rely on a seperate bypass if needed
            if (!test.isRunningTest())
                return mapIdentifiers.contains(identifier);
            else
                return false;
        }
    }
    
    /**
     * 
     *  @description    :   This method will hold logic to update the Entity field on objects
     * 
     *  @args           :   List<Sobject>, Map<Id, Sobject>, String, String, String, String
     *
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created By - 10/06/2017 - Subhash Garhwal - Apollo
     *                      V1.1 - Modified - 10/18/2017 - Subhash Garhwal - Issue--CR11657--QA--00007018
     * 
     **/
    public static void validateEntityValue(List<Sobject> objectRecords, Map<Id, Sobject> mapOldSobjectRecords, String objectName, String fieldName, String parentField, String parentRelationshipField, String parentObjectRelName, String parentObjectAPIName) {
        
        //Check for Bypass Entity Logic
        if(Util.bypassEntityPopulation) return ;
        
		//Check for values
		if(objectRecords != null && objectRecords.size() > 0 && String.isNotBlank(parentField) && String.isNotBlank(parentRelationshipField)
			&& String.isNotBlank(parentObjectRelName) && String.isNotBlank(fieldName) && String.isNotBlank(parentObjectAPIName)) {
                
			//Set to hold the Parent Ids
			Set<Id> setParentIds = new Set<Id>();
                
			//Loop over the Sobject
			for(Sobject sobj : objectRecords) {
                    
                //Check for Parent
                if(sobj.get(parentField) != null)
                    setParentIds.add(Id.valueOf(String.valueOf(sobj.get(parentField))));
                else
                    sobj.put(fieldName,'');     
            }
                
			//Check for Set size
			if(setParentIds.size() > 0) {
                    
                //Parent SOQL
                String SOQL = 'Select Id, ' + parentRelationshipField + ' From ' + parentObjectAPIName + ' Where Id IN : setParentIds AND ' + parentRelationshipField + ' != null';
                
                //Parent map
                Map<Id, Sobject> mapParentObject = new Map<Id, Sobject>();
                
                //SOQL over Parent
                for(Sobject obj : Database.query(SOQL))
                    mapParentObject.put(Id.valueOf(String.valueOf(obj.get('Id'))), obj);
                
                //Check for map size
                if(mapParentObject.size() > 0) {
                    
                    //Loop over the triggering Sobject
                    for(Sobject sObj : objectRecords) {
                        
                        //Check for Parent
                        if(sobj.get(parentField) != null && mapParentObject.containsKey(Id.valueOf(String.valueOf(sobj.get(parentField)))))
                            sObj.put(fieldName, mapParentObject.get(Id.valueOf(String.valueOf(sobj.get(parentField)))).get(parentRelationshipField));
                        else
                            sObj.put(fieldName,''); 
                    }   
                }
            }
		}
    }
    
    /**
     * 
     *  @description    :   This method will return tha API names of all fields for given object
     * 
     *  @args           :   String objectName
     *
     *  @return         :   String
     *
     *  @Revision Log   :   V1.0 - Created By - 09/24/2018 - Subhash Garhwal-CR-20180607-12270
     * 
     **/
    public static String allFieldAPINames(String objectApiName) {
    
    	//String to hold the field API names
    	 String fieldNames = '';
    	 
    	 //Set to hold the standard created date , last modified date 
         Set<String> setofStandardFields = new Set<String> { 'LastModifiedDate', 'Owner','CreatedBy', 'CurrencyIsoCode', 'ownerid', 'isdeleted',  'currencyisocode', 'createddate', 'createdbyid', 'lastmodifieddate', 'lastmodifiedbyid', 'systemmodstamp', 'lastactivitydate', 'lastvieweddate', 'lastreferenceddate', 'connectionreceivedid', 'connectionsentid'};
    	 
    	 //Map of objects to hold the details of sObjects
    	 Map<String, Schema.SObjectType> mapOfSobjects = new Map<String, Schema.SObjectType>();
	
		 //Get the details of Sobjects by describe call
		 mapOfSobjects = Schema.getGlobalDescribe();

		 //Get the field details of the object 
		 Map<String, Schema.SObjectField> mapOfSObjectFields= mapOfSobjects.get(objectApiName).getDescribe().fields.getMap();
		 
		 //Loop over the field details
		 for(String fieldName : mapOfSObjectFields.keySet()) {
		 	
		 	//Check if the set contains field
            if(!setofStandardFields.contains(fieldName)) {
		 	
		 		//Add field API names in a single string with , separated
		 		fieldNames +=  fieldName + ',';
            }
		 }
		 
		 //Remove last , from the string
		 fieldNames.removeEnd(',');
		 
		 //Return
		 return fieldNames;
    }
    /**
     *    @description    :   Map to get the sObjects record type Ids
     * 
     *    @args           :   
     * 
     *    @return         :   void
     * 
     *   @Revisions      :   03/26/2019 - Added By - Rajeev Jain
     * 
    **/
    public Static  Map<String, Id> sobjectRecordTypeId(String sObjectName) {
        Map<String, Id> mapSobjectRecordTypeId;
        //return Schema.getGlobalDescribe().get(sObjectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        if(mapSobjectRecordTypeId == null){
            mapSobjectRecordTypeId = new Map<String, Id>();
            //mapSobjectRecordTypeId.put(sObjectName, new Map<String, Id>());
            Map<String,Schema.RecordTypeInfo> mapRecordTypeInfo = Schema.getGlobalDescribe().get(sObjectName).getDescribe().getRecordTypeInfosByName();
            for(Schema.RecordTypeInfo rTypeInfo : mapRecordTypeInfo.values()) {
                
                mapSobjectRecordTypeId.put(rTypeInfo.getDeveloperName(), rTypeInfo.getRecordTypeId());
            }
            
        }
        //Return
        return mapSobjectRecordTypeId;
    }
    
    //Added By Mahendra Swarnkar on - 08/13/2019 - CR-12685 - Starts From Here
    
    // Get the Map of all Field set Api Name with the set of Fields API name in a field Set for an Object 
    public Static Map<String, Set<String>> sobjectFieldSetNameWithSetOfFieldsAPIName(String sObjectName) {
        
        Map<String, Set<String>> mapSobjectFieldSetNameWithSetOfFieldsAPIName = new Map<String, Set<String>>();
        Map<String, Schema.FieldSet> mapFieldSet = Schema.getGlobalDescribe().get(sObjectName).getDescribe().FieldSets.getMap();
        for(Schema.FieldSet fieldSetInfo : mapFieldSet.values()) {
			
            for( Schema.FieldSetMember fieldSetmemb : fieldSetInfo.getFields()) {
                if(!mapSobjectFieldSetNameWithSetOfFieldsAPIName.containsKey(fieldSetInfo.getName()))
                    mapSobjectFieldSetNameWithSetOfFieldsAPIName.put(fieldSetInfo.getName(), new Set<String>());
                
                mapSobjectFieldSetNameWithSetOfFieldsAPIName.get(fieldSetInfo.getName()).add(fieldSetmemb.getFieldPath());
            }   
        }
        return mapSobjectFieldSetNameWithSetOfFieldsAPIName;
    }
    
    // Get the list of all field api names included in a field set
    // Victor Hanson - 04/07/2020 - CR-20200304-13828 - Added sobjectFieldSetNameWithSetOfFieldsAPIName
    public Static Set<String> getFieldSetFieldsAPINames(String sObjectName, String fieldSetApiName) {
        
        Set<String> setOfFieldsAPIName = new Set<String>();
        List<Schema.FieldSetMember> fields = Schema.getGlobalDescribe().get(sObjectName).getDescribe().FieldSets.getMap().get(fieldSetAPIName).getFields();
        for( Schema.FieldSetMember fieldSetmemb : fields) {
            setOfFieldsAPIName.add(fieldSetmemb.getFieldPath());
        }
        return setOfFieldsAPIName;
    }
    
    //Commented By CR-20200102-13584
    //Instance for CustomPewrmissionReader class
	//public static CustomPermissionsReader cPR;
    
    //Get the CustomPewrmissionReader class instance. Via this class method "hasPermission()" we can check if current User have a particular CustomPermission Or Not
	/*public static CustomPermissionsReader getCustomPermissionsReader() {
        if(cPR == null)
            cPR = new CustomPermissionsReader();
        
        return cPR;
    }*/
    //Added By Mahendra Swarnkar on - 08/13/2019 - CR-12685 - Ends Here
    
    public static String getTheInstanceUrl() 
    {
        String result = null;
    	List<String> fragments = URL.getSalesforceBaseUrl().getHost().split('\\.');
    	if(fragments.size() == 3) 
        {
            result = fragments[0];
        }
        else if(fragments.size() == 5) 
        {
            result = fragments[1];
        }
    	return result + '.salesforce.com';
    }
    
    
    //Method to return a specific date value of a specific week and of a specific day in that week
    //Method to return a specific date value of a specific week and of a specific day in that week
    public static Date returnDateOfSpecificDayOfSpecificWeek(String whichDay, Integer howManyWeekBackOrAhead, 
                                                             Integer howManyDaysBackOrAhead, 
                                                             Date dateOnTheBasisOfWhichCalculationWithHappen) 
    {
        if(howManyWeekBackOrAhead != null && howManyDaysBackOrAhead != null) 
        {
        	throw new customException('You can not specify both weeks and days for calculation prospective. Please specify only one of them.');    
        }
        
        if(dateOnTheBasisOfWhichCalculationWithHappen == null) 
        {
            throw new customException('Please specify a date value for further calculation.');
        }
        
        if(String.isBlank(whichDay)) 
        {
            throw new customException('Please specify the day value for the date for further calculation');
        }
        
        String dayOfMentionedDate = Util.calculateDayOfDate(dateOnTheBasisOfWhichCalculationWithHappen);	    
        Integer offSetValue;
        Date offSetAdjustedDate;
        Integer noOfDaysToAdd = 0;     
        Date finalResultantDate;
        
        if(howManyWeekBackOrAhead != null) 
        {
            if(howManyWeekBackOrAhead == 0) 
            {
                throw new customException('Please specify a non null and non zero value for week.');
            }
            noOfDaysToAdd = howManyWeekBackOrAhead * 7;
        }
        else if(howManyDaysBackOrAhead != null) 
        {
            if(howManyDaysBackOrAhead == 0) 
            {
                throw new customException('Please specify a non null and non zero value for days.');
            }
            noOfDaysToAdd = howManyDaysBackOrAhead;
        }
        else 
        {
            throw new customException('Please specify atleast either weeks value or days values for calculation prospective.');
        }
        offSetValue = DateOffsetCalculator.returnOffsetValue(whichDay, dayOfMentionedDate);
        if(offSetValue != null) 
        {
            offSetAdjustedDate = dateOnTheBasisOfWhichCalculationWithHappen.addDays(offSetValue); 
            finalResultantDate = offSetAdjustedDate.addDays(noOfDaysToAdd);
            if(howManyDaysBackOrAhead != null) 
            {
                String dayOfResultantDate = Util.calculateDayOfDate(finalResultantDate);
            	Integer additionalOffSetValue = DateOffsetCalculator.returnOffsetValue(whichDay, dayOfResultantDate);
                Date additionalOffSetAdjustedDate = finalResultantDate.addDays(additionalOffSetValue);
                return additionalOffSetAdjustedDate;
        	}
            return finalResultantDate;
        }
        else 
        {
            throw new customException('Offset should have non null value for calculation.');   
        }    
    }
	
	/* 
	* Purpose - This method is used to check if a perticular User have access to the managed package.
	* Revision Logs - Created date - 5 Feb 2020 - CR-20200205-13692.
	*/
	public static Boolean checkManagedPackageAccess(Id userId, String nameSpacePrefixOfManagedPackage) {
		
		Boolean isLicenseGranted = false;
		
		if(String.isNotBlank(userId) && String.isNotBlank(nameSpacePrefixOfManagedPackage)){
			
			for(UserPackageLicense packageLic : [SELECT UserId 
												FROM UserPackageLicense 
												WHERE PackageLicense.NamespacePrefix =: nameSpacePrefixOfManagedPackage 
												AND UserId =:userId]){
			 
				isLicenseGranted = true;
			}
		 }
		return isLicenseGranted;
	}	
	
	//Method to change the format of date to string - CR-20200717-14331
    	public static String formatDate(Date pMailDate, Integer days)
    	{
        	Date dueDate = pMailDate.addDays(-days);
        	String month = dueDate.month() < 10 ? ('0' + dueDate.month()) : String.valueOf(dueDate.month());
        	String day =  dueDate.day() < 10 ? ('0'+dueDate.day()) : String.valueOf(dueDate.day());       
       		return  month+ '/' + day+ '/' + dueDate.year();
    	}
    
    /**
     *    @description    :   This method is used to get existing Registrations Of Eab Event or Campaign Members of Campaign.
     *                        Logic : if List.sObject type is Advisory_Event__c(EAB Event) it return list of Registraions under EAB Event
     *                        if List.sObject type is Campaign it return List of Campaign Members under Campaign.
     *   
     *    @args           :   List<sObject>
     * 
     *    @return         :   List<sObject>
     * 
     *   @Revisions      :   V1.0 - Created - Saurabh Kumar - 03/30/2021 - CR-20201116-14696
     * 					 :   V1.1 - Modified  - Chirag Soni - 05/11/2022 - CR-20220429-16152 - added new Contact Ids parameter to method and SOQL. 
     * 
     **/
    
    public static List<sObject> getExistingRegistrationOrCampaignMember(List<sObject> listOfsObject, Set<Id> contactIds){
        
        if((listOfsObject == null || listOfsObject.size() == 0)&& (contactIds == null || contactIds.size()>0))
            return null;
        
        if(listOfsObject.getSObjectType() == Advisory_Event__c.sObjectType){
            
            //Modified  - Chirag Soni - 05/11/2022 - CR-20220429-16152 - added Contact__c IN :contactIds
            return [SELECT Id, Contact__c, Status__c FROM Registration__c WHERE EAB_Event__c IN :listOfsObject AND Contact__c IN :contactIds];
            
        } else if(listOfsObject.getSObjectType() == Campaign.sObjectType){
             //Modified  - Chirag Soni - 05/11/2022 - CR-20220429-16152 - added Contact__c IN :contactIds
            return [SELECT Id, ContactId, Status, Registration__c FROM CampaignMember WHERE CampaignId IN :listOfsObject AND ContactId IN :contactIds];
        }
        
        return null;
    }
}