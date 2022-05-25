/*
    Purpose         :   This class is to assign a Topic i.e. HypercareCR to Change request record.
                
    Create By       :   MAhendra Swarnkar
    
    Created Date    :   3/24/2017
    
    Current Version :   v1.0 - Created.
    
    Revision Log    :   V_1.0 Created 
*/
public class AssignHypercareTopic {

    /**
     * @description : This method is to assign HypercareCR Topic to Chage request record 
     * 
     * @param 		: List of change requests Ids
     * 
     * @return 		: void
     */
    @InvocableMethod
    public static void assignTopics(List<Id> listRecordIds  ) {
     
        //String variable to hold topic name
        String topicHypercareCR = System.Label.HypercareCR_Topic_Name;
        
        //variabe to hold the topic Id
        Id topicsId;
        
        //List to hold the Topics 
        List<Topic> listTopics = [Select Id, Name from Topic where Name =: topicHypercareCR limit 1];
        
        //Check for size and populate the topicsId
        if(listTopics != null && listTopics.size() > 0) { 
            topicsId = listTopics[0].Id;
        }
        else
        {
            //create a new instance of "hypercareCR" TOpic if not already existed
            Topic tp = new Topic(Name = topicHypercareCR);
            insert tp;
            topicsId = tp.Id; 
        }
        
        //List to hold the topic Assignment records 
        List<TopicAssignment> listTopicAssignmentToInsert = new List<TopicAssignment>();
        
        //Check for size
        if(topicsId != null && listRecordIds != null && listRecordIds.size() > 0)
        {
            //Loop over the record ids
            for(Id recordId: listRecordIds)
            {
                //Check for size
                if(recordId != null 
                   	&& recordId.getSobjectType() == Schema.SFDC_Change_Request__c.SObjectType )
            		
                    //popuate the list of topic Assignment  to be inserted
                    listTopicAssignmentToInsert.add(new TopicAssignment(EntityId = recordId, TopicId = topicsId));
            }
            
            //Check for Size
            if(listTopicAssignmentToInsert.size() > 0)
                
                //Insert the Topic Assignments
                insert listTopicAssignmentToInsert;
        }
    }
}