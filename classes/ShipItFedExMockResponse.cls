/** 
  * Description     :   Mock Response class for Integration with Fed Ext WebService
  *	
  * Created By      :   Rajeev Jain(Simplyforce)
  *
  * Created Date    :   04/03/2015
  *
  * Version         :   V1.0 Created
  * 				:	V1.1 Modified By - Mahendra Swarnkar - 3/2/2016 - CR-20160104-9486 - Updated method "testRateRequestService" - Added the fifth service for Ground home delivery service
  * 
  **/
public class ShipItFedExMockResponse {
	
    //Flag to  Make Adddress validation response differemtiate 
    public static String statusRequire;
    
    //Default Success 
    public static String responseResultType = 'SUCCESS';
    
    /** Method to Return Address Validation Response **/
    public static ShipItFedExAddressValidationService.AddressValidationReply testAddressValidation(ShipItFedExAddressValidationService.WebAuthenticationDetail authenticationDetail,
                                                                                                  ShipItFedExAddressValidationService.ClientDetail clientDetail,
                                                                                                  ShipItFedExAddressValidationService.TransactionDetail transactionDetails,
                                                                                                  ShipItFedExAddressValidationService.VersionId  versionId,
                                                                                                  List<ShipItFedExAddressValidationService.AddressToValidate> addressToValidateList){
    	
        ShipItFedExAddressValidationService.AddressValidationReply reply = new ShipItFedExAddressValidationService.AddressValidationReply();
        
        List<ShipItFedExAddressValidationService.AddressValidationResult> validationResults = new List<ShipItFedExAddressValidationService.AddressValidationResult>();
        
        //Hold Notifications
        List<ShipItFedExAddressValidationService.Notification> notifications = new List<ShipItFedExAddressValidationService.Notification>();                                                                                         
        ShipItFedExAddressValidationService.Notification notification = new ShipItFedExAddressValidationService.Notification();
                                                                                                      
		ShipItFedExAddressValidationService.TransactionDetail tranDeftails = new ShipItFedExAddressValidationService.TransactionDetail();
		tranDeftails.CustomerTransactionId = transactionDetails.CustomerTransactionId;
        
		//Validation Result
		ShipItFedExAddressValidationService.AddressValidationResult result = new ShipItFedExAddressValidationService.AddressValidationResult();
        result.ClientReferenceId = transactionDetails.CustomerTransactionId;
        result.State = 'STANDARDIZED';
        result.Classification = 'BUSINESS';
        
		//Effective Address
		ShipItFedExAddressValidationService.Address effectiveAddress = new ShipItFedExAddressValidationService.Address();
        effectiveAddress = addressToValidateList[0].Address;
		
		//Result Attributes(we check only for listed attribute from response so setting only 6 attribute fro fake response)
		List<ShipItFedExAddressValidationService.AddressAttribute> attributes = new List<ShipItFedExAddressValidationService.AddressAttribute>(); 
		ShipItFedExAddressValidationService.AddressAttribute resolved = new ShipItFedExAddressValidationService.AddressAttribute();
		ShipItFedExAddressValidationService.AddressAttribute postalValidated = new ShipItFedExAddressValidationService.AddressAttribute();
		ShipItFedExAddressValidationService.AddressAttribute CityStateValidated = new ShipItFedExAddressValidationService.AddressAttribute();
		ShipItFedExAddressValidationService.AddressAttribute StreetValidated = new ShipItFedExAddressValidationService.AddressAttribute();
		ShipItFedExAddressValidationService.AddressAttribute StreetRangeValidated = new ShipItFedExAddressValidationService.AddressAttribute();
		ShipItFedExAddressValidationService.AddressAttribute InvalidSuiteNumber = new ShipItFedExAddressValidationService.AddressAttribute();
                                                                                                      
		//For Validation Status = 'No Change', All attributes should be null or set to true
		if(responseResultType == 'SUCCESS'){
            InvalidSuiteNumber.Name = 'InvalidSuiteNumber';
            InvalidSuiteNumber.value = 'false';
            reply.HighestSeverity = 'SUCCESS';
			notification.Severity = 'SUCCESS';
			notification.Source = 'WSI';
			notification.Code = '0';
            notification.Message = 'SUCCESS';
            notifications.add(notification);
            attributes.add(InvalidSuiteNumber);
        }else if(responseResultType == 'WARNING'){
        	
            InvalidSuiteNumber.Name = 'InvalidSuiteNumber';
            InvalidSuiteNumber.value = 'true';
            reply.HighestSeverity = 'WARNING';
			notification.Severity = 'WARNING';
			notification.Source = 'WSI';
			notification.Code = '0';
            notification.Message = 'Invalid Suit Number';
            notifications.add(notification);
            attributes.add(InvalidSuiteNumber);
        }                                                                                              
        if(statusRequire == 'Resolved'){
        	
            //For Resolved resolved returned with true and effective address does not match with entered address
            resolved.Name = 'Resolved';
            resolved.Value = 'true';
            InvalidSuiteNumber.Name = 'InvalidSuiteNumber';
            InvalidSuiteNumber.value = 'false';
            effectiveAddress.City = 'Modified XYZ';
            attributes.add(resolved);
            attributes.add(InvalidSuiteNumber);
            
        }else if(statusRequire == 'Warning'){
        	
            resolved.Name = 'Resolved';
            resolved.Value = 'false';
            InvalidSuiteNumber.Name = 'InvalidSuiteNumber';
            InvalidSuiteNumber.value = 'false';
            attributes.add(InvalidSuiteNumber);
            effectiveAddress.City = 'Modified XYZ';
            attributes.add(resolved);
            
            CityStateValidated.Name = 'CityStateValidated';
            CityStateValidated.Value = 'false';
            attributes.add(CityStateValidated);
            
        }else if(statusRequire == 'No Change1'){
        	
            //For 'no Change' validation status eithere Resolved attr should be balnk or true and effective address exactly same as user entered address.
            //So here we do not change address
            resolved.Name = 'Resolved';
            resolved.Value = 'true';
            InvalidSuiteNumber.Name = 'InvalidSuiteNumber';
            InvalidSuiteNumber.value = 'false';
            attributes.add(resolved);
            attributes.add(InvalidSuiteNumber);
        }
		
		result.EffectiveAddress = effectiveAddress;
        
		result.Attributes = attributes;
                                                                                                      
		//set Notifiaction in reply
		reply.Notifications = notifications;
        
		//Set Transaction Details
		reply.TransactionDetail = tranDeftails;
		
		//Add result to List
		validationResults.add(result);
		
		//Set Results
		reply.AddressResults = validationResults;
                                                                                                      
		//Coverage code of Service class
		ShipItFedExAddressValidationService.ParsedPostalCodeDetail ParsedPostalCodeDetail = new ShipItFedExAddressValidationService.ParsedPostalCodeDetail();
        String Base = ParsedPostalCodeDetail.Base;
        String AddOn = ParsedPostalCodeDetail.AddOn;
        String DeliveryPoint = ParsedPostalCodeDetail.DeliveryPoint;
        
        ShipItFedExAddressValidationService.AddressValidationRequest AddressValidationRequest = new ShipItFedExAddressValidationService.AddressValidationRequest();
        ShipItFedExAddressValidationService.WebAuthenticationDetail WebAuthenticationDetail = authenticationDetail;
        ShipItFedExAddressValidationService.ClientDetail ClientDetail1 = clientDetail;
        ShipItFedExAddressValidationService.TransactionDetail TransactionDetail = transactionDetails;
        ShipItFedExAddressValidationService.VersionId Version = versionId;
        DateTime InEffectAsOfTimestamp = DateTime.now();
        ShipItFedExAddressValidationService.AddressToValidate[] AddressesToValidate = addressToValidateList;  
		
        ShipItFedExAddressValidationService.ParsedStreetLineDetail ParsedStreetLineDetail = new ShipItFedExAddressValidationService.ParsedStreetLineDetail();                                                                                        
        String HouseNumber = ParsedStreetLineDetail.HouseNumber;
        String PreStreetType = ParsedStreetLineDetail.PreStreetType;
        String LeadingDirectional = ParsedStreetLineDetail.LeadingDirectional;
        String StreetName = ParsedStreetLineDetail.StreetName;
        String StreetSuffix = ParsedStreetLineDetail.StreetSuffix;
        String TrailingDirectional = ParsedStreetLineDetail.TrailingDirectional;
        String UnitLabel = ParsedStreetLineDetail.UnitLabel;
        String UnitNumber = ParsedStreetLineDetail.UnitNumber;
        String RuralRoute = ParsedStreetLineDetail.RuralRoute;
        String POBox = ParsedStreetLineDetail.POBox;
        String Building = ParsedStreetLineDetail.Building;
        String Organization = ParsedStreetLineDetail.Organization;   
		
		ShipItFedExAddressValidationService.Localization Localization = new ShipItFedExAddressValidationService.Localization();
		String LanguageCode = Localization.LanguageCode;
        String LocaleCode = Localization.LanguageCode;
                                                                                                      
		ShipItFedExAddressValidationService.NotificationParameter NotificationParameter = new ShipItFedExAddressValidationService.NotificationParameter();                                                                                          
		String Id = NotificationParameter.Id;
        String Value = NotificationParameter.Value;
		
		ShipItFedExAddressValidationService.ParsedPostalCodeDetail ParsedPostalCode= new ShipItFedExAddressValidationService.ParsedPostalCodeDetail();
		ShipItFedExAddressValidationService.ParsedAddressPartsDetail ParsedAddressPartsDetail = new ShipItFedExAddressValidationService.ParsedAddressPartsDetail();
		//ParsedAddressPartsDetail.ParsedStreetLineDetail = ParsedStreetLineDetail;
		//ParsedAddressPartsDetail.ParsedPostalCode = ParsedPostalCode;
                                                                                                      
        return reply;
    }
    
