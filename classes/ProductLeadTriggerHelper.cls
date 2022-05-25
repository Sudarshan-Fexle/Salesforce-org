/** 
  * Description     :   This class is used to do the actual manuplation ion the product Lead object, called from the trigger.
  *
  * Created By      :   Abhinav Sharma
  *
  * Created Date    :  07/04/2018
  *
  * Revision Log    :  V1.1 - Created.
  * 		    :  V1.2 - Abhinav sharma - 09/13/2018 - CR-20180910-1258 - New Method - updateLastMQLOpportunityAndStatusChange, Commented - populateProductLeadName
  * 		    :  V1.3 - Created - Dipesh Gupta -05/07/2020 - CR-20200429-14006 (Automated email notification to PDR for hot lead)
  *		    :  V1.4 - Modified By Rajeev Jain -09/28/2020 - CR-20200917-14522
  *		    :  V1.5 - Modified By - Neha Sharma - CR-20210129-14857 - 03/01/2021 - Update Logic for Hot Lead Trigger
  *         :  V1.6 - Modified By - Chirag Soni - CR-20220224-15942 - 04/14/2022 - updated method sendEmail() - added not null check
**/
public class ProductLeadTriggerHelper {
    
    //Static Variable to  keep the value through out the transaction. 
    Static Integer Trigger_Run_Count = 0;
    Static Map<Id, Map<String, DateTime>> MAP_LAST_PRODUCT_LEAD_SATGE = new Map<Id, Map<String, DateTime>>();
    
    public static final Map<String, Decimal > MapStageNameWithOrderForProductLeads = new Map<String, Decimal >{'Customer' => 6, 'SQL' => 5, 'SAL' => 4, 
                                                                                                'MQL' => 3, 'SGL' => 2, 'TGL' => 2, 'TAL' => 2,
                                                                                                'EAL' => 2, 'AQL' => 2, 'Inquiry' => 1};    
    
    /** 
      * Description     :   This Method is used to populate the Name on the Product lead Object
      *
      * Created By      :   Abhinav Sharma
      *
      * Created Date    :  07/04/2018
      *
      * Revision Log    :  V1.1 - Created.
      *
      **/
   /* public static void populateProductLeadName(List<Product_Lead__c> newProductLeads) {
        
        //List to hold those Product Lead that is going to be Updated 
        List<Product_Lead__c> productLeadsToBeUpserted = new List<Product_Lead__c>();
            
        //Converting the List to the Set 
        Set<Id> setProductLeadIDs = new Set<Id>();
        
        //Loop through the Product Lead Object list
        for(Product_Lead__c pD : newProductLeads)
            setProductLeadIDs.add(pD.Id);           
        
        //Check for the set size
        if(setProductLeadIDs.size() > 0) {
            
            //Query on the Product Lead Object
            for(Product_Lead__c productLeads : [Select Id, Name, Name__c From Product_Lead__c Where Id IN: setProductLeadIDs]) {
                
                //Compare the Name and Name__c field values are similar or not
                if(productLeads.Name != productLeads.Name__c) 
                    productLeadsToBeUpserted.add(new Product_Lead__c (Id = productLeads.Id, Name = productLeads.Name__c));
            }
            
            //Check for the size of list
            if(productLeadsToBeUpserted != null && productLeadsToBeUpserted.size() >0) {
                
                //Bypassing the triggers and updating the List.
                Util.BypassAllTriggers = true;
                update productLeadsToBeUpserted;
                Util.BypassAllTriggers = false;
            }
        }
    }*/
   
