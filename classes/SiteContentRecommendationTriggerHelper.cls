/*
 * Purpose		:	Helper Class for SiteContentRecommendationTrigger to update Institution when insert and update
 * 
 * CreatedDate	:	21/10/2019
 * 
 * RevisionLog	: 	V_1.0 - Created - Dipesh Gupta
 * */

public class SiteContentRecommendationTriggerHelper {
	
    
    public static void updateInstitutionOnSiteContentRecommendation(List<Site_Content_Recommendation__c> newSiteContentRecommendations, 
                                                                    Map<Id, Site_Content_Recommendation__c> oldMapOfSiteContentRecommendations)
    {
        
        // Set Of Site Profile Id
        Set<Id> setScrSiteProfileIds = new Set<Id>();

        for(Site_Content_Recommendation__c scr : newSiteContentRecommendations)
        {
            // Check if Institution__c is blank and Site_Profile__c not blank than only fill the set of Site Profile Id
            if(String.isBlank(scr.Institution__c) &&  String.isNotBlank(scr.Site_Profile__c) )
                
                if(oldMapOfSiteContentRecommendations == null || 
                   (oldMapOfSiteContentRecommendations != null && scr.Site_Profile__c != oldMapOfSiteContentRecommendations.get(scr.Id).Site_Profile__c || scr.Contact__c != oldMapOfSiteContentRecommendations.get(scr.Id).Contact__c))
                setScrSiteProfileIds.add(scr.Site_Profile__c);
            
        }
        
        // Check setScrSiteProfileIds size
        if(setScrSiteProfileIds.size() > 0) {
            
            // Filling Map of siteProfile with Institution
            Map<Id, Site_Profile__c> mapSiteProfileWithInstitutions = new Map<Id, Site_Profile__c>([SELECT Id, r_Institution__c, Contact__r.AccountId 
                                                                                                  From Site_Profile__c WHERE Id IN : setScrSiteProfileIds ]) ;
            
            // Check if mapSiteProfileWithInstitutions is not null
            if(mapSiteProfileWithInstitutions != null) {
            	
                //Loop on the new Site content Recommendations. 
                for(Site_Content_Recommendation__c sCR : newSiteContentRecommendations) {
                    
                    //Check the records if the institution is blank
                    if(String.isBlank(sCR.Institution__c))
                        sCR.Institution__c = mapSiteProfileWithInstitutions.containsKey(sCR.Site_Profile__c) ? mapSiteProfileWithInstitutions.get(sCR.Site_Profile__c).Contact__r.AccountId : null;
                    
                }
            }
    	}
	}
}