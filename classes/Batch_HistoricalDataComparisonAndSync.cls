/**
 *	Description   :	Batch class to prepare the Historical Data comparison sheets and sync the data. 
 *					[Note]: Developers need to update the batch as per their need.
 *
 *	Created By    :	Subhash Garhwal
 *
 *	Created Date  : 09/28/2020
 *
 *	Revision Logs : V_1.0 - Created - CR-20200825-14471:
 *			Add step for historical data - Update any contract with Search - New Names, Inquiry Pool, Pre Names — old products (ESNN, ESIP, ESPN)
 *			or new (ESNNESYRS, ESIPESYRS, ESPNESYRS). Let’s run a script to pull the SPs and review in Full1 (add contract link, Id, SP link, product
 *			name, parent product name, existing quantity, proposed quantity etc.) before doing the update.
 *
 **/
global with sharing class Batch_HistoricalDataComparisonAndSync implements Database.Batchable<SObject>, Database.Stateful {
	
	//Comparison String
	//public String comparisonFileString = 'Contract Id, Contract, Program Subscription Id, Program Subscription, Product Id, Product Name, Parent Product Id, Parent Product Name, Proposed Product Id, Proposed Product Name \n';
	public String comparisonFileString = 'Subscription Period ID, SP Name , Institution ID, Institution Name, Contract Id, Program Subscription Id, OLD Total_Paper_only_Contract_Quantity, NEW Total_Paper_only_Contract_Quantity, OLD Total_e_only_Contract_Quantity, NEW Total_e_only_Contract_Quantity, OLD Total_Contract_Quantity, NEW Total_Contract_Quantity \n';
	
    	//Variable to control the comparison and update actions
	public Boolean isDataSync = false;
	
	//Constructor
	public Batch_HistoricalDataComparisonAndSync(Boolean isDataSync) {
		
		//Set value
		this.isDataSync = isDataSync;
	}
	
    	//Set to hold the existing Product codes
	Set<String> setProductCodes = new Set<String>{'ESNN', 'ESIP', 'ESPN','ESNNESYRS', 'ESIPESYRS', 'ESPNESYRS'};
    
	//Batch Start method
	global Database.queryLocator start(Database.BatchableContext ctx) {
		
		//SOQL over the Program Subscription
		//return Database.getQueryLocator([Select Id, Name, SBQQ__Contract__c, SBQQ__Contract__r.ContractNumber, SBQQ__Product__c, SBQQ__Product__r.Name, SBQQ__RequiredByProduct__c, SBQQ__RequiredByProduct__r.Name, Product_Code__c, SBQQ__RequiredByProduct__r.ProductCode From SBQQ__Subscription__c Where Product_Code__c IN : setExistingProductCodes AND SBQQ__RequiredByProduct__r.ProductCode IN : mapComparisionMapping.keySet()]);
		return Database.getQueryLocator([Select Id, SBQQ__Contract__c from  SBQQ__Subscription__c where SBQQ__RequiredByProduct__r.ProductCode = 'ESYRS'  AND SBQQ__Product__r.ProductCode IN : setProductCodes AND RecordTypeId =: CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM]);
	}
	
	//Execute Method
	global void execute(Database.BatchableContext ctx, List<SBQQ__Subscription__c> scope) {
        
        //Map to hold the Product Names with relate field names to update the Contracted Contact Qty field
        Map<String, Set<String>> mapProductsWithRelatedFields = CPQConstants.MAP_PRODUCTS_WITH_SUB_FIELD_DETAILS;
        
        //Map to hold the ROllup of the All Paper, E-only fields for New Names, Inquiry Pool and Pre Names
        Map<String, Decimal> mapPaperAndEOnlyFieldsRollupsWithESYRSProduct = new Map<String,Decimal>();
        
        //Map to hold the ESYRS related SubscriptionPeriods Details
        Map<String, Id> mapSubscriptionPeriodsWithESYRSProduct = new Map<String, Id>();
        
        Map<String, Id> mapSubscriptionPeriodsWithPreInquiryESYRSProduct = new Map<String, Id>();
        
        
        //Map to update the Subscription Periods
        Map<Id, Subscription_Period__c> mapSubscriptionPeriods = new Map<Id, Subscription_Period__c>();
        Map<Id, Subscription_Period__c> mapOldSubscriptionPeriods = new Map<Id, Subscription_Period__c>();
        
        Map<Id, String> mapAccountWithName = new Map<Id, String>();
        
        //SOQL over the Component Subscription
        for(SBQQ__Subscription__c compSub : [Select Id, Subscription_Period__c, Subscription_Period__r.Period_Start_Date__c, Subscription_Period__r.Name, 
                                             Subscription_Period__r.Total_Contract_Quantity__c, Subscription_Period__r.Total_e_only_Contract_Quantity__c, 
                                             Subscription_Period__r.Total_Paper_only_Contract_Quantity__c, 
                                             Subscription_Period__r.Contract__c, Subscription_Period__r.Contract__r.ContractNumber,
                                             Subscription_Period__r.Institution__c, Subscription_Period__r.Institution__r.Name,
                                             Subscription_Period__r.Program_Subscription__c, Subscription_Period__r.Program_Subscription__r.Name,
                                             Paper_New_Names_m__c, E_Only_New_Names_m__c, Paper_Inquiry_Pool_m__c,
                                             E_Only_Inquiry_Pool_m__c, Paper_PRE_Names_m__c, E_Only_PRE_Names_m__c, Related_Product__c,
                                             Paper_Quantity_Fulfillment_m__c, E_Only_Quantity_Fulfillment_m__c, SBQQ__Quantity__c,
                                             Paper_Transfer_Marketing_m__c, E_Only_Transfer_Marketing_m__c, Program_Subscription__r.SBQQ__ProductName__c,
                                             Program_Subscription__r.Program_Subscription__r.Product_Code__c, SBQQ__ProductName__c,
                                             Program_Subscription__r.SBQQ__Product__r.ProductCode,
                                             Media_Costs_m__c, Postage_Costs_m__c, SBQQ__ListPrice__c, SBQQ__CustomerPrice__c, E_Only_Client_Provided_Inquiries_m__c,
                                             E_Only_EAB_Generated_Inquiries_m__c, Paper_Client_Provided_Inquiries_m__c, Paper_EAB_Generated_Inquiries_m__c
                                             FROM SBQQ__Subscription__c
                                             WHERE Program_Subscription__c != null AND Program_Subscription__c IN : scope 
                                             AND Program_Subscription__r.SBQQ__RequiredByProduct__c != null AND Program_Subscription__r.SBQQ__RequiredByProduct__r.ProductCode = 'ESYRS'  
                                             AND Program_Subscription__r.SBQQ__Product__c != null AND Program_Subscription__r.SBQQ__Product__r.ProductCode IN : setProductCodes
                                             //AND SBQQ__Contract__c IN : setContractIds 
                                             AND Subscription_Period__c != null
                                             AND Status__c != 'Void-Amended'
                                             AND RecordTypeId =: CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT
                                             AND Subscription_Period__r.Institution__c NOT IN ('001C000001WXl3rIAD', '001C000001eEDgPIAW', '0010v00000XKOY6AAP')]) 
		{
            
            //Check Subscription Period in map
            if(!mapOldSubscriptionPeriods.containsKey(compSub.Subscription_Period__c))
                mapOldSubscriptionPeriods.put(compSub.Subscription_Period__c, new Subscription_Period__c(Id = compSub.Subscription_Period__c, Total_Contract_Quantity__c = compSub.Subscription_Period__r.Total_Contract_Quantity__c,
                                                                                                         Total_e_only_Contract_Quantity__c = compSub.Subscription_Period__r.Total_e_only_Contract_Quantity__c,
                                                                                                         Total_Paper_only_Contract_Quantity__c = compSub.Subscription_Period__r.Total_Paper_only_Contract_Quantity__c,
                                                                                                        Contract__c = compSub.Subscription_Period__r.Contract__c, 
                                                                                                        Institution__c = compSub.Subscription_Period__r.Institution__c,
                                                                                                        Program_Subscription__c = compSub.Subscription_Period__r.Program_Subscription__c, 
                                                                                                        Name = compSub.Subscription_Period__r.Name));
            if(!mapAccountWithName.containsKey(compSub.Subscription_Period__c))
                mapAccountWithName.put(compSub.Subscription_Period__r.Institution__c, compSub.Subscription_Period__r.Institution__r.Name);
            
            //Check Subscription Period in map
            if(!mapSubscriptionPeriods.containsKey(compSub.Subscription_Period__c))
                mapSubscriptionPeriods.put(compSub.Subscription_Period__c, new Subscription_Period__c(Id = compSub.Subscription_Period__c, Total_Contract_Quantity__c = 0,Total_e_only_Contract_Quantity__c = 0, 
                                                                                                      Total_Paper_only_Contract_Quantity__c = 0));
            
            //Check Product in map
            if(mapProductsWithRelatedFields.containsKey(compSub.Program_Subscription__r.SBQQ__ProductName__c)) {
                
                //Loop over the fields
                for(String productSpecField : mapProductsWithRelatedFields.get(compSub.Program_Subscription__r.SBQQ__ProductName__c)) { 
                    
                    //Check for ESYRS Product
                    if(compSub.Program_Subscription__r.Program_Subscription__c != null && compSub.Program_Subscription__r.Program_Subscription__r.Product_Code__c == 'ESYRS'
                       && (CPQConstants.SET_ESYRS_SUB_PRODUCTS.contains(compSub.Program_Subscription__r.SBQQ__ProductName__c) || setProductCodes.contains(compSub.Program_Subscription__r.SBQQ__Product__r.ProductCode))) 
                    {
                           
                           //Unique Key to add the details in map
                           String eSYRSWithYear = compSub.Program_Subscription__r.Program_Subscription__c + compSub.Program_Subscription__r.Program_Subscription__r.Product_Code__c + '-' + compSub.Subscription_Period__r.Period_Start_Date__c;
                           
                           //Check value in map	
                           if(!mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.containsKey(eSYRSWithYear + ' - PaperOnly'))
                               mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.put(eSYRSWithYear + ' - PaperOnly',0);
                           
                           //Check value in map
                           if(!mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.containsKey(eSYRSWithYear + ' - EOnly'))
                               mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.put(eSYRSWithYear + ' - EOnly',0);
                           
                           //Check for field value
                           if(CPQConstants.PAPER_ONLY_FIELDS.contains(productSpecField) && compSub.get(productSpecField) != null)
                               mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.put(eSYRSWithYear + ' - PaperOnly', mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.get(eSYRSWithYear + ' - PaperOnly') + ((Decimal) compSub.get(productSpecField) * (Decimal) compSub.get('SBQQ__Quantity__c')));
                           
                           //Check for field value
                           if(CPQConstants.E_ONLY_FIELDS.contains(productSpecField) && compSub.get(productSpecField) != null)
                               mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.put(eSYRSWithYear + ' - EOnly', mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.get(eSYRSWithYear + ' - EOnly') + ((Decimal) compSub.get(productSpecField) * (Decimal) compSub.get('SBQQ__Quantity__c')));
                           
                           //Check for Sub Product
			   if(compSub.Program_Subscription__r.SBQQ__ProductName__c == 'New Names – Search' || compSub.Program_Subscription__r.SBQQ__ProductName__c == 'New Names'){
                               mapSubscriptionPeriodsWithESYRSProduct.put(eSYRSWithYear, compSub.Subscription_Period__c);
                    	}
					}
                }
            }
        }
        
        //Loop over the ESYRS Specific Products
        for(String eSYRSProd : mapSubscriptionPeriodsWithESYRSProduct.keySet()) {
            
            //Instance of the Subscription Period
            Subscription_Period__c sP = new Subscription_Period__c(Id = mapSubscriptionPeriodsWithESYRSProduct.get(eSYRSProd));
            
            //Check if map already contansSP to update
            if(mapSubscriptionPeriods.containsKey(mapSubscriptionPeriodsWithESYRSProduct.get(eSYRSProd)))
                sP = mapSubscriptionPeriods.get(mapSubscriptionPeriodsWithESYRSProduct.get(eSYRSProd));
            
            //Set Paper only quantity
            if(mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.containsKey(eSYRSProd + ' - PaperOnly')) {
                
                //Set Paper field value
                sP.Total_Paper_only_Contract_Quantity__c = mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.get(eSYRSProd + ' - PaperOnly');
                sP.Total_Contract_Quantity__c += mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.get(eSYRSProd + ' - PaperOnly');
            }
            
            //Set E-Only only quantity
            if(mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.containsKey(eSYRSProd + ' - EOnly')) {
                
                //Set Paper field value
                sP.Total_e_only_Contract_Quantity__c = mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.get(eSYRSProd + ' - EOnly');
                sP.Total_Contract_Quantity__c += mapPaperAndEOnlyFieldsRollupsWithESYRSProduct.get(eSYRSProd + ' - EOnly');
            }
            //Put SP in Map to update
            mapSubscriptionPeriods.put(sP.Id, sP);
        }
        
        //Loop over the ESYRS Specific Products
        for(Id sPId : mapSubscriptionPeriods.keySet()) {
            
            Subscription_Period__c sP = mapSubscriptionPeriods.get(sPId);
            Subscription_Period__c sPOld;
            
            //Get Old SP details 
            if(mapOldSubscriptionPeriods.containsKey(sP.Id))
            	sPOld = mapOldSubscriptionPeriods.get(sP.Id);
            
            comparisonFileString = comparisonFileString + sP.Id + ', ' + sPOld.Name + ', ' + sPOld.Institution__c+ ', ' + mapAccountWithName.get(sPOld.Institution__c) + ', ' + sPOld.Contract__c + ', ' + sPOld.Program_Subscription__c + ', ' + sPOld.Total_Paper_only_Contract_Quantity__c + ', ' + sP.Total_Paper_only_Contract_Quantity__c + ', ' + sPOld.Total_e_only_Contract_Quantity__c + ', ' + sP.Total_e_only_Contract_Quantity__c + ', ' + sPOld.Total_Contract_Quantity__c + ', ' + sP.Total_Contract_Quantity__c + ' \n';
        }
        
        //Check if data need to update or not
        if(isDataSync && mapSubscriptionPeriods.size() > 0) {
            
            update mapSubscriptionPeriods.values();
        }
			
	}
    
    global void finish(Database.BatchableContext ctx){
    	
    	if(isDataSync == false) {
    		
    		//Comparison File
	    	Messaging.EmailFileAttachment subsComparisonFile = new Messaging.EmailFileAttachment();
	    	
	    	//Prepare the file data
	    	Blob subComparisonFileContent = Blob.valueOf(comparisonFileString);
			string csvname= 'SubscriptionPeriodQuantityFieldUpdate.csv';
			subsComparisonFile.setFileName(csvname);
			subsComparisonFile.setBody(subComparisonFileContent);
			
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			//String[] toAddresses = new List<string> {'Mahendra.Swarnkar@fexle.com', 'kbaluja@eab.com'};
			String[] toAddresses = new List<string> {'Mahendra.Swarnkar@fexle.com'};
			String subject ='Subscription Period Comparison File For Quantity Field Update';
			email.setSubject(subject);
			email.setToAddresses( toAddresses );
			email.setPlainTextBody('Hi , Please find the attached File. Thanks! ');
			email.setFileAttachments(new Messaging.EmailFileAttachment[] {subsComparisonFile});
			Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});	
    	}
    }
}