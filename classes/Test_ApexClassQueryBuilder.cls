/**
*   Purpose         :   Test class for ApexClassQueryBuilder
*            
*   Create By       :   Abhinav Sharma
* 
*   Created Date    :   01/01/2020
*
*   Revision Log    :   V_1.0 - Created - Abhinav Sharma
*   
*   Coverage        :   V_1.0 - 100%
*
**/
@isTest(seeAllData = false)
private class Test_ApexClassQueryBuilder 
{
    static testMethod void testApexClassQueryBuilder()
    {
        Set<Id> setOfApexIds = new Set<Id>();
        for(ApexClass aC : [SELECT Id From ApexClass LIMIT 100])
        {
            setOfApexIds.add(aC.Id);    
        }
        System.assert(setOfApexIds.size() > 0);
        
        Test.startTest();
        ApexClassQueryBuilder.retrieveClassesHavingTestMethodsInBetween(); 
        ApexClassQueryBuilder.retrieveAllTestClasses();
        ApexClassQueryBuilder.buildDynamicApexClassQuery(setOfApexIds);
        Test.stopTest();
    }
}