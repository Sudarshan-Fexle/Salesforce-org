public class IntranetChatterGroupController {
    
    public IntranetChatterGroupController() { }
    public string groupId { get; set; }
    
    public integer maxVisibleChatterGroups {
        get {
            if (maxVisibleChatterGroups == null) maxVisibleChatterGroups = 15;
            return maxVisibleChatterGroups;
        }
        set;
    }
    
    /**
     * @description:    list of all chatter groups (note: should filter for privacy in the future)
     * 
     **/
    Transient map<Id, CollaborationGroup> mGroupMap;
    private map<Id, CollaborationGroup> groupMap {
        get {
            if (mGroupMap == null) {
                mGroupMap = new map<Id, CollaborationGroup>(groups);
            }
            return mGroupMap;
        }
        set;
    }
    
    /**
     * @description:    list of all chatter groups (note: should filter for privacy in the future)
     * 
     **/
    Transient list<CollaborationGroup> mGroups;
    public list<CollaborationGroup> groups {
        get {
            if (mGroups == null) {
                mGroups = [SELECT Id, CanHaveGuests, CollaborationType, Description, FullPhotoURL, GroupEmail, HasPrivateFieldsAccess, 
                           InformationBody, InformationTitle, OwnerId, Owner.Name, IsArchived, LastViewedDate, Name, MemberCount, SmallPhotoURL 
                           FROM CollaborationGroup WHERE IsArchived = false ORDER BY LastViewedDate DESC NULLS LAST LIMIT :maxVisibleChatterGroups];
            }
            return mGroups;
        }
        set{
            mGroups = value;
        }
    }
    
    /**
     * @description:    group membership map
     * 
     **/
    public map<Id, boolean> groupMemberMap {
        get {
            if (groupMemberMap == null) {
                groupMemberMap = new map<Id, boolean>();
                map<Id, CollaborationGroupMember> gmMap = new map<Id, CollaborationGroupMember>([SELECT Id, CollaborationGroupId, MemberId 
                                                                                                 FROM CollaborationGroupMember 
                                                                                                 WHERE MemberId = :UserInfo.getuserId()]);
                for (CollaborationGroupMember cgm : gmMap.values()) {
                    gmMap.put(cgm.CollaborationGroupId, cgm);
                }
                
                for (CollaborationGroup g : groups) {
                    groupMemberMap.put(g.Id, gmMap.containsKey(g.Id));
                }
            }
            return groupMemberMap;
        }
        set{
            groupMemberMap = value;
        }
    }
    
    /**
     * @description:    command used to join a group
     * 
     **/
    public void joinGroup() {
        
        //get the group that they want to join
        CollaborationGroup jGroup = groupMap.get(groupId);
        
        //if this is a private group, insert a group request
        if (jGroup.CollaborationType == 'Private' || jGroup.CollaborationType == 'Unlisted') {
            // insert the request
            CollaborationGroupMemberRequest cgmr =  new CollaborationGroupMemberRequest( CollaborationGroupId = groupId, RequesterId = UserInfo.getUserId() );
            insert cgmr;
        }
        else {
            // add the user to the group
            CollaborationGroupMember cgm =  new CollaborationGroupMember( CollaborationGroupId = groupId, MemberId = UserInfo.getUserId() );
            insert cgm;
        }
        
        refreshGroups();        
    }
    
    /**
     * @description:    get an updated list of groups and current memberships
     * 
     **/
    public void refreshGroups() {
        groupMap = null;
        groups = null;
        groupIdToGroupRequest = null;
        groupMemberMap = null;
    }
    
    /**
     * @Description:    map of groupId to groupRequest (pending)
     * 
     **/
    public map<Id, boolean> groupIdToGroupRequest {
        get {
            if (groupIdToGroupRequest == null) {
                groupIdToGroupRequest = new map<Id, boolean>();
                //add all groups to the map
                for (Id CollaborationGroupId : groupMap.keySet()) groupIdToGroupRequest.put(CollaborationGroupId, false);
                for (CollaborationGroupMemberRequest request : [SELECT Id, CollaborationGroupId, RequesterId, Status FROM CollaborationGroupMemberRequest WHERE Status = 'Pending']) {
                    groupIdToGroupRequest.put(request.CollaborationGroupId, true);
                }
            }
            return groupIdToGroupRequest;
        }
        set{
            groupIdToGroupRequest = value;
        }
    }
}