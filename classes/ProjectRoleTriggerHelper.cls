/**
    Purpose         :   Helper class for Trigger on Project Role Object.
                
    Created By      :   Abhinav Sharma
    
    Created Date    :   03/03/2015
    
    Current Version :   v1.0
    
    Revision Log    :   v1.0 - Abhinav Sharma - 03/03/2015 - CR-20141222-8389 - Added methods (validateProjectKeyRole, validateExistanceOfPrimaryRoles)
                        V1.1 - Abhinav Sharma - CR-20200828-14475 - 09/18/2020 - Add the check to prevent the update of Name field of project Role except contact and role field update
			V1.2 - Abhinav Sharma - CR-20200318-13865 - 17/06/2020 
        
**/
public class ProjectRoleTriggerHelper {

    //Added By - Abhinav Sharma - CR-20141222-8389 - 03/03/2015
    /**
     *  @description    :  Method to check and validate that primary Project Role can only be added once.  
     *
     *  @args           :   List of project roles, Boolean isBefore
     * 
     *  @return         :   void
     * 
    **/ 
    public static void validateExistanceOfPrimaryRoles(List<Project_Role__c> newProjectRoles, Map<Id, Project_Role__c> mapOldProjectRoles) {
        
        //Set to hold the project IDs
        Set<Id> setProjectIds = new Set<Id>();
        
        //Set to hold the role values
        Set<String> setOfPrimaryRoles = new Set<String>();
        setOfPrimaryRoles.add('Executive Sponsor');
        setOfPrimaryRoles.add('Contract Signer');
        setOfPrimaryRoles.add('Implementation Lead');
        setOfPrimaryRoles.add('Value Lead');
        
        //Loop through new project role records
        for(Project_Role__c pR : newProjectRoles) {
            
            
            //Checking and validating for role field values
            if(mapOldProjectRoles == null || (mapOldProjectRoles != null && mapOldProjectRoles.get(pR.Id) != null 
                                                && mapOldProjectRoles.get(pR.Id).Role__c != pR.Role__c)) {
                if(pR.Project__c != null)      
                    setProjectIds.add(pR.Project__c);
                    
                if(mapOldProjectRoles != null && mapOldProjectRoles.get(pR.Id) != null
                    && mapOldProjectRoles.get(pR.Id).Project__c != null)
                    setProjectIds.add(mapOldProjectRoles.get(pR.Id).Project__c);
                                                    
            }
        }
        
        //Set to hold the project record types IDs - needs to be excluded for the role standardization logic
        Set<ID> setExcludedRecordTypes = new Set<ID>();
        //Modified By - Abhinav Sharma - 06/17/2020 - CR-20200318-13867 - Project Page Layout and RT deletions
        for(RecordType rd : [SELECT ID FROM RecordType WHERE sObjectType = 'Project__c' AND IsActive = true
                                    AND (/*DeveloperName = 'Univ' OR DeveloperName = 'NPD' OR DeveloperName = 'ABSS'
                                            OR*/ DeveloperName = 'SSC' /*OR DeveloperName = 'Southwind' OR DeveloperName = 'TI'
                                                OR DeveloperName = 'Consulting'*/)])
            setExcludedRecordTypes.add(rd.Id);
        
        //Map of Projects
        Map<Id, Project__c> mapProjects = new Map<Id, Project__c>([SELECT ID, RecordTypeId FROM Project__c 
                                                                    WHERE ID IN : setProjectIds AND RecordTypeID NOT IN : setExcludedRecordTypes]);
        
        //Map to hold the Project Id - Role combined string as key and corresponding record count as value
        Map<String, Integer> mapProjectIdAndRoleKeyWithRecordCount = new Map<String, Integer>();
            
       
        //Loop through change requests records already assigned to a release
        for(Project_Role__c pRol : [SELECT ID, Role__c, Project__c FROM Project_Role__c 
                                            WHERE Project__c != null AND Project__c IN: mapProjects.keySet()]) {
                                              
              //Modified by - Dipesh Gupta - 05-27-2020 - CR-20200519-14068                                  
               List<string> rolelist = new List<string>(); 
               if(String.isNotBlank(pRol.Role__c) && (pRol.Role__c).contains(';')){
                      rolelist = (pRol.Role__c).split(';');
                }
                else if(String.isNotBlank(pRol.Role__c) && !(pRol.Role__c).contains(';')){
                      rolelist.add(pRol.Role__c);
                    
                      
                }
                                                
             for(String role : rolelist){                                   
                //Checking for the primary role values and accordingly populating the map                                
                if(String.isNotBlank(role) && setOfPrimaryRoles.contains(role)) {
               
                if(mapProjectIdAndRoleKeyWithRecordCount.containsKey(pRol.Project__c + '-' + role))
                     mapProjectIdAndRoleKeyWithRecordCount.put(pRol.Project__c + '-' +role, mapProjectIdAndRoleKeyWithRecordCount.get(pRol.Project__c + '-' + role) + 1);
                else
                    mapProjectIdAndRoleKeyWithRecordCount.put(pRol.Project__c + '-' + role, 1); 
               
                }
             }
        }
        
         
        //Loop through new project role records
        for(Project_Role__c pRole : newProjectRoles) {
            //Modified by - Dipesh Gupta - 05-27-2020 - CR-20200519-14068   
            List<string> rolelist = new List<string>(); 
            if(String.isNotBlank(pRole.Role__c) && (pRole.Role__c).contains(';')){
                rolelist = (pRole.Role__c).split(';');
            }
            else if(String.isNotBlank(pRole.Role__c) && !(pRole.Role__c).contains(';')){
                rolelist.add(pRole.Role__c);
            }
            
            for(string role :rolelist){
                if(pRole.project__c != null && String.isNotBlank(role)
                   && mapProjectIdAndRoleKeyWithRecordCount != null  
                   && mapProjectIdAndRoleKeyWithRecordCount.get(pRole.project__c + '-' + role) != null
                   && mapProjectIdAndRoleKeyWithRecordCount .get(pRole.project__c + '-' + role) > 1) {
                       pRole.addError(System.Label.Error_Message_Primary_Role_Already_Exists);
                   }
            }
        }
    }
    
