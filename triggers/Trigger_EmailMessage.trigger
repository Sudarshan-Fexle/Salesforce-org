/**
 *  Description     :  Trigger on the Email Message Object.
 * 
 *  Created By      :  Abhinav sharma
 * 
 *  Created Date    :   05/08/2018
 * 
 *  Revision Logs   :   V_1.0 - Created -  CR-20180502-12201 - 05/08/2018
 *                      
 **/ 
trigger Trigger_EmailMessage on EmailMessage (before insert) {
    
    //Check for the Before Insert Case
    if(Trigger.isBefore) {
        
        //Check for the Insert Case
        if(Trigger.isInsert) {
        	
            //Call Helper Class Method 
            EmailMessageTriggerHelper.askEABCaseHtmlBodyPopulation(Trigger.New);
        }
     }
}