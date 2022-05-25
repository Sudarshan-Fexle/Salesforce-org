/**
 * Purpose		:	Helper class for the Campaign Member trigger.
 * 
 * Create By		:  	Victor Hanson
 * 
 * Created Date		:   	06/24/2014
 *  
 * Revision Log		:	V1.0
 * 				V1.1 - Modified By - Colin McGloin - CR-20180220-12079 - Allowed Marketo Campaign Members to populate Primary Program from the value on the Parent Campaign
 * 				V1.2 - Modified By - Victor Hanson - CR-20190627-13200 - 08/04/2019 - if cm.Primary_Program__c is null, populate it with the Campaign's Primary Program
 * 				V1.3 - Modified By - Dipesh Gupta  - CR-20200429-14006 - 05/07/2020 (Automated email notification to PDR for hot lead)
 * 				V1.4 - Modified By - Rajeev Jain   - CR-20200917-14522 - 09/28/2020 - Add the criteria to send hot lead mail for past week
 * 				V1.5 - Modified By - Saurabh Kumar - CR-20200821-14465 - 10/28/2020 - Added a method populateRegistration
 * 				V1.6 - Modified By - Neha Sharma - CR-20210129-14857 - 03/03/2021 - Update Logic for Hot Lead Trigger
 * 				V1.7 - Modified By - Victor Hanson - CR-20210308-14971 - 03/11/2021 
 * 				V1.8 - Modified By - Saurabh Kumar - CR-20201116-14696 - 03/25/2021 - Added a method createAndPopulateRegistration();
 * 				V1.9 - Modified By - Saurabh Kumar - CR-20201116-14696 - 03/30/2021 - Added a postChatterOnStatusMismatch();
 * 				V2.0 - Modified By - Chirag Soni - CR-20210902-15405 - 09/03/2021 - Updated the Method createAndPopulateRegistration() - Added conditions to check Waitlist status and avoid the "Invited" status campaign members
 * 				V2.1 - Modified By - Chirag Soni -CR-20210526-15185 -  10/11/2021 - UAT #92 Added size check for map mapCampaignIdToRegistrations in method populateRegistration  
 **/
public class CampaignMemberTriggerHelper{
    //Modified By - Saurabh Kumar - CR-20201116-14696
    public static boolean isCreateAndPopulateRegistrationExecute = true; 
    public static final String CAMPAIGN_MEMBER_STATUS_WAITLISTED = 'Waitlisted';
    
    //Added By - Chirag Soni - CR-20210902-15405 - 09/03/2021 - Added Variables
    public static final String CAMPAIGN_MEMBER_STATUS_CANCELLED = 'Cancelled';
    public static final String CAMPAIGN_MEMBER_STATUS_INVITED = 'Invited';
    
    public static final Map<String, Decimal > MapStageNameWithOrderForCampaignMembers = new Map<String, Decimal >{'Intel' => 1,'Targeted' => 1, 'Sent' => 1, 'Visited Page' => 1, 'Sent' => 1, 'Member' => 1, 'Invited' => 1, 'Visited Page' => 2, 'Clicked Link in Email' => 2, 'Clicked Link on Page' => 2, 'Clicked Link' => 2, 'Clicked' => 2, 'Filled Out Form' => 3, 'Downloaded Associated Content' => 3, 'Took Success Step' => 3, 'Visited Booth' => 3, 'Unable to Attend' => 4, 'Canceled or Unable to Attend' => 4, 'Registered' => 5, 'Canceled' => 6, 'Registered Dinner' => 7, 'Registered Session' => 8, 'Registered Reception' => 9, 'Registered Breakout' => 10, 'Attended Dinner' => 11, 'Attended Session' => 12, 'Attended Reception' => 13, 'Attended Breakout' => 14, 'Intro' => 15, 'Requested Demo' => 15, 'Attended' => 15, 'No Show' => 16, 'Had Marketer Sitdown' => 17, 'Attended On-demand' => 17};
    
    
	/**	Developer		:	Drew Freeman
	 *  	Date			:	8/27/11
	 * 	Purpose:			To populate MA Assignment, Marketer Assignment, and Primary Program lookups on Campaign Member
	 * 					Custom field lookups cannot be imported through the Campaign Member import wizard
	 * 
	 * 	Revision Logs 		: 	V1.1 : 	Simplyforce-Bhavi[12/13/2011] - Added code to avoid the case sensitivity while comparing the usernames with
	 * 					MA Username and Marketer Username - CR-20111012-161
	 **/
        public static void PopulateCampaignMemberLookups(list<CampaignMember> campaignMemberList) {
            
            Set<String> MName = new Set<String>();
            Set<String> ProgAcro = new Set<String>();
            
            //Added by CM
            Set<Id> campaignIds = new Set<Id>();
            
            for (CampaignMember cm : campaignMemberList) {
                MName.add(cm.MA_Username__c);
                MName.add(cm.Marketer_Username__c);
                ProgAcro.add(cm.Program_Acronym__c);
                //Added by CM
                campaignIds.add(cm.CampaignId);            
            }
            
            Map<String, Id> MNameMap = new Map<String, Id>(); 
            for (User u : [select Username, Id from User where Username in :MName and isActive = true]) {
                
                //commented by Bhavi
                //MNameMap.put(u.Username, u.Id);
                
                //Bhavi - Added code to put the username in small letter in map
                MNameMap.put(u.Username.toLowerCase(), u.Id);
            }
            
            //Added by CM
            List<Campaign> campaigns = new List<Campaign>();
            Map<Id, Id> campaignToProgram = new Map<Id, Id>();
            
            //Get our Campaign Primary Program
            if (campaignIds.size() > 0){
                
                //Query for our Campaigns
                campaigns = [SELECT Id, Primary_Program__c, RecordTypeId FROM Campaign WHERE Id IN :campaignIds];
                
                //Loop through our Campaigns
                for (Campaign c : campaigns){
                    //Proceed if Primary Program is populated
                    if (c.Primary_Program__c != null){
                        //If the Campaign has not been added to the Map already, add it
                        if (campaignToProgram.get(c.Id) == null){
                            campaignToProgram.put(c.Id, c.Primary_Program__c);
                        }
                    }
                }
                
            }
            
            Map<String, Id> ProgAcroMap = new Map<String, Id>(); 
            for (Program__c p : [select Program_Acronym__c, Id from Program__c where Program_Acronym__c in :ProgAcro and Status__c = 'Active']) {
                ProgAcroMap.put(p.Program_Acronym__c, p.Id);
            }
            
            for (CampaignMember cm : campaignMemberList) {
                
                //Bhavi - Added code to avoid the case sensitivity
                if (cm.MA_Username__c != null && MNameMap.containsKey(cm.MA_Username__c.toLowerCase())) {
                    cm.MA_Assignment__c = MNameMap.get(cm.MA_Username__c.toLowerCase());
                }
                if (cm.Marketer_Username__c != null && MNameMap.containsKey(cm.Marketer_Username__c.toLowerCase())) {
                    cm.Marketer_Assignment__c = MNameMap.get(cm.Marketer_Username__c.toLowerCase());
                }
                //Upto here
                
                if (ProgAcroMap.containsKey (cm.Program_Acronym__c) && cm.Program_Acronym__c != null) {
                    cm.Primary_Program__c = ProgAcroMap.get(cm.Program_Acronym__c);
                }
                
                //Modified by VH - 08/04/2019 - Primary_Program__c is null, populate it with the Campaign's Primary Program if it's populated
                //Added by CM - Marketo Primary Program  
                //If our Campaign Member is a Marketo Campaign Member
                if (cm.RecordTypeId == Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Marketo Campaign Member').RecordTypeId
                    || cm.Primary_Program__c == null){
                        //If we have a value for the Program in the Map then populate CM Primary Program with it
                        if (campaignToProgram.get(cm.CampaignId) != null){
                            cm.Primary_Program__c = campaignToProgram.get(cm.CampaignId);
                        }
                    }
                
            }
        }
    
