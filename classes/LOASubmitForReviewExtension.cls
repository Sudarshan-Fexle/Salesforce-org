/**
 *  Description     :  Extension for LOA Review Process
 *
 *  Created By      :  Victor Hanson
 *
 *  Created Date    :  05/2/2017
 *
 *  Revision Logs   :   V1.0 - Created - Victor Hanson
 *                      V1.0 - Modified - 05/5/2017 - Subhash Garhwal - Do commenting and formating
 **/
public without sharing class LOASubmitForReviewExtension {
    
    //Properties
    public SBQQ__Quote__c proposal { get; set; }
    public string redlineRecipient { get; set; }
    public string submissionType { get; set; }
    public Date expDate { get; set; }
    private string reviewerName { get; set; }
    private string reviewerEmail { get; set; }
    
    
    //Final Variables
    public static final string RADIO_OPTION_PRIMARY_CONTACT = 'PrimaryContact';
    public static final string RADIO_OPTION_PROPOSAL_OWNER = 'ProposalOwner';
    public static final string RADIO_OPTION_DEAL_DESK = 'DealDesk';
    public static final string RADIO_OPTION_LEGAL = 'Legal';
    public static final string SUBMISSION_TYPE_REDLINE = 'Redline';
    public static final string SUBMISSION_TYPE_SIGNATURE = 'Signature';
    
    //Variable to control the displaying elements on VF page
    public Boolean isSucceed {get;set;} 
    
    
    //Std Controller (Extension)
    public LOASubmitForReviewExtension(ApexPages.StandardController controller) {
        
        //Get Record
        proposal = (SBQQ__Quote__c) controller.getRecord();
        
        //inIt
        inIt();
        
    }
    
    //inIt method to define all the variable values and load all the Properties
    public void inIt() {
        
        //Set Properties
        isSucceed = false;
        
        //Default value
        redlineRecipient = RADIO_OPTION_PROPOSAL_OWNER;
        
        //Type of submission (redline or signature)
        submissionType = ApexPages.currentPage().getParameters().get('Type');
        
        
    }
    
    /**
     *  @description    :   Submit method to send LOA Document for review 
     *                      
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 05/2/2017 - Created - Victor Hanson 
     *
     **/
    public pageReference submit() {
        
        //try-catch
        try {
            
            //Check for Red Line submissionif it's sending for redline...
            if (submissionType.equalsIgnoreCase(SUBMISSION_TYPE_REDLINE)) {
                
                //Contact Instance
                Contact con = new Contact();
                
                //set the recipient details
                setReviewerNameAndEmail();
                
                //Set our Redline Approver to Legal.  VH updated 7/21/17
                proposal.Redline_Approver__c = 'Legal';
                
                //Set ExpDate
                expDate = proposal.External_Review_Due_Date__c;
                
                //Make sure the expDate is greater than today
                if (expDate == null || expDate <= date.today())
                    throw new customException('Expiration Date must be greater than today.');
                
                //verify the proposal is approved
                if (proposal.SBQQ__Status__c != 'Approved')
                    throw new customException('Status must be \'Approved\' before it can be sent for redline.');
                
                //Check for Id
                if(proposal.LOA_Word_Document_ID__c == null || !(proposal.LOA_Word_Document_ID__c instanceof Id))
                    throw new customException('Proposal should have correct LOA Word Document Id');
                
                //Check for Redline Approver value
                if (proposal.Redline_Approver__c == null)
                    throw new customException('Approver is required.');
                    
                //Redline process
                SpringCMHelper springHelper = new SpringCMHelper(proposal.Id);
                String externalGUID = springHelper.uploadDocument(proposal.LOA_Word_Document_ID__c, SpringCMHelper.springCMConfig.Folder_GUID__c, null);
                String externalGUID_Original = springHelper.uploadDocument(proposal.LOA_Word_Document_ID__c, Label.SpringCM_Original_LOA_Folder, proposal.Id);
                
                if(!test.isRunningTest()) {
                    //Check for error
                    if(ApexPages.hasMessages(ApexPages.Severity.ERROR))
                        return null;
                }
                
                //Update proposal with GUID of the uploaded doc
                proposal.External_Document_Original_GUID__c = externalGUID_Original;
                proposal.External_Document_GUID__c = externalGUID;
                springHelper.documentGUID = externalGUID; //set the documentGUID specifically to this version, so the correct one is sent for redlines.
                
                //submit for redline and get the GUID of the redline task from SpringCM
                string redlineGUID = springHelper.redlineReview(reviewerName, 
                                         reviewerEmail, 
                                         datetime.newInstance(expDate.year(), expDate.month(),expDate.day()),
                                         Label.Redline_Review_Email_Subject,
                                         Label.Redline_Review_Email_Body
                                        );
                //update the proposal with the GUID of the redline task
                proposal.External_Review_GUID__c = redlineGUID;
                proposal.SBQQ__DocumentStatus__c = Label.Document_Status_Sent_for_Redline;
                proposal.LOA_Non_Standard__c = true;
                
                //add SpringCM Attributes (Status)
                springHelper.addDocumentAttributes();
                
                //begin the SpringCM Workflow process
                springHelper.startSpringCMWorkflow_Redline();
                
                //Check for error
                if(ApexPages.hasMessages(ApexPages.Severity.ERROR))
                    return null;
                
                //Update Proposal   
                update proposal;
                
                //add success message
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Submitted for Redline'));
                
                //Set success to true 
                isSucceed = true;
            
            }
        } catch(DMLException dmlExp) {
            
            //Add Error on page
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,dmlExp.getDmlMessage(0)));
            
        } catch(Exception e) {
            system.debug('@@:' + e + e.getStackTraceString());
            //Add Error on page
            ApexPages.addMessages(e);
        }
        
        return null;
    }
    
    /**
     *  @description    :   sets the Name & Email of the redline recipient
     *                      
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 05/2/2017 - Created - Victor Hanson 
     *
     **/
    @TestVisible private void setReviewerNameAndEmail() {
        //Check for Recipient
        if(redlineRecipient.equalsIgnoreCase(RADIO_OPTION_PRIMARY_CONTACT)) {
            reviewerName = proposal.SBQQ__PrimaryContact__r.Name;
            reviewerEmail = proposal.SBQQ__PrimaryContact__r.Email;
        }
        else if (redlineRecipient.equalsIgnoreCase(RADIO_OPTION_PROPOSAL_OWNER)) {
            reviewerName = proposal.SBQQ__SalesRep__r.Name;
            reviewerEmail = proposal.SBQQ__SalesRep__r.Email;
        }
        else if (redlineRecipient.equalsIgnoreCase(RADIO_OPTION_DEAL_DESK)) {
            reviewerName = RADIO_OPTION_DEAL_DESK;
            reviewerEmail = Label.Proposal_Redline_DealDesk;
        }
        else if (redlineRecipient.equalsIgnoreCase(RADIO_OPTION_LEGAL)) {
            reviewerName = RADIO_OPTION_LEGAL;
            reviewerEmail = Label.Proposal_Redline_Legal;
        }
        
        proposal.Redline_Recipient_Name__c = reviewerName;
        proposal.Redline_Recipient_Email__c = reviewerEmail;
    }
}