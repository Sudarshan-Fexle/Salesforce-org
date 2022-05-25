/*
	Author:			Scott Grabo
	Created: 		9/30/2014	
	Description:	On save or update of a User record, joins Users to the Chatter Groups that
					have been flagged as "auto-follow" in the ChatterGroupManagement custom setting
	Called by:		ChatterGroupAutoFollow
	Consumes:		ChatterGroupManagement__c (custom setting)
	Calls:			Nothing
	Change log:		9/30/2014 - Creation
					Modified By - MAhendra Swarnkar - CR-20170302-10732- 4/24/2017 -update the "AddToGroups()"  method to add the Auto_Subscribe_to_Chatter_Groups__c field in the query.
*/
public class UserChatterGroupAutoFollow 
{
    
    public static void callFuture_AddToGroup(Set<Id> userIDs, Boolean isUpdate)
    {
        if(system.isFuture() || system.isBatch()){
            UserChatterGroupAutoFollow.AddToGroups(userIDs, isUpdate);
        }else{
            UserChatterGroupAutoFollow.AddToGroups_Future(userIDs, isUpdate);
        }     
    }
    
    @future
    public static void AddToGroups_Future(Set<Id> userIDs, Boolean isUpdate)
    {
        UserChatterGroupAutoFollow.AddToGroups(userIDs, isUpdate);
    }
    
    //Updated By MAhendra Swarnkar - CR-20170302-10732 - 4/24/2017 - Added the Auto_Subscribe_to_Chatter_Groups__c field in the query string
	// Established as an @future class to prevent the "can't change a User and another object"
	// error at runtime.
    public static void AddToGroups(Set<ID> userIDs, Boolean isUpdate)
    {
        //Updated By MAhendra Swarnkar - CR-20170302-10732- 4/24/2017 - Added the Auto_Subscribe_to_Chatter_Groups__c field in the query string
        // Identify the users that are Standard only, because
        // we don't want to do this for Partners/etc.
		List<User> eligibleUsers = [Select	ID
                                    from	User 
                                    where	ID in :userIds AND
                                    		IsActive = TRUE AND
                                    		Auto_Subscribe_to_Chatter_Groups__c = TRUE AND
                                   			UserType = 'Standard'];
        
        // Only bother continuing if we've identified eligible users...
		if(eligibleUsers.size() > 0)
        {
            // Identify the groups that we're targeting
            // Get the names first...
            Map<String, ChatterGroupManagement__c> mapChatterGroups = new Map<String, ChatterGroupManagement__c>
                                                                        ([Select	ChatterGroupName__c
                                                                            from	ChatterGroupManagement__c
                                                                            where	AutoSubscribe__c = true]);
            Set<String> targetGroups = new Set<String>();
            for(ChatterGroupManagement__c thisCG : mapChatterGroups.values())
                targetGroups.add(thisCG.ChatterGroupName__c);
            // ...then build a list of the matching groups with ID
            List<CollaborationGroup> chatterGroups = [Select	id, 
                                                                Name 
                                                       From		CollaborationGroup 
                                                       where 	name in :targetGroups];
        
            // Only bother continuing if we've identified Groups 
            if(chatterGroups.size() > 0)
            {
                // Capture all of the existing members of the target Chatter Groups
                Map<ID, CollaborationGroupMember> allMembers = new Map<ID, CollaborationGroupMember>
                                                                ([Select	ID,
                                                                            MemberID,
                                                                            CollaborationGroupID
                                                                    from	CollaborationGroupMember
                                                                    where	CollaborationGroupID in :chatterGroups]);
                // We're capturing this as a string of concatenated IDs (member plus group)
                // to simplify the comparison later on
                Set<String> currentMembers = new Set<String>();
                for(CollaborationGroupMember thisMember : allMembers.values())
                    currentMembers.add(String.valueOf(thisMember.MemberID) + String.valueOf(thisMember.CollaborationGroupID));
                    
                // Loop through the final Users list, adding members to the Group as 
                // needed
                List<CollaborationGroupMember> CGMlist = new List<CollaborationGroupMember>();
                for(User newUser : eligibleUsers)
                {
                    // Now, loop through for each of the target Groups
                    for(CollaborationGroup thisGroup : ChatterGroups)
                    {
                        // ...and the User isn't already a member of the Group, then
                        // add him/her. Otherwise, just add him/her
                        If((isUpdate && !currentMembers.contains(String.valueOf(newUser.ID) + String.valueOf(thisGroup.ID))) ||
                           !isUpdate)
                        {
                            CollaborationGroupMember CGM = new CollaborationGroupMember();
                            CGM.CollaborationGroupId = thisGroup.ID;
                            CGM.MemberID = newUser.Id;
                            // "P" = "On each post"
                            CGM.NotificationFrequency = 'P';
                            CGMList.add(CGM);
                        }
	                }
                }
        
                // Assuming we found somebody, insert them.
                if(!CGMList.isEmpty())
                    insert CGMList;
            }
    	}
    }

}