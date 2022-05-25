/**
* 
* Desription      :   	test methods for the Batch_ISSystemComponentDuplicacyMerge class
* 
* Revision Logs   :    
* 
* 
**/
@isTest(seeAllData = false)
public class Test_Batch_ISSysCmpDuplicacyMerge {
    
    /**
* 
* @description: data setup method for record insert
* 
**/
    @testSetup static void dataSetup()
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
        
        List<SFDC_Change_Request__c> changeReqList = [Select Id From SFDC_Change_Request__c];
        System.assert(changeReqList.size() > 0);
        
        // IS_System__c
        List<IS_System__c> isSystemList = new List<IS_System__c>();
        isSystemList.add(new IS_System__c(Name = 'Test1',Status__c = 'Active'));
        isSystemList.add(new IS_System__c(Name = 'Test2',Status__c = 'Active'));
        isSystemList.add(new IS_System__c(Name = 'Test3',Status__c = 'Active'));
        isSystemList.add(new IS_System__c(Name = 'Test4',Status__c = 'Active'));
        isSystemList.add(new IS_System__c(Name = 'Test5',Status__c = 'Active'));
        isSystemList.add(new IS_System__c(Name = 'Test6',Status__c = 'Active'));
        isSystemList.add(new IS_System__c(Name = 'Test7',Status__c = 'Active'));
        isSystemList.add(new IS_System__c(Name = 'Test8',Status__c = 'Active'));
        isSystemList.add(new IS_System__c(Name = 'Test9',Status__c = 'Active'));
        isSystemList.add(new IS_System__c(Name = 'Test10',Status__c = 'Active'));
        isSystemList.add(new IS_System__c(Name = 'Test11',Status__c = 'Active'));
        
        insert isSystemList;
        
        List<IS_System__c> isSystemList2 = [Select Id From IS_System__c];
        System.assert(isSystemList.size() > 0);
        System.assert(isSystemList[0].Id != null);
        
         List<IS_System_Component__c> childComponentsToBeInsert = new List<IS_System_Component__c>();
        childComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate', IS_System__c = isSystemList[0].Id, Object_Label__c = 'Account',Object_API_Name__c = 'Account', Object_Type__c = 'Object'));
        childComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate', IS_System__c = isSystemList[1].Id, Object_Label__c = 'Account',Object_API_Name__c = 'Account', Object_Type__c = 'Object'));
        childComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate', IS_System__c = isSystemList[2].Id, Object_Label__c = 'Account',Object_API_Name__c = 'Account', Object_Type__c = 'Object'));
		
        insert childComponentsToBeInsert;
        
        List<IS_System_Component__c> parentComponentsToBeInsert = new List<IS_System_Component__c>();
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate', Parent_IsSystemComponent__c	 = childComponentsToBeInsert[0].Id, IS_System__c = isSystemList[0].Id, Object_Label__c = 'Account',Object_API_Name__c = 'Account', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate', Parent_IsSystemComponent__c	 = childComponentsToBeInsert[1].Id, IS_System__c = isSystemList[1].Id, Object_Label__c = 'Account',Object_API_Name__c = 'Account', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate', Parent_IsSystemComponent__c	 = childComponentsToBeInsert[2].Id, IS_System__c = isSystemList[2].Id, Object_Label__c = 'Account',Object_API_Name__c = 'Account', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate', IS_System__c = isSystemList[3].Id, Object_Label__c = 'Account',Object_API_Name__c = 'Account', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate', IS_System__c = isSystemList[4].Id, Object_Label__c = 'Account',Object_API_Name__c = 'Account', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate', IS_System__c = isSystemList[5].Id, Object_Label__c = 'Contact',Object_API_Name__c = 'Contact', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate', IS_System__c = isSystemList[5].Id, Object_Label__c = 'Contact',Object_API_Name__c = 'Contact', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate', IS_System__c = isSystemList[6].Id, Object_Label__c = 'Contact',Object_API_Name__c = 'Contact', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Contact',Object_API_Name__c = 'Contact', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Contact',Object_API_Name__c = 'Contact', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Contact',Object_API_Name__c = 'Contact', Object_Type__c = 'Object'));
        parentComponentsToBeInsert.add(new IS_System_Component__c(Name = 'will auto-populate',Object_Label__c = 'Contact',Object_API_Name__c = 'Contact', Object_Type__c = 'Object'));
        
        insert parentComponentsToBeInsert;
        
        
        List<IS_System_Component__c> isSystemComList = [Select Id From IS_System_Component__c];
        System.assert(isSystemComList.size() == 15);
        
        
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
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr1.Id,IS_System_Component__c = childComponentsToBeInsert[0].Id,Type_Of_Modification__c = 'Add', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr1.Id,IS_System_Component__c = childComponentsToBeInsert[1].Id,Type_Of_Modification__c = 'Modify', Description__c = 'Tsesting the Batch'));
        modsToBeInsert.add(new IS_System_Modification__c(Change_Request__c = cr2.Id,IS_System_Component__c = childComponentsToBeInsert[2].Id,Type_Of_Modification__c = 'Add', Description__c = 'Tsesting the Batch'));
       
        insert modsToBeInsert;
        
        List<IS_System_Modification__c> isSysModList = [Select Id From IS_System_Modification__c];
        System.assert(isSysModList.size() == 13);
        
    }
  
/**
* 
* @description: test batch 
* 
**/
    static testMethod void test_Batch()
    {
        Set<Id> setOfIsSysCmpIds = new Set<Id>();
        for(IS_System_Component__c isSys : [Select Id From IS_System_Component__c])
        {
            setOfIsSysCmpIds.add(isSys.Id);
        }
        System.debug('setOfIsSysCmpIds = '+ setOfIsSysCmpIds);
        test.startTest();
        Batch_ISSystemComponentDuplicacyMerge batchExe = new Batch_ISSystemComponentDuplicacyMerge(setOfIsSysCmpIds);
        DataBase.executeBatch(batchExe,20);
        
        Batch_ISSystemComponentDuplicacyMerge batchExe1 = new Batch_ISSystemComponentDuplicacyMerge(null);
        DataBase.executeBatch(batchExe1,20);
        test.stopTest();   
        
        
    }
    
}