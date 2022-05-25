/**
*  Description     :   Helper class for Competitor and Tech System object trigger.
*
*  Created By      :   Mahendra Swarnkar 
*
*  Created Date    :   11/24/2021
*
*  Revision Logs   :   V_1.0 - Created - CR-20211118-15596
*                      V_1.1 - Modified By - Chirag Soni - CR-20211207-15617 - 5/24/2022 - Commented reference for formula status field and added picklist status field in place of it.
**/
public class CompetitorandTechSystemTriggerHelper {
    
    
    /**
*  @description    :   Method to update the Project Object fields related to the Account.
*
*  @args           :   List<Competitor_and_Tech_System__c> newCompTechSystemList, Map<Id, Competitor_and_Tech_System__c> oldCompTechSystemMap
*
*  @return         :   void
*
*  Revision Logs   :   V_1.0 - Created By - Mahendra Swarnkar - CR-20211118-15596 - 11/24/2021
**/
    public static void updateProjectFields(List<Competitor_and_Tech_System__c> newCompTechSystemList, Map<Id, Competitor_and_Tech_System__c> oldCompTechSystemMap)
    {
        //Set to hold the Competitor and Tech System related Account ids. 
        set<Id> setCompTechAccountids = new set<Id>();
        
        Id externalSystemRTid = Schema.SObjectType.Competitor_and_Tech_System__c.getRecordTypeInfosByName().get('External System').getRecordTypeId();
        
        //loop on comptechsystem
        for(Competitor_and_Tech_System__c compTechSystem : newCompTechSystemList != null ? newCompTechSystemList : oldCompTechSystemMap.values())
        {
            //Check for the compTechSystem object changes.
            if(compTechSystem.RecordTypeId == externalSystemRTid && (oldCompTechSystemMap == null || (oldCompTechSystemMap != null
                                                                                                      && (oldCompTechSystemMap.get(compTechSystem.Id).Institution__c != compTechSystem.Institution__c
                                                                                                          || oldCompTechSystemMap.get(compTechSystem.Id).Tech_System__c != compTechSystem.Tech_System__c
                                                                                                          || oldCompTechSystemMap.get(compTechSystem.Id).Tech_Name__c != compTechSystem.Tech_Name__c
                                                                                                          || oldCompTechSystemMap.get(compTechSystem.Id).Category__c != compTechSystem.Category__c
                                                                                                          || oldCompTechSystemMap.get(compTechSystem.Id).Name != compTechSystem.Name
                                                                                                        //Modified By - Chirag Soni - CR-20211207-15617 - 5/24/2022 - Commented reference for formula status field and added picklist status field in place of it.       
                                                                                                        /*|| oldCompTechSystemMap.get(compTechSystem.Id).Status__c != compTechSystem.Status__c*/
                                                                                                          || oldCompTechSystemMap.get(compTechSystem.Id).Status2__c != compTechSystem.Status2__c))))
            {
                //Add the institution ids in the set. 
                setCompTechAccountids.add(compTechSystem.Institution__c); 
                
                //check if the old map is filled (Update case and Account/Tech System is changed.)
                if(oldCompTechSystemMap != null && oldCompTechSystemMap.containsKey(compTechSystem.Id) && 
                   oldCompTechSystemMap.get(compTechSystem.Id).RecordTypeId == externalSystemRTid)
                {
                    //Fill the set with the Account Id from Old Map to get the previous Account.
                    setCompTechAccountids.add(oldCompTechSystemMap.get(compTechSystem.Id).Institution__c); 
                }
            }
            //Delete use case
            if(newCompTechSystemList ==  null && oldCompTechSystemMap != null && oldCompTechSystemMap.containsKey(compTechSystem.Id))
            {
                //Fill the set with the Account Id from Old Map to get the previous Account.
                setCompTechAccountids.add(oldCompTechSystemMap.get(compTechSystem.Id).Institution__c); 
            }
        }
        
        //Check for the set size.
        if(setCompTechAccountids.size() > 0)
        {
            try
            {
                //List to hold the Project.
                List<Project__c> projectToBeUpdated = new List<Project__c>();
                
                //Query on the Account Object.
                for(Account acc : [Select Id, (Select Id, Name, Institution__c, Tech_System__c, Category__c From Competitors_and_Tech_Systems__r), 
                                   (Select Id, Current_SIS__c, Learning_Management_System__c, Enrollment_CRM__c, 
                                    Institution__c, RecordTypeId From Projects__r Where Record_Type_Text__c = 'Tech') 
                                   From Account Where Id IN: setCompTechAccountids])
                {
                    //Check for the list size. 
                    if(acc.Projects__r != null && acc.Projects__r.size() > 0 && acc.Competitors_and_Tech_Systems__r != null && acc.Competitors_and_Tech_Systems__r.size() > 0)
                    {
                        //calling a method on Project trigger helper. 
                        ProjectTriggerHelper.populateFieldsOnProjectFromCompTechSystem(acc.Projects__r, null); 
                        
                        //Adding the project to the list.
                        projectToBeUpdated.addAll(acc.Projects__r);
                    }
                }
                
                //checking for the size of the List. 
                if(projectToBeUpdated != null && projectToBeUpdated.size() > 0)
                {
                    Util.ByPassAllTriggers = true;
                    update projectToBeUpdated;
                    Util.ByPassAllTriggers = false;
                }
            }catch(Exception ex)
            {   
                if(Trigger.isDelete)
                    oldCompTechSystemMap.values().get(0).addError(ex.getMessage());
                else
                    newCompTechSystemList[0].addError(ex.getMessage());
            }
        }
    }
    
}