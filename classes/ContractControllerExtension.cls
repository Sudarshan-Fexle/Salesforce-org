/**
 *  Desription      :   Standard Controller for Subscription Detail Page.
 * 
 *  Created By      :   Colin McGloin
 * 
 *  Created Date    :   04/18/2017
 * 
 *  Revision Logs   :   V1.0 - Created - 04/18/2017 - CR-20170403-10807
 *                      V1.1 - Added By Deepak Kumar - 5/26/2017 - Q2C Phase 2 - CR-20170403-10807
 * 			V1.2 - Modified By Deepak Kumar - 08/25/2017 - Issue--CR10808--QA--00005243
 *			V1.3 - Modified By - Subhash Garhwal - 03/27/2018 - CR-20180212-12039 - Changed where close for Program Subscription
 *			V1.4 - Modified By - Subhash Garhwal - 04/10/2018 - CR-20180410-12156 - Added record type check in listProgComponentSubscriptions method
 *			V1.5 - Modified By - Subhash Garhwal - CR-20180516-12227 - 05/16/2018 - Call a Future method to run a trigger of Subscription period.
 *			V1.6 - Modified By - Subhash Garhwal - CR-20181114-12751 - 011/15/2018 - Updated the methods to pull Offer type subscriptions in the "program subscriptions" related list.
 *			V1.7 - Modified By - Victor Hanson - CR-20181019-12685 - 12/17/2018 - Modified totalProgramSubscriptionCount to include Products where Program Subscription Override = true
 **/

