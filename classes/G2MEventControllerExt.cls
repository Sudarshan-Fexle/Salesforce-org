//Modified By Dipesh Gupta - on 08/05/2019 - CR-20190522-13122- removed references of 'Gotomeeting_Organizer__c' field
public class G2MEventControllerExt {
    public static final String ErrorEmail = 'sunj@advisory.com';
    
    public User Organizer { get; set; }
    public String NextAction { get; set; }
   
    private final Event event;
    private final ApexPages.StandardController stdController;
    
    public static String GetEventHash(Event e) {
        
        return  ' (' + e.StartDateTime.Format('yyyy/M/d h:mm a') + ' - ' + e.EndDateTime.Format('yyyy/M/d h:mm a') + ' EST)';
    	
    }
    private Id GetEventOrganizerId(Event e) {
        //Modified By Dipesh Gupta - CR-20190522-13122- removing references of 'Gotomeeting_Organizer__c' field
        // ID organizerId = e.Gotomeeting_Organizer__c == 'Assigned To'? e.OwnerId : e.CreatedById;
        //return organizerId == null? UserInfo.getUserId() : organizerId;
        return UserInfo.getUserId();
        
    }
    private User GetEventOrganizer(Event e) {
        return [select Id, Email, GotomeetingPassword__c from User where id = :GetEventOrganizerId(e)];
    }
    private User GetEventOrganizer(Map<ID,User> users, Event e) {
        return users.get(GetEventOrganizerId(e));
    }
    
    // The extension constructor initializes the private member variable by using the getRecord method from the standard controller.
    public G2MEventControllerExt(ApexPages.StandardController controller) {
        stdController = controller;
        event = (Event) stdController.getRecord();
        Organizer = GetEventOrganizer(event);
    }
    
    public PageReference load() {
      /*  if(event.Gotomeeting__c) {
            if(event.Gotomeeting_Id__c == null) {
                NextAction = '<h3>The event is marked for Gotomeeting, however there is no associated Gotomeeting yet.</h3><p>Please click "Go" to create a Gotomeeting for the current event.</p>';
            } else {
                String hash = GetEventHash(event);
                if(event.Gotomeeting_Organizer_Saved_Id__c != Organizer.Id) {
                    NextAction = '<h3>The organizer for the underline Gotomeeting is changed.</h3><p>Please click "Go" to re-create Gotomeeting with a different organizer.</p>';
                } else if(hash != event.Gotomeeting_Hash__c) {
                    NextAction = '<h3>This event is changed since the Gotomeeting is created.</h3><p>Please click "Go" to update Gotomeeting for the current event.</p>';
                }
            }
        }
        else {
            if(event.Gotomeeting_Id__c != null) {
                NextAction = '<h3>This event is no longer marked for Gotomeeting.</h3><p>Please click "Go" to delete existing Gotomeeting for the current event.</p>';
            }
        }
        
        if(NextAction == null)
            NextAction = 'No gotomeeting action is needed.';*/
            
        return null;
    }
    
    public boolean hasG2MLogin
    {
        get
        {
            return Organizer != null && Organizer.Email != null && Organizer.Email != ''
                && Organizer.GotomeetingPassword__c != null && Organizer.GotomeetingPassword__c != '';
        }
    }

    public PageReference synchG2M()
    {
        if(!hasG2MLogin)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The organizer has not setup his Gotomeeting access yet.'));
            return null;
        }
            
        try
        {
            G2MClient client = new G2MClient(Organizer.Email, Organizer.GotomeetingPassword__c);
            
            if(client.logon()) {
               /* if(event.Gotomeeting__c) {
                    if(event.Gotomeeting_Id__c == null) {
                        String result = client.createMeeting(event);
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, result));
                    } else {
                        String hash = GetEventHash(event);
                        if(event.Gotomeeting_Organizer_Saved_Id__c != Organizer.Id ) {
                            if(ClearG2M(event)) {
                                String result = client.createMeeting(this.event);             
                                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, result));
                            } else {
                                client.logoff();
                                return null;
                            }
                        } else if(hash != event.Gotomeeting_Hash__c) {
                            String result = client.updateMeeting(event);
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, result));
                        }
                    }
                }
                else {
                    if(event.Gotomeeting_Id__c != null) {
                        String result = client.deleteMeeting(event);
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, result));
                    }
                }  */          
    
                client.logoff();
                update event;
                
                //return null;
                return stdController.view();
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Failed to log on to Gotomeeting using the organizer account.'));
                
                return null;
            }     
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
            return null;
        }
    }
    
    private boolean ClearG2M(Event event)
    {
    /*    try
        {
            User oldOrganizer;
            if(event.Gotomeeting_Organizer_Saved_Id__c != null) {
                oldOrganizer = [select Id, Email, GotomeetingPassword__c from User where id = :event.Gotomeeting_Organizer_Saved_Id__c];

                G2MClient client = new G2MClient(oldOrganizer.Email, oldOrganizer.GotomeetingPassword__c);
                
                if(client.logon()) {
                    String result = client.deleteMeeting(event);    
                    client.logoff();
                    update event;
                    
                    return true;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Failed to log on to Gotomeeting using the previous organizer account.'));
                }
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Failed to retrieve the previous organizer account.'));
                return false;
            }  
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
        */
        return false; 
    }
  
    public PageReference cancel()
    {
        return stdController.view();
    }
}