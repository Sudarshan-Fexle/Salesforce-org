/**
 *  Purpose         :   This Batch is to replicate the solution data on the Account from the solution Staff Assignment 
 * 
 *  Created By      :   Mahendra Swarnkar
 * 
 *  Created Date    :   03/22/2016  
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20150908-9224
 *                      V_1.1 Modified By - Rajiv Jain - 17/02/2020 - CR-20190925-13366 -  Remove zzzSolution(Solution__c) field.
 *                      V_1.2 Modified By - Abhinav Sharma- 08/11/2020 - CR-20180808-12492 - Commented Solution_Adopted__c, Solution_Ended__c,Solution_Status__c field.
 *                      
 **/ 
global class Batch_UpdateSolutionRelatedDataOnAccount implements Database.Batchable<SObject>, Database.Stateful {

    //Variable to store dynamic soql query
    public String query;
    
    //String variable to hold the entire log message string value
    global String debugLogStr; 

    //Batch Constructor
    global Batch_UpdateSolutionRelatedDataOnAccount() {
        debugLogStr = '';
    }

    //Start Method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        //Checking query variable for null value
        if (query == null)
            query = 'SELECT Id, Institution__c ' +  
                    'FROM Team_Membership__c '+  
                    'WHERE Role__c != null ' +
                    'AND Institution__c != null ' + 
                    'AND Role__r.Active__c != null ' + 
                    'AND Role__r.Active__c = true ' +
                    'AND Status__c != null ' +
                    'AND Status__c != ' + '\'\'' +
                    'AND Status__c = ' + '\'Inactive\'  ';
        
        return Database.getQueryLocator(query);
    }
    
    //Execute method
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
    
        //Set to hold the institution Ids
        Set<Id> setInstitutionIds = new Set<Id>();
        
        //Loop through staff assignment records in current context
        for(Team_Membership__c tm : (List<Team_Membership__c>)scope) {
            if(tm.Institution__c != null)
                setInstitutionIds.add(tm.Institution__c);
        }
        
        //Checking set for size value
        if(setInstitutionIds.size() > 0) {
            
            //Map having account Id key as
            Map<Id, Integer> mapAccountIdWithActiveSACount = new Map<Id, Integer>();
            Map<Id, Date> mapAcountIdwithInactiveSALatestRoleStart = new Map<Id, Date>();
            Map<Id, Date> mapAcountIdwithSALatestRoleEnd = new Map<Id, Date>();
            
            //Map of accounts
            Map<Id, Account> mapAccounts = new Map<Id, Account>();
            
            //Modified by Mahendra Swarnkar - 05/05/2020 - CR-20200218-13769 - Solution_Partner__c deleted
            //Loop through staff assignment records
             //Commented by Abhinav Sharma- 08/11/2020 - CR-20180808-12492 - Solution_Adopted__c,Solution_Ended__c,Solution_Status__c
            for(Team_Membership__c tm : [SELECT Id, Start_date__c, End_date__c, Staff_member__c, Institution__c, Status__c,
                                         Role__c, Role__r.Active__c, Role__r.Name 
                                         /*Institution__r.Solution_Adopted__c,Institution__r.Solution_Ended__c,
                                          Institution__r.Solution_Status__c,*//*Institution__r.Solution_Partner__c*/
                                         FROM Team_Membership__c 
                                         WHERE Institution__c != null 
                                         AND Institution__c IN : setInstitutionIds
                                         AND Role__c != null
                                         AND Role__r.Active__c != null
                                         AND Role__r.Active__c = true
                                         ORDER BY LastModifiedDate ASC]) {  
                
                //Modified by Mahendra Swarnkar - 05/05/2020 - CR-20200218-13769 - Solution_Partner__c deleted
                //Populating account map with fields values                             
                //Commented by Abhinav Sharma- 08/11/2020 - CR-20180808-12492 - Solution_Adopted__c,Solution_Ended__c,Solution_Status__c                       
                mapAccounts.put(tm.Institution__c, new Account(Id = tm.Institution__c 
                                                               /*Solution_Partner__c = tm.Institution__r.Solution_Partner__c,*/
                                                               //Solution_Ended__c = tm.Institution__r.Solution_Ended__c,
                                                               //Solution_Status__c = tm.Institution__r.Solution_Status__c
                                                              ));                                
                
                //Checking for the Inactive status
                if(tm.Status__c != null && tm.Status__c != '' && tm.Status__c == 'Inactive') {                         
                     
                    //Checking for key presence in map and populating it with latest End date value for Active SA records
                    if(!mapAcountIdwithSALatestRoleEnd.containsKey(tm.Institution__c))
                        mapAcountIdwithSALatestRoleEnd.put(tm.Institution__c, tm.End_Date__c);
                    else {
                        if((mapAcountIdwithSALatestRoleEnd.get(tm.Institution__c) == null 
                            || (tm.End_Date__c > mapAcountIdwithSALatestRoleEnd.get(tm.Institution__c))))
                            mapAcountIdwithSALatestRoleEnd.put(tm.Institution__c, tm.End_Date__c);
                    }
                    
                    //Checking for key presence in map and populating it with latest start date value
                    if(!mapAcountIdwithInactiveSALatestRoleStart.containsKey(tm.Institution__c))
                        mapAcountIdwithInactiveSALatestRoleStart.put(tm.Institution__c, tm.Start_date__c);
                    else {
                        if((mapAcountIdwithInactiveSALatestRoleStart.get(tm.Institution__c) == null 
                            || (tm.Start_date__c > mapAcountIdwithInactiveSALatestRoleStart.get(tm.Institution__c))))
                            mapAcountIdwithInactiveSALatestRoleStart.put(tm.Institution__c, tm.Start_date__c);
                    }
                }
                    
                //Checking for the active status                             
                if(tm.Status__c != null && tm.Status__c != '' && tm.Status__c == 'Active') {
                    
                    //Populating map with appropriate key and value pair
                    if(!mapAccountIdWithActiveSACount.containsKey(tm.Institution__c))
                        mapAccountIdWithActiveSACount.put(tm.Institution__c, 1);
                    else
                        mapAccountIdWithActiveSACount.put(tm.Institution__c, (mapAccountIdWithActiveSACount.get(tm.Institution__c) + 1));
                }                             
            }
            
            //Map of accounts
            Map<Id, Account> mapAccountsToUpdate = new Map<Id, Account>();
            
            //Loop through staff assignment records in current context
            for(Team_Membership__c tm : (List<Team_Membership__c>)scope) {
                
                if(tm.Institution__c != null && !mapAccountIdWithActiveSACount.containsKey(tm.Institution__c)) {
                    
                    //Populating account instance with fields values and then adding it to map of records
                    Account acc = new Account(Id = tm.Institution__c);
                    
                    if(mapAccounts.containsKey(tm.Institution__c) 
                        && mapAccounts.get(tm.Institution__c) != null) {
                        
                        //Commented by Abhinav Sharma- 08/11/2020 - CR-20180808-12492 - Solution_Adopted__c,Solution_Ended__c,Solution_Status__c
                        //Checking for SA record Id on which RoleStart date is grater that today and 
                        //blank out the  solution status field value on the institution.  
                        /*if(mapAcountIdwithInactiveSALatestRoleStart.containsKey(tm.Institution__c) 
                            && mapAcountIdwithInactiveSALatestRoleStart.get(tm.Institution__c) > System.today() )
                            acc.Solution_Status__c = null;
                        else{
                            if(mapAccounts.get(tm.Institution__c).Solution_Status__c != System.label.SOLUTION_PARTNER_STATUS_FORMER)
                                acc.Solution_Status__c = System.label.SOLUTION_PARTNER_STATUS_FORMER;        
                        }*/
                        
                        //Modified by Mahendra Swarnkar - 05/05/2020 - CR-20200218-13769 - Solution_Partner__c deleted
                        /*if(mapAccounts.get(tm.Institution__c).Solution_Partner__c != null)
                            acc.Solution_Partner__c = null;*/    
                            
                        //Commented by Abhinav Sharma- 08/11/2020 - CR-20180808-12492 - Solution_Adopted__c,Solution_Ended__c    
                        /*if(mapAcountIdwithSALatestRoleEnd.containsKey(tm.Institution__c))
                            acc.Solution_Ended__c = mapAcountIdwithSALatestRoleEnd.get(tm.Institution__c);*/
                    
                        mapAccountsToUpdate.put(tm.Institution__c, acc);    
                    }
                }
            } 
            
            //String variable to hold the error message string in case of any failure
            String logMessage = '';
        
            //Check for size 
            if(mapAccountsToUpdate.values().size() > 0) {
            
                //disable the all the triggers
                Util.BypassAllTriggers = true;
            
                //Making a try to update the list of records and recording error messages will be emailed to the SFAdmin 
                logMessage = Util.createLog(Database.update(mapAccountsToUpdate.values(), false));
                
                //Enable the all the triggers
                Util.BypassAllTriggers = false;
            }
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '') 
                debugLogStr += logMessage;
        }    
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC) {
        
        //Checking error string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '')
            Util.sendBatchStatus(BC.getJobId(), 'Batch_UpdateSolutionRelatedDataOnAccount', debugLogStr, Label.Salesforce_Admin_Email);
        
        //Upto here
    }
}