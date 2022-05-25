/**
 *  Purpose            :    Utility class to hold the all the utility method for Revenue Management    
 *
 *  Created By         :    Subhash Garhwal
 *
 *  Created Date       :    02/08/2017
 *
 *  Revision Log       :    V1.0 - Created - CR-20161102-10316 - Revenue Management
 *                          V1.1 - Modified - Abhinav Sharma - 05/07/2017 - CR-20170302-10729 - Made changes according to Solution design 1.4
 *                          V1.2 - Modified - Abhinav Sharma - 05/07/2017 - CR-20170508-10908 - Mass edit: Ability to mass edit Comments fields. - Abhinav Sharma - 05/10/2017 (massEditRevenues method)
 *                          V1.3 - Modified - Abhinav Sharma - 05/15/2017 - CR-20170508-10923 - Program name change linkage
 *                          V1.4 - Modified - Abhinav Sharma - 05/16/2017 - CR-20170508-10914 - Enable Mass edit for risk fields
 *                          V1.5 - Modified - Abhinav Sharma - 05/18/2017 - CR-20170508-10905 - "Change Reason Code" (picklist) and validation around it
 *							V1.6 - Modified - Abhinav Sharma - 08/16/2017 - Issue--CR11136--QA--00005401 - Implemented changes for fixes
 *                                         
 **/
