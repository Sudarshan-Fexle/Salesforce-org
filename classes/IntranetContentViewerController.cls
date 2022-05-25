//V_1.1 - Modified By - Abhinav Sharma - CR-20150219-8692 - 04/29/2015
//V_1.2 - Modified By - Abhinav Sharma - CR-20141211-8300 - 04/30/2015
//V_1.3 - Modified By - Rajeev Jain - CR-20150618-9016 - BoardRoom Mobile Development -  06/29/2015
//V_1.4 - Modified By - Rajeev Jain - CR-20150618-9016 - BoardRoom Mobile Development -  08/06/2015 - Sorted View State error for Job of the day.
public class IntranetContentViewerController {
    
    public static final Integer DEFAULT_PAGE_SIZE = 5;
    public static final String MODE_CALENDAR = 'calendar';
	
    //V_1.4 - Modified By - Rajeev Jain - CR-20150618-9016 - BoardRoom Mobile Development -  08/06/2015
    //Changed to Static Varible to resolve View State error for it.
    public static IntranetContainer Container {get; private set;}
    public List<IntranetContent> TopRelatedContent {get; private set;} 
    
    //V_1.4 - Modified By - Rajeev Jain - CR-20150618-9016 - BoardRoom Mobile Development -  08/06/2015
    private static List<IntranetContent> mAllOtherContent;
    public List<IntranetContent> OtherContent { get; private set; }
    public IntranetContent MainIntranetContent { get; private set;}

    public String ContainerId {get; private set;}
    public String ScheduleId {get; private set;}
    public String View {get; private set;}
    public String Mode {get; private set;}
    public String OfficeId {get; private set;}

    public String SearchContentId {get; private set;}
    public String SearchContentType {get; private set;}
    public String SearchStartDate {get; private set;}
    
    //TODO: BSS
    public static String testViewState = '';

    public String getOfficeName() {
        if (OfficeId != null) {
            List<SelectOption> OfficeSelectList = IntranetHomeUtility.OfficeSelectList;
            for (SelectOption option : OfficeSelectList) {
                if (Id.valueOf(option.getValue()) == Id.valueOf(OfficeId)) {
                    return option.getLabel();
                }
            }
        }
        return null;
    }

    public Integer Offset {get; set;}
    public Boolean HasMore {get; private set;}
    public Date StartDate {get; set;}
    public Date EndDate {get; private set;}

    public IntranetContentViewerController() {
        
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=EDGE');
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        
        SearchContentId = params.get('SearchContentId');
        if (SearchContentId != null) SearchContentId = SearchContentId.substring(0, 15);
        SearchContentType = params.get('SearchContentType');
        SearchStartDate = params.get('SearchStartDate');

        ScheduleId = params.get('ScheduleId');
        if (ScheduleId != null) ScheduleId = ScheduleId.substring(0, 15);
        ContainerId = params.get('ContainerId');
        if (ContainerId != null) ContainerId = ContainerId.substring(0, 15);
        View = params.get('View');
        if (View != null) View = View.toLowerCase();
        Mode = params.get('Mode');
        if (Mode != null) Mode = Mode.toLowerCase();
        OfficeId = params.get('OfficeId');
        if (OfficeId != null) OfficeId = OfficeId.substring(0, 15);

        if (Offset == null || Offset < 0) Offset = 0;
        /*If(IntranetContentViewerController.testViewState != null && IntranetContentViewerController.testViewState == '') {
			IntranetContentViewerController.testViewState += View + '-----' + Mode;
        } else {
			IntranetContentViewerController.testViewState += View + '-----' + Mode;*/
            	LoadData();
        //throw new CustomException(IntranetContentViewerController.testViewState);
        //}
    }

