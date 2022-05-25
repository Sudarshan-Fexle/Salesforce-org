/**
 *  Description     :   CompetitorSelectionSiteController
 * 
 *  Created By      :   Colin McGloin
 * 
 *  Created Date    :   09/14/2021
 * 
 *  Revision Logs   :   V1.0 - Created - Colin McGloin - 09/14/2021 - CR-20210824-15375
 * 
 **/
public without sharing class CompetitorSelectionSiteController {
    
    //Map for Pulling through Royall Records
    public Id parentId {get; set;}
    public Map<Royall_Program__c, List<Competitor_Selection__c>> mapRPToCompSel {get; set;}
    
    //Boolean
    public boolean displaySaveButton {get; set;}
    public string displayMode {get; set;}
    
    public CompetitorSelectionSiteController() {
        
        //Get the Parent ID from the Page and pass through to Getter
        parentId = ApexPages.currentPage().getParameters().get('parentId');
        
        displaySaveButton = true;
        displayMode = 'edit';
        
        //Get our Map Values
        mapRPToCompSel = getRoyallAndHDRecords();
    }
    
    public Map<Royall_Program__c, List<Competitor_Selection__c>> getRoyallAndHDRecords () {
        
        //Map to return
        Map<Royall_Program__c, List<Competitor_Selection__c>> mapRoyallProgramToRelatedComps = new Map<Royall_Program__c, List<Competitor_Selection__c>>();
        
        //Run the query to get the Program Royall&HD record and related Competitor Selection records
        List<Royall_Program__c> royallPrograms = [SELECT Id, Name, Diversity_Filter__c, Program_Quantity__c, State_Selections__c, Start_Date_CX__c, End_Date_CX__c, Program_Package__r.Account__r.Name, Campaign_New__c, Target_Audience_New__c,
                                                  (Select Name, Id, Program_Royall_HD__c, State__c, Competitor__c, Competitor_Name__c FROM Competitor_Selections__r ORDER BY State__c ASC)
                                                  FROM Royall_Program__c
                                                  WHERE Program_Package__c = :parentId];
        
        //Check to see if the list have values
        if (royallPrograms.size() > 0){
            
            //Loop through and add records to Map
            for (Royall_Program__c rProgram : royallPrograms){
                
                //Check for related records
                if (rProgram.Competitor_Selections__r.size() > 0){
                                        
                    //Add to Map
                    mapRoyallProgramToRelatedComps.put(rProgram, rProgram.Competitor_Selections__r);
                }
            }
            
            //Check to see if there are any records to update
            if (mapRoyallProgramToRelatedComps.values().size() > 0){
                
                Boolean allCompetitorsCompleted = true;
                
                //Loop through our keys
                for (Royall_Program__c rProg : mapRoyallProgramToRelatedComps.keyset()){
                    
                    //Check to see if we have values
                    if (mapRoyallProgramToRelatedComps.get(rProg) != null){
                        
                        //Loop through and see if any records are completed
                        for (Competitor_Selection__c cS : mapRoyallProgramToRelatedComps.get(rProg)){
                            
                            //If Competitor is blank then set boolean to false
                            if (cS.Competitor__c == null){
                                allCompetitorsCompleted = false;
                                displaySaveButton = false;//
                                displayMode = 'detail';
                            }
                        }
                    }
                }
                
                //If all records are completed then add message
                if (allCompetitorsCompleted){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your changes have been completed. Please contact intersectsupport@eab.com for questions or if you need to edit selections already completed.'));
                }
            }
        }
        
        return mapRoyallProgramToRelatedComps;
    }
    
    public void saveDocument(){
        
        //Basic Function - needs expanding
        List<Competitor_Selection__c> recordsToUpdate = new List<Competitor_Selection__c>();
        
        try {
            
            //Loop through Map and get all the records to Update
            for (Royall_Program__c rP : mapRPToCompSel.keyset()){
                
                //Grab the records
                if (mapRPToCompSel.get(rP) != null){
                    
                    //Loop through records and check that Competitor has been completed on all of them
                    for (Competitor_Selection__c cS : mapRPToCompSel.get(rP)){
                        
                        //If Competitor has not been completed on all records then throw an Error and return to the Page
                        if (cS.Competitor__c == null){
                            
                            //Grab Current Page
                            PageReference pageRef = ApexPages.currentPage();
                            
                            throw new customException('Please populate all Competitor values for all records before clicking Save.');
                            
                        }
                    }
                    
                    //Add records to the Update List
                    recordsToUpdate.addAll(mapRPToCompSel.get(rP));
                }
            }
            
            //Update records
            update recordsToUpdate;
            
            //Query to get our Intersect Contact
            List<Contact> intersectSupport = [SELECT Id, Email FROM Contact WHERE Email = :System.Label.Competitor_Selection_Email_Address LIMIT 1];
            
            //Check to see if we have our Contact - otherwise skip
            if (intersectSupport.size() > 0){
                
                //Create List of Email Addresses
                List <String> toEmailAddresses = new List<String>();
                toEmailAddresses.add(intersectSupport[0].Email);
                
                //Send Email to Support
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(System.Label.Competitor_Selection_Email_Template);
                mail.setToAddresses(toEmailAddresses);
                mail.setWhatId(parentId);
                mail.setTargetObjectId(intersectSupport[0].Id);
                
                //Set the false so that no activity records can be created when an email is sent 
                List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                emails.add(mail);
                Messaging.sendEmail(emails);
                                
            }
            
            
            //Add Message to let the user this was completed
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your Updates have been completed. Please close out the browser.'));
            
        } catch(Exception ex) {
            
            //Return errors to the VF Page
            ApexPages.addMessages(ex);
            
        }
    }
    
}