/*
 *  Purpose         :   Helper class for "RoyallProgram" trigger
 *
 *  Create By       :   Mahendra Swarnkar 
 *
 *  Created Date    :   01/04/2017
 *
 *  Revision Log    :   V_1.0 Created - CR-20161128-10501 - Added a new Method "populateRollUpSummaryFields"
 *                  :   V_1.1 Modified By - Mahendra Swarnkar - CR-20170424-10876 - 07/06/2017 - modified the existing Method "populateRollUpSummaryFields" 
 *                                                                                           to populate the "Contracted_Programs_FAO__c" & "Contracted_Value_FAO__c" (Roll Up)fields values on Program package Object. 
 *                  :   V_1.2 Modified By - Dipesh Gupta - Added a new method updateCampaignCodeOnRoyall - CR-20200522-14088
 *                  :   V_1.3 Modified By - Mahendra Swarnkar - 05/07/2020 - CR-20200218-13769 - Comment part
 *                  :   V_1.4 Modified By - Abhinav Sharma - 11/03/2020 - CR-20201026-14638 - Add Cappex fields
 *                  :   V_1.5 Modified By - Mahendra Swarnkar - 01/04/2021 - CR-20201204-14725 - Update logic behind CX Current Contract Value
 *		    :   V_1.6 Modified By - Colin McGloin - 09/14/2021 - CR-20210824-15375
 *
 **/
public class RoyallProgramTriggerHelper {

    //Constant Variables
    public static final String ROYALL_PROGRAM_HD_RECORD_TYPE_LABEL = 'Hardwick Day';
    public static final String PROGRAM_PACKAGE_HD_RECORD_TYPE_LABEL = 'Hardwick Day';
    
    public static final String PROGRAM_PACKAGE_OBJECT_API_NAME = 'Program_Package__c';
    public static final String ROYALL_PROGRAM_OBJECT_API_NAME = 'Royall_Program__c';
    public static final String PROGRAM_PACKAGE_HD_RECORD_TYPE_DEVELOPER_NAME = 'Hardwick_Day';
    public static final String ROYALL_PROGRAM_HD_RECORD_TYPE_DEVELOPER_NAME = 'Hardwick_Day';
    public static final String ROYALL_PROGRAM_STATUS_CONTRACTED = 'Contracted';
    public static final String ROYALL_PROGRAM_TYPE_DISCOUNT_ALLOCATION = 'Discount Allocation';
    public static final String ROYALL_PROGRAM_TYPE_ACCOUNTING_ADJUSTMENT = 'Accounting adjustment';
    public static final String ROYALL_PROGRAM_TYPE_LINE_OF_BUSINESS_TRANSFER = 'Line of Business transfer';
    
    //V_1.1 Added By - Mahendra Swarnkar - CR-20170424-10876 - 07/06/2017 - Starts from here
    public static final String ROYALL_PROGRAM_CAMPAIGN_NEW_OPTIMIZATION_FRESHMAN_HD = 'Optimization - Freshman (HD)';
    public static final String ROYALL_PROGRAM_CAMPAIGN_NEW_OPTIMIZATION_GRADUATE_PROFESSIONAL_HD = 'Optimization - Graduate/Professional (HD)';
    public static final String ROYALL_PROGRAM_CAMPAIGN_NEW_OPTIMIZATION_TRANSFER_HD = 'Optimization - Transfer (HD)';
    public static final String ROYALL_PROGRAM_TYPE_RE_ENGAGEMENT = 'Re-engagement';
    public static final String ROYALL_PROGRAM_TYPE_UP_SELL = 'Up-sell';
    public static final String ROYALL_PROGRAM_TYPE_CROSS_SELL = 'Cross-sell';
    public static final String ROYALL_PROGRAM_TYPE_FINAL_INVOICE_ADJUSTMENT = 'Final invoice adjustment';

    //V_1.1 Added By - Mahendra Swarnkar - CR-20170424-10876 - 07/06/2017 - Ends here
    
