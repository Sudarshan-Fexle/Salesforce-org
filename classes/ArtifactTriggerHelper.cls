/**
 *  Purpose         :	Helper methods for Artifact
 *
 *  Revision Logs   :	V_1.0 - 04/09/2020 - Victor Hanson - Created
 * 			V_1.1 - 06/20/2020 - Victor Hanson - Bypass exception for suppression file name
 * 			V_1.2 - 07/25/2020 - Victor Hanson - CR-20200722-14351 - modified replaceMergeFieldsWithVals
 *			V_1.3 - 11/17/2020 - CR-20201012-14597 - Victor Hanson
 *			V_1.4 - 05/24/2021 - CR-20210524-15178 - To remove the un-necessary system.debug statements and to proper indent the code.
 *                     
**/
public class ArtifactTriggerHelper 
{
    
    /** 
     *  Purpose         :	get the Artifact Transfer Settings in map format
     *
     *  Revision Logs   :	V_1.0 - Created - 04/09/2020 - Victor Hanson - Created
     * 				V_1.1 - Modified - 11/12/2020 - CR-20201012-14597 - Victor Hanson - Added support for Proof Generation internal/external
     *                     
    **/
    public static Map<String, List<Artifact_Transfer_Setting__mdt>> keyToArtifactSetting {
        get {
            if (keyToArtifactSetting == null) {
                keyToArtifactSetting = new Map<String, List<Artifact_Transfer_Setting__mdt>>();
                //get all artifact transfer settings
                for (Artifact_Transfer_Setting__mdt atSetting : [SELECT Id, Artifact_Type__c, Artifact_Source__c, Artifact_Target__c, Drop_Type__c,
                                                                 Direction__c, Mail_Shop_Vendor__c, Transfer_Type__c, Source_Host_Profile__c, 
                                                                 Source_File_Name_Exact__c, Source_File_Name_Regex__c, Source_Directory_Path__c,
                                                                 Target_Directory_Path__c, Target_Host_Profile__c, Transformation_Profile__c,
                                                                 PGP_Encryption_Profile__c, PGP_Decryption_Profile__c, Proof_Generation__c
                                                                 FROM Artifact_Transfer_Setting__mdt WHERE Status__c = 'Active']) 
                {
                    String key = atSetting.Artifact_Type__c + '-' + atSetting.Mail_Shop_Vendor__c + '-' + atSetting.Proof_Generation__c + '-' + atSetting.Drop_Type__c ;
                    List<Artifact_Transfer_Setting__mdt> ats = keyToArtifactSetting.get(key);
                    if (ats == null) ats = new List<Artifact_Transfer_Setting__mdt>();
                    ats.add(atSetting);
                    keyToArtifactSetting.put(key, ats);
                }
            }
            return keyToArtifactSetting;
        }
        set;
    }
    
