@isTest
private class TestCInvBulkPrintExtension {
    static testMethod void testContinuePrinting()
    {
        ConsolidatedInvoice__c ci = new ConsolidatedInvoice__c(PrintStatus__c = 'Not Printed');
        insert ci;
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController([Select Id, Name from ConsolidatedInvoice__c Where Id = :ci.id]);
        sc.setSelected(new List<ConsolidatedInvoice__c>{ci});

Test.startTest();
        CInvBulkPrintExtension handler = new CInvBulkPrintExtension(sc);
        handler.ContinuePrinting();
Test.stopTest();

        ci = [Select Id, Name, PrintStatus__c from ConsolidatedInvoice__c Where Id = :ci.id];
        System.AssertEquals('Printed', ci.PrintStatus__c);
    }
}