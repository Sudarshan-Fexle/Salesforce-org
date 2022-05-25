/**********************************************************
* @Author       Heidi Tang (heidi.a.tang@accenture.com)
* @Date         2016-04-25
* @Description  Test class for KeyPlayersTriggerHandler
* @Requirement  REQ-0482 Auto-populate Contact Roles with Key Players/Influencers value.
* @Version      - V1.0 - Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
**********************************************************/
@isTest
public with sharing class KeyPlayersTriggerHandlerTest {
    @testSetup static void testDataBuilder() {
        
        User internalUser = TestDataFactory.createInternalSysAdminUser('usertest@mediaocean.com','Testing','usertest@mediaocean.com','test123');
        insert internalUser;
        
        string recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royall').getRecordTypeId();
        
        System.runAs(internalUser){

            List<Account> acctList = TestDataFactory.createAcctList(4,'Test Account');
            insert acctList; 

            List<Contact> conList = TestDataFactory.createConList(4,'testCon');
            conList[0].AccountId = acctList[0].Id;
            conList[1].AccountId = acctList[1].Id;
            conList[0].AccountId = acctList[2].Id;
            conList[1].AccountId = acctList[3].Id;
            insert conList;
            
            //Modify By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c  
            //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
            Opportunity newOpp = new Opportunity(AccountId = acctList[2].Id,Sales_Pursuit_Products__c  = 'APS', Name='Test Opportunity',StageName= '1 - Plan', CloseDate=Date.today(), RecordTypeId = recordTypeId, Main_Contact__c = conList[0].Id);
            insert newOpp;
        }
    }
    
    public static testMethod void testInsert(){ 
        Test.startTest();
        
        User loginUser = [SELECT Id FROM User WHERE UserName='usertest@mediaocean.com' LIMIT 1 ];
        Opportunity newOpp = [SELECT Id FROM Opportunity LIMIT 1];
        List<Contact> contactList = new List<Contact>([SELECT Id FROM Contact LIMIT 5]);
        
        System.runAs(loginUser){
            
            OpportunityContactRole contactRole = new OpportunityContactRole(ContactId = contactList[1].Id,OpportunityId=newOpp.Id,Role='Operational');
            insert contactRole;
            
            List<Key_Players_Influencers__c> keyPlayerList = new List<Key_Players_Influencers__c>();
            keyPlayerList.addAll(TestDataFactory.createKeyInfluencer(4,'Administrative',newOpp.Id));
            keyPlayerList[0].Name__c = contactList[0].Id;
            keyPlayerList[1].Name__c = contactList[1].Id;
            keyPlayerList[2].Name__c = contactList[2].Id;
            keyPlayerList[3].Name__c = contactList[3].Id;

           
                insert keyPlayerList;

                List<OpportunityContactRole> contactRoleList = new List<OpportunityContactRole>([SELECT Id FROM OpportunityContactRole WHERE Role = 'Administrative']);
                System.assert(contactRoleList.size()>0);

                Boolean isError = false;
                
                keyPlayerList.addAll(TestDataFactory.createKeyInfluencer(4,'Administrative',newOpp.Id));
                keyPlayerList[4].Name__c = contactList[0].Id;
    
                try{
                    insert keyPlayerList;
                } catch(DmlException dmle){
                    isError = true;
                }
                
                System.assert(isError);
            Test.stopTest();
        }
    }
    
    public static testMethod void testUpdate(){  
        Test.startTest();
        User loginUser = [SELECT Id FROM User WHERE UserName='usertest@mediaocean.com' LIMIT 1 ];
        Opportunity newOpp = [SELECT Id FROM Opportunity LIMIT 1];
        List<Contact> contactList = new List<Contact>([SELECT Id FROM Contact LIMIT 5]);
        
        System.runAs(loginUser){
            
            OpportunityContactRole contactRole = new OpportunityContactRole(ContactId = contactList[1].Id,OpportunityId=newOpp.Id,Role='Operational');
            insert contactRole;
            
            List<Key_Players_Influencers__c> keyPlayerList = TestDataFactory.createKeyInfluencer(4,'Administrative',newOpp.Id);
            keyPlayerList[0].Name__c = contactList[0].Id;
            keyPlayerList[1].Name__c = contactList[1].Id;
            keyPlayerList[2].Name__c = contactList[2].Id;
            keyPlayerList[3].Name__c = contactList[3].Id;
            insert keyPlayerList;

           
                keyPlayerList[0].Formal_Role__c = 'Operational';
                keyPlayerList[1].Formal_Role__c = 'Operational';
                keyPlayerList[2].Formal_Role__c = 'Legal';
                keyPlayerList[3].Formal_Role__c = 'Technical';
                
                update keyPlayerList;

                List<OpportunityContactRole> contactRoleList = new List<OpportunityContactRole>([SELECT Id FROM OpportunityContactRole WHERE Role = 'Administrative']);
                
                System.assert(contactRoleList.size()==0);

                keyPlayerList[1].Formal_Role__c = 'Operational';
                update keyPlayerList;

                
                Boolean isError = false;
                
                try{
                    keyPlayerList[2].Name__c = contactList[0].Id;
                    update keyPlayerList;
                } catch(DmlException dmle){
                    isError = true;
                }
                
                System.assert(isError);
            Test.stopTest();
        }
    }
    
    public static testMethod void testDelete(){
         Test.startTest();
 
        User loginUser = [SELECT Id FROM User WHERE UserName='usertest@mediaocean.com' LIMIT 1 ];
        Opportunity newOpp = [SELECT Id FROM Opportunity LIMIT 1];
        List<Contact> contactList = new List<Contact>([SELECT Id FROM Contact LIMIT 5]);
        
        System.runAs(loginUser){
            
            OpportunityContactRole contactRole = new OpportunityContactRole(ContactId = contactList[1].Id,OpportunityId=newOpp.Id,Role=null);
            insert contactRole;
            
            List<Key_Players_Influencers__c> keyPlayerList = TestDataFactory.createKeyInfluencer(4,'Administrative',newOpp.Id);
            keyPlayerList[0].Name__c = contactList[0].Id;
            keyPlayerList[1].Name__c = contactList[1].Id;
            keyPlayerList[2].Name__c = contactList[2].Id;
            keyPlayerList[3].Name__c = contactList[3].Id;
            insert keyPlayerList;

           
                delete keyPlayerList;
                
                List<OpportunityContactRole> contactRoleList = new List<OpportunityContactRole>([SELECT Id FROM OpportunityContactRole WHERE Role = 'Administrative']);          
                
                System.assert(contactRoleList.size()==0);
                
            Test.stopTest();
        }
    }
}