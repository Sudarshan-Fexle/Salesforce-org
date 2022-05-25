/*
Project Name : EAB Compass Community
Created By: Ayush Gupta
Created Date: 30-June-2021
Last Modifed Date: 30-June-2021
Description: 1) A visual force page to show a success message. User will redirect to this page once a request is approved.          
*/

public class CompassSuccessController {
	
	public String MessageToDisplay {get;set;}
	
	public CompassSuccessController(){
		
		if(apexpages.currentpage().getparameters().get('UserCreated')=='Yes') {
		
			MessageToDisplay = 'Thank you for your request.  Your user account has been created.  You will receive a Welcome Email ' +
			                   'providing you with details on how to access the Compass client community.';
		
		} else {
		
			MessageToDisplay = 'Thank you for your request. Our Compass team reviews requests during regular business hours and strives ' +
			                   'to approve new requests within 24 hours. When your request is approved, you will receive a welcome email ' +
			                   'providing you with details on how to access the Compass client community.<br/><br/>' +
			                   'If you have an urgent product support need, you may also reach out to our client solutions team via ' +
			                   'email (clientsupport@hobsons.com) or by phone (888.517.6460).';

		}
	
	}

    public PageReference RedirectUser() {
    	
    	PageReference pr = new PageReference('/Signin');
        return pr;
    }

}