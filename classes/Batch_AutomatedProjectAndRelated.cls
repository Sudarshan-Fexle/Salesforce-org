/**
*  Description     :   This batch class is run after 15 minutes when standard contract is created and 
						creates below related records:
*					   	- Project/Dployment and Job ticket. 

*  Created By      :   Dipesh Gupta
*
*  Created Date    :   02/25/2020
*
*  Current Version :   v1.0
*       
*  Revision Log    :   V_1.0 Created 
*                      V_1.1 - 01/06/2020 - Modified By - CR-20200522-14096 - Resolve Deployment Creation for products without Subscription Periods
*		       V_1.2 - 10/01/2020 - Modified By - CR-20200626-14231 - Victor Hanson - auto-populate job number on job ticket
*		       V_1.3 - 11/17/2020 - Modified By - CR-20200924-14549 - Abhinav Sharma - Misleading Batch Status on Contract
*                      V_1.4 - 04/30/2021 - Modified By - CR-20210323-15016 - Neha Sharma - populate drop type on job ticket
*		       V_1.5 - 06/17/2021 - Modified By - Shalu Sharma - CR-20200924-14551 - Create Project/JT when Sub Period Stage changes
*		       V_1.6 - 09/22/2021 - Modified By - Abhinav Sharma - CR-20210913-15430 - Job Ticket's Name incorrectly formatted
*		       V_1.7 - 01/25/2022 - Modified By - Shalu Sharma - CR-20220125-15747 - Populate Record Type on Job Ticket records 
**/
global class Batch_AutomatedProjectAndRelated implements Database.Batchable<sObject>, Database.Stateful
{
    public Set<Id> contractIds = new Set<Id>();
    public String logMessage = '';

    //Modified By - Shalu Sharma - 06/17/2021 - CR-20200924-14551 - Create Project/JT when Sub Period Stage changes
    public String query = '';
    public List<Contract> listOfContractsToCheckProject = new List<Contract>();
    public Map<Id, Set<String>> mapOfProjectIdWithJTs = new Map<Id, Set<String>>();
    public Map<Id, Id> mapOfProjectIdWithDeploymentIds = new Map<Id, Id>();
    
    //Modified By - Abhinav Sharma - 09/22/2021 - CR-20210913-15430 - Job Ticket's Name incorrectly formatted
    public Set<Id> setOfBoxCheckEligibleJTRecords = new Set<Id>();
    
    global Batch_AutomatedProjectAndRelated(Set<Id> contractIds)
    {	
        if(contractIds == null || contractIds.size() == 0) 
            throw New CustomException(System.Label.Set_Parameter_Value);
        
        this.contractIds = contractIds;   
        logMessage = '';
    }

    //Added By - Shalu Sharma - 06/17/2021 - CR-20200924-14551 - Create Project/JT when Sub Period Stage changes
    global Batch_AutomatedProjectAndRelated(Set<Id> contractIds, string query)
    {	
        if(contractIds == null || contractIds.size() == 0) 
            throw New CustomException(System.Label.Set_Parameter_Value);
        
        this.contractIds = contractIds;   
        this.query = query;
        logMessage = '';
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        if(String.isBlank(query)){
            query = 'SELECT Id, Batch_Status__c '+
                'FROM Contract WHERE Id IN : contractIds AND Batch_Status__c =\''+ System.Label.Ready_For_Batch +'\'';
        }
        return Database.getQueryLocator(query);	
    }
    
    global void execute(Database.BatchableContext BC,List<Contract> listOfContracts) 
    {

        //Added By - Shalu Sharma - 06/17/2021 - CR-20200924-14551 - Create Project/JT when Sub Period Stage changes
        listOfContractsToCheckProject = new List<Contract>();
        listOfContractsToCheckProject = listOfContracts;
        
        Map<Id,Contract> mapOfContract_BatchStatusToBeUpdated = new Map<Id,Contract>();
                                
        //Map to hold the ContractId With Subscription Period Records. 
        Map<Id, List<Subscription_Period__c>> mapContractIdWithSubscriptionPeriods = new Map<Id, List<Subscription_Period__c>>();
       
        //List to hold the Subscription Period for which we need to create Deployment and Project. 
        List<Subscription_Period__c> subscriptionPeriod_CreateProjectAndDeployment = new List<Subscription_Period__c>();
        
        //List to hold the Subscription Period for which we need to create project and Job Ticket. 
        List<Subscription_Period__c> subscriptionPeriod_CreateProjectAndJobTicket = new List<Subscription_Period__c>();
        
        //List to hold the Subscription Period for which we need to create project and Job Ticket but for Parent Product. 
        List<Subscription_Period__c> subscriptionPeriod_CreateProjectAndJobTicket_ParentProduct = new List<Subscription_Period__c>();
        
        //List to hold the Subscription Period for which we need to create project and Deployment but for parent Product. 
        List<Subscription_Period__c> subscriptionPeriod_CreateProjectAndDeployment_ParentProduct = new List<Subscription_Period__c>();
        
        //List to hold the Subscription Period for which we need to create project only. 
        Set<Subscription_Period__c> subscriptionPeriod_CreateProject = new Set<Subscription_Period__c>();
        
        //10/01/2020 - CR-20200626-14231 - Victor Hanson - add Job_No__c to the list of fields
        for(Subscription_Period__c sP: [SELECT Id, Year__c, Contract__c, Institution__c, Job_No__c,
                                        Total_Paper_only_Contract_Quantity__c, Stage__c,
                                        Source_Opportunity__c, Segment_Index__c, Period_End_Date__c,
                                        Program_Subscription__r.Membership__c, 
                                        Program_Subscription__r.Program__c,
                                        Program_Subscription__r.SBQQ__RequiredByProduct__c,
                                        Program_Subscription__r.SBQQ__Product__c,
                                        Program_Subscription__r.SBQQ__Product__r.Family,
                                        Program_Subscription__r.SBQQ__Product__r.Disregard_for_Revenue_Automation__c,
                                        Program_Subscription__r.SBQQ__RequiredByProduct__r.Program__c,
                                        Program_Subscription__r.SBQQ__ProductOption__r.Create_Deployment__c,
                                        Program_Subscription__r.SBQQ__ProductOption__r.Create_Job_Ticket__c
                                        FROM Subscription_Period__c WHERE 
                                        Program_Subscription__r.SBQQ__Product__r.Family =: System.Label.Enrollment_Services
                                        AND Program_Subscription__c != null
                                        AND Program_Subscription__r.SBQQ__Product__r.Disregard_for_Revenue_Automation__c != TRUE
                                        AND Stage__c != 'Pending'
                                        AND Contract__c != null
                                        AND Contract__c IN : contractIds]) 
        {
            //Condition 1
            if(String.isBlank(sP.Program_Subscription__r.SBQQ__RequiredByProduct__c)) {
                
                if(sP.Program_Subscription__r.SBQQ__ProductOption__r.Create_Deployment__c) {
                    
                    //Filling the respective list. 
                    subscriptionPeriod_CreateProjectAndDeployment.add(sP);
                    
                }else if(sP.Program_Subscription__r.SBQQ__ProductOption__r.Create_Job_Ticket__c) {
                    
                    //Filling the respective list. 
                    subscriptionPeriod_CreateProject.add(sP);
                    
                    //VH 05/07/2020: Commenting out the criteria below, because some Products (ie: EAM Visit Campaign) don't have paper quantity
                    //VH 04/29/2020: Added Total_Paper_only_Contract_Quantity__c > 0 because we only need to generate Job Tickets if Total Paper Only is greater than zero
                    //if (sp.Total_Paper_only_Contract_Quantity__c > 0) {
                        //Filling the respective list. 
                        subscriptionPeriod_CreateProjectAndJobTicket.add(sP);
                    //}
                    
                }else {
                    //Filling the respective list. 
                    subscriptionPeriod_CreateProject.add(sP);
                }
            } else {
                
                //This block is used for the parent Product project and deployment and Job ticket creation. 
                if(sP.Program_Subscription__r.SBQQ__ProductOption__r.Create_Deployment__c) {
                    
                    subscriptionPeriod_CreateProjectAndDeployment_ParentProduct.add(sP);
                    
                }else if(sP.Program_Subscription__r.SBQQ__ProductOption__r.Create_Job_Ticket__c) {
                    
                    //Filling the respective list. 
                    subscriptionPeriod_CreateProject.add(sP);
                    
                    //VH 05/07/2020: Commenting out the criteria below, because some Products (ie: EAM Visit Campaign) don't have paper quantity
                    //VH 04/29/2020: Added Total_Paper_only_Contract_Quantity__c > 0 because we only need to generate Job Tickets if Total Paper Only is greater than zero
                    //if (sp.Total_Paper_only_Contract_Quantity__c > 0) {
                        //also create job tickets
                        subscriptionPeriod_CreateProjectAndJobTicket_ParentProduct.add(sp);
                    //}
                    
                }else {
                    //Filling the respective list. 
                    subscriptionPeriod_CreateProject.add(sP);
                }
                
            }
        }

        /*Checking the size of lists and creating the projects and Deplpoyments*/
        if(subscriptionPeriod_CreateProjectAndDeployment.size() > 0) {

            //Creating the Instance of Projects. 
            Map<Id, Project__c> mapOfProjectsToBeCreated = createInstancesOfProject(new Set<Subscription_Period__c>(subscriptionPeriod_CreateProjectAndDeployment));
            
            if(mapOfProjectsToBeCreated.size() > 0) {

                //Inserting the Projects. 
                insert mapOfProjectsToBeCreated.values();

                //Inserting the Deployment just after project is inserted. 
                Map<Id, Deployment__c> mapOfDeploymentsToBeCreated = createDeploymentInstance(mapOfProjectsToBeCreated.values());
    
                if(mapOfProjectsToBeCreated.size() > 0)
                    insert mapOfDeploymentsToBeCreated.values();
            }
            
            for(Subscription_Period__c sP : subscriptionPeriod_CreateProjectAndDeployment)
                //Updating the contract status
                mapOfContract_BatchStatusToBeUpdated.put(sP.Contract__c, new Contract(Id = sP.Contract__c, Batch_Status__c = Label.Batch_Completed_Records_Created));
        }

        /*Checking if the Job ticket and Project to be created */
        if(subscriptionPeriod_CreateProjectAndJobTicket.size() > 0) {

            //Creating the Instance of Projects. 
            Map<Id, Project__c> mapOfProjectsToBeCreated = createInstancesOfProject(new Set<Subscription_Period__c>(subscriptionPeriod_CreateProjectAndJobTicket));
            
            insert mapOfProjectsToBeCreated.values();

            if(mapOfProjectsToBeCreated.size() > 0) {

                //Inserting the Job Tickets. 
                List<Job_Ticket__c> listOfJobTickets = createInstancesOfJobTickets(mapOfProjectsToBeCreated.values(), 
                                                         new Map<Id, Subscription_Period__c> (subscriptionPeriod_CreateProjectAndJobTicket));
                
                //Modified By - Abhinav Sharma - 09/22/2021 - CR-20210913-15430 - Job Ticket's Name incorrectly formatted
                if(listOfJobTickets.size() > 0) {
                    Util.bypassAllTriggers = false;
                    JobTicketTriggerHelper.Bypass_createBoxFoldersForJobTicket = true;
                    insert listOfJobTickets;
                    JobTicketTriggerHelper.Bypass_createBoxFoldersForJobTicket = false;

                    for(Job_Ticket__c jt : listOfJobTickets){
                        setOfBoxCheckEligibleJTRecords.add(jt.Id);
                    }
                }
            }
            
            for(Subscription_Period__c sP : subscriptionPeriod_CreateProjectAndJobTicket)
                //Updating the contract status
                mapOfContract_BatchStatusToBeUpdated.put(sP.Contract__c, new Contract(Id = sP.Contract__c, Batch_Status__c = Label.Batch_Completed_Records_Created));
        
        }

        /*This part is used to create only Project records. */
        if(subscriptionPeriod_CreateProject.size() > 0) {
            
            //Creating the Instance of Projects. 
            Map<Id, Project__c> mapOfProjectsToBeCreated = createInstancesOfProject(subscriptionPeriod_CreateProject);
            
            //11/17/2020 - Modified by - CR-20200924-14549 - Abhinav Sharma - Misleading Batch Status on Contract (Add curly brackets around if statement)
            if(mapOfProjectsToBeCreated.size() > 0){
                insert mapOfProjectsToBeCreated.values();
                
                for(Subscription_Period__c sP : subscriptionPeriod_CreateProject)
                    //Updating the contract status
                    mapOfContract_BatchStatusToBeUpdated.put(sP.Contract__c, new Contract(Id = sP.Contract__c, Batch_Status__c = Label.Batch_Completed_Records_Created));
            }
        
        }

        /*This part is used to  */        
        if(subscriptionPeriod_CreateProjectAndDeployment_ParentProduct.size() > 0) {
            
            //Set to hold the product Ids. 
            Set<Id> setProductIds = new Set<Id>();

            Map<String, Project__c> mapProductWithUniqueKeys = new Map<String, Project__c>();

            //Check if the parent Products. 
            for(Subscription_Period__c sP : subscriptionPeriod_CreateProjectAndDeployment_ParentProduct) {
                setProductIds.add(sP.Program_Subscription__r.SBQQ__RequiredByProduct__c);
            }

            //Modified By - Shalu Sharma - 06/17/2021 - CR-20200924-14551 - Create Project/JT when Sub Period Stage changes
            for(Project__c proj : [Select Contract2__c, Id, Fiscal_Year__c, Product2__c, Product__c, Subscription_Period__c From Project__c Where Product2__c IN: setProductIds]) {

                String uniquekey = getUniqueKey(proj);
                mapProductWithUniqueKeys.put(uniquekey, proj);
            }

            
            List<Subscription_Period__c> sPeiodThatDoesnthaveProjectCreated  = new List<Subscription_Period__c>();

            //Checking for the Map of Product with Unique Key.
            if(mapProductWithUniqueKeys.size() > 0) {
                
                for(Subscription_Period__c sPeriod : subscriptionPeriod_CreateProjectAndDeployment_ParentProduct) {
                    
                    String uniquekey = getUniqueKey(sPeriod);

                    //Check if the Project is already exist. 
                    if(mapProductWithUniqueKeys.containsKey(uniquekey) && mapProductWithUniqueKeys.get(uniquekey) != null) {

                        //Do nothing
                    }
                    else {
                        sPeiodThatDoesnthaveProjectCreated.add(sPeriod);
                    }

                }
            }

            //Calling a method.
            Map<Id, Project__c> mapProjects = new Map<Id, Project__c>();

            if(sPeiodThatDoesnthaveProjectCreated.size() > 0) {

                //Calling a method that will call the project creation process. 
                mapProjects = createInstancesOfProject(new Set<Subscription_Period__c>(sPeiodThatDoesnthaveProjectCreated));
                insert mapProjects.values();
            }

            //Joining both the Project list. 
            List<Project__c> projectsToBeSentForDeploymentCreation = new List<Project__c>();
            
            if(mapProjects.values().size() > 0)
                projectsToBeSentForDeploymentCreation.addAll(mapProjects.values());
            
            if(mapProductWithUniqueKeys.values().size() > 0 ) 
                projectsToBeSentForDeploymentCreation.addAll(mapProductWithUniqueKeys.values());
            
            if(projectsToBeSentForDeploymentCreation.size() > 0) {

                Map<Id, Deployment__c> mapOfDeployments = createDeploymentInstance(projectsToBeSentForDeploymentCreation);
            
                insert mapOfDeployments.values();
                
                for(Subscription_Period__c sP : subscriptionPeriod_CreateProject)
                    //Updating the contract status
                    mapOfContract_BatchStatusToBeUpdated.put(sP.Contract__c, new Contract(Id = sP.Contract__c, Batch_Status__c = Label.Batch_Completed_Records_Created));
        
            }

        }

        if(subscriptionPeriod_CreateProjectAndJobTicket_ParentProduct.size() > 0) {
            
            
            //Set to hold the product Ids. 
            Set<Id> setProductIds = new Set<Id>();

            Map<String, Project__c> mapProductWithUniqueKeys = new Map<String, Project__c>();

            //Check if the parent Products. 
            for(Subscription_Period__c sP : subscriptionPeriod_CreateProjectAndJobTicket_ParentProduct) {
                setProductIds.add(sP.Program_Subscription__r.SBQQ__RequiredByProduct__c);
            }

            //Modified By - Shalu Sharma - 06/17/2021 - CR-20200924-14551 - Create Project/JT when Sub Period Stage changes
            for(Project__c proj : [Select Id, Contract2__c,Fiscal_Year__c, Product2__c, Product__c, Subscription_Period__c From Project__c Where Product2__c IN: setProductIds OR Contract2__c IN :mapOfContract_BatchStatusToBeUpdated.keySet()]) {

                String uniquekey = getUniqueKey(proj);
                mapProductWithUniqueKeys.put(uniquekey, proj);
            }

            
            List<Subscription_Period__c> sPeiodThatDoesnthaveProjectCreated  = new List<Subscription_Period__c>();

            //Checking for the Map of Product with Unique Key.
            if(mapProductWithUniqueKeys.size() > 0) {
                
                for(Subscription_Period__c sPeriod : subscriptionPeriod_CreateProjectAndJobTicket_ParentProduct) {
                    
                    String uniquekey = getUniqueKey(sPeriod);

                    //Check if the Project is already exist. 
                    if(mapProductWithUniqueKeys.containsKey(uniquekey) && mapProductWithUniqueKeys.get(uniquekey) != null) {

                        //Do nothing
                    }
                    else {
                        sPeiodThatDoesnthaveProjectCreated.add(sPeriod);
                    }

                }
            }

            //Calling a method.
            Map<Id, Project__c> mapProjects = new Map<Id, Project__c>();

            if(sPeiodThatDoesnthaveProjectCreated.size() > 0) {

                //Calling a method that will call the project creation process. 
                mapProjects = createInstancesOfProject(new Set<Subscription_Period__c>(sPeiodThatDoesnthaveProjectCreated));
                insert mapProjects.values();
            }

            //Joining both the Project list. 
            List<Project__c> projectsToBeSentForJobTicketCreation = new List<Project__c>();
            
            if(mapProjects.values().size() > 0)
                projectsToBeSentForJobTicketCreation.addAll(mapProjects.values());
            
            if(mapProductWithUniqueKeys.values().size() > 0 ) 
            projectsToBeSentForJobTicketCreation.addAll(mapProductWithUniqueKeys.values());
            
            if(projectsToBeSentForJobTicketCreation.size() > 0) {

                List<Job_Ticket__c> listOfJobTickets = createInstancesOfJobTickets(projectsToBeSentForJobTicketCreation, 
                    new Map<Id, Subscription_Period__c>(subscriptionPeriod_CreateProjectAndJobTicket_ParentProduct) );
                
                //Modified By - Abhinav Sharma - 09/22/2021 - CR-20210913-15430 - Job Ticket's Name incorrectly formatted
                if(listOfJobTickets.size() > 0) {
                    Util.bypassAllTriggers = false;
                    JobTicketTriggerHelper.Bypass_createBoxFoldersForJobTicket = true;
                    insert listOfJobTickets;
                    JobTicketTriggerHelper.Bypass_createBoxFoldersForJobTicket = false;

                    for(Job_Ticket__c jt : listOfJobTickets){
                        setOfBoxCheckEligibleJTRecords.add(jt.Id);
                    }
                }
                
                 for(Subscription_Period__c sP : subscriptionPeriod_CreateProject)
                    //Updating the contract status
                    mapOfContract_BatchStatusToBeUpdated.put(sP.Contract__c, new Contract(Id = sP.Contract__c, Batch_Status__c = Label.Batch_Completed_Records_Created));
        
            }
        }
        
                   
        for(Contract cont : listOfContracts)
        {	
            if(!mapOfContract_BatchStatusToBeUpdated.containsKey(cont.Id))
                 mapOfContract_BatchStatusToBeUpdated.put(cont.Id, new Contract(Id = cont.Id, Batch_Status__c = Label.Batch_Completed_No_Records ));  
            
        }
        
        if(mapOfContract_BatchStatusToBeUpdated.size() > 0)
            update mapOfContract_BatchStatusToBeUpdated.values();
    }
    
    global void finish(Database.BatchableContext BC)
    {  
        //Modified By - Abhinav Sharma - 09/22/2021 - CR-20210913-15430 - Job Ticket's Name incorrectly formatted
        if(setOfBoxCheckEligibleJTRecords.size() > 0){

            //Calling a another batch job that will run for Job Ticket records. 
            Batch_CreateBoxFolderForJT batchJobTicket = new Batch_CreateBoxFolderForJT(setOfBoxCheckEligibleJTRecords);
            Database.executeBatch(batchJobTicket, Integer.valueOf(Label.ProductionTracking_BoxBatchSize));
        } 
        
        if(String.isNotBlank(logMessage))
            Util.sendBatchStatus(BC.getJobId(), 'Batch_AutomatedESCampAndRelated', logMessage, Label.Salesforce_Admin_Email);
    } 
    
    //Method to create the Es campaign instances. 
    public Map<Id, Project__c> createInstancesOfProject(Set<Subscription_Period__c> sPs ) {
        
        Map<Id, Project__c> mapOfProjectWithSPIds = new Map<Id, Project__c>();
        Map<String, Project__c> mapUKToProj = new Map<String, Project__c>();
        
        //Added By - Shalu Sharma - 06/17/2021 - CR-20200924-14551 - Create Project/JT when Sub Period Stage changes
        if(listOfContractsToCheckProject.size() > 0){

            //get existing projects to aviod multipal creation
            for(Project__c proj : [Select Contract2__c, Id, Fiscal_Year__c, Product2__c, Product__c, Subscription_Period__c 
                                    From Project__c Where Contract2__c IN: listOfContractsToCheckProject]) 
            {
                String uniquekey = getUniqueKey(proj);
                mapUKToProj.put(uniquekey, proj);
            }
        }
        

		for(Subscription_Period__c sP : sPs)
        {
            //check for duplicate projects
            String uk = getUniqueKey(sP);
            if (mapUKToProj.containsKey(uk) || sp.Program_Subscription__r.SBQQ__RequiredByProduct__r.Program__c == null) continue;

            Project__c project = new Project__c();
            project.Institution__c = sP.Institution__c;
            project.Fiscal_Year__c = String.valueOf(sP.Period_End_Date__c.year());
            // VH 04/30/2020: commented out line below because related to project because project is at the first-level parent (Custom App Marketing), 
            //                which can have multiple second-tier parents (New Names,etc)
            //project.Subscription_Period__c = sP.Id;
            project.Primary_Paid_Membership__c = sP.Program_Subscription__r.Membership__c;
            project.Product__c = sP.Program_Subscription__r.SBQQ__RequiredByProduct__r.Program__c;
            project.Product2__c = sP.Program_Subscription__r.SBQQ__RequiredByProduct__c;
            project.Contract2__c = sP.Contract__c;
            project.RecordTypeId = Constants.RECORD_TYPE_ID_ES_PROJECT;

            mapOfProjectWithSPIds.put(sP.Id, project);
            mapUKToProj.put(uk, project);
        }        
        
        return mapOfProjectWithSPIds;
    }
    
    //Method to create the Job Tickets instances. 
    public List<Job_Ticket__c> createInstancesOfJobTickets(List<Project__c> projects, Map<Id, Subscription_Period__c> mapOfSubscriptionPeriods ) {
        
        List<Job_Ticket__c> listOfJobTickets = new List<Job_Ticket__c>();

        //convert subscription periods to key map
        Map<String, List<Subscription_Period__c>> ukToSubPeriodList = new Map<String, List<Subscription_Period__c>>();
        for (Subscription_Period__c sP : mapOfSubscriptionPeriods.values()) {
            String uk = getUniqueKey(sP);
            List<Subscription_Period__c> tempSPList = ukToSubPeriodList.get(uk);
            if (tempSPList == null) tempSPList = new List<Subscription_Period__c>();
            
            tempSPList.add(sP);
            ukToSubPeriodList.put(uk, tempSPList);
        }

        if(projects.size() > 0){

            for(Job_Ticket__c jt : [Select Id, Project__c, Program__c, Fiscal_Year__c from Job_Ticket__c 
                                    Where Project__c != null And Project__c IN :projects])
            {
                if(!mapOfProjectIdWithJTs.containsKey(jt.Project__c))
                    mapOfProjectIdWithJTs.put(jt.Project__c, new Set<String>());
                mapOfProjectIdWithJTs.get(jt.Project__c).add(jt.Project__c +'-'+ jt.Program__c +'-'+ jt.Fiscal_Year__c);
            }
        }
        
		for(Project__c proj : projects)
        {
            
            //Modified By - Shalu Sharma - 06/17/2021 - CR-20200924-14551 - Create Project/JT when Sub Period Stage changes
            
            //get each subscription period for this parent product and year
            List<Subscription_Period__c> listSubPeriods = ukToSubPeriodList.get(proj.Contract2__c+ '-' +proj.Product2__c + '-' + proj.Fiscal_Year__c);
            
            if (listSubPeriods != null) {

                //Modified By - Shalu Sharma - 06/17/2021 - CR-20200924-14551 - Create Project/JT when Sub Period Stage changes
                String uniqueKeyStr = '';

                for (Subscription_Period__c sP : listSubPeriods) {
                    //Modified By - Shalu Sharma - 06/17/2021 - CR-20200924-14551 - Create Project/JT when Sub Period Stage changes
                    uniqueKeyStr = proj.Id +'-'+ sP.Program_Subscription__r.Program__c +'-'+ proj.Fiscal_Year__c;

                    //Modified By - Shalu Sharma - 06/17/2021 - CR-20200924-14551 - Create Project/JT when Sub Period Stage changes
                    if(!mapOfProjectIdWithJTs.containsKey(proj.Id) || (mapOfProjectIdWithJTs.containsKey(proj.Id) 
                    && !mapOfProjectIdWithJTs.get(proj.Id).contains(uniqueKeyStr))){

                        Job_Ticket__c jobTickt = new Job_Ticket__c();
                        //Added By - Abhinav Sharma - 09/22/2021 - CR-20210913-15430 - Added Name field on job ticket creation
                        jobTickt.Name = 'Auto-populated';
                        jobTickt.Project__c = proj.Id;
                        jobTickt.Subscription_Period__c = sP.Id;
                        jobTickt.Program__c = sP.Program_Subscription__r.Program__c;
                        jobTickt.Auto_Generated__c = true;
                        jobTickt.Mail_Quantity__c = sP.Total_Paper_only_Contract_Quantity__c;
                        
                        //10/01/2020 - CR-20200626-14231 - Victor Hanson - auto-populate job number
                        jobTickt.Job_Code__c = sP.Job_No__c;
                        
                        //04/30/2021 - CR-20210323-15016 - Neha Sharma - populate drop type
                        jobTickt.Drop_Type__c = 'Pre Planned';
                        
                        //01/25/2022 - CR-20220125-15747 - Shalu Sharma - Populate the Record Type = Job Ticket
                        jobTickt.RecordTypeId = Constants.JOB_TICKET_RT_ID;

                        listOfJobTickets.add(jobTickt);
                    }
                }
            }
        }

        return listOfJobTickets;
    }

    //Method to create the Deployment record Instance
    public Map<Id, Deployment__c> createDeploymentInstance(List<Project__c> newProjects) {


        //Map to hold the deployment. 
        Map<Id, Deployment__c> mapOfDeploymentsWithProjectIds = new Map<Id, Deployment__c>();

        if(newProjects.size() > 0){
            for(Deployment__c dep : [Select Id, Project__c From Deployment__c
                                     Where Project__c != null And Project__c IN :newProjects])
            {
                mapOfProjectIdWithDeploymentIds.put(dep.Project__c, dep.Id);
            }
            
        }

        for(Project__c proj : newProjects) {
            //Modified By - Shalu Sharma - 06/17/2021 - CR-20200924-14551 - Create Project/JT when Sub Period Stage changes
            if(!mapOfProjectIdWithDeploymentIds.containsKey(proj.Id)){
                    //Modified By - Shalu Sharma - 06/17/2021 - CR-20200924-14551 - Create Project/JT when Sub Period Stage changes
                    Deployment__c deployment = new Deployment__c();
                    deployment.Name = 'Will be Auto Populated';
                    deployment.Project__c = proj.Id;
                    deployment.RecordTypeId = Constants.RECORD_TYPE_ID_ES_DEPLOYMENT;

                    mapOfDeploymentsWithProjectIds.put(proj.Id, deployment);
            }
            
        }

        return mapOfDeploymentsWithProjectIds;
    }

    //Modified By - Shalu Sharma - 06/17/2021 - CR-20200924-14551 - Create Project/JT when Sub Period Stage changes
    //returns a unique key to identify a unique subscription period
    public String getUniqueKey(Subscription_Period__c sP) {
        return sP.Contract__c + '-' +sP.Program_Subscription__r.SBQQ__RequiredByProduct__c + '-' + sP.Period_End_Date__c.year();
    }

    //Modified By - Shalu Sharma - 06/17/2021 - CR-20200924-14551 - Create Project/JT when Sub Period Stage changes
    //returns a unique key to identify a unique Project
    public String getUniqueKey(Project__c proj) {
        return proj.Contract2__c+ '-' + proj.Product2__c + '-' + proj.Fiscal_Year__c;
    }
    
}