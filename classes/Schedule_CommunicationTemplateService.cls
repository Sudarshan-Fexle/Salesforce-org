/**
* 
* Desription      :   This class is used to schedule callCommunicationTemplateService future method which sends the calender invites to registered Registrations.
*
* Revision Logs   :   V1.0 - 07/14/2021 - Created - CR-20210709-15278 - Chirag Soni.
*		  :   V1.1 - 09/20/2021 - Modified - CR-20210628-15254 - Chirag Soni - Updated the Method createWebServiceBody() and getLongDate() to update payload
* 		  :   V1.2 - 10/26/2021 - Modified - CR-20211025-15548 - Chirag Soni - Updated Method  callWebServiceToSendCommunicationtTemplate() and getLongDate().
*		  :   V2.3 - 10/27/2021 - Modified - CR-20210914-15437 - Chirag Soni - Updated createWebServiceBody() Method to take Contact Email instead of Company email
*		  :   V2.4 - 02/07/2022 - Modified - CR-20220204-15768 - Chirag Soni - Added Util.IsInviteSent check in method callWebServiceToSendCommunicationtTemplate()
*		  :   V2.5 - 02/22/2022 - Modified - CR-20220119-15719 - Chirag Soni - Updated createWebServiceBody() added new field values on venue node in JSON
*
**/
public class Schedule_CommunicationTemplateService implements Schedulable,Database.AllowsCallouts  {
    
    Set<Id> setOfRegistrationIds = new Set<Id>();
    String reqMethod;
    boolean meetingUpdated;
    public static boolean isRegistered;
    
    public Schedule_CommunicationTemplateService(Set<Id> setOfRegistrationIds, String reqMethod, boolean meetingUpdated){
        
        this.setOfRegistrationIds = setOfRegistrationIds;
        this.reqMethod = reqMethod;
        this.meetingUpdated = meetingUpdated;
    }
    
