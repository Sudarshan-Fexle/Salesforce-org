/** 
  * Description     :   Wrapper Class to hold delivery option details
  *	
  * Created By      :   Rajeev Jain(Simplyforce)
  *
  * Created Date    :   03/10/2015
  *
  * Version         :   V1.0 Created
  * 
  **/
public without sharing class DeliveryOptionWrapper implements Comparable{
	
    //Delivery Options Properties
    public String packagePrice{get;set;}
    public String deliveryDate{get;set;}
    public String deliveryTime{get;set;}
    public Integer optionIndex{get;set;}
    public Boolean isRecommended{get;set;}
    public Boolean isAuthorizationRequired{get;set;}
	
	//Properties added on 24/03/2015 for phase 3 items
	//Text Properties
    public String serviceType{get;set;}
    public String serviceTypeName {get;set;}
    public String packagingType{get;set;}
    public String category{get;set;}
    public String deliveryDay{get;set;}
    public String signatureOption{get;set;}
    public String groundServiceDeliveryTime{get;set;}
    
    //Check Properties
    public Boolean available{get;set;}
    public Boolean authorizationRequired{get;set;}
    public Boolean recommended{get;set;}
    public Boolean selected{get;set;}
    
    //Date/DateTime Properties
    public DateTime deliveryDateTime{get;set;}
    
    //Currency
    public Decimal totalNetFreight{get;set;}
    public Decimal totalSurcharges{get;set;}
    public Decimal totalVendorCharges{get;set;}
    public Decimal totalTaxes{get;set;}
    public Decimal totalNetCharge{get;set;}
    
    //Class Constructor for Blank and default Initialization
    public DeliveryOptionWrapper(){}
    
    public DeliveryOptionWrapper(String packagePrice, String deliveryDate, String deliveryTime, Integer optionIndex, Boolean isRecommended, Boolean isAuthorizationRequired){
    	
        this.deliveryDate = deliveryDate; 
        this.packagePrice = packagePrice;
        this.deliveryTime = deliveryTime;
        this.optionIndex = optionIndex;
        this.isRecommended = isRecommended;
        this.isAuthorizationRequired = isAuthorizationRequired;
    }
    public DeliveryOptionWrapper(String serviceType, String packagingType, String category,
                                String deliveryDay, DateTime deliveryDateTime,
                                String signatureOption, Decimal totalNetFreight,
                                Decimal totalSurcharges, Decimal totalTaxes, 
                                Decimal totalNetCharge,Boolean available,Boolean authorizationRequired,
                                String groundServiceDeliveryTime){
                                    
		this.serviceType = serviceType;
        this.packagingType = packagingType;
        this.deliveryDay = deliveryDay;
        this.deliveryDateTime = deliveryDateTime;
        this.signatureOption = signatureOption;
        this.totalNetFreight = totalNetFreight;
        this.totalSurcharges = totalSurcharges;
        this.totalTaxes = totalTaxes;
		this.totalNetCharge = totalNetCharge;
		this.category = category;
		this.groundServiceDeliveryTime = groundServiceDeliveryTime;
                                    
		//Set Defaul false later sorting of list chippest option wouldd be set to Recommended
		recommended = false;
    	isAuthorizationRequired = authorizationRequired;
        
		//Format Total Net Charge
		totalNetCharge = totalNetCharge.setScale(2);
        
		packagePrice = '$' + totalNetCharge;
        if(deliveryDateTime != null){
    		deliveryDate = deliveryDateTime.format('EEE, MMM d');
    		deliveryTime = deliveryDateTime.format('hh:mm a'); 
        }
    }
    public Integer compareTo(Object compareTo){
		
		DeliveryOptionWrapper wrapObj = (DeliveryOptionWrapper)compareTo;
		if(totalNetCharge == wrapObj.totalNetCharge)
			return 0;
		if(totalNetCharge < wrapObj.totalNetCharge)
			return -1;
		return 1;	     
	}
}