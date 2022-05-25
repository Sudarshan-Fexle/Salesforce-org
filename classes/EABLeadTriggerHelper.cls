/**
 *  Purpose         :  This helper is to control the automation on 1EAB Lead object.
 * 
 *  Created By      :   Neha Sharma
 *
 *  Created Date    :   
 *
 *  Revision Logs   :   V_1.0 - Created 
 *                      V_1.1 - Created by - Nikita Kumari - CR-20210316-15000 - Add 1EAB Leads to Contact Roles 
 *                     
**/
public class EABLeadTriggerHelper {
     
    //Added by - Neha Piproniyan - 2/5/2021 - CR-20201204-14721
    /**
     *  @description    :   Method to auto-tag to PL with same [Contact] * [Primary Program] if exists. 
     *                      If doesn’t exist, create PL for that combination of Contact * Product, and then tag.
     *                      Newly created PL should start in 'Inquiry'.
     *                       
     *  @args           :   List for new 1EAB lead value, Map for old value
     * 
     *  @return         :   void
     * 
     **/ 
    public static void createProductLead(List<X1EAB_Lead__c> newEABLeadList,Map<Id, X1EAB_Lead__c> oldMapEABLead){
        
        
        Map<String,Id> mapOfContactWithProgram = new Map<String,Id>();
        Map<String,Product_Lead__c> mapOfproductLeadtoBeInsert = new Map<String,Product_Lead__c>();
        Map<String,X1EAB_Lead__c> mapOfeabLead = new Map<String,X1EAB_Lead__c>();
        Set<Id> setOfContactIds = new Set<Id>();
        Set<Id> setOfProgramIds = new Set<Id>();
        List<X1EAB_Lead__c> eabLeadToBeUpdated = new List<X1EAB_Lead__c>();
        
        
        for(X1EAB_Lead__c eabLead : newEABLeadList){
            if(eabLead.Contact__c != null && eabLead.Primary_Program__c != null && 
               (oldMapEABLead == null || (oldMapEABLead != null 
                                          &&(eabLead.Contact__c != oldMapEABLead.get(eabLead.Id).Contact__c 
                                             ||eabLead.Primary_Program__c != oldMapEABLead.get(eabLead.Id).Primary_Program__c
                                            )
                                         )
               ))
            {
                setOfContactIds.add(eabLead.Contact__c);
                setOfProgramIds.add(eabLead.Primary_Program__c); 
                mapOfeabLead.put(eabLead.Contact__c +'-' + eabLead.Primary_Program__c,eabLead);
            }
        }
        
        if(setOfContactIds.size() > 0 && setOfProgramIds.size() > 0)
        {
            //Query the exitsing product lead
            for(Product_Lead__c prodlead : [Select Id,Contact__c,Program__c from Product_Lead__c where Contact__c IN: setOfContactIds and Program__c IN: setOfProgramIds])
            {
                mapOfContactWithProgram.put(prodlead.Contact__c +'-' + prodlead.Program__c,prodlead.Id);                
            }
            
            for(X1EAB_Lead__c eabLead : newEABLeadList)
            {
                if(mapOfContactWithProgram.containsKey(eabLead.Contact__c +'-' + eabLead.Primary_Program__c)){
                    X1EAB_Lead__c eLead = new X1EAB_Lead__c();
                    eLead.Id = eabLead.Id;
                    eLead.Product_Lead__c = mapOfContactWithProgram.get(eabLead.Contact__c +'-' + eabLead.Primary_Program__c);
                    eabLeadToBeUpdated.add(eLead);
                   
                }
                else {
                    mapOfproductLeadtoBeInsert.put(eabLead.Contact__c +'-' + eabLead.Primary_Program__c,new Product_Lead__c(Contact__c = eabLead.Contact__c,Program__c = eabLead.Primary_Program__c,Stage__c = 'Inquiry'));
                }
            }
            
            if(mapOfproductLeadtoBeInsert.size() >0){
                
                insert mapOfproductLeadtoBeInsert.values();
                
                for(Product_Lead__c pLead : mapOfproductLeadtoBeInsert.values())
                {
                    X1EAB_Lead__c eLead = new X1EAB_Lead__c();
                    eLead.Id = mapOfeabLead.get(pLead.Contact__c +'-' + pLead.Program__c).Id;
                    eLead.Product_Lead__c = pLead.Id;
                    eabLeadToBeUpdated.add(eLead);
                }
                
                
            }
            
            if(eabLeadToBeUpdated.size() > 0){
                Util.byPassAllTriggers = true;
                update eabLeadToBeUpdated; 
                Util.byPassAllTriggers = false;
            }  
        }     
    }
    
