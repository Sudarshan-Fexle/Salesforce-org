global class Sched_validateUnitPriceWithCustomerPrice implements Schedulable {
    
    //Variables
    global Set<Id> setOpportunityProductIds;
    
    //Constructor
    global Sched_validateUnitPriceWithCustomerPrice() {
        setOpportunityProductIds = new Set<Id>();
    }
    
    global void execute(SchedulableContext ctx) {
        
        if(setOpportunityProductIds.size() > 0) 
            validateUnitPriceWithCustomerPriceFuture(setOpportunityProductIds);
    }
    
    public static void validateUnitPriceWithCustomerPriceFuture(set<Id> opportunityProducts) {
        
        //Check for size
        if(opportunityProducts != null && opportunityProducts.size() > 0){
        	
            //List to hold the Opportunity products
            List<OpportunityLineItem> listToUpdateOpportunityLineItem = new List<OpportunityLineItem>();
            
            //Loop over the Opportunity Product
            for(OpportunityLineItem oLI : [Select Id, TotalPrice, UnitPrice, Quantity, Customer_Price__c, SBQQ__QuoteLine__c from OpportunityLineItem where Id IN : opportunityProducts]) {
                
                //Check for Proposal Line
                if(oLI.SBQQ__QuoteLine__c != null ) {
                        
                    //Check for Total Price
                    if( oLI.TotalPrice != null && oLI.TotalPrice > 0 ) {
                        oLI.TotalPrice = oLI.Customer_Price__c * oLI.Quantity;
                    	listToUpdateOpportunityLineItem.add(oLI);
                    } //Check for unit price
                    else if( oLI.UnitPrice != null ){
                        oLI.UnitPrice = oLI.Customer_Price__c;
                    	listToUpdateOpportunityLineItem.add(oLI);
                    }
            	}
        	}
        	
            //Check for size & Update the opportunity Products
            if(listToUpdateOpportunityLineItem.size() > 0)
                update listToUpdateOpportunityLineItem;
        }
    }
}