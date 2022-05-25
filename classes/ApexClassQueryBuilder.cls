/**
*  Purpose      :   "ApexClass" Query Builder class
*  Created By   :   Abhinav Sharma
**/
public with sharing class ApexClassQueryBuilder 
{
    public static List<List<ApexClass>> retrieveAllTestClasses() 
    {
        return [Find '@isTest' IN ALL FIELDS RETURNING ApexClass(Id , Name 
                                                                 Where Name Like '%Test%' 
                                                                 AND NamespacePrefix = null
                                                                )];
    }
    
    // Modified by Rajeev Jain for CR-20200414-13943 14/April/2020 Start Here (Use AND in place of OR)
    public static List<ApexClass> retrieveClassesHavingTestMethodsInBetween() 
    {
        return [SELECT Id, Body 
                FROM ApexClass 
                WHERE NamespacePrefix = '' AND (Name LIKE '%Test' OR Name LIKE 'Test%')];  
    }
    // Modified by Rajeev Jain for CR-20200414-13943 14/April/2020 Ends Here
    
    public static String buildDynamicApexClassQuery(Set<Id> testclassesIds) 
    {
        if(Test.isRunningTest()) 
        {
            return 'SELECT ID FROM ApexClass WHERE ID IN : testclassesIds LIMIT 100';
        }
        else 
        {
            return 'SELECT ID FROM ApexClass WHERE ID IN : testclassesIds';    
        }
    }
}