    /**
     * @description	:	if the campaign member has the Undeliverable flag checked, add +1 to the related contact's
     * 				# Undeliverable Mailings field.
     * 
     * @params		:	trigger.new, trigger.oldMap
     **/
    public static void updateUndeliverableMailings(list<CampaignMember> campaignMemberList, map<Id, CampaignMember> oldCampaignMemberMap) {
        
        set<Id> contactIds = new set<Id>();
        list<Contact> contactsToUpdate = new list<Contact>();
        
        for (CampaignMember cm : campaignMemberList) contactIds.add(cm.ContactId);
        map<Id, Contact> contactMap = new map<Id, Contact>([SELECT Id, Num_Undeliverable_Mailings__c FROM Contact WHERE Id IN :contactIds]);
        
        for (CampaignMember cm : campaignMemberList) {
            
            CampaignMember oldCM;
            if (oldCampaignMemberMap != null) oldCM = oldCampaignMemberMap.get(cm.Id);
            
            if ((oldCM == null && cm.Undeliverable__c) || (oldCM != null && oldCM.Undeliverable__c != cm.Undeliverable__c)) 
            {
                Contact c = contactMap.get(cm.ContactId);
                
                if (c.Num_Undeliverable_Mailings__c == null) c.Num_Undeliverable_Mailings__c = 0;
                
                if (cm.Undeliverable__c) c.Num_Undeliverable_Mailings__c++;
                else if (c.Num_Undeliverable_Mailings__c > 0) c.Num_Undeliverable_Mailings__c--;
                
                contactsToUpdate.add(c);
            }
        }
        
        if (contactsToUpdate.size() > 0) {
            util.BypassAllTriggers = true;
            update contactsToUpdate;
            util.BypassAllTriggers = false;
        }
    }
    
