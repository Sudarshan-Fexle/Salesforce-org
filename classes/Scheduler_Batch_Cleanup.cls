/**
 *	Description		:	The scheduler is used to schedule Batch_Cleanup to delete the records for the particular object which are mentioned in the Cleanup meta data.
 *					1 - Here is a one method to create a query string using object name and where clauses and limits
 *
 *	Created by		:	Saurabh Kumar
 * 
 * 	Created Date		:	08/17/2017 
 * 
 * 	Revision Log		:	V1.0 Created - CR-20170803-11119
 *				:       V1.1 Modified By - Nikita Kumari - CR-20211005-15489
**/
global class Scheduler_Batch_Cleanup implements Schedulable{
	
    /**
     * 	Description	:	Execute method to initiate batch.
     * 
     * 	@args		:	SchedulableContext
     * 
     * 	@return		:	Void
     * 
     *  @revision	:	V1.0 Created
     * 
     * */
    global void execute(SchedulableContext sc){
        
        //Query on the Cleanup custom meta data
        List<Clean_Up__mdt> cleanups = new List<Clean_Up__mdt>();
        
        // Added By - Chirag Soni - CR-20211005-15489 - 11/18/2021 - added Test.isRunningTest condition
        if(Test.isRunningTest()){
            cleanups =  [Select Id, Additional_Filter_Clause__c, Object_Name__c, Order__c, Retain_N_days_Records__c, Limit_Of_Records__c From 
                         Clean_Up__mdt Where Object_Name__c != null AND Object_Name__c = 'Web_Service_Log__c' AND Active__c = true ORDER BY Order__c ASC LIMIT 1];
        }else{
            
            cleanups = [Select Id, Additional_Filter_Clause__c, Object_Name__c, Order__c, Retain_N_days_Records__c, Limit_Of_Records__c From 
                        Clean_Up__mdt Where Order__c != null AND Object_Name__c != null AND Active__c = true ORDER BY Order__c ASC LIMIT 1];
        }
            
        
        //Checking for the list size
        if(cleanups != null && cleanups.size() > 0){
            
            //Calling method to get dynamic query for order 1
            String query = Scheduler_Batch_Cleanup.getQuery(cleanups[0]);
            
            //Checking for the string value
            if(String.isNotBlank(query)){
                
                //Initiating the batch to process the records
                Batch_Cleanup cleanup = new Batch_Cleanup(query);
                
                //Set the Order the execution so that in next execution order should be greater than current
                cleanup.executionOrder = cleanups[0].Order__c;
                
                //Execute the batch
                Database.executeBatch(cleanup, 2000);
            }
        }
    }
    
    /**
     * 	Description	:	1 - Method is used to query on the meta data and get object details according to the order.
     * 					2 - Create dynamic query and get the records according to metadata queried object and conditions.
     * 
     * 	@args		:	Integer executionOrder
     * 
     * 	@return		:	String
     * 
     *  @revision	:	V1.0 Created
     * 
     * */
    public static String getQuery(Clean_Up__mdt cleanup){
        
        //Varibale to hold dynamic query Limit_Of_Records__c
        String query = '';
        
        //Checking for the list size
        if(cleanup != null){
            
            //Creating query with clauses
            query = 'Select Id From '+cleanup.Object_Name__c;
            
            //Checking if last N days is mentioned
            if(cleanup.Retain_N_days_Records__c != null)
                query += ' Where CreatedDate < LAST_N_DAYS:'+Integer.valueOf(cleanup.Retain_N_days_Records__c);
            
            //Checking for Additional clause
            if(cleanup.Additional_Filter_Clause__c != null){
                
                if(!query.contains('Where'))
                    query += ' Where ('+cleanup.Additional_Filter_Clause__c +' )';
                else
                    query += ' AND ( '+cleanup.Additional_Filter_Clause__c +' )';
            }
            
            //Checking if limit is mentioned in the meta data record
            if(cleanup.Limit_Of_Records__c != null)
                query += ' LIMIT '+Integer.valueOf(cleanup.Limit_Of_Records__c);
        }
        return query;
    }
}