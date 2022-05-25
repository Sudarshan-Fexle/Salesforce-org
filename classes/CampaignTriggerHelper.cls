/**
 *  Purpose         :   This class is helper class for trigger on User object.
 *  
 *  Create By       :   Mahendra Swarnkar
 *  
 *  Created Date    :   10/09/2017
 *  
 *  Current Version :   v1.0
 *  
 *  Revision Log    :   v1.0 - Created - Apollo Release - CR-20170927-11494 -  Added a new call for Entity field.
 *                      
*/
public without sharing class CampaignTriggerHelper {
    
    /**
     *  @description    :   Method used to populate the Entity field value
     *                      1) If Primary Program has a value, set Entity based on the related Program's Entity
     *                      2) otherwise, set Entity based on the record Owner's Entity 
     *
     *  @args           :   List of new Campaign records, Map of old Campaign records
     * 
     *  @return         :   void
     * 
     *  @Revision Log   :   V1.0 - Created By - Mahendra Swarnkar - 10/09/2017 - CR-20170927-11494 - Apollo Release
     **/
    public static void populateEntityField(List<Campaign> campaigns, Map<Id, Campaign> mapOldCampaigns) {
        
        //Set to hold the campaign ids on Promary Program based 
        List<Campaign> listProgramBasedcampaigns = new List<Campaign>();
        
        //Set to hold the campaign ids on Owner based 
        List<Campaign> listOwnerBasedcampaigns = new List<Campaign>();
        
        //Loop over the campaign records
        for(Campaign camp : campaigns) {
            
            //Check for the Primary Program
            if(camp.Primary_Program__c != null)
                listProgramBasedcampaigns.add(camp); 
            else
                //Populate the list of campaign for which Entity field will be populated on the basis of Owner's Entity field 
                listOwnerBasedcampaigns.add(camp);
        }
        
        //Check for size
        if(listProgramBasedcampaigns.size() > 0){
            
            //Method call to populate the Entity field value on the basis of Primary Program's Entity field value
            Util.validateEntityValue(listProgramBasedcampaigns, mapOldCampaigns , 'Campaign', 'Entity__c', 'Primary_Program__c', 'Entity__c', 'Primary_Program__r', 'Program__c');
        }
        
        //Check for size
        if(listOwnerBasedcampaigns.size() > 0){
            
            //Method call to populate the Entity field value on the basis of Owner's Entity field value
            Util.validateEntityValue(listOwnerBasedcampaigns, mapOldCampaigns , 'Campaign', 'Entity__c', 'OwnerId', 'Entity__c', 'Owner', 'User');
        }
    }
}