    //V_1.1 Modify By - Mahendra Swarnkar - CR-20170424-10876 - 07/06/2017
    //Added By - Mahendra Swarnkar - 01/03/2017 - CR-20161128-10501
    /**
     *  @description    :   Method to populate the RollUp Summary fields.
     *
     *  @args           :   List of Program Package records
     *
     *  @return         :   void
     *
    **/
    public static void populateRollUpSummaryFields(List<Royall_Program__c> newRoyallProgram , map<Id, Royall_Program__c> mapOldRoyallProgram) {
        
        //Set to hold the Program package record Ids.
        Set<Id> setProgramPackageIds = new Set<Id>();
        
        //Variable to hold the HD Record Type Id for Royall Program package
        Id royallProgPackHD_rtypeId;
        
        //Query the "HD" record type Id for Program package
        List<RecordType> rtypePP =[SELECT Id FROM RecordType WHERE sObjectType =: PROGRAM_PACKAGE_OBJECT_API_NAME AND RecordType.DeveloperName =: PROGRAM_PACKAGE_HD_RECORD_TYPE_DEVELOPER_NAME AND IsActive = true LIMIT 1];
        
        //Check for size and populate "royallProgPackHD_rtypeId" with the Hd record type Id 
        if(rtypePP != null && rtypePP.size() > 0 && rtypePP[0].Id != null)
            royallProgPackHD_rtypeId = rtypePP[0].Id;
        
        //Variable to hold the HD Record Type Id for Royall Program
        Id royallProgHD_rtypeId;
        
        //Query the "HD" record type Id for Royall Program
        List<RecordType> rtypeRP =[SELECT Id FROM RecordType WHERE sObjectType =: ROYALL_PROGRAM_OBJECT_API_NAME AND RecordType.DeveloperName =: ROYALL_PROGRAM_HD_RECORD_TYPE_DEVELOPER_NAME AND IsActive = true LIMIT 1];
        
        //Check for size and populate "royallProgHD_rtypeId" with the Hd record type Id
        if(rtypeRP != null && rtypeRP.size() > 0 && rtypeRP[0].Id != null)
            royallProgHD_rtypeId = rtypeRP[0].Id;
        
        //Checking for the null value
        if(newRoyallProgram != null && royallProgHD_rtypeId != null){
            
            //Loop through Royall Program records 
            for(Royall_Program__c rprog : newRoyallProgram) {
                
                //Check for the HD record type
                if(mapOldRoyallProgram == null 
                    && rprog.RecordTypeId == royallProgHD_rtypeId 
                    && rprog.Program_Package__c != null)
                    setProgramPackageIds.add(rprog.Program_Package__c);    
                
                //Update Use case
                if(mapOldRoyallProgram != null
                    && rprog.Program_Package__c != null
                    && mapOldRoyallProgram.get(rprog.Id).Program_Package__c != null
                    && 
                    (
                        rprog.Program_Package__c != mapOldRoyallProgram.get(rprog.Id).Program_Package__c
                        || 
                        rprog.Billable_Travel__c != mapOldRoyallProgram.get(rprog.Id).Billable_Travel__c
                        ||
                        rprog.Status__c != mapOldRoyallProgram.get(rprog.Id).Status__c
                        ||
                        rprog.Type__c != mapOldRoyallProgram.get(rprog.Id).Type__c
                        ||
                        rprog.RecordTypeId != mapOldRoyallProgram.get(rprog.Id).RecordTypeId
                        || 
                        rprog.Campaign_New__c != mapOldRoyallProgram.get(rprog.Id).Campaign_New__c
                        ||
                        rprog.Program_Cost__c != mapOldRoyallProgram.get(rprog.Id).Program_Cost__c
                    )
                ) {
                    
                    //Populating collection with the current instance
                    if(rprog.RecordTypeId == royallProgHD_rtypeId)
                        setProgramPackageIds.add(rprog.Program_Package__c);
                    
                    //Check for the HD record type and populating collection with current instance
                    if(mapOldRoyallProgram.get(rprog.Id).RecordTypeId == royallProgHD_rtypeId)
                        setProgramPackageIds.add(mapOldRoyallProgram.get(rprog.Id).Program_Package__c);
                }
            }   
        }
        
        //Delete Use case
        if(newRoyallProgram == null 
            && mapOldRoyallProgram != null 
            && royallProgHD_rtypeId != null) {
            
            //Loop through royall program records    
            for(Royall_Program__c rpro : mapOldRoyallProgram.values()) {
                
                //Check for the HD record type
                if(rpro.RecordTypeId == royallProgHD_rtypeId
                    && rpro.Program_Package__c != null)
                    setProgramPackageIds.add(rpro.Program_Package__c);  
            }
        }
        
        //Map to hold the Program Package records which will be updated
        Map<Id, Program_Package__c> mapOfProgramPackageToBeUpdated = new Map<Id, Program_Package__c>();
        
        //Check for size
        if(setProgramPackageIds.size() > 0 && royallProgHD_rtypeId != null && royallProgPackHD_rtypeId != null) {
            //Commneted by Mahendra Swarnkar - 05/07/2020 - CR-20200218-13769
            //Inline query through Program Package records and their related child program (Royal/HD) records
            for(Program_Package__c pp : [SELECT Id, Total_Contracted_Travel_Cost_HD__c, /*Total_Adjusted_Travel_Cost_HD__c,*/
                                            Contracted_Programs_FAO__c, Contracted_Value_FAO__c,
                                            (SELECT Id, Billable_Travel__c, Status__c, Type__c, Campaign_New__c, Program_Cost__c
                                                FROM Programs__r 
                                                WHERE recordTypeId != null
                                                AND recordTypeId =: royallProgHD_rtypeId
                                            ) 
                                         FROM Program_Package__c 
                                         WHERE Id IN : setProgramPackageIds 
                                            AND recordTypeId != null 
                                         AND recordTypeId =: royallProgPackHD_rtypeId
                                        ]
            ) {
                
                //Check for size of the list of related Royall_Program records 
                if(pp.Programs__r != null && pp.Programs__r.size() > 0) {
                    
                    //Local variables to hold the total sum of "Billable Travell" field on all related Royall_Programs records
                    // for "TotalContractedTravelCostHD" and "TotalAdjustedTravelCostHD"
                    Decimal sumTotalContractedTravelCostHD = 0;
                    Decimal sumTotalAdjustedTravelCostHD = 0;
                    
                    //V_1.1 Modify By - Mahendra Swarnkar - CR-20170424-10876 - 07/06/2017 - Starts from here
                    Integer countContractedProgramsFAO = 0;
                    Decimal sumContractedValueFAO = 0;
                    //V_1.1 Modify By - Mahendra Swarnkar - CR-20170424-10876 - 07/06/2017 - Ends here
                    
                    //Loop over the  related Program records 
                    for(Royall_Program__c rprogram : pp.Programs__r) {
                        
                        //Check if Royall program's status = Contracted  
                        if(String.isNotBlank(rprogram.Status__c) 
                            && rprogram.Status__c == ROYALL_PROGRAM_STATUS_CONTRACTED
                        ) {
                        
                            //Check if Royall program's status = Contracted then add the Billable Travell value to sumTotalContractedTravelCostHD
                            if(rprogram.Billable_Travel__c != null)
                                sumTotalContractedTravelCostHD = sumTotalContractedTravelCostHD + rprogram.Billable_Travel__c;
                        
                            //Check if Royall program's status = Contracted and 
                            //type = "'Discount Allocation' || 'Accounting adjustment'|| 'Line of Business transfer'" 
                            //then add the Billable Travell value to sumTotalAdjustedTravelCostHD 
                            if(String.isNotBlank(rprogram.Type__c)
                                &&
                                (
                                    rprogram.Type__c == ROYALL_PROGRAM_TYPE_DISCOUNT_ALLOCATION 
                                    || 
                                    rprogram.Type__c == ROYALL_PROGRAM_TYPE_ACCOUNTING_ADJUSTMENT 
                                    || 
                                    rprogram.Type__c == ROYALL_PROGRAM_TYPE_LINE_OF_BUSINESS_TRANSFER
                                )
                            ) {
                                
                                //Check for Billable Travell value
                                if(rprogram.Billable_Travel__c != null)
                                    sumTotalAdjustedTravelCostHD = sumTotalAdjustedTravelCostHD + rprogram.Billable_Travel__c;
                            }
                        
                            //V_1.1 Modify By - Mahendra Swarnkar - CR-20170424-10876 - 07/06/2017 - Starts from here
                            //Check if Status = Contracted 
                            //Campaign_New__c = (‘Optimization - Freshman (HD)’,’Optimization - Graduate/Professional (HD)’,’Optimization - Transfer (HD)’)
                            //Type__c = (‘Re-engagement’,’Up-Sell’,’Cross-Sell’,’Line of Business Transfer’,’Final Invoice Adjustment’)
                            // then increment the counter countContractedProgramsFAO and add the Program_Cost__c value to sumContractedValueFAO 
                            if(String.isNotBlank(rprogram.Type__c)
                                && String.isNotBlank(rprogram.Campaign_New__c)
                                && 
                                (
                                    rprogram.Campaign_New__c ==  ROYALL_PROGRAM_CAMPAIGN_NEW_OPTIMIZATION_FRESHMAN_HD  
                                    || 
                                    rprogram.Campaign_New__c ==  ROYALL_PROGRAM_CAMPAIGN_NEW_OPTIMIZATION_GRADUATE_PROFESSIONAL_HD
                                    || 
                                    rprogram.Campaign_New__c == ROYALL_PROGRAM_CAMPAIGN_NEW_OPTIMIZATION_TRANSFER_HD
                                )
                                &&
                                (  
                                   rprogram.Type__c == ROYALL_PROGRAM_TYPE_RE_ENGAGEMENT  
                                   || 
                                   rprogram.Type__c == ROYALL_PROGRAM_TYPE_UP_SELL
                                   || 
                                   rprogram.Type__c == ROYALL_PROGRAM_TYPE_CROSS_SELL
                                   || 
                                   rprogram.Type__c == ROYALL_PROGRAM_TYPE_LINE_OF_BUSINESS_TRANSFER
                                   || 
                                   rprogram.Type__c == ROYALL_PROGRAM_TYPE_FINAL_INVOICE_ADJUSTMENT
                                )
                            ){
                                countContractedProgramsFAO ++;
                                sumContractedValueFAO =  sumContractedValueFAO + rprogram.Program_Cost__c;
                            }
                        }    
                        //V_1.1 Modify By - Mahendra Swarnkar - CR-20170424-10876 - 07/06/2017 - Ends here
                    }
                    
                    //V_1.1 Modify By - Mahendra Swarnkar - CR-20170424-10876 - 07/06/2017 - Starts from here
                    //Populate the "Contracted_Programs_FAO__c" field on program package with total of no of related Programs which are Contracted and having the specific campaign_new and Type values.  
                    pp.Contracted_Programs_FAO__c = countContractedProgramsFAO;
                    
                    //Populate the "Contracted_Value_FAO__c" field on program package with total of "Program Cost" values on related Programs which are Contracted and having the specific campaign_new and Type values.  
                    if(sumContractedValueFAO > 0)
                        pp.Contracted_Value_FAO__c = sumContractedValueFAO;
                    else
                        pp.Contracted_Value_FAO__c = null;
                    //V_1.1 Modify By - Mahendra Swarnkar - CR-20170424-10876 - 07/06/2017 - Ends here
                    
                    //Populate the "Total_Contracted_Travel_Cost_HD__c" field on program package with total of "Billable Travel" values on related Programs which are Contracted.  
                    if(sumTotalContractedTravelCostHD > 0)
                        pp.Total_Contracted_Travel_Cost_HD__c = sumTotalContractedTravelCostHD;
                    else
                        pp.Total_Contracted_Travel_Cost_HD__c = null;
                    
                    //Commneted by Mahendra Swarnkar - 05/07/2020 - CR-20200218-13769
                    //Populate the "Total_Adjusted_Travel_Cost_HD__c" field on program package with total of "Billable Travel" values on related Programs which are Contracted and are of specific types. 
                    /*if(sumTotalAdjustedTravelCostHD > 0)
                        pp.Total_Adjusted_Travel_Cost_HD__c = sumTotalAdjustedTravelCostHD;
                    else
                        pp.Total_Adjusted_Travel_Cost_HD__c = null;*/
                    
                    //Populate the List of Program package to be updated. 
                    mapOfProgramPackageToBeUpdated.put(pp.Id, pp);
                }
            }
            
            //Disable All the triggers
            Util.BypassAllTriggers = true;
            
            //Check for size and update Program packages
            if(mapOfProgramPackageToBeUpdated.values().size() > 0)
                update mapOfProgramPackageToBeUpdated.values();
            
            //Enable All the triggers
            Util.BypassAllTriggers = false;
        }
    }