    /** 
      * Description     :   This Method is used TO populate the Last MQL Opportunity Field on Prod. Lead, If Stage is changed 
      *                     MQL From any of (TAL, TGL, EAL, SGL)
      *                     Running this method in the After Update case because a process Builder is working which Sets different value in the stage.
      *                     + 
      *                     Mehtod is used to populate the Name on the Product lead Object
      *
      * Created By      :   Abhinav Sharma
      *
      * Created Date    :  09/11/2018
      *
      * Revision Log    :  V1.1 - Created - CR-20180910-12583
      *                 :  V1.2 - Modified - CR-20220428-16144 - Chirag Soni - 5/20/2022 - Added LEFT method in  productLeads.Name__c
      **/
    public static void updateLastMQLOpportunityAndStatusChange(List<Product_Lead__c> newProductLeads, Map<Id, Product_Lead__c> oldMapProductLead ) {
    	
        //Set to hold the Stages of Product Lead
        Set<String> setProductLeadStages = new Set<String>{'TAL', 'TGL', 'EAL', 'SGL'};
            
        String STAGE_MQL = 'MQL';
        
        //List to hold those Product Lead that is going to be Updated 
        List<Product_Lead__c> productLeadsToBeUpserted = new List<Product_Lead__c>();
            
        //Converting the List to the Set 
        Set<Id> setProductLeadIDs = new Set<Id>();
        
        //Loop through the Product Lead Object list
        for(Product_Lead__c pD : newProductLeads) {
            setProductLeadIDs.add(pD.Id);           
        }
        
        //Check for the set size
        if(setProductLeadIDs.size() > 0) {
            
            //Query on the Product Lead Object
            for(Product_Lead__c productLeads : [Select Id, Last_Outreach_Start__c, Outreach_In_Cycle__c,
                                                Name, Name__c, Opportunity__c, Last_MQL_Opportunity__c, 
                                                Stage__c, Latest_Stage_Change__c From Product_Lead__c Where Id IN: setProductLeadIDs]) {
                
                //This block should only execute in the First transaction
                if(Trigger_Run_Count == 0) {
                    //map to hold the String and Date Time (Stage change Time)
                    Map<String, DateTime> mapStageWithStatusChangeDateTime = new Map<String, DateTime>();
                    if (oldMapProductLead != null)
                        mapStageWithStatusChangeDateTime.put(oldMapProductLead.get(productLeads.Id).Stage__c, productLeads.Latest_Stage_Change__c);
                    MAP_LAST_PRODUCT_LEAD_SATGE.put(productLeads.Id, mapStageWithStatusChangeDateTime);
                    mapStageWithStatusChangeDateTime = new Map<String, DateTime>();
                }
                
                //New Instance of product Lead
                Product_Lead__c updatedPLead = productLeads;
                
                //Check if the Stage Value is changed from setProductLeadStages to the 'MQL'
                if(oldMapProductLead != null  && 
                   oldMapProductLead.containsKey(productLeads.Id) &&
                   productLeads.Stage__c == STAGE_MQL &&
                   setProductLeadStages.contains(oldMapProductLead.get(productLeads.Id).Stage__c) &&
                   oldMapProductLead.get(productLeads.Id).Opportunity__c != null
                 ) {
                    	//Updating the old Opportunity on it. 
                     	updatedPLead.Last_MQL_Opportunity__c = oldMapProductLead.get(productLeads.Id).Opportunity__c;
                }
                
                //Checking the Status Change - If Stage is changed so update the System.now on it and trigger is running secong time in the  
                if(oldMapProductLead != null && oldMapProductLead.get(productLeads.Id).Stage__c != productLeads.Stage__c) {
                    
                    updatedPLead.Latest_Stage_Change__c = System.now();
                    
                    //Check for the stage value - if the Stage is changed then set the Last Outreach Start date. 
                    if(setProductLeadStages.contains(productLeads.Stage__c) ){
                        //Setting Todays date last outreach start date. 
                        updatedPLead.Last_Outreach_Start__c = Date.Today();
                        
                        //as soon as the last outreach is changed all the outreach in cycle has to the reset to 0. 
                        //they will be increased if any of the task is created after it. 
                        updatedPLead.Outreach_In_Cycle__c = 0;
                    }
                }
                    
                
                //Checking for the trigger execution second time and Process builder changed the Status what it was previously. 
                if(Trigger_Run_Count > 0 && MAP_LAST_PRODUCT_LEAD_SATGE != null 
                   && MAP_LAST_PRODUCT_LEAD_SATGE.containsKey(productLeads.Id)
                   && MAP_LAST_PRODUCT_LEAD_SATGE.get(productLeads.Id) != null &&
                   MAP_LAST_PRODUCT_LEAD_SATGE.get(productLeads.Id).containsKey(productLeads.Stage__c)
                  ){
                    
                      updatedPLead.Latest_Stage_Change__c = MAP_LAST_PRODUCT_LEAD_SATGE.get(productLeads.Id).get(productLeads.Stage__c);
                }
                
                //Check if the Value is changed of desirable Fields then only Fill the List that is going to be update. 
            	if(updatedPLead.Name != updatedPLead.Name__c || updatedPLead.Last_MQL_Opportunity__c != productLeads.Last_MQL_Opportunity__c 
                   || updatedPLead.Latest_Stage_Change__c != productLeads.Latest_Stage_Change__c 
                   || updatedPLead.Last_Outreach_Start__c != productLeads.Last_Outreach_Start__c)    
                    
                   //Adding the changes to the List
                   //Modified - CR-20220428-16144 - 5/20/2022 - Chirag Soni - Added LEFT method in  productLeads.Name__c
                    productLeadsToBeUpserted.add(new Product_Lead__c (Id = productLeads.Id, Name = productLeads.Name__c.LEFT(80),  
                                                Last_MQL_Opportunity__c = updatedPLead.Last_MQL_Opportunity__c, 
                                                Latest_Stage_Change__c = updatedPLead.Latest_Stage_Change__c,
                                                Last_Outreach_Start__c = updatedPLead.Last_Outreach_Start__c, 
                                                Outreach_In_Cycle__c = updatedPLead.Outreach_In_Cycle__c ));
            }
            
            //Check for the size of list
            if(productLeadsToBeUpserted != null && productLeadsToBeUpserted.size() >0) {
				
                Trigger_Run_Count = Trigger_Run_Count + 1;
                //Bypassing the triggers and updating the List.
                Util.BypassAllTriggers = true;
               	update productLeadsToBeUpserted;
            	Util.BypassAllTriggers = false;
            }
        }
    }
 	
