/**
*  Description     :  Helper class for EmailSubscriptionTrigger trigger.
*
*  Created By      :  Dipesh Gupta
*
*  Created Date    :  09/09/2019
* 
*  Revision Logs   :   V_1.0 - Created - Dipesh Gupta - CR-20190107-12810
*                   
**/ 
public class EmailSubscriptionTriggerHelper {
    
    public static void populateEmailSubcriptionFields(List<Email_Subscription__c> emailSubcriptions, Map<Id, Email_Subscription__c> mapOldEmailSubcriptions) {
        
        //Set to hold the Account Ids
        Set<Id> setOfAccountIds = new Set<Id>();
        
        //Set to hold the Email Subscription Ids
        Set<Id> setOfEmailSubIds = new Set<Id>();
        
        //Map Of Program Ids with respect to Membership Ids
        Map<String, Id> mapProgIdAccIdWithMemId =  new Map<String, Id>();   

        //Map to hold the subscription Id with the Termination date value. 
        Map<Id, Date> mapSubIdWithTerminationDate = new Map<Id, Date>();
        
        //Loop over the New Eamil Subscription 
        for(Email_Subscription__c newEmailSub : emailSubcriptions) {
            
            if(mapOldEmailSubcriptions == null   || mapOldEmailSubcriptions != null && 
               ((mapOldEmailSubcriptions.get(newEmailSub.Id).Contact__c != newEmailSub.Contact__c)||
                (mapOldEmailSubcriptions.get(newEmailSub.Id).Lead__c != newEmailSub.Lead__c) ||
                (mapOldEmailSubcriptions.get(newEmailSub.Id).Active__c != newEmailSub.Active__c) ||
                (mapOldEmailSubcriptions.get(newEmailSub.Id).Email_Subscription_Option__c != newEmailSub.Email_Subscription_Option__c))){
                    
                    //Adding Email Subscription Ids
                    setOfEmailSubIds.add(newEmailSub.Id);

                    //Check for the Active value. If this is an update case and Active is changed from true to false
                    if(mapOldEmailSubcriptions != null && newEmailSub.Active__c != mapOldEmailSubcriptions.get(newEmailSub.Id).Active__c 
                        && newEmailSub.Active__c == false ) 
                        //Map to hold the Date if the Active is selected as false
                        mapSubIdWithTerminationDate.put(newEmailSub.Id, Date.today());

                    else if (mapOldEmailSubcriptions != null && newEmailSub.Active__c != mapOldEmailSubcriptions.get(newEmailSub.Id).Active__c 
                        && newEmailSub.Active__c == true) {
                        mapSubIdWithTerminationDate.put(newEmailSub.Id, null);
                    }   
                }
        }
        
        //Check for the size of set.
        if(setOfEmailSubIds.size() > 0 ) {

            //Query Over Email Subscription
            List<Email_Subscription__c> emailSubToBeUpdate = [SELECT Id,Contact__c, Contact__r.Name,Contact__r.Counter_Id__c,Contact__r.AccountId,
                                                           Email_Subscription_Option__r.Name, Email_Subscription_Option__r.Counter_Id__c,
                                                           Email_Subscription_Option__r.Program__c,Membership__c,
                                                           Lead__r.Name,Lead__r.Counter_Id__c, Termination_Date__c, Active__c
                                                           FROM Email_Subscription__c WHERE Id IN: setOfEmailSubIds];

            //Check for Set of Sub  
            if(emailSubToBeUpdate.size() > 0){

                //Loop Over Email Subscription
                for(Email_Subscription__c emailSub : emailSubToBeUpdate)
                    //adding Account Id
                    setOfAccountIds.add(emailSub.Contact__r.AccountId);
                
            
                //Check for Set of Institution  
                if(setOfAccountIds.size() > 0){
                    
                    //loop to get membership related to set of Institution
                    for (Membership__c mem : [SELECT Id,  Account_Name__c, Program__c FROM Membership__c WHERE Account_Name__c IN: setOfAccountIds] ){
                        
                        String uniqueKey = mem.Program__c + ' - ' + mem.Account_Name__c;

                        //Putting Program Id with Membership Id 
                        mapProgIdAccIdWithMemId.put(uniqueKey, mem.Id); 
                    }
                }
                
                //Email subscription to be updated.
                for(Email_Subscription__c emailSub : emailSubToBeUpdate){
                    
                    //Email Subscription Name Populate
                    emailSub.Name = String.isNotBlank(emailSub.Contact__c) ? emailSub.Contact__r.Name + '-' + emailSub.Email_Subscription_Option__r.Name : emailSub.Lead__r.Name + '-' + emailSub.Email_Subscription_Option__r.Name;
                    
                    //Email Subscription External Id Populate
                    emailSub.External_Id__c = String.isNotBlank(emailSub.Contact__c) ? emailSub.Contact__r.Counter_Id__c + '-' + emailSub.Email_Subscription_Option__r.Counter_Id__c : emailSub.Lead__r.Counter_Id__c + '-' + emailSub.Email_Subscription_Option__r.Counter_Id__c;
                    
                    //Email Subscription Institution Populate
                    emailSub.Institution__c = emailSub.Contact__r.AccountId;
                    
                    //String to hold the email sub Program and Contact Id. 
                    String uniqueKey = emailSub.Email_Subscription_Option__r.Program__c + ' - ' + emailSub.Contact__r.AccountId;

                    //Populating membership
                    emailSub.Membership__c = mapProgIdAccIdWithMemId.containsKey(uniqueKey) ? mapProgIdAccIdWithMemId.get(uniqueKey): null;
                    
                    //Check for the Termination Date. 
                    emailSub.Termination_Date__c = mapSubIdWithTerminationDate.containsKey(emailSub.Id) ? mapSubIdWithTerminationDate.get(emailSub.Id) : emailSub.Termination_Date__c;
                }
                
                //Size check over updated list 
                if(emailSubToBeUpdate.size() > 0)
                   //Updating Email Subscription with new populated fields value 
                    update emailSubToBeUpdate;
                   
            }

        }
       
    }
    
