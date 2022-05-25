/**
*   Description     :   This class is used to call the lambda web services for Artifact Tx records and update the records based on response.
                
*   Created by      :   Dipesh Gupta
*
*   Created Date    :   04/10/2020
*
*   Revision Log    :   V1.0 - Created - Dipesh Gupta - CR-20200408-13920
*/
public class Enqueue_CallLambdaProcessOnArtifactTx implements Queueable, Database.AllowsCallouts {
	
    List<Id> ListOfArtifactTxIds = new List<Id>();
    String WSLOGS_ARTIFACTRECORDTYPEID = Schema.SObjectType.Web_Service_Log__c.getRecordTypeInfosByName().get('Artifact Transfer').getRecordTypeId();
    String ACCEPTED = 'Accepted';
    String RESULT = 'result';
    
	private Static API_Endpoints__mdt awsFTPCredential {
        
        get{
            
            if(awsFTPCredential == null) {
            	//Getting the Box credential.
        		API_Endpoints__mdt credential = [Select Id, Endpoint_URL__c, Authorization_Token__c 
                                                 From API_Endpoints__mdt
                                                 Where MasterLabel = 'AWS_FTP'];   
                return credential;
            }else{
                return awsFTPCredential;
            }
        	
        }   
    }
 
	//Constructor
	public Enqueue_CallLambdaProcessOnArtifactTx(List<Id> ListOfArtifactTxIds) {
		
		this.ListOfArtifactTxIds = ListOfArtifactTxIds;
	}
    
