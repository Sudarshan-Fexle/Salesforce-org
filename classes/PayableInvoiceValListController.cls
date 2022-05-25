/**
 *  Description     :   The list controller for Payable Invoice List Posting validation. Before a Payable Invoice can be posted,
 *      				the record must pass through a couple of scenarios.
 * 
 *  Created By      :   Colin McGloin
 * 
 *  Created Date    :   12/15/2016
 * 
 *  Revision Logs   :   V1.0 - Created by Colin McGloin - CR-20161201-10511
 * 						
 *                      
 *
 **/

public with sharing class PayableInvoiceValListController {

    ApexPages.StandardSetController stdController;
    Set<Id> selectedPayInvIds;
    Set<Id> approvedPayInvIds;
    Set<Id> approverSameAsPosterPayInvIds;
    Set<Id> unapprovedPayInvIds;
    Set<Id> creatorSameAsPosterPayInvIds;
    private String baseURL;
    ID UserId;
    Id approvedByUserId;
    PageReference pgref;

    public PayableInvoiceValListController(ApexPages.StandardSetController stdController) {
        this.stdController = stdController;
        this.baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        this.selectedPayInvIds = new Set<Id>();
        this.approvedPayInvIds = new Set<Id>();
        this.unapprovedPayInvIds = new Set<Id>();
        this.approverSameAsPosterPayInvIds = new Set<Id>();
        this.creatorSameAsPosterPayInvIds = new Set<Id>();
        this.userId = UserInfo.getUserId();
    }
	
    //Created by Colin McGloin - CR-20161201-10511
    public PageReference validateApprovalList() {
        
        //Check to make sure a Payable Invoice was selected
        if (this.stdController.getSelected().size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'No Payable Invoices selected. Please select at least one Payable Invoice to post.'));
        }
                //Modified By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020 - 
        	//Grab our Custom Permission
        	/*List<CustomPermission> customPermissions = [SELECT Id, DeveloperName
             											FROM CustomPermission
             											WHERE DeveloperName = 'Payable_Invoice_Post'];
        
        	//Check to see that the logged in user has the Custom Permission assigned
        	List<SetupEntityAccess> setupEntities = [SELECT SetupEntityId
             										 FROM SetupEntityAccess
             										 WHERE SetupEntityId in :customPermissions AND
             											   ParentId IN (SELECT PermissionSetId
                          								   FROM PermissionSetAssignment
                          								   WHERE AssigneeId = :this.userId)];*/
                                                           
        
        if (FeatureManagement.checkPermission('Payable_Invoice_Post') != true){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'You do not have the permission to post this record.'));
        }
        
        else {
            
            pgref = new PageReference('/a27');
            
            //Grab a Map of our Users so that we can have those all together in one query
            Map <String, User> allUsers = new Map <String, User>();
            List <User> fullListOfUsers = [SELECT Id, Name FROM User];
            for (User u : fullListOfUsers){
                allUsers.put(u.Name, u);
            }
            
            ffbext__OneTouchSettings__c oneTouchSettings = ffbext__OneTouchSettings__c.getInstance(UserId);

            sObject[] selectedSObjects = stdController.getSelected();
            for (sObject selectedSObject : selectedSObjects) {
                this.selectedPayInvIds.add(selectedSObject.Id);
            }

            List<c2g__codaPurchaseInvoice__c> payInvoices = [
                select Id, ffbext__Approved__c, Approval_Changed_By__c, CreatedById
                from c2g__codaPurchaseInvoice__c
                where Id in :selectedPayInvIds 
            ];

            //Modified By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020 - 
            //Royall Scenarios
            if (FeatureManagement.checkPermission('Royall_Finance') == true){

            for (c2g__codaPurchaseInvoice__c payableInvoice : payInvoices) {
                //Grab our User ID from the Map associated with the Approved By
                if (payableInvoice.Approval_Changed_By__c != null){
                    approvedByUserId = allUsers.get(payableInvoice.Approval_Changed_By__c).Id;
                }
                //If there is no Approver marked then move to the Unapproved Set
                if (approvedByUserId == null){
                    this.unapprovedPayInvIds.add(payableInvoice.id);
                }
                //If the creator is the Poster then it fails
                if (payableInvoice.CreatedById == UserId){
                    this.creatorSameAsPosterPayInvIds.add(payableInvoice.Id);
                }
                //If the Approver is the same as the Poster then move to Set
                if (UserId == approvedByUserId){
                    this.approverSameAsPosterPayInvIds.add(payableInvoice.id);
                }
                else {
                    if (okToPost(oneTouchSettings, payableInvoice)) {
                        this.approvedPayInvIds.add(payableInvoice.id);
                    }
                    else {
                        this.unapprovedPayInvIds.add(payableInvoice.id);
                        }
                    }
                }   

            }

            else {

                //ABC Scenarios
                for (c2g__codaPurchaseInvoice__c payableInvoice : payInvoices) {
                    //Check for Approval
                    if (okToPost(oneTouchSettings, payableInvoice)) {
                        this.approvedPayInvIds.add(payableInvoice.id);
                    }
                    else {
                        this.unapprovedPayInvIds.add(payableInvoice.id);
                        }
                }
            }

            if (!this.unapprovedPayInvIds.isEmpty()) {
                String emailMsg =  'Of ' + this.selectedPayInvIds.size() + ' selected Payable Invoices, the following Payable Invoices were not posted because they were not approved:\n';
                for (Id payableInvoiceId : this.unapprovedPayInvIds) {
                    emailMsg += this.baseURL + '/' + payableInvoiceId + '\n';
                }
                sendEmail(emailMsg);
            }
            
            if (!this.approverSameAsPosterPayInvIds.isEmpty()) {
                String emailMsg =  'Of ' + this.selectedPayInvIds.size() + ' selected Payable Invoices, the following Payable Invoices were not posted because the Approver was the same as the Poster:\n';
                for (Id payableInvoiceId : this.approverSameAsPosterPayInvIds) {
                    emailMsg += this.baseURL + '/' + payableInvoiceId + '\n';
                }
                sendEmail(emailMsg);
            }

            if (!this.creatorSameAsPosterPayInvIds.isEmpty()) {
                String emailMsg =  'Of ' + this.selectedPayInvIds.size() + ' selected Payable Invoices, the following Payable Invoices were not posted because the Creator was the same as the Poster:\n';
                for (Id payableInvoiceId : this.approverSameAsPosterPayInvIds) {
                    emailMsg += this.baseURL + '/' + payableInvoiceId + '\n';
                }
                sendEmail(emailMsg);
            }

            if (!this.approvedPayInvIds.isEmpty()) {

                //Create the Context record needed for the company pull 
                c2g.CODAAPICommon_2_0.Context context = new c2g.CODAAPICommon_2_0.Context();
                
                //Grab the current logged in as company
                List <String> currentCompanies = c2g.CODAAPICompany_2_0.GetCurrentCompanies(context);

                c2g.CODAAPICommon_9_0.Context context2 = new c2g.CODAAPICommon_9_0.Context();
                context2.CompanyName = currentCompanies[0];
                
                List<c2g.CODAAPICommon.Reference> values = new List<c2g.CODAAPICommon.Reference>();
                for (Id payInvoiceId : this.approvedPayInvIds) {
                    c2g.CODAAPICommon.Reference value = new c2g.CODAAPICommon.Reference();
                    value.Id = payInvoiceId;
                    values.add(value);
                }

                try {
                    c2g.CODAAPIPurchaseInvoice_9_0.BulkPostPurchaseInvoice(context2, values);
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

    private boolean okToPost(ffbext__OneTouchSettings__c oneTouchSettings, c2g__codaPurchaseInvoice__c thePayableInvoice) {
        boolean okToPost = true;
        if (oneTouchSettings.ffbext__EnablePayableInvoiceApproval__c) {
            if (!thePayableInvoice.ffbext__Approved__c) {
                okToPost = false;
            }
        }
        return okToPost;
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
            mail.setSenderDisplayName('FF Payable Invoice Posting');
            mail.setSaveAsActivity(false);
            mail.setSubject('The Advisory Board Company: Payable Invoice Post');
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

    //Modified By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020 - Comment the method as add updated custom permission check
   /* private boolean royallTeam() {

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