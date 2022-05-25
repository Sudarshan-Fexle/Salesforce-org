/**
 *  Description     :   The list controller for Sales Credit Note List Posting validation. Before a Sales Credit Note can be posted,
 *      				the record must pass through a couple of scenarios.
 * 
 *  Created By      :   Colin McGloin
 * 
 *  Created Date    :   02/21/2017
 * 
 *  Revision Logs   :   V1.0 - Created by Colin McGloin - CR-20161201-10511
 * 						
 *                      
 *
 **/

public with sharing class SalesCredNoteValListController {

    ApexPages.StandardSetController stdController;
    Set<Id> selectedSalesCredNoteIds;
    Set<Id> approvedSalesCredNoteIds;
    Set<Id> approverSameAsPosterSalesCredNoteIds;
    Set<Id> unapprovedSalesCredNoteIds;
    Set<Id> creatorSameAsPosterSalesCredNoteIds;
    private String baseURL;
    ID UserId;
    Id approvedByUserId;
    PageReference pgref;

    public SalesCredNoteValListController(ApexPages.StandardSetController stdController) {
        this.stdController = stdController;
        this.baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        this.selectedSalesCredNoteIds = new Set<Id>();
        this.approvedSalesCredNoteIds = new Set<Id>();
        this.unapprovedSalesCredNoteIds = new Set<Id>();
        this.approverSameAsPosterSalesCredNoteIds = new Set<Id>();
        this.creatorSameAsPosterSalesCredNoteIds = new Set<Id>();
        this.userId = UserInfo.getUserId();
    }
	
    //Created by Colin McGloin - CR-20161201-10511
    public PageReference validateApprovalList() {
        
        //Check to make sure a Sales Credit Note was selected
        if (this.stdController.getSelected().size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'No Sales Credit Notes selected. Please select at least one Sales Credit Notes to post.'));
        }
		// Modified By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020
        	//Grab our Custom Permission
        	/*List<CustomPermission> customPermissions = [SELECT Id, DeveloperName
             											FROM CustomPermission
             											WHERE DeveloperName = 'Sales_Credit_Note_Post'];
        
        	//Check to see that the logged in user has the Custom Permission assigned
        	List<SetupEntityAccess> setupEntities = [SELECT SetupEntityId
             										 FROM SetupEntityAccess
             										 WHERE SetupEntityId in :customPermissions AND
             											   ParentId IN (SELECT PermissionSetId
                          								   FROM PermissionSetAssignment
                          								   WHERE AssigneeId = :this.userId)];*/
                                                           
        //Modified By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020 -  
        if (FeatureManagement.checkPermission('Sales_Credit_Note_Post') != true){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'You do not have the permission to post this record.'));
        }
        
        else {
            
            //Grab a Map of our Users so that we can have those all together in one query
            Map <String, User> allUsers = new Map <String, User>();
            List <User> fullListOfUsers = [SELECT Id, Name FROM User];
            for (User u : fullListOfUsers){
                allUsers.put(u.Name, u);
            }
            
            ffbext__OneTouchSettings__c oneTouchSettings = ffbext__OneTouchSettings__c.getInstance(UserId);

            sObject[] selectedSObjects = stdController.getSelected();
            for (sObject selectedSObject : selectedSObjects) {
                this.selectedSalesCredNoteIds.add(selectedSObject.Id);
            }

            List<c2g__codaCreditNote__c> SalesCredNotes = [
                select Id, ffbext__Approved__c, Approval_Changed_By__c, CreatedById
                from c2g__codaCreditNote__c
                where Id in :selectedSalesCredNoteIds 
            ];

            //Modified By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020 -  
            //Royall Scenarios
            if (FeatureManagement.checkPermission('Royall_Finance') == true){

            for (c2g__codaCreditNote__c salesCreditNote : SalesCredNotes) {
                //Grab our User ID from the Map associated with the Approved By
                if (salesCreditNote.Approval_Changed_By__c != null){
                    approvedByUserId = allUsers.get(salesCreditNote.Approval_Changed_By__c).Id;
                }
                //If there is no Approver marked then move to the Unapproved Set
                if (approvedByUserId == null){
                    this.unapprovedSalesCredNoteIds.add(salesCreditNote.id);
                }
                //If the creator is the same as the Poster then move to an Unapproved Set
                if (salesCreditNote.CreatedById == UserId){
                    this.creatorSameAsPosterSalesCredNoteIds.add(salesCreditNote.id);
                }
                
                //If the Approver is the same as the Poster then move to Set
                if (UserId == approvedByUserId){
                    this.approverSameAsPosterSalesCredNoteIds.add(salesCreditNote.id);
                }
                else {
                    if (okToPost(oneTouchSettings, salesCreditNote)) {
                        this.approvedSalesCredNoteIds.add(salesCreditNote.id);
                    }
                    else {
                        this.unapprovedSalesCredNoteIds.add(salesCreditNote.id);
                        }
                    }
                }
            }

            else {

                    //ABC Scenarios
                    for (c2g__codaCreditNote__c salesCreditNote : SalesCredNotes) {
                        //Check for Approval
                        if (okToPost(oneTouchSettings, salesCreditNote)) {
                        this.approvedSalesCredNoteIds.add(salesCreditNote.id);
                        }
                    else {
                        this.unapprovedSalesCredNoteIds.add(salesCreditNote.id);
                        }
                    }

            }

            if (!this.unapprovedSalesCredNoteIds.isEmpty()) {
                String emailMsg =  'Of ' + this.selectedSalesCredNoteIds.size() + ' selected Sales Credit Notes, the following Sales Credit Notes were not posted because they were not approved:\n';
                for (Id salesCredNoteId : this.unapprovedSalesCredNoteIds) {
                    emailMsg += this.baseURL + '/' + salesCredNoteId + '\n';
                }
                sendEmail(emailMsg);
            }
            
            if (!this.approverSameAsPosterSalesCredNoteIds.isEmpty()) {
                String emailMsg =  'Of ' + this.selectedSalesCredNoteIds.size() + ' selected Sales Credit Notes, the following Sales Credit Notes were not posted because the Approver was the same as the Poster:\n';
                for (Id salesCredNoteId : this.approverSameAsPosterSalesCredNoteIds) {
                    emailMsg += this.baseURL + '/' + salesCredNoteId + '\n';
                }
                sendEmail(emailMsg);
            }

            if (!this.creatorSameAsPosterSalesCredNoteIds.isEmpty()) {
                String emailMsg =  'Of ' + this.selectedSalesCredNoteIds.size() + ' selected Sales Credit Notes, the following Sales Credit Notes were not posted because the creator of the Sales Credit Note was the same as the Poster:\n';
                for (Id salesCredNoteId : this.creatorSameAsPosterSalesCredNoteIds) {
                    emailMsg += this.baseURL + '/' + salesCredNoteId + '\n';
                }
                sendEmail(emailMsg);
            }

            if (!this.approvedSalesCredNoteIds.isEmpty()) {

                //Create the Context record needed for the company pull 
                c2g.CODAAPICommon_2_0.Context context = new c2g.CODAAPICommon_2_0.Context();
                
                //Grab the current logged in as company
                List <String> currentCompanies = c2g.CODAAPICompany_2_0.GetCurrentCompanies(context);

                c2g.CODAAPICommon_10_0.Context context2 = new c2g.CODAAPICommon_10_0.Context();
                context2.CompanyName = currentCompanies[0];
                
                List<c2g.CODAAPICommon.Reference> values = new List<c2g.CODAAPICommon.Reference>();
                for (Id salescreditNoteId : this.approvedSalesCredNoteIds) {
                    c2g.CODAAPICommon.Reference value = new c2g.CODAAPICommon.Reference();
                    value.Id = salescreditNoteId;
                    values.add(value);
                }

                try {
                    c2g.CODAAPISalesCreditNote_10_0.BulkPostCreditNote(context2, values);
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

    private boolean okToPost(ffbext__OneTouchSettings__c oneTouchSettings, c2g__codaCreditNote__c theSalesCreditNote) {
        boolean okToPost = true;
        if (oneTouchSettings.ffbext__EnableSalesCreditNoteApproval__c) {
            if (!theSalesCreditNote.ffbext__Approved__c) {
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
            mail.setSenderDisplayName('FF Sales Credit Note Posting');
            mail.setSaveAsActivity(false);
            mail.setSubject('The Advisory Board Company: Sales Credit Note Post');
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