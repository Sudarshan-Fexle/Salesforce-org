/**
 *  Description     :   Class is used to handle all the logic of manipulation on site token.
 *
 *  Created By      :   Dipesh Gupta
 *
 *  Created Date    :   05/17/2019
 *
 *  Revision Logs   :   V_1.0 - Created - Eab.com Rebuild - CR-20190510-13101
 *		    		:   V_1.1 - Modified By - Nikita Kumari - 07/30/2021 - CR-20200520-14074 - Show Site Token on 1EAB Lead record and vice-versa
 *                      
 **/
public class SiteTokenTriggerHelper {
    
    /**
     *  Description     :   Method to actual update the Token Used Count on related Institution.
     *
     *  Created By      :   Dipesh Gupta
     *
     *  Created Date    :   05/17/2019
     *
     *  Revision Logs   :   V_1.0 - Created - Eab.com Rebuild - CR-20190510-13101
     * 			    V_1.1 - Modified - 08/27/2019 - Victor Hanson - CR-20190827-13290 - updated populateTokenUsedCountOnInstitution
     *                      
    **/ 
    public static void populateTokenUsedCountOnInstitution(List<Site_Token__c> newSiteTokens, Map<Id, Site_Token__c> oldMapSiteToken) {
        
        //Set to hold the Site profiles id. 
        Set<Id> setSiteProfileIds = new Set<Id>();
        
        //Check for the Site Token loop. 
        for(Site_Token__c sT: newSiteTokens != null ? newSiteTokens : oldMapSiteToken.values()){
            
            //Check for the Site Token deleted or inserted. 
            
            //Delete cases. 
            if(newSiteTokens == null && oldMapSiteToken != null) {
                
                //Filling the set with the repective site profile ids.
                setSiteProfileIds.add(oldMapSiteToken.get(sT.Id).Site_Profile__c);
            }
            
            //Insert Case
            if(newSiteTokens != null) {
                setSiteProfileIds.add(sT.Site_Profile__c);
            }
        }
        
        //Check for the set.
        if(setSiteProfileIds.size() > 0 )
            updateTokenDetailsOnAccount(setSiteProfileIds);

        
    }
   
    public Static void updateTokenDetailsOnAccount(Set<Id> setSiteProfileIds) {
        
        //Check for the set size. 
        if(setSiteProfileIds.size() > 0) {
            
           //Map to hold the account
            Map<Id, Account> mapAccToBeUpdated = new Map<Id, Account>();

            //Map to hold the site profiles. 
            Map<Id, Site_Profile__c> mapSiteProfiles = new Map<Id, Site_Profile__c>();
              
            //Query on the site profile object. 
            for(Site_Profile__c sP : [Select Id, r_Institution__c, Contact__c, Contact__r.AccountId, Token_s_Pending_For_Chatter__c
                                      From Site_Profile__c Where Id IN: setSiteProfileIds ]) {
                
                //Add the Institution ids
                mapAccToBeUpdated.put(sP.Contact__r.AccountId, new Account(Id = sP.Contact__r.AccountId, Tokens_Used__c = 0));

                //Add the site profiles to the Map. 
                mapSiteProfiles.put(sp.Id, new Site_Profile__c(Id = sP.Id, Tokens_Used_YTD__c = 0, Token_s_Pending_For_Chatter__c = false));
            }
            
            //Check for the set size. 
            if(mapAccToBeUpdated.size() > 0) {
                 
                //Query on the Site profile to get All the related Site profiles. 
                for(Site_Profile__c sP : [Select Id, Contact__r.AccountId, Token_s_Pending_For_Chatter__c,
                                            Tokens_Used_YTD__c, 
                                            (Select Id, Chatter_Posted_For_This_Token__c From Site_Tokens__r Where Expiration_Date__c != null AND
                                            (Status__c = 'Active' OR Status__c = 'Expired') AND Expiration_Date__c = THIS_YEAR) 
                                          From Site_Profile__c 
                                          Where Contact__r.AccountId IN: mapAccToBeUpdated.keySet()]) {
                	
                	if(sP.Site_Tokens__r != null && sP.Site_Tokens__r.size() > 0) {
               			
                        //Adding the values in the Map for the same Account. 
                        if(mapAccToBeUpdated.containsKey(sP.Contact__r.AccountId))
                            mapAccToBeUpdated.get(sP.Contact__r.AccountId).Tokens_Used__c +=  sP.Site_Tokens__r.size(); 

                        if(mapSiteProfiles.containsKey(sP.Id))      
                            mapSiteProfiles.get(sP.Id).Tokens_Used_YTD__c +=  sP.Site_Tokens__r.size();  
                        
                        for(Site_Token__c sT : sP.Site_Tokens__r) {
							
                            //If there are even a single Token that is chatter post needed then set site profile 
                            //set as flag true so it can be included in the next hr batch job that is used to send the chatter post. 
                            if(!sT.Chatter_Posted_For_This_Token__c) {
                                
                                if(mapSiteProfiles.containsKey(sP.Id))  {
                                	mapSiteProfiles.get(sP.Id).Token_s_Pending_For_Chatter__c = true;  
                        			break;        
                                }         
                            }
						}
                    }  
                }
                
                //Check for the map. 
                if(mapAccToBeUpdated.size() > 0) {
                    Util.ByPassAllTriggers = true;
                    update mapAccToBeUpdated.values();
                    Util.ByPassAllTriggers = false;
                }

                //Check for the Map.
                if(mapSiteProfiles.size() > 0) {
                    Util.ByPassAllTriggers = true;
                    update mapSiteProfiles.values();
                    Util.ByPassAllTriggers = false;
                } 

            }
        }
    }  
    
