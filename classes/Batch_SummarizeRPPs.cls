/**
*  Description     :   This batch is used to summarize RPPs on Staff Assignments.
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
global class Batch_SummarizeRPPs implements Database.Batchable<sObject>, Database.Stateful 
{
    global Set<Id> setOfProgramGroupIds = new Set<Id>();
    
    global List<Team_Membership__c> listOfTeamMemberships = new List<Team_Membership__c>();
    
    global Batch_SummarizeRPPs(Set<Id> setOfProgramGroupIds)
    {	
        if(setOfProgramGroupIds == null || setOfProgramGroupIds.size() == 0) 
            throw New CustomException('No Program Group records Exists.');
        
        this.setOfProgramGroupIds = setOfProgramGroupIds;  
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'Select Id, Staff_Assignment__c From Role_Program_Perspective__c Where Staff_Assignment__c != null '+
                        'AND Program_Perspective__r.Program_Group__c IN : setOfProgramGroupIds';
        
        return Database.getQueryLocator(query);	    
    }
    
    global void execute(Database.BatchableContext BC,List<Role_Program_Perspective__c> listOfRoleProgramPerspective) 
    {
		//Set to hold Staff Assignment Ids
        Set<Id> setSAIds = new Set<Id>(); 
        
        for(Role_Program_Perspective__c rPP : listOfRoleProgramPerspective)
        {
           setSAIds.add(rPP.Staff_Assignment__c); 
        }
        if(setSAIds.size() > 0)
        {
        	listOfTeamMemberships = [Select Id, Program_Perspectives__c From Team_Membership__c Where Id IN : setSAIds];  
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        if(listOfTeamMemberships.size() > 0)
        {
            //Calling an another batch job. 
            Database.executeBatch(new Batch_UpdateProgramPerspectives(listOfTeamMemberships),200);
        }
    } 
}