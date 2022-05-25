/**
 *  @description	:	Sets the Program Package on Subscription Periods by either tagging existing Program Packages, or creating new
 * 
 *  @version		:	V1.1 - 12/06/2018 - Created - Victor Hanson - CR-20181019-12685
 * 			:	V1.2 - 12/27/2018 - Modified By - Subhash Garhawal - CR-20181019-12685
 *				V1.3 - 01/10/2019 - Modified By - Subhash Garhawal - CR-20181019-12685
 *				V1.4 - 01/23/2019 - Modified By - Subhash Garhawal - CR-20181019-12685
 *				V1.5 - 04/22/2021 - Modified By - Mahendra Swarnkar - CR-20210422-15100
 *				V1.6 - 07/30/2021 - Modified By - Subhash Garhawal - CR-20210726-15311 - Added a new Method getFiscalYear
 *
**/
global class Sched_ProgramPackageCreation implements Schedulable {
    
    //private variables
    public List<Subscription_Period__c> sPeriods { get; set; }
    private Map<Id, SBQQ__Subscription__c> mapProgramSubs { get; set; }
    private Set<Id> accountIds { get; set; }
    private Map<Id, Account> mapAccounts { get; set; }
    public static final Set<String> setunEligibleProductCodes = new Set<String>{'ESEMF', 'ESDISC', 'ESADLDISC'};
    
    //Added By Subhash - CR-20210211-14910 - 02/15/2021 - to resolve the 101 issue
    public static boolean IsFromSched_ProgramPackageCreation = false;
    
    public Sched_ProgramPackageCreation(List<Subscription_Period__c> sPeriods) {
        this.sPeriods = sPeriods;
    }
    
    global void execute(SchedulableContext ctx) {
        setProgramPackageOnSP();
    }
    
    /**
     *  @description    :   schedules the job that creates program packages for subscription periods
     * 
     *  @version        :   V1.1 - 12/06/2018 - Created - Victor Hanson - CR-20181019-12685
     *
    **/
    public static void scheduleProgramPackageCreation(List<Subscription_Period__c> sPeriods) {
        dateTime sysTime = dateTime.now().addSeconds(50);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        Sched_ProgramPackageCreation job = new Sched_ProgramPackageCreation(sPeriods);
        System.schedule('Sched_ProgramPackageCreation' + sysTime.getTime(),chron_exp, job);
    }
    
    /**
     *  @description    :   Sets Program Package on Subscription Periods
     * 
     *  @version    	:   V1.1 - 12/06/2018 - Created - Victor Hanson - CR-20181019-12685
     *
    **/
    public void setProgramPackageOnSP() {
    	
    	try {
    	
	        List<Program_Package__c> pPackagesToInsert = new List<Program_Package__c>();
	         
		//Modified By - Subhash Garhawal - CR-20210726-15311          
            	//SOQL over the Subscription Periods
            	List<Subscription_Period__c> subPeriods = [Select Id, Name, Institution__c, Period_End_Date__c, Program_Subscription__c, Membership_Lookup__c, Program_Package__c, Program_Subscription__r.SBQQ__Product__c, 
                					   Program_Subscription__r.SBQQ__Product__r.ProductCode, Program_Subscription__r.SBQQ__RequiredByProduct__c, Program_Subscription__r.SBQQ__RequiredByProduct__r.Family,
                                                           Program_Subscription__r.SBQQ__Product__r.Family, Program_Subscription__r.Product_Code__c 
                                                       	   From Subscription_Period__c
	        										   Where Id IN : sPeriods AND Membership_Lookup__c != null AND Program_Subscription__r.SBQQ__Product__r.ProductCode NOT IN :setunEligibleProductCodes];
		    
		    //Check subscription Periods
		    if(subPeriods.size() > 0) {
		    	    												  
				//3/4/2019 - Subhash Garhwal - Added new code to populate membership details on the Component Subscription
				//Map to hold the Component CPQ Subscriptions with Relate Parent Sub Period
				Map<Id, List<SBQQ__Subscription__c>> mapCompSubscriptionWithSubPeriod = new Map<Id, List<SBQQ__Subscription__c>>();
				
				//SOQL over the Component Subscriptions
				for(SBQQ__Subscription__c cS : [Select Id, Subscription_Period__c, Membership_Period__c From SBQQ__Subscription__c Where Subscription_Period__c != null AND Subscription_Period__c IN : sPeriods]) {
					
					//Check Parent Subscription Period
					if(!mapCompSubscriptionWithSubPeriod.containsKey(cS.Subscription_Period__c))
						mapCompSubscriptionWithSubPeriod.put(cS.Subscription_Period__c, new List<SBQQ__Subscription__c>());
					
					//Add component subscription in list
					mapCompSubscriptionWithSubPeriod.get(cS.Subscription_Period__c).add(cS);	
				}
				
			//Modified By - Subhash Garhawal - CR-20210726-15311
		        //get Subscription Periods, accts, program subs
		        accountIds = new Set<Id>();
		        Set<String> fiscalYears = new Set<String>();
		        Set<Id> programSubIds = new Set<Id>();
		        for (Subscription_Period__c sp : subPeriods) {
		            if (sp.Institution__c != null) accountIds.add(sp.Institution__c);
                    	    if (sp.Period_End_Date__c != null) fiscalYears.add( getFiscalYear(sp) );
		            if (sp.Program_Subscription__c != null) programSubIds.add(sp.Program_Subscription__c);
		        }
		        
		        //Updated by Subhash garhwal on 01/23/2019 - CR-20181019-12685 - Added Source_Opportunity__c, Source_Opportunity__r.Contract_Signature_Date__c, Source_Opportunity__r.SBQQ__PrimaryQuote__c, Source_Opportunity__r.SBQQ__PrimaryQuote__r.LOA_Signature_Date__c, Source_Opportunity__r.SBQQ__PrimaryQuote__r.Sync_Calculator_Update_Date__c in the Query
		        //get the map of program subscriptions
		        mapProgramSubs = new Map<Id, SBQQ__Subscription__c>([SELECT Id, Membership__c, Source_Opportunity__c, Source_Opportunity__r.Contract_Signature_Date__c,
		        													 Source_Opportunity__r.SBQQ__PrimaryQuote__c, Source_Opportunity__r.SBQQ__PrimaryQuote__r.LOA_Signature_Date__c,
		        													 Source_Opportunity__r.SBQQ__PrimaryQuote__r.Sync_Calculator_Update_Date__c FROM SBQQ__Subscription__c
		        													 WHERE Id IN :programSubIds AND Membership__c != null]);
		        
		        //get the map of accounts
		        mapAccounts = new Map<Id, Account>([SELECT Id, Account_Formal_Name__c FROM Account WHERE Id IN :accountIds]);
		        
		        
		        //get Program Packages each account & fiscal years
		        Map<String, Program_Package__c> pPackageMap = getProgramPackageMap(accountIds, fiscalYears);
		        		        
		        //loop through each subscription period to ensure that each Account/Year combo has a corresponding program package
		        for (Subscription_Period__c sp : subPeriods) {
                    
                    	    if(sp.Program_Subscription__c != null && sp.Program_Subscription__r.SBQQ__Product__c != null 
                       	    && String.IsNotBlank(sp.Program_Subscription__r.SBQQ__Product__r.ProductCode)
                       	    && setunEligibleProductCodes.contains(sp.Program_Subscription__r.SBQQ__Product__r.ProductCode))
                    	    	continue;    
			    
			    //Modified By - Subhash Garhawal - CR-20210726-15311		
                    	    String fiscalYear = getFiscalYear(sp);
			    String uk = getProgPackageKey(sp.Membership_Lookup__c, fiscalYear);
					
			    Program_Package__c pPackage = pPackageMap.get(uk);
		            
		            //Subhash Garhwal - 01/10/2019 - CR-20181019-12685 - Removed sp.Stage__c != 'Pending' check to create Program Packages for future (Pending) SPs.
		            //if program package not found, create one
		            if (pPackage == null) {
		                pPackage = getNewProgramPackage(sp, fiscalYear);
		                pPackagesToInsert.add(pPackage);
		            }
		            
		            //add program package to the map
		            if (pPackage != null) {
		                pPackageMap.put(uk, pPackage);
		            }
		        }
		        
		        //insert any program packages that don't already exist
		        if (pPackagesToInsert.size() > 0) {
		        	
		            //Util.byPassAllTriggers = false;
		            insert pPackagesToInsert;
		        }
		        
		        //V1.2 - 12/27/2018 - Added By - Subhash Garhawal - CR-20181019-12685
		        //List to hold the eligible Program package for engagement status update
		        List<Program_Package__c> eligibleProgramPackage = new List<Program_Package__c>();
		        
		        //List to hold the component subscriptions for update
		        List<SBQQ__Subscription__c> compSubscriptionsToUpdate = new List<SBQQ__Subscription__c>();
		        
                	//Added By Mahendra Swarnkar - CR-20210422-15100 -  04/22/2021
                	//Set to hold the Membership Ids 
                	Set<Id> setMembershipIds = new set<Id>();
			
                	//assign the Subscription Period to the Program Packages
		        for (Subscription_Period__c sp : subPeriods) {
		            //Modified By - Subhash Garhawal - CR-20210726-15311
                    	    String fiscalYear = getFiscalYear(sp);
		            String uk = getProgPackageKey(sp.Membership_Lookup__c, fiscalYear);
		            
		            Program_Package__c pPackage = pPackageMap.get(uk);
		            if (pPackage != null) {
		                
		                //Update Membership Period details on the Subscription Period
		                sp.Program_Package__c = pPackage.Id;
		                
		                //Update membership details on the Component Subscriptions
		                //Check Subscription Period Id in map
		                if(mapCompSubscriptionWithSubPeriod.containsKey(sP.Id)) {
		                	
		                	//Loop over the component subscriptions
		                	for(SBQQ__Subscription__c cS : mapCompSubscriptionWithSubPeriod.get(sP.Id)) {
		                		
		                		//Update Membership Period
		                		cS.Membership_Period__c = pPackage.Id;
		                		
		                		//Add record in list
		                		compSubscriptionsToUpdate.add(cS);
		                	}
		                }
		                
		                
		                //V1.2 - 12/27/2018 - Added By - Subhash Garhawal - CR-20181019-12685
		                //Populate the list eligible Program Package
		                eligibleProgramPackage.add(pPackage);
                        
                                //Added By Mahendra Swarnkar - CR-20210422-15100 -  04/22/2021
                                setMembershipIds.add(pPackage.Membership__c);
		            }
		        }
				
		        //update subscription periods with program package
		        if (subPeriods.size() > 0) {
                    	    //Added By Subhash - CR-20210211-14910 - 02/15/2021 - to resolve the 101 issue
		            IsFromSched_ProgramPackageCreation = true;
		            //Update Subscription Periods
		            update subPeriods;
		            
                    	    Util.byPassAllTriggers = false;
                            //V1.2 - 12/27/2018 - Added By - Subhash Garhawal - CR-20181019-12685 - Starts from here
		            //Check for size
		            if(eligibleProgramPackage.size() > 0){
		            	
                        	Shift_StatusRollup_Handler.IsFromSched_SubscriptionPeriodCreation = true;
                        
		            	//Method call to update the engagement status on Program Package
			        SubscriptionPeriodTriggerHelper.populateEngagementStatus(eligibleProgramPackage, true);	
		            }
		            //V1.2 - 12/27/2018 - Added By - Subhash Garhawal - CR-20181019-12685 - Ends here
		            
                    
		            //Update Component Subscriptions
		            if(compSubscriptionsToUpdate.size() > 0)
		            	update compSubscriptionsToUpdate;
                    
                    	    //Added By Mahendra Swarnkar - CR-20210422-15100 - 04/22/2021
                    	    if(setMembershipIds.size() > 0)
                    	    	ProgramPackageRoyallTriggerHelper.updateProgPackageOnMembership(setMembershipIds);
                    
                    	    //Added By Subhash - CR-20210211-14910 - 02/15/2021 - to resolve the 101 issue
                    	    IsFromSched_ProgramPackageCreation = false;
		        }
	    	}
    	} catch(Exception e){
            System.debug('###########e : ' +e);
            System.debug('###########getmessage : ' +e.getmessage());
            System.debug('###########Line Number : ' +e.getLineNumber());
                
	    //Check for UNABLE_TO_LOCK_ROW error
            if(e.getmessage().contains('UNABLE_TO_LOCK_ROW')) {
                	
			DateTime sysTime = DateTime.now().addSeconds(10);
		        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
		        Sched_ProgramPackageCreation job = new Sched_ProgramPackageCreation(sPeriods);
		        System.schedule('Sched_ProgramPackageCreation' + sysTime.getTime(),chron_exp, job);
	    }
        }
    }
    
    /**
     *  @description	:	
     * 
     *  @version		:	V1.1 - 12/06/2018 - Created - Victor Hanson - CR-20181019-12685
     *
    **/
    public Map<String, Program_Package__c> getProgramPackageMap(Set<Id> accountIds, Set<String> fiscalYears) {
        Map<String, Program_Package__c> programPackageMap = new Map<String, Program_Package__c>();
        
        //get all Program Packages in this Fiscal Year related to one of the child institutions
        for(Program_Package__c pPackage : [SELECT Id, Account__c, RecordType.Name, Account__r.RecordType.Name,
                                           Fiscal_Year__c, Membership__c, Membership__r.Program__r.Program_Acronym__c
                                           FROM Program_Package__c WHERE Account__c IN :accountIds
                                           AND Fiscal_Year__c IN :fiscalYears AND Membership__c != null
                                           AND RecordTypeId =: CPQConstants.PROGRAM_PACKAGE_RT_ID_EAB
                                           AND (Client_Status_New__c = 'Secured'
                                                OR (Account_Status__c = 'Existing Client' AND Client_Status_New__c != 'Lost'))])
        {
            String uk = getProgPackageKey(pPackage.Membership__c, pPackage.Fiscal_Year__c);
            programPackageMap.put(uk, pPackage);
        }
        //return the map of Unique Key to Program Package
        return programPackageMap;
    }
    
    /**
     *  @description	:	 
     * 
     *  @version        :   V1.1 - 12/06/2018 - Created - Victor Hanson - CR-20181019-12685
     *
    **/
    public Program_Package__c getNewProgramPackage(Subscription_Period__c sPeriod, String fiscalYear) {
        
        Program_Package__c newProgPackage = new Program_Package__c(
            
            //V1.2 - 12/27/2018 - Added By - Subhash Garhawal - CR-20181019-12685 - Starts from here
            RecordTypeId = CPQConstants.PROGRAM_PACKAGE_RT_ID_EAB,
            //V1.2 - 12/27/2018 - Added By - Subhash Garhawal - CR-20181019-12685 - Ends here
            
            Account__c = sPeriod.Institution__c,
            Name = 'Will auto-populate',
            Fiscal_Year__c = fiscalYear,
            
            //V1.2 - 12/27/2018 - Added By - Subhash Garhawal - CR-20181019-12685
            OwnerId = Label.IS_SF_AUTOMATION_EAB_USER_ID
        );
        
        if (mapProgramSubs.size() > 0 && mapProgramSubs.containsKey(sPeriod.Program_Subscription__c) && mapProgramSubs.get(sPeriod.Program_Subscription__c) != null) {
            
            //Populate the Membership
            newProgPackage.Membership__c = mapProgramSubs.get(sPeriod.Program_Subscription__c).Membership__c;
            
            //Added By Subhash garhwal on 01/23/2019 - CR-20181019-12685 - Starts from here
            if(mapProgramSubs.get(sPeriod.Program_Subscription__c).Source_Opportunity__c != null ){
                
                //Populate the contract signature date
                if(mapProgramSubs.get(sPeriod.Program_Subscription__c).Source_Opportunity__r.Contract_Signature_Date__c != null)
                    newProgPackage.Contract_Signature_Date__c = mapProgramSubs.get(sPeriod.Program_Subscription__c).Source_Opportunity__r.Contract_Signature_Date__c;
                
                if(mapProgramSubs.get(sPeriod.Program_Subscription__c).Source_Opportunity__r.SBQQ__PrimaryQuote__c != null) {
                    
                    //Populate the contract sent date
                    if( mapProgramSubs.get(sPeriod.Program_Subscription__c).Source_Opportunity__r.SBQQ__PrimaryQuote__r.LOA_Signature_Date__c != null)
                        newProgPackage.Contract_Sent__c = mapProgramSubs.get(sPeriod.Program_Subscription__c).Source_Opportunity__r.SBQQ__PrimaryQuote__r.LOA_Signature_Date__c;
                
                    //Populate the Proposal sent date
                    if(mapProgramSubs.get(sPeriod.Program_Subscription__c).Source_Opportunity__r.SBQQ__PrimaryQuote__r.Sync_Calculator_Update_Date__c != null)
                        newProgPackage.Proposal_Sent__c = mapProgramSubs.get(sPeriod.Program_Subscription__c).Source_Opportunity__r.SBQQ__PrimaryQuote__r.Sync_Calculator_Update_Date__c;
                }
            }
            //Added By Subhash garhwal on 01/23/2019 - CR-20181019-12685 - Ends here
        }
        
        if (mapAccounts.containsKey(sPeriod.Institution__c)) {
            Integer maxNameLength = 80;
            String name = 'FY ';
            Account a = mapAccounts.get(sPeriod.Institution__c);
            if (fiscalYear != null && fiscalYear.length() == 4) {
                name += fiscalYear.substring(2, 4);
                name += ' ' + a.Account_Formal_Name__c;
            }
            //check for max name length
            if (name.length() > maxNameLength) name=name.substring(0, maxNameLength);
            newProgPackage.name = name;
        }
        
        return newProgPackage;
    }
    
    /**
     *  @description    :   returns unique key for program package
     * 
     *  @version        :   V1.1 - 12/06/2018 - Created - Victor Hanson - CR-20181019-12685
     *
    **/
    public static String getProgPackageKey(Id membershipId, String fiscalYear) {
        return membershipId + '-' + fiscalYear;
    }
    
    /**
     *  @description    :   
     * 
     *  @version        :   V1.1 - 12/06/2018 - Created - Victor Hanson - CR-20181019-12685
     *                      V1.2 - Modified by Subhash - on 05/02/2019 - as per the spering clean up general issue sheet.
     *
    **/
    public static String getFiscalYear(Date d) {
        if (d == null) return null;
        /*
        String fiscalyear = '';
        
        if(d.month() <7)
            fiscalyear = String.valueOf(d.year()-1);
        else
            fiscalyear = String.valueOf(d.year());
        
        return fiscalyear;
        */
        return String.valueOf( d.year() );
    }
    
    /**
     *  @description    :   
     * 
     *  @version        :   V1.1 - Modified By - Subhash Garhawal - 07/30/2021 - CR-20210726-15311
     *                      V1.2 - Modified by Subhash - on 05/02/2019 - as per the spering clean up general issue sheet.
     *
    **/
    
    /**
     * 
     *   @description    :  This method used to get the fiscal Year 
     *                      Logic:
     *                            1. For Non ES Product: End Date's Year
     *                            2. For ES Product:
     *                               2.1. If Product is FAO one:
     *                                    Financial Aid Optimization (ESFAO), Financial Aid Descriptive Analysis (ESFAD),
     *                                    Full Budget Model (ESFBM), Four-Year Net Tuition Revenue Model (ESFYT), Inquiry Scoring (ESIQS),
     *                                    Retention Analysis (ESRTA), Transfer Financial Aid Optimization (ESTFAO)
     *                                    : The following ending between 8/1/21 and 7/31/22 goes to FY22
     *                               2.2  If Product is Non FAO one:
     *                                    The following ending between 7/1/21 to 6/30/22 goes to FY22
     *                                                                  
     *   @args           :   Subscription_Period__c
     *
     *   @return         :  String
     *
     *   @revision Log   :  V1.1 - Created - 07/30/2021 - Subhash Garhawal - CR-20210726-15311
     * 
     **/
    public static String getFiscalYear(Subscription_Period__c subPeriod) {
        
        //Check for End Date
        if(subPeriod.Period_End_Date__c == null)
            return null;
                    
            //Check for FAO Products
            if(String.isNotBlank(subPeriod.Program_Subscription__r.Product_Code__c) && CPQConstants.SET_ES_FAO_PRODUCT_CODES.contains(subPeriod.Program_Subscription__r.Product_Code__c)) {
                
                //Check for End Date Month
                if(subPeriod.Period_End_Date__c.Month() < 8)
                    return String.valueOf(subPeriod.Period_End_Date__c.year());
                else
                    return String.valueOf(subPeriod.Period_End_Date__c.year() + 1);
            
            } else {
                
                //Check for End Date Month
                if(subPeriod.Period_End_Date__c.Month() < 7)
                    return String.valueOf(subPeriod.Period_End_Date__c.year());
                else
                    return String.valueOf(subPeriod.Period_End_Date__c.year() + 1);
            } 

    }
}