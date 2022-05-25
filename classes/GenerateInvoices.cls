/**
*  Purpose		:	Controller class for "Generate Invoices" list view button based VF page on Sales Invoice object.
*
*  Create By    :   Abhinav Sharma - 02/26/2020 - CR-20200224-13795
*  
*  Revision Log	:  v1.0 -  Created 
*
**/
public with sharing class GenerateInvoices 
{
    private ApexPages.StandardSetController standardController;
    public String listFilterId {get; set;}
    public String buttonLabel {get;set;}
    public Boolean isCompleteLoaded {get; set;}
    
    //constructor
    public GenerateInvoices(ApexPages.StandardSetController stdController)
    {
        this.standardController = stdController; 
        this.listFilterId = standardController.getFilterId();
        isCompleteLoaded = false;
    }
    
    
    public void generateinvoice(){
         isCompleteLoaded = true;
        //Step #1:- Check if current logged in user have the required access
        if(GenerateInvoice.hasRequiredPermissionsValidations())
        {
            List<String> listOfSalesInvoiceId = new List<String>();
            Map<Id,String> mapOfSuccessInvoices = new Map<Id,String>();
            if(standardController.getSelected().size() > 0 )
            {
                List<GenerateInvoiceWrapper> listOfResultsDetailsWrapper = new List<GenerateInvoiceWrapper>();
                Integer i = 1;
                for(c2g__codaInvoice__c salesInvoice : [SELECT Id,Name, Invoice_Contact__c,Content_Document_ID__c,Credit_Manager__c 
                                                        FROM c2g__codaInvoice__c 
                                                        WHERE Id IN : standardController.getSelected()])
                {
                    
                    //Step #2:- Check if on current context record we have all the required fields populated or not
                    if(GenerateInvoice.hasRequiredFieldsValidations(salesInvoice))
                    {
                         //Step #3:- Check if we already have generated invoice
                        if(GenerateInvoice.hasGenerateInvoiceRequestAlreadyProcess(salesInvoice,buttonLabel)){    
                            listOfSalesInvoiceId.add(salesInvoice.Id);
                            mapOfSuccessInvoices.put(salesInvoice.Id,salesInvoice.Name);
                        }
                    }
                    else
                    {
                        system.debug('sales invoice' + salesInvoice.Id);
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, salesInvoice.Name +' : '+ System.Label.InvoiceContactAndCreditManagerRequireError));
                    }
                    i++;
                }
                
                if(listOfSalesInvoiceId.size() > 0)
                {
                    GenerateInvoiceWrapper instanceOfGeInvWrapper = new GenerateInvoiceWrapper();
                    // creating body and xApiKey string
                    instanceOfGeInvWrapper = GenerateInvoice.createBodyStr(listOfSalesInvoiceId);
                    //perform the callout to generate the invoice.
                    instanceOfGeInvWrapper = HTTPCalloutUtilities.makeGenerateInvoiceCalloutForSalesInvoice(instanceOfGeInvWrapper);
                    
                     //Check user receive the response from the  callout 
                    if(instanceOfGeInvWrapper != null && instanceOfGeInvWrapper.httpResponseResult != null) 
                    {
                         //If status code of response is 202 then show the sucess message otherwise error message
                        if(instanceOfGeInvWrapper.httpResponseResult.getStatusCode() == Constants.GENERATE_SALES_INVOICE_CALLOUT_SUCCESS_RESPONSE_STAUTS_CODE)
                        {
                            for(Id invoiceId : mapOfSuccessInvoices.keySet())
                            { 
                                //sucess message
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, mapOfSuccessInvoices.get(invoiceId)+' : '+ System.Label.Generate_Invoice_Api_Invoked_Success_Msg));   
                            }
                        }
                        else 
                        {
                            for(Id invoiceId : mapOfSuccessInvoices.keySet())
                            {
                                //error message
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,mapOfSuccessInvoices.get(invoiceId)+ 'STATUS CODE : ' + instanceOfGeInvWrapper.httpResponseResult.getStatusCode() + ' ' + instanceOfGeInvWrapper.httpResponseResult.getStatus()));
                            }
                        } 
                    }
                }
            }
            else
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.NO_SALES_INVOICE_SELECTED));
            }
        }
        else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.GenerateInvoiceUserAccessErroor));
        }
    }
    
    /**
      * @Description    :   Method to go back to list view on click of button.
      *
      * @args           :   -
      *
      * @return         :   pagereference
      *
    **/
    public pagereference backToListView() 
    {
        return new ApexPages.Action('{!List}').invoke();
        
    }
}