    /** Method to Return Rate Request Service Response **/
    public static ShipItFedExRateService.RateReply testRateRequestService(ShipItFedExRateService.WebAuthenticationDetail authenticationDetail, ShipItFedExRateService.ClientDetail clientDetail, ShipItFedExRateService.TransactionDetail transactionDetails, ShipItFedExRateService.VersionId  versionId){
    	
        ShipItFedExRateService.RateReply rateReply = new ShipItFedExRateService.RateReply();
        
        List<ShipItFedExRateService.Notification> notifications = new List<ShipItFedExRateService.Notification>();
        ShipItFedExRateService.Notification notification = new ShipItFedExRateService.Notification();
            
        ShipItFedExRateService.TransactionDetail tranDeftails = new ShipItFedExRateService.TransactionDetail();
		tranDeftails.CustomerTransactionId = transactionDetails.CustomerTransactionId;
        
        List<ShipItFedExRateService.RateReplyDetail> rateReplyDetails = new List<ShipItFedExRateService.RateReplyDetail>();
        
        //Add first Service 
        ShipItFedExRateService.RateReplyDetail replyDetail = new ShipItFedExRateService.RateReplyDetail();
        replyDetail.ServiceType = 'FIRST_OVERNIGHT';
        replyDetail.PackagingType = 'FEDEX_SMALL_BOX';
        replyDetail.DeliveryStation = 'KIPA';
        replyDetail.DeliveryDayOfWeek = 'FRI';
        replyDetail.DeliveryTimestamp = DateTime.now().addDays(1);
		        
        List<ShipItFedExRateService.RatedShipmentDetail> ratedShipmentDetails = new List<ShipItFedExRateService.RatedShipmentDetail>();
		ShipItFedExRateService.RatedShipmentDetail ratedShipmentDetail = new ShipItFedExRateService.RatedShipmentDetail();
        
        ShipItFedExRateService.ShipmentRateDetail shipmentRateDetail = new ShipItFedExRateService.ShipmentRateDetail();
        shipmentRateDetail.RateType = 'PAYOR_ACCOUNT_PACKAGE';
        shipmentRateDetail.RateScale = '6';
        shipmentRateDetail.RateZone = '02';
        shipmentRateDetail.PricingCode = 'PACKAGE';
        shipmentRateDetail.RatedWeightMethod = 'ACTUAL';
		
        ShipItFedExRateService.Money totalNetFreight = new ShipItFedExRateService.Money();
        totalNetFreight.Currency_x = 'USD';
        totalNetFreight.Amount = 80.1;
        shipmentRateDetail.TotalNetFreight = totalNetFreight;
        
        ShipItFedExRateService.Money totalSurcharges = new ShipItFedExRateService.Money();
        totalSurcharges.Currency_x = 'USD';
        totalSurcharges.Amount = 1.2;
        shipmentRateDetail.TotalSurcharges = totalSurcharges;
        
        ShipItFedExRateService.Money totalTaxes = new ShipItFedExRateService.Money();
        totalTaxes.Currency_x = 'USD';
        totalTaxes.Amount = 0.0;
        shipmentRateDetail.TotalTaxes = totalTaxes;
        
        ShipItFedExRateService.Money totalNetCharge = new ShipItFedExRateService.Money();
        totalNetCharge.Currency_x = 'USD';
        totalNetCharge.Amount = 80.3;
        shipmentRateDetail.TotalNetCharge = totalNetCharge;
        ratedShipmentDetail.ShipmentRateDetail = shipmentRateDetail;
        ratedShipmentDetails.add(ratedShipmentDetail);
        replyDetail.RatedShipmentDetails = ratedShipmentDetails;
        rateReplyDetails.add(replyDetail);
        
        //Add Second Service 
        replyDetail = new ShipItFedExRateService.RateReplyDetail();
        replyDetail.ServiceType = 'STANDARD_OVERNIGHT';
        replyDetail.PackagingType = 'FEDEX_SMALL_BOX';
        replyDetail.DeliveryStation = 'KIPA';
        replyDetail.DeliveryDayOfWeek = 'FRI';
        replyDetail.DeliveryTimestamp = DateTime.now().addDays(1);
        
        ratedShipmentDetails = new List<ShipItFedExRateService.RatedShipmentDetail>();
		ratedShipmentDetail = new ShipItFedExRateService.RatedShipmentDetail();
        
        shipmentRateDetail = new ShipItFedExRateService.ShipmentRateDetail();
        shipmentRateDetail.RateType = 'PAYOR_ACCOUNT_PACKAGE';
        shipmentRateDetail.RateScale = '1283';
        shipmentRateDetail.RateZone = '02';
        shipmentRateDetail.PricingCode = 'PACKAGE';
        shipmentRateDetail.RatedWeightMethod = 'ACTUAL';
		
        totalNetFreight = new ShipItFedExRateService.Money();
        totalNetFreight.Currency_x = 'USD';
        totalNetFreight.Amount = 46.75;
        shipmentRateDetail.TotalNetFreight = totalNetFreight;
        
        totalSurcharges = new ShipItFedExRateService.Money();
        totalSurcharges.Currency_x = 'USD';
        totalSurcharges.Amount = 0.7;
        shipmentRateDetail.TotalSurcharges = totalSurcharges;
        
        totalTaxes = new ShipItFedExRateService.Money();
        totalTaxes.Currency_x = 'USD';
        totalTaxes.Amount = 0.0;
        shipmentRateDetail.TotalTaxes = totalTaxes;
        
        totalNetCharge = new ShipItFedExRateService.Money();
        totalNetCharge.Currency_x = 'USD';
        totalNetCharge.Amount = 47.45;
        shipmentRateDetail.TotalNetCharge = totalNetCharge;
        
        ratedShipmentDetail.ShipmentRateDetail = shipmentRateDetail;
        ratedShipmentDetails.add(ratedShipmentDetail);
        replyDetail.RatedShipmentDetails = ratedShipmentDetails;
        rateReplyDetails.add(replyDetail);
        
        //Third Service
        replyDetail = new ShipItFedExRateService.RateReplyDetail();
        replyDetail.ServiceType = 'PRIORITY_OVERNIGHT';
        replyDetail.PackagingType = 'FEDEX_SMALL_BOX';
        replyDetail.DeliveryStation = 'KIPA';
        replyDetail.DeliveryDayOfWeek = 'FRI';
        replyDetail.DeliveryTimestamp = DateTime.now().addDays(1);
        
        ratedShipmentDetails = new List<ShipItFedExRateService.RatedShipmentDetail>();
		ratedShipmentDetail = new ShipItFedExRateService.RatedShipmentDetail();
        
        shipmentRateDetail = new ShipItFedExRateService.ShipmentRateDetail();
        shipmentRateDetail.RateType = 'PAYOR_ACCOUNT_PACKAGE';
        shipmentRateDetail.RateScale = '1';
        shipmentRateDetail.PricingCode = 'PACKAGE';
        shipmentRateDetail.RatedWeightMethod = 'ACTUAL';
		
        totalNetFreight = new ShipItFedExRateService.Money();
        totalNetFreight.Currency_x = 'USD';
        totalNetFreight.Amount = 61.5;
        shipmentRateDetail.TotalNetFreight = totalNetFreight;
        
        totalSurcharges = new ShipItFedExRateService.Money();
        totalSurcharges.Currency_x = 'USD';
        totalSurcharges.Amount = 0.92;
        shipmentRateDetail.TotalSurcharges = totalSurcharges;
        
        totalTaxes = new ShipItFedExRateService.Money();
        totalTaxes.Currency_x = 'USD';
        totalTaxes.Amount = 0.0;
        shipmentRateDetail.TotalTaxes = totalTaxes;
        
        totalNetCharge = new ShipItFedExRateService.Money();
        totalNetCharge.Currency_x = 'USD';
        totalNetCharge.Amount = 62.42;
        shipmentRateDetail.TotalNetCharge = totalNetCharge;
        
        ratedShipmentDetail.ShipmentRateDetail = shipmentRateDetail;
        ratedShipmentDetails.add(ratedShipmentDetail);
        replyDetail.RatedShipmentDetails = ratedShipmentDetails;
        rateReplyDetails.add(replyDetail);
        
        //Fourth Service
        replyDetail = new ShipItFedExRateService.RateReplyDetail();
        replyDetail.ServiceType = 'FEDEX_EXPRESS_SAVER';
        replyDetail.PackagingType = 'FEDEX_SMALL_BOX';
        replyDetail.DeliveryStation = 'KIPA';
        replyDetail.DeliveryDayOfWeek = 'Tue';
        replyDetail.DeliveryTimestamp = DateTime.now().addDays(1);
        
        ratedShipmentDetails = new List<ShipItFedExRateService.RatedShipmentDetail>();
		ratedShipmentDetail = new ShipItFedExRateService.RatedShipmentDetail();
        
        shipmentRateDetail = new ShipItFedExRateService.ShipmentRateDetail();
        shipmentRateDetail.RateType = 'PAYOR_ACCOUNT_PACKAGE';
        shipmentRateDetail.RateScale = '7167';
        shipmentRateDetail.PricingCode = 'PACKAGE';
        shipmentRateDetail.RatedWeightMethod = 'ACTUAL';
		
        totalNetFreight = new ShipItFedExRateService.Money();
        totalNetFreight.Currency_x = 'USD';
        totalNetFreight.Amount = 28.05;
        shipmentRateDetail.TotalNetFreight = totalNetFreight;
        
        totalSurcharges = new ShipItFedExRateService.Money();
        totalSurcharges.Currency_x = 'USD';
        totalSurcharges.Amount = 0.42;
        shipmentRateDetail.TotalSurcharges = totalSurcharges;
        
        totalTaxes = new ShipItFedExRateService.Money();
        totalTaxes.Currency_x = 'USD';
        totalTaxes.Amount = 0.0;
        shipmentRateDetail.TotalTaxes = totalTaxes;
        
        totalNetCharge = new ShipItFedExRateService.Money();
        totalNetCharge.Currency_x = 'USD';
        totalNetCharge.Amount = 28.47;
        shipmentRateDetail.TotalNetCharge = totalNetCharge;
        
        ratedShipmentDetail.ShipmentRateDetail = shipmentRateDetail;
        ratedShipmentDetails.add(ratedShipmentDetail);
        replyDetail.RatedShipmentDetails = ratedShipmentDetails;
        rateReplyDetails.add(replyDetail);
        
        // Added By Mahendra Swarnkar - 3/2/2016 - CR-20160104-9486 Starts from here
        //Fifth Service
        replyDetail = new ShipItFedExRateService.RateReplyDetail();
        replyDetail.ServiceType = 'GROUND_HOME_DELIVERY';
        replyDetail.PackagingType = 'YOUR_PACKAGING';
        replyDetail.TransitTime='FOUR_DAYS';
        
		ratedShipmentDetails = new List<ShipItFedExRateService.RatedShipmentDetail>();
		ratedShipmentDetail = new ShipItFedExRateService.RatedShipmentDetail();
        
        shipmentRateDetail = new ShipItFedExRateService.ShipmentRateDetail();
        shipmentRateDetail.RateType = 'PAYOR_ACCOUNT_PACKAGE';
        shipmentRateDetail.RatedWeightMethod = 'ACTUAL';
		
        totalNetFreight = new ShipItFedExRateService.Money();
        totalNetFreight.Currency_x = 'USD';
        totalNetFreight.Amount = 12.5;
        shipmentRateDetail.TotalNetFreight = totalNetFreight;
        
        totalSurcharges = new ShipItFedExRateService.Money();
        totalSurcharges.Currency_x = 'USD';
        totalSurcharges.Amount = 3.84;
        shipmentRateDetail.TotalSurcharges = totalSurcharges;
        
        totalTaxes = new ShipItFedExRateService.Money();
        totalTaxes.Currency_x = 'USD';
        totalTaxes.Amount = 0.0;
        shipmentRateDetail.TotalTaxes = totalTaxes;
        
        totalNetCharge = new ShipItFedExRateService.Money();
        totalNetCharge.Currency_x = 'USD';
        totalNetCharge.Amount = 16.34;
        shipmentRateDetail.TotalNetCharge = totalNetCharge;
        
        ratedShipmentDetail.ShipmentRateDetail = shipmentRateDetail;
        ratedShipmentDetails.add(ratedShipmentDetail);
        replyDetail.RatedShipmentDetails = ratedShipmentDetails;
        rateReplyDetails.add(replyDetail);
        // Added By Mahendra Swarnkar - 3/2/2016 - CR-20160104-9486 Starts from here
        
        rateReply.RateReplyDetails = rateReplyDetails;
        
        if(responseResultType == 'SUCCESS'){
			rateReply.HighestSeverity = 'SUCCESS';
			notification.Severity = 'SUCCESS';
			notification.Source = 'WSI';
			notification.Code = '0';
            notification.Message = 'SUCCESS';
            notifications.add(notification);   
        }else if(responseResultType == 'WARNING'){
        	rateReply.HighestSeverity = 'WARNING';
			notification.Severity = 'WARNING';
			notification.Source = 'WSI';
			notification.Code = '0';
            notification.Message = 'WARNING';
            notifications.add(notification);    
        }
        //set Notifiaction in reply
		rateReply.Notifications = notifications;
        
		//Set Transaction Details
		rateReply.TransactionDetail = tranDeftails;
        ShipItFedExRateService.DestinationControlDetail DestinationControlDetail = new ShipItFedExRateService.DestinationControlDetail();
		String[] StatementTypes = DestinationControlDetail.StatementTypes;
        String DestinationCountries = DestinationControlDetail.DestinationCountries;
        String EndUser = DestinationControlDetail.EndUser;
        
        ShipItFedExRateService.NotificationParameter NotificationParameter = new ShipItFedExRateService.NotificationParameter();
        String Id = NotificationParameter.id;
        String Value = NotificationParameter.Value;
        
        ShipItFedExRateService.EMailNotificationRecipient EMailNotificationRecipient = new ShipItFedExRateService.EMailNotificationRecipient();
        String EMailNotificationRecipientType = EMailNotificationRecipient.EMailNotificationRecipientType;
        String EMailAddress  = EMailNotificationRecipient.EMailAddress;
        String[] NotificationEventsRequested = EMailNotificationRecipient.NotificationEventsRequested;
        String Format = EMailNotificationRecipient.Format;
        
        ShipItFedExRateService.InternationalControlledExportDetail InternationalControlledExportDetail = new ShipItFedExRateService.InternationalControlledExportDetail();
        String Type_x = InternationalControlledExportDetail.Type_x;
        String ForeignTradeZoneCode = InternationalControlledExportDetail.ForeignTradeZoneCode;
        String EntryNumber = InternationalControlledExportDetail.EntryNumber;
        String LicenseOrPermitNumber = InternationalControlledExportDetail.LicenseOrPermitNumber;
        Date LicenseOrPermitExpirationDate = InternationalControlledExportDetail.LicenseOrPermitExpirationDate;
        
        ShipItFedExRateService.FreightSpecialServicePayment FreightSpecialServicePayment = new ShipItFedExRateService.FreightSpecialServicePayment();
        String SpecialService = FreightSpecialServicePayment.SpecialService;
        String PaymentType = FreightSpecialServicePayment.PaymentType;
        
        ShipItFedExRateService.CodAddTransportationChargesDetail CodAddTransportationChargesDetail = new ShipItFedExRateService.CodAddTransportationChargesDetail();
        String RateTypeBasis = CodAddTransportationChargesDetail.RateTypeBasis;
        String ChargeBasis = CodAddTransportationChargesDetail.ChargeBasis;
        String ChargeBasisLevel = CodAddTransportationChargesDetail.ChargeBasisLevel;
        
        ShipItFedExRateService.DocumentFormatOptionsRequested DocumentFormatOptionsRequested = new ShipItFedExRateService.DocumentFormatOptionsRequested();
        String[] Options = DocumentFormatOptionsRequested.Options;
        
        ShipItFedExRateService.FlatbedTrailerDetail FlatbedTrailerDetail = new ShipItFedExRateService.FlatbedTrailerDetail();
        String[] Options1 = FlatbedTrailerDetail.Options;
        
        ShipItFedExRateService.HazardousCommodityOptionDetail HazardousCommodityOptionDetail = new ShipItFedExRateService.HazardousCommodityOptionDetail();
        String CustomerSuppliedLabelText = HazardousCommodityOptionDetail.CustomerSuppliedLabelText;
        String LabelTextOption = HazardousCommodityOptionDetail.LabelTextOption;
        
        ShipItFedExRateService.ExpressFreightDetail ExpressFreightDetail = new ShipItFedExRateService.ExpressFreightDetail ();
        Boolean PackingListEnclosed = ExpressFreightDetail.PackingListEnclosed;
        Integer ShippersLoadAndCount = ExpressFreightDetail.ShippersLoadAndCount;
        String BookingConfirmationNumber = ExpressFreightDetail.BookingConfirmationNumber;
        Boolean ReferenceLabelRequested = ExpressFreightDetail.ReferenceLabelRequested;
        
        ShipItFedExRateService.DocTabZoneSpecification DocTabZoneSpecification = new ShipItFedExRateService.DocTabZoneSpecification();
        Integer ZoneNumber = DocTabZoneSpecification.ZoneNumber;
        String Header = DocTabZoneSpecification.Header;
        String DataField = DocTabZoneSpecification.DataField;
        String LiteralValue = DocTabZoneSpecification.LiteralValue;
        String Justification = DocTabZoneSpecification.Justification;
        
        ShipItFedExRateService.HazardousCommodityOptionDetail HazardousCommodityOptionDetail1 = new ShipItFedExRateService.HazardousCommodityOptionDetail();
        String LabelTextOption1 = HazardousCommodityOptionDetail1.LabelTextOption;
        String CustomerSuppliedLabelText1 = HazardousCommodityOptionDetail1.LabelTextOption;
        
        ShipItFedExRateService.DangerousGoodsSignatory DangerousGoodsSignatory = new ShipItFedExRateService.DangerousGoodsSignatory();
        String ContactName = DangerousGoodsSignatory.ContactName;
        String Title = DangerousGoodsSignatory.Title;
        String Place = DangerousGoodsSignatory.Place;
        
        ShipItFedExRateService.ConsolidationKey ConsolidationKey = new ShipItFedExRateService.ConsolidationKey();
        String Type_x1 = ConsolidationKey.Type_x;
        String Index1 = ConsolidationKey.Index;
        Date Date_x1 = ConsolidationKey.Date_x;
        
        ShipItFedExRateService.ServiceSubOptionDetail ServiceSubOptionDetail = new ShipItFedExRateService.ServiceSubOptionDetail();
        String FreightGuarantee = ServiceSubOptionDetail.FreightGuarantee;
        String SmartPostHubId = ServiceSubOptionDetail.SmartPostHubId;
        String SmartPostIndicia = ServiceSubOptionDetail.SmartPostIndicia;
        
        ShipItFedExRateService.UploadDocumentReferenceDetail UploadDocumentReferenceDetail = new ShipItFedExRateService.UploadDocumentReferenceDetail();
        Integer LineNumber = UploadDocumentReferenceDetail.LineNumber;
        String CustomerReference = UploadDocumentReferenceDetail.CustomerReference;
        String Description = UploadDocumentReferenceDetail.Description;
        String DocumentProducer = UploadDocumentReferenceDetail.DocumentProducer;
        String DocumentType = UploadDocumentReferenceDetail.DocumentType;
        String DocumentId = UploadDocumentReferenceDetail.DocumentId;
        Integer DocumentIdProducer = UploadDocumentReferenceDetail.LineNumber;
        
        ShipItFedExRateService.ExpressFreightDetail ExpressFreightDetail1 = new ShipItFedExRateService.ExpressFreightDetail();
        
        ShipItFedExRateService.ExpressFreightDetailContact ExpressFreightDetailContact = new ShipItFedExRateService.ExpressFreightDetailContact();
		String Name = ExpressFreightDetailContact.Name;
        String Phone = ExpressFreightDetailContact.Phone;
        
		ShipItFedExRateService.Money Money = new ShipItFedExRateService.Money(); 
        Decimal monAmount = Money.Amount;
        String xy = Money.Currency_x;
        
        ShipItFedExRateService.VariableHandlingChargeDetail VariableHandlingChargeDetail = new ShipItFedExRateService.VariableHandlingChargeDetail();
        ShipItFedExRateService.Money FixedValue = VariableHandlingChargeDetail.FixedValue;
        Decimal PercentValue = VariableHandlingChargeDetail.PercentValue;
        String RateElementBasis = VariableHandlingChargeDetail.RateElementBasis;
        String RateTypeBasis1 = VariableHandlingChargeDetail.RateTypeBasis;
        
        ShipItFedExRateService.CustomDocumentDetail CustomDocumentDetail = new ShipItFedExRateService.CustomDocumentDetail();
        ShipItFedExRateService.ShippingDocumentFormat Format1 = CustomDocumentDetail.Format;
        String LabelPrintingOrientation = CustomDocumentDetail.LabelPrintingOrientation;
        String LabelRotation = CustomDocumentDetail.LabelRotation;
        String SpecificationId = CustomDocumentDetail.SpecificationId;
        
        ShipItFedExRateService.ShippingDocumentEMailRecipient ShippingDocumentEMailRecipient = new ShipItFedExRateService.ShippingDocumentEMailRecipient();
        String RecipientType = ShippingDocumentEMailRecipient.RecipientType;
        String Address = ShippingDocumentEMailRecipient.Address;
        
        ShipItFedExRateService.DelayDetail DelayDetail = new ShipItFedExRateService.DelayDetail();
        Date Date_x = DelayDetail.Date_x;
        String DayOfWeek = DelayDetail.DayOfWeek;
        String Level = DelayDetail.Level;
        String Point = DelayDetail.Point;
        String Type_x2 = DelayDetail.Type_x;
        String Description1 = DelayDetail.Description;
        
        ShipItFedExRateService.EdtTaxDetail EdtTaxDetail = new ShipItFedExRateService.EdtTaxDetail();
        String TaxType = EdtTaxDetail.TaxType;
        Date EffectiveDate = EdtTaxDetail.EffectiveDate;
        String Name1 = EdtTaxDetail.Name;
        ShipItFedExRateService.Money TaxableValue = EdtTaxDetail.TaxableValue;
        String Description2 = EdtTaxDetail.Description;
        String Formula = EdtTaxDetail.Formula;
        ShipItFedExRateService.Money Amount = EdtTaxDetail.Amount;
        
        ShipItFedExRateService.CodDetail CodDetail = new ShipItFedExRateService.CodDetail();
        ShipItFedExRateService.Money CodCollectionAmount = CodDetail.CodCollectionAmount;
        ShipItFedExRateService.CodAddTransportationChargesDetail AddTransportationChargesDetail = CodDetail.AddTransportationChargesDetail;
        String CollectionType = CodDetail.CollectionType;
        ShipItFedExRateService.Party CodRecipient = CodDetail.CodRecipient;
        ShipItFedExRateService.ContactAndAddress FinancialInstitutionContactAndAddress = CodDetail.FinancialInstitutionContactAndAddress;
        String RemitToName = CodDetail.RemitToName;
        String ReferenceIndicator = CodDetail.ReferenceIndicator;
        ShipItFedExRateService.TrackingId ReturnTrackingId = CodDetail.ReturnTrackingId;
        
        ShipItFedExRateService.CustomerReference CustomerReference1 = new ShipItFedExRateService.CustomerReference();
        String CustomerReferenceType12 = CustomerReference1.CustomerReferenceType;
        String Value1 = CustomerReference1.Value;
        
        ShipItFedExRateService.Volume Volume = new ShipItFedExRateService.Volume();
        String Units = Volume.Units;
        Decimal Value2 = Volume.Value;
        
        ShipItFedExRateService.Tax Tax = new ShipItFedExRateService.Tax();
        String TaxType1 = Tax.TaxType;
        String Description3 = Tax.Description;
        ShipItFedExRateService.Money Amount12 = Tax.Amount;
        
        ShipItFedExRateService.HazardousCommodityDescription HazardousCommodityDescription = new ShipItFedExRateService.HazardousCommodityDescription();
        String Id123 = HazardousCommodityDescription.Id;
        Integer SequenceNumber = HazardousCommodityDescription.SequenceNumber;
        String PackingGroup = HazardousCommodityDescription.PackingGroup;
        ShipItFedExRateService.HazardousCommodityPackingDetail PackingDetails = HazardousCommodityDescription.PackingDetails;
        Boolean ReportableQuantity = HazardousCommodityDescription.ReportableQuantity;
        String ProperShippingName = HazardousCommodityDescription.ProperShippingName;
        String TechnicalName = HazardousCommodityDescription.TechnicalName;
        Decimal Percentage = HazardousCommodityDescription.Percentage;
        String HazardClass = HazardousCommodityDescription.HazardClass;
        String[] SubsidiaryClasses = HazardousCommodityDescription.SubsidiaryClasses;
        String LabelText = HazardousCommodityDescription.LabelText;
        String[] ProcessingOptions = HazardousCommodityDescription.ProcessingOptions;
        String Authorization = HazardousCommodityDescription.Authorization;
        
        ShipItFedExRateService.Localization Localization = new ShipItFedExRateService.Localization();
        String LanguageCode = Localization.LanguageCode;
        String LocaleCode = Localization.LocaleCode;
        
        ShipItFedExRateService.CustomLabelTextEntry CustomLabelTextEntry = new ShipItFedExRateService.CustomLabelTextEntry();
        ShipItFedExRateService.CustomLabelPosition Position = CustomLabelTextEntry.Position;
        String Format12 = CustomLabelTextEntry.Format;
        String[] DataFields = CustomLabelTextEntry.DataFields;
        String ThermalFontId = CustomLabelTextEntry.ThermalFontId;
        String FontName = CustomLabelTextEntry.FontName;
        Integer FontSize = CustomLabelTextEntry.FontSize;
        String Rotation = CustomLabelTextEntry.Rotation;
        
        ShipItFedExRateService.HazardousCommodityPackingDetail HazardousCommodityPackingDetail = new ShipItFedExRateService.HazardousCommodityPackingDetail();
        Boolean CargoAircraftOnly = HazardousCommodityPackingDetail.CargoAircraftOnly;
        String PackingInstructions = HazardousCommodityPackingDetail.PackingInstructions;
        
        ShipItFedExRateService.ContentRecord ContentRecord = new ShipItFedExRateService.ContentRecord();
        String PartNumber = ContentRecord.PartNumber;
        String ItemNumber = ContentRecord.ItemNumber;
        Integer ReceivedQuantity = ContentRecord.ReceivedQuantity;
        String Descriptionadws = ContentRecord.Description;
        
        ShipItFedExRateService.CommercialInvoiceDetail CommercialInvoiceDetail = new ShipItFedExRateService.CommercialInvoiceDetail ();
        ShipItFedExRateService.ShippingDocumentFormat Formatad = CommercialInvoiceDetail.Format;
        ShipItFedExRateService.CustomerImageUsage[] CustomerImageUsagesad = CommercialInvoiceDetail.CustomerImageUsages;
        
        ShipItFedExRateService.FreightGuaranteeDetail FreightGuaranteeDetail = new ShipItFedExRateService.FreightGuaranteeDetail();
        String Type_xadsf = FreightGuaranteeDetail.Type_x;
        Date Date_xs = FreightGuaranteeDetail.Date_x;
        
        ShipItFedExRateService.DangerousGoodsContainer DangerousGoodsContainer = new ShipItFedExRateService.DangerousGoodsContainer();
        String PackingType = DangerousGoodsContainer.PackingType;
        String ContainerType = DangerousGoodsContainer.ContainerType;
        String RadioactiveContainerClass = DangerousGoodsContainer.RadioactiveContainerClass;
        Integer NumberOfContainers = DangerousGoodsContainer.NumberOfContainers;
        ShipItFedExRateService.HazardousCommodityContent[] HazardousCommodities = DangerousGoodsContainer.HazardousCommodities;
        
        ShipItFedExRateService.VariableHandlingCharges VariableHandlingCharges = new ShipItFedExRateService.VariableHandlingCharges();
        ShipItFedExRateService.Money VariableHandlingCharge = VariableHandlingCharges.VariableHandlingCharge;
        ShipItFedExRateService.Money FixedVariableHandlingCharge = VariableHandlingCharges.FixedVariableHandlingCharge;
        ShipItFedExRateService.Money PercentVariableHandlingCharge = VariableHandlingCharges.PercentVariableHandlingCharge;
        ShipItFedExRateService.Money TotalCustomerCharge = VariableHandlingCharges.TotalCustomerCharge;
        
        ShipItFedExRateService.ReturnEMailDetail ReturnEMailDetail = new ShipItFedExRateService.ReturnEMailDetail();
        String MerchantPhoneNumber = ReturnEMailDetail.MerchantPhoneNumber;
        String[] AllowedSpecialServices = ReturnEMailDetail.AllowedSpecialServices;
        
        ShipItFedExRateService.PendingShipmentProcessingOptionsRequested PendingShipmentProcessingOptionsRequested = new ShipItFedExRateService.PendingShipmentProcessingOptionsRequested();
        String[] Options1234 = PendingShipmentProcessingOptionsRequested.Options;
       
        ShipItFedExRateService.Address Address123 = new ShipItFedExRateService.Address();
        String[] StreetLines = Address123.StreetLines;
        String City = Address123.City;
        String StateOrProvinceCode = Address123.StateOrProvinceCode;
        String PostalCode = Address123.PostalCode;
        String UrbanizationCode = Address123.UrbanizationCode;
        String CountryCode = Address123.CountryCode;
        String CountryName = Address123.CountryName;
        Boolean Residential = Address123.Residential;
        
        ShipItFedExRateService.TrackingId TrackingId = new ShipItFedExRateService.TrackingId();
        String TrackingIdType = TrackingId.TrackingIdType;
        String FormId = TrackingId.FormId;
        String TrackingNumber= TrackingId.TrackingNumber;
        
        ShipItFedExRateService.PackageSpecialServicesRequested PackageSpecialServicesRequested = new ShipItFedExRateService.PackageSpecialServicesRequested();
        String[] SpecialServiceTypes = PackageSpecialServicesRequested.SpecialServiceTypes;
        ShipItFedExRateService.CodDetail CodDetail13 = PackageSpecialServicesRequested.CodDetail;
        ShipItFedExRateService.DangerousGoodsDetail DangerousGoodsDetail = PackageSpecialServicesRequested.DangerousGoodsDetail;
        ShipItFedExRateService.Weight DryIceWeight = PackageSpecialServicesRequested.DryIceWeight;
        ShipItFedExRateService.SignatureOptionDetail SignatureOptionDetail = PackageSpecialServicesRequested.SignatureOptionDetail;
        ShipItFedExRateService.PriorityAlertDetail PriorityAlertDetail = PackageSpecialServicesRequested.PriorityAlertDetail;
        ShipItFedExRateService.AlcoholDetail AlcoholDetail = PackageSpecialServicesRequested.AlcoholDetail;
        
        ShipItFedExRateService.CustomDeliveryWindowDetail CustomDeliveryWindowDetail = new ShipItFedExRateService.CustomDeliveryWindowDetail();
        String Type_xadd = CustomDeliveryWindowDetail.Type_x;
        DateTime RequestTime = CustomDeliveryWindowDetail.RequestTime;
        ShipItFedExRateService.DateRange RequestRange = CustomDeliveryWindowDetail.RequestRange;
        Date RequestDate = CustomDeliveryWindowDetail.RequestDate;
        
		ShipItFedExRateService.LinearMeasure LinearMeasure = new ShipItFedExRateService.LinearMeasure();
		Decimal dedcValue = LinearMeasure.Value;
        String decUnits = LinearMeasure.Units;
        
        ShipItFedExRateService.ShippingDocumentDispositionDetail[] Dispositions = new List<ShipItFedExRateService.ShippingDocumentDispositionDetail>();
        ShipItFedExRateService.ShippingDocumentFormat DocFormat = new ShipItFedExRateService.ShippingDocumentFormat();
        
        ShipItFedExRateService.FreightAddressLabelDetail FreightAddressLabelDetail = new ShipItFedExRateService.FreightAddressLabelDetail();
        ShipItFedExRateService.ShippingDocumentFormat Format334 = FreightAddressLabelDetail.Format;
        Integer Copies = FreightAddressLabelDetail.Copies;
        String StartingPosition = FreightAddressLabelDetail.StartingPosition;
        ShipItFedExRateService.DocTabContent DocTabContent = FreightAddressLabelDetail.DocTabContent;
        String CustomContentPosition = FreightAddressLabelDetail.CustomContentPosition;
        
        ShipItFedExRateService.CustomLabelDetail CustomLabelDetail = new ShipItFedExRateService.CustomLabelDetail();
        String CoordinateUnits = CustomLabelDetail.CoordinateUnits;
        ShipItFedExRateService.CustomLabelTextEntry[] TextEntries = CustomLabelDetail.TextEntries;
        ShipItFedExRateService.CustomLabelGraphicEntry[] GraphicEntries = CustomLabelDetail.GraphicEntries;
        ShipItFedExRateService.CustomLabelBoxEntry[] BoxEntries = CustomLabelDetail.BoxEntries;
        ShipItFedExRateService.CustomLabelBarcodeEntry[] BarcodeEntries = CustomLabelDetail.BarcodeEntries;
        
        ShipItFedExRateService.Commodity Commodity = new ShipItFedExRateService.Commodity();
        String Name23 = Commodity.Name;
        Integer NumberOfPieces = Commodity.NumberOfPieces;
        String Descriptionqws = Commodity.Description;
        String CountryOfManufacture = Commodity.CountryOfManufacture;
        String HarmonizedCode = Commodity.HarmonizedCode;
        ShipItFedExRateService.Weight Weight = Commodity.Weight;
        Decimal Quantity = Commodity.Quantity;
        String QuantityUnits = Commodity.QuantityUnits;
        ShipItFedExRateService.Measure[] AdditionalMeasures = Commodity.AdditionalMeasures;
        ShipItFedExRateService.Money UnitPrice = Commodity.UnitPrice;
        ShipItFedExRateService.Money CustomsValue = Commodity.CustomsValue;
        ShipItFedExRateService.EdtExciseCondition[] ExciseConditions = Commodity.ExciseConditions;
        String ExportLicenseNumber = Commodity.ExportLicenseNumber;
        Date ExportLicenseExpirationDate = Commodity.ExportLicenseExpirationDate;
        String CIMarksAndNumbers = Commodity.CIMarksAndNumbers;
        String PartNumberad = Commodity.PartNumber;
        ShipItFedExRateService.NaftaCommodityDetail NaftaDetail= Commodity.NaftaDetail;
        
        ShipItFedExRateService.FreightRateDetail FreightRateDetail = new ShipItFedExRateService.FreightRateDetail();
        String QuoteNumber = FreightRateDetail.QuoteNumber;
        String QuoteType = FreightRateDetail.QuoteType;
        String BaseChargeCalculation = FreightRateDetail.BaseChargeCalculation;
        ShipItFedExRateService.FreightBaseCharge[] BaseCharges = FreightRateDetail.BaseCharges;
        ShipItFedExRateService.FreightRateNotation[] Notations = FreightRateDetail.Notations;
        
        ShipItFedExRateService.FreightServiceCenterDetail FreightServiceCenterDetail = new ShipItFedExRateService.FreightServiceCenterDetail();
        String InterlineCarrierCode = FreightServiceCenterDetail.InterlineCarrierCode;
        String InterlineCarrierName = FreightServiceCenterDetail.InterlineCarrierName;
        Integer AdditionalDays = FreightServiceCenterDetail.AdditionalDays;
        String LocalService = FreightServiceCenterDetail.LocalService;
        ShipItFedExRateService.Distance LocalDistance = FreightServiceCenterDetail.LocalDistance;
        String LocalDuration = FreightServiceCenterDetail.LocalDuration;
        String LocalServiceScheduling = FreightServiceCenterDetail.LocalServiceScheduling;
        String[] LimitedServiceDays = FreightServiceCenterDetail.LimitedServiceDays;
        String GatewayLocationId = FreightServiceCenterDetail.GatewayLocationId;
        String Location = FreightServiceCenterDetail.Location;
        ShipItFedExRateService.ContactAndAddress ContactAndAddress = FreightServiceCenterDetail.ContactAndAddress;
        
        ShipItFedExRateService.RatedPackageDetail RatedPackageDetail = new ShipItFedExRateService.RatedPackageDetail();
        ShipItFedExRateService.TrackingId[] TrackingIds = RatedPackageDetail.TrackingIds;
        Integer GroupNumber = RatedPackageDetail.GroupNumber;
        ShipItFedExRateService.Money EffectiveNetDiscount = RatedPackageDetail.EffectiveNetDiscount;
        ShipItFedExRateService.Money AdjustedCodCollectionAmount = RatedPackageDetail.AdjustedCodCollectionAmount;
        String OversizeClass = RatedPackageDetail.OversizeClass;
        ShipItFedExRateService.PackageRateDetail PackageRateDetail = RatedPackageDetail.PackageRateDetail;
        
        ShipItFedExRateService.FreightRateDetail FreightRateDetail1 = new ShipItFedExRateService.FreightRateDetail();
        String QuoteNumber12 = FreightRateDetail1.QuoteNumber;
        String QuoteType12 = FreightRateDetail1.QuoteType;
        String BaseChargeCalculation12 = FreightRateDetail1.BaseChargeCalculation;
        ShipItFedExRateService.FreightBaseCharge[] BaseCharges12 = FreightRateDetail1.BaseCharges;
        ShipItFedExRateService.FreightRateNotation[] Notations12 = FreightRateDetail1.Notations;
        
        ShipItFedExRateService.CustomerSpecifiedLabelDetail CustomerSpecifiedLabelDetail = new ShipItFedExRateService.CustomerSpecifiedLabelDetail();
        ShipItFedExRateService.DocTabContent DocTabContent3 = CustomerSpecifiedLabelDetail.DocTabContent;
        String CustomContentPosition24 = CustomerSpecifiedLabelDetail.CustomContentPosition;
        ShipItFedExRateService.CustomLabelDetail CustomContent = CustomerSpecifiedLabelDetail.CustomContent;
        ShipItFedExRateService.ConfigurableLabelReferenceEntry[] ConfigurableReferenceEntries = CustomerSpecifiedLabelDetail.ConfigurableReferenceEntries;
        String[] MaskedData = CustomerSpecifiedLabelDetail.MaskedData;
        String SecondaryBarcode = CustomerSpecifiedLabelDetail.SecondaryBarcode;
        ShipItFedExRateService.Localization TermsAndConditionsLocalization = CustomerSpecifiedLabelDetail.TermsAndConditionsLocalization;
        ShipItFedExRateService.RegulatoryLabelContentDetail[] RegulatoryLabels = CustomerSpecifiedLabelDetail.RegulatoryLabels;
        ShipItFedExRateService.AdditionalLabelsDetail[] AdditionalLabels = CustomerSpecifiedLabelDetail.AdditionalLabels;
        Integer AirWaybillSuppressionCount = CustomerSpecifiedLabelDetail.AirWaybillSuppressionCount;
        
        ShipItFedExRateService.ShippingDocumentDispositionDetail ShippingDocumentDispositionDetail = new ShipItFedExRateService.ShippingDocumentDispositionDetail();
        String DispositionType = ShippingDocumentDispositionDetail.DispositionType;
        String Grouping = ShippingDocumentDispositionDetail.DispositionType;
        ShipItFedExRateService.ShippingDocumentEMailDetail EMailDetail = ShippingDocumentDispositionDetail.EMailDetail;
        ShipItFedExRateService.ShippingDocumentPrintDetail PrintDetail = ShippingDocumentDispositionDetail.PrintDetail;
        
        ShipItFedExRateService.HazardousCommodityContent HazardousCommodityContent = new ShipItFedExRateService.HazardousCommodityContent();
        ShipItFedExRateService.HazardousCommodityDescription Descriptionf = HazardousCommodityContent.Description;
        ShipItFedExRateService.HazardousCommodityQuantityDetail Quantityd = HazardousCommodityContent.Quantity;
        ShipItFedExRateService.HazardousCommodityInnerReceptacleDetail[] InnerReceptaclessf = HazardousCommodityContent.InnerReceptacles;
        ShipItFedExRateService.HazardousCommodityOptionDetail Optionsadf = HazardousCommodityContent.Options;
        ShipItFedExRateService.RadionuclideDetail RadionuclideDetaildf = HazardousCommodityContent.RadionuclideDetail;
        
        ShipItFedExRateService.ShipmentLegRateDetail ShipmentLegRateDetail = new ShipItFedExRateService.ShipmentLegRateDetail();
        String LegDescription = ShipmentLegRateDetail.LegDescription;
        ShipItFedExRateService.Address LegOrigin = ShipmentLegRateDetail.LegOrigin;
        String LegOriginLocationId = ShipmentLegRateDetail.LegOriginLocationId;
        ShipItFedExRateService.Address LegDestination = ShipmentLegRateDetail.LegDestination;
        String LegDestinationLocationId = ShipmentLegRateDetail.LegDestinationLocationId;
        String RateType = ShipmentLegRateDetail.RateType;
        String RateScale = ShipmentLegRateDetail.RateScale;
        String RateZone = ShipmentLegRateDetail.RateZone;
        String PricingCode = ShipmentLegRateDetail.PricingCode;
        String RatedWeightMethod = ShipmentLegRateDetail.RatedWeightMethod;
        String MinimumChargeType = ShipmentLegRateDetail.MinimumChargeType;
        ShipItFedExRateService.CurrencyExchangeRate CurrencyExchangeRate = ShipmentLegRateDetail.CurrencyExchangeRate;
        String[] SpecialRatingApplied = ShipmentLegRateDetail.SpecialRatingApplied;
        Integer DimDivisor = ShipmentLegRateDetail.DimDivisor;
        String DimDivisorType = ShipmentLegRateDetail.DimDivisorType;
        Decimal FuelSurchargePercent = ShipmentLegRateDetail.FuelSurchargePercent;
        ShipItFedExRateService.Weight TotalBillingWeight = ShipmentLegRateDetail.TotalBillingWeight;
        ShipItFedExRateService.Weight TotalDimWeight = ShipmentLegRateDetail.TotalDimWeight;
        ShipItFedExRateService.Money TotalBaseCharge = ShipmentLegRateDetail.TotalBaseCharge;
        ShipItFedExRateService.Money TotalFreightDiscounts = ShipmentLegRateDetail.TotalFreightDiscounts;
        ShipItFedExRateService.Money TotalNetFreightad = ShipmentLegRateDetail.TotalNetFreight;
        ShipItFedExRateService.Money TotalSurchargesad = ShipmentLegRateDetail.TotalSurcharges;
        ShipItFedExRateService.Money TotalNetFedExCharges = ShipmentLegRateDetail.TotalNetFedExCharge;
        ShipItFedExRateService.Money TotalTaxesad = ShipmentLegRateDetail.TotalTaxes;
        ShipItFedExRateService.Money TotalNetChargead = ShipmentLegRateDetail.TotalNetCharge;
        ShipItFedExRateService.Money TotalRebatesd = ShipmentLegRateDetail.TotalRebates;
        ShipItFedExRateService.Money TotalDutiesAndTaxesad = ShipmentLegRateDetail.TotalDutiesAndTaxes;
        ShipItFedExRateService.Money TotalNetChargeWithDutiesAndTaxesad = ShipmentLegRateDetail.TotalNetChargeWithDutiesAndTaxes;
        ShipItFedExRateService.FreightRateDetail FreightRateDetaildss = ShipmentLegRateDetail.FreightRateDetail;
        ShipItFedExRateService.RateDiscount[] FreightDiscountsd = ShipmentLegRateDetail.FreightDiscounts;
        ShipItFedExRateService.Rebate[] Rebates = ShipmentLegRateDetail.Rebates;
        ShipItFedExRateService.Surcharge[] Surcharges = ShipmentLegRateDetail.Surcharges;
        ShipItFedExRateService.Tax[] Taxes = ShipmentLegRateDetail.Taxes;
        ShipItFedExRateService.EdtCommodityTax[] DutiesAndTaxes = ShipmentLegRateDetail.DutiesAndTaxes;
        ShipItFedExRateService.VariableHandlingCharges VariableHandlingChargesad = ShipmentLegRateDetail.VariableHandlingCharges;
        ShipItFedExRateService.VariableHandlingCharges TotalVariableHandlingChargessd = ShipmentLegRateDetail.TotalVariableHandlingCharges;
        
        ShipItFedExRateService.CommercialInvoice CommercialInvoice = new ShipItFedExRateService.CommercialInvoice();
        String[] Comments = CommercialInvoice.Comments;
        ShipItFedExRateService.Money FreightCharge = CommercialInvoice.FreightCharge;
        ShipItFedExRateService.Money TaxesOrMiscellaneousCharge = CommercialInvoice.TaxesOrMiscellaneousCharge;
        String TaxesOrMiscellaneousChargeType = CommercialInvoice.TaxesOrMiscellaneousChargeType;
        ShipItFedExRateService.Money PackingCosts = CommercialInvoice.PackingCosts;
        ShipItFedExRateService.Money HandlingCosts = CommercialInvoice.HandlingCosts;
        String SpecialInstructions = CommercialInvoice.SpecialInstructions;
        String DeclarationStatement = CommercialInvoice.DeclarationStatement;
        String PaymentTerms = CommercialInvoice.PaymentTerms;
        String Purpose = CommercialInvoice.Purpose;
        String OriginatorName = CommercialInvoice.OriginatorName;
        String TermsOfSale = CommercialInvoice.TermsOfSale;
        
        ShipItFedExRateService.ShippingDocumentSpecification ShippingDocumentSpecification = new ShipItFedExRateService.ShippingDocumentSpecification();
        String[] ShippingDocumentTypes;
        ShipItFedExRateService.CertificateOfOriginDetail CertificateOfOrigin = ShippingDocumentSpecification.CertificateOfOrigin;
        ShipItFedExRateService.CommercialInvoiceDetail CommercialInvoiceDetail23 = ShippingDocumentSpecification.CommercialInvoiceDetail;
        ShipItFedExRateService.CustomDocumentDetail[] CustomPackageDocumentDetail = ShippingDocumentSpecification.CustomPackageDocumentDetail;
        ShipItFedExRateService.CustomDocumentDetail[] CustomShipmentDocumentDetail = ShippingDocumentSpecification.CustomShipmentDocumentDetail;
        ShipItFedExRateService.ExportDeclarationDetail ExportDeclarationDetail = ShippingDocumentSpecification.ExportDeclarationDetail;
        ShipItFedExRateService.GeneralAgencyAgreementDetail GeneralAgencyAgreementDetail = ShippingDocumentSpecification.GeneralAgencyAgreementDetail;
        ShipItFedExRateService.NaftaCertificateOfOriginDetail NaftaCertificateOfOriginDetail = ShippingDocumentSpecification.NaftaCertificateOfOriginDetail;
        ShipItFedExRateService.Op900Detail Op900Detail = ShippingDocumentSpecification.Op900Detail;
        ShipItFedExRateService.DangerousGoodsShippersDeclarationDetail DangerousGoodsShippersDeclarationDetail = ShippingDocumentSpecification.DangerousGoodsShippersDeclarationDetail;
        ShipItFedExRateService.FreightAddressLabelDetail FreightAddressLabelDetail23 = ShippingDocumentSpecification.FreightAddressLabelDetail;
        ShipItFedExRateService.ReturnInstructionsDetail ReturnInstructionsDetail = ShippingDocumentSpecification.ReturnInstructionsDetail;
        
        ShipItFedExRateService.RateDiscount RateDiscount = new ShipItFedExRateService.RateDiscount();
        String RateDiscountType = RateDiscount.RateDiscountType;
        String Description35 = RateDiscount.Description;
        ShipItFedExRateService.Money Amount45 = RateDiscount.Amount;
        Decimal Percent = RateDiscount.Percent;
        
        ShipItFedExRateService.ShipmentSpecialServicesRequested ShipmentSpecialServicesRequested = new ShipItFedExRateService.ShipmentSpecialServicesRequested();
        String[] SpecialServiceTypes12 = ShipmentSpecialServicesRequested.SpecialServiceTypes;
        ShipItFedExRateService.CodDetail CodDetailfd = ShipmentSpecialServicesRequested.CodDetail;
        ShipItFedExRateService.DeliveryOnInvoiceAcceptanceDetail DeliveryOnInvoiceAcceptanceDetail = ShipmentSpecialServicesRequested.DeliveryOnInvoiceAcceptanceDetail;
        ShipItFedExRateService.HoldAtLocationDetail HoldAtLocationDetail = ShipmentSpecialServicesRequested.HoldAtLocationDetail;
        ShipItFedExRateService.EMailNotificationDetail EMailNotificationDetail = ShipmentSpecialServicesRequested.EMailNotificationDetail;
        ShipItFedExRateService.ReturnShipmentDetail ReturnShipmentDetail = ShipmentSpecialServicesRequested.ReturnShipmentDetail;
        ShipItFedExRateService.PendingShipmentDetail PendingShipmentDetail = ShipmentSpecialServicesRequested.PendingShipmentDetail;
        ShipItFedExRateService.InternationalControlledExportDetail InternationalControlledExportDetail234 = ShipmentSpecialServicesRequested.InternationalControlledExportDetail;
        ShipItFedExRateService.InternationalTrafficInArmsRegulationsDetail InternationalTrafficInArmsRegulationsDetail = ShipmentSpecialServicesRequested.InternationalTrafficInArmsRegulationsDetail;
        ShipItFedExRateService.ShipmentDryIceDetail ShipmentDryIceDetail = ShipmentSpecialServicesRequested.ShipmentDryIceDetail;
        ShipItFedExRateService.HomeDeliveryPremiumDetail HomeDeliveryPremiumDetail = ShipmentSpecialServicesRequested.HomeDeliveryPremiumDetail;
        ShipItFedExRateService.FlatbedTrailerDetail FlatbedTrailerDetailsd = ShipmentSpecialServicesRequested.FlatbedTrailerDetail;
        ShipItFedExRateService.FreightGuaranteeDetail FreightGuaranteeDetailsdf = ShipmentSpecialServicesRequested.FreightGuaranteeDetail;
        ShipItFedExRateService.EtdDetail EtdDetail = ShipmentSpecialServicesRequested.EtdDetail;
        ShipItFedExRateService.CustomDeliveryWindowDetail CustomDeliveryWindowDetailvfg = ShipmentSpecialServicesRequested.CustomDeliveryWindowDetail;
		
		ShipItFedExRateService.FreightShipmentDetail FreightShipmentDetail = new ShipItFedExRateService.FreightShipmentDetail();       
        String FedExFreightAccountNumber = FreightShipmentDetail.FedExFreightAccountNumber;
        ShipItFedExRateService.ContactAndAddress FedExFreightBillingContactAndAddress = FreightShipmentDetail.FedExFreightBillingContactAndAddress;
        ShipItFedExRateService.Party AlternateBilling = FreightShipmentDetail.AlternateBilling;
        String Role = FreightShipmentDetail.Role;
        String CollectTermsType = FreightShipmentDetail.CollectTermsType;
        ShipItFedExRateService.Money DeclaredValuePerUnit = FreightShipmentDetail.DeclaredValuePerUnit;
        String DeclaredValueUnits = FreightShipmentDetail.DeclaredValueUnits;
        ShipItFedExRateService.LiabilityCoverageDetail LiabilityCoverageDetail = FreightShipmentDetail.LiabilityCoverageDetail;
        String[] Coupons = FreightShipmentDetail.Coupons;
        Integer TotalHandlingUnits = FreightShipmentDetail.TotalHandlingUnits;
        Decimal ClientDiscountPercent = FreightShipmentDetail.ClientDiscountPercent;
        ShipItFedExRateService.Weight PalletWeight = FreightShipmentDetail.PalletWeight;
        ShipItFedExRateService.Dimensions ShipmentDimensions = FreightShipmentDetail.ShipmentDimensions;
        String Comment = FreightShipmentDetail.Comment;
        ShipItFedExRateService.FreightSpecialServicePayment[] SpecialServicePayments = FreightShipmentDetail.SpecialServicePayments;
        String HazardousMaterialsOfferor = FreightShipmentDetail.HazardousMaterialsOfferor;
        ShipItFedExRateService.FreightShipmentLineItem[] LineItems = FreightShipmentDetail.LineItems;
        
        ShipItFedExRateService.RadionuclideDetail RadionuclideDetail = new ShipItFedExRateService.RadionuclideDetail();
        String Radionuclide = RadionuclideDetail.Radionuclide;
        ShipItFedExRateService.RadionuclideActivity Activity = RadionuclideDetail.Activity;
        Boolean ExceptedPackagingIsReportableQuantity = RadionuclideDetail.ExceptedPackagingIsReportableQuantity;
        String PhysicalForm = RadionuclideDetail.PhysicalForm;
        String ChemicalForm = RadionuclideDetail.ChemicalForm;
        
        ShipItFedExRateService.ShipmentRateDetail ShipmentRateDetail1 = new ShipItFedExRateService.ShipmentRateDetail();
        String RateTypeas = ShipmentRateDetail1.RateType;
        String RateScaled = ShipmentRateDetail1.RateScale;
        String RateZoned = ShipmentRateDetail1.RateZone;
        String PricingCodead = ShipmentRateDetail1.PricingCode;
        String RatedWeightMethodad = ShipmentRateDetail1.RatedWeightMethod;
        String MinimumChargeTypead = ShipmentRateDetail1.MinimumChargeType;
        ShipItFedExRateService.CurrencyExchangeRate CurrencyExchangeRated = ShipmentRateDetail1.CurrencyExchangeRate;
        String[] SpecialRatingAppliedds = ShipmentRateDetail1.SpecialRatingApplied;
        Integer DimDivisordd = ShipmentRateDetail1.DimDivisor;
        String DimDivisorTypesc = ShipmentRateDetail1.DimDivisorType;
        Decimal FuelSurchargePercentss = ShipmentRateDetail1.FuelSurchargePercent;
        
        ShipItFedExRateService.CustomsClearanceDetail CustomsClearanceDetail = new ShipItFedExRateService.CustomsClearanceDetail();
        ShipItFedExRateService.BrokerDetail[] Brokers = CustomsClearanceDetail.Brokers;
        String ClearanceBrokerage = CustomsClearanceDetail.ClearanceBrokerage;
        ShipItFedExRateService.CustomsOptionDetail CustomsOptions = CustomsClearanceDetail.CustomsOptions;
        ShipItFedExRateService.Party ImporterOfRecord = CustomsClearanceDetail.ImporterOfRecord;
        ShipItFedExRateService.RecipientCustomsId RecipientCustomsId = CustomsClearanceDetail.RecipientCustomsId;
        ShipItFedExRateService.Payment DutiesPayment = CustomsClearanceDetail.DutiesPayment;
        String DocumentContent = CustomsClearanceDetail.DocumentContent;
        ShipItFedExRateService.Money CustomsValuead = CustomsClearanceDetail.CustomsValue;
        String FreightOnValue = CustomsClearanceDetail.FreightOnValue;
        ShipItFedExRateService.Money InsuranceCharges = CustomsClearanceDetail.InsuranceCharges;
        Boolean PartiesToTransactionAreRelated = CustomsClearanceDetail.PartiesToTransactionAreRelated;
        ShipItFedExRateService.CommercialInvoice CommercialInvoicead = CustomsClearanceDetail.CommercialInvoice;
        ShipItFedExRateService.Commodity[] Commodities = CustomsClearanceDetail.Commodities;
        ShipItFedExRateService.ExportDetail ExportDetail = CustomsClearanceDetail.ExportDetail;
        String[] RegulatoryControls;
        
       ShipItFedExRateService.HoldAtLocationDetail HoldAtLocationDetail1 = new ShipItFedExRateService.HoldAtLocationDetail();
        String PhoneNumber = HoldAtLocationDetail1.PhoneNumber;
        ShipItFedExRateService.ContactAndAddress LocationContactAndAddress = HoldAtLocationDetail1.LocationContactAndAddress;
        String LocationType = HoldAtLocationDetail1.LocationType;
        String LocationId = HoldAtLocationDetail1.LocationId;
        Integer LocationNumber = HoldAtLocationDetail1.LocationNumber;
        
        ShipItFedExRateService.FreightCommitDetail FreightCommitDetail = new ShipItFedExRateService.FreightCommitDetail();
        ShipItFedExRateService.FreightServiceCenterDetail OriginDetail = FreightCommitDetail.OriginDetail;
        ShipItFedExRateService.FreightServiceCenterDetail DestinationDetail = FreightCommitDetail.DestinationDetail;
        ShipItFedExRateService.Distance TotalDistance = FreightCommitDetail.TotalDistance;
        
        ShipItFedExRateService.CustomLabelBarcodeEntry CustomLabelBarcodeEntry = new ShipItFedExRateService.CustomLabelBarcodeEntry();
        ShipItFedExRateService.CustomLabelPosition Positionzd = CustomLabelBarcodeEntry.Position;
        String Formatadx = CustomLabelBarcodeEntry.Format;
        String[] DataFieldsad = CustomLabelBarcodeEntry.DataFields;
        Integer BarHeightaad = CustomLabelBarcodeEntry.BarHeight;
        Integer ThinBarWidtha = CustomLabelBarcodeEntry.ThinBarWidth;
        String BarcodeSymbologyx = CustomLabelBarcodeEntry.BarcodeSymbology;
        
        ShipItFedExRateService.DangerousGoodsDetail DangerousGoodsDetail1 = new ShipItFedExRateService.DangerousGoodsDetail();
        String Regulation = DangerousGoodsDetail1.Regulation;
        String Accessibility = DangerousGoodsDetail1.Accessibility;
        Boolean CargoAircraftOnlynkk = DangerousGoodsDetail1.CargoAircraftOnly;
        String[] Optionsad = DangerousGoodsDetail1.Options;
        String PackingOptionad = DangerousGoodsDetail1.PackingOption;
        String ReferenceIdad = DangerousGoodsDetail1.ReferenceId;
        ShipItFedExRateService.DangerousGoodsContainer[] Containersad = DangerousGoodsDetail1.Containers;
        ShipItFedExRateService.HazardousCommodityPackagingDetail Packagingad = DangerousGoodsDetail1.Packaging;
        ShipItFedExRateService.DangerousGoodsSignatory Signatory = DangerousGoodsDetail1.Signatory;
        String EmergencyContactNumber = DangerousGoodsDetail1.EmergencyContactNumber;
        String Offeror = DangerousGoodsDetail1.Offeror;
        ShipItFedExRateService.Contact InfectiousSubstanceResponsibleContact = DangerousGoodsDetail1.InfectiousSubstanceResponsibleContact;
        String AdditionalHandling = DangerousGoodsDetail1.AdditionalHandling;
        ShipItFedExRateService.RadioactivityDetail RadioactivityDetail = DangerousGoodsDetail1.RadioactivityDetail;
        
        ShipItFedExRateService.FreightBaseCharge FreightBaseCharge = new ShipItFedExRateService.FreightBaseCharge();
        String FreightClass = FreightBaseCharge.FreightClass;
        String RatedAsClass = FreightBaseCharge.RatedAsClass;
        String NmfcCode = FreightBaseCharge.NmfcCode;
        String Descriptionad = FreightBaseCharge.Description;
        ShipItFedExRateService.Weight Weightad = FreightBaseCharge.Weight;
        ShipItFedExRateService.Money ChargeRatead = FreightBaseCharge.ChargeRate;
        String ChargeBasisas = FreightBaseCharge.ChargeBasis;
        ShipItFedExRateService.Money ExtendedAmount = FreightBaseCharge.ExtendedAmount;
        
        ShipItFedExRateService.FreightShipmentLineItem FreightShipmentLineItem = new ShipItFedExRateService.FreightShipmentLineItem();
        String FreightClassaaf = FreightShipmentLineItem.FreightClass;
        String Packagingaded = FreightShipmentLineItem.Packaging;
        String Descriptionvr = FreightShipmentLineItem.Description;
        ShipItFedExRateService.Weight Weighthj = FreightShipmentLineItem.Weight;
        ShipItFedExRateService.Dimensions Dimensionsdh = FreightShipmentLineItem.Dimensions;
        ShipItFedExRateService.Volume Volumesfg = FreightShipmentLineItem.Volume;
        
        ShipItFedExRateService.PickupDetail PickupDetail = new ShipItFedExRateService.PickupDetail();
        DateTime ReadyDateTime = PickupDetail.ReadyDateTime; 
        DateTime LatestPickupDateTime = PickupDetail.LatestPickupDateTime; 
        String CourierInstructions = PickupDetail.CourierInstructions; 
        String RequestType = PickupDetail.RequestType; 
        String RequestSource = PickupDetail.RequestSource; 
        
        ShipItFedExRateService.RequestedPackageLineItem RequestedPackageLineItem = new ShipItFedExRateService.RequestedPackageLineItem();
        Integer SequenceNumberfdg = RequestedPackageLineItem.SequenceNumber;
        Integer GroupNumberssf = RequestedPackageLineItem.GroupNumber;
        Integer GroupPackageCountgfn = RequestedPackageLineItem.GroupPackageCount;
        ShipItFedExRateService.VariableHandlingChargeDetail VariableHandlingChargeDetailjy = RequestedPackageLineItem.VariableHandlingChargeDetail;
        ShipItFedExRateService.Money InsuredValuekj = RequestedPackageLineItem.InsuredValue;
        ShipItFedExRateService.Weight Weightlo = RequestedPackageLineItem.Weight;
        ShipItFedExRateService.Dimensions Dimensionslkj = RequestedPackageLineItem.Dimensions;
        String PhysicalPackaginglk = RequestedPackageLineItem.PhysicalPackaging;
        String ItemDescription = RequestedPackageLineItem.ItemDescription;
        String ItemDescriptionForClearance = RequestedPackageLineItem.ItemDescriptionForClearance;
        ShipItFedExRateService.CustomerReference[] CustomerReferences = RequestedPackageLineItem.CustomerReferences;
        ShipItFedExRateService.PackageSpecialServicesRequested SpecialServicesRequested = RequestedPackageLineItem.SpecialServicesRequested;
        ShipItFedExRateService.ContentRecord[] ContentRecords = RequestedPackageLineItem.ContentRecords;
        
        ShipItFedExRateService.PackageRateDetail PackageRateDetail1 = new ShipItFedExRateService.PackageRateDetail();
        String RateTypejjh = PackageRateDetail1.RateType;
        String RatedWeightMethodjn = PackageRateDetail1.RatedWeightMethod;
        String MinimumChargeTypelk = PackageRateDetail1.MinimumChargeType;
        ShipItFedExRateService.Weight BillingWeightmmn = PackageRateDetail1.BillingWeight;
        ShipItFedExRateService.Weight DimWeightkkn = PackageRateDetail1.DimWeight;
        ShipItFedExRateService.Weight OversizeWeightkm = PackageRateDetail1.OversizeWeight;
        ShipItFedExRateService.Money BaseChargekm = PackageRateDetail1.BaseCharge;
        ShipItFedExRateService.Money TotalFreightDiscountsknn = PackageRateDetail1.TotalFreightDiscounts;
        ShipItFedExRateService.Money NetFreight = PackageRateDetail1.NetFreight;
        ShipItFedExRateService.Money TotalSurchargesjh = PackageRateDetail1.TotalSurcharges;
        ShipItFedExRateService.Money NetFedExChargekknj = PackageRateDetail1.NetFedExCharge;
        ShipItFedExRateService.Money TotalTaxeslk = PackageRateDetail1.TotalTaxes;
        ShipItFedExRateService.Money NetChargelkm = PackageRateDetail1.NetCharge;
        ShipItFedExRateService.Money TotalRebateslk = PackageRateDetail1.TotalRebates;
        ShipItFedExRateService.RateDiscount[] FreightDiscountskkk = PackageRateDetail1.FreightDiscounts;
        ShipItFedExRateService.Rebate[] Rebatesj = PackageRateDetail1.Rebates;
        ShipItFedExRateService.Surcharge[] Surchargesjk = PackageRateDetail1.Surcharges;
        ShipItFedExRateService.Tax[] Taxesklj = PackageRateDetail1.Taxes;
        ShipItFedExRateService.VariableHandlingCharges VariableHandlingChargeskllj = PackageRateDetail1.VariableHandlingCharges;
        
        ShipItFedExRateService.PendingShipmentDetail PendingShipmentDetail2 = new ShipItFedExRateService.PendingShipmentDetail();
        String Type_xjjhh = PendingShipmentDetail2.Type_x;
        Date ExpirationDatenb = PendingShipmentDetail2.ExpirationDate;
        ShipItFedExRateService.EMailLabelDetail EmailLabelDetailkjj = PendingShipmentDetail2.EmailLabelDetail;
        ShipItFedExRateService.PendingShipmentProcessingOptionsRequested ProcessingOptionslkj = PendingShipmentDetail2.ProcessingOptions;
        ShipItFedExRateService.RecommendedDocumentSpecification RecommendedDocumentSpecificationko = PendingShipmentDetail2.RecommendedDocumentSpecification;
        
        ShipItFedExRateService.CommitDetail CommitDetail = new ShipItFedExRateService.CommitDetail();
        String CommodityName = CommitDetail.CommodityName;
        String ServiceType = CommitDetail.ServiceType;
        String[] AppliedOptions = CommitDetail.AppliedOptions;
        ShipItFedExRateService.ServiceSubOptionDetail AppliedSubOptions = CommitDetail.AppliedSubOptions;
        DateTime CommitTimestamp = CommitDetail.CommitTimestamp;
        String DayOfWeekjh = CommitDetail.DayOfWeek;
        String TransitTime = CommitDetail.TransitTime;
        String MaximumTransitTime = CommitDetail.MaximumTransitTime;
        String DestinationServiceArea = CommitDetail.DestinationServiceArea;
        ShipItFedExRateService.Address BrokerAddress = CommitDetail.BrokerAddress;
        String BrokerLocationId = CommitDetail.BrokerLocationId;
        DateTime BrokerCommitTimestamp = CommitDetail.BrokerCommitTimestamp;
        String BrokerCommitDayOfWeek = CommitDetail.BrokerCommitDayOfWeek;
        Integer BrokerToDestinationDays = CommitDetail.BrokerToDestinationDays;
        Date ProofOfDeliveryDate = CommitDetail.ProofOfDeliveryDate;
        String ProofOfDeliveryDayOfWeek = CommitDetail.ProofOfDeliveryDayOfWeek;
        ShipItFedExRateService.Notification[] CommitMessages = CommitDetail.CommitMessages;
        String[] DeliveryMessages = CommitDetail.DeliveryMessages;
        ShipItFedExRateService.DelayDetail[] DelayDetails = CommitDetail.DelayDetails;
        String DocumentContentmmhb = CommitDetail.DocumentContent;
        String[] RequiredDocuments = CommitDetail.RequiredDocuments;
        ShipItFedExRateService.FreightCommitDetail FreightCommitDetailhvg = CommitDetail.FreightCommitDetail;
        
        ShipItFedExRateService.RequestedShipment RequestedShipment = new ShipItFedExRateService.RequestedShipment();
        DateTime ShipTimestamp = RequestedShipment.ShipTimestamp;
        String DropoffType = RequestedShipment.DropoffType;
        String ServiceTypekjh = RequestedShipment.ServiceType;
        String PackagingTypekjh = RequestedShipment.PackagingType;
        ShipItFedExRateService.Weight TotalWeightj = RequestedShipment.TotalWeight;
        ShipItFedExRateService.Money TotalInsuredValuejkh = RequestedShipment.TotalInsuredValue;
        String PreferredCurrencyjkh = RequestedShipment.PreferredCurrency;
        ShipItFedExRateService.Party Shipperjkhg = RequestedShipment.Shipper;
        ShipItFedExRateService.Party Recipientjkh = RequestedShipment.Recipient;
        String RecipientLocationNumber = RequestedShipment.RecipientLocationNumber;
        ShipItFedExRateService.ContactAndAddress Origin = RequestedShipment.Origin;
        ShipItFedExRateService.Party SoldTo = RequestedShipment.SoldTo;
        ShipItFedExRateService.Payment ShippingChargesPayment = RequestedShipment.ShippingChargesPayment;
        ShipItFedExRateService.ShipmentSpecialServicesRequested SpecialServicesRequestedjkhg = RequestedShipment.SpecialServicesRequested;
        ShipItFedExRateService.ExpressFreightDetail ExpressFreightDetailjkh = RequestedShipment.ExpressFreightDetail;
        ShipItFedExRateService.FreightShipmentDetail FreightShipmentDetailjh = RequestedShipment.FreightShipmentDetail;
        String DeliveryInstructionsjhg = RequestedShipment.DeliveryInstructions;
        ShipItFedExRateService.VariableHandlingChargeDetail VariableHandlingChargeDetailkjh = RequestedShipment.VariableHandlingChargeDetail;
        ShipItFedExRateService.CustomsClearanceDetail CustomsClearanceDetailjkh = RequestedShipment.CustomsClearanceDetail;
        ShipItFedExRateService.PickupDetail PickupDetailjh = RequestedShipment.PickupDetail;
        ShipItFedExRateService.SmartPostShipmentDetail SmartPostDetaillklj = RequestedShipment.SmartPostDetail;
        Boolean BlockInsightVisibility = RequestedShipment.BlockInsightVisibility;
        ShipItFedExRateService.LabelSpecification LabelSpecification = RequestedShipment.LabelSpecification;
        ShipItFedExRateService.ShippingDocumentSpecification ShippingDocumentSpecificationjhg = RequestedShipment.ShippingDocumentSpecification;
        String[] RateRequestTypes = RequestedShipment.RateRequestTypes;
        String EdtRequestType = RequestedShipment.EdtRequestType;
        Integer PackageCount = RequestedShipment.PackageCount;
        String[] ShipmentOnlyFields = RequestedShipment.ShipmentOnlyFields;
        ShipItFedExRateService.ShipmentConfigurationData ConfigurationData = RequestedShipment.ConfigurationData;
        ShipItFedExRateService.RequestedPackageLineItem[] RequestedPackageLineItems = RequestedShipment.RequestedPackageLineItems;
        
        ShipItFedExRateService.Payment Payment = new ShipItFedExRateService.Payment();
		String PaymentType132 = Payment.PaymentType;
        ShipItFedExRateService.Payor Payor134 = Payment.Payor;
        
        ShipItFedExRateService.ExportDeclarationDetail ExportDeclarationDetail12 = new ShipItFedExRateService.ExportDeclarationDetail();
        ShipItFedExRateService.ShippingDocumentFormat DocumentFormat12 = ExportDeclarationDetail12.DocumentFormat;
        ShipItFedExRateService.CustomerImageUsage[] CustomerImageUsages12 = ExportDeclarationDetail12.CustomerImageUsages;
        
        ShipItFedExRateService.ShippingDocumentPrintDetail ShippingDocumentPrintDetail = new ShipItFedExRateService.ShippingDocumentPrintDetail();
        String PrinterId = ShippingDocumentPrintDetail.PrinterId;
        
        ShipItFedExRateService.CertificateOfOriginDetail CertificateOfOriginDetail = new ShipItFedExRateService.CertificateOfOriginDetail();
        ShipItFedExRateService.ShippingDocumentFormat DocumentFormat = CertificateOfOriginDetail.DocumentFormat;
        ShipItFedExRateService.CustomerImageUsage[] CustomerImageUsages = CertificateOfOriginDetail.CustomerImageUsages;
        
        ShipItFedExRateService.ShipmentConfigurationData ShipmentConfigurationData = new ShipItFedExRateService.ShipmentConfigurationData();
        ShipItFedExRateService.DangerousGoodsDetail[] DangerousGoodsPackageConfigurations = ShipmentConfigurationData.DangerousGoodsPackageConfigurations;
        
        ShipItFedExRateService.ShippingDocumentEMailDetail ShippingDocumentEMailDetail = new ShipItFedExRateService.ShippingDocumentEMailDetail();
        ShipItFedExRateService.ShippingDocumentEMailRecipient[] EMailRecipients = ShippingDocumentEMailDetail.EMailRecipients;
        String Grouping123 = ShippingDocumentEMailDetail.Grouping;
        ShipItFedExRateService.Localization Localization23 = ShippingDocumentEMailDetail.Localization;
        
        ShipItFedExRateService.Dimensions Dimensions = new ShipItFedExRateService.Dimensions();
        Integer Length = Dimensions.Length;
        Integer Width = Dimensions.Width;
        Integer Height = Dimensions.Height;
        String Units13 = Dimensions.Units;
        
        ShipItFedExRateService.EMailNotificationDetail EMailNotificationDetail232 = new ShipItFedExRateService.EMailNotificationDetail();
        String PersonalMessage = EMailNotificationDetail232.PersonalMessage;
        ShipItFedExRateService.EMailNotificationRecipient[] Recipients23 = EMailNotificationDetail232.Recipients;
        
        ShipItFedExRateService.LabelSpecification LabelSpecification1 = new ShipItFedExRateService.LabelSpecification();
        String LabelFormatType = LabelSpecification1.LabelFormatType;
        String ImageType = LabelSpecification1.ImageType;
        String LabelStockType = LabelSpecification1.LabelStockType;
        String LabelPrintingOrientation12 = LabelSpecification1.LabelPrintingOrientation;
        String LabelRotation12 = LabelSpecification1.LabelRotation;
        String LabelOrder123 = LabelSpecification1.LabelOrder;
        ShipItFedExRateService.ContactAndAddress PrintedLabelOrigin12 = LabelSpecification1.PrintedLabelOrigin;
        ShipItFedExRateService.CustomerSpecifiedLabelDetail CustomerSpecifiedDetail123 = LabelSpecification1.CustomerSpecifiedDetail;
        
        ShipItFedExRateService.ReturnShipmentDetail ReturnShipmentDetail12 = new ShipItFedExRateService.ReturnShipmentDetail();
        String ReturnType12 = ReturnShipmentDetail12.ReturnType;
        ShipItFedExRateService.Rma Rma234 = ReturnShipmentDetail12.Rma;
        ShipItFedExRateService.ReturnEMailDetail ReturnEMailDetail45 = ReturnShipmentDetail12.ReturnEMailDetail;
        ShipItFedExRateService.ReturnAssociationDetail ReturnAssociation34 = ReturnShipmentDetail12.ReturnAssociation;
        
        ShipItFedExRateService.NaftaCertificateOfOriginDetail NaftaCertificateOfOriginDetail123 = new ShipItFedExRateService.NaftaCertificateOfOriginDetail();
        ShipItFedExRateService.ShippingDocumentFormat Format34 = NaftaCertificateOfOriginDetail123.Format;
        ShipItFedExRateService.DateRange BlanketPeriod56 = NaftaCertificateOfOriginDetail123.BlanketPeriod;
        String ImporterSpecification23 = NaftaCertificateOfOriginDetail123.ImporterSpecification;
        ShipItFedExRateService.Contact SignatureContact34 = NaftaCertificateOfOriginDetail123.SignatureContact;
        String ProducerSpecification45 = NaftaCertificateOfOriginDetail123.ProducerSpecification;
        ShipItFedExRateService.NaftaProducer[] Producers78 = NaftaCertificateOfOriginDetail123.Producers;
        ShipItFedExRateService.CustomerImageUsage[] CustomerImageUsages67 = NaftaCertificateOfOriginDetail123.CustomerImageUsages;
        
        ShipItFedExRateService.InternationalTrafficInArmsRegulationsDetail InternationalTrafficInArmsRegulationsDetail23 = new ShipItFedExRateService.InternationalTrafficInArmsRegulationsDetail();
        String LicenseOrExemptionNumber34 = InternationalTrafficInArmsRegulationsDetail23.LicenseOrExemptionNumber;
        
        
        ShipItFedExRateService.AlcoholDetail AlcoholDetail45 = new ShipItFedExRateService.AlcoholDetail();
        String RecipientType56 = AlcoholDetail45.RecipientType;
        
        ShipItFedExRateService.CustomLabelGraphicEntry CustomLabelGraphicEntry = new ShipItFedExRateService.CustomLabelGraphicEntry();
        ShipItFedExRateService.CustomLabelPosition Position56 = CustomLabelGraphicEntry.Position;
        String PrinterGraphicId90 = CustomLabelGraphicEntry.PrinterGraphicId;
        String FileGraphicFullName89 = CustomLabelGraphicEntry.FileGraphicFullName;
        
        ShipItFedExRateService.Measure Measure8 = new ShipItFedExRateService.Measure();
        Decimal Quantity98 = Measure8.Quantity;
        String Units56 = Measure8.Units;
        
		ShipItFedExRateService.PriorityAlertDetail PriorityAlertDetail1 = new ShipItFedExRateService.PriorityAlertDetail();
        String[] EnhancementTypes = PriorityAlertDetail1.EnhancementTypes;
        String[] Content = PriorityAlertDetail1.Content;
        
        ShipItFedExRateService.EdtCommodityTax EdtCommodityTax = new ShipItFedExRateService.EdtCommodityTax();
        String HarmonizedCodesws = EdtCommodityTax.HarmonizedCode;
        ShipItFedExRateService.EdtTaxDetail[] Taxesbf = EdtCommodityTax.Taxes;
        
        ShipItFedExRateService.BrokerDetail BrokerDetail = new ShipItFedExRateService.BrokerDetail();
        String Type_xvvbf = BrokerDetail.Type_x;
        ShipItFedExRateService.Party Brokerlkm = BrokerDetail.Broker;
        
        ShipItFedExRateService.LiabilityCoverageDetail LiabilityCoverageDetailad = new ShipItFedExRateService.LiabilityCoverageDetail();
        String CoverageTypehh = LiabilityCoverageDetailad.CoverageType;
        ShipItFedExRateService.Money CoverageAmountlkkscsv = LiabilityCoverageDetailad.CoverageAmount;
        
        ShipItFedExRateService.HomeDeliveryPremiumDetail HomeDeliveryPremiumDetailvdf = new ShipItFedExRateService.HomeDeliveryPremiumDetail();
        String HomeDeliveryPremiumTypemlk = HomeDeliveryPremiumDetailvdf.HomeDeliveryPremiumType;
        Date Date_xok = HomeDeliveryPremiumDetailvdf.Date_x;
        String PhoneNumberkm = HomeDeliveryPremiumDetailvdf.PhoneNumber;
        
        ShipItFedExRateService.RateRequest RateRequest = new ShipItFedExRateService.RateRequest();
        ShipItFedExRateService.WebAuthenticationDetail WebAuthenticationDetail = RateRequest.WebAuthenticationDetail;
        ShipItFedExRateService.ClientDetail ClientDetailvdd = RateRequest.ClientDetail;
        ShipItFedExRateService.TransactionDetail TransactionDetailsfd = RateRequest.TransactionDetail;
        ShipItFedExRateService.VersionId Versiondvb = RateRequest.Version;
        Boolean ReturnTransitAndCommitdgf = RateRequest.ReturnTransitAndCommit;
        String[] CarrierCodeskln = RateRequest.CarrierCodes;
        String[] VariableOptionsll = RateRequest.VariableOptions;
        ShipItFedExRateService.ConsolidationKey ConsolidationKeyjkjn = RateRequest.ConsolidationKey;
        ShipItFedExRateService.RequestedShipment RequestedShipmentlkm = RateRequest.RequestedShipment;
        
        ShipItFedExRateService.AdditionalLabelsDetail AdditionalLabelsDetail = new ShipItFedExRateService.AdditionalLabelsDetail();
        String Type_xkjn = AdditionalLabelsDetail.Type_x;
        Integer Countkjn = AdditionalLabelsDetail.Count;
        
        ShipItFedExRateService.CustomLabelPosition CustomLabelPosition = new ShipItFedExRateService.CustomLabelPosition();
        Integer X = CustomLabelPosition.X;
        Integer Y = CustomLabelPosition.Y;
        
        ShipItFedExRateService.DateRange DateRange = new ShipItFedExRateService.DateRange();
        Date Begins = DateRange.Begins;
        Date Ends = DateRange.Ends;
        
        ShipItFedExRateService.FreightRateNotation FreightRateNotation = new ShipItFedExRateService.FreightRateNotation();
        String Code = FreightRateNotation.Code;
        String Descriptionjkl = FreightRateNotation.Description;
        
        ShipItFedExRateService.Distance Distance = new ShipItFedExRateService.Distance();
        Decimal Valuefhf = Distance.Value;
        String Unitslkm = Distance.Units;
		
        ShipItFedExRateService.ReturnAssociationDetail ReturnAssociationDetail = new ShipItFedExRateService.ReturnAssociationDetail();
        String TrackingNumberknlk = ReturnAssociationDetail.TrackingNumber;
        Date ShipDatepl = ReturnAssociationDetail.ShipDate;
        
        ShipItFedExRateService.ShipmentDryIceDetail ShipmentDryIceDetailssfv = new ShipItFedExRateService.ShipmentDryIceDetail();
        Integer PackageCountssdf = ShipmentDryIceDetailssfv.PackageCount;
        ShipItFedExRateService.Weight TotalWeight = ShipmentDryIceDetailssfv.TotalWeight;
        
        ShipItFedExRateService.DocTabContentZone001 DocTabContentZone001 = new ShipItFedExRateService.DocTabContentZone001();
        ShipItFedExRateService.DocTabZoneSpecification[] DocTabZoneSpecifications = DocTabContentZone001.DocTabZoneSpecifications; 
        
        ShipItFedExRateService.EMailLabelDetail EMailLabelDetail = new ShipItFedExRateService.EMailLabelDetail();
        String Message = EMailLabelDetail.Message;
        ShipItFedExRateService.EMailRecipient[] Recipients = EMailLabelDetail.Recipients;
        
        ShipItFedExRateService.RegulatoryLabelContentDetail RegulatoryLabelContentDetail = new ShipItFedExRateService.RegulatoryLabelContentDetail();
        String Type_xllk = RegulatoryLabelContentDetail.Type_x;
        String[] GenerationOptionsok = RegulatoryLabelContentDetail.GenerationOptions;
        
        ShipItFedExRateService.RecommendedDocumentSpecification RecommendedDocumentSpecification = new ShipItFedExRateService.RecommendedDocumentSpecification();
        String[] Types = RecommendedDocumentSpecification.Types;
        
        ShipItFedExRateService.HazardousCommodityPackagingDetail HazardousCommodityPackagingDetail = new ShipItFedExRateService.HazardousCommodityPackagingDetail();
        Integer Count = HazardousCommodityPackagingDetail.Count;
        String Unitskkl = HazardousCommodityPackagingDetail.Units;
        
        ShipItFedExRateService.RadionuclideActivity RadionuclideActivity = new ShipItFedExRateService.RadionuclideActivity();
        Decimal Valuddgl = RadionuclideActivity.Value;
        String UnitOfMeasurelkmkk = RadionuclideActivity.UnitOfMeasure;
        
        ShipItFedExRateService.ExportDetail ExportDetailssvdb = new ShipItFedExRateService.ExportDetail();
        String B13AFilingOption = ExportDetailssvdb.B13AFilingOption;
        String ExportComplianceStatement = ExportDetailssvdb.ExportComplianceStatement;
        String PermitNumber = ExportDetailssvdb.PermitNumber;
        ShipItFedExRateService.DestinationControlDetail DestinationControlDetailkjkn = ExportDetailssvdb.DestinationControlDetail;
        
        ShipItFedExRateService.Payor Payor = new ShipItFedExRateService.Payor();
        ShipItFedExRateService.Party ResponsibleParty = Payor.ResponsibleParty;
        
        ShipItFedExRateService.DocTabContentBarcoded DocTabContentBarcoded = new ShipItFedExRateService.DocTabContentBarcoded();
        String Symbology = DocTabContentBarcoded.Symbology;
        ShipItFedExRateService.DocTabZoneSpecification Specification = DocTabContentBarcoded.Specification;
        
        ShipItFedExRateService.ConfigurableLabelReferenceEntry ConfigurableLabelReferenceEntry = new ShipItFedExRateService.ConfigurableLabelReferenceEntry();
        Integer ZoneNumberddfv = ConfigurableLabelReferenceEntry.ZoneNumber;
        String Headervd = ConfigurableLabelReferenceEntry.Header;
        String DataFieldscds = ConfigurableLabelReferenceEntry.DataField;
        String LiteralValuesfdv = ConfigurableLabelReferenceEntry.LiteralValue;
        
        ShipItFedExRateService.SignatureOptionDetail SignatureOptionDetailxc = new ShipItFedExRateService.SignatureOptionDetail();
          String OptionTypea = SignatureOptionDetailxc.OptionType;
          String SignatureReleaseNumberssc = SignatureOptionDetailxc.SignatureReleaseNumber;
        
        ShipItFedExRateService.TaxpayerIdentification TaxpayerIdentification = new ShipItFedExRateService.TaxpayerIdentification();
        String TinType = TaxpayerIdentification.TinType;
        String Number_x = TaxpayerIdentification.Number_x;
        String Usage = TaxpayerIdentification.Usage;
        DateTime EffectiveDateqdwf = TaxpayerIdentification.EffectiveDate;
        DateTime ExpirationDate = TaxpayerIdentification.ExpirationDate;
        
        ShipItFedExRateService.UploadDocumentDetail UploadDocumentDetail = new ShipItFedExRateService.UploadDocumentDetail();
        Integer LineNumbers = UploadDocumentDetail.LineNumber;
        String CustomerReferencesvd = UploadDocumentDetail.CustomerReference;
        String DocumentProducersvd = UploadDocumentDetail.DocumentProducer;
        String DocumentTypess = UploadDocumentDetail.DocumentType;
        String FileNamesfvd = UploadDocumentDetail.FileName;
        String DocumentContentsfvd = UploadDocumentDetail.DocumentContent;
        Date ExpirationDateaaas = UploadDocumentDetail.ExpirationDate;
        
        ShipItFedExRateService.RadioactivityDetail RadioactivityDetail1 = new ShipItFedExRateService.RadioactivityDetail();
        Decimal TransportIndex = RadioactivityDetail1.TransportIndex;
        Decimal SurfaceReading = RadioactivityDetail1.SurfaceReading;
        Decimal CriticalitySafetyIndex = RadioactivityDetail1.CriticalitySafetyIndex;
        ShipItFedExRateService.Dimensions Dimensionsnmn = RadioactivityDetail1.Dimensions;
        
        ShipItFedExRateService.EMailRecipient EMailRecipient = new ShipItFedExRateService.EMailRecipient();
        String EmailAddresslk = EMailRecipient.EmailAddress;
        String Rolekllm = EMailRecipient.Role;
        ShipItFedExRateService.EmailOptionsRequested OptionsRequestedlkkm = EMailRecipient.OptionsRequested;
        ShipItFedExRateService.Localization Localizationlm = EMailRecipient.Localization;
        
        ShipItFedExRateService.CurrencyExchangeRate CurrencyExchangeRate1 = new ShipItFedExRateService.CurrencyExchangeRate();
        String FromCurrency = CurrencyExchangeRate1.FromCurrency;
        String IntoCurrency = CurrencyExchangeRate1.IntoCurrency;
        Decimal Rate = CurrencyExchangeRate1.Rate;
        
        ShipItFedExRateService.Rebate Rebate = new ShipItFedExRateService.Rebate();
        String RebateType = Rebate.RebateType;
        String Descriptionkjn = Rebate.Description;
        ShipItFedExRateService.Money Amountkjjnj = Rebate.Amount;
        Decimal Percentlkn = Rebate.Percent;
        
        ShipItFedExRateService.Surcharge Surcharge = new ShipItFedExRateService.Surcharge();
        String SurchargeType = Surcharge.SurchargeType;
        String Levellm = Surcharge.Level;
        String Descriptionlkn = Surcharge.Description;
        ShipItFedExRateService.Money Amountkjnj = Surcharge.Amount;
        
        ShipItFedExRateService.DangerousGoodsShippersDeclarationDetail DangerousGoodsShippersDeclarationDetailxs = new ShipItFedExRateService.DangerousGoodsShippersDeclarationDetail();
        ShipItFedExRateService.ShippingDocumentFormat Formatfgdb = DangerousGoodsShippersDeclarationDetailxs.Format;
        ShipItFedExRateService.CustomerImageUsage[] CustomerImageUsagessv = DangerousGoodsShippersDeclarationDetailxs.CustomerImageUsages;
        
        ShipItFedExRateService.CustomLabelBoxEntry CustomLabelBoxEntry = new ShipItFedExRateService.CustomLabelBoxEntry();
        ShipItFedExRateService.CustomLabelPosition TopLeftCorner = CustomLabelBoxEntry.TopLeftCorner;
        ShipItFedExRateService.CustomLabelPosition BottomRightCorner = CustomLabelBoxEntry.BottomRightCorner;
        
        ShipItFedExRateService.SmartPostShipmentDetail SmartPostShipmentDetail = new ShipItFedExRateService.SmartPostShipmentDetail();
        String Indicia = SmartPostShipmentDetail.Indicia;
        String AncillaryEndorsement = SmartPostShipmentDetail.AncillaryEndorsement;
        String HubId = SmartPostShipmentDetail.HubId;
        String CustomerManifestId = SmartPostShipmentDetail.CustomerManifestId;
        
        ShipItFedExRateService.NaftaProducer NaftaProducer = new ShipItFedExRateService.NaftaProducer();
        String Idnfta = NaftaProducer.Id;
        ShipItFedExRateService.Party Producerasfsd = NaftaProducer.Producer;
        
        ShipItFedExRateService.Op900Detail Op900Detailsfdg = new ShipItFedExRateService.Op900Detail();
        ShipItFedExRateService.ShippingDocumentFormat Formatllk = Op900Detailsfdg.Format;
        String Referencelk = Op900Detailsfdg.Reference;
        ShipItFedExRateService.CustomerImageUsage[] CustomerImageUsagesklj = Op900Detailsfdg.CustomerImageUsages;
        String SignatureNameklj = Op900Detailsfdg.SignatureName;
        
        ShipItFedExRateService.DeliveryOnInvoiceAcceptanceDetail DeliveryOnInvoiceAcceptanceDetailsvd = new ShipItFedExRateService.DeliveryOnInvoiceAcceptanceDetail();
        ShipItFedExRateService.Party Recipient = DeliveryOnInvoiceAcceptanceDetailsvd.Recipient;
        ShipItFedExRateService.TrackingId TrackingIdadsf = DeliveryOnInvoiceAcceptanceDetailsvd.TrackingId;
        
        
        return rateReply;
    }
    
