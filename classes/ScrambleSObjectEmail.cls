/**
*  Description     	:   Scramble emails on an SObject.
*                       
*  Created By      	:   Victor Hanson
* 
*  Created Date		:   03/21/2018
* 
*  Revision Logs	:   V_1.0 - Created
*			:   V_1.1 - Modified By Dipesh Gupta - CR-20200313-13851.
*			:   V_1.2 - Modified By - Neha Sharma - 02/03/2021 - CR-20200625-14228 - Scramble and Deactivate the contact where Entity is HC type
					
**/
global class ScrambleSObjectEmail implements Database.Batchable<SObject>, Database.Stateful{
    String scrambleFrom { get; set; }
    String scrambleTo { get; set; }
    Double failedUpdates { get; set; }
    Set<Schema.SObjectField> emailFieldsToScramble { get; set; }
    Schema.SObjectField mainEmailField { get; set; }
    SObjectType objType { get; set; }
    
    //Added By - Neha Sharma - 02/03/2021 - CR-20200625-14228 - This check it's run only for Entity HC type Contacts Deactivation and scrambling
    Boolean runBatchForEntityHC {get; set;}
	
    public String queryString {
        get {
            if (queryString == null && emailFieldsToScramble != null && emailFieldsToScramble.size() > 0) {
                List<String> emailList = new List<String>();
                for (Schema.SObjectField sObjField : emailFieldsToScramble) emailList.add(sObjField.getDescribe().getName());
                String fieldString = String.join(emailList, ',');
                
                //if this is a Contact scramble, get the Primary_State_Province__c field, because it is referenced in the execution body
                if (objType == Contact.SObjectType) fieldString += ',Primary_State_Province__c';
                
                //Modified By - Neha Sharma - 02/03/2021 - CR-20200625-14228 - Modify duplicate check for contacts
                /*if (runBatchForEntityHC) {
                    queryString = String.format('SELECT Id,Contact_Status__c, {0} FROM {1} WHERE Entity__c != null AND Entity__c =: entityHC AND ({2} != null) AND (NOT ({2} LIKE :filter))', 
                                            new List<String> { fieldString,objType.getDescribe().getName(), mainEmailField.getDescribe().getName() });
                } 
                
                else*/
                    queryString = String.format('SELECT Id, {0} FROM {1} WHERE ({2} != null) AND (NOT ({2} LIKE :filter))', 
                                            new List<String> { fieldString,objType.getDescribe().getName(), mainEmailField.getDescribe().getName() });
                
                //ends here

            }
            return queryString;
        }
        set;
    }
    
    global ScrambleSObjectEmail(SObjectType objType, Schema.SObjectField mainEmailField, Set<Schema.SObjectField> additionalEmails, String scrambleFrom, String scrambleTo, string query, boolean runBatchForEntityHC){
        this.scrambleFrom = scrambleFrom;
        this.scrambleTo = scrambleTo;
        this.objType = objType;
        this.mainEmailField = mainEmailField;
        //Modified By - Neha Sharma - 02/03/2021 - CR-20200625-14228 - Modify duplicate check for contacts
        this.queryString = query;
        this .runBatchForEntityHC = runBatchForEntityHC;
        //End Here
        failedUpdates = 0;
        
        //add emails to the list of emails
        emailFieldsToScramble = new Set<Schema.SObjectField>();
        emailFieldsToScramble.add(mainEmailField);
        if (additionalEmails != null) emailFieldsToScramble.addAll(additionalEmails);
    }

    global Database.queryLocator start(Database.BatchableContext ctx){
        String filter = '%' + scrambleTo + '%';
        
        //Added By - Neha Sharma - 02/03/2021 - CR-20200625-14228 - to hold Entity HC value
	String entityHC = Constants.ENTITY_HC;

       
        return Database.getQueryLocator( queryString );
    }

    global void execute(Database.BatchableContext ctx, List<Sobject> scope){

        for(SObject sobj : scope){
            
            //scramble each email address field
            for (Schema.SObjectField fld : emailFieldsToScramble) {
                
                String fldNameString = fld.getDescribe().getName();
                
                //some emails shouldn't be updated
                if ((fld == Contact.Email && (string)sobj.get(Contact.Email) != null)|| fld == Site_Profile__c.Username__c) {
                   
                    //Added by Dipesh Gupta - CR-20200313-13851.
                    //Skip the Test contacts that contains Test and @outlook.com both In the email address. 
                    if(((string)sobj.get(fldNameString)).toLowercase().contains('test') && ((string)sobj.get(fldNameString)).toLowercase().contains('outlook.com'))
                    	continue;
                    
                    // skip any test contacts using regex: t[0-9]+@advisory.com  (ie: t00234@advisory.com OR tn2162@eab.com)
                    Pattern myPattern = Pattern.compile('tn?[0-9]+@(advisory|eab).com');
                    Matcher myMatcher = myPattern.matcher((string)sobj.get(fldNameString));
                    // if it matches the expression, skip it
                    if (myMatcher.matches()) continue;
                    else sobj.put(fldNameString, getScrambledEmail(string.escapeSingleQuotes((String)sobj.get(fldNameString))));
                    
                    sobj.put(fldNameString, string.valueOf(sobj.get(fldNameString)).replace('\\\'','\''));
                }
                else {
                    sobj.put(
                        fldNameString, 
                        getScrambledEmail((String)sobj.get(fldNameString))
                    );
                }
                
            }
            
            //populate required fields if this is a Contact
            if (objType.getDescribe().getName() == 'Contact') {
                if (sobj.get('Primary_State_Province__c') == null && runBatchForEntityHC == false) sobj.put('Primary_State_Province__c', 'DC');
                
                //Added By - Neha Sharma - 02/03/2021 - CR-20200625-14228 - Deactivate the contact where entity is HC.
                if (runBatchForEntityHC) sobj.put('Contact_Status__c', 'Inactive – Other');
            }
            
        }
        
        // VH 7/26/13 - Bypass all triggers
        util.BypassAllTriggers = true;
        List<Database.SaveResult> dsrs = Database.update(scope, false);
        for(Database.SaveResult dsr : dsrs){
            if(!dsr.isSuccess()){
                failedUpdates++;
            }
        }
    }
    
    public String getScrambledEmail(String email) {
        
        // if the email is null, return immediately
        if (email == null) return email;
        
        // get the position of the search string (typically the '@' symbol)
        Integer pos = email.indexOf(scrambleFrom);
        
        // replace the scrambleFrom string with the scrambleTo string (ie: '@' -> '@junkabc.')
        if(pos >= 0) {
            email = email.replace(scrambleFrom, scrambleTo);
        } else {
            email = email + scrambleTo;
        }
        
        return email;
    }
    
    global void finish(Database.BatchableContext ctx){
        if(runBatchForEntityHC == false)
        {
        AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedBy.Email
                            FROM AsyncApexJob WHERE id = :ctx.getJobId()];

        String emailMessage = 'Your batch job ScrambleContactEmail has finished.\n\n'
            + 'It executed ' + a.totalJobItems + ' batches.  Of which, ' + a.jobitemsprocessed
            + ' processed without any exceptions thrown and ' + a.numberOfErrors
            + ' batches threw unhandled exceptions.  Of the batches that executed without error, '
            + failedUpdates + ' records were not updated successfully.';

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.createdBy.email};
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('noreply@salesforce.com');
        mail.setSenderDisplayName('Batch Job Summary');
        mail.setSubject('Batch job completed');
        mail.setPlainTextBody(emailMessage);
        mail.setHtmlBody(emailMessage);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
        }
    }
}