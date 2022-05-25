/**
 *   Purpose:    Helper class for Site Content object
 *   
 *   Revision Log:      v1.00 - 07/28/2019 - CR-20190510-13101 - Victor Hanson - Created
 * 			v1.01 - Modified by Dipesh Gupta : 01/30/2020 - CR-20191011-13407 -- Added some checks for Menu Customization 
 * 			v1.02 - Modified by Chirag Soni - 04/14/2022 - CR-20220223-15939 - Updated null and Contains numeric check in updateSiteContentMtM method 
**/
public class SiteContentHelper {
	
    //unique content id
    String guid { get; set; }
    SiteUser sUser { get; set; }
    
    //site content record
    public Site_Content__c siteContent { get; set; }
    
    //Added by Dipesh Gupta : 01/30/2020 - CR-20191011-13407 - Start Here
    //Map of Guid's with Menu Customization
    public Map<String, SitePostWrapper> mapOfIdsWithMenuCustomization { get; set; } 
    public  Map<String, Site_Content__c> mapSiteContent			 { get; set; }
    //Added by Dipesh Gupta : 01/30/2020 - CR-20191011-13407 - Stop Here
    
    
    //private variables to track site content MtM
    private List<Site_Content_MtM__c> sContentMtMToInsert { get; set; }
    private List<Site_Content_MtM__c> sContentMtMToDelete { get; set; }
    private Map<String, Site_Content_MtM__c> mapExistingSiteContentMtM { get; set; }
    
    /**
     * @description: constructor
     * 
     * @revision log: v1.00 - 07/28/2019 - CR-20190510-13101 - Victor Hanson - Created
     * 
     **/
    public SiteContentHelper(SiteUser sUser, String GUID) {
        //set variables
        sContentMtMToInsert = new List<Site_Content_MtM__c>();
        sContentMtMToDelete = new List<Site_Content_MtM__c>();
        siteContent = new Site_Content__c();
        this.sUser = sUser;
        this.guid = guid;
       
        getSiteContent();
    }
    /**
     * @description: constructor
     * 
     * @revision log: v1.00 - Added by Dipesh Gupta : 01/30/2020 - CR-20191011-13407
     * 
     **/
   public SiteContentHelper(SiteUser sUser, Map<String ,SitePostWrapper> mapOfIdsWithMenuCustomization) {
        
        this.sUser = sUser;
        
        //Added by Dipesh Gupta : 01/30/2020 - CR-20191011-13407 - Start Here
        this.mapOfIdsWithMenuCustomization = mapOfIdsWithMenuCustomization;
        
        //Added by Dipesh Gupta : 01/30/2020 - CR-20191011-13407 - Stop Here
        getSiteContent();
    }
    
