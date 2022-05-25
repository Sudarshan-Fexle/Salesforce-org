/**
*  Description     :  This class is for create contacts under Account.
*
*  Created By      :  Sudarshan singh
*
*  Created Date    :  02/20/2022
*
*  Revision Logs   :  V1.0 - Created - Sudarshan Singh 
*
**/
public with sharing class CreateContactsUnderAccount {
    
    /**
    * 
    *   @description    :   In this method validate contacts under Accounts. 
    *
    *   @args           :   None
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 02/20/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void validateContactsUnderAccount(List<Id> listOfId){
        
        List<Account> listOfAccount = [SELECT Id, Contact_Details__c FROM Account WHERE Id IN: listOfId];

        //Create list for store contacts from string.
        List<Contact> listOfNewContact = new List<Contact>();
        //Loop for each account.
        for (Account acc : listOfAccount) {
            
            //Spliting the string that is obtain from contacs details field.
            String[] getContactDetails = acc.Contact_Details__c.split('\n');
            for(String contact : getContactDetails){
                String[] con = contact.split(',');
                String firstName = con[0].substringAfter('=');
                String lastName = con[1].substringAfter('=');
                String email = con[2].substringAfter('=').trim();
                
                //Check firstname, lastname, email is not null.
                if(String.isNotBlank(firstName) && String.isNotBlank(lastName) && String.isNotBlank(email)){ 
                    //Add contact to listOfNewContact list.
                    listOfNewContact.add(new Contact(AccountId = acc.Id, FirstName = firstName.trim(), LastName = lastName.trim(), Email = email.trim()));
                }
            }
        }

        //Fetch all the contacts under account.
        List<Contact> listOfOldContact = [SELECT Id, AccountId, FirstName, LastName, Email From Contact WHERE AccountId IN: listOfId ];
        
        Set<Id> setOfContactId = new Set<Id>();
        
        //Store all the id of contact in set.
        for (Contact con : listOfOldContact) {
            setOfContactId.add(con.Id);
        }

        for (Integer i = 0; i < listOfNewContact.size(); i++) {
            for (Contact conn : listOfOldContact) {
                if ((listOfNewContact[i].AccountId + listOfNewContact[i].FirstName + listOfNewContact[i].LastName + listOfNewContact[i].Email).equals(conn.AccountId + conn.FirstName + conn.LastName + conn.Email)) {
                    
                    //Remove duplicate contact.
                    listOfNewContact.remove(i);

                    //Remove id of duplicate contact.
                    setOfContactId.remove(conn.Id);
                }
            }
        }
        
        //Fetch all the contacts that are not in listOfNewContact list to delete.
        List<Contact> listOfDeleteContact = [SELECT Id FROM Contact WHERE Id IN: setOfContactId];

        //Insert new Contact
        if(listOfNewContact.size() > 0)
            insert listOfNewContact;
        
        //Delete extra Contact.
        if(listOfDeleteContact.size() > 0)
            delete listOfDeleteContact;
    
    
    }
}