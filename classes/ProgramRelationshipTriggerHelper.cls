/**
 *  Description     :  Helper class for Trigger_ProgramRelationship trigger.
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  06/25/2015
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20150618-9013         
 *                      V_1.1 - Modified - Padmesh Soni - 07/11/2015 - CR-20150618-9013 - New method added - associateCollectionContentsOnCPC()
 *                      V_1.2 - Modified - Subhash Garhwal - 07/31/2015 - CR-20150618-9013 - New method added - validateCPCs
 *                      V_1.3 - Modified - Subhash Garhwal - 09/29/2015 - CR-20150925-9265 - Comment static flag
 *                      V_1.4 - Code Added - Subhash Garhwal - 08/04/2015 - CR-20150729-9114 - New method incentiveChangeLog added
 *                      V_1.5 - Code Added - Padmesh Soni - 08/12/2015 - CR-20150729-9114 - New method renameCPC added
 *                      V_1.6 - Code Modified - Subhash Garhwal - 10/15/2015 - CR-20151015-9325
 *                      V_1.7 - Modified - Rajeev Jain - CR-20151120-9402 - 04/19/2016 - Remove the usage of Collection_Perspective__c, since this field no longer exist on Incentive Change log object
 *						V_1.8 - Modified - Subhash Garhwal - Issue--CR10808--QA--00005222 - 08/25/2017 - Added a new logic to update the Program's Family field with Program Collection's Family field (validateProgramFamily method).
 *      
 **/
