/**
 *   Purpose         :   Test class for SearchAddressWrapper
 *            
 *   Create By       :   Nikita Kumari
 * 
 *   Created Date    :   07/07/2021
 *
 *   Revision Log    :   V_1.0 - Created - Nikita Kumari - CR-20211005-15489
 *   
 *   Coverage        :   V_1.0 - 100%
 *
 **/
@isTest(seeAllData = false)
public with sharing class Test_SearchAddressWrapper {
    
    static testMethod void testSearchAddressWrapper()
    {
        Test.startTest();
        
        SearchAddressWrapper SearchAddress = new SearchAddressWrapper();
        SearchAddress.results = null;
        SearchAddress.summary = null;
        
        SearchAddressWrapper.viewport ViewPort = new SearchAddressWrapper.viewport();
        ViewPort.topLeftPoint = null;
        ViewPort.btmRightPoint = null;
        
        SearchAddressWrapper.topLeftPoint TopLeftpoint = new SearchAddressWrapper.topLeftPoint();
        TopLeftpoint.lon = 4.4;
        TopLeftpoint.lat = 7.9;
        
        SearchAddressWrapper.summary Summary = new SearchAddressWrapper.summary();
        Summary.totalResults = 10;
        Summary.numResults = 12;
        Summary.queryTime = 90;
        Summary.offset = 7;
        Summary.queryType = 'SOQL';
        Summary.fuzzyLevel = 2;
        Summary.query = 'Select Id From Accounts';
        
        SearchAddressWrapper.results Results =  new SearchAddressWrapper.results();
        Results.address = null;
        Results.score = 78.4;
        Results.position = null;
        Results.id = 'aID7i0000009X';
        Results.viewport = null;
        Results.type = 'Type';
        
        SearchAddressWrapper.position Position = new SearchAddressWrapper.position();
        Position.lat = 56.89;
        Position.lon = 23.89;
        
        SearchAddressWrapper.btmRightPoint BTMRightPoint = new SearchAddressWrapper.btmRightPoint();
        BTMRightPoint.lon = 67.98;
        BTMRightPoint.lat = 82.74;
        
        SearchAddressWrapper.address Address = new SearchAddressWrapper.address();
        Address.countryCode = '+1';
        Address.postalCode = '10011';
        Address.countrySubdivisionName = 'New York';
        Address.country = 'United States';
        Address.countrySubdivision = 'US-NY';
        Address.countryCodeISO3 = 'USA';
        Address.countrySecondarySubdivision = 'california';
        Address.freeformAddress = '47 33th St, New York, NY 10011, USA';
        Address.municipality = 'nyc';
        Address.localName = '47 ';
        Address.streetName = '33th';
        
        Test.stopTest();
    }
}