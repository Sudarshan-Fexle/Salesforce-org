/**
 *  Purpose         :   Used to track undeliverable physical mailings from Mailing Campaigns.
 *
 *  Created By      :   Victor Hanson
 *
 *  Created Date    :   06/19/2014
 *
 *  Current Version :   v1.0 - Created
 *
 **/
public without sharing class LogUndeliverableMailController {
	
    //search parameter used by the barcode scanner
    public string mailPieceId { get; set; }
    
    //manual search parameters
    public string firstName { get; set; }
    public string lastName { get; set; }
    public string addressLine1 { get; set; }
    public string addressLine2 { get; set; }
    public string addressLine3 { get; set; }
    public string city { get; set; }
    public string state { get; set; }
    public string postalCode { get; set; }
    public string country { get; set; }
    
    //determines the type of search
    public string searchType { get; set; }
    public final string SEARCH_TYPE_BARCODE = 'BARCODE';
    public final string SEARCH_TYPE_MANUAL = 'MANUAL';
    public boolean displaySearchResults { get; set; }
    public string iconType { get; set; }
    
    //list to hold CampaignMembers found via findCampaignMembers method
    public list<CampaignMember> campaignMemberList { get; set; }
    
    //the base SOQL query for the findCampaignMembers query
    private static final string CAMPAIGN_MEMBER_SOQL_SELECT = 'SELECT Id, Contact.FirstName, Contact.LastName, Contact.Primary_Address_Line_1__c, '
        													+ 'Contact.Primary_Address_Line_2__c, Contact.Primary_Address_Line_3__c, Contact.Primary_City__c, '
        													+ 'Contact.Primary_State_Province__c, Contact.Primary_Postal_Code__c, Contact.Primary_Country__c, '
        													+ 'ContactId, Contact.Num_Undeliverable_Mailings__c, Campaign.Name, Undeliverable__c '
        													+ ' FROM CampaignMember';
	
	/**
	 * @description:	constructor
	 * 
     * @params:			
	 **/    
    public LogUndeliverableMailController() {
        
        //set the default search type to barcode
        searchType = SEARCH_TYPE_BARCODE;
    }
    
    /**
     * @description:	find Campaign Member(s) that meet the search criteria.  
     * 					If only one is found, update the undeliverable flag on the Campaign Member 
     * 					and add +1 to the # Undeliverable Mailings field on the related contact.
     * 
     * @params:			
    **/
    public pageReference findCampaignMembers() {
        
        //reset the icon type
        iconType = null;
        
        //return null if there are errors
        if (hasErrors) return null;
        
        //boolean to determine whether or not to display 'no results found' msg if campaignMemberList size is zero
        displaySearchResults = true;
        
        //get all campaign members matching the search criteria provided
        campaignMemberList = database.query(CAMPAIGN_MEMBER_SOQL_SELECT + whereClause);
        
        if (campaignMemberList.size() == 0) {
            iconType = ApexPages.Severity.WARNING.name();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No campaign member found with that criteria'));
        }
        else if (campaignMemberList.size() == 1) {
            
            recordUndeliverableMail();
        }
        else {
            
            iconType = ApexPages.Severity.INFO.name();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 
                                                       'Multiple Campaign Members found with that criteria.  Please select the correct record.'));
        }
        
        mailPieceId = null;
        
        return null;
    }
    
    //the where clause used in the findCampaignMembers method
    private string whereClause {
        get {
            whereClause = '';
            
            if (!isNull(mailPieceId)) {
                mailPieceId = mailPieceId.trim();
                whereClause = ' Mail_Piece_Id__c = :mailPieceId';
            }
            if (!isNull(firstName)) {
                if (whereClause != '') whereClause += ' AND ';
                whereClause += ' Contact.FirstName = :firstName';
            }
            if (!isNull(lastName)) {
                if (whereClause != '') whereClause += ' AND ';
                whereClause += ' Contact.LastName = :lastName';
            }
            if (!isNull(addressLine1)) {
                if (whereClause != '') whereClause += ' AND ';
                whereClause += ' Contact.Primary_Address_Line_1__c = :addressLine1';
            }
            if (!isNull(addressLine2)) {
                if (whereClause != '') whereClause += ' AND ';
                whereClause += ' Contact.Primary_Address_Line_2__c = :addressLine2';
            }
            if (!isNull(addressLine3)) {
                if (whereClause != '') whereClause += ' AND ';
                whereClause += ' Contact.Primary_Address_Line_3__c = :addressLine3';
            }
            if (!isNull(city)) {
                if (whereClause != '') whereClause += ' AND ';
                whereClause += ' Contact.Primary_City__c = :city';
            }
            if (!isNull(state)) {
                if (whereClause != '') whereClause += ' AND ';
                whereClause += ' Contact.Primary_State_Province__c = :state';
            }
            if (!isNull(postalCode)) {
                if (whereClause != '') whereClause += ' AND ';
                whereClause += ' Contact.Primary_Postal_Code__c = :postalCode';
            }
            if (!isNull(country)) {
                if (whereClause != '') whereClause += ' AND ';
                whereClause += ' Contact.Primary_Country__c = :country';
            }
            
            //add 'WHERE ' to the beginning of the whereClause
            whereClause = ' WHERE ' + whereClause;
            return whereClause;
        }
        set;
    }
    
    //returns true if the required fields are not populated
    private boolean hasErrors {
        get {
            
            if (isNull(mailPieceId) && (isNull(firstName) || isNull(lastName) || isNull(addressLine1))) {
                iconType = ApexPages.Severity.ERROR.name();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ERROR_UNDELIVERABLE_MAIL_SEARCH_REQ_FIELDS));
                return true;
            }
            return false;
        }
        set;
    }
    
    //clear the search criteria and all results
    public void clearSearchResults() {
        
        clearSearchCriteria();
        campaignMemberList = null;
    }
    
    //clear the search criteria
    public void clearSearchCriteria() {
        mailPieceId = null;
        firstName = null;
        lastName = null;
        addressLine1 = null;
        addressLine2 = null;
        addressLine3 = null;
        city = null;
        state = null;
        postalCode = null;
        country = null;
    }
    
    /**
     * @description: Update the campaign member as undeliverable
     * 
    **/
    public void recordUndeliverableMail() {
        
        CampaignMember cm;
        
        try {
            
            //if there is more than one campaign member, check which one the user selected
            if (campaignMemberList != null && campaignMemberList.size() > 1) {
                
                //create a map of campaign members
                map<Id, CampaignMember> cmMap = new map<Id, CampaignMember>(campaignMemberList);
                string campaignMemberId = ApexPages.currentPage().getParameters().get('campaignMemberId');
                cm = cmMap.get(campaignMemberId);         
            }
            else { //otherwise, use the first item in the list
                
                cm = campaignMemberList[0];
            }
             
            if (cm.Undeliverable__c) {
                
                //undeliverable mail already recorded for this Campaign Member record
                iconType = ApexPages.Severity.ERROR.name();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                           'Undeliverable Mail already recorded for ' + cm.Contact.FirstName
                                                           + ' ' + cm.Contact.LastName + ' in Campaign ' 
                                                           + cm.Campaign.Name));
                return;
            }
            
            cm.Undeliverable__c = true;
            
            update cm;
            
            //add a success message to the page
            iconType = ApexPages.Severity.CONFIRM.name();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 
                                                       'Undeliverable Mail recorded for ' + cm.Contact.FirstName
                                                       + ' ' + cm.Contact.LastName));
            //reset the search criteria and results
            clearSearchResults();
        }
        catch(DMLException e) {
            //Return errors to the VF Page
            iconType = ApexPages.Severity.ERROR.name();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                       e.getDMLMessage(0)));
        }
        catch(Exception e) {
            //Return errors to the VF Page
            iconType = ApexPages.Severity.ERROR.name();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                       e.getMessage()));
        }
        
    }
    
    public static boolean isNull(string value) {
        if (value == null || value.trim() == '') return true;
        return false;
    }
}