/**
 *  Purpose         :	Helper methods for Artifact Transfer
 *
 *  Revision Logs   :	V_1.0 - 04/09/2020 - Victor Hanson - Created
 * 			V_1.1 - 05/19/2020 - Victor Hanson - CR-20200515-14047 - added logic to updateJobTicket to send live proofs to approval
 * 			V_1.2 - 05/28/2020 - Victor Hanson - CR-20200527-14113 - Updated so it only sends the callout when artifact transfer is successful
 *                      V_1.2 - 06/03/2020 - Victor Hanson - CR-20200603-14137 - added populateArtifactTransferFields method
 * 			V_1.3 - 06/17/2020 - Victor Hanson - CR-20200610-14165 - updated updatesOnArtifactStatusChange
 * 			V_1.4 - 08/17/2020 - Victor Hanson - CR-20200803-14397 - added checkStatus
 *			V_1.5 - 11/17/2020 - Victor Hanson - CR-20201012-14597 
 *			V_1.6 - 05/24/2021 - Abhinav Sharma - CR-20210524-15178 - To remove the un-necessary system.debug statements and to proper indent the code.
 *          		V_1.7 - 05/18/2021 - Neha Sharma  - CR-20200701-14253 - Check if the the Status is Changed to Transferring
 * 			V_1.8 - 07/19/2021 - Shalu Sharma - CR-20210719-15296 - Add "Mail_Shop_Vendor__c" field in Query
 *                     
**/
public class ArtifactTransferHelper {
	
    public static final String STATUS_SUCCESS = 'Success';
    public static final String DIRECTION_PULL = 'Pull';
    public static final String DIRECTION_PUSH = 'Push';
    public static final String PRODUCTION_TRACKING_STATUS_PENDING_APPROVAL = 'Pending Approval';
    public static final String FAILURE = 'Failure';
    public static final String FILE_ISSUE = 'File Issue';
    
    /**
     *  Purpose         :	when the "push" records are getting set to "Transfer Now" after the "pull" record is marked as "success"
     *
     *  Revision Logs   :	V_1.0 - Created - 04/09/2020 - Victor Hanson - Created
     *                     
    **/
    public static void updatePushToTransferNow(List<Artifact_Transfer__c> aTransfers, Map<Id, Artifact_Transfer__c> oldMapATransfers) {
        
        //list of artifact transfers to update
        List<Artifact_Transfer__c> artifactTransfersToUpdate = new List<Artifact_Transfer__c>();
        
        //get artifact ids
        Set<Id> artifactIds = new Set<Id>();
        for (Artifact_Transfer__c newAT : aTransfers) artifactIds.add(newAT.Artifact__c);
        
        //get a map of artifacts with child artifact transfers
        Map<Id, Artifact__c> mapArtifactsWithPushTransfers = new Map<Id, Artifact__c>([SELECT Id, 
                                                                                       (SELECT Id, Status__c FROM Artifact_Transfers__r
                                                                                        WHERE Direction__c = :DIRECTION_PUSH AND Id NOT IN :aTransfers)
                                                                                       FROM Artifact__c WHERE Id IN :artifactIds]);
        
        ////VH
        //get a map of Artifacts with the number of Artifact Transfers
        /*Set<Id> artIds = new Set<Id>();
        for (Artifact_Transfer__c at : aTransfers) artIds.add(at.Artifact__c);
        Map<Id, Artifact__c> artifactMap = new Map<Id, Artifact__c>([SELECT Id, (SELECT Id FROM Artifact_Transfers__r) FROM Artifact__c WHERE Id IN :artIds]);
        */
        
        for (Artifact_Transfer__c newAT : aTransfers) {
            Artifact_Transfer__c oldAT;
            if (oldMapATransfers != null) oldAT = oldMapATransfers.get(newAT.Id);
            
            //if the pull transfer completed successfully, start the push
            if (oldAT != null && newAT.Direction__c == DIRECTION_PUSH && newAT.Status__c == STATUS_SUCCESS && oldAT.Status__c != newAT.Status__c) {
                Artifact__c artifact = mapArtifactsWithPushTransfers.get(newAT.Artifact__c);
                for (Artifact_Transfer__c pushAT : artifact.Artifact_Transfers__r) {
                    pushAT.Status__c = Constants.ARTIFACT_STATUS_TRANSFER_NOW;
                    pushAT.Source_File_Name_Exact__c = newAT.Target_File_Name__c;
                    artifactTransfersToUpdate.add(pushAT);
                }
            }
            
            //also,  if this is the only Artifact Transfer, regardless of direction, update status to Transfer Now
            //get artifact with artifact transfer count
            /*Artifact__c artifact = artifactMap.get(newAT.Artifact__c);
            if (artifact != null && artifact.Artifact_Transfers__r.size() == 1) {
                Artifact_Transfer__c atToUpdate = new Artifact_Transfer__c(Id = newAT.Id,
                                                                           Status__c = Constants.ARTIFACT_STATUS_TRANSFER_NOW);
                artifactTransfersToUpdate.add(atToUpdate);
            }*/
        }
        
        //update the artifact transfers
        if (artifactTransfersToUpdate.size() > 0) 
        {
            update artifactTransfersToUpdate;
        }
    }
    
