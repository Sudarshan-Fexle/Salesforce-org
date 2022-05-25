/**
 *  Purpose         :   This class is to hold all the helper methods for TrendingArticle functionality
 * 
 *  Created By      :   Bhavi Sharma
 * 
 *  Created Date    :   09/11/2014
 * 
 *  Revision Logs   :   V_1.0 - Created
 * 
 **/ 
public with sharing class TrendingArticleHelper {
    
    //Added By - Mahendra Swarnkar - 11/11/2017 - CR-20171019-11730  
    //Intranet Container's Content_Types_Allowed__c field value
    public Static String IntranetContainerContentType {get; set;}	 		
    
    /**
     *  @description    :   This method is to create the request envelope for GetItemDetails callout
     * 
     *  @args           :   URL value
     * 
     *  @return         :   Request.xml
     * 
     **/ 
    public static String GetItemDetailsEnvelope(String url) {
        
        //Request xml
        String requestEnvelope = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">'
                                    + '<soapenv:Header/>'
                                       + '<soapenv:Body>'
                                          + '<tem:GetItemDetails>'
                                             + '<tem:Url>' + url +'</tem:Url>'
                                          + '</tem:GetItemDetails>'
                                       + '</soapenv:Body>'
                                    + '</soapenv:Envelope>';
        return requestEnvelope; 
    }
    
    /**
     *  @description    :   This method is to parse the web service response and create the trending articles
     * 
     *  @args           :   response
     * 
     *  @return         :   List of Trending Articles
     * 
     **/
    public static List<TrendingArticle> GenerateTrendingArticlesFromGetTrendsResponse(HTTPResponse response, Map<String, Intranet_Defaults__c> mapTrendingIntranetDefaults, String trendName, DateTime requestTime) {
        
        //List of Trending article to be processed
        List<TrendingArticle> trendingArticles = new List<TrendingArticle>();
        
        //Get the DOM element
        if(response != null && response.getStatusCode() == 200) {
        	
            //Load document
            Dom.Document dom = response.getBodyDocument();
            
            //Get Root Element
            DOM.XmlNode rootElement = DOM.getRootElement();
            
            //Get List note
            for(DOM.XmlNode listElement : rootElement.getChildElement('list', null).getChildElement('DataRow', null).getChildren()) {
                
                //Get listElement and check the attribute name, if it's SubRows, then process it further
                if(listElement.getAttribute('name', null) == 'SubRows') {
            
                    //Get the Rows from Subrows list
                    for(DOM.XmlNode dataRowElement : listElement.getChildElement('list', null).getChildren()) {
                    
                        //initialize a new instance of Trending Article
                        TrendingArticle trendingArticle = new TrendingArticle();
                        
                        //Set request values
                        trendingArticle.Source = mapTrendingIntranetDefaults.get(trendName).Create_Source__c;
                        trendingArticle.Trend_Type = mapTrendingIntranetDefaults.get(trendName).TrendType__c; 
                        trendingArticle.Sort_Order = mapTrendingIntranetDefaults.get(trendName).SearchResultOrder__c; 
                        trendingArticle.WS1RequestTime = requestTime;
                        trendingArticle.WS1RequestMessage = mapTrendingIntranetDefaults.get(trendName).LinkBaseURL__c;
                        
                        //Get the complete DataRow message
                        trendingArticle.WS1ResponseTime = DateTime.now();
                        trendingArticle.WS1ResponseMessage = String.valueOf(dataRowElement);
                        
                        //String Link URL
                        String linkURL = dataRowElement.getAttribute('name', null);
                        if(linkURL == null)
                            continue;
                        //Split the URL and Chekc if it has year parameter in URL, then it''s a conetnet uploaded'
                        List<String> pairs = linkURL.split('/');
						for(String keyWord : pairs) {
							
							if(keyWord.isNumeric() && Integer.valueOf(keyWord) > 2000) {
								
								//Update Link Location
								trendingArticle.Link_Location = dataRowElement.getAttribute('name', null);
								break;
							}
						}
                        
                        //Only process teh below code when Link URL is not null
                        if(String.isNotBlank(trendingArticle.Link_Location)) {
                        
	                        //Title & Measures
	                        for(DOM.XmlNode dRChildElement : dataRowElement.getChildren()) {
	                            
	                            if(dRChildElement.getAttribute('name', null) == 'attributes') {
	                                
	                                //Title
	                                System.debug(dRChildElement);
	                                if(dRChildElement.getChildElement('string', null) != null)
	                                    trendingArticle.Article_Title = dRChildElement.getChildElement('string', null).getText();   
	                            }
	                            
	                            //Get listElement and check the attribute name, if it's SubRows, then process it further
	                            else if(dRChildElement.getAttribute('name', null) == 'measures') {
	                            
	                                //Get float data
	                                for(DOM.XmlNode floatElement : dRChildElement.getChildren()) {
	                                    
	                                    //Visits
	                                    if(floatElement.getAttribute('name', null) == 'Visits') {
	                                        
	                                        //Visits
	                                        if(String.isNotBlank(floatElement.getText()))
	                                            trendingArticle.Visit_Count = Integer.valueOf(floatElement.getText());
	                                    } 
                                        
                                        //Views
                                        if(floatElement.getAttribute('name', null) == 'Views') {
	                                        
	                                        //Views
	                                        if(String.isNotBlank(floatElement.getText()))
	                                            trendingArticle.View_Count = Integer.valueOf(floatElement.getText());
	                                    }
                                        
                                        //Downlaods
                                        if(floatElement.getAttribute('name', null) == 'Downloads') {
	                                        
	                                        //Views
	                                        if(String.isNotBlank(floatElement.getText()))
	                                            trendingArticle.Download_Count = Integer.valueOf(floatElement.getText());
	                                    }
	                                }
	                            }
	                        }
	                        
	                        //Add in list
	                        if(trendingArticle.Link_Location != null) {
	                            
	                            //Add in list
	                            trendingArticles.add(trendingArticle);
	                        	break;
	                        }
	                    }
                    }
                }
            }
        }
        
        //return trendingArticles
        return trendingArticles;
    }
    
    /**
     *  @description    :   This method is to creare a TrendingArticle instance and Populate it with the request and response parameters.
     * 
     *  @args           :   
     * 
     *  @return         :   List<TrendingArticle>
     * 
     **/
    public static List<TrendingArticle> GetUpdatedTrendingArticleList(List<TrendingArticle> trendingArticles, 
                                                                    Map<String, Intranet_Defaults__c> mapTrendingIntranetDefaults,
                                                                    String trendName) {
        
        //Webservice request time
        DateTime requestTime =  DateTime.now();
        
        //EndPoint URL
        String endpointURL = mapTrendingIntranetDefaults.get(trendName).LinkBaseURL__c;
		
		//Added By - Mahendra Swarnkar - 11/11/2017 - CR-20171019-11730
		if(String.isNotBlank(IntranetContainerContentType))                                                      
			TrendingArticleService.IntranetContainerContentType = IntranetContainerContentType;
        
		//Webservice Call
        HttpResponse httpResponse = TrendingArticleService.GetTrends(endPointURL);
        
        //Parse response and get the Trending Articles
        trendingArticles.addAll(TrendingArticleHelper.GenerateTrendingArticlesFromGetTrendsResponse(httpResponse, mapTrendingIntranetDefaults, trendName, requestTime));
        return trendingArticles;
    }
    
    /**
     *  @description    :   This method is to Loop through the Trending articles list and Call GetItem Details method for each TrendingArticle URL.
                                With each callout response, update the TrendingArticle instance
     * 
     *  @args           :   List of Trending Articles
     * 
     *  @return         :   Updated List of TrendingArticles
     *
     **/
    public static List<TrendingArticle> GetUpdatedTrendingArticleList(List<TrendingArticle> trendingArticles, 
                                                                    Map<String, Intranet_Settings__c> mapTrendingIntranetSettings) {
        
        //Endpoint
        String endPointURL = Label.ENDPOINT_GET_TRENDING_ITEM_DETAIL;
        
        //Loop Through the Trending Articles
        for(TrendingArticle tA : trendingArticles) {
            
            //Check of Link_Location is not Null
            if(String.isNotBlank(tA.Link_Location))  {
                
                //request envelope
                System.debug('tA.Link_Location:::::'+ tA.Link_Location);
                String requestEnvelope = TrendingArticleHelper.GetItemDetailsEnvelope(tA.Link_Location);
                
                //Set request parameters
                tA.WS2RequestTime = DateTime.now();
                tA.WS2RequestMessage = requestEnvelope;
                
                //Get webservice response
                HttpResponse response = TrendingArticleService.SendRequest(endPointURL, requestEnvelope);
                
                //Update Trending Article Instance
                tA.WS2ResponseTime = DateTime.now();
                tA.WS2ResponseMessage = response.getBody();
                tA = TrendingArticleHelper.GetUpdatedTrendingArticle(response, tA);
            }
        }
        
        //Return 
        return trendingArticles;                                                        
    }
    
    /**
     *  @description    :   Helper method to update teh Trending Article instance with the GetItemDetail Response
     * 
     *  @args           :   Response, Trending Article
     * 
     *  @return         :   Updated TrendingArticle
     *
     **/
    public static TrendingArticle GetUpdatedTrendingArticle(HttpResponse response, TrendingArticle trendingArticle) {
        
        //Check for the successful response
        if(response != null && response.getStatusCode() == 200) {
            
            //Load document
            Dom.Document dom = response.getBodyDocument();
            
            //Get Root Element
            DOM.XmlNode rootElement = dom.getRootElement();
            
            //Node
            DOM.XmlNode GetItemDetailsResultNode = rootElement.getChildElement('Body', TrendingArticleConstants.NS_SOAP).getChildElement('GetItemDetailsResponse', TrendingArticleConstants.NS_TEMP_URI).getChildElement('GetItemDetailsResult', TrendingArticleConstants.NS_TEMP_URI);
            
            //SubTitle
            if(GetItemDetailsResultNode.getChildElement(TrendingArticleConstants.KEYWORD_ARTICLE_SUBTITLE, TrendingArticleConstants.NS_TEMP_URI) != null)
            	trendingArticle.Article_Subtitle = GetItemDetailsResultNode.getChildElement(TrendingArticleConstants.KEYWORD_ARTICLE_SUBTITLE, TrendingArticleConstants.NS_TEMP_URI).getText();
            
            //ArticlePublishDate
            if(GetItemDetailsResultNode.getChildElement(TrendingArticleConstants.KEYWORD_ARTICLE_PUBLISH_DATE, TrendingArticleConstants.NS_TEMP_URI) !=null) {
                String publishDate = GetItemDetailsResultNode.getChildElement(TrendingArticleConstants.KEYWORD_ARTICLE_PUBLISH_DATE, TrendingArticleConstants.NS_TEMP_URI).getText();
                if(String.isNotBlank(publishDate) && publishDate != TrendingArticleConstants.INVALID_PUBLISH_DATE) {
                    
                    //Date and Time Pair
                    List<String> dateTimePair = publishDate.split(' ');
                    List<String> dateComponents = dateTimePair[0].split('/');
                    trendingArticle.Article_Publish_Date = DateTime.newinstance(Date.newinstance(Integer.valueOf(dateComponents[2]), Integer.valueOf(dateComponents[0]), Integer.valueOf(dateComponents[1])), Time.newInstance(0, 0, 0, 0));
                }
            }
            
            //ArticleAuthor
            if(GetItemDetailsResultNode.getChildElement(TrendingArticleConstants.KEYWORD_ARTICLE_AUTHOR, TrendingArticleConstants.NS_TEMP_URI) != null)
            	trendingArticle.Article_Author = GetItemDetailsResultNode.getChildElement(TrendingArticleConstants.KEYWORD_ARTICLE_AUTHOR, TrendingArticleConstants.NS_TEMP_URI).getText();
            
            //ArticleType
            if(GetItemDetailsResultNode.getChildElement(TrendingArticleConstants.KEYWORD_ARTICLE_TYPE, TrendingArticleConstants.NS_TEMP_URI) != null)
            	trendingArticle.Article_Type = GetItemDetailsResultNode.getChildElement(TrendingArticleConstants.KEYWORD_ARTICLE_TYPE, TrendingArticleConstants.NS_TEMP_URI).getText();
        }
        
        //return Update instance
        return trendingArticle;
    }
}