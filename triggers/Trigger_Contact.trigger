/**
 *  Description     :   This trigger is to handle all the pre and post processing operation for Contact record
 * 
 *  Created By      :   Bhavi
 * 
 *  Created Date    :   07/13/2012
 * 
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.1 - Modified By - Bhavi Sharma - 11/14/2013 - CR-20130419-2900
 *                      V_1.2 - Modified By - Abhinav Sharma - 03-07-2014 - CR-20140204-4441
                        V_1.3 - Modified By - Bhavi Sharma - 01/23/2015 - CR-20141209-8274 - New method added - resendBouncedAgreement()
                        V_1.4 - Modified By - Subhash Garhwal - 07/02/2015 - CR-20150618-9014 - New method added - updateStaffAssignment
                        V_1.5 - Manual Merged By - Rajeev Jain - 11/09/2015
                        V_1.6 - Modified By - Padmesh Soni - 17/08/2015 - CR-20150729-9114 - New method Added - createIncentiveChangeLog()
                        V_1.7 - Manual Merged By - Rajeev Jain - 11/09/2015 - upto here
                        V_1.8 - Modified By - Mahendra Swarnakar - CR-20150831-9207 - 11/25/2015 - Contact Edit Validation
                        V_1.9 - Modified By - Rajeev Jain - CR-20151120-9402 - 04/20/2016 - Modified createIncentiveChangeLog
                        V_2.0 - Modified By - Mahendra Swarnkar - 5/30/2016 - CR-20151209-9452 - Release 51
                        V_2.1 - Modified By - Rajeev Jain - 06/24/2016 - Royall Migration - Royall SFDC Schema Release.
                                                                       - Merging of Shift_Contact_Trigger on Contact object, from Royall Instance to Corporate Instance
                        V_2.2 - Modified By - Mahendra swarnakar - 11/8/2015 - CR-20160729-10074
                        V_2.3 - Modified By - Mahendra Swarnakar - CR-20161102-10332 - 12/20/2016 - Invoked a new method (populateTopParentInstitutionOnContacts)
                        V_2.4 - Modified By - Abhinav Sharma - 1/31/2017 - CR-20160812-10112 - Updated the CheckInstitutionChange() method 
											     - Added new method CreateCloneForHistoricalTracking() 
                        V_2.5 - Modified By - Mahendra Swarnkar - 1/21/2017 - CR-20160907-10171
                        V_2.6 - Modified By - Abhinav Sharma - 06/04/2017 - DS114
                        V_2.7 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
                        V_2.8 - Modified By - Mahendra Swarnkar - Apollo Release - CR-20170928-11571 - 10/09/2017 -  Added a new call for Entity field.
			V_2.9 - Modified By - Mahendra Swarnkar - Apollo Release - CR-20170928-11552 - 10/09/2017 -  Added a new call for Entity field.
			V_3.0 - Modified By - Colin McGloin - CR-20180125-11899 - 02/02/2018 - Added method which checks if we need to sync Workspace fields to User record 
			V_3.1 - Modified By - Abhinav sharma - CR-20180417-12165 - 08/08/2018 - new method checkHardBounceReasonAndDeactivateSiteProfile
			V_3.2 - Merged By   - Rajeev jain - Deployment Of Marketo Pahse 2 Release.
			V_3.3 - Merged By   - Rajeev Jain  - Deployment of CR-20180605-12266 - 08/31/2018
			V_3.4 - Modified By - Victor Hanson - 04/29/2019 - CR-20190425-13033 - removed references to updateContactPersonalAddressUpdated()
			V_3.5 - Modified By - Dipesh Gupta - 01/28/2020 - CR-20180912-12589 -  added method for update contact field
			V_3.6 - Modified By - Dipesh Gupta - 1/28/2020 - CR-20180912-12589   commented this method "CheckInstitutionChange", updateAddressInformationOnContactFromInstitution as per CR requirement
			V_3.7 - Modified By - Saurabh Kumar - 09/29/2020 - CR-20200821-14453 - syncRegistrationPartnerStatus method is added
			V_3.8 - Modified By - Mahendra Swarnakar - 02/27/2020 - CR-20200217-13758
			V_3.9 - Modified By - Mahendra Swarnakar -02/27/2020 - CR-20200217-13758
			V_4.0 - Modified By - Saurabh Kumar- 04/02/2021 - CR-20210128-14854  Added new methods validateContactToSyncAcquia() & syncContactAndRegistrationsWithAcquia()
			V_4.1 - Modified By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
 * 
 **/

