/**
    *  Purpose      :   to generate fake response for ProcessApexClassesWiseDetailsJob Class
    *  Created By   :   Nikita Kumari - CR-20211005-15489 - 07/08/2021
    **/
@isTest
global class MockHTTPResponseProcessApexClass implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"size" : "12" , "totalSize" : "24" , "records" : [{ "ApexClassOrTriggerId" : "01p2K000004Y3lvQAC" ,'
                         + ' "NumLinesCovered" : "34" , "NumLinesUncovered" : "0" , "totalPercentageCoverage" : "100"}]}');
        response.setStatusCode(200);
        return response; 
    }
}