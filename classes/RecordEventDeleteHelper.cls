/**
 *  Description     :   Helper class for event trigger and will hold event records delete based associated functionalities and validation logic.
 * 
 *  Created By      :   Abhinav Sharma    
 * 
 *  Created Date    :   03/15/2017
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20170307-10743
**/  
public without sharing class RecordEventDeleteHelper {
    
    //Added By - Abhinav Sharma - CR-20140618-5845 - 07/03/2014
    /**
     *  @description    :   This method is to there to update & validate case records on before events of trigger.
     *                      (i) Method to populate "Member Type" field on case with "RIAMLargeContract" value 
                                    if Key Notes on Institution record contains 'RIAMLargeContract.  
     * 
     *  @args           :   List of cases, Map of Cases
     * 
     *  @return         :   void
     * 
    **/ 
    public static void restrictProfilesFromDeletingTheEvents(List<Event> newEvents, Map<Id,Event> oldMapEvents) {
    	
        //Set to hold the restricted profiles IDs
        Set<Id> setOfRestrictedProfilesIds = new Set<Id>();
        
        //Loop through custom metadata type and fetching restricted profile details
		for(Activity_Delete_Restricted_Profiles__mdt rPro : [SELECT Id, Profile_Id__c 
                                                             FROM Activity_Delete_Restricted_Profiles__mdt
                                                             WHERE Profile_Id__c != null AND Profile_Id__c != ''
                                                             AND Profile_Name__c != null AND Profile_Name__c != ''
                                                            ]) {
        	//Checking field value for ID type
        	if(rPro.Profile_Id__c instanceOf ID)
            	setOfRestrictedProfilesIds.add(ID.valueOf(rPro.Profile_Id__c));
        }
    
        //Current Logged In user profile ID	
        String currentLoggedInUserProfileID = UserInfo.getProfileId();
    	
		//Checking set for size value and checking whether current user profile ID exists in it        
        if(setOfRestrictedProfilesIds.size() > 0 
        	&& setOfRestrictedProfilesIds.contains(currentLoggedInUserProfileID)) {
                
            //Loop through event records    
            for(Event evt : oldMapEvents.values())
                evt.addError(System.Label.ERROR_DO_NOT_HAVE_ACCESS_TO_DELETE_EVENT);
        }   
    }
}