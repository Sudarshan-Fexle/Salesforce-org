global class Batch_SyncZendeskUserRoles implements Database.Batchable<sObject>, Database.AllowsCallouts  {
    
    public String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (query == null) query = 'SELECT Id, Name, LastModifiedDate, Contact__c,' +
                                    'Project__r.Institution__r.Zendesk_Support__c,' +
                                    'Project__r.Product__r.Integration_Support__c ' +
                                    'FROM Project_Role__c ' +
                                    'WHERE LastModifiedDate >= YESTERDAY AND Project__r.Institution__r.Zendesk_Support__c = true ' +
            						'AND Project__r.Product__r.Integration_Support__c = \'' + Constants.ZENDESK + '\' ' +
                                    'ALL ROWS';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        Set<Id> contactIds = new Set<Id>();
        for (Project_Role__c pr : (List<Project_Role__c>)scope) {
            contactIds.add(pr.Contact__c);
        }
        
        //callout to sync the contact ids
        ZendeskService zdService = new ZendeskService();
        zdService.syncProjectRoles(contactIds);
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}