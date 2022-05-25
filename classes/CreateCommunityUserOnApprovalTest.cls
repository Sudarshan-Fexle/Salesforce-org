/**
 * Purpose          :   Test class for Trigger_CreateCommunityUserOnApproval
 * 
 * CreatedDate      :   10-May-2021
 * 
 * RevisionLog      :   V_1.0 - Created - Ayush Gupta - CR-20210422-15098
 *
 * Code Coverage    :   
**/
@isTest
public class CreateCommunityUserOnApprovalTest
{
    public static testmethod void testCreateCommunityUserOnApproval ()
    {
    
        // creating testing account
        Account acc = new Account();
        acc.name = 'Test Account';
        acc.BillingStreet = '123 Baker St';
        acc.BillingCity = 'Newark';
        acc.BillingState = 'Ohio';
        acc.BillingCountry = 'USA';
        acc.BillingPostalCode = '43055';
        insert acc;
        
        //---------create custom/approval request record-------
            
        Community_User_Request__c ins = new Community_User_Request__c();
            ins.Account__c = acc.id;    
            ins.Email__c = 'test@gmail.com';
            ins.First_Name__c = 'test';
            ins.Last_Name__c = 'case';
            ins.Request_Status__c = '';
            ins.User_Created__c = false;
            ins.User_Name__c = 'community@eab.com';
            //Added by Ayush Gupta - 5/4/2021 - Added phone no to prevent validation for required Email, Title and Phone
            ins.Phone_number__c = '98678956784';
        insert ins;
        
        
        //2014-07-29 : revgrp jmk : Taking this out as it's preventing deployment to production
        ins.Request_Status__c = 'Approved';
        update ins;
    } 
}