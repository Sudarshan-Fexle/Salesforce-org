/**
*   Description     :   This Batch Class is used to Remove Managed Package Licenses for inactive users.
*
*   Created by      :   Shalu Sharma
*
*   Created Date    :   02/1/2022
*
*   Revision Log    :   V1.0 - Created - Shalu Sharma - CR-20220125-15750 - Remove Managed Package Licenses
*/
global without sharing class Batch_AutoRemovalUserPackageLicense implements Database.Batchable<sObject>, Database.Stateful 
{
    public String debugLog = '';
    public String query = '';
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //to hold the time before 72 hours
        DateTime users72HrsPrior =  DateTime.now().addHours(-72);
        
        //to avoid the execution on test
        if(String.isBlank(query))
        {
            query = 'Select Id, isActive, LastModifiedDate FROM User WHERE isActive = false AND LastModifiedDate <=: users72HrsPrior';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<User> listOfUsers)
    {
        String logMessage = '';
        Set<Id> setOfUserIds = new Set<Id>();
        List<UserPackageLicense> userPackageLicenseToBeDeleted = new List<UserPackageLicense>();
        
        //for loop on the users list which is inactivated before 72 hours
        for(User user : listOfUsers) 
        {
        	setOfUserIds.add(user.Id);   
        }
        
        //check list size
        if(setOfUserIds.size() > 0 )
        {
            //get the user license records on the basis of the user ids
            for(UserPackageLicense userPkgLicense : [SELECT Id FROM UserPackageLicense WHERE UserId	IN : setOfUserIds])
            {
            	userPackageLicenseToBeDeleted.add(userPkgLicense);    
            }
            
            //delete the user license records
            if(userPackageLicenseToBeDeleted.size() > 0 )
            {
                //bypass the trigger
                Util.BypassAllTriggers = true;
                logMessage = Util.createLog(Database.delete(userPackageLicenseToBeDeleted,false));
                Util.BypassAllTriggers = false;
                
                if(String.isNotBlank(logMessage)) 
                {
                    debugLog += logMessage;
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        //send the email to system admin
        if(String.isNotBlank(debugLog))
        {
            Util.sendBatchStatus(BC.getJobId(), 'Batch_AutoRemovalUserPackageLicense', debugLog, System.Label.Salesforce_Admin_Email);  
        }
    }
}