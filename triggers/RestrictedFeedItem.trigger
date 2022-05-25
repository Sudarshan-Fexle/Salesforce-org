/*
	Author:			Scott Grabo
	Created: 		9/30/2014	
	Description:	Prevents the submission of posts (but not comments) to Chatter Groups that
					have been flagged as "restricted" in the ChatterGroupManagement custom setting
	Called by:		FeedItem (trigger)
	Consumes:		ChatterGroupManagement__c (custom setting)
	Calls:			Nothing
	Change log:		9/30/2014 - Creation
				V1.1 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
*/
trigger RestrictedFeedItem on FeedItem (before delete, before insert, before update)
{
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('FeedItem')) return;	

    // Determine if the current user is an Admin by looking through the Profiles
    // to see if his/her profile matches any of the admin IDs. 
    Boolean adminUser = false;
    for (Profile adminProfile : [SELECT Id, Name FROM Profile]) 
    {
        if(adminProfile.Name.Contains('Administrator') && 
           adminProfile.ID == UserInfo.GetProfileID())
        {
            adminUser = true;
            break;
        }
    }

    // If NOT an admin, then check against the group membership associated with 
    // the Leadership group access. 
    if(adminUser == false)
    {
        // Making the assumption that the Chatter Group to which we're posting
        // is the only one represented in the Trigger.New set
        String currentGroup ;
        if(Trigger.isDelete)
        	currentGroup = Trigger.Old[0].ParentID;
         else
        	currentGroup = Trigger.New[0].ParentID;
        
        // Identify the Chatter Groups that we're targeting
    	// Get the names first...
        Map<String, ChatterGroupManagement__c> mapChatterGroups = new Map<String, ChatterGroupManagement__c>
                                                                    ([Select	ChatterGroupName__c, 
                                                                      			PublicGroupName__c
                                                                        from	ChatterGroupManagement__c
                                                                        where	Restricted__c = true]);
        Set<String> restrictedChatterGroups = new Set<String>();
        for(ChatterGroupManagement__c thisCG : mapChatterGroups.values())
            restrictedChatterGroups.add(thisCG.ChatterGroupName__c);
        // ...then find the Chatter Group that corresponds to the current 
        // Parent being posted to
        List<CollaborationGroup> chatterGroups = [Select	id, 
                                                            Name 
                                                   From		CollaborationGroup 
                                                   where 	name in :restrictedChatterGroups AND
                                                 			ID = :currentGroup];
		
        // If nothing was found, it means they're posting to a non-restricted group,
        // and they should proceed without incident. Otherwise, let's dig in...
        if(chatterGroups.size() > 0)
        {
			// Find the Public Groups whose presence indicates "you can post", 
			// first by getting the names from the map...
            Set<String> enablingPublicGroups = new Set<String>();
            for(ChatterGroupManagement__c thisCG : mapChatterGroups.values())
                enablingPublicGroups.add(thisCG.PublicGroupName__c);
            
            // ...then by finding the Public Group IDs
            List<Group> publicGroup = [Select	id
                                       From		Group 
                                       where 	DeveloperName in :enablingPublicGroups];

            // We're just going to add-on to the previous Set
            for(Group thisGroup : publicGroup)
                enablingPublicGroups.add(thisGroup.ID);
        
            // Look for the current user in the Leadership access group 
            List<GroupMember> foundMembers = [Select 	ID 
                                                From    GroupMember 
                                                Where   GroupID IN : enablingPublicGroups and 
                                                        UserOrGroupID =: UserInfo.GetUserID()
                                                        Limit 1];
        
            // If we can't find him/her in the group AND s/he's not an admin, then
            // warn that they're not allowed to create a new feed item.
            if(foundMembers.size() == 0)
            {
                if(Trigger.isDelete)
                {
                    Trigger.New[0].addError(Label.Error_Restricted_Chatter_Message_Delete);
                } else if(Trigger.isUpdate)
                {
                    Trigger.New[0].addError(Label.Error_Restricted_Chatter_Message_Update);
                } else
                {
                	Trigger.New[0].addError(Label.Error_Restricted_Chatter_Message_Insert);    
                }
            }
        }
    }
}