    /**
     *  Purpose         :	Update the job ticket when certain Artifact Transfers are completed
     *
     *  Revision Logs   :	V_1.0 - Created - 04/09/2020 - Victor Hanson - Created
     * 				V_1.1 - 05/19/2020 - Victor Hanson - CR-20200515-14047 - added logic to send live proofs to approval
     *                     
    **/
    public static void updateJobTicket(List<Artifact_Transfer__c> aTransfers, Map<Id, Artifact_Transfer__c> oldMapATransfers) {
        
        //job tickets to update
        List<Production_Tracking__c> prodTrackingToUpdate = new List<Production_Tracking__c>();
        
        //get artifact ids
        Set<Id> artifactIds = new Set<Id>();
        
        for (Artifact_Transfer__c newAT : aTransfers) artifactIds.add(newAT.Artifact__c);
        
        //get artifacts
        Map<Id, Artifact__c> mapArtifacts = new Map<Id, Artifact__c>([SELECT Id, Type__c, Production_Tracking__c, Production_Tracking__r.Proof_Generation__c, (SELECT Id FROM Artifact_Transfers__r) FROM Artifact__c WHERE Id IN :artifactIds]);
        
        for (Artifact_Transfer__c newAT : aTransfers) 
        {
            Artifact_Transfer__c oldAT;
            if (oldMapATransfers != null) oldAT = oldMapATransfers.get(newAT.Id);
            
            //11/17/2020 - CR-20201012-14597 - Victor Hanson - get artifact to check if it only contains a single ArtTx
            Artifact__c artifact = mapArtifacts.get(newAT.Artifact__c);
            
            System.debug('@@@@@ newAT.Direction__c ' + newAT.Direction__c);
            System.debug('@@@@@ newAT.Direction__c == DIRECTION_PUSH ' + newAT.Direction__c == DIRECTION_PUSH);
            System.debug('@@@@@ artifact?.Artifact_Transfers__r?.size() ' + artifact?.Artifact_Transfers__r?.size());
            System.debug('@@@@@ newAT.Status__c ' + newAT.Status__c);
            if(oldAT != null) {
            	System.debug('@@@@@ oldAT.Status__c ' + oldAT.Status__c);    
                System.debug('@@@@@ oldAT.Status__c != newAT.Status__c ' + oldAT.Status__c != newAT.Status__c);
            }
            
            System.debug('@@@@@ newAT.Status__c == STATUS_SUCCESS ' + newAT.Status__c == STATUS_SUCCESS);
            
            
            //if direction is push and status is changed to success
            if ((newAT.Direction__c == DIRECTION_PUSH || (artifact?.Artifact_Transfers__r?.size() == 1)) 
                && oldAT != null && newAT.Status__c == STATUS_SUCCESS && oldAT.Status__c != newAT.Status__c)
            {
                System.debug('@@@@@ oldAT.Status__c ' + oldAT.Status__c);
                
                //05/19/2020 - Victor Hanson - CR-20200515-14047 - added ARTIFACT_TYPE_LIVE_PROOF_DATA so the prod tracking is sent to approval
                //if type is Artwork Proof or Live Proof, update Status Detail to Pending Approval, which will automatically start an approval process
                if (mapArtifacts.get(newAT.Artifact__c).Type__c == Constants.ARTIFACT_TYPE_ARTWORK_PROOF
                    || mapArtifacts.get(newAT.Artifact__c).Type__c == Constants.ARTIFACT_TYPE_LIVE_PROOF
                    || mapArtifacts.get(newAT.Artifact__c).Type__c == Constants.ARTIFACT_TYPE_READY_TO_PRINT) {
                        
                        System.debug('@@@@@ Come Inside ' + mapArtifacts.get(newAT.Artifact__c).Type__c);
                        
                        //Modify By -Abhinav sharma - 09-09-2020  - CR-20200716-14324 - Added the check to verify record is in approval process or not
                        if(!(Approval.isLocked(mapArtifacts.get(newAT.Artifact__c).Production_Tracking__c)))
                        {
                            
                            System.debug('@@@@@ Deep Inside ' + mapArtifacts.get(newAT.Artifact__c).Production_Tracking__c);
                            
                            //11/15/2020 - CR-20201012-14597 - Victor Hanson - if type=Ready To Print, update Status = Ready For Print
                            if (mapArtifacts.get(newAT.Artifact__c).Type__c == Constants.ARTIFACT_TYPE_READY_TO_PRINT) {
                                prodTrackingToUpdate.add(new Production_Tracking__c(Id=mapArtifacts.get(newAT.Artifact__c).Production_Tracking__c,
                                                                                    Status__c = Constants.PRODUCTION_TRACKING_STATUS_READY_FOR_PRINT));
                            	System.debug('@@@@@ inside if ' + prodTrackingToUpdate);
                            }
                            else {
                                prodTrackingToUpdate.add(new Production_Tracking__c(Id=mapArtifacts.get(newAT.Artifact__c).Production_Tracking__c,
                                                                                    Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_PENDING_APPROVAL));
                            	System.debug('@@@@@ inside else ' + prodTrackingToUpdate);
                            }
                        }
                    }
            }
        }
        
        //update production tracking records
        if (prodTrackingToUpdate.size() > 0) {
            System.debug('@@@@@ prodTrackingToUpdate ' + prodTrackingToUpdate);
            update prodTrackingToUpdate;
        }
    }
    