    /**
     *  Purpose         :	get the merge fields from dynamic fields and return artifact transactions for insert
     *
     *  Revision Logs   :	V_1.0 - Created - 04/09/2020 - Victor Hanson - Created
     * 				V_1.1 - Modified - 11/12/2020 - CR-20201012-14597 - Victor Hanson - Added support for Proof Generation internal/external
     *                     
    **/
    public static void createArtifactTransfers(List<Artifact__c> listArtifacts) 
    {
        List<Artifact_Transfer__c> artifactTransfersForInsert = new List<Artifact_Transfer__c>();
        
        //get all fields for query
        Set<String> qryFields = new Set<String> { 'Id', 'Type__c', 'Production_Tracking__r.Mail_Shop_Vendor__r.Historical_Linker__c', 
                                                  'Source_File_Name_Exact_Override__c', 'Source_Directory_Path_Override__c', 'Proof_Generation__c', 'Drop_Type__c' };
                
                qryFields.addAll(mapMergeFieldToAPIName.values());
        
                
        //construct query for record id
        String artifactSOQL = 'SELECT ' + String.join(new List<String>(qryFields), ',');
        artifactSOQL += ' FROM Artifact__c WHERE Id IN :listArtifacts';
        
        //get records
        List<Artifact__c> artifacts = database.query(artifactSOQL);
        
        //loop through each artifact
        for (Artifact__c artifact : artifacts) 
        { 
            //get the corresponding artifact transfer settings
            List<Artifact_Transfer_Setting__mdt> aTranserSettings = 
                keyToArtifactSetting.get(artifact.Type__c + '-' + artifact.Production_Tracking__r.Mail_Shop_Vendor__r.Historical_Linker__c + '-' + artifact.Proof_Generation__c + '-' + artifact.Drop_Type__c);
            
            if (aTranserSettings != null) 
            {
                //create an artifact transfer for each setting record
                for (Artifact_Transfer_Setting__mdt ats : aTranserSettings) 
                {
                    artifactTransfersForInsert.add(createArtifactTransfer(ats, artifact));
                }
            }
        }
        
        //if an artifact only has one transfer, set the status to Transfer Now even if it's a push
        Map<String, Integer> mapArtifactToTransferCount = new Map<String, Integer>();
        for (Artifact_Transfer__c artTx : artifactTransfersForInsert) 
        {
            Integer artTxCount = mapArtifactToTransferCount.get(artTx.Artifact__c);
            if (artTxCount == null) artTxCount = 1;
            else artTxCount++;
            mapArtifactToTransferCount.put(artTx.Artifact__c, artTxCount);
        }
        
        //now that we have the totals, check for any artifacts that only have one Transfer.  
        //If so, set them to transfer now
        for (Artifact_Transfer__c artTx : artifactTransfersForInsert) 
        {
            Integer artTxCount = mapArtifactToTransferCount.get(artTx.Artifact__c);
            if (artTxCount == 1 && artTx.Status__c != Constants.ARTIFACT_STATUS_TRANSFER_NOW) 
            {
                artTx.Status__c = Constants.ARTIFACT_STATUS_TRANSFER_NOW;
            }
        }
        
        if (artifactTransfersForInsert.size() > 0)
            insert artifactTransfersForInsert;
    }
    
    public static Artifact_Transfer__c createArtifactTransfer(Artifact_Transfer_Setting__mdt ats, Artifact__c artifact) 
    {
        //set the file name and populate merge fields with values
        String fileName = ats.Source_File_Name_Exact__c;
        if (fileName != null)
            fileName = replaceMergeFieldsWithVals(fileName, artifact);
        
        //set the Source Directory and populate merge fields with values
        String sourceDirectory = ats.Source_Directory_Path__c;
        if (sourceDirectory != null)
            sourceDirectory = replaceMergeFieldsWithVals(sourceDirectory, artifact);
        
        //set the Target Directory and populate merge fields with values
        String targetDirectory = ats.Target_Directory_Path__c;
        if (targetDirectory != null)
            targetDirectory = replaceMergeFieldsWithVals(targetDirectory, artifact);
        
        //set the Source File Name Regex and populate merge fields
        String sourceNameRegex = ats.Source_File_Name_RegEx__c;
        if (sourceNameRegex != null)
            sourceNameRegex = replaceMergeFieldsWithVals(sourceNameRegex, artifact);
        
        //Status
        String status = Constants.ARTIFACT_STATUS_STAGING;
        if (ats.Direction__c == ArtifactTransferHelper.DIRECTION_PULL)
            status = Constants.ARTIFACT_STATUS_TRANSFER_NOW;
        
        //generate the artifact transfer
        Artifact_Transfer__c aTransfer = new Artifact_Transfer__c(Artifact__c = artifact.Id,
                                                                  Direction__c = ats.Direction__c,
                                                                  Transfer_Type__c = ats.Transfer_Type__c,
                                                                  Source_File_Name_Exact__c = fileName,
                                                                  Source_File_Name_RegEx__c = sourceNameRegex,
                                                                  Source_Directory_Path__c = sourceDirectory,
                                                                  Target_Directory_Path__c = targetDirectory,
                                                                  Source_Host_Profile__c = ats.Source_Host_Profile__c,
                                                                  Artifact_Source__c = ats.Artifact_Source__c,
                                                                  Artifact_Target__c = ats.Artifact_Target__c,
                                                                  Target_Host_Profile__c = ats.Target_Host_Profile__c,
                                                                  Transformation_Profile__c = ats.Transformation_Profile__c,
                                                                  PGP_Encryption_Profile__c = ats.PGP_Encryption_Profile__c,
                                                                  PGP_Decryption_Profile__c = ats.PGP_Decryption_Profile__c,
                                                                  Status__c = status
                                                                 );
        
        return aTransfer;
    }
    
