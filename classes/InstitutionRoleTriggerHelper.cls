/**
 *  Purpose         :   This class is helper class for trigger on Institution Role object.
 *              
 *  Create By       :   Simplyforce Technology
 *  
 *  Created Date    :   11/08/2012
 *  
 *  Revision Log    :   V_1.0 Created
 *		    		:   V_1.1 - Modified By - Bhavi Sharma - 02/04/2014 - New methods added (UpdateInteractionInformation, UpdateInteractionInformationByContactIds) - CR-20140124-4353
 *		    		:   V_1.2 - Modified By - Ayush Gupta - CR-20210930-15473
**/
public without sharing class InstitutionRoleTriggerHelper {
    //Modified By - Ayush Gupta - CR-20210930-15473
    //Flag to contol the trigger execution for UpdateSupportProduct Process
    public static Boolean BYPASS_TRIGGER_CASE_UPDATE_SUPPORT_PRODUCT = false;
    
    //This method is to update the Contact's Role Tags
    /*public static void PopulateContactData(Map<Id, Institution_Roles__c> newInstitutionRoles, Map<Id, Institution_Roles__c> oldInstitutionRoles) {
        
        //creata a set to hold the appropriate Institution Roles
        Set<Id> institutionRolesIds = new Set<Id>();
        
        //Create a list of the contact records, This will be used in update scenerio where all institution records have been update with new contact
        List<Institution_Roles__c> oldInsRoles = new List<Institution_Roles__c>(); 
        
        //Loop through the records
        for(Institution_Roles__c iRole : newInstitutionRoles.values()) {
            
            //Check if this is insert case or update and add the record for processing
            if(oldInstitutionRoles == null || (iRole.Contact__c != oldInstitutionRoles.get(iRole.Id).Contact__c)) {
                
                //Add record id in set
                if(iRole.Contact__c != null)
                    institutionRolesIds.add(iRole.Id);
                    
                //check if teh case is for update and Contact has been changed
                if(oldInstitutionRoles != null && iRole.Contact__c != oldInstitutionRoles.get(iRole.Id).Contact__c)
                    oldInsRoles.add(oldInstitutionRoles.get(iRole.Id));
            }
        }
        
        //Cleanup Old Roles if any
        if(oldInsRoles.size() > 0) 
            InstitutionRoleTriggerHelper.UpdateContactRoleTagForDelete(oldInsRoles);
        
        //Check for the institutionRolesIds size
        if(institutionRolesIds.size() > 0) {
            
            //Create a map to hold the contact records to be updated
            Map<Id, Contact> mapContact = new Map<Id, Contact>();
            
            //fetch the Institution role data with all other required information
            for(Institution_Roles__c insRole : [Select Id, Role__c, Contact__c, Contact__r.Role_Tags__c from Institution_Roles__c where Contact__c != null 
                                                    AND Role__c != null AND Role__c != '' AND Id IN: institutionRolesIds AND Contact__c != null]) {
                
                //Contact cloneContact
                Contact cloneContact;
                
                //Check for the contact and update contact's data
                if(mapContact.containsKey(insRole.Contact__c)) {
                    
                    //Get the contact record from map
                    cloneContact = mapContact.get(insRole.Contact__c);
                } else {
                    
                    //Create a contact clone
                    cloneContact = new Contact(Id = insRole.Contact__c, Role_Tags__c = insRole.Contact__r.Role_Tags__c);
                }
                
                if(cloneContact.Role_Tags__c != null && cloneContact.Role_Tags__c != '' 
                        && (!cloneContact.Role_Tags__c.contains(insRole.Role__c))) {
                        
                    //Set program acronym in cloneContact
                    cloneContact.Role_Tags__c += ', ' + insRole.Role__c;
                } else {
                        
                    //Set program acronym in cloneContact
                    cloneContact.Role_Tags__c = insRole.Role__c;
                }
                
                //Put the contact record in map
                mapContact.put(insRole.Contact__c, cloneContact);
            }
            
            //Check if there are records to update
            if(mapContact.size() > 0)
                update mapContact.values();
        }
    }*/
    
    //This method is to update the Contact's Role Tags on Delete
    /*public static void UpdateContactRoleTagForDelete(List<Institution_Roles__c> institutionRoles) {
        
        //creata a set to hold the appropriate Institution Roles
        Set<Id> contactIds = new Set<Id>();
        
        //Loop through the records
        for(Institution_Roles__c iRole : institutionRoles) {
            
            //Add record id in set
            if(iRole.Contact__c != null)
                contactIds.add(iRole.Contact__c);
        }
        
        //Check for the institutionRolesIds size
        if(contactIds.size() > 0) {
            
            //Create a map to hold the contact records to be updated
            Map<Id, Contact> mapContact = new Map<Id, Contact>();
            
            //Fetch contact data
            Map<Id, Contact> mapExistingContacts = new Map<Id, Contact>([Select Id, Role_Tags__c from Contact where Id IN: contactIds]);
            
            //fetch the Institution role data with all other required information
            for(Institution_Roles__c insRole : institutionRoles) {
                
                //Contact cloneContact
                Contact cloneContact;
                
                //Check for the contact and update contact's data
                if(mapContact.containsKey(insRole.Contact__c)) {
                    
                    //Get the contact record from map
                    cloneContact = mapContact.get(insRole.Contact__c);
                } else {
                    
                    //Create a contact clone
                    cloneContact = mapExistingContacts.get(insRole.Contact__c);
                }
                
                if(cloneContact.Role_Tags__c != null && cloneContact.Role_Tags__c != '' 
                        && cloneContact.Role_Tags__c.contains(insRole.Role__c)) {
                        
                    //Set program acronym in cloneContact
                    cloneContact.Role_Tags__c = cloneContact.Role_Tags__c.replace(', ' + insRole.Role__c, '').replace(insRole.Role__c, '');
                }
                
                //Put the contact record in map
                mapContact.put(insRole.Contact__c, cloneContact);
            }
            
            //Check if there are records to update
            if(mapContact.size() > 0)
                update mapContact.values();
        }
    }*/
    
    /**
     *  @description    :   This method is to update the Interaction Information on Institution Role record
     * 
     *  @args           :   List of new institution record, Map of old institution record
     *  
     *  @return         :   void
     * 
     **/ 
    /*public static void UpdateInteractionInformation(List<Institution_Roles__c> institutionRoles, Map<Id, Institution_Roles__c> mapOldInstitutionRoles) {
        
        //Set to hold the contact Ids
        Set<Id> contactIds = new Set<Id>();
        
        //Loop through the records and check if record needs to be updated
        for(Institution_Roles__c iR : institutionRoles) {
            
            //Check id the record is new or contact Id has been changed
            if(mapOldInstitutionRoles == null || iR.Contact__c != mapOldInstitutionRoles.get(iR.Id).Contact__c) {
                
                //Add in Set
                contactIds.add(iR.Contact__c);
            }
        }
        
        //Check if records need to be updated
        if(contactIds.size() > 0)
            InstitutionRoleTriggerHelper.UpdateInteractionInformationByContactIds(institutionRoles, contactIds, false);
    }*/
    
    /**
     *  @description    :   This method is to take the contact Ids and Update the Interaction information on Institution Roles 
     * 
     *  @args           :   Set of contacts Ids
     * 
     *  @return         :   void
     * 
     **/ 
    /*public static void UpdateInteractionInformationByContactIds(List<Institution_Roles__c> inContextInstitutionRoles, Set<Id> contactIds, Boolean executeDML) {
        
        //Chekc for the before insert and update
        if(inContextInstitutionRoles == null) {
        
            //Query all the Institution Roles related to these contacts
            inContextInstitutionRoles = [Select Id, Institution__c, Contact__c from Institution_Roles__c where Contact__c != null AND Contact__c IN: contactIds];
        }
        
        //Process Roles
        if(inContextInstitutionRoles.size() == 0)
            return;
            
        //Loop through the inContextInstitutionRoles and create a set to institution
        Set<Id> accIds = new Set<Id>();
        for(Institution_Roles__c iR : inContextInstitutionRoles)
            accIds.add(iR.Institution__c);
        
        //return if No accounts
        if(accIds.size() == 0)
            return;
            
        //Create a set to hold the Opportunties Ids
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity opp : [Select Id from Opportunity where AccountId IN: accIds])
            oppIds.add(opp.Id);
        
        //Create a Map to hold the Max Date and Type for each contact
        Map<Id, InteractionWrapper> mapLastInteractionWrapper = new Map<Id, InteractionWrapper>();
        Map<Id, InteractionWrapper> mapNextInteractionWrapper = new Map<Id, InteractionWrapper>();
        
        //Query Activities
        List<Event> events = [Select ActivityDate, Event_Type__c, WhoId, WhatId from Event 
                                                    where WhoId != null AND WhoId IN: contactIds AND WhatId != null AND WhatId IN: oppIds
                                                        AND ActivityDate != null AND Cancelled_Did_Not_Occur__c = false AND
                                                        ((
                                                            (
                                                                RecordType.DeveloperName =: Constants.RECORD_TYPE_EVENT_DEVELOPER_NAME_PT_AM OR 
                                                                RecordType.DeveloperName =: Constants.RECORD_TYPE_EVENT_DEVELOPER_NAME_RI_AM OR 
                                                                RecordType.DeveloperName =: Constants.RECORD_TYPE_EVENT_DEVELOPER_NAME_TD_AM)
                                                                AND 
                                                                Event_Type__c =: Constants.EVENT_TYPE_IN_PERSON_VISIT
                                                             )
                                                            OR
                                                            ((
                                                                RecordType.DeveloperName =: Constants.RECORD_TYPE_EVENT_DEVELOPER_NAME_PT_MARKETING OR 
                                                                RecordType.DeveloperName =: Constants.RECORD_TYPE_EVENT_DEVELOPER_NAME_RI_MARKETING)
                                                                AND 
                                                                (
                                                                    Event_Type__c =: Constants.EVENT_TYPE_IN_PERSON_VISIT OR 
                                                                    Event_Type__c =: Constants.EVENT_TYPE_ADDITIONAL_CONTACT_MEETING OR 
                                                                    Event_Type__c =: Constants.EVENT_TYPE_PROSPECT_MEETING_ATTENDEE_COUNT_AS_VISIT
                                                                )
                                                            )) 
                                                            Order By ActivityDate ASC];
                                                            
        //Loop thriugh the events
        for(Event event : events) {
        
            //InteractionWrapper
            InteractionWrapper iW = new InteractionWrapper(event.ActivityDate, event.Event_Type__c, event.Id, 'Event');
            
            //Last Interaction
            if(event.ActivityDate <= Date.today()) {
                
                //Add in map
                mapLastInteractionWrapper.put(event.WhoId, iW);
            } else {
                
                //If Wrapper already added
                if(!mapNextInteractionWrapper.containsKey(event.WhoId))
                    mapNextInteractionWrapper.put(event.WhoId, iW);
            }
        }
        
        //Query Delivery member interactions
        for(Call__c call : [Select Id, Contact__c, Interaction_Type__c, Call_Date__c from Call__c where Contact__c != null AND Institution__c != null
                                                                                            AND Call_Date__c != null AND Contact__c IN: contactIds]) {
            
            //InteractionWrapper
            InteractionWrapper iW = new InteractionWrapper(call.Call_Date__c, call.Interaction_Type__c, call.Id, 'Member Interaction');
            
            //Last Interaction Call
            if(call.Call_Date__c <= Date.today()) {
                
                //Check if already in Last Interaction Map
                if(mapLastInteractionWrapper.containsKey(call.Contact__c)) {
                    
                    //Last Interaction
                    InteractionWrapper lastIWrapper = mapLastInteractionWrapper.get(call.Contact__c);
                    
                    //Check for the most recent date and put the most recent wrapper in list
                    if(iW.interactionDate > lastIWrapper.interactionDate)
                        mapLastInteractionWrapper.put(call.Contact__c, iW);
                } else {
                    
                    //Add by default
                    mapLastInteractionWrapper.put(call.Contact__c, iW);
                }
            } else {
                
                //Check if already in Last Interaction Map
                if(mapNextInteractionWrapper.containsKey(call.Contact__c)) {
                    
                    //Last Interaction
                    InteractionWrapper nextIWrapper = mapNextInteractionWrapper.get(call.Contact__c);
                    
                    //Check for the most recent date and put the most recent wrapper in list
                    if(iW.interactionDate < nextIWrapper.interactionDate)
                        mapNextInteractionWrapper.put(call.Contact__c, iW);
                } else {
                    
                    //Add by default
                    mapNextInteractionWrapper.put(call.Contact__c, iW);
                }   
            }
        }
        
        //Query Meeting Utilization
        for(Meeting_Utilization__c mU : [Select Id, Contact__c, Start_Date__c from Meeting_Utilization__c where Contact__c != null AND Institution__c != null
                                                                                            AND Start_Date__c != null AND Contact__c IN: contactIds]) {
            
            //InteractionWrapper
            InteractionWrapper iW = new InteractionWrapper(mU.Start_Date__c, 'Meeting Utilization', mu.Id, 'Meeting Utilization');
            
            //Last Interaction Call
            if(mU.Start_Date__c <= Date.today()) {
                
                //Check if already in Last Interaction Map
                if(mapLastInteractionWrapper.containsKey(mU.Contact__c)) {
                    
                    //Last Interaction
                    InteractionWrapper lastIWrapper = mapLastInteractionWrapper.get(mU.Contact__c);
                    
                    //Check for the most recent date and put the most recent wrapper in list
                    if(iW.interactionDate > lastIWrapper.interactionDate)
                        mapLastInteractionWrapper.put(mU.Contact__c, iW);
                } else {
                    
                    //Add by default
                    mapLastInteractionWrapper.put(mU.Contact__c, iW);
                }
            } else {
                
                //Check if already in Last Interaction Map
                if(mapNextInteractionWrapper.containsKey(mU.Contact__c)) {
                    
                    //Last Interaction
                    InteractionWrapper nextIWrapper = mapNextInteractionWrapper.get(mU.Contact__c);
                    
                    //Check for the most recent date and put the most recent wrapper in list
                    if(iW.interactionDate < nextIWrapper.interactionDate)
                        mapNextInteractionWrapper.put(mU.Contact__c, iW);
                } else {
                    
                    //Add by default
                    mapNextInteractionWrapper.put(mU.Contact__c, iW);
                }   
            }
        }
        
        //Create a list of teh institution Roles to be updated
        List<Institution_Roles__c> institutionRoles = new List<Institution_Roles__c>();
        
        //Loop through the original contacts
        for(Institution_Roles__c iR : inContextInstitutionRoles) {
            
            //Get wrapper record from Interaction Map
            if(mapLastInteractionWrapper.containsKey(iR.Contact__c)) {
                
                //Last Interaction Populate 
                iR.Last_Interaction_Date__c = mapLastInteractionWrapper.get(iR.Contact__c).interactionDate;
                iR.Last_Interaction_Type__c = mapLastInteractionWrapper.get(iR.Contact__c).interactionType;
            }
            
            //Get wrapper record from Interaction Map
            if(mapNextInteractionWrapper.containsKey(iR.Contact__c)) {
                
                //Last Interaction Populate 
                iR.Next_Interaction_Date__c = mapNextInteractionWrapper.get(iR.Contact__c).interactionDate;
                iR.Next_Interaction_Type__c = mapNextInteractionWrapper.get(iR.Contact__c).interactionType;
            }
            
            //Add institution role in the list to be updated
            institutionRoles.add(iR);
        }
        
        //Execute DMl if required
        if(executeDML && institutionRoles.size() > 0)
            update institutionRoles;
    }
    
    //Wrapper class for Interaction
    public class InteractionWrapper {
        
        public Date interactionDate;
        public String interactionType;
        public Id interactionId;
        public String interactionObject;
        
        //Constructor
        public InteractionWrapper(Date interactionDate, String interactionType, String interactionId, String interactionObject) {
            
            //Properties
            this.interactionDate = interactionDate;
            this.interactionType = interactionType;
            this.interactionId = interactionId;
            this.interactionObject = interactionObject;
        }
    }*/

   /**
     *  @description    :   This Method is used to update the contact.Key Contact, if that contact is stamped on any Institution role 
     *
     *  @args           :   List of new Institution Role records, Map of old Institution Role
     *
     *  @return         :   void
     *
     **/
    public Static void updateContactBasedOnInstitutionRole(List<Institution_Roles__c> newInstitutionRoles, Map<Id, Institution_Roles__c> oldMapInstitutionRoles) {
        
        //Set to hold the Contact Ids.
        Set<Id> setContactIds = new Set<Id>();
        
        //For Loop on Institution Roles.
        for(Institution_Roles__c iRole : newInstitutionRoles != null ? newInstitutionRoles : oldMapInstitutionRoles.values()) {
            
            //Check for the new and old map. 
            if(oldMapInstitutionRoles == null || (oldMapInstitutionRoles.get(iRole.Id).Contact__c != iRole.Contact__c 
                                                  || newInstitutionRoles == null ) ) {
                    
                //Add Contact Id in the set.
                setContactIds.add(iRole.Contact__c );
                                                      
                //Check for the Contact change.
                if(oldMapInstitutionRoles != null && oldMapInstitutionRoles.get(iRole.Id).Contact__c != iRole.Contact__c)  
                    setContactIds.add(oldMapInstitutionRoles.get(iRole.Id).Contact__c );
            }
        }
        
        //Check for the set size.
        if(setContactIds.size() > 0) {
            updatedKeyContactOnContact(setContactIds);
        }
    }
    
    //Method to update contact.
    public Static void updatedKeyContactOnContact(Set<Id> setContactIds) {
        
        //List to hold the contact that is going to be updated.
        List<Contact> consToBeUpdated = new List<Contact>();
            
        //Check for the set size.
        if(setContactIds != null && setContactIds.size() > 0) {
            
            //Query on the Contact.
            for(Contact con : [Select Id, Contact_Status__c, Key_Contact__c, (Select Id From Institution_Roles__r) 
                               From Contact Where Id IN: setContactIds]) {
                
                //Boolean for the Key contact.
                Boolean isKeyContact = false;
                                   
                //Check for the list size
                if(con.Institution_Roles__r != null && con.Institution_Roles__r.size() > 0 && con.Contact_Status__c == 'Active')
                    isKeyContact = true;
                
                //Compare between flag and contact Key contact field value.
                if(con.Key_Contact__c != isKeyContact)
                    consToBeUpdated.add(new Contact(Id = con.Id, Key_Contact__c = isKeyContact));
            }
        }
        
        //Check for the list size. 
        if(consToBeUpdated != null && consToBeUpdated.size() > 0) {
            
            //Bypassing Trigger
            Util.BypassAllTriggers = true;
            update consToBeUpdated;
            Util.BypassAllTriggers = false;
        }
    }
    
    /**
     *  @description    :   This Method to check the duplicates if any Institution role is create with the Same Account + Team Role. Throw an error.  
     *
     *  @args           :   List of new Institution Role records, Map of old Institution Role
     *
     *  @return         :   void
     *
     **/
    public static void checkForInstitutionRoleDuplicates(List<Institution_Roles__c> newInstitutionRoles, Map<Id, Institution_Roles__c> oldMapInstitutionRoles) {
        
        //Set to hold the Institution Role Ids.
        Set<Id> setInstitutionRoleIds = new Set<Id>();
        
        //Set to hold the Assignment Role Ids
        Set<Id> setAssignmentRoleIds  = new Set<Id>();
        
        //Set to hold the Institution Ids
        Set<Id> setInstitutionIds = new Set<Id>();
        
        //Set to hold the combination of Team Role and Institution.
        Set<String> setInstitutionAndTeamRoleUniqueKey = new Set<String>();
            
        //For Loop on the Institution Roles
        for(Institution_Roles__c iRole : newInstitutionRoles) {
            
            //Check for the Update or Insert Case. 
            if(String.isNotBlank(iRole.Assignment_Role__c ) && String.isNotBlank(iRole.Institution__c) && 
               (oldMapInstitutionRoles == null || (oldMapInstitutionRoles.get(iRole.Id).Assignment_Role__c  != iRole.Assignment_Role__c  
                ||  oldMapInstitutionRoles.get(iRole.Id).Institution__c != iRole.Institution__c))) {
                
                //String to hold the unique key. 
                String uniqueKey = iRole.Institution__c  + ' - ' + iRole.Assignment_Role__c;
                
                if(!setInstitutionAndTeamRoleUniqueKey.contains(uniqueKey))
                    setInstitutionAndTeamRoleUniqueKey.add(uniqueKey);
                else
                    iRole.addError('The Role you selected already exists for this Institution. Please select another Role.');
               
                //Adding the Instituion Roles to the Set.
                setInstitutionRoleIds.add(iRole.Id);
                setAssignmentRoleIds.add(iRole.Assignment_Role__c);
                setInstitutionIds.add(iRole.Institution__c);
            }
        }
        
        //Checking for the Set Size. 
        if(setInstitutionRoleIds.size() > 0 || (setAssignmentRoleIds.size() > 0 && setInstitutionIds.size() > 0)) {
            
            //Query on the Institution roles size. 
            for(Institution_Roles__c iRole : [Select Id, Assignment_Role__c, Institution__c  From Institution_Roles__c 
                                              Where Assignment_Role__c IN: setAssignmentRoleIds
                                              AND Institution__c IN: setInstitutionIds 
                                              AND ID Not IN: setInstitutionRoleIds]) {
                                                  
                
                //String to hold the unique key. 
                String uniqueKey = iRole.Institution__c  + ' - ' + iRole.Assignment_Role__c;
                
                if(!setInstitutionAndTeamRoleUniqueKey.contains(uniqueKey))
                    setInstitutionAndTeamRoleUniqueKey.add(uniqueKey);
                else 
                    throw new customException('The Role you selected already exists for this Institution. Please select another Role.');
            }
        }
    }
    /**
     *  @description    :   This Method to update the InstitutionRole Name field with the condition of Vacant Role Field   
     *
     *  @args           :   List of new Institution Role records, Map of old Institution Role
     *
     *  @return         :   void
     *
     *  @Revision Log   :   V_1.0 - Modified By - Ayush Gupta - CR-20210930-15473
     *
     **/
    public static void updateInstitutionRoleName(List<Institution_Roles__c> newInstitutionRoles, Map<Id, Institution_Roles__c> oldMapInstitutionRoles) {
        
        //Set to hold the Institution Role Ids.
        Set<Id> setInstitutionRoleTrueIds = new Set<Id>();
        
        //Set to hold the Assignment Role Ids
        Set<Id> setAssignmentRoleIds  = new Set<Id>();
        
        //Set to hold the Institution Ids
        Set<Id> setInstitutionIds = new Set<Id>();
        
        Map<Id,String> mapInstitutionIdWithName = new Map<Id,String>();
        
        Map<Id,String> mapAssignmentIdWithName = new Map<Id,String>();
        
        List<Institution_Roles__c> institutionToBeUpdate = new List<Institution_Roles__c>();
        
        String accountFormalName = '';
        String assignmentRoleName = '';
        
        //For Loop on the Institution Roles
        for(Institution_Roles__c iRole : newInstitutionRoles) {
            
            if((oldMapInstitutionRoles == null || (oldMapInstitutionRoles.get(iRole.Id).Name  != iRole.Name) || (oldMapInstitutionRoles.get(iRole.Id).Contact__c  != iRole.Contact__c)
                || (oldMapInstitutionRoles.get(iRole.Id).Assignment_Role__c  != iRole.Assignment_Role__c) || (oldMapInstitutionRoles.get(iRole.Id).Vacant_Role__c  != iRole.Vacant_Role__c))){
                    
                    setInstitutionRoleTrueIds.add(iRole.Id);
                    setInstitutionIds.add(iRole.Institution__c);
                    setAssignmentRoleIds.add(iRole.Assignment_Role__c); 
                }
        }
        
        for(Account acc : [SELECT Id,Account_Formal_Name__c FROM Account WHERE Id IN :setInstitutionIds]){
            
            mapInstitutionIdWithName.put(acc.Id,acc.Account_Formal_Name__c);
        }
        
        for(Team_Role__c arc : [SELECT Id,Name FROM Team_Role__c WHERE Id IN :setAssignmentRoleIds]){
            
            mapAssignmentIdWithName.put(arc.Id,arc.Name);
        }
        
        if(setInstitutionRoleTrueIds.size() > 0 && oldMapInstitutionRoles != null){
            //For Loop on the Institution Roles
            for(Institution_Roles__c iRole : newInstitutionRoles) {
                
                if((oldMapInstitutionRoles.get(iRole.Id).Vacant_Role__c  != iRole.Vacant_Role__c)){
                    Institution_Roles__c iRol = new Institution_Roles__c();                
                    if(iRole.Vacant_Role__c == true){
                        
                        iRol = new Institution_Roles__c(Id = iRole.Id, Name = mapAssignmentIdWithName.get(iRole.Assignment_Role__c) + '-'+mapInstitutionIdWithName.get(iRole.Institution__c) + '- Vacant');
                   BYPASS_TRIGGER_CASE_UPDATE_SUPPORT_PRODUCT = true;
                   
                    }
                    else if(iRole.Vacant_Role__c == false){
                        
                        if(iRole.Name.Contains('- Vacant')){
                            
                            String insName = mapAssignmentIdWithName.get(iRole.Assignment_Role__c) + '-'+mapInstitutionIdWithName.get(iRole.Institution__c);
                            iRol = new Institution_Roles__c(Id = iRole.Id, Name = insName.split('- Vacant')[0]);
                            BYPASS_TRIGGER_CASE_UPDATE_SUPPORT_PRODUCT = true;
                        }
                    }
                    institutionToBeUpdate.add(iRol);
                }
            }
        }
        if(institutionToBeUpdate.size() > 0){
           
            //Update the institution Role
            update institutionToBeUpdate;
            
            
        }
    }
}