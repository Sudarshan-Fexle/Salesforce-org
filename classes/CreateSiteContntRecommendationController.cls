/**
*   Description     :   This Class is used to add Site Content on Site Profile

*   Created by      :   Neha Sharma
*
*   Created Date    :   
*
*   Revision Log    :   V1.0 - Created  
*                       V1.1 - Modified by - Neha Sharma - CR-20200521-14083 - 10/22/2020 - Add options for assigning and removing "picks just for you" - Campaign
**/
public without sharing class CreateSiteContntRecommendationController {
    
    public createSiteContntRecommendationController() {

    }

    @AuraEnabled
    public static LightningResponseEntity createSCRs(String screen1Selection, string scrSelection, String userSelection, String assignmentRoleSelection)
    {

        LightningResponseEntity reponseHandler = new LightningResponseEntity();
        if(String.isNotBlank(screen1Selection)) 
        {
            //Parse SCRs.
            List<siteContentRecommendationsHelper.SiteContentWrapper> siteContentDataFromPage = new List<siteContentRecommendationsHelper.SiteContentWrapper>();
            List<LookupSearchResult> usersSelectiondata = new List<LookupSearchResult>();
            
            //Parse the JSON formatted Data, data is having the same format like "SiteContentWrapper" class. 
            siteContentDataFromPage = (List<siteContentRecommendationsHelper.SiteContentWrapper>) JSON.deserialize(scrSelection, List<siteContentRecommendationsHelper.SiteContentWrapper>.class);
            
            
            if(screen1Selection.contains('strategicLeader')) 
            {
                usersSelectiondata = (List<LookupSearchResult>) Json.deserialize(userSelection,  List<LookupSearchResult>.class);
                
                
                //Selected Users.
                Set<String> setSelectedUsers = new Set<String>();
                List<LookupSearchResult> lookupSearchResults = new List<LookupSearchResult>();
                
                for(LookupSearchResult userData : usersSelectiondata)
                    setSelectedUsers.add(userData.Id);
                
                Set<Id> setOfAccountIds = new Set<Id>();
                for(Account strtegicLeaderAccount : [Select Id From Account 
                                                     Where Research_Strategic_Leader__c IN: setSelectedUsers])
                {
                    setOfAccountIds.add(strtegicLeaderAccount.Id);
                }
                //Batch Job.
                 Batch_SiteContentRecommendations b = new Batch_SiteContentRecommendations(setOfAccountIds, null,scrSelection);
                 database.executeBatch(b, 1);             
            }
            else if(screen1Selection.contains('institutionRole')) 
            {
                //Set to hold the Ids Of Contact.  
                Set<Id> setOfSiteProfileIds = new Set<Id>();
                List<LookupSearchResult> listofLookUpResults = new List<LookupSearchResult>();
                
                if(assignmentRoleSelection.contains('"')) {
                    assignmentRoleSelection =  assignmentRoleSelection.replace('"', '');
                }
                  
                Set<Id> setOfContactIds = new Set<Id>();
                  for(Institution_Roles__c institutionRole : [Select Id, Contact__c, Contact__r.EAB_com_Site_Profile__c From Institution_Roles__c  
                                                            Where Assignment_Role__r.Name =: assignmentRoleSelection 
                                                            AND Assignment_Role__r.Active__c = true 
                                                            AND Assignment_Role__r.Institution_Role_External__c = true 
                                                            AND Contact__c != null]) 
                  {
                     setOfContactIds.add(institutionRole.Contact__c);
                  }
                 //Batch Job.
                      Batch_SiteContentRecommendations b = new Batch_SiteContentRecommendations(null, setOfContactIds,scrSelection);
                      database.executeBatch(b, 1);               
            }
            //Modified by - Neha Sharma - CR-20200521-14083 - 10/22/2020 - Add options for assigning and removing "picks just for you" - Campaign
            else if(screen1Selection.contains('campaign')) 
            {
                usersSelectiondata = (List<LookupSearchResult>) Json.deserialize(userSelection,  List<LookupSearchResult>.class);
                
                //Selected Campaign.
                Set<String> setSelectedCamp = new Set<String>();
                List<LookupSearchResult> lookupSearchResults = new List<LookupSearchResult>();
                
                for(LookupSearchResult userData : usersSelectiondata)
                    setSelectedCamp.add(userData.Id);
                
                Set<Id> setOfContactIds = new Set<Id>();
                for(CampaignMember campMember : [Select ContactId From CampaignMember 
                                                Where Type='Contact' And CampaignId IN: setSelectedCamp And Contact.Contact_Status__c = 'Active'])
                {
                    setOfContactIds.add(campMember.ContactId);
                }
                //Batch Job
                Batch_SiteContentRecommendations b = new Batch_SiteContentRecommendations(null, setOfContactIds,scrSelection);
                database.executeBatch(b, 1);
            }
            //End Here
        }
        return reponseHandler;
    }
}