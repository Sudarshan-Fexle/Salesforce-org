//V_1.1 - Modified By - Abhinav Sharma - CR-20150219-8692 - 04/29/2015
//V_1.2 - Modified By - Rajeev Jain - CR-20141002-7579 05/25/2015(Removed Duplicate condition for Item Type = Office Event)
//V_1.3 - Modified By - Abhinav Sharma - CR-20140930-7520 - 07/16/2015
//V_1.4 - Modified By - Rajeev Jain CR-20180919-12608 
public class IntranetContent implements Comparable {
        
    public String ItemActiveStatus {get; set;}
    public String AddressLine1 {get; set;}
    public String AddressLine2 {get; set;}
    public String AddressLine3 {get; set;}
    public String AdHocMainImageId {get; set;}
    public String AdHocThumbnailImageId {get; set;}
    public Boolean AlternateContent {get; set;}
    public String AlternateContentURL {get;set;}
    public String ApprovalStatus {get; set;}
    public Date ArticlePublishDate {get; set;}
    public String ArticleType {get; set;}
    public String ArticleAuthor {get;set;}
    public Decimal AverageRating {get; set;}
    public String BackgroundColor {get; set;}
    public String BackgroundColorCode {get; set;}
    public String CategoryName {get; set;}
    public String CategoryReferenceName {get; set;}
    public Boolean ChangeConfigItem {get; set;}
    public Decimal ChatterComments {get; set;}
    public Decimal ChatterLikes {get; set;}
    public Decimal ChatterShares {get; set;}
    public String Citation {get; set;}
    public String City {get; set;}
    public Id ColorSet {get; set;}
    public String ColorSetName {get; set;}
    public String ColorSetReferenceName {get; set;}
    public String ColorSetType {get; set;}
    public Boolean ConfigurationItem {get; set;}
    public String ContentAuthorSpeaker {get;set;}
    public String ContentMainImagePath {get; set;}
    public String ContentLength {get; set;}
    public String ContentMainImageURL {get; set;}
    public Id ContentMainImageId {get; set;}
    public DateTime ContentPublishDate {get; set;}
    public Id ContentThumbnailImageId {get; set;}
    public String ContentThumbnailImageURL {get; set;}
    public String ContentType {get; set;}
    public String ContentURL {get; set;}
    public Id ContentViewerImage {get; set;}
    public String Country {get; set;}
    public String CurrentOfficeId {get; set;}
    public Boolean DefaultContentFlag {get; set;}
    Public DateTime EventEndDateTime {get; set;}
    Public DateTime EventStartDateTime {get; set;}
    Public DateTime ExpirationDate {get; set;}
    Public String Fax {get; set;}
    public DateTime FinalExpiration {get; set;}
    public DateTime FirstAvailable {get; set;}
    Public String Floor {get; set;}
    Public String GoToMeetingLink {get; set;}
    Public String IconStyle {get; set;}
    Public String ImageForMainContent {get; set;}
    Public String ImageForThumbnail {get; set;}
    Public Id ImageSet {get; set;}
    Public Id ImageSetMainImageId {get; set;}
    Public Id ImageSetName {get; set;}
    Public String ImageSetReferenceName {get; set;}
    public String ImageSetThumbnailImageId {get; set;}
    public String ImageSetType {get; set;}
    Public Id IntranetContainer {get; set;}
    Public Boolean IsVisible {get; set;}
    Public String ItemAbstract {get; set;}
    Public String ItemFullText {get; set;}
    Public String ItemHeadline {get; set;}
    Public String ItemSubtitle {get; set;}
    public string ItemTitle {get; set;}
    Public String ItemType {get; set;}
    public Date LastContentUpdate {get; set;}
    Public Datetime LastWeatherUpdate {get; set;}
    Public String LinkAction {get; set;}
    Public String LinkLocation {get; set;}
    Public String LinkType {get; set;}
    Public String Location {get; set;}
    Public String LocationCity {get; set;}
    Public Id MainCategory {get; set;}
    public string Name {get; set;}
    Public String Office {get; set;}
    Public Decimal OfficeLatitude {get; set;}
    Public Decimal OfficeLongitude {get; set;}
    Public String OfficeName {get; set;}
    Public String OfficeNotes {get; set;}
    Public String OfficeShortName {get; set;}
    Public Id ParentContainerID {get; set;}
    Public String Permalink {get; set;}
    Public String Phone {get; set;}
    Public String PostalCode {get; set;}
    Public DateTime PublishDate {get; set;}
    //Public String RecordTypeName {get; set;}
    //Public String RecordTypeCategory {get; set;}
    Public String RelatedFirmInitiativeId {get; set;}
    Public String RelatedFirmInitiativeLink {get; set;}
    Public String RoomName {get; set;}
    Public String RoomNumber {get; set;}
    public string SecondaryLink1Action {get; set;}
    public string SecondaryLink1Location {get; set;}
    public string SecondaryLink1Name {get; set;}
    public string SecondaryLink2Action {get; set;}
    public string SecondaryLink2Location {get; set;}
    public string SecondaryLink2Name {get; set;}
    Public String SetType {get; set;}
    Public Boolean ShowMainImageInContentViewer {get; set;}
    Public decimal SortOrder {get; set;}
    Public String State {get; set;}
    Public String SubHeading {get; set;}
    Public String TextBoxBackColor {get; set;}
    Public String TextBoxBackColorCode {get; set;}
    Public String TextBoxTextColor {get; set;}
    Public Boolean TextBoxVisible {get; set;}
    Public String TextColorCode {get; set;}
    Public String ThumbnailImagePath {get; set;}
    Public Datetime CurrentTime {get; set;}
    Public String TimeZone {get; set;}
    Public String TitleTextPosition {get; set;}
    Public String TitleTextSize {get; set;}
    Public Integer TrendingViewCount {get; set;}
    Public decimal ViewCount {get; set;}
    Public String WeatherResponse {get; set;}
    public string ScheduleActiveStatus {get; set;}
    public Id IntranetContainerId {get; set;}
    public Id IntranetItemId {get; set;}
    public decimal DPAScore {get; set;}
    public Boolean ShowExpandLink {get; set;}
    public Boolean TrackUtilization {get; set; }
    public String ContainerClass { get; set; }
    public String DPAScoreType {get; set;}
    public String DisplayName { get; set; }
    public Boolean UpdateWeather {get; set;}
    public boolean ChatterIsLiked { get; set; }
    public boolean TrackFrequentApp { get; set; }
    public String UniqueId { get; set; }
    public Id IntranetScheduleId { get; set; }
    public boolean ABCNetworkOnly { get; set; }
    public boolean isRated { get; set; }
    
