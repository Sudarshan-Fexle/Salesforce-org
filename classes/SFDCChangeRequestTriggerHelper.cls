/*
    Purpose         :   This class is helper class for  SFDC Change Request Trigger(CR-20120424-757).
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   28/05/2012
    
    Current Version :   V1.0
    
    Revision Log    :   V_1.0 Created
                        V_1.1 - Ajit Surana - 04/18/2014 - CR-20140303-4690 - Added new method (rollUpStorySizeDataOnSFDCRelease())
                        V_1.2 - Bhavi Sharma - 05/02/2014 - CR-20140225-4635 - Updated rollUpDataOnSFDCRelease to rollup data when release field is getting changed
                        V_1.2 - Jason Bennett - 03/22/2016 - CR-20160317-9701 - Updated calculation of Manual Setup Mods for new method of tracking manual steps on CR Action Items
                        V_1.3 - Mahendra Swarnkar - CR-20160408-9753 - 1/30/2017 - Added a new Method "validateCRFields" 
                        V_1.4 - Modified by - Saurabh Kumar CR-20170907-11182 - 09/07/2017 - checkIfRollupUpdateNeeded method is updated in order to rollup of 
                                                                                             Total_Issues_CRA__c, Mods_with_Manual_Steps__c    
                        V_1.5 - Modified By - Dipesh Gupta CR-20170907-11182 - 09/13/2017  Updated rollUpDataOnSFDCRelease Method.
			V_1.6 - Modify By - Abhinav Sharma - CR-20170420-10865 - 02/13/2018 - Added a new Method - relateCaseWithCR
			V_1.7 - Modified By - Rajeev Jain - CR-20160809-10094 - 05/30/2018 - method rollUpStorySizeDataOnSFDCRelease modified to rollup story size on Change Request object
			V_1.8 - Modified By - Neha Sharma - 8/3/2014 - CR-20201208-14728 - notifyUserOnCRCancelled - Notify User when CR gets cancelled
*/
public without sharing class SFDCChangeRequestTriggerHelper {
     // Modified By - Neha Sharma - CR-20201208-14728
     public static boolean bypassNotification = false;
    
    /**
     * description      :   This method determines if an update to the rolled-up values on the related Release(s) is needed, and 
     *                      then calls the function to update the rollup fields if so.
     * @param           :   changeRequests
     *                      List of change requests currently in context
     * 
     * @return          :   void
     * 
     * @revision log    :   V_1.0 Modified by - Saurabh Kumar CR-20170907-11182 - 09/07/2017 - Adding Total_Issues_CRA__c, Mods_with_Manual_Steps__c fields
     */
    public static void checkIfRollupUpdateNeeded(List<SFDC_Change_Request__c> changeRequests) {
        
        //Create a set of Ids to hold the ids of SFDC Releases
        Set<Id> releasesIds = new Set<Id>();
        
        //Fields on SFDC Releases will be updated in case of Insert, Delete, Undelete and Update of change requests
        //In case of update, files will be updated if any of the fields on Change request is changed from the old value
        if(Trigger.isInsert || Trigger.isDelete || Trigger.isUndelete) {
            
            //Loop through the changeRequests records and add release ids in set
            for(SFDC_Change_Request__c cR : changeRequests) {
                
                //Add release Id in Set
                if(cR.Release__c != null)
                    releasesIds.add(cR.Release__c);
            }
        } else if(Trigger.isUpdate) {
                
            //Loop through the changeRequests records and add release ids in set
            for(SFDC_Change_Request__c cR : changeRequests) {
                
                //Get the old CR record
                SFDC_Change_Request__c oldCRInstance = (SFDC_Change_Request__c)Trigger.oldMap.get(cR.Id);
                
                //V_1.0 Modified by - Saurabh Kumar CR-20170907-11182 - 09/07/2017 - Adding Total_Issues_CRA__c, Mods_with_Manual_Steps__c fields
                //check if it is not a blank update or any of the roll up field value is getting changed
                if(cR.Release__c != oldCRInstance.Release__c 
                    || cR.of_Modifications__c != oldCRInstance.of_Modifications__c
                    || cR.Of_Manual_Setup_Mods__c != oldCRInstance.Of_Manual_Setup_Mods__c
                    || cR.Mods_with_Manual_Steps__c != oldCRInstance.Mods_with_Manual_Steps__c
                    || cR.SOX_Certification_Required__c != oldCRInstance.SOX_Certification_Required__c
                    || cR.Coding_Estimated_Hrs__c != oldCRInstance.Coding_Estimated_Hrs__c
                    || cR.Coding_Actual_Hours__c != oldCRInstance.Coding_Actual_Hours__c 
                    || cR.Config_Estimated_Hrs__c != oldCRInstance.Config_Estimated_Hrs__c 
                    || cR.Config_Actual_Hours__c != oldCRInstance.Config_Actual_Hours__c 
                    || cR.Design_Estimated__c != oldCRInstance.Design_Estimated__c 
                    || cR.Design_Actual_Hours__c != oldCRInstance.Design_Actual_Hours__c
                    || cR.IS_QA_Estimated_Hrs__c != oldCRInstance.IS_QA_Estimated_Hrs__c
                    || cR.IS_QA_Actual_Hours__c != oldCRInstance.IS_QA_Actual_Hours__c
                    || cR.Total_IS_CRM_Estimated_Hrs__c != oldCRInstance.Total_IS_CRM_Estimated_Hrs__c
                    || cR.Total_IS_CRM_Hrs__c != oldCRInstance.Total_IS_CRM_Hrs__c
                    || cR.User_Documentation_Actual_Hrs__c != oldCRInstance.User_Documentation_Actual_Hrs__c
                    || cr.Total_Issues_CRA__c != oldCRInstance.Total_Issues_CRA__c
                    || cr.Mods_with_Manual_Steps__c != oldCRInstance.Mods_with_Manual_Steps__c
                    || cR.Requirements_Gathering_Actual_Hrs__c != oldCRInstance.Requirements_Gathering_Actual_Hrs__c
                    || cR.Data_Imports_Updates_Actual_Hrs__c != oldCRInstance.Data_Imports_Updates_Actual_Hrs__c
                    || cR.Meetings_Communications_Actual_Hrs__c != oldCRInstance.Meetings_Communications_Actual_Hrs__c
                    || cR.UAT_Support_Actual_Hrs__c != oldCRInstance.UAT_Support_Actual_Hrs__c
                    //Modified by Mahendra Swarnakar - 05/05/2020 - CR-20200218-13769 - Documentation_Estimated_Hrs__c field
                    //|| cR.Documentation_Estimated_Hrs__c != oldCRInstance.Documentation_Estimated_Hrs__c
                    //|| cR.Meetings_Communications_Estimated_Hrs__c != oldCRInstance.Meetings_Communications_Estimated_Hrs__c
                    || cR.Data_Imports_Updates_Estimated_Hrs__c != oldCRInstance.Data_Imports_Updates_Estimated_Hrs__c
                    //|| cR.Requirements_Gathering_Estimated_Hrs__c != oldCRInstance.Requirements_Gathering_Estimated_Hrs__c
                    || cR.UAT_Support_Estimated_Hrs__c != oldCRInstance.UAT_Support_Estimated_Hrs__c
                 ) {
                    
                    //Add release Id in Set
                    if(cR.Release__c != null)
                        releasesIds.add(cR.Release__c);
                    
                    //Added By Bhavi Sharma - 05/02/2014 - CR-20140225-4635
                    if(oldCRInstance.Release__c != null)
                        releasesIds.add(oldCRInstance.Release__c);
                }
            }
        }
        
        //Check if there are records to process
        if(releasesIds.size() > 0) {
            rollUpDataOnSFDCRelease(releasesIds);
        }
    }
    
    /**
     * description      :   This method is to roll up SFDC Change request fields on SFDC Release object
     * 
     * @param           :   changeRequests
     *                      Set of Release Ids for the Release records that need to be updated
     * 
     * @return          :   void
     * 
     * @revision log    :   //V_1.0 Modified by - Saurabh Kumar CR-20170907-11182 - 09/07/2017 - Adding Total_Issues_CRA__c, Mods_with_Manual_Steps__c fields
     */
    public static void rollUpDataOnSFDCRelease(Set<Id> releaseIds) {
        
        //Verify that there are records to process
        if(releaseIds.size() > 0 && releaseIds != null) {
                    
            //Map to hold the release
            Map<Id, SFDC_Release__c> mapReleases = new Map<Id, SFDC_Release__c>();
            
            //Map to hold the Manual Step Counts
            Map<Id, Integer> mapReleaseToSteps = new map<Id,Integer>();
            
            //Modified by Mahendra Swarnkar - 05/07/2020 - CR-20200218-13769 - meetings_communications_estimated_hrs__c,requirements_gathering_estimated_hrs__c field.
            //V_1.0 Modified by - Saurabh Kumar CR-20170907-11182 - 09/07/2017 - Adding Total_Issues_CRA__c, Mods_with_Manual_Steps__c fields
            //Fetch all the change requests, and group these records by SFDC Release.
            //Get Count and Sum for various fields
            List<AggregateResult> aggregateResultsForCR = [Select Count(ID) recordCount, SUM(of_Modifications__c) totalModifications,
                                        SUM(Of_Manual_Setup_Mods__c) totalmanualSetupMods, SUM(Mods_with_Manual_Steps__c) totalModsWithManualSteps,
                                        SOX_Certification_Required__c certRequired,
                                        SUM(Coding_Estimated_Hrs__c) totalCodingEstimatedHours, SUM(Coding_Actual_Hours__c) totalCodingActualHours,
                                        SUM(Config_Estimated_Hrs__c) totalConfigEstimatedHours, SUM(Config_Actual_Hours__c) totalConfigActualHours,
                                        SUM(Design_Estimated__c) totalDesignEstimatedHours, SUM(Design_Actual_Hours__c) totalDesignActualHours,
                                        SUM(IS_QA_Estimated_Hrs__c) totalISQAEstimatedHours, SUM(IS_QA_Actual_Hours__c) totalISQAActualHours,
                                        SUM(User_Documentation_Actual_Hrs__c) totalUDActualHours, Release__c release,
                                        SUM(Total_IS_CRM_Estimated_Hrs__c) totalISCRMEstimatedHours, SUM(Total_IS_CRM_Hrs__c) totalISCRMActualHours,
                                        SUM(Total_Issues_CRA__c) totalIssueCRAs, SUM(Mods_with_Manual_Steps__c) totalManualMods,
                                        SUM(Requirements_Gathering_Actual_Hrs__c) totalRequirmentGathering, 
                                        SUM(Data_Imports_Updates_Actual_Hrs__c) totalDataImportUpdatesActualHours, 
                                        SUM(Meetings_Communications_Actual_Hrs__c) totalMeetingCommunicationHours,
                                        //Modified by Mahendra Swarnakar - 05/05/2020 - CR-20200218-13769 - Documentation_Estimated_Hrs__c field
                                        //SUM(Documentation_Estimated_Hrs__c) totalDocumentationEstimated,
                                        //SUM(Meetings_Communications_Estimated_Hrs__c) totalCommunicationEstimated,
                                        SUM(Data_Imports_Updates_Estimated_Hrs__c) totalDataImportsHours,
                                        //SUM(Requirements_Gathering_Estimated_Hrs__c) totalRequirementgatheringHours,
                                        SUM(UAT_Support_Actual_Hrs__c) totalUATSupportActualHours,
                                     	SUM(UAT_Support_Estimated_Hrs__c) totalUATsupportHours
                                        From SFDC_Change_Request__c where Release__c IN: releaseIds 
                                        GROUP BY ROLLUP(Release__c, SOX_Certification_Required__c)];
            
            //Get the count of manual steps for each Release
            List<AggregateResult> arReleaseManualSteps = [SELECT Count(Id) recordCount, IS_System_Modification__r.Change_Request__r.Release__c release
                                                          FROM CR_Action_Item__c
                                                          WHERE IS_System_Modification__r.Change_Request__r.Release__c in: releaseIds 
                                                          AND RecordTypeId = :Schema.SObjectType.CR_Action_Item__c.getRecordTypeInfosByName().get('Deployment Plan Step').getRecordTypeId()
                                                          AND IS_System_Modification__r.Delete_from_Design__c = FALSE
                                                          AND Action_Item_Status__c != 'Cancelled'
                                                          GROUP BY IS_System_Modification__r.Change_Request__r.Release__c];
            system.debug('SFDCChangeRequestTriggerHelper.rollUpDataOnSFDCRelease - arReleaseManualSteps = '+arReleaseManualSteps);
            
            //Load the results of the Manual Step query into a map
            for(AggregateResult arSteps : arReleaseManualSteps) {
                mapReleaseToSteps.put(Id.valueOf(String.valueOf(arSteps.get('release'))),Integer.valueOf(arSteps.get('recordCount')));
            }
            system.debug('SFDCChangeRequestTriggerHelper.rollUpDataOnSFDCRelease - mapReleaseToSteps = '+mapReleaseToSteps);
                                        
            //Do the processing only if aggregate query have results to process
            if(aggregateResultsForCR.size() > 0) {
                
                //Create an instance of SFDC Release object
                SFDC_Release__c release;
                
                //loop through the aggregate results
                for(AggregateResult aR : aggregateResultsForCR) {
                    
                    //Update data on release object
                    if(aR.get('release') != null) {
                        
                        //Release id
                        Id releaseId = Id.valueOf(String.valueOf(aR.get('release')));
              
                        //Create a clone for release record
                        if(!mapReleases.containsKey(releaseId))
                            mapReleases.put(releaseId, new SFDC_Release__c(Id = releaseId));
                        
                        release = mapReleases.get(releaseId);
                        
                        //Check if SOX_Certification_Required__c status is Yes
                        if(aR.get('certRequired') != null && String.valueOf(aR.get('certRequired')) == Constants.YES) {
                            
                            //Set the rollup data
                            if(aR.get('recordCount') != null) 
                                release.No_of_SOX_Requests__c = Integer.valueOf(aR.get('recordCount'));
                            
                            //Put back in map
                            mapReleases.put(release.Id, release);
                        } else if(aR.get('certRequired') == null) {
                        
                            //Set the rollup data
                            if(aR.get('recordCount') != null) 
                                release.No_of_Change_Requests__c = Integer.valueOf(aR.get('recordCount'));
                            if(aR.get('totalModifications') != null) 
                                release.No_of_Modifications__c = Integer.valueOf(aR.get('totalModifications'));
                            if(aR.get('totalmanualSetupMods') != null) 
                                release.No_of_Manual_Setup_Mods__c = Integer.valueOf(aR.get('totalmanualSetupMods'));
                            //JRB Add in the new method for counting the number of manual steps using CR Action Item
                            if(mapReleaseToSteps.containsKey(releaseId))
                                release.No_of_Manual_Setup_Mods__c = release.No_of_Manual_Setup_Mods__c + mapReleaseToSteps.get(releaseId);
                            if(aR.get('totalCodingEstimatedHours') != null) 
                                release.Coding_Estimated_Hrs__c = Double.valueOf(aR.get('totalCodingEstimatedHours'));
                            if(aR.get('totalCodingActualHours') != null) 
                                release.Coding_Actual_Hrs__c = Double.valueOf(aR.get('totalCodingActualHours'));
                            if(aR.get('totalConfigEstimatedHours') != null) 
                                release.Config_Estimated_Hrs__c = Double.valueOf(aR.get('totalConfigEstimatedHours'));
                            if(aR.get('totalConfigActualHours') != null) 
                                release.Config_Actual_Hrs__c = Double.valueOf(aR.get('totalConfigActualHours'));
                            if(aR.get('totalDesignEstimatedHours') != null) 
                                release.Design_Estimated_Hrs__c = Double.valueOf(aR.get('totalDesignEstimatedHours'));
                            if(aR.get('totalDesignActualHours') != null) 
                                release.Design_Actual_Hrs__c = Double.valueOf(aR.get('totalDesignActualHours'));
                            if(aR.get('totalISQAEstimatedHours') != null) 
                                release.IS_QA_Estimated_Hrs__c = Double.valueOf(aR.get('totalISQAEstimatedHours'));
                            if(aR.get('totalISQAActualHours') != null) 
                                release.IS_QA_Actual_Hrs__c = Double.valueOf(aR.get('totalISQAActualHours'));
                            if(aR.get('totalUDActualHours') != null) 
                                release.User_Documentation_Actual_Hrs__c = Double.valueOf(aR.get('totalUDActualHours'));
                            if(aR.get('totalISCRMEstimatedHours') != null) 
                                release.Total_IS_CRM_Estimated_Hrs__c = Double.valueOf(aR.get('totalISCRMEstimatedHours'));
                            if(aR.get('totalISCRMActualHours') != null) 
                                release.Total_IS_CRM_Actual_Hrs__c = Double.valueOf(aR.get('totalISCRMActualHours'));
                            
                            //V_1.5 Modified By - Dipesh Gupta CR-20170907-11182 - 09/13/2017
                            if(aR.get('totalRequirmentGathering') != null)
                                release.Requirements_Gathering_Actual_Hrs__c = Double.valueOf(aR.get('totalRequirmentGathering'));  
                            if(aR.get('totalDataImportUpdatesActualHours') != null)
                                release.Data_Imports_Updates_Actual_Hrs__c = Double.valueOf(aR.get('totalDataImportUpdatesActualHours'));
                            if(aR.get('totalMeetingCommunicationHours') != null)
                                release.Meetings_Communications_Actual_Hrs__c = Double.valueOf(aR.get('totalMeetingCommunicationHours'));
                            if(aR.get('totalUATSupportActualHours') != null)
                                release.UAT_Support_Actual_Hrs__c = Double.valueOf(aR.get('totalUATSupportActualHours'));
                            
                            //Modified by Mahendra Swarnakar - 05/05/2020 - CR-20200218-13769 - Documentation_Estimated_Hrs__c field
                            /*if(aR.get('totalDocumentationEstimated') != null)
                                release.Documentation_Estimated_Hrs__c = Double.valueOf(aR.get('totalDocumentationEstimated'));
                            if(aR.get('totalDocumentationEstimated') != null)
                                release.Documentation_Estimated_Hrs__c = Double.valueOf(aR.get('totalDocumentationEstimated'));*/
                            
                            //Modified by Mahendra Swarnkar - 05/07/2020 - CR-20200218-13769 - meetings_communications_estimated_hrs__c,requirements_gathering_estimated_hrs__c field.
                            /*if(aR.get('totalCommunicationEstimated') != null)
                                release.Meetings_Communications_Estimated_Hrs__c = Double.valueOf(aR.get('totalCommunicationEstimated'));*/
                            if(aR.get('totalDataImportsHours') != null)
                                release.Data_Imports_Updates_Estimated_Hrs__c = Double.valueOf(aR.get('totalDataImportsHours'));
                            /*if(aR.get('totalRequirementgatheringHours') != null)
                                release.Requirements_Gathering_Estimated_Hrs__c = Double.valueOf(aR.get('totalRequirementgatheringHours'));*/
                            if(aR.get('totalUATsupportHours') != null)
                                release.UAT_Support_Estimated_Hrs__c = Double.valueOf(aR.get('totalUATsupportHours'));
                          
                            //V_1.0 Modified by - Saurabh Kumar CR-20170907-11182 - 09/07/2017 - Adding Total_Issues_CRA__c, and Total_Manual_Modifications__c fields
                            if(aR.get('totalIssueCRAs') != null) 
                                release.Total_Issues_CRA__c = Double.valueOf(aR.get('totalIssueCRAs'));
                            if(aR.get('totalManualMods') != null) 
                                release.Total_Manual_Modifications__c = Double.valueOf(aR.get('totalManualMods'));
                            
                            //Put back in map
                            mapReleases.put(release.Id, release);
                        }
                    }
                }
            } 
            
            for(Id releaseId : releaseIds) {
                
                //Set 0s where no record found
                if(!mapReleases.containsKey(releaseId ))
                    mapReleases.put(releaseId, new SFDC_Release__c(Id = releaseId, No_of_SOX_Requests__c = 0, No_of_Change_Requests__c = 0,
                                                            No_of_Modifications__c = 0, No_of_Manual_Setup_Mods__c = 0, 
                                                            Coding_Estimated_Hrs__c = 0, Coding_Actual_Hrs__c = 0, 
                                                            Config_Estimated_Hrs__c = 0, Config_Actual_Hrs__c = 0,
                                                            Design_Estimated_Hrs__c = 0, Design_Actual_Hrs__c = 0, 
                                                            IS_QA_Estimated_Hrs__c = 0, IS_QA_Actual_Hrs__c = 0,
                                                            Total_IS_CRM_Estimated_Hrs__c = 0, Total_IS_CRM_Actual_Hrs__c = 0,
                                                            User_Documentation_Actual_Hrs__c = 0));     
            }
            
            //Check if there are records to update
            if(mapReleases.size() > 0) {
                
                update mapReleases.values();
            }
        }
    }
    
    //Added by Ajit Surana - 04/18/2014 - CR-20140303-4690
    /**
     *  @description    : This method assign a value to each CR based on the Story Size field. Add all values together & populate this on release object. 
     * 
     *  @args           : List of new Change Request records, Map of old Change Request Id and instance 
     * 
     *  @return         : void
     * 
     *  @revision Log   :   V_1.0 Modified By - Rajeev Jain - CR-20160809-10094 - 05/30/2018 
     * 
     **/
    public static void rollUpStorySizeDataOnSFDCRelease(List<SFDC_Change_Request__c> changeRequests, Map<Id, SFDC_Change_Request__c> mapOldChangeRequests) {
        
        //Map to hold the release Id as key and release record value
        Map<Id, SFDC_Release__c> mapRelease = new Map<Id, SFDC_Release__c>();
        
        //Loop through the Change Requests records
        if(changeRequests != null) {
            for(SFDC_Change_Request__c cR : changeRequests) {
                if(mapOldChangeRequests == null) {
                    if(cR.Release__c != null){
                         //Modified By - Rajeev Jain - CR-20160809-10094 - 05/30/2018 - Start
                        mapRelease.put(cR.Release__c, new SFDC_Release__c(Id=cR.Release__c, Story_Points__c = 0, Story_Points_Act__c = 0));
                    System.debug('Stage1');
                    }
                                                                         
                } else {
                   
                    if(cR.StorySizeEst__c != mapOldChangeRequests.get(cR.Id).StorySizeEst__c 
                       ||cR.StorySizeAct__c != mapOldChangeRequests.get(cR.Id).StorySizeAct__c
                       || cR.Release__c != mapOldChangeRequests.get(cR.Id).Release__c) {
                           if(cR.Release__c != null){
                               mapRelease.put(cR.Release__c, new SFDC_Release__c(Id=cR.Release__c, Story_Points__c = 0, Story_Points_Act__c = 0));
                               System.debug('Stage2');
                           }
                           if(mapOldChangeRequests.get(cR.Id).Release__c != null){
                               mapRelease.put(mapOldChangeRequests.get(cR.Id).Release__c, new SFDC_Release__c(Id=mapOldChangeRequests.get(cR.Id).Release__c, Story_Points__c = 0, Story_Points_Act__c = 0));
                               System.debug('Stage3');
                           }
                       }  
                }      
            }
        } else {
            for(SFDC_Change_Request__c cR : mapOldChangeRequests.values()) {
                if(mapOldChangeRequests.get(cR.Id).Release__c != null)
                    mapRelease.put(mapOldChangeRequests.get(cR.Id).Release__c, new SFDC_Release__c(Id=mapOldChangeRequests.get(cR.Id).Release__c, Story_Points__c = 0, Story_Points_Act__c = 0));
            }
        }
        
        //System.assert(false,mapRelease);
                
        //Check if there are records to update
        if(mapRelease.size() > 0) {
            
            //Map to hold Story Size values combinations
            Map<String, Integer> mapStroySizes = new Map<String, Integer>{'XS'=>1,'S'=>2,'M'=>3,'L'=>5,'XL'=>7};
            
            //Map of release records
            Map<Id, Integer> mapReleaseIdWithStoryPoints = new Map<Id, Integer>();
        
            //Loop through change requests records already assigned to a release
            for(SFDC_Change_Request__c cR : [SELECT ID, StorySizeEst__c,StorySizeAct__c , Release__c FROM SFDC_Change_Request__c WHERE Release__c IN: mapRelease.keySet()]) {
               
               
                //Checking and validating for story size field value
                Decimal sumCount ;
                Decimal actSumCount ;
                //Checking and validating for story size field value
                if(!String.isBlank(cR.StorySizeEst__c) && mapStroySizes.get(cR.StorySizeEst__c) != null) {
                    //Add new count
                    sumCount = mapRelease.get(cR.Release__c).Story_Points__c + mapStroySizes.get(cR.StorySizeEst__c);
                }else{
                    //Set present count
                    sumCount = mapRelease.get(cR.Release__c).Story_Points__c;
                }
                //Checking and validating for story size field value
                if(!String.isBlank(cR.StorySizeAct__c) && mapStroySizes.get(cR.StorySizeAct__c) != null) {
                     //Add new count
                    actSumCount = mapRelease.get(cR.Release__c).Story_Points_Act__c + mapStroySizes.get(cR.StorySizeAct__c);
                    //System.assert(false,'Stage4 '+ actSumCount );
                }else{
                    //Set present count
                    actSumCount = mapRelease.get(cR.Release__c).Story_Points_Act__c;
                    // System.assert(false,'Stage5 '+ actSumCount ); 
                    
                }
               // System.assert(false, 'debug - '+String.isBlank(cR.StorySizeAct__c) + mapStroySizes.get(cR.StorySizeAct__c) ); 
                
                mapRelease.put(cR.Release__c, new SFDC_Release__c(Id=cR.Release__c, Story_Points__c = sumCount ,Story_Points_Act__c=actSumCount));
            }
            
            //Modified By - Rajeev Jain - CR-20160809-10094 - 05/30/2018 - End
            System.debug('@@@@@@ mapRelease ' + mapRelease);
        }
        
        //Checking for size value
        if(mapRelease.values().size() > 0)
            update mapRelease.values();
    }   
    
    //Added By Mahendra Swarnkar - 1/30/2017 - CR-20160408-9753
    /**
     * description  :   This method is to populate/validate the fields in before logic
     * 
     * @param       :   List of change requests currently in context
     *              
     * @return      :   void 
     */
    public static void validateCRFields(List<SFDC_Change_Request__c> changeRequests) {
        
        //Set to hold the contact Ids
        Set<Id> contactId = new Set<Id>();
        
        //Loop over the trigger.new (i.e. list of CR records)
        for(SFDC_Change_Request__c cr: changeRequests) 
        {
            //check for null/blank
            if(cr.IS_QA_Lead2__c != null ) 
            {
                //Populate the set contactId
                contactId.add(cr.IS_QA_Lead2__c);
            }
        }
        
        //Check for size
        if(contactId.size()>0)
        {
            //Map to hold the contacct records
            Map<Id,Contact> mapOfContact = new Map<Id,Contact>([SELECT Id, Employee_User_Record__c 
                                                                    FROM Contact 
                                                                    where Employee_User_Record__c != null 
                                                                            AND ID IN : contactId
                                                               ]);
            
            //Check for size
            if(mapOfContact.size() > 0)
            { 
                //Loop over the change request records 
                for(SFDC_Change_Request__c cr: changeRequests) 
                {
                    //check for null/blank
                    if(cr.QA_Lead__c == null 
                        &&cr.IS_QA_Lead2__c != null 
                        && mapOfContact.containsKey(cr.IS_QA_Lead2__c)) 
                    {
                        //Populate the Lead QA User field value
                        cr.QA_Lead__c = mapOfContact.get(cr.IS_QA_Lead2__c).Employee_User_Record__c;
                    } 
                }
            }
        }
    }
    /**
     * description  :   This method is used to relate the Case with the CR
     * 
     * @param       :   List of change requests currently in context
     *              
     * @return      :   void 
     * 
     * Created BY   :   V_1.1 - Added By Abhinav Sharma - CR-20170420-10865 - relateCaseWithCR
     */
    public static void relateCaseWithCR (List<SFDC_Change_Request__c> newChangeRequests) {
     
        //Map to hold the Case Number and related CR
        Map<String, String> mapCaseWithCR = new  Map<String, String>();
        
        //List of case that is going to update  
        list<Case> caseTobeUpdated = new List<Case>();
            
        //Check if list is not null
        if(newChangeRequests != null) {
            
            //loop through the change request
            for(SFDC_Change_Request__c changeRequest : newChangeRequests) {
                
                //Check if the related Case is not Null 
                if(changeRequest.Related_Case_Number__c != null)
                	mapCaseWithCR.put(changeRequest.Related_Case_Number__c, changeRequest.Id);    
            }
            
            //Check for the map size
            if(mapCaseWithCR.size() > 0) {
            	
                //Query on the case 
                for(Case cse : [Select Id, CaseNumber, Change_Request__c From Case where CaseNumber IN: mapCaseWithCR.keyset()]) {
                    
                    //Check for the map contains caseNumber
                    if(mapCaseWithCR.containsKey(cse.CaseNumber) && mapCaseWithCR.get(cse.CaseNumber) != null)
                    	caseTobeUpdated.add(new Case (Id = cse.Id, Change_Request__c = mapCaseWithCR.get(cse.CaseNumber)));
            	}
                
                //Bypass all trigger
                Util.ByPassAllTriggers = true;
                
                //Check for the list of Case to be Updated 
                if(caseTobeUpdated.size() > 0)
                    update caseTobeUpdated;
                
                //Bypass all trigger
                Util.ByPassAllTriggers = false;
            }
        }
    }
    
     /**
     * description  :   This method is used to notify the user on cancelled on CR
     * 
     * @param       :   List of change requests currently in context
     *              
     * @return      :   void 
     * 
     * Created BY   :   V_1.1 - Added By Neha Sharma - CR-20201208-14728 - 8/3/2021
     */
    public static void notifyUserOnCRCancelled (List<SFDC_Change_Request__c> newChangeRequests,Map<Id, SFDC_Change_Request__c> mapOldChangeRequests) {
        
        Map<Id,SFDC_Change_Request__c> mapOfChangeRequest = new Map<Id,SFDC_Change_Request__c>();
        Map<Id,List<String>> mapOfChangeRequestWithEmailIds = new Map<Id,List<String>>();
        List<SFDC_Change_Request__c> changeRequestTobeUpdate = new List<SFDC_Change_Request__c>();
        List<IS_System_Modification__c> systemComponentList = new  List<IS_System_Modification__c>();
        
        if(bypassNotification)
            return;
         //loop through the change request
         for(SFDC_Change_Request__c changeRequest : newChangeRequests) {
             
            //Check if CR is mark as cancelled and Change Request Level is L1/L2
            if(mapOldChangeRequests != null  && changeRequest.Status__c == 'Cancelled' && 
               changeRequest.Status__c != mapOldChangeRequests.get(changeRequest.Id).Status__c 
               )
            {
                if(changeRequest.Change_Request_Level__c == null || 
                   (changeRequest.Change_Request_Level__c != null && 
                    (
                        (changeRequest.Change_Request_Level__c).contains('L1') 
                        || (changeRequest.Change_Request_Level__c).contains('L2')
                        || (changeRequest.Change_Request_Level__c).contains('L3')
                    )
                   ))
                {
                    //map to hold the change request Ids
                    mapOfChangeRequest.put(changeRequest.Id,changeRequest);
                }
                
                if(changeRequest.Release__c != null && changeRequest.Change_Request_Level__c != null && (changeRequest.Change_Request_Level__c).contains('L1'))
                {
                     //Create the instance of change request and set the release as null
                    SFDC_Change_Request__c changeReqst = new SFDC_Change_Request__c();
                    changeReqst.Id = changeRequest.Id;
                    changeReqst.Release__c = null;
                    changeRequestTobeUpdate.add(changeReqst);
                }
                 
                   
            }
             
             if(mapOfChangeRequest.size() > 0){
                 for(SFDC_Change_Request__c chnRequest : [Select Id,Change_Request_Level__c,(Select Id,Delete_from_Design__c FROM SFDC_Modifications6__r 
                                                          WHERE Delete_from_Design__c = False 
														  AND Change_Request__c IN: mapOfChangeRequest.keySet()),Name,
                                                          Owner.Email,Release__c,Release__r.Environment_Manager__c,
                                                          Release__r.Environment_Manager__r.Email,Release__r.Release_Manager__c,
                                                          Release__r.Release_Manager__r.Email,LastModifiedBy.Name
                                                          FROM SFDC_Change_Request__c 
                                                          WHERE Id IN: mapOfChangeRequest.keySet()])
                 {
                     mapOfChangeRequest.put(chnRequest.Id,chnRequest);
                     
                     if(!mapOfChangeRequestWithEmailIds.containsKey(chnRequest.Id) ){
                         if(chnRequest.Change_Request_Level__c == null || (chnRequest.Change_Request_Level__c != null &&!((chnRequest.Change_Request_Level__c).contains('L1'))))
                         {
                         mapOfChangeRequestWithEmailIds.put(chnRequest.Id,new List<String>{});
                        if(chnRequest.Owner.Email != null)
                         {
                             mapOfChangeRequestWithEmailIds.get(chnRequest.Id).add(chnRequest.Owner.Email);
                         }
                         
                         if(chnRequest.Release__c != null){
                             if(chnRequest.Release__r.Environment_Manager__c != null && 
                                chnRequest.Release__r.Environment_Manager__r.Email != null)
                             {
                                 mapOfChangeRequestWithEmailIds.get(chnRequest.Id).add(chnRequest.Release__r.Environment_Manager__r.Email);
                             }
                             
                             if(chnRequest.Release__r.Release_Manager__c != null && 
                                chnRequest.Release__r.Release_Manager__r.Email != null)
                             {
                                 mapOfChangeRequestWithEmailIds.get(chnRequest.Id).add(chnRequest.Release__r.Release_Manager__r.Email);
                             }
                         } 
                         }
                     }

                     if(chnRequest.SFDC_Modifications6__r.size() > 0)
                     {
                         for(IS_System_Modification__c systemComp : chnRequest.SFDC_Modifications6__r){
                             IS_System_Modification__c systmComp = new IS_System_Modification__c();
                             systmComp.Id = systemComp.Id;
                             systmComp.Delete_from_Design__c = true;
                             systemComponentList.add(systmComp);
                         } 
                     }  
                 }
                 
                 if(systemComponentList.size() > 0)
                 { 
                     //Bypass all trigger
                     Util.ByPassAllTriggers = true;
                     update systemComponentList;
                     //Bypass all trigger
                     Util.ByPassAllTriggers = false;   
                 }
                 
                 //Bypass all trigger
                 Util.ByPassAllTriggers = true;  
                 if(changeRequestTobeUpdate.size() > 0)
                     update changeRequestTobeUpdate;
                 //Bypass all trigger
                 Util.ByPassAllTriggers = false;  
                 
                 if(mapOfChangeRequest.size() > 0 && mapOfChangeRequestWithEmailIds.size() >0)
                 {
                     SFDCChangeRequestTriggerHelper.sendEmails(mapOfChangeRequest,mapOfChangeRequestWithEmailIds);
                     bypassNotification = true;
                 }     
             }    
        }
    }
   
    
    public static void sendEmails(Map<Id,SFDC_Change_Request__c> mapOfChangeRequest, Map<Id,List<String>> mapOfChangeRequestWithEmailIds)
    {
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
		if(mapOfChangeRequest.size() > 0 && mapOfChangeRequestWithEmailIds.size()>0)
        {
            for(SFDC_Change_Request__c changeRequest : mapOfChangeRequest.values()){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(mapOfChangeRequestWithEmailIds.get(changeRequest.Id));
                mail.setSubject('Change Request '+ changeRequest.Name +' has been cancelled');
                String body = 'Change Request '+ changeRequest.Name +' has been cancelled and mods have been removed from the release manifest. <br><br> Name of person cancelling: '+ changeRequest.LastModifiedBy.Name + ' <br><br>If you have any questions, please see the person who cancelled CR, noted above. <br><br> Thank you!';
                mail.setHtmlBody(body);
                mails.add(mail);
            }
            
        }
        
        if(mails.size() > 0){
            //system.assert(false,mails);
           Messaging.sendEmail(mails);  
        }  
    }
    
    /**
     * description  :   This method is used to show error if No modification is added on CR befpre moving the status to QA
     * 
     * @param       :   List of change requests currently in context
     *              
     * @return      :   void 
     * 
     * Created BY   :   V_1.1 - Added By Neha Sharma - CR-20201208-14728 - 8/3/2021
     */
    public static void validationOnCRStatusChange (List<SFDC_Change_Request__c> newChangeRequests,Map<Id, SFDC_Change_Request__c> mapOldChangeRequests) {
    	  
        Set<String> setOfCRStatus = new Set<String>{'07-In Dev QA','08-To Test Sandbox','09-In IS QA','10-In UAT','11-Ready for Deployment'};
        Set<Id> setOfChangeRequestId = new Set<Id>();
        Map<Id,List<IS_System_Modification__c>> mapOfSystemModification = new Map<Id,List<IS_System_Modification__c>>(); 
        
         //loop through the change request
         for(SFDC_Change_Request__c changeRequest : newChangeRequests) {
             
            //Check if CR is mark as cancelled and Change Request Level is L1/L2
            if(mapOldChangeRequests != null  && setOfCRStatus.contains(changeRequest.Status__c) && 
               changeRequest.Status__c != mapOldChangeRequests.get(changeRequest.Id).Status__c )
            {
                
                setOfChangeRequestId.add(changeRequest.Id);
            }
             
             if(setOfChangeRequestId.size() > 0){
                 for(IS_System_Modification__c sysmod : [Select Id,Delete_from_Design__c,Change_Request__c,Change_Request__r.status__c FROM IS_System_Modification__c WHERE Change_Request__c IN: setOfChangeRequestId])
                 {
                     if(!mapOfSystemModification.containsKey(sysmod.Change_Request__c)){
                         mapOfSystemModification.put(sysmod.Change_Request__c,new List<IS_System_Modification__c>{});
                     }
                     mapOfSystemModification.get(sysmod.Change_Request__c).add(sysmod);
                 }
                 
                 if(newChangeRequests.size() > 0){
                     for(SFDC_Change_Request__c cRequest : newChangeRequests) {
                         if(!mapOfSystemModification.containsKey(cRequest.Id) ){
                             cRequest.addError('Before advancing the status of this change request, please ensure all modifications are included.');
                         }
                     }
                 }
             }  
         }
    }
}