public with sharing class RMUtility {
    
    /**
     *  @description    :   This method is used to populate the field values on ABC Revenue
     *
     *  @args           :   Contract__c, String, String
     *
     *  @retuen         :   ABC_Revenue__c
     *
     *  @revision Log   :   V1.0 - Created - 2/8/2017 - Subhash Garhwal - CR-20161102-10316
     *
     **/
    public static ABC_Revenue__c popuateRevenue(Contract__c contractABC, SBQQ__Subscription__c sBQQSubscription, String feeType, String productId, String recordTypeId) {
        
        //Instance of ABC Revenue
        ABC_Revenue__c aBCRevenue = new ABC_Revenue__c();
        
        //Populate field values
        if(contractABC != null) {
            
            //Populating fields on ABC Revenue
        	aBCRevenue.Contract_ABC__c = contractABC.Id;
        	aBCRevenue.Institution__c = contractABC.Payer_Account__c;
        	aBCRevenue.Program__c = contractABC.Program__c;
        	aBCRevenue.Recognition_End_Date__c = contractABC.End__c;
        	aBCRevenue.Recognition_Start_Date__c = contractABC.Start__c;
            
            //Check for feeType to set Expected_Amount_to_Recognize__c
            if(feeType == RMConstants.ABC_REVENUE_FEE_TYPE_SETUP)
                aBCRevenue.Expected_Amount_to_Recognize__c = contractABC.Setup_In_Negotiated__c;
            else if(feeType == RMConstants.ABC_REVENUE_FEE_TYPE_ANNUAL) {
            
                //Check for Negotiated_Amount__c and Setup_In_Negotiated__c
                if(contractABC.Negotiated_Amount__c != null && contractABC.Setup_In_Negotiated__c != null)
                	aBCRevenue.Expected_Amount_to_Recognize__c = contractABC.Negotiated_Amount__c - contractABC.Setup_In_Negotiated__c;
                else if(contractABC.Setup_In_Negotiated__c == null)
                    aBCRevenue.Expected_Amount_to_Recognize__c = contractABC.Negotiated_Amount__c;
                else if(contractABC.Negotiated_Amount__c == null)
                	aBCRevenue.Expected_Amount_to_Recognize__c = - contractABC.Setup_In_Negotiated__c;
            }
            
            //Check for feeType to set GAAP Amount
            if(feeType == RMConstants.ABC_REVENUE_FEE_TYPE_SETUP)
                aBCRevenue.GAAP_Amount__c = contractABC.Setup_In_Negotiated__c;
            else if(feeType == RMConstants.ABC_REVENUE_FEE_TYPE_ANNUAL) {
                
                //Check for Negotiated_Amount__c and Setup_In_Negotiated__c
                if(contractABC.Negotiated_Amount__c != null && contractABC.Setup_In_Negotiated__c != null)
                    aBCRevenue.GAAP_Amount__c = contractABC.Negotiated_Amount__c - contractABC.Setup_In_Negotiated__c;
                else if(contractABC.Setup_In_Negotiated__c == null)
                    aBCRevenue.GAAP_Amount__c = contractABC.Negotiated_Amount__c;
                else if(contractABC.Negotiated_Amount__c == null)
                      aBCRevenue.GAAP_Amount__c = - contractABC.Setup_In_Negotiated__c;
            }
        
            //Check for feeType to set Negotiated Amount
            if(feeType == RMConstants.ABC_REVENUE_FEE_TYPE_SETUP)
                aBCRevenue.Negotiated_Amount__c = contractABC.Setup_In_Negotiated__c;
            else if(feeType == RMConstants.ABC_REVENUE_FEE_TYPE_ANNUAL) {
                
                //Check for Negotiated_Amount__c and Setup_In_Negotiated__c
                if(contractABC.Negotiated_Amount__c != null && contractABC.Setup_In_Negotiated__c != null)
                    aBCRevenue.Negotiated_Amount__c = contractABC.Negotiated_Amount__c - contractABC.Setup_In_Negotiated__c;
                else if(contractABC.Setup_In_Negotiated__c == null)
                    aBCRevenue.Negotiated_Amount__c = contractABC.Negotiated_Amount__c;
                else if(contractABC.Negotiated_Amount__c == null)
                      aBCRevenue.Negotiated_Amount__c = - contractABC.Setup_In_Negotiated__c;
            }
        
        } else if(sBQQSubscription != null) {
            
            //Populating fields on ABC Revenue
        	aBCRevenue.Program_Subscription__c = sBQQSubscription.Id;
            
            //Added By - Abhinav Sharma - 08/16/2017 - Issue--CR11136--QA--00005401
            //Start from here
            aBCRevenue.Contract__c = sBQQSubscription.SBQQ__Contract__c;
            //Upto here
            
        	aBCRevenue.Institution__c = sBQQSubscription.SBQQ__Account__c;
        	aBCRevenue.Program__c = sBQQSubscription.Program__c;
        	aBCRevenue.Recognition_End_Date__c = sBQQSubscription.SBQQ__EndDate__c;
        	aBCRevenue.Recognition_Start_Date__c = sBQQSubscription.SBQQ__StartDate__c;
            
            //Check for feeType to set Expected_Amount_to_Recognize__c
            if(feeType == RMConstants.ABC_REVENUE_FEE_TYPE_SETUP)
                aBCRevenue.Expected_Amount_to_Recognize__c = sBQQSubscription.Setup_In_Negotiated__c;
            else if(feeType == RMConstants.ABC_REVENUE_FEE_TYPE_ANNUAL) {
            
                //Check for Negotiated_Amount_Subscription__c and Setup_In_Negotiated__c
                if(sBQQSubscription.Negotiated_Amount_Subscription__c != null && sBQQSubscription.Setup_In_Negotiated__c != null)
                	aBCRevenue.Expected_Amount_to_Recognize__c = sBQQSubscription.Negotiated_Amount_Subscription__c - sBQQSubscription.Setup_In_Negotiated__c;
                else if(sBQQSubscription.Setup_In_Negotiated__c == null || sBQQSubscription.Setup_In_Negotiated__c == 0.00)
                    aBCRevenue.Expected_Amount_to_Recognize__c = sBQQSubscription.Negotiated_Amount_Subscription__c;
                else if(sBQQSubscription.Negotiated_Amount_Subscription__c == null)
                	aBCRevenue.Expected_Amount_to_Recognize__c = - sBQQSubscription.Setup_In_Negotiated__c;
            }
            
            //Check for feeType to set GAAP Amount
            if(feeType == RMConstants.ABC_REVENUE_FEE_TYPE_SETUP)
                aBCRevenue.GAAP_Amount__c = sBQQSubscription.Setup_In_Negotiated__c;
            else if(feeType == RMConstants.ABC_REVENUE_FEE_TYPE_ANNUAL) {
                
                //Check for Negotiated_Amount_Subscription__c and Setup_In_Negotiated__c
                if(sBQQSubscription.Negotiated_Amount_Subscription__c != null && sBQQSubscription.Setup_In_Negotiated__c != null)
                    aBCRevenue.GAAP_Amount__c = sBQQSubscription.Negotiated_Amount_Subscription__c - sBQQSubscription.Setup_In_Negotiated__c;
                else if(sBQQSubscription.Setup_In_Negotiated__c == null || sBQQSubscription.Setup_In_Negotiated__c == 0.00)
                    aBCRevenue.GAAP_Amount__c = sBQQSubscription.Negotiated_Amount_Subscription__c;
                else if(sBQQSubscription.Negotiated_Amount_Subscription__c == null)
                      aBCRevenue.GAAP_Amount__c = - sBQQSubscription.Setup_In_Negotiated__c;
            }
        
            //Check for feeType to set Negotiated Amount
            if(feeType == RMConstants.ABC_REVENUE_FEE_TYPE_SETUP)
                aBCRevenue.Negotiated_Amount__c = sBQQSubscription.Setup_In_Negotiated__c;
            else if(feeType == RMConstants.ABC_REVENUE_FEE_TYPE_ANNUAL) {
                
                //Check for Negotiated_Amount_Subscription__c and Setup_In_Negotiated__c
                if(sBQQSubscription.Negotiated_Amount_Subscription__c != null && sBQQSubscription.Setup_In_Negotiated__c != null)
                    aBCRevenue.Negotiated_Amount__c = sBQQSubscription.Negotiated_Amount_Subscription__c - sBQQSubscription.Setup_In_Negotiated__c;
                else if(sBQQSubscription.Setup_In_Negotiated__c == null || sBQQSubscription.Setup_In_Negotiated__c == 0.00)
                    aBCRevenue.Negotiated_Amount__c = sBQQSubscription.Negotiated_Amount_Subscription__c;
                else if(sBQQSubscription.Negotiated_Amount_Subscription__c == null)
                      aBCRevenue.Negotiated_Amount__c = - sBQQSubscription.Setup_In_Negotiated__c;
            }
        }
        
        //Populating fields on ABC Revenue
        aBCRevenue.Fee_Type__c = feeType;
        aBCRevenue.Line_Status__c = RMConstants.ABC_REVENUE_LINE_STATUS_DRAFT; 
        aBCRevenue.Product__c = productId;
        aBCRevenue.RecordTypeId = recordTypeId;
        
        //Return
        return aBCRevenue;
    }
    
    /**
     *  @description    :   This method is used to build the SOQL query string.
     *
     *  @args           :   Map<String, Schema.SObjectType>, String
     *
     *  @return         :   String
     *
     **/
    public static String buildSOQL(Map<String, Schema.SObjectType> globalDescribe, String objName) {
        
        //SOQL query
        String SOQL = 'Select ';
        
        //Get the field of the object'
        for(String field : globalDescribe.get(objName).getDescribe().fields.getMap().keySet())
            SOQL += field + ',';
        
        //Remove extra elements and add object
        SOQL = SOQL.removeEnd(',') + ' From ' + objName;
        
        //Return 
        return SOQL;
        
    }
    
    /**
     *  @description    :   This method is used to update the field values on Cloned ABC Revenue according to current Contract ABC values
     *
     *  @args           :   ABC_Revenue__c, Contract__c, String
     *
     *  @retuen         :   ABC_Revenue__c
     *
     *  @revision Log   :   V1.0 - Created - 2/8/2017 - Subhash Garhwal - CR-20161102-10316
     *
     **/
    public static ABC_Revenue__c updateClonedRevenues(ABC_Revenue__c aBCRevenue, Contract__c contractABC, SBQQ__Subscription__c sBQQSubsciption, String productId) {
        
        //Populate field values
        if(contractABC != null) {
            
            //Populating revenue fields
        	aBCRevenue.Contract_ABC__c = contractABC.Id;
        	aBCRevenue.Institution__c = contractABC.Payer_Account__c;
        	aBCRevenue.Program__c = contractABC.Program__c;
            
        } else if(sBQQSubsciption != null) {
            
            //Populating revenue fields
        	aBCRevenue.Program_Subscription__c = sBQQSubsciption.Id;
        	aBCRevenue.Institution__c = sBQQSubsciption.SBQQ__Account__c;
        	aBCRevenue.Program__c = sBQQSubsciption.Program__c;
            
            //Added By - Abhinav Sharma - 08/16/2017 - Issue--CR11136--QA--00005401
            //Start from here
            aBCRevenue.Contract__c = sBQQSubsciption.SBQQ__Contract__c;
            //Upto here
        }
        
        //Populating revenue fields
        aBCRevenue.Line_Status__c = null;
        aBCRevenue.Product__c = productId; 
        aBCRevenue.Rev_Rec_Complete__c = false;
        aBCRevenue.Expected_Amount_to_Recognize__c = null;
        aBCRevenue.Negotiated_Amount__c = null;
        aBCRevenue.GAAP_Amount__c = null;
        aBCRevenue.Secured_Amount__c = null;
        aBCRevenue.List_Price__c = null;
        aBCRevenue.OwnerId = UserInfo.getUserId();
        
        //Return
        return aBCRevenue;
    }
    
    /**
     *  @description    :   This method is used to update the field values on Copied ABC Revenue
     *
     *  @args           :   ABC_Revenue__c
     *
     *  @retuen         :   ABC_Revenue__c
     *
     *  @revision Log   :   V1.0 - Created - 2/8/2017 - Subhash Garhwal - CR-20161102-10316
     *                      V1.1 - Modified - CR-20170508-10923 (5/15/2017) - By Abhinav Sharma 
     *
     **/
     public static ABC_Revenue__c updateCopiedRevenues(ABC_Revenue__c aBCRevenue, Contract__c contractABC, SBQQ__Subscription__c sBQQSubscription, String productId, RevenueManagementWrapper rW) {
        
        //Added - CR-20170508-10923 (5/15/2017) - By Abhinav Sharma
        //Start from here
        if(contractABC != null) {
        	aBCRevenue.Program__c = contractABC.Program__c;
        }
        	
        else if(sBQQSubscription != null) {
            
        	aBCRevenue.Program__c = sBQQSubscription.Program__c;
            
            //Added By - Abhinav Sharma - 08/16/2017 - Issue--CR11136--QA--00005401
            //Start from here
            aBCRevenue.Program_Subscription__c = sBQQSubscription.Id;
            aBCRevenue.Contract__c = sBQQSubscription.SBQQ__Contract__c;
            //Upto here
        }
        	
        aBCRevenue.Product__c = productId;
        //Upto here
        
        aBCRevenue.Line_Status__c = rW.aBCRevenue.Line_Status__c;
        aBCRevenue.Recognition_Start_Date__c = rW.aBCRevenue.Recognition_Start_Date__c;
        aBCRevenue.Recognition_End_Date__c = rW.aBCRevenue.Recognition_End_Date__c;
        aBCRevenue.Site_Live_Date__c = rW.aBCRevenue.Site_Live_Date__c;
        aBCRevenue.Risk_Type__c = rW.aBCRevenue.Risk_Type__c;
        aBCRevenue.Risk_Status__c = rW.aBCRevenue.Risk_Status__c;
        aBCRevenue.Risk_Due_Date__c = rW.aBCRevenue.Risk_Due_Date__c;
        aBCRevenue.Fee_Type__c = rW.aBCRevenue.Fee_Type__c;
        aBCRevenue.Negotiated_Amount__c = rW.aBCRevenue.Negotiated_Amount__c;
        aBCRevenue.GAAP_Amount__c = rW.aBCRevenue.GAAP_Amount__c;
        aBCRevenue.List_Price__c = rW.aBCRevenue.List_Price__c;
        aBCRevenue.Secured_Amount__c = rW.aBCRevenue.Secured_Amount__c;
        aBCRevenue.Secured_Amount_GAAP__c = rW.aBCRevenue.Secured_Amount_GAAP__c;
        aBCRevenue.Expected_Amount_to_Recognize__c = rW.aBCRevenue.Expected_Amount_to_Recognize__c;
        aBCRevenue.Risk_Maximum_Potential__c = rW.aBCRevenue.Risk_Maximum_Potential__c;
        aBCRevenue.Risk_Expected__c = rW.aBCRevenue.Risk_Expected__c;
        aBCRevenue.Risk_Estimated__c = rW.aBCRevenue.Risk_Estimated__c;
        aBCRevenue.Comments__c = rW.aBCRevenue.Comments__c;

        //Changed this mapping to never copy over the Recognized Amounts - Requested by Laura Beale
        aBCRevenue.Recognized_to_Date_Negotiated__c = 0;
        aBCRevenue.Recognized_to_Date_GAAP__c = 0;

        aBCRevenue.Rev_Rec_Complete__c = false;
                
        //Return
        return aBCRevenue;
    }
    
    /**
     *  @description    :   This method is used to populate the field values on new ABC Revenue records
     *
     *  @args           :   Contract__c, String
     *
     *  @retuen         :   ABC_Revenue__c
     *
     *  @revision Log   :   V1.0 - Created - 2/8/2017 - Subhash Garhwal - CR-20161102-10316
     *
     **/
    public static ABC_Revenue__c updateNewRevenues(Contract__c contractABC, SBQQ__Subscription__c sBQQSubscription, String productId, String recordTypeId) {
        
        //Instance of ABC Revenue
        ABC_Revenue__c aBCRevenue = new ABC_Revenue__c();
        
        //Populate field values
        if(contractABC != null) {
        
            //Populating fields on revenue
            aBCRevenue.Contract_ABC__c = contractABC.Id;
            aBCRevenue.Institution__c = contractABC.Payer_Account__c;
            aBCRevenue.Program__c = contractABC.Program__c;
        
        } else if(sBQQSubscription != null) {
            
            //Populating fields on revenue
            aBCRevenue.Program_Subscription__c = sBQQSubscription.Id;
            aBCRevenue.Institution__c = sBQQSubscription.SBQQ__Account__c;
            aBCRevenue.Program__c = sBQQSubscription.Program__c;
            
            //Added By - Abhinav Sharma - 08/16/2017 - Issue--CR11136--QA--00005401
            //Start from here
            aBCRevenue.Contract__c = sBQQSubscription.SBQQ__Contract__c;
            //Upto here
        }
        
        //Populating fields on revenue
        aBCRevenue.Product__c = productId;
        aBCRevenue.Rev_Rec_Complete__c = false;
        aBCRevenue.RecordTypeId = recordTypeId;
        
        //Return
        return aBCRevenue;
    }
    
    /**
     *  @description    :   This method is used to Edit the field values
     *
     *  @args           :   RevenueManagementWrapper, RevenueManagementWrapper, Map<Id, ffrr__Template__c>
     *
     *  @retuen         :   
     *
     *  @revision Log   :   V1.0 - Created - 2/8/2017 - Subhash Garhwal - CR-20161102-10316
     *                      V1.1 - Modified - CR-20170302-10729 - Made changes according to Solution design 1.4 (Added new fields to update)
     *						V1.2 - Modified - 10/03/2017 - Subhash Garhwal - CR-20170907-11185 - Bypass Site Live Date update logic if Clarizen First Go Live Complete is populated
     *
     **/
    public static void massEditRevenues(RevenueManagementWrapper rMW, RevenueManagementWrapper revenuemManagementWrap, Map<Id, ffrr__Template__c> mapTemplates) {
        
        //Check for mass Edit variable
        if(revenuemManagementWrap != null) {
            
            //Check for Rev_Rec_Complete__c field
            if(rMW.aBCRevenue.Rev_Rec_Complete__c) {
                
                //if one of the following fields is changed, then Rev Rec Complete is auto-updated to FALSE so that the Rev Rec system can re-process the line.
                //– Recognition Start Date
                //– Recognition End Date
                //– Negotiated Amount
                //– Expected Amount
                //– GAAP Amount
                //– Secured Amount
                if((revenuemManagementWrap.aBCRevenue.Recognition_Start_Date__c != null && rMW.aBCRevenue.Recognition_Start_Date__c != revenuemManagementWrap.aBCRevenue.Recognition_Start_Date__c)
                    || (revenuemManagementWrap.aBCRevenue.Recognition_End_Date__c != null && rMW.aBCRevenue.Recognition_End_Date__c != revenuemManagementWrap.aBCRevenue.Recognition_End_Date__c)
                    || (revenuemManagementWrap.aBCRevenue.Negotiated_Amount__c != null && rMW.aBCRevenue.Negotiated_Amount__c != revenuemManagementWrap.aBCRevenue.Negotiated_Amount__c
                    || (revenuemManagementWrap.aBCRevenue.Negotiated_Amount__c != null && (rMW.aBCRevenue.Expected_Amount_to_Recognize__c == null || rMW.aBCRevenue.Expected_Amount_to_Recognize__c == 0
                        || rMW.aBCRevenue.GAAP_Amount__c == null || rMW.aBCRevenue.GAAP_Amount__c == 0
                        || rMW.aBCRevenue.Secured_Amount__c == null || rMW.aBCRevenue.Secured_Amount__c == 0))))
                    rMW.aBCRevenue.Rev_Rec_Complete__c = false; 
            }
            
            //Edit values
            rMW.aBCRevenue.Line_Status__c = String.isNotBlank(revenuemManagementWrap.aBCRevenue.Line_Status__c) ? revenuemManagementWrap.aBCRevenue.Line_Status__c : rMW.aBCRevenue.Line_Status__c;
            rMW.aBCRevenue.Recognition_Start_Date__c = revenuemManagementWrap.aBCRevenue.Recognition_Start_Date__c != null ? revenuemManagementWrap.aBCRevenue.Recognition_Start_Date__c : rMW.aBCRevenue.Recognition_Start_Date__c;
            rMW.aBCRevenue.Recognition_End_Date__c = revenuemManagementWrap.aBCRevenue.Recognition_End_Date__c != null ? revenuemManagementWrap.aBCRevenue.Recognition_End_Date__c : rMW.aBCRevenue.Recognition_End_Date__c;
            rMW.aBCRevenue.Site_Live_Date__c = (rMW.clarizenFirstGoLiveComplete == null && revenuemManagementWrap.aBCRevenue.Site_Live_Date__c != null) ? revenuemManagementWrap.aBCRevenue.Site_Live_Date__c : rMW.aBCRevenue.Site_Live_Date__c;
            rMW.aBCRevenue.Fee_Type__c = String.isNotBlank(revenuemManagementWrap.aBCRevenue.Fee_Type__c) ? revenuemManagementWrap.aBCRevenue.Fee_Type__c : rMW.aBCRevenue.Fee_Type__c;
            rMW.aBCRevenue.Risk_Type__c = String.isNotBlank(revenuemManagementWrap.aBCRevenue.Risk_Type__c) ? revenuemManagementWrap.aBCRevenue.Risk_Type__c : rMW.aBCRevenue.Risk_Type__c;
            rMW.aBCRevenue.Risk_Status__c = String.isNotBlank(revenuemManagementWrap.aBCRevenue.Risk_Status__c) ? revenuemManagementWrap.aBCRevenue.Risk_Status__c : rMW.aBCRevenue.Risk_Status__c;
            rMW.aBCRevenue.Risk_Due_Date__c = revenuemManagementWrap.aBCRevenue.Risk_Due_Date__c != null ? revenuemManagementWrap.aBCRevenue.Risk_Due_Date__c : rMW.aBCRevenue.Risk_Due_Date__c;
            rMW.aBCRevenue.List_Price__c = revenuemManagementWrap.aBCRevenue.List_Price__c != null ? revenuemManagementWrap.aBCRevenue.List_Price__c : rMW.aBCRevenue.List_Price__c;
            rMW.aBCRevenue.Negotiated_Amount__c = revenuemManagementWrap.aBCRevenue.Negotiated_Amount__c != null ? revenuemManagementWrap.aBCRevenue.Negotiated_Amount__c : rMW.aBCRevenue.Negotiated_Amount__c;
            rMW.aBCRevenue.Expected_Amount_to_Recognize__c = revenuemManagementWrap.aBCRevenue.Expected_Amount_to_Recognize__c != null ? revenuemManagementWrap.aBCRevenue.Expected_Amount_to_Recognize__c : rMW.aBCRevenue.Expected_Amount_to_Recognize__c;
            rMW.aBCRevenue.GAAP_Amount__c = revenuemManagementWrap.aBCRevenue.GAAP_Amount__c != null ? revenuemManagementWrap.aBCRevenue.GAAP_Amount__c : rMW.aBCRevenue.GAAP_Amount__c;
            rMW.aBCRevenue.Secured_Amount__c = revenuemManagementWrap.aBCRevenue.Secured_Amount__c != null ? revenuemManagementWrap.aBCRevenue.Secured_Amount__c : rMW.aBCRevenue.Secured_Amount__c;
            rMW.aBCRevenue.Secured_Amount_GAAP__c = revenuemManagementWrap.aBCRevenue.Secured_Amount_GAAP__c != null ? revenuemManagementWrap.aBCRevenue.Secured_Amount_GAAP__c : rMW.aBCRevenue.Secured_Amount_GAAP__c;
        
            //Added By - Abhinav Sharma - CR-20170508-10908 - Mass edit: Ability to mass edit Comments fields.
            //Start from here
            rMW.aBCRevenue.Comments__c = revenuemManagementWrap.aBCRevenue.Comments__c != null ? revenuemManagementWrap.aBCRevenue.Comments__c : rMW.aBCRevenue.Comments__c;
            //upto here
            
            //Added By - Abhinav Sharma - CR-20170508-10914 - Mass edit: Ability to mass edit Risk fields.
            //Start from here
            rMW.aBCRevenue.Risk_Maximum_Potential__c = revenuemManagementWrap.aBCRevenue.Risk_Maximum_Potential__c != null ? revenuemManagementWrap.aBCRevenue.Risk_Maximum_Potential__c : rMW.aBCRevenue.Risk_Maximum_Potential__c;
            rMW.aBCRevenue.Risk_Expected__c = revenuemManagementWrap.aBCRevenue.Risk_Expected__c != null ? revenuemManagementWrap.aBCRevenue.Risk_Expected__c : rMW.aBCRevenue.Risk_Expected__c;
            rMW.aBCRevenue.Risk_Estimated__c = revenuemManagementWrap.aBCRevenue.Risk_Estimated__c != null ? revenuemManagementWrap.aBCRevenue.Risk_Estimated__c : rMW.aBCRevenue.Risk_Estimated__c;    
            //Upto here
            
            //Added By - Abhinav Sharma - CR-20170508-10905 - "Change Reason Code" (picklist) and validation around it
            //Start from here
            rMW.aBCRevenue.Change_Reason_Code_Clone__c = revenuemManagementWrap.aBCRevenue.Change_Reason_Code_Clone__c != null ? revenuemManagementWrap.aBCRevenue.Change_Reason_Code_Clone__c : rMW.aBCRevenue.Change_Reason_Code_Clone__c;
            //Upto here
            
            //Checking if risk status is having pending or dropped as a value with it
            if(String.isNotBlank(rMW.aBCRevenue.Risk_Status__c)
                && (
                    rMW.aBCRevenue.Risk_Status__c == 'Pending'
                    || 
                    rMW.aBCRevenue.Risk_Status__c == 'Dropped'            
                )
            ) {
                rMW.aBCRevenue.Secured_Amount__c = 0.00;
                rMW.aBCRevenue.Secured_Amount_GAAP__c = 0.00;    
            }
        }
        
        //Check for mass Edit variable
        if(revenuemManagementWrap == null)
            revenuemManagementWrap = rMW;   
        
        //Logic for template
        if(revenuemManagementWrap != null && mapTemplates != null 
            && String.isNotBlank(revenuemManagementWrap.selectedTemplate) 
            && mapTemplates.containsKey(revenuemManagementWrap.selectedTemplate) 
            && mapTemplates.get(revenuemManagementWrap.selectedTemplate) != null) {
            
            //Update Template values
            rMW.aBCRevenue.Rev_Rec_Templates__c = mapTemplates.get(revenuemManagementWrap.selectedTemplate).Name;
            rMW.aBCRevenue.Rev_Rec_Template_Ids__c = mapTemplates.get(revenuemManagementWrap.selectedTemplate).Id;
            rMW.templates = new List<String>();
            
            //Template values
            rMW.templates.add(mapTemplates.get(revenuemManagementWrap.selectedTemplate).Name);
            rMW.selectedTemplate = revenuemManagementWrap.selectedTemplate;
            
            //Check for Template A
            if(mapTemplates.get(revenuemManagementWrap.selectedTemplate).Template_A__c != null) {
                
                
                rMW.aBCRevenue.Rev_Rec_Templates__c += ',' + mapTemplates.get(revenuemManagementWrap.selectedTemplate).Template_A__r.Name;
                rMW.aBCRevenue.Rev_Rec_Template_Ids__c = ',' + mapTemplates.get(revenuemManagementWrap.selectedTemplate).Template_A__c;
                
                //Template values
                rMW.templates.add(mapTemplates.get(revenuemManagementWrap.selectedTemplate).Template_A__r.Name);
            }
        }
    }
    
    /**
     *  @description    :   Method is used to populate template details  
     *                                  
     *  @args           :   List<SelectOption>, Map<Id, ffrr__Template__c>
     *
     *  @return         :   Pagereference
     *  
     *  @Revision Log   :   V1.0 - 2/8/2017 - Created - CR-20161102-10316 - Subhash Garhwal
     * 						V1.1 - 01/17/2019 - Modified By Colin McGloin - Removed filter to only show Templates with a Template A record populated since we no longer need Template A 
     *
     **/
    public static void populateTemplateDetails(List<SelectOption> primaryTemplates, Map<Id, ffrr__Template__c> mapTemplates) {
        
        //Add Blank option
        primaryTemplates.add(new SelectOption('', '--None--'));
        
        //Query through Templates
        for(ffrr__Template__c template : [Select Id, Name, Template_A__c, Template_A__r.Name 
                                          	From ffrr__Template__c
                                          	WHERE Active__c = TRUE
                                         	ORDER BY Name ASC
                                         ]) {
            
            //Add Templates in select options
            primaryTemplates.add(new SelectOption(template.Id, template.Name));
            
            //Add Template in map
            mapTemplates.put(template.Id, template);
        }
    }
    
    //Added By - Abhinav Sharma - CR-20170508-10905 - variable to control execution of trigger
    /**
     *  @description    :   This variable to check if the trigger needs to be executed for the current context user
     *
	 *  @return         :   boolean
     *
    **/
    public static Boolean EXECUTE_TRIGGER {
        get {
            
            //Checking for the null value
            if(RMUtility.EXECUTE_TRIGGER == null) {
                
            	//Used Custom Label for Custom Permission in order to omit one query
                //Checking list for it's size
                if(String.isNotBlank(Label.BYPASS_TRIGGER_CUSTOM_PERMISSION_ID)) {
                    
                    //Checking if "Trigger_Bypass_for_Financial_Data_Update" permission set is assigned to current logged in user
					//At the same time, "Bypass Triggers" custom permission is enabled on it
					//Then we will set/update the "Util.EXECUTE_TRIGGER" flag to false. 
                    List<SetupEntityAccess> setupEntities = [SELECT SetupEntityId
                                                            	FROM SetupEntityAccess
                                                               	WHERE SetupEntityId = :System.Label.BYPASS_TRIGGER_CUSTOM_PERMISSION_ID 
                                                             		AND ParentId IN (SELECT PermissionSetId
                                                                                        FROM PermissionSetAssignment
                                                                                        WHERE AssigneeId = :UserInfo.getUserId()
                                                                                     		AND PermissionSet.Name =: System.Label.Bypass_Triggers_Permission_Set_API_Name
                                                                                    )
                                                            ];
                	
                    //Checking for the eligility and setting flags
                    if(setupEntities.size() > 0)
                        RMUtility.EXECUTE_TRIGGER = false;
                    else
                        RMUtility.EXECUTE_TRIGGER = true;
                
                } else {
                	RMUtility.EXECUTE_TRIGGER = true;
                }
            }
            
            //Execute all the triggers
            return RMUtility.EXECUTE_TRIGGER;
        }
        set;
    }
    
    public static void calculateListPriceRevenueRecordSingleRecord (Id revenueId){
        
        ABC_Revenue__c revenue = [SELECT Id, Program_Subscription__c, Fee_Type__c, Recognition_End_Date__c, Recognition_Start_Date__c, List_Price__c
                                  FROM ABC_Revenue__c
                                  WHERE ID = :revenueId];
        
        System.debug('zzz Revenue: ' + revenue);
        
        //Go off and get our Component Subscription records
        List<SBQQ__Subscription__c> relatedSubscriptions = [SELECT Id, Name, SBQQ__SegmentStartDate__c, SBQQ__SegmentEndDate__c, SBQQ__Product__c,
                                                            Term_Type__c, Years_in_Term__c, SBQQ__ListPrice__c, Product_Category__c
                                                            FROM SBQQ__Subscription__c
                                                            WHERE Program_Subscription__c = :revenue.Program_Subscription__c];
        
        Map<String, String> mapSubProdCatToRevenueFeeType = new Map<String, String>{'Annual Fee' => 'Annual','Travel Fee' => 'Annual','Implementation Fee' => 'Setup_Implementation'};     
            
        //Variable where we'll store the amount accumulated across Subscriptions
        Decimal combinedListPrice = 0;
        
        //If we have records then proceed
        if (relatedSubscriptions.size() > 0){
            
            //Loop through out Subscription records
            for (SBQQ__Subscription__c sub : relatedSubscriptions){
                
                //If the Categories match
                if (revenue.Fee_Type__c == mapSubProdCatToRevenueFeeType.get(sub.Product_Category__c)){
                    
                    //Calculate our List Price Amount per Day
                    Integer daysOfSegment = sub.SBQQ__SegmentStartDate__c.daysBetween(sub.SBQQ__SegmentEndDate__c) + 1;
                    Decimal DailyListPriceAmount = sub.SBQQ__ListPrice__c/daysOfSegment;
                    
                    System.debug('@@@ Sub Name: ' + sub.Name);
                    System.debug('@@@ days of segment: ' + daysOfSegment);
                    System.debug('@@@ Total List Price: ' + sub.SBQQ__ListPrice__c);
                    System.debug('@@@ DailyListPriceAmount: ' + DailyListPriceAmount);
                    
                    //Calculate if we have an overlap
                    if (revenue.Recognition_Start_Date__c <= sub.SBQQ__SegmentEndDate__c && revenue.Recognition_End_Date__c >= sub.SBQQ__SegmentStartDate__c){
                        
                        System.debug('@@@ Recognition Start Date: ' + revenue.Recognition_Start_Date__c);
                        System.debug('@@@ Recognition End Date: ' + revenue.Recognition_End_Date__c);
                        System.debug('@@@ Subscription Start Date: ' + sub.SBQQ__SegmentStartDate__c);
                        System.debug('@@@ Subscription End Date: ' + sub.SBQQ__SegmentEndDate__c);
                        
                        Integer overlapDays = 0;
                        
                        if (revenue.Recognition_Start_Date__c < sub.SBQQ__SegmentStartDate__c && revenue.Recognition_End_Date__c <= sub.SBQQ__SegmentEndDate__c){
                            overlapDays = sub.SBQQ__SegmentStartDate__c.daysBetween(revenue.Recognition_End_Date__c) + 1;
                        } else if (revenue.Recognition_Start_Date__c >= sub.SBQQ__SegmentStartDate__c && revenue.Recognition_End_Date__c <= sub.SBQQ__SegmentEndDate__c){
                            overlapDays = revenue.Recognition_Start_Date__c.daysBetween(revenue.Recognition_End_Date__c) + 1;
                        } else if (revenue.Recognition_Start_Date__c >= sub.SBQQ__SegmentStartDate__c && revenue.Recognition_End_Date__c > sub.SBQQ__SegmentEndDate__c){
                            overlapDays = revenue.Recognition_Start_Date__c.daysBetween(sub.SBQQ__SegmentEndDate__c) + 1;
                        } else if (revenue.Recognition_Start_Date__c < sub.SBQQ__SegmentStartDate__c && revenue.Recognition_End_Date__c > sub.SBQQ__SegmentEndDate__c){
                            overlapDays = sub.SBQQ__SegmentStartDate__c.daysBetween(sub.SBQQ__SegmentEndDate__c) + 1;
                        }
                        
                        System.debug('### Overlap Days: ' + overlapDays);
                        
                        //Calculate the Amount field
                        Decimal rangelistPrice = DailyListPriceAmount*overlapDays;
                        system.debug('@@@ rangelistPrice: ' + rangelistPrice);
                        combinedListPrice += rangelistPrice;
                        
                    }
                    
                }
                
            }
            
        }
        
        Revenue.List_Price__c = combinedListPrice;
        update Revenue;
        
    }
    
    
}