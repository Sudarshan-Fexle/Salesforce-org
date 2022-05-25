/**
 *  Description     :   Helper class for NBB object trigger.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   11/15/2013
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20130517-3034
                        V_1.1 - Code modified - Ajit Surana - Modified(populateSharingOnNBB) - CR-20140201-4430
						V_1.2 - Modified By - Mahendra Swarnkar - 06/10/2015 - CR-20150416-8891 - Method modified (populateSharingOnNBB , createOrUpdateNBBSharing)
						V_1.3 - Manual Merged - Rajeev Jain - 11/20/2015 - CR-20151118-9395 - Manual merged changes from ProjADev to Test Sandbox as changes was done in projA Deve By Coling McGloain
						V_1.4 - modified by - Mahendra Swarnkar -02/03/2016 - CR-20151028-9361 - updated "createOrUpdateNBBSharing" method to remove the query inside the for loop.
						V_1.5 - Modified By - Mahendra Swarnakar - 10/21/2016 - CR-20160202-9576 
						V_1.6 - Modified By - MAhendra Swarnkar - Issue--CR11597--QA--00007152 (CR-20170928-11597) - 10/26/2017
						V_1.7 - Modified By - Subhash Garhwal - Issue--CR11597--QA--00007275 - populateSharingOnNBB method - Change logic to share with only same entity user.
						V_1.8 - Modified By - Subhash Garhwal - 01/30/2018 - CR-20180126-11902 - createOrUpdateNBBSharing method
						
 **/
