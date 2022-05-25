/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.   
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test    
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
/** Description     :   Test class for TrendingArticals.
  * 
  * Created Date    :   08/27/2014
  *
  * Created By      :   
  *  
  * Current vision  :   v1.0    
  *  
  * Revision Logs   :   v1.0 - Created
  * 					v1.1 - Modified By - Abhinav Sharma - 05/24/2016 - CR-20160506-9837\
  * 					V_1.2 - Modified By - Dipesh Gupta - 11/06/2017 - CR-20171019-11730 - Added Intranet_Settings__c Custom setting Data 	
  *
  * Coverage        :   94%
  **/    
@isTest(seeAllData= false)
public class Test_TrendingArticles {
	
	//Setup
	static void setUpIntranetSettings() {
		
		//List of IntranetSetting Records
        List<Intranet_Settings__c> listInttranetSettings = new List<Intranet_Settings__c>();
        
        listInttranetSettings.add(new Intranet_Settings__c(Name = TrendingArticleConstants.WEBTRENDS_USER,
                                                              Value__c = 'advisory_board\\webdev'));
        listInttranetSettings.add(new Intranet_Settings__c(Name = TrendingArticleConstants.WEBTRENDS_PW,
                                                              Value__c = 'Advisory123!'));
        
        listInttranetSettings.add(new Intranet_Settings__c(Name = TrendingArticleConstants.WebTrendsEAB_User,
                                                              Value__c = 'Advisory1234!'));
        
        listInttranetSettings.add(new Intranet_Settings__c(Name = TrendingArticleConstants.WebTrendsEAB_PW,
                                                              Value__c = 'Advisory1234!'));
        
        insert listInttranetSettings;
    }
    
