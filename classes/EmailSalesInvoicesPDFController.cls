/**
*  Purpose      :   Controller class for "Email Invoice PDF" to send emails to user using list view button and vf page.
*
*  Create By    :   Abhinav Sharma - 04/06/2020 - CR-20200224-13795
*  
*  Revision Log :   V_1.0 -  Created
                    V_1.1 - Modified By Abhinav Sharma - CR-20200617-14202
		    V_1.2 - Modified By - Colin McGloin - CR-20200715-14316
		    V_1.3 - Modified By - Mahendra Swarnakar - CR-20211112-15581 - Updated method sendEmailAndCreateTasks - Added necessary checks in conditions and Queries
* 
**/
public with sharing class EmailSalesInvoicesPDFController 
{
    private ApexPages.StandardSetController standardController;
    private Set<Id> selectedRecordIds;
    public String listFilterId {get; set;}
    //public static boolean isCompleteLoaded {get;set;}
    public static transient List<Messaging.SingleEmailMessage> listOfemailsend; 
    
    //constructor
    public EmailSalesInvoicesPDFController(ApexPages.StandardSetController stdController)
    {
        this.standardController = stdController; 
        this.listFilterId = standardController.getFilterId();
        selectedRecordIds = new Set<Id>();
        //isCompleteLoaded = false;
        for(c2g__codaInvoice__c invoice : (List<c2g__codaInvoice__c>)standardController.getSelected())
        {
            selectedRecordIds.add(invoice.Id);
        } 
    }
    
    public void sendsalesInvoiceEmail()
    {
        sendEmailAndCreateTasks(selectedRecordIds);
    }
    
    /**
    * @Description    :   Method to send email to user and check all criteria are satisfied.
    *
    * @args           :   Set of Id(sales invoice record ids)
    *
    * @return         :   void
    * 
    * @Revision Log   :   Modified By - Mahendra Swarnkar - CR-20211112-15581 - 11/29/2021 - Updated method sendEmailAndCreateTasks - Added necessary checks in conditions and Queries
    *
    **/
    public static void sendEmailAndCreateTasks(Set<Id> selectedRecordIds)
    {   
        
        //Added by - Mahendra Swarnkar - CR-20211112-15581 - 11/29/2021 - Check for set contains the sales invoice record Id
        if(selectedRecordIds != null && selectedRecordIds.size() > 0) 
        {
            
            // Modified By - Colin McGloin - CR-20200715-14316
            //Map for checking for Invoice Billing Contacts
            Map<Id, List<Invoice_Billing_Contact__c>> mapConIdToIBCs = new Map <Id, List<Invoice_Billing_Contact__c>>();
            
            //Added by - Mahendra Swarnkar - CR-20211112-15581 - Added Standard_Contract__c != null check in query 
            //isCompleteLoaded = true;
            List<Invoice_Billing_Contact__c> invoiceBillingContacts = [SELECT Id, Name, Contact__c, Contact_Name__c, Standard_Contract__c, Contract_Name__c, Invoice_Email__c, Enabled_for_this_Contract__c
                                                                       FROM Invoice_Billing_Contact__c
                                                                       WHERE Enabled_for_this_Contract__c = TRUE  AND Standard_Contract__c != null];
            
            //Loop through our IBC and set in Map
            for (Invoice_Billing_Contact__c ibc: invoiceBillingContacts){
                
                  //Added by - Mahendra Swarnkar - CR-20211112-15581 - Added standard contract contains key check in below condition
                  if (mapConIdToIBCs.containsKey(ibc.Standard_Contract__c) && mapConIdToIBCs.get(ibc.Standard_Contract__c) != null){
                    List<Invoice_Billing_Contact__c> ibcs = mapConIdToIBCs.get(ibc.Standard_Contract__c);
                    ibcs.add(ibc);
                    mapConIdToIBCs.put(ibc.Standard_Contract__c, ibcs);
                } else {
                    List<Invoice_Billing_Contact__c> ibcs = new List <Invoice_Billing_Contact__c>();
                    ibcs.add(ibc);
                    mapConIdToIBCs.put(ibc.Standard_Contract__c, ibcs);
                }
            }
            
            //Check for set contains the sales invoice record Id
            if(selectedRecordIds != null && selectedRecordIds.size() > 0) 
            {
                Set<Id> setOfContentDocumentId = new Set<Id>();
                Map<Id,c2g__codaInvoice__c> mapOfSalesInvoice = new Map<Id,c2g__codaInvoice__c>();
                
                //Query the sales invoice record 
                for(c2g__codaInvoice__c invoice : [Select Id,Invoice_Contact__c,Credit_Manager__c,
                                                   Credit_Manager__r.Email, Invoice_Contact__r.Email,
                                                   Credit_Manager__r.Title,Name,ffaci__InvoiceEmail__c, 
                                                   Invoice_Contact__r.Asst_Email__c,Content_Document_ID__c,
                                                   Contract__c
                                                   FROM c2g__codaInvoice__c 
                                                   WHERE Id IN: selectedRecordIds])
                {
                    //map to hold the sales invoice record
                    mapOfSalesInvoice.put(invoice.Id,invoice);
                    
                    //set to hold the content document Id from sales invoice record
                    setOfContentDocumentId.add(invoice.Content_Document_ID__c); 
                }
                
                Map<Id,Contentversion> mapOfContentVersion = new Map<Id,Contentversion>();
                
                if(setOfContentDocumentId.size() > 0)
                {
                    //Perform query on content version on the basis of content document id and fill the map
                    for(Contentversion content :  [SELECT Id, contentDocumentId, ContentDocument.title,
                                                   FileType,VersionData  
                                                   FROM Contentversion 
                                                   WHERE contentDocumentId IN: setOfContentDocumentId 
                                                   AND islatest = true])
                    {
                        mapOfContentVersion.put(content.contentDocumentId,content);
                        
                    }
                    
                    //Query the sales invoice template 
                    List<Emailtemplate> emailTemplate = [Select Id,Name,body,DeveloperName 
                                                         FROM Emailtemplate 
                                                         WHERE DeveloperName =: System.Label.Sales_Invoice_Template Limit 1];
                    
                    //Check for any content version record exist
                    if(mapOfSalesInvoice.size() > 0 && mapOfContentVersion.size() > 0)
                    {
                        listOfemailsend = new List<Messaging.SingleEmailMessage>();
                        
                        //loop to generate the necessary data to send email like email Id,Contact,target object etc 
                        for(c2g__codaInvoice__c salesinvoice : mapOfSalesInvoice.values())
                        {
                            if(GenerateInvoice.hasRequiredFieldsValidations(salesinvoice) 
                               && mapOfSalesInvoice.containsKey(salesinvoice.Id)
                               && String.isNotBlank(mapOfSalesInvoice.get(salesInvoice.Id).Content_Document_ID__c))
                            {
                                //List to hold the email address on which email will be send
                                Set<String> emailAddressSet = new Set<String>();
                                
                                if(String.isNotBlank(salesInvoice.Credit_Manager__r.Email))
                                    emailAddressSet.add(salesInvoice.Credit_Manager__r.Email);                    
                                
                                if(String.isNotBlank(salesInvoice.Invoice_Contact__r.Email))
                                    emailAddressSet.add(salesInvoice.Invoice_Contact__r.Email);                        
                                
                                if(String.isNotBlank(salesInvoice.ffaci__InvoiceEmail__c))
                                    emailAddressSet.add(salesInvoice.ffaci__InvoiceEmail__c);                        
                                
                                if(String.isNotBlank(salesInvoice.Invoice_Contact__r.Asst_Email__c))
                                    emailAddressSet.add(salesInvoice.Invoice_Contact__r.Asst_Email__c);
                                
                                //Get our Invoice Billing Contacts
                                if (mapConIdToIBCs.get(salesinvoice.Contract__c) != null){
                                    List<Invoice_Billing_Contact__c> ibcs = mapConIdToIBCs.get(salesinvoice.Contract__c);
                                    for (Invoice_Billing_Contact__c ibc : ibcs){
                                        emailAddressSet.add(ibc.Invoice_Email__c);
                                    }
                                }
                                
                                //Convert Set to List
                                List<String> emailAddress = new List<String>();
                                emailAddress.addAll(emailAddressSet);
                                
                                //check for any email adddress exist to send invoice email
                                if(emailAddress.size() > 0 
                                   && mapOfContentVersion.containsKey(salesInvoice.Content_Document_ID__c))
                                {
                                    if(emailTemplate != null && emailTemplate.size() > 0) 
                                    {
                                        sendEmailAttachment(mapOfContentVersion.get(salesInvoice.Content_Document_ID__c).Id, emailAddress,emailTemplate[0].Id,salesInvoice.Invoice_Contact__c,salesInvoice.Id);
                                    }
                                    else 
                                    {
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Unable to find out the email template.'));                                    
                                    }
                                }
                                else
                                {
                                    //Display the error message that no email Id exist to send email
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invoice '+ salesinvoice.Name + ' : '+ System.Label.POPULATE_EMAIL_ON_ASSOCIATE_INVOICE_CONTACT)); 
                                }
                            }
                            else
                            {
                                //remove the invoice from map for which mail can't be send
                                mapOfSalesInvoice.remove(salesInvoice.Id);
                                
                                //Display the error message to user
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invoice '+ salesinvoice.Name + ' : '+ System.Label.TO_EMAIL_INVOICE_REQUIRED_FIELDS_ARE_MISSING));
                            }
                        }
                        
                        if(listOfemailsend.size() > 0)
                        {
                            try
                            {
                                //send the mail to user 
                                Messaging.sendEmail(listOfemailsend);
                                
                                //Display the message to user that email has been send.
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, System.Label.INVOICE_EMAIL_SEND_SUCCESSFULLY));
                                
                                //method to craete task and update the invoice record email status
                                createTaskwithAttachment(mapOfSalesInvoice,mapOfContentVersion);
                            }
                            catch(DMLException ex)
                            {
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getDmlMessage(0)));
                            } 
                        } 
                    }
                    else
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.INVALID_CONTENT_DOCUMENT_ID_ON_INVOICE));
                    }
                }
                else
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CONTENT_DOCUMENT_ID_OR_INVOICE_DOES_NOT_EXIST));
                }     
            }
            else
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.NO_SALES_INVOICE_SELECTED));
            }
        }
    }
    
    /**
    * @Description    :   Method to send email to user.
    *
    * @args           :   Id,String[],Id,Id,Id
    *
    * @return         :   void
    *
    **/
    public static void sendEmailAttachment(Id docId,String[] emailAddress,Id templateId,Id targetObjectId,Id recordId) 
    {
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        semail.setEntityAttachments(new Id[]{docId});
        semail.setSaveAsActivity(false);
        semail.setTemplateId(templateId);
        semail.setWhatId(recordId);
        semail.setToAddresses(emailAddress);
        
        //Added By mahendra Swarnkar - CR-20200520-14073 - 05/26/2020 - Starts from here 
        //List to hold the email address on which email will be send (BCC address)
		List<String> emailAddressBCC = new List<String>();
        emailAddressBCC.add(UserInfo.getUserEmail());
        semail.setBccAddresses(emailAddressBCC);
        //Added By mahendra Swarnkar - CR-20200520-14073 - 05/26/2020 - Ends here
        
        semail.setTargetObjectId(targetObjectId);
        listOfemailsend.add(semail);   
    }
    
    /**
    * @Description    :   Method to inset task record and add the attachment under that and update the invoice email status.
    *
    * @args           :   Map<Id,c2g__codaInvoice__c> ,Map<Id,Contentversion>
    *
    * @return         :   void
    *
    **/
    public static void createTaskwithAttachment(Map<Id,c2g__codaInvoice__c> mapOfSalesInvoice,
                                                Map<Id,Contentversion> mapOfContentVersion)
    {
        try
        {
            Map<Id,Task> mapOftaskTobeInsert = new Map<Id,Task>();
            Map<Id,Task> mapOfTaskWithInvoice = new Map<Id,Task>();
            List<c2g__codaInvoice__c> invoiceToBeUpdated = new List<c2g__codaInvoice__c>();
            List<Attachment> listOfAttachmentToBeInsert = new List<Attachment>();
            
            //loop to task and invoice record in list which going to be insert or update
            for(c2g__codaInvoice__c invoice : mapOfSalesInvoice.values())
            {
                //new instance of task with all info
                Task tsk = new Task();
                tsk.Subject = 'Email: EAB Invoice'+' '+invoice.Name;
                tsk.WhatId = invoice.Id;
                tsk.WhoId = invoice.Invoice_Contact__c;
                tsk.Status = 'Completed';
                tsk.Priority ='Normal';
                tsk.Event_Type__c = 'Email';
                tsk.Event_Purpose__c= 'Email';
                tsk.Description = 'From:'+''+invoice.Credit_Manager__r.Email+'\n'
                    +'To:'+' '+invoice.Invoice_Contact__r.Email+'\n'
                    +' '+invoice.Invoice_Contact__r.Asst_Email__c != null ? invoice.Invoice_Contact__r.Asst_Email__c : ''+'\n'
                        +' '+invoice.ffaci__InvoiceEmail__c != null ? invoice.ffaci__InvoiceEmail__c : ''+'\n'
                            +'Subject: EAB Invoice '+invoice.Name+'\n'
                            +'(Invoice in attachment)'; 
                
                //map to hold the task which going to be insert
                mapOftaskTobeInsert.put(invoice.Id,tsk);
                
                //invoice whose status going to be update 
                invoice.Email_Status__c = 'Emailed';
                invoiceToBeUpdated.add(invoice);  
            }
            
            //perfrom the database operation to insert the task and upadte the invoice
            if(mapOftaskTobeInsert.size() > 0 && invoiceToBeUpdated.size() > 0)
            {
                Database.update(invoiceToBeUpdated,false);
                Database.insert(mapOftaskTobeInsert.values(),false);
            }
            
            //Query the latest insert record of task
            for(Task tsk : [select id,CreatedDate,WhatId 
                            FROM Task 
                            WHERE WhatId IN: mapOftaskTobeInsert.keySet() 
                            AND CreatedDate = TODAY 
                            ORDER BY createdDate DESC])
            {
                if(!mapOfTaskWithInvoice.ContainsKey(tsk.WhatId))
                {
                    mapOfTaskWithInvoice.put(tsk.WhatId,tsk);    
                }
            }
            
            //Add the Attachment unser the task
            if(mapOfTaskWithInvoice.size() > 0)
            {
                for(Task task : mapOfTaskWithInvoice.values())
                {
                    Attachment anAttachment = new Attachment();
                    if(mapOfSalesInvoice.ContainsKey(task.WhatId))
                    {
                        anAttachment.Name =  'Invoice-'+mapOfSalesInvoice.get(task.WhatId).Name+'.pdf';
                        if(mapOfContentVersion.Containskey(mapOfSalesInvoice.get(task.WhatId).Content_Document_ID__c))
                        {
                            anAttachment.Body = mapOfContentVersion.get(mapOfSalesInvoice.get(task.WhatId).Content_Document_ID__c).VersionData;
                        }
                    } 
                    anAttachment.ParentId = task.Id;
                    listOfAttachmentToBeInsert.add(anAttachment);     
                }
            }
            
            //Insert the attcahment under the task
            if(listOfAttachmentToBeInsert.size() > 0)
            {  
                Database.insert(listOfAttachmentToBeInsert,false);
            }
        }
        catch(DMLException ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getDmlMessage(0)));
        } 
    }
    
    /**
    * @Description    :   Method to go back to previous list view.
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