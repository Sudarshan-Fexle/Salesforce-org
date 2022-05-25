/**
*  Description     :   Send the doc file on email as attachment. 
*
*  Created By      :   Dipesh Gupta  
* 
*  Created Date    :   05/10/2020
* 
*  Revision Logs   :   V_1.0 - Created - CR-20190702-13205
**/
public class SendTripReportOnEmailController {
  
  public  Boolean isEmailReport{get;set;}
  public  String eventId;
  public  String errorMessage {get;set;}
 
    
 public SendTripReportOnEmailController(){
      isEmailReport = false;
      errorMessage = '';
     eventId = ApexPages.currentPage().getParameters().get('Id');
     
  }
    
 
  public void getsendEmail(){
     
   Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      
     List<Event> eventList = [Select Id,whoId,What.Name,What.Type,StartDateTime From Event where Id =: eventId Limit 1];
    
     if(eventList.size() > 0 && eventList[0].What.Type == 'opportunity'){
         
     Id userId = UserInfo.getUserId();
     List<String> emailAddresses = new List<String>();
     Blob blobData;
     
         for(user usr : [Select Id,Name,Email From User where id =: userId LIMIT 1]){
             if(String.isNotBlank(usr.Email))
             	emailAddresses.add(usr.Email);
         }

   // Reference the attachment page, pass in the event ID
        PageReference pdf = Page.TripPrepReport;
        pdf.getParameters().put('Id',(String)eventList[0].Id);
        pdf.setRedirect(true);
        
        // Take the doc content
         if(!Test.isRunningTest()){
        	 blobData = pdf.getContent();
         }
         else{
              blobData = Blob.valueOf('Test');
         }
        
        // Create the email attachment
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(eventList[0].What.Name+'.doc');
        efa.setBody(blobData);
      
        // Sets the paramaters of the email
        email.setSubject('Trip Prep Report');
        email.setToAddresses(emailAddresses);
        email.setPlainTextBody('Report has attached below:-');
 
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
         
      try{     
           system.debug('email--'+email);
          
          if(emailAddresses.size() > 0){
            // Sends the email
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            errorMessage = 'Email has been send on current user mail Id.Please click the button below to go back.';
            isEmailReport = true;
          }
          else{
               errorMessage = 'Please add the email Id for current user.Click the button below to go back.';
               isEmailReport = false;
          }
            
         }
          catch(Exception ex){
               isEmailReport = false;
               errorMessage = ex.getMessage();
              
          }
      }
      else{
           system.debug('email error--');
           errorMessage = 'Event having opportunity can only Email Report, click the button below to go back.';
           isEmailReport = false;
        
      }
     
    

    }
    
}