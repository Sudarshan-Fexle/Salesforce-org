/**
    * 
    *   @description    :  This Class is used to perform all the Implimentation of manipulation on the PSA Project object. 
    *
    *  Created By       :  Abhinav Sharma
    *
    *   @revision Log   :  V1.1  - Created by Abhinav Sharma - 09/24/2018 - CR-20180917-12599
    * 					   V1.2 - Modified by Colin McGloin - 04/01/2019 - CR-20190104-12806 
    * 
**/
public class PSAProjectTriggerHelper {
    
    //Variable.
    public Static Boolean PSA_PROJ_SYNC_PROCESS = false;
	
    /**
    * 
    *   @description    :  This mehtod is Used to populate the right Name on the PSA Project Object
    *
    *   @args           :  List<pse__Proj__c> newProjects
    *
    *   @return         :  void
    *
    *   @revision Log   :  V1.1  - Created by Abhinav Sharma - 09/24/2018 - CR-20180917-12599 
    * 
	**/ 
    public static void handleBeforeLogics(List<pse__Proj__c> newProjects) {
        
        //Set to hold the User Ids
        set<Id> setUserIds = new set<Id>();
        
        //Check for the Project loopup is Filled in the Project
        if(newProjects != null && newProjects.size() > 0) {
            
            //loop throgh the Projects
            for(pse__Proj__c psaProj : newProjects) {
            	
                //Check for the project.
                if(PSA_PROJ_SYNC_PROCESS) {
            		
                    if(!psaProj.Name.contains('PSA')) {
                    	
                        //check for the length of the name
                        if(psaProj.Name.length() > 74 ){
                             psaProj.Name = psaProj.Name.substring(0, 73) + ' - PSA';
                        }else {
                             psaProj.Name = psaProj.Name +  ' - PSA';
                        }
                    }

                    //Checking for the Field
                    if(String.isNotBlank(psaProj.PSA_Project_Manager_User__c)){
                    	//Fill the set with the User IDS
                        setUserIds.add(psaProj.PSA_Project_Manager_User__c);   
                    }
                }
            }
        }
        
        //Check the Size of the Set
        if(setUserIds.size() > 0) {
            
            //Map to hold the User id with corresponding Contact Id.
            Map<Id, Id> mapUserWithContact = new Map<Id, Id>();
            
            //Query on the Contact where User Employee Ids in this set -setUserIds
            for(Contact con : [Select Id, Employee_User_Record__c From Contact Where Employee_User_Record__c IN: setUserIds]) {
                
                //Filling Map with the Contact Id and user id.
                mapUserWithContact.put(con.Employee_User_Record__c, con.Id);
            }                   
            
            //Checking the Map Size
            if(mapUserWithContact != null && mapUserWithContact.size() > 0) {
                
                //Loop on the PSA Project records. 
                for(pse__Proj__c proj : newProjects) {
            		
                    //Check for the Map if it contains the Key of Project manager. 
                    if(mapUserWithContact.containsKey(proj.PSA_Project_Manager_User__c))
                        proj.pse__Project_Manager__c = mapUserWithContact.get(proj.PSA_Project_Manager_User__c);
                }
            }
        }
    }
    
    /**
    * 
    *   @description    :  This method is called to populate Region on records created Manually. Called from Process Builder.
    *
    *   @args           :  List<pse__Proj__c> newProjects
    *
    *   @return         :  void
    *
    *   @revision Log   :  V1.0  - Created by Colin McGloin - 01/04/2019 - CR-20190104-12806 
    * 
	**/
    @invocablemethod
    public static void updateRegionIfNeeded(List<pse__Proj__c> newProjects) {
        
        //Grab our Global Region
        List<pse__Region__c> globalRegion = [SELECT Id, Name FROM pse__Region__c WHERE Name = :Label.Shadow_Project_Region];
        
        //List of Projects to be updated
        List<pse__Proj__c> projsToUpdate = new List<pse__Proj__c>();
        
        //If we have a record to work with then proceed
        if(globalRegion.size() > 0){
            
            //Loop through our Projects and populate with Region value
            for (pse__Proj__c proj : newProjects){
                //Add our Project to the List for updating
                projsToUpdate.add(new pse__Proj__c (Id = proj.Id, pse__Region__c = globalRegion[0].Id));
            }   
        }
        
        //If we have records to update then proceed
        if (projsToUpdate.size() > 0){
            update projsToUpdate;
        }
        
    }
    
}