/**
    Purpose:    This class is to display the event details. This class will be served as controller for EventDetailsForOutlook page.-  CR-20111219-286
    
    Create By:  Simplyforce Technology
    
    Created Date:   12/22/2011
    
    Current Version:    v1.0
    
    Revision Log:
    
 **/
 public with sharing class EventDetailsForOutlook {
    
    //Calss variables
    public Opportunity opportunity{get; set;}
    public Contact contact{get; set;}
    
    //constructor
    public EventDetailsForOutlook(ApexPages.StandardController controller) {
        
        //get event record
        Event event = (Event)controller.getRecord();
        
        //initiate opportunity data 
        opportunity = new Opportunity();
        
        //fecth the opportunity related data using what Id
        List<Opportunity> listOpportunity = [Select Id, Membership__c, Membership__r.Membership_Status__c, (Select Id, Contact.Name, Contact.Title, Role from OpportunityContactRoles) from Opportunity where Id =: event.WhatId];
        
        //check for the list size and set the opportunity data
        if(listOpportunity.size() > 0)
            opportunity = listOpportunity[0];
            
        //initiate contact data
        contact = new Contact();
        
        //fecth the opportunity related data using what Id
        List<Contact> listContact = [Select Id, Description, AssistantName, AssistantPhone, ReportsToId, Phone, Title from Contact where Id =: event.WhoId];
        
        //check for the list size and set the opportunity data
        if(listContact.size() > 0)
            contact = listContact[0];
    }
}