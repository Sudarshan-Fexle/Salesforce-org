/*
Purpose         :   Mode Controlling - Sudo helper class - Dynamic Related List
Created By      :   Abhinav Sharma
Created Date    :   11/13/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 11/13/2021   
*/
public without sharing class dynlistWithoutSharingSudoHelper 
{    
    /* Query */
    public static List<sObject> doQuery(String query) 
    {
        return Database.query(query);
    }
    
    /* Inserts */
    public static Database.SaveResult doInsert(sObject recordToInsert) 
    {
        return doInsert(new sObject[] { recordToInsert })[0];
    }
    
    public static Database.SaveResult doInsert(sObject recordToInsert, Boolean opt_allOrNone) 
    {
        return doInsert(new sObject[] { recordToInsert }, opt_allOrNone)[0];
    }
    
    public static List<Database.SaveResult> doInsert(List<sObject> recordsToInsert) 
    {
        return doInsert(recordsToInsert, true);
    }
    
    public static List<Database.SaveResult> doInsert(List<sObject> recordsToInsert, Boolean opt_allOrNone) 
    {
        return Database.insert(recordsToInsert, opt_allOrNone);
    }
    
    /* Updates */
    public static Database.SaveResult doUpdate(sObject recordToUpdate) 
    {
        return doUpdate(new sObject[] { recordToUpdate })[0];
    }
    
    public static Database.SaveResult doUpdate(sObject recordToUpdate, Boolean opt_allOrNone) 
    {
        return doUpdate(new sObject[] { recordToUpdate }, opt_allOrNone)[0];
    }
    
    public static List<Database.SaveResult> doUpdate(List<sObject> recordsToUpdate) 
    {
        return doUpdate(recordsToUpdate, true);
    }
    
    public static List<Database.SaveResult> doUpdate(List<sObject> recordsToUpdate, Boolean opt_allOrNone) 
    {
        return Database.update(recordsToUpdate, opt_allOrNone);
    }
}