    //Calling Metadata.
    public static void updateCampaignCodeOnRoyall(List<Royall_Program__c> royallPrograms) {

        //Set to hold the campaign New Value. 
        Set<String> setToCampaignNew = new Set<String>();

        //Map to hold the Campaign code with repsect to Uniqu Key. 
        Map<String, String> mapOfCampaignCodeWithUniqueKey = new Map<String, String>();

        for(Royall_Program__c rP : royallPrograms) {

            setToCampaignNew.add(rP.Campaign_New__c);

        }

        //Check the size of set. 
        if(setToCampaignNew.size() > 0) {

            //Query on the custom Metadata.
            for(Program_Royall_HD_Campaign_Job_Code__mdt jobCode : [Select Campaign__c, Code__c, Target_Audience_New__c 
                                                                   From Program_Royall_HD_Campaign_Job_Code__mdt
                                                                   Where Campaign__c IN: setToCampaignNew AND Is_Active__c = true] ) {
                String uniqueKy = jobCode.Campaign__c +  (String.isNotBlank(jobCode.Target_Audience_New__c) ? '-'+jobCode.Target_Audience_New__c : '');

                mapOfCampaignCodeWithUniqueKey.put(uniqueKy, jobCode.Code__c);
                
            }

            //Loop again on the list of royallProgram. 
            for(Royall_Program__c rProgram : royallPrograms) {

                String uniqueKey1 = rProgram.Campaign_New__c;
                String uniqueKey2 = uniqueKey1 + '-' + rProgram.Target_Audience_New__c;              

                if(mapOfCampaignCodeWithUniqueKey != null) {
                    if(mapOfCampaignCodeWithUniqueKey.containsKey(uniqueKey2)) {
                        rProgram.Campaign_Code__c = mapOfCampaignCodeWithUniqueKey.get(uniqueKey2);
                    }else if(mapOfCampaignCodeWithUniqueKey.containsKey(uniqueKey1)){
                        rProgram.Campaign_Code__c = mapOfCampaignCodeWithUniqueKey.get(uniqueKey1);
                    }else{
                        rProgram.Campaign_Code__c = '';
                    }
                }else {
                    rProgram.Campaign_Code__c = '';
                }
            }
        }
    }
    
