/**
 *  Purpose         :   Helper class with name ComponentChangesDetailTriggerHelper
 *
 *  Create By       :   
 *
 *  Created Date    :   
 *
 *  Revision Logs   :   V_1.0 - Created
 *		    		:   V_1.1 - Modified By - Abhishek Mishra - 09/30/2021 - CR-20210909-15416 - method handelDuplicates() is commented to avoid extra processing
**/
public without sharing class ComponentChangesDetailTriggerHelper {
    
    public static void populateUserName(List<Component_Changes_Detail__c> newChangeDetail , Map<Id, Component_Changes_Detail__c> oldMap){
        
        Set<String> userId = new Set<String>();
        for(Component_Changes_Detail__c ccd: newChangeDetail){
            
            if(oldMap == null|| oldMap.get(ccd.Id).Last_Modified_By__c != ccd.Last_Modified_By__c || oldMap.get(ccd.Id).Created_By__c != ccd.Created_By__c)
                userId.add(ccd.Last_Modified_By__c);
            	userId.add(ccd.Created_By__c);

        }
        
        Map<Id , User> userDetials = new Map<Id,User>([Select Id , Name from User where Id =: userId]);
        
        for(Component_Changes_Detail__c ccd: newChangeDetail){
            
            if(userDetials.containsKey(ccd.Last_Modified_By__c)){
                ccd.Last_Modified_By_Name__c = userDetials.get(ccd.Last_Modified_By__c).Name;
                ccd.Created_By_Name__c = userDetials.get(ccd.Created_By__c).Name;
            }
        }
        
    }
    
    
    public static void checkISSystemComponent(List<Component_Changes_Detail__c> compChangeList){
        
        String recordTypeId = '012C0000000Ulom';
        
        Org_Comparision__c occ = [Select Id ,Change_Request__c , Create_Modifications_Manually__c From Org_Comparision__c where id =: compChangeList[0].Org_Comparison__c Limit 1];
        
        if(occ.Create_Modifications_Manually__c != true){
            
            String changeRequestId = occ.Change_Request__c; 
            
            String componentRecordTypeId = '012C0000000Ulog';
            
            //Find out only Unique set of Component Type, so that we can limit only those IsSystem Components to Retrieve
            Set<String> uniqueCompType =  new Set<String>();
            
            //Map to Hold Is System Component Instance Corrosponding to ObjectAPI name
            Map<String, IS_System_Component__c> mapComponentWithIsSystemComponent = new Map<String, IS_System_Component__c>();
            Map<String, Id> mapComponentWithIsSystemComponentId = new Map<String, Id>();
            
            
            //List of SFDC Mod to Inset and Update
            List<IS_System_Modification__c> listOfModForInsert = new List<IS_System_Modification__c>(); 
            
            //Remianing Component List for which no System Component Found
            List<Component_Changes_Detail__c> remainingComps = new List<Component_Changes_Detail__c>();
            
            for(Component_Changes_Detail__c compChange : compChangeList)
                uniqueCompType.add(compChange.Type__c);
            
            //Queryy Is System Components
            for(IS_System_Component__c isSysComp :[select Id, Name, Object_Label__c, Parent_API_Name__c, Object_API_Name__c, Object_Type__c 
                                                   from IS_System_Component__c where Object_Type__c IN : uniqueCompType])
                mapComponentWithIsSystemComponentId.put(isSysComp.Object_API_Name__c,isSysComp.id);
            
            
            //Loop over the new changes
            for(Component_Changes_Detail__c compChange : compChangeList){
                
                String compFullName = fullNameHelper(compChange);
                
                if(mapComponentWithIsSystemComponentId.containsKey(compFullName))
                    
                    listOfModForInsert.add(new IS_System_Modification__c(RecordTypeId = recordTypeId, Change_Request__c = changeRequestId, 
                                                                         IS_System_Component__c = mapComponentWithIsSystemComponentId.get(compFullName),
                                                                         Type_of_Modification__c = compChange.Type_Of_Mod__c,
                                                                         Include_in_Change_Set__c = true,
                                                                         Description__c = 'Component Modified'));
                else{
                    
                    remainingComps.add(compChange);
                    mapComponentWithIsSystemComponent.put(compFullName, new IS_System_Component__c(Object_Label__c = compFullName, 
                                                                                                   Object_API_Name__c = compFullName,
                                                                                                   Object_Type__c = compChange.Type__c,
                                                                                                   RecordTypeId = componentRecordTypeId));
                }
            }
            
            //insert mapComponentWithIsSystemComponent.values();
            if(mapComponentWithIsSystemComponent.size() > 0){
                
                Database.SaveResult[] saveResults1 = Database.insert(mapComponentWithIsSystemComponent.values(), false);
                String createLog1  = Util.createLog(saveResults1);
                if(String.isNotBlank(createLog1))
                    EmailHandler.sendEmail(Label.Environment_Manager_Email_Id, 'Error while Is System Compponent Insert, please refer below log ::', createLog1);
            }
            
            //Loop over the Remaining Comp to Insert
            for(Component_Changes_Detail__c compChange : remainingComps){
                
                String compFullName = fullNameHelper(compChange);
                
                if(mapComponentWithIsSystemComponent.containsKey(compFullName))
                    listOfModForInsert.add(new IS_System_Modification__c(RecordTypeId = recordTypeId, Change_Request__c = changeRequestId, 
                                                                         IS_System_Component__c = mapComponentWithIsSystemComponent.get(compFullName).Id,
                                                                         Type_of_Modification__c = compChange.Type_Of_Mod__c,
                                                                         Include_in_Change_Set__c = true,
                                                                         Description__c = 'Component Modified'));
            }
            
            if(listOfModForInsert.size() > 0){
                
                //Insert Mods
                Database.SaveResult[] saveResults2 = Database.insert(listOfModForInsert, false);
                
                String createLog2  = Util.createLog(saveResults2);
                
                //EmailHandler.sendEmail('rajeev.jain@simplyforce.com', 'Error while mod insert', createLog2);
                if(String.isNotBlank(createLog2))
                    EmailHandler.sendEmail(Label.Environment_Manager_Email_Id, 'Error while Mods insert, Please refer below log', createLog2);
            }
        }
    }
    
    public static String fullNameHelper(Component_Changes_Detail__c compChange){
        
        String compFullName = '';
        
        /* if(compChange.Type__c == 'Page Layout'){
        if(String.isNotBlank(compChange.Parent_API_Name__c))
        compFullName =  compChange.Parent_API_Name__c + '-' + compChange.Full_Name__c;
        else 
        compFullName = compChange.Full_Name__c;
        }else{
        
        if(String.isNotBlank(compChange.Parent_API_Name__c))
        compFullName = compChange.Parent_API_Name__c + '.' + compChange.Full_Name__c;
        else
        compFullName = compChange.Full_Name__c;
        }*/
        
        compFullName = compChange.Full_Name__c;
        return compFullName;
    }
    //Commented By - Abhishek Mishra - 09/30/2021 - CR-20210909-15416 - 
    //Commented out the method as it is unused and does not perform any functionality
    /*
    public static void handelDuplicates(List<Component_Changes_Detail__c> newChangeDetail) {
        
        //Set to hold the org comparision Ids
        Set<Id> setOrgComparisionIds = new Set<Id>();
        
        //Set to hold the new Component Change details Ids
        Set<Id> setComponentChangeDetailsIds = new Set<Id>();
        Set<String> setNewComponentChangeDeytailUniqueKey = new Set<String>();
         
        //String to hold the unique Key (uniqueKey = Type-Full Name-last Modified By Id)
        String uniqueKey;
        
        //Loop over the new component change details
        for(Component_Changes_Detail__c orgComp : newChangeDetail) {
        	
            //Check for org comparision and then populate the set setOrgComparisionIds
            if(orgComp.Org_Comparison__c != null){
                
                setOrgComparisionIds.add(orgComp.Org_Comparison__c);
                
                uniqueKey = '';
                
                if(String.isNotBlank(orgComp.Full_Name__c) &&  String.isNotBlank(orgComp.Type__c) && orgComp.Last_Modified_By__c != null) {
                    
                    uniqueKey = orgComp.Type__c + '-' + orgComp.Full_Name__c + '-' +orgComp.Last_Modified_By__c; 
                
                    //Check for duplicate records in the new list
                    if(!setNewComponentChangeDeytailUniqueKey.contains(uniqueKey) ) {
                        
                        //Populate the set with unique key for new records
                        setNewComponentChangeDeytailUniqueKey.add(uniqueKey);
                        setComponentChangeDetailsIds.add(orgComp.Id);
                    }
                }
            }
        }
        
        //Check for size
        if(setOrgComparisionIds.size() > 0) {
            
            //Map to hold the uniqueJ Key with list of duplicate component change detail records
            Map<String, List<Component_Changes_Detail__c>> mapOrgComparisions = new Map<String, List<Component_Changes_Detail__c>>();
            

            //Get all the COmponent change details related to org comparisions ins setOrgComparisionIds
            for(Component_Changes_Detail__c orgCompa : [SELECT Id, Full_Name__c, Last_Modified_By__c, Last_Modified_By_Name__c, Last_Modified_Date__c, Type__c, Type_Of_Mod__c FROM Component_Changes_Detail__c 
                                                        WHERE ID NOT IN : setComponentChangeDetailsIds AND Org_Comparison__c != null AND Org_Comparison__c IN : setOrgComparisionIds]) 
            {
                uniqueKey = '';
				
                //Build the uniqueKey and then accordingly populate the map                
                if(String.isNotBlank(orgCompa.Full_Name__c) &&  String.isNotBlank(orgCompa.Type__c) && orgCompa.Last_Modified_By__c != null) {
                    
                    // uniqueKey = Type-Full Name-last Modified By Id 
                    uniqueKey = orgCompa.Type__c + '-' + orgCompa.Full_Name__c + '-' + orgCompa.Last_Modified_By__c; 
                    
                    //contains check for the unique key and then populate the map
                    if(!mapOrgComparisions.containsKey(uniqueKey))
                        mapOrgComparisions.put(uniqueKey, new List<Component_Changes_Detail__c>());
                    mapOrgComparisions.get(uniqueKey).add(orgCompa);
                }
            }
            
            //Check for size
            if(mapOrgComparisions.size() > 0) {
				
                List<Component_Changes_Detail__c> listComponentChangeDeytailsToDelete = new List<Component_Changes_Detail__c>();
                
                setNewComponentChangeDeytailUniqueKey = new Set<String>();
                
                //Loop over the new component change details
                for(Component_Changes_Detail__c orgCompar : newChangeDetail) {
                    
                    uniqueKey = '';
                        
                    if(String.isNotBlank(orgCompar.Full_Name__c) &&  String.isNotBlank(orgCompar.Type__c) && orgCompar.Last_Modified_By__c != null) {
                    	
                        uniqueKey = orgCompar.Type__c + '-' + orgCompar.Full_Name__c + '-' +orgCompar.Last_Modified_By__c;    
                        
                        //Check for duplicate records in the new list
                        if(!setNewComponentChangeDeytailUniqueKey.contains(uniqueKey) ) {
                            
                            //Populate the set with unique key for new records
                            setNewComponentChangeDeytailUniqueKey.add(uniqueKey);
                            
                            //Check for the uniquekey in the map and check for the duplicate org comparisions size 
                            if(mapOrgComparisions.containsKey(uniqueKey) && mapOrgComparisions.get(uniqueKey) != null && mapOrgComparisions.get(uniqueKey).size() > 0) {
                                listComponentChangeDeytailsToDelete.addAll(mapOrgComparisions.get(uniqueKey));
                            
                            }
                        }//else {
                            //Add duplicate records for deletion in the new list 
                         //   listComponentChangeDeytailsToDelete.add(orgCompar);
                        //}
                    }
                }
                
                //Check for size
                if(listComponentChangeDeytailsToDelete.size() > 0) {
                    //Disable all the triggers 
                    Util.BypassAllTriggers = true;
                    
                    //Delete the duplicate mods
                    //delete listComponentChangeDeytailsToDelete;
                    
                   //Enable all the triggers
                    Util.BypassAllTriggers = false;
                }
            }   
        }
    }*/
}