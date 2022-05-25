/*
    Purpose         :   This class is helper class for trigger on Restriction Clearance Requests object.
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   11/07/2012
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created - CR-20120924-1526
                        V_1.2 - Modified By - Mahendra Swarnakar - 10/10/2016 - CR-20160426-9797
                        V_1.3 - Modified By - Abhinav Sharma -2/20/2018 - CR-20170119-10646
*/
public without sharing class RestrictionClearanceRequestHelper {
    
    //This method is to update the Warm Lead status when restriction Clearance Request is getting created
    public static void updateWarmLeads(List<Restriction_Clearance_Request__c> rCRequests) {
        
        //Create a set to hold the warm lead Ids and maintian the uniqueness
        Set<Id> warmLeadsIds = new Set<Id>();
        
        //Create a list of the Warm Lead records to be updated
        List<Warm_Lead__c> warmLeads = new List<Warm_Lead__c>();
        
        //Loop through the requests
        for(Restriction_Clearance_Request__c rCR : rCRequests) {
            
            //Check if Warm_Lead__c is not null and add in set
            if(rCR.Warm_Lead__c != null)
                warmLeadsIds.add(rCR.Warm_Lead__c);
        }
        
        //Query all the Warm leads which are not having status = 'Pending Restriction Clearance'
        for(Warm_Lead__c warmLead : [Select Status__c from Warm_Lead__c where Status__c !=: Constants.STATUS_WARM_LEAD_PENDING_RESTRICTION_CLEARANCE
                                        AND ID IN: warmLeadsIds]) {
            
            //Set the status and add recotrds in the list to be updated
            warmLead.Status__c = Constants.STATUS_WARM_LEAD_PENDING_RESTRICTION_CLEARANCE;
            warmLeads.add(warmLead);
        }
        
        //check for the size and update the records
        if(warmLeads.size() > 0)
            update warmLeads;
    }
    
    //Added BY - Mahendra Swarnakar - 10/10/2016 - CR-20160426-9797
    public static void sendEmailToRestrictionOwner(List<Restriction_Clearance_Request__c> rCRequests){
        
        //Set to hold the user IDs
        Set<Id> setUsersIds = new Set<Id>();
        
        //Set to hold the program ID associated with the restriction Clearance Request Record
        Set<Id> setProgramIds = new Set<Id>();
        
        //Set to hold the contact ID associated with the restriction Clearance Request Record
        Set<Id> setContacts = new Set<Id>();
        
        //Loop over restriction Clearance Request new Records
        for(Restriction_Clearance_Request__c rcr : rCRequests) {
           
            //Checking for the restriction owner field value and adding reference to collection accordingly
            if(rcr.Restriction_Owner_2__c != null)
                setUsersIds.add(rcr.Restriction_Owner_2__c);
            
            //Checking for the owner field value and adding reference to collection accordingly
            if(rcr.OwnerId != null)
                setUsersIds.add(rcr.OwnerId);

            //Checking for program field value and adding reference to the collection
            if(rcr.Program__c != null)
                setProgramIds.add(rcr.Program__c);
            
            //Checking for Contact field value and adding reference to the collection
            if(rcr.Contact__c != null)
                setContacts.add(rcr.Contact__c);
        }
        
        //Map to hold userId with User records Details
        Map<Id, User> mapOfUsers = new Map<Id, User>();
        Map<Id, Program__c> mapOfPrograms = new Map<Id, Program__c>();
        Map<Id, Contact> mapOfContacts = new Map<Id, Contact>();
        
        //Checking for size value and populating map of user accordingly 
        if(setUsersIds.size() > 0)
            mapOfUsers = new Map<Id, User>([SELECT Id, Email, FirstName, LastName, Name
                                            FROM User 
                                            WHERE Id IN : setUsersIds 
                                            AND IsActive = true
                                            AND Email != null
                                            AND Email != ''
                                           ]);
        
        //Checking for size value and populating map of program accordingly 
        if(setProgramIds.size() > 0)
            mapOfPrograms = new Map<Id, Program__c>([SELECT Id, Name, Program_Acronym__c  
                                                     FROM Program__c
                                                     WHERE Id IN : setProgramIds]);
        
        //Checking for size value and populating map of contact accordingly 
        if(setContacts.size() > 0)
            mapOfContacts = new Map<Id, Contact>([SELECT Id, Name, 
                                                  Account.Account_Formal_Name__c
                                                  FROM Contact 
                                                  WHERE Id IN : setContacts
                                                 ]);
        
        //Step 0: Create a master list to hold the emails we'll send
        List<Messaging.singleEmailMessage> mails = new List<Messaging.singleEmailMessage>();
        
        //Loop through restriction clearance request records                                
        for(Restriction_Clearance_Request__c rcr : rCRequests) {
            
            //Checking for "Restriction Owner" field value
            if(rcr.Restriction_Owner_2__c != null) {
                
                // Step 1: Create a new Email
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                //Check for UserMAp
                if(mapOfUsers.size() > 0) {
                    
                    //Checking for key presence in the map
                    if(mapOfUsers.containsKey(rcr.Restriction_Owner_2__c) 
                        && mapOfUsers.get(rcr.Restriction_Owner_2__c) != null
                        && mapOfUsers.containsKey(rcr.OwnerId)
                        && mapOfUsers.get(rcr.OwnerId) != null) {

                        /// Step 2: Set list of people who should get the email
                        List<String> sendTo = new List<String>();
                        sendTo.add(mapOfUsers.get(rcr.Restriction_Owner_2__c).Email);
                        mail.setToAddresses(sendTo);

                        // Step 3: Set who the email is sent from
                        mail.setReplyTo(mapOfUsers.get(rcr.OwnerId).Email);
                        mail.setSenderDisplayName(mapOfUsers.get(rcr.OwnerId).Name);
                            
                        // Step 4. Set email contents - you can use variables!
                        mail.setSubject('RCR: ' + ' ' + rCR.Name + ' ');
                   
                        //Step 5. Setting email body
                        String body = 'Creator has assigned you the following new restriction clearance request:';
                        body += ' <BR></BR> ';
                        body += '<B>Restriction Clearance Request Name:</B> ' + rCR.Name;
                        body += ' <BR></BR> ';
                        body += '<B>Contact Institution:</B> ' + rCR.Contact_Institution__c;
                        body += ' <BR></BR> ';
                        body += '<B>Contact:</B> ';
                        
                        //Checking for value in map and accordingly adding it to email template   
                        if(rcr.Contact__c != null && mapOfContacts.get(rcr.Contact__c).Name != null)
                            body += mapOfContacts.get(rcr.Contact__c).Name;
                        else
                            body += '';
                        
                        body += ' <BR></BR> ';
                        body += '<B>Program:</B> ';
                            
                        //Checking for value in map and accordingly adding it to email template   
                        if(rcr.Program__c != null && mapOfPrograms.get(rcr.Program__c).Name != null)
                            body += mapOfPrograms.get(rcr.Program__c).Name;
                        else
                            body += '';
                            
                        body += ' <BR></BR> ';
                        body += '<B>Type of Interaction Requested:</B> ' + rCR.Type_of_Interaction_Requested__c;
                        body += ' <BR></BR> ';
                        body += '<B>Clearance Request Comments:</B> ' + rCR.Clearance_Request_Comments__c;
                        body += ' <BR></BR> ';
                        body += ' <BR></BR> ';
                        body += '<B>For more details, click the following link:</B> ';
                        body += ' <BR></BR> '; 
                        body += URL.getSalesforceBaseUrl().toExternalForm() + '/' + rCR.Id;
                        mail.setHtmlBody(body);    
                        
                        // Step 6. Add your email to the master list
                        mails.add(mail);
                    }
                }
            }
        }
                
        //Checking for the size value and sending email
        if(mails.size() > 0)
            Messaging.sendEmail(mails);     
    }
    
    //Added By - Mahendra Swarnakar - 10/10/2016 - CR-20160426-9797
    //V_1.3 - Modified By - Abhinav Sharma -2/20/2018 - CR-20170119-10646
    public static void populateNameOnRCRRecords(List<Restriction_Clearance_Request__c> rCRequests){
    
        //Set of program records IDs
        Set<Id> setOfProgramsIds = new Set<Id>();
    
        //Set of Marketers IDs
        Set<Id> setOfMarketersIds = new Set<Id>();
    
        //Loop over restriction Clearance Request new Records
        for(Restriction_Clearance_Request__c rcr : rCRequests){
    
            //Checking for program field value and adding reference to the collection
            if(rcr.Program__c != null)
                setOfProgramsIds.add(rcr.Program__c);
        
            //Checking for marketer field value and adding reference to the collection
            if(rcr.Marketer__c != null)
                setOfMarketersIds.add(rcr.Marketer__c);
        }
    
        //Map of Programs
        Map<Id, Program__c> mapOfPrograms = new Map<Id, Program__c>();
    
        //Checking for size value and populating map of program accordingly 
        if(setOfProgramsIds.size() > 0)
            mapOfPrograms = new Map<Id, Program__c>([SELECT Id, Name, Program_Acronym__c  
                                 FROM Program__c
                                 WHERE Id IN : setOfProgramsIds]);
    
        //Map of Marketers
        Map<Id, User> mapOfMarkters = new Map<Id, User>();  
    
        //Checking for size value and populating map of user accordingly 
        if(setOfMarketersIds.size() > 0)
            mapOfMarkters = new Map<Id, User>([SELECT Id, Email, Name, FirstName, LastName 
                            FROM User 
                            WHERE Id IN : setOfMarketersIds 
                               ]);
    
        //Loop through restriction clearance request records                                
        for(Restriction_Clearance_Request__c rcr1 : rCRequests){
    
            //Checking field for a valid value
            if(String.isNotBlank(rcr1.Contact_Institution__c)) {
    
                //Checking if "-" exists in between value for Contact_Institution__c field a rcr record
                if(rcr1.Contact_Institution__c.split('-') != null && rcr1.Contact_Institution__c.split('-').size() > 0)
                    rcr1.Name = rcr1.Contact_Institution__c.split('-')[0].trim();
                else
                    rcr1.Name = rcr1.Contact_Institution__c.trim();
            }
                
            rcr1.Name += '-';
    
            //Checking if "-" exists in between value for Contact_Institution__c field a rcr record
            if(rcr1.Program__c != null 
                &&
                mapOfPrograms.containsKey(rcr1.Program__c) 
                &&
                mapOfPrograms.get(rcr1.Program__c) != null
                &&
                String.isNotBlank(mapOfPrograms.get(rcr1.Program__c).Program_Acronym__c)
            )
                rcr1.Name += mapOfPrograms.get(rcr1.Program__c).Program_Acronym__c.trim();
            else
                rcr1.Name += '';
    
            rcr1.Name += '-';
    
            //Checking for length of "Type of Omtravtion requested field value
            if(String.isNotBlank(rcr1.Type_of_Interaction_Requested__c)) {
                if( rcr1.Type_of_Interaction_Requested__c.length() > 18)
                    rcr1.Name += rcr1.Type_of_Interaction_Requested__c.subString(0,18).trim();
                else
                    rcr1.Name += rcr1.Type_of_Interaction_Requested__c.trim();
            }
    
            rcr1.Name += '-';
    
            // Checking if markter field is having non null/blank value with it
            if(rcr1.Marketer__c != null 
                && 
                mapOfMarkters.ContainsKey(rcr1.Marketer__c)
                && 
                mapOfMarkters.get(rcr1.Marketer__c) != null
            ){
            
                //Checking for the firstname field value    
                if(mapOfMarkters.get(rcr1.Marketer__c).FirstName != null)
                    rcr1.Name +=  mapOfMarkters.get(rcr1.Marketer__c).FirstName.trim() + ' ';
    
                //Checking for the lastname field value 
                if(mapOfMarkters.get(rcr1.Marketer__c).LastName != null)
                    rcr1.Name +=  mapOfMarkters.get(rcr1.Marketer__c).LastName.trim();
            
            } else {
                rcr1.Name += '';
            }
			//V_1.3 - Modified By - Abhinav Sharma -2/20/2018 - CR-20170119-10646
			//Additional condition to check name maximum length
			if(rcr1.Name.length() > 80)
				rcr1.Name = rcr1.Name.substring(0, 79);
        }
    }
}