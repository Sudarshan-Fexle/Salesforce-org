/**
 *	Purpose			:	This class is to hold all teh field's propertues for Shipmenyt object.
 * 
 * 	Created By		:	Bhavi Sharma
 * 
 * 	Created Date	:	03/25/2015
 * 
 * Revision Logs	:	V_1.0 - Created
 *
 **/ 
public without sharing class ShipmentWrapper {
	
	//Properties
	public String AcceptBillingAgreement {get; set;}
	public Boolean AddDefaultInsurance {get; set;}
	public String AddressValidation {get; set;}
	public String AuthorizationReason {get; set;}
	public DateTime AuthorizationRequestDate {get; set;}
	public String AuthorizationRequestedFrom {get; set;}
	public DateTime AuthorizationResponseDate {get; set;}
	public String AuthorizationStatus {get; set;}
	public String AuthorizedBy {get; set;}
    public String AddressClassification{get;set;}
	public String BillingBatchId {get; set;}
	public String BillingStatus {get; set;}
	public String BillingType {get; set;}
	public String BillTo {get; set;}
	public Decimal DeclaredValue {get; set;}
    public DateTime DeliveryDate {get; set;}
	public DateTime DeliveryDateActual {get; set;}
    public String DeliveryDateText{get;set;}
    public String DeliveryServiceDescription{get;set;}
    public Boolean DeliveryIneligibleForGuarantee{get;set;}
	public String EDIBatchId {get; set;}
	public Boolean HoldShipmentatFedExLocation {get; set;}
	public Decimal InsuranceAmount {get; set;}
	public Datetime LabelPrintedDate {get; set;}
	public String PackageCode {get; set;}
	public Decimal PackageDepth {get; set;}
	public Decimal PackageLength {get; set;}
	public String PackageType {get; set;}
	public Decimal PackageWidth {get; set;}
	public Boolean PersonalBilling {get; set;}
	public String Recipient {get; set;}
	public String RecipientAddressLine1 {get; set;}
	public String RecipientAddressLine2 {get; set;}
	public String RecipientCity {get; set;}
	public String RecipientCompany {get; set;}
	public String RecipientEmail {get; set;}
	public String RecipientFirstName {get; set;}
	public String RecipientLastName {get; set;}
	public String RecipientName {get; set;}
	public String RecipientPhone {get; set;}
	public String RecipientPostalCode {get; set;}
	public String RecipientSelectionMethod {get; set;}
	public String RecipientStateOrProvince {get; set;}
    public String ReferenceId {get; set;}
	public String Sender {get; set;}
	public String SenderAddressLine1 {get; set;}
	public String SenderAddressLine2 {get; set;}
	public String SenderCity {get; set;}
	public String SenderCompany {get; set;}
	public String SenderCostCenter {get; set;}
	public String SenderDepartment {get; set;}
	public String SenderEmail {get; set;}
	public String SenderFinanceCode {get; set;}
	public String SenderFirstName {get; set;}
	public String SenderLastName {get; set;}
	public String SenderName {get; set;}
	public String SenderOfficeCode {get; set;}
	public String SenderOfficeName {get; set;}
	public String SenderPhone {get; set;}
	public String SenderPostalCode {get; set;}
	public String SenderSecondaryEmail {get; set;}
	public String SenderStateOrProvince {get; set;}
	public Decimal ShipAmount {get; set;}
	public Decimal ShipAmountActual {get; set;}
	public Date ShipDate {get; set;}
	public Date ShipDateActual {get; set;}
	public String ShipDay {get; set;}
	public String ShipmentOrigin {get; set;}
	public String ShipMethod {get; set;}
	public String ShipMethodCategory {get; set;}
	public String SignatureRequirement {get; set;}
	public String Stage {get; set;}
	public String Status {get; set;}
	public String TrackingNumber {get; set;}
	public Boolean VendorPackage {get; set;}
	public Decimal WeightActual {get; set;}
	public Decimal WeightEstimated {get; set;}
	public Shipment__c shipment {get; set;}
    public String id{get;set;}
    public String deliveryDateString{get;set;}
    public String deliveryTimeString{get;set;}
        
	//Constructor
	public ShipmentWrapper() {
		
	}
}