   /** 
    * Description     :	This Method is used To merge/delete the duplicate Campaign member records.
    *
    * Created By      :	Mahendra Swarnkar
    *
    * Created Date    :	04/19/2019
    *
    * Revision Log    :	V1.1 - Created - CR-20181130-12772
    *
    **/
    public static void mergeCampaignMember(list<CampaignMember> campaignMemberList, map<Id, CampaignMember> oldCampaignMemberMap) {
        
        //Set to hold the Campaign member Ids
        Set<Id> setCampaignMemberIds = new Set<Id>();
        
        //Set to hold the contact Ids
        Set<Id> setContactIds = new Set<Id>();
        
        //Set to Hold the Lead Ids
        Set<Id> setLeadIds = new Set<Id>();
        
        //Set to hold the Campaign Ids
        Set<Id> setCampaignIds = new Set<Id>();
        
        //Loop over the new campaign member List
        for(CampaignMember cMember : campaignMemberList) {
            
            //Check for conditions
            if(oldCampaignMemberMap == null 
               || cMember.ContactId !=  oldCampaignMemberMap.get(cMember.Id).ContactId
               || cMember.LeadId !=  oldCampaignMemberMap.get(cMember.Id).LeadId
               || cMember.CampaignId !=  oldCampaignMemberMap.get(cMember.Id).CampaignId
               || cMember.Status !=  oldCampaignMemberMap.get(cMember.Id).Status
               || cMember.Product_Lead__c  !=  oldCampaignMemberMap.get(cMember.Id).Product_Lead__c) {
                   
                   //Populate the set
                   setCampaignMemberIds.add(cMember.Id);
                   
                   //Populate the set
                   if(cMember.ContactId != null) {
                       setContactIds.add(cMember.ContactId);
                   }
                   
                   //Populate the set
                   if(cMember.LeadId != null) {
                       setLeadIds.add(cMember.LeadId);
                   }
                   
                   //Populate the set
                   if(cMember.CampaignId != null) {
                       setCampaignIds.add(cMember.CampaignId);
                   }
               }	
        }
        
        //Check for size
        if(setCampaignMemberIds.size() > 0) {
            
            //Map to hold the new Campaign Member's new list records
            Map<Id, CampaignMember> mapNewCMs = new Map<Id, CampaignMember>();
            
            //Map to hold the External Id with CM list
            Map<String, Map<Id,CampaignMember>> mapExternalIdWithListCM = new Map<String, Map<Id,CampaignMember>>();
            
            //Query over the Campaign member List
            for(CampaignMember cMember  : [Select Id, CampaignId, Status, CreatedDate, LastModifiedDate, External_Id__c, 
                                           ContactId, Contact.Counter_ID__c, LeadId, Lead.Counter_ID__c 
                                           From CampaignMember
                                           Where CampaignId != null AND CampaignId IN : setCampaignIds 
                                           AND ((ContactId != null AND ContactId IN : setContactIds) OR (LeadId != null AND LeadId IN : setLeadIds)) 
                                           ORDER BY CreatedDate ASC]){
                                               
                                               //External Id String
                                               String externalId = '';
                                               
                                               //IF(ISBLANK(ContactId),Lead.Counter_ID__c,Contact.Counter_ID__c) + "_" + CASESAFEID(Campaign.Id)
                                               
                                               //Populate the external Id 	
                                               if(cMember.ContactId != null && cMember.Contact.Counter_ID__c != null)
                                                   externalId = cMember.Contact.Counter_ID__c + '_' + cMember.CampaignId;
                                               else if(cMember.LeadId != null && cMember.Lead.Counter_ID__c != null)
                                                   externalId = cMember.Lead.Counter_ID__c + '_' + cMember.CampaignId;
                                               
                                               //Populate the external Id
                                               cMember.External_Id__c = externalId;
                                               
                                               //Poulate the map
                                               if(setCampaignMemberIds.contains(cMember.Id))
                                                   mapNewCMs.put(cMember.Id, cMember);
                                               
                                               //Populate the Map
                                               if(!mapExternalIdWithListCM.containsKey(externalId))
                                                   mapExternalIdWithListCM.put(externalId, new Map<Id,CampaignMember>());
                                               
                                               //Populate the Map	
                                               mapExternalIdWithListCM.get(externalId).put(cMember.Id, cMember);
                                           }
            
            //Map to hold the CMs to be deleted
            Map<Id, CampaignMember>  MapCMsToBeDeleted = new Map<Id, CampaignMember> ();
            
            //Map<String, CampaignMember>  MapExternalIdWithCMsToBeUpdated = new Map<String, CampaignMember> ();
            
            //Map to hold the CMs to be updated
            Map<Id, CampaignMember>  MapCMsToBeUpdate = new Map<Id, CampaignMember> ();
            
            //Check for size
            if(mapNewCMs.size() > 0 ){
                
                // Loop over the new list
                for(CampaignMember cMem : mapNewCMs.values()){
                    
                    //Hold the winning CM
                    CampaignMember winningCM = cMem;
                    
                    //External Id
                    String exId = winningCM.External_Id__c;
                    
                    //Check for condition/size
                    if(String.IsNotBlank(exId) && mapExternalIdWithListCM.containsKey(exId)
                       && mapExternalIdWithListCM.get(exId) != null 
                       && mapExternalIdWithListCM.get(exId).size() > 0
                       && mapExternalIdWithListCM.get(exId).values() != null 
                       && mapExternalIdWithListCM.get(exId).values().size() > 0){
                           
                           //Loop over the CMs with same external Id
                           for(CampaignMember CampMemb : mapExternalIdWithListCM.get(exId).values()){
                               
                               //Check for condition
                               if(cMem.Id != CampMemb.Id){
                                   
                                   //variables to holdd the stage order for the existing and current product lead
                                   Decimal winningCMStageOrder = 0;
                                   Decimal CampMembStageOrder = 0;
                                   
                                   //Get the stage order for existing PL
                                   if(MapStageNameWithOrderForCampaignMembers.containsKey(winningCM.Status))
                                       winningCMStageOrder = MapStageNameWithOrderForCampaignMembers.get(winningCM.Status);
                                   
                                   //Get the stage order for current PL	
                                   if(MapStageNameWithOrderForCampaignMembers.containsKey(CampMemb.Status))
                                       CampMembStageOrder = MapStageNameWithOrderForCampaignMembers.get(CampMemb.Status);
                                   
                                   //Compare the CMs and Identify the winning CM	
                                   if(winningCMStageOrder > CampMembStageOrder ){
                                       
                                       MapCMsToBeDeleted.put(CampMemb.Id, CampMemb);
                                       
                                   } else if(winningCMStageOrder < CampMembStageOrder){
                                       MapCMsToBeDeleted.put(winningCM.Id, winningCM);
                                       winningCM = CampMemb;
                                   } else if(winningCMStageOrder == CampMembStageOrder){
                                       
                                       if(winningCM.CreatedDate < CampMemb.CreatedDate ) {
                                           
                                           MapCMsToBeDeleted.put(CampMemb.Id, CampMemb);
                                       } else if(winningCM.CreatedDate > CampMemb.CreatedDate) {
                                           MapCMsToBeDeleted.put(winningCM.Id, winningCM);
                                           winningCM = CampMemb;
                                       } else if(winningCM.CreatedDate == CampMemb.CreatedDate){
                                           
                                           if(winningCM.LastModifiedDate > CampMemb.LastModifiedDate){
                                               MapCMsToBeDeleted.put(CampMemb.Id, CampMemb);
                                               
                                           } else if(winningCM.LastModifiedDate < CampMemb.LastModifiedDate){
                                               MapCMsToBeDeleted.put(winningCM.Id, winningCM);
                                               winningCM = CampMemb;
                                           }
                                       }
                                   }
                               }
                           }	
                       }
                    //Check for condition & Populate the map
                    if(winningCM != null)
                        MapCMsToBeUpdate.put(winningCM.Id, winningCM);
                }
            }
            
            //Bypassing the triggers and deleting/updating the List.
            Util.BypassAllTriggers = true;
            if(MapCMsToBeDeleted.size() > 0 && MapCMsToBeDeleted.values().size() > 0)
                delete MapCMsToBeDeleted.values();
            
            if(MapCMsToBeUpdate.size() > 0 && MapCMsToBeUpdate.values().size() > 0)
                update MapCMsToBeUpdate.values();
            
            Util.BypassAllTriggers = false;
        }
    }
    
