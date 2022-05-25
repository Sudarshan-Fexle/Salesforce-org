/**
 *  Description     :   Controller class to have the logic of VF page will be invoked from "Email Experts" button onk case detail page.
 * 
 *  Created By      :      
 * 
 *  Created Date    :   
 * 
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.1 - Modified By - Abhinav Sharma - CR-20140513-5496 - 06/02/2014
 *                      V_1.2 - Modified By - Abhinav Sharma - CR-20140629-6014 - 07/02/2014
 *                      V_1.3 - Modified By - Abhinav Sharma - CR-20140629-6015 - 07/05/2014
 *                      V_1.4 - Modified By - Abhinav Sharma - CR-20150603-8989 - 06/10/2015
 *                      V_1.5 - Modified By - Abhinav Sharma - CR-20150914-9243 - 11/27/2015
 *                      V_1.6 - Modified By - Abhinav Sharma - CR-20150925-9267 - 02/26/2016
 *                      V_1.7 - Modified By - Colin McGloin - CR-20160420-9784 - 04/21/2016
 *                      V_1.8 - Modified By - MAhendra Swarnkar - CR-20160729-10075 - 08/27/2016
 *                      V_1.9 - Modified By - Mahendra Swarnkar - CR-20160726-10065 - 11/18/2016 Added the "New_Member_s_First_Case__c" field in the Query to fetch its value
 *                      V_2.0 - Modified By - Mahendra Swarnkar - CR-20161102-10332 - 1/19/2017 - Comment out "CRMfusionDBR101.DB_Globals.triggersDisabled"
 *                      V_2.1 - Modified By - Mahendra Swarnkar - CR-20170217-10702 - 03/18/2017 - Added the fields in the Query to fetch its value
 * 			V_2.3 - Modified By - Dipesh Gupta - CR-20170519-10949 - 07/05/2017 - replace the "Platinum Services"  and "Access member" field references with the "Research Platform" field reference
 * 			V_2.4 - Modified By - Colin McGloin - CR-20180131-11928 - 03/20/2018 - Add entity population in the createDummyContact method to fix error
 *			V_2.5 - Modified By - Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756
 *			V_2.6 - Modified By - Nikita Kumari - 02/02/2022 - CR-20220120-15734 - Added SME Info section fields in soql
 **/ 
