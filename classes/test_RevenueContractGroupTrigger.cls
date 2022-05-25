@isTest
public with sharing class test_RevenueContractGroupTrigger
{
   /************************************************************************************    
    *    Rudimentary test to get coverage of RevenueContractGroup.trigger
    *    Functional testing of the handler is included in ffps_eab package and this test 
    *    is simply to allow the unmanaged trigger to be deployed.
    **/
    @isTest
    public static void testRevenueObjectDeletion_test()
    {
       Revenue_Contract_Group__c rcg = new Revenue_Contract_Group__c();
       insert rcg;
       delete rcg; 
    }
}