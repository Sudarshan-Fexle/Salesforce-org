// DAF - added after update
/*
    Purpose:    Populate fields (on before insert and before update) only if one of these fields changed: Formal Name, Primary_City__c, Primary_State_Province__c):
                1) Name =  [Formal Name] - [City] [State Abbrev]

                ***on before insert and before update*** (If OwnerID changed):
                2) EA_AE__c = Lookup to the UserID on the AccountTeamMember with rol of “EA or AE”
                
                ***on after insert***: 
                4) Create Membership__c records: For all active Program__c records, create a Membership__c many-to-many record
                Program__c = program ID
                Account_Name__c = Account ID

                ***on after delete***:
                5) remove the memberships ?

    Create By:          Pierre Eymard (SAP Contractor)

    Last Modified By:   Nathan Banas (SAP) - 1/25/2011

    Current Version:    v1.8

    Revision Log:       v1.0 - (PE) Created code
                        v1.1 - (JN) - Modified to resolve errors
                        v1.2 - (NB-2011-01-25) - Added header, code comments, and reviewed code coverage
                        v1.3 - Simplyforce - Bhavi- 2011-11-28 - CR-20110916-67
                        v1.4 - VH - 7/31/2013 - CR-2083 Added method to kickoff approval process for vendor institutions
                        v1.5 - Abhinav Sharma - 03-05-2014 - CR-20140204-4441
                        v1.6 - Modfied By - Abhinav Sharma - 07/03/2014 - CR-20140618-5845
                        v1.7 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
                        v1.8 - VH - 09/08/2014 - EAB Project
                        V1.9 - Rajeev Jain - 06/07/2016 - Royall Migration - Royall SFDC Schema Release - Distinction of Royall Account with EAB Accounts - Work on AfterInsert,Update,Delete
                        V2.0 - Rajeev Jain - 06/14/2016 - Royall Migration - Royall SFDC Schema Release - Merging of Account Triggers from Royall Enviournmnent.
                                                         - Indented whole trigger code which was looking very ockward. 
                                                         - Two Trigger on Account Object Merged here from Roayll Instance.
                                                            - 1 - Shift_Account_Trigger
                                                            - 2 - shift_update_acc_years_status
                        V2.1 - Modified By - Mahendra Swarnkar - CR-20160802-10078 - 09/05/2016
                        V2.2 - Modified By - Mahendra Swarnkar - CR-20161102-10332 - 1/2/2017
                        V2.3 - Modified By - Abhinav Sharma - CR-20170217-10702 - Invoked a new method - syncUpChildrenCasesFields
                        V2.4 - Modified By - 06/04/2017 - Abhinav Sharma - DS114  - Added call for "populateFieldsValuesOnContracts" method
                        V2.5 - Modified By - 06/05/2017 - Subhash Garhwal - DS114  - Added call for "updateRelationshipIntractionFields" method
                        V2.6 - Merged By - Rajeev Jain - 07/05/2017(In order of migration tasks of - Releases after Q2CDev3 sandbox refresh date[04/07/2017] in Q2CDev3 sandbox from Test sandbox in order to sync with Q2c Beta Release and Revenue Management
                        V2.7 - Modified By - Mahendra Swarnkar - 05/04/2017 - CR-20170221-10707 - Invoked a new method - populateAssociatePrincipalOnopportunityFromAccount
                        V2.8 - Merged By - Rajeev Jain - 07/05/2017 - upto here
                        V2.9 - Modified By Dipesh Gupta - 08/12/2017 - CR-20170426-10878 - Added a new Method populateProjectFieldsFromAccount.
                        V3.0 -  Modified By - Dipesh Gupta - 08/23/2017 -CR-20170221-10712 Added a new Method.populateJobNoOfProgramPackage
                        V3.1 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  to add bypass logic to trigger.
                        V3.2 - Modified By - Subhash Garhwal - 10/06/2017 - Apollo - CR-20170929-11627 -  Added a new method ValidateEntity
                        V3.3 - Modified By - Victor Hanson - 09/16/2019 - CR-20181208-12776 - added updateEABRelationship
                        V3.4 - Modified By - Victor Hanson - 07/14/2019 - CR-20200706-14269 - added updateGeolocation
                        V3.5 - Modified By -  Abhinav Sharma - 8/13/2020 -  CR-20180808-12492 - Commented out "populateSolutionFlagFieldOnAccount" method invocation
                        V3.6 - Modified By - Saurabh Kumar - 04/02/2021 - CR-20210128-14854 - added a new method validateAccountToSyncAcquia ()
*/
trigger Account_NameEAMemberships on Account (before delete, before insert, before update, after insert, after update, after delete) {   
	
		try {
    
        //Check for trigger
        //Call helper class method populate the entity field, 10/06/2017 - Subhash Garhwal - Apollo - CR-20170929-11627
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            
            //07/14/2020 - CR-20200706-14269 - Victor Hanson
            AccountTriggerHelper.updateGeolocation(Trigger.New, Trigger.OldMap);
            
            //Check for AccountTriggerHelper's executingOnce to prevent duplicate executions
            If(AccountTriggerHelper.executingOnce == false)    
        		AccountTriggerHelper.ValidateEntity(Trigger.New, Trigger.OldMap);
            
            if (trigger.isUpdate) {
                
                //09/16/2019 - CR-20181208-12776 - populated eab relationship status
                AccountTriggerHelper.updateEABRelationship(trigger.newMap);
            }
        }   
                            
        //return immediately if method returns true
        if(Util.areTriggersOnThisObjectBypassed('Account')) return;
        
        // if bypass all triggers is true, return without processing
        if (util.BypassAllTriggers) return;
        
        if (trigger.isAfter) {
            
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //VH - 09/08/2014 - EAB Project
                SiteUserHelper.institutionUpsertToSiteDatabase(trigger.new, trigger.oldMap);
                
            }
            
            if (trigger.isUpdate) {
                
                //Subhash Garhwal - 6/5/2017
                AccountTriggerHelper.updateRelationshipIntractionFields(trigger.new, trigger.oldMap);
                
                //V1.13 - Added By - Abhinav Sharma - CR-20170217-10702
                AccountTriggerHelper.syncUpChildrenCasesFields(trigger.new, trigger.oldMap);
                
                // CR-3556 Update parent institution rollups
                AccountTriggerHelper.populateParentAcctRollups(trigger.new, trigger.oldMap);
                
                //Added by - By - Mahendra Swarnkar - CR-20161102-10332 - 1/2/2017
              AccountTriggerHelper.populateTopParentInstitutionOnContacts(trigger.new, trigger.oldMap);
                
                //Added By - 06/04/2017 - Abhinav Sharma - DS114 
                AccountTriggerHelper.populateFieldsValuesOnContracts(trigger.new, trigger.oldMap);
                
                //V1.10 - Added by Rajeev Jain - 06/14/2016 - Royall Migration - Royall SFDC Schema Release - Manual Merge
                if (!system.isFuture() && !system.isScheduled() && !system.isBatch() && Shift_ChangeDelete_Callout.calloutSettings.Enable_Account_Trigger__c) 
                    Shift_ChangeDelete_Callout.processRecords((List<SObject>)trigger.new, 'update', 'Account');
                   
                 //V_1.18 -  Modified By - Dipesh Gupta - 08/23/2017 -CR-20170221-10712 
                 AccountTriggerHelper.populateJobNoOfProgramPackage(trigger.new, trigger.oldMap);
                
                
                 //Added by - By - Saurabh Kumar - 04/02/2021 - CR-20210128-14854
                 AccountTriggerHelper.validateAccountToSyncAcquia(trigger.new, trigger.oldMap);
                
            }
            
            //V1.9 - Added By Rajeev Jain - 06/07/2016
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)
                AccountTriggerHelper.updateRoyallChildCounter(Trigger.New, Trigger.OldMap); 
        }
        
        // NB20110114 - Added Condition !Util.IsTrigger_AccountNameEAMemberships to prevent duplicate executions
        if (!Util.IsTrigger_ContractFieldUpdate && !Util.IsTrigger_EventUpdateFields && !Util.IsTrigger_EventPrewire && !Util.IsBatch && !Util.IsTrigger_AccountNameEAMemberships) {
            
            // Added to prevent duplicate execution when updating accounts
            Util.IsTrigger_AccountNameEAMemberships = true;
            
            // If this trigger was called by a delete action, process results
            if(Trigger.isDelete) { 
                /************** 5) we need to delete the memberships ***********/
                
                // Create a map of Memberships to delete /w the Membership Id as the key
                map<id, Membership__c> memstodelete = new map<id, Membership__c>([select id from Membership__c where Account_Name__c in :Trigger.oldmap.keyset()]);
                
                //Call @future to delete Memberships for each Program, because this would be too many DML rows, passing the above map to the method
                if (!Util.IsTesting)
                    
                    //Bhavi Sharma - 04/26/2013 - CR-20130227-2597 - Added condition to make the callout only if not current context is not batch or future
                    if(!System.isFuture() && !System.isBatch())
                        Util.deleteMemberships(memstodelete.keyset());   
                        
            } else {
                
                // retreive institution record type map
                Map<String, Id> acctRTMap = AccountTriggerHelper.AccountRTMap;
                
                if (Trigger.isAfter && trigger.isInsert) {
                    
                    // VH 7/31/13 CR-2093
                    if (trigger.isInsert) AccountTriggerHelper.BeginVendorApproval(trigger.New);
                }
                
                // If this trigger was called by a before action, process results
                if (Trigger.isBefore) {
                    
                    // CR-3734 - populate the Account's Region based on Primary Country
                    AccountTriggerHelper.populateRegion(trigger.New);
                    
                    // CR-2083
                    AccountTriggerHelper.RequireCommentsForAppRejection(trigger.New);
                    
                    /**** Simplyforce - Bhavi- 2012-09-04 - CR-20120521-906 ****/
                    
                    //Check for the event
                    if(Trigger.isInsert || Trigger.isUpdate) {
                        
                        //Call helper class populate TOP parent data
                        AccountTriggerHelper.populateTopParentInstitute(Trigger.New, Trigger.OldMap);
                        
                    }
                    /**** Simplyforce - Bhavi- 2012-09-04 - CR-20120521-906 ****/
                    
                    /********* 1) format the NAME  ***********/
                    
                    // Loop through each account that spawned this trigger
                    for (Account a : Trigger.new) {
                    
                        // if it's an update, we only update the name if there's a reason for it
                        if (Trigger.isUpdate && !(a.Account_Formal_Name__c != System.Trigger.oldMap.get(a.Id).Account_Formal_Name__c ||
                                                  a.Primary_State_Province__c != System.Trigger.oldMap.get(a.Id).Primary_State_Province__c ||
                                                  a.Primary_City__c != System.Trigger.oldMap.get(a.Id).Primary_City__c || 
                                                  ((a.Primary_State_Province__c == null || a.Primary_State_Province__c == '') && (a.Primary_Country__c != System.Trigger.oldMap.get(a.Id).Primary_Country__c)) ||
                                                  a.Name != System.Trigger.oldMap.get(a.Id).Name))
                            continue;
                        
                        // Set Account Name equal <Account Formal Name> - <Account Primary City> <Account Primary State>
                        
                        //Commented by Bhavi
                        //String accname = a.Account_Formal_Name__c +' - '+ a.Primary_City__c +' '+ a.Primary_State_Province__c;
                        
                        //Bhavi - Check Primary_State_Province__c value, if null then populate Name with Primary County field
                        String accname;
                        if(a.Primary_State_Province__c != null && a.Primary_State_Province__c != '')
                            accname = a.Account_Formal_Name__c +' - '+ a.Primary_City__c + ' - ' + a.Primary_State_Province__c;
                        else if(a.Primary_Country__c != null && a.Primary_Country__c != '')
                            accname = a.Account_Formal_Name__c +' - '+ a.Primary_City__c + ' - ' + a.Primary_Country__c;
                        else
                            accname = a.Account_Formal_Name__c +' - '+ a.Primary_City__c;
                        
                        
                        //truncate if too long for the field
                        a.Name = accname.substring(0,Math.min(accname.length(), Account.Name.getDescribe().getLength()));
                    }
                    
                    // Set to store accountIds to prepare for the next 2 updates: ea_ae__c
                    set<Id> accids = new Set<Id>();
                    
                    // Loop through each Account and put the accountIds in a set to prepare for the next 2 updates: ea_ae_c
                    for (Account a : Trigger.new) {
                    
                        /* DAF - changed below  // bypass updates if the owner hasn't changed
                        if (Trigger.isUpdate && !(a.ownerid != System.Trigger.oldMap.get(a.Id).ownerid))
                        continue;
                        
                        // Add account Id to list to process for the next 2 updates
                        accids.add(a.Id);
                        */
                        // DAF - added below
                        if ((Trigger.isUpdate && (a.ownerid != System.Trigger.oldMap.get(a.Id).ownerid))) { 
                            // Add account Id to list to process for the next 2 updates
                            accids.add(a.Id);
                        }
                        // changed 10/13/11      if ((Trigger.isUpdate && (a.Type_of_Institution__c != System.Trigger.oldMap.get(a.Id).Type_of_Institution__c)) && (rtMap.containsKey(a.Type_of_Institution__c))) {
                        if ((Trigger.isInsert) && (acctRTMap.containsKey(a.Type_of_Institution__c))) {
                            a.RecordTypeId = acctRTMap.get(a.Type_of_Institution__c);
                        }
                        // DAF - added above
                    }
                    
                    /*************** 2) If Insert or OwnerID changed EA_AE__c = Lookup to the UserID on the AccountTeamMember with rol of “EA or AE” *********/
                    
                    //VH 3/13/18: only query for account team members if there are accountIds to query
                    List<AccountTeamMember> acctmbrs = new List<AccountTeamMember>();
                    if (accids.size() > 0) 
                        acctmbrs = [SELECT id, accountid, userid, TeamMemberRole FROM AccountTeamMember WHERE accountid IN :accids AND (TeamMemberRole='AE or EA' OR TeamMemberRole LIKE '%Research & Insights RM')];
                    
                    Map<Id, List<AccountTeamMember>> acctmbraccids = new Map<Id, List<AccountTeamMember>>();
                    
                    // Loop through Account Team Members for the related Accounts
                    for (AccountTeamMember actm : acctmbrs) {
                    
                        List<AccountTeamMember> actmList = acctmbraccids.get(actm.accountid);
                        if (actmList == null)
                            actmList = new List<AccountTeamMember>();
                        
                        actmList.add(actm);
                        
                        // Create a map of Account Team Members w/ Account Id as the key  
                        acctmbraccids.put(actm.accountid, actmList);
                        // note: if there are more than one accountteammember for an accountid, only one is used
                    }
                    
                    // Loop through Accounts that spawned this trigger
                    for (Account a : Trigger.new){
                    
                        // If the map of Account Team Members w/ Account Id as the key can successfully retrieve
                        // the current Account Id in the loop, then add the Account Team Member's User Id to EA_AE__c
                        // field on the Account in the loop
                        //if (acctmbraccids.get(a.id) != null )
                        //    a.EA_AE__c = acctmbraccids.get(a.id).userid ; 
                        List<AccountTeamMember> actmembers = acctmbraccids.get(a.id);
                        
                        if (actmembers != null) {
                        
                            for (AccountTeamMember act : actmembers) {
                                
                                if (act.teamMemberRole == 'AE or EA' )
                                    a.EA_AE__c = act.userid;
                            }
                        }
                        
                    }
                    
                    // Map to store Acccounts w/ Account EA_AE__c contact Id as the key
                    Map<Id,Account> accwitheaaeids = new Map<Id,Account>();
                    Map<Id,Account> accwithRMRIids = new Map<Id,Account>();
                    
                    // Loop through Accounts that spawned this trigger and build the accwitheaaeids map
                    for (Account a : Trigger.new) {
                    
                    
                        // Only add to the map if the field is not null
                        if (a.EA_AE__c != null)
                            accwitheaaeids.put(a.EA_AE__c, a );
                    }
                    
                    //System.debug(' ************ accwitheaaeids size = '+ accwitheaaeids.size());
                    if (accwitheaaeids.size() != 0 ) {
                    
                        // Query all contacts related to the Accounts EA_AE__c field
                        List<Contact> contacts = new List<Contact> ([select id, Employee_User_Record__c  from Contact where Employee_User_Record__c in :accwitheaaeids.keySet() ]);
                        
                        // Map to store Contact records w/ the Contacts SF User Id as the key
                        Map<Id, Contact> contactIds = new Map<Id, Contact> ();
                        
                        // Loop through contacts and build the contactIds map
                        for (Contact c : contacts) {
                            //System.debug(' ************ putting contact: '+c.id);
                            contactIds.put(c.Employee_User_Record__c, c);
                            // note: if there are more than one contact for an accountid, only one is used
                        }
                    }
                    
                    
                    
                    //System.debug(' ************ accwithRMRIids size = '+ accwitheaaeids.size());
                    if (accwithRMRIids.size() != 0 ) {
                        
                        List<Contact> contactsRMRIs = new List<Contact> ([select id, Employee_User_Record__c  from Contact where Employee_User_Record__c in :accwithRMRIids.keySet() ]);
                        
                        // Map to store Contact records w/ the Contacts SF User Id as the key
                        Map<Id, Contact> contactRMRIIds = new Map<Id, Contact> ();
                        
                        // Loop through contacts and build the contactRMRIIds map
                        for (Contact c : contactsRMRIs) {
                            
                            contactRMRIIds.put(c.Employee_User_Record__c, c);
                            // note: if there are more than one contact for an accountid, only one is used
                        }
                        
                        
                    }
                } else {
                
                    // trigger.isBefore
                    /************** 4) if Trigger.isBefore... so in after trigger: Create the Membership object ***********/
                    //Call @future to insert Memberships for each Program, because this would be too many DML rows.
                            
                    //                if (!Util.IsTesting)
                    if ((!Util.IsTesting) && (Trigger.isInsert)) { 
                        
                        //Bhavi Sharma - 04/26/2013 - CR-20130227-2597 - Added condition to make the callout only if not current context is not batch or future
                        if(!System.isFuture() && !System.isBatch())
                            Util.makeMembershipsforAccounts(Trigger.newmap.keyset());
                    }   
                    
                    // DAF - added below
                    if (Trigger.isUpdate) {
                    
                        Set<Id> accRTchangesIDs = new Set<Id>();
                        for (Account a : Trigger.new) {
                        
                            if (a.RecordTypeId != Trigger.oldMap.get(a.Id).RecordTypeId) {
                                accRTchangesIDs.add(a.Id);
                                system.debug('DAFx: ' + a.Id);
                            }
                        }
                        if ((!Util.IsTesting) && (accRTchangesIDs.size() > 0)) {
                            
                            //Bhavi Sharma - 04/26/2013 - CR-20130227-2597 - Added condition to make the callout only if not current context is not batch or future
                            if(!System.isFuture() && !System.isBatch())
                                Util.makeMembershipsforAccounts(accRTchangesIDs);   
                        }
                    }
                    // DAF - added above
                }
            }
        }
        
        //Added By Abhinav Sharma on 03-05-2014 - CR-20140204-4441 - Restriction status not being updated properly as part of nightly batch job
        //Checking for the event type
        if(Trigger.isBefore) {
            
            //Checking for the request type
            if(Trigger.isDelete) {
                
                //Calling Helper class method
                AccountTriggerHelper.deleteAllRestrictionMtMRecords(Trigger.old);
                
                //V1.10 - Added by Rajeev Jain - 06/14/2016 - Royall Migration - Royall SFDC Schema Release - Manual Merge
                if (!system.isFuture() && !system.isScheduled() && !system.isBatch() && Shift_ChangeDelete_Callout.calloutSettings.Enable_Account_Trigger__c) 
                    Shift_ChangeDelete_Callout.processRecords((List<SObject>)trigger.old, 'delete', 'Account'); 
            }
            
            //V1.10 - Rajeev Jain - 06/24/2016 - Royall Migration - Royall SFDC Schema Release - Merging of Account Object Trigger(shift_update_acc_years_status) from Royall Instance
            if(Trigger.isUpdate)
                AccountTriggerHelper.updateRoyallAccountYearStatus(Trigger.New, Trigger.NewMap);    
            
            
            
        }
        
        
        //Added By - Abhinav Sharma - 07/03/2014 - CR-20140618-5845
        //Checking for the event type
        if(Trigger.isAfter) {
            
            //Checking for the request type
            if(Trigger.isUpdate) {
                
                //Calling helper class method to update the "Member Type" field value on case records with respect to parent account "Key Notes" (Description) field value
                AccountTriggerHelper.updateChildrenCasesMemberTypeFieldValue(Trigger.new, Trigger.oldMap);
                
        //V_1.16 - Merged By - Rajeev Jain - 07/05/2017 -
                //Added by - Mahendra Swarnkar - 05/04/2017 - CR-20170221-10707 
                //Calling helper class method to update the "Associate Principle" field value on Opportunity records with respect to parent account "Associate Principle.Name" value
                AccountTriggerHelper.populateAssociatePrincipalOnopportunityFromAccount(Trigger.new, Trigger.oldMap);
                //V_1.16 - Merged By - Rajeev Jain - 07/05/2017 - upto here 
                
                //V_1.17 - Added by DIPESH Kumar Calling method of Account Trigger helper.
                AccountTriggerHelper.populateProjectFieldsFromAccount(Trigger.new, Trigger.oldMap);
            }
            
            //Commented By Abhinav Sharma - 8/13/2020 -  CR-20180808-12492
            //Added By - Mahendra Swarnkar - CR-20160802-10078 - 09/05/2016
           /* if(Trigger.isInsert || Trigger.isUpdate)
                AccountTriggerHelper.populateSolutionFlagFieldOnAccount(Trigger.new, Trigger.oldMap);*/
        }
        
        //Return our static variable to false to allow reprocessing if necessary
        Util.IsTrigger_AccountNameEAMemberships = false;
        
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
    // Return our static variable to false to allow reprocessing if necessary
    Util.IsTrigger_AccountNameEAMemberships = false;
}