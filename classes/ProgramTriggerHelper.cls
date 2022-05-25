/**
 *  Description     :  Helper class for Program Trigger.
 *
 *  Created By      :  
 *
 *  Created Date    :  
 *
 *  Revision Logs   :   V_1.0 - Created
 *		    		:   V_1.1 - Modified By - Ajit Surana - 03/30/2015 - CR-20150312-8758
 *		    		:   V_1.2 - Modified By - Subhash Garhwal - 06/25/2015 - CR-20150618-9014
 *		    		:   V_1.3 - Modified By - Rajeev Jain - 04/19/2016 - CR-20151120-9402 - Removed Incentive Change Log Method Reference from Here, In order to delete the Program fields.
 *		    		:   V_1.4 - Modified By - Subhash Garhwal - 08/19/2017 - Issue--CR10808--QA--00005222 - Modified insertOrUpdateProductData method
 *		    		:   V_1.5 - Modified By - Subhash Garhwal - 08/25/2017 - Issue--CR10808--QA--00005222 - Modified insertOrUpdateProductData method
 *		    		:   V_1.6 - Modified By - Mahendra Swarnkar - 10/09/2017 - CR-20170927-11494 - Apollo Release (Program child = Campaign ) - Added new methods "updateChildObjectsEntityField" and "updateChildObjectsEntityFieldofProgram"
 *		    		:   V_1.7 - Modified By - Mahendra Swarnkar - 10/11/2017 - CR-20170929-11624 - Apollo Release (Program child = Opportunity )
 *		    		:   V_1.8 - Modified By - Subhash Garhwal - 07/05/2018 - Subhash Garhwal - CR-20180323-12122 
 *		    		:   V_1.9 - Modified By - Victor Hanson09/30/2019 - CR-20181208-12776 - commented out the update portion of insertOrUpdateProductData.  Don't want to update the Product Family when Program is updated
 *		    		:   V_2.0 - Modified By - Nikita Kumari - 09/28/2021 - CR-20210910-15426 - Added new Method validateProgramAcronyms
 *
 **/
public class ProgramTriggerHelper {
    
    Public Static boolean CHECK_TRIGGER_EXCEPTION = false;
    
    public static void scheduleProgramAbbreviationJob(list<Program__c> programs, map<Id, Program__c> oldProgramMap) {
        
        // see if there is already a scheudled job pending
        list<CronTrigger> pendingJobs = [SELECT Id
                                         FROM CronTrigger
                                         WHERE NextFireTime != null AND StartTime = null AND CronJobDetail.Name = 'Sched_Event_UpdateProgramAbbreviation'];
                                         
        // if there is already a pending job, don't schedule
        if (pendingJobs.size() > 0) return;
        
        boolean scheduleBatch = false;
        
        // if any program's abbreviation was updated, schedule the batch
        for (Program__c prog : programs) {
            
            if (scheduleBatch == false) {
                
                Program__c oldProg;
                if (oldProgramMap != null) oldProg = oldProgramMap.get(prog.Id);
                if (oldProg != null && prog.Program_Abbreviation__c != oldProg.Program_Abbreviation__c) {
                    
                    scheduleBatch = true;
                }
            }
        }
        
        if (scheduleBatch) {
            
            // if the job is already scheduled, cancel it and create another
            list<CronTrigger> jobs = [SELECT Id
                                      FROM CronTrigger
                                      WHERE CronJobDetail.Name = 'Sched_Event_UpdateProgramAbbreviation'];
            for (CronTrigger job : jobs)
                system.abortJob(job.Id);
            
            //Build the system time of now + 10 minutes to schedule the batch apex.
            Datetime sysTime = System.now();
            sysTime = sysTime.addMinutes(10);
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            Sched_Event_UpdateProgramAbbreviation schedJob = new Sched_Event_UpdateProgramAbbreviation();
            //Schedule the next job, and give it the system time so name is unique
            System.schedule('Sched_Event_UpdateProgramAbbreviation',chron_exp,schedJob);
        }
    }
    
