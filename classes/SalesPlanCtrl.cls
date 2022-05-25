/**
 *  Purpose         :	Controller Class for Sales Plan component 
 * 
 *  Create By       :   
 * 
 *  Created Date    :   
 * 
 *  Revision Log    :   V1.0 - Created  
 * 						V1.1 - Modified By - Mahendra Swarnkar - 02/04/2020 - CR-20200128-13664 - Added "without sharing" access modifier
 *                      V1.2 Modified By -Abhinav Sharma - 6/5/2020 -  CR-20200524-14104 - Access modifier based changes here for the @auraenabled properties
 **/
public without sharing class SalesPlanCtrl {
    
    @AuraEnabled
    public static SalesPlanWrapper initializeData(String oppId){
        
        System.debug('VCG Debug  Currrent OP Id ' + oppId);
        
        
        List<Opportunity> oppLst = getOpportunityRecord(oppId);
        List<SelectOption> mstages = getOpportunityStages();
        
        String oppRecordTypeName = SP_RecordTypeManager.getNameById(oppLst[0].RecordTypeId, 'Opportunity');
        
        List<SelectOptionWithDescription> mstageswithDescription = getOpportunityStageswithDescription(oppRecordTypeName);
        
       // Boolean allProductsExempt = checkExemptProducts(oppLst[0].SP_Products__c);
        Map<String,SP_OpportunityActionManager> managermap = getManagerData(oppLst[0], oppRecordTypeName);
        List<User> ownerInfo = getOwnerInfo(oppLst[0]);
        User userDetails = getUserInfo();
        Boolean isMgr = getIsMgr(oppLst[0], userDetails, ownerInfo);
        String nextStepSig = Date.today().month() + '/' + Date.today().day() + '/' + Date.today().year() + ' ' + UserInfo.getFirstName().substring(0,1) + UserInfo.getLastName().substring(0,1) + ': ';
        SalesPlanWrapper spWrapper = new SalesPlanWrapper();
        spWrapper.opp = oppLst[0];
        spWrapper.currentStage = oppLst[0].StageName;
        spWrapper.mstages = mstages;
        spWrapper.mstageswithdescription = mstageswithDescription;
        spWrapper.managermap = managermap;
        spWrapper.isMgr = isMgr;
        spWrapper.nextStepSig = nextStepSig;
        spWrapper.userInfo = userDetails;
        spWrapper.mgrId = ownerInfo[0].ManagerId;
        return spWrapper;
    }   
    
    
    public static User getUserInfo(){
        return [SELECT Id, Email, Name, Manager.Email, Manager.Name FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];        
    }    
    
    public static List<User> getOwnerInfo(Opportunity opp){
        return [SELECT Id, ManagerId FROM User WHERE Id =: opp.OwnerId];
    }
    
    public static Boolean getIsMgr(Opportunity opp, User usrInfo, List<User> ownerInfo){
        Boolean isMgr = false;
        Id mgrId; 
        for (User owner : ownerInfo) {
            mgrId = owner.ManagerId;
            if (usrInfo.Id == owner.ManagerId) {
                isMgr = true;
            }
        }
        return isMgr;
    }
    @AuraEnabled
    public static Map<String,SP_OpportunityActionManager> getManagerData(Opportunity opp, String oppRecordTypeName){
        Map<String,SP_OpportunityActionManager> managermap = new Map<String,SP_OpportunityActionManager>();
        Map<String,list<Stage_Objective__c>> so = queryStageObjectives(opp, oppRecordTypeName);
        System.debug('so '+so);
        Map<String,list<Task>> oa = queryOppActions(opp);
        System.debug('oa '+oa);
        Map<Id,Objective_Action__c> objActions = queryObjectiveActions(opp);
        System.debug('objActions '+objActions.size());
        Set<String> stagesSet = new Set<String>();
        stagesSet.addAll(so.keySet());
        stagesSet.addAll(oa.keySet());
        for(String stage : stagesSet){ 
            managermap.put(stage,new SP_OpportunityActionManager(so.get(stage),oa.get(stage),objActions,opp.Id));
        }
        System.debug('managermap '+managermap);
        return managermap;
    }
    
    public static Map<Id,Objective_Action__c> queryObjectiveActions(Opportunity opp){
        return new Map<Id,Objective_Action__c>([SELECT Id, name, Stage_Objective__c, Action_Type__c, Order__c, Stage_Name__c,
                                                   Opportunity_Type__c, Opportunity_Order_Type__c, Opportunity_Order_SubType__c
                                                   FROM Objective_Action__c]);
    }
    
    public static map<String,list<Stage_Objective__c>> queryStageObjectives(Opportunity opp, String oppRecordTypeName){
        map<String,list<Stage_Objective__c>> result = new map<String,list<Stage_Objective__c>>();
        set<Id> oaIds = SP_sCollection.IdSet([select ObjectiveActionID__c from Task where WhatId = :opp.Id],Task.ObjectiveActionId__c);
        list<Stage_Objective__c> so;
        String stage; 
        System.debug('VCG Debug Record Type' + oppRecordTypeName);
        System.debug('VCG Debug Type' + opp.Type);
        System.debug('VCG Debug Order Type' + opp.Order_Type__c);
        
        for(Stage_Objective__c obj : [SELECT Id, name, Advancement_Criteria__c, Opportunity_Stage__r.name, Order__c, Description__c,
                                         Field_Set__c, (SELECT Id, name, Description__c, Order__c, Action_Type__c, Stage_Objective__r.Opportunity_Stage__r.name, Stage_Objective__c, Stage_Name__c, Opportunity_Type__c, Opportunity_Order_Type__c, Opportunity_Order_SubType__c
                                                           FROM Objective_Action__r
                                                           WHERE Opportunity_Record_Type__c INCLUDES(:oppRecordTypeName) 
                                                           AND Opportunity_Type__c INCLUDES (:opp.Type) 
                                                           AND Opportunity_Order_Type__c INCLUDES (:opp.Order_Type__c)
                                                           //   AND Opportunity_Order_SubType__c INCLUDES (:opp.Order_Sub_Type__c)                                    
                                                           ORDER BY Order__c)
                                         FROM Stage_Objective__c
                                         WHERE Opportunity_Record_Type__c INCLUDES(:oppRecordTypeName)
                                         AND Opportunity_Type__c INCLUDES (:opp.Type)
                                         AND Opportunity_Order_Type__c INCLUDES (:opp.Order_Type__c)
                                         //  AND Opportunity_Order_SubType__c INCLUDES (:opp.Order_Sub_Type__c) 
                                         order by Order__c]){
                                             stage = opp.StageName;
                                             
                                             
                                             so = result.containsKey(stage) ? result.get(stage) : new list<Stage_Objective__c>();
                                             so.add(obj);
                                             result.put(stage,so);
                                         }
        return result;
    }
    
    public static Map<String, List<Task>> queryOppActions(Opportunity opp){
        Map<String, List<Task>> result = new Map<String, List<Task>>();
        List<Task> actions;
        String stage;
        for(Task act : [SELECT Id, Subject, ActivityDate, IsClosed, ObjectiveActionID__c,
                        Key_Action__c, StageObjectiveID__c, Description, Related_Stage__c,
                        WhatId, Status, Coaching_Status__c, Coached_By__c, Date_of_Coaching__c, Event_Type__c 
                        FROM Task
                        WHERE whatId = :opp.Id
                        AND StageObjectiveID__c != null
                        AND ObjectiveActionID__c != null]){
                            stage = act.Related_Stage__c;
                            actions = result.containsKey(opp.StageName) ? result.get(opp.StageName) : new list<Task>();
                            actions.add(act);
                            //result.put(stage,actions);
                            result.put(opp.StageName,actions);
                        }
        return result;
    }
    
    public static List<Opportunity> getOpportunityRecord(String oppId){
        return [SELECT Id, Name,StageName, RecordTypeId, OwnerId, Type, Order_Type__c, Order_Sub_Type__c
                FROM Opportunity
                WHERE Id =:oppId];
    }
    
    public static Opportunity getOpportunityRecordById(String oppId){
        return [SELECT Id, StageName, RecordTypeId, OwnerId, Type, Order_Type__c, Order_Sub_Type__c
                FROM Opportunity
                WHERE Id =:oppId];
    }
    
    public static List<SelectOption> getOpportunityStages(){
        Map<String,String> stageMap = new Map<String,String>();
        List<SelectOption> mstages = new List<SelectOption>();
        for(Schema.PicklistEntry ple:Opportunity.sObjectType.getDescribe().fields.getMap().get('StageName').getDescribe().getPicklistValues()){
            stageMap.put(ple.getValue(),ple.getLabel());
            
        }
        for(Opportunity_Stage__c stage:[SELECT Id, Name
                                           FROM Opportunity_Stage__c
                                           WHERE Id IN (SELECT Opportunity_Stage__c FROM Stage_Objective__c)
                                           ORDER BY Stage_Number__c]){
                                               mstages.add(new SelectOption(stage.name,stageMap.get(stage.name)));
                                           }
        
        return mstages;       
    }
    
  /* public static boolean checkExemptProducts(String oppProds) {
        if (oppProds == null) {
            return true;
        }
        String[] oppProdArr = oppProds.split(';',0);
        Set<String> exemptProds = SP_Exempt_Products__c.getAll().keySet();
        
        if (exemptProds.containsAll(oppProdArr)) {
            return true;
        }
        
        return false;
    }*/
    
    public static List<SelectOptionWithDescription> getOpportunityStageswithDescription(string oppRecordTypeName){
        Map<String,String> stageMap = new Map<String,String>();
        List<SelectOptionWithDescription> mstages = new List<SelectOptionWithDescription>();
        for(Schema.PicklistEntry ple:Opportunity.sObjectType.getDescribe().fields.getMap().get('StageName').getDescribe().getPicklistValues()){
            stageMap.put(ple.getValue(),ple.getLabel());
            
        }
        
        
        
        for(Stage_Objective__c stage:[SELECT Opportunity_Stage__r.name, Opportunity_Stage__c,Objective_Job_Aid__c 
                                         FROM Stage_Objective__c 
                                         where Opportunity_Stage__r.name in: stageMap.keyset()
                                         order by Order__c
                                        ]){
                                            mstages.add(new SelectOptionWithDescription(stage.Opportunity_Stage__r.name,
                                                                                        stageMap.get(stage.Opportunity_Stage__r.name),
                                                                                        stage.Objective_Job_Aid__c));
                                        }
        
        return mstages;       
    }
    
    @AuraEnabled
    public static void requestCoaching(String selectedObjId, List<SP_OpportunityActionManager.Objective> stageObjectives, User userInfoDetails, Opportunity opp, String mgrEmail, String mgrId) {
        try
        {
            
            Stage_Objective__c obj = [select Name from Stage_Objective__c where Id =:selectedObjId];
            String toEmail = '';
            if (mgrEmail != '') {
                toEmail = mgrEmail;
            }
            else if (userInfoDetails.Manager.Email != null) {
                toEmail = userInfoDetails.Manager.Email;
            }
            else {
                toEmail = '';
            }
            
            System.debug('VCG Stage toEmail' + toEmail);
            if (toEmail != null) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {toEmail};
                    String[] ccAddresses = new String[] {userInfoDetails.Email};
                        mail.setToAddresses(toAddresses);
                mail.setCcAddresses(ccAddresses);
                mail.setReplyTo(userInfoDetails.Email);
                mail.setSenderDisplayName(userInfoDetails.Name);
                mail.setSubject('Sales Plan Coaching Requested');
                
               // String prefix = ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To');
               // prefix = prefix.substring(0, prefix.indexOf('.'));
                 mail.setPlainTextBody(userInfoDetails.Name + ' is requesting sales coaching for the SPI Objective ' + obj.Name + '. \r\n\r\nThis request is related to the Opportunity: ' + opp.Name );
                if (!Test.isRunningTest()) {
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                }
                createCoachingTask(opp.Id, opp.StageName, mgrId);
                
            }
            
        }catch(Exception ex)
        {
            System.debug('VCG Stage ex.getMessage()' + ex.getMessage() + '   at line number' + ex.getLineNumber());
        }
        
    }
    
    @AuraEnabled 
    public static void sendManagerCoachingEmail(String selectedObjId, List<SP_OpportunityActionManager.Objective> stageObjectives, User userInfoDetails, Opportunity opp, String managerEmail, String mgrId, String url )
    {
        
        
                Stage_Objective__c obj = [select Name from Stage_Objective__c where Id =:selectedObjId];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {managerEmail};
                    String[] ccAddresses = new String[] {userInfoDetails.Email};
                        mail.setToAddresses(toAddresses);
                mail.setCcAddresses(ccAddresses);
                mail.setReplyTo(userInfoDetails.Email);
                mail.setSenderDisplayName(userInfoDetails.Name);
                mail.setSubject('Sales Plan Coaching Requested');
                System.debug('VCG Stage Mail Formation');
                System.debug('URL ' + url);
                //mail.setPlainTextBody(userInfoDetails.Name + ' is requesting sales coaching for the SPI Objective ' + obj.Name + '. \r\n\r\nThis request is related to the Opportunity: ' + opp.Name );
               
                mail.setPlainTextBody(userInfoDetails.Name + ' is requesting sales coaching for the SPI Objective ' + obj.Name + '. \r\n\r\nThis request is related to the Opportunity: ' + opp.Name + '\r\n\r\n Link to Opportunity : ' + url);
                    
              
        
                if (!Test.isRunningTest()) {
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                }
                if(mgrId == null)
                    mgrId = getManagerIdByEmail(managerEmail);
                
                createCoachingTask(opp.Id, opp.StageName, mgrId);
        
    }
    
    public static Id getManagerIdByEmail(String managerEmail)
    {
        try
        {
        if(managerEmail <> '' && managerEmail <> null)
        {
            return [select Id, Name, Email from User where Email =: managerEmail LIMIT 1].Id;
        }            
        }catch(Exception ex)
        {
            return null;
        }
        return null;
        
    }
    
    public static void createCoachingTask(Id opptyId, String opptyStage, Id mgrId) {
        System.debug('VCG Debug - Current Task Owner' + mgrId);
        Task t = new Task();
        t.WhatId = opptyId;
        t.Subject = 'Request for Coaching - ' + opptyStage;
        RecordType reqCoaching;
        try {
            reqCoaching = [SELECT Id FROM RecordType WHERE DeveloperName = 'Request_for_Coaching' AND SobjectType = 'Task' LIMIT 1];
            t.RecordTypeId = reqCoaching.Id;
        }
        catch (Exception e) {
            reqCoaching = null;
        }
        //t.RecordTypeId = SystemIds__c.getInstance().RecordTypeId_Task_CoachingRequest__c;
        t.ActivityDate = Date.Today()+7;
        // t.Sales_Plan_Task__c = true;
        if (mgrId != null) {
            t.OwnerId = mgrId;
        }
        else {
            t.OwnerId = UserInfo.getUserId();
        }
        try {
            insert t;
        }
        catch (Exception e) {
            t.RecordTypeId = null;
            insert t;
        }
    }
    
    //Map<String,SP_OpportunityActionManager> managermap,
    @AuraEnabled    
    public static void saveActi(List<Task> actions, Opportunity opp, String nextStepSig){
        list<Task> actionsToUpdate = new list<Task>();
        String nextStep = '';
        Date nextStepDate = Date.today()+5000;
        Boolean foundNextStep = false;
        
        system.debug('@managerMap'+actions);
        
        system.debug('@actions'+actions);
        for(Task act: actions){
            system.debug('@act'+act);
            act.Sales_Activity_Type__c = act.Subject.replace('?','');
            
            if(act.IsClosed){                
                act.Status = 'Completed';
                
                if(act.ActivityDate == NULL || act.ActivityDate > Date.today()){
                    act.ActivityDate = Date.today();
                }
                
                system.debug('@another act'+act);
            }
            
            act.Sales_Plan_Task__c = true;
            act.Event_Type__c = 'VVS';
            actionsToUpdate.add(act);
            
            if (act.ActivityDate < nextStepDate && act.ActivityDate >= Date.today() && act.status != 'Completed') {
                foundNextStep = true;
                nextStepDate = act.ActivityDate;
                if (act.Description != null) {
                    nextStep = nextStepSig + act.Subject + ' - ' + act.Description;
                }
                else {
                    nextStep = nextStepSig + act.Subject + ' - (no comment)';
                }
            }
        }
        //system.debug('@actionsToUpdate'+actionsToUpdate);
        
        database.upsert(actionsToUpdate);
        
        // Populate Next Step and Next Step Date (if configured)
        if (SP_Settings__c.getInstance().Auto_Next_Step__c && foundNextStep) {
            if (nextStep.length() > 255) {
                opp.NextStep = nextStep.substring(0,255);
            }
            else {
                opp.NextStep = nextStep;
            }
            opp.Next_Steps_Date__c = nextStepDate;
        }
        
        UPDATE opp;
    }
    
    public class SalesPlanWrapper{
        @AuraEnabled public Opportunity opp {get;set;}
       // @AuraEnabled public Sales_Coach_Stage__c coach;
        @AuraEnabled public List<SelectOption> mstages {get;set;}
        @AuraEnabled public List<SelectOptionWithDescription> mstageswithdescription {get;set;}
        @AuraEnabled public Map<String,SP_OpportunityActionManager> managermap {get;set;}
        @AuraEnabled public Boolean isMgr {get;set;}
       // @AuraEnabled public Boolean allProductsExempt;
        @AuraEnabled public String nextStepSig {get;set;}
        @AuraEnabled public User userInfo {get;set;}
        @AuraEnabled public String mgrId {get;set;}
        @AuraEnabled public String currentStage {get;set;}
        
        public SalesPlanWrapper(){
            
        }
    }
    
    public class SelectOption{
        @AuraEnabled public String value {get;set;}
        @AuraEnabled public String label {get;set;}
        
        public SelectOption(String value, String label){
            this.value = value;
            this.label = label;
        }
    }
    
    public class SelectOptionWithDescription{
        @AuraEnabled public String value {get;set;}
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String description {get;set;}
        
        public SelectOptionWithDescription(String value, String label,String description){
            this.value = value;
            this.label = label;
            this.description = description;
        }
    }
    
    
}