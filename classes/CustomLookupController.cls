/** 
  * Description     :   This controller is used for lookup search of Standard and custom object records through custom lookup dialog
  *                 :   Using this lookup we can avoid, potential permission issue and case licence limitations.
  *                 :   Designed it very generic so it can be utilized for any object later for searching in order to avoid standard lookup and potential permission issues.
  * Limitation      :   1 - It supports "Recently viewed" functionality same as standard lookup supports.
  *                 :       But referes to Salesforce document as well. It supports any standard object but don't support its related object
  *                 :       e.g. Recently viewed supports to Case object, but don't support to its related object like CaseTeamMember, CaseTeamRole etc.
  *                 :   2 - However it will search as normal record search.
  *                 :   3 - As on date 03/18/2016 - It is designed for CaseTeamCustomLookup in order to avoid typical Case License Issue.
  *                 :       So CaseTeamTemplate don't supports to recently viewed but other functionality will work as expected.
  *                 :   4 - For "Recently Viewed" functionality RecentSearch Method is used. 
  *                 :       In this method for example I have included Contact Object logic but in same way you can use it for any other standard and custom object as well.
  *                 :   5 - For dynamic display no of fields on the page used field set.
  *
  * Created By      :   Rajeev Jain(Simplyforce)
  *
  * Created Date    :   03/18/2016
  *
  * Version         :   V1.0 Created
  * 				:	V2.0 Modified - CR-20160406-9738 - Fixed the known issue along with mentioned changes on this CR.
  * 				:	V2.0 - Issue Fixed - Removed unused debugs, corrected spelling mistake(Support) in top comments.
  *							 - 				- fixed the issue to clear the search results.									
  **/
public class CustomLookupController {
    
    //Properties
    public List<LookupResult> results{get;set;}
    public String searchString{get;set;}
    public List<LookupResult> recnetlyViewed{get;set;}
    public Boolean isAnyListPopulated{get;set;}
    private String parentRecordId;
    public String objectType{get;set;}
    public String sourceScreen{get;set;}
    public String rowNumber{get;set;}
    
