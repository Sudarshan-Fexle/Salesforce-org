/** 
  * Description     :   Wrapper Class to Pass Map in ShipIt Package Component.
  *						Purpose of this class is just to define a type in component attribute so map can be pass to the component.
  *	
  * Created By      :   Rajeev Jain(Simplyforce)
  *
  * Created Date    :   03/04/2015
  *
  * Version         :   V1.0 Created
  * 
  **/
public without sharing class MapPackageWrapper{
	
	//Map holds list of package types corrosponding to its row count    
    public Map<Integer,List<ShipIt_PackageType__c>> mapAllPackages{get;set;}
    
    //Map holds list of delivery options corrosponding to box counter
    public Map<Integer,List<DeliveryOptionWrapper>> mapDeliveryOptions{get;set;}
    
    //Holds size of the list in one box of delivery options
    public Integer numberOfItems{get;set;}
    
    //Hold Index of Selected Delivery Items
    public Integer selectedOptionIndex{get;set;}
    
    //Class Constructor
    public mapPackageWrapper(Map<Integer,List<ShipIt_PackageType__c>> mapAllPackages){
        this.mapAllPackages =  mapAllPackages;  
        mapDeliveryOptions = new Map<Integer,List<DeliveryOptionWrapper>>();
    }
    public mapPackageWrapper(Map<Integer,List<DeliveryOptionWrapper>> mapDeliveryOptions){
        this.mapDeliveryOptions = mapDeliveryOptions;
    	mapAllPackages = new Map<Integer,List<ShipIt_PackageType__c>>();
    }
    //
}