     /**
     *  Purpose         :	This Method is used to Call the lambda process for the Artifact transfer records When the status is changed.
     *
     *  Revision Logs   :	V_1.0 - Created - 04/10/2020 - Dipesh Gupta
     * 				V_1.1 - Modified - 06/17/2020 - CR-20200610-14165 - Victor Hanson
     *                  :       V_1.2 - Modified By Neha Sharma - 05/18/21 - CR-20200701-14253 - logic to update Artifact Status to Transferring when Artifact Transfer Status changes to Transferring.
     *                     
    **/
    public static void updatesOnArtifactStatusChange(List<Artifact_Transfer__c> newArtifacts, Map<Id, Artifact_Transfer__c> oldArtifactTransfer) {
        
        Set<Id> setArtifactTxIdsWithTxNowStatus = new Set<Id>();
        Set<Id> setArtifactTxIdsForFailures = new Set<Id>();
        Map<Id, Artifact_Transfer__c> mapOfArtifactIdWithTx = new Map<Id, Artifact_Transfer__c>();
        Map<Id, Artifact__c> mapOfArtifactToBeUpdated = new Map<Id, Artifact__c>();
        
        //Check if there is Artifact.
        for(Artifact_Transfer__c artTx : newArtifacts) {
            
            //Check if the Status is changed on Artifact transfer. 
            if(oldArtifactTransfer == null 
               || (oldArtifactTransfer != null 
                   && oldArtifactTransfer.get(artTx.Id).Status__c != artTx.Status__c)) {
                       
                //Check if the the Status is Changed to Transfer 
                if(artTx.Status__c == Constants.ARTIFACT_STATUS_TRANSFER_NOW)  {
                    setArtifactTxIdsWithTxNowStatus.add(artTx.Id);
                } 
                       
                //Check if the the Status is Changed to Success       
                if(artTx.Status__c == STATUS_SUCCESS) {
                    mapOfArtifactIdWithTx.put(artTx.Artifact__c, artTx);
                }
                
		//06/17/2020 - CR-20200610-14165 - Victor Hanson
                //Check if the the Status is Changed to Failure
                if(artTx.Status__c == FAILURE) {
                    mapOfArtifactToBeUpdated.put(artTx.Artifact__c, new Artifact__c(Id = artTx.Artifact__c, Status__c = FAILURE));
                }
                
                //Modified By Neha Sharma - 05/18/21 - CR-20200701-14253 - Check if the the Status is Changed to Transferring
                if(artTx.Status__c == Constants.ARTIFACT_TRANSFER_STATUS_TRANSFERRING) {
                    mapOfArtifactToBeUpdated.put(artTx.Artifact__c, new Artifact__c(Id = artTx.Artifact__c, Status__c = Constants.ARTIFACT_TRANSFER_STATUS_TRANSFERRING));
                }
            }
        }
        
       
       if(mapOfArtifactIdWithTx.size() > 0) {
            
           List<Artifact_Transfer__c> artifactTxToBeUpdated = New List<Artifact_Transfer__c>();
           
            //Getting the Sibling Artifact Tx Records. 
            for(Artifact_Transfer__c artTx : [Select Id, Artifact__c, 
                                              Status__c, Direction__c, 
                                              Source_File_Name_Exact__c  
                                              From Artifact_Transfer__c 
                                              Where Artifact__c =: mapOfArtifactIdWithTx.keySet()
                                              AND Direction__c =: ArtifactTransferHelper.DIRECTION_PUSH
                                              AND Status__c =: Constants.ARTIFACT_STATUS_STAGING]) {
               
                    artTx.Source_File_Name_Exact__c = mapOfArtifactIdWithTx.get(artTx.Artifact__c).Target_File_Name__c;
                    artTx.Status__c = Constants.ARTIFACT_STATUS_TRANSFER_NOW;
                    artifactTxToBeUpdated.add(artTx);                          
            }
           
            if(artifactTxToBeUpdated.size() > 0)
                Update artifactTxToBeUpdated;
           
            //Check if all the Artifact Tx Under a Artifact has been 
        }
        if(mapOfArtifactToBeUpdated.size() > 0) {
            
            //Updating the Artifact Records.
            update mapOfArtifactToBeUpdated.values();
            
            //06/17/2020 - CR-20200610-14165 - Victor Hanson
            //get production tracking and set the statusDetail to File Issue
            //Modified By Neha Sharma - 05/18/21 - CR-20200701-14253 - get production tracking and set the statusDetail to File Issue
            Set<Id> prodTrackingIds = new Set<Id>();
            for (Artifact__c artifact : [SELECT Id, Production_Tracking__c FROM Artifact__c 
                                         WHERE Id IN :mapOfArtifactToBeUpdated.keySet() and Status__c =: FAILURE])
            {
                prodTrackingIds.add(artifact.Production_Tracking__c);
            }
            
            List<Production_Tracking__c> pTracking = [SELECT Id, Status_Detail__c FROM Production_Tracking__c 
                                                      WHERE Id IN :prodTrackingIds];
            for (Production_Tracking__c pt : pTracking) {
                pt.Status_Detail__c = FILE_ISSUE;
            }
            if (pTracking.size() > 0)
                update pTracking;
        }
        
        //If setArtifactTxIdsWithTxNowStatus then call the Enqueue Job That will do the callout. 
        if(setArtifactTxIdsWithTxNowStatus.size() > 0){
            
            //VH 08/16/2020 - CR-20200803-14397 - TODO: Finish on 8/17
            DateTime sysTime = DateTime.now().addMinutes(Integer.valueOf(Label.Artifact_Transfer_Callout_Delay_in_Mins));
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            Sched_CallLambdaProcessOnArtifactTx sched_CallLambdaProcess = new Sched_CallLambdaProcessOnArtifactTx();
            sched_CallLambdaProcess.ListOfArtifactTxIds = new List<Id> (setArtifactTxIdsWithTxNowStatus);
            system.schedule('Sched_CallLambdaProcessOnArtifactTx' + sysTime.getTime() + String.valueOf(Math.random()), chron_exp, sched_CallLambdaProcess);
            
            //VH 08/16/2020 - CR-20200803-14397 - commented out
            //System.enqueueJob(new Enqueue_CallLambdaProcessOnArtifactTx(new List<Id> (setArtifactTxIdsWithTxNowStatus)));
        }
            
    }
    
