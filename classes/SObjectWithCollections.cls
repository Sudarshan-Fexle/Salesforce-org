/**
*  Description     :  This class is for declaration and implementation of SObject.
*
*  Created By      :  Sudarshan singh
*
*  Created Date    :  02/04/2022
*
*  Revision Logs   :  V1.0 - Created - Sudarshan Singh 
*
**/
public with sharing class SObjectWithCollections {
    
    /**
    * 
    *   @description    :   In this method declaration and implemantation of Sobject and store the value in it statically.
    *
    *   @args           :   None
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 02/04/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void staticSobjectsWithCollection(){

        List<Account> listOfAccount = new List<Account>();
        listOfAccount.add(new Account(Name = 'James')); 
        listOfAccount.add(new Account(Name = 'Robert'));
        listOfAccount.add(new Account(Name = 'John'));
        listOfAccount.add(new Account(Name = 'Michael'));
        listOfAccount.add(new Account(Name = 'William'));
        System.debug(listOfAccount);

        List<Contact> listOfContact = new List<Contact>();
        listOfContact.add(new Contact(LastName = 'David'));
        listOfContact.add(new Contact(LastName = 'Richard'));
        listOfContact.add(new Contact(LastName = 'Joseph'));
        listOfContact.add(new Contact(LastName = 'Thomas'));
        listOfContact.add(new Contact(LastName = 'Charles'));

        List<List<Contact>> listOfListOfContact = new List<List<Contact>>();
        listOfListOfContact.add(listOfContact);
        listOfListOfContact.add(listOfContact);
        listOfListOfContact.add(listOfContact);
        listOfListOfContact.add(listOfContact);
        listOfListOfContact.add(listOfContact);
        System.debug(listOfListOfContact);

        List<List<Account>> listOfListOfAccount = new List<List<Account>>();
        listOfListOfAccount.add(listOfAccount);
        listOfListOfAccount.add(listOfAccount);
        listOfListOfAccount.add(listOfAccount);
        listOfListOfAccount.add(listOfAccount);
        listOfListOfAccount.add(listOfAccount);

        List<List<List<Account>>> listOfListOfListOfAccount = new List<List<List<Account>>>();
        listOfListOfListOfAccount.add(listOfListOfAccount);
        listOfListOfListOfAccount.add(listOfListOfAccount);
        listOfListOfListOfAccount.add(listOfListOfAccount);
        listOfListOfListOfAccount.add(listOfListOfAccount);
        listOfListOfListOfAccount.add(listOfListOfAccount);
        System.debug(listOfListOfListOfAccount);

        Map<String, Account> mapOfStringAccount = new Map<String, Account>();
        mapOfStringAccount.put('1', new Account(Name = 'James')); 
        mapOfStringAccount.put('2', new Account(Name = 'Robert'));
        mapOfStringAccount.put('3', new Account(Name = 'John'));
        mapOfStringAccount.put('4', new Account(Name = 'Michael'));
        mapOfStringAccount.put('5', new Account(Name = 'William'));
        System.debug(mapOfStringAccount);

        Map<Account, Account> mapOfAccountAccount = new Map<Account, Account>();
        mapOfAccountAccount.put(new Account(Name = 'James'), new Account(Name = 'James'));
        mapOfAccountAccount.put(new Account(Name = 'Robert'), new Account(Name = 'Robert'));
        mapOfAccountAccount.put(new Account(Name = 'John'), new Account(Name = 'John'));
        mapOfAccountAccount.put(new Account(Name = 'Michael'), new Account(Name = 'Michael'));
        mapOfAccountAccount.put(new Account(Name = 'William'), new Account(Name = 'William'));
        System.debug(mapOfAccountAccount);

        Map<Account, Contact> mapOfAccountContact = new Map<Account, Contact>();
        mapOfAccountContact.put(new Account(Name = 'James'),new Contact(LastName = 'David'));
        mapOfAccountContact.put(new Account(Name = 'Robert'),new Contact(LastName = 'James'));
        mapOfAccountContact.put(new Account(Name = 'John'),new Contact(LastName = 'David'));
        mapOfAccountContact.put(new Account(Name = 'Michael'),new Contact(LastName = 'John'));
        mapOfAccountContact.put(new Account(Name = 'William'),new Contact(LastName = 'James'));
        System.debug(mapOfAccountContact);

        Map<String, List<Account>> mapOfStringListOfAccount = new Map<String, List<Account>>();
        mapOfStringListOfAccount.put('1', listOfAccount);
        mapOfStringListOfAccount.put('2', listOfAccount);
        mapOfStringListOfAccount.put('3', listOfAccount);
        mapOfStringListOfAccount.put('4', listOfAccount);
        mapOfStringListOfAccount.put('5', listOfAccount);
        System.debug(mapOfStringListOfAccount);

        Set<Contact> setOfContact = new Set<Contact>();
        setOfContact.add(new Contact(LastName = 'David'));
        setOfContact.add(new Contact(LastName = 'James'));
        setOfContact.add(new Contact(LastName = 'David'));
        setOfContact.add(new Contact(LastName = 'John'));
        setOfContact.add(new Contact(LastName = 'James'));

        Map<String, Set<Contact>> mapOfStringSetOfContact = new Map<String, Set<Contact>>();
        mapOfStringSetOfContact.put('1', setOfContact);
        mapOfStringSetOfContact.put('2', setOfContact);
        mapOfStringSetOfContact.put('3', setOfContact);
        mapOfStringSetOfContact.put('4', setOfContact);
        mapOfStringSetOfContact.put('5', setOfContact);
        System.debug(mapOfStringSetOfContact);

        Map<String, Map<Account, Contact>> mapOfStringMapOfAccountContact = new Map<String, Map<Account, Contact>>();
        mapOfStringMapOfAccountContact.put('1', mapOfAccountContact);
        mapOfStringMapOfAccountContact.put('2', mapOfAccountContact);
        mapOfStringMapOfAccountContact.put('3', mapOfAccountContact);
        mapOfStringMapOfAccountContact.put('4', mapOfAccountContact);
        mapOfStringMapOfAccountContact.put('5', mapOfAccountContact);
        System.debug(mapOfStringMapOfAccountContact);

        Map<String, Map<Account, Account>> mapOfStringMapOfAccountAccount = new Map<String,Map<Account,Account>>();
        mapOfStringMapOfAccountAccount.put('1', mapOfAccountAccount);
        mapOfStringMapOfAccountAccount.put('2', mapOfAccountAccount);
        mapOfStringMapOfAccountAccount.put('3', mapOfAccountAccount);
        mapOfStringMapOfAccountAccount.put('4', mapOfAccountAccount);
        mapOfStringMapOfAccountAccount.put('5', mapOfAccountAccount);

        Map<Map<String, Account>, Map<String, Map<Account, Account>>> mapOfMapOfStringAccountMapOfStringMapOfAccountAccount = new  Map<Map<String, Account>, Map<String, Map<Account, Account>>>();
        mapOfMapOfStringAccountMapOfStringMapOfAccountAccount.put(mapOfStringAccount, mapOfStringMapOfAccountAccount);
        mapOfMapOfStringAccountMapOfStringMapOfAccountAccount.put(mapOfStringAccount, mapOfStringMapOfAccountAccount);
        mapOfMapOfStringAccountMapOfStringMapOfAccountAccount.put(mapOfStringAccount, mapOfStringMapOfAccountAccount);
        mapOfMapOfStringAccountMapOfStringMapOfAccountAccount.put(mapOfStringAccount, mapOfStringMapOfAccountAccount);
        mapOfMapOfStringAccountMapOfStringMapOfAccountAccount.put(mapOfStringAccount, mapOfStringMapOfAccountAccount);
        System.debug(mapOfMapOfStringAccountMapOfStringMapOfAccountAccount);

        Map<Account, List<Contact>> mapOfAccountListOfContact = new Map<Account, List<Contact>>();
        mapOfAccountListOfContact.put(new Account(Name = 'a'), listOfContact);
        mapOfAccountListOfContact.put(new Account(Name = 'b'), listOfContact);
        mapOfAccountListOfContact.put(new Account(Name = 'c'), listOfContact);
        mapOfAccountListOfContact.put(new Account(Name = 'd'), listOfContact);
        mapOfAccountListOfContact.put(new Account(Name = 'e'), listOfContact);

        Map<Account, Map<Account, List<Contact>>> mapOfAccountMapOfAccountListOfContact = new Map<Account, Map<Account, List<Contact>>>();
        mapOfAccountMapOfAccountListOfContact.put(new Account(Name = 'a'), mapOfAccountListOfContact);
        mapOfAccountMapOfAccountListOfContact.put(new Account(Name = 'b'), mapOfAccountListOfContact);
        mapOfAccountMapOfAccountListOfContact.put(new Account(Name = 'c'), mapOfAccountListOfContact);
        mapOfAccountMapOfAccountListOfContact.put(new Account(Name = 'd'), mapOfAccountListOfContact);
        mapOfAccountMapOfAccountListOfContact.put(new Account(Name = 'e'), mapOfAccountListOfContact);

        Map<String, Map<Account, Map<Account, List<Contact>>>> mapOfStringMapOfAccountMapOfAccountListOfContact = new Map<String, Map<Account, Map<Account, List<Contact>>>>();
        mapOfStringMapOfAccountMapOfAccountListOfContact.put('1', mapOfAccountMapOfAccountListOfContact);
        mapOfStringMapOfAccountMapOfAccountListOfContact.put('2', mapOfAccountMapOfAccountListOfContact);
        mapOfStringMapOfAccountMapOfAccountListOfContact.put('3', mapOfAccountMapOfAccountListOfContact);
        mapOfStringMapOfAccountMapOfAccountListOfContact.put('4', mapOfAccountMapOfAccountListOfContact);
        mapOfStringMapOfAccountMapOfAccountListOfContact.put('5', mapOfAccountMapOfAccountListOfContact);

        Map<String, Map<String,Account>> mapOfStringMapOfStringAccount = new Map<String, Map<String,Account>>();
        mapOfStringMapOfStringAccount.put('1', mapOfStringAccount);
        mapOfStringMapOfStringAccount.put('2', mapOfStringAccount);
        mapOfStringMapOfStringAccount.put('3', mapOfStringAccount);
        mapOfStringMapOfStringAccount.put('4', mapOfStringAccount);
        mapOfStringMapOfStringAccount.put('5', mapOfStringAccount);

        Map<Map<String, Map<String,Account>>, Map<String, Map<Account, Map<Account, List<Contact>>>>> mapOfMapOfStringMapOfStringAccountMapOfStringMapOfAccountMapOfAccountListOfContact = new Map<Map<String, Map<String,Account>>, Map<String, Map<Account, Map<Account, List<Contact>>>>>();
        mapOfMapOfStringMapOfStringAccountMapOfStringMapOfAccountMapOfAccountListOfContact.put(mapOfStringMapOfStringAccount,mapOfStringMapOfAccountMapOfAccountListOfContact);
        mapOfMapOfStringMapOfStringAccountMapOfStringMapOfAccountMapOfAccountListOfContact.put(mapOfStringMapOfStringAccount,mapOfStringMapOfAccountMapOfAccountListOfContact);
        mapOfMapOfStringMapOfStringAccountMapOfStringMapOfAccountMapOfAccountListOfContact.put(mapOfStringMapOfStringAccount,mapOfStringMapOfAccountMapOfAccountListOfContact);
        mapOfMapOfStringMapOfStringAccountMapOfStringMapOfAccountMapOfAccountListOfContact.put(mapOfStringMapOfStringAccount,mapOfStringMapOfAccountMapOfAccountListOfContact);
        mapOfMapOfStringMapOfStringAccountMapOfStringMapOfAccountMapOfAccountListOfContact.put(mapOfStringMapOfStringAccount,mapOfStringMapOfAccountMapOfAccountListOfContact);
        System.debug(mapOfMapOfStringMapOfStringAccountMapOfStringMapOfAccountMapOfAccountListOfContact);

    }

    /**
    * 
    *   @description    :   In this method declaration and implemantation of Sobject and store the value in it dynamically. 
    *
    *   @args           :   Integer
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 02/04/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void dynamicSobjectsWithCollection(Integer noOfvalue){

        List<Account> listOfAccount = new List<Account>();
        for (Integer i = 0; i < noOfvalue; i++) {
            listOfAccount.add(new Account(Name = String.valueOf(i)));    
        }
        System.debug(listOfAccount);

        List<Contact> listOfContact = new List<Contact>();
        for (Integer i = 0; i < noOfvalue; i++) {
        listOfContact.add(new Contact(LastName = 'David'));
        }

        List<List<Contact>> listOfListOfContact = new List<List<Contact>>();
        for (Integer i = 0; i < noOfvalue; i++) {
        listOfListOfContact.add(listOfContact);
        }
        System.debug(listOfListOfContact);

        List<List<Account>> listOfListOfAccount = new List<List<Account>>();
        for (Integer i = 0; i < noOfvalue; i++) {
        listOfListOfAccount.add(listOfAccount);
        }

        List<List<List<Account>>> listOfListOfListOfAccount = new List<List<List<Account>>>();
        for (Integer i = 0; i < noOfvalue; i++) {
        listOfListOfListOfAccount.add(listOfListOfAccount);
        }
        System.debug(listOfListOfListOfAccount);

        Map<String, Account> mapOfStringAccount = new Map<String, Account>();
        for (Integer i = 0; i < noOfvalue; i++) {
        mapOfStringAccount.put(String.valueOf(i), new Account(Name = String.valueOf(i)));
        }
        System.debug(mapOfStringAccount);

        Map<Account, Account> mapOfAccountAccount = new Map<Account, Account>();
        for (Integer i = 0; i < noOfvalue; i++) {
        mapOfAccountAccount.put(new Account(Name = String.valueOf(i)), new Account(Name = String.valueOf(i)));
        }
        System.debug(mapOfAccountAccount);

        Map<Account, Contact> mapOfAccountContact = new Map<Account, Contact>();
        for (Integer i = 0; i < noOfvalue; i++) {
        mapOfAccountContact.put(new Account(Name = String.valueOf(i)),new Contact(LastName = 'David'));
        }
        System.debug(mapOfAccountContact);

        Map<String, List<Account>> mapOfStringListOfAccount = new Map<String, List<Account>>();
        for (Integer i = 0; i < noOfvalue; i++) {
        mapOfStringListOfAccount.put(String.valueOf(i), listOfAccount);
        }
        System.debug(mapOfStringListOfAccount);

        Set<Contact> setOfContact = new Set<Contact>();
        for (Integer i = 0; i < noOfvalue; i++) {
        setOfContact.add(new Contact(LastName = 'David'));
        }

        Map<String, Set<Contact>> mapOfStringSetOfContact = new Map<String, Set<Contact>>();
        for (Integer i = 0; i < noOfvalue; i++) {
        mapOfStringSetOfContact.put(String.valueOf(i), setOfContact);
        }
        System.debug(mapOfStringSetOfContact);

        Map<String, Map<Account, Contact>> mapOfStringMapOfAccountContact = new Map<String, Map<Account, Contact>>();
        for (Integer i = 0; i < noOfvalue; i++) {
        mapOfStringMapOfAccountContact.put(String.valueOf(i), mapOfAccountContact);
        }
        System.debug(mapOfStringMapOfAccountContact);

        Map<String, Map<Account, Account>> mapOfStringMapOfAccountAccount = new Map<String,Map<Account,Account>>();
        for (Integer i = 0; i < noOfvalue; i++) {
        mapOfStringMapOfAccountAccount.put(String.valueOf(i), mapOfAccountAccount);
        }

        Map<Map<String, Account>, Map<String, Map<Account, Account>>> mapOfMapOfStringAccountMapOfStringMapOfAccountAccount = new  Map<Map<String, Account>, Map<String, Map<Account, Account>>>();
        for (Integer i = 0; i < noOfvalue; i++) {
        mapOfMapOfStringAccountMapOfStringMapOfAccountAccount.put(mapOfStringAccount, mapOfStringMapOfAccountAccount);
        }
        System.debug(mapOfMapOfStringAccountMapOfStringMapOfAccountAccount);

        Map<Account, List<Contact>> mapOfAccountListOfContact = new Map<Account, List<Contact>>();
        for (Integer i = 0; i < noOfvalue; i++) {
        mapOfAccountListOfContact.put(new Account(Name = String.valueOf(i)), listOfContact);
        }

        Map<Account, Map<Account, List<Contact>>> mapOfAccountMapOfAccountListOfContact = new Map<Account, Map<Account, List<Contact>>>();
        for (Integer i = 0; i < noOfvalue; i++) {
        mapOfAccountMapOfAccountListOfContact.put(new Account(Name = String.valueOf(i)), mapOfAccountListOfContact);
        }

        Map<String, Map<Account, Map<Account, List<Contact>>>> mapOfStringMapOfAccountMapOfAccountListOfContact = new Map<String, Map<Account, Map<Account, List<Contact>>>>();
        for (Integer i = 0; i < noOfvalue; i++) {
        mapOfStringMapOfAccountMapOfAccountListOfContact.put(String.valueOf(i), mapOfAccountMapOfAccountListOfContact);
        }

        Map<String, Map<String,Account>> mapOfStringMapOfStringAccount = new Map<String, Map<String,Account>>();
        for (Integer i = 0; i < noOfvalue; i++) {
        mapOfStringMapOfStringAccount.put(String.valueOf(i), mapOfStringAccount);
        }

        Map<Map<String, Map<String,Account>>, Map<String, Map<Account, Map<Account, List<Contact>>>>> mapOfMapOfStringMapOfStringAccountMapOfStringMapOfAccountMapOfAccountListOfContact = new Map<Map<String, Map<String,Account>>, Map<String, Map<Account, Map<Account, List<Contact>>>>>();
        for (Integer i = 0; i < noOfvalue; i++) {
        mapOfMapOfStringMapOfStringAccountMapOfStringMapOfAccountMapOfAccountListOfContact.put(mapOfStringMapOfStringAccount,mapOfStringMapOfAccountMapOfAccountListOfContact);
        }
        System.debug(mapOfMapOfStringMapOfStringAccountMapOfStringMapOfAccountMapOfAccountListOfContact);
        
    }
}