    //Added By - Abhinav Sharma - CR-20141222-8389 - 03/03/2015
    /**
     *  @description    :  Method to update the flag “Key Roles Identified” on “Project” record as TRUE.
     *                     If we are having Project Role associated to it with below each below listed roles:-
     *                          Executive Sponsor
     *                          Contract Signer
     *                          Implementation Lead
     *                          Value Lead
     *                     If not then false.
     * 
     *  @args           :   List of project roles, map of old project roles
     * 
     *  @return         :   void
     * 
    **/ 
    public static void validateProjectKeyRole(List<Project_Role__c> newProjectRoles, Map<Id, Project_Role__c> mapOldProjectRoles) {
        
        //Set of Project Ids
        Set<Id> setProjectIds = new Set<Id>();
        
        //Map of Projects
        Map<Id, Project__c> mapProjects = new Map<Id, Project__c>();
        
        //Loop through the Project Roles records
        if(newProjectRoles != null) {
            
            //Loop through new project role records
            for(Project_Role__c pR : newProjectRoles) {
                
                //Insert case
                if(mapOldProjectRoles == null) {
                    if(pR.Project__c != null)
                        setProjectIds.add(pR.Project__c);
                //Update Case
                } else {
                    if(pR.Project__c != null)
                        setProjectIds.add(pR.Project__c);
                    if(mapOldProjectRoles.get(pR.Id).Project__c != null)
                        setProjectIds.add(mapOldProjectRoles.get(pR.Id).Project__c);
                }      
            }
        //Delete Case
        } else {
            for(Project_Role__c pRole : mapOldProjectRoles.values()) {
                if(mapOldProjectRoles.get(pRole.Id).Project__c != null)
                    setProjectIds.add(mapOldProjectRoles.get(pRole.Id).Project__c);
            }
        }
         
        //Check if there are records to update
        if(setProjectIds.size() > 0) {
            
            //Set to hold the role values
            Set<String> setRoles = new Set<String>();
            setRoles.add('Executive Sponsor');
            setRoles.add('Contract Signer');
            setRoles.add('Implementation Lead');
            setRoles.add('Value Lead');
            
	    // Modified By - Abhinav Sharma - CR-20200318-13867
            //Set to hold the project record types IDs - needs to be excluded for the role standardization logic
            Set<ID> setExcludedRecordTypes = new Set<ID>();
            for(RecordType rd : [SELECT ID FROM RecordType WHERE sObjectType = 'Project__c' AND IsActive = true
                                    AND DeveloperName = 'SSC' /*(DeveloperName = 'Univ' OR DeveloperName = 'NPD' OR DeveloperName = 'ABSS'
                                            OR DeveloperName = 'SSC' OR DeveloperName = 'Southwind' OR DeveloperName = 'TI')*/])
                setExcludedRecordTypes.add(rd.Id);
            
	    // Commentout Field for CR-20200318-13865
            //Map of ELigible Projects
            mapProjects = new Map<Id, Project__c>([SELECT ID, RecordTypeId/*, Key_Roles_Identified__c*/ FROM Project__c 
                                                                                    WHERE ID IN : setProjectIds 
                                                                                    AND RecordTypeID NOT IN : setExcludedRecordTypes]);
            
            //Map to hold the project Id as key and set of corresponding project roles role field values
            Map<Id, Set<String>> mapProjectIdWithSetOfRoles = new Map<Id, Set<String>>();
            
            
            //Loop through change requests records already assigned to a release
            for(Project_Role__c pRol : [SELECT ID, Role__c, Project__c FROM Project_Role__c 
                                                WHERE Project__c != null AND Project__c IN: mapProjects.keySet()]) {
                                                    
               //Modified by - Dipesh Gupta - 05-27-2020 - CR-20200519-14068                                  
               List<string> rolelist = new List<string>(); 
               if(String.isNotBlank(pRol.Role__c) && (pRol.Role__c).contains(';')){
                      rolelist = (pRol.Role__c).split(';');
                }
                else if(String.isNotBlank(pRol.Role__c) && !(pRol.Role__c).contains(';')){
                      rolelist.add(pRol.Role__c);
                }
                 
                for(String role : rolelist){
                    if(mapProjectIdWithSetOfRoles.containsKey(pRol.Project__c))
                        mapProjectIdWithSetOfRoles.get(pRol.Project__c).add(role);
                    else
                        mapProjectIdWithSetOfRoles.put(pRol.Project__c, new Set<String>{role}); 
                }                                    
                
            }
            
            //Loop through map keys
            for(String key : mapProjectIdWithSetOfRoles.keySet()) {
                if(mapProjectIdWithSetOfRoles.containsKey(key) && mapProjectIdWithSetOfRoles.get(key) != null && mapProjects.get(key) != null) {
                    //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                    /*if(mapProjectIdWithSetOfRoles.get(key).containsAll(setRoles))
                        mapProjects.get(key).Key_Roles_Identified__c = true;
                    else
                        mapProjects.get(key).Key_Roles_Identified__c = false;*/
                }
            }
        }
        
        //Checking for size value
        if(mapProjects.values().size() > 0) {
            Util.BypassAllTriggers = true;
            update mapProjects.values(); 
            Util.BypassAllTriggers = false;
        }       
    }

