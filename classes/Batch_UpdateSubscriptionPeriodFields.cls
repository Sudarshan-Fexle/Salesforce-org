/*
Purpose         :   Class to update Profit, Negotiated Amount (Components), Renewal Negotiated, Previous Period Negotiated (Components), Previous Period Negotiated

Create By       :   Mahendra Swarnkar

Created Date    :   07/13/2020

Revision Log    :   V1.0 Created


*/
global class Batch_UpdateSubscriptionPeriodFields implements Schedulable, Database.Batchable<SObject>, Database.Stateful {
    
    public String queryStr;
    public Set<Id> setContractIds;    
    
    //Default Constructor
    public Batch_UpdateSubscriptionPeriodFields() {}
    
    //Constructor
    public Batch_UpdateSubscriptionPeriodFields(Set<Id> setContractIds) {
        this.setContractIds = setContractIds;
    }
    
    //Batch Start Method
    global Database.Querylocator start(Database.BatchableContext BC) {
        
        if (String.isBlank(queryStr)) {
            queryStr = 'Select ID From Contract Where ID IN : setContractIds';
        }  
        
        //Retrieving and returning membership records
        return Database.getQueryLocator(queryStr);
    }
    
    //Batch Execute Method
    global void execute(Database.BatchableContext BC, List<Contract> scope) {
        
        //Check if list has 0 elements
        if(!scope.isEmpty()) {
        	
            //Map Subscriptions
            Map<Id, Subscription_Period__c> mapSPs = new Map<Id, Subscription_Period__c>();
            
            //Map to hold the SP Id with sum of customer amount on related component subscriptions (Product = Implementaion fee)
            Map<Id, Decimal> mapSPIdWithSumImplementationFee = new Map<Id, Decimal>();
            
            //Map Subscriptions to be updated 
            Map<Id, Subscription_Period__c> mapSPsToUodate = new Map<Id, Subscription_Period__c>();
            
            //Map to hold the Program Subscription with Pending Subscription Period calculations
            Map<Id, Decimal> mapProgramSubWithPendingProposalValue = new Map<Id,Decimal>();
            
            //Map to hold the greatest Segment Index on the Program Subscription
            Map<Id, Decimal> mapProSubWithGreatestSegmentIndex = new Map<Id, Decimal>();
            
            //Swet to hold the program Subscription Ids
            Set<Id> setProgSubscriptionIds = new set<Id>();
            
            //Get all the Subscription Periods and related component Subscriptions  related to contracts 
            for(Subscription_Period__c sp : [Select Id, Stage__c, Profit_Period__c, Negotiated_Amount_Period__c, Renewal_Negotiated__c, 
                                             	Previous_Period_Negotiated__c, Previous_Period_Negotiated_Components__c, Program_Subscription__c,
                                             	Program_Subscription__r.SBQQ__EndDate__c, Period_Start_Date__c, Status__c,Decision_Type__c,
                                             	Previous_Subscription_Period__c,
                                                ( Select Id, Profit_m__c, Customer_Amount__c, Product_Code__c,
                                                 	Program_Subscription__c, SBQQ__SegmentIndex__c, SBQQ__SegmentUplift__c
                                                  From Subscriptions__r where Customer_Amount__c != null AND Customer_Amount__c > 0 ORDER BY SBQQ__SegmentIndex__c DESC) 
                                             	From Subscription_Period__c Where Contract__c IN : scope]){
                
				//holds the sum of negotiated amount
                Decimal negotiatedAmountSum = 0;
                
				//holds the sum of Profit Amount
                Decimal profitAmountSum = 0;
                
				//holds the sum of customer amount on Implementation fee components 
                Decimal implementationFeeSum = 0;
                
				Boolean ischanged = false;
				                                 
				//Populate Program Subscription set
				if(sp.Previous_Subscription_Period__c == null && sp.Program_Subscription__c != null){
                	setProgSubscriptionIds.add(sp.Program_Subscription__c);
                }
				                                  
				//Check for Components
                if(sp.Subscriptions__r != null && sp.Subscriptions__r.size() > 0) {
                    
                    //Iterate over the child component subsccriptions
                    for(SBQQ__Subscription__c cSub : sp.Subscriptions__r){
                        
                        //Calculate negotiated amout
                        negotiatedAmountSum = negotiatedAmountSum + cSub.Customer_Amount__c ;
                        
                        //calculate Profit amount
                        profitAmountSum = profitAmountSum + (cSub.Profit_m__c != null ? cSub.Profit_m__c : 0);
                        
                        //check for Implementation components and calculate Implementation amount
                        if(cSub.Product_Code__c == 'ImplementationFee' || cSub.Product_Code__c == 'ImplementationFeeSS')
                        	implementationFeeSum = implementationFeeSum + cSub.Customer_Amount__c ;
                        
                        //Check Program Subscription in map if not in the map then Add it in map
                        if(!mapProSubWithGreatestSegmentIndex.containsKey(cSub.Program_Subscription__c)){ 
                            mapProSubWithGreatestSegmentIndex.put(cSub.Program_Subscription__c, cSub.SBQQ__SegmentIndex__c);
                            
                        }else{
                            
                            if(mapProSubWithGreatestSegmentIndex.get(cSub.Program_Subscription__c) < cSub.SBQQ__SegmentIndex__c)
                            {
                                mapProSubWithGreatestSegmentIndex.put(cSub.Program_Subscription__c, cSub.SBQQ__SegmentIndex__c);
                                mapProgramSubWithPendingProposalValue.put(cSub.Program_Subscription__c, 0);                                      
                            }
                        }
                        
                        if(mapProSubWithGreatestSegmentIndex.get(cSub.Program_Subscription__c) == cSub.SBQQ__SegmentIndex__c) {
                            
                            //Check for uplift
                            if(cSub.Customer_Amount__c != null && cSub.Customer_Amount__c > 0) {
                                
                                //Perform the calculation for negotiated amount period for Pending Sps
                                Decimal pendingNAPAmount = cSub.Customer_Amount__c;
                                
                                //Check for uplift
                                if(cSub.SBQQ__SegmentUplift__c != null && cSub.SBQQ__SegmentUplift__c > 0 )
                                	pendingNAPAmount = pendingNAPAmount + ((cSub.Customer_Amount__c * cSub.SBQQ__SegmentUplift__c)/100);
                                
                                if(pendingNAPAmount > 0) {
                                	
                                    if(!mapProgramSubWithPendingProposalValue.containsKey(cSub.Program_Subscription__c))
                                        mapProgramSubWithPendingProposalValue.put(cSub.Program_Subscription__c, 0);
                                    
                                    //Add overall NAP
                                    Decimal finalPendingNAPAmount = mapProgramSubWithPendingProposalValue.get(cSub.Program_Subscription__c) + pendingNAPAmount;
                                    
                                    //Add amount in map
                                    mapProgramSubWithPendingProposalValue.put(cSub.Program_Subscription__c, finalPendingNAPAmount);
                                }
                                
                            }
                        }   
                    }
                }
				
                // populate map
				if(implementationFeeSum > 0){
                    mapSPIdWithSumImplementationFee.put(sp.Id,implementationFeeSum);
                }
                
                //Populate Profit Amount
                if(profitAmountSum > 0 && sp.Profit_Period__c != profitAmountSum){
                    sp.Profit_Period__c = profitAmountSum;
                    ischanged = true;
                }
                
                if(negotiatedAmountSum > 0) {
                    
                	//Populate negotiatedd Amount Period for non - pending SPs
                    if(sp.Negotiated_Amount_Period__c != negotiatedAmountSum
						&& (sp.Stage__c != 'Pending' || (sp.Stage__c == 'Pending' && sp.Decision_Type__c != 'Need New LOA'))) {
                    
                        sp.Negotiated_Amount_Period__c = negotiatedAmountSum;
                        ischanged = true;
                    }
                    
                    //Populate Renewal Negotiated
                    if((sp.Renewal_Negotiated__c == null || sp.Renewal_Negotiated__c == 0)
						&& !(
                           	sp.Period_Start_Date__c != null && sp.Status__c == CPQConstants.SUBSCRIPTION_PERIOD_STAGE_PENDING
						    && sp.Program_Subscription__r.SBQQ__EndDate__c.daysBetween(sp.Period_Start_Date__c) == 1
						)
                      ) {
                        
                        sp.Renewal_Negotiated__c = negotiatedAmountSum;
                        ischanged = true;
                    }   
                }
				
				//Set the updated values in the Map
                mapSPs.put(sp.Id, sp);
				
				//Check for change and populate the map Sp to be update with respective updated field value on the SP.
                if(ischanged) {
                    
                	if(!mapSPsToUodate.containsKey(sp.Id))
                        mapSPsToUodate.put(sp.Id, new Subscription_Period__c(Id = sp.Id));
                    
                    mapSPsToUodate.get(sp.Id).Profit_Period__c = sp.Profit_Period__c;
					mapSPsToUodate.get(sp.Id).Negotiated_Amount_Period__c = sp.Negotiated_Amount_Period__c;
                    mapSPsToUodate.get(sp.Id).Renewal_Negotiated__c = sp.Renewal_Negotiated__c;
				}
				
            }
            
			//Map to hold the Contract ABC with Program Subscriptions
            Map<Id, Set<Id>> mapContractABCWithProgramSubs = new map<Id, Set<Id>>();
            
            //Map to hold the Program Subscription with Latest close Opportunity amount
            Map<Id, Decimal> mapProSubWithLatestOppAmount = new Map<Id, Decimal>();
            
			if(setProgSubscriptionIds.size() > 0) {
              
				//SOQL over the Program Subscriptions
				for(SBQQ__Subscription__c pS : [Select Id, Previous_Contract_ABC__c From SBQQ__Subscription__c Where Id IN : setProgSubscriptionIds AND Previous_Contract_ABC__c != null]) {
                    
                    //Check Contract ABC Id in map
                    if(!mapContractABCWithProgramSubs.containsKey(pS.Previous_Contract_ABC__c))
                        mapContractABCWithProgramSubs.put(pS.Previous_Contract_ABC__c, new Set<Id>());
                    
                    //Add Program Subscription in map
                    mapContractABCWithProgramSubs.get(pS.Previous_Contract_ABC__c).add(pS.Id);  
				}
                
              //Check for Contract ABC
              if(mapContractABCWithProgramSubs.size() > 0) {
                
                //SOQL on the Opportunity to get the latest opportunities for Contrat ABC
                for(Opportunity opp : [Select Id, Amount, Signed_Opportunity_Contract__c From Opportunity Where Signed_Opportunity_Contract__c IN : mapContractABCWithProgramSubs.keySet()
                                  AND ISWON = true AND ISCLOSED = true ORDER BY CloseDate DESC]) {
                                    
                  //Check Contract ABC in map
                  if(mapContractABCWithProgramSubs.get(opp.Signed_Opportunity_Contract__c) != null) {
                    
                    //Loop over the Program Subscription ids
                    for(Id pSId : mapContractABCWithProgramSubs.get(opp.Signed_Opportunity_Contract__c)){
                      
                      //Add Amount in map
                      mapProSubWithLatestOppAmount.put(pSId, opp.Amount);
                    }
                  }                    
                }
              }
            }
            
            //Loop2 over the Sps Key set to populate the other calculated field values
            for(Id spID : mapSPs.keySet()) {
                
                Boolean ischanged = false;
                
                //get Subscription period
                Subscription_Period__c sp = mapSPs.get(spID);
                
                //Populate the Negotiated Amount Period for Pending SPs
                if(sp.Stage__c == 'Pending' && sp.Decision_Type__c == 'Need New LOA' && sp.Program_Subscription__c != null 
					&& mapProgramSubWithPendingProposalValue.size() > 0 && mapProgramSubWithPendingProposalValue.containsKey(sp.Program_Subscription__c)
                  	&& mapProgramSubWithPendingProposalValue.get(sp.Program_Subscription__c) != null && mapProgramSubWithPendingProposalValue.get(sp.Program_Subscription__c) > 0) {
                    
                    ischanged = true;
                    
					//Populate the Negotiated_Amount_Period__c
					if(mapProgramSubWithPendingProposalValue.get(sp.Program_Subscription__c) != sp.Negotiated_Amount_Period__c){
                    	ischanged = true;
                        sp.Negotiated_Amount_Period__c = mapProgramSubWithPendingProposalValue.get(sp.Program_Subscription__c);
					}
                    
                    //Populate the Renewal_Negotiated__c
                    if((sp.Renewal_Negotiated__c == null || sp.Renewal_Negotiated__c == 0)
						&& !(
                           	sp.Period_Start_Date__c != null && sp.Status__c == CPQConstants.SUBSCRIPTION_PERIOD_STAGE_PENDING
							&& sp.Program_Subscription__r.SBQQ__EndDate__c.daysBetween(sp.Period_Start_Date__c) == 1
						)){
                        sp.Renewal_Negotiated__c = sp.Negotiated_Amount_Period__c;
						ischanged = true;
                    }
                }
                
                //Previous Subscription Period
                Subscription_Period__c previousSP;
                
                //Get Previous subscription period
                if(sp != null && sp.Previous_Subscription_Period__c != null && mapSPs.containsKey(sp.Previous_Subscription_Period__c)
                  	&& mapSPs.get(sp.Previous_Subscription_Period__c) != null ) {
                    
                    //Previous SP
                    previousSP = mapSPs.get(sp.Previous_Subscription_Period__c);
                
                    if(previousSP != null) {
                        
                        Decimal pPNegoAmount = previousSP.Renewal_Negotiated__c;
                        Decimal pPNegoAmountComponent = previousSP.Negotiated_Amount_Period__c;
                        
                        //calculate the Previous Period Negotiated and Previous Period Negotiated (Components) 
                        if(mapSPIdWithSumImplementationFee.size() > 0 && mapSPIdWithSumImplementationFee.containsKey(previousSP.Id)
                           && mapSPIdWithSumImplementationFee.get(previousSP.Id) != null && mapSPIdWithSumImplementationFee.get(previousSP.Id) > 0) {
                            pPNegoAmount = pPNegoAmount - mapSPIdWithSumImplementationFee.get(previousSP.Id);
                            pPNegoAmountComponent = pPNegoAmountComponent - mapSPIdWithSumImplementationFee.get(previousSP.Id);
                        }
                        
                        //Populate Previous Period Negotiated
                        if(pPNegoAmount > 0 && sp.Previous_Period_Negotiated__c != pPNegoAmount){
                            
                            sp.Previous_Period_Negotiated__c = pPNegoAmount;
                            ischanged = true;
                        }
                            
                        //Populate Previous Period Negotiated (Components)
                        if(pPNegoAmountComponent > 0 && sp.Previous_Period_Negotiated_Components__c != pPNegoAmountComponent){
                            
                            sp.Previous_Period_Negotiated_Components__c = pPNegoAmountComponent;
                            ischanged = true;
                        }
                    }
                } else if(sP.Previous_Subscription_Period__c == null && sP.Program_Subscription__c != null && mapProSubWithLatestOppAmount.containsKey(sP.Program_Subscription__c)
							&& sP.Previous_Period_Negotiated__c != mapProSubWithLatestOppAmount.get(sP.Program_Subscription__c)) {
                        
					//Update amount and add Sub Period to list
					sP.Previous_Period_Negotiated__c = mapProSubWithLatestOppAmount.get(sP.Program_Subscription__c);
                    sP.Previous_Period_Negotiated_Components__c = mapProSubWithLatestOppAmount.get(sP.Program_Subscription__c);
                    ischanged = true;
                }
                
                //Set the updated values in the Map
                mapSPs.put(spID, sp);
                
                //Check for change and populate the map Sp to be update with respective updated field value on the SP.
                if(ischanged) {
                    
                	if(!mapSPsToUodate.containsKey(sp.Id))
                        mapSPsToUodate.put(sp.Id, new Subscription_Period__c(Id = sp.Id));
                    
                    mapSPsToUodate.get(sp.Id).Previous_Period_Negotiated_Components__c = sp.Previous_Period_Negotiated_Components__c;
                    mapSPsToUodate.get(sp.Id).Previous_Period_Negotiated__c = sp.Previous_Period_Negotiated__c;
					mapSPsToUodate.get(sp.Id).Negotiated_Amount_Period__c = sp.Negotiated_Amount_Period__c;
                    mapSPsToUodate.get(sp.Id).Renewal_Negotiated__c = sp.Renewal_Negotiated__c;
				}
            }
            
            //update Subscription Periods.
            if(mapSPsToUodate.size() > 0 && mapSPsToUodate.values() != null && mapSPsToUodate.values().size() > 0) {                
                
                Util.BypassAllTriggers = true;
                Database.update(mapSPsToUodate.values(), false);
                Util.BypassAllTriggers = false;
            }   
        }
    }
    
    //Batch Finish method
    global void finish(Database.BatchableContext BC) {
        
    }
    
    //Scheduler Execute Method
    global void execute(SchedulableContext ctx) {
        // execute the job
        Batch_UpdateSubscriptionPeriodFields batch = new Batch_UpdateSubscriptionPeriodFields();
        batch.setContractIds = setContractIds;
        batch.queryStr = queryStr;
        Database.executeBatch(batch, 1);
    }
    
    //Method to schedule this Scheduler
    public static void scheduleSPFieldUpdate(Set<Id> setContractIds) {
        dateTime sysTime = dateTime.now().addMinutes(1);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        Batch_UpdateSubscriptionPeriodFields job = new Batch_UpdateSubscriptionPeriodFields(setContractIds);
        System.schedule('Batch_UpdateSubscriptionPeriodFields' + sysTime.getTime(),chron_exp, job);
    }
}