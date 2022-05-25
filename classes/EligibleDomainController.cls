public with sharing class EligibleDomainController {

    @AuraEnabled
    public static string checkEligibleDomain(string recordId)
    {
        String msg = '';
        String US_CORPORATE_RTYPE = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Corporate').getRecordTypeId();
        String US_EDUCATION_RTYPE = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Education').getRecordTypeId();
        String US_INTER_EDU_RTYPE = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Education').getRecordTypeId();
        
        if(String.isNotBlank(recordId)){
            for(Account acc : [Select Id,recordType.Id,(Select Id,Name,Is_Included__c FROM Eligible_Domains__r) FROM Account WHERE Id =: recordId and Status__c = 'Active']){
                
                if(acc.recordType.Id == US_CORPORATE_RTYPE ||  acc.recordType.Id == US_EDUCATION_RTYPE || acc.recordType.Id == US_INTER_EDU_RTYPE){
                    if(acc.Eligible_Domains__r.size() == 0){
                        msg = 'This institution does not have an associated eligible domain record, which impacts eab.com access.';
                    }
                    else if(acc.Eligible_Domains__r.size() > 0){
                        Boolean eligibleDomain = false;
                        for(Eligible_Domain__c eligibleDomn : acc.Eligible_Domains__r){
                            if(eligibleDomn.Is_Included__c == true){
                                eligibleDomain = true;
                            }
                        }
                        if(eligibleDomain == false){
                          
                            msg = 'This institution does not have an associated eligible domain record, which impacts eab.com access.';
                        }
                    }
                    
                }
            }
        }
       return msg; 
    }
}