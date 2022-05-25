/**
*  Purpose      :   Controller class for "Email Invoice PDF" to send email to user using detail page button and vf page.
*
*  Create By    :   Abhinav Sharma - 04/03/2020 - CR-20200224-13795
*  
*  Revision Log :   v1.0 -  Created 
* 
**/
public with sharing class EmailSalesInvoicePDFController {
    
	private ApexPages.StandardController standardController;
    private Set<Id> invoiceRecordId;
    private List<Contentversion> listOfInvoiceDoc;
    public c2g__codaInvoice__c salesInvoice;
    public List<Messaging.SingleEmailMessage> listOfemailsend;
    public Boolean isCompleteLoaded {get; set;}
    
   
    //Constructor
    public EmailSalesInvoicePDFController(ApexPages.StandardController stdController){
        this.standardController = stdController;
        invoiceRecordId = new Set<Id>();
        this.salesInvoice = (c2g__codaInvoice__c)standardController.getRecord();
        if(this.salesInvoice != null){
        	invoiceRecordId.add(this.salesInvoice.Id);   
        }
        listOfInvoiceDoc = new  List<Contentversion>();
        isCompleteLoaded = false;
       
    }
    
     /**
      * @Description    :   Method to send email to user and check all criteria are satisfied.
      *
      * @args           :   Set of Id(sales invoice record ids)
      *
      * @return         :   void
      *
    **/
    public void sendInvoiceEmail(){
         isCompleteLoaded = true;
         EmailSalesInvoicesPDFController.sendEmailAndCreateTasks(invoiceRecordId);
    }
    
}