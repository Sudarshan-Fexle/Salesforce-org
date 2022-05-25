/* 
* Name          : Shift_StatusRollup_Handler
* Author        : Shift CRM
* Description   : Calculates program package account status based on previous fiscal year.
*          Calculates engagement status and account status rollups on account.
*
* Maintenance History: 
* Date ---------Name  -------------Version ---  Remarks 
* 07/14/2014	Hermes				1.0			Initial
* 07/18/2014	Hermes				1.1			Refactor status logic
* 06/16/2016	Rajeev				1.2			SFDC Roayall Schema Release - Manauly migrated code from Royall Enviournment to Corporate Instance - 
* 09/20/2016	Subhash     		1.3			CR-20160817-10134 
* 12/27/2016	Mahendra Swarnkar	1.4			CR-20161128-10501 - Since we are going to merge the Program package (HD) into the Program package (Royall) So commented out the some part of code.
* 02/18/2017	Mahendra Swarnkar	1.5			CR-20170215-10692 - 
*												1.a) Created a new common "programPackage" method to check the record type of Program_Package__c 
* 													and accordingly populate the Royall and HD specific fields on Institution.
*												1.b) This new method will be called by "Shift_StatusRollup_Handler" class and "Batch_RoyallShiftAccountStatus" batch class
*												2.a) Updated "accountRollupsRoyal" method to call the "programPackage" method and commented the common code. 
* 03/15/17		Victor Hanson		1.6			CR-20170215-10692 - Updated getPPToUpdate so the map key also filters by RecordType.  Deleted commented out code
* 08/26/19		Mahendra Swarnkar	1.7			CR-20190826-13287 - Updated setAccountStatus so that it can update the account status for EAB and Royall Kind of PP.
*/

