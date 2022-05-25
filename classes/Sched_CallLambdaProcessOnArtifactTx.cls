/**
 *   Description     :   	Schedules the lambda web services for Artifact Tx records
 *
 *   Revision Log    :   	V1.0 - 08/16/2020 - CR-20200803-14397 - Victor Hanson - created
 * 
*/
global class Sched_CallLambdaProcessOnArtifactTx implements Schedulable {
    
    public List<Id> ListOfArtifactTxIds = new List<Id>();
    
    global Sched_CallLambdaProcessOnArtifactTx() { }
    
    global void execute(SchedulableContext SC) {
        System.enqueueJob(new Enqueue_CallLambdaProcessOnArtifactTx(ListOfArtifactTxIds));
    }
}