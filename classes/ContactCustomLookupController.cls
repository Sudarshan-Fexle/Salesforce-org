/** 
  * Description     :   This class is used in custom lookup for contact search in replacing of standard Contact Lookup
  *
  * Created By      :   Rajeev Jain(Simplyforce)
  *
  * Created Date    :   03/03/2015
  *
  * Version         :   V1.0 Created
  *                 :   V2.0 Modified By - Rajeev Jain - 12/22/2015 - CR-20150826-9191 - Added Criterias in query for filetered results
  * 
  **/
public with sharing class ContactCustomLookupController {
    
    //Properties
    public List<Contact> results{get;set;}
    public String searchString{get;set;}
    public List<Contact> recnetlyViewed{get;set;}
    public Boolean isAnyListPopulated{get;set;}
    
    //V2.0 - Added By Rajeev Jain 
    private String lookupFor;
    public static final String CONTACT_EMPLOYEE_RECORD_TYPE_DEVELOPERNAME = 'Employee';
    
    //Class Constructor
    public ContactCustomLookupController(){
        
        //Initialize
        results = new List<Contact>();
        recnetlyViewed = new List<Contact>();
        isAnyListPopulated = true;
        
        //Get Search String Parameters
        searchString = System.currentPageReference().getParameters().get('lksrch');
        
        //Check Lookup for Parameter
        lookupFor = System.currentPageReference().getParameters().get('lookupFor');
        
        //Run Search at the window load
        runSearch();
    }
    
    //Perform Page Search based on Keywords
    public PageReference search(){
        
        runSearch();
        return null;
    }
    
    /** Method to Prepare query and hit the search **/
    private void runSearch(){
        
        try{
            
        
            // TODO prepare query string for complex serarches & prevent injections
            if(searchString != '' && searchString != null){
                
                recnetlyViewed = new List<Contact>();
                results = performSearch(searchString); 
                isAnyListPopulated = true;  
                if(results.size() == 0)
                    isAnyListPopulated = false;
            }else{
                
                results = new List<Contact>();
                recnetlyViewed = recentSearch();
                isAnyListPopulated = true;
                if(recnetlyViewed.size() == 0)  
                    isAnyListPopulated = false;
            }               
        }catch(Exception e){
            ShipItHelper.displayErrorMessages(e.getMessage());
        }
    } 
    
    private List<Contact> recentSearch(){
        
        //List to hold recently searched contact
        List<Contact> contactList = new List<Contact>();

        if(!Test.isRunningTest()){
            
            //Get Recently Viewed Contacts
            List<RecentlyViewed> recentlyViewedData = [select Id, Name from RecentlyViewed where Type = 'Contact' ORDER BY LastViewedDate DESC];
                        
            if(recentlyViewedData.size() > 0 ){
                    
                //Fill The Set
                Set<Id> setContactIds = new Set<Id>();
                
                String contactIds = '(' ;
                
                //Loop Over Recnetly Viewed
                for(RecentlyViewed item : recentlyViewedData){
                    contactIds += '\'' + item.Id + '\',';
                    //setContactIds.add(item.Id);   
                } 
                contactIds = contactIds.removeEnd(',')+ ')';
                
                String SOQLQuery = 'Select Id, Name ';
            
                //fetch fields from fieldset to support the dynamic behaviour
                for(Schema.FieldSetMember f : SObjectType.Contact.FieldSets.Custom_Lookup_Fields.getFields())
                        SOQLQuery += ', ' + f.getFieldPath();
                SOQLQuery += ' FROM Contact';        
                SOQLQuery = SOQLQuery +  ' where Id IN ' + contactIds;
                
                //Add Filter Criteria if Lookup is for Marketer data
                if(String.isNotBlank(lookupFor) && lookupFor.equalsIgnoreCase('Marketer'))
                    SOQLQuery = SOQLQuery + ' AND RecordType.DeveloperName = \''+ CONTACT_EMPLOYEE_RECORD_TYPE_DEVELOPERNAME + '\' AND Employee_User_Record__c != null AND Employee_User_Record__r.IsActive = true';
                    
                SOQLQuery = SOQLQuery + ' limit 25';
                
                contactList = database.query(SOQLQuery);
            }
        }
        return contactList;
    }
    //Run the Search and return the record found
    private List<Contact> performSearch(String searchString){
        
        String SOQLQuery = 'Select Id, Name ';
        
        //fetch fields from fieldset to support the dynamic behaviour
        for(Schema.FieldSetMember f : SObjectType.Contact.FieldSets.Custom_Lookup_Fields.getFields())
                SOQLQuery += ', ' + f.getFieldPath();
        
        SOQLQuery += ' FROM Contact'; 
         
        //Replace * in Search with blank
        searchString = searchString.replaceAll('\\*', '');
        
        SOQLQuery = SOQLQuery +  ' where (NOT Contact_Status__c LIKE \'%Inactive%\') AND Name LIKE \'%' + String.escapeSingleQuotes(searchString) +'%\'';
        
        //Add Filter Criteria if Lookup is for Marketer data
        if(String.isNotBlank(lookupFor) && lookupFor.equalsIgnoreCase('Marketer'))
            SOQLQuery = SOQLQuery + ' AND RecordType.DeveloperName = \''+ CONTACT_EMPLOYEE_RECORD_TYPE_DEVELOPERNAME + '\' AND Employee_User_Record__c != null AND Employee_User_Record__r.IsActive = true';
                    
        Integer limitData = Integer.valueOf(ShipItHelper.shipItSettings.get('ContactSearchLimit').value__c);
        String tempSOQL = SOQLQuery + ' LIMIT ' + 10000;
        
        //Check size of the Result Returned 
        List<Contact> tempResults = database.query(tempSOQL);
        
        if(tempResults.size() > limitData)    
            //JRB ShipItHelper.displayErrorMessages(Label.ShipIt_SearchResultSetExceeded);    
            ShipItHelper.displayInfoMessages(Label.ShipIt_SearchResultSetExceeded);    
        
        SOQLQuery = SOQLQuery  + ' LIMIT ' + limitData;
        return database.query(SOQLQuery); 
    }
    
    /** Clear Search Results **/
    public void clearSearchResults(){
        
        results = new List<Contact>();
        
        recnetlyViewed = recentSearch();
        isAnyListPopulated = true;
        if(recnetlyViewed.size() == 0)
            isAnyListPopulated = false;
    }
    
    // used by the visualforce page to send the link to the right dom element
    public string getFormTag() {
        return System.currentPageReference().getParameters().get('frm');
    }
     
    // used by the visualforce page to send the link to the right dom element for the text box
    public string getTextBox() {
        return System.currentPageReference().getParameters().get('txt');
    }
}