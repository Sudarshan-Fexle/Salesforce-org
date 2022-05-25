/**
 * 
 * Desription      :    Test class for CPQUtility class
 * 
 * Revision Logs   :    V_1.0 - Created - CR-20211005-15489
 * 
 * 
 **/
@isTest (seeAllData = false)
private class Test_CPQUtility {
    
    static testMethod void testBuildSOQL() {
        Map<String, Schema.SObjectType> globalDescribe = new Map<String, Schema.SObjectType>();
        globalDescribe.put('Contact', Schema.SObjectType.Contact.getSobjectType() );
        
        String objName = 'Contact';
        String additionRelationshipFields = 'Account__r.Name';
        String whereClause = 'WWHERE AccountID != null';
        
        String query = CPQUtility.buildSOQL(globalDescribe, objName, additionRelationshipFields, whereClause); 
        System.assert(String.isNotBlank(query), 'Query Should not be blank');
        
    }
}