/**
 *  Purpose            :    Wrapper class for Revenue management. This class will use to hold all the properties    
 *
 *  Created By         :    Subhash Garhwal
 *
 *  Created Date       :    02/07/2017
 *
 *  Revision Log       :    V_1.0 - Created - CR-20161102-10316 - Revenue Management
 *                          V1.1 - Modified - CR-20170302-10729 - Made changes according to Solution design 1.4
 *                          V1.2 - Modified By - Abhinav Sharma - 05/18/2017 - CR-20170508-10905
 *                          V1.2 - Modified By - Subhash Garhwal - 10/03/2017 - CR-20170907-11185
 *                          V1.3 - Modified By - Colin McGloin - 12/14/2018 - CR-20181212-12784
 *              
 **/
public with sharing class RevenueManagementWrapper {
    
    //Properties
    public ABC_Revenue__c aBCRevenue {get;set;}
    public Boolean selected {get;set;}
    public String selectedTemplate {get;set;}
    public List<String> templates {get;set;}
    public Boolean isTemplateEditable {get;set;}
    public string errorMessage {get; set;}
    public integer currentRowNo {get; set;}
    public List<ABCRevenueLineWrapper> abcRevenueLineWrapper {get;set;}
    
    //Subhash Garhwal - 10/03/2017 - CR-20170907-11185
    public Date clarizenFirstGoLiveComplete {get;set;}
    public Boolean isSiteLiveDateChangedFromDeployment {get;set;}
    
    //List to hold the vales for Templates
    public List<SelectOption> primaryTemplates {get;set;}
    
    //Values for Line Status
    public List<SelectOption> lineStatusValues {get;set;}
    public String selectedLineStatus {get;set;}
    public Boolean isLineStatusNotMatches {get; set;}
    public String lineStatusOldValue {get; set;}
    
    //Is Line Copied, Property is to reflect/ or lets us know if Instance is Copied as a Line
    public Boolean isCopied{get;set;}
    
    //Constructor
    public RevenueManagementWrapper(){
    }
    
    //Added By - Abhinav Sharma - 05/18/2017 - CR-20170508-10905
    //Start from here
    //Constructor
    public RevenueManagementWrapper(ABC_Revenue__c aBCRevenue, List<SelectOption> primaryTemplates, String selectedTemplate, Boolean selected, Boolean isTemplateEditable, List<SelectOption> lineStatusValues){
        
        //Set values
        this.aBCRevenue = aBCRevenue;
        this.selected = selected;
        this.primaryTemplates = primaryTemplates;
        this.selectedTemplate = selectedTemplate;
        templates = new List<String>();
        this.isTemplateEditable = isTemplateEditable;
        this.abcRevenueLineWrapper = new List<ABCRevenueLineWrapper>();
        this.lineStatusValues = lineStatusValues;
        this.isCopied = false;
        
        //Subhash Garhwal - 10/03/2017 - CR-20170907-11185
        //Remove the reference of "Clarizen_First_Go_Live_Complete__c" - By abhinav Sharma - 7/6/2020 - CR-20200204-13690
        //this.clarizenFirstGoLiveComplete = aBCRevenue.Clarizen_First_Go_Live_Complete__c;
        this.isSiteLiveDateChangedFromDeployment = false;
        
        //Set Template names
        if(String.isNotBlank(aBCRevenue.Rev_Rec_Templates__c)) {
            
            //Split values
            List<String> tempTemplates = aBCRevenue.Rev_Rec_Templates__c.split(';');
            
            //Loop over the templates
            for(String template : tempTemplates)
                templates.add(template); 
        }
        
        //Logic to bypass the none "line status" value for the permission set user
        isLineStatusNotMatches = RevenueManagementWrapper.checkLineStatusForMatching(aBCRevenue, lineStatusValues);
        lineStatusOldValue = aBCRevenue.Line_Status__c;
        
    }
    //upto here
    
    //Constructor
    public RevenueManagementWrapper(ABC_Revenue__c aBCRevenue, List<SelectOption> primaryTemplates, String selectedTemplate, Boolean selected, Boolean isTemplateEditable, List<SelectOption> lineStatusValues, ID programID, String programName){
        
        //Set values
        this.aBCRevenue = aBCRevenue;
        this.selected = selected;
        this.primaryTemplates = primaryTemplates;
        this.selectedTemplate = selectedTemplate;
        templates = new List<String>();
        this.isTemplateEditable = isTemplateEditable;
        this.abcRevenueLineWrapper = new List<ABCRevenueLineWrapper>();
        this.lineStatusValues = lineStatusValues;
        this.isCopied = false;
        
        if(this.aBCRevenue != null)
            this.aBCRevenue.Program__c = programID;
        
        if(this.aBCRevenue != null && this.aBCRevenue.Program__c != null)
            this.aBCRevenue.Program__r.Name = programName;
        
        //Set Template names
        if(String.isNotBlank(aBCRevenue.Rev_Rec_Templates__c)) {
            
            //Split values
            List<String> tempTemplates = aBCRevenue.Rev_Rec_Templates__c.split(';');
            
            //Loop over the templates
            for(String template : tempTemplates)
                templates.add(template); 
        }
        
        //Logic to bypass the none "line status" value for the permission set user
        isLineStatusNotMatches = RevenueManagementWrapper.checkLineStatusForMatching(aBCRevenue, lineStatusValues);
        lineStatusOldValue = aBCRevenue.Line_Status__c;
    }
    
    //Wrapper class to hold the ABC Revenue Line Details
    //03/09/2017 - Subhash Garhwal - Added - CR-20170302-10729
    public class ABCRevenueLineWrapper {
        
        //Properties
        public ABC_Revenue_Line__c abcRevenueLine {get;set;}
        
        //Constructor
        public ABCRevenueLineWrapper(ABC_Revenue_Line__c abcRevenueLine) {
            
            //Set values
            this.abcRevenueLine = abcRevenueLine;
        }
    }
    
    //method to check line status value matching
    public static Boolean checkLineStatusForMatching(ABC_Revenue__c aBCRevenue, List<SelectOption> lineStatusValues) {
        
        //Checking line status for its value
        if(String.isNotBlank(aBCRevenue.Line_Status__c) && lineStatusValues != null && lineStatusValues.size() > 0) {
            
            //Set to hold the line status options
            Set<String> setOfLineStatuses = new Set<String>();
            
            //Loop through list values and populating set with it
            for(SelectOption st : lineStatusValues)
                setOfLineStatuses.add(st.getValue());
            
            //Checking whether set contains the line status selected value
            if(setOfLineStatuses.contains(aBCRevenue.Line_Status__c))
                return false;
            else
                return true;    
        }
        
        //Return "false" as default value
        return false;
    }
}