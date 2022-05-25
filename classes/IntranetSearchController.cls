//String.isNotBlank(SearchTerm) - Added By - Abhinav Sharma - CR-20150826-9192 - 10/12/2015 - In existing condition
//V1.2 - Merged Code - Rajeev Jain - 10/28/2015 - Conflict found with CR-20150826-9192 - Merged from the Test Sandbox
//V1.3 - Modify - Victor Hanson - 10/05/2017 - CR-20171003-11642 - only add users that are in the current user's entity
public without sharing class IntranetSearchController {
    
    public static final Integer DEFAULT_PAGE_SIZE = 5;
    public static final Integer DEFAULT_USER_PAGE_SIZE = 6;
    public static final String EXCLUDED_USER_USERTYPES = 'PowerCustomerSuccess,CustomerSuccess,Guest,CSPLitePortal,CSNOnly,SelfService';
    
    public String SearchTerm { get; set; }
    public String SearchMoreType { get; set; }
    
    // Summary Data
    public List<SearchResultSection> ContentSearchResult { get; private set; }
    public List<IntranetUserInfo> UserSearchResult { get; private set; }
    public List<SearchResultSection> SearchResultSummary { get; private set; }
    public List<IntranetWordpressSearch.SearchResultInfo> PortalSearchResult { get; private set; }

    public Boolean TooManyMatches { get; private set; }
    public Integer TotalCount { get; set; }
   
    // Cached Full Result
    public Map<string, List<IntranetContentInfo>> mAllGroupedContentSearchResult;
    public List<IntranetUserInfo> mAllUserSearchResult;
    public List<IntranetWordpressSearch.SearchResultInfo> mAllPortalSearchResult; 
    
    static String[] mExcludedUserTypes;
    static String[] ExcludedUserTypes {
        get {
            if(mExcludedUserTypes == null) {
                mExcludedUserTypes = EXCLUDED_USER_USERTYPES.split(',');
            }
            return mExcludedUserTypes;
        }
    }
    
    static Map<String, Schema.FieldSet> mFieldsetMap;
    public static Map<String, Schema.FieldSet> FieldsetMap {
        get {
            if(mFieldsetMap == null) {
                mFieldsetMap = new Map<String, Schema.FieldSet>();
                
                Schema.DescribeSobjectResult result = Intranet_Item__c.sObjectType.getDescribe();
                // Get all fieldsets
                Map<String, Schema.FieldSet> mapFieldset = result.fieldSets.getMap();
                for(Schema.FieldSet fieldset : mapFieldset.values()) {
                    String name = fieldset.Label;
                    if(!name.startsWith('Search Results ')) continue;
                    mFieldsetMap.put(name.replace('Search Results ', ''), fieldset);
                }
            }
            return mFieldsetMap;
        }
    }
    
    static Map<String, Schema.SObjectField> mFieldMap;
    public static Map<String, Schema.SObjectField> FieldMap {
        get {
            if(mFieldMap == null) {
                Schema.DescribeSobjectResult result = Intranet_Item__c.sObjectType.getDescribe();
                // Get all fields
                mFieldMap = result.fields.getMap();
            }
            return mFieldMap;
        }
    }

    static String mUserGroupName;
    static String mPortalGroupName;
    public static String UserGroupName {
        get {
            if(mUserGroupName == null) {
                mUserGroupName = IntranetHomeUtility.LookupIntranetDefaultByName('Users').SearchCategory__c;
            }
            return mUserGroupName;
        }
    }
    public static String PortalGroupName {
        get {
            if(mPortalGroupName == null) {
                mPortalGroupName = IntranetHomeUtility.LookupIntranetDefaultByName('Portals').SearchCategory__c;
            }
            return mPortalGroupName;
        }
    }
    
    public IntranetSearchController() {
        if(ApexPages.currentPage() == null) return;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        if(SearchTerm == null) SearchTerm = params.get('q');
        
        if(ContentSearchResult == null) Search();
    }
    
    public PageReference Search(){
        //String.isNotBlank(SearchTerm) - Added By - Abhinav Sharma - CR-20150826-9192 - 10/12/2015 - In existing condition
        //V1.2 - Merged Code - Rajeev Jain - 10/28/2015 - Conflict found with CR-20150826-9192
        if(String.isNotBlank(SearchTerm) && SearchTerm.length() > 2) {
            SearchCore();
            SampleResult();
        } else {
            ResetSearch();
        }
        return null;
    }
    
    public PageReference SearchMoreContentType() {
        if(mAllGroupedContentSearchResult.containsKey(SearchMoreType)) {
            List<IntranetContentInfo> res = mAllGroupedContentSearchResult.get(SearchMoreType);
            SearchResultSection section = new SearchResultSection(SearchMoreType, 0, res.size());
            section.Contents.addAll(res);
            section.Contents.add(0, res[0].DuplicateToHeader());
            ContentSearchResult.clear();
            ContentSearchResult.add(section);
            
            UserSearchResult = new List<IntranetUserInfo>();
            PortalSearchResult = new List<IntranetWordpressSearch.SearchResultInfo>();
            
        } else if(SearchMoreType == UserGroupName) {
            UserSearchResult = mAllUserSearchResult;
            
            ContentSearchResult = new List<SearchResultSection>();
            PortalSearchResult = new List<IntranetWordpressSearch.SearchResultInfo>();
            
        } else if(SearchMoreType == PortalGroupName) {
            PortalSearchResult = mAllPortalSearchResult;
            
            UserSearchResult = new List<IntranetUserInfo>();
            ContentSearchResult = new List<SearchResultSection>();
        }
        
        return null;
    }

    public PageReference BackToSearchSummary() {
        
        SearchMoreType = '';
        SampleResult();
        
        return null;
    }

    public void ResetSearch() {
        TotalCount = 0;
        SearchResultSummary = new List<SearchResultSection>();
        ContentSearchResult = new List<SearchResultSection>();
        UserSearchResult = new List<IntranetUserInfo>();
        PortalSearchResult = new List<IntranetWordpressSearch.SearchResultInfo>();
    }
    
    public void SearchCore() {
        ResetSearch();

        String searchString = SearchTerm + '*';
       
        // 1. Search Users
        List<List<SObject>> searchUserList = [FIND :searchString IN NAME FIELDS RETURNING
            User (Id, Name, LastName, Title, Email, Phone, FirstName, Manager.Name, Workspace_Number__c, Office__c,
                  SmallPhotoUrl, FullPhotoUrl, ABC_Department__c, Entity__c
                  WHERE IsActive != false AND UserType NOT IN :ExcludedUserTypes
                  ORDER BY Name)];

        // 1.1 Process users
        mAllUserSearchResult = new List<IntranetUserInfo>();
        List<User> users = searchUserList.get(0);
        for(User item : users) {
            
            //VH 10/05/2017 - CR-11642 - only add users that are in the current user's entity
            if (IntranetHomeUtility.isVisibleForUserEntity(item.Entity__c, IntranetHomeUtility.getUserSession.userEntity))
                mAllUserSearchResult.add(new IntranetUserInfo(item));
        }

        // 1.2 Sort result and Generate count summary
        mAllUserSearchResult.sort();
        SearchResultSummary.add(new SearchResultSection(UserGroupName, 0, mAllUserSearchResult.size()));
        
        // 2. Search Items & Topics
        List<List<SObject>> searchList = [FIND :searchString IN ALL FIELDS RETURNING
            Intranet_Item__c (Id, Item_Title__c, Item_Type__c, Event_Start_Date_Time__c, Event_End_Date_Time__c,
                              Category_Reference_Name__c, Chatter_Likes__c, Chatter_Comments_Rollup__c,
                              View_Count__c, LastModifiedDate, Permalink__c, Office_Name__c, Event_Type__c,
                              Content_Author_Speaker__c, Publish_Date__c, Event_Status__c, Average_Utilization_Rating__c,
                              Item_SubTitle__c, Item_Abstract__c, Link_URL__c, Content_Publish_Date__c, Link_Behaviour__c, 
                              Content_URL_Validated__c, Link_URL_Validated__c, Secondary_Link_1_Location_Validated__c, 
                              Permalink_Validated__c
                              WHERE Search_Exclusion_Auto__c = false AND Visible_for_Current_User_Entity__c = true
                              ORDER BY LastModifiedDate DESC),
            Topic (Id)];

        // 2.1 Process topics
        List<Intranet_Item__c> items = searchList.get(0);
        Map<Id, Intranet_Item__c> mapIntranetItems = new Map<Id, Intranet_Item__c>(items);
        
        Map<Id, Topic> mapTopic = new Map<Id, Topic>((List<Topic>) searchList.get(1));        
        List<TopicAssignment> topicAssignments = [SELECT EntityId FROM TopicAssignment
                                                  WHERE TopicId IN :mapTopic.keyset()];
        // 2.2 Collect additional item ids basing on the topics 
        List<Id> topicItemIds = new List<Id>();
        for(TopicAssignment item : topicAssignments) {
            String objectName = item.EntityId.getSObjectType().getDescribe().getName();
            if(objectName == 'Intranet_Item__c') {
                if(!mapIntranetItems.containsKey(item.EntityId)) topicItemIds.add(item.EntityId);
            }
        }
        
        // 2.3 Get topic items detail
        Map<string, List<IntranetContentInfo>> mAllContentSearchResult = new Map<string, List<IntranetContentInfo>>();
        Map<Id, Intranet_Item__c> mapTopicItem = new Map<Id, Intranet_Item__c>();        
        if(topicItemIds.size() > 0) mapTopicItem = new Map<Id, Intranet_Item__c>([
            SELECT Id, Name, Item_Title__c, Item_Type__c, Event_Start_Date_Time__c, Event_End_Date_Time__c,
                Category_Reference_Name__c, Chatter_Likes__c, Chatter_Comments_Rollup__c,
                View_Count__c, LastModifiedDate, Permalink__c, Office_Name__c, Event_Type__c,
                Content_Author_Speaker__c, Publish_Date__c, Event_Status__c, Average_Utilization_Rating__c,
                Item_SubTitle__c, Item_Abstract__c, Link_URL__c, Content_Publish_Date__c, Link_Behaviour__c, 
            Content_URL_Validated__c, Link_URL_Validated__c, Secondary_Link_1_Location_Validated__c, Permalink_Validated__c
            FROM Intranet_Item__c
            WHERE ID IN :topicItemIds AND Search_Exclusion_Auto__c = false AND Visible_for_Current_User_Entity__c = true
        ]);

        // 2.4 Merge items
        items.addAll(mapTopicItem.values());

        // 2.5 get all schedules and intranet schedules with intranet containers where intranet item is in the search results
        mapIntranetItems = new Map<Id, Intranet_Item__c>(items);
        list<Intranet_Schedule__c> schedules = [SELECT Id, Intranet_Container__r.Top_Parent_Container_Id__c, Intranet_Item__c, 
                                                Intranet_Container__c, Intranet_Container__r.Reference_Number__c, Office__c
                                                FROM Intranet_Schedule__c WHERE Intranet_Item__c IN :mapIntranetItems.keySet()];
        set<id> topParentContainerIdSet = new set<Id>();
        for (Intranet_Schedule__c sched : schedules)
            topParentContainerIdSet.add(sched.Intranet_Container__r.Top_Parent_Container_Id__c);
        
        map<Id, Intranet_Container__c> parentContainerMap = new map<Id, Intranet_Container__c>([SELECT Id, Display_Name__c, Name
            FROM Intranet_Container__c WHERE Id IN :topParentContainerIdSet]);
        
        //create a map
        map<Id, Id> intranetIdToContainerIdMap = new map<Id, Id>();
        map<Id, Intranet_Schedule__c> intranetIdToScheduleMap = new map<Id, Intranet_Schedule__c>();
        for (Intranet_Schedule__c sched : schedules) {
            intranetIdToContainerIdMap.put(sched.Intranet_Item__c, sched.Intranet_Container__r.Top_Parent_Container_Id__c);
            intranetIdToScheduleMap.put(sched.Intranet_Item__c, sched);
        }
        
        // 2.6 Process items one by one
        for(Intranet_Item__c item : items) {
            String itemType = item.Item_Type__c;
            if(itemType == null) continue;

            Intranet_Defaults__c intranetDefault = IntranetHomeUtility.LookupIntranetDefault(itemType);
            if(intranetDefault == null) continue;
                    
            // Get the sorting field & direction
            Schema.SObjectField sortField = null;
            Boolean ascendingSort = true;
            try {
                if(intranetDefault.SearchResultSortField__c != null)
                    sortField = FieldMap.get(intranetDefault.SearchResultSortField__c);
                if(sortField == null)
                    sortField = FieldMap.get('LastModifiedDate');
                ascendingSort = intranetDefault.SearchResultSortFieldDir__c != 'desc';                    
            } catch(Exception ex) {
                sortField = FieldMap.get('LastModifiedDate');
            }

            Schema.FieldSet fieldset = FieldsetMap.get(itemType);
            if(fieldset == null) fieldset = FieldsetMap.get(item.Event_Type__c);
            if(fieldset == null) {
            }            
            
            //get the container id
            Id containerId = intranetIdToContainerIdMap.get(item.Id);
            
            //get the item container and the schedule
            Intranet_Container__c container = parentContainerMap.get(containerId);
            Intranet_Schedule__c schedule = intranetIdToScheduleMap.get(item.Id);
            if(mAllContentSearchResult.containsKey(itemType)) {
                List<IntranetContentInfo> lst = mAllContentSearchResult.get(itemType);
                lst.add(new IntranetContentInfo(item, schedule, container, fieldset, FieldMap, sortField, ascendingSort));
            } else {
                List<IntranetContentInfo> lst = new List<IntranetContentInfo>();
                lst.add(new IntranetContentInfo(item, schedule, container, fieldset, FieldMap, sortField, ascendingSort));
                mAllContentSearchResult.put(itemType, lst);
            }
        }

        Map<String, Set<String>> mMapItemCategoryTypes = IntranetHomeUtility.getIntranetItemCategoryTypeMaps();
        mAllGroupedContentSearchResult = new Map<string, List<IntranetContentInfo>>();
        for(String category : mMapItemCategoryTypes.keySet()) {
            Set<string> itemTypes = mMapItemCategoryTypes.get(category);

            // Combine items & find the smallest SortOrder for the item types in the same category
            Decimal sortOrder = 9999;
            List<IntranetContentInfo> res = new List<IntranetContentInfo>();
            for(String itemType : itemTypes) {
                List<IntranetContentInfo> resItem = mAllContentSearchResult.get(itemType);
                if(resItem == null) continue;

                res.addAll(mAllContentSearchResult.get(itemType));
                Intranet_Defaults__c intranetDefault = IntranetHomeUtility.LookupIntranetDefault(itemType);
                if(intranetDefault != null && intranetDefault.SearchResultOrder__c != null && intranetDefault.SearchResultOrder__c < sortOrder)
                    sortOrder = intranetDefault.SearchResultOrder__c;
            }
            if(res.size() == 0) continue;
            
            res.sort();
            for(Integer i=0; i<res.size(); i++) res[i].RowNumber = i+1;
            
            SearchResultSection itemSearchResultSection = new SearchResultSection(category, sortOrder, res.size());
            
            SearchResultSummary.add(itemSearchResultSection);
            mAllGroupedContentSearchResult.put(category, res);
        }

        // 3. Portal Search
        mAllPortalSearchResult = IntranetWordpressSearch.search(SearchTerm);
        if(mAllPortalSearchResult != null && mAllPortalSearchResult.size() > 0) {
            SearchResultSection portalSearchResultSection = new SearchResultSection(PortalGroupName, 9999, mAllPortalSearchResult.size());
            SearchResultSummary.add(portalSearchResultSection);
        }

        SearchResultSummary.sort();
    }
    
    public void SampleResult() {
        ContentSearchResult = new List<SearchResultSection>();
        for(SearchResultSection summary : SearchResultSummary) {
            summary.Contents.clear();
            
            if(summary.Name == UserGroupName || summary.Name == PortalGroupName) continue;
            
            List<IntranetContentInfo> res = mAllGroupedContentSearchResult.get(summary.Name);
            TotalCount += res.size();
            if(res.size() <= DEFAULT_PAGE_SIZE) {
                summary.Contents.addAll(res);
            } else {
                for(Integer i=0; i<DEFAULT_PAGE_SIZE; i++) {
                    summary.Contents.add(res[i]);
                }
            }
            
            // Dupliccate first row into column header
            summary.Contents.add(0, summary.Contents[0].DuplicateToHeader());
            ContentSearchResult.add(summary);
        }
        
        UserSearchResult = new List<IntranetUserInfo>();
        TotalCount += mAllUserSearchResult.size();
        TooManyMatches = TotalCount >= 2000;
        
        for(IntranetUserInfo u : mAllUserSearchResult) {
            if(UserSearchResult.size() < DEFAULT_USER_PAGE_SIZE) {
                UserSearchResult.add(u);
            } else {
                break;
            }
        }
        
        PortalSearchResult = new List<IntranetWordpressSearch.SearchResultInfo>();
        TotalCount += mAllPortalSearchResult.size();
        for(IntranetWordpressSearch.SearchResultInfo u : mAllPortalSearchResult) {
            if(PortalSearchResult.size() < DEFAULT_PAGE_SIZE) {
                PortalSearchResult.add(u);
            } else {
                break;
            }
        }
    }

    public class SearchResultSection implements Comparable {
        public String Name { get; private set; }
        public Integer Count { get; private set; }
        public Decimal SortOrder { get; private set;}
        public List<IntranetContentInfo> Contents { get; private set;}

        public SearchResultSection(String name, Decimal sortOrder, Integer count) {
            this.Name = name;
            this.SortOrder = sortOrder;
            this.Count = count;
            this.Contents = new List<IntranetContentInfo>();
        }
        
        public Integer compareTo(Object compareTo) {
            if(compareTo == null) return 1;
            SearchResultSection target = (SearchResultSection)compareTo;
            if(target == null) return 1;
            
            if (this.SortOrder == target.SortOrder) return 0;
            if (this.SortOrder >  target.SortOrder) return 1;
            return -1;
        }
    }
}