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

/*
*    Description     :    The class is used to as mock class for Test_CreateApexTestDependency
*
*    Created By      :    Ishan Arora
*
*    Created Date    :    13/04/2018
*
*    Revision Logs   :     V_1.0 - Created
*
*/
@isTest//CreateApexTestDependenc
global class Test_CreateApexTestDependencyMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"size":7268,"totalSize":7268,"done":false,"queryLocator":"01g1D00000329c9QAA-2000","entityTypeName":"ApexCodeCoverage","records":[{"attributes":{"type":"ApexCodeCoverage","url":"/services/data/v41.0/tooling/sobjects/ApexCodeCoverage/7141D000009KxgDQAS"},"ApexClassOrTrigger":{"attributes":{"type":"Name","url":"/services/data/v41.0/tooling/sobjects/ApexTrigger/01qC00000005jL0IAI"},"Id":"01qC00000005jL0IAI","Name":"dlrs_ABC_RevenueTrigger"},"ApexTestClass":{"attributes":{"type":"ApexClass","url":"/services/data/v41.0/tooling/sobjects/ApexClass/01pC0000000JKt2IAG"},"Name":"dlrs_ABC_RevenueTest"}},{"attributes":{"type":"ApexCodeCoverage","url":"/services/data/v41.0/tooling/sobjects/ApexCodeCoverage/7141D000009KxgEQAS"},"ApexClassOrTrigger":{"attributes":{"type":"Name","url":"/services/data/v41.0/tooling/sobjects/ApexTrigger/01qC0000000A3d4IAC"},"Id":"01qC0000000A3d4IAC","Name":"Trigger_ABCRevenue"},"ApexTestClass":{"attributes":{"type":"ApexClass","url":"/services/data/v41.0/tooling/sobjects/ApexClass/01pC0000000JKt2IAG"},"Name":"dlrs_ABC_RevenueTest"}}]}');
        response.setStatusCode(200);
        return response; 
    }
}