    //V_1.3 - Modified By - Abhinav Sharma - CR-20140930-7520 - 07/16/2015 - Added new field Video_Link_Image_Url__c
    public String VideoImageLinkUrl{get;set;}
    
    public Id PollId {get; set;} 
    public String PollSuggestAddress {get; set;} 
    public String PollSuggestSubject {get; set;}
    public Id MyPollChoiceId {get; set;} 
    public List<ConnectApi.FeedPollChoice> PollChoices { get; private set;}
    
    //Properties
    public String FirstName {get; set;}
    public String LastName {get; set;}
    public String ABCDepartment {get; set;}
    public String UserId {get; set;}
    public String SmallPhotoUrl {get; set;}
    
    //Trending
    public String Trend_Type {get; set;}
    public String Link_Location {get; set;}
    public String Article_Title {get; set;}
    public Double View_Count {get; set;}
    public Double Trending_View_Count{get; set;}
    
    //Map to hold the month name with Month number
    Map<Integer, String> mapMonthName = new Map<Integer, String> {
                                                                    1 => 'Jan',
                                                                    2 => 'Feb',
                                                                    3 => 'Mar',
                                                                    4 => 'Apr',
                                                                    5 => 'May',
                                                                    6 => 'June',
                                                                    7 => 'July',
                                                                    8 => 'Aug',                                                                 1 => 'Jan',
                                                                    9 => 'Sept',
                                                                    10 => 'Oct',
                                                                    11 => 'Nov',
                                                                    12 => 'Dec'                                                                      
                                                                };
    
    //Event Month Text
    public String Month_Name {get; set;}
    
    public Map<String,String> BoardroomColorCode {get; set;}
    public String TitleColor {get;set;}
    
    
    