    /**
     *  Description     :   Method to Update the site profile with the Token Details.
     * 
     *  Created By      :   Mahendra Swaranakar
     *
     *  Created Date    :   07/30/2020
     *
     *  Revision Logs   :   V1.1 - Created - CR-20200415-13948
     * 						
    **/ 
    Public Static void updateSiteProfileWhenTokenChatterPosted(List<Site_Token__c> newSiteTokens, Map<Id, Site_Token__c> oldMapSiteTokens) {
        
        Set<Id> setOfSiteProfiles = new Set<Id>();
        
        for(Site_Token__c sT : newSiteTokens != null ? newSiteTokens : oldMapSiteTokens.values()) {
			    
            if((oldMapSiteTokens != null && String.isNotBlank(sT.Site_Profile__c)
               && oldMapSiteTokens.get(sT.Id).Chatter_Posted_For_This_Token__c != sT.Chatter_Posted_For_This_Token__c) || newSiteTokens == null ) {
            		
                   setOfSiteProfiles.add(sT.Site_Profile__c);
            }
        }    
        
        if(setOfSiteProfiles.size() > 0){
            
            //Map to hold the site Profiles. 
            Map<Id, Site_Profile__c> mapSiteProfiles = new Map<Id, Site_Profile__c>();
            
            //Getting site Profiles to get the 
            for(Site_Profile__c sP : [Select Id, Token_s_Pending_For_Chatter__c,
                                      (Select Id From Site_Tokens__r Where Chatter_Posted_For_This_Token__c = false LIMIT 1) 
                                      From Site_Profile__c where Id IN: setOfSiteProfiles]) {
				Boolean tokensPendingChatter = false;
                
               if(sP.Site_Tokens__r != null && sP.Site_Tokens__r.size() > 0) {
            		tokensPendingChatter = true;
                }else{
                    tokensPendingChatter = false;
                }
                                          
                if(sP.Token_s_Pending_For_Chatter__c != tokensPendingChatter)
                     mapSiteProfiles.put(sP.Id, new Site_Profile__c (Id = sP.Id, Token_s_Pending_For_Chatter__c= tokensPendingChatter));
            }
            
            if(mapSiteProfiles != null && mapSiteProfiles.size()  >0) {
                
                Util.BypassAllTriggers = true; 
                update mapSiteProfiles.values();
                Util.BypassAllTriggers = false;
            }
                
        }
    }
    
    /**
     *  Description     :   Method to populate site token record, on the Warm lead record site token Whenever 
     *             	    User tag lead on the Site Token record
     *
     *  Created By      :   Nikita Kumari
     *
     *  Created Date    :   07/30/2021
     *
     *  Revision Logs   :   V_1.0 - CR-20200520-14074 - Show Site Token on 1EAB Lead record and vice-versa
     *
     **/ 
    public static void populateTokenOn1EABLead(List<Site_Token__c> newSiteTokens, Map<Id, Site_Token__c> oldMapSiteToken) {
        
        //map to hold the warm leads 
        Map<Id, X1EAB_Lead__c> mapOf1EABLeadToUpdate = new Map<Id, X1EAB_Lead__c>();

        //Loop over the site Tokens
        for(Site_Token__c sT: newSiteTokens ){
            //New and Update case
            if(( oldMapSiteToken == null && sT.Lead__c != null)  
               || (oldMapSiteToken != null && sT.Lead__c != oldMapSiteToken.get(sT.Id).Lead__c)){
                   
                   //get details to 1EAB Lead if it's associated with a Site Token
                   if(sT.Lead__c != null){
                      mapOf1EABLeadToUpdate.put(sT.Lead__c,new X1EAB_Lead__c(Id = st.Lead__c, Token__c = sT.Id));                       
                   }
                   
                   //update details over 1EAB Lead if user updates over Site Token
                   if(oldMapSiteToken != null && sT.Lead__c != oldMapSiteToken.get(sT.Id).Lead__c && oldMapSiteToken.get(sT.Id).Lead__c != null){
                       mapOf1EABLeadToUpdate.put(oldMapSiteToken.get(sT.Id).Lead__c, new X1EAB_Lead__c(Id = oldMapSiteToken.get(sT.Id).Lead__c, Token__c = null));                       
                   }
            } 
        }
        //update Records
        if(mapOf1EABLeadToUpdate.size() > 0){
            Util.BypassAllTriggers = true; 
            update mapOf1EABLeadToUpdate.values();
            Util.BypassAllTriggers = false;
        }
      
    }
}