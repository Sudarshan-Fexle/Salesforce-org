/**
*  Purpose         :  Test class for sdgMapper
*               
*  Created By      :  Mahendra Swarnakar
*   
*  Created Date    :  6/14/2020 
*   
*  Revision Log    :   v1.0  
*                       
*  Coverage        :   100%
**/
@isTest
private with sharing class Test_SP_sCollection {
    
    @isTest
    static void testSCollection(){
        
        
        Util.IsTest(true);

        Util.BypassAllTriggers = true;

        list<Account> accs = new list<Account>();
        list<Contact> cons = new list<Contact>();
        
        Account acct = TestUtilities.CreateNewAccount(false);
        acct.AccountNumber = '01';
        acct.Name = 'Test Account 1';
        acct.Description = 'Test Description 1';
        accs.add(acct);

        Account acct2 = TestUtilities.CreateNewAccount(false);
        acct2.AccountNumber = '02';
        acct2.Name = 'Test Account 2';
        acct2.Description = 'Test Description 2';
        accs.add(acct2);
            

        list<Id> accIds = new list<Id>();
        for(Database.SaveResult res:database.insert(accs)){
            if(res.isSuccess()){
                accIds.add(res.getId());
            }
        }
        for(Id accId:accIds){
      Contact con = new Contact(
              LastName = 'Dipesh Gupta 1111', AccountId = accId, Email = 'Test1'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
            cons.add(con);
        }
        list<Id> conIds = new list<Id>();
        for(Database.SaveResult res:database.insert(cons)){
            if(res.isSuccess()){
                conIds.add(res.getId());
            }
        }
           
        Test.StartTest();
    
        map<String, sObject> accMap = SP_sCollection.stringMap(accs,Account.AccountNumber);

        system.assert(accMap != null);
        system.assert(accMap.keySet().contains('01'));
        Account acctM = (Account)accMap.get('01');
        system.assertEquals('Test Account 1', acctM.get('Name'));
        
        list<sObject> accList = SP_sCollection.sortByString(accMap);
        system.assert(accList.size() > 0);
        Account a;

        for(integer i=1;i < accList.size();i++){
            a = (Account) accList[i-1];
            System.assertEquals(a.AccountNumber,i<10 ? '0' + String.valueOf(i) : String.valueOf(i));
        }
          
        Map<Id, SObject> acctMap  = new Map<Id, SObject>();

        acctMap = SP_sCollection.idMap(cons,Contact.AccountId);

        system.assert(acctMap != null);
        system.assert(acctMap.keySet().contains(acct.Id));
        Contact conta = (Contact)acctMap.get(acct.Id);
        system.assertEquals('Dipesh Gupta 1111' , conta.get('LastName'));

        acctMap = SP_sCollection.idMap(cons,'AccountId');

        system.assert(acctMap != null);
        system.assert(acctMap.keySet().contains(acct.Id));

        Contact conta1 = (Contact)acctMap.get(acct.Id);
        system.assertEquals('Dipesh Gupta 1111' , conta1.get('LastName'));

        Map<String, SObject> acctMapS  = new Map<String, SObject>();
        acctMapS = SP_sCollection.stringMap(cons,Contact.name);
        
        system.assert(acctMap != null);
        system.assert(acctMap.keySet().contains(acct.Id));
        Contact conta2 = (Contact)acctMap.get(acct.Id);
        system.assertEquals('Dipesh Gupta 1111' , conta2.get('LastName'));

        acctMapS = SP_sCollection.stringMap(cons,'name');
        
        system.assert(acctMap != null);
        system.assert(acctMap.keySet().contains(acct.Id));
        Contact conta3 = (Contact)acctMap.get(acct.Id);
        system.assertEquals('Dipesh Gupta 1111' , conta3.get('LastName'));
            
        Set<Id> setOfAcctId = new Set<ID>();
        setOfAcctId = SP_sCollection.idSet(cons,Contact.AccountId);

        system.assert(setOfAcctId != null);
        system.assert(setOfAcctId.contains(acct.Id));

        setOfAcctId = SP_sCollection.idSet(cons,'AccountId');
        system.assert(setOfAcctId != null);
        system.assert(setOfAcctId.contains(acct.Id));
            
        Set<String> setOfFieldValue = new Set<String>();
        
        setOfFieldValue = SP_sCollection.stringSet(cons,Contact.name);
        
        system.assertEquals(new Set<String>{null} , setOfFieldValue);
        setOfFieldValue = SP_sCollection.stringSet(cons,'name');
        system.assertEquals(new Set<String>{null} , setOfFieldValue);
               
        map<id,list<sObject>> conIdMap = SP_sCollection.idListMap(cons,Contact.AccountId);

        system.assert(conIdMap != null);
        system.assert(conIdMap.keySet().size() > 0);
        system.assert(conIdMap.keySet().contains(acct.Id));
        system.assert(conIdMap.get(acct.Id).size() > 0);
        Contact conta4 = (Contact)conIdMap.get(acct.Id)[0];
        system.assertEquals('Dipesh Gupta 1111' ,conta4.get('LastName'));

        conIdMap = SP_sCollection.idListMap(cons,'AccountId');

        map<String,list<sObject>> conStringMap = SP_sCollection.stringListMap(cons,Contact.name);
        conStringMap = SP_sCollection.stringListMap(cons,'name');
        
        List<SObject> listOfSobjects = new List<SObject>();
        listOfSobjects = SP_sCollection.puts(accs,Account.Name,'Override Test Account');

        Account acctM3 = (Account)listOfSobjects[0];
        system.assertEquals('Override Test Account', acctM3.get('Name'));

        listOfSobjects = SP_sCollection.puts(accs,Account.Name,new list<String>{'List Override Test Account 1','List Override Test Account 2'});

        Account acctM1 = (Account)listOfSobjects[0];
        Account acctM2 = (Account)listOfSobjects[1];
        system.assertEquals('List Override Test Account 1', acctM1.get('Name'));
        system.assertEquals('List Override Test Account 2', acctM2.get('Name'));

        listOfSobjects = SP_sCollection.flatten(conIdMap);

        system.assert(listOfSobjects != null);
        system.assert(listOfSobjects.size() > 0);

        listOfSobjects = SP_sCollection.flatten(conStringMap);
        system.assert(listOfSobjects != null);
        system.assert(listOfSobjects.size() > 0);
          
        Test.StopTest();
  }
}