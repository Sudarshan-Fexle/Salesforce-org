/*
    Purpose         :   This class is helper class for  Release Trigger.
                
    Create By       :   Dipesh Gupta
    
    Created Date    :   11/28/2019
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created - Dipesh Gupta - 11/28/2019
                        V_1.1 Modified - Dipesh Gupta - 12/27/2019
			V_1.2 Modified - Dipesh Gupta - 1/30/2020 Added new method "deleteCompChangeDetail"
			V_1.3 Modified - Neha Sharma - CR-20210719-15300
*/
public without sharing class ReleaseTriggerHelper {
public static List<Org_Comparison_Configuration_Manager__mdt> listOfOrgCompareConfigManager = [Select Id, Component_Type__c, 
                                                                                     Team_Members__c, 
                                                                                     Source_of_Truth__c, 
                                                                                     Comparison_Org__c,
                                                                                     Save_Mods_To__c, Base_URL__c
                                                                                     From Org_Comparison_Configuration_Manager__mdt
                                                                                     WHERE Team_Members__c != null
                                                                                     AND Source_of_Truth__c != null
                                                                                     AND Comparison_Org__c != null
                                                                                     AND Save_Mods_To__c != null];
    public static final String QA_TYPE_ORG = 'QA';
    public static final String UAT_TYPE_ORG = 'UAT';
    
    //If while inserting a release record we have values for QA/UAT Env, Start date fields 
    //AND "Ready for Org Comparision" = true then create correspoding Org Comparision records with defaults from that release.
    // OR
    // If either QA env or UAT env or Start date got changed or Ready for Org Comparision got changed to true then
    //Manage (insert/update) org comparision records on the basis different possible use cases around it.
    public static void manageOrgComparisionRecords(List<SFDC_Release__c> newReleases, Map<Id, SFDC_Release__c> oldMapReleases) 
    {
        Map<Id, SFDC_Release__c> mapOfEligibleReleases = new Map<Id, SFDC_Release__c>();
        for(SFDC_Release__c release : newReleases) 
        {
            //Insert case
            if(oldMapReleases == null && release.Ready_for_Org_Comparison__c) 
            {
                mapOfEligibleReleases.put(release.Id, release);    
            }
            
            //Update case
            if(oldMapReleases != null && release.RecordTypeId == constants.RECORD_TYPE_eTech_Dev
                && (release.Start_Date__c != oldMapReleases.get(release.Id).Start_Date__c
                   || release.Org_Comparison_QA__c != oldMapReleases.get(release.Id).Org_Comparison_QA__c
                   || release.Org_Comparison_UAT__c != oldMapReleases.get(release.Id).Org_Comparison_UAT__c
                   || release.Status__c != oldMapReleases.get(release.Id).Status__c
                   || release.Ready_for_Org_Comparison__c != oldMapReleases.get(release.Id).Ready_for_Org_Comparison__c
                )
            ) 
            {
                if(release.Ready_for_Org_Comparison__c) 
                {
                    mapOfEligibleReleases.put(release.Id, release);    
                }
            }       
        }
        if(mapOfEligibleReleases.values().size() > 0) 
        {
            Map<Id, Boolean> mapOfReleaseIdWIthOCExistsOrNot = new Map<Id, Boolean>();
            Map<Id, Boolean> mapOfReleaseIdWithUATOCExist = new Map<Id, Boolean>();
            
            Map<Id, List<Org_Comparision__c>> mapOfReleaseIdWithOCs = new Map<Id, List<Org_Comparision__c>>();
            for(SFDC_Release__c rel : [Select ID, Org_Comparison_UAT__c, 
                                       (SELECT ID, Release__c, Comparison_Org__c, Component_Types__c, User_Filter__c,Source_of_Truth__c, 
                                        Last_Modified_Date_Bar__c, Type__c, Save_Mods_To__c,Create_Modifications_Manually__c,
                                        Save_Mods_To_Different_Org__c
                                        FROM Org_Comparisons__r)
                                        FROM SFDC_Release__c
                                        WHERE ID IN : mapOfEligibleReleases.keySet()
                                      ]) 
            {
                if(rel.Org_Comparisons__r != null && rel.Org_Comparisons__r.size() > 0) 
                {
                    mapOfReleaseIdWIthOCExistsOrNot.put(rel.Id, true);
                    mapOfReleaseIdWithOCs.put(rel.Id, rel.Org_Comparisons__r);
                    
                    //Check the size of ocs under a release is 1 and UAT is not there. 
                    if(rel.Org_Comparisons__r.size() == 1 && rel.Org_Comparisons__r[0].Type__c == QA_TYPE_ORG 
                    	&& String.isNotBlank(rel.Org_Comparison_UAT__c)) {
                		mapOfReleaseIdWithUATOCExist.put(rel.Id, false);
                   }
                } 
                else 
                {
                    mapOfReleaseIdWIthOCExistsOrNot.put(rel.Id, false);
                }
            }
            if(mapOfReleaseIdWIthOCExistsOrNot.values().size() > 0) 
            {
                List<Org_Comparision__c> listOfOCsToBeUpserted = new List<Org_Comparision__c>();
                Set<Id> setIdsOrgComparisonToBeDeleted = new Set<Id>();
                
                List<Org_Comparison_Configuration_Manager__mdt> oCCompConfigs = new List<Org_Comparison_Configuration_Manager__mdt>();
                oCCompConfigs = ReleaseTriggerHelper.listOfOrgCompareConfigManager;
                if(oCCompConfigs.size() > 0) 
                {
                    for(Id relId : mapOfReleaseIdWIthOCExistsOrNot.keyset()) 
                    {
                        //Insertion of OCs will take place with defaults from release
                        if(!mapOfReleaseIdWIthOCExistsOrNot.get(relId)) 
                        {
                            //OC for QA Org
                            Org_Comparision__c orgCompQA = new Org_Comparision__c();
                            orgCompQA.Release__c = relId;                        
                            orgCompQA.Comparison_Org__c = mapOfEligibleReleases.get(relId).Org_Comparison_QA__c;
                            orgCompQA.Component_Types__c = oCCompConfigs[0].Component_Type__c;
                            orgCompQA.User_Filter__c = oCCompConfigs[0].Team_Members__c;
                            orgCompQA.Source_of_Truth__c = oCCompConfigs[0].Source_of_Truth__c;
                            orgCompQA.Last_Modified_Date_Bar__c = mapOfEligibleReleases.get(relId).Start_Date__c;
                            orgCompQA.Type__c = ReleaseTriggerHelper.QA_TYPE_ORG;
                            orgCompQA.Created_Date_Bar__c = mapOfEligibleReleases.get(relId).Start_Date__c;
                            orgCompQA.Create_Modifications_Manually__c = true;
                            orgCompQA.Save_Mods_To_Different_Org__c = true;
                            //Need to fetch the self Connection Id via query and then populate the field Save_Mods_To__c
                            orgCompQA.Save_Mods_To__c = oCCompConfigs[0].Save_Mods_To__c;
                            orgCompQA.Create_destructive_mods__c = true;
                            orgCompQA.Create_Additive_Mods__c = true;
                        	listOfOCsToBeUpserted.add(orgCompQA);       
                            
                            if(String.isNotBlank(mapOfEligibleReleases.get(relId).Org_Comparison_UAT__c)) {
                            	
                                //OC for UAT Org
                                Org_Comparision__c orgCompUAT = new Org_Comparision__c();
                                orgCompUAT.Release__c = relId;                        
                                orgCompUAT.Comparison_Org__c = mapOfEligibleReleases.get(relId).Org_Comparison_UAT__c;
                                orgCompUAT.Component_Types__c = oCCompConfigs[0].Component_Type__c;
                                orgCompUAT.User_Filter__c = oCCompConfigs[0].Team_Members__c;
                                orgCompUAT.Source_of_Truth__c = oCCompConfigs[0].Source_of_Truth__c;
                                orgCompUAT.Last_Modified_Date_Bar__c = mapOfEligibleReleases.get(relId).Start_Date__c;
                                orgCompUAT.Type__c = ReleaseTriggerHelper.UAT_TYPE_ORG;
                                orgCompUAT.Created_Date_Bar__c = mapOfEligibleReleases.get(relId).Start_Date__c;
                                orgCompUAT.Create_Modifications_Manually__c = true;
                                orgCompUAT.Save_Mods_To_Different_Org__c = true;
                                //Need to fetch the self Connection Id via query and then populate the field Save_Mods_To__c
                                orgCompUAT.Save_Mods_To__c = oCCompConfigs[0].Save_Mods_To__c;
                                orgCompUAT.Create_destructive_mods__c = true;
                                orgCompUAT.Create_Additive_Mods__c = true;
                                
                                listOfOCsToBeUpserted.add(orgCompUAT);
                            }
                        }
                        
                        //Updating of OCs will take place with updated defaults from release
                        else 
                        {
                            if(mapOfReleaseIdWithOCs.containsKey(relId)) 
                            {
                                SFDC_Release__c releaseVar = mapOfEligibleReleases.get(relId);
                                for(Org_Comparision__c exOC : mapOfReleaseIdWithOCs.get(relId)) 
                                {
                                    if(!exOC.Create_Modifications_Manually__c)
                                        exOC.Create_Modifications_Manually__c = true;
                                    if(!exOC.Save_Mods_To_Different_Org__c)
                                        exOC.Save_Mods_To_Different_Org__c = true;
                                    if(exOC.Save_Mods_To__c == null)
                                        //Need to fetch the "self Connection" Id via query and then populate the field Save_Mods_To__c 
                                        exOC.Save_Mods_To__c = oCCompConfigs[0].Save_Mods_To__c;
                                        
                                    if(exOC.Type__c.equalsIgnoreCase(ReleaseTriggerHelper.QA_TYPE_ORG)) 
                                    {
                                        if(releaseVar.Start_Date__c != exOC.Last_Modified_Date_Bar__c
                                            || releaseVar.Org_Comparison_QA__c != exOC.Comparison_Org__c) 
                                        {
                                            exOC.Last_Modified_Date_Bar__c = releaseVar.Start_Date__c;
                                            exOC.Comparison_Org__c = releaseVar.Org_Comparison_QA__c;
                                            
                                            listOfOCsToBeUpserted.add(exOC);
                                        }    
                                    }
                                    else if(exOC.Type__c.equalsIgnoreCase(ReleaseTriggerHelper.UAT_TYPE_ORG)) 
                                    {
                                        if(releaseVar.Start_Date__c != exOC.Last_Modified_Date_Bar__c
                                           || releaseVar.Org_Comparison_UAT__c != exOC.Comparison_Org__c) 
                                        {
                                            exOC.Last_Modified_Date_Bar__c = releaseVar.Start_Date__c;
                                            exOC.Comparison_Org__c = releaseVar.Org_Comparison_UAT__c;
                                            
                                            //Check if on the release lvel we removed the OC then delete the OC. 
                                            if(String.isBlank(releaseVar.Org_Comparison_UAT__c)) {
                                                setIdsOrgComparisonToBeDeleted.add(exOC.Id);
                                            }else { 
                                                listOfOCsToBeUpserted.add(exOC);
                                            }
                                         }     
                                    }
                                    else 
                                    {
                                        //Not a valid case for now. Just skip it.
                                        exOC.addError('Please provide valid value for QA Or UAT.');    
                                    }
                                }    
                            } 
                        }
                        
                        if(mapOfReleaseIdWithUATOCExist.size() > 0) {
                        	
                            //If the map holds the mapOfReleaseIdWithUATOCExist. 
                            if(mapOfReleaseIdWithUATOCExist.containsKey(relId)) {
                                
                            	//OC for UAT Org
                                Org_Comparision__c orgCompUAT = new Org_Comparision__c();
                                orgCompUAT.Release__c = relId;                        
                                orgCompUAT.Comparison_Org__c = mapOfEligibleReleases.get(relId).Org_Comparison_UAT__c;
                                orgCompUAT.Component_Types__c = oCCompConfigs[0].Component_Type__c;
                                orgCompUAT.User_Filter__c = oCCompConfigs[0].Team_Members__c;
                                orgCompUAT.Source_of_Truth__c = oCCompConfigs[0].Source_of_Truth__c;
                                orgCompUAT.Last_Modified_Date_Bar__c = mapOfEligibleReleases.get(relId).Start_Date__c;
                                orgCompUAT.Type__c = ReleaseTriggerHelper.UAT_TYPE_ORG;
                                orgCompUAT.Create_Modifications_Manually__c = true;
                                orgCompUAT.Save_Mods_To_Different_Org__c = true;
                                orgCompUAT.Created_Date_Bar__c = mapOfEligibleReleases.get(relId).Start_Date__c;
                                //Need to fetch the self Connection Id via query and then populate the field Save_Mods_To__c
                                orgCompUAT.Save_Mods_To__c = oCCompConfigs[0].Save_Mods_To__c;
                                orgCompUAT.Create_destructive_mods__c = true;
                                orgCompUAT.Create_Additive_Mods__c = true;    
                                
                                listOfOCsToBeUpserted.add(orgCompUAT);
                            }
                        }
                    }  
                    
                    if(listOfOCsToBeUpserted.size() > 0) 
                    {
                        if(!Test.isRunningTest()) {
                            Util.BypassAllTriggers = true;
                            upsert listOfOCsToBeUpserted;
                            Util.BypassAllTriggers = false;
                        }
                    }  
                    
                    if(setIdsOrgComparisonToBeDeleted.size() > 0) {
                       	Batch_DeleteCompChangeDetail bat = new Batch_DeleteCompChangeDetail (setIdsOrgComparisonToBeDeleted, true);
                         database.executeBatch(bat,200) ;
                    }
                }
                else 
                {
                    //Add error logic - config setting doesn't exists
                    throw new CustomException('Custom Setting does not Exists');
                }
            }
        }
    }
    
   
    
    
    
    /**
     * description  :   This method is used to Update following fields on the base of Target Deployment Date.
     *                      1.) Design_Deadline__c
     *                      2.) Target_Dev_Completion_Date__c
     *                      3.) Target_QA_Completion_Date__c
     *                      4.) Target_UAT_Completion_Date__c
     * 
     * @param       :   List of Release currently in context
     *              
     * @return      :   void 
     * 
     * Created BY   :   V_1.0 - Added By Dipesh Gupta - CR-20191216-13564 - 
     */
    public static void updatingTargetFields(List<SFDC_Release__c> newReleases, Map<Id, SFDC_Release__c> mapOldReleases) {
        
        //Loop through the Change Requests records
        
        if(!newReleases.IsEmpty()) 
        {
            for(SFDC_Release__c release : newReleases)
            {
                //Check for Target Deployment Date Change
                if(mapOldReleases == null || (mapOldReleases != null && 
                                              (mapOldReleases.get(release.id).Release_level__c != release.Release_level__c ||   
                                              mapOldReleases.get(release.Id).Target_Release_Date__c != release.Target_Release_Date__c)))
                {
                    
                    //Release level check
                    if(release.Release_level__c == 'L1 Weekly' || release.Target_Release_Date__c == null)
                    {
                        //Putting null value for L1 Weekly case
                        release.Design_Deadline__c = null;
                        release.Target_Dev_Completion_Date__c = null ;
                        release.Target_QA_Completion_Date__c = null ;
                        release.Target_UAT_Completion_Date__c = null ;
                    }
                    
                    //Release level and Target Deployment date check                             
                    if(release.Release_level__c == 'L2' && release.Target_Release_Date__c != null )
                    {
                        
                        // Friday 4 weeks prior to Target_Deployment_Date__c
                        release.Design_Deadline__c = Util.returnDateOfSpecificDayOfSpecificWeek('Friday', -4, null, release.Target_Release_Date__c);
                        
                        // Friday 3 weeks prior to Target_Deployment_Date__c
                        release.Target_Dev_Completion_Date__c = Util.returnDateOfSpecificDayOfSpecificWeek('Friday', -3, null, release.Target_Release_Date__c) ;
                        
                        // Friday 2 weeks prior to Target_Deployment_Date__c
                        release.Target_QA_Completion_Date__c = Util.returnDateOfSpecificDayOfSpecificWeek('Friday', -2, null, release.Target_Release_Date__c) ;
                        
                        // Friday 1 weeks prior to Target_Deployment_Date__c
                        release.Target_UAT_Completion_Date__c = Util.returnDateOfSpecificDayOfSpecificWeek('Friday', -1, null, release.Target_Release_Date__c) ;
                    }
                }
            }
        }
    }
    
    /**
     * description  :   This method is used to Delete all component change detail when release stage Deployed.
     * @return      :   void 
     * 
     * Created BY   :   Dipesh Gupta .
     * Created Date :   30/1/2020
     */
    public static void deleteCompChangeDetail(List<SFDC_Release__c> newReleases, Map<Id, SFDC_Release__c> mapOldReleases) {
        
        Set<Id> setOfReleaseIds = new Set<Id>();
        Set<Id> setOfOrgCompIds = new Set<Id>();
        
        
        if(!newReleases.IsEmpty())
        {
            //Loop through the Change Requests records
            for(SFDC_Release__c release : newReleases)
            {
                if(mapOldReleases != null && release.Status__c != mapOldReleases.get(release.Id).Status__c 
                   	&& release.Status__c == 'Deployed')  
                {	
                    setOfReleaseIds.add(release.Id);
                    release.Ready_for_Org_Comparison__c = false ;
                }
            }
            
            if(setOfReleaseIds != null && setOfReleaseIds.size() > 0 )
            {
                
                for(Org_Comparision__c oc : [Select Id from Org_Comparision__c Where Release__c IN : setOfReleaseIds])
                {
                    
                    setOfOrgCompIds.add(oc.Id);
                }
            }
            
            if(setOfOrgCompIds != null && setOfOrgCompIds.size() > 0 )
            {
                //This Batch class will delete the component changes details. 
                Batch_DeleteCompChangeDetail bat = new Batch_DeleteCompChangeDetail (setOfOrgCompIds, false);
                database.executeBatch(bat,200);  
            }
        }
    }
}