    public void execute(QueueableContext context) {
        
    	//Query on the Artifact Transfer to get the details. 
        if(ListOfArtifactTxIds.size() > 0) {
            
            String endPoint = awsFTPCredential.Endpoint_URL__c;
            String token = awsFTPCredential.Authorization_Token__c;
			Map<String, String> mapofHeaders = new Map<String, String>();
            mapofHeaders.put(Constants.CONTENT_TYPE, Constants.CONTENT_TYPE_APP_JSON);
            mapofHeaders.put('Accept', Constants.CONTENT_TYPE_APP_JSON);
            mapofHeaders.put(Constants.X_API_KEY, token);
                
        	String thisChunkArtifactTxId = ListOfArtifactTxIds[0];
            
            //Query on the Artifact Transfers. 
            List<Artifact_Transfer__c> artifactTxs = [Select Id, Transfer_Type__c, Source_File_Name_Exact__c, 
                                                      Source_File_Name_RegEx__c, Source_Host_Profile__c, 
                                                      Source_Directory_Path__c, Target_Host_Profile__c, 
                                                      Target_Directory_Path__c, PGP_Decryption_Profile__c,
                                                      PGP_Encryption_Profile__c, Transformation_Profile__c
                                                      From Artifact_Transfer__c Where Id =: thisChunkArtifactTxId];
            
            if(artifactTxs != null && artifactTxs.size() > 0) {
            	system.debug('endPoint##'+endPoint);
                HttpRequest req = requestBuilderForLambda(endPoint, mapofHeaders, createBodyForLambdaRequest(artifactTxs[0]), Constants.HTTP_REQUEST_POST_TYPE);
                
                HttpResponse res = new HttpResponse();
                if(!Test.isRunningTest())
                	res = HTTPService.Send(req);
                else {
                    res.setBody('{"api_key_id":"zkp35rnrq2","id":"'+thisChunkArtifactTxId+'","result":"Accepted","message_id":"d"}');
                    res.setStatus('200');
                }
                Map<String, Object> mapOfResponseParser = new Map<String, Object>();
                
                if(res != null){
                    
                    System.debug('res.getBody()===='+res.getBody());
                    mapOfResponseParser = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    System.debug('mapOfResponseParser---'+mapOfResponseParser);
                   	System.debug('mapOfResponseParser Get' + mapOfResponseParser.get('result'));
                    
                }   
                if(mapOfResponseParser.size() > 0) {
                    
                    Artifact_Transfer__c artifactTransfer = new Artifact_Transfer__c(Id = thisChunkArtifactTxId);
                    
                    System.debug('Code' + res.getStatusCode());
                    System.debug('Yes or no'+String.valueOf(mapOfResponseParser.get(RESULT)) == ACCEPTED);
                    System.debug('Yes or no'+String.valueOf(mapOfResponseParser.get('result')) == ACCEPTED);
                    System.debug('Yes or no'+String.valueOf(mapOfResponseParser.get('result')) == 'Accepted');
                    System.debug('Yes or no'+String.valueOf(mapOfResponseParser.get(RESULT)).toLowerCase().trim() == ACCEPTED.toLowerCase().trim());
					System.debug('Yes or no'+String.valueOf(mapOfResponseParser.get(RESULT)).toLowerCase().trim().contains(ACCEPTED.toLowerCase().trim()));
					System.debug('Yes or no'+String.valueOf(mapOfResponseParser.get(RESULT)).contains(ACCEPTED));

                    
                    if(res.getStatusCode() == 200 && String.valueOf(mapOfResponseParser.get(RESULT)).contains(ACCEPTED)){  
                        
						system.debug('I am Success ::::: ');
                        
                        //Update the status to transferring. 
                        artifactTransfer.Status__c = Constants.ARTIFACT_TRANSFER_STATUS_TRANSFERRING;
                    }else {
                        
                        system.debug('I am Failed ::::: ');
                        artifactTransfer.Status__c = Constants.FAILURE;
                        artifactTransfer.Result__c = String.valueOf(mapOfResponseParser.get(RESULT));
                    }
                    	
                    system.debug('artifactTransfer ::::: '+artifactTransfer);
                    update artifactTransfer;
                    
                    //create web service log
                    Web_Service_Log__c webServiceLog = new Web_Service_Log__c(RecordTypeId = WSLOGS_ARTIFACTRECORDTYPEID,
                                                                              Artifact_Transfer__c = thisChunkArtifactTxId,
                                                                              Web_Service_Method__c = Constants.HTTP_REQUEST_POST_TYPE,
                                                                              Request_Sent__c = system.now(),
                                                                              Request_Message_Log__c = String.valueOf(req),
                                                                              Response_Message__c = String.valueOf(res.getStatusCode()),
                                                                              Response_Message_Log__c = String.valueOf(res.getBody()),
                                                                              Requested_By__c = UserInfo.getUserName());
                    insert webServiceLog;
                }
                
            }
            
            //Removing the zeroth id from the list. 
            ListOfArtifactTxIds.remove(0);
            
            if(ListOfArtifactTxIds != null && ListOfArtifactTxIds.size() > 0 && !Test.isRunningTest()) {
	        //Recalling the enqueue job.
            	System.enqueueJob(new Enqueue_CallLambdaProcessOnArtifactTx(ListOfArtifactTxIds));
            }
        }
    }
    
    public Static String createBodyForLambdaRequest(Artifact_Transfer__c artifactTx) {
    	
        String JsonStringAsBody = '{';
        
        Map<String, Object> mapOfArtifactTxs = artifactTx.getPopulatedFieldsAsMap();
        
        for(String  fieldValue: mapOfArtifactTxs.keySet()){
        	
            JsonStringAsBody += '"' + fieldValue + '": "' + mapOfArtifactTxs.get(fieldValue) + '",';
        }
        JsonStringAsBody = JsonStringAsBody.removeEnd(',') + '}';
        system.debug('JsonStringAsBody--'+JsonStringAsBody);
        return JsonStringAsBody;
    }
    
    public Static HttpRequest requestBuilderForLambda(String endPoint, Map<String, String> mapOfHeader, String body, String methodType) {
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setBody(body);
        req.setMethod(methodType);
        
        if(mapOfHeader != null && mapOfHeader.size() > 0) {
        	
            for(String key : mapOfHeader.keySet()){
               req.setHeader(key, mapOfHeader.get(key));
            }
        } 
        
        return req;
    }
}