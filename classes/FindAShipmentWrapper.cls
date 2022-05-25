/** 
  * Description     :   Inner Wrappeer Class To Hold Ship A Find Package Components Properties 
  * 					Purpose of this wrapper class is to maintain its as an template specially for Ship A find Package component
  *
  * Created By      :   Rajeev Jain(Simplyforce)
  *
  * Created Date    :   03/14/2015
  *
  * Version         :   V1.0 Created
  * 
  **/
public without sharing class FindAShipmentWrapper {
	
    //============================== Cosntants ===============================
	
    //============================== Class Properties ===========================
    //Hold Searched Shipment Record List and Display on the Page
    public List<ShipmentWrapper> searchedShipmentList{
        get{
            
            //Temp List
            List<ShipmentWrapper> shipmentWrapperList = new List<ShipmentWrapper>();
            
            ///Loop get current Selected page records
            if(mapShipmentList.containsKey(userSelectedStep)){
                for(Shipment__c shipmentRecord : mapShipmentList.get(userSelectedStep)){
                	shipmentWrapperList.add(ShipItHelper.getShipmentWrapperInstance(shipmentRecord));	    
                }	    
            }
            
        	return shipmentWrapperList;
        }
	}
    
    //Standard Set Controller
    public Apexpages.Standardsetcontroller setCont{get;set;}
    
    //Map to Hold List of Shipment Object corrosponding to Key
    private Map<Integer,List<Shipment__c>> mapShipmentList = new Map<Integer,List<Shipment__c>>();
    
    //User Selected Step
    public Integer userSelectedStep{get;set;}
    
    //Hold from Date
    public String fromDate{get;set;}
    
    //Hold To Date
    public String toDate{get;set;}
    
    //Hold Search String
    public String searchText{get;set;}
    
    //Hold flag to Show is Result diplayed was default or filtered
    public Boolean isResultFiltered{get;set;}
    
    //Hold Selected Shipment Category either My Shipments or All Shipments
    public String selectedShipmentCategory{get;set;}
    
    //Get the Select Recurrence type
    public List<SelectOption> shipmentCategories {
        get{
            
            //List of select option
            List<SelectOption> options = new List<SelectOption>(); 
            
            options.add(new SelectOption('My Shipments','My Shipments')); 
            options.add(new SelectOption('All Shipments','All Shipments')); 
            return options; 
        }
    }
	
	//property to hold Selected Status
    public String selectedStatus{get;set;}
    
    //Get List of Options for Status field
    public List<SelectOption> shipmentStatusList{
        get{
        	
            //List of select option
            List<SelectOption> options = new List<SelectOption>();
            
            //Add Defualt Option 'All' to fitler the status
            options.add(new SelectOption('All','All'));
            
            options.addAll(ShipItHelper.getSelectOptionListByField('Shipment__c','Status__c')); 
            
            return options;
        }
    }
    
    //Hold Selected Billing Type Status
    public String selectedBillingTypeStatus{get;set;}
    
    //Get List of Options for Status field
    public List<SelectOption> shipmentBillingTypeList{
        get{
        	
            //List of select option
            List<SelectOption> options = new List<SelectOption>();
            
            //Add Defualt Option 'All' to fitler the status
            options.add(new SelectOption('All','All'));
            
            
            //List of select option
            options.addAll(ShipItHelper.getSelectOptionListByField('Shipment__c','Billing_Type__c')); 
            
            return options;
        }
    }
    
    //Class Constructor
    public FindAShipmentWrapper(){
        
		defaultSearch();
    }
    
    /**
	*  @description    :   Method for default Search
    * 			
    *  @args           :   
    * 
    *  @return         :   void
    * 
    **/
    private void defaultSearch(){
    	
        //Default Values
        userSelectedStep = 1;
        selectedShipmentCategory = 'My Shipments';
        fromDate = '';
        toDate = '';
        searchText = '';
        isResultFiltered = false;
        
		//Default Search 
        List<Shipment__c> searchedResult = ShipItHelper.searchDefaultShipments(ShipItHelper.DEFAULT_PAGE_SIZE);
        System.debug('Check searchedResult Size :: ' + searchedResult.size()); 
        //Temp List to Hold Instances of Shipment object
        List<Shipment__c> tempShipmentList = new List<Shipment__c>();
       
        Integer counter = 1;
        mapShipmentList = new Map<Integer,List<Shipment__c>>();
         	
        //Loop over searched Result
        for(Integer i=0;i<searchedResult.size();i++){
            tempShipmentList.add(searchedResult[i]);
            if(i==ShipItHelper.DEFAULT_PAGE_SIZE-1){
                mapShipmentList.put(counter,tempShipmentList);
                tempShipmentList = new List<Shipment__c>();
                counter++;
            }
        }
        if(tempShipmentList.size()>0){
			mapShipmentList.put(counter,tempShipmentList);   
        }
        
        //searchShipments();
    }
    
   /**
	*  @description    :   Method to Search All Shipment Records Using Search Shipment data and fill the Shipment List
    * 			
    *  @args           :   
    * 
    *  @return         :   void
    * 
    **/
    public void searchShipments(){
		
        try{
            
			//System.debug('Check for From Date ::: ' + Date.valueOf('2015-03-15'));
        	
            Integer limitData = Integer.valueOf(ShipItHelper.shipItSettings.get('ContactSearchLimit').value__c);
            
            //Call Helper Class method and Serch the Shipment Records(Filter Search) 
            List<Shipment__c> searchedReuslts = ShipItHelper.searchFilteredShipments(selectedStatus, selectedBillingTypeStatus, searchText, limitData, selectedShipmentCategory,fromDate,toDate);
            
            //Temp List to Hold Instances of Shipment object
            List<Shipment__c> tempShipmentList = new List<Shipment__c>();
            
            //Reset User Selected Step
            userSelectedStep = 1;
            
            //Initialize
            Integer counter = 1;
            mapShipmentList = new Map<Integer,List<Shipment__c>>();
            
            //Loop over searched Result
            for(Integer i=0;i<searchedReuslts.size();i++){
                
                tempShipmentList.add(searchedReuslts[i]);
                
                if(tempShipmentList.size() == ShipItHelper.DEFAULT_PAGE_SIZE){
                    
                    mapShipmentList.put(counter,tempShipmentList);
                    tempShipmentList = new List<Shipment__c>();
                    counter++;
                }
            }
            if(tempShipmentList.size()>0){
                mapShipmentList.put(counter,tempShipmentList);   
            }
            //Set flag to true
            isResultFiltered = true;
            
        }catch(Exception e){
            ShipItHelper.displayErrorMessages(e.getMessage());
        }
    }
    
   /**
	*  @description    :   Method to Clear Search Results and Set to Defual State
    * 			
    *  @args           :   
    * 
    *  @return         :   void
    * 
    **/
    public void clearSearch(){
        
        defaultSearch();
    }
    
   /**
	*  @description    :   Method to return whether previous page exists
    * 			
    *  @args           :   
    * 
    *  @return         :   Boolean flag
    * 
    **/
    public Boolean hasPrevious{
        get{
            
            //Get List from map and if size is greater then zero means its have previous
            List<Shipment__c> shipmentList = mapShipmentList.get(userSelectedStep-1);
			if( shipmentList != null && shipmentList.size() >0)
                return true;
            return false;
        }
    }
    
   /**
	*  @description    :   Method to return whether next page exists
    * 			
    *  @args           :   
    * 
    *  @return         :   Boolean flag
    * 
    **/
    public Boolean hasNext{
        get{
            //Get List from map and if size is greater then zero means its have previous
            List<Shipment__c> shipmentList = mapShipmentList.get(userSelectedStep+1);
			if( shipmentList != null && shipmentList.size() >0)
                return true;
            return false;
        }
    }
    
   /**
	*  @description    :   Method to get Page Number
    * 			
    *  @args           :   
    * 
    *  @return         :   void
    * 
    **/	
    public Integer pageNumber{
        get{
            return userSelectedStep;
        }
    }
   
    /* List To hold Total Paging Numbers */ 
    public List<Integer> pagingNumbers{
        get{
            List<Integer> numbers = new List<Integer>();
            for(Integer i=1;i<=mapShipmentList.size();i++){
                numbers.add(i);
            }
            return numbers;       
        }
    }
    
    public void setSelectedStep(){
        userSelectedStep = userSelectedStep;
    }
}