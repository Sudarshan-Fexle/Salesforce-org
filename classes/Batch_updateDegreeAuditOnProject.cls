/**
 *  Description     :   Helper class for Asset object trigger.
 *
 *  Created By      :   Abhinav Sharma
 *
 *  Created Date    :   12/19/2018
 *
 *  Revision Logs   :   V_1.0 - Created by - Neha Sharma - CR-20200615-14188 - 04/08/2021 - Add the logic to perform historical data update for Degree Audit
 *                      V_1.1 - Modified By - Mahendra Swarnkar - CR-20211118-15596 - 11/24/2021 - Added changes to work with Competitor and Tech System Object and its fields instead of "Assets" object and fields.
 * 						V_1.2 - Modified By - Chirag Soni - CR-20211207-15617 - 5/24/2022 - Commented reference for formula status field and added picklist status field in place of it.
**/
global class Batch_updateDegreeAuditOnProject implements Database.Batchable<SObject>, Database.Stateful 
{
    // Start(Database.BatchableContext) method from Database.Batchable class
    global Database.queryLocator start(Database.BatchableContext ctx)
    {
        return Database.getQueryLocator('Select Id,Institution__c,Recordtype.Name from project__c where Recordtype.Name = \''+ 'Tech\'');
    }
    
    global void execute(Database.BatchableContext ctx, List<project__c> listOfProject)
    {
        if(listOfProject.size() > 0) {
            
            Map<Id, List<Project__c>> mapOfAccountIdandProjects = new Map<Id, List<Project__c>>();
            
            //map to hold the Project Ids
            Map<Id,Project__c> mapOfProject = new  Map<Id,Project__c>();
            //Set to hold the Project Ids
            Set<Id> setOfProjecctDegreeAudit = new Set<Id>();
            
            Map<Id,Project__c> projectToBeUpdate = new Map<Id,project__c>();
            
            for(Project__c proj : listOfProject){
                
                if(!mapOfAccountIdandProjects.ContainsKey(proj.Institution__c))
                {
                    mapOfAccountIdandProjects.put(proj.Institution__c, new List<Project__c>());
                }
                mapOfAccountIdandProjects.get(proj.Institution__c).add(proj); 
                
                mapOfProject.put(proj.Id,proj);
            }
            
            //Modified By - Mahendra Swarnkar - CR-20211118-15596 - 11/24/2021 - Commented asset related logic
            /*Map<Id,List<Asset>> mapOfAccountIdandAssets =  new Map<Id,List<Asset>>();
            for(Asset ass : [Select Id, Name, AccountId, TechStatus__c,TechSystem__c, TechCategory__c
                             From Asset
                             Where AccountId IN : mapOfAccountIdandProjects.keySet()
                             ORDER BY AccountId, CreatedDate DESC])
            {
                if(!mapOfAccountIdandAssets.ContainsKey(ass.AccountId))
                    mapOfAccountIdandAssets.put(ass.AccountId, new List<Asset>());
                mapOfAccountIdandAssets.get(ass.AccountId).add(ass);
            }
            
            for(Project__c pro : mapOfProject.values()){
                pro.Degree_Audit__c = '';
                pro.current_SIS__c = '';
                pro.Learning_Management_System__c = '';
                pro.Enrollment_CRM__c = '';
                
                if(mapOfAccountIdandAssets.containsKey(pro.Institution__c))
                {
                    for(Asset ass : mapOfAccountIdandAssets.get(pro.Institution__c))
                    {
                        //get list of techSystem values
                        List<String> techSystemValues = new List<String>();
                        
                        if(String.isNotBlank(ass.TechSystem__c) && ass.TechSystem__c.contains(';'))
                            techSystemValues = ass.TechSystem__c.split(';');
                        else
                            techSystemValues.add(ass.TechSystem__c); 
                        for(String techSys : techSystemValues)
                        {
                            if(techSys == 'Degree Audit')
                            {
                                if(ass.TechStatus__c == 'current'){
                                    if(String.IsNotBlank(pro.Degree_Audit__c)){
                                        pro.Degree_Audit__c = pro.Degree_Audit__c +','+ass.Name ;
                                    }
                                    else{
                                        pro.Degree_Audit__c = ass.Name ;
                                    }
                                } 
                            }
                             else if(techSys == 'SIS')
						{
							if(ass.TechStatus__c == 'current'){
							    if(String.IsNotBlank(pro.current_SIS__c)){
									pro.current_SIS__c = pro.current_SIS__c +','+ass.Name ;
								}
								else{
									pro.current_SIS__c = ass.Name ;
								}	
							}
						}
						else if(techSys == 'LMS')
						{
							if(ass.TechStatus__c == 'current'){
							    if(String.IsNotBlank(pro.Learning_Management_System__c)){
									pro.Learning_Management_System__c = pro.Learning_Management_System__c + ','+ass.Name ;
								}
								else{
									pro.Learning_Management_System__c = ass.Name ;
								}
							}
						}
						else if(String.isNotBlank(ass.TechCategory__c) && ass.TechCategory__c == 'Enrollment' && techSys == 'CRM')
						{
							if(ass.TechStatus__c == 'current'){
							    if(String.IsNotBlank(pro.Enrollment_CRM__c )){
									pro.Enrollment_CRM__c = pro.Enrollment_CRM__c +','+ass.Name ;
								}
								else{
									pro.Enrollment_CRM__c = ass.Name ;
								}
							}
						}
                        }
                        
                    }
                }
            } */
            
             //Modified By - Mahendra Swarnkar - CR-20211118-15596 - 11/24/2021 - Added logic for Competitor and Tech system Object  - from here 
             
            Map<Id,List<Competitor_and_Tech_System__c>> mapOfAccountIdandCompTechSystems =  new Map<Id,List<Competitor_and_Tech_System__c>>();
            //Modified By - Chirag Soni - CR-20211207-15617 - 5/24/2022 - Commented reference for formula status field and added picklist status field in place of it.   
            for(Competitor_and_Tech_System__c compTechSystem : [Select Id, Name, Institution__c, /*Status__c,*/ Status2__c, Tech_System__c, Category__c
                                                                From Competitor_and_Tech_System__c Where Institution__c IN : mapOfAccountIdandProjects.keySet() ORDER BY Institution__c, CreatedDate DESC])
            {
                if(!mapOfAccountIdandCompTechSystems.ContainsKey(compTechSystem.Institution__c))
                    mapOfAccountIdandCompTechSystems.put(compTechSystem.Institution__c, new List<Competitor_and_Tech_System__c>());
                mapOfAccountIdandCompTechSystems.get(compTechSystem.Institution__c).add(compTechSystem);
            }
            
             
            for(Project__c pro : mapOfProject.values())
            {
                pro.Degree_Audit__c = '';
                pro.current_SIS__c = '';
                pro.Learning_Management_System__c = '';
                pro.Enrollment_CRM__c = '';
                
                if(mapOfAccountIdandCompTechSystems.containsKey(pro.Institution__c))
                {
                    for(Competitor_and_Tech_System__c compTechSystem : mapOfAccountIdandCompTechSystems.get(pro.Institution__c))
                    {
                        //get list of techSystem values
                        List<String> techSystemValues = new List<String>();
                        
                        if(String.isNotBlank(compTechSystem.Tech_System__c) && compTechSystem.Tech_System__c.contains(';'))
                            techSystemValues = compTechSystem.Tech_System__c.split(';');
                        else
                            techSystemValues.add(compTechSystem.Tech_System__c); 
                        for(String techSys : techSystemValues)
                        {
                            if(techSys == 'Degree Audit')
                            {
                                //Modified By - Chirag Soni - CR-20211207-15617 - 5/24/2022 - Commented reference for formula status field and added picklist status field in place of it.      
                                if(/*compTechSystem.Status__c == 'current'*/ compTechSystem.Status2__c == 'Current'){
                                    if(String.IsNotBlank(pro.Degree_Audit__c)){
                                        pro.Degree_Audit__c = pro.Degree_Audit__c +','+compTechSystem.Name ;
                                    } else{
                                        pro.Degree_Audit__c = compTechSystem.Name ;
                                    }	
                                } 
                            }else if(techSys == 'SIS')
                            {
                                 //Modified By - Chirag Soni - CR-20211207-15617 - 5/24/2022 - Commented reference for formula status field and added picklist status field in place of it.      
                                if(/*compTechSystem.Status__c == 'current'*/ compTechSystem.Status2__c == 'Current'){
                                    if(String.IsNotBlank(pro.current_SIS__c)){
                                        pro.current_SIS__c = pro.current_SIS__c +','+compTechSystem.Name ;
                                    }else{
                                        pro.current_SIS__c = compTechSystem.Name ;
                                    }	
                                }
                            }else if(techSys == 'LMS')
                            {
                                 //Modified By - Chirag Soni - CR-20211207-15617 - 5/24/2022 - Commented reference for formula status field and added picklist status field in place of it.      
                                if(/*compTechSystem.Status__c == 'current'*/ compTechSystem.Status2__c == 'Current'){
                                    if(String.IsNotBlank(pro.Learning_Management_System__c)){
                                        pro.Learning_Management_System__c = pro.Learning_Management_System__c + ','+compTechSystem.Name ;
                                    }else{
                                        pro.Learning_Management_System__c = compTechSystem.Name ;
                                    }
                                }
                            }else if(String.isNotBlank(compTechSystem.Category__c) && compTechSystem.Category__c == 'Enrollment' && techSys == 'CRM')
                            {
                                 //Modified By - Chirag Soni - CR-20211207-15617 - 5/24/2022 - Commented reference for formula status field and added picklist status field in place of it.      
                                if(/*compTechSystem.Status__c == 'current'*/ compTechSystem.Status2__c == 'Current'){
                                    if(String.IsNotBlank(pro.Enrollment_CRM__c )){
                                        pro.Enrollment_CRM__c = pro.Enrollment_CRM__c +','+compTechSystem.Name ;
                                    }else{
                                        pro.Enrollment_CRM__c = compTechSystem.Name ;
                                    }
                                }
                            }
                        }
                    }
                }
            }//Modified By - Mahendra Swarnkar - CR-20211118-15596 - 11/24/2021 - Added logic for Competitor and Tech system Object  - till here 
            if(mapOfProject.values().size() > 0)
            {
                Util.byPassAllTriggers = true;
                update mapOfProject.values();
                Util.BypassAllTriggers = false;
             }
         }
    }
    
    global void finish(Database.BatchableContext ctx)
    {
        
    }
}