    //Added By - Dipesh gupta - CR-20200519-14068 - 05/27/2020
    /**
     *  @description    :  Method to update the Project Role Name.
     * 
     *  @args           :   List of project roles, map of old project roles
     * 
     *  @return         :   void
     * 
     * Revision log     :   V1.0 Modified by -  Abhinav Sharma - CR-20200828-14475 - 09/18/2020 -
     *                      Add the check to prevent the update of Name field of project Role except contact and role field update
    **/ 
    public static void updateProjectRoleName(List<Project_Role__c> newProjectRoles, Map<Id, Project_Role__c> mapOldProjectRoles){
        
        set<Id> setOfContactIds = new set<Id>();
        Map<Id,Contact> mapOfContact = new Map<Id,Contact>();
        List<Project_Role__c> projRoles = new list<Project_Role__c>();
        
        for(Project_Role__c projRole : newProjectRoles){
            if(mapOldProjectRoles == null || (mapOldProjectRoles != null && 
                                              (mapOldProjectRoles.get(projRole.Id).Contact__c != projRole.Contact__c 
                                               || mapOldProjectRoles.get(projRole.Id).Role__c != projRole.Role__c
                                               || mapOldProjectRoles.get(projRole.Id).Name != projRole.Name
                                               || mapOldProjectRoles.get(projRole.Id).Name != projRole.Name)))
            {  
              if(projRole.Contact__c != null)
              {
              	setOfContactIds.add(projRole.Contact__c);
              }
              projRoles.add(projRole);
            }
        }

        //Modified by -  Abhinav Sharma - CR-20200828-14475 - 09/18/2020 - Name of Project Role is changed when updating the Buyer Role
        if(projRoles.size() > 0){
            
            //get the contact details first name, last name in query
            if(setOfContactIds.size() > 0){
                
                for(Contact con : [Select Id,Name,FirstName,LastName From Contact where Id IN : setOfContactIds])
                {
                    mapOfContact.put(con.Id,con);
                }
            }
            
            //Update the project role name with combination of contact and role
            for(Project_Role__c projRole : projRoles){
                String projectname = '';
                
                //check if contact exits of role add the contact name in project role
                if(mapOfContact.size() > 0 && mapOfContact.containsKey(projRole.Contact__c)){
                    projectname = mapOfContact.get(projRole.Contact__c).FirstName +' '+mapOfContact.get(projRole.Contact__c).LastName; 
                                       
                }
 
                //Check if project name contains the contact name then add the role in it else append only role in name
                if(String.isNotBlank(projRole.Role__c)){
                    if(String.isNotBlank(projectname)){  
                        projectname  = projectname +' - '+projRole.Role__c;
                    }
                    else{
                        projectname = (projRole.Role__c);
                    }  
                }
                
                //Added the condition to check name should not be more then 80 character so user will not get error while saving project role
                if(String.isNotBlank(projectname) && (projectname).length() > 80){
                    projRole.Name = ((projectname).substring(0, 80)).replace(';', '-');
                }
                else if(String.isNotBlank(projectname)) {
                    projRole.Name = (projectname).replace(';', '-');
                }
                else if(String.isBlank(projectname)) {
                    projRole.Name = 'null';
                }
            } 
        }
        //End here
        
         
    }
}