    /** 
      * Description     :	This Method is used TO populate the External Id field with deleting the duplicate Product lead records having the smae external Id.
      *
      * Created By      :	Mahendra Swarnkar
      *
      * Created Date    :	04/19/2019
      *
      * Revision Log    :	V1.1 - Created - CR-20181130-12772
      *
      **/
    public static void populateExternalId(List<Product_Lead__c> newProductLeads, Map<Id, Product_Lead__c> oldMapProductLead ) {
    	
    	//set to hold the contact Ids
    	Set<Id> setContactIds = new Set<Id>();
        
    	//set to hold the contact Ids
    	Set<Id> setLeadIds = new Set<Id>();
    	
    	//Set to hold the Program Ids
    	Set<Id> setProgramIds = new Set<Id>();
    	
    	//set to hold the Product Lead Ids
    	Set<Id> setProductLeadIds = new Set<Id>();
        
    	//Loop over the new list
		for(Product_Lead__c pLead : newProductLeads){
			
			//Check for condition
			if(oldMapProductLead == null 
				|| pLead.Contact__c != oldMapProductLead.get(pLead.Id).Contact__c 
				|| pLead.Lead__c != oldMapProductLead.get(pLead.Id).Lead__c 
				|| pLead.Program__c != oldMapProductLead.get(pLead.Id).Program__c
               			|| pLead.External_Id__c != oldMapProductLead.get(pLead.Id).External_Id__c
				) {
				
				//populate the set
				setProductLeadIds.add(pLead.Id);
				
				//Pipulate the set 
				if(pLead.Contact__c != null){
					setContactIds.add(pLead.Contact__c);
				}
				
				//Pipulate the set 
				if(pLead.Lead__c != null){
					setLeadIds.add(pLead.Lead__c);
				}
				
				//Pipulate the set 
				if(pLead.Program__c != null){
					setProgramIds.add(pLead.Program__c);
				}
			}
		}
		
		//Check for size
		if(setProductLeadIds.size() > 0){
			
			
			//1. Identify the duplicate product Leads
			
			//Map to Hold the External Id with list of productLeads
			Map<String, Map<Id,Product_Lead__c>> mapExternalIdWithListProductLead = new Map<String, Map<Id,Product_Lead__c>>();
			
			//Set to hold the product leads for which history records needs to be queried
			Set<ID> setAllfeasibleProductLead = new Set<ID>();
			
			//Map to hold the Product Lead Id with total number of field history records
			Map<Id, Integer> mapProductLeadIdWithRelatedHistoryRecordCount = new Map<Id, Integer>();
			
			//Map to hold the new product leads list records
			Map<Id, Product_Lead__c> mapNewProductLeads = new Map<Id, Product_Lead__c>();
            
            //List to hold the id of product Leads on which no merge rules applied and they are inserted duplicate in the system. We have to send this list to Kate so they can take the necessary action as needed. 
            List<Product_Lead__c> duplicatedProductLeads = new List<Product_Lead__c>();
            
            //Query over the existing Product leads
            for (Product_Lead__c pLead : [Select Id, External_Id__c, Contact__c, Contact__r.Counter_ID__c, Lead__c, Lead__r.Counter_ID__c, 
                                            Program__c, Program__r.Counter_ID__c, 
                                          	Stage__c, reset__c, CreatedDate 
                                            From Product_Lead__c 
                                            where Program__c != null AND Program__c IN : setProgramIds 
                                            AND ((Contact__c != null AND Contact__c IN : setContactIds) 
                                                OR (Lead__c != null AND Lead__c IN : setLeadIds))
                                            ORDER BY CreatedDate ASC]){
                
                //External Id string
                String externalId = '';
                
                //Check ffor program counter
                if(pLead.Program__r.Counter_ID__c != null){
                    
                    //Populate the External Id string with unique key
                    if(pLead.Contact__c != null && pLead.Contact__r.Counter_ID__c != null)
                        externalId = pLead.Contact__r.Counter_ID__c + '_' + pLead.Program__r.Counter_ID__c;
                    else if(pLead.Lead__c != null && pLead.Lead__r.Counter_ID__c != null)
                        externalId = pLead.Lead__r.Counter_ID__c + '_' + pLead.Program__r.Counter_ID__c;
                }   
                
                //Set the External Id field value for the records
                pLead.External_Id__c = externalId;
                
                //Check for size & populate the map
                if(setProductLeadIds.contains(pLead.Id))
                    mapNewProductLeads.put(pLead.Id, pLead);
                
                //if(pLead.Contact__c != null){
                
                    //Populate the Map
                    if(!mapExternalIdWithListProductLead.containsKey(externalId))
                        mapExternalIdWithListProductLead.put(externalId, new Map<Id,Product_Lead__c>());
                        
                    mapExternalIdWithListProductLead.get(externalId).put(pLead.Id, pLead);  
                //}
                
                //Populate the set and Maps
                setAllfeasibleProductLead.add(pLead.Id);
                mapProductLeadIdWithRelatedHistoryRecordCount.put(pLead.Id, 0);
            }
            
            //Map to holfd the product lead Id with list of history records for field "Reset?"
            Map<Id, List<Product_Lead__History>> mapProductLeadIdWithRelatedRecetHistoryRecord = new Map<Id, List<Product_Lead__History>>();
            
            //Check for size
            if(setAllfeasibleProductLead.size() > 0 ) {
                
                //Query over the Product leads history
                for (Product_Lead__History pLeadHistory : [Select ParentId, Field, OldValue, NewValue
                					   From Product_Lead__History 
                                                           where ParentId != null AND ParentId IN : setAllfeasibleProductLead]){  
                    //Populate the map
                    if(!mapProductLeadIdWithRelatedHistoryRecordCount.containsKey(pLeadHistory.ParentId))
                        mapProductLeadIdWithRelatedHistoryRecordCount.put(pLeadHistory.ParentId, 0);
                    
                    Integer count = mapProductLeadIdWithRelatedHistoryRecordCount.get(pLeadHistory.ParentId) + 1;
                    mapProductLeadIdWithRelatedHistoryRecordCount.put(pLeadHistory.ParentId, count);
                    
                    //check for condition
                    if(pLeadHistory.Field == 'reset__c' ){
                        if(!mapProductLeadIdWithRelatedRecetHistoryRecord.containsKey(pLeadHistory.ParentId))
                            mapProductLeadIdWithRelatedRecetHistoryRecord.put(pLeadHistory.ParentId, new List<Product_Lead__History>());
                            
                        mapProductLeadIdWithRelatedRecetHistoryRecord.get(pLeadHistory.ParentId).add(pLeadHistory);
                    }
                    
                }
            }
            
            //Map to hold the product leads to be deleted
            Map<Id, Product_Lead__c>  MapProductLeadsToBeDeleted = new Map<Id, Product_Lead__c> ();
            
            //Map to hold product leads to delete.
            Map<String, List<Product_Lead__c>> mapExternalIdWithListProductLeadToBeDeleted = new Map<String, List<Product_Lead__c>>();
            
            //Map ,to hold the product leads to be updated
            Map<String, Product_Lead__c>  MapExternalIdWithProductLeadsToBeUpdated = new Map<String, Product_Lead__c> ();
                
            //check for the size
            if(mapNewProductLeads.size() > 0){
                
                //Query Over the new Product Leads
                for(Product_Lead__c newPLead : mapNewProductLeads.values()){
                    
                    //first Winning product lead
                    Product_Lead__c winningProductLead = newPLead;
                    
                    //External Id of Winning product Lead
                    String exId = winningProductLead.External_Id__c;
                    
                    //Checl for size
                    if(String.IsNotBlank(exId) && mapExternalIdWithListProductLead.containsKey(exId)
                        && mapExternalIdWithListProductLead.get(exId) != null 
                        && mapExternalIdWithListProductLead.get(exId).size() > 0
                        && mapExternalIdWithListProductLead.get(exId).values() != null 
                        && mapExternalIdWithListProductLead.get(exId).values().size() > 0){
                        
                        //Loop over the product leads having the same external Id value
                        for(Product_Lead__c pLead : mapExternalIdWithListProductLead.get(exId).values()){
                            
                            //Check for condition
                            if(newPLead.Id != pLead.Id){
                                //variables to holdd the stage order for the winning and current product lead
                                Decimal winningProductLeadStageOrder = 0;
                                Decimal pLeadStageOrder = 0;
                            
                                //Get the stage order for wining PL
                                if(MapStageNameWithOrderForProductLeads.containsKey(winningProductLead.Stage__c))
                                    winningProductLeadStageOrder = MapStageNameWithOrderForProductLeads.get(winningProductLead.Stage__c);
                                
                                //Get the stage order for current PL    
                                if(MapStageNameWithOrderForProductLeads.containsKey(pLead.Stage__c))
                                    pLeadStageOrder = MapStageNameWithOrderForProductLeads.get(pLead.Stage__c);
                                

                                //Compare the stage and get the winning product lead    
                                if(winningProductLeadStageOrder > pLeadStageOrder ){
                                    System.debug('winningProductLeadStageOrder-->'+ winningProductLeadStageOrder);
                                    System.debug('pLeadStageOrder-->'+ pLeadStageOrder);
                                    MapProductLeadsToBeDeleted.put(pLead.Id, pLead);
                                
                                } else if(winningProductLeadStageOrder < pLeadStageOrder){
                                    
                                    MapProductLeadsToBeDeleted.put(winningProductLead.Id, winningProductLead);
                                    
                                    winningProductLead = pLead;
                                    
                                } else if(winningProductLeadStageOrder == pLeadStageOrder){
                                
                                    
                                    System.debug('winningProductLeadStageOrder===='+winningProductLeadStageOrder);
                                    //If both are having the stage Inquiry
                                    if(winningProductLeadStageOrder == 1){
                                        
                                        //Check for Reset Field value and if both (winning and other product lead ) are true ten check for Reset field history count if that too are same then check for the the records created dates
                                        if(winningProductLead.reset__c == true || pLead.reset__c == true) {
                                            
                                            if(winningProductLead.reset__c == true && pLead.reset__c == false ){
                                                
                                                MapProductLeadsToBeDeleted.put(pLead.Id, pLead);
                                                
                                            } else if(winningProductLead.reset__c == false && pLead.reset__c == true ){
                                                
                                                MapProductLeadsToBeDeleted.put(winningProductLead.Id, winningProductLead);
                                    
                                                winningProductLead = pLead;
                                                
                                            }else if(winningProductLead.reset__c == true && pLead.reset__c == true){
                                                
                                                Integer winningHistorycount = 0;
                                                Integer pLeadHistorycount = 0;
                                                
                                                if(mapProductLeadIdWithRelatedRecetHistoryRecord != null){
                                                    
                                                    //winning PL Reset history count
                                                    if(mapProductLeadIdWithRelatedRecetHistoryRecord.containsKey(winningProductLead.Id)
                                                        && mapProductLeadIdWithRelatedRecetHistoryRecord.get(winningProductLead.Id) != null 
                                                        && mapProductLeadIdWithRelatedRecetHistoryRecord.get(winningProductLead.Id).size() > 0)
                                                        
                                                        winningHistorycount = mapProductLeadIdWithRelatedRecetHistoryRecord.get(winningProductLead.Id).size();
                                                        
                                                    //other PL Reset history count
                                                    if(mapProductLeadIdWithRelatedRecetHistoryRecord.containsKey(pLead.Id)
                                                        && mapProductLeadIdWithRelatedRecetHistoryRecord.get(pLead.Id) != null 
                                                        && mapProductLeadIdWithRelatedRecetHistoryRecord.get(pLead.Id).size() > 0)
                                                        
                                                        pLeadHistorycount = mapProductLeadIdWithRelatedRecetHistoryRecord.get(pLead.Id).size();
                                                } 
                                                
                                                //Compare reset History count
                                                if(winningHistorycount > pLeadHistorycount){
                                                        MapProductLeadsToBeDeleted.put(pLead.Id, pLead);
                                                        
                                                }else if(winningHistorycount < pLeadHistorycount){
                                                    
                                                        MapProductLeadsToBeDeleted.put(winningProductLead.Id, winningProductLead);
                                                        
                                                        winningProductLead = pLead;
                                                } else {
                                                    
                                                    // If reset history count is same then compare the created date
                                                    if(winningProductLead.CreatedDate < pLead.CreatedDate){
                                                    
                                                        MapProductLeadsToBeDeleted.put(pLead.Id, pLead);
                                                        
                                                    }else if(winningProductLead.CreatedDate > pLead.CreatedDate) {
                                                        
                                                        MapProductLeadsToBeDeleted.put(winningProductLead.Id, winningProductLead);
                                                        winningProductLead = pLead;
                                                    }
                                                }
                                            }
                                        } else if(mapProductLeadIdWithRelatedHistoryRecordCount.size() > 0) {
                                            
                                            Integer winningAllHistorycount = 0;
                                            Integer pLeadAllHistorycount = 0;
                                            
                                            if(mapProductLeadIdWithRelatedHistoryRecordCount.containsKey(winningProductLead.Id) && mapProductLeadIdWithRelatedHistoryRecordCount.get(winningProductLead.Id) > 0)
                                                winningAllHistorycount = mapProductLeadIdWithRelatedHistoryRecordCount.get(winningProductLead.Id);
                                            
                                            if(mapProductLeadIdWithRelatedHistoryRecordCount.containsKey(pLead.Id) && mapProductLeadIdWithRelatedHistoryRecordCount.get(pLead.Id) > 0)
                                                pLeadAllHistorycount = mapProductLeadIdWithRelatedHistoryRecordCount.get(pLead.Id);
                                            
                                            if(winningAllHistorycount < pLeadAllHistorycount){
                                                MapProductLeadsToBeDeleted.put(winningProductLead.Id, winningProductLead);
                                                winningProductLead = pLead;
                                            } else if(winningAllHistorycount > pLeadAllHistorycount){
                                                MapProductLeadsToBeDeleted.put(pLead.Id, pLead);
                                            } else {
                                                    
                                                // If reset history count is same then compare the created date
                                                if(winningProductLead.CreatedDate < pLead.CreatedDate){
                                                    
                                                    MapProductLeadsToBeDeleted.put(pLead.Id, pLead);
                                                        
                                                }else if(winningProductLead.CreatedDate > pLead.CreatedDate) {
                                                        
                                                    MapProductLeadsToBeDeleted.put(winningProductLead.Id, winningProductLead);
                                                    winningProductLead = pLead;
                                                }
                                            }    
                                        } else {
                                            
                                            // If reset history count is same then compare the created date
                                            if(winningProductLead.CreatedDate < pLead.CreatedDate){
                                                
                                                MapProductLeadsToBeDeleted.put(pLead.Id, pLead);
                                                
                                            }else if(winningProductLead.CreatedDate > pLead.CreatedDate) {
                                                
                                                MapProductLeadsToBeDeleted.put(winningProductLead.Id, winningProductLead);
                                                winningProductLead = pLead;
                                            }
                                        }
                                    }
                                    else{
                                        //If No above conditioin matched means this dups has to handle manually so adding to a list and email out to the Kate.
                                        duplicatedProductLeads.add(pLead);                                    
                                    }
                                }
                                
                            }
                        }
                    }
                    //Check for condition and populate the map
                    if(winningProductLead != null )
                        MapExternalIdWithProductLeadsToBeUpdated.put(winningProductLead.External_Id__c, winningProductLead);
                }
                
                //2.0 reparent the child records to Wining product lead
                if(MapProductLeadsToBeDeleted.size() > 0 != null && MapProductLeadsToBeDeleted.values() != null && MapProductLeadsToBeDeleted.values().size() > 0 ){
                    
                    //Reparent the Task records
                    reparentChilds('CampaignMember',MapProductLeadsToBeDeleted, MapExternalIdWithProductLeadsToBeUpdated);
                    
                    //Reparent the Task records
                    reparentChilds('Task',MapProductLeadsToBeDeleted, MapExternalIdWithProductLeadsToBeUpdated);
                    
                    //Reparent the Event records
                    reparentChilds('Event',MapProductLeadsToBeDeleted, MapExternalIdWithProductLeadsToBeUpdated);
                    
                    //Reparent the Opportunity records
                    reparentChilds('Opportunity',MapProductLeadsToBeDeleted, MapExternalIdWithProductLeadsToBeUpdated);
                    
                    //Reparent the Note records
                    reparentChilds('Note',MapProductLeadsToBeDeleted, MapExternalIdWithProductLeadsToBeUpdated);
                    
                    //Reparent the Attachment records
                    reparentChilds('Attachment',MapProductLeadsToBeDeleted, MapExternalIdWithProductLeadsToBeUpdated);
                    
                    
                    //Bypassing the triggers and updating the List.
                    //Util.BypassAllTriggers = true;
                    
                    //Delete the duplicate records
                    delete MapProductLeadsToBeDeleted.values();
                    
                    //Util.BypassAllTriggers = false;                   
                }
                
                //Check for size
                if(MapExternalIdWithProductLeadsToBeUpdated.size() > 0 && MapExternalIdWithProductLeadsToBeUpdated.values() != null && MapExternalIdWithProductLeadsToBeUpdated.values().size() > 0 ){
                
                    //Bypassing the triggers and updating the List.
                    Util.BypassAllTriggers = true;
                    System.debug('MapExternalIdWithProductLeadsToBeUpdated.values--> '+MapExternalIdWithProductLeadsToBeUpdated.values());
                    update MapExternalIdWithProductLeadsToBeUpdated.values();
                    Util.BypassAllTriggers = false; 
                        
                }
                
                
                //Check the size of duplicate records. 
                if(duplicatedProductLeads.size() > 0 ) {
                    
                    String emailBody = 'Hi, ' + '\n\n' + 'Duplicate product leads detected in the system. \n Please find the details below.';
                    String tableOpen = '<table>';
                    String tableClose = '</table>';
                    String headerOpen = '<th>';
                    string headerClose = '</th>';
                    string rowOpen = '<tr>';
                    string rowClose = '</tr>';
                    String descriptionOpen = '<td>';
                    String descriptionClose = '</td>';
                    String instanceURL = URL.getSalesforceBaseUrl().toExternalForm();
                    
                    //List of emailId
                    List<String> emailIds = new List<String>();
                    
                    
                    //Check if the Label have multiple Email Adress. 
                    if(System.Label.Product_Lead_Duplicate_Alert_Emails.contains(','))        
                        for(String eId : (System.Label.Product_Lead_Duplicate_Alert_Emails).split(','))
                            emailIds.add(eId);
                    else
                        emailIds.add(System.Label.Product_Lead_Duplicate_Alert_Emails);
            
                    String finalTable = emailBody + '</br></br>' + tableOpen + headerOpen + 'Product Lead URL' + headerClose;
                    String subject = duplicatedProductLeads.size() > 1 ? 'Duplicate Product Leads Detected' : 'Duplicate Product Lead Detected';
                    
                    for(Product_Lead__c pL : duplicatedProductLeads) {
                        
                            
                         String rowDetails =   rowOpen +  descriptionOpen +  instanceURL + '/' + pL.Id +  descriptionClose + rowClose;
                         finalTable += rowDetails + '</br>';
                    }
                    
                    finalTable += tableClose + '</br>' + 'Thanks!';
                    
                    System.debug(finalTable);
                    EmailHandler.createEmail(emailIds, subject, '', finalTable, true);
                }
            }
        }       
    }
    
