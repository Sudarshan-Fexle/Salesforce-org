/**
 * 
 *  Purpose         :   Helper class for the Subscription Adjustment object
 *
 *  Revision Logs   :   V_1.0 - Created     - Victor Hanson     - 01/10/2019 - CR-20160414-9762
 *			V_1.1 - Modified By - Subhash Garhwal   - 09/03/2020 - CR-20200818-14441
 *			V_1.2 - Modified By - Mahendra Swarnkar - 11/25/2020 - CR-20201105-14668
 * 			V_1.3 - Modified By - Abhinav Sharma    - 06/08/2021 - CR-20210113-14806 - Add blank check in "getProgramSubQueryString()"" method
 *			V_1.4 - Modified By - Subhash Garhwal   - 06/17/2021 - CR-20210315-14999
 *			V_1.5 - Modified By - Mahendra Swarnakar - 07/19/2021 - CR-20210809-15339
 *			V_1.6 - Modified By - Mahendra Swarnakar - 07/19/2021 - CR-20210719-15297
 * 
**/
public without sharing class SubscriptionAdjustmentHelper {
    
    //final variables
    public static final String SUBSCRIPTION_ADJUSTMENT_STATUS_APPROVED = 'Contracted';
    public static final String TYPE_UPSELL = 'Upsell';
    public static final String TYPE_FINAL_ADJUSTMENT = 'Final Adjustment';
    
    public static Boolean BYPASS_GAAP_NEGOTIATION_AMOUNT_POSTAGE_MEDIA = false;
    
    //Added by Mahendra Swarnkar - 05/11/2020 - CR-20200508-14032
    public static boolean hasExecutedSubAdjustment = false; 
    public static boolean ByPassOpportunityTriggerOnUpsells = false;
    
    //public variables
    public Map<Id, SBQQ__Subscription__c> mapProgramSubscriptionWithChildSubs { get; set; }
    public Map<Id, SBQQ__Subscription__c> mapParentProgramSubscription { get; set; }
    public List<Subscription_Adjustment__c> sAdjustments { get; set; }
    public Map<Id, SBQQ__Subscription__c> SPToProgramSubscriptionMap { get; set; }
    public Map<Id, Subscription_Adjustment__c> mapOldSAdjustments { get; set; }
    public boolean subscriptionAdjustmentExecuted = false;
    public boolean insertSubscriptions = false;
    
    //private variables
    private Map<Id, Subscription_Period__c> mapSubscriptionPeriods { get; set; }
    private Set<Id> parentProductIds { get; set; }
    private Set<Id> programSubIds { get; set; }
    private Set<Id> parentProgramSubIds { get; set; }
    private Map<Id, Subscription_Adjustment__c> mapProgramSubToSubscriptionAdjustment { get; set; }
    
    //map of each parent product's configuration attributes
    private Map<Id, List<ProductConfiguratorController.CustomAttribute>> productIdToCustomAttMap { get; set; }
    
    /**
     * 
     *  @description    :   Constructor that sets up all the data to be used by this class
     * 
     *  @Revision Logs  :   V1.1 - 01/10/2019 - Created - Victor Hanson - CR-20181019-12685
     * 
    **/
    public SubscriptionAdjustmentHelper(List<Subscription_Adjustment__c> sAdjustments, Map<Id, Subscription_Adjustment__c> mapOldSAdjustments) {
        
        if (subscriptionAdjustmentExecuted) return;
            subscriptionAdjustmentExecuted = true;
        
        //define variables
        this.mapOldSAdjustments = mapOldSAdjustments;
        this.sAdjustments = new List<Subscription_Adjustment__c>();
        parentProductIds = new Set<Id>();
        mapProgramSubToSubscriptionAdjustment = new Map<Id, Subscription_Adjustment__c>();
        SPToProgramSubscriptionMap = new Map<Id, SBQQ__Subscription__c>();
        programSubIds = new Set<Id>();
        parentProgramSubIds = new Set<Id>();
        
        this.sAdjustments = sAdjustments;
        
        if (mapOldSAdjustments != null) {
            for (Subscription_Adjustment__c sa : sAdjustments) {
                
                Subscription_Adjustment__c oldSA = mapOldSAdjustments.get(sa.Id);
                //if the subscription adjustment's status is updated to Approved, set insert flag to true
                if (sa.Status__c == SUBSCRIPTION_ADJUSTMENT_STATUS_APPROVED && (oldSA == null || (oldSA != null && sa.Status__c != oldSA.Status__c))) 
                {
                    insertSubscriptions = true;
                    break;
                }
            }
        }
        
        //get subscription periods with related records
        getProgramSubWithRelatedRecords();
        setDefaultFieldValues();
    }
    
    /**
     * 
     *  @description    :   populates program subscription and subscription period maps based on the related Subscription Period
     * 
     *  @Revision Logs  :   V1.1 - 01/10/2019 - Created - Victor Hanson - CR-20181019-12685
     * 
    **/
    public void getProgramSubWithRelatedRecords() {
        
        //get the subscription period ids
        Set<Id> sPeriodIds = new Set<Id>();
        for (Subscription_Adjustment__c sa : sAdjustments) {
            if (sa.Subscription_Period__c != null) {
                sPeriodIds.add(sa.Subscription_Period__c);
            }
        }
        if (sPeriodIds.size() == 0) return;
        
	// Modified By - Mahendra Swarnakar - 07/19/2021 - CR-20210719-15297
        mapSubscriptionPeriods = new Map<Id, Subscription_Period__c>([SELECT Id, Program_Subscription__c, Program_Subscription__r.SBQQ__RequiredByProduct__c, Program_Subscription__r.SBQQ__Product__c,
                                                                      Program_Subscription__r.Program_Subscription__c, Segment_Index__c
                                                                      FROM Subscription_Period__c
                                                                      WHERE Id IN :sPeriodIds]);
        
        for (Subscription_Period__c sp : mapSubscriptionPeriods.values()){
            SPToProgramSubscriptionMap.put(sp.Id, new SBQQ__Subscription__c(Id=sp.Program_Subscription__c));
            programSubIds.add(sp.Program_Subscription__c);
            parentProgramSubIds.add(sp.Program_Subscription__r.Program_Subscription__c); //get the top-level program subscription as well
            
	    //Modified By - Mahendra Swarnakar - 07/19/2021 - CR-20210719-15297
            if (sp != null && sp.Program_Subscription__c != null && sp.Program_Subscription__r.SBQQ__RequiredByProduct__c != null)
                parentProductIds.add(sp.Program_Subscription__r.SBQQ__RequiredByProduct__c);
        }
        
        //get the program subscription and child subscriptions
        List<SBQQ__Subscription__c> listProgramSubscriptionWithChildSubs = Database.query( getProgramSubQueryString() 
                                                              + 'WHERE Id IN :programSubIds '
                                                              + 'AND Subscription_Adjustment__c = null '
                                                              + 'AND SBQQ__Product__r.Allow_Subscription_Adjustments__c = true ');
							      /*+ 'AND Finance_Status__c = \'Active\' '
							      + 'AND SBQQ__Quantity__c > 0 '*/
        
        //get the parent program subscriptions
        List<SBQQ__Subscription__c> parentProgramSubs = Database.query( getProgramSubQueryString() 
                                                                       + ' WHERE Id IN :parentProgramSubIds');
        
        mapParentProgramSubscription = new Map<Id, SBQQ__Subscription__c>(parentProgramSubs);
        mapProgramSubscriptionWithChildSubs = new Map<Id, SBQQ__Subscription__c>(listProgramSubscriptionWithChildSubs);
        
        
    }
    
    /**
     * 
     *  @description    :   Returns dynamic query for Program Subscriptions, 
     *                      Component Subscriptions, and all of the Custom Configuration Attribute fields
     * 
     *  @Revision Logs  :   V1.1 - 01/10/2019 - Created - Victor Hanson - CR-20181019-12685
     * 
    **/
    public String getProgramSubQueryString() 
    {
        //Added By - Abhinav Sharma - 06/08/2021 - CR-20210113-14806 - Add blank check
        String tempconfigAttFields = '';
        String tempSAconfigAttFields = '';
        
        if(String.isNotBlank(configAttFields)) 
        {
            tempconfigAttFields = configAttFields + ',';
            tempSAconfigAttFields = ', ' + configAttFields;
        }
	
        //Modified By - Mahendra Swarnakar - 07/19/2021 - CR-20210719-15297
        String programSubQry = 'SELECT Id,SBQQ__RequiredByProduct__c,Program_Subscription__c,Subscription_Period__c,Top_Parent_Product__c,'
                                + 'Program_Subscription__r.SBQQ__Product__c, SBQQ__ProductName__c,SBQQ__Product__c,SBQQ__SegmentIndex__c, SBQQ__SegmentLabel__c,' 
                                + tempconfigAttFields
                                + '(SELECT Id, SBQQ__RequiredByProduct__c,Program_Subscription__r.SBQQ__RequiredByProduct__c,SBQQ__Quantity__c,SBQQ__ProductName__c,'
                                    + 'SBQQ__SegmentIndex__c, SBQQ__SegmentLabel__c, SBQQ__Contract__c,SBQQ__Account__c,SBQQ__SubscriptionStartDate__c,SBQQ__SubscriptionEndDate__c,'
                                    + 'SBQQ__SegmentStartDate__c,SBQQ__SegmentEndDate__c,Product_Code__c,Top_Parent_Product__c, Top_Related_Product__c,'
                                    + 'Status__c,Membership__c,Program__c,SBQQ__Product__c,Program_Subscription__r.SBQQ__Product__c, '
                                    + 'ES_Additional_Media_Cost_per_Thousand_m__c, ES_Additional_Postage_Cost_per_Thousan_m__c, Subscription_Period__c, ES_Additional_Program_Cost_per_Thousan_m__c '
                                    + tempSAconfigAttFields + ' FROM Subscriptions1__r WHERE Subscription_Adjustment__c = null '
                                    + 'AND (SBQQ__TerminatedDate__c = null OR SBQQ__TerminatedDate__c >= TODAY) '
                                    + 'AND Type__c != \''+ TYPE_UPSELL +'\' AND Type__c != \'' + TYPE_FINAL_ADJUSTMENT + '\') '
                                + 'FROM SBQQ__Subscription__c ';
        return programSubQry;
    }
    
    /**
     * 
     *  @description    :   Returns a comma delimited list of Configuration Attribute fields associated with Program Subscription Products
     * 
     *  @Revision Logs  :   V1.1 - 01/10/2019 - Created - Victor Hanson - CR-20181019-12685
     * 
    **/
    public String configAttFields {
        get {
            if (configAttFields == null) {
                List<String> allFields = new List<String>();
                Set<String> individualFields = new Set<String>(); //fields like Paper_New_Names__c
                Set<String> targetFields = new Set<String>(); //fields like Paper_New_Names_CSV__c
                
                productIdToCustomAttMap = ProductConfiguratorController.getConfigurationAttributes(parentProductIds);
                
                
                
                
                //cycle through the whole map, adding each field to a set
                for (List<ProductConfiguratorController.CustomAttribute> customAttList : productIdToCustomAttMap.values()) {
                    for (ProductConfiguratorController.CustomAttribute ca : customAttList) {
                        
                        //make sure the field exists on Subscription before adding
                        String individualField = getFieldAPIName(ca.attribute.CSV_Map_Field__c);
                        if (individualField != null) {
                            individualFields.add(individualField);
                        }

                        String targetField = getFieldAPIName(ca.attribute.SBQQ__TargetField__c);
                        if (targetField != null)  {
                            targetFields.add(targetField);
                        }
                    }
                }
                allFields.addAll(individualFields);
                allFields.addAll(targetFields);
                configAttFields = String.join(allFields, ',');
                
            }
            return configAttFields;
        }
        set;
    }

    /**
     * 
     *  @description    :   return either the original field name, or the mapped field value
     * 
     *  @Revision Logs  :   V1.1 - 04/02/2019 - Created - Victor Hanson - CR-20181019-12685
     * 
    **/
    private String getFieldAPIName(String fldAPIName) {
        if (qlToSubscriptionTwinFieldMap.containsKey(fldAPIName.toLowerCase())) {
            fldAPIName = qlToSubscriptionTwinFieldMap.get(fldAPIName.toLowerCase());
        }
        
        if (!subscriptionFieldAPINameSet.contains(fldAPIName.toLowerCase())) {
            //returns null if the field doesn't exist on subscription
            fldAPIName = null;
        }
        return fldAPIName;
    }
     
    /**
     * 
     *  @description    :   map of all custom twin fields mapped between QuoteLine and Subscription
     * 
     *  @Revision Logs  :   V1.1 - 04/02/2019 - Created - Victor Hanson - CR-20181019-12685
     *			    V1.2 - 09/03/20202 - Modified - Subhash Garhwal - CR-20200818-14441 - Apply SOQL query using the variable.
     * 
    **/
    public static Map<String, String> qlToSubscriptionTwinFieldMap {
        get {
            if (qlToSubscriptionTwinFieldMap == null) {
                qlToSubscriptionTwinFieldMap = new Map<String, String>();
                
                List<Field_Mapping_Value__mdt> fieldMappings = [SELECT Id, Source_Value__c, Target_Value__c FROM Field_Mapping_Value__mdt
                                                            WHERE Field_Mapping__r.DeveloperName = 'QuoteLine_to_Subscription' AND Source_Value__c != null];
                                                            
                for (Field_Mapping_Value__mdt twinField : fieldMappings) 
                {
                    qlToSubscriptionTwinFieldMap.put(twinField.Source_Value__c.toLowerCase(), twinField.Target_Value__c);
                }
            }
            
            
            return qlToSubscriptionTwinFieldMap;
        }
        set;
    }

    /**
     * 
     *  @description    :   get set of subscription field api names
     * 
     *  @Revision Logs  :   V1.1 - 01/10/2019 - Created - Victor Hanson - CR-20181019-12685
     * 
    **/
    private Set<String> subscriptionFieldAPINameSet {
        get {
            if (subscriptionFieldAPINameSet == null) {
                subscriptionFieldAPINameSet = new Set<String>();
                List<FieldDefinition> subscriptionFields = [Select QualifiedApiName FROM FieldDefinition 
                                                            WHERE EntityDefinition.QualifiedApiName ='SBQQ__Subscription__c' ORDER BY QualifiedApiName DESC];
                for (FieldDefinition fd : subscriptionFields)
                {
                    subscriptionFieldAPINameSet.add(fd.QualifiedApiName.toLowerCase());
                }
            }
            return subscriptionFieldAPINameSet;
        }
        set;
    }

    
    /**
     * 
     *  @description    :   Set default field values on insert
     * 
     *  @Revision Logs  :   V1.1 - 01/10/2019 - Created - Victor Hanson - CR-20181019-12685
     * 
    **/
    public void setDefaultFieldValues() {
        
        for (Subscription_Adjustment__c sa : sAdjustments) {
            //set the program subscription field
            sa.Program_Subscription__c = SPToProgramSubscriptionMap.get(sa.Subscription_Period__c).Id;
            mapProgramSubToSubscriptionAdjustment.put(sa.Program_Subscription__c, sa);
        }
    }
    
    public static boolean hasExecutedCloneCompSub = false;
    
    /**
     * 
     *  @description    :   clone each of the component subscriptions and update with the new paper/e-only values.
     *                      Also, set the revised subscription field so this new subscription doesn't get re-created as a duplicate on renewal/amendment
     * 
     *  @Revision Logs  :   V1.1 - 01/10/2019 - Created - Victor Hanson - CR-20181019-12685
     * 
    **/
    public void cloneComponentSubscriptions() {
        
        if (hasExecutedCloneCompSub) return;
        hasExecutedCloneCompSub = true;
        
        List<SBQQ__Subscription__c> subscriptionsToUpsert = new List<SBQQ__Subscription__c>();
        
        for (SBQQ__Subscription__c programSub : mapProgramSubscriptionWithChildSubs.values()) {
            
            Integer segmentIndex;
            Integer tempSegmentIndex;
            
            //get the Subscription Adjustment for this Program Sub
            
            Subscription_Adjustment__c sa = mapProgramSubToSubscriptionAdjustment.get(programSub.Id);
            
            if (programSub.Subscriptions1__r.size() == 0) {
                throw new customException('Cannot add subscription adjustment to Subscription Period where the related Program Subscription has '
                                        + 'no Subscriptions, or all subscriptions have Terminated Date populated.');
            }
            //clone each component subscription
            for (SBQQ__Subscription__c componentSub : programSub.Subscriptions1__r) {
            	    
                if (componentSub.SBQQ__SegmentIndex__c != null) tempSegmentIndex = Integer.valueOf(componentSub.SBQQ__SegmentIndex__c);
                
                //only continue if the segment index is the same as the one being adjusted
                if (mapSubscriptionPeriods.get(sa.Subscription_Period__c).Segment_Index__c == tempSegmentIndex) {
                    
                    //set the segment index -- this is used later to determine which year value is updated in the CSV field
                    segmentIndex = tempSegmentIndex;
                    
                    SBQQ__Subscription__c clonedSubscription = componentSub.clone();
                    clonedSubscription.Subscription_Adjustment__c = sa.Id;
                    
                    //VH commented out 6/12/2019-this field causes errors when populated outside the normal CPQ process and attempting to amend
                    //set the revised subscription field so this new subscription doesn't get re-created as a duplicate on renewal/amendment
                    //clonedSubscription.SBQQ__RevisedSubscription__c = componentSub.Id;
                    
		    //Modified By - Mahendra Swarnakar - 07/19/2021 - CR-20210719-15297
                    //VH added 6/12/2019 to fix an error when attempting to ammend after a Subscription Adjustment is contracted
                    clonedSubscription.SBQQ__SubscriptionType__c = 'One-time';
                    clonedSubscription.SBQQ__ProductSubscriptionType__c = 'One-time';
                    clonedSubscription.SBQQ__SegmentLabel__c = componentSub.SBQQ__SegmentLabel__c;
                    
                    //update the field values for the cloned subscription
                    setCustomAttributes(sa, clonedSubscription, null, 'clone');
                    
                    //update the custom attributes for the original subscription (original qty + upsell qty)
                    setCustomAttributes(sa, componentSub, null, 'original');
                    
                    //add both the clone and original subscription to the list to be upserted
                    subscriptionsToUpsert.add(clonedSubscription);
                    subscriptionsToUpsert.add(componentSub);
                }
            }
            
            //get the top-level parent subscription
            SBQQ__Subscription__c parentSub = mapParentProgramSubscription.get(programSub.Program_Subscription__c);
            
            
            //get the attributes for the programSub
            List<ProductConfiguratorController.CustomAttribute> attributes = getAttributes(programSub);
            
            //update the custom attributes for the original subscription (original qty + upsell qty)
            setCustomAttributes(sa, parentSub, attributes, segmentIndex, 'program');
            
            //add program subscription to the list to be upserted, since we also updated the custom attribute CSV fields
            //Modified By - Mahendra Swarnakar - 09/22/2021 CR-20210719-15297 add null check
            if(parentSub != null){
                subscriptionsToUpsert.add(parentSub);
            }
        }
        
        if (insertSubscriptions && subscriptionsToUpsert.size() > 0) {
            
            //bypass proposal triggers to save SOQL queries
            ContractTriggerHelper.BYPASS_PROPOSAL_AND_LINES_TRIGGER = true;
            
            // Added Check to Bypass the Contract trigger methods for renewal proposals - By Mahendra Swarnkar - 11/25/2020 - CR-20201105-14668
            ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL = true;
            
            SubscriptionAdjustmentHelper.BYPASS_GAAP_NEGOTIATION_AMOUNT_POSTAGE_MEDIA = true;
            
            //util.BypassAllTriggers = true;
            //SBQQ_SubscriptionTriggerHelper.populateAmendmentPriceOverride(subscriptionsToUpsert);
            //Added by Mahendra Swarnkar - 05/11/2020 - CR-20200508-14032
            hasExecutedSubAdjustment = true;
            
            upsert subscriptionsToUpsert[0];
            
            // instantiate a new instance of the Queueable class
            //EnqueueSubscriptionAdjustmentHelper updateJob = new EnqueueSubscriptionAdjustmentHelper(subscriptionsToUpsert[0]);
            // enqueue the job for processing
            //ID jobID = System.enqueueJob(updateJob);
        }
    }
    
    /**
     * 
     *  @description    :   overloaded method to set custom attributes associated with the program subscription's product
     * 
     *  @Revision Logs  :   V1.1 - 01/10/2019 - Created - Victor Hanson - CR-20181019-12685
     * 
    **/
    private void setCustomAttributes(Subscription_Adjustment__c sa, SBQQ__Subscription__c subscription, Integer segmentIndex, String type) {
    	setCustomAttributes(sa, subscription, null, segmentIndex, type);
    }
    
    private Set<Id> subscriptionAdjustmentsCheckedForRecalc = new Set<Id>();
    
    /**
     * 
     *  @description    :   checks to see if the Subscription Adjustment's Program/Postage/Media Cost has been manually overridden
     * 
     *  @Revision Logs  :   V1.1 - 01/30/2019 - Created - Victor Hanson - CR-20181019-12685
     * 
    **/
    private void checkRecalculation(Subscription_Adjustment__c sa, Subscription_Adjustment__c oldSA) {
        
        if (subscriptionAdjustmentsCheckedForRecalc.contains(sa.Id)) return;
        subscriptionAdjustmentsCheckedForRecalc.add(sa.Id);
        
        //get the old program/postage/media costs
        Decimal oldpaper = oldSA.Paper__c == null ? 0 : oldSA.Paper__c;
        Decimal oldeOnly = oldSA.E_Only__c == null ? 0 : oldSA.E_Only__c;
        Decimal oldQuantity = oldSA.Quantity__c == null ? 0 : oldSA.Quantity__c;
        
        Decimal oldCostPerThousand = oldSA.Program_Cost_Per_Thousand__c == null ? 0 : oldSA.Program_Cost_Per_Thousand__c;
        Decimal oldPostageCostPerThousand = oldSA.Postage_Cost_Per_Thousand__c == null ? 0 : oldSA.Postage_Cost_Per_Thousand__c;
        Decimal oldMediaCostPerThousand = oldSA.Media_Cost_Per_Thousand__c == null ? 0 : oldSA.Media_Cost_Per_Thousand__c;
        
        Decimal oldProgramCost_calculated;
        Decimal oldPostageCost_calculated;
        Decimal oldMediaCost_calculated;
        
        if(oldQuantity != 0){
        	oldProgramCost_calculated = getCalculatedPrice(oldQuantity, oldCostPerThousand);    
            	oldPostageCost_calculated = getCalculatedPrice(oldQuantity, oldPostageCostPerThousand);
        	oldMediaCost_calculated = getCalculatedPrice(oldQuantity, oldMediaCostPerThousand);
        } else {
            	oldProgramCost_calculated = getCalculatedPrice(oldpaper + oldeOnly, oldCostPerThousand);
            	oldPostageCost_calculated = getCalculatedPrice(oldpaper, oldPostageCostPerThousand);
        	oldMediaCost_calculated = getCalculatedPrice(oldpaper + oldeOnly, oldMediaCostPerThousand); 
        }
        
        boolean quantityHasChanged = false;
        if (sa.Paper__c != oldSA.Paper__c || sa.E_Only__c != oldSA.E_Only__c || sa.Quantity__c != oldSA.Quantity__c) {
            quantityHasChanged = true;
        }
        
        //if quantity has not been changed & program/postage/media costs have changed manually, do not re-calculate cost
        if (!quantityHasChanged && (sa.Price_Override__c 
            || (oldPostageCost_calculated != null && oldPostageCost_calculated.setscale(2) != sa.Postage_Cost__c) 
            || (oldMediaCost_calculated != null && oldMediaCost_calculated.setscale(2) != sa.Media_Cost__c && sa.Include_Media_cost__c == 'Yes' && sa.Media_Cost__c != 0)
            || (oldProgramCost_calculated != null && oldProgramCost_calculated.setscale(2) != sa.Program_Cost__c)))
        {
            sa.Price_Override__c = true;
        }
        else {
            sa.Price_Override__c = false;
        }
    }
    
    /**
     * 
     *  @description    :   populate the Component Subscription details on each of the cloned records.
     *                       Also, if the final year of the contract is being adjusted,
     *                       updates the existing CPQ Program Subscription's CSV value to contain the updated value,
     *                       so renewals are created with the correct quantities.
     *                      ie: Y4 Paper Inquiry Pool updated with Paper+=1500, Paper_Inquiry_Pool_CSV__c = {Paper_Inquiry_Pool__c:2500,2500,2500}
     * 
     *  @Revision Logs  :   V1.1 - 01/10/2019 - Created - Victor Hanson - CR-20181019-12685
     *                      V1.2 - 10/02/2020 - Modifed - Colin McGloin - Added ALR logic to allow Student Journey/High Affinity Products to use SA
     * 
    **/
    private void setCustomAttributes(Subscription_Adjustment__c sa, 
                                     SBQQ__Subscription__c subscription,
                                     List<ProductConfiguratorController.CustomAttribute> attributes, 
                                     Integer segmentIndex, 
                                     String type)
    {
    	
    	Subscription_Adjustment__c oldSA;
        if (mapOldSAdjustments != null && mapOldSAdjustments.containsKey(sa.Id)) {
            oldSA = mapOldSAdjustments.get(sa.Id);
            //sets recalculatecosts to false if cost is manually overridden
            checkRecalculation(sa, oldSA);
        }
        
        if (attributes == null) {
            attributes = getAttributes(subscription);
        }
        
        boolean setOriginalQuantity = false;
        if (sa.Original_Quantity__c == null || sa.Original_Quantity__c == 0) {
            setOriginalQuantity = true;
            sa.Original_Quantity__c = 0;
        }
        
        //set of fields that correspond to this product (ie: New Names or PRE Names fields)
        Set<String> applicableFields = new Set<String>();
        SBQQ__Subscription__c saProgramSubscription = mapProgramSubscriptionWithChildSubs.get(SPToProgramSubscriptionMap.get(sa.Subscription_Period__c).Id);
        
        //get the set of applicable fields based on Product
        applicableFields = CPQConstants.MAP_PRODUCT_NAME_TO_ADJUSTABLE_QUANTITY_FIELDS.get(saProgramSubscription.SBQQ__ProductName__c);
        
        //Added check for size - 07/19/2021 - CR-20210719-15297
        if(attributes != null && attributes.size() > 0){
            for (ProductConfiguratorController.CustomAttribute ca : attributes) {
            
            	//skip if this field is not part of the Product the user is adjusting
            	if (applicableFields == null || !applicableFields.contains(ca.attribute.SBQQ__TargetField__c)) {
                    continue;
            	}
            
            	boolean isPaper = false;
            	boolean isEOnly = false;
            	boolean ALR = false;
            
            	//Added for CR-20210315-14999 - 17/06/2021
            	boolean isQuantity = false;
            
            	String attFieldName = getFieldAPIName(ca.attribute.CSV_Map_Field__c);
            	if (attFieldName == null) continue; //VH 4/2/2019 - skip if field is not on subscription
            	String targetFieldName = getFieldAPIName(ca.attribute.SBQQ__TargetField__c);
            	if (targetFieldName == null) continue; //VH 4/2/2019 - skip if field is not on subscription
            
            	//make sure the attribute matches the subscription adjustment product name
            	if (ca.attribute.CSV_Map_Product__r.name != sa.Product__c) continue;
            
            	if (attFieldName.containsIgnoreCase('PAPER')) {
                    isPaper = true;
            	}
            	else if (attFieldName.containsIgnoreCase('E_ONLY')) {
                    isEOnly = true;
            	} 
            	else if (attFieldName.containsIgnoreCase('Student_Journey_Quantity') || attFieldName.containsIgnoreCase('High_Affinity_Audience_Quantity')){
            	    ALR = true;
            	}
            	// added for CR-20210315-14999 - 17/06/2021
            	else if (attFieldName.containsIgnoreCase('Deposit_IQ_Quantity') || attFieldName.containsIgnoreCase('Yield_IQ_Quantity') || attFieldName.containsIgnoreCase('Guaranteed_Inquiries')
            	         || attFieldName.containsIgnoreCase('Candidate_Names')){
                    isQuantity = true;
            	}
            
            	//skip if this isn't paper or e-only, since those are the only 2 fields that can be updated via this process
            	if ((!isPaper && !isEOnly && !ALR && !isQuantity)) continue;
            
            	//return the api name for the paper or e-only field on Subscription Adjustment
            	//Updated by Colin McGloin - Modified since we're adding ALR which combines both Paper and E-Only and maps that over
            	String saFieldName;
            	if (isPaper){
                    saFieldName = 'Paper__c';
            	} else if (isEOnly){
                    saFieldName = 'E_Only__c';
            	} else if (ALR){
                    saFieldName = 'Total_Quantity__c';
            	}
            	//Added for CR-20210315-14999 - 17/06/2021
            	else if(isQuantity){
                    saFieldName = 'Quantity__c';
            	}
            
            	if (type == 'clone') {
                    subscription.Subscription_Adjustment__c = sa.Id; 
                    subscription.put(attFieldName, (Decimal)sa.get(saFieldName));
                    //subscription.Type__c = sa.Type__c;
                
                
                    //9/23/2020 - Subhash Garhwal - CR-20200818-14441
                    //if (!sa.Price_Override__c || subscription.Product_Code__c.containsIgnoreCase('PROGRAM')) {
                    
                    //Commented By Mahendra on 07/19/2021 - CR-20210719-15297- Moved the logic in setCustomAttributesPopulateSubscriptionFields method -  Starts from here
                    /*
                    subscription.Type__c = sa.Type__c;

                    //set the price
                    Decimal price = getPrice(sa, subscription);
                    subscription.SBQQ__SpecialPrice__c = sa.List_Price__c;
                    subscription.SBQQ__CustomerPrice__c = sa.Program_Cost_Customer_Amount__c;
                    subscription.SBQQ__ListPrice__c = sa.List_Price__c;
                    subscription.SBQQ__AdditionalDiscountAmount__c = sa.Program_Cost_Discount__c;
                    subscription.Postage_Costs_m__c = sa.Postage_Cost__c;
                    subscription.Media_Costs_m__c = sa.Media_Cost__c;
                    //Added by Mahendra Swarnkar - 05/11/2020 - CR-20200508-14032
                    subscription.Contract_Signature_Date__c = sa.Contract_Signature_Date__c;
                    */
                    //Commented By Mahendra on 07/19/2021 - CR-20210719-15297- Moved the logic in setCustomAttributesPopulateSubscriptionFields method - Ends here
                    //}
            	}
            	else if (type == 'original') {
                
                    //update the original subscription's quantity field with the original + new quantity
                    Decimal originalVal = (Decimal)subscription.get(attFieldName) == null ? 0 : (Decimal)subscription.get(attFieldName);
                
                    Decimal newVal = (Decimal)sa.get(saFieldName) == null ? 0 : (Decimal)sa.get(saFieldName);
                
                    //Commented By Mahendra on 07/19/2021 - CR-20210719-15297- Moved the logic in setCustomAttributesPopulateSubscriptionFields method -  Starts from here
                    //Added by Mahendra Swarnkar - 05/11/2020 - CR-20200508-14032
                    //subscription.Contract_Signature_Date__c = sa.Contract_Signature_Date__c;
                    //Commented By Mahendra on 07/19/2021 - CR-20210719-15297- Moved the logic in setCustomAttributesPopulateSubscriptionFields method -  Ends here
                    subscription.put(attFieldName, originalVal + newVal);
            	}
            	else if (type == 'program') {
                    //ie: update the CSV field's value like: {"Paper_Inquiry_Pool__c":"1000|1000|1000"}
                    //ie: ca.attribute.SBQQ__TargetField__c = Paper_Inquiry_Pool_CSV__c
                
                    String originalVal = (String)subscription.get(targetFieldName); 
                
                    Map<String, Object> obj = new Map<String, Object>();
                    try {
                    	obj = (Map<String, Object>)JSON.deserializeUntyped(originalVal);
                    }
                    catch(Exception e) {
                    	system.debug('@@json parse error: '+e.getMessage());
                    continue;
                    }
                
                    String s = (String)obj.get('yearValues'); // ie: ca.attribute.CSV_Map_Field__c = Paper_Inquiry_Pool__c
                    List<String> listYears = s.split('\\|');
                    List<Decimal> listYearsDecimal = new List<Decimal>();
                    for (String y : listYears) {
                        listYearsDecimal.add(decimal.valueOf(y));
                    }
                
                    //set the original quantity
                    if (setOriginalQuantity && listYearsDecimal.size() > 0 && listYearsDecimal.size() >= segmentIndex)
                        sa.Original_Quantity__c += listYearsDecimal[segmentIndex-1];
                
                    //if the quantity for the final year is updated, set the new quantity for all years.
                    //  This allows the renewal to be created with the same quantity as the previous year.
                    if (listYearsDecimal.size() == segmentIndex) {
                    	//add the upsell amount to each year
                    	for (Integer i = 0; i < listYearsDecimal.size(); i++) {
                            //Null check - Added by Colin McGloin
                            if ((Decimal)sa.get(saFieldName) != null){
                                listYearsDecimal[i] += (Decimal)sa.get(saFieldName);
                    	    }
                        
                    	}
                    	String newValue = '{"' + attFieldName + '":"' + String.join(listYearsDecimal, '|') + '"}';
                    	subscription.put(targetFieldName, newValue);
                    }
                }
            }
	} 
        //Added By Mahendra on 07/19/2021 - CR-20210719-15297 
        setCustomAttributesPopulateSubscriptionFields(sa, subscription, type);
    }
    
    //Added By Mahendra on 07/19/2021 - CR-20210719-15297 
    private void setCustomAttributesPopulateSubscriptionFields(Subscription_Adjustment__c sa, SBQQ__Subscription__c subscription, String type) {
        
        if( sa != null && subscription != null) {
        
            if (type == 'clone') {
                
                subscription.Type__c = sa.Type__c;
                
                //set the price
                Decimal price = getPrice(sa, subscription);
                subscription.SBQQ__SpecialPrice__c = sa.List_Price__c;
                subscription.SBQQ__CustomerPrice__c = sa.Program_Cost_Customer_Amount__c;
                subscription.SBQQ__ListPrice__c = sa.List_Price__c;
                subscription.SBQQ__AdditionalDiscountAmount__c = sa.Program_Cost_Discount__c;
                subscription.Postage_Costs_m__c = sa.Postage_Cost__c;
                subscription.Media_Costs_m__c = sa.Media_Cost__c;
                subscription.Contract_Signature_Date__c = sa.Contract_Signature_Date__c;
            }
            else if (type == 'original') {
                subscription.Contract_Signature_Date__c = sa.Contract_Signature_Date__c;
            }
        }
    }
    
    /**
     * 
     *  @description    :   returns the price for each Program/Postage/Media Component Subscription
     * 
     *  @Revision Logs  :   V1.1 - 01/10/2019 - Created - Victor Hanson - CR-20181019-12685
     * 
    **/
    private Decimal getPrice(Subscription_Adjustment__c sa, SBQQ__Subscription__c sub) {
        Decimal price;
        Decimal paperQty = sa.Paper__c == null ? 0 : sa.Paper__c;
        Decimal eOnlyQty = sa.E_Only__c == null ? 0 : sa.E_Only__c;
        Decimal quantity = sa.Quantity__c == null ? 0 : sa.Quantity__c;
        
        //if the price is overridden, take the override price
        if (sub.Product_Code__c != null) {
            
            Decimal adjustmentQty;
            
            //set the program cost per thousand on Subscription Adjustment
            sa.Program_Cost_Per_Thousand__c = sub.ES_Additional_Program_Cost_per_Thousan_m__c;
            //set the program price
            if (sa.Program_Cost__c == null || !sa.Price_Override__c) {
                // Modified By - Mahendra Swarnakar - 07/19/2021 - CR-20210809-15339
                if(sa.Quantity__c != null){
                    	//program price is calculated using Paper + E-Only
                	price = getCalculatedPrice(quantity, sub.ES_Additional_Program_Cost_per_Thousan_m__c);
                } else {
                	//program price is calculated using Paper + E-Only
                	price = getCalculatedPrice(paperQty + eOnlyQty, sub.ES_Additional_Program_Cost_per_Thousan_m__c);    
                }
                
                sa.Program_Cost__c = price;
            }
            
            //set the postage cost per thousand on Subscription Adjustment
            sa.Postage_Cost_Per_Thousand__c = sub.ES_Additional_Postage_Cost_per_Thousan_m__c;
            
            //set the postage price
            if (sa.Postage_Cost__c == null || !sa.Price_Override__c) {
                // Modified By - Mahendra Swarnakar - 07/19/2021 - CR-20210809-15339
                if(sa.Quantity__c != null){
                    	//postage is calculated only using the Paper quantity
                	price = getCalculatedPrice(quantity, sub.ES_Additional_Postage_Cost_per_Thousan_m__c);
                }else {
                	//postage is calculated only using the Paper quantity
                	price = getCalculatedPrice(paperQty, sub.ES_Additional_Postage_Cost_per_Thousan_m__c);    
                }
                
                //Modified By - Mahendra Swarnkar - 05/25/2020 - CR-20200522-14085 -
                if(sa.RecordTypeId != Util.RecordTypeId('Subscription_Adjustment__c', 'Final Invoice Adjustment')
                   || ((paperQty != 0 || eOnlyQty != 0 || quantity != 0) && sa.RecordTypeId == Util.RecordTypeId('Subscription_Adjustment__c', 'Final Invoice Adjustment'))){
                    sa.Postage_Cost__c = price;   
                }
            }
            
                
            //set the postage cost per thousand on Subscription Adjustment
            sa.Media_Cost_Per_Thousand__c = sub.ES_Additional_Media_Cost_per_Thousand_m__c;
            
            // Updated By Mahendra Swarnkar - 06/12/2019 - Added check for Include_Media_cost__c field so that when Include_Media_cost__c is false, Media_Cost__c should calculate to 0. 
            //set the media price
            if(sa.Include_Media_cost__c == 'No'){
                sa.Media_Cost__c = 0;
            } else{
            	
                if (sa.Media_Cost__c == null || sa.Media_Cost__c == 0 || !sa.Price_Override__c) {
                    // Modified By - Mahendra Swarnakar - 07/19/2021 - CR-20210809-15339
                    if(sa.Quantity__c != null){
                        //media price is calculated using Paper + E-Only
                    	price = getCalculatedPrice(quantity, sub.ES_Additional_Media_Cost_per_Thousand_m__c);
                    } else {
                    	//media price is calculated using Paper + E-Only
                    	price = getCalculatedPrice(paperQty + eOnlyQty, sub.ES_Additional_Media_Cost_per_Thousand_m__c);    
                    }
                    
                    //Modified By - Mahendra Swarnkar - 05/25/2020 - CR-20200522-14085 
                    if(sa.RecordTypeId != Util.RecordTypeId('Subscription_Adjustment__c', 'Final Invoice Adjustment')
                       || ((paperQty != 0 || eOnlyQty != 0 || quantity != 0) && sa.RecordTypeId == Util.RecordTypeId('Subscription_Adjustment__c', 'Final Invoice Adjustment'))){
                       	sa.Media_Cost__c = price;
                    }
                }
            }
            
            //Added by Colin McGloin - 05/28/2020
            //Set any of Cost fields to $0 if they are null
            if (sa.Program_Cost__c == null){
                sa.Program_Cost__c = 0;
            }
            if (sa.Postage_Cost__c == null){
                sa.Postage_Cost__c = 0;
            }
            if (sa.Media_Cost__c == null){
                sa.Media_Cost__c = 0;
            }


            price = sa.Program_Cost__c + sa.Postage_Cost__c + sa.Media_Cost__c;
        }
                
        return price;
    }
    
    /**
     * 
     *  @description    :   returns calculated price based on quantity and cost per thousand
     * 
     *  @Revision Logs  :   V1.1 - 01/10/2019 - Created - Victor Hanson - CR-20181019-12685
     * 
    **/
    private Decimal getCalculatedPrice(Decimal quantity, Decimal costPerThousand) {
        if (costPerThousand == null || quantity == null) return 0;
        return ((quantity/1000) * costPerThousand).setscale(2);
    }
    
    /**
     * 
     *  @description    :   get a list of product configuration attributes
     * 
     *  @Revision Logs  :   V1.1 - 01/10/2019 - Created - Victor Hanson - CR-20181019-12685
     * 
    **/
    public List<ProductConfiguratorController.CustomAttribute> getAttributes(SBQQ__Subscription__c subscription) {
        
        //Modified By Mahendra on 07/19/2021 - CR-20210719-15297 - Added Null check - Starts from here
        List<ProductConfiguratorController.CustomAttribute> attributes;
        
        if(subscription != null && subscription.SBQQ__RequiredByProduct__c != null) {
        	
            //get the custom attributes from either the parent product or the program subscription's parent product
            attributes = productIdToCustomAttMap.get(subscription.SBQQ__RequiredByProduct__c);
            
            if (attributes == null && subscription.Program_Subscription__c != null) {
                attributes = productIdToCustomAttMap.get(subscription.Program_Subscription__r.SBQQ__RequiredByProduct__c);
            }
        }
        //Modified By Mahendra on 07/19/2021 - CR-20210719-15297 - Added Null check - Ends here

        return attributes;
    }
    
}