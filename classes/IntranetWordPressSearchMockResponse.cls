/** Description		:	Mock test class to hold fake response for Portal search on Wordpress based system from IntranetSearch page
  * 
  * Created Date	:	06/18/2015
  *
  * Created By		:   Rajeev Jain(Simplyforce)
  *  
  * Current vision	:	v1.0
  *  
  * Revision Logs	:	v1.0 - Created - For - CR-20141002-7579 - To improve code coverage of IntranetSearchController class.
  **/
@isTest
global class IntranetWordPressSearchMockResponse implements HttpCalloutMock{
	
    public Static String portalSearchTerm;
    
    //Implement the interface method   
    global HTTPResponse respond(HTTPRequest req) {
    	
        // Optionally, only send a mock response for a specific endpoint
        HttpResponse response = new HttpResponse();
        
        response.setHeader('Content-Type', 'application/json');
        
        String portalSearchUrl = IntranetWordpressSearch.PortalSearchUrl + EncodingUtil.urlEncode(portalSearchTerm, 'UTF-8');
        if(req.getEndpoint() == portalSearchUrl){
            
            String responseBody = '[{'
                                 + '"post-title":"Advisory Board Credit Card Frequently Asked Questions",'
                                 + '"permalink":"https://portals.advisory.com/travel?post_type=page&p=2320",'
                                 + '"post-content":"[title] Advisory Board Credit Card Frequently Asked Questions [/title] [toggle title=What does direct bill payment mean?]The firm will send the payment to the card provider directly based on approved expense report submissions and you will no longer have to worry about sending in a card payment. Under our new program once you submit expenses.",'
                                 + '"site":"Travel"'
                                 + '},'
                                 + '{'
                                 + '"post-title":"Advisory Board Credit Card",'
                                 + '"permalink":"https://portals.advisory.com/travel?post_type=page&p=2001",'
                                 + '"post-content":"Expense System Procedures All employees who travel for business or have regular business expenses are required to sign up for an Advisory Board Credit Card. All work related expenses must be billed to this credit card. Using this credit card reduces administrative costs for the Advisory Board, speeds up the reimbursement process, and ensures that.",'
                                 + '"site":"Travel"'
                                 + '},'
                                 + '{'
                                 + '"post-title":"Advisory.com",'
                                 + '"permalink":"https://portals.advisory.com/dss?post_type=page&p=3645",'
                                 + '"post-content":"Branding is equally as important a consideration for web-based communications as for print. As digital communication continues to expand, The Advisory Board Company applies the same standards for disciplined use of brand marks on the web as it does for print materials. The web requires its own standards for look and feel, navigation, and organization",'
                                 + '"site":"DSS"'
                                 + '}]';
            response.setBody(responseBody);
            response.setStatusCode(200);
        }else{
        	
            response.setBody('No valid request');
            response.setStatusCode(400);
        }
        
        return response;
    }
}