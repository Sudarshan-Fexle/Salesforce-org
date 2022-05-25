trigger Contract_Integrated_Accounts_UpdateFields on Contract_Integrated_Accounts__c (after insert, after update, after delete, before insert, before update)
{
    /*
    Purpose:    Memberships - Membership for a CIA is one that matches Membership Program = CIA Contract's Program AND Membership Account = CIA Account__c
                    For all Memberships connected to these CIA's, initiate query and calculation for these fields:
                    Active_Contract_Idenfied__c
                    Earliest_Contract__c
                    Latest_Contract__c
                    
                Contract Integrated Account
                    Name = LEFT((LEFT(accountName, 55) + progAcronym + YearString + ' - Int').trim(), 80)
    
    Create By:  Jeremy Nottingham (Synaptic) 12/2010
    
    Last Modified By:   Drew Freeman 3/6/12
    
    Current Version:    v1.2
    
    Revision Log:       v1.0 - (JN) Created Trigger 12/2010
                        v1.1 - (JN) Added this header, commented, assured function and test coverage
                        v1.2 - (JN 2/15/2011) Added 'after delete' and modified code accordingly, also brought up test coverage
                        v1.3 - (JN 2/28/2011) Modified Naming Convention to handle long names
                        v1.4 - (DAF 3/6/2012) Blanked out Membership's Active Contract Identified when CIA is deleted
                        v1.5 - Ajit Surana - 08/14/2014 - CR-20140731-6814 - Modified through Line# 243-267 to prevent duplicate records from being added to the "contractsToUpdate" list 
                        v1.6 - Modified By - Mahendra Swarnakar - 3/15/2017 - CR-20170210-10679
                        V1.7 - Modified By - Subhash Garhwal - 6/04/2017 - CR-20170403-10807
                        V1.8 - Modified by - Saurabh Kumar - 06/05/2017 - CR-20170403-10808 (DS114) - Fields "Earliest_Subscription__c", "Active_Subscription__c", "Latest_Subscription__c" are added
                        V1.9 - Modified by - Saurabh Kumar - 06/26/2017 - Issue--CR10808--QA--00005099 - New call is added "populateSubscriptionFieldsOnMembership"
                        //Rajeev - 11/06/2017 - Merged Code of Q2C Hypercare from FFDC1 to Test
                        V2.0 - Modified by - Victor Hanson - 10/18/2017 - Issue--CR11695--QA--00007013 - Modified populateContractsOnMembership to work with standard contracts / CPQ Subscriptions
                        V1.10 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
                        V1.10 - Modified By - Subhash Garhwal - 10/06/2017 - Apollo Release -  Added a new call for Entity field.
                        //Rajeev - 11/06/2017 - Merged Code of Q2C Hypercare from FFDC1 to Test - upto here
                        
    */  
    try {
        
            //Check for trigger
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
            Util.validateEntityValue(Trigger.new, Trigger.oldMap, 'Contract_Integrated_Accounts__c', 'Entity__c', 'Account__c', 'Entity__c', 'Account__r', 'Account');
        
        //return immediately if method returns true 
        if(Util.areTriggersOnThisObjectBypassed('Contract_Integrated_Accounts__c')) return;
        
        //Added By - Mahendra Swarnakar - 3/15/2017 - CR-20170210-10679 -Starts from here
        //Bypass All Triggers
        if (Util.BypassAllTriggers) return;
        
        //Check for trigger event
        if(Trigger.isBefore) {
            
            //Check for event
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Subhash Garhwal - 6/4/2017 - Call Helper class method
                ContractIntegratedAccountsTriggerHelper.cIANamingConvention(Trigger.new);
            }
        }
        
        if (Trigger.isAfter && !Util.IsBatch && !Util.IsTrigger_ContractIntegratedAcctRunning)
        {
            Util.IsTrigger_ContractIntegratedAcctRunning = true;
            
            //Check for trigger event
            if(Trigger.isAfter) {
                
                List<Membership__c> memstoupdate = new List<Membership__c>();
                List<Contract_Integrated_Accounts__c> CIANeedingUpdate = new List<Contract_Integrated_Accounts__c>();
                List<Id> ListOpportunityIds = new List<Id>();
                List<Contract__c> ListContracts = new List<Contract__c>();
                List<Program__c> ListPrograms = new List<Program__c>();
                List<Account> ListAccounts = new List<Account>();
                Map<Id, Program__c> ContractToProgramMap = new Map<Id, Program__c>();
                Map<Id, Contract__c> CIAToContractMap = new Map<Id, Contract__c>();
                Map<Id, Account> CIAToAccountMap = new Map<Id, Account>();
                set<Id> contractIds = new set<Id>();
                set<Id> accids = new set<Id>();
                set<id> progids = new set<id>();
                Set<Id> DeletedCIAContractIDs = new Set<Id>();  // DAF - added 03-07-12        
                
                list<Contract_Integrated_Accounts__c> triggercias = (Trigger.IsDelete)? Trigger.old : Trigger.new;
                Set<Id> DeletedCIAAccountIds = new Set<Id>();
                
                for(Contract_Integrated_Accounts__c c : triggercias)
                {
                    System.debug('### Contract Id:' + c.Contract__c);
                    System.debug('### Account Id:' + c.Account__c);
        
                    if(c.Contract__c != null && c.Account__c != null)
                    {
                        contractIds.add(c.Contract__c);
                        accids.add(c.Account__c);
                    }
         
                    if (Trigger.isDelete) { // DAF - added 03-07-12
                        if(c.Contract__c!=null) // TSCONIERS added 07-26-2012
                            DeletedCIAContractIDs.add(c.Contract__c);   // DAF - added 03-07-12
                        if(c.Account__c!=null) // TSCONIERS added 07-26-2012 
                            DeletedCIAAccountIds.add(c.Account__c); // VRH - added 4/26/12
                        
                    }   // DAF - added 03-07-12
         
                }
                
                ListContracts = [select Id, Program__c, Year__c, Start__c from Contract__c where Id in :contractIds];
                ListAccounts = [select Id, Name, Account_Formal_Name__c from Account where Id in :accids];
                
                //Get Programs for all these Contracts
                for(Contract__c c : ListContracts)
                {
                    if ((c.Program__c != null))
                    {
                        progids.add(c.Program__c);
                    }
                }
                ListPrograms = [select Id, Program_Acronym__c from Program__c where Id in :progids];
                
                for(Contract__c c : ListContracts)
                {
                    if(c.Program__c != null)
                    {
                        for(Program__c p : ListPrograms)
                        {
                            if(p.id == c.Program__c)
                            {
                                ContractToProgramMap.put(c.Id, p);
                            }
                        }
                    }
                } 
                
                //Only execute the code for delete scenerio
                if(Trigger.isDelete) {
                    
                    //V1.8 - Modified by - Saurabh Kumar - 06/05/2017 - CR-20170403-10808 (DS114) - Fields "Earliest_Subscription__c", "Active_Subscription__c", "Latest_Subscription__c" are added
                    list<Membership__c> memstocheck = [select Id, Account_Name__c, Program__c, Active_Contract_Idenfied__c, Active_Subscription__c,
                        Active_Contract_Idenfied__r.Start__c, Active_Contract_Idenfied__r.End__c, Earliest_Contract__c, Latest_Subscription__c, Earliest_Subscription__c,
                        Earliest_Contract__r.Start__c, Earliest_Contract__r.End__c, Latest_Contract__c, Latest_Contract__r.Start__c, 
                        Latest_Contract__r.End__c  
                        from Membership__c where Program__c in :progids and Account_Name__c in :accids];
                    
                    list<Contract__c> contracts = [select id, Start__c, End__c, Program__c, Payer_Account__c, Program__r.Program_Acronym__c, Year__c,
                        (select id, Account__c from Contract_Integrated_Accounts__r where Account__c in :accids)
                        from Contract__c 
                        where ((Payer_Account__c in :accids and Program__c in :progids) or (id in :contractIds))
                        and (Status__c = 'ATL' or Status__c = 'Honorary' or Status__c = 'Dropped')];
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
                    
                    Set<Id> acctIds = new Set<Id>();
                    
                    for (Membership__c m : memstocheck) {
                        Contract__c earliestContract;
                        Contract__c latestContract;
                        Contract__c latestActiveContract;
                        Contract__c earliestFutureContract;
                        
                        if (accid2contractlistmap.get(m.Account_Name__c) != null) {
            
                            for (Contract__c acon : accid2contractlistmap.get(m.Account_Name__c)) {
                                if (acon.Program__c != m.Program__c) continue; 
                                
                                //earliest contract
                                if ((acon.Start__c != null) 
                                    && ((earliestContract == null)  || (acon.Start__c < earliestContract.Start__c))) 
                                {
                                    //system.debug('\n\nearliest ' + acon.id);
                                    earliestContract = acon;
                                }
                                
                                //latest contract
                                if ((acon.End__c != null)
                                    && ((latestContract == null) || (acon.End__c > latestContract.End__c))) 
                                {
                                    //system.debug('\n\nlatest ' + acon.id);
                                    latestContract = acon;
                                }
                                
                                //active contract idenfied
                                if (((acon.Start__c != null) && (acon.End__c != null))
                                    && (acon.Start__c <= system.today()) 
                                    && (acon.End__c >= system.today())) 
                                {
                                    if ((latestActiveContract == null) || (acon.End__c > latestActiveContract.End__c)) 
                                    {
                                        //system.debug('\n\nactive ident ' + acon.id);
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
                            
                            if (latestActiveContract == null) {
                                latestActiveContract = earliestFutureContract;
                            }
                        } //end if account and program null
                        
                        //put m in update list if any changes are necessary
                        if ( ( ((earliestContract != null) && (earliestContract.id != m.Earliest_Contract__c))
                            || ( (latestContract != null) && (latestContract.id != m.Latest_Contract__c))
                            || ( (latestActiveContract != null) && (latestActiveContract.id != m.Active_Contract_Idenfied__c))) ) 
                        {
                            //put changed values into appropriate fields
                            if (earliestContract != null) m.Earliest_Contract__c = earliestContract.id;
                            if (latestContract != null) m.Latest_Contract__c = latestContract.id;
                            if (latestActiveContract != null) m.Active_Contract_Idenfied__c = latestActiveContract.id;
            
                            if (Trigger.isDelete) {
                                m.Active_Contract_Idenfied__c = null;
                                m.Earliest_Contract__c = null;
                                m.Latest_Contract__c = null;
                                acctIds.add(m.Account_Name__c);
                                
                            } //DAF - added 03-06-12
                            
                            memstoupdate.add(m);    //DAF - moved from above 03-06-12
            
                        }
                        
                    }
                    
                    //Perform Membership update as necessary
                    if (memstoupdate.size() > 0) {
                        update memstoupdate;
                        // find all contracts associated with these memberships
                        List<Contract__c> contractsToUpdate = [SELECT Id FROM Contract__c WHERE Payer_Account__c IN :acctIds];
                        // update these contracts 
                        update contractsToUpdate;
                    }
                    
                    //V1.8 - Modified by - Saurabh Kumar - 06/05/2017 - CR-20170403-10808 (DS114) - Fields "Earliest_Subscription__c", "Active_Subscription__c", "Latest_Subscription__c" are added
                    //DAF - added below 03-06-12
                    memstoupdate.clear();
                    for (Membership__c m : [select Id, Active_Contract_Idenfied__c, Active_Subscription__c, Earliest_Contract__c, Earliest_Subscription__c,  Latest_Contract__c, Latest_Subscription__c, Account_Name__c 
                                        from Membership__c 
                                        where (Active_Contract_Idenfied__c IN :DeletedCIAContractIDs OR Earliest_Contract__c IN :DeletedCIAContractIDs OR Latest_Contract__c IN :DeletedCIAContractIDs)]) {
                        m.Active_Contract_Idenfied__c = null;
                        m.Earliest_Contract__c = null;
                        m.Latest_Contract__c = null;
                        acctIds.add(m.Account_Name__c);
                        memstoupdate.add(m);
                    }
                    //Perform Membership update as necessary
                    if (memstoupdate.size() > 0) {
                        update memstoupdate;
                        // find all remaining contract integrated accounts for the deleted CIAs
                        List<Contract_Integrated_Accounts__c> cias = [SELECT Id, Contract__c FROM Contract_Integrated_Accounts__c WHERE Account__c IN :DeletedCIAAccountIDs];
                        
                        //Set of Ids of Contract ABC records to be updated
                        Set<Id> contractIdsToUpdate = new Set<Id>();
                        
                        //Loop through the CIAs records
                        for (Contract_Integrated_Accounts__c cia : cias)
                            contractIdsToUpdate.add(cia.Contract__c);
                        system.debug('@@GOT HERE! 242' + memstoupdate);
                        
                        //Modified By - Ajit Surana - 08/14/2014 - CR-20140731-6814
                        //Map to hold the Contract ABC records to be updated with appropriate values
                        Map<Id, Contract__c> mapContractsToUpdate = new Map<Id, Contract__c>();
                        
                        // find all contracts associated with these memberships
                        // get the earliest
                        List<Contract__c> contractListEarliest = [SELECT Id FROM Contract__c WHERE Id IN :contractIdsToUpdate AND (Negotiated_Amount__c != null AND Type__c != null AND Start__c != null AND End__c != null AND Year__c != null AND Program__c != null AND Join_Date__c != null AND Payer_Account__c != null AND Main_Contact__c != null AND Invoice_Contact__c != Null) ORDER BY Start__c ASC LIMIT 1];
                        if (contractListEarliest.size() > 0)
                            mapContractsToUpdate.put(contractListEarliest[0].Id, contractListEarliest[0]);
                        
                        // get the latest
                        List<Contract__c> contractListLatest = [SELECT Id FROM Contract__c WHERE Id IN :contractIdsToUpdate AND (Negotiated_Amount__c != null AND Type__c != null AND Start__c != null AND End__c != null AND Year__c != null AND Program__c != null AND Join_Date__c != null AND Payer_Account__c != null AND Main_Contact__c != null AND Invoice_Contact__c != Null) ORDER BY Start__c DESC LIMIT 1];
                        if (contractListLatest.size() > 0)
                            mapContractsToUpdate.put(contractListLatest[0].Id, contractListLatest[0]);
                        
                        // get the current
                        List<Contract__c> contractListCurrent = [SELECT Id FROM Contract__c WHERE Id IN :contractIdsToUpdate AND (Negotiated_Amount__c != null AND Type__c != null AND Start__c != null AND End__c != null AND Year__c != null AND Program__c != null AND Join_Date__c != null AND Payer_Account__c != null AND Main_Contact__c != null AND Invoice_Contact__c != Null) AND Active_2__c = 'Active' AND Start__c > TODAY AND End__c < TODAY ORDER BY Start__c Desc LIMIT 1];
                        if (contractListCurrent.size() > 0)
                            mapContractsToUpdate.put(contractListCurrent[0].Id, contractListCurrent[0]);
                        
                        
                        // update these contracts 
                        system.debug('@@Contracts to update:' + mapContractsToUpdate);
                        update mapContractsToUpdate.values();
                    }
                    //DAF - added above 03-06-12
                } else if (!Trigger.IsDelete) {
                       
                   List<Contract__c> contractsToUpdate = [Select Id , Start__c, End__c, Program__c, Payer_Account__c, Active__c, CreatedDate from Contract__c where Id IN: contractIds];
                       
                   //Update Membership records
                    ContractIntegratedAccountsTriggerHelper.populateContractsOnMembership(contractsToUpdate, Trigger.New);
                   
                    // Perform Name Check/Update
                    System.debug('### Name Check/Update ###');
                    
                    //Get Accounts and Contracts
                    for(Contract_Integrated_Accounts__c cia : Trigger.new) {
                    
                        for(Contract__c c : ListContracts) {
                            if(c.Id == cia.Contract__c)
                                CIAToContractMap.put(cia.Id, c);
                        }
                        
                        for(Account a : ListAccounts) {
                            if(a.Id == cia.Account__c)
                                CIAToAccountMap.put(cia.Id, a);
                        }
                    }
                        
                    System.debug('### List Contracts:' + CIAToContractMap);
                    System.debug('### List Accounts:' + CIAToAccountMap);
                
                    /*  Name  */
                    
                    for(Contract_Integrated_Accounts__c cia : Trigger.New) {
                        if(cia.Account__c != null && cia.Contract__c != null) {
                            integer maxAcctLen = 55;
                            string accountName = '';
                            string progAcronym = '';
                            string YearString = '';
                            string newName = '';
                            
                            System.debug('### Contract Integrated Account Id: ' + cia.Account__c);
                            System.debug('### Contract Integrated Contract Id: ' + cia.Contract__c);
                            
                            if(CIAToAccountMap.get(cia.Id) != null) {
                            
                                System.debug('### Contract Integrated Account (Name): ' + CIAToAccountMap.get(cia.Id).Name);
                                System.debug('### Contract Integrated Account (Name) [trimmed]: ' + CIAToAccountMap.get(cia.Id).Name.substring(0, Math.min(maxAcctLen, CIAToAccountMap.get(cia.Id).Name.Length())));
                                if (CIAToAccountMap.get(cia.Id).Name != null) accountName = CIAToAccountMap.get(cia.Id).Name.substring(0, Math.min(maxAcctLen, CIAToAccountMap.get(cia.Id).Name.Length())) + ' - ';
                            }
                            
                            if(ContractToProgramMap.get(cia.Contract__c) != null) {
                            
                                System.debug('### Contract Integrated Contract (Program - Acryonym): ' + ContractToProgramMap.get(cia.Contract__c).Program_Acronym__c);
                                if (ContractToProgramMap.get(cia.Contract__c).Program_Acronym__c != null) progAcronym =  ContractToProgramMap.get(cia.Contract__c).Program_Acronym__c + ' - ';
                            }
                            
                            if(CIAToContractMap.get(cia.Id) != null) {
                            
                                System.debug('### Contract Integrated Contract (Start): ' + CIAToContractMap.get(cia.Id).Start__c);
                                if (CIAToContractMap.get(cia.Id).Year__c != null) YearString = CIAToContractMap.get(cia.Id).Year__c;
                            }
                            
                            newName = (accountName + progAcronym + YearString + ' - Int').trim();
                            newName = newName.substring(0,Math.min(newName.Length(), 80));
                            
                            System.debug('### Contract Integrated Account Current Name: ' + cia.Name);
                            System.debug('### Contract Integrated Account New Name: ' + newName);
                            
                            if(cia.Name != newName)
                                CIANeedingUpdate.add(new Contract_Integrated_Accounts__c(Id = cia.Id, Account__c = cia.Account__c, Contract__c = cia.Contract__c, Name = newName));
                        }
                    }
                    
                    // Update Names
                    if(CIANeedingUpdate.size() > 0) update CIANeedingUpdate;
                }
                Util.IsTrigger_ContractIntegratedAcctRunning = false;
                
            } 
            
            //Check Event type
            if(Trigger.isAfter) {
                
                //Check for request type
                if(Trigger.isInsert || Trigger.isUpdate){
                    
                    //Added By - Mahendra Swarnakar - 3/15/2017 - CR-20170210-10679 - Call helper Class method
                    ContractIntegratedAccountsTriggerHelper.createMembershipForCIARecords(Trigger.new, Trigger.oldmap);
                }
            }
            //Added By - Mahendra Swarnakar - 3/15/2017 - CR-20170210-10679 -Ends here
        }
        
        //Check Event type
        if(Trigger.isAfter) {
            
            System.debug('CIA############ : ' +Trigger.new);
            
            //Check for trigger event
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)
                ContractIntegratedAccountsTriggerHelper.populateSubscriptionFieldsOnMembership(Trigger.new, Trigger.oldMap);
                    
            //Check for request type
            if(Trigger.isInsert){
                //Subhash Garhwal - 6/7/2017
                ContractIntegratedAccountsTriggerHelper.createMemberships(Trigger.new);
            }
        }
        
    } catch(DMLException e) {
           
        //failed record
        String failedRecordId = e.getDmlId(0);
        String failureMessage = e.getDmlMessage(0);
       
        String errorMessage = Label.ERROR_TRIGGER_SUBTEXT_1 + failedRecordId + Label.ERROR_TRIGGER_SUBTEXT_2 + failedRecordId +  Label.ERROR_TRIGGER_SUBTEXT_3 + failureMessage;
       
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(errorMessage);
        else
            Trigger.New[0].addError(errorMessage);
    } catch(Exception e) {
               
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}