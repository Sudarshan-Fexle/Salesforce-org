/**
    Desription      :   Helper class for Site Content Recommendation functionality
  
    Revision Logs   :   v1.0 - 05/17/2019 - Created - Colin McGloin - CR-20190510-13102
                        v1.1 - 07/01/2019 - Modified - Victor Hanson - updated buildWordpressHTTPCallout
                        v1.2 - 08/22/2019 - Modified - Victor Hanson - CR-20190823-13279 - commented out getPermissionToAccess
**/ 
public with sharing class siteContentRecommendationsHelper {

    public Site_Profile__c siteProfile {get; set;}
    public static Id currentRecordId;
    
    //max search results returned on the 'Step 2' page where user selects Contacts or Institutions
    public static final Integer SEARCH_RESULTS_LIMIT = 75;

    public siteContentRecommendationsHelper () {

        //Run our Initial Queries
        inIt ();
        
    }

    public void inIt () {

        //Grab our ID from the Redirect
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');

        //Query for the Site Profile Fields we need for the page
        if (currentRecordId != null) {
            siteProfile = [SELECT Id, Contact__c, Contact__r.Name, Contact__r.Account.Name
                            FROM Site_Profile__c
                            WHERE Id = :currentRecordId];
                            }
       
    }
    
    
    @AuraEnabled (cacheable=true)
    //Method that bring the details for the WP callout that will be used in the java Script. 
    public static wpCallOutDetails bringWPCalloutDetails() {

        wpCallOutDetails wPDetails = new wpCallOutDetails();
        //Query on the custom Metadata
        for(API_Endpoints__mdt apiEndpointDetails : [Select Id, Authorization_Token__c, Endpoint_URL__c From API_Endpoints__mdt Where DeveloperName = 'EAB_WP' LIMIT 1]) {

            //Adding the values in the instance.
            wPDetails.endPoint = apiEndpointDetails.Endpoint_URL__c;
            wPDetails.authrizationToken = apiEndpointDetails.Authorization_Token__c;
        }

        return wPDetails;
    }

    /**
     *  @description    : build http reqeust for wordpress callouts.  includes reference to named credential
     * 
     *  @Revision Log   :  V1.0 - Created By - Victor Hanson - CR-20190510-13101 - 06/17/2019.
     **/
    public static HttpRequest buildWordpressHTTPCallout(String method, String endpoint){

        //get the callout details
        wpCallOutDetails eab_wp = bringWPCalloutDetails();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(eab_wp.endPoint + endpoint);
        req.setMethod(method);
        req.setHeader('Authorization', 'Basic ' + eab_wp.authrizationToken);
        req.setHeader('Content-Type', 'application/json');

        // non-standard authentication
        /*req.setHeader('X-Username', '{!$Credential.UserName}');
        req.setHeader('X-Password', '{!$Credential.Password}');*/

        return req;
        
    }

    @AuraEnabled (cacheable=true)
    public static SiteProfileWrapper getSiteProfileInfo(String siteProfileId ){

        //Site Profile Wrapper Initialize.
        SiteProfileWrapper siteProfileWrapper = new SiteProfileWrapper();

        //For Loop query on the site profile Object to get the site profile information. 
        for(Site_Profile__c sP : [SELECT Id, Name, Contact__c, Contact__r.Name, Contact__r.Account.Name
                            FROM Site_Profile__c
                            WHERE Id = :siteProfileId]) {
            
            //Filling the property for the siteProfile Object.
            siteProfileWrapper.siteProfileName = sP.Contact__r.Name;
            siteProfileWrapper.accountFormalName = sP.Contact__r.Account.Name;
            siteProfileWrapper.siteProfileContactName = sP.Contact__c;
            siteProfileWrapper.siteProfileId = sP.Id;
        }
        return siteProfileWrapper;
    }

    @AuraEnabled (cacheable=true)
    public static Account getOriginalAccountInfo(String accId) {

        //Check for the Id. 
        if(String.isNotBlank(accId)) {
            
            //Query on the account. 
            Account acc = [Select Id, Name, Account_Formal_Name__c From Account Where Id =: accId];

            //Return the account. 
            return acc; 
        }

        return null;

    }



    @AuraEnabled (cacheable=true)
    public static boolean getIsUserInClassic(){

        //Run class to see if the user is in Classic or Lightning
        String themeDisplayed = UserInfo.getUiThemeDisplayed();

        //Boolean for Classic
        boolean displayClassic = false;

        //Populate checkbox for handiness
        if (themeDisplayed == 'Theme3'){
            displayClassic = true;
        }

        return displayClassic;                                  

    }

    /* v1.2 - 08/22/2019 - Victor Hanson - CR-20190823-13279 - commented out
    @AuraEnabled (cacheable=true)
    public static boolean getPermissionToAccess(){

        //Run helper class to see if the user has the Access to the Permission
        CustomPermissionsReader cpr = new CustomPermissionsReader();
        Boolean scrUserAccess = cpr.hasPermission('Site_Content_Recommendations_Access');

        //Return our access
        return scrUserAccess;                                          

    }*/

    @AuraEnabled (cacheable=true)
    public static String getInstitutionWebPrograms (String siteProfileId) {
		
        String webAccess = '';
            
        //Set for storing our Program
        Set<Id> programIds = new Set<Id>();

        //String for storing our Web Program Access Ids in
        List<String> siteProgramIDs = new List<String>();

        List<Site_Profile__c> siteProfiles = [Select Id, Contact__c, Contact__r.AccountId 
                                            From Site_Profile__c Where Id =: siteProfileId];

        if(siteProfiles!= null && String.isNotBlank(siteProfiles[0].Contact__r.AccountId))
        	webAccess = getProgramAccess(siteProfiles[0].Contact__r.AccountId);
		
        return webAccess;
    }
    
    @AuraEnabled (cacheable=true)
    public static String getProgramAccess(String institutionId) {
        
        //Set for storing our Program
        Set<Id> programIds = new Set<Id>();
        
        //String for storing our Web Program Access Ids in
        List<String> siteProgramIDs = new List<String>();
        
       //Query for all Memberships which are related to Institution and Member Status is Paid
        List <Membership__c> paidMemberships = [SELECT Id, Name, Program__c, Account_Name__c
                                                FROM Membership__c
                                                WHERE
                                                // Member__c = TRUE
                                                //AND 
                                                Account_Name__c = : institutionId];
        
        //if we have records
        if (paidMemberships.size() > 0){
            
            //Loop through our Memberships and grab our Program
            for (Membership__c mem : paidMemberships){
                if(mem.Program__c != null){
                    programIds.add(mem.Program__c);
                }
            }
            
            //If we have Program IDs then proceed with our Query
            if (programIds.size() > 0){
                
                //Query for our Programs and Web Program Access MTM records
                List<Program__c> progs = [SELECT Id, Name,
                                          (SELECT Id, Adv_com_Program_ID__c FROM Web_Program_Access_MTM__r)
                                          FROM Program__c
                                          WHERE Id IN :programIds];
                
                //Loop through our Prorgrams and the 
                for (Program__c prog : progs){
                    
                    //Populate our Web Program Access List
                    List<Web_Program_Access_MTM__c> webProgramAccessRecords = prog.Web_Program_Access_MTM__r;
                    
                    //Proceed if we have records
                    if(webProgramAccessRecords != null && webProgramAccessRecords.size() > 0){
                        
                        //Loop through records
                        for (Web_Program_Access_MTM__c webProgAccessMtM : webProgramAccessRecords){
                            if(webProgAccessMtM.Adv_com_Program_ID__c != null){
                                siteProgramIDs.add(String.valueof(webProgAccessMtM.Adv_com_Program_ID__c));
                            }
                        }
                    }
                }
            }
        }
            
        
        
        //String for holding our return value
        String webprogAccessIdsString = '';
        
        //Convert our List to a String value
        if(siteProgramIDs.size() > 0){
            webprogAccessIdsString = String.join(siteProgramIDs,',');
        }
        
        System.debug('###: ' + webprogAccessIdsString);
        
        return webprogAccessIdsString;
    }

    @AuraEnabled (cacheable=true)
    public static List<siteContentWrapper> getRelatedSiteContentRecords(String siteProfileId) {
        
        //List to hold the Site Content recommendation records. 
        List<SiteContentWrapper> siteContentRecommendations = new List<SiteContentWrapper>();
        
        System.debug('currentRecordId----'+siteProfileId);

        //For loop on the Site Content Recommendation.
        for(Site_Content_Recommendation__c sCR : [Select Id, Site_Content__c, Site_Content__r.GUID__c, Site_Content__r.Title__c, 
                                     Site_Content__r.URL__c From Site_Content_Recommendation__c 
                                     Where Site_Profile__c =: siteProfileId]) {
            
            //Add the Site Content details to the List.
            siteContentRecommendations.add(new SiteContentWrapper(sCR.Id, sCR.Site_Content__r.GUID__c, 
                                                                  sCR.Site_Content__r.Title__c,
                                                                  sCR.Site_Content__r.URL__c));

           
        }
		return siteContentRecommendations;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchDataForLookUp(String searchTerm, List<String> selectedIds, String objName, String selectedSiteContent) {
        
        set<String> setWebProgramIds = new Set<String>();
        searchTerm = '%'+searchTerm+'%';
    
        //List to hold the Lookup search results.
        List<LookupSearchResult> filteredData = new List<LookupSearchResult>();

        //Parse the JSON formatted Data, data is having the same format like "SiteContentWrapper" class. 
        List<SiteContentWrapper> siteContentDataFromPage = (List<SiteContentWrapper>) JSON.deserialize(selectedSiteContent , List<SiteContentWrapper>.class);
        
        //This is for the Object Specific Check. - Contact Object. 
        if(objName.equalsIgnoreCase('Contact') || objName.equalsIgnoreCase('"Contact"')) {

            //VH 06/28/2019: removed "AND Account.Web_Program_Access__c != null" from the query below, because we should allow guest users to see recommendations too
            //Query on the Contact where EAB Site profiles are not null and Site profiles are not inactive as well as the institution is in setAccountIds.
            for(Contact con : [Select Id, Account.Account_Formal_Name__c, Name, Account.Web_Program_Access__c, EAB_com_Site_Profile__r.Tokens_Available__c,
                              EAB_com_Site_Profile__c From Contact Where EAB_com_Site_Profile__c != null 
                              AND EAB_com_Site_Profile__r.Status__c != 'Inactive' AND 
                              Name LIKE: searchTerm AND EAB_com_Site_Profile__c NOT IN: selectedIds LIMIT :SEARCH_RESULTS_LIMIT]) {
                
                //Check for the validity of Site content over Institution.
                if(checkValidityOfContentsOnInstitution(siteContentDataFromPage, con.Account.Web_Program_Access__c))
                    filteredData.add(new LookupSearchResult(con.EAB_com_Site_Profile__c, 'Contact', 'standard:contact', con.Name, con.Account.Account_Formal_Name__c, false, '' ));
            
                else if(con.EAB_com_Site_Profile__r.Tokens_Available__c == 0 )
                     filteredData.add(new LookupSearchResult(con.EAB_com_Site_Profile__c, 'Contact', 'standard:contact', con.Name, con.Account.Account_Formal_Name__c , true, '    *No tokens available' ));
                else
                    filteredData.add(new LookupSearchResult(con.EAB_com_Site_Profile__c, 'Contact', 'standard:contact', con.Name, con.Account.Account_Formal_Name__c, false, '    *Freemium token required'));
            }
        }
        

        //Check for the Account Object. 
        if(objName.equalsIgnoreCase('Account') || objName.equalsIgnoreCase('"Account"')) {

            //Check for the Account. 
            for(Account acc : [Select Id, Name, Account_Formal_Name__c, Web_Program_Access__c, Tokens_Available__c
                                From Account Where Name LIKE: searchTerm AND ID NOT IN: selectedIds LIMIT :SEARCH_RESULTS_LIMIT]) {

                //Check for the validity of Site content over Institution.
                if(checkValidityOfContentsOnInstitution(siteContentDataFromPage, acc.Web_Program_Access__c))
                    filteredData.add(new LookupSearchResult(acc.Id, 'Account', 'standard:account', acc.Name, acc.Account_Formal_Name__c, false, '' ));
                
                else if(acc.Tokens_Available__c == 0)
                    filteredData.add(new LookupSearchResult(acc.Id, 'Account', 'standard:account', acc.Name, acc.Account_Formal_Name__c , true, '    *No tokens available'  ));
                else 
                    filteredData.add(new LookupSearchResult(acc.Id, 'Account', 'standard:account', acc.Name, acc.Account_Formal_Name__c, false, '    *Freemium token required' ));
               
            }
        }
        system.debug('filteredData====='+filteredData);

        return filteredData;
    }

    public static Boolean checkValidityOfContentsOnInstitution(List<SiteContentWrapper> siteContentDataFromPage, String webProgramAccess ) {

        Boolean isValidContact = false; 

        //Set to hold the Id. 
        Set<String> setEabWebProgramAccess = new Set<String>();

        //Check for the blank condition.
        if(String.isNotBlank(webProgramAccess)) {
            
            //Check for the web program Access values.
            if(webProgramAccess.contains(','))
                setEabWebProgramAccess.addAll(webProgramAccess.split(','));
            else
                setEabWebProgramAccess.add(webProgramAccess); 
        }

        if(setEabWebProgramAccess.size() > 0) {

            //For loop on the site Content Wrapper. 
            for(SiteContentWrapper sCW : siteContentDataFromPage) {
                
                //Check for the site content wrapper. 
                if(sCW.webProgramAccessIds != null && sCW.webProgramAccessIds.size() > 0){
                    
                    //Check for the set contains All. (If atleast one condition meets, set the boolean true and break the loop)
                    if(sCW.webProgramAccessIds.containsAll(setEabWebProgramAccess) || setEabWebProgramAccess.containsAll(sCW.webProgramAccessIds))
                        isValidContact = true;
                        break;
                } 
            }
        }   

        return isValidContact;
    }


    @AuraEnabled
    public static void createSiteContentRecommendationForMultipleSiteProfiles(String jsonFormattedData, String siteProfileDetails) {

       
        //Parse the JSON formatted Data, data is having the same format like "SiteContentWrapper" class. 
         List<SiteContentWrapper> siteContentDataFromPage = (List<SiteContentWrapper>) JSON.deserialize(jsonFormattedData , List<SiteContentWrapper>.class);

        //Parse the JSON formatted Data, data is having the same format like "LookupSearchResult" class. 
        List<LookupSearchResult> siteProfilesFromPage = (List<LookupSearchResult>) Json.deserialize(siteProfileDetails,  List<LookupSearchResult>.class);

        //Set to hold the existing guids.
        Set<String> setExistingGuids = new Set<String>();

        //Set to hold the Ids of Site profile. 
        Set<Id> setSiteProfileIds = new Set<Id>();

        //Map to hold the Id with the Site Content. 
        Map<String, Site_Content__c> mapIdWithSiteContent = new Map<String, Site_Content__c>();
        
        //List to hold the site content records. 
        List<Site_Content__c> siteContentToBeCreated = new List<Site_Content__c>();

        //List to hold the site content Recommendation that is going to be inserted in the data base for the selected Site Profiles/Contact.
        List<Site_Content_Recommendation__c> siteContentRecommendationsToBeInserted = new List<Site_Content_Recommendation__c>();

        /*Getting All site content Recommendation 
        records which is coming from the Page and check the data base if we have the same GUID Content exist previously */
        for(SiteContentWrapper sCWrapper : siteContentDataFromPage) {
            mapIdWithSiteContent.put(sCWrapper.guid, new Site_Content__c());
        }

        //Loop on the site content.
        for(Site_Content__c siteContent : [Select Id, GUID__c From Site_Content__c where GUID__c IN: mapIdWithSiteContent.keySet()]) {
            mapIdWithSiteContent.put(siteContent.GUID__c, siteContent);
            setExistingGuids.add(siteContent.GUID__c);
        }
      
         //Loop on the site Content Records. 
         for(SiteContentWrapper sCWrapper : siteContentDataFromPage) {

             //Check for the siteContentId - if the siteContentId is populated that means that is existing record and if not populated that means these are the records we need to update those. 
             if(!setExistingGuids.contains(sCWrapper.guid)) {
                //Add the data to the List. 
                siteContentToBeCreated.add(new Site_Content__c(GUID__c = sCWrapper.guid, Title__c = sCWrapper.title, 
                                                                URL__c = sCWrapper.url));
             
             }
         }

         //Check for the Size of non existing site content list. 
         if(siteContentToBeCreated.size() > 0) {
             insert siteContentToBeCreated;

             for(Site_Content__c sC : siteContentToBeCreated)
                mapIdWithSiteContent.put(sC.GUID__c, sC);
         }

         //Getting the results from the site profiles. Those were selected from the page. 
        for(LookupSearchResult lSR : siteProfilesFromPage) {
            setSiteProfileIds.add(lSR.id);
        }

        //Query the site Profiles that selected by User. 
        for(Site_Profile__c sP : [Select Id, Contact__c, (Select Id, Site_Content__r.GUID__c 
                                 From Site_Content_Recommendations__r) From Site_Profile__c where Id IN: setSiteProfileIds]) {
            
            //Set to hold the exising GUIDs
            Set<String> setExistingGuidsForSiteProfile = new Set<String>();

           //Check for the Site profile child records.
            if(sP.Site_Content_Recommendations__r != null && sP.Site_Content_Recommendations__r.size() > 0) {

                //Loop on the Site Content Recommendations.
                for(Site_Content_Recommendation__c sCR : sP.Site_Content_Recommendations__r)
                    setExistingGuidsForSiteProfile.add(sCR.Site_Content__r.GUID__c);

            }

            for(String selectedSiteContentGUID : mapIdWithSiteContent.keyset()) {

                //Check if the guid is exist for site profile- Means any existing site content recommendation is existed on this site profile in the system for this GUId 
                if(mapIdWithSiteContent.containsKey(selectedSiteContentGUID) && 
                    !setExistingGuidsForSiteProfile.contains(selectedSiteContentGUID)) {
                    
                    siteContentRecommendationsToBeInserted.add(new Site_Content_Recommendation__c(
                            Site_Content__c = mapIdWithSiteContent.get(selectedSiteContentGUID).Id,
                            Site_Profile__c = sP.Id,
                            Contact__c = sP.Contact__c));   
                }
            }
        }

        //Check the size of list. 
        if(siteContentRecommendationsToBeInserted != null && siteContentRecommendationsToBeInserted.size() > 0)
            insert siteContentRecommendationsToBeInserted;

    }
    
    @AuraEnabled
    public Static void createSiteContentRecommendationsForMultipleAccounts(String selectedAccs, String selectedContents) {

        System.debug('selectedAccounts?? -- '+selectedAccs);
        System.debug('selectedContents?? -- '+selectedContents);
        
        //Parse the JSON formatted Data, data is having the same format like "LookupSearchResult" class. 
        List<LookupSearchResult> selectedAccountDetails = (List<LookupSearchResult>) Json.deserialize(selectedAccs,  List<LookupSearchResult>.class);
		
        //Parse the JSON formatted Data, data is having the same format like "SiteContentWrapper" class. 
        List<SiteContentWrapper> selectedSiteContents = (List<SiteContentWrapper>) JSON.deserialize(selectedContents , List<SiteContentWrapper>.class);
		
		System.debug('selectedAccountDetails?? -- '+selectedAccountDetails);
        System.debug('selectedSiteContents?? -- '+selectedSiteContents);
        
        //Set to hold the Ids of Accounts. 
        Set<Id> setAccountIds = new Set<Id>();
        
        //Map to hold the Site Profile with the Contact. 
        Map<Id, Id> mapSiteProfileWithContact = new Map<Id, Id>();
        
        //Map to hold the account Id and List of web Program Ids. 
        Map<Id, List<String>> mapAccWithWebAccessCode = new Map<Id, List<String>>();
        
        //Map to hold the siteContents.
        Map<String, Site_Content__c> mapIdWithSiteContent = new Map<String, Site_Content__c>();
        
        //Set to hold the ids
        Set<String> setExistingGuids = new Set<String>();
        
        //Map to hold the Site profile with Site Content Recommendation. 
        Map<Id, Map<Id, Set<String>>> mapOfSiteContentRecWithSiteProfilesWithAcc = new Map<Id, Map<Id, Set<String>>>();
        
        //List to hold the site content records. 
        List<Site_Content__c> siteContentToBeCreated = new List<Site_Content__c>();
        
        //List to hold the site content Recommendation records. 
        List<Site_Content_Recommendation__c> siteContentRecommendationsToBeCreated = new List<Site_Content_Recommendation__c>();

        //Loop on the Account details and fill the account set. 
        for(LookupSearchResult lSR: selectedAccountDetails)
        	setAccountIds.add(lSR.id);
         
        /*Query for the Account and access the webProgramAccess code*/
        for(Account selectedAccountsDetails : [Select Id, Web_Program_Access__c From Account where ID IN: setAccountIds]) {
    		
            //List to hold the String.
            List<String> allWebAccess = new List<String>();
            
            if(String.isNotBlank(selectedAccountsDetails.Web_Program_Access__c))
                
                //Adding the value conditionally.
                allWebAccess.addAll(selectedAccountsDetails.Web_Program_Access__c.contains(',') 
                                    								? selectedAccountsDetails.Web_Program_Access__c.split(',') 
                                    								: new List<String> {selectedAccountsDetails.Web_Program_Access__c});    
            
            //Map to hold the account id with the list of web Program ids. 
            mapAccWithWebAccessCode.put(selectedAccountsDetails.Id, allWebAccess);
        }
        
        System.debug('mapAccWithWebAccessCode------??'+mapAccWithWebAccessCode);
      	
       /*Getting All site content Recommendation 
        records which is coming from the Page and check the data base if we have the same GUID Content exist previously */
        for(SiteContentWrapper sCWrapper : selectedSiteContents) {
            mapIdWithSiteContent.put(sCWrapper.guid, new Site_Content__c());
        }

        //Loop on the site content.
        for(Site_Content__c siteContent : [Select Id, GUID__c From Site_Content__c where GUID__c IN: mapIdWithSiteContent.keySet()]) {
            mapIdWithSiteContent.put(siteContent.GUID__c, siteContent);
            setExistingGuids.add(siteContent.GUID__c);
        }
      
         //Loop on the site Content Records. 
         for(SiteContentWrapper sCWrapper : selectedSiteContents) {

             //Check for the siteContentId - if the siteContentId is populated that means that is existing record and if not populated that means these are the records we need to update those. 
             if(!setExistingGuids.contains(sCWrapper.guid)) {
                //Add the data to the List. 
                siteContentToBeCreated.add(new Site_Content__c(GUID__c = sCWrapper.guid, Title__c = sCWrapper.title, 
                                                                URL__c = sCWrapper.url));
             }
         }
        
        //Check for the site content. 
        if(siteContentToBeCreated.size() > 0) {
        	
            //Inserting the site content that is going to be inserted.
            insert siteContentToBeCreated;
            
            //Loop on the site content. 
            for(Site_Content__c sC : siteContentToBeCreated)
                mapIdWithSiteContent.put(sC.GUID__c, sC);
         }
         
	 // Modified By - Neha Sharma - CR-20200728-14372 - 22/10/2020
         for(Site_Profile__c sP: [Select Id, Contact__c, Contact__r.AccountId, (Select Id, Site_Content__c, Site_Content__r.GUID__c
                                      From Site_Content_Recommendations__r) From Site_Profile__c 
                                  Where Contact__r.AccountId IN: setAccountIds AND Type__c = 'EAB.com' AND Status__c != 'Inactive' AND Contact__r.Contact_Status__c = 'Active']) {                                    
                                                     
            //Map to hold the Site profile with the Contact details.                                          
            mapSiteProfileWithContact.put(sP.Id , sP.Contact__c);                                         
                                                     
        	//Check if map contains the account Id. 
            if(!mapOfSiteContentRecWithSiteProfilesWithAcc.containsKey(sP.Contact__r.AccountId)){
            	mapOfSiteContentRecWithSiteProfilesWithAcc.put(sP.Contact__r.AccountId, new Map<Id, Set<String>>());
            }
           
                                      
            if(!mapOfSiteContentRecWithSiteProfilesWithAcc.get(sP.Contact__r.AccountId).containsKey(sP.Id))
            	mapOfSiteContentRecWithSiteProfilesWithAcc.get(sP.Contact__r.AccountId).put(sP.Id, new Set<String>());  
                                      
            if(sP.Site_Content_Recommendations__r != null && sP.Site_Content_Recommendations__r.size() > 0) {
            	
                for(Site_Content_Recommendation__c sCR : sP.Site_Content_Recommendations__r)
                	mapOfSiteContentRecWithSiteProfilesWithAcc.get(sP.Contact__r.AccountId).get(sP.Id).add(sCR.Site_Content__r.GUID__c);
			}
        }
        System.debug('mapOfSiteContentRecWithSiteProfilesWithAcc==='+mapOfSiteContentRecWithSiteProfilesWithAcc);
        
        //Now Loop through the Institution. 
        for(Id accId : mapAccWithWebAccessCode.Keyset()) {
   			
            //Loop through the Selected Site Content.
            for(SiteContentWrapper sContent : selectedSiteContents) {
            	
                Boolean isValid = true;
                
				//Victor Hanson - 08/22/2019 - CR-20190823-13279 - commented out to allow us to add recommendations to accts even without active memberships
                //if(sContent.webProgramAccessIds != null && sContent.webProgramAccessIds.size() > 0){
                	//isValid = isValidContentForInstitution(mapAccWithWebAccessCode.get(accId), sContent.webProgramAccessIds );    
                //}
				
                System.debug('isvalid==='+isValid);
                
                //Check for the validness of the component. 
                if(isValid){
               		
                    //Map of site Content.
                    if(mapOfSiteContentRecWithSiteProfilesWithAcc.containsKey(accId)){
                        
                        //Loop on the site profiles.
                        for(Id siteProfileId : mapOfSiteContentRecWithSiteProfilesWithAcc.get(accId).Keyset()) {
                       		
                            //Check for the Site Profile's site recommendation exists or not. 
                            if(!mapOfSiteContentRecWithSiteProfilesWithAcc.get(accId).get(siteProfileId).contains(sContent.guid)) {
                            
                            	//Inserting a new records. 
                                siteContentRecommendationsToBeCreated.add(new Site_Content_Recommendation__c(
                                    Site_Content__c = mapIdWithSiteContent.get(sContent.guid).Id,
                                    Site_Profile__c = siteProfileId,
                                    Contact__c = mapSiteProfileWithContact.get(siteProfileId))); 
                            }
                        }
                    }
                }
            }
        }
        
        System.debug('siteContentRecommendationsToBeCreated----'+siteContentRecommendationsToBeCreated);
        
        //Check for the Size of list. 
        if(siteContentRecommendationsToBeCreated.size() > 0) {
            insert siteContentRecommendationsToBeCreated;
        }
   	}
    
    Public static Boolean isValidContentForInstitution(List<String> accountAccessCode, Set<String> siteContentAccessCode) {
        
        //Check for the null check
        if(accountAccessCode != null && accountAccessCode.size() > 0 
        	&& siteContentAccessCode != null && siteContentAccessCode.size() > 0) {
            
       		for(String contentCode : siteContentAccessCode) {
            	
            	if(accountAccessCode.contains(contentCode))
                    return  true;
           	}
        }
        
        return false;
    }

   public Class SiteContentWrapper {
        
        @AuraEnabled
        public String guid {get; set;}
        
        @AuraEnabled
        public String siteContentId {get; set;}
        
        @AuraEnabled
        public String title {get; set;}
        
        @AuraEnabled
        public String url {get; set;}

        @AuraEnabled
        public Set<String> webProgramAccessIds {get; set;}

        public siteContentWrapper(String siteContentId, String guid, String title, String url) {

            this.siteContentId = siteContentId;
            this.guid = guid;
            this.title = title;
            this.url = url;
        }
    }

    //Class that has the site profile properties.
    public Class SiteProfileWrapper {

        @AuraEnabled
        public String siteProfileName {get; set;}

        @AuraEnabled
        public String accountFormalName {get; set;}

        @AuraEnabled
        public String siteProfileContactName {get; set;}

        @AuraEnabled
        public String siteProfileId {get; set;}
    }

    public Class wpCallOutDetails {

         @AuraEnabled
         Public String endPoint{get; set;}

         @AuraEnabled
         Public String  authrizationToken{get; set;}
    }
    
    
}