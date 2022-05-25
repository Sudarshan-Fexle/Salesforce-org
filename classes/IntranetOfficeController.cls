//V_1.1 - modified By - Rajeev Jain - 07/16/2015 - CR-20150618-9016 - BoardRoom mobile Conversion to  avoid proxies error in salesforce.
//V_1.2 - Modified by - Rajeev Jain - 08/11/2015 - CR-20150618-9016 - Improved utilization tracking and added device info.
//V_1.3 - Modified by - Mahendra Swarnkar - 10/11/2016 - CR-20160926-10187 - Populated constants variables from newly created constant labels
global class IntranetOfficeController extends IntranetBaseController {
    
    private IntranetContainer mContainer;
    public String OfficeContainerId { get; set;}

    public IntranetContainer OfficeContainer {
        get {
            if(mContainer == null) NewOfficeSelected();
    
            return mContainer;
        }
    }

    private Id mSelectedOffice;
    private IntranetType.UserSession userSession;
    
    public Id getSelectedOffice() {
        if(mSelectedOffice == null) {
            if(userSession == null)
                userSession = IntranetHomeUtility.getUserSession;
            if(userSession != null) mSelectedOffice = userSession.AssignedOffice;
            if(mSelectedOffice == null) {
                for(SelectOption option : OfficeSelectList) {
                    if(option.getLabel().contains('DC')) {
                        mSelectedOffice = Id.valueOf(option.getValue());
                        break;
                    }
                }
            }
    	}
        return mSelectedOffice;
    }
    public void setSelectedOffice(Id value){
        mSelectedOffice = value;
    }
    
    public String getSelectedOfficeName() {
        for(SelectOption option : OfficeSelectList) {
            if(Id.valueOf(option.getValue()) == getSelectedOffice()) return option.getLabel();
        }
        
        return null;
    }
    
    public List<SelectOption> OfficeSelectList {
        get {
            return IntranetHomeUtility.OfficeSelectList;
        }
    }
    
    public IntranetOfficeController(){
        super();
    }
    
    public PageReference NewOfficeSelected() {
    
        office = null;
        weatherCache = null;
        LocationData = null;

        Id mainContainerId = this.OfficeContainerId;
        Id previewScheduleId = this.SchedId;
        Id officeId = getSelectedOffice();

        IntranetType.UserSession userSession = IntranetHomeUtility.getUserSession;       
        Map<string, Intranet_Utilization__c> maplikedItems = IntranetUtilizationHelper.getLikedItems();
    
        IntranetContainer officeNewsContainer;
        IntranetContainer newsCarouselContainer;
        
        IntranetContainer con = BoardroomHomeContainerController.GetContainer(mainContainerId);
        Map<Id, IntranetContainer> mapContainers = BoardroomHomeContainerController.GetContainersByTopParentContainerId((String) con.TopContainerId);
        
        for (IntranetContainer ic : mapContainers.values()) {
            if(ic.ContainerType == 'SubContainer' && ic.DisplayName.contains('News'))
                officeNewsContainer = ic;
            if(ic.ContainerType == 'News Carousel')
                newsCarouselContainer = ic;
            
            IntranetContainer pc;
            if(ic.ParentContainerId == null) {
                pc = mapContainers.get(ic.ParentContainerId);
                if(pc != null)
                    pc.SubContainers.Add(ic);
            }
        }
        
        this.mContainer = mapContainers.get(mainContainerId);
        
        Map<Id, Intranet_Schedule__c> associatedSchedules = BoardroomHomeContainerController.GetOfficeSchedules(mapContainers.keySet(), OfficeId, previewScheduleId);
        
        // Get preview container ids, preview item ids
        Set<Id> previewContainerIds = new Set<Id>();
        Set<Id> itemIds = new Set<Id>();
        Id previewItemId;
        
        for (Intranet_Schedule__c sched : AssociatedSchedules.values()){
            itemIds.add(sched.Intranet_Item__c);
            
            if(previewScheduleId != null && sched.Id == previewScheduleId) {
                previewContainerIds.add(sched.Intranet_Container__c);
                previewItemId = sched.Intranet_Item__c;
            }
        }

        Map<Id, Intranet_Item__c> AssociatedItems = BoardroomHomeContainerController.GetContentItems(ItemIds, null, null, null);
        
        for (Intranet_Schedule__c sch : associatedSchedules.values()) {
            
            if(!AssociatedItems.containsKey(sch.Intranet_Item__c)) continue;
            if(!mapContainers.containsKey(sch.Intranet_Container__c)) continue;
            
            IntranetContainer parentContainer = mapContainers.get(sch.Intranet_Container__c);
            parentContainer.IsPreview = previewContainerIds.contains(parentContainer.ContainerId);

            // We end up get all the news items regardless of office now, we have to re-filter them here.
            if(officeId != null && sch.Office__c != null &&newsCarouselContainer != null && 
               parentContainer.ContainerId == newsCarouselContainer.ContainerId &&
               id.valueOf(sch.Office__c) != id.valueOf(officeId)) {
                   continue;
            }
            
            IntranetContent ic = new IntranetContent(parentContainer, sch, AssociatedItems.get(sch.Intranet_Item__c),
                                                     userSession, maplikedItems);
            parentContainer.RelatedContent.add(ic);
        }
        
        // Attach News Carousel items to Office News Container
        if(officeNewsContainer != null && officeId != null && newsCarouselContainer != null) {
            officeNewsContainer.RelatedContent.clear();
            officeNewsContainer.RelatedContent.addAll(newsCarouselContainer.RelatedContent);
        }
        
        // I really do NOT like this: we need make this a static method.
        BoardroomHomeContainerController controller = new BoardroomHomeContainerController();
        for(Id key : mapContainers.keyset()) {
            controller.SortLimitContainerContent(mapContainers.get(key), previewItemId);
        }

        for (IntranetContainer ic : mapContainers.values()) {
            if(mapContainers.containsKey(ic.ParentContainerId)) {
            IntranetContainer pc = mapContainers.get(ic.ParentContainerId);
            pc.SubContainers.Add(ic);
                pc.SubContainers.sort();
            }
        }
		//V_1.2 - Modified by - Rajeev Jain - 08/11/2015 - CR-20150618-9016 - Improved utilization tracking and added device info.
        String deviceData = getCookieVal('deviceData');
        String browserData = getCookieVal('browserData');
        String screenData = getCookieVal('screenSize');
        
        //Reset Cookies after setting in the User Session
        setCookies('deviceData',null);
        setCookies('browserData',null);
        setCookies('screenData',null);
         
         //Track User Session
        
        //Load User Session
        UserSession = IntranetHomeUtility.getUserSession;
        if(String.isNotBlank(screenData))
        	UserSession.ScreenSize = IntranetHomeUtility.convertScreenSizeToString(Integer.valueOf(screenData));
        userSession.Browser = browserData;
        userSession.device = deviceData;
        userSession.JobLevel = IntranetHomeUtility.getUserSession.JobLevelActual;
            
       
         //Call future method to create a utilization record
        IntranetUtilizationHelper.createIntranetUtilizationRecord(JSON.serialize(UserSession), IntranetUtilizationHelper.CLICK_TYPE_OFFICECHANGE, null, mainContainerId, officeId, SchedId, null); 
        //V_1.2 - Modified by - Rajeev Jain - 08/11/2015 - CR-20150618-9016 - Improved utilization tracking and added device info.
        //Upto Here
        return null;
    }
    //V_1.2 - Modified by - Rajeev Jain - 08/11/2015 - CR-20150618-9016 - Improved utilization tracking and added device info.
    /* Method to Get Cookies values from Browser*/
	private String getCookieVal(String cookieName){
		String cookieVal = '';
		Cookie cookie;
		cookie = ApexPages.currentPage().getCookies().get(cookieName);
		 if(cookie != null)
            cookieVal = cookie.getValue();
        return cookieVal;
	}
    
    /* Method to Set Cookies values from Browser*/
    private void setCookies(String cookieName, String value){
        Cookie cook = new Cookie(cookieName,value,null,-1,false);
    }
    
    //V_1.2 - Modified by - Rajeev Jain - 08/11/2015 - CR-20150618-9016 - Improved utilization tracking and added device info.
    //Upto Here - By Rajeev
    //
    @future
    public static void UpdateWeather(Id officeId, string weatherJSON) {
        if (weatherJSON != null) {
            Intranet_Item__c intranetItem_Office = new Intranet_Item__c(Id = officeId,
                                                                        Weather_Response__c = weatherJSON,
                                                                        Last_Content_Update__c = dateTime.now());
            update intranetItem_Office;
        }
    }
    
    //V_1.3 - Modified by - Mahendra Swarnkar - 10/11/2016 - CR-20160926-10187
    //Hard coded values are replaced with custom labels
    //Start from here
    
    //NOTE: This URL and API Key should be added as a Custom Label
    //public static final string WEATHER_API_KEY = 'e005d0f8072ab8fcaf28d166a6f58a78';
    public static final string WEATHER_API_KEY = System.Label.BR_PAGE_WEATHER_API_KEY;
    
    //public static final string WEATHER_URL = 'https://api.forecast.io/forecast/';
    public static final string WEATHER_URL = System.Label.BR_PAGE_WEATHER_API_HOST_URL;
    
    //V_1.3 - Modified by - Mahendra Swarnkar - 10/11/2016 - CR-20160926-10187 - Upto here
    
    public static string WEATHER_DATA { get; set; }
    
    public string LocationData {
        get {
            if (LocationData == null) {
                //PLACEHOLDER
                if (office != null) {
                    LocationData = office.Location__Latitude__s + ',' + office.Location__Longitude__s + ',' + office.Id;
                }
            }
            return LocationData;
        }
        set;
    }
    
    /**
     * @description: Determine whether or not the weather needs to be updated
     *
     **/
    public boolean UpdateWeather {
        get {
            UpdateWeather = False;
            if (LastContentUpdate != null) {
                DateTime oldPlusThirty = LastContentUpdate.addMinutes(30);
                if(oldPlusThirty < dateTime.now()){
                    UpdateWeather = true;
                }
            } else {
                UpdateWeather = true;
            }
        	return UpdateWeather;
        }
        set;
    }
    
    public DateTime LastContentUpdate {
        get {
            return office.Last_Content_Update__c;
        }   
        set;
    }
    
    public Id MainImageOfficeId {
        get {
            return office.Image_Set_Main_Image_Id__c;
        }
        set;
    }
    
    /**
     * @description:	get the cached weather JSON form the Office record
     * 
     **/
    public string weatherCache {
        get {
            if (office != null) {
                //weatherCache = '{"latitude":38.9056,"longitude":-77.05,"timezone":"America/New_York","offset":-4,"currently":{"time":1411148249,"summary":"Mostly Cloudy","icon":"partly-cloudy-day","nearestStormDistance":70,"nearestStormBearing":100,"precipIntensity":0,"precipProbability":0,"temperature":72.97,"apparentTemperature":72.97,"dewPoint":58.32,"humidity":0.6,"windSpeed":5.09,"windBearing":78,"visibility":10,"cloudCover":0.69,"pressure":1024.83,"ozone":315.27},"daily":{"summary":"Light rain on Sunday and Friday, with temperatures peaking at 85°F on Sunday.","icon":"rain","data":[{"time":1411099200,"summary":"Partly cloudy throughout the day.","icon":"partly-cloudy-day","sunriseTime":1411124070,"sunsetTime":1411168331,"moonPhase":0.86,"precipIntensity":0.0001,"precipIntensityMax":0.0006,"precipIntensityMaxTime":1411167600,"precipProbability":0.01,"precipType":"rain","temperatureMin":57.83,"temperatureMinTime":1411124400,"temperatureMax":74.74,"temperatureMaxTime":1411153200,"apparentTemperatureMin":57.83,"apparentTemperatureMinTime":1411124400,"apparentTemperatureMax":74.74,"apparentTemperatureMaxTime":1411153200,"dewPoint":56.31,"humidity":0.73,"windSpeed":4.42,"windBearing":73,"visibility":9.57,"cloudCover":0.43,"pressure":1023.44,"ozone":314.42},{"time":1411185600,"summary":"Partly cloudy in the morning.","icon":"partly-cloudy-day","sunriseTime":1411210523,"sunsetTime":1411254633,"moonPhase":0.89,"precipIntensity":0,"precipIntensityMax":0,"precipProbability":0,"temperatureMin":61.44,"temperatureMinTime":1411207200,"temperatureMax":80.61,"temperatureMaxTime":1411243200,"apparentTemperatureMin":61.44,"apparentTemperatureMinTime":1411207200,"apparentTemperatureMax":81.4,"apparentTemperatureMaxTime":1411243200,"dewPoint":60.6,"humidity":0.73,"windSpeed":6.05,"windBearing":134,"visibility":9.72,"cloudCover":0.25,"pressure":1021.96,"ozone":303.04},{"time":1411272000,"summary":"Light rain starting in the afternoon, continuing until evening.","icon":"rain","sunriseTime":1411296976,"sunsetTime":1411340936,"moonPhase":0.92,"precipIntensity":0.0066,"precipIntensityMax":0.0444,"precipIntensityMaxTime":1411333200,"precipProbability":0.36,"precipType":"rain","temperatureMin":63.94,"temperatureMinTime":1411293600,"temperatureMax":84.8,"temperatureMaxTime":1411329600,"apparentTemperatureMin":63.94,"apparentTemperatureMinTime":1411293600,"apparentTemperatureMax":86.23,"apparentTemperatureMaxTime":1411329600,"dewPoint":63.35,"humidity":0.73,"windSpeed":3.77,"windBearing":217,"visibility":9.71,"cloudCover":0.23,"pressure":1011.76,"ozone":289.83},{"time":1411358400,"summary":"Clear throughout the day.","icon":"clear-day","sunriseTime":1411383429,"sunsetTime":1411427239,"moonPhase":0.95,"precipIntensity":0.0003,"precipIntensityMax":0.0019,"precipIntensityMaxTime":1411358400,"precipProbability":0.02,"precipType":"rain","temperatureMin":59.94,"temperatureMinTime":1411383600,"temperatureMax":71.67,"temperatureMaxTime":1411419600,"apparentTemperatureMin":59.94,"apparentTemperatureMinTime":1411383600,"apparentTemperatureMax":71.67,"apparentTemperatureMaxTime":1411419600,"dewPoint":52.06,"humidity":0.62,"windSpeed":10.48,"windBearing":294,"visibility":10,"cloudCover":0.05,"pressure":1014.32,"ozone":306.82},{"time":1411444800,"summary":"Clear throughout the day.","icon":"clear-day","sunriseTime":1411469883,"sunsetTime":1411513541,"moonPhase":0.98,"precipIntensity":0,"precipIntensityMax":0,"precipProbability":0,"temperatureMin":54.05,"temperatureMinTime":1411470000,"temperatureMax":74.33,"temperatureMaxTime":1411498800,"apparentTemperatureMin":54.05,"apparentTemperatureMinTime":1411470000,"apparentTemperatureMax":74.33,"apparentTemperatureMaxTime":1411498800,"dewPoint":49.34,"humidity":0.63,"windSpeed":4.15,"windBearing":327,"cloudCover":0,"pressure":1022.52,"ozone":287.88},{"time":1411531200,"summary":"Clear throughout the day.","icon":"clear-day","sunriseTime":1411556337,"sunsetTime":1411599844,"moonPhase":0.01,"precipIntensity":0,"precipIntensityMax":0,"precipProbability":0,"temperatureMin":57.77,"temperatureMinTime":1411556400,"temperatureMax":74.27,"temperatureMaxTime":1411585200,"apparentTemperatureMin":57.77,"apparentTemperatureMinTime":1411556400,"apparentTemperatureMax":74.27,"apparentTemperatureMaxTime":1411585200,"dewPoint":53.02,"humidity":0.67,"windSpeed":4.82,"windBearing":48,"cloudCover":0.01,"pressure":1028.19,"ozone":285.88},{"time":1411617600,"summary":"Clear throughout the day.","icon":"clear-day","sunriseTime":1411642790,"sunsetTime":1411686147,"moonPhase":0.04,"precipIntensity":0.0019,"precipIntensityMax":0.0033,"precipIntensityMaxTime":1411689600,"precipProbability":0.09,"precipType":"rain","temperatureMin":53.63,"temperatureMinTime":1411642800,"temperatureMax":72.11,"temperatureMaxTime":1411671600,"apparentTemperatureMin":53.63,"apparentTemperatureMinTime":1411642800,"apparentTemperatureMax":72.11,"apparentTemperatureMaxTime":1411671600,"dewPoint":51.61,"humidity":0.69,"windSpeed":4.59,"windBearing":67,"cloudCover":0.02,"pressure":1030.37,"ozone":287.82},{"time":1411704000,"summary":"Drizzle in the morning.","icon":"rain","sunriseTime":1411729244,"sunsetTime":1411772450,"moonPhase":0.07,"precipIntensity":0.0033,"precipIntensityMax":0.0055,"precipIntensityMaxTime":1411736400,"precipProbability":0.21,"precipType":"rain","temperatureMin":51.68,"temperatureMinTime":1411722000,"temperatureMax":76.99,"temperatureMaxTime":1411758000,"apparentTemperatureMin":51.68,"apparentTemperatureMinTime":1411722000,"apparentTemperatureMax":76.99,"apparentTemperatureMaxTime":1411758000,"dewPoint":52.39,"humidity":0.71,"windSpeed":0.89,"windBearing":45,"cloudCover":0.09,"pressure":1023.78,"ozone":280.4}]}}';
                weatherCache = office.Weather_Response__c;
            }
            if (weatherCache == null) {
                weatherCache = 'null';
            }
            return weatherCache;
        }
        set;
    }
    
    /**
     * @description:	Office the current user is associated with
     * 
     **/
    public Intranet_Item__c office {
        get {
            if (office == null) {
                //get the office record
                list<Intranet_Item__c> offices = [SELECT Id, Location__Latitude__s, Location__Longitude__s, Weather_Response__c, Last_Content_Update__c, Image_Set_Main_Image_Id__c FROM Intranet_Item__c WHERE Id = :mSelectedOffice];
                if (offices.size() > 0) {
                    office = offices[0];
                }
            }
            return office;
        }
        set;
    }
    
    /**
     * @description:	makes a callout to weather.io and returns the json response to the VF Component
     * 
     * @param:			(string) position (ie: '38.9056,-77.05')
     * 
     **/
    @RemoteAction
    global static string getWeather(string positionAndId) {
        try {
            //parse out the lat/lon from the position
            list<string> lat_lon = positionAndId.split(',');
            string lat = lat_lon[0];
            string lon = lat_lon[1];
            string officeId = lat_lon[2];
            
            //prepare HTTP callout
            HTTPRequest req = new HttpRequest();
            req.setTimeout(120000);
            req.setEndpoint(WEATHER_URL + WEATHER_API_KEY + '/' + lat + ',' + lon + '?exclude=minutely,hourly,alerts,flags');
            req.setMethod('GET');
            HTTP http = new HTTP();
            //send the callout and return the response body
            HTTPResponse res = http.send(req);

            String jsonBody = res.getBody();
            //System.debug('Check for JSON Respponse ::: ' + jsonBody);
            // Verify the response
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);
            if(m.containskey('daily')) {
                //cache the weather data
                UpdateWeather(officeId, jsonBody);
                return JSON.serialize(jsonBody);
            }
        }
        catch(Exception ex) {
        }

        return null;
    }
}