   /** 
    * Description     :	This Method is used To Automated email notification to PDR for hot lead
    *
    * Created By      :	Dipesh Gupta
    *
    * Created Date    :	05/19/2020
    *
    * Revision Log    :	Created - Dipesh Gupta -05/19/2020 - CR-20200429-14006 (Automated email notification to PDR for hot lead)
    *                   Modified By Rajeev Jain -09/28/2020 - CR-20200917-14522 - Add the criteria to send hot lead mail for past week
    **/
    public static void sendMailToProductOwner(list<CampaignMember> campaignMemberList, Map<Id, CampaignMember> oldCampaignMemberMap) 
    {
        //Set to hold the Campaign member Ids
        Set<Id> setCampaignMemberIds = new Set<Id>();
        Set<Id> setProductLeadIds = new Set<Id>();
        List<CampaignMember> listOfCampaignMember = new List<CampaignMember>();
        List<Product_Lead__c> listOfProductLead = new List<Product_Lead__c>();
        Set<Id> userIds = new set<Id>();
        Map<Id,User> mapOfUsers = new Map<Id,User>();
        
        //Modified By Rajeev Jain -09/28/2020 - CR-20200917-14522 - Add the criteria to send hot lead mail for past week using Request_Demo_Mail_Date__c field
        for(CampaignMember cMember : campaignMemberList)
        {
            //Modified By - Neha Sharma - CR-20210129-14857 - 03/01/2021 - Update Logic for Hot Lead Trigger
            if((cMember.Status == 'Requested Demo' || cMember.Status == 'Requested Follow Up') && (oldCampaignMemberMap == null 
                                                                                                   || (oldCampaignMemberMap != null && oldCampaignMemberMap.get(cMember.Id).Status != cMember.Status)))
            {
                setCampaignMemberIds.add(cMember.Id);
                setProductLeadIds.add(cMember.Product_Lead__c);
            }
            else if(oldCampaignMemberMap != null && oldCampaignMemberMap.get(cMember.Id).Status != cMember.Status && (cMember.Status != 'Requested Demo' || cMember.Status != 'Requested Follow Up')){
                CampaignMember camp = new CampaignMember();
                camp.Request_Demo_Mail_Date__c = null;
                camp.Id = cMember.Id;
                listOfCampaignMember.add(camp);
            }
        }
        
        if(setCampaignMemberIds.size() > 0 && setProductLeadIds.size() > 0)
        {
            //Modified By - Neha Sharma - CR-20210129-14857 - 03/01/2021 - To hold Product Leads with it's respective campaign members list
            Map<Product_Lead__c, List<CampaignMember>> mapOfProductLeadWithCampMembers = new Map<Product_Lead__c, List<CampaignMember>>();
            
            for(Product_Lead__c pL : [SELECT Id, OwnerId, Stage__c, Owner.Email, 
                                      Program__r.Name,(Select Id,Status 
                                                       From Campaign_Members__r 
                                                       WHERE (Status =: System.Label.Requested_Demo OR Status = 'Requested Follow Up') AND Id IN: setCampaignMemberIds) 
                                      FROM Product_Lead__c 
                                      WHERE Id IN : setProductLeadIds ])
            {
                if(pL.OwnerId != System.Label.Marketo_Sync_Owner_Id && pL.Stage__c == 'AQL' || (pL.OwnerId == System.Label.Marketo_Sync_Owner_Id && pL.Stage__c == 'AQL'))
                {
                    if(pL.Campaign_Members__r.size() > 0){
                        for(CampaignMember campMem : pL.Campaign_Members__r)
                        {
                            CampaignMember camp = new CampaignMember();
                            camp.Request_Demo_Mail_Date__c = system.today();
                            camp.Id = campMem.id;
                            listOfCampaignMember.add(camp);
                            
                            // Modified By - Neha Sharma - CR-20210129-14857 - 03/01/2021 - To fill Product Leads with it's respective campaign members list
                            if(!mapOfProductLeadWithCampMembers.containsKey(pL))
                                mapOfProductLeadWithCampMembers.put(pL, new List<CampaignMember>{campMem});
                            else
                                mapOfProductLeadWithCampMembers.get(pL).add(campMem);
                        } 
                    }
                    listOfProductLead.add(pL);
                    userIds.add(pL.OwnerId);    
                }
            }
            
            if(listOfCampaignMember.size() > 0){
                update listOfCampaignMember;
            }
            
            if(userIds.size() > 0)
            {
                for(User usr : [Select id,Manager.Email,Email from user where Id IN: userIds])
                {
                    mapOfUsers.put(usr.Id,usr);
                }
            }
            //Modified By Rajeev Jain -09/28/2020 - CR-20200917-14522 - End here
            //Modified By - Neha Sharma - CR-20210129-14857 - 03/01/2021 - Update Logic for Hot Lead Trigger
            //ProductLeadTriggerHelper.sendEmail(listOfProductLead, mapOfUsers);
            ProductLeadTriggerHelper.sendEmail(mapOfProductLeadWithCampMembers, mapOfUsers);
        }
    }
    
