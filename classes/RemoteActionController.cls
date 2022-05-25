/**
 *  Description     :   Class to hold the remote action methods.
 * 
 *  Created By      :   Abhinav Sharma    
 * 
 *  Created Date    :   04/28/2015
 * 
 *  Revision Logs   :   V_1.0 - Created - 04/28/2015 - CR-20150219-8692 - Boardroom Speed Issue
 *             			V_1.1 - Modified - 05/01/2015 - Rajeev Jain - CR-20141003-7624
 *             			V_1.2 - Modified - 05/03/2015 - Abhinav Sharma - CR-20141020-7816 - Frequently Accessed Apps in the Hamburger
 *          			V_1.3 - Modified - 07/08/2015 - Rajeev Jain - CR-20150618-9016 - Board Room Mobile
 *             			Description - Added new Remote Action method, Capture Device, Screen and Browser information.
 *         				V_1.4 - Modified - 07/15/2015 - Rajeev Jain - CR-20150618-9016 - Board Room Mobile
 *             			Description - moved 'get weather' remoteaction method from IntranetOfficeController to here
 *          			V_1.5 - Modified - 07/30/2015 - Rajeev Jain - CR-20150709-9072
 * 						V_1.6 - Modified - 08/07/2015 - Rajeev Jain- CR-20150618-9016 - Board Room Mobile - Added device information on Utilization tracking
 * 						V_1.7 - Modified By Mahendra Swarnkar - 11/3/2016 - CR-20160923-10186
 **/