    //Subhash Garhwal - Modified - 08/19/2017 - Issue--CR10808--QA--00005222 - Added check for Program Family
    //Subhash Garhwal - Modified - 08/25/2017 - Issue--CR10808--QA--00005222 - Removed the additional Program family check and now Product family will only updates if Product is Royall related.
    //insert or update product data based on the Program value and Opertaion type
    //Victor Hanson - Modified - 09/30/2019 - CR-20181208-12776 - commented out because we no longer want to update the Product Family when Program is updated
    public static void insertOrUpdateProductData(Boolean isInsert, List<Program__c> programs){
        
        //create a new list of product to be inserted or updated
        List<Product2> products = new List<Product2>();
        
        //check the operation type
        //in case of insert operation create the new products records using program information
        //in case of update operation update the product records associted with the program and if no record is associated then create the new one
        if(isInsert) {
            
            //loop through the programs
            for(Program__c program : programs) {
                
                Boolean status = 'Active'.equalsIgnoreCase(program.Status__c)?true:false;
                
                //Subhas Garhwal - 08/19/2017 - Issue--CR10808--QA--00005222 - Added Program Line for family
                //add a new Product
                //Instance of Product
                Product2 product = new Product2(Name = program.Name, ProductCode = program.Program_Acronym__c,IsActive = status, Program__c = program.Id);
                
                //Check for PL
                //09/30/2019 - Victor Hanson - CR-20181208-12776 - commented out
                /*if(String.isNotBlank(program.Program_Line__c) && program.Program_Line__c == 'Royall')
                  product.Family = program.Business_line__c;*/
                               
                products.add(product);
            }
        } 
        /* 09/30/2019 - Victor Hanson - CR-20181208-12776 - commented out because we no longer want to update the Product Family when Program is updated
        else {
            
            //product map
            Map<Id, List<Product2>> mapProduct = new Map<Id, List<Product2>>();
            
            //Subhas Garhwal - 08/19/2017 - Issue--CR10808--QA--00005222 - Added SBQQ__Component__c and Offer__c fields in SOQL query
            //Subhas Garhwal - 08/22/2017 - Issue--CR10808--QA--00005222 - Removed SBQQ__Component__c and Offer__c fields in SOQL query
            //Fetch the existing products from data base based on programs
            for(Product2 prod : [Select Id, Name, ProductCode, Family, Program__c from Product2 where Program__c in: programs]) {
                
                //check if program id is already in the map, then add teh product to list of values else create a new entry for the map
                if(mapProduct.containsKey(prod.Program__c)) {
                    
                    //add the product in existing list of products
                    mapProduct.get(prod.Program__c).add(prod);
                    
                } else {
                    
                    //add a new list of product in map
                    mapProduct.put(prod.Program__c, new List<Product2>{prod});
                }
            }
            
            //loop through the program records
            for(Program__c program : programs) {
                
                Boolean status = 'Active'.equalsIgnoreCase(program.Status__c)?true:false;
                
                //check if program have products with it
                if(mapProduct.containsKey(program.Id)) {
                    
                    for(Product2 prod : mapProduct.get(program.Id)) {
                      
                      //Subhas Garhwal - 08/19/2017 - Issue--CR10808--QA--00005222
                      //Variable to hold the Product Family
                      String productFamily = prod.Family;
                      
                      //Subhas Garhwal - 08/25/2017 - Issue--CR10808--QA--00005222 - Commented else part
                      //Check for Royall Product
                      if(String.isNotBlank(program.Program_Line__c) &&  program.Program_Line__c == 'Royall')
              productFamily = program.Business_line__c;
            
                      //Subhas Garhwal - 08/19/2017 - Issue--CR10808--QA--00005222 - Added Program Line for family
                        //update all the products associated with the program with the program id
                        products.add(new Product2(Id = prod.Id, Name = program.Name, ProductCode = program.Program_Acronym__c,
                                      Family = productFamily, IsActive = status));
                    }
                } else {
                    
                    //Subhas Garhwal - 08/19/2017 - Issue--CR10808--QA--00005222 - Added Program Line for family
                    //add a new Product
                    Product2 product = new Product2(Name = program.Name, ProductCode = program.Program_Acronym__c,IsActive = status, Program__c = program.Id);
                
                  //Check for PL
                  if(String.isNotBlank(program.Program_Line__c) && program.Program_Line__c == 'Royall')
                    product.Family = program.Business_line__c;
                  
                  products.add(product);
                }
            }
        }*/
        
        //upsert the list of products
        if(products.size() > 0)
            upsert products;
    }
    
