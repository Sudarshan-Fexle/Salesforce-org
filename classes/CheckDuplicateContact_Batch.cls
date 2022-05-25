/**
*  Description     :  This class is for checking duplicate contacts using batch process.
*
*  Created By      :  Sudarshan singh
*
*  Created Date    :  03/25/2022
*
*  Revision Logs   :  V1.0 - Created - Sudarshan Singh 
*
**/
public without sharing class CheckDuplicateContact_Batch implements Database.Batchable<sObject>{

    /**
    * 
    *   @description    :   In this method populate the original contact and Is duplicate fields of all contacts that are duplicate. 
    *
    *   @args           :   Database.BatchableContext, List<Contact>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 03/25/2022 - Sudarshan singh - Comment
    * 
    **/
    public Database.QueryLocator start(Database.BatchableContext bContext){
        return Database.getQueryLocator([SELECT Id, LastName, Email FROM Contact ORDER BY CreatedDate ASC]);
    }
    
    public void execute(Database.BatchableContext bContext, List<Contact> listOfContact){
        
        List<Contact> listOfContactToUpdate = new List<Contact>();
        Map<String, Contact> mapOfUniqueContact = new Map<String, Contact>();

        for(Contact con : listOfContact){

            if (mapOfUniqueContact.containsKey(con.LastName + con.Email)){
                Contact c = new Contact();
                c.Id = con.Id;
                c.Original_Contact__c = mapOfUniqueContact.get(con.LastName + con.Email).Id;
                c.Is_Duplicate__c = true;
                listOfContactToUpdate.add(c);
            }
            else 
                mapOfUniqueContact.put(con.LastName + con.Email, con);

        }
        update listOfContactToUpdate;
    }
    
    public void finish(Database.BatchableContext bContext){
        System.debug('Contacts are update.');
    }
}