    public void LoadDataCore() {
        if (Mode == MODE_CALENDAR)
            InitializeCalendarDateList();

        IntranetContent thisConent;

        if (SearchContentId != null && SearchContentType != null) {
            thisConent = LoadDataByContent(SearchContentId, SearchContentType, Mode == MODE_CALENDAR);
        } else if (ScheduleId != null) {
            thisConent = LoadDataBySchedule(ScheduleId, OfficeId, Mode == MODE_CALENDAR);
        } else if (ContainerId != null) {
            if (View == 'office event' || View == 'training event' || View == 'member event')
                thisConent = LoadDataByContainer(ContainerId, View, OfficeId, Mode == MODE_CALENDAR);
            else
                thisConent = LoadDataByContainer(ContainerId, null, OfficeId, Mode == MODE_CALENDAR);
        }
		
        //V_1.4 - Modified By - Rajeev Jain - CR-20150618-9016 - BoardRoom Mobile Development -  08/06/2015
        if (Mode != MODE_CALENDAR && IntranetContentViewerController.mAllOtherContent == null) {
            IntranetContentViewerController.mAllOtherContent = new List<IntranetContent>();
            TopRelatedContent = new List<IntranetContent>();
            for (IntranetContent ic : IntranetContentViewerController.Container.RelatedContent) {
                if (thisConent != null && ic.IntranetItemId == thisConent.IntranetItemId) continue;
                if (thisConent != null && ic.MainCategory != null && TopRelatedContent.size() <= 2 && ic.MainCategory == thisConent.MainCategory ) {
                    TopRelatedContent.add(ic);
                } else {
                    IntranetContentViewerController.mAllOtherContent.add(ic);
                }
            }

            GetOtherContent();
        }
	}

    public IntranetContent LoadDataByContent(String contentId, String contentType, boolean forCalendar) {
        
        List<Intranet_Schedule__c> schedules = [SELECT Id FROM Intranet_Schedule__c
                                                WHERE Intranet_Item__c = :contentId];

        if (schedules.size() == 0) {
        
            // Get similar items
            Map<Id, Intranet_Item__c> mapItems = new Map<Id, Intranet_Item__c>([SELECT Id FROM Intranet_Item__c
                    WHERE Item_Type__c = :contentType]);

            // Get first schedule
            schedules = [SELECT Id FROM Intranet_Schedule__c
                         WHERE Intranet_Item__c IN :mapItems.keySet()
                         ORDER BY Is_Visible__c desc LIMIT 1];
        }

        // When coming from all the other places, we do not really need filter by office logic.
        OfficeId = null;

        if(schedules.size() > 0)
            return LoadDataBySchedule(schedules[0].Id, null, forCalendar);
        
        ContainerId = Label.IntranetMainPage;
        if (View == 'office event' || View == 'training event' || View == 'member event')
                return LoadDataByContainer(ContainerId, View, null, Mode == MODE_CALENDAR);
        return LoadDataByContainer(ContainerId, null, null, Mode == MODE_CALENDAR);
    }

