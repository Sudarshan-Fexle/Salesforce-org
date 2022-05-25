/** 
* Description   :   Class validate connection and return the error if any - OneClick Deploy
*
* Created By    :   Rajeev Jain(Simplyforce)
*
* Created Date  :   02/27/2018
*
* Version       :   V1.0 Created
*                   
**/
public class ValidateConnection {
    
    //List to store Org Connector Config custom setting data
    List<Org_Connector_Config__c> orgConnectorConfig ;
    
    //String hold the error messages
    public String validationMsg{get;set;}
    
    //Constructor
    public ValidateConnection() {
        
        //Initialization
        validationMsg = '';
    }
    
    /**
     * @Description :	Method for validating the connection
     * 
     * @Modifcation	:	Added By - Rajeev Jain - 02/27/2018
     * 
     * @args		:	
     * 
     * @Return		:	Void
     * */
    public String getAndParse(DeploymentWizardBean appProperties) {
        
        //Try-Catch block
        try {
            
            //Query on custom setting to get connection parameters
            orgConnectorConfig = [Select Base_URL_Login__c, Base_URL_Test__c, Consumer_Key__c, Client_Secret_Key__c, Oath_Token_Url__c from Org_Connector_Config__c Limit 1];
            
            String CLIENTID = orgConnectorConfig[0].Consumer_Key__c;
            String CLIENTSECRET = orgConnectorConfig[0].Client_Secret_Key__c;
            String OAUTHTOKENURL = orgConnectorConfig[0].Oath_Token_Url__c;
            
            //Checking if the variables are not blank
            if(String.isNotBlank(appProperties.selectedSourceCon)) {
                
                DeploymentWizardConstants.CONNECTION_FILTER += ' Or Name =\''+appProperties.selectedSourceCon+'\'';
            }
            if(String.isNotBlank(appProperties.selectedTargetCon)) {
                
                DeploymentWizardConstants.CONNECTION_FILTER += ' Or Name =\''+appProperties.selectedTargetCon+'\'';
            }
            
            DeploymentWizardConstants.CONNECTION_SOQL = DeploymentWizardConstants.CONNECTION_SOQL + DeploymentWizardConstants.CONNECTION_FILTER;
            
            String urlParameters = '';
            
            if(appProperties.selectedSourceCon == appProperties.selectedTargetCon) {
                validationMsg = 'Source and target org can not be same';
                return validationMsg;
            }
            
            //Looping over the list
            for(Connection__c connect : Database.query(DeploymentWizardConstants.CONNECTION_SOQL)) {
                
                //Boolean variable to check if connected app exists or not
                Boolean isConnectedApp = true;
                urlParameters = '';
                
                //Checking the org type and changing the endpoint accordingly
                if(connect.Org_type__c.containsIgnoreCase('Production'))
                    urlParameters = orgConnectorConfig[0].Base_URL_Login__c+'/services/oauth2/token?grant_type=refresh_token&refresh_token=' + connect.Refresh_Token__c + '&client_id=' + clientId + '&client_secret=' + clientSecret;
                else if(connect.Org_type__c.containsIgnoreCase('Sandbox'))
                    urlParameters = orgConnectorConfig[0].Base_URL_Test__c+'/services/oauth2/token?grant_type=refresh_token&refresh_token=' + connect.Refresh_Token__c + '&client_id=' + clientId + '&client_secret=' + clientSecret;
                
                // Get the XML document from the external server
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(urlParameters);
                req.setMethod('GET');
                HttpResponse res = null;

                    res = http.send(req);
                
                if(res != null) {
                    
                    JsonParser parser =  JSON.createParser(res.getBody());
                    
                    while (parser.nextToken() != null) {
                        
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                            
                            // Get the value.
                            parser.nextToken();
                            //validationMsg += '\n'+connect.Name+' = >Access token exists.  \n';
                        }
                        else if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'error_description')) {
                            
                            // Get the value.
                            parser.nextToken();
                            if(parser.getText() == 'expired access/refresh token') {
                                validationMsg += '\n'+connect.Name+' = >Refresh token expired.  \n';
                            }
                            else if(connect.Name != 'Self Connection') {
                                validationMsg += '\n Connected App not found for '+connect.Name+' external connections \n';
                                isConnectedApp = false;
                                break;
                            }
                        }
                    }
                }
                
                if(!isConnectedApp)
                    break;
            }
            
            return validationMsg;
        }
        catch(Exception ex) {
            return 'Fail';
            
        }
        // return '';
    }
    
}