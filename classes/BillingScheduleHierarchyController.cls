global with sharing class BillingScheduleHierarchyController {
    
    public static Id ContractId;
    public static Map<ID, Billing_Schedule_Header__c> mapBillingScheduleHierarchyRecords;
    //Added By Mahendra Swarnkar - CR-20210112-14800 - 01/25/2021 - Starts from here  
    public static Map<ID, List<Billing_Schedule_Period__c>> mapBillingScheduleHierarchyBSPRecords;
    public static Map<ID, List<Billing_Schedule_Line__c>> mapBillingScheduleHierarchyBSLRecords;
    //Added By Mahendra Swarnkar - CR-20210112-14800 - 01/25/2021 - Ends here 
    
    public static Map<String, List<BillingScheduleHierarchyWrapper>> mapBillingScheduleHierarchyWrappers;
    
    @AuraEnabled (cacheable=true)
    public static String BillingScheduleHierarchyInitialLoad (String ParentId) {
        	
            if(String.IsNotBlank(ParentId)) {
                
            	ContractId = ID.valueOf(ParentId);
                
                mapBillingScheduleHierarchyRecords = getBillingScheduleHierarchyRecords();
                
                //Modified By Mahendra Swarnkar - CR-20210112-14800 - 01/25/2021 - Starts from here 
                mapBillingScheduleHierarchyBSPRecords = getBillingScheduleHierarchyBSPRecords();
                mapBillingScheduleHierarchyBSLRecords = getBillingScheduleHierarchyBSLRecords();
                
                mapBillingScheduleHierarchyWrappers = fillWrappers(mapBillingScheduleHierarchyRecords, mapBillingScheduleHierarchyBSPRecords, mapBillingScheduleHierarchyBSLRecords);
                //Modified By Mahendra Swarnkar - CR-20210112-14800 - 01/25/2021 - Ends here 
                
            } else {
                throw new AuraHandledException('Error:: Id Not Specified');
            }
		
        return JSON.serialize(mapBillingScheduleHierarchyWrappers);
    }
    @AuraEnabled (cacheable=true)
    public static String getColumns()
    {
        List<ColumnNameWrapper> listColumnNames = new List<ColumnNameWrapper>();
        /*
         *
         *  	type: 'url',
                fieldName: 'accountOwner',
                label: 'Account Owner',
                typeAttributes: {
                    label: { fieldName: 'accountOwnerName' }
                }
         *  
         * "name": "123555", ---- index
                "accountName": "Rewis Inc", --- invoicingArrangement
                "accountOwnerName": "Jane Doe", -- name
				"accountOwner": "http://example.com/jane-doe", -- recordLink
                
				"employees": 3100, --- invoicingArrangement
                "phone": "837-555-1212",
                
                "billingCity": "Phoeniz, AZ"


         * 
         * 
		*/
        
        
        //Type Attribut for Name
        Map<String, List<ColumnNameWrapper>> mapTypeAttribues = new Map<String, List<ColumnNameWrapper>>();
        mapTypeAttribues.put('label',new List<ColumnNameWrapper>{new ColumnNameWrapper(null, 'fieldName', 'name', null, null ) });
        listColumnNames.add(new ColumnNameWrapper('url', 'recordLink', 'Name', null, mapTypeAttribues ) );
        
        //String type, String fieldName, String label, Integer initialWidth, Map<String, List<ColumnNameWrapper>> typeAttributes
        listColumnNames.add(new ColumnNameWrapper('text', 'parentProductWithProduct', 'Parent Product with Product', 300, null ) );
        listColumnNames.add(new ColumnNameWrapper('currency', 'billingAmount', 'Billing Amount', 300, null ) );
        listColumnNames.add(new ColumnNameWrapper('Date', 'startDate', 'Start Date', 300, null ) );
        listColumnNames.add(new ColumnNameWrapper('Date', 'endDate', 'End Date', 300, null ) );
        
        return JSON.serialize(listColumnNames);
        //return 'Testing is going on';
        //return JSON.serialize( listColumnNames);
    }
    @AuraEnabled
    public static string getRowData()
    {
        return null;
        //return JSON.serialize( sdgNamespaceUtility.GetNamespace());
    }
    
    public class BillingScheduleHierarchyWrapper{
        public String index;
        public String name;
        public String parentProductWithProduct;
        public Decimal billingAmount;
        public Date startDate;
        public Date endDate;
        public String recordLink;
        public Id recordId;
        public String salesInvoiceId;
        public String salesInvoiceName;
        public Date billDate;
        public String notes;
        
        public BillingScheduleHierarchyWrapper(Id recordId, String index, String name, String recordLink, String parentProductWithProduct, String notes, Decimal billingAmount, Date startDate, Date endDate) {
			
            this.recordId = recordId;
            this.index = index;
            this.name = name;
            this.recordLink = recordLink;
            this.parentProductWithProduct = parentProductWithProduct;
            this.notes = notes;
            this.billingAmount = billingAmount;
            //system.debug('startDate.format() ::: ' + startDate.format());
            this.startDate = startDate;
            this.endDate = endDate;
    	}
        
    }
    
    public class ColumnNameWrapper{
        public String type;
        public String fieldName;
        public String label;
        public Integer initialWidth;
        public Map<String, List<ColumnNameWrapper>> typeAttributes;
        
        public ColumnNameWrapper(String type, String fieldName, String label, Integer initialWidth, Map<String, List<ColumnNameWrapper>> typeAttributes) {
			this.type = type;
            this.fieldName = fieldName ;
            this.label = label;
            this.initialWidth = initialWidth;
            this.typeAttributes = typeAttributes;
    	}
        
    }
    
    //get the billing schedule Headers
    public static Map<ID, Billing_Schedule_Header__c> getBillingScheduleHierarchyRecords() {
        
        //Map to hold the Billing Schedule Headers with its childs.
        Map<ID, Billing_Schedule_Header__c> mapBillingScheduleheaders;
        
        if(ContractId != null){
         	
            mapBillingScheduleheaders = new Map<ID, Billing_Schedule_Header__c>();
                
            //Modified By Mahendra Swarnkar - CR-20210112-14800 - 01/25/2021 - removed the inline query for child BSP/BSLs Due to record limit restriction 
            for(Billing_Schedule_Header__c bsh : [Select Id, Name, Total_Invoiced__c, Contract_Start_Date__c, Contract_End_Date__c, List_Of_Product_Codes__c, Contract_Total__c, Invoicing_Arrangement__c 
                                                  From Billing_Schedule_Header__c 
                                                  WHERE Standard_Contract__c != null AND Standard_Contract__c =: ContractId 
                                                  ORDER BY Contract_Start_Date__c]) 
            {
                mapBillingScheduleheaders.put(bsh.Id, bsh);
                system.debug('@@@@@@ Start BSH :: '+ bsh.Contract_Start_Date__c + '  End :: ' + bsh.Contract_End_Date__c);
			}
        }
        return mapBillingScheduleheaders;
    }
    
    //Added By Mahendra Swarnkar - CR-20210112-14800 - 01/25/2021 - Starts from here 
    //get the billing schedule Periods
    public static Map<ID, List<Billing_Schedule_Period__c>> getBillingScheduleHierarchyBSPRecords() {
        
        //Map to hold the Billing Schedule Periods.
        Map<ID, List<Billing_Schedule_Period__c>> mapBillingScheduleBSP;
        
        if(ContractId != null){
         	
            mapBillingScheduleBSP = new Map<ID, List<Billing_Schedule_Period__c>>();
                
            for(Billing_Schedule_Period__c bsp : [Select Id, Name,Billing_Schedule_Header__c, Billing_Schedule_Period_Start_Date__c, Billing_Schedule_Period_End_Date__c, Total_Billing_Amount_For_Period__c, Sales_Invoice__c, Sales_Invoice__r.Name,
            					  Billing_Date_Calculation__c, Billing_Date_Actual__c, List_Of_Product_Codes__c, Billing_Date_Calculated__c, Billing_Period_Notes__c
                           			  FROM Billing_Schedule_Period__c 
                                                  WHERE Billing_Schedule_Header__c != null AND Billing_Schedule_Header__r.Standard_Contract__c != null AND Billing_Schedule_Header__r.Standard_Contract__c =: ContractId 
                                                  ORDER BY Billing_Schedule_Period_Start_Date__c]) 
            {
                if(!mapBillingScheduleBSP.containsKey(bsp.Billing_Schedule_Header__c))
                	mapBillingScheduleBSP.put(bsp.Billing_Schedule_Header__c, new List<Billing_Schedule_Period__c>());
                mapBillingScheduleBSP.get(bsp.Billing_Schedule_Header__c).add(bsp);
	    }
        }
        return mapBillingScheduleBSP;
    }
    
    //get the billing schedule Lines
    public static Map<ID, List<Billing_Schedule_Line__c>> getBillingScheduleHierarchyBSLRecords() {
        
        //Map to hold the Billing Schedule Lines.
        Map<ID, List<Billing_Schedule_Line__c>> mapBillingScheduleBSLs;
        
        if(ContractId != null){
         	
            mapBillingScheduleBSLs = new Map<ID, List<Billing_Schedule_Line__c>>();
                
            for(Billing_Schedule_Line__c bsl : [Select Id, Billing_Schedule_Header__c, Name, Billing_Amount__c, Billing_Schedule_Period__c, Billing_Schedule_Period__r.Billing_Schedule_Period_Start_Date__c, Billing_Schedule_Period__r.Billing_Schedule_Period_End_Date__c, 
            					Parent_Product_with_Product__c, Billing_Schedule_Period__r.Billing_Date_Calculation__c, Billing_Schedule_Period__r.Billing_Date_Actual__c, Billing_Schedule_Period__r.Sales_Invoice__c, Billing_Schedule_Period__r.Sales_Invoice__r.Name,
						Billing_Schedule_Period__r.Billing_Date_Calculated__c
                           			FROM Billing_Schedule_Line__c 
                                                WHERE Billing_Schedule_Header__c != null AND Billing_Schedule_Header__r.Standard_Contract__c != null AND Billing_Schedule_Header__r.Standard_Contract__c =: ContractId 
                                                ORDER BY Parent_Product_with_Product__c ASC]) 
            {
                if(!mapBillingScheduleBSLs.containsKey(bsl.Billing_Schedule_Header__c))
                	mapBillingScheduleBSLs.put(bsl.Billing_Schedule_Header__c, new List<Billing_Schedule_Line__c>());
                mapBillingScheduleBSLs.get(bsl.Billing_Schedule_Header__c).add(bsl);
	    }
        }
        return mapBillingScheduleBSLs;
    }
    //Added By Mahendra Swarnkar - CR-20210112-14800 - 01/25/2021 - Ends here 
    
    //Modified By Mahendra Swarnkar - CR-20210112-14800 - 01/25/2021 - modified the Method to use the new parameters ("mapBillingScheduleHierarchyBSPRecords" and "mapBillingScheduleHierarchyBSLRecords") to build the Billing hierarchy map.  
    //Populate the wrappers to hold the billing schedule Heirarchy data presentation on the component.  
    public static Map<String, List<BillingScheduleHierarchyWrapper>> fillWrappers(Map<ID, Billing_Schedule_Header__c> mapBillingScheduleHeader, Map<ID, List<Billing_Schedule_Period__c>> mapBillingScheduleHierarchyBSPRecords, Map<ID, List<Billing_Schedule_Line__c>> mapBillingScheduleHierarchyBSLRecords) {
        
        Map<String, List<BillingScheduleHierarchyWrapper>> mapBillingScheduleHierarchyWrappers = new Map<String, List<BillingScheduleHierarchyWrapper>>(); 
        
        if(mapBillingScheduleHeader != null && mapBillingScheduleHeader.size() > 0){
            
            Integer indexCounter = 1;
            String recordLink = URL.getSalesforceBaseUrl().toExternalForm()+'/';
            //.toExternalForm()
            
            for(Billing_Schedule_Header__c bsh : mapBillingScheduleHeader.values()){
            	
                //1. process the billing Schedule Header
                String parentIndex = 'Parent'+indexCounter;

                String blankString = '';
                
                BillingScheduleHierarchyWrapper parent = new BillingScheduleHierarchyWrapper(bsh.Id, parentIndex, bsh.Name, recordLink + bsh.id, bsh.List_Of_Product_Codes__c, blankString, bsh.Contract_Total__c, bsh.Contract_Start_Date__c, bsh.Contract_End_Date__c);
                
                if(!mapBillingScheduleHierarchyWrappers.containsKey('Parent')) 
                    mapBillingScheduleHierarchyWrappers.put('Parent', new List<BillingScheduleHierarchyWrapper>());
                
                mapBillingScheduleHierarchyWrappers.get('Parent').add(parent);
				
				//2. Process the Billing Schedule Periods
				
                Integer countchild = 1;
                Map<Id, String> mapBillingSchedulePeriodIdWithBillingScheduleIndex = new Map<Id, String>();
                Map<Id, Billing_Schedule_Period__c> mapBillingScheduleperiods = new Map<Id, Billing_Schedule_Period__c>();
                
                //Modified By Mahendra Swarnkar - CR-20210112-14800 - 01/25/2021 - Used the Map "mapBillingScheduleHierarchyBSPRecords"
                //Check for Billing Schedule Periods
                if(/*bsh.Billing_Schedule_Periods__r != null*/ 
                    mapBillingScheduleHierarchyBSPRecords != null 
                    && mapBillingScheduleHierarchyBSPRecords.size() > 0
                    && mapBillingScheduleHierarchyBSPRecords.containsKey(bsh.Id)
                    && mapBillingScheduleHierarchyBSPRecords.get(bsh.Id) != null
                    && mapBillingScheduleHierarchyBSPRecords.get(bsh.Id).size() > 0) 
                {
                    for(Billing_Schedule_Period__c bsp : /*bsh.Billing_Schedule_Periods__r*/ mapBillingScheduleHierarchyBSPRecords.get(bsh.Id)) {
                        
                        mapBillingScheduleperiods.put(bsp.Id, bsp);
                        
                        system.debug('@@@@@@@ Start BP :: ' + bsp.Billing_Schedule_Period_Start_Date__c + ' End BP :: ' + bsp.Billing_Schedule_Period_End_Date__c);
                        String childIndex = parentIndex + '.Child' + countchild;
                        
                        mapBillingSchedulePeriodIdWithBillingScheduleIndex.put(bsp.Id, childIndex);
                        
                        BillingScheduleHierarchyWrapper child = new BillingScheduleHierarchyWrapper(bsp.Id, childIndex, bsp.Name, recordLink + '/' + bsp.id, bsp.List_Of_Product_Codes__c, bsp.Billing_Period_Notes__c, bsp.Total_Billing_Amount_For_Period__c, bsp.Billing_Schedule_Period_Start_Date__c, bsp.Billing_Schedule_Period_End_Date__c);
                        if (bsp.Sales_Invoice__c != null) {
                            child.salesInvoiceId = recordLink + bsp.Sales_Invoice__c;
                            child.salesInvoiceName = bsp.Sales_Invoice__r.Name;
                        }
                        child.billDate = (bsp.Billing_Date_Actual__c != null) ? bsp.Billing_Date_Actual__c : bsp.Billing_Date_Calculated__c;
                        
                        if(!mapBillingScheduleHierarchyWrappers.containsKey(parentIndex)) 
                            mapBillingScheduleHierarchyWrappers.put(parentIndex, new List<BillingScheduleHierarchyWrapper>());
                        
                        mapBillingScheduleHierarchyWrappers.get(parentIndex).add(child);
                        
                        countchild++;
                    }
                    
                    //Reset/Re-initiate the counter
                    countchild = 1;
                }
                
                //Modified By Mahendra Swarnkar - CR-20210112-14800 - 01/25/2021 - Used the Map "mapBillingScheduleHierarchyBSLRecords"
                //3. Process the Billing Schedule Lines
                //Check for Billing Schedule Periods
                if(/*bsh.Billing_Schedule_Lines__r != null*/
                	mapBillingScheduleHierarchyBSLRecords != null 
                    	&& mapBillingScheduleHierarchyBSLRecords.size() > 0
                	&& mapBillingScheduleHierarchyBSLRecords.containsKey(bsh.Id)
                	&& mapBillingScheduleHierarchyBSLRecords.get(bsh.Id) != null
                	&& mapBillingScheduleHierarchyBSLRecords.get(bsh.Id).size() > 0) 
                {
                    
                    for(Billing_Schedule_Line__c bsl : /*bsh.Billing_Schedule_Lines__r*/ mapBillingScheduleHierarchyBSLRecords.get(bsh.Id)) {
                        
                        if(bsl.Billing_Schedule_Period__c != null && mapBillingSchedulePeriodIdWithBillingScheduleIndex.size() > 0 
                           && mapBillingSchedulePeriodIdWithBillingScheduleIndex.containsKey(bsl.Billing_Schedule_Period__c)){
                               
                               // Index like
                               String bspIndex = mapBillingSchedulePeriodIdWithBillingScheduleIndex.get(bsl.Billing_Schedule_Period__c);
                               String grandChildIndex = bspIndex + '.GChild'+countchild;
                               
                               BillingScheduleHierarchyWrapper grandChild = new BillingScheduleHierarchyWrapper(bsl.Id,grandChildIndex, bsl.Name, recordLink + '/' + bsl.id, bsl.Parent_Product_with_Product__c, blankString, bsl.Billing_Amount__c, bsl.Billing_Schedule_Period__r.Billing_Schedule_Period_Start_Date__c, bsl.Billing_Schedule_Period__r.Billing_Schedule_Period_End_Date__c);
                               if (bsl.Billing_Schedule_Period__r.Sales_Invoice__c != null) {
                                   grandChild.salesInvoiceId = recordLink + bsl.Billing_Schedule_Period__r.Sales_Invoice__c;
                                   grandChild.salesInvoiceName = bsl.Billing_Schedule_Period__r.Sales_Invoice__r.Name;
                               }
                               grandChild.billDate = (bsl.Billing_Schedule_Period__r.Billing_Date_Actual__c != null) ? bsl.Billing_Schedule_Period__r.Billing_Date_Actual__c : bsl.Billing_Schedule_Period__r.Billing_Date_Calculated__c;
                               
                               if(!mapBillingScheduleHierarchyWrappers.containsKey(bspIndex)) 
                                   mapBillingScheduleHierarchyWrappers.put((bspIndex), new List<BillingScheduleHierarchyWrapper>());
                               
                               mapBillingScheduleHierarchyWrappers.get(bspIndex).add(grandChild);
                               
                               countchild++;           
                           }
                    }
                    
                    //Reset/Re-initiate the counter
                    countchild = 1;
                }
                
                indexCounter ++;       
            }
        }
        
		return mapBillingScheduleHierarchyWrappers;        
    }
}