/**
*   Description     :   This Class is used to hit box one by one and update the folder information on the Job tickets.
			Batch will be called from the batch size 1 since the folder creation request is one at a time.
*
*   Created by      :   Abhinav Sharma
*
*   Created Date    :   04/03/2020
*
*   Revision Log    :   V1.0 - Created - Abhinav Sharma - CR-20200325-13887
* 		    :	V1.0 - Modified By - Mahendra Swarnkar - CR-20210323-15016 - 04/22/2021
*/
global class Batch_CreateBoxFolderForJT implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts
{
    
    //Set to hold the Ids of Job Tickets. 
    public Set<Id> setJobTicketIds = new Set<Id>();
    public BoxPlatformApiConnection api;
    Map<String, String> mapFiscalYearWithIds = new Map<String, String>();
    
    public WebServiceCredential__mdt boxServiceCredential 
    {
        get
        {
            if(boxServiceCredential == null) 
            {
                //Getting the Box credential.
                WebServiceCredential__mdt Credential = [Select Id, Private_Key__c, Token_Endpoint__c, Client_Id__c, 
                                                        Client_Secret__c, Enterprise_Id__c,Public_Key_Id__c  
                                                        From WebServiceCredential__mdt 
                                                        Where MasterLabel = 'Box_API_Credential'];   
                return Credential;
            }
            else
            {
                return boxServiceCredential;
            }
        }  
    }
    
    //Constructor
    public Batch_CreateBoxFolderForJT(Set<Id> setJobTicketIds) 
    {
        if(setJobTicketIds != null && setJobTicketIds.size() > 0 ) 
        {
            this.setJobTicketIds = setJobTicketIds;
        }
        else
        {
            throw new CustomException('Please send the valid parameters!');
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //Script to get the access token 
        BoxJwtEncryptionPreferences preferences = new BoxJwtEncryptionPreferences();
        preferences.setPublicKeyId(boxServiceCredential.Public_Key_Id__c);
        preferences.setPrivateKey(boxServiceCredential.Private_Key__c);
        if(!Test.isRunningTest())
        {
            api = BoxPlatformApiConnection.getAppEnterpriseConnection(boxServiceCredential.Enterprise_Id__c, boxServiceCredential.Client_Id__c, boxServiceCredential.Client_Secret__c, preferences);
        }   
        else
        {
            api = null;
        } 
        
        //Modified By - Abhinav Sharma - 01/05/2021 - CR-20201105-14666 - Add automation when Drop # is updated on JT - Comment Box_Folder_Id__c
        //String to for the Query.
        String query = 'Select Id, School__c,  Name, Box_Folder_Id__c, BOX_Folder_Link__c, Fiscal_Year__c  From Job_Ticket__c Where Id IN: setJobTicketIds AND Fiscal_Year__c != null '/*AND Box_Folder_Id__c = null'*/;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Job_Ticket__c> scope)
    {
        //This contains the information of root folder details. (PrintMis Folder)        
        BoxFolder parentFolder = new BoxFolder(api, Label.Box_RootFolder_Id); 
        
        //List to hold production tracking records. 
        List<Job_Ticket__c> jobTicketsToBeUpdated = new List<Job_Ticket__c>();
        
        for(Job_Ticket__c jobTicket : scope) 
        { 
            String folderFiscalYearId = '';
            if(!mapFiscalYearWithIds.containsKey(jobTicket.Fiscal_Year__c)) 
            {
                if(!Test.isRunningTest())
                {
                    folderFiscalYearId = BoxFolderUtility.parseFolderCreationReponse(parentFolder.createFolder(jobTicket.Fiscal_Year__c));
                }
                else
                {
                    folderFiscalYearId = '12345';
                }
                mapFiscalYearWithIds.put(jobTicket.Fiscal_Year__c, folderFiscalYearId);
            }
            else
                folderFiscalYearId = mapFiscalYearWithIds.get(jobTicket.Fiscal_Year__c);  
            
            //Folder of Fiscal Year where we need to create the Jt folders. 
            parentFolder = new BoxFolder(api, folderFiscalYearId); 
            
            String folderId = '';
            String shareableLink = '';
            
            //Creating the Job ticket folder Ids.
            if(!Test.isRunningTest())
            {
                folderId = BoxFolderUtility.parseFolderCreationReponse(parentFolder.createFolder(jobTicket.Name));
                shareableLink  = BoxFolderUtility.fetchSharableURL(api, folderId);
                
                //This part is to tag a school name on the Job Ticket folder on Box.
                if(String.isNotBlank(jobTicket.School__c)) 
                {
                    BoxFolder folder = new BoxFolder(api, folderId);
                    BoxSharedLink.Info linkInfo = folder.createTag(jobTicket.School__c);    
                }
            }
            
            jobTicketsToBeUpdated.add(new Job_Ticket__c(Id = jobTicket.Id, Box_Folder_Id__c = folderId, BOX_Folder_Link__c =  shareableLink));
        }
        
        if(jobTicketsToBeUpdated.size() > 0) 
        {
            //Updating the job tickets. 
            Util.BypassAllTriggers = true;
            update jobTicketsToBeUpdated;
            Util.BypassAllTriggers = false;    
        }
    }   
    
    global void finish(Database.BatchableContext BC)
    {
        if(setJobTicketIds.size() > 0) 
        {
            //Added By - Neha Sharma - 04/29/2020 - CR-20210323-15016 - Calling a another batch job that will run for creative package. 
            Batch_CreateBoxFolderForCreativePackage batchCreativePackage = new Batch_CreateBoxFolderForCreativePackage(setJobTicketIds);
            Database.executeBatch(batchCreativePackage, Integer.valueOf(Label.ProductionTracking_BoxBatchSize));
            
            //Calling a another batch job that will run for production tracking. 
            Batch_CreateBoxFolderForPT batchProductionTracking = new Batch_CreateBoxFolderForPT(setJobTicketIds);
            Database.executeBatch(batchProductionTracking, Integer.valueOf(Label.ProductionTracking_BoxBatchSize));
        }
    }
}