    //Added by - Ajit Surana - 03/30/2015 - CR-20150312-8758
    /**
     *  @description    :  Method to check if a program�s �Industry Member for Meetings� value is updated,
     *                     then update the all related institutions related to program�s membership.
     *
     *  @args           :  List of Program records, Map of old Program records
     * 
     *  @return         :  void
     * 
    **/ 
    //Commented by Mahendra Swarnkar - 02/12/2020 - CR-20190904-13307 - field Industry_Member__c on object Account is deleted 
    /*public static void updateInstitutionFromMembershipRelatedProgram(List<Program__c> newPrograms, Map<Id, Program__c> mapOldPrograms) {
    
        //Set to Program Ids
        Set<Id> progIds = new Set<Id>();
        
        //Update use case
        if(newPrograms!= null) {
        
            //Loop through Trigger.new
            for(Program__c pro : newPrograms){
            
                //Check if Industry Member for Meetings field is updated on Program record or not
                if(mapOldPrograms != null 
                    && (pro.Industry_Member_for_Meetings__c != mapOldPrograms.get(pro.Id).Industry_Member_for_Meetings__c))
                    progIds.add(pro.Id);
            }
        }
        
        //Checking set for size value
        if(progIds.size() > 0){
        
            //Map to hold Id => AccountId and Value => Instance Of Account
            Map<Id, Account> mapAccounts = new Map<Id, Account>();
        
            //Get appropriate Membership data from database
            for(Membership__c mem : [Select Id, Account_Name__c, Account_Name__r.Industry_Member__c, Program__c, 
                                         Program__r.Industry_Member_for_Meetings__c From Membership__c 
                                         Where Program__c != null AND Program__c IN : progIds AND Account_Name__c != null 
                                         AND Active_Core_Membership__c = 1 /*AND Industry_Member__c = true*//*]) {
        
                mapAccounts.put(mem.Account_Name__c, new Account(ID = mem.Account_Name__c, Industry_Member__c = mem.Program__r.Industry_Member_for_Meetings__c));
            }
            
            //Check for size
            if(mapAccounts.size() > 0) {
                Util.byPassAllTriggers = true;
                update mapAccounts.values();
                Util.byPassAllTriggers = false;
            }
        }
    }*/
    
    
    /**
     *  @description    :  Method to check if a program�s �Industry Member for Meetings� value is deleted,
     *                     then update the all related institutions related to program�s membership.
     *
     *  @args           :  Map of old Program records
     * 
     *  @return         :  void
     * 
    **/ 
    //Commented by Mahendra Swarnkar - 02/12/2020 - CR-20190904-13307 - field Industry_Member__c on object Account is deleted
    /*public static void updateInstitutionFromMembershipRelatedProgramDeletion(Map<Id, Program__c> mapOldPrograms) {
    
        //Map to hold Id => AccountId and Value => Instance Of Account
        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        
        //Get appropriate Membership data from database
        for(Membership__c mem : [Select Id, Account_Name__c, Account_Name__r.Industry_Member__c, Program__c, 
                                    Program__r.Industry_Member_for_Meetings__c From Membership__c 
                                    Where Program__c != null AND Program__c IN: mapOldPrograms.keySet() AND Account_Name__c != null]) {
        
                mapAccounts.put(mem.Account_Name__c, new Account(ID = mem.Account_Name__c, Industry_Member__c = false));
        }
            
        //Check for size
        if(mapAccounts.size() > 0) {
        
            Util.byPassAllTriggers = true;
            update mapAccounts.values();
            Util.byPassAllTriggers = false;
        }
    }*/
    