    /** Method to Return Validate Shipment Reply **/
    public static ShipItFedExShipmentService.ShipmentReply testValidateShipmentService(ShipItFedExShipmentService.WebAuthenticationDetail authenticationDetail, ShipItFedExShipmentService.ClientDetail clientDetail, ShipItFedExShipmentService.TransactionDetail transactionDetails, ShipItFedExShipmentService.VersionId  versionId){
    	
        ShipItFedExShipmentService.ShipmentReply shipmentReply = new ShipItFedExShipmentService.ShipmentReply();
        
         //Hold Notifications
        List<ShipItFedExShipmentService.Notification> notifications = new List<ShipItFedExShipmentService.Notification>();
		ShipItFedExShipmentService.Notification notification = new ShipItFedExShipmentService.Notification();
        
        //Hold Customer Transaction Id
        ShipItFedExShipmentService.TransactionDetail tranDeftails = new ShipItFedExShipmentService.TransactionDetail();
		tranDeftails.CustomerTransactionId = transactionDetails.CustomerTransactionId;
        
        if(responseResultType == 'SUCCESS'){
            
            shipmentReply.HighestSeverity = 'SUCCESS';
			notification.Severity = 'SUCCESS';
			notification.Source = 'WSI';
			notification.Code = '0';
            notification.Message = 'SUCCESS';
            notifications.add(notification);
        }else if(responseResultType == 'WARNING'){
        	
            shipmentReply.HighestSeverity = 'WARNING';
			notification.Severity = 'WARNING';
			notification.Source = 'WSI';
			notification.Code = '0';
            notification.Message = 'Invalid Shipment';
            notifications.add(notification);
        }   
        
        shipmentReply.Notifications = notifications;
        shipmentReply.TransactionDetail = tranDeftails;
        
        return shipmentReply;
    }
    
