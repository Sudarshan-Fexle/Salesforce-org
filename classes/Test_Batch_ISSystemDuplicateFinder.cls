/**
*  Description     :   This class is there to find duplicate Is System Component records.
*
*  Created Date    :   02/04/2020 
* 
*  Revision Logs   :   V1.0 - Created
*
**/
@isTest(seeAllData = false)
private class Test_Batch_ISSystemDuplicateFinder {
    
    
    static testMethod void testBatchISSystemDuplicateFinder()
    {
        
        //Bypass DupeBlocker and triggers for test data creation
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        //V1.2
        Util.ByPassDLRSForTest = true;
        
        //Set up data as needed for the test class
        
        SFDC_Change_Request__c cr1 =TestUtilities.CreateChangeRequest(true);
        SFDC_Change_Request__c cr2 =TestUtilities.CreateChangeRequest(true);
        SFDC_Change_Request__c cr3 =TestUtilities.CreateChangeRequest(true);
        
        //List to hold the parent component which has to insert
        List<IS_System_Component__c> parentComponentsToBeInsert = new List<IS_System_Component__c>();
        
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Account',Object_API_Name__c = 'Account', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Account',Object_API_Name__c = 'Account', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Account',Object_API_Name__c = 'Account', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Account',Object_API_Name__c = 'Account', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Account',Object_API_Name__c = 'Account', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Contact',Object_API_Name__c = 'Contact', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Contact',Object_API_Name__c = 'Contact', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Contact',Object_API_Name__c = 'Contact', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Contact',Object_API_Name__c = 'Contact', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Contact',Object_API_Name__c = 'Contact', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Contact',Object_API_Name__c = 'Contact', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Opportunity',Object_API_Name__c = 'Opportunity', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Opportunity',Object_API_Name__c = 'Opportunity', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Opportunity',Object_API_Name__c = 'Opportunity', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Opportunity',Object_API_Name__c = 'Opportunity', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Opportunity',Object_API_Name__c = 'Opportunity', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Opportunity',Object_API_Name__c = 'Opportunity', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Opportunity',Object_API_Name__c = 'Opportunity', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Test_Batch_ISSystemDuplicateFinder',Object_API_Name__c = 'Test_Batch_ISSystemDuplicateFinder', Object_Type__c = 'Apex Class'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Test_Batch_ISSystemDuplicateFinder',Object_API_Name__c = 'Test_Batch_ISSystemDuplicateFinder', Object_Type__c = 'Apex Class'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Test_Batch_ISSystemDuplicateFinder',Object_API_Name__c = 'Test_Batch_ISSystemDuplicateFinder', Object_Type__c = 'Apex Class'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Test_Batch_ISSystemDuplicateFinder',Object_API_Name__c = 'Test_Batch_ISSystemDuplicateFinder', Object_Type__c = 'Apex Class'));
        
        if(parentComponentsToBeInsert != null)
        {
            //Inserting Parent Component
            insert parentComponentsToBeInsert;
        }
        
        //List to hold the child component which has to insert
        List<IS_System_Component__c> childComponentsToBeInsert = new List<IS_System_Component__c>();
        
        childComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Account_No__c',Object_API_Name__c = 'Account_No__c',Parent__c	 =parentComponentsToBeInsert[0].Id ,Object_Type__c = 'Custom Field'));
        childComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Account_No__c',Object_API_Name__c = 'Account_No__c',Parent__c	 =parentComponentsToBeInsert[1].Id ,Object_Type__c = 'Custom Field'));
        childComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Account_Formal_Name__c',Object_API_Name__c = 'Account_Formal_Name__c',Parent__c	 =parentComponentsToBeInsert[2].Id ,Object_Type__c = 'Custom Field'));
        childComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Account_Formal_Name__c',Object_API_Name__c = 'Account_Formal_Name__c',Parent__c	 =parentComponentsToBeInsert[3].Id ,Object_Type__c = 'Custom Field'));
        childComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Account_Restriction_Status__c',Object_API_Name__c = 'Account_Restriction_Status__c',Parent__c	 =parentComponentsToBeInsert[4].Id ,Object_Type__c = 'Custom Field'));
        childComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Account_Restriction_Status__c',Object_API_Name__c = 'Account_Restriction_Status__c',Parent__c	 =parentComponentsToBeInsert[5].Id ,Object_Type__c = 'Custom Field'));
        childComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Account_No__c',Object_API_Name__c = 'Account_No__c',Parent__c	 =parentComponentsToBeInsert[6].Id ,Object_Type__c = 'Custom Field'));
        childComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Account_No__c',Object_API_Name__c = 'Account_No__c',Parent__c	 =parentComponentsToBeInsert[7].Id ,Object_Type__c = 'Custom Field'));
        childComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Account_Formal_Name__c',Object_API_Name__c = 'Account_Formal_Name__c',Parent__c	 =parentComponentsToBeInsert[8].Id ,Object_Type__c = 'Custom Field'));
        childComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Account_Formal_Name__c',Object_API_Name__c = 'Account_Formal_Name__c',Parent__c	 =parentComponentsToBeInsert[9].Id ,Object_Type__c = 'Custom Field'));
        childComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Account.Account_No__c',Object_API_Name__c = 'Account.Account_No__c',Parent__c	 =parentComponentsToBeInsert[2].Id, Object_Type__c = 'Custom Field'));
        childComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Account.Account_No__c',Object_API_Name__c = 'Account.Account_No__c',Parent__c	 =parentComponentsToBeInsert[2].Id, Object_Type__c = 'Custom Field'));
        childComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Contact-Account_Formal_Name__c',Object_API_Name__c = 'Contact-Account_Formal_Name__c',Parent__c	 =parentComponentsToBeInsert[8].Id, Object_Type__c = 'Page Layout'));
        childComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Contact-Account_Formal_Name__c',Object_API_Name__c = 'Contact-Account_Formal_Name__c',Parent__c	 =parentComponentsToBeInsert[8].Id, Object_Type__c = 'Page Layout'));
        
        if(childComponentsToBeInsert != null)
        {
            //Inserting Child Component
            insert childComponentsToBeInsert;
        }
        
        List<IS_System_Modification__c> modsToBeInsert = new List<IS_System_Modification__c>();
        
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr1.Id,IS_System_Component__c = parentComponentsToBeInsert[0].Id,Type_Of_Modification__c = 'Add', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr1.Id,IS_System_Component__c = parentComponentsToBeInsert[1].Id,Type_Of_Modification__c = 'Modify', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr1.Id,IS_System_Component__c = parentComponentsToBeInsert[2].Id,Type_Of_Modification__c = 'Modify', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr1.Id,IS_System_Component__c = parentComponentsToBeInsert[3].Id,Type_Of_Modification__c = 'Add', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr1.Id,IS_System_Component__c = parentComponentsToBeInsert[4].Id,Type_Of_Modification__c = 'Modify', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr1.Id,IS_System_Component__c = parentComponentsToBeInsert[5].Id,Type_Of_Modification__c = 'Modify', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr1.Id,IS_System_Component__c = parentComponentsToBeInsert[6].Id,Type_Of_Modification__c = 'Delete', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr1.Id,IS_System_Component__c = parentComponentsToBeInsert[7].Id,Type_Of_Modification__c = 'Add', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr1.Id,IS_System_Component__c = parentComponentsToBeInsert[8].Id,Type_Of_Modification__c = 'Modify', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr2.Id,IS_System_Component__c = parentComponentsToBeInsert[9].Id,Type_Of_Modification__c = 'Add', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr2.Id,IS_System_Component__c = childComponentsToBeInsert[1].Id,Type_Of_Modification__c = 'Modify', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr2.Id,IS_System_Component__c = childComponentsToBeInsert[2].Id,Type_Of_Modification__c = 'Modify', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr2.Id,IS_System_Component__c = childComponentsToBeInsert[3].Id,Type_Of_Modification__c = 'Add', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr2.Id,IS_System_Component__c = childComponentsToBeInsert[4].Id,Type_Of_Modification__c = 'Modify', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr2.Id,IS_System_Component__c = childComponentsToBeInsert[5].Id,Type_Of_Modification__c = 'Modify', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr2.Id,IS_System_Component__c = childComponentsToBeInsert[6].Id,Type_Of_Modification__c = 'Delete', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr2.Id,IS_System_Component__c = childComponentsToBeInsert[7].Id,Type_Of_Modification__c = 'Add', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr2.Id,IS_System_Component__c = childComponentsToBeInsert[8].Id,Type_Of_Modification__c = 'Modify', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr2.Id,IS_System_Component__c = childComponentsToBeInsert[9].Id,Type_Of_Modification__c = 'Modify', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr3.Id,IS_System_Component__c = parentComponentsToBeInsert[6].Id,Type_Of_Modification__c = 'Delete', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr3.Id,IS_System_Component__c = parentComponentsToBeInsert[7].Id,Type_Of_Modification__c = 'Add', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr3.Id,IS_System_Component__c = parentComponentsToBeInsert[8].Id,Type_Of_Modification__c = 'Modify', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr3.Id,IS_System_Component__c = parentComponentsToBeInsert[9].Id,Type_Of_Modification__c = 'Add', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr3.Id,IS_System_Component__c = childComponentsToBeInsert[1].Id,Type_Of_Modification__c = 'Modify', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr3.Id,IS_System_Component__c = childComponentsToBeInsert[2].Id,Type_Of_Modification__c = 'Modify', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr3.Id,IS_System_Component__c = childComponentsToBeInsert[3].Id,Type_Of_Modification__c = 'Add', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr3.Id,IS_System_Component__c = childComponentsToBeInsert[4].Id,Type_Of_Modification__c = 'Modify', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr3.Id,IS_System_Component__c = childComponentsToBeInsert[5].Id,Type_Of_Modification__c = 'Modify', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr3.Id,IS_System_Component__c = childComponentsToBeInsert[6].Id,Type_Of_Modification__c = 'Delete', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr3.Id,IS_System_Component__c = childComponentsToBeInsert[7].Id,Type_Of_Modification__c = 'Add', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr3.Id,IS_System_Component__c = childComponentsToBeInsert[8].Id,Type_Of_Modification__c = 'Modify', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr3.Id,IS_System_Component__c = childComponentsToBeInsert[9].Id,Type_Of_Modification__c = 'Modify', Description__c = 'Tsesting the Batch'));
        
        if(modsToBeInsert != null)
        {
            //Inserting Child Component
            insert modsToBeInsert;
        }
        
        //Set to hold the 
        Set<Id> setOfIsSystemCompIds = new Set<Id>();
        
        for(IS_System_Component__c isSystemComp : [Select Id from IS_System_Component__c])
        {
            setOfIsSystemCompIds.add(isSystemComp.Id);
        }
        Test.startTest();
        if(setOfIsSystemCompIds.Size() > 0)
        {
            Batch_ISSystemDuplicateFinder batchExe = new Batch_ISSystemDuplicateFinder(setOfIsSystemCompIds);
            DataBase.executeBatch(batchExe,100);      
        }
        Test.stopTest();   
    } 
}