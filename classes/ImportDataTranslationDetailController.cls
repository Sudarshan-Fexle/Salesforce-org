/**
*  Description     :    This controller is used to Import Data Translation Details.
*
*  Created By      :    Neha Sharma   
* 
*  Created Date    :    12/14/2021 
* 
*  Revision Logs   :    V_1.0 Created - Neha Sharma - 10/07/2021 -  
*
*/
public without sharing class ImportDataTranslationDetailController 
{    
    public final static String CHAR_COMMA = ',';
    
    public static List<Transformation_Data_Detail_Generator__mdt> getAllTransformationDataDetailSettings() 
    {
        return Transformation_Data_Detail_Generator__mdt.getAll().values();
    }
    
    public static Set<String> getTransformationDataDetailKeyFieldsValues() 
    {
        return ImportDataTranslationDetailController.getSetOfCommaSeperatedValues(System.Label.Transformation_Data_Detail_Key_Fields_Values); 
    }
    
    public static Set<String> getTransformationDataDetailKeyFields() 
    {
        return ImportDataTranslationDetailController.getSetOfCommaSeperatedValues(System.Label.Transformation_Data_Detail_Key_Fields ); 
    }
    
    public static Set<String> getSetOfCommaSeperatedValues(String commaSeperatedString) 
    {
        Set<String> setOfValues = new Set<String>();
        if(String.isNotBlank(commaSeperatedString)) 
        {
            if(commaSeperatedString.trim().split(ImportDataTranslationDetailController.CHAR_COMMA).size() > 0) 
            {
                for(String val : commaSeperatedString.trim().split(ImportDataTranslationDetailController.CHAR_COMMA)) 
                {
                    setOfValues.add(val);    
                }     
            }
            else 
            {
                setOfValues.add(commaSeperatedString.trim());
            }
        }
        return setOfValues;
    }
    

    @AuraEnabled  
    public static Map<String, String> getselectOptions(String recordId) {

        Map<String, String> options = new Map<String, String>();
        List<Data_Translation_Set__c> dtSet = [Select recordType.Name from Data_Translation_Set__c where Id =: recordId];
        for (Transformation_Data_Detail_Mapping__mdt mapping : [Select Id,Source_Field_API_Name__c,RecordType_Name__c,Source_Field_Label__c 
                                                                From Transformation_Data_Detail_Mapping__mdt where RecordType_Name__c =: dtSet[0].recordType.Name]) {
            options.put(mapping.Source_Field_Label__c, mapping.Source_Field_API_Name__c);
        }

        return options;
    }

    
    @AuraEnabled(cacheable=false) 
    public static LightningResponseEntity insertDataTranslationDetailRecords(List<String> selectedGroupingValues, 
                                                                             List<String> selectedGroupingLabels, String recordId) 
    {
        LightningResponseEntity res = new LightningResponseEntity();
        try
        {
            if(selectedGroupingValues.size() > 0 && selectedGroupingLabels.size() > 0 && String.isNotBlank(recordId))
            {
                //Getting all the initial details that will be useful further for logic building and decision making
                List<Transformation_Data_Detail_Generator__mdt> listOfTransformationDetails = ImportDataTranslationDetailController.getAllTransformationDataDetailSettings();
                Set<String> setOfKeyFieldsEligibleValues = ImportDataTranslationDetailController.getTransformationDataDetailKeyFieldsValues();
                Set<String> setOfKeyFieldsNames = ImportDataTranslationDetailController.getTransformationDataDetailKeyFields();
                
                //Map of key field name as key and corresponding eligible metadata records as value
                Map<String, List<Transformation_Data_Detail_Generator__mdt>> mapOfKeyFieldsWithDetails = new Map<String, List<Transformation_Data_Detail_Generator__mdt>>();
                
                //Map of eligible metadata records
                Map<String,Transformation_Data_Detail_Generator__mdt> mapOfTransDataDetailGenerator = new Map<String,Transformation_Data_Detail_Generator__mdt>();
                
                //Set of Inter Field API name from eligible metadata records
                Set<String> setOfInternalFields = new Set<String>();
                
                //List of data Translation detail records that need to insert
                List<Data_Translation_Detail__c> listOfDataTransDetailToBeInsert = New List<Data_Translation_Detail__c>();
                
                //List of data Translation set records that need to update
                List<Data_Translation_Set__c> listOfDataTransDetailToUpdate = New List<Data_Translation_Set__c>();
                
                //Only proceed further if we have initial details
                if(listOfTransformationDetails.size() > 0 && setOfKeyFieldsEligibleValues.size() > 0 && setOfKeyFieldsNames.size() > 0) 
                {
                    for(Transformation_Data_Detail_Generator__mdt transDataDetail : listOfTransformationDetails) 
                    {
                        if(String.isNotBlank(transDataDetail.Internal_Field_API_Name__c))
                        {
                            SObject sObj = (SObject) transDataDetail;
                            for(String keyFieldName : setOfKeyFieldsNames)
                            {
                                if(String.isNotBlank(String.valueOf(sObj.get(keyFieldName))))
                                {
                                    String keyFieldValue = String.valueOf(sObj.get(keyFieldName));
                                    if(setOfKeyFieldsEligibleValues.contains(keyFieldValue)) 
                                    {
                                        if(!mapOfKeyFieldsWithDetails.containsKey(keyFieldName)) 
                                        {
                                            mapOfKeyFieldsWithDetails.put(keyFieldName, new List<Transformation_Data_Detail_Generator__mdt>());
                                        }
                                        mapOfKeyFieldsWithDetails.get(keyFieldName).add(transDataDetail);
                                    }
                                }        
                            }
                        }
                    }
                }
                
                
                if(mapOfKeyFieldsWithDetails != null && mapOfKeyFieldsWithDetails.values().size() > 0 )
                {
                    for(String keyfield : mapOfKeyFieldsWithDetails.keySet())
                    {
                        if(selectedGroupingValues.contains(keyfield))
                        {
                            for(Transformation_Data_Detail_Generator__mdt transGen : mapOfKeyFieldsWithDetails.get(keyfield))
                            { 
                                if(String.isNotBlank(transGen.Internal_Field_API_Name__c))
                                {
                                    setOfInternalFields.add(transGen.Internal_Field_API_Name__c);
                                    if(!mapOfTransDataDetailGenerator.containsKey(transGen.Internal_Field_API_Name__c + recordId))
                                    {
                                        mapOfTransDataDetailGenerator.put(transGen.Internal_Field_API_Name__c + '-'+recordId,transGen);
                                    }
                                }
                            }
                        }
                    }
                    
                }
                
                
                if(mapOfTransDataDetailGenerator.values().size() == 0)
                {
                   
                    res.message = System.Label.Selected_Partner_Variables_have_been_created_already;
                    res.isSuccess = false;
                }
                else if(setOfInternalFields.size()  > 0 && mapOfTransDataDetailGenerator != null && mapOfTransDataDetailGenerator.values().Size() > 0)
                {
                    for(Data_Translation_Detail__c dataTransDetail : [Select Id,Data_Translation__c,Internal_Field_API_Name__c,Table_Name__c,Requirement__c,Internal_Definition__c from Data_Translation_Detail__c where 
                                                                      Internal_Field_API_Name__c IN:setOfInternalFields
                                                                      AND Data_Translation__c =:recordId])
                    {
                        if(mapOfTransDataDetailGenerator.containsKey(dataTransDetail.Internal_Field_API_Name__c+'-'+ recordId))
                        {
                            mapOfTransDataDetailGenerator.remove(dataTransDetail.Internal_Field_API_Name__c+'-'+ recordId);
                        }
                    }
                    
                    if(mapOfTransDataDetailGenerator != null && mapOfTransDataDetailGenerator.values().size() > 0)
                    {
                        for(Transformation_Data_Detail_Generator__mdt transGen : mapOfTransDataDetailGenerator.values())
                        {
                            SObject sObj = (SObject) transGen;
                            String Requirement ;
                            Data_Translation_Detail__c dataTransDetail = new Data_Translation_Detail__c();
                            dataTransDetail.Data_Translation__c = recordId;
                            dataTransDetail.Table_Name__c = transGen.Table_Name__c;
                            dataTransDetail.Internal_Definition__c = transGen.Internal_Definition__c;
                            dataTransDetail.Internal_Field_API_Name__c = transGen.Internal_Field_API_Name__c;
                            dataTransDetail.Internal_Data_Type__c = transGen.Internal_Data_Type__c;
                            dataTransDetail.Internal_Field_Name__c = transGen.Internal_Field_Name__c;
                            dataTransDetail.grouping__c = transGen.grouping__c;
                             for(String keyFieldName : selectedGroupingValues)
                            {
                                if(String.isNotBlank(String.valueOf(sObj.get(keyFieldName))))
                                {
                                    String keyFieldValue = String.valueOf(sObj.get(keyFieldName));
                                    if(keyFieldValue == 'Required') 
                                    {
                                        Requirement = 'Required';
                                    }
                                    else if(Requirement !=  'Required')
                                    {
                                        Requirement = 'optional';
                                    }
                                }
                                else if(String.isBlank(Requirement))
                                {
                                     Requirement = '';
                                }
                            }
                            dataTransDetail.Requirement__c = Requirement;
                          
                            listOfDataTransDetailToBeInsert.add(dataTransDetail);
                        }
                    }
                    else
                    {
                       
                   		insertDTSetRecord(recordId,selectedGroupingLabels);
                        res.message = System.Label.DTD_Records_Already_Exist;
                        res.isSuccess = false;
                    }
                    
                }
                                
                
                if(listOfDataTransDetailToBeInsert.size() > 0){
                    
                    insert listOfDataTransDetailToBeInsert;
                    
                                 
                   
                    res = insertDTSetRecord(recordId,selectedGroupingLabels);
                    
                }   
            }  
            
            return res;
        }
        catch (DmlException e) 
        {
            res.setError(e.getdmlMessage(0));
            res.isSuccess = false;
            return res;  
        }
    }
    
    public static String removeDuplicate(String selectedPartnerVariables)
    {
        String uniqueSelectedPartnerVariables ;
        if(selectedPartnerVariables != null && (selectedPartnerVariables).contains(','))
        {
            selectedPartnerVariables = selectedPartnerVariables.replaceAll('(\\s+)', ''); 
            Set<String> duplicateRemoveList = new Set<String>(selectedPartnerVariables.split(','));
            uniqueSelectedPartnerVariables = String.join(new List<String>(duplicateRemoveList), ', ');  
            return uniqueSelectedPartnerVariables;
        }
        else
        {
            uniqueSelectedPartnerVariables = selectedPartnerVariables;
            return uniqueSelectedPartnerVariables;
        }
        
    }
    
    public static LightningResponseEntity insertDTSetRecord(String recordId, List<String> selectedGroupingLabels)
    {
        LightningResponseEntity res = new LightningResponseEntity();
        
        //List of data Translation set records that need to update
        List<Data_Translation_Set__c> listOfDataTransDetailToUpdate = New List<Data_Translation_Set__c>();
        
        for(Data_Translation_Set__c data : [Select Id,Selected_Partner_Variables__c from Data_Translation_Set__c where Id =: recordId])
        {
            if(selectedGroupingLabels.size() > 0)
            {   
                String grpValues ;
                if(String.isBlank(data.Selected_Partner_Variables__c))
                {
                    data.Selected_Partner_Variables__c  = String.join(selectedGroupingLabels, ',');
                    data.Selected_Partner_Variables__c = removeDuplicate(data.Selected_Partner_Variables__c);
                }
                else
                {
                    data.Selected_Partner_Variables__c  += +', '+ String.join(selectedGroupingLabels, ',');
                    data.Selected_Partner_Variables__c = removeDuplicate(data.Selected_Partner_Variables__c);
                }
                
            }
            data.Selected_Partner_Variables__c = (data.Selected_Partner_Variables__c).removeEnd(',');
            listOfDataTransDetailToUpdate.add(data);
        }                    
        if(listOfDataTransDetailToUpdate.size() > 0)
        {
            update listOfDataTransDetailToUpdate;
        } 
        res.message = System.Label.DTD_Import_Process_Completed_Successfully;
        res.isSuccess = true;
        return res;
    }
}