public with sharing class ContractControllerExtension {
	
    //Subscription record
    public Contract contract {get; set;}
    public integer displayCount1 { get; set; }
    public integer displayCount2 { get; set; }
    public integer displayCount3 { get; set; } 
    
    //variable to check if any record is selected or not
    public Boolean isSelected {get; set;}
    public Boolean manageMode {get; set;}
    
    public integer rowNumber {get; set;}
    
    //List to manage the subscription, subscription period and calculation 
    public List <ContractControllerWrappper> contractControllerWrapperList {get; set;}
    
    //Property to check if the currrent logged in user have the license of Managed Package.
    Public Boolean isCPQLicenseUser {get;set;}
    public String CPQ_NAMESPACE = 'SBQQ';
    
    //Standard Controller Constructor
    public ContractControllerExtension(ApexPages.StandardController stdController) {
        contract = (contract)stdController.getRecord();
        
        //Default our three custom related lists to show 5 records
        displayCount1 = 5;
        displayCount2 = 5;
        displayCount3 = 5;
        isSelected = false;
        manageMode = false;
        
        //Check if the CPQ license User.
        isCPQLicenseUser = Util.checkManagedPackageAccess(UserInfo.getUserId(), CPQ_NAMESPACE);
        
        if(!isCPQLicenseUser)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'CPQ License is required to see the records.'));
		
        //Call the init method
        inIt();
        
    }
	
	//Map to hold the new Subscription Period to update the renewal owner on Subscription and Subscription Period - CR-20180502-12199
	//Added by Subhash Garhwal 06/14/2018 
	public Map<Id, Subscription_Period__c> mapSubscriptionPeriod = new Map<Id, Subscription_Period__c>();
	
	
        /**
     *  @description    :   Returns a sorted list of Program Subscriptions
     *
     *  @args           :    
     *
     *  @return         :   list<Program Subscription>
     *
     *	@Revision Log	:	V1.1 - Modified By - Subhash Garhwal - 03/27/2018 - CR-20180212-12039 - Changed where close for Program Subscription
     *							   Removed SBQQ__Product__r.SBQQ__Component__c = FALSE check and added RecordType.DeveloperName = Program check
	 *						V1.2 - Modified By - Subhash Garhwal - CR-20181114-12751 - 011/15/2018 - Changed where close for Program Subscription
     * 							   added RecordType.DeveloperName = Offer check 
     *
     **/
    public list<SBQQ__Subscription__c> listProgSubscriptions {
        get {
            if (listProgSubscriptions == null) {
                string qry = 'SELECT ' 
                    + fieldSetQryString('SBQQ__Subscription__c', 'ProgSubscriptionRelatedList') 
                    + ' FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c = \'' + contract.Id + '\' AND  (RecordType.DeveloperName = \'Program\' OR RecordType.DeveloperName = \'Offer\')  ORDER BY Name ASC LIMIT ' + displayCount1;
                listProgSubscriptions = database.query(qry);
            }
            return listProgSubscriptions;
        }
        set;
    }


    /**
     *  @description    :   Returns total number of related Program Subscription records
     *
     *  @args           :    
     *
     *  @return         :   integer
     * 
     * 	@revision log	: 12/17/2018 - Modified - VH - added logic to include Products where Program Subscription Override is true
     *
     **/
    public integer totalProgramSubscriptionCount {
        get {
            if (totalProgramSubscriptionCount == null) {
                totalProgramSubscriptionCount = [SELECT COUNT() FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c = :contract.Id AND 
                                                 (SBQQ__Product__r.SBQQ__Component__c = FALSE OR SBQQ__Product__r.Program_Subscription_Override__c = TRUE)];
            }
            return totalProgramSubscriptionCount;
        }
        set;
    }


    /**
     *  @description    :   adds 5 to the number of visible records on the first related List
     *
     *  @args           :    
     *
     *  @return         :   
     *
     **/
    public void showMoreRelatedList1() {
        displayCount1 = displayCount1 + 5;
        listProgSubscriptions = null;
    }

    /**
     *  @description    :   Returns a sorted list of Subscription Periods
     *
     *  @args           :    
     *
     *  @return         :   list<Program Subscription>
     *
     **/
    public list<Subscription_Period__c> listSubscriptionPeriods {

        get {
            if (listSubscriptionPeriods == null) {
                string qry = 'SELECT ' 
                    + fieldSetQryString('Subscription_Period__c', 'SubscriptionPeriodRelatedList') +' , Research_Strategic_Leader__c'+
                    + ' FROM Subscription_Period__c WHERE Contract__c = \'' + contract.Id + '\' ORDER BY Segment_Index__c ASC NULLS LAST LIMIT ' + displayCount2;
                listSubscriptionPeriods = database.query(qry);
            }
			
			//Size check
			if(listSubscriptionPeriods.size() > 0)
			
				//Adding value into the map to update renewal owner on Subscription and Subscription Period
				mapSubscriptionPeriod = new Map<Id, Subscription_Period__c>(listSubscriptionPeriods);
			
            return listSubscriptionPeriods;
        }
        set;
    }


    /**
     *  @description    :   Returns total number of related Program Component Subscription records
     *
     *  @args           :    
     *
     *  @return         :   integer
     *
     **/
    public integer totalSubscriptionPeriodCount {
        get {
            if (totalSubscriptionPeriodCount == null) {
                totalSubscriptionPeriodCount = [SELECT COUNT() FROM Subscription_Period__c WHERE Contract__c = :contract.Id];
            }
            return totalSubscriptionPeriodCount;
        }
        set;
    }


    /**
     *  @description    :   adds 5 to the number of visible records on the second related List
     *
     *  @args           :    
     *
     *  @return         :   
     *
     **/
    public void showMoreRelatedList2() {
        displayCount2 = displayCount2 + 5;
        listSubscriptionPeriods = null;
    }


    /**
     *  @description    :   Returns a sorted list of Program Subscriptions
     *
     *  @args           :    
     *
     *  @return         :   list<Program Subscription>
     *
     **/
    public list<SBQQ__Subscription__c> listProgComponentSubscriptions {
        get {
            if (listProgComponentSubscriptions == null) {
                string qry = 'SELECT ' 
                    + fieldSetQryString('SBQQ__Subscription__c', 'ProgComponentsRelatedList') 
                    + ' FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c = \'' + contract.Id + '\' AND RecordType.DeveloperName = \'Component\' ORDER BY SBQQ__SegmentStartDate__c ASC NULLS LAST, Program_Code__c ASC NULLS LAST, SBQQ__Product__r.Name ASC NULLS LAST LIMIT ' + displayCount3;
                listProgComponentSubscriptions = database.query(qry);
            }
            return listProgComponentSubscriptions;
        }
        set;
    }


    /**
     *  @description    :   Returns total number of related Program Component Subscription records
     *
     *  @args           :    
     *
     *  @return         :   integer
     *
     **/
    public integer totalProgramComponentSubscriptionCount {
        get {
            if (totalProgramComponentSubscriptionCount == null) {
                totalProgramComponentSubscriptionCount = [SELECT COUNT() FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c = :contract.Id AND SBQQ__Product__r.SBQQ__Component__c = TRUE];
            }
            return totalProgramComponentSubscriptionCount;
        }
        set;
    }
    

    /**
     *  @description    :   adds 5 to the number of visible records on the third related List
     *
     *  @args           :    
     *
     *  @return         :   
     *
     **/
    public void showMoreRelatedList3() {
        displayCount3 = displayCount3 + 5;
        listProgComponentSubscriptions = null;
    }

   /**
     *  @description    :   inIt method, call on the page load   
     *                                  
     *  @args           :   
     *
     *  @return         :   void 
     *  
     *  @Revision Log   :   V1.1 - 5/26/2017 - Created - CR-20170403-10807 - Deepak Kumar
     * 						V1.2 - Modified By - Subhash Garhwal - CR-20181114-12751 - 011/15/2018 - Changed where close for Program Subscription
     * 							   added RecordType.DeveloperName = Offer check
     *
     **/
    public void inIt() {
        
        
        
        //Initialize properties 
        contractControllerWrapperList = new List<ContractControllerWrappper>();
        
        //temp variable
        transient integer cntVal = 0;
        
        //Map to hold the Program Subscription details
        Map<Id, ContractControllerWrappper> mapProgramSubscriptions = new Map<Id, ContractControllerWrappper>();
        
        //V1.2 - Modified By - Subhash Garhwal - CR-20181114-12751 - 011/15/2018 - Changed where close to add RecordType.DeveloperName = Offer
        //Populate the subscriptionList
        for(SBQQ__Subscription__c proSub : [Select Id, Name, SBQQ__Product__c, SBQQ__StartDate__c, SBQQ__EndDate__c, Status__c, SBQQ__RequiredByProduct__c,
                                        Renewal_Owner__c, Negotiated_Amount_Subscription__c, Opt_Out__c, Opt_out_Notice_Date__c From SBQQ__Subscription__c
                                        Where SBQQ__Contract__c =: contract.Id AND (RecordType.DeveloperName = 'Program' OR RecordType.DeveloperName = 'Offer')]) {
            
            //Populate the subscription list
            ContractControllerWrappper proramSubscriptions = new ContractControllerWrappper(proSub, false, cntVal);
                                            
            //Add vlaues in map
            mapProgramSubscriptions.put(proSub.Id, proramSubscriptions);
                                            
            //Increment the value by 1
            cntVal++;                                
        }
        
        //Check for subscriptionList size
        if(mapProgramSubscriptions.size() > 0 ) {
            
            //Loop through the subscription period's records
            for(Subscription_Period__c subPd : [Select Id, Segment_Index__c, Product__c, Stage__c, Period_Start_Date__c, Period_End_Date__c, Program_Subscription__c,
                                                Renewal_Owner__c, Pool_Month__c, Pool_Year__c, Negotiated_Amount_Period__c, Renewal_Negotiated_Adjustment__c, Period__c,
                                                Previous_Period_Negotiated__c, Profit_Period__c,Renewal_Negotiated__c, Close_Date__c, Campaign_Kicker__c, Decision_Type__c, Research_Strategic_Leader__c
                                                From Subscription_Period__c Where Program_Subscription__c != null
                                                AND Program_Subscription__c IN : mapProgramSubscriptions.keySet() Order By Program_Subscription__c ASC]) {
                                                    
                //Populate mapSubsIdWithSubscriptionPeriods                                   
                if(mapProgramSubscriptions.containsKey(subPd.Program_Subscription__c)) 
                    mapProgramSubscriptions.get(subPd.Program_Subscription__c).subscriptionPeriodList.add(subPd);
            }
        }
        
        //Add all values
        contractControllerWrapperList.addAll(mapProgramSubscriptions.values());
    }
    
    /**
     *  @description    :   Save method  
     *                                  
     *  @args           :   
     *
     *  @return         :   void 
     *  
     *  @Revision Log   :   V1.1 - 5/26/2017 - Created - CR-20170403-10807 - Deepak Kumar
     * 					:   V1.2 - Modified By - Subhash Garhwal - CR-20180516-12227 - 05/16/2018 - Call a Future method to run a trigger of Subscription period.
     *
    **/
    public void doSave() {
        
        //Set to hold the Ids of Subscription period 
        Set<Id> setSubperiodsIds = new Set<Id>();
        
        //Savepoint
        Savepoint sp = Database.setSavepoint();
        
        try {
            
            //Insert the  Subscriptions records
            if(contractControllerWrapperList.size() != null) {
                
                //temp
                boolean isAnyLineSelected = false;
                
                //Check for validation
                //Loop through the contractControllerWrapper
                for(ContractControllerWrappper wrap : contractControllerWrapperList) {
                
                    //If 
                    if(wrap.isSelected) {
                        isAnyLineSelected = true;
                        break;
                    }
                }
                
                //Check
                if(!isAnyLineSelected)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one Subscription'));
                
                //Checking for page message
                if(!Apexpages.hasMessages()) {
                    
                    //List to hold the Program Subscriptions records 
                    List<SBQQ__Subscription__c> progSubscriptionList =new List<SBQQ__Subscription__c>();
                    
                    //List to the Subsription Period records
                    List<Subscription_Period__c> ListOfSubscriptionPeriod = new List<Subscription_Period__c>();
                    
                    //Loop through the contractControllerWrapper
                    for(ContractControllerWrappper wrap : contractControllerWrapperList) {
                        
                        //Updating flag value to true
                        if(wrap.isBlueImageNeedToEnabled)
                           wrap.isGreenImageNeedToEnabled = true; 
                        
                        //Populate the progSubscriptionList
                        progSubscriptionList.add(wrap.sbqqSubsription);
                        
                        //Loop through the contractControllerWrapper's subscriptionPeriod records 
                        for(Subscription_Period__c subPd :  wrap.subscriptionPeriodList) {
                            
                            //V1.1 - Modified By - Subhash Garhwal - CR-20180516-12227 - 05/16/2018
                            //Filling the Subscription Periods id in the Set
	                        setSubperiodsIds.add(subPd.Id);  
                                
                            //Populate the subscriptionPeriodList
                            ListOfSubscriptionPeriod.add(subPd);
                        }
                        
                        //Setting flags to defaults
                        wrap.isBlueImageNeedToEnabled = false;
                        wrap.isSelected = false;
                    }
                    
                    //Check for the progSubscriptionList's size
                    if(progSubscriptionList.size() > 0) {
                        
                        //bypassing triggers
                        Util.BypassAllTriggers = true;
                        
                        //perform update over records
                        update progSubscriptionList; 
                        
                        //Enabling triggers
                        Util.BypassAllTriggers = false; 
                    } 
                        
                    //Check for the subscriptionPeriodList's size 
                    if(ListOfSubscriptionPeriod.size() > 0) {
                        
                        //bypassing triggers
                        Util.BypassAllTriggers = true;
                        
                        //perform update over records
                        update ListOfSubscriptionPeriod; 
                        
                        //Enabling triggers
                        Util.BypassAllTriggers = false;
                        
                        //Calling a method to update the Renewal Owner on Program Subs.
                        SubscriptionPeriodTriggerHelper.populateRenewalOwnerOnSubAndOwnerOnMembership(new Map<Id, Subscription_Period__c>(ListOfSubscriptionPeriod), mapSubscriptionPeriod);
                        
                        //V1.1 - Modified By- Subhash Garhwal - CR-20180516-12227 - 05/16/2018
                        //Calling the Future Method that will blank Update the Subscription Periods.
                        blankUpdateSubPeriods(setSubperiodsIds);
                    }
                }
            }
        
        } catch(Exception e) {
            
            //Add Error on page
            ApexPages.addMessages(e);
            
            //Rollback changes
            Database.rollback(sp);
        }    
    }
    
    /**
     *  @description    :   Save and Close method  
     *                                  
     *  @args           :   
     *
     *  @return         :   Pagereference 
     *  
     *  @Revision Log   :   V1.1 - 5/26/2017 - Created - CR-20170403-10807 - Deepak Kumar
     *
     **/
    public Pagereference saveAndClose() {
        
        try {
        
            //Save the process 
            doSave();
            
            if(ApexPages.hasMessages(ApexPages.Severity.ERROR))
                return null;
            
            //return
            return new Pagereference('/' + contract.Id);
        } catch(Exception e) {
            
            //return 
            return null;
        }
		
	// Comment By - Rajeev Jain - CR-20200217-13763 - 06/15/2020
        //return null;
    }
    
    
    //Wrapper class, to hold the subscription, subscription period and related all the properties.    
    public class ContractControllerWrappper {
      
        //Properties
        public SBQQ__Subscription__c sbqqSubsription {get;set;}
        public Boolean isSelected {get;set;}
        public Boolean isBlueImageNeedToEnabled {get; set;}
        public Boolean isGreenImageNeedToEnabled {get; set;}
        public List<Subscription_Period__c> subscriptionPeriodList {get; set;}
        public Integer rowNumber {get; set;}
        
        //Constructor
        public ContractControllerWrappper(SBQQ__Subscription__c sbqqSubsription, Boolean isSelected, Integer rowNumber) {
           
            this.sbqqSubsription = sbqqSubsription;
            this.isSelected = isSelected;
            this.isGreenImageNeedToEnabled = false;
            this.isBlueImageNeedToEnabled = false;
            this.subscriptionPeriodList = new List<Subscription_Period__c>();
            this.rowNumber = rowNumber;
        }
    }
    
    /**
     *  @description    :   Returns a comma delimited list of a Field Set's Field API Names
     *
     *  @args           :    
     *
     *  @return         :   string
     *
     **/
    public string fieldSetQryString(string objectAPIName, string fieldSetName) {
        DisplayFieldsOnStandardPageLayoutCon d = new DisplayFieldsOnStandardPageLayoutCon();
        d.objectNameStr = objectAPIName;
        d.fieldSetNameStr = fieldSetName;
        List<Schema.FieldSetMember> fields = d.fieldSetFieldsList;
        list<string> listFieldAPINames = new list<string>();
        for (Schema.FieldSetMember f : fields) {
            listFieldAPINames.add(f.getFieldPath());
        }
        return string.join(listFieldAPINames, ',');
    }
    
    /**
     *  @description    :   Method to update the IsSelected flag value  
     *                                  
     *  @args           :   
     *
     *  @return         :   void 
     *  
     *  @Revision Log   :   V1.1 - 5/26/2017 - Created - CR-20170403-10807 - Deepak Kumar
     *
    **/
    public void setIsSelectedFlagToFalse() {
        contractControllerWrapperList[rowNumber].isSelected = false;
    }
    
    /**
     *  @description    :   Method to update the flag values   
     *                                  
     *  @args           :   
     *
     *  @return         :   void 
     *  
     *  @Revision Log   :   V1.1 - 5/26/2017 - Created - CR-20170403-10807 - Deepak Kumar
     *
    **/
    public void updateFlagsValues() {
        contractControllerWrapperList[rowNumber].isGreenImageNeedToEnabled = false;
        contractControllerWrapperList[rowNumber].isBlueImageNeedToEnabled = true;
    }
    
    /**
     *  @description    :   Method to blank update the SPeriod values to execute the Trigger logic.   
     *                                  
     *  @args           :   
     *
     *  @return         :   void 
     *  
     *  @Revision Log   :   V1.1 - Created By - Subhash Garhwal - CR-20180516-12227 - 05/16/2018
     *
    **/
    @future
    public static void blankUpdateSubPeriods(Set<Id> subPeriodIds) {
		
        
		//checking the Size of list 
        if (subPeriodIds.size() > 0){
            
            List<Subscription_Period__c> subPeriods = [Select Id From Subscription_Period__c Where Id IN:subPeriodIds];
            
            if(subPeriods.size() > 0) {
               
                //Just blank Updating the list to Update the SPeriod
                update subPeriods; 
            } 
        }      
    } 
}