    //setUp Defaults
    static List<Intranet_Defaults__c> setUpIntranetDefaults() {
    	
    	//Intranet Defaults
    	//List of IntranetDefaultsRecords
        List<Intranet_Defaults__c> listIntranetDefaults = new List<Intranet_Defaults__c>();
        
    	listIntranetDefaults.add(new Intranet_Defaults__c(Name = TrendingArticleConstants.TRENDING_ADVISORY_DOT_COM, 
                                                             Category__c = TrendingArticleConstants.CATEGORY_TRENDING,
                                                             Create_Source__c = 'Advisory.com',
                                                             TrendType__c = 'Most Popular Last 24 Hours',
                                                             LinkBaseURL__c = 'https://ws.webtrends.com/v3/Reporting/profiles/27910/reports/18d039ae036/?totals=all&start_period=current_hour-24&end_period=current_hour&period_type=agg&format=xml&range=1',
                                                         	 SettingType__c = TrendingArticleConstants.SETTING_TYPE_ITEM_TYPE,
                                                         	 ContentTypes__c = TrendingArticleConstants.WEBTRENDS_ADV_DOT_COM_TREND1 + ';' + TrendingArticleConstants.WEBTRENDS_ADV_DOT_COM_TREND2 + ';' + TrendingArticleConstants.WEBTRENDS_ADV_DOT_COM_TREND3));
		
        listIntranetDefaults.add(new Intranet_Defaults__c(Name = TrendingArticleConstants.WEBTRENDS_ADV_DOT_COM_TREND1, 
                                                             Category__c = TrendingArticleConstants.CATEGORY_TRENDING,
                                                             Create_Source__c = 'Advisory.com',
                                                             TrendType__c = 'Most Popular Last 24 Hours',
                                                          	 Intranet_Container__c = UserInfo.getUserId(),
                                                             LinkBaseURL__c = 'https://ws.webtrends.com/v3/Reporting/profiles/27910/reports/18d039ae036/?totals=all&start_period=current_hour-24&end_period=current_hour&period_type=agg&format=xml&range=1'));
        
        listIntranetDefaults.add(new Intranet_Defaults__c(Name = TrendingArticleConstants.WEBTRENDS_ADV_DOT_COM_TREND2, 
                                                             Category__c = TrendingArticleConstants.CATEGORY_TRENDING,
                                                             Create_Source__c = 'Advisory.com',
                                                             TrendType__c = 'Most Popular Last 7 Days',
                                                          	 Intranet_Container__c = UserInfo.getUserId(),
                                                             LinkBaseURL__c = 'https://ws.webtrends.com/v3/Reporting/profiles/27910/reports/18d039ae036/?totals=all&start_period=current_day-7&end_period=current_day&period_type=agg&format=xml&range=1'));
        
        listIntranetDefaults.add(new Intranet_Defaults__c(Name = TrendingArticleConstants.WEBTRENDS_ADV_DOT_COM_TREND3, 
                                                             Category__c = TrendingArticleConstants.CATEGORY_TRENDING,
                                                             TrendType__c = 'Most Downloaded Last 7 Days',
                                                             Create_Source__c = 'Advisory.com',
                                                          	 Intranet_Container__c = UserInfo.getUserId(),
                                                             LinkBaseURL__c = 'https://ws.webtrends.com/v3/Reporting/profiles/27910/reports/ElUxi2T7MM6/?totals=all&start_period=current_day-7&end_period=current_day&period_type=agg&format=xml&range=1'));
        
        listIntranetDefaults.add(new Intranet_Defaults__c(Name = TrendingArticleConstants.TRENDING_EAB_DOT_COM, 
                                                             Category__c = TrendingArticleConstants.CATEGORY_TRENDING,
                                                             Create_Source__c = 'EAB.com',
                                                             TrendType__c = 'Most Popular Last 24 Hours',
                                                             LinkBaseURL__c = 'https://ws.webtrends.com/v3/Reporting/profiles/27910/reports/18d039ae036/?totals=all&start_period=current_hour-24&end_period=current_hour&period_type=agg&format=xml&range=1',
                                                         	 SettingType__c = TrendingArticleConstants.SETTING_TYPE_ITEM_TYPE,
                                                         	 ContentTypes__c = TrendingArticleConstants.WEBTRENDS_EAB_DOT_COM_TREND1 + ';' + TrendingArticleConstants.WEBTRENDS_EAB_DOT_COM_TREND2 + ';' + TrendingArticleConstants.WEBTRENDS_EAB_DOT_COM_TREND3));
		
        listIntranetDefaults.add(new Intranet_Defaults__c(Name = TrendingArticleConstants.WEBTRENDS_EAB_DOT_COM_TREND1, 
                                                             Category__c = TrendingArticleConstants.CATEGORY_TRENDING,
                                                             Create_Source__c = 'EAB.com',
                                                             TrendType__c = 'Most Popular Last 24 Hours',
                                                          	 Intranet_Container__c = UserInfo.getUserId(),
                                                             LinkBaseURL__c = 'https://ws.webtrends.com/v3/Reporting/profiles/27910/reports/18d039ae036/?totals=all&start_period=current_hour-24&end_period=current_hour&period_type=agg&format=xml&range=1'));
        
        listIntranetDefaults.add(new Intranet_Defaults__c(Name = TrendingArticleConstants.WEBTRENDS_EAB_DOT_COM_TREND2, 
                                                             Category__c = TrendingArticleConstants.CATEGORY_TRENDING,
                                                             Create_Source__c = 'EAB.com',
                                                             TrendType__c = 'Most Popular Last 7 Days',
                                                          	 Intranet_Container__c = UserInfo.getUserId(),
                                                             LinkBaseURL__c = 'https://ws.webtrends.com/v3/Reporting/profiles/27910/reports/18d039ae036/?totals=all&start_period=current_day-7&end_period=current_day&period_type=agg&format=xml&range=1'));
        
        listIntranetDefaults.add(new Intranet_Defaults__c(Name = TrendingArticleConstants.WEBTRENDS_EAB_DOT_COM_TREND3, 
                                                             Category__c = TrendingArticleConstants.CATEGORY_TRENDING,
                                                             TrendType__c = 'Most Downloaded Last 7 Days',
                                                             Create_Source__c = 'EAB.com',
                                                          	 Intranet_Container__c = UserInfo.getUserId(),
                                                             LinkBaseURL__c = 'https://ws.webtrends.com/v3/Reporting/profiles/27910/reports/ElUxi2T7MM6/?totals=all&start_period=current_day-7&end_period=current_day&period_type=agg&format=xml&range=1'));
        insert listIntranetDefaults; 
        
        return listIntranetDefaults;
    }
    
