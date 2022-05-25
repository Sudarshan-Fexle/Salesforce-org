/**
*   Description     :   This Class is used to hit box one by one and update the folder information on the Production tracking.
                		Batch will be called from the batch size 1 since the folder creation request is one at a time. 
*
*   Created by      :   Abhinav Sharma
*
*   Created Date    :   04/03/2020
*
*   Revision Log    :   V1.0 - Created - Abhinav Sharma - CR-20200325-13887  
                    :   V1.1 - Modified for - CR-20200723-14352 - Box Link Expiration in 1 Month to Never Expired with Tag to Folder
		    :   V1.2 - Modified for - CR-20200914-14509 - 10/07/2020 - Resolve duplicate Box folder creation for Prod Tracking records
*		    :   V1.3 - Modified for - CR-20210524-15178 - 05/24/2021 - To remove the un-necessary system.debug statements and to proper indent the code.
*		    :   V1.4 - Modified for - CR-20210420-15089 - 04/19/2021 - Added Box_Folder_Id__c = null to query to prevent duplicate box folder creation
*/
global class Batch_CreateBoxFolderForPT implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts
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
    public Batch_CreateBoxFolderForPT(Set<Id> setJobTicketIds) 
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
        
        //04/19/2021 - CR-20210420-15089 - Victor Hanson - added Box_Folder_Id__c = null to query to prevent duplicate box folder creation
        //String to for the Query.
        String query = 'Select Id, Name, Job_Ticket__r.School__c, Box_Folder_Id__c, BOX_Folder_Link__c, Job_Ticket__r.Box_Folder_Id__c From Production_Tracking__c Where Job_Ticket__c =: setJobTicketIds AND Job_Ticket__c != null AND Job_Ticket__r.Box_Folder_Id__c != null AND (Box_Folder_Id__c = null OR BOX_Folder_Link__c = null)';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Production_Tracking__c> scope)
    {
        //Modified By - CR-20200914-14509 - 10/07/2020 - Resolve duplicate Box folder creation for Prod Tracking records
        Set<String> setOfTrackingName = new Set<String>();
        
        //Getting the production tracking records and create the folder for them as well. 
        for(Production_Tracking__c prodTrack : scope) 
        {
            BoxFolder parentJTFolder = new BoxFolder(api, prodTrack.Job_Ticket__r.Box_Folder_Id__c); 
            
            String folderPTId = '';
            String shareablePTLink = '';
            
            if(!Test.isRunningTest())
            {
                //Modified By - CR-20200914-14509 - 10/07/2020 - Resolve duplicate Box folder creation for Prod Tracking records
                if(!setOfTrackingName.contains(prodTrack.Name))
                {
                    setOfTrackingName.add(prodTrack.Name);
                    folderPTId = BoxFolderUtility.parseFolderCreationReponse(parentJTFolder.createFolder(prodTrack.Name));
                    shareablePTLink  = BoxFolderUtility.fetchSharableURL(api, folderPTId);
                    
                    //This part is to tag a school name on the Job Ticket folder on Box.
                    if(String.isNotBlank(prodTrack.Job_Ticket__r.School__c)) 
                    {
                        BoxFolder folder = new BoxFolder(api, folderPTId);   
                        BoxSharedLink.Info linkInfo = folder.createTag(prodTrack.Job_Ticket__r.School__c);    
                    }
                }
            }
            prodTrack.Box_Folder_Id__c = folderPTId;
            prodTrack.BOX_Folder_Link__c = shareablePTLink;
        }
        Util.BypassAllTriggers = true; 
        update scope; 
        Util.BypassAllTriggers = false;
    }
    
    
    global void finish(Database.BatchableContext BC){
		
    }	
}