/** 
  * Description     :   This class works as an integration handler between ShipIt App and FedEX WebService.
  *
  * Created By      :   Rajeev Jain(Simplyforce)
  *
  * Created Date    :   03/18/2015
  *
  * Version         :   V1.0 Created
  *                 :   V1.1 Modified (Rajeev Jain 04/30/2015) Addded to store Residential Attribute
  * 				
  * 
  **/
public without sharing class ShipItServiceController {
    
    //Private Properties direcly used in callout each time
    //Web Authentication Details
    private String key;
    private String password;
    private String accountNumber;
    private String meterNumber;
  
    //Additional standard settings
    private Integer offsetDropOffTime;
    
    //Transaction Details
    private String customerTransactionid;
  
    //Some properties would be used by ShipIt Controller
    public Boolean isInvalidSuitNumber{get;set;}
    
    //Class Constructor
    public ShipItServiceController(){
        
        //Set Default false
        isInvalidSuitNumber = false;
        
        //Populate Authentication Details 
        key = ShipItHelper.shipItSettings.get(ShipItHelper.FEDEX_USE_PRODUCTION_CREDENTIALS).value__c == 'true' ? ShipItHelper.shipItSettings.get(ShipItHelper.FEDEX_KEY).value__c : ShipItHelper.shipItSettings.get(ShipItHelper.FEDEX_TEST_KEY).value__c;
        password = ShipItHelper.shipItSettings.get(ShipItHelper.FEDEX_USE_PRODUCTION_CREDENTIALS).value__c == 'true' ? ShipItHelper.shipItSettings.get(ShipItHelper.FEDEX_PASSWORD).value__c : ShipItHelper.shipItSettings.get(ShipItHelper.FEDEX_TEST_PASSWORD).value__c;
        accountNumber = ShipItHelper.shipItSettings.get(ShipItHelper.FEDEX_USE_PRODUCTION_CREDENTIALS).value__c == 'true' ? ShipItHelper.shipItSettings.get(ShipItHelper.FEDEX_AccountNumber).value__c : ShipItHelper.shipItSettings.get(ShipItHelper.FEDEX_TEST_AccountNumber).value__c;
        meterNumber = ShipItHelper.shipItSettings.get(ShipItHelper.FEDEX_USE_PRODUCTION_CREDENTIALS).value__c == 'true'? ShipItHelper.shipItSettings.get(ShipItHelper.FEDEX_MeterNumber).value__c : ShipItHelper.shipItSettings.get(ShipItHelper.FEDEX_TEST_MeterNumber).value__c;
        
        //Get additional standard settings
        offsetDropOffTime = Integer.valueOf(ShipItHelper.shipItSettings.get(ShipItHelper.SHIPMENT_TIME).value__c);
    }
    
    /**
    *  @description    :   Method to validate Address info for shipment on FedEx End Points.
    *           
    *  @args           :   Actual Shipment, Shipment Instance which hold effective addresses.
    * 
    *  @return         :   Return validation Status('No Change','Passed','Resolved','Warning')
    * 
    **/
    public String validateAddressOnFedEx(Shipment__c shipment, Shipment__c compShipment,Web_Service_Log__c webServiceLog){
        
        //Add Web Authentication Credentials
        ShipItFedExAddressValidationService.WebAuthenticationCredential credentials = new ShipItFedExAddressValidationService.WebAuthenticationCredential();
        credentials.Key = key;
        credentials.password = password;
        
        ShipItFedExAddressValidationService.WebAuthenticationDetail authenticationDetail = new ShipItFedExAddressValidationService.WebAuthenticationDetail();
        authenticationDetail.UserCredential = credentials;
        
        //Add CLient Detail
        ShipItFedExAddressValidationService.ClientDetail clientDetail = new ShipItFedExAddressValidationService.ClientDetail();
        clientDetail.AccountNumber = accountNumber;
        clientDetail.MeterNumber = meterNumber;
        
        //Version Id
        ShipItFedExAddressValidationService.VersionId  versionId = new ShipItFedExAddressValidationService.VersionId();
        
        //Version Setting
        versionId.ServiceId = ShipItHelper.shipItSettings.get('VersionServiceId').value__c;
        versionId.Major = Integer.valueOf(ShipItHelper.shipItSettings.get('VersionMajor').value__c);
        versionId.Intermediate = Integer.valueOf(ShipItHelper.shipItSettings.get('VersionIntermediate').value__c);
        versionId.Minor = Integer.valueOf(ShipItHelper.shipItSettings.get('VersionMinor').value__c);
        
        //String validation Status
        String validationStatus = '';
        
        //Add Transaction Details
        ShipItFedExAddressValidationService.TransactionDetail transactionDetails = new ShipItFedExAddressValidationService.TransactionDetail();
        transactionDetails.CustomerTransactionId = shipment.id + dateTime.now().format('MM-dd-YYYY hh:mm a');
        
        //Address to Validate
        
        //String client Refernece Id
        String clientReferenceId = shipment.id + dateTime.now().format('MM-dd-YYYY hh:mm a');
        
        ShipItFedExAddressValidationService.Contact shipContact = new ShipItFedExAddressValidationService.Contact();
        shipContact.CompanyName = shipment.Recipient_Company__c;
        shipContact.PersonName = shipment.Recipient_Name__c;
        shipContact.PhoneNumber = shipment.Recipient_Phone__c;
        
        //Address Details
        ShipItFedExAddressValidationService.Address addressDetail = new ShipItFedExAddressValidationService.Address();
        
        //Add List of Streets
        List<String> streetLines = new List<String>();
        streetLines.add(shipment.Recipient_Address_Line_1__c);
        streetLines.add(shipment.Recipient_Address_Line_2__c);
        addressDetail.StreetLines = streetLines;
        addressDetail.City = shipment.Recipient_City__c;
        addressDetail.StateOrProvinceCode = shipment.Recipient_State_Province__c;
        
        //Rj Remove appended additional 4 digit zip code as per CR-8666(Fix Address Validation Issue)
        if(shipment.Recipient_PostalCode__c.contains('-')){
            String [] strZipArray = shipment.Recipient_PostalCode__c.split('\\-');
            addressDetail.PostalCode = strZipArray[0];
        }else{
            addressDetail.PostalCode = shipment.Recipient_PostalCode__c;
        }
        
        addressDetail.CountryCode = ShipitHelper.shipItSettings.get('RecipientCountryCode').value__c;
       
        ShipItFedExAddressValidationService.AddressToValidate addressToValidate = new ShipItFedExAddressValidationService.AddressToValidate();
        addressToValidate.Contact = shipContact;
        addressToValidate.Address = addressDetail;
        addressToValidate.ClientReferenceId = clientReferenceId;
        
        //Add created address to List
        List<ShipItFedExAddressValidationService.AddressToValidate> addressToValidateList = new List<ShipItFedExAddressValidationService.AddressToValidate>();
        addressToValidateList.add(addressToValidate);
        
        //Effective time Stamp
        Datetime inEffectTimeStamp = Datetime.now();
        
        //Set Request time in Web Service log
        webServiceLog.Request_Sent__c = DateTime.now();
        webServiceLog.Web_Service_Class__c = 'ShipItServiceController';
        webServiceLog.Web_Service_Method__c = 'validateAddressOnFedEx';
        webServiceLog.Web_Service_Name__c = 'ShipItFedExAddressValidationService';
        webServiceLog.Request_Message__c = 'Validate Shipping Address on FedEx';
        webServiceLog.Shipment__c = shipment.Id;
        
        //Validate Address on Fed Ex Endpoint
        ShipItFedExAddressValidationService.AddressValidationServicePort servicePort = new ShipItFedExAddressValidationService.AddressValidationServicePort();
        ShipItFedExAddressValidationService.AddressValidationReply validationReply;
        
        if(Test.isRunningTest()){
            validationReply = ShipItFedExMockResponse.testAddressValidation(authenticationDetail, clientDetail, transactionDetails, versionId,  addressToValidateList);    
        }else{
            validationReply = servicePort.addressValidation(authenticationDetail, clientDetail, transactionDetails, versionId, inEffectTimeStamp, addressToValidateList);   
        }
       
        //Set Response time in Web service Log
        webServiceLog.Response_Received__c = DateTime.now();
        
        List<ShipItFedExAddressValidationService.AddressValidationResult> validationResults = validationReply.AddressResults;
        
        //Hold Notifications
        ShipItFedExAddressValidationService.Notification[] notifications = validationReply.Notifications;
        
        //Hold Customer Transaction Id
        ShipItFedExAddressValidationService.TransactionDetail transactionDetail = validationReply.TransactionDetail;
        
        String logNotifcation = '', warnMsg = '';
        String transactionId = transactionDetail != null ? transactionDetail.CustomerTransactionId : '';    
        //Check Size of Notication Result Returned in Response
        if(notifications.size()>0){
            
            //Combine all notification and set to web service log(All notification will be stored in web Service log)
            logNotifcation = notifications[0].Severity + ',' + notifications[0].Source + ',' + notifications[0].Code + ',' 
                            + notifications[0].Message + ',' + notifications[0].MessageParameters + ',' + transactionId;
            
            webServiceLog.Error_Message__c = logNotifcation;
            webServiceLog.Response_Message__c = notifications[0].Message;
            webServiceLog.Response_Message_Log__c = validationReply.toString().left(32000);
            webServiceLog.Requested_By__c = UserInfo.getUserId();
            
            //Warn Message will be displayed on the page
            warnMsg = notifications[0].Code + '-' + notifications[0].Message + '-' + shipment.Id;
        }
        
        //========================= Parse Response of Address validation =============================================
        //Hieghest Severity to Showw the Response Result(Error OR SUCCESS) from fedEx Server
        String highestSeverity = validationReply.HighestSeverity;
        
        //Check if Success then Parse Resposne according to it
        if(highestSeverity.equalsIgnoreCase(ShipItHelper.FED_INTEGRATION_RESPONSE_SUCCESS) || 
            highestSeverity.equalsIgnoreCase(ShipItHelper.FED_INTEGRATION_RESPONSE_WARNING) || 
           highestSeverity.equalsIgnoreCase(ShipItHelper.FED_INTEGRATION_RESPONSE_NOTE)){
            
            //Map to Hold Results Attribute Value Pair
            Map<String,String> resultAttrMap = new Map<String,String>();
            
            //Loop over each Results and get Attribute value
            for(ShipItFedExAddressValidationService.AddressValidationResult rs : validationResults){
                
                //Get Result attribute and check it
                ShipItFedExAddressValidationService.AddressAttribute[] resultAttributes = rs.Attributes;
                
                //Check Effective contact And Address
                ShipItFedExAddressValidationService.Contact effectiveContact = rs.EffectiveContact;
                ShipItFedExAddressValidationService.Address effectiveAddress = rs.EffectiveAddress;
                              
                //Hold flag that shows any single attribute is set to false
                Boolean isValidationOK = false;
                //Loop over each attribute
                for(ShipItFedExAddressValidationService.AddressAttribute attr : resultAttributes){
                    
                    //Check Attribute values and other propertiies and decide validation status based on that
                    //Hold over all status for attribute value, none of the attribute should be blank or false
                    resultAttrMap.put(attr.Name, attr.value);
                }
                
                //RJ(04/30/2015) Residential Attribute to Say the Recipient addreess is Residential or Business or Mixed or Unknown
                shipment.Address_Classification__c = rs.Classification;
                
                //Listed Attribute
                String resolved = resultAttrMap.get(ShipItHelper.VALIDATION_ATTRIBUTE_RESOLVED);
                String postalValidate = resultAttrMap.get(ShipItHelper.VALIDATION_ATTRIBUTE_POSTALVALIDATED);
                String CityStateValidated = resultAttrMap.get(ShipItHelper.VALIDATION_ATTRIBUTE_CITYSTATEVALIDATED);
                String StreetValidated = resultAttrMap.get(ShipItHelper.VALIDATION_ATTRIBUTE_STREETVALIDATED);
                String StreetRangeValidated = resultAttrMap.get(ShipItHelper.VALIDATION_ATTRIBUTE_STREETRANGEVALIDATED);
                String InvalidSuiteNumber = resultAttrMap.get(ShipItHelper.VALIDATION_ATTRIBUTE_INVALIDSUITNUMBER);
                
                //Check Invalid SuitNumber Attribute
                isInvalidSuitNumber = Boolean.valueOf(InvalidSuiteNumber);
                
                //Var to hold two Street Lines
                String streetLine1, streetLine2;
                if(effectiveAddress.StreetLines.size() > 1){
                    
                    streetLine1 = effectiveAddress.StreetLines[0];
                    streetLine2 = effectiveAddress.StreetLines[1];
                }else{
                    streetLine1 = effectiveAddress.StreetLines[0]; 
                }
                
                //Generally Response returen Address Line 2 With null value so we reset to Blank to make better compare 
                if(streetLine2 == null)
                    streetLine2 = '';
                
                compShipment.Recipient_Address_Line_1__c = streetLine1.trim();
                compShipment.Recipient_Address_Line_2__c = streetLine2.trim();
                compShipment.Recipient_City__c = effectiveAddress.City.trim();
                compShipment.Recipient_State_Province__c = effectiveAddress.StateOrProvinceCode.trim();
                compShipment.Recipient_PostalCode__c = effectiveAddress.PostalCode.trim();
                
                //Check for Validation Status No Change
                if((String.isBlank(resolved)) &&
                   (String.isBlank(postalValidate) || postalValidate.equalsIgnoreCase('true')) &&
                   (String.isBlank(CityStateValidated) || CityStateValidated.equalsIgnoreCase('true')) && 
                   (String.isBlank(StreetValidated) || StreetValidated.equalsIgnoreCase('true')) &&
                   (String.isBlank(StreetRangeValidated) || StreetRangeValidated.equalsIgnoreCase('true')) &&
                   (String.isBlank(InvalidSuiteNumber) || InvalidSuiteNumber.equalsIgnoreCase('true'))){
                       
                       //Check for 'No Change', Compare Fed Ex Effective address with Exsiting Address
                       if(Shipment.Recipient_Address_Line_1__c.trim() == streetLine1.trim() && 
                       (streetLine2.trim() == Shipment.Recipient_Address_Line_2__c.trim()) &&
                       shipment.Recipient_City__c.trim() == effectiveAddress.City.trim() &&
                       shipment.Recipient_State_Province__c.trim() == effectiveAddress.StateOrProvinceCode.trim() &&
                       shipment.Recipient_PostalCode__c.trim() == effectiveAddress.PostalCode.trim() && 
                       ShipitHelper.shipItSettings.get('RecipientCountryCode').value__c == effectiveAddress.CountryCode){
                            
                            validationStatus = ShipItHelper.VALIDATION_STATUS_NOCHANGE;
                        }
                   //Check for No Change and Resolved(Currently Passed validation is not used)
                   }else if(resolved.equalsIgnoreCase('true')){
                       
                       if(Shipment.Recipient_Address_Line_1__c.trim() == streetLine1.trim() && 
                       (streetLine2.trim() == Shipment.Recipient_Address_Line_2__c.trim()) &&
                       shipment.Recipient_City__c.trim() == effectiveAddress.City.trim() && 
                       shipment.Recipient_State_Province__c.trim() == effectiveAddress.StateOrProvinceCode.trim() &&
                       shipment.Recipient_PostalCode__c.trim() == effectiveAddress.PostalCode.trim() && 
                       ShipitHelper.shipItSettings.get('RecipientCountryCode').value__c == effectiveAddress.CountryCode){
                            
                            validationStatus = ShipItHelper.VALIDATION_STATUS_NOCHANGE;
                       }else{
                            validationStatus = ShipItHelper.VALIDATION_STATUS_RESOLVED;   
                       }
                   }else if(resolved.equalsIgnoreCase('false') && ((String.isNotBlank(postalValidate) && postalValidate.equalsIgnoreCase('false')) || (String.isNotBlank(CityStateValidated) && CityStateValidated.equalsIgnoreCase('false')) ||
                   (String.isNotBlank(StreetValidated) && StreetValidated.equalsIgnoreCase('false')) || (String.isNotBlank(StreetRangeValidated) && StreetRangeValidated.equalsIgnoreCase('false')) || 
                   (String.isNotBlank(InvalidSuiteNumber) && InvalidSuiteNumber.equalsIgnoreCase('true')))){
                        validationStatus = ShipItHelper.VALIDATION_STATUS_WARNING;   
                   } 
            }
            //Check if Waarning then display message on the screen
            if(highestSeverity.equalsIgnoreCase(ShipItHelper.FED_INTEGRATION_RESPONSE_WARNING)){
                
                //Warning message will not stop the app but will be displayed on the page
                ShipItHelper.displayErrorMessages(warnMsg);    
            }
        }else{
            
            //ERROR or FAILURE message will stop the apps current functionality will be displayed on the page
            ShipItHelper.displayErrorMessages(warnMsg);  
        }
        
        //Return final Validation Status
        return validationStatus;
    }
    
    /**
    *  @description    :   Method to Send Request to Rate Service of Fed Ex and get Delivery options Details and Other Shiping Request
    *           
    *  @args           :   Actual Shipment, Web Service Log Instance
    * 
    *  @return         :   Return Delivery option List
    * 
    **/
    public List<DeliveryOptionWrapper> requestRateServiceToFedEx(Shipment__c shipment, Web_Service_Log__c webServiceLog){
        
         //Add Web Authentication Credentials
        ShipItFedExRateService.WebAuthenticationCredential credentials = new ShipItFedExRateService.WebAuthenticationCredential();
        credentials.Key = key;
        credentials.password = password;
        
        ShipItFedExRateService.WebAuthenticationDetail authenticationDetail = new ShipItFedExRateService.WebAuthenticationDetail();
        authenticationDetail.UserCredential = credentials;
        
        //Add CLient Detail
        ShipItFedExRateService.ClientDetail clientDetail = new ShipItFedExRateService.ClientDetail();
        clientDetail.AccountNumber = accountNumber;
        clientDetail.MeterNumber = meterNumber;
        
        //Version Id
        ShipItFedExRateService.VersionId  versionId = new ShipItFedExRateService.VersionId();
        
        //Version Setting
        versionId.ServiceId = ShipItHelper.shipItSettings.get(ShipItHelper.VERSIONSERVICEID_RATESERVICE).value__c;
        versionId.Major = Integer.valueOf(ShipItHelper.shipItSettings.get(ShipItHelper.VERSIONMAJORID_RATESERVICE).value__c);
        versionId.Intermediate = Integer.valueOf(ShipItHelper.shipItSettings.get(ShipItHelper.VERSIONINTERMEDIATE_RATESERVICE).value__c);
        versionId.Minor = Integer.valueOf(ShipItHelper.shipItSettings.get(ShipItHelper.VERSIONMINOR_RATESERVICE).value__c);
        
        //Add Transaction Details
        ShipItFedExRateService.TransactionDetail transactionDetails = new ShipItFedExRateService.TransactionDetail();
        transactionDetails.CustomerTransactionId = shipment.id ;
        
        //Hold Return Transit and Commint info
        Boolean returnTransmitAndCommit = Boolean.valueOf(ShipItHelper.shipItSettings.get('ReturnTransitAndCommit').value__c);
        
        ShipIt_PackageType__c selectedPackageType = ShipItHelper.getSelectedPackageInstanceByFullName(shipment.Package_Type__c);
        
        //================= Prepare Requested Shipment Data ========================================================================
        ShipItFedExRateService.RequestedShipment requestedShipment = new ShipItFedExRateService.RequestedShipment();
        //JRB uncommented this line
        DateTime dropoffDateTime = DateTime.newInstance(shipment.Ship_Date__c.year(),shipment.Ship_Date__c.month(),shipment.Ship_Date__c.day(),0,0,0);
        
        dropoffDateTime = dropoffDateTime.addHours(offsetDropOffTime);
        
        //requestedShipment.ShipTimestamp = DateTime.newInstance(shipment.Ship_Date__c, DateTime.now().time()+offsetDropOffTime); 
        requestedShipment.ShipTimestamp = dropoffDateTime;
        
        requestedShipment.DropoffType = ShipItHelper.shipItSettings.get('DropoffType').value__c;
        requestedShipment.PackagingType = selectedPackageType.Name;
        
        requestedShipment.BlockInsightVisibility = false;
        
        // ====================== Prepare Shipper Data ==========================
        //Create Contact And Assign it later on party Object
        ShipItFedExRateService.Contact contactData = new ShipItFedExRateService.Contact();
        contactData.CompanyName = ShipItHelper.shipItSettings.get(ShipItHelper.SENDERCOMPANYNAME).value__c;
        contactData.PersonName = shipment.Sender_Name__c;
        contactData.PhoneNumber = shipment.Sender_Phone__c;
        
        //Prepare Address Data
        ShipItFedExRateService.Address addressdata = new ShipItFedExRateService.Address();
        
         //Add List of Streets
        List<String> streetLines = new List<String>();
        streetLines.add(shipment.Sender_Address_Line_1__c);
        streetLines.add(shipment.Sender_Address_Line_2__c);
        addressdata.StreetLines = streetLines; 
        addressdata.City = shipment.Sender_City__c;
        addressdata.StateOrProvinceCode = shipment.Sender_State_Province__c;
        addressdata.PostalCode = shipment.Sender_PostalCode__c; 
        addressdata.CountryCode = ShipItHelper.shipItSettings.get(ShipItHelper.SENDERCOUNTRYCODE).value__c;
        
        //Add Shipper Information , which holds contact, address and acccount Number Details'
        ShipItFedExRateService.Party shipper = new ShipItFedExRateService.Party();
        shipper.AccountNumber = accountNumber;
        shipper.Contact = contactData;
        shipper.Address = addressdata;
        
        //Set Shipper in Requested Shipment
        requestedShipment.Shipper = shipper;
        
        //=================== Prepare Recipient Data ======================================
        //Create Contact And Assign it later on party Object
        ShipItFedExRateService.Contact recipientContactData = new ShipItFedExRateService.Contact();
        recipientContactData.CompanyName = shipment.Recipient_Company__c;
        recipientContactData.PersonName = shipment.Recipient_Name__c;
        recipientContactData.PhoneNumber = shipment.Recipient_Phone__c;
        
        //Prepare Address Data
        ShipItFedExRateService.Address recipientAddressdata = new ShipItFedExRateService.Address();
        
         //Add List of Streets
        streetLines = new List<String>();
        streetLines.add(shipment.Recipient_Address_Line_1__c);
        streetLines.add(shipment.Recipient_Address_Line_2__c);
        
        recipientAddressdata.StreetLines = streetLines; 
        recipientAddressdata.City = shipment.Recipient_City__c;
        recipientAddressdata.StateOrProvinceCode = shipment.Recipient_State_Province__c;
        recipientAddressdata.PostalCode = shipment.Recipient_PostalCode__c; 
        recipientAddressdata.CountryCode = ShipItHelper.shipItSettings.get(ShipItHelper.RECIPIENTCOUNTRYCODE).value__c;
        
        //Rj(04/30/2015) Sending Residential flag it make difference in Delivery Option Rate Charges
        //If address is Residential then shipment charges are higher then the Business and other address options
        //Set Is Residential Flag True if Address Classification field is Residential 
        recipientAddressdata.Residential = shipment.Address_Classification__c.equalsIgnoreCase('Residential') ? true : false;
            
        //Add Shipper Information , which holds contact, address and acccount Number Details'
        ShipItFedExRateService.Party recipient = new ShipItFedExRateService.Party();
        recipient.AccountNumber = accountNumber;
        recipient.Contact = recipientContactData;
        recipient.Address = recipientAddressdata;
        
        //Assign Recipient in Requested Shipment
        requestedShipment.Recipient = recipient;
        
        //List to hold Rate request type
        List<String> rateRequestList = new List<String>{ShipItHelper.shipItSettings.get(ShipItHelper.RATEREQUESTTYPE).value__c};
        requestedShipment.RateRequestTypes = rateRequestList;    
        requestedShipment.PackageCount = 1;
        
        //================Prepare Requested Package Line Items ================
        ShipItFedExRateService.RequestedPackageLineItem packageLineItems = new ShipItFedExRateService.RequestedPackageLineItem();
        
        //Set Insured Value
        ShipItFedExRateService.Money money = new ShipItFedExRateService.Money();
        money.Currency_x = ShipItHelper.CURRENCY_USD;
        
        //Check if Declared Value is blank then apply defaul insurance amount for it.
        if(shipment.Declared_Value__c != null && shipment.Declared_Value__c >= 100){
            money.Amount =  shipment.Declared_Value__c;   
        }else{
            money.Amount = Decimal.valueOf(ShipItHelper.shipItSettings.get(ShipItHelper.DEFAULTINSURENCE).value__c);
            shipment.Add_Default_Insurance__c = true;
        }
        
        packageLineItems.InsuredValue = money;
        
        //Set Package Count
        packageLineItems.GroupPackageCount = 1;
        
        //Set Wight and Units
        ShipItFedExRateService.Weight weight = new ShipItFedExRateService.Weight();
        weight.Units = shipItHelper.shipItSettings.get(shipItHelper.WEIGHTUNITSTRING).value__c;
        weight.Value = (Decimal)shipment.Weight_Estimated__c;
        packageLineItems.Weight = weight;
        
        //Set Dimensions for Package
        //Check for Package Type Selected, Apply Dimensions only if custom package was applied by user
        if(selectedPackageType.Is_Custom__c){
            ShipItFedExRateService.Dimensions dimensions = new ShipItFedExRateService.Dimensions();
            
            //Rj Convert decimal to whole number e.g. 1.4 to 2 
            //Renter Package Dimension with whole number on Shipment fields 
            shipment.Package_Depth_in__c = Math.Ceil(shipment.Package_Depth_in__c);
            shipment.Package_Length_in__c = Math.Ceil(shipment.Package_Length_in__c);
            shipment.Package_Width_in__c = Math.Ceil(shipment.Package_Width_in__c);
            
            dimensions.Height = Integer.valueOf(shipment.Package_Depth_in__c);
            dimensions.Length = Integer.valueOf(shipment.Package_Length_in__c);
            dimensions.Width = Integer.valueOf(shipment.Package_Width_in__c);  
            dimensions.Units = ShipItHelper.shipItSettings.get(ShipItHelper.DIMENSION_UNITE).value__c;
            
            packageLineItems.Dimensions = dimensions;    
        }
        
        //Make List of Package Line Items
        List<ShipItFedExRateService.RequestedPackageLineItem> lineItemList = new List<ShipItFedExRateService.RequestedPackageLineItem>();
        lineItemList.add(packageLineItems);
        
        //Assign signature option details
        //THis is the optional parameter
        
        //Assign Requested Package Line Items to the Requested Shipment Instance
        requestedShipment.RequestedPackageLineItems = lineItemList;
        
        //================================ Make Request for Rate Services ========================================
        ShipItFedExRateService.RateServicePort rateRequest = new  ShipItFedExRateService.RateServicePort();
        
        //Career Codes
        List<String> careerCodes = new List<String>();
        List<String> variableOptions = new List<String>();
        ShipItFedExRateService.ConsolidationKey consolidationKey = new ShipItFedExRateService.ConsolidationKey();
        
         //Set Request time in Web Service log
        webServiceLog.Request_Sent__c = DateTime.now();
        webServiceLog.Web_Service_Class__c = 'ShipItServiceController';
        webServiceLog.Web_Service_Method__c = 'requestRateServiceToFedEx';
        webServiceLog.Web_Service_Name__c = 'ShipItFedExRateService';
        webServiceLog.Request_Message__c = 'Get Delivery options';
        webServiceLog.Shipment__c = shipment.Id;
        ShipItFedExRateService.RateReply rateReply;
        
        if(Test.isRunningTest()){
            rateReply = ShipItFedExMockResponse.testRateRequestService(authenticationDetail,clientDetail, transactionDetails,versionId);        
        }else{
            
            rateReply = rateRequest.getRates(authenticationDetail,clientDetail,transactionDetails,versionId,returnTransmitAndCommit,
                                         careerCodes,variableOptions,consolidationKey, requestedShipment);
        }
        
        //Set Response time in Web service Log
        webServiceLog.Response_Received__c = DateTime.now();
        
        //Start -  Added by Rajeev for CR:
        //Set Request Message Log in Web service Log
        if(requestedShipment != null)
        {
            webServiceLog.Request_Message_Log__c = requestedShipment.toString().left(32000);
        }
        //End -  Added by Rajeev for CR:
        
        //Check the Size of Reply Options and fill it in Delivery Option Wrapper
        List<DeliveryOptionWrapper> deliveryOptionList = new List<DeliveryOptionWrapper>();
            
        //================================================ Parse Response =======================================================
        //Get Notification(Notifaication always comes with following attribute severity,Source,Code,Message,LocalizedMessage)
        ShipItFedExRateService.Notification[] notifications = rateReply.Notifications;
        
        //Hold Customer Transaction Id
        ShipItFedExRateService.TransactionDetail transactionDetail = rateReply.TransactionDetail;
        
        String logNotifcation = '', warnMsg = '';
        String transactionId = transactionDetail != null ? transactionDetail.CustomerTransactionId : '';
        
        //Check Size of Notication Result Returned in Response
        if(notifications.size()>0){
            
            //Combine all notification and set to web service log(All notification will be stored in web Service log)
            logNotifcation = notifications[0].Severity + ',' + notifications[0].Source + ',' + notifications[0].Code + ',' 
                            + notifications[0].Message + ',' + notifications[0].MessageParameters + ',' + transactionId;
            
            webServiceLog.Error_Message__c = logNotifcation;
            webServiceLog.Response_Message__c = notifications[0].Message;
            webServiceLog.Response_Message_Log__c = rateReply.toString().left(32000);
            webServiceLog.Requested_By__c = UserInfo.getUserId();
            
            //Warn Message will be displayed on the page
            warnMsg = notifications[0].Code + '-' + notifications[0].Message + '-' + shipment.Id;
        }
        
        //Check Response from fedEx
        if(rateReply.HighestSeverity.equalsIgnoreCase(ShipItHelper.FED_INTEGRATION_RESPONSE_SUCCESS) || 
           rateReply.HighestSeverity.equalsIgnoreCase(ShipItHelper.FED_INTEGRATION_RESPONSE_NOTE) || 
           rateReply.HighestSeverity.equalsIgnoreCase(ShipItHelper.FED_INTEGRATION_RESPONSE_WARNING)){
        	    
            //Parse Rate Reply Data on the Success
            for(ShipItFedExRateService.RateReplyDetail replyDetail : rateReply.RateReplyDetails){
               
                //Get Rated Shipment Detail
                ShipItFedExRateService.RatedShipmentDetail[] ratedShipmentDetails = replyDetail.RatedShipmentDetails;
                ShipItFedExRateService.ShipmentRateDetail shipmentRateDetail = ratedShipmentDetails[0].ShipmentRateDetail;
                
                //Get Totla Net Freight
                ShipItFedExRateService.Money totalNetFreight = shipmentRateDetail.TotalNetFreight;
                ShipItFedExRateService.Money totalSurcharges = shipmentRateDetail.TotalSurcharges;
                ShipItFedExRateService.Money totalTaxes = shipmentRateDetail.TotalTaxes;
                ShipItFedExRateService.Money totalNetCharge = shipmentRateDetail.TotalNetCharge;
                
                //String cateogry
                String category = '', groundServiceDeliveryTime = '';
                
                
                groundServiceDeliveryTime = (replyDetail.ServiceType == 'FEDEX_GROUND' || replyDetail.ServiceType == 'GROUND_HOME_DELIVERY') && String.isNotBlank(replyDetail.TransitTime) ? ShipItHelper.fedExGroundServiceTimeMap.get(replyDetail.TransitTime) : '';
               	
               	System.debug(shipment.Bill_To__c+' ::::: @@@@replyDetail.ServiceType::: '+ replyDetail.ServiceType +'  :::::@@replyDetail.TransitTime (date time):::'+ replyDetail.TransitTime +'::::@@@@replyDetail.DeliveryTimestamp '+replyDetail.DeliveryTimestamp);
                
                
                //Check for Billing Type Selected, Personal Shipping
                if(shipment.Bill_To__c == 'Personal'){
                    
                    //Get All Ship Methods Related to Personal and no Authorization Required since billing is personal.
                    //User will have to pay on his own paycheck, So no approval required
                    
                    //Get Ship It method of Persoanl type based on available services return from Fed Ex in Response.
                    ShipIt_ShipMethod__c personalShipMethod = ShipItHelper.pshipItMethods.get(replyDetail.ServiceType);
                    
                    if(personalShipMethod != null){
                        
                        category = ShipItHelper.shipItSettings.get('ShipCategoryPersonal') != null ? ShipItHelper.shipItSettings.get('ShipCategoryPersonal').value__c : '';
                        
                        //Add All options returned from fedex in List and display options on the screen
                        deliveryOptionList.add(new DeliveryOptionWrapper(replyDetail.ServiceType, replyDetail.PackagingType,
                                                                        category, replyDetail.DeliveryDayOfWeek, replyDetail.DeliveryTimestamp,
                                                                        replyDetail.SignatureOption, totalNetFreight.Amount,
                                                                        totalSurcharges.Amount, totalTaxes.Amount,
                                                                        totalNetCharge.Amount,true,false,groundServiceDeliveryTime));
                    }
                //Department billing
                }else{
                    
                    //Get Ship It method of Departemt type based on available services return from Fed Ex in Response.
                    ShipIt_ShipMethod__c departmentShipMethod = ShipItHelper.dshipItMethods.get(replyDetail.ServiceType);
                    
                    if(departmentShipMethod != null){
                        
                        if(shipment.Authorization_Status__c == 'Denied' && departmentShipMethod.Authorization_Required__c){
                            continue;    
                        }
                        
                        //Check If Authorization Required
                        if(departmentShipMethod.Authorization_Required__c){
                            category = ShipItHelper.shipItSettings.get('ShipCategoryStandard') != null ? ShipItHelper.shipItSettings.get('ShipCategoryStandard').value__c : '';
                            deliveryOptionList.add(new DeliveryOptionWrapper(replyDetail.ServiceType, replyDetail.PackagingType,
                                                                        category, replyDetail.DeliveryDayOfWeek, replyDetail.DeliveryTimestamp,
                                                                        replyDetail.SignatureOption, totalNetFreight.Amount,
                                                                        totalSurcharges.Amount, totalTaxes.Amount,
                                                                        totalNetCharge.Amount,true,true,groundServiceDeliveryTime));
                        }else{
                            category = ShipItHelper.shipItSettings.get('ShipCategoryAuthorization') != null ? ShipItHelper.shipItSettings.get('ShipCategoryAuthorization').value__c : '';
                            deliveryOptionList.add(new DeliveryOptionWrapper(replyDetail.ServiceType, replyDetail.PackagingType,
                                                                        category, replyDetail.DeliveryDayOfWeek, replyDetail.DeliveryTimestamp,
                                                                        replyDetail.SignatureOption, totalNetFreight.Amount,
                                                                        totalSurcharges.Amount, totalTaxes.Amount,
                                                                        totalNetCharge.Amount,true,false,groundServiceDeliveryTime));
                        }
                    }
                }
            }
            
            //Sort in Chippest to Most Expensive Options so we can set first option as recommended after sorting
            deliveryOptionList.sort();
            
            //Loop over the List and Reset Indexing of it{
            for(Integer i=0; i<deliveryOptionList.size(); i++){
                
                if(i == 0){
                    deliveryOptionList[0].recommended = true;    
                    deliveryOptionList[0].isRecommended = true;   
                    deliveryOptionList[0].isAuthorizationRequired = false;
                }
                
                deliveryOptionList[i].optionIndex = i; 
            }
               
            //Check if Waarning then display message on the screen
            if(rateReply.HighestSeverity.equalsIgnoreCase(ShipItHelper.FED_INTEGRATION_RESPONSE_WARNING)){
                
                //Warning message will not stop the app but will be displayed on the page
                ShipItHelper.displayErrorMessages(warnMsg);    
            }
        }else{
            
            //Log Record to Web Service Log Object
            //ERROR or FAILURE message will stop the apps current functionality will be displayed on the page
            ShipItHelper.displayErrorMessages(warnMsg);   
        }
        System.debug('CHeck Delivery Option List  ' + deliveryOptionList);
        return deliveryOptionList;
    }
    
     /**
    *  @description    :   Method to validate Shipment Data from the final review Screen of Ship It Appp.
    *           
    *  @args           :   Shipment Instancce
    * 
    *  @return         :   
    * 
    **/
    public Boolean validateShipment(Shipment__c shipment, Web_Service_Log__c webServiceLog){
        
        //Flag to Show that shipment was validated Succesfully to End User
        Boolean isShipmentValidated = false;
        
        ShipItFedExShipmentService.WebAuthenticationCredential credentials = new ShipItFedExShipmentService.WebAuthenticationCredential();
        credentials.Key = key;
        credentials.password = password;
        
        ShipItFedExShipmentService.WebAuthenticationDetail authenticationDetail = new ShipItFedExShipmentService.WebAuthenticationDetail();
        authenticationDetail.UserCredential = credentials;
        
        //Add CLient Detail
        ShipItFedExShipmentService.ClientDetail clientDetail = new ShipItFedExShipmentService.ClientDetail();
        clientDetail.AccountNumber = accountNumber;
        clientDetail.MeterNumber = meterNumber;
        
        //Version Id
        ShipItFedExShipmentService.VersionId  versionId = new ShipItFedExShipmentService.VersionId();
        
        //Version Setting
        versionId.ServiceId = ShipItHelper.shipItSettings.get(ShipItHelper.VERSIONSERVICEID_SHIPSERVICE).value__c;
        versionId.Major = Integer.valueOf(ShipItHelper.shipItSettings.get(ShipItHelper.VERSIONMAJORID_SHIPSERVICE).value__c);
        versionId.Intermediate = Integer.valueOf(ShipItHelper.shipItSettings.get(ShipItHelper.VERSIONINTERMEDIATE_SHIPSERVICE).value__c);
        versionId.Minor = Integer.valueOf(ShipItHelper.shipItSettings.get(ShipItHelper.VERSIONMINOR_SHIPSERVICE).value__c);
        
        //Add Transaction Details
        ShipItFedExShipmentService.TransactionDetail transactionDetails = new ShipItFedExShipmentService.TransactionDetail();
        transactionDetails.CustomerTransactionId = shipment.id + dateTime.now().format('MM-dd-YYYY hh:mm a');
        
         //================= Prepare Requested Shipment Data ========================================================================
        ShipItFedExShipmentService.RequestedShipment requestedShipment = new ShipItFedExShipmentService.RequestedShipment();
        //requestedShipment.ShipTimestamp = DateTime.newInstance(shipment.Ship_Date__c, DateTime.now().time()); 
        //requestedShipment.ShipTimestamp = DateTime.now().addDays(1);
        DateTime dropoffDateTime = DateTime.newInstance(shipment.Ship_Date__c.year(),shipment.Ship_Date__c.month(),shipment.Ship_Date__c.day(),0,0,0);
        //system.debug('ShipItServiceController.validateShipment - dropoffDateTime: '+dropoffDateTime);
        dropoffDateTime = dropoffDateTime.addHours(offsetDropOffTime);
        //system.debug('ShipItServiceController.validateShipment - dropoffDateTime(offset): '+dropoffDateTime);
        //requestedShipment.ShipTimestamp = DateTime.newInstance(shipment.Ship_Date__c, DateTime.now().time()+offsetDropOffTime); 
        requestedShipment.ShipTimestamp = dropoffDateTime;
        //system.debug('ShipItServiceController.validateShipment - requestedShipment.ShipTimeStamp: '+requestedShipment.ShipTimeStamp);
        
        requestedShipment.DropoffType = ShipItHelper.shipItSettings.get('DropoffType').value__c;
        requestedShipment.PackagingType = ShipItHelper.getSelectedPackageInstanceByFullName(shipment.Package_Type__c).Name;
        requestedShipment.ServiceType = shipment.Ship_Method__c;
        requestedShipment.BlockInsightVisibility = false;
        
       
        // ====================== Prepare Shipper Data ==========================
        //Create Contact And Assign it later on party Object
        ShipItFedExShipmentService.Contact contactData = new ShipItFedExShipmentService.Contact();
        contactData.CompanyName = ShipItHelper.shipItSettings.get(ShipItHelper.SENDERCOMPANYNAME).value__c;
        contactData.PersonName = shipment.Sender_Name__c;
        contactData.PhoneNumber = shipment.Sender_Phone__c;
        
        //Prepare Address Data
        ShipItFedExShipmentService.Address addressdata = new ShipItFedExShipmentService.Address();
        
         //Add List of Streets
        List<String> streetLines = new List<String>();
        streetLines.add(shipment.Sender_Address_Line_1__c);
        streetLines.add(shipment.Sender_Address_Line_2__c);
        addressdata.StreetLines = streetLines; 
        addressdata.City = shipment.Sender_City__c;
        addressdata.StateOrProvinceCode = shipment.Sender_State_Province__c;
        addressdata.PostalCode = shipment.Sender_PostalCode__c; 
        addressdata.CountryCode = ShipItHelper.shipItSettings.get(ShipItHelper.SENDERCOUNTRYCODE).value__c;
        
        
        //Add Shipper Information , which holds contact, address and acccount Number Details'
        ShipItFedExShipmentService.Party shipper = new ShipItFedExShipmentService.Party();
        shipper.AccountNumber = accountNumber;
        shipper.Contact = contactData;
        shipper.Address = addressdata;
        
        //Set Shipper in Requested Shipment
        requestedShipment.Shipper = shipper;
        
        //=================== Prepare Recipient Data ======================================
        //Create Contact And Assign it later on party Object
        ShipItFedExShipmentService.Contact recipientContactData = new ShipItFedExShipmentService.Contact();
        recipientContactData.CompanyName = shipment.Recipient_Company__c;
        recipientContactData.PersonName = shipment.Recipient_Name__c;
        recipientContactData.PhoneNumber = shipment.Recipient_Phone__c;
        
        //Prepare Address Data
        ShipItFedExShipmentService.Address recipientAddressdata = new ShipItFedExShipmentService.Address();
        
         //Add List of Streets
        streetLines = new List<String>();
        streetLines.add(shipment.Recipient_Address_Line_1__c);
        streetLines.add(shipment.Recipient_Address_Line_2__c);
        
        recipientAddressdata.StreetLines = streetLines; 
        recipientAddressdata.City = shipment.Recipient_City__c;
        recipientAddressdata.StateOrProvinceCode = shipment.Recipient_State_Province__c;
        recipientAddressdata.PostalCode = shipment.Recipient_PostalCode__c; 
        recipientAddressdata.CountryCode = ShipItHelper.shipItSettings.get(ShipItHelper.RECIPIENTCOUNTRYCODE).value__c;
        
        //Rj(04/30/2015) Sending Residential flag it make difference in Delivery Option Rate Charges
        //If address is Residential then shipment charges are higher then the Business and other address options
        //Set Is Residential Flag True if Address Classification field is Residential 
        recipientAddressdata.Residential = shipment.Address_Classification__c.equalsIgnoreCase('Residential') ? true : false;
        
        //Add Shipper Information , which holds contact, address and acccount Number Details'
        ShipItFedExShipmentService.Party recipient = new ShipItFedExShipmentService.Party();
        recipient.AccountNumber = accountNumber;
        recipient.Contact = recipientContactData;
        recipient.Address = recipientAddressdata;
        
        //Assign Recipient in Requested Shipment
        requestedShipment.Recipient = recipient;
        
        //List to hold Rate request type
        List<String> rateRequestList = new List<String>{ShipItHelper.shipItSettings.get(ShipItHelper.RATEREQUESTTYPE).value__c};
        requestedShipment.RateRequestTypes = rateRequestList;
        
        // ====================================== Shipping Charges Payment ================================================
        //Add Payment Type
        ShipItFedExShipmentService.Payment chargesPayment = new ShipItFedExShipmentService.Payment();
        chargesPayment.PaymentType = shipItHelper.shipItSettings.get('PaymentType').value__c;
        
        ShipItFedExShipmentService.Payor payor = new ShipItFedExShipmentService.Payor();
        
        //Add Resposnible Party 
        ShipItFedExShipmentService.Party resposnibleParty = new ShipItFedExShipmentService.Party();
        resposnibleParty.AccountNumber = accountNumber;
        
        //Assign resposnible party in Payyor
        payor.ResponsibleParty = resposnibleParty;
        
        //Asssign payor in charges payment
        chargesPayment.Payor = payor;
        
        //====================================== Label specifications ==============================================
        ShipItFedExShipmentService.LabelSpecification labelSpecifications = new ShipItFedExShipmentService.LabelSpecification();
        labelSpecifications.LabelFormatType = ShipItHelper.shipItSettings.get('LabelFormatType').value__c;
        labelSpecifications.ImageType = ShipItHelper.shipItSettings.get('LabelImageType').value__c;
        labelSpecifications.LabelStockType = ShipItHelper.shipItSettings.get('LabelStockType').value__c;
        
        //========================================== Requested Package Line Items ==========================================
        //Add Package Line Items
        ShipItFedExShipmentService.RequestedPackageLineItem packageLineItem = new ShipItFedExShipmentService.RequestedPackageLineItem();
        
               
        //Start -  Added by Rajeev for CR:
        //Set Insured Value
        ShipItFedExShipmentService.Money money = new ShipItFedExShipmentService.Money();
        money.Currency_x = ShipItHelper.CURRENCY_USD;
        
        //Check if Declared Value is blank then apply default insurance amount for it.
        if(shipment.Declared_Value__c != null && shipment.Declared_Value__c >= 100){
            money.Amount =  shipment.Declared_Value__c;   
        }else{
            money.Amount = Decimal.valueOf(ShipItHelper.shipItSettings.get(ShipItHelper.DEFAULTINSURENCE).value__c);
            //set default insurance flag
            shipment.Add_Default_Insurance__c = true;
        }
         //set insuredValue in packageLineItems
         packageLineItem.InsuredValue = money;
       //End -  Added by Rajeev for CR: 
       
        //Create Customer Reference
        ShipItFedExShipmentService.CustomerReference customerReference = new ShipItFedExShipmentService.CustomerReference();
        customerReference.CustomerReferenceType = ShipItHelper.shipItSettings.get('CustomerReferenceType').value__c;
        customerReference.Value = shipment.Id;
        
        //List custom References 
        List<ShipItFedExShipmentService.CustomerReference> customerReferences = new List<ShipItFedExShipmentService.CustomerReference>();
        customerReferences.add(customerReference);
        
        //Prepare Weight Data
        ShipItFedExShipmentService.Weight weightData = new ShipItFedExShipmentService.Weight();
        weightData.Units = shipItHelper.shipItSettings.get(shipItHelper.WEIGHTUNITSTRING).value__c;
        weightData.Value = (Decimal)shipment.Weight_Estimated__c;
        
        //Assign Customer Reference in Package Line Item
        packageLineItem.CustomerReferences = customerReferences;
        packageLineItem.Weight = weightData;
        
        
        //Asssign all of data to Requested Shipment
        requestedShipment.ShippingChargesPayment = chargesPayment;
        requestedShipment.LabelSpecification = labelSpecifications;
        requestedShipment.PackageCount = 1;
        
        //Make List of Package Line Items
        List<ShipItFedExShipmentService.RequestedPackageLineItem> lineItemList = new List<ShipItFedExShipmentService.RequestedPackageLineItem>();
        lineItemList.add(packageLineItem);
        
        //Assign signature option details
        //THis is the optional parameter
        
        //Assign Requested Package Line Items to the Requested Shipment Instance
        requestedShipment.RequestedPackageLineItems = lineItemList;
        
        //Set Request time in Web Service log
        webServiceLog.Request_Sent__c = DateTime.now();
        webServiceLog.Web_Service_Class__c = 'ShipItServiceController';
        webServiceLog.Web_Service_Method__c = 'validateShipment';
        webServiceLog.Web_Service_Name__c = 'ShipItFedExShipService';
        webServiceLog.Request_Message__c = 'Validate Shipment on FedEx';
        webServiceLog.Shipment__c = shipment.Id;
        
        //============================================= Make Request to Fex Ex =============================================
        //Make Validate Shipment Request
        ShipItFedExShipmentService.ShipServicePort servicePort = new ShipItFedExShipmentService.ShipServicePort();
        ShipItFedExShipmentService.ShipmentReply shipmentValidationReply;
        
        if(Test.isRunningTest()){
            shipmentValidationReply = ShipItFedExMockResponse.testValidateShipmentService(authenticationDetail,clientDetail,transactionDetails,versionId);     
        }else{
            shipmentValidationReply = servicePort.validateShipment(authenticationDetail,clientDetail,transactionDetails,versionId,requestedShipment);    
        }
        
        //Set Response time in Web service Log
        webServiceLog.Response_Received__c = DateTime.now();
        
        //Start -  Added by Rajeev for CR: 
        //Set Request Message Log in Web service Log
        if(requestedShipment != null)
        {
            webServiceLog.Request_Message_Log__c = requestedShipment.toString().left(32000);
        }
        //End -  Added by Rajeev for CR:
        
        
        //Hold Notifications
        ShipItFedExShipmentService.Notification[] notifications = shipmentValidationReply.Notifications;
        
        //Hold Customer Transaction Id
        ShipItFedExShipmentService.TransactionDetail transactionDetail = shipmentValidationReply.TransactionDetail;
        
        String logNotifcation = '', warnMsg = '';
        String transactionId = transactionDetail != null ? transactionDetail.CustomerTransactionId : '';    
        
        //Check Size of Notication Result Returned in Response
        if(notifications.size()>0){
            
            //Combine all notification and set to web service log(All notification will be stored in web Service log)
            logNotifcation = notifications[0].Severity + ',' + notifications[0].Source + ',' + notifications[0].Code + ',' 
                            + notifications[0].Message + ',' + notifications[0].MessageParameters + ',' + transactionId;
            
            webServiceLog.Error_Message__c = logNotifcation;
            webServiceLog.Response_Message__c = notifications[0].Message;
            webServiceLog.Response_Message_Log__c = shipmentValidationReply.toString().left(32000);
            webServiceLog.Requested_By__c = UserInfo.getUserId();
            
            //Warn Message will be displayed on the page
            warnMsg = notifications[0].Code + '-' + notifications[0].Message + '-' + shipment.Id;
        }
        
        //=================================== Parse Validate Shipment Response ==================================================
        //System.debug('Check Highest Severity in Shipment Validation Reply :::: ' + shipmentValidationReply.HighestSeverity);
        if(shipmentValidationReply.HighestSeverity.equalsIgnoreCase(ShipItHelper.FED_INTEGRATION_RESPONSE_SUCCESS) || 
           shipmentValidationReply.HighestSeverity.equalsIgnoreCase(ShipItHelper.FED_INTEGRATION_RESPONSE_WARNING) || 
          shipmentValidationReply.HighestSeverity.equalsIgnoreCase(ShipItHelper.FED_INTEGRATION_RESPONSE_NOTE)){
              
            isShipmentValidated = true;
              
            //processShipmentAndPrintLabel(shipment);
            //Check if Waarning then display message on the screen
            if(shipmentValidationReply.HighestSeverity.equalsIgnoreCase(ShipItHelper.FED_INTEGRATION_RESPONSE_WARNING)){
                
                //Warning message will not stop the app but will be displayed on the page
                ShipItHelper.displayErrorMessages(warnMsg);    
            }
          }else{
              
            //ERROR or FAILURE message will stop the apps current functionality will be displayed on the page
            ShipItHelper.displayErrorMessages(warnMsg); 
          }
        
        return isShipmentValidated;
    }
    
     /**
    *  @description    :   Method to Process Shipment and Print label from the review screen.
    *           
    *  @args           :   Shipment Instancce
    * 
    *  @return         :   
    * 
    **/
    public Boolean processShipmentAndPrintLabel(Shipment__c shipment, Web_Service_Log__c webServiceLog){
        
        //Flag to show if shipment was Processed Successfully
        Boolean isShipmentProcessed = false;
        
        ShipItFedExShipmentService.WebAuthenticationCredential credentials = new ShipItFedExShipmentService.WebAuthenticationCredential();
        credentials.Key = key;
        credentials.password = password;
        
        ShipItFedExShipmentService.WebAuthenticationDetail authenticationDetail = new ShipItFedExShipmentService.WebAuthenticationDetail();
        authenticationDetail.UserCredential = credentials;
        
        //Add CLient Detail
        ShipItFedExShipmentService.ClientDetail clientDetail = new ShipItFedExShipmentService.ClientDetail();
        clientDetail.AccountNumber = accountNumber;
        clientDetail.MeterNumber = meterNumber;
        
        //Version Id
        ShipItFedExShipmentService.VersionId  versionId = new ShipItFedExShipmentService.VersionId();
        
        //Version Setting
        //Version Setting
        versionId.ServiceId = ShipItHelper.shipItSettings.get(ShipItHelper.VERSIONSERVICEID_SHIPSERVICE).value__c;
        versionId.Major = Integer.valueOf(ShipItHelper.shipItSettings.get(ShipItHelper.VERSIONMAJORID_SHIPSERVICE).value__c);
        versionId.Intermediate = Integer.valueOf(ShipItHelper.shipItSettings.get(ShipItHelper.VERSIONINTERMEDIATE_SHIPSERVICE).value__c);
        versionId.Minor = Integer.valueOf(ShipItHelper.shipItSettings.get(ShipItHelper.VERSIONMINOR_SHIPSERVICE).value__c);
        
        //Add Transaction Details
        ShipItFedExShipmentService.TransactionDetail transactionDetails = new ShipItFedExShipmentService.TransactionDetail();
        transactionDetails.CustomerTransactionId = shipment.id + dateTime.now().format('MM-dd-YYYY hh:mm a');
        
        //================================= Prepare Requested Shipment Data ==================================================
         //================= Prepare Requested Shipment Data ========================================================================
        ShipItFedExShipmentService.RequestedShipment requestedShipment = new ShipItFedExShipmentService.RequestedShipment();
        //requestedShipment.ShipTimestamp = DateTime.newInstance(shipment.Ship_Date__c, DateTime.now().time()); 
        DateTime dropoffDateTime = DateTime.newInstance(shipment.Ship_Date__c.year(),shipment.Ship_Date__c.month(),shipment.Ship_Date__c.day(),0,0,0);
        system.debug('ShipItServiceController.processShipmentAndPrintLabel - dropoffDateTime: '+dropoffDateTime);
        dropoffDateTime = dropoffDateTime.addHours(offsetDropOffTime);
        system.debug('ShipItServiceController.processShipmentAndPrintLabel - dropoffDateTime(offset): '+dropoffDateTime);
        //requestedShipment.ShipTimestamp = DateTime.newInstance(shipment.Ship_Date__c, DateTime.now().time()+offsetDropOffTime); 
        requestedShipment.ShipTimestamp = dropoffDateTime;
        system.debug('ShipItServiceController.processShipmentAndPrintLabel - requestedShipment.ShipTimeStamp: '+requestedShipment.ShipTimeStamp);
        requestedShipment.DropoffType = ShipItHelper.shipItSettings.get('DropoffType').value__c;
        requestedShipment.PackagingType = ShipItHelper.getSelectedPackageInstanceByFullName(shipment.Package_Type__c).Name;
        requestedShipment.ServiceType = shipment.Ship_Method__c;
        requestedShipment.BlockInsightVisibility = false;
        
        // ====================== Prepare Shipper Data ==========================
        //Create Contact And Assign it later on party Object
        ShipItFedExShipmentService.Contact contactData = new ShipItFedExShipmentService.Contact();
        contactData.CompanyName = ShipItHelper.shipItSettings.get(ShipItHelper.SENDERCOMPANYNAME).value__c;
        contactData.PersonName = shipment.Sender_Name__c;
        contactData.PhoneNumber = shipment.Sender_Phone__c;
        
        //Prepare Address Data
        ShipItFedExShipmentService.Address addressdata = new ShipItFedExShipmentService.Address();
        
         //Add List of Streets
        List<String> streetLines = new List<String>();
        streetLines.add(shipment.Sender_Address_Line_1__c);
        streetLines.add(shipment.Sender_Address_Line_2__c);
        addressdata.StreetLines = streetLines; 
        addressdata.City = shipment.Sender_City__c;
        addressdata.StateOrProvinceCode = shipment.Sender_State_Province__c;
        addressdata.PostalCode = shipment.Sender_PostalCode__c; 
        addressdata.CountryCode = ShipItHelper.shipItSettings.get(ShipItHelper.SENDERCOUNTRYCODE).value__c;
        
        //Add Shipper Information , which holds contact, address and acccount Number Details'
        ShipItFedExShipmentService.Party shipper = new ShipItFedExShipmentService.Party();
        shipper.AccountNumber = accountNumber;
        shipper.Contact = contactData;
        shipper.Address = addressdata;
        
        //Set Shipper in Requested Shipment
        requestedShipment.Shipper = shipper;
        
        //=================== Prepare Recipient Data ======================================
        //Create Contact And Assign it later on party Object
        ShipItFedExShipmentService.Contact recipientContactData = new ShipItFedExShipmentService.Contact();
        recipientContactData.CompanyName = shipment.Recipient_Company__c;
        recipientContactData.PersonName = shipment.Recipient_Name__c;
        recipientContactData.PhoneNumber = shipment.Recipient_Phone__c;
        
        //Prepare Address Data
        ShipItFedExShipmentService.Address recipientAddressdata = new ShipItFedExShipmentService.Address();
        
         //Add List of Streets
        streetLines = new List<String>();
        streetLines.add(shipment.Recipient_Address_Line_1__c);
        streetLines.add(shipment.Recipient_Address_Line_2__c);
        
        recipientAddressdata.StreetLines = streetLines; 
        recipientAddressdata.City = shipment.Recipient_City__c;
        recipientAddressdata.StateOrProvinceCode = shipment.Recipient_State_Province__c;
        recipientAddressdata.PostalCode = shipment.Recipient_PostalCode__c; 
        recipientAddressdata.CountryCode = ShipItHelper.shipItSettings.get(ShipItHelper.RECIPIENTCOUNTRYCODE).value__c;
        
        //Rj(04/30/2015) Sending Residential flag it make difference in Delivery Option Rate Charges
        //If address is Residential then shipment charges are higher then the Business and other address options
        //Set Is Residential Flag True if Address Classification field is Residential 
        recipientAddressdata.Residential = shipment.Address_Classification__c.equalsIgnoreCase('Residential') ? true : false;
        
        //Add Shipper Information , which holds contact, address and acccount Number Details'
        ShipItFedExShipmentService.Party recipient = new ShipItFedExShipmentService.Party();
        recipient.AccountNumber = accountNumber;
        recipient.Contact = recipientContactData;
        recipient.Address = recipientAddressdata;
        
        //Assign Recipient in Requested Shipment
        requestedShipment.Recipient = recipient;
        
        //List to hold Rate request type
        List<String> rateRequestList = new List<String>{ShipItHelper.shipItSettings.get(ShipItHelper.RATEREQUESTTYPE).value__c};
        requestedShipment.RateRequestTypes = rateRequestList;
        
        //=================================== Shipping Charges Payment ==========================================================
        //Add Payment Type
        ShipItFedExShipmentService.Payment chargesPayment = new ShipItFedExShipmentService.Payment();
        chargesPayment.PaymentType = shipItHelper.shipItSettings.get('PaymentType').value__c;
        
        ShipItFedExShipmentService.Payor payor = new ShipItFedExShipmentService.Payor();
        
        //Add Resposnible Party 
        ShipItFedExShipmentService.Party resposnibleParty = new ShipItFedExShipmentService.Party();
        resposnibleParty.AccountNumber = accountNumber;
        
        //Assign resposnible party in Payyor
        payor.ResponsibleParty = resposnibleParty;
        
        //Asssign payor in charges payment
        chargesPayment.Payor = payor;
        
        //=============================== Label specifications ===================================================================
        ShipItFedExShipmentService.LabelSpecification labelSpecifications = new ShipItFedExShipmentService.LabelSpecification();
        labelSpecifications.LabelFormatType = ShipItHelper.shipItSettings.get('LabelFormatType').value__c;
        labelSpecifications.ImageType = ShipItHelper.shipItSettings.get('LabelImageType').value__c;
        labelSpecifications.LabelStockType = ShipItHelper.shipItSettings.get('LabelStockType').value__c;
        
        //================================ Requested Package Line Items =======================================================
        //Add Package Line Items
        ShipItFedExShipmentService.RequestedPackageLineItem packageLineItem = new ShipItFedExShipmentService.RequestedPackageLineItem();
        
        //Start -  Added by Rajeev for CR:
        //Set Insured Value
        ShipItFedExShipmentService.Money money = new ShipItFedExShipmentService.Money();
        money.Currency_x = ShipItHelper.CURRENCY_USD;
        
        //Check if Declared Value is blank then apply default insurance amount for it.
        if(shipment.Declared_Value__c != null && shipment.Declared_Value__c >= 100){
            money.Amount =  shipment.Declared_Value__c;   
        }else{
            money.Amount = Decimal.valueOf(ShipItHelper.shipItSettings.get(ShipItHelper.DEFAULTINSURENCE).value__c);
            //set default insurance flag
            shipment.Add_Default_Insurance__c = true;
        }
         //set insuredValue in packageLineItems
         packageLineItem.InsuredValue = money;
       //End -  Added by Rajeev for CR: 
       
        //Create Customer Reference
        ShipItFedExShipmentService.CustomerReference customerReference = new ShipItFedExShipmentService.CustomerReference();
        customerReference.CustomerReferenceType = ShipItHelper.shipItSettings.get('CustomerReferenceType').value__c;
        customerReference.Value = shipment.Id;
        
        //List custom References 
        List<ShipItFedExShipmentService.CustomerReference> customerReferences = new List<ShipItFedExShipmentService.CustomerReference>();
        customerReferences.add(customerReference); 
        
         //Prepare Weight Data
        ShipItFedExShipmentService.Weight weightData = new ShipItFedExShipmentService.Weight();
        weightData.Units = shipItHelper.shipItSettings.get(shipItHelper.WEIGHTUNITSTRING).value__c;
        weightData.Value = (Decimal)shipment.Weight_Estimated__c;
        
        //Assign Customer Reference in Package Line Item
        packageLineItem.CustomerReferences = customerReferences;
        packageLineItem.Weight = weightData;
        
        //Asssign all of data to Requested Shipment
        requestedShipment.ShippingChargesPayment = chargesPayment;
        requestedShipment.LabelSpecification = labelSpecifications;
        requestedShipment.PackageCount = 1;
        
        //Make List of Package Line Items
        List<ShipItFedExShipmentService.RequestedPackageLineItem> lineItemList = new List<ShipItFedExShipmentService.RequestedPackageLineItem>();
        lineItemList.add(packageLineItem);
        
        //Assign signature option details
        //THis is the optional parameter
        
        //Assign Requested Package Line Items to the Requested Shipment Instance
        requestedShipment.RequestedPackageLineItems = lineItemList;
        
        //====================================== Special Service Requested(Here We Included email Notification Service) =============================================
        //This Service decides notification needs to be send during whole shipment to respective parties.
        
        ShipItFedExShipmentService.ShipmentSpecialServicesRequested specialServiceRequested = new ShipItFedExShipmentService.ShipmentSpecialServicesRequested();
        
        //Create List of Special Services
        List<String> serviceList = new List<String>();
        serviceList.add(ShipItHelper.shipItSettings.get('EmailNoticeServiceType').value__c);
        
        //Assign special Service Types
        specialServiceRequested.SpecialServiceTypes = serviceList;
        
        //========== Email Notification detail =================================
        ShipItFedExShipmentService.EMailNotificationDetail emailNotificationDetail = new ShipItFedExShipmentService.EMailNotificationDetail();
        
        //Personal Message
        emailNotificationDetail.PersonalMessage = ShipItHelper.shipItSettings.get('EmailNoticeMessage').value__c;
        
        //Responsible Parties, Recipient who will recieve notifications
        List<ShipItFedExShipmentService.EMailNotificationRecipient> emailRecipients = new List<ShipItFedExShipmentService.EMailNotificationRecipient>();
        
        //Get All three type of notification Settings
        List<String> r_PNotficationList = ShipItHelper.getShipItNotificationSettings('EmailNotice_R_P_');
        List<String> s_PNotficationList = ShipItHelper.getShipItNotificationSettings('EmailNotice_S_P_');
        List<String> s_SNotficationList = ShipItHelper.getShipItNotificationSettings('EmailNotice_S_S_');
        ShipItFedExShipmentService.EMailNotificationRecipient emailRecipient;
        
        //Localization
        ShipItFedExShipmentService.Localization localization = new ShipItFedExShipmentService.Localization();
        localization.LanguageCode = 'EN';
        
        /**
         * Notifiacaition Event Detail :
         * On Tender –  when the package is picked up from the drop-off location
         * On Shipment – when the package has been actually shipped
         * On Delivery – when the package has been delivered 
         * On Exception – when an exception occurs during package movement from origin to destination.
       * */

        //Create Instances of Recipient then add to the List
        //(If at least one setting exist in the list type of 'EmailNotice_R_P_' then Recipient Primary Email Address needs to be add in recipient)
        if(r_PNotficationList.size() > 0 && String.isNotBlank(shipment.Recipient_Email__c)){
            
            emailRecipient = new ShipItFedExShipmentService.EMailNotificationRecipient();
            emailRecipient.EMailAddress = shipment.Recipient_Email__c;
            emailRecipient.Format = shipItHelper.shipItSettings.get('EmailNoticeFormat').value__c;
            emailRecipient.NotificationEventsRequested = r_PNotficationList;
            emailRecipient.Localization = localization;
            
            //Set EMail Event Recipient Type(SHIPPER,RECIPIENT,BROKER,OTHER,THIRD_PARTY)
            emailRecipient.EMailNotificationRecipientType = 'SHIPPER';
            emailRecipients.add(emailRecipient);
        }
        //(If at least one setting exist in the list type of 'EmailNotice_S_P_' then Sender Primary Email Address needs to be add in recipient)
        if(s_PNotficationList.size() > 0 && String.isNotBlank(shipment.Sender_Email__c)){
            
            emailRecipient = new ShipItFedExShipmentService.EMailNotificationRecipient();
            emailRecipient.EMailAddress = shipment.Sender_Email__c;
            emailRecipient.Format = shipItHelper.shipItSettings.get('EmailNoticeFormat').value__c;
            emailRecipient.NotificationEventsRequested = s_PNotficationList;
            emailRecipient.Localization = localization;
            
            //Set EMail Event Recipient Type(SHIPPER,RECIPIENT,BROKER,OTHER,THIRD_PARTY)
            emailRecipient.EMailNotificationRecipientType = 'SHIPPER';
            emailRecipients.add(emailRecipient);
        }
        //(If at least one setting exist in the list type of 'EmailNotice_S_S_' then Recipient Secondary Email Address needs to be add in recipient)
        if(s_SNotficationList.size() > 0 && String.isNotBlank(shipment.Sender_Secondary_Email__c)){
            
            emailRecipient = new ShipItFedExShipmentService.EMailNotificationRecipient();
            emailRecipient.EMailAddress = shipment.Sender_Secondary_Email__c;
            emailRecipient.Format = shipItHelper.shipItSettings.get('EmailNoticeFormat').value__c;
            emailRecipient.NotificationEventsRequested = s_SNotficationList;
            emailRecipient.Localization = localization;
            
            //Set EMail Event Recipient Type(SHIPPER,RECIPIENT,BROKER,OTHER,THIRD_PARTY)
            emailRecipient.EMailNotificationRecipientType = 'SHIPPER';
            emailRecipients.add(emailRecipient);
        }
        
        //Add Recipients to Notification Details
        emailNotificationDetail.Recipients = emailRecipients;
        specialServiceRequested.EMailNotificationDetail = emailNotificationDetail;
        requestedShipment.SpecialServicesRequested = specialServiceRequested;
        
        //Set Request time in Web Service log
        webServiceLog.Request_Sent__c = DateTime.now();
        webServiceLog.Web_Service_Class__c = 'ShipItServiceController';
        webServiceLog.Web_Service_Method__c = 'processShipmentAndPrintLabel';
        webServiceLog.Web_Service_Name__c = 'ShipItFedExShipService';
        webServiceLog.Request_Message__c = 'Process Shipment and Print Label';
        webServiceLog.Shipment__c = shipment.Id;
        
        //Start -  Added by Rajeev for CR:
        //Set Request Message Log in Web service Log
        if(requestedShipment != null)
        {
            webServiceLog.Request_Message_Log__c = requestedShipment.toString().left(32000);
        }
        //End -  Added by Rajeev for CR:        
        
        
        //============================================= Make Request to Fex Ex =============================================
        //Make Validate Shipment Request
        ShipItFedExShipmentService.ShipServicePort servicePort = new ShipItFedExShipmentService.ShipServicePort();
        ShipItFedExShipmentService.ProcessShipmentReply  processShipmentReply;
        if(Test.isRunningTest()){
            processShipmentReply = ShipItFedExMockResponse.testProcessShipmentService(authenticationDetail,clientDetail,transactionDetails,versionId);    
        }else{
            processShipmentReply = servicePort.processShipment(authenticationDetail,clientDetail,transactionDetails,versionId,requestedShipment);
        }
        
        //Set Response time in Web service Log
        webServiceLog.Response_Received__c = DateTime.now();
        
        //=================================== Parse Validate Shipment Response ==================================================
        //System.debug('Check Highest Severity in Shipment Process Reply :::: ' + processShipmentReply.HighestSeverity);
        
        //Hold Notifications
        ShipItFedExShipmentService.Notification[] notifications = processShipmentReply.Notifications;
        
        //Hold Customer Transaction Id
        ShipItFedExShipmentService.TransactionDetail transactionDetail = processShipmentReply.TransactionDetail;
        
        String logNotifcation = '', warnMsg = '';
        String transactionId = transactionDetail != null ? transactionDetail.CustomerTransactionId : '';    
        
        //Check Size of Notication Result Returned in Response
        if(notifications.size()>0){
            
            //Combine all notification and set to web service log(All notification will be stored in web Service log)
            logNotifcation = notifications[0].Severity + ',' + notifications[0].Source + ',' + notifications[0].Code + ',' 
                            + notifications[0].Message + ',' + notifications[0].MessageParameters + ',' + transactionId;
            
            webServiceLog.Error_Message__c = logNotifcation;
            webServiceLog.Response_Message__c = notifications[0].Message;
            webServiceLog.Response_Message_Log__c = processShipmentReply.toString().left(32000);
            webServiceLog.Requested_By__c = UserInfo.getUserId();
            
            //Warn Message will be displayed on the page
            warnMsg = notifications[0].Code + '-' + notifications[0].Message + '-' + shipment.Id;
        }
        
        //check if Shipmment Was Successfull
        if(processShipmentReply.HighestSeverity.equalsIgnoreCase(ShipItHelper.FED_INTEGRATION_RESPONSE_SUCCESS) || 
           processShipmentReply.HighestSeverity.equalsIgnoreCase(ShipItHelper.FED_INTEGRATION_RESPONSE_WARNING) || 
           processShipmentReply.HighestSeverity.equalsIgnoreCase(ShipItHelper.FED_INTEGRATION_RESPONSE_NOTE)){
            
            shipment.Vendor_JobId__c = processShipmentReply.JobId;
            
            //Completed Shipment detail
            shipment.Carrier_Code__c = processShipmentReply.CompletedShipmentDetail.CarrierCode;
            
            //Operation Detail
            ShipItFedExShipmentService.ShipmentOperationalDetail opDetail = processShipmentReply.CompletedShipmentDetail.OperationalDetail;
            
            if(String.isNotBlank(opDetail.AstraPlannedServiceLevel)){
                
                //Get Ship It method Instance
                ShipIt_ShipMethod__c serviceInstance = ShipItHelper.allShipItMethods.get(shipment.Ship_Method__c);
                
                if(opDetail.AstraPlannedServiceLevel.contains('AT')){
                    Shipment.Delivery_Date_Text__c =  String.valueOf(serviceInstance.get('AT__c'));
                    shipment.Delivery_Date__c = null;
                }else{
                    
                    Shipment.Delivery_Date_Text__c = opDetail.AstraPlannedServiceLevel;
                    shipment.Delivery_Date__c = ShipItHelper.convertDateTimeStringToGmtFormat(opDetail.AstraPlannedServiceLevel,serviceInstance);          
                }
            }
            shipment.Delivery_Service_Description__c = opDetail.AstraDescription;   
            //Modified by Mahendra Swarnkar - 05/08/2020 - Delivery_Ineligible_For_Guarantee__c	deleted from object Shipment__c - CR-20200218-13769
            //shipment.Delivery_Ineligible_For_Guarantee__c = opDetail.IneligibleForMoneyBackGuarantee;   
            //SShipment Rating(Getting null value in Following node)
            
            /*ShipItFedExShipmentService.ShipmentRating shRating = processShipmentReply.CompletedShipmentDetail.ShipmentRating;
            System.debug('Check Shipment Raating :: ' + processShipmentReply.CompletedShipmentDetail);
            System.debug('Check Shipment Rate Details :: ' + shRating.ShipmentRateDetails);
            shipment.Ship_Freight_Amount__c = shRating.ShipmentRateDetails[0].TotalNetFreight.Amount;
            shipment.Ship_Surcharges__c = shRating.ShipmentRateDetails[0].TotalSurcharges.Amount;
            shipment.Ship_Vendor_Amount__c = shRating.ShipmentRateDetails[0].TotalNetFedExCharge.Amount;
            shipment.Ship_Taxes__c = shRating.ShipmentRateDetails[0].TotalTaxes.Amount;
            shipment.Ship_Amount__c = shRating.ShipmentRateDetails[0].TotalNetCharge.Amount;*/
            
            //Start -  Added by Rajeev for CR: 
            //Update Shipment record fields based on ProcessShipment response
            ShipItFedExShipmentService.ShipmentRating shRating = processShipmentReply.CompletedShipmentDetail.ShipmentRating;
            if(shRating != null && shRating.ShipmentRateDetails.size() > 0)
            { 
               
                for(ShipItFedExShipmentService.ShipmentRateDetail  objShipmentRateDetail : shRating.ShipmentRateDetails)
                {
                   if(objShipmentRateDetail.RateType == shRating.ActualRateType)
                   { 
                     shipment.Ship_Freight_Amount__c = shRating.ShipmentRateDetails[0].TotalNetFreight.Amount;
                     shipment.Ship_Surcharges__c = shRating.ShipmentRateDetails[0].TotalSurcharges.Amount;
                     //Commented by Mahendra Swarnakar - 05/08/2020 - CR-20200218-13769  Ship_Vendor_Amount__c field.
                     //shipment.Ship_Vendor_Amount__c = shRating.ShipmentRateDetails[0].TotalNetFedExCharge.Amount;
                     shipment.Ship_Taxes__c = shRating.ShipmentRateDetails[0].TotalTaxes.Amount;
                     shipment.Ship_Amount__c = shRating.ShipmentRateDetails[0].TotalNetCharge.Amount;
                   
                    }
                
                }
               
            }
            //End-  Added by Rajeev for CR: 
            
            //Completed Package Details
            List<ShipItFedExShipmentService.CompletedPackageDetail> completedPackageDetails = processShipmentReply.CompletedShipmentDetail.CompletedPackageDetails;
            
            //Set Tracking Number to Shipment Record
            //Tracking Ids
            List<ShipItFedExShipmentService.TrackingId> trackingIds = completedPackageDetails[0].TrackingIds;
            shipment.Tracking_Number__c = trackingIds[0].TrackingNumber;
            
            //Label
            ShipItFedExShipmentService.ShippingDocument label = completedPackageDetails[0].Label;
            
            //Check if Return type is PDF
            if(label.ImageType == 'PDF'){
                
                ShipItFedExShipmentService.ShippingDocumentPart[] parts = label.Parts;
                
                //Get Image String from parts, Get Base 64 encode string in response
                String image = parts[0].Image;
                String convertedData = EncodingUtil.base64Decode(image).toString();
                //System.debug('Chheck for Converted Data ::: ' + convertedData);
                //Create New Attachment Record on Shipment, Decode string and add to attachment 
                List<Attachment> attachments = new List<Attachment>();
                
                attachments.add(new Attachment(Body = EncodingUtil.base64Decode(image), ParentID = shipment.Id,
                                             Name = 'Shipment Label', Description = 'Shipment Label',
                                             ContentType = 'application/pdf'));
                /*attachments.add(new Attachment(Body = EncodingUtil.base64Decode(image), ParentID = shipment.Recipient__c,
                                             Name = 'Shipment Label', Description = 'Shipment Label',
                                             ContentType = 'application/pdf'));*/
               
                
                insert attachments; 
                
                //If all steps successfully executed set flag to true
                isShipmentProcessed = true;
                
                //Set Latest Attachment Id in page Parameter
                ApexPages.currentPage().getParameters().put('attachmentId',attachments[0].Id);
            }
            
            //Check if Waarning then display message on the screen
            if(processShipmentReply.HighestSeverity.equalsIgnoreCase(ShipItHelper.FED_INTEGRATION_RESPONSE_WARNING)){
                
                //Warning message will not stop the app but will be displayed on the page
                ShipItHelper.displayErrorMessages(warnMsg);    
            }
        }else{
            
            //ERROR or FAILURE message will stop the apps current functionality will be displayed on the page
            ShipItHelper.displayErrorMessages(warnMsg);
        }
        return isShipmentProcessed;
    }
}