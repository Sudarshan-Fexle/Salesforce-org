/**
*   Purpose         :   Test class for Batch_ISSystemComponentDelete
*            
*   Create By       :   Abhinav Sharma
* 
*   Created Date    :   02/05/2019
*
*   Revision Log    :   V_1.0 - Created - Abhinav Sharma 
*   
*   Coverage        :   V_1.0
*
**/
@isTest(seeAllData = false)
private class Test_Batch_ISSystemComponentDelete 
{
    @testSetup static void testSetUpData()
    {
        //Bypass DupeBlocker and triggers for test data creation
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        Util.ByPassDLRSForTest = true;
        List<IS_System_Component__c> parentComponentsToBeInsert = new List<IS_System_Component__c>();
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Account',Object_API_Name__c = 'Account', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Contact',Object_API_Name__c = 'Contact', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Opportunity',Object_API_Name__c = 'Opportunity', Object_Type__c = 'Object'));
        insert parentComponentsToBeInsert;
        Util.byPassAllTriggers = false;
    }
    
    static testMethod void test_ISSystemCompDelete()
    {
        Set<Id> setOfIsSysCompIds = new Set<Id>();
        for(IS_System_Component__c isSysComp : [Select Id From IS_System_Component__c])
        {
            setOfIsSysCompIds.add(isSysComp.Id);
        }
        if(setOfIsSysCompIds.size() > 0) 
        {
            Test.startTest();
            Batch_ISSystemComponentDelete isSysComp = new Batch_ISSystemComponentDelete(setOfIsSysCompIds);
            DataBase.executeBatch(isSysComp); 
            Test.stopTest();        
        }
    }
}