    /** 
      * Description     :   This Method is used to reparent the child records of duplicate product leads to winning product Lead.
      *
      * Created By      :   Mahendra Swarnkar
      *
      * Created Date    :   04/19/2019
      *
      * Revision Log    :   V1.1 - Created - CR-20181130-12772
      *
    **/
    public static void reparentChilds(String ObjectName, Map<Id, Product_Lead__c> mapProductLeads, Map<String, Product_Lead__c> MapExternalIdWithProductLeadsToBeUpdated){
        
        
        //Chekc for size
        if(mapProductLeads.size() > 0 != null && mapProductLeads.values() != null && mapProductLeads.values().size() > 0 ){
            
            //Lists to hold the child records to be updates
            List<Task> listTaskToBeUpdated = new List<Task>();
            List<Event> listEventToBeUpdated = new List<Event>();
            List<Opportunity> listOpportunityToBeUpdated = new List<Opportunity>();
            List<Note> listNotesToBeUpdated = new List<Note>();
            List<Attachment> listAttachmentsToBeUpdated = new List<Attachment>();
            List<CampaignMember> listCampaignMembersToBeUpdated = new List<CampaignMember>();
            
            // Reparent the Task
            if(ObjectName == 'Task') {
                
                //Query task records
                for(Task tsk : [Select Id, WhatId From Task where WhatId IN : mapProductLeads.keySet()]){
                    Product_Lead__c prodLead = mapProductLeads.get(tsk.WhatId);
                    
                    //Check for conditions
                    if(prodLead.Contact__c != null && prodLead.Contact__r.Counter_ID__c != null  && prodLead.Program__c != null && prodLead.Program__r.Counter_ID__c != null) {
                        
                        //Get the external Id
                        String exterId = prodLead.Contact__r.Counter_ID__c + '_' + prodLead.Program__r.Counter_ID__c;
                        // Get the winning product lead record Id and reparent the task records
                        if(String.IsNotBlank(exterId) && MapExternalIdWithProductLeadsToBeUpdated != null 
                            && MapExternalIdWithProductLeadsToBeUpdated.containsKey(exterId) 
                            && MapExternalIdWithProductLeadsToBeUpdated.get(exterId) != null){
                            
                            tsk.WhatId = MapExternalIdWithProductLeadsToBeUpdated.get(exterId).Id;
                            
                            //Populate the List
                            listTaskToBeUpdated.add(tsk);   
                        }
                    }
                }
            // Reparent the Event
            } else if(ObjectName == 'Event'){
                
                //Query event records
                for(Event evt : [Select Id, WhatId From Event where WhatId IN : mapProductLeads.keySet()]){
                    Product_Lead__c prodLead = mapProductLeads.get(evt.WhatId);
                    
                    //Check for conditions
                    if(prodLead.Contact__c != null && prodLead.Contact__r.Counter_ID__c != null  
                        && prodLead.Program__c != null && prodLead.Program__r.Counter_ID__c != null) {
                        
                        //Get the external Id
                        String exterId = prodLead.Contact__r.Counter_ID__c + '_' + prodLead.Program__r.Counter_ID__c;
                        
                        // Get the winning product lead record Id and reparent the event records
                        if(String.IsNotBlank(exterId) && MapExternalIdWithProductLeadsToBeUpdated != null 
                            && MapExternalIdWithProductLeadsToBeUpdated.containsKey(exterId) 
                            && MapExternalIdWithProductLeadsToBeUpdated.get(exterId) != null){
                            
                            evt.WhatId = MapExternalIdWithProductLeadsToBeUpdated.get(exterId).Id;
                            
                            //Populate the List
                            listEventToBeUpdated.add(evt);  
                        }
                    }
                }
                
            // Reparent the Opportunity
            } else if(ObjectName == 'Opportunity'){
                
                //Query Opportunity records
                for(Opportunity opp : [Select Id, Product_Lead__c From Opportunity where Product_Lead__c != null AND Product_Lead__c IN : mapProductLeads.keySet()]){
                    Product_Lead__c prodLead = mapProductLeads.get(opp.Product_Lead__c);
                    
                    //Check for conditions
                    if(prodLead.Contact__c != null && prodLead.Contact__r.Counter_ID__c != null  
                        && prodLead.Program__c != null && prodLead.Program__r.Counter_ID__c != null) {
                        
                        //Get the external Id
                        String exterId = prodLead.Contact__r.Counter_ID__c + '_' + prodLead.Program__r.Counter_ID__c;
                        
                        // Get the winning product lead record Id and reparent the opporunity records
                        if(String.IsNotBlank(exterId) && MapExternalIdWithProductLeadsToBeUpdated != null 
                            && MapExternalIdWithProductLeadsToBeUpdated.containsKey(exterId) 
                            && MapExternalIdWithProductLeadsToBeUpdated.get(exterId) != null){
                            
                            opp.Product_Lead__c = MapExternalIdWithProductLeadsToBeUpdated.get(exterId).Id;
                            
                            //Populate the List
                            listOpportunityToBeUpdated.add(opp);    
                        }
                    }
                }
                
            // Reparent the Notes
            } else if(ObjectName == 'Note') {
                
                //Query Notes  records
                for(Note proLeadNotes : [Select Id, ParentId From Note where ParentId IN : mapProductLeads.keySet()]){
                    Product_Lead__c prodLead = mapProductLeads.get(proLeadNotes.ParentId);
                    
                    //Check for conditions
                    if(prodLead.Contact__c != null && prodLead.Contact__r.Counter_ID__c != null  
                        && prodLead.Program__c != null && prodLead.Program__r.Counter_ID__c != null) {
                        
                        //Get the external Id
                        String exterId = prodLead.Contact__r.Counter_ID__c + '_' + prodLead.Program__r.Counter_ID__c;
                        
                        // Get the winning product lead record Id and reparent the Notes records
                        if(String.IsNotBlank(exterId) && MapExternalIdWithProductLeadsToBeUpdated != null 
                            && MapExternalIdWithProductLeadsToBeUpdated.containsKey(exterId) 
                           && MapExternalIdWithProductLeadsToBeUpdated.get(exterId) != null){
                            
                            proLeadNotes.ParentId = MapExternalIdWithProductLeadsToBeUpdated.get(exterId).Id;
                            
                            //Populate the List
                            listNotesToBeUpdated.add( proLeadNotes);
                        }
                    }
                }
                
                // Reparent the Attachments
            } else if(ObjectName == 'Attachment') {
                
                //Query Attachments records
                for(Attachment proLeadAttachment : [Select Id, ParentId From Attachment where ParentId IN : mapProductLeads.keySet()]){
                    Product_Lead__c prodLead = mapProductLeads.get(proLeadAttachment.ParentId);
                    
                    //Check for conditions
                    if(prodLead.Contact__c != null && prodLead.Contact__r.Counter_ID__c != null  
                        && prodLead.Program__c != null && prodLead.Program__r.Counter_ID__c != null) {
                        
                        //Get the external Id
                        String exterId = prodLead.Contact__r.Counter_ID__c + '_' + prodLead.Program__r.Counter_ID__c;
                        
                        // Get the winning product lead record Id and reparent the Attachments records
                        if(String.IsNotBlank(exterId) && MapExternalIdWithProductLeadsToBeUpdated != null 
                            && MapExternalIdWithProductLeadsToBeUpdated.containsKey(exterId) 
                           && MapExternalIdWithProductLeadsToBeUpdated.get(exterId) != null){
                            
                            proLeadAttachment.ParentId = MapExternalIdWithProductLeadsToBeUpdated.get(exterId).Id;
                            
                            //Populate the List
                            listAttachmentsToBeUpdated.add( proLeadAttachment);
                        }
                    }
                }
            } else if(ObjectName == 'CampaignMember') {
                
                //Query Attachments records
                for(CampaignMember cMember : [Select Id, Product_Lead__c From CampaignMember where Product_Lead__c != null AND Product_Lead__c IN : mapProductLeads.keySet()]){
                    Product_Lead__c prodLead = mapProductLeads.get(cMember.Product_Lead__c);
                    
                    //Check for conditions
                    if(prodLead.Contact__c != null && prodLead.Contact__r.Counter_ID__c != null  
                        && prodLead.Program__c != null && prodLead.Program__r.Counter_ID__c != null) {
                        
                        //Get the external Id
                        String exterId = prodLead.Contact__r.Counter_ID__c + '_' + prodLead.Program__r.Counter_ID__c;
                        
                        // Get the winning product lead record Id and reparent the Attachments records
                        if(String.IsNotBlank(exterId) && MapExternalIdWithProductLeadsToBeUpdated != null 
                            && MapExternalIdWithProductLeadsToBeUpdated.containsKey(exterId) 
                           && MapExternalIdWithProductLeadsToBeUpdated.get(exterId) != null){
                            
                            cMember.Product_Lead__c = MapExternalIdWithProductLeadsToBeUpdated.get(exterId).Id;
                            
                            //Populate the List
                            listCampaignMembersToBeUpdated.add( cMember);
                        }
                    }
                }
            }
            
            //Bypassing the triggers and updating the Lists.
            Util.BypassAllTriggers = true;
            
            if(listTaskToBeUpdated.size() > 0)
                update listTaskToBeUpdated;
                
            if(listEventToBeUpdated.size() > 0)
                update listEventToBeUpdated;
                
            if(listOpportunityToBeUpdated.size() > 0)
                update listOpportunityToBeUpdated;
                
            if(listNotesToBeUpdated.size() > 0)
                update listNotesToBeUpdated;
                
            if(listAttachmentsToBeUpdated.size() > 0)
                update listAttachmentsToBeUpdated;
            
            Util.BypassAllTriggers = false;
            
            if(listCampaignMembersToBeUpdated.size() > 0)
                update listCampaignMembersToBeUpdated;
        }
    }
    
