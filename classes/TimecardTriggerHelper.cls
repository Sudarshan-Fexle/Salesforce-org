/**
*  @description :   This class is used to perform all the Implimentation of manipulation on pse__Timecard_Header__c Object
* 
* Created By    :   Nikita Kumari
* 
* Revision Log  :   V1.0 - Created - 06/10/2021 - CR-20210518-15162.
*		        :   V1.1 - Modified By - Nikita kumari - 09/21/2021 - CR-20210917-15447 - Issue with Actual fields not populating correctly on PSA Projects
* 				:   V1.2 - Modified By - Chirag Soni - 05/20/2022 - CR-20220405-16067 - updated logic on rollUpTimeOnPSAProject() method.
**/
public class TimecardTriggerHelper {
    
    public static Boolean bypassRollUpTimeOnPSAProject = false;
    public static Set<String> setOfEngagemenTypesBypass = new Set<String> {'EDH Gratis Premium Service Hours'};
    /**
    * 
    *   @description    :  This mehtod is Used to populate the Actual Hours corresponding its year on the PSA Project Object
    *
    *   @args           :  List<pse__Proj__c> newProjects
    *
    *   @return         :  void
    *
    *   @revision Log   :  V1.1 - Created By - Nikita Kumari - 06/10/2021 - CR-20210518-15162 
    * 			        :  V1.2 - Modified By - Nikita kumari - 09/21/2021 - CR-20210917-15447 - Issue with Actual fields not populating correctly on PSA Projects
    * 					:  V1.3 - Modified By - Chirag Soni - 05/20/2022 - CR-20220405-16067 - Updated logic to skip hours calculation if Engagement_Type__c is 'EDH Gratis Premium Service Hours'
    * 
    **/ 
    public static void rollUpTimeOnPSAProject(List<pse__Timecard_Header__c> newTimecards, Map<Id, pse__Timecard_Header__c> oldMapOfTimecards) {
                
        //bypass rollUpTimeOnPSAProject method
        if(bypassRollUpTimeOnPSAProject) return;
        
        //to hold PSA Project Ids
        Set<Id> psaTimecardIds = new Set<Id>();
        Map<Id, pse__Proj__c> mapPSAProjectToBeUpdate = new Map<Id, pse__Proj__c>();
        
        //Modified By - Chirag Soni - 05/20/2022 - CR-20220405-16067 - Updated logic to skip hours calculation if Engagement_Type__c is 'EDH Gratis Premium Service Hours'-- starts here
        for(pse__Timecard_Header__c timecard : newTimecards)
        {
            //update/insert case
            if(timecard.pse__Status__c == Constants.TIMECARD_STATUS_APPROVED &&
               (oldMapOfTimecards == null || (oldMapOfTimecards != null
                                              && oldMapOfTimecards.get(timecard.Id).pse__Status__c != timecard.pse__Status__c)))
            {
                psaTimecardIds.add(timecard.Id);                    
            }
        }
        
        if(!psaTimecardIds.isEmpty())
        {
            for(pse__Timecard_Header__c timecard : [SELECT id,pse__Project__c, pse__Milestone__c, pse__Milestone__r.EAB_Deployment__c,
                                                    pse__Milestone__r.EAB_Deployment__r.Engagement_Type__c FROM pse__Timecard_Header__c Where Id IN : psaTimecardIds])
            {
                //check project if project is nll
                if(timecard.pse__Project__c != null)
                {
                    if(timecard.pse__Milestone__c != null && timecard.pse__Milestone__r.EAB_Deployment__c != null &&
                       setOfEngagemenTypesBypass.contains(timecard.pse__Milestone__r.EAB_Deployment__r.Engagement_Type__c))
                        continue;
                    else
                        mapPSAProjectToBeUpdate.put(timecard.pse__Project__c, new pse__Proj__c());  
                }
            }
        }
        //Modified By - Chirag Soni - 05/20/2022 - CR-20220405-16067 - Updated logic to skip hours calculation if Engagement_Type__c is 'EDH Gratis Premium Service Hours'-- ends here
        
        //check list and map size            
        if(psaTimecardIds.size() > 0 && mapPSAProjectToBeUpdate.size() > 0 && mapPSAProjectToBeUpdate.keySet().size() > 0){
            
            //Added By - Nikita kumari - 09/21/2021 - CR-20210917-15447 - Issue with Actual fields not populating correctly on PSA Projects
            Boolean populateTotalHoursOnProject = false;
            //to hold previous project Id
            Id prePSAProjId = null;
            
            //get Date time record which is related to approved Timecard
            for(pse__Time_Date__c timeDate : [Select pse__Hours__c, pse__Date__c, pse__Timecard__r.pse__Project__c, pse__Timecard__c,
                                              pse__Timecard__r.pse__Project__r.Year_1_Start_Date__c,pse__Timecard__r.pse__Project__r.Year_1_End_Date__c,
                                              pse__Timecard__r.pse__Project__r.Year_2_Start_Date__c,pse__Timecard__r.pse__Project__r.Year_2_End_Date__c,
                                              pse__Timecard__r.pse__Project__r.Year_3_Start_Date__c,pse__Timecard__r.pse__Project__r.Year_3_End_Date__c,
                                              pse__Timecard__r.pse__Project__r.Year_4_Start_Date__c,pse__Timecard__r.pse__Project__r.Year_4_End_Date__c,
                                              pse__Timecard__r.pse__Project__r.Year_5_Start_Date__c,pse__Timecard__r.pse__Project__r.Year_5_End_Date__c,
                                              pse__Timecard__r.pse__Project__r.Year_1_Actual_Hours__c,
                                              pse__Timecard__r.pse__Project__r.Year_2_Actual_Hours__c,
                                              pse__Timecard__r.pse__Project__r.Year_3_Actual_Hours__c,
                                              pse__Timecard__r.pse__Project__r.Year_4_Actual_Hours__c,
                                              pse__Timecard__r.pse__Project__r.Year_5_Actual_Hours__c
                                              FROM pse__Time_Date__c Where pse__Hours__c != 0
                                              And pse__Timecard__c != null ANd pse__Timecard__r.pse__Status__c = :Constants.TIMECARD_STATUS_APPROVED
                                              And pse__Timecard__r.pse__Project__c != null 
                                              AND pse__Timecard__c IN :psaTimecardIds
                                              And pse__Timecard__r.pse__Project__c IN :mapPSAProjectToBeUpdate.keySet()
                                              order by pse__Timecard__r.pse__Project__c DESC])
            {
                //Added By - Nikita kumari - 09/21/2021 - CR-20210917-15447 - Issue with Actual fields not populating correctly on PSA Projects
                //populating rollup from time date entry
                populateTotalHoursOnProject = true;
                
                if(mapPSAProjectToBeUpdate.containsKey(timeDate.pse__Timecard__r.pse__Project__c)) {
                    
                    //PSA Project
                    pse__Proj__c psaProj = mapPSAProjectToBeUpdate.get(timeDate.pse__Timecard__r.pse__Project__c);
                    
                    //to assign Actual Hours which is already exist
                    if(prePSAProjId == null || prePSAProjId != timeDate.pse__Timecard__r.pse__Project__c){
                        
                        prePSAProjId = timeDate.pse__Timecard__r.pse__Project__c;
                        psaProj.Id = timeDate.pse__Timecard__r.pse__Project__c;
                        psaProj.Year_1_Actual_Hours__c = timeDate.pse__Timecard__r.pse__Project__r.Year_1_Actual_Hours__c;
                        psaProj.Year_2_Actual_Hours__c = timeDate.pse__Timecard__r.pse__Project__r.Year_2_Actual_Hours__c;
                        psaProj.Year_3_Actual_Hours__c = timeDate.pse__Timecard__r.pse__Project__r.Year_3_Actual_Hours__c;
                        psaProj.Year_4_Actual_Hours__c = timeDate.pse__Timecard__r.pse__Project__r.Year_4_Actual_Hours__c;
                        psaProj.Year_5_Actual_Hours__c = timeDate.pse__Timecard__r.pse__Project__r.Year_5_Actual_Hours__c;
                    }
                    
                    //if date falls in between project Year 1 start and end date
                    if(timeDate.pse__Timecard__r.pse__Project__r.Year_1_Start_Date__c <= timeDate.pse__Date__c
                       && timeDate.pse__Timecard__r.pse__Project__r.Year_1_End_Date__c >= timeDate.pse__Date__c
                      ){
                          psaProj.Year_1_Actual_Hours__c = psaProj.Year_1_Actual_Hours__c == null ? timeDate.pse__Hours__c : psaProj.Year_1_Actual_Hours__c + timeDate.pse__Hours__c;
                      }
                    
                    //if date falls in between project Year 2 start and end date
                    if(timeDate.pse__Timecard__r.pse__Project__r.Year_2_Start_Date__c <= timeDate.pse__Date__c
                       && timeDate.pse__Timecard__r.pse__Project__r.Year_2_End_Date__c >= timeDate.pse__Date__c
                      ){
                          psaProj.Year_2_Actual_Hours__c = psaProj.Year_2_Actual_Hours__c == null ? timeDate.pse__Hours__c : psaProj.Year_2_Actual_Hours__c + timeDate.pse__Hours__c;
                      }
                    
                    //if date falls in between project Year 3 start and end date
                    if(timeDate.pse__Timecard__r.pse__Project__r.Year_3_Start_Date__c <= timeDate.pse__Date__c
                       && timeDate.pse__Timecard__r.pse__Project__r.Year_3_End_Date__c >= timeDate.pse__Date__c
                      ){
                          psaProj.Year_3_Actual_Hours__c = psaProj.Year_3_Actual_Hours__c == null ? timeDate.pse__Hours__c : psaProj.Year_3_Actual_Hours__c + timeDate.pse__Hours__c;
                      }
                    
                    //if date falls in between project Year 4 start and end date
                    if(timeDate.pse__Timecard__r.pse__Project__r.Year_4_Start_Date__c <= timeDate.pse__Date__c
                       && timeDate.pse__Timecard__r.pse__Project__r.Year_4_End_Date__c >= timeDate.pse__Date__c
                      ){
                          psaProj.Year_4_Actual_Hours__c = psaProj.Year_4_Actual_Hours__c == null ? timeDate.pse__Hours__c : psaProj.Year_4_Actual_Hours__c + timeDate.pse__Hours__c;
                      }
                    
                    //if date falls in between project Year 5 start and end date
                    if(timeDate.pse__Timecard__r.pse__Project__r.Year_5_Start_Date__c <= timeDate.pse__Date__c
                       && timeDate.pse__Timecard__r.pse__Project__r.Year_5_End_Date__c >= timeDate.pse__Date__c
                      ){
                          psaProj.Year_5_Actual_Hours__c = psaProj.Year_5_Actual_Hours__c == null ? timeDate.pse__Hours__c : psaProj.Year_5_Actual_Hours__c + timeDate.pse__Hours__c;
                      }
                    
                    mapPSAProjectToBeUpdate.put(psaProj.Id, psaProj);
                }
            }
            
            //Added By - Nikita kumari - 09/21/2021 - CR-20210917-15447 - Starts from here
            if(!populateTotalHoursOnProject){
                
                //get Date time record which is related to approved Timecard
                for(pse__Timecard__c timeCard : [select Id, pse__Total_Hours__c, pse__Start_Date__c, pse__End_Date__c,
                                                  pse__Project__r.Year_1_Start_Date__c, pse__Project__r.Year_2_Start_Date__c,
                                                  pse__Project__r.Year_3_Start_Date__c, pse__Project__r.Year_4_Start_Date__c,
                                                  pse__Project__r.Year_5_Start_Date__c, pse__Project__r.Year_1_End_Date__c,
                                                  pse__Project__r.Year_2_End_Date__c, pse__Project__r.Year_3_End_Date__c, 
                                                  pse__Project__r.Year_4_End_Date__c, pse__Project__r.Year_5_End_Date__c 
                                                  from pse__Timecard__c Where pse__Status__c = :Constants.TIMECARD_STATUS_APPROVED
                                                  And pse__Project__c != null 
                                                  //AND Id IN :psaTimecardIds // Commented By - Chirag Soni - CR-20220405-16067
                                                  AND pse__Timecard_Header__c IN :psaTimecardIds // Added By - Chirag Soni - CR-20220405-16067
                                                  And pse__Project__c IN :mapPSAProjectToBeUpdate.keySet()
                                                  order by pse__Project__c DESC])
                {
                                        
                    if(mapPSAProjectToBeUpdate.containsKey(timeCard.pse__Project__c)) {
                        
                        //PSA Project
                        pse__Proj__c psaProj = mapPSAProjectToBeUpdate.get(timeCard.pse__Project__c);
                        
                        //to assign Actual Hours which is already exist
                        if(prePSAProjId == null || prePSAProjId != timeCard.pse__Project__c){
                            
                            prePSAProjId = timeCard.pse__Project__c;
                            psaProj.Id = timeCard.pse__Project__c;
                            psaProj.Year_1_Actual_Hours__c = timeCard.pse__Project__r.Year_1_Actual_Hours__c;
                            psaProj.Year_2_Actual_Hours__c = timeCard.pse__Project__r.Year_2_Actual_Hours__c;
                            psaProj.Year_3_Actual_Hours__c = timeCard.pse__Project__r.Year_3_Actual_Hours__c;
                            psaProj.Year_4_Actual_Hours__c = timeCard.pse__Project__r.Year_4_Actual_Hours__c;
                            psaProj.Year_5_Actual_Hours__c = timeCard.pse__Project__r.Year_5_Actual_Hours__c;
                        }
                        
                        //if date falls in between project Year 1 start and end date
                        if(timeCard.pse__Project__r.Year_1_Start_Date__c <= timeCard.pse__Start_Date__c
                           && timeCard.pse__Project__r.Year_1_End_Date__c >= timeCard.pse__End_Date__c
                          ){
                              psaProj.Year_1_Actual_Hours__c = psaProj.Year_1_Actual_Hours__c == null ? timeCard.pse__Total_Hours__c : psaProj.Year_1_Actual_Hours__c + timeCard.pse__Total_Hours__c;
                          }
                        
                        //if date falls in between project Year 2 start and end date
                        if(timeCard.pse__Project__r.Year_2_Start_Date__c <= timeCard.pse__Start_Date__c
                           && timeCard.pse__Project__r.Year_2_End_Date__c >= timeCard.pse__End_Date__c
                          ){
                              psaProj.Year_2_Actual_Hours__c = psaProj.Year_2_Actual_Hours__c == null ? timeCard.pse__Total_Hours__c : psaProj.Year_2_Actual_Hours__c + timeCard.pse__Total_Hours__c;
                          }
                        
                        //if date falls in between project Year 3 start and end date
                        if(timeCard.pse__Project__r.Year_3_Start_Date__c <= timeCard.pse__Start_Date__c
                           && timeCard.pse__Project__r.Year_3_End_Date__c >= timeCard.pse__End_Date__c
                          ){
                              psaProj.Year_3_Actual_Hours__c = psaProj.Year_3_Actual_Hours__c == null ? timeCard.pse__Total_Hours__c : psaProj.Year_3_Actual_Hours__c + timeCard.pse__Total_Hours__c;
                          }
                        
                        //if date falls in between project Year 4 start and end date
                        if(timeCard.pse__Project__r.Year_4_Start_Date__c <= timeCard.pse__Start_Date__c
                           && timeCard.pse__Project__r.Year_4_End_Date__c >= timeCard.pse__End_Date__c
                          ){
                              psaProj.Year_4_Actual_Hours__c = psaProj.Year_4_Actual_Hours__c == null ? timeCard.pse__Total_Hours__c : psaProj.Year_4_Actual_Hours__c + timeCard.pse__Total_Hours__c;
                          }
                        
                        //if date falls in between project Year 5 start and end date
                        if(timeCard.pse__Project__r.Year_5_Start_Date__c <= timeCard.pse__Start_Date__c
                           && timeCard.pse__Project__r.Year_5_End_Date__c >= timeCard.pse__End_Date__c
                          ){
                              psaProj.Year_5_Actual_Hours__c = psaProj.Year_5_Actual_Hours__c == null ? timeCard.pse__Total_Hours__c : psaProj.Year_5_Actual_Hours__c + timeCard.pse__Total_Hours__c;
                          }
                        
                        mapPSAProjectToBeUpdate.put(psaProj.Id, psaProj);
                    }
                }
            }
            //Added By - Nikita kumari - 09/21/2021 - CR-20210917-15447 - Ends here
            
            if(mapPSAProjectToBeUpdate.values().size() > 0){
                
                Util.ByPassAllTriggers = true;
                Update mapPSAProjectToBeUpdate.values();
                bypassRollUpTimeOnPSAProject = true;
                Util.ByPassAllTriggers = false;
            }
        }
    }
    
}