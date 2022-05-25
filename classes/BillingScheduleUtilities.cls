/**
*  Description     :  Utility class which contains methods for creation/editing of Billing Schedule Header, Billing Schedule Periods and Billing Schedule Lines
*
*  Created By      :  Colin McGloin
*
*  Created Date    :  10/29/2019
*
*  Revision Log    :   V1.0 - Created
*                      V1.1 - Modified by - Mahendra Swarnkar - 11/19/2020 - CR-20201106-14672 - Billing - BSL different than SIN Total Billing Amt
*                      V1.2 - Modified By - Mahendra Swarnkar - 12/08/2020 - Issue--CR14672--QA--00010296 - Recalculation is still executing on Periods with invoice
*		       V1.3 - Modified By - Colin McGloin - 02/16/2021 - CR-20201110-14685 - Annual Frequency Not Working with Prorated Periods - Issue on Period creation
*/

public without sharing class BillingScheduleUtilities {
    
    //Set to store the Program Subscription Statuses we wish to exclude
    public static final Set<String> bypassProgSubStatuses = new Set<String> {'Void', 'Honorary', 'Dropped', 'Expired', 'Void-Amended'};
    
    //Map to set duration of Months per Invoicing Arrangement // "75/25 Split"
    public static final Map<String, Integer> mapInvArrangementToNumber = new Map <String, Integer> {'Annual' => 12, 'Semi-Annual' => 6, 'Quarterly' => 3, 'Monthly' => 1, 'ES-75-25' => 6};
     
    public static final Map<String, Integer> mapInvArrangementToNumberOfPeriodsPerYear = new Map <String, Integer> {'Annual' => 1, 'Semi-Annual' => 2, 'Quarterly' => 4, 'Monthly' => 12, 'ES-75-25' => 2};
    
    //Map which contains the time period between Periods
    public static final Map<String, Integer> mapInvArrangementToPeriodDuration = new Map <String, Integer> {'Annual' => 365, 'Semi-Annual' => 181, 'Quarterly' => 90, 'Monthly' => 29, 'ES-75-25' => 181};
     
    //This method is used to create Billing Schedule Headers for Standard Contracts just created by the CPQ process
    public static void createBillingScheduleHeadersFromContract (List<Contract> allContracts) {
        
        //List of wrappers for insertion
        List<BillingScheduleHeaderWrapper> BSHWrappersForInsert = new List<BillingScheduleHeaderWrapper>();
        
        //Map for Insert
        Map<String, BillingScheduleHeaderWrapper> mapUniqueToBSHW = new Map<String, BillingScheduleHeaderWrapper>();
        
        //List for updating Contracts
        List<Contract> consToUpdate = new List<Contract>();
        
        if(allContracts == null ){
        	
            //Query for all Standard Contract records which have not been processed yet
        	allContracts = [SELECT Id, Name, CreatedDate, Billing_Schedule_Automated_Status__c,Invoice_Contact__c, AccountId,Invoicing_Arrangement__c,
                                       (SELECT Id, Name, SBQQ__Contract__c, Invoicing_Arrangement__c, Invoice_Contact__c, SBQQ__Product__c, SBQQ__Product__r.Family FROM SBQQ__Subscriptions__r WHERE RecordType.Name = 'Program' And Invoicing_Arrangement__c != null) 
                                       FROM Contract
                                       WHERE Billing_Schedule_Automated_Status__c = 'Awaiting Processing'];

        }
        
        //Check to see if we have any records to process
        if (allContracts.size() > 0) {
            
            //Loop through our Contract records
            for (Contract con  : allContracts) {
                
                //Add boolean which will be used to denote if this Product should have Enrollment Services rules applied
                boolean enrollmentServicesProduct = false;

                //Add boolean which will be used to denote if this Product should have YouVisit rules applied
                boolean youVisitProduct = false;
                
                //Check to see if we have any Program Subscriptions linked
                if (con.SBQQ__Subscriptions__r != null){
                    
                    //Loop through our Program Subscription records
                    for (SBQQ__Subscription__c progSub : con.SBQQ__Subscriptions__r){

                        //Check our Program Subscription Product family
                        if (progSub.SBQQ__Product__r.Family != null && progSub.SBQQ__Product__r.Family == System.Label.Enrollment_Services_Product_Family){
                            enrollmentServicesProduct = true;
                        }

                        //Check our Program Subscription Product family & set record as a YouVisit Scenario if needed
                        if (progSub.SBQQ__Product__r.Family != null && progSub.SBQQ__Product__r.Family == System.Label.Youvisit_Product_Family){
                            youVisitProduct = true;
                        }
                        
                    }
                    
                }

                //Check our Map for Unique Key
                BillingScheduleHeaderWrapper bshToCreate = new BillingScheduleHeaderWrapper(con.Id, con.Invoicing_Arrangement__c, con.Invoice_Contact__c, con.AccountId, enrollmentServicesProduct, youVisitProduct);

                //Add Wrapper to List
                BSHWrappersForInsert.add(bshToCreate);
                
                //Update our Contract Status to note it's run through the process
                con.Billing_Schedule_Automated_Status__c = 'Completed';
                consToUpdate.add(con);

            }
        }
        
        //Check to see if we have Billing Schedule Records to insert
        if (BSHWrappersForInsert.size() > 0) {
            
            //Get our List back of Billing Schedule Header records to insert
            List <Billing_Schedule_Header__c> BSHToInsert = createBillingScheduleHeader(BSHWrappersForInsert);
            insert BSHToInsert;

            //Call our method to create the Billing Schedule Periods
            createBillingSchedulePeriods(BSHToInsert, null);
        }
        
        //Check for our Contracts and update
        if (consToUpdate.size() > 0) {
            Util.BypassAllTriggers = true;
            update consToUpdate;
            Util.BypassAllTriggers = false;
        }

        System.debug('BSH - After Limits' + Limits.getCpuTime());
        
    }
    
    //Modified by Colin McGloin - 02/16/2021 - CR-20201110-14685
    public static void createBillingSchedulePeriods (List<Billing_Schedule_Header__c> parentBSH, Map<Id, Billing_Schedule_Period__c> mapLockedPeriods) {

        //Create a Map which associates our Program Subscriptions with the relevant Invoicing Arrangements
        Map <Id, Map<Billing_Schedule_Header__c, List<SBQQ__Subscription__c>>> mapConMapInvArrProgSub = new Map<Id, Map<Billing_Schedule_Header__c, List<SBQQ__Subscription__c>>>();

        //Map for Contract ID to BSH
        Map<Id, Billing_Schedule_Header__c> mapConIdToBSH = new Map<Id, Billing_Schedule_Header__c>();

        //Map BSH to Compo Subs
        Map<Billing_Schedule_Header__c, List<SBQQ__Subscription__c>> bshToCompSubs = new Map <Billing_Schedule_Header__c, List<SBQQ__Subscription__c>>();

        system.debug('parentBSHsize' + parentBSH.size());

        //Loop through our records
        for (Billing_Schedule_Header__c bsh : parentBSH){

            system.debug('Contract ID' + bsh.Standard_Contract__c);

            //Add our BSH to Map
            mapConIdToBSH.put(bsh.Standard_Contract__c, bsh);

        }

        //Once we have our Invoicing Arrangements then let's go and get all of the relevant Program Subscriptions
        if (mapConIdToBSH.keyset().size() > 0){

	    //Loop through our Program Subscriptions related to the Contract
            List<SBQQ__Subscription__c> compSubs  = [SELECT Id, Name, SBQQ__SubscriptionStartDate__c, SBQQ__SubscriptionEndDate__c, Status__c, 
                                                    SBQQ__Product__r.Family, SBQQ__Contract__r.Createddate,SBQQ__Contract__c, SBQQ__Contract__r.StartDate, SBQQ__Contract__r.Invoicing_Arrangement__c, SBQQ__Contract__r.EndDate, Invoicing_Arrangement__c,
                                                    SBQQ__SegmentIndex__c, SBQQ__SegmentStartDate__c, SBQQ__SegmentEndDate__c, Program_Subscription__r.Invoicing_Arrangement__c,
                                                    Program_Subscription__r.SBQQ__Product__r.Family
                                                    FROM SBQQ__Subscription__c
                                                    WHERE SBQQ__Contract__c IN :mapConIdToBSH.keyset()
                                                    AND Status__c NOT IN :bypassProgSubStatuses
                                                    AND RecordType.Name = 'Component'
                                                    ORDER BY SBQQ__SegmentIndex__c ASC];
            
            //Check to see if we have Subs
            if (compSubs.size() > 0){

                //Loop through our BSH records
                for (SBQQ__Subscription__c sub : compSubs){

                    //Check for our Contract in the Map
                    if (mapConIdToBSH.get(sub.SBQQ__Contract__c) != null){

                        //Get our BSH
                        Billing_Schedule_Header__c bsh = mapConIdToBSH.get(sub.SBQQ__Contract__c);

                        //Check our BSH to Sub map
                        if (bshToCompSubs.get(bsh) != null){
                            List<SBQQ__Subscription__c> subs = bshToCompSubs.get(bsh);
                            subs.add(sub);
                            bshToCompSubs.put(bsh, subs);
                        } else {
                            List<SBQQ__Subscription__c> subs = new List<SBQQ__Subscription__c>();
                            subs.add(sub);
                            bshToCompSubs.put(bsh, subs);
                        }

                    }

                }

            }

            //List for storing our Wrappers
            List<BillingSchedulePeriodWrapper> bspwList = new List<BillingSchedulePeriodWrapper>();

            //Check to see we have records
            if (bshToCompSubs.size() > 0){

                //Loop through our BSH
                for (Billing_Schedule_Header__c bsh : bshToCompSubs.keyset()){

                    System.debug ('Starting new BSH: ' + bsh.Name);

                    //Create a Map for associating our Component Subs with their respective Segment Indexes
                    Map <Integer, List<SBQQ__Subscription__c>> mapSegmentIndexToComponents = new Map<Integer, List<SBQQ__Subscription__c>>();

                    //Get our Prog Subs
                    List<SBQQ__Subscription__c> progSubs = bshToCompSubs.get(bsh);
                    System.debug ('ProgSubs Size: ' + progSubs.size());
                        
                    //Check for List size
                    if (progSubs != null && progSubs.size() > 0){
                        
                        //Added By - Mahendra swarnkar - 06/24/2020 - CR-20200609-14162 - start from here
                        Date firstsegmentStartDate;
                        Date firstsegmentEndDate;
                        Boolean IsTwoPeriodForFirstSegment = false;
                        //Added By - Mahendra swarnkar - 06/24/2020 - CR-20200609-14162 - Ends here

                        Integer j = progSubs.size();
                        
                        //Loop through our Program Subscriptions and denote the Product Family
                        for (Integer i = 0; i < j; i++) {

                            //Add our Components to our Map based on Segment Index
                            if (progSubs[i].SBQQ__SegmentIndex__c != null){
                                
                                //Added By - Mahendra swarnkar - 06/24/2020 - CR-20200609-14162 - start from here
                                if(progSubs[i].SBQQ__SegmentIndex__c == 1){
                                    firstsegmentStartDate = progSubs[i].SBQQ__SegmentStartDate__c;
                                    firstsegmentEndDate = progSubs[i].SBQQ__SegmentEndDate__c;
                                    if(firstsegmentStartDate.year() != firstsegmentEndDate.year())
                                        IsTwoPeriodForFirstSegment = true;
                                }
                                //Added By - Mahendra swarnkar - 06/24/2020 - CR-20200609-14162 - Ends here
                                
                                if (mapSegmentIndexToComponents.get(Integer.valueof(progSubs[i].SBQQ__SegmentIndex__c)) == null){
                                    List<SBQQ__Subscription__c> subs = new List<SBQQ__Subscription__c>();
                                    subs.add(progSubs[i]);
                                    mapSegmentIndexToComponents.put(Integer.valueof(progSubs[i].SBQQ__SegmentIndex__c), subs);
                                } else {
                                    List<SBQQ__Subscription__c> subs = new List<SBQQ__Subscription__c>();
                                    subs = mapSegmentIndexToComponents.get(Integer.valueof(progSubs[i].SBQQ__SegmentIndex__c));
                                    subs.add(progSubs[i]);
                                    mapSegmentIndexToComponents.put(Integer.valueof(progSubs[i].SBQQ__SegmentIndex__c), subs);
                                }
                            }

                        }

                        //Enrollment Services Logic
                        if (mapSegmentIndexToComponents.size() > 0 && bsh.Enrollment_Services_Product__c == true){

                            system.debug('Enrollment Services Logic Entered');

                            //Counter for the Installment Numbers
                            Integer installmentCounter = 0;
                            
                            //Mahendra Swarnakar - CR-20200609-14162 - 7/3/20202 - start -
                            Integer billingSegmentCount = 0;
                            //Mahendra Swarnakar - CR-20200609-14162 - End - 
                            
                            //Get our start Date
                            Date contractStartDate = progSubs[0].SBQQ__Contract__r.StartDate;
                            Date contractEndDate = progSubs[0].SBQQ__Contract__r.EndDate;
                            
                            //Used in the loop
                            Date startDate;
                            Date endDate;
                            

                            boolean runLogic = true;                                
                            Integer innerInstallmentcounter = 0;
                            Date PreviousInstallementStartDate;
                            Date PreviousInstallementEndDate;
                                
                            //Added by Colin McGloin - CR-20201110-14685
                            boolean finalLoop = false;

                            //Calculate Number of Periods Needed && the duration between them
                            Integer numOfPeriods = 0;
                            Integer calculateIntervalBetweenPeriod = 0;

                            system.debug('Number of Segment Index Values: ' + mapSegmentIndexToComponents.keySet().size());
                            
                            for(Integer k = 0; k < mapSegmentIndexToComponents.keySet().size(); k++ ){
                                
                                //Calculate our Periods
                                numOfPeriods = mapInvArrangementToNumberOfPeriodsPerYear.get(bsh.Invoicing_Arrangement__c);
                                
                                system.debug('numOfPeriods: ' + numOfPeriods);
                                system.debug('value of k' + k);
                                
                                //Check to see if the First year is one segment or two
                                /*if (!IsTwoPeriodForFirstSegment){
                                    numOfPeriods--;
                                    //Set flag to true 
                                    IsTwoPeriodForFirstSegment = true;
                                }*/
                                
                                for (Integer i = 0; i < numOfPeriods; i++) {
                                    
                                    boolean increaseBillingSegment = false;
                                    
                                    //Increment our Installment Counter
                                    installmentCounter++;
                                    innerInstallmentcounter++;
                                    Date billDate;
                                    
                                    system.debug('i value' + i);
                                    system.debug('installmentCounter - start of loop' + installmentCounter);
                                    system.debug('innerInstallmentcounter - start of loop' + innerInstallmentcounter);
                                    
                                    //Added By - Mahendra swarnkar - 06/24/2020 - CR-20200609-14162 - start from here
                                    
                                    if(bsh.Invoicing_Arrangement__c == 'ES-75-25'){
                                        Boolean IsEvenInstallment = math.mod(installmentCounter, 2) == 0 ? True : False ;
                                        if(installmentCounter == 1){
                                            
                                            startDate = firstsegmentStartDate;
                                            endDate = firstsegmentEndDate;
                                            billingSegmentCount = 1;
                                        } else {
                                            
                                            if(innerInstallmentcounter == 2){
                                                startDate = PreviousInstallementStartDate;
                                                endDate = PreviousInstallementEndDate;
                                            }
                                        }
                                        
                                        if(startDate.year() == endDate.year() || (startDate.year() != endDate.year() && innerInstallmentcounter == 2) ){
                                            innerInstallmentcounter = 0;
                                            increaseBillingSegment = true;
                                            
                                        }
                                        
                                        if((startDate.year() == endDate.year() && IsEvenInstallment) || ( !IsEvenInstallment && startDate.year() != endDate.year()))
                                            billDate =  date.newinstance(startDate.year(),7,1); 
                                        
                                        if((startDate.year() == endDate.year() && !IsEvenInstallment) || ( IsEvenInstallment && startDate.year() != endDate.year()))
                                            billDate =  date.newinstance(endDate.year(),1,1);
                                        
                                        if(installmentCounter == 1){ 
                                            billDate = progSubs[0].SBQQ__Contract__r.CreatedDate.date();
                                        }
                                        
                                        PreviousInstallementStartDate = startDate;
                                        PreviousInstallementEndDate = endDate;
                                        
                                    } else {
                                        
                                        //Added By - Mahendra swarnkar - 06/24/2020 - CR-20200609-14162 - Ends here 	
                                        if (installmentCounter == 1){
                                            
                                            startDate = contractStartDate;
                                            
                                            //Check our End Date
                                            if (startDate.Month() == 1 || startDate.Month() == 2 || startDate.Month() == 3 || startDate.Month() == 4 || startDate.Month() == 5 || startDate.Month() == 6){
                                                endDate = Date.newInstance(startDate.Year(), 6, 30);
                                            } else {
                                                endDate = Date.newInstance(startDate.Year() + 1, 6, 30);
                                            }
                                        }
                                        
                                        //Calculate our Bill Date
                                        billDate = startDate.addDays(-30);
                                    }
                                    
                                    System.debug('%%%StartDate' + startDate);
                                    System.debug('%%%EndDate' + endDate);
                                    
                                    system.debug('installmentCounter - post logic' + installmentCounter);
                                    system.debug('innerInstallmentcounter - post logic' + innerInstallmentcounter);
                                    
                                    //Calculate our Bill Date
                                    //Date billDate = startDate.addDays(-30);
                                    
                                    //Check to make sure our End Date is before the end of the Contract
                                    if (endDate >= contractEndDate){
                                        endDate = contractEndDate;
                                        if(innerInstallmentcounter == 0){
                                            finalLoop = true;
                                        }
                                        system.debug('runLogic - endDate Check: ' + runLogic);
                                    }
                                    
                                    //Merged in by Colin McGloin as part of CR-20201110-14685
                                    if (startDate >= contractEndDate){
                                        runLogic = false;
                                        system.debug('runLogic - startDate Check: ' + runLogic);
                                    }
                                    
                                    if(runLogic) {
                                        //Create our Billing Schedule Period Wrapper
                                        BillingSchedulePeriodWrapper bspWrapper = new BillingSchedulePeriodWrapper(billDate, startDate, endDate, bsh.Id, installmentCounter, billingSegmentCount);   
                                        
                                        if(increaseBillingSegment)
                                            billingSegmentCount ++;
                                        
                                        //Add our Wrapper to the List
                                        bspwList.add(bspWrapper);
                                        system.debug('bspwList size:' + bspwList.size());
                                        system.debug('Period Installment Counter:' + installmentCounter);
                                        
                                        //Check to see if this is our Final Loop and mark runLogic as false to ensure this does not create another record
                                        if (finalLoop){
                                            runLogic = false;
                                        }
                                    }
                                    
                                    //Increment our Periods
                                    if(startDate != null)
                                        startDate = endDate.addDays(1);
                                    if(endDate != null)
                                        endDate = endDate.addYears(1);
                                    if(billDate != null)   
                                        billDate = billDate.addYears(1);
                                    
                                    System.debug('^^^^' + startDate);
                                    System.debug('^^^^^^' + endDate);
                                    
                                }
                                
                            }

                        }
                        
                        //Regular Tech Product Logic
                        else if(mapInvArrangementToNumber.containsKey(bsh.Invoicing_Arrangement__c) && mapSegmentIndexToComponents.size() > 0 && bsh.Enrollment_Services_Product__c == false){

                            //Counter for the Installment Numbers
                            Integer installmentCounter = 0;

                            //Loop through each of our Segments and go through the Period Creation process
                            for (Integer segIndex : mapSegmentIndexToComponents.keyset()) {

                                //Start and End Dates
                                Date startCompSubStartDate = mapSegmentIndexToComponents.get(segIndex)[0].SBQQ__SegmentStartDate__c;
                                Date startCompSubEndDate = mapSegmentIndexToComponents.get(segIndex)[0].SBQQ__SegmentEndDate__c;
                                
                                //Calculate Number of Periods Needed && the duration between them
                                Integer numOfPeriods = 0;
                                Integer calculateIntervalBetweenPeriod = 0;

                                //Check to ensure the Duration between the two dates is at least a year and calculate Number of Periods
                                if (startCompSubStartDate.daysBetween(startCompSubEndDate) < 364){
                                    numOfPeriods = calculatePeriodsForSubscription(mapSegmentIndexToComponents.get(segIndex)[0], bsh.Invoicing_Arrangement__c);
                                } else {
                                    numOfPeriods = mapInvArrangementToNumberOfPeriodsPerYear.get(bsh.Invoicing_Arrangement__c);
                                }

                                system.debug('R&T Segment Index: ' + segIndex);
                                system.debug('R&T Num of Periods: ' + numOfPeriods);
                                
                                //Calculate Interval between Periods based on Invoicing Arrangement
                                calculateIntervalBetweenPeriod = mapInvArrangementToPeriodDuration.get(bsh.Invoicing_Arrangement__c);
                                
                                //Calculate our Start Date - this needs to be refactored for Billing Sched Rules
                                Date billDateCalc = startCompSubStartDate - 30;
                                
                                List <Billing_Schedule_Period__c> listExistingBillingSchedulePeriods = new List <Billing_Schedule_Period__c>();
                                if(mapLockedPeriods != null && mapLockedPeriods.size() > 0 && mapLockedPeriods.values() != null && mapLockedPeriods.values().size() > 0) {
                                    listExistingBillingSchedulePeriods.addAll(mapLockedPeriods.values());
                                }
                                
                                Date startDate = startCompSubStartDate;
                                Date endDate;

                                //Calulate our End Date
                                if (startDate.month() == 2 && bsh.Invoicing_Arrangement__c == 'Monthly'){
                                    Integer endDaysInMonth = Date.daysInMonth(startDate.Year(), startDate.Month());
                                    endDate = Date.newInstance(startDate.Year(), startDate.month(), endDaysInMonth);
                                } else {
                                    endDate = startCompSubStartDate.addDays(calculateIntervalBetweenPeriod);
                                }
                                
                                //Loop through and create our Billing Schedule
                                for (Integer i = 1; i <= numOfPeriods; i++) {

                                    //Increase our Installment Counter
                                    installmentCounter++;
                                    
                                    //Flag to check for existing periods
                                    Boolean isExistingPeriod = false;
                                    
                                    //Check for size
                                    if(listExistingBillingSchedulePeriods.size() > 0) {
                                        
                                        //process the list and check if this periods is already exist under the relared billing schedule header  
                                        isExistingPeriod = existingBillingSchedulePeriod(listExistingBillingSchedulePeriods, startCompSubStartDate, startCompSubStartDate.addDays(calculateIntervalBetweenPeriod));
                                        
                                        //If existing period the continue to next period
                                        if(isExistingPeriod){
                                            startDate = startDate.addDays(calculateIntervalBetweenPeriod);

                                            //Calculate Billing Date
                                            billDateCalc = billDateCalc.addDays(calculateIntervalBetweenPeriod);
                                            
                                            continue;
                                            }
                                        }

                                        //YouVisit Logic
                                        //Added by Colin McGloin - CR-20200706-14267
                                        if (bsh.YouVisit_Product__c == true ){

                                            //See how many days are in our Month
                                            Integer endDaysInMonth = Date.daysInMonth(endDate.Year(), endDate.Month());
                                            system.debug('endDaysInMonth: ' + endDaysInMonth);

                                            //Grab our Contract Start Date
                                            Date contractStartDate = progSubs[0].SBQQ__Contract__r.StartDate;
                                            Date contractCreatedDate = progSubs[0].SBQQ__Contract__r.CreatedDate.Date();

                                            system.debug('startDate preYouVisitLogic: ' + startDate);

                                            //Start Date should be the 1st of the Month if applicable aside from first installment which starts from the beginning of the Contract
                                            if (startDate != contractStartDate){
                                                if (startDate.day() != 1){
                                                    startDate = Date.newInstance(startDate.Year(), startDate.month(), 1);
                                                }
                                            }

                                            system.debug('startDate postYouVisitLogic: ' + startDate);

                                            system.debug('endDate preYouVisitLogic: ' + endDate);

                                            //Our End Date should be the last day of the Month if applicable
                                            if (endDate.day() != endDaysInMonth){
                                                endDate = Date.newInstance(endDate.Year(), endDate.month(), endDaysInMonth);
                                            }

                                            system.debug('endDate postYouVisitLogic: ' + endDate);

                                            system.debug('billDateCalc preYouVisitLogic: ' + billDateCalc);

                                            //Our Billing Date should always be the 1st of the Month Before
                                            if (billDateCalc.day() != 1){
                                                billDateCalc = Date.newInstance(startDate.Year(), (startDate.Month() - 1), 1);
                                            }

                                            //Double Check our Bill Date Calc is not before our Created Date
                                            if (billDateCalc < contractCreatedDate){
                                                billDateCalc = contractCreatedDate;
                                            }

                                            system.debug('billDateCalc postYouVisitLogic: ' + billDateCalc);

                                        }

                                        //Ensure our first Period doesn't have an over extended Period Date
                                        if (endDate > startCompSubEndDate){
                                            endDate = startCompSubEndDate;
                                        }
                                        
                                        //Create our Billing Schedule Period Wrapper
                                        BillingSchedulePeriodWrapper bspWrapper = new BillingSchedulePeriodWrapper(billDateCalc, startDate, endDate, bsh.Id, installmentCounter,0);
                                    
                                    //Add our Wrapper to the List
                                    bspwList.add(bspWrapper);
                                    System.debug('R&T bspwList size:' + bspwList.size());
                                    
                                    //Calculate Billing Date
                                    billDateCalc = billDateCalc.addDays(calculateIntervalBetweenPeriod);

                                    //Calculate our next Start Date
                                    startDate = endDate.addDays(1);

                                    //Set our End Date
                                    if (startDate.month() == 2){
                                        endDate = startDate.addDays(27);
                                    } else {
                                        endDate = startDate.addDays(calculateIntervalBetweenPeriod);
                                    }
                                    
                                    //Check to see if the End Date is after the Contract End Date and correct if needed
                                    if (endDate > startCompSubEndDate || (i + 1) == numOfPeriods){
                                        endDate = startCompSubEndDate;
                                    }

                                }
                            }
                        }

                    }

                }

            }

            //Insert our Billing Schedule Periods
            if (bspwList.size() > 0){
                List <Billing_Schedule_Period__c> BSPToInsert = createBillingSchedulePeriods(bspwList);
                
                System.debug('BSP - List Size: ' + BSPToInsert.size());
                
                insert BSPToInsert;

                System.debug('BSH - After Periods' + Limits.getCpuTime());
                
                //Create childs only if there is no recalculation of billing schedules is performed
                if(mapLockedPeriods == null)
                    //Insert the billing schedule lines
                    createBillingScheduleLines(BSPToInsert, parentBSH, null);
            }
        }
    }

    public static boolean existingBillingSchedulePeriod (List<Billing_Schedule_Period__c> existingBillingSchedulePeriods, Date startDate, Date endDate){

        //Variable for saying Yes/No
        boolean existingBSP = false;
        
        //Loop through our Program Subscription
        for (Billing_Schedule_Period__c bsp : existingBillingSchedulePeriods){

            if((startDate >= bsp.Billing_Schedule_Period_Start_Date__c && startDate < bsp.Billing_Schedule_Period_End_Date__c) ||
                (endDate > bsp.Billing_Schedule_Period_Start_Date__c && endDate <= bsp.Billing_Schedule_Period_End_Date__c)) {

                    //Set our variable to true
                    existingBSP = true;

                }
        }

        return existingBSP;
    }

    public static Integer calculateMonthDuration (List<SBQQ__Subscription__c> progSubs) {

        //Start Date List
        List<Date> startDates = new List<Date>();

        //End Date List
        List<Date> endDates = new List<Date>();

        //Loop through our Program Subscriptions and get our Start and End Dates
        for (SBQQ__Subscription__c sub : progSubs){
            
            if (sub.SBQQ__SubscriptionStartDate__c != null){
                startDates.add(sub.SBQQ__SubscriptionStartDate__c);
            }
            
            if (sub.SBQQ__SubscriptionEndDate__c != null){
                endDates.add(sub.SBQQ__SubscriptionEndDate__c);
            }
        }

        Integer monthsDuration = 0;

        //Sort the Lists
        if (startDates.size() > 0 && endDates.size() > 0){
            startDates.sort();
            endDates.sort();

            //Get our Earliest and Latest Dates
            Date earliestDate = startDates[0];
            Date latestDate = endDates[(endDates.size() - 1)];
            monthsDuration = earliestDate.monthsBetween(latestDate);

            //Compare our MonthsBetween and DaysBetween and if there is a period of Days between then add an extra Period
            Date monthDurationDate = earliestDate.addMonths(monthsDuration);
            if (monthDurationDate < latestDate) {
                monthsDuration ++;
            }
        }

        //Return our Duration value
        return monthsDuration;

    }
    
    public static List<Billing_Schedule_Header__c> createBillingScheduleHeader (List<BillingScheduleHeaderWrapper> bshWrappers) {
        
        //Create a list for our final Billing Schedule Header records
        List<Billing_Schedule_Header__c> bshRecords  = new List<Billing_Schedule_Header__c>();
        
        //Loop through our Wrapper records and create our Billing Schedule Header records
        for (BillingScheduleHeaderWrapper bshWrapper : bshWrappers){
            
            //Populate our fields
            Billing_Schedule_Header__c bsh = new Billing_Schedule_Header__c();
            bsh.Standard_Contract__c = bshWrapper.contractId;
            bsh.Invoicing_Arrangement__c = bshWrapper.invoicingArrangement;
            bsh.Invoice_Contact__c = bshWrapper.invoiceContact;
            bsh.Institution__c = bshWrapper.institutionId;
            bsh.Enrollment_Services_Product__c = bshWrapper.enrollmentServicesProduct;
            bsh.YouVisit_Product__c = bshWrapper.youVisitProduct;
            bshRecords.add(bsh);
        }
        
        //Return our created records
        return bshRecords;
        
    }

    public static List<Billing_Schedule_Period__c> createBillingSchedulePeriods (List<BillingSchedulePeriodWrapper> bspWrappers){

        //Create a list for our final Billing Schedule Period records
        List<Billing_Schedule_Period__c> bspRecords = new List<Billing_Schedule_Period__c>();
        
        //Loop through our Wrapper records and create our Billing Schedule Period records
        for (BillingSchedulePeriodWrapper bspWrapper : bspWrappers){
            
            //Populate our fields
            Billing_Schedule_Period__c bsp = new Billing_Schedule_Period__c();
            bsp.Billing_Date_Calculated__c = bspWrapper.billingDateCalculated;
            bsp.Billing_Schedule_Period_Start_Date__c = bspWrapper.billingPeriodStart;
            bsp.Billing_Schedule_Period_End_Date__c = bspWrapper.billingPeriodEnd;
            bsp.Billing_Schedule_Header__c = bspWrapper.billSchedHeader;
            bsp.Installment__c = bspWrapper.InstallmentNum;
            bsp.Billing_Segment__c = bspWrapper.billingSegment;
            bspRecords.add(bsp);

            System.debug('BSH ID' + bsp.Billing_Schedule_Header__c);
            System.debug('Insert Start Date' + bsp.Billing_Schedule_Period_Start_Date__c);
            System.debug('Insert End Date' + bsp.Billing_Schedule_Period_End_Date__c);
        }
        
        //Return our created records
        return bspRecords;

    }
    
    public class BillingScheduleHeaderWrapper {
        
        public Id contractId;
        public String invoicingArrangement;
        public Id invoiceContact;
        public Id institutionId;
        public boolean enrollmentServicesProduct;
        public boolean youVisitProduct;
        
        public BillingScheduleHeaderWrapper (Id contractId, String invoicingArrangement, Id invoiceContact, Id institutionId, boolean enrollmentServicesProduct, boolean youVisitProduct) {
            
            this.institutionId = institutionId;
            this.contractId = contractId;
            this.invoicingArrangement = invoicingArrangement;
            this.invoiceContact = invoiceContact; 
            this.enrollmentServicesProduct = enrollmentServicesProduct;
            this.youVisitProduct = youVisitProduct;
        } 
        
    }

    //------- Mahendra Swanakar - CR-20200609-14162 - 7/3/2020 ( add the billingSegment in wrapper ) ------  
    public class BillingSchedulePeriodWrapper {

        public Date billingDateCalculated;
        public Date billingPeriodStart;
        public Date billingPeriodEnd;
        public Id billSchedHeader;
        public Integer InstallmentNum;
        public Integer billingSegment;

        public BillingSchedulePeriodWrapper (Date billingDateCalculated, Date billingPeriodStart, Date billingPeriodEnd, Id billSchedHeader, Integer InstallmentNum, Integer billingSegment){

            this.billingDateCalculated = billingDateCalculated;
            this.billingPeriodStart = billingPeriodStart;
            this.billingPeriodEnd = billingPeriodEnd;
            this.billSchedHeader = billSchedHeader;
            this.InstallmentNum = InstallmentNum;
            this.billingSegment = billingSegment;

        }

    }
    
    //Create Billing schedule Lines
    public static void createBillingScheduleLines (List<Billing_Schedule_Period__c> parentBSP, List<Billing_Schedule_Header__c> parentBSH, Map<Id, Billing_Schedule_Period__c> mapLockedPeriods) {
    	
    	//map to hold the Billing schedule lines.
    	Map<Id, Billing_Schedule_Header__c> mapBSH = new Map<Id, Billing_Schedule_Header__c>();
    	mapBSH.putAll(parentBSH);
    	
    	//Set to hold the contract Ids
    	Set<Id> setContractIds = new Set<Id>();
    	
    	//Map to hold the uniqueKey with BSH Id.
    	Map<String, Id> mapUniqueKeyWithBSHId = new Map<String, Id>();
    	
    	//Loop over the BSH records
    	for(Billing_Schedule_Header__c bsh : mapBSH.values()){
    		
    		//Check for standard contract on the BSH
    		if(bsh.Standard_Contract__c != null){
    			
    			//populate the set
    			setContractIds.add(bsh.Standard_Contract__c);
    			
    			//Check for the condition and populate the map
    			if(bsh.Invoicing_Arrangement__c != null )
    				mapUniqueKeyWithBSHId.put(bsh.Standard_Contract__c + '/' +bsh.Invoicing_Arrangement__c, bsh.Id);
    		}
        }
    	
    	//Map to hold the BSH Id with related BSP.
        Map<Id, List<Billing_Schedule_Period__c>> mapBSHIdwithBillingPeriods = new Map<Id, List<Billing_Schedule_Period__c>>();
        
        System.debug('Parent Periods: ' + parentBSP);
        System.debug('Parent Periods Count ' + parentBSP.size());
    	
    	//Loop over the BSP and apopulate the mapBSHwithBillingPeriods map.
    	for(Billing_Schedule_Period__c bsp : parentBSP){
    		
    		//Chekck for the BSH on BSP
    		if(bsp.Billing_Schedule_Header__c != null){
    			
    			//Populate the map
    			if(!mapBSHIdwithBillingPeriods.containsKey(bsp.Billing_Schedule_Header__c))
    				mapBSHIdwithBillingPeriods.put(bsp.Billing_Schedule_Header__c, new List<Billing_Schedule_Period__c>());
    			mapBSHIdwithBillingPeriods.get(bsp.Billing_Schedule_Header__c).add(bsp);	
    		}
    	}
    	System.debug('####mapBSHIdwithBillingPeriods '+mapBSHIdwithBillingPeriods);
    	/* point #1
    	Loop through all Component Subscriptions associated with the Program Subscriptions associated with the Standard Contract 
    		that fit the Invoicing Arrangement.  
    	  A Billing Schedule Line will be created for each Component Subscription and Billing Schedule Period that it’s associated with.
    	*/
        
    	//Map to hold BSH ID with list of Component Subscriptions
	    Map<Id, List<SBQQ__Subscription__c>> mapBSHidWithComponentSubscriptions = new Map<Id, List<SBQQ__Subscription__c>>();
        
        //Map Subscription Period and Product Id as a key and list of component Subscriptions as a value.
        Map<String, List<SBQQ__Subscription__c>> mapSPUniqueKeyWithComponentSubscriptions = new Map<String, List<SBQQ__Subscription__c>>();
    	
    	//Check for size
    	if(mapUniqueKeyWithBSHId.size() > 0 && setContractIds.size() > 0){
    		
    		//Get all the component subscriptions under the contracts in the set
	    	for(SBQQ__Subscription__c compSubs : [SELECT Id, Name, Status__c, Customer_Amount__c, SBQQ__SubscriptionEndDate__c , SBQQ__SubscriptionStartDate__c, SBQQ__SegmentStartDate__c, SBQQ__SegmentEndDate__c, SBQQ__SegmentIndex__c,
                                                  	SBQQ__Contract__c , SBQQ__Contract__r.StartDate, Subscription_Period__c, SBQQ__Product__c, SBQQ__Product__r.Name, SBQQ__Product__r.ProductCode, Program_Subscription__c,
                                                   	Program_Subscription__r.Invoicing_Arrangement__c, Program_Subscription__r.SBQQ__Product__c, Program_Subscription__r.SBQQ__Product__r.Family,
                                                  	Postage_Costs_m__c, Media_Costs_m__c, Postage_Adjustment_m__c, Media_Adjustment_m__c, Program_Subscription__r.Membership__r.Active_Contract_Main_Contact__c
	                                                FROM SBQQ__Subscription__c
	                                                WHERE SBQQ__Contract__c IN : setContractIds
	                                                	AND Program_Subscription__r.Status__c NOT IN : bypassProgSubStatuses
	                                                    AND RecordType.DeveloperName = 'Component']) {
	    		
                 		System.debug('###compSubs '+compSubs);                                           
				//check for conditions
				if(compSubs.SBQQ__Contract__c != null && compSubs.Program_Subscription__c != null && String.isNotBlank(compSubs.Program_Subscription__r.Invoicing_Arrangement__c)){
	    			
	    			//Unique to identify the BSH
				String uniqueKey = compSubs.SBQQ__Contract__c +'/'+compSubs.Program_Subscription__r.Invoicing_Arrangement__c;
	    			System.debug('##mapUniqueKeyWithBSHId.size() '+mapUniqueKeyWithBSHId.size());
                    		System.debug('##mapUniqueKeyWithBSHId.containsKey(uniqueKey) '+mapUniqueKeyWithBSHId.containsKey(uniqueKey));
                    		System.debug('##mapUniqueKeyWithBSHId.get(uniqueKey) '+mapUniqueKeyWithBSHId.get(uniqueKey));
	    			//populate the map
		    		if(mapUniqueKeyWithBSHId.size() > 0 && mapUniqueKeyWithBSHId.containsKey(uniqueKey) && mapUniqueKeyWithBSHId.get(uniqueKey) != null){
		    			
                        //Populate the map with default values
		    			if(!mapBSHidWithComponentSubscriptions.containsKey(mapUniqueKeyWithBSHId.get(uniqueKey)))
		    				mapBSHidWithComponentSubscriptions.put(mapUniqueKeyWithBSHId.get(uniqueKey), new List<SBQQ__Subscription__c>());
		    			
                        //populate the map with actual values
		    			mapBSHidWithComponentSubscriptions.get(mapUniqueKeyWithBSHId.get(uniqueKey)).add(compSubs);
		    		}
	    		}
	    	}	
        }
    	System.debug('##mapBSHIdwithBillingPeriods.size() > 0 '+mapBSHIdwithBillingPeriods.size());
    	System.debug('##mapBSHidWithComponentSubscriptions.size() > 0 '+mapBSHidWithComponentSubscriptions.size());
    	//Check for size
    	if(mapBSHIdwithBillingPeriods.size() > 0 && mapBSHidWithComponentSubscriptions.size() > 0){
    		
    		//List to hold the BSL wrapper instances
    		List <BillingScheduleLineWrapper> listBSLwrapper = new List<BillingScheduleLineWrapper>();
    		
            //map to hold the subscription Id with already invoiced amount (from the lines under the locked periods) 
            Map<Id, Map<String, Decimal>> mapSubscriptionIdWithAlreadyInvoicedAmount= new Map<Id, Map<String, Decimal>>();
            
            Map<Id, Integer> mapSubscriptionIdWithNumberOfLockedLines= new Map<Id, Integer>();
            
            //Handel the Recalculation - Starts from here
            //Loop over the locked periods
            if(mapLockedPeriods != null && mapLockedPeriods.size() > 0)
            {
                for(Billing_Schedule_Period__c bsPeriod : mapLockedPeriods.values()){
                    
                    //Check for lines under the periods
                    if(bsPeriod.Billing_Schedule_Lines__r != null && bsPeriod.Billing_Schedule_Lines__r.size() > 0) {
                        
                        //Loop over the related lines
                        for(Billing_Schedule_Line__c bsline : bsPeriod.Billing_Schedule_Lines__r) {
                            
                            //Check for related component subscriotion and the billing amount invoiced 
                            if(bsline.Related_Subscription_Component__c != null && bsline.Billing_Amount__c != null){
                                
                                //instantiate the temporary map to hold the Product type with invoiced amount 
                                Map<String, Decimal> mapProductWithAlreadyInvoicedAmount;
                                
                                //Check for contains in the map and get the values
                                if(mapSubscriptionIdWithAlreadyInvoicedAmount.containsKey(bsline.Related_Subscription_Component__c) )
                                    mapProductWithAlreadyInvoicedAmount = mapSubscriptionIdWithAlreadyInvoicedAmount.get(bsline.Related_Subscription_Component__c);
                                
                                //check for null and then accordingly initialize the mao to defaults
                                if(mapProductWithAlreadyInvoicedAmount == null)
                                    mapProductWithAlreadyInvoicedAmount = new Map<String, Decimal>();
                                
                                //Check for postage 
                                if(bsline.Related_Component_Product__c == 'Postage'){
                                    
                                    if(!mapProductWithAlreadyInvoicedAmount.containsKey('Postage'))
                                        mapProductWithAlreadyInvoicedAmount.put('Postage', 0);
                                    
                                    Decimal invoicedPostageAmount = mapProductWithAlreadyInvoicedAmount.get('Postage') + bsline.Billing_Amount__c;
                                    mapProductWithAlreadyInvoicedAmount.put('Postage', invoicedPostageAmount);
                                } 
                                //Check for Media
                                else if(bsline.Related_Component_Product__c == 'Media') {
                                    
                                    if(!mapProductWithAlreadyInvoicedAmount.containsKey('Media'))
                                        mapProductWithAlreadyInvoicedAmount.put('Media', 0);
                                    
                                    Decimal invoicedPostageAmount = mapProductWithAlreadyInvoicedAmount.get('Media') + bsline.Billing_Amount__c;
                                    mapProductWithAlreadyInvoicedAmount.put('Media', invoicedPostageAmount);
                                }
                                //If not postage/media then it should be either program/Annual/travel/Implementation etc.
                                else {
                                    
                                    if(!mapProductWithAlreadyInvoicedAmount.containsKey('Program'))
                                        mapProductWithAlreadyInvoicedAmount.put('Program', 0);
                                    
                                    Decimal invoicedPostageAmount = mapProductWithAlreadyInvoicedAmount.get('Program') + bsline.Billing_Amount__c;
                                    mapProductWithAlreadyInvoicedAmount.put('Program', invoicedPostageAmount);
                                    
                                    if(!mapSubscriptionIdWithNumberOfLockedLines.containsKey(bsline.Related_Subscription_Component__c))
                                        mapSubscriptionIdWithNumberOfLockedLines.put(bsline.Related_Subscription_Component__c, 0);    
                                    
                                    Integer lockedLines = mapSubscriptionIdWithNumberOfLockedLines.get(bsline.Related_Subscription_Component__c) + 1;
                                    mapSubscriptionIdWithNumberOfLockedLines.put(bsline.Related_Subscription_Component__c, lockedLines);
                                }
                                
                                //Check for size
                                if(mapProductWithAlreadyInvoicedAmount.size() > 0) 
                                    mapSubscriptionIdWithAlreadyInvoicedAmount.put(bsline.Related_Subscription_Component__c, mapProductWithAlreadyInvoicedAmount);
                                
                            }    	   
                        }   
                    }
                }    
            }
            
            //Handel the Recalculation - Ends here
            
            System.debug('##mapBSHIdwithBillingPeriods.keySet() '+ mapBSHIdwithBillingPeriods.keySet().size());
    		//Loop over the BSH Ids
    		for(Id bshId : mapBSHIdwithBillingPeriods.keySet()){
    			System.debug('###mapBSHidWithComponentSubscriptions.containsKey(bshId) '+mapBSHidWithComponentSubscriptions.containsKey(bshId));
    			//1) Check if we have have any component subscriptions related to the BSH 2) //Check if we have have any Billing schedule Periods related to the BSH
    			if(mapBSHIdwithBillingPeriods.get(bshId) != null && mapBSHIdwithBillingPeriods.get(bshId).size() > 0 && mapBSHidWithComponentSubscriptions.containsKey(bshId)){
    			
    				//Get the invoicing Arrangement
                    String invoicingArrangement = mapBSH.get(bshId).Invoicing_Arrangement__c;
                    
                    //List of our Periods
                    List<Billing_Schedule_Period__c> bspForBSH = mapBSHIdwithBillingPeriods.get(bshId);
    				
    				//Map to hold the componentSubscription Id with number of lines required to create.
                    Map<Id,Integer> mapComponentIdWithNoOfLines = calculatePeriodsForLines( mapBSHidWithComponentSubscriptions.get(bshId), invoicingArrangement, bspForBSH);
    				
    				//Map to hold the componentSubscription Id with number of lines required to create.
    				Map<Id,Integer> mapComponentIdWithCreatedLines = new Map<Id,Integer>();
    				
                    system.debug('@@@@@' + mapComponentIdWithNoOfLines);
                    system.debug('@$#' + mapBSHidWithComponentSubscriptions.get(bshId));
    				//Check for the size
    				if(mapComponentIdWithNoOfLines != null && mapComponentIdWithNoOfLines.size() > 0){
    					
    					//Loop oveer the billing schedule periods 
		    			for( Billing_Schedule_Period__c billingSP : mapBSHIdwithBillingPeriods.get(bshId)){
		    					
	                        //Get our Billing Schedule Rule
	                        Date bspStartDate = billingSP.Billing_Schedule_Period_Start_Date__c;
	                        Date bspEndDate = billingSP.Billing_Schedule_Period_End_Date__c;
							
	    					//Loop over the component subscriptions and create the billing schedule line for each component subscription for each billing schedule period
	    					for(SBQQ__Subscription__c comSub : mapBSHidWithComponentSubscriptions.get(bshId)) {
	    						
                                //Check for size
	    						if(mapComponentIdWithNoOfLines.containsKey(comSub.Id) && mapComponentIdWithNoOfLines.get(comSub.Id) > 0){
	    							
                                    //Get the no of locked lines that are already invoiced
                                    Integer lockedLines = 0; 
                                    if(mapSubscriptionIdWithNumberOfLockedLines.size() > 0 && mapSubscriptionIdWithNumberOfLockedLines.containsKey(comSub.Id) && mapSubscriptionIdWithNumberOfLockedLines.get(comSub.Id) >= 0)
                                    	lockedLines = mapSubscriptionIdWithNumberOfLockedLines.get(comSub.Id);
                                    
	    							//Number of lines to create for the component subscription 
									Integer numOfLines = mapComponentIdWithNoOfLines.get(comSub.Id);
	    							
                                    //Need to refaactor the billing amount on the basis of billing schedule rules or some other logic.
                                    Decimal postageCost = 0;
                                    Decimal mediaCost = 0;
                                    Decimal billingAmountPostage = 0;
                                    Decimal billingAmountMedia = 0;
                                    Decimal billingAmount = 0;
                                    
                                    //Temporary map to hold the product type like Postage/Media/Program with already invoiced value for mthe subscription. 
                                    Map<String, Decimal> mapTempProductWithAlreadyInvoicedAmount = new Map<String, Decimal>();
                                    if(mapSubscriptionIdWithAlreadyInvoicedAmount.size() > 0 && mapSubscriptionIdWithAlreadyInvoicedAmount.containsKey(comSub.Id) 
                                      	&& mapSubscriptionIdWithAlreadyInvoicedAmount.get(comSub.Id) != null && mapSubscriptionIdWithAlreadyInvoicedAmount.get(comSub.Id).size() > 0) {
                                        
										mapTempProductWithAlreadyInvoicedAmount = mapSubscriptionIdWithAlreadyInvoicedAmount.get(comSub.Id);
                                    }
                                    
                                    //Check for the Program Cost (i.e for the ES Case)
                                    if(comSub.SBQQ__Product__r.Name == 'Program Costs' ){
                                    	
                                        //
                                        Decimal postage = comSub.Postage_Costs_m__c != null ? comSub.Postage_Costs_m__c : 0;
                                        Decimal media = comSub.Media_Costs_m__c != null ? comSub.Media_Costs_m__c : 0;
                                        Decimal postageCostAdjust = comSub.Postage_Adjustment_m__c != null ? comSub.Postage_Adjustment_m__c : 0;
                                        Decimal mediaCostAdjust = comSub.Media_Adjustment_m__c != null ? comSub.Media_Adjustment_m__c : 0;
                                        
                                        //Get the total postage/media costs
                                        postageCost = postage - postageCostAdjust;
                                        mediaCost = media - mediaCostAdjust;
                                        
                                        //Calculate the billing amount for Postage/Media cost
                                        billingAmountPostage = postageCost != null ? postageCost/numOfLines : 0 ;	
                                        billingAmountMedia = mediaCost != null ? mediaCost/numOfLines : 0;
                                        
                                        //Handel Recalculation - Starts from here 
                                        if(mapTempProductWithAlreadyInvoicedAmount.size() > 0) {
                                        	Decimal postageCostTemp = 0;
                                            Decimal mediaCostTemp = 0;
                                            if(mapTempProductWithAlreadyInvoicedAmount.containsKey('Postage') && mapTempProductWithAlreadyInvoicedAmount.get('Postage') != null)
                                                postageCostTemp = postageCost - mapTempProductWithAlreadyInvoicedAmount.get('Postage');
                                            
                                            if(mapTempProductWithAlreadyInvoicedAmount.containsKey('Media') && mapTempProductWithAlreadyInvoicedAmount.get('Media') != null)
                                                mediaCostTemp = mediaCost - mapTempProductWithAlreadyInvoicedAmount.get('Media');
                                        	
											if(numOfLines == 1 && lockedLines == 1){
                                               	billingAmountPostage = postageCostTemp != null ? postageCostTemp/ numOfLines : 0 ;	
                                        		billingAmountMedia = mediaCostTemp != null ? mediaCostTemp/ numOfLines : 0; 
                                            }
                                            else{
                                                billingAmountPostage = postageCostTemp != null ? postageCostTemp/ (numOfLines - lockedLines) : 0 ;	
                                        		billingAmountMedia = mediaCostTemp != null ? mediaCostTemp/ (numOfLines - lockedLines) : 0;
                                            }
                                        }
                                        //Handel Recalculation - Ends here 
                                        
									} 
                                    
                                    //get the components customer Amount
                                    Decimal customerAmount = comSub.Customer_Amount__c != null ? comSub.Customer_Amount__c : 0;
                                    
                                    //Calculate the billing amount for all other products like annual fee/Travel fee etc
                                    billingAmount = customerAmount/numOfLines; 
                                    
                                    //Handel Recalculation - Starts from here 
                                    if(mapTempProductWithAlreadyInvoicedAmount.size() > 0 && mapTempProductWithAlreadyInvoicedAmount.containsKey('Program') && mapTempProductWithAlreadyInvoicedAmount.get('Program') != null) {
                                        	
				        customerAmount = customerAmount - mapTempProductWithAlreadyInvoicedAmount.get('Program');
                                        
                                        //Calculate the billing amount for all other products like annual fee/Travel fee etc
                                        //Modify by - Mahendra Swarnakar - 09-17-20 - Issue--CR14374--QA--00010114
                                        if(numOfLines - lockedLines > 0)
                                    		billingAmount = customerAmount/(numOfLines - lockedLines); 
									}
                                    //Handel Recalculation - Ends here 
                                    
                                    //Populate the map with default value
                                    if(!mapComponentIdWithCreatedLines.containsKey(comSub.Id))
                                        mapComponentIdWithCreatedLines.put(comSub.Id, lockedLines + 1);
                                    
                                    //Get the no of lines already created
                                    Integer numOfLinesAlreadyCreated = mapComponentIdWithCreatedLines.get(comSub.Id);

                                    System.debug('num of lines already created: ' + numOfLinesAlreadyCreated);
                                    System.debug('num of lines to create: ' + numOfLines);

                                    System.debug('Sub Start Date: ' + comSub.SBQQ__SubscriptionStartDate__c);
                                    System.debug('Sub End Date: ' + comSub.SBQQ__SubscriptionEndDate__c);
                                    System.debug('BPeriod Start Date: ' + bspStartDate);
                                    System.debug('BPeriod End Date: ' + bspEndDate);
	    							
                                    //Check for conditions to create the Lines for each periods
	    							if(numOfLinesAlreadyCreated <= numOfLines 
	    							     && ((comSub.SBQQ__SegmentStartDate__c <= bspStartDate   
			    								&& comSub.SBQQ__SegmentEndDate__c >= bspEndDate) 
			    							|| (comSub.SBQQ__SegmentStartDate__c >= bspStartDate   
			    								&& comSub.SBQQ__SegmentEndDate__c <= bspEndDate)) ) 
                                    {
                                        //Check for implementation fee and add only one/single billing schedule line for it, under the first billing period installment
	    								if(comSub.SBQQ__Product__c != null && comSub.SBQQ__Product__r.ProductCode == 'ImplementationFee' ) {
                                            
                                            //Handel Recalculation - Starts from here 
                                            if(comSub.Customer_Amount__c != null && mapTempProductWithAlreadyInvoicedAmount.size() > 0 
                                               	&& mapTempProductWithAlreadyInvoicedAmount.containsKey('Program') 
                                               	&& mapTempProductWithAlreadyInvoicedAmount.get('Program') != null) 
                                            {
                                                if(mapTempProductWithAlreadyInvoicedAmount.get('Program') == comSub.Customer_Amount__c ){
                                                    continue;
                                                } else {
                                                	
                                                    
                                                    billingAmount = comSub.Customer_Amount__c - mapTempProductWithAlreadyInvoicedAmount.get('Program');
                                                    
                                                    //Create our Billing Schedule line Wrapper
                                                    //Modified By - Mahendra Swarnkar - 12/08/2020 - Issue--CR14672--QA--00010296 - skip locked BSP for newly created BSL
                                                    if(mapLockedPeriods == null || (mapLockedPeriods != null && !mapLockedPeriods.containsKey(billingSP.Id))) {
                                                        BillingScheduleLineWrapper bspWrapper = new BillingScheduleLineWrapper(bshId, billingSP.Id, comSub.Id, null, billingAmount, 2, null, comSub.Program_Subscription__r.Membership__r.Active_Contract_Main_Contact__c);
                                                        
                                                        //Add our Wrapper to the List
                                                        listBSLwrapper.add(bspWrapper);
                                                    }
                                                    mapSubscriptionIdWithAlreadyInvoicedAmount.get(comSub.Id).put('Program', comSub.Customer_Amount__c);
                                                    
                                            	}
                                            } //Handel Recalculation - Ends here  
                                            else {
                                            	
                                                if(billingSP.Installment__c == 1) {
                                                
                                                    //Modified By - Mahendra Swarnkar - 12/08/2020 - Issue--CR14672--QA--00010296 - skip locked BSP for newly created BSL
                                                    //Create our Billing Schedule line Wrapper
                                                    if(mapLockedPeriods == null || (mapLockedPeriods != null && !mapLockedPeriods.containsKey(billingSP.Id))) {
                                                        BillingScheduleLineWrapper bspWrapper = new BillingScheduleLineWrapper(bshId, billingSP.Id, comSub.Id, null, comSub.Customer_Amount__c, 1, null, comSub.Program_Subscription__r.Membership__r.Active_Contract_Main_Contact__c);
                                                        
                                                        //Add our Wrapper to the List
                                                        listBSLwrapper.add(bspWrapper);
                                                    }
                                                }
                                            }    
                                        } else {
                                        	
                                            if(comSub.SBQQ__Product__r.Name == 'Program Costs' ){
                                                //updated to Replace '75/25 Split' with "ES-75-25" to make invoicing arrangements in sync
                                                if(invoicingArrangement.equalsIgnoreCase('ES-75-25')) {
													
                                                    //Calculate the billing amount for Postage/Media cost
                                                    billingAmountPostage = (postageCost != null && numOfLinesAlreadyCreated == 1) ? postageCost : 0 ;
                                                    billingAmountMedia = (mediaCost != null && numOfLinesAlreadyCreated == 1) ? mediaCost : 0 ;
                                                    
                                                    //Calculate the billing amount for program cost
                                        	    //billingAmount = comSub.Customer_Amount__c != null && numOfLinesAlreadyCreated == 1 ? comSub.Customer_Amount__c * 0.75 : (comSub.Customer_Amount__c != null && numOfLinesAlreadyCreated == 2 ? comSub.Customer_Amount__c * 0.25 : 0);
                                                    
                                                    //Added By - Mahendra swarnkar - 06/24/2020 - CR-20200609-14162 - start from here
                                                    //if(comSub.SBQQ__SegmentIndex__c == 1){
                                                    if(comSub.SBQQ__SegmentIndex__c != null){
                                                        if(numOfLinesAlreadyCreated == 1 && comSub.SBQQ__SegmentStartDate__c.year() == comSub.SBQQ__SegmentEndDate__c.year())
                                                            billingAmount = comSub.Customer_Amount__c != null ? comSub.Customer_Amount__c : 0;
                                                        else {
                                                        	billingAmount = comSub.Customer_Amount__c != null && numOfLinesAlreadyCreated == 1 ? comSub.Customer_Amount__c * 0.75 : (comSub.Customer_Amount__c != null && numOfLinesAlreadyCreated == 2 ? comSub.Customer_Amount__c * 0.25 : 0);
                                                        }    
                                                    } else{
                                                        //billingAmount = comSub.Customer_Amount__c != null && numOfLinesAlreadyCreated == 1 ? comSub.Customer_Amount__c * 0.75 : (comSub.Customer_Amount__c != null && numOfLinesAlreadyCreated == 2 ? comSub.Customer_Amount__c * 0.25 : 0);
                                                        billingAmount = comSub.Customer_Amount__c != null ? comSub.Customer_Amount__c : 0;
                                                    }
                                                    //Added By - Mahendra swarnkar - 06/24/2020 - CR-20200609-14162 - Ends here
                                                    
                                                    //Handel Recalculation - Starts from here 
                                                    if(mapTempProductWithAlreadyInvoicedAmount.size() > 0){
                                                    	
                                                        if(mapTempProductWithAlreadyInvoicedAmount.containsKey('Postage') && mapTempProductWithAlreadyInvoicedAmount.get('Postage') != null) 
                                                        {
                                                            if(postageCost != mapTempProductWithAlreadyInvoicedAmount.get('Postage')){
                                                                Decimal postageAmount = postageCost - mapTempProductWithAlreadyInvoicedAmount.get('Postage');
                                                                mapSubscriptionIdWithAlreadyInvoicedAmount.get(comSub.Id).put('Postage', postageCost);
                                                                billingAmountPostage = postageAmount;
                                                            }
                                                                
                                                        }
                                                        
                                                        if(mapTempProductWithAlreadyInvoicedAmount.containsKey('Media') && mapTempProductWithAlreadyInvoicedAmount.get('Media') != null) 
                                                        {
                                                            if(mediaCost != mapTempProductWithAlreadyInvoicedAmount.get('Media')){
                                                                Decimal mediaAmount = mediaCost - mapTempProductWithAlreadyInvoicedAmount.get('Media');
                                                                mapSubscriptionIdWithAlreadyInvoicedAmount.get(comSub.Id).put('Media', mediaAmount);
                                                                billingAmountMedia = mediaAmount;
                                                            }
                                                        }
                                                        
                                                        if(mapTempProductWithAlreadyInvoicedAmount.containsKey('Program') && mapTempProductWithAlreadyInvoicedAmount.get('Program') != null) 
                                                        {
                                                            if(comSub.Customer_Amount__c != null && comSub.Customer_Amount__c != mapTempProductWithAlreadyInvoicedAmount.get('Program')){
                                                                Decimal programCost = comSub.Customer_Amount__c-mapTempProductWithAlreadyInvoicedAmount.get('Program');
                                                                mapSubscriptionIdWithAlreadyInvoicedAmount.get(comSub.Id).put('Program', comSub.Customer_Amount__c);
                                                                billingAmount = programCost;
                                                            }
                                                        }   
                                                    }
                                                    //Handel Recalculation - Ends here 
                                                 }
                                                
                                                if(billingAmountPostage != 0){

                                                    System.debug('^Flag - BL Created Here');
                                                	
                                                    //Create our Billing Schedule line Wrapper for postage
                                                    //Modified By - Mahendra Swarnkar - 12/08/2020 - Issue--CR14672--QA--00010296 - skip locked BSP for newly created BSL
                                                    if(mapLockedPeriods == null || (mapLockedPeriods != null && !mapLockedPeriods.containsKey(billingSP.Id))) {
                                                        BillingScheduleLineWrapper bspWrapperForPostage = new BillingScheduleLineWrapper(bshId, billingSP.Id, comSub.Id, null, billingAmountPostage, numOfLinesAlreadyCreated, 'Postage', comSub.Program_Subscription__r.Membership__r.Active_Contract_Main_Contact__c);
                                                            
                                                        //Add our Wrapper to the List
                                                        listBSLwrapper.add(bspWrapperForPostage);
                                                    }
                                                }
                                                
                                                if(billingAmountMedia != 0){

                                                    System.debug('%Flag - BL Created Here');

                                                    //Create our Billing Schedule line Wrapper for media
                                                    //Modified By - Mahendra Swarnkar - 12/08/2020 - Issue--CR14672--QA--00010296 - skip locked BSP for newly created BSL
                                                    if(mapLockedPeriods == null || (mapLockedPeriods != null && !mapLockedPeriods.containsKey(billingSP.Id))) {
                                                        BillingScheduleLineWrapper bspWrapperForMedia = new BillingScheduleLineWrapper(bshId, billingSP.Id, comSub.Id, null, billingAmountMedia, numOfLinesAlreadyCreated, 'Media', comSub.Program_Subscription__r.Membership__r.Active_Contract_Main_Contact__c);
                                                            
                                                        //Add our Wrapper to the List
                                                        listBSLwrapper.add(bspWrapperForMedia);
                                                    }
                                                }
                                                if(billingAmount != 0){

                                                    System.debug('!Flag - BL Created Here');
                                                	
                                                    //Create our Billing Schedule line Wrapper for program cost
                                                    //Modified By - Mahendra Swarnkar - 12/08/2020 - Issue--CR14672--QA--00010296 - skip locked BSP for newly created BSL
                                                    if(mapLockedPeriods == null || (mapLockedPeriods != null && !mapLockedPeriods.containsKey(billingSP.Id))){
                                                        BillingScheduleLineWrapper bspWrapper = new BillingScheduleLineWrapper(bshId, billingSP.Id, comSub.Id, null, billingAmount, numOfLinesAlreadyCreated, null, comSub.Program_Subscription__r.Membership__r.Active_Contract_Main_Contact__c);
                                                    
                                                        //Add our Wrapper to the List
                                                        listBSLwrapper.add(bspWrapper);
                                                    }
                                                }
                                            } else {

                                                System.debug('@Flag - BL Created Here');
                                                
                                                //Added By - Mahendra swarnkar - 06/24/2020 - CR-20200609-14162 - start from here
                                                if(invoicingArrangement.equalsIgnoreCase('ES-75-25') && (comSub.SBQQ__Product__r.Name == 'Multi Year Discount' || comSub.SBQQ__Product__r.Name == 'Additional Discount')){
                                                    
                                                    //if(comSub.SBQQ__SegmentIndex__c == 1){
                                                    if(comSub.SBQQ__SegmentIndex__c != null){
                                                        if(numOfLinesAlreadyCreated == 1 && comSub.SBQQ__SegmentStartDate__c.year() == comSub.SBQQ__SegmentEndDate__c.year())
                                                            billingAmount = comSub.Customer_Amount__c != null ? comSub.Customer_Amount__c : 0;
                                                        else {
                                                        	billingAmount = comSub.Customer_Amount__c != null && numOfLinesAlreadyCreated == 1 ? comSub.Customer_Amount__c * 0.75 : (comSub.Customer_Amount__c != null && numOfLinesAlreadyCreated == 2 ? comSub.Customer_Amount__c * 0.25 : 0);
                                                        }    
                                                    } else{
                                                        //billingAmount = comSub.Customer_Amount__c != null && numOfLinesAlreadyCreated == 1 ? comSub.Customer_Amount__c * 0.75 : (comSub.Customer_Amount__c != null && numOfLinesAlreadyCreated == 2 ? comSub.Customer_Amount__c * 0.25 : 0);
                                                        billingAmount = comSub.Customer_Amount__c != null ? comSub.Customer_Amount__c : 0;
                                                    }
                                                }
                                                //Added By - Mahendra swarnkar - 06/24/2020 - CR-20200609-14162 - Ends here
                                                
                                                //Create our Billing Schedule line Wrapper
                                                //Modified By - Mahendra Swarnkar - 12/08/2020 - Issue--CR14672--QA--00010296 - skip locked BSP for newly created BSL
                                                if(mapLockedPeriods == null || (mapLockedPeriods != null && !mapLockedPeriods.containsKey(billingSP.Id))) {
                                                    BillingScheduleLineWrapper bspWrapper = new BillingScheduleLineWrapper(bshId, billingSP.Id, comSub.Id, null, billingAmount, numOfLinesAlreadyCreated, null, comSub.Program_Subscription__r.Membership__r.Active_Contract_Main_Contact__c);
                                                    
                                                    //Add our Wrapper to the List
                                                    listBSLwrapper.add(bspWrapper);
                                                }
                                            }
                                                 
                                            //Increment the already crealted lines counter to 1 and update the already created lines map
                                            numOfLinesAlreadyCreated = numOfLinesAlreadyCreated + 1;
                                            mapComponentIdWithCreatedLines.put(comSub.Id, numOfLinesAlreadyCreated);
                                            
                                            //count ++;
                                        }
		    						}
		    						
	    						}
	    					}	
		    			}
    				}
    			}
    		}
    		
    		//Check for size
    		if (listBSLwrapper.size() > 0){
                    
                    //Get the billing schedule line records from the line wrapper list
                    List <Billing_Schedule_Line__c> BSLToInsert = createBillingScheduleLineRecordsFromWrapper(listBSLwrapper);
                    
                    //insert the billing schedule lines
                    insert BSLToInsert;

                    System.debug('BSL - After Limits' + Limits.getCpuTime());

                    BillingScheduleLineTriggerHelper.updatBillingSchedulePeriodStartAndEndDate(BSLToInsert, null);
			}
    	}
    }
    
    //method to parse the billing schedule lines wrapper instances into the billing schedule line records 
    public static List<Billing_Schedule_Line__c> createBillingScheduleLineRecordsFromWrapper (List<BillingScheduleLineWrapper> bslWrappers){

        //Create a list for our final Billing Schedule lines records
        List<Billing_Schedule_Line__c> bslRecords = new List<Billing_Schedule_Line__c>();
        
        //Loop through our Wrapper records and create our Billing Schedule lines records
        for (BillingScheduleLineWrapper bslWrapper : bslWrappers){
            
            //Populate our fields
            Billing_Schedule_Line__c bsl = new Billing_Schedule_Line__c();
            
            bsl.Billing_Schedule_Header__c = bslWrapper.billSchedHeader;
            bsl.Billing_Schedule_Period__c = bslWrapper.billSchedPeriod;
            bsl.Related_Subscription_Component__c = bslWrapper.relatedSubscriptionComponent;
            bsl.Billing_Amount__c = bslWrapper.billingAmount;
            bsl.Installment__c = bslWrapper.installmentNumber;
            bsl.Company__c = 'EAB';
            bsl.Related_Component_Product_Override__c = bslWrapper.RelatedComponentProductOverride;
            bsl.Main_Contact__c = bslWrapper.MainContactId;
            //bsl.Billing_Date_Actual__c = system.today();
            
            bslRecords.add(bsl);
        }
        
        //Return our created records
        return bslRecords;
    }
    
    //Wrapper class for Billing schedule lines
    public class BillingScheduleLineWrapper {
        
        public Id billSchedHeader;
        public Id billSchedPeriod;
        public Id relatedSubscriptionComponent;
        public Date billingDateActual;
        public Decimal billingAmount;
        public Integer installmentNumber;
        public String RelatedComponentProductOverride; 
        public Id MainContactId;
        
        public BillingScheduleLineWrapper (Id billSchedHeader, Id billSchedPeriod, Id relatedSubscriptionComponent, Date billingDateActual, Decimal billingAmount, Integer installmentNumber, String RelatedComponentProductOverride, Id MainContactId){

            this.billSchedHeader = billSchedHeader;
            this.billSchedPeriod = billSchedPeriod;
            this.relatedSubscriptionComponent = relatedSubscriptionComponent;
            this.billingDateActual = billingDateActual;
            this.billingAmount = billingAmount;
            this.installmentNumber = installmentNumber;
            this.RelatedComponentProductOverride = RelatedComponentProductOverride;
            this.MainContactId = MainContactId;
            
        }
    }
    
    //calculate and then return the no of Billing schedule lines required to create
    public static Map<Id,Integer> calculatePeriodsForLines(List<SBQQ__Subscription__c> listcomponentSubscriptions, String invoiceArrangement, List<Billing_Schedule_Period__c> PeriodsForBSH) {

		//Holds the Component Subscription Id with no of lines required
        Map<Id,Integer> mapComponentIdWithNoOfLines = new Map<Id,Integer>();

        //Query for our necessary Period values
        List<Billing_Schedule_Period__c> bspRecords = [SELECT ID, Installment__c, Billing_Segment__c,Billing_Schedule_Period_Start_Date__c, Billing_Schedule_Period_End_Date__c
                                                        FROM Billing_Schedule_Period__c WHERE ID in :PeriodsForBSH];
		
        //Loop through our Program Subscriptions and get our Start and End Dates
        for (SBQQ__Subscription__c sub : listcomponentSubscriptions){
            
            if(sub.SBQQ__Product__r.ProductCode == 'ImplementationFee'){
                //Populate the map
                mapComponentIdWithNoOfLines.put(sub.Id, 1);
            } else {
            	
                //Check for start and end date on Component subscriotion 
                if (sub.SBQQ__SegmentStartDate__c != null && sub.SBQQ__SegmentEndDate__c != null){

                    if (bspRecords != null){

                        //Integer for counting total number of Periods
                        Integer periodCounter = 0;

                        //Loop through our Periods and see total count for that time period
                        for (Billing_Schedule_Period__c bsp : bspRecords){

                        if (bsp.Billing_Schedule_Period_Start_Date__c != null && bsp.Billing_Schedule_Period_End_Date__c != null){

                            if ((bsp.Billing_Schedule_Period_Start_Date__c <= sub.SBQQ__SegmentStartDate__c &&
                                bsp.Billing_Schedule_Period_End_Date__c >= sub.SBQQ__SegmentEndDate__c) ||
                                (bsp.Billing_Schedule_Period_Start_Date__c >= sub.SBQQ__SegmentStartDate__c &&
                                bsp.Billing_Schedule_Period_End_Date__c <= sub.SBQQ__SegmentEndDate__c)){

                                    //Increment our Counter
                                    periodCounter++;
                                }   
                                
                            }
                        }
                        
                        //get total no of months
                        //Integer monthsDuration = (sub.SBQQ__SegmentStartDate__c).monthsBetween(sub.SBQQ__SegmentEndDate__c);
                        
                        /*Date monthDurationDate = (sub.SBQQ__SegmentStartDate__c).addMonths(monthsDuration);
                        if (monthDurationDate < sub.SBQQ__SegmentEndDate__c) {
                            monthsDuration ++;
                        }*/

                        
                        //Add oue Sub and Counter
                        mapComponentIdWithNoOfLines.put(sub.Id, periodCounter);

                    }
                }
                        
                    /*if(String.isNotBlank(invoiceArrangement) ){
                            
                        if(mapInvArrangementToNumber.containsKey(invoiceArrangement)){
                                
                            //Get the number of months associated with the Invoicing Arrangement
                            Integer monthsInvArr = mapInvArrangementToNumber.get(invoiceArrangement);
                                
                            //Calculate Number of Periods Needed
                            //Integer numOfPeriods = monthsDuration/monthsInvArr;
                            Integer numOfPeriods = (Integer) System.Math.ceil( (Decimal) monthsDuration/monthsInvArr);
                                
                            system.debug('@@@@@ invoiceArrangement' + invoiceArrangement + ' monthsInvArr' + monthsInvArr + '@@@ monthsDuration' + monthsDuration);
                                
                            system.debug('@@@@@ sub' + sub.Id + ' ' + sub.Name + '@@@ numOfPeriods' + numOfPeriods);
                            //Populate the map
                            mapComponentIdWithNoOfLines.put(sub.Id, numOfPeriods);
                        }
                    }
                }*/
             }
            
        }
        
        //Return the map
        return mapComponentIdWithNoOfLines;
    }
    
    //calculate and then return the no of Billing schedule lines required to create
    public static void recalculateCreateBillingSchedulePeriodsFromBSH(Billing_Schedule_Header__c billingScheduleHeader) {
        
	//Get all related Billing schedule periods/Billing schedule Lines
        //Check for the Billing schedule periods which needs to be deleted and then recreated (on the basis of invoicing status like if that Billing schedule is locked or not )
        //upsert the Billing schedule periods
        
        //Check for size
        if(billingScheduleHeader != null){
        	
            //Map to hold the Locked billing schedule periods i.e already invoiced.
            Map<Id, Billing_Schedule_Period__c> mapLockedPeriods = new Map<Id, Billing_Schedule_Period__c>();
            
            //List to hold the billing schedule periods needs to be recreate.
            List<Billing_Schedule_Period__c> listPeriodsNeedsToRecreate = new List<Billing_Schedule_Period__c>();
            
            //List to hold the lines to be delete
            list<Billing_Schedule_Line__c> listLinesToRecreate = new list<Billing_Schedule_Line__c>();
            
            //Get all the related billing periods and billing lines.
            for(Billing_Schedule_Period__c bsp : [Select Id, Billing_Schedule_Period_Start_Date__c, Billing_Schedule_Period_End_Date__c, 
                                                  Billing_Date_Calculated__c, Billing_Schedule_Header__c, Installment__c, Invoice_Sent__c, Sales_Invoice__c,
                                                  (Select Id, Billing_Schedule_Header__c, Billing_Schedule_Period__c, Related_Subscription_Component__c,
                                                   Billing_Amount__c, Installment__c, Company__c, Related_Component_Product_Override__c,
                                                   Related_Component_Product__c, Main_Contact__c From Billing_Schedule_Lines__r)
                                                  From Billing_Schedule_Period__c 
                                                  where Billing_Schedule_Header__c =: billingScheduleHeader.Id]) {
            	
                //check if the periods is locked.
                //Changed by Colin McGloin - 03/20 - Updating so any BSP with a Sales Invoice is considered locked as well
                //Modified by - Mahendra Swarnkar - 11/19/2020 - CR-20201106-14672 - Billing - BSL different than SIN Total Billing Amt
                if(/*bsp.Invoice_Sent__c == true ||*/ bsp.Sales_Invoice__c != null){
                	    
                	//populate the locked periods map
                	mapLockedPeriods.put(bsp.Id, bsp);
                
                } else {
                	
                    if(bsp.Billing_Schedule_Lines__r != null && bsp.Billing_Schedule_Lines__r.size() > 0)
                    	listLinesToRecreate.addAll(bsp.Billing_Schedule_Lines__r);
                    
		    //Populate the map with periods needs to recreate
                    listPeriodsNeedsToRecreate.add(bsp);
                }
            }
            
            //deleting unlocked lines and periods which will going to be recreate.
            if(listPeriodsNeedsToRecreate.size() > 0) {
            	
                //Disable all triggers
            	Util.byPassAllTriggers = true;
            
                //Delete the lines
                if(listLinesToRecreate.size() > 0){
                    delete listLinesToRecreate;
                }
            	
                //Delete the periods
            	delete listPeriodsNeedsToRecreate;
            	
                //Reenable all triggers
            	Util.byPassAllTriggers = false;
            }
            
            //Recreate the billing schedule periods.
            createBillingSchedulePeriods((new List<Billing_Schedule_Header__c> {billingScheduleHeader}) , mapLockedPeriods);
            
            List<Billing_Schedule_Period__c> listBillingSchedulePeriods = [Select Id, Billing_Schedule_Period_Start_Date__c, Billing_Schedule_Period_End_Date__c, 
                                                                           Billing_Date_Calculated__c, Billing_Schedule_Header__c, Installment__c, Invoice_Sent__c,
                                                                           (Select Id, Billing_Schedule_Header__c, Billing_Schedule_Period__c, Related_Subscription_Component__c,
                                                                            Billing_Amount__c, Installment__c, Company__c, Related_Component_Product_Override__c,
                                                                            Related_Component_Product__c, Main_Contact__c From Billing_Schedule_Lines__r)
                                                                           From Billing_Schedule_Period__c 
                                                                           where Billing_Schedule_Header__c =: billingScheduleHeader.Id];
            
            if(listBillingSchedulePeriods != null && listBillingSchedulePeriods.size() > 0){
            	
                //Recreate the billing schedule lines.
            	createBillingScheduleLines(listBillingSchedulePeriods, (new List<Billing_Schedule_Header__c> {billingScheduleHeader}), mapLockedPeriods);
            }
            
	}
    }
    
    public static Integer calculatePeriodsForSubscription (SBQQ__Subscription__c componentSub, String invoicingArrangement){

        Integer numOfPeriods = 0;

        //Get our Subscription Start and End Date and calculate duration between
        if (componentSub.SBQQ__SegmentStartDate__c != null && componentSub.SBQQ__SegmentEndDate__c != null){
            Integer duration = componentSub.SBQQ__SegmentStartDate__c.daysBetween(componentSub.SBQQ__SegmentEndDate__c);
            
            //Divide our Duration by our setupon Intervals
            Integer setPeriodDuration = mapInvArrangementToPeriodDuration.get(invoicingArrangement);
            
            //Modified by - Mahendra Swarnkar - 11/24/2020 - CR-20201110-14685 - Billing - BSP creation
            Decimal numOfPeriodsDecimal = Decimal.valueOf(duration).divide(setPeriodDuration, 1);
            
            numOfPeriodsDecimal = numOfPeriodsDecimal.round(System.RoundingMode.CEILING);
            numOfPeriods = Integer.valueOf(numOfPeriodsDecimal);
            System.debug('numOfPeriods '+numOfPeriods);
        }

        return numOfPeriods;

    }
    
    
}