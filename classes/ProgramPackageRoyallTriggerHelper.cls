/*
*  Purpose         :   Helper class of Trigger_Program_Package_Royall, manually merged code from Royall Enviournment to Corporate Instance.
*                       - Moved code from shift_mass_update_programs trigger to this class
*
*  Create By       :   Rajeev Jain
*
*  Created Date    :   06/24/2016
*
*  Revision Log    :    V_1.0 Created
*                       V_1.1 Modified - Victor Hanson - Added updateMembershipStatus_Royall method
*			V_1.2 Modified - Saurabh Kumar - CR-20170807-11129 - Modified - Added updateMembershipStatus_Royall method
*			V_1.3 Modified - Dipesh Gupta - CR-20170221-10712 - Added a new Method updateRoyallProgramJobNo.
*                       V_1.4 Modified - Abhinav Sharma - CR-20180917-12597 - Modified Method updateRoyallProgramJobNo.
*                       V_1.5 Modified - Abhainav Sharma - CR-20180809-12494 - Created a new Method "updateProgramPackageOnMembership".
*                       V_1.6 Modified - Abhinav Sharma - CR-20180809-12493 Commneted all the references for Royall - Admissions - Undergraduate and Royall - Advancement Record type updateMembershipStatus_Royall.
*                       V_1.7 Merged   - Rajeev Jain - Release - BOSS Project: Account Merge.	10/24/2018					
*                       V_1.8 Modified - Subhash Garhwal - CR-20181113-12746 - 11/27/2018 - Commented out the methods - updateMembershipStatus_Royall
*                       V_1.9 Merged   - Rajeev jain - 12/07/2018
*                       V_2.0 Modified - Subhash Garhwal - CR-20181019-12685 - 12/27/2018 - Added new Methods "populateRollUpFieldsOnProgramPackage" and "populateRollUpFields".
*                       V_2.1 Added    - Dipesh Gupta - CR-20200522-14088 - replace the references of Campaign New Code field with Campaign code  updateRoyallProgramJobNo
*                       V_2.2 Modified - Subhash Garhwal - 09/23/2020 - CR-20200914-14504 - Modified massUpdatePrograms method
*                       V_2.3 Modified - Victor Hanson - 10/27/2020 - CR-20201013-14598 - Modified syncRenewalDetailsOnProgramPackage to check for Program Costs OR Cappex Service Costs
*			V_2.4 Modified - Mahendra Swarnkar - 01/08/2021 - CR-20201204-14725 - Update logic behind CX Current Contract Value
*			V_2.5 Modified - Mahendra Swarnkar - CR-20210422-15100 -  04/22/2021
**/
public without sharing class ProgramPackageRoyallTriggerHelper {
    
    /**Commented by - Subhash - CR-20181113-12746 - 11/27/2018 -- Starts from here*/ 
    /**
    *  @description    :   Populate fields on membership from the respective child institution's Program Packages.
    *
    *  @args           :   List of Program Packages
    *
    *  @return         :   void
    *
    **/
   /* public static void updateMembershipStatus_Royall(list<Program_Package__c> oldProgramPackages, list<Program_Package__c> newProgramPackages) {
        
        list<Program_Package__c> programPackages = (newProgramPackages != null) ? newProgramPackages : oldProgramPackages;
        
        //get all parent institution ids
        set<Id> acctIds = new set<Id>();
        set<Id> parentAcctIds = new set<Id>();
        for (Program_Package__c pp : programPackages) acctIds.add(pp.Account__c);
        for(Account a : [SELECT Id, ParentId FROM Account WHERE Id IN :acctIds]) parentAcctIds.add(a.ParentId);
        
        //get all royall memberships
        list<Membership__c> memberships = [SELECT Id, Program_Acronym__c, Program__c, Membership_Status_Text__c, Active_Program_Package__c, Account_Name__c
                                           FROM Membership__c 
                                           WHERE Account_Name__c IN :parentAcctIds AND Account_Name__c != null
                                           AND Program__r.Business_Line__c = :Label.Royall_Business_Line];
        system.debug('@@@zzzmemberships:' + memberships);
        //update the royall memberships -- this will trigger an update to the Membership Status & Active Program Package if needed
        updateMembershipStatus_Royall(memberships, true);
    }
    */
    
    //Modified by Abhinav Sharma - CR-20180809-12493 Commneted all the references for Royall - Admissions - Undergraduate and Royall - Advancement Record type updateMembershipStatus_Royall.
    //V_1.2 Modified - Saurabh Kumar - CR-20170807-11129 - Modified - Added updateMembershipStatus_Royall method
     /**
     *  @description    :   Method to populate fields on membership from the respective child institution Program Packages.
     *
     *  @args           :   List of new Membership
     *
     *  @return         :   void
     *
    **/
    /*public static void updateMembershipStatus_Royall(list<Membership__c> memberships, boolean updateMemberships) {
        
        //Fiscal year start date is 7/1, so get the fiscal year based on today's date
        string currentFiscalYear = string.valueOf(shift_get_fiscal_year.current());
        
        //get all royall programs
        map<string, Program__c> mapRoyallPrograms = new map<string, Program__c>([SELECT Id, Program_Acronym__c 
                                                                                 FROM Program__c WHERE Business_Line__c = :Label.Royall_Business_Line]);
        
        //map of all institutions with list of memberships memberships where Business Line = "RY".
        set<Id> parentAcctIds = new set<Id>();
        map<string, Membership__c> keyToMembership = new map<string, Membership__c>();
        
        for (Membership__c mem : memberships) {
            
            //if it's a Royall or HD program
            if (mapRoyallPrograms.containsKey(mem.Program__c)) {
                
                //default as Prospect - Pure
                mem.Membership_Status_Text__c = Constants.PROSPECT_PURE;
                mem.Active_Program_Package__c = null;
                
                //create a map of <parentAcctId-programAcronym, Membership>
                keyToMembership.put(mem.Account_Name__c + '-' + mapRoyallPrograms.get(mem.Program__c).Program_Acronym__c, mem);
                parentAcctIds.add(mem.Account_Name__c);
            }
        }
        
        //do not continue if there are no parent accounts that have royall memberships
        if (keyToMembership.size() > 0) {
            
            //get all Program Packages in this Fiscal Year related to one of the child institutions
            list<Program_Package__c> pPackages = [SELECT Id, Account__r.ParentId, RecordType.Name, Account__r.RecordType.Name
                                                  FROM Program_Package__c WHERE Account__r.ParentId IN :parentAcctIds
                                                  AND Fiscal_Year__c = :currentFiscalYear
                                                  AND (Client_Status_New__c = 'Secured'
                                                       OR (Account_Status__c = 'Existing Client' AND Client_Status_New__c != 'Lost'))];
            
            //if there are no corresponding program packages that fit the criteria, return
            if (pPackages.size() == 0) return;
           
            //Modified by Abhinav Sharma - CR-20180809-12493 Commneted all the references for Royall - Admissions - Undergraduate and Royall - Advancement Record type.
            //for each programPackage, see if we need to update the membership status text
            for (Program_Package__c pp : pPackages) {
                string progAcronym;
                if (pp.RecordType.Name == 'Hardwick Day')
                    progAcronym = 'RYFA';
                //else if (pp.Account__r.RecordType.Name == 'Royall - Admissions - Undergraduate')
                //   progAcronym = 'RYAU';
                else if (pp.Account__r.RecordType.Name == 'Graduate Education')
                    progAcronym = 'RYAG';
                //else if (pp.Account__r.RecordType.Name == 'Royall - Advancement')
                //  progAcronym = 'RYAF';
               
                Membership__c mem = keyToMembership.get(pp.Account__r.ParentId + '-' + progAcronym);
                
                //Modified By Subhash Garhwal - CR-20181113-12746 - 11/21/2018.
                //checking for the Graduate Education - 
                //After account Merge Release, we have merged the RYAF with the RYFA for Graduate education Rtype
				//So, for the Graduate Education if there is no Membership from the above Line then check if we can get the membership from the RYAF Program Acronym
				
                //if(pp.Account__r.RecordType.Name == 'Graduate Education' && mem == null) 
                //    mem = keyToMembership.get(pp.Account__r.ParentId + '-' + 'RYAF');
                
                if (mem != null) {
                    mem.Active_Program_Package__c = pp.Id;
                    mem.Membership_Status_Text__c = constants.MEMBER_PAYER;
                }
            }
        }
        
        if (updateMemberships) {
            util.BypassAllTriggers = true;
            update memberships;
            
            //V_1.2 Modified - Saurabh Kumar - CR-20170807-11129 - Modified - Added  method
            Util.BypassAllTriggers = false;
        }
    }
    */
    /**Commented by - Subhash - CR-20181113-12746 - 11/27/2018 -- Ends here*/
        
    /**
    *  @description    :   	Merged code from shift_mass_update_programs trigger from Royall Enviournment
    *
    *  @args           :   	List of old Account records
    *
    *  @return         :   	void
    *
    *  @Revision Log   	:	V1.1 - Modified By - Subhash Garhwal - 09/23/2020 - CR-20200914-14504 - Removed the Lock the record validation	
    **/
    public static void massUpdatePrograms(List<Program_Package__c> newProgramPackage, map<Id, Program_Package__c> oldProgramPackage) {
        
        Map <Id,Program_Package__c> theUpdatedProgramsMap= new Map <Id,Program_Package__c > ();
        
        //Loop over each new program Package record
        for(Program_Package__c pckg : newProgramPackage){
            if(pckg.Client_Status_New__c != oldProgramPackage.get(pckg.Id).Client_Status_New__c && pckg.Client_Status_New__c == 'Lost'){
                theUpdatedProgramsMap.put(pckg.Id, pckg);    
            }
        }
        
        if(theUpdatedProgramsMap.size() > 0){
            
            Set<Id> lockedPrgPkgIdSet = new Set<Id> ();
            
            List<Royall_Program__c> theProgramList = [select Id, Status__c, Program_Package__c, Lock_the_Record__c  
                                                      from Royall_Program__c 
                                                      where Program_Package__c in : theUpdatedProgramsMap.KeySet()];
            
            for( Royall_Program__c theProg: theProgramList ){
                theProg.Status__c = 'Declined';
                if(theProg.Lock_the_Record__c == True)
                    lockedPrgPkgIdSet.add(theProg.Program_Package__c);
            }
            System.debug('###########theProgramList : ' +theProgramList.size());
            System.debug('###########theProgramListSize : ' +theProgramList);
            //Update Program List
            List <Database.SaveResult> srList = Database.update(theProgramList,false);
            
            Set <Id> UpdatedProg = new Set<Id> (); 
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    UpdatedProg.add(sr.getId());
                }
            }
            
            Set<Id> failedProg = new Set<Id>();
            
            for( Royall_Program__c prog : theProgramList){
                if(!UpdatedProg.contains(prog.Id))
                    failedProg.add(prog.Program_Package__c);
            }
            
            // Add error to the program Package that were not updated
            if(failedProg.size() > 0){
                for( Program_Package__c theProPkg: theUpdatedProgramsMap.values()){
                    if(failedProg.contains(theProPkg.Id)){
                    	
                    	//09/23/2020 - Subhash Garhwal - CR-20200914-14504 - Removed the Lock the record validation
                        if(lockedPrgPkgIdSet.contains(theProPkg.Id)) continue; //theProPkg.addError(System.Label.Error_Msg_Locked_Prog_Pck_update);
                        else
                        theProPkg.addError(System.Label.Error_Msg_Prog_Pck_update);
                    }
                }
            }
        }
    }
    
    //V_1.3 Modified - Dipesh Gupta - CR-20170221-10712 - Added a new Method updateRoyallProgramJobNo.
    /**
    *  @description    :   This method is used to populate the value on the jobno field. 
    *
    *  @args           :   
    *
    *  @return         :   void
    * 
    * Version          :  V1.1 - updated by Abhinav Sharma - CR-20180917-12597 - 09/27/2018.
    * 		       :  V1.2 - Updated by Dipesh Gupta - 05/26/2020 - CR-20200522-14088
    *
    **/
    public static void updateRoyallProgramJobNo(List<Program_Package__c> newProgramPackage, map<Id, Program_Package__c> oldProgramPackage) {
      
      //Set to hold the id of program package 
      Set<Id> setProgramPackageId = new Set<Id>();
      
      //List to hold the royal program.
       List<Royall_Program__c> royallProgramToBeUpdated = new List<Royall_Program__c>();
       
      //Loop through the new list of program package
      for(Program_Package__c programPackage : newProgramPackage)   {
        
        //Check if the Account is changes than only fill the Set
        if(oldProgramPackage != null && oldProgramPackage.containsKey(programPackage.Id) && oldProgramPackage.get(programPackage.Id) != null 
          && oldProgramPackage.get(programPackage.Id).Account__c != programPackage.Account__c  )  {
            
        //Fill the set with the Program 
        setProgramPackageId.add(programPackage.Id);
        }
      }
      
      //Check the Size of set
      if(setProgramPackageId.size() > 0) {
        
        //Map to hold the Account Id with respact to the school code.
        //Map<Id, String> mapAccountSchoolCode = new Map<Id, String>();
        Map<Id, Program_Package__c> mapAccountSchoolCode = new Map<Id, Program_Package__c>();
        
        //Modified by Rajeev jain - CR-20180917-12597 - 09/27/2018 - Added a new Field in the Query. 
        //Query on the program Package to the Id Info.
        for(Program_Package__c  programPackage : [Select Id, Account__c, Account__r.r_School_Code__c, Account__r.School_Code_Advancement__c, Fiscal_Year__c FROM Program_Package__c where Id IN: setProgramPackageId] ) {
          
          //map to hold the Account id with the school code.
          mapAccountSchoolCode.put(programPackage.Account__c, programPackage);
        }
          
        //Query on the royall programs related to the Program package
         for(Royall_Program__c royallProgram : [Select Id, Name, Program_Package__r.Account__c, Campaign_Code__c, Fiscal_Year__c, 
                                                Target_Audience_New__c, Program_Package__r.Account__r.r_School_Code__c 
           									    From Royall_Program__c where Program_Package__c IN: setProgramPackageId]) {
           
           //string to hold the jobNo    
           String  royallProgramJobNo = '';
               
           if(mapAccountSchoolCode.containsKey(royallProgram.Program_Package__r.Account__c) && 
              mapAccountSchoolCode.get(royallProgram.Program_Package__r.Account__c) != null) {
            	
                  /*Checking for the Targer Audience Value if the Target Audience new  = 'Advancement Accounts' then Job number should be School_Code_Advancement__c
                  if target audience new is anything else than "r_School_Code__c"
				  */
                  //Check for the Target Audience New value
                  if(royallProgram.Target_Audience_New__c == Label.TARGET_AUDIENCE_VALUE)
                  	  royallProgramJobNo = mapAccountSchoolCode.get(royallProgram.Program_Package__r.Account__c).Account__r.School_Code_Advancement__c;
                  else
                      //Assigning the school code of Account to the String [1st 2 letters of job no are of institution's school code]
                      royallProgramJobNo = mapAccountSchoolCode.get(royallProgram.Program_Package__r.Account__c).Account__r.r_School_Code__c;
           }   
           
           if(String.isNotBlank(royallProgram.Fiscal_Year__c))
               royallProgramJobNo += royallProgram.Fiscal_Year__c.right(2);
               
           if(String.isNotBlank(royallProgram.Campaign_Code__c))
               royallProgramJobNo += royallProgram.Campaign_Code__c;
               
           royallProgramToBeUpdated.add(new Royall_Program__c (Id= royallProgram.Id, Name = royallProgramJobNo));
        }
         
         //Bypass All Triggers
            Util.BypassAllTriggers = true;
         
         System.debug('###########royallProgramToBeUpdated : ' +royallProgramToBeUpdated);
         System.debug('###########royallProgramToBeUpdatedSize : ' +royallProgramToBeUpdated.size());
           
         //Check the size of List
         if(royallProgramToBeUpdated.size() > 0)
           update royallProgramToBeUpdated;
           
         //Enable All Triggers
            Util.BypassAllTriggers = false;
            
       }
    }
    
    /**
    *  @description    :   This method is used to populate the Current/Previous/next program Package on the related membership Object. 
    *
    *  @args           :   
    *
    *  @return         :   void
    * 
    * Version          :  V1.1 - Created by Abhinav sharma - 09/28/2018 - CR-20180809-12494
    *
    **/
    public static void updateProgramPackageOnMembership(list<Program_Package__c> newProgramPackage, map<Id, Program_Package__c> oldMapProgramPackage) {
    	
    	//Set to hold the Program Package 
    	Set<Id> setMembershipIds = new set<Id>();
    	
    	//List to hold the membership[ that is going to be Updated in the Data base 
    	List<Membership__c> listMembershipToBeUpdated = new List<Membership__c>();
    	
    	//Checking for the program package
    	if(newProgramPackage != null && newProgramPackage.size() > 0) {
    		
    		//Check for the program package 
    		for(Program_Package__c prgrmPckage : newProgramPackage) {
    		
    			//Checking for the Membership Change on the program packahge or Newly inserted program package.
    			if(oldMapProgramPackage == null 
    			|| 
    			(
    			oldMapProgramPackage != null 
    			&& 
    			(oldMapProgramPackage.get(prgrmPckage.Id).Membership__c != prgrmPckage.Membership__c
    			||
    			oldMapProgramPackage.get(prgrmPckage.Id).Total_Adjusted_Contracted_Cost__c != prgrmPckage.Total_Adjusted_Contracted_Cost__c	
    			||
    			oldMapProgramPackage.get(prgrmPckage.Id).Account_Status__c != prgrmPckage.Account_Status__c
    			||
    			oldMapProgramPackage.get(prgrmPckage.Id).Client_Status_New__c != prgrmPckage.Client_Status_New__c
    			|| 
    			oldMapProgramPackage.get(prgrmPckage.Id).Fiscal_Year__c	!= prgrmPckage.Fiscal_Year__c))) {
    				
    				//Adding Membership on the set
    				setMembershipIds.add(prgrmPckage.Membership__c);		
    				
    				//Checking for the old map Null check to know if this is the Update case and Membership got changes on the program Package. 
    				if(oldMapProgramPackage != null && oldMapProgramPackage.get(prgrmPckage.Id).Membership__c != prgrmPckage.Membership__c)
    					setMembershipIds.add(oldMapProgramPackage.get(prgrmPckage.Id).Membership__c);	
    			}
    		}
    		
    		//Checking for the set of Membership ids
    		if(setMembershipIds != null && setMembershipIds.size() > 0 ) {
    			
                //Added By Mahendra Swarnkar - CR-20210422-15100 -  04/22/2021 
                ProgramPackageRoyallTriggerHelper.updateProgPackageOnMembership(setMembershipIds);
                
                //Commented By Mahendra Swarnkar - CR-20210422-15100 -  04/22/2021 - Starts here
                /*
    			//Query on the Membership to get the Membership field. 
    			for(Membership__c mem : [Select Id, Name, Previous_Year_Program_Package__c, Current_Year_Program_Package__c, Next_Year_Program_Package__c, 
										Previous_Year_Program_Cost__c, Current_Year_Program_Cost__c, Next_Year_Program_Cost__c, 
                                       Last_Secured_Fiscal_Year__c,
										Previous_Year_Account_Status__c, Current_Year_Account_Status__c, Next_Year_Account_Status__c, 
										Previous_Year_Engagement_Status__c, Current_Year_Engagement_Status__c, Next_Year_Engagement_Status__c, Active_Fiscal_Year__c,
										(Select Id, Fiscal_Year__c, Total_Adjusted_Contracted_Cost__c, Client_Status_New__c, 
                                         Account_Status__c  From Program_Packages_Royall_HD__r)
										
										From Membership__c Where Id IN: setMembershipIds]) {
						
                          
                      	//Setting the null value for all the fields 
                        mem.Current_Year_Program_Package__c = null;        
                        mem.Current_Year_Program_Cost__c = null;
                        mem.Current_Year_Account_Status__c = null;
                        mem.Current_Year_Engagement_Status__c = null;
                        mem.Previous_Year_Program_Package__c= null;
                        mem.Previous_Year_Program_Cost__c = null;
                        mem.Previous_Year_Account_Status__c = null;
                        mem.Previous_Year_Engagement_Status__c = null;
                        mem.Next_Year_Program_Package__c = null;
                        mem.Next_Year_Program_Cost__c = null;
                        mem.Next_Year_Account_Status__c = null;
                        mem.Next_Year_Engagement_Status__c = null;
                        mem.Last_Secured_Fiscal_Year__c = '0'; 
					
					//Checking the size of list or program package
					if(mem.Program_Packages_Royall_HD__r == null && mem.Program_Packages_Royall_HD__r.size() == 0) {
                    	
                        System.debug('No Program Package related to this membership');
                    }else {
                    	
                        //Loop through the Membership child Object program package
                        for(Program_Package__c programPckage : mem.Program_Packages_Royall_HD__r) {
                            
                            //Now check for the Active Fiscal Year for the Membership 
                            if(Integer.valueof(programPckage.Fiscal_Year__c) == Integer.valueof(mem.Active_Fiscal_Year__c)) {
                                
                                mem.Current_Year_Program_Package__c = 	programPckage.Id;
                                mem.Current_Year_Program_Cost__c = programPckage.Total_Adjusted_Contracted_Cost__c;
                                mem.Current_Year_Account_Status__c = programPckage.Account_Status__c; 
                                mem.Current_Year_Engagement_Status__c = programPckage.Client_Status_New__c; 
                            
                            }else if(Integer.valueof(programPckage.Fiscal_Year__c) == Integer.valueof(mem.Active_Fiscal_Year__c) - 1){
                                
                                //Setting value in the Membership Fields
                                mem.Previous_Year_Program_Package__c = programPckage.Id;
                                mem.Previous_Year_Program_Cost__c = programPckage.Total_Adjusted_Contracted_Cost__c;
                                mem.Previous_Year_Account_Status__c = programPckage.Account_Status__c;
                                mem.Previous_Year_Engagement_Status__c = programPckage.Client_Status_New__c; 
                            
                            }else if(Integer.valueOf(programPckage.Fiscal_Year__c) == Integer.valueof(mem.Active_Fiscal_Year__c) + 1) {
                                //Setting values in the membership field for the Next year Program package.
                                mem.Next_Year_Program_Package__c = programPckage.Id;
                                mem.Next_Year_Program_Cost__c = programPckage.Total_Adjusted_Contracted_Cost__c;
                                mem.Next_Year_Account_Status__c = programPckage.Account_Status__c;
                                mem.Next_Year_Engagement_Status__c = programPckage.Client_Status_New__c; 
                            }
                            
                            //Checking for the Engagement Status is secured?
                            if(programPckage.Client_Status_New__c == 'Secured' && programPckage.Fiscal_Year__c != null && 
                               	Integer.valueOf(programPckage.Fiscal_Year__c) > Integer.valueOf(mem.Last_Secured_Fiscal_Year__c))
                            	
                                mem.Last_Secured_Fiscal_Year__c = programPckage.Fiscal_Year__c;
					
                        }
                        
                        
                    }
                    
                     //Checking if Last secured Fiscal value is still 0 then set it null
                     if(String.isNotBlank(mem.Last_Secured_Fiscal_Year__c) && mem.Last_Secured_Fiscal_Year__c == '0')
                         mem.Last_Secured_Fiscal_Year__c = null;
                         
                                            
					//adding value to the Membership list that is going to be Update
					listMembershipToBeUpdated.add(mem);
				}
				
				System.debug('###########listMembershipToBeUpdated Size : ' +listMembershipToBeUpdated.size());
				System.debug('###########listMembershipToBeUpdated : ' +listMembershipToBeUpdated);
				
				//checking the size of list that is going to be updated 
				if(listMembershipToBeUpdated != null && listMembershipToBeUpdated.size() > 0) {
					update listMembershipToBeUpdated;
				}
                */
                //Commented By Mahendra Swarnkar - CR-20210422-15100 -  04/22/2021 - Ends here
            } 
    	}	
    }
    
    //Added By Mahendra Swarnkar - CR-20210422-15100 -  04/22/2021
    public static void updateProgPackageOnMembership(Set<Id> setMembershipIds) {
        
        //List to hold the membership[ that is going to be Updated in the Data base 
    	List<Membership__c> listMembershipToBeUpdated = new List<Membership__c>();
        
        //Checking for the set of Membership ids
        if(setMembershipIds != null && setMembershipIds.size() > 0 ) {
            
            //Query on the Membership to get the Membership field. 
            for(Membership__c mem : [Select Id, Name, Previous_Year_Program_Package__c, Current_Year_Program_Package__c, Next_Year_Program_Package__c, 
                                     Previous_Year_Program_Cost__c, Current_Year_Program_Cost__c, Next_Year_Program_Cost__c, 
                                     Last_Secured_Fiscal_Year__c,
                                     Previous_Year_Account_Status__c, Current_Year_Account_Status__c, Next_Year_Account_Status__c, 
                                     Previous_Year_Engagement_Status__c, Current_Year_Engagement_Status__c, Next_Year_Engagement_Status__c, Active_Fiscal_Year__c,
                                     (Select Id, Fiscal_Year__c, Total_Adjusted_Contracted_Cost__c, Client_Status_New__c, 
                                      Account_Status__c  From Program_Packages_Royall_HD__r)
                                     
                                     From Membership__c Where Id IN: setMembershipIds]) 
            {    
                //Setting the null value for all the fields 
                mem.Current_Year_Program_Package__c = null;        
                mem.Current_Year_Program_Cost__c = null;
                mem.Current_Year_Account_Status__c = null;
                mem.Current_Year_Engagement_Status__c = null;
                mem.Previous_Year_Program_Package__c= null;
                mem.Previous_Year_Program_Cost__c = null;
                mem.Previous_Year_Account_Status__c = null;
                mem.Previous_Year_Engagement_Status__c = null;
                mem.Next_Year_Program_Package__c = null;
                mem.Next_Year_Program_Cost__c = null;
                mem.Next_Year_Account_Status__c = null;
                mem.Next_Year_Engagement_Status__c = null;
                mem.Last_Secured_Fiscal_Year__c = '0'; 
                
                //Checking the size of list or program package
                if(mem.Program_Packages_Royall_HD__r == null && mem.Program_Packages_Royall_HD__r.size() == 0) {
                    
                    System.debug('No Program Package related to this membership');
                }else {
                    
                    //Loop through the Membership child Object program package
                    for(Program_Package__c programPckage : mem.Program_Packages_Royall_HD__r) {
                        
                        //Now check for the Active Fiscal Year for the Membership 
                        if(Integer.valueof(programPckage.Fiscal_Year__c) == Integer.valueof(mem.Active_Fiscal_Year__c)) {
                            
                            mem.Current_Year_Program_Package__c = 	programPckage.Id;
                            mem.Current_Year_Program_Cost__c = programPckage.Total_Adjusted_Contracted_Cost__c;
                            mem.Current_Year_Account_Status__c = programPckage.Account_Status__c; 
                            mem.Current_Year_Engagement_Status__c = programPckage.Client_Status_New__c; 
                            
                        }else if(Integer.valueof(programPckage.Fiscal_Year__c) == Integer.valueof(mem.Active_Fiscal_Year__c) - 1){
                            
                            //Setting value in the Membership Fields
                            mem.Previous_Year_Program_Package__c = programPckage.Id;
                            mem.Previous_Year_Program_Cost__c = programPckage.Total_Adjusted_Contracted_Cost__c;
                            mem.Previous_Year_Account_Status__c = programPckage.Account_Status__c;
                            mem.Previous_Year_Engagement_Status__c = programPckage.Client_Status_New__c; 
                            
                        }else if(Integer.valueOf(programPckage.Fiscal_Year__c) == Integer.valueof(mem.Active_Fiscal_Year__c) + 1) {
                            //Setting values in the membership field for the Next year Program package.
                            mem.Next_Year_Program_Package__c = programPckage.Id;
                            mem.Next_Year_Program_Cost__c = programPckage.Total_Adjusted_Contracted_Cost__c;
                            mem.Next_Year_Account_Status__c = programPckage.Account_Status__c;
                            mem.Next_Year_Engagement_Status__c = programPckage.Client_Status_New__c; 
                        }
                        
                        //Checking for the Engagement Status is secured?
                        if(programPckage.Client_Status_New__c == 'Secured' && programPckage.Fiscal_Year__c != null && 
                           Integer.valueOf(programPckage.Fiscal_Year__c) > Integer.valueOf(mem.Last_Secured_Fiscal_Year__c))
                            
                            mem.Last_Secured_Fiscal_Year__c = programPckage.Fiscal_Year__c;   
                    }
                }
                
                //Checking if Last secured Fiscal value is still 0 then set it null
                if(String.isNotBlank(mem.Last_Secured_Fiscal_Year__c) && mem.Last_Secured_Fiscal_Year__c == '0')
                    mem.Last_Secured_Fiscal_Year__c = null;
                
                //adding value to the Membership list that is going to be Update
                listMembershipToBeUpdated.add(mem);
            }
            
            //checking the size of list that is going to be updated 
            if(listMembershipToBeUpdated != null && listMembershipToBeUpdated.size() > 0) {
                update listMembershipToBeUpdated;
            }
        } 
    }
    
    /**
     *  @description    :   This method is used to populate the following rollup fields
     *						Part A:- populate from the related components 
     *							Fields are =   Total_Contracted_Program_Annual_Cost__c, Total_Contracted_Postage_Cost_CPQ__c, Total_Contracted_Media_Cost_CPQ__c
     * 
     *  @args           :   Map<Id, Program_Package__c>
     *
     *  @return         :   void
     *
	 *  @Version        :	V1.1 - Created By - Subhash Garhawal - 12/27/2018 - CR-20181019-12685
	 * 					:	V1.2 - Updated By Mahendra Swarnkar - 04/03/2019 - CR-20181019-12685 - to include the Postage cost and media cost fields and then populate the respective fields accordingly
    **/
    //Commented by Subhash Garhwal - 01/17/2020
    /*public static void populateRollUpFields(Map<Id, Program_Package__c> mapProgramPackages) {
    	System.debug('mapProgramPackages::::'+mapProgramPackages);
		//Chekc for size
    	if(mapProgramPackages != null && mapProgramPackages.size() > 0){
    		
			//Map to hold the Primary Proposal(Id) on Renewal Opportunity as a Key and Proposal Package Id as value
    		Map<Id,Id> mapPrimaryProposalIdWithProgramPackageId = new Map<Id,Id>();
    		
    		//Updated By Mahendra Swarnkar - 04/03/2019 - CR-20181019-12685 - to include the Postage cost and media cost fields in the query
    		//Aggrigate Query on the Component Subscriptions
    		for(AggregateResult aR : [Select Membership_Period__c pP, SUM(Customer_Amount__c) cAmount, SUM(Media_Costs_m__c) mCost, SUM(Postage_Costs_m__c) pCost,
    										 SUM(Contracted_Contact_Qty_CPQ__c) contrContQty From SBQQ__Subscription__c
    										 Where Membership_Period__c IN : mapProgramPackages.keySet() AND Product_Code__c IN : CPQConstants.CPQ_ES_PRODUCT_CODES
    										 		AND SBQQ__Quantity__c > 0 GROUP BY Membership_Period__c, SBQQ__Product__r.ProductCode]) {
    										 	   	
    			//Get Program Package Id
    			Id pPackageId =  (Id) aR.get('pP');
    			
    			//Check Program Package Id in map
    			if(mapProgramPackages.containsKey(pPackageId)) {
    				
                    if(aR.get('cAmount') != null)
                    	mapProgramPackages.get(pPackageId).Total_Contracted_Program_Annual_Cost__c = (Decimal)(aR.get('cAmount'));
                    
                    if(aR.get('mCost') != null)
						mapProgramPackages.get(pPackageId).Total_Contracted_Media_Cost_CPQ__c = (Decimal) aR.get('mCost');
                    
                    if(aR.get('pCost') != null) 
			    		mapProgramPackages.get(pPackageId).Total_Contracted_Postage_Cost_CPQ__c = (Decimal) aR.get('pCost');
			    	
			    	if(aR.get('contrContQty') != null)
			    		mapProgramPackages.get(pPackageId).Total_Contracted_Contact_Qty_CPQ__c = (Decimal) aR.get('contrContQty');
				}
    		}
    	}
    	
    	//Disable all triggers
		Util.BypassAllTriggers = true;
		
		//Update Program Package
		update mapProgramPackages.values();
		
		//Enable all triggers
		Util.BypassAllTriggers = false;	
    }*/
    
	/**
	*  @description    :   This method is used to populate the following rollup fields
	*						Part A:- populate from the related components 
	*							Fields are =   Total_Contracted_Program_Annual_Cost__c, Total_Contracted_Postage_Cost_CPQ__c, Total_Contracted_Media_Cost_CPQ__c
	* 
	*  @args           :   Map<Id, Program_Package__c>
	*
	*  @return         :   void
	*
	*  @Version        :	V1.1 - Created By - Subhash Garhawal - 01/17/2020
	* 					
	**/
    public static void populateRollUpFields(Map<Id, Program_Package__c> mapProgramPackages) { 
        
        //Check for the size
        if(mapProgramPackages != null && mapProgramPackages.size() > 0){
        	
            //Map to hold uniquekey for Membershipp period with Membership Period.
            Map<String, Id> mapUniqueKeyWithMembeershipPeriodId = new Map<String, Id>();
            
            //Set to hold the Account Ids
            Set<Id> setAccountIds = new Set<Id>();
            
            //Set to hold the Program Ids
            Set<Id> setProgramIds = new Set<Id>();
            
            //Loop over queried memebershipPeriods.
            for(Program_Package__c progPackage : [SELECT Id, Account__c, Fiscal_Year__c, Membership__r.Program__c FROM Program_Package__c 
                                              	  WHERE ID IN :mapProgramPackages.keySet() 
                                                  AND RecordTypeId =: CPQConstants.PROGRAM_PACKAGE_RT_ID_EAB])
            {	
				//Unique Key for Membership period = Account + Fiscal Year + Membership.Program
				String uniqueKeyMembershipPeriod = progPackage.Account__c + '-' + progPackage.Fiscal_Year__c + '-' + progPackage.Membership__r.Program__c;
                
                //populate the map/Sets
                mapUniqueKeyWithMembeershipPeriodId.put(uniqueKeyMembershipPeriod, progPackage.Id);
                setAccountIds.add(progPackage.Account__c);
                setProgramIds.add(progPackage.Membership__r.Program__c);
            }
            
            System.debug('mapProgramPackagesWithUniqueKey::::>>>' +mapUniqueKeyWithMembeershipPeriodId);
            
            //Check for size 
        	if(setAccountIds.size() > 0 && setProgramIds.size() > 0){
                
                //Fetch all the component Subscriptions with matching programs and Accounts.
            	for(SBQQ__Subscription__c compSUb : [Select Id, SBQQ__Account__c, Subscription_Period__r.Period_End_Date__c, 
                                                 Top_Parent_Product__r.Program__c, Product_Code__c, Customer_Amount__c, 
                                                 Media_Costs_m__c, Postage_Costs_m__c, Contracted_Contact_Qty_CPQ__c
                                                 From SBQQ__Subscription__c 
                                                 Where SBQQ__Account__c != null AND SBQQ__Account__c IN : setAccountIds 
                                                 And Top_Parent_Product__c != null AND Top_Parent_Product__r.Program__c != null AND Top_Parent_Product__r.Program__c In : setProgramIds 
                                                 AND Product_Code__c IN : CPQConstants.CPQ_ES_PRODUCT_CODES
                                                 And RecordTypeID =: CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT]) 
				{
                    //Unique Key for Component Subscription = Account + SubscriptionPeriod.EndDate's Year + Top Parent Product.Program
        			String uniqueKeyCompSubscription = '';
                    
                    //Create/populate the unique key for component subscription
                    if(compSUb.SBQQ__Account__c != null && compSUb.Subscription_Period__r.Period_End_Date__c != null && compSUb.Top_Parent_Product__r.Program__c != null){
                    	uniqueKeyCompSubscription = String.valueOf(compSUb.SBQQ__Account__c) + '-' +
                                                String.valueOf((compSUb.Subscription_Period__r.Period_End_Date__c).year()) + '-' +
                                                String.valueOf(compSUb.Top_Parent_Product__r.Program__c);                                 
                    }
                    System.debug('uniqueKeyCompSubscription::::>>>' +uniqueKeyCompSubscription);
                      
                    //Check if there is any membership period with the matching key 
                    if(mapUniqueKeyWithMembeershipPeriodId.containsKey(uniqueKeyCompSubscription) && mapUniqueKeyWithMembeershipPeriodId.get(uniqueKeyCompSubscription) != null) {
                        
                        //get the matched membership Period Id
                        Id matchedMembershipPeriodId= mapUniqueKeyWithMembeershipPeriodId.get(uniqueKeyCompSubscription);
                        
                        //check if it is already contains in the map
                        if(!mapProgramPackages.containsKey(matchedMembershipPeriodId))
                            mapProgramPackages.put(matchedMembershipPeriodId, new Program_Package__c(Id = matchedMembershipPeriodId, Total_Contracted_Program_Annual_Cost__c = 0, Total_Contracted_Media_Cost_CPQ__c = 0, Total_Contracted_Postage_Cost_CPQ__c = 0, Total_Contracted_Contact_Qty_CPQ__c = 0));
                        
                        //Get the Membership Period Instance
                        Program_Package__c membershipPeriod = mapProgramPackages.get(matchedMembershipPeriodId);
                        
                        System.debug('compSUb.Customer_Amount__c : ' + compSUb.Customer_Amount__c + ' compSUb.Media_Costs_m__c : ' + compSUb.Media_Costs_m__c + ' compSUb.Postage_Costs_m__c : ' + compSUb.Postage_Costs_m__c + ' compSUb.Contracted_Contact_Qty_CPQ__c : ' + compSUb.Contracted_Contact_Qty_CPQ__c);
                        //Populate the membership period fields
                        membershipPeriod.Total_Contracted_Program_Annual_Cost__c = (membershipPeriod.Total_Contracted_Program_Annual_Cost__c != null ? membershipPeriod.Total_Contracted_Program_Annual_Cost__c : 0) + (compSUb.Customer_Amount__c != null ? compSUb.Customer_Amount__c : 0) ;
						membershipPeriod.Total_Contracted_Media_Cost_CPQ__c = (membershipPeriod.Total_Contracted_Media_Cost_CPQ__c  != null ? membershipPeriod.Total_Contracted_Media_Cost_CPQ__c : 0) + (compSUb.Media_Costs_m__c != null ? compSUb.Media_Costs_m__c : 0) ;
                        membershipPeriod.Total_Contracted_Postage_Cost_CPQ__c = (membershipPeriod.Total_Contracted_Postage_Cost_CPQ__c  != null ? membershipPeriod.Total_Contracted_Postage_Cost_CPQ__c : 0) + (compSUb.Postage_Costs_m__c != null ? compSUb.Postage_Costs_m__c : 0) ;
                        membershipPeriod.Total_Contracted_Contact_Qty_CPQ__c = (membershipPeriod.Total_Contracted_Contact_Qty_CPQ__c  != null ? membershipPeriod.Total_Contracted_Contact_Qty_CPQ__c : 0) + (compSUb.Contracted_Contact_Qty_CPQ__c != null ? compSUb.Contracted_Contact_Qty_CPQ__c : 0) ;
                        
                        //Populate the Map
                        mapProgramPackages.put(membershipPeriod.Id, membershipPeriod);
                    }  
				}
                System.debug('mapProgramPackages:::::::>>>>>>' +mapProgramPackages);
                
                //Check for size
                if(mapProgramPackages.size() > 0 && mapProgramPackages.values() != null && mapProgramPackages.values().size() > 0) {
                	
                    //Disable all triggers
                    Util.BypassAllTriggers = true;
                    
                    //Update Membership Periods
                    update mapProgramPackages.values();
                    
                    //Enable all triggers
                    Util.BypassAllTriggers = false;	
                }
        	}  
        }
    }
    
    /**
     *  @description    :   This method is used to populate the following rollup fields
     *						Populate from the renewal opportunity related primary proposal 
     *						Fields are = Total_Pending_Signature_Program_Cost_CPQ__c, Total_Pending_Signature_Postage_Cost_CPQ__c, Total_Pending_Signature_Media_Cost__c.
     * 
     *  @args           :   Set<Id>
     *
     *  @return         :   void
     *
	 *  @Version        :	V1.1 - Created By - Subhash Garhawal - 01/11/2019 - CR-20181019-12685
	 * 					:	V1.2 - Updated By Mahendra Swarnkar - 04/03/2019 - CR-20181019-12685 - to include the Postage cost and media cost fields and then populate the respective fields accordingly
    **/
	public static void syncRenewalDetailsOnProgramPackage(Set<Id> setRenewedSubPeriodIds) {
		
		//Map to hold the Program Packages
		Map<Id, Program_Package__c> mapProgramPackages = new Map<Id, Program_Package__c>();
		
		//Check for Subscription Periods
		if(setRenewedSubPeriodIds.size() > 0) {
			
            //Updated By Mahendra Swarnkar - 04/03/2019 - CR-20181019-12685 - to include the Postage cost and media cost fields in the query
			//SOQL over the Proposal Lines
			//Aggrigate Query on the Component Subscriptions
    		for(AggregateResult aR : [Select SBQQ__RenewedSubscription__r.Subscription_Period__r.Program_Package__c pP, SBQQ__Product__r.ProductCode pCode, SUM(SBQQ__CustomerTotal__c) cAmount, SUM(Media_Costs__c) mCost, SUM(Postage_Costs__c) pCost From SBQQ__QuoteLine__c
    										 Where SBQQ__RenewedSubscription__r.Subscription_Period__r.Program_Package__c != null 
    										 		//AND SBQQ__RenewedSubscription__r.Subscription_Period__c IN : setRenewedSubPeriodIds 
                                      				AND SBQQ__RenewedSubscription__r.Subscription_Period__r.Program_Package__c != null
                                      				AND SBQQ__RenewedSubscription__r.Subscription_Period__r.Program_Package__c IN : setRenewedSubPeriodIds
                                      				AND SBQQ__ProductCode__c IN : CPQConstants.CPQ_ES_PRODUCT_CODES
    										 		AND SBQQ__Quantity__c > 0 AND SBQQ__Quote__r.SBQQ__Type__c = 'Renewal'
    										 		GROUP BY SBQQ__RenewedSubscription__r.Subscription_Period__r.Program_Package__c, SBQQ__Product__r.ProductCode]) {
    										 	   	
    			//Get Program Package Id
    			Id pPackageId =  (Id) aR.get('pP');
    			
    			//Check Program Package Id in map
    			if(!mapProgramPackages.containsKey(pPackageId))
    				mapProgramPackages.put(pPackageId, new Program_Package__c(Id = pPackageId));
    				
				//Get Product code
    			String pCode = (String) aR.get('pCode');
				Decimal mediaCost = (Decimal) aR.get('mCost');
	    		Decimal postageCost = (Decimal) aR.get('pCost');
    			
                	//10/27/2020 - CR-20201013-14598 - Victor Hanson - updated to check for Program Costs OR Cappex Service Costs
    			//Check product code and update cost details on Program Package
				if(CPQConstants.COST_PRODUCT_CODES.contains(pCode)) {
                	mapProgramPackages.get(pPackageId).Total_Pending_Signature_Program_Cost_CPQ__c = (Decimal)(aR.get('cAmount'));
                    
                    if(mediaCost > 0)
    					mapProgramPackages.get(pPackageId).Total_Pending_Signature_Media_Cost__c = mediaCost;
    				
                    if(postageCost > 0)
    				mapProgramPackages.get(pPackageId).Total_Pending_Signature_Postage_Cost_CPQ__c = postageCost;
                }
    			
				
				/*
    			else if(pCode == 'Media Costs')
    				mapProgramPackages.get(pPackageId).Total_Pending_Signature_Media_Cost__c = (Decimal)(aR.get('cAmount'));
    			else if(pCode == 'Postage Costs')
    				mapProgramPackages.get(pPackageId).Total_Pending_Signature_Postage_Cost_CPQ__c = (Decimal)(aR.get('cAmount'));
				*/
    		}
    		
    		//Check Program Packages
    		if(mapProgramPackages.size() > 0) {
    			
    			//Disable all triggers
				Util.BypassAllTriggers = true;
				
				//Update Program Package
				update mapProgramPackages.values();
				
				//Enable all triggers
				Util.BypassAllTriggers = false;
    		}
		}
	}
	
	/**
     *  @description    :   This method is used to populate the
     *						1. Total Contracted Contact Qty on the Program Packages from related Component Subscriptions.
     *						2. Total 'Pending Signature' Contact Qty on the Program Packages from related Proposal Lines.
     *
     *						Pick up Paper + E-only field values for the related sub product
     *						Mapping for fields corresponding to Product
     *						'New Names' => 'Paper_New_Names__c', 'E_Only_New_Names__c'
     *						'Inquiry Pool' => 'Paper_Inquiry_Pool__c', 'E_Only_Inquiry_Pool__c'
     *						'PRE Names' => 'Paper_PRE_Names__c', 'E_Only_PRE_Names__c' 
     * 
     *  @args           :   Set<Id>, String
     *
     *  @return         :   void
     *
	 *  @Version        :	V1.1 - Created By - Subhash Garhawal - 01/22/2019 - CR-20181019-12685
	 * 
    **/
	public static void validateTotalContractedContactQty(Set<Id> setRenewedSubPeriodIds, String origin) {
		
		//Check for set size
		if(setRenewedSubPeriodIds.size() > 0) {
			
			//Map to hold the Product Names with relate field names to update the Contracted Contact Qty field
			Map<String, Set<String>> mapProductsWithRelatedFields = CPQConstants.MAP_PRODUCTS_WITH_QL_FIELD_DETAILS;
			
			//Map to hold the Program Packages
			Map<Id, Program_Package__c> mapProgramPackages = new Map<Id, Program_Package__c>();
			
			//Check for Proposal Line origin
			if(origin == CPQConstants.ORIGIN_PROPOSAL_LINE) {
				
				//SOQL over the Proposal Lines
				for(SBQQ__QuoteLine__c pL : [Select Id, SBQQ__RenewedSubscription__r.Subscription_Period__r.Program_Package__c, Related_Product__c, Paper_New_Names__c,
												    E_Only_New_Names__c, Paper_Inquiry_Pool__c, E_Only_Inquiry_Pool__c, Paper_PRE_Names__c, E_Only_PRE_Names__c,
                                             		Paper_Quantity_Fulfillment__c, E_Only_Quantity_Fulfillment__c, Paper_Transfer_Marketing__c, E_Only_Transfer_Marketing__c
												    From SBQQ__QuoteLine__c Where Related_Product__c IN : mapProductsWithRelatedFields.keySet()
												    AND SBQQ__RenewedSubscription__r.Subscription_Period__r.Program_Package__c != null
                                             		AND SBQQ__RenewedSubscription__r.Subscription_Period__r.Program_Package__c IN : setRenewedSubPeriodIds
                                             		AND SBQQ__ProductCode__c IN : CPQConstants.CPQ_ES_PRODUCT_CODES
    										 		AND SBQQ__Quantity__c > 0 AND SBQQ__Quote__r.SBQQ__Type__c = 'Renewal']) {
    										 			
    				//Check Program Package in map
    				if(!mapProgramPackages.containsKey(pL.SBQQ__RenewedSubscription__r.Subscription_Period__r.Program_Package__c))
    					mapProgramPackages.put(pL.SBQQ__RenewedSubscription__r.Subscription_Period__r.Program_Package__c, new Program_Package__c(Id = pL.SBQQ__RenewedSubscription__r.Subscription_Period__r.Program_Package__c, Total_Pending_Signature_Contact_Qty_CPQ__c = 0));
					
					//Check Product in map
					if(mapProductsWithRelatedFields.containsKey(pL.Related_Product__c)) {
						
						//Loop over the fields
						for(String productSpecField : mapProductsWithRelatedFields.get(pL.Related_Product__c)) {
							
							//Check field value
                            if(pL.get(productSpecField) != null){
                                System.debug('@@@@@@ '+ pL.SBQQ__RenewedSubscription__r.Subscription_Period__r.Program_Package__c +' Before :: ' + mapProgramPackages.get(pL.SBQQ__RenewedSubscription__r.Subscription_Period__r.Program_Package__c).Total_Pending_Signature_Contact_Qty_CPQ__c);
                                
                                mapProgramPackages.get(pL.SBQQ__RenewedSubscription__r.Subscription_Period__r.Program_Package__c).Total_Pending_Signature_Contact_Qty_CPQ__c += (Decimal) pL.get(productSpecField); 	
                            	System.debug('@@@@@@ '+ pL.Id +' '+ productSpecField +' :: ' + ((Decimal) pL.get(productSpecField)));
                                System.debug('@@@@@@ '+ pL.SBQQ__RenewedSubscription__r.Subscription_Period__r.Program_Package__c +' After :: ' + mapProgramPackages.get(pL.SBQQ__RenewedSubscription__r.Subscription_Period__r.Program_Package__c).Total_Pending_Signature_Contact_Qty_CPQ__c);
                                
                            }
						}
					}
				}
			}
			
			//Check for map size
			if(mapProgramPackages.size() > 0) {
				
				//Disable all triggers
				Util.BypassAllTriggers = true;
				
				//Update Program Package
				update mapProgramPackages.values();
				
				//Enable all triggers
				Util.BypassAllTriggers = false;
			}
		}
	}
    
    /**
    *  @description    :   Method to populate the Program Cost on Membership 
    *
    *  @args           :   List(New Membership Periods), Map(Old Membership Periods)
    *
    *  @return         :   void
    * 
    *  @Version        :   V_1.0 - Created - Mahendra Swarnkar - 01/08/2021 - CR-20201204-14725 - Update logic behind CX Current Contract Value
    *
    **/
    public static void updateProgramCostOnMembership(List<Program_Package__c> newProgramPackage, map<Id, Program_Package__c> oldProgramPackage) {
        
        //Map to hold the Membership Ids
        Map<Id, Membership__c> mapOfMembershipsToUpdate = new Map<Id, Membership__c>();
        
        
        //Loop through the new list of program package
        for(Program_Package__c programPackage : newProgramPackage){
            
            //Check if the Account is changes than only fill the Set
            if(oldProgramPackage != null && oldProgramPackage.get(programPackage.Id).Membership__c != programPackage.Membership__c ){
                
                //Fill the Map with the new Membership
                if(programPackage.Membership__c != null) 
                    mapOfMembershipsToUpdate.put(programPackage.Membership__c, new Membership__c(Id = programPackage.Membership__c, CX_Current_Contract_Value__c = 0));
                
                //Fill the Map with the new Membership
                if(oldProgramPackage.get(programPackage.Id).Membership__c != null) 
                    mapOfMembershipsToUpdate.put(oldProgramPackage.get(programPackage.Id).Membership__c , 
                                                 new Membership__c(Id = oldProgramPackage.get(programPackage.Id).Membership__c ,
                                                                   CX_Current_Contract_Value__c = 0));
            }
        }
        //Check the Size of set
        if(mapOfMembershipsToUpdate.size() > 0 && mapOfMembershipsToUpdate.keySet().size() > 0) {
            
            //Memberships to be update
            List<Membership__c> listMembershipToUpdate = new LIst<Membership__c>();
            
            for(AggregateResult membershipProgCost : [Select SUM(Program_Cost__c) programCost, Program_Package__r.Membership__c membershipId
                                                      From Royall_Program__c 
                                                      Where Program_Package__c != null AND Program_Package__r.Membership__c != null
                                                      AND End_Date_CX__c > Today AND Start_Date_CX__c < Today
                                                      AND Program_Package__r.Membership__r.Program_Acronym__c =: Constants.PROGRAM_ACRONYM_CXCN 
                                                      AND Program_Package__r.Membership__c IN: mapOfMembershipsToUpdate.keySet() 
                                                      GROUP BY Program_Package__r.Membership__c]
               ) {
                   //System.debug('#membershipProgCost '+membershipProgCost);
                   
                   if(mapOfMembershipsToUpdate.containsKey((Id)membershipProgCost.get('membershipId')))
                       mapOfMembershipsToUpdate.get((Id)membershipProgCost.get('membershipId')).CX_Current_Contract_Value__c =(Double)membershipProgCost.get('programCost');
               }
	       
            //Bypass All Triggers
            Util.BypassAllTriggers = true;
            
            //Check the size of List before update
            if(mapOfMembershipsToUpdate.values().size() > 0)
                update mapOfMembershipsToUpdate.values();
            
            //Enable All Triggers
            Util.BypassAllTriggers = false;
            
        }
    }
    
}