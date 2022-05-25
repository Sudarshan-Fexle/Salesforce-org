public with sharing class IntranetPeopleController {

    public User UserData {get; set;}
    public String OfficeName {get; set;}
    public String getMap {get; set;}
    
    public Intranet_Item__c UserOffice {get; set;}
    
    Id userId;
    
    public IntranetPeopleController(){
        
        //Get User Id
        userId = ApexPages.currentPage().getParameters().get('sfdc.userId');
        
        //Load the User Info
        this.UserData = getUserData();
        
        //Grab our Office data and Maps
        findUserData();
        
    }
    
    public void findUserData(){
        
        //Get User Office data if blank
        if(UserOffice == null){
            if(UserData.Office__c != null){
                
                //Grab our Office Record
                List<Intranet_Item__c> OfficeRecord = [select Id, Office_Name__c, Office_Short_Name__c, Location_Code__c from Intranet_Item__c where Id = :UserData.Office__c];
                
                //If we have an Office record then proceed with Assignment
                if (OfficeRecord.size() > 0){
                    
                    //Set UserOffice and OfficeName
                    UserOffice = OfficeRecord[0];
                    OfficeName = OfficeRecord[0].Office_Short_Name__c;
                    
                }
            }
        } else {
            UserOffice = null;
        }
    }
    
    public List<Schema.FieldSetMember> getFields() {
        return SObjectType.User.FieldSets.UserLocationFieldSet.getFields();
    }
    
    public User getUserData() {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getFields()) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id, Office__c, Name FROM User WHERE ID = :userId';
        return Database.query(query);
    }

    public String MapFileId{
        
        //Solution found here - https://salesforce.stackexchange.com/questions/4715/document-preview-with-visualforce
        get{
            if(MapFileId == null){
                if(UserOffice != null){
                    
                    //Get our Attachments linked to the Office record
                    List<Attachment> attachments = [SELECT Id, Name, ContentType, ParentId 
                                        			FROM Attachment
                                        			WHERE ParentId = :UserOffice.Id];
                    
                    //If we have Attachments to run through then proceed
                    if (attachments.size() > 0){
                        //Loop through our Attachments
                        for (Attachment att : attachments){
                            
                            //Pass our Name through to a separate String for Trim
                            String abbrevName = att.Name;
                            
                            //If Abbreviated Name contains PDF at the end, remove it
                            if (abbrevName.contains('.pdf')){
                                abbrevName = abbrevName.removeEnd('.pdf'); 
                            }
                            
                            //Check for our Location Code and then figure out our Floor && finally populate our value
                            if(abbrevName.startsWith(UserOffice.Location_Code__c) && 
                               string.isNotEmpty(UserData.EAB_Workspace_Floor__c) && abbrevName.endsWith(string.valueOf(Integer.valueOf(UserData.EAB_Workspace_Floor__c)))){
                                   MapFileId = att.Id;
                                   System.debug('@@@zzz' + MapFileId);
                               }
                        }
                        
                    }
                  
                }else{
                    MapFileId = null;
                }
            }
            return MapFileId;
        }
        set;
    }
    
    public Boolean renderMap{
        get{
            return !(MapFileId == null);
        }
        set;
    }
}