/**
 *  Purpose         :   Helper class for Lead trigger
 *
 *  Create By       :   Bhavi Sharma
 *
 *  Created Date    :   01/31/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *                  :   V_1.1 - Ajit Surana - 4/30/2014 - CR-20140409-5021 - copyAddressToContactOnConversion method modified
 *		    		:   V_1.2 - Modified By - Neha Sharma - 05/18/2021 - CR-20181203-12773 - Retain Acquisition Program data upon conversion
 *		    		:   V_1.3 - Modified By - Neha Sharma - 08/25/2021 - CR-20201029-14644
**/
public without sharing class LeadTriggerHelper {
    
    /**
     *  @description    :   This method is to copy the lead address to the contact record when lead is being created
     * 
     *  @args           :   List of new leads, Map of old leads
     * 
     *  @return         :   void
     * 
     **/
    public static void copyAddressToContactOnConversion(List<Lead> newLeads, Map<Id, Lead> mapOldLeads) {
        
        //Set to hold the account records Ids
        Set<Id> setInstitutionIds = new Set<Id>();   
        
        //Loop through lead records
        for(Lead ld : newLeads) {
            if(ld.IsConverted == true && ld.ConvertedAccountId != null 
                && ld.IsConverted != mapOldLeads.get(ld.Id).IsConverted) {
                setInstitutionIds.add(ld.ConvertedAccountId);
            }
        }
        
        //Map of account record
        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT ID, Primary_Address_Line_1__c, Primary_City__c, 
                                        Primary_State_Province__c, Primary_Country__c, Primary_Postal_Code__c FROM Account 
                                        WHERE ID IN : setInstitutionIds]);
        
        //Create a list of contacts to be updated
        List<Contact> contacts = new List<Contact>();
        
        //Loop over newly inserted Lead records
        for(Lead lead : newLeads) {
            
            //Check if this is a converted lead
            if(lead.IsConverted == true && lead.ConvertedAccountId != null 
                && lead.IsConverted != mapOldLeads.get(lead.Id).IsConverted) {
                
                //Check if ConvertedAccountId, Address Line 1, City, Country and Postal Code are not null
                if((String.isBlank(lead.Address_Line_1__c) || String.isBlank(lead.City__c) || 
                    String.isBlank(lead.Country__c) || String.isBlank(lead.Postal_Code__c))){
                        
                    //Checking for value in the map
                    if(mapAccounts.get(lead.ConvertedAccountId) != null) {
                    
                        //Account record
                        Account account = mapAccounts.get(lead.ConvertedAccountId);
                    
                        //Populate contact's address data with the lead's related Institute address data
                        contacts.add(new Contact(Id = lead.ConvertedContactId, 
                                                    Primary_Address_Line_1__c  = account.Primary_Address_Line_1__c, 
                                                    Primary_City__c = account.Primary_City__c, 
                                                    Primary_State_Province__c = account.Primary_State_Province__c, 
                                                    Primary_Country__c  = account.Primary_Country__c, 
                                                    Primary_Postal_Code__c = account.Primary_Postal_Code__c));
                    }
                    
                } else{
                    
                    //Populate contact's address data with the lead address data 
                    contacts.add(new Contact(Id = lead.ConvertedContactId, Primary_Address_Line_1__c  = lead.Address_Line_1__c, 
                                            Primary_City__c = lead.City__c, Primary_State_Province__c = lead.State_Province__c, 
                                            Primary_Country__c  = lead.Country__c, Primary_Postal_Code__c = lead.Postal_Code__c));
                }
            }
        }
        
        //Update contacts
        if(contacts.size() > 0)
            update contacts;
    }
    
    /** 
    * @description : Method is to delete Product Lead and Campaign Member when Contact to vet is deleted. 
    *  
    * @args : newListLead, OldMapLead 
    * 
    * @return : void 
    * 
    * Added by Seemu Saikia on 06/19/2019 for CR-20190213-12882
    **/ 
     
    public Static void deleteProductLeadsandCampaignMembers(Map<Id, Lead> oldMapcontactToVet){ 
         
        //Map to hold product data to be deleted and will use key to get related campain members 
        Map<Id, Product_Lead__c> productLeadToDelete = new Map<Id, Product_Lead__c>(); 
         
        List<CampaignMember> deleteCampaignMember = new List<CampaignMember>(); 
         
        //Get Prodect lead to delete related to the contact  
        if(oldMapcontactToVet.keyset() != null) 
            productLeadToDelete = new Map<Id, Product_Lead__c>([SELECT Id, Lead__c FROM Product_Lead__c WHERE Lead__c IN : oldMapcontactToVet.Keyset()]); 
             
        //Getting all the CM recrod related to the product Lead 
        if(productLeadToDelete.size() > 0) 
            deleteCampaignMember = [Select Id from CampaignMember where Product_Lead__c IN : productLeadToDelete.keyset()]; 
                 
             
        //ByPass All Trigger 
        util.BypassAllTriggers = true; 
         
        //delete campaign member 
        if(deleteCampaignMember.size() > 0) 
            delete deleteCampaignMember; 
         
        //delete records 
        if(productLeadToDelete.values().size() > 0 ) {
            delete productLeadToDelete.values(); 
            util.BypassAllTriggers = false; 
        }
        
    }
    
    /**
    *  @description    :   This method is to copy the lead Acquisition field to the contact record when contact is newly created
    * 
    *  @args           :   List of new leads, Map of old leads
    * 
    *  @return         :   void
    * 
    * Revision Logs    :   Modified By - Neha Sharma - 05/18/2021 - CR-20181203-12773 - Retain Acquisition Program data upon conversion
    * 
    **/
    public static void copyAcquisitionfieldToContactOnConversion(List<Lead> newLeads, Map<Id, Lead> mapOldLeads) {
        
        //Set to hold the Lead records Ids
        Map<Id, Lead> mapContactIdWithLead = new Map<Id, Lead>();   
        
        //Loop through lead records (update case)
        for(Lead ld : newLeads) {
            if(ld.IsConverted == true && ld.ConvertedContactId != null 
               && ld.IsConverted != mapOldLeads.get(ld.Id).IsConverted) {
                   mapContactIdWithLead.put(ld.ConvertedContactId, ld);
               }
        }
        
        if(mapContactIdWithLead.size() > 0 && mapContactIdWithLead.KeySet().size() > 0){
            //get metadata records which is belongs to lead conversion
            List<Field_Mapping__mdt> listLeadConvertFieldsMapping = [SELECT Id, Source_Object_API_Name__c, Source_Field_API_Name__c,Target_Object_API_Name__c, Target_Field_API_Name__c 
                                                                     FROM Field_Mapping__mdt 
                                                                     WHERE Target_Object_API_Name__c=: Constants.CONTACT_OBJECT_API_NAME AND Active__c = true];
            
            if(listLeadConvertFieldsMapping.size() > 0 ){
                //to hold contacts which is going to be update
                List<Sobject> listOfContactToBeUpdate = new List<Sobject>();
                
                //get all contacts which is not merged while lead conversion
                for(Contact cont : [Select Id From Contact Where Id IN :mapContactIdWithLead.KeySet() And Converted_From_Lead__c = true 
                                       And mkto_Acquisition_Date__c = null And mkto_Acquisition_Program__c = null]){
                                        
                    //get mapped fields from metadata
                    for(Field_Mapping__mdt mapField: listLeadConvertFieldsMapping){
                        
                        //populate target field with source field value 
                        if(mapContactIdWithLead.containsKey(cont.Id)){
                            cont.put(mapField.Target_Field_API_Name__c, mapContactIdWithLead.get(cont.Id).get(mapField.Source_Field_API_Name__c));
                        }
                    }
                    //add contacts in list
                    listOfContactToBeUpdate.add(cont);
                }
                
                //check list size before update
                if(listOfContactToBeUpdate.size() > 0){
                    //bypass trigger before update
                    util.BypassAllTriggers = true;
                    Update listOfContactToBeUpdate;
                    util.BypassAllTriggers = false; 
                }
            }
        }
        
    }
    
     /**
     *  @description    :   This method is update the contact to vet status to 'Disqualified' 
     * 
     *  @args           :   List of new leads, Map of old leads
     * 
     *  @return         :   void
     *
     *  @version	:   V_1.0 - Created By - Neha Sharma - 08/25/2021 - CR-20201029-14644
     * 
     **/
    public static void UpdateContactToVetStatusOnPdLead(List<Lead> newLeads, Map<Id, Lead> mapOldLeads) 
    {
        List<Product_Lead__c> productLeadToBeUpdated = new List<Product_Lead__c>();
        Set<Id> setOfLeadIds = new Set<Id>();
        for(lead lead : newLeads)
        {
            if(String.isNotBlank(lead.Status) &&  lead.Status == constants.DISQUALIFIED 
               && mapOldLeads != null && lead.Status != mapOldLeads.get(lead.Id).Status)
            {
                setOfLeadIds.add(lead.Id);
            }
        }
        
        if(setOfLeadIds.size() > 0)
        {
            for(Product_Lead__c	 pLead : [Select Id,Stage__c,Lead__c from Product_Lead__c where Stage__c = 'AQL' and Lead__c IN : setOfLeadIds])
            {
                pLead.Contact_to_Vet_Status__c = constants.DISQUALIFIED;
                productLeadToBeUpdated.add(pLead);
            }
        }
        
        if(productLeadToBeUpdated.size() > 0)
        {
            util.BypassAllTriggers = true;
            update productLeadToBeUpdated;
            util.BypassAllTriggers = false; 
        }
        
    }
}