/**
 *   Purpose         :   Test class for ProcessApexClassesWiseDetailsJob
 *            
 *   Create By       :   Abhinav Sharma
 * 
 *   Created Date    :   02/01/2020
 *
 *   Revision Log    :   V_1.0 - Created - Abhinav Sharma
 *                   :   V_1.1 - Modified by Nikita Kumari - CR-20211005-15489 - 07/08/2021 - Fixed issue and increase code covrage
 *   
 *
 **/
@isTest(seeAllData = false)
private class Test_ProcessApexClassesWiseDetailsJob 
{
    static testMethod void testProcessApexClassesWiseDetailsJob()
    {
        Test.startTest();
        
        RunAllTestsResultsWrapper wrapper = new RunAllTestsResultsWrapper('Test', null);
        
        // Added By Nikita kumari - CR-20211005-15489 - 08/07/2021 - Increase code coverage - start
        wrapper.emailBodyApexClassesCoverageDetails = 'test';
        Test.setMock(HttpCalloutMock.class,new MockHTTPResponseGenerator());
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+ System.Label.ApexClassesWiseCoverageDetails);
        req.setMethod(Constants.HTTP_REQUEST_GET_TYPE); 
        req.setHeader(Constants.CONTENT_TYPE, Constants.CONTENT_TYPE_APP_JSON);
        req.setHeader(Constants.AUTHORIZATION, Constants.BEARER + Constants.CHAR_BLANK_SPACE + UserInfo.getSessionID());
        Http httpreq = new Http();
        HttpResponse res = httpreq.send(req);
        
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String expectedValue = '{"status":"success"}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
        
        // Added By Nikita kumari - 08/07/2021 - CR-20211005-15489 - Increase code coverage - end
        ProcessApexClassesWiseDetailsJob proccApexClassWiseDetails = new ProcessApexClassesWiseDetailsJob(wrapper);
        System.enqueueJob(proccApexClassWiseDetails);
        
        
        Test.stopTest();
    }
    
    // Added By Nikita kumari - CR-20211005-15489 - 08/07/2021 - Increase code coverage
    static testMethod void testProcessApexClassesWiseDetailsJob1()
    {
        Test.startTest();
        
        RunAllTestsResultsWrapper wrapper1 = new RunAllTestsResultsWrapper('Test1', null);
        wrapper1.emailBodyApexClassesCoverageDetails = 'test1';
        Test.setMock(HttpCalloutMock.class,new MockHTTPResponseProcessApexClass());
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+ System.Label.ApexClassesWiseCoverageDetails);
        req.setMethod(Constants.HTTP_REQUEST_GET_TYPE); 
        req.setHeader(Constants.CONTENT_TYPE, Constants.CONTENT_TYPE_APP_JSON);
        req.setHeader(Constants.AUTHORIZATION, Constants.BEARER + Constants.CHAR_BLANK_SPACE + UserInfo.getSessionID());
        Http httpreq = new Http();
        HttpResponse res = httpreq.send(req);
        
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String expectedValue = '{"size" : "12" , "totalSize" : "24" , "records" : [{ "ApexClassOrTriggerId" : "01p2K000004Y3lvQAC" ,'
            					 + ' "NumLinesCovered" : "34" , "NumLinesUncovered" : "0" , "totalPercentageCoverage" : "100"}]}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
        
        ProcessApexClassesWiseDetailsJob proccApexClassWiseDetails1 = new ProcessApexClassesWiseDetailsJob(wrapper1);
        System.enqueueJob(proccApexClassWiseDetails1);
        
        
        Test.stopTest();
    }
}