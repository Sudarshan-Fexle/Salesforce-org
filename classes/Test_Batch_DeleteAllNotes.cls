/**
* 
* Desription      :   	test methods for the Batch_DeleteAllNotes class
* 
* Revision Logs   :    
* 
* 
**/
@isTest(seeAllData = false)
public class Test_Batch_DeleteAllNotes {
    
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
      	
        List<Note> noteListBeforeDelete = [Select Id From Note];
        System.assertEquals(10, noteListBeforeDelete.size());
            
        test.startTest();
        Batch_DeleteAllNotes batch = new Batch_DeleteAllNotes();
        Database.executeBatch(batch);
        test.stopTest();
        
        List<Note> noteListAfterDelete = [Select Id From Note];
        System.assertEquals(0, noteListAfterDelete.size());
    }

}