    /**
     *  Purpose         :   This method is used to populate Minimum_Contracted_Start_Date__c/Maximum_Contracted_Start_Date__c on Membership Period
     *
     *  Revision Logs   :   V_1.4 - Added By - Abhinav Sharma - 11/03/2020 - CR-20201026-14638 - Add Cappex fields
    **/
    public static void populateFieldOnMembershipPeriod(List<Royall_Program__c> newRoyallProgram , Map<Id, Royall_Program__c> mapOldRoyallProgram)
    {
        //Set to hold the Program package record Ids.
        Set<Id> setProgramPackageIds = new Set<Id>();
        
        for(Royall_Program__c rprog : newRoyallProgram != null ? newRoyallProgram : mapOldRoyallProgram.values())
        {
                if(newRoyallProgram != null && (mapOldRoyallProgram == null || (mapOldRoyallProgram != null && 
                                                                                (mapOldRoyallProgram.get(rprog.Id).Status__c != rprog.Status__c
                                                                                 || mapOldRoyallProgram.get(rprog.Id).Target_Audience_New__c != rprog.Target_Audience_New__c
                                                                                 || mapOldRoyallProgram.get(rprog.Id).Start_Date_CX__c != rprog.Start_Date_CX__c
                                                                                 || mapOldRoyallProgram.get(rprog.Id).End_Date_CX__c != rprog.End_Date_CX__c)))
                  )
                { 
                    setProgramPackageIds.add(rprog.Program_Package__c);
                }
                
                if(newRoyallProgram == null && mapOldRoyallProgram != null) {
                    setProgramPackageIds.add(mapOldRoyallProgram.get(rprog.Id).Program_Package__c);
                }
        }
        
        if(setProgramPackageIds.size() > 0)
        {
            List<Program_Package__c> listOfProgramPackageList = new List<Program_Package__c>();
            for(Program_Package__c programPackage : [SELECT Id, Minimum_Contracted_Start_Date__c, 
                                                     (SELECT Id, Start_Date_CX__c, End_Date_CX__c 
                                                      FROM Programs__r 
                                                      WHERE Status__c = 'Contracted' and Target_Audience_New__c = 'Cappex')
                                                     FROM Program_Package__c 
                                                     WHERE Id IN : setProgramPackageIds])
            {
                Date startDate;
                Date endDate;
                if(programPackage.Programs__r != null && programPackage.Programs__r.size() > 0)
                {
                    for(Royall_Program__c rp : programPackage.Programs__r ){
                        if(startDate == null){
                            startDate = rp.Start_Date_CX__c;
                        }
                        if(endDate == null){
                            endDate = rp.End_Date_CX__c;
                        }
                        if(rp.Start_Date_CX__c < startDate){
                            startDate = rp.Start_Date_CX__c;
                        }
                        if(rp.End_Date_CX__c > endDate){
                            endDate = rp.End_Date_CX__c;
                        }
                    }
                    programPackage.Minimum_Contracted_Start_Date__c = startDate;
                    programPackage.Maximum_Contracted_End_Date__c = endDate;
                    listOfProgramPackageList.add(programPackage);
                }
            }
            if(listOfProgramPackageList.size() > 0){
                Util.ByPassAllTriggers = true;
                update listOfProgramPackageList;
                Util.ByPassAllTriggers = false;
            }
        }
    }