    //Added by - Neha Piproniyan - 2/5/2021 - CR-20201204-14721
    /**
     *  @description    :   Method to inset lead Passer recprd When [Primary Lead Passer] field populated/changed on 1EAB lead then
     *                      IF Lead Passer record does not already exist with a combo of 1EAB Lead & Passer, then create it otherwise not.
     *                       
     *  @args           :   List for new 1EAB lead value, Map for old value
     * 
     *  @return         :   void
     * 
     **/ 
    public static void createLeadPasser(List<X1EAB_Lead__c> newEABLeadList,Map<Id, X1EAB_Lead__c> oldMapEABLead){
        
        Map<String,Id> mapOfLeadPasser = new Map<String,Id>();
        List<Lead_Passer__c> leadPasserTobeInsert = new  List<Lead_Passer__c>();
        Set<Id> setOfEABLeadId = new Set<Id>();
        Set<Id> setOfPrimaryLeadPasserId = new Set<Id>();
       
        for(X1EAB_Lead__c eabLead : newEABLeadList){
            if(oldMapEABLead == null && eabLead.Primary_Lead_Passer__c != null ) 
            {  
                Lead_Passer__c laedPasser = new Lead_Passer__c(Passer__c = eabLead.Primary_Lead_Passer__c,X1EAB_Lead__c = eabLead.Id);
                leadPasserTobeInsert.add(laedPasser);
            }
            else if(oldMapEABLead != null && eabLead.Primary_Lead_Passer__c != oldMapEABLead.get(eabLead.Id).Primary_Lead_Passer__c){
                setOfEABLeadId.add(eabLead.Id);        
                setOfPrimaryLeadPasserId.add(eabLead.Primary_Lead_Passer__c);
            }
        }
        
        if(setOfEABLeadId.size() > 0 && setOfPrimaryLeadPasserId.size() > 0)
        {
            for(Lead_Passer__c leadPasser : [Select Id,X1EAB_Lead__c,Passer__c from Lead_Passer__c where X1EAB_Lead__c IN: setOfEABLeadId and Passer__c IN: setOfPrimaryLeadPasserId])
            {
                mapOfLeadPasser.put(leadPasser.X1EAB_Lead__c +'-' + leadPasser.Passer__c,leadPasser.Id);                
            } 
            
            for(X1EAB_Lead__c eabLead : newEABLeadList)
            {
                if(eabLead.Primary_Lead_Passer__c != null && !mapOfLeadPasser.containsKey(eabLead.Id +'-' + eabLead.Primary_Lead_Passer__c)){
                    Lead_Passer__c laedPasser = new Lead_Passer__c(Passer__c = eabLead.Primary_Lead_Passer__c,X1EAB_Lead__c = eabLead.Id);
                    leadPasserTobeInsert.add(laedPasser);
                }
            }
        }
        
        if(leadPasserTobeInsert.size() > 0)
        {    
            insert leadPasserTobeInsert;
        }  
    }

