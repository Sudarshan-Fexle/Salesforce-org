/**
 *   Purpose        : EAB Compass Community
                      User will enter the user name prefix and password to get entered in community
             	      1) Forgot password functionality will let you to the new visual force page.
             	      2) New user functionality will redirect you to new self registration page.
             	      3) Contact us page will redirect user to hobsons contact us page.    
 *
 *   Created By     :  Ayush Gupta
 *
 *   Created Date   :  10-May-2021
 *
 *   Current Version:  V1.0
 *
 *   Revision Log   :  
 * 
**/
public class SignInController {

	public String username {get; set;}
	public String password {get; set;}
	public string errorMsg {get;set;}

	public SignInController(){}

	public pagereference SignIn() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        
		string userNameForLogin = username + '@eab.community.com';
		
        PageReference pr = Site.login(userNameForLogin, password, startUrl); 
        
        if (pr == null) {
        	//  apexpages.addmessage(new apexpages.message(apexpages.severity.error,'Error occured'));
         	errorMsg = 'Username or password does not match. Please try again';
         	return null;
         	
        } else {
        	
        	return Site.login(userNameForLogin, password, startUrl);
        } 
        
    }
     

}