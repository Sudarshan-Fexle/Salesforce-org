/**
 *  Description     :  	To Check the Functionality of Trigger Feed Items
 *  
 *  Created By      :  	Ayush Gupta
 *  
 *  Created Date    :   05/07/2018
 *  
 *  Revision Logs   :   V_1.0 - Created - CR-20211022-15544
 *                   
**/ 
@istest(SeeAllData = true)
public class Test_triggerFeedItemOOOAutoResponder {
    
    testmethod static void myUnitTest() 
    {        
        //Customer Community User System Administrator 
        User us = [Select id from USER where Profile.Name = 'System Administrator' and isactive = true limit 1];
        system.runas(us)
        {
            //Query on the Record Type
            List<RecordType> rdType = [SELECT ID FROM RecordType Where sObjectType = 'Case' AND IsActive = true 
                                       AND DeveloperName = 'Starfish'];
            
             //Creating Account and Contact
            Account acc = TestUtilities.CreateNewAccount(true);
            Contact con = TestUtilities.CreateNewContact(true);
            
            //List to hold the case records
            List<Case> cases = new List<Case>();
            
            //Create a sample case record to insert and test case trigger
            Case aCase = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', Subject = 'out of office', 
                                  AccountId = acc.Id, Status ='In Progress');
            insert aCase;
            
            Test.startTest();
            
            FeedItem f = new FeedItem();
            f.Body = 'legal test';
            f.parentID = aCase.Id;             
            insert f;
            FeedComment fc = new FeedComment(FeedItemId = f.Id, CommentBody = 'Test Comment');
            insert fc;
            
            Test.StopTest();
        }
    }
}