    public void execute(SchedulableContext context) {
        
        //added size check w.r.t callCommunicationTemplateService method
        if(setOfRegistrationIds.size()>0){ 
            callCommunicationTemplateService(setOfRegistrationIds, reqMethod, meetingUpdated);
        }
        
    }
    
    
    @Future(callout=true)
    public static void callCommunicationTemplateService(Set<Id> setOfRegistrationIds, String reqMethod, boolean meetingUpdated) {
        
        //Check the size of the set. 
        if(setOfRegistrationIds.size() > 0) {
            callWebServiceToSendCommunicationtTemplate(setOfRegistrationIds, reqMethod, meetingUpdated);
        }
    }
    
    
    //06/12/2020 - CR-20200612-14180 - Victor Hanson - updated to use list of registrations and log success/error message
    //07/16/2020 - Victor Hanson - CR-20200707-14273 - added support for void callout
    //08/04/2020 - Victor Hanson - CR-20200804-14400 - added meetingUpdated to createWebServiceBody
    //10/08/2020 - CR-20200819-14447 - Saurabh Kumar - Replaced the reference from Meeting to EAB Event
    //03/03/2021 - CR-20210302-14959 - Saurabh Kumar - Added Zoom_Password__c field to the query.
    //07/27/2021 - CR-20210709-15278  - Chirag Soni - This method is moved from Registration helper class  to this class 
    //10/26/2021 - CR-20211025-15548 - Chirag Soni -  Added new field EAB_Event__r.Length_Days__c, in Query. 
    //02/07/2022 - CR-20220204-15768 - Chirag Soni - Added Util.IsInviteSent check
      public static HttpResponse callWebServiceToSendCommunicationtTemplate(Set<Id> setOfRegistrationIds, String reqMethod, boolean meetingUpdated) 
      {
          
          //Set to hold the eligible values for Event Types 
          Set<String> setOfEligibleEventTypes = new Set<String>();
          
          API_Endpoints__mdt communicationAPIDetail = [Select Id, Authorization_Token__c, 
                                                       Endpoint_URL__c From API_Endpoints__mdt 
                                                       Where MasterLabel = 'CommunicationTemplate_API' ];
          
          
          //Modified By - Abhinav Shrama - CR-20200923-14547 - 09/25/2020 - Added Contact__r.Email field in query
          //CR-20200707-14273 - 07/16/2020 - Victor Hanson - added timezone fields to query                                           
          //Updated by Saurabh Kumar - CR-20200819-14447 - 10/08/2020
          //Query on the Registration and get the results - Registration=>Meeting=>Eab Event.
          Map<Id, Registration__c> mapRegs = new Map<Id, Registration__c>([Select id, EAB_Event__c, Status__c,
                                                                           Zoom_Participant_URL__c, 
                                                                           EAB_Event__r.Communication_Template__r.Name,
                                                                           Contact__r.Email,
                                                                           EAB_Event__r.Event_Type__c,
                                                                           EAB_Event__r.Public_Name__c, 
                                                                           EAB_Event__r.Zoom_DialIn_Number__c,
                                                                           EAB_Event__r.Length_Days__c,
                                                                           EAB_Event__r.Zoom_Meeting_ID__c,
                                                                           EAB_Event__r.Long_Date__c,
                                                                           EAB_Event__r.Event_Website__c,
                                                                           EAB_Event__r.Begins__c, 
                                                                           EAB_Event__r.Ends__c,
                                                                           EAB_Event__r.Location__c,
                                                                           EAB_Event__r.Begins_Long_Date__c , 
                                                                           EAB_Event__r.Ends_Long_Date__c,
                                                                           EAB_Event__r.Begins_Long_Time__c,
                                                                           EAB_Event__r.Zoom_Password__c,//03/03/2021 - CR-20210302-14959 - Saurabh Kumar - Added Zoom_Password__c field to the query.
                                                                           Contact__c, Contact__r.Company_Email__c, Contact__r.Name,
                                                                           Contact__r.Asst_Email__c,
                                                                           /*Calendar_Hold_Sent__c,*/
                                                                           Contact__r.Account.Time_Zone_Id__c,
                                                                           Contact__r.Account.Time_Zone_Name__c
                                                                           From Registration__c 
                                                                           Where Id IN: setOfRegistrationIds AND Contact__c != null
                                                                           AND EAB_Event__c != null
                                                                           AND EAB_Event__r.Disable_Calendar_Invites__c = false
                                                                           /*AND EAB_Event__r.Communication_Template__c  != null *02/07/2021 - CR-20210207-14878 - VH - commented out because we no longer require communication template* */]);
          
          //Modified By - Abhinav Shrama - CR-20200923-14547 - 09/25/2020 - Added Contact__r.Email field in query
          //CR-20200707-14273 - 07/16/2020 - Victor Hanson - added timezone fields to query
          //Query on the Registration and get the results - Registration=>Meeting=>Eab Event.
          /*Map<Id, Registration__c> mapRegs = new Map<Id, Registration__c>([Select Id, Meeting__c, Status__c,
	    Zoom_Participant_URL__c, 
	    Meeting__r.EAB_Event__r.Communication_Template__r.Name,
	    Meeting__r.EAB_Event__c,
	    Contact__r.Email, 
	    Meeting__r.EAB_Event__r.Event_Type__c,
	    Meeting__r.EAB_Event__r.Public_Name__c, 
	    Meeting__r.EAB_Event__r.Zoom_DialIn_Number__c,
	    Meeting__r.EAB_Event__r.Zoom_Meeting_ID__c,
	    Meeting__r.EAB_Event__r.Event_Website__c,
	    Meeting__r.DateTime__c, 
	    Meeting__r.End_DateTime__c,
	    Contact__c, Contact__r.Company_Email__c, Contact__r.Name,
	    Contact__r.Asst_Email__c,
	    //Calendar_Hold_Sent__c,
	    Contact__r.Account.Time_Zone_Id__c,
	    Contact__r.Account.Time_Zone_Name__c
	    From Registration__c 
	    Where Id IN: setOfRegistrationIds AND Contact__c != null  
	    AND Meeting__r.EAB_Event__r.Communication_Template__c  != null]);*/
          
          //08/04/2020 - Victor Hanson - CR-20200804-14400 - added meetingUpdated
          String body = createWebServiceBody(mapRegs.values(), meetingUpdated);
          
          HttpRequest request = new HttpRequest();
          request.setEndpoint(communicationAPIDetail.Endpoint_URL__c + '?environment=' + EncodingUtil.urlEncode(URL.getSalesforceBaseUrl().toExternalForm(), 'UTF-8'));
          request.setMethod(reqMethod);
          request.setTimeout(120000);
          request.setBody(body);
          request.setHeader(Constants.X_API_KEY, communicationAPIDetail.Authorization_Token__c);
          request.setHeader(Constants.ACCEPT, Constants.CONTENT_TYPE_APP_JSON);
          request.setHeader(Constants.CONTENT_TYPE, Constants.CONTENT_TYPE_APP_JSON);
          //Test class issue fixes - Chirag Soni - 09/01/2021

          
          HttpResponse res;
	  //Updated By - Chirag Soni - CR-20220119-15719 
          //if(!test.isRunningTest())
          	res = new Http().send(request);
          
          try {
              //07/21/2020 - CR-20200707-14273 - VH - commented out because Jeffery is no longer sending anything in the body
              //Map to hold the response param. 
              //{"a4A2K000000e66E-001":{"successful":true},"a4A2K000000e66E-002":{"successful":true}}
              /*Map<String, Object> mapOfResponseParam = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

List<Registration__c> regsToUpdate = new List<Registration__c>();*/
              for (Registration__c reg : mapRegs.values()) {
                  reg.Calendar_Hold_Sent__c = 'true';
              }
              if (mapRegs.size() > 0)
                  update mapRegs.values();
                //Modified - CR-20220204-15768 - Chirag Soni Added
                 Util.IsInviteSent = true;
          }
          catch(Exception e) {
              
          }
          return res;
      }
    
