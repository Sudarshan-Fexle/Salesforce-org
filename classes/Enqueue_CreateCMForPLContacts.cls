/**
*   Description     :   This Class is used to create the Campaign Members based on Product Lead' Contact and SL Cadence on Task. 
                
*   Created by      :   Dipesh Gupta
*
*   Created Date    :   
*
*   Revision Log    :   V1.0 - Created - Dipesh Gupta - CR-20190703-13207
*/
public class Enqueue_CreateCMForPLContacts implements Queueable {
    
	//Set to hold the tasks Ids.
    Set<Id> setTaskIds = new Set<Id>();
    
    //Constructor.
    public Enqueue_CreateCMForPLContacts(Set<Id> setTaskIds) {
        this.setTaskIds = setTaskIds;
    }
    
    public void execute(QueueableContext context) {
    	
        // Map of ProductLead Id with List of SL Cadence Name
        Map<Id, List<String>> mapOfProdLeadIdWithSLCadenceName = new Map<Id, List<String>>();
        
        //List to hold the eligible tasks. 
        List<Task> eligibleTasks = new List<Task>();
        
        //Tasks to get the field detials. 
        for(Task tsk : [Select Id, WhatId, Product_Lead__c,  SalesLoft1__SalesLoft_Cadence_Name__c From Task Where Id IN : setTaskIds ]){
        	
            if(tsk.WhatID != null && tsk.WhatId.getSObjectType() == Schema.Product_Lead__c.SobjectType) {
            	
                // Chk for SalesLoft1__SalesLoft_Cadence_Name__c 
                if(String.isNotBlank(tsk.SalesLoft1__SalesLoft_Cadence_Name__c)) {
                	
                    //Map of product Lead. 
                    if(!mapOfProdLeadIdWithSLCadenceName.containskey(tsk.WhatId))
                        mapOfProdLeadIdWithSLCadenceName.put(tsk.WhatId, new List<String>());
                    
                    mapOfProdLeadIdWithSLCadenceName.get(tsk.WhatId).add(tsk.SalesLoft1__SalesLoft_Cadence_Name__c);  
                    
                    eligibleTasks.add(tsk);
                }
            }    
        }
        
        if(eligibleTasks.size() > 0 ) {
                
            // Set to hold SL Cadence Name that matches the campaign
            Set<String> SLCadenceNameToChk = new Set<String>();
            
            // Chk for mapOfProdLeadIdWithSLCadenceName
            if(mapOfProdLeadIdWithSLCadenceName.size() > 0)
            {
                // Loop over mapOfProdLeadIdWithSLCadenceName to get product id
                for(Id prodId : mapOfProdLeadIdWithSLCadenceName.keySet())
                {
                    // get the list of sl cadence name for a product lead
                    for(String slName : mapOfProdLeadIdWithSLCadenceName.get(prodId))
                    {
                        String delimiter = '+';
                        String splitedSLCName = slName.substringBefore(delimiter);
                        SLCadenceNameToChk.add(splitedSLCName);
                    }
                }
            }
            
            //Map to hold the Set of Campaign member's Contact Ids with the Campaign. 
            Map<String, Set<Id>> mapCampaignIdWithSetOfContacts = new Map<String, Set<Id>>(); 
            
            //Map to hold the Set of CampaignId with the Campaign name. 
            Map<String, Id> mapCampaignIdWithName = new Map<String, Id>(); 
            
            // Map to hold product lead id with contact id
            Map<Id, Id> mapOfProdLeadIdWithContactId = new Map<Id, Id>();
            
            //List of CampaignMember to be insert
            List<CampaignMember> campaignMemberToBeInsert = new List<CampaignMember>();
            
            
            // chk for SLCadenceNameToChk
            if(SLCadenceNameToChk.size() > 0 )
            {	
                System.debug('SLCadenceNameToChk----'+SLCadenceNameToChk);
                
                // Query for that campaign that matches the name with set of SLCadenceNameToChk
                for(CampaignMember cmp : [SELECT Id, Campaign.Name,  CampaignId, ContactId FROM CampaignMember 
                                          WHERE CampaignId != null AND Campaign.Name != null AND ContactId != null
                                          AND Campaign.Name IN: SLCadenceNameToChk])
                {	
                    System.debug('test--->>>' +cmp);
                    
                    if(!mapCampaignIdWithSetOfContacts.containsKey(cmp.Campaign.Name))
                        mapCampaignIdWithSetOfContacts.put(cmp.Campaign.Name, new Set<Id>());
                    
                    //Adding the contact Ids from the campaignMembers.
                    mapCampaignIdWithSetOfContacts.get(cmp.Campaign.Name).add(cmp.ContactId);
                    mapCampaignIdWithName.put(cmp.Campaign.Name, cmp.CampaignId);
                }
                System.debug('test--->>>' +mapCampaignIdWithSetOfContacts);
                //Query for those Campaign that have no campaign. 
                for(Campaign cmp : [Select Id, Name From Campaign where name IN : SLCadenceNameToChk AND Name NOt IN: mapCampaignIdWithName.keySet()]){
                    
                    mapCampaignIdWithSetOfContacts.put(cmp.Name, new Set<Id>());
                    mapCampaignIdWithName.put(cmp.Name, cmp.Id);
                }
            }
            
            System.debug('Test--->>3'+mapOfProdLeadIdWithSLCadenceName);
            
            // Chk for mapOfProdLeadIdWithSLCadenceName
            if(mapOfProdLeadIdWithSLCadenceName.size() > 0)
            {
                // Query in product lead to get the contact id for that tagged product while creating task
                for(Product_Lead__c prodLead : [SELECT Id, Contact__c FROM Product_Lead__c 
                                                WHERE Id IN : mapOfProdLeadIdWithSLCadenceName.keySet()])
                {
                    // Chk if contact id is not null
                    if(prodLead.Contact__c != null)
                    {
                        if(!mapOfProdLeadIdWithContactId.containskey(prodLead.Id))
                            mapOfProdLeadIdWithContactId.put(prodLead.Id, prodLead.Contact__c);
                    }
                }
            }
            
            System.debug('Test--->>2'+eligibleTasks);
            
            //Iterating over eligibleTasks list. 
            for(Task eligibleT : eligibleTasks) {
                
                String relatedContactId = '';
                String relatedCampaignId = '';
                
                //Get the related product Lead Contact.  
                if(mapOfProdLeadIdWithContactId.containsKey(eligibleT.WhatId))
                    relatedContactId = mapOfProdLeadIdWithContactId.get(eligibleT.WhatId);
                
                String delimiter = '+';
                String splitedSLCName = eligibleT.SalesLoft1__SalesLoft_Cadence_Name__c.substringBefore(delimiter);
                
                //Check if we have the campaign...
                if(mapCampaignIdWithSetOfContacts.containsKey(splitedSLCName) && String.isNotBlank(relatedContactId)){
                    
                    //Check if we have the campaign Member.
                    if(mapCampaignIdWithSetOfContacts.get(splitedSLCName).contains(relatedContactId)){
                        //Nothing needed since CampaignMember is added Previously. 
                    }else {
                        
                        
                        relatedCampaignId = mapCampaignIdWithName.containsKey(splitedSLCName) ? mapCampaignIdWithName.get(splitedSLCName) : '';
                    }
                }
                
                //Check if we have the related Contact and Campaigns. 
                if(String.isNotBlank(relatedCampaignId) && String.isNotBlank(relatedContactId)){
                    campaignMemberToBeInsert.add(new CampaignMember(CampaignId = relatedCampaignId, ContactId = relatedContactId));
                }
            }
            
            //Check the size of List.  (We are not Bypassing Triggers intentionally...)
            System.debug('Test--->>1'+campaignMemberToBeInsert);
            if(campaignMemberToBeInsert.size() > 0)
                insert campaignMemberToBeInsert;    
        }
   	}
}