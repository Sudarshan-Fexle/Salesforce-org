@isTest
Private class SandboxSetupTest {
	
    public static Group sandboxAdminGroup { get; set; }
    public static User testUser { get; set; }
    public static final String scrambledEmail = 'testuser123=eab.com@example.com';
    public static final String updatedEmail = 'testuser123@eab.com';
    
    @testSetup
    static void setupTestData() {
	
		List<Profile> p = [Select Id From Profile Where Name = 'System Administrator'];
		
        List<User> users = new List<User>();
        
        //add a user to the email update queue
        testUser = TestUtilities.CreateNewUser(p[0], false);
        testUser.Email = scrambledEmail;
        users.add(testUser);

        //add a user to the email update queue
        User testUser1 = TestUtilities.CreateNewUser(p[0], false);
        testUser1.Email = 'test2019@test.com.invalid';
        users.add(testUser1);
 
        insert users;
        
        //get the public group that updates user emails post-refresh
        sandboxAdminGroup = [SELECT Id FROM Group WHERE DeveloperName = :Label.Sandbox_Refresh_Group_Name];
        GroupMember newMember= new GroupMember(GroupId = sandboxAdminGroup.Id,
                                               UserOrGroupId = testUser.Id);
        insert newMember;
        
        GroupMember newMember2= new GroupMember(GroupId = sandboxAdminGroup.Id,
                                               UserOrGroupId = testUser1.Id);
        
        insert newMember2;
    }
    
    static testmethod void testSandboxSetup() {
        
        Test.startTest();

        Test.testSandboxPostCopyScript(
            new SandboxSetup(), UserInfo.getOrganizationId(),
                UserInfo.getOrganizationId(), UserInfo.getOrganizationName());

        Test.stopTest();

        //get the user info
        system.assertEquals(1, [SELECT Id, Email FROM User WHERE Email = :updatedEmail].size());
        system.debug('users'+[SELECT Id, Email FROM User where Email like '%test2019%']);
		system.assertEquals(1, [SELECT Id, Email FROM User WHERE Email = 'test2019@test.com'].size());
    }
}