@isTest(SeeAllData=true)
    private class Test_Transaction {

    static testMethod void test1() {
           List<c2g__codaTransaction__c> t = [Select Id from c2g__codaTransaction__c limit 1];
                update t;
        
        	
        	//Added By Rajeev Jain To increase the Coverage of Transaction Trigger helper - CR-20180426-12185 - 04/27/2018
         	List<c2g__codaTransaction__c> t1 = [Select Id from c2g__codaTransaction__c Where CINV__c != null limit 1];
                
        	t1[0].CINV__c = 'Test';
        	update t1;
        
        	t1[0].CINV_ID__c = null;
        	update t1;
    }
}