/**
 *  Description     :  Trigger helper class to handle the DML cases on the Email Message Object.
 * 
 *  Created By      :  Abhinav sharma
 * 
 *  Created Date    :   05/08/2018
 * 
 *  Revision Logs   :   V_1.0 - Created -  CR-20180502-12201 - 05/08/2018
 *                      
 **/ 
public class EmailMessageTriggerHelper {
	
    /**
     *  Description     :  Method to manipulate the before insert Message & populate the Html Body of Email message[AsK eab Record Type]
     * 
     *  Created By      :  Abhinav sharma
     * 
     *  Created Date    :   05/07/2018
     * 
     *  Revision Logs   :   V_1.0 - Created
     *                      
 	**/ 
	public static void askEABCaseHtmlBodyPopulation(List<EmailMessage> newEmailMessages) {
		        
        //Set to hold the New Ids 
        Set<Id> setCaseIds = new Set<Id>(); 
        
        //String to hold the ASK EAB Record Type Name 
        String ASK_EAB_RTYPE = 'EAB_Custom';
        String NOTES_AND_RESEARCH_ASSOCIATE = 'Notes from Research Associate:';
                
        //Loop through the List
        for(EmailMessage eMessage : newEmailMessages) {
        	            
        	//Check if the Parent is not blank and related with the case 
			if(String.isNotBlank(eMessage.ParentId))
            	setCaseIds.add(eMessage.ParentId);
        } 
                
        //Check for the Email message Parent Case.
        if(setCaseIds.size() > 0) {
            
            //Query on the Case to get the Related Info
            Map<Id, Case> mapCaseIds = new Map<Id, Case> ([Select Id, RecordType.DeveloperName From Case Where Id IN : setCaseIds AND RecordType.DeveloperName =: ASK_EAB_RTYPE]);
            
            if(mapCaseIds.size() > 0) {  
            	
                //Loop on the List of Email Message
                for(EmailMessage eMessage : newEmailMessages) {
				
                    //Check for the Record Type is ask Eab and Html Body contains Value.
        			if(eMessage.HtmlBody != null && eMessage.ParentId != null && mapCaseIds.containsKey(eMessage.ParentId) 
                       && mapCaseIds.get(eMessage.ParentId).RecordType.DeveloperName == ASK_EAB_RTYPE)  {
                           
                       //Check for the html body.
                       if(eMessage.HtmlBody.contains(NOTES_AND_RESEARCH_ASSOCIATE))
                           eMessage.Notes_From_Research_Associate__c = eMessage.HtmlBody.split(NOTES_AND_RESEARCH_ASSOCIATE)[1];
                       
                      //Check for the string ([ ref:) to move it from the String.
                      if(String.isNotBlank(eMessage.Notes_From_Research_Associate__c) && eMessage.Notes_From_Research_Associate__c.contains('ref:'))
                          eMessage.Notes_From_Research_Associate__c = eMessage.Notes_From_Research_Associate__c.split('ref:')[0].replace('[', '');
                    }           
                }
            }   
        }
    }
}