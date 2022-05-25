/**
 *  Purpose         :  This trigger is to control the automation on Job Ticket Component Object object.
 * 
 *  Created By      :   Dipesh Gupta
 *
 *  Created Date    :   10/14/2019
 *
 *  Revision Logs   :   V_1.0 - Created  - CR-20191011-13405
 *                     
**/
public class JobTicketComponentTriggerHelper 
{	
    /**
     *  Purpose         :   This method is used to update the respective job ticket if the 
     * 						values got updated on Job ticket component Type field. 
     * 
     *  Created By      :   Dipesh Gupta
     *
     *  Created Date    :   10/14/2019
     *
     *  Revision Logs   :   V_1.0 - Created  - CR-20191011-13405
     *                     
    **/
    public static void updateJobTicketBasedOnJobTicketComponentChange(List<Job_Ticket_Component__c> newJobTicketComponents, Map<Id, Job_Ticket_Component__c> mapJobTicketComponents) 
    {
		Set<Id> setJobTicketComponentIds = new Set<Id>();
        for(Job_Ticket_Component__c jTC : newJobTicketComponents) 
        {
            if(String.isNotBlank(jTC.Component__c) && mapJobTicketComponents != null 
               && mapJobTicketComponents.get(jTC.Id).Component__c != jTC.Component__c) 
            {
               	setJobTicketComponentIds.add(jTC.Id);    
            }
        }
        if(setJobTicketComponentIds.size() > 0) 
        {
           	List<Job_Ticket_MTM__c> jobTicketMtmsToSendOver = new List<Job_Ticket_MTM__c>();
            for(Job_Ticket_MTM__c jTM : [Select Id, Job_Ticket_Component__c, Job_Ticket__c 
                                         From Job_Ticket_MTM__c 
                                         Where  Job_Ticket_Component__c IN: setJobTicketComponentIds]) 
            {
                jobTicketMtmsToSendOver.add(jTM);
            }
            if(jobTicketMtmsToSendOver.size() > 0) {
                JobTicketMTMTriggerHelper.updateJobTicketFields(jobTicketMtmsToSendOver, null);
            }
        }
	}
}