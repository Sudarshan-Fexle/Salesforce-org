/**
 * 
 * Desription      :   	Trigger for the IS Use Case object
 * 
 * Revision Logs   :   	v1.00 - Victor Hanson - 10/30/2015 - Created
 * 						v1.01 - Jason Bennett - 3/22/2016 - Updated SOQL query to remove IS_Process since these are no longer linked in the current design
 * 
 * 
 **/
public without sharing class ISSystemAppHelper {
    
    public static final string SYSTEM_APP_STATUS_INACTIVE = 'Inactive';
    
	/**
     * @description: If the Status is changed and the new value is ‘Inactive’.  
     * 				 The method will check all child records for the current parent(s) for any records with a Status not equal to ‘Inactive’.  
     * 				 If found, an error is displayed from a custom label
     **/
    
    public static void inactiveCheck(map<Id, IS_System__c> newMapSystemApps, map<Id, IS_System__c> oldMapSystemApps) {
        //set of all system app ids that are changing to inactive
        set<Id> inactiveIdSet = new set<Id>();
        for (IS_System__c sysApp : newMapSystemApps.values()) {
            IS_System__c oldSysApp = oldMapSystemApps.get(sysApp.Id);
            if (sysApp.Status__c == 'Inactive' && sysApp.Status__c != oldSysApp.status__c) {
                inactiveIdSet.add(sysApp.Id);
            }
        }
        
        //if there is at least one system app being changed to inactive, get all child records
        if (inactiveIdSet.size() > 0) {
            list<IS_System__c> sysAppWithChildRecords = [SELECT Id, (SELECT Id, Status__c FROM IS_Systems__r WHERE Status__c != :SYSTEM_APP_STATUS_INACTIVE)
                                                         FROM IS_System__c WHERE Id IN :inactiveIdSet];
            for (IS_System__c sysAppWithActiveChild : sysAppWithChildRecords) {
                if (sysAppWithActiveChild.IS_Systems__r.size() > 0) {
                    IS_System__c sysApp = newMapSystemApps.get(sysAppWithActiveChild.Id);
                    sysApp.addError(Label.IS_System_App_Active_Child_Error);
                }
            }
        } 
    }
    
}