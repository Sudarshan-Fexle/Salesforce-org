/**
 * Purpose          :   Test class for NewUserController
 * 
 * CreatedDate      :   10-May-2021
 * 
 * RevisionLog      :   V_1.0 - Created - Ayush Gupta
 *
 * Code Coverage    :   
**/

@isTest
public class NewUserControllerTest{

    public static testmethod void testNewUserController(){
      
      test.starttest();
      
      /* -------------query profile ----------------*/    
      Profile p = [select Id,name from Profile where name = 'Overage High Volume Customer Portal User']; 
      /* -------------query profile ----------------*/

      /* -------------Create new Account ----------------*/
      Account acct_1 = TestUtilities.CreateNewAccount(false);
      acct_1.Description = 'Testing RIAMLargeContract Testing';
      /* -------------Create new Account ----------------*/
    
      /* -------------Create new contact  ----------------*/
        Contact con = new Contact(lastname='Test',email='hm@abc.com');
        List<Contact> contacts = new List<Contact>();
        // create a new contact
        Contact con_1 = TestUtilities.CreateNewContact(false);
        contacts.add(con_1);
        // create a new contact
        Contact con_2 = TestUtilities.CreateNewContact(false);
        contacts.add(con_2);
        insert contacts;

    /* -------------Create new user ----------------*/
    System.runAs ( new User(Id = UserInfo.getUserId()) ){
      User newUser = new User(
      profileId = p.id,
      username = 'TestReq@eab.community.com',
      email = 'abc@sakonent.com',
      emailencodingkey = 'UTF-8',
      localesidkey = 'en_US',
      languagelocalekey = 'en_US',
      timezonesidkey = 'America/Los_Angeles',
      CommunityNickname = 'Nick'+math.random(),
      alias= 'Comm',
      lastname='John',
      firstname='Test',
      contactId = contacts[0].Id
    );
    
    	insert newuser;
    }
    /* -------------Create new user ----------------*/      
      
    /* -------------Create new user request record ----------------*/
    Community_User_Request__c ComUserReq = new Community_User_Request__c();
    ComUserReq.user_name__c = 'TestReq@eab.community.com' ;
    ComUserReq.Email__c = 'TestingReq@abc.com';
    insert ComUserReq;
    /* -------------Create new user request record ----------------*/
        
    //create new user controller object
    NewUserController Ins = new NewUserController();
     
    Ins.FirstName = 'Murtaza';
    Ins.LastName = 'Ali';
    Ins.UserName = 'sak';
    Ins.PhoneNum = '12345';
    Ins.InsName = 'test';
    Ins.ClientId = '1234';
    Ins.CommUserReq.Email__c = 'hm@abc.com';
    
    Ins.SaveCommunityUserRequest();
    //ins.RedirectUser();
    /* ------------- UserName matched in approval request----------------*/
    
    test.stoptest();
  }
}