/*
  Purpose:       CR-2618 - Allow users to upload a list of adv.com users that want to be subscribed
                 to a specific Subscription Option.
  
  Created By:    Victor Hanson
  
  Created Date:  3/10/13
  
  Revision Log:  V1.0 - VRH - 3/10/13 - Created
                 V1.1 - VRH - 9/5/14 - Modified for EAB project
                 V1.2 - Modified By - Abhinav Sharma - 06/25/2018 - CR-20180605-12266 - Replace Email/Advisory_com_Preferred_Email_Address__c with Company_Email__c
		 V1.3 - Modified By - Neha Sharma - 05/19/2021 - CR-20190620-13192
        
*/
public class SiteProfileSubscriptionUploadController {

  public static final String SUBSCRIBE_SUCCESSFUL = 'Success';
  public static final String SUBSCRIBE_FAIL_NO_CONTACT = 'No active Site Profile with that Eloqua Email';
  public static final String SUBSCRIBE_FAIL_ALREADY_SUBSCRIBED = 'User already subscribed';
  public static final String SUBSCRIBE_FAIL_NOT_ELIGIBLE = 'Not eligible for that subscription option';
  public static final String EMAIL_HEADER_STRING = 'Eloqua Email';
  
  public integer EmailCount {
    get {
      if (EmailCount == null) EmailCount = 0;
      return EmailCount;
    }
    set;
  }
  
  //Commented By - Neha Sharma - 05/19/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
  // Subscription Name is used in the Export Details button on the corresponding VF Page
  public String SubscriptionName {
    get {
      /*if (SubscriptionName == null && EligibleSubOption.Related_Subscription__c != null) {
        List<Subscription_Option__c> subOptions = [SELECT Name 
                            			   FROM Subscription_Option__c 
                            			   WHERE Id = :EligibleSubOption.Related_Subscription__c];
        if (subOptions.size() > 0) SubscriptionName = subOptions[0].Name;
      }*/
      return SubscriptionName;
    }
    set;
  }
  
  //Commented By - Neha Sharma - 05/19/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
  // Eligible Subscription Option that is used so we can display the 'Related_Subscription__c' field on the VF page
  /*public Eligible_Subscription_Option__c EligibleSubOption {
    get {
      if (EligibleSubOption == null)  EligibleSubOption = new Eligible_Subscription_Option__c();
      return EligibleSubOption;
    }
    set;
  }*/
  
  // class to hold the contact + subscriptions + result data
  public class ContactWrapper {
    public Id EligibleSubOptionId { get; set; }
    public String Email { get; set; }
    public transient Contact Con { get; set; }
    public Id SubOptionId { get; set; }
    public Id ConId { get; set; }
    public String ConName { get; set; }
    //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
    //public transient Eligible_Subscription_Option__c EligSubOption { get; set; }
    
    public String SubscriptionEligibility {
      get {
        if (SubscriptionEligibility == null) {
          //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
          /*if (EligSubOption != null && EligSubOption.Id != null)
            SubscriptionEligibility = SiteProfileSubscriptionUploadController.SUBSCRIBE_SUCCESSFUL;
          else*/
	  if (Con == null)
            SubscriptionEligibility = SiteProfileSubscriptionUploadController.SUBSCRIBE_FAIL_NO_CONTACT;
          else
            SubscriptionEligibility = SiteProfileSubscriptionUploadController.SUBSCRIBE_FAIL_NOT_ELIGIBLE;
        }
        return SubscriptionEligibility;
      }
      set;
    }
    
    public ContactWrapper(String email, /*Id SubOptionId,*/ Contact con /*, Eligible_Subscription_Option__c eligSubOption*/) {
      this.Email = email;
      //Commented By - Neha Sharma - 05/19/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
      /*if (eligSubOption != null)
        this.EligSubOption = eligSubOption;*/
      if (con != null) {
        // set the contact
        this.Con = con;
        ConId = Con.Id;
        ConName = Con.Name;
        //Commented By - Neha Sharma - 05/19/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        // set the active subscriptions
        /*for (Subscription__c activeSub : con.Subscriptions__r) {
          //ActiveSubOptions.add(activeSub.Subscription_ID__r.Related_Subscription__c);
          try {
            if (eligSubOption != null && eligSubOption.Related_Subscription__c == activeSub.Subscription_ID__r.Related_Subscription__c) {
              SubscriptionEligibility = SiteProfileSubscriptionUploadController.SUBSCRIBE_FAIL_ALREADY_SUBSCRIBED;
            }
            else if (SubOptionId == activeSub.Subscription_ID__r.Related_Subscription__c) {
              SubscriptionEligibility = SiteProfileSubscriptionUploadController.SUBSCRIBE_FAIL_ALREADY_SUBSCRIBED;
            }
          }
          catch(Exception ex) {
            SubscriptionEligibility = 'EXCEPTION: ' + ex.getMessage();
            SubscriptionEligibility += ' on line number: ' + ex.getLineNumber();
            SubscriptionEligibility += '  stack trace: ' + ex.getStackTraceString();
          }
        }*/
      }
    }
    
  }
  
