/**
*  Description     :  In this class SOQL Query are performed. 
*
*  Created By      :  Sudarshan singh
*
*  Created Date    :  02/10/2022
*
*  Revision Logs   :  V1.0 - Created - Sudarshan Singh 
*
**/
public with sharing class SOQLQueryClass {
    
    /**
    * 
    *   @description    :   In this method  SOQL Query are performed.
    *
    *   @args           :   None
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 02/10/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void normalSOQL(){

        //1 Assignment
        //List of Accounts where name not equal to test and name not contains Fexle.
        List<Account> listOfAccount = [SELECT Id, Name, Website FROM Account WHERE (Name != 'Test' OR (Not Name Like '%Fexle%')) AND Website != null LIMIT 10];
        
        //Store all the account id in the set.
        Set<Id> setOfId = new Set<Id>();
       	for (Account acc : listOfAccount) {
           	setOfId.add(acc.Id);
        }

        //2 Assignment
        //Fetch all the contact from accounts.
         List<Contact> listOfContact = [Select FirstName, LastName, Account.Website, Account_Website__c FROM Contact WHERE AccountId IN: setOfId];
        
        //3 Assignment
        //Update Account Website field of Contact from Website field of Account.
        for (Contact con : listOfContact) {
                con.Account_Website__c = con.Account.Website;
        }
        
        update listOfContact;
        
    }

    /**
    * 
    *   @description    :   In this method  SOQL Query are performed.
    *
    *   @args           :   List<Id>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 02/14/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void inlineSOQLFunction(List<Id> listOfId){

        //Create a list to fetch all the contacts present in list of accountId.
        List<Account> listOfAccount = [SELECT Id, Name, Contact_Details__c,(SELECT FirstName, LastName, Email FROM Contacts) 
                                       FROM Account WHERE Id IN : listOfId];
        for (Account acc : listOfAccount) {
            String listOfAllContact = '';
            for (Contact con : acc.Contacts) {

                listOfAllContact += 'FirstName =' + con.FirstName  + ', LastName =' + con.LastName + ', Email =' + con.Email + '\n';
            }
            acc.Contact_Details__c = listOfAllContact;
        }

        //Update contact details field in accounts.
        update listOfAccount;
        System.debug(listOfAccount);

    }

    /**
    * 
    *   @description    :   In this method  SOQL Query are performed.
    *
    *   @args           :   None
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 02/14/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void aggregateSOQL(){
        
        //Create a map to store Id and Account.
        Map<Id, Account> mapOfIdAccount = new Map<Id, Account>();
        for(Account acc : [SELECT Id FROM Account])
            mapOfIdAccount.put(acc.Id, new Account(Id = acc.Id, Total_Active_Contacts__c = 0, Total_In_Active_Contacts__c = 0));
        
        //Loop for Count the Id for active and in-active contact.
        for (AggregateResult arResult : [SELECT AccountId, COUNT(Id) totalcount, Status__c FROM Contact 
                                         WHERE AccountId != null GROUP BY AccountId, Status__C]) {
            
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

        //Update the values of total active and in-active contacts of accounts. 
        update mapOfIdAccount.values();

    }

}