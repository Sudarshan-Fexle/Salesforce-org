/**
 *  Description     :   Batch that fetch all users which got deactivated in last 24 hours, then fetch all the "Contacts" owned by these users and transfer ownership to SFAdmin User.
 * 
 *  Created By      :   Dipesh Gupta  
 * 
 *  Created Date    :   08/17/2017
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20170412-10836 
 *
 **/                    
global class Batch_UpdateInActiveOwnershipToSFAdmin implements Database.Batchable<sObject>, Database.Stateful {
	
    //Set to hold the set of Object Names for which batch already executed. 
    global Map<String, Boolean> mapObjectNameWithAlreadyExecutedFlag;
	
    //String variable to hold the entire log message string value
    global String debugLogStr;
    
    //String to hold the query.
	global String query;
    
    //Object Name of Records for which ownership will be updated  
    global String objectName;
    
    //Hold the SF Admin User Id
    global String sfAdminId;
    
    //Batch size for next batch
    global Integer nextBatchSize;
    
    //hold the hour within which user ercord got deactivated
    global Integer lastNHours;
    
    //Method to get org default values from User_InActive_Ownership_To_SFAdmin__c custom setting
    public void getUserInActiveOwnershipToSFAdminRecords(){
        
        //Get Default values from the Custom settings.
		User_InActive_Ownership_To_SFAdmin__c userInactiveOwnerShip = User_InActive_Ownership_To_SFAdmin__c.getOrgDefaults();
        
        //Populate Salesforce Admin Id
        if(userInactiveOwnerShip.SFAdmin_Id__c != null)
        	sfAdminId = userInactiveOwnerShip.SFAdmin_Id__c;
        
        //Populate Default batch size
        if(userInactiveOwnerShip.Batch_Size__c != null)
        	nextBatchSize = Integer.valueOf(userInactiveOwnerShip.Batch_Size__c);
        
        //Populate Default number of hours, user records will be queried from this hours (like last N Hours)  
        if(userInactiveOwnerShip.Last_N_Hours__c != null)
        	lastNHours = Integer.valueOf(userInactiveOwnerShip.Last_N_Hours__c);
    }
    
    //Batch class Init method
    public void init () {
        
		//Method call to get custom setting default values 
        getUserInActiveOwnershipToSFAdminRecords();
        
        //Reset the Object Name (Type of records that are going to be updated)
        objectName = '';
        
        //Check for size
        if(mapObjectNameWithAlreadyExecutedFlag == null ) {  
         	
            //instantiate the map
            mapObjectNameWithAlreadyExecutedFlag = new Map<String, Boolean> ();
            
            //Get All the custom Metadata records
            for(User_Setting__mdt userSetting : [Select Id, Object_Name__c 
                                                 	From User_Setting__mdt 
                                                 	where IsEnableForBatch__c = true AND Object_Name__c != null]
			) {
                //Populate the map O bject Name with the flag value
                mapObjectNameWithAlreadyExecutedFlag.put((userSetting.Object_Name__c).toLowerCase(), false);
            }
            
            //Check for the size
            if(mapObjectNameWithAlreadyExecutedFlag.size() > 0){
                
                //Populate objectName with index 1 mentioned Object name on the map 
                for(String objeName : mapObjectNameWithAlreadyExecutedFlag.keySet()){
                    objectName = objeName;
                    break;
                }
            }
        }
        else{
            
            //If map is already populated 
            if(mapObjectNameWithAlreadyExecutedFlag.size() > 0) {
				
                //Loop over the objects name
                for(String objNames : mapObjectNameWithAlreadyExecutedFlag.keySet()) {
                    
                    //Check if the batch is already executed for ObjectName, else populate the objectName for the next objectName whose recirds will be updated for ownership 
                    if(mapObjectNameWithAlreadyExecutedFlag.get(objNames) != null 
                       	&& mapObjectNameWithAlreadyExecutedFlag.get(objNames)
					){
						continue;  
                    } else {
                        objectName = objNames;
                        break;
                    }
                }
            }
        }
        
       
        //Check for the Query to be executed and then set the default query string
        if(query == null)
        	query = 'Select Id From User Where IsActive = false AND LastModifiedDate <: DateTimeStart'+' AND LastModifiedDate >:  DateTimeEnd';
        	
    }
    
    //Start Method
	global Database.QueryLocator start(Database.BatchableContext bc) {
        
        //Methid call to set defaults values for this batch execution 
        init();
        
        DateTime DateTimeStart = System.now();
		DateTime DateTimeEnd = DateTimeStart.addhours(-lastNHours);
		 
		return database.getQueryLocator(query);
  	}
  
	//Execute Method
	global void execute(Database.BatchableContext bc, List<User> scope){
    	
    	//String variable to hold the error message string in case of any failure
    	String logMessage = '';
        
		//Check for the value
        if(String.isNotBlank(objectName) ){
         
            //Dynamic query to get the records to be updated  
            String queryToFetchObjectRecordsToBeUpdated = 'Select Id, OwnerId FROM '+ objectName + ' Where OwnerId IN :scope';
            
            //List to hold the ObjectNAme records to be updated
            List<SObject> recordsToBeUpdated = new List<SObject>();
            
            //Query the ObjectName records
            for(SObject obj : database.query(queryToFetchObjectRecordsToBeUpdated)) {
                
                //Check fro SF admin user Id 
                if(sfAdminId != null ){
                  
                    //update ownership to SF Admin user.
                    obj.put('OwnerId', sfAdminId);
                    
                    //Populate the list to be updated 
                    recordsToBeUpdated.add(obj);
                }
            }
            
            //Check for size
            if(recordsToBeUpdated.size() > 0) {
            
				//By Pass all the triggers 
                util.bypassAllTriggers = true;
                
                //Making a try to update the list of records and recording error messages will be wmailed to the SFAdmin 
                logMessage = Util.createLog(Database.update(recordsToBeUpdated,false));
                
                //By Pass all the triggers 
                util.bypassAllTriggers = false;
            }
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
        	if(logMessage != '') 
            	debugLogStr += logMessage;
        }
 	}
  
	//Finish method
	global void finish(Database.BatchableContext bc) {
	
 		//Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '') 
        	Util.sendBatchStatus(bc.getJobId(), 'Batch_UpdateInActiveOwnershipToSFAdmin', debugLogStr, Label.Salesforce_Admin_Email);
        
        //Remove the curren objectName from the map as for this objectType Batch is already executed 
        mapObjectNameWithAlreadyExecutedFlag.remove(objectName);
        
        //Check if More objects are available to Process the their records Then execute the batch 
        if(mapObjectNameWithAlreadyExecutedFlag != null && mapObjectNameWithAlreadyExecutedFlag.size() > 0 && !Test.isRunningTest()) {
            
            //Instantiate the batch 
            Batch_UpdateInActiveOwnershipToSFAdmin bat = new Batch_UpdateInActiveOwnershipToSFAdmin();
            
            //Set the map that needs to be processed
            bat.mapObjectNameWithAlreadyExecutedFlag = mapObjectNameWithAlreadyExecutedFlag;
            
            //Schedule the Apex batch after 5 minute of the completion of current batch execution 
            System.scheduleBatch(bat, 'Batch_UpdateInActiveOwnershipToSFAdmin'+system.today()+'_' + math.random(), 5, nextBatchSize);   
        }
    }
}