    //Class Constructor
    public CustomLookupController(){
        
        //Initialize
        results = new List<LookupResult>();
        recnetlyViewed = new List<LookupResult>();
        isAnyListPopulated = true;
        
        //Get Search String Parameters
        searchString = System.currentPageReference().getParameters().get('lksrch');
        parentRecordId = System.currentPageReference().getParameters().get('parentRecordId');
        objectType = System.currentPageReference().getParameters().get('objectType');
        sourceScreen = System.currentPageReference().getParameters().get('sourceScreen');
        rowNumber = System.currentPageReference().getParameters().get('rowNumber');
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
                
                recnetlyViewed = new List<LookupResult>();
                results = new List<LookupResult>();
                
                //Hold the List of Sobject and type cast it.
                for(Sobject obje : performSearch(searchString)){
                    
                    if(objectType == 'Contact'){
                        if(sourceScreen == 'ReferenceRequest'){
                         	results.add(new LookupResult(
                                            (Id)obje.get('id'),
                                            (String)obje.get('Name'),
                                            (Contact)obje));   
                        }
                    }
                    else{
                    	results.add(new LookupResult((Id)obje.get('id'),(String)obje.get('Name')));    
                    }
                }
                
                isAnyListPopulated = true;  
                if(results.size() == 0)
                    isAnyListPopulated = false;
            }else{
                
                results = new List<LookupResult>();
                
                if(!objectType.contains('CaseTeam')){
                    
                    //Hold the List of Sobject and type cast it.
                    for(Sobject obj : recentSearch()){
                        
                        if(objectType == 'Contact'){
                            if(sourceScreen == 'ReferenceRequest'){
                                recnetlyViewed.add(new LookupResult(
                                                        (Id)obj.get('id'),
                                                        (String)obj.get('Name'),
                                                        (Contact)obj));
                            }
                    	}
                        else{
                        	recnetlyViewed.add(new LookupResult((Id)obj.get('id'),(String)obj.get('Name')));    
                        }
                    }
                }
                
                isAnyListPopulated = true;
                if(recnetlyViewed.size() == 0)  
                    isAnyListPopulated = false;
            }               
        }catch(Exception e){
            ShipItHelper.displayErrorMessages(e.getMessage());
        }
    }
    
    private string decideSoqlQuery(String searchString){
        
        String SOQLQuery = 'Select Id, Name ';
        
        if(objectType == 'CaseTeamTemplate'){
            SOQLQuery += ', Description ';
        }else if(objectType == 'Contact'){
                if(sourceScreen == 'ReferenceRequest'){
                    for(Schema.FieldSetMember f : SObjectType.Contact.FieldSets.Contact_LookUp_Field_On_Reference_Reques.getFields()){
                        SOQLQuery += ', ' + f.getFieldPath();   
                    }
                }
		}else{
             	
                //Use this code if you wants to use custom lookup for other object as well
                // You just need to add field set on the object for which you wants to search records and display those field in lookup popup
                //fetch fields from fieldset to support the dynamic behaviour
                /*for(Schema.FieldSetMember f : SObjectType.Contact.FieldSets.Custom_Lookup_Fields.getFields())
                SOQLQuery += ', ' + f.getFieldPath();
                }*/
		}
        
        SOQLQuery += ' FROM ' + objectType; 
         
        //Replace * in Search with blank
        searchString = searchString.replaceAll('\\*', '');
        
        //Dynamic Where clause criteria to search record, based on what. 
        //You can customize it by just adding your conditions based on checking object type.
        //So in future if you wants to use this lookup for other object as well then must pass object type like account, contat etc.
        SOQLQuery = SOQLQuery +  ' where Name LIKE \'%' + String.escapeSingleQuotes(searchString) +'%\'';
        
        return SOQLQuery;
    }
    
    //Run the Search and return the record found
    private List<Sobject> performSearch(String searchString){
        
        String SOQLQuery = decideSoqlQuery(searchString);
        
        Integer limitData = Integer.valueOf(ShipItHelper.shipItSettings.get('ContactSearchLimit').value__c);
        
        String tempSOQL = SOQLQuery + ' LIMIT ' + 10000;
        
        //Check size of the Result Returned 
        List<Sobject> tempResults = database.query(tempSOQL);
        
        if(tempResults.size() > limitData)    
            //JRB ShipItHelper.displayErrorMessages(Label.ShipIt_SearchResultSetExceeded);    
            ShipItHelper.displayInfoMessages(Label.ShipIt_SearchResultSetExceeded);    
        
        SOQLQuery = SOQLQuery  + ' LIMIT ' + limitData;
        return database.query(SOQLQuery); 
    }
    
    private List<SObject> recentSearch(){
        
        //List to hold recently searched contact
        List<SObject> sobjectList = new List<SObject>();
        
        if(!Test.isRunningTest()){
            
            String SOQLQuery = 'Select Id, Name ';
           
            SOQLQuery += ' FROM RecentlyViewed where Type = \'' + objectType + '\' ORDER BY LastViewedDate DESC';
            
            //Get Recently Viewed Contacts
            List<RecentlyViewed> recentlyViewedData = Database.query(SOQLQuery);
            
            if(recentlyViewedData.size() > 0 ){
                
                String setRecordIds = '(' ;
                
                //Loop Over Recnetly Viewed
                for(RecentlyViewed item : recentlyViewedData){
                    setRecordIds += '\'' + item.Id + '\',';
                } 
                setRecordIds = setRecordIds.removeEnd(',')+ ')';
                
                //Reset SOql Query String
                SOQLQuery = 'Select Id, Name ';
            
                //fetch fields from fieldset to support the dynamic behaviour
                if(objectType == 'Contact'){
                    
                    if(sourceScreen == 'ReferenceRequest'){
                        for(Schema.FieldSetMember f : SObjectType.Contact.FieldSets.Contact_LookUp_Field_On_Reference_Reques.getFields())
                        	SOQLQuery += ', ' + f.getFieldPath();
                    }else{
                        for(Schema.FieldSetMember f : SObjectType.Contact.FieldSets.Custom_Lookup_Fields.getFields())
                        SOQLQuery += ', ' + f.getFieldPath();
                    }
                }
                
                SOQLQuery = SOQLQuery + ' FROM ' + objectType +  ' where Id IN ' + setRecordIds;
                
                SOQLQuery = SOQLQuery + ' limit 25';
                
                sobjectList = database.query(SOQLQuery);
            }
        }
        return sobjectList;
    }
    
    /** Clear Search Results **/
    public void clearSearchResults(){
        
        results = new List<LookupResult>();
        
        if(!objectType.contains('CaseTeam')){
                    
            //Hold the List of Sobject and type cast it.
            for(Sobject obj : recentSearch()){
                 
                if(objectType == 'Contact'){
                    if(sourceScreen == 'ReferenceRequest'){
                        recnetlyViewed.add(new LookupResult(
                                    (Id)obj.get('id'),
                                    (String)obj.get('Name'),
                                    (Contact)obj
                            	)
						);
                    }
				}
                else{
                    recnetlyViewed.add(new LookupResult((Id)obj.get('id'),(String)obj.get('Name')));
                }
            }
        }
        
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
    
    //Thhis is general Wrapper class to hold the lookup search record's properties.
    //Customize this wrapper class if you wants to use this lookup for other object.
    //You just need to define another constructor for this wrapper class
    //You just need to define no of properties based on how many fields you wants to display on the screen of the lookup popup on the page.
    public class LookupResult{
        
        public Id id{get;set;}
        public String name{get;set;}
        Public SObject obj{get;set;}
        
        //Class Constructor
        public LookupResult(Id lookupRecordId, String lookupRecordName){
            this.id = lookupRecordId;
            this.name = lookupRecordName;
        }
        
        public LookupResult(Id lookupRecordId, String lookupRecordName, SObject obj){
            this.id = lookupRecordId;
            this.name = lookupRecordName;
            this.obj = obj;
        }
        
    }
}