     /**
     *  Purpose         :	This Method is used to update the Aftifact record if all the artifact transfer under the same artifact status is sucess.
     *
     *  Revision Logs   :	V_1.0 - Created - 04/10/2020 - Dipesh Gupta
     * 				V_1.1 - Modified - 05/28/2020 - Victor Hanson CR-20200527-14113
     * 				V_1.2 - Modified - 06/03/2020 - Victor Hanson - CR-20200603-14137 - check for status=success & target file name updated
     * 				V_1.3 - Modified - 11/13/2020 - Victor Hanson - CR-20201012-14597 - modified to work with single artifact transfers
     *                          V_1.4 - Modified - 07/19/2021 - Shalu Sharma - CR-20210719-15296 - Add "Mail_Shop_Vendor__c" field in Query
     *                     
    **/
    public static void updateArtifactOnartifactTxStatusUpdate(List<Artifact_Transfer__c> newArtifacts, Map<Id, Artifact_Transfer__c> oldArtifactTransfer) {
        
        //get a map of artifacts with the number of related artifact transfers
        Set<Id> artifactIds = new Set<Id>();
        for (Artifact_Transfer__c artTx : newArtifacts) {
            artifactIds.add(artTx.Artifact__c);
        }
        Map<Id, Artifact__c> mapArtifacts = new Map<Id, Artifact__c>([SELECT Id, Proof_Generation__c, Production_Tracking__r.Proof_Generation__c, (SELECT Id FROM Artifact_Transfers__r) FROM Artifact__c WHERE Id IN :artifactIds]);
        
        //12/09/2020 -  - Victor Hanson - added so we can more easily reference the related pTracking record below
        Set<Id> pTrackingIds = new Set<Id>();
        for (Artifact__c artifact : mapArtifacts.values()) {
            pTrackingIds.add(artifact.Production_Tracking__c);
        }
        
        //Added by - 07/19/2021 - Shalu Sharma - CR-20210719-15296 - Add "Mail_Shop_Vendor__c" field in Query
        Map<Id, Production_Tracking__c> pTrackingMap = new Map<Id, Production_Tracking__c>([SELECT Id,RecordTypeId, Art_File_Name__c, Job_Ticket__c, Status__c, 
                                                                                            Creative_Package__c,Status_Detail__c, Proof_Generation__c, Mail_Shop_Vendor__c,
                                                                                            Suppression_File_Name__c
                                                                                            FROM Production_Tracking__c WHERE Id IN :pTrackingIds]);
        
        Map<Id, Artifact_Transfer__c> mapOfArtifactIdWithTx = new Map<Id, Artifact_Transfer__c>();
        Map<Id, Artifact_Transfer__c> mapOfArtifactIdWithNotSucessTx = new Map<Id, Artifact_Transfer__c>();
        
        Set<Id> setOfArtifactTxWithSuccessArtworkPush = new Set<Id>();
        Set<Id> setOfArtifactTxWithSuccessMailingListPush = new Set<Id>();
        
        List<Artifact__c> artifactToBeUpdated = new List<Artifact__c>();
        //Check if there is Artifact.
        for(Artifact_Transfer__c artTx : newArtifacts) {
            
            //VH 06/03/2020 - CR-20200603-14137 - Check for status change OR file name change
            //Check if the Status is changed on Artifact transfer. 
            if(artTx.Target_File_Name__c != null && oldArtifactTransfer == null 
               || (oldArtifactTransfer != null 
                   && artTx.Target_File_Name__c != null 
                   && (oldArtifactTransfer.get(artTx.Id).Status__c != artTx.Status__c 
                       || oldArtifactTransfer.get(artTx.Id).Target_File_Name__c != artTx.Target_File_Name__c))) 
            {
                //get the related artifact
                Artifact__c artifact;
                if (mapArtifacts != null) artifact = mapArtifacts.get(artTx.Artifact__c);
                
                //Check if the the Status is Changed to Success       
                if(artTx.Status__c == STATUS_SUCCESS) {
                    mapOfArtifactIdWithTx.put(artTx.Artifact__c, artTx);
                    
                    //11/13/2020 - CR-20201012-14597 - Victor Hanson - also check if this is the only ArtTx.  If so, callout
                    //check if this is a 'push'
                    if (artTx.Direction__c == DIRECTION_PUSH || (artifact != null && artifact?.Artifact_Transfers__r.size() == 1)) {
                        
                        //check if this is artwork
                        if (artTx.Artifact_Type__c == Constants.ARTIFACT_TYPE_ARTWORK) {
                            setOfArtifactTxWithSuccessArtworkPush.add(artTx.Id);
                        }
                        //check if this is mailing list
                        if (artTx.Artifact_Type__c == Constants.ARTIFACT_TYPE_MAILING_LIST
                            || (artTx.Artifact_Type__c == Constants.ARTIFACT_TYPE_SUPPRESSION_LIST 
                                && mapArtifacts.get(artTx.Artifact__c).Proof_Generation__c == ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL)) 
                        {
                            setOfArtifactTxWithSuccessMailingListPush.add(artTx.Id);
                        }
                    }
                }         
            }
        }
        
        //11/17/2020 - CR-20201012-14597 - Victor Hanson - updated to include proof generation
        //05/28/2020 - CR-20200527-14113 - Victor Hanson - Updated so it only sends the callout when artifact transfer is successful
        if (setOfArtifactTxWithSuccessArtworkPush.size() > 0) {
            List<Production_Tracking__c> pts = new List<Production_Tracking__c>();
            //get artifact with prod tracking details
            for (Artifact_Transfer__c artTx : [SELECT Id, Artifact__r.Production_Tracking__c,Artifact__r.Production_Tracking__r.Creative_Package__c ,
                                               Artifact__r.Production_Tracking__r.Proof_Generation__c,
                                               Artifact__r.Proof_Generation__c
                                               From Artifact_Transfer__c 
                                               Where Id =: setOfArtifactTxWithSuccessArtworkPush]) 
            {
                //12/09/2020 - CR-20201012-14597 - Victor Hanson - updated
                Production_Tracking__c pt = pTrackingMap.get(artTx.Artifact__r.Production_Tracking__c);

                //11/13/2020 - CR-20201012-14597 - Victor Hanson - call method from within loop because there can be multiple
                //check and send callout for proof-submitted
                ProductionTrackingTriggerHelper.checkReadyForProof(pt);
            }
        }
        
        //11/17/2020 - CR-20201012-14597 - Victor Hanson - updated to include proof generation
        //05/28/2020 - CR-20200527-14113 - Victor Hanson - Updated so it only sends the callout when artifact transfer is successful
        if (setOfArtifactTxWithSuccessMailingListPush.size() > 0) {
            
            
            //get artifact with prod tracking details
            for (Artifact_Transfer__c artTx : [SELECT Id, Artifact__r.Production_Tracking__c,
                                               Artifact__r.Production_Tracking__r.Proof_Generation__c,
                                               Artifact__r.Proof_Generation__c
                                               From Artifact_Transfer__c 
                                               Where Id =: setOfArtifactTxWithSuccessMailingListPush]) 
            {
                //12/09/2020 - CR-20201012-14597 - Victor Hanson - updated
                Production_Tracking__c pt = pTrackingMap.get(artTx.Artifact__r.Production_Tracking__c);

                //check and send callout for live proof-submitted
                ProductionTrackingTriggerHelper.checkReadyForLiveProof(new List<Production_Tracking__c>{ pt }, artTx.Artifact__r.Proof_Generation__c);
            }
            
        }
        
        if(mapOfArtifactIdWithTx.size() > 0)
        {
            //Getting the Sibling Artifact Tx Records. 
            for(Artifact_Transfer__c artTx : [Select Id, Artifact__c, Status__c, Target_File_Name__c, 
                                              File_Size_KB__c,File_Extension__c,Direction__c
                                              From Artifact_Transfer__c 
                                              Where Artifact__c =: mapOfArtifactIdWithTx.keySet()])
            {
                //check artifact transfer status is not SUCCESS
                if(artTx.Status__c != STATUS_SUCCESS){
                    mapOfArtifactIdWithNotSucessTx.put(artTx.Artifact__c,artTx);
                }                               
            }
            
            
            for(Artifact_Transfer__c artifactTx : mapOfArtifactIdWithTx.values()){
               //Check if all the Artifact Tx Under a Artifact has been sucess
                if(!mapOfArtifactIdWithNotSucessTx.containsKey(artifactTx.Artifact__c)){
                    Artifact__c artifact = new Artifact__c();
                    artifact.Id = artifactTx.Artifact__c;
                    artifact.File_Name__c = artifactTx.Target_File_Name__c;
                    artifact.Status__c = artifactTx.Status__c;
                    artifact.File_Size_KB__c = artifactTx.File_Size_KB__c;
                    artifact.File_Extension__c = artifactTx.File_Extension__c;
                    artifactToBeUpdated.add(artifact);
                }
            }
        }
        
        //Updating the Artifact Records.
        if(artifactToBeUpdated.size() > 0){
            update artifactToBeUpdated;
        }
        
    }
    
