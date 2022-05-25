@isTest
private class Test_ProductLeadUtilties {

	/**
     * @description: Create our Test Data needed for the Test methods in the class
     **/

	@TestSetup
	public static void createTestData() {
		
		//Create an Institution and Contact
		Account testAccount = TestUtilities.CreateNewAccount(true);
		Contact brianODriscoll = TestUtilities.CreateNewContact(true);
		brianODriscoll.Location__c = 'TestClass @@@';
		update brianODriscoll; 

		//Create a new Program and set as Marketable to meet Lookup filter requirements
		Program__c testProg = TestUtilities.CreateNewProgram(true);
		testProg.Marketable__c = true;
		update testProg;

		//Create a new Lead to test process
		Lead johnnySexton = new Lead();
		johnnySexton.FirstName = 'Johnny';
		johnnySexton.LastName = 'Sexton';
		johnnySexton.LeadSource = 'Webinar';
		johnnySexton.Company = 'IRFU Test Class';
		insert johnnySexton;

		//Create a test Contact related Product Lead record
		Product_Lead__c testProdLead = new Product_Lead__c();
		testProdLead.Stage__c = 'Inquiry';
		testProdLead.Contact__c = brianODriscoll.Id;
		testProdLead.Program__c = testProg.Id;

		//Create our Lead related Product Lead Record
		Product_Lead__c testProdLead2 = new Product_Lead__c();
		testProdLead2.Stage__c = 'Inquiry';
		testProdLead2.Lead__c = johnnySexton.Id;
		testProdLead2.Program__c = testProg.Id;

		//Add our Product Leads to List
		List<Product_Lead__c> prodLeads = new List<Product_Lead__c>();
		prodLeads.add(testProdLead);
		prodLeads.add(testProdLead2);

		//Insert our Product Lead records
		insert prodLeads;

		//Create our Custom Setting Data
		Marketo_API_Config__c customSetting = new Marketo_API_Config__c();
		customSetting.Client_ID__c = '0f284101-02d9-41e4-8681-7c3b2078f17d';
		customSetting.Client_Secret__c = 'VyqtUpzUdK1BWEEDpMbLzwccSbrdsn66';
		customSetting.Endpoint__c = 'https://633-BTQ-665.mktorest.com/';
		customSetting.Marketo_Upsert_URL__c = 'https://633-BTQ-665.mktorest.com/rest/v1/leads.json?access_token=';
		customSetting.Marketo_Identity_Endpoint__c = 'https://633-BTQ-665.mktorest.com/identity/oauth/token?grant_type=client_credentials&client_id=';
		insert customSetting;
		
	}
	
	/**
     * @description: Simulate the Callout to get the Marketo Access Token & Product Lead Upsert
     **/

	@isTest static void testSuccessfulCallout() {

		//Grab our Contact Product Lead
		Product_Lead__c brian1 = [SELECT Id, Name, Stage__c, Action__c, Contact__c, Reset__c, Contact__r.Counter_ID__c FROM Product_Lead__c WHERE Contact__r.Location__c = 'TestClass @@@'];

		//Create our Headers
		Map<String, String> header = new Map<String, String> {'Content-Type' => 'application/json'};

		//Create our Mock Callout response for the Token Callout
		String tokenResponse = '{"access_token":"35b16797-8a22-4e7b-8dab-e1320a2b15ef:ab","token_type":"bearer","expires_in":2987,"scope":"bneal@eab.com"}';
		SingleRequestMock fakeTokenResponse = new SingleRequestMock (200, 'Success', tokenResponse, header);

		//Build our Marketo Callout Response
		//String updateResponse = '{"action":"updateOnly","lookupField":"Counter_ID__c","input":[{"Counter_ID__c" : "' + brian1.Contact__r.Counter_ID__c + ',"leadScoreHCAB" : "0"}]}';
		String updateResponse = '{"requestId":"14bac#16313fd4644","result":[{"id":71428,"status":"updated"}],"success":true}';
		SingleRequestMock fakeUpsertResponse = new SingleRequestMock (200,'Success', updateResponse, header);

		//Get our Callout URLS
		Marketo_API_Config__c config = Marketo_API_Config__c.getOrgDefaults();
		String clientId = config.Client_ID__c;
		String clientSecret = config.Client_Secret__c;
		String tokenURL = config.Marketo_Identity_Endpoint__c + clientID + '&client_secret=' + clientSecret;
		String upsertURL = config.Marketo_Upsert_URL__c + '35b16797-8a22-4e7b-8dab-e1320a2b15ef:ab';

		//Create our callout map
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(tokenURL, fakeTokenResponse);
		endpoint2TestResp.put(upsertURL, fakeUpsertResponse);

		//Create our Successful Mock Callout record
		testMultipleCallout mockAccessCallout = new testMultipleCallout(endpoint2TestResp);

		//Set our Successful Mock Callout record
		Test.setMock(HttpCalloutMock.class, mockAccessCallout);

		//Start our Test
		Test.startTest();

		//We want our callout to be sent
		HTTPService.sendCalloutInUnitTest = true;

		//Grab our Contact Product Lead
		Product_Lead__c brian2 = [SELECT Id, Name, Stage__c, Action__c, Contact__c, Reset__c FROM Product_Lead__c WHERE Contact__r.Location__c = 'TestClass @@@'];

		//Update our Product Lead so it triggers the Marketo Callout
		brian2.Reset__c = true;
		update brian2;

		//Stop our Test
		Test.stopTest();

		//Grab our Product Lead for verification
		Product_Lead__c brian3 = [SELECT Id, Name, Stage__c, Action__c, Contact__c, Reset__c FROM Product_Lead__c WHERE Contact__r.Location__c = 'TestClass @@@'];

		//System.assertEquals(false, brian3.Reset__c);

	}


