@isTest
public class slack_tst_Change_Request {
	@isTest 
	static void testTrigger() {
		SFDC_Change_Request__c obj0 = new SFDC_Change_Request__c(
			Title__c = 's'
		);
		insert obj0;
	}
}