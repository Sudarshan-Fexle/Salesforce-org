/**
 *  Purpose         :   This class is to hold all the helper method for Intranet Schedule trigger.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   08/04/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 * 						V_1.1 - Modified By - Mahendra Swarnkar - CR-20141017-7805 - 07/28/2015
 *
 **/
 public without sharing class IntranetScheduleTriggerHelper {

    //Constants
    public final static String NAME_VALUES_SEPARATOR = ' - ';
    public final static String DATE_FORMAT_SEPARATOR = '-';
    public final static String ERROR_INVALID_ITEM_TYPE = 'The selected Item Type is not allowed in the specified Container.';
    
    /**
     *  @description    :   This method is being called on before events. It validates the record data and set it
                                #1: Intranet Container Name format:
                                    a.  For top level Containers (with no Parent Container): <Record Type>-Primary-<DisplayName>
                                    b.  For Child record Containers:  <Record Type>-<ParentContainerDisplayName>-<DisplayName>
     * 
     *  @args           :   List of new records
     * 
     *  @return         :   void
     * 
     **/
    public static void validateData(List<Intranet_Schedule__c> intranetSchedules) {
        
        //Create a set of  related container and items
        Set<Id> setIntranetContainers = new Set<Id>();
        Set<Id> setIntranetItems = new Set<Id>();
        
        //Loop through the records
        for(Intranet_Schedule__c iS : intranetSchedules) {
            
            //Set setIntranetContainers
            setIntranetContainers.add(iS.Intranet_Container__c);
            setIntranetItems.add(iS.Intranet_Item__c);
        }
        
        //Fetch related data from database
        Map<Id, Intranet_Container__c> mapIntranetContainers = new Map<Id, Intranet_Container__c>([Select Id, Display_Name__c, Content_Types_Allowed__c from Intranet_Container__c where Id IN: setIntranetContainers]);
        Map<Id, Intranet_Item__c> mapIntranetItems = new Map<Id, Intranet_Item__c>([Select Id, Item_Title__c, Item_Type__c, Office_Short_Name__c from Intranet_Item__c where Id IN: setIntranetItems]);
        
        //Added By - Mahendra Swarnkar - CR-20141017-7805 - 07/28/2015 
        // List to hold the record type record's for Intranet schedule  
        List< RecordType > IntraSchedRd = [select Id, DeveloperName from RecordType where     SObjecttype = 'Intranet_Schedule__c' AND DeveloperName = 'Static']; 
        
        //Loop through the records
        for(Intranet_Schedule__c iS : intranetSchedules) {
            
            /** Build Name **/
            
            //Set Name
            String icDisplayName = 'Null';
            String iItemTitle = 'Null';
            
            String allowedContentType;
            String itemType;
            
            //Added By - Mahendra Swarnkar - CR-20141017-7805 - 07/28/2015
            //Set the Start and End date time of the intranet schedule when record type is static
            //Starts from here  
            if(iS.RecordTypeId == IntraSchedRd[0].Id) {
                iS.Start_Date_Time__c = null;
                iS.End_Date_Time__c = null;
            }
            //Ends here
            
            //Local varibales to hold the Intranet Container and Item
            Intranet_Container__c intranetContainer = mapIntranetContainers.get(iS.Intranet_Container__c);
            Intranet_Item__c intranetItem = mapIntranetItems.get(iS.Intranet_Item__c);
            
            if(intranetContainer != null
                && intranetContainer.Display_Name__c != null){
                
                icDisplayName = intranetContainer.Display_Name__c;
                allowedContentType = intranetContainer.Content_Types_Allowed__c;
                
                //Get the first 20 characters if Display Name is more than 20
                if(icDisplayName.length() > 20)
                    icDisplayName = icDisplayName.left(20);
            }
            if(intranetItem != null){
                if(intranetItem.Item_Title__c != null){
                    
                	iItemTitle = intranetItem.Item_Title__c;
                	itemType = intranetItem.Item_Type__c;
                
                	//Get the first 40 characters if Title is more than 40
                	if(iItemTitle.length() > 40)
                    	iItemTitle = iItemTitle.left(40);
                }else if(intranetItem.Office_Short_Name__c != null){
                    iItemTitle = intranetItem.Office_Short_Name__c;
                }
            }
            
            //ASet Name
            iS.Name = icDisplayName + IntranetScheduleTriggerHelper.NAME_VALUES_SEPARATOR + iItemTitle;
            
            //Check for the Intranet Schedule Start Date
            if(iS.Start_Date_Time__c != null) {
                
                //Append Date in Name
                //YYYY-MM-DD format
                iS.Name += IntranetScheduleTriggerHelper.NAME_VALUES_SEPARATOR 
                                + iS.Start_Date_Time__c.year() + IntranetScheduleTriggerHelper.DATE_FORMAT_SEPARATOR
                                + ('0' + iS.Start_Date_Time__c.month()).right(2) + IntranetScheduleTriggerHelper.DATE_FORMAT_SEPARATOR
                                + ('0' + iS.Start_Date_Time__c.day()).right(2);
            }
            
            
            //Truncate to 80 CHaracters
            iS.Name = iS.Name.length() > 80 ? iS.Name.left(80) : iS.Name;
            
            system.debug('@@@iS.Name:' + iS.Name);
            if (iS.Name == null || iS.Name == '') throw new customException('NULLLLL');
            /** End: Name Part **/
            
            /** Validate If Item Type is a valid Item from Allowed Content Items **/
            
            //Check if selected Item type is in Content Allowed Items
            if(String.isNotBlank(allowedContentType) && String.isNotBlank(itemType) && !allowedContentType.containsIgnoreCase(itemType)) {
        		
        		//Throw validation error
        		throw new CustomException(IntranetScheduleTriggerHelper.ERROR_INVALID_ITEM_TYPE);
            }
        }
    }
    
    /**
     *  @description    :   This methid is  to create the create the Topics and Assign the on Items records
     * 
     *  @args           :   List and Map of items
     * 
     *  @return         :   void
     *
     **/
    public static void createTopics(List<Intranet_Schedule__c> newIntranetSchedules, Map<Id, Intranet_Schedule__c> mapOldIntranetSchedules) {
        
        //Create a set to Hold the Main Categoty Ids
        Set<Id> officeIds = new Set<Id>();
        Set<String> setDivisions = new Set<String>();
        Set<String> setFunctions = new Set<String>();
        Set<Id> oldOfficeIds = new Set<Id>();
        Set<String> setOldDivisions = new Set<String>();
        Set<String> setOldFunctions = new Set<String>();
        
        //Set to hold the intranet items ids
        Set<Id> setIntranetItemIds = new Set<Id>();
        
        //Loop through the new records
        for(Intranet_Schedule__c iS : newIntranetSchedules) {
            
            //setIntranetItemIds
            setIntranetItemIds.add(iS.Intranet_Item__c);
            
            //Check for the vaklues
            if(mapOldIntranetSchedules == null 
                || iS.Office__c != mapOldIntranetSchedules.get(iS.Id).Office__c) {
                
                //Office
                if(iS.Office__c != null)
                    officeIds.add(iS.Office__c);
            }
        }
        
        //Update
        if(mapOldIntranetSchedules != null) {
            
            //Loop through the new records
            for(Intranet_Schedule__c iS : newIntranetSchedules) {
                
                //setIntranetItemIds
                setIntranetItemIds.add(mapOldIntranetSchedules.get(iS.Id).Intranet_Item__c);
                
                //Office
                if(mapOldIntranetSchedules.get(iS.Id).Office__c != null && iS.Office__c != mapOldIntranetSchedules.get(iS.Id).Office__c) {
                    
                    //Old
                    oldOfficeIds.add(mapOldIntranetSchedules.get(iS.Id).Office__c);
                }
            }
        }
        
        //Fetch office Items
        Map<Id, Intranet_Item__c> mapOffice = new Map<Id, Intranet_Item__c>([Select Id, Name, Office_Short_Name__c from Intranet_Item__c 
                                                                                where Id IN: officeIds OR Id IN: oldOfficeIds]);
        
        //Map to hold the Topic with Schedules
        Map<String, Set<Id>> mapTopics = new Map<String, Set<Id>>();
        Map<String, Set<Id>> mapOldTopics = new Map<String, Set<Id>>();
        
        //Loop through the new records
        for(Intranet_Schedule__c iS : newIntranetSchedules) {
            
            //Check for the vaklues
            if(mapOldIntranetSchedules == null 
                || iS.Office__c != mapOldIntranetSchedules.get(iS.Id).Office__c
                || iS.Division__c != mapOldIntranetSchedules.get(iS.Id).Division__c
                || iS.Function__c != mapOldIntranetSchedules.get(iS.Id).Function__c) {
                
                //Office
                if(iS.Office__c != null && mapOffice.containsKey(iS.Office__c)) {
                    
                    //Topic Name
                    String topicName = mapOffice.get(iS.Office__c).Office_Short_Name__c;
                    
                    //Chekc in Map, if not exists, then add
                    if(!mapTopics.containsKey(topicName)) {
                        
                        //Add in map
                        mapTopics.put(topicName, new Set<Id>());
                    }
                        
                    //Create a Set to Hold the Category Name and related Schedules Ids
                    mapTopics.get(topicName).add(iS.Intranet_Item__c);
                }
                    
                //Division
                if(String.isNotBlank(iS.Division__c)) {
                    
                    //Split Values
                    List<String> lstDivision = iS.Division__c.split(';');
                    
                    //Loop through the divisions and prepare set
                    for(String topicName : lstDivision) {
                        
                        //Chekc in Map, if not exists, then add
                        if(!mapTopics.containsKey(topicName)) {
                            
                            //Add in map
                            mapTopics.put(topicName, new Set<Id>());
                        }
                            
                        //Create a Set to Hold the Category Name and related Schedules Ids
                        mapTopics.get(topicName).add(iS.Intranet_Item__c);      
                    }
                }
                
                //Function
                if(String.isNotBlank(iS.Function__c)) {
                    
                    //Split Values
                    List<String> lstFunction = iS.Function__c.split(';');
                    
                    //Loop through the divisions and prepare set
                    for(String topicName : lstFunction) {
                        
                        //Chekc in Map, if not exists, then add
                        if(!mapTopics.containsKey(topicName)) {
                            
                            //Add in map
                            mapTopics.put(topicName, new Set<Id>());
                        }
                            
                        //Create a Set to Hold the Category Name and related Schedules Ids
                        mapTopics.get(topicName).add(iS.Intranet_Item__c);      
                    }
                }
            }
        }
        
        //Update
        if(mapOldIntranetSchedules != null) {
            
            //Loop through the new records
            for(Intranet_Schedule__c iS : newIntranetSchedules) {
                
                //Office
                if(mapOldIntranetSchedules.get(iS.Id).Office__c != null && iS.Office__c != mapOldIntranetSchedules.get(iS.Id).Office__c) {
                    
                    //Topic Name
                    String topicName = mapOffice.get(mapOldIntranetSchedules.get(iS.Id).Office__c).Office_Short_Name__c;
                    
                    //Chekc in Map, if not exists, then add
                    if(!mapOldTopics.containsKey(topicName)) {
                        
                        //Add in map
                        mapOldTopics.put(topicName, new Set<Id>());
                    }
                        
                    //Create a Set to Hold the Category Name and related Schedules Ids
                    mapOldTopics.get(topicName).add(iS.Intranet_Item__c);
                }
                
                //Division
                if(mapOldIntranetSchedules.get(iS.Id).Division__c != null && iS.Division__c != mapOldIntranetSchedules.get(iS.Id).Division__c) {
                    
                    //Split Values
                    List<String> lstDivision = mapOldIntranetSchedules.get(iS.Id).Division__c.split(';');
                    
                    //Loop through the divisions and prepare set
                    for(String topicName : lstDivision) {
                        
                        //Chekc in Map, if not exists, then add
                        if(!mapOldTopics.containsKey(topicName)) {
                            
                            //Add in map
                            mapOldTopics.put(topicName, new Set<Id>());
                        }
                            
                        //Create a Set to Hold the Category Name and related Schedules Ids
                        mapOldTopics.get(topicName).add(iS.Intranet_Item__c);       
                    }
                }
                
                //Function
                if(mapOldIntranetSchedules.get(iS.Id).Function__c != null && iS.Function__c != mapOldIntranetSchedules.get(iS.Id).Function__c) {
                    
                    //Split Values
                    List<String> lstFunction = mapOldIntranetSchedules.get(iS.Id).Function__c.split(';');
                    
                    //Loop through the divisions and prepare set
                    for(String topicName : lstFunction) {
                        
                        //Chekc in Map, if not exists, then add
                        if(!mapOldTopics.containsKey(topicName)) {
                            
                            //Add in map
                            mapOldTopics.put(topicName, new Set<Id>());
                        }
                            
                        //Create a Set to Hold the Category Name and related Schedules Ids
                        mapOldTopics.get(topicName).add(iS.Intranet_Item__c);       
                    }
                }
            }
        }
        system.debug('mapOldTopics:::::::::::::'+mapOldTopics);
        
        //Fetch all the Topic in System Already and Create a Map to hold it
        Map<String, Topic> mapTopicWithName = new Map<String, Topic>();
        Set<Id> topicIds = new Set<Id>();
        
        for(Topic t : [Select Id, Name from Topic]) {
            
            //Add in map
            mapTopicWithName.put(t.Name, t);
            topicIds.add(t.Id);
        }
        system.debug('mapTopicWithName::::::::'+mapTopicWithName);
        
        //Check for the existing assignment
        Map<String, Id> existingTopicsAssignemnt = new Map<String, Id>();
        for(TopicAssignment tA : [Select EntityId, TopicId from TopicAssignment where EntityId IN: setIntranetItemIds AND TopicId IN: topicIds]) {
            
            //Add in Set
            existingTopicsAssignemnt.put(tA.TopicId + '-' + tA.EntityId, tA.Id);
        }
        
        //Topics to Add
        Map<String, Topic> topicsToAdd = new Map<String, Topic>();
        
        //Now loop through the Schedules again and create the Topics and Assignment
        for(String topicName : mapTopics.keySet()) {
            
            //Topic Name already exists
            if(!mapTopicWithName.containsKey(topicName)) 
                topicsToAdd.put(topicName, new Topic(Name = topicName));
              
        }
         system.debug('#@@@@@@@@@@@@@'+topicsToAdd);
         
        //Insert new Topics
        if(topicsToAdd.size() > 0) 
            insert topicsToAdd.values();
            
        //Club topics all together
        mapTopicWithName.putAll(topicsToAdd);
        
        //Delete list for tAs
        List<TopicAssignment> delTAs = new List<TopicAssignment>();
        
        //Loop through  the initial list and check which records need topics assignemnet deleted
        for(String topicName : mapOldTopics.keySet()) {
            
            //Schedules
            for(Id ScheduleId : mapOldTopics.get(topicName)) {
                
                //Check if topic exists
                if(mapTopicWithName.containsKey(topicName)) {
                    
                    //Unique Assignment Key
                    String uniqueKey = mapTopicWithName.get(topicName).Id + '-' + ScheduleId;
                    
                    //Only create the assignment record if not already exists
                    if(existingTopicsAssignemnt.containsKey(uniqueKey)) {
                        
                        //Add Assignment
                        delTAs.add(new TopicAssignment(Id = existingTopicsAssignemnt.get(uniqueKey)));
                    }
                }
            }
        }
        
        //Create a List of Topic Assignment to be added
        List<TopicAssignment> tAs = new List<TopicAssignment>();
        
        //Loop through  the initial list and check which records need topics created
        for(String topicName : mapTopics.keySet()) {
            
            //Schedules
            for(Id ScheduleId : mapTopics.get(topicName)) {
                
                //Check if topic exists
                if(mapTopicWithName.containsKey(topicName)) {
                    
                    //Unique Assignment Key
                    String uniqueKey = mapTopicWithName.get(topicName).Id + '-' + ScheduleId;
                    
                    //Only create the assignment record if not already exists
                    if(!existingTopicsAssignemnt.containskey(uniqueKey)) {
                        
                        //Add Assignment
                        tAs.add(new TopicAssignment(EntityId = ScheduleId, TopicId = mapTopicWithName.get(topicName).Id));
                    }
                }
            }
        }
        
        //Delete Assignment
        if(delTAs.size() > 0)
            delete delTAs;
        
        //Insert assignments
        if(tAs.size() > 0)
            insert tAs;
    }
}