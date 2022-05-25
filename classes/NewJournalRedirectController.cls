/*
    Purpose:
       The Controller for the NewJournalRedirect VF page. It sets the ffgl__DerivePeriod__c checkbox to false
       and redirects to the standard New page.
            
    Initiative: IconATG PSA Implementation
    Author:     William Rich
    Company:    IconATG
    Contact:    william.rich@iconatg.com
    Created:    7/6/2015
*/

public with sharing class NewJournalRedirectController {

    private final ApexPages.StandardController stdController;

    public NewJournalRedirectController(ApexPages.StandardController stdController) {
        this.stdController = stdController;
    }

    public PageReference redirect() {
        PageReference pgRef = new PageReference('/a1e/e');
        pgRef.getParameters().put('retURL', ApexPages.currentPage().getParameters().get('retURL'));
        pgRef.getParameters().put('00NC0000005wRlC', 'false');
        pgRef.getParameters().put('nooverride', '1');
        pgRef.setRedirect(true);
        return pgRef;
    }
}