/**
 *	Purpose			:	Service class for TrendingArticle
 * 
 * 	Created By		:	Bhavi Sharma
 * 
 * 	Created Date	:	09/11/2014
 * 
 * 	Revision Logs	:	V_1.0 - Created
 * 					:   V_1.1 - Modified by Dipesh Gupta- 11/07/2017 - CR-20171019-11730 - Modified 'GetTrends' - Used a check to identify if user is EAB type or not.
 *
 **/ 
public with sharing class TrendingArticleService {
	
    //Added By - Mahendra Swarnkar - 11/11/2017 - CR-20171019-11730
    //Intranet Container's Content_Types_Allowed__c field value
    public Static String IntranetContainerContentType {get; set;}	 		
    
	/**
	 *	@description	:	This method is to hit the WebTrends endpoint and Get the Measures
	 *
	 *	@args			:	Endpoint URL
	 *
	 *	@return			:	HTTPResponse
	 *
	 *  @Version        :   V_1.1 - Modified by Dipesh Gupta - CR-20171019-11730 - 11/07/2017
	 *
	 **/
	public static HttpResponse GetTrends(String endPointURL) {
		
		//Get Trending Intranet Setting
        Map<String, Intranet_Settings__c> mapTrendingIntranetSettings = Intranet_Settings__c.getAll();
        
        //Create a HttpRequest
		HttpRequest req = new HttpRequest();
		req.setEndpoint(endPointURL);
		req.setMethod('GET');
		
        //V_1.1 - Modified by Dipesh Gupta - CR-20171019-11730 - Start here 
        String username = '';
        String password = '';
        
        if(String.isNotBlank(IntranetContainerContentType)){
         
            //Check if the User is EAB Type
            if(IntranetContainerContentType == TrendingArticleConstants.TRENDING_ADVISORY_DOT_COM) {
                
                 // Specify the required user name and password to access the endpoint
                 username = mapTrendingIntranetSettings.get(TrendingArticleConstants.WEBTRENDS_USER).Value__c;
                 password = mapTrendingIntranetSettings.get(TrendingArticleConstants.WEBTRENDS_PW).Value__c;
            }
            else {
                if(IntranetContainerContentType == TrendingArticleConstants.TRENDING_EAB_DOT_COM){
                    
                    // Specify the required user name and password to access the endpoint
                    username = mapTrendingIntranetSettings.get(TrendingArticleConstants.WebTrendsEAB_User).Value__c;
                    password = mapTrendingIntranetSettings.get(TrendingArticleConstants.WebTrendsEAB_PW).Value__c;   
                }
            }
        }
         //V_1.1 - Modified by Dipesh Gupta - CR-20171019-11730 - End Here
             
        //Authorization
		Blob headerValue = Blob.valueOf(username + ':' + password);
		String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
		req.setHeader('Authorization', authorizationHeader);
		
		//Request
		Http http = new Http();
		HTTPResponse res = http.send(req);
		return res;
	}
	
	/**
	 * 	@description	:	This method is to hit the Endpoint URL
	 * 
	 * 	@args			:	
	 * 
	 * 	@return			:
	 * 
	 **/
	public static HttpResponse SendRequest(String endPointURL, String requestEnvelope) {
		
		//Create a HttpRequest
		HttpRequest req = new HttpRequest();
		req.setEndpoint(endPointURL);
		req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        req.setHeader('SOAPAction', 'http://tempuri.org/GetItemDetails');
		
		//Set Body
		req.setBody(requestEnvelope);
		
		//Request
		Http http = new Http();
		HTTPResponse res = http.send(req);
		return res;
	}
}