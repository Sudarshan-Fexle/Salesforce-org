/**
*  Description     :    Wrapper class for PrintMIS Catalyst Test Data Utility 
*
*  Created Date    :    09/22/2021
* 
*  Revision Logs   :    V_1.0 - Created By - Mahendar Swarnkar - CR-20210909-15418
*/

public without sharing class CatalystPrintDataUtilityWrapper {
      
      //----- Inventory Transaction fields-----//
      
      // Print Vendor 
      public String IT_Print_Vendor {get;set;}
      
      // Mail Vendor
      public String IT_Mail_Vendor {get;set;}
      
      //----- Job Ticket fields-----//
      
      // Drop Type 
      public String JT_Drop_Type {get;set;}
      
      // Vendor Type
      public String JT_Vendor_Type {get;set;}
      
      // Mail Vendor
      public String JT_Mail_Vendor {get;set;}
      
      // # of Drops
      public Integer JT_No_Of_Drop {get;set;}
      
      // Project Id 
      public String JT_Project_ID {get;set;}
      
      // Project Id 
      //public Date JT_Mail_Date {get;set;}
      
      //----- Parent Proposal Line fields-----//
      public String Parent_QL_PricebookEntry {get;set;}
      public String Parent_QL_TopParentProduct {
          get;
          set{
              Parent_QL_TopParentProduct = value;
              
              if(Parent_QL_TopParentProduct != null){
                  Child_QL_TopParentProduct = Parent_QL_TopParentProduct;
                  Grand_QL_TopParentProduct = Parent_QL_TopParentProduct;
              }
          }
      }
      public String Parent_QL_Product{
          get; 
          set{
              Parent_QL_Product = value;
              
              if(Parent_QL_Product != null){
                  for(Product2 prod : [Select ID, Parent_Product__c, (Select ID from PricebookEntries limit 1) From Product2 Where ID =: Parent_QL_Product]){
                      
                      Parent_QL_TopParentProduct = prod.Parent_Product__c != null ? prod.Parent_Product__c : prod.ID;
                      Parent_QL_PricebookEntry = prod.PricebookEntries != null && prod.PricebookEntries.size() > 0 ? prod.PricebookEntries[0].Id : null;
                      
                  }
              }
          }
      }
      
      //----- Child Proposal Line fields-----//
         
      public String Child_QL_PricebookEntry {get;set;}
      public String Child_QL_TopParentProduct {get;set;}
      public String Child_QL_ProductOption {get;set;}
      public String Child_QL_DynamicOptionId {get;set;}
      public String Child_QL_Product{
          get; 
          set{
              Child_QL_Product = value;
              
              if(Child_QL_Product != null){
                  for(Product2 prod : [Select ID, (Select ID from PricebookEntries limit 1), 
                                        (Select ID, SBQQ__Feature__c From SBQQ__OptionalFor__r Where SBQQ__ConfiguredSKU__c = : Parent_QL_Product Limit 1), 
                                        (Select ID, SBQQ__Feature__c, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c From SBQQ__Options__r Where SBQQ__OptionalSKU__r.Product_Category__c = 'Annual Fee' Limit 1)
                                       From Product2 Where ID =: Child_QL_Product])
                  {
                      
                      Child_QL_PricebookEntry = prod.PricebookEntries != null && prod.PricebookEntries.size() > 0 ? prod.PricebookEntries[0].Id : null;
                      
                      if(prod.SBQQ__OptionalFor__r != null && prod.SBQQ__OptionalFor__r.size() > 0) {
                          Child_QL_ProductOption = prod.SBQQ__OptionalFor__r[0].Id;
                          Child_QL_DynamicOptionId = prod.SBQQ__OptionalFor__r[0].SBQQ__Feature__c != null ? prod.SBQQ__OptionalFor__r[0].SBQQ__Feature__c : null;    
                      }
                      
                      if(prod.SBQQ__Options__r != null && prod.SBQQ__Options__r.size() > 0) {
                          Grand_QL_Product = prod.SBQQ__Options__r[0].SBQQ__OptionalSKU__c;
                          Grand_QL_ProductOption = prod.SBQQ__Options__r[0].Id;
                          Grand_QL_DynamicOptionId = prod.SBQQ__Options__r[0].SBQQ__Feature__c;
                      }
                  }
              }
          }
      }
  
      //----- Grand Child Proposal Line fields-----//
      
      public String Grand_QL_PricebookEntry {get;set;}
      public String Grand_QL_TopParentProduct {get;set;}
      public String Grand_QL_ProductOption {get;set;}
      public String Grand_QL_DynamicOptionId {get;set;}
      public String Grand_QL_Dimension {get;set;}
      public String Grand_QL_Product{
          get; 
          set{
              Grand_QL_Product = value;
              if(Grand_QL_Product != null){
                  
                  for(Product2 prod : [Select ID, (Select ID from PricebookEntries limit 1), (Select ID from SBQQ__Dimensions__r limit 1) From Product2 Where ID =: Grand_QL_Product]){
                      Grand_QL_PricebookEntry = prod.PricebookEntries != null && prod.PricebookEntries.size() > 0 ? prod.PricebookEntries[0].Id : null;
                      Grand_QL_Dimension = prod.SBQQ__Dimensions__r != null && prod.SBQQ__Dimensions__r.size() > 0 ? prod.SBQQ__Dimensions__r[0].Id : null;
                  }
              }
          }
      }
      
      //----- List of Emails -----//
      
      public List<String> emailList {get;set;}        
      
      
  }