    /**
     * @description: get site content record 
     * 
     * @revision log: v1.00 - 07/28/2019 - CR-20190510-13101 - Victor Hanson - Created
     * 
     **/
    private Id getSiteContent() {
        
        //Added by Dipesh Gupta : 01/30/2020 - CR-20191011-13407 - Start Here
        //Meeting Customization check
        if(sUser != NUll && sUser.command != null && sUser.Command.equalsIgnoreCase('updateMenuCustomization')){
            
            //Initializing
            mapSiteContent = new Map<String, Site_Content__c>();
            
            //Query on the site Content
            for(Site_Content__c sContent : [Select Id, GUID__c, Web_Program_Access_Ids__c, Title__c, URL__c  
                                            From Site_Content__c Where GUID__c IN: mapOfIdsWithMenuCustomization.keySet()]) {
                
                mapSiteContent.put(sContent.GUID__c, sContent);
            }
            
            //check if the fields or web program access values have changed since last sync
            if(mapOfIdsWithMenuCustomization.size() > 0)
            {
                
                System.debug('mapOfIdsWithMenuCustomization===='+ mapOfIdsWithMenuCustomization);
                
                //If there is no Site Content Record is created then create one. 
                for(String id_x : mapOfIdsWithMenuCustomization.keySet())
                {	
                    System.debug('mapOfIdsWithMenuCustomization==='+mapOfIdsWithMenuCustomization.get(id_x));
                    
                    {
                        if(!mapSiteContent.containsKey(id_x)){ 
                            Site_Content__c siteContentToBeInsert = new Site_Content__c();
                            siteContentToBeInsert.Name = mapOfIdsWithMenuCustomization.get(id_x).post_title.abbreviate(80);
                            siteContentToBeInsert.GUID__c = id_x;
                            siteContentToBeInsert.Title__c = mapOfIdsWithMenuCustomization.get(id_x).post_title;
                            mapSiteContent.put(id_x, siteContentToBeInsert);
                        }
                        else{
                            mapSiteContent.get(id_x).Name = mapOfIdsWithMenuCustomization.get(id_x).post_title.abbreviate(80);
                            mapSiteContent.get(id_x).GUID__c = id_x;
                            mapSiteContent.get(id_x).Title__c = mapOfIdsWithMenuCustomization.get(id_x).post_title;
                        }     
                    }
                }
                if(mapSiteContent.size() > 0)
                {
                    upsert mapSiteContent.values();
                } 
            }
            
            System.debug('mapSiteContent ----' + mapSiteContent);
            
            if(mapSiteContent.size() > 0)
            {
                return mapSiteContent.values()[0].Id;
            }
            else
            {
                return null;    
            } 
        }
        //Added by Dipesh Gupta : 01/30/2020 - CR-20191011-13407 - Stop Here
        else{
            //Query on the site Content
            for(Site_Content__c sContent : [Select Id, GUID__c, Web_Program_Access_Ids__c From Site_Content__c Where GUID__c =: sUser.post.id_x]) {
                siteContent = sContent;
            }
            
            //check if the fields or web program access values have changed since last sync
            boolean upsertRequired = checkForUpsert();
            
            //If there is no Site Content Record is created then create one. 
            if(upsertRequired) {
                
                siteContent.Name = sUser.post.post_title.abbreviate(80);
                siteContent.GUID__c = sUser.post.id_x;
                siteContent.Title__c = sUser.post.post_title;  
                siteContent.URL__c = sUser.post.guid;
                //populate the web program access ids field as a comma-delimited value
                if (sUser.post.webProgramAccessIds != null && sUser.post.webProgramAccessIds.size() > 0)
                    siteContent.Web_Program_Access_Ids__c = String.join(new List<String> ( sUser.post.webProgramAccessIds ), ',');
                upsert siteContent;
            }
            
            return siteContent.Id;
        }
    }
    
    /**
     * @description: check fields on the Site Content record to see if it should be updated based on the data coming from the site
     * 
     * @revision log: v1.00 - 07/28/2019 - CR-20190510-13101 - Victor Hanson - Created
     * 
     **/
    private boolean checkForUpsert() {
        boolean needsUpsert = false;
        
        //get existing site content mtm
        getExistingSiteContentMtM();
        //check basic field info first
        if (siteContent == null 
            || siteContent.GUID__c != sUser.post.post_title.abbreviate(80)
            || siteContent.Title__c != sUser.post.post_title
            || siteContent.URL__c != sUser.post.guid) 
        {
            needsUpsert = true;
        }
        
        //if the basic fields didn't change, check for web program access changes
        if (sUser.post.webProgramAccessIds != null && sUser.post.webProgramAccessIds.size() > 0) {
            
            //get web program access ids from the callout so we can compare the values
            Set<String> newWPAccessIds = new Set<String>();
            if (sUser.post.webProgramAccessIds != null && sUser.post.webProgramAccessIds.size() > 0)
                newWPAccessIds = sUser.post.webProgramAccessIds;
            
            //if web program access ids are different, or the WPA IDs don't match, set upsert to true       
            if (mapExistingSiteContentMtM.size() != newWPAccessIds.size()
                || !mapExistingSiteContentMtM.keySet().containsAll(newWPAccessIds)) 
            {
                needsUpsert = true;
                //updateSiteContentMtM();
            }
        }
        
        return needsUpsert;
    }
    
