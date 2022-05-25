/**
* Purpose : Mock Http class for GenerateInvoice
*
* Create By : Dipesh Gupta
*
* Created Date : 03/04/2019
*
* Revision Log : V_1.0 - Created - Dipesh Gupta
*
* Coverage : V_1.0 -
*
**/
@isTest
global class MockHttpResponseGenerateInvoice implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req){
        
        
        List<String> invoiceId = new List<string>();
        invoiceId.add('a1bC0000003Zs3ZIAS');
        String accessToken = UserInfo.getSessionId();
        String instanceURL = 'https://'+ URL.getSalesforceBaseUrl().getHost();
        
        Boolean isProduction = Util.IS_PRODUCTION_INSTANCE;
        String id_param = '';
        if(isProduction)
        {
            id_param = Constants.PRODUCTION_URL_INSTANCE +'/'+ System.Label.Id_Param_Url_Substring +'/'+ UserInfo.getOrganizationId()+'/'+UserInfo.getUserId();
        }
        else
        {
            id_param = Constants.SANDBOX_URL_INSTANCE +'/'+ System.Label.Id_Param_Url_Substring +'/'+UserInfo.getOrganizationId()+'/'+UserInfo.getUserId();
        }
        
        String xApiKey = '{"' + Constants.ACCESS_TOKEN + '": "' + accessToken + '",'
            + '"' + Constants.INSTANCEURL + '": "' + instanceURL + '",'
            + '"' + Constants.ID_PARAMETER + '": "' + id_param
            +'"}';
        
        String bodyStr = '["';
        bodyStr += CoreUtilities.quotedString(invoiceId, Constants.COMMA);
        bodyStr += '"]';
        
        HttpResponse res = new HttpResponse();
        res.setHeader(Constants.CONTENT_TYPE, Constants.CONTENT_TYPE_APP_JSON);
        res.setHeader(Constants.ACCEPT, Constants.CONTENT_TYPE_APP_JSON);
        res.setHeader(Constants.X_API_KEY,xApiKey);
        res.setBody(bodyStr);
        return res;
    }

}