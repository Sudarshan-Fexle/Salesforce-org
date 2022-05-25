/*
Purpose         :   Controller class for Milestone Tracking Component and Customize Milestone Tracking Component screens. 

Created By      :   Abhinav Sharma

Created Date    :   07/27/2020

Current Version :   v1.0

Revision Log    :   V_1.0 Created - CR-20200717-14331
                :   V_1.1 Modified by - Abhinav Sharma - 10/12/2020 - CR-20200915-14512 - Added logic to not calculate status on the basis of "Art/Proof approval", if  "Art/Proof approval" stage are skip
*/
public without sharing class MilestoneTrackingController 
{    
    @AuraEnabled(cacheable=true)
    public static List<MilestoneWithStatusWrapper> fetchproductionTrackingInfo(String recordId)
    {
        //Boolean variable hold the info that row will highlight 
        Boolean hightlightRow = false;
        
        //Variable to hold the status of MilestoneTrackingComponent
        String status  = '';
        
        List<Production_Tracking__c> pTrackingList = new List<Production_Tracking__c>();
        List<MilestoneWithStatusWrapper>  milestoneWithStatusWrapperList = new List<MilestoneWithStatusWrapper>(); 
        List<MilestoneWrapper>  milestoneWrapperList = new List<MilestoneWrapper>();
        Map<Integer,Milestone_Tracking__mdt> mapOfMilestoneTraking = new Map<Integer,Milestone_Tracking__mdt>();
        
        if(String.isNotBlank(recordId))
        {
            for(Milestone_Tracking__mdt milestone : [SELECT Id,Order__c,Due_Date_Label__c,Days__c,Help_Text__c,Status__c,
                                                     Status_Details__c,PT_Due_Date_Field_Name__c 
                                                     FROM Milestone_Tracking__mdt 
                                                     WHERE order__c != null 
                                                     AND Operation_Type__c = 'Component'])
            {
                mapOfMilestoneTraking.put(Integer.valueOf(milestone.order__c), milestone);
            }
            
            if(mapOfMilestoneTraking.size() > 0) 
            {	//Modified by - Abhinav Sharma - 10/12/2020 - CR-20200915-14512
                List<Job_Ticket__c> jobtickets = [SELECT Id,
                                                  Active_Production_Tracking__r.Status_Detail__c,
                                                  Active_Production_Tracking__r.status__c,
                                                  Active_Production_Tracking__r.Planned_Mail_Date__c,
                                                  Active_Production_Tracking__r.Art_Due_to_Vendor_Date__c,
                                                  Active_Production_Tracking__r.Live_Proof_Approval_Due_Date__c,
                                                  Active_Production_Tracking__r.Data_Due_to_Vendor_Date__c,
                                                  Active_Production_Tracking__r.Proof_Approval_Date__c,
                                                  Active_Production_Tracking__r.New_Art__c,
                                                  Active_Production_Tracking__r.Previous_Production_Tracking__c,
                                                  Active_Production_Tracking__r.Previous_Production_Tracking__r.Mail_Shop_Vendor__c,
                                                  Active_Production_Tracking__r.Mail_Shop_Vendor__c,
                                                  Active_Production_Tracking__c
                                                  FROM job_Ticket__c 
                                                  WHERE Id =: recordId 
                                                  AND Active_Production_Tracking__c != null
                                                  AND Active_Production_Tracking__r.Planned_Mail_Date__c != null];
                if(jobtickets.size() > 0)
                {
                    pTrackingList.add(jobtickets[0].Active_Production_Tracking__r); 
                }
                
            	if(pTrackingList.size() > 0)
            	{
                	for(Integer i = 1; i <= (mapOfMilestoneTraking.values()).size() ; i++)
                	{
                        Milestone_Tracking__mdt milestone = mapOfMilestoneTraking.get(i);
                        MilestoneWrapper wrap = new MilestoneWrapper();
                        List<String> statusDetail = (milestone.Status_Details__c).split(Constants.COMMA);
                    	wrap.mailDueDate =  Util.formatDate(pTrackingList[0].Planned_Mail_Date__c, Integer.valueOf(milestone.Days__c));
                   
                        
                        Date dueDate = pTrackingList[0].Planned_Mail_Date__c.addDays(-Integer.valueOf(milestone.Days__c));
                        String pTStatusDetails = pTrackingList[0].Status_Detail__c != null ? pTrackingList[0].Status_Detail__c : '';
                        
			//Modified by - Abhinav Sharma - 10/12/2020 - CR-20200915-14512
                        //Check status is "Completed"
                        if((Date.valueOf(pTrackingList[0].get(milestone.PT_Due_Date_Field_Name__c)) != null ||
                            Date.valueOf(pTrackingList[0].get(milestone.PT_Due_Date_Field_Name__c)) < pTrackingList[0].Planned_Mail_Date__c))
                        {
                             wrap.isComplete = true;  
                        }
                    
                        
                        //Check for nextHighLightRow
                        if(milestone.order__c > 1 && wrap.isComplete == false 
                           && milestoneWrapperList[i-2].isComplete == true)
                        {
                            wrap.nextHighLightRow = true;
                        }   
                        else if(Integer.valueOf(milestone.order__c) == 1 && wrap.isComplete == false)
                        {
                           wrap.nextHighLightRow = true; 	
                        }
                        
                        
                        //Check status is "At Risk" or "On Track"
                        if(wrap.nextHighLightRow == true){
                                //Modified by - Abhinav Sharma - 10/12/2020 - CR-20200915-14512 - Added for skip the "Art/Proof approval" status on milestone tracking
                                if((milestone.Due_Date_Label__c == 'Art Due To Vendor' || milestone.Due_Date_Label__c == 'Proof Approval Due' ) && 
                                   (pTrackingList[0].New_Art__c == false && pTrackingList[0].Previous_Production_Tracking__c != null  &&
                                    pTrackingList[0].Mail_Shop_Vendor__c == pTrackingList[0].Previous_Production_Tracking__r.Mail_Shop_Vendor__c))
                                {
                                    wrap.isDirectLiveProof = true;
                                    if(pTrackingList[0].Planned_Mail_Date__c <= system.today())
                                    {
                                        status = Label.Milestone_Tracking_Status_At_Risk;
                                    }
                                    else if(pTrackingList[0].Planned_Mail_Date__c > system.today())
                                    {
                                        status = Label.Milestone_Tracking_Status_On_Track;
                                    }
                                    
                                }
                                else if(status != Label.Milestone_Tracking_Status_At_Risk
                                        && (dueDate > system.today() || 
                                            (pTrackingList[0].Planned_Mail_Date__c > system.today() && Date.valueOf(pTrackingList[0].get(milestone.PT_Due_Date_Field_Name__c)) != null && 
                                             Date.valueOf(pTrackingList[0].get(milestone.PT_Due_Date_Field_Name__c)) < pTrackingList[0].Planned_Mail_Date__c)))
                                {
                                    status = Label.Milestone_Tracking_Status_On_Track;
                                }
                                else if(dueDate <= system.today())
                                {
                                    status = Label.Milestone_Tracking_Status_At_Risk;
                                }
                            }
                            wrap.milestoneTracking = milestone;
                            wrap.plannedMailDate =  Util.formatDate(pTrackingList[0].Planned_Mail_Date__c,0);
                            milestoneWrapperList.add(wrap);
                        }
                        
                        Boolean highLightRow = false;
                        for(Integer i = milestoneWrapperList.size()-1 ; i >= 0 ; i--)
                        {
			    //Modified by - Abhinav Sharma - 10/12/2020 - CR-20200915-14512
                            if(milestoneWrapperList[i].isDirectLiveProof == false && milestoneWrapperList[i].milestoneTracking.order__c > 2 && milestoneWrapperList[i].isComplete == true) {
                                highLightRow = true;
                            }
                            if(highLightRow == true){
                                milestoneWrapperList[i].nextHighLightRow = false;
                            }
                            if(milestoneWrapperList[i].nextHighLightRow == true && highLightRow == false)
                            {
                                highLightRow = true;
                            }  
                            
                        }
                        
                        MilestoneWithStatusWrapper wrap = new MilestoneWithStatusWrapper();
                        if(String.isBlank(status) && pTrackingList[0].Planned_Mail_Date__c <= system.today()){
                            wrap.status = Label.Milestone_Tracking_Status_At_Risk;
                        }
                        else if(String.isBlank(status) && pTrackingList[0].Planned_Mail_Date__c > system.today()){
                            wrap.status = Label.Milestone_Tracking_Status_On_Track;
                        }
                        else {
                            wrap.status = status;
                        }
                        wrap.mileStoneWrapperList = milestoneWrapperList;
                        
                        milestoneWithStatusWrapperList.add(wrap);
                    }
                    else
                    {
                        return null;
                    }
                }
                else
                {
                    return null;
                }
           
        } 
        return milestoneWithStatusWrapperList;
    
    }
    
    public class MilestoneWrapper
    {
    	//Modified by - Abhinav Sharma - 10/12/2020 - CR-20200915-14512
        @auraEnabled public Milestone_Tracking__mdt milestoneTracking {get; set;}
        @auraEnabled public String plannedMailDate {get; set;}
        @auraEnabled public String  mailDueDate {get; set;}
        @auraEnabled public boolean nextHighLightRow {get; set;}
        @auraEnabled public boolean isComplete {get; set;}
        @auraEnabled public boolean isDirectLiveProof {get; set;}
        
        MilestoneWrapper() 
        {
            milestoneTracking = new Milestone_Tracking__mdt();
            nextHighLightRow = false;
            isComplete = false;
            plannedMailDate = '';
            mailDueDate = '';
            isDirectLiveProof = false;
        }
    } 
    
    public class MilestoneWithStatusWrapper
    {
        @auraEnabled public String status {get; set;}
        @auraEnabled public List<MilestoneWrapper> mileStoneWrapperList {get; set;}
        
        MilestoneWithStatusWrapper() 
        {
            status = '';
            mileStoneWrapperList = new List<MilestoneWrapper>();
        }
    }
}