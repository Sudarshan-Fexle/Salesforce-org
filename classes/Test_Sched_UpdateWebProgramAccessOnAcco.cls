/**
*	Description		:	The test class to test the functionalities of Sched_UpdateWebProgramAccessOnAccount class
*
*	Created by		:	Mahendra Swarnkar
* 
* 	Created Date	:	08/21/2019
* 
* 	Revision Log	:	V1.0 Created - CR-12685 (Created as per the production validation Error/exception).
*						Coverage - 84%
**/
@isTest(seeAllData = false)
public class Test_Sched_UpdateWebProgramAccessOnAcco {
	
    //Test Method
    static testMethod void unitTest(){
        
        //Bypass All Triggers
        Util.BypassAllTriggers = true;
        
        //Insert Accounts
        List<Account> listAccounts = new List<Account>();
        listAccounts.add(new Account(Name = 'Test1'));
        listAccounts.add(new Account(Name = 'Test2'));
        listAccounts.add(new Account(Name = 'Test3'));
        listAccounts.add(new Account(Name = 'Test4'));
        listAccounts.add(new Account(Name = 'Test5'));
        insert listAccounts;
        
        system.assertEquals(5, listAccounts.size());
        
        Set<Id> setAccountIds = new Set<Id>();
        for(Account acc : listAccounts){
            setAccountIds.add(acc.Id);
        }
        
        //Start testing from here
        Test.startTest();
        
        //Bypass All Triggers
        Util.BypassAllTriggers = false;
        
        //Call Queuable job from here, 
        //Sched_UpdateWebProgramAccessOnAccount.scheduleUpdateWebProgramAccessOnAccount(setAccountIds, setAccountIds);
        
        //Stop testing here
        Test.stopTest(); 
    }
}