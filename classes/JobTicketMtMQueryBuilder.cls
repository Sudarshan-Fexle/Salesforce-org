/*
    Purpose         :   Job Ticket MtM Query Builder Class
    
    Created By      :   Abhinav Sharma
    
    Created Date    :   12/01/2020
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created
*/
public with sharing class JobTicketMtMQueryBuilder 
{
    public static List<Job_Ticket_MtM__c> getAllJobTicketComponents(String jobTicketId) 
    {
        return [Select Id, Job_Ticket__c, Job_Ticket_Component__c
                From Job_Ticket_MTM__c 
                Where Job_Ticket__c =: jobTicketId];       
    }
    
    public static List<Job_Ticket_MtM__c> getJobTicketMtMDetails(String jobMtMId) 
    {
        return [SELECT Id, Name, Job_Ticket_Component__c, 
                Job_Ticket_Component__r.Component__c
                FROM Job_Ticket_MtM__c 
                Where Id =: jobMtMId 
                    AND Job_Ticket_Component__r.Component__c != null
                    AND Job_Ticket_Component__r.Component__c != ''
               ];      
    }
}