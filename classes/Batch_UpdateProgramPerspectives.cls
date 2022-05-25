/**
*  Description     :   This batch populate Program Perspective fields value with all related Role Program Perspectives
*		               Short Name field, if Role Program Perspectives Effective End date >= today 
*					   
*  Created By      :   Abhinav Sharma
*
*  Created Date    :   08/26/2020
*
*  Current Version :   v1.0
*       
*  Revision Log    :   V_1.0 Created - 08/26/2020 - Abhinav Sharma - CR-20200806-14405 - Error In Update Program Collection record
*
**/   
global class Batch_UpdateProgramPerspectives implements Database.Batchable<sObject> 
{
    //String variable to hold the entire log message string value
    global String debugLogStr;
    
    public List<Team_Membership__c> staffAssignments = new List<Team_Membership__c>();
    
    global Batch_UpdateProgramPerspectives(List<Team_Membership__c> staffAssignments)
    {	
        if(staffAssignments == null || staffAssignments.size() == 0) 
            throw New CustomException('No Team Membership records exists.');
        
        this.staffAssignments = staffAssignments;   
        debugLogStr = '';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'Select Id, Staff_Assignment__c, Perspective_Short_Name__c '+ 
            'From Role_Program_Perspective__c Where Staff_Assignment__c != null '+
            'AND Staff_Assignment__c IN : staffAssignments '+ 
            'AND (Effective_End__c = null OR Effective_End__c >= TODAY) '+
            'AND Perspective_Short_Name__c != null';
        return Database.getQueryLocator(query);	    
    }
    
    global void execute(Database.BatchableContext BC,List<Role_Program_Perspective__c> listOfRoleProgramPerspectives) 
    {
        //String variable to hold the error message string in case of any failure
        String logMessage = '';
        
        //Map to hold Staff Assignment Id as key and Program Perspective as value
        Map<Id, String> mapSAIdWithPP = new Map<Id, String>();
        
        //Set to hold Staff Assignment Id and Short Name
        Set<String> setSAIdWIthSN = new Set<String>();
        
        for(Role_Program_Perspective__c rPP : listOfRoleProgramPerspectives)
        {
            //Check if map contains staff assinmentId 
            if(mapSAIdWithPP.containsKey(rPP.Staff_Assignment__c) 
               && !setSAIdWIthSN.contains(rPP.Staff_Assignment__c + '-' + rPP.Perspective_Short_Name__c))
            {
                mapSAIdWithPP.put(rPP.Staff_Assignment__c, mapSAIdWithPP.get(rPP.Staff_Assignment__c) + ', ' + rPP.Perspective_Short_Name__c);
            }
            else if(!setSAIdWIthSN.contains(rPP.Staff_Assignment__c + '-' + rPP.Perspective_Short_Name__c))
            {
                mapSAIdWithPP.put(rPP.Staff_Assignment__c, rPP.Perspective_Short_Name__c);    
            }            
            //Add values in set
            setSAIdWIthSN.add(rPP.Staff_Assignment__c + '-' + rPP.Perspective_Short_Name__c);
        }
        
        //Loop through Staff Assignment list
        for(Team_Membership__c sA : staffAssignments) {
            
            //Check if map contains Staff Assignment Id
            if(mapSAIdWithPP.containsKey(sA.Id))
            {
                sA.Program_Perspectives__c = mapSAIdWithPP.get(sA.Id);
            }
            else
            {
                sA.Program_Perspectives__c = null;
            }  
        }
        
        if(staffAssignments.size() > 0) {
            
            //Making a try to update the list of records and recording error messages will be mailed to the SFAdmin 
            logMessage = Util.createLog(Database.update((staffAssignments),false));
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '' && logMessage.length() < 0) 
                debugLogStr += logMessage; 
        }  
    }
    
    global void finish(Database.BatchableContext BC)
    {
        if(String.isNotBlank(debugLogStr))
            Util.sendBatchStatus(BC.getJobId(), 'Batch_UpdateProgramPerspectives', debugLogStr, Label.Salesforce_Admin_Email);
    } 
}