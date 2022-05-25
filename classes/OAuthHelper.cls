/**
 *  Description     :  OAuth Helper class
 *
 *  Created By      :  Victor Hanson
 *
 *  Created Date    :  05/2/2017
 *
 *  Revision Logs   :   V1.0 - Created
 **/
public class OAuthHelper {
	
    //Fetched from URL
    public String access_token { get; set; }
    public String token_type { get; set; }
    private String api_base_url { get; set; }
    
    //Constructo
    public OAuthHelper() {
        
        //Get the access token
        getAccessToken();
    }
    
    /**
	 *	@description	:	Method to get the access token for the API user   
	 *						
	 *	@args			:	
	 *
	 *	@return			:	void
	 *
	 *	@revision Log	:	V_1.0 - 05/2/2017 - Created - Victor Hanson 
	 *
	 **/
	public void getAccessToken() {
		
        try {
        
	        //Map to hold authentication response
	        Map<String, Object> authResponse = new map<String, Object>();
	        
	        //Flag to check the need of reauthenticate
	        Boolean reAuthenticate = true;
	        
	        //see if the access token has expired.  If not, use the existing token.
	        if (Cache.Org.get('local.Default.springCMAuthentication') != null) {
	            authResponse = (Map<string, Object>)Cache.Org.get('local.Default.springCMAuthentication');
	            DateTime expDateTime = (DateTime)authResponse.get('expDateTime');
	            if (dateTime.now() < expDateTime) {
	            	//If now() is less than the token expiration date/time, use the existing token
	                reAuthenticate = false;
	            }
	        }
	        
	        if (reAuthenticate) {
	        	
	        	//Get End point details from SpringCM metadata
	        	SpringCM_Configuration__mdt springCMConfig = SpringCMHelper.springCMConfig;
	        	
	        	//JSON of the clientId & clientSecret
	            String messageBody = Json.serialize(new AuthRequest(springCMConfig.ClientId__c, springCMConfig.Client_Secret__c));
	            
	        	//Set HttpRequest
	        	HttpRequest request = HTTPRequestBuilder.createSpringCMRequest(springCMConfig.Auth_Endpoint_URL__c, null, messageBody,'POST', 60*1000);
	    	
		        //Send HTTP Request
		        HttpResponse res = HTTPService.send(request);
	        	
	        	//Check for status code
	        	if(res.getStatusCode() == 200) {
	        		
	        		//Get body
		            String resp = res.getBody();
		            
		            //parse the json into a generic object, and get the pertinent info
		            authResponse = (Map<String, Object>) Json.deserializeUntyped(resp);
		            
		            //Get expire time 
		            Decimal expires_in = (Decimal)authResponse.get('expires_in');
		            DateTime expDateTime = dateTime.now().addSeconds(integer.valueOf(expires_in));
		            authResponse.put('expDateTime', (object)expDateTime);
		            Cache.Org.put('local.Default.springCMAuthentication', authResponse);		
	        	} else
	        		throw new customException(res.getBody());
	        }
	        
	        access_token = (String) authResponse.get('access_token');
	        token_type = (String) authResponse.get('token_type');
	        api_base_url = (String) authResponse.get('api_base_url');
        
        } catch(Exception e) {
            
            //Add Error on page
            ApexPages.addMessages(e);
        }
    }
    
    /** object used to create the json for authentication **/
    public class AuthRequest {
        
        //Properties
		public string client_id { get; set; }
        public string client_secret { get; set; }
        
        //Constructor
        public AuthRequest(String client_id, String client_secret) {
            
            //Set values
            this.client_id = client_id;
            this.client_secret = client_secret;
        }
    }
}