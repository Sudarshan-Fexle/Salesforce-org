/**
 *  Purpose         :   Helper class for Intranet Utilization
 * 
 *  Created By      :   Bhavi Sharma
 * 
 *  Created Date    :   08/18/2014
 * 
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.1 - Modified By - Abhinav Sharma - CR-20150128-8603 -04/01/2015
 *                      V_1.2 - Modified By - Rajeev Jain - CR-20141003-7624 - 05/01/2015
 *                      V_1.3 - Modified By - Rajeev Jain - CR-20150618-9016 - 08/07/2015 -Board Room Mobile - Track device information, populate display name if already not there
 *                      V_1.4 - Modified By - Mahendra Swarnkar - CR-20161005-10203 - 07/07/2017 - Updated the existing method "createIntranetUtilizationRecord".
 *
 **/ 
public with sharing class IntranetUtilizationHelper {
        
    //Constants for Utitlization Records
    public final static String CLICK_TYPE_LIKE = 'Like';
    public final static String CLICK_TYPE_COMMENT = 'Comment';
    public final static String CLICK_TYPE_EXPAND = 'Expand';
    public final static String CLICK_TYPE_FEEDBACK = 'Feedback';
    public final static String CLICK_TYPE_LAUNCHAPP = 'Launch App';
    public final static String CLICK_TYPE_OFFICECHANGE = 'Office Change';
    public final static String CLICK_TYPE_OPENWEB = 'Open Web';
    public final static String CLICK_TYPE_OPENPAGE = 'Open Page';
    public final static String CLICK_TYPE_SELECT = 'Select';
    public final static String CLICK_TYPE_SHARE = 'Share';
    public final static String CLICK_TYPE_RATE = 'Rate';
    
    
    //V_1.4 - Modified By - Mahendra Swarnkar - CR-20161005-10203 - 07/07/2017 -- Starts from here
    public final static String SCHEDULER_STATIC_NAME = 'Sched_UtilizationInsert ';
    //V_1.4 - Modified By - Mahendra Swarnkar - CR-20161005-10203 - 07/07/2017 -- Ends here
    
    //Rajeev Jain - (01/05/2015) - Added new cosntanct for click type page section CR-20141003-7624
    public final static String CLICK_TYPE_PAGE_SECTION = 'Page Section';
    
    //Success Data
    public final static String ClICK_TYPE_REMOTESUCCESS = 'Success';
    public final static String CLICK_TYPE_REMOTEFAILUIRE = 'Failed';
    /**
     *  @description    :   This method is to create the Intranet Utilization record
     * 
     *  @args           :   UserSession instance
                            Click Type
                            Clicked Intranet Container Id
                            Clicked Intranet Item Id
                            Clicked Intranet Schedule Id
                            OPTIONAL Rating Value
     * 
     *  @return         :   void
     *
     **/
    @future
    public static void createIntranetUtilizationRecord(String serializedUserSession, String clickType, String displayName, Id intranetContainerId, Id intranetItemId, Id intranetScheduleId, Double ratingValue) {
        system.debug('JRBJRB - serializedUserSession:'+serializedUsersession);
        system.debug('JRBJRB - intranetItemId:'+intranetItemId);
        //Deserialized UserSession
        
        integer i = 0;
        
        IntranetType.UserSession UserSession = (IntranetType.UserSession)JSON.deserialize(serializedUserSession, IntranetType.UserSession.class);
        
        //Create a new intranet Utilization record
        Intranet_Utilization__c intranetUtilization = new Intranet_Utilization__c();
        intranetUtilization.Access_Location__c = UserSession.AccessLocation;
        intranetUtilization.Browser__c = UserSession.Browser;
        intranetUtilization.Click_Type__c = clickType;
        IntranetUtilization.Container_Display_Name__c = displayName;
        intranetUtilization.Department__c = UserSession.Department;
        intranetUtilization.Device__c = UserSession.Device;
        intranetUtilization.Division__c = UserSession.Division;
        intranetUtilization.Function__c = UserSession.Function;
        intranetUtilization.Intranet_Container__c = intranetContainerId;
        intranetUtilization.Intranet_Item__c = intranetItemId;
        intranetUtilization.Intranet_Schedule__c = intranetScheduleId;
        intranetUtilization.Job_Level__c = UserSession.JobLevel;
        if(UserSession.Manager != null)
            intranetUtilization.Manager__c = UserSession.Manager;
        
        //V_1.3 - Modified By - Rajeev Jain - CR-20150618-9016 - 08/07/2015
        //Check if display Name is not populated then Query based on container Id and populate it
        if(String.isBlank(displayName) && String.isNotBlank(intranetContainerId)){
            List<Intranet_Container__c> intCont = [select Display_Name__c from Intranet_Container__c where Id = :intranetContainerId];   
            if(intCont.size() > 0)
                IntranetUtilization.Container_Display_Name__c = intCont[0].Display_Name__c;  
        }
        
        //V_1.2 - Modified By - Rajeev Jain - CR-20150618-9016 - 07/08/2015 - BoardRoom Phase 2
        List<Intranet_Item__c> officeItem;
        
        if(String.isNotBlank(UserSession.AssignedOffice))
            officeItem = [select Id, Office_Short_Name__c from Intranet_Item__c where Id = :UserSession.AssignedOffice];
        
        intranetUtilization.Office__c = officeItem != null && officeItem.size() >0 ? officeItem[0].Office_Short_Name__c + ' Office' : UserSession.AssignedOffice; 
        
        //V_1.2 - Modified By - Rajeev Jain - CR-20150618-9016 - 07/08/2015 - BoardRoom Phase 2
        //Commneted out the code to save Office Name instead of the Hard Coded Office Id
        //intranetUtilization.Office__c = UserSession.AssignedOffice;
        
        intranetUtilization.Rating__c = ratingValue;
        intranetUtilization.Screensize__c = UserSession.ScreenSize; 
        intranetUtilization.User__c = UserSession.UserId;
        
        //Added By - Abhinav Sharma - CR-20150128-8603 - 04/01/2015
        //Start From here
        intranetUtilization.Hour__c = system.now().hour();
        //Upto Here
        
        if (intranetUtilization.Intranet_Item__c != null) {
            
            //V_1.4 - Modified By - Mahendra Swarnkar - CR-20161005-10203 - 07/07/2017 - Starts from here
            //Initialize schedular instance
            Sched_UtilizationInsert sched = new Sched_UtilizationInsert();
            
            //Assign the value for intranetUtilization record
            sched.intranetUtilization = intranetUtilization;
            
            //Build the system time of now + 1 minute to schedule the scheduler that will isert the Intranet Utilization record.
            Datetime sysTime = System.now();
            sysTime = sysTime.addMinutes(1);
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            
            try {
                                
                //Insert intranetUtilization record
                insert intranetUtilization;
                
            } catch(Exception ex){
                
                //Check for the Error
                if(ex.getMessage().contains(system.Label.ERROR_UNABLE_TO_LOCK_ROW)) {
                       
                    //schedule the scheduler
                    Id jobId = System.schedule(SCHEDULER_STATIC_NAME + ((math.random()) * 10000), chron_exp, sched);
                       
                } else {
                    throw new CustomException(ex.getMessage()+' Cause:'+ex.getCause()+ 'Line NO: '+ex.getLineNumber() +'StackTrace: '+ ex.getStackTraceString());             
                }
            }
            //V_1.4 - Modified By - Mahendra Swarnkar - CR-20161005-10203 - 07/07/2017 -- Ends here
        }
    }
    
    /**
     *  @description    :   This method is to provides a List of Intranet Utilizations created by the current user through Likes or Ratings.
     * 
     *  @args           :   none
     * 
     *  @return         :   Map of Click_Type__c + Intranet Item Id and Utilization (ie: key="[ClickType][ItemID]" value=Utilization])
     * 
     **/ 
    public static Map<String, Intranet_Utilization__c> getLikedItems() {
        
        //Create a Map to hold the Intranet Item Id and Utilitzation Record
        Map<String, Intranet_Utilization__c> mapItemIdWithUtilization = new Map<String, Intranet_Utilization__c>();
        
        //Query all the Utilization Reccords for Current User and Click Type = Like
        for(Intranet_Utilization__c intranetUtilization : [Select Id, Name, Name__c, Intranet_Container__c, Intranet_Item__c, Intranet_Schedule__c, Click_Type__c from Intranet_Utilization__c 
                                                                where Intranet_Item__c != null AND User__c =: UserInfo.getUserId()]) {
            
            //Populate Map
            mapItemIdWithUtilization.put(intranetUtilization.Click_Type__c + intranetUtilization.Intranet_Item__c, intranetUtilization);
        }
        
        //Return Map
        return mapItemIdWithUtilization;
    }
    
    //Added - CR-20141003-7624 - Rajeev Jain - 05/01/2015 
    //Start FROM Here
    //Map to Hold the Mapping of Tab items with Intranet Custom Setting Records Name, Used in Tab Utilization Record Creation
    private static Map<String,String> pTabUtilizationItemMap;
    
    public static Map<String,String> TabUtilizationItemMap{
        
        get{
            if(pTabUtilizationItemMap == null){
                pTabUtilizationItemMap = new Map<String,String>{'Training' => 'Training Event Tab Utilization',
                                                                'Member Events' => 'Member Event Tab Utilization',
                                                                'Birthdays' => 'Birthday Event Tab Utilization',
                                                                'Food' => 'Food Tab Utilization',
                                                                'Weather' => 'Office Weather Tab Utilization',
                                                                'News' => 'Office News Tab Utilization',
                                                                'Events' => 'Office Events Tab Utilization',
                                                                'BoardRoom Home Page' => 'Board Room Main Page Utilization'} ;   
            }
            return pTabUtilizationItemMap;
        }
    }
    //Upto here
}