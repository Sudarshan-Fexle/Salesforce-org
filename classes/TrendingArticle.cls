//V_1.1 - Modified By Dipesh Gupta - 11/15/2017 - Issue--CR11730--QA--00007444 updated method UpsertIntranetItemsAndSchedules to populate the Entity Field for intranet items.
global with sharing class TrendingArticle {
    
    public String Link_Location{get;set;}                //URL for the article.  Also serves as the Unique Id
    public String Source{get;set;}                       //Advisory.com, EAB.com, etc.
    public DateTime WS1RequestTime{get;set;}             //Date & Time of when the request was made to the first web service
    public DateTime WS1ResponseTime{get;set;}            //Date & Time of when the response is received from the first web service
    public String WS1RequestMessage{get;set;}            //Request message sent to the first web service
    public String WS1ResponseMessage{get;set;}           //Response message received from first web service
    public DateTime WS2RequestTime{get;set;}             //Date & Time of when the request was made to the second web service
    public DateTime WS2ResponseTime{get;set;}            //Date & Time of when the response is received from the second web service
    public String WS2RequestMessage{get;set;}            //Request message sent to the second web service
    public String WS2ResponseMessage{get;set;}           //Response message received from second web service
    public String Trend_Type{get;set;}                   //Type of Trending being checked – values of Trend1, Trend2, and Trend3 from IntranetSettings Custom Setting
    public String Article_Title{get;set;}                //Title of the article that is trending 
    public String Article_Subtitle{get;set;}             //Subtitle of the article that is trending
    public DateTime Article_Publish_Date{get;set;}       //Date & Time the article was published
    public String Article_Author{get;set;}               //Author of the article
    public String Article_Type{get;set;}                 //Blog Post, Daily Briefing, etc
    public Integer View_Count{get;set;}                  //Number of Views
    public Integer Visit_Count{get;set;}                 //Number of Visits or Downloads
    public Integer Download_Count{get;set;}              //Number of Visits or Downloads
    public Static String TREND_SOURCE{get; set;}		 //Trend Source
    public Double Sort_Order {get; set;}		 		//Sort Order
    
    /**
     *  @description    :   This method is to get the list of trending article.
     * 
     *  @args           :   Trending Source
     * 
     *  @return         :   List of Trending Article
     * 
     **/
    public static List<TrendingArticle> GetTrendingArticlesByTrendSource(String trendSource)  {
        
        //List of Trending Article
        List<TrendingArticle> trendingArticles = new List<TrendingArticle>();
        
        //Get Trending Intranet Setting
        Map<String, Intranet_Defaults__c> mapTrendingIntranetDefaults = Intranet_Defaults__c.getAll();
        
        //Intranet_Defaults__c Record
        Intranet_Defaults__c intranetDefault;
        
        //Check for the trendSource
        if((trendSource == TrendingArticleConstants.TRENDING_ADVISORY_DOT_COM || trendSource == TrendingArticleConstants.TRENDING_EAB_DOT_COM)
            && mapTrendingIntranetDefaults.containsKey(trendSource)) {
            
            //Get Content Types
            intranetDefault = mapTrendingIntranetDefaults.get(trendSource);
            
            //Chekc for the properties
            if(intranetDefault.SettingType__c == TrendingArticleConstants.SETTING_TYPE_ITEM_TYPE 
                && String.isNotBlank(intranetDefault.ContentTypes__c)) {
                
                //Split Content Types
                List<String> contentTypes = intranetDefault.ContentTypes__c.split(';');
                
                //Loop through the content types
                for(String contentType : contentTypes) {
                    
                    //Get Trend1
                    if(mapTrendingIntranetDefaults.containsKey(contentType) 
                        && mapTrendingIntranetDefaults.get(contentType).Category__c == TrendingArticleConstants.CATEGORY_TRENDING) {
                        
                        //Set Trend Source    
                        TREND_SOURCE = mapTrendingIntranetDefaults.get(contentType).Create_Source__c;
                        
						//Call helper method and get the updated list TrendingArticles
                        trendingArticles = TrendingArticleHelper.GetUpdatedTrendingArticleList(trendingArticles, mapTrendingIntranetDefaults, contentType);
                    }
                }
            }
        }
        System.debug('$##$#$$$'+trendingArticles);
        return trendingArticles;
    }
     
    /**
     *  @description    :   This method is to get the list of update Treding articles after the Second Callout (GetItemDetails)
     * 
     *  @args           :   Trending Articles list
     * 
     *  @return         :   List of Trending Article (Updated with Second Webservice Parameters)
     * 
     **/
    public static List<TrendingArticle> GetUpdatedTrendingArticlesByTrendingArticles(List<TrendingArticle> trendingArticles)  {
        
        //Get Trending Intranet Setting
        Map<String, Intranet_Settings__c> mapTrendingIntranetDefaults = Intranet_Settings__c.getAll();
        
        system.debug('$##$#$$$'+trendingArticles);
     
        //Call Helper class method to update the instance of TrendingArticle
        return TrendingArticleHelper.GetUpdatedTrendingArticleList(trendingArticles, mapTrendingIntranetDefaults);
        
    }
     
    /**
     *  @description    :   This method is to loop through the trending item lists and insert/update the Item amd Schedule records
     * 
     *  @args           :   List of TrendingArticles
     * 
     *  @return         :   isSuccess
     * 
     *  @Version        :  V1.1 - Created
     * 					   V1.2 - Modified By Dipesh Gupta - 11/15/2017 - Issue--CR11730--QA--00007444 
     * 
     **/
    public static Boolean UpsertIntranetItemsAndSchedules(List<TrendingArticle> trendingArticles, String trendName) {
        
		//Check for the trendingArticles
        if(trendingArticles == null || trendingArticles.size() == 0)
            return true;
        
        //Trending Container Id
        //List<Intranet_Defaults__c> defaults = IntranetHomeUtility.getIntranetDefaultByCategoryAndSource(TrendingArticleConstants.INTRANET_DEFAULTS_CATEGORY_TRENDING, TrendingArticle.TREND_SOURCE);
        List<Intranet_Defaults__c> defaults = IntranetHomeUtility.getIntranetDefaultByCategoryAndSource(TrendingArticleConstants.INTRANET_DEFAULTS_CATEGORY_TRENDING, trendName);

        //Check for the size and do not do anything if not records in list
        if(defaults.size() == 0)
            return true;
        
        //Loop through the TrendingArticles and create a set on UniqueIds
        Set<String> uniqueIds = new Set<String>();
        
        //Looping Trending artiles
        for(TrendingArticle tA : trendingArticles) {
            
            //Check for valid value
            if(String.isNotBlank(tA.Link_Location)) {
                
                //Truncate it to 100 charcters as Unique Id field can only have 100 characters
                String uniqueId = tA.Link_Location;
                if(uniqueId.startsWith('{'))
                    uniqueId = uniqueId.subString(1, uniqueId.length());
                if(uniqueId.endsWith('}'))
                    uniqueId = uniqueId.subString(0, uniqueId.length() - 1);
                uniqueId =  uniqueId + tA.Trend_Type;
                uniqueId = uniqueId.length() > 100 ? uniqueId.right(100) : uniqueId;
                
                //Add in Set
                System.debug('uniqueId:::::'+ uniqueId);
                uniqueIds.add(uniqueId);
            }
        }
        
        //Create a Set of Intranet Item Ids
        Set<Id> intranetItemIds = new Set<Id>();
        Map<String, Intranet_Item__c> mapIntranetItemWithUniqueIds = new Map<String, Intranet_Item__c>();
        
        //Query Intranet Items and create a map with Unique Ids
        for(Intranet_Item__c intranetItem : [Select Id, Unique_Id__c from Intranet_Item__c where Unique_Id__c != null AND Unique_Id__c IN: uniqueIds]) {
            
            //Populate IntranetItem here
            intranetItemIds.add(intranetItem.Id);
            
            //Populate Map
            mapIntranetItemWithUniqueIds.put(intranetItem.Unique_Id__c, intranetItem);  
        }
        
        //Set to hold Intrnet Item Ids
        Map<Id, List<Intranet_Schedule__c>> mapIntranetItemWithSchedule = new Map<Id, List<Intranet_Schedule__c>>();
        
        //Get all the related schedule with Imtranet Container ids
        for(Intranet_Schedule__c iS : [Select Id, Intranet_Item__c, Entity__c from Intranet_Schedule__c where Intranet_Item__c != null 
                                                AND Intranet_Item__c =: intranetItemIds
                                                AND Intranet_Container__c =: defaults[0].Intranet_Container__c]) {
            
            //Check if map already contains this schedule, the add in existing, else put a new
            if(mapIntranetItemWithSchedule.containsKey(iS.Intranet_Item__c))
                mapIntranetItemWithSchedule.get(iS.Intranet_Item__c).add(iS);
            else
                mapIntranetItemWithSchedule.put(iS.Intranet_Item__c, new List<Intranet_Schedule__c>{iS});
        }
        
        //List of Items to be inserted/updated
        List<Intranet_Item__c> intranetItems = new List<Intranet_Item__c>();
        
        //List of Schedules to be inserted
        List<Intranet_Schedule__c> intranetSchedules = new List<Intranet_Schedule__c>();
                
        //Loop through the TrendingArticles and Create the Items and Schedule records
        for(TrendingArticle tA : trendingArticles) {
            
            //Create/Update an Intranet Item
            //Check for the LinkLocation
            if(String.isNotBlank(tA.Link_Location)) {
                
                //Check if Item already exists
                Intranet_Item__c intranetItem = new Intranet_Item__c();
                intranetItem.Unique_Id__c = tA.Link_Location;
                if(intranetItem.Unique_Id__c.startsWith('{'))
                    intranetItem.Unique_Id__c = intranetItem.Unique_Id__c.subString(1, intranetItem.Unique_Id__c.length());
                if(intranetItem.Unique_Id__c.endsWith('}'))
                    intranetItem.Unique_Id__c = intranetItem.Unique_Id__c.subString(0, intranetItem.Unique_Id__c.length() - 1);
                intranetItem.Unique_Id__c = intranetItem.Unique_Id__c + tA.Trend_Type;
                intranetItem.Unique_Id__c = intranetItem.Unique_Id__c.length() > 100 ? intranetItem.Unique_Id__c.right(100) : intranetItem.Unique_Id__c;
                System.debug('intranetItem.Unique_Id__c:::::'+ intranetItem.Unique_Id__c);
				
                //Check if Item already exists
                if(mapIntranetItemWithUniqueIds.containsKey(intranetItem.Unique_Id__c))
                    intranetItem =  mapIntranetItemWithUniqueIds.get(intranetItem.Unique_Id__c);
                    
                //Populate data
                intranetItem.RecordTypeId = defaults[0].Item_RecordTypeId__c;
                intranetItem.Active_Status__c = defaults[0].Active_Status__c;
                intranetItem.Approval_Status__c = defaults[0].Approval_Status__c;
                intranetItem.Item_SubTitle__c = tA.Article_Subtitle;
                intranetItem.Item_Title__c = tA.Article_Title;
                intranetItem.Item_Type__c = defaults[0].Item_Type__c;
                intranetItem.Link_Action__c = defaults[0].Link_Action__c;
                intranetItem.Link_URL__c = tA.Link_Location;
                intranetItem.Link_Type__c = defaults[0].Link_Type__c;
                intranetItem.Trending_View_Count__c = tA.View_Count;
                intranetItem.Trending_Visit_Count__c = tA.Visit_Count;
                if(tA.View_Count == null && tA.Download_Count != null)
                    intranetItem.Trending_View_Count__c = tA.Download_Count;
                intranetItem.Trend_Type__c = tA.Trend_Type;
                intranetItem.Article_Type__c = tA.Article_Type;
                intranetItem.Content_Author_Speaker__c = tA.Article_Author;
                intranetItem.Content_Publish_Date__c = tA.Article_Publish_Date != null ? tA.Article_Publish_Date.date(): null;
                intranetItem.Article_Publish_Date__c = tA.Article_Publish_Date != null ? tA.Article_Publish_Date.date(): null;
                intranetItem.Last_Content_Update__c = DateTime.now();
                intranetItem.Sort_Order__c = tA.Sort_Order;
                
                //Modified By Dipesh Gupta - 11/15/2017 - Issue--CR11730--QA--00007444 - to update the Entity of intranet Items - Start here.
                if(trendName == TrendingArticleConstants.TRENDING_ADVISORY_DOT_COM)
                	intranetItem.Entity__c = TrendingArticleConstants.HC_USER;
                
                if(trendName == TrendingArticleConstants.TRENDING_EAB_DOT_COM)
                	intranetItem.Entity__c = TrendingArticleConstants.EAB_USER;
               
                //Modified By Dipesh Gupta - 11/15/2017 - Issue--CR11730--QA--00007444 - to update the Entity of intranet Items - Ends here.
                
                //Title doesn't come in case of download, so set the Link Location as title
                if(String.isBlank(intranetItem.Item_Title__c)) {
                	
                    //Set Title
                    intranetItem.Item_Title__c = intranetItem.Link_URL__c;
                    if(intranetItem.Item_Title__c.contains('/') && intranetItem.Item_Title__c.contains('.'))
                        intranetItem.Item_Title__c = intranetItem.Item_Title__c.subString(intranetItem.Item_Title__c.lastIndexOf('/')+1, intranetItem.Item_Title__c.lastIndexOf('.'));
                }
                
                //Add in list
                intranetItems.add(intranetItem);
            }
        }
        
        //Upsert
        upsert intranetItems;
        
        //Create/Update an Intranet Schedule
        //Loop through the intranetItems
        for(Intranet_Item__c intranetitem : intranetItems) {
            
            //Intranet Schedule
            Intranet_Schedule__c intranetSchedule = new Intranet_Schedule__c();
            
            //Check if Intranet Schedule record already exists
            if(mapIntranetItemWithSchedule.containsKey(intranetitem.Id)) {
                
                //Loop through the list of schedules and update all accordingly
                for(Intranet_Schedule__c iS : mapIntranetItemWithSchedule.get(intranetitem.Id)){
                    
                    //Set data
                    iS.Active_Status__c = defaults[0].Active_Status__c;
                    iS.Approval_Status__c = defaults[0].Approval_Status__c;
                    iS.Intranet_Container__c = defaults[0].Intranet_Container__c;
                    iS.RecordTypeId = defaults[0].Schedule_recordTypeId__c;
                    iS.Entity__c = intranetitem.Entity__c;
                    
                    //Add in list
                    intranetSchedules.add(iS);
                }
            } else {
              
                intranetSchedule.Active_Status__c = defaults[0].Active_Status__c;
                intranetSchedule.Approval_Status__c = defaults[0].Approval_Status__c;
                intranetSchedule.Intranet_Container__c = defaults[0].Intranet_Container__c;
                intranetSchedule.Intranet_Item__c = intranetitem.Id;
                intranetSchedule.RecordTypeId = defaults[0].Schedule_recordTypeId__c;
                intranetSchedule.Entity__c = intranetitem.Entity__c;
                
                //Add in list
                intranetSchedules.add(intranetSchedule);
            }
        }
        
        //Upsert 
        upsert intranetSchedules;
        
        return true;
    }
    
    /**
     * 
     * 
     * 
     * 
     * 
     **/
    public List<TrendingArticle> AdvisoryArticles {
    
        get {
            //Call GetTrends Methods and create a  list of Trending Articles
            //List<TrendingArticle> trendingArticles = TrendingArticle.GetTrendingArticlesByTrendSource('Trending - Advisory.com');
            
            //Get Each Item details using GetItemDetails callout
            //trendingArticles = TrendingArticle.GetUpdatedTrendingArticlesByTrendingArticles(trendingArticles);
            return new List<TrendingArticle>();
        }
    } 
   
     public List<TrendingArticle> EABArticles {
    
        get {
            //Call GetTrends Methods and create a  list of Trending Articles
            //List<TrendingArticle> trendingArticles = TrendingArticle.GetTrendingArticlesByTrendSource('Trending - EAB.com');
            
            //Get Each Item details using GetItemDetails callout
            //trendingArticles = TrendingArticle.GetUpdatedTrendingArticlesByTrendingArticles(trendingArticles);
            return new List<TrendingArticle>();//trendingArticles;
        }
    } 
    
    
    /**
     *  @description    :   This future method is to fetch the Trends details and create Items and Schedules records 
     * 
     *  @args           :   Trend Source
     * 
     *  @return         :   void
     * 
     **/
    @future(callout = true)
    webservice static void CreateIntranetItemsAndScheduleByTrendSource(String trendSource) {
        
        //Added By - Mahendra Swarnkar - 11/11/2017 - CR-20171019-11730
		if(String.isNotBlank(trendSource))
        	TrendingArticleHelper.IntranetContainerContentType = trendSource;
        
        //Call GetTrends Methods and create a  list of Trending Articles
        List<TrendingArticle> trendingArticles = TrendingArticle.GetTrendingArticlesByTrendSource(trendSource);
        
        //Get Each Item details using GetItemDetails callout
        trendingArticles = TrendingArticle.GetUpdatedTrendingArticlesByTrendingArticles(trendingArticles);
        
        //Create Item and Schedules records
        Boolean isSuccess = TrendingArticle.UpsertIntranetItemsAndSchedules(trendingArticles, trendSource);
    }
    
    /**
     *  @description    :   This method is to take the Trandsource name and return the list of Contaciner Ids
     * 
     *  @args           :   trendSourceName
     * 
     *  @return         :   IntranetContainer Ids
     * 
     **/
    public static Set<Id> GetTrendingContainerIds(String trendSource) {
        
        //Set Container Ids
        Set<Id> containerIds = new Set<Id>();
        
        //Get Trending Intranet Setting
        Map<String, Intranet_Defaults__c> mapTrendingIntranetDefaults = Intranet_Defaults__c.getAll();
        
        //Intranet_Defaults__c Record
        Intranet_Defaults__c intranetDefault;
        
        //Check for the trendSource
        if((trendSource == TrendingArticleConstants.TRENDING_ADVISORY_DOT_COM || trendSource == TrendingArticleConstants.TRENDING_EAB_DOT_COM)
            && mapTrendingIntranetDefaults.containsKey(trendSource)) {
            
            //Get Content Types
            intranetDefault = mapTrendingIntranetDefaults.get(trendSource);
            
            //Chekc for the properties
            if(intranetDefault.SettingType__c == TrendingArticleConstants.SETTING_TYPE_ITEM_TYPE 
                && String.isNotBlank(intranetDefault.ContentTypes__c)) {
                
                //Split Content Types
                List<String> contentTypes = intranetDefault.ContentTypes__c.split(';');
                
                //Loop through the content types
                for(String contentType : contentTypes) {
                    
                    //Get Trend1
                    if(mapTrendingIntranetDefaults.containsKey(contentType) 
                        && mapTrendingIntranetDefaults.get(contentType).Category__c == TrendingArticleConstants.CATEGORY_TRENDING
                        && mapTrendingIntranetDefaults.get(contentType).Intranet_Container__c != null) {
                        
                        //Call helper method and get the updated list TrendingArticles
                        containerIds.add(mapTrendingIntranetDefaults.get(contentType).Intranet_Container__c);
                    }
                }
            }
        }
        
        //return 
        return containerIds;
    }
}