    public IntranetContent LoadDataBySchedule(String scheduleId, String officeId, boolean forCalendar) {
        
        
        IntranetType.UserSession userSession = IntranetHomeUtility.getUserSession;
        Map<string, Intranet_Utilization__c> maplikedItems = IntranetUtilizationHelper.getLikedItems();
        
        //JRB Map<Id, Intranet_Utilization__c> mapRatedItems = IntranetUtilizationHelper.getRatedItems();
        Map<String,Intranet_Utilization__c> mapRatedItems = new Map<String,Intranet_Utilization__c>();
        IntranetContainer officeNewsContainer;
        IntranetContainer newsCarouselContainer;

        Intranet_Schedule__c schedule = [SELECT Intranet_Container__c, Intranet_Item__c
                                         FROM Intranet_Schedule__c
                                         WHERE Id = :scheduleId];
        
        String containerId = schedule.Intranet_Container__c;
        String contentId = schedule.Intranet_Item__c;
        
        IntranetContainer con = BoardroomHomeContainerController.GetContainer(containerId);
        
        Map<Id, IntranetContainer> mapContainers = BoardroomHomeContainerController.GetContainersByTopParentContainerId((String) con.TopContainerId);
        
        for (IntranetContainer ic : mapContainers.values()) {
            if (ic.ContainerType == 'SubContainer' && ic.DisplayName == 'News')
                officeNewsContainer = ic;
            if (ic.ContainerType == 'News Carousel')
                newsCarouselContainer = ic;

            IntranetContainer pc;
            if (ic.ParentContainerId == null) {
                pc = mapContainers.get(ic.ParentContainerId);
                if (pc != null)
                    pc.SubContainers.Add(ic);
            }
        }
        
        IntranetContentViewerController.Container = mapContainers.get(containerId);
        if(IntranetContentViewerController.Container == null) IntranetContentViewerController.Container = con;

        Map<Id, Intranet_Schedule__c> associatedSchedules = (OfficeId == null) ?
                BoardroomHomeContainerController.GetSchedulesForIntranetContentViewer(mapContainers.keySet(), scheduleId) :
                BoardroomHomeContainerController.GetOfficeSchedules(mapContainers.keySet(), OfficeId, scheduleId);

        Set<Id> ItemIds = new Set<Id>();
        for (Intranet_Schedule__c sched : associatedSchedules.values()) {
            ItemIds.add(sched.Intranet_Item__c);
        }
        if (SearchContentId != null && !ItemIds.contains(SearchContentId)) ItemIds.add(SearchContentId);
        
        Map<Id, Intranet_Item__c> AssociatedItems = BoardroomHomeContainerController.GetContentItems(ItemIds, null,
                forCalendar ? StartDate : null, forCalendar ? EndDate : null);

        // Sort items, so the scheduled item is the first one.
        decimal MinSortOrder = -100;
        IntranetContent thisConent;
        for (Intranet_Schedule__c sch : associatedSchedules.values()) {
            if (!AssociatedItems.containsKey(sch.Intranet_Item__c)) continue;
            if (!mapContainers.containsKey(sch.Intranet_Container__c)) continue;

            IntranetContainer parentContainer = mapContainers.get(sch.Intranet_Container__c);

            // We end up get all the news items regardless of office now, we have to re-filter them here.
            if (officeId != null && newsCarouselContainer != null && parentContainer.ContainerId == newsCarouselContainer.ContainerId &&
                    id.valueOf(sch.Office__c) != id.valueOf(officeId)) {
                continue;
            }

            //JRB IntranetContent ic = new IntranetContent(parentContainer, sch, AssociatedItems.get(sch.Intranet_Item__c),
            //JRB        userSession, maplikedItems, mapRatedItems);
            IntranetContent ic = new IntranetContent(parentContainer, sch, AssociatedItems.get(sch.Intranet_Item__c),
                    userSession, maplikedItems);

            if (ic.SortOrder < MinSortOrder) MinSortOrder = ic.SortOrder;
            if (ic.IntranetItemId == contentId) thisConent = ic;
            parentContainer.RelatedContent.add(ic);
        }

        // Add the content if it has not been added yet
        if(SearchContentId != null && IntranetContentViewerController.Container != null) {
            Boolean hasAddedAlready = false;
            for(IntranetContent ic : IntranetContentViewerController.Container.RelatedContent) {
                if(ic.IntranetItemId == SearchContentId) {
                    hasAddedAlready = true;
                    break;
                }
            }

            if(!hasAddedAlready) {
                //JRB thisConent = new IntranetContent(this.Container, AssociatedItems.get(SearchContentId),
                //JRB     userSession, maplikedItems, mapRatedItems);                
                thisConent = new IntranetContent(IntranetContentViewerController.Container, AssociatedItems.get(SearchContentId),
                     userSession, maplikedItems);                
                IntranetContentViewerController.Container.RelatedContent.add(thisConent);
            }
        }

        if (thisConent != null)
            thisConent.SortOrder = MinSortOrder - 100;

        // Attach News Carousel items to Office News Container
        if (officeNewsContainer != null && officeId != null && newsCarouselContainer != null) {
            officeNewsContainer.RelatedContent.clear();
            officeNewsContainer.RelatedContent.addAll(newsCarouselContainer.RelatedContent);
        }

        for (IntranetContainer ic : mapContainers.values()) {
            ic.RelatedContent.sort();
        }

        return thisConent;
    }

