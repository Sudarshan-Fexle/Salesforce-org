/**
 *  Description     :   This class is to make ths webservice callout.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   08/23/2013
 *
 *  Revision Logs   :   V1.0 - Created
 * 						V1.1 - Modified - Victor Hanso - 08/22/2017 - added a seperate method that sends the callout even if it is called from a unit test
 *
**/
public with sharing class HTTPService {
	
	//HttpResponse instance
	public static HttpResponse response;
    
    //boolean to indicate whether or not the callout should execute while in a unit test
    public static boolean sendCalloutInUnitTest = false;
	
    /**
     * 
     * @description: method to Make callout
     * 
     * @revision log: V1.1 - 08/22/2017 - Victor Hanson - Modified
     * 
     **/
    public static HttpResponse send(HttpRequest request) {

        //Create a HTTP instance and do callout
        Http http = new Http();
        
        //Check whether or not this should send the callout
        if(!Test.isRunningTest() || sendCalloutInUnitTest)
        	response = http.send(request);
        
        return response;
    }
}