/**
*  Purpose      :   Apex Classes/Triggers wise code coverage related details
*  Created By   :   Abhinav Sharma
**/
public with sharing class ProcessApexClassesWiseDetailsJob implements Queueable, Database.AllowsCallouts
{
    public RunAllTestsResultsWrapper sEW;
    public ProcessApexClassesWiseDetailsJob(RunAllTestsResultsWrapper sEW) 
    {
        this.sEW = sEW; 
    }
    
    public void execute(QueueableContext context)
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+ System.Label.ApexClassesWiseCoverageDetails);
        req.setMethod(Constants.HTTP_REQUEST_GET_TYPE); 
        req.setHeader(Constants.CONTENT_TYPE, Constants.CONTENT_TYPE_APP_JSON);
        req.setHeader(Constants.AUTHORIZATION, Constants.BEARER + Constants.CHAR_BLANK_SPACE + UserInfo.getSessionID());
        Http httpreq = new Http();
        HttpResponse res = httpreq.send(req);
        
        ApexClassesCoverageDetailsWrapper apexClassesWiseRelatedDetails = (ApexClassesCoverageDetailsWrapper)JSON.deserialize(res.getBody(), ApexClassesCoverageDetailsWrapper.class);
        
        if(apexClassesWiseRelatedDetails != null) 
        {
            if(apexClassesWiseRelatedDetails.records != null && apexClassesWiseRelatedDetails.records.size() > 0) 
            {
                Map<String, ApexClassTriggerWrapper> mapOfApexClassTriggersDetails = new Map<String, ApexClassTriggerWrapper>();
                for(ApexClass aC : [SELECT ID, Name FROM ApexClass ORDER By Name ASC]) 
                {
                    ApexClassTriggerWrapper aW = new ApexClassTriggerWrapper(aC.Id, aC.Name);
                    aW.componentType = 'Apex Class';
                    mapOfApexClassTriggersDetails.put(aC.Id, aW);
                }
                
                for(ApexTrigger aT : [SELECT ID, Name FROM ApexTrigger ORDER By Name ASC]) 
                {
                    ApexClassTriggerWrapper aWC = new ApexClassTriggerWrapper(aT.Id, aT.Name);
                    aWC.componentType = 'Apex Trigger';
                    mapOfApexClassTriggersDetails.put(aT.Id, aWC);
                }
                
                if(mapOfApexClassTriggersDetails.values().size() > 0) 
                {
                    sEW.emailBodyApexClassesCoverageDetails = 'Component Name' + Constants.CHAR_COMMA + 'Type' + Constants.CHAR_COMMA +  'Number of Line Uncovered' + Constants.CHAR_COMMA + 'Number of Line Covered' + Constants.CHAR_COMMA + 'Total no. of lines' + + Constants.CHAR_COMMA + 'Code Coverage (%)' + Constants.CHAR_NEW_LINE;
                    List<String> listOfApexClassesWithCoverageDetails = new List<String>();
                    for(ApexClassesCoverageDetailsWrapper.Records rec : apexClassesWiseRelatedDetails.records)
                    {
                        if(mapOfApexClassTriggersDetails.containsKey(rec.ApexClassOrTriggerId)) 
                        {
                            Integer totalNoOfLines = (rec.NumLinesCovered + rec.NumLinesUncovered);
                            listOfApexClassesWithCoverageDetails.add(mapOfApexClassTriggersDetails.get(rec.ApexClassOrTriggerId).apexClassOrTriggerName + Constants.CHAR_COMMA + mapOfApexClassTriggersDetails.get(rec.ApexClassOrTriggerId).componentType + Constants.CHAR_COMMA + rec.NumLinesUncovered + Constants.CHAR_COMMA + rec.NumLinesCovered + Constants.CHAR_COMMA + totalNoOfLines + Constants.CHAR_COMMA + CoreUtilities.doPercentageCalculation(rec.NumLinesCovered, totalNoOfLines, 2));
                        }
                    }
                    if(listOfApexClassesWithCoverageDetails.size() > 0) 
                    {
                        listOfApexClassesWithCoverageDetails.Sort();
                        for(String classDetailsLiteral : listOfApexClassesWithCoverageDetails)
                        {
                            sEW.emailBodyApexClassesCoverageDetails += classDetailsLiteral + Constants.CHAR_NEW_LINE; 
                        }        
                    }
                }
            }    
        }
        
        if(String.isNotBlank(System.Label.RunAllTestEmails)) 
        {
            Set<String> setOfEmails = new Set<String>();
            if(System.Label.RunAllTestEmails.split(Constants.CHAR_COMMA) != null 
               && System.Label.RunAllTestEmails.split(Constants.CHAR_COMMA).size() > 0) 
            {
                for(String eml : System.Label.RunAllTestEmails.split(Constants.CHAR_COMMA)) 
                {
                    setOfEmails.add(eml);
                }    
            }
            else 
            {
                setOfEmails.add(System.Label.RunAllTestEmails); 
            }
			
            if(setOfEmails.size() > 0) 
            {
                List<String> toRecipients = new List<String>();
                
                List<OrgWideEmailAddress> orgWideAddress = [Select id, Displayname, Address From OrgWideEmailAddress 
                                                            Where Address =: Label.SF_ADMIN_EMAIL];
                
                toRecipients.addAll(setOfEmails);
                if(toRecipients.size() > 0) 
                {
                     //Check the sandbox name - Spiliting the Usename from the last . so we can get the org name.
                    String userName = UserInfo.getUserName();
                   	String orgName = userName.subString(userName.lastIndexof('.')+1, userName.length());
					orgName = orgName.capitalize();
                    
                    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage mail = EmailHandler.createEmail(toRecipients, orgName + ' - ' + System.Label.RunAllTestsEmailSubject, '',System.Label.RunAllTestEmailBody,false);
                    Messaging.EmailFileAttachment attachmentFile1;
                    Messaging.EmailFileAttachment attachmentFile2;
                    
                    if(String.isNotBlank(sEW.emailBodyApexTestItemsDetails)) 
                    {
                        String fileOneName = System.Label.RunAllTestResultsFileName + Constants.CHAR_UNDERSCORE + CoreUtilities.getInstanceName() + Constants.CHAR_UNDERSCORE + String.valueOf(Date.today());
                        attachmentFile1 = EmailHandler.createEmailAttachment(fileOneName + Constants.FILE_EXTENSION_CSV, Blob.valueOf(sEW.emailBodyApexTestItemsDetails));
                    }
                    if(String.isNotBlank(sEW.emailBodyApexClassesCoverageDetails)) 
                    {
                        String fileSecondName = System.Label.Class_Wise_Details + Constants.CHAR_UNDERSCORE + CoreUtilities.getInstanceName() + Constants.CHAR_UNDERSCORE + String.valueOf(Date.today());
                        attachmentFile2 = EmailHandler.createEmailAttachment(fileSecondName + Constants.FILE_EXTENSION_CSV, Blob.valueOf(sEW.emailBodyOverallCodeCoverageDetails + Constants.CHAR_NEW_LINE + sEW.emailBodyApexClassesCoverageDetails));
                    }
                    
                    if(orgWideAddress != null && orgWideAddress.size() > 0)
                    	mail.setOrgWideEmailAddressId(orgWideAddress[0].Id);
                    
                    mail.setFileAttachments(new List<Messaging.EmailFileAttachment> {attachmentFile1, attachmentFile2});
                    emails.add(mail);
                    Messaging.sendEmail(emails);    
                }
                else 
                {
                    throw new customException(System.Label.Email_Missing_Error);    
                }
            }
        }
    }
    
    public class ApexClassTriggerWrapper
    {
        public String apexClassOrTriggerID;
        public String apexClassOrTriggerName;
        public String componentType;
        public ApexClassTriggerWrapper(String apexClassOrTriggerID, String apexClassOrTriggerName) 
        {
            this.apexClassOrTriggerID = apexClassOrTriggerID;
            this.apexClassOrTriggerName = apexClassOrTriggerName;
        }    
    }
}