    /**
     *  Purpose         :	replaces merge fields with their corresponding artifact field value
     *
     *  Revision Logs   :	V_1.0 - Created - 04/09/2020 - Victor Hanson - Created
     * 				V_1.1 - Modified - 06/19/2020 - CR-20200619-14210 - Victor Hanson - bypass exception for suppression file name
     * 				V_1.2 - Modified - 07/25/2020 - CR-20200722-14351 - Victor Hanson - removed exception when field is blank
     *                     
    **/
    public static String replaceMergeFieldsWithVals(String fldVal, Artifact__c artifact) 
    {
        for (String mergeFld : mapMergeFieldToAPIName.keySet()) 
        {
            String mergeFldAPIName = mapMergeFieldToAPIName.get(mergeFld);
            String dynamicFieldVal = ExtractFieldValues((SObject) artifact, mergeFldAPIName);
            if (dynamicFieldVal == null) 
            {
                //07/25/2020 - CR-20200722-14351 - Victor Hanson - removed exception when field is blank
                /*if (!Test.isRunningTest() && mergeFldAPIName != null && !mergeFldAPIName.equalsIgnoreCase('Production_Tracking__r.Suppression_File_Name__c'))
                    throw new customException('The merge field value is blank (' + mergeFldAPIName + ').  Place a value in this field and try again');*/
            }
            else 
            {
                fldVal = fldVal.replace(mergeFld, dynamicFieldVal);
            }
        }
        return fldVal;
    }
    
    public static string ExtractFieldValues(sObject sb, string fieldAPIName)
    {
        string fvalue='';
        if(fieldAPIName.contains('.'))
        {
            List<string> splitedFields = fieldAPIName.split('\\.');
            try
            {
                for(integer i=0;i<splitedFields.size()-1;i++)
                {
                    sb=sb.getSobject(splitedFields[i]);   
                }
                fvalue = string.valueof(sb.get(splitedFields[splitedFields.size()-1]));
            }
            catch(exception ex)
            {
                system.debug('******exception while fetching fieldValues as relationship '+fieldAPIName+'  value is blank.'+ex.getmessage()); 
                fvalue='';
            }
        }
        else if(sb.get(fieldAPIName)!=null)
        {
            fvalue = string.valueOf(sb.get(fieldAPIName));
        }
        return fvalue;
    }
    
    /**
    *  Purpose         :	get a map of all merge fields for each custom metadata field containing such fields
    *
    *  Revision Logs   :	V_1.0 - Created - 04/09/2020 - Victor Hanson - Created
    *                     
    **/
    public static Map<String, String> mapMergeFieldToAPIName 
    {
        get {
            if (mapMergeFieldToAPIName == null) {
                mapMergeFieldToAPIName = new Map<String, String>();
                
                for (List<Artifact_Transfer_Setting__mdt> atsList : keyToArtifactSetting.values()) {
                    for (Artifact_Transfer_Setting__mdt ats : atsList) {
                        //get the value for each of the fields that contain merge fields
                        if (ats.Source_File_Name_Exact__c != null)
                            mapMergeFieldToAPIName.putAll(getMergeFieldSplit(ats.Source_File_Name_Exact__c));
                        if (ats.Source_Directory_Path__c != null)
                            mapMergeFieldToAPIName.putAll(getMergeFieldSplit(ats.Source_Directory_Path__c));
                        if (ats.Target_Directory_Path__c != null)
                            mapMergeFieldToAPIName.putAll(getMergeFieldSplit(ats.Target_Directory_Path__c));
                        if (ats.Source_File_Name_RegEx__c != null)
                            mapMergeFieldToAPIName.putAll(getMergeFieldSplit(ats.Source_File_Name_RegEx__c));
                    }
                }
            }
            return mapMergeFieldToAPIName;
        }
        set;
    }
    
