public class CheckCaseFieldPopulatedToCreateCRClass {
	
    //Variable to hold the boolena flag    
    public boolean isError{get; set;}
    public String caseId;
    
    //Constructor
  	public CheckCaseFieldPopulatedToCreateCRClass() {
        isError = false;
    }   
    
    public String redirect() {
    	
        //String to hold the case Number
        caseId = '';
        isError = false;
    	/*/a0U/e?retURL=%2Fa0U%2Fo 
        &CF00NC0000005TsUU={!Case.IS_System__c} 
        &00NC00000057B5y={!Case.Users_Affected__c} 
        &00NC00000057B5m={!Case.Requested_Completion_Date__c} 
        &00NC00000057B5g={!Case.Priority} 
        &00NC00000057B5w={!Case.Change_Request_Title__c} 
        &CF00NC0000005U88L={!Case.Contact} 
        &00N3D000001ouhQ={!Case.Steps_to_Reproduce_MS__c} 
        &00N3D000001qn8R={!Case.Summary__c} 
        &00N3D000001qVCP={!Case.Change_Request_Level__c} 
        &00N3D000001zxh4={!Case.CaseNumber} 
        &RecordType=012C0000000Bmdh 
        &ent=01IC0000000lkSP*/
        
        //Check the case Number
        if(apexpages.currentpage().getparameters().get('Id') != null)
        	caseId = apexpages.currentpage().getparameters().get('Id');
        
        //Query on the case to get the fields populated or not
        List<Case> cse = [Select Id, IS_System__c, IS_System__r.Name, Users_Affected__c, Requested_Completion_Date__c, 
                          	Priority, Change_Request_Title__c, ContactId, Contact.Name, Steps_to_Reproduce_MS__c, 
                         	Summary__c, Change_Request_Level__c, CaseNumber FROM Case Where Id =: caseId ];
        
        //Check the size of case list
        if(cse.size() > 0) {
            
            //Check if the Field of CR is blank 
            if(String.isBlank(cse[0].Change_Request_Title__c) || String.isBlank(cse[0].Change_Request_Level__c) || String.isBlank(cse[0].Summary__c)) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'The fields Change Request Level, Change Request Title, and Summary must be populated on the Case before creating a new Change Request.'));
                isError = true;
                
                return null;
            }else {
                
                String newCRURL = '/a0U/e?retURL=%2Fa0U%2Fo&CF'
                    +Label.CR_IS_System_c+'='+cse[0].IS_System__r.Name+'&'+Label.CR_IS_System_c+'_lkid='+cse[0].IS_System__c
                    +'&'+Label.CR_Users_Affected_c+'='+cse[0].Users_Affected__c
                    +'&'+Label.CR_Requested_Completion_Date_c+'='+cse[0].Requested_Completion_Date__c
                    +'&'+Label.CR_Priority_c+'='+cse[0].Priority
                    +'&'+Label.CR_Title_c+'='+cse[0].Change_Request_Title__c
                    +'&CF'+Label.CR_Requested_By2_c+'='+cse[0].Contact.Name+'&'+Label.CR_Requested_By2_c+'_lkid='+cse[0].ContactId
                    +'&'+Label.CR_Case_Steps_To_Reproduce_c+'='+cse[0].Steps_to_Reproduce_MS__c
                    +'&'+Label.CR_What_Is_The_Business_Need_c+'='+cse[0].Summary__c
                    +'&'+Label.CR_Change_Request_Level_c+'='+cse[0].Change_Request_Level__c
                    +'&'+Label.CR_Related_Case_Number_c+'='+cse[0].CaseNumber
                    +'&RecordType=012C0000000Bmdh&ent=01IC0000000lkSP';
                    
                return newCRURL;
            }
        }
        return null;
    }
    
    public String goBack() {
        
        return '/'+caseId;
    }
}