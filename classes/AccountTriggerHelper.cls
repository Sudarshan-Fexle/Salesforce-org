/*
 *  Purpose         :   This class is helper class for trigger on Membership object.
 *
 *  Create By       :   Simplyforce Technology(Bhavi)
 *
 *  Created Date    :   09/04/2012
 *
 *  Revision Log    :   V_1.0 Created
 *                      V_1.1 Modified - 9/5/13 - VH - Added method to require comments upon approval rejection
                        V_1.2 Modified - 12/18/13 - VH - CR-3734 & CR-3556
                        V_1.3 Modified - 03/05/2014 - Abhinav Sharma - CR-20140131-4429
                        V_1.4 Modified - 03/05/2014 - Abhinav Sharma - CR-20140204-4441
                        V_1.5 Modified - 03-10-2014 - CR-20140220-4547 - Modify method (rollupChildAcctDataToParents)
                        V_1.6 Modified - 04/03/2014 - CR-20140201-4431 - Commented Out Method getAccountWithoutSharing(Id acctId)
                        V_1.7 Modified - 07/03/2014 - CR-20140618-5845 - Add Institution Description to Expert Center Case layout
                        V_1.8 Modified - Ajit Surana - 02/03/2015 - CR-20141216-8346
                        V_1.9 Modified - Jeffery Sun - 09/30/2015 - CR-20130328-2770
                        V_2.0 Modified - Rajeev Jain - 06/07/2016 - Royall Migration - Royall SFDC Schema Release - Distinction of Royall Account with EAB Accounts - Work on AfterInsert,Update,Delete
                        V_2.1 Modified - Rajeev Jain - 06/24/2016 - Royall Migration - Royall SFDC Schema Release - Manual merging of the code written in 'shift_update_acc_years_status' AccountTrigger in Royall Instance
                        V_2.2 Modified By - Abhinav Sharma - 06/30/2016 - CR-20160419-9779 - Modify method (countryToRegionMap)
                        V_2.3 Modified By - Mahendra Swarnkar - 07/28/2016 - CR-20160419-9779 - Modify method (countryToRegionMap) as per the following UAT changes
                                                                             1) Update the "Caribbean" region with the "Latin America" region.
                                                                             2) Moving India from the Australasia region to the Middle East Region
                        V_2.4 - Modified By - Mahendra Swarnkar - CR-20160802-10078 - 09/05/2016
                        V_2.5 - Modified By - Mahendra Swarnkar - CR-20161102-10332 - 1/2/2017
                        V_2.6 - Modified By - Mahendra Swarnkar - 2/20/2017 - CR-20170215-10692 - Updated the QUery to include the Royall Record type check in the where clause
                        V_2.7 - Modified By - Abhinav Sharma - CR-20170217-10702 - Added a new method - syncUpChildrenCasesFields
                        V_2.8 - Modified By - 06/04/2017 - Abhinav Sharma - DS114  - Added "populateFieldsValuesOnContractsABC" method
                        V_2.9 - Modified By - 6/5/2017 - Subhash Garhwal - Q2C Phase 2 - DS077 - added "updateRelationshipIntractionFields" method 
                        V_3.0 - Merged By - Rajeev Jain - 07/05/2017(In order of migration tasks of - Releases after Q2CDev3 sandbox refresh date[04/07/2017] in Q2CDev3 sandbox from Test sandbox in order to sync with Q2c Beta Release and Revenue Management
                        V_3.1 - Modified By - Abhinav Sharma - CR-20170222-10716 - 4/24/2017 - syncUpChildrenCasesFields method updated 
                        V_3.2 - Modified By - Mahendra Swarnkar - 05/04/2017 - CR-20170221-10707 - Added a new method - populateAssociatePrincipalOnopportunityFromAccount
                        V_3.3 - Merged By - Rajeev Jain - 07/05/2017 - uptohere
                        V_3.4 - Modified By - Subhash Garhwal - 08/04/2017 - CR-20170803-11120 - updated updateRelationshipIntractionFields method
                        V_3.5 - Modified By - Dipesh Gupta - 08/12/2017 -CR-20170426-10878 Added a neew Method populateProjectFieldsFromAccount, to  Update  the .Number of Hospitals field of rhe project when related accout Updates.
                        V_3.6 - Modified By - Dipesh Gupta - 08/23/2017 - CR-20170221-10712, Added a new Method populateJobNoOfProgramPackage which update the Job Number on the related program Package.
                        V_3.7 - Modified By - Subhash Garhwal - 10/06/2017 - Add a new Method ValidateEntity to update Entity
                        V_3.8 - Modified By - Mahendra Swarnkar - 11/10/2017  - Apollo - CR-20170929-11627 (Issue--CR11627--QA--00007404)
                        V_3.9 - Modified By - Victor Hanson - 11/20/2017 - CR-20171120-11791 - added bypass_updateChildrenCaseMemberTypeFieldValue
                        V_4.0 - Modified By - Abhinav sharma - 09/27/2018 - CR-20180917-12597 - updated the method - populateJobNoOfProgramPackage
                        V_4.1 - Modified By - Subhash Garhwal - 11/29/2018 - CR-20181114-12748 - updated the method - populateParentAcctRollups
                        V_4.2 - Modified By - Victor Hanson - 09/16/2019 - CR-20181208-12776 - added method updateEABRelationship
                        V_4.3 - Modified By - Dipesh Gupta - 05/26/2020 - CR-20200522-14088 - replace the references of Campaign New Code field with Campaign code  populateJobNoOfProgramPackage
                        V_4.4 - Modified By - Victor Hanson - 07/14/2020 - CR-20200706-14269 - added method updateGeolocation
                        V_4.5 - Modified By  Abhinav Sharma- 08/11/2020 - CR-20180808-12492 - Commented the Solution_Adopted__c,Solution_Status__c,Solution_Ended__c
                        V_4.6 - Modified By - Abhinav Sharma - 17/06/2020 - CR-20200318-13865
                        V_4.7 - Modified By - Abhinav Sharma - 06/17/2020 - CR-20200318-13867
                        V_4.8 - Modified By - Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756
                        V_4.9 - Modified By - Saurabh Kumar - 04/02/2021 - CR-20210128-14854 - added a new method validateAccountToSyncAcquia ()
			V_5.0 - Modified By - Chirag Soni - 12/22/2021 - CR-20210606-15193 - added logic to sync registration.
**/
public without sharing class AccountTriggerHelper {
	 
    //Flag for executing the ValidateEntity() method once
    Public Static Boolean executingOnce = false;
    Public Static Boolean bypass_updateChildrenCaseMemberTypeFieldValue = false;
    Public Static Boolean bypass_createInitiatingOpportunityName = false;
    
    //Added By Abhinav Sharma - 06/04/2017 - DS114
    /**
     *  @description    :   This method is to keep contract ABC records fields values in sync with correspodning account fields values changes.
     *
     *  @args           :   List<Account> newAccounts, Map<Id, Account> mapOfAccounts
     *
     *  @return         :   void
     *
     **/
    public static void populateFieldsValuesOnContracts(List<Account> newAccounts, Map<Id, Account> mapOldAccounts) {
        
        //Checking for update use cases
        if(newAccounts != null && mapOldAccounts != null) {
            
            //Set of eligible accounts
            Set<Id> setOfAccountIds = new Set<Id>();
            
            //Loop through account records and checking for the field value changes
            for(Account acc : newAccounts) {
                
                //Checking for the fields value changes
                if(acc.Name != mapOldAccounts.get(acc.Id).Name
                  
                  )
                    setOfAccountIds.add(acc.Id);
            }
            
            //Map of account
            Map<Id, Account> mapOfAccounts = new Map<Id, Account>();
            
            //Checking set for its size
            if(setOfAccountIds.size() > 0) {
                mapOfAccounts = new Map<Id, Account>([SELECT ID, Name
                                                        FROM Account
                                                        WHERE ID IN : setOfAccountIds
                                                    ]);
            }
            
            //Map of contracts
            Map<Id, Contract> mapOfContractsToBeUpdated = new Map<Id, Contract>();
            
            //Loop through contract records associated with Accounts
            for(Contract con : [SELECT ID, Account_Name_Text__c, AccountID
                                FROM Contract
                                WHERE AccountID != null
                                    AND AccountID IN : setOfAccountIds 
                                ]) {
                    
              //Checking for field value changes
                if(con.Account_Name_Text__c != mapOfAccounts.get(con.AccountID).Name) {
                  con.Account_Name_Text__c = mapOfAccounts.get(con.AccountID).Name; 
                    mapOfContractsToBeUpdated.put(con.Id, con); 
                }
            }
            
            //Checking map for its size
            if(mapOfContractsToBeUpdated.values().size() > 0) {
                Util.byPassAllTriggers = true;
                update mapOfContractsToBeUpdated.values();
                Util.byPassAllTriggers = false;
            }
        }
    }

    //Commented By Abhinav Sharma - 04/03/2014 - CR-20140201-4431
    // get the institution with OpenActivities / ActivityHistories - this can only be done in a class without sharing
    /*public static Account getAccountWithoutSharing(Id acctId) {

        return [SELECT Id, Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName,
                   (SELECT Id, Subject, ActivityDate, WhoId, AccountId, IsTask, OwnerId FROM ActivityHistories
                    ORDER BY ActivityDate DESC NULLS LAST, LastModifiedDate DESC LIMIT 70),
                   (SELECT Id, Subject, ActivityDate, WhoId, AccountId, IsTask, OwnerId FROM OpenActivities
                    ORDER BY ActivityDate DESC NULLS LAST, LastModifiedDate DESC LIMIT 70)
                   FROM Account WHERE Id = :acctId];
    }*/

    
    // CR-3556 check to see if the Fast Track rollup field has been updated.
    // If so, update any parent institutions so they can receive the updated info
    public static void populateParentAcctRollups(list<Account> accounts, map<Id, Account> oldAccounts) {

        set<Id> parentAcctsToUpdate = new set<Id>();

        for (Account acct : accounts) {

            // get the old account
            Account oldAcct = oldAccounts.get(acct.Id);

            if (oldAcct != null) {

                if (acct.Fast_Track__c != oldAcct.Fast_Track__c ||
                    acct.Fast_Track_Units__c != oldAcct.Fast_Track_Units__c ||
                    acct.Research_Current_Period_Value_Rolled_Up__c != oldAcct.Research_Current_Period_Value_Rolled_Up__c ||
                    acct.Tech_Current_Period_Value_Rolled_Up__c != oldAcct.Tech_Current_Period_Value_Rolled_Up__c ||
                    acct.Enrollment_Contract_Value__c != oldAcct.Enrollment_Contract_Value__c ||
                    acct.ParentId != oldAcct.ParentId)
                {

                    // if the parent id was removed from the account, add that parent to our list to update
                    if (acct.ParentId == null && oldAcct.ParentId != null)
                        parentAcctsToUpdate.add(oldAcct.ParentId);

                    if (acct.ParentId != null)
                        parentAcctsToUpdate.add(acct.ParentId);
                }
            }
        }


        if (parentAcctsToUpdate.size() > 0) {

            // send these ids to the method that will update their rollup values
            rollupChildAcctDataToParents(parentAcctsToUpdate);
        }
    }

    //Modfied By - Abhinav Sharma - 03-10-2014 - CR-20140220-4547 - Formula should include Parent and all Child data below it
    // CR-3556 update 6 fields with rollup data.  This cannot be done via rollup fields because this is only a lookup relationship
    public static void rollupChildAcctDataToParents(set<Id> parentAcctIds) {}

    public static void RequireCommentsForAppRejection(List<Account> triggerNew) {
        // map to hold accounts with approval requests in process
        Map<Id, Account> acctMap = new Map<Id, Account>();
        
        if (!acctMap.isEmpty()) {
            // Get the last approval process step for the approval processes,
            // and check the comments.
            for (ProcessInstance pi : [SELECT TargetObjectId,
                                        (SELECT Id, StepStatus, Comments FROM Steps WHERE StepStatus = 'Rejected' ORDER BY CreatedDate DESC LIMIT 1 )
                                       FROM ProcessInstance
                                       WHERE TargetObjectId In :acctMap.keySet()
                                       AND Id IN (SELECT ProcessInstanceId FROM ProcessInstanceStep WHERE StepStatus = 'Rejected')
                                       ORDER BY CreatedDate DESC LIMIT 1])
            {
                // If no comment exists, then prevent the object from saving.
                if ((pi.Steps[0].Comments == null ||
                    pi.Steps[0].Comments.trim().length() == 0))
                {
                    acctMap.get(pi.TargetObjectId).addError('Please provide a reason for your rejection.');
                }
            }
        }
    }

    // begin the approval process for any institutions that are created by a user with ABC Dataloader profile
    public static void BeginVendorApproval(List<Account> accounts) {
        // return immediately if the profileId is not ABC Dataloader
        // all vendors that require approval are generated by the ABC Dataloader profile with a record size = 1
        //Modified By - Chirag Soni - 12/22/2021 - CR-20210606-15193
        if (UserInfo.getProfileId() != label.ABC_Dataloader_Profile_Id || accounts.size() > 1) return;

        // get the Vendor record type id
        Id vendorRTId;
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND IsActive=true AND DeveloperName='Vendor' LIMIT 1];
        if (recordTypes.size() > 0) vendorRTId = recordTypes[0].Id;

        // check each institution to see whether it needs approval
        for (Account a : accounts) {
            // make sure the recordType is Vendor
            if (a.RecordTypeId == vendorRTId) {
                // Create an approval request for the account
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval.');
                req1.setObjectId(a.id);

                // Submit the approval request for the account
                Approval.ProcessResult result = Approval.process(req1);
            }
        }
    }

    //This method is to populate the Top Parent lookup Id field with the Appropriate value
    //VH 08/02/2017 - Issue--CR11094--UAT--00005313 - reduce soql queries
    public static void populateTopParentInstitute(List<Account> institutes, map<Id, Account> oldMapInstitutes) {

        //Loop through the account records and create a set of parent ids
        Set<Id> setParentIds = new Set<Id>();

        //Loop through the account records
        for(Account acc : institutes) {

            //Add parentid in set if not null
            if(acc.ParentId != null) {
                
                //VH 08/02/2017 - Issue--CR11094--UAT--00005313 - reduce soql queries
                //only add the parentId if the parentId is newly added, or changed
                if (oldMapInstitutes == null || 
                    (oldMapInstitutes != null && oldMapInstitutes.get(acc.Id).ParentId != acc.ParentId))
                {
                    
                    //Add in set
                    setParentIds.add(acc.ParentId);
                }
            } else {

                //Set null to parent
                acc.Top_Parent_Institution__c = null;
            }
        }

        //Check for the parent size
        if(setParentIds.size()>0) {

            //Get account data from database
            Map<Id,Account> mapAccounts = new Map<Id,Account>([SELECT Id , Top_Parent_Institution__c From Account where Id IN : setParentIds]);

            //Loop through the in context account records
            for(Account acc : institutes) {

                //Check for the ParentId
                if(acc.ParentId != null && mapAccounts.containsKey(acc.ParentId)) {

                    //Get account from map
                    Account parentAcc = mapAccounts.get(acc.ParentId);

                    //check for top parentid
                    if(parentAcc.Top_Parent_Institution__c != null)
                        acc.Top_Parent_Institution__c = parentAcc.Top_Parent_Institution__c;
                    else
                        acc.Top_Parent_Institution__c = parentAcc.Id;
                }
            }
        }
    }

    // map of account record types
    public static Map<String, Id> AccountRTMap {
        get {
            if (AccountRTMap == null) {
                AccountRTMap = new Map<String, Id>();
                AccountRTMap = Util.recordtypemap('Account');
            }
            return AccountRTMap;
        }
        set;
    }

    // populate the region based on the Account's Primary Country
    public static void populateRegion(list<Account> accounts) {

        for (Account acct : accounts) {

            string regionStr;

            // make sure primary country is not null
            if (acct.Primary_Country__c != null) {

                // see if the primary country is in our map
                if (countryToRegionMap.containsKey(acct.Primary_Country__c))
                    regionStr = countryToRegionMap.get(acct.Primary_Country__c);
                else
                    regionStr = acct.Primary_Country__c;
            }

            acct.Region__c = regionStr;
        }
    }
    
    //V_1.13 - Modified By - Mahendra Swarnkar - 07/28/2016 - CR-20160419-9779 - Updated the existing mapping
    //Modified By - Abhinav Sharma - 06/30/2016 - CR-20160419-9779 - Updated the existing mapping
    //Modified By Ajit Surana - 02/03/2015 - CR-20141216-8346 - Updated Region
    //Modified By Abhinav Sharma - 03/05/2014 - CR-20140131-4429 - Updated Region
    // map of Country -> Region
    private static map<String, String> countryToRegionMap {

        get {

            if (countryToRegionMap == null) {

                // create a new map and assign the proper values
                countryToRegionMap = new map<string, string> {
                    'Afghanistan' => 'Middle East', 'Aland Islands' => 'Europe', 'Albania' => 'Europe', 'Algeria' => 'Africa',
                    'American Samoa' => 'Australasia', 'Andorra' => 'Europe', 'Angola' => 'Africa', 'Anguilla' => 'Latin America',
                    'Antartica' => 'Antarctica', 'Antigua and Barbuda' => 'Latin America', 'Argentina' => 'Latin America',
                    'Armenia' => 'Europe', 'Aruba' => 'Latin America', 'Australia' => 'Australasia', 'Austria' => 'Europe',
                    'Azerbaijan' => 'Europe', 'Bahamas' => 'Latin America', 'Bahrain' => 'Middle East', 'Bangladesh' => 'Australasia',
                    'Barbados' => 'Latin America', 'Belarus' => 'Europe', 'Belgium' => 'Europe', 'Belize' => 'Latin America',
                    'Benin' => 'Africa', 'Bermuda' => 'Latin America', 'Bhutan' => 'Australasia', 'Bolivia' => 'Latin America',
                    'Bosnia and Herzegovina' => 'Europe', 'Botswana' => 'Africa', 'Bouvet Island' => 'Africa', 'Brazil' => 'Latin America',
                    'British Indian Ocean Territory' => 'Australasia', 'Brunei Darussalam' => 'Australasia', 'Bulgaria' => 'Europe',
                    'Burkina Faso' => 'Africa', 'Burundi' => 'Africa', 'Cambodia' => 'Australasia', 'Cameroon' => 'Africa',
                    'Canada' => 'Canada', 'Cape Verde' => 'Africa', 'Cayman Islands' => 'Latin America', 'Central African Republic' => 'Africa',
                    'Chad' => 'Africa', 'Chile' => 'Latin America', 'China' => 'Australasia', 'Christmas Island' => 'Australasia',
                    'Cocos Islands' => 'Australasia', 'Colombia' => 'Latin America', 'Comoros' => 'Africa', 'Congo' => 'Africa',
                    'Congo, The Democratic Republic of' => 'Africa', 'Cook Islands' => 'Australasia', 'Costa Rica' => 'Latin America',
                    'Cote D\'ivoire' => 'Africa', 'Croatia' => 'Europe', 'Cuba' => 'Latin America', 'Cyprus' => 'Europe',
                    'Czech Republic' => 'Europe', 'Denmark' => 'Europe', 'Djibouti' => 'Africa', 'Dominica' => 'Latin America',
                    'Dominican Republic' => 'Latin America', 'Ecuador' => 'Latin America', 'Egypt' => 'Africa', 'El Salvador' => 'Latin America',
                    'Equatorial Guinea' => 'Africa', 'Eritrea' => 'Africa', 'Estonia' => 'Europe', 'Ethiopia' => 'Africa',
                    'Falkland Islands' => 'Latin America', 'Faroe Islands' => 'Europe', 'Fiji' => 'Australasia',
                    'Finland' => 'Europe', 'France' => 'Europe', 'French Guiana' => 'Latin America', 'French Polynesia' => 'Australasia',
                    'French Southern Territories' => 'Australasia', 'Gabon' => 'Africa', 'Gambia' => 'Africa', 'Georgia' => 'Europe',
                    'Germany' => 'Europe', 'Ghana' => 'Africa', 'Gibraltar' => 'Europe', 'Greece' => 'Europe', 'Greenland' => 'Europe',
                    'Grenada' => 'Latin America', 'Guadeloupe' => 'Latin America', 'Guam' => 'Australasia', 'Guatemala' => 'Latin America',
                    'Guernsey' => 'Europe', 'Guinea' => 'Africa', 'Guinea-Bissau' => 'Africa', 'Guyana' => 'Latin America',
                    'Haiti' => 'Latin America', 'Heard Island and McDonald Island' => 'Australasia',
                    'Holy See (Vatican City State)' => 'Europe', 'Honduras' => 'Latin America', 'Hong Kong' => 'Australasia',
                    'Hungary' => 'Europe', 'Iceland' => 'Europe', 'India' => 'Middle East', 'Indonesia' => 'Australasia',
                    'Iran' => 'Middle East', 'Iraq' => 'Middle East', 'Ireland' => 'Europe', 'Isle of Man' => 'Europe',
                    'Israel' => 'Middle East', 'Italy' => 'Europe', 'Jamaica' => 'Latin America', 'Japan' => 'Australasia',
                    'Jersey' => 'Europe', 'Jordan' => 'Middle East', 'Kazakhstan' => 'Australasia', 'Kenya' => 'Africa',
                    'Kiribati' => 'Australasia', 'Korea, Democratic People\'s Republic of' => 'Australasia',
                    'Korea, Republic of Korea' => 'Australasia', 'Kuwait' => 'Middle East', 'Kyrgyzstan' => 'Australasia',
                    'Lao People\'s Democratic Republic' => 'Australasia', 'Latvia' => 'Europe', 'Lebanon' => 'Middle East',
                    'Lesotho' => 'Europe', 'Liberia' => 'Africa', 'Libyan Arab Jamahiriya' => 'Africa', 'Liechtenstein' => 'Europe',
                    'Lithuania' => 'Europe', 'Luxembourg' => 'Europe', 'Macao' => 'Australasia', 'Macedonia' => 'Europe',
                    'Madagascar' => 'Africa', 'Malawi' => 'Africa', 'Malaysia' => 'Australasia', 'Maldives' => 'Australasia',
                    'Mali' => 'Africa', 'Malta' => 'Europe', 'Marshall Islands' => 'Australasia', 'Martinique' => 'Latin America',
                    'Mauritania' => 'Africa', 'Mauritius' => 'Africa', 'Mayotte' => 'Africa', 'Mexico' => 'Latin America',
                    'Micronesia' => 'Australasia', 'Moldova' => 'Europe', 'Monaco' => 'Europe', 'Mongolia' => 'Australasia',
                    'Montenegro' => 'Europe', 'Montserrat' => 'Latin America', 'Morocco' => 'Africa', 'Mozambique' => 'Africa',
                    'Myanmar' => 'Australasia', 'Namibia' => 'Africa', 'Nauru' => 'Australasia', 'Nepal' => 'Australasia',
                    'Netherlands' => 'Europe', 'New Caledonia' => 'Australasia', 'New Zealand' => 'Australasia',
                    'Nicaragua' => 'Latin America', 'Niger' => 'Africa', 'Nigeria' => 'Africa', 'Niue' => 'Australasia',
                    'Norfolk Island' => 'Australasia', 'Northern Mariana Islands' => 'Australasia', 'Norway' => 'Europe',
                    'Oman' => 'Middle East', 'Pakistan' => 'Middle East', 'Palau' => 'Australasia',
                    'Palestinian Territory, Occupied' => 'Middle East', 'Panama' => 'Latin America', 'Papua New Guinea' => 'Australasia',
                    'Paraguay' => 'Latin America', 'Peru' => 'Latin America', 'Philippines' => 'Australasia', 'Pitcairn' => 'Australasia',
                    'Poland' => 'Europe', 'Portugal' => 'Latin America', 'Puerto Rico' => 'Latin America', 'Qatar' => 'Middle East',
                    'Republic of Panama' => 'Latin America', 'Reunion' => 'Africa', 'Romania' => 'Europe', 'Russia' => 'Australasia',
                    'Russian Federation' => 'Australasia', 'Rwanda' => 'Africa', 'Saint Barthélemy' => 'Latin America',
                    'Saint Helena' => 'Africa', 'Saint Kitt and Nevis' => 'Latin America', 'Saint Lucia' => 'Latin America',
                    'Saint Martin' => 'Latin America', 'Saint Pierre and Miquelon' => 'Canada',
                    'Saint Vincent and the Grenadines' => 'Latin America', 'Samoa' => 'Australasia', 'San Marino' => 'Europe',
                    'Sao Tome and PrincipeSenegal' => 'Africa', 'Saudi Arabia' => 'Middle East', 'Serbia' => 'Europe',
                    'Seychelles' => 'Africa', 'Sierra Leone' => 'Africa', 'Singapore' => 'Australasia', 'Slovakia' => 'Europe',
                    'Slovenia' => 'Europe', 'Solomon Islands' => 'Australasia', 'Somalia' => 'Africa', 'South Africa' => 'Africa',
                    'South Georgia and South Sandwich' => 'Latin America', 'Spain' => 'Latin America', 'Sri Lanka' => 'Australasia',
                    'Sudan' => 'Africa', 'Suriname' => 'Latin America', 'Svalbard and Jan Mayen' => 'Europe',
                    'Swaziland' => 'Africa', 'Sweden' => 'Europe', 'Switzerland' => 'Europe',
                    'Syrian Arab Republic' => 'Middle East', 'Taiwan' => 'Australasia', 'Tajikistan' => 'Australasia',
                    'Tanzania' => 'Africa', 'Thailand' => 'Australasia', 'Timor-Leste' => 'Australasia', 'Togo' => 'Africa',
                    'Tokelau' => 'Australasia', 'Tonga' => 'Australasia', 'Trinidad and Tobago' => 'Latin America', 'Tunisia' => 'Africa',
                    'Turkey' => 'Europe', 'Turkmenistan' => 'Australasia', 'Turks and Caicos' => 'Latin America', 'Tuvalu' => 'Australasia',
                    'Uganda' => 'Africa', 'Ukraine' => 'Europe', 'United Arab Emirates' => 'Middle East', 'United Kingdom' => 'UK',
                    'United States' => 'United States', 'Uruguay' => 'Latin America', 'Uzbekistan' => 'Australasia',
                    'Vanuatu' => 'Australasia', 'Venezuela' => 'Latin America', 'Viet Nam' => 'Australasia',
                    'Virgin Islands, British' => 'Latin America', 'Virgin Islands, US' => 'Latin America', 'Wallis and Futuna' => 'Australasia',
                    'Western Sahara' => 'Africa', 'Yemen' => 'Middle East', 'Zambia' => 'Africa', 'Zimbabwe' => 'Africa'
                };
            }
            return countryToRegionMap;
        }
        set;
    }

    //Added By Abhinav Sharma - CR-20140204-4441 - Restriction status not being updated properly as part of nightly batch job
    /**
     *  @description    :   This method is to delete all Restriction MtM records related to that Accounts when deleted.
     *
     *  @args           :   List of old Account records
     *
     *  @return         :   void
     *
     **/
     public static void deleteAllRestrictionMtMRecords(List<Account> deletedAccounts) {

        //List to hold the Restriction MtM records
        List<Restricted_MtM__c> restrictedMtms = [SELECT ID FROM Restricted_MtM__c WHERE Account__c != null AND Account__c IN : deletedAccounts];

        //Checking list for size value
        if(restrictedMtms != null && restrictedMtms.size() > 0)
            delete restrictedMtms;
     }

     //Added By Abhinav Sharma - 07/03/2014 - CR-20140618-5845
    /**
     *  @description    :   This method is there to update "Member Type" field on case records associated to account record according to its description field value.
     *
     *  @args           :   List of new Accounts, Map of old Account
     *
     *  @return         :   void
     *
     **/
    public static void updateChildrenCasesMemberTypeFieldValue(List<Account> newAccounts, Map<Id, Account> mapOldAccounts) {
		
        //Victor Hanson - 11/20/2017 - CR-20171120-11791 - added bypass_updateChildrenCaseMemberTypeFieldValue
        if (bypass_updateChildrenCaseMemberTypeFieldValue) return;
        bypass_updateChildrenCaseMemberTypeFieldValue = true;
        
        //Set to hold the Account Ids
        Set<Id> setAccountIds = new Set<Id>();

        //Loop through new Account records and filtering out the records for whom "Key Notes" (Description) field got changes
        for(Account acc : newAccounts) {
            if(mapOldAccounts.get(acc.Id).Description != acc.Description) {
                setAccountIds.add(acc.Id);
            }
        }
        
		//Check for set size
		if(setAccountIds.size() > 0) {
			
	        //Map to hold the Account records
	        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT ID, Description FROM Account WHERE Id IN : setAccountIds]);
	
	        //Map of Case records going to be updated with "Member Type" field value
	        Map<Id, Case> mapCasesToBeUpdated = new Map<Id, Case>();
	
	        //Retrieving out all the children Case object records associated to eligible account records
	        for(Case cs : [SELECT Id, Member_Type__c, AccountId FROM Case WHERE AccountId IN : setAccountIds]) {
	
	            //Checking for difference in between field values
	            if(mapAccounts != null && mapAccounts.get(cs.AccountId) != null) {
	
	                //Checking if description field value containing specified string with it or not
	                if(mapAccounts.get(cs.AccountId).Description != null && mapAccounts.get(cs.AccountId).Description.contains(Constants.RIAM_LARGE_CONTRACTS)) {
	                    if(cs.Member_Type__c != Constants.RIAM_LARGE_CONTRACTS) {
	                        cs.Member_Type__c = Constants.RIAM_LARGE_CONTRACTS;
	                        mapCasesToBeUpdated.put(cs.Id, cs);
	                    }
	                } else {
	                    //Checking for null & blank value
	                    if(!String.isBlank(cs.Member_Type__c)) {
	                        cs.Member_Type__c = '';
	                        mapCasesToBeUpdated.put(cs.Id, cs);
	                    }
	                }
	
	            } else {
	
	                //Checking for null & blank value
	                if(!String.isBlank(cs.Member_Type__c)) {
	                    cs.Member_Type__c = '';
	                    mapCasesToBeUpdated.put(cs.Id, cs);
	                }
	            }
	        }
	
	        //Checking for size value && then performing the updates
	        if(mapCasesToBeUpdated.values().size() > 0) {
	            Util.BypassAllTriggers = true;
	            update mapCasesToBeUpdated.values();
	            Util.BypassAllTriggers = false;
	        }
		}
    }
    
    //V_1.11 - Modified by Abhinav Sharma - CR-20180809-12493 - Remove the references of Royall rtype
    //V_1.10 - Added By - Rajeev Jain - 06/07/2016 - 
    /**
     *  @description    :   This method is used to Increase/Decrease Royall Child field counter on Parent Account, when any Royall child account insert/update/delete
     *
     *  @args           :   List of new Accounts, Map of old Account
     *
     *  @return         :   void
     *
     **/
     public static void updateRoyallChildCounter(List<Account> newAccounts, Map<Id, Account> oldAccountsMap){
        
        //Map to hold the Parent Account Instance with fields which needs to be update(Royall Child Counter) corrospondiing to its Id
        Map<Id, Account> mapAccountsForUpdate = new Map<Id, Account>();
        
      	//Commented the Under grad and Royall Advancement record type from the code as we have marked those Rtypes for the eletion  
        Set<String> royallRecordTypes = new Set<String>{'Royall_Admissions_Graduate'/*, 'Royall_Admissions_Undergraduate', 'Royall_Advancement'*/};
        
        //Loop over account Records
        for(Account acc : newAccounts != null ? newAccounts : oldAccountsMap.values()){
            
            //Insert Case
            if(oldAccountsMap == null && acc.ParentId != null)
                mapAccountsForUpdate.put(acc.ParentId, new Account(Id = acc.ParentId, Royall_Children__c = 0));
            
            //Update Case
            if(oldAccountsMap != null && newAccounts != null && 
                    ((acc.ParentId != oldAccountsMap.get(acc.id).ParentId || acc.RecordTypeId != oldAccountsMap.get(acc.id).RecordTypeId)
                    || (acc.r_Current_Year_Account_Status__c != oldAccountsMap.get(acc.id).r_Current_Year_Account_Status__c
                        && (String.isBlank(acc.r_Current_Year_Account_Status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_Current_Year_Account_Status__c)))
                    || (acc.r_Current_Year_Status__c != oldAccountsMap.get(acc.id).r_Current_Year_Status__c
                        && (String.isBlank(acc.r_Current_Year_Status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_Current_Year_Status__c)))
                    || (acc.r_Previous_Year_Account_Status__c != oldAccountsMap.get(acc.id).r_Previous_Year_Account_Status__c
                        && (String.isBlank(acc.r_Previous_Year_Account_Status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_Previous_Year_Account_Status__c)))
                    || (acc.r_Previous_Year_Status__c != oldAccountsMap.get(acc.id).r_Previous_Year_Status__c
                        && (String.isBlank(acc.r_Previous_Year_Status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_Previous_Year_Status__c)))
                    || (acc.r_Next_Year_Account_Status__c != oldAccountsMap.get(acc.id).r_Next_Year_Account_Status__c
                        && (String.isBlank(acc.r_Next_Year_Account_Status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_Next_Year_Account_Status__c)))
                    || (acc.r_Next_Year_Status__c != oldAccountsMap.get(acc.id).r_Next_Year_Status__c
                        && (String.isBlank(acc.r_Next_Year_Status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_Next_Year_Status__c)))
                    || (acc.r_hd_current_year_account_status__c != oldAccountsMap.get(acc.id).r_hd_current_year_account_status__c
                        && (String.isBlank(acc.r_hd_current_year_account_status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_hd_current_year_account_status__c)))
                    || (acc.r_HD_Current_Year_Engagement_Status__c != oldAccountsMap.get(acc.id).r_HD_Current_Year_Engagement_Status__c
                        && (String.isBlank(acc.r_HD_Current_Year_Engagement_Status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_HD_Current_Year_Engagement_Status__c)))
                    || (acc.r_HD_Next_Year_Account_Status__c != oldAccountsMap.get(acc.id).r_HD_Next_Year_Account_Status__c
                        && (String.isBlank(acc.r_HD_Next_Year_Account_Status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_HD_Next_Year_Account_Status__c)))
                    || (acc.r_HD_Next_Year_Engagement_Status__c != oldAccountsMap.get(acc.id).r_HD_Next_Year_Engagement_Status__c
                        && (String.isBlank(acc.r_HD_Next_Year_Engagement_Status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_HD_Next_Year_Engagement_Status__c)))
                    || (acc.r_HD_Previous_Year_Account_Status__c != oldAccountsMap.get(acc.id).r_HD_Previous_Year_Account_Status__c
                        && (String.isBlank(acc.r_HD_Previous_Year_Account_Status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_HD_Previous_Year_Account_Status__c)))
                    || (acc.r_HD_Previous_Year_Engagement_Status__c != oldAccountsMap.get(acc.id).r_HD_Previous_Year_Engagement_Status__c
                        && (String.isBlank(acc.r_HD_Previous_Year_Engagement_Status__c) || String.isBlank(oldAccountsMap.get(acc.id).r_HD_Previous_Year_Engagement_Status__c)))
                )){
                
                //Add in map if new Parent Id is not null
                if(acc.ParentId != null)
                    mapAccountsForUpdate.put(acc.ParentId, new Account(Id = acc.ParentId, Royall_Children__c = 0));
                
                ///Add in map if Old Parent Id is not null
                if(oldAccountsMap.get(acc.id).ParentId != null)
                    mapAccountsForUpdate.put(oldAccountsMap.get(acc.id).ParentId, new Account(Id = oldAccountsMap.get(acc.id).ParentId, Royall_Children__c = 0));   
            }
            
            //Delete case
            if(newAccounts == null && acc.ParentId != null)
                mapAccountsForUpdate.put(acc.ParentId, new Account(Id = acc.ParentId, Royall_Children__c = 0));     
        }
        
        //Check for the size
        if(mapAccountsForUpdate.size() > 0){
            
            //Query on the Child records with Aggregate Results
            for(AggregateResult ar : [select count(Id) ct, ParentId pA 
                                        from Account where ParentId IN : mapAccountsForUpdate.keySet()
                                        AND RecordType.DeveloperName IN : royallRecordTypes 
                                        AND (r_Current_Year_Account_Status__c != null OR 
                                        r_Current_Year_Status__c != null OR r_Previous_Year_Account_Status__c != null OR
                                        r_Previous_Year_Status__c != null OR r_Next_Year_Account_Status__c != null OR 
                                        r_Next_Year_Status__c != null OR r_hd_current_year_account_status__c != null OR
                                        r_HD_Current_Year_Engagement_Status__c != null OR r_HD_Next_Year_Account_Status__c != null OR 
                                        r_HD_Next_Year_Engagement_Status__c != null OR r_HD_Previous_Year_Account_Status__c != null OR 
                                        r_HD_Previous_Year_Engagement_Status__c != null) GROUP BY ParentId]){
                Id parentId = Id.valueOf(String.valueOf(ar.get('pA')));
                
                //Check if Map contains key then Set Child records
                if(mapAccountsForUpdate.containsKey(parentId))
                    mapAccountsForUpdate.get(parentId).Royall_Children__c = Integer.valueOf(ar.get('ct'));      
            }
            
            //Bypass Account trigger for ReRun
            Util.BypassAllTriggers = true;
            
            //Update the map values
            update mapAccountsForUpdate.values();
            
            //Reset Flag
            Util.BypassAllTriggers = false;
        }
     }
     
     //V_1.10 - Added By - Rajeev Jain - 06/07/2016 - 
    /**
     *  @description    :   This method handle royall specific code, which is migrated from Royall enviournment. 
     *
     *  @args           :   List of new Accounts, Map of old Account
     *
     *  @return         :   void
     *
     **/
     public static void updateRoyallAccountYearStatus(List<Account> newAccounts, Map<Id, Account> newAccountMap){
        
        // control trigger execution
        if (!Test.isRunningTest() && !Account_Status_Management__c.getOrgDefaults().Enable_Update_Account_Status_Trigger__c)
            return;
            
        //Calculate the current Fiscal year using shift_fical_year class
        Integer currentFY = shift_get_fiscal_year.current();
        
        // Map to hold the accounts  roll up status fields and Concurrent active years counter
        Map<Id, String> theCurrentStatus = new Map<Id, String>();
        Map<Id, String> thePastStatus = new Map<Id, String>();
        Map<Id, String> theNextStatus = new Map<Id, String>(); 
        
        // Variables used to remenber previous values and keep track of concurrent active years
        Map<Id, list<Integer>> theAccountYearMap = new Map<Id, List<Integer>>();
        
        // Modify By - Mahendra Swarnkar - 2/18/2017 - CR-20170215-10692 - Updated the QUery to include the Royall Record type check in the where clause
        for (Program_Package__c p : [Select Id, Name, Account__c, Fiscal_Year__c, Client_Status_New__c
                                        from Program_Package__c
                                        where Account__c in: newAccountMap.keySet() AND RecordType.DeveloperName =: Label.PROGRAM_PACKAGE_RECORD_TYPE_DEVELOPER_NAME_ROYALL order by Account__c asc, Fiscal_Year__c asc]) {
            
            //Get the status for Previous, Current and Next Fiscal Year
            if (p.Fiscal_Year__c != null){      
                if (Integer.valueOf(p.Fiscal_Year__c) == currentFY) {
                    theCurrentStatus.put(p.Account__c, p.Client_Status_New__c);
                    //theCurrentAccountStatus.put(p.Account__c, p.R_Account_Status__c);
                }
                if (Integer.valueOf(p.Fiscal_Year__c) == currentFY+1) {
                    theNextStatus.put(p.Account__c, p.Client_Status_New__c);
                    //theNextAccountStatus.put(p.Account__c, p.R_Account_Status__c);
                }
                if (Integer.valueOf(p.Fiscal_Year__c) == currentFY-1) {
                    thePastStatus.put(p.Account__c, p.Client_Status_New__c);
                    //thePastAccountStatus.put(p.Account__c, p.R_Account_Status__c);
                }
    
                // Keep count of Concurrent active years based on Client status being Secured or Committed.
                if (p.Client_Status_New__c == 'Secured' || p.Client_Status_New__c == 'Committed') {
                    if (!theAccountYearMap.containskey(p.Account__c)) {
                        List<Integer> temp = new List<Integer>();
                        temp.add(Integer.valueOf(p.Fiscal_Year__c));
                        theAccountYearMap.put(p.Account__c, temp);
                    } else {
                        if (theAccountYearMap.get(p.Account__c).get(theAccountYearMap.get(p.Account__c).size()-1) - Integer.valueOf(p.Fiscal_Year__c) == -1) {
                            theAccountYearMap.get(p.Account__c).add(Integer.valueOf(p.Fiscal_Year__c));
                        } else {
                            theAccountYearMap.get(p.Account__c).clear();
                            theAccountYearMap.get(p.Account__c).add(Integer.valueOf(p.Fiscal_Year__c));
                        }
                    }
                }
            } 
        }
        
        // Save the roll up fields on the accounts
        for (Account a : newAccounts){
            
            //Engagement Status
            if (theCurrentStatus.get(a.Id) != null) {
                a.r_Current_Year_Status__c = theCurrentStatus.get(a.Id); 
            } else {
                a.r_Current_Year_Status__c = null;
            }    
                
            if (thePastStatus.get(a.Id) != null) {
                a.r_Previous_Year_Status__c = thePastStatus.get(a.Id); 
            } else {    
                a.r_Previous_Year_Status__c = null;
            }    

            if (theNextStatus.get(a.Id) != null) {
                a.r_Next_Year_Status__c = theNextStatus.get(a.Id); 
            } else {    
                a.r_Next_Year_Status__c = null;
            }
        }      
     }
     
     /**
      * @Description    :   Method to Populate Solutions Flag field formula.
      *                     solutions Flag Formula Check for:-
      *                     B.1) Formula should check the Institution hierarchy to determine the highest Solution Flag 
      *                          based on the Current & Parent Accounts (ie: Current Account, Parent Account, Top Parent Account)
      *                     B.2) The Formula should display the highest Solutions Flag based on the value in 
      *                          the current and parent/top parent institution's "Solution Status" field.
      *
      * @args           :   List<Site_Issue__c>, Map<Id, Site_Issue__c> msMap
      *
      * @return         :   
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - CR-20160802-10078 - 09/05/2016
                            V1.1 - Modified By - Abhinav Sharma- 08/11/2020 - CR-20180808-12492 - Commented Solution_Adopted__c,Solution_Status__c,Solution_Ended__c field
    **/
   /* public static void populateSolutionFlagFieldOnAccount(List<Account> newAccounts, Map<Id, Account> mapOldAccounts) {
        
        //Set of eligible accounts Ids
        Set<Id> setOfEligibleAccountIds = new Set<Id>();
        
        //Set of eligible Grad parent accounts Ids which are needs to be updated on there update
        Set<Id> setOfEligibleGrandParentAccountIds = new Set<Id>();
        
        //Populate the Account ids set
        for(Account acc : newAccounts) {
            
            //Checking for Update/Insert use case
            if(
                mapOldAccounts == null
                ||
                (
                    mapOldAccounts != null
                    && 
                    (
                        acc.Solution_Adopted__c != mapOldAccounts.get(acc.Id).Solution_Adopted__c
                        || acc.Solution_Status__c != mapOldAccounts.get(acc.Id).Solution_Status__c
                        || acc.ParentId != mapOldAccounts.get(acc.Id).ParentId
                    )
                )
            ){
                setOfEligibleAccountIds.add(acc.Id);
                
                if(acc.ParentId == null) {
                    setOfEligibleGrandParentAccountIds.add(acc.Id);    
                }
            }
        }    
    
        //List to hold the Account Ids
        Set<Id> setParentAccountId = new Set<Id>();
        
        //Map to hold the Grand parent Accounts instance.
        Map<Id, Account> mapGrandParentAccounts = new Map<Id, Account>();
        
        //Checking for size value
        if(setOfEligibleAccountIds.size() > 0) {
            
            //Populate the Account ids set
            for(Account acc : [SELECT Id, ParentId, Parent.ParentId, Solution_Adopted__c, 
                                Solutions_Flag_Image_Holder__c, Solution_Status__c 
                                FROM Account 
                                WHERE Id IN : setOfEligibleAccountIds]){
                
                //Checking for the 1st level parent                    
                if(acc.ParentId != null) {
                    
                    //Populating set with the 1st level parent ID value
                    setParentAccountId.add(acc.ParentId);
                    
                    //Checking for the 2nd level parent ID value
                    if(acc.Parent.ParentId != null)
                        setParentAccountId.add(acc.Parent.ParentId);
                }
                
                //Adding the current context record instance into the set
                setParentAccountId.add(acc.Id);
                
                //populate the Grand parent map
                if(setOfEligibleGrandParentAccountIds.size () > 0 
                    && setOfEligibleGrandParentAccountIds.contains(acc.Id)
                ) {
                    mapGrandParentAccounts.put(acc.Id, acc);               
                }
            }
            
            //Checking for the size value
            if(setParentAccountId.size() > 0){
            
                //Retreving the children records along with 1st and 2nd level parents details
                Map<Id, Account> mapAccounts = new Map<Id, Account> ([Select Id, Solution_Adopted__c, 
                                                                          Solutions_Flag_Image_Holder__c, Solution_Status__c,
                                                                          ParentId, Parent.Solutions_Flag_Image_Holder__c,
                                                                          Parent.Solution_Status__c, 
                                                                          Parent.ParentId, Parent.Solution_Adopted__c,
                                                                          Parent.Parent.Solutions_Flag_Image_Holder__c,
                                                                          Parent.Parent.Solution_Status__c,
                                                                          Parent.Parent.Solution_Adopted__c
                                                                      FROM Account 
                                                                      WHERE (
                                                                                ParentId != null 
                                                                                AND 
                                                                                ParentId IN : setParentAccountId
                                                                            ) 
                                                                            OR (
                                                                                Parent.ParentId != null 
                                                                                AND 
                                                                                Parent.ParentId IN : setParentAccountId
                                                                            ) 
                                                                            OR(
                                                                                ParentId = null
                                                                                AND
                                                                                Id IN : setParentAccountId
                                                                            )
                                                                       ]);
                
                //Checking for the size value
                if(mapAccounts.values().size() > 0) {
                
                    //Map to hold the account record Id as key and List of parent records as a value
                    Map<Id, List<Account>> mapAccountIDWithListOfParents = new Map<Id, List<Account>>();
                
                    //Loop through retrieved account records
                    for(Account acc : mapAccounts.values()) {   
                        
                        //Checking for the grand parent   
                        if(acc.parentId == null) {
                            
                            if(!mapAccountIDWithListOfParents.containsKey(acc.Id))
                                mapAccountIDWithListOfParents.put(acc.Id, new List<Account>());
                        }
                        
                        
                        //Checking for the 1st level parent
                        if(acc.parentId != null) {
                            
                           if(!mapAccountIDWithListOfParents.containsKey(acc.Id))
                                mapAccountIDWithListOfParents.put(acc.Id, new List<Account>{new Account(Id = acc.parentId, 
                                                                                                        Solution_Adopted__c = acc.Parent.Solution_Adopted__c, 
                                                                                                        Solutions_Flag_Image_Holder__c = acc.Parent.Solutions_Flag_Image_Holder__c, 
                                                                                                        Solution_Status__c = acc.Parent.Solution_Status__c
                                                                                                        )});
                            else
                                mapAccountIDWithListOfParents.get(acc.Id).add(new Account(Id = acc.parentId, 
                                                                                          Solution_Adopted__c = acc.Parent.Solution_Adopted__c, 
                                                                                          Solutions_Flag_Image_Holder__c = acc.Parent.Solutions_Flag_Image_Holder__c, 
                                                                                          Solution_Status__c = acc.Parent.Solution_Status__c));
                        }
                        
                        //Checking for the 2nd level of parent   
                        if(acc.parentId != null && acc.parent.parentId != null) {
                            
                            if(!mapAccountIDWithListOfParents.containsKey(acc.Id))
                                mapAccountIDWithListOfParents.put(acc.Id, new List<Account>{new Account(Id = acc.parentId, 
                                                                                                        Solution_Adopted__c = acc.Parent.Solution_Adopted__c, 
                                                                                                        Solutions_Flag_Image_Holder__c = acc.Parent.Solutions_Flag_Image_Holder__c, 
                                                                                                        Solution_Status__c = acc.Parent.Solution_Status__c)});
                            else
                                mapAccountIDWithListOfParents.get(acc.Id).add(new Account(Id = acc.Parent.parentId, 
                                                                                         Solution_Adopted__c = acc.Parent.Parent.Solution_Adopted__c, 
                                                                                         Solutions_Flag_Image_Holder__c = acc.Parent.Parent.Solutions_Flag_Image_Holder__c, 
                                                                                         Solution_Status__c = acc.Parent.Parent.Solution_Status__c));
                        }          
                    }
                    
                    //Checking for size and null value
                    if(mapAccountIDWithListOfParents.size() > 0
                        && mapAccountIDWithListOfParents.keySet() != null
                        && mapAccountIDWithListOfParents.keySet().size() > 0
                    ) {
                        
                        //Map of Solution Status with precedence order
                        Map<String, Integer> mapSolutionStatusValueWithOrder = new Map<String, Integer>();
                        mapSolutionStatusValueWithOrder.put('Active', 2);
                        mapSolutionStatusValueWithOrder.put('Former', 1);
                        mapSolutionStatusValueWithOrder.put('blank', 0);
                        
                        //Map to hold the child account ID as key and corresponding "highest" solution status value 
                        //amongs all the parents as value
                        Map<Id, String> mapOfAccIdWithOverallHighestSolutionStatus = new Map<Id, String>();
                        
                        //Loop through children records Ids (of 1st level children or 2nd level children)
                        //For ex:- A1 and A2   
                        for(Id childAccId : mapAccountIDWithListOfParents.keySet()){
                            
                            //For the Case of Grand parent update case
                            if(mapAccountIDWithListOfParents.get(childAccId) != null && mapAccountIDWithListOfParents.get(childAccId).size() == 0 ){
                                
                                //Check for conditions and then determine accordingly for Active, former, [Blank] Image type
                                if(mapAccounts.containsKey(childAccId)
                                    && mapAccounts.get(childAccId) != null
                                    && mapAccounts.get(childAccId).ParentId == null
                                    && mapAccounts.get(childAccId).Solution_Adopted__c != null
                                ) {   
                                    //Check for the status
                                    if(
                                        mapAccounts.get(childAccId).Solution_Status__c == 'Active'
                                        || mapAccounts.get(childAccId).Solution_Status__c == 'Former'
                                    ){
                                        mapOfAccIdWithOverallHighestSolutionStatus.put(childAccId, mapAccounts.get(childAccId).Solution_Status__c.trim());
                                    }else{
                                        mapOfAccIdWithOverallHighestSolutionStatus.put(childAccId, 'blank');
                                    }
                                }
                                else
                                    mapOfAccIdWithOverallHighestSolutionStatus.put(childAccId, 'blank');
                            }
                            
                            //loop through associated parent IDs
                            //For ex:- (A2->A3), (A1 --> (A2, A3))
                            for(Account parentAcc : mapAccountIDWithListOfParents.get(childAccId)) {
                                
                                //Checking for the blank/null value for the "Solution Status" field
                                if(String.isNotBlank(parentAcc.Solution_Status__c)) {
                                    
                                    //Checking for the presence of child record Id as key in the map
                                    if(!mapOfAccIdWithOverallHighestSolutionStatus.containsKey(childAccId))
                                        mapOfAccIdWithOverallHighestSolutionStatus.put(childAccId, parentAcc.Solution_Status__c.trim());
                                    else {
                                        if(mapOfAccIdWithOverallHighestSolutionStatus.get(childAccId) != null
                                          &&
                                          mapSolutionStatusValueWithOrder.containsKey(mapOfAccIdWithOverallHighestSolutionStatus.get(childAccId))
                                          &&
                                          mapSolutionStatusValueWithOrder.get(mapOfAccIdWithOverallHighestSolutionStatus.get(childAccId)) != null
                                          &&
                                          mapSolutionStatusValueWithOrder.containsKey(parentAcc.Solution_Status__c.trim())
                                          &&
                                          mapSolutionStatusValueWithOrder.get(parentAcc.Solution_Status__c.trim()) != null
                                        ) {
                                            if(mapSolutionStatusValueWithOrder.get(mapOfAccIdWithOverallHighestSolutionStatus.get(childAccId)) < mapSolutionStatusValueWithOrder.get(parentAcc.Solution_Status__c.trim()))
                                                mapOfAccIdWithOverallHighestSolutionStatus.put(childAccId, parentAcc.Solution_Status__c.trim());
                                        }
                                    }
                                } else {
                                    if(!mapOfAccIdWithOverallHighestSolutionStatus.containsKey(childAccId))
                                        mapOfAccIdWithOverallHighestSolutionStatus.put(childAccId, 'blank');
                                }
                            }    
                        }
                        
                        //Checking for map size and null value
                        if(mapOfAccIdWithOverallHighestSolutionStatus.values() != null
                            && mapOfAccIdWithOverallHighestSolutionStatus.values().size() > 0) {
                            
                            //Loop through children records Ids (of 1st level children or 2nd level children)
                            //For ex:- A1 and A2   
                            for(Id chAccId : mapAccountIDWithListOfParents.keySet()) {
                                
                                //Checking for key presence in the map
                                if(mapOfAccIdWithOverallHighestSolutionStatus.containsKey(chAccId)
                                  &&
                                  mapOfAccIdWithOverallHighestSolutionStatus.get(chAccId) != null
                                ) {
                                    //Checking for key and value in map
                                    if(mapAccounts.containsKey(chAccId)
                                      && mapAccounts.get(chAccId) != null
                                      && String.isNotBlank(mapAccounts.get(chAccId).Solution_Status__c)
                                      && mapSolutionStatusValueWithOrder.containsKey(mapAccounts.get(chAccId).Solution_Status__c.trim())
                                      && mapSolutionStatusValueWithOrder.get(mapAccounts.get(chAccId).Solution_Status__c.trim()) != null
                                    ) {
                                        
                                        //Child is having highest value
                                        if(mapSolutionStatusValueWithOrder.get(mapOfAccIdWithOverallHighestSolutionStatus.get(chAccId)) < mapSolutionStatusValueWithOrder.get(mapAccounts.get(chAccId).Solution_Status__c.trim()))
                                            mapOfAccIdWithOverallHighestSolutionStatus.put(chAccId, mapAccounts.get(chAccId).Solution_Status__c.trim());
                                    }                                                          
                                }
                            }        
                                
                            //Map of account records to be updated
                            Map<Id, Account> mapOfAccountsToBeUpdated = new Map<Id, Account>();
                              
                            if(mapOfAccIdWithOverallHighestSolutionStatus.keySet() != null
                                && mapOfAccIdWithOverallHighestSolutionStatus.keySet().size() > 0
                            ) {
                                
                                //Loop through map keys
                                for(Id cId : mapOfAccIdWithOverallHighestSolutionStatus.keySet()) {
                                    if(mapOfAccIdWithOverallHighestSolutionStatus.get(cId) == 'blank')
                                        mapOfAccountsToBeUpdated.put(cId, new Account(Id = cId, Solutions_Flag_Image_Holder__c = null));
                                    else
                                        mapOfAccountsToBeUpdated.put(cId, new Account(Id = cId, Solutions_Flag_Image_Holder__c = mapOfAccIdWithOverallHighestSolutionStatus.get(cId)));
                                }
                            }
                          
                            //Checking map for the size value
                            if(mapOfAccountsToBeUpdated.values() != null
                                && mapOfAccountsToBeUpdated.values().size() > 0) {
                                
                                //Bypassing all the triggers
                                Util.byPassAllTriggers = true;
                                    
                                //Update accounts
                                update mapOfAccountsToBeUpdated.values();
                                    
                                //Enabling triggers again
                                Util.BypassAllTriggers = false;    
                            }    
                        }
                    }        
                }
            }
        }
    }*/
    
    //Added By - Mahendra Swarnkar - CR-20161102-10332 - 1/2/2017
    /**
        *  @description    :   Sync up "Top Parent Institution" field value on the associated contacts 
        *                       with the value of "Top Parent Institution" field of account, on it's change.
        * 
        *  @args           :   List<Account> accounts, Map<Id, Account> mapOldAccounts
        * 
        *  @return         :   void
        * 
    **/  
    public static void populateTopParentInstitutionOnContacts(List<Account> accounts, Map<Id, Account> mapOldAccounts){
        
        //Set to hold account's woth account IDs
        Map<Id, Account> mapOfAccounts = new Map<Id, Account>();
        
        //Loop over Account records
        for(Account acc : accounts) {
            
            //Check for Update case
            if(mapOldAccounts != null 
                && acc.Top_Parent_Institution__c != mapOldAccounts.get(acc.Id).Top_Parent_Institution__c)
                mapOfAccounts.put(acc.Id, acc);
        }
        
        //Check Account set not blank
        if(mapOfAccounts.size() > 0){
            
            //list to hold accounts records
            Map<Id, Contact> MapOfContactsToBeUpdate = new Map<Id, Contact>();
            
            //Get Account associated Contact records 
            for(Contact cont : [SELECT Id, AccountId, Top_Parent_Institution__c 
                                FROM Contact 
                                WHERE AccountId IN : mapOfAccounts.keyset() 
                                ]){
                
                //Check for parent Account and populate contact list to update "Top Parent Institution"
                if(mapOldAccounts.containskey(cont.AccountId)
                    && mapOldAccounts.get(cont.AccountId) != null
                ) {
                    
                    //Checking for the "Top Parent Institution" field value for null
                    if(mapOfAccounts.get(cont.AccountId).Top_Parent_Institution__c != null) {
                        if(cont.Top_Parent_Institution__c != mapOfAccounts.get(cont.AccountId).Top_Parent_Institution__c) {
                            cont.Top_Parent_Institution__c = mapOfAccounts.get(cont.AccountId).Top_Parent_Institution__c;
                            mapOfContactsToBeUpdate.put(cont.Id, cont);
                        }
                            
                    } else {
                        if(cont.AccountId != cont.Top_Parent_Institution__c) {
                            cont.Top_Parent_Institution__c = cont.AccountId;
                            mapOfContactsToBeUpdate.put(cont.Id, cont);
                        }
                    }
                }
            }
            
            //Check for List and update Contact records
            if(mapOfContactsToBeUpdate.values().size() > 0 ){
                
                //Bypassing all the triggers
                Util.byPassAllTriggers = true;
                
                //Update records
                update mapOfContactsToBeUpdate.values();
            
                //Enabling triggers again
                Util.BypassAllTriggers = false; 
            }
        }
    }
    
    //Added By - Abhinav Sharma - CR-20170217-10702
    public static void syncUpChildrenCasesFields(list<Account> newAccounts, map<Id, Account> oldAccountsMap) {
        
        //Map of eligible accounts
        Map<Id, Account> mapOfEligibleAccounts = new Map<Id, Account>();
        
        //Checking for the update use cases and records for there eligibility
        if(oldAccountsMap != null && newAccounts != null) {
            for(Account acc : newAccounts) {
                if(
                    (
                        acc.ParentId != oldAccountsMap.get(acc.Id).ParentId
                        ||
                        acc.Primary_Country__c != oldAccountsMap.get(acc.Id).Primary_Country__c
                    ) 
                ) {
                    mapOfEligibleAccounts.put(acc.Id, acc);
                }
            }        
        }
        
        //Checking set for it's size
        if(mapOfEligibleAccounts.keySet().size() > 0) {
            
            //Map of cases to be updated
            Map<Id, Case> mapOfCasesToBeUpdated = new Map<Id, Case>();
            
            //Commented by Mahendra Swarnkar - 03/04/2020 - CR-20200217-13756 : RT deleted- Expert_Center, International_Speaker_Request, Syndicate Services
            //V_1.20 - Merged By - Rajeev Jain - 07/05/2017
            //Modified By - Abhinav Sharma - CR-20170222-10716 - 4/24/2017 - Add International Speaker Request record type
            //Fetching children cases from the database
            for(Case ca : [SELECT ID, Country__c, Parent_System__c, AccountId
                            FROM Case
                            WHERE AccountId != null
                                AND AccountId IN : mapOfEligibleAccounts.keySet()
                                AND 
                                    (
                                        /*RecordType.DeveloperName = 'Syndicated_Services'
                                       OR
                                       RecordType.DeveloperName = 'Expert_Center'
                                       OR*/
                                       RecordType.DeveloperName = 'International'
                                        /*OR 
                                        RecordType.DeveloperName = 'International_Speaker_Request'*/
                                )           
                          ]) {
                //V_1.20 - Merged By - Rajeev Jain - 07/05/2017 - upto here               
                //Boolean variable to determine whether fields updates requries for the case or not
                Boolean isUpdateHappenForCaseInstance = false;              
                              
                //Checking whether "Parent System" and "Institution Parent Account" differs or not              
                if(ca.Parent_System__c != mapOfEligibleAccounts.get(ca.AccountId).ParentId) {
                    ca.Parent_System__c = mapOfEligibleAccounts.get(ca.AccountId).ParentId; 
                    isUpdateHappenForCaseInstance =  true;
                }
                                  
                //Checking whether "Country" and "Institution Primary Country" differs or not              
                if(ca.Country__c != mapOfEligibleAccounts.get(ca.AccountId).Primary_Country__c) {
                    ca.Country__c = mapOfEligibleAccounts.get(ca.AccountId).Primary_Country__c;               
                    isUpdateHappenForCaseInstance =  true;          
                }
                              
                //Checking for the boolean variable and populating map with case instance accordingly (if requires)
                if(isUpdateHappenForCaseInstance)
                    mapOfCasesToBeUpdated.put(ca.Id, ca);
            }
            
            //Checking map for its size
            if(mapOfCasesToBeUpdated.values().size() > 0) {
                Util.byPassAllTriggers = true;
                update mapOfCasesToBeUpdated.values();
                Util.byPassAllTriggers = false;
            }
        }
    }
    
    //V_1.19 - Added by - Mahendra Swarnkar - 05/04/2017 - CR-20170221-10707 - Added a new method - populateAssociatePrincipalOnopportunityFromAccount
    /**
     *  @description    :   Method to populate Associate Principal On opportunity record with the related Account's Associate Principal name. 
     * 
     *  @args           :   List of Account, Map of old Account
     * 
     *  @return         :   void
     * 
    **/
    public static void populateAssociatePrincipalOnopportunityFromAccount(List<Account> newAccount, Map<Id, Account> mapOldAccounts) {
    
      //Set to hold the Account Ids
      Set<Id> setAccountIds = new Set<Id> ();
      
      //Loop over the opportunity records
      for(Account acc :  newAccount) {
        
        //Check for size and populate the set of account ids
        if(mapOldAccounts != null 
          && acc.Associate_Principal__c != mapOldAccounts.get(acc.Id).Associate_Principal__c)
          setAccountIds.add(acc.Id);
      }
      
      //Map to hold the acccount records
      Map<Id, Account> mapAccounts = new Map<Id, Account> ();
        
      //Check for size
      if(setAccountIds.size() > 0) {
      
        //List to hold the Opportunity records going to be updated
        List<Opportunity> listOpportunityToBeUpdated = new List<Opportunity>();
        
        //Query on Opportunity records
        for(Opportunity opp : [Select Id, Associate_Principal__c, AccountId, Account.Associate_Principal__c, Account.Associate_Principal__r.Name
                  From Opportunity where AccountId != null AND AccountId IN : setAccountIds]) {
          
          
          //populate the Associate_Principal__c field value on opportunity
          if(opp.Account.Associate_Principal__c != null )
            opp.Associate_Principal__c = opp.Account.Associate_Principal__r.Name;
          else
            opp.Associate_Principal__c = null;
            
          //populate the opportunity list
          listOpportunityToBeUpdated.add(opp);
        }
        
        //Check for size
        if(listOpportunityToBeUpdated.size() > 0) {
        
          ///By Pass all the trigger
                Util.byPassAllTriggers = true;
                
                //Update the opportunity records
                update listOpportunityToBeUpdated;
                
                ///Enable all the trigger
                Util.byPassAllTriggers = true;
        
        }
      }
    }
    
    /**
     *  @description    :   Method to sync Relationship_Interaction__c
     * 
     *  @args           :   List<Account> accounts, Map<Id, Account> mapOldAccounts
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.1 - Modified By - 08/04/2017 - Subhash Garhwal - CR-20170803-11120
     * 
     **/
    public static void updateRelationshipIntractionFields(List<Account> accounts, Map<Id, Account> mapOldAccounts) {
        
        //Map to hold Account
        Map<Id, Account> mapAccounts = new Map<Id,Account>();
        
        //Loop over List of Account
        for(Account acc : accounts) {
            
            //Check for condition
            if(acc.EA_AE__c != mapOldAccounts.get(acc.Id).EA_AE__c || acc.GM__c != mapOldAccounts.get(acc.Id).GM__c
                || acc.Principal__c != mapOldAccounts.get(acc.Id).Principal__c || acc.Associate_Principal__c != mapOldAccounts.get(acc.Id).Associate_Principal__c
                || acc.Strategic_Account_Segment__c != mapOldAccounts.get(acc.Id).Strategic_Account_Segment__c) {
                   
                //Map populated
                mapAccounts.put(acc.Id, acc);
            }
        }
        
        //Check for map size
        if(mapAccounts.size() > 0) {
            
            //List of Relationship Interaction
            List<Relationship_Interaction__c> rSIToBeUpdate = new List<Relationship_Interaction__c>(); 
            
            
            for(Relationship_Interaction__c rSI: [Select Id, Institution__c, EA_AE__c, GM__c, Principal__c, Associate_Principal__c,
                                                  Strategic_Account_Segment__c From Relationship_Interaction__c
                                                  Where Institution__c IN : mapAccounts.keySet()]) {
                
                //Check for map key
                if(mapAccounts.containsKey(rSI.Institution__c)) {
                    
                    //Populate fields for Relationship Interaction from Account
                    rSI.EA_AE__c = mapAccounts.get(rSI.Institution__c).EA_AE__c;
                    rSI.GM__c = mapAccounts.get(rSI.Institution__c).GM__c;
                    rSI.Principal__c = mapAccounts.get(rSI.Institution__c).Principal__c;
                    rSI.Associate_Principal__c = mapAccounts.get(rSI.Institution__c).Associate_Principal__c;
                    rSI.Strategic_Account_Segment__c = mapAccounts.get(rSI.Institution__c).Strategic_Account_Segment__c;
                    
                    //Add RI in to list
                    rSIToBeUpdate.add(rSI);
                }
            }
            
            //Check for list size
            if(rSIToBeUpdate.size() > 0) {
                
                //Bypass the trigger
                Util.byPassAllTriggers = true;
                
                //Update
                update rSIToBeUpdate;
                
                Util.byPassAllTriggers = false;
            }
        }
    }
    
    /**
     *  @description    :   Method to Update the related project field when Account Update
     * 
     *  @args           :   List<Account> accounts, Map<Id, Account> mapOldAccounts
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.1 - Created By - 08/12/2017 - Dipesh Gupta- CR-20170426-10878
     * 
     **/
     public static void populateProjectFieldsFromAccount(List<Account> listAccounts, Map<id, Account> oldAccountMap) {
     	
     	//Set to hold tthe Account Id 
     	Set<Id> setAccountIds = new Set<Id>();
     	
        //Query on project where Account is updted Account.
        for(Account acc : listAccounts) {
			
            //check for size
            if(oldAccountMap != null 
               	&& acc.Number_of_Hospitals_in_System__c != oldAccountMap.get(acc.id).Number_of_Hospitals_in_System__c
			) {
                //Inserting Account Id to the set
            	setAccountIds.add(acc.id);    
            }
        }
		
         //Check if set size is greater than 0.
     	if(setAccountIds.size() > 0) {
	    
            //List to hold the projects 
	     	List<Project__c> projectToBeUpdate = new list<Project__c> ();
            
	     	//Query On project for the selected record type.
                //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
	     	/*for(Project__c proj : [Select Id, Number_of_Hospitals__c, Institution__c, Institution__r.Number_of_Hospitals_in_System__c 
                                   	FROM Project__c 
                                   	Where Institution__c != null 
                                   	AND Institution__c IN: setAccountIds 
                                    	// Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - 'NPD','ABSS','Univ','Southwind','TI' and 'Consulting' From Project.
	     				//Modified By - Abhinav Sharma - 06/17/2020 - CR-20200318-13867 - Project Page Layout and RT deletions
	     				//AND RecordType.DeveloperName IN ('CCA', 'EHBI', 'CMA', 'CPM', 'CostOps', 'HP_Consumer_Scheduling', 'iRound','RCS')
                                  ])
			{
	     		
                if(proj.Number_of_Hospitals__c != proj.Institution__r.Number_of_Hospitals_in_System__c){
                    projectToBeUpdate.add(new Project__c(id = proj.Id, Number_of_Hospitals__c = proj.Institution__r.Number_of_Hospitals_in_System__c)); 
                }
	     	}
            
            //Bypass All Triggers
            Util.BypassAllTriggers = true;
            
            //Check for the size of list
	     	if(projectToBeUpdate.size() > 0)
	     		update projectToBeUpdate;
            
            //Enable All Triggers
            Util.BypassAllTriggers = false;*/
	     }
     }
     
   //V_1.23 - Modified By - Dipesh Gupta - 08/23/2017 - CR-20170221-10712, 
    /**
     *  @description    :   Method to Update the related program package job number field on the Account Update
     * 
     *  @args           :   List<Account> accounts, Map<Id, Account> mapOldAccounts
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.1 - Created By - 08/23/2017 - Dipesh Gupta- CR-20170221-10712
     * 			:   V1.2 - Modified BY Abhinav sharma - 09/27/2018 - CR-20180917-12597
     * 			:   V1.3 - Modified by Dipesh Gupta - 05/26/2020 - CR-20200522-14088


     * 
     **/
     
     public static void populateJobNoOfProgramPackage(List<Account> newAccounts, Map<Id, Account> mapOldAccounts) {
     	
     	//Set to hold the Account Ids 
     	Set<Id> setAccountId = New Set<Id>();
     	
     	//Map to hold the school code with respact to Account Id.
     	//Map<Id, String> mapAccountSchoolCode = new Map<Id, String>();
     	
     	//List to hold the royal program.
     	List<Royall_Program__c> royallProgramToBeUpdated = new List<Royall_Program__c>();
     	
     	//Loop through the new List of Account 
     	for(Account acc : newAccounts) {
     		
            //CR-20180917-12597 - Added one more condition if the new Field School_Code_Advancement__c is changed then also the respective Royall Program be changed.
     		//Filling the Set only for those record which have School code populated.
     		if(mapOldAccounts != null && mapOldAccounts.containsKey(acc.Id) && mapOldAccounts.get(acc.Id) != null  
     			&& (mapOldAccounts.get(acc.Id).r_School_Code__c != acc.r_School_Code__c 
                    || mapOldAccounts.get(acc.Id).School_Code_Advancement__c != acc.School_Code_Advancement__c) ) {
     			
     			//Add account id to the Set
     			setAccountId.add(acc.Id);
     			//mapAccountSchoolCode.put(acc.Id, acc.r_School_Code__c);
     		}
     	}	
     	
     	//Check the size of set
     	if(setAccountId.size() > 0) {
     		
     		//Set to hold the program packge Ids
     		Set<Id> setProgramPackage = New Set<Id>();
     		
     		//Fetchinng all the program packges related to the account.
     		for(Program_Package__c programPackge : [Select Id From Program_Package__c where Account__c IN: setAccountId]){
     			
     			//Set holding the account related Program package Ids.
     			setProgramPackage.add(programPackge.Id);		
     		}	
     		
     		//Looop through the Royall program which is related to the Program package
     		for(Royall_Program__c royallProgram : [Select Id, Name, Program_Package__r.Account__c, Program_Package__r.Fiscal_Year__c, Program_Package__r.Account__r.r_School_Code__c, Program_Package__r.Account__r.School_Code_Advancement__c,
     												Target_Audience_New__c, Campaign_Code__c From Royall_Program__c where Program_Package__c IN: setProgramPackage]) {
     			
     			String  royallJobNoFieldValue = '';
     					
     			//Check if the Account	
                if(royallProgram.Program_Package__r.Account__c != null) {
                    
                    //Check for the target Audience Value
                    if(royallProgram.Target_Audience_New__c.equalsIgnoreCase(Label.TARGET_AUDIENCE_VALUE)) {
                       //Check for the Null or blank
                       if(String.isNotBlank(royallProgram.Program_Package__r.Account__r.School_Code_Advancement__c) )
                    	royallJobNoFieldValue = royallProgram.Program_Package__r.Account__r.School_Code_Advancement__c;         
                    }
                    else{
                        //Check for the r_School_Code__c in the Code
                        if(String.isNotBlank(royallProgram.Program_Package__r.Account__r.r_School_Code__c))
                        	royallJobNoFieldValue = royallProgram.Program_Package__r.Account__r.r_School_Code__c;        
                    }
                }
     			
                //Filling the Fiscal Year code
     			if(String.isNotBlank(royallProgram.Program_Package__r.Fiscal_Year__c))
     				royallJobNoFieldValue = royallJobNoFieldValue + String.ValueOf(royallProgram.Program_Package__r.Fiscal_Year__c).Right(2);
     			
                //Filling the Campign new Code.
     			if(String.isNotBlank(royallProgram.Campaign_Code__c))
     				royallJobNoFieldValue = royallJobNoFieldValue + String.valueOf(royallProgram.Campaign_Code__c);
     				
     		
     			royallProgramToBeUpdated.add(new Royall_Program__c (Id = royallProgram.Id, Name = royallJobNoFieldValue));       		}
     		
     		//Bypass All Triggers
            Util.BypassAllTriggers = true;
           
     		//Check the size of List
     		if(royallProgramToBeUpdated.size() > 0)
     			update royallProgramToBeUpdated;
     			
     		//Enable All Triggers
            Util.BypassAllTriggers = false;
            
     	}
     }
	
	/**
     *  @description    :   Method to update Entity field on according to Record Type or Entity Override field
     * 
     *  @args           :   List<Account> accounts, Map<Id, Account> mapOldAccounts
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created By - Subhash Garhwal- 10/06/2017 - Subhash Garhwal - Apollo - CR-20170929-11627
     * 			    V1.1 - Modified By - Mahendra Swarnkar - 11/10/2017  - Apollo - CR-20170929-11627 (Issue--CR11627--QA--00007404)
     * 
     **/
	public static void ValidateEntity(List<Account> accounts, Map<Id, Account> mapOldAccounts) {
		
		//Map to hold account record Type
		Map<Id, String> mapAccountRecordTypes = Util.mapRecordTypes('Account');
		
		//Set to hold the Account Ids
		//Set<Id> setAccIds = new Set<Id>();
		
        //Set to hold the Account Owners Ids
		Set<Id> setAccOwnersIds = new Set<Id>();
		
        //Loop over Account records
		for(Account acc : accounts) {
        
            //Check for Vender Type Account
            if(mapAccountRecordTypes.get(acc.RecordTypeId) == 'Vendor') {
              
                //Populate the Set of Account owner Ids
				setAccOwnersIds.add(acc.OwnerId);  
            }
        }
        
        
        //Map to hols the user records 
        Map<Id, User> mapUsers = new Map<Id, User>();
        
        //Check for size
        if(setAccOwnersIds.size() > 0){
         	
            //Populate user map
            for(User us : [Select Entity__c From User Where Id IN : setAccOwnersIds]) {
                mapUsers.put(us.Id, us);
            }
        }
        
		//Get Current user Entity
		//String currentUserEntity = [Select Entity__c From User Where Id =: UserInfo.getUserId() LIMIT 1].Entity__c;
		
		//Loop over Account records
		for(Account acc : accounts) {
            
            //Check for Accountrecord type
            if(mapAccountRecordTypes.containsKey(acc.RecordTypeId)) {
                
                //Check for Vendor Type account record
                if(mapAccountRecordTypes.get(acc.RecordTypeId) == 'Vendor' 
                    && mapUsers.size() > 0 
                    && mapUsers.containsKey(acc.OwnerId)
                    && mapUsers.get(acc.OwnerId) != null
                 ) {
                    
                    //Populate the Entity with owners Entity
                    acc.Entity__c = mapUsers.get(acc.OwnerId).Entity__c;
                    //throw new CustomException('@@@@@@@  '+mapUsers + ' %%%% '+acc.Entity__c); 
                }
                else{
                    //Check for all record Type nad then accordingly populate the Entity value
                    if(Constants.MAP_ACCOUNT_ENTITY_WITH_RECORD_TYPE.containsKey(mapAccountRecordTypes.get(acc.RecordTypeId)))
                        acc.Entity__c = Constants.MAP_ACCOUNT_ENTITY_WITH_RECORD_TYPE.get(mapAccountRecordTypes.get(acc.RecordTypeId));
                }    
            }
		}
       //Set the flag value to true
       executingOnce = true;     
	}
    /**
     *  @description    :  Method to update opportunity name in case of EAb initiating record type
     * 
     *  @args           :   List of opportunities, Map of Opportunity
     * 
     *  @return         :   void
     * 
     * Created By       :   Created By Rajeev jain - CR-20181008-12649 - 13/03/2019
    **/
    public static void updateOpportunityName(List<Account> newAccounts , Map<Id, Account> oldMapAccount){
        
        //Set to hold the opportunity Ids. 
        Set<Id> accIds = new Set<Id>();
        
        //for loop on the new list of Account. 
        for(Account acc : newAccounts){
            
            //checking for the old and new map to execute the code conditionally.
            if(oldMapAccount == null || 
               oldMapAccount.get(acc.Id).Account_Formal_Name__c != acc.Account_Formal_Name__c
               || oldMapAccount.get(acc.Id).Primary_State_Province__c != acc.Primary_State_Province__c ){
                   
                   //Adding the account ids to the set of the account Ids. 
                   accIds.add(acc.Id);                   
               }
        }
        
		//Checking the size of set.
        if(accIds.size() > 0) {    
            
            //List to hold the opportunity. 
            List<Opportunity> opp = new List<Opportunity>();
            
            //Query on the opportunity to fetch the related opportunity on the account (Only Open Opportunity)
            opp = new List<Opportunity>([Select Id, Name , OwnerId, Opportunity_Products__c, CloseDate, AccountId, RecordTypeId FROM Opportunity 
                                         where AccountId IN :accIds AND IsClosed = false AND 
                                         RecordTypeId =:  CPQConstants.OPP_RT_ID_EAB_INITIATING]);
            
            //Checking the size of the List. 
            if(opp.size() > 0){
                
              	//Calling a method on OpportunityTriggerHelper. 
                OpportunityTriggerHelper.createInitiatingOpportunityName(opp, null); 

                //Bypass All trigger to true.
				Util.ByPassAlltriggers = true;   
                
                bypass_createInitiatingOpportunityName =  True;
                
                update opp;
               
                //Bypass All trigger to false.
				Util.ByPassAlltriggers = false;    
                
               
            }
        } 
    }
    
    /**
     *  @description    :  Update EAB Relationship on Institution based on Membership Status
     * 
     *  @args           :   List of Accounts
     * 
     *  @return         :   void
     * 
     *  @revisions		:   09/16/2019 - Victor Hanson - CR-20181008-12649 - Created
    **/
    public static void updateEABRelationship(Map<Id, Account> acctMap) {
        //get all Accounts with Memberships
        List<AggregateResult> aggrMembershipsByAcctByStatus = [SELECT COUNT(Id), Account_Name__c acct, Membership_Status_Text__c memberStatus
                                                             FROM Membership__c 
                                                             WHERE Account_Name__c IN :acctMap.keySet()
                                                             GROUP BY Account_Name__c,Membership_Status_Text__c];
        
        Map<Id, String> mapAcctIdToRelationshipStatus = new Map<Id, String>();
        
        for (AggregateResult ar : aggrMembershipsByAcctByStatus) {
            Id acctId = (Id) ar.get('acct');
            String tempStatus = (String) ar.get('memberStatus');
            
            //get the current status
            String currentStatus = mapAcctIdToRelationshipStatus.get(acctId);
            
            if (tempStatus != null) {
                //set the temp status based on membership status
                if (tempStatus.startsWithIgnoreCase('Member'))
                    tempStatus = 'Member';
                else if (tempStatus.startsWithIgnoreCase(Constants.PROSPECT_PENDING_FUTURE_START_DATE))
                    tempStatus = 'Pending Future Start';
                else if (tempStatus.startsWithIgnoreCase(Constants.PROSPECT_RECENT_DROP))
                    tempStatus = 'Past Member';
                else
                    tempStatus = 'Prospect';
                
                //set the status based on tempStatus
                if (currentStatus == null
                    || tempStatus == 'Member'
                    || currentStatus != 'Member' && tempStatus == 'Pending Future Start'
                    || currentStatus != 'Member' && currentStatus != 'Pending Future Start' && tempStatus == 'Past Member') 
                {
                    currentStatus = tempStatus;
                }
            }
            
            //set value in map
            mapAcctIdToRelationshipStatus.put(acctId, currentStatus);
        }
        
        //loop through all the accts and see if they need to have the Relationship Status updated
        for (Account acct : acctMap.values()) {
            String currentStatus = mapAcctIdToRelationshipStatus.get(acct.Id);
            if (acct.EAB_Relationship_Status_Text__c != currentStatus)
                acct.EAB_Relationship_Status_Text__c = currentStatus;
        }
    }
    
    /**
     *  @description    :  	Populates geolocation status if the account meets the criteria
     * 
     *  @args           :   List of Accounts, Map of Accounts
     * 
     *  @return         :   void
     * 
     *  @revisions		:   07/14/2020 - CR-20200706-14269 - Victor Hanson - created
     *		        	:   07/28/2020 - CR-20200706-14269 - Rajeev Jain - Modified for Fix soql 101 Error
     *					
    **/
    public static void updateGeolocation(List<Account> newAccounts , Map<Id, Account> oldMapAccount) {
        boolean executeGeolocationJob = false;
	// 07/28/2020 - CR-20200706-14269 - Rajeev Jain - Modified for Fix soql 101 Error
        boolean isSandboxCheck = false; 
        if(test.isRunningTest())
        {
            isSandboxCheck = !UserInfo.getUserName().endswith('com.eab');
        }
        else{
            isSandboxCheck = SessionHelper.isSandbox();
        }
        for (Account newAcct : newAccounts) {
            Account oldAcct;
            if (oldMapAccount != null) oldAcct = oldMapAccount.get(newAcct.Id);
            //don't set geolocation status to ready for batch if this is a sandbox -- limited number of callouts per month
            if (!isSandboxCheck || (Label.Allow_Sandbox_Address_Geocode != null && Label.Allow_Sandbox_Address_Geocode.equalsIgnoreCase('TRUE'))) {
                //is this a new account OR is at least one primary address field changed?
                if (newAcct.Primary_Address_Line_1__c != null &&
                    newAcct.Primary_Country__c != null &&
                    (oldAcct == null ||
                     newAcct.Primary_Address_Line_1__c != oldAcct.Primary_Address_Line_1__c ||
                     newAcct.Primary_City__c != oldAcct.Primary_City__c ||
                     newAcct.Primary_State_Province__c != oldAcct.Primary_State_Province__c ||
                     newAcct.Primary_Country__c != oldAcct.Primary_Country__c))
                {
                    //clear any existing geolocation and timezone data
                    newAcct.Primary_Location__Latitude__s = null;
                    newAcct.Primary_Location__Longitude__s = null;
                    newAcct.Time_Zone_ID__c = null;
                    newAcct.Time_Zone_Name__c = null;
                    newAcct.Geolocation_Status__c = LocationHelper.READY_FOR_BATCH;
                }
            }
            
            //if any accounts have geolocation status = ready for batch, execute the batch job
            if (newAcct.Geolocation_Status__c == LocationHelper.READY_FOR_BATCH && (oldAcct == null || oldAcct.Geolocation_Status__c != newAcct.Geolocation_Status__c)) {
                executeGeolocationJob = true;
            }
            
        }
        
        if (executeGeolocationJob) {
            Integer enqueuedJobs = [SELECT COUNT() FROM AsyncApexJob 
                                    WHERE JobType='BatchApex' 
                                    AND Status IN ('Processing','Preparing','Queued') 
                                    AND ApexClass.Name = 'Batch_GeocodeAddress'] ;
            
            //if the job isn't already running
            if(enqueuedJobs <= 0){
                database.executeBatch(new Batch_GeocodeAddress(), 5);
            }
        }
    }
    
    /**
    * @description		: This method is used to update Requires_Acquia_Sync__c field to true on All Contacts.
    *                              Logic : if Account.Time_Zone_ID__c  And Account.Account_Formal_Name__c is updated 
    *                              with some new value then update Requires_Acquia_Sync__c field of all the contact under this account
    *                              to true. 
    *                    
    * 
    * @args			: List<Account> newAccounts, Map<Id, Account> mapOfOldAccounts
    * 
    * @return	        	: void
    * 
    * @revision log		: V1.0 - Created - Saurabh Kumar - 04/02/2021 - CR-20210128-14854
    * 				: V1.1 - Modified By - Chirag Soni - 12/22/2021 - CR-20210606-15193 - added logic to sync registration.
    * */
    public static void validateAccountToSyncAcquia(List<Account> newAccounts , Map<Id, Account> mapOfOldAccounts){
        
        //set to hold account id 
        Set<Id> accountIds = new Set<Id>();
        for(Account account : newAccounts){
            
            //check if the value of Time_Zone_ID__c And Account_Formal_Name__c is changed 
            if(account.Time_Zone_ID__c != mapOfOldAccounts.get(account.Id).Time_Zone_ID__c ||
               account.Account_Formal_Name__c != mapOfOldAccounts.get(account.Id).Account_Formal_Name__c)
                accountIds.add(account.id);
        }
        if(accountIds.size()==0)
            return;
        
        Map<Id, Contact> mapOfIdAndContactToBeUpdated = new   Map<Id, Contact>();
        
        for(Contact contact : [SELECT Id, Acquia_Id__c, Requires_Acquia_Sync__c FROM Contact WHERE AccountId IN : accountIds]){
            
            mapOfIdAndContactToBeUpdated.put(contact.Id, new Contact(Id = contact.Id, Requires_Acquia_Sync__c = true));
        }
        
        if(mapOfIdAndContactToBeUpdated.values().size()==0)
            return;
        
        //Modified By Chirag Soni - 12/22/2021 - CR-20210606-15193 - added logic to sync registration.
        Util.byPassAllTriggers = true;
        update mapOfIdAndContactToBeUpdated.values();
        Util.byPassAllTriggers = false;
        
        ContactTriggerUtilities.syncContactAndRegistrationsWithAcquia(mapOfIdAndContactToBeUpdated.values(), null);
    }
}