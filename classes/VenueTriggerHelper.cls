/**
 *	Purpose			:	This class is to hold all the helper methods for Venue Trigger
 *
 *	Created By		:	Bhavi Sharma
 *
 *	Created Date	:	02/14/2015
 *
 *	Revision Logs	:	V_1.0 - Created
 *						V_1.1 - Modified By - Mahendra Swarnkar - 10/16/2015 - CR-20150928-9276 - Added new method (updateStaffRateOnTeamMembers)
 *
 **/ 
public without sharing class VenueTriggerHelper {
    
    //Flag to control the trigger execution
    public static Boolean EXECUTE_VENUE_TRIGGER = true;
    public static String EVENT_VENUE_AND_ACCOMODATION_RdTYPE = 'Event_Venue_and_Accommodations';
    public static String ACCOMODATIONS_RdTYPES = 'Accommodations';
     
    //Method Added By - Mahendra Swarnkar - 10/16/2015 - CR-20150928-9276
    /**
	 * 	@description	:	This method will populate the staff rate field on Team member records with following logic:-
	 * 						a) A manual or dataloader entry in the "Staff Rate" field on the Team Member object 
	 * 						   should always override the auto-populated value from the associated Event Venue.
							b) If an Event has multiple associated Event Venue records, use the Staff Rate value from 
							   the record with type "Event Venue and Accommodations."
							   If no record of that type exists, then use the most recent record of type "Accommodations."
	 *						
	 *	@args			:	List of new Venues
	 * 
	 * 	@return			:	void
	 * 
	 **/
	public static void updateStaffRateOnTeamMembers(List<Venue__c> venues , Map<Id, Venue__c> mapOldVenues) {
		
		//Map to hold AdvisoryEventIds as aKey and Event vanue count as a value 
        Map<Id, Integer> mapAEVanuesCount = new Map<Id, Integer>();
        
        //Loop through Event Venues and populating set to hold the "Advisory Event" records Id value
        for(Venue__c ven: venues != null ? venues : mapOldVenues.values()) {
            
            //Insert case
            if(mapOldVenues == null && ven.Advisory_Event__c != null && ven.Staff_Rate__c != null) 
            	mapAEVanuesCount.put(ven.Advisory_Event__c, 0);
            
            //Delete case
            if(venues == null && ven.Advisory_Event__c != null) 
            	mapAEVanuesCount.put(ven.Advisory_Event__c, 0);
            
            //Update Case
            if(mapOldVenues != null && venues != null 
               && (ven.Staff_Rate__c != mapOldVenues.get(ven.Id).Staff_Rate__c
                   || ven.RecordTypeId != mapOldVenues.get(ven.Id).RecordTypeId))
               mapAEVanuesCount.put(ven.Advisory_Event__c, 0); 
            
        } 
        
        //Check for size value
        if(mapAEVanuesCount.keySet().size() > 0) {
        	
        	//Map to hold event venue record types as a value and record types developerName as a key
        	Map<String, RecordType> mapVenueRecordTypes = new Map<String, RecordType>();
        	
        	//Set of recordtype developernames
        	Set<String> rdTypesDeveloperNames = new Set<String>();
        	rdTypesDeveloperNames.add(EVENT_VENUE_AND_ACCOMODATION_RdTYPE);
        	rdTypesDeveloperNames.add(ACCOMODATIONS_RdTYPES);
        
	        //loop through recordtypes
	        for(RecordType  rType : [Select Id, DeveloperName From RecordType 
	        							Where SobjectType = 'Venue__c' AND IsActive = True 
	        							AND RecordType.DeveloperName IN : rdTypesDeveloperNames]) {
            	if(rType.DeveloperName == EVENT_VENUE_AND_ACCOMODATION_RdTYPE)
            		mapVenueRecordTypes.put(rType.DeveloperName, rType);
            	else
               		mapVenueRecordTypes.put(rType.DeveloperName, rType);
        	}
        	
        	//Checking map for size value
        	if(mapVenueRecordTypes.keySet().size() > 0) {
        	
                //Map to hold AdvisoryEventIds as aKey and Event vanues instance as a value 
        		Map<Id, Venue__c> mapAEVanues = new Map<Id, Venue__c>();
        	
	        	//Loop through Event venues and populating map accordingly to have appropriate values
	            for(Venue__c ven: [SELECT ID, Advisory_Event__c, Staff_Rate__c, RecordType.DeveloperName 
                                   		From Venue__c 
	                                    Where Advisory_Event__c != null 
	                                    AND Advisory_Event__c IN : mapAEVanuesCount.keySet() 
	                                    AND RecordType.DeveloperName != null 
					   				    AND RecordType.DeveloperName IN : mapVenueRecordTypes.keySet() 
	                                    ORDER BY CreatedDate DESC]) {
	             	
                    //Incrementing the counter value in the map mapAEVanuesCount 
	                if(mapAEVanuesCount.containsKey(ven.Advisory_Event__c)) {
                        Integer counter = mapAEVanuesCount.get(ven.Advisory_Event__c);
                        counter++;
                        mapAEVanuesCount.put(ven.Advisory_Event__c, counter);
                    }
                                  
					//Check for availability
	                if(!mapAEVanues.containsKey(ven.Advisory_Event__c)) 
	                    mapAEVanues.put(ven.Advisory_Event__c, ven);
	                else {
                        
	                    if(mapVenueRecordTypes.containsKey(ACCOMODATIONS_RdTYPES)
                            && mapVenueRecordTypes.get(ACCOMODATIONS_RdTYPES) != null
							&& mapVenueRecordTypes.containsKey(EVENT_VENUE_AND_ACCOMODATION_RdTYPE)
							&& mapVenueRecordTypes.get(EVENT_VENUE_AND_ACCOMODATION_RdTYPE) != null
							&& mapAEVanues.containsKey(ven.Advisory_Event__c)
							&& mapAEVanues.get(ven.Advisory_Event__c) != null
							&& mapAEVanues.get(ven.Advisory_Event__c).RecordTypeId != null
							&& ven.RecordTypeId == mapVenueRecordTypes.get(EVENT_VENUE_AND_ACCOMODATION_RdTYPE).Id 
							&& mapAEVanues.get(ven.Advisory_Event__c).RecordTypeId == mapVenueRecordTypes.get(ACCOMODATIONS_RdTYPES).Id)
							mapAEVanues.put(ven.Advisory_Event__c, ven);
						else 
                            continue;
	                }
	            }
            	
                //List to hold Team members to be updated 
                Map<Id, Team_Member__c> mapOfTeamMembersToUpdate = new Map<Id, Team_Member__c>();
                
                //Loop through Team members
                //Populating team members list to be updated 
                for(Team_Member__c tM : [SELECT ID, Advisory_Event__c, Staff_Rate__c From Team_Member__c 
                                         Where Advisory_Event__c != null 
                                         AND Advisory_Event__c IN : mapAEVanuesCount.keySet()]) {
                                             
                                             //Checking for venue presence                                 
                                             if(mapAEVanuesCount.containsKey(tM.Advisory_Event__c)
                                                && mapAEVanuesCount.get(tM.Advisory_Event__c) != null) {
                                                    if(mapAEVanuesCount.get(tM.Advisory_Event__c) > 0) {
                                                        
                                                        //Check for availability and additional validation conditions to populate staff rate 
                                                        if(mapAEVanues.containsKey(tM.Advisory_Event__c)
                                                           && mapAEVanues.get(tM.Advisory_Event__c) != null
                                                           && tM.Staff_Rate__c != mapAEVanues.get(tM.Advisory_Event__c).Staff_Rate__c) {
                                                               tM.Staff_Rate__c = mapAEVanues.get(tM.Advisory_Event__c).Staff_Rate__c;
                                                           } 
                                                        mapOfTeamMembersToUpdate.put(tM.Id, tM);
                                                    } else {
                                                        
                                                        tM.Staff_Rate__c = null;
                                                        mapOfTeamMembersToUpdate.put(tM.Id, tM);
                                                    }
                                                }
                                         }
                
                //Check for the Size
                if(mapOfTeamMembersToUpdate.values().size() > 0) {
                    
                    //Disable all the Triggers
                    Util.BypassAllTriggers = True;
                    
                    //Update the Team Members
                    Update mapOfTeamMembersToUpdate.values();
                    
                    //Enable all the Triggers
                    Util.BypassAllTriggers = False;
                }                                
                
            }
		}
    }	        
   
    /**
	 * 	@description	:	This method is to verify that only one program can be set as Primary.
	 								If the current record has just been marked as Primary__c = TRUE, then set any other Venue records for the same meeting as Primary__c = FALSE.  
									If there is only one Venue record, it should be marked as Primary__c = TRUE.  
									If there is more than one Venue record and none are currently marked as Primary__c = TRUE, then the most recently modified record should be set as Primary__c = TRUE.
	 * 
	 *	@args			:	List of new Venues
	 * 
	 * 	@return			:	void
	 * 
	 **/
	public static void validatePrimaryVenue(List<Venue__c> venues) {
		
		//Check for the Program Venues and create a set of Meeting Ids to check with
		Set<Id> meetingIds = new Set<Id>();
		
		//Loop through the records and populate a set for Program meetings
		for(Venue__c venue : venues) {
			
			//Check for the Meeting Venues and populate the meeting Ids set
			if(venue.Advisory_Event__c != null) {
				
				//Populate the meeting IDs 
				meetingIds.add(venue.Advisory_Event__c);
			}
		}
		
		//Fetch the related Venues with these meetings
		if(meetingIds.size() == 0)
			return;
		
		//Map to hold the metting Id as key, and related list of primary Venues as values
		Map<Id, List<Venue__c>> mapMeetingWithRelatedPrimaryVenues = new Map<Id, List<Venue__c>>();
		
		//Query the related Venues of type Program
		for(Venue__c Venue : [Select Id, Advisory_Event__c from Venue__c where Advisory_Event__c IN: meetingIds 
															AND Primary__c = true
                           									AND ID NOT IN: venues]) {
			
			//Add in Map
			if(!mapMeetingWithRelatedPrimaryVenues.containsKey(Venue.Advisory_Event__c))
				mapMeetingWithRelatedPrimaryVenues.put(Venue.Advisory_Event__c, new List<Venue__c>());
			
			//Add Venue record
			mapMeetingWithRelatedPrimaryVenues.get(Venue.Advisory_Event__c).add(Venue);
		}
		
		//List to hold the Venues to update from Primary to non Primary
		List<Venue__c> nonPrimaryVenuesToUpdate = new List<Venue__c>();
		
		//Loop through the new records again and check if there is any record need to be set as non primary
		for(Venue__c venue : Venues) {
			
			//Check for the Program Venues and populate the meeting Ids set
			if(venue.Advisory_Event__c != null) {
				
                //Check if this Venue is set as primary and there is other record which need to be set as non primary
				if(mapMeetingWithRelatedPrimaryVenues.containsKey(venue.Advisory_Event__c)) {
					
					//Chekc if current Venue is cam as primary, only the mark the other as not primary
					if(venue.Primary__c == true) {
						
					    //Existing primary Venues
						List<Venue__c> existingVenues = mapMeetingWithRelatedPrimaryVenues.get(venue.Advisory_Event__c);
						
						//Loop through these records and set them as primary
                        for(Venue__c eVenue : existingVenues) {
							
                            eVenue.Primary__c = false;
                        }
						//Add in list to update
						nonPrimaryVenuesToUpdate.addAll(existingVenues);
					}
				} else {
					
					//Set this Venue as Primary
					venue.Primary__c = true;
				}
			}
		}
		
		//Update the from primary to non primary
		if(nonPrimaryVenuesToUpdate.size() > 0) {
			
			//no need to execute the triggers
			VenueTriggerHelper.EXECUTE_Venue_TRIGGER = false;
			
			//Update 
			update nonPrimaryVenuesToUpdate;
			
			//Activate trigger again, so the other methods and be executed
			VenueTriggerHelper.EXECUTE_Venue_TRIGGER = true;
		}
	}    
}