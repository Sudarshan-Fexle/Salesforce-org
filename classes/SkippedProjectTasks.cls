/**
*  Purpose		:	Controller class for "Skipped Project tasks" list view button based VF page on PSA Project Task object.
*
*  Create By    :   Neha Sharma - 04/25/2022 - 
*  
*  Revision Log	:  v1.0 -  Created 
*
**/
public with sharing class SkippedProjectTasks
{
    private ApexPages.StandardSetController standardController;
    public String listFilterId {get; set;}
    public String buttonLabel {get;set;}
    public Boolean isCompleteLoaded {get; set;}
    
    //constructor
    public SkippedProjectTasks(ApexPages.StandardSetController stdController)
    {
        this.standardController = stdController; 
        this.listFilterId = standardController.getFilterId();
        isCompleteLoaded = false;
         system.debug('getProjTasks1');

    }
    
    
    public void runProcess()
    {
         system.debug('getProjTasks');
         isCompleteLoaded = true;
         List<pse__Project_Task__c> projTaskListToUpdate = new List<pse__Project_Task__c>();
         Map<Id,String> mapOfSuccessProjectTask = new Map<Id,String>();
        
         if(standardController.getSelected().size() > 0 )
         {
            system.debug(standardController.getSelected());
           
            String whereClause = 'WHERE Id IN : standardController.getSelected()';
            if(buttonLabel == 'Skipped')
            {
                whereClause += ' AND pse__Started__c = FALSE AND pse__Completed__c = FALSE';
            }
            else if(buttonLabel == 'InstaClose')
            {
            	whereClause +=  ' AND pse__Started__c = True';  
            }
             
            String query = 'SELECT Id,Name,pse__Started__c,pse__Status__c,pse__Completed__c FROM pse__Project_Task__c ' + whereClause;
             
            List<pse__Project_Task__c> projTask = database.query(query);

             if(projTask != null && projTask.size() > 0)
             {
                 for(pse__Project_Task__c ptask : projTask)
                 {
                     ptask.pse__Completed__c = true;
                     ptask.pse__Started__c = true;
                     if(buttonLabel == 'Skipped')
                     {
                         ptask.pse__Status__c = 'Skipped';
                     }
                     else if(buttonLabel == 'InstaClose')
                     {
                        ptask.pse__Status__c = 'Completed';
                     }
                     projTaskListToUpdate.add(ptask);
                     mapOfSuccessProjectTask.put(ptask.Id,ptask.Name);
                 }
                 
                 system.debug(projTaskListToUpdate);
                 if(projTaskListToUpdate.size() > 0)
                 {
                     try{
                         List<Database.SaveResult > updateResults = database.update(projTaskListToUpdate, false);
                         for(Integer i = 0, size = updateResults.size(); i < size; i++) {
                             if(updateResults[i].isSuccess()) {
                                 system.debug('update success' + updateResults[i]);
                                 //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, updateResults[i]));
                             }
                             else{
                                 system.debug('update error' + updateResults[i]);
                                 //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, updateResults[i]));
                             }
                         }
                        
                 
                     }
                     catch(exception ex)
                     {
                         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
                     }
                 }
                 
                
             }
             else
             {
                 system.debug('error1');
                 if(buttonLabel == 'Skipped')
                 {
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Skipped is only an option if the Task has not  Started.  The Aborted Status is an option for Started Tasks that are ending without the intended work.'));
                 }
                 else if(buttonLabel == 'InstaClose')
                 {
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Skipped is only an option if the Task has not  Started.  The Aborted Status is an option for Started Tasks that are ending without the intended work.'));
                 }
             }
         }
         else
         {
             system.debug('error2');
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select a single record to proceed further.'));
         }
        
        
    }
    
    /**
      * @Description    :   Method to go back to list view on click of button.
      *
      * @args           :   -
      *
      * @return         :   pagereference
      *
    **/
    public pagereference backToListView() 
    {
        return new ApexPages.Action('{!List}').invoke();
        
    }
    
    
    public static void updateProjectTask()
    {
        
    }
}