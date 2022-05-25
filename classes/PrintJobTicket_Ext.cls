/*
    Purpose         :   Controller class to display to print out details from the Job Ticket record 
						which we can use to send to the Vendor.
                
    Created By      :   Abhinav Sharma
    
    Created Date    :   11/25/2019
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created - Abhinav Sharma - 11/25/2019
                        V_1.1 - Modified - Colin McGloin - 01/10/2019 - Removed Mail Shop Fields and Added new Colors Section
			V_1.2 - Modified - Victor Hanson - 05/08/2020 - CR-20200508-14031 - Added jobTicketName reference for PDF download
                        V_1.3 - Modified - Neha Sharma - 08/07/2021 - CR-20201218-14754 - add the getUserTimeZone method
*/
public with sharing class PrintJobTicket_Ext
{
    //Collection useful for displaying Job Ticket Details
    public Job_Ticket__c jobTicket {get; set;}
    public Map<Integer, List<Schema.FieldSetMember>> mapOfJobTicketFields {get; set;}
    public Map<Integer, List<Schema.FieldSetMember>> mapOfJobTicketMailShopFields {get; set;}
    public String jobTicketDescriptiveName {get; set;}
    //V_1.2 - Modified - Victor Hanson - 05/08/2020 - CR-20200508-14031 - Added jobTicketName reference for PDF download
    public String jobTicketName { get; set; }
    
    //Modified - Neha Sharma- 08/07/2021 - CR-20201218-14754 - Added the dateTimeUserContext for the PDF time zone
    public String dateTimeUserContext {get;set;}
    
    //Collection useful for displaying Job Ticket MtM Details
    public Map<String, Job_Print_Ticket_View_Manager__mdt> mapOfComponentTypeWithSettings {get; set;}
    public Map<String, List<Job_Ticket_MtM__c>> mapOfComponentTypeWithJobTicketMtMs {get; set;}
    public Map<String, List<List<Schema.FieldSetMember>>> mapOfComponentTypeWithFieldSetDetails {get; set;}
    
    public PrintJobTicket_Ext(ApexPages.StandardController standardController)
    {
        //Modified - Neha Sharma- 08/07/2021 - CR-20201218-14754 - add the calling of getUserTimeZone method
        getUserTimeZone();
        
        jobTicket = (Job_Ticket__c)standardController.getRecord();
        inIt();
        if(jobTicket != null && jobTicket.Id != null) 
        {
            fetchJobTicketRelatedDetails();
            mapOfComponentTypeWithSettings = fetchComponentTypeBasedSettingsAndMappings();
            fetchJobTicketMtMDetails();
        }
        else 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, System.Label.Unable_To_Access_Job_Ticket_Details));
        }
    }
    
    public void inIt() 
    {
    	jobTicketDescriptiveName = '';
        mapOfJobTicketFields = new Map<Integer, List<Schema.FieldSetMember>>();
        mapOfJobTicketMailShopFields = new Map<Integer, List<Schema.FieldSetMember>>();
        mapOfComponentTypeWithSettings = new Map<String, Job_Print_Ticket_View_Manager__mdt>();
        mapOfComponentTypeWithJobTicketMtMs = new Map<String, List<Job_Ticket_MtM__c>>();
        mapOfComponentTypeWithFieldSetDetails = new Map<String, List<List<Schema.FieldSetMember>>>();
        
        
        //V_1.2 - Modified - Victor Hanson - 05/08/2020 - CR-20200508-14031 - Added jobTicketName reference for PDF download
        //get jt name
        Job_Ticket__c jt = [SELECT Id, Name FROM Job_Ticket__c WHERE Id = :jobTicket.Id];
        jobTicketName = jt.Name;
    }
    
    private List<Schema.FieldSetMember> getJobTicketFields() 
    {
        return Schema.SObjectType.Job_Ticket__c.fieldSets.getMap().get(System.Label.PrintJobTicket_FieldSetName).getFields();
    }
    
    private List<Schema.FieldSetMember> getJobTicketMailShopFields() 
    {
        return Schema.SObjectType.Job_Ticket__c.fieldSets.getMap().get(System.Label.PrintJobTicket_MailShopFieldSetName).getFields();
    }
    
    private List<Schema.FieldSetMember> getJobTicketMTMFields(String fieldSetName) 
    {
        if(String.isNotBlank(fieldSetName)) 
        {
            return Schema.SObjectType.Job_Ticket_MtM__c.fieldSets.getMap().get(fieldSetName).getFields();        
        }
        else 
        {
            return null;    
        }
    }
    
    private void fetchJobTicketRelatedDetails() 
    {
        List<Schema.FieldSetMember> listOfJobTicketFSMs = new List<Schema.FieldSetMember>();
        listOfJobTicketFSMs.addAll(getJobTicketFields());
        listOfJobTicketFSMs.addAll(getJobTicketMailShopFields());
        
        String jobTicketId = jobTicket.Id;
        String whereClause = 'WHERE Id =:jobTicketId';
        String jobTicketQuery = DatabaseUtilities.getFieldsetQuery('Job_Ticket__c', listOfJobTicketFSMs, 
                                                                   new List<String>{'Descriptive_Name__c'}, 
                                                                   whereClause, null, null, true);
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets = (List<Job_Ticket__c>)Database.query(jobTicketQuery);
        if(jobTickets != null && jobTickets.size() > 0) 
        {
            jobTicket = jobTickets[0]; 	
            jobTicketDescriptiveName = jobTickets[0].Descriptive_Name__c;
            
            mapOfJobTicketFields = new Map<Integer, List<Schema.FieldSetMember>>();
            Integer cnt = 0;
            Integer keyCnt = 0;
            for(Schema.FieldSetMember sFS : getJobTicketFields()) 
            {
                if(cnt==Integer.valueOf(System.Label.Print_Job_Ticket_Section_Columns)) 
                {
                    keyCnt++;
                    cnt = 0;
                }

                if(mapOfJobTicketFields.containsKey(keyCnt)) 
                {
                    mapOfJobTicketFields.get(keyCnt).add(sFS);     
                }
                else 
                {
                    mapOfJobTicketFields.put(keyCnt, new List<Schema.FieldSetMember>{sFS});        
                }
                cnt++;
            }
            
            mapOfJobTicketMailShopFields = new Map<Integer, List<Schema.FieldSetMember>>();
            cnt = 0;
            keyCnt = 0;
            for(Schema.FieldSetMember sFSMS : getJobTicketMailShopFields()) 
            {
                if(cnt==Integer.valueOf(System.Label.Print_Job_Ticket_Mail_Shop_Section_Columns)) 
                {
                    keyCnt++;
                    cnt = 0;
                }
                
                if(mapOfJobTicketMailShopFields.containsKey(keyCnt)) 
                {
                    mapOfJobTicketMailShopFields.get(keyCnt).add(sFSMS);     
                }
                else 
                {
                    mapOfJobTicketMailShopFields.put(keyCnt, new List<Schema.FieldSetMember>{sFSMS});        
                }
                cnt++;
            } 
        }
        else 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Error_Unable_Query_Job_Details ));
        }
    }
    
    private Map<String, Job_Print_Ticket_View_Manager__mdt> fetchComponentTypeBasedSettingsAndMappings() 
    { 
        Map<String, Job_Print_Ticket_View_Manager__mdt> mapOfComponentTypeBasedMappings = new Map<String, Job_Print_Ticket_View_Manager__mdt>();
        for(Job_Print_Ticket_View_Manager__mdt jobTicketManager : [SELECT Id, Component_Type__c, 
                                                                   Field_Sets__c, Columns__c, Location__c
                                                                   FROM Job_Print_Ticket_View_Manager__mdt
                                                                   WHERE Component_Type__c != null AND Component_Type__c != ''
                                                                   AND Columns__c != null AND Columns__c > 0 AND Location__c = 'Print'
                                                                  ]) 
        {
            mapOfComponentTypeBasedMappings.put(jobTicketManager.Component_Type__c, jobTicketManager);                                                                   
        }
        return mapOfComponentTypeBasedMappings;
    }
    
    private void fetchJobTicketMtMDetails() 
    {
        mapOfComponentTypeWithJobTicketMtMs = new Map<String, List<Job_Ticket_MtM__c>>();
        if(mapOfComponentTypeWithSettings != null && mapOfComponentTypeWithSettings.values().size() > 0) 
        {
            Set<String> setOfComponentTypes = new Set<String>();
            for(Job_Ticket_MtM__c jTM : [SELECT Id, Job_Ticket_Component__c, 
                                         Job_Ticket_Component__r.Component__c,
                                         Back_of_Colors__c, Front_of_Colors__c, Back_Colors_PMS__c, Front_Colors_PMS__c
                                         FROM Job_Ticket_MtM__c
                                         WHERE Job_Ticket__c =: jobTicket.Id
                                         AND Job_Ticket_Component__c != null
                                         AND Job_Ticket_Component__r.Component__c != null
                                         ORDER By Name ASC
                                        ]
               ) 
            {
                setOfComponentTypes.add(jTM.Job_Ticket_Component__r.Component__c);           
            }
            if(setOfComponentTypes.size() > 0) 
            {
                List<Schema.FieldSetMember> listOfFieldSetMembers = new List<Schema.FieldSetMember>();
                Map<String, List<Schema.FieldSetMember>> mapOfComponentTypeAndFieldSetDetails = new Map<String, List<Schema.FieldSetMember>>();
                for(String componentType : mapOfComponentTypeWithSettings.keySet()) 
                {
                    if(setOfComponentTypes.contains(componentType)) 
                    {
                        listOfFieldSetMembers.addAll(getJobTicketMTMFields(mapOfComponentTypeWithSettings.get(componentType).Field_Sets__c));    
                        mapOfComponentTypeAndFieldSetDetails.put(componentType, getJobTicketMTMFields(mapOfComponentTypeWithSettings.get(componentType).Field_Sets__c));
                    }
                }
                if(listOfFieldSetMembers.size() > 0) 
                {
                    populateCollectionWithMtMDetails(listOfFieldSetMembers);
                    populateMapOfTypeAndFieldSetDetails(mapOfComponentTypeAndFieldSetDetails);
                }
            }
        }
        else 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, System.Label.Error_Component_Type_Mapping_Doesnt_Exists ));
        }
    }
    
    private void populateCollectionWithMtMDetails(List<Schema.FieldSetMember> listOfFieldSetMembers) 
    {
        String jobTicketId = jobTicket.Id;
        String whereClause = 'WHERE Job_Ticket__c =:jobTicketId AND Job_Ticket_Component__c != null AND Job_Ticket_Component__r.Component__c != null';
        String orderBy = 'ORDER BY Name ASC ';
        String jobTicketMtMQuery = DatabaseUtilities.getFieldsetQuery('Job_Ticket_MtM__c', listOfFieldSetMembers, 
                                                                      new List<String>{'Job_Ticket_Component__c', 'Name', 'Job_Ticket__c', 'Job_Ticket_Component__r.Component__c', 'Back_of_Colors__c', 'Front_of_Colors__c', 'Back_Colors_PMS__c', 'Front_Colors_PMS__c'}, 
                                                                      whereClause, orderBy, null, true);
        for (sObject queriedObject : Database.query(jobTicketMtMQuery)) 
        {
            Job_Ticket_MtM__c jTMtM = (Job_Ticket_MtM__c)queriedObject;
            if(mapOfComponentTypeWithJobTicketMtMs.containsKey(jTMtM.Job_Ticket_Component__r.Component__c)) 
            {
                mapOfComponentTypeWithJobTicketMtMs.get(jTMtM.Job_Ticket_Component__r.Component__c).add(jTMtM);     
            }
            else 
            {
                mapOfComponentTypeWithJobTicketMtMs.put(jTMtM.Job_Ticket_Component__r.Component__c, new List<Job_Ticket_MtM__c>{jTMtM});        
            }
        }    
    }
    
    private void populateMapOfTypeAndFieldSetDetails(Map<String, List<Schema.FieldSetMember>> mapOfTypeAndFieldSetDetails) 
    {
        mapOfComponentTypeWithFieldSetDetails = new Map<String, List<List<Schema.FieldSetMember>>>();
        for(String cType : mapOfTypeAndFieldSetDetails.keySet()) 
        {
            List<List<Schema.FieldSetMember>> partitionedFieldSetMembersRecordsList = new List<List<Schema.FieldSetMember>>{new list<Schema.FieldSetMember>()};
            
            List<Schema.FieldSetMember> fieldSetMembers;
            integer iteration = 0;
            integer partitionSize = 0;
            Schema.FieldSetMember fieldSetMember;
            
            for(integer i = 0; i < mapOfTypeAndFieldSetDetails.get(cType).size(); i++) 
            {
                if(partitionSize == mapOfComponentTypeWithSettings.get(cType).Columns__c) 
                {
                    partitionedFieldSetMembersRecordsList.add(new list<Schema.FieldSetMember>());
                    iteration += 1;
                    partitionSize = 0;
                }
                fieldSetMember = mapOfTypeAndFieldSetDetails.get(cType)[i];
                partitionedFieldSetMembersRecordsList[iteration].add(fieldSetMember);
                partitionSize++;
            }
            mapOfComponentTypeWithFieldSetDetails.put(cType, partitionedFieldSetMembersRecordsList);
        }
    }
   
    //Modified - Neha Sharma- 08/07/2021 - CR-20201218-14754 - Added the method to get the current user time zone
    public void getUserTimeZone(){
        String userTimeZone = UserInfo.getTimeZone().getID();
        Datetime dateTimeInGMT=System.now();
        dateTimeUserContext =dateTimeInGMT.format('MM/dd/yyyy HH:mm a',userTimeZone); 
    }
}