    //Constructor
    public IntranetContent (IntranetContainer container, 
                           Intranet_Schedule__c 
                           sched, Intranet_Item__c item,
                           IntranetType.UserSession userSession, 
                           Map<string, Intranet_Utilization__c> maplikedItems) 
    {
        
        //Modified by Mahendra Swarnakar - 05/05/2020 - CR-20200218-13769 - article_author__c, Background_Color__c, 
        //Color_Set_Reference_Name__c, color_set_type__c, expiration_date__c deleted
        try{
        
        //Schedule Fields
        ScheduleActiveStatus    = sched.Active_Status__c;
        IntranetScheduleId      = sched.Id;
                               
        //Item Fields
        IntranetContainerId     = container.ContainerId;
        IntranetItemId          = item.Id;
        ItemActiveStatus        = item.Active_Status__c;
        AddressLine1            = item.Address_Line_1__c;
        AddressLine2            = item.Address_Line_2__c;
        AddressLine3            = item.Address_Line_3__c;
        AdHocMainImageId        = item.Ad_Hoc_Main_Image_Id__c;
        AdHocThumbnailImageId   = item.Ad_Hoc_Thumbnail_Image_Id__c;
        AlternateContent        = item.Alternate_Content__c;
        ApprovalStatus          = item.Approval_Status__c;     
        ArticlePublishDate      = item.Article_Publish_Date__c;
        ArticleType             = item.Article_Type__c;
        //ArticleAuthor           = item.Article_Author__c;
        AverageRating           = item.Average_Utilization_Rating__c;
        //BackgroundColor         = item.Background_Color__c;
        BackgroundColorCode     = item.Background_Color_Code__c;
        CategoryName            = item.Category_Name__c;
        MainCategory            = item.Main_Category__c;
        ChangeConfigItem        = item.Change_Configuration_Item__c;
        ChatterComments         = item.Chatter_Comments_Rollup__c;
        ChatterLikes            = item.Chatter_Likes__c;
        ChatterShares           = item.Chatter_Shares__c;
        Citation                = item.Citation__c;
        City                    = item.City__c;
        ColorSet                = item.Color_Set__c;
        ColorSetName            = item.Color_Set_Name__c;
        //ColorSetReferenceName   = item.Color_Set_Reference_Name__c;
        //ColorSetType            = item.Color_Set_Type__c;
        ContentMainImageURL     = item.Content_Main_Image__c;
        ContentMainImageId      = item.Content_Main_Image_Id__c;
        ContentURL              = item.Content_URL_Validated__c;
        
        CategoryReferenceName   = item.Category_Reference_Name__c;
        ContentThumbnailImageURL = item.Content_Thumbnail_Image__c;
        ContentThumbnailImageId = item.Content_Thumbnail_Image_Id__c;
        //CurrentOfficeId           = IntranetHomeUtility.UserSession.AssignedOffice(item.Office_Name__c);
        
        EventEndDateTime        = item.Event_End_Date_Time__c;
        
        EventStartDateTime      = item.Event_Start_Date_Time__c;
                               
        OfficeName              = item.Office_Name__c;
        OfficeLatitude          = item.Location__Latitude__s;
        OfficeLongitude         = item.Location__Longitude__s;
        
        
        ItemSubtitle            = item.Item_Subtitle__c;
        
        ItemAbstract            = item.Item_Abstract__c;
        
        TextBoxBackColor        = item.Text_Box_Back_Color__c;
        
        TextBoxVisible          = item.Text_Box_Visible__c;
                               
        LastWeatherUpdate       = item.Last_Content_Update__c;
        
        LinkAction              = item.Link_Behaviour__c;
        LinkLocation            = item.Link_URL_Validated__c;
        //LinkLocation            = item.Link_URL__c;
        
        //V_1.3 - Modified By - Abhinav Sharma - CR-20140930-7520 - 07/16/2015 - Added new field Video_Link_Image_Url__c
        VideoImageLinkUrl 		= item.Video_Link_Image_Url__c;  
        
        ItemType                = item.Item_Type__c;
                               
        RoomName                = item.Room_Name__c;
                               
        RoomNumber              = item.Room_Number__c;
                               
        Floor                   = item.Floor__c;
        
        
        DefaultContentFlag      = item.Default_Content_Flag__c;
        //ExpirationDate          = item.Expiration_Date__c;
        IconStyle               = item.Icon_Style__c;   
        IsVisible               = item.Is_Visible__c;
        ItemSubtitle            = item.Item_Subtitle__c;
        ItemTitle               = item.Item_Title__c;
        ItemFullText            = item.Item_Full_Text__c;
        LinkAction              = item.Link_Behaviour__c;
        LinkType                = item.Link_Type__c;
        Name                    = item.Name;
        //RecordTypeName            = item.RecordType.Name;
        //PublishDate               = item.Global_Available_Date__c;
        SecondaryLink1Action    = item.Secondary_Link_1_Action__c;
        SecondaryLink1Location  = item.Secondary_Link_1_Location_Validated__c;
        SecondaryLink1Name      = item.Secondary_Link_1_Name__c;
        SecondaryLink2Action    = item.Secondary_Link_2_Action__c;
        SecondaryLink2Name      = item.Secondary_Link_2_Name__c;
        SortOrder               = item.Sort_Order__c;
        SubHeading              = item.SubHeading__c;
        ViewCount               = item.View_Count__c;
        WeatherResponse         = item.Weather_Response__c;
        UpdateWeather           = item.Update_Weather_Now__c;
        DPAScore                = 0;
        ABCNetworkOnly          = item.ABC_Network_Only__c;
        ContentLength           = item.Content_Length__c;
        ContentPublishDate      = item.Content_Publish_Date__c;
        ContentAuthorSpeaker    = item.Content_Author_Speaker__c;
        //Modified by Rajeev Jain CR-20180919-12608 - Start here
        BoardroomColorCode 		= IntranetHomeUtility.boardRoomColorCode;
            
            if(item.Create_Source__c == 'Litmos'){
                if(BoardroomColorCode != null && BoardroomColorCode.size() > 0){
                    
                    Boolean flag = false;
                    
                    for(String title : BoardroomColorCode.keySet()){
                        
                        if(ItemTitle.contains(title)){
                            
                            //assign color to item title 
                            TitleColor = BoardroomColorCode.get(title);
                            
                            ItemTitle = ItemTitle.replace(title, '');

                            //End loop
                            break;
                            
                        }else {
                           
                            TitleColor = BoardroomColorCode.get('L&D');

                        } 
                    }
                }
            }
            else{
               
                TitleColor = '#333D47';
            }
            
         // Modified by Rajeev Jain CR-20180919-12608 - Ends here
        PollId = item.Poll_Id__c;
        Intranet_Defaults__c intranetDefault = IntranetHomeUtility.LookupIntranetDefault('Poll Item');
        if(intranetDefault != null) {
            PollSuggestAddress = intranetDefault.EmailToAddress__c;
            PollSuggestSubject = intranetDefault.EmailSubject__c;
        }
        
        if(item.Permalink__c!=null) this.Permalink = item.Permalink_Validated__c;

        CustomizeContent(container, sched, item, userSession, maplikedItems);
        if(this.SortOrder == null) this.SortOrder = 0;
        if(this.DPAScore == null) this.DPAScore = 0;      
            
        }
        catch(Exception e){
           system.assert(false ,e.getMessage()+e.getStackTraceString());
            
        }
    }
    
