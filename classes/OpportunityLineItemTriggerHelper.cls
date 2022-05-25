/**
 *  Description     :  Helper class for OpportunityLineItemTrigger trigger.
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  06/29/2016
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
 *						V_1.1 - Modified - Subhash Garhwal - Added a new method "validateUnitPriceWithCustomerPrice"
 *
 **/
public without sharing class OpportunityLineItemTriggerHelper {
    
    //Variable to control the trigger execution
    public static Boolean isExecuteProgramOppSync = true;
    
    /**
     *  @description    :   This method is used to create Program Opportunity Under the parent Opportunity record, Parent is renewal opp
     *
     *                      Details form WORK ORDER (Process): 
     *                      Use Case#: 3.02 (UC - Use Cases - CPQ Wave 1 v0.3)
     *
     *  @args           :   List<OpportunityLineItem>,
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 06/29/2016 - Created - Subhash Garhwal - CR-20160414-9762
     *
     **/
    /*public static void syncProgramOpportunities(List<OpportunityLineItem> opportunityLineItems) {
        
        //Map to hold the list of OpportunityLineItems with unique Identifier (Parent Opportunity + Program)
        Map<String, List<OpportunityLineItem>> mapUniqueIdentifierWithOppLineItems = new Map<String, List<OpportunityLineItem>>();
        
        //Set to hold the Opportunity Ids
        Set<Id> setParentOppIds = new Set<Id>();
        
        //Set to hold the Program Ids
        Set<Id> setProgramIds = new Set<Id>();
        
        //Query through OpportunityLineItem
        for(OpportunityLineItem oLI : [Select Id, OpportunityId, Opportunity.SBQQ__Renewal__c, Opportunity.AccountId, Opportunity.CloseDate,
                                              Opportunity.OwnerId, Product2Id, Product2.Program__c, Product2.Program__r.Business_line__c,Product2.Program_or_Component__c From OpportunityLineItem
                                              Where Id IN : opportunityLineItems AND Opportunity.SBQQ__Renewal__c = true AND
                                              Opportunity.RecordType.DeveloperName =: CPQConstants.OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_CONTRACT_LOA
                                              AND Product2.Program_or_Component__c IN : CPQConstants.SET_QUOTE_LINE_PROGRAM_IDENTIFIERS]) {
                                                
            //Create unique key
            String uK = oLI.OpportunityId + '-' + oLI.Product2.Program__c;
            
            //Check key in map
            if(!mapUniqueIdentifierWithOppLineItems.containsKey(uK))
                mapUniqueIdentifierWithOppLineItems.put(uK, new List<OpportunityLineItem>());
            
            //Add line itm in map
            mapUniqueIdentifierWithOppLineItems.get(uK).add(oLI);
            
            //Populate Opp and Program Id set
            setParentOppIds.add(oLI.OpportunityId);
            setProgramIds.add(oLI.Product2.Program__c);                                         
        }
        
        //Check for map size
        if(mapUniqueIdentifierWithOppLineItems.size() > 0) {
            
            //Query through the existing Program Opportunities to remove duplicate creating of Program Opps
            for(Opportunity opp : [Select Id, Parent_Opportunity__c, Program__c From Opportunity Where Parent_Opportunity__c IN : setParentOppIds
                                          AND Program__c IN : setProgramIds]) {
                //Create unique key
                String uK = opp.Parent_Opportunity__c + '-' + opp.Program__c;
                
                //Check if map contains the uniqye key
                if(mapUniqueIdentifierWithOppLineItems.containsKey(uK))
                    mapUniqueIdentifierWithOppLineItems.remove(uK);         
            }
            
            //List to insert Program Opportunities
            List<Opportunity> programOpportunities = new List<Opportunity>();
            
            //Get Opportunity record types
            Map<String, Id> mapOppRecordType = Util.recordtypemap('Opportunity');
            
            //Loop over the mapUniqueIdentifierWithOppLineItems key Set to create Program Opportunities
            for(String uK : mapUniqueIdentifierWithOppLineItems.keySet()) {
                
                //Loop over the related OpportunityLineItems
                for(OpportunityLineItem oLI : mapUniqueIdentifierWithOppLineItems.get(uK)) {
                    
                    //Instance of Program Opportunity
                    Opportunity opp = new Opportunity();
                    
                    //Set field values
                    opp.Name = 'Will auto populate';
                    opp.Amount = 0;
                    opp.OwnerId = oLI.Opportunity.OwnerId;
                    opp.AccountId = oLI.Opportunity.AccountId;
                    opp.Probability = 0;
                    opp.StageName = CPQConstants.OPPORTUNITY_STAGE_PENDING;
                    opp.Source_Stage__c = CPQConstants.OPPORTUNITY_SOURCE_STAGE_RENEWAL;
                    opp.Parent_Opportunity__c = oLI.OpportunityId;
                    opp.Program__c = oLI.Product2.Program__c;
                    opp.CloseDate = oLI.Opportunity.CloseDate;
                    
                    //Set Record Type
                    if(oLI.Product2.Program_or_Component__c != null && CPQConstants.MAP_PROGRAM_TYPE_WITH_RENEWAL_RECORDTYPE_DEVELOPERNAME.containsKey(oLI.Product2.Program_or_Component__c)
                        && mapOppRecordType.containsKey(CPQConstants.MAP_PROGRAM_TYPE_WITH_RENEWAL_RECORDTYPE_DEVELOPERNAME.get(oLI.Product2.Program_or_Component__c)))
                        opp.RecordTypeId = mapOppRecordType.get(CPQConstants.MAP_PROGRAM_TYPE_WITH_RENEWAL_RECORDTYPE_DEVELOPERNAME.get(oLI.Product2.Program_or_Component__c));
                    
                    //Add Program Opp in list
                    programOpportunities.add(opp);
                    
                    break;
                }
            }
            
            //Check for Program Opportunity list size
            if(programOpportunities.size() > 0) {
                
                OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
                OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
                
                insert programOpportunities;
                
                OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
                OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
            }
                
        } 
    }*/
    
    /**
     *  @description    :   This method is used to set the UnitPrice on the Opportunity Product according to related Proposal Line Customer Price
     *
     *
     *  @args           :   List<OpportunityLineItem>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 09/17/2019 - Created - Subhash Garhwal
     * 						V_1.1 - 10/01/2019 - Modified - Subhash Garhwal	- CR-20191001-13386
     *
     **/
	public static void validateUnitPriceWithCustomerPrice(List<OpportunityLineItem> opportunityProducts, Map<Id, OpportunityLineItem> mapOldopportunityProducts) {
		//system.assert(false,'opportunityProducts');
        Set<Id> setOpportunityProductIds = new Set<Id>();
        
        //New list of opprtunityLine Item to update.
        List<OpportunityLineItem> oppListItems = new List<OpportunityLineItem>();
        
		//Loop over the Opportunity Product
		for(OpportunityLineItem oLI : opportunityProducts) {
			
			//Check for Proposal Line
			if(oLI.SBQQ__QuoteLine__c != null ) {
				
                if(mapOldopportunityProducts != null) {
                    
                    setOpportunityProductIds.add(oLI.Id);
                
                } else if(mapOldopportunityProducts == null) {
                	OpportunityLineItem oppLI = new OpportunityLineItem();
                    
                    setOpportunityProductIds.add(oLI.Id);
                    System.debug('@@@@@@@@@ oLI.TotalPrice ' + oLI.TotalPrice + ' #### oLI.UnitPrice ' + oLI.UnitPrice + ' $$$$$$$ oLI.Customer_Price__c' + oLI.Customer_Price__c);
                    //Check for Total Price
                    /*if( oLI.TotalPrice != null && oLI.TotalPrice > 0 ) {
                        oLI.TotalPrice = oLI.Customer_Price__c * oLI.Quantity;
                        //oppLI.Id = oLI.Id;
                        //oppLI.TotalPrice = oLI.Customer_Price__c * oLI.Quantity;
                        //oppListItems.add(oppLI);
                    } else if( oLI.UnitPrice != null ){
                        oLI.UnitPrice = oLI.Customer_Price__c;
                        //oppLI.Id = oLI.Id;
                        //oppLI.UnitPrice = oLI.Customer_Price__c;
                        //oppListItems.add(oppLI);
                    }*/
                }
			}
		}
        
        //if(oppListItems.size() > 0)
            //update oppListItems;
        
        if(setOpportunityProductIds.size() > 0 && !System.isScheduled()){
            
            dateTime sysTime = dateTime.now().addMinutes(5);
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            Sched_validateUnitPriceWithCustomerPrice job = new Sched_validateUnitPriceWithCustomerPrice();
            job.setOpportunityProductIds = setOpportunityProductIds;
    
            System.schedule('Sched_validateUnitPriceWithCustomerPrice' + sysTime.getTime(), chron_exp, job);
        }
	}
}