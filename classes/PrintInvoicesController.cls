/**
*  Purpose	:	Controller class for "Print Invoices" list view button based VF page on Sales Invoice object.
*
*  Create By    :   Abhinav Sharma - 02/28/2020 - CR-20200224-13795
*  
*  Revision Log	:  v1.0 -  Created 
* 
**/  
public with sharing class PrintInvoicesController 
{
    private ApexPages.StandardSetController standardController;
    private String contentVersionIds;
    Private Map<c2g__codaInvoice__c,Id> mapOfInvoiceWithVersionId;
    private Map<Id,c2g__codaInvoice__c> mapOfinvoiceToBeUpdate;
    public Boolean showBackButton {get;set;}
    public Boolean isErrorMessage {get;set;}
    
    public PrintInvoicesController(ApexPages.StandardSetController stdController)
    {
        this.standardController = stdController; 
        isErrorMessage = false;
        showBackButton = false;
        
        //Step #1:- Check if current logged in user have the required access
        if(PrintInvoicesController.hasRequiredPermissionsValidations())
        {
            Map<String,c2g__codaInvoice__c> mapOfContentDocumentIdwithInvoice = new Map<String,c2g__codaInvoice__c>();
            mapOfinvoiceToBeUpdate = new Map<Id,c2g__codaInvoice__c>();
            mapOfInvoiceWithVersionId = new Map<c2g__codaInvoice__c,Id>();
            contentVersionIds = '';
            
            //Check user selected any record
            if(standardController.getSelected().size() > 0)
            {
                //Query on sales invoice and store the ContentDocumentId in set
                for(c2g__codaInvoice__c invoice : [SELECT Id, Name, Content_Document_ID__c,Print_Error_Message__c 
                                                   FROM c2g__codaInvoice__c 
                                                   WHERE Id IN: standardController.getSelected()])
                {
                    if(String.isNotBlank(invoice.Content_Document_Id__c))
                    {
                        mapOfContentDocumentIdwithInvoice.put(invoice.Content_Document_Id__c,invoice);
                        if(String.isNotBlank(invoice.Print_Error_Message__c)){
                            invoice.Print_Error_Message__c = '';
                            system.debug('mapOfinvoiceToBeUpdate--0#'+mapOfinvoiceToBeUpdate);
                            if(!mapOfinvoiceToBeUpdate.containsKey(invoice.Id))
                            {
                                 system.debug('mapOfinvoiceToBeUpdate--0#'+mapOfinvoiceToBeUpdate);
                            	 mapOfinvoiceToBeUpdate.put(invoice.Content_Document_Id__c,invoice);    
                            }
                           
                        }
                        else{
                           if(!mapOfinvoiceToBeUpdate.containsKey(invoice.Id))
                            {
                                 system.debug('mapOfinvoiceToBeUpdate--0#'+mapOfinvoiceToBeUpdate);
                            	 mapOfinvoiceToBeUpdate.put(invoice.Content_Document_Id__c,invoice);    
                            } 
                        }
                    }
                    else
                    {
                        isErrorMessage = true;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,invoice.Name 
                                                                   + Constants.SPACE + Constants.COLON + Constants.SPACE
                                                                   + System.Label.NO_CONTENTDOCUMENTID_FOUND_ON_INVOICE));
                        
                        invoice.Print_Error_Message__c = 'Invoice is not downloaded as ContentDocumentId is blank for this Invoice ';
                        system.debug('mapOfinvoiceToBeUpdate--8#'+mapOfinvoiceToBeUpdate);
                        if(!mapOfinvoiceToBeUpdate.containsKey(invoice.Id))
                        {
                            system.debug('mapOfinvoiceToBeUpdate--8#'+mapOfinvoiceToBeUpdate);
                        	mapOfinvoiceToBeUpdate.put(invoice.Content_Document_Id__c,invoice);    
                        }
                        
                    }
                }
                
                //query to get the Contentversion id's
                if(mapOfContentDocumentIdwithInvoice.size() > 0 )
                {    
                    for(Contentversion conVersion : [SELECT Id,contentDocumentId,ContentDocument.title 
                                                     FROM Contentversion 
                                                     WHERE contentDocumentId IN: mapOfContentDocumentIdwithInvoice.keySet() 
                                                     AND islatest = true])
                    {
                        //contentVersionIds += conVersion.Id + Constants.CHAR_BACKSLASH;
                       
                        if(mapOfContentDocumentIdwithInvoice.containsKey(conVersion.contentDocumentId))
                        {
                            isErrorMessage = false;
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, mapOfContentDocumentIdwithInvoice.get(conVersion.contentDocumentId).Name +' : ' + System.Label.SALES_INVOICE_DOWNLOADED_SUCCESSFULLY));   
                            system.debug('mapOfinvoiceToBeUpdate--1'+mapOfinvoiceToBeUpdate);
                            if(mapOfinvoiceToBeUpdate.containsKey(conVersion.contentDocumentId))
                            {
                                system.debug('mapOfinvoiceToBeUpdate--1#'+mapOfinvoiceToBeUpdate);
                                mapOfInvoiceWithVersionId.put(  mapOfinvoiceToBeUpdate.get(conVersion.contentDocumentId),conVersion.Id);
                                mapOfinvoiceToBeUpdate.get(conVersion.contentDocumentId).c2g__PrintStatus__c = 'Printed';
                            }
                                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, mapOfContentDocumentIdwithInvoice.get(conVersion.contentDocumentId) +' : ' + 'Invoice will be download from download button'));  
                        }
                    } 
                    if(mapOfInvoiceWithVersionId.size() < 0)
                    {
                        isErrorMessage = true;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.NO_INVOICE_FOUND));
                    }
                    else
                    {  
                        //contentVersionIds = contentVersionIds.removeEnd(Constants.CHAR_BACKSLASH);
                        isErrorMessage = false;
                    }
                }
                else
                {
                    isErrorMessage = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                                               System.Label.NO_CONTENTDOCUMENTID_FOUND_ON_INVOICE));
                }     
            }
            else
            {
                 isErrorMessage = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                                           System.Label.NO_SALES_INVOICE_SELECTED));
            }
        }
        else
        {
             isErrorMessage = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 
                                                       System.Label.GenerateInvoiceUserAccessErroor));
        }
    }
    
    //method to Download the invoice
    public void updateInvoice() 
    { 
        Set<Id> successId = new Set<ID>();
        try{
            system.debug('mapOfinvoiceToBeUpdate---'+ mapOfinvoiceToBeUpdate);
            if(mapOfinvoiceToBeUpdate.size() > 0 ){
                 showBackButton = true;
                  system.debug(mapOfinvoiceToBeUpdate);
        		  Database.SaveResult[] updateResults  = Database.update(mapOfinvoiceToBeUpdate.values(),false); 
                for (Database.SaveResult sr : updateResults) {
                    if (!sr.isSuccess()) {         
                        for(Database.Error err : sr.getErrors()) {                   
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,''));
                        }
                    }
                    else{   
                        successId.add(sr.getId());
                    }
                }
                if(mapOfInvoiceWithVersionId.size() > 0){
                    for(c2g__codaInvoice__c invoice :  mapOfInvoiceWithVersionId.keySet()){
                        if(successId.Contains(invoice.Id)){
                            contentVersionIds +=  String.valueOf(mapOfInvoiceWithVersionId.get(invoice)) + Constants.CHAR_BACKSLASH;
                             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, invoice.name + ': ' + System.Label.SALES_INVOICE_DOWNLOADED_SUCCESSFULLY));
                        }
                    }
                } 
            }
        }
        catch(DMLException ex){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getDmlMessage(0)));
        }        
        
    }
   
    public PageReference downloadInvoice() 
    {
        if(String.isNotBlank(contentVersionIds)) 
        {  
            contentVersionIds = contentVersionIds.removeEnd(Constants.CHAR_BACKSLASH);
            PageReference target = new PageReference(Constants.INVOICE_DOWNLOAD_URL + contentVersionIds);
            target.setRedirect(false);
            return target;   
        } 
        else{
             showBackButton = false;
             return null;
        }
  
    }
    
    public pagereference backToListView() 
    {
        return new ApexPages.Action('{!List}').invoke();  
    }
    
     public static Boolean hasRequiredPermissionsValidations() 
    {
    	return CoreUtilities.getCompVisibility(System.Label.Print_Invoice_On_Sales_Invoice_Permission_Name);
    }
}