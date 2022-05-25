/*
Purpose         :   Batch class to create convert attachments to files.

Create By       :   Mahendra Swarnkar

Created Date    :   26/02/2020

Revision Log    :   V1.0 - Created - 26/02/2020 - CR-20180704-12321
                    V2.0 - Modify by - Mahendra Swarnkar - 5/7/2020 CR-20200506-14021

*/
global class Batch_UpdateContactFieldProtocoled implements Database.Batchable<SObject> , Database.Stateful {
    
    public string queryString;
    Public Integer count;
    
    global set<Id> setOfTrueContact;
    
    //hold the entire log message string value
    global String debugLogStr;
    
    //query the custom metadata record which hold the object and query detail
    Public Map<Integer,EventAndTask_Protocol_Manager__mdt> mapOfCustomMetadataDetails{
        set;
        get{
            if(mapOfCustomMetadataDetails == null){
                mapOfCustomMetadataDetails = new Map<Integer,EventAndTask_Protocol_Manager__mdt>();
                for(EventAndTask_Protocol_Manager__mdt customMetadata : [Select Id, Order_Number__c,Query__c,Object_Api_Name__c FROM EventAndTask_Protocol_Manager__mdt]){
                    if(customMetadata.Query__c != null)
                        mapOfCustomMetadataDetails.put((Integer)customMetadata.Order_Number__c,customMetadata);
                }   
            }
            
            return mapOfCustomMetadataDetails;
        }
    }
    
    Public Set<String> setOfEventType = new Set<String>();
    Public Set<Id> conId = new Set<Id>();
    Public Map<String, Set<String>> mapEventTypeWithEventPurpose = new  Map<String, Set<String>>();
    
    
    //Class Constructor
    public Batch_UpdateContactFieldProtocoled(Integer order, Set<Id> setOfConId){
        
        setOfTrueContact = setOfConId;
        debugLogStr = '';
        
        
        mapEventTypeWithEventPurpose.put('In Person Visit', new Set<String> {'Initial', 'Follow Up', 'Relationship Visit'});
        mapEventTypeWithEventPurpose.put('Phone Appointment', new Set<String> {'Initial', 'Follow Up', 'Prewire'});
        mapEventTypeWithEventPurpose.put('Web Visit', new Set<String> {'Initial', 'Follow Up'});
        
        
        
        for(String type  : mapEventTypeWithEventPurpose.keySet()){
            setOfEventType.add(type);
        }
        
        //Get/initialize the order/counter of child objects 
        count = order != null ? order : 1;
        
        //Generate the query string from the custom metadata
        if(mapOfCustomMetadataDetails != null && mapOfCustomMetadataDetails.size() > 0 && mapOfCustomMetadataDetails.containsKey(count)){
            if(mapOfCustomMetadataDetails.get(count).Query__c != null){
                
                //Get the query string related to a Object from the Meta data 
                queryString = mapOfCustomMetadataDetails.get(count).Query__c ;
                if(String.isNotBlank(mapOfCustomMetadataDetails.get(count).Object_Api_Name__c) && mapOfCustomMetadataDetails.get(count).Object_Api_Name__c == 'Event'){
                    queryString += ' AND Event_Type__c IN: setOfEventType';
                }
                if(String.isNotBlank(mapOfCustomMetadataDetails.get(count).Object_Api_Name__c) && mapOfCustomMetadataDetails.get(count).Object_Api_Name__c == 'Contact'){
                    queryString += ' AND  Id Not IN: setOfTrueContact';
                }
            }
            else
                throw new CustomException('Please add query in the custom metadata record');   	
        }
        else{
            //handle exception
            throw new CustomException('Please create custom metadata record.');   	
        }
    }
    
    //batch start method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator(queryString);
    }
    
    
    global void execute(Database.BatchableContext BC, list<Sobject> SobjectList) 
    {
        //Get Record Type
        Map<String,Id> mapOfObjWithRcrdTypeId = new  Map<String,Id>();
        mapOfObjWithRcrdTypeId.put('Event',Util.RecordTypeId('Event', 'Sales'));
        mapOfObjWithRcrdTypeId.put('Task',Util.RecordTypeId('Task', 'Sales Outreach'));
        
        //set of contactId
        Set<Id> setOfContactId = new  Set<Id>();
        
        Set<Id> setOfSobjId = new Set<Id>();
        
        //Map of contacts related to events
        Map<Id, List<Sobject>> mapOfSobjRelationship = new Map<Id, List<Sobject>>();
        
        //Map Of existing contact
        Map<Id,Contact> mapOfexistContacts = new Map<Id,Contact>();
        
        //List to update contact
        Map<Id, Contact> mapContactsToUpdate = new Map<Id, Contact>();
        
        if(SobjectList.size() > 0){
            
            //Check this logic of batch will execute for task and event only
            if(mapOfCustomMetadataDetails.get(count).Object_Api_Name__c == 'Task' || mapOfCustomMetadataDetails.get(count).Object_Api_Name__c == 'Event'){
               
                //fill setOfSobjId with sobject id's
                for(Sobject objt : SobjectList){
                    setOfSobjId.add((ID)objt.get('Id'));
                }
                
                 //Check this logic of batch will execute for task only
                if(mapOfCustomMetadataDetails.get(count).Object_Api_Name__c == 'Task'){
                    
                    //fill the map of task with taskrelationship and set of contact id's
                    for(TaskWhoRelation taskWhoRel: [SELECT RelationId, TaskId FROM TaskWhoRelation WHERE TaskId IN: setOfSobjId]){
                        
                        if(!mapOfSobjRelationship.containsKey(taskWhoRel.TaskId))
                        {
                            mapOfSobjRelationship.put(taskWhoRel.TaskId, new List<Sobject>());
                        }
                        mapOfSobjRelationship.get(taskWhoRel.TaskId).add(taskWhoRel);
                        setOfContactId.add(taskWhoRel.RelationId);
                    }
                }
                
                 //Check this logic of batch will execute for task only
                if(mapOfCustomMetadataDetails.get(count).Object_Api_Name__c == 'event'){
                    
                     //fill the map of task with taskrelationship and set of contact id's
                    for(EventWhoRelation eventWhoRel: [SELECT RelationId, EventId FROM EventWhoRelation WHERE EventId IN: setOfSobjId]){
                        
                        if(!mapOfSobjRelationship.containsKey(eventWhoRel.EventId))
                        {
                            mapOfSobjRelationship.put(eventWhoRel.EventId, new List<Sobject>());
                        }
                        mapOfSobjRelationship.get(eventWhoRel.EventId).add(eventWhoRel);
                        setOfContactId.add(eventWhoRel.RelationId);
                    }
                }
                
                //Query the contact 
                if(setOfContactId.size() > 0){
                    for(Contact con : [Select Id, Protocoled_Sales__c From contact where id IN: setOfContactId]){
                        if(!mapOfexistContacts.containsKey(con.Id)){
                            mapOfexistContacts.put(con.Id,new Contact());
                        }
                        mapOfexistContacts.put(con.Id,con);   
                    }     
                }
                

                for(Sobject obj: SobjectList){
                    if(mapOfSobjRelationship.containsKey((ID)obj.get('Id')) && mapOfSobjRelationship.get((ID)obj.get('Id')) != null){
                        
                        for(Sobject relationshipRcrd : mapOfSobjRelationship.get((ID)obj.get('Id'))){
                            //check for recordtype 
                            
                            if((Id)obj.get('RecordTypeId')  == mapOfObjWithRcrdTypeId.get(mapOfCustomMetadataDetails.get(count).Object_Api_Name__c)){
                            
                                
                                //logic will execute for event only
                                if(mapOfCustomMetadataDetails.get(count).Object_Api_Name__c == 'Event'){
                                    //Check for event type and event purpose
                                    if(mapEventTypeWithEventPurpose.containsKey((String)obj.get('Event_Type__c'))  &&
                                       mapEventTypeWithEventPurpose.get((String)obj.get('Event_Type__c')) != null  &&
                                       mapEventTypeWithEventPurpose.get((String)obj.get('Event_Type__c')).contains((String)obj.get('Event_Purpose__c')))
                                    {
                                        //add the contact to set which is marked as true
                                        setOfTrueContact.add((ID)relationshipRcrd.get('RelationId'));
                                        //Check if contact if Protocoled_Sales__c is false then marked it as true
                                        if(mapOfexistContacts.containsKey((ID)relationshipRcrd.get('RelationId')) &&
                                           mapOfexistContacts.get((ID)relationshipRcrd.get('RelationId')).Protocoled_Sales__c == false){
                                               mapContactsToUpdate.put((ID)relationshipRcrd.get('RelationId'), new Contact(Id = (ID)relationshipRcrd.get('RelationId'), Protocoled_Sales__c = true));
                                           }
                                    }
                                    
                                }
                                else if(mapOfCustomMetadataDetails.get(count).Object_Api_Name__c == 'Task'){
                                    
                                    //add the contact to set which is marked as true
                                    setOfTrueContact.add((ID)relationshipRcrd.get('RelationId'));
                                     //Check if contact if Protocoled_Sales__c is false then marked it as true
                                    if(mapOfexistContacts.containsKey((ID)relationshipRcrd.get('RelationId')) &&
                                       mapOfexistContacts.get((ID)relationshipRcrd.get('RelationId')).Protocoled_Sales__c == false)
                                    {
                                        mapContactsToUpdate.put((ID)relationshipRcrd.get('RelationId'), new Contact(Id = (ID)relationshipRcrd.get('RelationId'), Protocoled_Sales__c = true));
                                    }
                                }
                            }
                        }
                    }
                }
            }   
            
            //Check if batch is execute for contact then logic will execute
            if(mapOfCustomMetadataDetails.get(count).Object_Api_Name__c == 'Contact'){
                //check contact field Protocoled_Sales__c is true the update it to false
                for(Sobject obj : SobjectList){
                    if(obj.get('Protocoled_Sales__c') == true){
                        mapContactsToUpdate.put((ID)obj.get('Id'), new Contact(Id = (ID)obj.get('Id'), Protocoled_Sales__c = false));
                    }
                }
            }
            
            //Size check
            if(mapContactsToUpdate.size() > 0){
                
                //by pass logic
                Util.byPassAllTriggers = true;
                
                //update
                update mapContactsToUpdate.values();
                
                //by pass logic
                Util.byPassAllTriggers = false;
            }   
        }
    }
    
    
    //Finish method
    global void finish(Database.BatchableContext BC) 
    {
        //Integer variable to hold the count to execute the batch gain
       count = count + 1;
        
        
        //Again call the batch and pass the count value so that can access the another query from the metadata
        if(mapOfCustomMetadataDetails != null && mapOfCustomMetadataDetails.size() > 0 && count <= mapOfCustomMetadataDetails.size()){
            
            
            if(mapOfCustomMetadataDetails.ContainsKey(count)){
                
                
                
                //Calling of the batch
                Batch_UpdateContactFieldProtocoled batch = new Batch_UpdateContactFieldProtocoled(count,setOfTrueContact);
                batch.mapOfCustomMetadataDetails = mapOfCustomMetadataDetails;
                Database.executeBatch(batch);
            }
        }
    }
}