   /** 
    * Description     :	This Method is used to populate Registration on Campaign Member.
    * 			Logic: When a Campaign Member is created where RecordType=Event Invite List Member, check if there is an EAB Event where 
    * 			EABEvent.Campaign__c = CampaignMember.CampaignId. If so, check all existing Registrations to see if the Campaign Member needs to be 
    * 			linked to the Registration record.
    *
    * Created By      :	Saurabh Kumar
    *
    * Created Date    :	10/28/2020
    *
    * Revision Log    :	V1.0 - Created - Saurabh Kumar - 10/28/2020 - CR-20200821-14465
    *			V1.1 - Modified - Chirag Soni - 10/11/2021 - CR-20210526-15185 - UAT #92 Added size check for map mapCampaignIdToRegistrations
    **/
    public static void populateRegistration(List<CampaignMember> newCampaignMembers){
        
        //Set to hold Campaign Id
        Set<Id> campaignIds = new Set<Id>();
        
        //Collection to hold EAB Events by Campaign Id
        Map<Id, List<Advisory_Event__c>> mapOfEABEventsByCampaignId = new Map<Id, List<Advisory_Event__c>>();
        
        //Get Record Type Id
        String campaignMemberRecordTypeId = Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Event Invite List Member').RecordTypeId;
            
        for(CampaignMember cm : newCampaignMembers){
            
            if(cm.RecordTypeId == campaignMemberRecordTypeId && cm.CampaignId != null)
                campaignIds.add(cm.CampaignId);
        }
        
        if(campaignIds.size() == 0)
            return;
        //Query on EAB Event using Campaing Id
        for(Advisory_Event__c eabEvent : [Select Id, Invite_List__c From Advisory_Event__c Where Invite_List__c != null AND
                                         Invite_List__c IN : campaignIds]){
            if(!mapOfEABEventsByCampaignId.containsKey(eabEvent.Invite_List__c))
                mapOfEABEventsByCampaignId.put(eabEvent.Invite_List__c, new List<Advisory_Event__c>());
            
            mapOfEABEventsByCampaignId.get(eabEvent.Invite_List__c).add(eabEvent);
        }

        //03/11/2021 - CR-20210308-14971 - Victor Hanson - added map so we can remove subquery - changes start here
        Map<Id, List<Registration__c>> mapCampaignIdToRegistrations = new Map<Id, List<Registration__c>>();
        for (Registration__c reg : [SELECT Id, Contact__c, EAB_Event__r.Invite_List__c FROM Registration__c WHERE EAB_Event__r.Invite_List__c IN :campaignIds]) {
            if (!mapCampaignIdToRegistrations.containsKey(reg.EAB_Event__r.Invite_List__c)) {
                mapCampaignIdToRegistrations.put(reg.EAB_Event__r.Invite_List__c, new List<Registration__c>());
            }
            mapCampaignIdToRegistrations.get(reg.EAB_Event__r.Invite_List__c).add(reg);
        }
        
        if(mapOfEABEventsByCampaignId.size() == 0)
            return;
        
        //Modified By - Chirag Soni - 10/11/2021 - CR-20210526-15185 - UAT #92 Added size check for map mapCampaignIdToRegistrations
        if(mapCampaignIdToRegistrations.size() > 0)
        {     
            //Block to populate Registration
            for(CampaignMember cm : newCampaignMembers){
                
                if(cm.RecordTypeId != campaignMemberRecordTypeId || cm.CampaignId == null || !mapOfEABEventsByCampaignId.containsKey(cm.CampaignId) || 
                   mapCampaignIdToRegistrations.get(cm.CampaignId).size() == 0)
                    continue;
                for(Registration__c reg : mapCampaignIdToRegistrations.get(cm.CampaignId)){
                    
                    Boolean isRegistrationAssigned = false;
                    
                    if(reg.Contact__c == cm.ContactId){
                        cm.Registration__c = reg.Id;
                        isRegistrationAssigned = true;
                        break;
                    }                 	
                    if(isRegistrationAssigned)
                        break;
                }
            }
        }
        //03/11/2021 - CR-20210308-14971 - Victor Hanson - added map so we can remove subquery - changes end here
    }
    
