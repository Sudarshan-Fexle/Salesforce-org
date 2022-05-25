/*
* Purpose          :   Test class for PaginatedContactWrapper
* 
* CreatedDate      :   6/2/2020
* 
* RevisionLog      :   V_1.0 - Created - Dipesh Gupta
*                      V_1.1 - Modified By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
* Code Coverage    :   
* */
@isTest
public class Test_PaginatedContactWrapper {
    
    @TestSetup
    static void dataSetup(){
        Util.BypassAllTriggers = true;
        Util.IsTest(true);

        //Insert program record
        List<Program__c> progList = new List<Program__c>();
        Program__c prog1 = TestUtilities.CreateNewProgram(false);
        prog1.Program_Acronym__c = 'HCAB';
        progList.add(prog1);
        insert progList;

        //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        //Insert Subscription Option record
        /*List<Subscription_Option__c> subOptions = new List<Subscription_Option__c>();
        Subscription_Option__c subOption = new Subscription_Option__c();
        subOption.Subscription_Status__c = 'Active';
        subOption.Subscription_Category__c = 'EMAIL_DAILY';
        subOption.Name = 'Daily Briefing';
        subOptions.add(subOption);

        insert subOptions;

        //Insert Eligible Subscription Option
        List<Eligible_Subscription_Option__c> eligibleSubOptions = new List<Eligible_Subscription_Option__c>();
        Eligible_Subscription_Option__c eligibleSub1 = new Eligible_Subscription_Option__c();
        eligibleSub1.Program__c = prog1.Id;
        eligibleSub1.Related_Subscription__c = subOption.Id;
        eligibleSubOptions.add(eligibleSub1);

        insert eligibleSubOptions;*/

        //Insert contact record
        List<Contact> listOfContactToInsert = new List<Contact>();
        for(Integer i = 1 ; i < 6 ; i++){
            Contact testContact = TestUtilities.CreateNewContact(false);
            testContact.FirstName = 'Test ' + i ;
            testContact.LastName = 'LastName ' + i;
            listOfContactToInsert.add(testContact);
        }

        insert listOfContactToInsert;
    }
    

    @isTest
    static void testWrapper(){
        //Query on contact
        List<Contact> listOfContact = [SELECT Name, Email FROM Contact Where Name LIKE 'Test%' ORDER BY Name];
        
        //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        //Query on Eligible Subscription Option
        //Eligible_Subscription_Option__c eligibleSub = [SELECT ID FROM Eligible_Subscription_Option__c LIMIT 1];
        List<SiteProfileSubscriptionUploadController.ContactWrapper> selectList=new List<SiteProfileSubscriptionUploadController.ContactWrapper>();
        
        for(Contact cont : listOfContact){
            //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
            SiteProfileSubscriptionUploadController.ContactWrapper cW = new SiteProfileSubscriptionUploadController.ContactWrapper(cont.Email , /*cont.Id,*/ cont /*, eligibleSub*/);
            cW.ConId = cont.ID;
            cW.ConName = cont.Name;
            //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
            /*cW.EligibleSubOptionId = eligibleSub.ID;
            cW.EligSubOption = eligibleSub;*/
            cW.Email = cont.Email;
            cW.Con = cont;
            selectList.add(cW);
        }

        PaginatedContactWrapper pCW = new PaginatedContactWrapper();
        pCW.selectList = selectList;

        system.assertEquals(5, pCw.getSize());

        pCW.add(new SiteProfileSubscriptionUploadController.ContactWrapper(listOfContact[0].Email , /*listOfContact[0].Id,*/ listOfContact[0] /*, eligibleSub*/));
        system.assertEquals(6, pCw.getSize());
        
        SiteProfileSubscriptionUploadController.ContactWrapper sProfCW = pcW.get(2);
        system.assert(sProfCW != null);
        system.assertEquals('Test 3 LastName 3', sProfCW.ConName);

        sProfCW = pcW.get(10);
        system.assert(sProfCW == null);
        system.assertEquals(null, sProfCW);

    
        List<SiteProfileSubscriptionUploadController.ContactWrapper> cWList =new List<SiteProfileSubscriptionUploadController.ContactWrapper>();
        
        cWList = pcW.getSelectList();
        system.assertEquals(6, cWList.size());
        
        cWList = pcW.getSubList(0, 3);

        Integer count = 1;
        for(SiteProfileSubscriptionUploadController.ContactWrapper CWR : cWList){
            system.assertEquals('Test ' + count + ' LastName ' + count, CWR.ConName);
            count++;
        }

        pCW.remove(3);
        system.assertEquals(5, pCw.getSize());

        cWList = pCW.get0();
        system.assert(cWList != null);
        system.assertEquals('Test 1 LastName 1' , cWList[0].ConName);

        cWList = pCW.get1();
        cWList = pCW.get2();
        cWList = pCW.get3();
        cWList = pCW.get4();
        cWList = pCW.get5();

        
        List<SiteProfileSubscriptionUploadController.ContactWrapper> cWList1 =new List<SiteProfileSubscriptionUploadController.ContactWrapper>();
        cWList = pCW.get6();
        system.assertEquals(cWList1 , cWList);

        cWList = pCW.get7();
        system.assertEquals(cWList1 , cWList);

        cWList = pCW.get8();
        system.assertEquals(cWList1 , cWList);

        cWList = pCW.get9();
        system.assertEquals(cWList1 , cWList);

        pcW.clear();
        cWList = pcW.getSelectList();
        system.assertEquals(0, cWList.size());


        
    }
}