	/**
     * @description: Simulate failure to ensure the Exception works correctly - no Mock Upsert Callout created in this case
     **/

	@isTest static void testFailedCallout() {

		//Grab our Contact Product Lead
		Product_Lead__c brian1 = [SELECT Id, Name, Stage__c, Action__c, Contact__c, Reset__c, Contact__r.Counter_ID__c FROM Product_Lead__c WHERE Contact__r.Location__c = 'TestClass @@@'];
		
        //Create our Headers
		Map<String, String> header = new Map<String, String> {'Content-Type' => 'application/json'};

		//Create our Mock Callout response for the Token Callout
		String tokenResponse = '{"access_token":"35b16797-8a22-4e7b-8dab-e1320a2b15ef:ab","token_type":"bearer","expires_in":2987,"scope":"bneal@eab.com"}';
		SingleRequestMock fakeTokenResponse = new SingleRequestMock (600, 'Failure', tokenResponse, header);

		//Get our Callout URLS
		Marketo_API_Config__c config = Marketo_API_Config__c.getOrgDefaults();
		String clientId = config.Client_ID__c;
		String clientSecret = config.Client_Secret__c;
		String tokenURL = config.Marketo_Identity_Endpoint__c + clientID + '&client_secret=' + clientSecret;

		//Create our callout map
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(tokenURL, fakeTokenResponse);

		//Create our Successful Mock Callout record
		testMultipleCallout mockAccessCallout = new testMultipleCallout(endpoint2TestResp);

		//Set our Successful Mock Callout record
		Test.setMock(HttpCalloutMock.class, mockAccessCallout);

		//Start our Test
		Test.startTest();

		//We want our callout to be sent
		HTTPService.sendCalloutInUnitTest = true;

		//Grab our Contact Product Lead
		Product_Lead__c brian2 = [SELECT Id, Name, Stage__c, Action__c, Contact__c, Reset__c FROM Product_Lead__c WHERE Contact__r.Location__c = 'TestClass @@@'];

		//Update our Product Lead so it triggers the Marketo Callout
		brian2.Reset__c = true;
		update brian2;

		//Stop our Test
		Test.stopTest();

		//Grab our Product Lead for verification
		Product_Lead__c brian3 = [SELECT Id, Name, Stage__c, Action__c, Contact__c, Reset__c FROM Product_Lead__c WHERE Contact__r.Location__c = 'TestClass @@@'];

		//System.assertEquals(false, brian3.Reset__c);

	}

	/**
     * @description: Single HttpCalloutMock which we'll use with the testMultipleCallout class
    **/

	public class SingleRequestMock implements HttpCalloutMock {

		public Integer code;
		public String status;
		public String bodyAsString;
		public Map<String, String> responseHeaders;

		public SingleRequestMock(Integer code, String status, String body,
                                         Map<String, String> responseHeaders) {
			this.code = code;
			this.status = status;
			this.bodyAsString = body;
			this.responseHeaders = responseHeaders;
		}

	    public HTTPResponse respond(HTTPRequest req) {
	        HttpResponse resp = new HttpResponse();
			resp.setStatusCode(code);
			resp.setStatus(status);
			resp.setBody(bodyAsString);

			if (responseHeaders != null) {
			     for (String key : responseHeaders.keySet()) {
				resp.setHeader(key, responseHeaders.get(key));
			     }
			}
			return resp;
	    }
	}
	
}