    //method to check functionality of TrendingArticles
    static testMethod void testGetTrendingArticlesByTrendSourceAdvisoryDotCom() {
        
        //Setup Custom settings
        setUpIntranetSettings();
        List<Intranet_Defaults__c> listIntranetDefaults = setUpIntranetDefaults();
        
        //set mock response
        Test.setMock(HttpCalloutMock.class, new TrendingArticlesMockResponse());
         
        //Test start here
        Test.startTest();
        
        //Added By - Mahendra Swarnkar - 11/11/2017 - CR-20171019-11730 
        TrendingArticleHelper.IntranetContainerContentType = TrendingArticleConstants.TRENDING_ADVISORY_DOT_COM;
        
        //Calling controller method 
        List<TrendingArticle> listTrendingArticles = TrendingArticle.GetTrendingArticlesByTrendSource(TrendingArticleConstants.TRENDING_ADVISORY_DOT_COM);
        
        //Test stop here
        Test.stopTest();
         
        //Assert for results
        // 3 Categories and 1 datarows for each categories = 3*1 = 3
        System.assertEquals(3, listTrendingArticles.size());
         
        //Loop through the Trending articles
        for(Integer i = 1; i < 4; i++) {
         	
         	//assertion
         	System.assertEquals(listIntranetDefaults[i].Create_Source__c, listTrendingArticles[i-1].Source);
         	System.assertEquals(listIntranetDefaults[i].TrendType__c, listTrendingArticles[i-1].Trend_Type);
        }
         	
         	//Check for teh Measures on a fix index
         	System.assertEquals(1222, listTrendingArticles[0].Visit_Count);
         	System.assertEquals(1380, listTrendingArticles[0].View_Count);
    }
    
    //method to check functionality of TrendingArticles
    static testMethod void testGetTrendingContainers() {
        
        //Setup Custom settings
        setUpIntranetSettings();
        List<Intranet_Defaults__c> listIntranetDefaults = setUpIntranetDefaults();
        
        //set mock response
        Test.setMock(HttpCalloutMock.class, new TrendingArticlesMockResponse());
         
        //Test start here
        Test.startTest();
       
        //Added By - Mahendra Swarnkar - 11/11/2017 - CR-20171019-11730 
        TrendingArticleHelper.IntranetContainerContentType = TrendingArticleConstants.TRENDING_ADVISORY_DOT_COM;
        
        //Calling controller method 
        Set<Id> trendingContainersIds = TrendingArticle.GetTrendingContainerIds(TrendingArticleConstants.TRENDING_ADVISORY_DOT_COM);
        
        //Test stop here
        Test.stopTest();
         
        //Assert for results
        System.assertEquals(1, trendingContainersIds.size());
    }
    
    //method to check functionality of TrendingArticles
    static testMethod void testGetTrendingArticlesByTrendSourceEABDotCom() {
        
        //Setup Custom settings
        setUpIntranetSettings();
        List<Intranet_Defaults__c> listIntranetDefaults = setUpIntranetDefaults();
        
        //Set Response
	   	TrendingArticlesMockResponse.MethodNumber = 2;
	   
        //set mock response
        Test.setMock(HttpCalloutMock.class, new TrendingArticlesMockResponse());
         
        //Test start here
        Test.startTest();
       
        //Added By - Mahendra Swarnkar - 11/11/2017 - CR-20171019-11730 
        TrendingArticleHelper.IntranetContainerContentType = TrendingArticleConstants.TRENDING_EAB_DOT_COM;
        
        //Calling controller method 
        List<TrendingArticle> listTrendingArticles = TrendingArticle.GetTrendingArticlesByTrendSource(TrendingArticleConstants.TRENDING_EAB_DOT_COM);
        
        //Test stop here
        Test.stopTest();
         
        //Assert for results
        // 3 Categories and 1 datarows for each categories = 3*1 = 3
        System.assertEquals(3, listTrendingArticles.size());
    }
    
