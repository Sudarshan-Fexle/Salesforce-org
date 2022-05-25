/*
Purpose         :   Controller class for added template to job Ticket from lightning component.
					Calling - On the Job ticket record "Add to template button". 

Created By      :   Dipesh Gupta

Created Date    :   03/02/2020

Current Version :   v1.0

Revision Log    :   V_1.0 Created - Dipesh Gupta - 03/02/2020
                :   V_1.1 Modified By - Shalu Sharma - 03/04/2022 - CR-20220304-15984

*/
public without sharing class CloneJobTicketTemplate 
{ 
    @AuraEnabled(cacheable=false)
    public static LightningResponseEntity checkForAccess(String jobTicketId)
    {
        try 
        {
            String message = '';
            if(String.isNotBlank(jobTicketId))
            {
                for(Job_Ticket__c jobTickt : [SELECT Id, Auto_Generated__c, Added_Job_Template__c  
                                              FROM Job_Ticket__c
                                              WHERE Id =: jobTicketId])
                {
                    //Commented via Shalu Sharma - 03/04/2022 - CR-20220304-15984
                    /*if(!(jobTickt.Auto_Generated__c == true && jobTickt.Added_Job_Template__c == false))
                    {
                        message = System.Label.No_Data_Message_For_Processing;
                    }*/
                }
                if(String.isNotBlank(message))
                {
                	return LightningResponseEntity.create().setBody(message);  
                }
            }
            else
            {
                return null;
            }
        }
        catch (Exception e) 
        {
            throw new CustomException('Exception occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n'); 
        }
		return null;         
    }
    
    private static List<Schema.FieldSetMember> getJobTicketFields() 
    {
        return Schema.SObjectType.Job_Ticket__c.fieldSets.getMap().get(System.Label.Job_Ticket_Field_Set_For_Clone_Record).getFields();
    }
    
    @AuraEnabled(cacheable=false)
    public static LightningResponseEntity doClone(Id parentId, String jobTicketId) 
    {
        if(String.isNotBlank(parentId) && String.isNotBlank(jobTicketId))
        {
            try 
            {
                
                /*
                List<Schema.FieldSetMember> listOfJobTicketFSMs = new List<Schema.FieldSetMember>();
                listOfJobTicketFSMs.addAll(getJobTicketFields());
                
                List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
                
                Job_Ticket__c jTicketToBeCloned = new Job_Ticket__c();
                List<Job_Ticket__c> templateJobTickets = [Select Id, Template_Name__c From Job_Ticket__c Where Id =: parentId];
                String whereClause = 'WHERE Id =: jobTicketId';
                String jobTicketQuery = DatabaseUtilities.getFieldsetQuery('Job_Ticket__c', listOfJobTicketFSMs, 
                                                                           new List<String>{'Descriptive_Name__c'}, 
                                                                           whereClause, null, null, true);
                
                jobTickets = (List<Job_Ticket__c>)Database.query(jobTicketQuery);
                if(jobTickets != null && jobTickets.size() > 0)
                {
                	//Cloning the record. 
                	jTicketToBeCloned = jobTickets[0].clone(false, false, false, false);
                    jTicketToBeCloned.Descriptive_Name__c = templateJobTickets[0].Template_Name__c;
                    insert jTicketToBeCloned;
                    
					//Updating the Job Tickets. 
					Job_Ticket__c jTToBeUpdated = new Job_Ticket__c();
                    jTToBeUpdated.Id = jobTicketId;
                    jTToBeUpdated.Added_Job_Template__c = true;
                    
                    Util.ByPassAllTriggers = true;
                    update jTToBeUpdated;
                    Util.ByPassAllTriggers = false;
                    
                }*/

                String fieldApis = '';
                for(String field : Schema.SObjectType.Job_Ticket_MtM__c.fields.getMap().keySet())
                    fieldApis += field + ',';

                fieldApis = fieldApis.removeEnd(',');
                String query = 'Select ' + fieldApis + ', Job_Ticket__r.Template_Name__c FROM Job_Ticket_MtM__c WHERE Job_Ticket__c =: parentId AND Component_Type__c != null';


                List<Job_Ticket_MtM__c> jobTicketMTMs = Database.query(query);
                List<Job_Ticket_MtM__c> jobTicketMtmToBeCloned = new List<Job_Ticket_MtM__c>();
                String templateName = '';

                if(jobTicketMTMs.size() > 0) {
                    
                    for(Job_Ticket_MtM__c mtm : jobTicketMTMs) {

                        if(String.isBlank(templateName))
                            templateName = mtm.Job_Ticket__r.Template_Name__c;

                        //New Instance of Job Ticket MTM Instance. 
                        Job_Ticket_MTM__c newJTM = mtm.clone(false, false, false, false);
                        newJTM.Job_Ticket__c =  jobTicketId;
                        
                        jobTicketMtmToBeCloned.add(newJTM);
                    } 
                }

                if(jobTicketMtmToBeCloned.size() > 0)
                    insert jobTicketMtmToBeCloned;
                
                //Updating the Job Tickets. 
                Job_Ticket__c jTToBeUpdated = new Job_Ticket__c();
                jTToBeUpdated.Id = jobTicketId;
                jTToBeUpdated.Descriptive_Name__c = templateName;
                jTToBeUpdated.Added_Job_Template__c = true;
                
                Util.ByPassAllTriggers = true;
                update jTToBeUpdated;
                Util.ByPassAllTriggers = false;

                return LightningResponseEntity.create().setBody(jTToBeUpdated);
            }
            catch (Exception e) 
            {
                throw new CustomException('Exception occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n'); 
            }
        }
        else 
        {
            return null;    
        }        
    }
}