/*
 *  Purpose         :   Apex Test class for CompetitorSelectionSiteController class related functionality
 *
 *  Create By       :   Ayush Gupta 
 *
 *  Created Date    :   10/06/2021
 *
 *  Revision Log    :   V_1.0 Created   - CR-20210824-15375

 **/
@isTest(seeAllData = false)
private class Test_CompetitorSelectionSiteController {
    	//V_1.1 Modify By - Mahendra Swarnkar - CR-20170424-10876 - 07/06/2017
    	// Added By - Mahendra - CR-20161128-10501 - 01/04/2017
	static testMethod void test_populateRollUpSummaryFields() {
		
        //Bypass all the triggers
        Util.BypassAllTriggers = true;
        
        List<RecordType> rtypes = [Select Name, Id From RecordType 
                                   where sObjectType='Account' and Name = 'US Education'];
                //Insert the Account record
                Account acc = new Account ( Name = 'Shift CRM',Status__c='Active',RecordTypeId = rtypes[0].Id);
                insert acc;
                
		Contact  con = new Contact ( LastName = 'Test Contact',Email='cmcgloin@eab.com',Title = 'Test',Phone = '614-555-8855');
                insert con;
		
                //Assert on results
                system.assert(acc != null);
                
                //Insert the Program package records
                List<Program_Package__c> progPackage= new List<Program_Package__c> ();
                progPackage.add(new Program_Package__c (Name = 'Test1', Account__c = acc.Id, Fiscal_Year__c = '2016', 
                					Client_Status_New__c = 'Committed',
                                                        RecordTypeId = Util.RecordTypeId(RoyallProgramTriggerHelper.PROGRAM_PACKAGE_OBJECT_API_NAME, RoyallProgramTriggerHelper.PROGRAM_PACKAGE_HD_RECORD_TYPE_LABEL)));
                progPackage.add(new Program_Package__c (Name = 'Test2', Account__c = acc.Id, Fiscal_Year__c = '2016', 
                					Client_Status_New__c = 'Committed',
                                                        RecordTypeId = Util.RecordTypeId(RoyallProgramTriggerHelper.PROGRAM_PACKAGE_OBJECT_API_NAME, 'Royall')));
                insert progPackage;
                
                //Commneted by Mahendra Swarnkar - 05/07/2020 - CR-20200218-13769
                //Querying for the details
                progPackage = [SELECT Id, Name, Total_Contracted_Travel_Cost_HD__c 
                               FROM Program_Package__c 
                               WHERE ID IN : progPackage ORDER BY Name ASC];
               
            
                //Insert the Program records
                List<Royall_Program__c> rPrograms = new List<Royall_Program__c> ();
                rPrograms.add(new Royall_Program__c ( Name = 'Test Program1', Program_Package__c = progPackage[1].Id, Target_Audience_New__c = 'Financial Aid Clients',
                					Campaign_New__c = 'Other', Type__c = 'Discount Allocation', Probability__c = 10,
                                                        Contract_Sent__c = Date.Today(), 
                                                        Proposal_Sent__c = Date.Today(), Billable_Travel__c = 20,
                                                        RecordTypeId = Util.RecordTypeId(RoyallProgramTriggerHelper.ROYALL_PROGRAM_OBJECT_API_NAME, 'Royall')));
            
                //Starts Test from here
        	Test.startTest();
        
        	PageReference myVfPage = Page.CompetitorSelectionSite;
        	Test.setCurrentPage(myVfPage);
        
        	// Put Id into the current page Parameters
        	ApexPages.currentPage().getParameters().put('parentId',progPackage[1].Id);
        
        	//Enable all the triggers
        	Util.BypassAllTriggers = false;
                
                //Insert Royall Programs
                insert rPrograms;
            
		List<Competitor_Selection__c> comp = new List<Competitor_Selection__c> ();
                comp.add(new Competitor_Selection__c (Competitor__c = acc.Id,Program_Royall_HD__c = rPrograms[0].Id,State__c='AV'));
        
        	insert comp;
                CompetitorSelectionSiteController cc = new CompetitorSelectionSiteController();
        	cc.getRoyallAndHDRecords();
        	cc.saveDocument();
               	test.stopTest();
                
            }
}