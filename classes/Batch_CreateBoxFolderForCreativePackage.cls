/**
*   Description     :   This Class is used to hit box and update the folder information on the Creative Package.
                        Batch will be called from the batch size 1 since the folder creation request is one at a time. 
*
*   Created by      :   Neha Sharma
*
*   Created Date    :   04/29/2020
*
*   Revision Log    :   V1.0 - Created - Neha Sharma - CR-20210323-15016 
*/
global class Batch_CreateBoxFolderForCreativePackage implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts
{
    //Set to hold the Ids of Job Tickets. 
    public Set<Id> setJobTicketIds = new Set<Id>();
    public BoxPlatformApiConnection api;
    
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
    public Batch_CreateBoxFolderForCreativePackage(Set<Id> setJobTicketIds) 
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
        //String to for the Query.
        String query = 'Select Id, Job_Ticket__c, Box_Folder_Id__c, Box_Folder_Link__c, Job_Ticket__r.Box_Folder_Id__c From Creative_Package__c Where Box_Folder_Id__c = null AND Job_Ticket__c != null AND Job_Ticket__r.Box_Folder_Id__c != null And Job_Ticket__c =: setJobTicketIds ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Creative_Package__c> scope)
    {
        //For Resolve duplicate Box folder creation for Creative
        Map<Id, List<Creative_Package__c>> mapOfJTIdWithCreativePackages = new Map<Id, List<Creative_Package__c>>();
        
        //Getting the creative package records and create the folder for them as well. 
        for(Creative_Package__c creativePkg : scope) 
        {
            if(!mapOfJTIdWithCreativePackages.containsKey(creativePkg.Job_Ticket__c))
                mapOfJTIdWithCreativePackages.put(creativePkg.Job_Ticket__c, new List<Creative_Package__c>());
            
            mapOfJTIdWithCreativePackages.get(creativePkg.Job_Ticket__c).add(creativePkg);
        }
        
        //check map size
        if(mapOfJTIdWithCreativePackages.size() > 0 && mapOfJTIdWithCreativePackages.keySet().size() > 0 && mapOfJTIdWithCreativePackages.values().size() > 0)
        {
            //holds packages that will going to update
            List<Creative_Package__c> creativePkgsToBeUpdate = new List<Creative_Package__c>();
            List<Job_Ticket__c> listJobTicketsToBeUpdate = new List<Job_Ticket__c>();
            
            //get job tickets on which assets folder going to create
            for(Id jobTicketId : mapOfJTIdWithCreativePackages.keySet()) 
            {
                BoxFolder parentJTFolder = new BoxFolder(api, mapOfJTIdWithCreativePackages.get(jobTicketId)[0].Job_Ticket__r.Box_Folder_Id__c); 
                String folderId = '';
                String shareableFolderLink = '';
                
                if(!Test.isRunningTest())
                {
                    //get folder Id and link
                    folderId = BoxFolderUtility.parseFolderCreationReponse(parentJTFolder.createFolder('Assets'));
                    shareableFolderLink = BoxFolderUtility.fetchSharableURL(api, folderId);
                }
                
                for(Creative_Package__c creativePkg : mapOfJTIdWithCreativePackages.get(jobTicketId))
                {
                    creativePkg.Box_Folder_Id__c = folderId;
                    creativePkg.BOX_Folder_Link__c = shareableFolderLink;
                    creativePkgsToBeUpdate.add(creativePkg);
                    listJobTicketsToBeUpdate.add(new Job_Ticket__c(Id = jobTicketId, Creative_Package_Box_Folder_Id__c = folderId, Creative_Package_BOX_Folder_Link__c = shareableFolderLink));
                }
            }
            
            if(creativePkgsToBeUpdate.size() > 0)
            {
                Util.BypassAllTriggers = true; 
                update creativePkgsToBeUpdate; 
                Util.BypassAllTriggers = false;
            }
            
            if(listJobTicketsToBeUpdate.size() > 0)
            {
                Util.BypassAllTriggers = true; 
                update listJobTicketsToBeUpdate; 
                Util.BypassAllTriggers = false;
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {} 
}