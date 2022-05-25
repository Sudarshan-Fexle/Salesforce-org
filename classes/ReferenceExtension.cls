/**
 *  Description     :  Extension class for the ReferenceModule VF Page
 *
 *  Revision Logs   :   V_1.0 - Created - Victor Hanson - Reference Tracking project (CR-20150826-9191)
 * 			V_1.1 - Modified By Dipesh Gupta - 10/07/2019 - CR-20190919-13355 - Commented NASA_Associate_Principal__c as per requirment
 			V_1.2 - Modified By Mahendra Swarnkar - 02/03/2020 - CR-20200217-13756
 **/
public class ReferenceExtension {
    
	public Reference__c reference { get; set; }
    private ApexPages.StandardController stdController { get; set; }
    public boolean isNew {
        get {
            return reference.Id == null;
        }
        set;
    }
    
    //return url
    @testVisible
    private string retURL {
        get {
            if (retURL == null) {
                retURL = ApexPages.currentPage().getParameters().get('retURL');
                if (retURL == null) retURL = '/'; //if there is no return url -- set the default
            }
            return retURL;
        }
        set;
    }
    
    /**
     * @description: constructor
     **/
    public ReferenceExtension(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        //setup the initial reference perk
        reference = (Reference__c)stdController.getRecord();
        
        if (isNew) {
            //default submitted by to the current user
            reference.Submitted_By__c = UserInfo.getUserId();
            //set the institution based on the contact
            setInstitution();
        }
    }
    
    /**
     * @description: override the standard save functionality so we can present the user with user-friendly error messages
     **/
    public pageReference save() {
        PageReference pg;
        
        try {
            upsert reference;
            pg = new PageReference(retURL);
        } catch(DMLException ex) {
            // add any error to the result that is returned on the VF page.
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getDMLMessage(0)));
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage() + '\r\n' + ex.getStackTraceString()));
        }
        
        return pg;
    }
    
    /**
     * @description: set the institution for the reference module based on the contact selected
     **/
    public void setInstitution() {
        //get the institution for the contact
        list<Contact> cons = [SELECT Id, AccountId, Account.RecordType.DeveloperName, Account.Principal__c, Account.Associate_Principal__c FROM Contact WHERE Id = :reference.Contact_Name__c];
        if (cons.size() > 0) {
            reference.Institution__c = cons[0].AccountId;
            
            //Commneted by Mahendra Swarnkar - 02/03/2020 - CR-20200217-13756
            //default the member type to NASA if related contact's institution is US Provider Strategic and the Principal field is populated
            if (/*cons[0].Account.RecordType.DeveloperName == 'US_Provider_Strategic' &&*/ cons[0].Account.Principal__c != null) {
                reference.Member_Type__c = 'NASA';
                reference.NASA_Principal__c = cons[0].Account.Principal__c;        	    
                //Modified By Dipesh Gupta - 10/07/2019 - CR-20190919-13355 - Commented NASA_Associate_Principal__c as per requirment 
                //reference.NASA_Associate_Principal__c = cons[0].Account.Associate_Principal__c;

            }
        }
    }
    
    /**
     * @description: when a user selects a membership, it should auto-populate the Dedicated Advisor field
     **/
    public void setDedicatedAdvisor() {
        if (reference.Dedicated_Advisor__c == null) {
            list<Membership__c> mems = [SELECT Id, Primary_Project__c, Primary_Project__r.Dedicated_Advisor__c, Program__c, 
                                        Active_Contract_Idenfied__r.Payer_Account__c
                                        FROM Membership__c WHERE Id = :reference.Membership__c];
            if (mems.size() > 0) {
                if (mems[0].Primary_Project__c != null)
                	reference.Dedicated_Advisor__c = mems[0].Primary_Project__r.Dedicated_Advisor__c;
                else if (mems[0].Active_Contract_Idenfied__r.Payer_Account__c != null) {
                    //get the membership of the Active Contract's member payer account
                    list<Membership__c> payerMemberships = [SELECT Id, Primary_Project__c, Primary_Project__r.Dedicated_Advisor__c 
                                                            FROM Membership__c 
                                                            WHERE Account_Name__c = :mems[0].Active_Contract_Idenfied__r.Payer_Account__c
                                                            AND Program__c = :mems[0].Program__c];
                    if (payerMemberships[0].Primary_Project__c != null)
                        reference.Dedicated_Advisor__c = payerMemberships[0].Primary_Project__r.Dedicated_Advisor__c;
                }
            }
        }
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
    
    /** get the record type id **/
    public Id recordTypeId {
        get {
            if (recordTypeId == null) {
                if (ApexPages.currentPage().getParameters().get('RecordType') != null)
                    recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
                else if (reference.RecordTypeId != null)
                    recordTypeId = reference.RecordTypeId;
                else
                    recordTypeId = ReferenceModuleHelper.getDefaultRecordTypeId('Reference__c');
            }
            return recordTypeId;
        }
        set;
    }
    
    /** get the record type name **/
    public string recordTypeName {
        get {
            if (recordTypeName == null && recordTypeId != null)
                recordTypeName = [SELECT Name FROM RecordType WHERE Id = :recordTypeId].Name;
            return recordTypeName;
        }
        set;
    }
}