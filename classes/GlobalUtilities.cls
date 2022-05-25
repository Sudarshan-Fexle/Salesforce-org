public without sharing class GlobalUtilities {
    
    @future(callout=true)
    public static void siteCallout_UpsertOrganization(string institutionId, string status, String site) {
        //get the site user
        string institutionJSON = SiteUserHelper.getInstitutionSiteUser(institutionId, status, site);
        
        // encrypt the response
        String EncryptedJSON = EncryptionHelper.encryptString(institutionJSON);
        
        // use Jeffery's WSDL to send the data back to Advisory.com
        SiteComSFService.SFServiceSoap sfService = new SiteComSFService.SFServiceSoap();
        sfService.timeout_x = 120000;
        
        
        string command = '[' + site + '] UpsertOrganization';
        try {
            string calloutResponse = sfService.UpsertOrganization(EncryptedJSON);
            if (calloutResponse == 'OK')
                SiteProfileLogger.log(institutionId, institutionJSON, command, 'Success', calloutResponse);
            else {
                SiteProfileLogger.log(institutionId, institutionJSON, command, 'Error', calloutResponse);
            }
        }
        catch(Exception ex) {
            SiteProfileLogger.log(institutionId, institutionJSON, command, 'Exception', ex.getMessage() + '\r\n \r\n' + ex.getStackTraceString());
        }
    }
    
    @future
    public static void ConnectDocsToOpp(Set<Id> contractIds) {
        // bypass all triggers when adding records to these opps
        Util.BypassAllTriggers = true;
        List<Contract__c> contracts = [SELECT Name, Id, (SELECT Id, Contracts_ABC__c FROM Contracts_to_Contract_Docs_MtMs__r) FROM Contract__c WHERE Id IN :contractIds];
                                        
        // get all opportunity ids
        Set<Id> contractMTMIds = new Set<Id>();
        for (Contract__c con : contracts) {
            for (Contracts_to_Contract_Docs_MtM__c docMTM : con.Contracts_to_Contract_Docs_MtMs__r)
                contractMTMIds.add(docMTM.Id);
        }
        
        // get all opps associated with the contract and the opp's Contract Doc MTMs
        Map<Id, Contracts_to_Contract_Docs_MtM__c> DocMtmMap = new Map<Id, Contracts_to_Contract_Docs_MtM__c>([SELECT Id, Contracts_ABC__c, Contract_Docs__c, Contract_Docs__r.Account__c
                                                                FROM Contracts_to_Contract_Docs_MtM__c
                                                                WHERE Id IN :contractMTMIds]);
        
        ContractsToContractDocsMTMUtilities.AddDocsToOpps(DocMtmMap);
        Util.BypassAllTriggers = false;
    }
    
    @future
    public static void ConnectDocsToContract(Set<Id> contractIds) {
        // bypass all triggers when adding records to these opps/contracts
        Util.BypassAllTriggers = true;
        List<Contract__c> contracts = [SELECT Name, Id, (SELECT Id, Signed_Opportunity_Contract__c, Previous_Contract__c FROM Opportunities__r)
                                        FROM Contract__c WHERE Id IN :contractIds];
                                        
        // get all opportunity ids
        Set<Id> oppIds = new Set<Id>();
        for (Contract__c con : contracts) {
            for (Opportunity o : con.Opportunities__r)
                oppIds.add(o.Id);
        }
        
        // get all opps associated with the contract and the opp's Contract Doc MTMs
        List<Opportunity> oppList = [SELECT Name, Id, Signed_Opportunity_Contract__c, AccountId,
                                                    (SELECT Id, Contract_Documents__c FROM Contract_Docs_to_Opps_MtMs__r)
                                                                FROM Opportunity WHERE Id IN :oppIds];
        
        ContractsToContractDocsMTMUtilities.CheckOppsForDocChanges(oppList, null);
        Util.BypassAllTriggers = false;
    }
    
}