    //Added by - Subhash Garhwal - 06/25/2015 - CR-20150618-9014
    /**
     *  @description    :   Method to notify related Program Group and Perspective, If any change will occures in any Key field:
     *                      Business_line__c,New_Business_Marketer__c, New_Business_Vertical__c, Account_Management_Reporting_Vertical__c, Account_Management_Reporting_Group__c  
     *
     *  @args           :   List for new pragram value, Map for old value
     * 
     *  @return         :   void
     * 
     **/ 
    public static void keyInformationChangedNotification(List<Program__c> programs, Map<Id,Program__c> mapOldPrograms){
    
        //Set to hold Program Id, by using this we will fatch all the related Program Groups and Perspectives       
        Set<Id> setProgramIds = new Set<Id>();
    
        //Loop through Programs
        for(Program__c pro : programs){
            
            //Check for appropriate condition 
            if(pro.Effective_Start__c != mapOldPrograms.get(pro.Id).Effective_Start__c || pro.Effective_End__c != mapOldPrograms.get(pro.Id).Effective_End__c
                || pro.Business_line__c != mapOldPrograms.get(pro.Id).Business_line__c || pro.New_Business_Marketer__c != mapOldPrograms.get(pro.Id).New_Business_Marketer__c
                || pro.Account_Management_Reporting_Vertical__c != mapOldPrograms.get(pro.Id).Account_Management_Reporting_Vertical__c
                || pro.Account_Management_Reporting_Group__c != mapOldPrograms.get(pro.Id).Account_Management_Reporting_Group__c){
                
                    //Add Program Id in set
                    setProgramIds.add(pro.Id);
            }
        }
        
        //Check set size
        if(setProgramIds.size() > 0) {
            
            //Query through Email Template
            List<EmailTemplate> eTemp = [Select Id, DeveloperName From EmailTemplate Where DeveloperName =: Label.PROGRAM_KEY_FILED_CHANGE LIMIT 1];
            
            //List of SingleEmailMessage. This list used to notify PG and Perspectives Owners  
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            
            //Check for EmailTemplate
            if(eTemp.size() > 0) {
                
                //Set to hold Program Group Id
                Set<Id> setPGIds = new Set<Id>();
                
                //Set to hold Business Owner Ids
                Set<String> setBOwners = new Set<String>();
                
                //Query through Program_Relationship__c to get persoective or program group id 
                for(Program_Relationship__c pR : [Select Id, Program__c, Program_Perspective__r.Program_Group__c, Program_Perspective__r.Program_Group__r.Business_Owner__c, Program_Perspective__r.Program_Group__r.Business_Owner__r.Email
                                                         From Program_Relationship__c Where Program__c IN: setProgramIds AND Program_Perspective__r.Program_Group__c != null]) {
                                                                                    
                    //Add Program Group Id in set
                    setPGIds.add(pR.Program_Perspective__r.Program_Group__c);
                    
                    //Check if set contains Unique combination
                    if(String.isNotBlank(pR.Program_Perspective__r.Program_Group__r.Business_Owner__c)
                        && !setBOwners.contains(pR.Program_Perspective__r.Program_Group__r.Business_Owner__c) && pR.Program_Perspective__r.Program_Group__r.Business_Owner__r.Email != null ) {
                        
                        //Add new Email into Email list
                        emails.add(EmailHandler.email(eTemp[0].Id, pR.Program_Perspective__r.Program_Group__r.Business_Owner__c, null));
                        
                        //Add Business Owner Id in set
                        setBOwners.add(pR.Program_Perspective__r.Program_Group__r.Business_Owner__c);
                    }
                }
                
                //Check for Program Group set size
                if(setPGIds.size() > 0) {
                    
                    //Query through Program_Perspective__c to get persoective 
                    for(Program_Perspective__c pP : [Select Id, Program_Group__c, Perspective__c, Perspective__r.Business_Owner__c
                                                            From Program_Perspective__c Where Program_Group__c IN: setPGIds AND Perspective__r.Business_Owner__r.Email != null]) {
                                                                                        
                        //Check if set contains Unique combination
                        if(!setBOwners.contains(pP.Perspective__r.Business_Owner__c)) {
                            
                            //Add new Email into Email list
                            emails.add(EmailHandler.email(eTemp[0].Id, pP.Perspective__r.Business_Owner__c, null));
                            
                            //Add Business_Owner__c in set
                            setBOwners.add(pP.Perspective__r.Business_Owner__c);
                        }
                    }   
                }
                
                //Subhash Garhwal - 23/7/2015 - CR-20150618-9013 - Code Commented as per Program Management Issues submitted by Taylor
                //Send email
                //if(emails.size() > 0)
                    //Messaging.SendEmail(emails);
            }                                   
        }
    }
    
