/**
*  Purpose      :   InvoiceBillingContactTriggerHelper
*
*  Create By    :   
*  
*  Revision Log :   V_1.0 -  Created
                    V_1.1 - Modified By - Colin McGloin - CR-20200715-14316
		    V_1.2 - Modified By - Mahendra Swarnkar - CR-20211112-15581 - 11/29/2021 - Updated method getInvoiceBillingContacts Added Not null check for contractId
* 
**/
public without sharing class InvoiceBillingContactTriggerHelper {

    @AuraEnabled(cacheable=true)
    public static List<Invoice_Billing_Contact__c> getInvoiceBillingContacts(Id contractId) {
        
        //Added By -  Mahendra Swarnkar - CR-20211112-15581 - 11/29/2021
        List <Invoice_Billing_Contact__c> relatedIBC = new List <Invoice_Billing_Contact__c>();
        
        //Added By -  Mahendra Swarnkar - CR-20211112-15581 - 11/29/2021
        if(contractId != null)
        {
            //Once we have our Contract ID then run the query and get the necessary data
            relatedIBC = [SELECT Id, Name, Contact__c, Contact_Name__c, Standard_Contract__c, Contract_Name__c, Invoice_Email__c, Enabled_for_this_Contract__c
                          FROM Invoice_Billing_Contact__c
                          WHERE Standard_Contract__c = :contractId]; 
        }
        return relatedIBC;
    }

    // Modified By - Mahendra Swarnkar - CR-20211112-15581 - 11/29/2021 - Optimized the code so that it can be restricted to execute the logic
    @AuraEnabled
    public static void importInvoiceBillingContacts (String recordId){
        
        //Added By - Mahendra Swarnkar - CR-20211112-15581 - 11/29/2021
        if(String.isNotBlank(recordId)){
            
            //Map for checking/removing Invoice Contact
            Map<Id, Invoice_Billing_Contact__c> mapContactIdToIBC = new Map<Id, Invoice_Billing_Contact__c>();
            
            //Run a query to get our Institution from the Contract
            Contract contract = [SELECT Id, Name, AccountId FROM Contract WHERE ID = :recordId];
            
            //Added By - Mahendra Swarnkar - CR-20211112-15581 - 11/29/2021
            if(contract != null && contract.AccountId != null){
                
                //Run a quick query to see how many Invoice enabled Contacts are set up on the Insitution
                List <Contact> invoiceContacts = [SELECT Id, Name, Enabled_for_Invoice__c FROM Contact WHERE AccountId = :contract.AccountId AND Enabled_for_Invoice__c = TRUE];
                
                //Run the logic if there are Invoice Contacts to work with
                if (invoiceContacts.size() > 0){
                    
                    //Get our Invoice Billing Contacts
                    List <Invoice_Billing_Contact__c> invContacts = getInvoiceBillingContacts(contract.Id);
                    
                    //Added By - Mahendra Swarnkar - CR-20211112-15581 - 11/29/2021
                    //Check for records
                    if (invContacts != null && invContacts.size() > 0){
                        
                        //Loop through our invContacts and populate in a Map
                        for (Invoice_Billing_Contact__c ibc : invContacts){
                            
                            //Populate Map
                            mapContactIdToIBC.put(ibc.Contact__c, ibc);
                            
                        }
                        
                    }
                    
                    //Added By - Mahendra Swarnkar - CR-20211112-15581 - 11/29/2021 - Removed from top and Added list here 
                    //List for creating IBC records if needed
                    List<Contact> recordsToCreate = new List <Contact>();
                    
                    //Loop through our Invoice Contacts and remove the ones already created
                    for (Contact con : invoiceContacts){
                        
                        //Added By - Mahendra Swarnkar - CR-20211112-15581 - 11/29/2021 - Added list here 
                        //Check to see if the Map has this contact already
                        if (mapContactIdToIBC.size() > 0 && mapContactIdToIBC.containsKey(con.Id) && mapContactIdToIBC.get(con.Id)!= null ){
                            continue;
                        }
                        //Add record to 
                        recordsToCreate.add(con);
                    }
                    
                    //Send the information through to create records
                    if (recordsToCreate.size() > 0){
                        
                        //List for creating records
                        List<Invoice_Billing_Contact__c> invoiceBillContacts = new List<Invoice_Billing_Contact__c>();
                        
                        //Loop through our records to create
                        for (Contact createIBC : recordsToCreate){
                            
                            Invoice_Billing_Contact__c ibcForCon = createInvoiceBillingContact(createIBC.Id, contract.Id, false);
                            invoiceBillContacts.add(ibcForCon);
                            
                        }
                        //Added By - Mahendra Swarnkar - CR-20211112-15581 - 11/29/2021 - Added list here 
                        if(invoiceBillContacts.size() > 0){
                            //insert our new Records
                            insert invoiceBillContacts;
                        }
                    } 
                }
            }
        }
    }

    // Modified By - Mahendra Swarnkar - CR-20211112-15581 - 11/29/2021 - updated the method logic to include the deserialization of JSON string in the try-catch block.
    @AuraEnabled
    public static string updateInvoiceBillingContact(Object data) {
        
        //Added By - Mahendra Swarnkar - CR-20211112-15581 - 11/29/2021 - include the deserialization of JSON string in the try block
        try{
            List<Invoice_Billing_Contact__c> invoiceBillingContactsForUpdate = (List<Invoice_Billing_Contact__c>) JSON.deserialize(
                JSON.serialize(data),
                List<Invoice_Billing_Contact__c>.class
            );
            
            update invoiceBillingContactsForUpdate;
            return 'Success: contacts updated successfully';
        }
        catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }

    public static Invoice_Billing_Contact__c createInvoiceBillingContact (Id ContactId, Id ContractId, boolean enabledForContact){

        Invoice_Billing_Contact__c newRecord = new Invoice_Billing_Contact__c();
        newRecord.Contact__c = ContactId;
        newRecord.Standard_Contract__c = ContractId;
        newRecord.Enabled_for_this_Contract__c = enabledForContact;

        return newRecord; 

    }

}