public without sharing class Shift_StatusRollup_Handler {
  
    //constants
    public static final String  EXISTING_CLIENT = 'Existing Client';
	public static final String  NEW_CLIENT = 'New Client';
    public static final String  STATUS_COMMITTED = 'Committed';
    public static final String  STATUS_SECURED = 'Secured';
    public static final String  STATUS_LOST = 'Lost';
    public static boolean IsFromSched_SubscriptionPeriodCreation = false;
    //bypass variable to ensure we don't get in to a recursive update situation
    public static boolean bypassSetAcctStatus {
        get {
            if (bypassSetAcctStatus == null) bypassSetAcctStatus = false;
            return bypassSetAcctStatus;
        }
        set;
    }
    
    /**
     * 
     * @description: Update the Account Status field to either "New Customer" or "Existing Customer" 
     *         based on whether or not there was a program package for the previous year where Engagement Status != "Lost".
     * 
     **/
    public static void setAccountStatus(list<Program_Package__c> ppList) {
        
        if ( !(Shift_StatusRollup_Handler.IsFromSched_SubscriptionPeriodCreation) && bypassSetAcctStatus) return;
        	bypassSetAcctStatus = true;
        
        set<Id> ppIds = new set<Id>();
        set<Id> accountIds = new set<Id>();
        list<Program_Package__c> ppToUpdate = new list<Program_Package__c>();
        map<string, Program_Package__c> FYToPPMap = new map<string, Program_Package__c>();
        
        // Added on - 08/26/19 - CR-20190826-13287 - Mahendra Swarnkar - Updated setAccountStatus so that it can update the account status for EAB and Royall Kind of PP
        Set<Id> setRecordTypeIds = new Set<Id>();
        
        for (Program_Package__c pp : ppList) {
            accountIds.add(pp.Account__c);
            ppIds.add(pp.Id);
            
            //Populate the recordtype set
            setRecordTypeIds.add(pp.RecordTypeId);
            
            if (pp.Client_Status_New__c != STATUS_LOST) {
                FYToPPMap.put(pp.Account__c + '-' + pp.RecordTypeId + '-' + integer.valueOf(pp.Fiscal_Year__c), pp);
            }
                
        }
        
        list<Account> accountsToUpdate = new list<Account>();
        
        //pull only those PP which are fall under the record types in "setRecordTypeIds" under the related institutions.
        list<Account> accounts = [SELECT Id,
                                  (SELECT Id, Fiscal_Year__c, FY_Date__c, Account__c, Account_Status__c, Client_Status_New__c, RecordTypeId
                                   FROM Program_Packages__r 
                                   WHERE Client_Status_New__c != :STATUS_LOST AND Fiscal_Year__c != null AND ID NOT IN :ppIds AND RecordTypeId IN : setRecordTypeIds)
                                  FROM Account 
                                  WHERE Id IN :accountIds];
        
        
        for (Account a : accounts) {
            for (Program_Package__c pp : a.Program_Packages__r) FYToPPMap.put(pp.Account__c + '-' + pp.RecordTypeId + '-' + integer.valueOf(pp.Fiscal_Year__c), pp);
        }
        
        //see which pp records need to be updated
        for (Account a : accounts) {
            ppToUpdate = getPPToUpdate(a.Program_Packages__r, FYToPPMap, ppToUpdate);
        }
        
        
        getPPToUpdate(ppList, FYToPPMap, new list<Program_Package__c>());
        System.debug('###########ppToUpdate : ' +ppToUpdate);
        System.debug('###########ppToUpdatesize : ' +ppToUpdate.size());
        
        if (ppToUpdate.size() > 0) {
            
            Util.bypassAllTriggers = true;
             update ppToUpdate;
            Util.bypassAllTriggers = false;
        }
    }
    
    /**
     * 
     * @description: Update the Account Status field to either "New Client" or "Existing Client"
     * 
     * @return value: list of program packages with the account status field updated
     * 
     **/
    private static list<Program_Package__c> getPPToUpdate(list<Program_Package__c> ppList, map<string, Program_Package__c> FYToPPMap, list<Program_Package__c> ppUpdateList) {
        for (Program_Package__c pp : ppList) {

            if (FYToPPMap.containsKey(pp.Account__c + '-' + pp.RecordTypeId + '-' + (integer.valueOf(pp.Fiscal_Year__c)-1))) {
                Program_Package__c prevYearPP = FYToPPMap.get(pp.Account__c + '-' + pp.RecordTypeId + '-' + (integer.valueOf(pp.Fiscal_Year__c)-1));
                
                system.debug(' @@@@@@@ Client_Status_New__c' + prevYearPP.Client_Status_New__c + ' @@@@@ prevYearPP : ' + prevYearPP );
                system.debug(' @@@@@@@ pp.Account_Status__c : ' + pp.Account_Status__c + ' @@@@ pp.Client_Status_New__c : ' + pp.Client_Status_New__c +' @@@@@ pp : ' + pp);
                
                if (prevYearPP.Client_Status_New__c != null) {
                    if (pp.Account_Status__c != EXISTING_CLIENT && pp.Client_Status_New__c != null) {
                        pp.Account_Status__c = EXISTING_CLIENT;
                        ppUpdateList.add(pp);
                    }
                    else if (pp.Client_Status_New__c == null) {
                        pp.Account_Status__c = null;
                        ppUpdateList.add(pp);
                    }
                }
                else if (pp.Client_Status_New__c != null) {
                    pp.Account_Status__c = NEW_CLIENT;
                    ppUpdateList.add(pp);
                }
                else {
                    pp.Account_Status__c = null;
                    ppUpdateList.add(pp);
                }
            }
            else if (pp.Account_Status__c != NEW_CLIENT && pp.Client_Status_New__c != null) {
                pp.Account_Status__c = NEW_CLIENT;
                ppUpdateList.add(pp);
            }
            else if (pp.Account_Status__c == NEW_CLIENT || pp.Account_Status__c == EXISTING_CLIENT) {
                if (pp.Client_Status_New__c == null) {
                    pp.Account_Status__c = null;
                    ppUpdateList.add(pp);
                }
            }
            else {
                pp.Account_Status__c = null;
                ppUpdateList.add(pp);
            }
            
            if(FYToPPMap.containsKey(pp.Account__c + '-' + pp.RecordTypeId + '-' + (integer.valueOf(pp.Fiscal_Year__c))))
            	FYToPPMap.put(pp.Account__c + '-' + pp.RecordTypeId + '-' + (integer.valueOf(pp.Fiscal_Year__c)), pp);
        }
        
        return ppUpdateList;
    }
    
    //V_1.5 - Modify By - Mahendra Swarnkar - 2/18/2017 - CR-20170215-10692 -starts from here
    /**
     *  @description        :   Method is used to call when need to Program Package Rollups Account's fields
     *
     *  @args               :   List<Program_Package__c> newProgPacks, Map<Id,Program_Package__c> oldMapProgPack
     *
     *  @return             :   Void
     *
     *  @revision Logs      :   V_1.1 - Created - 07/11/2016 - Subhash Garhwal
     * 							V_1.2 - Modify By - Mahendra Swarnkar - 2/18/2017 - CR-20170215-10692 - 2.a) Updated "accountRollupsRoyal" method to call the "programPackage" method and commented the common code.
     *
     **/
    public static void accountRollupsRoyal(List<Program_Package__c> newProgPacks, Map<Id,Program_Package__c> oldMapProgPack) {
        
        //Check for Not Schedule, Not Batch, Not Future
        if (!system.isFuture() && !system.isScheduled() && !system.isBatch()) { 
            
            //Calculate the current Fiscal year using shift_fical_year class
            Integer currentFY = shift_get_fiscal_year.current();
            
            //List to hold the related Accounts
            List<Account> listAccounts = new List<Account>();
            
            //Map to hold Account Id with Accounts
            Map<Id, Account> mapAccountToBeUpdated = new Map<Id, Account>();
        
            //Loop over new List of Program packages
            for(Program_Package__c pp : newProgPacks != null ? newProgPacks : oldMapProgPack.values()) {
                    
                    //Insert case
                    if(newProgPacks != null && oldMapProgPack == null && pp.Account__c != null)
                        listAccounts.add(new Account(Id = pp.Account__c));
                        
                    //Update Case
                    if(newProgPacks != null 
                       	&& oldMapProgPack != null 
                       	&& 
                       		(
                            	pp.Fiscal_Year__c != oldMapProgPack.get(pp.Id).Fiscal_Year__c 
                               || pp.Client_Status_New__c != oldMapProgPack.get(pp.Id).Client_Status_New__c 
                               || pp.Account_Status__c != oldMapProgPack.get(pp.Id).Account_Status__c
                               || pp.Account__c != oldMapProgPack.get(pp.Id).Account__c
                               || pp.RecordTypeId != oldMapProgPack.get(pp.Id).RecordTypeId
                            )
                      )
                    {  
                        //Check for Account
                        if(pp.Account__c != null)
                            listAccounts.add(new Account(Id = pp.Account__c));
                        
                        //Check for Old Account
                        if(oldMapProgPack.get(pp.Id).Account__c != null)
                            listAccounts.add(new Account(Id = oldMapProgPack.get(pp.Id).Account__c));
                    }
                    
                    //Delete Case
                    if(newProgPacks == null && pp.Account__c != null)
                        listAccounts.add(new Account(Id = pp.Account__c));
            }
            
            //Check for account size and Ids
            if(listAccounts.size() > 0)
            {	
            	//2.a) Updated "accountRollupsRoyal" method to call the "programPackage" method and commented the common code.
                //Method calling for program package
				mapAccountToBeUpdated = programPackage(listAccounts,currentFY);
                
                //Update Accounts
                if(mapAccountToBeUpdated.values() != null 
                   	&& mapAccountToBeUpdated.values().size() > 0)
                    update mapAccountToBeUpdated.values();
            }
        }
     }
    
   /**
	 * @description		:	Method is using to popuplate Royall and HD Program package specific Account fields
     * 							1.a) check the record type of Program_Package__c and accordingly populate the Royall and HD specific fields on Institution (Account).
     *							1.b) This common method will be used by "Shift_StatusRollup_Handler" class and "Batch_RoyallShiftAccountStatus" batch class
	 *
	 * @args			:	List<Account> scope, Integer currentFY
	 *
	 * @return			:	Map<Id,Account> mapOfAccountsTobeUpdated,
	 * 
	 * @revision Logs	:   V1.1 - Created By - Mahendra Swarnkar - 2/18/2017 - CR-20170215-10692
	 *  
	 **/
	public static Map<Id,Account> programPackage(List<Account> listAccounts, Integer currentFY) {
		
        //Map Of Account to be update 
		Map<Id,Account> mapOfAccountsTobeUpdated = new Map<Id, Account>();
        
        //Check for size
        if(listAccounts != null && listAccounts.size() > 0 ) 
        {
            //Loop over list of Account
            for(Account acc : listAccounts) 
            {  
                //Populated map of Accounts to be updated
                mapOfAccountsTobeUpdated.put(acc.Id, new Account(Id = acc.Id,r_Current_Year_Status__c = null, r_Previous_Year_Status__c = null, 
                                                                    r_Next_Year_Status__c = null, r_Current_Year_Account_Status__c = null,
                                                                    r_Previous_Year_Account_Status__c = null, r_Next_Year_Account_Status__c = null,
                                                                    r_HD_Previous_Year_Engagement_Status__c = null, r_HD_Current_Year_Engagement_Status__c = null,
                                                                    r_HD_Next_Year_Engagement_Status__c = null, r_HD_Previous_Year_Account_Status__c = null,
                                                                    r_hd_current_year_account_status__c = null, r_HD_Next_Year_Account_Status__c = null));
            }
            
            //loop over the Program Packages related to Account Ids in the "listAccounts" list
            for(Program_Package__c p : [SELECT Id, Name, Account__c, Fiscal_Year__c, Client_Status_New__c, Account_Status__c, Recordtype.DeveloperName 
                                            FROM Program_Package__c 
                                            WHERE Account__c != null AND Account__c in: listAccounts
                                            ORDER BY Account__c asc, Fiscal_Year__c asc]
               ) 
            {
                //Check if map conatins Account Id realted to progaram packages
                if(mapOfAccountsTobeUpdated.containsKey(p.Account__c)
                   && mapOfAccountsTobeUpdated.get(p.Account__c) != null) {
                       
					//Get the status for Previous, Current and Next Fiscal Year
                    if (p.Fiscal_Year__c != null)
                    {  
                    	//Check for Royall Record type then populate the Royall specific institution fields
                        if(p.Recordtype.DeveloperName == Label.PROGRAM_PACKAGE_RECORD_TYPE_DEVELOPER_NAME_ROYALL)
                        {    
                        	//Check if Fiscal year equals to Current Fiscal year    
                            if (integer.valueOf(p.Fiscal_Year__c) == currentFY)
                            {
                                //Populated Account'S field Current Year Status and Current Year Account Status by PP fields
                                mapOfAccountsTobeUpdated.get(p.Account__c).r_Current_Year_Status__c = p.Client_Status_New__c;
                                mapOfAccountsTobeUpdated.get(p.Account__c).r_Current_Year_Account_Status__c = p.Account_Status__c;
							}
                               
                            //Check if fiscal year is less 1 year from current fiscal year
                            if (integer.valueOf(p.Fiscal_Year__c) == currentFY+1) 
                            {
                                //Populated Account'S field Next Year Status and NExt Year Account Status by PP fields
                                mapOfAccountsTobeUpdated.get(p.Account__c).r_Next_Year_Status__c = p.Client_Status_New__c;
                                mapOfAccountsTobeUpdated.get(p.Account__c).r_Next_Year_Account_Status__c = p.Account_Status__c;
                            }
                            
                            //Check if fiscal year is greater than 1 year from current fiscal year
                            if (integer.valueOf(p.Fiscal_Year__c) == currentFY-1) 
                            {
                                //Populated Account'S field Prevous Year Status and previous Year Account Status by PP fields
                                mapOfAccountsTobeUpdated.get(p.Account__c).r_Previous_Year_Status__c = p.Client_Status_New__c;
                                mapOfAccountsTobeUpdated.get(p.Account__c).r_Previous_Year_Account_Status__c = p.Account_Status__c;
                            }
						}
						//Check for HD Record type then populate the HD specific institution fields
						else if(p.Recordtype.DeveloperName == Label.PROGRAM_PACKAGE_RECORD_TYPE_DEVELOPER_NAME_HD) 
						{
                            //Check if Fiscal year equals to Current Fiscal year    
                            if (integer.valueOf(p.Fiscal_Year__c) == currentFY) 
                            {
                                //Populated Account'S field Current Year Status and Current Year Account Status by PP fields
                                mapOfAccountsTobeUpdated.get(p.Account__c).r_HD_Current_Year_Engagement_Status__c = p.Client_Status_New__c;
                                mapOfAccountsTobeUpdated.get(p.Account__c).r_hd_current_year_account_status__c = p.Account_Status__c;
                            }
                            
                            //Check if fiscal year is less 1 year from current fiscal year
                            if (integer.valueOf(p.Fiscal_Year__c) == currentFY+1) 
                            {
                                //Populated Account'S field Next Year Status and NExt Year Account Status by PP fields
                                mapOfAccountsTobeUpdated.get(p.Account__c).r_HD_Next_Year_Engagement_Status__c = p.Client_Status_New__c;
                                mapOfAccountsTobeUpdated.get(p.Account__c).r_HD_Next_Year_Account_Status__c = p.Account_Status__c; 
                            }
                            
                            //Check if fiscal year is greater than 1 year from current fiscal year
                            if (integer.valueOf(p.Fiscal_Year__c) == currentFY-1) 
                            {
                                //Populated Account'S field Prevous Year Status and previous Year Account Status by PP fields
                                mapOfAccountsTobeUpdated.get(p.Account__c).r_HD_Previous_Year_Engagement_Status__c = p.Client_Status_New__c;
                                mapOfAccountsTobeUpdated.get(p.Account__c).r_HD_Previous_Year_Account_Status__c = p.Account_Status__c;
                            }
                        }
					}
				}
            }
        }
		
        //return the map of accounts    
        return mapOfAccountsTobeUpdated;    
	}
    //V_1.5 - Modify By - Mahendra Swarnkar - 2/18/2017 - CR-20170215-10692 - Ends Here
}