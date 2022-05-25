/*
Purpose         :   Controller class for "SandboxCreateANDRefresh" page, to Create a Sandbox using Tooling API.

Created By      :   Abhinav Sharma

Created Date    :   02/03/2020

Current Version :   v1.0

Revision Log    :   V_1.0 Created
                    V_1.1 - Modified By - Abhinav Sharma - 06/02/2020 - CR-20200601-14124 - Include SandboxSetup Class in the Create SB Wizard to automate Post refresh 
                    V_1.2 - Modified by - Abhinav Sharma - 06/03/2020 - CR-20200203-13681 - New App for assigning "picks just for you" on eab.com 
                    V_1.3 - Modified by - Abhinav Sharma - 09/15/2020 - CR-20200728-14372 - Added the Institution and Contact for Assigning site content recommendation
		    V_1.4 - Modified by - Abhinav Sharma - 09/15/2020  - CR-20200213-13742 - New App for assigning "picks just for you" on eab.com
*/
public with sharing class SandboxCreateAndRefreshManager 
{
    public List<Create_Sandbox_Request__c> listOfSandboxRefreshDetails {get;set;}
    public SandboxCreateWrapper sCWrapper {get; set;}
    private ApexPages.StandardController stdContoller;
    
    public Boolean isSuccess {get; set;}
    
    public SandboxCreateAndRefreshManager() 
    {
        isSuccess = false;
        sCWrapper = new SandboxCreateWrapper();
    }
    public SandboxCreateAndRefreshManager(ApexPages.StandardController standardController)
    {
        this.stdContoller = standardController;	
    }
    
    //Method to invoke sandbox create request
    public Pagereference createAndRefreshSandboxPage(SandboxCreateWrapper sCWrapper, boolean autoActivate, 
                                                     String sandboxType) 
    {
        createAndRefreshSandbox(sCWrapper,
                                autoActivate,
                                sandboxType,
                                true
                               );
        if(isSuccess) 
        {
            return stdContoller.view();   
        }
        else 
        {
            return null; 
        }
    }
    
    public SandboxCreateWrapper createAndRefreshSandbox(SandboxCreateWrapper sCWrap, boolean autoActivate, 
                                                        String sandboxType, Boolean isPageContext)
    {
        try 
        {
            isSuccess = false;
            
            if(autoActivate == null) 
            {
                autoActivate = true;    
            }
            
            if(String.isBlank(sandboxType)) 
            {
                sandboxType = 'DEVELOPER';
            }
            
            
            List<Create_Sandbox_Request__c> listToBeUpdateErrorMessage = new List<Create_Sandbox_Request__c>();
            if(String.isNotBlank(sCWrap.cSRequest.Sandbox_Name__c) 
               && String.isNotBlank(sCWrap.cSRequest.Sandbox_Description__c)
              )
            {
                /*String bodyStr = '{"ApexClassId": "' + System.Label.Post_Sandbox_Refresh_Class_ID + '",'
                        + '"AutoActivate": ' + autoActivate + ','
                        + '"Description": "' + sCWrap.cSRequest.Sandbox_Description__c + '",'
                        + '"LicenseType": "' + sandboxType + '",'
                        + '"SandboxName": "' + sCWrap.cSRequest.Sandbox_Name__c + '"'
                        +'}';*/
                //Modified By - Abhinav Sharma- 06/02/2020 - CR-20200601-14124 - Include SandboxSetup Class in the Create SB Wizard to automate Post refresh
                //Add Apex Class Id in bodyStr
                
                String bodyStr = '{"ApexClassId": "' + System.Label.Post_Sandbox_Refresh_Class_ID + '",'
                    +'"AutoActivate": ' + autoActivate + ','
                    + '"Description": "' + sCWrap.cSRequest.Sandbox_Description__c + '",'
                    + '"LicenseType": "' + sandboxType + '",'
                    + '"SandboxName": "' + sCWrap.cSRequest.Sandbox_Name__c + '"'
                    +'}';
                
                System.debug('@@@ bodyStr'+bodyStr);
                HttpResponse res = HTTPCalloutUtilities.makeSandboxCreateCallout(bodyStr);
                System.debug('@@@ res Sandbox Create ' + res);
                if(res != null) 
                {
                    if(Constants.setOfSBCreateSuccessCodes.contains(res.getStatusCode()))
                    {
                        CreateSandboxResponseWrapper cSandboxWrapper = new CreateSandboxResponseWrapper();
                        cSandboxWrapper = cSandboxWrapper.parse(res.getBody());
                        cSandboxWrapper.CreateSBRequestId = sCWrap.cSRequest.Id;
                        
                        System.debug('@@@ cSandboxWrapper'+cSandboxWrapper);
                        List<Create_Sandbox_Request__c> listToUpdateErrorMsg = new List<Create_Sandbox_Request__c>();
                        List<Create_Sandbox_Request__c> listOfCreateSBReq = new List<Create_Sandbox_Request__c>();
                        listOfCreateSBReq.add(new Create_Sandbox_Request__c(Id = sCWrap.cSRequest.Id, 
                                                                            Status__c = System.Label.Sandbox_Create_In_Progress, 
                                                                            SandboxInfo_Id__c = cSandboxWrapper.Id));
                        System.debug('@@@ listOfCreateSBReq ' + listOfCreateSBReq);
                        if(listOfCreateSBReq.size() > 0)
                        {
                            Util.BypassAllTriggers = true;
                            List<Database.SaveResult> updateResult = Database.update(listOfCreateSBReq, false);
                            for (Database.SaveResult result : updateResult) 
                            {
                                if (!result.isSuccess())
                                {
                                    for (Database.Error err : result.getErrors())
                                    {
                                        sCWrap.cSRequest.Error_Message__c = err.getMessage();
                                        listToUpdateErrorMsg.add(new Create_Sandbox_Request__c(Id = result.getId(),
                                                                                               Error_Message__c = sCWrap.cSRequest.Error_Message__c));
                                    }
                                }
                            }
                            update listToUpdateErrorMsg;
                            Util.BypassAllTriggers = false;    
                        }
                        
                        //Schedule the scheduler to check the minutely basis status of SB Creation Process.
                        if(isPageContext && !Apexpages.hasMessages()) 
                        {	
                            SandboxCreateWrapper sCW = new SandboxCreateWrapper();
                            sCW.cSRequest =  listOfCreateSBReq[0];   
                            
                            System.debug('@@@@ '+listOfCreateSBReq[0].Id);
                            
                            List<SandboxCreateWrapper> sCWs = new List<SandboxCreateWrapper>();
                            sCWs.add(sCW);
                            
                            Scheduler_BatchCreateSBRequestProcess.scheduleAfterMinutesForPage(Integer.valueOf(System.Label.Time_Duration_For_Sandbox_Creation_Job_Status_Check), 
                                                                                              true, sCWs);
                        }
                        else 
                        {
                            sCWrap.cSRequest = listOfCreateSBReq[0];
                            sCWrap.isSBCreateRequestSuccessive = true;
                            sCWrap.messageDetails = System.Label.SB_Create_Req_Success_Msg;
                        }
                        isSuccess = true;
                    }
                    else
                    {
                        if(isPageContext) 
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'STATUS CODE : ' + res.getStatusCode() + ' ' + res.getStatus()));    
                        }
                        else 
                        {
                            sCWrap.messageDetails = 'STATUS CODE : ' + res.getStatusCode() + ' ' + res.getStatus();
                            listToBeUpdateErrorMessage.add(new Create_Sandbox_Request__c(Id = sCWrap.cSRequest.Id, Error_Message__c = sCWrap.messageDetails));
                        }
                    }
                } 
                else 
                {
                    if(isPageContext) 
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Invalid_Response));
                    }
                    else 
                    {
                        sCWrap.messageDetails = System.Label.Invalid_Response;
                        listToBeUpdateErrorMessage.add(new Create_Sandbox_Request__c(Id = sCWrap.cSRequest.Id, Error_Message__c = sCWrap.messageDetails));
                    }
                }
            }
            else 
            {
                if(isPageContext) 
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Specify_SanboxName_And_Description));    
                }    
                else 
                {
                    sCWrap.messageDetails = System.Label.Specify_SanboxName_And_Description;
                    listToBeUpdateErrorMessage.add(new Create_Sandbox_Request__c(Id = sCWrap.cSRequest.Id, Error_Message__c = sCWrap.messageDetails));
                }
            }
            update listToBeUpdateErrorMessage;
        }
        catch(Exception e) 
        {
            if(isPageContext) 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            }  
            else 
            {
                sCWrap.messageDetails = e.getMessage();    
            }
            return sCWrap;
        }
        return sCWrap;
    }
    
    /*Method for Create Sandbox Lightning Web Component*/
    @AuraEnabled(cacheable=true) 
    public static boolean getCompVisibility()
    {
        return CoreUtilities.getCompVisibility(System.Label.Manage_Sandbox_Permission);
    }
    
    //Method to create a Sandbox Refresh Details object record with user populated field values 
    //to initiate a new request for the sandbox creation
    @AuraEnabled(cacheable=false)
    public static List<Create_Sandbox_Request__c> createRecordSandboxRefreshDetails(String sandboxName, String sandboxDes, 
                                                                                    List<String> selectedAccounts, 
                                                                                    boolean autoActivate)
    {
        try
        {
            List<User> listOfUser = [SELECT Id, Name FROM User Where Id =: UserInfo.getUserId()];
            List<Create_Sandbox_Request__c> listOfSandboxRefreshDetails = new List<Create_Sandbox_Request__c>();
            if(String.isNotBlank(sandboxName) 
               && String.isNotBlank(sandboxDes) 
               && listOfUser != null && listOfUser.size() > 0
              )
            {
                String selectAccountsStr = '';
                selectAccountsStr = CoreUtilities.quotedString(selectedAccounts, Constants.CHAR_COMMA);
                listOfSandboxRefreshDetails.add(new Create_Sandbox_Request__c(Sandbox_Name__c = sandboxName, 
                                                                              Sandbox_Description__c = sandboxDes,
                                                                              Selected_Account__c = selectAccountsStr,
                                                                              Auto_Activate__c  = autoActivate,
                                                                              Requested_By__c = listOfUser[0].Name,
                                                                              Request_Date_Time__c = system.now(),
                                                                              Status__c = System.Label.Sandbox_Request_Awaiting_Sandbox_Creation ));
            }
            else 
            {
                throw new CustomException(System.Label.Create_Sandbox_Required_Fields_Message);
            }
            
            if(listOfSandboxRefreshDetails.size() > 0)
            {
                Util.BypassAllTriggers = true;
                insert listOfSandboxRefreshDetails;
                Util.BypassAllTriggers = false;
            }
            return listOfSandboxRefreshDetails;
        }
        catch(Exception e)
        {
            throw new CustomException('Exception occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n');
        }
    }
    
    //Modified by- Abhinav Sharma - 09/15/2020 - CR-20200728-14372 
    //Modified by- Abhinav Sharma - 06/03/2020 - CR-20200213-13742 - New App for assigning "picks just for you" on eab.com
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> doSearchRecords(String searchTerm, List<String> selectedIds,String sObjectName, 
                                                           String field, String subField,Integer maxResults, String icon, String whereClause) 
    {
        
        if(String.isNotBlank(searchTerm) && String.isNotBlank(subField) && String.isNotBlank(sObjectName) 
           && String.isNotBlank(searchTerm) && maxResults != null) 
        {
            List<LookupSearchResult> results = new List<LookupSearchResult>();
            String strQuery = ''; 
            
            if(String.isBlank(whereClause)){
                strQuery = 'SELECT Id, '+field + ', ' + subField +' FROM '+ sObjectName +' WHERE '+field+' LIKE \'%' + searchTerm + '%\' AND Id NOT IN : selectedIds  LIMIT : maxResults';
            }
            else
            {
                strQuery = 'SELECT Id, ' + field + ', ' + subField +' FROM '+ sObjectName +' WHERE '+ whereClause ;
                strQuery += ' AND '+ field +' LIKE \'%' + searchTerm + '%\' AND Id NOT IN : selectedIds  LIMIT : maxResults';
            }
                            
            List<sObject> searchResults = Database.query(strQuery);
            if(searchResults != null && searchResults.size() > 0)
            {
                for(sObject sObj : searchResults)
                {
                    LookupSearchResult res = new LookupSearchResult();
                        //Modified By - Abhinav Sharma - CR-20200728-14372
                        subField = sObjectName == 'Contact'? subField.split(', ')[0] : subField;
                    
                        //Modified By - Abhinav Sharma - CR-20200728-14372 - 9/15/20 - Added the Institution and Contact to add the site content recommendation on the basis of multiple institution/Contact
                        //Added By - Mahendra Swarnakar - 12/01/2020 ((String.valueOf(sObj.get('EAB_com_Site_Profile__c')) != null ? Id.valueOf(String.valueOf(sObj.get('EAB_com_Site_Profile__c'))) : sObj.Id))
                        res.Id = sObjectName == 'Contact' ? (String.valueOf(sObj.get('EAB_com_Site_Profile__c')) != null ? Id.valueOf(String.valueOf(sObj.get('EAB_com_Site_Profile__c'))) : sObj.Id) : sObj.Id;
                        //End Here
                        res.title = String.valueOf(sObj.get(field));
                        
                        //Modified By - Abhinav Sharma - CR-20200728-14372 - 9/15/20 - Added the Institution and Contact to add the site content recommendation on the basis of multiple institution/Contact
                        
                        if(sObj.get(subField) != null && subField != 'CreatedDate' && sObjectName != 'Contact' && subField != 'EAB_com_Site_Profile__c')
                        {
                            res.subtitle = sObjectName +' • ' + String.valueOf(sObj.get(subField));
                        } //End here
                        //Modified By - Abhinav Sharma - Issue--CR14372--QA--00010239 - 10/28/2020 - As per the enhancement
                        else if(sObj.get(subField) != null && sObjectName == 'Contact'){
                            res.subtitle = String.valueOf(sObj.getSobject('Account').get('Name'));
                        }
                        //End here
                    else
                    {
                        res.subtitle = sObjectName;
                    }
                    
                    if(sObjectName == 'Team_Role__c')
                        res.subtitle = '';
                    
                        //Modified By - Abhinav Sharma - CR-20200728-14372 - 9/15/20 - Added the Institution and Contact to add the site content recommendation on the basis of multiple institution/Contact 
                        if(sObjectName == 'Contact')
                            res.keyContactId = sObj.Id; 
                    res.icon = icon;
                    results.add(res);
                } 
                return results;
            }
            else 
            {
                throw new CustomException('Exception occured:\r\n' + System.Label.No_Record_Display + '\r\n');
            }
        }
        else 
        {
            throw new CustomException('Exception occured:\r\n' + System.Label.SB_Required_Search_Based_Parameter + '\r\n');    
        }
    }
    
    public class LookupSearchResult 
    {
        @AuraEnabled public Id id {get;set;}
        @AuraEnabled public String icon {get;set;}
        @AuraEnabled public String title {get;set;}
        @AuraEnabled public String subtitle {get;set;}
        
        //Modified By - Abhinav Sharma - CR-20200728-14372 - 9/16/2020 - Added this for holding Memnership Key Contact ids
        @AuraEnabled public Id keyContactId {get;set;}
        
    }
    
    public class Errors {}
    
    public class CreateSandboxResponseWrapper 
    {
        public String CreateSBRequestId;
        public String id;
        public Boolean success;
        public List<Errors> errors;
        public List<Errors> warnings;
        public List<Errors> infos;
        
        public CreateSandboxResponseWrapper parse(String json) 
        {
            return (CreateSandboxResponseWrapper) System.JSON.deserialize(json, CreateSandboxResponseWrapper.class);
        }
    }  
    
    //Action Method to invoke sandbox create request
    public Pagereference createAndRefreshSandboxPageAction() 
    {
        isSuccess = false;
        
        sCWrapper = new SandboxCreateWrapper();
        
        String recordId = ApexPages.CurrentPage().getparameters().get('id');
        
        //Initiate a sandbox creation request, only if someone clicks on the detail page 
        //button from the rquested based record
        if(String.isNotBlank(recordId)) 
        {
            //Get the Create SB request record
            listOfSandboxRefreshDetails = [SELECT Sandbox_Name__c, Sandbox_Description__c, Auto_Activate__c 
                                           FROM Create_Sandbox_Request__c 
                                           WHERE Id =: recordId];
            
            //Chekkc for size
            if(listOfSandboxRefreshDetails.size() > 0) 
            {
                sCWrapper.cSRequest = listOfSandboxRefreshDetails[0];
                
                //Method to make a callout to create a new dev sandbox using Tooling API
                createAndRefreshSandboxPage(sCWrapper, listOfSandboxRefreshDetails[0].Auto_Activate__c, null );
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.No_Sandbox_Create_Request_Record_Exists));    
            }
        }
        else
        {
            //Error Message Invalid reord id
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Valid_Record_Id));    
        }
        
        if(isSuccess) 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Start_SB_Creation_Process_Message));
        
        return null;
    }
}