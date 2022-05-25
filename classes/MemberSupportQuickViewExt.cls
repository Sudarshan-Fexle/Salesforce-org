/**
 *  Description     :    Methods to support the memberSupportQuickView LWC Component
 * 
 *  Revision Logs   :    V_1.0 - 11/27/2019 - Victor Hanson - Created - CR-20191127-13537
**/ 
public with sharing class MemberSupportQuickViewExt {
	
    public static final String SITE_ISSUE_CATEGORY_DATA_SITE_ISSUE = 'Data/Site Issue';
    public static final String SITE_ISSUE_CATEGORY_CHANGE_REQUEST = 'Change Request';
    public static final String RECORD_TYPE_DEV_NAME_SSC = 'SSC_RMS';
    public static final Id SITE_ISSUE_RT_ID_SSC_RMS = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_DEV_NAME_SSC).getRecordTypeId();
    
    public static List<String> ignoreStatus {
        get {
            if (ignoreStatus == null) ignoreStatus = Label.MS_QuickView_Status_Filter.split(',');
            return ignoreStatus;
        }
        set;
    }
       
    
    /**
     *  Description     :  get all open tickets
     *
     *	Revision Logs   :  11/27/2019 - Victor Hanson - Created
    **/
    @AuraEnabled(cacheable=true)
    public static dataWrapper getTicketData(Id recordId, String recordTypeName){
        dataWrapper dWrapper = new dataWrapper();
        
        //get project created date
        List<Project__c> projects = [SELECT Id, CreatedDate FROM Project__c WHERE Id = :recordId];
        dWrapper.createdDate = Date.valueOf(projects[0].CreatedDate);
        String soql = 'SELECT Id, RecordType.Name, RecordTypeId FROM Site_Issue__c ' +
            	' WHERE Project__c = :recordId' +
                ' AND Site_Issue_Close_Date__c = null ' +
            	' AND Actual_Resolution_Date__c = null ' +
                ' AND Status__c NOT IN :ignoreStatus ' +
            	' AND (NOT Status__c LIKE \'Resolved%\')';
        List<Site_Issue__c> sIssues = database.query(soql);
        for (Site_Issue__c si : sIssues)
        {
            dWrapper.numOpenTickets++;
        }
        
        return dWrapper;
    }
    
    /**
     *  Description     :  get all open Cases related to this project
     *
     *	Revision Logs   :  11/27/2019 - Victor Hanson - Created
    **/
    @AuraEnabled(cacheable=true)
    public static Integer getOpenCases(Id recordId){
        return [SELECT COUNT() FROM Case 
                WHERE Project_Source_MS__c = :recordId
                AND IsClosed = false];
    }
    
    /**
     *  Description     :  search all open tickets opened in the past x days
     *
     *	Revision Logs   :  11/27/2019 - Victor Hanson - Created
    **/
    @AuraEnabled(cacheable=true)
    public static dataWrapper searchTickets(Id recordId, String startDate, String endDate, String recordTypeName){
        
        Date sDate;
        Date eDate;
        dataWrapper dWrapper = new dataWrapper();
        
        String soql = 'SELECT Id, Status__c, Site_Issue_Priority__c, Support_Category__c, Site_Issue_Close_Date__c, Site_Issue_Created_Date__c, Elapsed_Opened_to_Act_Resolution_Date__c FROM Site_Issue__c ' +
            		  'WHERE Project__c = :recordId AND Status__c NOT IN :ignoreStatus ';
        if (String.isNotBlank(recordTypeName)) {
            soql += ' AND RecordType.Name = \'' + recordTypeName + '\'';
        }
        
        //populate Open Tickets for RecordType (execute this query before populating start/end)
        List<Site_Issue__c> openIssuesByRecordType = database.query(soql + ' AND Site_Issue_Close_Date__c = null AND Actual_Resolution_Date__c = null AND (NOT Status__c LIKE \'Resolved%\')');
        
        dWrapper.numOpenTicketsRT = openIssuesByRecordType.size();
        
        if (String.isNotEmpty(startDate)) {
            sDate = Date.valueOf(startDate);
            soql += ' AND CreatedDate >= :sDate ';
        }
        if (String.isNotEmpty(endDate)) {
            eDate = Date.valueOf(endDate);
            soql += ' AND CreatedDate <= :eDate ';
        }
            		  
        //query site issues that meet the criteria
        List<Site_Issue__c> siteIssues = database.query(soql);
        
        //define list of critical or high priority values
        Set<String> priorityHighOrCritical = new Set<String>{ 'High', 'Critical' };
        
        for (Site_Issue__c si : siteIssues) {
            //count the number of high or critical tickets
            if (priorityHighOrCritical.contains(si.Site_Issue_Priority__c))
                dWrapper.numHighOrCriticalTickets_Last_N_Days++;
            
            //if this is closed, calculate SLA
            if (si.Elapsed_Opened_to_Act_Resolution_Date__c != null) {
                
                dWrapper.numAll++;
                dWrapper.avgAllResolution += integer.valueOf(si.Elapsed_Opened_to_Act_Resolution_Date__c);
                
                //count values to calculate SLA
                if (si.Support_Category__c == SITE_ISSUE_CATEGORY_DATA_SITE_ISSUE) {
                    dWrapper.numDataIssue++;
                    dWrapper.avgDataIssueResolution += integer.valueOf(si.Elapsed_Opened_to_Act_Resolution_Date__c);
                }
                else if (si.Support_Category__c == SITE_ISSUE_CATEGORY_CHANGE_REQUEST) {
                    dWrapper.numChangeRequest++;
                    dWrapper.avgChangeRequestResolution += integer.valueOf(si.Elapsed_Opened_to_Act_Resolution_Date__c);
                }
            }
        }
        
        //calculate the average SLA
        if (dWrapper.numAll > 0) {
            Decimal decimalAvgAllResolution = Decimal.valueOf(dWrapper.avgAllResolution) / Decimal.valueOf(dWrapper.numAll);
            dWrapper.avgAllResolution = Integer.valueOf(decimalAvgAllResolution.setScale(0, System.RoundingMode.HALF_UP));
        }
        if (dWrapper.numDataIssue > 0) {
            Decimal decimalAvgDataIssueRes = Decimal.valueOf(dWrapper.avgDataIssueResolution) / Decimal.valueOf(dWrapper.numDataIssue);
            dWrapper.avgDataIssueResolution = Integer.valueOf(decimalAvgDataIssueRes.setScale(0, System.RoundingMode.HALF_UP));
        }
        if (dWrapper.numChangeRequest > 0) {
            Decimal decimalAvgChangeRequestResolution = Decimal.valueOf(dWrapper.avgChangeRequestResolution) / Decimal.valueOf(dWrapper.numChangeRequest);
            dWrapper.avgChangeRequestResolution = Integer.valueOf(decimalAvgChangeRequestResolution.setScale(0, System.RoundingMode.HALF_UP));
        }
        
        dWrapper.numOpenTickets_Last_N_Days = siteIssues.size();
        
        return dWrapper;
    }
    
    /**
     *  Description     :  wrapper class for Ticket Data
     *
     *	Revision Logs   :  11/27/2019 - Victor Hanson - Created
    **/
    public class dataWrapper {
        
        @AuraEnabled public Integer numOpenTickets { get; set; }
        @AuraEnabled public Integer numOpenTicketsRT { get; set; }
        @AuraEnabled public Integer numOpenTickets_Last_N_Days { get; set; }
        @AuraEnabled public Integer numHighOrCriticalTickets_Last_N_Days { get; set; }
        
        @AuraEnabled public Integer numDataIssue { get; set; }
        @AuraEnabled public Integer avgDataIssueResolution { get; set; }
        
        @AuraEnabled public Integer numChangeRequest { get; set; }
        @AuraEnabled public Integer avgChangeRequestResolution { get; set; }
        
        @AuraEnabled public Integer numAll { get; set; }
        @AuraEnabled public Integer avgAllResolution { get; set; }
        
        @AuraEnabled public Date createdDate { get; set; }
        @AuraEnabled public Date todaysDate { get; set; }
        
        public dataWrapper() {
            todaysDate = Date.today();
            numOpenTickets = 0;
            numOpenTicketsRT = 0;
            numOpenTickets_Last_N_Days = 0;
            numHighOrCriticalTickets_Last_N_Days = 0;
            
            //Average SLA for data/site issue
            numDataIssue = 0;
            avgDataIssueResolution = 0;
            
            //Average SLA for Change Request
            numChangeRequest = 0;
            avgChangeRequestResolution = 0;
            
            //Average SLA all
            numAll = 0;
            avgAllResolution = 0;
        }
    }

    //get record types
    @AuraEnabled(cacheable=true)
    public static List<String> getRecordTypes(Id recordId) {
        List<String> rts = new List<String>();
        List<AggregateResult> aggs = [SELECT RecordType.Name FROM Site_Issue__c WHERE Project__c = :recordId GROUP BY RecordType.Name ORDER BY RecordType.Name ASC];
        for (AggregateResult ar : aggs) {
            rts.add((String) ar.get('Name'));
        }
        return rts;
    }
}