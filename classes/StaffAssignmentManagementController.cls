/*
Purpose         :   This controller is used to Add/Edit/Delete Staff Assignment Functionality & 
                    Assign Selected Staff Assignments to selected EAB Events.
Created By      :   Saurabh Kumar
Created Date    :   10/07/2020
Current Version :   V_2.0
Revision Log    :   V_1.0 Created - Saurabh Kumar - 10/07/2020 - CR-20200821-14455
                    V_2.0 Modified By Saurabh Kumar - 11/17/2020 - CR-20200821-14455 - To By Pass All Trigger While Staff Assignment Created From Component.
*/
public without sharing class StaffAssignmentManagementController 
{   
     /* 
    *   Description     :   This method is used to fetch All Assigned Role to draw in dropdown markup (Add / Edit Staff Screen).
    *
    *   @argument       :   
    *   
    *   return type     :   LightningResponseEntity
    * 
    *   Revision Logs   :   V_1.0 - Created
    */
    @AuraEnabled(cacheable=true)
    public static LightningResponseEntity fetchAllAssignedRoleRecords() 
    {
        LightningResponseEntity res = new LightningResponseEntity();
        try
        {
            //To hold all Assigned Role records
            List<Team_Role__c> teamRoles = StaffAssignmentManagerQueryBuilder.getAllAssignedRoleRecords();
            if(teamRoles.size() > 0)
            {
                res.setBody(teamRoles);
                res.setSuccess(true);  
            }
            else
            {
                //Throw error in case of no Role
                res.setMessage(System.Label.No_Role_To_Display);
                res.setSuccess(true);
            }
            return res;
        }
        catch (Exception ex) 
        {
            //Throw error
            res.setError(ex.getMessage());
            return res;
        }
    }
    /* 
    *   Description     :   This method is used to fetch EAB Event records based on Keyword.
    *
    *   @argument       :   String, String
    *   
    *   return type     :   LightningResponseEntity
    * 
    *   Revision Logs   :   V_1.0 - Created
    */
    @AuraEnabled(cacheable=true)
    public static LightningResponseEntity fetchAllEABEventRecords(String eabEventId, String searchText)
    {
        LightningResponseEntity res = new LightningResponseEntity();
        try
        {
            if(String.isNotBlank(eabEventId))
            {
                List<Advisory_Event__c> allEABEvents = new List<Advisory_Event__c>();
                
                if(String.isNotBlank(searchText))
                {
                    //To hold EAB Event records with searching based on Keyword
                    allEABEvents = StaffAssignmentManagerQueryBuilder.getAllEABEventRecords(eabEventId, searchText);
                }
                else
                {   
                    //To hold EAB Event records without searching
                    allEABEvents = StaffAssignmentManagerQueryBuilder.getAllEABEventRecords(eabEventId);
                }
                
                if(allEABEvents.size() > 0)
                {
                    List<EABEventWrapper> eabEventWrappers = new List<EABEventWrapper>();
                    for(Advisory_Event__c eabEvent : allEABEvents)
                    {
                        //Wrapper to hold all EAB Event details
                        EABEventWrapper eEventWrapper = new  EABEventWrapper(
                            eabEvent.Id, eabEvent.Public_Name__c, eabEvent.Event_Type__c,
                            eabEvent.Primary_Program__r.Name, String.valueOf(eabEvent.Begins__c),
                            String.valueOf(eabEvent.Ends__c));
                        
                        eabEventWrappers.add(eEventWrapper);
                    }
                    res.setBody(eabEventWrappers);
                    res.setSuccess(true);  
                }
                else
                {
                    //Throw error in case of no EAB Event records
                    res.setMessage(System.Label.No_EAB_Event_To_Display);
                    res.setSuccess(true);
                }
            }
            else
            {
                //Throw error in case of Insufficient Access To RecordId
                res.setError(Label.Insufficient_Access_To_RecordId); 
            }
            return res;
        }
        catch (Exception ex) 
        {
            //Throw error 
            res.setError(ex.getMessage());
            return res;
        }
    }
   
    /* 
    *   Description     :   This method is used to fetch Staff Assignment records for selected EAB Event (Detail Page).
    *
    *   @argument       :   String
    *   
    *   return type     :   LightningResponseEntity
    * 
    *   Revision Logs   :   V_1.0 - Created
    */
    @AuraEnabled(cacheable=true)
    public static LightningResponseEntity fetchStaffAssignmentRecords(String eabEventId) 
    {
        LightningResponseEntity res = new LightningResponseEntity();
        try
        {
            if(String.isNotBlank(eabEventId))
            {
                //To hold Staff Assignment records for selected EAB Event (Detail Page).
                List<Team_Membership__c> staffAssignments = StaffAssignmentManagerQueryBuilder.getStaffAssignmentRecords(eabEventId);
                if(staffAssignments.size() > 0)
                {
                    res.setBody(staffAssignments);
                    res.setSuccess(true);  
                }
                else
                {
                    //Throw error in case of no Staff Assignment records
                    res.setMessage(System.Label.No_Staff_Assignment_To_Display);
                    res.setSuccess(true);
                    return res;
                }
            }
            else
            {
                //Throw error in case of Insufficient Access To RecordId
                res.setError(Label.Insufficient_Access_To_RecordId); 
                return res;
            }
            return res;
        }
        catch (Exception ex) 
        {
            //Throw error
            res.setError(ex.getMessage());
            return res;
        }
    }
    
    /* 
    *   Description     :   This method is used to fetch selected Staff Assignment records.
    *
    *   @argument       :   String, String
    *   
    *   return type     :   LightningResponseEntity
    * 
    *   Revision Logs   :   V_1.0 - Created
    */
    @AuraEnabled(cacheable=true)
    public static LightningResponseEntity fetchSelectedStaffAssignmentRecords(String eabEventId, String selectedStaffAssignmentIds) 
    {  
        LightningResponseEntity res = new LightningResponseEntity();
        try
        {
            if(String.isNotBlank(eabEventId))
            {
                List<Team_Membership__c> staffAssignments = new List<Team_Membership__c>();
                if(String.isBlank(selectedStaffAssignmentIds))
                {
                    //To hold Staff Assignment records for selected EAB Event (Detail Page).
                    staffAssignments = StaffAssignmentManagerQueryBuilder.getStaffAssignmentRecords(eabEventId);
                }
                else
                {
                    List<Id> sAIds = selectedStaffAssignmentIds.split('-');
                    //To hold selected Staff Assignment records.
                    staffAssignments = StaffAssignmentManagerQueryBuilder.getStaffAssignmentRecords(sAIds);
                }
                
                if(staffAssignments.size() > 0)
                {
                    res.setBody(staffAssignments);
                    res.setSuccess(true);  
                }
                else
                {
                    //Throw error in case of no Staff Assignment records
                    res.setMessage(System.Label.No_Staff_Assignment_To_Display);
                    res.setSuccess(true);
                    return res;
                }
            }
            else
            {
                //Throw error in case of Insufficient Access To RecordId
                res.setError(Label.Insufficient_Access_To_RecordId); 
                return res;
            }
            return res;
        }
        catch (Exception ex) 
        {
            //Throw error
            res.setError(ex.getMessage());
            return res;
        }
    }
    
    /* 
    *   Description     :   This method is used to save staff assignment details.
    *
    *   @argument       :   Id, String, List<Id>
    *   
    *   return type     :   LightningResponseEntity
    * 
    *   Revision Logs   :   V_1.0 - Created
    */
    @AuraEnabled
    public static LightningResponseEntity saveStaffAssignmentRecords(Id eabEventId, String staffAssignmentJson, List<Id> staffAssignmentIdsToDelete) 
    {
      
        LightningResponseEntity res = new LightningResponseEntity();
        Savepoint sp = Database.setSavepoint();
        try
        {
            if(String.isNotBlank(staffAssignmentJson))
            {
                //To convert JSON into StaffAssignmentWrapper to save records
                List<StaffAssignmentWrapper> staffAssignmentWrapper = (List<StaffAssignmentWrapper>) 
                    JSON.deserializeStrict(staffAssignmentJson, List<StaffAssignmentWrapper>.class);
                //To hold Staff Assignment records to Insert / Update
                List<Team_Membership__c> staffAssignmentToSave = new List<Team_Membership__c>();
               
                if(staffAssignmentWrapper.size() > 0)
                { 
                    for(StaffAssignmentWrapper staffAssignmentWrp : staffAssignmentWrapper)
                    {
                        Team_Membership__c staffAssignmentToInsert = new Team_Membership__c();
                        if(staffAssignmentWrp.staffAssignmentRecordId != null)
                        {
                            staffAssignmentToInsert.Id = staffAssignmentWrp.staffAssignmentRecordId;
                        }
                        else
                        {
                            staffAssignmentToInsert.RecordTypeId = Constants.RECORD_TYPE_ID_EAB_EVENT_OF_STAFF_ASSIGNMENT;
                        }
                        if(eabEventId != null)
                        {
                            staffAssignmentToInsert.EAB_Event__c = eabEventId;
                        }
                        
                        if(staffAssignmentWrp.staffAssignmentName != null)
                        {
                            staffAssignmentToInsert.Name = staffAssignmentWrp.staffAssignmentName; 
                        }
                        else
                        {
                            staffAssignmentToInsert.Name = Constants.TEST_TEXT;
                        }
                       
                        if(staffAssignmentWrp.staffMemberId != null)
                        {
                            staffAssignmentToInsert.Staff_member__c = staffAssignmentWrp.staffMemberId;
                        }
                        if(staffAssignmentWrp.assignedRoleId != null)
                        {
                            staffAssignmentToInsert.Role__c = staffAssignmentWrp.assignedRoleId;
                        }
                        staffAssignmentToSave.add(staffAssignmentToInsert);
                    }
                  
                    if(staffAssignmentToSave.size() > 0)
                    {
                        //01/05/2021 - Victor Hanson - commented out the bypasses below,
                        //because when triggers bypassed, name isn't auto-generated and registration isn't created
                        //To By Pass All Trigger While Staff Assignment Created From Component.
                        //Util.BypassAllTriggers = true;
                        //Util.byPassFromCustomComponent = true;
                        //Upsert Dml
                        upsert staffAssignmentToSave;
                        Util.BypassAllTriggers = false;
                        Util.byPassFromCustomComponent = false;
                        res.setBody(staffAssignmentToSave);
                        res.setSuccess(true); 
                    }
                }
            }
            if(staffAssignmentIdsToDelete.size() > 0)
            {
                //To delete selected Staff Assignment records
                delete [SELECT ID FROM Team_Membership__c WHERE ID IN :staffAssignmentIdsToDelete AND EAB_Event__c =: eabEventId];
            }
            if(String.isBlank(staffAssignmentJson) && staffAssignmentIdsToDelete.size() == 0)
            {
                Database.RollBack(sp);
                
                //Throw error in case of no Staff Assignment to Create / Update / Delete
                res.setMessage(Label.No_Staff_Assignment_To_Create_Update_Delete);
                res.setSuccess(true);
            }
            return res;
        }
        catch(Exception ex)
        {
            Database.RollBack(sp);
            
            //Throw error 
            res.setError(ex.getMessage());
            return res;
        }
    }
   
    /* 
    *   Description     :   This method is used to associate selected Staff Assignments to selected EAB Events.
    *
    *   @argument       :   List<Id>, List<Id>
    *   
    *   return type     :   LightningResponseEntity
    * 
    *   Revision Logs   :   V_1.0 - Created
    */
    @AuraEnabled
    public static LightningResponseEntity assignStaffToEvents(List<Id> eabEventIds, List<Id> staffAssignmentIds) 
    {
        LightningResponseEntity res = new LightningResponseEntity();
        Savepoint sp = Database.setSavepoint();
        try
        {
            if(eabEventIds.size() > 0 && staffAssignmentIds.size() > 0)
            {
                //To hold selected EAB Event records.
                List<Advisory_Event__c> eabEvents = StaffAssignmentManagerQueryBuilder.getAllEABEventRecords(eabEventIds);
                //To hold selected Staff Assignment records.
                List<Team_Membership__c> staffAssignments = StaffAssignmentManagerQueryBuilder.getStaffAssignmentRecords(staffAssignmentIds);
                
                if(eabEvents.size() > 0 && staffAssignments.size() > 0)
                { 
                    List<Team_Membership__c> staffAssignmentsToInsert = new List<Team_Membership__c>();
                    for(Advisory_Event__c eabEvent : eabEvents)
                    {
                        for(Team_Membership__c staffAssignment : staffAssignments)
                        {
                            Team_Membership__c staffAssignmentCopy = staffAssignment.clone(false);
                            staffAssignmentCopy.EAB_Event__c = eabEvent.Id;
                            staffAssignmentsToInsert.add(staffAssignmentCopy);
                        }
                    }
                    if(staffAssignmentsToInsert.size() > 0)
                    {
                        //01/11/2021 - Victor Hanson - Commented out the bypass because it prevents records from being created properly
                        //To By Pass All Trigger While Staff Assignment Created From Component.
                        //Util.BypassAllTriggers = true;
                        //Util.byPassFromCustomComponent = true;
                        //Insert Dml
                        insert staffAssignmentsToInsert;
                        Util.BypassAllTriggers = false;
                        Util.byPassFromCustomComponent = false;
                        res.setBody(staffAssignmentsToInsert);
                        res.setSuccess(true); 
                    }
                }
            }
            return res;
        }
        catch(Exception ex)
        {
            Database.RollBack(sp);
            
            //Throw error
            res.setError(ex.getMessage());
            return res;
        }
    }
    
    //Wrapper to hold EAB Event records
    public class EABEventWrapper
    {
        @auraEnabled public String eabRecordId;
        @auraEnabled public String publicName;
        @auraEnabled public String eventType;
        @auraEnabled public String primaryProgram;
        @auraEnabled public String begins;
        @auraEnabled public String ends;
      
        public EABEventWrapper(String eabRecordId,String publicName, String eventType, 
                               String primaryProgram, String begins, String ends)
        {
            this.eabRecordId = eabRecordId;
            this.publicName = publicName;
            this.eventType = eventType;
            this.primaryProgram = primaryProgram;
            this.begins = begins;
            this.ends = ends;
        }
    }
     //Wrapper to hold new / existing / deleted Staff Assignment records
    public class StaffAssignmentWrapper
    {
        @auraEnabled public String staffAssignmentRecordId;
        @auraEnabled public String staffAssignmentName;
        @auraEnabled public String staffMemberId;
        @auraEnabled public String staffMemberName;
        @auraEnabled public String assignedRoleId;
        @auraEnabled public String assignedRoleName;
      
        public StaffAssignmentWrapper(String staffAssignmentRecordId, String staffAssignmentName,
                                      String staffMemberId, String staffMemberName, String assignedRoleId, 
                                      String assignedRoleName)
        {
            this.staffAssignmentRecordId = staffAssignmentRecordId;
            this.staffAssignmentName = staffAssignmentName;
            this.staffMemberId = staffMemberId;
            this.staffMemberName = staffMemberName;
            this.assignedRoleId = assignedRoleId;
            this.assignedRoleName = assignedRoleName;
        }
    }
}