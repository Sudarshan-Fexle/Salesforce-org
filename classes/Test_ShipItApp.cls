/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 * 
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
/** 
  * Description     :   Test Class for Ship It App.   
  *
  * Created By      :   Rajeev Jain(Simplyforce)
  *
  * Created Date    :   03/10/2015
  *
  * Version         :   V1.0 Created
  * 				:	V1.1 Modifield By - Rajeev Jain 05/01/2015, CR-20150429-8921  Added test method to test from restircted profile user
  *					:	V1.1 Modifield By - Mahendra Swarnkar - 02/16/2016 - CR-20160104-9486.  
  * Code Coverage   :   
  **/   
@isTest(seeAllData = false)
public class Test_ShipItApp {
	
    static void setupUserAndCommonData(){
        
        //Added By - Mahendra Swarnkar- CR-20160315-9697 - 3/30/2016 - Starts from here 
        //Pull the current user record from system and check if address or phone is null, update user with test values
        User currentUser = [Select Street, City, State, PostalCode, Country, Phone from User where Id =: UserInfo.getUserId()];
        if(String.isBlank(currentUser.Street) || String.isBlank(currentUser.City) 
            || String.isBlank(currentUser.State) || String.isBlank(currentUser.PostalCode) 
            || String.isBlank(currentUser.Country) || String.isBlank(currentUser.Phone)) {
            currentUser.Street = '2445 M Street';
            currentUser.City = 'Washington';
            currentUser.State = 'DC';
            currentUser.PostalCode = '20037';
            currentUser.Country = 'USA';
            currentUser.Phone = '202-266-569';
            Util.BypassAllTriggers = true;
            update currentUser;
            Util.BypassAllTriggers = false;
        }
        //Added By - Mahendra Swarnkar- CR-20160315-9697 - 3/30/2016 - Ends here
        
        //Query to get System admin Profile
    	List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];   
        
        //CR-20150429-8921 Added new user for restricted profile and test with it.
		//Rajeev Jain - Changed the profile - SFDC Dev Contractor to Delivery Business Analyst - Restricted
        List<Profile> restrictedProfiles = [SELECT Id FROM Profile WHERE Name = 'Delivery Business Analyst - Restricted'];    
        
        //List to hold Restri
        //User Insert
        List<User> userList = new List<User>();
        
        userList.add(new User(Username = math.random()+'@testorg.com',
                            ProfileId = profiles[0].Id, IsActive=true,
                            Alias = 'test',Email = 'testing@example.com',EmailEncodingKey='UTF-8', 
                            LastName='Test Contact User',LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',
							Job_Level_Code__c = 300));
                           
        userList.add(new User(Username = math.random()+'@testorg.com',
                            ProfileId = profiles[0].Id, IsActive=true,
                            Alias = 'test',Email = 'testing@example.com',EmailEncodingKey='UTF-8', 
                            LastName='Test Contact User',LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',
                            Job_Level_Code__c = 403));
		userList.add(new User(Username = math.random()+'@testorg.com',
                            ProfileId = restrictedProfiles[0].Id, IsActive=true,
                            Alias = 'test',Email = 'testing@example.com',EmailEncodingKey='UTF-8', 
                            LastName='Test User Restricted Profile',LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',
                            Job_Level_Code__c = 403));
        insert userList;
        
        //Insert Account as a Company or Institution
        Account acc = new Account();
        acc.Name = 'Test Account -123';
        acc.Account_Formal_Name__c = 'Test Account - 123'   ;
        acc.Status__c = 'Active';
        insert acc;
        
        //Insert contacts
		Contact newContact = new Contact();
                newContact.FirstName = 'Test';
                newContact.LastName = 'Contact';
                newContact.Primary_Address_Line_1__c = '2445 M St NW';
                newContact.Primary_Address_Line_2__c = 'Suite 600';
        		newContact.Primary_Address_Line_3__c = 'blah blah blah';
                newContact.Primary_City__c = 'Washington';
                newContact.Primary_State_Province__c = 'DC';
                newContact.Primary_Country__c = 'United States';
                newContact.Primary_Postal_Code__c = '20001';
				newContact.Email = 'Test'+Math.random()+'@eab.com';
				newContact.Title = 'Test';
				newContact.Phone = '614-555-8855';
                newContact.AccountId = acc.Id;
        
        //Insert Contact
        insert newContact;
        