    public IntranetContent(IntranetContainer container, Intranet_Item__c item,
                           IntranetType.UserSession userSession, Map<string, Intranet_Utilization__c> maplikedItems) {
        
        //Schedule Fields
        IntranetContainerId     = container.ContainerId;
        IntranetItemId          = item.Id;
                
        //Modified by Mahendra Swarnakar - 05/05/2020 - CR-20200218-13769 - article_author__c, Background_Color__c, 
        //Color_Set_Reference_Name__c, color_set_type__c, expiration_date__c deleted
        //Item Fields
        ItemActiveStatus        = item.Active_Status__c;
        AddressLine1            = item.Address_Line_1__c;
        AddressLine2            = item.Address_Line_2__c;
        AddressLine3            = item.Address_Line_3__c;
        AdHocMainImageId        = item.Ad_Hoc_Main_Image_Id__c;
        AdHocThumbnailImageId   = item.Ad_Hoc_Thumbnail_Image_Id__c;
        AlternateContent        = item.Alternate_Content__c;
        ApprovalStatus          = item.Approval_Status__c;     
        ArticlePublishDate      = item.Article_Publish_Date__c;
        ArticleType             = item.Article_Type__c;
        //ArticleAuthor           = item.Article_Author__c;
        AverageRating           = item.Average_Utilization_Rating__c;
        //BackgroundColor         = item.Background_Color__c;
        BackgroundColorCode     = item.Background_Color_Code__c;
        CategoryName            = item.Category_Name__c;
        MainCategory            = item.Main_Category__c;
        ChangeConfigItem        = item.Change_Configuration_Item__c;
        ChatterComments         = item.Chatter_Comments_Rollup__c;
        ChatterLikes            = item.Chatter_Likes__c;
        ChatterShares           = item.Chatter_Shares__c;
        Citation                = item.Citation__c;
        City                    = item.City__c;
        ColorSet                = item.Color_Set__c;
        ColorSetName            = item.Color_Set_Name__c;
        //ColorSetReferenceName   = item.Color_Set_Reference_Name__c;
        //ColorSetType            = item.Color_Set_Type__c;
        ContentMainImageURL     = item.Content_Main_Image__c;
        ContentMainImageId      = item.Content_Main_Image_Id__c;
        ContentURL              = item.Content_URL_Validated__c;
        
        CategoryReferenceName   = item.Category_Reference_Name__c;
        ContentThumbnailImageURL = item.Content_Thumbnail_Image__c;
        ContentThumbnailImageId = item.Content_Thumbnail_Image_Id__c;
        
        EventEndDateTime        = item.Event_End_Date_Time__c;
        
        EventStartDateTime      = item.Event_Start_Date_Time__c;
                               
        OfficeName              = item.Office_Name__c;
        //OfficeLatitude            = item.Location__Latitude__s;
        //OfficeLongitude           = item.Location__Longitude__s;
        
        ItemSubtitle            = item.Item_Subtitle__c;
        
        ItemAbstract            = item.Item_Abstract__c;
        
        TextBoxBackColor        = item.Text_Box_Back_Color__c;
        
        TextBoxVisible          = item.Text_Box_Visible__c;
        
        LinkAction              = item.Link_Behaviour__c;
        LinkLocation            = item.Link_URL_Validated__c;
        //LinkLocation            = item.Link_URL__c;
        
        //V_1.3 - Modified By - Abhinav Sharma - CR-20140930-7520 - 07/16/2015 - Added new field Video_Link_Image_Url__c
        VideoImageLinkUrl 		= item.Video_Link_Image_Url__c;
                               
        ItemType                = item.Item_Type__c;
                               
        RoomName                = item.Room_Name__c;
                               
        RoomNumber              = item.Room_Number__c;
                               
        Floor                   = item.Floor__c;
        
        
        DefaultContentFlag        = item.Default_Content_Flag__c;
        //ExpirationDate            = item.Expiration_Date__c;
        IconStyle             = item.Icon_Style__c;   
        IsVisible             = item.Is_Visible__c;
        ItemSubtitle          = item.Item_Subtitle__c;
        ItemTitle               = item.Item_Title__c;
        ItemFullText            = item.Item_Full_Text__c;
        LinkAction                = item.Link_Behaviour__c;
        LinkType              = item.Link_Type__c;
        VideoImageLinkUrl 		= item.Video_Link_Image_Url__c;
        Name                    = item.Name;
        SecondaryLink1Action  = item.Secondary_Link_1_Action__c;
        SecondaryLink1Location    = item.Secondary_Link_1_Location_Validated__c;
        SecondaryLink1Name        = item.Secondary_Link_1_Name__c;
        SecondaryLink2Action  = item.Secondary_Link_2_Action__c;
        SecondaryLink2Name        = item.Secondary_Link_2_Name__c;
        SecondaryLink2Location = item.Secondary_Link_1_Location_Validated__c;
        SortOrder               = item.Sort_Order__c;
        SubHeading                = item.SubHeading__c;
        ViewCount             = item.View_Count__c;
        DPAScore = 0;
        ABCNetworkOnly = item.ABC_Network_Only__c;
                             
        PollId = item.Poll_Id__c;
        Intranet_Defaults__c intranetDefault = IntranetHomeUtility.LookupIntranetDefault('Poll Item');
        if(intranetDefault != null) {
            PollSuggestAddress = intranetDefault.EmailToAddress__c;
            PollSuggestSubject = intranetDefault.EmailSubject__c;
        }
        
        if(item.Permalink__c!=null) this.Permalink = item.Permalink_Validated__c;

        CustomizeContent(container, new Intranet_Schedule__c(), item, userSession, maplikedItems);
        if(this.SortOrder == null) this.SortOrder = 0;
        if(this.DPAScore == null) this.DPAScore = 0;                       
    }

