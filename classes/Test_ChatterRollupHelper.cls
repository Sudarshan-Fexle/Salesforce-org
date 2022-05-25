/**
* Purpose		: Test class for ChatterRollupHelper
*
* Created By		: Colin McGloin
*
* Created Date		: 02/19/2021
*
* Revision Log		: V_1.0 - Created - Colin McGloin - CR-20210217-14927
*			: V_1.1 - Modified By - Neha Sharma - CR-20210326-15037 - 3/4/2021 - Added new method to handle the Contentpost use case 
*
* Coverage		: V_1.0 - 86%
*
* Notes			: Unfortunately we have to use "SeeAllData=True" due to a quirk with testing ConnectApi (Chatter) methods
*			  Also currently unable to insert a Custom Metadata Record for purposes of test so we need to test with an existing Record. Need to refactor this once we have the ability to create a record in Code.
*
**/

@isTest(seeAllData = true)
public with sharing class Test_ChatterRollupHelper {

    static testmethod void Test_processRollups() {

        //Start our Test
        Test.startTest();
        
        //Create a PSA Project record
        pse__Proj__c psaProject = new pse__Proj__c();
        psaProject.name = 'The Voldemort Project';
        insert psaProject;
        
        //Insert the Project Task
        pse__Project_Task__c projectTask = new pse__Project_Task__c();
        projectTask.pse__Project__c = psaProject.Id;
        insert projectTask;

        //Create our FeedItem record and insert
        FeedItem testRecord = new FeedItem();
        testRecord.type = 'TextPost';
        testRecord.body = 'He who shall not be Named is back';
        testRecord.isRichText = true;
        testRecord.ParentId = projectTask.Id;
        insert testRecord;
    
        //Stop our Test
        Test.stopTest();

        //Get our Account Record
        pse__Proj__c theGreatestWizardWhoEverLived = [SELECT Id, Name FROM pse__Proj__c WHERE Name = 'The Voldemort Project'];
        Id projectId = theGreatestWizardWhoEverLived.Id;

        //Query for our FeedItem
        FeedItem duplicateChatterPost = [SELECT Id, Body, ParentId FROM FeedItem WHERE ParentId = :projectId];
        
        //Strip out our Additional Post info
        String testString = duplicateChatterPost.Body.subStringBefore('<');

        //Run our Checks
        System.assertEquals('He who shall not be Named is back',testString);

    }
    
    //Added new method to handle the Contentpost use case - Added By - Neha Sharma - CR-20210326-15037 - 3/4/2021
    static testmethod void Test_processRollupsforContentPost() {

        //Start our Test
        Test.startTest();
        
        //Create a PSA Project record
        pse__Proj__c psaProject = new pse__Proj__c();
        psaProject.name = 'The Voldemort Project';
        insert psaProject;
        
        //Insert the Project Task
        pse__Project_Task__c projectTask = new pse__Project_Task__c();
        projectTask.pse__Project__c = psaProject.Id;
        insert projectTask;

        ContentVersion  cv = new ContentVersion ();
       	cv.Title = 'Penguins';
      	cv.PathOnClient = 'Penguins.jpg';
      	cv.VersionData = Blob.valueOf('Test Content');
      	cv.IsMajorVersion = true;           
        insert cv;
        
        //Create our FeedItem record and insert
        FeedItem testRecord = new FeedItem();
        testRecord.type = 'ContentPost';
        testRecord.body = 'Testing Data';
        testRecord.isRichText = true;
        testRecord.RelatedRecordId = cv.id;
        testRecord.ParentId = projectTask.Id;
        insert testRecord;
    
        //Stop our Test
        Test.stopTest();

        //Get our Account Record
        pse__Proj__c theGreatestWizardWhoEverLived = [SELECT Id, Name FROM pse__Proj__c WHERE Name = 'The Voldemort Project'];
        Id projectId = theGreatestWizardWhoEverLived.Id;

        //Query for our FeedItem
        FeedItem duplicateChatterPost = [SELECT Id, Body, ParentId FROM FeedItem WHERE ParentId = :projectId];
        
        //Strip out our Additional Post info
        String testString = duplicateChatterPost.Body.subStringBefore('<');

        System.assertNotEquals(null, duplicateChatterPost);
        //Run our Checks
        System.assertEquals('Testing Data',testString);

    }
}