    /**
     *  Purpose         :   populate fields on Artifact Transfer
     *
     *  Revision Logs   :   V_1.0 - 06/03/2020 - CR-20200603-14137 - Victor Hanson - Created
     *                     
    **/
    public static void populateArtifactTransferFields(List<Artifact_Transfer__c> aTransfers) {
        
        //get artifact ids
        Set<Id> artifactIds = new Set<Id>();
        for (Artifact_Transfer__c newAT : aTransfers) artifactIds.add(newAT.Artifact__c);
        
        //get artifacts
        Map<Id, Artifact__c> mapArtifactsWithProjManager = new Map<Id, Artifact__c>([SELECT Id, Type__c, Production_Tracking__r.Job_Ticket__r.Project_Manager__c 
                                                                                     FROM Artifact__c WHERE Id IN :artifactIds]);
        
        for (Artifact_Transfer__c newAT : aTransfers) {
            //get artifact w/proj manager
            Artifact__c artifact = mapArtifactsWithProjManager.get(newAT.Artifact__c);
            if (artifact != null && 
                artifact.Production_Tracking__r.Job_Ticket__r.Project_Manager__c != null &&
                newAT.Project_Manager__c != artifact.Production_Tracking__r.Job_Ticket__r.Project_Manager__c)
            {
                newAT.Project_Manager__c = artifact.Production_Tracking__r.Job_Ticket__r.Project_Manager__c;
            }
        }
    }

