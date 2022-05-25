/**
 *	Purpose			:	Controller class used on the ReferenceRequest_New and ReferenceSelection VF page
 * 
 * 	Created By		:	Victor Hanson
 * 
 * 	Created Date	:	12/16/2015
 * 
 * Revision Logs	:	V_1.0 - Created
 * 						V_1.1 - Modified By - Abhinav Sharma - 03/31/2016 - CR-20160204-9586
 *                      V_1.2 - Modified By - Victor Hanson - 04/29/2019 - CR-20190425-13033 - removed references to reference_availability__c
 *
 **/ 
public without sharing class ReferenceRequestController {
    
    public static final string DELIMITER = '; ';
    public static final string STATUS_SELECTED = 'Selected';
    public static final string STATUS_SEARCH = 'Search';
    public static final string ERROR_MUST_SELECT_ONE_RECOMMENDATION = 'At least one Reference Request Contact must be selected';
    public static final string SELECTION_STATUS_NEED_ADDITIONAL_REFERENCE_RECOMMENDATIONS = 'Need Additional Reference Recommendations';
    public static final string PICKLIST_OPTION_NONE = '--none--';
    
    /** **/
    public string recordTypeName {
        get {
            if (wrapper.recordTypeId != null)
                recordTypeName = [SELECT Name FROM RecordType WHERE Id = :wrapper.recordTypeId].Name;
            return recordTypeName;
        }
        set;
    }
    
    /**
     * @description: if the status is recommended, return true.  This determines whether or not the ReferenceSelection VF page options are editable
     **/
    public boolean isRecommended {
        get {
            return wrapper.requestStatus == ReferenceRequestExtension.STATUS_RECOMMENDED;
        }
        set;
    }
    
    //properties
    public boolean isSaved { get; set; }
    public ReferenceRequestWrapper wrapper { get; set; }
    public string referenceModuleInput1 { get; set; }
    public string referenceModuleInput2 { get; set; }
    public string referenceModuleInput3 { get; set; }
    public string referenceModuleInput4 { get; set; }
    public string referenceModuleInput5 { get; set; }
    //picklist properties
    public string attributePicklist1 { get; set; }
    public string attributePicklist2 { get; set; }
    public string attributePicklist3 { get; set; }
    public string attributePicklist4 { get; set; }
    public string attributePicklist5 { get; set; }
    //module properties
    public string attributeModule1 { get; set; }
    public string attributeModule2 { get; set; }
    public string attributeModule3 { get; set; }
    public string attributeModule4 { get; set; }
    public string attributeModule5 { get; set; }
    
    /**
     *  @description    :   constructor
     *              
     *  @args           :   null
     * 
     *  @return         :   void
     * 
     **/
    public ReferenceRequestController() {
        wrapper = new ReferenceRequestWrapper(ApexPages.currentPage().getParameters().get('Id'), ApexPages.currentPage().getParameters().get('SourceId'));
        
        //setup the reference module inputs
        initRefModuleInputs();
        isSaved = false;
    }
    
    /**
     *  @description    :   populate the reference module input fields with the selected values
     *              
     *  @args           :   null
     * 
     *  @return         :   void
     * 
     **/
    @testVisible
    private void initRefModuleInputs() {
        if (wrapper.referenceModules != null) {
            list<string> modules = wrapper.referenceModules.split(DELIMITER);
            for (integer i = 0; i < modules.size(); i++) {
                if (i == 0) referenceModuleInput1 = modules[i];
                else if (i == 1) referenceModuleInput2 = modules[i];
                else if (i == 2) referenceModuleInput3 = modules[i];
                else if (i == 3) referenceModuleInput4 = modules[i];
                else if (i == 4) referenceModuleInput5 = modules[i];
            }
        }
    }
    
    /**
     *  @description    :   update the Reference Module(s) field with a semi-colon delimited list of modules
     *              
     *  @args           :   null
     * 
     *  @return         :   void
     * 
     **/
    public void updateModules() {
        list<string> modules = new list<string>();
        if (referenceModuleInput1 != null && referenceModuleInput1 != '') modules.add(referenceModuleInput1);
        if (referenceModuleInput2 != null && referenceModuleInput2 != '') modules.add(referenceModuleInput2);
        if (referenceModuleInput3 != null && referenceModuleInput3 != '') modules.add(referenceModuleInput3);
        if (referenceModuleInput4 != null && referenceModuleInput4 != '') modules.add(referenceModuleInput4);
        if (referenceModuleInput5 != null && referenceModuleInput5 != '') modules.add(referenceModuleInput5);
        wrapper.referenceModules = string.join(modules, DELIMITER);
    }
    
    
    public void updateAttributes() {
        list<string> attributes = new list<string>();
        if (attributeModule1 != null && attributeModule1 != '') attributes.add(attributePicklist1 + ': ' + attributeModule1);
        if (attributeModule2 != null && attributeModule2 != '') attributes.add(attributePicklist2 + ': ' + attributeModule2);
        if (attributeModule3 != null && attributeModule3 != '') attributes.add(attributePicklist3 + ': ' + attributeModule3);
        if (attributeModule4 != null && attributeModule4 != '') attributes.add(attributePicklist4 + ': ' + attributeModule4);
        if (attributeModule5 != null && attributeModule5 != '') attributes.add(attributePicklist5 + ': ' + attributeModule5);
        wrapper.attributes = string.join(attributes, DELIMITER);
    }
    
    /**
     *  @description    :   directs the user back to the return url
     *              
     *  @args           :   null
     * 
     *  @return         :   void
     * 
     **/
    public pageReference cancel() {
        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        if (retURL == null || retURL == '') retURL = '/';
        return new pageReference(retURL);
    }
    
    /**
     *  @description    :   save the reference request record
     *              
     *  @args           :   null
     * 
     *  @return         :   pageReference
     * 
     **/
    public pageReference save() {
        
        Reference_Request__c req = new Reference_Request__c();
        
        try{
            req.Requesting_Institution__c = wrapper.requestingInstitutionId != '' ? wrapper.requestingInstitutionId : null;
            req.Source_Opportunity__c = wrapper.sourceOpportunity;
            req.Source_Membership__c = wrapper.sourceMembership;
            req.Source_Project__c = wrapper.sourceProject;
            req.Requesting_Contact__c = wrapper.requestingContactId != '' ? wrapper.requestingContactId : null;
            req.Additional_Contact_1__c = wrapper.additionalContact1Id != '' ? wrapper.additionalContact1Id : null;
            req.Additional_Contact_2__c = wrapper.additionalContact2Id != '' ? wrapper.additionalContact2Id : null;
            req.Reference_Modules__c = wrapper.referenceModules;
            req.Number_of_References_Needed__c = wrapper.numReferencesNeeded;
            req.Date_Needed_By__c = wrapper.dateNeededBy != '' ? date.parse(wrapper.dateNeededBy) : null;
            req.Reference_Type_Needed__c = wrapper.referenceTypeNeeded;
            req.Attributes__c = wrapper.attributes;
            req.Background_Info_Anticipated_Questions__c = wrapper.anticipatedQuestionsBackgroundInfo;
            req.Submitted_By__c = userinfo.getUserId();
            req.Date_Submitted__c = dateTime.now();
            req.Institution_Type__c = wrapper.institutionType;
            req.Marketer__c = wrapper.marketerId != '' ? wrapper.marketerId : null;
            req.RecordTypeId = wrapper.recordTypeId != '' ? wrapper.recordTypeId : null;
            
            //Added By - Abhinav Sharma - 03/31/2016 - CR-20160204-9586
            //Start from here
            req.Selection_Status__c = wrapper.selectionStatus;
            //Upto here
            
            //validate prior to upsert
            ReferenceRequestHelper.validateReferenceRequest(req);
            
            upsert req;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
            return null;
        }
        
        req = [SELECT Name FROM Reference_Request__c WHERE Id = :req.Id];
        string msg = 'Your request has been submitted.  Your reference number is <b>' + req.Name + '</b>';
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,msg)); 
        isSaved = true;
        return null;
    }
    
    //Modified By - Abhinav Sharma - 03/31/2016 - CR-20160204-9586
    /**
     *  @description    :   confirm selection of reference request contacts.
     *              
     *  @args           :   null
     * 
     *  @return         :   pageReference
     * 
     **/
    public pageReference submitSelection() {
        
        //create a savepoint to rollback the transaction in case of exception
		SavePoint sp = Database.setSavePoint();
        
        try {
            
            //Added By - Abhinav Sharma - 03/31/2016 - CR-20160204-9586
            //Start from here
            if(wrapper.selectionStatus == ReferenceRequestController.PICKLIST_OPTION_NONE)
                throw new customException(System.Label.ERROR_MUST_SELECT_SELECTION_STATUS);
            //Upto here
            
            //If Selection Status equals to "Need Additional Reference Recommendations" then there is no need to validate for
            //atleast one recommandation selection
            if(String.isNotBlank(wrapper.selectionStatus)
            	&& wrapper.selectionStatus != ReferenceRequestController.SELECTION_STATUS_NEED_ADDITIONAL_REFERENCE_RECOMMENDATIONS) {
             	
                //ensure that at least one recommendation has been selected
            	integer numSelected = 0;
            	for (ReferenceRequestWrapper.Recommendation recommendation : wrapper.recommendations)
                	if (recommendation.isSelected) numSelected++;
            	if (numSelected == 0) 
                	throw new customException(ERROR_MUST_SELECT_ONE_RECOMMENDATION);
            }
            
            //update reference request status to "Selected"
            Reference_Request__c req = new Reference_Request__c(Id = wrapper.Id,
                                                                Request_Status__c = STATUS_SELECTED);
            wrapper.requestStatus = STATUS_SELECTED;
            
            //Added By - Abhinav Sharma - 03/31/2016 - CR-20160204-9586
            //Start from here
            // If the user chooses "Need Additional Reference Recommendations" value for "Selection Status" 
            // then while saving their reference selections, also set the Reference Request's Status to "Search". 
            // This will allow the Reference Lead to add more References.
            if(String.isNotBlank(wrapper.selectionStatus)
            	&& wrapper.selectionStatus == ReferenceRequestController.SELECTION_STATUS_NEED_ADDITIONAL_REFERENCE_RECOMMENDATIONS)
            	req.Request_Status__c = ReferenceRequestController.STATUS_SEARCH;
            //Upto here
            
            //Setting selectio status
            req.Selection_Status__c = wrapper.selectionStatus;
            update req;
            
            list<Contact> consToUpdate = new list<Contact>();
            set<Id> refReqConsToSubmit = new set<Id>();
            list<Reference_Request_Contact__c> refReqConsToDelete = new list<Reference_Request_Contact__c>();
            for (integer i = 0; i < wrapper.recommendations.size(); i++) {
                ReferenceRequestWrapper.Recommendation recommendation = wrapper.recommendations[i];
                if (recommendation.isSelected) {
                    //update reference request.Contact.Reference Availability to "Hold"
                    Contact c = new Contact(Id = recommendation.contactId);
                    consToUpdate.add(c);
                    refReqConsToSubmit.add(recommendation.Id);
                }
                else if (!recommendation.isSelected && !recommendation.isSubmitted) {
                    refReqConsToDelete.add(new Reference_Request_Contact__c(Id=recommendation.Id));
                    //remove the unselected recommendation from the list so it's not visible when the page rerenders
                    wrapper.recommendations.remove(i);
                }
            }
            //perform the necessary updates / deletes
            if (consToUpdate.size() > 0) update consToUpdate;
            
            if (refReqConsToDelete.size() > 0) delete refReqConsToDelete;
            
            if (refReqConsToSubmit.size() > 0) {
                //submit all reference request contacts for approval
                ReferenceRequestContactHelper.submitForApproval(refReqConsToSubmit);
            }
        }
        catch(Exception e){
            
            //rollback the transaction
			database.rollback(sp);
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
            system.debug('@@stack trace:' + e.getStackTraceString());
            return null;
        }
        
        //add confirmation message
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Reference options submitted')); 
        return null;
    }
    
    /**
     * @description: return a JSON encoded map of dependent picklist values
     **/
    public string attributes {
        get {
            map<string, list<PicklistHelper.PicklistWrapper>> picklistDependencyMap = new PicklistHelper('Reference__c', 'Field_A__c', 'Picklist Usage').getWrapperMap();
            return JSON.serialize(picklistDependencyMap);
        }
        set;
    }
    
    public string contactLookupId { get; set; }
    public string contactName { get; set; }
    public string lookupField { get; set; }
    
    /**
     * @description: populates the requesting institution when a contact is selected
     **/
    public void identifyContact() {
        system.debug('@@@fld:' + lookupField + '  cName:' + contactName + '  cId:' + contactLookupId);
        string whereClause = 'Id = \'' + contactLookupId + '\'';
        if (contactLookupId == null) whereClause = 'Name LIKE \'%' + string.escapeSingleQuotes(contactName) + '%\'';
        list<Contact> contacts = database.query('SELECT Id, Name, Title, AccountId, Account.Name FROM Contact WHERE ' + whereClause);
        if (contacts.size() == 1) {
            if (lookupField == 'Contact') {
                wrapper.requestingInstitution = contacts[0].Account.Name;
                wrapper.requestingInstitutionId = contacts[0].AccountId;
                wrapper.requestingContact = contacts[0].Name;
                wrapper.requestingContactId = contacts[0].Id;
                wrapper.requestingContactTitle = contacts[0].Title;
                list<Membership__c> activeMemberships = [SELECT Id FROM Membership__c WHERE Account_Name__c = :contacts[0].AccountId AND Membership_Status__c LIKE 'Member%'];
                if (activeMemberships.size() > 0) wrapper.institutionType = 'Existing Member';
                else wrapper.institutionType = 'Prospective Member';
            }
            else if (lookupField == 'Contact1') {
                wrapper.additionalContact1Id = contacts[0].Id;
                wrapper.additionalContact1 = contacts[0].Name;
            }
            else if (lookupField == 'Contact2') {
                wrapper.additionalContact2Id = contacts[0].Id;
                wrapper.additionalContact2 = contacts[0].Name;
            }
        }
        else if (contacts.size() > 1) {
            ReferenceRequestHelper.displayErrorMessages('Multiple Contacts matched the search criteria.  Please click the lookup icon to select the correct Contact.');
        }
        else if (contacts.size() == 0) {
            ReferenceRequestHelper.displayErrorMessages('No Contacts were found.  Please click the lookup icon to find a Contact.');
        }
    }
    
    /**
     * @description: record type picklist values
     **/
    public list<SelectOption> recordTypeOptions {
        get {
            if (recordTypeOptions == null) {
                recordTypeOptions = new list<SelectOption>();
                recordTypeOptions.add(new SelectOption('', '--None--'));
                for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Reference_Request__c']) {
                    recordTypeOptions.add(new SelectOption(rt.Id, rt.Name));
                }
            }
            return recordTypeOptions;
        }
        set;
    }
    
}