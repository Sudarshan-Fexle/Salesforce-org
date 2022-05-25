/*
    Purpose         :   This class is to assign a Topic i.e. CriticalCR to Change request record.
                
    Create By       :   MAhendra Swarnkar
    
    Created Date    :   3/24/2017
    
    Current Version :   v1.0 - Created.
    
    Revision Log    :   V_1.0 Created 
*/
public class AssignCriticalCRTopic {
	
    /**
     * @description : This method is to assign CriticalCR Topic to Chage request record 
     * 
     * @param 		: List of change requests Ids
     * 
     * @return 		: void
     */
    @InvocableMethod
    public static void assignCriticalCRTopics(List<Id> listRecordIdsCritical  ) {
     	
        //String variable to hold topic name
        String topicCriticalCR = System.Label.CriticalCR_Topic_Name;
        
        //variabe to hold the topic Id
        Id topicsId;
        
        //List to hold the Topics 
        List<Topic> listTopicToBeinserted = [Select Id, Name from Topic where Name =: topicCriticalCR limit 1];
        
        //Check for size and populate the topicsId
        if(listTopicToBeinserted != null && listTopicToBeinserted.size() > 0) { 
            topicsId = listTopicToBeinserted[0].Id;
        }
        else
        {
            //create a new instance of "topicCriticalCR" TOpic if not already existed
            Topic tp = new Topic(Name = topicCriticalCR);
            insert tp;
            topicsId = tp.Id; 
        }
        
        //List to hold the topic Assignment records
        List<TopicAssignment> listTopicAssignmentToInsert = new List<TopicAssignment>();
        
        //Check for size
        if(topicsId != null && listRecordIdsCritical != null && listRecordIdsCritical.size() > 0)
        {
            //Loop over the record ids
            for(Id recordId: listRecordIdsCritical)
            {
                //Check for size
                if(recordId != null 
                   	&& recordId.getSobjectType() == Schema.SFDC_Change_Request__c.SObjectType )
            		
                    //popuate the list of topic Assignment to be inserted
                    listTopicAssignmentToInsert.add(new TopicAssignment(EntityId = recordId, TopicId = topicsId));
            }
            
            //Check for Size
            if(listTopicAssignmentToInsert.size() > 0)
                
                //Insert the Topic Assignments
                insert listTopicAssignmentToInsert;
        }
    }
}