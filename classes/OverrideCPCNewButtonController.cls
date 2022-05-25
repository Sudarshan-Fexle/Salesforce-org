/**
 *  Purpose         :   Controller for OverrideCPCNewButton VF page. 
 * 
 *  Created By      :   Subhash Garhwal
 * 
 *  Created Date    :   07/24/2015 
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20150618-9013
 * 
 **/
public with sharing class OverrideCPCNewButtonController {
    
    //Properties
    public Program_Relationship__c pR {get;set;}
    
    //Constructor
    public OverrideCPCNewButtonController(ApexPages.StandardController SC) {
        
        //Get the record
        pR = (Program_Relationship__c)SC.getRecord();
        
    }
    
    /**
     *  @description    :   This method is used to redirect user on record type selection page
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/
     public Pagereference redirect() {
        
        //Check for Program Perspcetive
        if(pR != null && pR.RecordTypeId != null) {
            
            //Return URL
            String afterSaveURL = '/apex/RedirectWithVariables?redirect=Object--Program_Relationship__c!!Name--Will Auto-Populates!!RecordTypeId--' + pR.RecordTypeId;
            
            //Check for Collection perspective
            if(pR.Program_Perspective__c != null) {
                
                //Query through Program Perspective (Collection Perspective)
                Program_Perspective__c pP = [Select Id, Business_Owner__c, Effective_Start__c, Effective_End__c From Program_Perspective__c Where Id =: pR.Program_Perspective__c];
                
                //Pass Parameters
                afterSaveURL += '!!Program_Perspective__c--' + pP.Id;
                
                //Check for business Owner
                if(String.isNotBlank(pP.Business_Owner__c))
                    afterSaveURL += '!!Business_Owner__c--' + pP.Business_Owner__c;
                
                //Check for Effective_Start__c
                if(pP.Effective_Start__c != null)
                    afterSaveURL += '!!Effective_Start__c--' + pP.Effective_Start__c.format();
                
                //Add save URL and return URL in string
                afterSaveURL += '!!afterSaveURL--/' + pP.Id + '!!returnURL--/' + pP.Id; 
                
            } else if(pR.Program__c != null) {
                
                //Query through contact to get current user's contact
                List<Contact> contact = [Select Id From Contact Where Employee_User_Record__c =: Userinfo.getUserId() LIMIT 1];
                
                //Check for contact
                if(contact.size() > 0)
                    afterSaveURL += '!!Business_Owner__c--' + contact[0].Id;
                
                //Pass Parameters
                afterSaveURL += '!!Program__c--' + pR.Program__c + '!!returnURL--/' + pR.Program__c;
            
            } else if(pR.Program_Group__c != null) {
                
                //Query through contact to get current user's contact
                List<Contact> contact = [Select Id From Contact Where Employee_User_Record__c =: Userinfo.getUserId() LIMIT 1];
                
                //Check for contact
                if(contact.size() > 0)
                    afterSaveURL += '!!Business_Owner__c--' + contact[0].Id;
                    
                //Pass Parameters
                afterSaveURL += '!!Program_Group__c--' + pR.Program_Group__c + '!!returnURL--/' + pR.Program_Group__c;
            
            } else if(pR.Business_Owner__c != null) {
                
                //Pass Parameters
                afterSaveURL += '!!Business_Owner__c--' + pR.Business_Owner__c + '!!returnURL--/' + pR.Business_Owner__c;
            }
            
            //Return
            return new PageReference(afterSaveURL); 
        }
        
        //Return
        return null;
     }

}