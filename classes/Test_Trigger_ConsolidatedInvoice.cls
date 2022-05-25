/*
    Purpose         :   Test class for Trigger_ConsolidatedInvoice
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   24/06/2015
    
    Current Version :   V1.0
    
    Revision Log    :   V1.0 - Created for CR-20150416-8890 -06/24/2015 
*/
@IsTest(SeeAllData=false)
public class Test_Trigger_ConsolidatedInvoice {
    
    //Created for CR-20150416-8890 -06/24/2015
    //test method to test that the values from activities(Task) histories are in sync.
    static testmethod void test_syncValuesFromActivityHistories() {
        
        //Bypassing all triggers
		Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        //Query through RecordType for Account record type
        RecordType accountRecordType = [SELECT Id , DeveloperName FROM recordType WHERE DeveloperName = 'US_Corporate' AND SobjectType = 'Account' ];
        
        //Query through RecordType for Contact record type
        RecordType contactRecordType = [SELECT Id , DeveloperName FROM recordType WHERE DeveloperName = 'External' AND SobjectType = 'Contact'];
        
        //Query through RecordType for Activities(Task) record type
        RecordType taskRecordType = [SELECT Id , DeveloperName FROM recordType WHERE DeveloperName = 'General' AND SobjectType = 'Task'];
        
        //Account 
        Account acc = new Account(Name = 'TestAccount', RecordTypeId = accountRecordType.Id, Status__c = 'Active');
        
        //Insert account
        insert acc;
        
        //Contact
        Contact con = new Contact(RecordTypeId = contactRecordType.Id, LastName = 'testLastName', AccountId = acc.Id, Asst_Email__c = 'test@test.com', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        
        //Insert Contact
        insert con;
        
        //Consolidated Invoice
        ConsolidatedInvoice__c conInvoice = new ConsolidatedInvoice__c(InvoiceContactLookup__c = con.Id );
        
        //Insert Consolidated Invoice
        insert conInvoice;    
        
        //Profile    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      
		//User
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                        	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                        	LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                        	TimeZoneSidKey='GMT', UserName=Math.random() + '@test.com');
        //Insert User
        insert u;
		
        //Run in User u context
        System.runAs(u){
            
            //List of Task Activities
            List<Task> tasks = new List<Task>();
            
            //Populate the list
            tasks.add(new Task(OwnerId = u.Id, Subject = 'Test1', Status = 'Completed', Priority = 'Normal', WhatId = conInvoice.Id ));
            tasks.add(new Task(OwnerId = u.Id, Subject = 'Test2', Status = 'In Progress', Priority = 'Normal', WhatId = conInvoice.Id ));
            
            //Insert Tasks
            insert tasks;
            
            //Query through Consolidated Invoices
            ConsolidatedInvoice__c conInvoice1 = [SELECT Id, Last_Follow_Up_Date__c , Last_Follow_Up_Note__c FROM ConsolidatedInvoice__c WHERE Id =: conInvoice.Id];
            
			//Asserts for results
			System.assertEquals(null, conInvoice1.Last_Follow_Up_Date__c);
            System.assertEquals(null, conInvoice1.Last_Follow_Up_Note__c);
            
            //Enable all triggers
			Util.byPassAllTriggers = false;
        
            //Start test
            Test.startTest();
            
            //Update Consolidated Invoices
            update conInvoice;
            
            //Stop test
            Test.stopTest();
        }
    }
}