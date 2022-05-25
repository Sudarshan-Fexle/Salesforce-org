/*
 * Purpose		:	Batch class to create new Membership records on the basis of Account related program's "Create membership" field value. .
 * 
 * Create By	:	Mahendra Swarnakar
 * 
 * Version		:	v1.0 (Created)
 * 
 * Revision Log	:	v1.0 - Created - CR-20160428-9806 - 5/9/2016 
 * 					Modified BY abhinav sharma - 04/20/2018
 * 
*/
global class Batch_Create_Memberships implements Database.Batchable<SObject>, Database.Stateful {

    //Debug Log
    global String debugLog;
    
    //Query String
    public string soqlstr {get; set;}
    
    //List to hold the all Program records
    global List<Program__c> allprograms;
    
    global Set<Id> setProgramIds = new Set<Id>(); 
    
    //Start method
    global Database.Querylocator start(Database.BatchableContext BC) {
        
        //Check if the set contains the value - Call from the Program Trigger
        if(setProgramIds != null && setProgramIds.size() > 0) {
        	
            allprograms = [Select id, Program_Acronym__c, Applicable_Segments__c, Membership_Record_Type__c
                        From Program__c 
                        WHERE Create_Memberships__c != null AND Create_Memberships__c != ''
                        AND Create_Memberships__c = 'Yes' AND Id IN: setProgramIds AND Status__c = 'Active'];
        }
       	//Calls from the Account modified 
        else {
            
             //Query through all Program records
       		 allprograms = [Select id, Program_Acronym__c, Applicable_Segments__c, Membership_Record_Type__c 
                        From Program__c 
                        WHERE Create_Memberships__c != null AND Create_Memberships__c != ''
                        AND Create_Memberships__c = 'Yes' AND Status__c = 'Active'];
        }
		                
        //Initialize
        debugLog = '';
        return Database.getQueryLocator(soqlstr);
    }
     
    //Execute method
    global void execute(Database.BatchableContext BC, List<Account> accounts) {
        
        //List to hold new Membership records
        List<Membership__c> newMsps = new List<Membership__c> ();

        //Set to hold the unique key (Account + Program) for the Membership to Prevent adding duplicate memberships
        Set<String> setOfExistingMemberships = new Set<String>();
        
        //Checking for the null and size value
        if(accounts != null && accounts.size() > 0 
            && allprograms != null && allprograms.size() > 0) {
        
            //Query through membership records and populating the set 
            for (Membership__c m : [SELECT ID, Account_Name__c, Program__c 
                                        FROM Membership__c 
                                        WHERE Account_Name__c != null
                                        AND Program__c != null
                                    	AND Account_Name__c IN : accounts])
                setOfExistingMemberships.add(String.valueOf(m.Account_Name__c) + String.valueOf(m.Program__c));
            
            //Loop through Account records
            for (Account a : accounts) {
                
                //Loop through program records
                for (Program__c prog: allprograms) {
                    
                    //Check for null 
                    if (prog.Applicable_Segments__c == null) continue;
                    
                    //Check for record type 
                    if (a.RecordtypeId != null
                        && a.Recordtype.Name != null
                        && Util.accountRT2SegmentMap.containsKey(a.Recordtype.Name)
                        && Util.accountRT2SegmentMap.get(a.Recordtype.Name) != null 
                        && prog.Applicable_Segments__c.contains(Util.accountRT2SegmentMap.get(a.Recordtype.Name))) {
                            
                        String accname = a.Name;
                        Integer maxaccnamelength = 55;
                        accname = accname.substring(0,(Math.min(maxaccnamelength, accname.length())));
                            
                        //Check for existing Membership records
                        if(!setOfExistingMemberships.contains(String.valueOf(a.Id) + String.valueOf(prog.Id))) {                     
                            
                            //Getting the Id of Standard Recorrd type of the Membership.
                           	Id membershipRT = Constants.Membership_Record_Type1;
                            
                            //Check for the Program membership Record type 
                            if(String.isNotBlank(prog.Membership_Record_Type__c) && Constants.MAP_MEMBERSHIP_RECORDTYPES.containsKey(prog.Membership_Record_Type__c) 
                               && Constants.MAP_MEMBERSHIP_RECORDTYPES.get(prog.Membership_Record_Type__c) != null) 
                            	membershipRT = 	Constants.MAP_MEMBERSHIP_RECORDTYPES.get(prog.Membership_Record_Type__c);
                            
                            
                            //Added the Record type Id in the List
                            //Populating newMsps list by creating new membership records
                            newMsps.add(new Membership__c (Name = accname + ' - ' + prog.Program_Acronym__c, 
                                                           Program__c = prog.id, Account_Name__c = a.id, RecordtypeId = membershipRT ));
                        }   
                    }
                }   
            }
        }
        
        //String variable to hold the error message string in case of any failure
        String logMessage = '';
        
        //Check for size
        if(newMsps != null && newMsps.size() > 0) {
            
            //Making a try to update the list of records and recording error messages will be emailed to the SFAdmin 
            logMessage = Util.createLog(Database.insert(newMsps, false));
        }
        
        //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
        if(logMessage != '') 
            debugLog += logMessage;
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC) {
        
        //Checking error string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLog != '')
            Util.sendBatchStatus(BC.getJobId(), 'Batch_Create_Memberships', debugLog, Label.Salesforce_Admin_Email);
    }
}