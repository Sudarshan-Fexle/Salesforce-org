/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=false)
private class Test_LeadTrigger {

/**
 *  Purpose         :   Test class for Lead trigger
 *
 *  Created By      :   Bhavi Sharma    
 *
 *  Created Date    :   01/31/2014  
 *
 *  Revision Logs   :   V_1.0 - Created
 *                  :   V_1.1 - Ajit Surana - 4/30/2014 - CR-20140409-5021 - testCopyAddressToContactOnConversion method modified.
 *
 *  Coverage        :   
 *
 **/
    
    static testMethod void testCopyAddressToContactOnConversion() {
        
        //Create Test data for Lead
        Lead lead = new Lead(LastName = 'Testing', Company = 'Testing', Address_Line_1__c = 'Testing 604', City__c = 'Dallas', 
                             State_Province__c = 'CA', Country__c = 'USA', Postal_Code__c = '12345', 
                             Email =  'Test'+Math.random()+'@eab.com', Phone='Test');
        insert lead;
        
        //Convert lead record
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead.Id);
        
        //Setting lead converted status
        lc.setConvertedStatus('Vetted');
        
        //Start Testing from here
        Test.startTest();
        
        try{
            
            //Convert Lead Record
            Database.LeadConvertResult lCR = Database.convertLead(lc);
            
            //Assret resultd
            System.assert(lCR.isSuccess());
            
            //Fetch lead information
            lead = [Select IsConverted, ConvertedContactId, Address_Line_1__c, City__c, State_Province__c, Country__c, Postal_Code__c from Lead where Id =: lead.Id];
            
            //Assert for the results
            System.assert(lead.IsConverted);
            System.assert(lead.ConvertedContactId != null);
            
            //Fetch contact data and assert for the address variables
            Contact contact = [Select Primary_Address_Line_1__c, Primary_City__c, Primary_State_Province__c, Primary_Country__c, 
                               Primary_Postal_Code__c from Contact where Id =: lead.ConvertedContactId];
            System.assertEquals(lead.Address_Line_1__c, contact.Primary_Address_Line_1__c);
            System.assertEquals(lead.City__c, contact.Primary_City__c);
            System.assertEquals(lead.State_Province__c, contact.Primary_State_Province__c);
            System.assertEquals(lead.Country__c, contact.Primary_Country__c);
            System.assertEquals(lead.Postal_Code__c, contact.Primary_Postal_Code__c);
            
            //Stop test here
            Test.stopTest();
            
            //Added by Ajit Surana - 4/30/2014 - CR-20140409-5021
            //Create Test data for Lead passing "null" for Address_Line_1__c and Postal_Code__c fields
            Lead testLead = new Lead(LastName = 'Test', Company = 'Test Account', Address_Line_1__c = null, City__c = 'Dallas', 
                                     State_Province__c = 'CA', Country__c = 'USA', Postal_Code__c = null);
            insert testLead;
            
            //Convert lead record
            Database.LeadConvert lc1 = new Database.LeadConvert();
            lc1.setLeadId(testLead.Id);
            lc1.setConvertedStatus('Vetted');
            
            //Convert Lead Record
            Database.LeadConvertResult lCR1 = Database.convertLead(lc1);
            
            //Assert resultd
            System.assert(lCR1.isSuccess());
            
            //Fetch lead information
            testLead = [Select IsConverted, ConvertedContactId, Address_Line_1__c, City__c, State_Province__c, Country__c, Postal_Code__c from Lead where Id =: testLead.Id];
            
            //Assert for the results
            System.assert(testLead.IsConverted);
            System.assert(testLead.ConvertedContactId != null);
            
            //Fetch contact data and assert for the address variables
            Contact contact1 = [Select Primary_Address_Line_1__c, Primary_City__c, Primary_State_Province__c, Primary_Country__c, 
                                Primary_Postal_Code__c from Contact where Id =: testLead.ConvertedContactId];
            
            //Assert for the resuts
            System.assertEquals(null, contact1.Primary_Address_Line_1__c);
            System.assertEquals(testLead.City__c, contact1.Primary_City__c);
            System.assertEquals(testLead.State_Province__c, contact1.Primary_State_Province__c);
            System.assertEquals(testLead.Country__c, contact1.Primary_Country__c);
            System.assertEquals(null, contact1.Primary_Postal_Code__c);
            
        }catch(Exception e) {
            
        }
    }
    
    //Create Test data for Lead
    //Added by Seemu Saikia on 06/19/2019 to test LeadTriggerHelper.deleteProductLeadsandCampaignMembers()
    @isTest
    public static void testDeleteProductLeadsandCampaignMembers(){
        
        Lead lead = new Lead(LastName = 'TestingForDelete', Company = 'Testing', Address_Line_1__c = 'Testing 604', City__c = 'Dallas', 
                             State_Province__c = 'CA', Country__c = 'USA', Postal_Code__c = '12345');
        insert lead;
        
        Program__c programRec = new Program__c(Name ='testProgram',Create_memberships__c ='No',Marketable__c = true);
        insert programRec;
        
        Product_Lead__c pLead = new Product_Lead__c(Name='TestPlead',Program__c = programRec.Id,Lead__c=lead.id);
        insert pLead;
        
        Campaign testcamp = new Campaign(
            Name = 'Warm Lead Test',
            StartDate = system.today(),
            Type = 'Paid Event',
            Channel__c = 'Prospect Meeting'
        );
        insert testcamp;
        Contact con = new Contact(LastName = 'testcon',email='s@ss.com',phone='1255478896',title='VIP' );
        insert con;
        CampaignMember testcms = new CampaignMember(CampaignId = testcamp.id,Product_Lead__c = pLead.id,ContactID = con.id,Contact_Level__c = 'CXO',Status = 'Responded');
        insert testcms;
        test.startTest();
        
        Lead leadDelete = [Select id from lead where id =: lead.Id];
        delete leadDelete;
        
        List<Product_Lead__c> pLeadDeleted =[select id from Product_Lead__c where Lead__c =: leadDelete.id];
        system.assertEquals(0, pLeadDeleted.size());
        
        List<CampaignMember> campDeleted = [SELECT CampaignId from CampaignMember where Product_Lead__c =: pLead.id];
        system.assertEquals(0, campDeleted.size());
 
    }
    
    /**
    *  Purpose         :   Test method for CopyAcquisitionfieldToContactOnConversion method of LeadTriggerHelper
    *
    *  Revision Logs   :   Created By - Neha Sharma - 05/18/2021 - CR-20181203-12773 - testCopyAcquisitionfieldToContactOnConversion method created
    *
    *  Coverage        :   
    *
    **/
    static testMethod void testCopyAcquisitionfieldToContactOnConversion() {
        
        //Bypass trigger
        util.BypassAllTriggers = true;
        //create contact to merge lead
       	Contact contact = TestUtilities.CreateNewContact(true);
        
        //Create Test data for Lead 
        List<Lead> listOfLeads = new List<Lead>();
        Lead testLead = new Lead(LastName = 'Test Lead 1', Company = 'Test Account1', mkto_Acquisition_Date__c = System.today(), 
                                 mkto_Acquisition_Program__c = 'Test Prog');
        listOfLeads.add(testLead);
        
        testLead = new Lead(LastName = 'Test Lead 2', Company = 'Test Account2', mkto_Acquisition_Date__c = System.today(), 
                                 mkto_Acquisition_Program__c = 'Test Prog1');
        listOfLeads.add(testLead);
        
        insert listOfLeads;
        
        util.BypassAllTriggers = false;
        
        test.startTest();
        
        List<Database.LeadConvert> leadsForConvertion = new List<Database.LeadConvert>();
        
        //Convert lead record - it's going to create new Contact
        Database.LeadConvert lc1 = new Database.LeadConvert();
        lc1.setLeadId(listOfLeads[0].Id);
        lc1.setConvertedStatus('Vetted');
        lc1.setDoNotCreateOpportunity(true);
        leadsForConvertion.add(lc1);
        
        //Convert lead record - it's going to merge in a Contact
        Database.LeadConvert lc2 = new Database.LeadConvert();
        lc2.setLeadId(listOfLeads[1].Id);
        lc2.setConvertedStatus('Vetted');
        lc2.setContactId(contact.Id);
        lc2.setAccountId(contact.AccountId);
        lc2.setDoNotCreateOpportunity(true);
        leadsForConvertion.add(lc2);
        
        //Convert Lead Record
        List<Database.LeadConvertResult> leadConvertResult = Database.convertLead(leadsForConvertion);
        
        //Assert to check both leads are converted
        System.assert(leadConvertResult[0].isSuccess());
        System.assert(leadConvertResult[1].isSuccess());
        
        //hold contact Ids
        Set<Id> contactIds = new Set<Id>{leadConvertResult[0].getContactId(), leadConvertResult[1].getContactId()};
            
        //Fetch updated Contact information
        List<Contact> contacts = [Select mkto_Acquisition_Date__c,mkto_Acquisition_Program__c,Converted_From_Lead__c 
                                  from Contact where Id IN: contactIds];
        
        //Assert for the results
        System.assertEquals(null, contacts[0].mkto_Acquisition_Date__c);
        System.assertEquals(null, contacts[0].mkto_Acquisition_Program__c);
        
        System.assertEquals(listOfLeads[0].mkto_Acquisition_Date__c , contacts[1].mkto_Acquisition_Date__c);
        System.assertEquals(listOfLeads[0].mkto_Acquisition_Program__c , contacts[1].mkto_Acquisition_Program__c);
        
        test.stopTest();
        
    }
    
   /**
    *  Purpose         :   Test method for UpdateContactToVetStatusOnPdLead method of LeadTriggerHelper
    *
    *  Revision Logs   :   Created By - Neha Sharma - 09/02/2021 - CR-20201029-14644 - testUpdateContactToVetStatusOnPdLead method created
    *
    *  Coverage        :   
    *
    **/
    static testMethod void testUpdateContactToVetStatusOnPdLead() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
	
        //Bypass trigger
        util.BypassAllTriggers = true;
        
        //create contact to merge lead
       	Contact contact = TestUtilities.CreateNewContact(true);
        
        //create program
        Program__c programRec = new Program__c( Name = 'testprog', Program_Acronym__c = 'TEST', Status__c = 'Active', 
            									Create_Memberships__c = 'Yes',Marketable__c = true);
        insert programRec;
        
        //Create Test data for Lead 
        List<Lead> listOfLeads = new List<Lead>();
        Lead testLead = new Lead(LastName = 'Test Lead 1', Company = 'Test Account1',Status = 'Open',
                                 FirstName = 'Test 1', LeadSource = 'Webinar');
        listOfLeads.add(testLead);
        
        testLead = new Lead(LastName = 'Test Lead 2', Company = 'Test Account2',Status = 'Open',
                           FirstName = 'Test 2', LeadSource = 'Webinar');
        listOfLeads.add(testLead);
        
        //insert leads 
        insert listOfLeads;
        
        //Inserting product leads
        List<Product_Lead__c> pLeads = new List<Product_Lead__c>();
        pLeads.add(new product_lead__c (Name = 'Test 1',Contact__c = contact.Id,
                                                 Program__c = programRec.Id,
                                                 Stage__c = 'AQL', Action__c = 'Accept - Promote to TGL'));

        pLeads.add(new product_lead__c (Name = 'Test 2',Contact__c = contact.Id,
                                                 Program__c = programRec.Id,
                                                 Stage__c = 'AQL', Action__c = 'Accept - Promote to TGL'));
        
        insert pLeads;       
        //ProductLead Records
        pLeads = [Select Name, Stage__c from Product_Lead__c ORDER BY Name ASC];
        pLeads[0].Stage__c = 'AQL';
        pLeads[1].Stage__c = 'AQL';
        update pLeads;

        //Add Leads to product lead
        pLeads = [Select Lead__c from Product_Lead__c ORDER BY Name ASC];
        pLeads[0].Lead__c = listOfLeads[0].Id;
        pLeads[1].Lead__c = listOfLeads[1].Id;
        update pLeads;
        
        //Create our Custom Setting Data
		Marketo_API_Config__c customSetting = new Marketo_API_Config__c();
		customSetting.Client_ID__c = '0f284101-02d9-41e4-8681-7c3b2078f17d';
		customSetting.Client_Secret__c = 'VyqtUpzUdK1BWEEDpMbLzwccSbrdsn66';
		customSetting.Endpoint__c = 'https://633-BTQ-665.mktorest.com/';
		customSetting.Marketo_Upsert_URL__c = 'https://633-BTQ-665.mktorest.com/rest/v1/leads.json?access_token=';
		customSetting.Marketo_Identity_Endpoint__c = 'https://633-BTQ-665.mktorest.com/identity/oauth/token?grant_type=client_credentials&client_id=';
		insert customSetting;
        
        //Test start from here 
        Test.startTest();
        //Get lead records
        listOfLeads = [Select Id, Status From Lead ORDER BY Company ASC];
        listOfLeads[0].Status = 'Disqualified';
        listOfLeads[1].Status = 'Disqualified';
		listOfLeads[0].Disqualification_Reason__c = 'Contact longer at institution';
		listOfLeads[1].Disqualification_Reason__c = 'Contact longer at institution';
        
		util.BypassAllTriggers = false;
        
        //update leads
        update listOfLeads;
		
		util.BypassAllTriggers = true;
        pLeads = [Select Id, Stage__c, Contact_to_Vet_Status__c From Product_Lead__c ORDER BY Name ASC limit 2];
        
        system.assertEquals('Disqualified', pLeads[0].Contact_to_Vet_Status__c);
        system.assertEquals('Disqualified', pLeads[1].Contact_to_Vet_Status__c);
        //Test stop here
        Test.stopTest();
    }
}