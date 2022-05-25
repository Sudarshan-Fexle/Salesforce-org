/**
*Purpose         :   Test class for CaseTriggerHelper
*
*Created By       :  Ayush Gupta  
*
*Created Date    :   07/29/2021
*
*Revision Log    :   V_1.0 - Created - Ayush Gupta - CR-20210526-15183
*		     V_1.1 - Modified By - Ayush Gupta - CR-20210826-15383
*		     V_1.2 - Modified By - Shalu Sharma - 01/12/20222 - CR-20211130-15609
**/
@isTest(seeAllData=true)
public with sharing class Test_SurveyInvitationHelper {
    /** 
     * Description : Method to test out the logic which is responsible to populate Support Product and GD Component on case
    **/
    static testmethod void test_sentSurveyToUsersForStarfish(){

        //Bypass Dupeblocker
        Util.IsTest(true);

        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        Account acc = TestUtilities.CreateNewAccount(true);
        Contact con = TestUtilities.CreateNewContact(acc,true);
        Util.BypassAllTriggers = false;
        FeedItem fi = new FeedItem(ParentId = acc.Id, Body = 'Test Body');
        insert fi;
        
        //Create Feed Comment Record
        FeedComment fc = new FeedComment(FeedItemId = fi.Id, CommentBody = 'Test Comment');
        insert fc;

        //Querying Details for "Technical_Support,APS_Review & Starfish" record type on Case Object
        List<RecordType> starfishRecordTypeIds = [Select Id From RecordType Where DeveloperName IN ('APS_Review','Starfish') And SobjectType = 'Case'];

        //Assert for the results
        System.assert(starfishRecordTypeIds != null);
        
        List<Case> caseList = new List<Case>();

        //Creating Case
        caseList.add(new Case(RecordTypeId = starfishRecordTypeIds[0].Id, Origin = 'Other', Subject = 'Test SurveyInvitation', 
                            Description = 'Test SurveyInvitation',Status = 'New',Priority = 'Minor',Support_Product__c = 'Starfish',
                            ContactId = con.Id,AccountId = acc.Id));

        caseList.add(new Case(RecordTypeId = starfishRecordTypeIds[1].Id, Origin = 'Other', Subject = 'Test SurveyInvitation', 
                            Description = 'Test SurveyInvitation',Status = 'New',Priority = 'Minor',Support_Product__c = 'Starfish',
                            ContactId = con.Id,AccountId = acc.Id));

        //Inserting the Case list
        Insert caseList;

        FeedItem fi1 = new FeedItem(ParentId = acc.Id, Body = 'Test Body');
        insert fi1;
        
        //Create Feed Comment Record
        FeedComment fc1 = new FeedComment(FeedItemId = fi.Id, CommentBody = 'Test Comment');
        insert fc1;
        
        //Start Test from here
        Test.startTest();
        
        //Enabling triggers so then helper class written logic can be execute on DML event
        Util.byPassAllTriggers = false;
        
        caseList[0].Status = 'Closed';
        caseList[1].Status = 'Closed';
        Set<Id> setOfCaseId = new Set<Id>{caseList[0].Id, caseList[1].Id};

        Update caseList;

        //Querying case records
        List<SurveyInvitation> surveyInvt = [Select Id, InvitationLink, ParticipantId From SurveyInvitation WHERE ParticipantId = :con.Id];
        List<SurveySubject> surveySubj = [Select ParentId, SubjectId,Name From SurveySubject WHERE SubjectId IN : setOfCaseId];
        List<Case> casesList = [Select Id,CaseNumber,Survey_Sent__c,RecordType.Name From Case WHERE Id IN :caseList];
        
        //Added By - Shalu Sharma - 01/12/20222 - CR-20211130-15609 - Check Assert for the Participant
        System.assertEquals(con.Id, surveyInvt[0].ParticipantId);
        
        //Stop Test here
        Test.stopTest();
        
       }
        
    /** 
     * Description : Method to test out the logic which is responsible to populate Support Product and GD Component on case
    **/

    static testmethod void test_sentSurveyToUsersForIntersect(){

        //Bypass Dupeblocker
        Util.IsTest(true);

        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        Account acc = TestUtilities.CreateNewAccount(true);
        Contact con = TestUtilities.CreateNewContact(acc,true);

        //Querying Details for "Intersect,Counselor_Community and Intersect_APS" record type on Case Object
        List<RecordType> intersectRecordTypeIds = [Select Id From RecordType Where DeveloperName IN ('Intersect','Counselor_Community','Intersect_APS','Technical_Support') And SobjectType = 'Case' ORDER BY Name ASC];

        //Assert for the results
        System.assert(intersectRecordTypeIds != null);

        //List to hold the case records
        List<Case> caseList = new List<Case>();

        //Creating Case
        caseList.add(new Case(RecordTypeId = intersectRecordTypeIds[0].Id, Origin = 'Other', Subject = 'Test SurveyInvitation', 
                            Description = 'Test SurveyInvitation',Status = 'New',Priority = 'Minor',Support_Product__c = 'Intersect',
                            ContactId = con.Id,AccountId = acc.Id));

        caseList.add(new Case(RecordTypeId = intersectRecordTypeIds[1].Id, Origin = 'Other', Subject = 'Test SurveyInvitation', 
                            Description = 'Test SurveyInvitation',Status = 'New',Priority = 'Minor',Support_Product__c = 'Intersect',
                            ContactId = con.Id,AccountId = acc.Id));
        
        caseList.add(new Case(RecordTypeId = intersectRecordTypeIds[2].Id, Origin = 'Other', Subject = 'Test SurveyInvitation', 
                            Description = 'Test SurveyInvitation',Status = 'New',Priority = 'Minor',Support_Product__c = 'Intersect',
                            ContactId = con.Id,AccountId = acc.Id));
        
        caseList.add(new Case(RecordTypeId = intersectRecordTypeIds[3].Id, Origin = 'Other', Subject = 'Test SurveyInvitation', 
                            Description = 'Test SurveyInvitation',Status = 'New',Priority = 'Minor',Support_Product__c = 'Starfish',
                            ContactId = con.Id,AccountId = acc.Id));


        //Inserting the Case list
        Insert caseList;

        //Start Test from here
        Test.startTest();
        
        //Enabling triggers so then helper class written logic can be execute on DML event
        Util.byPassAllTriggers = false;
        
        caseList[0].Status = 'Closed';
        caseList[1].Status = 'Closed';
        caseList[2].Status = 'Closed';
        caseList[3].Status = 'Closed';
        Set<Id> setOfCaseId = new Set<Id>{caseList[0].Id, caseList[1].Id,caseList[2].Id, caseList[3].Id};

        Update caseList;

        //Querying case records
        List<SurveyInvitation> surveyInvt = [Select Id, InvitationLink From SurveyInvitation WHERE ParticipantId = :con.Id];
        List<SurveySubject> surveySubj = [Select ParentId, SubjectId,Name From SurveySubject WHERE SubjectId IN : setOfCaseId];
        List<Case> casesList = [Select Id,CaseNumber,Survey_Sent__c From Case WHERE Id IN :setOfCaseId];

       
        Group groups =  constants.tier2SupportQueue;
        Group groups1 =  constants.tier1SupportQueue;
        Map<String, Set<String>> maps = constants.MAP_CONFIGURATION_MANAGER;
        Set<String> SET_INSTITUTION_INACTIVE_TYPE_STAT = constants.SET_INSTITUTION_INACTIVE_TYPE_STATUS;
        Set<String> SET_REGISTRATION_CANCELLED_STAT = constants.SET_REGISTRATION_CANCELLED_STATUS;
        Map<string, integer> MAP_WARM_LEAD_EVENTS  = constants.MAP_WARM_LEAD_EVENTS;
        Set<String> SET_OOO_AND_AUTOMATIC_REPLY = constants.SET_OOO_AND_AUTOMATIC_REPLY;
            
            
        //Stop Test here
        Test.stopTest();

    }
}