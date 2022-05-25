/**
*  Description     :   Helper class for Survey Invitation object
* 
*  Created By      :   Ayush Gupta    
* 
*  Created Date    :   03/23/2013
* 
*  Revision Logs   :   V_1.0 - Created
*		       V_1.1 - Modified By - Ayush Gupta - 08/25/2021 - CR-20210824-15377
*		       V_1.2 - Modified By - Ayush Gupta - 08/31/2021 - CR-20210829-15391
*		       V_1.3 - Modified By - Ayush Gupta - CR-20210826-15383
*                      V_1.4 - Modified By - Shalu Sharma - 01/12/20222 - CR-20211130-15609 - Populate Participant field on Survey Invitation
**/
public class SurveyInvitationHelper {
    
    /**
    *  @description    :   This method is used to populate Support Product and GD Component on case
    * 
    *  @return         :   Void
    * 
    *  @Revision Log   :   V1.0 - Created By - Ayush Gupta - 07/27/2021 - CR-20210526-15183 - Salesforce Surveys setup
    * 		       :   V1.1 - Modified By - Shalu Sharma - 01/12/20222 - CR-20211130-15609 - Populate Participant field on Survey Invitation
    **/
    public static void sentSurveyToUsers(Map<Id, Case> mapOfNewCases, Map<Id, Case> oldMapOfCases) {
        
        Map<Id, SurveyInvitation> mapOfCaseWithSurveyInvitations = new Map<Id, SurveyInvitation>();
        Map<String, Set<Id>> mapCaseRecordTypeWithIds = new Map<String, Set<Id>>();
        Map<String, Id> mapSurveyNameWithIds = new Map<String, Id>();
        Map<String, Id> mapNetworkNameWithIds = new Map<String, Id>();
        Boolean isStarfish = false;
        Boolean isIntersect = false;
        Set<Id> setCaseIds = new Set<Id>();
        List<Case> caseTobeUpdate = new List<Case>();
        Map<Id, String> mapCaseOwnerwithCaseId = new Map<Id, String>();
                
        for(RecordType rt :[Select Id, DeveloperName, Name From RecordType 
                            Where (DeveloperName IN :Constants.CASE_STARFISH_SURVEY_RELATED_RT_NAME OR DeveloperName IN :Constants.CASE_INTERSECT_SURVEY_RELATED_RT_NAME)
                            And SobjectType = 'Case'])
        {
            if(Constants.CASE_STARFISH_SURVEY_RELATED_RT_NAME.contains(rt.DeveloperName)){
                
                if(!mapCaseRecordTypeWithIds.containsKey(Constants.STARFISH_NAME))
                    mapCaseRecordTypeWithIds.put(Constants.STARFISH_NAME, new set<Id>());
                
                mapCaseRecordTypeWithIds.get(Constants.STARFISH_NAME).add(rt.Id);
            }
            else if(Constants.CASE_INTERSECT_SURVEY_RELATED_RT_NAME.contains(rt.DeveloperName)){
                
                if(!mapCaseRecordTypeWithIds.containsKey(Constants.INTERSECT_NAME))
                    mapCaseRecordTypeWithIds.put(Constants.INTERSECT_NAME, new set<Id>());
                
                mapCaseRecordTypeWithIds.get(Constants.INTERSECT_NAME).add(rt.Id);
            }
        }
        
        //get Surevy Ids
        for(Survey sur :[Select Id,Name, DeveloperName From Survey Where DeveloperName IN :Constants.CASE_SURVEY_DEV_NAMES])
        {
            if(!mapSurveyNameWithIds.containsKey(Constants.STARFISH_NAME) && sur.DeveloperName == Constants.EAB_STARFISH_SURVEY_DEVNAME)
            	mapSurveyNameWithIds.put(Constants.STARFISH_NAME, sur.Id);
            
            if(!mapSurveyNameWithIds.containsKey(Constants.INTERSECT_NAME) && sur.DeveloperName == Constants.EAB_NAVIANCE_SURVEY_DEVNAME)
            	mapSurveyNameWithIds.put(Constants.INTERSECT_NAME, sur.Id);
        }
        for(Network net :[SELECT Id, Name FROM Network Where Name IN :Constants.CASE_COMMUNITY_Network_NAMES])
        {
            if(!mapNetworkNameWithIds.containsKey(Constants.STARFISH_NAME) && net.Name == Constants.STARFISH_SURVEY_NETWORK_NAME)
                mapNetworkNameWithIds.put(Constants.STARFISH_NAME, net.Id);
            
            if(!mapNetworkNameWithIds.containsKey(Constants.INTERSECT_NAME) && net.Name == Constants.NAVIANCE_SURVEY_NETWORK_NAME)
                mapNetworkNameWithIds.put(Constants.INTERSECT_NAME, net.Id);
        }        

        for(Case newCase : mapOfNewCases.values()) {

            //Populate the case Id
            setCaseIds.add(newCase.Id);
            
	    //Modified By - Ayush Gupta - 08/31/2021 - CR-20210829-15391
            //check survey is sent or not
            if(!newCase.Survey_Sent__c && newCase.Status == 'Closed' && (newCase.Case_Category__c != 'Duplicate'))
            {
                if(mapCaseRecordTypeWithIds.values().size() > 0 && mapCaseRecordTypeWithIds.get(Constants.STARFISH_NAME).contains(newCase.RecordTypeId) 
                   && mapNetworkNameWithIds.values().size() > 0 && mapSurveyNameWithIds.values().size() > 0)
                {
                    //Added By - Shalu Sharma - 01/12/20222 - CR-20211130-15609 - Populate Participant field on Survey Invitation
                    //create survey invite for contact 
                    mapOfCaseWithSurveyInvitations.put(newCase.Id, new SurveyInvitation(Name = 'Survey Invitation - '+newCase.CaseNumber,
                                                                                        CommunityId = mapNetworkNameWithIds.get(Constants.STARFISH_NAME), 
                                                                                        ParticipantId = newCase.ContactId, 
                                                                                        OptionsAllowGuestUserResponse = true,
                                                                                        SurveyId = mapSurveyNameWithIds.get(Constants.STARFISH_NAME)
                                                                                       ));
                    isStarfish = true;
                }
                if(mapCaseRecordTypeWithIds != null && mapCaseRecordTypeWithIds.values().size() > 0
                   && mapCaseRecordTypeWithIds.get(Constants.INTERSECT_NAME).contains(newCase.RecordTypeId)
                  && mapNetworkNameWithIds.values().size() > 0 && mapSurveyNameWithIds.values().size() > 0)
                {
                    //Added By - Shalu Sharma - 01/12/20222 - CR-20211130-15609 - Populate Participant field on Survey Invitation
                    //create survey invite for contact
                    mapOfCaseWithSurveyInvitations.put(newCase.Id, new SurveyInvitation(Name = 'Survey Invitation - '+newCase.CaseNumber,
                                                                                        CommunityId = mapNetworkNameWithIds.get(Constants.INTERSECT_NAME), 
                                                                                        ParticipantId = newCase.ContactId,
                                                                                        OptionsAllowGuestUserResponse = true,
                                                                                        SurveyId = mapSurveyNameWithIds.get(Constants.INTERSECT_NAME)
                                                                                       ));
                    isIntersect = true;
                }
            }
        }
        
        for(Case cs :[SELECT Id,owner.name FROM Case WHERE Id IN: setCaseIds]){
            
            if(!mapCaseOwnerwithCaseId.containsKey(cs.Id))
                mapCaseOwnerwithCaseId.put(cs.Id, cs.Owner.Name);
        }
        
        //check list size
        if(mapOfCaseWithSurveyInvitations.size() > 0 && mapOfCaseWithSurveyInvitations.values().size() > 0){
            
            Util.ByPassAllTriggers = true;
            Insert mapOfCaseWithSurveyInvitations.values();
            Util.BypassAllTriggers = false;
            
            // Step 0: Create a master list to hold the emails we'll send
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            
            List<SurveySubject> listOfSurveySubjects = new List<SurveySubject>();
            
            for(Id caseId : mapOfCaseWithSurveyInvitations.keySet()){
                
                String surveySubjName = mapOfCaseWithSurveyInvitations.get(caseId).Name.replace('Invitation', 'Subject');
                listOfSurveySubjects.add(new SurveySubject( ParentId = mapOfCaseWithSurveyInvitations.get(caseId).Id, SubjectId = caseId, Name = surveySubjName));
            }
            if(listOfSurveySubjects.size() > 0){
                
                Util.ByPassAllTriggers = true;
                Insert listOfSurveySubjects;
                Util.ByPassAllTriggers = false;
            }
            if(isStarfish){
                OrgWideEmailAddress owa = [select Id, Address from OrgWideEmailAddress Where Address = 'starfishsupport@eab.com'];
                
                for(SurveyInvitation surveyInvt : [Select Id, InvitationLink, Owner.Name,
                                                   (Select Id, ParentId, SubjectId,Subject.Owner.Name From SurveySubjects) 
                                                   From SurveyInvitation Where Id IN: mapOfCaseWithSurveyInvitations.values()])
                {
                    
                    //new Case details
                    Case newCase = mapOfNewCases.get(surveyInvt.SurveySubjects[0].SubjectId);
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    // Step 2: Set list of people who should get the email
                    List<String> sendTo = new List<String>();
                    
                    if(String.isNotBlank(newCase.ContactEmail)){
                        sendTo.add(newCase.ContactEmail);
                        
                        mail.setToAddresses(sendTo);
                        
                        // Step 3: Set who the email is sent from
                        //mail.setSenderDisplayName('EAB Starfish Support');
                        mail.setOrgWideEmailAddressId(owa.Id);
                        
                        // Step 4. Set email contents - you can use variables!
                        mail.setSubject('How would you rate the support you received?');
                        String body = '';
                        body += '<p>Dear '+ newCase.Contact_Name__c +',</p>' +
                            '<p>You recently contacted EAB support for '+ newCase.Support_Product__c +' and we would appreciate'+
                            ' your feedback on the service you received from '+ mapCaseOwnerwithCaseId.get(newCase.Id) + '. Please take a moment to complete this'+
                            ' short survey with regards to Case number '+ newCase.CaseNumber + ', in reference to case subject: ' + newCase.Subject +'.</p>'+
                            '<p>Take Our Survey - <a href="' + surveyInvt.InvitationLink + '" rel="noopener noreferrer" target="_blank">Click Here</a></p>'+
                            '<p>Your feedback will be used to improve our service levels and will take less than 5 minutes to complete.</p>'+
                            '<p>Sincerely,</p>'+
                            '<p>EAB Support Management</p><p><br></p>';
                        
                        mail.setHtmlBody(body);
                        
                        // Step 5. Add your email to the master list
                        mails.add(mail);
                       
                        Case newStarCase = new Case();
                        newStarCase.Id = newCase.Id;
                        newStarCase.Survey_Sent__c = true;
                        
                        caseToBeUpdate.add(newStarCase);
                    }
                }
            }
            else if(isIntersect){
                OrgWideEmailAddress owaInter = [select Id, Address from OrgWideEmailAddress Where Address = 'intersectsupport@eab.com'];
                
                for(SurveyInvitation surveyInvt : [Select Id, InvitationLink,Owner.Name, 
                                                   (Select Id, ParentId, SubjectId,Subject.Owner.Name From SurveySubjects) 
                                                   From SurveyInvitation Where Id IN: mapOfCaseWithSurveyInvitations.values()])
                {
                    //new Case details
                    Case newCase = mapOfNewCases.get(surveyInvt.SurveySubjects[0].SubjectId);
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    // Step 2: Set list of people who should get the email
                    List<String> sendTo = new List<String>();
                    if(String.isNotBlank(newCase.ContactEmail)){
                        sendTo.add(newCase.ContactEmail);
                        
                        mail.setToAddresses(sendTo);
                        
                        // Step 3: Set who the email is sent from
                        //mail.setSenderDisplayName('EAB Starfish Support');
                        mail.setOrgWideEmailAddressId(owaInter.Id);
                        
                        // Step 4. Set email contents - you can use variables!
                        mail.setSubject('How would you rate the support you received?');
                        String body = '';
                        body += '<p>Dear '+ newCase.Contact_Name__c +',</p>' +
                            '<p>You recently contacted Intersect Support for '+ newCase.Support_Product__c +' and we would appreciate'+
                            ' your feedback on the service you received from '+  mapCaseOwnerwithCaseId.get(newCase.Id) + '. Please take a moment to complete this'+
                            ' short survey with regards to Case number '+ newCase.CaseNumber + ', in reference to case subject: ' + newCase.Subject +'.</p>'+
                            '<p>Take Our Survey - <a href="' + surveyInvt.InvitationLink + '" rel="noopener noreferrer" target="_blank">Click Here</a></p>'+
                            '<p>Your feedback will be used to improve our service levels and will take less than 5 minutes to complete.</p>'+
                            '<p>Sincerely,</p>'+
                            '<p>Intersect Support Management</p><p><br></p>';
                        
                        mail.setHtmlBody(body);
                        
                        // Step 5. Add your email to the master list
                        mails.add(mail);
                      
                        Case newInterCase = new Case();
                        newInterCase.Id = newCase.Id;
                        newInterCase.Survey_Sent__c = true;
                        
                        caseToBeUpdate.add(newInterCase);
                    }
                }              
            }
            
            if(caseToBeUpdate.size() > 0){
                //Bypass all logic
                Util.byPassAllTriggers = true;
                
                update caseToBeUpdate;
                
                //Bypass all logic
                Util.byPassAllTriggers = false;
                
            }
            //check mails size
            if(mails.size() > 0){
                //send all emails
                Messaging.sendEmail(mails);
                CaseTriggerHelper.BYPASS_SURVEY_INVITATION_HELPER = true;
            }

        }
    }
}