    /**
        *  Description     :  Method to check the duplicates if dup exist then we have the certain set of rules to make the changes. 
        *
        *  Created By      :  Dipesh Gupta
        *
        *  Created Date    :  09/09/2019
        * 
        *  Revision Logs   :   V_1.0 - Created - Dipesh Gupta - CR-20190107-12810
        *                   
    **/
    public static void verifyEmailDuplicacy(List<Email_Subscription__c> emailSubcriptions, Map<Id, Email_Subscription__c> mapOldEmailSubcriptions){
        
              
        //Set to hold the Contact Ids
        Set<Id> setOfContactIds = new Set<Id>();
        
        //Set to hold the Contact Ids
        Set<Id> setOfLeadIds = new Set<Id>();
        
        //Set to hold the Contact Ids
        Set<Id> setOfEmailSubOppIds = new Set<Id>();
        
        //Map of Contact-EmailSubscriptionOption with Email Subscription 
        Map<String, List<Email_Subscription__c>> mapOfEmailSub = new Map<String, List<Email_Subscription__c>>();
        
        //Set to hold the Contact Ids
        Set<Id> setOfOfEmailSubToBeDeleteIds = new Set<Id>();
        
        //Loop over the Updated Eamil Subscription 
        for(Email_Subscription__c newEmailSub : emailSubcriptions) {
            
            //Contact Update
            if((newEmailSub.Contact__c != null || newEmailSub.Lead__c != null) 
               && (mapOldEmailSubcriptions == null 
                   || (newEmailSub.Contact__c != mapOldEmailSubcriptions.get(newEmailSub.ID).Contact__c 
                       || newEmailSub.Lead__c != mapOldEmailSubcriptions.get(newEmailSub.ID).Lead__c))) {
                       
                		//Adding Contact Ids
                       setOfContactIds.add(newEmailSub.Contact__c);
                       
                       //Adding Email Subscription Option
                       setOfEmailSubOppIds.add(newEmailSub.Email_Subscription_Option__c);
                       
                       //Adding Lead Ids
                       setOfLeadIds.add(newEmailSub.Lead__c);
                       
                   }
        }
        
        //check for size
        if(setOfContactIds.size() > 0 || setOfLeadIds.size() > 0 ){
            
            
            for(Email_Subscription__c eS : [SELECT Id, Active__c, CreatedDate, Lead__c, Contact__c, Email_Subscription_Option__c FROM Email_Subscription__c 
                                            WHERE (Contact__c IN: setOfContactIds OR Lead__c IN: setOfLeadIds) AND Email_Subscription_Option__c IN: setOfEmailSubOppIds Order BY CreatedDate ASC ]){
                                       
                 if(eS.Active__c == True){
                     //To verify duplicate took an unique key to identify                           
                     String unique_key =  String.isBlank(eS.Contact__c) ? eS.Lead__c + '-' +es.Email_Subscription_Option__c : eS.Contact__c + '-' +es.Email_Subscription_Option__c; 
                     
                     if(!mapOfEmailSub.containsKey(unique_key))
                         mapOfEmailSub.put(unique_key, new List<Email_Subscription__c>());
                     
                     mapOfEmailSub.get(unique_key).add(eS);
                     
                 }
                 else{
                    setOfOfEmailSubToBeDeleteIds.add(eS.Id);                               
                 }
             }
            //Loop over the Updated Eamil Subscription 
            for(Email_Subscription__c newEmailSub : emailSubcriptions) {
                
                //To verify duplicate took an unique key to identify                           
                String unique_key =  String.isBlank(newEmailSub.Contact__c) ? newEmailSub.Lead__c + '-' +newEmailSub.Email_Subscription_Option__c : newEmailSub.Contact__c + '-' +newEmailSub.Email_Subscription_Option__c;                      
                
                
                if(mapOfEmailSub.containsKey(unique_key)){
                
                    Datetime earliestDate =mapOfEmailSub.get(unique_key)[0].CreatedDate;
                    
                    for(Email_Subscription__c emailSub : mapOfEmailSub.get(unique_key)) {
                                               
                        //Check for Earliest Date Comperision
                        if(emailSub.CreatedDate > earliestDate){

                            //adding email subscription for delete
                            setOfOfEmailSubToBeDeleteIds.add(emailSub.Id);
                        }
                    }
                    
                } 
            }
        }
                
        if(setOfOfEmailSubToBeDeleteIds.size() > 0 ){

            //calling future method to for deleting duplicate
            deleteDuplicate(setOfOfEmailSubToBeDeleteIds);
        }
    }
    
    
    @future
    public static void deleteDuplicate(Set<Id> setOfSubscriptionId){
                
        //fetching the duplicates
        List<Email_Subscription__c> listOfEmailSubToBeDelete = [SELECT Id FROM Email_Subscription__c WHERE Id IN :setOfSubscriptionId ];
        
        if(listOfEmailSubToBeDelete.size() > 0 ){
            
            //deleting duplicate
            delete listOfEmailSubToBeDelete;
        }
    }
}