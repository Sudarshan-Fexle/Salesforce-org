/**
 *  Description     :   Helper class for ReferenceRequestController class.
 *
 *  Created By      :   
 *
 *  Created Date    :   2/17/2016
 *
 *  Revision Logs   :   V_1.0 - Created
                        V_1.1 - Modified By - Mahendra Swarnkar - CR-20160830-10157 - 09/02/2016 - Modified the method "validateReferenceRequest" - Updated if condition for "Reference_Modules__c" to have check for null/blank
**/
public without sharing class ReferenceRequestHelper {
  
    /**
     *  @description    :   These method is used to display Info on the Page.
     *
     *  @args           :   Error Message as String
     *
     *  @return         :   void
     *
     **/
     public static void displayErrorMessages(String msg){
        
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,msg);            
        ApexPages.addMessage(myMsg);        
     }
    
    //Modified By - Mahendra Swarnkar - CR-20160830-10157 - 09/02/2016 - Updated if condition for "Reference_Modules__c" to have check for null/blank
    public static void validateReferenceRequest(Reference_Request__c req) {
        list<string> errorMessages = new list<string>();
        if (req.Requesting_Contact__c == null) errorMessages.add(Schema.Reference_Request__c.fields.Requesting_Contact__c.getDescribe().getLabel());
        if (String.isBlank(req.Reference_Modules__c)) errorMessages.add(Schema.Reference_Request__c.fields.Reference_Modules__c.getDescribe().getLabel());
        if (req.Number_of_References_Needed__c == null || req.Number_of_References_Needed__c <= 0) errorMessages.add(Schema.Reference_Request__c.fields.Number_of_References_Needed__c.getDescribe().getLabel());
        if (req.Date_Needed_By__c == null) errorMessages.add(Schema.Reference_Request__c.fields.Date_Needed_By__c.getDescribe().getLabel());
        if (req.RecordTypeId == null) errorMessages.add('Reference Request Type');
        //add errors to page
        string msg = 'Please populate the fields below:<br/><ul>';
        for (string s : errorMessages) msg += '<li>' + s + '</li>';
            msg += '</ul>';
      if (errorMessages.size() > 0) throw new customException(msg);
    }
    
    //This method is to create a select option list for given Picklist Entries
    public static List<SelectOption> getSelectOptionListByField(String objectName, String fieldName) {
        
        //Describe field and create a list of select options  
        List<SelectOption> listOptions = new List<SelectOption>();
        
        //loop throough the picklist entries and populate select list
        for (Schema.PicklistEntry pE : Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getPickListValues()) {
            
            //Populate the select list with values
            listOptions.add(new SelectOption(pE.getValue() , pE.getLabel()));  
        }
        
        //Return list
        return listOptions;
    }
}