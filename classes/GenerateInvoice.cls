/**
*  Purpose      :   Controller class for "Generate Invoice or Rebuilt Invoice" detail page button based VF page on Sales Invoice object.
*
*  Create By    :   Abhinav Sharma - 02/26/2020 - CR-20200224-13795
*  
*  Revision Log :  V1.0 - Created
*		:  V1.1 - Modified By - Mahendra Swarnkar - CR-20210512-15138 - Updated the Instance IUL so that it should reference the respective environment (SB/Production).
* 
**/
public with sharing class GenerateInvoice 
{
    private ApexPages.StandardController standardController;
    public c2g__codaInvoice__c salesInvoice;
    public Boolean isCompleteLoaded {get; set;}
    public String buttonLabel = '';
    
    public GenerateInvoice(ApexPages.StandardController stdController)
    {
        this.standardController = stdController;
        this.salesInvoice = (c2g__codaInvoice__c)standardController.getRecord();
        buttonLabel = apexpages.currentpage().getparameters().get('buttonLabel');
        isCompleteLoaded = false;
    }
    
    
    public void performTasks() {
        
        //Step #1:- Check if current logged in user have the sales invoice custom permission
        if(GenerateInvoice.hasRequiredPermissionsValidations())
        {
            //Step #2:- Check if on current context record we have all the required fields populated or not
            if(GenerateInvoice.hasRequiredFieldsValidations(this.salesInvoice))
            {
                //Step #3:- Check if we already have generated invoice
                if(GenerateInvoice.hasGenerateInvoiceRequestAlreadyProcess(this.salesInvoice,buttonLabel))
                {
                  try 
                    {
                        List<String> listOfSalesInvoiceId = new List<String>();
                        listOfSalesInvoiceId.add(this.salesInvoice.Id);
                        
                        GenerateInvoiceWrapper instanceOfGeInvWrapper = new GenerateInvoiceWrapper();
                        
                        // creating body and xApiKey string
                        instanceOfGeInvWrapper = createBodyStr(listOfSalesInvoiceId);
                        
                        
                        //perform the callout to generate the invoice.
                        instanceOfGeInvWrapper = HTTPCalloutUtilities.makeGenerateInvoiceCalloutForSalesInvoice(instanceOfGeInvWrapper);
                        
                        //Check user receive the response from the  callout 
                        if(instanceOfGeInvWrapper != null && instanceOfGeInvWrapper.httpResponseResult != null) 
                        {
                            //If status code of response is 202 then show the sucess message otherwise error message
                            if(instanceOfGeInvWrapper.httpResponseResult.getStatusCode() == Constants.GENERATE_SALES_INVOICE_CALLOUT_SUCCESS_RESPONSE_STAUTS_CODE)
                            {
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, System.Label.Generate_Invoice_Api_Invoked_Success_Msg));
                            }
                            else 
                            {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Constants.STATUS_CODE +' '+ instanceOfGeInvWrapper.httpResponseResult.getStatusCode() + ' ' + instanceOfGeInvWrapper.httpResponseResult.getStatus()));
                            } 
                        }
                    }
                    catch(Exception ex) 
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Constants.ERROR_LINE + ex.getLineNumber() + Constants.DETAILS +' ' + ex.getMessage()));
                    }
                }
            }
            else
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.InvoiceContactAndCreditManagerRequireError));
            }
        }
        else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.GenerateInvoiceUserAccessErroor));
        }
        
        isCompleteLoaded = true;
    }
    
    public static Boolean hasRequiredPermissionsValidations() 
    {
        return CoreUtilities.getCompVisibility(System.Label.Generate_Invoice_On_Sales_Invoice_Permission_Name);
    }
    
    public static Boolean hasRequiredFieldsValidations(c2g__codaInvoice__c cI) 
    {
        return (cI != null && (String.isNotBlank(cI.Invoice_Contact__c) && String.isNotBlank(cI.Credit_Manager__c)) ? true : false);
    }
    
    public static Boolean hasGenerateInvoiceRequestAlreadyProcess(c2g__codaInvoice__c salesinvoice,String buttonLabel) 
    {
 
        if(buttonLabel == 'GenerateInvoice'){
           
        	if(String.isBlank(salesinvoice.Content_Document_ID__c)){
            	 return true;      
            } 
            else{ 
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,  salesinvoice.Name +' : '+System.Label.REGENERATE_INVOICE)); 
            	 return false; 
            }
        }
        else if(buttonLabel == 'RebuiltInvoice'){
        	if(String.isNotBlank(salesinvoice.Content_Document_ID__c)){
            	 return true;      
            } 
            else{ 
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, salesinvoice.Name +' : '+System.Label.GENERATE_INVOICE_FIRST_TIME));
           		return false; 
           }    
        }      
        else{
            return false;   
        }   
    }
    
    /**
      * @Description    :   Method to creating body string and xapikey string.
      *
      * @args           :   list of String (sales invoice recod ids)
      *
      * @return         :   GenerateInvoiceWrapper
      *
    **/
    public static GenerateInvoiceWrapper createBodyStr(List<String> listOfSalesInvoiceId)
    {
        GenerateInvoiceWrapper gIinvoiceWrapperInstance = new GenerateInvoiceWrapper();
        
        String accessToken = UserInfo.getSessionId();
        
        //String instanceURL = 'https://'+ URL.getSalesforceBaseUrl().getHost();
       
        //Modified By Mahendra Swarnkar - CR-20210512-15138 - Updated the Instance IUL so that it should reference the respective environment (SB/Production).
        //String instanceURL = System.Label.Generate_Invoice_Instance_URL;
        String instanceURL = System.URL.getSalesforceBaseURL().toExternalForm();
        
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
        
        String xApiKey = '{"' + 'accesstoken' + '": "' + accessToken + '",'
            + '"' + Constants.INSTANCEURL + '": "' + instanceURL + '",'
            + '"' + Constants.ID_PARAMETER + '": "' + id_param
            +'"}';
     
        String bodyStr ='[';      
        bodyStr += CoreUtilities.quotedAndCommaSepratedString(listOfSalesInvoiceId, Constants.COMMA);
        bodyStr += ']';
        
        gIinvoiceWrapperInstance.bodyStr = bodyStr;
        gIinvoiceWrapperInstance.xApiKey = xApiKey;
       
        return gIinvoiceWrapperInstance;
        
    }
}