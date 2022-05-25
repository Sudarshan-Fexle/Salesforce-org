@isTest

/**
 *  Description     :   This Test class allows us to use a Map to specify which Response we want back for each Request
 *
 *  Created By      :   Colin McGloin
 *
 *  Created Date    :   04/27/2018
 *
 *  Revision Logs   :   V1.0 - Created
 *
**/

public class testMultipleCallout implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;

    public testMultipleCallout(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpCalloutMock mock = requests.get(req.getEndpoint());
        if (mock != null) {
            return mock.respond(req);
        } else {
                throw new CustomException('HTTP callout not supported for test methods');
        }
    }

    public void addRequestMock(String url, HttpCalloutMock mock) {
        requests.put(url, mock);
    }
}