    //Modified By Rajeev Jain -09/28/2020 - CR-20200917-14522 
    public static void updateMaildate(List<Product_Lead__c> newProductLeads, Map<Id, Product_Lead__c> oldMapProductLead ) 
    {
        if(newProductLeads.size() > 0) {
            for(Product_Lead__c pL : newProductLeads)
            {
                //Modified By - Neha Sharma - 2020/10/09 - Added null checks
                if(oldMapProductLead != null && oldMapProductLead.containsKey(pL.Id) && oldMapProductLead.get(pL.Id).Stage__c != pL.Stage__c && pL.Stage__c != 'AQL')
                {
                    pL.Hot_Lead_Mail_Date__c = null;
                }
            }
        }
        
    }    
    
    /** 
      * Description     :   This Method is used to Automated email notification to PDR for hot lead
      *
      * Created By      :   Dipesh Gupta
      *
      * Created Date    :   05/07/2020
      *
      * Revision Log    :   V1.3 - Created - Dipesh Gupta -05/07/2020 - CR-20200429-14006 (Automated email notification to PDR for hot lead)
      * 					Modified By - Neha Sharma - CR-20210129-14857 - 03/01/2021 - Update Logic for Hot Lead Trigger
      *
    **/
    public static void sendMailToProductOwner(List<Product_Lead__c> newProductLeads, Map<Id, Product_Lead__c> oldMapProductLead ) 
    {
        List<Product_Lead__c> productLeadMailList = new List<Product_Lead__c>();
         List<Product_Lead__c> productLeadToBeUpdated = new List<Product_Lead__c>();
        Set<Id> userIds = new set<Id>();
        Map<Id,User> mapOfUsers = new Map<Id,User>();
        
        //Modified By - Neha Sharma - CR-20210129-14857 - 03/01/2021 - Update Logic for Hot Lead Trigger
        List<Product_Lead__c> productLeasdList = [Select Id,OwnerId,owner.Name,Stage__c,owner.Email, Program__r.Name,Hot_Lead_Mail_Date__c,
                                                  (Select Id,Status,Request_Demo_Mail_Date__c 
                                                   From Campaign_Members__r 
                                                   WHERE (Status =: System.Label.Requested_Demo OR Status = 'Requested Follow Up')) 
                                                  FROM Product_Lead__c 
                                                  Where Id IN : newProductLeads];
        if(productLeasdList.size() > 0)
        {
            Map<Product_Lead__c, List<CampaignMember>> mapOfProductLeadWithCampMembers = new Map<Product_Lead__c, List<CampaignMember>>();

            Boolean campMembermailSend = false;
            for(Product_Lead__c pL : productLeasdList)
            {
                Product_Lead__c productLead = new Product_Lead__c();
                if(((pL.Stage__c == 'AQL' && oldMapProductLead.get(pL.Id).ownerId == System.Label.Marketo_Sync_Owner_Id && oldMapProductLead.get(pL.Id).ownerId != pL.OwnerId) 
                     ||(oldMapProductLead.get(pL.Id).ownerId != System.Label.Marketo_Sync_Owner_Id && oldMapProductLead.get(pL.Id).Stage__c != pL.Stage__c && pL.Stage__c == 'AQL')
                    ) && pL.Campaign_Members__r.size() > 0)                    
                {

                    //Modified By Rajeev Jain -09/28/2020 - CR-20200917-14522 - Add the criteria to send hot lead mail for past week
                    for(campaignMember camp : pL.Campaign_Members__r)
                    {   
                         Date requestDemoMailDate = camp.Request_Demo_Mail_Date__c != null ? (Date.newInstance(camp.Request_Demo_Mail_Date__c.year(),camp.Request_Demo_Mail_Date__c.month(), camp.Request_Demo_Mail_Date__c.day())) : null;
                   
                         if(camp.Request_Demo_Mail_Date__c == null)
                         {
                            camp.Request_Demo_Mail_Date__c = system.today();
                            campMembermailSend = true;
                         }  
                        else{
                            if(system.today() <= requestDemoMailDate.addDays(7) && system.today() >= camp.Request_Demo_Mail_Date__c){
                                campMembermailSend = true;
                            } 
                        }

                        if(!mapOfProductLeadWithCampMembers.containsKey(pL))
                            mapOfProductLeadWithCampMembers.put(pL, new List<CampaignMember>{camp});
                        else
                            mapOfProductLeadWithCampMembers.get(pL).add(camp);
                    }
                    
                    if(pL.Hot_Lead_Mail_Date__c == null)
                         pL.Hot_Lead_Mail_Date__c = system.today();
                    
                    productLead.Hot_Lead_Mail_Date__c = system.today();
                    productLead.Id = pL.Id;
                    productLeadToBeUpdated.add(productLead);
                    
                    //Modified By Rajeev Jain -09/28/2020 - CR-20200917-14522 - Add the criteria to send hot lead mail for past week
                    Date hotMailDate = Date.newInstance(pL.Hot_Lead_Mail_Date__c.year(),pL.Hot_Lead_Mail_Date__c.month(), pL.Hot_Lead_Mail_Date__c.day());
                    if((pL.Hot_Lead_Mail_Date__c != null && 
                        system.today() <= hotMailDate.addDays(7) && 
                        system.today() >= pL.Hot_Lead_Mail_Date__c
                       ) 
                       && 
                       (campMembermailSend == true))
                    {
                         productLeadMailList.add(pL);
                         userIds.add(pL.OwnerId);
                    }
                }
               
            }
            
            if(userIds.size() > 0)
            {
                  for(User usr : [Select id,Manager.Email,Email from user where Id IN: userIds])
                  {
                      mapOfUsers.put(usr.Id,usr);
                  }
            }
            
            if(productLeadToBeUpdated.size() > 0){
                update productLeadToBeUpdated;
            }
            if(productLeadMailList.size() > 0)
            {
                //Modified By - Neha Sharma - CR-20210129-14857 - 03/01/2021 - Update Logic for Hot Lead Trigger
                if(mapOfUsers.size() > 0)
                    //sendEmail(productLeadMailList,mapOfUsers);
                    sendEmail(mapOfProductLeadWithCampMembers,mapOfUsers);
            }
        }
        //Modified By Rajeev Jain -09/28/2020 - CR-20200917-14522 - End here
    }
    
