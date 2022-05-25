/**
    *  @description    :   This batch is used to Remove the Active Institution on Staff Assignment - 
    * 					   because Staff Assignment.Status is a Formula Field and can change the value with out DML on it. 
    * 					   So this batch Job will scheduled at night and check if any staff Assignment is Inavtive 
    * 					   and have the value in the Acttive Institution Field 
    * 					   then nullify the Active institution.  
    * 
    *  @args           :   List<Team_Membership__c>
    *
    *  @return         :   void
    * 
    *  Created By      :   Added by Rajeev Jain - CR-20170812-11145 - Update the Active Institution field
    
    *
  **/ 
global class Batch_ActiveInstitutionStaffAssignment implements Database.Batchable<sObject> {
    
    //Start method - 
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        //Query on staff Assignment
        String query = 'Select Id, Active_Institution__c, Status__c From Team_Membership__c Where Status__c = \'Inactive\' AND Active_Institution__c != null';
        
        return DataBase.getQueryLocator(query);
        
    }
    
    //Execute method
    global void execute(Database.BatchableContext BC, List<Team_Membership__c> scope)  {
        
        //List to hold the team membership. 
        List<Team_Membership__c> staffAssignmentsToBeUpdated = new List<Team_Membership__c>();
        
        //Loop on the List
        for(Team_Membership__c teamMembership : scope) {
        	
            //Check the status
            if(teamMembership.Status__c == 'Inactive' && teamMembership.Active_Institution__c != null) {
                
                //Set null in the Active institution field since the Staff Assignment is inactive now. 
                teamMembership.Active_Institution__c = null;
                staffAssignmentsToBeUpdated.add(teamMembership);
            }
        }
        
        //Check for the List Size
        if(staffAssignmentsToBeUpdated.size() > 0) {
            //Update the List
            update staffAssignmentsToBeUpdated;
        }
    }
    
    global void finish(Database.BatchableContext BC){}
    
}