public without sharing class ProgramRelationshipTriggerHelper {

    /**
     *  @description    :   Method to check related Program Perspective's In Use values on record delation, If "In Use" values > 0, then throw an exception.
     *
     *  @args           :   List<Program_Relationship__c>
     *
     *  @return         :   void
     *
     **/
    public static void validateBeforeDelete(List<Program_Relationship__c> programRelationships) {

        //Loop through Program relationship
        for(Program_Relationship__c pR : programRelationships) {

            //Check for Program Relationship's Total In Use field (This field holds count of related Program Perspective's In Use values)
            if(pR.Total_In_Use__c > 0)
                throw new CustomException(Label.PROGRAM_RELATIONSHIP_IN_USE);
        }
    }
    

    /**
     *  @description    :   Method to notify related Program Perspective's Business Owner, when new record inserted or update occurs to the following fields:
     *                      Name, Effective_Start__c, Effective_End__c or record is deleted.
     *
     *  @args           :   List<Program_Relationship__c>, Map<Id, Program_Relationship__c>
     *
     *  @return         :   void
     *
     **/
    public static void keyInformationChangedNotification(List<Program_Relationship__c> programRelationships, Map<Id, Program_Relationship__c> mapOldprogramRelationships) {
        
        //Set to hold Program Relationship's Ids
        Set<Id> setPRIds = new Set<Id>();

        //Loop through program group data
        for(Program_Relationship__c pR : programRelationships != null ? programRelationships : mapOldprogramRelationships.values()) {
            
            //Subhash Garhwal - 23/7/2015 - CR-20150618-9013 - Code Commented as per Program Management Issues submitted by Taylor
            //Check appropriate condition (If changes occure in any key field)
            /*if(programRelationships != null && (mapOldprogramRelationships == null || pR.Name != mapOldprogramRelationships.get(pR.Id).Name
                || pR.Effective_Start__c != mapOldprogramRelationships.get(pR.Id).Effective_Start__c || pR.Effective_End__c != mapOldprogramRelationships.get(pR.Id).Effective_End__c)) {
                
                //Add Program Group Id in set
                setPRIds.add(pR.Id);
            
            //Check for delete case
            }*/
            
            if(programRelationships != null && mapOldprogramRelationships == null)
                setPRIds.add(pR.Id);    
             else if(programRelationships == null)
                setPRIds.add(pR.Id);
        }

        //Check for set size
        if(setPRIds.size() > 0) {
            
            //Query through email templete
            List<EmailTemplate> eTemplate = [Select Id, Name, DeveloperName From EmailTemplate where DeveloperName =: Label.PROGRAM_RELATIONSHIP_NOTIFICATION LIMIT 1];
            
            //List of SingleEmailMessage
            //This list is used to notify all the related program groups and Group Purpose
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            
            //Check for email template
            if(eTemplate.size() == 1) {
                
                //Set to hold Business Owner Ids
                Set<String> setBOwners = new Set<String>();
                
                //Query through Program Realtionship to get all the Program Group related to updated programs
                for(Program_Relationship__c pR : [Select Id, Name, Program_Perspective__c, Program_Perspective__r.Business_Owner__c From Program_Relationship__c Where Id IN : setPRIds AND Program_Perspective__r.Business_Owner__r.Email != null]) {
                    
                    //Check if set contains 
                    if(!setBOwners.contains(pR.Program_Perspective__r.Business_Owner__c)) {
                        
                        //Add email in list
                        mails.add(EmailHandler.email(eTemplate[0].Id, pR.Program_Perspective__r.Business_Owner__c, null));
                        
                        //Add Business Owner Id in set
                        setBOwners.add(pR.Program_Perspective__r.Business_Owner__c);    
                    }
                }
                
                //Subhash Garhwal - 27/7/2015 - CR-20150618-9013 - Code Commented as per Program Management Issues submitted by Taylor
                //Check for email list size to notify Program Group and Group Purpose owners
                //if(mails.size() > 0)
                    //Messaging.sendEmail(mails);
            }
        }
    }
    
    /**                 ~~~~~~~~ Code added - Padmesh Soni (07/10/2015) - CR-20150618-9014 ~~~~~~~~
     *  @description    :   Method is used for below use cases: 
     *                          When a new Collection Perspective Child (CPC) is created, create Collection Contents records. 
     *                              1. Identify the Collection Perspective record associated with the current CPC�s Program Collection and 
     *                              Perspective values
     *                              2. Identify each CPC associated with the Collection Perspective identified in the previous step
     *                              3. Create a Collection Content record for each CPC found, as follows:
     *                                  1. Collection Perspective Child = Original CPC (M/D)
     *                                  2. Collection Perspective = identified CPC (from step 1)
     *                                  3. Program Collection = associated CPC�s Program Collection
     *                                  4. Program = associated CPC�s Program 
     *                                  5. Related child = associated CPC
     *                          Upon a change to Program Collection or Perspective
     *                              1. Delete all related Collection Content records.
     *                              2. Recreate as described for creation.
     *
     *  @args           :   List<Program_Relationship__c>, Map<Id, Program_Relationship__c>
     *
     *  @return         :   void
     *
     **/
    public static void associateCollectionContentsOnCPC(List<Program_Relationship__c> newCollectionPerspectiveChildren, Map<Id, Program_Relationship__c> mapOldCollectionPerspectiveChildren) {
        
        //List to hold all new records of Collection Contents need to be inserted
        List<CollectionContents__c> collectionContentsToInserted = new List<CollectionContents__c>();
        
        //Map to hold Collection Perspective Child's Id with respect to Collection Perspective's Id
        Map<Id, Id> mapCPCWithCP = new Map<Id, Id>();
        
        //Set to hold Ids of Collection Perspective Child
        Set<Id> cPCIdsToUseDeletion = new Set<Id>();
        
        //Set to hold Collection Ids
        Set<Id> collectionIds = new Set<Id>();
        Set<Id> perspectiveIds = new Set<Id>();
        
        //Map to hold all unique Combination with respect to CPC of Program Collection Id - Perspective Id
        Map<Id, String> mapCPCWithPCAndPCombo = new Map<Id, String>();
        
        //Map to hold the CP Id with Child CPC
        Map<Id,Id> mapCPCIdWithCPId = new Map<Id, Id>();
        
        //Loop through Trigger.new
        for(Program_Relationship__c newCPC : [Select Id, Program_Perspective__c, Program_Group__c, Program_Perspective__r.Perspective__c,
                                                     Program_Perspective__r.Program_Group__c From Program_Relationship__c Where Program_Group__c != null 
                                                     AND Program__c = null AND RecordType.DeveloperName != 'Program'
                                                     AND Id IN :newCollectionPerspectiveChildren]) {
            
            //Check for appropriate conditions
            if(mapOldCollectionPerspectiveChildren == null && newCPC.Program_Perspective__c != null) { 
                
                //Add Program Collection in set
                collectionIds.add(newCPC.Program_Group__c);
                perspectiveIds.add(newCPC.Program_Perspective__r.Perspective__c);
                
                //Creating uniquekey combination of Collection Program Id and Perspective Id
                String uniqueKey = newCPC.Program_Group__c + '-' + newCPC.Program_Perspective__r.Perspective__c;
                        
                //populate map
                mapCPCWithPCAndPCombo.put(newCPC.Id, uniqueKey);
                mapCPCIdWithCPId.put(newCPC.Id,newCPC.Program_Perspective__c);
                
            } else if(mapOldCollectionPerspectiveChildren != null 
                && (mapOldCollectionPerspectiveChildren.get(newCPC.Id).Program_Perspective__c != newCPC.Program_Perspective__c
                    || mapOldCollectionPerspectiveChildren.get(newCPC.Id).Program_Group__c != newCPC.Program_Group__c)) { 
                
                //Check for updation with new values not with blank updates
                if(newCPC.Program_Perspective__c != null) {
                    
                    //populate set
                    perspectiveIds.add(newCPC.Program_Perspective__r.Perspective__c);
                    
                    //Creating uniquekey combination of Collection Program Id and Perspective Id
                    String uniqueKey = newCPC.Program_Group__c + '-' + newCPC.Program_Perspective__r.Perspective__c;
                            
                    //populate map
                    mapCPCWithPCAndPCombo.put(newCPC.Id, uniqueKey);
                    mapCPCIdWithCPId.put(newCPC.Id,newCPC.Program_Perspective__c);
                }
                
                //Add Program Collection in set
                collectionIds.add(newCPC.Program_Group__c);
                
                //populate set
                cPCIdsToUseDeletion.add(newCPC.Id);
            }
        }
        
        //Check for size
        if(mapCPCWithPCAndPCombo.size() > 0) {
            
            //Map to hold query result
            Map<Id, Program_Perspective__c> mapCollectionPerspective = new Map<Id, Program_Perspective__c>(
                                                                                [SELECT Id, Perspective__c, Program_Group__c 
                                                                                    FROM Program_Perspective__c 
                                                                                    WHERE Perspective__c IN: perspectiveIds 
                                                                                    AND Program_Group__c IN: collectionIds]);
            
            //Map to hold unique key and CPC
            Map<String, List<Program_Relationship__c>> mapUniqueWithCPCs = new Map<String, List<Program_Relationship__c>>();
            
            //Loop through Collection Perspective Child query result
            for(Program_Relationship__c cPC : [SELECT Id, Program_Perspective__c, Program_Perspective__r.Program_Group__c, Program_Perspective__r.Perspective__c,
                                                      Program__c, Program_Group__c FROM Program_Relationship__c 
                                                      WHERE Program_Perspective__c IN: mapCollectionPerspective.keyset()]) {
                
                //Check for already contained key
                if(mapCollectionPerspective.containsKey(cPC.Program_Perspective__c)) {
                    
                    //Creating uniquekey combination of Collection Program Id and Perspective Id
                    String uniqueKey = mapCollectionPerspective.get(cPC.Program_Perspective__c).Program_Group__c 
                                        + '-' + mapCollectionPerspective.get(cPC.Program_Perspective__c).Perspective__c;
                    
                    //Check for already contained key
                    if(mapUniqueWithCPCs.containsKey(uniqueKey)) {
                        
                        //adding CPC on to map's key value
                        mapUniqueWithCPCs.get(uniqueKey).add(cPC);
                    } else {
                        
                        //populate map
                        mapUniqueWithCPCs.put(uniqueKey, new List<Program_Relationship__c>{cPC});
                    }
                }       
            }
            
            //Check for size
            if(mapUniqueWithCPCs.size() > 0) {
                
                //Loop through  map's keyset
                for(Id cPCId : mapCPCWithPCAndPCombo.keyset()) {
                    
                    //getting value on map's key
                    String uniqueKey = mapCPCWithPCAndPCombo.get(cPCId);
                    
                    //Check for already contained key
                    if(mapUniqueWithCPCs.containsKey(uniqueKey)) {
                        
                        //Loop through Program Relationship
                        for(Program_Relationship__c cPC : mapUniqueWithCPCs.get(uniqueKey)) {
                            
                            //populate the list to be inserted
                            collectionContentsToInserted.add(new CollectionContents__c(Collection_Perspective_Child__c = cPCId, 
                                                                Program__c = cPC.Program__c, Program_Collection__c = cPC.Program_Group__c, 
                                                                Collection_Perspective__c = mapCPCIdWithCPId.get(cPCId), Related_child__c = cPC.Id));
                        }
                    }
                }   
            }
        }
        
        //Check for size
        if(cPCIdsToUseDeletion.size() > 0) {
            
            //DML operation on Collection Contents
            delete [SELECT Id FROM CollectionContents__c WHERE Collection_Perspective_Child__c IN: cPCIdsToUseDeletion];
        }
        
        //Check for size of list
        if(collectionContentsToInserted.size() > 0)
            insert collectionContentsToInserted;
        
        //Subhash Garhwal - 09/29/2015 - CR-20150925-9265 - Code commented   
        //By pass the triggers here
        //Util.BypassAllTriggers = true;
    }
    
    //Mathod Modified - Subhash Garhwal - 10/15/2015 - CR-20151015-9325
    /**
     *  @description    :   This method is used to create a new CC records for existing Program Collection CPC records.
     *
     *  @args           :   List<Program_Relationship__c>
     *
     *  @return         :   void
     *
     **/
    public static void validateCollectionContentsOnCPC(List<Program_Relationship__c> collectionPChildren, Map<Id, Program_Relationship__c> mapOldCPCS) {
        
        //Set to hold Collection Ids
        Set<Id> setCollectionIds = new Set<Id>();
        
        //Set to hold Perspective Ids
        Set<Id> setPerspectiveIds = new Set<Id>();
        
        //Map to hold unique key and List of CPCs
        Map<String, List<Program_Relationship__c>> mapUniqueWithCPCs = new Map<String, List<Program_Relationship__c>>();
        
        //Set to hold the CPC Id to delete the CC records
        Set<Id> setCPCIds = new Set<Id>();
        
        //Loop through CPCs
        for(Program_Relationship__c cPC : [Select Id, Program_Perspective__c, Program__c, Program_Group__c, Program_Perspective__r.Perspective__c,
                                                     Program_Perspective__r.Program_Group__c, RecordType.DeveloperName From Program_Relationship__c
                                                     Where Id IN : collectionPChildren AND Program_Perspective__c != null]) {
            
            //Check for insert case
            if(mapOldCPCS == null || (mapOldCPCS != null && (cPC.Program__c != mapOldCPCS.get(cPC.Id).Program__c
                                     || cPC.Program_Group__c != mapOldCPCS.get(cPC.Id).Program_Group__c
                                     || cPC.Program_Perspective__c != mapOldCPCS.get(cPC.Id).Program_Perspective__c))) {
                
                //Check for update case
                if(mapOldCPCS != null)
                    setCPCIds.add(cPC.Id);
                
                //Populate set
                setCollectionIds.add(cPC.Program_Perspective__r.Program_Group__c);
                setPerspectiveIds.add(cPC.Program_Perspective__r.Perspective__c);
                
                //Unique key
                String uniqueKey = cPC.Program_Perspective__r.Program_Group__c + '-' + cPC.Program_Perspective__r.Perspective__c;
                
                //Check for unique Key in map
                if(mapUniqueWithCPCs.containsKey(uniqueKey))
                    
                    mapUniqueWithCPCs.get(uniqueKey).add(cPC);
                
                else
                    mapUniqueWithCPCs.put(uniqueKey, new List<Program_Relationship__c>{cPC});
            
            } else if(mapOldCPCS != null && (cPC.Program__c != mapOldCPCS.get(cPC.Id).Program__c || cPC.Program_Group__c != mapOldCPCS.get(cPC.Id).Program_Group__c
                        || cPC.Program_Perspective__c != mapOldCPCS.get(cPC.Id).Program_Perspective__c)) {
                
                
                //Populate set
                setCollectionIds.add(cPC.Program_Perspective__r.Program_Group__c);
                setPerspectiveIds.add(cPC.Program_Perspective__r.Perspective__c);
                
                //Unique key
                String uniqueKey = cPC.Program_Perspective__r.Program_Group__c + '-' + cPC.Program_Perspective__r.Perspective__c;
                
                //Check for unique Key in map
                if(mapUniqueWithCPCs.containsKey(uniqueKey))
                    
                    mapUniqueWithCPCs.get(uniqueKey).add(cPC);
                
                else
                    mapUniqueWithCPCs.put(uniqueKey, new List<Program_Relationship__c>{cPC});
            }
        }
        
        //Check for map size
        if(mapUniqueWithCPCs.size() > 0) {
            
            //List of Collection content to inset
            List<CollectionContents__c> collectionContents = new List<CollectionContents__c>();
            
            //Query through Program Relationship
            for(Program_Relationship__c cPC : [Select Id, Program_Perspective__c, Program__c, Program_Group__c, Program_Perspective__r.Perspective__c,
                                                     Program_Perspective__r.Program_Group__c From Program_Relationship__c Where Id NOT IN : collectionPChildren
                                                     AND Program_Perspective__r.Perspective__c != null AND Program_Perspective__r.Perspective__c IN : setPerspectiveIds
                                                     AND Program_Group__c IN : setCollectionIds
                                                     AND Program_Group__c != null AND RecordType.DeveloperName != 'Program']) {
                
                //Creating uniquekey combination of Collection Program Id and Perspective Id
                String uniqueKey = cPC.Program_Group__c + '-' + cPC.Program_Perspective__r.Perspective__c;
                        
                //Check unique Key in map
                if(mapUniqueWithCPCs.containsKey(uniqueKey)) {
                    
                    //Loop through New Program Collection records
                    for(Program_Relationship__c newCPC : mapUniqueWithCPCs.get(uniqueKey)) {
                        
                        //populate the list to be inserted
                        collectionContents.add(new CollectionContents__c(Collection_Perspective_Child__c = cPC.Id, 
                                                            Program__c = newCPC.Program__c, Program_Collection__c = newCPC.Program_Group__c, 
                                                            Collection_Perspective__c = cPC.Program_Perspective__c, Related_child__c = newCPC.Id));
                    }
                }
            }
            
            
            //Delete the CC records
            if(setCPCIds.size() > 0)
                delete [Select Id From CollectionContents__c Where Related_child__c IN : setCPCIds];
            
            //Check for list size
            if(collectionContents.size() > 0)
                insert collectionContents; 
        }
    }
    
    /**
     *  @description    :   Method to delete all the Collection Content related to it.
     *
     *  @args           :   List<Program_Relationship__c>
     *
     *  @return         :   void
     *
     **/
    public static void deleteCollectionContents(List<Program_Relationship__c> collectionPCs) {
        
        //Check for list size
        if(collectionPCs.size() > 0)
            delete [Select Id From CollectionContents__c Where Related_child__c IN : collectionPCs];
    }
    
    /**
     *  @description    :   This methiod is to validate the data before inserting into database. If there is any Duplicate, display error message to user.
     *
     *  @args           :   List<Program_Replationship__c>, Map<Id, Program_Relationship__c>
     *
     *  @return         :   void
     *
     **/
    public static void validateCPCs(List<Program_Relationship__c> cPChildren, Map<Id, Program_Relationship__c> mapOldCPChildren) {
        
        //Map to hold unique Key (Combination of Collection Perspective and Program/Program Collection) with collection of CPCs
        Map<String, List<Program_Relationship__c>> mapCPCsWithUK = new Map<String, List<Program_Relationship__c>>();
        
        //Set to hold Collection Perspective Ids
        Set<Id> setCPIds = new Set<Id>();
        
        //Loop through Collection Perspective Children
        for(Program_Relationship__c cPC : cPChildren) {
            
            //Check for Collection Perspective
            if(cPC.Program_Perspective__c != null && (mapOldCPChildren == null || cPC.Program_Perspective__c != mapOldCPChildren.get(cPC.Id).Program_Perspective__c
                || cPC.Program__c != mapOldCPChildren.get(cPC.Id).Program__c || cPC.Program_Group__c != mapOldCPChildren.get(cPC.Id).Program_Group__c
                || cPC.Effective_End__c != mapOldCPChildren.get(cPC.Id).Effective_End__c || cPC.Effective_Start__c != mapOldCPChildren.get(cPC.Id).Effective_Start__c)) {
                
                //Add Program Perspective Id in set
                setCPIds.add(cPC.Program_Perspective__c);
                
                //Unique Key
                String uniqueKey = '';
                
                uniqueKey += cPC.Program_Perspective__c;
                
                //Check Individual Program is null or not
                if(cPC.Program__c != null)
                
                    //Add Individual Program in unique key  
                    uniqueKey = uniqueKey + cPC.Program__c;
                
                //Check Program Collection is null or not
                if(cPC.Program_Group__c != null)
                    
                    //Add Program Collection in unique key
                    uniqueKey = uniqueKey + cPC.Program_Group__c;
                    
                //Check unique key in map
                if(mapCPCsWithUK.containsKey(uniqueKey)) {
                    
                    //Loop through CPC records
                    for(Program_Relationship__c nCPC : mapCPCsWithUK.get(uniqueKey)) {
                        
                        //Check for current record�s effective date if conflicting with any existing one
                        if((cPC.Effective_End__c == null && nCPC.Effective_End__c == null)
                            || (cPC.Effective_End__c != null && nCPC.Effective_End__c == null && cPC.Effective_End__c >= nCPC.Effective_Start__c)
                            || (cPC.Effective_End__c == null && nCPC.Effective_End__c != null && cPC.Effective_Start__c <= nCPC.Effective_End__c)
                            || (cPC.Effective_Start__c <= nCPC.Effective_End__c && cPC.Effective_Start__c >= nCPC.Effective_Start__c)
                            || (cPC.Effective_End__c >= nCPC.Effective_Start__c && cPC.Effective_End__c <= nCPC.Effective_End__c)
                            || (nCPC.Effective_Start__c <= cPC.Effective_End__c && nCPC.Effective_Start__c >= cPC.Effective_Start__c)
                            || (nCPC.Effective_End__c >= cPC.Effective_Start__c && nCPC.Effective_End__c <= cPC.Effective_End__c))
                        //Add Error
                        throw new CustomException(Label.ERROR_UNIQUENESS_CPC);
                    }
                    
                    //Add new CPC in map
                    mapCPCsWithUK.get(uniqueKey).add(cPC);
                
                //Add CPC record in map
                } else
                    mapCPCsWithUK.put(uniqueKey, new List<Program_Relationship__c> {cPC});
            }
        }
        
        //Check for size
        if(setCPIds.size() > 0 && mapCPCsWithUK.size() > 0) {
            
            //Query through Collection Perspective Child
            for(Program_Relationship__c cPC : [Select Id, Effective_End__c, Effective_Start__c, Program_Perspective__c, Program__c, Program_Group__c
                                                From Program_Relationship__c Where Program_Perspective__c IN : setCPIds AND Id NOT IN : cPChildren]) {
                                                    
                //Unique Key
                String uniqueKey = cPC.Program_Perspective__c;

                //Check Individual Program is null or not
                if(cPC.Program__c != null)
                
                    //Add Individual Program in unique key  
                    uniqueKey = uniqueKey + cPC.Program__c;

                //Check Program Collection is null or not
                if(cPC.Program_Group__c != null)
            
                    //Add Program Collection in unique key
                    uniqueKey = uniqueKey + cPC.Program_Group__c;
                    
                //Check unique key in map
                if(mapCPCsWithUK.containsKey(uniqueKey)) {
                    
                    //Loop through CPC records
                    for(Program_Relationship__c nCPC : mapCPCsWithUK.get(uniqueKey)) {
                        
                        //Check for current record�s effective date if conflicting with any existing one
                        if((cPC.Effective_End__c == null && nCPC.Effective_End__c == null)
                            || (cPC.Effective_End__c != null && nCPC.Effective_End__c == null && cPC.Effective_End__c >= nCPC.Effective_Start__c)
                            || (cPC.Effective_End__c == null && nCPC.Effective_End__c != null && cPC.Effective_Start__c <= nCPC.Effective_End__c)
                            || (cPC.Effective_Start__c <= nCPC.Effective_End__c && cPC.Effective_Start__c >= nCPC.Effective_Start__c)
                            || (cPC.Effective_End__c >= nCPC.Effective_Start__c && cPC.Effective_End__c <= nCPC.Effective_End__c)
                            || (nCPC.Effective_Start__c <= cPC.Effective_End__c && nCPC.Effective_Start__c >= cPC.Effective_Start__c)
                            || (nCPC.Effective_End__c >= cPC.Effective_Start__c && nCPC.Effective_End__c <= cPC.Effective_End__c))
                        
                        //Add Error
                        throw new CustomException(Label.ERROR_UNIQUENESS_CPC); 
                    }
                }                                   
            }
        } 
    }
    
    //Code Added  - Subhash Garhwal - 08/04/2015 - CR-20150729-9114 - New incentiveChangeLog method added.
    //V_1.7 - Modified - Rajeev Jain - CR-20151120-9402 - 04/19/2016 - Remove the usage of Collection_Perspective__c, since this field no longer exist on Incentive Change log object
    //Modifed the logic of creating the Incentive Change log, as per the updated SDD of Change Management. - Now creating change log based on CPC changes and populating in CPC field                                                               
    /**
     *  @description    :   This method is used to create Incentive Change Log, whenever a new CPC inserted or Effective Dates are modified.
     *  
     *  @args           :   List<Program_Relationship__c>, map<Id, Program_Relationship__c>
     *
     *  @return         :   void
     *
     **/
    public static void incentiveChangeLog(List<Program_Relationship__c> cPCs, Map<Id, Program_Relationship__c> mapOldCPCs){
      	//Garvit Jain
        /* 
        //List of Incentive Change logs
        List<Incentive_Change_Log__c> incentiveChangeLogs = new List<Incentive_Change_Log__c>();
        
        //Loop through CPC   
        for(Program_Relationship__c cPC : cPCs){
            
            //Add new Incentive change log into list for insert case
            if(mapOldCPCs == null)
                incentiveChangeLogs.add(new Incentive_Change_Log__c(Collection_Perspective_Child__c = cPC.Id,
                                                                    Change_Type__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_NEW,
                                                                    Change_Element__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_PROGRAM_COLLECTION)); 

            //Add new Incentive change log into list for update case
            if(mapOldCPCs != null && (cPC.Effective_Start__c != mapOldCPCs.get(cPC.Id).Effective_Start__c || cPC.Effective_End__c != mapOldCPCs.get(cPC.Id).Effective_End__c)) {
                    
                Incentive_Change_Log__c iCL = new Incentive_Change_Log__c(Collection_Perspective_Child__c = cPC.Id, 
                                                                          Change_Type__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_MODIFIED,
                                                                          Change_Element__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_PROGRAM_COLLECTION);
                    
                //check for start date
                if(cPC.Effective_Start__c != mapOldCPCs.get(cPC.Id).Effective_Start__c){
                    iCL.Start_Date__c = cPC.Effective_Start__c;
                    iCL.Change_Value__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_VALUE_START_DATE;
                }
                
                //Check for end date 
                if(cPC.Effective_End__c != mapOldCPCs.get(cPC.Id).Effective_End__c){
                    iCL.End_Date__c = cPC.Effective_End__c;
                    iCL.Change_Value__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_VALUE_END_DATE;
                }
                
                //Add list 
                incentiveChangeLogs.add(iCL);
            }
        }
        
        //Check insertIcg Size
        if(incentiveChangeLogs.size() > 0)
            insert incentiveChangeLogs;
    */
    }
    
    //Code Added  - Padmesh Soni - 08/12/2015 - CR-20150729-9114 - New renameCPC method added.
    /**
     *  @description    :   This method is used to rename CPC record before the record is commited.
     *
     *  @args           :   List<Program_Relationship__c>, map<Id, Program_Relationship__c>
     *
     *  @return         :   void
     *
     **/
    public static void renameCPC(List<Program_Relationship__c> cPCs, Map<Id, Program_Relationship__c> mapOldCPCs){
    
        //Loop through CPC   
        for(Program_Relationship__c cPC : cPCs)
            //Rename the name field
            cPC.Name = cPC.CPC_Name__c;
    }
    
    /**
     *  @description    :   This method is used to update the Program's Family field with Program Collection's Family field (validateProgramFamily method).
     *
     *  @args           :   List<Program_Relationship__c>, Map<Id, Program_Relationship__c>
     *
     *  @return         :   void
     *
     *	@revision Log	:	V1.0 - Created - 08/25/2017 - Subhas Garhwal - Issue--CR10808--QA--00005222 
     *
     **/
	public static void validateProgramFamily(List<Program_Relationship__c> programRelationships, Map<Id, Program_Relationship__c> mapOldProgramRelationships) {
		
		//Set to hold the Program Id
		Set<Id> setProgramIds = new Set<Id>();
		
		//SOQL over the PCC
		for(Program_Relationship__c pCC : programRelationships) {
			
			//Check for Program Collection change
			if((mapOldProgramRelationships == null && pCC.Program__c != null) || (mapOldProgramRelationships != null && (pCC.Program__c != mapOldProgramRelationships.get(pCC.Id).Program__c
				|| pCC.Program_Perspective__c != mapOldProgramRelationships.get(pCC.Id).Program_Perspective__c))) {
					
				//Add new Program
				setProgramIds.add(pCC.Program__c);
				
				//Check for update case
				if(mapOldProgramRelationships != null && mapOldProgramRelationships.get(pCC.Id).Program__c != null)
					setProgramIds.add(mapOldProgramRelationships.get(pCC.Id).Program__c);			
			}
		}
		
		//Check for set size
		if(setProgramIds.size() > 0) {
			
			//List to update the Programs
			List<Program__c> programsToUpdate = new List<Program__c>();
			
			//SOQL over the Program
			for(Program__c program : [Select Id, Family__c, Name ,(Select Id, Program_Group__c, Program_Perspective__r.Program_Group__r.Family__c,
										Program_Perspective__r.Program_Group__r.Name From Program_Relationships__r ORDER BY LastModifiedDate DESC LIMIT 1) From Program__c 
										Where Id IN : setProgramIds]) {
				
				//Check for Family
				if(program.Program_Relationships__r != null && program.Program_Relationships__r.size() == 1) {
					
					//Check for Family
					if((program.Program_Relationships__r[0].Program_Perspective__r.Program_Group__r.Family__c  != null 
							&& program.Family__c != program.Program_Relationships__r[0].Program_Perspective__r.Program_Group__r.Family__c ) 
							|| (program.Program_Relationships__r[0].Program_Perspective__r.Program_Group__r.Name  != null 
								&& program.Name != program.Program_Relationships__r[0].Program_Perspective__r.Program_Group__r.Name ))
						programsToUpdate.add(new Program__c(Id = program.Id, Family__c = program.Program_Relationships__r[0].Program_Perspective__r.Program_Group__r.Family__c,
						Parent_Bundle_s__c = program.Program_Relationships__r[0].Program_Perspective__r.Program_Group__r.Name));	
				}	
			}
			
			//Check for size
			if(programsToUpdate.size() > 0) {
				
				//Bypass
				Util.byPassAllTriggers = true;
                update programsToUpdate;
                Util.byPassAllTriggers = false;
			}
		}
	}
}