    /**
     *  @description    :   Method is used to update Contact or Opportunity From 1EAB Lead to Opportunity Contact Role
     *                       
     *  @args           :   List for new 1EAB lead value, Map for old value
     * 
     *  @return         :   void
     *
     *  Revision Logs   :   V_1.0 - Created by - Nikita Kumari - CR-20210316-15000 - Add 1EAB Leads to Contact Roles
     *                      
     **/
    public static void updateEABContactOnOppContactRole(List<X1EAB_Lead__c> newEABLeadList,Map<Id, X1EAB_Lead__c> oldMapEABLead){
        
        //to hold new 1EAB Lead, new/old Opportunities, new/old Contact
        Map<Id, X1EAB_Lead__c> mapOfOppWithEABLeads = new Map<Id, X1EAB_Lead__c>(); 
        Set<Id> setOfOpportunities = new Set<Id>();
        Set<Id> setOfOldOpportunities = new Set<Id>();
        Set<Id> setOfContacts = new Set<Id>();        
        
        //loop over all 1EAB Leads
        for(X1EAB_Lead__c eabLead : newEABLeadList){
            //check if contact/opportunity is changed from 1EAB Leads
            if(oldMapEABLead != null &&(eabLead.Contact__c != oldMapEABLead.get(eabLead.Id).Contact__c 
                                        || eabLead.Opportunity__c != oldMapEABLead.get(eabLead.Id).Opportunity__c
                                       )
              ) 
            {
                //hold 1EAB Leads
                mapOfOppWithEABLeads.put(eabLead.Id, eabLead);
                
                //check Opportunities can't be null
                if(eabLead.Opportunity__c != null)
                    setOfOpportunities.add(eabLead.Opportunity__c);
                setOfContacts.add(eabLead.Contact__c);
                
                if(eabLead.Opportunity__c != oldMapEABLead.get(eabLead.Id).Opportunity__c && oldMapEABLead.get(eabLead.Id).Opportunity__c != null){
                    setOfOldOpportunities.add(oldMapEABLead.get(eabLead.Id).Opportunity__c);
                }
                //hold old contacts
                if(eabLead.Contact__c != oldMapEABLead.get(eabLead.Id).Contact__c && oldMapEABLead.get(eabLead.Id).Contact__c != null){
                    setOfContacts.add(oldMapEABLead.get(eabLead.Id).Contact__c);
                }
                
            }
        }
        
        //check if user change the opportunity from 1EAB Lead
        if(setOfOldOpportunities.size() > 0){
            //get list of all Contact roles for Opportunity
            List<OpportunityContactRole> opportunityContactRoleToBeDeleted = [SELECT Id From OpportunityContactRole 
                                                                              Where ContactId IN :setOfContacts 
                                                                              And OpportunityId IN :setOfOldOpportunities];
            //check if we have the contact roles that needs to be deleted
            if(opportunityContactRoleToBeDeleted.size() > 0){
                
                Util.byPassAllTriggers = true;
                Delete opportunityContactRoleToBeDeleted;
                Util.byPassAllTriggers = false;
            }
        }
        
        //check set of new Opp/contact size
        if(setOfOpportunities.size() > 0 && setOfContacts.size() > 0)
        {
            //to hold Contact Roles, Contacts detail, and mapping the opportunity with Role and Contact Id
            List<OpportunityContactRole> opportunityContactRoleToBeUpdate = new List<OpportunityContactRole>();
            Map<Id, Contact> mapOfContact = new Map<Id, Contact>([Select Id,EAB_Department__c from Contact Where Id IN: setOfContacts]);
            Map<Id, Map<Id, Id>> mapOfOpprtunityIdWithContactAndRoleId = new Map<Id, Map<Id, Id>>();
            
            for(OpportunityContactRole oppContRole : [SELECT Id, ContactId, OpportunityId From OpportunityContactRole 
                                                      Where ContactId IN :setOfContacts And OpportunityId IN :setOfOpportunities])
            {
                if(!mapOfOpprtunityIdWithContactAndRoleId.containsKey(oppContRole.OpportunityId)){
                    mapOfOpprtunityIdWithContactAndRoleId.put(oppContRole.OpportunityId, new Map<Id, Id>());
                }
                mapOfOpprtunityIdWithContactAndRoleId.get(oppContRole.OpportunityId).put(oppContRole.ContactId, oppContRole.Id);
            }
                        
            for(X1EAB_Lead__c eabLead : mapOfOppWithEABLeads.values()){
                
                //check if didn't have contact role for Opportunity
                if(!mapOfOpprtunityIdWithContactAndRoleId.containsKey(eabLead.Opportunity__c))
                {
                    
                    OpportunityContactRole oppContRole = new OpportunityContactRole(Source_Record_Id__c = eabLead.Id,Source_Record_Name__c =  eabLead.Name,
                                                                                    Role = (mapofContact.get(eabLead.Contact__c).EAB_Department__c != null ? mapofContact.get(eabLead.Contact__c).EAB_Department__c : Constants.CONTACT_ROLE_TYPE_OTHER), 
                                                                                    ContactId = eabLead.Contact__c, OpportunityId = eabLead.Opportunity__c);
                    opportunityContactRoleToBeUpdate.add(oppContRole);
                }
                //check if opportunity have contact role but contact needs to be updated
                else if(mapOfOpprtunityIdWithContactAndRoleId.containsKey(eabLead.Opportunity__c) 
                        && mapOfOpprtunityIdWithContactAndRoleId.get(eabLead.Opportunity__c).containsKey(oldMapEABLead.get(eabLead.Id).Contact__c))
                {
                    //check if contact is changed on 1EAB Lead
                    OpportunityContactRole oppContRole = new OpportunityContactRole(Id = mapOfOpprtunityIdWithContactAndRoleId.get(eabLead.Opportunity__c).get(oldMapEABLead.get(eabLead.Id).Contact__c),
                                                                                    Source_Record_Id__c = eabLead.Id, ContactId = eabLead.Contact__c,Source_Record_Name__c =  eabLead.Name,
                                                                                    Role = (mapofContact.get(eabLead.Contact__c).EAB_Department__c != null ? mapofContact.get(eabLead.Contact__c).EAB_Department__c : Constants.CONTACT_ROLE_TYPE_OTHER)
                                                                                   );
                    
                    opportunityContactRoleToBeUpdate.add(oppContRole);
                }
            }
                        
            //check list size before update
            if(opportunityContactRoleToBeUpdate.size() > 0){
                //create/update opportunity contact roles
                Util.byPassAllTriggers = true;
                Upsert opportunityContactRoleToBeUpdate; 
                Util.byPassAllTriggers = false;
            }  
        }     
    }
}