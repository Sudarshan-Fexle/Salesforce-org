@isTest
public class Test_Batch_OppUpdateCTAssManagerEmail {
	
    /**
     * Purpose         :   Test Class is written for code coverage Batch_OppUpdateCTAssManagerEmailData Class
     * 
     * Created By      :   Dipesh Gupta
     * 
     * Created Date    :   12/09/2019
     * 
     * Revision Log    :   V_1.1 Created
     * 
     * @description    :   Create some test users related to opportunities, update the user's manager and verify the CT Assignment's Manager email field is updated on the opportunity.
     * 
     **/
    private static testMethod void testManagerUpdate() {
        
        //Get profile list
        List<Profile> testProfile = [Select Id, Name from Profile where Name = 'System Administrator'];
        
        //Assert for results
        System.assert(testProfile.size()>0);
        
        //Test User Create
        List<User> userList = new List<User>();
        
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User1', FirstName='Test1', Email='testuser1@test.com',
                              Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                              timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User2', FirstName='Test2', Email='testuser2@test.com',
                              Alias='Test2', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                              timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User3', FirstName='Test3', Email='testuser3@test.com',
                              Alias='Test3', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                              timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '121232412', IsActive = true));
        
        //Insert users
        insert userList;
        
        //Update first user Manager lookup to second user
        userList[0].ManagerId = userList[1].Id;
        userList[1].ManagerId = userList[2].Id;
        update userList;
        
		Util.BypassAllTriggers = true;
		
        //bypass triggers and insert opportunity
        Opportunity opportunity1 = testUtilities.CreateNewOpportunity(false);
        Opportunity opportunity2 = testUtilities.CreateNewOpportunity(false);
        opportunity1.CT_Assignment__c = userList[0].Id;
        opportunity2.CT_Assignment__c = userList[1].Id;
        list<Opportunity> opportunities = new list<Opportunity> { opportunity1, opportunity2 };
        insert opportunities;
        
        for (Opportunity o : opportunities) o.CT_Assignment_s_Manager__c = null;
        update opportunities;
        util.BypassAllTriggers = false;
        
        //Query to retrive "CT Assignment Manager Email" field from Opportunity record
        List<Opportunity> oppList = [SELECT ID, CT_Assignment_s_Manager__c FROM Opportunity WHERE Id IN :opportunities];
        
        //Assert for the result
        System.assertEquals(2, oppList.size());
        System.assertEquals(null, oppList[0].CT_Assignment_s_Manager__c, 'triggers were bypassed, so the CT Assignment manager email should be null.');
        System.assertEquals(null, oppList[1].CT_Assignment_s_Manager__c, 'triggers were bypassed, so the CT Assignment manager email should be null.');
        
        //execute the batch
        test.startTest();
        database.executeBatch(new Batch_OppUpdateCTAssManagerEmailData(new set<Id> { userList[0].Id, userList[1].Id, userList[2].Id }));
        test.stopTest();
        
        //Query to retrive "Owner Manager Email" field from Opportunity record
        oppList = [SELECT ID, CT_Assignment_s_Manager__c FROM Opportunity WHERE Id IN :opportunities];
        
        //Assert for the result
        System.assertEquals('testuser2@test.com', oppList[0].CT_Assignment_s_Manager__c);
        System.assertEquals('testuser3@test.com', oppList[1].CT_Assignment_s_Manager__c);
        
    }
    
}