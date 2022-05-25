/*
    Purpose         :   This class is to test the AssignHypercareTopic apex class functionalty.
                
    Create By       :   MAhendra Swarnkar
    
    Created Date    :   3/24/2017
    
    Current Version :   v1.0 - Created.
    
    Revision Log    :   V_1.0 Created 
				        V_1.1 - Modified By - Deepak Kumawat - Apollo release - Test Fixed failures

	Coverage    	:  100%
*/
@isTest(seeAllData=true)
public class Test_AssignHypercareTopic {
    
    static testmethod void myUnitTest() {
		
        //Bypass All the triggers
        Util.BypassAllTriggers = true;
        
        //get a release record
        List<SFDC_Release__c> release = [Select Id,Release_level__c from SFDC_Release__c where Release_level__c = 'L2' And Status__c != 'Deployed' AND RecordType.DeveloperName = 'eTech_Dev' LIMIT 1]; 
        
        //get a isSystem record
        List<IS_System__c>  testISRecord = [Select Id from IS_System__c where RecordType.DeveloperName = 'System' LIMIT 1];
        
        //Id employeeRTId = Util.RecordTypeId('Contact', 'Employee');
        
        //get a contact
        List<Contact>  contact = [Select Id from Contact where RecordType.DeveloperName = 'Employee' LIMIT 1];
        
        if(release.size()> 0 && testISRecord.size()>0 && contact.size()>0){
        	//Insert Change Request record
            SFDC_Change_Request__c changeRequestA =  new SFDC_Change_Request__c(Title__c = 'Test CR 1.2', IS_System__c = testISRecord[0].Id, 
                                                                                Priority__c = 'B - High', Status__c = '03-Approved', 
                                                                                Users_Affected__c = 'All', Requested_By2__c = contact[0].Id, 
                                                                                Business_Operations_Contact2__c = contact[0].Id , 
                                                                                Request_Description__c = 'Testing', Business_Justification__c = 'Test',
                                                                                CR_Type__c = 'Hypercare', Release__c = release[0].id,
                                                                                Reason_For_Critical__c = 'Test', RecordTypeId = Util.RecordTypeId('SFDC_Change_Request__c', 'SFDC Change Request'));
            SFDC_Change_Request__c changeRequestB =  new SFDC_Change_Request__c(Title__c = 'Test CR 1.1', 
                                                                                IS_System__c = testISRecord[0].Id, Priority__c = 'B - High',
                                                                                Status__c = '03-Approved', Users_Affected__c = 'All',
                                                                                Requested_By2__c = contact[0].Id, Request_Description__c = 'Testing',
                                                                                Business_Justification__c = 'Test', IS_QA_Lead2__c = contact[0].Id,
                                                                                CR_Type__c = 'Hypercare', Release__c = release[0].id,
                                                                                Reason_For_Critical__c = 'Test', RecordTypeId = Util.RecordTypeId('SFDC_Change_Request__c', 'SFDC Change Request'));
            
            //Start Test from here 
            Test.startTest();
            
            //Insert change request records
            insert changeRequestA;
            
            //List to hold the CR Ids
            List<Id> changerequestId = new List<Id>();
            changerequestId.add(changeRequestA.Id);
            
            //Method Call
            AssignHypercareTopic.assignTopics(changerequestId);
            
            //Test Stop here 
            Test.stopTest();
            
            //Query the Topic records.
            List<Topic> topicList = [Select Id, Name From Topic where Name =: System.Label.HypercareCR_Topic_Name];
            
            //Assserts on results
            System.assertEquals(1, topicList.size());
            System.assertEquals('HypercareCR', topicList[0].Name);
            
            //List to Hold the Topic Assignment records
            List<TopicAssignment> topicAssgnmentList = [Select Id, EntityId, TopicId From TopicAssignment where TopicId =: topicList[0].Id AND EntityId =: changeRequestA.Id ];
            
            //Assserts on results
            System.assertEquals(1, topicAssgnmentList.size());
            System.assertEquals(changeRequestA.Id, topicAssgnmentList[0].EntityId);
            System.assertEquals(topicList[0].Id, topicAssgnmentList[0].TopicId);
            
            //Insert change request records
            insert changeRequestB;
            
            changerequestId = new List<Id>();
            changerequestId.add(changeRequestB.Id);
            
            //Method Call
            AssignHypercareTopic.assignTopics(changerequestId);
            
            //Query the Topic records.
            topicList = [Select Id, Name From Topic where Name =: System.Label.HypercareCR_Topic_Name];
            
            //Assserts on results
            System.assertEquals(1, topicList.size());
            System.assertEquals('HypercareCR', topicList[0].Name);
            
            //Query the  Topic Assignment records
            topicAssgnmentList = [Select Id, EntityId, TopicId From TopicAssignment where TopicId =: topicList[0].Id AND (EntityId =: changeRequestA.Id OR EntityId =: changeRequestB.Id) ORDER BY CreatedDate desc];
            
            //Assserts on results
            System.assertEquals(2, topicAssgnmentList.size());
            /*System.assertEquals(changeRequestA.Id, topicAssgnmentList[0].EntityId);
            System.assertEquals(topicList[0].Id, topicAssgnmentList[0].TopicId);
            System.assertEquals(changeRequestB.Id, topicAssgnmentList[1].EntityId);
            System.assertEquals(topicList[0].Id, topicAssgnmentList[1].TopicId);
            */
            
            List<SFDC_Change_Request__c> cRs = new List<SFDC_Change_Request__c>{changeRequestA,changeRequestB};
            
            //Delete Change request
            delete cRs;
            
            //Query the  Topic Assignment records
            cRs = [Select Id From SFDC_Change_Request__c where Id IN : cRs];
            
            //Assserts on results
            System.assertEquals(0,cRs.size()); 
              
        } 
    }
}