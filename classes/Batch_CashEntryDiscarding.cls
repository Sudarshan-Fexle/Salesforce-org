global class Batch_CashEntryDiscarding implements Database.Batchable<SObject> {

    global String query = 'SELECT Id, c2g__BankAccount__c, c2g__BankAccountCurrency__c, c2g__CashEntryCurrency__c, c2g__Date__c, '
        + 'c2g__PaymentMethod__c, c2g__Period__c, c2g__Type__c FROM c2g__codaCashEntry__c '
        + 'WHERE C2G__BANKACCOUNTVALUE__C<= 0 and C2G__Status__C=\'In Progress\'';
    
    //Override Start method
    global Database.queryLocator start(Database.BatchableContext ctx) {
        return Database.getQueryLocator(query);
    }
    
    //Override execute method
    global void execute(Database.BatchableContext ctx, list<Sobject> scope) {
    
        // Convert the query of Sobjects into a List of CashEntry
        list<c2g__codaCashEntry__c> cashEntries = (list<c2g__codaCashEntry__c>) scope;
        // Loop through all CashEntries
        for (c2g__codaCashEntry__c cashEntry : cashEntries) {
            try {
                c2g.CODAAPICashEntryTypes_6_0.CashEntry entry = new c2g.CODAAPICashEntryTypes_6_0.CashEntry();
                
                entry.BankAccount = new c2g.CODAAPICommon.Reference();
                entry.BankAccount.Id = cashEntry.c2g__BankAccount__c;
                
                entry.BankAccountCurrency = cashEntry.c2g__BankAccountCurrency__c;
                
                entry.CashEntryCurrency = new c2g.CODAAPICommon.Reference();
                entry.CashEntryCurrency.Id = cashEntry.c2g__CashEntryCurrency__c;
                
                entry.DateValue = cashEntry.c2g__Date__c;
                
                entry.PaymentMethod = cashEntry.c2g__PaymentMethod__c;
                
                entry.Period = new c2g.CODAAPICommon.Reference();
                entry.Period.Id = cashEntry.c2g__Period__c;
             
                entry.TypeRef = parseCashEntryType(cashEntry.c2g__Type__c);
             
                entry.Id = cashEntry.Id;
                entry.DiscardReason = 'Data Migration Error';
                entry.Status = c2g.CODAAPICashEntryTypes_6_0.enumStatus.Discarded;
                
                c2g.CODAAPICashEntry_6_0.UpdateCashEntry(null, entry);
            } catch (Exception ex) {
                String emailMessage = 'Error has happend for cash entry: ' + cashEntry.id + '\n' + ex;
                AsyncApexJob a = [SELECT CreatedBy.Email FROM AsyncApexJob WHERE id = :ctx.getJobId()];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {a.CreatedBy.email};
                mail.setToAddresses(toAddresses);
                mail.setReplyTo('noreply@salesforce.com');
                mail.setSenderDisplayName('Salesforce Batch'); 
                mail.setSubject('Batch_CashEntryDiscarding: error');
                mail.setPlainTextBody(emailMessage);
                mail.setHtmlBody(emailMessage);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }

    c2g.CODAAPICashEntryTypes_6_0.enumType parseCashEntryType(string type)
    {
        for (c2g.CODAAPICashEntryTypes_6_0.enumType tt: c2g.CODAAPICashEntryTypes_6_0.enumType.values()) {
            if (tt.name() == type) {
                return tt;
            }
        }
        
        return c2g.CODAAPICashEntryTypes_6_0.enumType.Payment;
    }
    
    // Override Finish method
    global void finish(Database.BatchableContext ctx) {
    
        AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors,
                            CompletedDate, CreatedDate, CreatedBy.Email FROM AsyncApexJob WHERE id = :ctx.getJobId()];
        
        // Send email to confirm completion of this batch
        String emailMessage = 'The batch job \"Batch_CashEntryDiscarding\" has finished.  It has started at ' + a.CreatedDate + 
            ' and has finished at ' + a.CompletedDate + '. It has processed '  + a.TotalJobItems + ' batches.  Of which, ' +
            a.JobItemsProcessed + ' processed without any exceptions thrown and ' + a.NumberOfErrors +
            ' batches threw unhandled exceptions.';
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.email};
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('noreply@salesforce.com');
        mail.setSenderDisplayName('Salesforce Batch'); 
        mail.setSubject('Batch_CashEntryDiscarding: completed');
        mail.setPlainTextBody(emailMessage);
        mail.setHtmlBody(emailMessage);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}