public without sharing class NBBTriggerHelper {

    /**
     *  @description    :   This method is used for populate NBB Share records on NBB in specific cases:
     *                          1. If Institution Team Role is LIKE '%RM' OR 'EA%' OR '%AE' AND Team Role NOT LIKE '%marketer%'. If the team member meets
     *                              these criteria and there isn't an existing manual sharing record for this User and NBB record, create the
     *                              manual sharing record.
                                2. If Institution Team member is either deleted or role has been modified so it doesn't fit in the #1 criteria, 
                                    then delete the manual sharing rule.
     *
     *  @param          :   Trigger.new, Trigger.oldMap
     *
     *  @return         :    
     **/
     //Modified By - Mahendra Swarnakar - 10/21/2016 - CR-20160202-9576 
     //Modified By - Subhash Garhwal - Issue--CR11597--QA--00007275 - Change logic to share with only same entity user.
     public static void populateSharingOnNBB(List<NBB__c> newNBBs, Map<Id, NBB__c> oldMapNBBs) {

        //Set to hold Account's Name of NBB record
        Set<Id> opportunityIds = new Set<Id>();

        //Loop through Trigger.new
        for(NBB__c nBB : newNBBs) {

            //Check if NBB's Opportunity is not null
            if(nBB.Opportunity__c != null)
                opportunityIds.add(nBB.Opportunity__c);
        }

        //Map to hold the opportunity Ids with the relevant Account Id.
        //Key => Opportunity.Id, Value =: Opportunity.AccountId
        Map<Id, Id> mapOpportunityWithAccountId = new Map<Id, Id>();

        //Check for size of set
        if(opportunityIds.size() > 0) {

            //List of Opportunity
            for(Opportunity opp : [SELECT AccountId FROM Opportunity 
                                   	WHERE Id IN : opportunityIds AND AccountId != null])
				mapOpportunityWithAccountId.put(opp.Id, opp.AccountId);
            
            //Check accountIds size
            if(mapOpportunityWithAccountId.size() > 0) {

                //Updated by Mahendra Swarnkar - 06/10/2015 - CR-20150416-8891
                //build SOQL's where clause criteria from custom setting.
				//Fetch the Configuration Manager records where Parameter Key  = ‘TeamMemberRoleForNBBSharing’
				//Build the dynamic SOQL query for AccountTeamMembers
                //Starts from here
                
                //Map to hold Key = AccountId & Value = List of Account Team Member for creating Sharing
                Map<Id, List<AccountTeamMember>> mapAccountWithATMs  = new Map<Id, List<AccountTeamMember>>();
                
                //Map to hold Key = AccountId & Value = List of associated staff Assignment
                Map<Id, List<Team_Membership__c>> mapAccountWithStaffAssignments  = new Map<Id, List<Team_Membership__c>>();
                
                //Query through Configuration Manager 
                List<Configuration_Manager__c> configManager = [SELECT Id , Parameter_Key__c , Parameter_Value__c 
                                                                	FROM Configuration_Manager__c 
                                                                	WHERE Parameter_Key__c != null 
                                                                		AND Parameter_Key__c = 'TeamMemberRoleForNBBSharing'];
                
                //Set to hold the account Ids
                Set<Id> setAccIds = new Set<Id>();
                
                //Add all account Ids from the map
                setAccIds.addAll(mapOpportunityWithAccountId.values());
                
                //SOQL where clause
                //Check for size
                if(configManager != null && configManager.size() > 0) {
                    
                	//Building dynamic SOQL
                	//Subhash Garhwal - 11/01/2017 - Added Entity field
                	String soql = 'SELECT Id, UserId, User.Entity__c, TeamMemberRole, AccountId FROM AccountTeamMember WHERE AccountId != null AND AccountId IN : setAccIds';

                    soql += ' AND (';

                    //Loop through Configuration Managers 
                    for(Configuration_Manager__c cMgr : configManager) {
						
                        //Variable to hold parameter value
						String parameterValue = cMgr.Parameter_Value__c;                   
                        
                        //Check parameter value for null and empty
                        if(!String.isBlank(parameterValue))
                        	soql += ' TeamMemberRole LIKE \'' + parameterValue  + '\' OR';
                    }
                    
                    //Trim the query string 
                    soql.trim();
                    
                    //Remove extra 'OR' in the query string   
                    soql = soql.removeEnd('OR');
                    
                    //Remove extra '(' in the query
                    if(soql.endsWith('AND ('))
                        soql = soql.removeEnd('(') + 'User.IsActive = true ';
					else
                        soql += ' ) AND User.IsActive = true ';
                    
                    //Debug for query string 
                    system.debug('soql :::::'+soql);
                    
                    //Updated by Ajit Surana -03/1/2014 - CR-20140201-4430  
                    //Update SOQL Query for AccountTeamMembers where User.IsActive = true
                    //Query all the ATM related to these account records related to specific roles
                    //These users will get the Read access on relevant NBB records
                    for(AccountTeamMember accTeamMember : Database.query(soql)) {
    
                        //Check if AccountId is already in KeySet of mapAccountWithATMs
                        if(mapAccountWithATMs.containsKey(accTeamMember.AccountId))
    						mapAccountWithATMs.get(accTeamMember.AccountId).add(accTeamMember);
                        else
    						mapAccountWithATMs.put(accTeamMember.AccountId, new List<AccountTeamMember>{accTeamMember});
                    }
				}
                //Modified By - MAhendra Swarnkar - Issue--CR11597--QA--00007152 (CR-20170928-11597) - 10/26/2017 - Modified Query's where condition so that it doesn't auto-generate the manual sharing for those Staff Assignments where the Role End is less than Today
                //Modified By - Mahendra Swarnakar - 10/21/2016 - CR-20160202-9576 
                //Removed "Role__r.Incentivized__c != null AND Role__r.Incentivized__c = true " from query
                //Query through Staff Assignment records 
                for(Team_Membership__c sfA : [SELECT Id, Employee__c, Staff_member__c, Institution__c FROM Team_Membership__c 
                                              	WHERE Role__c != null 
                                              	AND Institution__c != null
                                              	And Institution__c IN : mapOpportunityWithAccountId.values()
                                             	And (End_Date__c = null OR End_Date__c >=: System.today())]) {
                    
                    //Check if AccountId is already in KeySet of mapAccountWithStaffAssignments
					if(mapAccountWithStaffAssignments.containsKey(sfA.Institution__c))
    					mapAccountWithStaffAssignments.get(sfA.Institution__c).add(sfA);
                    else
    					mapAccountWithStaffAssignments.put(sfA.Institution__c, new List<Team_Membership__c>{sfA});
                }
                
                //call method to create Sharing on NBB records
                createOrUpdateNBBSharing(mapOpportunityWithAccountId, newNBBs, mapAccountWithATMs, oldMapNBBs , mapAccountWithStaffAssignments  );
       		}
        }
     }


    /**
     *  @description    :   This mehod is to take the NBB records and ATM map and will create the sharing records for them.
     *
     *  @param          :   List<NBB> , map of Account Team Member, Map<NBB>
     *
     *  @return         :
     *
     *	@Revision Log	:	V1.1 - Modified By - Subhash Garhwal - 01/30/2018 - CR-20180126-11902
     *	
     **/
    public static void createOrUpdateNBBSharing(Map<Id, Id> mapOpportunityWithAccountId, List<NBB__c> newNBBs, Map<Id, List<AccountTeamMember>> mapAccountWithATMs, Map<Id, NBB__c> oldMapNBBs , Map<Id, List<Team_Membership__c>> mapAccountWithStaffAssignments ) {

        //List of NBB Shares to be create / delete
        List<NBB__Share> nBBSharesToInsert = new List<NBB__Share>();
        List<NBB__Share> nBBSharesToDelete = new List<NBB__Share>();
        
        //Check for size of map
        if(mapAccountWithATMs != null && mapAccountWithATMs.size() > 0) {

            //Loop through NBBs
            for(NBB__c nBB : newNBBs) {

                //Get the relevant account Id from Opportunity map
                if(mapOpportunityWithAccountId != null && nBB.opportunity__c != null
                	&& !mapOpportunityWithAccountId.containskey(nBB.opportunity__c))
                    continue;

                //Get account Id from Opportunity Map
                Id accId = mapOpportunityWithAccountId.get(nBB.opportunity__c);

                //Loop through AccountTeamMembers
                if(mapAccountWithATMs.containsKey(accId) && mapAccountWithATMs.get(accId) != null) {
                    
                    //Loop through account team member records
                    for(AccountTeamMember aTM : mapAccountWithATMs.get(accId)) {
    
                        //add into list to be insert
                        //Owner doesn't need sharing
                        if(aTM.UserId != nBB.OwnerId && aTM.User.Entity__c == nBB.Entity__c) {
                            
                            //Populate NBB Sharing to insert list
                            nBBSharesToInsert.add(new NBB__Share(ParentId = nBB.Id, AccessLevel = 'Read', 
                                                                 UserOrGroupId = aTM.UserId,
                                                                 RowCause = Schema.NBB__Share.RowCause.Manual));
                        }
                    }
                }
            }
        }
        
        //Updated by Mahendra Swarnkar -05/14/2015 - CR-20150416-8891
        //Create NBB Sharing for the Staff Assignment Stamped users 
        //Starts from here
        
        //Updated by Mahendra Swarnkar -02/03/2016 - CR-20151028-9361 - to remove the query inside the for loop
        //CR-20151028-9361 - changes Starts from here 
        //Check for size of map
        if(mapAccountWithStaffAssignments != null && mapAccountWithStaffAssignments.size() > 0) {

            //Set to hold the contacts Id values associated to Staff assignments
            Set<Id> setOfStaffMembers = new Set<Id>();

            //Loop through keys of map
            for(Id tMAccId : mapAccountWithStaffAssignments.keyset()) {
                for(Team_Membership__c tm : mapAccountWithStaffAssignments.get(tMAccId)) {
                    if(tm.Staff_member__c != null)
                        setOfStaffMembers.add(tm.Staff_member__c);    
                }
            }

            //Checking set for size value
            if(setOfStaffMembers.size() > 0) {
				
				//Modified By - Subhash Garhwal - 01/30/2018 - CR-20180126-11902 - Added IsActive = true check in SOQL
                //Map of staff members
                Map<Id, Contact> mapStaffMembers = new Map<Id, Contact>([SELECT Id, Employee_User_Record__c, Employee_User_Record__r.Entity__c FROM Contact WHERE ID IN : setOfStaffMembers AND Contact_Status__c = 'Active' AND Employee_User_Record__c != null AND Employee_User_Record__r.IsActive = true]);

                //Checking map for size and null value
                if(mapStaffMembers != null && mapStaffMembers.keyset().size() > 0) {

                    //Loop through NBBs
                    for(NBB__c nBB : newNBBs) {
             
                        //Get the relevant account Id from Opportunity map
                        if(mapOpportunityWithAccountId != null && nBB.opportunity__c != null
                            && !mapOpportunityWithAccountId.containskey(nBB.opportunity__c))
                            continue;
                
                        //Get account Id from Opportunity Map
                        Id accId = mapOpportunityWithAccountId.get(nBB.opportunity__c);
                
                        //Loop through Staff Assignments
                        if(mapAccountWithStaffAssignments.containsKey(accId) 
                            && mapAccountWithStaffAssignments.get(accId) != null) {
                    
                            //Loop through staff assignment records    
                            for(Team_Membership__c sfA : mapAccountWithStaffAssignments.get(accId)) {

                                if(sfA.Staff_member__c != null 
                                    && mapStaffMembers.containsKey(sfA.Staff_member__c)
                                    && mapStaffMembers.get(sfA.Staff_member__c) != null) {
                                    
                                    //Pull through the Contact Record and Employee User Record associated
                                    Contact EmpContact = mapStaffMembers.get(sfA.Staff_member__c);
                                
                                    //add into list to be insert
                                    //Owner doesn't need sharing
                                    if(EmpContact.Employee_User_Record__c != null && EmpContact.Employee_User_Record__c != nBB.OwnerId && EmpContact.Employee_User_Record__r.Entity__c == nBB.Entity__c) {
                                        
                                        //Populate NBB Sharing to insert list
                                        nBBSharesToInsert.add(new NBB__Share(ParentId = nBB.Id, AccessLevel = 'Read', UserOrGroupId = EmpContact.Employee_User_Record__c,
                                                                   RowCause = Schema.NBB__Share.RowCause.Manual));
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        //CR-20151028-9361 - changes Ends here
        
        //Map to hold the existing sharing record with the unique key
        //Key => ParentId-UserOrGroupId, Value => sharingRecord
        Map<String, NBB__Share> mapExistingSharing = new Map<String, NBB__Share>();

        //check if trigger is running for Update and there are Manual sharing on NBB record to be deleted
        if(oldMapNBBs != null) {
                
            //Query NBB Shares and populate data in Map
            for(NBB__Share nBBShare : [SELECT UserOrGroupId, RowCause, ParentId FROM NBB__Share  
                                       WHERE ParentId IN: newNBBs AND RowCause =: Schema.NBB__Share.RowCause.Manual]) {

                //generate unique key
                String uniqueKey =  nBBShare.ParentId + '-' + nBBShare.UserOrGroupId;
                mapExistingSharing.put(uniqueKey, nBBShare);
            }

            System.debug('mapExistingSharing ::::::' + mapExistingSharing);

            //Check for size of Shares list
            if(mapExistingSharing.size() > 0) {

                //Check size of list
                if(nBBSharesToInsert.size() > 0) {

                    //Create a clone of list for iteration
                    List<NBB__Share> cloneNBBSharesToInsert = new List<NBB__Share>();
                    cloneNBBSharesToInsert.addAll(nBBSharesToInsert);

                    //Loop through Share records list to be insert
                    for(Integer i = cloneNBBSharesToInsert.size() - 1; i >= 0; i--) {

                        System.debug('cloneNBBSharesToInsert:::::' + cloneNBBSharesToInsert.size());
                        System.debug('nBBSharesToInsert:::::' + nBBSharesToInsert.size());

                        //Generate the Unique key and check
                        //If there is already a record in Sharing table for the new user, no need to insert it again
                        //if sharing table is having a record which is not in new list, mark it for deletion
                        String uniqueKey =  cloneNBBSharesToInsert[i].ParentId + '-' + cloneNBBSharesToInsert[i].UserOrGroupId;

                        //check if this is already in sharing table, leave it as it is and no need to insert it again
                        if(mapExistingSharing.containsKey(uniqueKey)) {

                            //Delete from Insertion list
                            nBBSharesToInsert.remove(i);

                            //Remove this record from exisitng Map also, so remaining records will be get deleted
                            mapExistingSharing.remove(uniqueKey);
                        }
                    }
                }
                
                // iterate through each nbb record that is still in our mapExistingSharing map and if the rowCause is Manual, add to the deletion list
                for (NBB__Share nbbShare : mapExistingSharing.values()) {
                    
                    nBBSharesToDelete.add(nbbShare);
                }
            }
        }
        
        //insert new sharing
        if(nBBSharesToInsert.size() > 0)
            insert nBBSharesToInsert;

        //delete unused ones
        if(nBBSharesToDelete.size() > 0)
            delete nBBSharesToDelete;
    }
    
}