    //07/27/2021 - CR-20210709-15278  - Chirag Soni - This method is moved from Registration helper class  to this class 
    //08/06/2021 - CR-20210804-15330 - Chirag Soni - Added condition to enviroment detail and append unique id to it
    //09/20/2021 - CR-20210628-15254 - Chirag Soni - performed changes to add new payload field "Venue" in the HTTP Request 
    //10/18/2021 - CR-20210628-15254 - Chirag Soni - Modified the " Location at " to " location at "
    //Modified By - Chirag Soni - CR-20210914-15437 - 10/27/2021 - Replaced the Company Email filed with Email
    //02/22/2022 - CR-20220119-15719 - Chirag Soni - Added new values on venue node in JSON
    public static String createWebServiceBody(List<Registration__c> regs, boolean meetingUpdated) {
        
        //Creating body of registration. 
        String jSONBody = '[';
        
        Integer count = 1;
        
       //Chirag Soni - CR20210804-15330 - Added condition to enviroment detail and append unique id to it - Starts here
        String enviromentDetails = 'Production-'; 
        
        if([SELECT IsSandbox FROM Organization].IsSandbox){
            enviromentDetails = URL.getSalesforceBaseUrl().getHost().substringBetween('--','.')+'-';
        }
        //Chirag Soni - CR20210804-15330 - Added condition to enviroment detail and append unique id to it - ends here
        
        //Added by  - Chirag Soni -  09/20/2021 - CR-20210628-15254 - Created a set to hold EAB Event, Added a for loop to store eab event Id and 
        //							      Created a map to store EAB Event primary venue - Start Here
   	//set to store eab event Ids 
        Set<Id> setOfEABEvent = new Set<Id>();
        //map to store EAB Event primary venue
        Map<Id, String> mapOfEABEventIdWithPrimaryVenue = new Map<Id, String>();
        
        for (Registration__c reg : regs){
            if(reg != null && reg.EAB_Event__c != null)
                setOfEABEvent.add(reg.EAB_Event__c);
            if(!mapOfEABEventIdWithPrimaryVenue.containsKey(reg.EAB_Event__c))
                mapOfEABEventIdWithPrimaryVenue.put(reg.EAB_Event__c,'');
        }
        //Updated By - Chirag Soni - CR-20220119-15719 - added new fields in Query 
        for(Venue__c venue : [Select Advisory_Event__c, Name, Venue_Address__c, Primary_City__c, Primary_Postal_Code__c, Primary_State_Province__c From Venue__c Where Primary__c = True AND Advisory_Event__c IN: mapOfEABEventIdWithPrimaryVenue.keySet()]){
            //Updated by - Chirag Soni - 10/18/2021 - CR-20210628-15254 - Modified the " Location at " to " location at "
            if(mapOfEABEventIdWithPrimaryVenue.containsKey(venue.Advisory_Event__c) && venue != null){
                
                //Updated By - Chirag Soni - CR-20220119-15719 - added new fields 
                mapOfEABEventIdWithPrimaryVenue.put(venue.Advisory_Event__c, venue.Name + '<br/>' + venue.Venue_Address__c+'<br/>'+venue.Primary_City__c+', '+venue.Primary_State_Province__c+'<br/>'+venue.Primary_Postal_Code__c);
            }
        }
		
        //Added by  - Chirag Soni -  09/20/2021 - CR-20210628-15254 - Created a set to hold EAB Event, Added a for loop to store eab event Id and 
        //							      Created a map to store EAB Event primary venue - Start Here
        for (Registration__c reg : regs) {
            
            if(reg != null) {
                //add a comma to separate these objects if there are multiple
                if (count > 1 && count < regs.size()+1) {
                    jSONBody += ',';
                }
                //prep for new reg in list
                jSONBody += '{';
                
                Map<String, Object> mapOfWebServiceParameters = new Map<String, Object>();
                
                //String to create the format of mobileOneTouch. FORMAT - 16699006833,,1234567890#,#
                String oneTouchString = '';
                oneTouchString = String.isNotBlank(reg.EAB_Event__r.Zoom_DialIn_Number__c) ? reg.EAB_Event__r.Zoom_DialIn_Number__c.replace('+', '').replace('-', '') + ',,' : '';
                oneTouchString += String.isNotBlank(reg.EAB_Event__r.Zoom_Meeting_ID__c) ? reg.EAB_Event__r.Zoom_Meeting_ID__c.replace('-', '') + '#' : '';
                
                //Added by -  Chirag Soni - CR-20210628-15254 - 09/20/2021 - added the string to store Modified venue.
		//Chirag Soni - CR20210804-15330 - Append Unique id with enviroment details.
                mapOfWebServiceParameters.put('uniqueid', reg.Id); 
                
                mapOfWebServiceParameters.put('Venue', mapOfEABEventIdWithPrimaryVenue.get(reg.EAB_Event__c));
                
                if (reg.EAB_Event__r.Public_Name__c != null)
                    mapOfWebServiceParameters.put('subject', reg.EAB_Event__r.Public_Name__c);
                if (reg.EAB_Event__r.Begins__c != null)
                   mapOfWebServiceParameters.put('startTime', parseDateTime(reg.EAB_Event__r.Begins__c));
                if (reg.EAB_Event__r.Ends__c != null)
                  mapOfWebServiceParameters.put('endTime', parseDateTime(reg.EAB_Event__r.Ends__c));
                
                if (Label.Location_CommunicationTemplatedAPI != null)
                    mapOfWebServiceParameters.put('location', reg.EAB_Event__r.Location__c);
                if (Label.EAB_Events != null)
                    mapOfWebServiceParameters.put('organizer', Label.EAB_Events);
                
                //Modified By - Abhinav Shrama - CR-20200923-14547 - 09/25/2020 - Added Contact Email value when Company Email is not exist
                   
                //Modified By - Chirag Soni - CR-20210914-15437 - 10/27/2021 - Replaced the Company Email filed with Email - From Here
                if (reg.Contact__r.Email != null){
                    mapOfWebServiceParameters.put('member', reg.Contact__r.Email);
                }
                else if(reg.Contact__r.Company_Email__c != null){
                    mapOfWebServiceParameters.put('member', reg.Contact__r.Company_Email__c);
                }
                //Modified By - Chirag Soni - CR-20210914-15437 - 10/27/2021 - Replaced the Company Email filed with Email - Till Here
                
                if (reg.Contact__r.Asst_Email__c != null)
                    mapOfWebServiceParameters.put('assistant', reg.Contact__r.Asst_Email__c);
                if (reg.EAB_Event__r.Communication_Template__r.Name != null)
                    mapOfWebServiceParameters.put('template', reg.EAB_Event__r.Communication_Template__r.Name);
                if (reg.Zoom_Participant_URL__c != null)
                    mapOfWebServiceParameters.put('zoomurl', reg.Zoom_Participant_URL__c);
                if (reg.EAB_Event__r.Zoom_Meeting_ID__c != null)
                    mapOfWebServiceParameters.put('zoomid', reg.EAB_Event__r.Zoom_Meeting_ID__c);
                if (reg.EAB_Event__r.Zoom_DialIn_Number__c != null)
                    mapOfWebServiceParameters.put('zoomdialin', reg.EAB_Event__r.Zoom_DialIn_Number__c);
                //CR-20200707-14273 - 07/16/2020 - Victor Hanson - added getLongDate method
                if (reg.EAB_Event__r.Begins__c != null)
                    mapOfWebServiceParameters.put('dates', getLongDate(reg));
                
                //CR-20200803-14398 - 08/04/2020 - Victor Hanson - added meetingUpdated
                mapOfWebServiceParameters.put('meetingUpdated', meetingUpdated);
                
                if (reg.EAB_Event__r.Event_Website__c != null)
                    mapOfWebServiceParameters.put('website', reg.EAB_Event__r.Event_Website__c);
                if (reg.Contact__r.Name != null)
                    mapOfWebServiceParameters.put('AttendeeName', reg.Contact__r.Name);
                if (oneTouchString != null)
                    mapOfWebServiceParameters.put('mobileOneTouch', oneTouchString);
                //CR-20200707-14273 - 07/16/2020 - Victor Hanson - added timezone info
                if (reg.Contact__r.Account.Time_Zone_Id__c != null)
                    mapOfWebServiceParameters.put('preferredTimeZoneId', reg.Contact__r.Account.Time_Zone_Id__c);
                if (reg.Contact__r.Account.Time_Zone_Name__c != null)
                    mapOfWebServiceParameters.put('preferredTimeZoneName', reg.Contact__r.Account.Time_Zone_Name__c);
                
                for(String s  : mapOfWebServiceParameters.KeySet()) {
                    jSONBody += '"' +  s + '": ' +  '"' + mapOfWebServiceParameters.get(s) + '", ';  
                }
                jSONBody = jSONBody.removeEnd(', ') + '}';
                
                count++;
            }
        }
        //close array
        jSONBody += ']';
        
        return jSONBody;
    }
    
