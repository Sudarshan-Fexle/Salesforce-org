/**
 * 	@Description	:	Test class for Batch_NightlyBizzaboRegistrationAPICall
 * 
 *  @Created By		:	Saurabh Kumar 
 * 
 *  @Created Date	:	10/24/2020
 * 
 *  @Revision Log	:	V1.0 CR-20201022-14631 - Created
 * 			:	V1.1 CR-20200819-14449 - 12/17/2020 - Updated by Saurabh Kumar: Removed the meeting reference.
 * */
@isTest(SeeAllData = false)
private class Test_BatchNightlyBizzaboRegistrationAPI {
    
    private static testMethod void doNothing(){}
    /*
    @testSetup static void setup() {
         
         Account account = new Account(Name = 'Test Acc');
         insert account;
         
         //create Contacts
        List<Contact> contacts = new List<Contact>();
         
        Contact retContact = new Contact();
        retContact.FirstName = 'Joe';
        retContact.LastName = 'Thomas-' + Crypto.getRandomInteger();
      
        retContact.AccountId = account.id;
        retContact.Is_Ignore_Phrase_Characters__c = true;
        retContact.Primary_Address_Line_1__c = '123 main st';
        retContact.Primary_City__c = 'Columbus';
        retContact.Primary_State_Province__c = 'OH';
        retContact.Primary_Postal_Code__c = '43235';
        retContact.Title = 'CEO';
        retContact.Email = 'testuser2175436032@eab.com';
        retContact.Phone = '614-555-8855';
        retContact.Contact_Status__c = 'Active';
         
        contacts.add(retContact);
        
        retContact = new Contact();
        retContact.FirstName = 'Sue';
        retContact.LastName = 'Thomas-' + Crypto.getRandomInteger();
      
        retContact.AccountId = account.id;
        retContact.Is_Ignore_Phrase_Characters__c = true;
        retContact.Primary_Address_Line_1__c = '123 main st';
        retContact.Primary_City__c = 'Columbus';
        retContact.Primary_State_Province__c = 'OH';
        retContact.Primary_Postal_Code__c = '43235';
        retContact.Title = 'CEO';
        retContact.Email = 'testuser21537293601@eab.com';
        retContact.Phone = '614-555-8855';
        retContact.Contact_Status__c = 'Active';
        contacts.add(retContact);
        
        retContact = new Contact();
        retContact.FirstName = 'Kett';
        retContact.LastName = 'Thomas-' + Crypto.getRandomInteger();
      
        retContact.AccountId = account.id;
        retContact.Is_Ignore_Phrase_Characters__c = true;
        retContact.Primary_Address_Line_1__c = '123 main st';
        retContact.Primary_City__c = 'Columbus';
        retContact.Primary_State_Province__c = 'OH';
        retContact.Primary_Postal_Code__c = '43235';
        retContact.Title = 'CEO';
        retContact.Email = 'testuser2175436033@eab.com';
        retContact.Phone = '614-555-8855';
        retContact.Contact_Status__c = 'Active';
        contacts.add(retContact);
        
        retContact = new Contact();
        retContact.FirstName = 'Matt';
        retContact.LastName = 'Thomas-' + Crypto.getRandomInteger();
      
        retContact.AccountId = account.id;
        retContact.Is_Ignore_Phrase_Characters__c = true;
        retContact.Primary_Address_Line_1__c = '123 main st';
        retContact.Primary_City__c = 'Columbus';
        retContact.Primary_State_Province__c = 'OH';
        retContact.Primary_Postal_Code__c = '43235';
        retContact.Title = 'CEO';
        retContact.Email = 'testuser2175436034@eab.com';
        retContact.Phone = '614-555-8855';
        retContact.Contact_Status__c = 'Active';
        contacts.add(retContact);
         
        retContact = new Contact();
        retContact.FirstName = 'Stephen';
        retContact.LastName = 'Thomas-' + Crypto.getRandomInteger();
      
        retContact.AccountId = account.id;
        retContact.Is_Ignore_Phrase_Characters__c = true;
        retContact.Primary_Address_Line_1__c = '123 main st';
        retContact.Primary_City__c = 'Columbus';
        retContact.Primary_State_Province__c = 'OH';
        retContact.Primary_Postal_Code__c = '43235';
        retContact.Title = 'CEO';
        retContact.Email = 'testuser2175436034@eab.com';
        retContact.Phone = '614-555-8855';
        retContact.Contact_Status__c = 'Active';
        contacts.add(retContact);
        insert contacts;
         
        //Create the new Registration record
        Registration__c registration = new Registration__c();
        registration.Contact__c = contacts[0].Id;
        insert registration;
   		
        Advisory_Event__c eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        eabEvent.Bizzabo_Event_ID__c = '240888';
        insert eabEvent;
         
        Meeting__c meeting  = new Meeting__c(Name = 'Test', EAB_Event__c = eabEvent.Id);
        insert meeting;
         
        Meeting__c childMeeting  = new Meeting__c(Parent_Meeting__c = meeting.Id,Name = 'Test', EAB_Event__c = eabEvent.Id);
        insert childMeeting;
         
        registration.Meeting__c = childMeeting.Id;
        update registration;
         
     }
    //To hit Registration API call to Bizzabo and get Registration records.
    static testMethod void testCallBatch() {
        Test.startTest();
        
        Integer emailbefore = Limits.getEmailInvocations();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseRegistrationAPICall());
        Batch_NightlyBizzaboRegistrationAPICall  batchBizzaboRegistrationAPICall = new Batch_NightlyBizzaboRegistrationAPICall();
        String asyncId = Database.executeBatch(batchBizzaboRegistrationAPICall, 200);
        System.assert(asyncId != null);
        
        //Get Meeting record
        Meeting__c meeting = [Select Id, Name From Meeting__c Where Parent_Meeting__r.EAB_Event__r.Bizzabo_Event_ID__c = '240888'];
        Database.executeBatch(new Batch_NightlyBizzaboRegistrationAPICall('?eventId=240888&size=200&page=0', meeting.Id));

        Test.stopTest();
        
        List<Registration__c> registrations = [Select Meeting__c, Id, Name, Contact__c, Contact__r.Email From Registration__c];
        System.assertEquals(3, registrations.size());
        
        Set<String> contactEmails = new Set<String>();
        for(Registration__c reg : registrations)
            contactEmails.add(reg.Contact__r.Email);
        
        System.assert(registrations.size() == contactEmails.size());
        
        System.schedule('Batch_NightlyBizzaboRegistrationAPICall', '0 0 0/2 1/1 * ? *', new Batch_NightlyBizzaboRegistrationAPICall());
    }*/
}