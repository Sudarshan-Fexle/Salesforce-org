/**
*  Description     :    This Class is having all the automation logic method on Mailroom Inventory object.
*
*  Created By      :    Subhash Garhwal
*
*  Created Date    :    07/15/2021   
* 
*  Revision Logs   :    V_1.0 - Created - CR-20210722-15306
*                      
**/
public with sharing class MailroomInventoryTriggerHelper 
{    
    public static boolean byPassMultipleCallouts = false;
    /**
    * 
    *  Purpose         :  Method used to send Mailroom Inventory Records for HTTP Callout
    *
    *  Created by      :  Subhash Garhwal
    *
    *  Created Date    :  07/15/2021
    *
    *  Revision Logs   :  V_1.0 - Created
    *                     
    **/
    
    Public static void sendNotificationToEmployee(List<Mailroom_Inventory__c> newMailPackage, Map<Id, Mailroom_Inventory__c> mapOfOldMailPackage)
    {
        if(byPassMultipleCallouts) return;
        
        //map to hold Id and Mail Package
        Map<Id, Mailroom_Inventory__c> mapOfMailPackages = new Map<Id, Mailroom_Inventory__c>();
        
        //map to hold User Name with its corresponding Ids
        //Map<String, Id> mapOfUserNameWithIDs = new Map<String, Id>();
        
        //For After Update
        if(newMailPackage.size() > 0 && mapOfOldMailPackage.size() > 0)
        {
            //Loop over to new records
            for(Mailroom_Inventory__c mailPackage : newMailPackage)
            {
                //Update Case
                if(String.isNotBlank(mailPackage.Status__c) && 
                   (mailPackage.Status__c == Constants.MAILROOM_STATUS_WAITING_FOR_USER || 
                    mailPackage.Status__c.startsWith(Constants.MAILROOM_STATUS_COMPLETED))
                   && (mailPackage.Status__c != mapOfOldMailPackage.get(mailPackage.Id).Status__c)
                  )
                {
                    //Storing Values into Map
                    mapOfMailPackages.put(mailPackage.Id, mailPackage);
                    //mapOfUserNameWithIDs.put(mailPackage.Operator__c, null);
                }
            }
        }
        
        /*if(mapOfUserNameWithIDs.size() > 0 && mapOfUserNameWithIDs.KeySet().size() > 0)
        {
        for(User user : [SELECT Id, Name FROM User WHERE Name IN : mapOfUserNameWithIDs.keySet()])
        {
        if(mapOfUserNameWithIDs.containsKey(user.Name))
        {
        mapOfUserNameWithIDs.put(user.Name, user.Id);    
        }
        }
        }*/
        
        // For Loop over the mapOfMailPackages
        for(Id mailPackageId : mapOfMailPackages.keySet())
        {
            //Logic when status is changed from "New" to "Waiting for user"
            if(mapOfMailPackages.get(mailPackageId).Status__c == Constants.MAILROOM_STATUS_WAITING_FOR_USER 
               && mapOfOldMailPackage.get(mailPackageId).Status__c == Constants.MAILROOM_STATUS_NEW){
                   //Creating JSON body
                   Map<String, String> mailPackageJSON = new Map<String, String>();
                   mailPackageJSON.put('id', mailPackageId);
                   mailPackageJSON.put('attachments', 'ALL');
                   //mailPackageJSON.put('operator', mapOfUserNameWithIDs.get(mapOfMailPackages.get(mailPackageId).Operator__c));
                   mailPackageJSON.put('operator', mapOfMailPackages.get(mailPackageId).Operator__c);
                   
                   sendRecordForCallout(mailPackageId, JSON.serialize(mailPackageJSON));
               }
            
            //Logic when status is changed from "Waiting-Scanning" to "Waiting for user"
            if(mapOfMailPackages.get(mailPackageId).Status__c == Constants.MAILROOM_STATUS_WAITING_FOR_USER 
               && mapOfOldMailPackage.get(mailPackageId).Status__c == Constants.MAILROOM_STATUS_WAITING_SCANNING){
                   //Creating JSON body
                   Map<String, String> mailPackageJSON = new Map<String, String>();
                   mailPackageJSON.put('id', mailPackageId);
                   mailPackageJSON.put('attachments', 'NEW');
                   //mailPackageJSON.put('operator', mapOfUserNameWithIDs.get(mapOfMailPackages.get(mailPackageId).Operator__c));
                   mailPackageJSON.put('operator', mapOfMailPackages.get(mailPackageId).Operator__c);
                   sendRecordForCallout(mailPackageId, JSON.serialize(mailPackageJSON));
               }
            
            //Logic when status startswith "Completed-"
            if(mapOfMailPackages.get(mailPackageId).Status__c.startsWith(Constants.MAILROOM_STATUS_COMPLETED)){
                //Creating JSON body
                Map<String, String> mailPackageJSON = new Map<String, String>();
                mailPackageJSON.put('id', mailPackageId);
                //mailPackageJSON.put('operator', mapOfUserNameWithIDs.get(mapOfMailPackages.get(mailPackageId).Operator__c));
                mailPackageJSON.put('operator', mapOfMailPackages.get(mailPackageId).Operator__c);
                //Call SendCallout Method to PostHTTPRequest
                sendRecordForCallout(mailPackageId, JSON.serialize(mailPackageJSON));
            }
        }
        
        byPassMultipleCallouts = true;
    }
    
    /**
    * 
    *  Purpose         :  Sends a callout to for mailPackages when Status is changed
    *
    *  Created by      :  Subhash Garhwal
    *
    *  Created Date    :  07/15/2021
    *
    *  Revision Logs   :  V_1.0 - Created
    *                     
    **/
    @future(callout=true)
    public static void sendRecordForCallout(Id mailPackageId, String jsonBody) {
        sendCallout(mailPackageId, jsonBody);
    }
    
    /**
    * 
    *  Purpose         :  Method used to Sends a callout for mail packages.
    *
    *  Created by      :  Subhash Garhwal
    *
    *  Created Date    :  07/15/2021
    *
    *  Revision Logs   :  V_1.0 - Created
    *                     
    **/
    public static HttpResponse sendCallout(Id mailPackageId, String jsonBody) 
    {
        //Create new HttpResponse
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        Http h = new Http();
        String response;
        
        Mailroom_Inventory__c mailPackage = [SELECT Id, Status__c FROM Mailroom_Inventory__c WHERE Id = :mailPackageId];
        
        try {
            //determine callout credentials for vendor
            List<API_Endpoints__mdt> apiEndpoints = [SELECT Id, Endpoint_URL__c, Authorization_Token__c FROM API_Endpoints__mdt
                                                     WHERE DeveloperName = :Constants.AWS_MAIL_STRING]; 
            
            if (apiEndpoints.size() > 0) {
                
                //create request
                req.setEndpoint(apiEndpoints[0].Endpoint_URL__c + Constants.MAILROOM_NOTIFICATION_API);
                req.setMethod(Constants.HTTP_REQUEST_POST_TYPE);
                req.setHeader('x-api-key', apiEndpoints[0].Authorization_Token__c);
                req.setHeader('Content-Type', 'application/json');
                req.setBody(''+jsonBody);
                //to avoid read out error
                req.setTimeout(120000);
                res = h.send(req);
            }
            else {
                throw new customException(Constants.NO_API_ENDPOINT_WITH_RECORD_ID + mailPackageId+ '\'');
            }
            //set response as the response callout body
            response = res.getBody();
            
        }
        catch (exception e) {
            response = e.getMessage() + '\r\n\r\n' + e.getStackTraceString();
        }
        
        //get Web Service Log recrd type named with MailPackage
        Id webServiceLogMailPackage = Schema.SObjectType.Web_Service_Log__c.getRecordTypeInfosByDeveloperName().get('Mailroom_Inventory').getRecordTypeId();
        
        //create web service log
        Web_Service_Log__c webServiceLog = new Web_Service_Log__c(RecordTypeId = webServiceLogMailPackage,
                                                                  Mailroom_Inventory__c = mailPackage.Id,
                                                                  Request_Sent__c = system.now(),
                                                                  Request_Message_Log__c = JSON.serializePretty(JSON.deserializeUntyped(jsonBody), false),
                                                                  Response_Message__c = String.valueOf(res.getStatusCode()),
                                                                  Response_Message_Log__c = response,
                                                                  Requested_By__c = UserInfo.getUserName());
        insert webServiceLog;
        return res;
    }
    
    
    /**
    * 
    *  Purpose         :  Method used to populate the Operator Field on Mailroom Inventory
    *
    *  Created by      :  Subhash Garhwal
    *
    *  Created Date    :  07/15/2021
    *
    *  Revision Logs   :  V_1.0 - Created
    *                     
    **/
    public static void populateOperatorFieldOnMailroomInventory(List<Mailroom_Inventory__c> newMailPackage, 
                                                                Map<Id, Mailroom_Inventory__c> mapOfOldMailPackage)
    {
        Id currentUserId = UserInfo.getUserId();
        
        for(Mailroom_Inventory__c mailPackage : newMailPackage)
        {
            if(mailPackage.Automation_Update__c == false 
               && currentUserId != (Id)Label.EAB_Integrations_User_Id
               && (mapOfOldMailPackage == null || (mapOfOldMailPackage != null 
                                                   && mailPackage.LastModifiedDate != mapOfOldMailPackage.get(mailPackage.Id).LastModifiedDate))
              )
            { 
                mailPackage.Operator__c = currentUserId;
            }
        }
    }
}