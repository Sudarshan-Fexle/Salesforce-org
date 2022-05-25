/*
    Purpose         :   This trigger is to do all the pre and post processing operations for MembershipKeyContact object
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   12/15/2012
    
    Current Version :   v1.1
    
    Revision Log    :   V_1.0 Created
                        V_1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
			V_1.2 - Modified By - Mahendra Swarnkar - 1/21/2017 - CR-20160907-10171
			V_1.3 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
			V_1.4 - Modified By - Deepak kumawat - 10/09/2017 - CR-20170927-11497 - Apollo Release - Apollo Release -  Added a new call for Entity field
			V_1.5 - Modified By - Dipesh Gupta - 11/11/2019 - CR-20190419-13012 - Added new method 'validateMembershipKeyContact' 
			V_1.6 - Modified by Mahendra Swarnakar -02/27/2020 - CR-20200217-13758
			V_1.7 - Modified By - Subhash Garhwal - 04/27/2021 - CR-20210422-15095 - Move validateMembershipKeyContact method form before event to after
			V_1.8 - Added By - Neha Sharma - 4/28/2022 - CR-20210520-15169
*/
trigger Trigger_MembershipKeyContact on Membership_Key_Contact__c (after insert, after update, before insert, before update) {
    
	try { 
		
		//Check for trigger
		if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
			Util.validateEntityValue(Trigger.new, Trigger.oldMap, 'Membership_Key_Contact__c', 'Entity__c', 'Membership__c', 'Entity__c', 'Membership__r', 'Membership__c');
			
		//return immediately if method returns true	
    	if(Util.areTriggersOnThisObjectBypassed('Membership_Key_Contact__c')) return;
    
        //Check for the request type
        if(Trigger.isAfter) {
            
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method
                MembershipKeyContactTriggerHelper.populateContactData(Trigger.New);     
                
                //Subhash Garhwal - 04/27/2021 - CR-20210422-15095 - Moved this method to after call
                //MembershipKeyContactTriggerHelper.validateMembershipKeyContact(Trigger.new, Trigger.oldMap);  
                
            }
        }
        
        //Added By - Mahendra Swarnkar - 1/21/2017 - CR-20160907-10171
        //Check for the request type
        if(Trigger.isbefore) {
            
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method
                MembershipKeyContactTriggerHelper.updatePubMeetingStatusValue(Trigger.New, Trigger.oldMap);
                
                /* Added By Dipesh Gupta - 11/11/2019 - CR-20190419-13012 - This method is Used to validate Membership key contact, 
                   One membership can not have multiple contacts as MPOC */
                
                //======================Modified by Mahendra Swarnakar -02/27/2020 - CR-20200217-13758 - Start here=============================
		// Bypass process if this trigger was called by a batch or BypassAllTriggers
        	if(Util.IsBatch || Util.BypassAllTriggers) return;
        
        	// auto-generate subscriptions (CR-6629)
        	SiteUserHelper.CreateAutoSubscriptions(trigger.new, trigger.oldMap);
        
        	// List to store Membership Ids relating to the MKCs that spawned this trigger
        	List<Id> MembershipIds = new List<Id>();
        
        	// List to store Contact Ids relating to the MKCs that spawned this trigger
        	set<id> ContactIds = new set<id>();
        
        	// Map to store memberships for the MKCs that called this trigger
        	List<Membership__c> Memberships = new List<Membership__c>();
        
        	// Map to store the MKC's Membership Ids in a map w/ the MKC Id as the key
        	map<id, id> mkcid2mid = new map<id, id>(); 
        
        	// Loop through Membership_Key_Contacts that spawned this trigger
        	for(Membership_Key_Contact__c mkc : Trigger.New)
        	{
            		// If the Membership Key Contact has a Membership assigned, process
            		if(mkc.Membership__c != null)
            		{
                		// Add the MKC's Membership Id to a list
                		MembershipIds.add(mkc.Membership__c);
                
                		// Add the MKC's Contact Id to a list
                		contactIds.add(mkc.Contact__c);
                
                		// Add the MKC's Membership Id to a map w/ the MKC Id as the key
                		mkcid2mid.put(mkc.id, mkc.Membership__c);
            		}
        	}
        
        	// Query all Memberships related to the MKC's that spawned this trigger
        	Memberships = [select Id, Program__c, Program__r.Program_Acronym__c from Membership__c where Id in :MembershipIds];
        
        	// Map to store Memberships w/ their Id as the key
        	map<id, Membership__c> memid2memmap = new map<id, Membership__c>(Memberships);
        
        	// Query all Contacts and store them in a Map w/ their Id as the key
        	map<id, Contact> conid2conmap = new map<id, Contact>([select FirstName, LastName from Contact where id in :contactIds]);
        
        	System.Debug('### Memberships Found: ' + Memberships.size() + ' ###');
        
        	// Process only if there are memberships related to the MKCs that called this trigger
        	if(Memberships.size() > 0)
        	{
            		// Get the max field length of the MKC Name field (should be 80)
            		Integer maxnamelength = Membership_Key_Contact__c.Name.getDescribe().getLength();
            
            		// Loop through each MKC
            		for(Membership_Key_Contact__c mkc : Trigger.New)
            		{
                		// If the trigger was called by an Insert action or the trigger was called by an Update action
                		// and the MKC's Contact, Membership, or Role has changed, then process 
                		if(Trigger.isInsert ||
                    		(Trigger.isUpdate && (mkc.Contact__c != Trigger.oldmap.get(mkc.id).Contact__c ||
                    		mkc.Membership__c != Trigger.oldmap.get(mkc.id).Membership__c ||
                    		mkc.Role__c != Trigger.oldmap.get(mkc.id).Role__c)))
                		{
                    			//Make name for Membership record: Left([First Name] [Last Name] - [Program Acronym] - [Role],80)
                    			String longname = ' ';
                    
                    			// If the MKC has a Contact, start setting the new Name field
                    			if (mkc.Contact__c != null)
                    			{
                        			// Set the first part of the Long Name (<First Name>)
                        			if (conid2conmap.get(mkc.Contact__c).FirstName != null)
                            			longname += conid2conmap.get(mkc.Contact__c).FirstName;
                        
                        			// Set the second part of the Long Name (<Last Name>)   
                        			if (conid2conmap.get(mkc.Contact__c).LastName != null)
                            			longname += ' ' + conid2conmap.get(mkc.Contact__c).LastName;
                        
                        			// Add a seperator ( - ) to the Name
                        			longname +=  ' - ';
                    			}
                    
                    			// If the MKC has an associated Membership, and that Membership has a Program whose Acronym is not Null then add the Program Acronym to the new Name
                    			if (mkc.Membership__c != null && memid2memmap.get(mkc.Membership__c).Program__c != null && memid2memmap.get(mkc.Membership__c).Program__r.Program_Acronym__c != null) 
                        			longname += memid2memmap.get(mkc.Membership__c).Program__r.Program_Acronym__c;
                    
                    			// If the MKC has a Role, then add a separator then the Role to the new Name
                    			if (mkc.Role__c != null)
                        			longname += ' - ' + mkc.Role__c;
                    
                    			// Perform field truncation to ensure the new name does not go over the max length of the Name field (should be max 80)
                    			mkc.name = longname.substring(0,Math.min(maxnamelength, longname.length()));
                    		}
            		}
        	}
            	//===========================Modified by Mahendra Swarnakar -02/27/2020 - CR-20200217-13758 - End Here===========================
            }
        }
		
        //Added By - Neha Sharma - 4/28/2022 - CR-20210520-15169
		if(Trigger.isBefore){
			if(Trigger.isInsert || Trigger.isUpdate){
				MembershipKeyContactTriggerHelper.checkForSingleMembershipKeyContactRelatedToMembership(trigger.new, trigger.oldMap);
			}
		}
        
    //Catching DML Exceptions
    } catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));

    //Catching all Exceptions
    } catch(Exception e) {
        
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}