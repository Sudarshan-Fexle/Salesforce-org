/**
* 
* Desription      :   	test methods for the Batch_ConvertNotesToContentNotes class
* 
* Revision Logs   :    
* 
* 
**/
@isTest(seeAllData = false)
public class Test_Batch_ConvertNotesToContentNotes  {
    
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
        
        
        //Query on Profile
        Profile profile1 = [Select Id, Name From Profile Where name = 'Standard User' LIMIT 1];
        
        // hold User
       List<User> usrList = new List<User>();
        usrList.add(new User(LastName = 'testnn1',
                           FirstName='testnning1',
                           Alias = 'tenf',
                           Email = 'wwetest@asdf.com',
                           Username = 'wwetesting@asdf.com',
                           ProfileId = profile1.id,
                           IsActive = true,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           ));
        usrList.add(new User(LastName = 'teftrfst2',
                           FirstName='testiffgng2',
                           Alias = 'dfgt2',
                           Email = 'tewwsst@addf.com',
                           Username = 'tdfwesting@asdf.com',
                           ProfileId = profile1.id,
                           IsActive = true,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           ));
        usrList.add(new User(LastName = 'teffrsst2',
                           FirstName='testifgsdng2',
                           Alias = 'sfgst2',
                           Email = 'frttest@asdf.com',
                           Username = 'teftrsting@asdf.com',
                           ProfileId = profile1.id,
                           IsActive = true,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           ));
        
        //Insert User
        insert usrList;
        
        List<user> userList = [Select Id From user];
        System.assert(userList[0].Id != null);
        System.assert(userList.size() > 0);
        
        // add Account
        List<Account> accList = new List<Account>();
        for(integer i = 0; i<10 ; i++)
        {
            Account acc = new Account ();
            acc.Name = 'TestAccount';
            acc.CurrencyIsoCode = 'USD';
            accList.add(acc);
        }
        
        if(accList != null && accList.size() > 0)
        {
            insert accList;
        }
        
        List<Account> listOfAccount = [Select Id From Account];
        System.assert(listOfAccount.size() == 10);
        
        
        // Add Note
        List<Note> listOfNote = new List<Note>();
        Integer cn = 1;
        for(Account acc : listOfAccount)
        {
            Note oNote = new Note();
            oNote.Title ='my acc note'+ cn;
            oNote.Body = 'test note body \n thanks '+ cn;
            oNote.ParentId = acc.Id;
            listOfNote.add(oNote);
        }
        
        if(listOfNote != null && listOfNote.size() > 0 )
        {
            insert listOfNote;
        }
        
        List<Note> noteList = [Select Id From Note];
        System.assert(noteList.size() == 10);
    }
    
/**
* 
* @description: test batch 
* 
**/
    static testMethod void test_Batch()
    {
        //Bypass DupeBlocker and triggers for test data creation
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        //V1.2
        Util.ByPassDLRSForTest = true;
        List<String> listOfObjApiName = new List<String>();
        listOfObjApiName.add('Account');
        
        List<Note> listOfNotes = [SELECT Id, Title, Body, ParentId, OwnerId FROM Note WHERE ParentId != null];
      	
        test.startTest();
        Batch_ConvertNotesToContentNotes batch = new Batch_ConvertNotesToContentNotes(null,listOfObjApiName);
        database.batchablecontext bd ;
        batch.start(bd);
        batch.execute(bd, listOfNotes);
        batch.finish(bd);    
        
        test.stopTest();
        
        
    }

}