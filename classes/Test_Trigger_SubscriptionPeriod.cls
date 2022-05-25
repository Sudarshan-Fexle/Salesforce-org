/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_Trigger_SubscriptionPeriod {
    
    /**
     * 
     *  @description    :   This method used to test updateFutureSubscriptionPeriod method
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created - 06/19/2017 - Q2C Phase 2 - CR-20170403-10807
     *              	    V1.2 - Modified By - 8/21/2017- Subhash Garhwal 
     * 			    V1.3 - Modified By - 10/19/2020 - Neha Sharma -  CR-20200910-14498 - Add youvisit type field to Subscription Periods    
     *                      V1.4 - Modified By - 06/25/2021 - Shalu Sharma - CR-20200924-14551 - For creating Project/Deployment and Job ticket records          
     * 
     **/
    static testMethod void testUpdateFutureSubscriptionPeriod() {
        
        //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
        
        //create Test data for Account object as an institute
        Account account = new Account(Name = 'AccountTest1');
        insert account;

        //Create contact
        Contact contact = new Contact(LastName = 'TestingABC', AccountId = account.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert contact;

        //create Contract ABC test data
        Contract__c contractABC = new Contract__c(Name = 'TestContract1', Invoicing_Arrangement__c = 'Special', Payer_Account__c = account.Id,
                                                Year__c = '2017', Type__c = 'NBB', Main_Contact__c = contact.Id, Invoice_Contact__c = contact.Id,
                                                Negotiated_Amount__c = 12 );

        //Insert the contract ABC
        insert contractABC;

        Test.startTest();
        //List to hold subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();  

        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 3, Previous_Period_Plus_Uplift__c = 2000,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));                                                       
        //Insert
        insert subscriptions;        

        //List to hold the Subscription Period records
        List<Subscription_Period__c> listOfSubscriptionPeriod = new List<Subscription_Period__c>();
        List<User> usrs = [Select Id, Name From User Order By Name ASC Limit 2];
        //Add the new 
        listOfSubscriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[0].Id, Period_Start_Date__c = Date.Today(), Period_End_Date__c = Date.Today() + 5,
                                                                Stage__c = 'Honorary', Segment_Index__c = 3, Opt_Out_Date__c = Date.today(), Renewal_Owner__c = usrs[0].Id, Research_Strategic_Leader__c = usrs[0].Id));
        listOfSubscriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[0].Id, Period_Start_Date__c = Date.Today() + 2,Period_End_Date__c = Date.Today() + 5, 
                                                                Stage__c = 'Pending', Segment_Index__c = 100, Opt_Out_Date__c = Date.today(), Renewal_Owner__c = usrs[0].Id, Research_Strategic_Leader__c = usrs[0].Id));
        listOfSubscriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[1].Id, Period_Start_Date__c = Date.Today() + 3, Period_End_Date__c = Date.Today() + 5,
                                                                Stage__c = CPQConstants.SUBSCRIPTION_PERIOD_STAGE_DROPPED, Segment_Index__c = 13, Opt_Out_Date__c = Date.today(), Renewal_Owner__c = usrs[0].Id, Research_Strategic_Leader__c = usrs[0].Id));                                                     
        listOfSubscriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[1].Id, Period_Start_Date__c = Date.Today() + 5, Period_End_Date__c = Date.Today() + 8,
                                                                Stage__c = 'Pending', Segment_Index__c = 15, Opt_Out_Date__c = Date.today(), Renewal_Owner__c = usrs[0].Id, Research_Strategic_Leader__c = usrs[0].Id));                                                      
        //Insert the listOfSubscriptionPeriod
        insert listOfSubscriptionPeriod;
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Query on subscription period records 
        listOfSubscriptionPeriod = [Select Id, Negotiated_Amount_Period__c, Program_Subscription__c, Stage__c  From Subscription_Period__c Order By Name];
        
        listOfSubscriptionPeriod[0].Renewal_Owner__c = usrs[1].Id;
        listOfSubscriptionPeriod[1].Renewal_Owner__c = usrs[1].Id;
        listOfSubscriptionPeriod[2].Research_Strategic_Leader__c = usrs[1].Id;
        listOfSubscriptionPeriod[3].Research_Strategic_Leader__c = usrs[1].Id;
        
        update listOfSubscriptionPeriod; 
        
        //Update the subscriptionPeriod 
        listOfSubscriptionPeriod[0].Stage__c = CPQConstants.SUBSCRIPTION_PERIOD_STAGE_DROPPED;
        
        //Update 
        update listOfSubscriptionPeriod[0];
        
        //Query on update subscription period records 
        listOfSubscriptionPeriod = [Select Id, Negotiated_Amount_Period__c, Segment_Index__c, Renewal_Year_Half__c,Program_Subscription__c, Stage__c  From Subscription_Period__c Order By Name];
        
        //Update the Segment Index 
        listOfSubscriptionPeriod[0].Segment_Index__c = 49;
        
        //Update Operation on the Subscription Periord
        update listOfSubscriptionPeriod[0];
        
        //Inistate
        listOfSubscriptionPeriod = new List<Subscription_Period__c>();
        
        //Query on the Susbcription Period 
        listOfSubscriptionPeriod = [Select Id, Negotiated_Amount_Period__c, Segment_Index__c, Renewal_Year_Half__c,Program_Subscription__c, Stage__c  From Subscription_Period__c Order By Name];
    
        //Assert to check the 
        
        
        //Testing stop here
        Test.Stoptest(); 
        
    }
    
    /**
     * 
     *  @description    :   This method used to test updateNegotiatedAmountPeriod method
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created - 06/19/2017 - Q2C Phase 2 - CR-20170403-10807
     * 
     **/
    static testMethod void testUpdateNegotiatedAmountPeriod() {
        
        //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
        
        //create Test data for Account object as an institute
        Account account = new Account(Name = 'AccountTest1');
        insert account;

        //Create contact
        Contact contact = new Contact(LastName = 'TestingABC', AccountId = account.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert contact;

        //create Contract ABC test data
        Contract__c contractABC = new Contract__c(Name = 'TestContract1', Invoicing_Arrangement__c = 'Special', Payer_Account__c = account.Id,
                                                Year__c = '2017', Type__c = 'NBB', Main_Contact__c = contact.Id, Invoice_Contact__c = contact.Id,
                                                Negotiated_Amount__c = 12 );

        //Insert the contract ABC
        insert contractABC;

        //List to hold subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();  

        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 3, Previous_Period_Plus_Uplift__c = 2000,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));                                                       
        //Insert
        insert subscriptions;        
        
        //List to hold the Subscription Period records
        List<Subscription_Period__c> listSusbcriptionPeriod  = new List<Subscription_Period__c>();
        
        //Add the new 
        listSusbcriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[0].Id, Period_Start_Date__c = Date.Today(), 
                                                                Stage__c = CPQConstants.SUBSCRIPTION_PERIOD_STAGE_DROPPED, Opt_Out_Date__c =  Date.Today() ));
        listSusbcriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[0].Id, Period_Start_Date__c = Date.Today() + 1, 
                                                                Stage__c = 'Pending', Opt_Out_Date__c =  Date.Today()));
        listSusbcriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[1].Id, Period_Start_Date__c = Date.Today(), 
                                                                Stage__c = CPQConstants.SUBSCRIPTION_PERIOD_STAGE_DROPPED, Opt_Out_Date__c =  Date.Today()));                                                        
        listSusbcriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[1].Id, Period_Start_Date__c = Date.Today(), 
                                                                Stage__c = 'Pending', Opt_Out_Date__c =  Date.Today()));                                                     
        
	//  Modified By - Mahendra Swarnkar - 06/04/2020 - CR-20200505-14017
        //Insert the listOfSubscriptionPeriod
        if(listSusbcriptionPeriod.size() > 0)
        	insert listSusbcriptionPeriod;
        
        //Test Start here 
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false; 
        
        
        listSusbcriptionPeriod[0].Negotiated_Amount_Period__c = 2000;
        listSusbcriptionPeriod[0].Period_Start_Date__c = Date.Today().addDays(1);

        update listSusbcriptionPeriod[0];  
        
        //ByPass the trigger 
        Util.byPassAllTriggers = true; 
        
        //Query on subscription period records 
        listSusbcriptionPeriod = [Select Id, Negotiated_Amount_Period__c,Research_Strategic_Leader__c,  Renewal_Year_Half__c, Program_Subscription__c, Stage__c  From Subscription_Period__c Order By Name];
        
        //Assert for the check the stage name
        //System.assertEquals(1000, listOfSubscriptionPeriod[1].Negotiated_Amount_Period__c);  
        //System.assertEquals('H1', listOfSubscriptionPeriod[1].Renewal_Year_Half__c);   
        
        //Testing stop here
        Test.Stoptest();
        
        listSusbcriptionPeriod[0].Research_Strategic_Leader__c = UserInfo.getUserId();
        update listSusbcriptionPeriod[0];
    }
    /**
     * 
     *  @description    :   This method used to test updateNegotiatedAmountPeriod method
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created - 06/19/2017 - Q2C Phase 2 - CR-20170403-10807
     * 			:   V1.2 - Modified by - Neha Sharma - 05/24/2021 - CR-20210105-14771
     * 
     * 
     **/
    static testMethod void testpopulateRenewalYearHalfOnSubPeriod() {
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(true);
        
        //Creating program record
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //Creating Membership records
        Membership__c membership = TestUtilities.CreateNewMembership(account.Id, program.Id, true);
                
        //Creating Subscription record
        SBQQ__Subscription__c subscription = TestUtilities.createNewSubscription(membership.Id, false);
        
        //Modified by Neha Sharma on 05/24/2021 - CR-20210105-14771
        //Record type for subscription
        subscription.recordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;

        //Insert Subscription
        insert subscription;

        //List to hold the record's type 
        List<RecordType> recordTypeSP = [Select Id, Name from RecordType Where SobjectType = 'Subscription_Period__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_PERIOD_RECORD_TYPE_DEVELOPERNAME_EAB];

        //Call a util method
        Subscription_Period__c sPeriod = TestUtilities.createNewSubscriptionPeriod(subscription.Id,false);
	//  Modified By - Mahendra Swarnkar - 06/04/2020 - CR-20200505-14017
	 sPeriod.Renewal_Year_Half__c = 'H1';
        
        //Insert Subscription Period
        if(sPeriod != null)
        insert sPeriod;

        Util.byPassAllTriggers = false;

        //Modified by Neha Sharma on 05/24/2021 - CR-20210105-14771 -- start here
        //List to hold the record's type 
        //Creating Subscription record
        List<SBQQ__Subscription__c> programSubscriptions = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c programSubscription = TestUtilities.createNewSubscription(membership.Id, false);
        
        //Record type for subscription
        programSubscription.recordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        programSubscription.Program__c = program.Id;
        programSubscription.You_Visit_Package_Type_m__c = 'Premium';
        
        programSubscriptions.add(programSubscription);
        
        programSubscription = TestUtilities.createNewSubscription(membership.Id, false);
        programSubscription.recordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        programSubscription.Program__c = program.Id;
        programSubscription.You_Visit_Package_Type_m__c = 'Essential';
        
        programSubscriptions.add(programSubscription);
        
        insert programSubscriptions;
        
        //Call a util method
        Subscription_Period__c sPeriod2 = TestUtilities.createNewSubscriptionPeriod(programSubscriptions[0].Id, false);
        insert sPeriod2;
    
        
        //Modified by Neha Sharma on 05/24/2021 - CR-20210105-14771 -- ends here

        //Testing start here
        Test.startTest();

        //Record type
        sPeriod.recordTypeId = recordTypeSP[0].Id;
        
        //List has more than 1 row for assignment to SObject
        sPeriod = [Select Id,Renewal_Year_Half__c from  Subscription_Period__c Where Id =: sPeriod.Id];

        //Testing stop here
        System.assertEquals('H1', sPeriod.Renewal_Year_Half__c); 

        sPeriod.Pool_Year__c = '2018';
        sPeriod.Pool_Month__c = '10';
	sPEriod.Renewal_Year_Half__c = 'H2';
        //Update Subscription Period
        update sPeriod;

        //Query on Subscription Period
        sPeriod = [Select Id,Renewal_Year_Half__c from  Subscription_Period__c Where Id =: sPeriod.Id];

        //Testing stop here
        System.assertEquals('H2', sPeriod.Renewal_Year_Half__c); 

        //Modified by Neha Sharma on 05/24/2021 - CR-20210105-14771 -- start here
        sPeriod2 = [Select Id,YouVisit_Package_Type__c from Subscription_Period__c where YouVisit_Package_Type__c != null AND Id =:sPeriod2.Id];
        System.assertEquals('Premium',  sPeriod2.YouVisit_Package_Type__c);

        sPeriod2.Program_Subscription__c = programSubscriptions[1].Id;
        update sPeriod2;
		
        sPeriod2 = [Select Id,YouVisit_Package_Type__c from Subscription_Period__c where YouVisit_Package_Type__c != null AND Id =:sPeriod2.Id];
        System.assertEquals('Essential', sPeriod2.YouVisit_Package_Type__c);

        //Modified by - Neha Sharma - 05/24/2021 -- ends here

        //Testing start here
        Test.stopTest();

    }
    /**
     * 
     *  @description    :   This method used to test updateDecisionType method
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created - 07/05/2017 - Q2C Phase 2 - CR-20170403-10807
     * 
     **/
    static testMethod void testupdateDecisionType() {

       //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(true);
        
        //Creating program record
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //Creating Membership records
        Membership__c membership = TestUtilities.CreateNewMembership(account.Id, program.Id, true);


        //List to hold Subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();


        //Loop to insert subscription
        for(Integer count = 0 ; count < 3 ;count++ ) {

            //Add record to list
            subscriptions.add( TestUtilities.createNewSubscription(membership.Id, false));
            subscriptions[count].recordTypeId = recordTypes[0].Id;
            subscriptions[count].Term_Type__c = 'Opt Out';
        }

        //Subscription OPT OUT 
        //subscriptions[0].Opt_Out__c = 'Board Approval Opt Out';
        //subscriptions[1].Opt_Out__c  = 'Board Approval Opt Out';
        //subscriptions[2].Opt_Out__c  = 'Board Approval Opt Out';
        subscriptions[2].Early_Termination_Date__c = Date.today() +1;

        //Insert Subscription
        insert subscriptions;

        //List to hold the record's type 
        List<RecordType> recordTypeSP = [Select Id, Name from RecordType Where SobjectType = 'Subscription_Period__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_PERIOD_RECORD_TYPE_DEVELOPERNAME_EAB];


        //List to hold Subscription Period
        List<Subscription_Period__c> speriods = new List<Subscription_Period__c>();

        for(Integer count = 0 ; count < 3; count++) {
    
            for(Integer counter = 0 ; counter < 5 ; counter++) {
    
                //Call a util method
                speriods.add(TestUtilities.createNewSubscriptionPeriod(subscriptions[count].Id,false));
                speriods[counter].recordTypeId = recordTypeSP[0].Id;
                speriods[counter].Period_Start_Date__c = Date.Today() + counter;
                speriods[counter].Period_End_Date__c = Date.today() ;
    
            }

        }
        
        //Bypassing Triggers so then test data can be created easily
        //Util.byPassAllTriggers = false;

        speriods[1].Stage__c = 'Void';
        speriods[2].Stage__c = 'Void';
        speriods[3].Stage__c = 'Void';
        speriods[4].Stage__c = 'Void';
        speriods[5].Stage__c = 'Void';
        speriods[6].Stage__c = 'Void';
        speriods[7].Stage__c = 'Void';
        speriods[8].Stage__c = 'Void';
        speriods[9].Stage__c = 'Void';
        speriods[10].Stage__c = 'Void';
        speriods[11].Stage__c = 'Void';
        speriods[12].Stage__c = 'Void';
        speriods[13].Stage__c = 'Void';
        speriods[14].Stage__c = 'Void';
        
	//  Modified By - Mahendra Swarnkar - 06/04/2020 - CR-20200505-14017
        //Insert subscription period
        if(speriods.size() > 0)
        insert speriods;

        //Testing start here
        Test.startTest();

            //Query on Subscription Period
            speriods = [Select Id, Renewal_Year_Half__c, Decision_Type__c  from  Subscription_Period__c order By createdDate];
            subscriptions = [Select Id, Opt_Out__c From  SBQQ__Subscription__c];
            
            //Assert 
            System.assertEquals(3,subscriptions.Size());                                                                                                             
            System.assertEquals(15,speriods.Size());
            //System.assertEquals('Need New LOA',speriods[0].Decision_Type__c);
            /*System.assertEquals('Opt Out',speriods[1].Decision_Type__c);
            System.assertEquals('Opt Out',speriods[2].Decision_Type__c);
            System.assertEquals('Opt Out',speriods[3].Decision_Type__c);
            System.assertEquals('Opt Out',speriods[4].Decision_Type__c);
            System.assertEquals('Opt Out',speriods[5].Decision_Type__c);
            System.assertEquals('Opt Out',speriods[6].Decision_Type__c);
            System.assertEquals('Opt Out',speriods[7].Decision_Type__c);
            System.assertEquals('Opt Out',speriods[8].Decision_Type__c);
            System.assertEquals('Opt Out',speriods[9].Decision_Type__c);
            System.assertEquals('Opt Out',speriods[10].Decision_Type__c);
            System.assertEquals('Opt Out',speriods[11].Decision_Type__c);
            System.assertEquals('Opt Out',speriods[12].Decision_Type__c);
            System.assertEquals('Opt Out',speriods[13].Decision_Type__c);
            System.assertEquals('Opt Out',speriods[14].Decision_Type__c);*/

        //Testing stop here
        Test.stopTest();
    }
    
    /**
     * 
     *  @description    :   This method used to test populateNextYearRenewal method
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created - 07/05/2017 - Q2C Phase 2 - CR-20170403-10807
     * 
     **/
    static testMethod void testpopulateNextYearRenewal() {  

        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(true);

        //Create contact
        Contact contact = new Contact(LastName = 'TestingABC', AccountId = account.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert contact;

        //create Contract ABC test data
        Contract__c contract = new Contract__c(Name = 'TestContract1', Invoicing_Arrangement__c = 'Special', Payer_Account__c = account.Id,
                                                Year__c = '2017', Type__c = 'NBB', Main_Contact__c = contact.Id, Invoice_Contact__c = contact.Id,
                                                Negotiated_Amount__c = 12 );

        //Insert the contract ABC
        insert contract;

        //Create Contract
        Contract StdContract = new Contract(AccountId = account.Id, Status = 'Draft', StartDate = Date.today(), ContractTerm = 12);
        insert StdContract;

        //Creating program record
        Program__c program = TestUtilities.CreateNewProgram(true);


        //Creating Membership records
        Membership__c membership = TestUtilities.CreateNewMembership(account.Id, program.Id, true);

        //Creating Opportunity 
        Opportunity opp = TestUtilities.CreateNewOpportunity(account.Id,false);
        opp.Signed_Opportunity_Contract__c = contract.Id;
        opp.CloseDate = Date.today();
        insert opp; 

        //List to hold Subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();

        //Add record to list
        subscriptions.add( TestUtilities.createNewSubscription(membership.Id, false));
        subscriptions[0].recordTypeId = recordTypes[0].Id;
        //Commented by Mahendra Swarnkar - 05/18/2020 - CR-20200218-13769
        //subscriptions[0].Previous_Contract_ABC__c = contract.Id;

        //Insert Subscription
        insert subscriptions;

        //List to hold the record's type 
        List<RecordType> recordTypeSP = [Select Id, Name from RecordType Where SobjectType = 'Subscription_Period__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_PERIOD_RECORD_TYPE_DEVELOPERNAME_EAB];


        //List to hold Subscription Period
        List<Subscription_Period__c> speriods = new List<Subscription_Period__c>();

        for(Integer count = 0 ; count < 3; count++) {
        
            //Call a util method
            speriods.add(TestUtilities.createNewSubscriptionPeriod(subscriptions[0].Id,false));
            speriods[count].recordTypeId = recordTypeSP[0].Id;
            speriods[count].Segment_Index__c = count +1;
            speriods[count].Contract__c  = StdContract.Id;
        }
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;

        //insert subscription period
        insert speriods;

        //Testing start here
        Test.startTest();

            //Query on Subscription Period
            speriods = [Select Id, Renewal_Year_Half__c, Decision_Type__c  from  Subscription_Period__c order By createdDate];
            
            //Assert 
            System.assertEquals(3,speriods.Size());                                                                                                             

        //Testing stop here
        Test.stopTest();

        //List to hold Subscription Period
        List<Subscription_Period__c> speriods1 = new List<Subscription_Period__c>();

        for(Integer count = 0 ; count < 3; count++) {
        
            //Call a util method
            speriods1.add(TestUtilities.createNewSubscriptionPeriod(subscriptions[0].Id,false));
            speriods1[count].recordTypeId = recordTypeSP[0].Id;
            speriods1[count].Segment_Index__c = count +1;
            speriods1[count].Contract__c  = StdContract.Id;
            speriods1[count].Previous_Subscription_Period__c = speriods[0].Id;
            //Commented by Mahendra Swarnkar - 05/18/2020 - CR-20200218-13769
            //speriods1[count].Previous_Contract_ABC__c = contract.Id;
        }
        

        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = false;

        //insert subscription period
        insert speriods1;

        //Query on Subscription Period
        speriods1 = [Select Id, Renewal_Year_Half__c, Decision_Type__c  from  Subscription_Period__c order By createdDate];     
		
        Map<Id, Subscription_Period__c> mapSubPeriods = new Map<Id, Subscription_Period__c>();
        
        List<Subscription_Period__c> sPs = [Select Id, Program_Subscription__c, Program_Subscription__r.Program__r.Program_Acronym__c
                               From Subscription_Period__c Where Program_Subscription__c != null];
         
        mapSubPeriods.putAll(sPs);
        
        //Creating task 
        Task t = new Task();
        t.WhatId = sPs[0].Id;
        t.Duration_in_Hours__c = 5;
        t.Subject = 'Test';
       
        insert t;
        
        Event e = new Event();
        e.Subject = 'Test';
        e.WhatId = sPs[0].Id;
        e.StartDateTime = System.now();
        e.EndDateTime = System.now().addMinutes(+5);
        
        insert e;   
        
        SubscriptionPeriodTriggerHelper.populateProgramInfo_TasksSP(mapSubPeriods, new List<Task> {t});
        SubscriptionPeriodTriggerHelper.populateProgramInfo_EventsSP(mapSubPeriods, new List<Event> {e} );
    }
    /**
     * 
     *  @description    :   This method used to test populateEngagementStatusOnProgramPackage method
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created - 07/05/2017 - Q2C Phase 2 - CR-20170403-10807
     * 
     **/
    static testMethod void testPopulateEngagementStatusOnProgramPackage() {  

        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(true);

        //Create contact
        Contact contact = new Contact(LastName = 'TestingABC', AccountId = account.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert contact;

        //Create Contract
        Contract StdContract = new Contract(AccountId = account.Id, Status = 'Draft', StartDate = Date.today(), ContractTerm = 12);
        insert StdContract;

        //Creating program record
        Program__c program = TestUtilities.CreateNewProgram(true);


        //Creating Membership records
        Membership__c membership = TestUtilities.CreateNewMembership(account.Id, program.Id, true);

        //Creating Opportunity 
        Opportunity opp = TestUtilities.CreateNewOpportunity(account.Id,false);
        //opp.Signed_Opportunity_Contract__c = contract.Id;
        opp.CloseDate = Date.today();
        insert opp; 
		
		
		//Program Package "EAB" Record Type Id
		Id programPackage_EAB_RTypeId = TestUtilities.FindRecordTypeId('Program_Package__c','EAB' );
		
		List<Program_Package__c> progPacks = new List<Program_Package__c>();
		
		progPacks.add(new Program_Package__c(Name = 'Test1', Account__c = account.Id, Fiscal_Year__c = String.valueOf(Date.Today().Year()),
                                             Client_Status_New__c = Label.Client_Status_Secured, Account_Status__c = 'Existing Client', RecordTypeId = programPackage_EAB_RTypeId));
        progPacks.add(new Program_Package__c(Name = 'Test2', Account__c = account.Id, Fiscal_Year__c = String.valueOf(Date.Today().Year()+1),
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'Existing Client', RecordTypeId = programPackage_EAB_RTypeId));
	
		insert progPacks;
		
        //List to hold Subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();

        //Add record to list
        subscriptions.add( TestUtilities.createNewSubscription(membership.Id, false));
        subscriptions[0].recordTypeId = recordTypes[0].Id;
        subscriptions[0].SBQQ__Contract__c = StdContract.Id;
        
        //Insert Subscription
        insert subscriptions;

        //List to hold the record's type 
        List<RecordType> recordTypeSP = [Select Id, Name from RecordType Where SobjectType = 'Subscription_Period__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_PERIOD_RECORD_TYPE_DEVELOPERNAME_EAB];


        //List to hold Subscription Period
        List<Subscription_Period__c> speriods = new List<Subscription_Period__c>();
		speriods.add(new Subscription_Period__c(Name = 'TestSP1', Program_Subscription__c = subscriptions[0].Id, recordTypeId = recordTypeSP[0].Id,
                                          Period_Start_Date__c = Date.Today(), Period_End_Date__c = Date.Today().addYears(1).addDays(-1),
                                          Segment_Index__c = 1, Negotiated_Amount_Period__c  = 1.0, Contract__c = StdContract.Id, Decision_Type__c = 'Need New LOA',
                                           Stage__c = '', Program_Package__c = progPacks[1].Id));
                                           
		speriods.add(new Subscription_Period__c(Name = 'TestSP2', Program_Subscription__c = subscriptions[0].Id, recordTypeId = recordTypeSP[0].Id,
                                          Period_Start_Date__c = Date.Today().addYears(1), Period_End_Date__c = Date.Today().addYears(2).addDays(-1),
                                          Segment_Index__c = 2, Negotiated_Amount_Period__c  = 1.0, Contract__c = StdContract.Id,
                                           Stage__c = 'ATL', Program_Package__c = progPacks[0].Id));
		 
        //  Modified By - Mahendra Swarnkar - 06/04/2020 - CR-20200505-14017
	if(speriods.size() > 0)
        	insert speriods;

        //Testing start here
        Test.startTest();
				
		//Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = false;

        //insert subscription period
        
        
        Util.byPassAllTriggers = true;
        
        //Query on Subscription Period
        List<Program_Package__c> pPackages = [Select Id, Fiscal_Year__c,  Client_Status_New__c  from  Program_Package__c ORDER BY Fiscal_Year__c ASC];
            
            //Assert 
            System.assertEquals(2,pPackages.Size());
            System.assertEquals(pPackages[0].Fiscal_Year__c, String.valueOf(Date.Today().Year()));
            System.assertEquals(pPackages[1].Fiscal_Year__c, String.valueOf(Date.Today().Year()+1));
               
        speriods[0].Program_Package__c =  pPackages[0].Id;
        speriods[1].Program_Package__c =  pPackages[1].id;
                                                  
		
        Util.byPassAllTriggers = false;
        update speriods;
        
        //Testing stop here
        Test.stopTest();
       
    }  
    
    static testmethod void testPopulatePreviousCurrentNextYearProgramCost() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        //Creating program record
        Program__c program = TestUtilities.CreateNewProgram(true);

        //Insert Products
        List<Product2> products = new List<Product2>();
        
        //Add new Products in List
        products.add(new Product2(Name = 'TMBH - Test Method', Family = 'Enrollment Services', Program__c = program.Id, IsActive = true,
                                  ProductCode = 'TMBH', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'Student Success Management Intelligence',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                                  SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
        
        //Add new Products in List
        products.add(new Product2(Name = 'Annual Fee', IsActive = true, ProductCode = 'Program Costs', SBQQ__Component__c = true,
                                  Product_Category__c = 'Annual Fee', Program_Name_Member_Facing__c = 'Program Costs',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1));
        
        insert products;
        
        //List to insert Feature
        List<SBQQ__ProductFeature__c> features = new List<SBQQ__ProductFeature__c>();
        
        //Add Feature record in list to insert
        features.add(new SBQQ__ProductFeature__c(Name = 'Annual Fee', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[0].Id));
        
        //Insert
        insert features;
        
        //List to insert Product Options
        List<SBQQ__ProductOption__c> productOptions = new List<SBQQ__ProductOption__c>();
        
        //Add records in list to insert
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[1].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[0].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        
        //Insert
        insert productOptions;
        
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education'); 
        
        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(false);
        account.RecordTypeId = accountUSCorporateRecordType;
        insert account; 
		
        //Creating Membership records
        Membership__c membership = TestUtilities.CreateNewMembership(account.Id, program.Id, false);
        membership.RecordTypeId = Constants.Membership_Record_Type_Enrollment;
        insert membership;
        
        //Program Package "EAB" Record Type Id
		Id programPackage_EAB_RTypeId = TestUtilities.FindRecordTypeId('Program_Package__c','EAB' );
		
		List<Program_Package__c> progPacks = new List<Program_Package__c>();
		
		progPacks.add(new Program_Package__c(Name = 'Test1', Account__c = account.Id, Fiscal_Year__c = String.valueOf(Date.Today().Year()-1), Membership__c = membership.Id,
                                             Client_Status_New__c = Label.Client_Status_Secured, Account_Status__c = 'Existing Client', RecordTypeId = programPackage_EAB_RTypeId));
        
        progPacks.add(new Program_Package__c(Name = 'Test2', Account__c = account.Id, Fiscal_Year__c = String.valueOf(Date.Today().Year()), Membership__c = membership.Id,
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'Existing Client', RecordTypeId = programPackage_EAB_RTypeId));
        
        progPacks.add(new Program_Package__c(Name = 'Test2', Account__c = account.Id, Fiscal_Year__c = String.valueOf(Date.Today().Year()+1), Membership__c = membership.Id,
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'Existing Client', RecordTypeId = programPackage_EAB_RTypeId));
	
		insert progPacks;
        
        //Create contact
        Contact contact = new Contact(LastName = 'TestingABC', AccountId = account.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert contact;

        //Create Contract
        Contract StdContract = new Contract(AccountId = account.Id, Status = 'Draft', StartDate = Date.today(), ContractTerm = 12);
        insert StdContract;
        
        //Creating Opportunity 
        Opportunity opp = TestUtilities.CreateNewOpportunity(account.Id,false);
        opp.CloseDate = Date.today();
        insert opp; 
		
        //Query on Subscription Record Types
        List<RecordType> recrdTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Subscription__c' 
                                       AND DeveloperName IN ('Program', 'Component') AND IsActive = true ORDER BY DeveloperName DESC];
        
        //Creating Subscription record
        //List to hold subscription
        List<SBQQ__Subscription__c> programSubscriptions = new List<SBQQ__Subscription__c>();  
        
        //Add new subscription record in list
        programSubscriptions.add(new SBQQ__Subscription__c(RecordTypeId = recrdTypes[0].Id, SBQQ__Account__c = account.Id,
                                                           SBQQ__Quantity__c = 1, Source_Opportunity__c = opp.Id,
                                                           SBQQ__ListPrice__c = 0, Stage_Period__c = 'Pending',SBQQ__Contract__c = StdContract.Id,
                                                           SBQQ__Product__c = products[0].ID, Program__c = program.ID, Membership__c = membership.Id,
                                                           SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                           Status__c = 'Committed', Invoice_Contact__c = contact.Id));
        
        //Insert
        insert programSubscriptions;
           
        List<Subscription_Period__c> subscriptionPeriods = new List<Subscription_Period__c>();
        
        //Creating Subscription Period record
        Subscription_Period__c sPeriod = TestUtilities.createNewSubscriptionPeriod(programSubscriptions[0].Id, false);
        
        sPeriod.Institution__c = account.Id;
        sPeriod.Period_Start_Date__c = Date.Today().addYears(-1).addDays(1);
        sPeriod.Period_End_Date__c = Date.Today();
        sPeriod.Contract__c = StdContract.Id;
        sPeriod.Source_Opportunity__c = opp.Id;
        sPeriod.Membership_Lookup__c = membership.Id;
        sPeriod.Program_Package__c = progPacks[0].Id;
        subscriptionPeriods.add(sPeriod);
        
        //Creating Subscription Period record
        Subscription_Period__c sPeriod1 = TestUtilities.createNewSubscriptionPeriod(programSubscriptions[0].Id, false);
        
        sPeriod1.Institution__c = account.Id;
        sPeriod1.Period_Start_Date__c = Date.Today().addDays(1);
        sPeriod1.Period_End_Date__c = Date.Today().addYears(1);
        sPeriod1.Contract__c = StdContract.Id;
        sPeriod1.Source_Opportunity__c = opp.Id;
        sPeriod1.Membership_Lookup__c = membership.Id;
        sPeriod1.Program_Package__c = progPacks[1].Id;
        subscriptionPeriods.add(sPeriod1);
        
        //Creating Subscription Period record
        Subscription_Period__c sPeriod2 = TestUtilities.createNewSubscriptionPeriod(programSubscriptions[0].Id, false);
        
        sPeriod2.Institution__c = account.Id;
        sPeriod2.Period_Start_Date__c = Date.Today().addYears(1).addDays(1);
        sPeriod2.Period_End_Date__c = Date.Today().addYears(2);
        sPeriod2.Contract__c = StdContract.Id;
        sPeriod2.Source_Opportunity__c = opp.Id;
        sPeriod2.Membership_Lookup__c = membership.Id;
        sPeriod2.Program_Package__c = progPacks[2].Id;
        subscriptionPeriods.add(sPeriod2);
        
        insert subscriptionPeriods;
            
        List<SBQQ__Subscription__c> listcomponentSubscription = new List<SBQQ__Subscription__c>();
        
        //Creating Subscription record
        SBQQ__Subscription__c componentSubscription = TestUtilities.createNewSubscription(membership.Id, false);
        
        componentSubscription.SBQQ__Contract__c = StdContract.Id;
        componentSubscription.Subscription_Period__c = subscriptionPeriods[0].Id;
        componentSubscription.recordTypeId = recrdTypes[1].Id;
        componentSubscription.Opportunity__c = opp.Id;
        componentSubscription.Source_Opportunity__c = opp.Id;
        componentSubscription.SBQQ__RequiredByProduct__c = products[0].ID;
        componentSubscription.SBQQ__Product__c = products[1].ID;
        componentSubscription.SBQQ__SegmentStartDate__c = Date.Today().addYears(-1).addDays(1);
        componentSubscription.SBQQ__SegmentEndDate__c = Date.today();
        componentSubscription.Program_Subscription__c = programSubscriptions[0].Id;
        componentSubscription.SBQQ__RenewalPrice__c = 100;
        componentSubscription.SBQQ__CustomerPrice__c = 100;
        componentSubscription.SBQQ__Quantity__c = 1;
        
        listcomponentSubscription.add(componentSubscription);
        
        //Creating Subscription record
        SBQQ__Subscription__c componentSubscription1 = TestUtilities.createNewSubscription(membership.Id, false);
        
        componentSubscription1.SBQQ__Contract__c = StdContract.Id;
        componentSubscription1.Subscription_Period__c = subscriptionPeriods[1].Id;
        componentSubscription1.recordTypeId = recrdTypes[1].Id;
        componentSubscription1.Opportunity__c = opp.Id;
        componentSubscription1.Source_Opportunity__c = opp.Id;
        componentSubscription1.SBQQ__RequiredByProduct__c = products[0].ID;
        componentSubscription1.SBQQ__Product__c = products[1].ID;
        componentSubscription1.SBQQ__SegmentStartDate__c = Date.Today().addDays(1);
        componentSubscription1.SBQQ__SegmentEndDate__c = Date.today().addYears(1);
        componentSubscription1.Program_Subscription__c = programSubscriptions[0].Id;
        componentSubscription1.SBQQ__RenewalPrice__c = 100;
        componentSubscription1.SBQQ__CustomerPrice__c = 100;
        componentSubscription1.SBQQ__Quantity__c = 1;
        
        listcomponentSubscription.add(componentSubscription1);
        
        //Creating Subscription record
        SBQQ__Subscription__c componentSubscription2 = TestUtilities.createNewSubscription(membership.Id, false);
        
        componentSubscription2.SBQQ__Contract__c = StdContract.Id;
        componentSubscription2.Subscription_Period__c = subscriptionPeriods[1].Id;
        componentSubscription2.recordTypeId = recrdTypes[1].Id;
        componentSubscription2.Opportunity__c = opp.Id;
        componentSubscription2.Source_Opportunity__c = opp.Id;
        componentSubscription2.SBQQ__RequiredByProduct__c = products[0].ID;
        componentSubscription2.SBQQ__Product__c = products[1].ID;
        componentSubscription2.SBQQ__SegmentStartDate__c = Date.today().addYears(1).addDays(1);
        componentSubscription2.SBQQ__SegmentEndDate__c = Date.today().addYears(2);
        componentSubscription2.Program_Subscription__c = programSubscriptions[0].Id;
        componentSubscription2.SBQQ__RenewalPrice__c = 100;
        componentSubscription2.SBQQ__CustomerPrice__c = 100; 
        componentSubscription.SBQQ__Quantity__c = 1;
        	
        listcomponentSubscription.add(componentSubscription2);
        
        //Insert componentSubscription
        insert listcomponentSubscription;
        
        for(Subscription_Period__c sp : subscriptionPeriods){
            sp.Membership_Lookup__c = membership.Id;
        }
        
        Test.startTest();
		
        Util.byPassAllTriggers = false;
        update subscriptionPeriods;
        
        Test.stopTest();
    }
    
    /**
     * 
     *  @description    :   This method used to test testyouVisitPackageOnSubPeriod method
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created - Neha Sharma - CR-20200910-14498 - 10/19/2020 - Add youvisit type field to Subscription Periods
     * 			    V1.2 - Modified by - Neha Sharma - 05/24/2021 - CR-20210105-14771
     **/
    static testMethod void testyouVisitPackageOnSubPeriod() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(true);
        
        //Creating program record
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //Creating Membership records
        Membership__c membership = TestUtilities.CreateNewMembership(account.Id, program.Id, true);
                
        //List to hold the record's type 
        List<RecordType> recordTypeSP = [Select Id, Name from RecordType Where SobjectType = 'Subscription_Period__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_PERIOD_RECORD_TYPE_DEVELOPERNAME_EAB];


        Util.byPassAllTriggers = false;

        //List to hold the record's type 
        //Creating Subscription record
        List<SBQQ__Subscription__c> programSubscriptions = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c programSubscription = TestUtilities.createNewSubscription(membership.Id, false);
        
        //Record type for subscription
        programSubscription.recordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        programSubscription.Program__c = program.Id;
        programSubscription.You_Visit_Package_Type_m__c = 'Premium';
        
        programSubscriptions.add(programSubscription);
        
        programSubscription = TestUtilities.createNewSubscription(membership.Id, false);
        programSubscription.recordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        programSubscription.Program__c = program.Id;
        programSubscription.You_Visit_Package_Type_m__c = 'Essential';
        
        programSubscriptions.add(programSubscription);
        
        insert programSubscriptions;
        
        //Call a util method
        Subscription_Period__c sPeriod2 = TestUtilities.createNewSubscriptionPeriod(programSubscriptions[0].Id, false);
        insert sPeriod2;
    
        //Testing start here
        Test.startTest();
    
        sPeriod2 = [Select Id,YouVisit_Package_Type__c from Subscription_Period__c where YouVisit_Package_Type__c != null AND Id =:sPeriod2.Id];
        System.assertEquals('Premium',  sPeriod2.YouVisit_Package_Type__c);

        sPeriod2.Program_Subscription__c = programSubscriptions[1].Id;
        update sPeriod2;
		
        sPeriod2 = [Select Id,YouVisit_Package_Type__c from Subscription_Period__c where YouVisit_Package_Type__c != null AND Id =:sPeriod2.Id];
        System.assertEquals('Essential', sPeriod2.YouVisit_Package_Type__c);

        //Testing start here
        Test.stopTest();
        
    }
    
    /**
     * 
     *  @description    :   This method used to test callBatchAutomatedProjectAndRelated method
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created - Shalu Sharma - CR-20200924-14551 - 06/25/2021 - For creating Project/Deployment and Job ticket records
     * 
     **/
    static testMethod void testCallBatchAutomatedProjectAndRelated(){
    
        //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
                
        //List to hold opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(TestUtilities.CreateNewOpportunity(false));
        opportunities.add(TestUtilities.CreateNewOpportunity(false));
        insert opportunities;
        
        System.assert(opportunities.size() > 0);
        
        //Get Record Type
        Id QuoteOpenRecordType = TestUtilities.FindRecordTypeId('SBQQ__Quote__c', 'Open');
        
        //List ot hold proposal 
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add to list
        quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[0].Id, SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'Draft', 
                                      SBQQ__StartDate__c = Date.today() , SBQQ__EndDate__c = Date.today().addDays(2), recordTypeId = QuoteOpenRecordType,
                                      SBQQ__PrimaryContact__c = opportunities[0].Main_Contact__c, SBQQ__Primary__c = true, Invoice_Frequency__c = 'Annual'));
        
       
        quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[1].Id, SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'Draft', 
                                      SBQQ__StartDate__c = Date.today() , SBQQ__EndDate__c = Date.today().addDays(2), recordTypeId = QuoteOpenRecordType,
                                      SBQQ__PrimaryContact__c = opportunities[0].Main_Contact__c, SBQQ__Primary__c = true, Invoice_Frequency__c = 'ES-75-25',Is_Enrollment_Services__c =true));
        
        //Insert Opportunity
        insert quotes;
       
        //List to hold Contract records to insert
        List<Contract> contracts = new List<Contract>();
        
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 36,
                                   AccountId = opportunities[0].AccountId, SBQQ__Opportunity__c = opportunities[0].Id,
                                   SBQQ__Quote__c = quotes[0].Id, Invoicing_Arrangement__c = 'Annual', Billing_Schedule_Automated_Status__c = 'Completed'));
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(5), EndDate = System.today().addDays(15), 
                                   ContractTerm = 30, AccountId = opportunities[1].AccountId, SBQQ__Opportunity__c = opportunities[1].Id,
                                   SBQQ__Quote__c = quotes[1].Id, Billing_Schedule_Automated_Status__c = 'Awaiting Processing', Invoicing_Arrangement__c = 'ES-75-25'));    
        
        insert contracts;

        //create Contract ABC test data
        Contract__c contractABC = new Contract__c(Name = 'TestContract1', Invoicing_Arrangement__c = 'Special', Payer_Account__c = opportunities[0].AccountId,
                                                Year__c = '2017', Type__c = 'NBB', Main_Contact__c = opportunities[0].Main_Contact__c, Invoice_Contact__c = opportunities[0].Main_Contact__c,
                                                Negotiated_Amount__c = 12 );

        //Insert the contract ABC
        insert contractABC;
        
        Contract__c contractABC2 = new Contract__c(Name = 'TestContract2', Invoicing_Arrangement__c = 'Special', Payer_Account__c = opportunities[1].AccountId,
                                                Year__c = '2017', Type__c = 'NBB', Main_Contact__c = opportunities[1].Main_Contact__c, Invoice_Contact__c = opportunities[1].Main_Contact__c,
                                                Negotiated_Amount__c = 12 );

        //Insert the contract ABC
        insert contractABC2;

        Test.startTest();
        //List to hold subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();  

        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000, Previous_Contract_ABC__c = contractABC.Id,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 3, Previous_Period_Plus_Uplift__c = 2000,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id, Previous_Contract_ABC__c = contractABC.Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));                                                       
        //Insert
        insert subscriptions;
	       
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //List to hold the Subscription Period records
        List<Subscription_Period__c> listOfSubscriptionPeriod = new List<Subscription_Period__c>();
        List<User> usrs = [Select Id, Name From User Order By Name ASC Limit 2];
        //Add the new 
        listOfSubscriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[0].Id, Period_Start_Date__c = Date.Today(), Period_End_Date__c = Date.Today() + 5,
                                                              Renewal_Negotiated__c = 12,Negotiated_Amount_Period__c = 10, Stage__c = 'Honorary', Segment_Index__c = 3, Opt_Out_Date__c = Date.today(), Renewal_Owner__c = usrs[0].Id, Research_Strategic_Leader__c = usrs[0].Id, Contract__c = contracts[0].Id));
        listOfSubscriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[0].Id, Period_Start_Date__c = Date.Today() + 2,Period_End_Date__c = Date.Today() + 5, 
                                                              Renewal_Negotiated__c = 10, Negotiated_Amount_Period__c = 12, Stage__c = 'Pending', Segment_Index__c = 100, Opt_Out_Date__c = Date.today(), Renewal_Owner__c = usrs[0].Id, Research_Strategic_Leader__c = usrs[0].Id, Contract__c = contracts[0].Id));
        listOfSubscriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[1].Id, Period_Start_Date__c = Date.Today() + 3, Period_End_Date__c = Date.Today() + 5,
                                                              Stage__c = CPQConstants.SUBSCRIPTION_PERIOD_STAGE_DROPPED, Segment_Index__c = 13, Opt_Out_Date__c = Date.today(), Renewal_Owner__c = usrs[0].Id, Research_Strategic_Leader__c = usrs[0].Id, Contract__c = contracts[1].Id));                                                     
        listOfSubscriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[1].Id, Period_Start_Date__c = Date.Today() + 5, Period_End_Date__c = Date.Today() + 8,
                                                                Stage__c = Constants.SUBSCRIPTION_PERIOD_STATUS_ATL, Segment_Index__c = 1, Opt_Out_Date__c = Date.today(), Renewal_Owner__c = usrs[0].Id, Research_Strategic_Leader__c = usrs[0].Id, Contract__c = contracts[0].Id));                                                      
        //Insert the listOfSubscriptionPeriod
        insert listOfSubscriptionPeriod;
        
        listOfSubscriptionPeriod[0].Negotiated_Amount_Period__c = 20;
        listOfSubscriptionPeriod[0].Renewal_Negotiated__c = 20;
        listOfSubscriptionPeriod[1].Stage__c = Constants.SUBSCRIPTION_PERIOD_STATUS_ATL;
        listOfSubscriptionPeriod[3].Stage__c = Constants.SUBSCRIPTION_PERIOD_STATUS_PENDING;
        update listOfSubscriptionPeriod; 
        
        //Query on subscription period records 
        listOfSubscriptionPeriod = [Select Id, Stage__c From Subscription_Period__c];
        System.assertEquals(Constants.SUBSCRIPTION_PERIOD_STATUS_ATL,  listOfSubscriptionPeriod[1].Stage__c);
    } 
}