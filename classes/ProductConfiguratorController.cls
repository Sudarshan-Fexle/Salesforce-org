/**
*  Description     :	Helper class for SBQQ_QuoteLineTrigger trigger.
*
*  Created By      :  	Victor Hanson
*
*  Created Date    :  
*
*  Revision Logs   :	V1.0 - Created - Victor Hanson - CR-20181019-12685
*			V1.1 - Modified - Subhash Garhwal - 03/07/2019 - CR-20181019-12685 - Modified calls to add order of the products and apply product selection validations.						
*			V1.2 - Modified - Subhash Garhwal - 09/27/2019 - CR-20190911-13329
*			V1.3 - Modified - Subhash Garhwal - 09/25/2010 - CR-20200922-14545
*			V1.4 - Modified - Victor Hanson - 10/27/2020 - CR-20201013-14598 - Updated to include cappex reminder before save
*			V1.5 - Modified - Subhash - CR-20201106-14674 - 11/10/2020 - Added Check so that it can also consider the subproducts without questions in the comparision
*		        V1.6 - Modified - Subhash Garhwal - CR-20210421-15094 - 5/3/2021
*			V1.7 - Modified - Subhash Garhwal - CR-20210521-15173 - 03/16/2021
**/
global class ProductConfiguratorController {
    
    global ProductConfiguratorController() {
        
    }
    
    //return a list of attributes for a single product (used on the custom configurator page)
    @RemoteAction
    global static List<CustomAttribute> getConfigurationAttributes(String productId) {
        if(String.isNotBlank(productId))
        	return getConfigurationAttributes(new Set<Id>{ productId }).get(productId);
        else
           return  (new List<CustomAttribute>());
        
    }
    
    //returns all configuration attributes for a set of products
    global static Map<Id, List<CustomAttribute>> getConfigurationAttributes(Set<Id> productId) {
        
        //Map to hold the Custom attributes with Product
        Map<Id, List<CustomAttribute>> customAttributeMap = new Map<Id, List<CustomAttribute>>();
        
        /**************    Subhash garhwal - 01/08/2018 - Added code to display Product in specific order      *************/
        //Map to hold the Product Option Ids with Product
        Map<Id, List<Id>> mapProductWithProductOptionProducts = new Map<Id, List<Id>>();
        
        //Main Product Attributes with Main Product Id
        Map<Id, List<SBQQ__ConfigurationAttribute__c>> mapMainProductAttributes = new Map<Id, List<SBQQ__ConfigurationAttribute__c>>();
        
        
        //SOQL over the Product Options
        for(SBQQ__ProductOption__c proOption : [Select Id, SBQQ__OptionalSKU__c, SBQQ__Feature__c, SBQQ__ConfiguredSKU__c, SBQQ__Number__c From SBQQ__ProductOption__c
                                                              Where SBQQ__ConfiguredSKU__c IN : productId AND SBQQ__OptionalSKU__c != null ORDER BY SBQQ__Number__c ASC]) {
            
            //Check Product Id in map
            if(!mapProductWithProductOptionProducts.containsKey(proOption.SBQQ__ConfiguredSKU__c))
                mapProductWithProductOptionProducts.put(proOption.SBQQ__ConfiguredSKU__c, new List<Id>());
            
            //Add Product Option in list
            mapProductWithProductOptionProducts.get(proOption.SBQQ__ConfiguredSKU__c).add(proOption.SBQQ__OptionalSKU__c);                          
        }
        
        //Map to hold the Sub Products with Configuration Attributes
        Map<Id, List<SBQQ__ConfigurationAttribute__c>> mapSubProductWithConfigurationAttributes = new Map<Id, List<SBQQ__ConfigurationAttribute__c>>();
        
        //SOQL over the Configuration attributes
        for(SBQQ__ConfigurationAttribute__c configAtt : [SELECT Id, CSV_Map_Product__c,CSV_Map_Product__r.Name, CSV_Map_Field__c, Field_Type__c, SBQQ__ShownValues__c,
                                                                 SBQQ__TargetField__c, SBQQ__Feature__r.SBQQ__Number__c, Default_Value__c, SBQQ__Product__c, SBQQ__Product__r.Name FROM SBQQ__ConfigurationAttribute__c 
                                                                 WHERE RecordType.Name = 'Attribute Map' AND SBQQ__Product__c IN : productId ORDER BY SBQQ__DisplayOrder__c ASC]) {
            
            //Check for main Product
            if(configAtt.CSV_Map_Product__c == configAtt.SBQQ__Product__c) {
            	
            	//Check main Product in map
            	if(!mapMainProductAttributes.containsKey(configAtt.SBQQ__Product__c))
            		mapMainProductAttributes.put(configAtt.SBQQ__Product__c, new List<SBQQ__ConfigurationAttribute__c>());
            	
            	mapMainProductAttributes.get(configAtt.SBQQ__Product__c).add(configAtt);
            
            } else {
            	
            	//Check Sub Product in map
	            if(!mapSubProductWithConfigurationAttributes.containsKey(configAtt.CSV_Map_Product__c))
	                mapSubProductWithConfigurationAttributes.put(configAtt.CSV_Map_Product__c, new List<SBQQ__ConfigurationAttribute__c>());
	            
	            //Add Config attribute in map
	            mapSubProductWithConfigurationAttributes.get(configAtt.CSV_Map_Product__c).add(configAtt);
            }	
        }
        
        //Map to hold the Main Product with Config Attributes
        Map<Id, List<SBQQ__ConfigurationAttribute__c>> mapProductWithConfigAttributes = new Map<Id, List<SBQQ__ConfigurationAttribute__c>>();
        
        //Loop over the Product
        for(Id proId : mapProductWithProductOptionProducts.keySet()) {
            
            //Check Product Id in map
            if(!mapProductWithConfigAttributes.containsKey(proId))
                mapProductWithConfigAttributes.put(proId, new List<SBQQ__ConfigurationAttribute__c>());
                    
            //Loop over the Sub Products
            for(Id subProdId : mapProductWithProductOptionProducts.get(proId)) {
                
                //Check Sub Product is having attributes
                if(mapSubProductWithConfigurationAttributes.containsKey(subProdId))
                    mapProductWithConfigAttributes.get(proId).addAll(mapSubProductWithConfigurationAttributes.get(subProdId));  
            }
        }
        
        //Loop over product
        for(Id proId : mapProductWithConfigAttributes.keySet()) {
            
            //List to hold the Custom Attribute
            List<CustomAttribute> customAttributes = new List<CustomAttribute>();
            
            //Get all the Configuration attributes from Product
            List<SBQQ__ConfigurationAttribute__c> attributes = mapProductWithConfigAttributes.get(proId);
            
            //Check main Product Id in Direct Config. Attributes
            if(mapMainProductAttributes.containsKey(proId))
            	attributes.addAll(mapMainProductAttributes.get(proId));
            	
            //Set to hold the field names
            Set<String> setFieldNames = new Set<String>();
            
            //Loop over the attributes
            for (SBQQ__ConfigurationAttribute__c a : attributes) {
                setFieldNames.add(a.CSV_Map_Field__c);
            }
            
            //Check for fields
            if (setFieldNames.size() > 0) {
                
                //Get field details
                Map<String, FieldObj> fields = getFields(setFieldNames);
                
                //add field details in custom attributes
                for (SBQQ__ConfigurationAttribute__c a : attributes) {
                    customAttributes.add( new CustomAttribute(a, fields.get( a.CSV_Map_Field__c )) );
                }
            }
            
            //Add Attributes with Product
            customAttributeMap.put(proId, customAttributes);
        }
        
        /*
        //Get config attributes from product
        List<Product2> products = [SELECT Id, (SELECT Id, CSV_Map_Product__c,CSV_Map_Product__r.Name, CSV_Map_Field__c, Field_Type__c, SBQQ__ShownValues__c,SBQQ__TargetField__c,
                                                      SBQQ__Feature__r.SBQQ__Number__c, Default_Value__c FROM SBQQ__ConfigurationAttributes__r 
                                               WHERE RecordType.Name = 'Attribute Map' ORDER BY SBQQ__DisplayOrder__c ASC) 
                                   FROM Product2 
                                   WHERE Id IN :productId];
        
        //Check for products
        if (products.size() > 0) {
            
            //Loop over the Products
            for (Product2 p : products) {
                
                //List to hold the Custom Attribute
                List<CustomAttribute> customAttributes = new List<CustomAttribute>();
                
                //Get all the Configuration attributes from Product
                List<SBQQ__ConfigurationAttribute__c> attributes = products[0].SBQQ__ConfigurationAttributes__r;
                
                //Set to hold the field names
                Set<String> fieldNames = new Set<String>();
                
                //Loop over the attributes
                for (SBQQ__ConfigurationAttribute__c a : attributes) {
                    fieldNames.add(a.CSV_Map_Field__c);
                }
                
                //Check for fields
                if (fieldNames.size() > 0) {
                    
                    //Get field details
                    Map<String, FieldObj> fields = getFields(fieldNames);
                    
                    //add field details in custom attributes
                    for (SBQQ__ConfigurationAttribute__c a : attributes) {
                        customAttributes.add( new CustomAttribute(a, fields.get( a.CSV_Map_Field__c )) );
                    }
                }
                
                //Add Attributes with Product
                customAttributeMap.put(p.Id, customAttributes);
            }
        }
        */
        
        return customAttributeMap;
    }
    
    //get field details so they can be displayed properly on the configurator
    public static Map<String, FieldObj> getFields(Set<String> fieldAPINames) {
        Map<String, FieldObj> fieldObjMap = new Map<String, FieldObj>();
        Map<String, Schema.DescribeFieldResult> fldMap = new Map<String, Schema.DescribeFieldResult>();
        
        //get all fields on quoteline
        Map<String, Schema.SObjectField> M = Schema.SObjectType.SBQQ__QuoteLine__c.fields.getMap();
        for( String fldName : M.keySet() ) {
            fldMap.put(fldName, M.get(fldName).getDescribe());
        }
        
        //convert the fields specified
        for (String s : fieldAPINames) {
            if (fldMap.get(s.toLowerCase()) != null) {
                fieldObjMap.put(s, new FieldObj( fldMap.get(s.toLowerCase()) ));
            }
            else {
                throw new customException('No field \'' + s + '\' found.  Please review the Configuration Attributes on this Product');
            }
        }
        
        return fieldObjMap;
    }
    
    //return a list of attributes for a single product (used on the custom configurator page)  //, Boolean isRenewal
    //10/27/2020 - Victor Hanson - CR-20201013-14598 - Updated to include cappex reminder before save
    @RemoteAction
    global static String parseSubProductDetails(String subProdDetails, String parentProductId, Boolean isRenewal, String subProdDetailsWithOutQuestions ) {
    	
    	try {
            
            
    		
    		//Check for Parent Product Id
    		if(parentProductId instanceof Id) {
    			
                List<SubProductDetailWithoutQuestions> subProductDetailsWithOutQuestionsList = new List<SubProductDetailWithoutQuestions>();
                
                if(String.isNotBlank(subProdDetailsWithOutQuestions) )
                    subProductDetailsWithOutQuestionsList = (List<SubProductDetailWithoutQuestions>)System.JSON.deserialize(subProdDetailsWithOutQuestions, List<SubProductDetailWithoutQuestions>.class);

                
    		//Get Sub Product details
    		List<SubProductDetails> subProductDetailsList = (List<SubProductDetails>)System.JSON.deserialize(subProdDetails, List<SubProductDetails>.class);
    			
    		//Set to hold the slected products
    		Set<String> setSelectedProductDetails = new Set<String>();
    			
    		//Map to hold the Sub Product Name and Sub Product details
    		Map<String, SubProductDetails> mapSubProductDetails = new Map<String, SubProductDetails>();
                
    			
    		//SOQL over the Main Product
    		List<Product2> mainProduct = [Select Id, Name, ProductCode From Product2 Where Id =: parentProductId];
                
                //Map to hold the Sub Product Name and Sub Product details without Questions
    		Map<String, SubProductDetailWithoutQuestions> mapSubProductDetailWithoutQuestions = new Map<String, SubProductDetailWithoutQuestions>();
                
                //Loop Over the Sub Products without Questions
                for(SubProductDetailWithoutQuestions  spdWQ: subProductDetailsWithOutQuestionsList){
                    if(spdWQ.selected){
                        mapSubProductDetailWithoutQuestions.put(spdWQ.subProductName, spdWQ);   
                    }
                }
                
                
    			//Loop over the Sub Products
    			for(SubProductDetails sPD : subProductDetailsList) {
    				
    				//Check if Product is selected or not and add product details in map
                    if(sPD.selected){
    					
                        mapSubProductDetails.put(sPD.Name, sPD);
                        
                        /*************     Code to make sure selected sub products have value selected in all configuration attributes (even 0 for number fields) --- Start       **********/
    					
    					//Sub Product have the custom attributes
    					if(sPD.attributes != null) {
    						
    						//Map to hold the Paper and E-only Field Values those need to compare
    						//Map<Integer, List<List<String>>> mapFieldValuesForCompare = new Map<Integer, List<List<String>>>();
    						
    						//Map to hold the Paper and E-only Field result with indexing that will remove other index related field from comparision
    						//Map<Integer, Map<Integer, Boolean>> mapComparisionResultIndexing = new Map<Integer, Map<Integer, Boolean>>();
    						
    						//Variable to hold the total Years
    						Integer totalYears = 0;
    						
    						//Map to hold the Sub Product with Paper and E-only Field values List
    						//Map<String, List<List<String>>> mapSubProductWithFieldValuesToCompare = new Map<String, List<List<String>>>();
    						
                            			/***Added By Mahendra Swarnkar for Issue (181): "Include Descriptive Monitoring?" & "Include Descriptive without Monitoring?" fields can't have same value in same year  - Starts from here****/
                            			//List to hold the 'Include_Descriptive_Monitoring__c' field values
    						List<String> includeDesccriptiveWithMonitoringFieldYearValues = new List<String>();
    						
    						//List to hold the 'Include_Descriptive_without_Monitoring__c' field values
    						List<String> includeDesccriptiveWithOutMonitoringFieldYearValues = new List<String>();
                            			/***Added By Mahendra Swarnkar for Issue (181): "Include Descriptive Monitoring?" & "Include Descriptive without Monitoring?" fields can't have same value in same year  - Ends here****/
    						
                            			/***Added By Victor Hanson - CR-20201013-14598 - 10/26/2020  - Starts here****/
                            			Boolean hasCappex = false;
                            			/***Added By Victor Hanson - CR-20201013-14598 - 10/27/2020 - Ends here****/
    						/***Added By Mahendra Swarnkar for validation: "On the ESYRS product, for Fulfillment, they have to enter a value greater than 0 for atleast one of the Paper or E-only quantities in the same year"- Starts from here****/
                            			/*//List to hold the 'Paper_Quantity_Fulfillment__c' field values
    						List<String> ESYRS_Fulfillment_Paper_FieldYearValues = new List<String>();
    						
    						//List to hold the 'E_Only_Quantity_Fulfillment__c' field values
    						List<String> ESYRS_Fulfillment_EOnly_FieldYearValues = new List<String>();
                            			*/
                            			/***Added By Mahendra Swarnkar for validation: "On the ESYRS product, for Fulfillment, they have to enter a value greater than 0 for atleast one of the Paper or E-only quantities in the same year"- Ends here****/
    							
						//Loop over the CustomAttributes
    						for(CustomAttribute cA : sPD.attributes) {
    							
    								//Get Field for Custom attribute
    								FieldObj cAField = cA.field;
									
								//Get Years value
								List<String> allYearsvalue = cA.years;
								
								totalYears = allYearsvalue.size();
								
								//Check years value
								if(allYearsvalue != null && allYearsvalue.size() > 0) {
									
									//Check Main Product
									/*if(CPQConstants.MAP_PAPER_AND_EONLY_VALIDATION.containsKey(mainProduct[0].Name)) {
										
										//Check Sub Product
										if(CPQConstants.MAP_PAPER_AND_EONLY_VALIDATION.get(mainProduct[0].Name).containsKey(sPD.Name)) {
											
											//Check Sub Product name in map
											if(!mapSubProductWithFieldValuesToCompare.containsKey(sPD.Name))
												mapSubProductWithFieldValuesToCompare.put(sPD.Name, new List<List<String>>());
											
											//Check Field name in set
											if(CPQConstants.MAP_PAPER_AND_EONLY_VALIDATION.get(mainProduct[0].Name).get(sPD.Name).contains(cAField.fieldAPIName)) {
												
												//Add Values in map
												mapSubProductWithFieldValuesToCompare.get(sPD.Name).add(new List<String>());
												mapSubProductWithFieldValuesToCompare.get(sPD.Name)[mapSubProductWithFieldValuesToCompare.get(sPD.Name).size() - 1].addAll(allYearsvalue);		
												
											}
										}
									} */
									
									/*if(CPQConstants.MAP_SUB_PRODUCT_WITH_PAPER_AND_E_ONLY_COMPARISION_FIELDS.containsKey(sPD.Name)) {
										
										//Loop over the Indexing
										for(Integer compIndex : CPQConstants.MAP_SUB_PRODUCT_WITH_PAPER_AND_E_ONLY_COMPARISION_FIELDS.get(sPD.Name).KeySet()) {
											
											//Loop over the Fields
											for(String fName : CPQConstants.MAP_SUB_PRODUCT_WITH_PAPER_AND_E_ONLY_COMPARISION_FIELDS.get(sPD.Name).get(compIndex)) {
												
												//Chek field Name
												if(cAField.fieldAPIName.equalsIgnoreCase(fName)) {
													
													//Check Field Indexing
													if(!mapFieldValuesForCompare.containsKey(compIndex))
														mapFieldValuesForCompare.put(compIndex, new List<List<String>>());
													
													//Add Values in map
													mapFieldValuesForCompare.get(compIndex).add(new List<String>());
													mapFieldValuesForCompare.get(compIndex)[mapFieldValuesForCompare.get(compIndex).size() - 1].addAll(allYearsvalue);
												}
											}
										}
									}*/
                                    
                                    					/***Added By Mahendra Swarnkar for Issue (181): "Include Descriptive Monitoring?" & "Include Descriptive without Monitoring?" fields can't have same value in same year  - Starts from here****/
									if(sPD.Name.equalsIgnoreCase('Financial Aid Descriptive Analysis')) {
                                        					//Check for Include Descriptive Monitoring
										if(cAField.fieldAPIName.equalsIgnoreCase('Include_Descriptive_Monitoring__c'))
											includeDesccriptiveWithMonitoringFieldYearValues = allYearsvalue;
										else if(cAField.fieldAPIName.equalsIgnoreCase('Include_Descriptive_without_Monitoring__c'))
											includeDesccriptiveWithOutMonitoringFieldYearValues = allYearsvalue;
                                    }
                                    
                                    /***Added By Victor Hanson - CR-20201013-14598 - 10/26/2020 : Check if there is a cappex product - Starts here****/
                                    if(mainProduct[0].ProductCode.equalsIgnoreCase(Label.PRODUCT_CODE_CXCNM) ||
                                       mainProduct[0].ProductCode.equalsIgnoreCase(Label.PRODUCT_CODE_CXCNUG))
                                    {
                                        hasCappex = true;
                                    }
                                    /***Added By Victor Hanson - CR-20201013-14598 - 10/26/2020 : Check if there is a cappex product - Ends here****/
                                    
                                    /***Added By Mahendra Swarnkar for Issue (181): "Include Descriptive Monitoring?" & "Include Descriptive without Monitoring?" fields can't have same value in same year  - Ends here****/
                                    
                                    /***Added By Mahendra Swarnkar for validation: "On the ESYRS product, for Fulfillment, they have to enter a value greater than 0 for atleast one of the Paper or E-only quantities in the same year"- Starts from here****/
									/*if(sPD.Name.equalsIgnoreCase('Sophomore/ Junior Fulfillment')) {
                                        
                                        					//Check for Paper_Quantity_Fulfillment__c/E_Only_Quantity_Fulfillment__c
										if(cAField.fieldAPIName.equalsIgnoreCase('Paper_Quantity_Fulfillment__c'))
											ESYRS_Fulfillment_Paper_FieldYearValues = allYearsvalue;
										else if(cAField.fieldAPIName.equalsIgnoreCase('E_Only_Quantity_Fulfillment__c'))
											ESYRS_Fulfillment_EOnly_FieldYearValues = allYearsvalue;
                                    }*/
                                    /***Added By Mahendra Swarnkar for validation: "On the ESYRS product, for Fulfillment, they have to enter a value greater than 0 for atleast one of the Paper or E-only quantities in the same year"- Ends here****/
									
									//Loop over each year to check value
									for(Integer i = 0; i < allYearsvalue.size(); i++) {
										
										//Get year value
										String yearvalue = allYearsvalue[i];
										
										//Check value
										if(String.isBlank(yearvalue))
											return 'Please add a value to all the selected Sub Products configuration attributes (even 0 for number fields)';
									}
								}
    						}
                            
                            /***Added By Victor Hanson - CR-20201013-14598 - 10/26/2020 : provide reminder to user when saving cappex product - Starts here****/
                            if (hasCappex) {
                                return Label.CAPPEX_WARN_ON_SAVE;
                            }
                            /***Added By Victor Hanson - CR-20201013-14598 - 10/26/2020 : provide reminder to user when saving cappex product - Ends here****/
                            
    						//Check Paper and E-Only fields
    						/*if(mapSubProductWithFieldValuesToCompare.size() > 0) {
    							
    							//Loop over the field year values
    							for(Integer i = 0; i < totalYears; i++) {
    								
    								//Loop over the Sub Products
    								for(String subProName : mapSubProductWithFieldValuesToCompare.keySet()) {
    									
    									//Get List of values
    									List<List<String>> yearValuesToCompare = mapSubProductWithFieldValuesToCompare.get(subProName);
    									
    									//Variable to hold the counter of > 0 values
    									Integer greaterThanZeroValues = 0;
    									
    									for(Integer j = 0; j < yearValuesToCompare.size(); j++) {
    										
    										//Check field value
    										if(yearValuesToCompare[j][i] != null && Integer.valueOf(yearValuesToCompare[j][i]) > 0)
    											greaterThanZeroValues++;			
    									}
    									
    									//Check for value
    									if(greaterThanZeroValues > 1)
    										return 'Paper and E only both can\'t have value in the same year';	
    								}
    							}
    						} */
    						/*if(mapFieldValuesForCompare.size() > 0) {
    							 
								//Set to hold the Indexing values
								Set<Integer> setIndexing = new Set<Integer>();
								
								if(CPQConstants.MAP_SUB_PRODUCT_WITH_INDEX_OF_FIELD_TO_EXECLUDE_ZERO_VALIDATION.containsKey(sPD.Name))
									setIndexing = CPQConstants.MAP_SUB_PRODUCT_WITH_INDEX_OF_FIELD_TO_EXECLUDE_ZERO_VALIDATION.get(sPD.Name);
								
    							//Loop over the field year values
    							for(Integer i = 0; i < totalYears; i++) {
    								
    								//Loop over the Intexing
    								for(Integer compIndex : mapFieldValuesForCompare.keySet()) {
    									
    									//Get List of values
    									List<List<String>> yearValuesToCompare = mapFieldValuesForCompare.get(compIndex);
    									
    									//Variable to show error
    									Boolean showError = true;
    									
    									//Check Indexing in map
									if(setIndexing.contains(compIndex)) {
											
											//Check Index in map
											if(!mapComparisionResultIndexing.containsKey(compIndex))
												mapComparisionResultIndexing.put(compIndex, new Map<Integer, Boolean>());
										}
    											
    									//Loop over all the lists
    									for(Integer j = 0; j < yearValuesToCompare.size(); j++) {
    										
    										if(yearValuesToCompare[j][i] != null && Integer.valueOf(yearValuesToCompare[j][i]) > 0) {
    											
    											showError = false;
    											
    											if(mapComparisionResultIndexing.containsKey(compIndex))
    												mapComparisionResultIndexing.get(compIndex).put(i, true); 
    										} 
    									}
    									
    									if(showError && mapComparisionResultIndexing.containsKey(compIndex)) {
    										
    										mapComparisionResultIndexing.get(compIndex).put(i, false);
											showError = false;
    									}
    									
    									//Check for error
    									if(showError)
    										return '\'Paper\' and \'E-Only\' both can\'t be 0 for selected Sub Product';
    								}
    							}
    							
    							//Check for map size
    							if(mapComparisionResultIndexing.size() > 0) {
    								
    								//Loop over the size
    								for(Integer i = 0; i < totalYears; i++) {
    									
    									Boolean showError = true;
    										
    									//Loop over the map values
    									for(Integer compIndex : mapComparisionResultIndexing.keySet()) {
    										
    										//Check for value
    										if(mapComparisionResultIndexing.get(compIndex).containsKey(i) && mapComparisionResultIndexing.get(compIndex).get(i) == true)
    											showError = false;	
    									}
    									
    									//Check for error MSG
    									if(showError)
    										return '\'Paper\' and \'E-Only\' both can\'t be 0 for selected Sub Product';	 
    								}		
    							} 
    						}*/
                            
                            /***Added By Mahendra Swarnkar for Issue (181): "Include Descriptive Monitoring?" & "Include Descriptive without Monitoring?" fields can't have same value in same year  - Starts from here****/
    						//Check Paper and E-Only fields
    						if(includeDesccriptiveWithMonitoringFieldYearValues.size() > 0 && includeDesccriptiveWithOutMonitoringFieldYearValues.size() > 0 && includeDesccriptiveWithMonitoringFieldYearValues.size() == includeDesccriptiveWithOutMonitoringFieldYearValues.size()) {
    							 
    							//Loop over the field year values
    							for(Integer i = 0; i < includeDesccriptiveWithMonitoringFieldYearValues.size(); i++) {
    								
                                    if(includeDesccriptiveWithMonitoringFieldYearValues[i] == 'Yes' && (includeDesccriptiveWithMonitoringFieldYearValues[i]).equalsIgnoreCase(includeDesccriptiveWithOutMonitoringFieldYearValues[i]))
    									return '\'Include Descriptive Monitoring?\' and \'Include Descriptive W/O Monitoring?\' both can\'t have the same value for same Year';
    							}
    						}
    						/***Added By Mahendra Swarnkar for Issue (181): "Include Descriptive Monitoring?" & "Include Descriptive without Monitoring?" fields can't have same value in same year  - Ends here****/ 
    						
    						/***Added By Mahendra Swarnkar for validation: "On the ESYRS product, for Fulfillment, they have to enter a value greater than 0 for atleast one of the Paper or E-only quantities in the same year"- Starts from  here****/
    						/*else if(ESYRS_Fulfillment_Paper_FieldYearValues.size() > 0 && ESYRS_Fulfillment_EOnly_FieldYearValues.size() > 0 && ESYRS_Fulfillment_Paper_FieldYearValues.size() == ESYRS_Fulfillment_EOnly_FieldYearValues.size()){
    							
    							//Loop over the field year values
    							for(Integer i = 0; i < ESYRS_Fulfillment_Paper_FieldYearValues.size(); i++) {
    								
                                    //Get Paper/E-only fulfilment Quantity field values
    								Integer paperValue = ESYRS_Fulfillment_Paper_FieldYearValues[i] != null ? Integer.valueOf(ESYRS_Fulfillment_Paper_FieldYearValues[i]) : 0 ;
    								Integer eOnlyValue = ESYRS_Fulfillment_EOnly_FieldYearValues[i] != null ? Integer.valueOf(ESYRS_Fulfillment_EOnly_FieldYearValues[i]) : 0 ;
    								
                                    //Chek if one of them is populated with value > 0 
                                    if(paperValue == 0 && eOnlyValue == 0 )
    									return 'Either \'Paper Quantity Fulfillment\' OR \'E Only Quantity Fulfillment\' should have value greater than 0 in the same Year';	
    							}
    						}*/
    						/***Added By Mahendra Swarnkar for validation: "On the ESYRS product, for Fulfillment, they have to enter a value greater than 0 for atleast one of the Paper or E-only quantities in the same year"- Ends here****/
    						
    					}
    				
    					/*************     Code to make sure selected sub products have value selected in all configuration attributes (even 0 for number fields) --- End       **********/
                        
                    }
    			}
                
                
    			//Check for Main Product size
    			if(mainProduct.size() > 0) {
    				
    				//Get Main Product Name
    				String mainProductName = mainProduct[0].Name;
    				
    				/*************     Code to product selction validation Exclude --- Start       **********/
    				//This code is for main Product selction validation
    				if(CPQConstants.mapCustomProductSelectionValidations.containsKey(mainProductName)) {
    					
    					//Loop over the Sub Products
    					for(String subProdName : CPQConstants.mapCustomProductSelectionValidations.get(mainProductName).keySet()) {
    						
                            			//Modify By - Subhash - CR-20201106-14674 - 11/10/2020 - Added Check so that it can also consider the subproducts without questions in the comparision
    						//Check SubProduct in selected map
    						if(mapSubProductDetails.containsKey(subProdName) || mapSubProductDetailWithoutQuestions.containsKey(subProdName)) {
    							
    							//Get Related Sub Products
    							Set<String> relatedSubProducts = CPQConstants.mapCustomProductSelectionValidations.get(mainProductName).get(subProdName);
    							
    							//Loop over the Related Sub Product
    							for(String relatedSubProd : relatedSubProducts) {
    								
                                    				//Modify By - Subhash - CR-20201106-14674 - 11/10/2020 - Added Check so that it can also consider the subproducts without questions in the comparision
    								//Check Related Sub Product is selected or not
    								if(mapSubProductDetails.containsKey(relatedSubProd) || mapSubProductDetailWithoutQuestions.containsKey(relatedSubProd)) {
    									
    									//Return Error MSG
    									return CPQConstants.MAP_VALIDATION_MSG_FOR_PRODUCT_CONFIGURATOR.get(subProdName);
    								}
    							}
    						}
    					}
    				}
    				/*************     Code to product selction validation Exclude --- End       **********/
    				
    				/*************     Code to product selction validation Include --- Start       **********/
    				//This code is for main Product selction validation
    				if(CPQConstants.MAP_CUSTOM_PRODUCT_INCLUDE_VALIDATIONS.containsKey(mainProductName)) {
    					
    					//Loop over the Sub Products
    					for(String subProdName : CPQConstants.MAP_CUSTOM_PRODUCT_INCLUDE_VALIDATIONS.get(mainProductName).keySet()) {
    						// CR-20200522-14086 Added By Mahendra Swarnkar
                            			if(isRenewal && (mainProductName == 'Virtual Tour Main' || mainProductName == 'Virtual Tour- Undergraduate'))
                                			continue;
                            
    						//Check SubProduct in selected map
    						if(mapSubProductDetails.containsKey(subProdName) || (mapSubProductDetailWithoutQuestions.containsKey(subProdName) && mapSubProductDetailWithoutQuestions.get(subProdName) != null && mapSubProductDetailWithoutQuestions.get(subProdName).mainProductName == mainProductName)) {
    							
    							//Get Related Sub Products
    							Set<String> relatedSubProducts = CPQConstants.MAP_CUSTOM_PRODUCT_INCLUDE_VALIDATIONS.get(mainProductName).get(subProdName);
    							
    							/***Added By Mahendra Swarnkar for Web Application product validation: "web application can only be selected if either new Name, Pre Name or Inquiry Pool is selected "- Starts from here****/
    							if(subProdName.equalsIgnoreCase('Web Application')){
    								
    								Boolean showError = true;
    								
    								//Loop over the Related Sub Product
	    							for(String relatedSubProd : relatedSubProducts) {
	    								
	    								if(showError){
	    									//Check Related Sub Product is selected or not
		    								if( mapSubProductDetails.containsKey(relatedSubProd)) 
		    									showError = false;
	    								} 	
	    							}
                                    /*if(showError){
	    									
	    									//Return Error MSG
	    									return CPQConstants.MAP_VALIDATION_MSG_FOR_PRODUCT_CONFIGURATOR.get(subProdName);
									}*/
	    							/***Added By Mahendra Swarnkar for Web Application product validation: "web application can only be selected if either new Name, Pre Name or Inquiry Pool is selected "- Ends here****/		
    							} else{
    								
    								//9/25/2020 - Subhash Garhwal - CR-20200922-14545 - Modified the logic if all the required products are not selected
    								Boolean showError = true;
    								
    								//Loop over the Related Sub Product
	    							for(String relatedSubProd : relatedSubProducts) {
	    								
	    								//Check Related Sub Product is selected or not
	    								if(mapSubProductDetails.containsKey(relatedSubProd) || mapSubProductDetailWithoutQuestions.containsKey(relatedSubProd))
	    									showError = false;
	    							}
	    							
	    							if(showError)
	    								return CPQConstants.MAP_VALIDATION_MSG_FOR_PRODUCT_CONFIGURATOR.get(subProdName);	
    							}
    						}
    					}
    				}
    				/*************     Code to product selction validation Include --- End       **********/
    				
    				/*************     Code to field values validations --- Start       **********/
    				/*Details:
    					The below applies to the ESFUL Sub product and any Offer Sub products ESOFFRA, ESOFFRB, ESOFFRC that are selected:
						If on the ESFUL sub product, there is only value for the attribute 'E Only Quantity Fulfillment' (and 'Paper Quantity Fulfillment' is blank or 0),
							then check that for all the Offer sub products selected, the answer to the attribute 'Paper Offer or PDF?' = PDF
            			If on the ESFUL sub product, there is only value for the attribute 'Paper Quantity Fulfillment' (and 'E Only Quantity Fulfillment' is blank or 0),
            				then check that for all the Offer sub products selected, the answer to the attribute 'Paper Offer or PDF?' = Paper
					*/
					//Check for "Year Round Search" main Product
					if(mainProductName == CPQConstants.PRODUCT_NAME_YEAR_ROUND_SEARCH) {
						
                        
						//Check for selected Sub Products
						if(mapSubProductDetails.containsKey(CPQConstants.PRODUCT_NAME_SOPHOMORE_JUNIOR_FULFILLMENT)
							&& (mapSubProductDetails.containsKey(CPQConstants.PRODUCT_NAME_OFFER_1)
								|| mapSubProductDetails.containsKey(CPQConstants.PRODUCT_NAME_OFFER_2)
								|| mapSubProductDetails.containsKey(CPQConstants.PRODUCT_NAME_OFFER_3))) {
									
							//Integer to hold the number of years
							Integer numberOfYears = 0;
							
							//Map to hold the Sub Product Name ==> Sub Product Field ==> All Years values in list (This will hold the Parent Sub Products)
							Map<String, Map<String, List<String>>> mapParentSubProductWithFieldValuesDetails = subProductWithFieldValuesDetails(CPQConstants.SET_YRS_PARENT_SUBPRODUCTS, mapSubProductDetails);
							
							//Map to hold the Sub Product Name ==> Sub Product Field ==> All Years values in list (This will hold the Child Sub Products)
							Map<String, Map<String, List<String>>> mapChildSubProductWithFieldValuesDetails = subProductWithFieldValuesDetails(CPQConstants.SET_YRS_CHILD_SUBPRODUCTS, mapSubProductDetails);
							
							
							//Loop over the parent Sub Product
							for(String pSubPro : mapParentSubProductWithFieldValuesDetails.keySet()) {
								
                                // Modified By Sybhash Garhwal - 08/04/2020
								//Check for Product
								if((pSubPro == CPQConstants.PRODUCT_NAME_INQUIRY_POOL
                                    || pSubPro == CPQConstants.PRODUCT_NAME_INQUIRY_POOL_SEARCH
                                    || pSubPro == CPQConstants.PRODUCT_NAME_INQUIRY_POOL_CUSTOM_APP_MARKETING
                                    || pSubPro == CPQConstants.PRODUCT_NAME_INQUIRY_POOL_OTHER_APP_MARKETING
                                   ) && !mapSubProductDetails.containsKey(CPQConstants.PRODUCT_NAME_OFFER_2)
									&& CPQConstants.MAP_INQUIRY_POOL_PRODICTS_WITH_RELATED_FIELDS.containsKey(pSubPro) 
                                   	&& mapParentSubProductWithFieldValuesDetails.get(pSubPro).size() > 0) {
									
									//Loop over the the field those value we need to check
									for(String relatedField : CPQConstants.MAP_INQUIRY_POOL_PRODICTS_WITH_RELATED_FIELDS.get(pSubPro)) {
										
										//Get field values
										List<String> fieldvalues = mapParentSubProductWithFieldValuesDetails.get(pSubPro).get(relatedField);
										
										//Loop over the values
										for(Integer i = 0; i < fieldvalues.size(); i++) {
											
											//Integer to hold the values
											Integer fieldValue = String.isNotBlank(fieldvalues[i]) ? Integer.valueOf(fieldvalues[i]) : 0;
											
											//Check if value is > 0
											if(fieldValue > 0)
												return 'Please select \'Offer 2\' with Inquiry Pool';
										}
									}
									
								} else {
								
									//Collection to get the fields
									List<String> eOnlyQuantityFulFillmentValues = new List<String>();
									List<String> paperQuantityFulfillmentValues = new List<String>();
                                    
									//Check E_Only_Quantity_Fulfillment__c in map
									if(mapParentSubProductWithFieldValuesDetails.get(pSubPro).containsKey('E_Only_Quantity_Fulfillment__c'))
										eOnlyQuantityFulFillmentValues = mapParentSubProductWithFieldValuesDetails.get(pSubPro).get('E_Only_Quantity_Fulfillment__c');
									
									//Check Paper_Quantity_Fulfillment__c
									if(mapParentSubProductWithFieldValuesDetails.get(pSubPro).containsKey('Paper_Quantity_Fulfillment__c'))
										paperQuantityFulfillmentValues = mapParentSubProductWithFieldValuesDetails.get(pSubPro).get('Paper_Quantity_Fulfillment__c');
									
									//Get total years
									if(numberOfYears == 0 && eOnlyQuantityFulFillmentValues.size() > 0)
										numberOfYears = eOnlyQuantityFulFillmentValues.size();  	
									
									//Loop over the Related Sub Product
									for(String cSubPro : mapChildSubProductWithFieldValuesDetails.keySet()) {
										
										//List to hold the Offer related field values
										List<String> paperOfferOrPDFValues = new List<String>();
										
                                        //List to hold the Offer1 base field values
										List<String> Offer1Basevalues = new List<String>();
                                        
                                        //Added By Mahendra Swarnkar for offers based validation update - 10/17/2019 Starts from here 
                                        //List to hold the Offer2 and 3 base field values
										List<String> Offer2Basevalues = new List<String>();
										List<String> Offer3Basevalues = new List<String>();
										//Added By Mahendra Swarnkar for offers based validation update - 10/17/2019 Ends here
										
										//Check Child Sub Product in map
										if(CPQConstants.MAPOFFERPRODICTSWITHRELATEDFIELDS.containsKey(cSubPro) && mapChildSubProductWithFieldValuesDetails.get(cSubPro).containsKey(CPQConstants.MAPOFFERPRODICTSWITHRELATEDFIELDS.get(cSubPro))) {
											
											//Get values
											paperOfferOrPDFValues = mapChildSubProductWithFieldValuesDetails.get(cSubPro).get(CPQConstants.MAPOFFERPRODICTSWITHRELATEDFIELDS.get(cSubPro));
											
                                            //Check for Offer1 Product and get the base prices values
                                            if(mapChildSubProductWithFieldValuesDetails.containsKey('Offer 1') && mapChildSubProductWithFieldValuesDetails.get('Offer 1').containsKey('Quantity_Base_Price_Up_to_5_000_1__c'))
                                            	Offer1Basevalues = mapChildSubProductWithFieldValuesDetails.get('Offer 1').get('Quantity_Base_Price_Up_to_5_000_1__c');
                                        	
                                            //Added By Mahendra Swarnkar for offers based validation update - 10/17/2019 Starts from here
                                            //Check for Offer1 Product and get the base prices values
                                            if(mapChildSubProductWithFieldValuesDetails.containsKey('Offer 2') && mapChildSubProductWithFieldValuesDetails.get('Offer 2').containsKey('Quantity_Base_Price_Up_to_5_000_2__c'))
                                            	Offer2Basevalues = mapChildSubProductWithFieldValuesDetails.get('Offer 2').get('Quantity_Base_Price_Up_to_5_000_2__c');
                                            
                                            //Check for Offer1 Product and get the base prices values
                                            if(mapChildSubProductWithFieldValuesDetails.containsKey('Offer 3') && mapChildSubProductWithFieldValuesDetails.get('Offer 3').containsKey('Quantity_Base_Price_Up_to_5_000_3__c'))
                                            	Offer3Basevalues = mapChildSubProductWithFieldValuesDetails.get('Offer 3').get('Quantity_Base_Price_Up_to_5_000_3__c');
                                            //Added By Mahendra Swarnkar for offers based validation update - 10/17/2019 ends here
											                                            
											//Loop over the years
											for(Integer i = 0; i < numberOfYears; i++) {
												
												//Check Parent product values
												if(eOnlyQuantityFulFillmentValues.size() > i && paperQuantityFulfillmentValues.size() > i) {
													
													//Integer to hold the values
													Integer eOnlyQuantityFulFillmentvalue = String.isNotBlank(eOnlyQuantityFulFillmentValues[i]) ? Integer.valueOf(eOnlyQuantityFulFillmentValues[i]) : 0;
													Integer paperQuantityFulfillmentValue = String.isNotBlank(paperQuantityFulfillmentValues[i]) ? Integer.valueOf(paperQuantityFulfillmentValues[i]) : 0;
													
                                                    //***Added By Mahendra Swarnkar for validation: "On the ESYRS product, the Offer1 base price should be equal to total of Fullfilment Quantity (paper + eonly fields) value"- Starts from  here****/
                                                    Integer totalFulfilmentValue = eOnlyQuantityFulFillmentvalue + paperQuantityFulfillmentValue ;
                                                    
                                                    //Added By Mahendra Swarnkar for offers based validation update - 10/17/2019 Starts from here
                                                    //Integer offer1BaseValue = Offer1Basevalues.size() > 0 && String.isNotBlank(Offer1Basevalues[i]) ? Integer.valueOf(Offer1Basevalues[i]) : 0;
                                                    Integer offerBaseValue =  (Offer1Basevalues.size() > 0 && String.isNotBlank(Offer1Basevalues[i]) ? Integer.valueOf(Offer1Basevalues[i]) : 0) 
                                                        						+ (Offer2Basevalues.size() > 0 && String.isNotBlank(Offer2Basevalues[i]) ? Integer.valueOf(Offer2Basevalues[i]) : 0) 
                                                        						+ (Offer3Basevalues.size() > 0 && String.isNotBlank(Offer3Basevalues[i]) ? Integer.valueOf(Offer3Basevalues[i]) : 0) ;
                                                    
													//Modified by Subhash Garhwal - 09/30/2019 && isRenewal == false
                                                    if(/*totalFulfilmentValue != offer1BaseValue*/ totalFulfilmentValue < offerBaseValue && isRenewal == false) {
                                                        //return '\'Offer 1\' Quantity Base price should be equal to equal to sum of  Paper/E Only Quantity Fulfillment on Sophomore/ Junior Fulfillment in respective year';
                                                        //return '\'Offers\' Quantity Base price should be equal or less than to sum of  Paper/E Only Quantity Fulfillment on Sophomore/ Junior Fulfillment in respective year';
                                                        return 'The total of all Offers (per year) should be equal to the total of Paper and E-only Quantities for Fulfillment. However if you want to have more total offers than Fulfillment, you can click Save and proceed.';
                                                    } else if(totalFulfilmentValue > offerBaseValue)
                                                    	return 'The total of all Offers (per year) should be equal/greater to the total of Paper and E-only Quantities for Fulfillment.';
                                                    	
                                                    //Added By Mahendra Swarnkar for offers based validation update - 10/17/2019 ends here
                                                    
                                                    //***Added By Mahendra Swarnkar for validation: "On the ESYRS product, the Offer1 base price should be equal to sum of  Paper/E Only Quantity Fulfillment on Sophomore/ Junior Fulfillment"- Ends here****/
                                                    
													//Check for values
													if(eOnlyQuantityFulFillmentvalue > 0 && paperQuantityFulfillmentValue > 0)
														continue;
													
                                                    //Commented BY Subhash Garhwal - 01/13/2020 - Start Here
                                                    /*else if(eOnlyQuantityFulFillmentvalue > 0 && paperQuantityFulfillmentValue <= 0 && paperOfferOrPDFValues.size() > i) {
														
														//Check offer value
														if(paperOfferOrPDFValues[i] == 'Paper')
															return 'Can only select \'Paper\' option for \'Paper Offer or PDF\' if \'Paper Quantity Fulfillment\' value is > 0 for respective year';
                                                        
                                                        //Added blank/null condition error message - By Mahendra Swarnkar - 03/25/2019 - CR-20181019-12685
														else if(String.isBlank(paperOfferOrPDFValues[i]))
															return 'Please select \'PDF\' option for \'Paper Offer or PDF\' if \'E Only Quantity Fulfillment\' value is > 0 for respective year';
													
													
													} else if(eOnlyQuantityFulFillmentvalue <= 0 && paperQuantityFulfillmentValue > 0 && paperOfferOrPDFValues.size() > i) {
														
														//Check offer value
														if(paperOfferOrPDFValues[i] == 'PDF')
															return 'Can only select \'PDF\' option for \'Paper Offer or PDF\' if \'E Only Quantity Fulfillment\' value is > 0 for respective year';	
                                                        
                                                        //Added blank/null condition error message - By Mahendra Swarnkar - 03/25/2019 - CR-20181019-12685
														else if(String.isBlank(paperOfferOrPDFValues[i]))
															return 'Please select \'Paper\' option for \'Paper Offer or PDF\' if \'Paper Quantity Fulfillment\' value is > 0 for respective year';
													}*/
                                                    //Commented BY Subhash Garhwal - 01/13/2020 - End Here
												}
											}
										}
									}
								}
							}	
						}
					}

					//Added by Subhash Garhwal - 09/27/2019 - CR-20190911-13329 - Start Here
					/*************     Code to field values validations --- Start       **********/
    				/*Details:
    					The below applies to the ESWAP Sub product is selected:
						then make sure they have atleast one of ESAM - (ESNN, ESIP, ESPN) sub product also added.
					*/
					//Check for "Custom Application Marketing" main Product
					if(mainProductName == CPQConstants.PRODUCT_Custom_Application_Marketing) {
						//Check for selected Sub Products
						if(mapSubProductDetails.containsKey(CPQConstants.PRODUCT_Name_Web_Application)) {
							
                            //Integer to hold the number of years
							//Integer numberOfYears = 3;
                            
							//Map to hold the Sub Product Name ==> Sub Product Field ==> All Years values in list (This will hold the Parent Sub Products)
							Map<String, Map<String, List<String>>> mapParentSubProductWithFieldValuesDetails = subProductWithFieldValuesDetails(CPQConstants.SET_ESAM_PARENT_SUBPRODUCTS, mapSubProductDetails);
                            Map<String,List<String>> mapOfSubProductWithYearValue = new Map<String,List<String>>();
							Map<String,List<String>> mapOfESWAPwithYearValue = new Map<String,List<String>>();
                            Boolean nonZeroCheck = false;

                            // modified by Subhash Garhwal - 08/04/2020
                            //Loop over the parent Sub Product
                            for(String pSubPro : mapParentSubProductWithFieldValuesDetails.keySet()) {
                                if((pSubPro == CPQConstants.PRODUCT_NAME_INQUIRY_POOL 
                                    || pSubPro == CPQConstants.PRODUCT_NAME_INQUIRY_POOL_SEARCH
                                    || pSubPro == CPQConstants.PRODUCT_NAME_INQUIRY_POOL_CUSTOM_APP_MARKETING
                                    || pSubPro == CPQConstants.PRODUCT_NAME_INQUIRY_POOL_OTHER_APP_MARKETING
                                   ) && mapParentSubProductWithFieldValuesDetails.get(pSubPro).size() > 0){
                                    for(String relatedField : CPQConstants.MAP_Inquiry_Pool_WITH_RELATED_FIELDS.get(pSubPro)) {
                                        //Get field values 
                                        mapOfSubProductWithYearValue.put(relatedField, mapParentSubProductWithFieldValuesDetails.get(pSubPro).get(relatedField));  
                                    }
                                }
                                // modified by Subhash Garhwal - 08/04/2020
                                if((pSubPro == CPQConstants.PRODUCT_NAME_New_Names
                                    || pSubPro == CPQConstants.PRODUCT_NAME_New_Names_SEARCH
                                    || pSubPro == CPQConstants.PRODUCT_NAME_New_Names_CUSTOM_APP_MARKETING
                                    || pSubPro == CPQConstants.PRODUCT_NAME_New_Names_OTHER_APP_MARKETING
                                   ) && mapParentSubProductWithFieldValuesDetails.get(pSubPro).size() > 0) {
                                    for(String relatedField : CPQConstants.MAP_New_Names_WITH_RELATED_FIELDS.get(pSubPro)) {
                                        //Get field values
                                        mapOfSubProductWithYearValue.put(relatedField, mapParentSubProductWithFieldValuesDetails.get(pSubPro).get(relatedField));  
                                    }
								}
                                if((pSubPro == CPQConstants.PRODUCT_NAME_PRE_Names
                                    || pSubPro == CPQConstants.PRODUCT_NAME_PRE_Names_SEARCH
                                    || pSubPro == CPQConstants.PRODUCT_NAME_PRE_Names_CUSTOM_APP_MARKETING
                                    || pSubPro == CPQConstants.PRODUCT_NAME_PRE_Names_OTHER_APP_MARKETING
                                   ) && mapParentSubProductWithFieldValuesDetails.get(pSubPro).size() > 0) {
                                    for(String relatedField : CPQConstants.MAP_Pre_Names_WITH_RELATED_FIELDS.get(pSubPro)) {
                                        //Get field values
                                        mapOfSubProductWithYearValue.put(relatedField, mapParentSubProductWithFieldValuesDetails.get(pSubPro).get(relatedField));  
                                    }
                                }
								if(pSubPro == CPQConstants.PRODUCT_Name_Web_Application && mapParentSubProductWithFieldValuesDetails.get(pSubPro).size() > 0){
                                    for(String relatedField : CPQConstants.MAP_Web_Application_PRODICTS_WITH_RELATED_FIELDS.get(pSubPro)) {
                                        //Get field values
                                        mapOfESWAPwithYearValue.put(relatedField, mapParentSubProductWithFieldValuesDetails.get(pSubPro).get(relatedField));  
                                    }
                                }
                            }
 

 			for(String eswapKey : mapOfESWAPwithYearValue.keySet()){
                                integer i = 0;
                                System.debug('Keyset :: '+ eswapKey);
                                for(String eswapValue : mapOfESWAPwithYearValue.get(eswapKey)){
                                    System.debug('eswapKey :: '+eswapValue);
                                    if(Integer.valueOf(eswapValue) > 0){
                                        for(String str : mapOfSubProductWithYearValue.keySet()){
                                            System.debug('Keyset inner :: '+ str);
                                            Boolean correctSenario  = false;
                                            for(Integer j = 0; j < mapOfSubProductWithYearValue.get(str).size(); j++){
                                                System.debug(i+ 'Values inner ::: '+mapOfSubProductWithYearValue.get(str)[i]);
                                                if(Integer.valueOf(mapOfSubProductWithYearValue.get(str)[i]) > 0){
                                                    nonZeroCheck = false;
                                                    correctSenario = true;
                                                    break;
                                                }
                                                else{
                                                    nonZeroCheck = true;
                                                }
                                            }
                                            if(correctSenario)
                                                break;
                                        }
                                    }
                                i++;
                                }
                            }    
                            
                                //5/3/2021 - Subhash Garhwal - CR-20210421-15094 Remove the Web application validation
			        //Loop over the parent Sub Product
			        /*for(String pSubPro : mapParentSubProductWithFieldValuesDetails.keySet()) {
                                
                                // modified by Subhash Garhwal - 08/04/2020
				//Check for Product
				if((pSubPro == CPQConstants.PRODUCT_Name_Web_Application) 
                                    && CPQConstants.MAP_Web_Application_PRODICTS_WITH_RELATED_FIELDS.containsKey(pSubPro)
                                    && mapParentSubProductWithFieldValuesDetails.get(pSubPro).size() > 0
                                    && ( nonZeroCheck == true 
                                         || (
                                            !mapSubProductDetails.containsKey(CPQConstants.PRODUCT_NAME_INQUIRY_POOL)
                                            && !mapSubProductDetails.containsKey(CPQConstants.PRODUCT_NAME_INQUIRY_POOL_CUSTOM_APP_MARKETING)
                                            && !mapSubProductDetails.containsKey(CPQConstants.PRODUCT_NAME_INQUIRY_POOL_OTHER_APP_MARKETING)
                                     		&& !mapSubProductDetails.containsKey(CPQConstants.PRODUCT_NAME_New_Names)
                                            && !mapSubProductDetails.containsKey(CPQConstants.PRODUCT_NAME_New_Names_CUSTOM_APP_MARKETING)
                                            && !mapSubProductDetails.containsKey(CPQConstants.PRODUCT_NAME_New_Names_OTHER_APP_MARKETING)
                                       		&& !mapSubProductDetails.containsKey(CPQConstants.PRODUCT_NAME_PRE_Names)
                                      		&& !mapSubProductDetails.containsKey(CPQConstants.PRODUCT_NAME_PRE_Names_CUSTOM_APP_MARKETING)
                                      		&& !mapSubProductDetails.containsKey(CPQConstants.PRODUCT_NAME_PRE_Names_OTHER_APP_MARKETING)
                                      	 )
                                       )
                                  ) {
                                         
									//Loop over the the field those value we need to check
									for(String relatedField : CPQConstants.MAP_Web_Application_PRODICTS_WITH_RELATED_FIELDS.get(pSubPro)) {
                                        
										//Get field values
										List<String> fieldvalues = mapParentSubProductWithFieldValuesDetails.get(pSubPro).get(relatedField);
										
                                        for(Integer i = 0; i < fieldvalues.size(); i++) {
                                            //Integer to hold the values
                                            Integer fieldValue = String.isNotBlank(fieldvalues[i]) ? Integer.valueOf(fieldvalues[i]) : 0;
                                            
                                            //Check if value is > 0
                                            if(fieldValue > 0)
                                                return 'Cannot add Web Application without New Names or Inquiry Pool or Pre Names';
                                        }
									}
									
								}
							} */
						}
					}
    				//Added by Subhash Garhwal - 09/27/2019 - CR-20190911-13329 - End Here

    				/*************     Code to field values validations --- End       **********/
                    
                    		//Added by Subhash Garhwal - 12/18/2019 - Start Here
    				/*Details:
    					The below applies to the 'You Vist' Sub product is selected:
						then make sure they have 'Studio Services' sub product also added.
					*/
					//Check for "You Visit Main" main Product
					if(mainProductName == CPQConstants.PRODUCT_You_Visit_Main) {
                        
                        			//Check for selected Sub Products
						if(mapSubProductDetails.containsKey(CPQConstants.PRODUCT_Virtual_Tour)) {
                            
							//Map to hold the Sub Product Name ==> Sub Product Field ==> All Years values in list (This will hold the Parent Sub Products)
							Map<String, Map<String, List<String>>> mapParentSubProductWithFieldValuesDetails = subProductWithFieldValuesDetails(CPQConstants.SET_YOU_VISIT_MAIN_PARENT_SUBPRODUCTS, mapSubProductDetails);
							//Map to hold the Sub Product Name ==> Sub Product Field ==> All Years values in list (This will hold the Child Sub Products)
							Map<String, Map<String, List<String>>> mapChildSubProductWithFieldValuesDetails = subProductWithFieldValuesDetails(CPQConstants.SET_YOU_VISIT_MAIN_CHILD_SUBPRODUCTS, mapSubProductDetails);
							//Loop over the parent Sub Product
							/*
                            				for(String pSubPro : mapParentSubProductWithFieldValuesDetails.keySet()) {
								
								//Check for Product
								if(pSubPro == CPQConstants.PRODUCT_Virtual_Tour && !mapSubProductDetails.containsKey(CPQConstants.PRODUCT_Studio_Services)
									&& CPQConstants.MAP_YOU_VIST_PRODICTS_WITH_RELATED_FIELDS.containsKey(pSubPro) && mapParentSubProductWithFieldValuesDetails.get(pSubPro).size() > 0) {
									   
									//Loop over the the field those value we need to check
									for(String relatedField : CPQConstants.MAP_YOU_VIST_PRODICTS_WITH_RELATED_FIELDS.get(pSubPro)) {
										//Get field values
										List<String> fieldvalues = mapParentSubProductWithFieldValuesDetails.get(pSubPro).get(relatedField);
										//Loop over the values
										for(Integer i = 0; i < fieldvalues.size(); i++) {
											//Integer to hold the values
											Integer fieldValue = String.isNotBlank(fieldvalues[i]) ? i : 0;
											//Check if value is > 0
											if(fieldValue > 0)
												return 'To select \'YouVisit\' you also need to select Studio Services';
										}
									}
								}
							}
							*/
						}
                    }
					//Added by Subhash Garhwal - 12/18/2019 - End Here
					
					//Added by Colin McGloin - 07/27/2020 - Starts Here

					//Check for "Student Journey" main Product
					if(mainProductName == CPQConstants.PRODUCT_STUDENT_JOURNEY) {

						//Check for selected Sub Products
						if(mapSubProductDetails.containsKey(CPQConstants.PRODUCT_STUDENT_JOURNEY_ARCHITECTURE) ||
						mapSubProductDetails.containsKey(CPQConstants.PRODUCT_STUDENT_JOURNEY_BUSINESS) ||
						mapSubProductDetails.containsKey(CPQConstants.PRODUCT_STUDENT_JOURNEY_COE) ||
						mapSubProductDetails.containsKey(CPQConstants.PRODUCT_STUDENT_JOURNEY_DEGREE) ||
						mapSubProductDetails.containsKey(CPQConstants.PRODUCT_STUDENT_JOURNEY_EDUCATION) ||
						mapSubProductDetails.containsKey(CPQConstants.PRODUCT_STUDENT_JOURNEY_ENGINEERING) ||
						mapSubProductDetails.containsKey(CPQConstants.PRODUCT_STUDENT_JOURNEY_GRAD_WIDE) ||
						mapSubProductDetails.containsKey(CPQConstants.PRODUCT_STUDENT_JOURNEY_HEALTH_SCIENCES) ||
						mapSubProductDetails.containsKey(CPQConstants.PRODUCT_STUDENT_JOURNEY_LAW) ||
						mapSubProductDetails.containsKey(CPQConstants.PRODUCT_STUDENT_JOURNEY_NURSING) ||
						mapSubProductDetails.containsKey(CPQConstants.PRODUCT_STUDENT_JOURNEY_PHARMACY)){

							//Map to hold the Sub Product Name ==> Sub Product Field ==> All Years values in list (This will hold the Child Sub Products)
							Map<String, Map<String, List<String>>> mapParentSubProductWithFieldValuesDetails = subProductWithFieldValuesDetails(CPQConstants.MAP_STUDENT_JOURNEY_QUANTITY_VALIDATION_FIELDS.keyset(), mapSubProductDetails);

							//Loop over the parent Sub Product
							for(String pSubPro : mapParentSubProductWithFieldValuesDetails.keySet()) {
								
								//Check for Product
								if(CPQConstants.MAP_STUDENT_JOURNEY_QUANTITY_VALIDATION_FIELDS.keyset().contains(pSubPro) && mapParentSubProductWithFieldValuesDetails.get(pSubPro).size() > 0) {

									List<String> subProductValues = new List<String>();
									subProductValues.add(CPQConstants.MAP_STUDENT_JOURNEY_QUANTITY_VALIDATION_FIELDS.get(pSubPro));
									
									//Loop over the the field those value we need to check
									for(String relatedField : subProductValues) {
										
										//Get field values
										List<String> fieldvalues = mapParentSubProductWithFieldValuesDetails.get(pSubPro).get(relatedField);

										Integer fieldValue = 0;
										
										//Loop over the values
										for(Integer i = 0; i < fieldvalues.size(); i++) {
											
											//Integer to hold the values
											fieldValue += String.isNotBlank(fieldvalues[i]) ? Integer.valueOf(fieldvalues[i]) : 0;
											
										}

										//Check if value is > 0
										if(fieldValue == 0)
										return 'Please enter a value greater than 0 in "Student Journey Quantity" for one of the years for the Product: ' + pSubPro;

									}
								}

							}

						} if (mapSubProductDetails.containsKey(CPQConstants.PRODUCT_HIGH_AFFINITY_AUDIENCE)){

							//Map to hold the Sub Product Name ==> Sub Product Field ==> All Years values in list (This will hold the Child Sub Products)
							Map<String, Map<String, List<String>>> mapParentSubProductWithFieldValuesDetails = subProductWithFieldValuesDetails(CPQConstants.SET_HA_AUDIENCE_QUANTITY_VALIDATION_SUBPRODUCTS, mapSubProductDetails);

							//Loop over the parent Sub Product
							for(String pSubPro : mapParentSubProductWithFieldValuesDetails.keySet()) {
								
								//Check for Product
								if(CPQConstants.PRODUCT_HIGH_AFFINITY_AUDIENCE.contains(pSubPro) && mapParentSubProductWithFieldValuesDetails.get(pSubPro).size() > 0) {
									
									//Loop over the the field those value we need to check
									for(String relatedField : CPQConstants.LIST_STUDENT_JOURNEY_HA_QUANTITY_VALIDATION_FIELDS) {
										
										//Get field values
										List<String> fieldvalues = mapParentSubProductWithFieldValuesDetails.get(pSubPro).get(relatedField);

										Integer fieldValue = 0;
										
										//Loop over the values
										for(Integer i = 0; i < fieldvalues.size(); i++) {
											
											//Integer to hold the values
											fieldValue += String.isNotBlank(fieldvalues[i]) ? Integer.valueOf(fieldvalues[i]) : 0;
											
										}

										//Check if value is > 0
										if(fieldValue == 0)
										return 'Please enter a value greater than 0 for one of the years for High Affinity Audience Quantity';

									}
								}

							}

						}
                        if (mapSubProductDetails.containsKey(CPQConstants.PRODUCT_ADDITIONAL_STUDENT_JOURNEY)){

							//Map to hold the Sub Product Name ==> Sub Product Field ==> All Years values in list (This will hold the Child Sub Products)
							Map<String, Map<String, List<String>>> mapParentSubProductWithFieldValuesDetails = subProductWithFieldValuesDetails(CPQConstants.SET_ADDT_STUDENT_JOURNEY_VALIDATION_SUBPRODUCTS, mapSubProductDetails);

							//Loop over the parent Sub Product
							for(String pSubPro : mapParentSubProductWithFieldValuesDetails.keySet()) {
								
								//Check for Product
								if(CPQConstants.PRODUCT_ADDITIONAL_STUDENT_JOURNEY.contains(pSubPro) && mapParentSubProductWithFieldValuesDetails.get(pSubPro).size() > 0) {

									//Boolean for checking if the field is populated in at least one year
									Boolean validationCheck = true;
									String yearValue;
									
									//Loop over the the field those value we need to check
									for(String relatedField : CPQConstants.LIST_ADDT_STUDENT_JOURNEY_VALIDATION_FIELDS) {
										
										//Get field values
										List<String> fieldvalues = mapParentSubProductWithFieldValuesDetails.get(pSubPro).get(relatedField);
										
										//Loop over the values
										for(Integer i = 0; i < fieldvalues.size(); i++) {
											
											//Integer to hold the values
											if (fieldvalues[i] != null){
												yearValue = fieldvalues[i];
											}

											//Check the value of our Year Value to see if it's equal to a value other than None or Blank
											if (yearValue != 'None'){
												validationCheck = false;
											}
											
										}

										//Check if boolean check is still equal to true
										if(validationCheck == true)
										return 'Please select a value other than None for "Additional Student Journey Versions" in one of the years for Additional Student Journey';

									}
								}

							}
						}

					}

    			}
			}
			
			
    		return 'success';
    		
    	} catch(Exception ex) {
            return ex.getMessage();
        }
    }
    
    
    /**
     * 
     * @description	:   Method to Populate Sub Product details with Field and yearly values
     * 
     *  @args           :   Set<String>, Map<String, SubProductDetails>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 03/06/2019 - Created - Subhash Garhwal - CR-20181019-12685
     * 
     **/
	private static Map<String, Map<String, List<String>>> subProductWithFieldValuesDetails(Set<String> setSubProducts, Map<String, SubProductDetails> mapSubProductDetails) {
		
		//Map to hold the Sub Product Name ==> Sub Product Field ==> All Years values in list
		Map<String, Map<String, List<String>>> mapSubProductWithFieldValuesDetails = new Map<String, Map<String, List<String>>>();
		
		//Loop over the YRS Parent Sub Products
		for(String yRSSubProd : setSubProducts) {
			
			//Check if Sub Product is selected or not
			if(mapSubProductDetails.containsKey(yRSSubProd)) {
				
				//Check Parent Sub Product in Parent Sub Product map
				if(!mapSubProductWithFieldValuesDetails.containsKey(yRSSubProd))
					mapSubProductWithFieldValuesDetails.put(yRSSubProd, new Map<String, List<String>>());
				
				//Loop over the configuration attributes
				for(CustomAttribute cA : mapSubProductDetails.get(yRSSubProd).attributes) {
					
					//Add field name in map
					if(!mapSubProductWithFieldValuesDetails.get(yRSSubProd).containsKey(cA.attribute.CSV_Map_Field__c))
						mapSubProductWithFieldValuesDetails.get(yRSSubProd).put(cA.attribute.CSV_Map_Field__c, new List<String>());
					
					//Add Years values
					mapSubProductWithFieldValuesDetails.get(yRSSubProd).get(cA.attribute.CSV_Map_Field__c).addAll(cA.years);	
				}
			}
		}
		
		//Return
		return mapSubProductWithFieldValuesDetails;
	}
    
    //Class to get the selected data to apply some validations
    global class SubProductDetails {
    	
		//Variables
		public String name{get;set;}
		public Boolean isRenewal{get;set;}
		public Boolean selected{get;set;}
		//public Integer order{get;set;}
		// public Boolean isSubProductWithNoQuestions{get;set;}
        
		public List<CustomAttribute> attributes{get;set;}
    }
    
    global class SubProductDetailWithoutQuestions {
    	
		//Variables
		public String mainProductName{get;set;}
        	public String subProductName{get;set;}
		public Boolean isRequired{get;set;}
		public Boolean selected{get;set;}
		
    }
    
    
    global class CustomAttribute {
        
        public SBQQ__ConfigurationAttribute__c attribute { get; set; }
        public FieldObj field { get; set; }
        public List<String> years{get;set;}
        
        //Varibale
        public CustomAttribute(SBQQ__ConfigurationAttribute__c attribute, FieldObj field) {
            this.attribute = attribute;
            this.field = field;
        }
    }
    
    public class FieldObj {
        
        public List<Schema.PicklistEntry> picklistEntries { get; set; }
        public String fieldType { get; set; }
        public String fieldAPIName { get; set; }
        public String fieldLabel { get; set; }
        public String fieldHelpText { get; set;}
        public String helpTextDisplay { get; set;}
	
	//Modified By - Subhash Garhwal - CR-20210521-15173 
        public Boolean isHideFromUI { get; set;}
        
        public FieldObj(Schema.DescribeFieldResult fld) {
            try {
                fieldAPIname = fld.getName();
                fieldLabel = fld.getLabel();
                fieldType = String.valueOf(fld.getType());
                fieldHelpText = fld.getInlineHelpText();
                
		if(fieldAPIname == 'Did_Prior_Yr_Fulflmnt_have_anyPaper__c')
			isHideFromUI = true;
                
                if(String.isNotBlank(fieldHelpText))
                	helpTextDisplay = 'inline-block';
                else
                	helpTextDisplay = 'none';	
                
                if (fieldType == 'DOUBLE') fieldType = 'Number';
                if (fieldType == 'PICKLIST') {
                    //get picklist values
                    picklistEntries = fld.getPicklistValues();
                }
            }
            catch(Exception e) {
                throw new customException('Error on field:' + JSON.serialize(fld) 
                             + '\r\n error:' + e.getMessage() + e.getStackTraceString());
            }
        }
    }
    
    
}