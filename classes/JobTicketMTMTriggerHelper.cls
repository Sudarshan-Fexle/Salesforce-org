/**
*  Purpose         :  This Class is having all the automation logic method on Job Ticket MTM object.
* 
*  Created By      :   Dipesh Gupta
*
*  Created Date    :   11/22/2019
*
*  Revision Logs   :   V_1.0 - Created - Dipesh Gupta - CR-20191011-13405
*		       V_1.1 - Modified By - Victor Hanson - CR-20200211-13722 - added logic to support identification of digital printer
*		       V_1.2 - Modified By - Dipesh Gupta - CR-20200511-14035 - Default Component Code to CEEB
*		       V_1.3 - Modified By - Colin McGloin - CR-20200702-14258
*		       V_1.4 - Modified By - Abhinav Sharama - CR-20210106-14784 - 01/19/2021 - JobTicket MTM validation rules for 'Other'
*		       V_1.5 - Modified By - Mahendra Swarnakar - CR-20210325-15027 - 04/26/2021
*		       V_1.6 - Modified By - Shalu Sharma - CR-20210520-15168 - 06/16/2021 - PrintMIS: field to display envelope size(s)
*              	       V_1.7 - Modified By - Shalu Sharma - CR-20210924-15459 - 10/05/2021 - Added new method "populatesAvailablePriorYearInventoryOnJobTicket"
*                     
**/
public without sharing class JobTicketMTMTriggerHelper {
	
    /**
     *  Purpose         :	Sets the Component Type field on JTMtM
     *
     *  Revision Logs   :	V_1.0 - 04/28/2020 - Victor Hanson - Created
     *                     
    **/
    public static void updateJobTicketMtMFields(List<Job_Ticket_MtM__c> newJobTicketMTMs) 
    {
        Set<Id> jtComponentIds = new Set<id>();
        for (Job_Ticket_MtM__c jtMtM : newJobTicketMTMs) {
            if (jtMtM.Job_Ticket_Component__c != null)
                jtComponentIds.add(jtMtM.Job_Ticket_Component__c);
        }
        
        if (jtComponentIds.size() > 0) {
            //get job ticket components as a map
            Map<Id, Job_Ticket_Component__c> mapJTComponents = new Map<Id, Job_Ticket_Component__c>([SELECT Id, Component__c
                                                                                                    FROM Job_Ticket_Component__c WHERE Id IN :jtComponentIds]);
            for (Job_Ticket_MtM__c jtMtM : newJobTicketMTMs) {
                Job_Ticket_Component__c jtComponent = mapJTComponents.get(jtMtM.Job_Ticket_Component__c);
                if (jtComponent != null) {
                    jtMtM.Component_Type__c = jtComponent.Component__c;
                }
            }
        }
    }
    
    /**
     *  Purpose         :	update fields on job ticket
     *
     *  Revision Logs   :	Modified - 03/06/2020 - Victor Hanson - added digital printer identifier
     * 	                :       Modified - 06/16/2021 - Shalu Sharma - CR-20210520-15168 - Update "updateJobTicketFields" to populate "Envelope_Size__c" on Job Ticket
     *                     
    **/
    public static void updateJobTicketFields(List<Job_Ticket_MtM__c> newJobTicketMTMs, Map<Id, Job_Ticket_MtM__c> mapOldJobTicketMTMs) 
    {
        Set<Id> setJobTicket = new Set<Id>();
        Map<Id, Job_Ticket__c> mapOfJobTicket = new Map<Id, Job_Ticket__c>();
        List<Job_Ticket__c> jobTicketToUpdate = new List<Job_Ticket__c>();
        for(Job_Ticket_MtM__c jT : newJobTicketMTMs != null ? newJobTicketMTMs : mapOldJobTicketMTMs.values())
        {
            if(jT.Job_Ticket_Component__c != null && jT.Job_Ticket__c != null)
            {
                setJobTicket.add(jT.Job_Ticket__c);
            }	
        }
        if(setJobTicket.size() > 0)
        {
            Set<Id> jobTicketMTM = new Set<Id>();
            for(Job_Ticket_MtM__c jTm: [Select Id From Job_Ticket_MtM__c 
                                        Where Job_Ticket__c IN :setJobTicket])
            {
                jobTicketMTM.add(jTm.Id);
            }
            
            Map<Id, Set<String>> mapOfJobTicketIdWithComponentValues = new Map<Id, Set<String>>();
            Map<Id, Integer> mapOfJobTicketIdWithCountOfEnvelope = new Map<Id, Integer>();
            Set<Id> setOfJobTicketWithQualifyForDigitalComponent = new Set<Id>();
            Map<Id, Set<String>> mapOfJobTicketIdWithEnvelopeSize = new Map<Id, Set<String>>();
            
            Integer countOfEnvelope = 0;
            
            if(jobTicketMTM.size() > 0)
            {
            	for(Job_Ticket_MtM__c jTMTM : [Select Job_Ticket_Component__r.Component__c,Job_Ticket_Component__r.Size__c, Job_Ticket__c, Job_Ticket__r.Vendor_Type__c, 
                                               Job_Ticket__r.Component_Types_Referenced__c, Job_Ticket_Component__r.Qualifies_for_Digital_Printer__c,
                                               Job_Ticket__r.Program__r.Program_Formal_Name__c, Job_Ticket__r.Program__c
                                               From Job_Ticket_MtM__c 
                                               Where Id IN :jobTicketMTM 
                                               And Job_Ticket_Component__r.Component__c != null])
                {
                    if(!mapOfJobTicketIdWithComponentValues.containsKey(jTMTM.Job_Ticket__c)) 
                    {
                        mapOfJobTicketIdWithComponentValues.put(jTMTM.Job_Ticket__c, new set<String>());
                    }
                    mapOfJobTicketIdWithComponentValues.get(jTMTM.Job_Ticket__c).add(jTMTM.Job_Ticket_Component__r.Component__c);
                    
                    //03/06/2020 - CR-20200211-13722 - Victor Hanson - added logic to support identification of digital printer
                    //if there is a component mtm that qualifies for digital, vendor type is null, and program formal name contains Fulfillment
                    if (!setOfJobTicketWithQualifyForDigitalComponent.contains(jTMTM.Job_Ticket__c) 
                        && jTMTM.Job_Ticket_Component__r.Qualifies_for_Digital_Printer__c
                        && jtMtM.Job_Ticket__r.Vendor_Type__c == null
                        && (jtMtM.Job_Ticket__r.Program__c == null 
                            || (jtMtM.Job_Ticket__r.Program__c != null 
                                && !jtMtM.Job_Ticket__r.Program__r.Program_Formal_Name__c.containsIgnoreCase(Constants.FULFILLMENT))))
                    {
                        setOfJobTicketWithQualifyForDigitalComponent.add(jTMTM.Job_Ticket__c);
                    }
                    
                    //Added By - Shalu Sharma - CR-20210520-15168 - 06/16/2021 - To populate Envelope_Size__c on Job Ticket
                    if(jTMTM.Job_Ticket_Component__r.Component__c == Constants.COMPONENT_TYPE_ENVELOPE)
                    {
                        //map to hold all related JTM size where type is "Envelope"
                        if(!mapOfJobTicketIdWithEnvelopeSize.containsKey(jTMTM.Job_Ticket__c)) 
                        {
                            mapOfJobTicketIdWithEnvelopeSize.put(jTMTM.Job_Ticket__c, new set<String>());
                        }
                        mapOfJobTicketIdWithEnvelopeSize.get(jTMTM.Job_Ticket__c).add(jTMTM.Job_Ticket_Component__r.Size__c);
                    }
                    
                }
                if(mapOfJobTicketIdWithComponentValues.size() > 0)
                {
                    for(Id jId : mapOfJobTicketIdWithComponentValues.keySet())
                    {
                        Job_Ticket__c jobTicket = new Job_Ticket__c(Id = jId);

                        //Added by Colin McGloin - 12/10/2019
                        //Populate all of our values into the field Component_Types_Referenced__c
                        List <String> stringValues = new List<String>();
                        stringvalues.addall(mapOfJobTicketIdWithComponentValues.get(jId));
                        String combinedValues = String.join(stringValues, ',');
                        jobTicket.Component_Types_Referenced__c = combinedValues;
                        
                        //Added By - Shalu Sharma - CR-20210520-15168 - 06/16/2021 - To populate Envelope_Size__c on Job Ticket
                        if(mapOfJobTicketIdWithEnvelopeSize.size() > 0 && mapOfJobTicketIdWithEnvelopeSize.containsKey(jId))
                        {
                            //add all set of size into list
                            List <String> stringValuesForEnvelopeSize = new List<String>();
                            stringValuesForEnvelopeSize.addall(mapOfJobTicketIdWithEnvelopeSize.get(jId));
                            
                            //to join all the size values with ';'
                            String combinedValuesForEnvelopeSize = String.join(stringValuesForEnvelopeSize, ';');
                            jobTicket.Envelope_Size__c = combinedValuesForEnvelopeSize;
                        }
                        else
                        {
                            //assign blank into string
                            jobTicket.Envelope_Size__c = null;    
                        }
                        
                        //Modified by Victor Hanson - 03/06/2020 - CR-20200211-13722
                        //if job ticket is in the set of JTs with a Qualifying Digital Printer component, update digital printer on JT 
                        if (setOfJobTicketWithQualifyForDigitalComponent.contains(jobTicket.Id))
                        {
                            jobTicket.Vendor_Type__c = Constants.VENDOR_TYPE_DIGITAL;
                        }

                        //Update our records
                        jobTicketToUpdate.add(jobTicket);
                    }   
                }
            }
            else
            {
                for(Job_Ticket__c jTicket : [Select Id, Component_Types_Referenced__c
                                             From Job_Ticket__c 
                                             Where Id IN :setJobTicket])
                {
                    //Added By - Shalu Sharma - CR-20210520-15168 - 06/16/2021 - If no Job Ticket MtM exist on Job Ticket then set Envelope_Size__c = null
                    Job_Ticket__c jobTicket = new Job_Ticket__c(Id = jTicket.Id, 
                                                                Component_Types_Referenced__c = null,
                                                                Envelope_Size__c = null);
                    
                    jobTicketToUpdate.add(jobTicket);
                } 
            }
            if(jobTicketToUpdate.size() > 0)
            {
                Util.byPassAllTriggers = true;
                update jobTicketToUpdate;
                Util.byPassAllTriggers = false;
            }
        }
    }


    public static void checkForLockedRecordEdts (List<Job_Ticket_MtM__c> newJobTicketMTMs, Map<Id, Job_Ticket_MtM__c> mapOldJobTicketMTMs) {

        //Loop through our Job Ticket MtM records
        for(Job_Ticket_MtM__c jT : newJobTicketMTMs != null ? newJobTicketMTMs : mapOldJobTicketMTMs.values()){

            //Map of modified Field Names and old and new values
            Map<String, List<String>> mapFieldNameToOldandNewValue = new Map<String, List<String>>();

            //Check to see if our Record is Locked
            if (jT.Job_Ticket_Locked__c == true){

                //Get our Field Names
                Map<String, String> mapFieldNamesToLabels = getOurFieldSetFieldNames();
                Set<String> fields = mapFieldNamesToLabels.keyset();

                //Check Field Names List Size
                if (fields.size() > 0){

                    //Loop through fields
                    for (String f : fields){

                        //Check to see if the field was changed
                        if (jt.get(f) != mapOldJobTicketMTMs.get(jT.Id).get(f)) {

                            List<String> oldNewValues = new List<String>();

                            String newValue = String.valueOf(jt.get(f));
                            String oldValue = String.valueOf(mapOldJobTicketMTMs.get(jT.Id).get(f));
                            oldNewValues.add(oldValue);
                            oldNewValues.add(newValue);

                            String fieldLabel = mapFieldNamesToLabels.get(f);

                            //Put our Field Name, Old Value and New Value into the Map
                            mapFieldNameToOldandNewValue.put(fieldLabel, oldNewValues);

                        }

                    }

                }

            }

            //Let's send our Email if we have a value
            if (mapFieldNameToOldandNewValue.size() > 0)
            {
                sendEmailToStakeholders(jT.Job_Ticket__c, mapFieldNameToOldandNewValue);
            }

        }


    }
    
    public static Map<String, String> getOurFieldSetFieldNames () 
    {
        //List for storing all our field names
        Map<String, String> fieldNames = new Map<String, String>();

        //Query our Custom Metadata to get all the JTM field sets
        List <Job_Print_Ticket_View_Manager__mdt> allJTMFieldSets = [SELECT Id, Field_Sets__c FROM Job_Print_Ticket_View_Manager__mdt WHERE Location__c = 'JTM'];

        //Check to see if we have records
        if (allJTMFieldSets.size() > 0) 
        {
            //Loop through our field sets
            for (Job_Print_Ticket_View_Manager__mdt fieldSet : allJTMFieldSets){
                
                //Check we have a Field Set Name
                if (fieldSet.Field_Sets__c != null)
                {
                    //Get the fields contained in the Field Set and add the names to our List
                    for (Schema.FieldSetMember fields :Schema.SObjectType.Job_Ticket_MtM__c.fieldSets.getMap().get(fieldSet.Field_Sets__c).getFields())
                    {
                        //Add our field name/label to the Map
                        fieldNames.put(fields.getFieldPath(), fields.getLabel());
                    }
                }
            }
        }

        //Return our Field Names
        return fieldNames;

    }
    
    public static void sendEmailToStakeholders (Id jobticket, Map<String, List<String>> fieldNamesOldAndNewValue) 
    {
        // grab the email template
        List<EmailTemplate> emailTemplates = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName = 'Locked_Job_Ticket_Components_Modified'];
        
        if(emailTemplates!= null && emailTemplates.size() > 0) 
        {
            
            // grab the Job Ticket fields we need
            Job_Ticket__c jTicket = [Select Id, Name, School__c, Program__c, Program__r.Name, Art_Director_Name__c, Production_Manager__c, Production_Manager__r.Name, PM_Name__c FROM Job_Ticket__c WHERE Id=: jobticket];
    
            //Get our Group Names
            List<String> groupNames = System.Label.Job_Ticket_Queue_Names.split(';');
    
            //Get out Queue Members for the Email
            List <String> emailsToSendTo = new List <String>();
            for (User userToAdd : [SELECT Email FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName IN :groupNames)]){
    
                //Add our members to List
                emailsToSendTo.add(userToAdd.Email);
    
            } 
    
            //Set our HTML String
            String htmlBody = emailTemplates[0].HtmlValue;
    
            //Construct our Changed Fields string
            String changedFieldsString = '';
    
            //Loop through out Map
            for (String fieldName : fieldNamesOldAndNewValue.keyset())
            {
                List<String> oldAndNewValue = fieldNamesOldAndNewValue.get(fieldName);
    
                changedFieldsString += '<b>Field Name: </b>';
                changedFieldsString += fieldname;
                changedFieldsString += '<br>';
                changedFieldsString += '<b>Old Value: </b>';
                changedFieldsString += oldAndNewValue[0];
                changedFieldsString += '<br>';
                changedFieldsString += '<b>New Value: </b>';
                changedFieldsString += oldAndNewValue[1];
                changedFieldsString += '<br><br>';
    
            }
    
            // process the merge fields
            String subject = emailTemplates[0].Subject;
            subject = subject.replace('{!Job_Ticket__c.Name}', jTicket.Name);
    
            //Set our Custom Record Link
            String recordLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + jTicket.Id;
            htmlBody = htmlBody.replace('recordLink', recordLink);
    
            //Set our custom value on HTML body
            htmlBody = htmlBody.replace('{!custommergestringfromapexclass}', changedFieldsString);
    
            //Replace our Job Ticket Name in HTML Body
            htmlBody = htmlBody.replace('{!Job_Ticket__c.Name}', jTicket.Name);
            htmlBody = htmlBody.replace('{!Job_Ticket__c.School__c}', jTicket.School__c);
            htmlBody = htmlBody.replace('{!Job_Ticket__c.Program__c}', jTicket.Program__r.Name);
            htmlBody = htmlBody.replace('{!Job_Ticket__c.Art_Director_Name__c}', jTicket.Art_Director_Name__c);
            htmlBody = htmlBody.replace('{!Job_Ticket__c.Production_Manager__c}', jTicket.Production_Manager__r.Name);
            htmlBody = htmlBody.replace('{!Job_Ticket__c.PM_Name__c}', jTicket.PM_Name__c);
    
            //Remove quotes at end
            htmlBody = htmlBody.replace(']]>', '');
            htmlBody = htmlBody.replaceAll('<!\\[CDATA\\[', ''); // replace '<![CDATA['
            htmlBody = htmlBody.replaceAll('\\]\\]>', ''); // replace ']]'
    
            //Set our custom values on Plain body
            String plainBody = emailTemplates[0].Body;
            plainBody = plainBody.replace('{!custommergestringfromapexclass}', changedFieldsString);
            plainBody = plainBody.replace('recordLink', recordLink);
            plainBody = plainBody.replace('{!Job_Ticket__c.Name}', jTicket.Name);
            plainBody = plainBody.replace(']]>', '');
    
            //build the email message
            Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
            email.setToAddresses(emailsToSendTo);
            email.setReplyTo('noreply@salesforce.com');
            email.setSenderDisplayName('Salesforce Automated Email');
            email.setSubject(subject);
            email.setHtmlBody(htmlBody);
            email.setPlainTextBody(plainBody);
    
            //Send our email
            Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email}); 
        }
    }
   
    
    //Modified By Dipesh Gupta - CR-20200511-14035 - Default Component Code to CEEB
    public static void populateDefaultComponentCodeFromJT(List<Job_Ticket_MtM__c> newJobTicketMTMs)
    {
        Set<Id> setOfJobTicketIds = new Set<Id>();
            
     	for(Job_Ticket_MtM__c jtM : newJobTicketMTMs)
        {
            setOfJobTicketIds.add(jtM.Job_Ticket__c);    
        }
        
	//Modified By Mahendra Swarnakar - CR-20210325-15027 - 04/26/2021
        if(setOfJobTicketIds.size() > 0)
        {
            Map<Id, Job_Ticket__c> mapJobTickets = new Map<Id, Job_Ticket__c>([SELECT Id, CEEB_Code__c, Drop_Type__c
                                                                               FROM Job_Ticket__c 
                                                                               WHERE Id IN : setOfJobTicketIds]);
            for (Job_Ticket_MtM__c jtMtM : newJobTicketMTMs) 
            {
                Job_Ticket__c jobTicket = mapJobTickets.get(jtMtM.Job_Ticket__c);
                if (jobTicket != null) 
                {
                    if(jobTicket.Drop_Type__c != System.Label.DROP_TYPE_ON_DEMAND){
                        jtMtM.Component_Code__c = jobTicket.CEEB_Code__c;
                    }
                }
            }
        }
    }
    /**
     *  Purpose         :	This method is used to delete associated Inventory related to Job Ticket MtM
     *
     *  Revision Logs   :       V_1.5 - Added By - Abhinav Sharama - CR-20210106-14784 - 01/19/2021 - JobTicket MTM validation rules for 'Other'
     *                     
    **/
    public static void validationOnCustomTextFields(List<Job_Ticket_MtM__c> newJobTicketMTMs) 
    {

        //validate fields on Insert/Update case
        for(Job_Ticket_MtM__c jobTicket : newJobTicketMTMs) 
        {
            //Validation on Paper Weight
            if(jobTicket.Paper_Weightx__c == Constants.JOB_TICKET_MTM_SIZE_OTHER && String.isBlank(jobTicket.Paper_Weight_Custom__c)) {
                jobTicket.Paper_Weight_Custom__c.addError(Label.JT_MTM_Paper_Weight_Error_Msg);
            }
            //Validation on Fold
            else if(jobTicket.Fold__c == Constants.JOB_TICKET_MTM_SIZE_OTHER && String.isBlank(jobTicket.Fold_Custom__c)) {
                jobTicket.Fold_Custom__c.addError(Label.JT_MTM_Fold_Error_Msg);
            }
            //Validation on Letter Size
            else if(jobTicket.Letter_Size__c == Constants.JOB_TICKET_MTM_SIZE_OTHER && String.isBlank(jobTicket.Letter_Size_Custom__c)) {
                jobTicket.Letter_Size_Custom__c.addError(Label.JT_MTM_Letter_Size_Error_Msg);
            }
            //Validation on Reply Size
            else if(jobTicket.Reply_Size__c == Constants.JOB_TICKET_MTM_SIZE_OTHER && String.isBlank(jobTicket.Reply_Size_Custom__c)) {
                jobTicket.Reply_Size_Custom__c.addError(Label.JT_MTM_Reply_Size_Error_Msg);
            }
            //Validation on Window1 Position From Bottom
            else if(jobTicket.Window_1_Position_From_Bottom__c == Constants.JOB_TICKET_MTM_SIZE_OTHER && String.isBlank(jobTicket.Window1_Position_from_Bottom_Custom__c)) {
                jobTicket.Window1_Position_from_Bottom_Custom__c.addError(Label.JT_MTM_Window1_Position_From_Bottom_Error_Msg);
            }
            //Validation on Window1 Position From Left
            else if(jobTicket.Window_1_Position_From_Left__c == Constants.JOB_TICKET_MTM_SIZE_OTHER && String.isBlank(jobTicket.Window1_Position_from_Left_Custom__c)) {
                jobTicket.Window1_Position_from_Left_Custom__c.addError(Label.JT_MTM_Window1_Position_From_Left_Error_Msg);
            }
            //Validation on Window1 Size
            else if(jobTicket.Envelope_Window_1_Size__c == Constants.JOB_TICKET_MTM_SIZE_OTHER && String.isBlank(jobTicket.Window1_Size_Custom__c)) {
                jobTicket.Window1_Size_Custom__c.addError(Label.JT_MTM_Window1_Size_Error_Msg);
            }
            //Validation on Pref
            else if(jobTicket.Perf__c == Constants.JOB_TICKET_MTM_SIZE_OTHER && String.isBlank(jobTicket.Perforation_Custom__c)) {
                jobTicket.Perforation_Custom__c.addError(Label.JT_MTM_Perf_Error_Msg);
            }
            //Validation on Type of Fold
            else if(jobTicket.Type_of_Fold__c == Constants.JOB_TICKET_MTM_SIZE_OTHER && String.isBlank(jobTicket.Type_of_Fold_Custom__c )) {
                jobTicket.Type_of_Fold_Custom__c.addError(Label.JT_MTM_Type_of_Fold_Error_Msg);
            }
            //Validation on Paper Type
            else if(jobTicket.Paper_Typex__c == Constants.JOB_TICKET_MTM_SIZE_OTHER && String.isBlank(jobTicket.Paper_Type_Custom__c)) {
                jobTicket.Paper_Type_Custom__c.addError(Label.JT_MTM_Paper_Type_Error_Msg);
            }
            //Validation on Sub Type
            else if(jobTicket.Sub_type__c == Constants.JOB_TICKET_MTM_SIZE_OTHER && String.isBlank(jobTicket.Sub_type_Custom__c)) {
                jobTicket.Sub_type_Custom__c.addError(Label.JT_MTM_Sub_Type_Error_Msg);
            }
            //Validation on Folded Size
            else if(jobTicket.Folded_Size__c == Constants.JOB_TICKET_MTM_SIZE_OTHER && String.isBlank(jobTicket.Folded_Size_Custom__c)) {
                jobTicket.Folded_Size_Custom__c.addError(Label.JT_MTM_Folded_Size_Error_Msg);
            }
            //Validation on Form Size
            else if(jobTicket.Form_Size__c == Constants.JOB_TICKET_MTM_SIZE_OTHER && String.isBlank(jobTicket.Form_Size_Custom__c)) {
                jobTicket.Form_Size_Custom__c.addError(Label.JT_MTM_Form_Size_Error_Msg);
            }
        }
    }
    
    //Modified By Mahendra Swarnakar - CR-20210325-15027 - 04/26/2021
    //We are intentionally executing it in future method because we are updating MTMs on there insertion which can cause side effects
    //if will run in the same context and we are executing this method in after event due to dependency of Component_Counter_Id__c
    //field which is an auto number field
    public static void populateComponentCodeForOndemandJT(List<Job_Ticket_MtM__c> newJobTicketMTMs, Map<Id, Job_Ticket_MtM__c> mapOldJobTicketMTMs) {
        
        Set<Id> setOfJobTicketIds = new Set<Id>();
        for(Job_Ticket_MtM__c jtM : newJobTicketMTMs)
        {
            if(jtM.Job_Ticket__c != null && String.isBlank(jtM.Component_Code__c)) 
            {
            	setOfJobTicketIds.add(jtM.Job_Ticket__c);
            }
        }
        if(setOfJobTicketIds.size() > 0) 
        {
            Map<Id, Job_Ticket__c> mapJobTickets = new Map<Id, Job_Ticket__c>([SELECT Id, CEEB_Code__c, 
                                                                               Drop_Type__c
                                                                               FROM Job_Ticket__c 
                                                                               WHERE Id IN : setOfJobTicketIds]);
        	
            List<Job_Ticket_MtM__c> listJTMtMtoUpdate = new List<Job_Ticket_MtM__c>();
            for (Job_Ticket_MtM__c jtMtM : newJobTicketMTMs) 
            {
                Job_Ticket__c jobTicket = mapJobTickets.get(jtMtM.Job_Ticket__c);
                
                if (jobTicket != null 
                    && String.isNotBlank(jobTicket.Drop_Type__c)
                    && jobTicket.Drop_Type__c.equalsIgnoreCase(System.Label.DROP_TYPE_ON_DEMAND)
                ) 
                {
                    Job_Ticket_MtM__c jTM = new Job_Ticket_MtM__c(Id = jtMtM.ID ); 
                    jTM.Component_Code__c = jtMtM.Component_Counter_Id__c;
                    
                    if(String.isNotBlank(jtMtM.Component_Type__c) 
                       && jtMtM.Component_Type__c.equalsIgnoreCase(System.Label.COMPONENT_TYPE_FORM)
                    ) 
                    {
                        jTM.Laser__c = System.Label.DEFAULT_VALUE_FOR_LASER_FIELD;
                    }
                    listJTMtMtoUpdate.add(jTM);
                }
            }
            if(listJTMtMtoUpdate.size() > 0)
            {
                Util.BypassAllTriggers = true;
                update listJTMtMtoUpdate;
                Util.BypassAllTriggers = false;
            }    
        }
    }

    /**
    *  Purpose         :    This method is used to used to populate "Available Prior Year Inventory" on Job ticket
    *
    *  Revision Logs   :    V1.0 - Created - Shalu Sharma - CR-20210924-15459 - 10/05/2021
    *                     
    **/
    public static void populatesAvailablePriorYearInventoryOnJobTicket(List<Job_Ticket_MtM__c> newJobTicketMTMs, 
                                                                        Map<Id, Job_Ticket_MtM__c> mapOldJobTicketMTMs)
    {    
		Set<String> setOfComponentCodesAndCounterId = new Set<String>();
		Set<String> setOfFiscalYear = new Set<String>();
		
		for(Job_Ticket_MtM__c jtMTM : [Select Id, Job_Ticket__c, Job_Ticket__r.Fiscal_Year__c,
									   Job_Ticket__r.Drop_Type__c, Status__c, 
									   Component_Code_Formula__c, Component_Counter_Id__c
									   From Job_Ticket_Mtm__c 
									   Where Id IN :newJobTicketMTMs
									   AND Status__c != null AND Status__c = 'Approved'])
		{
			//Checking the status of JTMTM record
			if( mapOldJobTicketMTMs != null && mapOldJobTicketMTMs.get(jtMTM.Id).Status__c != jtMTM.Status__c)
			{
				if(jtMTM.Job_Ticket__r.Drop_Type__c == Constants.JOB_TICKET_PRE_PLANNED_DROP_TYPE && String.isNotBlank(jtMTM.Component_Code_Formula__c))
					setOfComponentCodesAndCounterId.add(jtMTM.Component_Code_Formula__c);
				
				if(jtMTM.Job_Ticket__r.Drop_Type__c == Constants.JOB_TICKET_ON_DEMAND_DROP_TYPE && String.isNotBlank(jtMTM.Component_Counter_Id__c))
					setOfComponentCodesAndCounterId.add(jtMTM.Component_Counter_Id__c);
				
				if(String.isNotBlank(jtMTM.Job_Ticket__r.Fiscal_Year__c)){
					setOfFiscalYear.add(String.valueOf(Integer.valueOf(jtMTM.Job_Ticket__r.Fiscal_Year__c)-1));
					setOfFiscalYear.add(jtMTM.Job_Ticket__r.Fiscal_Year__c);
				}
			}
		}
		
		//checking the size of map
		if(setOfComponentCodesAndCounterId.size() > 0 && setOfFiscalYear.size() > 0)
		{            
			//List of Job Tickets To Update
			Map<Id, Job_Ticket__c> jobTicketToBeUpdate = new Map<Id, Job_Ticket__c>();
			
			for(Inventory__c inventory : [Select Id, Name, Fiscal_Year__c, Inventory_Control_Number__c, 
										  Job_Ticket_MtM__r.Component_Code_Formula__c, 
										  Job_Ticket_MtM__r.Job_Ticket__r.Fiscal_Year__c,
										  Job_Ticket_MtM__r.Job_Ticket__c From Inventory__c
										  Where Component_Code_Counter_Id__c IN : setOfComponentCodesAndCounterId 
										  AND Fiscal_Year__c IN : setOfFiscalYear])
			{
				jobTicketToBeUpdate.put(inventory.Job_Ticket_MtM__r.Job_Ticket__c, new Job_Ticket__c(Id = inventory.Job_Ticket_MtM__r.Job_Ticket__c, Available_Prior_Year_Inventory__c = true));
			}
			
			//Checking the size of jobTicketToUpdate
			if(jobTicketToBeUpdate.size() > 0 && jobTicketToBeUpdate.values().size() > 0)
			{ 
				Util.bypassAllTriggers = true;
				Update jobTicketToBeUpdate.values();
				Util.bypassAllTriggers = false;
			}
		}
    }
}