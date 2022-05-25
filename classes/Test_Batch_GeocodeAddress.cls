/**
 *  Purpose         :	Test class for Batch_GeocodeAddress
 *
 *  Revision Logs   :	V_1.0 - 07/13/2020 - CR-20200706-14269 - Victor Hanson - Created
 * 
**/
@IsTest
private class Test_Batch_GeocodeAddress {
    
    public static final String testAddressLine1 = '123 main st';
    
    @testSetup static void testSetupData()
    {
        //create a test institution with address info
        util.bypassAllTriggers = true;
        Account acct = TestUtilities.CreateNewAccount('US Education', false);
        acct.Primary_Address_Line_1__c = testAddressLine1;
        acct.Primary_City__c = 'Columbus';
        acct.Primary_State_Province__c = 'OH';
        acct.Primary_Country__c = 'United States';
        insert acct;
        util.bypassAllTriggers = false;
        
    }
    
    @IsTest static void testBatchGeocodeAddress() {
        //get the test institution
        Account acct = [SELECT Id, Primary_Address_Line_1__c, Geolocation_Status__c FROM Account WHERE Primary_Address_Line_1__c = :testAddressLine1];
        
        //setup the fake callout response
        String mockResponseBody = '{"summary":{"query":"2425 shillingham ct powell oh 43065"},"results":[{"position":{"lat":40.13309,"lon":-83.08111}},{"position":{"lat":40.18466,"lon":-83.07446}}]}';
        SingleRequestMock fakeResponse = new SingleRequestMock(200, 'OK', mockResponseBody, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        Test.startTest();
        
        //update the address
        acct.Primary_Address_Line_1__c = '1 Main St';
        acct.Geolocation_Status__c = LocationHelper.READY_FOR_BATCH;
        update acct;
        
        Test.stopTest();
        
        //verify both web service logs were generated
        acct = [SELECT Id, Primary_Address_Line_1__c, Geolocation_Status__c, Primary_Location__Latitude__s, Primary_Location__Longitude__s,
                (SELECT Id FROM Web_Service_Logs__r)
                FROM Account WHERE Primary_Address_Line_1__c = '1 Main St'];
        system.assertEquals(40.13309, acct.Primary_Location__Latitude__s);
        system.assertEquals(-83.08111, acct.Primary_Location__Longitude__s);
        system.assertNotEquals(null, acct.Web_Service_Logs__r);
    }
    
    @IsTest static void testGetTimezone() {
        //get the test institution
        Account acct = [SELECT Id, Primary_Address_Line_1__c, Geolocation_Status__c FROM Account WHERE Primary_Address_Line_1__c = :testAddressLine1];
        
        //setup the fake callout response
        String mockResponseBody = '{"TimeZones":[{"Id":"America/New_York","Names":{"ISO6391LanguageCode":"en","Generic":"Eastern Time"}}]}';
        SingleRequestMock fakeResponse = new SingleRequestMock(200, 'OK', mockResponseBody, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        Test.startTest();
        
        LocationHelper lHelper = new LocationHelper();
        lHelper.acctId = acct.Id;
        //executes the timezone callout
        SearchTimezoneWrapper timezoneWrapper = lHelper.getTimezone('40.13309,-83.08111');
        //check if the timezone was returned
        if (timezoneWrapper != null && 
            timezoneWrapper.timezones != null && 
            timezoneWrapper.timezones.size() > 0 &&
            timezoneWrapper.timezones[0].Id != null && 
            timezoneWrapper.timezones[0].Names != null && 
            timezoneWrapper.timezones[0].Names.Generic != null) 
        {
            acct.Geolocation_Status__c = LocationHelper.COMPLETED_SUCCESS;
            acct.Time_Zone_ID__c = timezoneWrapper.timezones[0].Id;
            acct.Time_Zone_Name__c = timezoneWrapper.timezones[0].Names.Generic;
        }
        else {
            acct.Geolocation_Status__c = LocationHelper.COMPLETED_FAIL;
        }
        util.bypassAllTriggers = true;
        update acct;
        
        Test.stopTest();
        
        //verify both web service logs were generated
        acct = [SELECT Id, Primary_Address_Line_1__c, Geolocation_Status__c, Primary_Location__Latitude__s, Primary_Location__Longitude__s,
                Time_Zone_ID__c, Time_Zone_Name__c,
                (SELECT Id FROM Web_Service_Logs__r)
                FROM Account WHERE Primary_Address_Line_1__c = :testAddressLine1];
        system.assertEquals('America/New_York', acct.Time_Zone_ID__c);
        system.assertEquals('Eastern Time', acct.Time_Zone_Name__c);
        system.assertEquals(LocationHelper.COMPLETED_SUCCESS, acct.Geolocation_Status__c);
        system.assertNotEquals(null, acct.Web_Service_Logs__r);
    }
}