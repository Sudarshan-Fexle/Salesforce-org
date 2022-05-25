/**
 *  Description     :  Mock class for SpringCM functionality. This class is holding all the mock responses.
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  05/08/2017
 *
 *  Revision Logs   :   V1.0 - Created
 **/
@isTest
global class SpringCMMockResponseGenerator implements HttpCalloutMock {
	
	//Respond method
	global HTTPResponse respond(HTTPRequest req) {
        
		// Create a fake response
		HttpResponse res = new HttpResponse();
	        
		//Check for End Point
		if(req.getEndpoint().contains('/api/v201606/apiuser')) {
			
			// Create a fake response
			res.setHeader('Content-Type', 'application/json');
	        res.setBody('{"access_token":"4f5ae03e11924f98857a23eae3436c151M8qRohOSztr3MILUJV4Jl1ZOO1Am7ulFkKaN6ODlMP4NdoyUBRTTFAPVibCwhmUFHlTBs7Y4RS6W6LvkCpkqaSAj5EpeMQE","token_type":"bearer","expires_in":3597.0,"api_base_url":"https://apina21.springcm.com"}');
	        res.setStatusCode(200);
	        		
		} else if(req.getEndpoint().containsIgnoreCase('/externalreviewtasks')) {
			
			// Create a fake response
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody('{"Sender":{"Href":"https://apina21.springcm.com/v201411/users/b0950751-b51b-e711-80bc-1c98ec21a4ed"},"Documents":{"Items":[{"Href":"https://apina21.springcm.com/v201411/documents/77bdfc78-de33-e711-80ca-ac162d88a264"}],"Offset":0,"Limit":20,"Total":1},"Recipient":{"Name":"Subhash Garhwal","Email":"subhash@simplyforce.com"},"AlsoNotify":[{"Name":"Inbound Email Service","Email":"inboundService@mailinator.com"}],"Status":"Sent","DueDate":"2017-05-10T04:00:00Z","EmailSubject":"Document ready for review","EmailMessage":"test message...","AddSignature":false,"Href":"https://apina21.springcm.com/v201411/externalreviewtasks/7ebdfc78-de33-e711-80ca-ac162d88a264"}');
	        res.setStatusCode(201);
	    } else if(req.getEndpoint().contains('https://apiupload')) {
			
			// Create a fake response
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody('{"Name":"LOA_Q-00300_v014_p (11).pdf","CreatedDate":"2017-05-08T11:07:10.917Z","CreatedBy":"victor.r.hanson@gmail.com","UpdatedDate":"2017-05-08T11:07:10.917Z","UpdatedBy":"victor.r.hanson@gmail.com","Description":"","ParentFolder":{"Href":"https://apina21.springcm.com/v201411/folders/8736ff35-992e-e711-80ca-ac162d88a264"},"HistoryItems":{"Href":"https://apina21.springcm.com/v201411/documents/77bdfc78-de33-e711-80ca-ac162d88a264/historyitems"},"AccessLevel":{"See":true,"Read":true,"Write":true,"Move":true,"Create":true,"SetAccess":true},"PageCount":0,"Lock":{"Href":"https://apina21.springcm.com/v201411/documents/77bdfc78-de33-e711-80ca-ac162d88a264/lock"},"PreviewUrl":"https://na21.springcm.com/atlas/documents/preview.aspx?aid=18453&lduid=77bdfc78-de33-e711-80ca-ac162d88a264","Versions":{"Href":"https://apina21.springcm.com/v201411/documents/77bdfc78-de33-e711-80ca-ac162d88a264/versions"},"ShareLinks":{"Href":"https://apina21.springcm.com/v201411/documents/77bdfc78-de33-e711-80ca-ac162d88a264/sharelinks"},"DocumentProcessTrackingActivities":{"Href":"https://apina21.springcm.com/v201411/documents/77bdfc78-de33-e711-80ca-ac162d88a264/documentprocesstrackingactivities"},"DocumentReminders":{"Href":"https://apina21.springcm.com/v201411/documents/77bdfc78-de33-e711-80ca-ac162d88a264/documentreminders"},"RelatedDocuments":{"Href":"https://apina21.springcm.com/v201411/documents/77bdfc78-de33-e711-80ca-ac162d88a264/relateddocuments"},"DownloadDocumentHref":"https://apidownloadna21.springcm.com/v201411/documents/77bdfc78-de33-e711-80ca-ac162d88a264","NativeFileSize":255536,"PdfFileSize":255536,"Href":"https://apina21.springcm.com/v201411/documents/77bdfc78-de33-e711-80ca-ac162d88a264"}');
	        res.setStatusCode(201);
	    
		} else if(req.getEndpoint().containsIgnoreCase('/workflows')) {
			
			// Create a fake response
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody('{"Sender":{"Href":"https://apina21.springcm.com/v201411/users/b0950751-b51b-e711-80bc-1c98ec21a4ed"},"Documents":{"Items":[{"Href":"https://apina21.springcm.com/v201411/documents/77bdfc78-de33-e711-80ca-ac162d88a264"}],"Offset":0,"Limit":20,"Total":1},"Recipient":{"Name":"Subhash Garhwal","Email":"subhash@simplyforce.com"},"AlsoNotify":[{"Name":"Inbound Email Service","Email":"inboundService@mailinator.com"}],"Status":"Sent","DueDate":"2017-05-10T04:00:00Z","EmailSubject":"Document ready for review","EmailMessage":"test message...","AddSignature":false,"Href":"https://apina21.springcm.com/v201411/externalreviewtasks/7ebdfc78-de33-e711-80ca-ac162d88a264"}');
	        res.setStatusCode(201);
	    } else {
			
			// Create a fake response
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody('{"Sender":{"Href":"https://apina21.springcm.com/v201411/users/b0950751-b51b-e711-80bc-1c98ec21a4ed"},"Documents":{"Items":[{"Href":"https://apina21.springcm.com/v201411/documents/77bdfc78-de33-e711-80ca-ac162d88a264"}],"Offset":0,"Limit":20,"Total":1},"Recipient":{"Name":"Subhash Garhwal","Email":"subhash@simplyforce.com"},"AlsoNotify":[{"Name":"Inbound Email Service","Email":"inboundService@mailinator.com"}],"Status":"Sent","DueDate":"2017-05-10T04:00:00Z","EmailSubject":"Document ready for review","EmailMessage":"test message...","AddSignature":false,"Href":"https://apina21.springcm.com/v201411/externalreviewtasks/7ebdfc78-de33-e711-80ca-ac162d88a264"}');
	        res.setStatusCode(201);
	    }
	    
	    //Return response
	    return res;
	}
}