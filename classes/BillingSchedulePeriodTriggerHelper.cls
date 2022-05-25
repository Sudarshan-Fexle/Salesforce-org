/**
 *  Purpose         :   This class is helper class for trigger on Opportunity object.
 *              
 *  Create By       :   Mahendra Swarnkar
 *  
 *  Created Date    :   05/25/2020
 *  
 *  Current Version :   V1.0 
 *  
 *  Revision Log    :   V1.0 - Created  
 *                      V1.1 - Modified By - Mahendra Swarnkar - 30/11/2020 - CR-20201109-14681 - Billing - BSP Validation Rules for Installment
 *			V1.2 - Modified By - Mahendra Swarnkar - 02/01/2021 - CR-20201109-14679 - BSP Clone Enhancement
 *  
**/
public without sharing class BillingSchedulePeriodTriggerHelper {

    public static Boolean validateInstallment = false;
    /**
      * 
      *  @description   :   Added method to validate the Billing schedule Periods
      *
      *  @args          :   List<Billing_Schedule_Period__c>, Map<Id, Billing_Schedule_Period__c>
      *
      *  @return        :   void
      *
      *  @revision Log  :   V1.0 - Created - 05/25/2020 - Mahendra Swarnkar - CR-20200512-14038
      *                     V1.1 - Created - 06/15/2020 - Mahendra Swarnkar - CR-20200605-14143 - Before delete validate that Sales_Credit_Note and Sales_Invoice is not tag on BSP. 
      * 
    **/
    public static void validateBSPs(List<Billing_Schedule_Period__c> newBSPList, Map<Id, Billing_Schedule_Period__c> mapOldBSPs) {
        
        for(Billing_Schedule_Period__c bsp : newBSPList != null ? newBSPList : mapOldBSPs.values()) {
            if(newBSPList == null && mapOldBSPs !=  null){
                if(bsp.Sales_Invoice__c != null || String.isNotBlank(bsp.Sales_Credit_Note_Record__c) || String.isNotBlank(bsp.Consolidated_Invoice_Record__c)){
                    throw new CustomException('You can not delete ' + bsp.name);
                }
            }    
        }
    }
    
    /**
      * 
      *  @description   :   Added method to validate the Billing schedule Periods
      *
      *  @args          :   List<Billing_Schedule_Period__c>, Map<Id, Billing_Schedule_Period__c>
      *
      *  @return        :   void
      *
      *  @revision Log  :   V1.0 - Created - 05/25/2020 - Mahendra Swarnkar - CR-20200512-14038
      * 
    **/
/*    public static void deleteRelatedBSLs(List<Billing_Schedule_Period__c> newBSPList, Map<Id, Billing_Schedule_Period__c> mapOldBSPs) {
        
        Set<Id> setBSPIds = new Set<Id>();
        for(Billing_Schedule_Period__c bsp : newBSPList != null ? newBSPList : mapOldBSPs.values()) {
            if(newBSPList == null && mapOldBSPs !=  null){
                if(bsp.Sales_Invoice__c == null){
                    setBSPIds.add(bsp.ID);
                }
            }
        }
        if(setBSPIds.size() > 0){
            List<Billing_Schedule_Line__c> listBSLtoDelete = new List<Billing_Schedule_Line__c>(); 
            for(Billing_Schedule_Line__c bsl : [Select Id from Billing_Schedule_Line__c where Billing_Schedule_Period__c IN : setBSPIds]){
                listBSLtoDelete.add(bsl);
            }
            if(listBSLtoDelete.size() > 0){
                delete listBSLtoDelete;
            }
        }
    }*/
    

    /**
    * 
    *  @description   :   Added method to update the #PO on Billing schedule Periods from Billing Schedule Header
    *
    *  @args          :   List<Billing_Schedule_Period__c>, Map<Id, Billing_Schedule_Period__c>
    *
    *  @return        :   void
    *
    *  @revision Log  :   V1.0 - Created - 06/22/2020 - Mahendra Swarnkar - CR-20200619-14209
    * 
    **/
    public static void populatePOonBSP(List<Billing_Schedule_Period__c> newBSPList, Map<Id, Billing_Schedule_Period__c> mapOldBSPs) {
        
        Set<Id> setOfBSHIds = new Set<Id>();
        Map<Id,Billing_Schedule_Header__c> mapOfBSH = new Map<Id,Billing_Schedule_Header__c>();
        
        for(Billing_Schedule_Period__c bsp : newBSPList){
            if(mapOldBSPs == null || (mapOldBSPs != null && (mapOldBSPs.get(bsp.Id).Billing_Schedule_Header__c != bsp.Billing_Schedule_Header__c
                                                             || mapOldBSPs.get(bsp.Id).PO__c != bsp.PO__c))){
                if(bsp.Billing_Schedule_Header__c != null){
                setOfBSHIds.add(bsp.Billing_Schedule_Header__c);
                }
            }
        }
        
        if(setOfBSHIds.size() > 0){
            for(Billing_Schedule_Header__c bsh : [Select Id,PO__c From Billing_Schedule_Header__c Where Id IN: setOfBSHIds]){
                if(!mapOfBSH.containsKey(bsh.Id)){
                    mapOfBSH.put(bsh.Id,bsh);
                }
            }
           
            
            if(mapOfBSH.size() > 0){
                for(Billing_Schedule_Period__c bsp : newBSPList){
                    if(mapOfBSH.containsKey(bsp.Billing_Schedule_Header__c)){
                        bsp.PO__c = mapOfBSH.get(bsp.Billing_Schedule_Header__c).PO__c;
                    }
                }
            }
            
        }
    }
    
    /**
    * 
    *  @description   :   Added method to validate Installment field on Billing schedule Periods is unique
    *
    *  @args          :   List<Billing_Schedule_Period__c>, Map<Id, Billing_Schedule_Period__c>
    *
    *  @return        :   void
    *
    *  @revision Log  :   V1.0 - Created - 11/30/2020 - Mahendra Swarnkar - CR-20201109-14681
    * 
    **/
    public static void validateUniqueInstallment(List<Billing_Schedule_Period__c> newBSPList, Map<Id, Billing_Schedule_Period__c> mapOldBSPs) {
        
        if(validateInstallment) return;
        
        Map<Id, List<Decimal>> mapOfBSHWithInstallment = new Map<Id, List<Decimal>>();
        List<Billing_Schedule_Period__c> listOfBSPToValidate = new List<Billing_Schedule_Period__c>();
        
        for(Billing_Schedule_Period__c bsp : newBSPList){
            
            if(bsp.Installment__c != null && (mapOldBSPs == null || 
                                              (mapOldBSPs != null && mapOldBSPs.get(bsp.Id).Installment__c != bsp.Installment__c))
              ){
                  if(bsp.Billing_Schedule_Header__c != null && !mapOfBSHWithInstallment.containsKey(bsp.Billing_Schedule_Header__c)){
                      mapOfBSHWithInstallment.put(bsp.Billing_Schedule_Header__c, new List<Decimal>());
              }
                  
                  if(!listOfBSPToValidate.contains(bsp)) {
                      listOfBSPToValidate.add(bsp);
                  }
                  
              }
        }
        
        if(mapOfBSHWithInstallment != null && mapOfBSHWithInstallment.keySet().size() > 0) {
            
            Map<Id,Billing_Schedule_Period__c> mapOfBSP = new Map<Id,Billing_Schedule_Period__c>([Select Id, Installment__c, Billing_Schedule_Header__c From Billing_Schedule_Period__c 
                                                                                                   Where Billing_Schedule_Header__c IN :mapOfBSHWithInstallment.keySet() 
                                                                                                   AND Installment__c != null]
                                                                                                );
            
            if(mapOfBSP != null && mapOfBSP.keySet().size() > 0) {
                for(Billing_Schedule_Period__c existingBSP : mapOfBSP.values()) {

                    if(mapOfBSHWithInstallment.containsKey(existingBSP.Billing_Schedule_Header__c))
                         mapOfBSHWithInstallment.get(existingBSP.Billing_Schedule_Header__c).add(existingBSP.Installment__c);
                }

                for(Billing_Schedule_Period__c bsp : listOfBSPToValidate) {
                    
                    if(mapOfBSHWithInstallment.containsKey(bsp.Billing_Schedule_Header__c) && mapOfBSHWithInstallment.get(bsp.Billing_Schedule_Header__c).contains(bsp.Installment__c)) {
                        bsp.addError('Installment # Of newly created or Updated BSP already exist on associated BSH.');
                    }
                }
            }
            
            validateInstallment = true;
        }
        
    }
    
    /**
    * 
    *  @description   :   Added method to remove values from some fields while cloning Billing schedule Periods
    *
    *  @args          :   List<Billing_Schedule_Period__c>
    *
    *  @return        :   void
    *
    *  @revision Log  :   V1.0 - Created - 02/01/2021 - Mahendra Swarnkar - CR-20201109-14679
    * 
    **/
    public static void updateBSPonClone(List<Billing_Schedule_Period__c> newBSPList) {
        
        //new cloned records
        for (Billing_Schedule_Period__c bsp : newBSPList) {
            
            //clone use case
            if (bsp.isClone()) {
                System.debug('Clone ');
                
                //while cloning BSP remove these fields if populated
                //Blank Sales Invoice field if populated
                if(bsp.Sales_Invoice__c != null)
                    bsp.Sales_Invoice__c = null;
                
                //Blank Actual Invoice Sent Date if populated
                if(bsp.Actual_Invoice_Sent_Date__c != null)
                    bsp.Actual_Invoice_Sent_Date__c = null;
                
                //Blank Billing Posted Date if populated
                if(bsp.Billing_Posted_Date__c != null)
                    bsp.Billing_Posted_Date__c = null;
                
                //Blank Billing Date Override if populated
                if(bsp.Billing_Date_Override__c != null)
                    bsp.Billing_Date_Override__c = null;
                
            }
        }
    }
    
    /**
    * 
    *  @description   :   Added method to clone Billing schedule Periods with releated Billing Schedule Lines
    *
    *  @args          :   List<Billing_Schedule_Period__c>
    *
    *  @return        :   void
    *
    *  @revision Log  :   V1.0 - Created - 02/01/2021 - Mahendra Swarnkar - CR-20201109-14679
    * 
    **/
    public static void cloneBSLonBSPclone(List<Billing_Schedule_Period__c> newBSPList) {
        
        //Map to update cloned BSP
        Map<Id, Id> mapBSPWithClonedBSPIds = new Map<Id, Id>();
        
        //clone use case
        for (Billing_Schedule_Period__c bsp : newBSPList) {
            
            //clone use case
            //check clone source id
            if (bsp.isClone() && bsp.getCloneSourceId() != null) {
                
                //add before clone BSP Id with after Clone BSP id into map 
                mapBSPWithClonedBSPIds.put(bsp.getCloneSourceId(), bsp.Id);
            }
        }
        
        //check map is not empty
        if( !mapBSPWithClonedBSPIds.isEmpty() && mapBSPWithClonedBSPIds.keySet().size() > 0) {
            
            //hold dynamic query string
            String queryString = 'SELECT ';
            
            //get all BSL fields
            for (String fieldName: Schema.SObjectType.Billing_Schedule_Line__c.fields.getMap().keySet()) {
                queryString += fieldName + ',';
            }
            
            //hold Before Clone BSL ids
            Set<Id> bspIds = mapBSPWithClonedBSPIds.keySet();
            
            queryString = queryString.removeEnd(',') + ' FROM Billing_Schedule_Line__c WHERE Billing_Schedule_Period__c != null ' +
                          'AND Billing_Schedule_Period__c IN :bspIds';
            
            //hold BSP releated lines for cloning
            List<Billing_Schedule_Line__c> billingSchLines = new List<Billing_Schedule_Line__c>();
            
            //return creatable fields with value from query
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, database.query(queryString));
            
            //get all BSP releated BSL's
            for(Billing_Schedule_Line__c bsl : (List<Billing_Schedule_Line__c>)securityDecision.getRecords())
            {
				Billing_Schedule_Line__c billSchLine = bsl.clone();
				
                //assign cloned BSP Id on BSL
				if(mapBSPWithClonedBSPIds.containsKey(bsl.Billing_Schedule_Period__c))
					billSchLine.Billing_Schedule_Period__c = mapBSPWithClonedBSPIds.get(bsl.Billing_Schedule_Period__c);
                   
                //add bsl in list
                billingSchLines.add(billSchLine);
            }
                        
            //Insert BSL's under cloned BSP
            if(billingSchLines.size() > 0) {
                
                //flag for bypass triggers
                Util.BypassAllTriggers = true;
                INSERT billingSchLines;
                Util.BypassAllTriggers = false;
            }
        }
    }
}