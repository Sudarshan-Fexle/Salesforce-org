/**
Desription      :   Test class for EABLeadTriggerHelper

Created By      :   Neha Sharma 

Created Date    :   02/05/2021

Revision Logs   :   v1 - Created - Neha Sharma - CR-20201204-14721
		    v2 - Modified By - Nikita Kumari - 07/28/2021 - CR-20210316-15000 - Add 1EAB Leads to Contact Roles
**/ 
@istest(seeAllData=false)
public class Test_EABLeadTriggerHelper {

    static testmethod void test_createproductLead(){
         //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
       
        //List of Program
        List<Program__c> programs = new List<Program__c>();
        
        //Add new Programs in list
        programs.add(new Program__c(Name = 'Test Program 1', Status__c = 'Active',Marketable__c = true));
        programs.add(new Program__c(Name = 'Test Program 2', Status__c = 'Active',Marketable__c = true));
      
        //Insert
        insert programs;
        
        //Create restricted accounts
        List<Account> accounts = new List<Account>();
        
        //Added records in list 
        accounts.add(new Account(Name = 'account 1'));
        accounts.add(new Account(Name = 'account 2'));
        
        //Insert 
        insert accounts;
        
        //Retreiving "External" Record type for Contact object
        RecordType externalRecordType = [SELECT ID, DeveloperName FROM RecordType 
                                         WHERE SobjectType = 'Contact' AND IsActive = true 
                                         AND DeveloperName = 'External' LIMIT 1];
        
        // List to store test Contacts
        List<Contact> contacts = new List<Contact>();
        
        //Add contact data in list
        contacts.add(new Contact(accountid = accounts[0].id , Lastname = 'contact 1', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Active', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(accountid = accounts[1].id , Lastname = 'contact 2', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Active', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
       
       
        //Insert Contact Data
        insert contacts;
        
        List<Product_Lead__c> productLeadList = new List<Product_Lead__c>();
        productLeadList.add(new product_lead__c (Name = 'Test1',Contact__c = contacts[0].Id,Program__c = programs[0].Id,Stage__c = 'Inquiry'));
        //productLeadList.add(new product_lead__c (Name = 'Test1',Contact__c = contacts[1].Id,Program__c = programs[1].Id,Stage__c = 'Inquiry'));
        
        insert productLeadList;
        
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = false;
        
        List<X1EAB_Lead__c> eabLeadList = new List<X1EAB_Lead__c>();
        eabLeadList.add(new X1EAB_Lead__c(Name = 'Test1', Contact__c = contacts[0].Id,Primary_Program__c =programs[0].Id,
                                          PDE_Assignment__c= UserInfo.getUserId(), PDR_PDA_Assignment__c = UserInfo.getUserId(), 
                                          Primary_Lead_Passer__c = UserInfo.getUserId(), Product_Lead__c = productLeadList[0].Id));
        eabLeadList.add(new X1EAB_Lead__c(Name = 'Test1', Contact__c = contacts[1].Id,Primary_Program__c =programs[1].Id,
                                          PDE_Assignment__c= UserInfo.getUserId(), PDR_PDA_Assignment__c = UserInfo.getUserId(), 
                                          Primary_Lead_Passer__c = UserInfo.getUserId(), Product_Lead__c = productLeadList[0].Id));
        
        insert eabLeadList;
        
        test.startTest();
        
        List<X1EAB_Lead__c> eLeadList = [Select Id,Product_Lead__c from X1EAB_Lead__c];
        system.assert(eLeadList[0].Product_Lead__c != null);
        system.assert(eLeadList[1].Product_Lead__c != null);
        
       List<Product_Lead__c> newProductLead = [Select Id from product_Lead__c];
       system.assertEquals(2,newProductLead.size());
        
        test.stopTest();   
    }
    
    static testmethod void test_createLeadPasser(){
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //List of Program
        List<Program__c> programs = new List<Program__c>();
        
        //Add new Programs in list
        programs.add(new Program__c(Name = 'Test Program 1', Status__c = 'Active',Marketable__c = true));
        programs.add(new Program__c(Name = 'Test Program 2', Status__c = 'Active',Marketable__c = true));
        
        //Insert
        insert programs;
        
        //Create restricted accounts
        List<Account> accounts = new List<Account>();
        
        //Added records in list 
        accounts.add(new Account(Name = 'account 1'));
        accounts.add(new Account(Name = 'account 2'));
               
        //Insert 
        insert accounts;
        
        //Retreiving "External" Record type for Contact object
        RecordType externalRecordType = [SELECT ID, DeveloperName FROM RecordType 
                                         WHERE SobjectType = 'Contact' AND IsActive = true 
                                         AND DeveloperName = 'External' LIMIT 1];
        
        // List to store test Contacts
        List<Contact> contacts = new List<Contact>();
        
        //Add contact data in list
        contacts.add(new Contact(accountid = accounts[0].id , Lastname = 'contact 1', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Active', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(accountid = accounts[1].id , Lastname = 'contact 2', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Active', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
              
        //Insert Contact Data
        insert contacts;
        
        List<Product_Lead__c> productLeadList = new List<Product_Lead__c>();
        productLeadList.add(new product_lead__c (Name = 'Test1',Contact__c = contacts[0].Id,Program__c = programs[0].Id,Stage__c = 'Inquiry'));
        productLeadList.add(new product_lead__c (Name = 'Test1',Contact__c = contacts[1].Id,Program__c = programs[1].Id,Stage__c = 'Inquiry'));
        
        insert productLeadList;
       
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = false;
        test.startTest();
        List<X1EAB_Lead__c> eabLeadList = new List<X1EAB_Lead__c>();
        eabLeadList.add(new X1EAB_Lead__c(Name = 'Test1', Contact__c = contacts[0].Id,Primary_Program__c =programs[0].Id,
                                          PDE_Assignment__c= UserInfo.getUserId(), PDR_PDA_Assignment__c = UserInfo.getUserId(), 
                                          Primary_Lead_Passer__c = UserInfo.getUserId()));
        eabLeadList.add(new X1EAB_Lead__c(Name = 'Test1', Contact__c = contacts[1].Id,Primary_Program__c =programs[1].Id,
                                          PDE_Assignment__c= UserInfo.getUserId(), PDR_PDA_Assignment__c = UserInfo.getUserId(), 
                                          Primary_Lead_Passer__c = UserInfo.getUserId()));
       
        insert eabLeadList;
        
         test.stopTest();         
        
         
    }
    
    //Added By - Nikita Kumari - 07/28/2021 - CR-20210316-15000 - Add 1EAB Leads to Contact Roles
    static testmethod void test_updateEABContactOnOppContactRole(){
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //List of Program
        List<Program__c> programs = new List<Program__c>();
        
        //Add new Programs in list
        programs.add(new Program__c(Name = 'Test Program 1', Status__c = 'Active',Marketable__c = true));
        programs.add(new Program__c(Name = 'Test Program 2', Status__c = 'Active',Marketable__c = true));
        
        //Insert
        insert programs;
        
        //Create restricted accounts
        List<Account> accounts = new List<Account>();
        
        //Added records in list 
        accounts.add(new Account(Name = 'account 1'));
        accounts.add(new Account(Name = 'account 2'));
               
        //Insert 
        insert accounts;
        
        //Retreiving "External" Record type for Contact object
        RecordType externalRecordType = [SELECT ID, DeveloperName FROM RecordType 
                                         WHERE SobjectType = 'Contact' AND IsActive = true 
                                         AND DeveloperName = 'External' LIMIT 1];
        
        //create Opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        
        opportunities.add(TestUtilities.CreateNewOpportunity(accounts[0].id, false));
        opportunities.add(TestUtilities.CreateNewOpportunity(accounts[1].id, false));
          
        //Insert Opportunity Data
        insert opportunities;
        
        List<Product_Lead__c> productLeadList = new List<Product_Lead__c>();
        productLeadList.add(new product_lead__c (Name = 'Test1',Contact__c = opportunities[0].Main_Contact__c, Program__c = programs[0].Id,Stage__c = 'Inquiry'));
        productLeadList.add(new product_lead__c (Name = 'Test1',Contact__c = opportunities[1].Main_Contact__c, Program__c = programs[1].Id,Stage__c = 'Inquiry'));
        
        insert productLeadList;
       
        List<X1EAB_Lead__c> eabLeadList = new List<X1EAB_Lead__c>();
        eabLeadList.add(new X1EAB_Lead__c(Name = 'Test1', Contact__c = opportunities[0].Main_Contact__c,Primary_Program__c =programs[0].Id,
                                          PDE_Assignment__c= UserInfo.getUserId(), PDR_PDA_Assignment__c = UserInfo.getUserId(), 
                                          Primary_Lead_Passer__c = UserInfo.getUserId(), Opportunity__c = opportunities[0].Id));
        eabLeadList.add(new X1EAB_Lead__c(Name = 'Test1', Contact__c = opportunities[1].Main_Contact__c,Primary_Program__c =programs[1].Id,
                                          PDE_Assignment__c= UserInfo.getUserId(), PDR_PDA_Assignment__c = UserInfo.getUserId(), 
                                          Primary_Lead_Passer__c = UserInfo.getUserId(), Opportunity__c = opportunities[1].Id));
       
        insert eabLeadList;
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = false;
        
        test.startTest();
        
        //update Opportunities
        eabLeadList[0].Opportunity__c = opportunities[1].Id;
        eabLeadList[1].Opportunity__c = opportunities[0].Id;
        Update eabLeadList;
        
        List<OpportunityContactRole> oppContRoles = [SELECT Id, ContactId, OpportunityId From OpportunityContactRole 
                                                     Where (ContactId =: opportunities[0].Main_Contact__c OR ContactId =: opportunities[1].Main_Contact__c)
                                                     And OpportunityId IN :opportunities];
        
        System.assertEquals(2, oppContRoles.size());
        System.assertEquals(eabLeadList[0].Opportunity__c, oppContRoles[1].OpportunityId);
        System.assertEquals(eabLeadList[1].Opportunity__c, oppContRoles[0].OpportunityId);
        System.assertEquals(eabLeadList[0].Contact__c, oppContRoles[1].ContactId);
        System.assertEquals(eabLeadList[1].Contact__c, oppContRoles[0].ContactId);
        
        //update Contact
        eabLeadList[0].Contact__c = opportunities[1].Main_Contact__c;
        eabLeadList[1].Contact__c = opportunities[0].Main_Contact__c;
        Update eabLeadList;
        
        oppContRoles = [SELECT Id, ContactId, OpportunityId From OpportunityContactRole 
                        Where (ContactId =: opportunities[0].Main_Contact__c OR ContactId =: opportunities[1].Main_Contact__c)
                        And OpportunityId IN :opportunities];
        
        System.assertEquals(2, oppContRoles.size());
        System.assertEquals(eabLeadList[0].Contact__c, oppContRoles[1].ContactId);
        System.assertEquals(eabLeadList[1].Contact__c, oppContRoles[0].ContactId);
        
        //update Opportunities
        eabLeadList[0].Opportunity__c = null;
        Update eabLeadList;
        
        oppContRoles = [SELECT Id, ContactId, OpportunityId From OpportunityContactRole 
                        Where (ContactId =: opportunities[0].Main_Contact__c OR ContactId =: opportunities[1].Main_Contact__c)
                        And OpportunityId IN :opportunities];
        
        System.assertEquals(1, oppContRoles.size());
        System.assertEquals(eabLeadList[1].Opportunity__c, oppContRoles[0].OpportunityId);
        
        test.stopTest();         
        
         
    }
}