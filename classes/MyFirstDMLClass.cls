/**
*  Description     :  This class is for implementation of DML.
*
*  Created By      :  Sudarshan singh
*
*  Created Date    :  02/07/2022
*
*  Revision Logs   :  V1.0 - Created - Sudarshan Singh 
*
**/
public with sharing class MyFirstDMLClass {
    
    /**
    * 
    *   @description    :   In this method store data in salesforce database using sql queries.
    *
    *   @args           :   None
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 02/07/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void staticDMLs(){

        //Add names of Bank in Account object.
        Account bob = new Account(Name = 'Bank of Baroda');        
        Account sbi = new Account(Name = 'State Bank Of India');        
        Account icici = new Account(Name = 'ICICI Bank');        
        Account axis = new Account(Name = 'Axis Bank');        
        Account boi = new Account(Name = 'Bank of India');        
        List<Account> listOfBankAccount = new List<Account>{bob, sbi, icici, axis, boi};
        insert listOfBankAccount;
        
        //Add names of user contact in perticular bank account. 
        List<Contact> listOfUserContact = new List<Contact>();
        listOfUserContact.add(new Contact(LastName = 'James',AccountId = bob.Id));
        listOfUserContact.add(new Contact(LastName = 'Robert',AccountId = bob.Id));
        listOfUserContact.add(new Contact(LastName = 'John',AccountId = bob.Id));
        listOfUserContact.add(new Contact(LastName = 'Michael',AccountId = bob.Id));
        listOfUserContact.add(new Contact(LastName = 'William',AccountId = bob.Id));
        listOfUserContact.add(new Contact(LastName = 'David',AccountId = sbi.Id));
        listOfUserContact.add(new Contact(LastName = 'Richard',AccountId = sbi.Id));
        listOfUserContact.add(new Contact(LastName = 'Joseph',AccountId = sbi.Id));
        listOfUserContact.add(new Contact(LastName = 'Thomas',AccountId = sbi.Id));
        listOfUserContact.add(new Contact(LastName = 'Charles',AccountId = sbi.Id));
        listOfUserContact.add(new Contact(LastName = 'Christopher',AccountId = icici.Id));
        listOfUserContact.add(new Contact(LastName = 'Daniel',AccountId = icici.Id));
        listOfUserContact.add(new Contact(LastName = 'Matthew',AccountId = icici.Id));
        listOfUserContact.add(new Contact(LastName = 'Anthony',AccountId = icici.Id));
        listOfUserContact.add(new Contact(LastName = 'Mark',AccountId = icici.Id));
        listOfUserContact.add(new Contact(LastName = 'Donald',AccountId = axis.Id));
        listOfUserContact.add(new Contact(LastName = 'Steven',AccountId = axis.Id));
        listOfUserContact.add(new Contact(LastName = 'Paul',AccountId = axis.Id));
        listOfUserContact.add(new Contact(LastName = 'Andrew',AccountId = axis.Id));
        listOfUserContact.add(new Contact(LastName = 'Joshua',AccountId = axis.Id));
        listOfUserContact.add(new Contact(LastName = 'Kenneth',AccountId = boi.Id));
        listOfUserContact.add(new Contact(LastName = 'Kevin',AccountId = boi.Id));
        listOfUserContact.add(new Contact(LastName = 'Brian',AccountId = boi.Id));
        listOfUserContact.add(new Contact(LastName = 'George',AccountId = boi.Id));
        listOfUserContact.add(new Contact(LastName = 'Edward',AccountId = boi.Id));
        insert listOfUserContact;

    }
}