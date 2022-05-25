/**
 *  Purpose         :   This class is to hold all the helper method for Intranet Item trigger.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   08/04/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.1 - Modified By - Abhinav Sharma - CR-20150219-8692 - 05/03/2015
 * 			V_1.2 - Modified By - Abhinav Sharma - CR-20140930-7520 - 07/16/2015
 * 			V_1.3 - Modified By - Rajeev Jain - CR-20150821-9176 - 08/21/2015 - Release 45 - HyperCare - Vimeo is not working production
 * 			V_1.4 - Modified By - Victor Hanson - Added Litmos support for Events
 *                      V_1.5 - Modified By - Dipesh Gupta - 05/29/2020 - CR-20200514-14042 - Update method getUpdatedMRSAndTRSIntranetItems.
 *
 **/ 
public without sharing class IntranetItemTriggerHelper {
    
    //Constants
    public final static String NAME_VALUES_SEPARATOR = ' - ';
    public final static String DATE_FORMAT_SEPARATOR = '-';
    public final static String KEYWORD_SETTING = 'Setting';
    public final static String KEYWORD_EVENT_ITEM = 'Event Item';
    public final static String KEYWORD_PERMALINK_CONTENT_VIEWER = 'ContentViewer';
    public final static String KEYWORD_PERMALINK_LINK_URL = 'Link_URL__c';
    public final static String CREATE_SOURCE_MRS = 'MRS';
    public final static String CREATE_SOURCE_TRS = 'TRS';
    public final static String CREATE_SOURCE_LITMOS = 'Litmos';
	    
    //This varibale to hold the Item Type and it's related folder name
    public final static Map<String, String> MAP_CONTENT_VIEWER = new Map<String, String> {
        
                                                                                            'news item' => 'news',
                                                                                            'member impact story' => 'initiative',
                                                                                            'job item' => 'feature job',
                                                                                            'talent item' => 'feature talent',
                                                                                            'trending - advisory.com' => 'trending advisory',
                                                                                            'trending - eab.com' => 'trending eab',
                                                                                            'poll item' => 'chatter poll'
                                                                                        };
    
    public final static Set<String> SET_LINK_BASED_PERMALINKS = new Set<String> {
                                                                                    'training event',
                                                                                    'member event',
                                                                                    'office event',
                                                                                    'video item',
                                                                                    'app link'
                                                                                };
    
    //Added By - Abhinav Sharma - CR-20140930-7520
    //Start FROM Here                                                                                
	public final static String RECORD_TYPE_INTRANET_ITEM_DEVELOPER_NAME_ITEM_VIDEO = 'Item_Video';
    public final static String youTubeimageURL = 'http://img.youtube.com/vi/';
    public final static String videoXmlURL_1 = 'https://vimeo.com/api/v2/video/';
    public final static String videoXmlURL_2 = '.xml';
    
    //V_1.3 - Modified By - Rajeev Jain - CR-20150821-9176 - 08/21/2015 - Release 45 - HyperCare - Vimeo is not working production
	public final static String videoXmlURL_3 = 'https://vimeo.com/api/oembed.xml?url=';
    public final static String vimeo_XML_Thumbnail_URL = 'thumbnail_url';
    
	//Flag to Say If trigger needs to bypass or not, if true trigger code will not run and if false trigger code will run
    public static Boolean isByPassIntranetItemTrigger = false; 
    //upto Here
    
    //Added By - Abhinav Sharma - CR-20150219-8692 - 05/03/2015 
    //Start from here                                                                              
     /**
     *   @description  :  This method is to check if URL is valid or not and update this accordingly.
     * 
     *   @args      :  List<Intranet_Item__c> intranetItems
     * 
     *   @return      :  void
     * 
     **/
    public static void validateAndFormatURL(List<Intranet_Item__c> intranetItems) {
        
        //Loop through intranet item records
        for(Intranet_Item__c ii : intranetItems) {
            
            //Checking for the null value
            if(ii.Link_URL__c == null) 
                ii.Link_URL_Validated__c = '';
            
            //Checking for the null value
            if(ii.Content_URL__c == null) 
                ii.Content_URL_Validated__c = '';
        	
            //Checking for the null value
            if(ii.Permalink__c == null) 
                ii.Permalink_Validated__c = '';
            
            //Checking for the null value
            if(ii.Secondary_Link_1_Location__c == null) 
                ii.Secondary_Link_1_Location_Validated__c = '';
            
            //check if   linkURL is not blank
            if(String.isNotBlank(ii.Link_URL__c)) {
                
                //variable to hold the Link URL value
                String linkURL = ii.Link_URL__c;
      
                // JS: Skip this for the relative links
                if(linkURL.startsWith('/')) {
                    ii.Link_URL_Validated__c = linkURL;
                } else {

                    //Check if link doesn't start with http or https, then update it
                    if(!linkURL.startsWithIgnoreCase(IntranetHomeUtility.HTTPS) && !linkURL.startsWithIgnoreCase(IntranetHomeUtility.HTTP)) {
                        
                        //Update Link URL and add HTTP link
                        if(linkURL.contains('//')) {
                            linkURL = linkURL.subString(linkURL.indexOf('//')+2, linkURL.length());
                            linkURL = IntranetHomeUtility.HTTP + linkURL;
                        } else
                            linkURL = IntranetHomeUtility.HTTP + linkURL;
                    }  
                    ii.Link_URL_Validated__c = linkURL;
                }       
            }
            
            //check if contentURL is not blank
            if(String.isNotBlank(ii.Content_URL__c)) {
                
                //variable to hold the Link URL value
                String contentURL = ii.Content_URL__c;
      
                // JS: Skip this for the relative links
                if(contentURL.startsWith('/')) {
                    ii.Content_URL_Validated__c = contentURL;
                } else {

                    //Check if link doesn't start with http or https, then update it
                    if(!contentURL.startsWithIgnoreCase(IntranetHomeUtility.HTTPS) && !contentURL.startsWithIgnoreCase(IntranetHomeUtility.HTTP)) {
                        
                        //Update Link URL and add HTTP link
                        if(contentURL.contains('//')) {
                            contentURL = contentURL.subString(contentURL.indexOf('//')+2, contentURL.length());
                            contentURL = IntranetHomeUtility.HTTP + contentURL;
                        } else
                            contentURL = IntranetHomeUtility.HTTP + contentURL;
                    }  
                    ii.Content_URL_Validated__c = contentURL;
                }       
            }
            
            //check if contentURL is not blank
            if(String.isNotBlank(ii.Permalink__c)) {
                
                //variable to hold the Link URL value
                String paramLinkURL = ii.Permalink__c;
      
                // JS: Skip this for the relative links
                if(paramLinkURL.startsWith('/')) {
                    ii.Permalink_Validated__c = paramLinkURL;
                } else {

                    //Check if link doesn't start with http or https, then update it
                    if(!paramLinkURL.startsWithIgnoreCase(IntranetHomeUtility.HTTPS) && !paramLinkURL.startsWithIgnoreCase(IntranetHomeUtility.HTTP)) {
                        
                        //Update Link URL and add HTTP link
                        if(paramLinkURL.contains('//')) {
                            paramLinkURL = paramLinkURL.subString(paramLinkURL.indexOf('//')+2, paramLinkURL.length());
                            paramLinkURL = IntranetHomeUtility.HTTP + paramLinkURL;
                        } else
                            paramLinkURL = IntranetHomeUtility.HTTP + paramLinkURL;
                    }  
                    ii.Permalink_Validated__c = paramLinkURL;
                }       
            }
            
            //check if contentURL is not blank
            if(String.isNotBlank(ii.Secondary_Link_1_Location__c)) {
                
                //variable to hold the Link URL value
                String secondaryLinkURL = ii.Secondary_Link_1_Location__c;
      
                // JS: Skip this for the relative links
                if(secondaryLinkURL.startsWith('/')) {
                    ii.Secondary_Link_1_Location_Validated__c = secondaryLinkURL;
                } else {

                    //Check if link doesn't start with http or https, then update it
                    if(!secondaryLinkURL.startsWithIgnoreCase(IntranetHomeUtility.HTTPS) && !secondaryLinkURL.startsWithIgnoreCase(IntranetHomeUtility.HTTP)) {
                        
                        //Update Link URL and add HTTP link
                        if(secondaryLinkURL.contains('//')) {
                            secondaryLinkURL = secondaryLinkURL.subString(secondaryLinkURL.indexOf('//')+2, secondaryLinkURL.length());
                            secondaryLinkURL = IntranetHomeUtility.HTTP + secondaryLinkURL;
                        } else
                            secondaryLinkURL = IntranetHomeUtility.HTTP + secondaryLinkURL;
                    }  
                    ii.Secondary_Link_1_Location_Validated__c = secondaryLinkURL;
                }       
            }
        }
    }  
    //Upto Here
                                                                                    
    /**
     *  @description    :   This method is being called on before events. It validates the record data and set it
                                #1: Intranet Container Name format:
                                    a.  For top level Containers (with no Parent Container): <Record Type>-Primary-<DisplayName>
                                    b.  For Child record Containers:  <Record Type>-<ParentContainerDisplayName>-<DisplayName>
     * 
     *  @args           :   List of new records
     * 
     *  @return         :   void
     * 
     **/
    public static void validateData(List<Intranet_Item__c> intranetItems) {
        
        //Record Type Map
        Map<Id, RecordType> mapRecordType = new Map<Id, RecordType>([Select Id, Name, DeveloperName from RecordType where SobjectType = 'Intranet_Item__c' AND IsActive = true]);
        
        //Loop through the records and set Name
        for(Intranet_Item__c iI : intranetItems) {
            
            //Record Type name
            String recordTypeDeveloperName = mapRecordType.get(iI.RecordTypeId).DeveloperName;
            
            //Items
            if(recordTypeDeveloperName.startsWithIgnoreCase('Item')) {
                
                //Item Title
                String itemTitle = 'Null';
                String iTemType = 'Null';
                
                //Truncate to 40 charcters if more than 40
                if(String.isNotBlank(iI.Item_Title__c)) {
                    
                    //Set Title
                    itemTitle = iI.Item_Title__c;
                    if(itemTitle.length() > 40)
                        itemTitle = itemTitle.left(40);
                }
                    
                //Truncate to 20 charcters if more than 20
                if(String.isNotBlank(iI.Item_Type__c)) {
                    
                    //Set Type
                    itemType = iI.Item_Type__c;
                    if(itemType.length() > 20)
                        itemType = itemType.left(20);
                }
                
                //Check for the Date
                DateTime createdDate = DateTime.now();
                if(iI.CreatedDate != null)
                    createdDate = iI.CreatedDate;
                
                //Name field
                iI.Name = itemTitle + IntranetItemTriggerHelper.NAME_VALUES_SEPARATOR 
                            + itemType + IntranetItemTriggerHelper.NAME_VALUES_SEPARATOR 
                            + createdDate.year() + IntranetItemTriggerHelper.DATE_FORMAT_SEPARATOR 
                            + ('0' + createdDate.month()).right(2) + IntranetItemTriggerHelper.DATE_FORMAT_SEPARATOR 
                            + ('0' + createdDate.day()).right(2);
            
            } else if(recordTypeDeveloperName.startsWithIgnoreCase('Settings')) {
                
                //String to hold the setting Name
                String settingName = 'Null';
                
                //Category
                if(recordTypeDeveloperName.containsIgnoreCase('Category') && String.isNotBlank(iI.Category_Name__c)) {
                    
                    settingName = iI.Category_Name__c;
                } else if(recordTypeDeveloperName.containsIgnoreCase('Color_Set') && String.isNotBlank(iI.Color_Set_Name__c)) {
                    
                    settingName = iI.Color_Set_Name__c;
                } else if(recordTypeDeveloperName.containsIgnoreCase('Image_Set') && String.isNotBlank(iI.Image_Set_Name__c)) {
                    
                    settingName = iI.Image_Set_Name__c;
                } else if(recordTypeDeveloperName.containsIgnoreCase('Office') && String.isNotBlank(iI.Office_Short_Name__c)) {
                    
                    settingName = iI.Office_Short_Name__c;
                }
                
                //Truncate to 40 characters if more than 40 charcters
                if(settingName.length() > 40)
                    settingName = settingName.left(40);
                
                //String itemType
                String itemType = 'Null';
                    
                //Truncate to 20 charcters if more than 20
                if(String.isNotBlank(iI.Item_Type__c)) {
                    
                    //Set Type
                    itemType = iI.Item_Type__c;
                    if(itemType.length() > 20)
                        itemType = itemType.left(20);
                }
                
                //Name
                iI.Name = settingName + IntranetItemTriggerHelper.NAME_VALUES_SEPARATOR
                            + itemType + IntranetItemTriggerHelper.NAME_VALUES_SEPARATOR
                            + IntranetItemTriggerHelper.KEYWORD_SETTING;
            }
            
            //Truncate to 80 CHaracters
            iI.Name = iI.Name.length() > 80 ? iI.Name.left(80) : iI.Name;
        }
    }
    
    /**
     *  @description    :   This methid is  to create the create the Topics and Assign the on Items records
     * 
     *  @args           :   List and Map of items
     * 
     *  @return         :   void
     *
     **/
    public static void createTopics(List<Intranet_Item__c> newIntranetItems, Map<Id, Intranet_Item__c> mapOldIntranetItems) {
        
        //Create a set to Hold the Main Categoty Ids
        Set<Id> mainCategories = new Set<Id>();
        
        //Loop through the new records
        for(Intranet_Item__c iI : newIntranetItems) {
            
            //Chekc for the Maon Category
            if(iI.Main_Category__c != null) {
                
                //Add in Set
                mainCategories.add(iI.Main_Category__c);
            }
        }
        
        //Loop through the old records
        if(mapOldIntranetItems != null) {
            
            //Loop through the records
            for(Intranet_Item__c iI : mapOldIntranetItems.values()) {
                
                //Chekc for the Maon Category
                if(iI.Main_Category__c != null) {
                    
                    //Add in Set
                    mainCategories.add(iI.Main_Category__c);
                }
            }
        }
        
        //Category Name
        Map<Id, Intranet_Item__c> mapNewIntranentItems = new Map<Id, Intranet_Item__c>([Select Id, Name, Category_Name__c from Intranet_Item__c where Id IN: mainCategories]);
        
        //Map to hold the Topic with Items
        Map<String, Set<Id>> mapTopics = new Map<String, Set<Id>>();
        Map<String, Set<Id>> mapOldTopics = new Map<String, Set<Id>>();
        
        //Loop through the items and create a set of Category
        for(Intranet_Item__c iI : newIntranetItems) {
            
            //Check for the Main Category
            if(newIntranetItems != null && iI.Main_Category__c != null
                && (mapOldIntranetItems == null || iI.Main_Category__c != mapOldIntranetItems.get(iI.Id).Main_Category__c) ) {
                
                //topicName
                String topicName = mapNewIntranentItems.get(iI.Main_Category__c).Category_Name__c;
                
                //Chekc in Map, if not exists, then add
                if(!mapTopics.containsKey(topicName)) {
                    
                    //Add in map
                    mapTopics.put(topicName, new Set<Id>());
                }
                    
                //Create a Set to Hold the Category Name and related Items Ids
                mapTopics.get(topicName).add(iI.Id);
            }
            
            //Old Item
            if(mapOldIntranetItems != null && iI.Main_Category__c != mapOldIntranetItems.get(iI.Id).Main_Category__c && mapOldIntranetItems.get(iI.Id).Main_Category__c != null) {
                
                //topicName
                String topicName = mapNewIntranentItems.get(mapOldIntranetItems.get(iI.Id).Main_Category__c).Category_Name__c;
                
                //Chekc in Map, if not exists, then add
                if(!mapOldTopics.containsKey(topicName)) {
                    
                    //Add in map
                    mapOldTopics.put(topicName, new Set<Id>());
                }
                
                //Create a Set to Hold the Category Name and related Items Ids
                mapOldTopics.get(topicName).add(iI.Id); 
            }
        }
        
        //Fetch all the Topic in System Already and Create a Map to hold it
        Map<String, Topic> mapTopicWithName = new Map<String, Topic>();
        Set<Id> topicIds = new Set<Id>();
        
        for(Topic t : [Select Id, Name from Topic where Name IN: mapTopics.keySet() OR Name IN: mapOldTopics.keySet()]) {
            
            //Add in map
            mapTopicWithName.put(t.Name, t);
            topicIds.add(t.Id);
        }
        
        //Check for the existing assignment
        Map<String, Id> existingTopicsAssignemnt = new Map<String, Id>();
        for(TopicAssignment tA : [Select EntityId, TopicId from TopicAssignment where EntityId IN: newIntranetItems AND TopiciD =: topicIds]) {
            
            //Add in Set
            existingTopicsAssignemnt.put(tA.TopicId + '-' + tA.EntityId, tA.Id);
        }
        
        //Topics to Add
        Map<String, Topic> topicsToAdd = new Map<String, Topic>();
        
        //Now loop through the items again and create the Topics and Assignment
        for(String topicName : mapTopics.keySet()) {
            
            //Topic Name already exists
            if(!mapTopicWithName.containsKey(topicName))
                topicsToAdd.put(topicName, new Topic(Name = topicName));
        }
        
        //Insert new Topics
        if(topicsToAdd.size() > 0)
            insert topicsToAdd.values();
        
        //Club topics all together
        mapTopicWithName.putAll(topicsToAdd);
        
        //Create a List of Topic Assignment to be added
        List<TopicAssignment> tAs = new List<TopicAssignment>();
        
        //Loop through  the initial list and check which records need topics created
        for(String topicName : mapTopics.keySet()) {
            
            //Items
            for(Id itemId : mapTopics.get(topicName)) {
                
                //Check if topic exists
                if(mapTopicWithName.containsKey(topicName)) {
                    
                    //Unique Assignment Key
                    String uniqueKey = mapTopicWithName.get(topicName).Id + '-' + itemId;
                    
                    //Only create the assignment record if not already exists
                    if(!existingTopicsAssignemnt.containskey(uniqueKey)) {
                        
                        //Add Assignment
                        tAs.add(new TopicAssignment(EntityId = itemId, TopicId = mapTopicWithName.get(topicName).Id));
                    }
                }
            }
        }
        
        //Delete list for tAs
        List<TopicAssignment> delTAs = new List<TopicAssignment>();
        
        //Loop through  the initial list and check which records need topics assignemnet deleted
        for(String topicName : mapOldTopics.keySet()) {
            
            //Items
            for(Id itemId : mapOldTopics.get(topicName)) {
                
                //Check if topic exists
                if(mapTopicWithName.containsKey(topicName)) {
                    
                    //Unique Assignment Key
                    String uniqueKey = mapTopicWithName.get(topicName).Id + '-' + itemId;
                    
                    //Only create the assignment record if not already exists
                    if(existingTopicsAssignemnt.containsKey(uniqueKey)) {
                        
                        //Add Assignment
                        delTAs.add(new TopicAssignment(Id = existingTopicsAssignemnt.get(uniqueKey)));
                    }
                }
            }
        }
        
        //Insert assignments
        if(tAs.size() > 0)
            insert tAs;
            
        //Delete Assignment
        if(delTAs.size() > 0)
            delete delTAs;
    }
    
    /**
     *  @description    :   This method is to stop deleting the Intranet_Item__c record which has Default_Content_Flag = true
     * 
     *  @args           :   List of Intranet_Item__c records to be deleted
     * 
     *  @return         :   void
     * 
     **/
    public static void validateBeforeDelete(List<Intranet_Item__c> intranetItems) {
        
        //Loop through the records and check if it has Default_Content_Flag = true,
        //If yes, then throw and error  and do not allow user to delete the records
        for(Intranet_Item__c intranetItem : intranetItems) {
            
            //Check for the flag
            if(intranetItem.Default_Content_Flag__c == true)
                throw new CustomException(Label.ERROR_DELETE_DEFAULT_CONTENT_FLAG_TRUE);
        }
    }
    
    /**
     *  @description    :   This method is to check the Permalink Type and populate the URL based on that
     * 
     *  @args           :   List of Intranet Items
     * 
     *  @return         :   void
     * 
     **/
    public static void populatePermaLink(List<Intranet_Item__c> intranetItems) {
    /*  
        //Get the Custom Setting 
        Map<String, Intranet_Defaults__c> intranetDefaults = Intranet_Defaults__c.getAll();
        
        //Describe Intranet Item object to tget the fields. This map will be used to check if Custom setting's Permalink field has a valid filed name or not
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Intranet_Item__c.fields.getMap();
        
        //Lopp through the records
        for(Intranet_Item__c intranetItem : intranetItems) {
            
            //Check for the Item Type
            if(String.isNotBlank(intranetItem.Item_Type__c)) {
                
                //String intranet Item Type
                String itemType = intranetItem.Item_Type__c.toLowerCase();
                
                //Variable to hold permaLink
                String permaLink;
                
                //Check if custom setting is defined for the same
                if(intranetDefaults.containsKey(intranetItem.Item_Type__c)) {
                    
                    //Get the Custom Setting record
                    Intranet_Defaults__c intranetDefault = intranetDefaults.get(intranetItem.Item_Type__c);
                    
                    //Check for the Permalink
                    if(String.isNotBlank(intranetDefault.Permalink__c)) {
                        
                        //Content Viewer
                        //And Check if there is folder defined for the same
                        if(intranetDefault.Permalink__c.equalsIgnoreCase(IntranetItemTriggerHelper.KEYWORD_PERMALINK_CONTENT_VIEWER)
                            && IntranetItemTriggerHelper.MAP_CONTENT_VIEWER.containsKey(itemType)
                            && String.isNotBlank(intranetItem.Item_Title__c)) {
                            
                            //Item title
                            String itemTitle = intranetItem.Item_Title__c;
                            itemTitle = itemTitle.replaceAll('[^A-Za-z0-9- .]','');
                            
                            //Generate URL
                            permaLink = '/cv'
                                        + '/' + IntranetItemTriggerHelper.MAP_CONTENT_VIEWER.get(itemType)
                                        + '/' + itemTitle + ' ' + Date.today().year() + ('0' + Date.today().month()).right(2) + ('0' + Date.today().day()).right(2);
                        } else if(IntranetItemTriggerHelper.SET_LINK_BASED_PERMALINKS.contains(itemType)) {
                            
                            //Check if the field is correct 
                            if(mapFields.containsKey(intranetDefault.Permalink__c)) {
                                    
                                //If its a LinkBased Permalink, populate Link URL to PermaLink 
                                permaLink = intranetItem.Link_URL__c;
                            }
                        }
                    }
                }
                
                //Check if permaLink is not null, set it on Intranet Item
                if(String.isNotBlank(permaLink)) {
                    
                    //Replace spaces with + sign
                    permaLink = permaLink.replaceAll(' ', '+'); 
                    intranetItem.Permalink__c = permaLink;
                }
            } 
        }
    */

        // JS: Now we switch away from URLRewrite, we will generate Permalink for all the item types with a valid ContentViewerView__c, except Page.
        for(Intranet_Item__c intranetItem : intranetItems) {
            String itemType = intranetItem.Item_Type__c;
            if(String.isBlank(itemType)) continue;

            Intranet_Defaults__c intranetDefault;
            if(!String.isBlank(intranetItem.Event_Type__c))
                intranetDefault = IntranetHomeUtility.LookupIntranetDefaultByName(intranetItem.Event_Type__c);
            if(intranetDefault == null)
                intranetDefault = IntranetHomeUtility.LookupIntranetDefault(itemType);
                
            if (intranetDefault != null && intranetDefault.SearchCategory__c != 'Exclude' && String.isNotBlank(intranetDefault.ContentViewerView__c)) {
                String newLink = null;
                if(intranetDefault.ContentViewerView__c == 'Link_URL__c') {
                    newLink = IntranetHomeUtility.validateAndFormatURL(intranetItem.Link_URL__c);
                } else if (intranetDefault.ContentViewerView__c.contains('mode=calendar')) {
                    if(intranetItem.Event_Start_Date_Time__c == null) {
                        newLink = '/apex/IntranetContentViewer?' + intranetDefault.ContentViewerView__c + '&SearchContentId=' +  
                            intranetItem.Id + '&SearchContentType=' + itemType + '&SearchStartDate=' + 
                            EncodingUtil.urlEncode(intranetItem.Event_Start_Date_Time__c.format('MM/dd/yyyy'), 'UTF-8');
                    } else {
                        newLink = '/apex/IntranetContentViewer?' + intranetDefault.ContentViewerView__c + '&SearchContentId=' +  
                            intranetItem.Id + '&SearchContentType=' + itemType;
                    }
                } else {
                    newLink = '/apex/IntranetContentViewer?' + intranetDefault.ContentViewerView__c + '&SearchContentId=' +
                        intranetItem.Id + '&SearchContentType=' +  itemType;
                }

                if(newLink != null && intranetItem.Permalink__c != newLink) intranetItem.Permalink__c = newLink;
            }
        }
    }

    // Since we do not get the Id before insert, can't update record after insert, we will have to force another update. 
    public static void forcePermaLinkUpdate(List<Intranet_Item__c> intranetItems) {
        List<Intranet_Item__c> forceUpdates = new List<Intranet_Item__c>();

        for(Intranet_Item__c intranetItem : intranetItems) {
            String itemType = intranetItem.Item_Type__c;
            if(String.isBlank(itemType)) continue;

            Intranet_Defaults__c intranetDefault;
            if(!String.isBlank(intranetItem.Event_Type__c))
                intranetDefault = IntranetHomeUtility.LookupIntranetDefaultByName(intranetItem.Event_Type__c);
            if(intranetDefault == null)
                intranetDefault = IntranetHomeUtility.LookupIntranetDefault(itemType);
                
            if (intranetDefault != null && intranetDefault.SearchCategory__c != 'Exclude' && String.isNotBlank(intranetDefault.ContentViewerView__c)) {
                Intranet_Item__c item = [SELECT Id FROM Intranet_Item__c WHERE Id = :intranetItem.Id];
                forceUpdates.add(item);
            }
        }

        if(forceUpdates.size() > 0) {
            update forceUpdates;
        }
    }
    
    /**
     *  @description    :   This method is to create the Intranet Schedule record for each Intranet_Item record
     *                          •   For each Intranet Item record, get the Custom Setting record where the Name matches the Item Type
                                    o   If CS.Item_Type = ‘Event Item’ and CS.ContentType is not blank, 
                                           If item.Event_Type is in the ContentType string, 
                                            •   Get the CS record where the Name matches the item.Event Type and use that
                                •   Active Status = CS.Active_Status__c
                                •   Approval Status = CS.Approval_Status__c
                                •   RecordTypeId = CS.Schedule_RecordTypeId__c
                                •   Intranet_Container = CS.Intranet_Container__c
                                     
     *
     *  @args           :   List of Intranet Items
     *
     *  @return         :   List of Intranet Schedule
     *
     **/
    public static List<Intranet_Schedule__c> CreateIntranetSchedulesByIntranetItems(List<Intranet_Item__c> intranetItems) {
        
        //
        List<Intranet_Schedule__c> intranetSchedules = new List<Intranet_Schedule__c>();
        
        //Get the Custim Setting
        Map<String, Intranet_Defaults__c> intranetDefaults = Intranet_Defaults__c.getAll();
        
        //Loop through the Intranet Items
        for(Intranet_Item__c intranetItem : intranetItems) {
            
            //Check for the Item Type
            if(String.isNotBlank(intranetItem.Item_Type__c)
                && String.isNotBlank(intranetItem.Event_Type__c)
               && (intranetItem.Item_Type__c == 'Training Event'
                  || intranetItem.Item_Type__c == 'Member Event')
               && intranetDefaults.containsKey(intranetItem.Item_Type__c)) {
                   
                   //Get the Custon Setting
                   Intranet_Defaults__c intranetDefault_ItemType = intranetDefaults.get(intranetItem.Item_Type__c);
                   
                //Check is it's an Event Type
                   if(String.isNotBlank(intranetDefault_ItemType.ContentTypes__c)
                      && intranetDefault_ItemType.ContentTypes__c.containsIgnoreCase(intranetItem.Event_Type__c)) 
                   {
                       system.debug('intranetItem***' + intranetItem);
                       
                       //Get the Custon Setting
                       Intranet_Defaults__c intranetDefault_EventType = intranetDefaults.get(intranetItem.Event_Type__c);
                       
                       //Create a new Schedule record
                       Intranet_Schedule__c intranetSchedule = new Intranet_Schedule__c();
                       intranetSchedule.Active_Status__c = intranetDefault_EventType.Active_Status__c;
                       intranetSchedule.Approval_Status__c = intranetDefault_EventType.Approval_Status__c;
                       intranetSchedule.RecordTypeId = intranetDefault_EventType.Schedule_RecordTypeId__c;
                       intranetSchedule.Intranet_Container__c = intranetDefault_EventType.Intranet_Container__c;
                       intranetSchedule.Intranet_Item__c = intranetItem.Id;
                       
                       //Add in list
                       intranetSchedules.add(intranetSchedule);
                   }
               }    
        }
        
        //Return Schedule   
        return intranetSchedules;
    }
    
    /**
     *  @description    :   This method is to Update the Intranet Item instance 
                                   If any of the records being inserted meets the criteria below, update the values on the Intranet Item records
                                    •   Member Events
                                        o   How to identify a new Member Event record:
                                               Create Source = ‘MRS’
                                        o   Fields values to update before the record is saved
                                               First, get the Custom Settings data
                                                •   Load Custom Setting ‘Intranet_Defaults__c’
                                                •   Find the record where the Create Source is ‘MRS’
                                                •   The values below that reference CS refer to the Custom Settings record
                                               Link_URL = CS.LinkBaseURL + the current value of Link_URL__c
                                               Active  Status = CS.Active_Status__c
                                               Approval Status = CS.Approval_Status__c
                                               RecordTypeId = CS.Item_RecordTypeId__c
                                               Event Type = CS.Event_Type__c
                                               Item type = CS.Item_Type__c
                                               Link Type = CS.Link_Type__c
                                               Link Action = CS.Link_Action__c
                                    •   Training Events
                                        o   How to identify a new Training Event record:
                                               Create Source = ‘TRS’
                                        o   Fields values to update before the record is saved
                                               First, get the Custom Settings data
                                                •   Load Custom Setting ‘Intranet_Defaults__c’
                                                •   Find the record where the Create Source is ‘TRS’
                                                •   The values below that reference CS refer to the Custom Settings record
                                               Link_URL = CS.LinkBaseURL + the current value of Link_URL__c
                                               Active  Status = CS.Active_Status__c
                                               Approval Status = CS.Approval_Status__c
                                               RecordTypeId = CS.Item_RecordTypeId__c
                                               Event Type = CS.Event_Type__c
                                               Item type = CS.Item_Type__c
                                               Link Type = CS.Link_Type__c
                                               Link Action = CS.Link_Action__c
        
     *
     *  @args   :   List of Intranet Items
     *
     *  @return :   List of updated intranet  Items
     *
     **/
    public static List<Intranet_Item__c> getUpdatedMRSAndTRSIntranetItems(List<Intranet_Item__c> intranetItems, Map<Id, Intranet_Item__c> oldItemsMap) {
        
        //Fetch custom setting data and Prepare MRS and TRS Map
        Map<String, Intranet_Defaults__c> mapIntranetDefaults = new Map<String, Intranet_Defaults__c>();
        for(Intranet_Defaults__c intranetDefault : Intranet_Defaults__c.getAll().values()) {
            
            //Check if it's a MRS or TRS, only then add in Map
            if(intranetDefault.Create_Source__c == IntranetItemTriggerHelper.CREATE_SOURCE_MRS
               || intranetDefault.Create_Source__c == IntranetItemTriggerHelper.CREATE_SOURCE_TRS
               || intranetDefault.Create_Source__c == IntranetItemTriggerHelper.CREATE_SOURCE_LITMOS) {
                
                //Put in Map
                mapIntranetDefaults.put(intranetDefault.Create_Source__c, intranetDefault); 
            }
        }
        
        //Loop through the Intranet Item records (Change in Condition - Modified By - Dipesh Gupta - 05/29/2020 - CR-20200514-14042 - Update apex class IntranetItemTriggerHelper)
        for(Intranet_Item__c intranetItem : intranetItems != null ? intranetItems : oldItemsMap.values()) {
            
            //Get Intranet Item (Change in Condition - Modified By - Dipesh Gupta - 05/29/2020 - CR-20200514-14042 - Update apex class to include additional check of create source field change)
            if((intranetItem.Create_Source__c == IntranetItemTriggerHelper.CREATE_SOURCE_MRS 
                || intranetItem.Create_Source__c == IntranetItemTriggerHelper.CREATE_SOURCE_TRS
                || intranetItem.Create_Source__c == IntranetItemTriggerHelper.CREATE_SOURCE_LITMOS)
                && mapIntranetDefaults.containsKey(intranetItem.Create_Source__c)
                && ( oldItemsMap == null || (oldItemsMap != null && oldItemsMap.get(intranetItem.Id).Create_Source__c != intranetItem.Create_Source__c))
                ) {
                
                //intranetDefaults
                Intranet_Defaults__c intranetDefault = mapIntranetDefaults.get(intranetItem.Create_Source__c);
                
                //Update intranet Item record
                intranetItem.Link_URL__c = intranetDefault.LinkBaseURL__c + intranetItem.Unique_Id__c;
                intranetItem.Active_Status__c = intranetDefault.Active_Status__c;
                intranetItem.Approval_Status__c = intranetDefault.Approval_Status__c;
                intranetItem.RecordTypeId = intranetDefault.Item_RecordTypeId__c;
                intranetItem.Event_Type__c = intranetDefault.Event_Type__c;
                intranetItem.Item_Type__c = intranetDefault.Item_Type__c;
                intranetItem.Link_Type__c = intranetDefault.Link_Type__c;
                intranetItem.Link_Action__c = intranetDefault.Link_Action__c;
            }
        }
        
        //Return intranetItems
        return intranetItems;
    }
    
    /**
     *  @description    :   Create the Intranet_Schedule records if the Intranet_Item records are not being manually created.  (Create_Source will be blank or match Label.Intranet_CreateSource_Default)
                                o   This function should run in the After Insert trigger
                                o   Call the function created above that will create the Intranet_Schedule records for the new Intranet Item records
                                o   Insert the Intranet_Schedule records
                                                                
     *  @args           :   List of intranet Items
     *
     *  @return         :   void
     *
     **/
    public static void createSchedulesForAutomatedItems(List<Intranet_Item__c> intranetItems) {
        
        //List of automated Intranet Items
        List<Intranet_Item__c> lstIntranetItems = new List<Intranet_Item__c>();
        
        //Loop through the records
        for(Intranet_Item__c intranetItem : intranetItems) {
            
            //Create_Source will be blank or match Label.Intranet_CreateSource_Default)
            if(String.isBlank(intranetItem.Create_Source__c) 
                || intranetItem.Create_Source__c != Label.Intranet_CreateSource_Default) {
                
                //Add in list
                lstIntranetItems.add(intranetItem); 
            }
        }
        
        //Chekc for the size and Call method to create Schedule records
        if(lstIntranetItems.size() > 0) {
            
            //Get related schedules
            List<Intranet_Schedule__c> schedules = IntranetItemTriggerHelper.CreateIntranetSchedulesByIntranetItems(intranetItems);
            
            if(schedules.size() > 0)
                insert schedules;
        }
    }
    
    //Added By - Abhinav Sharma - CR-20140930-7520
    //Start FROM Here
    /**
     *  @description    :   This to make Image Url from YouTube Video and Runs Before Insert and Before Update of the Item
     * 
     *  @args           :   List of New Intranet Items, List of Old Intranet Items
     * 
     *  @return         :   void
     * 
     **/
    public static void getYouTubeVideoImageUrl(List<Intranet_Item__c> newItems, Map<Id,Intranet_Item__c> oldItemsMap){
    	
         //Query on Record Type and Process Items only which Are video Items
        List<RecordType> recordTypes = [select Id, Name, DeveloperName from RecordType where DeveloperName = :RECORD_TYPE_INTRANET_ITEM_DEVELOPER_NAME_ITEM_VIDEO];
        
        //Query through Intranet Vimeo Item Custom Setting to get the youtube image format
        List<Intranet_Video_Item_Links__c> cS_youtubeImageFormat = [SELECT Id, Name, Value__c, Is_Enabled__c FROM Intranet_Video_Item_Links__c WHERE Is_Enabled__c = true AND Name Like 'YouTube_%'];
        
        //Loop over New Items
        for(Intranet_Item__c newItem : newItems){
            
            //Check for following condition
            if(newItem.RecordTypeId == recordTypes[0].Id && newItem.Link_URL__c != null 
               && !newItem.Link_URL__c.containsIgnoreCase('vimeo.com') && newItem.Link_URL__c.containsIgnoreCase('youtube.com')){
            	
                   //Get YouTube Url
                   String url = newItem.Link_URL__c;
                   String youTubeId = url.substring(url.lastIndexOf('/')+1,url.length());  
                   
                   
                   //Create Dynamic Image Url and store it
                   String imgUrl = IntranetItemTriggerHelper.youTubeimageURL + youTubeId + cS_youtubeImageFormat[0].Value__c;
                   
                   newItem.Video_Link_Image_Url__c = imgUrl;
               }else if(newItem.RecordTypeId == recordTypes[0].Id && newItem.Link_URL__c == null){
               		newItem.Video_Link_Image_Url__c = '';    
               }
        }

    }
    
    /**
     *  @description    :   This method is to Make Image url for Vimeo video and Runs After Insert and After Update of the Item
     * 
     *  @args           :   List of New Intranet Items, List of Old Intranet Items
     * 
     *  @return         :   void
     * 
     **/
    public static void getVimeoVideoImageURL(List<Intranet_Item__c> newItems, Map<Id,Intranet_Item__c> oldItemsMap){
        
        //Set to Hold Item Ids
        Set<Id> itemIds = new Set<Id>();
        
        //List of Set of Ids, here we are making two way list to make callout in multiple future method
        //Because Callout is applied on limit so we can not hit callout more then its limit, so we will call multiple time future method
        List<Set<Id>> itemListOfSet = new List<Set<Id>>();
        itemListOfSet.add(itemIds);
        
        //Query on Record Type and Process Items only which Are video Items
        List<RecordType> recordTypes = [select Id, Name, DeveloperName from RecordType where DeveloperName = :RECORD_TYPE_INTRANET_ITEM_DEVELOPER_NAME_ITEM_VIDEO];
        
        //Query through Intranet Vimeo Item Custom Setting to get the youtube image format
        List<Intranet_Video_Item_Links__c> cS_VimeoImageFormat = [SELECT Id, Name, Value__c, Is_Enabled__c FROM Intranet_Video_Item_Links__c WHERE Is_Enabled__c = true AND Name Like 'Vimeo_Thumbnail_%'];
                
        //Counter to track no of items has been added in the set, if set size is greater then Limit Callouts we reset set and counter
        //And add to the list that set
        Integer counter = 1;
        
        //Loop Over New Items
        for(Intranet_Item__c newItem : newItems){
            
            //Check if Link Url is not blank or Link Url Is updated and different from old one
            //Add Items Ids for only those items which contains only vimeo video not youtube video
            if(newItem.RecordTypeId == recordTypes[0].Id && newItem.Link_URL__c != null 
               && (oldItemsMap == null || oldItemsMap.get(newItem.Id).Link_URL__c != newItem.Link_URL__c)
               && newItem.Link_URL__c.containsIgnoreCase('vimeo.com') && !newItem.Link_URL__c.containsIgnoreCase('youtube.com')){
                
                   //Variable to hold the size of list of set
                   Integer index = itemListOfSet.size();
                   
                   //Check for callout overflow 
                   if(counter < Limits.getLimitCallouts()){
                       
                       //Get current Item ids set
                       itemIds = itemListOfSet.get(index-1);
                       
                       //Populate set
                       itemIds.add(newItem.Id);
                       
                       //Populate list
                       itemListOfSet.set(index-1,itemIds );
                       counter++;
                       
                   }else{
                       //Reinitialise the set
                       itemIds = new Set<Id>();
                       
                       //Populate the set
                       itemIds.add(newItem.Id);
                       
                       //Populate the list
                       itemListOfSet.add(itemIds);
                       
                       //Reset the counter
                       counter = 1;
                   }
                 
            }
        }
        
        //Call future method from here
        if(itemListOfSet.size() > 0){
        	
            for(Integer i=0;i<itemListOfSet.size();i++){
            	
                if(itemListOfSet[i].size() > 0)
                	updateVideoImageUrl(itemListOfSet[i], cS_VimeoImageFormat[0].Value__c);
            }
        }
    }
	/**
     *  @description    :   Future Method to hit the API and update the link of the Vimeo and get Xml
     * 						Parse XMl to get Image URl for Vimeo video link
     * 						//V_1.3 - Modified By - Rajeev Jain - CR-20150821-9176 - 08/21/2015 - Release 45 - HyperCare - Vimeo is not working production
     * 
     *  @args           :   List of New Intranet Items, List of Old Intranet Items, vimeo image format
     * 
     *  @return         :   void
     * 
     **/
    @future(callout=true)
    public static void updateVideoImageUrl(Set<Id> itemIds , String vimeoImageFormat){
    	
        //V_1.3 - Modified By - Rajeev Jain - CR-20150821-9176 - 08/21/2015 - Release 45 - HyperCare - Vimeo is not working production
         //List to Hold Items
        List<Intranet_Item__c> itemList = new List<Intranet_Item__c>();
        
        //Loop over Item List and Extract its Url
        for(Intranet_Item__c itemData : [select Id, Name, Link_URL__c, Video_Link_Image_Url__c from Intranet_Item__c where Id IN :itemIds]){
            
            Http h = new Http();
	    	HttpRequest req = new HttpRequest();
            
            String videoXmlURL = IntranetItemTriggerHelper.videoXmlURL_3 + itemData.Link_URL__c;
            
            // url that returns the XML in the response body
	    	req.setEndpoint(videoXmlURL);
	    	req.setMethod('GET');
	    	HttpResponse res = h.send(req);
	    	Dom.Document doc = res.getBodyDocument();
	    
	    	//Retrieve the root element for this document.
	    	Dom.XMLNode rootNode = doc.getRootElement();
            String smallThumbnail = rootNode.getChildElement(IntranetItemTriggerHelper.vimeo_XML_Thumbnail_URL,null).getText();
            itemData.Video_Link_Image_Url__c = smallThumbnail;
            itemList.add(itemData);
        }
		
        //Set Flag to Bypass Intranet Item Trigger to Prevent to Run on the Next time
        IntranetItemTriggerHelper.isByPassIntranetItemTrigger = true;
        
        update itemList;
        //V_1.3 - Modified By - Rajeev Jain - CR-20150821-9176 - 08/21/2015 - Release 45 - HyperCare - Vimeo is not working production
        //Upto Here
    }
    //Added By - Abhinav Sharma - CR-20140930-7520 Upto Here
}