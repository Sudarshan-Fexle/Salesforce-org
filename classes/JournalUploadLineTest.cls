@isTest
private class JournalUploadLineTest
{
	@isTest
	static void testPopulateGlaAndDim1Lookups()
	{
		// Given
		// A GL Account and a Dimension 1 record
		c2g__codaGeneralLedgerAccount__c testGla = new c2g__codaGeneralLedgerAccount__c(
			c2g__ReportingCode__c = '5400',
			Name = '5400 - PRINTING/ARTWORK',
			c2g__Type__c = 'Profit and Loss',
			c2g__TrialBalance1__c = 'Profit and Loss',
			c2g__TrialBalance2__c = 'Operating Expenses'
		);
		insert testGla;
		c2g__codaDimension1__c testCc = new c2g__codaDimension1__c(
			Name = '03-300-00 - H*Works Revenue Cycle',
			c2g__ReportingCode__c = '03-300-00'
		);
		insert testCc;
		// And
		// A Journal Upload Line with Cost Center and GLA text fields filled in
		Journal_Batch_Header__c testJbh = new Journal_Batch_Header__c();
		insert testJbh;
		Journal_Upload_Lines__c testJul = new Journal_Upload_Lines__c(
			Journal_Batch_Header__c = testJbh.Id,
			Cost_Center__c = '03-300-00',
			General_Ledger_Account__c = '5400'
		);

		// When
		// I insert the Journal Upload Line
		insert testJul;

		// Then
		// The Cost Center and General Ledger Account lookups are populated.
		testJul = [select Dimension_1_Full__c, General_Ledger_Account_Full__c from Journal_Upload_Lines__c where id = :testJul.Id];
		System.assertEquals(testGla.Id, testJul.General_Ledger_Account_Full__c, 'GLA lookup should have been populated');
		System.assertEquals(testcc.Id, testJul.Dimension_1_Full__c, 'Cost Center lookup should have been populated');
	}
}