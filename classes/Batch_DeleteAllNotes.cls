/*
Purpose         :   Batch class to delete all Notes.

Create By       :   Mahendra Swarnkar

Created Date    :   06/2/2020

*/
global without sharing class Batch_DeleteAllNotes implements Database.Batchable<SObject>, Database.Stateful 
{
    public String queryStr;
    public String debugLogs;
    global Batch_DeleteAllNotes()
    {
        this.debugLogs = '';
        If(String.isBlank(queryStr))
        {
            this.queryStr = 'Select Id From Note';
        }
    }
    
    global Database.Querylocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext BC, list<Note> scope) 
    {
        Util.byPassAllTriggers = true;
        debugLogs += DatabaseUtilities.createLog(Database.delete(scope, false));
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC) 
    {
        if(debugLogs != '')
        {
            Util.sendBatchStatus(BC.getJobId(), 'Batch_DeleteAllNotes', debugLogs, userInfo.getUserEmail());        
        }
    }
}