/*
Purpose         :   Controller class for SLA Tracking Component and Customize SLA Tracking Component screens. 
Created By      :   Abhinav Sharma
Created Date    :   07/27/2020
Current Version :   v1.0
Revision Log    :   V_1.0 Created - CR-20200717-14438
*/
public without sharing class SLATrackingController 
{    
    @AuraEnabled(cacheable=true)
    public static LightningResponseEntity fetchproductionTrackingInfo(String recordId)
    {
        LightningResponseEntity res = new LightningResponseEntity();
        try 
        {
            if(string.isNotBlank(recordId))
            {
                List<Production_Tracking__c> pTrackings = [SELECT Id,Proof_File_Received_DateTime__c,
                                                           Proof_Pending_Approval_DateTime__c,Actual_Mail_Date__c,
                                                           Proof_Approved_DateTime__c,Live_Proof_File_Received_DateTime__c,
                                                           Job_Ticket__r.Vendor_Type__c,
                                                           Live_Proof_Pending_Approval_DateTime__c,
                                                           ReadyforPrint_LP_Approval_DateTime__c,Planned_Mail_Date__c,
                                                           Art_Received_by_Vendor__c,Data_Received_by_Vendor__c,
                                                           Live_Proofs_Approved__c,Live_Proofs_Received__c,
                                                           Proof_Approved__c,Proof_Received__c
                                                           FROM Production_Tracking__c 
                                                           WHERE Id =: recordId 
                                                           AND Status__c =: Label.SLA_PT_STATUS 
                                                           AND RecordType.DeveloperName = 'Mail_Shop'
                                                           AND Job_Ticket__r.Vendor_Type__c =: Constants.VENDOR_TYPE_DIGITAL];
                if(pTrackings != null && pTrackings.size() > 0)
                {
                    Map<Integer,SLA_Tracking__mdt> mapOfSLATracking = new Map<Integer,SLA_Tracking__mdt>();
                    for(SLA_Tracking__mdt sTrackingSetting : [SELECT Id,Label,To_Key_DateTime__c,Consider_To_Date__c,
                                                              From_Key_DateTime__c,Status_Field_Name__c,
                                                              Time_Format__c,Help_Text__c,Order__c 
                                                              FROM SLA_Tracking__mdt
                                                              WHERE Order__c != null])
                    {
                        mapOfSLATracking.put(Integer.valueOf(sTrackingSetting.order__c), sTrackingSetting);
                    }
                    if(mapOfSLATracking != null && mapOfSLATracking.size() > 0)
                    {
                        List<SLAWrapper> SLAWrapperList = new List<SLAWrapper>();
                        for(Integer i = 1; i <= (mapOfSLATracking.values()).size() ; i++)
                        {
                            SLA_Tracking__mdt slaTracking = mapOfSLATracking.get(i);
                            SLAWrapper wrap = new SLAWrapper();
                            Decimal timediff = 0.0;
                            DateTime fromDateTime;
                            DateTime toDateTime;
                            
                            //Setting status on the basis of actual mail date v/s planned mail date
                            wrap.actualMailDate = pTrackings[0].Actual_Mail_Date__c != null ? (pTrackings[0].Actual_Mail_Date__c).format() : '' ;
                            if(pTrackings[0].Planned_Mail_Date__c != null && pTrackings[0].Actual_Mail_Date__c != null){
                                if(pTrackings[0].Actual_Mail_Date__c == pTrackings[0].Planned_Mail_Date__c)
                                {
                                    wrap.status = Label.SLA_STATUS_ON_TIME;
                                }
                                else if(pTrackings[0].Actual_Mail_Date__c < pTrackings[0].Planned_Mail_Date__c)
                                {
                                    Integer days = pTrackings[0].Actual_Mail_Date__c.daysBetween( pTrackings[0].Planned_Mail_Date__c);
                                    wrap.status = Label.SLA_STATUS_EARLY + + ' ('+string.valueOf(days)+'d)';
                                }
                                else if(pTrackings[0].Actual_Mail_Date__c > pTrackings[0].Planned_Mail_Date__c)
                                {
                                    Integer days = pTrackings[0].Planned_Mail_Date__c.daysBetween( pTrackings[0].Actual_Mail_Date__c);
                                    wrap.status = Label.SLA_STATUS_LATE + ' ('+string.valueOf(days)+'d)';
                                }
                            }
                            
                            
                            //Check if datatype of field is of date type then convert it to datetime
                            if(pTrackings[0].get(slaTracking.From_Key_DateTime__c) != null && PrintmisUtility.checkDataType(Constants.PT_OBJECT_API_NAME,slaTracking.From_Key_DateTime__c) == Constants.SLA_DATE)
                            {
                                fromDateTime = DateTime.newInstance(Date.valueOf(pTrackings[0].get(slaTracking.From_Key_DateTime__c)).Year(),
                                                                    Date.valueOf(pTrackings[0].get(slaTracking.From_Key_DateTime__c)).Month(),
                                                                    Date.valueOf(pTrackings[0].get(slaTracking.From_Key_DateTime__c)).Day());
                            }
                            else
                            {
                                fromDateTime = DateTime.valueOf(pTrackings[0].get(slaTracking.From_Key_DateTime__c));
                            }
                            
                            
                            if( pTrackings[0].get(slaTracking.To_Key_DateTime__c) != null && PrintmisUtility.checkDataType(Constants.PT_OBJECT_API_NAME,slaTracking.To_Key_DateTime__c) == Constants.SLA_DATE)
                            {
                                toDateTime = DateTime.newInstance(Date.valueOf(pTrackings[0].get(slaTracking.To_Key_DateTime__c)).Year(),
                                                                  Date.valueOf(pTrackings[0].get(slaTracking.To_Key_DateTime__c)).Month(),
                                                                  Date.valueOf(pTrackings[0].get(slaTracking.To_Key_DateTime__c)).Day());
                            }
                            else
                            {
                                toDateTime = DateTime.valueOf(pTrackings[0].get(slaTracking.To_Key_DateTime__c));
                            }
                           
                            
                            //Calculate the SLA Time in days or Hours
                            timediff = PrintmisUtility.calculateTimeDifference(fromDateTime,toDateTime,slaTracking.Time_Format__c);
                            
                            if(slaTracking.Time_Format__c == Label.Days)
                            { 
                                wrap.slaTime = timediff != null ?  ((timediff < 0) ? '' : String.valueOf(timediff)+'d') : '';
                            }
                            else if(slaTracking.Time_Format__c == Label.Hours)
                            {
                                wrap.slaTime = timediff != null ? ((timediff < 0) ? '' : String.valueOf(timediff)+'h') : '';
                            }

                            //calculate time of Complete 
                            if(slaTracking.Consider_To_Date__c == true){
                                wrap.dateOfCompleted = toDateTime != null ? toDateTime.format(Label.SLA_TRACKING_DATE_OF_COMPLTE_FORMAT) : '';   
                            }
                            else {
                                wrap.dateOfCompleted = fromDateTime != null ? fromDateTime.format(Label.SLA_TRACKING_DATE_OF_COMPLTE_FORMAT) : '';
                            }

                            wrap.milestoneName = slaTracking.Label; 
                            wrap.slaStatus = String.valueOf(pTrackings[0].get(slaTracking.Status_Field_Name__c));
                            wrap.statusColorClass = String.valueOf(pTrackings[0].get(slaTracking.Status_Field_Name__c)) == 'Late' ? 'slds-text-color_error' : 'slds-text-color_default';
                            wrap.helpText = slaTracking.Help_Text__c;
                            SLAWrapperList.add(wrap);
                        }
                        res.setBody(SLAWrapperList);
                        res.setSuccess(true);
                        return res;
                    }
                    else
                    {
                        res.setMessage(Label.No_SLA_Custom_Metadata_Records);
                        res.setSuccess(true);
                        return res;
                    }
                }
                else
                {
                    res.setMessage(Label.No_SLA_Records);
                    res.setSuccess(true);
                    return res; 
                }
            }
            else
            {
                res.setError(Label.Insufficient_Access_To_RecordId);
                return res;                 
            }    
        }
        catch (Exception ex) 
        {
            //{"isSuccess":false,"message":"I am an error.","status":"error"}
            if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
            {
                res.setError(ex.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': '));
            }
            else 
            {
                res.setError(ex.getMessage());
            }
            return res;
        }
    }
    
    public class SLAWrapper
    {
        @auraEnabled public String milestoneName {get; set;}
        @auraEnabled public String dateOfCompleted {get; set;}
        @auraEnabled public String slaTime {get; set;}
        @auraEnabled public String slaStatus {get; set;}
        @auraEnabled public String status {get; set;}
        @auraEnabled public String actualMailDate {get; set;}
        @auraEnabled public String helpText {get; set;}
        @auraEnabled public String statusColorClass {get; set;}
        
        public SLAWrapper()
        {
            milestoneName = '';
            dateOfCompleted = '';
            slaTime = '';
            SLAStatus = '';
        }
    }
}