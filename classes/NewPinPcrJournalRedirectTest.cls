/*
    Purpose:
       The Test class for the following controllers:
           NewPINRedirectController
           NewPCRRedirectController
           NewJournalRedirectController
            
    Initiative: IconATG PSA Implementation
    Author:     William Rich
    Company:    IconATG
    Contact:    william.rich@iconatg.com
    Created:    7/6/2015
*/

@isTest(SeeAllData=false)
private class NewPinPcrJournalRedirectTest  {

    static testMethod void testPINRedirect() {
        c2g__codaPurchaseInvoice__c pin = new c2g__codaPurchaseInvoice__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(pin);

        Test.startTest();

        NewPINRedirectController pinController = new NewPINRedirectController(stdController);
        pinController.redirect();

        Test.stopTest();
    }

    static testMethod void testPCRRedirect() {
        c2g__codaPurchaseCreditNote__c pcr = new c2g__codaPurchaseCreditNote__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(pcr);

        Test.startTest();

        NewPCRRedirectController pcrController = new NewPCRRedirectController(stdController);
        pcrController.redirect();

        Test.stopTest();
    }

    static testMethod void testJournalRedirect() {
        c2g__codaJournal__c journal = new c2g__codaJournal__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(journal);

        Test.startTest();

        NewJournalRedirectController journalController = new NewJournalRedirectController(stdController);
        journalController.redirect();

        Test.stopTest();
    }
}