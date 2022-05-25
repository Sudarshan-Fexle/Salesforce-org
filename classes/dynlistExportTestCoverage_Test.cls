/*
Purpose         :   Test class for "dynlistExportTestCoverage" apex class (Dynamic Related List)
Created By      :   Abhinav Sharma
Created Date    :   11/11/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 11/11/2021
*/
@isTest(isparallel=true)
global without sharing class dynlistExportTestCoverage_Test implements HttpCalloutMock
{
    static testMethod void testCallout()
    {
        Test.setMock(HttpCalloutMock.class, new dynlistExportTestCoverage_Test());
        dynlistExportTestCoverage etc = new dynlistExportTestCoverage();
        System.assertNotEquals(etc.cw,null);
        System.assertNotEquals(etc.cw.records,null);
        System.assertEquals(etc.cw.records[0].NumLinesCovered,0);
        System.assertEquals(etc.cw.records[0].ApexClassOrTrigger.Name,'TestClass');
    } 
    
    global HTTPResponse respond(HTTPRequest req) 
    {
          // Create a fake response
          HttpResponse res = new HttpResponse();
          res.setHeader(dynlistConstants.CHAR_CONTENT_TYPE, dynlistConstants.CHAR_APPLICATION_JSON);
          res.setBody('{"size":182,"totalSize":182,"done":true,"queryLocator":null,"entityTypeName":"ApexCodeCoverageAggregate","records":[{"attributes":{"type":"ApexCodeCoverageAggregate","url":"/services/data/v43.0/tooling/sobjects/ApexCodeCoverageAggregate/715000000LdFWSA0"},"Id":"715000000LdFWSA0","ApexClassOrTrigger":{"attributes":{"type":"Name","url":"/services/data/v43.0/tooling/sobjects/ApexClass/01p000000C9D3AAK"},"Name":"TestClass"},"NumLinesCovered":0,"NumLinesUncovered":69},{"attributes":{"type":"ApexCodeCoverageAggregate","url":"/services/data/v43.0/tooling/sobjects/ApexCodeCoverageAggregate/715e0000000LxSAAA0"},"Id":"710000000LxSAAA0","ApexClassOrTrigger":{"attributes":{"type":"Name","url":"/services/data/v43.0/tooling/sobjects/ApexClass/01pe0000000C9RCAA0"},"Name":"TestClass2"},"NumLinesCovered":10,"NumLinesUncovered":53}]}');
          res.setStatusCode(dynlistConstants.HTTP_CALLOUT_SUCCESS_STATUS_CODE);
          return res;
    }
    
    //this method is to test all the use cases associated with "dynlistExportTestCoverage.CoverageWrapper" 
    @isTest(seeAllData=false)
    static void testCoverageWrapper()
    {
        dynlistExportTestCoverage.CoverageWrapper coverageWrapper = new dynlistExportTestCoverage.CoverageWrapper();
        
        //Test start here
        Test.startTest();
        
        dynlistExportTestCoverage.Records records = new dynlistExportTestCoverage.Records();
        
        dynlistExportTestCoverage.Attributes attributes = new dynlistExportTestCoverage.Attributes();
        
        //Variable declaration
        String typeName = 'ApexCodeCoverageAggregat';
        String url = '/services/data/v43.0/tooling/sobjects/ApexCodeCoverageAggregate/715000000LdFWSA0';
        //Setting the Attributes variables
        attributes.type = typeName;
        attributes.url = url;
        
        System.assert(attributes!=null);
        
        //Variable declaration
        Integer numberOfLines = 50;
        String Id = '715000000LdFWSA0';
        
        //Setting the record variables
        records.NumLinesUncovered = numberOfLines;
        records.NumLinesUncovered = numberOfLines;
        records.NumLinesCovered = numberOfLines;
        records.attributes = attributes;
        records.Id = Id;
        
        System.assert(records!=null);
        
        dynlistExportTestCoverage.ApexClassOrTrigger apexClassOrTrigger = new dynlistExportTestCoverage.ApexClassOrTrigger();
        //Setting the ApexClassOrTrigger variables
        apexClassOrTrigger.attributes = attributes;
        apexClassOrTrigger.Name = '';
        
        System.assert(apexClassOrTrigger!=null);
 
        //Setting the coverageWrapper variables
        coverageWrapper.size = 1;
        coverageWrapper.totalSize = 10;
        coverageWrapper.done = true;
        coverageWrapper.entityTypeName = '';
        coverageWrapper.queryLocator = '';
        
        System.assert(coverageWrapper!=null);
        
        //Test stop here
        Test.stopTest();
    }
}