    //This Method is to Test the Get Item Details Callout
    static testMethod void testGetUpdatedTrendingArticlesByTrendingArticles() {
        
    	//Setup Custom settings
        setUpIntranetSettings();
        List<Intranet_Defaults__c> listIntranetDefaults = setUpIntranetDefaults();
        
        //Prepopulate Trending Artcle list with Appropriate Values
       	List<TrendingArticle> listTrendingArticles = new List<TrendingArticle>();
       	
       	//Add 3 dummy records
       	for(Integer i = 0; i < 3; i++) {
       		
       		//Initiate TrendingArticles
       		TrendingArticle tA = new TrendingArticle();
       		tA.Source= 'TestSource';
       		tA.Trend_Type = 'Test_TrendType';
       		tA.Link_Location = 'https://test.com';
       		tA.Article_Title = 'Test Title';
       		tA.Visit_Count = 5000;
       		tA.View_Count = 1000;
       		
       		//Add in list
       		listTrendingArticles.add(tA);
       	}
       
	   	//Set Response
	   	TrendingArticlesMockResponse.MethodNumber = 1;
	   
	    //set mock response
		Test.setMock(HttpCalloutMock.class, new TrendingArticlesMockResponse());
	     
		//Test start here
	    Test.startTest();
		
        //Added By - Mahendra Swarnkar - 11/11/2017 - CR-20171019-11730 
        TrendingArticleHelper.IntranetContainerContentType = TrendingArticleConstants.TRENDING_EAB_DOT_COM;
        
		//Call methiod to get the Item details	    
		listTrendingArticles = TrendingArticle.GetUpdatedTrendingArticlesByTrendingArticles(listTrendingArticles);
	     
	    //Test stop here
	    Test.stopTest();
	    
	    //Expected ArticlePublishDate
	    Date expectedArticlePublishDate = Date.newInstance(2001, 1, 1);
	    
	    //Assert for the results
	    for(TrendingArticle tA : listTrendingArticles) {
	    	
	    	System.assertEquals('ABC Homepage', tA.Article_Type);
	    	System.assertEquals(expectedArticlePublishDate, tA.Article_Publish_Date.date());
	    }
    }
    
    //This Method is to Test the Get Item Details Callout
    static testMethod void testGetUpdatedTrendingArticlesByTrendingArticles_InvalidDateTime() {
        
    	//Setup Custom settings
        setUpIntranetSettings();
        List<Intranet_Defaults__c> listIntranetDefaults = setUpIntranetDefaults();
        
        //Prepopulate Trending Artcle list with Appropriate Values
       	List<TrendingArticle> listTrendingArticles = new List<TrendingArticle>();
       	
       	//Add 3 dummy records
       	for(Integer i = 0; i < 3; i++) {
       		
       		//Initiate TrendingArticles
       		TrendingArticle tA = new TrendingArticle();
       		tA.Source= 'TestSource';
       		tA.Trend_Type = 'Test_TrendType';
       		tA.Link_Location = 'http://test.com';
       		tA.Article_Title = 'Test Title';
       		tA.Visit_Count = 5000;
       		tA.View_Count = 1000;
       		
       		//Add in list
       		listTrendingArticles.add(tA);
       	}
       
	   	//Set Response
	   	TrendingArticlesMockResponse.MethodNumber = 3;
	   
	    //set mock response
		Test.setMock(HttpCalloutMock.class, new TrendingArticlesMockResponse());
	     
		//Test start here
	    Test.startTest();
		
        //Added By - Mahendra Swarnkar - 11/11/2017 - CR-20171019-11730 
        TrendingArticleHelper.IntranetContainerContentType = TrendingArticleConstants.TRENDING_EAB_DOT_COM;
        
		//Call methiod to get the Item details	    
		listTrendingArticles = TrendingArticle.GetUpdatedTrendingArticlesByTrendingArticles(listTrendingArticles);
	     
	    //Test stop here
	    Test.stopTest();
	    
	    //Assert for the results
	    for(TrendingArticle tA : listTrendingArticles) {
	    	
	    	System.assertEquals('ABC Homepage', tA.Article_Type);
	    	System.assertEquals(null, tA.Article_Publish_Date);
	    }
    }
    
