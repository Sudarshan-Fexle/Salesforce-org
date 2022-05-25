/*
Purpose:    This Trigger populates the related Account/Contact restriction status based on the most restrictive restriction attached to them.
            It queries all the related Restrictions on a particular account for this processing. 
            You can find the logic in the comments inside the Trigger.

Create By:  Angela Williams (SAP) 11/2010           

Last Modified By:   Jeremy Nottingham (SAP) 2/25/2011

Current Version:    v1.4

Revision Log:       v1.0 - Created code
                    v1.1 - (NB-2011-01-24) Added header, code comments, and reviewed code coverage
                    v1.2 - (JN-2011-01/27) Changed logic for calculating Contact Restriction Status: Included any Contacts under affected Accounts as well.
                    v1.3 - (JN 2/25/2011) Added Before logic to uncheck the Run Trigger checkbox if it's checked.
                    v1.4 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
                    v1.5 - Modified By - Abhinav Sharma - 08/13/2014 - CR-20140604-5691 - Allow Adv.com contacts to be moved from Inactive to Active institutions
		    		v1.6 - Modified By - Mahendra Swarnkar - 05/19/2016 - CR-20160512-9853
		    		v1.7 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
		    		V1.7 - Modified By - Subhash Garhwal - 10/09/2017 - CR-20170928-11568 -  Added a new call to update Entity
		    		
*/
trigger RestrictedMtM_UpdateRestrictionStatus on Restricted_MtM__c (before insert, before update, after insert, after delete, after update) {
	

	try {
    	
    	//Check for trigger
    	if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    		Util.validateEntityValue(Trigger.new, Trigger.oldMap, 'Restricted_MtM__c', 'Entity__c', 'Restriction__c', 'Entity__c', 'Restriction__r', 'Restrictions__c');
    			
    	//return immediately if method returns true	
    	if(Util.areTriggersOnThisObjectBypassed('Restricted_MtM__c')) return;
    	
    	
        // return immediately without processing if either of these are true
        if (Util.BypassAllTriggers) return;
    
        //if before insert/update, set whether or not the retriction is expired.
        if (Trigger.IsBefore) {
            RestrictionTriggerHelper.SetExpiration(trigger.new);
        }
    
        //Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849
        //Start From Here
        if (trigger.isAfter && trigger.isDelete) {
    
            //Calling Helper class method
            RestrictionTriggerHelper.DeleteProcess(trigger.oldMap);
        }
        //Upto Here
    
        if (Trigger.IsAfter && !trigger.isDelete) {
    
            // List to hold Restriction Ids of each Restriction MtM
            List<Id> restrictionIdList = new List<Id>();
    
            // Create List of RestrictionMtM records based on trigger type
            list<Restricted_MtM__c> rmtms = (Trigger.IsDelete) ? Trigger.old : Trigger.new;
    
            // Loop over RestrictionMtM records and add their Restriction Ids to a list
            for (Restricted_MtM__c rmtm : rmtms) {
                if (rmtm.Restriction__c != null) {
                    // Add the Restriction Id to the list of Restriction Ids
                    restrictionIdList.add(rmtm.Restriction__c);
                }
            }
    
            // Quesry for all related Restrictions
            List<Restrictions__c> restrictionsList = [select Id, Category__c, Status__c from Restrictions__c 
            where Id IN:restrictionIdList
            and Status__c != 'Retired'];
    
            // Build a Map of related Restrictions to their Id as a key
            map<id, Restrictions__c> id2restmap = new map<id, Restrictions__c>(restrictionslist);
    
            // List to store all of the source RestrictedMtM records.
            List<Restricted_MtM__c> sourceRestMtMOriginal = new List<Restricted_MtM__c>();
    
            // Build list of source RestrictionMtM records
            for(Restricted_MtM__c res: rmtms) {
                if (res.Restriction__c != null) {
                    sourceRestMtMOriginal.add(res);
                }
            }
    
            // Find the new restriction category as it wont be available in Trigger.new
            restrictionIdList = new List<Id>();
    
            // Rebuild the related Restriction Id list
            for(Restricted_MtM__c mtm: sourceRestMtMOriginal) {
                restrictionIdList.add(mtm.Restriction__c);
            }
    
            // Map to story Catagories w/ Restriction Id as the key
            Map<Id, String> categoryMap = new Map<Id, String>();
    
            // Build a list of catagories w/ the Restriction Id as the key
            for(Restrictions__c rst: restrictionsList ) {
                // Add the Restriction Id to the list of Restriction Ids
                categoryMap.put(rst.Id, rst.Category__c);
            }
    
            //Find the record type ids for this object type
            String accountRecordTypeId, contactRecordTypeId;
    
            map<String, Id> rtmap = Util.recordtypemap('Restricted_MtM__c');
            accountRecordTypeId = rtmap.get('Account Restriction');
            contactRecordTypeId = rtmap.get('Contact Restriction');
    
            //if(accountRecordTypeId !=null && contactRecordTypeId !=null){
            // Holds the mapping for RestrictedMtM records with their Account references.
            Map<Id, Id> restMtM_AccountIdMapping = new Map<Id, Id>();
    
            // Holds the mapping for RestrictedMtM records with their Contact references.
            Map<Id, Id> restMtM_ContactIdMapping = new Map<Id, Id>();
            set<id> acctids = new set<id>();
            set<id> contactids = new set<id>();
    
            boolean accountFlag = false;
            boolean contactFlag = false;
    
            // Loop through all RestrictionMtMs and determine if they are an Account or Contract type RestrictionMtM
            // Add their Id to the appropriate list for Account or Contact RestrictionMtM
            for(Restricted_MtM__c rmtm: sourceRestMtMOriginal) {
                //Populate Account Map if record type is Account Restriction
                if(rmtm.Account__c != null) {
                    System.debug('Account Instruction Type found');
                    //restMtM_AccountIdMapping.put(rmtm.Id, rmtm.Account__c);
                    acctids.add(rmtm.Account__c);
                    accountFlag = true;
                }
                //Populate Contact Map if record type is Contact Restriction
                else if(rmtm.Contact__c != null) {
                    System.debug('Contact Instruction Type found');
                    restMtM_ContactIdMapping.put(rmtm.Id, rmtm.Contact__c);
                    contactids.add(rmtm.Contact__c);
                    contactFlag = true;
                }
            }
    
            // DAF - added this section 11/15/11 - get account IDs that were deleted from the MtM
            if (trigger.isUpdate) {
                for (Integer i = 0; i < sourceRestMtMOriginal.size(); i++) {
                    if (trigger.old[i].Account__c != trigger.new[i].Account__c) {
                        acctids.add(trigger.old[i].Account__c);
                        accountFlag = true;
                    }
                }
            }
    
            /* Process for Account restriction first by using the Account Map and the below mentioned conditional logic */
            /*
            IF Recordtype is “Institution Restriction” (Account)
            Update Account Restriction Status on Account
            If one of the Restriction Categories is “Restricted: Permission Required”
            · Account Restriction = “Restricted: Permission Required”
            Else
            · Account Restriction = “Critical Background Information”
            */
    
            // If there are RestrictionMtMs that reference Accounts then process
            if (accountFlag) {
    
                //Exclude the Records which are deleted or updated. The status on account shall be based on latest restrictions. 
                //List<Restricted_MtM__c> listRestrictions = [select Id, Account__c, Restriction__r.Category__c from Restricted_MtM__c where Account__c IN : restMtM_AccountIdMapping.values()];  
                map<id, Account> acctid2acctmap = new map<id, Account>([select id,
                (select id, Contact_Restriction_Status__c from Contacts), 
                (select Restriction__r.Category__c from Restrictions_MtM__r where Restriction__r.Status__c != 'Retired') 
                from Account where id in :acctids]);
    
                List<Restricted_MtM__c> listRestrictions;
    
                map<id, list<Restricted_MtM__c>> accid2restlist = new map<id, list<Restricted_MtM__c>>();
    
                // Loop through each account and build a map of Restriction MtM records w/ Account Id as their key
                for (Account a : acctid2acctmap.values()) {
                    accid2restlist.put(a.id, a.Restrictions_MtM__r);
                }
    
                Map<Id, List<Restricted_MtM__c>> restMtM_RestrictionsMapping = new Map<Id, List<Restricted_MtM__c>>();
    
                /* Add the current record to the Lists if its not Delete Trigger. 
                This is to ensure that we have the latest values available for current record
                */
    
                if(!Trigger.isDelete) {
                    // Loop through RestrictionMtM records that are not being deleted and build a list of Restriction to process and a map of Restrictions for each account
                    for(Restricted_MtM__c rmtm: sourceRestMtMOriginal) {
                        if (rmtm.Account__c != null) {
                            listRestrictions = acctid2acctmap.get(rmtm.Account__c).Restrictions_MtM__r;
                            listRestrictions.add(rmtm);
                            accid2restlist.put(rmtm.Account__c,listRestrictions);
                        }
                    }
                }
    
                /*
                // Put the Account Id and a blank List for all related restrictions in the Map  
                for(Restricted_MtM__c rest: listRestrictions){
                List<Restricted_MtM__c> listRest = new List<Restricted_MtM__c>();
                restMtM_RestrictionsMapping.put(rest.Account__c, listRest); 
                }*/
    
                List<Account> accountsToUpdate = new List<Account>();
    
                // Loop through each account in this map and set the Account restriction status based on the associated RestrictionMtMs
                for (Account acc : acctid2acctmap.values()) {
                    //Get Contacts to check restrictions on from this Account
                    for (Contact c : acc.Contacts) {
                        contactids.add(c.Id);
                        contactFlag = true;
                    }
    
                    //Default value
                    acc.Account_Restriction_Status__c = null;
    
                    // Determine if this account should be restricted based on 'Info Alert' only
                    if (acc.Restrictions_MtM__r.size() > 0) 
                        acc.Account_Restriction_Status__c = 'Critical Background Information';
    
                    // Loop through each RestrictionMtM on this account and determine if this Account should be restricted based on a 'Restricted' status
                    for (Restricted_MtM__c rmtm : acc.Restrictions_MtM__r) {
                        if (rmtm.Restriction__r.Category__c == 'Restricted: Permission Required') {
                            //all it takes is one bad one, and we're done.
                            acc.Account_Restriction_Status__c = 'Restricted: Permission Required';
                            break;
                        }
                    }
    
                    // Add each account to a list to be updated
                    accountsToUpdate.add(acc);
                }
    
                //Update all the eligible accounts
                if (accountstoupdate.size() > 0) {
                    
                    //Bypassing all the triggers
                    Util.BypassAllTriggers = true;
                    
                    //Update Accounts
                    update accountsToUpdate;
                }
            }
    
            /* Process for Contact restriction by using the Account Map and the below mentioned conditional logic */
            /*
            If Record Type = “Contact Restriction”
                Update Contact Restriction Status on Contact
            If there are no Account Restrictions on Contact’s Account
                If Contact Restrictions
                    If one of the Restriction Categories is "Restricted: Permission Required"
                        Contact Restriction = "Restricted: Permission Required"
                    else
                        Contact Restriction = "Critical Background Information
                    else
                        If one of the Account Restrictions is "Restricted: Permission Required"
                            Contact Restriction = "Account - Restricted: Permission Required"
                        else
                            If one of the Contact Restriction Categories is "Restricted: Permission Required"
                                Contact Restriction = "Restricted: Permission Required"
                            else
                                Contact Restriction = "Critical Background Information
            */
    
            // If there are RestrictionMtMs that reference Contacts then process
            if(contactFlag) {
    
                /*
                Find the account information for the contacts associated with Restrictions
                START
                */
                
                //Set to hold all "inactive" type picklist values for the institution object status field
                Set<String> setOfInstitutionInactiveStatuses = Constants.SET_INSTITUTION_INACTIVE_TYPE_STATUS; 
    
                //Modified By - Abhinav Sharma - 08/13/2014 - CR-20140604-5691 - Included the Account.Status field in the query
                List<Contact> contacts = [select Id, Contact_Restriction_Status__c, AccountId, Account.Account_Restriction_Status__c, Account.Status__c,
                (select Restriction__r.Category__c from Restrictions_MtM__r where Restriction__r.Status__c != 'Retired')     
                from Contact where Id IN :contactids];
    
                for (Contact c : contacts) {
                    //Default value
                    c.Contact_Restriction_Status__c = null;
                    //No Account Restrictions 
                    if (c.Account.Account_Restriction_Status__c == null) {
                        for (Restricted_MtM__c rmtm : c.Restrictions_MtM__r) {
                            if (rmtm.Restriction__r.Category__c == 'Critical Background Information') 
                                c.Contact_Restriction_Status__c = 'Critical Background Information';
                            if (rmtm.Restriction__r.Category__c == 'Restricted: Permission Required') {
                                c.Contact_Restriction_Status__c = 'Restricted: Permission Required';
                                break;
                            }
                        }
                    //High Restriction on Account
                    } else if (c.Account.Account_Restriction_Status__c == 'Restricted: Permission Required') {
                        c.Contact_Restriction_Status__c = 'Account - Restricted: Permission Required';
                    //Must be Low Restriction on Account. Check for high restriction on Contact
                    } else {
                        c.Contact_Restriction_Status__c = 'Account - Critical Background Information';
                        for (Restricted_MtM__c rmtm : c.Restrictions_MtM__r) {
                            if (rmtm.Restriction__r.Category__c == 'Restricted: Permission Required') {
                                c.Contact_Restriction_Status__c = 'Restricted: Permission Required';
                                break;
                            } 
                        }
                    }
                    
                    //Added by - Abhinav Sharma - 08/13/2014 - CR-20140604-5691
                    if(setOfInstitutionInactiveStatuses.contains(c.Account.Status__c))
                        c.Bypass_Filters__c = true;
                    
                } //end for Contact c : contacts
                
                //Bypassing all triggers
                Util.BypassAllTriggers = true;
                
                //Modified By - Mahendra Swarnkar - 05/19/2016 - CR-20160512-9853
                //Updating records via batch when are more than 1000
                if (contacts.size() > 1000 && !system.isBatch() && !system.isFuture()) {
                    Set<Id> setRestrictionMTMIds = new Set<Id>();
                    for(Restricted_MtM__c rMTM : [SELECT Id FROM Restricted_MtM__c WHERE Restriction__c != null
                                                        AND Contact__c != null AND Contact__c IN : contacts]) {
                        setRestrictionMTMIds.add(rMTM.Id);
                    }
                    if(setRestrictionMTMIds.size() > 0) {
                        Batch_RestrictionUpdate batch = new Batch_RestrictionUpdate(setRestrictionMTMIds);
                        database.executeBatch(batch, 1);
                        // return immediately
                        return;
                    }
                } else {
                    if(contacts.size() > 0)
                        update contacts;
                }

            }//end if ContactFlag 
        } //end if Trigger.IsAfter
    //Catching DML Exceptions
    } catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));

    //Catching all Exceptions
    } catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}