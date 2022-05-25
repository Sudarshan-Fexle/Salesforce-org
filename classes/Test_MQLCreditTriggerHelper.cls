/*
 * Description	   :  Test classs for the code coverage of JobTicketMTMTriggerHelper
 * 
 * Created By      :  Nikita Kumari
 *
 * Created Date    :  02/08/2022
 *
 * Revision Logs   :  V_1.0 - Created - CR-20220119-15726
 *                  	
 * Code Coverage   :  100%	 	
 * */

@isTest
private class Test_MQLCreditTriggerHelper {

    @testSetup static void testSetupData()
    {
        //Disable all the triggers
        Util.BypassAllTriggers = true;
        
        map<String, Map<String, Id>> mapOfRTDevNameWithRTIds = new map<String, Map<String, Id>>();
        
        //Query through RecordTypes
        for(RecordType recordType : [SELECT Id , DeveloperName, Name, SObjectType 
                                     FROM RecordType WHERE IsActive = true AND SObjectType IN ('Opportunity','Event')]
           )
        {
            if(!mapOfRTDevNameWithRTIds.containsKey(recordType.SObjectType))
            {
                mapOfRTDevNameWithRTIds.put(recordType.SObjectType, new Map<String, Id>());
            }
            mapOfRTDevNameWithRTIds.get(recordType.SObjectType).put(recordType.DeveloperName, recordType.Id);
        }
        
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        
        //List of Opportunity
        List<Opportunity> oppList = new List<Opportunity>();
                 
        //Insert Opportunity Record
        //Modified By - CR-20220301-15949 - Neha Sharma - Test class fix - 2/3/2022 - 
        oppList.add(new Opportunity(Sales_Pursuit_Products__c = 'APS', AccountId = cont.AccountId,
                                    RecordTypeId = mapOfRTDevNameWithRTIds.get('Opportunity').get('BI_Contract_Maintenance') , 
                                    Name = 'Test Opportunity1' , Main_Contact__c = cont.Id, StageName = 'Proposal In Progress' , 
                                    Amount = 1234 , CloseDate=system.today().addDays(50) ));
        oppList.add(new Opportunity(Sales_Pursuit_Products__c = 'APS', AccountId = cont.AccountId,
                                    RecordTypeId = mapOfRTDevNameWithRTIds.get('Opportunity').get('EAB_Initiating') , 
                                    Name = 'Test Opportunity2' , Main_Contact__c = cont.Id, StageName = '0-Exploring' , 
                                    Amount = 1234 , CloseDate=system.today().addDays(60) ));
        
        //insert opp
        Insert oppList;
        
        //List to hold Events
        List<Event> events = new List<Event>();

        //Populate List
        events.add(new Event(RecordTypeId = mapOfRTDevNameWithRTIds.get('Event').get('Core_Marketing') ,StartDateTime = system.today().addDays(4), EndDateTime = system.today().addDays(6) , OwnerId = Userinfo.getUserId(), Subject = 'Will Auto-Populate', WhatId = oppList[0].Id , Cancelled_Did_Not_Occur__c = false ,  Event_Type__c = 'Web Visit' ));
        events.add(new Event(RecordTypeId = mapOfRTDevNameWithRTIds.get('Event').get('Core_Marketing') ,StartDateTime = system.today().addDays(3), EndDateTime = system.today().addDays(6) , OwnerId = Userinfo.getUserId(), Subject = 'Will Auto-Populate', WhatId = oppList[1].Id , Cancelled_Did_Not_Occur__c = false ,  Event_Type__c = 'Web Visit' ));
        events.add(new Event(RecordTypeId = mapOfRTDevNameWithRTIds.get('Event').get('Core_Marketing') , StartDateTime = system.today().addDays(2), EndDateTime = system.today().addDays(6) , OwnerId = Userinfo.getUserId(), Subject = 'Will Auto-Populate', WhatId = oppList[0].AccountId , Cancelled_Did_Not_Occur__c = false ,  Event_Type__c = 'Web Visit' ));

        //Insert Events
        insert events ;
        
        //enable all the triggers
        Util.BypassAllTriggers = false;
        
    }
    
    @IsTest static void testpopulateFieldOnBefore()
    {
        List<Event> listOfEvents = [Select Id, WhatId,StartDateTime From Event Order By WhatId Desc];
        //assert on the
        System.assertEquals(3, listOfEvents.size());
            
        //Create MQL Credits
        List<MQL_Credit__c> mqlCredits = new List<MQL_Credit__c>();
        
        mqlCredits.add(new MQL_Credit__c(Name = 'Test Opp 3', Event_ID__c = listOfEvents[0].Id));
        mqlCredits.add(new MQL_Credit__c(Name = 'Test Opp 3', Event_ID__c = listOfEvents[0].Id));
        mqlCredits.add(new MQL_Credit__c(Name = 'Test Opp 3', Event_ID__c = listOfEvents[0].Id));
        
        insert mqlCredits;
        
        mqlCredits = [Select Id, Name, Event_ID__c, MQL_Credit_Date__c From MQL_Credit__c Where Id IN: mqlCredits];
        //assert on the result
        System.assertEquals(listOfEvents[0].StartDateTime, mqlCredits[0].MQL_Credit_Date__c);
        
        mqlCredits[0].MQL_Credit_Date__c = System.today().addDays(10);
        Update mqlCredits[0];
        
        mqlCredits = [Select Id, Name, Event_ID__c, MQL_Credit_Date__c From MQL_Credit__c Where Id IN: mqlCredits];
        //assert on the result
        System.assertNOTEquals(System.today().addDays(10), mqlCredits[0].MQL_Credit_Date__c);
        //assert on the result
        System.assertEquals(listOfEvents[0].StartDateTime, mqlCredits[0].MQL_Credit_Date__c);
    }
    
     @IsTest static void testcheckEventRelatedOppRT()
    {
        List<Event> listOfEvents = [Select Id, WhatId,StartDateTime From Event Order By WhatId Desc];
        //assert on the
        System.assertEquals(3, listOfEvents.size());
            
        //Create MQL Credits
        List<MQL_Credit__c> mqlCredits = new List<MQL_Credit__c>();
        
        mqlCredits.add(new MQL_Credit__c(Name = 'Test Opp 3', Event_ID__c = listOfEvents[2].Id));
        mqlCredits.add(new MQL_Credit__c(Name = 'Test Opp 3', Event_ID__c = listOfEvents[0].Id));
        mqlCredits.add(new MQL_Credit__c(Name = 'Test Opp 3', Event_ID__c = listOfEvents[0].Id));
        
        try{
            insert mqlCredits;
        }
        catch(Exception ex)
        {
            System.assertEquals(true, ex.getMessage().contains(System.Label.MQL_Credit_Opp_Error_Msg));
        }
        
        mqlCredits[0].Event_ID__c = listOfEvents[0].Id;
        Insert mqlCredits;
        
        try{
            mqlCredits[0].Event_ID__c = listOfEvents[2].Id;
            Update mqlCredits[0];
        }        
        catch(Exception ex)
        {
            System.assertEquals(true, ex.getMessage().contains(System.Label.MQL_Credit_Opp_Error_Msg));
        }
    }
    
    @IsTest static void testcheckDeleteCase()
    {
        MQL_Credit__c mqlCred = new MQL_Credit__c();
        
        try{
            Delete mqlCred;
        }
        catch(Exception ex)
        {
            System.assertEquals(true, String.isNotBlank(ex.getMessage()));
        }
        
    }
}