    public void CustomizeContent(IntranetContainer container, 
                                Intranet_Schedule__c sched, 
                                Intranet_Item__c item,
                                IntranetType.UserSession userSession, 
                                Map<string, Intranet_Utilization__c> maplikedItems) 
    {
        
        //Check if the Item has already been liked by the logged in User
        this.ChatterIsLiked = maplikedItems.containsKey(IntranetUtilizationHelper.CLICK_TYPE_LIKE + item.Id);
        this.isRated = maplikedItems.containsKey(IntranetUtilizationHelper.CLICK_TYPE_RATE + item.Id);
        this.ChatterComments = Item.Chatter_Comments_Rollup__c;
        updateDPAScore(userSession, sched, item);    
        
        if(sched != null)
            PublishDate = sched.Start_Date_Time__c;
        
        if(item.Item_Type__c == 'Firm App Link' || item.Item_Type__c == 'Quick Link' || 
           item.Item_Type__c == 'Page Link' || item.Item_Type__c == 'Food Link' ) {
               
            if(item.Item_Type__c == 'Firm App Link' || item.Item_Type__c == 'Food Link') {
                this.IconStyle = item.Icon_Style__c;
                if(this.IconStyle == null) this.IconStyle = IntranetHomeUtility.IntranetConstants.Icon_Style__c;
            }
            this.SortOrder = item.Sort_Order__c;
            this.TrackFrequentApp = item.Track_Frequent_App__c;
            if(item.Item_Type__c != 'Food Link') this.TrackUtilization = item.Track_Utilization__c;
            this.IntranetContainerId = container.ContainerId;
            this.IntranetItemId = item.id;
            if(item.Item_Type__c == 'Page Link') this.ItemSubtitle = item.Item_Subtitle__c;
            this.ItemTitle = item.Item_Title__c;
            this.ItemType = item.Item_Type__c;
            this.LinkAction = item.Link_Behaviour__c;
            this.LinkType = item.Link_Type__c;
            this.Name = item.Name;
        } else if(item.Item_Type__c == 'Member Event') {
            this.EventEndDateTime = item.Event_End_Date_Time__c;
            this.EventStartDateTime = item.Event_Start_Date_Time__c;
            this.IntranetContainerId = container.ContainerId;
            this.IntranetItemId = item.id;
            this.ItemSubtitle = item.Item_Subtitle__c;
            this.ItemTitle = item.Item_Title__c;
            this.ItemType = item.Item_Type__c;
            this.LinkAction = item.Link_Behaviour__c;
            this.LinkType = item.Link_Type__c;
            this.LocationCity = item.Location_City__c;
            this.Name = item.Name;
            if(this.EventStartDateTime != null)
                this.SortOrder = this.EventStartDateTime.getTime();
            
            //Set Month Name
            if(item.Event_Start_Date_Time__c != null) {
                
                //if multi-day event and today is within the time period, return today's month/day (CR-7578)
                if (this.EventStartDateTime.isSameDay(this.EventEndDateTime) == false
                    && DateTime.now().date() >= this.EventStartDateTime.date() 
                    && DateTime.now().date() <= this.EventEndDateTime.date() ) {
                        
                        Month_Name = mapMonthName.get(DateTime.now().month());
                        EventStartDateTime = DateTime.now();
                    }
                else {
                    Month_Name = mapMonthName.get(item.Event_Start_Date_Time__c.month());
                }
            }
            
        } else if(item.Item_Type__c == 'Office Event') {
            
            this.LinkAction = item.Link_Behaviour__c;
            this.EventEndDateTime = item.Event_End_Date_Time__c;
            this.EventStartDateTime = item.Event_Start_Date_Time__c;
            this.IntranetContainerId = container.ContainerId;
            this.IntranetItemId = item.id;
            this.ItemTitle = item.Item_Title__c;
            this.ItemType = item.Item_Type__c;
            this.Name = item.Name;
            if(sched != null)
                this.Office = sched.Office__c;
            this.Permalink = item.Permalink_Validated__c;
            if(this.EventStartDateTime != null)
                this.SortOrder = this.EventStartDateTime.getTime();
            
        } else if(item.Item_Type__c == 'Training Event') {
            this.LinkAction = item.Link_Behaviour__c;
            if(this.EventStartDateTime != null)
                this.SortOrder = this.EventStartDateTime.getTime();
            
        } else if(container.ContainerType == 'Poll') {
            this.LinkAction = item.Link_Behaviour__c;
            this.ChatterIsLiked = maplikedItems.containsKey(IntranetUtilizationHelper.CLICK_TYPE_LIKE + item.Id);
            this.isRated = maplikedItems.containsKey(IntranetUtilizationHelper.CLICK_TYPE_RATE + item.Id);
            this.PollId = item.Poll_Id__c;
            this.MyPollChoiceId = null;
            this.PollChoices = new List<ConnectApi.FeedPollChoice>();
            if(this.PollId != null) {
                ConnectApi.FeedItem feedItem = ConnectApi.ChatterFeeds.getFeedItem('internal', pollId);
                if(feedItem.type == ConnectApi.FeedItemType.PollPost) {
                    this.ItemTitle = feedItem.body.text;
                    LoadPollChoice((ConnectApi.FeedPoll) feedItem.attachment);
                }
            }
            
        } else if(container.ContainerType == 'SubContainer' && 
                  (container.DisplayName=='Advisory.com' || container.DisplayName=='EAB.com')) {
        
            this.LinkAction = item.Link_Behaviour__c;
            this.ChatterIsLiked = maplikedItems.containsKey(IntranetUtilizationHelper.CLICK_TYPE_LIKE + item.Id);
            this.isRated = maplikedItems.containsKey(IntranetUtilizationHelper.CLICK_TYPE_RATE + item.Id);
            Trend_Type = item.Trend_Type__c;
            Link_Location = item.Link_URL__c;
            Article_Title = item.Item_Title__c;
            View_Count = item.View_Count__c;
            Trending_View_Count = item.Trending_View_Count__c;
            if(item.Last_Content_Update__c != null && item.Sort_Order__c != null)
            	this.SortOrder = -item.Last_Content_Update__c.addMinutes(-Integer.valueOf(item.Sort_Order__c)).getTime();
        } else if(container.ContainerType == 'Video') {
            this.LinkAction = item.Link_Behaviour__c;
            this.ChatterIsLiked = maplikedItems.containsKey(IntranetUtilizationHelper.CLICK_TYPE_LIKE + item.Id);
            this.isRated = maplikedItems.containsKey(IntranetUtilizationHelper.CLICK_TYPE_RATE + item.Id);
            this.SortOrder = -this.DPAScore;
        } else if (item.Item_Type__c == 'Component Link'){
            
            this.LinkAction = item.Link_Behaviour__c;
            this.IconStyle = item.Icon_Style__c;
            if(this.IconStyle == null) this.IconStyle = IntranetHomeUtility.IntranetConstants.Icon_Style__c;

        } else if (item.Item_Type__c == 'Member Impact'){
            
            if(this.DefaultContentFlag != true){
                updateDPAScore(userSession, sched, item);
                this.SortOrder = -this.DPAScore;
            }else{
                this.SortOrder = 1;
            }
            this.LinkAction = item.Link_Behaviour__c;
            this.ChatterIsLiked = maplikedItems.containsKey(IntranetUtilizationHelper.CLICK_TYPE_LIKE + item.Id);
            this.isRated = maplikedItems.containsKey(IntranetUtilizationHelper.CLICK_TYPE_RATE + item.Id);
            
        } else if (item.Item_Type__c == 'System Status'){
            if(this.DefaultContentFlag != true){
                updateDPAScore(userSession, sched, item);
                this.SortOrder = -this.DPAScore;
            }else{
                this.SortOrder = 1;
            }
            
        } else if(item.Item_Type__c == 'News Item' && (container.ContainerType == 'News Carousel' || 
                (container.ContainerType == 'SubContainer' && container.DisplayName=='News'))) {
                    
            this.LinkAction = item.Link_Behaviour__c;
            this.AlternateContent = item.Alternate_Content__c;
            this.AlternateContentURL = item.Content_URL__c;
            this.CategoryReferenceName = item.Category_Reference_Name__c;
            this.ChatterComments = Item.Chatter_Comments_Rollup__c;
            this.ChatterIsLiked = maplikedItems.containsKey(IntranetUtilizationHelper.CLICK_TYPE_LIKE + item.Id);
            this.isRated = maplikedItems.containsKey(IntranetUtilizationHelper.CLICK_TYPE_RATE + item.Id);
            this.ChatterLikes = item.Chatter_Likes__c;
            this.ChatterShares = item.Chatter_Shares__c;
            this.Citation = item.Citation__c;
            this.ContentMainImageId = item.Content_Main_Image_Id__c;
            this.ContentThumbnailImageId = item.Content_Thumbnail_Image_Id__c;
            this.IntranetContainerId = container.ContainerId;
            this.IntranetItemId = item.id;
            this.ItemFullText = item.Item_Full_Text__c;
            this.ItemSubtitle = item.Item_Subtitle__c;
            this.ItemTitle = item.Item_Title__c;
            this.ItemType = item.Item_Type__c;
            this.Name = item.Name;
            if(sched != null)
                this.Office = sched.Office__c;
            this.RoomName = item.Room_Name__c;
            this.RoomNumber = item.Room_Number__c;
            this.Floor = item.Floor__c;
            this.Permalink = item.Permalink_Validated__c;
            this.ShowExpandLink = item.Show_Expand_Link__c;
            this.ShowMainImageInContentViewer = item.Show_Main_Image_In_Content_Viewer__c;
            this.TrackUtilization = item.Track_Utilization__c;
            updateDPAScore(userSession, sched, item);
            this.SortOrder = -this.DPAScore;

            //Modified by Mahendra Swarnakar - 05/05/2020 - CR-20200218-13769 - article_author__c, Background_Color__c deleted
            if(container.ContainerType == 'News Carousel' ) {
                //this.BackgroundColor = item.Background_Color__c;
                this.TextBoxBackColor = item.Text_Box_Back_Color__c;
                this.TextBoxTextColor = item.Text_Box_Text_Color__c;
                this.TextBoxVisible = item.Text_Box_Visible__c;
            } else {
                
            }

        }else if(container.ContainerType == 'Flexible') {

            this.LinkAction = item.Link_Behaviour__c;
            this.ContainerClass = item.Container_Class__c;
            //Set the DPA score type in the fields that are used by the calculation routine
            this.DPAScoreType = item.DPA_Score_Type__c;
            if(sched != null && sched.Intranet_Container__r != null)
                sched.Intranet_Container__r.DPA_Score_Type__c = item.DPA_Score_Type__c;
            updateDPAScore(userSession, sched, item);
            this.IntranetContainerId = container.ContainerId;
            this.IntranetItemId = item.id;
            this.ItemType = item.Item_Type__c;
            this.Name = item.Name;
            this.TrackUtilization = item.Track_Utilization__c;
            this.SortOrder = -this.DPAScore;
            
            if(this.ItemType == 'Ad Item') {
                this.ContentMainImageURL = IntranetHomeUtility.LookupIntranetSetting('BaseImageUrl') + item.Content_Main_Image__c;
                this.ImageSetReferenceName = item.Image_Set_Reference_Name__c;
                this.LinkAction = item.Link_Behaviour__c;
                this.LinkType = item.Link_Type__c;
                this.UniqueId = item.Unique_Id__c;
                this.ContainerClass = 'AdItem';

            } else if(this.ItemType == 'Job Item' || this.ItemType == 'Talent Item') {

                this.ChatterComments = item.Chatter_Comments_Rollup__c;
                this.ChatterIsLiked = maplikedItems.containsKey(IntranetUtilizationHelper.CLICK_TYPE_LIKE + item.Id);
                this.isRated = maplikedItems.containsKey(IntranetUtilizationHelper.CLICK_TYPE_RATE + item.Id);
                this.ChatterLikes = item.Chatter_Likes__c;
                this.ChatterShares = item.Chatter_Shares__c;
                //Color_Set_Reference_Name__c deleted : Modified By Mahendra Swarnakar - 05/05/2020 -CR-20200218-13769
                //this.ColorSetReferenceName = item.Color_Set_Reference_Name__c;
                this.DisplayName = item.Display_Name__c;
                this.ItemFullText = item.Item_Full_Text__c;
                this.ItemTitle = item.Item_Title__c;
                this.Permalink = item.Permalink__c;
                this.ShowExpandLink = item.Show_Expand_Link__c;
                this.TextBoxBackColor = item.Text_Box_Back_Color__c;
                this.TextBoxTextColor = item.Text_Box_Text_Color__c;

                if(this.ItemType == 'Job Item') {
                    this.ContainerClass = 'JobItem';
                } else {
                    this.ContainerClass = 'TalentItem';
                    this.Citation = item.Citation__c;
                    this.ContentMainImageURL = IntranetHomeUtility.LookupIntranetSetting('BaseImageUrl') + item.Content_Main_Image__c;
                    this.ImageSetReferenceName = item.Image_Set_Reference_Name__c;
                    this.ImageSetMainImageId = IntranetHomeUtility.GetImagesetImage(userSession.Manager);
                }
            }
            
            container.DisplayName = this.DisplayName;
            container.DPAScoreType = this.DPAScoreType;
            container.ShowExpandLink = this.ShowExpandLink;
            container.ContainerClass = this.ContainerClass;

        } else if(container.ContainerType == 'SubContainer') {
            Trend_Type = item.Trend_Type__c;
            Link_Location = item.Link_URL__c;
            Article_Title = item.Item_Title__c;
            View_Count = item.View_Count__c;
            Trending_View_Count = item.Trending_View_Count__c;
			if(item.Last_Content_Update__c != null && item.Sort_Order__c != null)
                this.SortOrder = -item.Last_Content_Update__c.addMinutes(-Integer.valueOf(item.Sort_Order__c)).getTime();
        }
    }
    
