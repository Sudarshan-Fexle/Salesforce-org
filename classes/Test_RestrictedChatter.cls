@isTest
public class Test_RestrictedChatter 
{
    static testMethod void Test_RestrictedChatter() 
    {
		// First, create the Public Group
		Group publicGroup = New Group(Name = 'Public Group 1', 
                                      DeveloperName = 'PubGroup1');
        insert publicGroup;
                                      
        // Next, create the Chatter Group
        CollaborationGroup restrictedGroup = New CollaborationGroup(Name = 'Chatter 1', 
                                                                   	CollaborationType = 'Public');
		insert restrictedGroup;
                                      
		// Next, create a restricted Custom Setting with auto-follow
		ChatterGroupManagement__c customSetting = New ChatterGroupManagement__c(Name = 'CS 1',
                                                                                ChatterGroupName__c = 'Chatter 1', 
                                                                                PublicGroupName__c = 'Public Group 1',
                                                                                Restricted__c = true);
		insert customSetting;
                                      
        // Identify a user
        User testUser = [Select	Id 
                         from 	User 
                         where 	Id !=: UserInfo.getUserId() AND
                         		IsActive = true AND
                         		UserType = 'Standard'
                         limit 	1];
		
        // Add one of those users to the Public Group
/*
        GroupMember publicGroupMember = New GroupMember(GroupID = publicGroup.ID, 
                                                        UserOrGroupID = testUser.ID);
        insert publicGroupMember;
*/
        // Set this to run as our test user
        System.runAs(testUser)
        {
            FeedItem newItem = New FeedItem(Body = 'Test Item1',
                                            ParentID = restrictedGroup.ID);
            try
            {
                insert newItem;

                System.assert(false);
            } catch(Exception e) 
            {
                System.assert(true);
            }
        }
    }        
        

    static testMethod void Test_AutoFollow()
    {
		// First, create the Public Group
		Group publicGroup = New Group(Name = 'Public Group 1', 
                                      DeveloperName = 'PubGroup1');
        insert publicGroup;
                                      
        // Next, create the Chatter Group
        CollaborationGroup restrictedGroup = New CollaborationGroup(Name = 'Chatter 1', 
                                                                   	CollaborationType = 'Public');
		insert restrictedGroup;
                                      
		// Next, create a restricted Custom Setting with auto-follow
		ChatterGroupManagement__c customSetting = New ChatterGroupManagement__c(Name = 'CS 1',
                                                                                ChatterGroupName__c = 'Chatter 1', 
                                                                                AutoSubscribe__c = true);
		insert customSetting;
                                      
        // Identify a user
        User testUser = [Select	Id 
                         from 	User 
                         where 	Id !=: UserInfo.getUserId() AND
                         		IsActive = true AND
                         		UserType = 'Standard' 
                         limit 	1];
		testUser.FirstName = 'Fred';
        //Modified By Rajeev jain at the time of Production Deployment - CR-20180126-11909 - Solve - SalesforceIQIntegration User cannot be edited
		//update testUser;
	}                                      

}