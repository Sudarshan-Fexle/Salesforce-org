/*
Purpose         :   Apex class for Parent Controller (Dynamic Related List)
Created By      :   Abhinav Sharma
Created Date    :   11/09/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 11/09/2021
*/
public with sharing class dynlistParentController
{ 
    public List<Contact> contacts {get;set;}
    public String query {get; set;}
    public Boolean respectSharing {get; set;}
    
    public String modeExecuted {get; set;}
    public Integer recordCount {get; set;}
    
    public dynlistParentController() 
    {
        contacts = new List<Contact>();    
    }
    
    public void queryRecords() 
    {
        query = 'select id, name, ownerid, Owner.name, email from Contact';
        contacts = new List<Contact>();
        if(respectSharing) 
        {
            contacts = Database.query(query);
            recordCount = contacts.size();
            modeExecuted = 'With Sharing';
        } 
        else 
        {
            contacts = dynlistWithoutSharingSudoHelper.doQuery(query);
            recordCount = contacts.size();
            modeExecuted = 'Without Sharing';
        }
    } 
}