    public void LoadPollChoice(ConnectApi.FeedPoll poll) {
        if(poll != null && poll.choices != null) {
            this.MyPollChoiceId = poll.myChoiceId;
            this.PollChoices = poll.choices;
        }
    }

    private void updateDPAScore (IntranetType.UserSession userSession, Intranet_Schedule__c sched, Intranet_Item__c item) {
        try {
            this.DPAScore = IntranetHomeUtility.calculateDPAScore(userSession, sched, item);
            if(this.DPAScore == null) this.DPAScore = 0;
        } catch (Exception ex) {
            this.DPAScore = 0;
        }
    }
    
    public Integer compareTo(Object compareTo) {
        if(compareTo == null) return 1;
        IntranetContent compareToIContent = (IntranetContent)compareTo;
        if(compareToIContent == null) return 1;
        
        if ( (SortOrder == null? 0 : SortOrder) == (compareToIContent.SortOrder == null? 0 : compareToIContent.SortOrder) ) return 0;
        if ( (SortOrder == null? 0 : SortOrder) > (compareToIContent.SortOrder == null? 0 : compareToIContent.SortOrder) ) return 1;
        return -1;
    }
    
    public string ToString(string indent) {
        return indent + 'Content: (Id=' + this.IntranetItemId + ' name=' + this.Name + ', type=' + this.ItemType + ', permalink=' + this.Permalink +
            ', sortOrder=' + this.sortOrder + ')<br>';
    }
}