    //Modified By - Neha Sharma - CR-20210129-14857 - 03/01/2021 - Update Logic for Hot Lead Trigger
    //Modified By Rajeev Jain -09/28/2020 - CR-20200917-14522 - Add the logic to send mail to manager of record owner also.
    //Modified By - Chirag Soni - CR-20220224-15942 - 04/14/2022 - updated method sendEmail() - added not null check for cc email
    //public static void sendEmail(List<Product_Lead__c> productLeasdList, Map<Id,user> mapOfUsers)
    public static void sendEmail(Map<Product_Lead__c, List<CampaignMember>> productLeasdList, Map<Id,user> mapOfUsers)
    {
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        String systemUrl = String.valueOf(System.Url.getSalesforceBaseUrl());
        String baseUrl = systemUrl.substring(systemUrl.indexOf('=')+1,systemUrl.indexOf('.com')+4);
        for(Product_Lead__c pl : productLeasdList.keySet())
        {
            //Added By - Neha Sharma - CR-20210129-14857 - 03/01/2021 - To check mail send for Request Demo or Requested Follow Up
            Boolean sendEmailForRequestesDemo = false;
            Boolean sendEmailForRequestesFollowUp = false;

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            List<String> ccAddresses = new List<String>();
            if(mapOfUsers.size() > 0 && mapOfUsers.containskey(pl.OwnerId))
            {
                sendTo.add(mapOfUsers.get(pl.OwnerId).Email);
                
                //Modified By - Chirag Soni - CR-20220224-15942 - 04/14/2022 - updated method sendEmail() - added not null check for cc email
                if(mapOfUsers.get(pl.OwnerId).Manager.Email != null)
                    
                {
                    ccAddresses.add(mapOfUsers.get(pl.OwnerId).Manager.Email);
                }
            }

            if(productLeasdList.values().size() > 0) {

                for(CampaignMember campMem : pL.Campaign_Members__r)
                {
                    
                    if(campMem.Status == System.Label.Requested_Demo)
                        sendEmailForRequestesDemo = true;
					//Added By - Neha Sharma - CR-20210129-14857 - 03/01/2021 - Update Logic for Hot Lead Trigger
                    if(campMem.Status == 'Requested Follow Up')
                        sendEmailForRequestesFollowUp = true;
                } 
            }
            //Modified By - Neha Sharma - CR-20210129-14857 - 03/01/2021 - Update Logic for Hot Lead Trigger
            if(sendEmailForRequestesFollowUp) {
                mail.setToAddresses(sendTo);
                mail.setCCAddresses(ccAddresses);
                mail.setSubject('Requested Follow Up/Hot Lead Notification');
                String body = ' You have received a Hot Lead for '+ pl.Program__r.Name +'. This means this person has requested a follow up of your product. Please send outreach (call and/or email) within one hour. ';
                body += '<br/><br/><br/>'+baseUrl+'/'+pl.Id;
                mail.setHtmlBody(body);
                mails.add(mail);
            }
            if(sendEmailForRequestesDemo) {
                mail.setToAddresses(sendTo);
                mail.setCCAddresses(ccAddresses);
                mail.setSubject('Demo Request/Hot Lead Notification');
                String body = ' You have received a Hot Lead for '+ pl.Program__r.Name +'. This means this person has requested a demo of your product. Please send outreach (call and/or email) within one hour. ';
                body += '<br/><br/><br/>'+baseUrl+'/'+pl.Id;
                mail.setHtmlBody(body);
                mails.add(mail);
            }
            
        }
        
        Messaging.sendEmail(mails);
    }
}