    //Added by - Padmesh Soni - 08/04/2015 - CR-20150729-9114
    //Code Commented By - Rajeev Jain - 04/19/2016 - CR-20151120-9402 - Removed this method from program trigger since it is no longer in use
    /**
     *  @description    :   Method to create Incentive Change Log (ICL) record when some specific fields are update.
     *                  
     *                          Field modified          Change Type         Populate In ICL
     *                      
     *                      1.  Name                    Text                Program
     *                          Program Formal Name
     *                          Program Acronym     
     *
     *                      2.  Effective dates         Effective dates     Program
     *                                                                      Start date, end date (depending on chg)
     *                      
     *                      3.  Status                  Status              Program
     *
     *  @args           :   List for new program, Map for old Programs
     * 
     *  @return         :   void
     * 
     **/ 
    /*public static void createIncentiveChangeLog(List<Program__c> programs, Map<Id,Program__c> mapOldPrograms){
    
        //List of Incentive Change Log to be inserted
        List<Incentive_Change_Log__c> incentiveChangeLogs = new List<Incentive_Change_Log__c>();
        
        //Loop throgh programs
        for(Program__c pro : programs) {
            
            //Check if some name fields are updated ,comparing old and new fields
            if(pro.Name != mapOldPrograms.get(pro.Id).Name 
                || pro.Program_Formal_Name__c != mapOldPrograms.get(pro.Id).Program_Formal_Name__c
                || pro.Program_Acronym__c != mapOldPrograms.get(pro.Id).Program_Acronym__c)
                incentiveChangeLogs.add(new Incentive_Change_Log__c(Change_Type__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_TEXT, Program__c = pro.Id));
            
            //Check if dates fields are updated, comparing old and new fields
            if(mapOldPrograms != null && (pro.Effective_Start__c != null || pro.Effective_End__c != null) 
                && (pro.Effective_Start__c != mapOldPrograms.get(pro.Id).Effective_Start__c 
                || pro.Effective_End__c != mapOldPrograms.get(pro.Id).Effective_End__c)) {
            
                //Instance of Incentive Change Log
                Incentive_Change_Log__c iCL = new Incentive_Change_Log__c(Program__c = pro.Id, Change_Type__c = ISSPConstants.INCENTIVE_CHANGE_LOG_VALUE_TYPE_EFFECTIVE_DATES);
                
                //Check if start date changed
                if(pro.Effective_Start__c != mapOldPrograms.get(pro.Id).Effective_Start__c)
                    iCL.Start_Date__c = pro.Effective_Start__c;
                    
                //Check if end date changed 
                if(pro.Effective_End__c != mapOldPrograms.get(pro.Id).Effective_End__c)
                    iCL.End_Date__c = pro.Effective_End__c;
                
                //Add list 
                incentiveChangeLogs.add(iCL);
            }   
                
            //Check if status field are updated ,comparing old and new field
            if(mapOldPrograms != null && pro.Status__c != mapOldPrograms.get(pro.Id).Status__c)
                incentiveChangeLogs.add(new Incentive_Change_Log__c(Change_Type__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_STATUS, Program__c = pro.Id));
        }
        
        //Check list size
        if(incentiveChangeLogs.size() > 0)
            insert incentiveChangeLogs;     
    } */
    
