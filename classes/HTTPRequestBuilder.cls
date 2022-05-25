/**
 *  Description     :   This class is to Create a HTTP request
 *
 *  Created By      :	Bhavi Sharma
 *
 *  Created Date    :   08/23/2013
 *
 *  Revision Logs   :   V_1.0 - Created
 *						V_1.0 - Modified - 05/5/2017 - Subhash Garhwal - Added a new request method to SpringCM call
 *
**/
public with sharing class HTTPRequestBuilder {

    //Modified by rajeev jain
    //Method is to get serialize HTTPRequest
  /*  public static HttpRequest CreateRequest(String endPoint, String method, String soapAction, String body) {

        //Load custom setting
		Credit_Card_Settings__c configDefaults = CreditCardConstants.CONFIG_DEFAULT;

        //Http Request Object
        HttpRequest request = new HttpRequest();
        request.setEndpoint(configDefaults.Endpoint__c);
        request.setMethod(CreditCardConstants.REQUEST_TYPE_POST);
        request.setHeader('SOAPAction', soapAction);
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setBody(body);
        request.setTimeout(120000);

        System.debug('request message is: '+ request.getBody());

        return request;
    }
*/    
    /**
	 *	@description	:	Method to create HttpRequest request for SpringCM   
	 *						
	 *	@args			:	String, String, String, String, Integer
	 *
	 *	@return			:	HttpRequest
	 *
	 *	@revision Log	:	V_1.0 - 05/5/2017 - Created - Subhash Garhwal - Originally created by Victor. Moved code from SpringCMHelper class to here  
	 *
	 **/
	public static HttpRequest createSpringCMRequest(String endPoint, String authorization, String messageBody, String requestType, Integer timeOut) {
        return createSpringCMRequest(endPoint, null, authorization, messageBody, requestType, timeOut);
	}
    
    /**
	 *	@description	:	Method to create HttpRequest request for SpringCM   
	 *						
	 *	@args			:	String, String, String, String, Integer
	 *
	 *	@return			:	HttpRequest
	 *
	 *	@revision Log	:	V_1.0 - 06/7/2017 - Created - Victor Hanson - Overloaded method so we can send blobs as the body of request for file insert
	 *
	 **/
    public static HttpRequest createSpringCMRequest(String endPoint, blob fileBlob, String authorization, String messageBody, String requestType, Integer timeOut) {
		
		//Http Request Object
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(requestType);
        request.setTimeout(timeOut);
        
        if(authorization != null) {
            system.debug('@@Authorization:' + authorization);
        	request.setHeader('Authorization', authorization);
        }
        
        //Check for request Type
        if(requestType == 'POST' || requestType == 'PUT') {
        	
        	request.setHeader('Accept', '*/*');
        	request.setHeader('Content-Transfer-Encoding', 'base64');
            request.setHeader('Content-Type', 'application/json');
            
	        if (fileBlob != null) request.setBodyAsBlob(fileBlob);
            else request.setBody(messageBody);
	        request.setHeader('Content-length', String.valueOf(messageBody.length()));	
        }
        
        //system.debug('@@messageBody:' + request.getBody());
        system.debug('@@getEndpoint:' + request.getEndpoint());

        return request;
	}

    /**
     *  @description    :   Method to create HttpRequest request for Marketo   
     *                      
     *  @args           :   String, String
     *
     *  @return         :   HttpRequest
     *
     *  @revision Log   :   V_1.0 - 25/4/2018 - Created - Colin McGloin
     *
     **/

    public static HttpRequest createMarketoCallout (String endPoint, String requestType){

        //Http Request Object
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(requestType);
        request.setTimeout(1200);

        return request;

    }


}