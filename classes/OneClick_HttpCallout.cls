/**
* Description   :   Class to carry out http callouts and return response
*
* Created By    :   Ishan Arora
*
* Created Date  :   16/03/2018
*
* Version       :   V1.0 Created
*             
**/ 
public class OneClick_HttpCallout {
    
    /*  @description    :  Meathod to save dependencies record in object
    *
    *  @args           	:  String url
    *
    *  @return         	:   HttpResponse
    *
    **/
    public HttpResponse sendCallout(String url){
        //Initialize http request
        HttpRequest req = new HttpRequest();
        //Initialize http request header
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');

        //This the setting query into the endPoint
        req.setEndpoint(url);
        
        req.setMethod('GET'); 
        
        Http h = new Http();
        HttpResponse  res = h.send(req);
        
        return res;
        
    }
    
}