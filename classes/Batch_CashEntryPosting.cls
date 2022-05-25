global class Batch_CashEntryPosting implements Database.Batchable<SObject> {

    global String query = 'SELECT id FROM c2g__codaCashEntry__c where c2g__status__c = \'In Progress\'';
    
    //Override Start method
    global Database.queryLocator start(Database.BatchableContext ctx) {

        // Query all Memberships with Future status
        return Database.getQueryLocator(query);
    }
    
    //Override execute method
    global void execute(Database.BatchableContext ctx, list<Sobject> scope) {
    
        // Convert the query of Sobjects into a List of CashEntry
        list<c2g__codaCashEntry__c> cashEntries = (list<c2g__codaCashEntry__c>) scope;
        // Loop through all CashEntries
        for (c2g__codaCashEntry__c cashEntry : cashEntries) {
            c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();
            ref.Id = cashEntry.Id;
            
            try {
                c2g.CODAAPICashEntry_6_0.PostCashEntry(null, ref);
            } catch (Exception ex) {
                String emailMessage = 'Error has happend for cash entry: ' + cashEntry.id + '\n' + ex;
                AsyncApexJob a = [SELECT CreatedBy.Email FROM AsyncApexJob WHERE id = :ctx.getJobId()];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {a.CreatedBy.email};
                mail.setToAddresses(toAddresses);
                mail.setReplyTo('noreply@salesforce.com');
                mail.setSenderDisplayName('Salesforce Batch'); 
                mail.setSubject('Batch_CashEntryPosting: error');
                mail.setPlainTextBody(emailMessage);
                mail.setHtmlBody(emailMessage);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }
    
    // Override Finish method
    global void finish(Database.BatchableContext ctx) {
    
        AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors,
                            CompletedDate, CreatedDate, CreatedBy.Email FROM AsyncApexJob WHERE id = :ctx.getJobId()];
        
        // Send email to confirm completion of this batch
        String emailMessage = 'The batch job \"Batch_CashEntryPosting\" has finished.  It has started at ' + a.CreatedDate + 
            ' and has finished at ' + a.CompletedDate + '. It has processed '  + a.TotalJobItems + ' batches.  Of which, ' +
            a.JobItemsProcessed + ' processed without any exceptions thrown and ' + a.NumberOfErrors +
            ' batches threw unhandled exceptions.';
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.email};
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('noreply@salesforce.com');
        mail.setSenderDisplayName('Salesforce Batch'); 
        mail.setSubject('Batch_CashEntryPosting: completed');
        mail.setPlainTextBody(emailMessage);
        mail.setHtmlBody(emailMessage);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}