/**
*  Description     :  Batch class to update TopParentProduct field on proposal line.
*
*  Created By      :  Mahendra Swarnkar
*
*  Created Date    :  09/17/2019
*
*/
global class Batch_DataUpdatePopulateParentProduct implements Database.Batchable<SObject>, Database.Stateful  {
    
    public string query;
    
    //Start Method
    global Database.Querylocator start(Database.BatchableContext BC) {
        String batchQuery;
        
        if(String.isNotBlank(query))
        	batchQuery = query;
        else
            batchQuery = 'Select Id, SBQQ__Quote__c, SBQQ__RequiredBy__c, Top_Parent_Product__c, Related_Product_with_Parent_Product__c,' 
            			+ 'SBQQ__Product__c, SBQQ__Product__r.Name, SBQQ__Product__r.Parent_Product__c,Opportunity_Contracted__c, SBQQ__RequiredBy__r.Top_Parent_Product__c' 
						+ ' FROM SBQQ__QuoteLine__c ' 
            			+ 'WHERE ( '
            			//+ ' SBQQ__Product__r.name = \'Transfer Recruitment\' OR '
            			+         ' Related_Product_with_Parent_Product__c IN (\'ESXFRR\', \'ESXFR - ESXFRR\', \'ESCXFR - ESXFRR\', \'ESTDIQ - ESXFRR\' ) '
            			+        ' ) '
            			+ 'AND Top_Parent_Product__c = \'01tC0000002r1Ho\' ORDER BY SBQQ__Quote__c ASC, Name ASC ';
        
		return Database.getQueryLocator(batchQuery);
    }
    
    //Execute Method
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        
        //Map to hold the proposal Id with map of all of its child proposal lines
        Map<Id, Map<Id,SBQQ__QuoteLine__c>> mapProposalIdwithProposalLines = new Map<Id, Map<Id,SBQQ__QuoteLine__c>>();
        
        for(SBQQ__QuoteLine__c qline : (List<SBQQ__QuoteLine__c>) scope){

            mapProposalIdwithProposalLines.put(qline.SBQQ__Quote__c, new Map<Id, SBQQ__QuoteLine__c>());
        }

        //Chek for size
        if(mapProposalIdwithProposalLines.size() > 0){
        	
        	//MAp Proposal lines to be updated
        	Map<Id, SBQQ__QuoteLine__c> mapQuotelinesToBeUpdate = new Map<Id, SBQQ__QuoteLine__c>();
        	
        	//MAp parent line with list of child lines	
        	Map<Id, List<SBQQ__QuoteLine__c>> mapParentQuotelineWithChildQuotelines = new Map<Id, List<SBQQ__QuoteLine__c>>();
        	 
        	//Query all the proposal lines related to the quotelines
        	for(SBQQ__QuoteLine__c propLine : [Select Id, SBQQ__Quote__c, SBQQ__RequiredBy__c, Opportunity_Contracted__c, Top_Parent_Product__c, SBQQ__Product__c, SBQQ__Product__r.Parent_Product__c, SBQQ__RequiredBy__r.Top_Parent_Product__c From SBQQ__QuoteLine__c Where SBQQ__Quote__c IN : mapProposalIdwithProposalLines.keyset() ORDER BY SBQQ__Quote__c Desc, Name Asc ]) {
                
                //populate the top parent product field value for Main proposal lines
				if(propLine.SBQQ__RequiredBy__c == null) { 
					
					//check  for Product
					if(propLine.SBQQ__Product__c != null ){
					
						//If product have the parent product then populate top parent with parent product
						if(propLine.SBQQ__Product__r.Parent_Product__c != null && propLine.Top_Parent_Product__c != propLine.SBQQ__Product__r.Parent_Product__c){
							
							propLine.Top_Parent_Product__c = propLine.SBQQ__Product__r.Parent_Product__c;
							mapQuotelinesToBeUpdate.put(propLine.Id, propLine);	
						} else  if(propLine.SBQQ__Product__r.Parent_Product__c == null){
							
							//if product not have the parent product then populate the top parent product with the product it self
							if(propLine.Top_Parent_Product__c != propLine.SBQQ__Product__c) {
							
								propLine.Top_Parent_Product__c = propLine.SBQQ__Product__c;
								mapQuotelinesToBeUpdate.put(propLine.Id, propLine);	
							}
						}
                        
					} else {
						
                        // if product is not populated on the quoteline then Top_Parent_Product__c is blank
						if(propLine.Top_Parent_Product__c != null){
						
							propLine.Top_Parent_Product__c = null;
							mapQuotelinesToBeUpdate.put(propLine.Id, propLine);
						}	
					}
				}
				
				//Populate the map parent lines with list of child lines
				if(propLine.SBQQ__RequiredBy__c != null ) {
					
                    if(propLine.SBQQ__Product__r.Parent_Product__c != null && propLine.Top_Parent_Product__c != propLine.SBQQ__Product__r.Parent_Product__c ){
                        
                        propLine.Top_Parent_Product__c = propLine.SBQQ__Product__r.Parent_Product__c;
						mapQuotelinesToBeUpdate.put(propLine.Id, propLine);	
                    } 
                    
                    if (propLine.SBQQ__Product__r.Parent_Product__c == null){
                     
                        if (mapQuotelinesToBeUpdate.containsKey(propLine.SBQQ__RequiredBy__c) 
                            && mapQuotelinesToBeUpdate.get(propLine.SBQQ__RequiredBy__c) != null 
                            && mapQuotelinesToBeUpdate.get(propLine.SBQQ__RequiredBy__c).Top_Parent_Product__c != null 
                            && propLine.Top_Parent_Product__c != mapQuotelinesToBeUpdate.get(propLine.SBQQ__RequiredBy__c).Top_Parent_Product__c ) 
                        {
                            propLine.Top_Parent_Product__c = mapQuotelinesToBeUpdate.get(propLine.SBQQ__RequiredBy__c).Top_Parent_Product__c;
                            mapQuotelinesToBeUpdate.put(propLine.Id, propLine);
                        
                        } 
                        else {
                            
                            if(propLine.SBQQ__RequiredBy__r.Top_Parent_Product__c != null && propLine.Top_Parent_Product__c != propLine.SBQQ__RequiredBy__r.Top_Parent_Product__c) {
                                
                                propLine.Top_Parent_Product__c = propLine.SBQQ__RequiredBy__r.Top_Parent_Product__c;
                                mapQuotelinesToBeUpdate.put(propLine.Id, propLine);
                            }
                        }
                    }
                    
					if(!mapParentQuotelineWithChildQuotelines.containsKey(propLine.SBQQ__RequiredBy__c))
						mapParentQuotelineWithChildQuotelines.put(propLine.SBQQ__RequiredBy__c, new List<SBQQ__QuoteLine__c>());
					
					mapParentQuotelineWithChildQuotelines.get(propLine.SBQQ__RequiredBy__c).add(propLine);
				}
				
				//Popuate the map proposal with all relatd child proposal lines
                if(mapProposalIdwithProposalLines.containsKey(propLine.SBQQ__Quote__c)
                	&& mapProposalIdwithProposalLines.get(propLine.SBQQ__Quote__c).size() > 0
                	&& !mapProposalIdwithProposalLines.get(propLine.SBQQ__Quote__c).containsKey(propLine.Id))	
					mapProposalIdwithProposalLines.get(propLine.SBQQ__Quote__c).put(propLine.Id, propLine);
        	}

        	//Check for size
        	if(mapParentQuotelineWithChildQuotelines.size() > 0){
        		
        		//Loop over the parent quoteline Ids
        		for(Id parentQuoteline : mapParentQuotelineWithChildQuotelines.keySet()){
        			
        			//method call to populate the top parent product on child lines
        			mapQuotelinesToBeUpdate = SBQQ_QuoteLineTriggerHelper.populateTopParentProductOnChildQuoteLines(mapParentQuotelineWithChildQuotelines, mapParentQuotelineWithChildQuotelines.get(parentQuoteline), mapQuotelinesToBeUpdate, mapProposalIdwithProposalLines);	
        		}
        		

        		
        		//update the quotelines
        		if(mapQuotelinesToBeUpdate.size() > 0){
        			
        			//Bypass all the triggers
    				Util.bypassAllTriggers = true;
    				
    				//Update the proposal records 
    				Database.update(mapQuotelinesToBeUpdate.values(),false);
    				
    				//Enable all the triggers.
    				Util.bypassAllTriggers = false;
        		}        		
        	}
        }
        
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC) {
    }
}