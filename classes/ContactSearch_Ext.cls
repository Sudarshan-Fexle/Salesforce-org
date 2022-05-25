/**
 *  Desription      :   Class to cover the functionality for allowing the user to search for a Contact record on an
                        Institution detail page using "Account" as standard controller.
 * 
 *  Created By      :   Ajit Surana
 * 
 *  Created Date    :   08/04/2014
 * 
 *  Revision Logs   :   V1.0 - Created
 **/ 
public class ContactSearch_Ext {

    //Instance variable for the standard controller
    public ApexPages.StandardController controller {get; set;}
    
    //Account instance
    public Account a;
    
    //Flag variable to check
    public Boolean isSearch {get; set;}
    
    //List to hold the results from the search operation
    public List<Contact> searchResults {get;set;}

    //String variable to hold the text entered by the user
    public string searchText {get; set;}
    
    //Class constructor
    public ContactSearch_Ext(ApexPages.StandardController controller) {

        //Initialize the standard controller
        this.controller = controller;
        searchResults = new List<Contact>();
        isSearch 
        = false;
        this.a = (Account)controller.getRecord();

    }

    //Method to perform the Search functionality when "Search" button will be hit by user
    public void search() {

        //Checking search strings for null and blank value
        if((searchText != null && searchText != '')){
            
            if(searchText != null && searchText != ''
                && searchText.replaceAll('\\*','').replaceAll('\\%', '').replaceAll('\\_', '').trim().length() > 0){
            
                //String to hold the search string entered by user
                String searchStr = '%\''+searchText+ '%\'';
            
                //Variable to hold Account Id    
                Id accId = a.Id;
            
                //Dynamic soql to find the related Contacts by name
                String qry = 'Select Id, Name, Title, Email, Phone From Contact Where AccountId =: accId  AND Name LIKE \'%' + searchText+'%\' Order By Name';
                searchResults = Database.query(qry);
                
                //Check for size
                if(searchResults.size() == 0)
                    isSearch = true;
                else{
                    isSearch = false;
                }
            }
        }
    }
}