    public IntranetContent LoadDataByContainer(String mainContainerId, string contentType, String officeId, boolean forCalendar) {
        IntranetType.UserSession userSession = IntranetHomeUtility.getUserSession;
        Map<string, Intranet_Utilization__c> maplikedItems = IntranetUtilizationHelper.getLikedItems();
        //JRB Map<Id, Intranet_Utilization__c> mapRatedItems = IntranetUtilizationHelper.getRatedItems();
        Map<Id,Intranet_Utilization__c> mapRatedItems = new Map<Id,Intranet_Utilization__c>();
        IntranetContainer officeNewsContainer;
        IntranetContainer newsCarouselContainer;

        IntranetContainer con = BoardroomHomeContainerController.GetContainer(mainContainerId);
        Map<Id, IntranetContainer> mapContainers = BoardroomHomeContainerController.GetContainersByTopParentContainerId((String) con.TopContainerId);
        for (IntranetContainer ic : mapContainers.values()) {
            if (ic.ContainerType == 'SubContainer' && ic.DisplayName.contains('News'))
                officeNewsContainer = ic;
            if (ic.ContainerType == 'News Carousel')
                newsCarouselContainer = ic;

            IntranetContainer pc;
            if (ic.ParentContainerId == null) {
                pc = mapContainers.get(ic.ParentContainerId);
                if (pc != null)
                    pc.SubContainers.Add(ic);
            }
        }
        
        IntranetContentViewerController.Container = mapContainers.get(containerId);

        Map<Id, Intranet_Schedule__c> associatedSchedules = (OfficeId == null) ?
                BoardroomHomeContainerController.GetSchedulesForIntranetContentViewer(mapContainers.keySet(), null) :
                BoardroomHomeContainerController.GetOfficeSchedules(mapContainers.keySet(), OfficeId, null);

        Set <Id> ItemIds = new Set<Id>();
        for (Intranet_Schedule__c sched : associatedSchedules.values()) {
            ItemIds.add(sched.Intranet_Item__c);
        }
        if (SearchContentId != null && !ItemIds.contains(SearchContentId)) ItemIds.add(SearchContentId);

        Map<Id, Intranet_Item__c> AssociatedItems = BoardroomHomeContainerController.GetContentItems(ItemIds, contentType,
                forCalendar ? StartDate : null, forCalendar ? EndDate : null);
        for (Intranet_Schedule__c sch : associatedSchedules.values()) {
            if (!AssociatedItems.containsKey(sch.Intranet_Item__c)) continue;
            if (!mapContainers.containsKey(sch.Intranet_Container__c)) continue;

            IntranetContainer parentContainer = mapContainers.get(sch.Intranet_Container__c);

            // We end up get all the news items regardless of office now, we have to re-filter them here.
            if (officeId != null && newsCarouselContainer != null && parentContainer.ContainerId == newsCarouselContainer.ContainerId &&
                    id.valueOf(sch.Office__c) != id.valueOf(officeId)) {
                continue;
            }

            //JRB IntranetContent ic = new IntranetContent(parentContainer, sch, AssociatedItems.get(sch.Intranet_Item__c),
            //JRB        userSession, maplikedItems, mapRatedItems);
            IntranetContent ic = new IntranetContent(parentContainer, sch, AssociatedItems.get(sch.Intranet_Item__c),
                    userSession, maplikedItems);
            parentContainer.RelatedContent.add(ic);
        }

        // Attach News Carousel items to Office News Container
        if (officeNewsContainer != null && officeId != null && newsCarouselContainer != null) {
            officeNewsContainer.RelatedContent.clear();
            officeNewsContainer.RelatedContent.addAll(newsCarouselContainer.RelatedContent);
        }

        // Add the content if it has not been added yet
        if(SearchContentId != null && IntranetContentViewerController.Container != null) {
            Boolean hasAddedAlready = false;
            for(IntranetContent ic : IntranetContentViewerController.Container.RelatedContent) {
                if(ic.IntranetItemId == SearchContentId) {
                    hasAddedAlready = true;
                    break;
                }
            }

            if(!hasAddedAlready) {
                //JRB thisConent = new IntranetContent(this.Container, AssociatedItems.get(SearchContentId),
                //JRB     userSession, maplikedItems, mapRatedItems);                
                IntranetContent thisConent = new IntranetContent(IntranetContentViewerController.Container, AssociatedItems.get(SearchContentId),
                     userSession, maplikedItems);                
                IntranetContentViewerController.Container.RelatedContent.add(thisConent);
            }
        }

        for (IntranetContainer ic : mapContainers.values()) {
            ic.RelatedContent.sort();
        }
        return null;
    }
	