  public final integer MAX_ROWS = 3000;
  
  // the uploaded file
  public transient blob FileRecords { get; set; }
  public transient List<String> LineNo { get; set; }
  //List<Subscription__c> subscriptions = new List<Subscription__c>();
  
  // Upload the CSV file with 1 column of email addresses
  public Pagereference UploadFile() {
    ContactWrappers = new List<ContactWrapper>();
    // reset the pagination contact wrapper list
    PagedContactWrapperList = null;
    Set<String> ContactEmailSet = new Set<String>();
    //Commented By - Neha Sharma - 05/19/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
    //List<Subscription__c> subscriptionsToInsert = new List<Subscription__c>();
    
    /*if (EligibleSubOption.Related_Subscription__c == null) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Subscription is a required field.'));   
      return null;
    }
    else*/
    if (FileRecords == null || FileRecords.size() == 0) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must choose a CSV file to upload.'));   
      return null;
    }
    
    try { 
            String fileData = FileRecords.toString();
            
            // split the rows of data
      	    LineNo = FileData.split('\r\n');
      
      	    if (LineNo.size() >= (MAX_ROWS+2)) {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: The CSV file you uploaded cannot be larger than ' + MAX_ROWS + ' rows.'));   
            	return null;
      	    }
      
           // find which column the Email is on
      	   Integer columnNum = 0;
      	   for (String columnName : LineNo[0].split(',')) {
        	if (columnName.equalsIgnoreCase(EMAIL_HEADER_STRING)) break;
        	columnNum++;
      	   }
      
           // get all emails from the CSV file
      	   for (Integer i = 1; i < LineNo.size(); i++) {
        	List<String> actualData = LineNo[i].split(',');
                if (actualData.size() >= columnNum && actualData[columnNum] != null && actualData[columnNum].trim() != '') {
          		ContactEmailSet.add(actualData[columnNum].trim().toLowerCase());
          		EmailCount++;
                }
      	   }
    }
    catch(Exception ex) {
      system.debug('@@error: ' + ex);
      String readError = 'Couldn’t read the specified file.  Make sure the file is saved as a CSV with Eloqua Email as a Column Header and try again.';
            readError += '<br/>  If you continue to have problems, follow the steps below.';
            readError += '<br/><ul><li>Right-click the .csv file and choose \'Open with\' -> \'Notepad\'</li>';
            readError += '<li>In notepad, click File -> Save As...</li>';
            readError += '<li>Change the \'Encoding\' field that is located to the left of the Save button to UTF-8 and click Save</li>';
            readError += '<li>Try uploading the file again.</li>';
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, readError));  
      return null;
    }
    //Commented By - Neha Sharma - 05/19/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
    // Create contact wrappers from the contacts we found
    ContactWrappers = CreateContactWrappers(ContactEmailSet, null /*, EligibleSubOption.Related_Subscription__c*/);
    
    //Commented By - Neha Sharma - 05/19/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
    // add new subscriptions for each successful response
    /*for (ContactWrapper wrapper : ContactWrappers) {
      if (wrapper.SubscriptionEligibility == SUBSCRIBE_SUCCESSFUL) {
        Subscription__c newSub = new Subscription__c(Activation_Date__c = system.now(), 
        					     Contact__c = wrapper.Con.Id, 
                              			     Subscription_Status__c = 'Active',
                              			     Subscription_ID__c = wrapper.EligSubOption.Id);
        subscriptionsToInsert.add(newSub);
        
      }
    }*/
    
    //Commented By - Neha Sharma - 05/19/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
    // insert the new subscriptoins
    /*if (subscriptionsToInsert.size() > 0) {
      try {
        insert subscriptionsToInsert;
      }
      catch(DMLException ex) {
        // add any error to the result that is returned on the VF page.
        for (ContactWrapper wrapper : ContactWrappers) {
          wrapper.SubscriptionEligibility = ex.getDMLMessage(0);
        }
        return null;
      }
      catch(Exception ex) {
        // add any error to the result that is returned on the VF page.
        for (ContactWrapper wrapper : ContactWrappers) {
          wrapper.SubscriptionEligibility = ex.getMessage();
        }   
        return null;
      }
    }*/
    
    return null;
  }
  
  // Creates contact wrappers with information on whether or not the given subscription can be created on each contact
  public static List<ContactWrapper> CreateContactWrappers(Set<string> contactEmails, Id contactId /*, Id subscriptionOptionId*/) {
    if (contactEmails == null) contactEmails = new Set<String>();
    List<ContactWrapper> conWrapperList = new List<ContactWrapper>();
    Set<Id> acctIdSet = new Set<Id>();
    Set<Id> conIdSet = new Set<Id>();
    
    // add all emails to map
    Map<String, Contact> emailToContactMap = new Map<String, Contact>();
    for (String email : contactEmails) emailToContactMap.put(email.toLowerCase(), null);
    
    //Commented By - Neha Sharma - 05/19/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
    // get all adv.com user contacts
    String qryString = 'SELECT Id, AccountId, Email, Name,  (SELECT Id, Type__c, Status__c, User_Id__c, Username__c FROM Site_Profiles__r),' +
             		 /*'(SELECT Id, Subscription_ID__r.Related_Subscription__c ' +
                 	 'FROM Subscriptions__r WHERE Subscription_ID__r.Related_Subscription__c = :subscriptionOptionId AND Termination_Date__c = null) '*/ +
                  	 'FROM Contact WHERE Id IN (SELECT Contact__c FROM Site_Profile__c) ';
    
    //Modified By Abhinav Sharma - 06/25/2018 - CR-20180605-12266 - Replace Email/Advisory_com_Preferred_Email_Address__c with Company_Email__c
    //if (contactId == null) qryString += 'AND (Advisory_com_Preferred_Email_Address__c IN :contactEmails OR Email IN :contactEmails)';
    if (contactId == null) qryString += 'AND (Company_Email__c IN :contactEmails)';
    else qryString += 'AND Id = :contactId';
    
    List<Contact> advContacts = database.query(qryString);
    
    // match each contact to an email in our map
    // for (Contact con : advContacts) emailToContactMap.put(con.Eloqua_Email__c.toLowerCase(), con);
    
    // get a unique set of Contact & Account Ids
    for (Contact c : advContacts) {
      acctIdSet.add(c.AccountId);
      conIdSet.add(c.Id);
    }
    
    // get all institutions with memberships and programs
    Map<Id, Account> acctMap = new Map<Id, Account>([SELECT Id, 
    						     (SELECT Id, Program__c FROM Memberships__r WHERE Membership_Status_Text__c LIKE 'Member%') 
                            			     FROM Account WHERE Id IN :acctIdSet]);
    
    // get all unique program ids
    Set<Id> progIdSet = new Set<Id>();
    for (Account acct : acctMap.values()) {
      for (Membership__c mem : acct.Memberships__r)
        progIdSet.add(mem.Program__c);
    }
    
    //Commented By - Neha Sharma - 05/19/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
    /*List<Eligible_Subscription_Option__c> subscriptionOptions = [SELECT Id, Related_Subscription__c, Program__c 
                                  FROM Eligible_Subscription_Option__c 
                                  WHERE Related_Subscription__c = :subscriptionOptionId];
    
    Map<Id, Eligible_Subscription_Option__c> programToEligSubOption = new Map<Id, Eligible_Subscription_Option__c>();
    for (Eligible_Subscription_Option__c eso : subscriptionOptions) {
      programToEligSubOption.put(eso.Program__c, eso);
    }*/
    
    
    // match the contacts up with their corresponding email
    /*for (Contact con : advContacts) {
      emailToContactMap.put(con.Eloqua_Email__c.toLowerCase(), con);
    }*/
    
    /*Map<Id, Eligible_Subscription_Option__c> acctToESOMap = new Map<Id, Eligible_Subscription_Option__c>();
    
    // map each acct with a prog -> eligible sub option
    for (Account acct : acctMap.values()) {
      for (Membership__c mem : acct.Memberships__r) {
        Eligible_Subscription_Option__c eso = programToEligSubOption.get(mem.Program__c);
        if (eso != null) {
          acctToESOMap.put(acct.Id, eso);
          break;
        }
      }
    }*/
    
    // add all emails / email+Contacts to the wrapper list
    for (String key : emailToContactMap.keySet()) {
      Contact con = emailToContactMap.get(key);
      if (con != null) {
        //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        // get a unique set of Subscription Ids
        /*Eligible_Subscription_Option__c EligSubOption;
        if (con.AccountId != null) 
          EligSubOption = acctToESOMap.get(con.AccountId);*/
        
        conWrapperList.add(new ContactWrapper(key, /*subscriptionOptionId,*/ con /*, EligSubOption*/));
      }
      else
        conWrapperList.add(new ContactWrapper(key, /*subscriptionOptionId,*/ null /*, null*/));
    }
    
    return conWrapperList;
  }
  
  // hold the paged version of contact wrappers
  public PaginatedContactWrapper PagedContactWrapperList {
    get {
      if (PagedContactWrapperList == null && ContactWrappers != null) {
        PagedContactWrapperList = new PaginatedContactWrapper();
        for (ContactWrapper conWrap : ContactWrappers) {
          PagedContactWrapperList.add(conWrap);
        }
      }
      return PagedContactWrapperList;
    }
    set;
  }
  
  // export the results to excel
  public PageReference ExportToExcel() {
      PageReference pg = Page.SiteProfileSubscriptionExcel;
      pg.setRedirect(false);
      return pg;
    }
  
  // list of contact wrappers that will be displayed in the grid on the VF page
  public transient List<ContactWrapper> ContactWrappers { get; set; }
    
}