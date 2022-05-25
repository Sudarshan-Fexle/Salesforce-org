/**
*   Description     :   This Class is used to update Box Folder Name For JT
*
*   Created by      :   Abhinav Sharma
*
*   Created Date    :   07/10/2020
*
*   Revision Log    :   V1.0 - Created - Abhinav Sharma - CR-20200709-14285 - Update box folder name 
*/
global class Batch_UpdateBoxFolderForJT implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts
{
    //Set to hold the Ids of Job Tickets. 
    public Set<Id> setJobTicketIds = new Set<Id>();
    public BoxPlatformApiConnection api;
    
    public WebServiceCredential__mdt boxServiceCredential {
        
        get{
            if(boxServiceCredential == null) {
                //Getting the Box credential.
                WebServiceCredential__mdt Credential = [Select Id, Private_Key__c, Token_Endpoint__c, Client_Id__c, 
                                                        Client_Secret__c, Enterprise_Id__c,Public_Key_Id__c  
                                                        From WebServiceCredential__mdt 
                                                        Where MasterLabel = 'Box_API_Credential'];   
                return Credential;
            }else{
                return boxServiceCredential;
            }
        }   
    }
        
    //Constructor
    public Batch_UpdateBoxFolderForJT(Set<Id> setJobTicketIds) 
    {
        if(setJobTicketIds != null && setJobTicketIds.size() > 0 ) {
            this.setJobTicketIds = setJobTicketIds;
        }else{
            throw new CustomException('Please send the valid parameters!');
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //Script to get the access token 
        BoxJwtEncryptionPreferences preferences = new BoxJwtEncryptionPreferences();
        preferences.setPublicKeyId(boxServiceCredential.Public_Key_Id__c);
        preferences.setPrivateKey(boxServiceCredential.Private_Key__c);
        if(!Test.isRunningTest()){
            api = BoxPlatformApiConnection.getAppEnterpriseConnection(boxServiceCredential.Enterprise_Id__c, boxServiceCredential.Client_Id__c, boxServiceCredential.Client_Secret__c, preferences);
        }	
        else
        {
            api = null;
        } 
       
        //String to for the Query.
        String query = 'Select Id, Name, Box_Folder_Id__c, BOX_Folder_Link__c, Fiscal_Year__c  From Job_Ticket__c Where Id IN: setJobTicketIds';
        
        System.debug('query----'+query);
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Job_Ticket__c> jobTickets)
    {
		//List to hold production tracking records. 
		List<Job_Ticket__c> jobTicketsToBeUpdated = new List<Job_Ticket__c>();
        
        for(Job_Ticket__c jobTicket : jobTickets) 
        { 
            //This contains the information of root folder details. (PrintMis Folder)        
            BoxFolder parentFolder = new BoxFolder(api, jobTicket.Box_Folder_Id__c);
            
            String folderId = '';
            String shareableLink = '';
        	
            //Creating the Job ticket folder Ids.
            if(!Test.isRunningTest())
            {
                folderId = BoxFolderUtility.parseFolderCreationReponse(parentFolder.rename(jobTicket.Name));
            }
        }
    }   
    
	global void finish(Database.BatchableContext BC){
    }
}