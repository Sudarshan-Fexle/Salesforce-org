/*
    Purpose         :   Temporary Batch class to update Payer status field value on Membership.
                
    Create By       :   MAhendra Swarnkar
    
    Created Date    :   08/19/2020
    
    Revision Log    :   V1.0 - Created - 08/19/2020 - CR-20200427-13986
						    
*/
global without sharing class Batch_MembershipPayerStatusDataUpdate implements Database.Batchable<SObject>, Database.Stateful {
    
    public String queryString;
        
    //String which holds the csv values
    public String csvString = ' Membership Id ' + ',' + ' Old Payer Status ' + ',' + ' New Payer Status ' + ',' + ' Old Membership Status ' + ',' + ' New Membership Status ' + ',' + '\n';
    
    
    global Database.Querylocator start(Database.BatchableContext BC) {
        
        if(String.isBlank(queryString) ){
            //queryString = 'SELECT Id, Account_Name__c, Program__c, Payer_Status__c, Membership_Status_Text__c, Active_Subscription__c, Active_Contract_Idenfied__c FROM Membership__c Where Payer_Status__c = null OR Payer_Status__c = \'\' ';
            queryString = 'SELECT Id, Account_Name__c, Program__c, Payer_Status__c, Membership_Status_Text__c, Active_Subscription__c, Active_Contract_Idenfied__c FROM Membership__c ';
        }
        
        //Query over the Membership where the Active subscription's research strategic leader in not null and not deactivated.
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<Membership__c> scope) {
        
        //List to hold the new Value Of membership
        List<Membership__c> membershipToBeUpdate = new  List<Membership__c>();
        
        //Check for size
        if( !scope.isEmpty()) {
            
            //Set to hold the active subscription Ids
            Set<Id> setActiveSubscriptionIds = new Set<Id>();
            
            //Set to hold the Active Contract ABC's Ids
            Set<Id> setActiveContractABCIds = new Set<Id>();
                
            //Getting new or updated membership 
            for(Membership__c memb : scope) {
                	
                //Populate the sets
                if(memb.Active_Subscription__c != null ) 
                    setActiveSubscriptionIds.add(memb.Active_Subscription__c);
                
                //Populate the sets
                if(memb.Active_Contract_Idenfied__c != null ) 
                    setActiveContractABCIds.add(memb.Active_Contract_Idenfied__c);
            }
            
            //Map to hold the Active subscriptions
            Map<Id, SBQQ__Subscription__c> mapActiveSubscriptions;
            if(setActiveSubscriptionIds.size() > 0) {
                mapActiveSubscriptions = new Map<Id, SBQQ__Subscription__c>([Select Id, SBQQ__Account__c, Program__c, SBQQ__RequiredByProduct__c, 
                                                                              SBQQ__RequiredByProduct__r.Parent_Product__c, SBQQ__RequiredByProduct__r.Parent_Product__r.Program__c, 
                                                                              SBQQ__Product__c, SBQQ__Product__r.Parent_Product__c, SBQQ__Product__r.Parent_Product__r.Program__c 
                                                                             From SBQQ__Subscription__c 
                                                                             Where ID IN : setActiveSubscriptionIds]);
            }
            
            //Map to hod the Active Contract ABCs
            Map<Id, Contract__c> mapActiveContractABCs;
            if(setActiveContractABCIds.size() > 0) {
                mapActiveContractABCs = new Map<Id, Contract__c>([Select Id, Payer_Account__c, Program__c From Contract__c Where ID IN : setActiveContractABCIds]);
            }
            
            //Getting new or updated membership 
            for(Membership__c mem : scope) {
                
                //Set default payer status
                String PAYER_STATUS = 'N/A';
                
                //Check for acccount
                if(mem.Account_Name__c != null && mem.Program__c != null) {
                    
                    //Check for active Subscriptions
                    if(mem.Active_Subscription__c != null && mapActiveSubscriptions != null && mapActiveSubscriptions.size() > 0 
                        && mapActiveSubscriptions.containsKey(mem.Active_Subscription__c) && mapActiveSubscriptions.get(mem.Active_Subscription__c) != null) 
                    { 
                                                
                        //Check for conditions to populate the payer status
                        if( mapActiveSubscriptions.get(mem.Active_Subscription__c).SBQQ__Account__c != null 
                           && mem.Account_Name__c ==  mapActiveSubscriptions.get(mem.Active_Subscription__c).SBQQ__Account__c )
                        {
                         	if( mapActiveSubscriptions.get(mem.Active_Subscription__c).Program__c != null && mem.Program__c ==  mapActiveSubscriptions.get(mem.Active_Subscription__c).Program__c) {
                                
                                PAYER_STATUS = Constants.PAYER; 
                            } else {
                                
                                PAYER_STATUS = Constants.PAYER_STATUS_INTEGRATED_GLOBAL;
                            }
                        } else {
                            
                            if((mapActiveSubscriptions.get(mem.Active_Subscription__c).Program__c != null && mem.Program__c ==  mapActiveSubscriptions.get(mem.Active_Subscription__c).Program__c))
                            	PAYER_STATUS = Constants.PAYER_STATUS_INTEGRATED;
                        }
                          
                     //Check for tje Active Contract ABCs
                    } else if(mem.Active_Contract_Idenfied__c != null && mapActiveContractABCs != null && mapActiveContractABCs.size() > 0 
                           && mapActiveContractABCs.containsKey(mem.Active_Contract_Idenfied__c) && mapActiveContractABCs.get(mem.Active_Contract_Idenfied__c) != null) 
                    {
                        
                        //Check for conditions to set the Payeer Status
                        if(mapActiveContractABCs.get(mem.Active_Contract_Idenfied__c).Payer_Account__c != null 
                           && mapActiveContractABCs.get(mem.Active_Contract_Idenfied__c).Payer_Account__c == mem.Account_Name__c)
                        {
                            if(mapActiveContractABCs.get(mem.Active_Contract_Idenfied__c).Program__c != null 
                               && mapActiveContractABCs.get(mem.Active_Contract_Idenfied__c).Program__c == mem.Program__c)
                            	
                                PAYER_STATUS = Constants.PAYER;
                        	else
                            	PAYER_STATUS = Constants.PAYER_STATUS_INTEGRATED_GLOBAL;    
                        } else {
                            if((mapActiveContractABCs.get(mem.Active_Contract_Idenfied__c).Program__c != null && mem.Program__c ==  mapActiveContractABCs.get(mem.Active_Contract_Idenfied__c).Program__c))
                            	PAYER_STATUS = Constants.PAYER_STATUS_INTEGRATED;
                        }
                    }
                }
              
                mem.Payer_Status__c = PAYER_STATUS;
                
                if(String.isNotBlank(mem.Membership_Status_Text__c) && mem.Membership_Status_Text__c.equalsIgnoreCase('Prospect - Pending Future Start Date')){
                    mem.Membership_Status_Text__c = Constants.PROSPECT_PENDING_FUTURE_START_DATE;
                }
                membershipToBeUpdate.add(new Membership__c(Id = mem.Id , Payer_Status__c = PAYER_STATUS, Membership_Status_Text__c = mem.Membership_Status_Text__c));
            }
        }
        if(membershipToBeUpdate.size() > 0)
        {
            //Update the Membership
            Database.update(membershipToBeUpdate, false);
        }
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC) 
    {
        
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(csvString);
        string csvname= 'MembershipComparisionSheet.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {'mahendra.Swarnkar@fexle.com'};
        String subject = (Util.IS_PRODUCTION_INSTANCE ? 'Production :: ' : 'SandBox :: ') + 'Membership Comparision Sheet';
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('Hi, Please find the comparison list attached. Thanks! ');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}