    //This method is used to parse the Date time to String format & convert it in the gmt format.
    //07/27/2021 - CR-20210709-15278  - Chirag Soni - This method is moved from Registration helper class  to this class  
    public static String parseDateTime(DateTime dt) {
        
        String parsedDateTime = '';
        
        if(dT != null) {
            parsedDateTime = String.valueOfGmt(dt).replace(' ', 'T').substringBeforeLast(':') + ':00Z';
        }
        return parsedDateTime;
    }
    
   /**
    * 	@description	:	returns the long version of the start/end dateTimes for a registration
    * 
    * 	@revision log	:	07/16/2020 - CR-20200707-14273 - Victor Hanson - created
    * 				08/04/2020 - CR-20200804-14400 - Victor Hanson - updated getLongDate to fix an issue with null timezone & added formatting for AM/PM to a.m./p.m.
    *                       	07/27/2021 - CR-20210709-15278  - Chirag Soni - This method is moved from Registration helper class  to this class 
    *				09/20/2021 - CR-20210628-15254 - Chirag Soni - Updated the method to filter different communication template and modified in the longDate
    * 				10/26/2021 - CR-20211025-15548 - Chirag Soni - Added condition for all day event
    * 				02/25/2022 - Chirag Soni - CR-20220119-15719 - Remove extra period for dinner and receptions
    **/
    
