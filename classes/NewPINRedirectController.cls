/*
    Purpose:
       The Controller for the PINRedirect VF page. It sets the ffap__DerivePeriod__c checkbox to false
       and redirects to the standard New page.
            
    Initiative: IconATG PSA Implementation
    Author:     William Rich
    Company:    IconATG
    Contact:    william.rich@iconatg.com
    Created:    7/6/2015
*/

public with sharing class NewPINRedirectController {

    private final ApexPages.StandardController stdController;

    public NewPINRedirectController(ApexPages.StandardController stdController) {
        this.stdController = stdController;
    }

    public PageReference redirect() {
        PageReference pgRef = new PageReference('/a27/e');
        pgRef.getParameters().put('retURL', ApexPages.currentPage().getParameters().get('retURL'));
        pgRef.getParameters().put('00NC0000005wRl1', 'false');
        pgRef.getParameters().put('nooverride', '1');
        pgRef.setRedirect(true);
        return pgRef;
    }
}