    /**
     *  @description    :   Method to populate the Program Cost on Membership.
     *
     *  @args           :   List of Royall Programs
     *
     *  @return         :   void
     *
     *  Revision Log    :   V_1.0 - Created - Mahendra Swarnkar - 01/04/2021 - CR-20201204-14725 - Update logic behind CX Current Contract Value
     *
    **/
    public static void populateProgramCostOnMembership(List<Royall_Program__c> newRoyallProgram , map<Id, Royall_Program__c> mapOldRoyallProgram) {
        
        //Set to hold the Membership Period Ids
        Set<Id> setMembershipPeriodIds = new Set<Id>();
        
        //Loop through Royall Program records 
        for(Royall_Program__c rprog : newRoyallProgram != null ? newRoyallProgram : mapOldRoyallProgram.values()) {
            
            // Insert/Update use case
            if(newRoyallProgram != null && 
               (mapOldRoyallProgram == null || (mapOldRoyallProgram != null && 
                                                (
                                                    rprog.Program_Package__c != mapOldRoyallProgram.get(rprog.Id).Program_Package__c ||
                                                    rprog.Program_Cost__c != mapOldRoyallProgram.get(rprog.Id).Program_Cost__c || 
                                                    rprog.Start_Date_CX__c != mapOldRoyallProgram.get(rprog.Id).Start_Date_CX__c || 
                                                    rprog.End_Date_CX__c != mapOldRoyallProgram.get(rprog.Id).End_Date_CX__c 
                                                )
                                               )
               )
              ){
                  if(rprog.Program_Package__c != null)
                      setMembershipPeriodIds.add(rprog.Program_Package__c); 
                  
                  //add Membership Period
                  if(mapOldRoyallProgram != null && rprog.Program_Package__c != mapOldRoyallProgram.get(rprog.Id).Program_Package__c
                    && mapOldRoyallProgram.get(rprog.Id).Program_Package__c != null) {
                      setMembershipPeriodIds.add(mapOldRoyallProgram.get(rprog.Id).Program_Package__c);
                  }
              }
            
            //Delete Use case
            if(newRoyallProgram == null && mapOldRoyallProgram != null) {
                if(rprog.Program_Package__c != null)
                    setMembershipPeriodIds.add(rprog.Program_Package__c);
            }
            
        }   
        
        //check Membership Period set
        if(setMembershipPeriodIds.size() > 0) {
            
            //Map to hold the Membership Ids
            Map<Id, Membership__c> mapOfMembershipsToUpdate = new Map<Id, Membership__c>();
            
            //get Membership ids from associated Membership Periods
            for(Program_Package__c membershipPeriod : [Select Membership__c From Program_Package__c 
                                                       Where Membership__c != null AND Membership__r.Program_Acronym__c =: Constants.PROGRAM_ACRONYM_CXCN AND Id IN: setMembershipPeriodIds]
            ) {
                mapOfMembershipsToUpdate.put(membershipPeriod.Membership__c, new Membership__c(Id = membershipPeriod.Membership__c, CX_Current_Contract_Value__c = 0));
                
            }
            
            //check Membership set
            if(mapOfMembershipsToUpdate.size() > 0 && mapOfMembershipsToUpdate.keySet().size() > 0) {
                
                //Memberships to be update
                List<Membership__c> listMembershipToUpdate = new LIst<Membership__c>();
                
                for(AggregateResult membershipProgCost : [Select SUM(Program_Cost__c) programCost, Program_Package__r.Membership__c membershipId
                                                          From Royall_Program__c 
                                                          Where Program_Package__c != null AND Program_Package__r.Membership__c != null
                                                          AND End_Date_CX__c >= Today AND Start_Date_CX__c <= Today
                                                          AND Program_Package__r.Membership__c IN: mapOfMembershipsToUpdate.keySet() 
                                                          GROUP BY Program_Package__r.Membership__c]
                   ) {
                       
                       if(mapOfMembershipsToUpdate.containsKey((Id)membershipProgCost.get('membershipId')))
                           mapOfMembershipsToUpdate.get((Id)membershipProgCost.get('membershipId')).CX_Current_Contract_Value__c =(Double)membershipProgCost.get('programCost');

                   }
                
                if(mapOfMembershipsToUpdate.values().size() > 0) {
                    Util.ByPassAllTriggers = true;
                    Update mapOfMembershipsToUpdate.values();
                    Util.ByPassAllTriggers = false;
                }
                
            }
        }
        
    }

