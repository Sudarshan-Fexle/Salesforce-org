/**
* Description   :   Class to act as controller for CreateOrgConnection
*
* Created By    :   Ishan Arora
*
* Created Date  :   21/02/2018
*
* Version       :   V1.0 Created
*             
**/ 
public class CreateOrgConnectionController{
    
    //Controller Properties
    //Variable to hold the Types of connection like Self Or External
    public String connectionType{get;set;}
    //Variable to store connection Name
    public String connectionName{get; set;}
    //Variable to store Org Type
    public String orgType{get; set;}
    // List of connection object to store sourse connection Data
    public List<Connection__c> source ;
    //List to store Org Connector Config custom setting data
    public List<Org_Connector_Config__c> orgConnectorConfig ;
    //List to store Org Connector Config validation custom setting data
    public List<Org_Connector_Config_Validation__c> orgConnectorConfigValidation ;
    //Flag for errors
    Boolean check ;
    
    // Class Constructor (Standard)
    public CreateOrgConnectionController(ApexPages.StandardController stdController){
        
        //Query on custom setting to get connection parameters
        orgConnectorConfig = [Select Base_URL_Login__c,Base_URL_Test__c,Connection_Type_Self__c, Client_Id_URL__c, Consumer_Key__c, Login_Hint__c, 
                              OAuth_URL__c,OrgType_Production_developer__c, Prompt_Encoded__c, Redirect_URI__c, Redirect_URL__c,Self_Connection__c,State_URI__c 
                              from Org_Connector_Config__c Limit 1];
        
        //Query on custom setting to get validations
        orgConnectorConfigValidation = [Select Duplicate_Local_Connection__c ,Duplicate_External_Connection__c , Invalid_Connection_Name__c,
                                        Local_Connection_Absent__c, OrgType_Not_Selected__c, Username_length_error__c  
                                        from Org_Connector_Config_Validation__c Limit 1];       
    }
    
    /*  @description    :  Meathod to send request to connected app with  connection parametersto connected app 
	*
	*  @args           	:  none
	*
	*  @return         	:   void
	*
	**/
    public PageReference createConnection() {
        //Set flag true
         check=true;
        //Validate connections instructions
        validations();
        //check if no errors occur in validations
        if(check==true){
            
            //Check if connection type is self connection
            If((source.size() > 0 && source != null )|| connectionName == orgConnectorConfig[0].Self_Connection__c){
                
                String state = null;
                //Check if connection type is external
                If(source.size() > 0 && source != null ){
                    state =  connectionName + '|' +orgType+'|' + source[0].Refresh_Token__c + '|' + source[0].Instance_URL__c + '|'+ source[0].Org_type__c  ;
                }
                else{
                    //Id locasl connection
                    state =  connectionName + '|' +orgType;   
                }
                
                //Encode state parameter
                String stateEncoded = EncodingUtil.urlEncode(state+'|', 'UTF-8');
                
                //String to hold base url
                String baseUrl ='';
                
                //String to add local connection login id at login page
                String loginHint = '&'+ orgConnectorConfig[0].Login_Hint__c + EncodingUtil.urlEncode(UserInfo.getUserName(), 'UTF-8');
                
                //String to hold redirection url
                String oauthUrl ='';
                
                //Check if type is production
                if(orgType == orgConnectorConfig[0].OrgType_Production_developer__c   ){
                    
                    baseUrl = orgConnectorConfig[0].Base_URL_Login__c;
                }
                else{
                    //If org type is sandbox
                    baseUrl = orgConnectorConfig[0].Base_URL_Test__c;
                }
                
                //Check if local connection
                if( connectionName == orgConnectorConfig[0].Self_Connection__c){
                    oauthUrl = baseUrl + orgConnectorConfig[0].OAuth_URL__c +'?'+ orgConnectorConfig[0].Prompt_Encoded__c+
                        '&'+orgConnectorConfig[0].Client_Id_URL__c + orgConnectorConfig[0].Consumer_Key__c + 
                        '&'+ orgConnectorConfig[0].Redirect_URI__c + orgConnectorConfig[0].Redirect_URL__c   + '&'+ orgConnectorConfig[0].State_URI__c+ stateEncoded;
                }
                else{
                    //If external connection
                    oauthUrl = baseUrl + orgConnectorConfig[0].OAuth_URL__c +'?'+ orgConnectorConfig[0].Prompt_Encoded__c+
                        '&'+orgConnectorConfig[0].Client_Id_URL__c + orgConnectorConfig[0].Consumer_Key__c + 
                        '&'+ orgConnectorConfig[0].Redirect_URI__c + orgConnectorConfig[0].Redirect_URL__c +
                        '&'+ orgConnectorConfig[0].State_URI__c+ stateEncoded;
                }
                
                System.debug('url - '+oauthUrl);
                //Redirect 
                PageReference pageRef = new PageReference(oauthUrl);
                pageRef.setRedirect(true);
                return pageRef;
                
            }
            else{
                
                //If local connection is not present
                // Error
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,''+orgConnectorConfigValidation[0].Local_Connection_Absent__c));
                return null ;
                
            }
        }else{
            return null;
        }
    }
    
    /*  @description    :  Meathod to apply validations on create connection org page
	*
	*  @args           	:  none
	*
	*  @return         	:   void
	*
	**/
    public void validations(){
        
          //Check if org type is not selected
        if(orgType == null || orgType ==''){
            //Error
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,''+orgConnectorConfigValidation[0].OrgType_Not_Selected__c));
           check = false;
        }
        //Check if external connections is empty 
        if(connectionName == '' || connectionName == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,''+orgConnectorConfigValidation[0].Invalid_Connection_Name__c));
            check = false;
        }
        //Check if coonnection name is to long
        if(connectionName.length() > 60){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,''+orgConnectorConfigValidation[0].Username_length_error__c));
           check = false; 
        }
        
        //Check if connection type is Self
        if( connectionType == orgConnectorConfig[0].Connection_Type_Self__c){
            
            connectionName = orgConnectorConfig[0].Self_Connection__c;
            //Set connection name as self connection   
        }else{
            
            //Query on connection name to check if connection name already exist
            List<Connection__c> connectionData = [Select Id from Connection__c where Name=:connectionName];
            
            //Case to check if connection name already exists 
            if(connectionData.size() > 0){
                //Error
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,''+ orgConnectorConfigValidation[0].Duplicate_External_Connection__c));
                check = false;
            }
        }
        
        //Query to find if local connection already exists
        source = [Select Access_Token__c, Refresh_Token__c , Instance_URL__c, Org_type__c from Connection__c where Name =:orgConnectorConfig[0].Self_Connection__c Limit 1];
		//Local connection already exists
        if((connectionName == orgConnectorConfig[0].Self_Connection__c && source.size() > 0 ) )  {
            // Error
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,''+orgConnectorConfigValidation[0].Duplicate_Local_Connection__c));
            check = false;
        }
        
    }
}