@isTest
public class slack_tst_CPQ_Exception_Request {
	@isTest 
	static void testTrigger() {
		CPQ_Exception_Request__c obj0 = new CPQ_Exception_Request__c();
        obj0.Status__c = 'Draft';
		insert obj0;
	}
}