    /**
     *  @description    :   This Method is used to check if the Program's below field changes than fire an Batch thay will create the membership records Under the Institutions.
              1. Applicable Segments
              2. Create Memberships?

     *  @args           :   List for new pragram value, Map for old value
     * 
     *  @return         :   void
     * 
     *  @Created BY     : Abhinav Sharma - 04/19/2018
     **/ 
    public static void insertNewMembershipIfProgramChange(List<Program__c> programs, Map<Id,Program__c> mapOldPrograms) {
      
        //Set to hold the Program Ids 
        Set<Id> setProgramIds = new Set<Id>();
            
        //Check for the Update case 
        for(Program__c prgrm : programs) {
          
            //Check if there is field changes   
            if( mapOldPrograms != null && prgrm.Status__c == 'Active' && prgrm.Create_memberships__c == 'Yes'
                && (mapOldPrograms.get(prgrm.Id).Applicable_Segments__c !=  prgrm.Applicable_Segments__c  
                    || mapOldPrograms.get(prgrm.Id).Create_memberships__c !=  prgrm.Create_memberships__c) ) {
              
                //add the Program Id in the Set
              setProgramIds.add(prgrm.Id);              
            }
        }
        
        //Check the size of set.
        if(setProgramIds.size() > 0) {
          
            //Calling a Batch class that will create the membership records for the institutions
            Batch_Create_Memberships b = new Batch_Create_Memberships();
            b.setProgramIds = setProgramIds;
            b.soqlstr = 'SELECT ID, Name, RecordTypeId, Recordtype.Name FROM Account';
                
            //Execute the Batch 
            Id JobId = Database.executeBatch(b, 5);
        }
     }
     
     /**
     * 
     *  @description    :   Update Subscription records when Program fields get updated 
     *
     *  @args           :   List<Program__c> programs, Map<Id,Program__c> mapOldPrograms
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.0 - Created - 07/05/2018 - Subhash Garhwal - CR-20180323-12122 
     * 
     **/
     public static void updateSubscriptionFields(List<Program__c> programs, Map<Id,Program__c> mapOldPrograms) {
     
        //Set to hold the Program Ids 
        Map<Id, Program__c> mapOfPrograms = new Map<Id, Program__c>();
        
        //List to update the Subscriptions
        List<SBQQ__Subscription__c> subscriptionsToBeUpdate = new List<SBQQ__Subscription__c>();
            
        //Check for the Update case 
        for(Program__c program : programs) {
     
            if(program.Account_Management_Group__c != mapOldPrograms.get(program.Id).Account_Management_Group__c 
               || program.Account_Management_Reporting_Business__c != mapOldPrograms.get(program.Id).Account_Management_Reporting_Business__c
               || program.Account_Management_Reporting_Vertical__c != mapOldPrograms.get(program.Id).Account_Management_Reporting_Vertical__c 
               || program.Account_Management_Reporting_Group__c != mapOldPrograms.get(program.Id).Account_Management_Reporting_Group__c
               || program.New_Business_Marketer__c != mapOldPrograms.get(program.Id).New_Business_Marketer__c 
               || program.New_Business_Group__c != mapOldPrograms.get(program.Id).New_Business_Group__c){
                
                
                //Add the Program Id in to the Set
                mapOfPrograms.put(program.Id, program);
           }
        }
        
        //Size Check
        if(mapOfPrograms.size() > 0) {
            
            //Query over the Subscription 
            for(SBQQ__Subscription__c sub : [Select Id, Program__c, Account_Management_Group__c, Account_Management_Reporting_Business__c, Account_Management_Reporting_Vertical__c,
                                                 Account_Management_Reporting_Group__c, New_Business_Marketer__c, New_Business_Group__c From SBQQ__Subscription__c 
                                                 Where Program__c IN : mapOfPrograms.keySet()]){
                                                    
                //Adding values into the values
                subscriptionsToBeUpdate.add(new SBQQ__Subscription__c(Id = sub.Id, Account_Management_Group__c = mapOfPrograms.get(sub.Program__c).Account_Management_Group__c,
                                                                        Account_Management_Reporting_Vertical__c = mapOfPrograms.get(sub.Program__c).Account_Management_Reporting_Vertical__c,
                                                                        Account_Management_Reporting_Business__c = mapOfPrograms.get(sub.Program__c).Account_Management_Reporting_Business__c,
                                                                        Account_Management_Reporting_Group__c = mapOfPrograms.get(sub.Program__c).Account_Management_Reporting_Group__c,
                                                                        New_Business_Marketer__c = mapOfPrograms.get(sub.Program__c).New_Business_Marketer__c,
                                                                        New_Business_Group__c = mapOfPrograms.get(sub.Program__c).New_Business_Group__c));
            }
        }
        
        //Check for size
        if(subscriptionsToBeUpdate.size() > 0) {
        
            Util.byPassAllTriggers = true;
            update subscriptionsToBeUpdate;
            Util.byPassAllTriggers = false;
        }
     }
    
