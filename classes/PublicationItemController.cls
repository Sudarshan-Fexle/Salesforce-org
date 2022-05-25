/**
    Purpose:    		Controller class for the PublicationItem VF page.
                
    Create By:  		Victor Hanson
    
    Created Date:   	07/02/2014
    
    Current Version:    v1.0
    
    Revision Log:       
 **/
public without sharing class PublicationItemController {
	
    //variables
    public string searchString { get; set; }
    public string campaignId { get; set; }
    
    //constructor
    public PublicationItemController() {
        
        //get the campaign id
        campaignId = ApexPages.currentPage().getParameters().get('cid');
        
        //display an errror if there is no campaign Id
        if (campaignId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Campaign Id'));
        }
    }
    
    /**
     * @description: Search all publications for the search string where Publication Date >= last 6 months.
     * 
     **/
    public void search() {
        
        //clear any existing search results
        publicationMap.clear();
        
        searchString = ApexPages.currentPage().getParameters().get('searchString');
        
        system.debug('@@searchString:' + searchString);
        
        //if searchString is null or the user hasn't entered enough info, return immediately
        if (searchString != null && searchString.replace('*','').length() >= 2) {
            
            if (searchString != null) searchString = string.escapeSingleQuotes(searchString);
            
            String searchquery = 'FIND\'' + searchString + '*\'IN ALL FIELDS RETURNING ' +
            					 'Publication__c(Id,DERF__c,Stock_Num__c,Title__c WHERE Publication_Date__c >= LAST_N_MONTHS:6)'; 
            List<List<SObject>> sResultList = search.query(searchquery);
            
            if(sResultList[0] != null && sResultList[0].size() > 0){
                
                //add results to the map of publications
                publicationMap = new map<Id, Publication__c>((list<Publication__c>)sResultList[0]);
                
            }
        }
    }
    
    /**
     * @description:	save items in the publicationItemsToInsert list and delete items that have been de-selected.
     *
    **/
    public void save() {
        
        list<Publication_Item__c> publicationItemsToInsert = new list<Publication_Item__c>();
        list<Publication_Item__c> publicationItemsToDelete = new list<Publication_Item__c>();
        
        //add all selected items that are not already existing publication items
        for (Publication__c p : selectedPublicationMap.values()) {
            
            if (!existingPubIdToPubItemMap.containsKey(p.Id)) {
                
                publicationItemsToInsert.add(new Publication_Item__c(Publication__c = p.Id,
                                                                Campaign__c = campaign.Id));
            }
        }
        
        //check each existing pub item to see if it was de-selected.  If so, add to deletion list
        for (string pId : existingPubIdToPubItemMap.keySet()) {
            
            if (!selectedPublicationMap.containsKey(pId)) {
                publicationItemsToDelete.add(existingPubIdToPubItemMap.get(pId));
            }
        }
        
        try {
            
            if (publicationItemsToInsert.size() > 0)
                insert publicationItemsToInsert;
            
            if (publicationItemsToDelete.size() > 0)
                delete publicationItemsToDelete;
        }
        catch(DMLException ex) {
            //Return errors to the VF Page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDMLMessage(0)));
        }
        catch(Exception ex) {
            //Return errors to the VF Page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }
    
    /**
     * @description: add a publication record to our map & list of selected publications
     * 
     **/
    public pageReference addItem() {
        
        string pId = Apexpages.currentPage().getParameters().get('selectedPublicationId');  
        
        //add the selected publication to the map
        selectedPublicationMap.put(pId, publicationMap.get(pId));
        
        return null;
    }
    
    /**
     * @description: remove a publication record from the Selected Publication Map
     * 
     **/
    public pageReference removeItem() {
        
        string pId = Apexpages.currentPage().getParameters().get('selectedPublicationId');  
        
        //remove the item from the selectedPublicationMap
        selectedPublicationMap.remove(pId);
        
        return null;
    }
    
    //map of selected publications
    private map<Id, Publication__c> selectedPublicationMap {
        get {
            if (selectedPublicationMap == null) {
                selectedPublicationMap = new map<Id, Publication__c>();
                //add all existing publication items to the selected publication map
                for (String pubId : existingPubIdToPubItemMap.keySet()) {
                    selectedPublicationMap.put(pubId, new Publication__c(Id=pubId));
                }
            }
            return selectedPublicationMap;
        }
        set;
    }
    
    //list of selected publications
    public list<SelectableSObject> selectedPublications {
        get {
            selectedPublications = new list<SelectableSObject>();
            for (Publication__c p : selectedPublicationMap.values()) selectedPublications.add(new SelectableSObject(p, true));
            return selectedPublications;
        }
        set;
    }
    
    //
    private map<Id, Publication__c> publicationMap {
        get {
            if (publicationMap == null) publicationMap = new map<Id, Publication__c>();
            return publicationMap;
        }
        set;
    }
    
    //list of publications that will display on the page
    public list<SelectableSObject> publications {
        get {
            
            publications = new list<SelectableSObject>();
            //add results to the list of selectableSObjects
            for (Publication__c p : publicationMap.values()) {
                
                // Put the Publication into a SelectableSObject
                publications.add(new SelectableSObject(p, selectedPublicationMap.containsKey(p.Id)));
            }
            return publications;
        }
        set;
    }
    
    //get the related campaign
    public Campaign campaign {
        get {
            if (campaign == null) {
                campaign = new Campaign();
                if (campaignId != null) campaign = [SELECT Id, Name FROM Campaign WHERE Id = :campaignId];
            }
            return campaign;
        }
        set;
    }
    
    //gets a map of all existing publication items
    private map<Id, Publication_Item__c> existingPubIdToPubItemMap {
        get {
            if (existingPubIdToPubItemMap == null) {
                existingPubIdToPubItemMap = new map<Id, Publication_Item__c>();
                
                //get all existing publication items and add to our map
                for (Publication_Item__c pi : [SELECT Id, Publication__c FROM Publication_Item__c WHERE Campaign__c = :campaign.Id]) {
                    
                    existingPubIdToPubItemMap.put(pi.Publication__c, pi);
                    
                }
            }
            return existingPubIdToPubItemMap;
        }
        set;
    }
    
}