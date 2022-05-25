public with sharing class ProductLeadUtilities {
    
    public ProductLeadUtilities() {
        
    }

     /**
     *  @description    :   Grabs the Marketo Access Token needed for any MarketoCallout
     * 
     *  @args           :   None
     * 
     *  @return         :   String
     * 
     *  @Revision Log   :   V1.0 - Created By - Colin McGloin - 04/27/2018 - CR-20180220-12079 - Marketo Release
     **/
    
    public static string getMarketoAccessToken () {
        
        //String for Access Token
        String accessToken = '';

        //Declare our request 
        HttpRequest request = new HttpRequest();
        
        try {
            
            //Map to hold authentication response
            Map<String, Object> authResponse = new map<String, Object>();
            
            //Grab our Marketo Launchpoint Details
            Marketo_API_Config__c marketoConfig = Marketo_API_Config__c.getOrgDefaults();
            
            //Grab our Client ID and Client Secret
            String clientID = marketoConfig.Client_ID__c;
            String clientSecret = marketoConfig.Client_Secret__c;
            String endpoint = marketoConfig.Marketo_Identity_Endpoint__c;
            
            //Build our endpoint for the callout
            string calloutEndpoint = endpoint + clientID + '&client_secret=' + clientSecret;
            
            //Create our HTTP Request
            request = HTTPRequestBuilder.createMarketoCallout(calloutEndpoint, 'GET');

            System.debug('@@@request' + calloutEndpoint);
            
            //Send HTTP Request
            HttpResponse tokenResponse = HTTPService.send(request);
            
            //If our response is successful, then proceed with parse
            if (tokenResponse.getStatusCode() == 200){
                
                //Get body
                String resp = tokenResponse.getBody();
                
                //parse the json into a generic object, and get the pertinent info
                authResponse = (Map<String, Object>) Json.deserializeUntyped(resp);
                
                //Get our Access Token from the Map
                accessToken = (String) authResponse.get('access_token');

                //Create a List for passing through to Web Service Log creation method
                /*List<webServiceMarketoWrapper> wrappers = new List<webServiceMarketoWrapper>();
                
                //Loop through our Product Leads to create a Web Service Log for each Product Lead passed through
                for (Id pLead : prodLeadIDs){

                //Create our Wrappers for passing through to WebService Log Creation
                webServiceMarketoWrapper wrapper = new webServiceMarketoWrapper (request.getBody(), resp,'Success','ProductLeadUtilities', 'getMarketoAccessToken', pLead);

                //Add wrapper to our List
                wrappers.add(wrapper);

                //Create our WebService Log
                //insertWebServiceLog(wrappers);
                //insertWebServiceLog(request.getBody(), resp, 'Success', 'ProductLeadUtilities', 'getMarketoAccessToken', pLead);

            	}*/
                
            }
            
        }
        
        catch (Exception e) {

        	    //Create a List for passing through to Web Service Log creation method
                /*List<webServiceMarketoWrapper> wrappers = new List<webServiceMarketoWrapper>();
                
                //Loop through our Product Leads to create a Web Service Log for each Product Lead passed through
                for (Id pLead : prodLeadIDs){

	                //Create our Wrappers for passing through to WebService Log Creation
	                webServiceMarketoWrapper wrapper = new webServiceMarketoWrapper(request.getBody(),e.getMessage(), 'Failure', 'ProductLeadUtilities', 'getMarketoAccessToken', pLead);

	                //Add wrapper to our List
	                wrappers.add(wrapper);

	                //Create our WebService Log
	                //insertWebServiceLog(wrappers);
	                //insertWebServiceLog(request.getBody(), resp, 'Success', 'ProductLeadUtilities', 'getMarketoAccessToken', pLead);

            	}
            
            //Insert a WebService Log
            //insertWebServiceLog(NULL, e.getMessage(), 'Failure', 'ProductLeadUtilities', 'getMarketoAccessToken');*/
            
        }
        
        //Return our access token
        return accessToken;
        
    }

    @invocableMethod
    public static void productLeadMarketoUpdate (List<Id> prodLeads) {

    	String jsonStr = '';

    	//Map for building our JSON callout
    	List<Map<String, String>> jsonMapList = new List<Map<String, String>>();

		//Create JSON Generator
    	JSONGenerator gen = JSON.createGenerator(true);

    	//Run a query of Product Leads to get most recent values
    	List<Product_Lead__c> prodLeadsToUpdate = [SELECT Id, Contact__c, Contact__r.Counter_ID__c, Lead__c, Lead__r.Counter_ID__c, 
													Marketo_Lead_Score__c, Program__r.Program_Acronym__c
    												FROM Product_Lead__c
    												WHERE Id IN :prodLeads];

    	//If we have records to work with
    	if (prodLeadsToUpdate.size() > 0){

    		//Start our JSON Generator
    		gen.writeStartObject();

    		//Loop through our Product Leads
    		for (Product_Lead__c pLead : prodLeadsToUpdate){

    			String pLeadCounterID = '';
    			String marketoScoreFieldName = '';

    			//Check to see if our Contact or Lead is populated
    			if (pLead.Contact__c != null){
    				pLeadCounterID = pLead.Contact__r.Counter_ID__c;
    			} else if (pLead.Contact__c == null && pLead.Lead__c != null){
    				pLeadCounterID = pLead.Lead__r.Counter_ID__c;
    			}

    			//Populate Map with our value if we have one
    			if (String.isNotEmpty(pLeadCounterID)){
    				//jsonMapList.add(new Map<String, String> {'Counter_ID__c' => pLeadCounterID});

    				//Dynamically write to the Generator
    				gen.writeStringField('Counter_ID__c',pLeadCounterID);

    			}

    			//Build our Marketo Score Field Name
    			if (pLead.Program__r.Program_Acronym__c != null){
    				marketoScoreFieldName = 'leadScore' + pLead.Program__r.Program_Acronym__c;

    				//Populate our Map with the Marketo Score Value
    				//jsonMapList.add(new Map<String, String> {marketoScoreFieldName => String.valueOf(pLead.Marketo_Lead_Score__c)});

    				//Dynamically write to the Generator
    				gen.writeStringField(marketoScoreFieldName , String.valueOf(pLead.Marketo_Lead_Score__c));

    			}

    		}

    		  	//Close the JSON Generator
    			gen.writeEndObject();

    	}

    	//Get the JSON string from the Generator
        jsonStr = gen.getAsString();

    	//If we have Product Lead values for upsert then proceed
    	//if (jsonMapList.size() > 0){
    	if (jsonStr != null){

    		//Converts our Map to JSON for callout
    		//jsonStr = JSON.serializePretty(jsonMapList);

    		system.debug('jsonList' + jsonStr);

    		//Make our Marketo Callout
    		
    		marketoCallout('POST', jsonStr, prodLeads);
    	}

    }


    @future (callout=true)
    public static void marketoCallout (String setMethod, String requestBodyFields, List<Id> pLeadIds) {
    
    //Declare our HttpRequest & Response
    HttpRequest pleadRequest = new HttpRequest();
    HttpResponse responseBody = new HttpResponse();

        try {

            //Get our Access Token for the Marketo API Call
            String accessToken = getMarketoAccessToken();

            //Populate our Access Token for Test Classes
            if (Test.isRunningTest()){
            	accessToken = '35b16797-8a22-4e7b-8dab-e1320a2b15ef:ab';
            }

            System.debug('zzz@@@' + accessToken);
            
            //Grab our Marketo Launchpoint Details
            Marketo_API_Config__c marketoConfig = Marketo_API_Config__c.getOrgDefaults();
            
            //If we have an access token then run logic
            if (String.isNotEmpty(accessToken)){
                
                //Create our HTTP Response for Marketo Callout
                pleadRequest.setHeader('Content-Type', 'application/json');
                pleadRequest.setMethod(setMethod);
                
                //Build our Endpoint from Custom Setting and Access Token
                String endpoint = marketoConfig.Marketo_Upsert_URL__c + accessToken;
                pleadRequest.setEndpoint(endpoint);

                System.debug('***Request Endpoint***' + endpoint);
                    
                //We need to make this more flexible
                String requestBody = '{"action":"updateOnly","lookupField":"Counter_ID__c","input":[' + requestBodyFields + ']}';    
                pleadRequest.setBody(requestBody);

                System.debug('@@@zzz' + requestBody);
                
                //Response returned from Call
                responseBody = HTTPService.send(pleadRequest);

                System.debug('zzzresponse' + responseBody.getStatusCode());
                
                //Check to see it was successful or send alert email
                if (responseBody.getStatusCode() == 200) {

                	//Get body
                	String resp = responseBody.getBody();

                	//Create a List for passing through to Web Service Log creation method
                	List<webServiceMarketoWrapper> wrappers = new List<webServiceMarketoWrapper>();
                
                	//Loop through our Product Leads to create a Web Service Log for each Product Lead passed through
                	for (Id pLead : pLeadIds){

	                	//Create our Wrappers for passing through to WebService Log Creation
	                	webServiceMarketoWrapper wrapper = new webServiceMarketoWrapper (pleadRequest.getBody(), resp,'Success','ProductLeadUtilities', 'marketoCallout', pLead);

	                	//Add wrapper to our List
	                	wrappers.add(wrapper);
	                    
	                	//Create our WebService Log
	                	insertWebServiceLog(wrappers);

            		}
                    
                }
                
            }
            
        }
        
        //Catch our Exception if the Insert fails and log a WebService Log
        catch (Exception e) {

            //Declare our Response string
            String resp;

        	//Get body of the Response
            if (responseBody != null && responseBody.getBody() != null){
                resp = responseBody.getBody();
            } else {
                resp = e.getMessage();
            }

        	//Create a List for passing through to Web Service Log creation method
            List<webServiceMarketoWrapper> wrappers = new List<webServiceMarketoWrapper>();
                
            //Loop through our Product Leads to create a Web Service Log for each Product Lead passed through
            for (Id pLead : pLeadIds){

	            //Create our Wrappers for passing through to WebService Log Creation
	            webServiceMarketoWrapper wrapper = new webServiceMarketoWrapper (pleadRequest.getBody(), resp ,'Success','ProductLeadUtilities', 'marketoCallout', pLead);

	            //Add wrapper to our List
	            wrappers.add(wrapper);
	                    
	            //Create our WebService Log
	            insertWebServiceLog(wrappers);

            }
            
        }
        
    }
    



    public static void insertWebServiceLog (List<webServiceMarketoWrapper> marketoWebServices) /*(String requestMessage, String responseMessageLog, String responseMessage, String webServiceClass, String webServiceMethod, Id prodLeadId)*/ {
        
    	//List for inserting our WebService Logs
    	List<Web_Service_Log__c> wServiceLogs = new List<Web_Service_Log__c>();

        //Loop through our Wrappers
        for (webServiceMarketoWrapper pLeadWrapper : marketoWebServices){

	        //Create a new WebService Log Record
	        Web_Service_Log__c webServiceLog = new Web_Service_Log__c();
	        
	        //Set the Record Type to Marketo
	        webServiceLog.RecordTypeId = Schema.SObjectType.Web_Service_Log__c.RecordTypeInfosByName.get('Marketo').RecordTypeId;

	        //Assign our Product Lead so the WebService Log is associated correctly
	        webServiceLog.Product_Lead__c = pLeadWrapper.pLeadId;
	        
	        //Populate the necessary WebService fields
	        webServiceLog.Request_Message_Log__c = pLeadWrapper.requestMessage;
	        webServiceLog.Response_Message_Log__c = pLeadWrapper.responseMessageLog;
	        webServiceLog.Response_Message__c = pLeadWrapper.responseMessage;
	        webServiceLog.Request_Sent__c = DateTime.now();
	        webServiceLog.Requested_By__c = UserInfo.getName();
	        webServiceLog.Web_Service_Class__c = pLeadWrapper.webServiceClass;
	        webServiceLog.Web_Service_Method__c = pLeadWrapper.webServiceMethod;

	        //Add our WebService Log to List for Insertion
	        wServiceLogs.add(webServiceLog);

    	}
        
        //If we have Webservice Logs to insert then proceed
        if (wServiceLogs.size() > 0){

	        //insert logs
	        insert wServiceLogs;

	    }
        
    }

    public class webServiceMarketoWrapper {

    	public String requestMessage {get; set;}
    	public String responseMessageLog {get; set;}
    	public String responseMessage {get; set;}
		public String webServiceClass {get; set;}
		public String webServiceMethod {get; set;}
		public Id pLeadId {get; set;}


		public webServiceMarketoWrapper (String requestMessage, String responseMessageLog, String responseMessage, String webServiceClass, String webServiceMethod, Id pLeadId) {

			this.requestMessage = requestMessage;
			this.responseMessageLog = responseMessageLog;
			this.responseMessageLog = responseMessageLog;
			this.webServiceClass = webServiceClass;
			this.webServiceMethod = webServiceMethod;
			this.pLeadId = pLeadId;
		
		}

    }
    
}