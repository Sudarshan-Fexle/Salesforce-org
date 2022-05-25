/**
 *  Purpose         :   Test methods for the Batch_ProposalGradeUpdate class
 *
 *  Created By      :   Victor Hanson
 *
 *  Created Date    :   04/26/2018
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/ 
@isTest
public class Test_Batch_ProposalGradeUpdate {
	
    /**
     *
     *   @description    :   Creates a Proposal and Grade Criteria, then updates the Grade Criteria to
     * 			     verify the proposal's Execute Price Rules field gets updated
     *
     *   @revision Log   :   V_1.0 - Created - Victor Hanson - 04/28/2018
     *                       V_1.1 - Updated - Prateek Pant  - 10/12/2021 - CR-20211012-15511
     *
     **/
    static testmethod void testProposalGradeUpdate() {
        // CR-20211012-15511 - Start
        //Bypass Dupeblocker     
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        // insert account
        Account acc = TestUtilities.CreateNewAccount(true);
        System.assert(acc.Id != null);
        
        // insert opportunity.
        Opportunity opp = TestUtilities.CreateNewOpportunity(acc.Id, false);
        opp.SBQQ__Contracted__c = false;
        opp.CreatedDate = date.today()-5;
        insert opp;
        System.assert(opp.Id != null);
        
        //add a new quote
        SBQQ__Quote__c proposal = TestUtilities.createNewSbqqQuote(false);
        proposal.SBQQ__Primary__c = true;
        proposal.SBQQ__Opportunity2__c = opp.Id;
        insert proposal;
        // CR-20211012-15511 - End
        
        //get the newly inserted proposal, and make sure execute price rules is false
        proposal = [SELECT Id, Execute_Price_Rules__c FROM SBQQ__Quote__c WHERE Id = :proposal.Id];
        system.assertEquals(false, proposal.Execute_Price_Rules__c);
        
        //create a Custom Lookup Data record (record type = Grade Criteria)
        Custom_Lookup_Data__c customLookup = new Custom_Lookup_Data__c(name = 'test name',
                                                                      RecordTypeId = CustomLookupDataTriggerHelper.GRADE_CRITERIA_RT_ID);
        
        Util.BypassAllTriggers = false;
        insert customLookup;
        
        test.startTest();
        
        //update the customLookupData record, which will trigger the batch to execute
        customLookup.Name = '5% Test';
        update customLookup;
        
        test.stopTest();
        
        //get the newly inserted proposal, and make sure execute price rules is true, because the batch job executed
        proposal = [SELECT Id, Execute_Price_Rules__c FROM SBQQ__Quote__c WHERE Id = :proposal.Id];
        customLookup = [SELECT Id, URL_Encoded_Name__c FROM Custom_Lookup_Data__c WHERE Id = :customLookup.Id];
        system.assertEquals('5%25%20Test', customLookup.URL_Encoded_Name__c);
        //system.assertEquals(true, proposal.Execute_Price_Rules__c);
    }
}