global class RemoteActionController {
    
   /**
    *   @description    :   This method is Record Link Clicks on Page, we are excluding Like reocrd over here because it is already going to be record by Click on Like functionality.
    * 
    *   @CreatedBy      :   Rajeev Jain(09/17/2014) 
    * 					:	V_1.6 - Modified - 08/07/2015 - Rajeev Jain- CR-20150618-9016 - Board Room Mobile - Added device information on Utilization tracking
    *
    *   @args           :   Type of Link Click,
    * 
    *   @return         :   Map of Intranet Item Id and Utilization
    * 
    **/
	@RemoteAction
    global static String recordClickUtilization(String LINK_TYPE, String displayName, String itemId, String scheduleId, 
                                                String containerId, double rating, String DeviceInfo, String BrowserInfo,
                                                         Integer screenSize, String userAgentInfo){
        
        //String to Hold Click Type
        String clickType = '';
        
        //Check for Each Click Type
        if(LINK_TYPE.equalsIgnoreCase('Comment'))
            clickType = IntranetUtilizationHelper.CLICK_TYPE_COMMENT;
        else if(LINK_TYPE.equalsIgnoreCase('Expand'))
            clickType = IntranetUtilizationHelper.CLICK_TYPE_EXPAND;    
        else if(LINK_TYPE.equalsIgnoreCase('Feedback'))
            clickType = IntranetUtilizationHelper.CLICK_TYPE_FEEDBACK;  
        else if(LINK_TYPE.equalsIgnoreCase('Launch App'))
            clickType = IntranetUtilizationHelper.CLICK_TYPE_LAUNCHAPP; 
        else if(LINK_TYPE.equalsIgnoreCase('Office Change'))
            clickType = IntranetUtilizationHelper.CLICK_TYPE_OFFICECHANGE;
        else if(LINK_TYPE.equalsIgnoreCase('Open Web'))
            clickType = IntranetUtilizationHelper.CLICK_TYPE_OPENWEB;   
        else if(LINK_TYPE.equalsIgnoreCase('Open Page'))
            clickType = IntranetUtilizationHelper.CLICK_TYPE_OPENPAGE;  
        else if(LINK_TYPE.equalsIgnoreCase('Select'))
            clickType = IntranetUtilizationHelper.CLICK_TYPE_SELECT;    
        else if(LINK_TYPE.equalsIgnoreCase('Share'))
            clickType = IntranetUtilizationHelper.CLICK_TYPE_SHARE;
        else if (LINK_TYPE.equalsIgnoreCase('Like'))
            clickType = IntranetUtilizationHelper.CLICK_TYPE_LIKE;
        else if (LINK_TYPE.equalsIgnoreCase('Rate'))
            clickType = IntranetUtilizationHelper.CLICK_TYPE_RATE;
        
        //CR-20141003-7624 (Rajeev Jain 05/01/2015) Added new condition to handle click type for tab click
    	//Start from here
        else if(LINK_TYPE.equalsIgnoreCase('Page Section')){
          clickType = IntranetUtilizationHelper.CLICK_TYPE_PAGE_SECTION;    
        }
        else if(LINK_TYPE.equalsIgnoreCase('Office Page Section')){
          clickType = IntranetUtilizationHelper.CLICK_TYPE_PAGE_SECTION;    
        }
        //Upto here
        
        else
            return IntranetUtilizationHelper.ClICK_TYPE_REMOTESUCCESS;      
        
        //Get Shcehdule and Related Data    
        if (scheduleId != null) {
            Intranet_Schedule__c schedule = [SELECT Intranet_Container__c, Intranet_Item__c
                                             FROM Intranet_Schedule__c
                                             WHERE Id = :scheduleId];
            itemId = schedule.Intranet_Item__c;
            containerId = schedule.Intranet_Container__c;
        }
        
		// Modified By Mahendra Swarnkar - 11/3/2016 - CR-20160923-10186 - Starts from here
        transient string tempItemId = itemId;                                                 
        // Modified By Mahendra Swarnkar - 11/3/2016 - CR-20160923-10186 - Ends here
        
        //Check Click type Page Section then handle it explicitly
        if(clickType == IntranetUtilizationHelper.CLICK_TYPE_PAGE_SECTION){
          
            //Get Item Record Id from Intranet Setting map
            String key = IntranetUtilizationHelper.TabUtilizationItemMap.get(displayName);
            
            //Get Item Record Id
            itemId = IntranetHomeUtility.LookupIntranetSetting(key);
            
            // Modified By Mahendra Swarnkar - 11/3/2016 - CR-20160923-10186 - Starts from here
            if(String.isNotBlank(tempItemId) && String.isBlank(itemId))
                itemId = tempItemId;
            // Modified By Mahendra Swarnkar - 11/3/2016 - CR-20160923-10186 - Ends here
        }
              
        //Track User Session
        IntranetHomeUtility.UserDevice = DeviceInfo;
        IntranetHomeUtility.UserBrowser = BrowserInfo;
        IntranetHomeUtility.ScreenSize = screenSize;
    	IntranetHomeUtility.getUserSession.JobLevel = IntranetHomeUtility.getUserSession.JobLevelActual;
                                                            
        //Load User Session
        IntranetType.UserSession UserSession = IntranetHomeUtility.getUserSession;
        
        //Call future method to create a utilization record
        IntranetUtilizationHelper.createIntranetUtilizationRecord(JSON.serialize(UserSession), clickType, displayName, containerId, itemId, scheduleId, rating); 
        
        //Return Remote Record Utilization Success Message                                 
        return IntranetUtilizationHelper.ClICK_TYPE_REMOTESUCCESS + clickType;
        
        //Return Remote Record Utilization Failure message   
        return IntranetUtilizationHelper.CLICK_TYPE_REMOTEFAILUIRE; 
    }
    
     /**
      *   @description    :   This method is Record Link Clicks on Page, we are excluding Like reocrd over here because it is already going to be record by Click on Like functionality.
      * 
      *   @CreatedBy      :   Rajeev Jain(07/08/2015) - CR-20150618-9016 - Board Room Mobile
      *
      *   @args           :   Type of Link Click, Device Info, Browser Info, ScreenSize Info, UserAgent Info
      * 
      *   @return         :   Map of Intranet Item Id and Utilization
      * 
     **/
  	@RemoteAction
    global static String recordUtilizationOnMainPageLoad(String LINK_TYPE, String displayName, String itemId, String scheduleId, 
                                                         String containerId, double rating, String DeviceInfo, String BrowserInfo,
                                                         Integer screenSize, String userAgentInfo){
      
        //Track User Session
       /* IntranetHomeUtility.UserDevice = DeviceInfo;
        IntranetHomeUtility.UserBrowser = BrowserInfo;
        IntranetHomeUtility.ScreenSize = screenSize;
    	IntranetHomeUtility.getUserSession.JobLevel = IntranetHomeUtility.getUserSession.JobLevelActual;*/
                                                             
        //Call Existing Method                                                              
        return recordClickUtilization(LINK_TYPE, displayName, itemId, scheduleId, containerId, rating, DeviceInfo, BrowserInfo, screenSize, userAgentInfo);
    }
    
    //Added By - Abhinav Sharma - 05/03/2015 - CR-20141020-7816 - Frequently Accessed Apps in the Hamburger
    //V_1.5 - Modified - 07/30/2015 - Rajeev Jain - CR-20150709-9072
    /**
    *   @description    :   This method will update the custom setting field values to keep the top 5 items link in sync and updated at Hamberger menu.
    * 
    *   @CreatedBy      :   Abhinav Sharma (05/03/2015)
    *
    *   @args           :   String LINK_TYPE, String displayName, String itemId, String scheduleId, String containerId, double rating,String itemClickLink, string iconStyle, string linkAction
    * 
    *   @return         :   String
    * 
    **/ 
    @RemoteAction
    global static String recentlyClickedLinkItems(String LINK_TYPE, String displayName, String itemId, String scheduleId, String containerId, double rating,String itemClickLink, string iconStyle, string linkAction){
      
        //Checking & validating for the paramters values
        if(String.isNotBlank(itemId) && String.isNotBlank(displayName) 
          && String.isNotBlank(containerId) && String.isNotBlank(scheduleId) 
            && String.isNotBlank(itemClickLink)) {
        
            //Custom Setting instance
            Top_5_Frequently_Accessed_Apps__c top5AccessAppSetting = Top_5_Frequently_Accessed_Apps__c.getValues(Userinfo.getUserId());
                
            //Checking custom setting for the null value
            if(top5AccessAppSetting != null) {
                
                //Integer to hold the existing duplicate item index value
                Integer j;
                
                //Check what Item Id is clicked
                if(top5AccessAppSetting.Recent_Intranet_Content_Item_1__c == itemId)
                	j = 0;
                else if(top5AccessAppSetting.Recent_Intranet_Content_Item_2__c == itemId)
                    j = 1;
                else if(top5AccessAppSetting.Recent_Intranet_Content_Item_3__c == itemId)
                    j = 2;
                else if(top5AccessAppSetting.Recent_Intranet_Content_Item_4__c == itemId)
                    j = 3;
                else if(top5AccessAppSetting.Recent_Intranet_Content_Item_5__c == itemId)
                    j = 4;
                
                //Loop through wrapper list size
                /*for(Integer i=0; i<wrapperList.size(); i++) {
                    if(wrapperList[i].itemIdValue == itemId)
                    j = i;
                }*/
                
                //Initializing the instance
                Top_5_Frequently_Accessed_Apps__c top5AccessAppSettingToUpdate = new Top_5_Frequently_Accessed_Apps__c(ID = top5AccessAppSetting.Id);
                
                //Populate instance with field values
                top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_1__c = itemId;
                
                if(j != null && j==0) {
                  
                    top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_2__c = top5AccessAppSetting.Recent_Intranet_Content_Item_2__c;  
                    top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_3__c = top5AccessAppSetting.Recent_Intranet_Content_Item_3__c;
                    top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_4__c = top5AccessAppSetting.Recent_Intranet_Content_Item_4__c;
                    top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_5__c = top5AccessAppSetting.Recent_Intranet_Content_Item_5__c;
                    
                
              } else if(j != null && j==1) {
                    
                  	//top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_2__c = wrapperList[0].itemIdValue;
                  	top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_2__c = top5AccessAppSetting.Recent_Intranet_Content_Item_1__c;
                    //top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_3__c = wrapperList[2].itemIdValue;
                    top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_3__c = top5AccessAppSetting.Recent_Intranet_Content_Item_3__c;
                    //top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_4__c = wrapperList[3].itemIdValue;
                    top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_4__c = top5AccessAppSetting.Recent_Intranet_Content_Item_4__c;
                    //top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_5__c = wrapperList[4].itemIdValue;
                    top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_5__c = top5AccessAppSetting.Recent_Intranet_Content_Item_5__c;
                    
                } else if(j != null && j==2) {
                    
                    //top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_2__c = wrapperList[0].itemIdValue;
                    top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_2__c = top5AccessAppSetting.Recent_Intranet_Content_Item_1__c;
                    //top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_3__c = wrapperList[1].itemIdValue;
                    top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_3__c = top5AccessAppSetting.Recent_Intranet_Content_Item_2__c;
                    //top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_4__c = wrapperList[3].itemIdValue;
                    top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_4__c = top5AccessAppSetting.Recent_Intranet_Content_Item_4__c;
                    //top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_5__c = wrapperList[4].itemIdValue;
                    top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_5__c = top5AccessAppSetting.Recent_Intranet_Content_Item_5__c;
                                    
                } else if(j != null && j==3) {
                  
                  	//top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_2__c = wrapperList[0].itemIdValue;
                  	top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_2__c = top5AccessAppSetting.Recent_Intranet_Content_Item_1__c;
                    //top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_3__c = wrapperList[1].itemIdValue;
                    top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_3__c = top5AccessAppSetting.Recent_Intranet_Content_Item_2__c;
                    //top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_4__c = wrapperList[2].itemIdValue;
                    top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_4__c = top5AccessAppSetting.Recent_Intranet_Content_Item_3__c;
                    //top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_5__c = wrapperList[4].itemIdValue;
                    top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_5__c = top5AccessAppSetting.Recent_Intranet_Content_Item_5__c;
                
                } else {
                    //top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_2__c = wrapperList[0].itemIdValue;
                    top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_2__c = top5AccessAppSetting.Recent_Intranet_Content_Item_1__c;
                    //top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_3__c = wrapperList[1].itemIdValue;
                    top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_3__c = top5AccessAppSetting.Recent_Intranet_Content_Item_2__c;
                    //top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_4__c = wrapperList[2].itemIdValue;
                    top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_4__c = top5AccessAppSetting.Recent_Intranet_Content_Item_3__c;
                    //top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_5__c = wrapperList[3].itemIdValue;
                    top5AccessAppSettingToUpdate.Recent_Intranet_Content_Item_5__c = top5AccessAppSetting.Recent_Intranet_Content_Item_4__c;
                }
               
                //Updating custom setting
                update top5AccessAppSettingToUpdate;
                
          } else {
            
                //Custom Setting instance
                Top_5_Frequently_Accessed_Apps__c top5AccessAppSettingToInsert = new Top_5_Frequently_Accessed_Apps__c();
                top5AccessAppSettingToInsert.SetupOwnerId = Userinfo.getUserId();
                top5AccessAppSettingToInsert.Recent_Intranet_Content_Item_1__c = itemId;
                
                insert top5AccessAppSettingToInsert;
      }
      }
        return IntranetUtilizationHelper.ClICK_TYPE_REMOTESUCCESS + LINK_TYPE;    
    }
    //V_1.5 - Modified - 07/30/2015 - Rajeev Jain - CR-20150709-9072 - upto here
    
}