        //Insert Ship It Custom Setting
        List<ShipIt_PackageType__c> shipItPackageTypeList = new List<ShipIt_PackageType__c>();	
        shipItPackageTypeList.add(new ShipIt_PackageType__c(Name = 'FEDEX_ENVELOPE', Active__c = true, 
                                                            Package_Description__c = '', 
                                                            Package_Full_Name__c = 'FedEx Envelope' , 
                                                            Package_Image__c = 'img/fedex_envelope.png', 
                                                            Is_Custom__c = false, Weight_Limit__c = 0.5, 
                                                            Default_Dimension__c = ''));
        shipItPackageTypeList.add(new ShipIt_PackageType__c(Name = 'FEDEX_EXTRA_ LARGE_BOX', Active__c = true, 
                                                            Package_Description__c = '', 
                                                            Package_Full_Name__c = 'FedEx Extra Large Box', 
                                                            Package_Image__c = 'img/fedex_extra_large_box.png', 
                                                            Is_Custom__c = false, Weight_Limit__c = 20.0, 
                                                            Default_Dimension__c = ''));
        shipItPackageTypeList.add(new ShipIt_PackageType__c(Name = 'FEDEX_LARGE_ BOX', Active__c = true, 
                                                            Package_Description__c = '', 
                                                            Package_Full_Name__c = 'FedEx Large Box' , 
                                                            Package_Image__c = 'img/fedex_large_box.png', 
                                                            Is_Custom__c = false, Weight_Limit__c = 20.0, 
                                                            Default_Dimension__c = ''));
        shipItPackageTypeList.add(new ShipIt_PackageType__c(Name = 'FEDEX_MEDIUM _BOX', Active__c = true, 
                                                            Package_Description__c = '', 
                                                            Package_Full_Name__c = 'FedEx Medium Box' , 
                                                            Package_Image__c = 'img/fedex_medium_box.png', 
                                                            Is_Custom__c = false, Weight_Limit__c = 20.0, 
                                                            Default_Dimension__c = ''));
        shipItPackageTypeList.add(new ShipIt_PackageType__c(Name = 'FEDEX_PAK', Active__c = true, 
                                                            Package_Description__c = '', 
                                                            Package_Full_Name__c = 'FedEx Pak' , 
                                                            Package_Image__c = 'img/fedex_pak.png', 
                                                            Is_Custom__c = false, Weight_Limit__c = 20.0, 
                                                            Default_Dimension__c = ''));
        shipItPackageTypeList.add(new ShipIt_PackageType__c(Name = 'FEDEX_SMALL_ BOX', Active__c = true, 
                                                            Package_Description__c = '', 
                                                            Package_Full_Name__c = 'FedEx Small Box' , 
                                                            Package_Image__c = 'img/fedex_small_box.png', 
                                                            Is_Custom__c = false, Weight_Limit__c = 20.0, 
                                                            Default_Dimension__c = ''));
        shipItPackageTypeList.add(new ShipIt_PackageType__c(Name = 'FEDEX_TUBE', Active__c = true, 
                                                            Package_Description__c = '', 
                                                            Package_Full_Name__c = 'FedEx Tube' , 
                                                            Package_Image__c = 'img/fedex_tube.png', 
                                                            Is_Custom__c = false, Weight_Limit__c = 20.0, 
                                                            Default_Dimension__c = ''));
        shipItPackageTypeList.add(new ShipIt_PackageType__c(Name = 'YOUR_PACKAGING', Active__c = true, 
                                                            Package_Description__c = '', 
                                                            Package_Full_Name__c = 'Your Package' , 
                                                            Package_Image__c = 'img/your_packaging.png', 
                                                            Is_Custom__c = true, Weight_Limit__c = 150.0, 
                                                            Default_Dimension__c = '17x11x8'));
        insert shipItPackageTypeList;
        
