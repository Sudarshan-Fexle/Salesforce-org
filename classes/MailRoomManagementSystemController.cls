/**
*  Description     :    This is controller class for MailRoomManagementSystem
*
*  Created By      :    Subhash Gharwal
*
*  Created Date    :    07/20/2021   
* 
*  Revision Logs   :    V_1.0 - Created - CR-20210722-15306
*		   :    V_1.1 - Modified By - Shalu Sharma - 02/11/2022 - CR-20220125-15748 - Mailroom Management App - Create Tab Structure based on Status                 
*                     
**/ 
public with sharing class MailRoomManagementSystemController 
{
    //Added By - Shalu Sharma - 02/11/2022 - CR-20220125-15748
    public static Map<String, Set<String>> MAP_OF_MAILROOM_INVENTORY = new Map<String, Set<String>>
    {
        'in_Inventory' =>  new Set<String>{'New','Waiting for user','Waiting-Picking up','Waiting-Scanning','Waiting-Discarding'},
        'completed' => new Set<String>{'Completed-Picked up','Completed-Discarded'}
    };
        
    /**
    * 
    *  Purpose         :  Method used to fetch Mailroom metadat records and check user have Mailroom Managment access or not.
    *
    *  Created by      :  Subhash Garhwal
    *
    *  Created Date    :  07/20/2021
    *
    *  Revision Logs   :  V_1.0 - Created
    *                     
    **/
    @AuraEnabled(cacheable=true)
    public static LightningResponseEntity fetchMailroomOptionDetails()
    {
        //to hold response for component
        LightningResponseEntity responseEntity = new LightningResponseEntity();
        
        Set<String> setOfMailroomDevloperName = new Set<String>();
        try{
            
            List<Mailroom_Manager__mdt> mailroomManagers = [Select Id, Manage_All_Rooms__c, Assigned_to_Mailroom__r.Prefix__c, 
                                                            Assigned_to_Mailroom__r.Label, Assigned_to_Mailroom__r.DeveloperName 
                                                            From Mailroom_Manager__mdt 
                                                            Where IsActive__c = true
                                                            And Assigned_to_Mailroom__c != null 
                                                            And UserId__c != null And UserId__c =: UserInfo.getUserId()
                                                            And Assigned_to_Mailroom__r.IsActive__c = true
                                                            And Assigned_to_Mailroom__r.Prefix__c != null
                                                            Order By Manage_All_Rooms__c Desc
                                                           ];
            
            if(mailroomManagers.size() > 0)
            {
                EABMailroomManagmentWrapper eabMailroomManagmentWrapper = new EABMailroomManagmentWrapper();
                Boolean isUserAllowFullAccess = false;
                
                //get user specific mailroom records        
                for(Mailroom_Manager__mdt mailroomManager : mailroomManagers)
                {
                    //check if user have full access of mailrooms
                    if(mailroomManager.Manage_All_Rooms__c)
                    {
                        isUserAllowFullAccess = true;
                        break;
                    }
                    else
                    {
                        if(!setOfMailroomDevloperName.contains(mailroomManager.Assigned_to_Mailroom__r.DeveloperName))
                        {
                            setOfMailroomDevloperName.add(mailroomManager.Assigned_to_Mailroom__r.DeveloperName);
                            
                            //set prefix to filter Mail/Package records
                            eabMailroomManagmentWrapper.mapOfMailroomPrefixAndDevName.put(mailroomManager.Assigned_to_Mailroom__r.Prefix__c +'%', mailroomManager.Assigned_to_Mailroom__r.DeveloperName);
                            
                            //set true if user have a single room access
                            eabMailroomManagmentWrapper.userAllowedToAccessMailroom = true;
                            
                            //set mailroom options for current user whose driving page
                            eabMailroomManagmentWrapper.mailroomOptionsWrapper.add(new EABMailroomManagmentOptionsWarpper(mailroomManager.Assigned_to_Mailroom__r.Label,
                                                                                                                          mailroomManager.Assigned_to_Mailroom__r.DeveloperName));
                        }
                    }
                }
                
                //check if user have full access
                if(isUserAllowFullAccess)
                {
                    //get all mailroom records if user have full access
                    for(Mailroom__mdt mailroom : [Select Id, Prefix__c, Label, DeveloperName 
                                                  From Mailroom__mdt 
                                                  Where IsActive__c = true And Prefix__c != null
                                                  Order By Label Asc
                                                 ]
                       )
                    {
                        //set prefix to filter Mail/Package records
                        eabMailroomManagmentWrapper.mapOfMailroomPrefixAndDevName.put(mailroom.Prefix__c +'%', mailroom.DeveloperName);
                        
                        //set true if user have a single room access
                        eabMailroomManagmentWrapper.userAllowedToAccessMailroom = true;
                        
                        //set mailroom options for current user whose driving page
                        eabMailroomManagmentWrapper.mailroomOptionsWrapper.add(new EABMailroomManagmentOptionsWarpper(mailroom.Label,
                                                                                                                      mailroom.DeveloperName));
                    }
                }
                
                //set response in response entity
                responseEntity.setBody(eabMailroomManagmentWrapper);
            }
            else
            {
                responseEntity.setMessage(Label.Mailroom_No_Manage_Access_Msg);
                responseEntity.setSuccess(true);
            }
        }
        catch(Exception ex)
        {
            //set error in response entity
            responseEntity.setError(ex.getMessage());
        }
        return responseEntity;
    }
    
    /**
    *
    *  Purpose         :  Method used to fetch mail package records as per the Mailroom metadata prefix.
    *
    *  Created by      :  Subhash Garhwal
    *
    *  Created Date    :  07/20/2021
    *
    *  Revision Logs   :  V_1.0 - Created
    * 		       :  V_1.1 - Modified By - Shalu Sharma - 02/11/2022 - CR-20220125-15748
    *                     
    **/
    @AuraEnabled(cacheable=true)
    public static LightningResponseEntity fetchMailPackageDetails(String eabMailroomManagmentWrapper, String selectedTab)
    {
        EABMailroomManagmentWrapper eabMailroomManagmentWrap = (EABMailroomManagmentWrapper)System.JSON.deserialize(eabMailroomManagmentWrapper, EABMailroomManagmentWrapper.class);
        
        //to hold response for component
        LightningResponseEntity responseEntity = new LightningResponseEntity();
        
        try
        {
            //check map size
            if(eabMailroomManagmentWrap.mapOfMailroomPrefixAndDevName.size() > 0 && eabMailroomManagmentWrap.mapOfMailroomPrefixAndDevName.keySet().size() > 0 && String.isNotBlank(selectedTab))
            {
                //get Mail/Package records as per perfix value of Mailroom meta data
                for(Mailroom_Inventory__c mailDetail : [Select Id,Automation_Update__c, Bin__c, Carrier__c, Name, Operator__c, 
                                                        Package_Type__c, Recipient__c, Sender__c, Status__c, Recipient__r.Name,
                                                        LastModifiedDate
                                                        From Mailroom_Inventory__c 
                                                        Where Name Like : eabMailroomManagmentWrap.mapOfMailroomPrefixAndDevName.keySet()
                                                        Order By LastModifiedDate Desc]
                )
                {
                       String mailroomDevName = eabMailroomManagmentWrap.mapOfMailroomPrefixAndDevName.get(mailDetail.name.split('-')[0].trim() + '%');
                       //check status is contains "Waiting-"
                       if(Constants.MAILROOM_WAITING_USER_RESPONSE_WAITING_XXX_STATUS.contains(mailDetail.Status__c))
                       {
                           //set user response
                           UserResponseRecDetailWarpper userResponse = new UserResponseRecDetailWarpper(mailDetail.Id, mailDetail.name, mailDetail.Package_Type__c, 
                                                                                                        mailDetail.Recipient__r.Name, mailDetail.Status__c, mailDetail.Bin__c, 
                                                                                                        mailDetail.Status__c, mailroomDevName);
                           eabMailroomManagmentWrap.userResponseRecDetailWarpper.add(userResponse);
                       }
                       
                       if(MailRoomManagementSystemController.MAP_OF_MAILROOM_INVENTORY.get(selectedTab).contains(mailDetail.Status__c))
                       {
                           //set all mailroom related details
                           MailroomsRecDetailWarpper mailroomRec = new MailroomsRecDetailWarpper(mailDetail.Id, mailDetail.name, mailDetail.Package_Type__c, 
                                                                                                 mailDetail.Recipient__r.Name, mailDetail.Status__c, mailDetail.Bin__c, 
                                                                                                 mailDetail.Status__c, mailroomDevName);
                           eabMailroomManagmentWrap.mailroomsRecDetailWarpper.add(mailroomRec);
                       }
                    
                        //set all mailroom related details
                        MailroomsRecDetailWarpper mailroomRec = new MailroomsRecDetailWarpper(mailDetail.Id, mailDetail.name, mailDetail.Package_Type__c, 
                                                                                              mailDetail.Recipient__r.Name, mailDetail.Status__c, mailDetail.Bin__c, 
                                                                                              mailDetail.Status__c, mailroomDevName);
                        eabMailroomManagmentWrap.temporaryMailroomsRecDetailWarpper.add(mailroomRec);
                   }
                
                if(eabMailroomManagmentWrap.mailroomsRecDetailWarpper.size() > 0)  
                {
                    //set response in response entity
                    responseEntity.setBody(eabMailroomManagmentWrap);
                    responseEntity.setSuccess(true);   
                }
                else
                {
                    responseEntity.setMessage('No record(s) to display.');
                    responseEntity.setSuccess(true);
                }
            }
            else
            {
                responseEntity.setError('eabMailroomManagmentWrapper can not be null');    
            }
        } 
        catch(Exception ex)
        {
            //set error in response entity
            responseEntity.setError(ex.getMessage());
        }
        return responseEntity;
    }
    
    /**
    * 
    *  Purpose         :  Method used to fetch history tracking records of mail package.
    *
    *  Created by      :  Subhash Garhwal
    *
    *  Created Date    :  07/20/2021
    *
    *  Revision Logs   :  V_1.0 - Created
    *                     
    **/
    @AuraEnabled(cacheable=true)
    public static LightningResponseEntity fetchMailPackageHistoryDetails(Id mailPackageId)
    {
        //to hold response for component
        LightningResponseEntity responseEntity = new LightningResponseEntity(); 
        
        try
        {
            if(String.isNotBlank(mailPackageId))
            {
                //to hold status related history details
                List<MailPackageHistoryDetailWarpper> mailPackageHistoryDetails = new List<MailPackageHistoryDetailWarpper>();
                
                //get Mail/Package records as per perfix value of Mailroom meta data
                for(Mailroom_Inventory__History mailHistoryDetail : [Select Id, ParentId, Field, CreatedDate, NewValue, OldValue 
                                                                     From Mailroom_Inventory__History 
                                                                     Where Field IN :Constants.MAILROOM_HISTORY_DETAIL_FIELDS And ParentId =: mailPackageId Order By CreatedDate Desc]
                )
                {
                       //set history details
                       mailPackageHistoryDetails.add(new MailPackageHistoryDetailWarpper(Date.valueOf(mailHistoryDetail.CreatedDate), String.valueOf(mailHistoryDetail.NewValue)));
                   }
                
                if(mailPackageHistoryDetails.size() > 0)  
                {
                    //set response in response entity
                    responseEntity.setBody(mailPackageHistoryDetails);
                    responseEntity.setSuccess(true);   
                }
                else
                {
                    responseEntity.setMessage('No History data record(s) to display.');
                    responseEntity.setSuccess(true);
                }
            }
            else
            {
                responseEntity.setError(Label.Insufficient_Access_To_RecordId); 
            }
        } 
        catch(Exception ex)
        {
            //set error in response entity
            responseEntity.setError(ex.getMessage());
        }
        return responseEntity;
    }
    
    //to hold Mailroom Managment System app related info
    //Modified By - Shalu Sharma - 02/11/2022 - CR-20220125-15748 - added property "temporaryMailroomsRecDetailWarpper" in the wrapper
    public class EABMailroomManagmentWrapper
    {
        @AuraEnabled public Boolean userAllowedToAccessMailroom;
        @AuraEnabled public List<EABMailroomManagmentOptionsWarpper> mailroomOptionsWrapper;
        @AuraEnabled public List<MailroomsRecDetailWarpper> mailroomsRecDetailWarpper;
        @AuraEnabled public List<UserResponseRecDetailWarpper> userResponseRecDetailWarpper;
        @AuraEnabled public Map<String, String> mapOfMailroomPrefixAndDevName;
        @AuraEnabled public List<MailroomsRecDetailWarpper> temporaryMailroomsRecDetailWarpper;
        
        public EABMailroomManagmentWrapper()
        {
            this.mailroomOptionsWrapper = new List<EABMailroomManagmentOptionsWarpper>{new EABMailroomManagmentOptionsWarpper('All', 'All')};
            this.userAllowedToAccessMailroom = false;
            this.mailroomsRecDetailWarpper = new List<MailroomsRecDetailWarpper>();
            this.userResponseRecDetailWarpper = new List<UserResponseRecDetailWarpper>();
            this.mapOfMailroomPrefixAndDevName = new Map<String, String>();
            this.temporaryMailroomsRecDetailWarpper = new List<MailroomsRecDetailWarpper>();
        }
    }
    
    //to hold mailroom options details in label and value formate    
    public class EABMailroomManagmentOptionsWarpper
    {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        
        public EABMailroomManagmentOptionsWarpper(String label, String value)
        {
            this.label = label;
            this.value = value;
        }
    }
    
    //to hold mailroom a inventory section details   
    public class MailroomsRecDetailWarpper
    {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String packageType;
        @AuraEnabled public String recipient;
        @AuraEnabled public String status;
        @AuraEnabled public String bin;
        @AuraEnabled public String action;
        @AuraEnabled public String prefix;
        
        public MailroomsRecDetailWarpper(Id id, String name, String packageType, String recipient, String status, 
                                         String bin, String action, String prefix)
        {
            this.id = id;
            this.name = name;
            this.packageType = packageType;
            this.recipient = recipient;
            this.status = status;
            this.bin = bin;
            this.action = action;
            this.prefix = prefix;
        }
    }
    
    //to hold user response details   
    public class UserResponseRecDetailWarpper
    {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String packageType;
        @AuraEnabled public String recipient;
        @AuraEnabled public String status;
        @AuraEnabled public String bin;
        @AuraEnabled public String action;
        @AuraEnabled public String prefix;
        
        public UserResponseRecDetailWarpper(Id id, String name, String packageType, String recipient, String status, 
                                            String bin, String action, String prefix)
        {
            this.id = id;
            this.name = name;
            this.packageType = packageType;
            this.recipient = recipient;
            this.status = status;
            this.bin = bin;
            this.action = action;
            this.prefix = prefix;
        }
    }
    
    //to hold package history details   
    public class MailPackageHistoryDetailWarpper
    {
        @AuraEnabled public Date actionDate;
        @AuraEnabled public String action;
        
        public MailPackageHistoryDetailWarpper(Date actionDate, String action)
        {
            this.actionDate = actionDate;
            this.action = action;            
        }
    }
}