        /**
         *  Purpose         :   Query for all Staff Assignments where Status = ‘Active’ and Assignment Role.Role = ‘Campaign Data Manager’ and set up and send email alert
         *
         *  Revision Logs   :   V_1.0 - Created - 07/22/2020 - Colin McGloin - CR-20200707-14271
         *                     
        **/

    @InvocableMethod
    public static void buildAndSendSuppressionEmailAlert (List<Id> failureArtifactTrasfers) {

        //Map of Artifacts to Job Tickets
        Map <Id, Id> mapArtTransferToInstitution = new Map <Id, Id>();

        //Map of Institution to Emails
        Map <Id, Set<String>> mapInstitutionToActiveStaffAssignments = new Map <Id, Set<String>> ();

        //List of Artifact Transfer records
        List <Artifact_Transfer__c> artifactTransfers = [SELECT Id, Artifact__c, Artifact__r.Job_Ticket__c, Artifact__r.Job_Ticket__r.Project__r.Institution__c, Artifact__r.Job_Ticket__r.Project_Manager__r.Email FROM Artifact_Transfer__c WHERE Id IN :failureArtifactTrasfers];

        //Loop through our Artifact Transfers and get the Job Tickets
        for (Artifact_Transfer__c aT : artifactTransfers){

            //Get our Job Ticket Institution
            if (aT.Artifact__r.Job_Ticket__c != null){

                //Put our Institution and Job Tick
                mapArtTransferToInstitution.put(aT.Id, aT.Artifact__r.Job_Ticket__r.Project__r.Institution__c);

            }

        }

        //Proceed if we have Job Tickets
        if (mapArtTransferToInstitution.values().size() > 0){

            //Query for the correct Staff Assignments
            List<Team_Membership__c> staffAssignment = [SELECT Id, Name, Status__c, Role__r.Name, Active_Institution__c, Staff_member__c, Staff_member__r.Email
                                                        FROM Team_Membership__c
                                                        WHERE Status__c = 'Active'
                                                        AND Role__r.Name = :System.Label.Artifact_Transfer_Staff_Assignment
                                                        AND Active_Institution__c IN :mapArtTransferToInstitution.values()];

            //Check to see if we have Staff Assignments that meet requirements
            if (staffAssignment.size() > 0){

                //Loop through our Staff Assignment
                for (Team_Membership__c sAssignment : staffAssignment){

                    //Double check to make sure we have an Active Institution
                    if (sAssignment.Active_Institution__c != null){

                        //Check our Map and pop the values into the Map if needed
                        if (mapInstitutionToActiveStaffAssignments.get(sAssignment.Active_Institution__c) != null && sAssignment.Staff_member__r.Email != null){

                            //Get our current Email Strings in there
                            Set <String> currentEmails = mapInstitutionToActiveStaffAssignments.get(sAssignment.Active_Institution__c);

                            //Add the next Email to the 
                            currentEmails.add(sAssignment.Staff_member__r.Email);
                            
                            //Add our Emails to Map
                            mapInstitutionToActiveStaffAssignments.put(sAssignment.Active_Institution__c, currentEmails);

                        } else {

                            //Create a set of String 
                            Set <String> currentEmails = new Set<String>();
                            currentEmails.add(sAssignment.Staff_member__r.Email);

                            //Add our Emails to Map
                            mapInstitutionToActiveStaffAssignments.put(sAssignment.Active_Institution__c, currentEmails);

                        }
                    }
                }
            }

            //Now we have our emails then let's create our Mail Message and send
            // grab the email template
            List<EmailTemplate> emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName = 'Artifact_Transfer_Transfer_Failed'];

            //Loop through our Artifact Transfers from the Map again
            for (Id artifactTransfer : mapArtTransferToInstitution.keyset()){

                //Grab our Institution from the first Map again
                if (mapArtTransferToInstitution.get(artifactTransfer) != null){

                    Id InstitutionId = mapArtTransferToInstitution.get(artifactTransfer);

                    //start building the email message
                    Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
                    email.setTemplateId(emailTemplate[0].Id);
                    email.setWhatId(artifactTransfer);
                    email.setSaveAsActivity(false);
                    email.setReplyTo('noreply@salesforce.com');
                    email.setSenderDisplayName('Salesforce Automated Email');

                    //Create a Set for use for our Email Addresses
                    Set <String> emailAddresses = new Set<String>();

                    //Grab our Emails for that Institution
                    if (mapInstitutionToActiveStaffAssignments.get(InstitutionId) != null){

                        //Get the Set of Emails
                        Set<String> emails = mapInstitutionToActiveStaffAssignments.get(InstitutionId);
                        emailAddresses.addAll(emails);

                    }

                    //Check to see if we have Email Addresses and then send Email if we do
                    if (emailAddresses.size() > 0){

                        //Convert our Set to a List
                        List <String> emailAdds = new List <String>();
                        emailAdds.addAll(emailAddresses);

                        email.setToAddresses(emailAdds);
                        email.setTargetObjectId(UserInfo.getUserId());

                        //Send our email
                        Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email}); 
                    }
                }
            }
        }
    }
    
    /**
     *  Purpose         :   if we have not reached the max retry count, try the callout again
     *
     *  Revision Logs   :   V_1.0 - 08/17/2020 - CR-20200803-14397 - Victor Hanson - created
     *                     
    **/
    public static void checkStatus(List<Artifact_Transfer__c> newArtifacts, Map<Id, Artifact_Transfer__c> oldArtifactTransfer) {
        for (Artifact_Transfer__c artTx : newArtifacts) {
            //get old artifact transfer
            Artifact_Transfer__c oldArtTX = oldArtifactTransfer.get(artTx.Id);
            
            //check if the status is changing to failure
            if (artTx.Status__c != oldArtTX.Status__c && artTx.Status__c != null && artTx.Status__c.equalsIgnoreCase(FAILURE)) {
                //check if retry count limit has been reached.  If not, update the status to retry
                if (artTx.Retry_Count__c == null || (artTx.Retry_Count__c < Decimal.valueOf(Label.Artifact_Transfer_Max_Retries))) {
                    if (artTx.Retry_Count__c == null)
                        artTx.Retry_Count__c = 0;
                    artTx.Retry_Count__c++;
                    artTx.Result__c = null; //clear out the error message in the result field
                    artTx.Status__c = Constants.ARTIFACT_STATUS_TRANSFER_NOW;
                }
            }
        }
    }
}