    public static String getLongDate(Registration__c reg) {
        String timezone = Constants.TIMEZONE_AMERICA_NEWYORK;
        String timezoneName = 'Eastern Time';
        String longDate;
        //Updated by  -  Chirag Soni -  09/20/2021 - Modified the body data - From Here
        if (reg.EAB_Event__r.Communication_Template__r.Name != null && reg.EAB_Event__r.Begins__c != null && reg.EAB_Event__r.Ends__c != null){
            
            if (reg.EAB_Event__r.Communication_Template__r.Name == 'In-Person Event' && reg.EAB_Event__r.Length_Days__c > 1) //10/26/2021 - CR-20211025-15548 - Chirag Soni - updated
                longDate = reg.EAB_Event__r.Begins_Long_Date__c + ' - ' +reg.EAB_Event__r.Ends_Long_Date__c;
            else if(reg.EAB_Event__r.Communication_Template__r.Name == 'In-Person Event' && reg.EAB_Event__r.Length_Days__c == 1) //10/26/2021 - CR-20211025-15548 - Chirag Soni - Added
                longDate = reg.EAB_Event__r.Begins_Long_Date__c;
            
            else if((reg.EAB_Event__r.Communication_Template__r.Name == 'Dinner' || reg.EAB_Event__r.Communication_Template__r.Name == 'Reception'))
                
                //Updated By - Chirag Soni - CR-20220119-15719 - Remove extra period for dinner and receptions
                longDate = reg.EAB_Event__r.Begins_Long_Date__c + ' at ' +reg.EAB_Event__r.Begins_Long_Time__c.left(reg.EAB_Event__r.Begins_Long_Time__c.length()-1);
            
            else if(reg.EAB_Event__r.Communication_Template__r.Name == 'Virtual Event'){
                longDate = '';
                //if timezone name or id are blank, default to eastern
                if (!String.isBlank(reg.Contact__r.Account.Time_Zone_Id__c) && !String.isBlank(reg.Contact__r.Account.Time_Zone_Name__c)) {
                    timezone = reg.Contact__r.Account.Time_Zone_Id__c;
                    timezoneName = reg.Contact__r.Account.Time_Zone_Name__c;
                }
                longDate += reg.EAB_Event__r.Begins__c.format('EEEE, MMMM d | h:mm [a]', timezone).replace('[AM]', 'a.m.').replace('[PM]', 'p.m.'); //Specify Time zone like America/New_York
                longDate += ' - ' + reg.EAB_Event__r.Ends__c.format('h:mm [a]', timezone).replace('[AM]', 'a.m.').replace('[PM]', 'p.m.') + ' ' + timezoneName;
            }
        }
        //Updated by  -  Chirag Soni -  09/20/2021 - Modified the body data - Till Here
        
        //Commented by  -  Chirag soni -  09/20/2021 -  Moved the logic in above else if logic - From here
        /*
        //if timezone name or id are blank, default to eastern
        if (!String.isBlank(reg.Contact__r.Account.Time_Zone_Id__c) && !String.isBlank(reg.Contact__r.Account.Time_Zone_Name__c)) {
            timezone = reg.Contact__r.Account.Time_Zone_Id__c;
            timezoneName = reg.Contact__r.Account.Time_Zone_Name__c;
        }
        String longDate += reg.EAB_Event__r.Begins__c.format('EEEE, MMMM d | h:mm [a]', timezone).replace('[AM]', 'a.m.').replace('[PM]', 'p.m.'); //Specify Time zone like America/New_York
        longDate += ' - ' + reg.EAB_Event__r.Ends__c.format('h:mm [a]', timezone).replace('[AM]', 'a.m.').replace('[PM]', 'p.m.') + ' ' + timezoneName;*/
        //Commented by  -  Chirag soni -  09/20/2021 -  Moved the logic in above else if logic - Till here
        return longDate;
    }
    
}