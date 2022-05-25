/*
Purpose         :   Controller class for clone job ticket from lightning component.

Created By      :   Dipesh Gupta

Created Date    :   04/06/2020

Current Version :   v1.0

Revision Log    :   V_1.0 Created

*/
public without sharing class CloneJobTicketController 
{
    private static SuperCloneServiceForCloneJobTicket service = new SuperCloneServiceForCloneJobTicket();
    
    @AuraEnabled(cacheable=false)
    public static LightningResponseEntity doClone(Id parentId, String esCampaignId, Id projectId, String fiscalYearValue, Boolean keepColorsVlaue) 
    {
        if(parentId != null) 
        {
            try 
            {
                return LightningResponseEntity.create().setBody(service.doClone(parentId, esCampaignId, projectId, fiscalYearValue, keepColorsVlaue ));
            }
            catch (Exception e) 
            {
                //throw new AuraHandledException('Exception occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n'); 
                String errorMessage = e.getMessage();
                List<String> splittedByValidationExceptions = new List<String>();
                if(errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
                {
                    splittedByValidationExceptions = errorMessage.split('FIELD_CUSTOM_VALIDATION_EXCEPTION');
                    errorMessage = errorMessage.split('FIELD_CUSTOM_VALIDATION_EXCEPTION')[splittedByValidationExceptions.size() - 1];
                    errorMessage = errorMessage.removeStart(',').removeEnd('[]').trim();
                }
                throw new AuraHandledException(errorMessage);
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
    
    @AuraEnabled(cacheable=false)
    public static LightningResponseEntity overwriteJobTicket(Id parentId, String esCampaignId, Id projectId, String fiscalYearValue, Boolean keepColorsVlaue) 
    {
        if(parentId != null)
        { 
            try 
            {
                List<Job_Ticket__c> jobTicketsToBeDeleted = new List<Job_Ticket__c>();
                Set<String> setOfSchool = new Set<String>();
                Set<Id> setOfSubProgram = new Set<Id>();
                
                for(Job_Ticket__c jobTickt : [SELECT Id, School__c, Program__c, Fiscal_Year__c FROM Job_Ticket__c
                                              WHERE Id =: parentId])
                {
                	setOfSchool.add(jobTickt.School__c); 
                    setOfSubProgram.add(jobTickt.Program__c);
                }
                
                for(Job_Ticket__c jobTickt : [SELECT Id FROM Job_Ticket__c
                                              WHERE Project__c =: projectId
                                              AND Auto_Generated__c = true
                                              AND School__c IN : setOfSchool
                                              AND Program__c IN : setOfSubProgram
                                              AND Fiscal_Year__c =: fiscalYearValue])
                {  
                	jobTicketsToBeDeleted.add(new Job_Ticket__c(Id = jobTickt.Id));	   
                }
                
                LightningResponseEntity newJobTicket = LightningResponseEntity.create().setBody(service.doClone(parentId, esCampaignId, projectId, fiscalYearValue, keepColorsVlaue));
                
                if(jobTicketsToBeDeleted.size() > 0){
                    Util.ByPassAllTriggers = true;
                    delete jobTicketsToBeDeleted;
                    Util.ByPassAllTriggers = false;    
                }
                
                return newJobTicket;
                
            	/*List<Job_Ticket__c> jobTicketsToBeUpdated = new List<Job_Ticket__c>(); 
                for(Job_Ticket__c jobTickt : [SELECT Id, Project__c, Fiscal_Year__c  
                                              FROM Job_Ticket__c
                                              WHERE Id =: parentId])
                {  
                	jobTicketsToBeUpdated.add(new Job_Ticket__c(Id = parentId, Project__c = projectId, Fiscal_Year__c = fiscalYearValue));	   
                }
                if(jobTicketsToBeUpdated.size() > 0)
                {
                    Util.ByPassAllTriggers = true;
                    update jobTicketsToBeUpdated;
                    Util.ByPassAllTriggers = false;    
                }
                return LightningResponseEntity.create().setBody(jobTicketsToBeUpdated[0].Id);*/
            }
            catch (Exception e) 
            {
                //throw new CustomException('Exception occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n'); 
                String errorMessage = e.getMessage();
                List<String> splittedByValidationExceptions = new List<String>();
                if(errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
                {
                    splittedByValidationExceptions = errorMessage.split('FIELD_CUSTOM_VALIDATION_EXCEPTION');
                    errorMessage = errorMessage.split('FIELD_CUSTOM_VALIDATION_EXCEPTION')[splittedByValidationExceptions.size() - 1];
                    errorMessage = errorMessage.removeStart(',').removeEnd('[]').trim();
                }
                throw new AuraHandledException(errorMessage);
            }
        }
        else
        {
        	return null;    
        }
    }
}