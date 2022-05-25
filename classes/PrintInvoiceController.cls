/**
*  Purpose		:	Controller class for "Print Invoice" detail page button based VF page on Sales Invoice object.
*
*  Create By    :   Abhinav Sharma - 02/26/2020 - CR-20200224-13795
*  
*  Revision Log	:  v1.0 -  Created
* 
**/
public with sharing class PrintInvoiceController 
{   
    public Boolean isDownloadInvoice {get;set;}
    
    private ApexPages.StandardController standardController;
    private c2g__codaInvoice__c salesInvoice;
    private List<Contentversion> listOfInvoiceDoc;
    private List<c2g__codaInvoice__c> salesInvoiceTobeUpdate;
    
    public PrintInvoiceController(ApexPages.StandardController stdController)
    {
        this.standardController = stdController;
        this.salesInvoice = (c2g__codaInvoice__c)stdController.getRecord();
        isDownloadInvoice = false; 
        listOfInvoiceDoc = new  List<Contentversion>();
        salesInvoiceTobeUpdate = new List<c2g__codaInvoice__c>();
        
        system.debug('this.salesInvoice--'+this.salesInvoice);
        
        //Step #1:- Check if current logged in user have the required access
        if(PrintInvoiceController.hasRequiredPermissionsValidations())
        {
            if(this.salesInvoice != null)
            {   
                c2g__codaInvoice__c invoiceToBeUpsert = new c2g__codaInvoice__c();
                if(String.isNotBlank(this.salesInvoice.Content_Document_Id__c))
                {    
                    listOfInvoiceDoc  = [SELECT Id, contentDocumentId, ContentDocument.title 
                                         FROM Contentversion 
                                         WHERE contentDocumentId =: this.salesInvoice.Content_Document_Id__c 
                                         AND islatest = true];   
                    
                    if(listOfInvoiceDoc.size() > 0)
                    { 
                        isDownloadInvoice = true;
                        invoiceToBeUpsert.c2g__PrintStatus__c = 'Printed';
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, System.Label.SALES_INVOICE_DOWNLOADED_SUCCESSFULLY));
                    }
                    else
                    {
                        invoiceToBeUpsert.Print_Error_Message__c = System.Label.NO_INVOICE_FOUND;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.NO_INVOICE_FOUND));
                        isDownloadInvoice = false;
                    } 
                }
                else
                {   
                    invoiceToBeUpsert.Print_Error_Message__c = System.Label.NO_CONTENTDOCUMENTID_FOUND_ON_INVOICE;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.NO_CONTENTDOCUMENTID_FOUND_ON_INVOICE));
                }
                invoiceToBeUpsert.Id =  this.salesInvoice.id;
                salesInvoiceTobeUpdate.add(invoiceToBeUpsert);
            } 
            else 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.UNABLE_TO_ACCESS_SALES_INVOICE));    
            }
        }
        else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.GenerateInvoiceUserAccessErroor));
        }
        
    }
    
    //method to Download the invoice
    public PageReference downloadInvoice() 
    {
         try{
            if(salesInvoiceTobeUpdate.size() > 0 ){
                Util.BypassAllTriggers = true;
                
        		upsert salesInvoiceTobeUpdate;
               
                if(listOfInvoiceDoc != null && listOfInvoiceDoc.size() > 0 && isDownloadInvoice == true) 
                {  
                    PageReference target = new PageReference(Constants.INVOICE_DOWNLOAD_URL + listOfInvoiceDoc[0].Id);
                    target.setRedirect(true);
                    return target;
                }
           }
        }
        catch(DMLException ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getDmlMessage(0)));
        }  
        
        return null;
    }
    
     public static Boolean hasRequiredPermissionsValidations() 
    {
    	return CoreUtilities.getCompVisibility(System.Label.Print_Invoice_On_Sales_Invoice_Permission_Name);
    }
 
}