        //Insert Ship it Custom Setting
        List<ShipIt_Settings__c> shipItSettingList = new List<ShipIt_Settings__c>();
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'AccountNumber' , value__c = '20080175'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'AddrNormalizeAccept' , value__c = 'Normalized/Accepted'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'AddrNormalizeDecline' , value__c = 'Normalized/Declined'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'AddrResolvedAcceptValue' , value__c = 'Resolved/Accepted'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'AddrResolvedDeclineValue' , value__c = 'Resolved/Declined'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'AddrResolvedUpdateValue' , value__c = 'Resolved/Updated'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'AddrValidValue' , value__c = 'Passed'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'AddrWarningValue' , value__c = 'Warning/Declined'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'CityStateValidated' , value__c = 'City / State Validation'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'ContactSearchLimit' , value__c = '250'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'CustomerReferenceType' , value__c = 'CUSTOMER_REFERENCE'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'DefaultInsurance' , value__c = '100'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'DimensionUnits' , value__c = 'IN'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'DropoffType' , value__c = 'REGULAR_PICKUP'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'EmailNoticeFormat' , value__c = 'HTML'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'EmailNoticeMessage' , value__c = ''));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'EmailNoticeServiceType' , value__c = 'EMAIL_NOTIFICATION'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'EmailNotice_R_P_Delivery' , value__c = 'FALSE'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'EmailNotice_R_P_Exception' , value__c = 'FALSE'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'EmailNotice_R_P_Shipment' , value__c = 'FALSE'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'EmailNotice_R_P_Tender' , value__c = 'FALSE'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'EmailNotice_S_P_Delivery' , value__c = 'TRUE'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'EmailNotice_S_P_Exception' , value__c = 'TRUE'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'EmailNotice_S_P_Shipment' , value__c = 'TRUE'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'EmailNotice_S_P_Tender' , value__c = 'TRUE'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'EmailNotice_S_S_Delivery' , value__c = 'TRUE'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'EmailNotice_S_S_Exception' , value__c = 'TRUE'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'EmailNotice_S_S_Shipment' , value__c = 'TRUE'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'EmailNotice_S_S_Tender' , value__c = 'TRUE'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'FAQpageURL' , value__c = ''));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'FedExEndPointAddressValidation' , value__c = 'https://ws.fedex.com:443/web-services/addressvalidation'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'FedExEndPointRateService' , value__c = 'https://ws.fedex.com:443/web-services/rate'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'FedExEndPointShipService' , value__c = 'https://ws.fedex.com:443/web-services/ship'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'FedExTrackingURL' , value__c = 'https://www.fedex.com/apps/fedextrack/?action=track&cntry_code=us&trackingnumber'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'InvalidSuiteNumber' , value__c = 'Suite Number Validation'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'Key' , value__c = 'VFY4PJUerd8JYt8e'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'LabelFormatType' , value__c = 'COMMON2D'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'LabelImageType' , value__c = 'PDF'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'LabelStockType' , value__c = 'PAPER_LETTER'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'MeterNumber' , value__c = '107754347'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'Password' , value__c = 'Necu5S89TKAQuHjSIYeZ7BBOY'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'PaymentType' , value__c = 'SENDER'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'PostalValidated' , value__c = 'Postal Code Validation'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'RateRequestType' , value__c = 'NONE'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'RecipientCountryCode' , value__c = 'US'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'RecipientPrimaryEmailTip' , value__c = 'Does not receive email notifications'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'Resolved' , value__c = 'Resolved'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'ReturnTransitAndCommit' , value__c = 'TRUE'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'SearchKeywordsTip' , value__c = 'Search against Sender Name, Recipient Name, and Recipient Company Name'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'SenderCompanyName' , value__c = 'The Advisory Board Company'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'SenderCountryCode' , value__c = 'US'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'SenderPrimaryEmailTip' , value__c = 'Receive Notifications on Pickup, Shipment, Delivery, and/or Exception events'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'SenderSecondaryEmailTip' , value__c = 'Receive Notifications on Pickup, Shipment, Delivery, and/or Exception events'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'ServiceTypeCode_E' , value__c = 'Express'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'ServiceTypeCode_F' , value__c = 'Freight'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'ServiceTypeCode_G' , value__c = 'Ground'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'ServiceTypeCode_S' , value__c = 'SmartPost'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'ShipCategoryAuthorization' , value__c = 'Alternate'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'ShipCategoryPersonal' , value__c = 'Personal'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'ShipCategoryStandard' , value__c = 'Standard'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'ShipmentSearchLimit' , value__c = '250'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'ShipmentTime' , value__c = '17'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'ShipMethodRecommend' , value__c = 'FEDEX_2_DAY'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'SignOption_Adult' , value__c = 'ADULT'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'SignOption_Direct' , value__c = 'DIRECT'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'SignOption_Indirect' , value__c = 'INDIRECT'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'SignOption_None' , value__c = 'NO_SIGNATURE_REQUIRED'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'StreetRangeValidated' , value__c = 'Street Number Validation'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'StreetValidated' , value__c = 'Street Address Validation'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'TestAccountNumber' , value__c = '510087844'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'TestFedExEndPointAddressValidation' , value__c = 'https://wsbeta.fedex.com:443/web-services/addressvalidation'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'TestFedExEndPointRateService' , value__c = 'https://wsbeta.fedex.com:443/web-services/rate'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'TestFedExEndPointShipService' , value__c = 'https://wsbeta.fedex.com:443/web-services/ship'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'TestKey' , value__c = 'MdacUTU1QUNtEjhJ'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'TestMeterNumber' , value__c = '118670629'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'TestPassword' , value__c = 'TyUUJtlCnEhs2HEbnisghybDO'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'UseProductionFedExCredentials' , value__c = 'TRUE'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'VersionIntermediate' , value__c = '0'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'VersionIntermediateRateService' , value__c = '0'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'VersionIntermediateShipService' , value__c = '0'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'VersionMajor' , value__c = '3'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'VersionMajorRateService' , value__c = '16'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'VersionMajorShipService' , value__c = '15'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'VersionMinor' , value__c = '0'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'VersionMinorRateService' , value__c = '0'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'VersionMinorShipService' , value__c = '0'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'VersionServiceId' , value__c = 'aval'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'VersionServiceIdRateService' , value__c = 'crs'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'VersionServiceIdShipService' , value__c = 'ship'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'WeightUnits' ,value__c = 'LB'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'WebServiceLogRecordType' ,value__c = '012L00000000iPk'));
        
        //Rajeev Jain - 12/08/2017 - Added additional custom setting data for Production Failure fix - CR-20171019-11731
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'TestKey_EAB' ,value__c = 'nF1kn3sOaK6tp3AI'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'TestPassword_EAB' ,value__c = 'kwDzbC7vaktUoVJWkcRcFzPvF'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'TestAccountNumber_EAB' ,value__c = '510087100'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'TestMeterNumber_EAB' ,value__c = '118980587'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'Key_EAB' ,value__c = 'VFY4PJUerd8JYt8e'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'Password_EAB' ,value__c = 'Necu5S89TKAQuHjSIYeZ7BBOY'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'AccountNumber_EAB' ,value__c = '020080175'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'MeterNumber_EAB' ,value__c = '107754347'));
        shipItSettingList.add(new ShipIt_Settings__c(Name = 'SenderCompanyName_EAB' ,value__c = 'EAB'));
        
		insert shipItSettingList;
        
        List<ShipIt_ShipMethod__c> shipItMethodList = new List<ShipIt_ShipMethod__c>();
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'EUROPE_FIRST_INTERNATIO NAL_PRIORITY', Display_Name__c = 'Europe First International Priority', Authorization_Required__c = FALSE, Department_Standard__c = FALSE, Personal__c = FALSE , Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'FEDEX_1_DAY_FREIGHT',  Display_Name__c = 'FedEx 1 Day Freight', Authorization_Required__c = FALSE, Department_Standard__c = FALSE, Personal__c = FALSE, Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'FEDEX_2_DAY',  Display_Name__c = 'FedEx 2 Day', Authorization_Required__c = TRUE, Department_Standard__c = TRUE, Personal__c = TRUE,
                                                     A1__c = '4:30 PM', A2__c = '4:30 PM', A3__c = '4:30 PM', A4__c = '4:30 PM', A5__c = '4:30 PM', A6__c = '4:30 PM', A7__c = '4:30 PM', A8__c = '4:30 PM', A9__c = '4:30 PM',
                                                     AA__c = '4:30 PM', AM__c = '4:30 PM', AT__c = '3 Business Days by 5pm', PM__c = '4:30 PM', RM__c = '4:30 PM', Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'FEDEX_2_DAY_AM',  Display_Name__c = 'FedEx 2 Day AM', Authorization_Required__c = TRUE, Department_Standard__c = TRUE, Personal__c = TRUE,
                                                     A1__c = '10:30 AM', A2__c = '10:30 AM', A3__c = '12:00 PM', A4__c = '10:30 AM', A5__c = '12:00 PM', A6__c = '', A7__c = '10:30 AM', A8__c = '12:00 PM', A9__c = '',
                                                     AA__c = '10:30 AM', AM__c = '12:00 PM', AT__c = '', PM__c = '', RM__c = '', Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'FEDEX_2_DAY_FREIGHT',  Display_Name__c = 'FedEx 2 Day Freight', Authorization_Required__c = FALSE, Department_Standard__c = FALSE, Personal__c = FALSE, Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'FEDEX_3_DAY_FREIGHT',  Display_Name__c = 'FedEx 3 Day Freight', Authorization_Required__c = FALSE, Department_Standard__c = FALSE, Personal__c = FALSE, Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'FEDEX_DISTANCE_DEFERRE D',  Display_Name__c = 'FedEx Distance Deferred', Authorization_Required__c = FALSE, Department_Standard__c = FALSE, Personal__c = TRUE, Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'FEDEX_EXPRESS_SAVER',  Display_Name__c = 'FedEx Express Saver', Authorization_Required__c = FALSE, Department_Standard__c = TRUE, Personal__c = TRUE,
                                                     A1__c = '4:30PM', A2__c = '4:30PM', A3__c = '4:30PM', A4__c = '4:30PM', A5__c = '4:30PM', A6__c = '4:30PM', A7__c = '4:30PM', A8__c = '4:30PM', A9__c = '4:30PM',
                                                     AA__c = '4:30PM', AM__c = '4:30PM', AT__c = '3 Business Days by 5pm', PM__c = '4:30PM', RM__c = '4:30PM', Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'FEDEX_FIRST_FREIGHT',  Display_Name__c = 'FedEx First Freight', Authorization_Required__c = FALSE, Department_Standard__c = FALSE, Personal__c = FALSE, Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'FEDEX_FREIGHT_ECONOMY',  Display_Name__c = 'FedEx Freight Economy', Authorization_Required__c = FALSE, Department_Standard__c = FALSE, Personal__c = FALSE, Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'FEDEX_FREIGHT_PRIORITY',  Display_Name__c = 'FedEx Freight Priority', Authorization_Required__c = FALSE, Department_Standard__c = FALSE, Personal__c = FALSE, Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'FEDEX_GROUND',  Display_Name__c = 'FedEx Ground', Authorization_Required__c = FALSE, Department_Standard__c = TRUE, Personal__c = TRUE, Brown_Box_Only__c = TRUE ));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'FEDEX_NEXT_DAY_AFTERN OON',  Display_Name__c = 'FedEx Next Day Afternoon', Authorization_Required__c = TRUE, Department_Standard__c = TRUE, Personal__c = TRUE, Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'FEDEX_NEXT_DAY_EARLY_M ORNING',  Display_Name__c = 'FedEx Next Day Early Morning', Authorization_Required__c = TRUE, Department_Standard__c = TRUE, Personal__c = TRUE, Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'FEDEX_NEXT_DAY_END_OF_ DAY',  Display_Name__c = 'FedEx Next Day End Of Day', Authorization_Required__c = TRUE, Department_Standard__c = TRUE, Personal__c = TRUE, Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'FEDEX_NEXT_DAY_FREIGHT',  Display_Name__c = 'FedEx Next Day Freight', Authorization_Required__c = FALSE, Department_Standard__c = FALSE, Personal__c = FALSE, Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'FEDEX_NEXT_DAY_MID_MO RNING',  Display_Name__c = 'FedEx Next Day Mid Morning', Authorization_Required__c = TRUE, Department_Standard__c = TRUE, Personal__c = TRUE, Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'FIRST_OVERNIGHT',  Display_Name__c = 'First Overnight', Authorization_Required__c = TRUE, Department_Standard__c = TRUE, Personal__c = TRUE,
                                                     A1__c = '8:00 AM', A2__c = '8:30 AM', A3__c = '8:30 AM', A4__c = '9:00 AM', A5__c = '10:00 AM', A6__c = '10:00 AM', A7__c = '9:30 AM', A8__c = '11:00 AM', A9__c = '12:00 PM', Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'GROUND_HOME_DELIVERY',  Display_Name__c = 'Ground Home Delivery', Authorization_Required__c = FALSE, Department_Standard__c = TRUE, Personal__c = TRUE, Brown_Box_Only__c = TRUE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'INTERNATIONAL_ECONOMY',  Display_Name__c = 'International Economy', Authorization_Required__c = FALSE, Department_Standard__c = FALSE, Personal__c = FALSE, Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'INTERNATIONAL_ECONOMY_ FREIGHT',  Display_Name__c = 'International Economy Freight', Authorization_Required__c = FALSE, Department_Standard__c = FALSE, Personal__c = FALSE, Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'INTERNATIONAL_FIRST',  Display_Name__c = 'International First', Authorization_Required__c = FALSE, Department_Standard__c = FALSE, Personal__c = FALSE, Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'INTERNATIONAL_PRIORITY',  Display_Name__c = 'International Priority', Authorization_Required__c = FALSE, Department_Standard__c = FALSE, Personal__c = FALSE, Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'INTERNATIONAL_PRIORITY_ FREIGHT',  Display_Name__c = 'International Priority Freight', Authorization_Required__c = FALSE, Department_Standard__c = FALSE, Personal__c = FALSE, Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'PRIORITY_OVERNIGHT',  Display_Name__c = 'Priority Overnight', Authorization_Required__c = TRUE, Department_Standard__c = TRUE, Personal__c = TRUE,
                                                      A1__c = '10:30 AM', A2__c = '10:30 AM', A3__c = '12:00 PM', A4__c = '10:30 AM', A5__c = '12:00 PM', A6__c = '4:30 PM', A7__c = '10:30 AM', A8__c = '12:00 PM', A9__c = '4:30 PM',
                                                     AA__c = '10:30 AM', AM__c = '12:00 PM', AT__c = '2 Business Days by Noon', PM__c = '4:30PM', RM__c = '4:30PM', Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'SAME_DAY',  Display_Name__c = 'Same Day', Authorization_Required__c = FALSE, Department_Standard__c = FALSE, Personal__c = TRUE, Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'SAME_DAY_CITY',  Display_Name__c = 'Same Day City', Authorization_Required__c = FALSE, Department_Standard__c = FALSE, Personal__c = TRUE, Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'SMART_POST',  Display_Name__c = 'Smart Post', Authorization_Required__c = FALSE, Department_Standard__c = FALSE, Personal__c = FALSE, Brown_Box_Only__c = FALSE));
        shipItMethodList.add(new ShipIt_ShipMethod__c(Name = 'STANDARD_OVERNIGHT', Display_Name__c = 'Standard Overnight', Authorization_Required__c = TRUE,Department_Standard__c = TRUE,Personal__c = TRUE, Brown_Box_Only__c = FALSE));
        
		insert shipItMethodList;
    }
    
    static List<Id> setupShipmentList(){
    	
        //Inserts Default Shipments 
        List<Shipment__c> shipmentsList = new List<Shipment__c>();
		shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Department', Bill_To__c = 'Department',
                                         Status__c = 'New',
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today().addDays(-2)));
        shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Department', Bill_To__c = 'Department',
                                         Status__c = 'New', 
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today().addDays(-2)));
        shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Department', Bill_To__c = 'Department',
                                         Status__c = 'New',
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today().addDays(-2)));
        shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Department', Bill_To__c = 'Department',
                                         Status__c = 'New',
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today().addDays(-2)));
        shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Department', Bill_To__c = 'Department',
                                         Status__c = 'New',
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today().addDays(-2)));
        shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Personal', Bill_To__c = 'Personal',
                                         Status__c = 'In Progress',
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today().addDays(-2)));
        shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Personal', Bill_To__c = 'Personal',
                                         Status__c = 'In Progress',
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today().addDays(-2)));
        shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Personal', Bill_To__c = 'Personal',
                                         Status__c = 'In Progress',
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today().addDays(-2)));
        shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Personal', Bill_To__c = 'Personal',
                                         Status__c = 'In Progress',
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today().addDays(-2)));
        shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Personal', Bill_To__c = 'Personal',
                                         Status__c = 'In Progress',
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today().addDays(-2)));
        shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Personal', Bill_To__c = 'Personal',
                                         Status__c = 'Pending Authorization',
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today()));
        shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Personal', Bill_To__c = 'Personal',
                                         Status__c = 'Pending Authorization',
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today()));
        shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Personal', Bill_To__c = 'Personal',
                                         Status__c = 'Pending Authorization',
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today()));
        shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Personal', Bill_To__c = 'Personal',
                                         Status__c = 'Pending Authorization',
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today()));
        shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Personal', Bill_To__c = 'Personal',
                                         Status__c = 'Pending Authorization',
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today()));
        shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Personal', Bill_To__c = 'Personal',
                                         Status__c = 'Shipped',
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today()));
        shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Personal', Bill_To__c = 'Personal',
                                         Status__c = 'Shipped',
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today()));
        shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Personal', Bill_To__c = 'Personal',
                                         Status__c = 'Shipped',
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today()));
        shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Personal', Bill_To__c = 'Personal',
                                         Status__c = 'Shipped',
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today()));
        shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Personal', Bill_To__c = 'Personal',
                                         Status__c = 'Shipped',
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today()));
        
        //Added By MAhendra Swarnakar - CR-20160104-9486 - 2/16/2016 - Starts from Here
		shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Personal', Bill_To__c = 'Personal',
                                         Status__c = 'Shipped',
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today(),
                                         Ship_Method__c = 'FEDEX_GROUND'));
        shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Department', Bill_To__c = 'Department',
                                         Status__c = 'New',
                                         Recipient_Company__c = 'Test Account 123',Ship_Method__c = 'FEDEX_GROUND',
                                         Ship_Date__c = Date.today().addDays(-2)));
        
        //Added By MAhendra Swarnakar - CR-20160104-9486 - 2/16/2016 - Ends Here
		insert shipmentsList;
        
        //List of Ids and Add to Fixed Search Result
        List<Id> fixedSearchResults = new List<Id>();
        
        //Loop over shipments List and add to the List
        for(Shipment__c sh : shipmentsList){
        	fixedSearchResults.add(sh.Id);    
        }
        return fixedSearchResults;
    }
    
    /**
     *  @description    :   These method is to test Address screen and select a Package functions
     *
     *  @args           :
     *
     *  @return         :   void
     *
     **/
    static testMethod void testshipAPackageComponentsFunctions() {
    	
        //Call Common Setup Method
        setupUserAndCommonData();
        
        //Start test from here 
        Test.startTest();
        
        //Don't Set URL Parameter 
        //Instantitate Controller
        ShipItController controller = new ShipItController();
        
        /** used to Check Asserts Reustls **/
        Boolean isInvalidContactId = controller.isInvalidContactId;
        System.assertEquals(false, isInvalidContactId);
        
        String appView = controller.appView;
        System.assertEquals('New', appView);
        
        String shipmentSelectionMethod = controller.shipmentWrapper.RecipientSelectionMethod;
        System.assertEquals('Manual Entry', shipmentSelectionMethod);
        
        Boolean isAddressVarified = controller.isAddressVerified;
        System.assertEquals(false, isAddressVarified);
        
        //Now set Blank Contact Id, there must be show error on the message for invlid contact Id
        Apexpages.currentPage().getParameters().put('contactId','');
        controller = new ShipItController();
        Boolean isInvalidContactId1 = controller.isInvalidContactId;
        
        System.assertEquals(true, isInvalidContactId1);
       
        //Verify and Continue
        controller.verifyAndContinueAddress();
        
        //varify Address when user leave blank address
        Boolean isAddressVarified1 = controller.isAddressVerified;
        System.assertEquals(false, isAddressVarified1);
        
        //Get Contact Id from Url Instantiate the Controller
        //Query on contact and pass Id in Url
        List<Contact> contacts = [select Id, Name from Contact];
        
        //Check the Size of the List	
        Apexpages.currentPage().getParameters().put('contactId',contacts[0].Id);
        
        controller = new ShipItController();
        
        System.assertEquals(contacts[0].Id, controller.recipientId);
        
        String shipmentSelectionMethod2 = controller.shipmentWrapper.RecipientSelectionMethod;
        System.assertEquals('Contact Record', shipmentSelectionMethod2);
        
        //Get Shipment Object and 
        ShipmentWrapper shipmentWrapperObj = controller.shipmentWrapper;
                
        //Set Status Required Attr
        ShipItFedExMockResponse.statusRequire = '';
        
        //Call verify Address Method
        controller.verifyAndContinueAddress();
        
        //Check if Address Has varified and check validation Status
        Boolean isAddressVerified2 = controller.isAddressVerified;
        String validationStatus = controller.validationStatus;
        System.assertEquals(true, isAddressVerified2);
        //System.assertEquals('No Change', validationStatus);
        
        ShipItFedExMockResponse.statusRequire = 'No Change1';
        controller.verifyAndContinueAddress();
        
        ShipItFedExMockResponse.statusRequire = 'Resolved';
        controller.verifyAndContinueAddress();
		String validationStatus1 = controller.validationStatus;
        //System.assertEquals('Resolved', validationStatus1);
        
        //Accept Suggested Address from FedEx
        controller.acceptUpdatesWithChange();
        String isAdressAccepted = controller.isAddressUpdateAccepted;
        Boolean isPopupDisplay = controller.isPopupDisplay;
        System.assertEquals('true', isAdressAccepted);
        System.assertEquals(false, isPopupDisplay);
        
        //Accept Suggested Address without change
        controller.acceptUpdatesWithoutChange();
        
        ShipItFedExMockResponse.statusRequire = 'Warning';
        controller.verifyAndContinueAddress();
        controller.reValidateAddressOnFedEx();
        
        //This time again revalidate
        ShipItFedExMockResponse.statusRequire = '';
        controller.reValidateAddressOnFedEx();
        
        controller.acceptYesAnswerFromUser();
        controller.verifyAndContinueAddress();
        
        //Keep Existing
        controller.keepExisting();
        Boolean keepExistingPopupDisplay = controller.isPopupDisplay;  
        //System.assertEquals(false, keepExistingPopupDisplay);
        
        //Keep Existing
        Boolean isAddVerified = controller.isAddressVerified;
        
        //Get BillingType List
        List<SelectOption> billingTypeList = controller.billToListItems;
        
        //Get Ship Date List Items
        List<SelectOption> shipDateListItems = controller.shipDateListItems;
        
        //Get List of Authorizers
        List<SelectOption> listOfAuthorizer = controller.listOfAuthorizers;
        
        //Get List of Signature Requirement
       	List<SelectOption> signatureRequirementList = controller.signatureRequirementList;
        
        System.assertEquals(true, billingTypeList.size()>0);
        System.assertEquals(true, shipDateListItems.size()>0);
        System.assertEquals(true, listOfAuthorizer.size()>0);
        System.assertEquals(true, signatureRequirementList.size()>0);
        
        //==================== Select one Package and Navigates to Package Details Screen ==========================
        controller.selectedPackageName = 'FEDEX_PAK';
        controller.describePackageDetails();
        
        //Get Selected Package Instance 
        ShipIt_PackageType__c selectedPackage = controller.selectedPackage;
        
        //Check if Package Selection is verified
        Boolean isPackageSelectionVerified = controller.isPackageSelectionVerified;
        
        //Populate Some Data on the Ship It order Screen and then Call Get Delivery options methods
        controller.selectedShipDate = Date.today() + '';
        controller.shipment.Bill_To__c = 'Personal';
        controller.getDeleveryOptions(); /** Asserts for this use case are pending **/
		
        //Save and Navigates to Review Screen
        controller.saveAndNavigatesToReviewScreen(); /** Asserts for this use case are pending **/
		
        //Send Authorization Request and Save Data 
        // Set SelectedAuthorizer for Authorizer Request to whom request would be send by email
        controller.selectedAuthorizer = listOfAuthorizer[0].getValue();
        
        //Send Authorization Request
        controller.sendAuthorizationRequest();
        
        //Authorize Request
        Apexpages.currentPage().getParameters().put('isAuthorized','true');
        
        //Atuhorize Request
        controller.authorizeRequest();
        
        //Print Shipment Label
        controller.printShippingLabel();
        
        // Added By Mahendra Swarnkar - 3/2/2016 - CR-20160104-9486 Starts from here
        // Insert shipment record to test ground home delivery use case 
        Shipment__c shipmentGround = new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Personal', Bill_To__c = 'Personal',
                                         Status__c = 'New',Package_Type__c = 'Your Package',
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today().addDays(1),
                                         Ship_Method__c = 'GROUND_HOME_DELIVERY');
        insert shipmentGround;
        
        // If Record Was inserted then Load Screen in AppView = 'Review Screen';
        Apexpages.currentPage().getParameters().put('shipmentId',shipmentGround.Id);
        
        controller = new ShipItController();
        
        //Set Package Type
        controller.describePackageDetails();
        
        //Get Selected Package Instance 
        selectedPackage = controller.selectedPackage;
        
        //Check if Package Selection is verified
        Boolean isPackageSelectionVerified1 = controller.isPackageSelectionVerified;
        
        //Populate Some Data on the Ship It order Screen and then Call Get Delivery options methods
        controller.selectedShipDate = Date.today() + '';
        controller.shipment.Bill_To__c = 'Personal';
        controller.getDeleveryOptions();
		
        //Save and Navigates to Review Screen
        controller.saveAndNavigatesToReviewScreen();
		
        //Send Authorization Request and Save Data 
        // Set SelectedAuthorizer for Authorizer Request to whom request would be send by email
        controller.selectedAuthorizer = listOfAuthorizer[0].getValue();
        
        //Send Authorization Request
        controller.sendAuthorizationRequest();
        
        //Authorize Request
        Apexpages.currentPage().getParameters().put('isAuthorized','true');
        
        //Atuhorize Request
        controller.authorizeRequest();
        
        //Print Shipment Label
        controller.printShippingLabel();
        
        //Asserts for the results
        System.assertEquals('Your Package', selectedPackage.Package_Full_Name__c);
        System.assertEquals(true, isPackageSelectionVerified);
        // Added By Mahendra Swarnkar - 3/2/2016 - CR-20160104-9486 - Ends here 
        
        //Now Check if Shipment Was Saved then Query Shipment record and check if any record was created
        List<Shipment__c> savedShipments = [select id from Shipment__c];
		
        // If Record Was inserted then Load Screen in AppView = 'Review Screen';
        if(savedShipments.size() > 0)
        	Apexpages.currentPage().getParameters().put('shipmentId',savedShipments[0].Id);
        
        controller = new ShipItController();
        
        //Check Now App State app must be open in ReviewScreen
        String appViewWithShipmentId = controller.appView;
        
        //Create Fake Instance to Just call delivery option wrapper Constructor
        DeliveryOptionWrapper optionWrapper = new DeliveryOptionWrapper('$7.73','03/14/2015','9:30 PM',1,true,true);
        
        //Call Wrapper option Properties
        Boolean isAvailable = optionWrapper.available;
        Boolean authorizationRequired = optionWrapper.authorizationRequired;
        Boolean selected = optionWrapper.selected;
        String serviceTypeName = optionWrapper.serviceTypeName;
        
        //Go to Find A Shipment Navigate to Next and Previous
        controller.next();
        controller.previous();
        
        //Stop Test from Here
        Test.stopTest();
        
        System.assertEquals('Your Package', selectedPackage.Package_Full_Name__c);
        System.assertEquals(true, isPackageSelectionVerified);
        System.assertEquals(true, savedShipments.size()>0);
        System.assertEquals('Review', appViewWithShipmentId);
        System.assertEquals(true, savedShipments[0].Id != null);
    }
    
    /**
     *  @description    :   These method is to test Ship A find Package Components Fucntions
     *
     *  @args           :
     *
     *  @return         :   void
     *
     **/
    static testMethod void testFindAShipmentComponentFunctions() {
        
        //Call Common Setup Method
        setupUserAndCommonData();
		
        //Set Fixed Search Results
        Test.setFixedSearchResults(setupShipmentList());
        	
        //Start Test from Here
        Test.startTest();
        
        //Instantiate Ship It Controller
        ShipItController controller = new ShipItController();
        
        //Get Instance of Find a Shipment Wrapper
        FindAShipmentWrapper shipItWrapper = controller.findAshipment;
        
        //List to Hold Default Search Results
        List<ShipmentWrapper> defaultShipmentList = shipItWrapper.searchedShipmentList;
        
        //Paging Numbers
        List<Integer> defaultPaging = shipItWrapper.pagingNumbers;
        
        List<SelectOption> shipmentCategories = shipItWrapper.shipmentCategories;
        List<SelectOption> statusList = shipItWrapper.shipmentStatusList;
        List<SelectOption> billingList = shipItWrapper.shipmentBillingTypeList;
        
        //Set Selected Step
        shipItWrapper.userSelectedStep = 1;
        shipItWrapper.setSelectedStep();
        
        //Search Results by Entering criteria
        shipItWrapper.searchText = 'test';
        shipItWrapper.searchShipments();
        
        //Check is there next page
        Boolean hasNext = shipItWrapper.hasNext;
        
        //Searched List
        List<ShipmentWrapper> searchedList = shipItWrapper.searchedShipmentList;
        
        //Now switch to Next step then check is there any previous page
        shipItWrapper.userSelectedStep = 2;
        shipItWrapper.setSelectedStep();
        
        Boolean hasPrevious = shipItWrapper.hasPrevious;
        
        //Now Clear Search Result
        shipItWrapper.clearSearch();
        List<ShipmentWrapper> clearedList = shipItWrapper.searchedShipmentList;
        
        //Stop Test from here
        Test.stopTest();
        
        //Assert for Results
        //Check default Serach results Size
        System.assertEquals(ShipItHelper.DEFAULT_PAGE_SIZE,defaultShipmentList.size());
        System.assertEquals(true,shipmentCategories.size() > 0);
        System.assertEquals(true,statusList.size() > 0);
        System.assertEquals(true,billingList.size() > 0);
        System.assertEquals(10,searchedList.size());
        System.assertEquals(ShipItHelper.DEFAULT_PAGE_SIZE,clearedList.size());
        System.assertEquals(true,hasNext);
        System.assertEquals(true,hasPrevious);
        //System.assertEquals(1,defaultPageSize);
 
    }
    
    /**
     *  @description    :   These method is to test helper functions in shipIt helper classs
     *
     *  @args           :
     *
     *  @return         :   void
     *
     **/
    static testMethod void testShipItHelperFunctions() {
        
    	//Call Common Setup Method
        setupUserAndCommonData();    
        
        //Set Fixed Search Results
        Test.setFixedSearchResults(setupShipmentList());
        
        //Get Contact Data
        List<Contact> contacts = [select Id, Name from Contact];
        
        //Start test from here
        Test.startTest();
        
        //Check Recipient Infor
        List<Contact> recipientList = ShipItHelper.getRecipientInformation(contacts[0].Id);
        
        //Get Sender Infor
        List<User> senderList = ShipItHelper.getSenderInformation(UserInfo.getUserId());
        
        //List to hold Shipment Package types
        List<ShipIt_PackageType__c> shipmentPackageList = ShipItHelper.getShipItPackageTypes();
        
        //Package Instance
        ShipIt_PackageType__c packageInstance = ShipItHelper.getSelectedPackageInstance('FEDEX_ENVELOPE');
        
        //Package Instance by its Display Name
        ShipIt_PackageType__c packageInstance1 = ShipItHelper.getSelectedPackageInstance('FedEx Envelope');
        
        //Shipment Instance
        Shipment__c shipment = new Shipment__c(Status__c = 'New', Bill_To__c = 'Personal');
        
        //Save Ship It Data
        ShipItHelper.shipItSaveData(shipment, 'Delivery Options');
        
        //Send Request Authorization
        ShipItHelper.sendRequestForAuthorization(UserInfo.getUserId(), shipment);
        
        //Populate SHipment Data
        List<Shipment__c> shipmentList = ShipItHelper.populateShipmentData(shipment.Id);
        
        //Update Authorization with Authorized Status
        ShipItHelper.updateAuthorizationResposne(shipment,true);
        
        ShipItHelper.updateAuthorizationResposne(shipment,false);
        
        //Display Error Message and Infor Message on the page
        ShipItHelper.displayErrorMessages('Invalid Data');
        ShipItHelper.displayInfoMessages('Shipment was saved Successfully');
        
        //Methdo to Get Record Type 
        RecordType rt = ShipItHelper.getRecordType('FedEx – Department Shipment');
        
        //Print Shipment Label
        //Boolean isSuccess = ShipItHelper.sendShipmentAndPrintLabel(Shipment);
        
        //Format from date
        String fromDate = Date.today().addDays(-2).month() + '/' + date.today().addDays(-2).day() + '/' + date.today().addDays(-2).year();
        String toDate = Date.today().month() + '/' + date.today().day() + '/' + date.today().year();
        
        //Call Search with Blank Record
        List<Shipment__c> searchResults = ShipItHelper.searchFilteredShipments('New', 'department', '', 50, 'My Shipments', fromDate, toDate);
        
        //Search Shipment List to hold search Results
        searchResults = ShipItHelper.searchFilteredShipments('New', 'department', 'test', 50, 'My Shipments', fromDate, toDate);
		
		//Cover another two condition where once from date can be null or todate can be null        
		List<Shipment__c> searchResults1 = ShipItHelper.searchFilteredShipments('New', 'department', 'test', 50, 'My Shipments', '', toDate);
        List<Shipment__c> searchResult2 = ShipItHelper.searchFilteredShipments('New', 'department', 'test', 50, 'My Shipments', fromDate, '');
		
		//List to hold Select Option Returned
		List<SelectOption> dynamicOptionList = ShipItHelper.getSelectOptionListByField('Shipment__c', 'Status__c');
        
        //Get All Ship Method 
        Map<String,ShipIt_ShipMethod__c> shipMethodSettings = ShipItHelper.allShipItMethods;
        
        //Get Personal Ship it Method
        Map<String,ShipIt_ShipMethod__c> personalShipItMethod = ShipItHelper.pshipItMethods;
        
        //Get All Department Shipment Method
        Map<String,String> mapGroundService = ShipItHelper.fedExGroundServiceTimeMap;
        
        //Get Date Time Format in GMT format
        DateTime gmtDtTime = ShipItHelper.convertDateTimeStringToGmtFormat('MON - 13 APR 10:30A',null);
        
        //Get Date Time Format in GMT Format
        DateTime gmtDtTime1 = ShipItHelper.convertDateTimeStringToGmtFormat('MON - 13 APR AA',shipMethodSettings.get('FEDEX_2_DAY'));
        
        DateTime gmtDtTime2 = ShipItHelper.convertDateTimeStringToGmtFormat('MON - 13 APR AM',shipMethodSettings.get('FEDEX_2_DAY'));
        
        DateTime gmtDtTime3 = ShipItHelper.convertDateTimeStringToGmtFormat('MON - 13 APR PM',shipMethodSettings.get('FEDEX_2_DAY'));
        
        DateTime gmtDtTime4 = ShipItHelper.convertDateTimeStringToGmtFormat('MON - 13 APR AX',null);
        
        DateTime gmtDtTime5 = ShipItHelper.convertDateTimeStringToGmtFormat('MON - 13 APR 10:30P',null);
        
        DateTime gmtDtTime6 = ShipItHelper.convertDateTimeStringToGmtFormat('MON - 13 APR 10:30X',null);
        
        //Stop Test from here
        Test.stopTest();
        
		System.assertEquals(true, recipientList.size() > 0);
        System.assertEquals(true, dynamicOptionList.size() > 0);
    }
    
    /**
     *  @description    :   These method is to test helper functions in shipIt helper classs
     *
     *  @args           :
     *
     *  @return         :   void
     *
     **/
    static testMethod void testPrintLabelController() {
    	
        //Call Common Setup Method
        setupUserAndCommonData();   
        
        List<Shipment__c> shipmentsList = new List<Shipment__c>();
		shipmentsList.add(new Shipment__c(Accept_Billing_Agreement__c='Yes',
                                         Billing_Type__c = 'Department', Bill_To__c = 'Department',
                                         Status__c = 'New',
                                         Recipient_Company__c = 'Test Account 123',
                                         Ship_Date__c = Date.today().addDays(-2)));
        insert shipmentsList;
        
        //Insert Attachment 
        List<Attachment> attachments = new List<Attachment>();
                Blob blobStr = Blob.valueOf('Test Test Test');
                attachments.add(new Attachment(Body = blobStr, ParentID = shipmentsList[0].Id,
                                             Name = 'Shipment Label', Description = 'Shipment Label',
                                             ContentType = 'application/pdf'));
        insert attachments;
        
        
        //Start Test
        Test.startTest();
        
        //Set Latest Attachment Id in page Parameter
        ApexPages.currentPage().getParameters().put('attachmentId',attachments[0].Id);
        
        //Instantiate Printlabel controller without Attachment Id
        ShipIt_ShipmentPrintLabelController controller = new ShipIt_ShipmentPrintLabelController();
        
		//Set Latest Attachment Id in page Parameter
        //ApexPages.currentPage().getParameters().put('attachmentId','');
        //controller = new ShipIt_ShipmentPrintLabelController();
        
        
        //Stop Test
        Test.stopTest();
        
        //Asserts for Result
        System.assertEquals(true, String.isNotBlank(controller.attachmentBody));
        System.assertEquals('application/pdf', controller.contentType);
    }
    
     /**
     *  @description    :   Method to Search on Custom Lookup
     *
     *  @args           :
     *
     *  @return         :   void
     *
     **/
    /*static testMethod void testCustomContactLookup() {
    	
        //Insert Account as a Company or Institution
        Account acc = new Account();
        acc.Name = 'Test Account -123';
        acc.Account_Formal_Name__c = 'Test Account - 123'   ;
        acc.Status__c = 'Active';
        insert acc;
        
        //Insert contacts
		Contact newContact = new Contact();
                newContact.FirstName = 'Test';
                newContact.LastName = 'Contact';
                newContact.Primary_Address_Line_1__c = 'Test Street at test City';
                newContact.Primary_Address_Line_2__c = 'test Place';
                newContact.Primary_City__c = 'test City';
                newContact.Primary_State_Province__c = 'Test State NY';
                newContact.Primary_Country__c = 'United States';
                newContact.Primary_Postal_Code__c = '20202';
                newContact.Phone = '2242435';
				newContact.Email = 'Test'+Math.random()+'@eab.com';
				newContact.Title = 'Test';
        		newContact.AccountId = acc.Id;
        
        //Insert Contact
        insert newContact;
        
        //Start test from Here 
        Test.startTest();
        
        //Instantitate Controller
        ContactCustomLookupController contactController = new ContactCustomLookupController();
        
        //Flag to Show is any list populate
        Boolean isAnyListPopulate = contactController.isAnyListPopulated;
		List<Contact> recnetlyViewed = contactController.recnetlyViewed;
        
        //Search Contact
        Apexpages.currentPage().getParameters().put('lksrch','test contact');
        contactController.search();
        
        //Search Results
        List<Contact> searchResults = contactController.results;
        
        //Clear Search Results
        contactController.clearSearchResults();
        List<Contact> clearedResults = contactController.recnetlyViewed;
        
        //Set Page Parameters
        Apexpages.currentPage().getParameters().put('frm','frm:pb:txt');
        Apexpages.currentPage().getParameters().put('txt','frm:pb:section:test');
        
        //Get form tag and Search Field Id from Controller
        String formId = contactController.getFormTag();
        String textBoxId = contactController.getTextBox();
        
        //Stop Test from Here
        Test.stopTest();
        
        //Assert for Result
        System.assertEquals(true, isAnyListPopulate);
        System.assertEquals(true, searchResults.size() > 0 );
        System.assertEquals(true, clearedResults.size() > 0 );
    }*/
}