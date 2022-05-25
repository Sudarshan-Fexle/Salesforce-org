/**
*  Purpose         :   Test class for EmailSubscriptionTriggerHelper
*                
*  Created By      :   Dipesh Gupta - CR-20190107-12810
*   
*  Created Date    :   09/11/2019
*   
*  Revision Log    :   V1.0 - Created by - Dipesh Gupta - CR-20190107-12810 
*                      V1.1 - Modified By - Nikita Kumari - 06/17/2021 - CR-20210517-15150 - Run All test fixes
*          
*  Coverage        :   V1.0 - 85%
*          
**/
@isTest(SeeAllData = false) 
public class Test_EmailSubscriptionTriggerHelper {
    
    @testSetup static void setup() {
   
        //Start Test here
        test.startTest();
        //Modified By - Nikita Kumari - 06/17/2021 - CR-20210517-15150 - Run All test fixes
        Util.ByPassAllTriggers = true;
	
        //Create Test data for Lead
        Lead lead = new Lead(LastName = 'Testing', Company = 'Testing', Address_Line_1__c = 'Testing 604', City__c = 'Dallas', 
                             State_Province__c = 'CA', Country__c = 'USA', Postal_Code__c = '12345', 
                             Email =  'Test'+Math.random()+'@eab.com', Phone='Test');
        insert lead;
        
        //Create Test data for Account
        List<Account> acc = new List<Account>();
        acc.add(TestUtilities.CreateNewAccount(True));
        acc.add(TestUtilities.CreateNewAccount(True));
        
        //Create Test data for Contact
        List<Contact> con = new List<Contact>();
        con.add(TestUtilities.CreateNewContact(acc[0], True));
        con.add(TestUtilities.CreateNewContact(acc[1], True));
        
        //Create Test data for Program__c
        List<Program__c> program = new List<Program__c>();
        program.add(TestUtilities.CreateNewProgram(True));
        program.add(TestUtilities.CreateNewProgram(True));
        
        List<Membership__c> memberships = new List<Membership__c>(); 
        memberships.add(new Membership__c(Name = 'Test Membership One', Account_Name__c = acc[0].Id, Program__c = program[0].Id));
        memberships.add(new Membership__c(Name = 'Test Membership Two', Account_Name__c = acc[1].Id, Program__c = program[1].Id));         
        //insert membership record 
        insert memberships;
        
        //Modified By - Nikita Kumari - 06/17/2021 - CR-20210517-15150 - Run All test fixes
        Util.ByPassAllTriggers = false;
        
        List<Email_Subscription_Option__c> emailSubOption = new List<Email_Subscription_Option__c>();
        emailSubOption.add(new Email_Subscription_Option__c(Name = 'Test Email Subscription Option One ', Program__c = program[0].Id));
        emailSubOption.add(new Email_Subscription_Option__c(Name = 'Test Email Subscription Option Two', Program__c = program[1].Id));
        
        //insert Email Subscription Option record 
        insert emailSubOption;  
        
        List<Email_Subscription__c> emailSubscription = new List<Email_Subscription__c>();
        emailSubscription.add(new Email_Subscription__c(Name = 'Test Email Subscription One', Contact__c = con[0].Id, Email_Subscription_Option__c = emailSubOption[0].Id));
        emailSubscription.add(new Email_Subscription__c(Name = 'Test Email Subscription Two', Contact__c = con[1].Id, Email_Subscription_Option__c = emailSubOption[1].Id));
        
        //insert Email Subscription Option record 
        insert emailSubscription;
        
        //Stop Test here
        test.stopTest();        
    }
    
    static testmethod void testUnit() { 
    }
    
    
}