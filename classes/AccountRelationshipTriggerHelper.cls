/**
 *  Description     :   Helper class for AccountRelationship__c object trigger.
 *
 *  Created By      :   Abhinav Sharma
 *
 *  Created Date    :   02/02/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20150116-8581
 **/

public class AccountRelationshipTriggerHelper {

     /**
     *  @description    :   Method to validate "For each Institution, allow only one relationship per Third Party record." 
     * 
     *  @args           :   List of Account Relationships
     * 
     *  @return         :   void
     * 
    **/ 
    //Added By - Abhinav Sharma - CR-20150116-8581 - 02/02/2015
    public static void validateRelationshipForThirdParty(List<AccountRelationship__c> listAccountReleationship) {
        
        //Set to hold the institution Ids
        Set<Id> setInstitutionIds = new Set<Id>();
        
        //Loop through new records
        for(AccountRelationship__c aR : listAccountReleationship) {
            if(aR.Institution__c != null && aR.Third_Party__c != null)
                setInstitutionIds.add(aR.Institution__c);
        }
        
        //Checking for setInstitutionIds size
        if(setInstitutionIds.size() > 0) {
            
            //Map to hold the institution Id as key and associated account relationship record third party lookup Ids as value
            Map<Id, Set<Id>> mapAccountIdWithThirdParty = new Map<Id, Set<Id>>();
        
            //Querying for Account Relationship records
            for(AccountRelationship__c a : [SELECT ID, Institution__c, Third_Party__c FROM AccountRelationship__c 
                                                WHERE Institution__c != null AND institution__c IN : setInstitutionIds
                                                AND Third_Party__c != null]) {
                if(mapAccountIdWithThirdParty.containsKey(a.Institution__c))
                    mapAccountIdWithThirdParty.get(a.Institution__c).add(a.Third_Party__c);
                else
                    mapAccountIdWithThirdParty.put(a.Institution__c, new Set<Id>{a.Third_Party__c});
            }
        
            //Checking map for its size value
            if(mapAccountIdWithThirdParty.size() > 0) {
                    
                //Loop through new Account relationship record and validating it
                for(AccountRelationship__c  aRelationship : listAccountReleationship) {
                    if(aRelationship.Institution__c != null 
                        && aRelationship.Third_Party__c != null 
                        && mapAccountIdWithThirdParty.containsKey(aRelationship.Institution__c)
                        && mapAccountIdWithThirdParty.get(aRelationship.Institution__c) != null
                        && mapAccountIdWithThirdParty.get(aRelationship.Institution__c).contains(aRelationship.Third_Party__c))
                            aRelationship.addError(System.Label.ERROR_Third_Party);        
               }
            }
        }
    }
}