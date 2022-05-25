/*
    Purpose         :   Utility class with methods to assist with unit test data creation.
                
    Create By       :   Dipesh Gupta
    
    Created Date    :   12/02/2019      
    
    Revision Log    :   V1.0 Created
    		    :   V_1.1 - Modified By - Dipesh Gupta to Change the reference of Es Campaign to the Project. Issue--CR13887--QA--00009627 (CR-20200325-13887)
		    :   V_1.2 - Modified By - Abhinav Sharma - 02/05/2021 - CR-20210108-14792 - JT Component field and record updates
    		    :   V_1.3 - Modified by - Shalu Sharma - 5/18/21 - CR-20210315-14997 - Update the "BRE" to "Reply Envelope (BRE/CRE)"
		    :   V_1.4 - Modified By - 04/30/2021 - CR-20210323-15016 - Neha Sharma - populate drop type
*/
public with sharing class PrintManagementTestDataFactory {

    // get the record type id for a given record type name
    public static Id FindRecordTypeId(String ObjectType, String recordTypeName) {
        Id recordTypeId;
        List<RecordType> recordTypes = [SELECT Name, Id, SobjectType FROM RecordType WHERE IsActive = true AND SobjectType = :ObjectType AND Name = :recordTypeName LIMIT 1];
        if (recordTypes.size() > 0)
            recordTypeId = recordTypes[0].Id;
        return recordTypeId;
    }
    
    public static ES_Campaign__c CreateNewESCampaign(boolean CreateAndInsert) {
        Id accountId = TestUtilities.CreateNewAccount(true).Id;
        Id userId = TestUtilities.createNewUser(true).Id;
        
        ES_Campaign__c esCampaign = new ES_Campaign__c();
        esCampaign.School__c = accountId;
        esCampaign.Fiscal_Year__c = '2020';
        esCampaign.Status__c = 'Open';
        esCampaign.Project_Manager__c = userId;
        if (CreateAndInsert)
            insert esCampaign;
            
        return esCampaign;
    }
    

    public static Project__c CreateNewProject(boolean CreateAndInsert) {
        
        Id accountId = TestUtilities.CreateNewAccount(true).Id;
        Id userId = TestUtilities.createNewUser(true).Id;
        //Modified -Abhinav Sharma-  02/10/2021- Using RecordType Name instead of Label
        String jobTicketRecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get('ES_Project').getRecordTypeId();
        Id programId = TestUtilities.CreateNewProgram(true).Id;
		
        //Modified  02/10/2020 - Fiscal_Year__c added
        Project__c project = new Project__c(Name = 'Test Project', Institution__c = accountId, Product__c = programId, RecordTypeId = jobTicketRecordTypeId,Fiscal_Year__c=String.valueOf(System.Today().year()));
        
        if (CreateAndInsert)
            insert project;
            
        return project;
    }
    

    public static Job_Ticket__c CreateNewJobTicket(boolean CreateAndInsert) {
        Id contactId = TestUtilities.CreateNewContact(true).Id;
        Id userId = TestUtilities.CreatenewUser(true).Id;
        //Id eSCampaignId = PrintManagementTestDataFactory.CreateNewESCampaign(true).Id;
        //Id projectId = PrintManagementTestDataFactory.CreateNewProject(true).Id;

        Job_Ticket__c jobTicket = new Job_Ticket__c();
        //jobTicket.ES_Campaign__c = eSCampaignId;
        //jobTicket.Project__c = projectId;
        jobTicket.Art_Director__c = userId;
        jobTicket.Status__c = 'Draft';
        jobTicket.Descriptive_Name__c = '### Test Record ###';
        jobTicket.Mail_Quantity__c = 20000;
        //04/30/2021 - CR-20210323-15016 - Neha Sharma - populate drop type
        jobTicket.Drop_Type__c = 'Pre Planned';
        
        if (CreateAndInsert)
            insert jobTicket;
            
        return jobTicket;
    }
    
    public static Job_Ticket_Component__c CreateNewJobTicketComponent(boolean CreateAndInsert) {
        
        Job_Ticket_Component__c jobTickectCompponent = new Job_Ticket_Component__c();
        jobTickectCompponent.Name = 'Test';
        //Modified By - Abhinav Sharma - 02/05/2021 - CR-20210108-14792 - JT Component field and record updates (Change Component value Brochure to Collateral and Size)
        jobTickectCompponent.Component__c = Label.Component_Type_Value;
        jobTickectCompponent.Paper_Type__c = '80# Gloss, Dull, Matte or Silk Text';
        jobTickectCompponent.Size__c = '9 x 11-1/2';
            
        if (CreateAndInsert)
            insert jobTickectCompponent;
            
        return jobTickectCompponent;
    }
    
    public static Job_Ticket_MtM__c CreateNewJobTicketMTM(boolean CreateAndInsert) {
        Id jobTicketId = PrintManagementTestDataFactory.CreateNewJobTicket(true).Id;
        Id jobTicketComponentId = PrintManagementTestDataFactory.CreateNewJobTicketComponent(true).Id;
        
        Job_Ticket_MtM__c jobTickectMTM = new Job_Ticket_MtM__c();
        jobTickectMTM.Job_Ticket__c = jobTicketId;
        jobTickectMTM.Job_Ticket_Component__c = jobTicketComponentId;
        //Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997
        jobTickectMTM.Component_Type__c = Constants.COMPONENT_TYPE_BRE;
            
        if (CreateAndInsert)
            insert jobTickectMTM;
            
        return jobTickectMTM;
    }
    
    public static Production_Tracking__c CreateNewFulFillmentTracking(boolean CreateAndInsert) {
        Id jobTicketId = PrintManagementTestDataFactory.CreateNewJobTicket(true).Id;
        
        Production_Tracking__c fulfillmentTracking = new Production_Tracking__c();
        fulfillmentTracking.Job_Ticket__c = jobTicketId;
        fulfillmentTracking.Status__c = 'Planned';
            
        if (CreateAndInsert)
            insert fulfillmentTracking;
            
        return fulfillmentTracking;
    }
    
    public static Vendor_Component_Pricing__c CreateNewVendorComponentPricing(boolean CreateAndInsert) {
        Id accountId = TestUtilities.CreateNewAccount(true).Id;
        Id jobTicketComponent = PrintManagementTestDataFactory.CreateNewJobTicketComponent(true).Id;
        
        Vendor_Component_Pricing__c vendorComponentPricing = new Vendor_Component_Pricing__c();
        vendorComponentPricing.Vendor__c = accountId;
        vendorComponentPricing.Job_Ticket_Component__c = jobTicketComponent;
        vendorComponentPricing.Pricing_in_place_for_this_Year__c = true;
            
        if (CreateAndInsert)
            insert vendorComponentPricing;
            
        return vendorComponentPricing;
    }
    
    
    public static Vendor_Pricing_Per_Unit__c CreateNewVendorPricingPerUnit(boolean CreateAndInsert) {
        Id accountId = TestUtilities.CreateNewAccount(true).Id;
        
        Vendor_Pricing_Per_Unit__c vendorPricingPerUnit = new Vendor_Pricing_Per_Unit__c();
        vendorPricingPerUnit.Quantity_Minimum__c = 100;
        vendorPricingPerUnit.Quantity_Maximum__c = 1000;
        //vendorPricingPerUnit.Price_Effective_Start_Date__c = 2019-07-01;
        //vendorPricingPerUnit.Price_Effective_End_Date__c = 2020-06-30;
            
        if (CreateAndInsert)
            insert vendorPricingPerUnit;
            
        return vendorPricingPerUnit;
    }
    
    
}