/**
*  Purpose         :  This Class is having all the automation logic method on Creative Package object.
* 
*  Created By      :  Neha Sharma
*
*  Created Date    :  05/05/2021
*
*  Revision Logs   :   V_1.0 - Created  - CR-20210323-15016
*                  :   V_1.1 - Modified By Mahendra Swarnkar - CR-20210630-15262
**/
public class CreativePackageTriggerhelper {
	
    public static Boolean updatePTonArtFileChangeFutureExecution = False; 
    public static void createBoxFolderForCreativePackage (List<Creative_Package__c> newCreativePackage, Map<Id, Creative_Package__c> oldMapOfCreativePackage) {
		
        //Set to hold the Job Ticket Ids
        Set<ID> setJobTicketIds = new Set<ID>();
        
        //get new creative package records
        for(Creative_Package__c creativePack : newCreativePackage) {
			
            if(creativePack.Job_Ticket__c != null && (creativePack.Box_Folder_Link__c == null || creativePack.Box_Folder_Id__c == null)
               &&(oldMapOfCreativePackage == null 
                  || (oldMapOfCreativePackage != null && oldMapOfCreativePackage.get(creativePack.Id).Job_Ticket__c != creativePack.Job_Ticket__c)
                 )
			) {
                setJobTicketIds.add(creativePack.Job_Ticket__c);
            }
        }
        
        if(setJobTicketIds.size() > 0){
            
            Map<Id, Job_Ticket__c> mapJobTickets = new Map<Id, Job_Ticket__c>([Select ID, Creative_Package_Box_Folder_Id__c, Creative_Package_BOX_Folder_Link__c From Job_Ticket__c where ID IN : setJobTicketIds]);
            
            if(mapJobTickets != null && mapJobTickets.size() > 0){
                
                Set<Id> setJobTicketIdsToCreateCreativePackageBoxFolder = new Set<Id>(); 
                //get new creative package records
                for(Creative_Package__c cPackage : newCreativePackage) {
                    
                    if(cPackage.Job_Ticket__c != null && mapJobTickets.containsKey(cPackage.Job_Ticket__c) && mapJobTickets.get(cPackage.Job_Ticket__c) != null
                       && (cPackage.Box_Folder_Link__c == null || cPackage.Box_Folder_Id__c == null))
                    {
                    	
                        if(mapJobTickets.get(cPackage.Job_Ticket__c).Creative_Package_Box_Folder_Id__c != null) {
                        	cPackage.Box_Folder_Id__c = mapJobTickets.get(cPackage.Job_Ticket__c).Creative_Package_Box_Folder_Id__c;    
                        } else{
                            setJobTicketIdsToCreateCreativePackageBoxFolder.add(cPackage.Job_Ticket__c);
                        }
                        
                        if(mapJobTickets.get(cPackage.Job_Ticket__c).Creative_Package_BOX_Folder_Link__c != null) {
                        	cPackage.Box_Folder_Link__c = mapJobTickets.get(cPackage.Job_Ticket__c).Creative_Package_BOX_Folder_Link__c;    
                        }
                    }  
                }
                if(setJobTicketIdsToCreateCreativePackageBoxFolder.size() > 0){
                 	
                    //Added By - Neha Sharma - 04/29/2020 - CR-20210323-15016 - Calling a another batch job that will run for creative package. 
                    Batch_CreateBoxFolderForCreativePackage batchCreativePackage = new Batch_CreateBoxFolderForCreativePackage(setJobTicketIdsToCreateCreativePackageBoxFolder);
                    Database.executeBatch(batchCreativePackage, Integer.valueOf(Label.ProductionTracking_BoxBatchSize));
                }
			}
		}
	}
    
    public static void beforeTriggerLogic (List<Creative_Package__c> newCreativePackage, Map<Id, Creative_Package__c> oldMapOfCreativePackage) {
        
        //get new creative package records
        for(Creative_Package__c creativePack : newCreativePackage) {
			
            if(String.isNotBlank(creativePack.Art_File_Name__c) && oldMapOfCreativePackage != null && oldMapOfCreativePackage.get(creativePack.Id).Art_File_Name__c != creativePack.Art_File_Name__c) {
                creativePack.Approval_Status__c = Constants.CREATIVE_PACKAGE_APPROVAL_STATUS;
            }
        }
    }
    
