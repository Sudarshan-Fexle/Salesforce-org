/**
 * 
 * @Description: VRH - this class contains methods to assist with the processing of membership records.
 * 
 * @Revision Log:       V_1.0 - Updated PopulateContractFields method to run more efficient Apex & SOQL queries - CR-20160115-9521 -2/11/2016
 *			V_1.1 - Modified by - Saurabh Kumar - 06/05/2017 - CR-20170403-10808 (DS114) - Fields "Earliest_Subscription__c", "Active_Subscription__c", "Latest_Subscription__c" are added
 * 			V_1.2 - Modified By - Neha Sharma - 11/03/2020 - CR-20200930-14569 - Commented out all values which is used to update Membership Owner
 *         	 	V_1.3 - Modified By - Neha Sharma - 10/03/2021 - CR-20200814-14435 - Remove the Commented out calling of  Util.membershipOwnerCheckfromMemberships(memidstoCheckRenewalOppOwner) method which is used to update Membership Owner
        
 **/
public with sharing class ContractUtilities {
	
	public static boolean IsActiveContractStatus(String contractStatus) {
		boolean isActive = true;
		if (contractStatus != null && (contractStatus.toLowerCase() == 'void' || 
			contractStatus.toLowerCase() == 'closed' || 
			contractStatus.toLowerCase() == 'pending')) {
				isActive = false;
		}
		return isActive;
	}
	
	 public static void PopulateContractFields(Map<Id, Contract__c> triggerNewMap) {
		
		System.Debug('### Begin Contract_AIAU_UpdateFields Trigger ###');
	
	    //Look for flags to skip reaction
	    if (!System.isBatch() && !Util.IsTestingContractIntegratedAcct)
	    {
	    
			System.Debug('\n### Begin Membership Earliest Contract, Latest Contract, Active Contract Identified, and Membership Owner Update ###');
	    
	        List<Membership__c> memstoupdate = new List<Membership__c>();
	        set<Id> sourceOppIds = new set<Id>();
	        set<Id> accids = new set<Id>();
	        set<id> progids = new set<id>();
	        set<id> ciaContractIds = new set<id>(); //set of Contract IDs from applicable Contract Integrated Accounts 
			Set<Id> VoidContractIDs = new Set<Id>();	// DAF - added 03-07-12        
	        Util.IsTrigger_ContractFieldUpdate = true;
	        for(Contract__c c : triggerNewMap.values())
	        {
	            //Collect Program and Account Ids to use to find Memberships
	            if ((c.Program__c != null) && (c.Payer_Account__c != null))
	            {
	                progids.add(c.Program__c);
	                accids.add(c.Payer_Account__c);
	            }
	            
				if (!ContractUtilities.IsActiveContractStatus(c.Status__c)) {	// DAF - added 03-07-12 // VRH - modified 4/4/12
					VoidContractIDs.add(c.Id);	// DAF - added 03-07-12
				}	// DAF - added 03-07-12
	
	        }
	        
	        //get set of Contract Ids on the basis of matching Contract Integrated Accounts 
	        List<Contract_Integrated_Accounts__c> ciaList = [select Id, Account__c, Contract__c, Contract__r.Program__c from Contract_Integrated_Accounts__c 
	            where (Contract__r.Program__c in :progids)
	            and ((Account__c in :accids) OR (Contract__c in :triggerNewMap.keyset()))];
	        
	        for (Contract_Integrated_Accounts__c cia : ciaList) {
	            //If this CIA is attached to a triggering Contract, get the CIA Account ID to find the Membership connected to it.
	            if (triggerNewMap.containsKey(cia.Contract__c)) {
                    if (cia.Account__c != null) //VH CR-20160115-9521
	                	accids.add(cia.Account__c);
	            }
	        }
	        
	        //V_1.2 - Modified by - Saurabh Kumar - 06/05/2017 - CR-20170403-10808 (DS114) - Fields "Earliest_Subscription__c", "Active_Subscription__c", "Latest_Subscription__c" are added
	        list<Membership__c> memstocheck = [select Id, Account_Name__c, Program__c, Active_Contract_Idenfied__c, Active_Subscription__c,
	            Active_Contract_Idenfied__r.Start__c, Active_Contract_Idenfied__r.End__c, Earliest_Contract__c, Earliest_Subscription__c, 
	            Earliest_Contract__r.Start__c, Earliest_Contract__r.End__c, Latest_Contract__c, Latest_Subscription__c, Latest_Contract__r.Start__c, 
	            Latest_Contract__r.End__c  
	            from Membership__c where Program__c in :progids and Account_Name__c in :accids];
	        
            //set<acctId-progId> - VH CR-20160115-9521
            set<string> memsToCheckSet = new set<string>();
            for (Membership__c m : memsToCheck) memsToCheckSet.add(m.Account_Name__c + '-' + m.Program__c);
	        
	        for(Contract_Integrated_Accounts__c cia : ciaList)
	        {
                if (memsToCheckSet.contains(cia.Account__c + '-' + cia.Contract__r.Program__c))
                    ciaContractIds.add(cia.Contract__c);
	        }
	        
	        
	        list<Contract__c> contracts = [select id, Start__c, End__c, Program__c, Payer_Account__c,
	            (select id, Account__c from Contract_Integrated_Accounts__r where Account__c in :accids)
	            from Contract__c 
	            where ((Payer_Account__c in :accids and Program__c in :progids)
	            or (id in :ciaContractIds))
	            and Start__c != null and End__c != null
	            and (Status__c = 'ATL' or Status__c = 'Honorary' or Status__c = 'Dropped')]; // Nathan B 1/5/11 - Added Status condition
	        map<id, Contract__c> conid2conmap = new map<id, Contract__c>(contracts);
	        
	        map<id, list<Contract__c>> accid2contractlistmap = new map<id, list<Contract__c>>();
	        map<id, set<Id>> accid2contractidsetmap = new map<id, set<id>>(); //acc id to Contract IDs, to make sure we don't add the same Contract twice
	        
	        //go through contracts (and Contract Integrated Accounts) for identified Memberships and put in sets by account number
	        for (Contract__c c : contracts) {
	            if (accid2contractidsetmap.get(c.Payer_Account__c) == null) 
	                accid2contractidsetmap.put(c.Payer_Account__c, new set<id>{c.id});
	            else
	                accid2contractidsetmap.get(c.Payer_Account__c).add(c.id);
	                
	            //Include entire list of Contract Integrated Accounts on this Contract as connections. 1/11/11 jn
	            for (Contract_Integrated_Accounts__c cia : c.Contract_Integrated_Accounts__r) {
	                if (accid2contractidsetmap.get(cia.Account__c) == null) 
	                    accid2contractidsetmap.put(cia.Account__c, new set<id>{c.id});
	                else
	                    accid2contractidsetmap.get(cia.Account__c).add(c.id);
	            }
	        } //end for contracts
	        
	        //convert id sets into contract lists by account ID
	        for (Id i : accid2contractidsetmap.keyset()) {
	            accid2contractlistmap.put(i,new list<Contract__c>());
	            for (Id cid : accid2contractidsetmap.get(i)) {
	                accid2contractlistmap.get(i).add(conid2conmap.get(cid));
	            }
	        }
	        
	        //Set of Membership IDs that need to be checked for a change in Owner
	        set<id> memidstoCheckRenewalOppOwner = new set<id>();
	        
	        for (Membership__c m : memstocheck) {
	            Contract__c earliestContract;
	            Contract__c latestContract;
	            Contract__c latestActiveContract;
	            Contract__c earliestFutureContract;
	            
	            //Go through all contracts connected to this Membership
	            if (accid2contractlistmap.get(m.Account_Name__c) != null) {
	                for (Contract__c acon : accid2contractlistmap.get(m.Account_Name__c)) {
	                    if (acon.Program__c != m.Program__c) continue; 
	                    
	                    //earliest contract
	                    if ((acon.Start__c != null) 
	                        && ((earliestContract == null)  || (acon.Start__c < earliestContract.Start__c))) 
	                    {
	                        earliestContract = acon;
	                    }
	                    
	                    //latest contract
	                    if ((acon.End__c != null)
	                        && ((latestContract == null) || (acon.End__c > latestContract.End__c))) 
	                    {
	                        latestContract = acon;
	                    }
	                    
	                    //active contract idenfied
	                    if (((acon.Start__c != null) && (acon.End__c != null))
	                        && (acon.Start__c <= system.today()) 
	                        && (acon.End__c >= system.today())) 
	                    {
	                        if ((latestActiveContract == null) || (acon.End__c > latestActiveContract.End__c)) 
	                        {
	                            latestActiveContract = acon;
	                        }
	                    }
	                    
	                    //earliest Future Contract (to use for Active Contract Idenfied if there is none found within its dates)
	                    if ((acon.Start__c != null) 
	                        && (acon.End__c != null)
	                        && (acon.Start__c > system.today())
	                        && ((earliestFutureContract == null) || (acon.Start__c < earliestFutureContract.Start__c)))
	                    {
	                        earliestFutureContract = acon;
	                    }
	                
	                }//end for acon
	                
	                //If this is no "Active" Contract, is there one in the future? We could use that in a pinch
	                if ((latestActiveContract == null) && (earliestFutureContract != null)){
	                    latestActiveContract = earliestFutureContract;
	                }
	            } //end if account and program null
	            
	            //put in update list if any changes are necessary
	            if ( ( ((earliestContract != null) && (earliestContract.id != m.Earliest_Contract__c))
	                || ( (latestContract != null) && (latestContract.id != m.Latest_Contract__c))
	                || ( (latestActiveContract != null) && (latestActiveContract.id != m.Active_Contract_Idenfied__c))) ) 
	            {
	                //put changed values into appropriate fields
	                if ((earliestContract != null) && (earliestContract.id != m.Earliest_Contract__c)) m.Earliest_Contract__c = earliestContract.id;
	                if ((latestContract != null) && (latestContract.id != m.Latest_Contract__c)) m.Latest_Contract__c = latestContract.id;
	                if ((latestActiveContract != null) && (latestActiveContract.id != m.Active_Contract_Idenfied__c)) {
	                    m.Active_Contract_Idenfied__c = latestActiveContract.id;
	                    //check this Membership to see if the Owner is still correct
	                    memidstoCheckRenewalOppOwner.add(m.id);
	                }
	
	                memstoupdate.add(m);
	            }
	            
	        }
	        
	        if (memstoupdate.size() > 0) {
	        	
	        	//Reset the flags to execute the membership trigger
				Util.IsTrigger_ContractFieldUpdate = false;
				Util.IsTrigger_Opportunity_ValidationAndFieldUpdates = false;
					
	        	System.debug('memstoupdate:::::' + memstoupdate);
	        	update memstoupdate;
	        }
	        
			//DAF - added below 03-06-12
			memstoupdate.clear();
	        for (Membership__c m : [select Id, Active_Contract_Idenfied__c, Earliest_Contract__r.Status__c, Latest_Contract__r.Status__c, Active_Contract_Idenfied__r.Status__c from Membership__c where Active_Contract_Idenfied__c in :VoidContractIDs]) {
				if (!ContractUtilities.IsActiveContractStatus(m.Active_Contract_Idenfied__r.Status__c)) 
					m.Active_Contract_Idenfied__c = null;
				if (!ContractUtilities.IsActiveContractStatus(m.Latest_Contract__r.Status__c))
					m.Latest_Contract__c = null;
				if (!ContractUtilities.IsActiveContractStatus(m.Earliest_Contract__r.Status__c))
					m.Earliest_Contract__c = null;
				
				memstoupdate.add(m);
				
	        }
	        if (memstoupdate.size() > 0) {
	        	
	        	//Reset the flags to execute the membership trigger
				Util.IsTrigger_ContractFieldUpdate = false;
				Util.IsTrigger_Opportunity_ValidationAndFieldUpdates = false;
					
	        	System.debug('memstoupdate:::::' + memstoupdate);
	        	update memstoupdate;
	        }
			//DAF - added above 03-06-12
	
	
	        
			System.Debug('### End Membership Active Contract Identified Earliest Contract /Latest Contract Update ###');
	
			System.Debug('### Start Source Opportunity Signed Opportunity Contract Update ###');
	        
	        for(Contract__c c : triggerNewMap.values())
	        {
	            //Collect Source Opportunity IDs to update their Signed Opportunity Contract fields later
	            if(c.Source_Opportunity__c != null)
	            {
	                sourceOppIds.Add(c.Source_Opportunity__c);
	            }
	        }
	        
	        map<id, Opportunity> sourceOppidmap = new map<id, Opportunity>([select id, Signed_Opportunity_Contract__c 
	            from Opportunity where id in :sourceOppIds]);
	        set<id> oppidstoupdate = new set<id>();
	        for (Contract__c c : triggerNewMap.values()) {
	            //Skip if no source, or conflict with other source in trigger list
	            if ((c.Source_Opportunity__c == null) || (oppidstoupdate.contains(c.Source_Opportunity__c))) continue;
	            
	            //get source Opp
	            Opportunity sourceOpp = sourceOppidmap.get(c.Source_Opportunity__c);
	            
	            //If source opportunity's field is not already set properly, set it
	            if (sourceOpp.Signed_Opportunity_Contract__c != c.id) {
	                sourceOpp.Signed_Opportunity_Contract__c = c.id;
	                oppidstoupdate.add(sourceOpp.id);
	            }
	        }
	        
	        //make update list
	        list<Opportunity> oppstoupdate = new list<Opportunity>();
	        for (Id i : oppidstoupdate) oppstoupdate.add(sourceOppidmap.get(i));
	        
	        //Update Opportunities
	        if (oppstoupdate.size() > 0) update oppstoupdate;
	
			System.Debug('### End Source Opportunity Signed Opportunity Contract Update ###');
	        
	    } //end if !System.isBatch
	} 
}