   /**
    *	Description     :	This Method is used create registration if not exist and populate Registration on campaign member.
    *                     	Logic : When a Campaign Member's Status is updated to one of the values [Registration Requested', 
    *				'Waitlist', 'No Show', 'Attended] and the related Campaign is associated with an EAB Event (via the Marketo Campaign field), 
    *				'Registered', Create a new Registration on that EAB Event for the Contact if a Registration doesn't already exist. Also,
    *				populate the CampaignMember.Registration__c field with the Registration.Id
    *
    * Created By      	:	Saurabh Kumar
    *
    * Created Date    	:	03/25/2021
    *
    * Revision Log    	:	V1.0 - Created - Saurabh Kumar - 03/25/2021 - CR-20201116-14696
    *		       	:   	V1.1 - Modified - Chirag Soni - 06/16/2021 - CR-20201116-14696 - MRS2.0 QA/UAT Issues #59
    *		        :   	V1.2 - Modified - Chirag Soni - 01/20/2022 - CR-20220120-15728 - Added try catch to get blank contact reg error in webservice logs
    *               :       V1.3 - Modified - Chirag Soni - 05/11/2022 - CR-20220429-16152 - Refactor the code in order to improve CPU time limit SOQL limit exception.
    **/
    public static void createAndPopulateRegistration(List<CampaignMember> newCampaignMembers, Map<Id, CampaignMember> oldCampaignMemberMap){
        
        // map to hold list of campaign member on campaign id 
        Map<Id, List<CampaignMember>> mapOfCampaignMemberByCampaignId = new Map<Id, List<CampaignMember>>();
        // set to hold contact Ids 
        Set<Id> contactIds = new Set<Id>();
        
        try //Modified - Chirag Soni - 01/20/2022 - CR-20220120-15728 - Added
        {
            for(CampaignMember cm : newCampaignMembers)
            {
                if(cm.Status != CAMPAIGN_MEMBER_STATUS_INVITED && cm.CampaignId != null && cm.ContactId != null && (oldCampaignMemberMap == null || 
                                                                                                                    cm.Status != oldCampaignMemberMap.get(cm.id).Status ||
                                                                                                                    cm.CampaignId != oldCampaignMemberMap.get(cm.id).CampaignId ||
                                                                                                                    cm.ContactId != oldCampaignMemberMap.get(cm.id).ContactId))
                {
                    if(Constants.CAMPAIGN_MEMBER_STATUSES.contains(cm.Status))
                    {
                        //---add contact ids---// 
                        contactIds.add(cm.ContactId);
                        
                        // fill map with campaign members over campaign Id
                        if(!(mapOfCampaignMemberByCampaignId.containsKey(cm.CampaignId)))
                            mapOfCampaignMemberByCampaignId.put(cm.CampaignId, new List<CampaignMember>());
                        
                        mapOfCampaignMemberByCampaignId.get(cm.CampaignId).add(cm);
                    }
                }
            }
            
            if(!mapOfCampaignMemberByCampaignId.keySet().isEmpty())
            {
                //status for eab event 
                Set<String> eabEventCompletedStatus = new Set<String>{Constants.STATUS_CLOSED_COMPLETED, Constants.STATUS_CLOSED_CANCELLED};
                    
                    // map to hold List of EAB Event by Campaign Id
                    Map<Id, Advisory_Event__c> mapOfEABEventByCampaignId = new Map<Id,  Advisory_Event__c>();
                // List to hold EAB Event
                List<Advisory_Event__c> eabEventsList = new List<Advisory_Event__c>();
                
               for(Advisory_Event__c eabEvent : [SELECT Id, Name, Marketo_Campaign__c, Status__c  FROM Advisory_Event__c 
                                                  WHERE Marketo_Campaign__c IN : mapOfCampaignMemberByCampaignId.keySet()
                                                  AND Status__c NOT IN :(eabEventCompletedStatus)])  
                {
                    mapOfEABEventByCampaignId.put(eabEvent.Marketo_Campaign__c, eabEvent);
                    eabEventsList.add(eabEvent);
                }
                
                if(mapOfEABEventByCampaignId.size()>0  && !contactIds.isEmpty())
                {
                    // get list of exisiting registration on EAB Event.
                    List<Registration__c> listOfExistingRegistraions = Util.getExistingRegistrationOrCampaignMember(eabEventsList, contactIds);
                    
                    // map to hold Existing Registration on contact id
                    Map<Id, Registration__c> mapOfRegistrationByContactIdToUpsert = new Map<Id, Registration__c>();
                    //-----------------------check if existing registrations are found ------------------------------------------------------//
                    if(listOfExistingRegistraions != null && !listOfExistingRegistraions.isEmpty())
                    {
                        for(CampaignMember cm : newCampaignMembers)
                        {
                            //Modified By -  Chirag Soni - CR-20210902-15405 - 09/03/2021 - Added a condition to avoid Invited status record
                            if(cm.Status != CAMPAIGN_MEMBER_STATUS_INVITED)
                            {
                                for(Registration__c registration : listOfExistingRegistraions)
                                {
                                    if(cm.ContactId == registration.Contact__c)  
                                    {
                                        //Added By -  Chirag Soni - CR-20210902-15405 - 09/14/2021 - Added a new variable to hold cancellation Reason
                                        String registrationStatus, declinedReason, cancellationReason;
                                        
                                        // if EAB Status is waitlist then registration status should be waitlist 
                                        if(cm.Status == CAMPAIGN_MEMBER_STATUS_WAITLISTED){
                                            declinedReason = Constants.REGISTRATION_WAITLIST_DECLINED_REASON_EVENT_REG_CAPACITY;
                                        }
                                        //Added By -  Chirag Soni - CR-20210902-15405 - 09/14/2021 - populate cancellation reason if campaign member status is cancelled
                                        else if(cm.Status == CAMPAIGN_MEMBER_STATUS_CANCELLED){
                                            cancellationReason = Constants.REGISTRATION_CANCELLATION_REASON;
                                        }    
                                        else{
                                            declinedReason = '';
                                            cancellationReason = '';//Modified by -  Chirag Soni -  CR-20210902-15405 - 09/14/2021 - Added Cancellation reason field
                                        }
                                        //Modified by -  Chirag Soni -  CR-20210902-15405 - 09/14/2021 - Added Cancellation reason field
                                        mapOfRegistrationByContactIdToUpsert.put(registration.Contact__c,  new Registration__c(
                                            Id = registration.Id,
                                            Status__c = cm.Status == CAMPAIGN_MEMBER_STATUS_WAITLISTED ? 'Waitlist':cm.Status,
                                            Declined_Reason__c = declinedReason,
                                            Cancellation_Reason__c = cancellationReason));
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    ////-----------------------Codition for remaining campaign members whose registrations are not found------------------------------------------------------//
                    if(mapOfRegistrationByContactIdToUpsert.size() < newCampaignMembers.size())
                    {
                        for(CampaignMember cm : newCampaignMembers)
                        {
                            //Modified By -  Chirag Soni - CR-20210902-15405 - 09/03/2021 - Added a condition to avoid Invited status record
                            if(!(mapOfRegistrationByContactIdToUpsert.containsKey(cm.ContactId)) && (cm.Status != CAMPAIGN_MEMBER_STATUS_INVITED)){
                                
                                String registrationStatus;
                                
                                // if EAB Status is waitlist then registration status should be waitlist 
                                if(mapOfEABEventByCampaignId.get(cm.CampaignId).Status__c == Constants.EAB_EVENT_STATUS_OPEN_WAITLIST_ONLY ){
                                    registrationStatus = Constants.REGISTRATION_STATUS_WAITLIST;
                                }else{
                                    //Modified By - Chirag Soni - 09/03/2021 - CR-20210902-15405 - Added the ternary condition to check Waitlist status and update Registration status
                                    registrationStatus = (cm.Status == CAMPAIGN_MEMBER_STATUS_WAITLISTED ? 'Waitlist':cm.Status);
                                }
                                
                                mapOfRegistrationByContactIdToUpsert.put(cm.ContactId ,new Registration__c(Contact__c = cm.ContactId, 
                                                                                                           Status__c = registrationStatus, 
                                                                                                           EAB_Event__c = mapOfEABEventByCampaignId.get(cm.CampaignId).Id));
                            }
                        }
                    }
                    //--- update registrations ---//
                    if(mapOfRegistrationByContactIdToUpsert.values().size() == newCampaignMembers.size())
                    {
                        RegistrationHelper.isCreateAndPopulateCampaignMemberStatusExecute = false;
                        upsert mapOfRegistrationByContactIdToUpsert.values();
                        RegistrationHelper.isCreateAndPopulateCampaignMemberStatusExecute = true;           
                    }
                    Map<Id, CampaignMember> mapOfCampaignMembersOnIds = new Map<Id, CampaignMember>();
                    // populate Registraion Id on Campaign Members
                    for(CampaignMember cm : newCampaignMembers){
                        
                        if(mapOfRegistrationByContactIdToUpsert.containsKey(cm.ContactId))
                            mapOfCampaignMembersOnIds.put(cm.Id, new CampaignMember(Id = cm.Id, Registration__c = mapOfRegistrationByContactIdToUpsert.get(cm.ContactId).Id));
                    }
                    if(!mapOfCampaignMembersOnIds.values().isEmpty())
                    {
                        Util.BypassAllTriggers = true;
                        update mapOfCampaignMembersOnIds.values();
                        Util.BypassAllTriggers = false;
                    }   
                }
            }
        }Catch(Exception ex){ //Modified - Chirag Soni - 01/20/2022 - CR-20220120-15728 - Added
            
            //set to hold campaign ids
            Set<Id> campaignIds = new Set<Id>();
            
            for(CampaignMember cm : newCampaignMembers){
                
                if(String.isNotBlank(cm.CampaignId)){
                    campaignIds.add(cm.CampaignId);
                }
            }
            //list of web service logs to be insert for exceptions
            List<Web_Service_Log__c> exceptionalWebServiceLogs = new List<Web_Service_Log__c>();
            // Web service log record type id.
            Id wslEabEventRTId =  Schema.SObjectType.Web_Service_Log__c.getRecordTypeInfosByName().get('EAB Event').getRecordTypeId();
            
            if(campaignIds.size()>0){
                
                for(Advisory_Event__c eabEvent : [SELECT Id FROM Advisory_Event__c WHERE Marketo_Campaign__c IN :campaignIds])
                {
                    // create web service logs on event 
                    exceptionalWebServiceLogs.add(new Web_Service_Log__c(RecordTypeId = wslEabEventRTId,
                                                                         EAB_Event__c = eabEvent.Id,
                                                                         Web_Service_Method__c = 'createAndPopulateRegistration',
                                                                         Request_Sent__c = system.now(),
                                                                         Request_Message_Log__c = ex.getMessage(),
                                                                         Response_Message_Log__c = ex.getMessage()+'\n'+ex.getStackTraceString()));
                }
            }else{
                // create web service logs on event 
                exceptionalWebServiceLogs.add(new Web_Service_Log__c(RecordTypeId = wslEabEventRTId,
                                                                     Web_Service_Method__c = 'createAndPopulateRegistration',
                                                                     Request_Sent__c = system.now(),
                                                                     Request_Message_Log__c = ex.getMessage(),
                                                                     Response_Message_Log__c = ex.getMessage()+'\n'+ex.getStackTraceString()));
                
            }
            // check size of wsl list 
            if(exceptionalWebServiceLogs.size()>0)
            {
                Util.ByPassAllTriggers = true;
                insert exceptionalWebServiceLogs;
                Util.ByPassAllTriggers = false;
            }
        }
    }       
    
   /** 
    * Description     :	This method is used to post chatter when registration status is updated
    * 			Login 1 : When a Registration's Status is Update and it's related to a Marketo Campaign Member
    * 			OR a Marketo Campaign Member's Status is updated and it's related to a Registration record:
    * 			if the Status value cannot be synchronized to the corresponding record because it doesn't meet the rules mentioned above, post a chatter.
    * 			Basically, we should be able to include logic in the afterUpdate portion of trigger to check if the corresponding record's Status was 
    * 			updated to match the EABEvent or CampaignMember where Status changed. If the values don't match because the update didn't occur due to not meeting the criteria mentioned above:
    * 			Chatter should @mention the EABEvent's Event Manager and the Campaign's Demand Generation Manager (Campaign.OwnerId)
    * 
    * Created By      :	Saurabh Kumar
    *
    * Created Date    :	03/30/2021
    *
    * Revision Log    :	V1.0 - Created - Saurabh Kumar - 03/30/2021 - CR-20201116-14696
    *
    **/
    public static void postChatterOnStatusMismatch(List<CampaignMember> newCampaignMembers, Map<Id, CampaignMember> oldCampaignMemberMap){
        
        //Set to hold Contact Ids
        Set<Id> contactIds = new Set<Id>();
        
        // Map to hold CampaignMember on Campaign Ids
        Map<Id, List<CampaignMember>> mapOfCampaignMembersOnCampaignIds = new  Map<Id, List<CampaignMember>>();
        
        for(CampaignMember campaignMember : newCampaignMembers)
        {
            if(campaignMember.Status != oldCampaignMemberMap.get(campaignMember.Id).Status &&
               String.isNotBlank(campaignMember.ContactId) &&
               String.isNotBlank(campaignMember.CampaignId)){
                   
                   if(!(mapOfCampaignMembersOnCampaignIds.containsKey(campaignMember.CampaignId))){
                       mapOfCampaignMembersOnCampaignIds.put(campaignMember.CampaignId, new List<CampaignMember>());
                   }
                   mapOfCampaignMembersOnCampaignIds.get(campaignMember.CampaignId).add(campaignMember);
                   contactIds.add(campaignMember.ContactId);
               }
        }
        if(mapOfCampaignMembersOnCampaignIds.size() == 0){
            return;
        }
        
        // map of campaign Id and Owner Id
        Map<Id, Id> mapOfCampaignIdAndOwnerId = new Map<Id, Id>();
        
        for(Campaign campaign : [SELECT Id, OwnerId FROM Campaign WHERE Id IN :mapOfCampaignMembersOnCampaignIds.keySet()]){
            mapOfCampaignIdAndOwnerId.put(campaign.Id, campaign.OwnerId);
        }
        
        // Map to hold EAB Event on Ids
        //Map<Id, Advisory_Event__c> mapOfEabEventsOnId = new   Map<Id, Advisory_Event__c>([SELECT Id, Marketo_Campaign__c, Event_Manager__c FROM Advisory_Event__c WHERE 
        //                                                                                Marketo_Campaign__c IN :mapOfCampaignMembersOnCampaignIds.keySet()]);
        if(mapOfCampaignIdAndOwnerId.size() == 0)
            return;
        // set to hold user id for mention user in chatter post
        Set<Id> userIdsToPostChatter = new Set<Id>();
        for(Registration__c registraion : [SELECT Id, Contact__c, Status__c, EAB_Event__c, EAB_Event__r.Marketo_Campaign__c, EAB_Event__r.Event_Manager__c  FROM Registration__c
                                           WHERE Contact__c IN :contactIds OR EAB_Event__r.Marketo_Campaign__c IN :mapOfCampaignIdAndOwnerId.keySet()]) {
            
             if(registraion.EAB_Event__r.Marketo_Campaign__c == null || !mapOfCampaignMembersOnCampaignIds.containsKey(registraion.EAB_Event__r.Marketo_Campaign__c))
                continue;
             for(CampaignMember campaignMember : mapOfCampaignMembersOnCampaignIds.get(registraion.EAB_Event__r.Marketo_Campaign__c)){
                 
             	if(registraion.Contact__c == campaignMember.ContactId && registraion.Status__c != campaignMember.Status){
                    
                    // get event manger id from eab event id
                    if(String.isNotBlank(registraion.EAB_Event__r.Event_Manager__c)) 
                    	userIdsToPostChatter.add(registraion.EAB_Event__r.Event_Manager__c);
                    
                    //get campaign owner id from campaign id
                    userIdsToPostChatter.add(mapOfCampaignIdAndOwnerId.get(campaignMember.CampaignId));
                }
            }
        }
        if(userIdsToPostChatter.size()>0){
            List<Id> userIds = new List<Id>();
            userIds.addAll(userIdsToPostChatter);
            //post chatter and mention user in it
            if(!Test.isRunningTest())
                ConnectApi.FeedItem feed = ChatterHelper.PostChatterFeedItem(ConnectApi.FeedType.News,'me', Label.MESSAGE_REGISTRATION_CAMPAIGN_MEMBER_STATUS_MISMATCH , userIds); 
        }
    }
}