    //V_1.4 - Modified By - Rajeev Jain - CR-20150618-9016 - BoardRoom Mobile Development -  08/06/2015
    //Earlier it was increasing OtherContent list size
    public void GetOtherContent() {
        OtherContent = new List<IntranetContent>();
        HasMore = false;
        if (mAllOtherContent.size() > 0) {
            Integer stopSize = DEFAULT_PAGE_SIZE + Offset;
            for (Integer i = Offset; i < stopSize; i++) {
                    
               if(i < mAllOtherContent.size()){
                	OtherContent.add(mAllOtherContent.get(i));
                	Offset++;    
                }else{
                    break;
                }      
                
            }
            HasMore = Offset < mAllOtherContent.size();
        }
    }

    // ==================================================================================
    // Support Calendar View
    // Merge code from Rajeev's IntranetContentViewerCalendarController
    // ==================================================================================

    private List<Date> WeekDates;

    //Wrapper List to Display formatted Data on Page
    private List<CalendarWrapper> wrapperList;

    public List<Date> getWeekDates() {
        return WeekDates;
    }
    public String getTodayDate() {
        return DateTime.now().format('yyMMdd');
    }

    //Get Current Week Month
    public String getMonth() {
        if (WeekDates.size() > 0)
            return Datetime.newInstance(2000, WeekDates[0].month(), 1).format('MMMM');
        return '[unknown]';
    }

    private Boolean noWeeklyData;
    public Boolean getNoWeeklyData() {
        return noWeeklyData;
    }
	
    //V_1.3 - Modified By - Rajeev Jain - CR-20150618-9016 - BoardRoom Mobile Development -  06/29/2015
    //Get month for current selected date
    public List<CalendarWrapper> getWrapperList() {

        if (wrapperList == null) {

            //List to Hold formated Calendar Data
            wrapperList = new List<CalendarWrapper>();

            noWeeklyData = true;

            //Loop over WeekDate
            for (Date currDate : WeekDates) {

                //New Wrapper Instnace
                CalendarWrapper calWrapper = new CalendarWrapper();

                //Format Date to Date Time
                Datetime dt = DateTime.newInstance(currDate.year(), currDate.month(), currDate.day());

                //New Wrapper Instance and Add to Wrapper List
                calWrapper.fullDayString = dt.format('yyMMdd');
                calWrapper.weekDayString = dt.format('EEEE');
                calWrapper.weekDayNumber = dt.day() + '';
				calWrapper.currentMonth = dt.format('MMMM');
                
                //Loop over Related Content
                for (IntranetContent contentItem : Container.RelatedContent) {
                    //Check for Date Comparision
                    if ((contentItem.EventStartDateTime == null || contentItem.EventStartDateTime.Date() <= currDate) &&
                            (contentItem.EventEndDateTime == null || contentItem.EventEndDateTime.Date() >= currDate) ) {
                        calWrapper.intranetContentList.add(contentItem);
                        noWeeklyData = false;
                    }
                }

                //Add Instance to Wrapper List
                wrapperList.add(calWrapper);
            }
        }

        //Return List
        return wrapperList;
    }

