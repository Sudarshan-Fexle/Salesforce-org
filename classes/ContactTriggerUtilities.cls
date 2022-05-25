/**
*  Description     :    Helper class for contact object trigger. This class is used to hold the various 
*                       Contact trigger routines
*  Created By      :      
* 
*  Created Date    :   
* 
*  Revision Logs   :    V_1.0 - Created
*                       V_1.1 - Modified By - Abhinav Sharma - 05/23/2014 - CR-20140507-5392
*                       V_1.2 - Modified By - Abhinav Sharma - 08/13/2014 - CR-20140604-5691
*                       V_1.3 - Modified By - Abhinav Sharma - 10/20/2014 - CR-20140923-7430
*                       V_1.4 - Modified By - Victor Hanson - 10/05/2014 - EAB / SF Integration Project
*                       V_1.5 - Modified By - Bhavi Sharma - 01/23/2015 - CR-20141209-8274 - New method addedd - resendBouncedAgreement()
*                       V_1.6 - Modified By - Bhavi Sharma - 06/10/2015 - CR-20141212-8307 - Updated - updateContactPersonalAddressUpdated
*                       V_1.7 - Modified By - Subhash Garhwal - 07/02/2015 - CR-20150618-9014 - New method added - updateStaffAssignment   
*                       V_1.8 - Modified By - MAhendra swarnakar - 09/18/2015 - CR-20150819-9165 - New method added - populateInstitutionLookUpFieldForNPD
*                       V_1.9 - Modified By - Padmesh Soni - 17/08/2015 - CR-20150729-9114 - New method added - createIncentiveChangeLog() 
*                       V_1.10 - Modified By - Mahendra Swarnakar - CR-20150831-9207 - 11/25/2015 - Contact Edit Validation - (validateContactFieldsForInvalidPhrase method)
*                       V_1.11 - Modified By - Rajeev Jain - 04/202/016 - CR-20151120-9402 - Modified createIncentiveChangeLog method logic as per the updated SDD of Change Management.
*                       V_1.12 - Modified By - Mahendra Swarnkar - 5/30/2016 - CR-20151209-9452 - Release 51 - Added a new methed "populateMASignOffDateOnUser" to 
*                                                                                                              populate the "Marketing Asssociated Sign Off Date" value on User record with "Marketing Asssociated Sign Off Date" field value on the contact
*                       V_1.13 - Modified By - Mahendra Swarnakar - CR-20160219-9621 - 30/6/2016 - Updated the validateContactFieldsForInvalidPhrase method logic to bypass the Email and Title validation for numeric value '2' only
*                       V_1.14 - Modified By - Mahendra Swarnakar - CR-20161102-10332 - 12/20/2016 - Added new method (populateTopParentInstitutionOnContacts)
*                       V_1.15 - Modified By - Mahendra Swarnakar - 1/21/2017 - CR-20160907-10171 - Updated existing method i.e. deleteKeyMemberContactsForInActiveContacts & Added a new method - updateMKCRecords
*                       V_1.16 - Modified By - Mahendra Swarnakar - 4/24/2017 - CR-20170118-10625 - Updated existing method i.e. UpdateRestrictionStatus
*                       v_1.17 - Modified By - 06/04/2017 - Abhinav Sharma - DS114  - Added a new method "updateContractABCRecordWithContactValues, updateSubscriptionRecordWithContactValues, updateOpportunityRecordWithContactValues" method
*                       V_1.18 - Modified By - Rajeev Jain - 07/05/2017(In order of migration tasks of - Releases after Q2CDev3 sandbox refresh date[04/07/2017] in Q2CDev3 sandbox from Test sandbox in order to sync with Q2c Beta Release and Revenue Management
*                       V_1.19 - Modified By - Mahendra Swarnkar - Apollo Release - CR-20170928-11571 - 10/09/2017 -  Added a new Methods "updateChildObjectsEntityField" and "updateChildObjectsEntityField".
*           		V_1.20 - Modified By - Mahendra Swarnkar - Apollo Release - CR-20170928-11552 - 10/09/2017 -  Added a new Method "populateEntityField".
*                       V_1.21 - Modified By - Victor Hanson - 11/20/2017 - CR-20171120-11791 - Apollo Hypercare - added bypass flag to "populateEntityField"
*                       V_1.22 - Modified By - Colin McGloin - 02/08/2018 - CR-20180125-11899 - Added checkForWorkspaceChanges method for syncing Workspace info between User/Contact
*                       V_1.23 - Modified By - Abhinav Sharma - 6/5/2018 - CR-20171211-11842 - Update 'updateStaffAssignment'method. Added string Method to avoid name character limit.
*			V_1.24 - Modified By - Subhash Garhwal - 05/30/2018 - CR-20180529-12249 - Added a new method deleteOpportunityContactRole to delete the opportunity Contact Role whenever any contact get deactivated
*                       V_1.25 - Modified By - Removed the References of Activity Field from the class - CR-20180604-12258 - Abhinav sharma - 06/28/2018
*                       V_1.26 - Modified By - Rajeev jain - 07/10/2018 - CR-20180604-12258 - Deployment.
*                       V_1.27 - Modified By - Abhinav sharma - 08/08/2018 - CR-20180417-12165 - New Method checkHardBounceReasonAndDeactivateSiteProfile
*                       V_1.28 - Modified By - Rajeev Jain - Deployment of Marketo Phase 2.
*                       V_1.29 - Modified By - Abhinav Sharma - 06/26/2018 - CR-20180605-12266 - 06/22/2018. Created a new Method - checkCompanyEmailEligibility
*                       V_1.30 - Modified By - Rajeev Jain  - Deployment Of  CR-20180605-12266  - 08/31/2018 - 
*               	V_1.31 - Modified By - Abhinav Sharma - CR-20180905-12569 - Hypercare Release of Marketo - Modified Method = checkCompanyEmailEligibility
*    		        V_1.32 - Modified By - Subhash Garhawal - 10/01/2018 - CR-20180720-12456 - undated methods 'populateInstitutionLookUpFieldForNPD', 'populateEntityField' to reduce the SOQL count
*                       V_1.33 - Modified By - Victor Hanson - 04/29/2019 - CR-20190425-13033 - removed updateContactPersonalAddressUpdated() method
*			V_1.34 - Modified By - Mahendra SwarnKar - 05/01/2019 - Commented the code in "checkForWorkspaceChanges" methods as per Spring Clean up - CR-20190501-13061
*                       V_1.35 - Modified By - Mahendra Swarnkar 17-06-2019 CR-20190522-13123
*			V_1.36 - Modified By - Dipesh Gupta - CR-20180912-12589 - 01/28/2020. create new method "autoPopulateContactField"
*			V_1.37 - Modified By - Abhinav Sharma - 06/23/2020 - CR-20200529-14119 - Updated UpdateRestrictionStatus
*			V_1.38 - Modified by - Neha Sharma - CR-20200717-14328 - 11/24/2020
*			V_1.39 - Modified by - Saurabh Kumar - CR-20200819-14449 - 09/24/2020. (1).Updated updateStaffAssignment method. (2). Updated validateContactBeforeDelete method
*			V_1.40 - Modified By - Mahendra Swarnakar - 03/04/2021 - CR-20210301-14956
*			V_1.41 - Modified By - Saurabh Kumar - CR-20210128-14854 - 04/02/2021 - Added new methods validateContactToSyncAcquia() & syncContactAndRegistrationsWithAcquia()
*                       V_1.42 - Modified By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
*			V_1.43 - Modified By - Chirag Soni - CR-20210606-15193 - 12/22/2021 - validateContactToSyncAcquia() & syncContactAndRegistrationsWithAcquia()
*			V_1.44 - Modified by - Neha Sharma - 5/2/2022 - CR-20220311-16007 - Added isChild = false in query
**/ 
public without sharing class ContactTriggerUtilities {
    
    public final static string ELOQUA_STATUS_PRIMARY = 'Eloqua Hard Bounce - Primary';
    public final static string ELOQUA_STATUS_PREFERRED = 'Eloqua Hard Bounce - Preferred';
    public static Boolean EXECUTE_RESEND_BOUNCED_AGREEMENT = true;
    
    //V_1.17 - Merged By - Rajeev Jain - 07/05/2017(In order of migration tasks of - Releases after Q2CDev3 sandbox refresh date[04/07/2017] in Q2CDev3 sandbox from Test sandbox in order to sync with Q2c Beta Release and Revenue Management

    /**
    *  @description    :   This method is there to populate fields on SBQQ__Subscription__c records with the fields value from the contacts.  
    * 
    *  @args           :   List of contacts, Map of old contacts
    * 
    *  @return         :   void
    * 
    **/ 
    public static void updateSubscriptionRecordWithContactValues(List<Contact> newContacts, Map<Id, Contact> mapOldContacts) {
        
        //Checking for the update use cases
        if(newContacts != null && mapOldContacts != null) {
            
            //Set to hold the contact IDs
            Map<Id, Contact> mapContacts = new Map<Id, Contact>();
            
            //Loop through contract records
            for(Contact c : newContacts) {
                
                //Checking for fields values changes
                if(c.Firstname != mapOldContacts.get(c.Id).FirstName
                    ||
                    c.LastName != mapOldContacts.get(c.Id).LastName 
                )
                    mapContacts.put(c.Id, c);       
            }
            
            //Checking collection for its size
            if(mapContacts.values().size() > 0) {
                
                //Map of SBQQ__Subscription__c
                Map<Id, SBQQ__Subscription__c> mapSubscriptions = new Map<Id, SBQQ__Subscription__c>();
                
                //Loop through subscription records
                for(SBQQ__Subscription__c sub : [SELECT ID, Renewal_Opportunity__c,
                                                    Renewal_Opportunity__r.Main_Contact__c,
                                                    Renewal_Opportunity_Main_Contact__c
                                                    FROM SBQQ__Subscription__c
                                                    WHERE Renewal_Opportunity__c != null
                                                        AND Renewal_Opportunity__r.Main_Contact__c != null
                                                        AND Renewal_Opportunity__r.Main_Contact__c IN : mapContacts.keySet()    
                                      ]) {
                    
                    //Checking for the field value and populating other fields accoridngly
                    if(sub.Renewal_Opportunity_Main_Contact__c != mapContacts.get(sub.Renewal_Opportunity__r.Main_Contact__c).Name) {
                            
                        String mainContactName = '';
                        
                        //Checking first name for null/blank value
                        if(String.isNotBlank(mapContacts.get(sub.Renewal_Opportunity__r.Main_Contact__c).FirstName))
                            mainContactName += mapContacts.get(sub.Renewal_Opportunity__r.Main_Contact__c).FirstName + ' ';
                            
                        mainContactName += mapContacts.get(sub.Renewal_Opportunity__r.Main_Contact__c).Lastname;
                        sub.Renewal_Opportunity_Main_Contact__c = mainContactName;                                      
                        mapSubscriptions.put(sub.Id, sub);
                            
                    }       
                }
                
                //Checking for size value
                if(mapSubscriptions.values().size() > 0) {
                    Util.byPassAllTriggers = true;
                    update mapSubscriptions.values();
                    Util.byPassAllTriggers = false;
                }
            }
        }
    }
    
    /**
    *  @description    :   This method is there to populate fields on contract ABC records with the fields value from the contacts.  
    * 
    *  @args           :   List of contacts, Map of old contacts
    * 
    *  @return         :   void
    * 
    **/ 
    public static void updateContractABCRecordWithContactValues(List<Contact> newContacts, Map<Id, Contact> mapOldContacts) {
        
        //Checking for the update use cases
        if(newContacts != null && mapOldContacts != null) {
            
            //Set to hold the contact IDs
            Map<Id, Contact> mapContacts = new Map<Id, Contact>();
            
            //Loop through contract records
            for(Contact c : newContacts) {
                
                //Checking for fields values changes
                if(c.Firstname != mapOldContacts.get(c.Id).FirstName
                    ||
                    c.LastName != mapOldContacts.get(c.Id).LastName 
                )
                    mapContacts.put(c.Id, c);       
            }
            
            //Checking collection for its size
            if(mapContacts.values().size() > 0) {
                
                //Map of contracts
                Map<Id, Contract__c> mapContracts = new Map<Id, Contract__c>();
                
                //Loop through contract ABC records
                for(Contract__c con : [SELECT ID, Main_Contact_Name__c, Main_Contact__c
                                        FROM Contract__c
                                        WHERE Main_Contact__c != null
                                            AND Main_Contact__c IN : mapContacts.keySet()   
                                      ]) {
                    
                    //Checking for fields value differences                      
                    if(con.Main_Contact_Name__c != mapContacts.get(con.Main_Contact__c).Name) {
                        
                        //Temp string
                        String mainContactName = '';
                        
                        //Checking first name for null/blank value
                        if(String.isNotBlank(mapContacts.get(con.Main_Contact__c).FirstName))
                            mainContactName += mapContacts.get(con.Main_Contact__c).FirstName + ' ';
                        
                        mainContactName += mapContacts.get(con.Main_Contact__c).Lastname;
                        
                        con.Main_Contact_Name__c = mainContactName;                                     
                        mapContracts.put(con.Id, con);
                    }                                          
                }
                
                //Checking for size value
                if(mapContracts.values().size() > 0) {
                    Util.byPassAllTriggers = true;
                    update mapContracts.values();
                    Util.byPassAllTriggers = false;
                }
            }
        }
    }
    
    /**
    *  @description    :   This method is there to populate fields on Opportunity records with the fields value from the contacts.  
    * 
    *  @args           :   List of contacts, Map of old contacts
    * 
    *  @return         :   void
    * 
    **/ 
    public static void updateOpportunityRecordWithContactValues(List<Contact> newContacts, Map<Id, Contact> mapOldContacts) {
        
        //Checking for the update use cases
        if(newContacts != null && mapOldContacts != null) {
            
            //Set to hold the contact IDs
            Map<Id, Contact> mapContacts = new Map<Id, Contact>();
            
            //Loop through contract records
            for(Contact c : newContacts) {
                
                //Checking for fields values changes
                if(c.Firstname != mapOldContacts.get(c.Id).FirstName
                    ||
                    c.LastName != mapOldContacts.get(c.Id).LastName 
                )
                    mapContacts.put(c.Id, c);       
            }
            
            //Checking collection for its size
            if(mapContacts.values().size() > 0) {
                
                //Map of opportunity
                Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>();
                
                //Loop through opportunity records
                for(Opportunity con : [SELECT ID, Main_Contact_Name_Text__c, Main_Contact__c
                                        FROM Opportunity
                                        WHERE Main_Contact__c != null
                                            AND Main_Contact__c IN : mapContacts.keySet()   
                                      ]) {
                    
                    //Checking for fields value differences                      
                    if(con.Main_Contact_Name_Text__c != mapContacts.get(con.Main_Contact__c).Name) {
                        
                        //Temp string
                        String mainContactName = '';
                        
                        //Checking first name for null/blank value
                        if(String.isNotBlank(mapContacts.get(con.Main_Contact__c).FirstName))
                            mainContactName += mapContacts.get(con.Main_Contact__c).FirstName + ' ';
                        
                        mainContactName += mapContacts.get(con.Main_Contact__c).Lastname;
                        
                        con.Main_Contact_Name_Text__c = mainContactName;                                     
                        mapOpportunities.put(con.Id, con);
                    }                                          
                }
                
                //Checking for size value
                if(mapOpportunities.values().size() > 0) {
                    Util.byPassAllTriggers = true;
                    update mapOpportunities.values();
                    Util.byPassAllTriggers = false;
                }
            }
        }
    }
    
    /**
    *  @description    :   This method is there to populate fields on Membership records with the fields value from the contacts.  
    * 
    *  @args           :   List of contacts, Map of old contacts
    * 
    *  @return         :   void
    * 
    **/ 
    public static void updateMembershipRecordWithContactValues(List<Contact> newContacts, Map<Id, Contact> mapOldContacts) {
        
        //Checking for the update use cases
        if(newContacts != null && mapOldContacts != null) {
            
            //Set to hold the contact IDs
            Map<Id, Contact> mapContacts = new Map<Id, Contact>();
            
            //Loop through contract records
            for(Contact c : newContacts) {
                
                //Checking for fields values changes
                if(c.Firstname != mapOldContacts.get(c.Id).FirstName
                    ||
                    c.LastName != mapOldContacts.get(c.Id).LastName 
                )
                    mapContacts.put(c.Id, c);       
            }
            
            //Checking collection for its size
            if(mapContacts.values().size() > 0) {
                
                //Map of membership
                Map<Id, Membership__c> mapMemberships = new Map<Id, Membership__c>();
                
                //Loop through membership records
                for(Membership__c mem : [SELECT ID, Active_Renewal_Opp_Main_Contact_Name__c, Active_Renewal_Opportunity_Main_Contact__c,
                                            Active_Renewal_Opportunity__c, Active_Renewal_Opportunity__r.Main_Contact__c
                                            FROM Membership__c
                                            WHERE Active_Renewal_Opportunity__c != null
                                                AND Active_Renewal_Opportunity__r.Main_Contact__c != null
                                                AND Active_Renewal_Opportunity__r.Main_Contact__c IN : mapContacts.keySet()   
                                      ]) {
                    
                    //Checking for fields value differences                      
                    if(mem.Active_Renewal_Opp_Main_Contact_Name__c != mapContacts.get(mem.Active_Renewal_Opportunity__r.Main_Contact__c).Name) {
                        
                        //Populating field contact reference
                        mem.Active_Renewal_Opportunity_Main_Contact__c = mapContacts.get(mem.Active_Renewal_Opportunity__r.Main_Contact__c).Id;
                        
                        //Temp string
                        String mainContactName = '';
                        
                        //Checking first name for null/blank value
                        if(String.isNotBlank(mapContacts.get(mem.Active_Renewal_Opportunity__r.Main_Contact__c).FirstName))
                            mainContactName += mapContacts.get(mem.Active_Renewal_Opportunity__r.Main_Contact__c).FirstName + ' ';
                        
                        mainContactName += mapContacts.get(mem.Active_Renewal_Opportunity__r.Main_Contact__c).Lastname;
                        
                        mem.Active_Renewal_Opp_Main_Contact_Name__c = mainContactName;                                     
                        mapMemberships.put(mem.Id, mem);
                    }                                          
                }
                
                //Checking for size value
                if(mapMemberships.values().size() > 0) {
                    Util.byPassAllTriggers = true;
                    update mapMemberships.values();
                    Util.byPassAllTriggers = false;
                }
            }
        }
    }
    //V_1.17 - Merged By - Rajeev Jain - 07/05/2017 - Upto Here
    
    //Added By - Mahendra Swarnakar - CR-20150831-9207 - 11/25/2015 - Contact Edit Validation
    //Modified By - Mahendra Swarnakar - CR-20160219-9621 - 30/6/2016 - Updated the logic to bypass the Email and Title validation for numeric value '2' only 
    /**
    *  @description    :   This method will check and validate First Name, Last Name, Title, or Email Address 
    *                       field values on contact record for invalid phrase/characters presence.  
    * 
    *  @args           :   List of contacts, Map of old contacts
    * 
    *  @return         :   void
    * 
    **/ 
    public static void validateContactFieldsForInvalidPhrase(List<Contact> newContacts, Map<Id, Contact> mapOldContacts) {

        //Bypassing the below written logic for "Adviosry Guest Users"
        if(UserInfo.getUserType() != null && UserInfo.getUserType().trim().toLowerCase() == System.Label.Adv_Guest_User_Type)
            return;
        
        //Map to hold the eligible contact records
        Map<Id, Contact> mapEligibleContacts = new Map<Id, Contact>();
        
        //Loop through contact records and bypassing records if having "Is_Ignore_Phrase_Characters__c" field as true.
        for(Contact con : newContacts) {
           
            //Insert use case
            if(mapOldContacts == null && !con.Is_Ignore_Phrase_Characters__c)
                mapEligibleContacts.put(con.Id, con);
            
            //Update use case
            if(mapOldContacts != null
                &&
                (
                    con.FirstName != mapOldContacts.get(con.Id).FirstName
                    ||
                    con.LastName != mapOldContacts.get(con.Id).LastName
                    ||
                    con.Email != mapOldContacts.get(con.Id).Email
                    ||
                    con.Title != mapOldContacts.get(con.Id).Title
                    ||
                    con.Is_Ignore_Phrase_Characters__c != mapOldContacts.get(con.Id).Is_Ignore_Phrase_Characters__c
                )
                && !con.Is_Ignore_Phrase_Characters__c
            )
                mapEligibleContacts.put(con.Id, con);    
        }
        
        //Checking map for size value
        if(mapEligibleContacts.keySet().size() > 0) {
            
            //Map to hold the field Label as a key and a set of invalid phrases for that field as avalue
            Map <String, Set<String>> mapOfFieldNameWithSetOfInvalidPhrases = new Map <String, Set<String>>();
            
            //Checking for null/blank values
            if(Invalid_Phrase_Characters__c.getall() != null 
                && Invalid_Phrase_Characters__c.getall().values() != null
                && Invalid_Phrase_Characters__c.getall().values().size() > 0
            ) {
                //Loop through custom setting records
                for(Invalid_Phrase_Characters__c iPC : Invalid_Phrase_Characters__c.getall().values()) {
                    if(String.isNotBlank(iPC.Object_Name__c) && iPC.Object_Name__c.trim().toLowerCase() == 'contact'
                        && String.isNotBlank(iPC.Invalid_Phrase__c) 
                        && String.isNotBlank(iPC.Applicable_For__c)){
                        
                        //Populating the mapOfFieldNameWithSetOfInvalidPhrases 
                        for(String str : iPC.Applicable_For__c.trim().split(',')){
                            if(String.isNotBlank(str)){
                                str = str.trim().toLowerCase();
                                if(mapOfFieldNameWithSetOfInvalidPhrases.containsKey(str))
                                    mapOfFieldNameWithSetOfInvalidPhrases.get(str).add(iPC.Invalid_Phrase__c.trim().toLowerCase());
                                else
                                    mapOfFieldNameWithSetOfInvalidPhrases.put(str, new Set<String> {iPC.Invalid_Phrase__c.trim().toLowerCase()});
                            }
                        }
                    }
                }
            }
            
            //Check for size
            if(mapOfFieldNameWithSetOfInvalidPhrases.keySet().size() > 0){
                
                //Loop through contact records
                for(Contact c : newContacts) {
                    if(mapEligibleContacts.containsKey(c.Id) && mapEligibleContacts.get(c.Id) != null) {
                        
                        //Boolean flag to decide that the Invalid phrase validation error message should be shown on page or not
                        Boolean isContainsInvalidPhrase = false;
                        
                        //Loop through mapOfFieldNameWithSetOfInvalidPhrases key set
                        for(String applicablefor : mapOfFieldNameWithSetOfInvalidPhrases.keySet()){
                            
                            if(mapOfFieldNameWithSetOfInvalidPhrases.get(applicablefor) != null && mapOfFieldNameWithSetOfInvalidPhrases.get(applicablefor).size() > 0 ){
                            
                                //check for the invalid phrases in the First name, Last name, Email, and title fields
                                for(String invalidPhrase : mapOfFieldNameWithSetOfInvalidPhrases.get(applicablefor)) {
                                    
                                    //check for the invalid phrases in the First name
                                    if(applicablefor.equalsIgnoreCase('FirstName')
                                        && String.isNotBlank(c.FirstName) 
                                        && c.FirstName.containsIgnoreCase(invalidPhrase)){
                                        
                                        //Set the validation error flag
                                        isContainsInvalidPhrase = true;
                                    }
                                    
                                    //check for the invalid phrases in the Last name
                                    if(applicablefor.equalsIgnoreCase('LastName')
                                        && String.isNotBlank(c.LastName) 
                                        && c.LastName.containsIgnoreCase(invalidPhrase)){
                                            
                                        //Set the validation error flag
                                        isContainsInvalidPhrase = true;
                                    }
                                    
                                    //check for the invalid phrases in the Email
                                    if(applicablefor.equalsIgnoreCase('Email')
                                        && String.isNotBlank(c.Email) 
                                        && c.Email.containsIgnoreCase(invalidPhrase)){
                                        
                                        //Set the validation error flag
                                        isContainsInvalidPhrase = true;
                                    }
                                    
                                    //check for the invalid phrases in the Title
                                    if(applicablefor.equalsIgnoreCase('Title')
                                        && String.isNotBlank(c.Title) 
                                        && c.Title.containsIgnoreCase(invalidPhrase)){
                                            
                                        //Set the validation error flag
                                        isContainsInvalidPhrase = true;
                                    }
                                }
                            }
                        }
                        
                        //Show the validation error message on the page if flag is true
                        if(isContainsInvalidPhrase)
                            c.addError(System.Label.Invalid_Phrase_Error_On_Contact);       
                    }
                }
            }
        }
    }    
    
    //Added By Abhinav Sharma - 06/23/2020 - CR-20200529-14119.
    //Modified By - Mahendra Swarnakar - 4/24/2017 - CR-20170118-10625
    //Modified By - Abhinav Sharma - 10/20/2014 - CR-20140923-7430
    public static void UpdateRestrictionStatus(List<Contact> newCons) {
        Set<Id> acctIds = new Set<Id>();
        for (Contact c : newCons)
            acctIds.add(c.AccountId);
        
        //Set to hold the Account Ids
        Set<Id> setAccountIds = new Set<Id>();
        
        //Loop over Contacts
        for(Contact con : newCons) {
            
            //Check for AccountId
            if(con.AccountId != null)
                setAccountIds.add(con.AccountId);
        }
        
        //Check for Account set
        if(setAccountIds.size() > 0) {
            
            //Query through the Accounts
            Map<Id, Account> mapAccounts = new Map<Id, Account>([Select Id, Account_Restriction_Status__c From Account Where Id IN : setAccountIds]);
            
            Map<Id, Contact> consWithRestrictions = new Map<Id, Contact>([SELECT Id, AccountId, Account.Account_Restriction_Status__c,
                                                                      (SELECT Restriction__r.Category__c FROM Restrictions_MtM__r WHERE Restriction_Expired__c = false)
                                                                      FROM Contact WHERE Id IN : newCons AND AccountId != null]);
            
            //Loop over the new Contacts
            for(Contact con : newCons) {
                
                //Check Account Id in map
                if(mapAccounts.containsKey(con.AccountId)) {
                    
                    //Set Contact_Restriction_Status__c
                    con.Contact_Restriction_Status__c = null;
                    
                    //Check for Account Status
                    if(String.isBlank(mapAccounts.get(con.AccountId).Account_Restriction_Status__c)) {
                        
                        //Get that contact with restrictions so we can determine the proper restriction
                        Contact conWithRestriction = consWithRestrictions.get(con.Id);
                        
                        //Added By Abhinav Sharma - 06/23/2020 - CR-20200529-14119
                        if(conWithRestriction != null && conWithRestriction.Restrictions_MtM__r != null && conWithRestriction.Restrictions_MtM__r.size() > 0) {
                        	
                            //Loop over the restricted MTM
                            for (Restricted_MtM__c rMtM : conWithRestriction.Restrictions_MtM__r) {
                                
                                //Check for Category
                                if (rMtM.Restriction__r.Category__c == 'Restricted: Permission Required') {
                                    con.Contact_Restriction_Status__c = 'Restricted: Permission Required';
                                    break;
                                
                                }else if (rMtM.Restriction__r.Category__c == 'Critical Background Information')
                                    con.Contact_Restriction_Status__c = 'Critical Background Information';
                            }        
                        }
                        
                    } else {
                        
                        //Check for Account Restriction status
                        if(mapAccounts.get(con.AccountId) != null && mapAccounts.get(con.AccountId).Account_Restriction_Status__c == 'Restricted: Permission Required')
                            con.Contact_Restriction_Status__c = 'Account - Restricted: Permission Required';
                        else if(con.Contact_Restriction_Status__c != null && !con.Contact_Restriction_Status__c.containsIgnoreCase('Restricted: Permission Required'))
                            con.Contact_Restriction_Status__c = 'Account - Critical Background Information';
                    }
                }    
            }
        }
    }
    
    public static void PopulateContactTitleFromEvent(List<Event> events) {
        Set<Id> contactIds = new Set<Id>();
        // get all whoIds (contactIds)
        for (Event e : events) {
            if (e.WhoId != null)
                contactIds.add(e.WhoId);
        }
        
    // get all of the events and their associated contacts
    Map<Id, Contact> contactMap = new Map<Id, Contact>();
    
    //Modified by - Abhinav Sharma - 6/18/2018 - CR-20180608-12274
    if(contactIds != null && contactIds.size() > 0 )
        contactMap = new Map<Id, Contact>([SELECT Name, Id, Title FROM Contact WHERE Id IN :contactIds]);
            
    BuildEventTitle(events, contactMap, false);
  }
    
    //Modified by - Neha Sharma - 5/2/2022 - CR-20220311-16007 - Added isChild=false in query 
    public static void PopulateContactTitleFromEvent(List<Contact> triggerNew, Map<Id, Contact> triggerOldMap) {
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        // CR-2879 check to see if the contact's title actually changed
        for (Contact newCon : triggerNew) {
            // get theh old contact
            Contact oldCon;
            if (triggerOldMap != null) oldCon = triggerOldMap.get(newCon.Id);
            if (oldCon == null || (oldCon != null && oldCon.Title != newCon.Title)) {
                contactMap.put(newCon.Id, newCon);
            }
        }
        
        //Modified by - Neha Sharma - 5/2/2022 - CR-20220311-16007 - Added isChild=false in query
        if (contactMap.size() > 0) {
            List<Event> events = [SELECT Id, RecurrenceActivityId, IsRecurrence, WhoId,
                                  Title__c 
                                  FROM Event WHERE WhoId IN :contactMap.keySet() AND isrecurrence=false AND isChild = false];
            
            BuildEventTitle(events, contactMap, true);
        }
    }
    
    public static void BuildEventTitle(List<Event> events, Map<Id, Contact> contactMap, boolean SaveUpdates) {
        List<Event> eventsToUpdate = new List<Event>();
        for (Event e : events) {
            // get the contact for this event
            Contact con = contactMap.get(e.WhoId);
            if (con != null) {
                // if the title isn't updated, check the next event
               if (e.Title__c == con.Title) continue;
                e.Title__c = con.Title;
               if (e.IsRecurrence || e.RecurrenceActivityId != null)
                    e.Exclude_From_Exchange_Synch__c = true;
                eventsToUpdate.add(e);
            }
        }
        
        // CR-2879 only update events if the title actually changed
        if (SaveUpdates && eventsToUpdate.size() > 0)
            update eventsToUpdate;
    }
    
    //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
    //Modified By - Mahendra Swarnakar - 1/21/2017 - CR-20160907-10171 - Updated existing method i.e. deleteKeyMemberContactsForInActiveContacts
    //This method is to delete  Key Member Contacts records if contact is not Active
    /*public static void deleteKeyMemberContactsForInActiveContacts(List<Contact> contacts) {
        
        //Create a set of Contact Ids to hold the Ids of InActive contacts
        Set<Id> inActiveContactsIds = new Set<Id>();
        
        //loop through the contacts
        for(Contact contact : contacts) {
            
            //Check for the contacts and add in set if Contact Status is not Active
            if(contact.Contact_Status__c != null && contact.Contact_Status__c != '' && contact.Contact_Status__c != Constants.ACTIVE) {
                
                //Add contact id
                inActiveContactsIds.add(contact.Id);
            }
        }
        
        //Check for the set size
        if(inActiveContactsIds.size() > 0) {
            
            //Delete all the Key membership Contacts, related to the inActiveContactsIds
            List<Membership_Key_Contact__c> keyContacts = [Select Id, Contact__r.AccountId, Membership__c from Membership_Key_Contact__c where Contact__c IN: inActiveContactsIds];
            
            // list all key contacts to update
            //List<Subscription__c> keyConSubscriptionsToUpdate = new List<Subscription__c>();
            
            Set<Id> membershipIds = new Set<Id>();
            for (Membership_Key_Contact__c mkc : keyContacts) {
                membershipIds.add(mkc.Membership__c);
            }
            
            // get all memberships and their associated membership key contacts
            List<Membership__c> memberships = [SELECT Id, Account_Name__c, Program__c,
                                               (SELECT Id, Contact__r.AccountId FROM Membership_Key_Contacts__r WHERE Contact__c IN :inActiveContactsIds)
                                               FROM Membership__c WHERE Id IN :membershipIds];
            
            // process each unique membership individually
            for (Membership__c membership : memberships) {
                List<Membership_Key_Contact__c> keyContactsDiffInst = new List<Membership_Key_Contact__c>();
                for (Membership_Key_Contact__c mkc : keyContacts) {
                    if (mkc.Contact__r.AccountId != membership.Account_Name__c) keyContactsDiffInst.add(mkc);
                }
                
                // put the key contact institution ids in a set
                Set<Id> keyContactInstIdSet = new Set<Id>();
                for (Membership_Key_Contact__c keyCon : keyContactsDiffInst)
                    keyContactInstIdSet.add(keyCon.Contact__r.AccountId);
                
                // 2) get a list of all active memberships on these institutions
                List<Account> acctWithActiveMemberships = [SELECT Id,
                                                           (SELECT Id, Account_Name__c, Program__c FROM Memberships__r WHERE Membership_Status__c LIKE 'Member%')
                                                           FROM Account WHERE Id IN :keyContactInstIdSet];
                                                           
                // 3) get all eligible subscription options for each institution and put them in a map
                Map<Id, Map<Id, Id>> acctIdToEligSubOptions = new Map<Id, Map<Id, Id>>();
                for(Account keyConAcct : acctWithActiveMemberships) {
                    // get all active programs for this acct
                    Set<Id> keyConProgIdSet = new Set<Id>();
                    for (Membership__c m : keyConAcct.Memberships__r) keyConProgIdSet.add(m.Program__c);
                    List<Eligible_Subscription_Option__c> keyConEligSubOpList = [SELECT Id, Related_Subscription__c FROM Eligible_Subscription_Option__c
                                                                                 WHERE Program__c IN :keyConProgIdSet];
                    Map<Id, Id> keyConSubToEligSubOption = new Map<Id, Id>();
                    for (Eligible_Subscription_Option__c keyConEligSubOp : keyConEligSubOpList) {
                        keyConSubToEligSubOption.put(keyConEligSubOp.Related_Subscription__c, keyConEligSubOp.Id);
                    }
                    acctIdToEligSubOptions.put(keyConAcct.Id, keyConSubToEligSubOption);
                }
                
                // get all active subscriptions for that program on that institution
                /List<Subscription__c> subscriptions = [SELECT Id, Subscription_ID__c, Contact__r.AccountId, Subscription_Status__c, Subscription_ID__r.Related_Subscription__c, Subscription_ID__r.Program__c, Subscription_ID__r.Program__r.Program_Acronym__c
                                                       FROM Subscription__c
                                                       WHERE Termination_Date__c = null
                                                       AND Contact__r.AccountId IN :keyContactInstIdSet
                                                       AND Contact__c IN :inActiveContactsIds
                                                       AND Subscription_ID__r.Program__c = :membership.Program__c];
                
                // 4) determine which subscriptions need to be terminated and which can be re-associated with another active eligible subscription option
                for (Subscription__c sub : subscriptions) {
                    Map<Id, Id> keyConSubToEligSubOption = acctIdToEligSubOptions.get(sub.Contact__r.AccountId);
                    String keyConEligSubOptionId = keyConSubToEligSubOption.get(sub.Subscription_ID__r.Related_Subscription__c);
                    if (keyConEligSubOptionId == null) {
                        // add a termination date of today to the subscription
                        sub.Subscription_Status__c = 'Inactive - No Eligible Memberships - ' + sub.Subscription_ID__r.Program__r.Program_Acronym__c;
                        sub.Termination_Date__c = system.now();
                    }
                    else {
                        // update the eligible subscription option to match the ESO of the program whose membership is still active
                        sub.Subscription_ID__c = keyConEligSubOptionId;
                    }
                    // add the subscription to the update list
                    keyConSubscriptionsToUpdate.add(sub);
                }/
            }
            
            // check if there are any subscriptions to update
           / if (keyConSubscriptionsToUpdate.size() > 0)
                update keyConSubscriptionsToUpdate;/
            
            //Modified By - Mahendra Swarnakar - 1/21/2017 - CR-20160907-10171 (Comment out condition and delete DML)
            //Check if there are records to delete
            //if(keyContacts.size() > 0)
                //delete keyContacts;
        }
    }*/
    
    //Validate contact before deleting
    public static void validateContactBeforeDelete(List<Contact> contacts) {
        
        //lists to hold records for deletion
        list<Site_Profile__c> sProfilesToDelete = new list<Site_Profile__c>();
        list<Site_User__c> sUsersToDelete = new list<Site_User__c>();
        
        //V_1.30 - Added by - Saurabh Kumar - CR-20200819-14449 - 09/24/2020. Set to hold Contact Ids to process EAB Event fields in syncing
        Set<Id> contactIds = new Set<Id>();
            
        //get a map of all contacts with site profiles
        map<Id, Contact> mapConWithSiteProfiles = new map<Id, Contact>([SELECT Id, Site_User__c, (SELECT Id, Status__c FROM Site_Profiles__r) FROM Contact WHERE Id IN :contacts]);
        
        //get all site users - delete any site users that will be orphaned by the deletion of this contact
        set<Id> sUserIdSet = new set<Id>();
        for (Contact con : contacts) sUserIdSet.add(con.Site_User__c);
        map<Id, Site_User__c> mapSiteUsers = new map<Id, Site_User__c>([SELECT Id, (SELECT Id FROM Site_Profiles__r), (SELECT Id FROM Contacts__r) FROM Site_User__c WHERE Id IN :sUserIdSet]);
        
        //loop through the contacts and check if any of the contact record have active site profiles.  If so, do not allow user to delete this contact
        for(Contact con : contacts) {
            
            //get the contact with site profiles
            Contact conWithSiteProfile = mapConWithSiteProfiles.get(con.Id);
            
            if (conWithSiteProfile.Site_Profiles__r.size() > 0) {
                for (Site_Profile__c sProfile : conWithSiteProfile.Site_Profiles__r) {
                    //Check for the field value
                    if(sProfile.Status__c == SiteUserHelper.STATUS_ACTIVE) {
                        con.addError('Unable to delete a Contact that is related to an active Site Profile.');
                        return;
                    }
                }
                
                //delete the site profiles
                sProfilesToDelete.addAll(conWithSiteProfile.Site_Profiles__r);
                
                //if the site user is only associated with the contact + site profiles that we are deleting, delete the site user too
                Site_User__c site_User = mapSiteUsers.get(con.Site_User__c);
                if (site_User.Contacts__r.size() == 1 && site_User.Site_Profiles__r.size() == conWithSiteProfile.Site_Profiles__r.size()) {
                    sUsersToDelete.add(site_User);
                }
            }
            //V_1.30 - Added by - Saurabh Kumar - CR-20200819-14449 - 09/24/2020.
            contactIds.add(con.Id);
        }
        
        //delete the site profiles and site users
        if (sProfilesToDelete.size() > 0) delete sProfilesToDelete;
        if (sUsersToDelete.size() > 0) delete sUsersToDelete;
        
        //V_1.30 - Added by - Saurabh Kumar - CR-20200819-14449 - 09/24/2020: Processing to make EAB Event fields in sync: Start
        if(contactIds.size() > 0){
        	
            //Set to hold EAB Event Ids
            Set<Id> eabEventIds = new Set<Id>();
            
            for(Team_Membership__c staffMember : [Select Id, EAB_Event__c From Team_Membership__c Where Role__c != null AND 
                                             	 Staff_member__c != null AND Staff_member__c IN : contactIds AND EAB_Event__c != null 
                                             	 AND RecordTypeId =: Constants.RECORD_TYPE_ID_EAB_EVENT_OF_STAFF_ASSIGNMENT]){
                eabEventIds.add(staffMember.EAB_Event__c);
            }
            
            if(eabEventIds.size() > 0)
                TeamMembershipTriggerHelper.updateEABEventFields(eabEventIds, contactIds);
        }
        //V_1.30 - Added by - Saurabh Kumar - CR-20200819-14449 - 09/24/2020: Processing to make EAB Event fields in sync: End
    }
        
    //Method added by VH - 1/7/14 - CR-20130514-3016
    public static void validateContactBeforeInsert(List<Contact> contacts) {
        
        // get the institution ids for all contacts
        set<Id> accountIdSet = new set<Id>();
        for (Contact contact : contacts) accountIdSet.add(contact.AccountId);
        
        // get a map of all accounts
        map<Id, Account> accountMap = new map<Id, Account>([SELECT Id, Status__c,Primary_State_Province__c, RecordType.DeveloperName 
                                                            FROM Account WHERE Id IN :accountIdSet AND Status__c != null]);
        
        // check to see if any of these contacts are being created on inactive institutions
        for (Contact contact : contacts) {
            
            // do not attempt to validate if one of the following is true:
            //  1. AccountMap is null
            //  2. AccountMap doesnt contain the account
            //  3. Contact Email contains '_inactive' (ie: adv.com user being moved from one institution to another)
            if (accountMap == null 
                || !accountMap.containsKey(contact.AccountId) 
                || contact.Email != null && contact.Email.contains('_inactive')) continue;
            
            // get the account
            Account account = accountMap.get(contact.AccountId);
            if(account != null && String.isNotBlank(account.Primary_State_Province__c)) 
            {
            	contact.Primary_State_Province__c = account.Primary_State_Province__c;
            }
            
            // if the acct status is not active and the record type is not vendor, return an error
            if (!account.Status__c.equalsIgnoreCase(Constants.ACTIVE)
                && account.RecordType.DeveloperName != 'Vendor') {
                    
                    contact.addError(Constants.ERROR_CANNOT_ADD_CONTACT_TO_INACTIVE_INSTITUTION);
                }
        }
    }
    
    //Method added by Bhavi Sharma - 09/25/2013 - CR-20130109-2089
    /**
*  @description    :   This method is to check wheather any of the address data has been changed.
In case of any change, it will update the Personal_Address_Updated__c flag to true, so it can be picked up by batch.
Batch will send this updated address to comdata.
*
*  @args           :   Trigger.new, Trigger.oldMap
*
*  @return         :
*
*  Revision Logs   :   V_1.1 - Bhavi Sharma - 06/04/2014 - Method updated to update the contact's personal address on Portfolio - CR-20140224-4623
V_1.2 - Bhavi Sharma - 06/10/2015 - Code updated to update the Card Holder Name of Portfolio whenever Legal Name changes on Contact
*
**/
   /* public static void updateContactPersonalAddressUpdated(List<Contact> newContacts, Map<Id, Contact> oldMapContacts) {
        
        //Create a list of contacts which have been updated with address
        List<Contact> addressUpdatedContacts = new List<Contact>();
        List<Contact> nameUpdates = new List<Contact>();
        
        //Loop through Trigger.new
        for(Contact contact : newContacts) {
            
            //Check if Personal_Address_Updated__c = true and it was false earlier, then fetch all the related Portfolio record where Portfolio_Owner__c = Contact.Id   
            if(contact.Personal_Address_Updated__c == true && oldMapContacts.get(contact.Id).Personal_Address_Updated__c == false) {
                
                //Add in list of address updated contacts
                addressUpdatedContacts.add(new Contact(Id = contact.Id, Personal_Address_Updated__c = false));
            }
            
            //Check whenever the contact's Lagal First Name and Last Name is changed, update the same name on Portfiolio
            if((String.IsNotBlank(contact.Legal_First_Name__c) && contact.Legal_First_Name__c != oldMapContacts.get(contact.Id).Legal_First_Name__c)
               || (String.IsNotBlank(contact.Legal_Last_Name__c) && contact.Legal_Last_Name__c != oldMapContacts.get(contact.Id).Legal_Last_Name__c)) {
                   
                   //Add in list of address updated contacts
                   nameUpdates.add(contact);
               }
        }
        
        if(nameUpdates.size() > 0) {
            
            //Query all teh related portfolio from database
            //Get all the portfolio records where Portfolio_Owner__c in contact list
            //Then populate the Name on portfolio
            List<Portfolio__c> payments = [Select Id, Card_Holder__r.Personal_Address_Line_1__c, Card_Holder__r.Personal_Address_Line_2__c, 
                                           Card_Holder__r.Personal_Address_City__c, Card_Holder__r.Personal_Address_State__c, 
                                           Card_Holder__r.Personal_Address_PostalCode__c, Card_Holder__r.Legal_First_Name__c, 
                                           Card_Holder__r.Legal_Last_Name__c, Card_Holder__r.Personal_Address_Country__c, 
                                           First_Name_On_Card__c, Last_Name_On_Card__c
                                           from Portfolio__c where Card_Holder__c IN: nameUpdates];
            //Loop through the payments
            for(Portfolio__c payment : payments) {
                
                //Name Updates
                if(payment.First_Name_On_Card__c != payment.Card_Holder__r.Legal_First_Name__c)
                    payment.First_Name_On_Card__c = trunc(payment.Card_Holder__r.Legal_First_Name__c, 15);
                if(payment.Last_Name_On_Card__c != payment.Card_Holder__r.Legal_First_Name__c)
                    payment.Last_Name_On_Card__c = trunc(payment.Card_Holder__r.Legal_Last_Name__c, 15);
            }
            
            if(payments.size() > 0)
                update payments;
        }
        
        //Update the Payment records with new address
        if(addressUpdatedContacts.size() > 0) {
            //Modified by Rajeev Jain
           // updatePortfolioWithContactPersonalAddress(addressUpdatedContacts);
            
            //Bypass all triggers before updating contacts
            Util.BypassAllTriggers = true;
            update addressUpdatedContacts;  
            Util.BypassAllTriggers = false;
        }
    } */
        
    //Method added by Bhavi Sharma - 06/04/2014 - CR-20140224-4623
    /**
*  @description    :   This method is to update the contact personal fields to the related portfolio
*
*  @args           :   List of contact
*
*  @return         :
*
**/
    //Modified by Rajeev Jain
   /* 
    public static void updatePortfolioWithContactPersonalAddress(List<Contact> contacts) {
        
        //get CC Default Settings instance  
        Credit_Card_Settings__c configDefaults = CreditCardConstants.CONFIG_DEFAULT;
        
        //Check if any of the contact was updated
        if(contacts.size() > 0) {
            
            //Query all teh related portfolio from database
            //Get all the portfolio records where Portfolio_Owner__c in contact list
            //Then populate the contact address on portfolio
            List<Portfolio__c> payments = [Select Id, Card_Holder__r.Personal_Address_Line_1__c, Card_Holder__r.Personal_Address_Line_2__c, 
                                           Card_Holder__r.Personal_Address_City__c, Card_Holder__r.Personal_Address_State__c, 
                                           Card_Holder__r.Personal_Address_PostalCode__c, Card_Holder__r.Legal_First_Name__c, 
                                           Card_Holder__r.Legal_Last_Name__c, Card_Holder__r.Personal_Address_Country__c, 
                                           First_Name_On_Card__c, Last_Name_On_Card__c
                                           from Portfolio__c where Card_Holder__c IN: contacts];
            
            //Loop through the payments
            for(Portfolio__c payment : payments) {
                
                //Populate address fields
                //Comdata doesn't  handle international addresses
                //So alll the contact with non US address will be process with the CC Setings default address
                if(!String.IsBlank(payment.Card_Holder__r.Personal_Address_Country__c) && Constants.SET_UNITED_STATES.contains(payment.Card_Holder__r.Personal_Address_Country__c.toLowerCase())) {
                    
                    //Populate from contact
                    payment.Billing_Address_Line_1__c = trunc(payment.Card_Holder__r.Personal_Address_Line_1__c, 30);
                    payment.Billing_Address_Line_2__c = trunc(payment.Card_Holder__r.Personal_Address_Line_2__c, 30);
                    payment.Billing_Address_City__c = trunc(payment.Card_Holder__r.Personal_Address_City__c, 20);
                    payment.Billing_Address_State__c = trunc(payment.Card_Holder__r.Personal_Address_State__c, 2);
                    payment.Billing_Address_PostalCode__c = trunc(payment.Card_Holder__r.Personal_Address_PostalCode__c, 10);
                    payment.Billing_Address_Attention_To__c = null;
                } else {
                    
                    //Populate from Credit Card Settings
                    payment.Billing_Address_Attention_To__c = trunc(configDefaults.Alternate_Delivery_Attention_To__c, 35);
                    payment.Billing_Address_Line_1__c = trunc(configDefaults.Alternate_Delivery_Address_1__c, 30);
                    payment.Billing_Address_Line_2__c = trunc(configDefaults.Alternate_Delivery_Address_2__c, 30);
                    payment.Billing_Address_City__c = trunc(configDefaults.Alternate_Delivery_City__c, 20);
                    payment.Billing_Address_State__c = trunc(configDefaults.Alternate_Delivery_State__c, 2);
                    payment.Billing_Address_PostalCode__c = trunc(configDefaults.Alternate_Delivery_Postal_Code__c, 10);
                }
                
                if(String.IsBlank(payment.First_Name_On_Card__c))
                    payment.First_Name_On_Card__c = trunc(payment.Card_Holder__r.Legal_First_Name__c, 15);
                if(String.IsBlank(payment.Last_Name_On_Card__c))
                    payment.Last_Name_On_Card__c = trunc(payment.Card_Holder__r.Legal_Last_Name__c, 20);
                
                //Update flag
                payment.Billing_Address_Updated__c = true; 
            }
            
            //Update Payments
            if(payments.size() > 0)
                update payments;
        }
    }
        */
    /**
*  @description    :   This method is to truncate the value upto given limit 
* 
*  @args           :   Value to be truncated, Characters limit
* 
*  @return         :   truncated value
* 
**/ 
    public static String trunc(String value, Integer length) {
        
        //Chekc if value is not null
        if(value != null && value.length() >= length) {
            
            //Trunc upto given length
            return value.left(length);
        }
        
        //Return
        return value;
    }
        
    //Method added by Bhavi Sharma - 10/03/2013 - CR-20130109-2089
    /**
    *  @description    :   This method is to check if contact status has been changed from "Active" to "In-active"
    1. Create a OSR record with appropriate values
    2. Assign this OSR to "Card Request Queue" (TODO)
    *
    *  @args           :   Trigger.New, Trigger.oldMap
    *
    *  @return         :
    *
    **/
    /*
    public static void createOSRContactActiveToInactive(List<Contact> newContacts, Map<Id, Contact> oldMapContacts) {

        //List of OSR records to be created
        List<OSR__c> newOSRsToInsert = new List<OSR__c>();
        
        //Set to hold Ids of Contacts with Active to Inactive status changed
        Set<Id> inactiveContactIds = new Set<Id>();
        
        //Map to hold Key = ContactId and Value = CreditCardId
        Map<Id, Id> mapCCWithContact = new Map<Id, Id>();
        
        //Loop through Trigger.new
        for(Contact contact : newContacts) {

        //Check for Contact's Status field
        if(contact.Contact_Status__c != null && contact.Contact_Status__c.containsIgnoreCase(Constants.CONTACT_STATUS_INACTIVE)
        && (oldMapContacts != null && contact.Contact_Status__c != oldMapContacts.get(contact.Id).Contact_Status__c
        && oldMapContacts.get(contact.Id).Contact_Status__c.equalsIgnoreCase(Constants.CONTACT_STATUS_ACTIVE))) {
        
        inactiveContactIds.add(contact.Id);
        }
        }
        
        //Check size of list
        if(inactiveContactIds.size() > 0) {
        
        //Query result of Credit Card assoiciated with the inactive contacts
        List<Credit_Card__c> creditCards = [SELECT Id, Card_Requested_By__c FROM Credit_Card__c WHERE Card_Requested_By__c IN:inactiveContactIds ORDER BY Status__c];
        
        if(creditCards.size() > 0) {
        
        //Loop through Credit Cards
        for(Credit_Card__c creditCard : creditCards) {
        
        //Check if map is already contains the creditCard then continue
        //else put into map
        if(mapCCWithContact.containsKey(creditCard.Card_Requested_By__c))
        continue;
        else
        mapCCWithContact.put(creditCard.Card_Requested_By__c, creditCard.Id);
        }
        }
        
        //Check for size of Map
        if(mapCCWithContact.size() > 0) {
        
        //Loop through Trigger.new
        for(Id contact : mapCCWithContact.KeySet()) {
        
        //Add a new OSR instance in list
        newOSRsToInsert.add(new OSR__c(Status__c = Constants.OSR_STATUS_NEW, Subject__c = Constants.OSR_SUBJECT_EMPLOYEE_LEAVING,
        Request_Type__c = Constants.OSR_REQUEST_TYPE_DEACTIVATE_CARD, Contact__c = contact,
        Request_Reason__c = Constants.OSR_REQUEST_REASON_LEAVING_COMPANY, Origin__c = Constants.OSR_ORIGIN_TRAVEL_PORTAL,
        Priority__c = Constants.OSR_PRIORITY_CREATE_MEDIUM, Related_Card__c = mapCCWithContact.get(contact)));
        }
        }
        }
        
        //Check for size of list and insert OSR
        if(newOSRsToInsert.size() > 0)
        insert newOSRsToInsert;
        }
    */
    
    //Code Added - Bhavi Sharma - 11/14/2013 - CR-20130419-2900
    /**
    *  @description    :   This method is used to populate Contact's Primary Address fields from Parent Account's Primary Address fields
    *                      when All field are blank. Contact's fields are:
    *                          1.Primary Address Line 1
    *                          2.Primary City
    *                          3.Primary Country
    *                          4.Primary State
    *                          5.Primary Postal Code
    *
    *  @param          :   Trigger.new
    *
    *  @return         :
    *
    **/
    /*commented out 12/12/13 pending further discussion on how to implement
    public static void populateContactPrimaryAddress(List<Contact> newContacts) {

        //Map to hold Account Id with Contact
        Map<Id, List<Contact>> mapofContactsAccount = new Map<Id, List<Contact>>();
        
        //Set to hold AccountIds of Contact
        Set<Id> accountIds = new Set<Id>();
        
        //Loop through Trigger.new
        for(Contact contact : newContacts) {
        
        //Check Primary Address fields all are blank
        if(contact.AccountId != null
        && (contact.Primary_Address_Line_1__c == null || contact.Primary_Address_Line_1__c == '')
        && (contact.Primary_City__c == null || contact.Primary_City__c == '')
        && (contact.Primary_State_Province__c == null || contact.Primary_State_Province__c == '')
        && (contact.Primary_Postal_Code__c == null || contact.Primary_Postal_Code__c == '')
        && (contact.Primary_Country__c == null || contact.Primary_Country__c == '')
        ) {
        
        //populate set of AccountIds
        accountIds.add(contact.AccountId);
        
        //Check map is already not contain Contact's AccountId and Populate mapofContactsAccount
        if(!mapofContactsAccount.containsKey(contact.AccountId)) {
        
        mapofContactsAccount.put(contact.AccountId, new List<Contact>{contact});
        } else {
        
        mapofContactsAccount.get(contact.AccountId).add(contact);
        }
        }
        }
        
        //Check for size of set
        if(accountIds.size() > 0) {
        
        for(Account account : [SELECT Id, Primary_Address_Line_1__c, Primary_City__c, Primary_Country__c, Primary_Postal_Code__c, Primary_State_Province__c
        FROM Account WHERE Id IN: AccountIds]) {
        
        //Check map is already contain Account id
        if(mapofContactsAccount.containsKey(account.Id)) {
        
        //Loop through Map's values as List of Contacts
        for(List<Contact> contacts : mapofContactsAccount.values()) {
        
        //Loop through Contact list
        for(Contact contact : contacts) {
        
        //populate values
        contact.Primary_Address_Line_1__c = account.Primary_Address_Line_1__c;
        contact.Primary_City__c = account.Primary_City__c;
        contact.Primary_State_Province__c = account.Primary_State_Province__c;
        contact.Primary_Postal_Code__c = account.Primary_Postal_Code__c;
        contact.Primary_Country__c = account.Primary_Country__c;
        }
        }
        }
        }
        }
        }
    */
         
    //Added By Abhinav Sharma - CR-20140204-4441 - Restriction status not being updated properly as part of nightly batch job
    /**
    *  @description    :   This method is to delete all Restriction MtM records related to that Contacts when deleted.
    *
    *  @args           :   List of old Contact records 
    *
    *  @return         :   void
    *
    **/
    public static void deleteAllRestrictionMtMRecords(List<Contact> deletedContacts) {
            
        //List to hold the Restriction MtM records
        List<Restricted_MtM__c> restrictedMtms = [SELECT ID FROM Restricted_MtM__c WHERE Contact__c != null AND Contact__c IN : deletedContacts];
        
        //Checking list for size value
        if(restrictedMtms != null && restrictedMtms.size() > 0)
            delete restrictedMtms;
    }
     

    //Commented By Dipesh Gupta - CR-20190402-12977 - 07/04/2019 
    /**
    *  @description    :   This method is to resed the credit card agreement to user if it was bounced earlier and now correct email is being entered in the system
    *
    *  @args           :   List of nec Contacts, Map of old Contacts
    *
    *  @return         :   void
    *
    **
    public static void resendBouncedAgreement(List<Contact> contacts, Map<Id, Contact> mapOldContacts) {
            
        //Create a set of the contacts where email Id is being updated and Contact  is Active
        Set<Id> setContactIds = new Set<Id>();
        
        //Loop through the contacts
        for(Contact contact : contacts) {
            
            //Check for the email change
            if(String.isNotBlank(contact.Email) && contact.Email != mapOldContacts.get(contact.Id).Email) {
                
                //Add in set
                setContactIds.add(contact.Id);
            }
        }
            
        //Check for the set size
        if(setContactIds.size() > 0) {
            
            //Map to hold the latest agreement event record for each contact
            Map<Id, echosign_dev1__SIGN_AgreementEvent__c> mapContactWithAgreementEvent = new Map<Id, echosign_dev1__SIGN_AgreementEvent__c>();
            
            //Query last agreement event record for these contacts
            for(echosign_dev1__SIGN_AgreementEvent__c agreement : [Select Id, echosign_dev1__SIGN_Agreement__r.OSR__c, echosign_dev1__SIGN_Agreement__r.echosign_dev1__Recipient__c, echosign_dev1__Description__c from echosign_dev1__SIGN_AgreementEvent__c where echosign_dev1__SIGN_Agreement__r.echosign_dev1__Recipient__c IN: setContactIds Order By CreatedDate DESC]) {
                
                //Add in Map
                if(!mapContactWithAgreementEvent.containsKey(agreement.echosign_dev1__SIGN_Agreement__r.echosign_dev1__Recipient__c))
                    mapContactWithAgreementEvent.put(agreement.echosign_dev1__SIGN_Agreement__r.echosign_dev1__Recipient__c, agreement);
            }
            
            //Map to hold the contacts and OSR to resend
            Map<Id, echosign_dev1__SIGN_AgreementEvent__c> mapOSRForAgreementToResendWithContacts = new Map<Id, echosign_dev1__SIGN_AgreementEvent__c>();
            
            //Loop through the agreements and check if the last agreement was failed because of bounce
            for(echosign_dev1__SIGN_AgreementEvent__c agreement : mapContactWithAgreementEvent.values()) {
                
                //Check for the description
                if(String.isNotBlank(agreement.echosign_dev1__Description__c) && agreement.echosign_dev1__Description__c.startsWith('Advisory Board Credit Card Agreement email bounced')) {
                    
                    //add in set
                    mapOSRForAgreementToResendWithContacts.put(agreement.echosign_dev1__SIGN_Agreement__r.OSR__c, agreement);
                }
            }
            
            //Check for the size
            if(mapOSRForAgreementToResendWithContacts.size() > 0) {
                
                //Fetch the OSR Records
                List<OSR__c> oSRs = [Select Id, Status__c, Request_Type__c, Contact__c from OSR__c where Id IN: mapOSRForAgreementToResendWithContacts.keySet()];
                for(OSR__c oSR : oSRs) {
                    
                    //Set the attributes so OSR trigger can be executed
                    oSR.Status__c = CreditCardConstants.OSR_STATUS_NEW;
                    oSR.Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD;
                }
                
                //Call send agreement methods
                ContactTriggerUtilities.EXECUTE_RESEND_BOUNCED_AGREEMENT = false;
                OSRTriggerHelper.sendAgreementForNewOSR(oSRs);
            }
        }
    }*/
        
    //Added by - Subhash Garhwal - 07/02/2015 - CR-20150618-9014 
    /**
    *  @decription  :   This method is used to update all the related Staff Assignments name, if contact name is changed.
    *                   For this we will blank update all the related Staff Assignments, do to this Renaming workflow will execute and update SA names according    
    *
    *  @args        :   List<Contact>, Map<Id, Contact>
    *
    *  @return      :   void
    * 
    *  @revision log:	Updated by Saurabh Kumar - 09/24/2020 - CR-20200819-14449: Added a check to make data sync on EAB Event if Employee_User_Record__c got changed. 
    *
    **/
    public static void updateStaffAssignment(List<Contact> contacts, Map<Id, Contact> mapOldContacts) {
        
        //Set to hold Contact Ids
        Set<Id> setConIds = new Set<Id>();
        
        //Set to hold contact Id to sync EAB Event fields. Added by Saurabh Kumar - 09/24/2020 - CR-20200819-14449
        Set<Id> contactIds = new Set<Id>();
            
        //Loop through contacts
        for(Contact con : contacts) {
            
            //Check for appropriate condition
            if(con.FirstName != mapOldContacts.get(con.Id).FirstName || con.LastName != mapOldContacts.get(con.Id).LastName)
                setConIds.add(con.Id);
            
            //Added by Saurabh Kumar - 09/24/2020 - CR-20200819-14449
            if(con.Employee_User_Record__c != mapOldContacts.get(con.Id).Employee_User_Record__c)
                contactIds.add(con.Id);
        }
        
        //Check for set size
        if(setConIds.size() > 0) {
            
            //List of Staff Assignment
            List<Team_Membership__c> teamMemberships = [Select Id, Staff_member__r.FirstName, Staff_member__r.LastName, Role__c,
                                                        Role__r.Name From Team_Membership__c Where Staff_member__c IN : setConIds];
            
            //Modified By - Abhinav Sharma - CR-20171211-11842 - Added string Method to avoid name character limit.
            //Loop through Staff Assignment
            for(Team_Membership__c tM : teamMemberships){
                tM.Name = Util.parseNull(tM.Staff_member__r.FirstName) + ' ' + Util.parseNull(tM.Staff_member__r.LastName) + '-' + Util.parseNull(tM.Role__r.Name);
                tM.Name = tM.Name.left(80);
            }
            
            //Check for list size
            if(teamMemberships.size() > 0)
                update teamMemberships;
        }
        
        //Added by Saurabh Kumar - 09/24/2020 - CR-20200819-14449: Start
        if(contactIds.size() > 0){
        	
            //Set to hold EAB Event Ids
            Set<Id> eabEventIds = new Set<Id>();
            
            for(Team_Membership__c staffMember : [Select Id, EAB_Event__c From Team_Membership__c Where Role__c != null AND 
                                             	 Staff_member__c != null AND Staff_member__c IN : contactIds AND EAB_Event__c != null 
                                             	 AND RecordTypeId =: Constants.RECORD_TYPE_ID_EAB_EVENT_OF_STAFF_ASSIGNMENT]){
                eabEventIds.add(staffMember.EAB_Event__c);
            }
            
            if(eabEventIds.size() > 0)
                TeamMembershipTriggerHelper.updateEABEventFields(eabEventIds, new Set<Id> ());
        }
        //Added by Saurabh Kumar - 09/24/2020 - CR-20200819-14449: End
    }
        
    /**
    *  @description    : This Method update the related Research Study Interaction if Institution is changed 
    * 
    *  @args           : List of new Contact instance, Map of old Contact Id and instance 
    * 
    *  @return         : void
    *                   V1.0 - Modified By - Subhash Garhawal - 10/01/2018 - CR-20180720-12456 - to reduce the SOQL count
                        V1.1 - Modified by Mahendra Swarnkar 17-06-2019 CR-20190522-13123
    **/
    /*public static void populateInstitutionLookUpFieldForNPD(List<Contact> listNewContact, Map<Id,Contact> mapOldContact){
        
        //Modified by - Subhash Garhawal - 10/01/2018 - CR-20180720-12456
        //Fetch the NPD record type Id
        Id rTypeNPD = Util.RecordTypeId('Syndicated_Research_Interaction__c', 'NPD'); [Select Id from RecordType where DeveloperName = 'NPD' AND SObjectType = 'Syndicated_Research_Interaction__c' AND IsActive = true limit 1];
        
        //Set to hold contact Id's
        Set<Id> setContactIds = new Set<Id>();
        
        //List to hold Research study Interaction records to be updated
        List<Syndicated_Research_Interaction__c> listRSItoBeUpdated = new List<Syndicated_Research_Interaction__c>();
        
        //loop through Trigger.New
        for(Contact con : listNewContact) {
            
            //Check for condition
            //Populate the set to hold Contact Id 
            if(mapOldContact.containsKey(con.Id) && con.AccountId != mapOldContact.get(con.Id).AccountId )
                setContactIds.add(con.Id);
        }
        
        //Check for size
        if(setContactIds.size() > 0) {
            
            //Fetch contact's childs(RSI)
            for(Syndicated_Research_Interaction__c rSI : [SELECT Id, Institution__c, RecordTypeId, Contact__r.AccountId FROM Syndicated_Research_Interaction__c WHERE Contact__c IN : setContactIds ]) {
                
                //Check for NPD record type then populate the institution lookup field on RSI with associated COntact's institution
                if(rTypeNPD != null && rSI.RecordTypeId == rTypeNPD ) {
                    rSI.Institution__c = rSI.Contact__r.AccountId;
                    
                    //Populate the list listRSItoBeUpdated
                    listRSItoBeUpdated.add(rSI);
                }
            }
        }
        
        //Check for size
        if(listRSItoBeUpdated.size() > 0) {
            
            //Bypass all triggers
            Util.BypassAllTriggers = true;
            
            //Update RSI's
            update listRSItoBeUpdated;
            
            //Enable all the triggers
            Util.BypassAllTriggers = false;
        }
    }*/
        
    //Manual Merger By - Rajeev Jain -11/09/2015
    //Added by - Padmesh Soni - 17/08/2015 - CR-20150729-9114 
    //V_1.11 - Modified By - Rajeev Jain - 04/202/016 - CR-20151120-9402 - Modified createIncentiveChangeLog method logic as per the updated SDD of Change Management.
    /**
    *  @decription  :  This method is used to create Incentive Change Log Records when contacts are created or updated Names
    *                   
    *
    *  @args    :  List<Contact>, Map<Id, Contact>
    *
    *  @return    :  void
    * 				Modified By - Seemu Saikia -CR-20190501-13072- 05/06/2019 - #Spring CleanUp
    *
    **/
    public static void createIncentiveChangeLog(List<Contact> contacts, Map<Id, Contact> mapOldContacts) {
       /* Spring CleanUp
        //List of Incentive Change logs
        List<Incentive_Change_Log__c> incentiveChangeLogs = new List<Incentive_Change_Log__c>();
        
        //Request on Contact in order to get info of Contact's User Record
        Map<Id, Contact> mapContacts = new Map<Id, Contact>([select id, Employee_User_Record__r.IsActive 
                                                                from Contact where ID IN : contacts AND Employee_User_Record__c != null]);
       
        //Loop through contacts
        for(Contact con : contacts) {
            
            //Handle for Newly inserting record
            if(mapOldContacts == null && mapContacts != null && mapContacts.containsKey(con.Id) && mapContacts.get(con.Id).Employee_User_Record__r.IsActive){
                incentiveChangeLogs.add(new Incentive_Change_Log__c(Contact__c = con.Id, Change_Type__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_NEW, 
                                                                    Change_Element__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_CONTACT));
            
            //Handle for Update Case                                                        
            }else if(mapOldContacts != null && con.Employee_User_Record__c != null && 
                        mapContacts.containsKey(con.Id) && mapContacts.get(con.Id).Employee_User_Record__r.IsActive){
                
                //Check change in Employement Start Date
                if(con.Employment_Start__c != mapOldContacts.get(con.Id).Employment_Start__c)
                    incentiveChangeLogs.add(new Incentive_Change_Log__c(Contact__c = con.Id, Change_Type__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_MODIFIED, 
                                                                    Change_Element__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_CONTACT,
                                                                    Change_Value__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_VALUE_START_DATE,
                                                                    Start_Date__c = con.Employment_Start__c));  
                if(con.Employment_Termination__c != mapOldContacts.get(con.Id).Employment_Termination__c)
                    incentiveChangeLogs.add(new Incentive_Change_Log__c(Contact__c = con.Id, Change_Type__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_MODIFIED, 
                                                                    Change_Element__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_CONTACT,
                                                                    Change_Value__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_VALUE_END_DATE,
                                                                    End_Date__c = con.Employment_Termination__c));  
            }
        }
        
         //Check list Size for insert
        if(incentiveChangeLogs.size() > 0)
            insert incentiveChangeLogs;
*/
    }
    //Manual Merger By - Rajeev Jain -11/09/2015 - upt to here

    //Added By - Mahendra Swarnkar - 5/30/2016 - CR-20151209-9452 - Release 51
    /**
    *  @decription  :   This method is used to Populate the "Marketing Asssociated Sign Off Date" value on User record with 
    *                   "Marketing Asssociated Sign Off Date" field value on the contact on the basis of the "Employee User Record" field value on the contact              
    *                  
    *  @args        :   List<Contact>, Map<Id, Contact>
    *
    *  @return      :   void
    *
    **/
  /*  public static void populateMASignOffDateOnUser(List<Contact> contacts, Map<Id, Contact> mapOldContacts) {
        
        //Map to hold the User records
        Map<Id, User> mapUsers = new Map<Id,User>();
        Map<Id, Contact> mapContacts = new Map<Id, Contact>();
        Map<Id, Contact> mapContactsToUpdate = new Map<Id, Contact>();
        
        //Loop through contacts
        for(Contact con : contacts != null ? contacts : mapOldContacts.values()) {
            
            //Insert and Update case
            if(contacts != null) {
                
                //Check that a contact is of "Employee" record type and 
                //1) new Contact is inserted and Employee_User_Record__c is not blank
                //2) User associated with the Contact is changed
                //3) Contact record type is changed to "Employee" 
                //4) User associated with the Contact is not blank and Marketing_Associate_Sign_Off_Date__c field vlue is changed
                if(con.RecordTypeId == Util.RecordTypeId('Contact', 'Employee')
                    &&(mapOldContacts == null 
                        ||(mapOldContacts != null
                            && (
                                con.Employee_User_Record__c != mapOldContacts.get(con.Id).Employee_User_Record__c
                                || 
                                con.Marketing_Associate_Sign_Off_Date__c != mapOldContacts.get(con.Id).Marketing_Associate_Sign_Off_Date__c 
                                || 
                                con.RecordTypeId != mapOldContacts.get(con.Id).RecordTypeId
                                )
                          )
                      )
                ) {
                    
                    //Checking for employee user records
                    if(con.Employee_User_Record__c != null) {
                       
                        //Populating map with new instance
                        mapUsers.put(con.Employee_User_Record__c, 
                            new User(Id =con.Employee_User_Record__c, Marketing_Associate_Sign_Off_Date__c = null ));
                       
                        //Populating map with old instance
                        if(mapOldContacts != null && mapOldContacts.containsKey(con.Id)
                            && mapOldContacts.get(con.Id).RecordTypeId == Util.RecordTypeId('Contact', 'Employee') 
                            && mapOldContacts.get(con.Id).Employee_User_Record__c != null )
                            mapUsers.put(mapOldContacts.get(con.Id).Employee_User_Record__c , new User(Id = mapOldContacts.get(con.Id).Employee_User_Record__c, Marketing_Associate_Sign_Off_Date__c = null));
                    } else
                        mapContacts.put(con.Id, con);
                }    
            }
        }
            
        //Loop through contacts
        for(Contact cont : contacts) {
                
            //check that a user is associated with the contact, then
            // Populate the Marketing_Associate_Sign_Off_Date__c field on the User record with the Marketing_Associate_Sign_Off_Date__c field value on the contact record
            if(cont.Employee_User_Record__c != null 
                && mapUsers.containsKey(cont.Employee_User_Record__c)
                && mapUsers.get(cont.Employee_User_Record__c) != null) {
                
                //Checking if contact if of employeee type    
                if(cont.RecordTypeId == Util.RecordTypeId('Contact', 'Employee')) {
                   mapUsers.get(cont.Employee_User_Record__c).Marketing_Associate_Sign_Off_Date__c = cont.Marketing_Associate_Sign_Off_Date__c;
                } else {
                    
                   //Populate the Marketing_Associate_Sign_Off_Date__c field on the User record
                   if(mapUsers.get(cont.Employee_User_Record__c).Marketing_Associate_Sign_Off_Date__c != null)
                       mapUsers.get(cont.Employee_User_Record__c).Marketing_Associate_Sign_Off_Date__c = null;
                
                }    
            }
               
            //Checking if "employee user contact" field is having null value with it
            if(cont.Employee_User_Record__c == null 
                && cont.RecordTypeId == Util.RecordTypeId('Contact', 'Employee')
                && mapContacts.containsKey(cont.Id)
                && mapContacts.get(cont.Id) != null
            ) {
                if(mapContacts.get(cont.Id).Marketing_Associate_Sign_Off_Date__c != null) {
                    Contact c = new Contact(Id = cont.Id);
                    c.Marketing_Associate_Sign_Off_Date__c = null;
                    mapContactsToUpdate.put(c.Id, c);    
                }        
            }
        }
        
        //Checking list for size value
        if(mapUsers.values() != null && mapUsers.values().size() > 0) {
            
            //Disable all the triggers
            Util.BypassAllTriggers = true;
                        
            //Update the User records
            update mapUsers.values();
            
            //Enable all the triggers
            Util.BypassAllTriggers = false;        
        }
        
        //Checking list for size value
        if(mapContactsToUpdate.values() != null && mapContactsToUpdate.values().size() > 0) {
            
            //Disable all the triggers
            Util.BypassAllTriggers = true;
            
            //Update the User records
            update mapContactsToUpdate.values();
            
            //Enable all the triggers
            Util.BypassAllTriggers = false;
        }
    }*/
    
    //Added By - Mahendra Swarnakar - CR-20161102-10332 - 12/20/2016
    /**
    *  @description    :  Method to populate the Contact's Top_Parent_Institution__c field based on following logic:-
    *             If the Contact.Account.Top_Parent_Institution__c field is not blank
    *               THEN
    *               Contact.Account.Top_Parent_Institution__c field.
    *             ELSE  
    *              If the Contact.Account.Top_Parent_Institution__c field is blank
    *              THEN
    *              it should populate with the Contact.AccountId value. 
  * 
    *  @args           :  List<Contact> contacts, Map<Id, Contact> mapOldContacts   
    * 
    *  @return         :  void
    * 
    **/  
    public static void populateTopParentInstitutionOnContacts(List<Contact> contacts, Map<Id, Contact> mapOldContacts){
        
      //Set to hold AccountIds
      Set<Id> setAccountIds = new Set<Id>();
      
      //Check list not null
      if(contacts != null){
          
        //Loop over new contact
        for(Contact con : contacts) {
          
            //Check for insert use case
            if(mapOldContacts == null) {
                
                //Checking for parent existance
                if(con.AccountId != null)
                    setAccountIds.add(con.AccountId);
                else
                    con.Top_Parent_Institution__c = null;
            }
          
            //Checking for the update use cases
            if(mapOldContacts != null) {
                
                //CHecking for the parent existance
                if(con.AccountId != null)
                    setAccountIds.add(con.AccountId);
                else 
                    con.Top_Parent_Institution__c = null;
                
            }
        }
      
          //Map to hold accounts records
        Map<Id, Account> mapofAccounts = new Map<Id, Account>();
      
            //Check Account set not blank
            if(setAccountIds != null)
                mapofAccounts = new Map<Id, Account>([SELECT ID, Top_Parent_Institution__c 
                                                        FROM Account 
                                                        WHERE Id IN : setAccountIds]);
        
            //Loop over new contact
            for(Contact con : contacts) {
          
                //Checking for key presence and null value in the map of Accounts
                if(con.AccountId != null 
                  && mapofAccounts.containsKey(con.AccountId)
                  && mapofAccounts.get(con.AccountId) != null
                ){
                    
                    //Checking for the key presence in map
                    if(mapofAccounts.get(con.AccountId).Top_Parent_Institution__c != null) {
                      if(con.Top_Parent_Institution__c != mapofAccounts.get(con.AccountId).Top_Parent_Institution__c)
                            con.Top_Parent_Institution__c = mapofAccounts.get(con.AccountId).Top_Parent_Institution__c;
                    } else {
                        if(con.AccountId != con.Top_Parent_Institution__c)
                            con.Top_Parent_Institution__c = con.AccountId;
                    }
                }
            }
        }
    }
    
    //Added By - Mahendra Swarnkar - 1/21/2017 - CR-20160907-10171
    /**
    *  @decription  :   When a contact's Status is changed from "Active" to any other inactive value, then
    *                   a) Query for all Membership Key Contacts related to that Contact where Pubs__c = true OR Meetings__c = true. 
    *                   b) Then set the Pubs and Meetings field values to false for any membership key contacts that are returned.
    *                   c) Update all membership key contacts records associated with that contact to have "Inactive" as status for Key_Contact_Status__c field.
    *
    *  @args        :   List<Contact>, Map<Id, Contact>
    *
    *  @return      :   void
    *
    **/
    public static void updateMKCRecords(List<Contact> contacts, Map<Id, Contact> mapOldContacts) {
            
        //Set to hold Contact Id
        Set<Id> setOfContactIds = new Set<Id>();
           
        //Checj for update case
        if(contacts.size() > 0 && mapOldContacts.size() > 0) {
            
            //Loop over contact record 
            for(Contact con : contacts){
                
                //Check for contact status id Active or not and status is updated 
                if(String.isNotBlank(con.Contact_Status__c)
                    && con.Contact_Status__c != 'Active' 
                    && con.Contact_Status__c != mapOldContacts.get(con.Id).Contact_Status__c
                ){
                    
                    //Add contact ID in the set 
                    setOfContactIds.add(con.Id);
                }
            }
            
            //Check for Contact set having Contact Ids
            if(setOfContactIds.size() > 0){
                
                //Map to hold MKC record
                Map<Id, Membership_Key_Contact__c> mapOfMKCRecordsToBeUpdated = new Map<Id, Membership_Key_Contact__c>();
                                                                 
                //Query to all the MKC records associated with the contact
                for(Membership_Key_Contact__c mkc : [SELECT Id , Pubs__c, Meetings__c, Key_Contact_Status__c 
                                                        FROM Membership_Key_Contact__c 
                                                        WHERE Contact__c != null 
                                                        AND Contact__c IN : setOfContactIds 
                                                    ]){
                        
                    //Checking for the fields values                                  
                    if(
                        (mkc.Pubs__c != null && mkc.Pubs__c)
                        ||
                        (mkc.Meetings__c != null && mkc.Meetings__c)
                        ||
                        (mkc.Key_Contact_Status__c != 'Inactive')
                    ) {
                        
                        //Update the check box value as false as business requirments
                        mkc.Pubs__c = false;
                        mkc.Meetings__c = false;
                        mkc.Key_Contact_Status__c = 'Inactive';
                        
                        //Add MKS record in list to update
                        mapOfMKCRecordsToBeUpdated.put(mkc.Id, mkc);        
                    }                                     
                }
                
                //Check for MKC updatation list and update all MKC records
                if(mapOfMKCRecordsToBeUpdated.values().size() > 0) {
                    
                    //Disable all the triggers
                    Util.BypassAllTriggers = true;
                    
                    //Update the MKC records
                    update mapOfMKCRecordsToBeUpdated.values();
                    
                    //Enable all the triggers
                    Util.BypassAllTriggers = false;
                }
            }
        }
    }
    
    /**
     *  @decription  :   Populate the Entity field value on contact - 
     *                   a) If Contact is "Employee" Type, then populate Entity value from related Employee Record's(user) Entity.
     *                   b) If Contact is "Non - Employee" Type, then populate Entity value from related Account's Entity. 
     *
     *  @args        :   List<Contact>, Map<Id, Contact>
     *
     *  @return      :   void
     *
     *  @Revision Log   :   V1.0 - Created By - Mahendra Swarnkar - 10/09/2017 - CR-20170928-11552 - Apollo Release    
     *             V1.1 - Modified By - Victor Hanson - 11/20/2017 - CR-20171120-11791 - Apollo Hypercare - added bypass flag
     *			   V1.2 - Modified By - Subhash Garhawal - 10/01/2018 - CR-20180720-12456 - to reduce the SOQL count
     * 
    **/
    public static void populateEntityField(List<Contact> contacts, Map<Id, Contact> mapOldContacts) {
        
        //Victor Hanson - 11/20/2017 - CR-20171120-11791 - added bypass flag
        //return immediately if we are bypassing entity population
        if (Util.bypassEntityPopulation) return;
        
        //Added by Subhash Garhawal - CR-20180720-12456 - to reduce the SOQL count 
        Id rTypeIdContactEmployee = Util.RecordTypeId('Contact', 'Employee');/*[Select Id, RecordType.DeveloperName From RecordType where RecordType.DeveloperName = 'Employee' Limit 1].Id*/
            
        //List to hold the "Employee" type contact records
        List<Contact> listEmployeeTypeContacts = new List<Contact>();
        
        //List to hold the "Non - Employee" type contact records
        List<Contact> listNonEmployeeTypeContacts = new List<Contact>();
        
        //loop over the contact records
        for(Contact con : contacts) {
            
            //String to hold Advisory Guest Account Id
            String guestAccountId = System.label.AdvisoryGuestAccountID;
             
            //Adde By Subhash Garhawal - 10/01/2018 - CR-20180720-12456            
            if((con.AccountId != null || con.Employee_User_Record__c != null) && 
           		(mapOldContacts ==  null || con.AccountId != mapOldContacts.get(con.Id).AccountId || con.Employee_User_Record__c != mapOldContacts.get(con.Id).Employee_User_Record__c)) {
                        
	            //Check for Advisory Guest Account ID
	            if( String.isNotBlank(guestAccountId) && con.AccountId != null && guestAccountId.containsIgnoreCase(con.AccountId)){
	                
	                //Set the Entity to ALL
	                Con.Entity__c = 'All';
	            } else{
	             
	                //Check for record type Id
	                if(con.RecordTypeId == rTypeIdContactEmployee && con.Employee_User_Record__c != null) {
	                    
	                    //Populate the Employee type contact list
	                    listEmployeeTypeContacts.add(con);
	                }
	                else {
	                    
	                    //Populate the Non Employee type contact list
	                    listNonEmployeeTypeContacts.add(con);
	                }
	            }
           	}
        }
        
        //Check for size
        if(listEmployeeTypeContacts.size() > 0){
            
            //Call Util Method
            Util.validateEntityValue(listEmployeeTypeContacts, null, 'Contact', 'Entity__c', 'Employee_User_Record__c', 'Entity__c', 'Employee_User_Record__r', 'User');
        }
        
        //Check for size
        if(listNonEmployeeTypeContacts.size() > 0){
            
            //Call Util Method
            Util.validateEntityValue(listNonEmployeeTypeContacts, null, 'Contact', 'Entity__c', 'AccountId', 'Entity__c', 'Account', 'Account');
        }
    }
    
    /**
     *  @description    :   Add a method to the ContactTriggerUtilities class that that checks if the record is either inserted, the Employee User Record record has changed or any of the Workspace fields have changed and then updates the Contact/User record accordingly
     *
     *  @args           :   List<Contact>, Map<Id, Contact>
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created - Colin McGloin - 01/30/2018 - CR-20180125-11899
     *  					V1.1 - Modified By - Mahendra SwarnKar - 05/01/2019 - Commented the class as per Spring Clean up - CR-20190501-13061 
     **/
    
    public static void checkForWorkspaceChanges (List<Contact> contacts, Map<Id, Contact> mapOldContacts){
        /*
        
        //List for updating User records
        List<User> userRecords = new List<User>();
        
        //Map for Linking UserID to Contact
        Map<Id, Contact> mapUserIDToContact = new Map<Id, Contact>();
        
        //Set for Updating Workspace Reference fields as needed
        Set<Id> workspaceIds = new Set<Id>();
        
        //Loop through our records
        for (Contact conRecord : contacts){
            
            //Check for insert scenario - User Update
            if (mapOldContacts == null && conRecord.Employee_User_Record__c != null){
                mapUserIDToContact.put(conRecord.Employee_User_Record__c, conRecord);
            }
            
            //Check for user update scenario
            if (mapOldContacts != null && conRecord.Employee_User_Record__c != null && 
                //User change
                (conRecord.Employee_User_Record__c != mapOldContacts.get(conRecord.Id).Employee_User_Record__c
                 //Workspace field changes
                 || conRecord.Workspace__c != mapOldContacts.get(conRecord.Id).Workspace__c
                 || conRecord.Workspace_Location__c != mapOldContacts.get(conRecord.Id).Workspace_Location__c
                 || conRecord.Workspace_Floor__c != mapOldContacts.get(conRecord.Id).Workspace_Floor__c
                 || conRecord.Workspace_Type__c != mapOldContacts.get(conRecord.Id).Workspace_Type__c 
                )){
                    mapUserIDToContact.put(conRecord.Employee_User_Record__c, conRecord);
                }
            
            //Check for our Workspace field changes
            if ((mapOldContacts == null && conRecord.Workspace__c != null) || (mapOldContacts != null && conRecord.Workspace__c != mapOldContacts.get(conRecord.Id).Workspace__c)){
                workspaceIds.add(conRecord.Workspace__c);
            }
            
        }
        
        //Check to see if our Set is populated
        if (mapUserIDToContact.size() > 0){
            
            //Query for our Contact values needed for Workspace updates
            List<Contact> contactWorkspace = [SELECT Id, Employee_User_Record__c, Workspace__c, Workspace__r.Name, Workspace__r.Floor__c , Workspace__r.Workspace_Type__c ,
            								Workspace_Location__c, Workspace_Location__r.Name FROM Contact WHERE Employee_User_Record__c IN :mapUserIDToContact.keySet()];
            
            //Double check we have records in our List
            if (contactWorkspace.size() > 0){
            
                //Loop through our Records and populate the Map with the Workspace values needed later
                for ( Contact con : contactWorkspace){
                    mapUserIDToContact.put(con.Employee_User_Record__c, con);
                }
                
            }
            
            //Query for our User Records
            List<User> contactUsers = [SELECT Id, Name, EAB_Workspace__c , EAB_Workspace_Floor__c , EAB_Workspace_Location__c, EAB_Workspace_Type__c  FROM User WHERE Id IN :mapUserIDToContact.keySet()];
            
            //Loop through our User Records
            for (User usr : contactUsers){
                
                //Grab our record from the Map
                if (mapUserIDToContact.get(usr.Id) != null){
                    Contact con = mapUserIDToContact.get(usr.Id);
                    
                    //Check for Workspace value and populate if necessary
                    if (con.Workspace__c !=null){
                        usr.EAB_Workspace__c = con.Workspace__r.Name;
                    } else {
                        usr.EAB_Workspace__c = '';
                    }
                    
                    //Check for Workspace Location value and populate if necessary
                    if (con.Workspace_Location__c != null){
                        usr.EAB_Workspace_Location__c = con.Workspace_Location__r.Name;
                    } else {
                        usr.EAB_Workspace_Location__c = '';
                    }
                    
                    //Check for Workspace Floor value and populate if necessary
                    if (con.Workspace__r.Floor__c != null){
                        usr.EAB_Workspace_Floor__c = con.Workspace__r.Floor__c;
                    } else {
                        usr.EAB_Workspace_Floor__c = '';
                    }
                    
                    //Check for Workspace Type value and populate if necessary
                    if (con.Workspace__r.Workspace_Type__c != null){
                        usr.EAB_Workspace_Type__c = con.Workspace__r.Workspace_Type__c;
                    }
                    else {
                        usr.EAB_Workspace_Type__c = '';
                    }
                    
                    //Add our records to List for Update
                    userRecords.add(usr);
                }
                
            }
            
        }
        
        //Check to see if we have records to update
        if (userRecords.size() > 0){
            
            //ByPass All Trigger
       util.BypassAllTriggers = true;
            
            //Update our records
            update userRecords;
            
            util.BypassAllTriggers = false;
            
        }
        
        //Sync Our Workspace fields on the Contact as needed
        if (workspaceIds.size() > 0){
            WorkspaceTriggerHelper.syncContactWithWorkspace(workspaceIds);
        }
        
    */
    }
    /**
     *  @description    :   Method to deactivate the "Site Profile Disabled from Hard Bounce" when the Reason of Hard bounce - Marketing - Hard Bounce Reason   
     * 
     *  @args           :   List<Contact>, Map<id, Contact>
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created - Abhinav Sharma - CR-20180417-12165 - 08/08/2018. 
     *   
     **/
    public static void checkHardBounceReasonAndDeactivateSiteProfile(List<Contact> newContacts, Map<Id, Contact> oldMapContact) {
      
        //List to hold the Contact Object instance which is goinng to be updated 
        List<Contact> consToBeUpdated  = new List<Contact>();
        
        //List of site profile that is going to be deactivated 
        List<Site_Profile__c> siteProfileToBeDeactivated = new List<Site_Profile__c>();
            
        //Set to hold the Contact ids 
        Set<Id> setContactIds = new Set<Id>();
        
        //Loop on the new list of contact
        for(Contact con : newContacts) {
          
            //Comparing the old and new value to stop the unnecessary execution of code, when its not needed. 
            if(String.isNotBlank(con.Marketing_Hard_Bounce_Reason__c) && con.Marketing_Hard_Bounce_Reason__c.equalsIgnoreCase('Category 2: Does not Exist') &&
                oldMapContact != null && con.Marketing_Hard_Bounce_Reason__c != oldMapContact.get(con.Id).Marketing_Hard_Bounce_Reason__c) {
              
                //Set to hold the Contact Ids     
                setContactIds.add(con.Id);
                    
                //Changing the Site Profile Disabled from Hard Bounce = True;
                consToBeUpdated.add(new Contact(Id = con.Id, Site_Profile_Disabled_from_Hard_Bounce__c = true));
            }
        }
        
        //Check for the Set Size
        if(setContactIds.size() > 0) {
      
            //Getting Contact's related site profile which is activated. 
            for(Site_Profile__c siteProfile : [Select Id, Status__c From Site_Profile__c where Contact__c IN: setContactIds AND Status__c = 'Active']) {
                
              //Chaning the Status from Active to inactive   
              siteProfileToBeDeactivated.add(new Site_Profile__c(Id = siteProfile.Id, Status__c = 'Inactive'));
            }
        }
        
       
        //Check for the Contact size
        if(consToBeUpdated.size() > 0) {
      
             //Bypassing trigger
          Util.BypassAllTriggers = true;
            
            update consToBeUpdated;
            
            //Bypassing trigger
          Util.BypassAllTriggers = false;
         }
        
        //Checking the Size of site profile
        if(siteProfileToBeDeactivated.size() > 0)
            update siteProfileToBeDeactivated;
    }
    
    /**
     *  @description    :   This method is used to delete the opportunity Contact Role whenever any contact get deactivated
     *
     *  @args           :   List<Contact>, Map<Id, Contact>
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created - Subhash Gharhwal - 05/30/2018 - CR-20180529-12249
     *   
     **/
    public static void deleteOpportunityContactRole (List<Contact> contacts, Map<Id, Contact> mapOldContacts) {
    
      //Set to hold the Contact Ids
      Set<Id> setOfContactIds = new Set<Id>();
      
      //List of OpportunityContactRole to be deleted
      List<OpportunityContactRole> opportunityContactRoleToBeDeleted = new List<OpportunityContactRole>();
      
      //Loop over the contacts
      for(Contact con : contacts) {
        
        //Check for deactive status
        if(con.Contact_Status__c != Null && con.Contact_Status__c != 'Active' 
          && mapOldContacts != Null && mapOldContacts.get(con.Id).Contact_Status__c != con.Contact_Status__c 
          && mapOldContacts.get(con.Id).Contact_Status__c == 'Active') {
            
          //Adding values into the set
          setOfContactIds.add(con.Id);
        }
      }
      
      //Size Check
      if(setOfContactIds.size() > 0) {
        
        //Query over the OpportunityContactRole
        for(OpportunityContactRole oppCotactRole : [Select Id From OpportunityContactRole Where ContactId IN : setOfContactIds AND Opportunity.IsClosed = false]) {
          
          //Adding value into the List to be deleted
          opportunityContactRoleToBeDeleted.add(oppCotactRole);
        }
      }
      //Size Check
      if(opportunityContactRoleToBeDeleted.size() > 0) {
        
        //ByPass All Trigger
       util.BypassAllTriggers = true;
            
            //delete records
            delete opportunityContactRoleToBeDeleted;
            
            util.BypassAllTriggers = false;
      }
    }
    
     /**
     *  @description    :   This method is used, to check the Eligible domain of Company Email.
     * 
     *  @args           :   List<Contact>, Map<Id, Contact>
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created - Abhinav Sharma - CR-20180605-12266 - 08/28/2018. 
     *   
     **/
    public static void checkCompanyEmailEligibility(List<Contact> newContacts, Map<Id, Contact> mapOldContact) {
    	
        //Set to hold the Account Ids 
        Set<Id> setAccIds =new Set<Id>();
        
        //Map to hold the Account with its Id
        map<Id, Account> mapIdWithAccount = new Map<Id, Account>();
                
        //Loop on the contact and update the Set with the institution Ids
        for(Contact contct : newContacts) 
        	setAccIds.add(contct.AccountId);    
        
        //Check for the set Size
        if(setAccIds.size() > 0)
            //Fill map with the eligible Domains 
        	mapIdWithAccount = SiteProfileTriggerHelper.getAccountsWithEligibleDomains(setAccIds);

        //Check for the Contact List 
        for(Contact con : newContacts) {
        	
            //Boolean variable to Keep the contact and Company Email in Sync
            Boolean isContactAndComapnyEmailInSync = false;
            
            //CR-20180905-12569 - Abhinav Sharma - Hypercare Release of Marketo. 
			//Added by Abhinav Sharma to check If Company Email is blank then Populate the Email in the Company email  
			//Checking Con.Id is null because we need to run this code only on the Insert Case. 
            if(String.isNotBlank(con.Email) && String.isBlank(con.Company_Email__c) && con.Id == null) {
            	
                //Just push the Email to the company Email. 
                con.Company_Email__c = con.Email;
                isContactAndComapnyEmailInSync = true;
            }
            
            //Check for the Company_Email__c change on the contact
            if((mapOldContact == null || (mapOldContact != null 
                 && 
                 (mapOldContact.get(con.Id).Company_Email__c != con.Company_Email__c
                 ||
                  mapOldContact.get(con.Id).Bypass_Domain_Validation__c != con.Bypass_Domain_Validation__c 
                  ||
				  mapOldContact.get(con.Id).AccountId != con.AccountId)))) {
                     
          		//Check for the eligibility of company Email if not then throw an Error Message.
                if(!isContactAndComapnyEmailInSync && String.IsNotBlank(con.Company_Email__c) && !con.Bypass_Domain_Validation__c && con.AccountId != null && !checkEligbleDomain(mapIdWithAccount.get(con.AccountId),con.Company_Email__c))
                	con.addError('Please add a valid domain Company Email.');    
           }
        }
    }
    
    /**
     *  @description    :   Method to check the Eligible Domain.
     * 
     *  @args           :   Account, Email 
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created - Abhinav Sharma - CR-20180605-12266 - 08/02/2018. 
     *   
     **/
    public static boolean checkEligbleDomain(Account acc, String emailToBeChecked) {
        
        //Boolean iseligible return tru and False accordingly.
        boolean isEligible = false;
        
        //Check for the Email 
        //Updated the Null Checks.
        if (String.IsNotBlank(emailToBeChecked) && acc != null && acc.Eligible_Domains__r != null) {
            
            // get the email domain
            String emailDomain = emailToBeChecked.split('@')[1].toLowerCase();
    	
            //Loop on the Eligible Domain 
        	for (Eligible_Domain__c domain : acc.Eligible_Domains__r) {
    			
                //Lower case emailDomain
                domain.Qualified_Domain__c = domain.Qualified_Domain__c.toLowerCase();
                
                //Check for the Eligible Domain
                if (domain.Is_Included__c == true && emailDomain == domain.Qualified_Domain__c.toLowerCase()) {
                    isEligible = true;
                    break;
                }
            }
        }
        
        return isEligible;
    }
    
    //New method. 
    public Static void updateKeyContactOnContact(List<Contact> newContacts, Map<Id, Contact> oldMapContacts) {
        
        //Set to hold the Contact Ids.
        Set<Id> setContactIds = new Set<Id>();
        
        //Loop on the contact.
        for(Contact con : newContacts != null ? newContacts : oldMapContacts.values() ) {
			
			//Check for the contact Status change. If the status is changed from active to Inavtive than change the field values. 
            if(oldMapContacts != null && oldMapContacts.get(con.Id).Contact_Status__c != con.Contact_Status__c ) {
                
                //Checking for the case if the status is changed from Active or To active
                if(oldMapContacts.get(con.Id).Contact_Status__c == 'Active' || con.Contact_Status__c == 'Active') {
                	
                    //Adding the contact Ids to the Set.
            		setContactIds.add(con.Id);  
                }
            }            
        }
        
        //check if the set is containing the values. 
        if(setContactIds.size() > 0) {
            System.enqueueJob(new Enqueue_CheckContactPrimaryOpportunity(setContactIds)); 
            ContractTriggerHelper.updateContact(setContactIds);
            InstitutionRoleTriggerHelper.updatedKeyContactOnContact(setContactIds);
        }
    }
    
    
    /**
     *  @description    :   Method to Auto-populated with the value from the Institution field.
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created - Dipesh Gupta - CR-20180912-12589 - 01/28/2020.
     *                      V_1.1 - Modified by - Neha Sharma - CR-20200717-14328 - 11/24/2020 - update the field "Exclude from Missing Timecards" to 
     *                                                                                           false whenever the contact status is changed to 'Inactive'.
     * 	    
     **/
    public static void autoPopulateContactField(List<Contact> newContactList, Map<Id,Contact> oldMapOfContact) {
        
        //Loop over the new contacts list
        for(Contact con : newContactList != null ? newContactList : oldMapOfContact.values()) {
           
            //Check for insert/update case
            if(oldMapOfContact == null || con.Contact_Status__c != oldMapOfContact.get(con.Id).Contact_Status__c || con.Active_Institution__c != oldMapOfContact.get(con.Id).Active_Institution__c ) {
                
                //Check if Contact is active 
                if(con.Contact_Status__c != null && con.Contact_Status__c == 'Active'){
                    con.Active_Institution__c = con.AccountId;
                }
                else {
                    con.Active_Institution__c = null;
                    
                    con.pse__Exclude_From_Missing_Timecards__c = false;
                }
            }
            
        }
        
       
    }
    
     /**
     *  @description    :   Method to check duplicacy on (email or company email) and Status.
     * 
     *  @args           :   List<Contact>, Map<Id, Contact>
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created - Dipesh Gupta - CR-20200129-13671. 
     **/
    public static void CheckForDuplicacyInUpdationOfContact(List<Contact> newContacts, Map<Id, Contact> oldMapContacts) {
        
        //Set to hold the Email/Company Email
        Set<String> setContactEmails = new Set<String>();
        Set<String> setContactCompanyEmails = new Set<String>();
        Set<Id> setContactIds = new Set<Id>();
        
        for(Contact con : newContacts){
            
            //Check if the bypass is true and field is changed.
            if(oldMapContacts != null && (oldMapContacts.get(con.Id).Bypass_Duplicate_Rules__c != con.Bypass_Duplicate_Rules__c && con.Bypass_Duplicate_Rules__c)){
                
                //Update the bypass duplicate.
                con.ByPass_Duplicate_Rule_By__c = UserInfo.getUserId();  
                con.ByPass_Duplicate_Time__c = System.now();
            }
            else{
                //if duplicate rule is not bypassed.
                if(!con.Bypass_Duplicate_Rules__c){
                    if(con.Contact_Status__c != oldMapContacts.get(con.Id).Contact_Status__c 
                       || con.Email != oldMapContacts.get(con.Id).Email
                       || con.Company_Email__c != oldMapContacts.get(con.Id).Company_Email__c)
                    {
                        
                        //If email is not null
                        if(String.isNotBlank(con.Email))
                            setContactEmails.add(con.Email);
                        
                        //If company email is not null
                        if(String.isNotBlank(con.Company_Email__c))
                            setContactCompanyEmails.add(con.Company_Email__c);
                        
                        //Set to restrict the query.
                        setContactIds.add(con.Id);
                    }
                }                
            }             
        }

        
        //Size check
        if(setContactEmails.size() > 0 || setContactCompanyEmails.size() > 0){
        
            //Loop over existing duplicate contacts
            for(Contact conFromDataBase : [SELECT Id, Contact_Status__c, Email, Company_Email__c 
                                           FROM Contact WHERE Id NOT IN: setContactIds 
                                           AND Email != null AND Email != '' AND Company_Email__c != null AND Company_Email__c != '' AND
                                           (Email IN :setContactEmails OR Company_Email__c IN :setContactEmails) LIMIT 100] ){
                                               
            	//Loop over new contacts
                for(Contact conNewList : newContacts){
                	
                    //Check for same Email/Company Email
                    if(conNewList.Email == conFromDataBase.Email 
                    	|| conNewList.Company_Email__c == conFromDataBase.Company_Email__c){
                                                       
                    	String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+conFromDataBase.Id;
                                                       
                        //Add error
                        conNewList.addError(System.Label.Duplicate_Contact_Error + ' - ' +Recordlink);
                   }
                }
        	}
       	}
    }
    
    
    
    /**
     *  @description    :   Method to update the contact's Address fields if they are clicked from the Moved to Institution button, if the Previous_Institution_Record__c field 
     *                      the value that clearly means, the button is clicked from the button. 
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created - Dipesh Gupta - CR-20180912-12589 - 03/05/2020. 
     *   
     **/
    public static void updateAddressInformationOnContactFromInstitution(List<Contact> newContacts) {

        //Map to hold the Institution. 
        Map<Id, Account> mapAccIdWithAccounts = new Map<Id, Account>();
        
        for(Contact con : newContacts) {

            //Check if the Contact is moved. 
            if(String.isNotBlank(con.AccountId)){
                mapAccIdWithAccounts.put(con.AccountId, new Account(Id = con.AccountId));
            }
        }
        
        if(mapAccIdWithAccounts.size() > 0) {

            for(Account acc : [Select Id, Primary_Address_Line_1__c, Primary_Address_Line_2__c, 
                               Primary_Address_Line_3__c, Primary_City__c,
                               Primary_State_Province__c, Primary_Postal_Code__c, 
                               Primary_Country__c 
                               From Account Where Id IN : mapAccIdWithAccounts.keySet() ]) {
                    
                mapAccIdWithAccounts.put(acc.Id,  acc);               
            }

            for(Contact con : newContacts) {

                //Check if this is Converted. 
                if(String.isNotBlank(con.AccountId) && mapAccIdWithAccounts.containsKey(con.AccountId) 
                    && con.Is_Move_To_New_Institution__c && con.Previous_Institution_Record__c != null) {

                    //Update address values from new Institution. 
                    con.Primary_Address_Line_1__c = mapAccIdWithAccounts.get(con.AccountId).Primary_Address_Line_1__c;
                    con.Primary_Address_Line_2__c = mapAccIdWithAccounts.get(con.AccountId).Primary_Address_Line_2__c;
                    con.Primary_Address_Line_3__c = mapAccIdWithAccounts.get(con.AccountId).Primary_Address_Line_3__c;
                    con.Primary_City__c = mapAccIdWithAccounts.get(con.AccountId).Primary_City__c;
                    con.Primary_State_Province__c = mapAccIdWithAccounts.get(con.AccountId).Primary_State_Province__c;
                    con.Primary_Country__c = mapAccIdWithAccounts.get(con.AccountId).Primary_Country__c;
                    con.Primary_Postal_Code__c = mapAccIdWithAccounts.get(con.AccountId).Primary_Postal_Code__c;
                }
            }
        }
    }

    /**
     *  @description    :   Method to update the old contact's status to "Inactive - Moved Institutions" when a new contact is created via "Move to new Institution" button.
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created - Dipesh Gupta - CR-20180912-12589 - 03/05/2020. 
     *   
     **/
    public static void updateMovedContactStatus(List<Contact> newContactList) {
        
        Map<Id,Contact> mapContactToUpdateStatus = new Map<Id, Contact>();
        
        //Loop over the new contacts list
        for(Contact con : newContactList ) {
           
            //Check for insert/update case
            if( con.Is_Move_To_New_Institution__c && con.Previous_Institution_Record__c != null) {
                mapContactToUpdateStatus.put(con.Previous_Institution_Record__c, new Contact(Id = con.Previous_Institution_Record__c, Contact_Status__c = 'Inactive - Moved Institutions'));
            }   
        }
        
        //Chek for size
        if(mapContactToUpdateStatus.size() > 0 && mapContactToUpdateStatus.values() != null && mapContactToUpdateStatus.values().size() > 0) {
			
            //disable all triggers
            Util.BypassAllTriggers = true;
            
            //update contact Status
            update mapContactToUpdateStatus.values();
            
            //Enable all triggers
            Util.BypassAllTriggers = false;
        }
    }
    
    /**
     * @description		: This method is used to sync Partner Status field on Registration in case of update & delete
     * 
     * @args			: List<Contact> newContacts, Map<Id, Contact> oldContacts
     * 
     * @return			: void
     * 
     * @revision log		: V1.0 Created - Saurabh Kumar - CR-20200821-14453 - 09/29/2020
     * */
    public static void syncRegistrationPartnerStatus(List<Contact> newContacts, Map<Id, Contact> oldContacts){
        
        //Set to hold Contact Ids whoes children should be processed
        Set<Id> contactIds = new Set<Id>();
        
        //Set to hold Contact Ids which should be skipped while processing
        Set<Id> parentIdsToSkipped = new Set<Id>();
        
        //Map to hold Registration which should be synced
        Map<Id, Registration__c> registrations = new Map<Id, Registration__c>();
        
        for(Contact con : newContacts != null ? newContacts : oldContacts.values()){
            
            if(newContacts == null && con.AccountId != null){
                
                parentIdsToSkipped.add(con.Id);
                contactIds.add(con.Id);
            }else if(con.AccountId != oldContacts.get(con.Id).AccountId && (con.AccountId != null || oldContacts.get(con.Id).AccountId != null)){
                contactIds.add(con.Id);
            }
        }
        
        if(contactIds.size() == 0)
            return;
       /*registrations = new Map<Id, Registration__c>([Select Id, EAB_Event__c From Registration__c Where EAB_Event__c != null AND Contact__c != null AND
                                            		Contact__c IN : contactIds]);
       if(registrations.size() > 0)
       		RegistrationHelper.updatePartnerStatus(registrations.keySet(), parentIdsToSkipped);*/
        
        //Modified By - Mahendra Swarnakar - 03/04/2021 - CR-20210301-14956 - Error when trying to edit any fields on Cappex Membership pages
                        
        registrations = new Map<Id, Registration__c>([Select Id, Name, Origin__c, Parent_Registration__c, Automated_Update__c, EAB_Event__c, EAB_Event__r.Status__c 
                                                      From Registration__c Where EAB_Event__c != null AND Contact__c != null 
                                                      AND Contact__r.AccountId != null AND Contact__c IN : contactIds 
                                                      AND (EAB_Event__r.Status__c =: Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION 
                                                           OR EAB_Event__r.Status__c =:Constants.EAB_EVENT_STATUS_OPEN_WAITLIST_ONLY)
                                                     ]);
        
        Boolean isEABEventManager = FeatureManagement.checkPermission('EAB_Event');
        
        if( isEABEventManager && registrations.size() > 0)
            RegistrationHelper.updatePartnerStatus(registrations.keySet(), parentIdsToSkipped);
        //Ends Here - CR-20210301-14956
    }
    
    
    /**
     * @description		: This method is used to update Requires_Acquia_Sync__c field on Contact.
     *                            Logic : Contact Requires Acquia Sync should be set to True when if any field is being change.
     *                            (Contact.Asst_Email__c, Contact.AssistantName, Contact.Primary_City__c, Contact.Email, Contact.Contact_Status__c,
                                  Contact.FirstName, Contact.Account.Account_Formal_Name__c, Contact.LastName, Contact.Primary_Address_Line_1__c, 
                                  Contact.Primary_Address_Line_2__c, Contact.Primary_State_Province__c, Contact.Time_Zone_ID__c, Contact.Title, 
                                  Contact.Primary_Postal_Code__c, Contact.Company_Email__c) are changed on that Contact, update Contact.Requires_Acquia_Sync__c = true.

     * 
     * @args			: List<Contact> newContacts, Map<Id, Contact> mapOfOldContacts
     * 
     * @return			: void
     * 
     * @revision log		: V1.0 - Created - Saurabh Kumar - 04/02/2021 - CR-20210128-14854
     * 				: V1.1 - Modified By - Chirag Soni - 12/22/2021 - CR-20210606-15193 - added logic to sync registration.
     * */
    
      public static void validateContactToSyncAcquia(List<Contact> newContacts, Map<Id, Contact> mapOfOldContacts){
        
        //Modified By Chirag Soni - 12/22/2021 - CR-20210606-15193 - added logic to sync registration.
        for(Contact contact : newContacts){
            
            //Cheking whether any field is being changed
            if(contact.AccountId != mapOfOldContacts.get(contact.Id).AccountId || 
               contact.Asst_Email__c != mapOfOldContacts.get(contact.Id).Asst_Email__c ||
               contact.AssistantName != mapOfOldContacts.get(contact.Id).AssistantName || 
               contact.Primary_City__c != mapOfOldContacts.get(contact.Id).Primary_City__c ||
               contact.Email != mapOfOldContacts.get(contact.Id).Email ||
               //contact.Contact_Status__c != mapOfOldContacts.get(contact.Id).Contact_Status__c ||
               contact.FirstName != mapOfOldContacts.get(contact.Id).FirstName ||
               contact.LastName != mapOfOldContacts.get(contact.Id).LastName ||
               contact.Primary_Address_Line_1__c != mapOfOldContacts.get(contact.Id).Primary_Address_Line_1__c ||
               contact.Primary_Address_Line_2__c != mapOfOldContacts.get(contact.Id).Primary_Address_Line_2__c ||
               contact.Primary_State_Province__c != mapOfOldContacts.get(contact.Id).Primary_State_Province__c ||
               //contact.Title != mapOfOldContacts.get(contact.Id).Title ||
               contact.Primary_Postal_Code__c != mapOfOldContacts.get(contact.Id).Primary_Postal_Code__c ||
               /*contact.Company_Email__c != mapOfOldContacts.get(contact.Id).Company_Email__c*/
               contact.Primary_Country__c != mapOfOldContacts.get(contact.Id).Primary_Country__c)
                
               // if any of above field value is changes set Requires Acquia Sync to true in order to Sync the updated data
               contact.Requires_Acquia_Sync__c = true;
        }
    }
    
    /**
    *  @description    :  This method is used to make callout ('/api/contacts/new?includeCustomObjects=true') when contact is updated with registration.Requires_Acquia_Sync__c = true
                                                
    * 
    *  @args           :   List<Contact> newContacts,  Map<Id, Contact> mapOfOldContacts
    * 
    *  @return         :   Void
    * 
    *  @revision Log   :   V1.0 - Created - Saurabh Kumar - 04/09/2021 - CR-20210128-14854
    * 		       :   V1.1 - Modified By - Chirag Soni - 12/22/2021 - CR-20210606-15193 - added logic to sync registration.
    * 
    * */
    public static void syncContactAndRegistrationsWithAcquia(List<Contact> newContacts,  Map<Id, Contact> mapOfOldContacts){
        
        //Set to hold contact Ids
        Set<Id> contactIds = new Set<Id>();
        
        for(Contact contact : newContacts){
            
            //Checking if Requires_Acquia_Sync__c is true then make callout to sync with Acquia
            if(contact.Requires_Acquia_Sync__c){
                contactIds.add(contact.Id);
            }
        }
        
        if(contactIds.size() == 0)
            return;

        //Modified By Chirag Soni - 12/22/2021 - CR-20210606-15193 - added logic to sync registration.
        List<Registration__c> registrationToSync = [SELECT Id, Requires_Acquia_Sync__c, Zoom_Participant_URL__c, Acquia_Id__c, RecordTypeId FROM Registration__c WHERE Contact__c IN :contactIds AND RecordTypeId != :Constants.REGISTRATION_RECORD_TYPE_ID_INTERNAL_ATTENDEE AND Acquia_Id__c != null];     
      
        
        if(registrationToSync != null && registrationToSync.size()> 0)
        {
            for(Registration__c reg : registrationToSync)
            {
                reg.Requires_Acquia_Sync__c = true;
            }
            
            Util.byPassAllTriggers = true;
            update registrationToSync;
            Util.byPassAllTriggers = false;
            
            RegistrationHelper.syncContactAndRegistrationsWithAcquia(registrationToSync, null);
        }
        
         //Modified By Chirag Soni - 12/22/2021 - CR-20210606-15193 - commented  below part 
        //Query on contact to check if there is any registration
        /*Map<Id, Contact> mapOfContacts = new Map<Id, Contact>([Select Id, (Select Id From Registrations__r) From Contact Where Id IN : contactIds]);
        
        //Block to process the enqueue the job
        for(Contact contact : newContacts){
            
            //Checking if Requires_Acquia_Sync__c is true and there is registration related to contact
            if(contact.Requires_Acquia_Sync__c && mapOfContacts.get(contact.Id).Registrations__r.size() > 0)
                System.enqueueJob(new AcquiaHTTPCallout(new List<Id> {contact.Id}));
        }*/
    }
    
}