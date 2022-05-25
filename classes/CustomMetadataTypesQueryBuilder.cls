/*
Purpose         :   Custom metadata type query builder Class

Created By      :   Abhinav Sharma

Created Date    :   01/14/2020

Current Version :   v1.0

Revision Log    :   V_1.0 Created
                :   V_1.1 - Modified By - Dipesh Gupta - 06/23/2020 - CR-20200303-13823 - Add spec sheet tips and reminders to component editor
*/
public with sharing class CustomMetadataTypesQueryBuilder 
{
    //Modified By - Dipesh Gupta - 06/23/2020 - CR-20200303-13823 - Add spec sheet tips and reminders to component editor
    public static List<Job_Print_Ticket_View_Manager__mdt > getJTMTypeJobTicketMappings() 
    {
        return [SELECT Id, Columns__c, Component_Type__c, Field_Sets__c, Location__c, Help_Text__c
                FROM Job_Print_Ticket_View_Manager__mdt
                WHERE Columns__c != null 
                AND Component_Type__c != null
                AND Location__c != null
                AND Location__c = 'JTM'
                ORDER By Component_Type__c ASC
               ];    
    }
    
  	//Added by - Abhinav Sharma- 03-11-2020 - CR-20200303-13825 (Color count per component should include CMYK and varnishes)
  	public static List<JTM_to_Associated_Features_Picklist__mdt> getJTMToAssociatedFeaturesPicklistMapping()
    {
        return [SELECT Id, Picklist_Value__c, Associated_Feature_Field__c, Value_if_Selected__c, Order__c 
                FROM JTM_to_Associated_Features_Picklist__mdt
               	WHERE Associated_Feature_Field__c != null 
               	AND Picklist_Value__c != null
               	AND Value_if_Selected__c != null ORDER BY Order__c ASC];
    }
    
}