    /**
    *  Purpose         :	in a merge string, get each instance of merge field
    *
    *  Revision Logs   :	V_1.0 - Created - 04/09/2020 - Victor Hanson - Created
    *                     
    **/
    public static Map<String, String> getMergeFieldSplit(String mergeString) 
    {
        Map<String, String> mapMergeFldToAPIName = new Map<String, String>();
        String openChar = '<';
        String closeChar = '>';
        for (String s : mergeString.split('<')) 
        {
            s = openChar + s;
            String fldAPIName = s.substringBetween(openChar,closeChar);
            if (!String.isBlank(fldAPIName))
                mapMergeFldToAPIName.put(openChar + fldAPIName + closeChar, fldAPIName);
        }
        return mapMergeFldToAPIName;
    }
    
     /**
     *  Purpose         :	Method is used to handle the updates on the artifact Object.
     *
     *  Revision Logs   :	V_1.0 - Created - 04/10/2020 - Dipesh Gupta - CR-20200408-13920
     *                     
    **/
    public static void updateArtifactTransferAndProductionTracking(List<Artifact__c> newArtifacts, Map<Id, Artifact__c> OldMapArtifacts) 
    {
        List<Artifact_Transfer__c> artifactTransfersToBeUpdatedToTXNow = new List<Artifact_Transfer__c>();
        List<Production_Tracking__c> productionTrackingToBeUpdatedAsFailure = new List<Production_Tracking__c>();
        Set<Id> setTXNowArtifactIds = new Set<Id>();
        for(Artifact__c artifact : newArtifacts) 
        {
            //Check if the status is changed and it is transfer
            if(artifact.Status__c == Constants.ARTIFACT_STATUS_TRANSFER_NOW && (OldMapArtifacts != null && OldMapArtifacts.get(artifact.Id).Status__c != artifact.Status__c)) 
            {
                setTXNowArtifactIds.add(artifact.Id);
            }
            
            if(artifact.Status__c == 'Failure' && String.isNotBlank(artifact.Production_Tracking__c) && 
               (OldMapArtifacts != null && OldMapArtifacts.get(artifact.Id).Status__c != artifact.Status__c))
                productionTrackingToBeUpdatedAsFailure.add(new production_Tracking__c(Id = artifact.Production_Tracking__c, Status_Detail__c = 'Failure'));    
        }
        
        if(productionTrackingToBeUpdatedAsFailure.size() > 0) 
            update productionTrackingToBeUpdatedAsFailure;
        
        //Check if the Artifact Tx records. 
        if(setTXNowArtifactIds.size() > 0) 
        {
            //Query Artifact transfer Records. 
            for(Artifact_Transfer__c artifactTx : [Select Id, Status__c From Artifact_Transfer__c 
                                                   Where Artifact__c IN: setTXNowArtifactIds
                                                   AND Direction__c =: ArtifactTransferHelper.DIRECTION_PULL
                                                   AND Status__c !=: Constants.ARTIFACT_STATUS_TRANSFER_NOW]) 
            {
                artifactTx.Status__c = Constants.ARTIFACT_STATUS_TRANSFER_NOW;
                artifactTransfersToBeUpdatedToTXNow.add(artifactTx);   
            }   
            
            //Check if the artifactTransfersToBeUpdatedToTXNow is more then 0 then Update. 
            if(artifactTransfersToBeUpdatedToTXNow.size() > 0) {
                update artifactTransfersToBeUpdatedToTXNow;
            }
        }
    }
}