    /**
     *  @description    :   Method to create the Competitor Selection records when a Royall Program record is created or modified
     *
     *  @args           :   List of Royall Programs
     *
     *  @return         :   void
     *
     *  Revision Log    :   V_1.0 - Created - Colin McGloin - 09/14/2021 - CR-20210824-15375
     *
    **/

    public static void createCompetitorSelectionRecords (List<Royall_Program__c> newRoyallProgram , map<Id, Royall_Program__c> mapOldRoyallProgram){

        //Map for storing the Royall Program&HD records
        Map<Id, Royall_Program__c> mapRoyallProgramIdToRecord = new Map<Id, Royall_Program__c>();

        //Map for storing the Competitor Selection records by State within the Program Royall & HD record
        Map<Id, Map<String, Integer>> mapRPIdToMapStateToCount = new Map<Id, Map<String, Integer>>();

        //Lists of Competitor Selection records
        List<Competitor_Selection__c> compSelectionsForInsert = new List<Competitor_Selection__c>();
        List<Competitor_Selection__c> compSelectionsForDeletion = new List<Competitor_Selection__c>();

        //Set for State Values
        Set<String> setExistingStateValues = new Set<String>();

        //Loop through Royall Program records 
        for(Royall_Program__c rprog : newRoyallProgram != null ? newRoyallProgram : mapOldRoyallProgram.values()) {

            if(newRoyallProgram != null &&
            //Insert Scenario
               (mapOldRoyallProgram == null &&
               rprog.State_Selections__c != null && rprog.Program_Quantity__c != null && rProg.Campaign_New__c == 'ISC Advanced Awareness for Competitors' && rProg.Segment_Index__c == 1
               //Update Scenario
               || (mapOldRoyallProgram != null && rProg.Campaign_New__c == 'ISC Advanced Awareness for Competitors' && rProg.Segment_Index__c == 1 &&
                (rprog.State_Selections__c != mapOldRoyallProgram.get(rprog.Id).State_Selections__c || rprog.Program_Quantity__c != mapOldRoyallProgram.get(rprog.Id).Program_Quantity__c))
               )
              ){

                //Add the Royall Ids into a Map
                mapRoyallProgramIdToRecord.put(rprog.Id, rprog);

              }

        }

        //Work with any Royall IDs which passed criteria
        if (mapRoyallProgramIdToRecord.keyset().size() > 0){

            //Query for any existing Competitor Selection Records
            List<Competitor_Selection__c> competitorSelectionRecords = [SELECT Id, Name, Competitor__c, Program_Royall_HD__c, State__c FROM Competitor_Selection__c WHERE Program_Royall_HD__c IN :mapRoyallProgramIdToRecord.keyset() AND State__c != NULL];

            //Check for records and add to Map
            if (competitorSelectionRecords.size() > 0){

                //Loop through the Comp Selection records
                for (Competitor_Selection__c cSelection : competitorSelectionRecords){

                    //Add State Values to a Set
                    setExistingStateValues.add(cSelection.State__c);

                    //Add record to the Map
                    if (mapRPIdToMapStateToCount.get(cSelection.Program_Royall_HD__c) == null){

                        //Create Inner Map
                        Map<String, Integer> mapStateToCount = new Map<String, Integer>();
                        mapStateToCount.put(cSelection.State__c,1);
                        
                        //Add to outer Map
                        mapRPIdToMapStateToCount.put(cSelection.Program_Royall_HD__c, mapStateToCount);

                    } else {

                        //Get our Inner Map
                        Map<String, Integer> innerMap = mapRPIdToMapStateToCount.get(cSelection.Program_Royall_HD__c);

                        //Check to see if Inner Map exists
                        if (innerMap.get(cSelection.State__c) == null){
                            innerMap.put(cSelection.State__c, 1);
                            mapRPIdToMapStateToCount.put(cSelection.Program_Royall_HD__c, innerMap);
                        } else {
                            Integer stateCount = innerMap.get(cSelection.State__c);
                            stateCount++;
                            innerMap.put(cSelection.State__c, stateCount);
                            mapRPIdToMapStateToCount.put(cSelection.Program_Royall_HD__c, innerMap);
                        }

                    }

                }

            }

            //Loop through our Royall Records
            for (Royall_Program__c rProgram : mapRoyallProgramIdToRecord.values()){

                //Check to see if we have a value in State field
                if (rProgram.State_Selections__c != null){

                    //Check to see if 

                    //Parse the State field to see how many States we have to account for
                    List<String> states = rProgram.State_Selections__c.split(';');

                    //Check to see if we have to delete any existing Records as part of a change
                    if (setExistingStateValues.size() > 0){

                        //Remove values
                        setExistingStateValues.removeAll(states);

                        //Loop through and grab our records
                        if (setExistingStateValues.size() > 0){

                            //Grab our Competitor Records which match our Orphan states
                            for (Competitor_Selection__c cS : competitorSelectionRecords){
                                
                                //If the Competitor Matches our Orphan States and the Competitor has not already been populated then add for deletion
                                if (setExistingStateValues.contains(cS.State__c) && cS.Competitor__c == null){
                                    compSelectionsForDeletion.add(cS);
                                }
                            }

                        }

                    }

                    //Check to see how many of each have been created
                    if (rProgram.Program_Quantity__c != null){

                        //Calculate how many Competitor Selections should be created
                        for (String s : states){

                            Integer existingCount = 0;

                            //Check existing count of records and add value to Integer
                            if (mapRPIdToMapStateToCount.get(rProgram.Id) != null){
                                Map<String, Integer> mapStateToRecordCount = mapRPIdToMapStateToCount.get(rProgram.Id);
                                if (mapStateToRecordCount.get(s) != null){
                                    existingCount = mapStateToRecordCount.get(s);
                                }

                            }

                            //Calculate how many records to create
                            Integer recordsToCreate = Integer.valueOf(rProgram.Program_Quantity__c) - existingCount;

                            //Loop through and create records
                            for (integer i = 0; i < recordsToCreate; i++){

                                Competitor_Selection__c newRecord = new Competitor_Selection__c (State__c = s, Program_Royall_HD__c = rProgram.Id);
                                compSelectionsForInsert.add(newRecord);

                            }

                        }

                    }

                }

            }

            //Create records
            if (compSelectionsForInsert.size() > 0){
                insert compSelectionsForInsert;
            }

            //Delete Records
            if (compSelectionsForDeletion.size() > 0){
                delete compSelectionsForDeletion;
            }

        }

    }
}