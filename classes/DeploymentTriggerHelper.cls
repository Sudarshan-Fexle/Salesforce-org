/**
*   Purpose         :   Helper class for Deployment object trigger.
* 
*   Created By      :   Bhavi Sharma    
* 
*   Created Date    :   05/25/2013
* 
*   Current Version :   V_1.0 - Created -   CR-20130328-2773
*                       V_1.1 - Modified - CR-20130612-3154 - Added method: updateDeploymentStatus
*                       V_1.2 - Modified - CR-20130829-3543 - Abhinav Sharma - 03-03-2014 - Added method: populateFirstDeploymentSignedOff
*                       V_1.3 - Modified - CR-20140403-4958 - Site Live - Target, Actual - not completed with 3968 - Abhinav Sharma - 04/29/2014 - Modified method: populateFirstDeploymentSignedOff
*                       V_1.4 - Modified - CR-20140408-5000 - Abhinav Sharma - 05-01-2014 - Added new method: populateDeploymentDataOnProject   
*                       V_1.5 - Modified - CR-20140716-6256 - Ajit Surana - 09/08/2014 - Exclude Project Record Type "SSC" from populateFirstDeploymentSignedOff() method    
*                       V_1.6 - Modified - CR-20140826-7138 - Abhinav Sharma - 10/17/2014 - CR-20140826-7138 - New methods getRCSProjectToUpdate 
*                                                                                                              & populateDeploymentSignOffOldestOnProject added.
*                       V_1.7 - Modified - CR-20141106-8010 - Abhinav Sharma - 11/25/2014 - Revert change to Site Live field on SSC projects
*                       V_1.8 - Modified - Abhinav Sharma - 02/03/2015 - CR-20141218-8365 - New method added - updateCalculatedDateFields
*            		V_1.9 - Modified - Abhinav Sharma - 10/20/2015 - CR-20150623-9023 - Updated existing method (updateCalculatedDateFields)
*            		V_2.0 - Modified - Mahendra Swarnkar - 07/05/2017 - CR-20170320-10767 - Updated existing method "populateDeploymentDataOnProject"
*            		V_2.1 - Modified - Subhash Garhwal -   09/12/2017 - CR-20170907-11185 - New method added  "updateSiteLiveDateOnABCRevenue"
*            		V_2.2 - Modified - Subhash Garhwal -   10/24/2017 - Issue--CR11185--QA--00007038 - Change Change_Reason_Code__c logic
*            		V_2.3 - Modified - Abhinav Sharma - CR-20180504-12211 - 08/20/2018  new method populateAPSDeploymentDataOnAPSProject
*            		V_2.4 - Modified - Rajeev Jain - Restrict the Date_Site_Live__c population on the Project if the Record type is APS 08/23/2018 - CR-20180504-12211 - populateFirstDeploymentSignedOff
*                       V_2.5 - Updated  - Abhinav Sharma - CR-20180917-12599 - 09/29/2018 
*                       V_2.6 - Modified - Abhinav Sharma - 03/19/2019 -updateSiteLiveDateOnABCRevenue Commented out population of Line_Status__c on ABC Revenue.
*                       V_2.7 - Modified - Dipesh Gupta - 07/31/2019 - 'createMilestoneOnDeploymentCreation' Updated During lightning migration.
*                       V_2.8 - Modified - Dipesh Gupta - 09/26/2019 - CR-20190529-13156 - APS replaced by Tech (SSC) as per Taylor Chatter
*                       V_2.9 - Modified - Dipesh Gupta - 11/19/2019 - CR-20190904-13311 - added new method validateDeployment
*                       V_3.0 - Modified - Victor Hanson - 01/14/2020 - CR-20200114-13620 - logic updated to fix a bug preventing deployment updates
*                       V_3.1 - Modified - Dipesh Gupta - 03/05/2020 - CR-20191223-13575 - Added  a new method - populateDeploymentFieldsFromProject
*			V_3.2 - Modified - Mahendra Swarnkar - 01/05/2021 - CR-20200615-14184 - Validation Rule for Deployments on revenue lines
*		        V_3.3 - Modified - Neha Sharma - CR-20210916-15439
**/ 
public without sharing class DeploymentTriggerHelper {
    
    //Modified By - Abhinav Sharma - 10/20/2015 - CR-20150623-9023
    //Added BY - Abhinav Sharma - 02/03/2015 - CR-20141218-8365
    /**
     *  @description    :   Method to populate Date fields on deployment with desired calculated values on CPRM Record Types.
     *
     *  @args           :   List of deployments
     *
     *  @return         :   void
     *
     **/
    public static void updateCalculatedDateFields(List<Deployment__c> newDeployments) {
        
        //Set to hold the record types developername string literals
        Set<String> setRdTypeDeveloperNames = new Set<string>();
        setRdTypeDeveloperNames.add('CPRM_Deployment');
        setRdTypeDeveloperNames.add('Data_Hub_Deployment');
        
        //Map of deployment record type
        Map<Id, RecordType> mapRdTypes = new Map<Id, RecordType>([SELECT ID, DeveloperName FROM RecordType 
                                                                  WHERE SobjectType = 'Deployment__c' AND IsActive = true 
                                                                  AND DeveloperName IN : setRdTypeDeveloperNames]);
        
        //Checking map for size and null value
        if(mapRdTypes != null && mapRdTypes.size() > 0) {
            
            //Loop through new Deployment records   
            for(Deployment__c dep : newDeployments) {
                
                //Perform calculation and populating field for "CPRM Deployment" record type
                if(mapRdTypes.containsKey(dep.RecordTypeId) 
                   && mapRdTypes.get(dep.RecordTypeId) != null
                   && mapRdTypes.get(dep.RecordTypeId).DeveloperName == 'CPRM_Deployment') {
                       
                       //Performing caluclation for the date fields
                       
                       //Commented by - abhinav sharma - 7/6/2020 -CR-20200204-13690 - Start - 
                       //Template_Sent_Expected__c
                       /*if(dep.C_A_DS__c != null)
                            dep.Template_Sent_Expected__c  = dep.C_A_DS__c + 2;
                        else
                            dep.Template_Sent_Expected__c = null;*/
                       
                       //C_E_TPC__c
                       if(dep.C_A_DS__c != null)
                           dep.C_E_TPC__c = dep.C_A_DS__c + 14;
                       else
                           dep.C_E_TPC__c = null;
                       
                       //Commented by - abhinav sharma - 7/6/2020 -CR-20200204-13690 - Start -    
                       //Redlining_Complete_Expected__c
                       /*if(dep.Template_Sent_Expected__c != null)
                            dep.Redlining_Complete_Expected__c  = dep.Template_Sent_Expected__c + 21;
                        else
                            dep.Redlining_Complete_Expected__c = null;
                        
                        
                        //Legal_Complete_Expected__c
                        if(dep.Redlining_Complete_Expected__c != null)
                            dep.Legal_Complete_Expected__c = dep.Redlining_Complete_Expected__c + 21;
                        else
                            dep.Legal_Complete_Expected__c = null;
                        
                        //C_E_IDI__c
                        if(dep.Legal_Complete_Expected__c != null)
                            dep.C_E_IDI__c = dep.Legal_Complete_Expected__c + 2;
                        else
                            dep.C_E_IDI__c = null;
                        
                        
                        //Feedback_on_Initial_Data_Expected__c 
                        if(dep.C_E_IDI__c != null)
                            dep.Feedback_on_Initial_Data_Expected__c  = dep.C_E_IDI__c + 14;
                        else
                            dep.Feedback_on_Initial_Data_Expected__c = null;  
                        
                        //C_E_CDI__c
                        if(dep.Feedback_on_Initial_Data_Expected__c != null)
                            dep.C_E_CDI__c = dep.Feedback_on_Initial_Data_Expected__c + 7;
                        else
                            dep.C_E_CDI__c = null;*/
                       
                       //C_E_DDC__c
                       if(dep.C_E_CDI__c != null)
                           dep.C_E_DDC__c = dep.C_E_CDI__c + 14;
                       else
                           dep.C_E_DDC__c = null;
                       
                       
                       //Commented by - abhinav sharma - 7/6/2020 - CR-20200204-13690 - Start -    
                       //Data_Sent_to_Vendor_Expected__c 
                       /* if(dep.C_E_DDC__c != null)
                            dep.Data_Sent_to_Vendor_Expected__c = dep.C_E_DDC__c + 7;
                        else
                            dep.Data_Sent_to_Vendor_Expected__c = null;
                        
                        
                        //DAS_Received_Expected__c  
                        if(dep.Data_Sent_to_Vendor_Expected__c  != null) 
                            dep.DAS_Received_Expected__c = dep.Data_Sent_to_Vendor_Expected__c + 15;
                        else
                            dep.DAS_Received_Expected__c = null; 
                        
                        
                        
                        if(dep.DAS_Received_Expected__c != null) 
                            dep.DAS_Approved_Expected__c  = dep.DAS_Received_Expected__c + 2;
                        else
                            dep.DAS_Approved_Expected__c = null;
                        
                        //C_E_ISBC__c 
                        if(dep.DAS_Approved_Expected__c != null) 
                            dep.C_E_ISBC__c = dep.DAS_Approved_Expected__c + 16;
                        else
                            dep.C_E_ISBC__c = null;
                                             
                        //UAT_Diagnostics_Call_Expected__c 
                        if(dep.C_E_IVC__c != null) 
                            dep.UAT_Diagnostics_Call_Expected__c = dep.C_E_IVC__c + 5;
                        else
                            dep.UAT_Diagnostics_Call_Expected__c = null;
                        
                        //UAT_Onsite_Expected__c
                        if(dep.UAT_Diagnostics_Call_Expected__c != null) 
                            dep.UAT_Onsite_Expected__c = dep.UAT_Diagnostics_Call_Expected__c + 2;
                        else
                            dep.UAT_Onsite_Expected__c = null;*/
                       //Comment End Here - By abhinav Sharma 
                       
                       
                       //C_E_IVC__c 
                       if(dep.C_E_ISBC__c != null) 
                           dep.C_E_IVC__c = dep.C_E_ISBC__c + 2;
                       else
                           dep.C_E_IVC__c = null;
                       
                       //C_E_DC__c
                       if(dep.UAT_Onsite_Expected__c != null) 
                           dep.C_E_DC__c = dep.UAT_Onsite_Expected__c + 30;
                       else
                           dep.C_E_DC__c = null;
                       
                       //Expected_Recurring_Update_Sign_Off2__c
                       if(dep.UAT_Onsite_Expected__c != null) 
                           dep.Expected_Recurring_Update_Sign_Off2__c = dep.UAT_Onsite_Expected__c + 30;
                       else
                           dep.Expected_Recurring_Update_Sign_Off2__c = null;
                   }
                
                /*
                //Perform calculation and populating field for "Data Hub Deployment" record types
                if(mapRdTypes.containsKey(dep.RecordTypeId) 
                  && mapRdTypes.get(dep.RecordTypeId) != null
                  && mapRdTypes.get(dep.RecordTypeId).DeveloperName == 'Data_Hub_Deployment') {
                   
                     //Data Acquisition Call (Expected) (Data_Acquisition_Call_Expected__c)
                     if(dep.Welcome_Call_Expected__c != null)
                      dep.Data_Acquisition_Call_Expected__c  = dep.Welcome_Call_Expected__c + 5;
                    else
                        dep.Data_Acquisition_Call_Expected__c = null;
		*/                   
		/*
                     //Feed Transport setup complete(Expected) (Feed_Transport_setup_complete_Expected__c)
                     if(dep.Data_Acquisition_Call_Expected__c != null)
                       dep.Feed_Transport_setup_complete_Expected__c  = dep.Data_Acquisition_Call_Expected__c + 5;
                    else
                        dep.Feed_Transport_setup_complete_Expected__c = null;
                        
                     //Receive Test Data (Expected) (Receive_Test_Data_Expected__c)
                     if(dep.Feed_Transport_setup_complete_Expected__c != null)
                      dep.Receive_Test_Data_Expected__c  = dep.Feed_Transport_setup_complete_Expected__c + 3;
                    else
                        dep.Receive_Test_Data_Expected__c = null;
		*/                        
		/*
                     //Extract data in ECDM (Expected) (Extract_data_in_ECDM_Expected__c)
                     if(dep.Receive_Test_Data_Expected__c != null)
                      dep.Extract_data_in_ECDM_Expected__c  = dep.Receive_Test_Data_Expected__c + 5;
                    else
                        dep.Extract_data_in_ECDM_Expected__c = null;
                   
                     //Transform data ECDM to ICDM (Exp.) (Transform_data_ECDM_to_ICDM_Exp__c)
                     if(dep.Extract_data_in_ECDM_Expected__c != null)
                      dep.Transform_data_ECDM_to_ICDM_Exp__c  = dep.Extract_data_in_ECDM_Expected__c + 3;
                    else
                        dep.Transform_data_ECDM_to_ICDM_Exp__c = null;
		*/                        
		/*
                     //ICDM sample data diagnostics (Expected) (ICDM_sample_data_diagnostics_Expected__c)
                     if(dep.Transform_data_ECDM_to_ICDM_Exp__c != null)
                      dep.ICDM_sample_data_diagnostics_Expected__c  = dep.Transform_data_ECDM_to_ICDM_Exp__c + 2;
                    else
                        dep.ICDM_sample_data_diagnostics_Expected__c = null;
		*/                   
		/*
                     //ICDM sample data diagnostic resolved Exp (ICDM_sample_data_diagnostic_resolved_Exp__c)
                     if(dep.ICDM_sample_data_diagnostics_Expected__c != null)
                      dep.ICDM_sample_data_diagnostic_resolved_Exp__c  = dep.ICDM_sample_data_diagnostics_Expected__c + 5;
                    else
                        dep.ICDM_sample_data_diagnostic_resolved_Exp__c = null;
		*/                    
		/*
                     //Historical Data Received (Expected) (Historical_Data_Received_Expected__c)
                     if(dep.ICDM_sample_data_diagnostic_resolved_Exp__c != null)
                      dep.Historical_Data_Received_Expected__c  = dep.ICDM_sample_data_diagnostic_resolved_Exp__c + 3;
                    else
                        dep.Historical_Data_Received_Expected__c = null;
                   
                     //ICDM historical data diagnostics (Exp.) (ICDM_historical_data_diagnostics_Exp__c)
                     if(dep.Historical_Data_Received_Expected__c != null)
                      dep.ICDM_historical_data_diagnostics_Exp__c  = dep.Historical_Data_Received_Expected__c + 1;
                    else
                        dep.ICDM_historical_data_diagnostics_Exp__c = null;
		*/                        
		/*
          	    //ICDM historical data diags resolved(Exp) (ICDM_historical_data_diags_resolved_Exp__c)
          	    if(dep.ICDM_historical_data_diagnostics_Exp__c != null)
                        dep.ICDM_historical_data_diags_resolved_Exp__c  = dep.ICDM_historical_data_diagnostics_Exp__c + 8;
                    else
                        dep.ICDM_historical_data_diags_resolved_Exp__c = null;
                    
                     //Enrichment service setup complete (Exp.) (Enrichment_service_setup_complete_Exp__c)
                     if(dep.ICDM_historical_data_diags_resolved_Exp__c != null)
                      dep.Enrichment_service_setup_complete_Exp__c  = dep.ICDM_historical_data_diags_resolved_Exp__c + 2;
                    else
                        dep.Enrichment_service_setup_complete_Exp__c = null;
		*/                    
		/*
                     //Enrichment service diagnostics (Exp.) (Enrichment_service_diagnostics_Exp__c)
                     if(dep.Enrichment_service_setup_complete_Exp__c != null)
                      dep.Enrichment_service_diagnostics_Exp__c  = dep.Enrichment_service_setup_complete_Exp__c + 1;
                    else
                        dep.Enrichment_service_diagnostics_Exp__c = null;
                    
                    //Enrichment service diags resolved (Exp.) (Enrichment_service_diags_resolved_Exp__c)
                    if(dep.Enrichment_service_diagnostics_Exp__c != null)
                      dep.Enrichment_service_diags_resolved_Exp__c  = dep.Enrichment_service_diagnostics_Exp__c + 5;
                    else
                        dep.Enrichment_service_diags_resolved_Exp__c = null;
		*/                        
		/*
                     //Data Handoff to Product (Expected) (Data_Handoff_to_Product_Expected__c)
                     if(dep.Enrichment_service_diags_resolved_Exp__c != null)
                      dep.Data_Handoff_to_Product_Expected__c  = dep.Enrichment_service_diags_resolved_Exp__c + 1;
                    else
                        dep.Data_Handoff_to_Product_Expected__c = null;
                        
                     //Internal Validation Complete (Expected) (C_E_IVC__c)
                     if(dep.Data_Handoff_to_Product_Expected__c != null)
                      dep.C_E_IVC__c  = dep.Data_Handoff_to_Product_Expected__c + 5;
                    else
                        dep.C_E_IVC__c = null;
		*/                        
		/*
                     //Recurring Update Sign-Off (Expected) (Recurring_Update_Sign_Off_Expected__c)
                     if(dep.C_E_IVC__c != null)
                      dep.Recurring_Update_Sign_Off_Expected__c  = dep.C_E_IVC__c + 15;
                    else
                        dep.Recurring_Update_Sign_Off_Expected__c = null;
         }         
		*/
            }   
        }
    }
    
    //This method is set to Data on Project object 
    public static void rollupDeploymentDataOnProject(List<Deployment__c> newDeployments, Map<Id, Deployment__c> mapOldDeployments){
        
        //Prepare a set of Project Ids
        Set<Id> projIds = new Set<Id>();
        
        //Loop through new Deployment record for get project Id
        for(Deployment__c deployment : newDeployments){
            
            //Project Ids set
            if(mapOldDeployments == null && deployment.Project__c != null)
                projIds.add(deployment.Project__c);
            
            //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
            if(mapOldDeployments != null 
               && mapOldDeployments.get(deployment.Id) != null 
               && (deployment.Project__c != mapOldDeployments.get(deployment.Id).Project__c
                   || deployment.C_A_DC__c != mapOldDeployments.get(deployment.Id).C_A_DC__c
                   /*|| deployment.Move_to_Production_Team_Expected__c != mapOldDeployments.get(deployment.Id).Move_to_Production_Team_Expected__c*/
                  )
              ) {
                  if(deployment.Project__c != null)   
                      projIds.add(deployment.Project__c);  
              }
        }
        
        //Map of Project object record with Key = Id and Value = Project Object
        Map<Id, Project__c> mapProjects = new Map<Id, Project__c>();
        
        //Query data of Deployment list
        // Commented By Abhinav Sharma - 08/07/2020 - CR-20200204-13690
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        List<Deployment__c> listDeployments = [SELECT Name, C_A_DC__c,/* Move_to_Production_Team_Expected__c,*/ /*CMA_Status_Formula__c,*/ Project__c 
                                               FROM Deployment__c WHERE Project__c IN : projIds ];
        
        //Loop through Deployment's Trigger.new
        for(Deployment__c deployment : listDeployments){
            
            if(!mapProjects.containsKey(deployment.Project__c)){
                
                //put in map with Key = ProjectId, value = Project record
                //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                mapProjects.put(deployment.Project__c, new Project__c(Id = deployment.Project__c/*, Move_to_Production_Team_Expected__c = null*//*, 
								      Final_Deployment_Sign_Off_Date__c = null */
                                                                      //No_of_Active_Green_Deployments__c = 0,
                                                                      //No_of_Active_Red_Deployments__c = 0, 
                                                                      //No_of_Active_Yellow_Deployments__c = 0, 
                                                                      //No_of_Historical_Green_Deployments__c = 0,
                                                                      //No_of_Historical_Red_Deployments__c = 0, 
                                                                      //No_of_Historical_Yellow_Deployments__c = 0
                                                                     ));
            }
            
            //Check map contains projectId of Deployment
            if(mapProjects.containsKey(deployment.Project__c)){
                
                //Get project instance from map
                Project__c project = mapProjects.get(deployment.Project__c);
                
                System.debug('###Name'+deployment.Name);
                
                // Commented By Abhinav Sharma - 08/07/2020 - CR-20200204-13690
                //Check specific criteria for Historical and Active Red Deployment
               /* if(deployment.CMA_Status_Formula__c == 'Red'){
                    
                    if(deployment.C_A_DC__c != null){
                        
                        //project.No_of_Historical_Red_Deployments__c +=1; 
                    }
                    //project.No_of_Active_Red_Deployments__c +=1;
                }
                //Check specific criteria for Historical and Active Green Deployment    
                if(deployment.CMA_Status_Formula__c == 'Green'){
                    
                    if(deployment.C_A_DC__c != null){
                        
                        //project.No_of_Historical_Green_Deployments__c +=1;
                    }
                    //project.No_of_Active_Green_Deployments__c +=1;
                }
                
                //Check specific criteria for Historical and Active Yellow Deployment
                if(deployment.CMA_Status_Formula__c == 'Yellow'){
                    
                    if(deployment.C_A_DC__c != null){
                        
                        //project.No_of_Historical_Yellow_Deployments__c +=1;
                    }
                    //project.No_of_Active_Yellow_Deployments__c +=1;
                }*/
                //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                //Check for maximum of Current Deployment Sign of (Actual) of Deployment
                /*if(project.Final_Deployment_Sign_Off_Date__c == null 
                    || deployment.C_A_DC__c > project.Final_Deployment_Sign_Off_Date__c)
                    project.Final_Deployment_Sign_Off_Date__c = deployment.C_A_DC__c; 
                
                //Check for maximum of Move to Prod Team Expected of Deployment
                //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                /*if(project.Move_to_Production_Team_Expected__c == null 
                    || deployment.Move_to_Production_Team_Expected__c > project.Move_to_Production_Team_Expected__c)
                    project.Move_to_Production_Team_Expected__c = deployment.Move_to_Production_Team_Expected__c;*/
                
                mapProjects.put(project.Id,project);
                System.debug('####'+mapProjects);
            }
        }
        //Query rollup data with aggregate 
        /*List<AggregateResult> aggregateResults = [SELECT Max(C_A_DC__c)deploySign, Max(Move_to_Production_Team_Expected__c) prodExp, Project__c projId 
        					    FROM Deployment__c WHERE Project__c IN : projIds Group By Project__c];
        
        //Check list of aggregate query size                                            
        if(aggregateResults.size() > 0){
            
            //Loop through aggregateResults list
            for(AggregateResult agg : aggregateResults){
                
                //Check not null criteria
                if(agg.get('deploySign') != null && agg.get('projId') != null){
                    
                    //Project Id
                    Id projectId = Id.valueOf(String.valueOf(agg.get('projId')));
                    
                    //add values in map
                    mapProjects.put(projectId, new Project__c(Id = projectId, Move_to_Production_Team_Expected__c = Date.valueOf(agg.get('prodExp')), 
                                    Final_Deployment_Sign_Off_Date__c = Date.valueOf(agg.get('deploySign'))));
                }
            }
        }*/
        
        System.debug('####'+mapProjects.size());
        //Check for map size
        if(mapProjects.size() > 0)
            util.BypassAllTriggers = true;
        update mapProjects.values();
        
    }
    
    // CR-3154
    // This method sets the deployment status field for the Deployment record when RecordType = Compass Connect Deployment
    // because this executes in the beforeUpdate portion of the trigger, we don't actually need to perform the update in the method
    public static void updateDeploymentStatus(List<Deployment__c> newDeployments){
        
        String Compass_Connect_RTID = Util.RecordTypeId('Deployment__c', Constants.RECORD_TYPE_DEPLOYMENT_COMPASS_CONNECT_DEPLOYMENT);
        for (Deployment__c newDeployment : newDeployments) {
            if (newDeployment.RecordTypeId == Compass_Connect_RTID) {
                String deploymentStatus;
                Date expected_TechnicalPlanning = newDeployment.C_E_TPC__c;
                Date expected_InitialDataIn = newDeployment.C_E_IDI__c;
                Date expected_CompleteDataIn = newDeployment.C_E_CDI__c;
                Date expected_DataDiagComplete = newDeployment.C_E_DDC__c;
                //Commented By - Abhinav sharma - 7/6/2020 - CR-20200204-13690
                // Date expected_InitSiteBuildComplete = newDeployment.C_E_IDC__c;
                Date expected_InternalValidationComplete = newDeployment.C_E_IVC__c;
                Date expected_DeploymentSignoff = newDeployment.C_E_DC__c;
                Date expected_RecurringUpdateSignOff = newDeployment.Expected_Recurring_Update_Sign_Off2__c;
                
                Date actual_TechnicalPlanning = newDeployment.C_A_TPC__c;
                Date actual_InitialDataIn = newDeployment.C_A_IDI__c;
                Date actual_CompleteDataIn = newDeployment.C_A_CDI__c;
                Date actual_DataDiagComplete = newDeployment.C_A_DDC__c;
                Date actual_InitSiteBuildComplete = newDeployment.C_A_ISBC__c;
                Date actual_InternalValidationComplete = newDeployment.C_A_IVC__c;
                Date actual_DeploymentSignoff = newDeployment.C_A_DC__c;
                Date actual_RecurringUpdateSignOff = newDeployment.Actual_Recurring_Update_Sign_Off__c;
                
                // create some date variables to hold data as it compares to the most current actual date completed
                Date actual_CurrentDate, actual_PreviousDate, expected_CurrentDate, expected_PreviousDate, 
                    expected_NextDate, expected_NextDate2;
                
                // figure out the which dates we need to compare by only taking the latest 2 expected vs actual dates
                if (actual_RecurringUpdateSignOff != null) {
                    system.debug('@@actual_RecurringUpdateSignOff:' + actual_RecurringUpdateSignOff);
                    expected_PreviousDate   = expected_DeploymentSignoff;
                    expected_CurrentDate    = expected_RecurringUpdateSignOff;
                    actual_PreviousDate = actual_DeploymentSignoff;
                    actual_CurrentDate  = actual_RecurringUpdateSignOff;
                }
                else if (actual_DeploymentSignoff != null) {
                    system.debug('@@actual_DeploymentSignoff:' + actual_DeploymentSignoff);
                    expected_PreviousDate   = expected_InternalValidationComplete;
                    expected_CurrentDate    = expected_DeploymentSignoff;
                    actual_PreviousDate = actual_InternalValidationComplete;
                    actual_CurrentDate  = actual_DeploymentSignoff;
                }
                else if (actual_InternalValidationComplete != null) {
                    system.debug('@@actual_InternalValidationComplete:' + actual_InternalValidationComplete);
                    //Commented By - Abhinav sharma - 7/6/2020 - CR-20200204-13690
                    // expected_PreviousDate   = expected_InitSiteBuildComplete;
                    expected_CurrentDate    = expected_InternalValidationComplete;
                    expected_NextDate   = actual_DeploymentSignoff;
                    expected_NextDate2  = actual_RecurringUpdateSignOff;
                    actual_PreviousDate = actual_InitSiteBuildComplete;
                    actual_CurrentDate  = actual_InternalValidationComplete;
                }
                else if (actual_InitSiteBuildComplete != null) {
                    system.debug('@@actual_InitSiteBuildComplete:' + actual_InitSiteBuildComplete);
                    expected_PreviousDate   = expected_DataDiagComplete;
                    //Commented By - Abhinav sharma - 7/6/2020 - CR-20200204-13690
                    // expected_CurrentDate    = expected_InitSiteBuildComplete;
                    expected_NextDate   = expected_InternalValidationComplete;
                    expected_NextDate2  = expected_DeploymentSignoff;
                    actual_PreviousDate = actual_DataDiagComplete;
                    actual_CurrentDate  = actual_InitSiteBuildComplete;
                }
                else if (actual_DataDiagComplete != null) {
                    system.debug('@@actual_DataDiagComplete:' + actual_DataDiagComplete);
                    expected_PreviousDate   = expected_CompleteDataIn;
                    expected_CurrentDate    = expected_DataDiagComplete;
                    //Commented By - Abhinav sharma - 7/6/2020 - CR-20200204-13690
                    // expected_NextDate   = expected_InitSiteBuildComplete;
                    expected_NextDate2 = expected_InternalValidationComplete;
                    actual_PreviousDate = actual_CompleteDataIn;
                    actual_CurrentDate  = actual_DataDiagComplete;
                }
                else if (actual_CompleteDataIn != null) {
                    system.debug('@@actual_CompleteDataIn:' + actual_CompleteDataIn);
                    expected_PreviousDate   = expected_InitialDataIn;
                    expected_CurrentDate    = expected_CompleteDataIn;
                    expected_NextDate   = expected_DataDiagComplete;
                    //Commented By - Abhinav sharma - 7/6/2020 - CR-20200204-13690
                    // expected_NextDate2 = expected_InitSiteBuildComplete;
                    actual_PreviousDate = actual_InitialDataIn;
                    actual_CurrentDate  = actual_CompleteDataIn;
                }
                else if (actual_InitialDataIn != null) {
                    system.debug('@@actual_InitialDataIn:' + actual_InitialDataIn);
                    expected_PreviousDate   = expected_TechnicalPlanning;
                    expected_CurrentDate    = expected_InitialDataIn;
                    expected_NextDate   = expected_CompleteDataIn;
                    expected_NextDate2 = expected_DataDiagComplete;
                    actual_PreviousDate = actual_TechnicalPlanning;
                    actual_CurrentDate  = actual_InitialDataIn;
                }
                else if (actual_TechnicalPlanning != null) {
                    system.debug('@@actual_TechnicalPlanning:' + actual_TechnicalPlanning);
                    expected_CurrentDate    = expected_TechnicalPlanning;
                    expected_NextDate   = expected_InitialDataIn;
                    expected_NextDate2 = expected_CompleteDataIn;
                    actual_CurrentDate  = actual_TechnicalPlanning;
                }
                else if (actual_TechnicalPlanning == null) {
                    system.debug('@@actual_TechnicalPlanning is null');
                    expected_CurrentDate    = expected_TechnicalPlanning;
                    expected_NextDate   = expected_InitialDataIn;
                    expected_NextDate2 = expected_CompleteDataIn;
                    actual_CurrentDate  = system.today();
                }
                
                if (actual_CurrentDate != null) {
                    if (actual_CurrentDate <= expected_CurrentDate) {
                        if (expected_NextDate != null && 
                            expected_NextDate2 != null &&
                            expected_NextDate < system.today() && 
                            expected_NextDate2 < system.today())
                        {// missed 2 expected dates in the future
                            deploymentStatus = 'Red';
                        }
                        else if (expected_NextDate != null &&
                                 expected_NextDate < system.today())
                        {// missed 1 expected date in the future
                            deploymentStatus = 'Yellow';
                        }
                        else {// no missed expected dates
                            deploymentStatus = 'Green';
                        }
                    }
                    if (actual_CurrentDate > expected_CurrentDate) {
                        if (actual_PreviousDate == null) {
                            if (expected_NextDate != null && 
                                expected_NextDate < system.today()) 
                            {
                                // we are two milestones behind
                                deploymentStatus = 'Red';
                            }
                            else {
                                deploymentStatus = 'Yellow';
                            }
                        }
                        else if (actual_PreviousDate != null && actual_PreviousDate > expected_PreviousDate) {
                            // previous and current milestones missed expected date
                            deploymentStatus = 'Red';
                        }
                        else {// only 1 missed expected date
                            deploymentStatus = 'Yellow';
                        }
                    }
                }
                
                //Comment By - Abhinav sharma - 7/6/2020 - CR-20200204-13690
                /*if (deploymentStatus != null) newDeployment.CPM_Deployment_Status__c = deploymentStatus;
                system.debug('@@deploymentStatus:' + deploymentStatus);*/
            }
        }
    }
    
    //Modified By Rajeev Jain - Restrict the Date_Site_Live__c population on the Project if the Record type is APS 08/23/2018 - CR-20180504-12211.
    //Modified By - Ajit Surana - 09/08/2014 - CR-20140716-6256 - Exclude Project Record Type "SSC" from this method
    //Added By - Abhinav Sharma - 03-03-2014 - CR-20130829-3543 - CMA - Elapsed Time Field - Moved to Prod Team
    //Modified By - Abhinav Sharma - 04/29/2014 - CR-20140403-4958 - Site Live - Target, Actual - not completed with 3968
    //Modified By - Abhinav Sharma - 11/25/2014 - CR-20141106-8010 - Revert change to Site Live field on SSC projects 
    /**
     *  @description    :   Method to set First_Deployment_Signed_Off__c field on the Project with the earliest value from the "Deployment Sign Off (Actual)" field on 
     *            the associated Deployment records whenever the associated Deployment record is inserted/updated.
     *
     *  @args           :   List of deployments, Map of old Deployments
     *
     *  @return         :   void
     *
     **/
    public static void populateFirstDeploymentSignedOff(List<Deployment__c> newDeployments, Map<Id, Deployment__c> mapOldDeployments) {
        
        //Set to hold Parent Project Ids
        Set<Id> setProjectsIds = new Set<Id>();
        
        //List to hold the current Context Deployment records
        List<Deployment__c> listDeployments = newDeployments != null ? newDeployments : mapOldDeployments.values();
        
        //Loop through deployment records and populating set with parent project records Id value
        for(Deployment__c deploy : listDeployments) {
            
            //Checking for parent project Id value and applying some other valid validations use cases
            if(deploy.Project__c != null && ((newDeployments != null && mapOldDeployments != null && (deploy.C_A_DC__c != mapOldDeployments.get(deploy.Id).C_A_DC__c || deploy.C_E_DC__c != mapOldDeployments.get(deploy.Id).C_E_DC__c))
                                             || (newDeployments != null && mapOldDeployments == null)
                                             || (newDeployments == null && mapOldDeployments != null)
                                            )
              ) {
                  setProjectsIds.add(deploy.Project__c);  
              }
        }
        
        //Chech set size before executing the further logic
        if(setProjectsIds.size() == 0)
            return;
        
        //List to hold the "Project" records to update
        Map<Id, Project__c> mapAllprojects = new Map<Id, Project__c>();
        
        //Map of Projects
        Map<Id, Project__c> mapProjects = new Map<Id, Project__c>();
        
        //Modified By - Ajit Surana - CR-20140716-6256 - 09/08/2014 - Added an extra filter of Record Type not equal to 'SSC'
        //Modified By - Abhinav Sharma - CR-20141106-8010 - 11/25/2014 - Removing filter of Record Type not equals to 'SSC'
        //Loop through parent project records and populating First_Deployment_Signed_Off__c field on the Project with the earliest value from the "Deployment Sign Off (Actual)" field. 
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        for(Project__c project : [SELECT Id, /*First_Deployment_Signed_Off__c,*/ Date_Site_Live__c, /*Site_Live_Target__c,*/RecordType.DeveloperName,
                                  (SELECT Id, C_A_DC__c, C_E_DC__c FROM Deployments__r WHERE C_A_DC__c != null ORDER BY C_A_DC__c ASC LIMIT 1)
                                  FROM Project__c WHERE Id IN : setProjectsIds]) 
        {
            
            //Populating map with the values
            mapAllprojects.put(project.Id, project);
            
            //Modified By - Abhinav Sharma - 04/29/2014 - CR-20140403-4958
            //Populating project.Date_Site_Live__c with Oldest deployment record's Deployment Sign Off (Actual) field value
            //Populating First_Deployment_Signed_Off__c field on the Project with oldest value from the "Deployment Sign Off (Actual)" field on the associated Deployment records
            //Populating project.Site_Live_Target__c field on the project with Deployment Sign Off (Expected) field value from the deployment having oldest deployment sign off (actual) field value
            //Only Process the record if found and
            if(project.Deployments__r.size() > 0) {
                
                //Add record in the list to be updated
                //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                //project.First_Deployment_Signed_Off__c = project.Deployments__r[0].C_A_DC__c;
                
                //Modified By Rajeev jain -  08/23/2018 - CR-20180504-12211
                //Checking for the record type, do not populate if the Record type is APS.
                //Modified By Dipesh Gupta - 09/26/2019 - CR-20190529-13156 - APS replaced by Tech (SSC) as per Taylor Chatter
                //Modified By Mahendra Swarnkar - 04/02/2020 - CR-20191204-13551
                //if(project.RecordType.DeveloperName != 'SSC')
                project.Date_Site_Live__c = project.Deployments__r[0].C_A_DC__c;
                //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                //project.Site_Live_Target__c = project.Deployments__r[0].C_E_DC__c;
                mapProjects.put(project.Id, project);
            } 
        }
        
        //Modified By - Ajit Surana - CR-20140716-6256 - 09/08/2014 - Added an extra filter of Record Type not equal to 'SSC'
        //Modified By - Abhinav Sharma - CR-20141106-8010 - 11/25/2014 - Removing filter of Record Type not equals to 'SSC'
        //Loop through parent project records and populating First_Deployment_Signed_Off__c field on the Project with the earliest value from the "Deployment Sign Off (Actual)" field. 
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        for(Project__c project : [SELECT Id, /*First_Deployment_Signed_Off__c,*/ Date_Site_Live__c, /*Site_Live_Target__c,*/ RecordType.DeveloperName, 
                                  (SELECT Id, C_A_DC__c, C_E_DC__c FROM Deployments__r WHERE C_E_DC__c != null ORDER BY C_E_DC__c ASC LIMIT 1)
                                  FROM Project__c WHERE Id IN : setProjectsIds AND ID NOT IN : mapProjects.keySet()]) 
        {
            
            //Modified By - Abhinav Sharma - 04/29/2014 - CR-20140403-4958
            //Populating project.Date_Site_Live__c with Oldest deployment record's Deployment Sign Off (Actual) field value
            //Populating First_Deployment_Signed_Off__c field on the Project with oldest value from the "Deployment Sign Off (Actual)" field on the associated Deployment records
            //Populating project.Site_Live_Target__c field on the project with Deployment Sign Off (Expected) field value from the deployment having oldest deployment sign off (actual) field value
            //Only Process the record if found and
            if(project.Deployments__r.size() > 0) {
                
                //Add record in the list to be updated
                //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                //project.First_Deployment_Signed_Off__c = project.Deployments__r[0].C_A_DC__c;
                
                //Modified By Rajeev jain -  08/23/2018 - CR-20180504-12211
                //Checking for the record type, do not populate if the Record type is APS.
                
                //Modified By Dipesh Gupta - 09/26/2019 - CR-20190529-13156 - APS replaced by Tech (SSC) as per Taylor Chatter
                if(project.RecordType.DeveloperName != 'SSC')
                    project.Date_Site_Live__c = project.Deployments__r[0].C_A_DC__c;
                
                //project.Site_Live_Target__c = project.Deployments__r[0].C_E_DC__c;
                mapProjects.put(project.Id, project);
                
            } 
        }
        
        //Checking map for size value
        if(mapAllprojects.values().size() > 0) {
            
            //Loop through map values
            for(Project__c project : mapAllprojects.values()) {
                
                //Checking for the value in the map
                if(!mapProjects.containsKey(project.Id)) {
                    //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                    // project.First_Deployment_Signed_Off__c = null;
                    
                    //Modified By Rajeev jain - 08/23/2018 - CR-20180504-12211
                    //Checking for the record type, do not populate if the Record type is APS.
                    //Modified By Dipesh Gupta - 09/26/2019 - CR-20190529-13156 - APS replaced by Tech (SSC) as per Taylor Chatter
                    // if(project.RecordType.DeveloperName != 'SSC')
                    project.Date_Site_Live__c = null;
                    
                    //project.Site_Live_Target__c = null;
                } else {
                    mapAllprojects.put(project.Id, mapProjects.get(project.Id));
                }
            }
            
            //Updating list of projects 
            update mapAllprojects.values();
        }
    }     
    
    //Method Commneted Out on the Project Object Clean up.
    //Added By - Abhinav Sharma - 10/17/2014 - CR-20140826-7138
    /**
     *  @description    :   Method is used to autopopulate the Deployment Sign-Off (Oldest) field on Project when a related Deployment record is 
     *                      created/updated/deleted and the Project's Record Type = "RCS".
     *                          1)  "Deployment Sign-Off (Oldest)" should be automatically updated to the oldest Deployment Sign Off (Actual) date.
     *
     *  @args           :   List of deployments, Map of old Deployments
     *
     *  @return         :   void
     *
     **/
    public static void populateDeploymentSignOffOldestOnProject(List<Deployment__c> newDeployments, Map<Id, Deployment__c> mapOldDeployments) {
        
        //Set to hold Project Id of Deployment record
        Set<Id> projectIds = new Set<Id>();
        
        //Map to hold key=> ProjectId & value=> instance of Project sobject
        Map<Id, Project__c> mapProjectToBeUpdated = new Map<Id, Project__c>();
        
        //Check for only in case of Insertion or Updation
        if(newDeployments != null) {
        
            //Loop through Trigger.new
            for(Deployment__c newDeployment : newDeployments) {
                
                //Check for null & adding ProjectId into set
                if(newDeployment.Project__c != null)    
                    projectIds.add(newDeployment.Project__c);
                
                //Check if Project is update on Deployment from previous
                if(mapOldDeployments != null && newDeployment.Project__c != mapOldDeployments.get(newDeployment.Id).Project__c)
                    projectIds.add(mapOldDeployments.get(newDeployment.Id).Project__c);
            }
        } else {
            
            //Loop through Trigger.new
            for(Deployment__c oldDeployment : mapOldDeployments.values()) {
                
                //Check for null & adding ProjectId into set
                if(oldDeployment.Project__c != null)    
                    projectIds.add(oldDeployment.Project__c);
            }
        }
        
        /*if(projectIds.size() > 0)
            mapProjectToBeUpdated = DeploymentTriggerHelper.getRCSProjectToUpdate(projectIds);*/
        
        //update the Projects with their "Deployment Sign-Off (Oldest)"
        if(mapProjectToBeUpdated.size() > 0) {
            
            Util.BypassAllTriggers = true;
            update mapProjectToBeUpdated.values();
        }
    }
    
    //Added By - Abhinav Sharma - 10/17/2014 - CR-20140826-7138
    /**
     *  @description    :   Method is used as generic bunch of logic to get a map of RCS projects which are need to updated 
     *                      for Deployment_Sign_Off_Oldest__c field values. 
     *
     *  @args           :   List of deployments, Map of old Deployments
     *
     *  @return         :   void
     *
     **/
    /*public static Map<Id, Project__c> getRCSProjectToUpdate(Set<Id> projectIds) {
        
        //Map to hold key=> ProjectId & value=> instance of Project sobject
        Map<Id, Project__c> mapRCSProjects = new Map<Id, Project__c>();
        
        //Loop through query result of Project who is related to "RCS" recordType 
        for(Project__c rcsProject : [SELECT Id FROM Project__c WHERE Id IN: projectIds AND RecordType.DeveloperName = 'RCS']) {
            
            //Check for ProjectId of Deployment is not process already
            //and populate the Map
            mapRCSProjects.put(rcsProject.Id, new Project__c(Id = rcsProject.Id, Deployment_Sign_Off_Oldest__c = null));
        }
        
        //Check for size of mapProjectToBeUpdated
        if(mapRCSProjects.size() > 0) {
            
            //Loop through aggregate results for finding oldest  Deployment Sign Off (Actual) date
            for(AggregateResult aResult : [SELECT MIN(C_A_DC__c) minSignOffActual, Project__c FROM Deployment__c 
                                                WHERE Project__c != null AND Project__c IN: mapRCSProjects.keyset() GROUP BY Project__c]) {
                
                //Getting and store the Aggregate result of Project Id
                Id projectId = (Id)aResult.get('Project__c'); 
                
                //Check ProjectId is already contians into map
                if(mapRCSProjects.containsKey(projectId)) {
                    
                    //Getting and store the Aggregate result of Minimum function of Deployment Sign Off (Actual)
                    //add store the date value into Project's "Deployment Sign-Off (Oldest)" 
                    mapRCSProjects.get(projectId).Deployment_Sign_Off_Oldest__c = (Date)aResult.get('minSignOffActual');
                }
            }
        }
        
        return mapRCSProjects;
    }*/     

    /**
     * 
     *   @description    :  This method used to update field "Site Live date" on all the child record (ABC Revenue) of Deployment 
     *                      as per the field value of "Deployment Sign Off (Actual)"
     *
     *   @args           :  List<Deployment__c> deployments, Map<Id,Deployment__c> mapOfDeployment
     *
     *   @return         :  void
     *
     *   @revision Log   :  V1.1 - Created - 09/12/2017 - Subhash Garhwal 
     *                      V1.2 - Modified - 02/26/2019 - Colin McGloin -  CR-20180918-12607 -  Modified to function with our new Deployment/Revenue functionality
     *                   :  V1.3 - Modified By Abhinav Sharma - 03/19/2019 - Commented out population of Line_Status__c on ABC Revenue.
     **/
    public static void updateSiteLiveDateOnABCRevenue(List<Deployment__c> newDeployments, Map<Id, Deployment__c> mapOldDeployments) {
        
        //Collections of Deployment IDs
        Map<Id, Deployment__c> mapOfDeployments = new Map<Id, Deployment__c>();
        Set<Id> setOfDeployments = new Set<Id>();
        
        //Loop through deployments
        for(Deployment__c deployment : newDeployments) {
            
            //Checking if C_A_DC__c field got changed
            if(deployment.C_A_DC__c != mapOldDeployments.get(deployment.Id).C_A_DC__c) 
                mapOfDeployments.put(deployment.Id,deployment);
            
            //Checking if Clarizen_First_Go_Live_Complete__c date field changed from a null value to a non null value in past date
            if(mapOldDeployments.get(deployment.Id).C_A_DC__c == null
               && deployment.C_A_DC__c != null
               && deployment.C_A_DC__c < System.today()
              )
                setOfDeployments.add(deployment.ID);
        }
        
        //Check for Deployment Size
        if(mapOfDeployments.Size() > 0 ) {
            
            //List to hold ABC Revenue to be updated
            List<ABC_Revenue__c> revenuesNeedtobeupdated =  new List<ABC_Revenue__c>();
            
            //List of change reason
            List<Change_Reason__c> changeReasonsToBeInserted = new List<Change_Reason__c>();
            
            //Loop through ABC Revenue records
            for(ABC_Revenue__c abcRevenue : [Select Id, Site_Live_Date__c, Deployment__c 
                                             From ABC_Revenue__c
                                             Where Deployment__c != null
                                             AND Deployment__c IN : mapOfDeployments.keySet()]
               ) {
                   
                   //Compare the value on Site_Live_Date__c with value on Clarizen_First_Go_Live_Complete__c     
                   if(abcRevenue.Site_Live_Date__c != mapOfDeployments.get(abcRevenue.Deployment__c).C_A_DC__c) {
                       
                       //Subhash Garhwal - 10/24/2017 - Issue--CR11185--QA--00007038
                       //Check for Site Live Date
                       if(abcRevenue.Site_Live_Date__c == null)
                           abcRevenue.Change_Reason_Code__c = 'Site Live Date Achieved';
                       else
                           abcRevenue.Change_Reason_Code__c = 'Site Live Date Changed';
                       
                       //Assign updated values to Site_Live_Date__c values of ABC Revenues 
                       abcRevenue.Site_Live_Date__c = mapOfDeployments.get(abcRevenue.Deployment__c).C_A_DC__c;
                       
                       //Set our ABC Revenue record back
                       //Modified By Abhinav Sharma - 03/19/2019 - commented out the code so it will not change the status(Line_Status__c).
                       //abcRevenue.Line_Status__c = 'Pending';
                       //abcRevenue.Include_In_Rev_Recx__c = false;
                       
                       //Change Reason record instance
                       Change_Reason__c changeReason = new Change_Reason__c();
                       changeReason.Site_Live_Date_Previous__c = mapOldDeployments.get(abcRevenue.Deployment__c).C_A_DC__c;
                       changeReason.Site_Live_Date_New__c = abcRevenue.Site_Live_Date__c;
                       changeReason.ABC_Revenue__c = abcRevenue.ID;
                       changeReason.Change_Reason_Code_New__c = abcRevenue.Change_Reason_Code__c;
                       changeReasonsToBeInserted.add(changeReason);
                       
                       //Populate the revenuesNeedtobeupdated list with ABC revenue
                       revenuesNeedtobeupdated.add(abcRevenue);
                   }
               }
            
            //check for the size 
            if(revenuesNeedtobeupdated.size() > 0){
                
                //bypass all the triggers
                Util.BypassAllTriggers = true;
                
                //Update the ABC Revenue records
                update revenuesNeedtobeupdated;
                
                //Enable all the triggers
                Util.BypassAllTriggers = false;
                
            }
            
            //Check for the size
            if(changeReasonsToBeInserted.size() > 0) {
                
                //bypass all the triggers
                Util.BypassAllTriggers = true;
                
                //Update the ABC Revenue records
                insert changeReasonsToBeInserted;
                
                //Enable all the triggers
                Util.BypassAllTriggers = false;
            }
        }
    }
    
    /**
     * 
     *   @description    :  This Method is used to populate the Deployment Object field to the Project Object.
     *
     *   @args           :  List<Deployment__c> newDeployments, Map<Id,Deployment__c> oldMapDeployment
     *
     *   @return         :  void
     *
     *   @revision Log   :  V1.1 - Created - CR-20180504-12211 - 08/20/2018 - Abhinav Sharma
     *                      V1.2 - Modified - CR-20180822-12518 - 08/07/2019 - Dipesh Gupta
     * 
     **/
    public static void populateAPSDeploymentDataOnAPSProject(List<Deployment__c> newDeployments, Map<Id,Deployment__c> oldMapDeployment) {
        
        //Set to hold the APS Project Ids
        set<Id> setProjectIds = new Set<Id>();
        
        //List of Project that needs to be Updated.
        List<Project__c> projectsToBeUpdated = new List<Project__c>();
        
        //String to hold the APS Deployment Ids 
        String APS_DEPLOYMENT = 'APS_Deployment'; 
        
        //Modified By Dipesh Gupta - 09/26/2019 - CR-20190529-13156 - APS replaced by Tech (SSC) as per Taylor Chatter
        String APS_PROJECT_RTYPE = 'SSC';
        
        //Loop on the new Deployments 
        for(Deployment__c dep : newDeployments) {
            
            //Check for the Old and New Values to restrict Trigger on recursive calls and unnecessary execution.
            if((oldMapDeployment == null 
                || 
                (
                    oldMapDeployment.containsKey(dep.Id) && oldMapDeployment.get(dep.Id) != null   
                    
                    &&   
                    (
                        oldMapDeployment.get(dep.Id).Project__c != dep.Project__c
                        ||
                        dep.Project__c != oldMapDeployment.get(dep.Id).Project__c 
                        ||
                        dep.Business_Analyst__c != oldMapDeployment.get(dep.Id).Business_Analyst__c 
                        ||
                        dep.C_A_CDI__c != oldMapDeployment.get(dep.Id).C_A_CDI__c 
                        ||
                        dep.Engineer_on_Implementation__c != oldMapDeployment.get(dep.Id).Engineer_on_Implementation__c 
                        ||
                        dep.UAT_Onsite__c != oldMapDeployment.get(dep.Id).UAT_Onsite__c 
                        ||
                        dep.Site_Live_Actual__c != oldMapDeployment.get(dep.Id).Site_Live_Actual__c 
                        ||
                        dep.Technical_Planning_Call_Actual__c != oldMapDeployment.get(dep.Id).Technical_Planning_Call_Actual__c 
                        ||
                        dep.Actual_Validation_Complete__c != oldMapDeployment.get(dep.Id).Actual_Validation_Complete__c 
                        ||
                        dep.Welcome_Call_Actual__c != oldMapDeployment.get(dep.Id).Welcome_Call_Actual__c 
                    )))) {
                        
                        //Filling a set of Projects
                        setProjectIds.add(dep.Project__c);
                        
                        //Check for the null of old Map
                        if(oldMapDeployment != null && oldMapDeployment.containsKey(dep.Id) && oldMapDeployment.get(dep.Id).Project__c != dep.Project__c)
                            setProjectIds.add(oldMapDeployment.get(dep.Id).Project__c);
                    }
        } 
        
        //Check for the Set size
        if(setProjectIds.size() > 0) {
            
            
            //Query on the Projects ton get the most recent child deployment Record. 
            for(Project__c prjct : [Select Id, (Select Id, Business_Analyst__c, C_A_CDI__c, Engineer_on_Implementation__c, UAT_Onsite__c, 
                                                Site_Live_Actual__c, Technical_Planning_Call_Actual__c, Actual_Validation_Complete__c, Welcome_Call_Actual__c From Deployments__r 
                                                where RecordType.DeveloperName =: APS_DEPLOYMENT Order By CreatedDate DESC LIMIT 1)
                                    FROM Project__c Where Id IN: setProjectIds AND RecordType.DeveloperName =: APS_PROJECT_RTYPE ]) 
            {
                
                //Creating a blank Instance of project
                Project__c project = new Project__c(Id = prjct.Id);
                
                //Check for the child record, if a project Doesn't contain any of the Deployment Than we should set null on the Project Field.
                if(prjct.Deployments__r != null && prjct.Deployments__r.size() > 0) {
                    
                    //Update the Appropriate values in the Project
                    //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                    //project.Recurring_Business_Analyst__c = prjct.Deployments__r[0].Business_Analyst__c;
                    project.Date_All_Data_In__c = prjct.Deployments__r[0].C_A_CDI__c;
                    //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                    //project.PT_Implementation_Engineer__c =  prjct.Deployments__r[0].Engineer_on_Implementation__c;
                    project.UAT_Onsite__c = prjct.Deployments__r[0].UAT_Onsite__c;
                    project.Date_Site_Live__c = prjct.Deployments__r[0].Site_Live_Actual__c;
                    project.Date_TKO__c = prjct.Deployments__r[0].Technical_Planning_Call_Actual__c;
                    project.Date_WC__c = prjct.Deployments__r[0].Welcome_Call_Actual__c;
                    //project.Configuration_Complete__c = prjct.Deployments__r[0].Actual_Validation_Complete__c;
                }else {
                    
                    //Update the Appropriate values in the Project
                    //project.Id = prjct.Id;
                    //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                    //project.Recurring_Business_Analyst__c = null;
                    project.Date_All_Data_In__c = null;
                    //project.PT_Implementation_Engineer__c =  null;
                    project.UAT_Onsite__c = null;
                    project.Date_Site_Live__c = null;
                    project.Date_TKO__c = null;
                    project.Date_WC__c = null;
                    //project.Configuration_Complete__c = null;
                    
                }
                
                //Adding one Instance at a time
                projectsToBeUpdated.add(project);                                       
            }
        }
        
        //Check for the Size of the list
        if( projectsToBeUpdated.size() > 0) {   
            
            //Update the Project list
            update  projectsToBeUpdated;
        }
    }
    
    /**
     * 
     *   @description    :  This mehtod is used to Create the milestone Record on the Creation of Deployment Record.
     *
     *   @args           :  List<Deployment__c> deployments
     *
     *   @return         :  void
     *
     *   @revision Log   :  V1.1  - Created by Abhinav Sharma - 09/24/2018 - CR-20180917-12599 
     * 
     **/
    public static void createMilestoneOnDeploymentCreation(List<Deployment__c> newDeployments) {
        
        //Set to hold the Ids of deployments
        set<Id> setDeploymentIds = new set<Id>();
        
        //Map to hold the Parent and Child Field API Name as per Mapping. 
        Map<String, String> mapDeploymentMilestoneSyncFieldNames = new Map<String, String>();
        
        //Map which holds the Deployment Ids with the All Fields API and Field value
        Map<Id, Map<String, Object>> mapDeploymentRecordValue = new Map<Id, Map<String, Object>>();
        
        //Map to hold the Relationship Field
        Map<Id, Object> mapRelationShipField = new Map<Id, Object>();
        
        
        //Check for the new Deployment 
        if(newDeployments != null && newDeployments.size() > 0) {
            
            //Loop to get the Id of Deployment records. 
            for(Deployment__c dep : newDeployments)
                setDeploymentIds.add(dep.Id);    
            
            
            String query = '';
            
            //Cheking for the Mapping of Fields for this Object. 
            for(Shadow_PSA_Project_Mapping__mdt shadowDeploymentMapping : [Select Id, Parent_Object_Name__c, Parent_Field_Name__c, 
                                                                           Child_Field_Name__c, Child_Object_Name__c 
                                                                           From Shadow_PSA_Project_Mapping__mdt Where
                                                                           IsActive__c = true AND Is_Insert_Mapping__c = true 
                                                                           AND Is_Shadow_Deployment__c = true
                                                                           AND Parent_Object_Name__c = 'Deployment__c' AND Child_Object_Name__c = 'pse__Milestone__c']) {
                                                                               
                                                                               
                                                                               //Map to hold the Deployment and Milstone.
                                                                               mapDeploymentMilestoneSyncFieldNames.put(shadowDeploymentMapping.Parent_Field_Name__c, shadowDeploymentMapping.Child_Field_Name__c);
                                                                               
                                                                               //Adding the Fields in the Query                                                        
                                                                               query += shadowDeploymentMapping.Parent_Field_Name__c + ', ';
                                                                               
                                                                           }
            
            //Cheking if the query is containg the Ids.
            if(!query.contains('Id,')) {
                //Adding Id to the Query. 
                query = 'Id, '+ query;
            }  
            
            
            //Modified By Neha Sharma - CR-20210916-15439 - Added the C_E_DC__c check in the query
            //Added By Dipesh Gupta - CR-20190723-13225 - We are bypassing the milestone creation for the deplotments where site live expected date is not filled, for the valid record types this field is reequired. So the functionality will not break for the valid ones. 
            //Forming Query
            query = 'Select ' + query.removeEnd(', ') + ' From Deployment__c Where Project__r.PSA_Project__c != null AND Id IN: setDeploymentIds AND C_E_DC__c != null';
            
            System.debug('query============================='+query);
            //List to hold the deployments that need to be Cloned.       
            List<Deployment__c> deploymentToBeClonedAsMilestone = Database.query(query);
            
            System.debug('deploymentToBeClonedAsMilestone========='+deploymentToBeClonedAsMilestone);
            
            if(deploymentToBeClonedAsMilestone != null && deploymentToBeClonedAsMilestone.size() > 0) {
                
                //List to hold the Sobject that needs to be updated. 
                List<SObject> listOfMilestoneToBeInserted = new List<SObject>();
                
                //Loop through the New List of Deployment. 
                for(Deployment__c eligibleDep : deploymentToBeClonedAsMilestone) {
                    
                    //Adding values in the Map.
                    mapDeploymentRecordValue.put(eligibleDep.Id, eligibleDep.getPopulatedFieldsAsMap()); 
                    mapRelationShipField.put(eligibleDep.Id, eligibleDep.Project__r.get('PSA_Project__c'));
                }
                
                
                System.debug('mapDeploymentRecordValue==============='+mapDeploymentRecordValue);
                
                //Loop on the Map to iterate over. 
                for(Id deploymentId : mapDeploymentRecordValue.keySet()) {
                    
                    System.debug('deploymentId==='+deploymentId);
                    //Creating a instance of Pse project.
                    sObject sObj = Schema.getGlobalDescribe().get('pse__Milestone__c').newSObject();
                    
                    //Loop on the map which contains API Name of Field with the values 
                    for(String parentAPIName : mapDeploymentMilestoneSyncFieldNames.keySet()){ 
                        
                        //getting the Value of this Field. 
                        if(mapDeploymentRecordValue.get(deploymentId).ContainsKey(parentAPIName)) {
                            
                            System.debug('1======================== +'+mapDeploymentMilestoneSyncFieldNames.get(parentAPIName));
                            System.debug('2======================== +'+mapDeploymentRecordValue.get(deploymentId).get(parentAPIName));
                            //Filling the sobject.
                            sObj.put(mapDeploymentMilestoneSyncFieldNames.get(parentAPIName), mapDeploymentRecordValue.get(deploymentId).get(parentAPIName));                        
                        }else{
                            System.debug('');                        
                            //Checking for the Project__r.PSA_Project__c
                            if(parentAPIName == 'Project__r.PSA_Project__c') {
                                sObj.put('pse__Project__c',mapRelationShipField.get(deploymentId));
                            }
                        }
                    }   
                    
                    System.debug('sObj==='+sObj);
                    
                    //Default set few Other values - 
                    sObj.put('pse__Milestone_Amount__c', 0);
                    sObj.put('CurrencyISOCode', 'USD');
                    //sObj.put('pse__Admin_Global_Edit__c', true);
                    //sObj.put('pse__Audit_Notes__c', 'POC');
                    
                    //Settin the SObject in the Final insertion list.
                    listOfMilestoneToBeInserted.add(sObj);
                }
                System.debug('listOfMilestoneToBeInserte==========================='+listOfMilestoneToBeInserted);
                
                //Check the Size Of list
                if(listOfMilestoneToBeInserted != null && listOfMilestoneToBeInserted.size() > 0 )
                    insert listOfMilestoneToBeInserted;
                
            }
        }
    }
    
    /**
     * 
     *   @description    :  This mehtod is used to keep the deployment and Milestone in sync
     *
     *   @args           :  List<Deployment__c> deployments, Map<Id, Deployment__c>()
     *
     *   @return         :  void
     *
     *   @revision Log   :  V1.1  - Created by Abhinav Sharma - 10/04/2018 - CR-20180917-12599 
     * 
     **/
    public static void syncDeploymentWithMilestone(List<Deployment__c> newdeployments, Map<Id, Deployment__c> oldMapDeployment) {
        
        
        //Map to hold the Source and Target mapping foer the Fields.
        Map<String, String> mapSourceAndTargetMapping = new Map<String, String>();
        
        //Map to hold the deployment id with the related List of Milestone ids 
        Map<Id, List<Id>> mapDeploymentWithMilestoneIds = new Map<Id, List<Id>>();
        
        //Set to hold the deployment Ids
        set<Id> setDeploymentIds = new set<Id>();
        
        //map to hold the New Project records With ID and Map<String(FieldAPI), Object(API)>
        Map<Id, Map<String, Object>> mapParentObjectIdWithFieldValues = new Map<Id, Map<String, Object>>();
        
        //Checking for the size of New List
        if(newdeployments != null && newdeployments.size() > 0) {
            
            //loop through the Deployment List
            for(Deployment__c dep : newdeployments) {
                
                //Checking for the deployment.project != null
                if(dep.Project__c != null)
                    setDeploymentIds.add(dep.Id);
            }
            
            //Check for the size of set
            if(setDeploymentIds != null && setDeploymentIds.size() > 0) {
                
                //Query on the Shadow Project Custom meta data to get the mapping in the update case. 
                //Getting the Data From the Custom MetaData which is only applicable for the Deployment and milestone sync records. 
                for(Shadow_PSA_Project_Mapping__mdt shadowDeploymentMapping : [Select Id, Parent_Object_Name__c, Parent_Field_Name__c, 
                                                                               Child_Field_Name__c, Child_Object_Name__c 
                                                                               From Shadow_PSA_Project_Mapping__mdt Where
                                                                               IsActive__c = true AND Is_Update_Mapping__c = true 
                                                                               AND Is_Shadow_Deployment__c = true
                                                                               AND Parent_Object_Name__c = 'Deployment__c' AND Child_Object_Name__c = 'pse__Milestone__c']) {
                                                                                   
                                                                                   //Map to hold the Source and Target Fields
                                                                                   mapSourceAndTargetMapping.put(shadowDeploymentMapping.Parent_Field_Name__c.trim(), shadowDeploymentMapping.Child_Field_Name__c.trim());
                                                                               }
                
                //Checking for the map size
                if(mapSourceAndTargetMapping != null && mapSourceAndTargetMapping.size() > 0) {
                    
                    //Query on the deployment only those deployment need to be in sync where Project.PSA Project Is not Null
                    for(Deployment__c deployment : [Select Id, Name, C_E_DC__c, Project__r.PSA_Project__c, (Select Id From PSA_Deployments__r)
                                                    From Deployment__c where Id IN: setDeploymentIds AND Project__r.PSA_Project__c != null]) {
                                                        
                                                        
                                                        //Checking the Milestone list size
                                                        if(deployment.PSA_Deployments__r != null && deployment.PSA_Deployments__r.size() > 0) {
                                                            
                                                            //loop on the milestone list
                                                            for(pse__Milestone__c pseMilestone : deployment.PSA_Deployments__r) {
                                                                
                                                                if(!mapDeploymentWithMilestoneIds.containsKey(deployment.Id))
                                                                    //Checking for the deployment which has the Milestone record Previously. 
                                                                    mapDeploymentWithMilestoneIds.put(deployment.Id, new List<Id>());
                                                                
                                                                //Adding the Deployment with the List of Milestone Ids  
                                                                mapDeploymentWithMilestoneIds.get(deployment.Id).add(pseMilestone.Id);  
                                                            }
                                                        }
                                                    }
                    
                    //Checking for the map size
                    if(mapDeploymentWithMilestoneIds != null && mapDeploymentWithMilestoneIds.size() > 0) {
                        
                        //Loop on the new Deployment Records 
                        for(Deployment__c newDep : newdeployments) {
                            
                            //Check for the update Case, if Old map is null or doesn't contain the Id then continue;
                            if(oldMapDeployment == null || (oldMapDeployment != null && !oldMapDeployment.containsKey(newDep.Id)))
                                continue;
                            
                            //Creating a map with the new and Old map
                            //Map to hold the Values of Field API Name and value
                            Map<String, Object> mapForNewValues = newDep.getPopulatedFieldsAsMap();
                            Map<String, Object> mapForOldValues = oldMapDeployment.get(newDep.Id).getPopulatedFieldsAsMap();
                            
                            for(String parentObjectFieldAPIName : mapSourceAndTargetMapping.keyset()) {
                                
                                //Check for the field value change [Only those fields which needs to keep in sync between Project and PSA Project]
                                if(mapForNewValues != null && mapForOldValues != null && mapSourceAndTargetMapping != null 
                                   && mapForNewValues.get(parentObjectFieldAPIName) != mapForOldValues.get(parentObjectFieldAPIName) 
                                   && mapDeploymentWithMilestoneIds.containsKey(newDep.Id)) {
                                       
                                       System.debug(mapForOldValues.get('Site_Live_Expected__c'));
                                       System.debug(mapForNewValues.get('Site_Live_Expected__c'));
                                       
                                       System.debug('New --- mapForNewValues = parentObjectFieldAPIName = '+parentObjectFieldAPIName + '== ' +mapForNewValues.get(parentObjectFieldAPIName) + 'OLD VALUES =-'+mapForOldValues.get(parentObjectFieldAPIName));
                                       //Map to hold the New Values.
                                       mapParentObjectIdWithFieldValues.put(newDep.Id, mapForNewValues);
                                   }
                            }
                        }
                        
                        System.debug('mapParentObjectIdWithFieldValues===='+mapParentObjectIdWithFieldValues);
                        
                        //List to hold the Sobject that needs to be updated. 
                        List<SObject> listOfMilestoneToBeUpdated = new List<SObject>();
                        
                        //Checking the Size of the set
                        if(mapParentObjectIdWithFieldValues.size() > 0) {
                            
                            for(Id depId : mapParentObjectIdWithFieldValues.keyset()) {
                                
                                for(Id milestoneId: mapDeploymentWithMilestoneIds.get(depId)) {
                                    
                                    //Creating a instance of Pse project.
                                    sObject sObj = Schema.getGlobalDescribe().get('pse__milestone__c').newSObject(String.valueOf(milestoneId));
                                    
                                    //Checking for the null values
                                    if(mapParentObjectIdWithFieldValues.get(depId) != null) {
                                        
                                        //Loop on the Map
                                        for(String parentObj : mapSourceAndTargetMapping.keyset()) {
                                            
                                            //Checking for the Update Condition. We can not update Project on Milestone
                                            if(parentObj == 'Project__r.PSA_Project__c')
                                                continue;
                                            
                                            //Adding Field values to the list. 
                                            sObj.put(mapSourceAndTargetMapping.get(parentObj).trim(), mapParentObjectIdWithFieldValues.get(depId).get(parentObj));
                                        }
                                    }
                                    
                                    //Cheking the Size of Sobject
                                    if(sObj != null && sObj.get('Id') != null)
                                        listOfMilestoneToBeUpdated.add(sObj);   
                                }
                            }
                            
                            //Checking for the size of list
                            if(listOfMilestoneToBeUpdated != null && listOfMilestoneToBeUpdated.size() > 0)
                                update listOfMilestoneToBeUpdated;  
                        }
                    }
                }   
            }
        }
    }
    
    /**
     * 
     *   @description    :  This method is used to validate from  not cancel or delete a Deployment that is linked to a Revenue record.
     *
     *   @args           :  List<Deployment__c> deployments, Map<Id, Deployment__c>()
     *
     *   @return         :  void
     *
     *   @revision Log   :  V1.1 - Created by Dipesh Gupta - 11/19/2019 - CR-20190904-13311 
     *                      V1.2 - Modified by Victor Hanson - 01/14/2020 - CR-20200114-13620
     * 
     **/
    public static void validateDeployment(List<Deployment__c> newDeployments, Map<Id, Deployment__c> oldMapDeployment) {
        
        //Set to hold the deployment Ids
        set<Id> setDeploymentIds = new set<Id>();
        
        
        //loop through the Deployment List
        for(Deployment__c dep : newDeployments != null ? newDeployments : oldMapDeployment.values()) {
            
            //Adding ids into set
            setDeploymentIds.add(dep.Id);
        }
        
        //Size check 
        if(setDeploymentIds != null && setDeploymentIds.size() > 0){
            
            //Map is used for holding DeploymentId With Revenue.
            Map<Id, List<ABC_Revenue__c	>> mapOfDeploymentIdWithRevenue = new   Map<Id, List<ABC_Revenue__c>> ();
            
            //loop over Revenue
            for(ABC_Revenue__c rev : [SELECT Id, Deployment__c FROM ABC_Revenue__c	WHERE Deployment__c IN: setDeploymentIds]){
                
                //Contains Check
                if(!mapOfDeploymentIdWithRevenue.containsKey(rev.Deployment__c) )
                    mapOfDeploymentIdWithRevenue.put(rev.Deployment__c, new List<ABC_Revenue__c>());
                
                mapOfDeploymentIdWithRevenue.get(rev.Deployment__c).add(rev); 
            }
            
            //Size check 
            if(mapOfDeploymentIdWithRevenue.size() > 0 && mapOfDeploymentIdWithRevenue != null){
                
                //loop through the Deployment List
                for(Deployment__c dep : newDeployments != null ? newDeployments : oldMapDeployment.values()) {
                    
                    //Size check 
                    if(mapOfDeploymentIdWithRevenue.get(dep.Id).size() > 0 && dep.Deployment_Phase__c == 'X - Cancelled/Duplicate' ){
                        
                        //adding error
                        dep.addError('You may not cancel or delete a Deployment that is linked to a Revenue record');
                    }
                }
            }
        }
    }
    
    // CR-20191223-13575 - Added a new method - populateDeploymentFieldsFromProject Start Here
    //Method to populate Learning_Management_System__c,  Current_SIS__c, CRM__c field on the Deployment from Project.CR-20191223-13575
    public static void populateDeploymentFieldsFromProject(List<Deployment__c> newDeployments, Map<Id, Deployment__c> oldMapDeployments){
        
        //Set to hold the Projects. 
        Map<Id, Project__c> mapOfProjects = new Map<Id, Project__c>();
        
        //Record Type Id with Name.
        String EDH_RECORDTYPE_ID = Schema.SObjectType.Deployment__c.getRecordTypeInfosByName().get('EDH').getRecordTypeId();
        
        for(Deployment__c dep : newDeployments) {
            
            if(oldMapDeployments == null || (
                oldMapDeployments != null &&  (oldMapDeployments.get(dep.Id).Project__c != dep.Project__c  
                                               || oldMapDeployments.get(dep.Id).RecordTypeId != dep.RecordTypeId))
              ) {
                  
                  if(String.isNotBlank(dep.Project__c) && dep.RecordTypeId == EDH_RECORDTYPE_ID)
                      mapOfProjects.put(dep.Project__c, new Project__c());   
                  else{
                      dep.Learning_Management_System__c = '';
                      dep.Current_SIS__c = '';
                      dep.CRM__c = '';
                  }
              }
        }
        
        if(mapOfProjects.size() > 0) {
            
            for(Project__c proj : [Select Id, Learning_Management_System__c, Current_SIS__c, Enrollment_CRM__c  From Project__c Where Id IN: mapOfProjects.keySet() ]) {
                
                mapOfProjects.put(proj.Id, proj);
            }
            
            if(mapOfProjects.size() > 0) {
                
                //Loop on the Deployment. 
                for(Deployment__c dep : newDeployments){
                    
                    if(mapOfProjects.containsKey(dep.Project__c) && mapOfProjects.get(dep.Project__c) != null) {
                        
                        dep.Learning_Management_System__c = mapOfProjects.get(dep.Project__c).Learning_Management_System__c;
                        dep.Current_SIS__c = mapOfProjects.get(dep.Project__c).Current_SIS__c;
                        dep.CRM__c = mapOfProjects.get(dep.Project__c).Enrollment_CRM__c;	    
                    }
                }
            }
        }
    }
    // CR-20191223-13575 - Added a new method - populateDeploymentFieldsFromProject Ends Here
    
    
    /**
    *   Description     :   This method is used to populate "Site_Live_Date__c with empty value on revenue if deployment associated with same revenue is deleting.
    *
    *   @args           :   Map<Id, Deployment__c>
    *
    *   @return type    :   Void
    *
    *   @Revision Log   :   V1.0 - Created - Mahendra Swarnakar - 01/05/2021 - CR-20200615-14184 - Validation Rule for Deployments on revenue lines
    * 
    **/
    public static void populateSiteLiveDateOnRevenue(Map<Id, Deployment__c> oldMapDeployments) {
        
        //get All Revenue record on which Site Live Date is populated
        if(oldMapDeployments != null && oldMapDeployments.keySet().size() > 0){
        	
            List<ABC_Revenue__c> revenuesToUpdate = new List<ABC_Revenue__c>();
            for(ABC_Revenue__c revenue : [SELECT Id, Site_Live_Date__c FROM ABC_Revenue__c 
                                          WHERE Deployment__c != null AND Site_Live_Date__c != null 
                                          AND Deployment__c IN: oldMapDeployments.keySet()]
			){
            	revenuesToUpdate.add(new ABC_Revenue__c(Id = revenue.Id, Site_Live_Date__c = null));
            }
            
            //update revenues
            if(revenuesToUpdate.size() > 0) {
                Util.BypassAllTriggers = true;
                UPDATE revenuesToUpdate;
                Util.BypassAllTriggers = false;
            }
        }
    }
}