    //This method is to cover the Catch Part of the Trigger_Program    
    public static void CustomExceptiontoCoverCatch () {
        throw new CustomException('I am only covering Catch part');
    }
    
    /**
     * 
     *  @description    :   validate the duplicate Program Acronym for new created program
     *
     *  @args           :   List<Program__c> programs
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.0 - Created - 09/28/2021 - Nikita Kumari - CR-20210910-15426 
     * 
     **/
    public static void validateProgramAcronyms(List<Program__c> programs){
        
        //Set to hold the ProgramAcronyms
        Set<String> setOfNewProgramAcronym = new Set<String>();
        
        //populating the setOfNewProgramAcronym
        for(Program__c prgms : programs){
            if(String.isNotBlank(prgms.Program_Acronym__c)){
                if(setOfNewProgramAcronym.contains(prgms.Program_Acronym__c)){
                    prgms.addError(System.Label.ERROR_PROGRAM_DUPLICATE_PROGRAM_ACRONYM);
                }
                else{
                    setOfNewProgramAcronym.add(prgms.Program_Acronym__c);
                }
            }
            
        }
        //checking size of setOfNewProgramAcronym
        if(setOfNewProgramAcronym.size() > 0){
            
            //Map to hold Exesting ProgramAcronyms with Program Id
            Map<String,Set<Id>> mapOfExestingProgramAcronyms = new Map<String,Set<Id>>();
        
            //populating the mapOfExestingProgramAcronyms
            for(Program__c program : [Select Id,Program_Acronym__c From Program__c Where Program_Acronym__c IN: setOfNewProgramAcronym]){
                if(!mapOfExestingProgramAcronyms.containsKey(program.Program_Acronym__c)){
                    mapOfExestingProgramAcronyms.put(program.Program_Acronym__c, new set<Id>());
                }
                mapOfExestingProgramAcronyms.get(program.Program_Acronym__c).add(program.Id);
            }
        
            if(mapOfExestingProgramAcronyms.size()>0 && mapOfExestingProgramAcronyms.keySet().size()>0){
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/';
                String RecordLinks = '';
                for(Program__c program : programs){
                    if(mapOfExestingProgramAcronyms.containsKey(program.Program_Acronym__c)){
                        for(Id programId : mapOfExestingProgramAcronyms.get(program.Program_Acronym__c)){
                            RecordLinks += baseUrl + programId + '; ';
                        }
                        RecordLinks = RecordLinks.removeEnd('; ');
                        program.addError(System.Label.ERROR_PROGRAM_DUPLICATE_PROGRAM_ACRONYM_WITH_RECORDLINK + RecordLinks);
                    }
                }
            } 
        }    
    }
}