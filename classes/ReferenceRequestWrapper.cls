/**
 *	Purpose			:	This class is to hold all the field's properties for Reference Request object.
 * 
 * 	Created By		:	Victor Hanson
 * 
 * 	Created Date	:	12/16/2015
 * 
 * Revision Logs	:	V_1.0 - Created
 * 						V_1.1 - Modified By - Abhinav Sharma - 03/31/2016 - CR-20160204-9586
 *
 **/ 
public without sharing class ReferenceRequestWrapper {
    
    //properties
    public string Name { get; set; }
    public string Id { get; set; }
    public string requestingInstitutionId { get; set; }
    public string requestingInstitution { get; set; }
    public string requestingContactId { get; set; }
    public string additionalContact1Id { get; set; }
    public string additionalContact1 { get; set; }
    public string additionalContact2Id { get; set; }
    public string additionalContact2 { get; set; }
    public string requestingContact { get; set; }
    public string sourceOpportunity { get; set; }
    public string sourceMembership { get; set; }
    public string sourceProject { get; set; }
    public string source { get; set; }
    public string submittedByName { get; set; }
    public string submittedDate { get; set; }
    public string recordTypeName { get; set; }
    public string requestingContactTitle { get; set; }
    public string requestStatus { get; set; }
    public string referenceModules { get; set; }
    public decimal numReferencesNeeded { get; set; }
    public string dateNeededBy { get; set; }
    public string referenceTypeNeeded { get; set; }
    public list<SelectOption> referenceTypeNeededOptions { get; set; }
    public string attributes { get; set; }
    public string anticipatedQuestionsBackgroundInfo { get; set; }
    public string submittedBy { get; set; }
    public string marketer { get; set; }
    public string marketerId { get; set; }
    public string institutionType { get; set; }
    public string recordTypeId { get; set; }
    public string sourceId { get; set; }
    public boolean showNextSteps { get; set; } //determines whether or not the "Next Steps" section of the ReferenceSelection VF page is visible
    
    //Added By - Abhinav Sharma - 03/31/2016 - CR-20160204-9586
    //Start from here
    public string selectionStatus { get; set; }
    public List<SelectOption> options { get; set; }
    //Upto here
    
    //list of reference recommendations
    public list<Recommendation> recommendations { get; set; }
    
    public list<SelectOption> attributeOptions {
        get {
            attributeOptions = new list<SelectOption>();
            if (referenceModules != null) {
                list<string> modules = referenceModules.split(ReferenceRequestController.DELIMITER);
                attributeOptions.add(new SelectOption('', ''));
                for (integer i = 0; i < modules.size(); i++) {
                    attributeOptions.add(new SelectOption(modules[i], modules[i]));
                }
            }
            return attributeOptions;
        }
        set;
    }
    
    /**
     * @description: 
     * 
     * @params: 
     * 
     * @return: 
     **/
    public ReferenceRequestWrapper(string reqId, string sourceRecordId) {
        getSource(sourceRecordId);
        
        if (reqId instanceOf Id) {
            Reference_Request__c req = [SELECT Id, Name, Request_Status__c, Selection_Status__c, Requesting_Institution__c, Requesting_Institution__r.Name, Source_Opportunity__c, Source_Membership__c, Source_Project__c, 
                                        Requesting_Contact__c, Requesting_Contact__r.Name, Requesting_Contact_Title__c, Reference_Modules__c, Number_of_References_Needed__c, Date_Needed_By__c, Reference_Type_Needed__c, 
                                        Attributes__c, Submitted_By__c, Source__c, Institution_Type__c, Marketer__c, RecordTypeId, Background_Info_Anticipated_Questions__c,
                                        Submitted_By__r.Name, Date_Submitted__c, RecordType.Name, Source_Id__c, Marketer__r.Name, 
                                        Additional_Contact_1__c, Additional_Contact_2__c, Additional_Contact_1__r.Name, Additional_Contact_2__r.Name,
                                        (SELECT Id, Reference_Contact__c, Reference_Contact__r.Name, Reference_Contact__r.Account.Name, Reference_Contact__r.Title, 
                                         Reference_Modules__c, Reference_Attributes__c, Reference_Contact__r.Account.Institution_Reference_Flag__c, 
                                         Reference_Contact__r.Contact_Reference_Flag__c, Approval_Status__c, Reference_Contact_Comments__c
                                         FROM Reference_Request_Contacts__r ORDER BY CreatedDate ASC)
                                       FROM Reference_Request__c WHERE Id = :reqId];
            populateFields(req);
        }
        
        //setup picklist
        referenceTypeNeededOptions = ReferenceRequestHelper.getSelectOptionListByField('Reference_Request__c', 'Reference_Type_Needed__c');
    }
    
    private void populateFields(Reference_Request__c req) {
        Id = req.Id;
        Name = req.Name;
        requestingInstitutionId = req.Requesting_Institution__c;
        requestingInstitution = req.Requesting_Institution__r.Name;
        requestingContactId = req.Requesting_Contact__c;
        additionalContact1Id = req.Additional_Contact_1__c;
        additionalContact1 = req.Additional_Contact_1__r.Name;
        additionalContact2Id = req.Additional_Contact_2__c;
        additionalContact2 = req.Additional_Contact_2__r.Name;
        requestingContact = req.Requesting_Contact__r.Name;
        requestingContactTitle = req.Requesting_Contact_Title__c;
        referenceModules = req.Reference_Modules__c;
        requestStatus = req.Request_Status__c;
        numReferencesNeeded = req.Number_of_References_Needed__c;
        dateNeededBy = req.Date_Needed_By__c != null ? req.Date_Needed_By__c.format() : null;
        referenceTypeNeeded = req.Reference_Type_Needed__c;
        attributes = req.Attributes__c;
        anticipatedQuestionsBackgroundInfo = req.Background_Info_Anticipated_Questions__c;
        submittedBy = req.Submitted_By__c;
        source = req.Source__c != null ? req.Source__c : null;
        marketer = req.Marketer__r.Name;
        institutionType = req.Institution_Type__c;
        recordTypeId = req.RecordTypeId;
        submittedByName = req.Submitted_By__r.Name;
        submittedDate = req.Date_Submitted__c != null ? req.Date_Submitted__c.format() : null;
        recordTypeName = req.RecordType.Name;
        sourceId = req.Source_Id__c;
        showNextSteps = false;
        
        //Added By - Abhinav Sharma - 03/31/2016 - CR-20160204-9586
    	//Start from here
        selectionStatus = req.Selection_Status__c;
        options = new List<SelectOption>();
        options.add(new SelectOption(ReferenceRequestController.PICKLIST_OPTION_NONE, ReferenceRequestController.PICKLIST_OPTION_NONE));
        
        //Dynamically retrieving "Selection Status" picklist field options
        Schema.DescribeFieldResult F = Reference_Request__c.Selection_Status__c.getDescribe();
        List<schema.picklistentry> typeList = F.getPicklistValues();
          
        //Populating select option list with options
        for (Schema.PicklistEntry typeItem : typeList) {
            options.add(new SelectOption(typeItem.getLabel(), typeItem.getValue()));  
        }
        //Upto here
        
        //get the recommendation info
        recommendations = getRecommendations(req.Reference_Request_Contacts__r);
    }
    
    private list<Recommendation> getRecommendations(list<Reference_Request_Contact__c> rrcList) {
        list<Recommendation> refReqContacts = new list<Recommendation>();
        
        //Added By - Abhinav Sharma - 04/11/2016 - CR-20160204-9586
        //Start from here
        //Set to hold the "Reference Contact" Ids which are currently having pending approval request                
        set<Id> existingApprovalsSet = new set<Id>();
        
        //Checking list for null and size value
        if(rrcList != null && rrcList.size() > 0) {
            
            //Retrieving existing approvals
            list<ProcessInstance> existingApprovals = [SELECT Id, TargetObjectId
                                                       FROM ProcessInstance 
                                                       WHERE TargetObjectId IN :rrcList];
            
            //Populating set to hold records Ids
            if(existingApprovals.size() != 0) {
                for(ProcessInstance e : existingApprovals)
                    existingApprovalsSet.add(e.TargetObjectId);
            }
        }
        //Upto here
               
        //get recommendations with contact info
        for (Reference_Request_Contact__c rrc : rrcList) {
            
            refReqContacts.add(new Recommendation(rrc, existingApprovalsSet.contains(rrc.Id)));
            //set showNextSteps = true if approval status is Released
            if (rrc.Approval_Status__c == 'Released') showNextSteps = true;
        }    
        
        return refReqContacts;
    }
    
    private void getSource(string recordIdString) {
        Id sourceId = null;
        string sourceObjectAPIName;
        if (recordIdString instanceOf Id) {
            sourceId = recordIdString;
            sourceObjectAPIName = sourceId.getSobjectType().getDescribe().getName();
            
            //set the source name
            string query = 'SELECT Id, Name FROM ' + sourceObjectAPIName + ' WHERE Id = :sourceId';
            list<SObject> objs = database.query(query);
            if (objs.size() > 0) {
                source = (string)objs[0].get('Name');
            }
            
            //set the source record id in the proper field
            if (sourceObjectAPIName == 'Opportunity') sourceOpportunity = sourceId;
            else if (sourceObjectAPIName == 'Membership__c') sourceMembership = sourceId;
            else if (sourceObjectAPIName == 'Project__c') sourceProject = sourceId;
        }
    }
    
    /**
     * @description: class is used to hold the reference recommendations
     * 
     **/
    public class Recommendation {
        public boolean isSelected { get; set; }
        public string Id { get; set; }
        public string institutionName { get; set; }
        public string institutionReferenceFlag { get; set; }
        public string contactId { get; set; }
        public string contactName { get; set; }
        public string contactReferenceFlag { get; set; }
        public string contactTitle { get; set; }
        public string modules { get; set; }
        public string attributes { get; set; }
        public string approvalStatus { get; set; }
        public string referenceContactComments { get; set; }
        public boolean isSubmitted { get; set; }
        
        public Recommendation(Reference_Request_Contact__c rrc, boolean isSubmitted) {
            isSelected = false;
            Id = rrc.Id;
            institutionName = rrc.Reference_Contact__r.Account.Name;
            institutionReferenceFlag = rrc.Reference_Contact__r.Account.Institution_Reference_Flag__c;
            contactId = rrc.Reference_Contact__c;
            contactName = rrc.Reference_Contact__r.Name;
            contactReferenceFlag = rrc.Reference_Contact__r.Contact_Reference_Flag__c;
            contactTitle = rrc.Reference_Contact__r.Title;
            modules = rrc.Reference_Modules__c != null ? rrc.Reference_Modules__c.replaceAll('\r\n', '<br/>') : null;
            attributes = rrc.Reference_Attributes__c != null ? rrc.Reference_Attributes__c.replaceAll('\r\n', '<br/>') : null;
            approvalStatus = rrc.Approval_Status__c;
            referenceContactComments = rrc.Reference_Contact_Comments__c;
            this.isSubmitted = isSubmitted;
        }
    }
}