/**
 *  Purpose         :   Batch Class for Batch_SyncZendeskMPOCRoles
 *
 *  Create By       :   Neha Sharma
 *
 *  Created Date    :   4-Aug-2021
 *
 *  Revision Logs   :   V_1.0 - Created By - Neha Sharma - CR-20210301-14957
**/
 
global class Batch_SyncZendeskMPOCRoles implements Database.Batchable<sObject>, Database.AllowsCallouts  {
    
    public String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (query == null) query = 'Select Id,Membership__r.Program_Acronym__c, Role__c, Membership__r.Account_Name__c, ' +
                                    'Contact__c, Key_Contact_Status__c, Contact_Status__c, Membership__r.Account_Name__r.Zendesk_Id__c ' +
                                    'FROM Membership_Key_Contact__c ' +
                                    'WHERE LastModifiedDate >= YESTERDAY AND Membership__r.Account_Name__r.Zendesk_Support__c = true AND ' +
                                    'Membership__c != null AND Membership__r.Program_Acronym__c = \'' +  System.Label.ProgramForZendesk + '\' ' ;
                                                                 
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Membership_Key_Contact__c> scope) {
        
        Set<Id> contactIds = new Set<Id>();
        Map<Id, Map<Double, List<Membership_Key_Contact__c>>> mapOfContactWithMembershipKeyCon = new Map<Id, Map<Double, List<Membership_Key_Contact__c>>>();
        
        for(Membership_Key_Contact__c memKayCon :scope)
            {
                
                if(!mapOfContactWithMembershipKeyCon.containsKey(memKayCon.Contact__c)){
                    mapOfContactWithMembershipKeyCon.put(memKayCon.Contact__c, new Map<Double, List<Membership_Key_Contact__c>>());
                    mapOfContactWithMembershipKeyCon.get(memKayCon.Contact__c).put(memKayCon.Membership__r.Account_Name__r.Zendesk_Id__c, new List<Membership_Key_Contact__c>());
                }
                
                mapOfContactWithMembershipKeyCon.get(memKayCon.Contact__c).get(memKayCon.Membership__r.Account_Name__r.Zendesk_Id__c).add(memKayCon);
                contactIds.add(memKayCon.Contact__c);
            }
        //callout to sync the contact ids
        ZendeskService zdService = new ZendeskService();
        zdService.syncMembershipKeyContactRoleRoles(contactIds,mapOfContactWithMembershipKeyCon);
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}