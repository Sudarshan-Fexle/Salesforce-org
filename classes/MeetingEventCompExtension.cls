/**
 *  Description     :  Helper class for the MeetingEventComp aura component
 *
 *  Revision Logs   :  V_1.0 - 09/20/2019 - Victor Hanson - Created
 *		    :  V_1.1 - Modified By - Chirag Soni - CR-20210226-14953 - 11/12/2021 - Modified Method -  getMeetingRegistrations
**/
public without sharing class MeetingEventCompExtension {
	
    //constructor
    public MeetingEventCompExtension() {}
    
    /**
     *  Description     :	get upcoming meeting registrations
     * 
     * 	Return Type	:	List<AggregateResult>
     *
     *	Revision Logs   :	09/20/2019 - Victor Hanson - Created
     *                  :	Modified By - Chirag Soni - CR-20210226-14953 - 11/12/2021 - Added new column Type
    **/
    @AuraEnabled
    public static List<AggregateResult> getMeetingRegistrations(List<Id> accountIds) {
        //Updated By - Chirag Soni - CR-20210226-14953 - 11/12/2021 - Added new EAB_Event__r.Event_Type__c
        return [SELECT Event_Name__c,Contact__c,Contact__r.Name,EAB_Event__r.Event_Type__c, Start_Date__c, COUNT(Id) numRecords
                FROM Meeting_Utilization__c 
                WHERE Institution__c IN :accountIds AND Start_Date__c >= TODAY
                GROUP BY Event_Name__c,Start_Date__c,EAB_Event__r.Event_Type__c,Contact__c,Contact__r.Name
                ORDER BY EAB_Event__r.Event_Type__c, Start_Date__c ASC];
    }
    
    /**
     *  Description     :	get total number of records
     * 
     * 	Return Type		:	List<AggregateResult>
     *
     *	Revision Logs   :	09/20/2019 - Victor Hanson - Created
    **/
    @AuraEnabled
    public static List<AggregateResult> getAggregate(String objectAPIName, String groupByField, String parentField, String parentId) {
        return getAggregate(objectAPIName, groupByField, parentField, parentId, null);
    }
    
    /**
     *  Description     :	get total number of records
     * 
     * 	Return Type		:	List<AggregateResult>
     *
     *	Revision Logs   :	09/20/2019 - Victor Hanson - Created
    **/
    @AuraEnabled
    public static List<AggregateResult> getAggregate(String objectAPIName, String groupByField, String parentField, String parentId, String whereClause) {
        String aggQueryString = 'SELECT COUNT(Id), ' + groupByField + ' FROM ' + objectAPIName
            				  + ' WHERE ' + parentField + ' = :parentId';
        if (whereClause != null) aggQueryString += ' AND ' + whereClause;
        aggQueryString += ' GROUP BY ' + groupByField + ' ORDER BY COUNT(Id) DESC';
        return database.query(aggQueryString);
    }
}