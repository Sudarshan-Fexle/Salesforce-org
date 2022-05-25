public class IntranetInternalPageController extends IntranetBaseController {

    public IntranetContainer Container {get; private set;}
    public IntranetContainer ContainerBookmarks {get; private set;}
    public IntranetContainer ContainerActions {get; private set;}
    
    private Map <Id, IntranetContainer> MainPageContainerHierarchy {get; set;}
    
    private Map<Id, IntranetContainer> MainPageContainerMap;
      
    //Constructor
    public IntranetInternalPageController() {
        super();
        LoadData();
    }
    
    public PageReference LoadData(){
        
        if(Container == null) {
        
            this.MainPageContainerMap = BoardroomHomeContainerController.GetContainersByTopParentContainerId(IntranetMainPageId);
            this.Container = MainPageContainerMap.get(IntranetMainPageId);
            
            GetMainPageContent();
            
            BuildContainerHierarchy(previewContentId);

            // Replicate main container's subcontainer to Bookmark
            if(ContainerBookmarks !=null ) {
                ContainerBookmarks.SubContainers.addAll(Container.SubContainers);
            }
        }
        
        return null;
    }
    
    public string getDataString() {
        return '<p>Main:<br/>' + this.Container.ToString('') + 
                    '</p><p>Bookmarks:<br/>' + ContainerBookmarks.ToString('') +
                    '</p><p>Actions:<br/>' + ContainerActions.ToString('') + '</p>';
    }
    
    public void GetMainPageContent() {
        
        IntranetType.UserSession userSession = IntranetHomeUtility.getUserSession;
        
        Map<string, Intranet_Utilization__c> maplikedItems = IntranetUtilizationHelper.getLikedItems();
            
        //Queries all Schedules associated with the Containers queried above
        Map <Id, Intranet_Schedule__c> AssociatedSchedules = BoardroomHomeContainerController.GetSchedulesForIntranetContentViewer(MainPageContainerMap.keySet(), SchedId);
        
        // Get preview container id and preview item ids
        if(IsPreview && AssociatedSchedules.containsKey(SchedId)) {
            this.PreviewContainerId = AssociatedSchedules.get(SchedId).Intranet_Container__c;    
        }
        
        Set <Id> ItemIds = new Set<Id>();
        for (Intranet_Schedule__c scheduleId : AssociatedSchedules.values()) {
            ItemIds.add(ScheduleId.Intranet_Item__c);
            if(IsPreview && scheduleId.Id == SchedId) {
                this.PreviewContentId = ScheduleId.Intranet_Item__c;
            }
        }
                     
        //Grabs all Items associated with the Schedules queried for above
        Map <Id, Intranet_Item__c> AssociatedItems = BoardroomHomeContainerController.GetContentItems(ItemIds, null, null, null);
        
        Map<Id, IntranetContent> IntranetContentMap = new Map<Id, IntranetContent>();
        for (Intranet_Schedule__c schedule : AssociatedSchedules.values()) {
            IntranetContainer container = MainPageContainerMap.get(schedule.Intranet_Container__c);
            container.IsPreview = IsPreview && container.ContainerId == this.PreviewContainerId;
            IntranetContent sc = new IntranetContent(container, schedule,
                AssociatedItems.get(schedule.Intranet_Item__c), userSession, maplikedItems);
            container.RelatedContent.add(sc);
        }
    }
    
    public void BuildContainerHierarchy(Id previewItemId) {
        for (IntranetContainer ic : MainPageContainerMap.values()) {
            if(ic.ContainerId == IntranetMainPageId) {
                // Skip the top Container
                continue;
            }
            if (ic.ParentContainerId == IntranetMainPageId && ic.ContainerName == 'Page Bookmarks') {
                ContainerBookmarks = ic;
                continue;
            }
            if(ic.ParentContainerId == IntranetMainPageId && ic.ContainerName == 'Page Actions') {
                ContainerActions = ic;
                continue;
            }
            
            IntranetContainer pc = MainPageContainerMap.get(ic.ParentContainerId);
            if(pc != null)
                pc.SubContainers.Add(ic);
        }
        
        for (IntranetContainer ic : MainPageContainerMap.values()) {
            ic.SubContainers.sort();
            SortLimitContainerContent(ic, previewItemId);
        }
    }
    
    public static void SortLimitContainerContent(IntranetContainer ic, Id previewItemId) {
        if(ic == null) return;
        
        // Move the preview item to top of the list.
        if(ic.IsPreview && previewItemId != null) {
            decimal MinSortOrder = -100;
            for(IntranetContent sc : ic.RelatedContent) {
                if(sc.SortOrder < MinSortOrder) MinSortOrder = sc.SortOrder;
            }
            for(IntranetContent sc : ic.RelatedContent) {
                if(previewItemId != null && previewItemId == sc.IntranetItemId) {
                    sc.SortOrder = MinSortOrder - 100;
                }
            }
        }
        ic.RelatedContent.sort();
        
        //Check if the size of the Container's RelatedContent is larger than the IntranetContainer's MaxContentItems field value.  
        if(ic.MaxContentItems != null && ic.RelatedContent.size() > ic.MaxContentItems) {
    
            //Maximum Allowed Size
            Integer maxAllowedSize = Integer.valueOf(ic.MaxContentItems);
            Integer currentSize = ic.RelatedContent.size();
            
            //If so, keep only the first ones in the Related Content list up to the number of MaxContentItems
            //This will limit the amount of data being sent to the View State for the main Intranet page
            for(Integer i = currentSize -1; i >= currentSize; i++) {
            
                //Remove from list
                ic.RelatedContent.remove(i);
            }
        }
        
        if(ic.ContainerType == 'Flexible') { 
            
            // Locate the first Item
            if(ic.RelatedContent.size() > 0) {
            	
                IntranetContent content = ic.RelatedContent.get(0);
                String itemType = content.ItemType;
                Integer maxItem = itemType == 'Ad Item'? 1 : (integer) ic.MaxContentItems;
            
                if(maxItem > 0) {
                
                    while(ic.RelatedContent.size() > maxItem) {
                    	ic.RelatedContent.remove(ic.RelatedContent.size() - 1);
                    }
                }
                
                if(itemType == 'Ad Item' || itemType == 'Job Item' || itemType == 'Talent Item')
                    ic.ContainerClass = content.ContainerClass;
            }
        }
        
        if(ic.SubContainers != null) {
        
            for (IntranetContainer subContainer : ic.SubContainers) {
                SortLimitContainerContent(subContainer, previewItemId);
            }
        }
        
        //Update the field MaxContentItems in IntranetContainer to the value in MaxContentItems in the custom setting 
        //where the Custom Setting Name field equals the top item's Item Type fie
        if(ic.RelatedContent.size() > 0) {
            
            //Intranet Defaults
            Map<String, Intranet_Defaults__c> mapIntranetDefaults = Intranet_Defaults__c.getAll();
            
            //IntranetContent
            IntranetContent intranetContent = ic.RelatedContent.get(0);
            if(intranetContent != null && String.isNotBlank(intranetContent.ItemType) 
                    && mapIntranetDefaults.containsKey(intranetContent.ItemType) 
                    && mapIntranetDefaults.get(intranetContent.ItemType).Max_Content_Items__c != null) {
                
                //Update MaxContentSize in container
                ic.MaxContentItems = mapIntranetDefaults.get(intranetContent.ItemType).Max_Content_Items__c;         
            }
        }
    }
}