/** 
*   Purpose         :   Controller class for Boardroom Home Caontainer page
*
*   Created By      :   Bhavi Sharma
*
*   Created Date    :   09/14/2014
*
*   Revision Logs   :   V_1.0 - Created
*                       V_1.1 - Modified By - Abhinav Sharma - CR-20140930-7536 - 01/28/2015
*                       V_1.2 - Modified By - Abhinav Sharma - CR-20150219-8692 - 04/29/2015
*                       V_1.3 - Modified By - Rajeev Jain - CR-20141003-7624 - 05/01/2015
*                       V_1.4 - Modified By - Abhinav Sharma - CR-20141020-7816 - 05/03/2015
*                       V_1.5 - Modified By - Rajeev Jain - CR-20150611-9000 - 06/17/2015 - BoardRoom Preview of Schedule item
*                       V_1.6 - Modified By - Abhinav Sharma - CR-20140930-7520 - 07/16/2015
*                       V_1.7 - Modified By - Rajeev Jain   - CR-20150618-9016 - 07/08/2015 - BoardRoom Mobile - Phase 2
*                       Description : Removed 'createUtlizationRecordOnMainPageLoad' action method.
*                       Moved code to java script and Action Remotting.
*                       V_1.8 - Modified By - Rajeev Jain- CR-20141003-7634 - 07/28/2015 - BoardRoom Header System Status
*                       V_1.9 - Modified By - Rajeev Jain - CR-20150709-9072 - 07/30/2015 
*                       Description : Top5AccessMenu Customsetting is taking too much space, removed usability of many fields from custom setting
*                       V_2.0 - Modified By - Mahendra Swarnkar - CR-20170918-11372 - 09/28/2017
*                       V_2.1 - Modified By - Victor Hanson - 10/05/2017 - CR-20171003-11642 - check for entity visibility
*                       v2.1 - Modified By - Rajiv jain - 02/18/2020 - CR-20190929-13382 - remove the zzzHas Subcontainers(Has_SubContainers__c) and zzzScreen Priority(Screen_Priority__c) field on Intranet_Container__c object
**/ 
public with sharing class BoardroomHomeContainerController extends IntranetBaseController {
    
    //Variable to Hold the Intranet Container Record
    public Intranet_Container__c intranetContainer{get; set;}
    
    //Variable to hold IntranetMainPageId
    String IntranetMainPageId;
    
    public String scheduleIdValue {get; set;}
    
    //Constructor
    public BoardroomHomeContainerController() {
        
        //Get Id from Label
        if(Test.isRunningTest())
            IntranetMainPageId = ApexPages.currentPage().getParameters().get('IntranetMainPageId');
        else
            IntranetMainPageId = Label.IntranetMainPage;
            
        //V_1.1 - Modified By - Abhinav Sharma - CR-20140930-7536 - 01/28/2015
        //Start Here
        String SearchContentId = ApexPages.currentPage().getParameters().get('SearchContentId');
        if (SearchContentId != null) {
            transient List<Intranet_Schedule__c> lshedules = new List<Intranet_Schedule__c>();
            lshedules = [SELECT Id FROM Intranet_Schedule__c
                                 WHERE Intranet_Item__c =: SearchContentId
                                 ORDER BY Is_Visible__c DESC LIMIT 1];
            if(lshedules.size() > 0)
                scheduleIdValue = lshedules[0].ID;    
        }
        //Upto here
        
        //Call inIt
        if(intranetContainer == null){
            inIt();
        }
    }
    
    //inIt method
    public override void inIt() {
        
        //Initialize
        intranetContainer = new Intranet_Container__c();
        
        //Fetch Intranet container record from database
        List<Intranet_Container__c> intranetContainers = [Select Id, Header_Container__c, Footer_Container__c from Intranet_Container__c where Id =: IntranetMainPageId];   
        
        //Check for intranetContainers size
        if(intranetContainers.size() > 0)
            intranetContainer = intranetContainers[0];
        
        //This gets all containers associated with the Main Page from Boardroom - since all containers should have it
        // as their parent - it should pull all containers
        ProcessPreviewParameters();
        
        if(MainPageContainerMap == null) {
            
             //Reinitialize map
            mapContainerIdWithDefaultContentItemId = new Map<Id, Id>();
            mapDefaultContentitemIdWithContainerId = new Map<Id, Id>();
        
            //This gets all containers associated with the Main Page from Boardroom - since all containers should have it
            // as their parent - it should pull all containers
            this.MainPageContainerMap = GetContainersByTopParentForHeader(intranetContainer.Header_Container__c);
            
            //We needs to load SubContainers of MainContainer if home Page only
            if(ApexPages.currentPage().getUrl().containsIgnoreCase(System.Label.BR_Home)){
                
                Map<Id, IntranetContainer> MainPageContainerMap1 = GetContainersByTopParent(intranetContainer.Id);
                for(Id tempId:MainPageContainerMap1.keySet()){
                    MainPageContainerMap.put(tempId, MainPageContainerMap1.get(tempId));    
                }
            }
            
            Id previewContentId = GetMainPageContent();
            
            BuildContainerHierarchy(previewContentId);
        }
    }
    
    public Map <Id, IntranetContainer> MainPageContainerHierarchy {get; private set;}
    private Map <Id, IntranetContainer> SubContainerMap;
    private Set <Id> ParentContainerCheckSet;
    transient Map <Id, IntranetContent> IntranetContentMap;
    private Map <String, Id> ContainerTypeToContainerId;
    
    set<Id> mappedContainers;
    @TestVisible Map<Id, IntranetContainer> MainPageContainerMap;
    
    //Map to hold the Default ContentItem id with the Container Id
    Map<Id, Id> mapContainerIdWithDefaultContentItemId = new Map<Id, Id>();
    Map<Id, Id> mapDefaultContentitemIdWithContainerId = new Map<Id, Id>();
    
    //Map to hold the Default ContentItem Id with the Intranet Content record
    Map<Id, IntranetContent> mapDefaultContentItemIdWithIntranetContent = new Map<Id, IntranetContent>();
    
    public Id GetMainPageContent() {
        
        IntranetType.UserSession userSession = IntranetHomeUtility.getUserSession;
        Id OfficeId = userSession.AssignedOffice;
        
        Map<string, Intranet_Utilization__c> maplikedItems = IntranetUtilizationHelper.getLikedItems();
        
        //V_1.5 - Modified By - Rajeev Jain - CR-20150611-9000 - 06/17/2015
        //07/24/2015 - Prior to migration to testSandbox - This Changes Merged from Prevuious release with BoardRoom Mobile Release -->
        //Queries all Schedules associated with the Containers queried above
        Map <Id, Intranet_Schedule__c> AssociatedSchedules = GetSchedules(MainPageContainerMap.keySet(), SchedId, system.today().addDays(15), IsPreview);
        
        // Get preview container id and preview item ids
        Id previewContainerId;
        Id previewContentId;
        
        if(IsPreview && AssociatedSchedules.containsKey(SchedId)) {
            previewContainerId = AssociatedSchedules.get(SchedId).Intranet_Container__c;    
        }
        
        Set <Id> ItemIds = new Set<Id>();
        
        for (Intranet_Schedule__c scheduleId : AssociatedSchedules.values()) {
        
            ItemIds.add(ScheduleId.Intranet_Item__c);

            // We have item already, remove the default content!
            if(mapContainerIdWithDefaultContentItemId.ContainsKey(ScheduleId.Intranet_Container__c)) {
                mapContainerIdWithDefaultContentItemId.remove(ScheduleId.Intranet_Container__c);
            }

            if(IsPreview && scheduleId.Id == SchedId) {
                previewContentId = ScheduleId.Intranet_Item__c;
            }
        }
        
        //Add all the DefaultContentItemIds in Set by defaults
        //This will allow the Intranet_Item query after this to get info for the Default Content items as well.
        ItemIds.addAll(mapContainerIdWithDefaultContentItemId.values());

        //Grabs all Items associated with the Schedules queried for above
        Map <Id, Intranet_Item__c> AssociatedItems = GetContentItems(ItemIds, null, system.today(), system.today().addDays(15));
        
        //When creating the IntranetContent record for the Default item, 
        //it may need some special conditions because there will be no related Schedule for it.
        //Loop through the AssociatedItems and check if Item Id is part of setDefaultContentItemIds set, then add in it Default Content Map
        for(Intranet_Item__c intranetItem : AssociatedItems.values()) {
            
            //If it is a Default Content Item, create the IntranetContent record and add it to the DefaultItemId to Intranet Content map created earlier.  
            //Do NOT add this to the main page content map.
            //check if the current item in the loop is one of the Default Content Items
            if(mapDefaultContentitemIdWithContainerId.containsKey(intranetItem.Id)) {
                
                //Intranet Continer
                IntranetContainer container = MainPageContainerMap.get(mapDefaultContentitemIdWithContainerId.get(intranetItem.Id));
                container.IsPreview = IsPreview && container.ContainerId == previewContainerId;
                
                //Check for the Intranet Item Id, if it's BirthDay then Get Users
                if(intranetItem.Item_Type__c == 'Birthdays' && String.isNotBlank(intranetItem.Birthdays_Cache__c)) {
                    
                    //Deserialize Biarthday data and Create a separate IntranetContent for each User
                    List<User> users = (List<User>)Json.deserialize(intranetItem.Birthdays_Cache__c, List<User>.class);
                    
                    //Loop through the users and creae a IntranetContent for each user
                    for(User user : users) {
                        
                        //VH 10/05/2017 - CR-20171003-11642 - check for entity visibility
                        if (IntranetHomeUtility.isVisibleForUserEntity(user.Entity__c, IntranetHomeUtility.getUserSession.userEntity)) {
                            
                            IntranetContent sc = new IntranetContent(container, intranetItem, userSession, maplikedItems);
                            sc.FirstName = user.FirstName;
                            sc.LastName = user.LastName;
                            sc.UserId = user.Id;
                            sc.ABCDepartment = user.ABC_Department__c;
                            sc.OfficeName = user.Office__c;
                            container.RelatedContent.add(sc);
                            mapDefaultContentItemIdWithIntranetContent.put(intranetItem.Id, sc);
                        }
                    } 
                } else {
                    
                    IntranetContent sc = new IntranetContent(container, intranetItem, userSession, maplikedItems);
                    container.RelatedContent.add(sc);
                    mapDefaultContentItemIdWithIntranetContent.put(intranetItem.Id, sc);
                }
            }   
        }
        
        IntranetContentMap = new map <Id, IntranetContent>();
        
        for (Intranet_Schedule__c schedule : AssociatedSchedules.values()) {

            IntranetContainer container = MainPageContainerMap.get(schedule.Intranet_Container__c);
            container.IsPreview = IsPreview && container.ContainerId == previewContainerId;
            
            //Intranet Item
            Intranet_Item__c intranetItem = AssociatedItems.get(schedule.Intranet_Item__c);
            
            //Check for the Intranet Item Id, if it's BirthDay then Get Users
            if(intranetItem != null && intranetItem.Item_Type__c == 'Birthdays' && String.isNotBlank(intranetItem.Birthdays_Cache__c)) {
                
                //Deserialize Birthday data and Create a separate IntranetContent for each User
                List<User> users = (List<User>)Json.deserialize(intranetItem.Birthdays_Cache__c, List<User>.class);
                
                //Loop through the users and creae a IntranetContent for each user
                for(User user : users) {
                    
                    //VH 10/05/2017 - CR-20171003-11642 - check for entity visibility
                    if (IntranetHomeUtility.isVisibleForUserEntity(user.Entity__c, IntranetHomeUtility.getUserSession.userEntity)) {
                        
                    IntranetContent sc = new IntranetContent(container, schedule, AssociatedItems.get(schedule.Intranet_Item__c), userSession, maplikedItems);
                    sc.FirstName = user.FirstName;
                    sc.LastName = user.LastName;
                    sc.UserId = user.Id;
                    sc.ABCDepartment = user.ABC_Department__c; 
                    sc.SmallPhotoURL = user.SmallPhotoUrl;
                    sc.OfficeName = user.Office__c;
                    container.RelatedContent.add(sc);
                    
                    //If it is not a Default Content Item, continue the normal process to create the IntratnetContent record and add to the map
                    if(!mapDefaultContentitemIdWithContainerId.containsKey(schedule.Intranet_Item__c)) {
                        IntranetContentMap.put(sc.IntranetItemId, sc);  
                    }
                } 
                } 
            } else if(AssociatedItems.containsKey(schedule.Intranet_Item__c)) {
                
                IntranetContent sc = new IntranetContent(container, schedule, AssociatedItems.get(schedule.Intranet_Item__c), userSession, maplikedItems);
                container.RelatedContent.add(sc);
                
                //If it is not a Default Content Item, continue the normal process to create the IntratnetContent record and add to the map
                if(!mapDefaultContentitemIdWithContainerId.containsKey(schedule.Intranet_Item__c)) {
                    IntranetContentMap.put(sc.IntranetItemId, sc);  
                }
            }
        }
        
        return previewContentId;
    }
    
    public void SortLimitContainerContent(IntranetContainer container, Id previewItemId) {
        
        if(container == null) return;
        
        if(container.RelatedContent == null || container.RelatedContent.size() == 0) {
            
            //Get the Default IntranetContent from Map if exists
            if(mapContainerIdWithDefaultContentItemId.containsKey(container.ContainerId)
                && mapDefaultContentItemIdWithIntranetContent.containsKey(mapContainerIdWithDefaultContentItemId.get(container.ContainerId))) {
                
                //Get Intranet Content
                IntranetContent intranetContent = mapDefaultContentItemIdWithIntranetContent.get(mapContainerIdWithDefaultContentItemId.get(container.ContainerId));    
                container.RelatedContent = new List<IntranetContent>();
                container.RelatedContent.add(intranetContent);
            } else 
                return;
        }
        
        // Move the preview item to top of the list.
        if(container.IsPreview && previewItemId != null) {
            decimal MinSortOrder = -100;
            for(IntranetContent sc : container.RelatedContent) {
                if(sc.SortOrder < MinSortOrder) MinSortOrder = sc.SortOrder;
            }
            for(IntranetContent sc : container.RelatedContent) {
                if(previewItemId != null && previewItemId == sc.IntranetItemId) {
                    sc.SortOrder = MinSortOrder - 100;
                }
            }
        }
        
        container.RelatedContent.sort();
        
        //Update the field MaxContentItems in IntranetContainer to the value in MaxContentItems in the custom setting 
        //where the Custom Setting Name field equals the top item's Item Type field        
        if(container.MaxContentItems == null || container.MaxContentItems == 0) {
        
            //IntranetContent
            IntranetContent intranetContent = container.RelatedContent.get(0);
            if(intranetContent != null) {
                Intranet_Defaults__c intranetDefault = IntranetHomeUtility.LookupIntranetDefault(intranetContent.ItemType);
                if(intranetDefault != null && intranetDefault.Max_Content_Items__c != null) {
                    container.MaxContentItems = intranetDefault.Max_Content_Items__c;
                }
            }
        }

        //Check if the size of the Container's RelatedContent is larger than the IntranetContainer's MaxContentItems field value.  
        if(container.MaxContentItems != null && container.MaxContentItems > 0 && 
            container.RelatedContent.size() > container.MaxContentItems) {
            
            //Maximum Allowed Size
            Integer maxAllowedSize = Integer.valueOf(container.MaxContentItems);
            Integer currentSize = container.RelatedContent.size();
            
            //If so, keep only the first ones in the Related Content list up to the number of MaxContentItems
            //This will limit the amount of data being sent to the View State for the main Intranet page
            for(Integer i = currentSize -1; i >= container.MaxContentItems; i--) {
                
                //Remove from list
                container.RelatedContent.remove(i);
            }
        }
        
        if(container.ContainerType == 'Flexible') {
            
            // Locate the first Item
            if(container.RelatedContent.size() > 0) {
                IntranetContent content = container.RelatedContent.get(0);
                String itemType = content.ItemType;
                Integer maxItem = itemType == 'Ad Item'? 1 : (integer) container.MaxContentItems;
                if(maxItem > 0) {
                    while(container.RelatedContent.size() > maxItem) {
                        container.RelatedContent.remove(container.RelatedContent.size() - 1);
                    }
                }
                if(itemType == 'Ad Item' || itemType == 'Job Item' || itemType == 'Talent Item'){
                    container.ContainerClass = content.ContainerClass;
                    container.DisplayName = content.DisplayName;
                    container.DPAScoreType = content.DPAScoreType;
                    container.ShowExpandLink = content.ShowExpandLink;
                }
            }
        }

        if(container.SubContainers != null) {
            for (IntranetContainer subContainer : container.SubContainers) {
                SortLimitContainerContent(subContainer, previewItemId);
            }
        }
    }
    
    public void BuildContainerHierarchy(Id previewItemId){
        
        //Initializes new sets/maps for building the Hierarchy
        mappedContainers = new set<Id>();
        MainPageContainerHierarchy = new map <Id, IntranetContainer>();
        ParentContainerCheckSet = new set <Id>();
        ContainerTypeToContainerId = new map <String, Id>();
        SubContainerMap = new map <Id, IntranetContainer>();
        for (IntranetContainer ic : MainPageContainerMap.values()){
            AddHierarchy(ic);
            SortLimitContainerContent(ic, previewItemId);
        }
    }
    
    public void AddHierarchy(IntranetContainer con) {
        
        //Loops through the containers and adds them to the Hierarchy map
        if(con.ParentContainerId == intranetContainer.Header_Container__c){
            if(!MainPageContainerHierarchy.keySet().contains(Con.ContainerId)){
                MainPageContainerHierarchy.put(Con.ContainerId, con);
                //ContainerTypeToContainerId.put(con.ContainerType, con.ContainerId);
                ContainerTypeToContainerId.put(con.ContainerName, con.ContainerId);
            }
        }
        if(con.ParentContainerId == intranetContainer.Id){
            if(!MainPageContainerHierarchy.keySet().contains(Con.ContainerId)){
                MainPageContainerHierarchy.put(Con.ContainerId, con);
                ContainerTypeToContainerId.put(con.ContainerName, con.ContainerId);
            }
        }
        else if(con.ParentContainerId != null && MainPageContainerMap.keyset().contains(con.ParentContainerId)){
            MainPageContainerMap.keyset().contains(con.ContainerId);
            AddHierarchy(MainPageContainerMap.get(con.ParentContainerId));
            if(ParentContainerCheckSet == null || !ParentContainerCheckSet.contains(Con.ContainerId)){
                MainPageContainerMap.get(con.ParentContainerId).SubContainers.add(con);
                ParentContainerCheckSet.add(Con.ContainerId);
                MainPageContainerMap.get(con.ParentContainerId).SubContainers.sort();
            }
        }
    }
    
    //The following are the methods for the Fixed Components
    //These all grab the container associated with that 'Container Type'
    Public IntranetContainer QuickLinks{
        get{IntranetContainer ic;
            Id IntranetContainerId;
            IntranetContainerId = ContainerTypeToContainerId.get('QuickLinks');
            ic = MainPageContainerHierarchy.get(IntranetContainerId);
            return ic;   
           }
        set;
    }
    
    Public IntranetContainer MemberImpact{
        get{IntranetContainer ic;
            Id IntranetContainerId;
            IntranetContainerId = ContainerTypeToContainerId.get('Member Impact');
            ic = MainPageContainerHierarchy.get(IntranetContainerId);
            return ic;
           }
        set;
    }
    
    Public IntranetContainer NewsCarousel{
        get{IntranetContainer ic;
            Id IntranetContainerId;
            IntranetContainerId = ContainerTypeToContainerId.get('News Carousel');
            ic = MainPageContainerHierarchy.get(IntranetContainerId);
            return ic;
           }
        set;
    }
    
    Public IntranetContainer ABCToday{
        get{IntranetContainer ic;
            Id IntranetContainerId;
            IntranetContainerId = ContainerTypeToContainerId.get('ABC Today');
            ic = MainPageContainerHierarchy.get(IntranetContainerId);
            return ic;
           }
        set;
    }
    
    Public IntranetContainer ABCVideo{
        get{IntranetContainer ic;
            Id IntranetContainerId;
            IntranetContainerId = ContainerTypeToContainerId.get('Video');
            ic = MainPageContainerHierarchy.get(IntranetContainerId);
            return ic;
           }
        set;
    }
    
    Public IntranetContainer ABCOffice{
        get{IntranetContainer ic;
            Id IntranetContainerId;
            IntranetContainerId = ContainerTypeToContainerId.get('ABC Office');
            ic = MainPageContainerHierarchy.get(IntranetContainerId);
            return ic;
        }
        set;
    }
    
    Public IntranetContainer ABCMenu {
        get{IntranetContainer ic;
            Id IntranetContainerId;
            IntranetContainerId = ContainerTypeToContainerId.get('Menu');
            ic = MainPageContainerHierarchy.get(IntranetContainerId);
            return ic;
           }
        set;
        
    }
    
    //<!--V_1.8 - Modified By - Rajeev Jain - CR-20141003-7634 - 07/28/2015 - BoardRoom Header System Status -->
    //Get System Status Data and its container Dynamically
    Public IntranetContainer SystemStatus{ 
        get{IntranetContainer ic;
            Id IntranetContainerId;
            IntranetContainerId = ContainerTypeToContainerId.get('System Status');
            ic = MainPageContainerHierarchy.get(IntranetContainerId);
            return ic;
           }
        set;
    }
    //<!--V_1.8 - Modified By - Rajeev Jain - CR-20141003-7634 - 07/28/2015 - BoardRoom Header System Status --> Upto Here
    
    Public IntranetContainer ABCPoll {
        get {
            Id IntranetContainerId = ContainerTypeToContainerId.get('Poll');
            IntranetContainer ic = MainPageContainerHierarchy.get(IntranetContainerId);
            return ic;
        }
        private set;
    }
    
    Public IntranetContainer Trending{
        get{IntranetContainer ic;
            Id IntranetContainerId;
            IntranetContainerId = ContainerTypeToContainerId.get('Trending');
            ic = MainPageContainerHierarchy.get(IntranetContainerId);
            return ic;
           }
        set;
    }
    
    Public IntranetContainer Flexible13 {
        get { return LookupFlexibleContainer('13');}
    }
    Public IntranetContainer Flexible15 {
        get { return LookupFlexibleContainer('15');}
    }
    Public IntranetContainer Flexible16 {
        get { return LookupFlexibleContainer('16');}
    }
    Public IntranetContainer Flexible17 {
        get { return LookupFlexibleContainer('17');}
    }
    Public IntranetContainer Flexible19 {
        get { return LookupFlexibleContainer('19');}
    }
    
    private IntranetContainer LookupFlexibleContainer(string position) {
        IntranetContainer ic;
        Id IntranetContainerId;
        IntranetContainerId = ContainerTypeToContainerId.get('Flexible_'+position);
        ic = MainPageContainerHierarchy.get(IntranetContainerId);
        return ic;
    }
    
    //Added By - Abhinav Sharma - CR-20141020-7816 - 05/03/2015
    //V_1.9 - Modified By - Rajeev Jain - CR-20150709-9072 - 07/30/2015 
    //Start From here
    public List<MostRecentContentItemWrapper> top5AccessAppSetting { 
        get {
            Top_5_Frequently_Accessed_Apps__c tempTop5AccessAppSetting = Top_5_Frequently_Accessed_Apps__c.getValues(Userinfo.getUserId());
            
            List<MostRecentContentItemWrapper> itemList = new List<MostRecentContentItemWrapper>();
            
            if(tempTop5AccessAppSetting != null){
                
                Set<String> setOfItemIds = new Set<String>();
                List<String> listOfItemIds = new List<String>();
                
                if(tempTop5AccessAppSetting.Recent_Intranet_Content_Item_1__c != null){
                    
                    setOfItemIds.add(tempTop5AccessAppSetting.Recent_Intranet_Content_Item_1__c);
                    listOfItemIds.add(tempTop5AccessAppSetting.Recent_Intranet_Content_Item_1__c);
                }
                if(tempTop5AccessAppSetting.Recent_Intranet_Content_Item_2__c != null){
                    
                    setOfItemIds.add(tempTop5AccessAppSetting.Recent_Intranet_Content_Item_2__c);
                    listOfItemIds.add(tempTop5AccessAppSetting.Recent_Intranet_Content_Item_2__c);
                }
                if(tempTop5AccessAppSetting.Recent_Intranet_Content_Item_3__c != null){
                    
                    setOfItemIds.add(tempTop5AccessAppSetting.Recent_Intranet_Content_Item_3__c);
                    listOfItemIds.add(tempTop5AccessAppSetting.Recent_Intranet_Content_Item_3__c);
                }
                if(tempTop5AccessAppSetting.Recent_Intranet_Content_Item_4__c != null){
                    
                    setOfItemIds.add(tempTop5AccessAppSetting.Recent_Intranet_Content_Item_4__c);
                    listOfItemIds.add(tempTop5AccessAppSetting.Recent_Intranet_Content_Item_4__c);
                }
                if(tempTop5AccessAppSetting.Recent_Intranet_Content_Item_5__c != null){
                    
                    setOfItemIds.add(tempTop5AccessAppSetting.Recent_Intranet_Content_Item_5__c);
                    listOfItemIds.add(tempTop5AccessAppSetting.Recent_Intranet_Content_Item_5__c);
                }
                
                //Temp List to Add Sequenced Data
                List<Intranet_Item__c> sequencedList = new List<Intranet_Item__c>();
                
                //Query on intranet Item and Get Schedule of It.
                Map<Id, Intranet_Item__c> mapRecentItems = new Map<Id,Intranet_Item__c>([select Id, Name, Display_Name__c, Icon_Style__c, Link_Behaviour__c, 
                                                                                         Link_Action__c, Link_URL_Validated__c, Item_Title__c,Create_Source__c
                                                                                         from Intranet_Item__c where Id IN : setOfItemIds]);
                
                //Loop over List of Id and get Item from Map and Add it to sequenced Map so most recent Item can be process in that order
                if(listOfItemIds.size() > 0 && mapRecentItems != null){
                    
                    for(String itemId : listOfItemIds){
                        
                        if(mapRecentItems.containsKey(Id.valueOf(itemId))){
                            sequencedList.add(mapRecentItems.get(itemId));
                        }
                    }
                }
                
                //Map to Hold Intranet Item Id and Schedule Id corrosponding to It
                Map<Id, Intranet_Schedule__c> mapCurrentSchedules = new Map<Id,Intranet_Schedule__c>();
                for(Intranet_Schedule__c tempSch : [select Id, Name, Intranet_Item__c, Intranet_Container__c 
                                                    from Intranet_Schedule__c where Intranet_Item__c IN :setOfItemIds]){
                    
                    mapCurrentSchedules.put(tempSch.Intranet_Item__c, tempSch);     
                }
                
                //Now Loop Over Sequenced List and Convert it to Intranet Content Wrapper and It to the List of ContentWrapper
                for(Intranet_Item__c ttItem : sequencedList){
                    
                    if(mapCurrentSchedules.containsKey(ttItem.Id)){
                        
                        itemList.add(new MostRecentContentItemWrapper(ttItem.Link_URL_Validated__c,
                                                                      ttItem.Item_Title__c,
                                                                      mapCurrentSchedules.get(ttItem.Id).Intranet_Container__c,
                                                                      ttItem.Id,
                                                                      mapCurrentSchedules.get(ttItem.Id).Id,
                                                                      
                                                                      ttItem.Icon_Style__c,
                                                                      ttItem.Link_Behaviour__c));
                    }
                }
            }
            
            return itemList;
        }
        set;
    }
    //Upto here
    //Upto here

    public void OfficeSelector (){
        list<SelectOption> options = IntranetHomeUtility.OfficeSelectList;
    }
    
    public Map<Id, IntranetContainer> GetContainersByTopParent(String topParentContainerId) {
        
        if(topParentContainerId != null) topParentContainerId = topParentContainerId.substring(0,15);
        
        Map <Id, Intranet_Container__c> mapContainers = new map <Id, Intranet_Container__c>(
                [SELECT Id, Name, Container_Type__c, Container_Level__c, Parent_Container__c,
                 Header_Container__c, Footer_Container__c, Status__c, Display_Name__c, 
                 Default_Content_Item__c, Show_Expand_Link__c, Top_Parent_Container_Id__c, 
                 Top_Parent_Container__c, Height__c, Width__c, Max_Content_Items__c,
                 Reference_Number__c, Content_Types_Allowed__c, Minimum_Visible_Screen__c, Position__c,
                 Show_Feedback_Link__c, Sort_Order__c
                 FROM Intranet_Container__c
                 WHERE Top_Parent_Container_Id__c = :topParentContainerId AND Status__c = 'Active' AND Container_Type__c != 'Menu'] );
        
        map<Id, IntranetContainer> mapIntranetContainer = new map<Id, IntranetContainer>();
        
        for (Intranet_Container__c container : mapContainers.values()) {
        
            mapIntranetContainer.put(container.Id, new IntranetContainer(container));
            
            //Check if default Content Id is not null, add in map
            if(container.Default_Content_Item__c != null) {
                
                //Add in Map
                mapContainerIdWithDefaultContentItemId.put(container.Id, container.Default_Content_Item__c);
                mapDefaultContentitemIdWithContainerId.put(container.Default_Content_Item__c, container.Id);
            }
        }
        
        return mapIntranetContainer;
    }
    
    public Map<Id, IntranetContainer> GetContainersByTopParentForHeader(String topParentContainerId) {
        
        if(topParentContainerId != null) topParentContainerId = topParentContainerId.substring(0,15);
        
        Map <Id, Intranet_Container__c> mapContainers = new map <Id, Intranet_Container__c>(
                [SELECT Id, Name, Container_Type__c, Container_Level__c, Parent_Container__c,
                 Header_Container__c, Footer_Container__c, Status__c, Display_Name__c, 
                 Default_Content_Item__c, Show_Expand_Link__c, Top_Parent_Container_Id__c, 
                 Top_Parent_Container__c, Height__c, Width__c, Max_Content_Items__c,
                 Reference_Number__c, Content_Types_Allowed__c, Minimum_Visible_Screen__c, Position__c,
                 Show_Feedback_Link__c, Sort_Order__c
                 FROM Intranet_Container__c
                 WHERE Top_Parent_Container_Id__c = :topParentContainerId AND Status__c = 'Active'] );
        
        map<Id, IntranetContainer> mapIntranetContainer = new map<Id, IntranetContainer>();
       
        for (Intranet_Container__c container : mapContainers.values()) {
        
            mapIntranetContainer.put(container.Id, new IntranetContainer(container));
            
            //Check if default Content Id is not null, add in map
            if(container.Default_Content_Item__c != null) {
                
                //Add in Map
                mapContainerIdWithDefaultContentItemId.put(container.Id, container.Default_Content_Item__c);
                mapDefaultContentitemIdWithContainerId.put(container.Default_Content_Item__c, container.Id);
            }
        }
        
        return mapIntranetContainer;
    }
    
    public static Map<Id, IntranetContainer> GetContainersByTopParentContainerId(String topParentContainerId) {

        if(topParentContainerId != null) topParentContainerId = topParentContainerId.substring(0,15);
        
        Map <Id, Intranet_Container__c> mapContainers = new map <Id, Intranet_Container__c>(
                [SELECT Id, Name, Container_Type__c, Container_Level__c, Parent_Container__c,
                 Header_Container__c, Footer_Container__c, Status__c, Display_Name__c, 
                 Default_Content_Item__c, Show_Expand_Link__c, Top_Parent_Container_Id__c, 
                 Top_Parent_Container__c, Height__c, Width__c, Max_Content_Items__c,
                 Reference_Number__c, Content_Types_Allowed__c, Minimum_Visible_Screen__c, Position__c,
                 Show_Feedback_Link__c, Sort_Order__c
                 FROM Intranet_Container__c
                 WHERE Top_Parent_Container_Id__c = :topParentContainerId AND Status__c = 'Active']);
        
        map<Id, IntranetContainer> mapIntranetContainer = new map<Id, IntranetContainer>();
        
        for (Intranet_Container__c container : mapContainers.values()) {
            mapIntranetContainer.put(container.Id, new IntranetContainer(container));
        }
        
        return mapIntranetContainer;
    }
    
    public static IntranetContainer GetContainer(Id containerId) {
        
        Intranet_Container__c container = 
            [SELECT Id, Name, Container_Type__c, Container_Level__c, Parent_Container__c,
             Header_Container__c, Footer_Container__c, Status__c, Display_Name__c, 
             Default_Content_Item__c, Show_Expand_Link__c, Top_Parent_Container_Id__c, 
             Top_Parent_Container__c, Height__c, Width__c, Max_Content_Items__c,
             Reference_Number__c, Content_Types_Allowed__c, Minimum_Visible_Screen__c, Position__c,
             Show_Feedback_Link__c, Sort_Order__c
             FROM Intranet_Container__c
             WHERE Id = :containerId];
        IntranetContainer ic = new IntranetContainer(container);
        
        return ic;
    }
    
    public static Map<Id, Intranet_Schedule__c> GetSchedules(Set<Id> containerIds, String previewScheduleId) {
        
        //Modified By Mahendra Swarnkar - CR-20170918-11372 - 09/28/2017  - Added "Entity__c" field in the query.
        Map <Id, Intranet_Schedule__c> mapSchedules = new Map <Id, Intranet_Schedule__c> (
            [SELECT Id, Name, Intranet_Container__c, Intranet_Item__c, Active_Status__c,
             Approval_Status__c, Intranet_Container__r.DPA_Score_Type__c, Importance__c,
             Office__r.Name, Level__c, Department__c, Division__c, Function__c, Start_Date_Time__c,
             End_Date_Time__c, Timeline_Emphasis__c, Manager_Level_Only__c, Critical_Visibility__c, 
             Office__r.Office_Short_Name__c, Entity__c
             from Intranet_Schedule__c where Intranet_Container__c IN :containerIds
                AND (Id = :previewScheduleId OR Is_Visible__c = true) AND Intranet_Item__c != null
                AND (Start_Date_Time__c <= :system.today().addDays(30) OR Start_Date_Time__c = null) 
                AND Is_Visible__c = true AND Intranet_Item__c != null
                AND (Intranet_Item__r.Event_Start_Date_Time__c <= :system.today().addDays(30) OR Intranet_Item__r.Event_Start_Date_Time__c = null)
                AND (Intranet_Item__r.Event_End_Date_Time__c <= :system.today().addDays(30) OR Intranet_Item__r.Event_End_Date_Time__c = null)
                ORDER BY Start_Date_Time__c DESC]);
        
        return mapSchedules;
    }
    /**
     * V_1.5 - Modified By - Rajeev Jain - CR-20150611-9000 - 06/17/2015 - BoardRoom Preview of Schedule item
     *  07/24/2015 - Prior to migration to testSandbox - Changes Merged from Prevuious release with BoardRoom Mobile Release
     * Description : Method modified to add another query to show schdeule as preview on the board room page.
     *              Here we checked if Preview is true in the URL,then query will fire for preview schedule.
    **/ 
    public static Map<Id, Intranet_Schedule__c> GetSchedules(Set<Id> containerIds, String previewScheduleId, Date endDate, Boolean isForPreview) {
        
        Map <Id, Intranet_Schedule__c> mapSchedules;
        if(isForPreview){
            
            //Modified By Mahendra Swarnkar - CR-20170918-11372 - 09/28/2017  - Added "Entity__c" field in the query.
            //Modified By Mahendra Swarnkar - Issue--CR11642--QA--00007340  11/6/2017  - Added "AND" condition to check Entity =: User.Entity 
            mapSchedules = new Map <Id, Intranet_Schedule__c> (
            [SELECT Id, Name, Intranet_Container__c, Intranet_Item__c, Active_Status__c,
             Approval_Status__c, Intranet_Container__r.DPA_Score_Type__c, Importance__c,
             Office__r.Name, Level__c, Department__c, Division__c, Function__c, Start_Date_Time__c,
             End_Date_Time__c, Timeline_Emphasis__c, Manager_Level_Only__c, Critical_Visibility__c, 
             Office__r.Office_Short_Name__c, Entity__c
             from Intranet_Schedule__c where Intranet_Container__c IN :containerIds
             AND (Id =: previewScheduleId OR Is_Visible__c = true) 
             AND Intranet_Item__c != null
             AND Entity__c =: IntranetHomeUtility.getUserSession.UserEntity
             AND (Intranet_Item__r.Event_Start_Date_time__c = null OR Intranet_Item__r.Event_Start_Date_time__c <= NEXT_N_DAYS:30)
             ]);
        }else{
            
            //Modified By Mahendra Swarnkar - CR-20170918-11372 - 09/28/2017  - Added "Entity__c" field in the query.
            mapSchedules = new Map <Id, Intranet_Schedule__c> (
            [SELECT Id, Name, Intranet_Container__c, Intranet_Item__c, Active_Status__c,
             Approval_Status__c, Intranet_Container__r.DPA_Score_Type__c, Importance__c,
             Office__r.Name, Level__c, Department__c, Division__c, Function__c, Start_Date_Time__c,
             End_Date_Time__c, Timeline_Emphasis__c, Manager_Level_Only__c, Critical_Visibility__c, 
             Office__r.Office_Short_Name__c, Entity__c
             from Intranet_Schedule__c where Intranet_Container__c IN :containerIds
                AND (Start_Date_Time__c <= :system.today().addDays(30) OR Start_Date_Time__c = null) 
                AND (End_Date_Time__c >= TODAY OR End_Date_Time__c = null)
                AND Is_Visible__c = true AND Intranet_Item__c != null
                AND (Intranet_Item__r.Event_Start_Date_Time__c <= :system.today().addDays(15) OR Intranet_Item__r.Event_Start_Date_Time__c = null)
                AND (Intranet_Item__r.Event_End_Date_Time__c <= :system.today().addDays(30) OR Intranet_Item__r.Event_End_Date_Time__c = null)
             ORDER BY Start_Date_Time__c DESC]);
        }
        return mapSchedules;
    }
    
    public static Map<Id, Intranet_Schedule__c> GetSchedulesForIntranetContentViewer(Set<Id> containerIds, String previewScheduleId) {
        
        //Modified By Mahendra Swarnkar - CR-20170918-11372 - 09/28/2017  - Added "Entity__c" field in the query.
        Map <Id, Intranet_Schedule__c> mapSchedules = new Map <Id, Intranet_Schedule__c> (
            [SELECT Id, Name, Intranet_Container__c, Intranet_Item__c, Active_Status__c,
             Approval_Status__c, Intranet_Container__r.DPA_Score_Type__c, Importance__c,
             Office__r.Name, Level__c, Department__c, Division__c, Function__c, Start_Date_Time__c,
             End_Date_Time__c, Timeline_Emphasis__c, Manager_Level_Only__c, Critical_Visibility__c, 
             Office__r.Office_Short_Name__c, Entity__c
             from Intranet_Schedule__c where Intranet_Container__c IN :containerIds
                AND (Id = :previewScheduleId OR Is_Visible__c = true) AND Intranet_Item__c != null
             ORDER BY CreatedDate DESC]);
                
        return mapSchedules;
    }
    
    public static Map<Id, Intranet_Schedule__c> GetOfficeSchedules(Set<Id> containerIds, String officeId, String previewScheduleId) {
        if(previewScheduleId != null) previewScheduleId = previewScheduleId.substring(0,15);
        if(officeId != null) officeId = officeId.substring(0,15);
        
        //Modified By Mahendra Swarnkar - CR-20170918-11372 - 09/28/2017  - Added "Entity__c" field in the query.
        Map <Id, Intranet_Schedule__c> mapSchedules = new Map<Id, Intranet_Schedule__c> (
            [SELECT Id, Name, Intranet_Container__c, Intranet_Item__c, Active_Status__c,
             Approval_Status__c, Intranet_Container__r.DPA_Score_Type__c, Importance__c,
             Office__r.Name, Level__c, Department__c, Division__c, Function__c, Start_Date_Time__c,
             End_Date_Time__c, Timeline_Emphasis__c, Manager_Level_Only__c, Critical_Visibility__c, 
             Office__r.Office_Short_Name__c, Entity__c
             from Intranet_Schedule__c
             WHERE  (Intranet_Item__c != null) AND
                    (
                        (Intranet_Container__c IN :containerIds AND Is_Visible__c = true AND Office__c = :officeId) OR
                        (Intranet_Container__r.Container_Type__c = 'News Carousel' AND Is_Visible__c = true AND Office__c = :officeId) OR
                        (Id = :previewScheduleId)
                    )]);
        
        return mapSchedules;
    }
    
    // Search Item by itemIds alone or itemType or date range.  
    // V_1.6 - Modified By - Abhinav Sharma - CR-20140930-7520 - 07/16/2015 - Added new field 'Video_Link_Image_Url__c' in query
    //07/24/2015 - Prior to migration to testSandbox - Changes Merged from Prevuious release with BoardRoom Mobile Release
    public static Map <Id, Intranet_Item__c> GetContentItems(Set <Id> ItemIds, String itemType, DateTime startDate, DateTime endDate) {
       
        Map <Id, Intranet_Item__c> mapItem;
        //Modified by Mahendra Swarnakar - 05/05/2020 - CR-20200218-13769 - article_author__c,Background_Color__c, 
        //Color_Set_Reference_Name__c,color_set_type__c,expiration_date__c, first_available__c deleted
        if(startDate != null && endDate != null) {
            mapItem = new Map <Id, Intranet_Item__c> (
                [SELECT Id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Ad_Hoc_Main_Image_Id__c,
                 Ad_Hoc_Thumbnail_Image_Id__c, Alternate_Content__c, Approval_Status__c, Average_Utilization_Rating__c,
                 /*Article_Author__c,*/ Article_Publish_Date__c, Article_Type__c, Background_Color_Code__c, 
                 Category_Name__c, Citation__c, City__c, Change_Configuration_Item__c, Color_Set__c, Color_Set_Name__c,
                 /*Color_Set_Reference_Name__c, Color_Set_Type__c,*/ Configuration_Item__c, Content_Author_Speaker__c,
                 Content_Length__c, Name, Item_Title__c,Create_Source__c, Sort_Order__c, Active_Status__c, Link_URL__c, Link_Type__c,
                 Item_Full_Text__c, Item_Abstract__c, Category_Reference_Name__c, Content_URL__c, /*Background_Color__c,*/
                 Item_Subtitle__c, Chatter_Comments_Rollup__c, Chatter_Likes__c, Chatter_Shares__c, Content_Main_Image_Id__c,
                 Content_Main_Image__c, Content_Thumbnail_Image__c, Content_Thumbnail_Image_Id__c, Office_Name__c, Permalink__c,
                 Content_Publish_Date__c, Event_Start_Date_Time__c, Event_End_Date_Time__c, /*Final_Expiration__c,*/
                 Show_Main_Image_in_Content_Viewer__c, Room_Name__c, Room_Number__c, Floor__c, Image_Set_Reference_Name__c,
                 /*First_Available__c,*/ Image_Set_Main_Image_Id__c, Link_Action__c, Item_Type__c, Text_Box_Back_Color__c,
                 Text_Box_Visible__c, Text_Box_Text_Color__c, Container_Class__c, Icon_Style__c, Location_City__c,
                 DPA_Score_Type__c, Display_Name__c, Show_Expand_Link__c, Track_Utilization__c, Unique_Id__c, Link_Behaviour__c,
                 Content_URL_Validated__c, Link_URL_Validated__c, Secondary_Link_1_Location_Validated__c, Permalink_Validated__c,
                 Track_Frequent_App__c, Secondary_Link_1_Location__c, Global_Available_Date__c, Default_Content_Flag__c,
                 /*Expiration_Date__c,*/ Secondary_Link_1_Name__c, Secondary_Link_2_Action__c, Secondary_Link_2_Name__c,
                 SubHeading__c, View_Count__c, Is_Visible__c, Secondary_Link_1_Action__c, Poll_Id__c, Main_Category__c,
                 ABC_Network_Only__c, Birthdays_Cache__c, Last_Content_Update__c, /*Location__c,*/ Location__Latitude__s,
                 Location__Longitude__s, Weather_Response__c, Update_Weather_Now__c, Trend_Type__c, Trending_View_Count__c,Video_Link_Image_Url__c
                 FROM Intranet_Item__c
                 WHERE (Id IN :ItemIds) AND ( (Event_Start_Date_Time__c <= :startDate AND Event_End_Date_Time__c > :startDate) OR 
                       (Event_Start_Date_Time__c <= :endDate AND Event_End_Date_Time__c > :endDate) OR 
                       (Event_Start_Date_Time__c >= :startDate AND Event_End_Date_Time__c < :endDate) OR
                       (Event_Start_Date_Time__c = null AND Event_End_Date_Time__c = null) )]);
            
        } else if(itemType != null) {
            mapItem = new Map <Id, Intranet_Item__c> (
                [SELECT Id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Ad_Hoc_Main_Image_Id__c,
                 Ad_Hoc_Thumbnail_Image_Id__c, Alternate_Content__c, Approval_Status__c, Average_Utilization_Rating__c,
                 /*Article_Author__c,*/ Article_Publish_Date__c, Article_Type__c, Background_Color_Code__c, 
                 Category_Name__c, Citation__c, City__c, Change_Configuration_Item__c, Color_Set__c, Color_Set_Name__c,
                 /*Color_Set_Reference_Name__c, Color_Set_Type__c,*/ Configuration_Item__c, Content_Author_Speaker__c,
                 Content_Length__c, Name, Item_Title__c, Create_Source__c, Sort_Order__c, Active_Status__c, Link_URL__c, Link_Type__c,
                 Item_Full_Text__c, Item_Abstract__c, Category_Reference_Name__c, Content_URL__c, /*Background_Color__c,*/
                 Item_Subtitle__c, Chatter_Comments_Rollup__c, Chatter_Likes__c, Chatter_Shares__c, Content_Main_Image_Id__c,
                 Content_Main_Image__c, Content_Thumbnail_Image__c, Content_Thumbnail_Image_Id__c, Office_Name__c, Permalink__c,
                 Content_Publish_Date__c, Event_Start_Date_Time__c, Event_End_Date_Time__c, /*Final_Expiration__c,*/
                 Show_Main_Image_in_Content_Viewer__c, Room_Name__c, Room_Number__c, Floor__c, Image_Set_Reference_Name__c,
                 /*First_Available__c,*/ Image_Set_Main_Image_Id__c, Link_Action__c, Item_Type__c, Text_Box_Back_Color__c,
                 Text_Box_Visible__c, Text_Box_Text_Color__c, Container_Class__c, Icon_Style__c, Location_City__c,
                 DPA_Score_Type__c, Display_Name__c, Show_Expand_Link__c, Track_Utilization__c, Unique_Id__c, Link_Behaviour__c,
                 Content_URL_Validated__c, Link_URL_Validated__c, Secondary_Link_1_Location_Validated__c, Permalink_Validated__c,
                 Track_Frequent_App__c, Secondary_Link_1_Location__c, Global_Available_Date__c, Default_Content_Flag__c,
                 /*Expiration_Date__c,*/ Secondary_Link_1_Name__c, Secondary_Link_2_Action__c, Secondary_Link_2_Name__c,
                 SubHeading__c, View_Count__c, Is_Visible__c, Secondary_Link_1_Action__c, Poll_Id__c, Main_Category__c,
                 ABC_Network_Only__c, Birthdays_Cache__c, Last_Content_Update__c,/*Location__c,*/ Location__Latitude__s,
                 Location__Longitude__s, Weather_Response__c, Update_Weather_Now__c, Trend_Type__c, Trending_View_Count__c,Video_Link_Image_Url__c
                 FROM Intranet_Item__c WHERE Id IN :ItemIds AND Item_Type__c = :itemType]);
            
        } else {    
            mapItem = new Map <Id, Intranet_Item__c> (
                [SELECT Id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Ad_Hoc_Main_Image_Id__c,
                 Ad_Hoc_Thumbnail_Image_Id__c, Alternate_Content__c, Approval_Status__c, Average_Utilization_Rating__c,
                 /*Article_Author__c,*/ Article_Publish_Date__c, Article_Type__c, Background_Color_Code__c, 
                 Category_Name__c, Citation__c, City__c, Change_Configuration_Item__c, Color_Set__c, Color_Set_Name__c,
                 /*Color_Set_Reference_Name__c, Color_Set_Type__c,*/ Configuration_Item__c, Content_Author_Speaker__c,
                 Content_Length__c, Name, Item_Title__c,Create_Source__c, Sort_Order__c, Active_Status__c, Link_URL__c, Link_Type__c,
                 Item_Full_Text__c, Item_Abstract__c, Category_Reference_Name__c, Content_URL__c, /*Background_Color__c,*/
                 Item_Subtitle__c, Chatter_Comments_Rollup__c, Chatter_Likes__c, Chatter_Shares__c, Content_Main_Image_Id__c,
                 Content_Main_Image__c, Content_Thumbnail_Image__c, Content_Thumbnail_Image_Id__c, Office_Name__c, Permalink__c,
                 Content_Publish_Date__c, Event_Start_Date_Time__c, Event_End_Date_Time__c, /*Final_Expiration__c,*/
                 Show_Main_Image_in_Content_Viewer__c, Room_Name__c, Room_Number__c, Floor__c, Image_Set_Reference_Name__c,
                 /*First_Available__c,*/ Image_Set_Main_Image_Id__c, Link_Action__c, Item_Type__c, Text_Box_Back_Color__c,
                 Text_Box_Visible__c, Text_Box_Text_Color__c, Container_Class__c, Icon_Style__c, Location_City__c,
                 DPA_Score_Type__c, Display_Name__c, Show_Expand_Link__c, Track_Utilization__c, Unique_Id__c, Link_Behaviour__c,
                 Content_URL_Validated__c, Link_URL_Validated__c, Secondary_Link_1_Location_Validated__c, Permalink_Validated__c,
                 Track_Frequent_App__c, Secondary_Link_1_Location__c, Global_Available_Date__c, Default_Content_Flag__c,
                 /*Expiration_Date__c,*/ Secondary_Link_1_Name__c, Secondary_Link_2_Action__c, Secondary_Link_2_Name__c,
                 SubHeading__c, View_Count__c, Is_Visible__c, Secondary_Link_1_Action__c, Poll_Id__c, Main_Category__c,
                 ABC_Network_Only__c, Birthdays_Cache__c, Last_Content_Update__c,/*Location__c,*/ Location__Latitude__s,
                 Location__Longitude__s, Weather_Response__c, Update_Weather_Now__c, Trend_Type__c, Trending_View_Count__c,Video_Link_Image_Url__c
                 FROM Intranet_Item__c WHERE Id IN :ItemIds]);
        }
        
        return mapItem;
    }
    //V_1.7 - Modified By - Rajeev Jain - CR-20150618-9016 - 07/08/2015 - BoardRoom Mobile - Phase 2
    //CR-20141003-7624 (Rajeev Jain 05/01/2015) Added new method called on page load used to create utilization record on page load
    //Start from here
    //Callling future method from here
    /*public void createUtlizationRecordOnMainPageLoad(){
        
        //Check if the page is boardRoom main page then call future method from hare
        //Rajeev Jain(05/01/2015) Create Utilization record for BoardRoom Main page load
        //Create Utilization Record only for BoardRoom Main Page
        if(ApexPages.currentPage().getUrl().containsIgnoreCase(System.Label.BR_Home))
            RemoteActionController.recordClickUtilization('Page Section', 'BoardRoom Home Page', null, null, null, null);
    }*/
    //Upto here
}