trigger Trigger_Contact on Contact (before update, before insert, before delete, after update, after insert, after delete) {
    
    //Check for trigger
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
        ContactTriggerUtilities.populateEntityField(Trigger.new, Trigger.oldMap);
  
   //return immediately if method returns true  
    if(Util.areTriggersOnThisObjectBypassed('Contact')) return;
  
    // if a trigger bypass is active, return immediately without processing
    if (Util.BypassAllTriggers)  {
        return;
    }
    
    // set this flag to true so we don't have duplicate execution going on
    SiteUserHelper.IsTriggerContact = true;
    
    //Check for the request Type
    if(Trigger.isBefore) {
        
        if (trigger.isInsert) {
            
            // Code Added - VH - 1/7/14
            ContactTriggerUtilities.validateContactBeforeInsert(trigger.new);
            
            //Dipesh Gupta - CR-20180912-12589 - 03/18/2020. 
            ContactTriggerUtilities.updateAddressInformationOnContactFromInstitution(Trigger.new);
        }
        
        if (trigger.isUpdate) {
            
            // Code Added - Dipesh Gupta - 02/24/2020
            ContactTriggerUtilities.CheckForDuplicacyInUpdationOfContact(trigger.new, trigger.oldMap);
            
             //Added By - Saurabh Kumar - 04/02/2021 - CR-20210128-14854
            ContactTriggerUtilities.validateContactToSyncAcquia(trigger.new, trigger.oldMap);
        }
        
        //Added By - Mahendra Swarnakar - CR-20150831-9207 - 11/25/2015 - Contact Edit Validation
        //Start from here
        if(Trigger.isInsert || Trigger.isUpdate) {
            
            //Added by Abhinav Sharma - CR-20180605-12266 - 08/28/2018. 
            ContactTriggerUtilities.checkCompanyEmailEligibility(trigger.new, trigger.oldMap);
            
            //Added By - Mahendra Swarnakar - CR-20161102-10332 - 12/20/2016
            //Calling Helper class method
            ContactTriggerUtilities.populateTopParentInstitutionOnContacts(trigger.new, trigger.oldMap);
            
            //Calling Helper class method
            ContactTriggerUtilities.validateContactFieldsForInvalidPhrase(trigger.new, trigger.oldMap);
            
            //Added by Colin McGloin - CR-20180125-11899 - 02/02/2018
            ContactTriggerUtilities.checkForWorkspaceChanges(trigger.new, trigger.oldMap);
            
            //Added by Dipesh Gupta - CR-20180912-12589 - 01/28/2020
            ContactTriggerUtilities.autoPopulateContactField(trigger.new, trigger.oldMap);

            //Added by Colin McGloin - CR-20201020-14618 - 11/5/2020
            PSEUtilities.runPSAPracticeToPublicGroupLogic(trigger.new, trigger.oldMap);
        }
        //Upto here
        
        
        //Modified By - Dipesh Gupta - 1/28/2020 - CR-20180912-12589   commented this method as per CR requirement
        /*
        if (trigger.isUpdate) {
            ContactSiteHelper.CheckInstitutionChange(trigger.new, trigger.oldMap);
        }
        */
        //Check for the event type
        if(Trigger.isDelete) {
    
            //Validate contact record before deleting
            ContactTriggerUtilities.validateContactBeforeDelete(Trigger.Old);
            
            //Added By Abhinav Sharma on 03-07-2014 - CR-20140204-4441 - Restriction status not being updated properly as part of nightly batch job
            //Calling Helper class method
            ContactTriggerUtilities.deleteAllRestrictionMtMRecords(trigger.old);
            
            //Added By - Rajeev Jain - 06/24/2016 - Royall Migration - Royall SFDC Schema Release.
            //Modified By - Mahendra swarnakar - 11/8/2015 - CR-20160729-10074
            if (!system.isFuture() && !system.isScheduled() && !system.isBatch() && Shift_ChangeDelete_Callout.calloutSettings.Enable_Contact_Trigger__c) {
                Shift_ChangeDelete_Callout.processRecords((List<SObject>)trigger.old, 'delete', 'Contact');
            }
            
            //Added By - Saurabh Kumar - 09/29/2020 - CR-20200821-14453
            ContactTriggerUtilities.syncRegistrationPartnerStatus(Trigger.new, Trigger.oldMap);
        }
    }
    
    if (Trigger.IsAfter) {
        
        if (trigger.isUpdate) {
            
            //Added By - Abhinav Sharma - 06/04/2017 - DS114
            ContactTriggerUtilities.updateContractABCRecordWithContactValues(trigger.new, trigger.oldMap);
            ContactTriggerUtilities.updateSubscriptionRecordWithContactValues(trigger.new, trigger.oldMap);
            ContactTriggerUtilities.updateOpportunityRecordWithContactValues(trigger.new, trigger.oldMap);
            ContactTriggerUtilities.updateMembershipRecordWithContactValues(trigger.new, trigger.oldMap);
            
            //Added By - Mahendra Swarnkar - 1/21/2017 - CR-20160907-10171
            ContactTriggerUtilities.updateMKCRecords(trigger.new, trigger.oldMap); 
            
            //VH 8/18/14 - EAB - if the contact's email changes, update the site profile username
            ContactSiteHelper.updateSiteProfilesFromContact(trigger.new, trigger.oldMap);
            
            //Modified by Mahendra Swarnkar - 02/18/2020 - CR-20190904-13309 - Field: Eligible_For_Cloning__c is deleted from contact
            //Code Added - Abhinav Sharma - 1/31/2017 - CR-20160812-10112
            //ContactSiteHelper.CreateCloneForHistoricalTracking(trigger.new, trigger.oldMap);
            
            //Added By - Subhash Garhawal - 05/30/2018 - CR-20180529-12249
            ContactTriggerUtilities.deleteOpportunityContactRole(trigger.new, trigger.oldMap);
            
            //Modified By - Bhavi Sharma - 01/23/2015 - CR-20141209-8274 - Call helper class method for resending the agreement
            if(ContactTriggerUtilities.EXECUTE_RESEND_BOUNCED_AGREEMENT == true) {
	    // ContactTriggerUtilities.resendBouncedAgreement(Trigger.New, Trigger.oldMap);
            }
            
            //Added by - Subhash Garhwal - 07/02/2015 - 07/02/2015 - CR-20150618-9014
            //Call helper class method.
            //This method is used to rename all the related SA name if contact name is changed
            ContactTriggerUtilities.updateStaffAssignment(Trigger.new, Trigger.oldMap);
            
            //Added By - Mahendra swarnakar - 09/18/2015 - CR-20150819-9165
            //Call helper class method.
            //This Method update the related Research Study Interaction if Institution is changed
            //ContactTriggerUtilities.populateInstitutionLookUpFieldForNPD(Trigger.new, Trigger.oldMap);
            
            //Added by Abhinav sharma - CR-20180417-12165 - 08/08/2018 
            ContactTriggerUtilities.checkHardBounceReasonAndDeactivateSiteProfile(Trigger.new, Trigger.oldMap);
            
            //Manual Merger By - Rajeev Jain - 11/09/2015
            //Added by - Padmesh Soni - 17/08/2015 - CR-20150729-9114     
            //Moved from here to below code - Rajeev Jain - 04/20/2016 - CR-20151120-9402
            //call the Helper class.
            //This method is used to create Incentive Change Log Records when contacts are created or updated
            //ContactTriggerUtilities.createIncentiveChangeLog(Trigger.new, Trigger.oldMap); 
            //Manual Merger By - Rajeev Jain - 11/09/2015 - upto here
            
            //Added By - Rajeev Jain - 06/24/2016 - Royall Migration - Royall SFDC Schema Release.
            //Modified By - Mahendra swarnakar - 11/8/2015 - CR-20160729-10074
            if (!system.isFuture() && !system.isScheduled() && !system.isBatch() && Shift_ChangeDelete_Callout.calloutSettings.Enable_Contact_Trigger__c) {               
                Shift_ChangeDelete_Callout.processRecords((List<SObject>)trigger.new, 'update', 'Contact');
            }
            
            //Calling a method - CR-20190111-12831
            ContactTriggerUtilities.updateKeyContactOnContact(trigger.new, trigger.oldMap);
            
            //Added By - Saurabh Kumar - 09/29/2020 - CR-20200821-14453
            ContactTriggerUtilities.syncRegistrationPartnerStatus(Trigger.new, Trigger.oldMap);
            
            //Added By - Saurabh Kumar - 04/09/2021 - CR-20210128-14854
            ContactTriggerUtilities.syncContactAndRegistrationsWithAcquia(Trigger.new, Trigger.oldMap);
            
        }
	
        //Added By - Rajeev Jain - 04/20/2016 - CR-20151120-9402
        if(Trigger.isInsert || Trigger.isUpdate) {
            
            //Added By - Mahendra Swarnkar - 5/30/2016 - CR-20151209-9452 - Release 51
            //Start from here
            //To populate the "Marketing Asssociated Sign Off Date" value on User record with "Marketing Asssociated Sign Off Date" field value on the contact
            //VH Commented out 04/29/2019 - CR-20190425-13033
            //ContactTriggerUtilities.populateMASignOffDateOnUser(trigger.new, trigger.oldMap);         
            //Added By - Mahendra Swarnkar - 5/30/2016 - CR-20151209-9452 - Release 51 - Ends here
            //Upto here
            
            //Rajeev Jain - Moved from above commented code to here, in order to call it at both event(Insert and Update)
            ContactTriggerUtilities.createIncentiveChangeLog(Trigger.new, Trigger.oldMap);
            
            //Added by Colin McGloin
            ContactTriggerUtilities.checkForWorkspaceChanges (Trigger.new, Trigger.oldMap);
            
            if(Trigger.isInsert)
            	ContactTriggerUtilities.updateMovedContactStatus(Trigger.new);
        }
    }
    //=============================Modified by Mahendra Swarnakar -02/27/2020 - CR-20200217-13758 - Start here===================================
    //return immediately if method returns true
    if(Util.areTriggersOnThisObjectBypassed('Contact')) return; 
    
    try {
        
        // if bypass all triggers is true, return without processing
        if (util.BypassAllTriggers || Util.BypassContactRestrictionTrigger) return;
        
        //Added condition by Bhavi - 06/14/2012 - Existing code will run only for before events
        if(Trigger.isBefore) {
            
            if (trigger.isBefore && trigger.isUpdate) {
                
                // bypass all triggers when updating the events;
                Util.BypassAllTriggers = true;
                ContactTriggerUtilities.PopulateContactTitleFromEvent(trigger.new, trigger.oldMap);
                //Calling helper class method to manage the restriction status
                ContactTriggerUtilities.UpdateRestrictionStatus(trigger.new);
                Util.BypassAllTriggers = false;
                
                //Bhavi - 12/18/2013 - CR-20130816-3463
                //SiteUserHelper.trackLoginHistory(trigger.new, trigger.old);
                
                Set<Id> accids = new Set<Id>();
                // Loop through Contacts and build a list of Account Ids
                for (Contact c: Trigger.new)
                {
                    // Only add the Account Id if the Contact has an Account
                    If (c.accountid != null)
                        accids.add(c.accountid);
                }
                // If there are Account Ids from the Contacts that spawned this trigger, then process
                if (accids.size() != 0)
                {   
                    // Get a map of Accounts relating to these Contacts w/ the Account Id as the key
                    Map<Id, Account> allaccounts = new Map<Id, Account> ([select id, Account_Restriction_Status__c from account where Id in :accids ]);
                    
                    // Loop through Contacts that spawned this trigger
                    for (Contact c: Trigger.new)
                    {
                        // If the Contact has an account, then process it
                        if (c.accountid != null)
                        {
                            // Get the Account Restriction Status value and assign it to a variable
                            string s = allaccounts.get(c.accountid) != null ? allaccounts.get(c.accountid).Account_Restriction_Status__c : null;
                            
                            // If the Account has a restriction, add it to the Contact
                            if (s != null)
                                c.Contact_Restriction_Status__c =  'Account - '+ s.substring(0,Math.min(s.length(), 70)); // maximum length = 80, and "account - " = 10 letters         
                        }
                    }
                }
            }
        } else if(Trigger.isAfter) {
            
            //Check for the update event
            if(Trigger.isUpdate) {
                
                //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
                //Call the helper class methid to delete the Membership Key Contact related to the InActive Contacts
                //ContactTriggerUtilities.deleteKeyMemberContactsForInActiveContacts(Trigger.New);            
            }
        }
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
   //=================================Modified by Mahendra Swarnakar -02/27/2020 - CR-20200217-13758 - End Here=================================
}