    /**
     * @description: verify each Site Content record has the associated MtM records created for each web program access id
     * 
     * @revision log: v1.00 - 07/28/2019 - CR-20190510-13101 - Victor Hanson - Created
     * 				: v1.01 - 04/14/2022 - CR-20220223-15939 - Chirag Soni - Updated null and Contains numeric check
     * 
     **/
    public static void updateSiteContentMtM(List<Site_Content__c> newSiteContent, Map<Id, Site_Content__c> oldSiteContentMap) {
        
        //instantiate variables
        Map<Id, Site_Content__c> mapSContentToUpdateMtMs = new Map<Id, Site_Content__c>();
        Set<String> allWebProgramAccessIds = new Set<String>();
        List<Site_Content_MtM__c> sContentMtMToInsert = new List<Site_Content_MtM__c>();
        List<Site_Content_MtM__c> sContentMtMToDelete = new List<Site_Content_MtM__c>();
        
        //loop through each site content record to see if web program access changed
        for (Site_Content__c sc : newSiteContent) {
            
            //get old site content
            Site_Content__c oldSContent;
            if (oldSiteContentMap != null)
                oldSContent = oldSiteContentMap.get(sc.Id);
            
            //if web program access ids are new or changed, add the site content record to our map
            if ( (oldSContent == null && sc.Web_Program_Access_Ids__c != null)
                || (oldSContent != null && oldSContent.Web_Program_Access_Ids__c != sc.Web_Program_Access_Ids__c))
            {
                mapSContentToUpdateMtMs.put(sc.Id, sc);
                
                //add all web program access ids
                allWebProgramAccessIds.addAll(sc.Web_Program_Access_Ids__c.split(','));
            }
        }
        
        //get the map of site content MtM
        Map<String, Site_Content_MtM__c> mapExistingSiteContentMtM = new Map<String, Site_Content_MtM__c>();
        
        //get all existing site content mtm
        for (Site_Content_MtM__c scMtM : [SELECT Id, Web_Program_Access__r.Site_Program_ID__c, Site_Content__c FROM Site_Content_MtM__c WHERE Site_Content__c IN :mapSContentToUpdateMtMs.keySet()]) {
            
            //add each record to our map for use later - set key as [siteContentId]-[programId] => SiteContentMtM
            mapExistingSiteContentMtM.put(getUK(scMtM), scMtM);
        }
        
        //loop through each site content MtM record
        for (Site_Content__c sc : newSiteContent) {
            
            //get old site content
            Site_Content__c oldSContent;
            if (oldSiteContentMap != null)
                oldSContent = oldSiteContentMap.get(sc.Id);
            system.debug('@@sc.Web_Program_Access_Ids__c:' + sc.Web_Program_Access_Ids__c);
            
            if (sc.Web_Program_Access_Ids__c != null && oldSContent != null && oldSContent.Web_Program_Access_Ids__c != null) {
                
                
                //convert comma-delim string of OLD ids to list
                List<String> oldSiteProgAccessIds = oldSContent.Web_Program_Access_Ids__c.split(',');
                
                //convert comma-delim string of ids to list
                List<String> siteProgAccessIds = sc.Web_Program_Access_Ids__c.split(',');
                
                
                //compare to list of site content sent from the site, to see if we need to delete any MtM records that were previously created 
                //(ie: if web program access was removed from a post for some Program)
                for (String oldAccessId : oldSiteProgAccessIds) {
                    
                    //add to deletion list if this site content mtm isn't in the list of web programs from the site
                    if (!siteProgAccessIds.contains(oldAccessId)) {
                        
                        //verify the site content mtm exists then add to delete list
                        Site_Content_MtM__c scMtMToDel = mapExistingSiteContentMtM.get(getUK(sc.Id, oldAccessId));
                        if (scMtMToDel != null)
                            sContentMtMToDelete.add(scMtMToDel);
                    }
                }
            }
        }
        
        //now, check which siteContentMtMs we need to create (ie: WPA that's coming from the site but not associated with the Site Content record yet)
        
        //store all web program access records and associated programs
        Map<String, Web_Program_Access__c> acronymToWPA = new Map<String, Web_Program_Access__c>();
        Map<String, Program__c> acronymToProgram = new Map<String, Program__c>();
        
        //convert web program access id strings to integers because they're stored as numbers in Salesforce
        List<Integer> wpaIds = new List<Integer>();
        for (String wpaId_String : allWebProgramAccessIds) {
            if (wpaId_String.isNumeric()) {
                wpaIds.add(Integer.valueOf(wpaId_String));
            }
        }
        
        //get web program access map
        Map<Decimal, Web_Program_Access__c> wpaIdMap = new Map<Decimal, Web_Program_Access__c>();
        List<Web_Program_Access__c> webProgramAccessFromSite = [SELECT Id, Site_Program_ID__c, Program_Code_to_Member__c FROM Web_Program_Access__c WHERE Site_Program_ID__c IN :wpaIds];
        for (Web_Program_Access__c wpa : webProgramAccessFromSite) {
            wpaIdMap.put(wpa.Site_Program_ID__c, wpa);
            
            acronymToWPA.put(wpa.Program_Code_to_Member__c, wpa);
        }
        
        //get programs based on web program access acronyms
        List<Program__c> programs = [SELECT Id, Program_Acronym__c FROM Program__c WHERE Program_Acronym__c IN :acronymToWPA.keySet()];
        for (Program__c p : programs) {
            acronymToProgram.put(p.Program_Acronym__c, p);
        }
        
        //get all MtM records that we need to create
        for (Site_Content__c sc : newSiteContent) {
            
            //get old site content
            Site_Content__c oldSContent;
            if (oldSiteContentMap != null)
                oldSContent = oldSiteContentMap.get(sc.Id);
            
            if (sc.Web_Program_Access_Ids__c != null) {
                
                
                //convert comma-delim string of OLD ids to list
                List<String> oldSiteProgAccessIds = new List<String>();
                if (oldSContent != null && oldSContent.Web_Program_Access_Ids__c != null)
                	oldSiteProgAccessIds = oldSContent.Web_Program_Access_Ids__c.split(',');
                
                //convert comma-delim string of ids to list
                List<String> siteProgAccessIds = sc.Web_Program_Access_Ids__c.split(',');
                
                for (String newSiteProgAccessId : siteProgAccessIds) {
                    
                    //if this id didn't exist on the old record, add to the insert list
                    if (!oldSiteProgAccessIds.contains(newSiteProgAccessId)) {
                        
                         Web_Program_Access__c wpa;
                        //Modified by Chirag Soni - 04/14/2022 - CR-20220223-15939 - Updated null and Contains numeric check
                        if(String.isNotBlank(newSiteProgAccessId) && newSiteProgAccessId.isNumeric() )
                        {
                            //get the web program access that corresponds to this id
                            wpa = wpaIdMap.get(Integer.valueOf(newSiteProgAccessId));
                        }
                       
                        //if null, continue
                        if (wpa == null)
                            continue;
                        
                        Program__c program = acronymToProgram.get(wpa.Program_Code_to_Member__c);
                        
                        //program is required, so make sure it's not null
                        if (program != null) {
                            
                            //add a site content MtM record with web program access & program populated
                            sContentMtMToInsert.add(new Site_Content_MtM__c(Web_Program_Access__c = wpa.Id,
                                                                            Program__c = program.Id, Site_Content__c = sc.Id));
                        }
                    }
                }
            }
        }
        
        if (sContentMtMToDelete.size() > 0)
            delete sContentMtMToDelete;
        
        if (sContentMtMToInsert.size() > 0)
            insert sContentMtMToInsert;
    }
    
    /**
     * @description: populates the mapExistingSiteContentMtM map
     **/
    private void getExistingSiteContentMtM() {
        
        mapExistingSiteContentMtM = new Map<String, Site_Content_MtM__c>();
        
        //get all existing site content mtm
        for (Site_Content_MtM__c scMtM : [SELECT Id, Web_Program_Access__r.Site_Program_ID__c FROM Site_Content_MtM__c WHERE Site_Content__c = :siteContent.Id]) {
            
            //add each record to our map for use later
            mapExistingSiteContentMtM.put(String.valueOf(scMtM.Web_Program_Access__r.Site_Program_ID__c), scMtM);
        }
    }
    
    //returns a unique key containing site content id + site program id
    public static String getUK(Site_Content_MtM__c scMtM) {
        return scMtM.Site_Content__c + '-' + String.valueOf(scMtM.Web_Program_Access__r.Site_Program_ID__c);
    }
    
    //returns a unique key containing site content id + site program id
    public static String getUK(Id sContentId, String siteProgramId) {
        return sContentId + '-' + siteProgramId;
    }
}