/*
Purpose         :   Utility class for printmis generic methods

Created By      :   Abhinav Sharma

Created Date    :   08/5/2020

Current Version :   v1.0

Revision Log    :   V_1.0 Created - CR-20200717-14331
                    V_1.0 Modified By - Abhinav Sharma - 08/27/2020 - CR-20200817-14438 
*/
public with sharing class PrintmisUtility {
    
    public static List<Production_Tracking__c> checkPTrackingAtRiskOROnTrack(List<Production_Tracking__c> pTrackingList, Map<Integer,Milestone_Tracking__mdt> mapOfMilestoneTracking){
        
        List<Production_Tracking__c> productionTrackingList = new List<Production_Tracking__c>();
        Map<Integer,Boolean> mapOfMilestoneTrackingStatus = new Map<Integer,Boolean>();
        Map<Integer,Boolean> mapOfMilestoneTrackingNexthighlight = new Map<Integer,Boolean>();
        
        if(pTrackingList.size() > 0 && mapOfMilestoneTracking.size() > 0 ){
            for(Production_Tracking__c ptracking : pTrackingList){
                
                String status  = '';
                
                
                for(Integer i = 1; i <= (mapOfMilestoneTracking.values()).size() ; i++)
                {
                    Milestone_Tracking__mdt milestone = mapOfMilestoneTracking.get(i);
                    Boolean isComplete = false;
                    boolean nextHighLightRow = false;
                    
                    List<String> statusDetail = (milestone.Status_Details__c).split(Constants.COMMA);
                    
                    if( Date.valueOf(ptracking.get(milestone.PT_Due_Date_Field_Name__c)) == null 
                       && ptracking.Status__c == milestone.status__c 
                       && statusDetail.contains(ptracking.Status_Detail__c)
                      )
                    {
                        ptracking.put(milestone.PT_Due_Date_Field_Name__c, system.today());
                    }
                    
                    //Check status is "At Risk" or "On Track"
                    Date dueDate = ptracking.Planned_Mail_Date__c.addDays(-Integer.valueOf(milestone.Days__c));
                    
                    if((Date.valueOf(ptracking.get(milestone.PT_Due_Date_Field_Name__c)) != null &&
                        Date.valueOf(ptracking.get(milestone.PT_Due_Date_Field_Name__c)) < ptracking.Planned_Mail_Date__c))
                    {
                         if(milestone.order__c > 1 && mapOfMilestoneTrackingNexthighlight.size() >0 && mapOfMilestoneTrackingNexthighlight.get(i-1) == true)
                            {
                                isComplete = false;
                                mapOfMilestoneTrackingStatus.put(i,isComplete);
                            }   
                            else 
                            {
                                isComplete = true;
                                mapOfMilestoneTrackingStatus.put(i,isComplete);
                            }
                    }
                    
                    
                    //Check for nextHighLightRow
                    if(mapOfMilestoneTrackingStatus.size() > 0)
                    {
                        if(milestone.order__c > 1 && isComplete == false  && mapOfMilestoneTrackingStatus.size() > 0 && mapOfMilestoneTrackingStatus.get(i-1) == true)
                        {
                        	nextHighLightRow = true;
                            mapOfMilestoneTrackingNexthighlight.put(i,nextHighLightRow);
                        } 
                    }
                	else if(Integer.valueOf(milestone.order__c) == 1 && isComplete == false)
                	{
                    	nextHighLightRow = true;
                        mapOfMilestoneTrackingNexthighlight.put(i,nextHighLightRow);
               		}
                    
                    if(nextHighLightRow == true){
                        if(status != Label.Milestone_Tracking_Status_At_Risk
                           && (dueDate > system.today() || 
                               (ptracking.Planned_Mail_Date__c > system.today() && Date.valueOf(ptracking.get(milestone.PT_Due_Date_Field_Name__c)) != null && 
                                Date.valueOf(ptracking.get(milestone.PT_Due_Date_Field_Name__c)) < ptracking.Planned_Mail_Date__c)))
                        {
                            status = Label.Milestone_Tracking_Status_On_Track;
                        }
                        else if(dueDate <= system.today())
                        {
                            status = Label.Milestone_Tracking_Status_At_Risk;
                        }
                    }    
                }
                if(String.isBlank(status) && ptracking.Planned_Mail_Date__c > system.today()){
                        ptracking.Current_Condition__c = Label.Milestone_Tracking_Status_On_Track;
                 }
                else if(String.isBlank(status) && ptracking.Planned_Mail_Date__c <= system.today()){
                        ptracking.Current_Condition__c = Label.Milestone_Tracking_Status_At_Risk;
                }
                else{
                     ptracking.Current_Condition__c = status;
                }
                productionTrackingList.add(ptracking);
            }
            
        }
        
        return productionTrackingList;
        
    }
    
    /**
    *  Purpose         :	Method used to calculate the difference between two datetime field and return the no. of days and no. of hours.
    * 
    *  Revision Logs   :	V_1.0 - 08/27/2020 - CR-20200817-14438 - Abhinav Sharma - Created
    *                     
    **/
    public static Decimal calculateTimeDifference(DateTime fromDateTime, DateTime toDateTime, String daysOrHours)
    {
        Decimal timeDiff;
        if(fromDateTime != null && toDateTime != null)
        {
            Decimal diffOfTime = (fromDateTime.getTime() - toDateTime.getTime());
            if(daysOrHours == Label.Days && diffOfTime >= 0) 
            {
                timeDiff = (diffOfTime/(1000*60*60*24)).setScale(2);
            }
            
            if(daysOrHours == Label.Hours && diffOfTime >= 0) 
            {
            	timeDiff = (diffOfTime/(1000*60*60)).setScale(2);    
            }
            return timeDiff;  
        }
        else
        {
        	return timeDiff; 
        }
    }
    
    /**
    *  Purpose         :	Method used to return the data type of field on the basis of object and field name.
    * 
    *  Revision Logs   :	V_1.0 - 08/27/2020 - CR-20200817-14438 - Abhinav Sharma - Created
    *                     
    **/
     public static String checkDataType(String objectName, String fieldName)
    {
        String dataType = '';
        if(string.isNotBlank(objectName) && string.isNotBlank(fieldName))
        {
            Schema.DescribeSObjectResult d = DatabaseUtilities.getObjectDescribeOnBasisOfObjectName(objectName);
            dataType = String.valueOf(d.fields.getMap().get(fieldName).getDescribe().getType());
        }
        return dataType;  
    }
}