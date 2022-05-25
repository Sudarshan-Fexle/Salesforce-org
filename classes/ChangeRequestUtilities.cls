public with sharing class ChangeRequestUtilities {
    //Boolean
    public static Boolean byPassTrigger = false;
    
    ////Boolean
    public static Boolean invokeInFuture = false;
    
    /*
     *  V1.1 Modified By - Rajiv Jain - 19/02/2020 - CR-20200130-13677  -  Remove zzzCurrent Status(Current_Status__c) field of IS_System__c object.
     *  This method is update the value of Current_Status__c and this field is removed from the IS_System__c object so comment the funtionality.
     * /
    // determine the current status for newly inserted IS System records
    /*public static void UpdateCurrentStatus(List<IS_System__c> triggerNew) {
        Set<Id> parentIds = new Set<Id>();
        Set<Id> triggerNewIds = new Set<Id>();
        for (IS_System__c ISS : triggerNew) {
            parentIds.add(ISS.Primary_System__c);
            triggerNewIds.add(ISS.Id);
        }
        
        // get a map of all parent systems
        Map<Id, IS_System__c> parentSystemMap = new Map<Id, IS_System__c>([SELECT Id, Current_Status__c FROM IS_System__c WHERE Id IN :parentIds]);
        Map<Id, IS_System__c> triggerNewMap = new Map<Id, IS_System__c>([SELECT Id, Current_Status__c, (SELECT Id, Status__c, Functionality__c FROM Change_Requests__r) FROM IS_System__c WHERE Id IN :triggerNewIds]);
        
        for (IS_System__c ISS : triggerNew) {
            String status = 'Fully Functional';
            IS_System__c parentSystem = parentSystemMap.get(ISS.Primary_System__c);
            if (parentSystem != null && parentSystem.Current_Status__c == 'All Out') {
                status = 'All Out';
            }
            else {
                IS_System__c ISSystem = triggerNewMap.get(ISS.Id);
                List<SFDC_Change_Request__c> relatedCRs;
                if (ISSystem != null && ISSystem.Change_Requests__r != null) {
                    relatedCRs = ISSystem.Change_Requests__r;
                }
                status = FindSystemStatus(relatedCRs);
            }
            system.debug('@@' + status);
            ISS.Current_Status__c = status;
        }
    }*/
    
    /*
     *  V1.1 Modified By - Rajiv Jain - 19/02/2020 - CR-20200130-13677  -  Remove zzzCurrent Status(Current_Status__c) field of IS_System__c object.
     *  This method is update the value of Current_Status__c and this field is removed from the IS_System__c object.
     * / 
    // class is used by ChangeRequest.trigger to ensure that the correct IS System Status is on the associated IS System.
   /* public static void UpdateCurrentStatus(List<SFDC_Change_Request__c> triggerNew) {
        Set<Id> ISSystemIds = new Set<Id>();
        Set<Id> triggerNewIds = new Set<Id>();
        // Map<IS System Id, List<Change Requests>>
        Map<Id, List<SFDC_Change_Request__c>> ISSystemToCRMap = new Map<Id, List<SFDC_Change_Request__c>>();
        
        // get a list of all IS Systems involved
        for (SFDC_Change_Request__c CR : triggerNew) {
            if (CR.IS_System__c != null) {
                triggerNewIds.add(CR.Id);
                ISSystemIds.add(CR.IS_System__c);
                // add to our ISSystem -> List<Change Request> map
                List<SFDC_Change_Request__c> tempCRList = new List<SFDC_Change_Request__c>();
                tempCRList = ISSystemToCRMap.get(CR.IS_System__c);
                if (tempCRList == null) {
                    tempCRList = new List<SFDC_Change_Request__c>();
                    tempCRList.add(CR);
                } else {
                    tempCRList.add(CR);
                }
                ISSystemToCRMap.put(CR.IS_System__c, tempCRList);
            }
        }
        
        // if none of these updates are a "system outage" record type, don't do anything
        if (ISSystemIds.size() == 0) return;
        
        // grab all associated CR's (except the ones that triggered this method)
        List<SFDC_Change_Request__c> AllCRs = [SELECT Name, Id, Status__c, IS_System__c, Functionality__c, Users_Affected__c FROM SFDC_Change_Request__c WHERE Id NOT IN :triggerNewIds AND IS_System__c IN :ISSystemIds];
        
        // add these CR's to their appropriate place in the map
        for (SFDC_Change_Request__c CR : AllCRs) {
            // add to our ISSystem -> List<Change Request> map
            List<SFDC_Change_Request__c> tempCRList = new List<SFDC_Change_Request__c>();
            tempCRList = ISSystemToCRMap.get(CR.IS_System__c);
            if (tempCRList == null) {
                tempCRList = new List<SFDC_Change_Request__c>();
                tempCRList.add(CR);
            } else {
                tempCRList.add(CR);
            }
            ISSystemToCRMap.put(CR.IS_System__c, tempCRList);
        }
        
        // list of ISSystem records to update
        List<IS_System__c> ISSystemUpdates = new List<IS_System__c>();
        // get a map of all CR's
        Map<Id, IS_System__c> ISSystemMap = new Map<Id, IS_System__c>([SELECT Id, Primary_System__r.Current_Status__c, Current_Status__c FROM IS_System__c WHERE Id IN :ISSystemToCRMap.keySet()]);
        // now that we have all the system info, see if any IS System records need to be updated
        for (IS_System__c ISS : ISSystemMap.values()) {
            
            List<SFDC_Change_Request__c> CRList = ISSystemToCRMap.get(ISS.Id);
            
            // if parent system is out, the child must be marked as out also
            if (ISS.Primary_System__r.Current_Status__c == 'All Out') {
                ISS.Current_Status__c = 'All Out';
                ISSystemUpdates.add(ISS);
                continue;
            }
            
            // get the temporary system status based on the list of related Change Requests
            String tempStatus = FindSystemStatus(CRList);
            
            system.debug('@@tempStatus:' + tempStatus);
            
            // add the IS System record to the update list of the tempstatus is not equal
            if (ISS.Current_Status__c != tempStatus) {
                ISS.Current_Status__c = tempStatus;
                ISSystemUpdates.add(ISS);
            }
            system.debug('@@ISS SYSTEM UPDATES:' + ISSystemUpdates);
            
        }
        
        if (ISSystemUpdates.size() > 0) {
            update ISSystemUpdates;
            ChangeRequestUtilities.UpdateDependentStatus(ISSystemUpdates);
        }
        
    }*/
    
    // return the system status based on a list of related CR's
    public static String FindSystemStatus(List<SFDC_Change_Request__c> CRList) {
        String tempStatus = 'Fully Operational';
        if (CRList == null) {
            return tempStatus;
        }
        
        for (SFDC_Change_Request__c CR : CRList) {
            if (CR.Status__c.toLowerCase().contains('open')) {
                if (CR.Functionality__c.toLowerCase().contains('all')) {
                    tempStatus = 'All Out';
                    break;
                }
                else if (CR.Functionality__c.toLowerCase().contains('critical')) {
                    tempStatus = 'Critical Out';
                    break;
                }
                else if (CR.Functionality__c.toLowerCase().contains('partial') && tempStatus != 'Partial Out') {
                    tempStatus = 'Partial Out';
                }
            }
            if (CR.Status__c.toLowerCase().contains('reported')) {
                tempStatus = 'Reported - pending verification';
            }
        }
        
        return tempStatus;
    }
    
    
    // make sure all users that add Request Comments (ie: activities with time) on a CR that they are added to the list of "IS Team Involved"
    public static void UpdateISTeamInvolved(List<SFDC_Request_Comment__c> triggerNew) {
        
        // get all the change requests associated with the list of Request Comments passed in
        
        Map<Id, SFDC_Change_Request__c> changeRequestMap = new Map<Id, SFDC_Change_Request__c>([SELECT Id, IS_QA_Lead2__c, IS_QA_Lead2__r.Name, OwnerId, IS_Team_Involved__c, CreatedById
                                                                                                FROM SFDC_Change_Request__c
                                                                                                WHERE Id IN (SELECT SFDC_Change_Request__c FROM SFDC_Request_Comment__c WHERE Id IN :triggerNew)]);
        
        // retreive all users associated with the CR Comments
        
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN (SELECT User__c FROM SFDC_Request_Comment__c WHERE Id IN :triggerNew)]);
        
        // list to hold the change requests that will need to be updated
        
        List<SFDC_Change_Request__c> changeRequestsToUpdate = new List<SFDC_Change_Request__c>();
        
        // go through each CR Comment and ensure that the user is either the owner or in the IS Team Involved field
        
        for (SFDC_Request_Comment__c activity : triggerNew) {
            SFDC_Change_Request__c aChangeRequest = changeRequestMap.get(activity.SFDC_Change_Request__c);
            User aUser = userMap.get(activity.User__c);
            if (activity.User__c != null && aChangeRequest.OwnerId != aUser.Id && aChangeRequest.IS_QA_Lead2__r.Name != aUser.Name) {
                if (aChangeRequest.IS_Team_Involved__c != null && !aChangeRequest.IS_Team_Involved__c.contains(aUser.Name))
                    aChangeRequest.IS_Team_Involved__c += ', ' + aUser.Name;
                else if (aChangeRequest.IS_Team_Involved__c == null)
                    aChangeRequest.IS_Team_Involved__c = aUser.Name;
                
                changeRequestsToUpdate.add(aChangeRequest);
            }
        }
        
        // Update any applicable CRs
        
        if (!changeRequestsToUpdate.isEmpty())
            update changeRequestsToUpdate;
        
    }
    
    /*
     *  V1.1 Modified By - Rajiv Jain - 19/02/2020 - CR-20200130-13677  -  Remove zzzCurrent Status(Current_Status__c) field of IS_System__c object.
     *  This method is called from the UpdateCurrentStatus method which is alerdy comment so we comment this method.
     * / 
    // called from the ISSystems trigger to update any dependent IS Systems that may be effected by system outages
    /*public static void UpdateDependentStatus(List<IS_System__c> systems) {
        Map<Id, String> sysIdToStatusMap = new Map<Id, String>();
        // get a map of all system ids with their corresponding status
        for (IS_System__c sys : systems) {
            sysIdToStatusMap.put(sys.Id, sys.Current_Status__c);
        }
        
        // get all systems with their associated CR's to determine the proper Current Status
        Map<Id, IS_System__c> dependentSystemMap = new Map<Id, IS_System__c>([SELECT Name, Primary_System__r.Current_Status__c, Id, Current_Status__c,
                                                                              (SELECT Id, Status__c, Functionality__c FROM Change_Requests__r),
                                                                              (SELECT Id, Primary_System__r.Current_Status__c, Current_Status__c, Primary_System__c FROM IS_Systems__r)
                                                                              FROM IS_System__c WHERE Primary_System__c IN :sysIdToStatusMap.keySet()]);
        
        if (dependentSystemMap.IsEmpty()) {
            dependentSystemMap = new Map<Id, IS_System__c>([SELECT Name, Primary_System__r.Current_Status__c, Id, Current_Status__c,
                                                            (SELECT Id, Status__c, Functionality__c FROM Change_Requests__r)
                                                            FROM IS_System__c WHERE Id IN :sysIdToStatusMap.keySet()]);
        }
        
        //list<IS_System__c> ISSystemList = (dependentSystemMap.IsEmpty())? systems : dependentSystemMap.values();
        list<IS_System__c> ISSystemList = dependentSystemMap.values();
        
        // list of IS System records to update
        List<IS_System__c> ISSUpdates = new List<IS_System__c>();
        Set<Id> GrandChildSystemIds = new Set<Id>();
        
        for (IS_System__c ISS : ISSystemList) {
            
            list<SFDC_Change_Request__c> CRList = ISS.Change_Requests__r;
            // prep the list to update grand children
            if (ISS.IS_Systems__r != null) {
                //GrandChildSystems.addAll(ISS.IS_Systems__r);
                for (IS_System__c GrandChildSys : ISS.IS_Systems__r) {
                    GrandChildSystemIds.add(GrandChildSys.Id);
                }
            }
            
            
            // if parent system is out, the child must be marked as out also
            if (ISS.Primary_System__r.Current_Status__c == 'All Out') {
                ISS.Current_Status__c = 'All Out';
                ISSUpdates.add(ISS);
                continue;
            }
            
            // get the temporary system status based on the list of related Change Requests
            String tempStatus = FindSystemStatus(CRList);
            // if the status has changes, update the status and add this record to our list of IS Systems to update
            if (tempStatus != null && tempStatus != ISS.Current_Status__c) {
                ISS.Current_Status__c = tempStatus;
                ISSUpdates.add(ISS);
            }
        }
        List<IS_System__c> GrandChildSystems = new List<IS_System__c>();
        if (GrandChildSystemIds.size() > 0) {
            GrandChildSystems = [SELECT Name, Primary_System__r.Current_Status__c, Id, Current_Status__c,
                                 (SELECT Id, Status__c, Functionality__c FROM Change_Requests__r),
                                 (SELECT Id, Primary_System__r.Current_Status__c, Current_Status__c, Primary_System__c FROM IS_Systems__r)
                                 FROM IS_System__c WHERE Id IN :GrandChildSystemIds];
        }
        
        if (ISSUpdates.size() > 0) {
            update ISSUpdates;
            if (GrandChildSystems.size() > 0)
                UpdateGrandChildStatus(GrandChildSystems);
        }
    }*/
    
    /*
     *  V1.1 Modified By - Rajiv Jain - 19/02/2020 - CR-20200130-13677  -  Remove zzzCurrent Status(Current_Status__c) field of IS_System__c object.
     *  This method is called from the UpdateDependentStatus method which is alerdy comment so we comment this method.
     * / 
    // called from the ISSystems trigger to update any dependent IS Systems that may be effected by system outages
    /*public static void UpdateGrandChildStatus(List<IS_System__c> systems) {
        Map<Id, String> sysIdToStatusMap = new Map<Id, String>();
        // get a map of all system ids with their corresponding status
        for (IS_System__c sys : systems) {
            sysIdToStatusMap.put(sys.Id, sys.Current_Status__c);
        }
        
        // get all systems with their associated CR's to determine the proper Current Status
        Map<Id, IS_System__c> dependentSystemMap = new Map<Id, IS_System__c>([SELECT Name, Primary_System__r.Current_Status__c, Id, Current_Status__c,
                                                                              (SELECT Id, Status__c, Functionality__c FROM Change_Requests__r),
                                                                              (SELECT Id, Primary_System__r.Current_Status__c, Current_Status__c, Primary_System__c FROM IS_Systems__r)
                                                                              FROM IS_System__c WHERE Primary_System__c IN :sysIdToStatusMap.keySet()]);
        
        list<IS_System__c> ISSystemList = (dependentSystemMap.IsEmpty())? systems : dependentSystemMap.values();
        
        // list of IS System records to update
        List<IS_System__c> ISSUpdates = new List<IS_System__c>();
        List<IS_System__c> GrandChildSystems = new List<IS_System__c>();
        
        for (IS_System__c ISS : ISSystemList) {
            system.debug('@@ISS CRs' + ISS.Change_Requests__r);
            list<SFDC_Change_Request__c> CRList = ISS.Change_Requests__r;
            // prep the list to update grand children
            if (ISS.IS_Systems__r != null)
                GrandChildSystems.addAll(ISS.IS_Systems__r);
            
            // if parent system is out, the child must be marked as out also
            if (ISS.Primary_System__r.Current_Status__c != 'All Out') {
                ISS.Current_Status__c = 'All Out';
                ISSUpdates.add(ISS);
                continue;
            }
            
            // get the temporary system status based on the list of related Change Requests
            String tempStatus = FindSystemStatus(CRList);
            
            // if the status has changes, update the status and add this record to our list of IS Systems to update
            if (tempStatus != null && tempStatus != ISS.Current_Status__c) {
                ISS.Current_Status__c = tempStatus;
                ISSUpdates.add(ISS);
            }
        }
        
        if (ISSUpdates.size() > 0) {
            update ISSUpdates;
            if (GrandChildSystems.size() > 0)
                UpdateDependentStatus(GrandChildSystems);
        }
    }*/
    
    /*
     *  V1.1 Modified By - Rajiv Jain - 19/02/2020 - CR-20200130-13677  -  Remove zzzCurrent Status(Current_Status__c) field of IS_System__c object.
     *  This method is not used any where.
     * /
    /*public static Set<Id> QueryISSystems(Set<Id> ISSystemIds) {
        Set<Id> retIds = new Set<Id>();
        // query for all is systems involved
        List<IS_System__c> ISSystemList = [SELECT Name, Id, Current_Status__c, Primary_System__c FROM IS_System__c WHERE Id IN :ISSystemIds];
        Set<Id> PrimarySystemIds = new Set<Id>();
        // create a set of ids for "Primary_System" records
        for (IS_System__c ISS : ISSystemList) {
            retIds.add(ISS.Id);
            if (ISS.Primary_System__c != null) {
                retIds.add(ISS.Primary_System__c);
            }
        }
        
        return retIds;
        
    }*/
    
    /**
    *  @description     :	Method to have following logic:-
    * 						A) When the Change Request status is changed to = "12-Deployed", 
    * 						Then update the stage field value as follows:- 
    * 						Check if there are any manual steps associated with the CR.
    * 							a) If there are no manual steps associated with CR OR if all the manual steps has 
    * 								been complete/performed in the production (Check "Step Complete in Production = true" 
    * 								on CR action Items), then set below field values 
    * 								on the CR Status = Deployed and Stage = Complete.
    * 							b) if there is at least a manual steps exist which is still not complete/performed 
    * 								in the production (Check "Step Complete in Production = false" on CR action Items) 
    * 								on the CR, then set below field values on the CR
									Status = Deployed and Stage = Pending manual steps.
    *
    *  @args           :   List<SFDC_Change_Request__c>, Map<Id, SFDC_Change_Request__c>
    *
    *  @return         :   void
    *
    *  @revision Log   :   V_1.0 - Dipesh Gupta - 10/31/2019 - CR-20191018-13439
    * 
    **/
    public static void validateAndUpdateCRStatusAndStage(List<SFDC_Change_Request__c> newChangeRequests, Map<Id, SFDC_Change_Request__c> mapOldChangeRequests)
    {
        Set<Id> setOfEligibleChangeRequests = new Set<Id>();
        for(SFDC_Change_Request__c cR : newChangeRequests) 
        {
            if(String.isNotBlank(cR.Status__c) && cR.Status__c.equalsIgnoreCase(System.Label.Deployed_CR_Status)
            	&& (cR.Status__c != mapOldChangeRequests.get(cR.Id).Status__c || mapOldChangeRequests.get(cR.Id).Status__c.equalsIgnoreCase(System.Label.Deployed_CR_Status))
            ) 
            {
                setOfEligibleChangeRequests.add(cR.Id);
            }   
            if(setOfEligibleChangeRequests.size() > 0) 
            {
                Map<Id, List<CR_Action_Item__c>> mapOfCRIdWithCRAs = new Map<Id, List<CR_Action_Item__c>>();
                Map<Id, Boolean> mapOfCRIdWithAllCompletedCRAs = new Map<Id, Boolean>();
                for(CR_Action_Item__c cRA : [Select ID, IS_System_Modification__c,
                                             IS_System_Modification__r.Change_Request__c,
                                             Step_Complete_in_Production__c 
                                             FROM CR_Action_Item__c 
                                             WHERE RecordType.Developername =: System.Label.RecordType_Developername_Deployment_Plan_Step 
                                             	AND IS_System_Modification__c != null
                                             	AND IS_System_Modification__r.Change_Request__c IN : setOfEligibleChangeRequests
                                            ]) 
                {
                    if (!mapOfCRIdWithCRAs.containskey(cRA.IS_System_Modification__r.Change_Request__c)) 
                    {
                        mapOfCRIdWithCRAs.put(cRA.IS_System_Modification__r.Change_Request__c, new List<CR_Action_Item__c>{cRA});
                        
                    } 
                    else 
                    {
                        List<CR_Action_Item__c> cRAs = mapOfCRIdWithCRAs.get(cRA.IS_System_Modification__r.Change_Request__c);
                        cRAs.add(cRA);
                    	mapOfCRIdWithCRAs.put(cRA.IS_System_Modification__r.Change_Request__c, cRAs);
                    }
                    
                    if(String.isNotBlank(cRA.Step_Complete_in_Production__c) 
                       && !cRA.Step_Complete_in_Production__c.equalsIgnoreCase(System.Label.Step_Complete_In_Production))
                    {
                        mapOfCRIdWithAllCompletedCRAs.put(cRA.IS_System_Modification__r.Change_Request__c, false);
                    }
                }
                for(SFDC_Change_Request__c cRequest : newChangeRequests) 
                {
                	//If there are no manual steps associated with CR then set CR Status = Deployed and Stage = Complete.
                    if(!mapOfCRIdWithCRAs.containsKey(cRequest.Id)) 
                    {
                    	cRequest.Stage__c = System.Label.CR_Complete_Stage;
                    } 
                    //if CR have manual steps associated with it
                    else 
                    {
                        //if there is at least a manual steps exist which is still not complete/performed
                        //then set CR Status = Deployed and Stage = Pending Manual Steps
                        if(mapOfCRIdWithAllCompletedCRAs.containsKey(cRequest.Id)
                        	&& mapOfCRIdWithAllCompletedCRAs.get(cRequest.Id) == false  
                        ) 
                        {
                            cRequest.Stage__c = System.Label.CR_Pending_Stage;
                        }
                        //all the manual steps has been complete/performed Check "Step Complete in Production = true"
                        //then set CR Status = Deployed and Stage = Complete.
                        else 
                        {
                            cRequest.Stage__c = System.Label.CR_Complete_Stage;
                        }
                    }
                }
            }
        }
    }
    
    /**
    *  @description    :	Method to have following logic:-
    * 						A) Check if all CR's on a release, either have [Status = "12-Deployed", and Stage = "Complete"]
    * 							OR [Status = "Cancelled"], Then update the that release record's "Release Status" as Deployed.
    * 						B) Check if all CR's on a release, have Status = "Cancelled" only
    * 							Then update the that release record's "Release Status" as "Cancelled".
    *
    *  @args           :   List<SFDC_Change_Request__c>, Map<Id, SFDC_Change_Request__c>
    *
    *  @return         :   void
    *
    *  @revision Log   :   V_1.0 - Dipesh Gupta - 11/01/2019 - CR-20191018-13439
    * 					   V_1.1 - Dipesh Gupta - 01/24/2020 - CR-20200110-13609
    * 
    **/
    public static void validateAndUpdateReleaseStatus(List<SFDC_Change_Request__c> newChangeRequests, Map<Id, SFDC_Change_Request__c> oldMapChangeRequests)
    {
        List<SFDC_Change_Request__c> changeRequests = newChangeRequests != null ? newChangeRequests : oldMapChangeRequests.values();
        Set<Id> setOfEligibleReleases = new Set<Id>();
        for(SFDC_Change_Request__c cR : changeRequests) 
        {
            //Update case
            if(newChangeRequests != null && oldMapChangeRequests != null
            	&& (cR.Status__c != oldMapChangeRequests.get(cR.Id).Status__c
                    || cR.Stage__c != oldMapChangeRequests.get(cR.Id).Stage__c
                    || cR.Release__c != oldMapChangeRequests.get(cR.Id).Release__c
                   )  
            ) 
            {
                if(cR.Release__c != null) 
                {
                    setOfEligibleReleases.add(cR.Release__c);
                }
                if(oldMapChangeRequests.get(cR.Id).Release__c != null) 
                {
                    setOfEligibleReleases.add(oldMapChangeRequests.get(cR.Id).Release__c);
                }
            }
            //Insert/delete case
            else 
            {
                if(cR.Release__c != null) 
                {
                    setOfEligibleReleases.add(cR.Release__c);
                }
            }
		}
        if(setOfEligibleReleases.size() > 0) 
        {
            Set<String> setOfNonEligibleReleaseStatuses = new Set<String>{System.Label.Release_Deployed_Status, System.Label.Release_Cancelled_Status};
            
            Map<Id, SFDC_Release__c> mapReleases = new Map<Id, SFDC_Release__c>();
            Map<Id, Boolean> mapOnNonEligibleReleases = new Map<Id, Boolean>();
            Map<Id, Integer> mapOfReleaseWithAllCRsCount = new Map<Id, Integer>();
            Map<Id, Integer> mapOfReleaseWithCancelledCRsCount = new Map<Id, Integer>();
            Map<Id, Integer> mapOfReleaseWithCompletelyDeployedCRsCount = new Map<Id, Integer>();
            
            //Modified by : Dipesh Gupta - 01/24/2020 - CR-20200110-13609 -- Start Here 
            Map<Id, List<SFDC_Change_Request__c>> releaseWithChangeRequests = new Map <Id, List<SFDC_Change_Request__c>>();
            
            //Query over Change Request
            for(SFDC_Change_Request__c crS : [SELECT Id, Status__c, Stage__c, Release__c, Release__r.Status__c FROM SFDC_Change_Request__c
                                              WHERE Release__c != null
                                              AND Release__c IN : setOfEligibleReleases
                                              AND Release__r.Status__c NOT IN : setOfNonEligibleReleaseStatuses])
            {
                
                //Putting Release Id with List of Change Request
                if(!releaseWithChangeRequests.containsKey(crS.Release__c))
                    releaseWithChangeRequests.put(crS.Release__c, new List<SFDC_Change_Request__c>());
                
                releaseWithChangeRequests.get(crS.Release__c).add(crS);
                
            }
            
            for(Id releaseId : releaseWithChangeRequests.keySet()) 
            {
                //Map of release with CR count 
                mapOfReleaseWithAllCRsCount.put(releaseId, releaseWithChangeRequests.get(releaseId).Size());
                //Related CR size check
                if(releaseWithChangeRequests.get(releaseId) != null && releaseWithChangeRequests.get(releaseId).Size() > 0){
                    mapReleases.put(releaseId, new SFDC_Release__c(Id = releaseId, Status__c = releaseWithChangeRequests.get(releaseId)[0].Status__c));
                    
                    for(SFDC_Change_Request__c cRequest : releaseWithChangeRequests.get(releaseId))
                    {
                        //If even one CR exists that is having non deployed/cancelled status then no update needed
                        //if(!setOfEligibleStatuses.contains(cRequest.Status__c))
                        if(String.isNotBlank(cRequest.Status__c)
                           && (cRequest.Status__c != System.Label.Release_Cancelled_Status
                               && (cRequest.Status__c != System.Label.Deployed_CR_Status && String.isNotBlank(cRequest.Stage__c) && cRequest.Stage__c != System.Label.CR_Complete_Stage))
                          )
                        {
                            mapOnNonEligibleReleases.put(cRequest.Release__c, false); 
                        }
                        //If even one CR exists that is having deployed/cancelled status then populate the collections accorrdingly
                        //that will help later
                        else if(String.isNotBlank(cRequest.Status__c) && cRequest.Status__c.equalsIgnoreCase(System.Label.Release_Cancelled_Status))
                        {
                            if(mapOfReleaseWithCancelledCRsCount.containsKey(cRequest.Release__c)) 
                            { 
                                Integer previousCount = mapOfReleaseWithCancelledCRsCount.get(cRequest.Release__c);
                                mapOfReleaseWithCancelledCRsCount.put(cRequest.Release__c, (previousCount + 1));
                            }
                            else 
                            {
                                mapOfReleaseWithCancelledCRsCount.put(cRequest.Release__c, 1);
                            }
                        }
                        if(String.isNotBlank(cRequest.Status__c) 
                           && cRequest.Status__c.equalsIgnoreCase(System.Label.Deployed_CR_Status)
                           && String.isNotBlank(cRequest.Stage__c) 
                           && cRequest.Stage__c.equalsIgnoreCase(System.Label.CR_Complete_Stage))
                        {
                            if(mapOfReleaseWithCompletelyDeployedCRsCount.containsKey(cRequest.Release__c))
                            {
                                Integer previousCountComplete = mapOfReleaseWithCompletelyDeployedCRsCount.get(cRequest.Release__c);
                                mapOfReleaseWithCompletelyDeployedCRsCount.put(cRequest.Release__c, (previousCountComplete + 1));
                            }
                            else 
                            {
                                mapOfReleaseWithCompletelyDeployedCRsCount.put(cRequest.Release__c, 1);
                            }
                        }
                    }
                }
                //If there is no CR exists within release then just do a skip no update needed
                else
                {
                    continue; 
                }
            }
            //Modified by : Dipesh Jain - 01/24/2020 - CR-20200110-13609 -- Stop Here 
            
            if(mapReleases.size() > 0) {
            	
                List<SFDC_Release__c> listOfReleasesToBeUpdated = new List<SFDC_Release__c>();
                for(SFDC_Release__c rel : mapReleases.values()) {
                    
                    Integer AllCRCounts = 0;
                    
                    //First bypass all those releases where atleast one CR exists with non deployed and cancelled status
                    if(mapOnNonEligibleReleases.containsKey(rel.Id))
                    {
                        continue;
                    } 
                    
                    //Check if all CR's on a release, have Status = "Cancelled" only
                    //Then update the that release record's "Release Status" as "Cancelled"
                    if(mapOfReleaseWithCancelledCRsCount.containsKey(rel.Id) 
                       && mapOfReleaseWithAllCRsCount.containsKey(rel.Id)
                      ) 
                    {
                        if(mapOfReleaseWithAllCRsCount.get(rel.Id) == mapOfReleaseWithCancelledCRsCount.get(rel.Id))
                            listOfReleasesToBeUpdated.add(new SFDC_Release__c(Id = rel.Id, Status__c = System.Label.Release_Cancelled_Status));
                        else    
                            AllCRCounts = mapOfReleaseWithCancelledCRsCount.get(rel.Id);
                    }
                    
                    //A) Check if all CR's on a release, either have [Status = "12-Deployed", and Stage = "Complete"]
                    //OR [Status = "Cancelled"], Then update the that release record's "Release Status" as Deployed.
                    if(mapOfReleaseWithCompletelyDeployedCRsCount.containsKey(rel.Id) 
                       && mapOfReleaseWithAllCRsCount.containsKey(rel.Id)
                      ) 
                    {
                        AllCRCounts = AllCRCounts + mapOfReleaseWithCompletelyDeployedCRsCount.get(rel.Id);
                        
                        If(mapOfReleaseWithAllCRsCount.get(rel.Id) == AllCRCounts)
                            listOfReleasesToBeUpdated.add(new SFDC_Release__c(Id = rel.Id, Status__c = System.Label.Release_Deployed_Status));    
                    }			
                }
                if(listOfReleasesToBeUpdated.size() > 0) 
                {
                    Util.byPassAllTriggers = true;
                    update listOfReleasesToBeUpdated;
                    Util.byPassAllTriggers = false;
                }
            }
        }
	}
    
    /**
    *  @description:       Method to submit for approval when stage is changed.
    *
    *  @args           :   List<SFDC_Change_Request__c>, Map<Id, SFDC_Change_Request__c>
    *
    *  @return         :   void
    *
    *  @revision Log   :   V_1.0 - Dipesh Gupta - 10/03/2019 - CR-20190906-13320
    *                      V_1.1 - Dipesh Gupta - 03/13/2020 - CR-20190906-13320 --- Revert the changes ---
    * 
    **/
  /*  public static void autoLaunchApprovals(List<SFDC_Change_Request__c> newChangeRequest, Map<Id, SFDC_Change_Request__c> mapOldChangeRequest) {
        
        //Set of Approver ids
        List<Id> approverIds = new List<Id>();
        
        //Map of PrioritizationQueue with Change Request Id as a key
        Map<Id, String> mapChangeRequestIdWithPrioritizationQueue = new Map<Id, String>();
        
        //Set
        Set<Id> setOfChangeRequestIdsWithStatusCancelled = new Set<Id>();
        
        for(SFDC_Change_Request__c cR : newChangeRequest){
            if(cR.status__c != null && cr.PrioritizationQueue__c != null && cR.Status__c == '01-New Request'){
                if(!mapChangeRequestIdWithPrioritizationQueue.containsKey(cR.Id))
                    mapChangeRequestIdWithPrioritizationQueue.put(cR.Id, cR.PrioritizationQueue__c);
            }
            
            if(cR.status__c != null && cr.PrioritizationQueue__c != null && cR.Status__c == 'Declined'){
                setOfChangeRequestIdsWithStatusCancelled.add(cR.Id);
            }
        }
        
        //List of users to send approval
        for(User usr : [SELECT Id, Prioritization_Queue_Member__c FROM User 
                        WHERE User.Prioritization_Queue_Member__c IN: mapChangeRequestIdWithPrioritizationQueue.values()
                        AND Id !=: userInfo.getUserId()]){
                            
        	approverIds.add(usr.Id);	
        }
        
        //Request for all Change Request 
        Approval.ProcessSubmitRequest [] requestList = new Approval.ProcessSubmitRequest []{};
        
        //Check
        if(newChangeRequest.size() > 0){
            
            for(SFDC_Change_Request__c cR: newChangeRequest){
                
                if(cR.status__c != null && cr.PrioritizationQueue__c != null 
                   && (mapOldChangeRequest == null || cR.PrioritizationQueue__c != mapOldChangeRequest.get(cR.Id).PrioritizationQueue__c || cR.status__c != mapOldChangeRequest.get(cR.Id).status__c)){
                       
                       //Create an approval request for the change request
                       Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                       
                       if(cR.Status__c == '01-New Request' && approverIds.size() > 0){
                           for (Id approverId : approverIds) {
                               Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                               req.setProcessDefinitionNameOrId('Change_Request_New_Request');
                               req.setObjectId(cR.id);
                               req.setNextApproverIds(new List<Id>{approverId});
                               req.setSkipEntryCriteria(true);
                               requestList.add(req);
                           }
                       }
                       
                       else if(cR.Status__c == '02-Sponsored'){
                           req1.setObjectId(cR.id);
                           //Submit the record to specific process and skip the criteria evaluation
                           req1.setProcessDefinitionNameOrId('Change_Request_Sponsored');
                           
                           //Determines whether to evaluate the entry criteria for the process
                           req1.setSkipEntryCriteria(true);
                           
                           requestList.add(req1);                                                  
                       }
                       else if(cR.Status__c == '03-Approved'){
                           req1.setObjectId(cR.id);
                           //Submit the record to specific process and skip the criteria evaluation
                           req1.setProcessDefinitionNameOrId('Change_Request_Approved');
                           
                           //Determines whether to evaluate the entry criteria for the process
                           req1.setSkipEntryCriteria(true);
                           
                           requestList.add(req1);                                                 
                       }
                   } 
            }
        }
        
        //Size check
        if(requestList.size() > 0){            
            byPassTrigger = true;
            // Submit the approval request for the change request.
            Approval.ProcessResult[] result = Approval.process(requestList);
        }
        //Check Size
        if(setOfChangeRequestIdsWithStatusCancelled.size() > 0){

          //Added schedules job 
          if (!system.isScheduled()) {
              
              dateTime sysTime = dateTime.now().addSeconds(10);
              String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
              System.schedule('ChangeRequestUtilities' + sysTime.getTime(), chron_exp, new Sched_ChangeRequestApprovalProcess(setOfChangeRequestIdsWithStatusCancelled));   
          }
        }
        //Check Size
        if(mapChangeRequestIdWithPrioritizationQueue.keySet().size() > 0){
            //Call future method to updated changeRequest
            futureAutoLaunchApprovals(mapChangeRequestIdWithPrioritizationQueue.keySet());
        }
    } */
    
    /**
    *  @description		:   Method to update the field of future method.
    *
    *  @args			:   Set<Id>
    *
    *  @return			:   void
    *
    *  @revision Log	:   V_1.0 - Mahendra Swarnkar - 10/03/2019 - CR-20190906-13320
    *                       V_1.1 - Dipesh Gupta - 03/13/2020 - CR-20190906-13320 --- Revert the changes ---
    **/
    /*@future
    public static void futureAutoLaunchApprovals(Set<Id> setTargetObjectId) { 
        
        //List of change request to update.
        List<SFDC_Change_Request__c> changeRequestToUpdate = new List<SFDC_Change_Request__c>();
        
        //Map of ProcessInstance status with TargetObjectId as a key.
        Map<Id, List<String>> mapProcessInstanceStatusWithId = new Map<Id, List<String>>();
        
        //Size check
        if(setTargetObjectId.size() > 0){
            
            //Loop over approval process history
            for( ProcessInstance proInst : [Select Id, ProcessDefinitionId, TargetObjectId, isDeleted, Status From ProcessInstance Where isDeleted = false And  TargetObjectId IN: setTargetObjectId ]){
                
                if(!mapProcessInstanceStatusWithId.containsKey(proInst.TargetObjectId))
                    mapProcessInstanceStatusWithId.put(proInst.TargetObjectId, new List<String>());
                
                mapProcessInstanceStatusWithId.get(proInst.TargetObjectId).add(proInst.Status);	
            }
            
            //Size check
            if(mapProcessInstanceStatusWithId.size() > 0){
                for(Id pI : mapProcessInstanceStatusWithId.keySet()){
                    
                    Integer countOfApprover = mapProcessInstanceStatusWithId.get(pI).size();
                    Integer countApproved = 0;
                    SFDC_Change_Request__c cReq = new SFDC_Change_Request__c();
                    
                    for(String status : mapProcessInstanceStatusWithId.get(pI)){
                        
                        If(status.contains('Approved')){
                            countApproved++;
                        }
                    }
                    if(countApproved == countOfApprover){
                        changeRequestToUpdate.add(new SFDC_Change_Request__c(ID = pI, Status__c = '02-Sponsored', Approver_Count__c = 0));
                    }
                }
            }
            //Size check
            if(changeRequestToUpdate.size() > 0){
                update changeRequestToUpdate;
            } 
        }
    } */
    
    /**
    *  @description:       Method to throw error when approval is rejected
    *
    *  @args           :   List<SFDC_Change_Request__c>, Map<Id, SFDC_Change_Request__c>
    *
    *  @return         :   void
    *
    *  @revision Log   :   V_1.0 - Dipesh Gupta - 12/31/2019 - CR-20190906-13320 -Enhancement
    *                      V_1.1 - Dipesh Gupta - 03/13/2020 - CR-20190906-13320 --- Revert the changes ---
    **/
   /* public static void RequireRejectionComment(List<SFDC_Change_Request__c> newChangeRequest, Map<Id, SFDC_Change_Request__c> mapOldChangeRequest) {
        
        //Map to hold rejected change request.
        Map<Id, SFDC_Change_Request__c> rejectedStatements = new Map<Id, SFDC_Change_Request__c>{};
        
        //Loop over new list
        for(SFDC_Change_Request__c cR : newChangeRequest){
                
            if (newChangeRequest != null){ 
                rejectedStatements.put(cR.Id, cR);  
            }
        }
        
        if (!rejectedStatements.isEmpty()){
            
            //Now that we have the most recent process instances, we can check the most recent process steps for comments.  
            for (ProcessInstance pi : [SELECT TargetObjectId, Status, (SELECT Id, StepStatus, Comments FROM Steps ORDER BY CreatedDate DESC LIMIT 1 )
                                       FROM ProcessInstance WHERE TargetObjectId IN :rejectedStatements.keySet() 
                                       And Status = 'Rejected'  ORDER BY CreatedDate DESC]){                   
                if ((pi.Steps[0].Comments == null || pi.Steps[0].Comments.trim().length() == 0)){
                    rejectedStatements.get(pi.TargetObjectId).addError( 'Please provide a rejection reason!');
                }
            }  
        }
    }*/
}