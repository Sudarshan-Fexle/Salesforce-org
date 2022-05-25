/**
 *  Description     :  Helper class for Product Trigger.
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  05/13/2017
 *
 *  Revision Logs   :   V_1.0 - Created By - Subhash Garhwal - CR-20170403-10807
 *		    		:   V_1.1 - Modified By - Victor Hanson - CR-20181208-12776 - added populateProductOnProgram
 *		    		:   V_1.2 - Modified By - Nikita Kumari - CR-20210910-15426 -  09/28/2021 - Added new Method validateProgramCodes
 *
**/
public without sharing class ProductTriggerHelper {
	
    /**
     *  @description    :   Populates the Product lookup on Program when Program lookup is populated.
     *
     *  @args           :   List<Product2>, Map<Id, Product2>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - CR-20170403-10807
     *
     **/
    public static void populateProductOnProgram(List<Product2> products, Map<Id, Product2> mapOldProducts) {
        //list of programs to update
        List<Program__c> programsToUpdate = new List<Program__c>();
        
        for (Product2 product : Products) {
            //get the old product
            Product2 oldProduct;
            if (mapOldProducts != null) {
                oldProduct = mapOldProducts.get(product.Id);
            }
            
            if (product.Program__c != null && (oldProduct == null || (oldProduct != null && oldProduct.Program__c != product.Program__c))) {
                programsToUpdate.add(new Program__c(Id = product.Program__c, Product__c = product.Id));
            }
        }
        
        //bypass triggers and update
        if (programsToUpdate.size() > 0) {
            util.bypassAllTriggers = true;
            update programsToUpdate;
            util.bypassAllTriggers = false;
        }
    }
    
    /**
     *  @description    :   This method is used to update the Sort Order on the Products as per shoring order.
     *						Sorting : Component (Component CB is true) --> Offer (Offer CB is true) --> Product (Component CB is false)
     *
     *  @args           :   List<Product2>, Map<Id, Product2>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - CR-20170403-10807
     *
     **/
	public static void validateShortOrder(List<Product2> products, Map<Id, Product2> mapOldProducts) {
		
		//Variable to check if need to execute Sort order logic or not
		Boolean isExecuteShortingOrder = false;
		
		//Loop over the Products
		for(Product2 pro : products != null ? products : mapOldProducts.values()) {
			
			//Check for insert/Update case
			if(products != null && (mapOldProducts == null || pro.SBQQ__Component__c != mapOldProducts.get(pro.Id).SBQQ__Component__c
				|| pro.Offer__c != mapOldProducts.get(pro.Id).Offer__c || pro.Family != mapOldProducts.get(pro.Id).Family)) {
					
				//Set Boolean
				isExecuteShortingOrder = true;
				
				break;
			}
			
			//Check for delete case
			if(products == null) {
				
				//Set Boolean
				isExecuteShortingOrder = true;
				
				break;
			}
		}
		
		//Check for variable
		if(isExecuteShortingOrder) {
			
			//List of Products to update
			List<Product2> productsToUpdate = new List<Product2>();
			
			//Interger to increase the counter
			Integer proOrder = 1;
			
			//Query through the Products
			for(Product2 pro : [Select Id, SBQQ__SortOrder__c, Sort_Order_Formula__c From Product2 ORDER BY Family ASC, Name ASC]) {
				
				//Check for Shore order
				if(pro.SBQQ__SortOrder__c != proOrder) {
					
					//Update the order
					pro.SBQQ__SortOrder__c = proOrder;
					
					//Add record in list
					productsToUpdate.add(pro);
				}
				
				//Increase counter
				proOrder++;
			}
			
			//Check for list size
			if(productsToUpdate.size() > 0) {
				
				//By Pass all the trigger
				Util.BypassAllTriggers = true;
				
				//Update
				update productsToUpdate;
				
				Util.BypassAllTriggers = false;
			}
		}
	}
    
    /**
     * 
     *  @description    :   validate the duplicate ProductCode for Insert and Update case
     *
     *  @args           :   List<Product2> products, Map<Id, Product2> mapOldProducts
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.0 - Created - 09/28/2021 - Nikita kumari - CR-20210910-15426 
     * 
     **/
    public static void validateProgramCodes(List<Product2> products, Map<Id, Product2> mapOldProducts){
        
        //Set to hold the ProductCode
        Set<String> setOfNewProductCode = new Set<String>();
        
        //populating the setOfNewProductCode
        for(Product2 pro : products) {
			
	    //Check for insert/Update case
	    if(String.isNotBlank(pro.ProductCode) && (mapOldProducts == null || pro.ProductCode != mapOldProducts.get(pro.Id).ProductCode)) {
                if(setOfNewProductCode.contains(pro.ProductCode)){
                    pro.addError(System.Label.ERROR_PRODUCT_DUPLICATE_PRODUCT_CODE);
            	}
            	else{
            		setOfNewProductCode.add(pro.ProductCode);
            	}    
	    }
    	}
        
        if(setOfNewProductCode.size() > 0){
            
            //Map to hold Exesting ProgramAcronyms with Program Id
            Map<String,Set<Id>> mapOfExestingProductCode = new Map<String,Set<Id>>();
            //populating the mapOfExestingProgramAcronyms
            for(Product2 product: [Select Id,ProductCode From Product2 Where ProductCode IN: setOfNewProductCode]){
            	if(!mapOfExestingProductCode.containsKey(product.ProductCode)){
                    mapOfExestingProductCode.put(product.ProductCode, new Set<Id>());
                }
                mapOfExestingProductCode.get(product.ProductCode).add(product.Id);
            }
            if(mapOfExestingProductCode.size()>0 && mapOfExestingProductCode.keySet().size()>0){
            	String baseUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/';
                String RecordLinks = '';
            	for(Product2 product : products){
                	if(mapOfExestingProductCode.containsKey(product.ProductCode)){
                    	    for(Id productId : mapOfExestingProductCode.get(product.ProductCode)){
                            	RecordLinks += baseUrl + productId + '; ';
                            }
                            RecordLinks = RecordLinks.removeEnd('; ');
                    	    product.addError(System.Label.ERROR_PRODUCT_DUPLICATE_PRODUCT_CODE_WITH_RECORDLINK + RecordLinks);
                	}
        	}
            }
        }  
    }
}