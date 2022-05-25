/**
 *  Description     :   The list controller for journal approval validation. Before a journal can be posted,
 *      				the record must pass through a couple of scenarios.
 * 
 *  Created By      :   William Rich (Company:IconATG Email:william.rich@iconatg.com)
 * 
 *  Created Date    :   3/22/2015
 * 
 *  Revision Logs   :   V1.0 - Created
 * 						V1.1 - Modified by Colin McGloin - CR-20161201-10511
 *                      
 *
 **/

public with sharing class JournalApprovalValidationListController {

    ApexPages.StandardSetController stdController;
    Set<Id> selectedJournalIds;
    Set<Id> approvedJournalIds;
    Set<Id> approverSameAsPosterJournalIds;
    Set<Id> unapprovedJournalIds;
    private String baseURL;
    ID UserId;
    Id approvedByUserId;
    PageReference pgref;

    public JournalApprovalValidationListController(ApexPages.StandardSetController stdController) {
        this.stdController = stdController;
        this.baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        this.selectedJournalIds = new Set<Id>();
        this.approvedJournalIds = new Set<Id>();
        this.unapprovedJournalIds = new Set<Id>();
        this.approverSameAsPosterJournalIds = new Set<Id>();
        this.userId = UserInfo.getUserId();
    }
	
    //Modified by Colin McGloin - CR-20161201-10511
    public PageReference validateApprovalList() {
        
        //Check to make sure a Journal was selected
        if (this.stdController.getSelected().size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'No journals selected. Please select at least one journal to post.'));
        }
        	//Grab our Custom Permission
        	List<CustomPermission> customPermissions = [SELECT Id, DeveloperName
             											FROM CustomPermission
             											WHERE DeveloperName = 'Journal_Post'];
        
        	//Check to see that the logged in user has the Custom Permission assigned
        	List<SetupEntityAccess> setupEntities = [SELECT SetupEntityId
             										 FROM SetupEntityAccess
             										 WHERE SetupEntityId in :customPermissions AND
             											   ParentId IN (SELECT PermissionSetId
                          								   FROM PermissionSetAssignment
                          								   WHERE AssigneeId = :this.userId)];
        
        if (setupEntities.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'You do not have the permission to post this record.'));
        }
        
        else {
            
            pgref = new PageReference('/a1e');
            
            //Grab a Map of our Users so that we can have those all together in one query
            Map <String, User> allUsers = new Map <String, User>();
            List <User> fullListOfUsers = [SELECT Id, Name FROM User];
            for (User u : fullListOfUsers){
                allUsers.put(u.Name, u);
            }
            
            ffbext__OneTouchSettings__c oneTouchSettings = ffbext__OneTouchSettings__c.getInstance(UserId);

            sObject[] selectedSObjects = stdController.getSelected();
            for (sObject selectedSObject : selectedSObjects) {
                this.selectedJournalIds.add(selectedSObject.Id);
            }

            List<c2g__codaJournal__c> journals = [
                select Id, Approved__c, Approval_Changed_By__c
                from c2g__codaJournal__c
                where Id in :selectedJournalIds 
            ];

            //Royall Scenarios
            if (royallTeam() == true){

            for (c2g__codaJournal__c journal : journals) {
                //Grab our User ID from the Map associated with the Approved By
                if (journal.Approval_Changed_By__c != null){
                    approvedByUserId = allUsers.get(journal.Approval_Changed_By__c).Id;
                }
                //If there is no Approver marked then move to the Unapproved Set
                if (approvedByUserId == null){
                    this.unapprovedJournalIds.add(journal.id);
                }
                
                //If the Approver is the same as the Poster then move to Set
                if (UserId == approvedByUserId){
                    this.approverSameAsPosterJournalIds.add(journal.id);
                }
                else {
                    if (okToPost(oneTouchSettings, journal)) {
                        this.approvedJournalIds.add(journal.id);
                    }
                    else {
                        this.unapprovedJournalIds.add(journal.id);
                        }
                    }
                }
            }

            else {

                    //ABC Scenarios
                    for (c2g__codaJournal__c journal : journals) {
                        //Check for Approval
                        if (okToPost(oneTouchSettings, journal)) {
                        this.approvedJournalIds.add(journal.id);
                    }
                    else {
                        this.unapprovedJournalIds.add(journal.id);
                        }
                    }
                }

            if (!this.unapprovedJournalIds.isEmpty()) {
                String emailMsg =  'Of ' + this.selectedJournalIds.size() + ' selected journals, the following journals were not posted because they were not approved:\n';
                for (Id journalId : this.unapprovedJournalIds) {
                    emailMsg += this.baseURL + '/' + journalId + '\n';
                }
                sendEmail(emailMsg);
            }
            
            if (!this.approverSameAsPosterJournalIds.isEmpty()) {
                String emailMsg =  'Of ' + this.selectedJournalIds.size() + ' selected journals, the following journals were not posted because the Approver was the same as the Poster:\n';
                for (Id journalId : this.approverSameAsPosterJournalIds) {
                    emailMsg += this.baseURL + '/' + journalId + '\n';
                }
                sendEmail(emailMsg);
            }

            if (!this.approvedJournalIds.isEmpty()) {

                //Call future method
                JournalApprovalValidationListController.futureBulkPost(this.approvedJournalIds);

                return pgref;
            }
        }

        return null;
    }

    @future
    public static void futureBulkPost (Set<Id> journalIds) {

        //Create the Context record needed for the company pull	
        c2g.CODAAPICommon_2_0.Context context = new c2g.CODAAPICommon_2_0.Context();
                
        //Grab the current logged in as company
    	List <String> currentCompanies = c2g.CODAAPICompany_2_0.GetCurrentCompanies(context);
                	
        //Grab the later version Context needed for Posting
        c2g.CODAAPICommon_10_0.Context context2 = new c2g.CODAAPICommon_10_0.Context();
        context2.CompanyName = currentCompanies[0];

        //List of Reference records
        List<c2g.CODAAPICommon.Reference> values = new List<c2g.CODAAPICommon.Reference>();
            for (Id journalId : journalIds) {
                c2g.CODAAPICommon.Reference value = new c2g.CODAAPICommon.Reference();
                value.Id = journalId;
                values.add(value);
                System.debug('&&&&& adding selected journal ' + journalId);
            }

        try {
                System.debug('&&&&& bulk posting journals');
                c2g.CODAAPIJournal_12_0.BulkPostJournal(context2, values);
            }
        catch (Exception e) {

            //Parse and sort our Error Message
            List<String> errors = e.getMessage().split(';');
            String errorMessage = '';

            if (errors.size() > 0){
                for (String error : errors){
                    errorMessage += error + '\n\n';
                }
                
            }

            String msg = 
                'This message has been sent by FinancialForce Accounting to inform you that the bulk document posting process ' +
                'you initiated has completed with the following errors. All selected records have been rolled back to their prior unposted states. ' +
                'Errors: \n\n' + errorMessage;
            sendEmail(msg);
            }
    }

    public PageReference back() {
        return stdController.cancel();
    }

    private boolean okToPost(ffbext__OneTouchSettings__c oneTouchSettings, c2g__codaJournal__c theJournal) {
        boolean okToPost = true;
        if (oneTouchSettings.EnableJournalApproval__c) {
            if (!theJournal.Approved__c) {
                okToPost = false;
            }
        }
        return okToPost;
    }

    public static void sendEmail(String emailMsg) {
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
            mail.setSenderDisplayName('FF Journal Posting');
            mail.setSaveAsActivity(false);
            mail.setSubject('EAB: Journal Post');
            mail.setPlainTextBody(emailMsg);
            Messaging.reserveSingleEmailCapacity(recipients.size());
            
            if (!System.Test.isRunningTest()) {
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
                /*if (results.get(0).isSuccess()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 'Email sent to ' + recipients[0] + ' successfully'));
                } 
                else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'The email failed to send: ' + results.get(0).getErrors().get(0).getMessage()));
                }*/
            }
        }
    }

    private boolean royallTeam() {

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

    }
}