public with sharing class CaseEmailController {
    
    //Added By - MAhendra Swarnkar - CR-20160729-10075 - 08/27/2016 - Starts From here
    //Internal Email Suffixes
    List<Internal_Applicable_Email_Suffix__mdt> internalEmailSuffixes = Constants.LIST_OF_INTERNAL_APPLICABLE_EMAIL_SUFFIXES;
        
    //Map of internal suffixes where record type developer name will behave as key
    Map<String, Set<String>> mapOfInternalEmailSuffixes;
    //Added By - MAhendra Swarnkar - CR-20160729-10075 - 08/27/2016 - Ends  here
    
    // the cc value
    public String EmailCC { get; set; }
    
    // email sent true/false
    public boolean EmailSentSuccessfully { get; set; }
    
    public String MembershipsCommaDelim {
        get {
            if (MembershipsCommaDelim == null) {
                MembershipsCommaDelim = '';
                for (integer i = 0; i < Memberships.size(); i++) {
                    MembershipsCommaDelim += Memberships[i].Program__r.Program_Acronym__c;
                    if (i < memberships.size()-1)
                         MembershipsCommaDelim += ', ';
                }
            }
            return MembershipsCommaDelim;
        }
        set;
    }
    
    // list of email addresses
    public String AvailableEmails {
        get {
            
            //Checking for null value
            if (AvailableEmails ==  null) {
                
                //Memory allocation and initialization
                AvailableEmails = '';
                 
                //Query to fetch all the Active Users
                List<User> users = [SELECT Id, Email FROM User 
                                        WHERE IsActive = true 
                                        ORDER BY Email ASC];
                
                //Add all emails to a set to prevent duplicates
                set<String> emailSet = new Set<String>();
                
                //Loop over the users
                for (User u : users) {
                    
                    //Modified By - Mahendra Swarnkar - CR-20160729-10075 - 08/27/2016 - Starts from here
                    //Check for expert center record type
                    if(ISExpertCenter || IsActMgr) { 
                        
                        //Checking emails for the eligibility
                        if(mapOfInternalEmailSuffixes != null 
                            && mapOfInternalEmailSuffixes.size() > 0
                            && mapOfInternalEmailSuffixes.containsKey(aCase.RecordType.DeveloperName)
                            && mapOfInternalEmailSuffixes.get(aCase.RecordType.DeveloperName) != null
                            && mapOfInternalEmailSuffixes.get(aCase.RecordType.DeveloperName).size() > 0) {
                                
                            //If expert center record type then only allows internal type of emails
                            for(String str : mapOfInternalEmailSuffixes.get(aCase.RecordType.DeveloperName)) {
                                
                                //Checking for null/blank value and eligibility and populating collection accordingly
                                if(String.isNotBlank(str.trim()) 
                                    && u.Email.trim().toLowerCase().contains(str))
                                    emailSet.add(u.Email);            
                            }
                        } else {
                            emailSet.add(u.Email);
                        }
                    } 
                    else {
                        
                        //Check for IRC Request record type
                        if(IsIRCRequest) {
                            
                            //Checking emails for the eligibility
                            if(mapOfInternalEmailSuffixes != null 
                                && mapOfInternalEmailSuffixes.size() > 0
                                && mapOfInternalEmailSuffixes.containsKey(aCase.RecordType.DeveloperName)
                                && mapOfInternalEmailSuffixes.get(aCase.RecordType.DeveloperName) != null
                                && mapOfInternalEmailSuffixes.get(aCase.RecordType.DeveloperName).size() > 0) {
                                    
                                //If  IRC Request record type then only add internal emails into the list
                                for(String str : mapOfInternalEmailSuffixes.get(aCase.RecordType.DeveloperName)) { 
                                    
                                    //Checking for null/blank value and eligibility and populating collection accordingly
                                    if(String.isNotBlank(str.trim()) 
                                       && u.Email.trim().toLowerCase().contains(str))
                                        emailSet.add(u.Email);            
                                }
                            } else {
                                emailSet.add(u.Email);
                            }
                        }
                        
                        //otherwise directly add the email into the collection
                        else {
                            emailSet.add(u.Email);
                        }
                    }
                }
                //Modified By - MAhendra Swarnkar - CR-20160729-10075 - 08/27/2016 - Ends here
                
                //Add emails to a list and sort them
                List<String> emailList = new List<String>();
                
                //Populating list with record
                for (String s : emailSet)
                    emailList.add(s);
                
                // sort the list in ascending order
                emailList.sort();
                
                //Loop through list of emails and constructing a comma seperated string literal
                for (String email : emailList)
                    AvailableEmails += '"' + email + '",';
                
                //Modified By - MAhendra Swarnkar - CR-20160729-10075 - 08/27/2016 - Added check for null - Starts from here
                // chop off that last comma
                if(AvailableEmails != '' && AvailableEmails.length() > 0)
                    AvailableEmails = AvailableEmails.subString(0, AvailableEmails.length()-1);
                //Modified By - MAhendra Swarnkar - CR-20160729-10075 - 08/27/2016 - Added check for null Starts from here
            }
            
            //Return constructed list of available emails
            return AvailableEmails;
        }
        private set;
    }
    
    //CC emails list
    public List<String> EmailCCList {
        get {
            EmailCCList = new List<String>();
            if (EmailCC.length() > 0) {
                // trim the string to remove any spaces
                EmailCC = EmailCC.replaceAll(' *', '');
                EmailCCList = EmailCC.trim().split(';');
            }
            
            return EmailCCList;
        }
        set;
    }
    // the bcc value
    public String EmailBCC { get; set; }
    
    //BCC emails list
    public List<String> EmailBCCList {
        get {
            EmailBCCList = new List<String>();
            if (EmailBCC.length() > 0) {
                // trim the string to remove any spaces
                EmailBCC = EmailBCC.replaceAll(' *', '');
                EmailBCCList = EmailBCC.split(';');
            }
            
            return EmailBCCList;
        }
        set;
    }
    
    // the subject value
    public String EmailSubject { get; set; }
    
    // the body value
    public String EmailBody {
        get {
            if (EmailBody == null && ApexPages.currentPage().getParameters().get('emailBody') !=  null)
                EmailBody = ApexPages.currentPage().getParameters().get('emailBody');
            if (EmailBody != null && ApexPages.currentPage().getURL().Contains('EmailPreview')) {
                if (EmailBody.Contains('\n'))
                    EmailBody = AddLines(EmailBody);
            }
            
            return EmailBody;
        }
        set;
    }
    
    // get the current user's info
    public User CurrentUser {
        get {
            if (CurrentUser == null) {
                CurrentUser = [SELECT Name, Id, Email FROM User WHERE Id = :UserInfo.getUserId()];
            }
            return CurrentUser;
        }
        set;
    }
    
    // get the related opportunity Id from the URL
    public String CaseId {
        get {
            if (CaseId == null)
                CaseId = ApexPages.currentPage().getParameters().get('id');
            return CaseId;
        }
        set;
    }
    
    //Email Attachments
    public List<Attachment> EmailAttachments {
        get {
            if (EmailAttachments == null)
                EmailAttachments = new List<Attachment>();
            return EmailAttachments;
        }
        set;
    }
    
    public String NameFile { get; set; }
    //public Attachment ContentFile { get; set; }
    
    //Email Attachment
    public Attachment EmailAttachment {
        get {
            if (EmailAttachment == null)
                EmailAttachment = new Attachment();
            return EmailAttachment;
        }
        set;
    }
    
    public PageReference SaveDoc() {
        Attachment newAttachment = new Attachment();
        if (SelectedId != null) {
            List<ContentVersion> contentVersionList = [SELECT id,Title,VersionData,PathOnClient FROM ContentVersion WHERE Id = :SelectedId];
            if (contentVersionList.size() == 1) {
                ContentVersion contentVersion = contentVersionList[0];
                newAttachment.Body = contentVersion.VersionData;
                
                String str = contentVersion.PathOnClient
                                .substring(contentVersion.PathOnClient.lastIndexOf('.')+1
                                ,contentVersion.PathOnClient.length());
                
                newAttachment.Name = contentVersion.Title + '.' + str;
            }
            // clear the selected id to bring the picklist back to '--None--'
            SelectedId = null;
        }
        else {
            EmailAttachment.Name = NameFile;
            newAttachment = EmailAttachment.Clone();
        }
        newAttachment.ParentId = aCase.Id;
        
        // make sure the attachment is valid, if not, throw an error
        if (newAttachment.Body == null ||  newAttachment.Name == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No file was selected.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        try {
            insert newAttachment;
        }
        catch(Exception ex) {
            return null;
        }
        // set attachment body to null (viewstate issues)
        newAttachment.body = null;
        EmailAttachments.add(newAttachment);
        EmailAttachment = new Attachment();
        return null;
    }
    
    public String AttachmentToRemove { get; set; }
    
    public PageReference RemoveAttachment() {
        for (integer i = 0; i < EmailAttachments.size(); i++) {
            Attachment a = EmailAttachments[i];
            if (a.Name == AttachmentToRemove) {
                EmailAttachments.remove(i);
            }
        }
        return null;
    }
    
    //V_1.12 - Modified By - Dipesh Gupta - CR-20170519-10949 - 07/05/2017 - replace the "Platinum Services"  and "Access member" field references with the "Research Platform" field reference in the query
    //Modified By - Mahendra Swarnkar - CR-20160726-10065 - 11/18/2016 Added the "New_Member_s_First_Case__c" field in the Query to fetch its value
    //Modified By - MAhendra Swarnkar - CR-20160803-10082 - 08/23/2016 - Added Platinum_Services__c field in the query
    //Modified By - Abhinav Sharma - CR-20140629-6014 - 07/02/2014 - Included Origin field in the Query
    //Modified By - Abhinav Sharma - CR-20140513-5496 - 06/02/2014 - Included RecordType.DeveloperName & Response_Format__c in the Query
    // the related opportunity
    //Modified By - Abhinav Sharma - CR-20150603-8989 - 06/10/2015 - Added New_Member__c, Member_Type__c fields in the query 
    //Modified By - Abhinav Sharma - CR-20150925-9267 - 02/26/2016 - Replace New_Member__c with New_Member_Programs_RI__c
    /** Modified By - Mahendra Swarnkar - CR-20170217-10702 - 03/18/2017 - Added fields Active_PT_Memberships__c,Active_RI_Memberships__c, Parent_System__c,
                                                                      Access_Member__c, Account_Type__c, Active_TD_Memberships__c, New_Member_Programs_TD__c to query **/                 
    public Case aCase {
        get {
            if (aCase == null) {
                //Modified By - Nikita Kumari - 02/02/2022 - CR-20220120-15734 - Added SME Info section fields in soql
                List<Case> cases = [SELECT Id, Contact_Email__c, AccountId, Active_PT_Memberships__c,Active_RI_Memberships__c, Parent_System__c,
                                    Account_Type__c, Priority, Response__c, Contact.Phone, Contact.Email,Active_TD_Memberships__c, 
                                    // New_Member_Programs_TD__c, 
                                    Parent_System__r.Name,Relationship_Manager__r.Name, Contact_City_State__c, CaseNumber, Owner.Name, CreatedDate, 
                                    Contact.Name, Account.Name, RI_Contract_Value__c, Relationship_Manager__c,Why_is_info_needed__c, 
                                    Executive_Advisor__c, Subject, Description, Deadline_Reason__c ,Contact_Title__c, Deadline__c, Contract_Value__c, 
                                    How_will_info_be_used__c,RecordType.DeveloperName, Response_Format__c, Origin, New_Member_Programs_RI__c, Member_Type__c, 
                                    //Research_Platform__c, 
                                    New_Member_s_First_Case__c,
                                    SME__c, Next_Steps_Post_Call__c,Previous_interactions__c,Who_is_joining_this_call_other_than_SL__c,
                                    Call_Topic_Additional_Details__c,Shared_Collateral__c,Topic_Content_Request__c, SME__r.Name, Who_is_joining_this_call_other_than_SL__r.Name, Topic_Content_Request__r.Name
                                    FROM Case WHERE Id = :CaseId];
                if (cases.size() > 0)
                    aCase = cases[0];
            }
            return aCase;
        }
        set;
    }
    
    public List<Membership__c> Memberships {
        get {
            if (Memberships == null) {
                Memberships = new List<Membership__c>();
                if (aCase != null)
                    Memberships = [SELECT Name, Id, Program_Acronym__c, Program__r.Name, Program__r.Program_Acronym__c, Membership_Status__c, Active_Contract_End_Date__c
                                    FROM Membership__c 
                                    WHERE Account_Name__c = :aCase.AccountId AND Membership_Status__c like 'member%' AND (Program__r.Business_Line__c like '%core%' OR Program__r.Business_Line__c like '%ri%')];
            }
            return Memberships;
        }
        set;
    }
    
    public boolean IsExpertCenter {
        get {
            if (IsExpertCenter == null) {
                // determine what type of email this is
                if (EmailType != null && EmailType.equalsIgnoreCase('ExpertCenter'))
                    IsExpertCenter = true;
                else
                    IsExpertCenter = false;
            }
            return IsExpertCenter;
        }
        set;
    }
    
    public boolean IsActMgr {
        get {
            if (IsActMgr == null) {
                // determine what type of email this is
                if (EmailType != null && EmailType.equalsIgnoreCase('AcctMgr'))
                    IsActMgr = true;
                else
                    IsActMgr = false;
            }
            return IsActMgr;
        }
        set;
    }
    
    //Added By - Abhinav Sharma - CR-20150914-9243 - 11/27/2015
    //Start from here
    public boolean IsAskEAB {
        get {
            if (IsAskEAB == null) {
                // determine what type of email this is
                if (EmailType != null && EmailType.equalsIgnoreCase('AskEAB'))
                    IsAskEAB = true;
                else
                    IsAskEAB = false;
            }
            return IsAskEAB;
        }
        set;
    }
    //upto Here
    
    //Added By Mahendra Swarnkar - CR-20160729-10075 - 08/27/2016 - Starts from here 
    public boolean IsIRCRequest {
        get {
            if (IsIRCRequest == null) {
                // determine what type of email this is
                if (EmailType != null && EmailType.equalsIgnoreCase(Constants.IRCREQUEST))
                    IsIRCRequest = true;
                else
                    IsIRCRequest = false;
            }
            return IsIRCRequest;
        }
        set;
    }
    //Added By Mahendra Swarnkar - CR-20160729-10075 - 08/27/2016 - Starts from here 
    
    public String EmailType { get; set; }
    
    //Constructor for the class
    public CaseEmailController() {
        
        EmailType = apexPages.currentPage().getParameters().get('type');
        
        //Updated By Bhavi - 01/31/2014 - CR-20140106-4225
        EmailCC = CurrentUser.Email;
        
        //Updated By - Abhinav Sharma - CR-20140629-6015 - 07/05/2014
        if (IsExpertCenter) {
            EmailSubject = aCase.Priority + ' – TEC Case # (' + aCase.CaseNumber + ') - ' + aCase.Account.Name;
        } else {
            //Commneted by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756 : IRC request
            /*if(IsIRCRequest && aCase.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_IRC_REQUEST)
                EmailSubject = Constants.IRC_REQUEST_RESPONSE + Constants.COLON +  Constants.CASE_NUMBER + ' ' + aCase.CaseNumber + ' - ' + aCase.Account.Name;
            else*/
                EmailSubject = Constants.MEMBER_READY_RESPONSE + Constants.COLON + Constants.CASE_NUMBER + ' ' + aCase.CaseNumber + ' - ' + aCase.Account.Name;
        }
        
        // Added By Mahendra Swarnkar - CR-20160729-10075 - 08/27/2016 - Starts from Here
        //Instantiate the Map of internal suffixes where record type developer name will behave as key
        mapOfInternalEmailSuffixes = new Map<String, Set<String>>();
        
        //Check for the internal email suffixes list size
        if(internalEmailSuffixes != null && internalEmailSuffixes.size() > 0 ){
            
            //Loop through internal email suffixes custom matadata type list
            for(Internal_Applicable_Email_Suffix__mdt iAEX : internalEmailSuffixes) {
                
                //Check for the case Object Type 
                if(String.isNotBlank(iAEX.Object_API_Name__c)
                   && iAEX.Object_API_Name__c.trim().toLowerCase() == Constants.CASE_OBJECT.toLowerCase()
                   && String.isNotBlank(iAEX.Applicable_Record_Types__c)) {
                       
                    //Checking for "Comma sepaerated values" in Applicable_Record_Types__c
                    //if yes then split it. perform a loop over splited values and populate map
                    //to have record type developer name as key
                    //Corresponding eligible domains set as value
                    if((iAEX.Applicable_Record_Types__c).contains(Constants.COMMA)) {
                       
                       //Loop through comma split string literal's on the record type developer name 
                       for(String rdType : iAEX.Applicable_Record_Types__c.split(Constants.COMMA)) {
                           
                           //Checking for key existance in the map and populating it accordingly
                           if(mapOfInternalEmailSuffixes.containsKey(rdType.trim()))
                               mapOfInternalEmailSuffixes.get(rdType.trim()).add(iAEX.Eligible_Email_Domain__c);
                           else
                               mapOfInternalEmailSuffixes.put(rdType.trim(), new Set<String>{iAEX.Eligible_Email_Domain__c});
                       }
                    
                    } else {
                       
                       //Checking for key existance in the map and populating it accordingly
                       if(mapOfInternalEmailSuffixes.containsKey((iAEX.Applicable_Record_Types__c).trim()))
                           mapOfInternalEmailSuffixes.get((iAEX.Applicable_Record_Types__c).trim()).add(iAEX.Eligible_Email_Domain__c);
                       else
                           mapOfInternalEmailSuffixes.put((iAEX.Applicable_Record_Types__c).trim(), new Set<String>{iAEX.Eligible_Email_Domain__c});
                    }
                }
            }    
        }
        // Added By Mahendra Swarnkar - CR-20160729-10075 - 08/27/2016 - Ends Here
    }
    
    public String EmailTo { get; set; }
    
    //To Emails List
    public List<String> EmailToList {
        get {
            EmailToList = new List<String>();
            if (EmailTo != null) {
                if (EmailTo.length() > 0) {
                    // replace commas with semi-colons
                    EmailTo = EmailTo.replaceAll(',', ';');
                    EmailTo = EmailTo.replaceAll(' *', '');
                    // trim the string to remove any spaces
                    EmailToList = EmailTo.trim().split(';');
                }
            }
            
            return EmailToList;
        }
        set;
    }
    
    public PageReference Cancel() {
        // return the case page
        PageReference pg = new PageReference('/'+aCase.Id);
        return pg;
    }
    
    public String ErrorString { get; set; }
    
    //Send Email Method
    public PageReference SendEmail() {
        
        try {
            
            //Added By mahendra Swarnkar - CR-20160729-10075 - 08/27/2016 - Starts From here
            //Boolean flag - Helpful in checking for internal email and respective email handling
            Boolean IS_EXTERNAL_EMAIL_EXISTS = false;
            Boolean IS_INVALID_EMAIL_EXISTS = false;
            
            
            //Set to hold the "eligible" internal domains string for "Expert Center" record type of case
            Set<String> setOfInternalDomainsForExpertCenterCases = new Set<String>();
            
            //Commnented Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756
            //Set to hold the "eligible" internal domains string for "IRC Request" record type of case
            //Set<String> setOfInternalDomainsForIRCRequestCases = new Set<String>();
            
            //Combine all list, in order to compare all emails, in single compare logic
            List<String> finalEmailsToCheck = new List<String>();
            if(EmailToList !=null && EmailToList.size()> 0)
                finalEmailsToCheck.addAll(EmailToList); 
            if(EmailBCCList != null && EmailBCCList.size() > 0)
                finalEmailsToCheck.addAll(EmailBCCList);
            if(EmailCCList != null && EmailCCList.size() > 0)
                finalEmailsToCheck.addAll(EmailCCList);
            
	    // Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756
            //Checking for key and value in the custom metadata type
            /*if(mapOfInternalEmailSuffixes.containsKey(Constants.CASE_RECORD_TYPE_EXPERT_CENTER)
                &&
                mapOfInternalEmailSuffixes.get(Constants.CASE_RECORD_TYPE_EXPERT_CENTER) != null
            ) {
                
                //Checking whether an email exists in TO emails list of Non-internal type
                //Loop through eligible internal domains  
                for(String str : mapOfInternalEmailSuffixes.get(Constants.CASE_RECORD_TYPE_EXPERT_CENTER)) {
                    str = str.replaceAll('@', '');
                    setOfInternalDomainsForExpertCenterCases.add(str.trim().toLowerCase());
                }
            }*/
            
            //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756 : IRC Request
            //Checking for key and value in the custom metadata type
            /*if(mapOfInternalEmailSuffixes.containsKey(Constants.CASE_RECORD_TYPE_IRC_REQUEST)
                &&
                mapOfInternalEmailSuffixes.get(Constants.CASE_RECORD_TYPE_IRC_REQUEST) != null
            ) {
                
                //Checking whether an email exists in TO emails list of Non-internal type
                //Loop through eligible internal domains  
                for(String str : mapOfInternalEmailSuffixes.get(Constants.CASE_RECORD_TYPE_IRC_REQUEST)) {
                    str = str.replaceAll('@', '');
                    setOfInternalDomainsForIRCRequestCases.add(str.trim().toLowerCase());
                }
            }*/
            
            //ToEmailAddresses list validate
            //Check for size for To address list
            if(finalEmailsToCheck != null && finalEmailsToCheck.size() > 0) { 
                //Loop over all the to addresses
                for(String toEmail : finalEmailsToCheck) {
                    
                    //Check here for ToEmail is valid email address or not
                    Integer indexOfEmail = toEmail.trim().indexOf('@');                 
                    
                    //Case - If email = @eab.com or eab.com only, if must contain at least one char in starts just before @
                    if(indexOfEmail <= 0){
                        IS_INVALID_EMAIL_EXISTS  = true;
                        break;    
                    }
                    //Check the size of 
                    if((toEmail.trim().split('@')).size() == 2){

                        //if the email is of expert certer type then validate the mails addresses for advisory related addresses
                        if(ISExpertCenter && setOfInternalDomainsForExpertCenterCases.size() > 0) {
                        
                            //Set the boolean flag to true if an email of Non-internal type exists
                            if(!setOfInternalDomainsForExpertCenterCases.contains(toEmail.trim().split('@')[1].toLowerCase().trim())) {  
                                IS_EXTERNAL_EMAIL_EXISTS = true;
                                break;
                            }
                        }
                        
                        //Commented by Mahendra Swarnakar - 03/05/2020 - CR-20200217-13756 : 
                        //Checking for IRC Request type
                        /*if(IsIRCRequest && setOfInternalDomainsForIRCRequestCases.size() > 0) {
                            
                            //Set the boolean flag to true if an email of Non-internal type exists
                            if(!setOfInternalDomainsForIRCRequestCases.contains(toEmail.trim().split('@')[1].toLowerCase())) {
                                IS_EXTERNAL_EMAIL_EXISTS = true;
                                break;
                            }
                        }*/
                        
                        //Commmented by Mahendra Swarnkar - 03/04/2020 - CR-20200217-13756
                        //Checking for Account Manager Request type
                        /*if(IsActMgr && aCase.RecordType.DeveloperName.equals(Constants.CASE_RECORD_TYPE_EXPERT_CENTER) && setOfInternalDomainsForIRCRequestCases.size() > 0) {
                            
                            //Set the boolean flag to true if an email of Non-internal type exists
                            if(!setOfInternalDomainsForExpertCenterCases.contains(toEmail.trim().split('@')[1].toLowerCase())) {
                                IS_EXTERNAL_EMAIL_EXISTS = true;
                                break;
                            }   
                        }*/
                    }
                    else{
                        IS_INVALID_EMAIL_EXISTS  = true;
                        break;
                    }
                }
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.RECIPIENT_FIELD_BLANK));            
                return null;
            }
            
            //Checking for flag value and adding message if internal email exists
            if(IS_EXTERNAL_EMAIL_EXISTS) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.ERROR_SEND_EMAIL_TO_INTERNAL_ADVISORY_RELATED_EMAIL_ADDRESS_ONLY));            
                return null;
            }
            
            if(IS_INVALID_EMAIL_EXISTS) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.INVALID_EMAIL_ADDRESS));            
                return null;
            }
            //Added By mahendra Swarnkar - CR-20160729-10075 - 08/27/2016 - Ends here
            
            // prepare the email to be sent
            Messaging.SingleEmailMessage mail = CreateCaseEmail(EmailToList, EmailCCList, CaseId, Label.DEFAULT_CASE_CREATEMAIL_ADDRESS, Label.DEFAULT_CASE_CREATEMAIL_ADDRESS, EmailSubject); //VH updated from CurrentUser.Email to tecsalesforce@advisory.com
            
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            messages.add(mail);
            
            // send the email and get the result
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(messages);
             
            if (results[0].isSuccess()) {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.CONFIRM, Label.CASE_EMAIL_SENT_SUCCESS_MESSAGE ) );
            }
            else {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'ERROR:' + results[0].getErrors()));
            }
            
            // set the sent email value to true so that we don't render the main page block.
            EmailSentSuccessfully = true;
        }
        catch (Exception ex) {
            ErrorString = ex.getMessage(); 
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, ex.getMessage() ) );
            return null;
        }
        
        // return the case page
        PageReference pg = Cancel();
        return pg;
    }
    
    public static Contact CreateDummyContact(String EmailAddress) {
        Contact con = new Contact();
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = :EmailAddress LIMIT 1];
        // if we find the contact already exists, use that contact, otherwise, create a new record
        if (contacts.size() > 0) {
            con = contacts[0];
        }
        else {
            con.LastName = EmailAddress;
            con.Email = EmailAddress;
            con.Description = '@@ Contact auto-created from CaseEmailController for purposes of data integrity (Activity would not be generated if there was no contact to associate the email to)';
            //Added by Colin McGloin - CR-20180131-11928
            con.Entity__c = 'EAB';
			
			con.Title = 'Test';
			con.Phone = '614-555-8855';
            // bypass dupeblocker
            //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
            insert con;
            //CRMfusionDBR101.DB_Globals.triggersDisabled = false;
        }
        
        return con;
    }
    
    // create the email message using the quote template
    public Messaging.SingleEmailMessage CreateCaseEmail(List<String> toRecipients, List<String> ccRecipients, Id caseId, String replyTo, String displayName, String eSubject){
        // create the email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Contact dummyContact = new Contact();
        if (toRecipients.size() > 0) {
            dummyContact = CreateDummyContact(toRecipients[0]);
            toRecipients.remove(0);
        }
        else if (ccRecipients.size() > 0) {
            dummyContact = CreateDummyContact(ccRecipients[0]);
            ccRecipients.remove(0);
        }
        /*this does not appear to be working -- must create an activity manually*/
        mail.setTargetObjectId(dummyContact.Id);
        // set the what id (Case)
        mail.setWhatId(caseId);
        mail.setSaveAsActivity(true);
        // set reply to email address
        mail.setReplyTo(replyTo);
        mail.setToAddresses(toRecipients);
        // set the subject
        mail.setSubject(eSubject+ReferenceString);
        
        //Modified By - Abhinav Sharma - CR-20150914-9243 - 11/27/2015
        //Start from here
        // put data in to our html body
        PageReference pr;
        
        //Checking for the record type
        if(aCase.RecordType != null && aCase.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_EAB_CUSTOM){
            pr = Page.AskEABTemplate;
            pr.getParameters().put(Constants.REFERENCE_STR,ReferenceString);    
        }
        else {    
            pr = Page.ExpertCenterTemplate;
            pr.getParameters().put(Constants.REFERENCE_STR,ReferenceString);  
        }    
        
        pr.getParameters().put(Constants.TYPE_PARAMETER, EmailType);
        String htmlBodyString;
        // only do this if it is not a test -- test methods don't support 'getContent()'
        if (!test.isRunningTest())
            htmlBodyString = (pr.GetContent().toString().replaceAll('\n', '\r\n'));
        else // send back a canned htmlBody
            htmlBodyString = '<b>this is a test </b>';
        //Upto here
        
        // parse-out the html tags from the html so we can set the PlainTextBody Properly
        integer startString = htmlBodyString.indexOf('</STYLE>');
        string plainBodyString = htmlBodyString.subString(startString+8, htmlBodyString.length());
        plainBodyString = plainBodyString.replaceAll('&nbsp;', ' ');
        plainBodyString = plainBodyString.replaceAll('<br/>', '\n');
        plainBodyString = plainBodyString.replaceAll('&#39;', '\'');
        plainBodyString = plainBodyString.replaceAll('<br />', '');
        
        //regular expression to match all HTML/XML tags
        string HTML_TAG_PATTERN = '<.*?>';
        // compile the pattern     
        pattern myPattern = pattern.compile(HTML_TAG_PATTERN);
        // get your matcher instance
        matcher myMatcher = myPattern.matcher(plainBodyString);
        //remove the tags     
        plainBodyString = myMatcher.replaceAll('');
        
        mail.setHtmlBody(htmlBodyString);
        mail.setPlainTextBody(plainBodyString);
        
        // set the sender's display name
        mail.setSenderDisplayName(displayName);
        
        
        // list of cc addresses
        if (EmailCCList.size() > 0) {
            mail.setCcAddresses(EmailCCList);
        }
        
        // list of bcc addresses
        if (EmailBCCList.size() > 0) {
            mail.setBccAddresses(EmailBCCList);
        }
        
        List<Messaging.EmailFileAttachment> eAttachments = new List<Messaging.EmailFileAttachment>();
        // if there are any attachments, attach them now
        for (Attachment a : EmailAttachments) {
            List<Attachment> attch = [SELECT Name,Body,ContentType From Attachment WHERE ID = :a.Id];
            if(attch.size() == 1) {
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(attch[0].Name);
                efa.setBody(attch[0].Body);
                efa.setContentType(attch[0].ContentType);
                eAttachments.add(efa);
            }
        }
        if (eAttachments.size() > 0)
             mail.setFileAttachments(eAttachments);
        return mail;
    }
    
    public String ReferenceString {
        get {
            if (ReferenceString == null) {
                ReferenceString = BuildReference(aCase.Id);
            }
            return ReferenceString;
        }
        set;
    }
    
    public static string BuildReference(string recordId) {
        //[ ref:_00DM04kmn._500M012rxU:ref ]
        //Modified by Colin McGloin as part of CR-9784
        string refString = ' [ ref:_';
        string orgId = String.valueOf(UserInfo.getOrganizationId());
        refString += orgId.subString(0, 5);
        string last10digitsOrg = orgId.substring(5, 15);
        if(last10digitsOrg.containsAny('0')){
            last10digitsOrg = last10digitsOrg.remove('0');
        }
        refString += last10digitsOrg;
        refString += '._';
        refString += recordId.subString(0, 5);
        string middledigitsRI = recordId.substring(5, 10);
        if(middledigitsRI.containsAny('0')){
            middledigitsRI = middledigitsRI.remove('0');
        }
        refString += middledigitsRI;
        refString += recordId.substring(10,15);
        refString += ':ref ]';
        return refString;
    }
    
    // properly format the input text to contain <br> elements for linebreaks
    public String AddLines(String inputText) {
        String retVal = inputText;
        if (retVal != null)
            retVal = retVal.replaceAll('\n', '<br/>');
        return retVal;
    }
    
    public String AttachmentType { get; set; }
    
    public String SearchString { get; set; }
    
    public List<String> ContentDocIds { 
        get {
            if (ContentDocIds == null)
                ContentDocIds = new List<String>();
            return ContentDocIds;
        }
        set;
    }
    
    public List<SelectOption> Workspaces {
        get {
            if (Workspaces == null) {
                Workspaces = new List<SelectOption>();
                // query for workspaces
                List<ContentWorkspace> contentWorkspaces = [SELECT Id, Name FROM ContentWorkspace];
                Workspaces.add(new SelectOption('', 'All Libraries'));
                for (ContentWorkspace cWorkSpace : contentWorkspaces) {
                    Workspaces.add(new SelectOption(cWorkSpace.Id, cWorkSpace.Name));
                }
            }
            return Workspaces;
        }
        set;
    }
    
    // selected workspace
    public String SelectedWorkspace { get; set; }
    public String SelectedId { get; set; }
    public Integer NoOfRecords { get; set; }
    public Integer PageNo {
        get {
            if (PageNo == null) PageNo = 0;
            return PageNo;
        }
        set;
    }
    
    public boolean HasNext {
        get {
            if (NoOfRecords > (Offset+ListSize)) return true;
            else return false;
        }
        set;
    }
    
    public boolean HasPrevious {
        get {
            if (PageNo > 0) return true;
            else return false;
        }
        set;
    }
    
    // returns the previous page of records
    public void Previous() {
        pageNo--;
    }
 
    // returns the next page of records
    public void Next() {
        pageNo++;
    }
    
    public Integer ListSize {
        get {
            return 10;
        }
        set;
    }
    public Integer Offset {
        get {
            Offset = ListSize * PageNo;
            return Offset;
        }
        set;
    }
    
    public List<ContentDocument> getContentDocuments() {
        
        String whereClause = '';
        if (SearchString != null && SearchString != '')
            whereClause = 'WHERE Title LIKE \'%' + SearchString + '%\' ';
        if (whereClause != '' && SelectedWorkspace != null)
            whereClause += ' AND ParentId = :SelectedWorkspace';
        else if (whereClause == '' && SelectedWorkspace != null)
            whereClause = 'WHERE ParentId = :SelectedWorkspace';
        
        if (whereClause == '')
            whereClause = 'WHERE LatestPublishedVersion.ContentUrl = null';
        else
            whereClause += ' AND LatestPublishedVersion.ContentUrl = null';
        
        String queryString = 'SELECT LatestPublishedVersionId, LatestPublishedVersion.FileType, Title FROM ContentDocument ' + whereClause + ' LIMIT ' + ListSize + ' OFFSET ' + Offset;
        List<ContentDocument> contentDocs = database.Query(queryString);
        // get the count of documents so we can figure out whether or not to show the Next/Previous links
        String countQuery = 'SELECT Id FROM ContentDocument ' + whereClause + ' LIMIT 1000';
        NoOfRecords = Database.Query(countQuery).size();
        
        return contentDocs;
    }
    
    public List<SelectOption> getTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('My Computer','My Computer'));
        options.add(new SelectOption('Content','Content'));
        return options;
    }
    
    public void Search() {
        // reset pageNo value to set the page number back to 0 when we perform a different search.
        PageNo = 0;
    }
}