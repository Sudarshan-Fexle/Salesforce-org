global class Batch_SiteContentRecommendations implements Database.Batchable<SObject> {
    
    public String queryString = '';
    public String scrSelection = '' ;
    public String objectName = '';
    public Set<Id> setOfAccIds = new Set<Id>();
    public Set<Id> setOfContIds = new Set<Id>();
    global String debugLog;
    
    global Batch_SiteContentRecommendations(Set<Id> setOfAccountIds, Set<Id> setOfContactIds, String selectedScr){
        setOfAccIds = setOfAccountIds;
        setOfContIds = setOfContactIds;
        
        if(setOfAccIds != null){
            queryString = 'Select Id From Account WHERE Id IN: setOfAccIds';
            objectName = 'Account';
        }
        else if(setOfContIds != null){
            queryString = 'Select Id,EAB_com_Site_Profile__c From Contact WHERE Id IN: setOfContIds'; 
            objectName = 'Contact';
        }
        
        scrSelection = selectedScr;
    }
    public List<SObject> start(Database.BatchableContext bi){
        debugLog = '';
        return database.query(queryString); 
    }
    
    public void execute(Database.BatchableContext bi, List<Sobject> sobjectList){
        
        List<LookupSearchResult> listofLookUpResults = new List<LookupSearchResult>();
        
        LightningResponseEntity reponseHandler = new LightningResponseEntity();
        
        for(Sobject obj : sobjectList){
            
            if(String.isNotBlank(objectName) && objectName == 'Account'){
                
                LookupSearchResult searchResult = new LookupSearchResult((Id)obj.get('Id'), 'Account', '','','', false, '');
                listofLookUpResults.add(searchResult);
                
            } 
            else if(String.isNotBlank(objectName) && objectName == 'Contact'){
                LookupSearchResult searchResult = new LookupSearchResult((Id)obj.get('EAB_com_Site_Profile__c') , 'Site_Profile__c', '','','', false, '');
                listofLookUpResults.add(searchResult);   
            }
        }
        
        
        if(listofLookUpResults.size() > 0 ) {
            String result = JSON.serialize(listofLookUpResults);
            try{
                if(String.isNotBlank(objectName) && objectName == 'Account'){
                    system.debug('objectName--'+ objectName);
                    siteContentRecommendationsHelper.createSiteContentRecommendationsForMultipleAccounts(result, scrSelection);    
                }
                else if(String.isNotBlank(objectName) && objectName == 'Contact'){
                    siteContentRecommendationsHelper.createSiteContentRecommendationForMultipleSiteProfiles(scrSelection, result);
                }
                
            }
            catch(Exception e){
                debugLog += e.getMessage();
            }  
        }
        
        
    }
    
    public void finish(Database.BatchableContext bi){  
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLog != '') 
            Util.sendBatchStatus(bi.getJobId(), 'Batch_SiteContentRecommendations', debugLog, Label.Salesforce_Admin_Email);
    }
}