/**
*  Purpose         :  Test class for CustomLookupController
*               
*  Created By      :  Dipesh Gupta
*   
*  Created Date    :  6/4/2020 
*   
*  Revision Log    :   v1.0  
*                       
*  Coverage        :    
**/

@isTest(SeeAllData=false)
private class Test_CustomLookupController {

   @testSetup static void setup() {
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education'); 
        
        //List to hold Institution records
        List<Account> accounts = new List<Account>();
        
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test Account', Status__c = 'Active' ));
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test BAccount', Status__c = 'Active' ));
        
        //Insert
        insert accounts;
        //
        List<RecordType> conRType = [Select Id, DeveloperName From RecordType Where SobjectType = 'Contact' AND DeveloperName = 'Employee' AND IsActive = true];
        
        //Create contact
        List<Contact> contacts = new List<Contact>();
        Contact con = new Contact(FirstName = 'Sub Test', LastName = 'Contact', AccountId = accounts[0].Id, Contact_Status__c = 'Active', recordTypeId = conRType[0].Id);
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = accounts[0].Id, Contact_Status__c = 'Active', recordTypeId = conRType[0].Id);
        contacts.add(contact);
        
        //Insert
        insert contacts;
        
        //Custom setting record
        ShipIt_Settings__c setting = new ShipIt_Settings__c();
        setting.Name = 'ContactSearchLimit';
        setting.Value__c = '1';
        insert setting ;
        
    }
       
    @isTest
    static void Test_CustomLookupContrlWithSearchString(){
        
        List<Account> accList = [Select Id from Account];
        test.startTest();
        
        Test.setCurrentPageReference(new PageReference('Page.CustomLookup')); 
        System.currentPageReference().getParameters().put('lksrch', 'Test Contact');
        System.currentPageReference().getParameters().put('parentRecordId', String.ValueOf(accList[0].Id)); 
        System.currentPageReference().getParameters().put('objectType', 'Contact');
        System.currentPageReference().getParameters().put('sourceScreen', 'ReferenceRequest'); 
        System.currentPageReference().getParameters().put('rowNumber', '1');
        
        CustomLookupController ctrl1 = new CustomLookupController();
        ctrl1.search();
        ctrl1.getFormTag();
        ctrl1.getTextBox();
        ctrl1.clearSearchResults();
        
        system.assertEquals('Test Contact',ctrl1.searchString);
        system.assertEquals('Contact',ctrl1.objectType);
        system.assertEquals('ReferenceRequest',ctrl1.sourceScreen); 
        system.assertEquals('1',ctrl1.rowNumber); 
        system.assertEquals(false,ctrl1.isAnyListPopulated);
        
        test.stopTest();
    }
    
    @isTest
    static void Test_CustomLookupContrlWithoutSearchString(){
        
        List<Account> accList = [Select Id from Account];
        test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.CustomLookup')); 
        System.currentPageReference().getParameters().put('lksrch', '');
        System.currentPageReference().getParameters().put('parentRecordId', String.ValueOf(accList[0].Id)); 
        System.currentPageReference().getParameters().put('objectType', 'Contact');
        System.currentPageReference().getParameters().put('sourceScreen', 'ReferenceRequest'); 
        System.currentPageReference().getParameters().put('rowNumber', '1');
        
        CustomLookupController ctrl = new CustomLookupController();
        ctrl.search();
        ctrl.getFormTag();
        ctrl.getTextBox();
        ctrl.clearSearchResults();
        
        system.assertEquals('',ctrl.searchString);
        system.assertEquals('Contact',ctrl.objectType);
        system.assertEquals('ReferenceRequest',ctrl.sourceScreen); 
        system.assertEquals('1',ctrl.rowNumber); 
        system.assertEquals(false,ctrl.isAnyListPopulated);
        
        test.stopTest();
    }
    
    
    @isTest
    static void Test_CustomLookupContrlmethod(){
    
     List<Account> accList = [Select Id from Account];
      test.startTest();
       Test.setCurrentPageReference(new PageReference('Page.CustomLookup')); 
        System.currentPageReference().getParameters().put('lksrch', 'Test Account');
        System.currentPageReference().getParameters().put('parentRecordId', String.ValueOf(accList[0].Id)); 
        System.currentPageReference().getParameters().put('objectType', 'Account');
        System.currentPageReference().getParameters().put('sourceScreen', 'ReferenceRequest'); 
        System.currentPageReference().getParameters().put('rowNumber', '1');
        
        CustomLookupController ctrl = new CustomLookupController();
        ctrl.search();
        ctrl.getFormTag();
        ctrl.getTextBox();
        ctrl.clearSearchResults();
        
        system.assertEquals('Test Account',ctrl.searchString);
        system.assertEquals('Account',ctrl.objectType);
        system.assertEquals('ReferenceRequest',ctrl.sourceScreen); 
        system.assertEquals('1',ctrl.rowNumber); 
        system.assertEquals(false,ctrl.isAnyListPopulated);
        
        Test.stopTest();
    }
    
}