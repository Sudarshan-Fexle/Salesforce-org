/**
 *  Description      :   The controller for journal approval validation. Before a journal can be posted,
 *                      the record must pass through a couple of scenarios.
 * 
 *  Created By      :   William Rich (Company:IconATG Email:william.rich@iconatg.com)
 * 
 *  Created Date    :   3/21/2015
 * 
 *  Revision Logs   :   V1.0 - Created
 *                      V1.1 - Modified by Colin McGloin - CR-20161201-10511
 *                      
 *
 **/

public with sharing class JournalApprovalValidationController {

    ApexPages.StandardController stdController;
    Id theJournalId;
    Id userID;
    PageReference pgRef;

    public JournalApprovalValidationController(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        this.theJournalId = stdController.getId();
        this.userId = UserInfo.getUserId();
        
    }
    
    //Modified by Colin McGloin - CR-20161201-10511
    public PageReference validateApproval() {

     //Modified By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020 - custom permission check 
    //We should only apply certain scenarios to Royall team
    if (FeatureManagement.checkPermission('Royall_Finance')){
        
        //Check if the Record is approved
        if (okToPost() == False) {
            //Present the error message to the user if record is not approved
            String msg = 'This Journal must be approved before it can be posted.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, msg));
            return pgRef;
        }
        //Check if the Poster is not the same user as the Approver
        if (approverSameAsPoster()){
            //Present the error message to the user if it is
            String msg = 'This Journal cannot be posted by the Approver.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, msg));
            return pgRef;
        }
        //Check if the Poster is not the same user as the Creator
        if (creatorSameAsPoster()){
            //Present the error message to the user if it is
            String msg = 'This Journal cannot be posted by the Creator.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, msg));
            return pgRef;
        }

    }
            
            //Post the Journal Record if we pass initial tests
            try {   
                    
                    //Create the Context record needed for the company pull 
                    c2g.CODAAPICommon_2_0.Context context = new c2g.CODAAPICommon_2_0.Context();
                
                    //Grab the current logged in as company
                    List <String> currentCompanies = c2g.CODAAPICompany_2_0.GetCurrentCompanies(context);
                    
                    //Grab the later version Context needed for Posting
                    c2g.CODAAPICommon_10_0.Context context2 = new c2g.CODAAPICommon_10_0.Context();
                    context2.CompanyName = currentCompanies[0];
                
                    //Add the record in the type needed by FF
                    c2g.CODAAPICommon.Reference journalRecord = new c2g.CODAAPICommon.Reference();
                    journalRecord.Id = theJournalId;
                
                    //Post the Journal once we've grabbed the current logged in Company
                    c2g.CODAAPIJournal_9_0.PostJournal(context2, journalRecord);
                
                    //If it posts, then redirect to the original record
                    pgRef = new PageReference('/' + theJournalId);
                    pgRef.setRedirect(false);

                    //system.debug('@@@zzz + the process reached here' + pgref);
                    return pgRef;       
                }

                    catch (Exception e) {

                        String msg = 'This message has been sent by FinancialForce Accounting to inform you that the Journal posting process ' +
                                     'you initiated has completed with the following errors:\n\n' + e.getMessage();
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,msg));
                        
            }

        return pgRef;

    }

    public PageReference cancel() {
        return this.stdController.cancel();
    }

    private boolean okToPost() {
        ffbext__OneTouchSettings__c oneTouchSettings;

        //Get our lowest level of settings (i.e returns User, then Profile then Org Wide based on availability)
        oneTouchSettings = ffbext__OneTouchSettings__c.getInstance(userID);

        c2g__codaJournal__c theJournal = [
            select Approved__c
            from c2g__codaJournal__c
            where Id = :theJournalId
        ];

        boolean okToPost = true;
        if (oneTouchSettings.EnableJournalApproval__c) {
            if (!theJournal.Approved__c) {
                okToPost = false;
            }
        }
        return okToPost;
    }
    
    //Added by Colin McGloin - CR-20161201-10511
    private boolean approverSameAsPoster() {
        
        //Set up Variable used later
        User ApprovedBy;
        
        //Grab the Journal record passed through 
        c2g__codaJournal__c jrnal = [SELECT Id, Approval_Changed_By__c from c2g__codaJournal__c WHERE Id = :theJournalId];
        
        //If there is a value in the Changed By field then grab our associated User
        if (jrnal.Approval_Changed_By__c != null){
            ApprovedBy = [SELECT Id FROM User WHERE Name = :jrnal.Approval_Changed_By__c];
        }
        
        //Default the value
        boolean approverSameAsPoster = true;
        
        //If the approver is not equal to the User Submitting to be Posted then allow it to go through
        if (ApprovedBy != null) {
            if (ApprovedBy.Id != userID){
                approverSameAsPoster = false;
            } 
        }
        //return our value after logic has been completed
        return approverSameAsPoster;
        
    }

    private boolean creatorSameAsPoster() {
        
        //Grab the Journal record passed through 
        c2g__codaJournal__c jrnal = [SELECT Id, CreatedById from c2g__codaJournal__c WHERE Id = :theJournalId];
        
        //Default the value
        boolean creatorSameAsPoster = true;
        
        //If the creator is not equal to the User Submitting to be Posted then allow it to go through
            if (jrnal.CreatedById != userID){
                creatorSameAsPoster = false;
            } 

        //return our value after logic has been completed
        return creatorSameAsPoster;
        
    }

    //Modified By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020 - Comment the method  
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