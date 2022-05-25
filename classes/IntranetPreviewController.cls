public class IntranetPreviewController {

    public IntranetContainer iContainer {get; set;}
    //public list<IntranetContent> iRelatedContent {get; set;}
    
    Id samplePageId = 'a00M0000003Eoqt';
    
    public IntranetPreviewController(){
        if(iContainer == null){
            //SelectContainer();
        }
    }
	/*
    public void SelectContainer(){
        
        Intranet_Container__c ic;
        
        ic = [select Id, Name, Container_Type__c, Container_Level__c, Parent_Container__c, Status__c, Display_Name__c, Default_Content_Item__c,
                      Show_Expand_Link__c, Top_Parent_Container_Id__c, Height__c, Width__c, Has_SubContainers__c, Max_Content_Items__c, Reference_Number__c,
                        Content_Types_Allowed__c, Minimum_Visible_Screen__c, Position__c, Screen_Priority__c, Show_Feedback_Link__c
                      from Intranet_Container__c
                     where id = :samplePageId];
        system.debug('IntranetPreviewController.BuildContainer - ic: '+ic);
        
        iContainer = new IntranetContainer(ic);
        system.debug('IntranetPreviewController.BuildContainer - iContainer: '+iContainer);
        
        map<Id,Intranet_Schedule__c> iScheds = new map<Id,Intranet_Schedule__c>([select Id, Name, Intranet_Container__c, Intranet_Item__c, Active_Status__c,
                                                                               Approval_Status__c
                                                                               from Intranet_Schedule__c
                                                                               where Intranet_Container__c = :ic.Id]);
        system.debug('IntranetPreviewController.BuildContainer - iScheds: '+iScheds);
        
        Set<Id> ItemIds = new set<Id>();
        for(Intranet_Schedule__c x : iScheds.values()){
            ItemIds.add(x.Intranet_Item__c); 
        }
        system.debug('IntranetPreviewController.BuildContainer - itemIds: '+itemIds);
        
        map<Id,Intranet_Item__c> iItems = new map<Id,Intranet_Item__c>([select Id, Name, Item_Title__c, Sort_Order__c, Active_Status__c//, //Link_Location__c
                                                                       from Intranet_Item__c
                                                                       where Id in :itemIds]);
        system.debug('IntranetPreviewController.BuildContainer - iItems: '+iItems);
        
        //for(Intranet_Schedule__c schedItem : iScheds.values()){
        //    IntranetContent i = new IntranetContent(SchedItem,iItems.get(SchedItem.Intranet_Item__c));
        //    iContainer.RelatedContent.add(i);
        //}
        system.debug('IntranetPreviewController.BuildContainer - iContainer(2): '+iContainer);
    }
    */
}