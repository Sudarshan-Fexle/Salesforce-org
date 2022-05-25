/**
 *  Description     :   The list controller for Sales Invoice List Posting validation. Before a Sales Invoice can be posted,
 *      				the record must pass through a couple of scenarios.
 * 
 *  Created By      :   Colin McGloin
 * 
 *  Created Date    :   02/07/2017
 * 
 *  Revision Logs   :   V1.0 - Created by Colin McGloin - CR-20161201-10511
 * 			v1.1 - Modified By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020 - 
 *                      
 *
 **/

public with sharing class SalesInvoiceApprovalValListController {

	ApexPages.StandardSetController stdController;
    Set<Id> selectedsSalesInvIds;
    Set<Id> approvedSalesInvIds;
    Set<Id> creatorSameAsPosterSalesInvIds;
    Set<Id> lastModifiedSameAsPosterSalesInvIds;
    private String baseURL;
    ID UserId;
    PageReference pgref;

    public SalesInvoiceApprovalValListController(ApexPages.StandardSetController stdController) {
        this.stdController = stdController;
        this.baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        this.selectedsSalesInvIds = new Set<Id>();
        this.approvedSalesInvIds = new Set<Id>();
        this.creatorSameAsPosterSalesInvIds = new Set<Id>();
        this.lastModifiedSameAsPosterSalesInvIds = new Set<Id>();
        this.userId = UserInfo.getUserId(); 
    }
	
    //Created by Colin McGloin - CR-20161201-10511
    public PageReference validateApprovalList() {
        
        //Check to make sure a Payable Invoice was selected
        if (this.stdController.getSelected().size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'No Sales Invoices selected. Please select at least one Sales Invoice to post.'));
        }
            //Modified By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020 - 
        	//Grab our Custom Permission
        	/*List<CustomPermission> customPermissions = [SELECT Id, DeveloperName
             											FROM CustomPermission
             											WHERE DeveloperName = 'Sales_Invoice_Post'];
        
        	//Check to see that the logged in user has the Custom Permission assigned
        	List<SetupEntityAccess> setupEntities = [SELECT SetupEntityId
             										 FROM SetupEntityAccess
             										 WHERE SetupEntityId in :customPermissions AND
             											   ParentId IN (SELECT PermissionSetId
                          								   FROM PermissionSetAssignment
                          								   WHERE AssigneeId = :this.userId)];*/
                                                           
        
        if (FeatureManagement.checkPermission('Sales_Invoice_Post') != true){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'You do not have the permission to post this record.'));
        }
        
        else {
            
            pgref = new PageReference('/a1b');

            sObject[] selectedSObjects = stdController.getSelected();
            for (sObject selectedSObject : selectedSObjects) {
                this.selectedsSalesInvIds.add(selectedSObject.Id);
            }

            List<c2g__codaInvoice__c> salesInvoices = [
                select Id, CreatedById, LastModifiedById
                from c2g__codaInvoice__c
                where Id in :selectedsSalesInvIds 
            ];

            //Modified By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020 - 
            //Royall Scenarios
            if (FeatureManagement.checkPermission('Royall_Finance') == true){

            for (c2g__codaInvoice__c salesInvoice : salesInvoices) {
                
                //If the Creator is the same as the Poster then move to Fail Set
                if (UserId == salesInvoice.CreatedById){
                    this.creatorSameAsPosterSalesInvIds.add(salesInvoice.id);
                }
                //If the user who last modified the record is the same as the Poster then move to Fail Set
                else if (UserId == salesInvoice.LastModifiedById){
                    this.lastModifiedSameAsPosterSalesInvIds.add(salesInvoice.Id);
                }
                else {
                        this.approvedSalesInvIds.add(salesInvoice.id);
                    }
                }
            }

            else {

                    //ABC Scenarios
                    for (c2g__codaInvoice__c salesInvoice : salesInvoices) {
                        //Add the Sales Invoice to the list to post
                        this.approvedSalesInvIds.add(salesInvoice.id);
                    }
                }

            if (!this.creatorSameAsPosterSalesInvIds.isEmpty()) {
                String emailMsg =  'Of ' + this.selectedsSalesInvIds.size() + ' selected Sales Invoices, the following Sales Invoices were not posted because the creator of the Sales Invoice was the same as the Poster:\n';
                for (Id salesInvoiceId : this.creatorSameAsPosterSalesInvIds) {
                    emailMsg += this.baseURL + '/' + salesInvoiceId + '\n';
                }
                sendEmail(emailMsg);
            }

            if (!this.lastModifiedSameAsPosterSalesInvIds.isEmpty()) {
                String emailMsg =  'Of ' + this.selectedsSalesInvIds.size() + ' selected Sales Invoices, the following Sales Invoices were not posted because the user who last modified the Sales Invoice was the same as the Poster:\n';
                for (Id salesInvoiceId : this.lastModifiedSameAsPosterSalesInvIds) {
                    emailMsg += this.baseURL + '/' + salesInvoiceId + '\n';
                }
                sendEmail(emailMsg);
            }

            if (!this.approvedSalesInvIds.isEmpty()) {

                //Create the Context record needed for the company pull 
                c2g.CODAAPICommon_2_0.Context context = new c2g.CODAAPICommon_2_0.Context();
                
                //Grab the current logged in as company
                List <String> currentCompanies = c2g.CODAAPICompany_2_0.GetCurrentCompanies(context);

                c2g.CODAAPICommon_10_0.Context context2 = new c2g.CODAAPICommon_10_0.Context();
                context2.CompanyName = currentCompanies[0];
                
                List<c2g.CODAAPICommon.Reference> values = new List<c2g.CODAAPICommon.Reference>();
                for (Id salesInvoiceId : this.approvedSalesInvIds) {
                    c2g.CODAAPICommon.Reference value = new c2g.CODAAPICommon.Reference();
                    value.Id = salesInvoiceId;
                    values.add(value);
                }

                try {
                    c2g.CODAAPISalesInvoice_10_0.BulkPostInvoice(context2, values);
                }
                catch (Exception e) {
                    String msg = 
                        'This message has been sent by FinancialForce Accounting to inform you that the bulk document posting process ' +
                        'you initiated has completed with the following errors:\n\n' + e.getMessage();
                    sendEmail(msg);
                    return pgref;
                }
            }
        }

        return null;
    }

    public PageReference back() {
        return stdController.cancel();
    }

    public void sendEmail(String emailMsg) {
        List<User> userList = [
            select email
            from User
            where Id = :UserInfo.getUserId()
        ];

        if (!userList.isEmpty()) {
            String[] recipients = new List<String>();
            recipients.add(userList.get(0).Email);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(recipients);
            mail.setSenderDisplayName('FF Sales Invoice Posting');
            mail.setSaveAsActivity(false);
            mail.setSubject('The Advisory Board Company: Sales Invoice Post');
            mail.setPlainTextBody(emailMsg);
            Messaging.reserveSingleEmailCapacity(recipients.size());
            
            if (!System.Test.isRunningTest()) {
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
                if (results.get(0).isSuccess()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 'Email sent to ' + recipients[0] + ' successfully'));
                } 
                else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'The email failed to send: ' + results.get(0).getErrors().get(0).getMessage()));
                }
            }
        }
    }

    //Modified By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020 - 
    /*private boolean royallTeam() {

        //Set our default to false
        boolean royallTeam = false;

        //Grab our Royall Custom Permission
        CustomPermission royallPermission = [SELECT Id, DeveloperName
                                              FROM CustomPermission
                                              WHERE DeveloperName = 'Royall_Finance'];

        
        //Check to see that the logged in user has the Custom Permission assigned
        List<SetupEntityAccess> royallSetupEntities = [SELECT SetupEntityId
                                                    FROM SetupEntityAccess
                                                    WHERE SetupEntityId = :royallPermission.Id AND
                                                           ParentId IN (SELECT PermissionSetId
                                                           FROM PermissionSetAssignment
                                                           WHERE AssigneeId = :this.userId)];

        //If the user is set to a Royall user then update our flag                                                   
        if (!royallSetupEntities.isEmpty()){
            royallTeam = True;
        }
        else {
            royallTeam = False;
        }
        //Return our flag
        return royallTeam;

    }*/
}