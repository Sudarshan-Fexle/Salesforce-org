public class SurveyController {
	
    public Event survey { get; set ;}
    public boolean completed { get; set; }
    
    public SurveyController() {
        
        //create the survey record
        survey = new Event (
        	RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('eTech Dev').getRecordTypeId(),
            Event_Type__c = 'Survey',
            //Title__c = 'Survey',
            ActivityDateTime = dateTime.now(),
            DurationInMinutes=1
        );
        
        //get the contact id from the url param
        String contactId = Apexpages.currentPage().getParameters().get('CID');
        if (contactId != null) survey.WhoId = contactId;
        
        //set completed variable to false
        completed = false;
    }
    
    public PageReference save() {
        
        try {
            insert survey;
        }
        catch(Exception e) {
            //Return errors to the VF Page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
        
        //Return success message to vf page
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Thanks for you feedback.'));
        completed = true;
        return null;
    }
    
    public List<SelectOption> surveyOptions {
        get {
            if (surveyOptions == null) {
                surveyOptions = new List<selectOption>();
                surveyOptions.add(new selectOption('Slow', 'Slow'));
                surveyOptions.add(new selectOption('Missing feature', 'Missing feature'));
                surveyOptions.add(new selectOption('Other', 'Other'));
            }
            
            return surveyOptions;
        }
        set;
    }
}