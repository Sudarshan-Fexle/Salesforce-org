global class Batch_Memberships implements Database.Batchable<sObject>, Database.Stateful {

	public String csvString = 'Membership Id' + ',' + 'Membership Name' + ',' + 'Join Date-Most Recent' + ',' + 'Latest Subscription Join Date' + ',' + 'Latest Contract Join Date'+ ',' +  '\n';

	global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator([Select Id, Name, Join_Date_Most_Recent__c, Latest_Subscription__c, Latest_Contract__c, 
        								 Latest_Subscription__r.Join_Date__c, Latest_Contract__r.Join_Date__c From Membership__c 
        								 Where ((Latest_Subscription__c != null AND Latest_Subscription__r.Join_Date__c != null) 
        								 OR (Latest_Contract__c != null AND Latest_Contract__r.Join_Date__c != null))]);   
    }
	
	global void execute(Database.BatchableContext BC, List<Membership__c> memberships){ 								
									
		for(Membership__c mem : memberships) {
		 
			if(mem.Latest_Subscription__c != null) {
			
				if( mem.Latest_Subscription__r.Join_Date__c != null && mem.Join_Date_Most_Recent__c != mem.Latest_Subscription__r.Join_Date__c)

					csvString += mem.Id + ',' + mem.Name + ',' + mem.Join_Date_Most_Recent__c + ',' + mem.Latest_Subscription__r.Join_Date__c
							+ ',' + '' + ','+ '\n';
							
			} else if(mem.Latest_Contract__c != null && mem.Latest_Contract__r.Join_Date__c != null 
				&& mem.Join_Date_Most_Recent__c != mem.Latest_Contract__r.Join_Date__c) {
				
				csvString += mem.Id + ',' + mem.Name + ',' + mem.Join_Date_Most_Recent__c + ',' + '' +
							+ ',' + mem.Latest_Contract__r.Join_Date__c + '\n';
			}
		}	
	}
		
	global void finish(Database.BatchableContext BC){
        
         Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
		blob csvBlob = Blob.valueOf(csvString);
		string csvname= 'Memberships.csv';
		csvAttc.setFileName(csvname);
		csvAttc.setBody(csvBlob);
		Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
		String[] toAddresses = new list<string> {'subhash.garhwal@briskminds.com'};
		String subject ='Membership Records';
		email.setSubject(subject);
		email.setToAddresses( toAddresses );
		email.setPlainTextBody('Hi Subhsah, Please find the comparison list attached. Thanks! ');
		email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
		Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
	}
}