    public void InitializeCalendarDateList() {
        
        //Added By - Abhinav Sharma - CR-20141211-8300 - 04/30/2015
        //Start From Here
        //Checking & validating expected URL parameters
        if(SearchStartDate == null && String.isNotBlank(SearchContentId) 
           && String.isNotBlank(SearchContentType) && SearchContentType.equalsIgnoreCase('office event')) {
              
           //List of intranet Items    
           List<Intranet_Item__c> searchedIntranetItemsList = [SELECT ID, Event_Start_Date_Time__c FROM Intranet_Item__c
                                                                  WHERE ID =: SearchContentId];
              
           //Checking list for size and null value
           if(searchedIntranetItemsList != null && searchedIntranetItemsList.size() > 0) {
                  if(searchedIntranetItemsList[0].Event_Start_Date_Time__c != null) {
                   Date eventStartDateVar = Date.valueOf(searchedIntranetItemsList[0].Event_Start_Date_Time__c);
                   SearchStartDate = eventStartDateVar.month() + '/' + eventStartDateVar.day() + '/' + eventStartDateVar.year();
               }
           }
        }
        //Upto here

        if(SearchStartDate != null){
            try {
                this.StartDate = Date.parse(SearchStartDate).toStartOfWeek().addDays(1);
            } catch(Exception ex) {
            }
        }

        if (this.StartDate == null) StartDate = Date.today().toStartOfWeek().addDays(1);
        this.EndDate = StartDate.addDays(5);
		
        WeekDates = new List<Date>();
        for (Integer i = 0; i <= 4; i++) {
            WeekDates.add(StartDate.addDays(i));
        }
       
	}
	
    public PageReference LoadData() {
        
        // If not for calendar, we will just refresh Other Content
        if (Container != null && Mode != MODE_CALENDAR) {
            GetOtherContent();
        } else {
            
            //V_1.3 - Modified By - Rajeev Jain - CR-20150618-9016 - BoardRoom Mobile Development -  07/10/2015
            //In the mobile look ahead link , looks for next business day data. If today is firday then next business day should be monday.
            //So we are handling this use case additionaly on load of the constructor
            Map<String,String> urlParams = ApexPages.currentPage().getParameters();
            String lookAheadMobile = urlParams.get('lookAheadMobile');
            
            if(String.isNotBlank(lookAheadMobile) && lookAheadMobile.equalsIgnoreCase('true')){
                
                if (this.StartDate == null) StartDate = Date.today().toStartOfWeek().addDays(1);
                
                Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
                String dayOfWeek=dt.format('EEEE');
                
                //Move it to next week if today is friday found in current week.
                if(dayOfWeek.equalsIgnoreCase('Friday')){
                    StartDate = StartDate.addDays(7);    
                }
            }
        	//V_1.3 - Modified By - Rajeev Jain - CR-20150618-9016 - BoardRoom Mobile Development -  07/10/2015
        	
            LoadDataCore();
            
        }

        return null;
    }

    public PageReference LoadNextWeekData() {
        
        StartDate = StartDate.addDays(7);
        //System.debug('Load Next Week Method Called ::: ');
        //System.assert(false, currentSelectedIndex);
        wrapperList = null;
        LoadDataCore();
        
        return null;
    }

    public PageReference LoadPreviousWeekData() {
        
        StartDate = StartDate.addDays(-7);
        //System.debug('Load Previous Week Method Called ::: ');
        wrapperList = null;
        LoadDataCore();
        return null;
    }

    public string getDataString() {
        return IntranetContentViewerController.Container.ToString('');
    }
    /** Wrapper Class To Hold Calendar Properties and formated Date to Display Calendar **/
    public class CalendarWrapper {

        //Properties
        public String fullDayString {get; set;}
        public String weekDayString {get; set;}
        public String weekDayNumber {get; set;}
        
        //V_1.3 - Modified By - Rajeev Jain - CR-20150618-9016 - BoardRoom Mobile Development -  06/29/2015
        //Added new property to get current month to display in the mobile
        public String currentMonth	{get; set;}
        
        public List<IntranetContent> intranetContentList {get; set;}

