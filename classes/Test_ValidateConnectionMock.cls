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
*    Description     :    The class is used to as mock class for Test_ValidateConnection
*
*    Created By      :    Ishan Arora
*
*    Created Date    :    13/04/2018
*
*    Revision Logs   :     V_1.0 - Created
*
*/
@isTest
global class Test_ValidateConnectionMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        System.debug('@@@####');
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"access_token":"SESSION_ID_REMOVED","signature":"QPZba4X87doppUaSmBpEhUgYCt1lZMtKPeR7CSm92w0=","scope":"refresh_token full","instance_url":"httpas://eab--OneClick.cs68.my.salesforce.com","id":"https://test.salesforce.com/id/00D1D0000008tfKUAQ/005C0000007CLN9IAO","token_type":"Bearer","issued_at":"1524474000739"}');
        response.setStatusCode(200);
        response.setStatus('Ok');
        return response; 
    }
}