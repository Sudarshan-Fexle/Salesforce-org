/*
Purpose         :   StaffAssignmentManagerQueryBuilder
Created By      :   Saurabh Kumar
Created Date    :   10/07/2020
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Saurabh Kumar - 10/07/2020 - CR-20200821-14455
*/
public class StaffAssignmentManagerQueryBuilder 
{
    /* 
    *	Description     :	This method is used to fetch All Assigned Role to draw in dropdown markup..
    *
    *	@argument	:	 
    *   
    *   return type     :   List<Team_Role__c>
    * 
    *	Revision Logs   : 	V_1.0 - Created
    */
    public static List<Team_Role__c> getAllAssignedRoleRecords()
    {
        return [Select Id, Name from Team_role__c WHERE EAB_Event__c = true AND Active__c = true
                ORDER BY Name ASC];
    }
    
    /* 
    *	Description     :	This method is used to fetch all EAB Event records excluding Current EAB Event record.
    *
    *	@argument	:	String 
    *   
    *   return type     :   List<Advisory_Event__c>
    * 
    *	Revision Logs   : 	V_1.0 - Created
    */
    public static List<Advisory_Event__c> getAllEABEventRecords(String eabEventId)
    {
        return [SELECT ID, Name, Public_Name__c, 
                Event_Type__c, Primary_Program__r.Name, 
                Begins__c, Ends__c, Status__c
                FROM Advisory_Event__c 
                WHERE ID !=: eabEventId 
                AND Status__c !=: Constants.STATUS_CLOSED_COMPLETED 
                AND Status__c !=: Constants.STATUS_CLOSED_CANCELLED
                AND Begins__c > TODAY LIMIT 20];
    }
    
    /* 
    *	Description     :	This method is used to fetch selected EAB Event records.
    *
    *	@argument	:	List<Id> 
    *   
    *   return type     :   List<Advisory_Event__c>
    * 
    *	Revision Logs   : 	V_1.0 - Created
    */
    public static List<Advisory_Event__c> getAllEABEventRecords(List<Id> eabEventIds)
    {
        return [SELECT ID, Name, Public_Name__c, 
                Event_Type__c, Primary_Program__r.Name, 
                Begins__c, Ends__c, Status__c
                FROM Advisory_Event__c 
                WHERE ID IN :eabEventIds];
    }
    
    /* 
    *	Description     :	This method is used to fetch EAB Event records based on Keyword.
    *
    *	@argument	:	String, String
    *   
    *   return type     :   List<Advisory_Event__c>
    * 
    *	Revision Logs   : 	V_1.0 - Created
    */
    public static List<Advisory_Event__c> getAllEABEventRecords(String eabEventId, String searchText)
    {
        searchText = '%' + searchText + '%';
        return [SELECT ID, Name, Public_Name__c, 
                Event_Type__c, Primary_Program__r.Name, 
                Begins__c, Ends__c 
                FROM Advisory_Event__c
                WHERE ID !=: eabEventId AND Name LIKE :searchText
                AND Status__c !=: Constants.STATUS_CLOSED_COMPLETED 
                AND Status__c !=: Constants.STATUS_CLOSED_CANCELLED
                AND Begins__c > TODAY LIMIT 20];
    }
    
    /* 
    *	Description     :	This method is used to fetch Staff Assignment records for selected EAB Event (Detail Page).
    *
    *	@argument	:	String
    *   
    *   return type     :   List<Team_Membership__c>
    * 
    *	Revision Logs   : 	V_1.0 - Created
    */
    public static List<Team_Membership__c> getStaffAssignmentRecords(String eabEventId)
    {
       return [SELECT ID, Name, Institution__c, 
                Institution__r.Name,Role__c, 
                Role__r.Name, Staff_member__c, 
                Staff_member__r.Name
                FROM Team_Membership__c 
                WHERE EAB_Event__c =: eabEventId
                AND Role__r.EAB_Event__c = true
                AND RecordType.DeveloperName = 'EAB_Event'
              ];
    }
    
    /* 
    *	Description     :	This method is used to fetch selected Staff Assignment records.
    *
    *	@argument	:	List<Id>
    *   
    *   return type     :   List<Team_Membership__c>
    * 
    *	Revision Logs   : 	V_1.0 - Created
    */
    public static List<Team_Membership__c> getStaffAssignmentRecords(List<Id> selectedStaffAssignmentIds)
    {
       return [SELECT ID, Name, Institution__c, 
                Institution__r.Name,Role__c, 
                Role__r.Name, Staff_member__c, 
                Staff_member__r.Name, RecordTypeId
                FROM Team_Membership__c 
                WHERE ID IN :selectedStaffAssignmentIds
              ];
    }
}