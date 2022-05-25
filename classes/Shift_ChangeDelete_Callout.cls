/* 
* Name          : Shift_ChangeDelete_Callout
* Author        : Shift CRM
* Description   : Manages REST callout
*
* Maintenance History: 
* Date ------------ Name  ----  Version --- Remarks 
* 02/20/2013        Hermes      1.0         Initial
@Modified By - Rajeev Jain - 06/28/2016 - SFDC Royall Migration - Migrated from Royall Enviournment to Corporate Instance
*/

public class Shift_ChangeDelete_Callout {
    
    //Custom Settings
    public static rest_callout_config__c calloutSettings = rest_callout_config__c.getInstance();
    
    //Process Records from Trigger
    public static void processRecords(List<sObject> sObject_List, String action, String objectName) {
        
        String royalSobjectIdSet = '';
        for(sObject tempSobject : sObject_List) {
            royalSobjectIdSet += String.valueOf(tempSobject.get('id'))+',';
        }
        
        royalSobjectIdSet = (royalSobjectIdSet.endsWith(','))?royalSobjectIdSet.left(royalSobjectIdSet.length()-1): royalSobjectIdSet;
        
        if(royalSobjectIdSet.length()>0 && Limits.getFutureCalls()<=Limits.getLimitFutureCalls()) {
            Shift_ChangeDelete_Callout.theCallout(royalSobjectIdSet, action, objectName);

            System.debug('String: ' +royalSobjectIdSet);
            System.debug('Action: ' +action);
            System.debug('Calls Made: ' +Limits.getFutureCalls());
            System.debug('Calls Left: ' + Limits.getLimitFutureCalls());
        }
    }
    
    //Callout
    @future (callout = true)
    public static void theCallout(String theObjectId_list, String actionType, String objectName) {
        String appKey = calloutSettings.AppKey__c;
        String username = calloutSettings.Username__c;
        String password = calloutSettings.Password__c;
        String endpoint = calloutSettings.Endpoint__c;
        
        
        HttpRequest req = new HttpRequest();
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        
        //Process Variables
        req.setBody('appkey='+EncodingUtil.urlEncode(appKey, 'UTF-8')
                    +'&type='+EncodingUtil.urlEncode(actionType, 'UTF-8')
                    +'&'+objectName+'='+EncodingUtil.urlEncode(theObjectId_list, 'UTF-8')
                    );
                    
        Http http = new Http();         
        HttpResponse res = new HttpResponse();
        
        System.debug(req.getBody());
        
        //Make Callout if not test running. We don't really care about the response. Fire and forget!
        if (!Test.isRunningTest()) {        
            try {
                res = http.send(req);
                System.debug(res);
            } catch(System.CalloutException e) {
                System.debug('Callout error: '+ e);
                System.debug(res.toString());
            }
        }
    }
}