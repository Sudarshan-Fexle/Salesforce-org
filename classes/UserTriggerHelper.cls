/*
    Purpose         :   This class is helper class for trigger on User object.
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   01/18/2012
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.1 Created
                        V_1.2 - Modified By - Bhavi Sharma - 06/14/2013 - CR-20130411-2851
                        V_1.3 - Modified By - Ajit Surana  - Added new method (updateOwnerManagerEmailOnOpportunities) -  04/19/2014 - CR-20140403-4951
                        V_1.4 - Modified By - Victor Hanson - Added new method (deactivateInactiveCommunityUsers) -  05/20/2014 - CR-4283
                        V_1.5 - Modified By - Jason Bennett - Added 3 new methods - populateUserInfoOffice,populateUserInfoDept,populateUserInfoWorkspace - 09/19/2014 - CR-6887
                        V_1.6 - Modified By - Bhavi Sharma - 01/23/2015 - Added new method - deactivateCreditCardsForInactiveUsers - CR-20141209-8273
                        V_1.7 - Modified By - Ajit Surana - 04/29/2015 - CR-20150112-8537 - Added a new method (updateCTAssignmentManagerEmailOnOpportunities) 
                        V_1.8 - Modified By - Abhinav Sharma - 08/25/2015 - CR-20150820-9167 - Added a new method - (doUpdateOnOpportunitiesOnUserUpdate)
                        V_1.9 - Modified By - Victor Hanson - 11/06/2015 - CR-20150427-8909 - updated method - (updateOwnerManagerEmailOnOpportunities)
                        V_2.0 - Modified By - Mahendra Swarnakar - 10/10/2016 - CR-20160426-9797 - Added a new method - (updateRestrictionClearanceRequestRecords)
                        V_2.1 - Modified By - Abhinav Sharma - DS114 - 06/02/2017 - Added "updateMembershipRecordsFieldsValues" method
                        V_2.2 - Modified By - Mahendra Swarnkar - 10/09/2017 - CR-20170928-11552 - Apollo Release - Added new methods "updateChildObjectsEntityField" and "updateChildObjectsEntityFieldofUser"
                        V_2.3 - Modified By - Mahendra Swarnkar - 10/09/2017 - CR-20170928-11558 - Apollo Release (User child = Member Support )
                        V_2.4 - Modified By - Mahendra Swarnkar - 10/11/2017 - CR-20170929-11624 - Apollo Release (User child = Opportunity )
                        V_2.5 - Modified By - Subhash Garhwal - 01/30/2018 - CR-20180126-11902 - Added a new method deactivateStaffAssignmentForInactiveUsers
                        V_2.6 - Modified By - Subhash Garhwal - CR-20180126-11912 - 02/05/2018 - Added a new Method - populateCTManagerEmailOnSubPeriod
                        V_2.7 - Modified By - Colin McGloin - 02/01/2018 - CR-20180125-11899 - Added method to check for insert or update and sync Workspace data from the Employee Contact record
                        V_2.8 - Modified By - Victor Hanson - 04/09/2018 - CR-20170918-11373 - Removed doUpdateOnOpportunitiesOnUserUpdate
                        V_2.9 - modified By - Rajeev Jain - CR-20190123-12845 - 02/05/2018 new method setContractTypeFree
                        V_3.0 - Modified By - Mahendra SwarnKar - 05/01/2019 - Commented the code in "syncUserWorkspaceFieldsFromContact" method as per Spring Clean up - CR-20190501-13061
                        V_3.1 - Modified By - Dipesh Gupta - 04/15/2020 - Update Code for UserTriggerHelper
                        V_3.2 - Modified By - Rajeev Jain - CR-20200714-14300 - 04/12/2021 - to replace hard coded profiles names, contract types via labels
			V_3.3 - Modified By - Ayush Gupta - CR-20210422-15098 - 06/14/2021
    			V_3.4 - Modified By - Nikita Kumari - 02/04/2022 - CR-20220128-15759 - Slack API - Use the users.lookupByEmail method to populate User.Slack_Id__c
                        V_3.5 - Modified By - Nikita Kumari - 08/03/2022 - CR-20220217-15921 - Boardroom Sunsetting Changes
*/
public without sharing class UserTriggerHelper {
    
    public final static string RTName_Office = 'Settings_Office';
    public final static string DEFAULT_OFFICE_CODE = 'DC';
    
    //Added By - Abhinav Sharma - 06/02/2017 - DS114
    public static void updateMembershipRecordsFieldsValues(List<User> users, Map<Id, User> mapOldUsers) 
    {
        Map<Id, User> mapOfUsers = new Map<Id, User>();
        for(User user : users) 
        {
            if(mapOldUsers.get(user.Id).FirstName != user.Firstname
               ||
               mapOldUsers.get(user.Id).LastName != user.Lastname
              ) 
            {
                mapOfUsers.put(user.Id, user);    
            }
        }
        if(mapOfUsers.size() > 0) 
        {
            Map<Id, Membership__c> mapOfMemberships = new Map<Id, Membership__c>();
            for(Membership__c membership : [Select Id, BA_Text__c, BA_Assignment2__c 
                                            FROM Membership__c 
                                            WHERE BA_Assignment2__c != null 
                                            AND BA_Assignment2__c IN : mapOfUsers.keySet()]) 
            {
                String bAAssignmentUsername = '';
                if(String.isNotBlank(mapOfUsers.get(membership.BA_Assignment2__c).FirstName))                           
                    bAAssignmentUsername += mapOfUsers.get(membership.BA_Assignment2__c).FirstName + ' ';
                                                
                bAAssignmentUsername += mapOfUsers.get(membership.BA_Assignment2__c).LastName;
                
                if(bAAssignmentUsername != membership.BA_Text__c) 
                {
                    membership.BA_Text__c = bAAssignmentUsername;
                    mapOfMemberships.put(membership.Id, membership);
                }
            }
            
            for(Membership__c membership : [Select Id, DA_Assignment_Text__c, DA_Assignment2__c 
                                            FROM Membership__c 
                                            WHERE DA_Assignment2__c != null 
                                            AND DA_Assignment2__c IN : mapOfUsers.keySet()]) 
            {
                String dAAssignmentUsername = '';
                if(String.isNotBlank(mapOfUsers.get(membership.DA_Assignment2__c).FirstName))
                    dAAssignmentUsername += mapOfUsers.get(membership.DA_Assignment2__c).FirstName + ' ';
                                                
                dAAssignmentUsername += mapOfUsers.get(membership.DA_Assignment2__c).LastName;
                
                if(dAAssignmentUsername != membership.DA_Assignment_Text__c) 
                {
                    if(!mapOfMemberships.containsKey(membership.Id)) 
                    {
                        membership.DA_Assignment_Text__c = dAAssignmentUsername;
                        mapOfMemberships.put(membership.Id, membership);        
                    } 
                    else 
                    {
                        mapOfMemberships.get(membership.Id).DA_Assignment_Text__c = dAAssignmentUsername;    
                    }
                }
            }
            
            Map<Id, Opportunity> mapOfOpportunities = new Map<Id, Opportunity>();
            for(Opportunity opp : [Select Id, Owner_Name__c, OwnerId 
                                            FROM Opportunity 
                                            WHERE OwnerId != null 
                                            AND OwnerId IN : mapOfUsers.keySet()]) 
            {
                String ownerNameStr = '';
                if(String.isNotBlank(mapOfUsers.get(opp.OwnerId).FirstName))                           
                    ownerNameStr += mapOfUsers.get(opp.OwnerId).FirstName + ' ';
                                                
                ownerNameStr += mapOfUsers.get(opp.OwnerId).LastName;
                
                if(ownerNameStr != opp.Owner_Name__c) 
                {
                    opp.Owner_Name__c = ownerNameStr;
                    mapOfOpportunities.put(opp.Id, opp);
                }
            }
            if(mapOfMemberships.values().size() > 0) 
            {
                Util.BypassAllTriggers = true;
                update mapOfMemberships.values();
                Util.BypassAllTriggers = false;
            }
            if(mapOfOpportunities.values().size() > 0) 
            {
                Util.BypassAllTriggers = true;
                update mapOfOpportunities.values();
                Util.BypassAllTriggers = false;
            }
        }        
    }
    
    //Added By - Abhinav Sharma - 06/06/2017 - DS114
    public static void updateProjectRecordsFieldsValues(List<User> users, Map<Id, User> mapOldUsers) 
    {
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        Map<Id, User> mapOfUsers = new Map<Id, User>();
        for(User user : users) 
        {
            if(mapOldUsers.get(user.Id).Alias != user.Alias)
                mapOfUsers.put(user.Id, user);
        }
        if(mapOfUsers.size() > 0) 
        {
            Map<Id, Project__c> mapOfProjects = new Map<Id, Project__c>();
            //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
            /* for(Project__c proj : [SELECT ID, Primary_Owner__c, Implementation_Business_Analyst__c
                                   FROM Project__c
                                   WHERE Implementation_Business_Analyst__c != null
                                   AND  Implementation_Business_Analyst__c IN : mapOfUsers.keySet()]) 
            {
                
                //Checking for the field value differences and populating collection accoridngly
                if(proj.Primary_Owner__c != mapOfUsers.get(proj.Implementation_Business_Analyst__c).Alias) 
                {
                    proj.Primary_Owner__c = mapOfUsers.get(proj.Implementation_Business_Analyst__c).Alias;
                    mapOfProjects.put(proj.Id, proj);
                } 
                else 
                {
                    if(String.isNotBlank(proj.Primary_Owner__c)) 
                    {
                        proj.Primary_Owner__c = '';
                        mapOfProjects.put(proj.Id, proj);
                    }
                }
            }
            
            if(mapOfProjects.values().size() > 0) 
            {
                Util.BypassAllTriggers = true;
                update mapOfProjects.values();
                Util.BypassAllTriggers = false;
            }*/     
        }
    }
    
    //Added By - Abhinav Sharma - 06/07/2017 - DS114
    public static void updateSubscriptionRecordsFieldsValues(List<User> users, Map<Id, User> mapOldUsers) 
    {
        Map<Id, User> mapOfUsers = new Map<Id, User>();
        for(User user : users) 
        {
            if(mapOldUsers.get(user.Id).FirstName != user.Firstname
               ||
               mapOldUsers.get(user.Id).LastName != user.Lastname
              ) 
            {
                mapOfUsers.put(user.Id, user);
            }
        }
        if(mapOfUsers.size() > 0) 
        {
            Map<Id, SBQQ__Subscription__c> mapOfSubscriptions = new Map<Id, SBQQ__Subscription__c>();
            for(SBQQ__Subscription__c sub : [Select Id, Renewal_Opportunity__c, 
                                             Renewal_Opportunity_Owner_Name__c,
                                             Renewal_Opportunity__r.OwnerId,
                                             Renewal_Opportunity__r.Owner.Name
                                             FROM SBQQ__Subscription__c 
                                             WHERE Renewal_Opportunity__c != null
                                             AND Renewal_Opportunity__r.OwnerId != null
                                             AND Renewal_Opportunity__r.OwnerId IN : mapOfUsers.keySet()]) 
            {
                String ownerName = '';
                if(String.isNotBlank(mapOfUsers.get(sub.Renewal_Opportunity__r.OwnerId).FirstName))                           
                    ownerName += mapOfUsers.get(sub.Renewal_Opportunity__r.OwnerId).FirstName + ' ';
                
                ownerName += mapOfUsers.get(sub.Renewal_Opportunity__r.OwnerId).LastName;
                
                if(ownerName != sub.Renewal_Opportunity_Owner_Name__c) 
                {
                    sub.Renewal_Opportunity_Owner_Name__c = ownerName;
                    mapOfSubscriptions.put(sub.Id, sub);
                }
            }
            
            Map<Id, Contract__c> mapOfContracts = new Map<Id, Contract__c>();
            for(Contract__c con : [Select Id, Renewal_Opp_Owner__c, 
                                   Contract_Renewal_Opportunity__c,
                                   Contract_Renewal_Opportunity__r.OwnerId,
                                   Contract_Renewal_Opportunity__r.Owner.Name
                                   FROM Contract__c 
                                   WHERE Contract_Renewal_Opportunity__c != null
                                   AND Contract_Renewal_Opportunity__r.OwnerId != null
                                   AND Contract_Renewal_Opportunity__r.OwnerId IN : mapOfUsers.keySet()]) 
            {
                String oppOwnername = '';
                if(String.isNotBlank(mapOfUsers.get(con.Contract_Renewal_Opportunity__r.OwnerId).FirstName))
                    oppOwnername += mapOfUsers.get(con.Contract_Renewal_Opportunity__r.OwnerId).FirstName + ' ';
                
                oppOwnername += mapOfUsers.get(con.Contract_Renewal_Opportunity__r.OwnerId).LastName;
                
                if(oppOwnername != con.Renewal_Opp_Owner__c) 
                {
                    con.Renewal_Opp_Owner__c = oppOwnername;
                    mapOfContracts.put(con.Id, con);        
                }
            }
            
            if(mapOfSubscriptions.values().size() > 0) 
            {
                Util.BypassAllTriggers = true;
                update mapOfSubscriptions.values();
                Util.BypassAllTriggers = false;
            }
            
            if(mapOfContracts.values().size() > 0) 
            {
                Util.BypassAllTriggers = true;
                update mapOfContracts.values();
                Util.BypassAllTriggers = false;
            }
        }        
    }
    
    //This method is to update the Owner Associate field on membership records when associate gets 
    //update for a user record
    public static void updateMembershipRecords(Map<Id, User> usersOldMap, Map<Id, User> usersNewMap) 
    {
        Map<Id, User> mapUser = new Map<Id, User>();
        for(User user : usersNewMap.values()) 
        {
            if(usersOldMap.get(user.Id).Associate__c != user.Associate__c) 
            {
                mapUser.put(user.Id, user);
            }
        }
        
        if(mapUser.size() > 0) 
        {
            //Added by Bhavi Sharma - 06/14/2013 - CR-20130411-2851
            Batch_UpdateMembershipOwnerAssociate batchToUpdate = new Batch_UpdateMembershipOwnerAssociate(mapUser);
            Database.executeBatch(batchToUpdate, 200);
        }
    }
    
    //Added by Ajit Surana - 04/19/2014 - CR-20140403-4951
    //VH Updated 11/06/2015 - CR-20150427-8909
    public static void updateOwnerManagerEmailOnOpportunities(List<User> newUsers, Map<Id, User> mapOldUsers) 
    {
        Set<Id> setOwnerUsers = new Set<Id>();
        //Set<Id> setOppIds = new Set<Id>();
        for(User usr : newUsers) 
        {
            if(mapOldUsers.get(usr.Id) != null && usr.IsActive == true 
               && mapOldUsers.get(usr.Id).ManagerId != usr.ManagerId) 
            {
                setOwnerUsers.add(usr.Id);
            }
        }
        if(setOwnerUsers.size() > 0) 
        {
            Batch_OpportunityUpdateManagerEmail oppUpdateManagerBatch = new Batch_OpportunityUpdateManagerEmail(setOwnerUsers);
            if(!Test.isRunningTest())
                database.executeBatch(oppUpdateManagerBatch, 1);
            return; 
        }
    }
    
    //This method will going to populate the email of Manager field on CT Assignment user detail page into the new "CT Assignment's Manager" 
    public static void updateCTAssignmentManagerEmailOnOpportunities(List<User> newUsers, Map<Id, User> mapOldUsers)
    {
        Set<Id> setOwnerUsers = new Set<Id>();
        for(User usr : newUsers)
        {
            if(mapOldUsers != null && mapOldUsers.get(usr.Id) != null && usr.IsActive == true
               && mapOldUsers.get(usr.Id).ManagerId != usr.ManagerId)
            {
                setOwnerUsers.add(usr.Id);
            }
        }
        if(setOwnerUsers.size() > 0) 
        {
            Batch_OppUpdateCTAssManagerEmailData oppUpdateCTAsstManagerBatch = new Batch_OppUpdateCTAssManagerEmailData(setOwnerUsers);
            if(!Test.isRunningTest())
                database.executeBatch(oppUpdateCTAsstManagerBatch, 1);
            return; 
        }
    }
    
    public static list<User> deactivateInactiveCommunityUsers(list<User> communityUsers) 
    {
        list<User> usersToDeactivate = new list<User>();
        map<Id, User> contactIdToUserMap = new map<Id, User>();
        for (User u : communityUsers) if (u.ContactId != null) contactIdToUserMap.put(u.ContactId, u);
        list<AggregateResult> openCases_AR = [SELECT Id, ContactId FROM Case 
                                              WHERE IsClosed = false AND ContactId IN :contactIdToUserMap.keySet()
                                              GROUP BY ContactId, Id];
        list<AggregateResult> activeProjectRoles_AR = [SELECT Id, Contact__c FROM Project_Role__c 
                                                    WHERE SIAM_Portal_Status__c = 'Active' AND Contact__c IN :contactIdToUserMap.keySet()
                                                    GROUP BY Contact__c, Id];
        map<Id, set<Id>> contactIdToActiveItems = new map<Id, Set<Id>>();
        for (Id cId : contactIdToUserMap.keySet()) 
        {
            contactIdToActiveItems.put(cId, new set<Id>());
        }
        
        //add open cases to active items
        for (AggregateResult ar : openCases_AR) 
        {
            set<Id> idSet = contactIdToActiveItems.get((string) ar.get('ContactId'));
            if (idSet == null) idSet = new set<Id>();
            
            idSet.add((string) ar.get('Id'));
            contactIdToActiveItems.put((string) ar.get('ContactId'), idSet);
        }
        
        for (AggregateResult ar : activeProjectRoles_AR) 
        {
            set<Id> idSet = contactIdToActiveItems.get((string) ar.get('Contact__c'));
            if (idSet == null) idSet = new set<Id>();
            
            idSet.add((string) ar.get('Id'));
            contactIdToActiveItems.put((string) ar.get('Contact__c'), idSet);
        }
        
        for (User u : communityUsers) 
        {
            //if the number of active items for this user's contact is 0, deactivate them
            if (contactIdToActiveItems.get(u.ContactId) == null || contactIdToActiveItems.get(u.ContactId).size() == 0) 
            {
                u.IsActive = false;
                usersToDeactivate.add(u);
            }
        }
        return usersToDeactivate;
    }
    
    //This method is to check if the User in being inserted or Updated(Cost Center Changes), 
    //then populate the values from Custom Setting
    public static void updateCostCenterRelatedData(List<User> newUsers, Map<Id, User> mapOldUsers)  
    {
        Set<String> setCostCenters = new Set<String>();
        for(User user : newUsers) 
        {
            if(String.isNotBlank(user.Cost_Center__c) 
                &&  (mapOldUsers == null || user.Cost_Center__c != mapOldUsers.get(user.Id).Cost_Center__c)) 
            {
                setCostCenters.add(user.Cost_Center__c);
            }
        }
        if(setCostCenters.size() > 0) 
        {
            Map<String, Department_Division_Function__c> mapDDF = Util.getDepartmentDivisionFunctionByCostCenter(setCostCenters);
            for(User user : newUsers) 
            {
                if(String.isNotBlank(user.Cost_Center__c) 
                    && (mapOldUsers == null || user.Cost_Center__c != mapOldUsers.get(user.Id).Cost_Center__c)
                    && mapDDF.containsKey(user.Cost_Center__c)) 
                {
                    //Depratment division function
                    if(mapDDF.keySet().contains(user.Cost_Center__c))
                    {
                        Department_Division_Function__c dDF = mapDDF.get(user.Cost_Center__c);
                        
                        //Set Values
                        user.ABC_Department__c = dDF.Intranet_Department__c;
                        user.ABC_Division__c  = dDF.Intranet_Division__c;
                        user.ABC_Function__c = dDF.Intranet_Function__c;
                    }
                }
            }
        }
    }
    
    //This method is to update several User fields based on the Location_Code__c, 
    //which is updated by an integration with Workday.
    public static void populateUserInfoOffice(List<User> updatedUsers, map<Id,User> oldUserRec)
    {
        //If the Location_Code__c field values change...
        List<User> usersToUpdateOffice = new list<User>();
        Set<Id> userIds = new set<Id>();
        
        for(User u1 : updatedUsers)
        {
            if(u1.Id != null && u1.Location_Code__c != oldUserRec.get(u1.Id).Location_Code__c)
            {
                usersToUpdateOffice.add(u1);
                userIds.add(u1.Id);
            }
        }
        //Commented By - Nikita Kumari - 08/03/2022 - CR-20220217-15921 - Boardroom Sunsetting Changes - Starts from here
        /*map<String,Id> Offices = new map<String,Id>();
        for(Intranet_Item__c o : [select id, Location_Code__c from Intranet_Item__c 
                                  where RecordType.DeveloperName = :RTName_Office 
                                  and Active_Status__c = 'Active' order by Office_Short_Name__c])
        {
            if(o.Location_Code__c != null && o.Location_Code__c != '')
            {
                Offices.put(o.Location_Code__c,o.Id);
            }
        }*/
        //Commented By - Nikita Kumari - 08/03/2022 - CR-20220217-15921 - Boardroom Sunsetting Changes - Ends from here

        for(User u2 : usersToUpdateOffice)
        {
            if(u2.Location_Code__c == null || u2.Location_Code__c == '')
            {
                u2.Location_Code__c = DEFAULT_OFFICE_CODE;
            }
            //Commented By - Nikita Kumari - 08/03/2022 - CR-20220217-15921 - Boardroom Sunsetting Changes
            /*if(Offices.containsKey(u2.Location_Code__c)){
                u2.Office__c = Offices.get(u2.Location_Code__c);
            }*/
        }
    }
    
    //Added by Colin McGloin - 08/08/2016 - CR-20150112-9762
    public static void checkForOrCreateApproverRecord(List<User> users) 
    {
        List<Id> allUserIds = new List<Id>();
        for (User usr : users)
        {
            allUserIds.add(usr.Id);
        }
        if (allUserIds.size() > 0)
        {
            checkForOrCreateApproverRecordFuture(allUserIds);
        }
        
    }

    //Added by Colin McGloin - 08/08/2016 - CR-20150112-9762
    //This method will insert a Steelbrick Approver record for the user when they are inserted
    @future
    public static void checkForOrCreateApproverRecordFuture(List<Id> users) 
    {
        List<sbaa__Approver__c> newApprovers = new List<sbaa__Approver__c>();

        for (User nUser : [SELECT Id, Name, UserType, IsActive FROM User WHERE Id IN :Users])
        {
            if(nUser.UserType == 'Standard')
            {
                //Add an Approver record if the new User is a Standard user
                sbaa__Approver__c newApp = new sbaa__Approver__c (sbaa__User__c = nUser.Id, Name = nUser.Name);
                newApprovers.add(newApp);
            }
        }
        
        if (newApprovers.size() > 0)
        {
            insert newApprovers;
        }
    }
    
    //Check to see if the Approver User is also the Owner.  
    //If not, try to assign them as the owner so they can modify Delegate fields
    public static void checkApproverOwner(map<Id, User> userMap) 
    {
        list<SBAA__Approver__c> approversToUpdate = new list<SBAA__Approver__c>();
        map<Id, SBAA__Approver__c> approverMap = new map<Id, SBAA__Approver__c>([SELECT Id, sbaa__User__c, 
                                                                                 OwnerId FROM SBAA__Approver__c 
                                                                                 WHERE sbaa__User__c IN :userMap.keySet()]);
        map<Id, SBAA__Approver__c> userIdToApproverMap = new map<Id, SBAA__Approver__c>();
        
        for (SBAA__Approver__c approver : approverMap.values()) 
        {
            User u = userMap.get(approver.sbaa__User__c);
            if (u.IsActive) 
            {
                //if the approver owner isn't the same as the approver user, add to our map
                if (approver.OwnerId != approver.sbaa__User__c)
                    userIdToApproverMap.put(approver.sbaa__User__c, approver);
            }
        }
        
        if (userIdToApproverMap.size() > 0) 
        {
            for (SBAA__Approver__c approver : userIdToApproverMap.values()) 
            {
                approver.OwnerId = approver.sbaa__User__c;
                approversToUpdate.add(approver);
            }
            
            if (approversToUpdate.size() > 0)
                database.update(approversToUpdate, false);
        }
    }
    
    //Added By - Mahendra Swarnakar - 10/10/2016 - CR-20160426-9797
    //Method use to fire blank update over Restriction Clearance Requested records to Update Record Name.
    public static void updateRestrictionClearanceRequestRecords(List<User> newUsers, Map<Id, User> mapOldUsers) 
    {
        List<Id> setUserIds = new List<Id>();
        for(User us : newUsers)
        {
            if(us.FirstName != mapOldUsers.get(us.Id).FirstName 
               || us.LastName != mapOldUsers.get(us.Id).LastName
            )
            {
                setUserIds.add(us.Id);
                   
            }
        }
        List<Restriction_Clearance_Request__c> rCRsToUpdate = new List<Restriction_Clearance_Request__c>();
        if(setUserIds.size() > 0)
        {
            rCRsToUpdate = [Select Id From Restriction_Clearance_Request__c 
                            Where Marketer__c != null
                            AND Marketer__c IN: setUserIds];
        }
        if(rCRsToUpdate.size() > 0)
            update rCRsToUpdate;
    }
    
    //Created - Subhash Garhwal - 01/30/2018 - CR-20180126-11902
    //Add a method to the UserTriggerHelper class that checks for Users being Deactivated.  
    //For each user that is deactivated, check for Staff Assignment Records for those Contacts where End Date = null.  
    //Set the End Date = today on any Staff Assignment records where End Date is null and the user is being deactivated.
    public static void deactivateStaffAssignmentForInactiveUsers(List<User> users, Map<Id, User> mapOldUsers) 
    {
        Set<Id> setInActiveUsers = new Set<Id>();
        for(User user : users) 
        {
            if(user.IsActive ==  false && mapOldUsers.get(user.Id).IsActive == true) 
            {
                setInActiveUsers.add(user.Id);
            }
        }

        //Modified By - Dipesh Gupta - 04/15/2020 - Update Code for UserTriggerHelper 
        deactivateStaffAssignmentForInactiveUsersFuture(setInActiveUsers);

    }
    
    //Modified By - Dipesh Gupta - 04/15/2020 - Update Code for UserTriggerHelper 
    @future
    private static void deactivateStaffAssignmentForInactiveUsersFuture(Set<Id> setInActiveUsers) 
    {
        if(setInActiveUsers.size() > 0) 
        {
            List<Team_Membership__c> staffAssignmentsToUpdate = [SELECT Id, End_Date__c FROM Team_Membership__c 
                                                                 WHERE Staff_member__r.Employee_User_Record__c IN : setInActiveUsers 
                                                                 AND End_Date__c = null];
            if(staffAssignmentsToUpdate.size() > 0) 
            {
                for (Team_Membership__c staffAssignment : staffAssignmentsToUpdate)
                    staffAssignment.End_Date__c = Date.today();
                
                Util.bypassAllTriggers = true;
                update staffAssignmentsToUpdate;
                    Util.bypassAllTriggers = false;
            }
        }
    }
    
    //V1.0 - Created - Subhash Garhwal - CR-20180126-11912 - 02/05/2018
    //This Method is used to update the Subscription Period CT Assignemnt User's Manger Email 
    //Field when ever a User's Manager's email changed
    public static void populateCTManagerEmailOnSubPeriod(List<User> users, map<Id, User> mapOldUser) 
    {
        map<Id, String> mapUserWithManagerEmail = new map<Id, String>();
        List<Subscription_Period__c> sPeriodToBeUpdated = new List<Subscription_Period__c>();
        for(User usr : users) 
        {
            if(mapOldUser != null && mapOldUser.get(usr.Id).ManagerId != usr.ManagerId)
                mapUserWithManagerEmail.put(usr.Id, '');
        }   
        if(mapUserWithManagerEmail.size() > 0) 
        {
            for(User usrr : [Select Id,  Manager.Email From User 
                             Where Id IN : mapUserWithManagerEmail.keySet()]) 
            {
                if(mapUserWithManagerEmail.containsKey(usrr.Id) && String.isNotBlank(usrr.Manager.Email))
                    mapUserWithManagerEmail.put(usrr.Id, usrr.Manager.Email);
            }
            
            for(Subscription_Period__c sPeriod : [Select Id, CT_Assignment__c, CT_Assignment_s_Manager_Email__c,  
                                                  Program_Subscription__r.OwnerId, Owner_Manager_Email__c 
                                                  From Subscription_Period__c
                                                  Where CT_Assignment__c IN: mapUserWithManagerEmail.keySet() 
                                                  OR Program_Subscription__r.OwnerId IN: mapUserWithManagerEmail.keySet()]) 
            {
                if(
                    (mapUserWithManagerEmail.containskey(sPeriod.CT_Assignment__c) 
                    && String.isNotBlank(mapUserWithManagerEmail.get(sPeriod.CT_Assignment__c)))
                    ||
                    (mapUserWithManagerEmail.containskey(sPeriod.Program_Subscription__r.OwnerId) 
                        && String.isNOtBlank(mapUserWithManagerEmail.get(sPeriod.Program_Subscription__r.OwnerId)))
                ) 
                {
                    if(mapUserWithManagerEmail.containsKey(sPeriod.CT_Assignment__c))
                        sPeriod.CT_Assignment_s_Manager_Email__c = mapUserWithManagerEmail.get(sPeriod.CT_Assignment__c);
                        
                    if(mapUserWithManagerEmail.containsKey(sPeriod.Program_Subscription__r.OwnerId))
                        sPeriod.Owner_Manager_Email__c = mapUserWithManagerEmail.get(sPeriod.Program_Subscription__r.OwnerId);
                        
                    sPeriodToBeUpdated.add(new Subscription_Period__c (Id = sPeriod.Id,
                                                                       CT_Assignment_s_Manager_Email__c = sPeriod.CT_Assignment_s_Manager_Email__c,
                                                                       Owner_Manager_Email__c = sPeriod.Owner_Manager_Email__c ));
                }
            }
            if(sPeriodToBeUpdated.size() > 0) 
            {
                util.BypassAllTriggers = true;
                if(sPeriodToBeUpdated.size() > Limits.getLimitDMLRows())
                    Database.executeBatch(new Batch_SperiodAssignMangerNOwnerManEmail(mapUserWithManagerEmail.keySet()), 200);
                else
                    update sPeriodToBeUpdated;  
                util.BypassAllTriggers = false;
            }
        }
    }
    
    /*
     * Modified By : Rajeev Jain 04/17/2019 
     * to remove the references of Credit Crad object fields
     * This method is to mark all the Active Created cards deactivated whenever a related 
     * user in marked as InActive in Salesforce
    public static void deactivateCreditCardsForInactiveUsers(List<User> users, Map<Id, User> mapOldUsers) {
        
        //Loop through the users records and createa set of AnActive users
        Set<Id> usersInActive = new Set<Id>();
        
        for(User user : users) {
            
            //Chekc if the user was Active aearlier and now marked has been InActive
            if(user.IsActive ==  false && mapOldUsers.get(user.Id).IsActive == true) {
                
                //Add in Set
                usersInActive.add(user.Id);
            }
        }
        
        //Check for the set size and fetch the related cards
        if(usersInActive.size() > 0) {
            
            //Resord Type Credit Card request
            List<RecordType> recordTypeOSRCreditCardRequest =[Select Id from RecordType where SObjectType = 'OSR__c' 
                                                            AND DeveloperName =: CreditCardConstants.OSR_RECORD_TYPE_DEVELOPER_NAME_CREDIT_CARD_REQUEST 
                                                            AND IsActive = true limit 1];
            
            ///List of OSRs to be created
            List<OSR__c> oSRs = new List<OSR__c>();
            
            //Map of portfolios to be deactivated
            Map<Id, Portfolio__c> mapPortfolios = new Map<Id, Portfolio__c>();
            
            //Fetch the related card records from Credit Card
            for(Credit_Card__c creditCard : [Select Id, Payment_Account__c, Payment_Account__r.Card_Holder__c from Credit_Card__c where Payment_Account__r.Card_Holder__r.Employee_User_Record__c IN: usersInActive]) {
                
                //Create a separate OSR record for each Card deactivation.
                //Creating an OSR will execute the OSRT trigger and then trigger will execute the Batch_ProcessOSRs to handle teh deactivation request
                oSRs.add(new OSR__c(Origin__c = CreditCardConstants.OSR_ORIGIN_TRAVEL_PORTAL, RecordTypeId = recordTypeOSRCreditCardRequest[0].Id, 
                                Request_Type__c = CreditCardConstants.OSR_REQUEST_TYPE_DEACTIVATE_ABC_CREDIT_CARD, Status__c = CreditCardConstants.OSR_STATUS_NEW, 
                                Related_Card__c = creditCard.Id, Contact__c = creditCard.Payment_Account__r.Card_Holder__c));
                
                //Add in Map to mark the Portfolio InActive
                //Updated by Mahendra Swarnakar - CR-20150901-9211 - 9/9/2015
                mapPortfolios.put(creditCard.Payment_Account__c, new Portfolio__c(Id = creditCard.Payment_Account__c, Status__c = CreditCardConstants.PORTFOLIO_STATUS_DEACTIVATED, Deactivation_Reason__c = CreditCardConstants.EMPLOYEE_NO_LONGER_EXISTS));
            }
            
            //Scheduled class
            Scheduler_DeactiveRelatedCards sched = new Scheduler_DeactiveRelatedCards();
            sched.oSRs = oSRs;
            sched.portfolios = mapPortfolios.values();
            
            //CRON_EXP 
            String day = string.valueOf(system.now().day());
            String month = string.valueOf(system.now().month());
            String hour = string.valueOf(system.now().hour());
            String minute = string.valueOf(system.now().minute() + 1);
            String second = string.valueOf(system.now().second());
            String year = string.valueOf(system.now().year());
        
            String strJobName = 'Job-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
            String CRON_EXP = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
            System.schedule(strJobName, CRON_EXP, sched);
        }
    }
    */
    
    //V1.0 - Created - Colin McGloin - 02/08/2018 - CR-20180125-11899
    //V1.1 - Modified By - Mahendra SwarnKar - 05/01/2019 - Commented the class as per Spring Clean up - CR-20190501-13061  
    //Add a method to the UserTriggerHelper class that syncs the Workspace fields on User from the related Contact Record
    public static void syncUserWorkspaceFieldsFromContact (List<User> users, Map<Id, User> mapOldUsers)
    {
       /* 
        //Set for storing our Counter IDs for querying our Contact Records
        Set<String> userCounterIds = new Set<String>();
        
        //Map for linking Counter ID to Contact
        Map<String, Contact> mapCounterToContact = new Map<String, Contact>();
        
        //Loop through our initial records
        for (User userRecord : users){
            
            //Check for insert scenario 
            if (mapOldUsers == null && userRecord.Employee_Contact_RecordID__c != null){
                userCounterIds.add(userRecord.Employee_Contact_RecordID__c);
            }
            
            //Check for update scenario
            if (mapOldUsers != null && userRecord.Employee_Contact_RecordID__c != mapOldUsers.get(userRecord.Id).Employee_Contact_RecordID__c){
                userCounterIds.add(userRecord.Employee_Contact_RecordID__c);
            }  
        }
        
        //Check to see if our Set is populated
        if (userCounterIds.size() > 0){
            
            //Query for our Employee Contact records and necessary values
            List<Contact> userContacts = [SELECT Id, Employee_User_Record__c, Counter_ID__c, Workspace__c, Workspace__r.Name, Workspace__r.Floor__c , Workspace__r.Workspace_Type__c , 
                                            Workspace_Location__c, Workspace_Location__r.Name FROM Contact WHERE Counter_ID__c IN :userCounterIds AND Employee_User_Record__c != NULL];
            
            //If we have Employee records to work with then let's proceed
            if(userContacts.size() > 0){
                
                //Loop through User Contacts
                for (Contact con : userContacts){
                    
                    //Add the Counter ID and the Contact to the Map
                    if (con.Counter_ID__c != null){
                        mapCounterToContact.put(con.Counter_ID__c, con);
                    }
                    
                }
                
            }
            
            //Loop through our User Records again
            for (User userRec : users) {
                
                //Check the Map for our Counter ID and Contact record
                if (mapCounterToContact.get(userRec.Employee_Contact_RecordID__c) != null){
                    //If we have a Contact for the value then grab it
                    Contact con = mapCounterToContact.get(userRec.Employee_Contact_RecordID__c);
                    
                    //Check for Workspace value and populate if necessary
                    if (con.Workspace__c !=null){
                        userRec.EAB_Workspace__c = con.Workspace__r.Name;
                    }
                    
                    //Check for Workspace Location value and populate if necessary
                    if (con.Workspace_Location__c != null){
                        userRec.EAB_Workspace_Location__c = con.Workspace_Location__r.Name;
                    }
                    
                    //Check for Workspace Floor value and populate if necessary
                    if (con.Workspace__r.Floor__c != null){
                        userRec.EAB_Workspace_Floor__c = con.Workspace__r.Floor__c;
                    }
                    
                    //Check for Workspace Type value and populate if necessary
                    if (con.Workspace__r.Workspace_Type__c != null){
                        userRec.EAB_Workspace_Type__c = con.Workspace__r.Workspace_Type__c;
                    }
                } else {
                    
                    //If there is no Contact Record for the User then we set the fields to blank
                    userRec.EAB_Workspace__c = '';
                    userRec.EAB_Workspace_Location__c = '';
                    userRec.EAB_Workspace_Floor__c = '';
                    userRec.EAB_Workspace_Type__c = '';
                    
                }
                
            }
            
        }
        */
    }
    /**
     *  @description    :   If the owner leaves the firm, this should be automatically be changed to their manager.
     *
     *  @args           :   List<User>() , Map<Id, User>()
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created - Mahendra Swarnkar - CR-20200316-13858 - 03/30/2020
     **/
    public static void updateAccountFieldVendorInvoiceOwner(List<User> users ,Map<Id, User> mapOldUsers){
        
        //Map of user id with manager id
        Map<Id, Id> mapUserIdWithManagerId = new Map<Id, Id>();
        
        for(User usr : users){
            
            //Insert and Update case
            if(usr.IsActive == false && (mapOldUsers == null || usr.IsActive != mapOldUsers.get(usr.Id).IsActive)){
                mapUserIdWithManagerId.put(usr.Id, usr.ManagerId);
            }
        }
        
        if(mapUserIdWithManagerId.size() > 0){
            updateAccountFieldVendorInvoiceOwnerFuture(mapUserIdWithManagerId);
        }
        
        
    }
    
    @future
    public static void updateAccountFieldVendorInvoiceOwnerFuture(Map<Id,Id> mapUserIdWithManagerId ){
        
        //Check size
        if(mapUserIdWithManagerId != null && mapUserIdWithManagerId.size() > 0){
            
            //List of account to update
            List<Account> accountToUpdate = new List<Account>();
            
            //Loop over account queried whose Field: Vendor_Invoice_Owner__c is the user from the map keyset. 
            for(Account acc : [Select Id, Vendor_Invoice_Owner__c From Account Where Vendor_Invoice_Owner__c IN: mapUserIdWithManagerId.keySet()]){
                if(mapUserIdWithManagerId.containsKey(acc.Vendor_Invoice_Owner__c) && mapUserIdWithManagerId.get(acc.Vendor_Invoice_Owner__c) != null){
                    
                    Account ac = new Account(Id = acc.Id);
                    ac.Vendor_Invoice_Owner__c = mapUserIdWithManagerId.get(acc.Vendor_Invoice_Owner__c);
                    
                    accountToUpdate.add(ac);
                }
            }
                 
            //Size check
            if(accountToUpdate.size() > 0){
                //Update
                update accountToUpdate;
            }
        }
    }
    
    //V1.0 - Created - Rajeev Jain - CR-20190123-12845 - 02/05/2018
    //V1.1 - Modified BY Seemu Saikia - 03/14/2019 - CR NO.CR-20190305-12912
    //When a user with below profiles is going to be created/updated then set the contract type 
    //field with the value  "Free".
    //Modified by Dipesh Gupta - CR-20200206-13707 - Commented the logic which sets free on the contract type.
    //Modified By - Rajeev Jain - CR-20200714-14300 - 04/12/2021 - to replace hard coded profiles names, contract types via labels 
    public static void setContractType(List<User> users, map<Id, User> mapOldUser) 
    {   
        Set<String> setAppSubscriptionRestrictedProfiles = getSetOfProfilesNames(System.Label.App_Subscription_Restricted_Profiles);
        Set<String> setAppSubscrtionProfiles = getSetOfProfilesNames(System.Label.App_Subscription_Profiles);
        Set<String> setRestrictedProfiles = getSetOfProfilesNames(System.Label.Restricted_Profiles);
        Set<String> setPlatformProfiles = getSetOfProfilesNames(System.Label.Platform_Profiles);
        Set<String> setGuestProfiles = getSetOfProfilesNames(System.Label.Guest_Profiles);
        Set<String> setPortalProfiles = getSetOfProfilesNames(System.Label.Portal_Profiles);
        Set<String> setChatterFreeProfiles = getSetOfProfilesNames(System.Label.Chatter_Free_Profiles);
        Set<String> setChatterOnlyProfiles = getSetOfProfilesNames(System.Label.Chatter_Only_Profiles);
                                
        Map<Id, Profile> mapOfProfiles = new Map<Id, Profile> ([Select Id , Name from Profile where 
                                                                Name IN: setAppSubscriptionRestrictedProfiles OR 
                                                                Name IN: setAppSubscrtionProfiles OR
                                                                Name IN: setRestrictedProfiles OR
                                                                Name IN: setPlatformProfiles OR
                                                                Name IN: setGuestProfiles OR
                                                                Name IN: setPortalProfiles OR
                                                                Name IN: setChatterFreeProfiles OR
                                                                Name IN: setChatterOnlyProfiles]);
        for(User usr: users)
        {
            if(mapOfProfiles.containsKey(usr.profileId))
            {
                if(setAppSubscriptionRestrictedProfiles.contains(mapOfProfiles.get(usr.profileId).Name))
                    usr.Contract_Type__c = System.Label.Contract_Type_App_Subscription_Restricted;  
                else if(setAppSubscrtionProfiles.contains(mapOfProfiles.get(usr.profileId).Name))
                    usr.Contract_Type__c = System.Label.Contract_Type_App_Subscription;
                else if(setRestrictedProfiles.contains(mapOfProfiles.get(usr.profileId).Name))
                    usr.Contract_Type__c = System.Label.Contract_Type_Restricted;
                else if(setPlatformProfiles.contains(mapOfProfiles.get(usr.profileId).Name))
                    usr.Contract_Type__c = System.Label.Contract_Type_Platform;
                else if(setGuestProfiles.contains(mapOfProfiles.get(usr.profileId).Name))
                    usr.Contract_Type__c = System.Label.Contract_Type_Guest;
                else if(setPortalProfiles.contains(mapOfProfiles.get(usr.profileId).Name))
                    usr.Contract_Type__c = System.Label.Contract_Type_Portal;
                else if(setChatterFreeProfiles.contains(mapOfProfiles.get(usr.profileId).Name))
                    usr.Contract_Type__c = System.Label.Contract_Type_Chatter_Free;
                else if(setChatterOnlyProfiles.contains(mapOfProfiles.get(usr.profileId).Name))
                    usr.Contract_Type__c = System.Label.Contract_Type_Chatter_Only;
            }
            else {
                usr.Contract_Type__c = System.Label.Contract_Type_Full;
            }
        }  
    }
    
    //V1.0 - Created - Pankaj - CR-20200714-14300 - 04/12/2021
    //Method to return a set of profiles names on the basis of comma seperated string of profiles
    private static Set<String> getSetOfProfilesNames(String profilesNames) {
        Set<String> setOfProfilesNames = new Set<String>();
        if(String.isNotBlank(profilesNames)) {
            for(String profileName : profilesNames.split(',')) {
                setOfProfilesNames.add(profileName);
            }
        }
        return setOfProfilesNames;
    }
    
    //V1.0 - Created - Ayush Gupta - CR-20210422-15098 - 06/14/2021
    public static void setCommunityUserName(List<User> users) {
        
        Map<Id,String> mapUserIdwithUserName = new Map<Id,String>();
        List<User> updateUsers = new List<User>();
        for(User us : users){
            if(us.License_Type__c == 'Overage High Volume Customer Portal'){
                if(!mapUserIdwithUserName.containsKey(us.Id)){
                    mapUserIdwithUserName.put(us.Id,us.Username);
                }
            }
        }
        if(mapUserIdwithUserName.keySet().size() > 0){
            for(Id uId :mapUserIdwithUserName.keyset()){
                String username = mapUserIdwithUserName.get(uId);
                List<String> usernames = username.split('@');
                username = usernames[0]+'@eab.community.com';
                User uTy = new User();
                uTy.Id = uId;
                uTy.Username = username;
                updateUsers.add(uTy);
            }
			            
        }
        if(updateUsers.size() >0){
            update updateUsers;
        }
    }
        
    //Added By - Nikita Kumari - CR-20220128-15759 - Slack API - Use the users.lookupByEmail method to populate User.Slack_Id__c
    public static void populateUserSlackId(List<User> users, map<Id, User> mapOldUser) 
    {
        map<Id, String> mapOfUserIdWithEmail = new map<Id, String>();
        
        for(User userDetail : users)
        {
            //insert/update case only
			if(String.isNotBlank(userDetail.Email) && userDetail.isActive == true
               && ((mapOldUser == null && String.isBlank(userDetail.Slack_Id__c))
                   || (mapOldUser != null 
                       && 
                       (userDetail.Slack_Id__c != mapOldUser.get(userDetail.Id).Slack_Id__c
                        || (userDetail.isActive != mapOldUser.get(userDetail.Id).isActive)
                        || (userDetail.Email != mapOldUser.get(userDetail.Id).Email)
                       )                       
                       )
                  )
               )
            {
                mapOfUserIdWithEmail.put(userDetail.Id, userDetail.Email);
            }
        }
        
        if(mapOfUserIdWithEmail.size() > 0 && mapOfUserIdWithEmail.keySet().size() > 0)
        {
            getSlackUserIdFromSlack(mapOfUserIdWithEmail);
        }
    }
    
    /**
    *  Purpose 		: Retrieve a single user by looking them up by their registered email address.
    *  Revision Log	: Created By - Nikita Kumari - CR-20220128-15759 - Slack API - Use the users.lookupByEmail method to populate User.Slack_Id__c
    **/
    @future (callout=true)
    public static void getSlackUserIdFromSlack(map<Id, String> mapOfUserIdWithEmail) {
        
        try{
            //check the user email and id before processing
            if(mapOfUserIdWithEmail.size() > 0 && mapOfUserIdWithEmail.keySet().size() > 0)
            {
                List<User> userDetailsToBeUpdated = new List<User>();
                
                //Query for our Slack Callout Details
                Slack_Callouts__mdt slackSandboxCallout = [SELECT Label, DeveloperName, API_Method__c, Image_URL__c, Slack_Channel__c, Slack_Token__c
                                                           FROM Slack_Callouts__mdt
                                                           WHERE DeveloperName = 'User_Lookup_by_Email'];
                
                for(Id userId : mapOfUserIdWithEmail.keySet()){
                    //Declare our Http, HttpRequest & Response records
                    Http slackHttp = new Http();
                    HttpRequest slackCalloutRequest = new HttpRequest();
                    HttpResponse slackResponseBody = new HttpResponse();
                    
                    //Define the specifics needed for the Slack API Method
                    slackCalloutRequest.setHeader('Content-Type', 'application/json');
                    slackCalloutRequest.setHeader('Authorization', 'Bearer ' + slackSandboxCallout.Slack_Token__c);
                    slackCalloutRequest.setMethod('GET');
                    slackCalloutRequest.setEndpoint(slackSandboxCallout.API_Method__c + mapOfUserIdWithEmail.get(userId));
                    
                    //Get our Response Record back
                    slackResponseBody = slackHttp.send(slackCalloutRequest);
                    
                    //If we'll get response from Slack
                    if (slackResponseBody.getStatusCode() == 200){
                        
                        // Deserialize the response json
                        SlackResponseWrapper slackResposeWrap = (SlackResponseWrapper)JSON.deserialize(slackResponseBody.getBody(), SlackResponseWrapper.class);
                        SlackResponseWrapper.UserWrapper userDetl = slackResposeWrap.user;
                        userDetailsToBeUpdated.add(new User(Id = userId, Slack_Id__c = userDetl.id));
                    }
                }
                //check user instance is not blank
                if(userDetailsToBeUpdated.size() > 0){
                    //bypass the trigger to reduce recursion
                    Util.BypassAllTriggers = true;
                    update userDetailsToBeUpdated;
                    Util.BypassAllTriggers = false;
                }
            }
        }
        catch(Exception ex){
            System.debug('Error from "getSlackUserIdFromSlack" apex method details:- '+ ex.getMessage());
        }
        
    }
}