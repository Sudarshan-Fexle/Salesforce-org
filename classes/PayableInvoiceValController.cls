/**
 *  Desription      :   The controller for Payable Invoice validation. Before a Payable Invoice can be posted,
 *                      the record must pass through a couple of scenarios.
 * 
 *  Created By      :   Colin McGloin
 * 
 *  Created Date    :   12/12/2016
 * 
 *  Revision Logs   :   V1.0 - Created - CR-20161201-10511
 *                      
 *
 **/

public with sharing class PayableInvoiceValController {

    ApexPages.StandardController stdController;
    Id payableInvoiceId;
    Id userID;
    

    public PayableInvoiceValController(ApexPages.StandardController stdController) {

        this.stdController = stdController;
        this.payableInvoiceId = stdController.getId();
        this.userId = UserInfo.getUserId();

    }
    
    public PageReference validateApproval() {

        PageReference pgRef = null;

        //Modify By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020 - add updated custom permission check
        //We should only apply certain scenarios to Royall team
        if (FeatureManagement.checkPermission('Royall_Finance') == true){
        
        //Check if the Record is approved
        if (okToPost() == False) {
            //Present the error message to the user if record is not approved
            String msg = 'This Payable Invoice must be approved before it can be posted.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, msg));
            return pgRef;
        }
        //Check if the Poster is not the same user as the Approver
        if (approverSameAsPoster()){
            //Present the error message to the user if it is
            String msg = 'This Payable Invoice cannot be posted by the Approver.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, msg));
            return pgRef;
        }
        //Check if the Poster is not the same user as the Creator
        if (creatorSameAsPoster()){
            //Present the error message to the user if it is
            String msg = 'This Payable Invoice cannot be posted by the Creator.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, msg));
            return pgRef;
        }
    }

            //Post the Payable Invoice Record
            try {   
                    
                    //Create the Context record needed for the company pull 
                    c2g.CODAAPICommon_2_0.Context context = new c2g.CODAAPICommon_2_0.Context();
                
                    //Grab the current logged in as company
                    List <String> currentCompanies = c2g.CODAAPICompany_2_0.GetCurrentCompanies(context);
                    
                    //Grab the later version Context needed for Posting
                    c2g.CODAAPICommon_9_0.Context context2 = new c2g.CODAAPICommon_9_0.Context();
                    context2.CompanyName = currentCompanies[0];
                
                    //Add the record in the type needed by FF
                    c2g.CODAAPICommon.Reference payInvoiceRecord = new c2g.CODAAPICommon.Reference();
                    payInvoiceRecord.Id = payableInvoiceId;
                
                    //Post the Journal once we've grabbed the current logged in Company
                    c2g.CODAAPIPurchaseInvoice_9_0.PostPurchaseInvoice(context2, payInvoiceRecord);
                
                    //If it posts, then redirect to the original record
                    pgRef = new PageReference('/' + payableInvoiceId);
                    pgRef.setRedirect(true);    
                }
                    catch (Exception e) {
                        String msg = 'This message has been sent by FinancialForce Accounting to inform you that the Payable Invoice posting process ' +
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

        c2g__codaPurchaseInvoice__c payableInvoice = [
            select ffbext__Approved__c
            from c2g__codaPurchaseInvoice__c
            where Id = :payableInvoiceId
        ];

        boolean okToPost = true;
        if (oneTouchSettings.ffbext__EnablePayableInvoiceApproval__c) {
            if (!payableInvoice.ffbext__Approved__c) {
                okToPost = false;
            }
        }
        return okToPost;
    }
    
    
    private boolean approverSameAsPoster() {
        
        //Set up Variable used later
        User ApprovedBy;
        
        //Grab the Payable Invoice record passed through 
        c2g__codaPurchaseInvoice__c payInvoice = [SELECT Id, Approval_Changed_By__c FROM c2g__codaPurchaseInvoice__c WHERE Id = :payableInvoiceId];
        
        //If there is a value in the Changed By field then grab our associated User
        if (payInvoice.Approval_Changed_By__c != null){
            ApprovedBy = [SELECT Id FROM User WHERE Name = :payInvoice.Approval_Changed_By__c];
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
        
        //Grab the Payable Invoice record passed through 
        c2g__codaPurchaseInvoice__c payInvoice = [SELECT Id, CreatedById FROM c2g__codaPurchaseInvoice__c WHERE Id = :payableInvoiceId];
        
        //Default the value
        boolean creatorSameAsPoster = true;
        
        //If the creator is not equal to the User Submitting to be Posted then allow it to go through
            if (payInvoice.CreatedById != userID){
                creatorSameAsPoster = false;
            } 

        //return our value after logic has been completed
        return creatorSameAsPoster;
        
    }

     //Modify By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020 - Comment the method as add updated custom permission check
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