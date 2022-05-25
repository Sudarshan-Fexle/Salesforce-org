/**
 * 
 * @description: Test methods for the ChatterHelper class.  @SeeAllData=true must be active for any methods that use the ConnectAPI.  
 * The number of test methods has been reduced to 1 because it decreases the execution time.  Having 3 separate methods that all use @SeeAllData=true adds a lot of time to the execution.
 * 
 * @revisions: 	1) Created
 * 				2) Modified - Victor Hanson - 8/21/15 - Combined tests to a single method, moved @SeeAllData to the method level to improve performance.
 * 
 **/
@isTest
private class ChatterHelper_Test{
    
    /**
     * 
     * @description: This tests three different scenarios:
     * 					1) CreatePost_TestWithMentions: 3 users created, user(0) has OOO setup.  Create Chatter post that @mentions all users, including the one with OOO -> Verify a new chatter is generated with the OOO message
     * 					2) CreateComment_TestWithMentions: 3 users created, user(0) has OOO setup.  Create Chatter comment that @mentions all users, including the one with OOO -> Verify a new chatter is generated with the OOO message
     * 					3) CreatePost_TestWithoutMention: 3 users created, no users have OOO setup.  Create Chatter comment that @mentions all users, including the one with OOO -> Verify the chatter is generated with the OOO message
     * 
     **/
    @isTest(SeeAllData=true)
    static void CreatePost_TestWithMentions(){
        List<User> users = CreateTestUsers('User_T1', 3, 1);
        List<Id> userIds = new List<Id>();
        userIds.add(users.get(0).Id);
        userIds.add(users.get(1).Id);
        
test.startTest();
        system.debug('##runas user: ' + users.get(2).Id);
        System.runAs(users.get(2)) {
            ConnectApi.FeedItem feed = ChatterHelper.PostChatterFeedItem(ConnectApi.FeedType.News,
                                                                         'me', 'This is a test!', userIds);
            Out_Of_Office_Comment__c comment = [SELECT UserId__c, Comment__c
                                                FROM Out_Of_Office_Comment__c WHERE Feed__c = :feed.Id];
            system.debug('##comment: ' + comment);
            system.assertEquals(comment.UserId__c, users.get(0).Id);
            system.assert(comment.Comment__c.contains('PTO0'));
            
            //CreateComment_TestWithMentions
            feed = ChatterHelper.PostChatterFeedItem(ConnectApi.FeedType.News,
                                                     'me', 'This is a test!', null);
            ConnectApi.Comment feedComment = ChatterHelper.PostChatterCommentItem(feed.Id, 'This is a test!', userIds);
            comment = [SELECT UserId__c, Comment__c
                       FROM Out_Of_Office_Comment__c WHERE Feed__c = :feed.Id];
            system.debug('##comment: ' + comment);
            system.assertEquals(comment.UserId__c, users.get(0).Id);
            system.assert(comment.Comment__c.contains('PTO0'));
            
            //CreatePost_TestWithoutMention -- remove OOO from user
            for (User u : users) {
                if (u.Out_of_Office_Start_Date__c != null) {
                    u.Out_of_Office_Start_Date__c = null;
                    u.Out_of_Office_Message__c = null;
                    update u;
                }
            }
            ConnectApi.FeedItem feed2 = ChatterHelper.PostChatterFeedItem(ConnectApi.FeedType.News,
                                                                          'me', 'This is a test!', userIds);
            List<Out_Of_Office_Comment__c> comments = [SELECT UserId__c, Comment__c
                                                       FROM Out_Of_Office_Comment__c WHERE Feed__c = :feed2.Id];
            system.assertEquals(0, comments.size());
        }
test.stopTest();
    }
    
    /**
     * 
     * @description: create test users with or without out of office setup
     * 
     **/
    static List<User> CreateTestUsers(String prefix, Integer totalCount, Integer oooCount) {
        Profile p = [select id from profile where name='System Administrator'];
        
        List<User> users = new List<User>();
        for(Integer i=0; i<totalCount; i++) {
            User user = TestUtilities.CreateNewUser(p, false);
            user.alias = prefix + i;
            
            if(i<oooCount) {
                user.Out_of_Office_Start_Date__c = Date.today();
                user.Out_of_Office_Message__c = 'PTO' + i;
            }
            users.add(user);
            system.debug('##Test User: ' + user.Id + ' => ' + user.Out_of_Office_Message__c);
        }
        
        insert users;
        return users;
    }
}