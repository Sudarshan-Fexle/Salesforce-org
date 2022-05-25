/**
 *  Purpose         :   Controller for CopyToClipboard component. 
 *
 *  Created By      :   Mahendra Swarnakar
 *
 *  Created Date    :   11/23/2020
 *
 *  Current Version :   v1.0 - Created
 *
 **/
public class CopyToClipboardController {

    /**
    *  @description    :   This method is used to copy the Counter Id from Project Task
    * 
	*  @args           :   Id (Project Task Id)
    *
    *  @return         :   String (Counter Id of Project Task)
    *
    *  @Version        :   V1.0 - Created By - Mahendra Swarnakar - 11/23/2020 - CR-20201020-14618 - Copy Counter Id from Project Task
    *
    **/
    @AuraEnabled
    public static List<pse__Project_Task__c> copyCounterId(Id projectTaskId ){
        
        List<pse__Project_Task__c> projectTask = new List<pse__Project_Task__c>();
        
        try{
            projectTask = projectTaskId != null ? [Select Counter_ID__c, PageProof_Proof_URL__c From pse__Project_Task__c Where Id =: projectTaskId] : new List<pse__Project_Task__c>();
            
        }
        catch(Exception ex){
            System.debug('Error::: '+ex.getMessage());
        }
        
        return projectTask;
    }
}