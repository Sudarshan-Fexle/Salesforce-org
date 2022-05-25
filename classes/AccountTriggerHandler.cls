/**
*  Description     :  This class is for handle triggers of Account.
*
*  Created By      :  Sudarshan singh
*
*  Created Date    :  03/01/2022
*
*  Revision Logs   :  V1.0 - Created - Sudarshan Singh 
*
**/
public without sharing class AccountTriggerHandler {
    
    /**
    * 
    *   @description    :   In this method update the account number using rating field input. 
    *
    *   @args           :   List<Account>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 03/01/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void updateAccountNumber(List<Account> listOfNewAccount, Map<Id, Account> mapOfOldAccount){

        //Hold Accounts that are update.
        List<Account> listOfAccount = new List<Account>();

        if (listOfNewAccount.size() > 0) {

            //Loop for all the new accounts
            for (Account acc : listOfNewAccount) {

                //Check if the rating field is update or insert
                if (mapOfOldAccount != null && acc.Rating != mapOfOldAccount.get(acc.Id).Rating || mapOfOldAccount == null && acc.Rating != null) {
                    
                    //Add account to list for update
                    listOfAccount.add(acc);
                }
            }
        }

        if (listOfAccount.size() > 0) {
            
            //Loop for account that are present in listOfAccount.
            for(Account acc : listOfNewAccount){
                
                //Check if rating field is null or blank.
                if(String.isBlank(acc.Rating) || String.isEmpty(acc.Rating))
                    acc.AccountNumber = '0';
                
                //Check if rating field is Hot. 
                else if(acc.Rating.equals('Hot'))
                    acc.AccountNumber = '1';
    
                //Check if rating field is Cold.
                else if(acc.Rating.equals('Cold'))
                    acc.AccountNumber = '1234';
            }
        }
    }

    /**
    * 
    *   @description    :   Write a trigger to make the In-Active Reason field as required if someone select False in the Active field/ Throw an exception if Active is False and "In-Active Reason" field is blank. Message: "Please select In Active Reason for the Account". 
    *
    *   @args           :   List<Account>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 03/03/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void makeInActiveReasonFieldRequired(List<Account> listOfNewAccount, Map<Id, Account> mapOfOldAccount){

        //Hold Accounts that are update.
        List<Account> listOfAccount = new List<Account>();

        if (listOfNewAccount.size() > 0) {

            //Loop for all the new accounts
            for (Account acc : listOfNewAccount) {

                //Check if the active field is update or insert
                if (mapOfOldAccount != null && acc.Active__c != mapOfOldAccount.get(acc.Id).Active__c || mapOfOldAccount == null) {
                    listOfAccount.add(acc);
                }
            }
        }

        if (listOfAccount.size() > 0) {

            //Loop for account that are present in listOfAccount.
            for (Account acc : listOfAccount) {

                //Check if active field of account is false or blank then show error.
                if(acc.Active__c == 'False' && String.isBlank(acc.In_Active_Reason__c)){
                    acc.addError('Please select In Active Reason for the Account');
                }
            }
        }
    }

    /**
    * 
    *   @description    :   1. Create new Contacts under the Account record according to the values in "Contact Details" and "Contact Details 1" field. Keep Following things in mind while creating the records:
    *                           1.1: Contact should not exists under the Account, if contact is already there then no need to perform any action.
    *                           1.2: If there is any additional contact under the Account then delete that (Only delete if Previous Account field is blank)
    *                       2. If someone add contact details in "Move To Contacts" field and also populates the Move to Account then do following:
    *                           2.1: Move all the mentioned contacts (in Move to Contacts) field from current account to "Move to Account", and update the "Previous Account" lookup with current Account.
    *                           2.2: If someone change the Move to Account, then move all the contacts those are mentioned in "Move To Contacts" field from previous Move To Account to new Move TO Account.
    *                           2.3: if someone change the Move to Contacts details then move the additional contacts from current Account to Move to Account OR if someone remove the values from "Move To Contacts" field then move these contacts back to current Account. 
    *
    *   @args           :   List<Account>, Map<Id, Account>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 03/03/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void createContactUnderAccount(List<Account> listOfNewAccount, Map<Id, Account> mapOfOldAccount){

        Map<Id, Account> mapOfAccount = new Map<Id, Account>();

        for(Account acc : listOfNewAccount) {
            
            //Check if the Account is inserted or updated.
            if(mapOfOldAccount == null || acc.Contact_Details__c != mapOfOldAccount.get(acc.Id).Contact_Details__c 
                || acc.Contact_Details_1__c != mapOfOldAccount.get(acc.Id).Contact_Details_1__c || acc.Move_To_Account__c != mapOfOldAccount.get(acc.Id).Move_To_Account__c 
                || acc.Move_To_Contacts__c != mapOfOldAccount.get(acc.Id).Move_To_Contacts__c  )

                mapOfAccount.put(acc.Id, acc);
            
        }

        if (mapOfAccount.size() > 0) {

            //TO store all the new contacts from contact details and contact details 1
            Map<String, Contact> mapOfNewContact = new Map<String, Contact>();

            //Insert case
            if (mapOfOldAccount == null) {
                
                //Loop over the account change.
                for (Account acc : mapOfAccount.values()) {
                    
                    if (acc.Move_To_Contacts__c == null) {
                        
                        //Store all the new contacts 
                        List<String> getNewContactDetails = new List<String>();

                        //Check contact details is not null.
                        if(acc.Contact_Details__c != null)
                            getNewContactDetails.addAll(acc.Contact_Details__c.split('\r\n'));
                    
                        //Check contact details 1 is not null
                        if(acc.Contact_Details_1__c != null)
                            getNewContactDetails.addAll(acc.Contact_Details_1__c.split('\r\n'));
        
                        //Remove duplicate value from list
                        getNewContactDetails = new List<String>(new Set<String>(getNewContactDetails));

                        if(getNewContactDetails != null && getNewContactDetails.size() > 0){

                            //Loop over the new contacts in contact details and contact details 1.
                            for(String contact : getNewContactDetails){
                                String[] con = contact.split(',');
                                String firstName = con[0].substringAfter('=');
                                String lastName = con[1].substringAfter('=');
                                String email = con[2].substringAfter('=').trim();
                                
                                //Check firstname, lastname, email is not null.
                                if(String.isNotBlank(firstName) && String.isNotBlank(lastName) && String.isNotBlank(email)) 
                                    mapOfNewContact.put(acc.Id + firstName.trim() + lastName.trim() + email.trim(), new Contact(AccountId = acc.Id, FirstName = firstName.trim(), LastName = lastName.trim(), Email = email.trim()));
            
                            }
                        }
                    }else{
                        //If move to contact is not null.
                        acc.addError('No contact found to move');
                    }

                }
            }

            //Update case
            if (mapOfOldAccount != null) {

                //Store all the account Ids.
                Set<Id> setOfOldAccount = new Set<Id>();
                
                // if()
                    //Loop over the mapOfOldAccount
                    for (Account acc : mapOfOldAccount.values()) {
                        if(mapOfOldAccount.get(acc.Id).Move_To_Account__c != null)
                            setOfOldAccount.add(mapOfOldAccount.get(acc.Id).Move_To_Account__c);
                    }
    
                //Fetch all the contacts under account and move to account.
                Map<Id, Contact> mapOfOldContact = new Map<Id, Contact>([SELECT Id, AccountId, FirstName, LastName, Email, Previous_Account__c From Contact WHERE AccountId IN: mapOfAccount.keySet() OR AccountId IN: setOfOldAccount]);
    
                //Fetch all the contacts under account.
                Map<Id, Contact> mapOfContacts = new Map<Id, Contact>([SELECT Id, AccountId, FirstName, LastName, Email, Previous_Account__c From Contact WHERE AccountId IN: mapOfAccount.keySet()]);
                
                //Store all the contacts to move and retrieve.
                Map<String, Contact> mapOfContactToChange = new Map<String, Contact>();
                
                //Loop over the accounts that are change.
                for (Account acc : mapOfAccount.values()) {
                    
                    //Store all the new values of contact details and contact details 1.
                    List<String> getNewContactDetails = new List<String>();

                    //Store all the old values of contact details and contact details 1.
                    List<String> getOldContactDetails = new List<String>();

                    //Store all the new values of move to contacts.
                    List<String> getNewMoveToContacts = new List<String>();

                    //Store all the old values of move to contacts.
                    List<String> getOldMoveToContacts = new List<String>();

                    //Store all the new contact.
                    List<String> newContacts = new List<String>();

                    //Store all the new contacts to move.
                    List<String> newMoveContact = new List<String>();

                    //Store all the moved contacts.
                    List<String> moveContacts = new List<String>();

                    //Store all the contact that are remove from move to contact.
                    List<String> retrieveContacts = new List<String>();

                    //Store all the contacts that are present in contact details and contact details 1 to remove from delete contacts.
                    List<String> allContacts = new List<String>();
    
                    if(acc.Contact_Details__c != null)
                        getNewContactDetails.addAll(acc.Contact_Details__c.split('\r\n'));
                    
                    if(acc.Contact_Details_1__c != null)
                        getNewContactDetails.addAll(acc.Contact_Details_1__c.split('\r\n'));
    
                    //Remove duplicate values.
                    getNewContactDetails = new List<String>(new Set<String>(getNewContactDetails));
    
                    if(mapOfOldAccount.get(acc.Id).Contact_Details__c != null)
                        getOldContactDetails.addAll(mapOfOldAccount.get(acc.Id).Contact_Details__c.split('\r\n'));
                    
                    if(mapOfOldAccount.get(acc.Id).Contact_Details_1__c != null)
                        getOldContactDetails.addAll(mapOfOldAccount.get(acc.Id).Contact_Details_1__c.split('\r\n'));
    
                    //Remove duplicate values.
                    getOldContactDetails = new List<String>(new Set<String>(getOldContactDetails));
    
                    if (getNewContactDetails != null) {

                        //To insert new contacts that are not present in old contact details.
                        for (String newCon : getNewContactDetails) {    
                            if (!getOldContactDetails.contains(newCon)) {
                                newContacts.add(newCon);
                            }
                        }
                    }
    
                    if(acc.Move_To_Contacts__c != null)
                        getNewMoveToContacts.addAll(acc.Move_To_Contacts__c.split('\r\n'));
    
                    if(mapOfOldAccount.get(acc.Id).Move_To_Contacts__c != null)
                        getOldMoveToContacts.addAll(mapOfOldAccount.get(acc.Id).Move_To_Contacts__c.split('\r\n'));
    
                    if (getNewMoveToContacts != null) {

                        //Loop over new move to contacts
                        for (String changeCon : getNewMoveToContacts ) {

                            //Store all the new contacts to move that are not in old move to contacts.
                            if(!getOldMoveToContacts.contains(changeCon))
                                moveContacts.add(changeCon);
                            
                            //Store all the new contacts to move that are not in old move to contacts if move to account is change.
                            if (getOldMoveToContacts.contains(changeCon)) {
                                newMoveContact.add(changeCon);
                            }
                        }
                    }
                    
                    if (getOldMoveToContacts != null) {

                        //Loop over old move to contacts.
                        for (String changeCon : getOldMoveToContacts) {

                            //Store all the contacts that are not in new move to contact to retrieve.
                            if (!getNewMoveToContacts.contains(changeCon)) {
                                retrieveContacts.add(changeCon);
                            }
                            
                        }
                    }
    
                    if(getNewContactDetails != null){
                        for(String contact : getNewContactDetails){
                            String[] con = contact.split(',');
                            String firstName = con[0].substringAfter('=');
                            String lastName = con[1].substringAfter('=');
                            String email = con[2].substringAfter('=').trim();
                            
                            //Check firstname, lastname, email is not null.
                            if(String.isNotBlank(firstName) && String.isNotBlank(lastName) && String.isNotBlank(email))
                                
                                //Store all the new key to remove contacts from delete.
                                allContacts.add(acc.Id + firstName.trim() + lastName.trim() + email.trim());
                                allContacts.add(mapOfOldAccount.get(acc.Id).Move_To_Account__c + firstName.trim() + lastName.trim() + email.trim());
        
                        }
                    }
    
                    if(newContacts != null){
                        for(String contact : newContacts){
                            String[] con = contact.split(',');
                            String firstName = con[0].substringAfter('=');
                            String lastName = con[1].substringAfter('=');
                            String email = con[2].substringAfter('=').trim();
                            
                            //Check firstname, lastname, email is not null.
                            if(String.isNotBlank(firstName) && String.isNotBlank(lastName) && String.isNotBlank(email)) 

                                //To insert new contacts to account
                                mapOfNewContact.put(acc.Id + firstName.trim() + lastName.trim() + email.trim(), new Contact(AccountId = acc.Id, FirstName = firstName.trim(), LastName = lastName.trim(), Email = email.trim()));
        
                        }
                    }
    
                    if (newMoveContact != null) {
                        for (String contact : newMoveContact) {
                            String[] con = contact.split(',');
                            String firstName = con[0].substringAfter('=');
                            String lastName = con[1].substringAfter('=');
                            String email = con[2].substringAfter('=').trim();
    
                            //Check firstname, lastname, email is not null and move to account and old move to account is not null and new and old move to account is not same.
                            if(String.isNotBlank(firstName) && String.isNotBlank(lastName) && String.isNotBlank(email) && acc.Move_To_Account__c != null && acc.Move_To_Account__c != mapOfOldAccount.get(acc.Id).Move_To_Account__c && mapOfOldAccount.get(acc.Id).Move_To_Account__c != null)
                                mapOfContactToChange.put(mapOfOldAccount.get(acc.Id).Move_To_Account__c + firstName.trim() + lastName.trim() + email.trim(), new Contact(AccountId = acc.Move_To_Account__c, FirstName = firstName.trim(), LastName = lastName.trim(), Email = email.trim(), Previous_Account__c = acc.Id));    
                        }
                    }
    
                    if (moveContacts != null) {
                        for (String contact : moveContacts) {
                            String[] con = contact.split(',');
                            String firstName = con[0].substringAfter('=');
                            String lastName = con[1].substringAfter('=');
                            String email = con[2].substringAfter('=').trim();
    
                            //Check firstname, lastname, email is not null and move to account is not null.
                            if(String.isNotBlank(firstName) && String.isNotBlank(lastName) && String.isNotBlank(email) && acc.Move_To_Account__c != null)
                                mapOfContactToChange.put(acc.Id + firstName.trim() + lastName.trim() + email.trim(), new Contact(AccountId = acc.Move_To_Account__c, FirstName = firstName.trim(), LastName = lastName.trim(), Email = email.trim(), Previous_Account__c = acc.Id));

                        }
                    }
    
                    if (retrieveContacts != null) {
                        
                        for (String contact : retrieveContacts) {
                            String[] con = contact.split(',');
                            String firstName = con[0].substringAfter('=');
                            String lastName = con[1].substringAfter('=');
                            String email = con[2].substringAfter('=').trim();

                            //Check firstname, lastname, email is not null 
                            if(String.isNotBlank(firstName) && String.isNotBlank(lastName) && String.isNotBlank(email))
                                mapOfContactToChange.put(mapOfOldAccount.get(acc.Id).Move_To_Account__c + firstName.trim() + lastName.trim() + email.trim(), new Contact(AccountId = acc.Id, FirstName = firstName.trim(), LastName = lastName.trim(), Email = email.trim(), Previous_Account__c = null));
    
                        }
                    }
    
                    for (Contact con : mapOfContacts.values()) {
                        
                        //Remove id from map of contacts to not delete.
                        if(allContacts.contains(con.AccountId + con.FirstName + con.LastName + con.Email)){
                            mapOfContacts.remove(con.Id);
                        }
                        
                        //Remove id from map of contacts where previous account is not null
                        if (con.Previous_Account__c != null) {
                            mapOfContacts.remove(con.Id);
                        }
                    }
                }

                if(mapOfOldContact != null){
                    for(Contact con : mapOfOldContact.values()) {
                        
                        //To update contact id if contacts key are present is mapOfContactTochange.
                        if (mapOfContactToChange.containsKey(con.AccountId + con.FirstName + con.LastName + con.Email)) {
                            mapOfContactToChange.get(con.AccountId + con.FirstName + con.LastName + con.Email).Id = con.Id; 
                        }
                    }
                }

                if (mapOfContactToChange != null) {
                    //Update changed contacts that are move or retrieve.
                    update mapOfContactToChange.values();
                }
    
                if(mapOfContacts != null) {
                    //Delete all the contacts that are not required.
                    delete mapOfContacts.values();
                }
            }

            if (mapOfNewContact != null ) {
                //Insert all the new contacts.
                insert mapOfNewContact.values();
            }
        }
    }

}








// public static void createContactUnderAccount(Map<Id, Account> mapOfNewAccount, Map<Id, Account> mapOfOldAccount){
//     Map<Id, Account> mapOfAccount = new Map<Id, Account>();

//     for(Account acc : mapOfNewAccount.values()) {
        
//         if(mapOfOldAccount == null || mapOfOldAccount.get(acc.id).Contact_Details__c != acc.Contact_Details__c || mapOfOldAccount.get(acc.Id).Contact_Details_1__c != acc.Contact_Details_1__c || mapOfOldAccount.get(acc.Id).Move_To_Account__c != acc.Move_To_Account__c || mapOfOldAccount.get(acc.Id).Move_To_Contacts__c != acc.Move_To_Contacts__c){
//             mapOfAccount.put(acc.Id, acc);
//         }    
//     }

//     if (mapOfAccount.size() > 0) {

//         List<String> listOfNewContactState = new List<String>();
//         List<String> listOfOldContactState = new List<String>();
//         List<String> listOfNewContact = new List<String>();
//         List<String> listOfMoveContact = new List<String>();

//         List<Contact> listOfContactToInsert = new List<Contact>();
//         List<Contact> listOfContactToDelete = new List<Contact>();
//         List<Contact> listOfContactToMove = new List<Contact>();
//         List<Contact> listOfContactToMoveBack = new List<Contact>();

//         //Insert new Contacts
//         if (mapOfOldAccount == null && mapOfNewAccount != null) {
            
//             for (Account acc : mapOfAccount.values()) {
                
//                 if(acc.Move_To_Contacts__c == null){
                    
//                     if(acc.Contact_Details__c != null)
//                         listOfNewContactState.addAll(acc.Contact_Details__c.split('\r\n'));
                    
//                     if(acc.Contact_Details_1__c != null)
//                         listOfNewContactState.addAll(acc.Contact_Details_1__c.split('\r\n'));
                    
//                     listOfNewContactState = new List<String>(new Set<String>(listOfNewContactState));

//                     if(listOfNewContactState != null){

//                         for(String contact : listOfNewContactState){
//                             String[] con = contact.split(',');
//                             String firstName = con[0].substringAfter('=');
//                             String lastName = con[1].substringAfter('=');
//                             String email = con[2].substringAfter('=').trim();
                        
//                             if(String.isNotBlank(firstName) && String.isNotBlank(lastName) && String.isNotBlank(email))
//                                 listOfContactToInsert.add(new Contact(AccountId = acc.Id, FirstName = firstName.trim(), LastName = lastName.trim(), Email = email.trim()));
//                         }
//                     }

//                 }else
//                     acc.addError('No contacts found to move.');
//             }
//         }

//         //Update contacts
//         if(mapOfOldAccount != null && mapOfNewAccount != null){

//             for (Account acc : mapOfAccount.values()) {

//                 if(acc.Contact_Details__c != null)
//                     listOfNewContactState.addAll(acc.Contact_Details__c.split('\r\n'));
                
//                 if(acc.Contact_Details_1__c != null)
//                     listOfNewContactState.addAll(acc.Contact_Details_1__c.split('\r\n'));
                
//                 listOfNewContactState = new List<String>(new Set<String>(listOfNewContactState));
                
//                 if(mapOfOldAccount.get(acc.Id).Contact_Details__c != null)
//                     listOfOldContactState.addAll(mapOfOldAccount.get(acc.Id).Contact_Details__c.split('\r\n'));
                
//                 if(mapOfOldAccount.get(acc.Id).Contact_Details_1__c != null)
//                     listOfOldContactState.addAll(mapOfOldAccount.get(acc.Id).Contact_Details_1__c.split('\r\n'));
                    
//                 listOfOldContactState = new List<String>(new Set<String>(listOfOldContactState));

//                 if(acc.Move_To_Contacts__c != null)
//                     listOfMoveContact.addAll(acc.Move_To_Contacts__c);
                    
//                 for (String con : listOfNewContactState){
//                     if (!listOfOldContactState.contains(con))
//                         listOfNewContact.add(con);
//                 }

//                 if(listOfNewContact != null){

//                     for(String contact : listOfNewContact){
//                         String[] con = contact.split(',');
//                         String firstName = con[0].substringAfter('=');
//                         String lastName = con[1].substringAfter('=');
//                         String email = con[2].substringAfter('=').trim();
                    
//                         if(String.isNotBlank(firstName) && String.isNotBlank(lastName) && String.isNotBlank(email))
//                             listOfContactToInsert.add(new Contact(AccountId = acc.Id, FirstName = firstName.trim(), LastName = lastName.trim(), Email = email.trim()));
//                     }
//                 }

//                 if(listOfMoveContact != null){

//                     for(String contact : listOfMoveContact){
//                         String[] con = contact.split(',');
//                         String firstName = con[0].substringAfter('=');
//                         String lastName = con[1].substringAfter('=');
//                         String email = con[2].substringAfter('=').trim();
                    
//                         if(String.isNotBlank(firstName) && String.isNotBlank(lastName) && String.isNotBlank(email))
//                             listOfContactToMove.add(new Contact(AccountId = acc.Move_To_Account__c, FirstName = firstName.trim(), LastName = lastName.trim(), Email = email.trim(), Previous_Account__c  = acc.Id));
//                     }
//                 }

//             }

//         }  

//         if(listOfContactToInsert != null)
//             insert listOfContactToInsert;

//     }
// }


//line 353
// if(String.isNotBlank(firstName) && String.isNotBlank(lastName) && String.isNotBlank(email) && acc.Move_To_Account__c != null && acc.Move_To_Account__c != mapOfOldAccount.get(acc.Id).Move_To_Account__c && mapOfOldAccount.get(acc.Id).Move_To_Account__c == null)
//     mapOfContactToChange.put(acc.Id + firstName.trim() + lastName.trim() + email.trim(), new Contact(AccountId = acc.Move_To_Account__c, FirstName = firstName.trim(), LastName = lastName.trim(), Email = email.trim(), Previous_Account__c = acc.Id));

// if(String.isNotBlank(firstName) && String.isNotBlank(lastName) && String.isNotBlank(email) && acc.Move_To_Account__c != null && acc.Move_To_Account__c == mapOfOldAccount.get(acc.Id).Move_To_Account__c)
//     mapOfContactToChange.put(acc.Id + firstName.trim() + lastName.trim() + email.trim(), new Contact(AccountId = acc.Move_To_Account__c, FirstName = firstName.trim(), LastName = lastName.trim(), Email = email.trim(), Previous_Account__c = acc.Id));

// if(String.isNotBlank(firstName) && String.isNotBlank(lastName) && String.isNotBlank(email) && acc.Move_To_Account__c != null && acc.Move_To_Account__c != mapOfOldAccount.get(acc.Id).Move_To_Account__c && mapOfOldAccount.get(acc.Id).Move_To_Account__c != null)
//     mapOfContactToChange.put(acc.Id + firstName.trim() + lastName.trim() + email.trim(), new Contact(AccountId = acc.Move_To_Account__c, FirstName = firstName.trim(), LastName = lastName.trim(), Email = email.trim(), Previous_Account__c = acc.Id));
     
//line 368
// if(String.isNotBlank(firstName) && String.isNotBlank(lastName) && String.isNotBlank(email) && acc.Move_To_Account__c == null && acc.Move_To_Account__c != mapOfOldAccount.get(acc.Id).Move_To_Account__c)
//     mapOfContactToChange.put(mapOfOldAccount.get(acc.Id).Move_To_Account__c + firstName.trim() + lastName.trim() + email.trim(), new Contact(AccountId = acc.Id, FirstName = firstName.trim(), LastName = lastName.trim(), Email = email.trim(), Previous_Account__c = null));

// if(String.isNotBlank(firstName) && String.isNotBlank(lastName) && String.isNotBlank(email) && acc.Move_To_Account__c != null && acc.Move_To_Account__c == mapOfOldAccount.get(acc.Id).Move_To_Account__c)
//     mapOfContactToChange.put(mapOfOldAccount.get(acc.Id).Move_To_Account__c + firstName.trim() + lastName.trim() + email.trim(), new Contact(AccountId = acc.Id, FirstName = firstName.trim(), LastName = lastName.trim(), Email = email.trim(), Previous_Account__c = null));

// if(String.isNotBlank(firstName) && String.isNotBlank(lastName) && String.isNotBlank(email) && acc.Move_To_Account__c != null && acc.Move_To_Account__c != mapOfOldAccount.get(acc.Id).Move_To_Account__c && mapOfOldAccount.get(acc.Id).Move_To_Account__c != null)
//     mapOfContactToChange.put(mapOfOldAccount.get(acc.Id).Move_To_Account__c + firstName.trim() + lastName.trim() + email.trim(), new Contact(AccountId = acc.Id, FirstName = firstName.trim(), LastName = lastName.trim(), Email = email.trim(), Previous_Account__c = null));