        //Constructor
        public CalendarWrapper() {

            //Initialize List
            intranetContentList = new List<IntranetContent>();
        }
    }
    
    //======================== CR-20150618-9016 - Added By Rajeev Jain ====================================================
    /**
     * Description	:	Additional code to maintain seprated list for daily view to display Calendar in mobile as daily view
	* */
    public Integer currentSelectedIndex{get;set;}
    
    public CalendarWrapper getDayCalendarData(){
        if(currentSelectedIndex == null){
        	
            //Set default index to zero
            currentSelectedIndex = 0;
            
            Map<String,String> urlParams = ApexPages.currentPage().getParameters();
            
            //Loop over Wrappr List and check if wrapper list day is today day 
            //then set index of list item to current selected index
            if(wrapperList != null && wrapperList.size() > 0){
                
                /** Give priority of Day on which calendar open in mobile as daily view
                // Priority is decided based on the Param Passed in the Url
                // Priority - 1 ==> If Item open from clicking on more information link in ABC today component on the page
                // Priority - 2 ==> If Look Ahead link is clicked in mobile, then open calendar on next day from current date 
                // Priority - 3 ==> If from any other way calendar is opened in mobile, it will display day from today.
                **/
                //============= Priority 1 ==============================================
                
                //Check if param containe linkClick = moreinfor and eventItemId and both are not blank
                if(String.isNotBlank(urlParams.get('linkClick')) && urlParams.get('linkClick').equalsIgnoreCase('MoreInfo')){
                    
                    for(Integer i=0; i<wrapperList.size(); i++){
                        
                        //Check if list item Id is same as eventItemId passed in Url Params
                        if(wrapperList[i].intranetContentList != null && wrapperList[i].intranetContentList.size() > 0){
                            
                            //Loop on each item on that day
                            for(IntranetContent ic : wrapperList[i].intranetContentList){
                    			
                                ///Get Event item id and check any of the current week calendar item contains with this id in the list
                    			//if yes then set that day as current day and set currentSelectedIndex to that item index in the list
                                if(ic.IntranetItemId == urlParams.get('eventItemId')){
                                	
                                    currentSelectedIndex = i;
                                    break;
                                }
                            }
                        }
                    }
                }else{
                    
                    String todayDay = Date.today().day() + '';
                    String nextDay = Date.today().addDays(1).day() + '';
                    String lookAheadMobile = urlParams.get('lookAheadMobile');
                   
                    for(Integer i=0; i<wrapperList.size(); i++){
                        
                        if(String.isNotBlank(lookAheadMobile) && lookAheadMobile.equalsIgnoreCase('true') && wrapperList[i].weekDayNumber == nextDay){
                            
                        	//========================== Priority 2 =================================
                            currentSelectedIndex = i;
                            break;
                        }else if(String.isNotBlank(lookAheadMobile) && lookAheadMobile.equalsIgnoreCase('false') && wrapperList[i].weekDayNumber == todayDay){
                            
                         	//========================== Priority 3 =================================   
                            currentSelectedIndex = i;
                            break;
                        }
                    }
                }
            }
        }
            
        if(wrapperList != null && wrapperList.size() > 0 && wrapperList.get(currentSelectedIndex) != null){
            return wrapperList.get(currentSelectedIndex);
        }
        return new CalendarWrapper();
    }
    
    /** Method to Navigate data to Next Day **/
    public void navigateToNextDay(){
        SearchStartDate = '';
        if(currentSelectedIndex < 4){
        	currentSelectedIndex = currentSelectedIndex+1;    
        }else{
        	currentSelectedIndex = 0;
            LoadNextWeekData();
        }
    }
    
    /** Method to Navigate data to Next Day **/
    public void navigateToPreviousDay(){
        SearchStartDate = '';
        if(currentSelectedIndex >= 1){
        	currentSelectedIndex = currentSelectedIndex-1;    
        }else{
        	currentSelectedIndex = 4;
            LoadPreviousWeekData();
        }
    }
    //======================== CR-20150618-9016 - Added By Rajeev Jain  Ends Here====================================================
}