    //Modified by Mahendra Swarnkar - CR-20210630-15262
    public static void updatePTonArtFileChange (Map<Id, Creative_Package__c> newCreativePackage, Map<Id, Creative_Package__c> oldMapOfCreativePackage) {
        updatePTonArtFileChangeFutureExecution = true;
        //Set to hold the Job Ticket Ids
        Set<ID> setCreativePackageIds = new Set<ID>();
        Set<ID> setJobTicketIds = new Set<ID>();
        Map<Id, List<Production_Tracking__c>> mapcreativePackageIdWithProductionTrackings = new Map<Id, List<Production_Tracking__c>>();
        //get new creative package records
        for(Creative_Package__c creativePack : newCreativePackage.values()) {
			
            if( String.isNotBlank(creativePack.Art_File_Name__c) && oldMapOfCreativePackage != null && oldMapOfCreativePackage.get(creativePack.Id).Art_File_Name__c != creativePack.Art_File_Name__c) {
                setJobTicketIds.add(creativePack.Job_Ticket__c);
                setCreativePackageIds.add(creativePack.Id);
                mapcreativePackageIdWithProductionTrackings.put(creativePack.Id, new List<Production_Tracking__c>());
            }
        }
        
        if(setCreativePackageIds.size() > 0){
            
            Set<String> statusDetails = new Set<String>{Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED, Constants.PRODUCTION_TRACKING_STATUS_DETAIL_PENDING_APPROVAL, Constants.PRODUCTION_TRACKING_STATUS_DETAIL_PENDING_MAIL_DATE_CONFIRMATION, Constants.PRODUCTION_TRACKING_STATUS_DETAIL_MAIL_DATE_CONFIRMED};
            Map<Id, Production_Tracking__c> jobTicketIdWithHighestDropPT = new Map<Id, Production_Tracking__c>();
            
            //Creative_Package__c != null AND Creative_Package__c IN : setCreativePackageIds /*AND Drop_Type__c =: 'On Demand'*/
            for(Production_Tracking__c prodTrack : [Select Id, Status__c, Status_Detail__c, Creative_Package__c, Drop__c, Job_Ticket__c 
                                                     FROM Production_Tracking__c 
                                                     Where RecordType.DeveloperName =: Constants.PRODUCTION_TRACKING_RECORDTYPE_MAIL_SHOP AND Job_Ticket__c != null AND Job_Ticket__c IN : setJobTicketIds ORDER BY Drop__c DESC nulls Last])
            {
                if(!jobTicketIdWithHighestDropPT.containsKey(prodTrack.Job_Ticket__c)){
                    jobTicketIdWithHighestDropPT.put(prodTrack.Job_Ticket__c, prodTrack);
                }
                
            	if(prodTrack.Creative_Package__c != null && setCreativePackageIds.contains(prodTrack.Creative_Package__c)){
                    
                    //Modified by Mahendra Swarnkar - CR-20210630-15262 - Added check for "Approved by Partner"
                    if(prodTrack.Status__c  == Constants.PRODUCTION_TRACKING_STATUS_APPROVED_BY_CLIENT || prodTrack.Status__c == Constants.PRODUCTION_TRACKING_STATUS_PROOF || (prodTrack.Status__c == Constants.PRODUCTION_TRACKING_STATUS_LIVE_PROOF && statusDetails.contains(prodTrack.Status_Detail__c))){
                        
                        if(mapcreativePackageIdWithProductionTrackings.containsKey(prodTrack.Creative_Package__c)) {
                            
                            prodTrack.Status__c = Constants.PRODUCTION_TRACKING_STATUS_PROOF;
                            prodTrack.Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED;
                            //prodTrack.Bypass_Color_Calibration__c = true;
                            prodTrack.Art_File_Name__c = newCreativePackage.get(prodTrack.Creative_Package__c).Art_File_Name__c;
                            mapcreativePackageIdWithProductionTrackings.get(prodTrack.Creative_Package__c).add(prodTrack);
                        }	
                    }
                }
            }
            
            List<Production_Tracking__c> listProductionTrackingToUpdate = new List<Production_Tracking__c>();
            for(Id cretivePackId : mapcreativePackageIdWithProductionTrackings.keySet()){
                
                if(mapcreativePackageIdWithProductionTrackings.get(cretivePackId).size() > 0)
                    listProductionTrackingToUpdate.addAll(mapcreativePackageIdWithProductionTrackings.get(cretivePackId));
            }
            
            if(listProductionTrackingToUpdate.size() > 0)
                update listProductionTrackingToUpdate;
            
            listProductionTrackingToUpdate = new List<Production_Tracking__c>();
            
            Set<Id> setOfJobTicketIds = new Set<Id>();
            
            for(Id cretivePackId : mapcreativePackageIdWithProductionTrackings.keySet()) {
                
                if(mapcreativePackageIdWithProductionTrackings.get(cretivePackId).size() <= 0 ){
					
                    Id jobTicketId = newCreativePackage.get(cretivePackId).Job_Ticket__c;
                    setOfJobTicketIds.add(jobTicketId);
                    
                    //Insert Production Tracking record.
                    Production_Tracking__c prodTracking = new Production_Tracking__c();
                    prodTracking.RecordTypeId = Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByName().get('Mail Shop').getRecordTypeId();
                    prodTracking.Creative_Package__c = cretivePackId;
                    prodTracking.Job_Ticket__c = newCreativePackage.get(cretivePackId).Job_Ticket__c;
                    prodTracking.Proof_Generation__c = Constants.PRODUCTION_TRACKING_PROOF_GENERATION_INTERNAL;
                    prodTracking.Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED;
                    //prodTracking.Status__c = 'Proof';
                    //prodTracking.Status_Detail__c = 'Submitted';
                    prodTracking.Drop__c = (jobTicketIdWithHighestDropPT.size() > 0 && jobTicketIdWithHighestDropPT.containsKey(jobTicketId) && jobTicketIdWithHighestDropPT.get(jobTicketId) != null && jobTicketIdWithHighestDropPT.get(jobTicketId).Drop__c != null) ? (jobTicketIdWithHighestDropPT.get(jobTicketId).Drop__c + 1) : 1 ; //(Get all PT records associated with this CPKG.  If this is the first PT, Drop # = 1, otherwise Sort by Drop # and use the largest Drop # + 1.  Also populate PT.Previous Production Tracking if there was a previous PT)
                    prodTracking.Previous_Production_Tracking__c = (jobTicketIdWithHighestDropPT.size() > 0 && jobTicketIdWithHighestDropPT.containsKey(jobTicketId) && jobTicketIdWithHighestDropPT.get(jobTicketId) != null) ? jobTicketIdWithHighestDropPT.get(jobTicketId).ID : null;
                    prodTracking.Drop_Type__c = Constants.PRODUCTION_TRACKING_DROP_TYPE;
                    //prodTracking.Bypass_Color_Calibration__c = true;
                    prodTracking.Art_File_Name__c = newCreativePackage.get(cretivePackId).Art_File_Name__c;
                    
                    
                    listProductionTrackingToUpdate.add(prodTracking);
                }
            }
            
            if(listProductionTrackingToUpdate.size() > 0){
                insert listProductionTrackingToUpdate;
                Batch_CreateBoxFolderForPT batchProductionTracking = new Batch_CreateBoxFolderForPT(setOfJobTicketIds);
                Database.executeBatch(batchProductionTracking, Integer.valueOf(Label.ProductionTracking_BoxBatchSize));
                
                Set<ID> productionIds = new Set<ID>();
                for(Production_Tracking__c prodTracking : listProductionTrackingToUpdate){
                    productionIds.add(prodTracking.Id);  
                    //prodTracking.Status__c = Constants.PRODUCTION_TRACKING_STATUS_PROOF;
		    //prodTracking.Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED;
                }
                if(productionIds.size() > 0){
                    updatePTonArtFileChangeFuture(productionIds);    
                }
                
                //update listProductionTrackingToUpdate;
            }
                
        }
    }
    
    //Modified by Mahendra Swarnkar - CR-20210630-15262
    @future
    public static void updatePTonArtFileChangeFuture(Set<ID> productionIds){
        List<Production_Tracking__c> listProductionTrackingToUpdate = new List<Production_Tracking__c>();
        for(Id prodId : productionIds){
            Production_Tracking__c prodTracking = new Production_Tracking__c(Id = prodId);  
            prodTracking.Status__c = Constants.PRODUCTION_TRACKING_STATUS_PROOF;
            prodTracking.Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED;
            listProductionTrackingToUpdate.add(prodTracking);
        }
        
        if(listProductionTrackingToUpdate.size() > 0)
	    update listProductionTrackingToUpdate;
    }
}