/**
 *	Purpose			:	Batch is using to Upadte information on Account realted to Program Package/HD	
 *
 *	Created By		:	Subhash Garhwal	
 *
 *	Created Date	:	07/08/2016	
 *
 *	Rivision Log	:	V_1.1 - Created	
 *					:	V_1.2 - Moved - 9/20/2016 - Subhash Garhwal - CR-20160817-10134 - Moved class from Royall Instance and Renamed to "Batch_RoyallShiftAccountStatus" From "Batch_ShiftAccountStatus".
 *					:	V_1.3 - Modify By - Mahendra Swarnkar - 2/18/2017 - CR-20170215-10692 - a) commented "programPackageHD" method logic 
 *								b) Updated "programPackage" method to apply record type check for Program_Package__c records 
 * 								   and accordingly populate the Royall and HD fields on Institution.  
 						V_1.4 - Modified By - Abhinav Sharma - CR-20180809-12493 - remove all the references of Royall Undergraad and Advancement record type. - Abhinav Sharma - CR-20180809-12493
 *
 **/
global class Batch_RoyallShiftAccountStatus implements Database.Batchable<sobject> { 
	 
	//String variable to hold the entire log message string value
    global String debugLogStr;
    
    /**
	 * @description		:	Batch class Start method
	 *
 	 * @args			:	Database.BatchableContext bc
	 *
	 * @return			:	Database.QueryLocator
	 **/
	global Database.QueryLocator start(Database.BatchableContext bc){
		
		//Updated the record types set to remove all the references of Royall Undergraad and Advancement record type. - Abhinav Sharma - CR-20180809-12493
		//Added - Subhash Garhwal - 9/20/2016 - CR-20160817-10134
		//Set to hold the Royall Record types developer name
		Set<String> setRoyallRecordTypes = new Set<String>{'Royall_Admissions_Graduate' /*, 'Royall_Admissions_Undergraduate', 'Royall_Advancement'*/};
		
		//SOQL query string
		String queryString = 'Select Id,r_Current_Year_Status__c From Account Where RecordType.DeveloperName IN : setRoyallRecordTypes';
   		
   		//return query
		return Database.getQueryLocator(queryString);
		
	}
	
	/**
	 * Description		:	Batch class execute method
	 *
	 * Args				:	Database.batchableContext bc, List<Account> scope
	 *
	 * Return			:	Void
	 **/
	global void execute(Database.batchableContext bc, List<Account> scope ) {
		
        //String variable to hold the error message string in case of any failure
        String logMessage = '';
        
		//Calculate the current Fiscal year using shift_fical_year class
	    Integer currentFY = shift_get_fiscal_year.current();
	    
		//Map Of Account to be update 
		Map<Id,Account> mapOfAccountsTobeUpdated = new Map<Id, Account>();
		
		//Method calling for program package method in "Shift_StatusRollup_Handler" class.
		mapOfAccountsTobeUpdated = Shift_StatusRollup_Handler.programPackage(scope,currentFY);
		
        //V_1.3 - Modify By - Mahendra Swarnkar - 2/18/2017 - CR-20170215-10692 - a) commented "programPackageHD" method logic - Starts from here
		/*
        //Method calling for program package
        programPackage(mapOfAccountsTobeUpdated, scope,currentFY);
        
		//Method call for program package
		programPackageHD(mapOfAccountsTobeUpdated, scope,currentFY);
		*/
		//V_1.3 - Modify By - Mahendra Swarnkar - 2/18/2017 - CR-20170215-10692 - a) commented "programPackageHD" method logic - Ends here
		
		//Check map value size
		if(mapOfAccountsTobeUpdated.values() != null 
           && mapOfAccountsTobeUpdated.values().size() > 0)
        {
            //Update  account records
            logMessage = Util.createLog(Database.update(mapOfAccountsTobeUpdated.values(),false));
		} 
        
        //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
        if(logMessage != '') 
            debugLogStr += logMessage;
	}
	
	/**
	 * @description		:	Batch class finish method
	 *
	 * @args			:	Database.batchableContext bc
	 *
	 * @return			:	Void
	 **/
	global void finish(Database.batchableContext bc)
    {
		//Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '') 
        	Util.sendBatchStatus(bc.getJobId(), 'Batch_RoyallShiftAccountStatus', debugLogStr, Label.Salesforce_Admin_Email);		
    }
	
    //V_1.3 - Modify By - Mahendra Swarnkar - 2/18/2017 - CR-20170215-10692 - Comment out this method and created a common method "Shift_StatusRollup_Handler.programPackage" 
   /**
	 * @description		:	Method is using into batch execute method for popuplate Account fields for Program package information
	 *
	 * @args			:	Map<Id,Account> mapOfAccountsTobeUpdated, List<Account> scope, Integer currentFY
	 *
	 * @return			:	Void
	 **/
	/*public void programPackage(Map<Id,Account> mapOfAccountsTobeUpdated, List<Account> scope, Integer currentFY) {
		
		//List of Program Package related to set of Account Ids
	    List<Program_Package__c> progPackList = new List<Program_Package__c>([Select Id, Name, Account__c, Fiscal_Year__c, Client_Status_New__c,
	    											Account_Status__c from Program_Package__c where Account__c in: scope
	                        						order by Account__c asc, Fiscal_Year__c asc]); 
	                        						
		for(Program_Package__c p : progPackList) {
			
			//Check if map conatins Account Id realted to progaram packages
        	if(mapOfAccountsTobeUpdated.containsKey(p.Account__c)) {
                		
                		
				//Get the status for Previous, Current and Next Fiscal Year
	            if (p.Fiscal_Year__c != null){  
	            	
	            	//Check if Fiscal year equals to Current Fiscal year    
	                if (integer.valueOf(p.Fiscal_Year__c) == currentFY) {
	                	
	                	//Populated Account'S field Current Year Status and Current Year Account Status by PP fields
	            		mapOfAccountsTobeUpdated.get(p.Account__c).r_Current_Year_Status__c = p.Client_Status_New__c;
	            		mapOfAccountsTobeUpdated.get(p.Account__c).r_Current_Year_Account_Status__c = p.Account_Status__c;
	            	}
	          		
	          		
	          		//Check if fiscal year is less 1 year from current fiscal year
	                if (integer.valueOf(p.Fiscal_Year__c) == currentFY+1) {
	                   	
		        		//Populated Account'S field Next Year Status and NExt Year Account Status by PP fields
		        		mapOfAccountsTobeUpdated.get(p.Account__c).r_Next_Year_Status__c = p.Client_Status_New__c;
		        		mapOfAccountsTobeUpdated.get(p.Account__c).r_Next_Year_Account_Status__c = p.Account_Status__c;
	                	
	            	}
	            	
	            	//Check if fiscal year is greater than 1 year from current fiscal year
	                if (integer.valueOf(p.Fiscal_Year__c) == currentFY-1) {
	                   	
		        		//Populated Account'S field Prevous Year Status and previous Year Account Status by PP fields
		        		mapOfAccountsTobeUpdated.get(p.Account__c).r_Previous_Year_Status__c = p.Client_Status_New__c;
		        		mapOfAccountsTobeUpdated.get(p.Account__c).r_Previous_Year_Account_Status__c = p.Account_Status__c;
	                }
	            } 
        	}
        }
	}
	*/
    
    //V_1.3 - Modify By - Mahendra Swarnkar - 2/18/2017 - CR-20170215-10692 - a) commented "programPackageHD" method logic - Starts from here
	/**
	 * @description		:	Method is using into batch execute method for popuplate Account fields for Program packageHD information
	 *
	 * @args			:	Map<Id,Account> mapOfAccountsTobeUpdated, List<Account> scope, Integer currentFY
	 *
	 * @return			:	Void
	 **/
	/*public void programPackageHD(Map<Id,Account> mapOfAccountsTobeUpdated, List<Account> scope, Integer currentFY) {
		
		//List Of  Program Packages HD
	    List<Program_Package_Hardwick_Day__c> progPackHDList = new list<Program_Package_Hardwick_Day__c>([Select Id, Account__c, Fiscal_Year_HD__c,
    														 	Client_Engagement_Status_HD__c, HD_Account_Status__c from Program_Package_Hardwick_Day__c
                												where Account__c in: scope order by Account__c asc, Fiscal_Year_HD__c asc]);  
                												
		//Loop over List of Program Packages HD
        for (Program_Package_Hardwick_Day__c pHD : progPackHDList) {
        	
        	//Check if map conatins Account Id related to progaram packages HD
        	if(mapOfAccountsTobeUpdated.containsKey(pHD.Account__c)) {
                		
	            //Get the status for Previous, Current and Next Fiscal Year HD
	            if (pHD.Fiscal_Year_HD__c != null){  
	            	
	            	//Check if Fiscal year HD equals to Current Fiscal year    
	                if (integer.valueOf(pHD.Fiscal_Year_HD__c) == currentFY) {
	                	
                		//Populated Account'S field Current Year Engagement Status and Current Year Account Status by PPHD fields
                		mapOfAccountsTobeUpdated.get(pHD.Account__c).r_HD_Current_Year_Engagement_Status__c = pHD.Client_Engagement_Status_HD__c;
                		mapOfAccountsTobeUpdated.get(pHD.Account__c).r_hd_current_year_account_status__c = pHD.HD_Account_Status__c;
	          		}
	          		
	          		//Check if fiscal year HD is greater than 1 year from current fiscal year
	                if (integer.valueOf(pHD.Fiscal_Year_HD__c) == currentFY+1) {
	                   
	                   	//Populated Account'S field Next Year Engagement Status and Next Year Account Status by PPHD fields
                		mapOfAccountsTobeUpdated.get(pHD.Account__c).r_HD_Next_Year_Engagement_Status__c = pHD.Client_Engagement_Status_HD__c;
                		mapOfAccountsTobeUpdated.get(pHD.Account__c).r_HD_Next_Year_Account_Status__c = pHD.HD_Account_Status__c;
	            	}
	            	
	            	//Check if fiscal year HD is less than 1 year from current fiscal year 
	                if (integer.valueOf(pHD.Fiscal_Year_HD__c) == currentFY-1) {
	                   
	                   	//Populated Account'S field previous Year Engagement Status and previous Year Account Status by PPHD fields
	            		mapOfAccountsTobeUpdated.get(pHD.Account__c).r_HD_Previous_Year_Engagement_Status__c = pHD.Client_Engagement_Status_HD__c;
	            		mapOfAccountsTobeUpdated.get(pHD.Account__c).r_HD_Previous_Year_Account_Status__c = pHD.HD_Account_Status__c;
	                }
	            } 
        	}
        } 
	} 
    */
    //V_1.3 - Modify By - Mahendra Swarnkar - 2/18/2017 - CR-20170215-10692 - a) commented "programPackageHD" method logic - Ends here
}