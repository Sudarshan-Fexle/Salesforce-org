/**
*  Description     :  This class is for handle triggers on Contact.
*
*  Created By      :  Sudarshan singh
*
*  Created Date    :  03/05/2022
*
*  Revision Logs   :  V1.0 - Created - Sudarshan Singh 
*
**/
public without sharing class ContactTriggerHandler {
    
    /**
    * 
    *   @description    :   Write a trigger to populate Total Active Contact and Total In Active Contacts field with the total Active and inactive contacts under the Account.
    *
    *   @args           :   List<Account>, Map<Id, Contact>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 03/05/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void updateStatusCountOnAccount(List<Contact> listOfNewContact, Map<Id, Contact> mapOfOldContact){

        //Map to hold Updated Accounts
        Map<Id,Account> mapOfIdAccount = new Map<Id, Account>();
        
        //Traverse on contact records
        for (Contact con : (listOfNewContact != null ? listOfNewContact : mapOfOldContact.values())) {
            
            //Check valid condition for update, insert and delete
            if (mapOfOldContact != null && con.Status__c != mapOfOldContact.get(con.Id).Status__C || mapOfOldContact == null || listOfNewContact == null && mapOfOldContact != null || con.AccountId != mapOfOldContact.get(con.Id).AccountId) {
                
                //Check if aacount id is not null
                if(con.AccountId != null )
                    mapOfIdAccount.put(con.AccountId, new Account(Id = con.AccountId, Total_Active_Contacts__c = 0, Total_In_Active_Contacts__c = 0));
    
                //Check for update
                if(mapOfOldContact != null && mapOfOldContact.get(con.Id).AccountId != null )
                    mapOfIdAccount.put(mapOfOldContact.get(con.Id).AccountId, new Account(Id = mapOfOldContact.get(con.Id).AccountId, Total_Active_Contacts__c = 0, Total_In_Active_Contacts__c = 0));
            }
        }
        
        if(mapOfIdAccount.size() > 0){

            //Getting the aggregate query result 
            for (AggregateResult arResult : [SELECT AccountId, COUNT(Id) totalcount, Status__c FROM Contact 
                                         WHERE AccountId IN: mapOfIdAccount.keySet() GROUP BY AccountId, Status__C]){

                Id accId = (Id)arResult.get('AccountId');
                String status = (String)arResult.get('Status__c');

                //Check if status is active then store the value of count in total active contats.
                if(status == 'Active'){
                    mapOfIdAccount.get(accId).Total_Active_Contacts__c = (Integer)arResult.get('totalcount');
                }

                //Check if status is in-active then store the value of count in total in-active contats.
                else if (status == 'In Active') {
                    mapOfIdAccount.get(accId).Total_In_Active_Contacts__c = (Integer)arResult.get('totalcount');
                }
            }

            if (mapOfIdAccount.size() > 0) {

                //Update accounts
                update mapOfIdAccount.values();
            }

        }

    }

    /**
    * 
    *   @description    :   Write a trigger to populate Total Active Contact and Total In Active Contacts field with the total Active and inactive contacts under the Account.
    *
    *   @args           :   List<Account>, Map<Id, Contact>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 03/05/2022 - Sudarshan singh - Comment
    * 
    **/
    // public static void createUserProfile(List<Contact> listOfNewContact, Map<Id, Contact> mapOfOldContact){

    //     Map<Id, Contact> mapOfInsertedContact = new Map<Id, Contact>();
    //     Map<Id, Contact> mapOfUpdatedContact = new Map<Id, Contact>();
        

    //     for (Contact con : (listOfNewContact != null) ? listOfNewContact : mapOfOldContact.values()) {
    //         if (String.isNotBlank(con.Email)) {
    //             if (mapOfOldContact == null) {
    //                 mapOfInsertedContact.put(con.Id, con);
    //             }

    //             if (mapOfOldContact != null && con.LastName != mapOfOldContact.get(con.Id).LastName && 
    //                 con.FirstName != mapOfOldContact.get(con.Id).FirstName && con.Email != mapOfOldContact.get(con.Id).Email) {
    //                  mapOfUpdatedContact.put(con.Id, con);
    //             }
    //         }
    //     }

    //     Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
    //     UserRole userRoleId = [SELECT Id FROM UserRole WHERE Name=: 'CEO' limit 1];

    //     //Insert user
    //     if (mapOfInsertedContact.size() > 0) {
            
    //         List<User> listOfNewUser = new List<User>();
    //         for (Contact con : mapOfInsertedContact.values()) {
    //             User newUser = new User();
    //             newUser.FirstName = con.FirstName;
    //             newUser.LastName = con.LastName;
    //             newUser.Email = con.Email;
    //             newUser.Alias = con.LastName;
    //             newUser.Username = con.FirstName + con.Email;
    //             newUser.CommunityNickname = con.LastName;
    //             newUser.LocaleSidKey = 'en_US';
    //             newUser.TimeZoneSidKey = 'GMT';
    //             newUser.ProfileId = profileId.Id;
    //             newUser.LanguageLocaleKey = 'en_US';
    //             newUser.EmailEncodingKey = 'UTF-8';
    //             newUser.ContactId = con.Id;
    //             newUser.UserRoleId = userRoleId.Id;
    //             listOfNewUser.add(newUser);

    //             //setup or non setup object mixed DML
    //         }

    //         if (listOfNewUser != null) 
    //             insert listOfNewUser;
    //     }

    //     //Update user
    //     if (mapOfUpdatedContact.size() > 0) {
              
    //         List<User> listOfUpdatedUser = [SELECT FirstName, LastName, Email, Contact.FirstName, Contact.LastName, Contact.Email FROM User WHERE ContactId IN: mapOfUpdatedContact.keySet()];
    //         for (User u : listOfUpdatedUser) {
    //             u.FirstName = u.Contact.FirstName;
    //             u.LastName = u.Contact.LastName;
    //             u.Email = u.Contact.Email;
    //             u.Alias = u.Contact.LastName;
    //             u.Username = u.Contact.FirstName + u.Contact.Email;
    //         }
    //         if (listOfUpdatedUser.size() > 0)
    //             update listOfUpdatedUser;
    //     }

    // }

}