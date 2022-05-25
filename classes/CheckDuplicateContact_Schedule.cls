/**
*  Description     :  This class is for checking duplicate contacts using Schedule process.
*
*  Created By      :  Sudarshan singh
*
*  Created Date    :  03/25/2022
*
*  Revision Logs   :  V1.0 - Created - Sudarshan Singh 
*
**/
public without sharing class CheckDuplicateContact_Schedule implements Schedulable {
    
    public void execute(SchedulableContext sContext) {
        
        CheckDuplicateContact_Batch checkDuplicateContact = new CheckDuplicateContact_Batch();
        Id batchId = DataBase.executeBatch(checkDuplicateContact, 100);
    }
}