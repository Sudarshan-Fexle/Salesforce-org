/**
 *  Purpose         :   This class is to hold all the helper method for Intranet Container trigger.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   08/04/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/ 
public without sharing class IntranetContainerTriggerHelper {
    
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
    public static void validateDate(List<Intranet_Container__c> intranetContainers, Map<Id, Intranet_Container__c> mapOldIntranetContainers) {
        
        //Set to hold the parent records ids
        Set<Id> setParentContainers = new Set<Id>();
        
        //Map Record Types
        Map<Id, RecordType> mapRecordType = new Map<Id, RecordType>([Select Id, Name from recordType where SObjectType = 'Intranet_Container__c' AND IsActive = true]);
        
        //mapContentItems
        Map<Id, Intranet_Item__c> mapContentItems = new Map<Id, Intranet_Item__c>();
        
        //Check if Parent Contaciner and Get the value if Parent already populated
        for(Intranet_Container__c iC : intranetContainers) {
            
            //Check for the parent container
            if(iC.Parent_Container__c != null) {
                
                //Add in set
                setParentContainers.add(iC.Parent_Container__c);
            }
            
            //INSERT: Check for the default content
            if(mapOldIntranetContainers == null && iC.Default_Content_Item__c != null) {
                
                mapContentItems.put(iC.Default_Content_Item__c, new Intranet_Item__c(Id = iC.Default_Content_Item__c, Default_Content_Flag__c = true));
            }
            
            //UPDATE: Check for the default content
            else if(mapOldIntranetContainers != null && iC.Default_Content_Item__c != mapOldIntranetContainers.get(iC.Id).Default_Content_Item__c) {
                
                //Check if content has been removed from New instance
                if(mapOldIntranetContainers.get(iC.Id).Default_Content_Item__c != null)
                    mapContentItems.put(mapOldIntranetContainers.get(iC.Id).Default_Content_Item__c, new Intranet_Item__c(Id = mapOldIntranetContainers.get(iC.Id).Default_Content_Item__c, Default_Content_Flag__c = false));
                
                //Check if content has been removed from New instance
                if(iC.Default_Content_Item__c != null)
                    mapContentItems.put(iC.Default_Content_Item__c, new Intranet_Item__c(Id = iC.Default_Content_Item__c, Default_Content_Flag__c = true));
            }
        }
        
        //Fetch records
        Map<Id, Intranet_Container__c> mapIntranetContainers = new Map<Id, Intranet_Container__c>([Select Id, Display_Name__c from Intranet_Container__c where Id IN: setParentContainers]);
    
        //Loop throgh the records and Set the name
        for(Intranet_Container__c iC : intranetContainers) {
            
            //Check for the parent container
            if(iC.Parent_Container__c != null && mapIntranetContainers.containsKey(iC.Parent_Container__c)) {
                
                //Set the Parent's Name
                iC.Name = mapRecordType.get(iC.RecordTypeId).Name + '-' + mapIntranetContainers.get(iC.Parent_Container__c).Display_Name__c + '-' + iC.Display_Name__c;
            } else {
                
                //Set the Primary Name
                iC.Name = mapRecordType.get(iC.RecordTypeId).Name + '-Primary-' + iC.Display_Name__c;
            }
            
            //Truncate to 80 CHaracters
            iC.Name = iC.Name.length() > 80 ? iC.Name.left(80) : iC.Name;
        }
        
        //Update mapContentItems
        if(mapContentItems.size() > 0)
            update mapContentItems.values();
    }
    
    /**
     *  @description    :   This method is being called on before events. It populates the field Content_Types_Allowed_Text__c with the picklist 
     * 						selections from Content_Types_Allowed.  This is used by Intranet_Schedule to limit items by Content Type
     * 
     *  @args           :   list of new or updated records
     * 
     *  @return         :   none
     * 
     **/
    public static void UpdateContentTypesAllowed(List<Intranet_Container__c> ics){
        //loop through and set field for records
        for(Intranet_Container__c ic : ics){
            string types = ic.Content_Types_Allowed__c;
            if(types != null){
                types = types.left(250);
            }
            ic.Content_Types_Allowed_Text__c = types;
        }
    }
    
    /** 
     * 	@description	:	This method is to check if the Update Now checkbox is true, then call the method to update the Trending Data
     * 
     * 	@args			:	List of Intranet Content
     * 
     * 	@return			:	void
     * 
     **/
    public static void updateTrendingData(List<Intranet_Container__c> newListIntranetContainer, Map<Id, Intranet_Container__c> oldMapIntranetContainer) {
    	
    	//Chekc for the Trending  Source
    	for(Intranet_Container__c intranetContainer : newListIntranetContainer) {
    		
    		//Check if teh flag is true and it was false previously
    		if(intranetContainer.Update_Now__c == true 
    			&& intranetContainer.Content_Types_Allowed__c != null
    			&& oldMapIntranetContainer.get(intranetContainer.Id).Update_Now__c != true) {
				
				//Get Trending Source Name
				if(intranetContainer.Content_Types_Allowed__c.containsIgnoreCase(TrendingArticleConstants.TRENDING_ADVISORY_DOT_COM))
					TrendingArticle.CreateIntranetItemsAndScheduleByTrendSource(TrendingArticleConstants.TRENDING_ADVISORY_DOT_COM);
				else if(intranetContainer.Content_Types_Allowed__c.containsIgnoreCase(TrendingArticleConstants.TRENDING_EAB_DOT_COM))
					TrendingArticle.CreateIntranetItemsAndScheduleByTrendSource(TrendingArticleConstants.TRENDING_EAB_DOT_COM);
    		
        		//Update the Last Content Update  Field
        		intranetContainer = IntranetContainerTriggerHelper.updateFieldValue(intranetContainer, 'Last_Content_Update__c', DateTime.now());
                intranetContainer = IntranetContainerTriggerHelper.updateFieldValue(intranetContainer, 'Update_Now__c', FALSE);
			}
    	}
    }
    
    /** 
     * 	@description	:	This method is to update the given field's value on IntranetContainer
     * 
     * 	@args			:	List of Intranet Contenters, Field name, field value
     * 
     * 	@return			:	void
     * 
     **/
    public static Intranet_Container__c updateFieldValue(Intranet_Container__c intranetContainer, String fieldName, Object fieldValue) {
    	
    	//Checkfor the size
    	if(intranetContainer != null && fieldName != null && fieldValue != null) {
    	
	    	//This method is to update the specific field's value on intranetContainers
	    	intranetContainer.put(fieldName, fieldValue);
	    }
        
        //update intranetContainers
	    return intranetContainer;
   	}
}