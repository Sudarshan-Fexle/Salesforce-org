//Modified By - Mahendra Swarnkar via - Issue--CR11372--QA--00006986 - 10/17/2017 - added the new property "UserSessionEntity" - Starts from here
//V1.1 Modified By - Rajiv Jain - 02/19/2020 - CR-20190929-13382 -  Remove zzzHas Subcontainers(Has_SubContainers__c) field of Intranet_Container__c object.
//                                                                   Remove zzzScreen Priority(Screen_Priority__c) field of Intranet_Container__c object.
public class IntranetContainer implements Comparable {
//public interface Container {
        
    public string ContainerName {get;set;}
    public string ContainerType {get; set;}
    public Id HeaderContainer {get; set;}
    public Id FooterContainer {get; set;}
    public String ContainerLevel {get; set;}
    public Id ContainerId {get; set;}
    public Decimal MaxContentItems {get; set;}
    public Id ParentContainerId {get; set;}
    public String ReferenceNumber {get; set;}
    public String Status {get; set;}
    public String ContentTypesAllowed {get; set;}
    public String DisplayName {get; set;}
    public Id DefaultContentItem {get; set;}
    public String MinimumVisibleScreen {get; set;}
    public String Name {get; set;}
    public String Position {get; set;}
    public Decimal ScreenPriority {get; set;}
    public boolean ShowExpandLink {get; set;}
    public boolean ShowFeedbackLink {get; set;}
    public Decimal SortOrder {get; set;}
    public Id TopContainerId {get; set;}
    public String TopParentContainerURL {get; set;}
    public decimal Height {get; set;}
    public decimal Width {get; set;}
    public string ContainerClass {get; set;}
    public string DPAScoreType {get; set;}
    public Boolean IsPreview { get; set;}
    
    //Modified By - Mahendra Swarnkar via - Issue--CR11372--QA--00006986 - 10/17/2017 - added the new property "UserSessionEntity" - Starts from here
    public String UserSessionEntity  { get; set;}
    //Modified By - Mahendra Swarnkar via - Issue--CR11372--QA--00006986 - 10/17/2017 - added the new property "UserSessionEntity" - Ends here
    
    private boolean checkSubContainers = false;
    private boolean mHasSubContainers;
    
    public boolean getHasSubContainers() {
        if(checkSubContainers)
            return this.SubContainers != null && SubContainers.size() > 0;
        
        return mHasSubContainers;
    }
    
    public list<IntranetContainer> SubContainers {get; set;}
    public list<IntranetContent> RelatedContent {get; set;}
    /*public map<String, List <IntranetContent>> RelatedContentByItemType {
        get{
            if(RelatedContent != null && RelatedContentByItemType == null){
                RelatedContentByItemType = new map<String, List <IntranetContent>>();
                for (IntranetContent ic : RelatedContent){
                    List <IntranetContent> iclist = RelatedContentByItemType.get(ic.ItemType);
                    if (iclist == null){
                        iclist = new List <IntranetContent>();       
                    }
                    iclist.add(ic);
                    RelatedContentByItemType.put(ic.ItemType,iclist);
                } 
            }
            return RelatedContentByItemType;
        }
        set;
    }*/

    public IntranetContainer(){}
    
    public IntranetContainer(Intranet_Container__c con){
        ContainerType           = con.Container_Type__c;
        
        if(con.Container_Type__c == 'Flexible'){
            ContainerName = con.Container_Type__c + '_' + con.Position__c;
        }else{
            ContainerName = con.Container_Type__c;
        }
        ContainerId             = con.Id;
        ContainerLevel          = con.Container_Level__c;
        /*---------Start ---  V1.1 Modified By - Rajiv Jain - 19/02/2020 - CR-20190929-13382 -  Remove zzzHas Subcontainers(Has_SubContainers__c) field. ----
         mHasSubContainers       = con.Has_SubContainers__c
         ---------------------End---------------------------------------*/
        if(con.Max_Content_Items__c != null)
            MaxContentItems = con.Max_Content_Items__c;
        else
            MaxContentItems = 0;
        
        ParentContainerId       = con.Parent_Container__c;
        ReferenceNumber         = con.Reference_Number__c;
        Status                  = con.Status__c; 
        ContentTypesAllowed     = con.Content_Types_Allowed__c;
        DisplayName             = con.Display_Name__c;
        DefaultContentItem      = con.Default_Content_Item__c;
        MinimumVisibleScreen    = con.Minimum_Visible_Screen__c;
        Name                    = con.Name;
        Position                = con.Position__c;
        //---------Start ---  V1.1 Modified By - Rajiv Jain - 19/02/2020 - CR-20190929-13382 -  Remove zzzScreen Priority(Screen_Priority__c) field. ----
        //So comment the Screen_Priority__c field as it is deleted and assign the ScreenPriority value is zero.         
        //ScreenPriority        = con.Screen_Priority__c;
        ScreenPriority          =  0;
        //-----------End ----------
        ShowExpandLink          = con.Show_Expand_Link__c;
        ShowFeedbackLink        = con.Show_Feedback_Link__c;
        SortOrder               = con.Sort_Order__c;
        TopContainerId          = con.Top_Parent_Container_Id__c;
        TopParentContainerURL   = con.Top_Parent_Container__c;
        Height                  = con.Height__c;
        Width                   = con.Width__c;
        HeaderContainer         = con.Header_Container__c;
        FooterContainer         = con.Footer_Container__c;
        IsPreview               = false;
        
        SubContainers           = new list<IntranetContainer>();
        RelatedContent          = new list<IntranetContent>();
        
        UserSessionEntity       = IntranetHomeUtility.getUserSession.UserEntity;
        CustomizeContainer();
        if(this.SortOrder == null) this.SortOrder = 0;
    }
   
    public void CustomizeContainer() {
        if(this.ContainerType == 'ABC Today' || this.ContainerType == 'ABC Office' ||
          (this.ContainerType == 'Tab' && this.DisplayName == 'Food') )
            checkSubContainers = true;
    }
    
    public Integer compareTo(Object compareTo) {
        if(compareTo == null) return 1;
        IntranetContainer compareToContainer = (IntranetContainer)compareTo;
        if(compareToContainer == null) return 1;
        
        if ( (SortOrder == null? 0 : SortOrder) == (compareToContainer.SortOrder == null? 0 : compareToContainer.SortOrder) ) return 0;
        if ( (SortOrder == null? 0 : SortOrder) > (compareToContainer.SortOrder == null? 0 : compareToContainer.SortOrder) ) return 1;
        return -1;
    }
    
    public string ToString(string indent) {
        String printOut = indent + 'Container: (id=' + this.ContainerId + ', name=' + this.Name + ', type=' + this.ContainerName + 
            ', parentContainer=' + (this.ParentContainerId == null? '' : this.ParentContainerId) + ', sortOrder=' + this.SortOrder + 
            ', isPreview=' + this.IsPreview + ', maxContentItems=' + MaxContentItems + ')<br>';
        if(this.RelatedContent.size() > 0) {
            for(IntranetContent content : this.RelatedContent) {
                printOut = printOut + content.ToString(indent + '\t\t');
            }
        }
        if(this.SubContainers.size() > 0) {
            for(IntranetContainer container : this.SubContainers) {
                printOut = printOut + container.ToString(indent + '\t');
            }            
        }
        return printOut;
    }
}