    //This method is to  test UpsertIntranetItemsAndSchedules function
    static testMethod void testUpsertIntranetItemsAndSchedules() {
    	
    	//Query through Item record type
    	List<RecordType> itemRdTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Intranet_Item__c' AND isActive = true AND DeveloperName = 'Item_Trending' LIMIT 1];
    	System.assertEquals(1, itemRdTypes.size());
    	
    	//Query through schedule record type
    	List<RecordType> schRdTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Intranet_Schedule__c' AND isActive = true AND DeveloperName = 'Static' LIMIT 1];
    	System.assertEquals(1, schRdTypes.size());
    	
    	//List of trending Articals
    	List<TrendingArticle> listTrendingArticals = new List<TrendingArticle>();
    	
    	//Create  Sample records
    	for(Integer i = 0; i < 5; i++) {
    	
	    	//New Instance of trending articals and set variables value
	    	TrendingArticle trendingArtical = new TrendingArticle();
	    	
	    	trendingArtical.Article_Author = 'Author';
	    	trendingArtical.Article_Publish_Date = date.Today();
	    	trendingArtical.Article_Subtitle = 'Sub Title';
	    	trendingArtical.Article_Title = 'Title';
	    	trendingArtical.Article_Type = 'Test';
            trendingArtical.Link_Location = '{http://www.test.advisory.com/testing-' + i + '}';
	    	trendingArtical.Source = 'Advisory.com';
	    	trendingArtical.Trend_Type = 'Downloading';
	    	trendingArtical.View_Count = 2;
	    	trendingArtical.Visit_Count = 9;
	    	trendingArtical.WS1RequestMessage = 'Request Message WS1';
	    	trendingArtical.WS1RequestTime = Date.Today();
	    	trendingArtical.WS1ResponseMessage = 'Response Message WS1';
	    	trendingArtical.WS1ResponseTime = Date.Today();
	    	trendingArtical.WS2RequestMessage = 'Request Message WS2';
	    	trendingArtical.WS2RequestTime = Date.Today();
	    	trendingArtical.WS2ResponseMessage = 'Response Message WS2';
	    	trendingArtical.WS2ResponseTime = Date.Today();
	    	
	    	listTrendingArticals.add(trendingArtical);
    	}
    	//Intranet container
        Intranet_Container__c intranetContainer = new Intranet_Container__c(Name= 'Contaiiner',
                                                                            CurrencyIsoCode = 'USD',
                                                                            Display_Name__c='Testing',
                                                                            Content_Types_Allowed__c = 'Trending - Advisory.com');
        
        insert intranetContainer ;
        
        //Intranett item
        Intranet_Item__c intranetItem = new Intranet_Item__c(Name = 'Test-0',Active_Status__c = 'Active',
        													Item_Type__c = 'Trending - Advisory.com',
                                                            Item_Title__c = 'Test',
                                                            Category_Name__c = 'A',
                                                            Color_Set_Name__c = 'ColorSet', 
                                                            Office_Short_Name__c = 'Office',
                                                            Unique_Id__c = listTrendingArticals[0].Link_Location);
        insert intranetItem;    
        
        //intranet sschedule
        Intranet_Schedule__c intranetSchedule = new Intranet_Schedule__c(Name = 'Test' , 
        																 Intranet_Container__c = intranetContainer.Id ,
                                                                          Intranet_Item__c = intranetItem.Id,
                                                                         Start_Date_Time__c = DateTime.now(),
                                                                         End_Date_Time__c = DateTime.now().addDays(5),
                                                                        RecordtypeId = schRdTypes[0].Id);  
        insert intranetSchedule;                                                                                                           
        
        //Intranet_Defaults__c 
        Intranet_Defaults__c intranetDefault = new Intranet_Defaults__c(Name = TrendingArticleConstants.ADVISORY_DOT_COM,
                                                              Category__c = TrendingArticleConstants.INTRANET_DEFAULTS_CATEGORY_TRENDING,
                                                              Intranet_Container__c = IntranetContainer.Id,
                                                              Item_RecordTypeId__c = itemRdTypes[0].Id,
                                                              Active_Status__c = 'Active',
                                                              Approval_Status__c = 'Draft',
                                                              Item_Type__c = 'Trending - Advisory.com',
                                                              Link_Action__c = 'Open in New Tab/Window',
                                                              Link_Type__c = 'Standard',
                                                              Schedule_recordTypeId__c = schRdTypes[0].Id,
                                                              Create_Source__c = TrendingArticleConstants.ADVISORY_DOT_COM);
		insert intranetDefault;
		
		//Test start here
        Test.startTest();
                
        //Added By - Mahendra Swarnkar - 11/11/2017 - CR-20171019-11730 
        TrendingArticleHelper.IntranetContainerContentType = TrendingArticleConstants.ADVISORY_DOT_COM;
        
        //Calling method of controller
        Boolean isSucess = TrendingArticle.UpsertIntranetItemsAndSchedules(listTrendingArticals, TrendingArticleConstants.ADVISORY_DOT_COM);
        
        //Test stop here
        Test.stopTest();
        
        //Asseert for results
        // 1 Exisiting + 5 New = 6
        List<Intranet_Item__c> listIntranetItem = [Select Id, Unique_id__c, Active_Status__c, Approval_Status__c, Item_SubTitle__c,
         													  Item_Title__c, Item_Type__c, Link_URL__c ,Link_Action__c,
         													  Trending_View_Count__c, Trending_Visit_Count__c,
         													  Trend_Type__c, Last_Content_Update__c From Intranet_Item__c Where Office_Short_Name__c != 'Office'];
        
        System.assertEquals(5,listIntranetItem.size());
        
        //Assert for New intranet items update
        for(Integer i = 0; i < listIntranetItem.size(); i++ ) {
        	
	        System.assertEquals(listIntranetItem[i].Active_Status__c , intranetDefault.Active_Status__c);
	        System.assertEquals(listIntranetItem[i].Approval_Status__c , intranetDefault.Approval_Status__c);
	        System.assertEquals(listIntranetItem[i].Item_Title__c , listTrendingArticals[i].Article_Title);
	        System.assertEquals(listIntranetItem[i].Item_Type__c , intranetDefault.Item_Type__c);
	        System.assertEquals(listIntranetItem[i].Link_Action__c , intranetDefault.Link_Action__c);
	        System.assertEquals(listIntranetItem[i].Link_URL__c , listTrendingArticals[i].Link_Location);
	        System.assertEquals(listIntranetItem[i].Trending_View_Count__c , listTrendingArticals[0].View_Count);
	        System.assertEquals(listIntranetItem[i].Trending_Visit_Count__c , listTrendingArticals[0].Visit_Count);
	        System.assertEquals(listIntranetItem[i].Trend_Type__c , listTrendingArticals[i].Trend_Type);
            System.assert(!listIntranetItem[i].Unique_id__c.startsWith('{') && !listIntranetItem[i].Unique_id__c.endsWith('}'));
        }
         
        // 1 Exisiting + 5 New = 6
        List<Intranet_Schedule__c> listSchItem = [Select Id,Active_Status__c, Approval_Status__c,Intranet_Container__c,RecordTypeId, Intranet_Item__c  From Intranet_Schedule__c];
        System.assertEquals(6, listSchItem.size());
        
        //Assert for existiing schedule update
        //Assert for Existing + New intranet items update
        for(Integer i = 0; i < listIntranetItem.size(); i++ ) {
        	
		    System.assertEquals(listSchItem[i].Active_Status__c , intranetDefault.Active_Status__c);
	        System.assertEquals(listSchItem[i].Approval_Status__c , intranetDefault.Approval_Status__c);
	        System.assertEquals(listSchItem[i].Intranet_Container__c , intranetDefault.Intranet_Container__c);
	        System.assertEquals(listSchItem[i].RecordTypeId , intranetDefault.Schedule_recordTypeId__c);
        }
    }
}