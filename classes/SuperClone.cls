/*
Purpose         :   Controller class for create job ticket from template lightning component.

Created By      :   Abhinav Sharma

Created Date    :   04/12/2019

Current Version :   v1.0

Revision Log    :   V_1.0 Created
		:   V_1.1 - Modified By Dipesh Gupta to Change the reference of Es Campaign to the Project. Issue--CR13887--QA--00009627 (CR-20200325-13887)

*/
public without sharing class SuperClone   
{
    private static SuperCloneService service = new SuperCloneService();
    
    @AuraEnabled(cacheable=false)
    public static LightningResponseEntity doClone(Id parentId, String projectId) 
    {
        if(parentId != null) 
        {
            try 
            {
                return LightningResponseEntity.create().setBody(service.doClone(parentId, projectId));
            }
            catch (Exception e) 
            {
                throw new AuraHandledException('Exception occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n'); 
            }
        }
        else 
        {
            return null;    
        }        
    }
    
    private static List<Schema.FieldSetMember> getFields() 
    {
        return Schema.SObjectType.Job_Ticket_Component__c.fieldSets.getMap().get(System.Label.Template_Selection_Screen_Fields).getFields();
    }
    
    @AuraEnabled(cacheable=false)
    public static LightningResponseEntity retrieveComponentsForSelectedTemplate(Id parentId)
    {
        try 
        {
            if(parentId != null) 
            {
                Set<Id> setOfJobTicketComponetIds = new Set<Id>();
                for(Job_Ticket_MtM__c jTM : [SELECT ID, Job_Ticket_Component__c, Job_Ticket__c 
                                             FROM Job_Ticket_MtM__c
                                             WHERE Job_Ticket__c =: parentId 
                                             AND Component_Type__c != null 
                                             AND Component_Type__c != ''
                                            ])
                {
                	setOfJobTicketComponetIds.add(jTM.Job_Ticket_Component__c);    
                }

                if(setOfJobTicketComponetIds.size() > 0) 
                {
                    String whereClause = 'WHERE ID IN :setOfJobTicketComponetIds';
                    String orderBy = 'ORDER BY Component__c ASC NULLS LAST ';
                    String jobTicketComponentQuery = DatabaseUtilities.getFieldsetQuery('Job_Ticket_Component__c', 
                                                                                        getFields(), 
                                                                                  		new List<String>{'Name'}, 
                                                                                  		whereClause, orderBy, null, true);
                    List<Job_Ticket_Component__c> jobTicketComponents = new List<Job_Ticket_Component__c>();
                    for (sObject queriedObject : Database.query(jobTicketComponentQuery)) 
                    {
                        jobTicketComponents.add((Job_Ticket_Component__c)queriedObject);    
                    }
                    return LightningResponseEntity.create().setBody(jobTicketComponents);    
                }
                else 
                {
                	return null;    
                }
            }
            else 
            {
                return null;    
            }
        }
        catch (Exception e) 
        {
            throw new AuraHandledException('Exception occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n'); 
        }
    }
}