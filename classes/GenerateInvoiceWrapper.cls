public without sharing class GenerateInvoiceWrapper 
{
    public integer rowNo {get; set;}
    public String messageDetails {get; set;}
    public c2g__codaInvoice__c sInvoice {get; set;}
    
    public String bodyStr {get; set;}
    public String xApiKey {get; set;}
    public Boolean isValidateSucess {get;set;}
    public HttpResponse httpResponseResult {get;set;}
    
    // for print invoice
    public ContentDocumentLink invoiceDocumentRecord {get; set;}
    
    
    public GenerateInvoiceWrapper() 
    {
        messageDetails = '';
        sInvoice = new c2g__codaInvoice__c();
        bodyStr = '';
        xApiKey = '';
        isValidateSucess =false;
        invoiceDocumentRecord = new ContentDocumentLink();
    }
}