/**
 *  Description     :   Batch Class is used to create the opportunity contact role under the opportunity. 
 *
 *  Created By      :   Mahendra
 *
 *  Created Date    :   02/21/2020
 *
 *  Revision Logs   :   V_1.0 - Created - Mahindra - CR-20200121-13645
 *                      
 **/
global class Batch_CreateOppContactRole implements Database.Batchable<sObject>, Database.Stateful  {
    
    public string queryString;
    Public Integer count;
    
    global Map<Id,Contact> mapofContact;
    
    //hold the entire log message string value
    global String debugLogStr;
    
    //query the custom metadata record which hold the object and query detail
    Public Map<Integer,QueryToCreateOppContactRole__mdt> mapOfCustomMetadataDetails{
		set;
        get{
            if(mapOfCustomMetadataDetails == null){
             	mapOfCustomMetadataDetails = new Map<Integer,QueryToCreateOppContactRole__mdt>();
                for(QueryToCreateOppContactRole__mdt customMetadata : [Select Id,Object_Name__c, Order_Number__c,Query__c,Opportunity_LookUp_Field_Name__c,Contact_Lookup_Field_Name__c FROM QueryToCreateOppContactRole__mdt where Query__c != null]){
                    mapOfCustomMetadataDetails.put((Integer)customMetadata.Order_Number__c,customMetadata);
                }   
            }
            
            return mapOfCustomMetadataDetails;
        }
    }
    
    //Class Constructor
    public Batch_CreateOppContactRole(Integer order ){
        
        debugLogStr = '';
        
        //Get/initialize the order/counter of child objects 
        count = order != null ? order : 1;
        
        //Generate the query string from the custom metadata
        if(mapOfCustomMetadataDetails != null && mapOfCustomMetadataDetails.size() > 0 && mapOfCustomMetadataDetails.containsKey(count)){
            if(mapOfCustomMetadataDetails.get(count).Query__c != null){
                
                //Get the query string related to a Object from the Meta data 
            	queryString = mapOfCustomMetadataDetails.get(count).Query__c ;
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
    
    //batch execute method
    global void execute(Database.BatchableContext BC, List<Sobject> sobjectList){
     
        String logMessage ='';
        
        //Map to mhold the contacts 
        mapofContact = new Map<Id,Contact>();
        
        Map<Id,Sobject> mapOfEvent = new  Map<Id,Sobject>();
        Map<Id,List<Sobject>> mapOfSobject = new Map<Id,List<Sobject>>();
        
        //Set to hold the ccontact Ids
        Set<Id> setofContactId = new Set<Id>();
        
        //Set to hold the Opportunity Ids
        Set<Id> setofOpportunityId = new Set<Id>();
        
        //map to hold the existing OpportunityContactRole Associated with a source
        Map<String,List<OpportunityContactRole>> mapOfexistingOppContactRolewithSource = new  Map<String,List<OpportunityContactRole>>();
        
        //map to hold the existing OpportunityContactRole not Associated with a source
        Map<String,List<OpportunityContactRole>> mapOfexistingOppContactRolewithoutSource = new  Map<String,List<OpportunityContactRole>>();
        
        //map to hold OpportunityContactRole details which is going to be upsert
        Map<String,OpportunityContactRole> mapOfoppContactRoleToBeUpsert = new Map<String,OpportunityContactRole>();

        //map to hold OpportunityContactRole details which is going to be deleted
        Map<String,OpportunityContactRole> mapOfoppContactRoleToBeDelete = new Map<String,OpportunityContactRole>();
        
        //Object Name (Opportunity child Object for which Batch is executed)
        String objectName = mapOfCustomMetadataDetails.get(count).Object_Name__c != null ? mapOfCustomMetadataDetails.get(count).Object_Name__c : '';
        
        //Check for size
        if(sobjectList.size() > 0){
            
            //Loop over the records
            for(Sobject obj : sobjectList){
                
                if(String.isNotBlank(objectName) && objectName == 'Warm_Lead_MtM__c'){
                	 setofContactId.add((String)obj.getSobject('Warm_Lead__r').get('Contact__c'));    
                }
                else if (String.isNotBlank(objectName) && objectName == 'Event'){
                    mapOfEvent.put(obj.Id,obj);
                }
                else if(mapOfCustomMetadataDetails.size() > 0 && String.isNotBlank(mapOfCustomMetadataDetails.get(count).Contact_Lookup_Field_Name__c)){
                    //Populate the contact Id set
                    setofContactId.add((String)obj.get(mapOfCustomMetadataDetails.get(count).Contact_Lookup_Field_Name__c));    
                }
                
                //Populate the opportunity id set 
                if(mapOfCustomMetadataDetails.size() > 0 && String.isNotBlank(mapOfCustomMetadataDetails.get(count).Opportunity_LookUp_Field_Name__c)){
                    setofOpportunityId.add((String)obj.get(mapOfCustomMetadataDetails.get(count).Opportunity_LookUp_Field_Name__c));    
                }
            }    
            
            if(mapOfEvent.size() > 0  && String.isNotBlank(objectName) && objectName == 'Event'){
                for(EventWhoRelation evtWhoRel: [SELECT RelationId, EventId FROM EventWhoRelation WHERE EventId IN: mapOfEvent.keySet()]){
                    if(mapOfSobject.containsKey(evtWhoRel.EventId)){
                        mapOfSobject.get(evtWhoRel.EventId).add(evtWhoRel);
                    }
                    else if(!mapOfSobject.containsKey(evtWhoRel.EventId)){
                        mapOfSobject.put(evtWhoRel.EventId,new List<Sobject>{evtWhoRel});
                    }
                    setofContactId.add(evtWhoRel.RelationId);
                }
            }
            
            //Check for size
            if(setofContactId.size() > 0){
                
                //Query over the contacts and accordingly populate the contact Map
                for(Contact con  : [SELECT Id,EAB_Department__c From Contact where Id IN: setofContactId]){
                    mapofContact.put(con.Id,con);
                }
            }
        
            //Chekc for size
            if(setofContactId.size() > 0 && setofOpportunityId.size() > 0){
                
                //Query over the OpportunityContactRoles 
                for(OpportunityContactRole oppContactRole : [Select Id,Source_Record_Name__c,Role,Source_Record_Id__c,ContactId,OpportunityId 
                                                             FROM OpportunityContactRole 
                                                             WHERE OpportunityId IN: setofOpportunityId AND ContactId IN : setofContactId])
                {
                    //Chek for Source Record id on the OCR
                    if(String.isBlank(oppContactRole.Source_Record_Id__c)){
                        
                        //fill the existing OpportunityContactRole details in mapOfexistingOppContactRolewithoutSource
                        if(!mapOfexistingOppContactRolewithoutSource.ContainsKey(oppContactRole.ContactId+'-'+oppContactRole.OpportunityId)){
                            mapOfexistingOppContactRolewithoutSource.put(oppContactRole.ContactId+'-'+oppContactRole.OpportunityId,new List<OpportunityContactRole>());
                        }
                        
                        mapOfexistingOppContactRolewithoutSource.get(oppContactRole.ContactId+'-'+oppContactRole.OpportunityId).add(oppContactRole);   
                    }
                    else{
                        
                        //fill the existing OpportunityContactRole details in mapOfexistingOppContactRole
                        if(!mapOfexistingOppContactRolewithSource.ContainsKey(oppContactRole.ContactId+'-'+oppContactRole.OpportunityId)){
                            mapOfexistingOppContactRolewithSource.put(oppContactRole.ContactId+'-'+oppContactRole.OpportunityId,new List<OpportunityContactRole>());
                        }
                        
                        mapOfexistingOppContactRolewithSource.get(oppContactRole.ContactId+'-'+oppContactRole.OpportunityId).add(oppContactRole);
                    }
                }
            }
            if(objectName != 'Event'){
            	for(Sobject sobj :  sobjectList){
                mapOfSobject.put(sobj.Id,new List<Sobject>{sobj});
            }    
            }
           
            /*system.debug('mapOfCustomMetadataDetails'+mapOfCustomMetadataDetails);
            system.debug('setofContactId'+setofContactId);
            system.debug('setofOpportunityId'+setofOpportunityId);
            system.debug('mapOfexistingOppContactRolewithSource'+mapOfexistingOppContactRolewithSource);
            system.debug('mapOfexistingOppContactRolewithoutSource'+mapOfexistingOppContactRolewithoutSource);
            system.debug('mapofContact'+mapofContact);
            */
            
            String contactId = '';
            String opportunityId = '';
            Id existingConId;
            
            system.debug('mapOfSobject'+mapOfSobject);
            if(String.isNotBlank(objectName)){
                for(Id rcrdId : mapOfSobject.keyset()){
                    //Loop over the Opportunity child Object records for which Batch is executed
                    for(Sobject obj : mapOfSobject.get(rcrdId)){
                        system.debug('obj'+obj);
                        Sobject eventSobj ;
                        if(objectName == 'Event'){
                            eventSobj = mapOfEvent.get(rcrdId);
                            opportunityId = (String)eventSobj.get('WhatId');
                        }
                        else{
                           opportunityId = (String)obj.get(String.valueOf(mapOfCustomMetadataDetails.get(count).Opportunity_LookUp_Field_Name__c)); 
                        }
                        
                        if(String.isNotBlank(objectName) && objectName == 'Warm_Lead_MtM__c'){
                            contactId = (String)obj.getSobject('Warm_Lead__r').get('Contact__c');
                            existingConId = (ID)obj.getSobject('Warm_Lead__r').get('Contact__c');
                        }
                        else if(String.isNotBlank(objectName) && objectName == 'Event'){
                            contactId = (String)obj.get('RelationId');
                            existingConId = (ID)obj.get('RelationId');
                        }
                        else{
                            contactId = (String)obj.get(String.valueOf(mapOfCustomMetadataDetails.get(count).Contact_Lookup_Field_Name__c)); 
                            existingConId = (ID)obj.get(mapOfCustomMetadataDetails.get(count).Contact_Lookup_Field_Name__c);
                        }                     
                        
                        //Chekc for related Contact and Opportunity 
                        if(String.isNotBlank(contactId) && String.isNotBlank(opportunityId))
                        {
                            //Check if the OpportunityContactRole Is already exist or Not if not exist then created/ Insert a new Opportunity Contact Role record Else Update the existing Opportunity Contact Role record 
                            if(!(mapOfexistingOppContactRolewithoutSource.containsKey(contactId+'-'+opportunityId))
                               && !(mapOfexistingOppContactRolewithSource.containsKey(contactId+'-'+opportunityId)))
                            {
                                //OCR record instance
                                OpportunityContactRole oppContactRole = new OpportunityContactRole();
                                
                                //Check for the Opportubity child Object
                                //for Object = "Event" 
                                if(String.isNotBlank(objectName) && objectName == 'Event'){
                                    oppContactRole.Source_Record_Name__c = (String)eventSobj.get('Subject');  
                                }
                                else if(String.isNotBlank(objectName) && objectName == 'Warm_Lead_MtM__c'){ 
                                    oppContactRole.Source_Record_Name__c = (String)obj.getSobject('Warm_Lead__r').get('Name');
                                }
                                else{
                                    //for Object != "Event"
                                    oppContactRole.Source_Record_Name__c = (String)obj.get('Name'); 
                                }
                                
                                //Populate the contact.EAB_Department as the OCR's Role field value
                                if(mapofContact.size() > 0 && mapofContact.containsKey(existingConId)){
                                    oppContactRole.Role = mapofContact.get(existingConId).EAB_Department__c != null ? mapofContact.get(existingConId).EAB_Department__c : 'Other';
                                }
                                if(String.isNotBlank(objectName) && objectName == 'Warm_Lead_MtM__c'){
                                    oppContactRole.Source_Record_Id__c = (String)obj.get('Warm_Lead__c');
                                }
                                else if(String.isNotBlank(objectName) && objectName == 'Event'){
                                    oppContactRole.Source_Record_Id__c = (String)eventSobj.get('Id');    
                                }
                                else{
                                    oppContactRole.Source_Record_Id__c = (String)obj.get('Id');    
                                }
                                
                                oppContactRole.ContactId = contactId;
                                oppContactRole.OpportunityId = opportunityId; 
                                
                                //Populate the map to insert the OCR records
                                if(!mapOfoppContactRoleToBeUpsert.containsKey(contactId+'-'+opportunityId)){
                                    mapOfoppContactRoleToBeUpsert.put(contactId+'-'+opportunityId,oppContactRole);
                                }
                            }
                            else if((mapOfexistingOppContactRolewithSource.containsKey(contactId+'-'+opportunityId))){
                                
                                if(mapOfexistingOppContactRolewithSource.get(contactId+'-'+opportunityId).size() > 1){
                                    
                                    for(OpportunityContactRole opp1  : mapOfexistingOppContactRolewithSource.get(contactId+'-'+opportunityId)){
                                        
                                        if(opp1.Id != mapOfexistingOppContactRolewithSource.get(contactId+'-'+opportunityId)[0].Id && !mapOfoppContactRoleToBeDelete.containsKey(opp1.Id))
                                            
                                            //system.debug('opp1.Id ---'+opp1.Id);
                                            
                                            mapOfoppContactRoleToBeDelete.put(opp1.Id,opp1);   
                                    }                   
                                }
                                
                                if((mapOfexistingOppContactRolewithoutSource.containsKey(contactId+'-'+opportunityId))){
                                    
                                    for(OpportunityContactRole opp : mapOfexistingOppContactRolewithoutSource.get(contactId+'-'+opportunityId)){
                                        
                                        if(!mapOfoppContactRoleToBeDelete.containskey(opp.Id)) {
                                            //system.debug('opp.Id ---'+opp.Id);
                                            mapOfoppContactRoleToBeDelete.put(opp.Id,opp);    
                                        }      
                                    }
                                    //system.debug('mapOfoppContactRoleToBeDelete-##'+mapOfoppContactRoleToBeDelete);
                                }
                            }
                            else if((mapOfexistingOppContactRolewithoutSource.containsKey(contactId+'-'+opportunityId))){
                                Boolean getrecordToUpsert = false;
                                for(OpportunityContactRole opp : mapOfexistingOppContactRolewithoutSource.get(contactId+'-'+opportunityId)){
                                    if(getrecordToUpsert != true){
                                        OpportunityContactRole oppContactRole = new OpportunityContactRole();
                                        oppContactRole.Id = opp.Id;
                                        
                                        if(String.isNotBlank(objectName) && objectName == 'Event'){
                                            oppContactRole.Source_Record_Name__c = (String)eventSobj.get('Subject');  
                                        }
                                        else if(String.isNotBlank(objectName) && objectName == 'Warm_Lead_MtM__c'){ 
                                            oppContactRole.Source_Record_Name__c = (String)obj.getSobject('Warm_Lead__r').get('Name');
                                        }
                                        else{
                                            oppContactRole.Source_Record_Name__c = (String)obj.get('Name'); 
                                        }
                                        
                                        if(mapofContact.size() > 0 && mapofContact.containsKey(existingConId)){
                                            oppContactRole.Role = mapofContact.get(existingConId).EAB_Department__c != null ? mapofContact.get(existingConId).EAB_Department__c : 'Other';
                                        }
                                        
                                        if(String.isNotBlank(objectName) && objectName == 'Warm_Lead_MtM__c'){
                                            oppContactRole.Source_Record_Id__c = (String)obj.get('Warm_Lead__c');
                                        }
                                        else if(String.isNotBlank(objectName) && objectName == 'Event'){
                                            oppContactRole.Source_Record_Id__c = (String)eventSobj.get('Id'); 
                                        }
                                        else{
                                            oppContactRole.Source_Record_Id__c = (String)obj.get('Id');
                                        }
                                        
                                        if(!mapOfoppContactRoleToBeUpsert.containsKey(oppContactRole.Id)){
                                            mapOfoppContactRoleToBeUpsert.put(oppContactRole.Id,oppContactRole);     
                                        }
                                        getrecordToUpsert = true; 
                                        system.debug('mapOfoppContactRoleToBeUpsert###---'+mapOfoppContactRoleToBeUpsert);
                                    }	
                                    else{
                                        for(OpportunityContactRole oppConRole : mapOfexistingOppContactRolewithoutSource.get(contactId+'-'+opportunityId)){
                                            if(!mapOfoppContactRoleToBeDelete.containsKey(oppConRole.Id)){
                                                system.debug('oppConRole.Id ---'+oppConRole.Id);
                                                mapOfoppContactRoleToBeDelete.put(oppConRole.Id,oppConRole); 
                                            }
                                        } 
                                    }
                                }   
                                
                            }
                            
                        }
}
                }
            }
            
            //check mapToBeUpsertOppContactRole size
            if(mapOfoppContactRoleToBeUpsert.size() > 0){
                system.debug('mapOfoppContactRoleToBeUpsert--' + mapOfoppContactRoleToBeUpsert);
                logMessage = Util.createLog(Database.upsert((mapOfoppContactRoleToBeUpsert.values()),false));
            }
            if(mapOfoppContactRoleToBeDelete.size() > 0){
                system.debug('mapOfoppContactRoleToBeDelete--' + mapOfoppContactRoleToBeDelete);
                logMessage = Util.createLog(Database.delete((mapOfoppContactRoleToBeDelete.values()),false));
            }
                //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
                if(logMessage != '')
                    debugLogStr += logMessage;             
        }
        
    }
    
    //batch finish method
    global void finish(Database.BatchableContext BC){
        
      //Integer variable to hold the count to execute the batch gain
        count = count + 1;
        
        //Again call the batch and pass the count value so that can access the another query from the metadata
        if(mapOfCustomMetadataDetails != null && mapOfCustomMetadataDetails.size() > 0 && count <= mapOfCustomMetadataDetails.size()){
        
            if(mapOfCustomMetadataDetails.ContainsKey(count)){
                
                //Calling of the batch
                Batch_CreateOppContactRole batch = new Batch_CreateOppContactRole(count);
                batch.mapOfCustomMetadataDetails = mapOfCustomMetadataDetails;
                Database.executeBatch(batch);
            }
        }
        
          if(String.isNotBlank(debugLogStr)) { 
            //User Instance
            List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
            
            //Send log to admin
            if(sfAdminUser.size() > 0)
                Util.sendBatchStatus(BC.getJobId(), 'Batch_CreateOppContactRole', debugLogStr, sfAdminUser[0].Email);
        }
        
    }
    
}