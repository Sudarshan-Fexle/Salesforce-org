/** 
  * Description     :   Class containing functions to interact with the Salesforce data objects.
  * 					This class is used as utility for Ship it main Controller.  
  * 					Class must be defined as ‘without sharing’ and will contain data class definitions for the data sets (Recipient fields, etc)
  *
  * Created By      :   Rajeev Jain(Simplyforce)
  *
  * Created Date    :   03/03/2015
  *
  * Version         :   V1.0 Created
  * 				:	V1.1(04/29/2015) Modified-Rajeev Jain : updated search criteria for find a shipment to include those records where source ='Shipit'.
  *						Updated Find a Shipment Error message constants
  *						V1.2 - Modified By - Mahendra Swarnkar - 11/28/2017 - CR-20171019-11731
  *						
  **/
public without sharing class ShipItHelper {
	
    //Class Constants
    //Shipment Status
    public static final String SHIPMENT_STATUS_PENDING_AUTHORIZATION = 'Pending Authorization';
    public static final String SHIPMENT_STATUS_READY = 'Ready';
    public static final String SHIPMENT_STATUS_IN_PROGRESS = 'In Progress';
    public static final String SHIPMENT_STATUS_SHIPPED = 'Shipped';
    public static final String SHIPMENT_STATUS_ALL = 'All';
    public static final String SHIPMENT_STATUS_NEW = 'New';
    public static final String SHIPMENT_STATUS_DELIVERED = 'Delivered';
    public static final String SHIPMENT_STATUS_CANCELLED = 'Cancelled';
    public static final String SHIPMENT_STATUS_READY_TO_PRINT = 'Ready to Print';
    public static final String SHIPMENT_STATUS_LABEL_PRINTED = 'Label Printed';
    
    //Authorization Status
    public static final String SHIPMENT_AUTHORIZATION_STATUS_REQUESTED = 'Requested';
    public static final String SHIPMENT_AUTHORIZATION_STATUS_AUTHORIZED = 'Authorized';
    public static final String SHIPMENT_AUTHORIZATION_STATUS_NO_AUTHORIZATION_NEEDED = 'No Authorization Needed';
    public static final String SHIPMENT_AUTHORIZATION_STATUS_DENIED = 'Denied';
    public static final String SHIPMENT_AUTHORIZATION_STATUS_INVALID = 'Invalid';
    
    //Error Message
    //Rajeev Jain - 04/29/2015 : updated text in constants
    public static final String FROM_DATE_MUST_BE_LESS_THEN_TO_DATE_OR_TODAY = 'Ship Date - End must be later than Ship Date - Start';
    public static final String TO_DATE_MUST_BE_GREATER_THEN_FROM_DATE_OR_TODAY = 'Ship Date – End must be after the Ship Date – Start';
    
    //Hold Search Limit, Later it can be moved in custom setting
    public final static Integer FIND_A_SHIPMENT_SEARCH_LIMIT = 250;
    
    //Pagination Properties
     
    //Page Size number of Record to be displayed on single page
    public final static Integer SEARCH_RESULTS_PAGE_SIZE = 10;
    
    //Default Page Size while Page Load
    public final static Integer DEFAULT_PAGE_SIZE = 10;
    
    //Modified by Mahendra Swarnkar - 05/08/2020 - Delivery_Ineligible_For_Guarantee__c,edi_batch_id__c, 
    //Hold_Shipment_at_FedEx_Location__c,insurance_amount__c
    //deleted from object Shipment__c - CR-20200218-13769
    //Defaul SOSL (Later it can be mover in custom Label)
    public static final String defaultSOSLFields = 'Id, Name, Accept_Billing_Agreement__c,  Add_Default_Insurance__c,  Address_Validation__c,  Authorization_Reason__c,  Authorization_Request_Date__c,'  
                                          +'Authorization_Requested_From__c,  Authorization_Response_Date__c,  Authorization_Status__c,  Authorized_By__c,  Billing_Batch_Id__c,  Billing_Status__c, '
                                          +'Billing_Type__c,  Bill_To__c,  Declared_Value__c,  Delivery_Date__c, Delivery_Date_Actual__c, '
                                          +'Label_Printed_Date__c,  Package_Code__c,  Package_Depth_in__c,  Package_Length_in__c,  Package_Type__c,  Package_Width_in__c, '
                                          +'Personal_Billing__c,  Recipient__c,  Recipient_Address_Line_1__c,  Recipient_Address_Line_2__c,  Recipient_City__c,  Recipient_Company__c,  Recipient_Email__c, '
                                          +'Recipient_First_Name__c,  Recipient_Last_Name__c,  Recipient_Name__c,  Recipient_Phone__c,  Recipient_PostalCode__c,  Recipient_Selection_Method__c,'
                                          +'Recipient_State_Province__c,  Sender__c,  Sender_Address_Line_1__c,  Sender_Address_Line_2__c,  Sender_City__c,  Sender_Company__c,  Sender_Cost_Center__c,'
                                          +'Sender_Department__c,  Sender_Email__c,  Sender_Finance_Code__c,  Sender_First_Name__c,  Sender_Last_Name__c,  Sender_Name__c,  Sender_Office_Code__c,'
                                          +'Sender_Office_Name__c,  Sender_Phone__c,  Sender_PostalCode__c,  Sender_Secondary_Email__c,  Sender_State_Province__c,  Ship_Amount__c,  Ship_Amount_Actual__c,  '
                                          +'Ship_Date__c,  Ship_Date_Actual__c,  Ship_Day__c, Ship_Method__c,  Ship_Method_Category__c,  Signature_Requirement__c, Status__c, Address_Classification__c,'
                                          +'Tracking_Number__c,  Vendor_Package__c,  Weight_Actual__c,  Weight_Estimated__c, Delivery_Date_Text__c, Delivery_Service_Description__c';
	
    //======================================== FedEx Constants Properties ===================================
    //Hold Success or Error String in the resposne from the fed Ex
    public static final String FED_INTEGRATION_RESPONSE_SUCCESS = 'SUCCESS';
    public static final String FED_INTEGRATION_RESPONSE_ERROR = 'ERROR';
    public static final String FED_INTEGRATION_RESPONSE_NOTE = 'NOTE';
	public static final String FED_INTEGRATION_RESPONSE_WARNING = 'WARNING';
    public static final String FED_INTEGRATION_RESPONSE_FAILURE = 'FAILURE';
    
    //Address Validation Attribute Constants
    public static final String VALIDATION_ATTRIBUTE_RESOLVED = 'Resolved';
    public static final String VALIDATION_ATTRIBUTE_POSTALVALIDATED = 'PostalValidated';
    public static final String VALIDATION_ATTRIBUTE_CITYSTATEVALIDATED = 'CityStateValidated';
    public static final String VALIDATION_ATTRIBUTE_STREETVALIDATED = 'StreetValidated';
    public static final String VALIDATION_ATTRIBUTE_STREETRANGEVALIDATED = 'StreetRangeValidated';
    public static final String VALIDATION_ATTRIBUTE_INVALIDSUITNUMBER = 'InvalidSuiteNumber';
    
    //Validation Status
    public static final String VALIDATION_STATUS_NOCHANGE = 'No Change';
    public static final String VALIDATION_STATUS_PASSED = 'Passed';
    public static final String VALIDATION_STATUS_RESOLVED = 'Resolved';
    public static final String VALIDATION_STATUS_WARNING = 'Warning';
    
    //Hold list of attribute for comparision for ship it app, which is used as listed attributes.
    //Specifies the address validation attribute name.  The attributes used by the ShipIt App
    public static final Set<String> listedAttributes = new Set<String>{ShipItHelper.VALIDATION_ATTRIBUTE_RESOLVED.toLowerCase(),
        																ShipItHelper.VALIDATION_ATTRIBUTE_POSTALVALIDATED.toLowerCase(),
        																ShipItHelper.VALIDATION_ATTRIBUTE_CITYSTATEVALIDATED.toLowerCase(),
        																ShipItHelper.VALIDATION_ATTRIBUTE_STREETVALIDATED.toLowerCase(),
        																ShipItHelper.VALIDATION_ATTRIBUTE_STREETRANGEVALIDATED.toLowerCase(),
        																ShipItHelper.VALIDATION_ATTRIBUTE_INVALIDSUITNUMBER.toLowerCase()};
	
	//Modified By Mahendra Swarnkar - 11/28/2017 - CR-20171019-11731 - Starts from here
	//Constants to Maintain Ship It Setting Name
	//Constancts to Hold Production Setting name
	public static String CurrentUserEntity  = (getSenderInformation(UserInfo.getUserId()))[0].Entity__c;
    public static final String FEDEX_KEY = CurrentUserEntity == 'EAB' ? 'Key_EAB' : 'Key';
    public static final String FEDEX_PASSWORD = CurrentUserEntity == 'EAB' ? 'Password_EAB' : 'Password';
    public static final String FEDEX_AccountNumber = CurrentUserEntity == 'EAB' ? 'AccountNumber_EAB' : 'AccountNumber';
    public static final String FEDEX_MeterNumber = CurrentUserEntity == 'EAB' ? 'MeterNumber_EAB' : 'MeterNumber'; 
    //Modified By Mahendra Swarnkar - 11/28/2017 - CR-20171019-11731 - Ends here
    
    //Property Says which credentials needs to be used in integration with FedEx
    public static final String FEDEX_USE_PRODUCTION_CREDENTIALS = 'UseProductionFedExCredentials'; 
    
    //Constant to Hold Production End Points Key name, Get from Ship It settings
    public static final String FEDEX_ENDPOINT_ADDRESSVALIDATION_PROD = 'FedExEndPointAddressValidation';
    public static final String FEDEX_ENDPOINT_RATESERVICE_PROD = 'FedExEndPointRateService';
    public static final String FEDEX_ENDPOINT_SHIPSERVICE_PROD = 'FedExEndPointShipService';
    
    //Constant to Hold Test End Points Key name, Get from Ship It settings
    public static final String FEDEX_ENDPOINT_ADDRESSVALIDATION_TEST = 'TestFedExEndPointAddressValidation';
    public static final String FEDEX_ENDPOINT_RATESERVICE_TEST = 'TestFedExEndPointRateService';
    public static final String FEDEX_ENDPOINT_SHIPSERVICE_TEST = 'TestFedExEndPointShipService';
    
    //Modified By Mahendra Swarnkar - 11/28/2017 - CR-20171019-11731 - Starts from here
    //Sandbox Settings Name
    public static final String FEDEX_TEST_KEY = CurrentUserEntity == 'EAB' ? 'TestKey_EAB' : 'TestKey';
    public static final String FEDEX_TEST_PASSWORD = CurrentUserEntity == 'EAB' ? 'TestPassword_EAB' : 'TestPassword';
    public static final String FEDEX_TEST_AccountNumber = CurrentUserEntity == 'EAB' ? 'TestAccountNumber_EAB' : 'TestAccountNumber';
    public static final String FEDEX_TEST_MeterNumber = CurrentUserEntity == 'EAB' ? 'TestMeterNumber_EAB' : 'TestMeterNumber';
    //Modified By Mahendra Swarnkar - 11/28/2017 - CR-20171019-11731 - Ends here
    
    public static final String VERSIONSERVICEID_ADDRESSSERVICE = 'VersionServiceIdAddressServie';
    public static final String VERSIONMAJORID_ADDRESSSERVICE = 'VersionMajorAddressServie';
    public static final String VERSIONINTERMEDIATE_ADDRESSSERVICE = 'VersionIntermediateAddressServie';
    public static final String VERSIONMINOR_ADDRESSSERVICE = 'VersionMinorAddressServie';
    
    //Rate Service Constants to Hole Name of Ship It Setting Data
    public static final String VERSIONSERVICEID_RATESERVICE = 'VersionServiceIdRateService';
    public static final String VERSIONMAJORID_RATESERVICE = 'VersionMajorRateService';
    public static final String VERSIONINTERMEDIATE_RATESERVICE = 'VersionIntermediateRateService';
    public static final String VERSIONMINOR_RATESERVICE = 'VersionMinorRateService';
    
    public static final String VERSIONSERVICEID_SHIPSERVICE = 'VersionServiceIdShipService';
    public static final String VERSIONMAJORID_SHIPSERVICE = 'VersionMajorShipService';
    public static final String VERSIONINTERMEDIATE_SHIPSERVICE = 'VersionIntermediateShipService';
    public static final String VERSIONMINOR_SHIPSERVICE = 'VersionMinorShipService';
    
    //Modified By Mahendra Swarnkar - 11/28/2017 - CR-20171019-11731 - Starts from here
    public static final String SENDERCOMPANYNAME = CurrentUserEntity == 'EAB' ? 'SenderCompanyName_EAB' : 'SenderCompanyName';
    //Modified By Mahendra Swarnkar - 11/28/2017 - CR-20171019-11731 - Ends here
    
    public static final String SENDERCOUNTRYCODE = 'SenderCountryCode';
    public static final String RECIPIENTCOUNTRYCODE = 'RecipientCountryCode';
    public static final String RATEREQUESTTYPE = 'RateRequestType';
    public static final String CURRENCY_USD = 'USD';
	public static final String WEIGHTUNITSTRING = 'WeightUnits';
    public static final String DIMENSION_UNITE = 'DimensionUnits';
    public static final String DEFAULTINSURENCE = 'DefaultInsurance'; 
    
    public static final String SHIPMENT_TIME = 'ShipmentTime';
    
    //Class Constructor
    public ShipItHelper(){}
    
    /**
     *  @description    :   This method is to get the user iformation which is identified as Recciever in ship It app.
     * 						This method is called from Ship It main Controller and return contact information to it.
     * 				
     *  @args           :   Contact Id selected on Ship It app
     * 
     *  @return         :   List of Contacts
     * 
     **/
    public static List<Contact> getRecipientInformation(String contactId){
    	//Added Company__c - By Dipesh Gupta - CR-20190503-13079 - Spring clean Up Round 1
        List<Contact> contacts = [select Id, FirstName, Company__c, LastName, Name, Contact.Account.Account_Formal_Name__c,
                                 		Primary_Address_Line_1__c, Primary_Address_Line_2__c, Primary_Address_Line_3__c,
                                 		Primary_City__c, Primary_State_Province__c, Primary_Postal_Code__c, Phone, Email
                                 		from Contact where Id = :contactId];
        return contacts;
    }
    
    /**
     *  @description    :   This method is to get the user iformation which is identified as sender in ship It app.
     * 						This method is called from Ship It main Controller and return User information to it.
     * 				
     *  @args           :   Logged in User Id
     * 
     *  @return         :   List of Users
     * 
     **/
    public static List<User> getSenderInformation(String userId){
        
        //Modified By Mahendra Swarnkar - 11/28/2017 - CR-20171019-11731 - Modified the Query to fetch the Entity__c field value for the user 
        List<User> users = [select Id, FirstName, LastName, Name, Street, City, State, PostalCode, Phone, Email, Entity__c,
                            		Finance_Code__c, ABC_Department__c, Cost_Center__c, Location_Code__c, Workspace_Office__c, Office__c	
                           			from User where Id = :userId];
        
        return users;
    }
    
    /**
     *  @description    :   This method return ShipIt PackageType custom Setting Data
     * 				
     *  @args           :   
     * 
     *  @return         :   List of Packages
     * 
     **/
    public static List<ShipIt_PackageType__c> getShipItPackageTypes(){
        List<ShipIt_PackageType__c> mcs = [select Name, Active__c, Package_Description__c, Package_Full_Name__c, Package_Image__c,
                                          			Is_Custom__c, Weight_Limit__c 
                                           			from ShipIt_PackageType__c where Active__c = true order by Is_Custom__c ASC];
        return mcs;
    }
	
    /**
     *  @description    :   This method return ShipIt PackageType custom Setting Instance based on Name passed to it
     * 				
     *  @args           :   Logged in User Id
     * 
     *  @return         :   List of Users
     * 
     **/
    public static ShipIt_PackageType__c getSelectedPackageInstance(String name){
		
		ShipIt_PackageType__c shipPackage = ShipIt_PackageType__c.getInstance(name);
		
		return shipPackage;        
    }
    
    /**
     *  @description    :   This method return ShipIt PackageType custom Setting Instance based on Full Name passed to it
     * 				
     *  @args           :   Logged in User Id
     * 
     *  @return         :   List of Users
     * 
     **/
    public static ShipIt_PackageType__c getSelectedPackageInstanceByFullName(String FullName){
		 
		List<ShipIt_PackageType__c> mcs = [select Name, Active__c, Package_Description__c, Package_Full_Name__c, Package_Image__c,
                                          			Is_Custom__c, Weight_Limit__c 
                                           			from ShipIt_PackageType__c where Package_Full_Name__c = :FullName];
        
		
		return mcs[0];        
    }
    
    /**
     *  @description    :   Method to save ship It Record on various stage of the ship it app.
     * 				
     *  @args           :   Shipment Object Reference, Stage of shipIt App.
     * 
     *  @return         :   void
     * 
     **/
    public static void shipItSaveData(Shipment__c shipment,String stage){
        
        if(shipment != null){
            
            try{
                
                //Update or insert shipment record
                upsert shipment;
            }catch(Exception e){
            	displayErrorMessages(e.getMessage());    
            }
        }
    }
    
    /**
     *  @description    :   Method to update ship it record with authorization status and send email to Authorizer
     * 				
     *  @args           :   Authorizer user Id , Stage of shipIt App.
     * 
     *  @return         :   void
     * 
     **/
    public static void sendRequestForAuthorization(String selectedUserId, Shipment__c shipment){
    	
        //Fill Authorization Details on Shipment Record while sending request for authorization
        shipment.Authorization_Requested_From__c = Id.valueOf(selectedUserId);
        shipment.Authorization_Request_Date__c = DateTime.now();
        shipment.Status__c = ShipItHelper.SHIPMENT_STATUS_PENDING_AUTHORIZATION;
        shipment.Authorization_Status__c = ShipItHelper.SHIPMENT_AUTHORIZATION_STATUS_REQUESTED;
        
        upsert shipment;
    }
    
    /**
     *  @description    :   Method to populate Shipment info based on Shipment Id passed to it.
     * 				
     *  @args           :   Shipment Id
     * 
     *  @return         :   List of Shipment Records
     * 
     **/
    public static List<Shipment__c> populateShipmentData(String shipmentId){
        
        //Modified by Mahendra Swarnkar - 05/08/2020 - Delivery_Ineligible_For_Guarantee__c, edi_batch_id__c, 
        //Hold_Shipment_at_FedEx_Location__c,insurance_amount__c
        //deleted from object Shipment__c - CR-20200218-13769
        //Get Shipment Data based on Id passed in method
        List<Shipment__c> shipmentList = [select Id, Name, Accept_Billing_Agreement__c,  Add_Default_Insurance__c,  Address_Validation__c,  Authorization_Reason__c,  Authorization_Request_Date__c,  
                                          Authorization_Requested_From__c,  Authorization_Response_Date__c,  Authorization_Status__c,  Authorized_By__c,  Billing_Batch_Id__c,  Billing_Status__c, 
                                          Billing_Type__c,  Bill_To__c,  Declared_Value__c,  Delivery_Date__c, Delivery_Date_Actual__c,  /*EDI_Batch_Id__c,  Hold_Shipment_at_FedEx_Location__c,*/  
                                          /*Insurance_Amount__c,*/  Label_Printed_Date__c,  Package_Code__c,  Package_Depth_in__c,  Package_Length_in__c,  Package_Type__c,  Package_Width_in__c,  
                                          Personal_Billing__c,  Recipient__c,  Recipient_Address_Line_1__c,  Recipient_Address_Line_2__c,  Recipient_City__c,  Recipient_Company__c,  Recipient_Email__c,  
                                          Recipient_First_Name__c,  Recipient_Last_Name__c,  Recipient_Name__c,  Recipient_Phone__c,  Recipient_PostalCode__c,  Recipient_Selection_Method__c, 
                                          Recipient_State_Province__c,  Sender__c,  Sender_Address_Line_1__c,  Sender_Address_Line_2__c,  Sender_City__c,  Sender_Company__c,  Sender_Cost_Center__c,  
                                          Sender_Department__c,  Sender_Email__c,  Sender_Finance_Code__c,  Sender_First_Name__c,  Sender_Last_Name__c,  Sender_Name__c,  Sender_Office_Code__c,  
                                          Sender_Office_Name__c,  Sender_Phone__c,  Sender_PostalCode__c,  Sender_Secondary_Email__c,  Sender_State_Province__c,  Ship_Amount__c,  Ship_Amount_Actual__c,  
                                          Ship_Date__c,  Ship_Date_Actual__c,  Ship_Day__c, Ship_Method__c,  Ship_Method_Category__c,  Signature_Requirement__c, Status__c, Address_Classification__c, 
                                          Tracking_Number__c,  Vendor_Package__c,  Weight_Actual__c,  Weight_Estimated__c, Delivery_Date_Text__c, /*Delivery_Ineligible_For_Guarantee__c,*/ Delivery_Service_Description__c
                                          from Shipment__c where Id = :shipmentId];
        return shipmentList;
    }
    
    /**
     *  @description    :   Method to update the response from User for request authorization
     * 				
     *  @args           :   Shipment Id
     * 
     *  @return         :   void
     * 
     **/
    public static void updateAuthorizationResposne(Shipment__c shipment,Boolean isAuthorized){
        
        //If Request was authorized then update shipment according to that 
        if(isAuthorized){
            
            shipment.Status__c = ShipItHelper.SHIPMENT_STATUS_READY_TO_PRINT;
            shipment.Authorization_Status__c = ShipItHelper.SHIPMENT_AUTHORIZATION_STATUS_AUTHORIZED;
            shipment.Authorization_Response_Date__c = DateTime.now();
            shipment.Authorized_By__c = UserInfo.getUserId();
        }else{
            shipment.Status__c = ShipItHelper.SHIPMENT_STATUS_NEW; 
            shipment.Authorization_Status__c = ShipItHelper.SHIPMENT_AUTHORIZATION_STATUS_DENIED;
            shipment.Authorization_Response_Date__c = DateTime.now();
            shipment.Authorized_By__c = UserInfo.getUserId();
        }
        
        upsert shipment;
    }
    
    /**
     *  @description    :   These method is used to display Error Messages on Page.
     *
     *  @args           :	Error Message as a String
     *
     *  @return         :   void
     *
     **/
     public static void displayErrorMessages(String msg){
        
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,msg);            
        ApexPages.addMessage(myMsg);        
     } 
     
     /**
     *  @description    :   These method is used to display Info on the Page.
     *
     *  @args           :	Information Message as String
     *
     *  @return         :   void
     *
     **/
     public static void displayInfoMessages(String msg){
        
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,msg);            
        ApexPages.addMessage(myMsg);        
     } 
	
    /**
     *  @description    :   Method to get Record Type Instance based on its name passed to it
     *
     *  @args           :	Information Message as String
     *
     *  @return         :   void
     *
     **/
    public static RecordType getRecordType(String recordTypeName){
    	
        //Query to get Record Type
        List<RecordType> recordTypes = [select Id, Name from RecordType 
                                        where DeveloperName = :recordTypeName];
        
        if(recordTypes.size() > 0){
            return recordTypes[0];
        } 
        return null;
    }
    
    /**
     *  @description    :   Method to send Shipment Details to FedEx and Print Shipping Label
     *
     *  @args           :	Shipment Object Instance
     *
     *  @return         :   Boolean Flag, states about success and failure
     *
     **/
    /*public static Boolean sendShipmentAndPrintLabel(Shipment__c shipment){
        Shipment.Status__c = ShipItHelper.SHIPMENT_STATUS_SHIPPED;
        Shipment.Label_Printed_Date__c = DateTime.now();
        
        //Update Shipment with Latest Status
        upsert shipment;
        
        //Return a flag  based on Succesfull call to FedExd
        //Currently As per phase 2 we are resending success message as hardcoded in phase 3 it would be a dyanmic
        return false;
    }*/
    
    /**
     *  @description    :   Method to return most recently shipment Records, no filter criteria is applied.
     *
     *  @args           :	Shipment Object instanct,Serach Text, Limit of Records return, Shipment Category(My Shipment or All Shipment)
     *
     *  @return         :   Search Results List
     *
     **/
    public static List<Shipment__c> searchDefaultShipments(Integer searchLimit){
        //Modified by Mahendra Swarnkar - 05/08/2020 - Delivery_Ineligible_For_Guarantee__c, edi_batch_id__c,
        //Hold_Shipment_at_FedEx_Location__c,insurance_amount__c 
        //deleted from object Shipment__c - CR-20200218-13769
        //(04/29/2015 Rajeev Jain) Updated Search Criteria to include records where source = 'ShipIt'
        List<Shipment__c> shipments = [select Id, Name, Accept_Billing_Agreement__c,  Add_Default_Insurance__c,  Address_Validation__c,  Authorization_Reason__c,  Authorization_Request_Date__c,  
                                          Authorization_Requested_From__c,  Authorization_Response_Date__c,  Authorization_Status__c,  Authorized_By__c,  Billing_Batch_Id__c,  Billing_Status__c, 
                                          Billing_Type__c,  Bill_To__c,  Declared_Value__c,  Delivery_Date__c, Delivery_Date_Actual__c,  /*EDI_Batch_Id__c, Hold_Shipment_at_FedEx_Location__c,*/  
                                          /*Insurance_Amount__c,*/  Label_Printed_Date__c,  Package_Code__c,  Package_Depth_in__c,  Package_Length_in__c,  Package_Type__c,  Package_Width_in__c,  
                                          Personal_Billing__c,  Recipient__c,  Recipient_Address_Line_1__c,  Recipient_Address_Line_2__c,  Recipient_City__c,  Recipient_Company__c,  Recipient_Email__c,  
                                          Recipient_First_Name__c,  Recipient_Last_Name__c,  Recipient_Name__c,  Recipient_Phone__c,  Recipient_PostalCode__c,  Recipient_Selection_Method__c, 
                                          Recipient_State_Province__c,  Sender__c,  Sender_Address_Line_1__c,  Sender_Address_Line_2__c,  Sender_City__c,  Sender_Company__c,  Sender_Cost_Center__c,  
                                          Sender_Department__c,  Sender_Email__c,  Sender_Finance_Code__c,  Sender_First_Name__c,  Sender_Last_Name__c,  Sender_Name__c,  Sender_Office_Code__c,  
                                          Sender_Office_Name__c,  Sender_Phone__c,  Sender_PostalCode__c,  Sender_Secondary_Email__c,  Sender_State_Province__c,  Ship_Amount__c,  Ship_Amount_Actual__c,  
                                          Ship_Date__c,  Ship_Date_Actual__c,  Ship_Day__c, Ship_Method__c,  Ship_Method_Category__c,  Signature_Requirement__c, Status__c,  
                                          Tracking_Number__c,  Vendor_Package__c,  Weight_Actual__c,  Weight_Estimated__c, Delivery_Date_Text__c, CreatedDate,
                                       	  Delivery_Service_Description__c, /*Delivery_Ineligible_For_Guarantee__c,*/ Address_Classification__c
                                          from Shipment__c where ownerId = :UserInfo.getUserId() AND Source__c = 'ShipIt' order by CreatedDate DESC LIMIT :searchLimit];
        	
        return shipments;
    }
    
    /**
     *  @description    :   Method to Search Shipment record based on criteria passed to it using SOSl.
     *
     *  @args           :	Shipment Object instanct,Serach Text, Limit of Records return, Shipment Category(My Shipment or All Shipment)
     *
     *  @return         :   Search Results List
     *
     **/ 
	public static List<Shipment__c> searchFilteredShipments(String selectedStatus, String selectedBillingType, String searchText, Integer searchLimit, String shipmentCategory,String fromDate,String toDate){
        
        String fullSOSL = ShipItHelper.defaultSOSLFields;
        
        //Add Defualt Where clause
        fullSOSL += ' where Name != null AND Source__c = \'ShipIt\'';
        
        String searchSOSL = '';
        
        ///Check if Status is applied 
        if(String.isNotBlank(selectedStatus) && !selectedStatus.equalsIgnoreCase('All')){
            fullSOSL =  fullSOSL + ' AND Status__c = \'' + selectedStatus + '\'';   
        }
        
        //Check if Billintype is Applied
        if(String.isNotBlank(selectedBillingType) && !selectedBillingType.equalsIgnoreCase('All')){
            fullSOSL = fullSOSL + ' AND Billing_Type__c = \'' + selectedBillingType + '\'';       
        }
       
        //Check for If Shiment Category is not null
        if(String.isNotBlank(shipmentCategory)){
            
            //Check if Shipment Category is personal or my shipment 
            if(shipmentCategory.equals('My Shipments')){
            	
                //This Filter Later will be implemented
                fullSOSL = fullSOSL + ' AND OwnerId = \'' + UserInfo.getUserId() + '\'';       
            }
        }
        
        //From Date and to date will also be implemented later
        if(String.isNotBlank(fromDate) && String.isBlank(toDate) && fromDate.contains('/')){
            
            //Convert Date string in salesforce convertible format
            List<String> fromDateArr = fromDate.split('/');
            
            if(fromDateArr.size() > 0 && fromDateArr.size() <= 3){
            	
                //Type Cast Date String to Date format
                Date fromDateActual = Date.valueOf(fromDateArr[2] + '-' + fromDateArr[0] + '-' + fromDateArr[1]);
                
                //Set Today if found null
                Date toDateActual = Date.today();
                
                //Check if From Date is less then toDate
                if(fromDateActual <= toDateActual){
                    fullSOSL = fullSOSL + ' AND Ship_Date__C >= :fromDateActual AND Ship_Date__C <= :toDateActual';       
                }else{
                    
                    //Display Message in case of From date is greate then to Data or today
                    ShipItHelper.displayErrorMessages(ShipItHelper.FROM_DATE_MUST_BE_LESS_THEN_TO_DATE_OR_TODAY);
                }
            }
            
        }else if(String.isNotBlank(toDate) && String.isBlank(fromDate) && toDate.contains('/')){
            
            //Convert from Date string to Date format
            List<String> toDateArr = toDate.split('/');
            
            if(toDateArr.size() > 0 && toDateArr.size() <= 3){
            	
                //Type cast in salesforce convertible format
                Date toDateActual = Date.valueOf(toDateArr[2] + '-' + toDateArr[0] + '-' + toDateArr[1]);
                
                //Set today if found null
                Date FromDateActual = Date.today();
                
                //Compare two date and here TO date must be greater then from date or today
                if(toDateActual >= FromDateActual){
                    fullSOSL = fullSOSL + ' AND Ship_Date__C >= :fromDateActual AND Ship_Date__C <= :toDateActual';       
                }else{
                	
                    //Display Message in case of From date is greate then to Data or today
                    ShipItHelper.displayErrorMessages(ShipItHelper.TO_DATE_MUST_BE_GREATER_THEN_FROM_DATE_OR_TODAY);
                }
            }
        }else if(String.isNotBlank(fromDate) && String.isNotBlank(toDate) && fromDate.contains('/') && toDate.contains('/')){
            
            //Convert format of the String
            List<String> fromDateArr = fromDate.split('/');
            List<String> toDateArr = toDate.split('/');
            
            //Check the Size of the Splitted Strings
            if(fromDateArr.size() >0 && toDateArr.size() >0 && fromDateArr.size() <= 3 && toDateArr.size() <= 3){
                
                //Tyepe Cast in Salesforce format
                Date toDateActual = Date.valueOf(toDateArr[2] + '-' + toDateArr[0] + '-' + toDateArr[1]);
                
                //Set today if found null
                Date fromDateActual = Date.valueOf(fromDateArr[2] + '-' + fromDateArr[0] + '-' + fromDateArr[1]);
                
                //Compare both date and To Date must be greate then toDate
                if(toDateActual >= fromDateActual){
                    fullSOSL = fullSOSL + ' AND Ship_Date__C >= :fromDateActual AND Ship_Date__C <= :toDateActual';       
                }else{
                	
                    //Display Message in case of From date is greate then to Data or today
                    ShipItHelper.displayErrorMessages(ShipItHelper.FROM_DATE_MUST_BE_LESS_THEN_TO_DATE_OR_TODAY);
                }
            }
        }
        
        //Final SOSL with all filter criteria
		//Bhavi Sharma - 03/28/2015 - If searchText is blank, then execute the SOQL based on the parameters added above
		//Else execute SOSL
		if(String.IsBlank(searchText)) {
	        
			//JRB String SOQL = 'Select ' + fullSOSL.replace('where', 'from Shipment__c where') + ' order by Ship_Date__c DESC Limit :searchLimit';
			String SOQL = 'Select ' + fullSOSL.replace('where', 'from Shipment__c where') + ' order by CreatedDate DESC Limit :searchLimit';
			return (List<Shipment__c>) database.query(SOQL);
		} else {
			
			//JRB searchSOSL = 'FIND \''+String.escapeSingleQuotes(searchText)+'*\' IN ALL FIELDS RETURNING Shipment__c('+fullSOSL+' order by Ship_Date__c DESC Limit :searchLimit)';
			searchSOSL = 'FIND \''+String.escapeSingleQuotes(searchText)+'*\' IN ALL FIELDS RETURNING Shipment__c('+fullSOSL+' order by CreatedDate DESC Limit :searchLimit)';
			
			//Hit the search and get Search resutl
			List<List<SObject>>searchList=search.query(searchSOSL);
			
			//Return the Search Result
	        return searchList[0];
		}
		
		return new List<Shipment__c>();
    }
    
    //This method is to create a select option list for given Picklist Entries
    public static List<SelectOption> getSelectOptionListByField(String objectName, String fieldName) {
        
        //Describe field and create a list of select options  
        List<SelectOption> listOptions = new List<SelectOption>();
        
        //loop throough the picklist entries and populate select list
        for (Schema.PicklistEntry pE : Schema.getGlobalDescribe().get('Shipment__c').getDescribe().fields.getMap().get(fieldName).getDescribe().getPickListValues()) {
         
            //Populate the select list with values
            listOptions.add(new SelectOption(pE.getValue() , pE.getLabel()));  
        }
        
        //Return list
        return listOptions;
    }
    
    /**
     *  @description    :   Method to Get Ship It Custom Settings
     *
     *  @args           :	
     *
     *  @return         :   Map of Ship It settings
     *
     **/ 
    
    private static Map<String, ShipIt_Settings__c> pShipItSettings;
    public static Map<String,ShipIt_Settings__c> shipItSettings{
        get {
            if(pShipItSettings == null) {
                pShipItSettings = ShipIt_Settings__c.getAll();
            }
            return pShipItSettings;
        }
    }
    
     /**
     *  @description    :   Method to Get Ship It Method Settings
     *
     *  @args           :	
     *
     *  @return         :   Map of Ship It Method settings
     *
     **/ 
    private static Map<String, ShipIt_ShipMethod__c> aShipItMethod;
    public static Map<String,ShipIt_ShipMethod__c> allShipItMethods{
        get{
            if(pShipItMethod == null){ 
            	pShipItMethod = ShipIt_ShipMethod__c.getAll();	    
            }
            return pShipItMethod;
        }
        
    }
    /**
     *  @description    :   Method to Ship It Methods type of Personal, Here p Prefix says methods for Personal.
     *
     *  @args           :	
     *
     *  @return         :   Map of Ship It Method settings
     *
     **/ 
	private static Map<String, ShipIt_ShipMethod__c> pShipItMethod;
    public static Map<String,ShipIt_ShipMethod__c> pshipItMethods{
        get{
            if(pShipItMethod == null){ 
                
                //Inititalize Map
                pShipItMethod = new Map<String,ShipIt_ShipMethod__c>();
                
                //Loop over Ship methods
                for(ShipIt_ShipMethod__c method : [select Id, Name, Authorization_Required__c, Department_Standard__c, Display_Name__c, Personal__c
                                                    from ShipIt_ShipMethod__c where Personal__c = true]){
					pShipItMethod.put(method.Name, method);	                                       
				}
            }
            return pShipItMethod;
        }
    }
    
    /**
     *  @description    :   Method to Ship It Methods type of Department Standard, Here d Prefix says methods for Department.
     *
     *  @args           :	
     *
     *  @return         :   Map of Ship It Method settings
     *
     **/
    private static Map<String, ShipIt_ShipMethod__c> dShipItMethod;
    public static Map<String,ShipIt_ShipMethod__c> dShipItMethods{
        get{
            if(dShipItMethod == null){ 
                
                //Inititalize Map
                dShipItMethod = new Map<String,ShipIt_ShipMethod__c>();
                
                //Loop over Ship methods
                for(ShipIt_ShipMethod__c method : [select Id, Name, Authorization_Required__c, Department_Standard__c, Display_Name__c, Personal__c
                                                    from ShipIt_ShipMethod__c where Department_Standard__c = true]){
					dShipItMethod.put(method.Name, method);	                                       
				}
            }
            return dShipItMethod;
        }
    }
    
     /**
     *  @description    :   Method to return Custom Setting from Ship It Settings which are related to Email Notification Setting
     *
     *  @args           :	Name Type('EmailNotice_S_P_*','EmailNotice_S_S_*','EmailNotice_R_P_*')
     *
     *  @return         :   List of Ship It Settings
     **/
    private static Map<String,String> nmapEmailEventType;
    public static List<String> getShipItNotificationSettings(String name){
    	name = name + '%';
        List<String> settingNameList = new List<String>();
        
        //Map to Return Constants value for Particular Setting Name
        if(nmapEmailEventType == null){
        	
            nmapEmailEventType = new Map<String,String>{'EmailNotice_R_P_Delivery' => 'ON_DELIVERY',
            														'EmailNotice_R_P_Exception' => 'ON_EXCEPTION',
            														'EmailNotice_R_P_Shipment' => 'ON_SHIPMENT',
            														'EmailNotice_R_P_Tender' => 'ON_TENDER',
            														'EmailNotice_S_P_Delivery' => 'ON_DELIVERY',
            														'EmailNotice_S_P_Exception' => 'ON_EXCEPTION',
            														'EmailNotice_S_P_Shipment' => 'ON_SHIPMENT',
            														'EmailNotice_S_P_Tender' => 'ON_TENDER',
            														'EmailNotice_S_S_Delivery' => 'ON_DELIVERY',
            														'EmailNotice_S_S_Exception' => 'ON_EXCEPTION',
            														'EmailNotice_S_S_Shipment' => 'ON_SHIPMENT',
            														'EmailNotice_S_S_Tender' => 'ON_EXCEPTION'
            														};
        } 
        
        for(ShipIt_Settings__c nSetting : [select Id, Name , value__c from ShipIt_Settings__c where Name Like :name AND value__c = 'true']){
        	settingNameList.add(nmapEmailEventType.get(nSetting.Name));	    
        }
        return settingNameList;
    }
    
    /** Map to Return Time Stamp for FedEx Ground service, conver enumration time to String time e.g. 3 buisness day **/
    private static Map<String,String> pFedExGroundServiceTimeMap;
    public static Map<String,String> fedExGroundServiceTimeMap{
        get{
            if(pFedExGroundServiceTimeMap == null){
                pFedExGroundServiceTimeMap = new Map<String,String>{'ONE_DAY' => '1 Business Day',
                    												'TWO_DAYS' => '2 Business Days',
                    												'THREE_DAYS' => '3 Business Days',
                    												'FOUR_DAYS' => '4 Business Days',
                    												'FIVE_DAYS' => '5 Business Days',
                    												'SIX_DAYS' => '6 Business Days',
                    												'SEVEN_DAYS' => '7 Business Days',
                    												'EIGHT_DAYS' => '8 Business Days',
                    												'NINE_DAYS' => '9 Business Days',
                    												'TEN_DAYS' => '10 Business Days',
                    												'ELEVEN_DAYS' => '11 Business Days',
                    												'TWELVE_DAYS' => '12 Business Days',
                    												'THIRTEEN_DAYS' => '13 Business Days',
                    												'FOURTEEN_DAYS' => '14 Business Days',
                    												'FIFTEEN_DAYS' => '15 Business Days',
                    												'SIXTEEN_DAYS' => '16 Business Days',
                    												'SEVENTEEN_DAYS' => '17 Business Days',
                    												'EIGHTEEN_DAYS' => '18 Business Days',
                    												'NINETEEN_DAYS' => '19 Business Days',
                    												'TWENTY_DAYS' => '20 Business Days',
                    												'UNKNOWN' => ''};	    
            }
            return pFedExGroundServiceTimeMap;
        }
    }
     /**
     *  @description    :   Method to get updated instance of shipment,populate shipment wrapper data into shipment object and return it.
     *
     *  @args           :	Shipment Wrapper
     *
     *  @return         :   shipment Object
     **/
    public static Shipment__c getShipmentObject(ShipmentWrapper shipmentWrapper){
        Shipment__c shipment;
        
        if(String.isNotBlank(shipmentWrapper.id)){
        	shipment = new Shipment__c(Id = shipmentWrapper.id);    
        }else{
        	shipment = new shipment__c();    
        }
         
		shipment.Accept_Billing_Agreement__c = shipmentWrapper.AcceptBillingAgreement != null?shipmentWrapper.AcceptBillingAgreement:null;
		shipment.Add_Default_Insurance__c = shipmentWrapper.AddDefaultInsurance != null ? shipmentWrapper.AddDefaultInsurance : null;
		shipment.Address_Validation__c = shipmentWrapper.AddressValidation != null ? shipmentWrapper.AddressValidation : null;
		shipment.Authorization_Reason__c = shipmentWrapper.AuthorizationReason != null ? shipmentWrapper.AuthorizationReason : null;
		shipment.Authorization_Request_Date__c = shipmentWrapper.AuthorizationRequestDate != null ? shipmentWrapper.AuthorizationRequestDate : null;
		shipment.Authorization_Requested_From__c = shipmentWrapper.AuthorizationRequestedFrom != null ? shipmentWrapper.AuthorizationRequestedFrom : null;
		shipment.Authorization_Response_Date__c = shipmentWrapper.AuthorizationResponseDate != null ? shipmentWrapper.AuthorizationResponseDate : null;
		shipment.Authorization_Status__c = shipmentWrapper.AuthorizationStatus != null ? shipmentWrapper.AuthorizationStatus : null;
		shipment.Authorized_By__c = shipmentWrapper.AuthorizedBy != null ? shipmentWrapper.AuthorizedBy : null;
       		shipment.Address_Classification__c = shipmentWrapper.AddressClassification != null ? shipmentWrapper.AddressClassification : null;
		shipment.Billing_Batch_Id__c = shipmentWrapper.BillingBatchId != null ? shipmentWrapper.BillingBatchId : null;
		shipment.Billing_Status__c = shipmentWrapper.BillingStatus != null ? shipmentWrapper.BillingStatus : null;
		shipment.Billing_Type__c = shipmentWrapper.BillingType != null ? shipmentWrapper.BillingType : null;
		shipment.Bill_To__c = shipmentWrapper.BillTo != null ? shipmentWrapper.BillTo : null;
		shipment.Declared_Value__c = shipmentWrapper.DeclaredValue != null ? shipmentWrapper.DeclaredValue : null;
		shipment.Delivery_Date__c = shipmentWrapper.DeliveryDate != null ? shipmentWrapper.DeliveryDate : null;
		shipment.Delivery_Date_Actual__c = shipmentWrapper.DeliveryDateActual != null ? shipmentWrapper.DeliveryDateActual : null;
        	shipment.Delivery_Date_Text__c = shipmentWrapper.DeliveryDateText != null ? shipmentWrapper.DeliveryDateText : null;
        	//Modified by Mahendra Swarnkar - 05/08/2020 - Delivery_Ineligible_For_Guarantee__c,edi_batch_id__c,
        	//Hold_Shipment_at_FedEx_Location__c,insurance_amount__c deleted from object Shipment__c - CR-20200218-13769
        	//shipment.Delivery_Ineligible_For_Guarantee__c = shipmentWrapper.DeliveryIneligibleForGuarantee != null ? shipmentWrapper.DeliveryIneligibleForGuarantee : null;
        	shipment.Delivery_Service_Description__c = shipmentWrapper.DeliveryServiceDescription != null ? shipmentWrapper.DeliveryServiceDescription : null;
		//shipment.EDI_Batch_Id__c = shipmentWrapper.EDIBatchId != null ? shipmentWrapper.EDIBatchId : null;
		//shipment.Hold_Shipment_at_FedEx_Location__c = shipmentWrapper.HoldShipmentatFedExLocation != null ? shipmentWrapper.HoldShipmentatFedExLocation : null;
		//shipment.Insurance_Amount__c = shipmentWrapper.InsuranceAmount != null ? shipmentWrapper.InsuranceAmount : null;
		shipment.Label_Printed_Date__c = shipmentWrapper.LabelPrintedDate != null ? shipmentWrapper.LabelPrintedDate : null;
		shipment.Package_Code__c = shipmentWrapper.PackageCode != null ? shipmentWrapper.PackageCode : null;
		shipment.Package_Depth_in__c = shipmentWrapper.PackageDepth != null ? shipmentWrapper.PackageDepth : null;
		shipment.Package_Length_in__c = shipmentWrapper.PackageLength != null ? shipmentWrapper.PackageLength : null;
		shipment.Package_Type__c = shipmentWrapper.PackageType != null ? shipmentWrapper.PackageType : null;
		shipment.Package_Width_in__c = shipmentWrapper.PackageWidth != null ? shipmentWrapper.PackageWidth : null;
		//shipment.Personal_Billing__c = shipmentWrapper.PersonalBilling != null ? shipmentWrapper.PersonalBilling : null;
		shipment.Recipient__c = shipmentWrapper.Recipient != null ? shipmentWrapper.Recipient : null;
		shipment.Recipient_Address_Line_1__c = shipmentWrapper.RecipientAddressLine1 != null ? shipmentWrapper.RecipientAddressLine1 : null;
		shipment.Recipient_Address_Line_2__c = shipmentWrapper.RecipientAddressLine2 != null ? shipmentWrapper.RecipientAddressLine2 : null;
		shipment.Recipient_City__c = shipmentWrapper.RecipientCity != null ? shipmentWrapper.RecipientCity : null;
		shipment.Recipient_Company__c = shipmentWrapper.RecipientCompany != null ? shipmentWrapper.RecipientCompany : null;
		shipment.Recipient_Email__c = shipmentWrapper.RecipientEmail != null ? shipmentWrapper.RecipientEmail : null;
		shipment.Recipient_First_Name__c = shipmentWrapper.RecipientFirstName != null ? shipmentWrapper.RecipientFirstName : null;
		shipment.Recipient_Last_Name__c = shipmentWrapper.RecipientLastName != null ? shipmentWrapper.RecipientLastName : null;
		shipment.Recipient_Name__c = shipmentWrapper.RecipientName != null ? shipmentWrapper.RecipientName : null;
		shipment.Recipient_Phone__c = shipmentWrapper.RecipientPhone != null ? shipmentWrapper.RecipientPhone : null;
		shipment.Recipient_PostalCode__c = shipmentWrapper.RecipientPostalCode != null ? shipmentWrapper.RecipientPostalCode : null;
		shipment.Recipient_Selection_Method__c = shipmentWrapper.RecipientSelectionMethod != null ? shipmentWrapper.RecipientSelectionMethod : null;
		shipment.Recipient_State_Province__c = shipmentWrapper.RecipientStateOrProvince != null ? shipmentWrapper.RecipientStateOrProvince : null;
        shipment.Reference_Id__c = shipmentWrapper.ReferenceId != null ? shipmentWrapper.ReferenceId : null;
		shipment.Sender__c = shipmentWrapper.Sender != null ? shipmentWrapper.Sender : null;
		shipment.Sender_Address_Line_1__c = shipmentWrapper.SenderAddressLine1 != null ? shipmentWrapper.SenderAddressLine1 : null;
		shipment.Sender_Address_Line_2__c = shipmentWrapper.SenderAddressLine2 != null ? shipmentWrapper.SenderAddressLine2 : null;
		shipment.Sender_City__c = shipmentWrapper.SenderCity != null ? shipmentWrapper.SenderCity : null;
		shipment.Sender_Company__c = shipmentWrapper.SenderCompany != null ? shipmentWrapper.SenderCompany : null;
		shipment.Sender_Cost_Center__c = shipmentWrapper.SenderCostCenter != null ? shipmentWrapper.SenderCostCenter : null;
		shipment.Sender_Department__c = shipmentWrapper.SenderDepartment != null ? shipmentWrapper.SenderDepartment : null;
		shipment.Sender_Email__c = shipmentWrapper.SenderEmail != null ? shipmentWrapper.SenderEmail : null;
		shipment.Sender_Finance_Code__c = shipmentWrapper.SenderFinanceCode != null ? shipmentWrapper.SenderFinanceCode : null;
		shipment.Sender_First_Name__c = shipmentWrapper.SenderFirstName != null ? shipmentWrapper.SenderFirstName : null;
		shipment.Sender_Last_Name__c = shipmentWrapper.SenderLastName != null ? shipmentWrapper.SenderLastName : null;
		shipment.Sender_Name__c = shipmentWrapper.SenderName != null ? shipmentWrapper.SenderName : null;
		shipment.Sender_Office_Code__c = shipmentWrapper.SenderOfficeCode != null ? shipmentWrapper.SenderOfficeCode : null;
		shipment.Sender_Office_Name__c = shipmentWrapper.SenderOfficeName != null ? shipmentWrapper.SenderOfficeName : null;
		shipment.Sender_Phone__c = shipmentWrapper.SenderPhone != null ? shipmentWrapper.SenderPhone : null;
		shipment.Sender_PostalCode__c = shipmentWrapper.SenderPostalCode != null ? shipmentWrapper.SenderPostalCode : null;
		shipment.Sender_Secondary_Email__c = shipmentWrapper.SenderSecondaryEmail != null ? shipmentWrapper.SenderSecondaryEmail : null;
		shipment.Sender_State_Province__c = shipmentWrapper.SenderStateOrProvince != null ? shipmentWrapper.SenderStateOrProvince : null;
		shipment.Ship_Amount__c = shipmentWrapper.ShipAmount != null ? shipmentWrapper.ShipAmount : null;
		shipment.Ship_Amount_Actual__c = shipmentWrapper.ShipAmountActual != null ? shipmentWrapper.ShipAmountActual : null;
		shipment.Ship_Date__c = shipmentWrapper.ShipDate != null ? shipmentWrapper.ShipDate : null;
		shipment.Ship_Date_Actual__c = shipmentWrapper.ShipDateActual != null ? shipmentWrapper.ShipDateActual : null;
		shipment.Ship_Day__c = shipmentWrapper.ShipDay != null ? shipmentWrapper.ShipDay : null;
		//shipment.Shipment_Origin__c = shipmentWrapper.ShipmentOrigin != null ? shipmentWrapper.ShipmentOrigin : null;
		shipment.Ship_Method__c = shipmentWrapper.ShipMethod != null ? shipmentWrapper.ShipMethod : null;
		shipment.Ship_Method_Category__c = shipmentWrapper.ShipMethodCategory != null ? shipmentWrapper.ShipMethodCategory : null;
		shipment.Signature_Requirement__c = shipmentWrapper.SignatureRequirement != null ? shipmentWrapper.SignatureRequirement : null;
		//shipment.Stage__c = shipmentWrapper.Stage != null ? shipmentWrapper.Stage : null;
		shipment.Status__c = shipmentWrapper.Status != null ? shipmentWrapper.Status : null;
		shipment.Tracking_Number__c = shipmentWrapper.TrackingNumber != null ? shipmentWrapper.TrackingNumber : null;
		//shipment.Vendor_Package__c = shipmentWrapper.VendorPackage != null ? shipmentWrapper.VendorPackage : null;
		shipment.Weight_Actual__c = shipmentWrapper.WeightActual != null ? shipmentWrapper.WeightActual : null;
		shipment.Weight_Estimated__c = shipmentWrapper.WeightEstimated != null ? shipmentWrapper.WeightEstimated : null;
        return shipment;
    }
    
    /**
     *  @description    :   Method to get update shipment Wrapper Instnace from Shipment Object
     *
     *  @args           :	Shipment Wrapper
     *
     *  @return         :   shipment Object
     **/
    public static ShipmentWrapper getShipmentWrapperInstance(Shipment__c shipment){
        
        ShipmentWrapper shipmentWrapper = new shipmentWrapper();
        
        if(shipment != null && String.isNotBlank(shipment.id)){
        	shipmentWrapper.id = shipment.id;	
        }
        
        System.debug('####### : -  ' + shipment);
        
        shipmentWrapper.AcceptBillingAgreement = shipment.Accept_Billing_Agreement__c != null?shipment.Accept_Billing_Agreement__c:null;
		shipmentWrapper.AddDefaultInsurance = shipment.Add_Default_Insurance__c != null ? shipment.Add_Default_Insurance__c : null;
		shipmentWrapper.AddressValidation = shipment.Address_Validation__c != null ? shipment.Address_Validation__c : null;
		shipmentWrapper.AuthorizationReason = shipment.Authorization_Reason__c != null ? shipment.Authorization_Reason__c : null;
		shipmentWrapper.AuthorizationRequestDate = shipment.Authorization_Request_Date__c != null ? shipment.Authorization_Request_Date__c : null;
		shipmentWrapper.AuthorizationRequestedFrom = shipment.Authorization_Requested_From__c != null ? shipment.Authorization_Requested_From__c : null;
		shipmentWrapper.AuthorizationResponseDate = shipment.Authorization_Response_Date__c != null ? shipment.Authorization_Response_Date__c : null;
		shipmentWrapper.AuthorizationStatus = shipment.Authorization_Status__c != null ? shipment.Authorization_Status__c : null;
		shipmentWrapper.AuthorizedBy = shipment.Authorized_By__c != null ? shipment.Authorized_By__c : null;
        	shipmentWrapper.AddressClassification = shipment.Address_Classification__c != null ? shipment.Address_Classification__c : null;
		shipmentWrapper.BillingBatchId = shipment.Billing_Batch_Id__c != null ? shipment.Billing_Batch_Id__c : null;
		shipmentWrapper.BillingStatus = shipment.Billing_Status__c != null ? shipment.Billing_Status__c : null;
		shipmentWrapper.BillingType = shipment.Billing_Type__c != null ? shipment.Billing_Type__c : null;
		shipmentWrapper.BillTo = shipment.Bill_To__c != null ? shipment.Bill_To__c : null;
		shipmentWrapper.DeclaredValue = shipment.Declared_Value__c != null ? shipment.Declared_Value__c : null;
		shipmentWrapper.DeliveryDate = shipment.Delivery_Date__c != null ? shipment.Delivery_Date__c : null; 
		shipmentWrapper.DeliveryDateActual = shipment.Delivery_Date_Actual__c != null ? shipment.Delivery_Date_Actual__c : null;
        	shipmentWrapper.DeliveryDateText = shipment.Delivery_Date_Text__c != null ? shipment.Delivery_Date_Text__c : null;
        	shipmentWrapper.DeliveryServiceDescription = shipment.Delivery_Service_Description__c != null ? shipment.Delivery_Service_Description__c : null;
		//Modified by Mahendra Swarnkar - 05/08/2020 - Delivery_Ineligible_For_Guarantee__c, edi_batch_id__c,
		//Hold_Shipment_at_FedEx_Location__c,insurance_amount__c
		//deleted from object Shipment__c - CR-20200218-13769
		//shipmentWrapper.DeliveryIneligibleForGuarantee = shipment.Delivery_Ineligible_For_Guarantee__c != null ? shipment.Delivery_Ineligible_For_Guarantee__c : null;
		//shipmentWrapper.EDIBatchId = shipment.EDI_Batch_Id__c != null ? shipment.EDI_Batch_Id__c : null;
		//shipmentWrapper.HoldShipmentatFedExLocation = shipment.Hold_Shipment_at_FedEx_Location__c != null ? shipment.Hold_Shipment_at_FedEx_Location__c : null;
		//shipmentWrapper.InsuranceAmount = shipment.Insurance_Amount__c != null ? shipment.Insurance_Amount__c : null;
		shipmentWrapper.LabelPrintedDate = shipment.Label_Printed_Date__c != null ? shipment.Label_Printed_Date__c : null;
		shipmentWrapper.PackageCode = shipment.Package_Code__c != null ? shipment.Package_Code__c : null;
		shipmentWrapper.PackageDepth = shipment.Package_Depth_in__c != null ? shipment.Package_Depth_in__c : null;
		shipmentWrapper.PackageLength = shipment.Package_Length_in__c != null ? shipment.Package_Length_in__c : null;
		shipmentWrapper.PackageType = shipment.Package_Type__c != null ? shipment.Package_Type__c : null;
		shipmentWrapper.PackageWidth = shipment.Package_Width_in__c != null ? shipment.Package_Width_in__c : null;
		//shipmentWrapper.Personal_Billing__c = shipment.PersonalBilling != null ? shipment.PersonalBilling : null;
		shipmentWrapper.Recipient = shipment.Recipient__c != null ? shipment.Recipient__c : null;
		shipmentWrapper.RecipientAddressLine1 = shipment.Recipient_Address_Line_1__c != null ? shipment.Recipient_Address_Line_1__c : null;
		shipmentWrapper.RecipientAddressLine2 = shipment.Recipient_Address_Line_2__c != null ? shipment.Recipient_Address_Line_2__c : null;
		shipmentWrapper.RecipientCity = shipment.Recipient_City__c != null ? shipment.Recipient_City__c : null;
		shipmentWrapper.RecipientCompany = shipment.Recipient_Company__c != null ? shipment.Recipient_Company__c : null;
		shipmentWrapper.RecipientEmail = shipment.Recipient_Email__c != null ? shipment.Recipient_Email__c : null;
		shipmentWrapper.RecipientFirstName = shipment.Recipient_First_Name__c != null ? shipment.Recipient_First_Name__c : null;
		shipmentWrapper.RecipientLastName = shipment.Recipient_Last_Name__c != null ? shipment.Recipient_Last_Name__c : null;
		shipmentWrapper.RecipientName = shipment.Recipient_Name__c != null ? shipment.Recipient_Name__c : null;
		shipmentWrapper.RecipientPhone = shipment.Recipient_Phone__c != null ? shipment.Recipient_Phone__c : null;
		shipmentWrapper.RecipientPostalCode = shipment.Recipient_PostalCode__c != null ? shipment.Recipient_PostalCode__c : null;
		shipmentWrapper.RecipientSelectionMethod = shipment.Recipient_Selection_Method__c != null ? shipment.Recipient_Selection_Method__c : null;
		shipmentWrapper.RecipientStateOrProvince = shipment.Recipient_State_Province__c != null ? shipment.Recipient_State_Province__c : null;
        shipmentWrapper.ReferenceId = shipment.Id != null ? shipment.Id : null;
		shipmentWrapper.Sender = shipment.Sender__c != null ? shipment.Sender__c : null;
		shipmentWrapper.SenderAddressLine1 = shipment.Sender_Address_Line_1__c != null ? shipment.Sender_Address_Line_1__c : null;
		shipmentWrapper.SenderAddressLine2	 = shipment.Sender_Address_Line_2__c != null ? shipment.Sender_Address_Line_2__c : null;
		shipmentWrapper.SenderCity = shipment.Sender_City__c != null ? shipment.Sender_City__c : null;
		shipmentWrapper.SenderCompany = shipment.Sender_Company__c != null ? shipment.Sender_Company__c : null;
		shipmentWrapper.SenderCostCenter = shipment.Sender_Cost_Center__c != null ? shipment.Sender_Cost_Center__c : null;
		shipmentWrapper.SenderDepartment = shipment.Sender_Department__c != null ? shipment.Sender_Department__c : null;
		shipmentWrapper.SenderEmail = shipment.Sender_Email__c != null ? shipment.Sender_Email__c : null;
		shipmentWrapper.SenderFinanceCode = shipment.Sender_Finance_Code__c != null ? shipment.Sender_Finance_Code__c : null;
		shipmentWrapper.SenderFirstName = shipment.Sender_First_Name__c != null ? shipment.Sender_First_Name__c : null;
		shipmentWrapper.SenderLastName = shipment.Sender_Last_Name__c != null ? shipment.Sender_Last_Name__c : null;
		shipmentWrapper.SenderName = shipment.Sender_Name__c != null ? shipment.Sender_Name__c : null;
		shipmentWrapper.SenderOfficeCode = shipment.Sender_Office_Code__c != null ? shipment.Sender_Office_Code__c : null;
		shipmentWrapper.SenderOfficeName = shipment.Sender_Office_Name__c != null ? shipment.Sender_Office_Name__c : null;
		shipmentWrapper.SenderPhone = shipment.Sender_Phone__c != null ? shipment.Sender_Phone__c : null;
		shipmentWrapper.SenderPostalCode = shipment.Sender_PostalCode__c != null ? shipment.Sender_PostalCode__c : null;
		shipmentWrapper.SenderSecondaryEmail = shipment.Sender_Secondary_Email__c != null ? shipment.Sender_Secondary_Email__c : null;
		shipmentWrapper.SenderStateOrProvince = shipment.Sender_State_Province__c != null ? shipment.Sender_State_Province__c : null;
		shipmentWrapper.ShipAmount = shipment.Ship_Amount__c != null ? shipment.Ship_Amount__c : null;
		shipmentWrapper.ShipAmountActual = shipment.Ship_Amount_Actual__c != null ? shipment.Ship_Amount_Actual__c : null;
		shipmentWrapper.ShipDate = shipment.Ship_Date__c != null ? shipment.Ship_Date__c : null;
		shipmentWrapper.ShipDateActual = shipment.Ship_Date_Actual__c != null ? shipment.Ship_Date_Actual__c : null;
		shipmentWrapper.ShipDay = shipment.Ship_Day__c != null ? shipment.Ship_Day__c : null;
		//shipmentWrapper.ShipmentOrigin = shipment.Shipment_Origin__c != null ? shipment.Shipment_Origin__c : null;
		shipmentWrapper.ShipMethod = shipment.Ship_Method__c != null ? shipment.Ship_Method__c : null;
		shipmentWrapper.ShipMethodCategory = shipment.Ship_Method_Category__c != null ? shipment.Ship_Method_Category__c : null;
		shipmentWrapper.SignatureRequirement = shipment.Signature_Requirement__c != null ? shipment.Signature_Requirement__c : null;
		//shipmentWrapper.Stage = shipment.Stage__c != null ? shipment.Stage__c : null;
		shipmentWrapper.Status = shipment.Status__c != null ? shipment.Status__c : null;
		shipmentWrapper.TrackingNumber = shipment.Tracking_Number__c != null ? shipment.Tracking_Number__c : null;
		//shipmentWrapper.Vendor_Package__c = shipment.VendorPackage != null ? shipment.VendorPackage : null;
		shipmentWrapper.WeightActual = shipment.Weight_Actual__c != null ? shipment.Weight_Actual__c : null;
		shipmentWrapper.WeightEstimated = shipment.Weight_Estimated__c != null ? shipment.Weight_Estimated__c : null;
        
        //Set properties
        if(shipmentWrapper.DeliveryDate != null){
            shipmentWrapper.deliveryDateString = shipmentWrapper.DeliveryDate.format('EEE, MMM d');
    		shipmentWrapper.deliveryTimeString = shipmentWrapper.DeliveryDate.format('hh:mm a');
        }
        return shipmentWrapper;
    }
    
     /**
     *  @description    :   Method to Convert a Date Time String to GMT Date Time
     *
     *  @args           :	String datetime value like('MON - 13 APR 10:30A','Missing time in it :- MON - 13 APR AA/AM/PM')
     *
     *  @return         :   DateTime
     *
     **/ 
    private static Map<String,Integer> pMapMonthHolder;
    public static DateTime convertDateTimeStringToGmtFormat(String dateTimeText,ShipIt_ShipMethod__c serviceInstance){
        
        //Get Date time format like '13 APR 10:30A''13 APR AA/PM/RM'
        String [] firstSplit = dateTimeText.trim().split('-');
       
        String actulaDateTimeText = firstSplit[1];
        
        //Now Split Again to get 
        String [] dateTextArray = actulaDateTimeText.trim().split('\\s');
        //System.debug('Check Actual Date Time Text ::: ' + dateTextArray);
        if(pMapMonthHolder == null){
            pMapMonthHolder = new Map<String,Integer>{'JAN' => 1, 'FEB' => 2, 'MAR' => 3, 'APR' => 4,
                									   'MAY' => 5, 'JUN' => 6, 'JUL' => 7, 'AUG' => 8,
                										'SEP' => 9, 'OCT' => 10, 'NOV' => 11, 'DEC' => 12};    
        }
        String day = dateTextArray[0]; 
        Integer month = pMapMonthHolder.get(dateTextArray[1]);
        
        //Get Time Text
        String timeText = dateTextArray[2];   
        if(String.isNotBlank(timeText) && !timeText.contains(':')){ 
            /*if(timeText.contains('AA')){
            	timeText = '4:30 PM';    
            }else if(timeText.contains('AM')){
            	timeText = '12:00 PM';    
            }else if(timeText.contains('PM')){
            	timeText = '4:30 PM';        
            }else{
            	timeText = '10:30 AM';            
            }*/
			
            if(serviceInstance != null){
                
                //Convert it to APi Name
                timeText = timeText + '__c';
                
                if(serviceInstance.get(timeText) != null)
            		timeText = String.valueOf(serviceInstance.get(timeText));	
                else
                    timeText = '4:30 PM';
            }else{
                timeText = '4:30 PM';
            }
        }else if(timeText.contains(':') && timeText.contains('A')){
        	timeText = timeText.replaceAll('A', ' AM');     
        }else if(timeText.contains(':') && timeText.contains('P')){
        	timeText = timeText.replaceAll('P', ' PM');     
        }else{
        	timeText = '4:30 PM';                
        }
        
        String finalDateTimeString = month + '/'+ day + '/' + Datetime.now().year() + ' ' + timeText;
        DateTime dt = DateTime.parse(finalDateTimeString);
        return dt;
    }
}