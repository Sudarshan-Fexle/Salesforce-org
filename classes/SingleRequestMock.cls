/**
 *  Purpose         :	Setup single request mock callout responses
 *
 *  Revision Logs   :	V_1.0 - 07/13/2020 - CR-20200706-14269 - Victor Hanson - Created
 * 
**/
@isTest
public class SingleRequestMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String bodyAsString;
        protected Blob bodyAsBlob;
        protected Map<String, String> responseHeaders;
 
        public SingleRequestMock(Integer code, String status, String body,
                                         Map<String, String> responseHeaders) {
            this.code = code;
            this.status = status;
            this.bodyAsString = body;
            this.bodyAsBlob = null;
            this.responseHeaders = responseHeaders;
        }
 
        public SingleRequestMock(Integer code, String status, Blob body,
                                         Map<String, String> responseHeaders) {
            this.code = code;
            this.status = status;
            this.bodyAsBlob = body;
            this.bodyAsString = null;
            this.responseHeaders = responseHeaders;
        }
 
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(code);
            resp.setStatus(status);
            if (bodyAsBlob != null) {
                resp.setBodyAsBlob(bodyAsBlob);
            } else {
                resp.setBody(bodyAsString);
            }
 
            if (responseHeaders != null) {
                 for (String key : responseHeaders.keySet()) {
                resp.setHeader(key, responseHeaders.get(key));
                 }
            }
            return resp;
        }
}