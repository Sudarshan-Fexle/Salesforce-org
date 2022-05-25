/**
*  Purpose      :   Class to periodically check whether run all tests has been completed 
					or not and accordingly, to do post steps and to create all the listings, once completed.
*  Created By   :   Abhinav Sharma
**/
global class Scheduler_SummarizeRunAllTestsResults implements Schedulable
{
    private String jobId;
    private String csvString = '';
    private Boolean errorOnly;
    private Boolean displayProgressOnUI;
    
    public Scheduler_SummarizeRunAllTestsResults(Id JobId, String csvString, Boolean errorOnly, Boolean displayProgressOnUI)
    {
        this.jobId = jobId;
        this.csvString = csvString;
        this.errorOnly = errorOnly;
        this.displayProgressOnUI = displayProgressOnUI;
    }
    
    global void execute(SchedulableContext ctx) 
    {
        List<ApexTestQueueItem> itemsList = ApexTestQueueItemQueryBuilder.returnRunTestsItemsForAJob(jobId);
        Integer count = 0;
        Integer total = itemsList.size();
        for(ApexTestQueueItem item : itemsList)
        {
            if(item.Status.toLowerCase() != Constants.STATUS_COMPLETED 
               && item.Status.toLowerCase() != Constants.STATUS_ABORTED 
               && item.Status.toLowerCase() != Constants.STATUS_FAILED
              )
            {
                if(displayProgressOnUI) 
                {
                    //Publish an event every time class got rescheduled to track next time progress
                    List<Run_All_Test_Results__e > runAllTestResults = new List<Run_All_Test_Results__e>();
                    runAllTestResults.add(new Run_All_Test_Results__e(Completed_Apex_Queue_Items__c = count, 
                                                                      Total_Apex_Queue_Items__c = total));
                    EventBus.publish(runAllTestResults);
                }
                
                DateTime sysTime = DateTime.now().addMinutes(Integer.valueOf(String.valueOf(System.Label.Recheck_Duration_Minutes)));
                String chron_exp = '' + sysTime.second() + Constants.CHAR_BLANK_SPACE 
                    + sysTime.minute() + Constants.CHAR_BLANK_SPACE 
                    + sysTime.hour() + Constants.CHAR_BLANK_SPACE 
                    + sysTime.day() + Constants.CHAR_BLANK_SPACE 
                    + sysTime.month() + Constants.CHAR_BLANK_SPACE + Constants.CHAR_QUESTION + Constants.CHAR_BLANK_SPACE + sysTime.year();
                Scheduler_SummarizeRunAllTestsResults job = new Scheduler_SummarizeRunAllTestsResults(jobId,csvString, errorOnly, displayProgressOnUI);
                System.schedule(System.Label.Run_All_Test_Job_Prefix  + Constants.CHAR_BLANK_SPACE + sysTime.getTime(),chron_exp, job); 
                break;
            }
            else
            {
                count++;
                
                if(count == itemsList.Size())
                {
                    if(displayProgressOnUI) 
                    {
                        //Publish event when run all tests completely performed
                        List<Run_All_Test_Results__e> completedTestClassResults = new List<Run_All_Test_Results__e>();
                        completedTestClassResults.add(new Run_All_Test_Results__e(Completed_Apex_Queue_Items__c = count, 
                                                                           Total_Apex_Queue_Items__c = total,
                                                                           Completed__c = true));
                        EventBus.publish(completedTestClassResults);
                    }    
                    
                    Integer is2Failures = 0;
                    String hold2Failures = '';
                    csvString += 'Class Name' + Constants.CHAR_COMMA + 'Method Name' + Constants.CHAR_COMMA 
                        + 'Error Message'+ Constants.CHAR_COMMA + 'Stack Trace' + Constants.CHAR_NEW_LINE;
                    List<ApexTestResult> testResult = ApexTestResultQueryBuilder.retrieveRunTestResultsForAJob(jobId);
                    Set<String> failuerClassNames = new Set<String>();
                    for(ApexTestResult result : testResult)
                    {
                        failuerClassNames.add(result.ApexClass.Name);
                        
                        //Record only errors details
                        if(errorOnly) 
                        {
                            if(result.Outcome.toLowerCase().contains(Constants.STATUS_FAIL))
                            {
                                csvString += result.ApexClass.Name + Constants.CHAR_COMMA
                                    + result.MethodName + Constants.CHAR_COMMA
                                    + CoreUtilities.replaceAllCommaWithBlankString(result.Message) + Constants.CHAR_COMMA 
                                    + CoreUtilities.replaceAllCommaWithBlankString(result.StackTrace) + Constants.CHAR_NEW_LINE;
                            }        
                        }
                        else 
                        {
                            csvString += result.ApexClass.Name + Constants.CHAR_COMMA 
                                + result.MethodName + Constants.CHAR_COMMA
                                + CoreUtilities.replaceAllCommaWithBlankString(result.Message) + Constants.CHAR_COMMA
                                + CoreUtilities.replaceAllCommaWithBlankString(result.StackTrace) + Constants.CHAR_NEW_LINE;
                        }
                    }
                    //Since now by this time, run all tests execution got completed 
                    //and we have results related details as well
                    //Therefore, make one another tooling API callout 
                    //to prepare an another sheet related to overall org coverage
                    //related details
                    if(String.isNotBlank(csvString)) 
                    {
                        RunAllTestsResultsWrapper sEW = new RunAllTestsResultsWrapper(csvString, jobId);
                        System.enqueueJob(new ProcessOverallOrgDetailsJob(sEW));                        
                    } 
                }
            }
        }
    }
}