     /** Method to Return Process Shipment Reply **/
    public static ShipItFedExShipmentService.ProcessShipmentReply testProcessShipmentService(ShipItFedExShipmentService.WebAuthenticationDetail authenticationDetail, ShipItFedExShipmentService.ClientDetail clientDetail, ShipItFedExShipmentService.TransactionDetail transactionDetails, ShipItFedExShipmentService.VersionId  versionId){
        
    	ShipItFedExShipmentService.ProcessShipmentReply processReply = new ShipItFedExShipmentService.ProcessShipmentReply();  
        processReply.JobId = '23243';
        
        ShipItFedExShipmentService.CompletedShipmentDetail completeShipmentDetail = new ShipItFedExShipmentService.CompletedShipmentDetail();
        
        completeShipmentDetail.CarrierCode = 'AX2435Z';
        
        ShipItFedExShipmentService.ShipmentOperationalDetail operationDetail = new ShipItFedExShipmentService.ShipmentOperationalDetail();
        operationDetail.DeliveryDate = Date.today().addDays(1);
        completeShipmentDetail.OperationalDetail = operationDetail;
        
        List<ShipItFedExShipmentService.CompletedPackageDetail> completedPackageDetails = new List<ShipItFedExShipmentService.CompletedPackageDetail>();
        ShipItFedExShipmentService.CompletedPackageDetail completedPackageDetail = new ShipItFedExShipmentService.CompletedPackageDetail();
        
        List<ShipItFedExShipmentService.TrackingId> trackingIds = new List<ShipItFedExShipmentService.TrackingId>();
        ShipItFedExShipmentService.TrackingId trackingId = new ShipItFedExShipmentService.TrackingId();
        trackingId.TrackingNumber = '24354';
        trackingIds.add(trackingId);
        completedPackageDetail.TrackingIds = trackingIds;
        
        ShipItFedExShipmentService.ShippingDocument label = new ShipItFedExShipmentService.ShippingDocument();
        label.ImageType = 'PDF';
        
        List<ShipItFedExShipmentService.ShippingDocumentPart> shippingDocumentParts = new List<ShipItFedExShipmentService.ShippingDocumentPart>();
        ShipItFedExShipmentService.ShippingDocumentPart part = new ShipItFedExShipmentService.ShippingDocumentPart();
        
        Blob imgStr =  Blob.valueOf('blah blah blah');
        
        //make Base 64 encodeing string
        String img = EncodingUtil.base64Encode(imgStr);
        part.DocumentPartSequenceNumber = 1;
        part.Image = img;
        shippingDocumentParts.add(part);
        label.Parts = shippingDocumentParts;
        completedPackageDetail.Label = label;
        completedPackageDetails.add(completedPackageDetail);
        completeShipmentDetail.CompletedPackageDetails = completedPackageDetails;
        processReply.CompletedShipmentDetail = completeShipmentDetail;
        
        //Hold Notifications
        List<ShipItFedExShipmentService.Notification> notifications = new List<ShipItFedExShipmentService.Notification>();
		ShipItFedExShipmentService.Notification notification = new ShipItFedExShipmentService.Notification();
        
        //Hold Customer Transaction Id
        ShipItFedExShipmentService.TransactionDetail tranDeftails = new ShipItFedExShipmentService.TransactionDetail();
		tranDeftails.CustomerTransactionId = transactionDetails.CustomerTransactionId;
        
        if(responseResultType == 'SUCCESS'){
            
            processReply.HighestSeverity = 'SUCCESS';
            notification.Severity = 'SUCCESS';
            notification.Source = 'WSI';
            notification.Code = '0';
            notification.Message = 'SUCCESS';
            notifications.add(notification);
        }else if(responseResultType == 'WARNING'){
            
            processReply.HighestSeverity = 'WARNING';
            notification.Severity = 'WARNING';
            notification.Source = 'WSI';
            notification.Code = '0';
            notification.Message = 'Invalid Suit Number';
            notifications.add(notification);
        }                                                                                              

        //set Notifiaction in reply
		processReply.Notifications = notifications;
        
		//Set Transaction Details
		processReply.TransactionDetail = tranDeftails;
        
        //========================================= Code Coverages Code ============================================
        ShipItFedExShipmentService.DestinationControlDetail destinationCD = new ShipItFedExShipmentService.DestinationControlDetail();
        
        String[] StatementTypes = destinationCD.StatementTypes;
        String DestinationCountries = destinationCD.DestinationCountries;
        String EndUser = destinationCD.EndUser;
        
        ShipItFedExShipmentService.NotificationParameter NotificationParameter = new ShipItFedExShipmentService.NotificationParameter();
        
        String id = NotificationParameter.Id;
        String Value = NotificationParameter.Value;
        
        
        ShipItFedExShipmentService.Commodity commodity = new ShipItFedExShipmentService.Commodity();
        
        String Name = commodity.Name;
        Integer NumberOfPieces = commodity.NumberOfPieces;
        String Description = commodity.Description;
        String CountryOfManufacture = commodity.CountryOfManufacture;
        String HarmonizedCode = commodity.HarmonizedCode;
        String QuantityUnits = commodity.QuantityUnits;
        String ExportLicenseNumber = commodity.ExportLicenseNumber;
        String CIMarksAndNumbers = commodity.CIMarksAndNumbers;
        String PartNumber = commodity.PartNumber;
        
        ShipItFedExShipmentService.EMailNotificationRecipient eMailNotificationRecipient = new ShipItFedExShipmentService.EMailNotificationRecipient();
        
        String EMailNotificationRecipientType = eMailNotificationRecipient.EMailNotificationRecipientType;
        String EMailAddress = eMailNotificationRecipient.EMailAddress;
        String[] NotificationEventsRequested = eMailNotificationRecipient.NotificationEventsRequested;
        String Format = eMailNotificationRecipient.Format;
        
        ShipItFedExShipmentService.InternationalControlledExportDetail internationalControlledExportDetail = new ShipItFedExShipmentService.InternationalControlledExportDetail();
        
        String Type_x = internationalControlledExportDetail.Type_x;
        String ForeignTradeZoneCode = internationalControlledExportDetail.ForeignTradeZoneCode;
        String EntryNumber = internationalControlledExportDetail.EntryNumber;
        String LicenseOrPermitNumber = internationalControlledExportDetail.LicenseOrPermitNumber;
        Date LicenseOrPermitExpirationDate = internationalControlledExportDetail.LicenseOrPermitExpirationDate;
        
        ShipItFedExShipmentService.ShippingDocument ShippingDocument = new ShipItFedExShipmentService.ShippingDocument();
        
        String Type_x1 = ShippingDocument.Type_x;
        String Grouping = ShippingDocument.Grouping;
        String ShippingDocumentDisposition = ShippingDocument.ShippingDocumentDisposition;
        String AccessReference = ShippingDocument.AccessReference;                
        String ImageType = ShippingDocument.ImageType;
        Integer Resolution = ShippingDocument.Resolution;
        Integer CopiesToPrint = ShippingDocument.CopiesToPrint;  
                      
        ShipItFedExShipmentService.FreightRateDetail freightRateDetail = new ShipItFedExShipmentService.FreightRateDetail();
        
        String QuoteNumber = freightRateDetail.QuoteNumber;
        String QuoteType = freightRateDetail.QuoteType;
        String BaseChargeCalculation = freightRateDetail.BaseChargeCalculation;
        
        ShipItFedExShipmentService.FreightSpecialServicePayment FreightSpecialServicePayment = new ShipItFedExShipmentService.FreightSpecialServicePayment();
        
        String SpecialService = FreightSpecialServicePayment.SpecialService;
        String PaymentType = FreightSpecialServicePayment.PaymentType;
        
        ShipItFedExShipmentService.CodAddTransportationChargesDetail CodAddTransportationChargesDetail = new ShipItFedExShipmentService.CodAddTransportationChargesDetail();
        
        String RateTypeBasis = CodAddTransportationChargesDetail.RateTypeBasis;
        String ChargeBasis = CodAddTransportationChargesDetail.ChargeBasis;
        String ChargeBasisLevel = CodAddTransportationChargesDetail.ChargeBasisLevel;
        
        ShipItFedExShipmentService.Payment Payment = new ShipItFedExShipmentService.Payment();
        
        String PaymentType1 = payment.PaymentType;
        
        ShipItFedExShipmentService.ProcessShipmentReply ProcessShipmentReply = new ShipItFedExShipmentService.ProcessShipmentReply();
        
        String HighestSeverity = ProcessShipmentReply.HighestSeverity;
        String JobId = ProcessShipmentReply.JobId;
        
        ShipItFedExShipmentService.DocumentFormatOptionsRequested DocumentFormatOptionsRequested = new ShipItFedExShipmentService.DocumentFormatOptionsRequested();
        
        String[] HighestSeverity1 = DocumentFormatOptionsRequested.Options;
        
        
        ShipItFedExShipmentService.TransactionDetail TransactionDetail = new ShipItFedExShipmentService.TransactionDetail();
        
        String HighestSeverity2 = TransactionDetail.CustomerTransactionId;
        
        ShipItFedExShipmentService.Weight Weight = new ShipItFedExShipmentService.Weight();
        
        String Units = Weight.Units;
        Decimal Value1 = Weight.Value;
        
        ShipItFedExShipmentService.CustomerSpecifiedLabelDetail CustomerSpecifiedLabelDetail = new ShipItFedExShipmentService.CustomerSpecifiedLabelDetail();
        
        String CustomContentPosition = CustomerSpecifiedLabelDetail.CustomContentPosition;
        String[] MaskedData = CustomerSpecifiedLabelDetail.MaskedData;
        String SecondaryBarcode12 = CustomerSpecifiedLabelDetail.SecondaryBarcode;
        Integer AirWaybillSuppressionCount = CustomerSpecifiedLabelDetail.AirWaybillSuppressionCount;
        
        ShipItFedExShipmentService.ShippingDocumentDispositionDetail ShippingDocumentDispositionDetail = new ShipItFedExShipmentService.ShippingDocumentDispositionDetail();
        
        String DispositionType = ShippingDocumentDispositionDetail.DispositionType;
        String Grouping1 = ShippingDocumentDispositionDetail.Grouping;
        
        
        ShipItFedExShipmentService.ShippingDocumentPrintDetail ShippingDocumentPrintDetail = new ShipItFedExShipmentService.ShippingDocumentPrintDetail();
        
        String PrinterId = ShippingDocumentPrintDetail.PrinterId;
        
        ShipItFedExShipmentService.CompletedEtdDetail CompletedEtdDetail = new ShipItFedExShipmentService.CompletedEtdDetail();
        
        String FolderId = CompletedEtdDetail.FolderId;
        
        ShipItFedExShipmentService.Party Party = new ShipItFedExShipmentService.Party();
        
        String AccountNumber = Party.AccountNumber;
        
        ShipItFedExShipmentService.DocTabZoneSpecification DocTabZoneSpecification = new ShipItFedExShipmentService.DocTabZoneSpecification();
        
        String Header = DocTabZoneSpecification.Header;
        Integer ZoneNumber = DocTabZoneSpecification.ZoneNumber;
        String DataField = DocTabZoneSpecification.DataField;
        String LiteralValue = DocTabZoneSpecification.LiteralValue;
        String Justification = DocTabZoneSpecification.Justification;

        
        ShipItFedExShipmentService.CommercialInvoice CommercialInvoice = new ShipItFedExShipmentService.CommercialInvoice();
        
        String[] Comments = CommercialInvoice.Comments;
        String TaxesOrMiscellaneousChargeType = CommercialInvoice.TaxesOrMiscellaneousChargeType;
        String SpecialInstructions = CommercialInvoice.SpecialInstructions;
        String DeclarationStatement = CommercialInvoice.DeclarationStatement;
        String PaymentTerms = CommercialInvoice.PaymentTerms;
        String Purpose = CommercialInvoice.Purpose;
        String OriginatorName = CommercialInvoice.OriginatorName;
        String TermsOfSale = CommercialInvoice.TermsOfSale;
        
        ShipItFedExShipmentService.ShippingDocumentPart ShippingDocumentPart = new ShipItFedExShipmentService.ShippingDocumentPart();
        
        Integer DocumentPartSequenceNumber = ShippingDocumentPart.DocumentPartSequenceNumber;
        String Image = ShippingDocumentPart.Image;
        
        ShipItFedExShipmentService.CustomsDeclarationStatementDetail CustomsDeclarationStatementDetail = new ShipItFedExShipmentService.CustomsDeclarationStatementDetail();
        
        String[] Types = CustomsDeclarationStatementDetail.Types;
        
        ShipItFedExShipmentService.CustomLabelDetail CustomLabelDetail = new ShipItFedExShipmentService.CustomLabelDetail();
        String CoordinateUnits = CustomLabelDetail.CoordinateUnits;
        ShipItFedExShipmentService.CustomLabelTextEntry[] TextEntries = CustomLabelDetail.TextEntries;
        ShipItFedExShipmentService.CustomLabelGraphicEntry[] GraphicEntries = CustomLabelDetail.GraphicEntries;
        ShipItFedExShipmentService.CustomLabelBoxEntry[] BoxEntries = CustomLabelDetail.BoxEntries;
        ShipItFedExShipmentService.CustomLabelBarcodeEntry[] BarcodeEntries = CustomLabelDetail.BarcodeEntries;
        
        ShipItFedExShipmentService.DeleteTagRequest DeleteTagRequest = new ShipItFedExShipmentService.DeleteTagRequest();
        ShipItFedExShipmentService.WebAuthenticationDetail WebAuthenticationDetail = DeleteTagRequest.WebAuthenticationDetail;
        ShipItFedExShipmentService.ClientDetail ClientDetail1 = DeleteTagRequest.clientDetail;
        ShipItFedExShipmentService.TransactionDetail TransactionDetail1 = DeleteTagRequest.TransactionDetail;
        ShipItFedExShipmentService.VersionId Version1 = DeleteTagRequest.Version;
        String DispatchLocationId = DeleteTagRequest.DispatchLocationId;
        Date DispatchDate = DeleteTagRequest.DispatchDate;
        ShipItFedExShipmentService.Payment Payment123 = DeleteTagRequest.Payment;
        String ConfirmationNumber = DeleteTagRequest.ConfirmationNumber;
        
        ShipItFedExShipmentService.CustomerSpecifiedLabelDetail CustomerSpecifiedLabelDetail12  = new ShipItFedExShipmentService.CustomerSpecifiedLabelDetail();
        ShipItFedExShipmentService.DocTabContent DocTabContent12 = CustomerSpecifiedLabelDetail12.DocTabContent;
        String CustomContentPosition12 = CustomerSpecifiedLabelDetail12.CustomContentPosition;
        ShipItFedExShipmentService.CustomLabelDetail CustomContent12 = CustomerSpecifiedLabelDetail12.CustomContent;
        ShipItFedExShipmentService.ConfigurableLabelReferenceEntry[] ConfigurableReferenceEntries12 = CustomerSpecifiedLabelDetail12.ConfigurableReferenceEntries;
        String[] MaskedData12 = CustomerSpecifiedLabelDetail12.MaskedData;
        String SecondaryBarcode = CustomerSpecifiedLabelDetail12.SecondaryBarcode;
        ShipItFedExShipmentService.Localization TermsAndConditionsLocalization = CustomerSpecifiedLabelDetail12.TermsAndConditionsLocalization;
        ShipItFedExShipmentService.RegulatoryLabelContentDetail[] RegulatoryLabels = CustomerSpecifiedLabelDetail12.RegulatoryLabels;
        ShipItFedExShipmentService.AdditionalLabelsDetail[] AdditionalLabels = CustomerSpecifiedLabelDetail12.AdditionalLabels;
        Integer AirWaybillSuppressionCountad = CustomerSpecifiedLabelDetail12.AirWaybillSuppressionCount;
        
        ShipItFedExShipmentService.HazardousCommodityContent HazardousCommodityContent = new ShipItFedExShipmentService.HazardousCommodityContent();
        ShipItFedExShipmentService.HazardousCommodityDescription Descriptionxscsd = HazardousCommodityContent.Description;
        ShipItFedExShipmentService.HazardousCommodityQuantityDetail Quantitya = HazardousCommodityContent.Quantity;
        ShipItFedExShipmentService.HazardousCommodityInnerReceptacleDetail[] InnerReceptacles = HazardousCommodityContent.InnerReceptacles;
        ShipItFedExShipmentService.HazardousCommodityOptionDetail Optionsasds = HazardousCommodityContent.Options;
        ShipItFedExShipmentService.RadionuclideDetail RadionuclideDetail = HazardousCommodityContent.RadionuclideDetail;
        
        ShipItFedExShipmentService.ShipmentLegRateDetail ShipmentLegRateDetail = new ShipItFedExShipmentService.ShipmentLegRateDetail();
        String LegDescription = ShipmentLegRateDetail.LegDescription;
        ShipItFedExShipmentService.Address LegOrigin = ShipmentLegRateDetail.LegOrigin;
        String LegOriginLocationId = ShipmentLegRateDetail.LegOriginLocationId;
        ShipItFedExShipmentService.Address LegDestination = ShipmentLegRateDetail.LegDestination;
        String LegDestinationLocationId = ShipmentLegRateDetail.LegDestinationLocationId;
        String RateType = ShipmentLegRateDetail.RateType;
        String RateScale = ShipmentLegRateDetail.RateScale;
        String RateZone = ShipmentLegRateDetail.RateZone;
        String PricingCode = ShipmentLegRateDetail.PricingCode;
        String RatedWeightMethod = ShipmentLegRateDetail.RatedWeightMethod;
        String MinimumChargeType = ShipmentLegRateDetail.MinimumChargeType;
        ShipItFedExShipmentService.CurrencyExchangeRate CurrencyExchangeRate = ShipmentLegRateDetail.CurrencyExchangeRate;
        String[] SpecialRatingApplied = ShipmentLegRateDetail.SpecialRatingApplied;
        Integer DimDivisor = ShipmentLegRateDetail.DimDivisor;
        String DimDivisorType = ShipmentLegRateDetail.DimDivisorType;
        Decimal FuelSurchargePercent = ShipmentLegRateDetail.FuelSurchargePercent;
        ShipItFedExShipmentService.Weight TotalBillingWeight = ShipmentLegRateDetail.TotalBillingWeight;
        ShipItFedExShipmentService.Weight TotalDimWeight = ShipmentLegRateDetail.TotalDimWeight;
        ShipItFedExShipmentService.Money TotalBaseCharge = ShipmentLegRateDetail.TotalBaseCharge;
        ShipItFedExShipmentService.Money TotalFreightDiscounts = ShipmentLegRateDetail.TotalFreightDiscounts;
        ShipItFedExShipmentService.Money TotalNetFreight = ShipmentLegRateDetail.TotalNetFreight;
        ShipItFedExShipmentService.Money TotalSurcharges = ShipmentLegRateDetail.TotalSurcharges;
        ShipItFedExShipmentService.Money TotalNetFedExCharge = ShipmentLegRateDetail.TotalNetFedExCharge;
        ShipItFedExShipmentService.Money TotalTaxes = ShipmentLegRateDetail.TotalTaxes;
        ShipItFedExShipmentService.Money TotalNetCharge = ShipmentLegRateDetail.TotalNetCharge;
        ShipItFedExShipmentService.Money TotalRebates = ShipmentLegRateDetail.TotalRebates;
        ShipItFedExShipmentService.Money TotalDutiesAndTaxes = ShipmentLegRateDetail.TotalDutiesAndTaxes;
        ShipItFedExShipmentService.Money TotalNetChargeWithDutiesAndTaxes = ShipmentLegRateDetail.TotalNetChargeWithDutiesAndTaxes;
        ShipItFedExShipmentService.FreightRateDetail FreightRateDetailzc = ShipmentLegRateDetail.FreightRateDetail;
        ShipItFedExShipmentService.RateDiscount[] FreightDiscounts = ShipmentLegRateDetail.FreightDiscounts;
        ShipItFedExShipmentService.Rebate[] Rebates = ShipmentLegRateDetail.Rebates;
        ShipItFedExShipmentService.Tax[] Taxes = ShipmentLegRateDetail.Taxes;
        ShipItFedExShipmentService.EdtCommodityTax[] DutiesAndTaxes = ShipmentLegRateDetail.DutiesAndTaxes;
        ShipItFedExShipmentService.VariableHandlingCharges VariableHandlingCharges = ShipmentLegRateDetail.VariableHandlingCharges;
        ShipItFedExShipmentService.VariableHandlingCharges TotalVariableHandlingCharges = ShipmentLegRateDetail.TotalVariableHandlingCharges;
			
		ShipItFedExShipmentService.ExpressFreightDetail ExpressFreightDetail = new ShipItFedExShipmentService.ExpressFreightDetail();
        Boolean PackingListEnclosed = ExpressFreightDetail.PackingListEnclosed;
        Integer ShippersLoadAndCount = ExpressFreightDetail.ShippersLoadAndCount;
        String BookingConfirmationNumber = ExpressFreightDetail.BookingConfirmationNumber;
        
        ShipItFedExShipmentService.UploadDocumentReferenceDetail UploadDocumentReferenceDetail = new ShipItFedExShipmentService.UploadDocumentReferenceDetail();
        Integer LineNumber = UploadDocumentReferenceDetail.LineNumber;
        String CustomerReference = UploadDocumentReferenceDetail.CustomerReference;
        String Descriptionad = UploadDocumentReferenceDetail.Description;
        String DocumentProducer = UploadDocumentReferenceDetail.DocumentProducer;
        String DocumentType = UploadDocumentReferenceDetail.DocumentType;
        String DocumentId = UploadDocumentReferenceDetail.DocumentId;
        String DocumentIdProducer = UploadDocumentReferenceDetail.DocumentIdProducer;
        
        ShipItFedExShipmentService.ShippingDocumentSpecification ShippingDocumentSpecification = new ShipItFedExShipmentService.ShippingDocumentSpecification();
        String[] ShippingDocumentTypes = ShippingDocumentSpecification.ShippingDocumentTypes;
        ShipItFedExShipmentService.CertificateOfOriginDetail CertificateOfOrigin = ShippingDocumentSpecification.CertificateOfOrigin;
        ShipItFedExShipmentService.CommercialInvoiceDetail CommercialInvoiceDetail = ShippingDocumentSpecification.CommercialInvoiceDetail;
        ShipItFedExShipmentService.CustomDocumentDetail[] CustomPackageDocumentDetail = ShippingDocumentSpecification.CustomPackageDocumentDetail;
        ShipItFedExShipmentService.CustomDocumentDetail[] CustomShipmentDocumentDetail = ShippingDocumentSpecification.CustomShipmentDocumentDetail;
        ShipItFedExShipmentService.ExportDeclarationDetail ExportDeclarationDetail = ShippingDocumentSpecification.ExportDeclarationDetail;
        ShipItFedExShipmentService.GeneralAgencyAgreementDetail GeneralAgencyAgreementDetail = ShippingDocumentSpecification.GeneralAgencyAgreementDetail;
        ShipItFedExShipmentService.NaftaCertificateOfOriginDetail NaftaCertificateOfOriginDetail = ShippingDocumentSpecification.NaftaCertificateOfOriginDetail;
        ShipItFedExShipmentService.Op900Detail Op900Detail = ShippingDocumentSpecification.Op900Detail;
        ShipItFedExShipmentService.DangerousGoodsShippersDeclarationDetail DangerousGoodsShippersDeclarationDetail = ShippingDocumentSpecification.DangerousGoodsShippersDeclarationDetail;
        ShipItFedExShipmentService.FreightAddressLabelDetail FreightAddressLabelDetail = ShippingDocumentSpecification.FreightAddressLabelDetail;
        ShipItFedExShipmentService.ReturnInstructionsDetail ReturnInstructionsDetail = ShippingDocumentSpecification.ReturnInstructionsDetail;
        
        ShipItFedExShipmentService.NaftaCertificateOfOriginDetail NaftaCertificateOfOriginDetailcsd = new ShipItFedExShipmentService.NaftaCertificateOfOriginDetail();
        ShipItFedExShipmentService.ShippingDocumentFormat Formatsdv = NaftaCertificateOfOriginDetailcsd.Format;
        ShipItFedExShipmentService.DateRange BlanketPeriod = NaftaCertificateOfOriginDetailcsd.BlanketPeriod;
        String ImporterSpecification = NaftaCertificateOfOriginDetailcsd.ImporterSpecification;
        ShipItFedExShipmentService.Contact SignatureContact = NaftaCertificateOfOriginDetailcsd.SignatureContact;
        String ProducerSpecification = NaftaCertificateOfOriginDetailcsd.ProducerSpecification;
        ShipItFedExShipmentService.NaftaProducer[] Producers = NaftaCertificateOfOriginDetailcsd.Producers;
        ShipItFedExShipmentService.CustomerImageUsage[] CustomerImageUsages = NaftaCertificateOfOriginDetailcsd.CustomerImageUsages;
        
        ShipItFedExShipmentService.VariableHandlingChargeDetail VariableHandlingChargeDetail = new ShipItFedExShipmentService.VariableHandlingChargeDetail();
        ShipItFedExShipmentService.Money FixedValue = VariableHandlingChargeDetail.FixedValue;
        Decimal PercentValue = VariableHandlingChargeDetail.PercentValue;
        String RateElementBasis = VariableHandlingChargeDetail.RateElementBasis;
        String RateTypeBasisaad = VariableHandlingChargeDetail.RateTypeBasis;
        
        ShipItFedExShipmentService.CustomDocumentDetail CustomDocumentDetail  = new ShipItFedExShipmentService.CustomDocumentDetail();
        ShipItFedExShipmentService.ShippingDocumentFormat Formatcbf = CustomDocumentDetail.Format;
        String LabelPrintingOrientation = CustomDocumentDetail.LabelPrintingOrientation;
        String LabelRotation = CustomDocumentDetail.LabelRotation;
        String SpecificationId = CustomDocumentDetail.SpecificationId;
        String CustomDocumentIdentifier = CustomDocumentDetail.CustomDocumentIdentifier;
        ShipItFedExShipmentService.DocTabContent DocTabContent = CustomDocumentDetail.DocTabContent;
        
        ShipItFedExShipmentService.EdtTaxDetail EdtTaxDetail = new ShipItFedExShipmentService.EdtTaxDetail();
        String TaxType = EdtTaxDetail.TaxType;
        Date EffectiveDate = EdtTaxDetail.EffectiveDate;
        String Namescs = EdtTaxDetail.Name;
        ShipItFedExShipmentService.Money TaxableValue = EdtTaxDetail.TaxableValue;
        String Descriptionkjh = EdtTaxDetail.Description;
        String Formula = EdtTaxDetail.Formula;
        ShipItFedExShipmentService.Money Amount = EdtTaxDetail.Amount;
        
        ShipItFedExShipmentService.ProcessShipmentRequest ProcessShipmentRequest = new ShipItFedExShipmentService.ProcessShipmentRequest();
        ShipItFedExShipmentService.WebAuthenticationDetail WebAuthenticationDetailsds = ProcessShipmentRequest.WebAuthenticationDetail;
        ShipItFedExShipmentService.ClientDetail ClientDetailad = ProcessShipmentRequest.ClientDetail;
        ShipItFedExShipmentService.TransactionDetail TransactionDetailad = ProcessShipmentRequest.TransactionDetail;
        ShipItFedExShipmentService.VersionId Versionaac = ProcessShipmentRequest.Version;
        ShipItFedExShipmentService.RequestedShipment RequestedShipmentads = ProcessShipmentRequest.RequestedShipment;
        
        ShipItFedExShipmentService.CodDetail CodDetailacs = new ShipItFedExShipmentService.CodDetail();
        ShipItFedExShipmentService.Money CodCollectionAmount = CodDetailacs.CodCollectionAmount;
        ShipItFedExShipmentService.CodAddTransportationChargesDetail AddTransportationChargesDetail = CodDetailacs.AddTransportationChargesDetail;
        String CollectionType = CodDetailacs.CollectionType;
        
        ShipItFedExShipmentService.Party CodRecipient = CodDetailacs.CodRecipient;
        ShipItFedExShipmentService.ContactAndAddress FinancialInstitutionContactAndAddress = CodDetailacs.FinancialInstitutionContactAndAddress;
        String RemitToName = CodDetailacs.RemitToName;
        String ReferenceIndicator = CodDetailacs.ReferenceIndicator;
        ShipItFedExShipmentService.TrackingId ReturnTrackingId = CodDetailacs.ReturnTrackingId;
        
        ShipItFedExShipmentService.GeneralAgencyAgreementDetail GeneralAgencyAgreementDetail123 = new ShipItFedExShipmentService.GeneralAgencyAgreementDetail();
        ShipItFedExShipmentService.ShippingDocumentFormat Formatlknj = GeneralAgencyAgreementDetail123.Format;
        
        ShipItFedExShipmentService.PackageBarcodes PackageBarcodes = new ShipItFedExShipmentService.PackageBarcodes();
        ShipItFedExShipmentService.BinaryBarcode[] BinaryBarcodes = PackageBarcodes.BinaryBarcodes;
        ShipItFedExShipmentService.StringBarcode[] StringBarcodes = PackageBarcodes.StringBarcodes;
        
        ShipItFedExShipmentService.CompletedCodDetail CompletedCodDetail = new ShipItFedExShipmentService.CompletedCodDetail();
        ShipItFedExShipmentService.Money CollectionAmount = CompletedCodDetail.CollectionAmount;
        String AdjustmentType = CompletedCodDetail.AdjustmentType;
        
        ShipItFedExShipmentService.ExportDeclarationDetail ExportDeclarationDetailds =new ShipItFedExShipmentService.ExportDeclarationDetail();
        ShipItFedExShipmentService.ShippingDocumentFormat DocumentFormat = ExportDeclarationDetailds.DocumentFormat;
        ShipItFedExShipmentService.CustomerImageUsage[] CustomerImageUsagesadfs = ExportDeclarationDetailds.CustomerImageUsages;
        
		ShipItFedExShipmentService.ProcessTagRequest  ProcessTagRequest = new ShipItFedExShipmentService.ProcessTagRequest();
        ShipItFedExShipmentService.WebAuthenticationDetail WebAuthenticationDetailad = ProcessTagRequest.WebAuthenticationDetail;
        ShipItFedExShipmentService.ClientDetail ClientDetailadss = ProcessTagRequest.ClientDetail;
        ShipItFedExShipmentService.TransactionDetail TransactionDetailxxg = ProcessTagRequest.TransactionDetail;
        ShipItFedExShipmentService.VersionId Versionsf = ProcessTagRequest.Version;
        ShipItFedExShipmentService.RequestedShipment RequestedShipmentzzsf = ProcessTagRequest.RequestedShipment;
        
        ShipItFedExShipmentService.PackageOperationalDetail PackageOperationalDetail = new ShipItFedExShipmentService.PackageOperationalDetail();
        String AstraHandlingText = PackageOperationalDetail.AstraHandlingText;
        ShipItFedExShipmentService.OperationalInstruction[] OperationalInstructions = PackageOperationalDetail.OperationalInstructions;
        ShipItFedExShipmentService.PackageBarcodes Barcodes = PackageOperationalDetail.Barcodes;
        String GroundServiceCode = PackageOperationalDetail.GroundServiceCode;
        
        ShipItFedExShipmentService.ShipmentRating ShipmentRating = new ShipItFedExShipmentService.ShipmentRating();
        String ActualRateType = ShipmentRating.ActualRateType;
        ShipItFedExShipmentService.Money EffectiveNetDiscount = ShipmentRating.EffectiveNetDiscount;
        ShipItFedExShipmentService.ShipmentRateDetail[] ShipmentRateDetails= ShipmentRating.ShipmentRateDetails;
        
        ShipItFedExShipmentService.ShippingDocumentFormat ShippingDocumentFormat = new ShipItFedExShipmentService.ShippingDocumentFormat();
        ShipItFedExShipmentService.ShippingDocumentDispositionDetail[] Dispositions = ShippingDocumentFormat.Dispositions;
        ShipItFedExShipmentService.LinearMeasure TopOfPageOffset = ShippingDocumentFormat.TopOfPageOffset;
        String ImageTypexgd = ShippingDocumentFormat.ImageType;
        String StockTypesf = ShippingDocumentFormat.StockType;
        Boolean ProvideInstructionszfsd = ShippingDocumentFormat.ProvideInstructions;
        ShipItFedExShipmentService.DocumentFormatOptionsRequested OptionsRequestedads= ShippingDocumentFormat.OptionsRequested;
        ShipItFedExShipmentService.Localization Localizationzzsv = ShippingDocumentFormat.Localization;
        String CustomDocumentIdentifieraadsv = ShippingDocumentFormat.CustomDocumentIdentifier;
        
        ShipItFedExShipmentService.Tax Tax = new ShipItFedExShipmentService.Tax();
        String TaxTypeAxds = Tax.TaxType;
        String Descriptionzsfgd = Tax.Description;
        ShipItFedExShipmentService.Money Amountaadsf= Tax.Amount;
        
        ShipItFedExShipmentService.HazardousCommodityDescription HazardousCommodityDescription = new ShipItFedExShipmentService.HazardousCommodityDescription();
        String Idadsf = HazardousCommodityDescription.Id;
        Integer SequenceNumberadfs = HazardousCommodityDescription.SequenceNumber;
        String PackingGroupsfdg = HazardousCommodityDescription.PackingGroup;
        ShipItFedExShipmentService.HazardousCommodityPackingDetail PackingDetailsaasdsf = HazardousCommodityDescription.PackingDetails;
        Boolean ReportableQuantityadsfd = HazardousCommodityDescription.ReportableQuantity;
        String ProperShippingName = HazardousCommodityDescription.ProperShippingName;
        String TechnicalName = HazardousCommodityDescription.TechnicalName;
        Decimal Percentage = HazardousCommodityDescription.Percentage;
        String HazardClass = HazardousCommodityDescription.HazardClass;
        String[] SubsidiaryClasses = HazardousCommodityDescription.SubsidiaryClasses;
        String LabelText = HazardousCommodityDescription.LabelText;
        String[] ProcessingOptions = HazardousCommodityDescription.ProcessingOptions;
        String Authorization = HazardousCommodityDescription.Authorization;
        
        ShipItFedExShipmentService.CustomLabelTextEntry CustomLabelTextEntry = new ShipItFedExShipmentService.CustomLabelTextEntry();
        ShipItFedExShipmentService.CustomLabelPosition Position = CustomLabelTextEntry.Position;
        String Formatzsfvd = CustomLabelTextEntry.Format;
        String[] DataFieldszsf = CustomLabelTextEntry.DataFields;
        String ThermalFontIdsvdf = CustomLabelTextEntry.ThermalFontId;
        String FontNamesvdf = CustomLabelTextEntry.FontName;
        Integer FontSizezsfd = CustomLabelTextEntry.FontSize;
        String Rotationasfd = CustomLabelTextEntry.Rotation;
        
        ShipItFedExShipmentService.CustomDeliveryWindowDetail CustomDeliveryWindowDetail = new ShipItFedExShipmentService.CustomDeliveryWindowDetail();
        String Type_xkkjh = CustomDeliveryWindowDetail.Type_x;
        DateTime RequestTimekjh = CustomDeliveryWindowDetail.RequestTime;
        ShipItFedExShipmentService.DateRange RequestRangekjh = CustomDeliveryWindowDetail.RequestRange;
        Date RequestDatehjg = CustomDeliveryWindowDetail.RequestDate;
        
        ShipItFedExShipmentService.ContentRecord ContentRecord = new ShipItFedExShipmentService.ContentRecord();
        String PartNumberads = ContentRecord.PartNumber;
        String ItemNumberadfs = ContentRecord.ItemNumber;
        Integer ReceivedQuantityadsvd = ContentRecord.ReceivedQuantity;
        String Descriptionadsfdg = ContentRecord.Description;
        
        ShipItFedExShipmentService.DeleteShipmentRequest DeleteShipmentRequest = new ShipItFedExShipmentService.DeleteShipmentRequest();
        ShipItFedExShipmentService.WebAuthenticationDetail WebAuthenticationDetailssfd = DeleteShipmentRequest.WebAuthenticationDetail;
        ShipItFedExShipmentService.ClientDetail ClientDetailsfdv = DeleteShipmentRequest.ClientDetail;
        ShipItFedExShipmentService.TransactionDetail TransactionDetailsfgd = DeleteShipmentRequest.TransactionDetail;
        ShipItFedExShipmentService.VersionId Versionsfdr = DeleteShipmentRequest.Version;
        DateTime ShipTimestampzadsfd = DeleteShipmentRequest.ShipTimestamp;
        ShipItFedExShipmentService.TrackingId TrackingIdsfgr = DeleteShipmentRequest.TrackingId;
        String DeletionControlzzsfdf = DeleteShipmentRequest.DeletionControl;
        
        ShipItFedExShipmentService.DangerousGoodsContainer DangerousGoodsContainer = new ShipItFedExShipmentService.DangerousGoodsContainer();
        String PackingType = DangerousGoodsContainer.PackingType;
        String ContainerType = DangerousGoodsContainer.ContainerType;
        String RadioactiveContainerClass = DangerousGoodsContainer.RadioactiveContainerClass;
        Integer NumberOfContainers = DangerousGoodsContainer.NumberOfContainers;
        ShipItFedExShipmentService.HazardousCommodityContent[] HazardousCommodities = DangerousGoodsContainer.HazardousCommodities;
        
        ShipItFedExShipmentService.VariableHandlingCharges VariableHandlingChargessfd = new ShipItFedExShipmentService.VariableHandlingCharges();
        ShipItFedExShipmentService.Money VariableHandlingChargenmb = VariableHandlingChargessfd.VariableHandlingCharge;
        ShipItFedExShipmentService.Money FixedVariableHandlingChargekn = VariableHandlingChargessfd.FixedVariableHandlingCharge;
        ShipItFedExShipmentService.Money PercentVariableHandlingChargekjn = VariableHandlingChargessfd.PercentVariableHandlingCharge;
        ShipItFedExShipmentService.Money TotalCustomerChargekjnjk = VariableHandlingChargessfd.TotalCustomerCharge;
        
        ShipItFedExShipmentService.PackageSpecialServicesRequested PackageSpecialServicesRequested = new ShipItFedExShipmentService.PackageSpecialServicesRequested();
        String[] SpecialServiceTypes = PackageSpecialServicesRequested.SpecialServiceTypes;
        ShipItFedExShipmentService.CodDetail CodDetail = PackageSpecialServicesRequested.CodDetail;
        ShipItFedExShipmentService.DangerousGoodsDetail DangerousGoodsDetail = PackageSpecialServicesRequested.DangerousGoodsDetail;
        ShipItFedExShipmentService.Weight DryIceWeight = PackageSpecialServicesRequested.DryIceWeight;
        ShipItFedExShipmentService.SignatureOptionDetail SignatureOptionDetail = PackageSpecialServicesRequested.SignatureOptionDetail;
        ShipItFedExShipmentService.PriorityAlertDetail PriorityAlertDetail = PackageSpecialServicesRequested.PriorityAlertDetail;
        ShipItFedExShipmentService.AlcoholDetail AlcoholDetail = PackageSpecialServicesRequested.AlcoholDetail;
        
        ShipItFedExShipmentService.CustomLabelGraphicEntry CustomLabelGraphicEntry = new ShipItFedExShipmentService.CustomLabelGraphicEntry();
        ShipItFedExShipmentService.CustomLabelPosition Positionkjhj = CustomLabelGraphicEntry.Position;
        String PrinterGraphicId = CustomLabelGraphicEntry.PrinterGraphicId;
        String FileGraphicFullName = CustomLabelGraphicEntry.FileGraphicFullName;
        
        ShipItFedExShipmentService.PendingShipmentAccessorDetail PendingShipmentAccessorDetail = new ShipItFedExShipmentService.PendingShipmentAccessorDetail();
        String Role = PendingShipmentAccessorDetail.Role;
        String UserId = PendingShipmentAccessorDetail.UserId;
        String Password = PendingShipmentAccessorDetail.Password;
        String EmailLabelUrl = PendingShipmentAccessorDetail.EmailLabelUrl;
        
        ShipItFedExShipmentService.FreightAddressLabelDetail FreightAddressLabelDetailkjhg = new ShipItFedExShipmentService.FreightAddressLabelDetail();
        ShipItFedExShipmentService.ShippingDocumentFormat Formathgjh = FreightAddressLabelDetailkjhg.Format;
        Integer Copies = FreightAddressLabelDetailkjhg.Copies;
        String StartingPosition = FreightAddressLabelDetailkjhg.StartingPosition;
        ShipItFedExShipmentService.DocTabContent DocTabContentjhg = FreightAddressLabelDetailkjhg.DocTabContent;
        String CustomContentPositionhhbhj = FreightAddressLabelDetailkjhg.CustomContentPosition;
        ShipItFedExShipmentService.CustomLabelDetail CustomContenthjg = FreightAddressLabelDetailkjhg.CustomContent;
        
        ShipItFedExShipmentService.FreightShipmentDetail FreightShipmentDetail = new ShipItFedExShipmentService.FreightShipmentDetail();
        String FedExFreightAccountNumber = FreightShipmentDetail.FedExFreightAccountNumber;
        ShipItFedExShipmentService.ContactAndAddress FedExFreightBillingContactAndAddress = FreightShipmentDetail.FedExFreightBillingContactAndAddress;
        ShipItFedExShipmentService.Party AlternateBilling = FreightShipmentDetail.AlternateBilling;
        ShipItFedExShipmentService.PrintedReference[] PrintedReferences = FreightShipmentDetail.PrintedReferences;
        String Rolejkhjk = FreightShipmentDetail.Role;
        String CollectTermsTypekjkhj = FreightShipmentDetail.CollectTermsType;
        ShipItFedExShipmentService.Money DeclaredValuePerUnit = FreightShipmentDetail.DeclaredValuePerUnit;
        String DeclaredValueUnits = FreightShipmentDetail.DeclaredValueUnits;
        ShipItFedExShipmentService.LiabilityCoverageDetail LiabilityCoverageDetail=  FreightShipmentDetail.LiabilityCoverageDetail;
        String[] Coupons = FreightShipmentDetail.Coupons;
        Integer TotalHandlingUnits = FreightShipmentDetail.TotalHandlingUnits;
        Decimal ClientDiscountPercent = FreightShipmentDetail.ClientDiscountPercent;
        ShipItFedExShipmentService.Weight PalletWeight = FreightShipmentDetail.PalletWeight;
        ShipItFedExShipmentService.Dimensions ShipmentDimensions = FreightShipmentDetail.ShipmentDimensions;
        String Comment = FreightShipmentDetail.Comment;
        ShipItFedExShipmentService.FreightSpecialServicePayment[] SpecialServicePayments  = FreightShipmentDetail.SpecialServicePayments;
        String HazardousMaterialsEmergencyContactNumber = FreightShipmentDetail.HazardousMaterialsEmergencyContactNumber;
        String HazardousMaterialsOfferor = FreightShipmentDetail.HazardousMaterialsOfferor;
        ShipItFedExShipmentService.FreightShipmentLineItem[] LineItems = FreightShipmentDetail.LineItems;
        
        ShipItFedExShipmentService.RadionuclideDetail RadionuclideDetailuhgj = new ShipItFedExShipmentService.RadionuclideDetail();
        String Radionuclide = RadionuclideDetailuhgj.Radionuclide;
        ShipItFedExShipmentService.RadionuclideActivity Activity = RadionuclideDetailuhgj.Activity;
        Boolean ExceptedPackagingIsReportableQuantity = RadionuclideDetailuhgj.ExceptedPackagingIsReportableQuantity;
        String PhysicalForm = RadionuclideDetailuhgj.PhysicalForm;
        String ChemicalForm = RadionuclideDetailuhgj.ChemicalForm;
        
        ShipItFedExShipmentService.ShipmentRateDetail ShipmentRateDetail = new ShipItFedExShipmentService.ShipmentRateDetail();
        String RateTypekjh = ShipmentRateDetail.RateType;
        String RateScalekjh = ShipmentRateDetail.RateScale;
        String RateZonekjbh = ShipmentRateDetail.RateZone;
        String PricingCodejkh = ShipmentRateDetail.PricingCode;
        String RatedWeightMethodjkh = ShipmentRateDetail.RatedWeightMethod;
        String MinimumChargeTypekjhj = ShipmentRateDetail.MinimumChargeType;
        ShipItFedExShipmentService.CurrencyExchangeRate CurrencyExchangeRatejh = ShipmentRateDetail.CurrencyExchangeRate;
        String[] SpecialRatingAppliedkjh = ShipmentRateDetail.SpecialRatingApplied;
        Integer DimDivisorkjh= ShipmentRateDetail.DimDivisor;
        String DimDivisorTypekjh = ShipmentRateDetail.DimDivisorType;
        Decimal FuelSurchargePercentlkjh = ShipmentRateDetail.FuelSurchargePercent;
        ShipItFedExShipmentService.Weight TotalBillingWeighthgf = ShipmentRateDetail.TotalBillingWeight;
        ShipItFedExShipmentService.Weight TotalDimWeightjjhg = ShipmentRateDetail.TotalDimWeight;
        ShipItFedExShipmentService.Money TotalBaseChargehjg = ShipmentRateDetail.TotalBaseCharge;
        ShipItFedExShipmentService.Money TotalFreightDiscountsjhgf = ShipmentRateDetail.TotalFreightDiscounts;
        ShipItFedExShipmentService.Money TotalNetFreightkjh = ShipmentRateDetail.TotalNetFreight;
        ShipItFedExShipmentService.Money TotalSurchargesjhg = ShipmentRateDetail.TotalSurcharges;
        ShipItFedExShipmentService.Money TotalNetFedExChargejyg = ShipmentRateDetail.TotalNetFedExCharge;
        ShipItFedExShipmentService.Money TotalTaxesjhg = ShipmentRateDetail.TotalTaxes;
        ShipItFedExShipmentService.Money TotalNetChargehg = ShipmentRateDetail.TotalNetCharge;
        ShipItFedExShipmentService.Money TotalRebatesjhg = ShipmentRateDetail.TotalRebates;
        ShipItFedExShipmentService.Money TotalDutiesAndTaxesjgv = ShipmentRateDetail.TotalDutiesAndTaxes;
        ShipItFedExShipmentService.Money TotalNetChargeWithDutiesAndTaxesjh = ShipmentRateDetail.TotalNetChargeWithDutiesAndTaxes;
        ShipItFedExShipmentService.ShipmentLegRateDetail[] ShipmentLegRateDetailsjhg = ShipmentRateDetail.ShipmentLegRateDetails;
        ShipItFedExShipmentService.FreightRateDetail FreightRateDetailhg = ShipmentRateDetail.FreightRateDetail;
        ShipItFedExShipmentService.RateDiscount[] FreightDiscountsjhjg = ShipmentRateDetail.FreightDiscounts;
        ShipItFedExShipmentService.Rebate[] Rebateshg = ShipmentRateDetail.Rebates;
        ShipItFedExShipmentService.Surcharge[] Surchargesjhg = ShipmentRateDetail.Surcharges;
        ShipItFedExShipmentService.Tax[] Taxesjhj= ShipmentRateDetail.Taxes;
        ShipItFedExShipmentService.EdtCommodityTax[] DutiesAndTaxesjhg = ShipmentRateDetail.DutiesAndTaxes;
        ShipItFedExShipmentService.VariableHandlingCharges VariableHandlingChargesjhg = ShipmentRateDetail.VariableHandlingCharges;
        ShipItFedExShipmentService.VariableHandlingCharges TotalVariableHandlingChargeskjh = ShipmentRateDetail.TotalVariableHandlingCharges;
        
        ShipItFedExShipmentService.CustomsClearanceDetail CustomsClearanceDetail = new ShipItFedExShipmentService.CustomsClearanceDetail();
          ShipItFedExShipmentService.BrokerDetail[] Brokers = CustomsClearanceDetail.Brokers;
          String ClearanceBrokerage = CustomsClearanceDetail.ClearanceBrokerage;
          ShipItFedExShipmentService.CustomsOptionDetail CustomsOptions= CustomsClearanceDetail.CustomsOptions;
          ShipItFedExShipmentService.Party ImporterOfRecord = CustomsClearanceDetail.ImporterOfRecord;
          ShipItFedExShipmentService.RecipientCustomsId RecipientCustomsId = CustomsClearanceDetail.RecipientCustomsId;
          ShipItFedExShipmentService.Payment DutiesPayment = CustomsClearanceDetail.DutiesPayment;
          String DocumentContent = CustomsClearanceDetail.DocumentContent;
          ShipItFedExShipmentService.Money CustomsValue = CustomsClearanceDetail.CustomsValue;
          String FreightOnValue = CustomsClearanceDetail.FreightOnValue;
          ShipItFedExShipmentService.Money InsuranceCharges = CustomsClearanceDetail.InsuranceCharges;
          Boolean PartiesToTransactionAreRelated = CustomsClearanceDetail.PartiesToTransactionAreRelated;
          ShipItFedExShipmentService.CommercialInvoice CommercialInvoicehgh = CustomsClearanceDetail.CommercialInvoice;
          ShipItFedExShipmentService.Commodity[] Commoditieshjg = CustomsClearanceDetail.Commodities;
          ShipItFedExShipmentService.ExportDetail ExportDetail = CustomsClearanceDetail.ExportDetail;
          String[] RegulatoryControls = CustomsClearanceDetail.RegulatoryControls;
          ShipItFedExShipmentService.CustomsDeclarationStatementDetail DeclarationStatementDetail = CustomsClearanceDetail.DeclarationStatementDetail;
        
        ShipItFedExShipmentService.ValidatedHazardousCommodityDescription ValidatedHazardousCommodityDescription = new ShipItFedExShipmentService.ValidatedHazardousCommodityDescription();
        String Idhjghj = ValidatedHazardousCommodityDescription.Id;
        Integer SequenceNumber = ValidatedHazardousCommodityDescription.SequenceNumber;
        String PackingGroup = ValidatedHazardousCommodityDescription.PackingGroup;
        String PackingInstructions = ValidatedHazardousCommodityDescription.PackingInstructions;
        String ProperShippingNamejhyg = ValidatedHazardousCommodityDescription.ProperShippingName;
        String ProperShippingNameAndDescriptionhgfgh = ValidatedHazardousCommodityDescription.ProperShippingNameAndDescription;
        String TechnicalNamejhgf = ValidatedHazardousCommodityDescription.TechnicalName;
        String HazardClasskuuh = ValidatedHazardousCommodityDescription.HazardClass;
        String[] SubsidiaryClassesefg = ValidatedHazardousCommodityDescription.SubsidiaryClasses;
        String Symbolskuy = ValidatedHazardousCommodityDescription.Symbols;
        String TunnelRestrictionCodejhg = ValidatedHazardousCommodityDescription.TunnelRestrictionCode;
        String SpecialProvisionsjuhg = ValidatedHazardousCommodityDescription.SpecialProvisions;
        String[] Attributesjgh = ValidatedHazardousCommodityDescription.Attributes;
        String Authorizationjhg = ValidatedHazardousCommodityDescription.Authorization;
        String LabelTextjkh = ValidatedHazardousCommodityDescription.LabelText;
        
        ShipItFedExShipmentService.DangerousGoodsDetail DangerousGoodsDetailsfsf = new ShipItFedExShipmentService.DangerousGoodsDetail();
        String Regulation = DangerousGoodsDetailsfsf.Regulation;
        String Accessibility = DangerousGoodsDetailsfsf.Accessibility;
        Boolean CargoAircraftOnly = DangerousGoodsDetailsfsf.CargoAircraftOnly;
        String[] Options = DangerousGoodsDetailsfsf.Options;
        String PackingOption = DangerousGoodsDetailsfsf.PackingOption;
        String ReferenceId = DangerousGoodsDetailsfsf.ReferenceId;
        ShipItFedExShipmentService.DangerousGoodsContainer[] Containers = DangerousGoodsDetailsfsf.Containers;
        ShipItFedExShipmentService.HazardousCommodityPackagingDetail Packaging = DangerousGoodsDetailsfsf.Packaging;
        ShipItFedExShipmentService.DangerousGoodsSignatory Signatory = DangerousGoodsDetailsfsf.Signatory;
        String EmergencyContactNumber = DangerousGoodsDetailsfsf.EmergencyContactNumber;
        String Offeror = DangerousGoodsDetailsfsf.Offeror;
        ShipItFedExShipmentService.Contact InfectiousSubstanceResponsibleContact = DangerousGoodsDetailsfsf.InfectiousSubstanceResponsibleContact;
        String AdditionalHandling = DangerousGoodsDetailsfsf.AdditionalHandling;
        ShipItFedExShipmentService.RadioactivityDetail RadioactivityDetail = DangerousGoodsDetailsfsf.RadioactivityDetail;
        
        ShipItFedExShipmentService.AssociatedShipmentDetail AssociatedShipmentDetail = new ShipItFedExShipmentService.AssociatedShipmentDetail();
        String Type_xds = AssociatedShipmentDetail.Type_x;
        ShipItFedExShipmentService.Party Senderds = AssociatedShipmentDetail.Sender;
        ShipItFedExShipmentService.Party Recipientsf = AssociatedShipmentDetail.Recipient;
        String ServiceTypesf = AssociatedShipmentDetail.ServiceType;
        String PackagingTypedfs = AssociatedShipmentDetail.PackagingType;
        ShipItFedExShipmentService.TrackingId TrackingIdsf = AssociatedShipmentDetail.TrackingId;
        ShipItFedExShipmentService.CustomerReference[] CustomerReferencessc = AssociatedShipmentDetail.CustomerReferences;
        ShipItFedExShipmentService.ShipmentOperationalDetail ShipmentOperationalDetailaafse = AssociatedShipmentDetail.ShipmentOperationalDetail;
        ShipItFedExShipmentService.PackageOperationalDetail PackageOperationalDetailsf = AssociatedShipmentDetail.PackageOperationalDetail;
        ShipItFedExShipmentService.ShippingDocument Labelads = AssociatedShipmentDetail.Label;
        
        ShipItFedExShipmentService.CompletedTagDetail CompletedTagDetail = new ShipItFedExShipmentService.CompletedTagDetail();
        String ConfirmationNumberadsf = CompletedTagDetail.ConfirmationNumber;
        String AccessTime = CompletedTagDetail.AccessTime;
        DateTime CutoffTime = CompletedTagDetail.CutoffTime; 
        String Location = CompletedTagDetail.Location;
        DateTime DeliveryCommitment = CompletedTagDetail.DeliveryCommitment; 
        Date DispatchDateads = CompletedTagDetail.DispatchDate;
        
        ShipItFedExShipmentService.FreightBaseCharge FreightBaseCharge = new ShipItFedExShipmentService.FreightBaseCharge();
        String FreightClass = FreightBaseCharge.FreightClass;
        String RatedAsClass = FreightBaseCharge.RatedAsClass;
        String NmfcCode = FreightBaseCharge.NmfcCode;
        String Descriptionsffda = FreightBaseCharge.Description;
        ShipItFedExShipmentService.Weight Weightsfvd = FreightBaseCharge.Weight;
        ShipItFedExShipmentService.Money ChargeRatezsdf = FreightBaseCharge.ChargeRate;
        String ChargeBasissffegr = FreightBaseCharge.ChargeBasis;
        ShipItFedExShipmentService.Money ExtendedAmountsfdgf = FreightBaseCharge.ExtendedAmount;
        
        ShipItFedExShipmentService.FreightShipmentLineItem FreightShipmentLineItem  = new ShipItFedExShipmentService.FreightShipmentLineItem();
        String FreightClasssfg = FreightShipmentLineItem.FreightClass; 
        Boolean ClassProvidedByCustomer = FreightShipmentLineItem.ClassProvidedByCustomer;
        Integer HandlingUnits = FreightShipmentLineItem.HandlingUnits;
        String Packagingsfdb = FreightShipmentLineItem.Packaging;
        Integer Pieceslok = FreightShipmentLineItem.Pieces;
        String NmfcCodewerer = FreightShipmentLineItem.NmfcCode;
        String HazardousMaterialswfe = FreightShipmentLineItem.HazardousMaterials;
        String PurchaseOrderNumberadsfe= FreightShipmentLineItem.PurchaseOrderNumber;
        String Descriptionadfs = FreightShipmentLineItem.Description;
        ShipItFedExShipmentService.Weight Weightfb= FreightShipmentLineItem.Weight;
        ShipItFedExShipmentService.Dimensions Dimensionsdg = FreightShipmentLineItem.Dimensions; 
        ShipItFedExShipmentService.Volume Volumehykyj = FreightShipmentLineItem.Volume; 
        
        ShipItFedExShipmentService.CompletedHazardousPackageDetail CompletedHazardousPackageDetail = new ShipItFedExShipmentService.CompletedHazardousPackageDetail();
        String ReferenceIdsfd = CompletedHazardousPackageDetail.ReferenceId;
        String Accessibilityfhjy = CompletedHazardousPackageDetail.Accessibility;
        Boolean CargoAircraftOnlydghtj = CompletedHazardousPackageDetail.CargoAircraftOnly;
        String Regulationdfg = CompletedHazardousPackageDetail.Regulation;
        Decimal RadioactiveTransportIndexssdghtj = CompletedHazardousPackageDetail.RadioactiveTransportIndex;
        String LabelTypehtjyy = CompletedHazardousPackageDetail.LabelType; 
        ShipItFedExShipmentService.ValidatedHazardousContainer[] Containerssffgrh = CompletedHazardousPackageDetail.Containers;
        
        ShipItFedExShipmentService.PickupDetail PickupDetail = new ShipItFedExShipmentService.PickupDetail();
        DateTime ReadyDateTime = PickupDetail.ReadyDateTime;
        DateTime LatestPickupDateTime = PickupDetail.LatestPickupDateTime;
        String CourierInstructions = PickupDetail.CourierInstructions;
        String RequestType = PickupDetail.RequestType;
        String RequestSource = PickupDetail.RequestSource;
        
        ShipItFedExShipmentService.ExportDetail ExportDetailsfd = new ShipItFedExShipmentService.ExportDetail();
        String B13AFilingOption = ExportDetailsfd.B13AFilingOption;
        String ExportComplianceStatement = ExportDetailsfd.ExportComplianceStatement;
        String PermitNumber = ExportDetailsfd.PermitNumber;
        ShipItFedExShipmentService.DestinationControlDetail DestinationControlDetail = ExportDetailsfd.DestinationControlDetail;
        
        ShipItFedExShipmentService.ConfigurableLabelReferenceEntry ConfigurableLabelReferenceEntry = new ShipItFedExShipmentService.ConfigurableLabelReferenceEntry();
        Integer ZoneNumbersdg = ConfigurableLabelReferenceEntry.ZoneNumber;
        String Headersfg = ConfigurableLabelReferenceEntry.Header;
        String DataFieldddgh = ConfigurableLabelReferenceEntry.DataField;
        String LiteralValuefygy = ConfigurableLabelReferenceEntry.LiteralValue;
        
        ShipItFedExShipmentService.TaxpayerIdentification TaxpayerIdentification = new ShipItFedExShipmentService.TaxpayerIdentification();
        String TinType = TaxpayerIdentification.TinType;
        String Number_x = TaxpayerIdentification.Number_x;
        String Usage = TaxpayerIdentification.Usage;
        DateTime EffectiveDatesfegr = TaxpayerIdentification.EffectiveDate;
        DateTime ExpirationDatesdgrht = TaxpayerIdentification.ExpirationDate;
        
        ShipItFedExShipmentService.UploadDocumentDetail UploadDocumentDetail = new ShipItFedExShipmentService.UploadDocumentDetail();
        Integer LineNumbesvdr = UploadDocumentDetail.LineNumber;
        String CustomerReferencezsdfb = UploadDocumentDetail.CustomerReference;
        String DocumentProducersfgrht =  UploadDocumentDetail.DocumentProducer;
        String DocumentTypesdgfg = UploadDocumentDetail.DocumentType;
        String FileNamesfdgfh = UploadDocumentDetail.FileName;
        String DocumentContentasdfdgf = UploadDocumentDetail.DocumentContent;
        Date ExpirationDateasfgr = UploadDocumentDetail.ExpirationDate;
        
        ShipItFedExShipmentService.RadioactivityDetail RadioactivityDetailasfd = new ShipItFedExShipmentService.RadioactivityDetail();
        Decimal TransportIndex = RadioactivityDetailasfd.TransportIndex;
        Decimal SurfaceReading = RadioactivityDetailasfd.SurfaceReading;
        Decimal CriticalitySafetyIndex = RadioactivityDetailasfd.CriticalitySafetyIndex;
        ShipItFedExShipmentService.Dimensions Dimensions = RadioactivityDetailasfd.Dimensions;
        
        ShipItFedExShipmentService.EMailRecipient EMailRecipient = new ShipItFedExShipmentService.EMailRecipient();
        String EmailAddresssfegr = EMailRecipient.EmailAddress;
        String Rolesfdgfht = EMailRecipient.Role;
        ShipItFedExShipmentService.EmailOptionsRequested OptionsRequestedsdgfhg = EMailRecipient.OptionsRequested;
        ShipItFedExShipmentService.Localization Localizationsdvgfb = EMailRecipient.Localization;
        
        ShipItFedExShipmentService.Rebate Rebate = new ShipItFedExShipmentService.Rebate();
        String RebateType = Rebate.RebateType;
        String Descriptionfegr = Rebate.Description;
        ShipItFedExShipmentService.Money Amountssfdgfg  = Rebate.Amount;
        Decimal Percentadsfdgrh = Rebate.Percent;
        
        ShipItFedExShipmentService.Surcharge Surcharge = new ShipItFedExShipmentService.Surcharge();
        String SurchargeType = Surcharge.SurchargeType;
        String Level = Surcharge.Level;
        String Descriptionsvvdbnty = Surcharge.Description;
        ShipItFedExShipmentService.Money Amountssgdhf = Surcharge.Amount; 
        
        ShipItFedExShipmentService.SmartPostShipmentDetail SmartPostShipmentDetail = new ShipItFedExShipmentService.SmartPostShipmentDetail();
        String Indicia  = SmartPostShipmentDetail.Indicia;
        String AncillaryEndorsement =SmartPostShipmentDetail.AncillaryEndorsement;
        String HubId = SmartPostShipmentDetail.HubId;
        String CustomerManifestId = SmartPostShipmentDetail.CustomerManifestId;
        
        ShipItFedExShipmentService.Op900Detail Op900Detailsfvde = new ShipItFedExShipmentService.Op900Detail();
        ShipItFedExShipmentService.ShippingDocumentFormat Formatsfgerht = Op900Detailsfvde.Format;
        String Reference = Op900Detailsfvde.Reference;
        ShipItFedExShipmentService.CustomerImageUsage[] CustomerImageUsagessvdd = Op900Detailsfvde.CustomerImageUsages;
        String SignatureNamesfdgf = Op900Detailsfvde.SignatureName;
        
        ShipItFedExShipmentService.PackageRateDetail PackageRateDetail = new ShipItFedExShipmentService.PackageRateDetail();
        String RateTypesdfg = PackageRateDetail.RateType;
        String RatedWeightMethodzsfdvgfbg = PackageRateDetail.RatedWeightMethod;
        String MinimumChargeTypeasdvfb = PackageRateDetail.MinimumChargeType;
        ShipItFedExShipmentService.Weight BillingWeightasdf = PackageRateDetail.BillingWeight;
        ShipItFedExShipmentService.Weight DimWeightscdfg = PackageRateDetail.DimWeight;
        ShipItFedExShipmentService.Weight OversizeWeightasdfg = PackageRateDetail.OversizeWeight;
        ShipItFedExShipmentService.Money BaseChargeasdf = PackageRateDetail.BaseCharge;
        ShipItFedExShipmentService.Money TotalFreightDiscountsasfdgr = PackageRateDetail.TotalFreightDiscounts;
        ShipItFedExShipmentService.Money NetFreight = PackageRateDetail.NetFreight;
        ShipItFedExShipmentService.Money TotalSurchargessfve = PackageRateDetail.TotalSurcharges;
        ShipItFedExShipmentService.Money NetFedExChargeaadssfed = PackageRateDetail.NetFedExCharge;
        ShipItFedExShipmentService.Money TotalTaxesasvd = PackageRateDetail.TotalTaxes;
        ShipItFedExShipmentService.Money NetChargessffdr = PackageRateDetail.NetCharge;
        ShipItFedExShipmentService.Money TotalRebatesafwegrh = PackageRateDetail.TotalRebates; 
        ShipItFedExShipmentService.RateDiscount[] FreightDiscountadsfegrts = PackageRateDetail.FreightDiscounts;
        ShipItFedExShipmentService.Rebate[] Rebatessfgrt = PackageRateDetail.Rebates;
        ShipItFedExShipmentService.Surcharge[] Surchargessfegrht = PackageRateDetail.Surcharges;
        ShipItFedExShipmentService.Tax[] Taxessrty = PackageRateDetail.Taxes;
        ShipItFedExShipmentService.VariableHandlingCharges VariableHandlingChargesasdvbf  = PackageRateDetail.VariableHandlingCharges;
        
        ShipItFedExShipmentService.ProcessTagReply ProcessTagReply = new ShipItFedExShipmentService.ProcessTagReply();
        String HighestSeverityasfdgr = ProcessTagReply.HighestSeverity;
        ShipItFedExShipmentService.Notification[] Notificationsasfer = ProcessTagReply.Notifications;
        ShipItFedExShipmentService.TransactionDetail TransactionDetailasfegr = ProcessTagReply.TransactionDetail;
        ShipItFedExShipmentService.VersionId Versionadwfegr = ProcessTagReply.Version;
        ShipItFedExShipmentService.CompletedShipmentDetail CompletedShipmentDetailasdgf = ProcessTagReply.CompletedShipmentDetail;
        
        ShipItFedExShipmentService.PendingShipmentDetail PendingShipmentDetail = new ShipItFedExShipmentService.PendingShipmentDetail();
        String Type_xadsfegr = PendingShipmentDetail.Type_x;
        Date ExpirationDateaawfegrht = PendingShipmentDetail.ExpirationDate;
        ShipItFedExShipmentService.EMailLabelDetail EmailLabelDetailsfegrht = PendingShipmentDetail.EmailLabelDetail;
        ShipItFedExShipmentService.PendingShipmentProcessingOptionsRequested ProcessingOptionsadsd = PendingShipmentDetail.ProcessingOptions;
        ShipItFedExShipmentService.RecommendedDocumentSpecification RecommendedDocumentSpecificationasfder = PendingShipmentDetail.RecommendedDocumentSpecification;
        ShipItFedExShipmentService.UploadDocumentReferenceDetail[] DocumentReferencesasfdgf = PendingShipmentDetail.DocumentReferences;
			
        ShipItFedExShipmentService.CertificateOfOriginDetail CertificateOfOriginDetail = new ShipItFedExShipmentService.CertificateOfOriginDetail();
        ShipItFedExShipmentService.ShippingDocumentFormat DocumentFormatdsfvbgd = CertificateOfOriginDetail.DocumentFormat;
        ShipItFedExShipmentService.CustomerImageUsage[] CustomerImageUsagesdsfd = CertificateOfOriginDetail.CustomerImageUsages;
        
        ShipItFedExShipmentService.ShipmentConfigurationData ShipmentConfigurationData = new ShipItFedExShipmentService.ShipmentConfigurationData();
        ShipItFedExShipmentService.DangerousGoodsDetail[] DangerousGoodsPackageConfigurations = ShipmentConfigurationData.DangerousGoodsPackageConfigurations;
        
        ShipItFedExShipmentService.ShippingDocumentEMailDetail ShippingDocumentEMailDetail = new ShipItFedExShipmentService.ShippingDocumentEMailDetail();
        ShipItFedExShipmentService.ShippingDocumentEMailRecipient[] EMailRecipients = ShippingDocumentEMailDetail.EMailRecipients;
        String Grouping234 = ShippingDocumentEMailDetail.Grouping;
        ShipItFedExShipmentService.Localization Localization = ShippingDocumentEMailDetail.Localization;
        
        ShipItFedExShipmentService.HazardousCommodityOptionDetail HazardousCommodityOptionDetail = new ShipItFedExShipmentService.HazardousCommodityOptionDetail();
        String LabelTextOption = HazardousCommodityOptionDetail.LabelTextOption;
        String CustomerSuppliedLabelText = HazardousCommodityOptionDetail.CustomerSuppliedLabelText;
        
        ShipItFedExShipmentService.OperationalInstruction OperationalInstruction = new ShipItFedExShipmentService.OperationalInstruction();
        Integer Number_xsfdgdg = OperationalInstruction.Number_x;
        String Content = OperationalInstruction.Content;
        
        ShipItFedExShipmentService.Dimensions Dimensionssfdgfzsd = new ShipItFedExShipmentService.Dimensions();
        Integer Length = Dimensionssfdgfzsd.Length;
        Integer Width = Dimensionssfdgfzsd.Width;
        Integer Height = Dimensionssfdgfzsd.Height;
        String Unitsadsfddf = Dimensionssfdgfzsd.Units;
        
        ShipItFedExShipmentService.LicenseOrPermitDetail LicenseOrPermitDetail = new ShipItFedExShipmentService.LicenseOrPermitDetail();
        String Number_xsfdgfsd = LicenseOrPermitDetail.Number_x;
        Date EffectiveDatessfgdbbf = LicenseOrPermitDetail.EffectiveDate;
        Date ExpirationDatesvdbf = LicenseOrPermitDetail.ExpirationDate;
        
        ShipItFedExShipmentService.DangerousGoodsSignatory DangerousGoodsSignatory = new ShipItFedExShipmentService.DangerousGoodsSignatory();
        String ContactName = DangerousGoodsSignatory.ContactName;
        String Title = DangerousGoodsSignatory.Title;
        String Place = DangerousGoodsSignatory.Place;
        
        ShipItFedExShipmentService.RateDiscount RateDiscount = new ShipItFedExShipmentService.RateDiscount();
        String RateDiscountType = RateDiscount.RateDiscountType;
        String Descriptionzzsfvdbf = RateDiscount.Description;
        ShipItFedExShipmentService.Money Amountsfdgfdgfg = RateDiscount.Amount;
        Decimal Percentssfgdbfng = RateDiscount.Percent;
        
        ShipItFedExShipmentService.ReturnShipmentDetail ReturnShipmentDetail = new ShipItFedExShipmentService.ReturnShipmentDetail();
        String ReturnType = ReturnShipmentDetail.ReturnType;
        ShipItFedExShipmentService.Rma Rma = ReturnShipmentDetail.Rma;
        ShipItFedExShipmentService.ReturnEMailDetail ReturnEMailDetail = ReturnShipmentDetail.ReturnEMailDetail;
        ShipItFedExShipmentService.ReturnAssociationDetail ReturnAssociation = ReturnShipmentDetail.ReturnAssociation;
        
        ShipItFedExShipmentService.ShippingDocumentEMailRecipient ShippingDocumentEMailRecipient = new ShipItFedExShipmentService.ShippingDocumentEMailRecipient();
        String RecipientType = ShippingDocumentEMailRecipient.RecipientType;
        String Address = ShippingDocumentEMailRecipient.RecipientType;
        
        ShipItFedExShipmentService.ShipmentManifestDetail ShipmentManifestDetail = new ShipItFedExShipmentService.ShipmentManifestDetail();
        String ManifestReferenceType = ShipmentManifestDetail.ManifestReferenceType;
        
        ShipItFedExShipmentService.CompletedHazardousShipmentDetail CompletedHazardousShipmentDetail = new ShipItFedExShipmentService.CompletedHazardousShipmentDetail();
        ShipItFedExShipmentService.CompletedHazardousSummaryDetail HazardousSummaryDetail = CompletedHazardousShipmentDetail.HazardousSummaryDetail;
        ShipItFedExShipmentService.ShipmentDryIceDetail DryIceDetail = CompletedHazardousShipmentDetail.DryIceDetail;
        ShipItFedExShipmentService.AdrLicenseDetail AdrLicense = CompletedHazardousShipmentDetail.AdrLicense;
        
        ShipItFedExShipmentService.BinaryBarcode BinaryBarcode = new ShipItFedExShipmentService.BinaryBarcode();
        String Type_xsfdgfhng = BinaryBarcode.Type_x;
        String Valuessfdgfng = BinaryBarcode.Value;
        
        ShipItFedExShipmentService.Money Money = new ShipItFedExShipmentService.Money();
        String Currency_x = Money.Currency_x;
        Decimal Amountadsvdbf = Money.Amount;
        
        ShipItFedExShipmentService.PrintedReference PrintedReference = new ShipItFedExShipmentService.PrintedReference();
        String Type_xzfvdgfg = PrintedReference.Type_x;
        String Valuesfgdfhg = PrintedReference.Value;
        
        ShipItFedExShipmentService.Volume Volume = new ShipItFedExShipmentService.Volume();
        String Unitsadfgdhf = Volume.Units;
        Decimal Valueeetrytjy = Volume.Value;
        
        ShipItFedExShipmentService.HazardousCommodityPackingDetail HazardousCommodityPackingDetail = new ShipItFedExShipmentService.HazardousCommodityPackingDetail();
        Boolean CargoAircraftOnlyrhtjy = HazardousCommodityPackingDetail.CargoAircraftOnly;
        String PackingInstructionsdfgnhg = HazardousCommodityPackingDetail.PackingInstructions;
        
        ShipItFedExShipmentService.NaftaLowValueStatementDetail NaftaLowValueStatementDetail = new ShipItFedExShipmentService.NaftaLowValueStatementDetail();
        String Roleasvdbf = NaftaLowValueStatementDetail.Role;
        
        ShipItFedExShipmentService.CommercialInvoiceDetail CommercialInvoiceDetailadsvdbf = new ShipItFedExShipmentService.CommercialInvoiceDetail();
        ShipItFedExShipmentService.ShippingDocumentFormat Formatsxvdbf = CommercialInvoiceDetailadsvdbf.Format;
        ShipItFedExShipmentService.CustomerImageUsage[] CustomerImageUsageszdsfvdf = CommercialInvoiceDetailadsvdbf.CustomerImageUsages;
        
        ShipItFedExShipmentService.FreightGuaranteeDetail FreightGuaranteeDetail = new ShipItFedExShipmentService.FreightGuaranteeDetail();
        String Type_xscvdbf = FreightGuaranteeDetail.Type_x;
        Date Date_xsfdgfhng = FreightGuaranteeDetail.Date_x;
        
        ShipItFedExShipmentService.ReturnEMailDetail ReturnEMailDetailadfsgdfg = new ShipItFedExShipmentService.ReturnEMailDetail();
        String MerchantPhoneNumber = ReturnEMailDetailadfsgdfg.MerchantPhoneNumber;
        String[] AllowedSpecialServices = ReturnEMailDetailadfsgdfg.AllowedSpecialServices;
        
        ShipItFedExShipmentService.PendingShipmentProcessingOptionsRequested PendingShipmentProcessingOptionsRequested = new ShipItFedExShipmentService.PendingShipmentProcessingOptionsRequested();
        String[] Optionsjknjkn = PendingShipmentProcessingOptionsRequested.Options;
        
        ShipItFedExShipmentService.InternationalTrafficInArmsRegulationsDetail InternationalTrafficInArmsRegulationsDetail = new ShipItFedExShipmentService.InternationalTrafficInArmsRegulationsDetail();
        String LicenseOrExemptionNumber = InternationalTrafficInArmsRegulationsDetail.LicenseOrExemptionNumber;
        
        ShipItFedExShipmentService.PackageRating PackageRating = new ShipItFedExShipmentService.PackageRating();
        String ActualRateTypescvdbf = PackageRating.ActualRateType;
        ShipItFedExShipmentService.Money EffectiveNetDiscountasfvdbf = PackageRating.EffectiveNetDiscount;
        ShipItFedExShipmentService.PackageRateDetail[] PackageRateDetailszcsvdf = PackageRating.PackageRateDetails;
        
        ShipItFedExShipmentService.AlcoholDetail AlcoholDetailaacsvdf = new ShipItFedExShipmentService.AlcoholDetail();
        String RecipientTypezZsfvdbfng = AlcoholDetailaacsvdf.RecipientType;
        
        ShipItFedExShipmentService.EtdDetail EtdDetail = new ShipItFedExShipmentService.EtdDetail();
        String[] RequestedDocumentCopies = EtdDetail.RequestedDocumentCopies;
        ShipItFedExShipmentService.UploadDocumentDetail[] Documents = EtdDetail.Documents;
        ShipItFedExShipmentService.UploadDocumentReferenceDetail[] DocumentReferences = EtdDetail.DocumentReferences;
        
        ShipItFedExShipmentService.EdtExciseCondition EdtExciseCondition = new ShipItFedExShipmentService.EdtExciseCondition();
        String Category = EdtExciseCondition.Category;
        String Valuesvdbf = EdtExciseCondition.Value;
        
        ShipItFedExShipmentService.Measure Measure = new ShipItFedExShipmentService.Measure();
        Decimal Quantityacsvdf = Measure.Quantity;
        String Unitssvdbfg = Measure.Units;
        
        ShipItFedExShipmentService.PriorityAlertDetail PriorityAlertDetailsccvdbfg = new ShipItFedExShipmentService.PriorityAlertDetail();
        String[] EnhancementTypes = PriorityAlertDetailsccvdbfg.EnhancementTypes;
        String[] Contentasvdf = PriorityAlertDetailsccvdbfg.Content;
        
        ShipItFedExShipmentService.EdtCommodityTax EdtCommodityTax = new ShipItFedExShipmentService.EdtCommodityTax();
        String HarmonizedCodesvdbfxc = EdtCommodityTax.HarmonizedCode;
        ShipItFedExShipmentService.EdtTaxDetail[] Taxesscvdfbsdv = EdtCommodityTax.Taxes;
        
        ShipItFedExShipmentService.AdrLicenseDetail AdrLicenseDetail = new ShipItFedExShipmentService.AdrLicenseDetail();
        ShipItFedExShipmentService.LicenseOrPermitDetail LicenseOrPermitDetailasfvdbf = AdrLicenseDetail.LicenseOrPermitDetail;
        
        ShipItFedExShipmentService.CompletedHoldAtLocationDetail CompletedHoldAtLocationDetail = new ShipItFedExShipmentService.CompletedHoldAtLocationDetail();
        ShipItFedExShipmentService.ContactAndAddress HoldingLocation = CompletedHoldAtLocationDetail.HoldingLocation;
        String HoldingLocationType = CompletedHoldAtLocationDetail.HoldingLocationType;
        
        ShipItFedExShipmentService.BrokerDetail BrokerDetail = new ShipItFedExShipmentService.BrokerDetail();
        String Type_xadsfvdb = BrokerDetail.Type_x;
        ShipItFedExShipmentService.Party Broker = BrokerDetail.Broker;
        
        ShipItFedExShipmentService.LiabilityCoverageDetail LiabilityCoverageDetailadsvdf = new ShipItFedExShipmentService.LiabilityCoverageDetail();
        String CoverageType = LiabilityCoverageDetailadsvdf.CoverageType;
        ShipItFedExShipmentService.Money CoverageAmount = LiabilityCoverageDetailadsvdf.CoverageAmount;
        
        ShipItFedExShipmentService.HoldAtLocationDetail HoldAtLocationDetail = new ShipItFedExShipmentService.HoldAtLocationDetail();
        String PhoneNumber = HoldAtLocationDetail.PhoneNumber;
        ShipItFedExShipmentService.ContactAndAddress LocationContactAndAddress = HoldAtLocationDetail.LocationContactAndAddress;
        String LocationType = HoldAtLocationDetail.LocationType;
        
        ShipItFedExShipmentService.HomeDeliveryPremiumDetail HomeDeliveryPremiumDetail = new ShipItFedExShipmentService.HomeDeliveryPremiumDetail();
        String HomeDeliveryPremiumType = HomeDeliveryPremiumDetail.HomeDeliveryPremiumType;
        Date Date_x = HomeDeliveryPremiumDetail.Date_x;
        String PhoneNumberadsfvd = HomeDeliveryPremiumDetail.PhoneNumber;
        
        ShipItFedExShipmentService.AdditionalLabelsDetail AdditionalLabelsDetail = new ShipItFedExShipmentService.AdditionalLabelsDetail();
        String Type_xasvdf = AdditionalLabelsDetail.Type_x;
        Integer Countzcsvdf = AdditionalLabelsDetail.Count;
        
        ShipItFedExShipmentService.CustomLabelPosition CustomLabelPosition = new ShipItFedExShipmentService.CustomLabelPosition();
        Integer X = CustomLabelPosition.X;
        Integer Y = CustomLabelPosition.Y;
        
        ShipItFedExShipmentService.ValidatedHazardousContainer ValidatedHazardousContainer = new ShipItFedExShipmentService.ValidatedHazardousContainer();
        Decimal QValue = ValidatedHazardousContainer.QValue;
        ShipItFedExShipmentService.ValidatedHazardousCommodityContent[] HazardousCommoditieszsfdvgfb = ValidatedHazardousContainer.HazardousCommodities;
        
        ShipItFedExShipmentService.DateRange DateRange = new ShipItFedExShipmentService.DateRange();
        Date Begins = DateRange.Begins;
        Date Ends = DateRange.Ends;
        
        ShipItFedExShipmentService.FreightRateNotation FreightRateNotation = new ShipItFedExShipmentService.FreightRateNotation();
        String Code = FreightRateNotation.Code;
        String Descriptionscvdbfxd = FreightRateNotation.Description;
        
        ShipItFedExShipmentService.CustomLabelBarcodeEntry CustomLabelBarcodeEntry = new ShipItFedExShipmentService.CustomLabelBarcodeEntry();
        ShipItFedExShipmentService.CustomLabelPosition Positionaasvdf = CustomLabelBarcodeEntry.Position;
        String Formatscvdf = CustomLabelBarcodeEntry.Format;
        String[] DataFields = CustomLabelBarcodeEntry.DataFields;
        Integer BarHeight = CustomLabelBarcodeEntry.BarHeight;
        Integer ThinBarWidth = CustomLabelBarcodeEntry.ThinBarWidth;
        String BarcodeSymbology = CustomLabelBarcodeEntry.BarcodeSymbology;
        
        ShipItFedExShipmentService.ReturnAssociationDetail ReturnAssociationDetail = new ShipItFedExShipmentService.ReturnAssociationDetail();
        String TrackingNumber = ReturnAssociationDetail.TrackingNumber;
        Date ShipDate = ReturnAssociationDetail.ShipDate;
        
        ShipItFedExShipmentService.ShipmentDryIceDetail ShipmentDryIceDetail = new ShipItFedExShipmentService.ShipmentDryIceDetail();
        Integer PackageCount = ShipmentDryIceDetail.PackageCount;
        ShipItFedExShipmentService.Weight TotalWeight = ShipmentDryIceDetail.TotalWeight;
        
        ShipItFedExShipmentService.DocTabContentZone001 DocTabContentZone001 = new ShipItFedExShipmentService.DocTabContentZone001();
        ShipItFedExShipmentService.DocTabZoneSpecification[] DocTabZoneSpecifications = DocTabContentZone001.DocTabZoneSpecifications;
        
        ShipItFedExShipmentService.EMailLabelDetail EMailLabelDetail = new ShipItFedExShipmentService.EMailLabelDetail();
        String Message = EMailLabelDetail.Message;
        ShipItFedExShipmentService.EMailRecipient[] Recipients = EMailLabelDetail.Recipients;
        
        ShipItFedExShipmentService.RegulatoryLabelContentDetail RegulatoryLabelContentDetail = new ShipItFedExShipmentService.RegulatoryLabelContentDetail();
        String Type_xasfvdbf = RegulatoryLabelContentDetail.Type_x;
        String[] GenerationOptionssvdbf = RegulatoryLabelContentDetail.GenerationOptions;
        
        ShipItFedExShipmentService.RecommendedDocumentSpecification RecommendedDocumentSpecification = new ShipItFedExShipmentService.RecommendedDocumentSpecification();
        String[] Typessvdbf = RecommendedDocumentSpecification.Types;
        
        ShipItFedExShipmentService.HazardousCommodityPackagingDetail HazardousCommodityPackagingDetail = new ShipItFedExShipmentService.HazardousCommodityPackagingDetail();
        Integer Countsfvdbf = HazardousCommodityPackagingDetail.Count;
        String Unitssfdgf = HazardousCommodityPackagingDetail.Units;
        
        ShipItFedExShipmentService.RadionuclideActivity RadionuclideActivity = new ShipItFedExShipmentService.RadionuclideActivity();
        Decimal Valueaadsfdgf = RadionuclideActivity.Value;
        String UnitOfMeasure = RadionuclideActivity.UnitOfMeasure;
        
        ShipItFedExShipmentService.DocTabContentBarcoded DocTabContentBarcoded = new ShipItFedExShipmentService.DocTabContentBarcoded();
        String Symbology = DocTabContentBarcoded.Symbology;
        ShipItFedExShipmentService.DocTabZoneSpecification Specification = DocTabContentBarcoded.Specification;
        
        ShipItFedExShipmentService.SignatureOptionDetail SignatureOptionDetailsfdfb = new ShipItFedExShipmentService.SignatureOptionDetail();
        String OptionType = SignatureOptionDetailsfdfb.OptionType;
        String SignatureReleaseNumber = SignatureOptionDetailsfdfb.SignatureReleaseNumber;
        
        ShipItFedExShipmentService.CompletedHazardousSummaryDetail CompletedHazardousSummaryDetail = new ShipItFedExShipmentService.CompletedHazardousSummaryDetail();
        Integer SmallQuantityExceptionPackageCount = CompletedHazardousSummaryDetail.SmallQuantityExceptionPackageCount; 
        
        ShipItFedExShipmentService.CurrencyExchangeRate CurrencyExchangeRatesdfdgf = new ShipItFedExShipmentService.CurrencyExchangeRate();
        String FromCurrency = CurrencyExchangeRatesdfdgf.FromCurrency;
        String IntoCurrency = CurrencyExchangeRatesdfdgf.IntoCurrency;
        Decimal Rate = CurrencyExchangeRatesdfdgf.Rate;
        
        ShipItFedExShipmentService.CompletedSmartPostDetail CompletedSmartPostDetail = new ShipItFedExShipmentService.CompletedSmartPostDetail();
        String PickUpCarrier = CompletedSmartPostDetail.PickUpCarrier;
        Boolean Machinable = CompletedSmartPostDetail.Machinable;
        
        ShipItFedExShipmentService.LinearMeasure LinearMeasure = new ShipItFedExShipmentService.LinearMeasure();
        Decimal Valuesfdgfh = LinearMeasure.Value;
        String Unitssfdgfhg = LinearMeasure.Units;
        
        ShipItFedExShipmentService.DangerousGoodsShippersDeclarationDetail DangerousGoodsShippersDeclarationDetailsfdgfsdfd = new ShipItFedExShipmentService.DangerousGoodsShippersDeclarationDetail();
        ShipItFedExShipmentService.ShippingDocumentFormat Formatsfdg = DangerousGoodsShippersDeclarationDetailsfdgfsdfd.Format;
        ShipItFedExShipmentService.CustomerImageUsage[] CustomerImageUsagessdfdg = DangerousGoodsShippersDeclarationDetailsfdgfsdfd.CustomerImageUsages;
        
        ShipItFedExShipmentService.PendingShipmentAccessDetail PendingShipmentAccessDetail = new ShipItFedExShipmentService.PendingShipmentAccessDetail();
        ShipItFedExShipmentService.PendingShipmentAccessorDetail[] AccessorDetails = PendingShipmentAccessDetail.AccessorDetails;
        
        ShipItFedExShipmentService.CustomLabelBoxEntry CustomLabelBoxEntry = new ShipItFedExShipmentService.CustomLabelBoxEntry();
        ShipItFedExShipmentService.CustomLabelPosition TopLeftCorner = CustomLabelBoxEntry.TopLeftCorner;
        ShipItFedExShipmentService.CustomLabelPosition BottomRightCorner = CustomLabelBoxEntry.BottomRightCorner;
        
        ShipItFedExShipmentService.NaftaProducer NaftaProducer = new ShipItFedExShipmentService.NaftaProducer();
        String Idsdfdgf = NaftaProducer.Id;
        ShipItFedExShipmentService.Party Producersfdgf = NaftaProducer.Producer;
        
        ShipItFedExShipmentService.DeliveryOnInvoiceAcceptanceDetail DeliveryOnInvoiceAcceptanceDetail = new ShipItFedExShipmentService.DeliveryOnInvoiceAcceptanceDetail();
        ShipItFedExShipmentService.Party Recipient = DeliveryOnInvoiceAcceptanceDetail.Recipient;
        ShipItFedExShipmentService.TrackingId TrackingIdadsfdg = DeliveryOnInvoiceAcceptanceDetail.TrackingId;
        
        ShipItFedExShipmentService.RecipientCustomsId RecipientCustomsIdadsfdgf = new ShipItFedExShipmentService.RecipientCustomsId();
		String Type_xsfdgfhg = RecipientCustomsIdadsfdgf.Type_x;
        String Valuesfdgfhsdfdf = RecipientCustomsIdadsfdgf.Value;
        
        ShipItFedExShipmentService.CustomerImageUsage CustomerImageUsage = new ShipItFedExShipmentService.CustomerImageUsage();
        String Type_xsfdgfhgdf = CustomerImageUsage.Type_x;
        String Idsfdgfg = CustomerImageUsage.Id;
        
        ShipItFedExShipmentService.ContactAndAddress ContactAndAddress = new ShipItFedExShipmentService.ContactAndAddress();
        ShipItFedExShipmentService.Contact Contact = ContactAndAddress.Contact;
        ShipItFedExShipmentService.Address Addressdsfdgfhg = ContactAndAddress.Address;
        
        ShipItFedExShipmentService.Rma Rmasfdgfhgh = new ShipItFedExShipmentService.Rma();
        String Reason = Rmasfdgfhgh.Reason;
        
        ShipItFedExShipmentService.CustomsOptionDetail CustomsOptionDetail = new ShipItFedExShipmentService.CustomsOptionDetail();
        String Type_xsfdgf = CustomsOptionDetail.Type_x;
        String Descriptionsfdgfhgjh = CustomsOptionDetail.Description;
        
        ShipItFedExShipmentService.ValidateShipmentRequest ValidateShipmentRequest = new ShipItFedExShipmentService.ValidateShipmentRequest();
        ShipItFedExShipmentService.WebAuthenticationDetail WebAuthenticationDetailsfdfsfdgf = ValidateShipmentRequest.WebAuthenticationDetail;
        ShipItFedExShipmentService.ClientDetail ClientDetailsfdgfg = ValidateShipmentRequest.ClientDetail;
        ShipItFedExShipmentService.TransactionDetail TransactionDetailsfdgfhgh = ValidateShipmentRequest.TransactionDetail;
        ShipItFedExShipmentService.VersionId Versionsfdgfhgh = ValidateShipmentRequest.Version;
        ShipItFedExShipmentService.RequestedShipment RequestedShipmentsdfdgfhg = ValidateShipmentRequest.RequestedShipment;
        
        ShipItFedExShipmentService.EmailOptionsRequested EmailOptionsRequested = new ShipItFedExShipmentService.EmailOptionsRequested();
        String[] Optionsadsfdgfhg = EmailOptionsRequested.Options;
        
        ShipItFedExShipmentService.HazardousCommodityQuantityDetail HazardousCommodityQuantityDetail = new ShipItFedExShipmentService.HazardousCommodityQuantityDetail();
        Decimal Amountzzsfdgfhg = HazardousCommodityQuantityDetail.Amount;
        String Unitssdfdegrfthg = HazardousCommodityQuantityDetail.Units;
        String QuantityTypesdfdgfhg = HazardousCommodityQuantityDetail.QuantityType;
        
        ShipItFedExShipmentService.ReturnInstructionsDetail ReturnInstructionsDetailasfdvgf = new ShipItFedExShipmentService.ReturnInstructionsDetail();
        ShipItFedExShipmentService.ShippingDocumentFormat Formatadsfdvgf = ReturnInstructionsDetailasfdvgf.Format;
        String CustomText = ReturnInstructionsDetailasfdvgf.CustomText;
        
        ShipItFedExShipmentService.ValidatedHazardousCommodityContent ValidatedHazardousCommodityContent = new ShipItFedExShipmentService.ValidatedHazardousCommodityContent();
        ShipItFedExShipmentService.ValidatedHazardousCommodityDescription Descriptionsfdgfhg = ValidatedHazardousCommodityContent.Description;
        ShipItFedExShipmentService.HazardousCommodityQuantityDetail Quantitysdfghg = ValidatedHazardousCommodityContent.Quantity;
        Decimal MassPointssfdgfhg = ValidatedHazardousCommodityContent.MassPoints;
        ShipItFedExShipmentService.HazardousCommodityOptionDetail Optionssdvfbg = ValidatedHazardousCommodityContent.Options;
        
        ShipItFedExShipmentService.CodReturnPackageDetail CodReturnPackageDetail = new ShipItFedExShipmentService.CodReturnPackageDetail();
        ShipItFedExShipmentService.Money CollectionAmountzzsfdvgf = CodReturnPackageDetail.CollectionAmount;
        String AdjustmentTypeasdfdgfh = CodReturnPackageDetail.AdjustmentType;
        Boolean Electronicsfdgfhg = CodReturnPackageDetail.Electronic;
        ShipItFedExShipmentService.PackageBarcodes Barcodessdfdgf = CodReturnPackageDetail.Barcodes;
        ShipItFedExShipmentService.ShippingDocument Labeladfdgfh = CodReturnPackageDetail.Label;
        
        ShipItFedExShipmentService.StringBarcode StringBarcode = new ShipItFedExShipmentService.StringBarcode();
        String Type_xdsfdgfg = StringBarcode.Type_x;
        String Valuedsfdgfhg = StringBarcode.Value;
        
        ShipItFedExShipmentService.NaftaCommodityDetail NaftaCommodityDetail = new ShipItFedExShipmentService.NaftaCommodityDetail();
        String PreferenceCriterion = NaftaCommodityDetail.PreferenceCriterion;
        String ProducerDetermination = NaftaCommodityDetail.ProducerDetermination;
        String ProducerId = NaftaCommodityDetail.ProducerId;
        String NetCostMethod = NaftaCommodityDetail.NetCostMethod;
        ShipItFedExShipmentService.DateRange NetCostDateRange= NaftaCommodityDetail.NetCostDateRange;
        
        ShipItFedExShipmentService.DocTabContent DocTabContentadsfdgfh = new ShipItFedExShipmentService.DocTabContent();
        String DocTabContentType = DocTabContentadsfdgfh.DocTabContentType;
        ShipItFedExShipmentService.DocTabContentZone001 Zone001 = DocTabContentadsfdgfh.Zone001;
        ShipItFedExShipmentService.DocTabContentBarcoded Barcoded = DocTabContentadsfdgfh.Barcoded;
        
        try{
            ShipItFedExShipmentService.ShipServicePort ShipServicePort = new ShipItFedExShipmentService.ShipServicePort();
            ShipItFedExShipmentService.ShipmentReply shReply = ShipServicePort.validateShipment(WebAuthenticationDetail, ClientDetail, TransactionDetail, VersionId, new ShipItFedExShipmentService.RequestedShipment());
        }catch(Exception e){}
        return processReply;
    }
}