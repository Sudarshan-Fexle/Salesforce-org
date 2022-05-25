/*
Purpose         :   This controller is used to create Rule & Event Rule Object's records from Advisory Event Object (Add Program Rules) Quick Action.
Created By      :   Saurabh Kumar
Created Date    :   03/18/2021
Current Version :   V_1.0
Revision Log    :   V_1.0 Created - Saurabh Kumar - 03/18/2021 - CR-20201222-14763
*/
public without sharing class AddProgramRulesController 
{   
    
    /* 
    *   Description     :   This method is used to fetch all or filter based records.
    *
    *   @argument       :   String, String
    *   
    *   return type     :   LightningResponseEntity
    * 
    *   Revision Logs   :   V_1.0 - Created
    */
    @AuraEnabled(cacheable=true)
    public static LightningResponseEntity fetchAllProgramRecords(String eabEventId, String searchText)
    {
        //To hold data and message to display on screen
        LightningResponseEntity res = new LightningResponseEntity();
        try
        {
            //Check for EAB Event Id
            if(String.isNotBlank(eabEventId))
            {
                //To hold all or filter based Program records
                List<Program__c> allPrograms = new List<Program__c>();
                
                //Check for Search Text
                if(String.isNotBlank(searchText))
                {
                    //To hold Program records with searching based on Keyword
                    allPrograms = AddProgramRulesManagerQueryBuilder.getAllProgramRecords(searchText);
                }
                else
                {   
                    //To hold Program records (Without Searching)
                    allPrograms = AddProgramRulesManagerQueryBuilder.getAllProgramRecords();
                }
                //Check for no of Program records
                if(allPrograms.size() > 0)
                {
                    //To hold all attributes related to Add Program Rules Quick Action Implementations
                    List<AddProgramRulesWrapper> addProgramRulesWrappers = new List<AddProgramRulesWrapper>();
                    
                    for(Program__c program : allPrograms)
                    {
                        //Set attributes in Wrapper
                        AddProgramRulesWrapper addProgRulesWrapper = new  AddProgramRulesWrapper(
                            program.Id, program.Name, program.Sector__c,
                            program.Applicable_Segments__c, program.Business_Line__c,false);
                        
                        addProgramRulesWrappers.add(addProgRulesWrapper);
                    }
                    //Check for Wrapper Size
                    if(addProgramRulesWrappers.size() > 0){
                        //Set Lightning Response Body with Our Wrapper to show on screen
                        res.setBody(addProgramRulesWrappers);
                        res.setSuccess(true);
                    }  
                }
                else
                {
                    //Throw error in case of no Program records
                    res.setMessage(System.Label.No_Program_To_Display);
                    res.setSuccess(true);
                }
            }
            else
            {
                //Throw error in case of Insufficient Access To RecordId
                res.setError(Label.Insufficient_Access_To_RecordId); 
            }
            return res;
        }
        catch (Exception ex) 
        {
            //Throw error 
            res.setError(ex.getMessage());
            return res;
        }
    }
    
    /* 
    *   Description     :   This method is used to create Rule & Event Rule Object's records.
    *
    *   @argument       :   String, String
    *   
    *   return type     :   LightningResponseEntity
    * 
    *   Revision Logs   :   V_1.0 - Created
    */
    @AuraEnabled
    public static LightningResponseEntity createProgramRuleRecords(String eabEventId, String addProgramRulesWrapperJson)
    {
        //To hold data and message to display on screen
        LightningResponseEntity res = new LightningResponseEntity();
         
        //Enabled Savepoint
        Savepoint sp = Database.setSavepoint();
        try
        {
            //Check for EAB Event Id
            if(String.isNotBlank(eabEventId)){
                
                //To hold all attributes related to Add Program Rules Quick Action Implementations
                List<AddProgramRulesWrapper> addProgramRulesWrappers = new List<AddProgramRulesWrapper>();
                
                //Check for JSON
                if(String.isNotBlank(addProgramRulesWrapperJson)){
                    
                    //To convert JSON to Wrapper
                    addProgramRulesWrappers = (List<AddProgramRulesWrapper>)JSON.deserializeStrict(addProgramRulesWrapperJson, List<AddProgramRulesWrapper>.class);
                    
                    //Check for Wrapper Size
                    if(addProgramRulesWrappers.size() > 0)
                    {
                        //To hold Rule and Event Rule records going to create
                        List<Rule__c> rulesToBeCreated = new List<Rule__c>();
                        List<Event_Rule__c> eventRulesToBeCreated = new List<Event_Rule__c>();
                        
                        for(AddProgramRulesWrapper addProgRuleWrap: addProgramRulesWrappers){
                            //To set attributes for Rule Object's new Instance  
                            Rule__c rule = new Rule__c();
                            rule.Advisory_Event__c = eabEventId;
                            //Check for Program Id
                            if(String.isNotBlank(addProgRuleWrap.programId)){
                                rule.Program__c = addProgRuleWrap.programId;
                            }
                            rule.Primary__c = addProgRuleWrap.isPrimary;
                            //Add in list to create Rule Object records
                            rulesToBeCreated.add(rule);
                        }
                        //Check for Rule Object's records Size
                        if(rulesToBeCreated.size() > 0){
                            
                            RuleTriggerHelper.EXECUTE_RULE_TRIGGER_METHOD = false;
                            insert rulesToBeCreated;
                            RuleTriggerHelper.EXECUTE_RULE_TRIGGER_METHOD = true;
                            
                            for(Rule__c rule : rulesToBeCreated){
                                //To set attributes for Event Rule Object's new Instance  
                                Event_Rule__c eventRule = new Event_Rule__c();
                                eventRule.Rule__c = rule.Id;
                                eventRule.Advisory_Event__c = rule.Advisory_Event__c;
                                //Add in list to create Event Rule Object records
                                eventRulesToBeCreated.add(eventRule);
                            }
                            
                            //Check for Event Rule Object's records Size
                            if(eventRulesToBeCreated.size() > 0){
                                
                                insert eventRulesToBeCreated;
                                
                                //Set Lightning Response Body with Our Wrapper to show on screen
                                //Success Message in case of records are created successfully.
                                res.setBody(rulesToBeCreated);
                                res.setMessage(System.Label.RULES_CREATED_SUCCESSFULLY);
                                res.setSuccess(true);
                            }
                        }
                    }
                }
                else{
                    Database.RollBack(sp);
                    //Throw error in case of Json not proper or empty
                    res.setMessage(System.Label.JSON_NOT_PROPER);
                    res.setSuccess(true);
                }
            }
            else
            {
                Database.RollBack(sp);
                //Throw error in case of Insufficient Access To RecordId
                res.setError(Label.Insufficient_Access_To_RecordId); 
            }
            return res;
        }
        catch (Exception ex) 
        {
            Database.RollBack(sp);
            //Throw error 
            res.setError(ex.getMessage());
            return res;
        }
    }
    
    //Wrapper to hold all attributes related to Add Program Rules Quick Action Implementations
    public class AddProgramRulesWrapper
    {
        @auraEnabled public String programId;
        @auraEnabled public String programName;
        @auraEnabled public String sector;
        @auraEnabled public String applicableSegments;
        @auraEnabled public String businessLine;
        @auraEnabled public Boolean isPrimary;     
        public AddProgramRulesWrapper(String programId,String programName, String sector, 
                                      String applicableSegments, String businessLine, Boolean isPrimary)
        {
            this.programId = programId;
            this.programName = programName;
            this.sector = sector;
            this.applicableSegments = applicableSegments;
            this.businessLine = businessLine;
            this.isPrimary = isPrimary;
        }
    }
}