/*
Purpose         :   Custom Metadata Types Utilities Class

Created By      :   Abhinav Sharma

Created Date    :   01/14/2020

Current Version :   v1.0

Revision Log    :   V_1.0 Created
*/
public without sharing class CustomMetadataTypesUtilities 
{
    public static Map<String, Job_Print_Ticket_View_Manager__mdt> getMapOfJTMTypesJobTicketMappings() 
    {
        Map<String, Job_Print_Ticket_View_Manager__mdt> mapOfComponentTypeWithDetails = new Map<String, Job_Print_Ticket_View_Manager__mdt>();
        for(Job_Print_Ticket_View_Manager__mdt jTVM : CustomMetadataTypesQueryBuilder.getJTMTypeJobTicketMappings()) 
        {
        	mapOfComponentTypeWithDetails.put(jTVM.Component_Type__c, jTVM);    
        }
        return mapOfComponentTypeWithDetails;
    }
}