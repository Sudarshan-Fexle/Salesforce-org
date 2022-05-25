/**
 * 	Purpose			:	Helper Controller class for IntranetContentViewerCalendarController
 * 
 * 	Created By		:	Rajeev Jain
 * 
 * 	Created Date	:	09/14/2014
 * 
 *	Revision Logs	:	V_1.0 - Created
 *
 **/
public with sharing class IntranetContentViewerCalendarController {
	
	//Properties
	//Intranet Container Instance
	public IntranetContainer mainContainer;
	public List<Date> WeekDates;
	public String month;
	
	//Map to Convert Month In Number
    private Map<Integer ,String> monthMap = new Map<Integer,String>{
    
        1 => 'January',
        2 => 'Febuary',
        3 => 'March',
        4 => 'April',
        5 => 'May',
        6 => 'June',
        7 => 'July',
        8 => 'August',
        9 => 'September',
        10 => 'October',
        11 => 'November',
        12 => 'December'   
    };
    
	//Wrapper List to Display formatted Data on Page
	public List<CalendarWrapper> wrapperList;
	
	public List<Date> getWeekDates(){
		return WeekDates;
	}
	
	//Get Date List
	public void setWeekDates(List<Date> dateList){
		
		this.WeekDates = dateList;
		if(WeekDates == null)
			WeekDates = new List<Date>();		
	}
	
	//Set Container
	public void setMainContainer(IntranetContainer container){
		
		this.mainContainer = container;
		if(mainContainer == null)
			mainContainer = new IntranetContainer();		
	}
	
	//Get Container
	public IntranetContainer getMainContainer(){
		
		return mainContainer;
	}
	
	//Get Current Week Month
	public String getMonth(){
		String currMonth = monthMap.get(WeekDates[0].month());	
		
		return currMonth;
	}
	//Set Date List
	public List<CalendarWrapper> getWrapperList(){
		
		if(wrapperList == null){
			
			//List to Hold formated Calendar Data
			wrapperList = new List<CalendarWrapper>();
					
			//Get List of Related Content and List of Date
			
			//Loop over WeekDate
			for(Date currDate:WeekDates){
				
				//New Wrapper Instnace
				CalendarWrapper calWrapper = new CalendarWrapper();
				
				//Format Date to Date Time
				
				Datetime dt = DateTime.newInstance(currDate.year(), currDate.month(), currDate.day());
				
				//New Wrapper Instance and Add to Wrapper List
				calWrapper.weekDayString = dt.format('EE');
				calWrapper.weekDayNumber = dt.day()+'';
				
				//Loop over Related Content
				for(IntranetContent contentItem:mainContainer.RelatedContent){
						
					//Check for Date Comparision
					if(contentItem.EventStartDateTime != null && currDate == contentItem.EventStartDateTime.Date()){
						
						calWrapper.intranetContentList.add(contentItem);
					}
				}
				
				//Add Instance to Wrapper List
				wrapperList.add(calWrapper);	
			}
		}
		
		//Return List
		return wrapperList;
	}
	
	/** Wrapper Class To Hold Calendar Properties and formated Date to Display Calendar **/
	public class CalendarWrapper{
		
		//Properties
		public String weekDayString{get;set;}
		public String weekDayNumber{get;set;}
		public List<IntranetContent> intranetContentList{get;set;}
		
		//Constructor
		public CalendarWrapper(){
			
			//Initialize List
			intranetContentList = new List<IntranetContent>();
		}
	}
}