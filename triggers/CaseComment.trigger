/**    Purpose:        Helper class for the CaseComment trigger.(CR-4283)
                
    Create By:      Victor Hanson
    
    Created Date:   06/02/2014
    
    Current Version : V1.1
    
    Revision Log:   V1.0 - VH - 06/02/2014 - Created
                    V1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
                    V1.2 - Modified By - Mahendra Swarnkar - 7/4/2016 -  CR-20160603-9890 - Added populateMostRecentPublicCaseComment method
                    V1.3 - Modified By - Abhinav Sharma - 09/05/2016 - CR-20160114-9520
                    V1.4 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  to add bypass logic to trigger.
                    V1.5 - Modified By - Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT_SUPPORT_REQUEST
                    V1.6 - Modified By - Ayush Gupta - 08/18/2021 - CR-20210817-15360

**/
trigger CaseComment on CaseComment (after insert, after update, after delete) {

    //return immediately if method returns true
    if(Util.areTriggersOnThisObjectBypassed('CaseComment')) return;		

    try {
      
      //By Pass trigger check
      if (Util.BypassAllTriggers) return;
      
      //Check evevt type
      if (trigger.isAfter) {
                        
            //Added by Ayush Gupta - 08/18/2021 - CR-20210817-15360
            if(Trigger.isInsert){
               CaseCommentTriggerHelper.populateLatestSupportRepComment(trigger.new); 
        }
            
        //Check request type
        if(Trigger.isInsert || Trigger.isUpdate){
            
              //update the case comment notify flag on the case CR-4283
              CaseCommentTriggerHelper.populateCaseCommentNotify(trigger.new, trigger.oldMap);
        }
        
        //Added by Mahendra Swarnkar 7/4/2016 - CR-20160603-9890  
        if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
                  
              //Calling helper class method to populate Most Recent CaseComment on member support
              CaseCommentTriggerHelper.populateMostRecentPublicCaseComment(Trigger.New, Trigger.oldMap);        
      	}
    }
    
    //Catching DML Exceptions
    } catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));

    //Catching all Exceptions
    } catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}