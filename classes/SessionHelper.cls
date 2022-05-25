/**
 * Desription      :   	login and get the session id / server url.  Used with the tooling api.
 * 
 * Created By      :   	Victor Hanson
 * 
 * Created Date    :   	8/25/2015
 * 
 * Revision Logs   :   	V1.0 - Created
 * 		   :	Modified By - Shalu Sharma - 31/08/2021 - CR-20210827-15386 - Salesforce Platform API Versions 21.0 through 30.0 Retirement (Update "services/Soap/u/22.0" to "services/Soap/u/52.0")
 *  
 **/
public class SessionHelper {
    
    private String username { get; set; }
    private String password { get; set; }
    @TestVisible private string resBody { get; set; }
    public string sessionId { get; set; }
    public string serverURL { get; set; }
    
    public SessionHelper() {
        string pw;
        //decrypt the password, but do not attempt to decrypt in unit tests because there is a different key between sandbox/prod and it will fail
        if (!test.isRunningTest()) {
            blob encryptedBlob = EncodingUtil.base64Decode(Label.Tooling_API_Password_Encrypted);
            pw = EncryptionHelper.decrypt(encryptedBlob);
        }
        
        this.username = Label.Tooling_API_Username;
        this.password = pw;
        getSessionId();
        if(this.sessionId==null)
            throw new CustomException('Unable to obtain Session Id');
    }
    
    
    private HttpResponse login() {
        //----------------------------------------------------------------------
        // Login via SOAP/XML web service api to establish session
        //----------------------------------------------------------------------
        HttpRequest request = new HttpRequest();
        //Modified By - Shalu Sharma - 31/08/2021 - CR-20210827-15386 - Salesforce Platform API Versions 21.0 through 30.0 Retirement (Update "services/Soap/u/22.0" to "services/Soap/u/52.0")
        request.setEndpoint('https://' + loginDomain + '.salesforce.com/services/Soap/u/52.0');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', '""');
        request.setTimeout(120000);
        //not escaping username and password because we're setting those variables above
        //in other words, this line "trusts" the lines above
        //if username and password were sourced elsewhere, they'd need to be escaped below
        request.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + username + '</username><password>' + password + '</password></login></Body></Envelope>');
        Http h = new Http();
        return h.send(request);
    }
    
    /**
     * 
     * @description: uses the current users Session Id when in an interactive context.  retreives the session id when using the API in a batch context
     * 
     **/
    public void getSessionId() {
        if (system.isBatch() || system.isFuture() || system.isScheduled()) {
            HttpResponse res = login();
            resBody = res.getBody();
            //handle errors
            string error;
            if (res.getStatusCode() != 200 && res.getStatusCode() != 201 && res.getStatusCode() != 204) {
                error = getErrors();
                
                //if its a login failure - try again, because for some reason it fails sporatically for no reason
                if (res.getStatusCode() == 500) {
                    
                    res = login();
                    resBody = res.getBody();
                    
                    if (res.getStatusCode() != 200 && res.getStatusCode() != 201 && res.getStatusCode() != 204) {
                        throw new CustomException('HTTP Error code:' + res.getStatusCode() + '  Response Body:' + error);
                    }
                }
            }
            
            
            Dom.XmlNode resultElmt;
            
            resultElmt = res.getBodyDocument().getRootElement()
                .getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/')
                .getChildElement('loginResponse','urn:partner.soap.sforce.com')
                .getChildElement('result','urn:partner.soap.sforce.com');
            
            //----------------------------------------------------------------------
            // Grab session id and server url (ie the session)
            //----------------------------------------------------------------------
            serverURL = resultElmt.getChildElement('serverUrl','urn:partner.soap.sforce.com').getText().split('/services')[0];
            sessionId = resultElmt.getChildElement('sessionId','urn:partner.soap.sforce.com').getText();
        }
        else {
            sessionId = UserInfo.getSessionId();
            serverURL = URL.getSalesforceBaseUrl().toExternalForm();
        }
        
    }
    
    public string getErrors() {
        String error;
        if (resBody != null) {
            Dom.Document docx = new Dom.Document();
            docx.load(resBody);
            
            dom.XmlNode xroot = docx.getrootelement() ;
            dom.XmlNode faultNode = xroot.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                .getChildElement('Fault', 'http://schemas.xmlsoap.org/soap/envelope/');
            
            for (dom.XmlNode node : faultNode.getChildElements()) {
                system.debug('@@:' + node.getText() + '-' + node.getNamespace());
            }
            error = faultNode.getChildElement('faultcode', null).getText();
            error += ' - ' + faultNode.getChildElement('faultstring', null).getText();
        }
        return error;
    }
    
    /**
     * 
     * @description: determine whether or not this is a sandbox instance.
     * 
     **/
    public static Boolean isSandbox() {
        return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    /**
     * 
     * @description: if this is running in a sandbox, the login domain is 'test', otherwise, it is 'login'
     * 
     **/
    private String loginDomain {
        get {
            if (loginDomain == null) {
                loginDomain = 'login';
                if (isSandbox()) {
                    loginDomain = 'test';
                }
            }
            return loginDomain;
        }
        set;
    }
}