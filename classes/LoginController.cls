/**
 * An apex page controller that exposes the site login functionality
 * Example based on: https://appirio.com/category/tech-blog/2013/10/create-custom-salesforce-communities-login-landing-page/
*/
global class LoginController{

    global String username {get;set;}
    global String password {get;set;}
    
    global LoginController () {}
    
    global PageReference forwardToSampleAuthPage() {
        return Page.Login_PTCommunity;
    }
    
    global PageReference login() {
        return Site.login(username, password, null);
    }
}