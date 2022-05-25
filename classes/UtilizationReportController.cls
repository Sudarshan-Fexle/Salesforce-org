/**
     *  Purpose         :   This Controller is used to run all logic on the Utilization Report Creator VF Page
     *
     *  Created By      :   Colin McGloin
     *
     *  Created Date    :   07/06/2018
     *
     *  @Revision Log   :   V1.0 - Created - CR-20180629-12311
     *          	:   V1.1 - Modified By CR-20191018-13437 - Modified by Mahendra Swarankar.
     *                  :   V1.2 - Modified By CR-20190606-13169 - Changes to StudyBuilder
     *			:   V1.3 - Modified By CR-20210521-15174 - Neha Sharma - 06/14/21  
     *
    **/

public with sharing class UtilizationReportController {
    
    //Modified By CR-20190606-13169 - Changes to StudyBuilder
    public Tabvalue outPutMapForDownload {get;set;}
    public String requestUniqueIdTab {get;set;}
    
    //Build our Constructor
    public UtilizationReportController () {
        
        requestRecord = new Utilization_Report__c();
        requestToOutputMap = new Map<String, TabValue>();
        showTable = false;
        requestUniqueIds = new Set<String>();
        showError = false;
        reqInst = new Account();
        reqMem = new Membership__c();
    }
    
    //Create a Wrapper Class for use within the VF Page
    public class TabValue {
        
        public string tabName {get; set;}
        public integer tabNumber {get; set;}
        public Utilization_Report__c originalRequest {get; set;}
        public Utilization_Report__c requestOutput {get; set;}
        public string requestType {get; set;}
        public List<String> output {get; set;}
        public tabularReportResponse fullResponse {get; set;}
        
        public TabValue () {
            
        }    
    }
    
    //String variable to be used for displaying the Error Message Panel on the VF Page
    public static final string ALERT_ERROR = 'error';

    //String variable for Map together our Summary Records
    public static final string MASTER_SUMMARY_VALUE = 'Master Summary Records';
    public static final string OBJECT_TYPE_INST = 'Institution';
    public static final string OBJECT_TYPE_MEM = 'Membership';
    
    //Create public variables
    public Utilization_Report__c requestRecord {get; set;}
    public String access_token {get; set;}
    public boolean showTable {get; set;}
    public boolean showError {get; set;}
    public Set<String> requestUniqueIds {get; set;}
    public Account reqInst {get; set;}
    public Membership__c reqMem {get; set;}
    public String objectType {get; set;}
    
    //Map for associating our Request with the Output
    public Map<String, Tabvalue> requestToOutputMap {get; set;}
    
    //Error Message Variables
    public transient string saveMessage { get; set; }
    public transient string msgSeverity { get; set; }

    //Set a Constant for the Request Record Type
    public final static String STUDYBUILDER_REQUEST_RT_NAME = 'Utilization_Report_Request';
    
    //Set our Map
    public Map<String, TabValue> getRequestToOutputMap {
        
        get{
            return this.requestToOutputMap;
        }
        set;
    }

    //Get the Record Type ID for the Output Record Type so we can set that correctly when creating our Output records
    public Id outputRTId {
        get {
            if (outputRTId == null) outputRTId = Schema.SObjectType.Utilization_Report__c.getRecordTypeInfosByName().get('Utilization Report Output').getRecordTypeId();
            return outputRTId;
        }
        set;
    }

     /**
     *  @description    :   This method is used to return all Active Utilization Report Request Scenarios
     *
     *  @Revision Log   :   V1.0 - Created - CR-20180629-12311
     *
    **/

    public List<Utilization_Report__c> getActiveStudyBuilderScenarios {
        
        get{
            
            //Set out List of Utilization Report Request Scenarios
            List<Utilization_Report__c> reportRequests = [SELECT Id, Name, Active__c, Report_Institution__c, Report_End_Date__c, Report_ID__c, Report_Membership__c,
                                                    Report_Output__c, Report_Start_Date__c, Scenario_Type__c, Report_Output_Tag_Line__c, Report_Object__c
                                                    FROM Utilization_Report__c
                                                    WHERE RecordType.DeveloperName = :STUDYBUILDER_REQUEST_RT_NAME AND Active__c = TRUE AND Report_Object__c = :objectType
                                                    AND Report_ID__c != null ORDER BY Name ASC];
            
            //Add our Unique Id for Master Summary Records first
            String masterUnique = 'Master Summary Records';
            requestUniqueIds.add(masterUnique);
            
            //If we have active records then run through them
            if(reportRequests.size() > 0){
                
                //Add our Request Ids to a List for later use
                for (Utilization_Report__c requestId : reportRequests){
                    
                    //Add our non-Summary Count records to the List for looping through in the tab section
                    if (requestId.Scenario_Type__c != Label.Studybuilder_Summary_Count_Scenario_Type){
                        //Create a unique ID for later use and add to our List
                        String uniqueId = requestId.Id + '-' + requestId.Name;
                        requestUniqueIds.add(uniqueId);
                    }
                }
            }
            
            //If we have records then return our List                                       
            if (reportRequests.size() > 0){
                return reportRequests;
            } else {
                return null;
            }
            
        } set;
        
    }
    
    /**
     *  @description    :   This method is used to query for and return our Requested Object records and other fields
     *
     *  @Revision Log   :   V1.0 - Created - CR-20180629-12311
     *
    **/
    
    public void getRequestRecord (Utilization_Report__c theRecord) {
        
        //Run through our Institution Scenario first
        if (theRecord.Report_Institution__c != null){
            //Query for our Institution Name so we can populate the filter correctly
            reqInst = [SELECT Id, Name FROM Account WHERE Id = :theRecord.Report_Institution__c];
            objectType = OBJECT_TYPE_INST;
        } else if (theRecord.Report_Membership__c != null){
            //Query for our Membership Name so we can populate the filter correctly
            reqMem = [SELECT Id, Name FROM Membership__c WHERE Id = :theRecord.Report_Membership__c];
            objectType = OBJECT_TYPE_MEM;
        }     
    }

    /**
     *  @description    :   This method is used to run our reports and return the correct data for each Active Scenario
     *
     *  @Revision Log   :   V1.0 - Created - CR-20180629-12311
     *
    **/
    
    public void filterReportsDynamicallyApex (List<Utilization_Report__c> requests) {
        
        //Report IDs
        Set<Id> reportIds = new Set<ID>();
        List<Report> scenarioReports = new List<Report>();
        String mapUnique = '';
        
        //List of Utilization Report Output records
        List<Utilization_Report__c> outputRecords = new List<Utilization_Report__c>();
        
        //Variables for Report Output
        Integer sumCount;
        
        //Set our initial Tab Counter to 0
        integer counter = 1;
        
        //Create our Master Summary Record
        TabValue masterRequestTab = new TabValue();
        masterRequestTab.tabName = 'All Summary Values';
        masterRequestTab.tabNumber = counter;
        masterRequestTab.requestType = Label.Studybuilder_Summary_Count_Scenario_Type;
        masterRequestTab.output = new List<String>();
        
        //Put Master in the Map
        requestToOutputMap.put(MASTER_SUMMARY_VALUE, masterRequestTab);
        
        //Cycle through our Request records
        for (Utilization_Report__c sRequest : requests){
            
            //Added if condition to not process utilization records where report Id is blank or is not a valid id -10/18/2019 - CR-20191018-13437 
            if( String.IsNotBlank(sRequest .Report_ID__c) && ((sRequest .Report_ID__c).trim().trim().length() == 15 || (sRequest .Report_ID__c).trim().trim().length() == 18)){
                //String.IsNotBlank(sRequest .Report_ID__c) && ((sRequest .Report_ID__c).trim().trim().length() == 15 || (sRequest .Report_ID__c).trim().trim().length() == 18)) {
                
                
                //Create our unique Id for Map purposes
                mapUnique = sRequest.Id + '-' + sRequest.Name;
                
                //Get our Report Metadata
                Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(sRequest.Report_ID__c);
                Reports.ReportMetadata reportMd = describe.getReportMetadata(); 
                
                //Get our Institution Filter
                Reports.ReportFilter reportFilter = reportMd.getReportFilters()[0];
                
                //Set our Filter Strings
                String inst = String.valueOf(reqInst.Name);
                String membership = String.valueOf(reqMem.Name);
                String startDate = String.valueOf(requestRecord.Report_Start_Date__c);
                String endDate = String.valueOf(requestRecord.Report_End_Date__c);
                
                //Modified By - Neha Sharma - CR-20210521-15174- 06/14/21 - start here 
                //Set our Report Filter
                if (String.isNotEmpty(inst)){
                    if(inst.contains(','))
                    {
                        reportFilter.setValue('"'+inst+'"');
                    }
                    else
                    {
                        reportFilter.setValue(inst);
                    }
                } else {
                    reportFilter.setValue(membership);
                }
                //Modified By - Neha Sharma - CR-20210521-15174 - 06/14/21 - End here 
                
                //Set our Start and End Date
                Reports.StandardDateFilter standardFilter = reportMd.getStandardDateFilter();
                standardFilter.setStartDate(startDate);
                standardFilter.setEndDate(endDate);
                
                //Run our Report and get our Results
                Reports.ReportResults results = Reports.ReportManager.runReport(sRequest.Report_ID__c, reportMd, true);
                
                //Add to our Counter which is used for the Tab Numbers
                counter++;
                
                //Create our initial Tab Wrapper record in the Map
                TabValue requestTab = new TabValue();
                
                //If our Scenario is not a Summary Count, then add to the Map
                if (sRequest.Scenario_Type__c != Label.Studybuilder_Summary_Count_Scenario_Type){
                    
                    //Populate our Tab Values
                    requestTab.tabName = sRequest.Name;
                    requestTab.tabNumber = counter;
                    requestTab.originalRequest = sRequest;
                    requestTab.requestType = sRequest.Scenario_Type__c;
                    requestTab.output = new List<String>();
                    requestTab.fullResponse = new tabularReportResponse();
                    
                    //Populate our Map
                    requestToOutputMap.put(mapUnique, requestTab);
                }
                
                //Create our shell Output Studybuilder Record
                Utilization_Report__c outputRecord = new Utilization_Report__c();
                outputRecord.Name = 'Placeholder Name';
                outputRecord.Original_Request__c = sRequest.Id;
                outputRecord.Report_Start_Date__c = requestRecord.Report_Start_Date__c;
                outputRecord.Report_End_Date__c = requestRecord.Report_End_Date__c;
                outputRecord.Report_Institution__c = requestRecord.Report_Institution__c;
                outputRecord.Report_Membership__c = requestRecord.Report_Membership__c;
                outputRecord.RecordTypeId = outputRTId;       
                
                //Scenario 1
                if (sRequest.Scenario_Type__c == Label.Studybuilder_Summary_Count_Scenario_Type){
                    
                    //String for Report Output
                    String outputString = '';
                    
                    //Get our Aggregate Data
                    Reports.ReportFactWithDetails factSum = (Reports.ReportFactWithDetails)results.getFactMap().get('T!T');
                    LIST<Reports.SummaryValue> summary = factSum.getAggregates();
                    Object summaryValue = summary.get(0).getValue();
                    sumCount = Integer.valueOf(summaryValue);
                    
                    //Populate our Report Output into the Output Record
                    if (sRequest.Report_Output_Tag_Line__c != null){
                        outputString = sRequest.Report_Output_Tag_Line__c + ' ' + String.valueOf(sumCount);
                    } else {
                        outputString = String.valueOf(sumCount);
                    }
                    
                    //Populate our Report Output field with the Report Output String
                    outputRecord.Report_Output__c = outputString;
                    
                    //Grab our Master Summary Count record
                    TabValue tab = requestToOutputMap.get(MASTER_SUMMARY_VALUE);
                    
                    //Add any existing values to our List before adding our new one
                    List<String> tableData = tab.output;
                    tableData.add(outputString);
                    tab.output = tableData;
                    
                    // Add our List back to the 
                    tab.requestOutput = outputRecord;
                    
                    //Put our Master Summary tab back in the Map
                    requestToOutputMap.put(MASTER_SUMMARY_VALUE, tab);
                    
                }
                //Scenario 2
                if (sRequest.Scenario_Type__c == Label.Studybuilder_Record_Names_Scenario_Type){
                    
                    // TABULAR TESTING
                    tabularReportResponse trr = new tabularReportResponse();
                    List<fieldDef> reportFields = new List<fieldDef>(); 
                    List<List<fieldData>> fieldDataList = new List<List<fieldData>>();
                    
                    // It retrieves the metadata info
                    Reports.ReportMetadata reportMetadata = results.getReportMetadata();
                    
                    // It retrieves a String list with API Names for Fields
                    List<String> fieldNames = reportMetadata.getDetailColumns();        
                    
                    // It retrieves extended metadata info
                    Reports.ReportExtendedMetadata reportExtendedMetadata = results.getReportExtendedMetadata();
                    
                    // It matches column names with labels
                    Map<String, Reports.DetailColumn> detailColumnMap = reportExtendedMetadata.getDetailColumnInfo();
                    
                    // It loops over detailColumnMap and populates reportFields with field names,
                    // labels and field types
                    for (String fieldName: fieldNames) {
                        Reports.DetailColumn detailColumn = detailColumnMap.get(fieldName);
                        fieldDef fd = new fieldDef();
                        fd.fieldName = detailColumn.getName(); 
                        fd.fieldLabel = detailColumn.getLabel();
                        fd.dataType = detailColumn.getDataType().name();
                        reportFields.add(fd);
                    }
                    
                    // It retrieves the fact map results    
                    Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get('T!T');     
                    
                    List<Reports.ReportDetailRow> reportDetailRowList = factDetails.getRows();
                    
                    // It loops over reportDetailRowList filling fieldDataList with row data
                    for (Reports.ReportDetailRow reportDetailRow: reportDetailRowList) {
                        Integer cellCounter = 0;
                        String miLabel = '';
                        String miValue = '';
                        List<fieldData> fieldDataRow = new List<fieldData>();
                        //loop over the cells in the row
                        for (Reports.ReportDataCell reportDataCell: reportDetailRow.getDataCells()) {
                            fieldData fd = new fieldData();
                            fd.dataType = reportFields[cellCounter].dataType;
                            if (fd.dataType != 'STRING_DATA') {
                                miLabel = String.valueOf(reportDataCell.getLabel());
                                miValue = String.valueOf(reportDataCell.getValue());
                            } else {
                                miLabel = reportDataCell.getLabel();
                                miValue = String.valueOf(reportDataCell.getValue());
                            }
                            fd.fieldLabel = miLabel;
                            fd.fieldValue = (String)miValue;
                            
                            cellCounter++;
                            
                            fieldDataRow.add(fd);
                        }
                        
                        //add the row to the list
                        fieldDataList.add(fieldDataRow);
                    }
                    
                    //Populate our Wrapper with the headers and field values
                    trr.reportFields = reportFields;
                    trr.fieldDataList = fieldDataList;
                    
                    //Add to the Map
                    if (requestToOutputMap.get(mapUnique) != null){
                        
                        //Get our Tabvalue record from the Map
                        TabValue tab = requestToOutputMap.get(mapUnique);
                        
                        //Pass our Report Wrapper Information Through to our Tab
                        tab.fullResponse = trr;
                    }   
                }
                
                //Add our records to the List for Insertion
                outputRecords.add(outputRecord);
            }
        }
        
        //Insert our Output Records if we have any
        if (outputRecords.size() > 0){
            insert outputRecords;
        }
    }
    
     /**
     * 
     * @description: Run Scenarios Record Method
     * 
     **/
    
    public pageReference runScenarios() {
        
        //Create our List variable for Active Scenarios
        List<Utilization_Report__c> activeScenarios = new List<Utilization_Report__c>();
        
        try {
            
            //Clear our Error Message if needed
            if (showError == true){
                showError = false;
            }
            
            //Check we have values in Required Fields
            validateRecord(requestRecord);
            
            //Query for other fields to be used later
            getRequestRecord(requestRecord);
            
            //Get our Active Scenarios
            if(getActiveStudyBuilderScenarios != null){
                activeScenarios = getActiveStudyBuilderScenarios;
            } else {
                //If there are no Active Scenarios then throw Exception and present error
                throw new CustomException (Label.Studybuilder_No_Active_Scenarios);
            }
            
            //Pass our Active Scenarios through to Filter and Retrieve Method
            filterReportsDynamicallyApex(activeScenarios);
            
            //Display our Table
            showTable();
            
        }
        
        catch (Exception ex) {
            
            //Display our Error
            showError = true;
            
            
            //Return any errors to the VF Page
            saveMessage = ex.getMessage();
            msgSeverity = 'error';
            
       }
        
        return null;
        
    }
    
     /**
     * 
     * @description: verify the required fields were populated.
     * 
     **/
    
    public void validateRecord(Utilization_Report__c theRecord) {
        
        if (theRecord.Report_Start_Date__c == null) throw new customException('Report Start Date is required.');
        if (theRecord.Report_End_Date__c == null) throw new customException('Report End Date is required.');
        if (theRecord.Report_Institution__c == null && theRecord.Report_Membership__c == null) throw new customException('Institution or Membership is required.');
        if (theRecord.Report_Institution__c != null && theRecord.Report_Membership__c != null) throw new customException('Please populate either Institution or Membership.');
    }

    /**
     * 
     * @description: Tell the VF Page to display our Table of Data
     **/
    
    public void showTable() {
        
        if (showTable != true){
            //Set the Table property to display 
            showTable = true;
        }     
    }

    //-- INNER REPORTING CLASSES
    // reportResponse wrapper
    public class reportResponse {
        public String reportType {get; set;}
        public tabularReportResponse tabResp {get; set;}        
        public reportResponse(){}
    }           

    // tabularReportResponse wrapper
    public class tabularReportResponse {
        public List<fieldDef> reportFields {get; set;}
        public List<List<fieldData>> fieldDataList {get; set;}
        public tabularReportResponse(){}
    }
    
    // fieldDef  wrapper
    public class fieldDef {
        public String fieldName {get; set;}
        public String fieldLabel {get; set;}
        public String dataType {get; set;}
        public fieldDef(){}
    }

    // fieldData wrapper
    public class fieldData {
        public String fieldValue {get; set;}
        public String fieldLabel {get; set;}
        public String dataType  {get; set;}
        public Boolean isHyperLink {get; set;}          
        public fieldData(){isHyperLink=false;}
    }
    
    //Modified By CR-20190606-13169 - Changes to StudyBuilder
    Public PageReference exportToExcel()
    { 
        outPutMapForDownload = new Tabvalue();
        if(String.isNotBlank(requestUniqueIdTab) && requestToOutputMap !=null && requestToOutputMap.size() > 0 
           && requestToOutputMap.containsKey(requestUniqueIdTab) ) {
               
            outPutMapForDownload = requestToOutputMap.get(requestUniqueIdTab);    
        }
        
        PageReference pgRef = New Pagereference('/apex/UtilizationReportDownloader');
        pgRef.setRedirect(false); 
        return pgRef;
    }
}