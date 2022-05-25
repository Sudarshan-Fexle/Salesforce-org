/*
Purpose         :   Controller class for Associated Job Component and Customize Job Component screens. 

Created By      :   Abhinav Sharma

Created Date    :   01/12/2020

Current Version :   v1.0

Revision Log    :   V_1.0 Created
                :   V_1.1 modified By - Dipesh Gupta - CR-20200429-14004
                :   V_1.2 Modified By - Abhinav Sharma - 6/5/2020 -  CR-20200524-14104 - Access modifier based changes here for the @auraenabled properties
		:   V_1.3 Modified By - Abhinav Sharma - 02/24/2021 - CR-20201111-14688 - Create Print PT when JT MtM is created 
		:   V_1.4 Modified By - Abhinav Sharma - 05/17/2021 - CR-20210513-15145 - Details missing on PTR when component marked as Approved By Partner (Update approveJobTicketMtM method)
		:   V_1.5 Modified By - Abhinav Sharma - 05/19/2021 - CR-20210518-15161 - Update the mthod "approveJobTicketMTM" so then "Cannot_Edit_Locked_Job_Ticket_Records" validation rule will
											  not excute un-necessary.
		:   V_1.6 Modified By - Abhinav Sharma - 06/08/2021 - CR-20210607-15195 - Add condition for Digital when excluding forms from PT creation
		:   V_1.7 Modified By - Abhinav Sharma - 06/04/2021 - CR-20210524-15178 - OE/BRE-Automation QA/Issues Fixes
		:   V_1.8 Modified By - Nikita Kumari - 10/01/2021 - CR-20210929-15468 -  Method - approveJobTicketMtM(), Added condition to display error message when user approve job ticket mtm's whose status is blank.
		:   V_1.9 Modified By - Nikita Kumari - 10/04/2021 - CR-20210924-15459 - Added boolean "executePopulatesAvailablePriorYearInventoryOnJobTicket" property
*/
public with sharing class AssociatedJobComponentsController
{
    //Added By - Nikita Kumari - 10/04/2021 - CR-20210924-15459 - Added boolean "executePopulatesAvailablePriorYearInventoryOnJobTicket" property
    public static Boolean executePopulatesAvailablePriorYearInventoryOnJobTicket = false;
    
    public static List<Schema.FieldSetMember> getDefaultFields() 
    {
        return Schema.SObjectType.Job_Ticket_MtM__c.fieldSets.getMap().get(System.Label.Associated_Job_Components).getFields();
    }
    
    //Modified by - Abhinav Sharma - 02/24/2021 - CR-20201111-14688 - Create Print PT when JT MtM is created (Add Status field in the JobTicketComponentWrapper)
    @AuraEnabled(cacheable=true)
    public static List<JobTicketComponentWrapper> retrieveExistingJobTicketComponents(String recordId) 
    {
        try
        {
            if(String.isNotBlank(recordId)) 
            {
                List<JobTicketComponentWrapper> jobTicketComponentWrapperList = new List<JobTicketComponentWrapper>();
                String whereClause = 'WHERE Job_Ticket__c =:recordId';
                String orderBy = 'ORDER BY Job_Ticket_Component__r.Component__c ASC ';
                String jobTicketEstimatesQuery = DatabaseUtilities.getFieldsetQuery('Job_Ticket_MtM__c', getDefaultFields(), 
                                                                                    new List<String>{'Name'}, 
                                                                                    whereClause, orderBy, null, true);
                for (sObject queriedObject : Database.query(jobTicketEstimatesQuery)) 
                {
                    Job_Ticket_MtM__c jM = (Job_Ticket_MtM__c)queriedObject;
                    String tabName = '';
                    if(jM.Job_Ticket_Component__c != null) 
                    {
                        tabName = jM.Job_Ticket_Component__r.Name.length() >= 50 ? jM.Job_Ticket_Component__r.Name.substring(0,50) +'...' : jM.Job_Ticket_Component__r.Name;
                        JobTicketComponentWrapper newWrapper = new JobTicketComponentWrapper(jM.Id, jM.Name, 
                                                                                             jM.Job_Ticket_Component__r.Name, 
                                                                                             jM.Job_Ticket_Component__r.Component__c,
                                                                                             jM.Paper_Weightx__c,
                                                                                             jM.Paper_Typex__c,
                                                                                             jM.Job_Ticket_Component__r.Size__c, 
                                                                                             jM.Color_Breakdown__c, 
                                                                                             jM.PMS_Color_Breakdown__c,
                                                                                             tabName, jM.Status__c);
                        jobTicketComponentWrapperList.add(newWrapper);
                    }
                    else 
                    {
                        JobTicketComponentWrapper newWrapper = new JobTicketComponentWrapper(jM.Id, jM.Name, 
                                                                                             null, 
                                                                                             null, 
                                                                                             jM.Paper_Weightx__c,
                                                                                             jM.Paper_Typex__c,
                                                                                             null,
                                                                                             jM.Color_Breakdown__c, 
                                                                                             jM.PMS_Color_Breakdown__c,
                                                                                             tabName, jM.Status__c);
                        jobTicketComponentWrapperList.add(newWrapper);
                    }
                }
                return jobTicketComponentWrapperList;
            } 
            else 
            {
                return null;    
            }    
        }
        catch (Exception e) 
        {
            throw new AuraHandledException('Exception occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n'); 
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static void deleteRecordsJobTicketMtm(List<Id> listOfJobTicketMtm)
    {
        try 
        {
            List<Job_Ticket_MtM__c> listOfJobTicketMtmToBeDelete = new List<Job_Ticket_MtM__c>();
            for(Id jTM : listOfJobTicketMtm)
            {
                listOfJobTicketMtmToBeDelete.add(new Job_Ticket_MtM__c(Id = jTM));
            }
            if(listOfJobTicketMtmToBeDelete.size() > 0)
            {
                JobTicketTriggerHelper.Bypass_changeReasonRequiredForLockedRecord = true;
                delete listOfJobTicketMtmToBeDelete;
                JobTicketTriggerHelper.Bypass_changeReasonRequiredForLockedRecord = false;
            }    
        }
        catch (Exception e) 
        {
            String errorMessage = e.getMessage();
            List<String> splittedByValidationExceptions = new List<String>();
            if(errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
            {
                splittedByValidationExceptions = errorMessage.split('FIELD_CUSTOM_VALIDATION_EXCEPTION');
                errorMessage = errorMessage.split('FIELD_CUSTOM_VALIDATION_EXCEPTION')[splittedByValidationExceptions.size() - 1];
                errorMessage = errorMessage.removeStart(',').removeEnd('[]').trim();
            }
            throw new AuraHandledException(errorMessage);
        }
    }
    
    //Add
    @AuraEnabled(cacheable=true)
    public static Job_Ticket__c fetchJobTicketInfo(String jobTicketId)
    {
        try 
        {
            if(String.isBlank(jobTicketId))
            {
                return null;
            }
            List<Job_Ticket__c> jobTickets = [Select Id, Name From Job_Ticket__c where Id =: jobTicketId];
            return jobTickets.size() > 0 ? jobTickets[0] : null;
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException('Exception occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n'); 
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> findJobComponentTypes() 
    {
        try 
        {
            Map<String, String> mapComponentOptions = new Map<String, String>();
            for(Schema.PicklistEntry f : Job_Ticket_Component__c.Component__c.getDescribe().getPicklistValues())
            {
                mapComponentOptions.put(f.getLabel(), f.getValue());
            }
            return mapComponentOptions;    
        }
        catch (Exception e) 
        {
            throw new AuraHandledException('Exception occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n'); 
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Job_Ticket_Component__c> fetchJobTicketComponents(String jobTicketId, String componentType) 
    {
        try 
        {
            if(String.isNotBlank(jobTicketId) && String.isNotBlank(componentType)) 
            {
                Set<Id> setOfJobTicketComponents = new Set<Id>();
                for(Job_Ticket_MTM__c jTM : JobTicketMtMQueryBuilder.getAllJobTicketComponents(jobTicketId)) 
                {
                    setOfJobTicketComponents.add(jTM.Job_Ticket_Component__c);                                 
                }
                return [Select Id, Name, Size__c, Program__r.Name,Order__c
                        From Job_Ticket_Component__c 
                        Where Component__c =: componentType ORDER BY Order__c ASC];
                        //AND ID NOT IN: setOfJobTicketComponents ORDER BY Order__c ASC];
            }
            else 
            {
                return null;    
            }
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException('Exception occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n'); 
        }   
    }
    
    //Edit
    @AuraEnabled(cacheable=true)
    public static List<associatedFeatureWrapper> showAllAssociatedFeaturesRecords(String jobTicketMtMID)
    {
        try 
        {
            if(String.isNotBlank(jobTicketMtMID))
            {
                List<associatedFeatureWrapper> associatedFeatureWrapperList = new List<associatedFeatureWrapper>();
                for (Associated_Features__c aF : [SELECT ID, Name,Job_Ticket_MtM__r.Name,Job_Ticket_Component__c, 
                                                  PMS__c, Color_Placement__c, C__c, M__c, Y__c, K__c,
                                                  Spot_Dull_Varnish__c, Spot_Gloss_Varnish__c, Spot_Matte_Varnish__c,CMYK__c
                                                  FROM Associated_Features__c
                                                  WHERE RecordType.Name= 'Color' 
                                                  AND Job_Ticket_MtM__c =:jobTicketMtMID])
                {
                    
                    AssociatedFeatureWrapper newWrapper = new associatedFeatureWrapper(aF.Id, aF.Name, 
                                                                                       aF.Job_Ticket_Component__c, 
                                                                                       aF.Job_Ticket_MtM__r.Name, 
                                                                                       aF.PMS__c, aF.Color_Placement__c,
                                                                                       aF.C__c, aF.M__c, aF.Y__c, aF.K__c,
                                                                                       aF.Spot_Dull_Varnish__c,aF.Spot_Gloss_Varnish__c,
                                                                                       aF.Spot_Matte_Varnish__c,aF.CMYK__c);
                    associatedFeatureWrapperList.add(newWrapper);
                }
                return associatedFeatureWrapperList;
            }
            else 
            {
                return null;
            }    
        }
        catch (Exception e) 
        {
            throw new AuraHandledException('Exception occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n'); 
        }
    }
    
    //Modified by - Dipesh Gupta - 03-11-2020 - CR-20200303-13825(Color count per component should include CMYK and varnishes)
    @AuraEnabled(cacheable=false)
    public static void createRecordsForAssociatedFeatures(String jobTicketMtMId, List<String> pmsValueforFront, 
                                                          List<String> pmsValueforBack, Boolean frontCPType, 
                                                          Boolean backCPType, String optionValueForFront,String optionValueForBack,
                                                          String selectedVarnishColorLabelForFront, String selectedVarnishColorLabelForBack) 
    {
        try 
        {
            ID recordTypesForAssociatedFeature = DatabaseUtilities.getRecordTypeIdForObject('Associated_Features__c', 'Color');
            if(recordTypesForAssociatedFeature != null) 
            {
                //Start Here
                if(String.isNotBlank(jobTicketMtMId) 
                   &&
                   //Modifed by Colin McGloin - Modified so that it runs if either the PMS Code is entered or the 4cp Colors/Varnish field is populated 
                   (((pmsValueforFront != null && pmsValueforFront.size() > 0) || (pmsValueforBack != null && pmsValueforBack.size() > 0))
                   ||
                    (String.isNotBlank(optionValueForFront) ||String.isNotBlank(selectedVarnishColorLabelForFront) || String.isNotBlank(optionValueForBack) ||
                     String.isNotBlank(selectedVarnishColorLabelForBack)))
                )   
                {
                    List<Associated_Features__c> createAssociatedFeatureRecords = new List<Associated_Features__c>();
                    if(frontCPType)
                    {
                        //Modified by - Dipesh Gupta - 03-11-2020 - CR-20200303-13825(Color count per component should include CMYK and varnishes)
                        Map<String,String> mapOfAFFieldWithValueForFront = new Map<String,String>();
                    	List<JTM_to_Associated_Features_Picklist__mdt> listOfJTMToAFPicklistRecords = CustomMetadataTypesQueryBuilder.getJTMToAssociatedFeaturesPicklistMapping();
                        if(listOfJTMToAFPicklistRecords != null && listOfJTMToAFPicklistRecords.size() > 0)
                        {
                            for(JTM_to_Associated_Features_Picklist__mdt jtmToAf : listOfJTMToAFPicklistRecords)
                            {
                                if(optionValueForFront == jtmToAf.Associated_Feature_Field__c)
                                {
                                    mapOfAFFieldWithValueForFront.put(jtmToAf.Associated_Feature_Field__c,jtmToAf.Value_if_Selected__c);
                                }
                                else
                                {
                                    mapOfAFFieldWithValueForFront.put(jtmToAf.Associated_Feature_Field__c,'false');    
                                }
                            }    
                        }
                        else
                        {
                            throw new CustomException(System.Label.Error_Msg_For_Custom_Setting_Not_Exists);
                        }
                        
                        //Check for either value being populated
                        if (pmsValueforFront.size() > 0)
                        {
                            for(String strF : pmsValueforFront)
                            { 
                                createAssociatedFeatureRecords.add(new Associated_Features__c(RecordTypeId = recordTypesForAssociatedFeature, 
                                                                                              Feature_Type__c = 'Color', 
                                                                                              Color_Placement__c = 'Front', 
                                                                                              PMS__c = strF, 
                                                                                              Job_Ticket_MtM__c = jobTicketMtMId
                                                                                             ));
                            }
                        }
                        
                        if (String.isNotBlank(optionValueForFront))  
                        {
                            createAssociatedFeatureRecords.add(new Associated_Features__c(RecordTypeId = recordTypesForAssociatedFeature, 
                                                                                          Feature_Type__c = 'Color', 
                                                                                          Color_Placement__c = 'Front', 
                                                                                          Job_Ticket_MtM__c = jobTicketMtMId,
                                                                                          PMS__c = selectedVarnishColorLabelForFront,
                                                                                          C__c = Boolean.valueOf(mapOfAFFieldWithValueForFront.get('C__c')),
                                                                                          M__c = Boolean.valueOf(mapOfAFFieldWithValueForFront.get('M__c')),
                                                                                          Y__c = Boolean.valueOf(mapOfAFFieldWithValueForFront.get('Y__c')),
                                                                                          K__c = Boolean.valueOf(mapOfAFFieldWithValueForFront.get('K__c')),
                                                                                          Spot_Dull_Varnish__c = Boolean.valueOf(mapOfAFFieldWithValueForFront.get('Spot_Dull_Varnish__c')),
                                                                                          Spot_Gloss_Varnish__c = Boolean.valueOf(mapOfAFFieldWithValueForFront.get('Spot_Gloss_Varnish__c')),
                                                                                          Spot_Matte_Varnish__c = Boolean.valueOf(mapOfAFFieldWithValueForFront.get('Spot_Matte_Varnish__c')),
                                                                                          CMYK__c = Boolean.valueOf(mapOfAFFieldWithValueForFront.get('CMYK__c'))
                                                                                         ));
                            
                        }
                    }
                    if(backCPType)
                    {
                        //Modified by - Dipesh Gupta - 03-11-2020 - CR-20200303-13825(Color count per component should include CMYK and varnishes)
                        Map<String,String> mapOfAFFieldWithValueForBack = new Map<String,String>();
                    	List<JTM_to_Associated_Features_Picklist__mdt> listOfJTMToAFPicklistRecords = CustomMetadataTypesQueryBuilder.getJTMToAssociatedFeaturesPicklistMapping();
                        if(listOfJTMToAFPicklistRecords != null && listOfJTMToAFPicklistRecords.size() > 0)
                        {
                            for(JTM_to_Associated_Features_Picklist__mdt jtmToAf : listOfJTMToAFPicklistRecords)
                            {
                                if(optionValueForBack == jtmToAf.Associated_Feature_Field__c)
                                {
                                    mapOfAFFieldWithValueForBack.put(jtmToAf.Associated_Feature_Field__c,jtmToAf.Value_if_Selected__c);
                                }
                                else
                                {
                                    mapOfAFFieldWithValueForBack.put(jtmToAf.Associated_Feature_Field__c,'false');    
                                }
                            }
                        }
                        else
                        {
                            throw new CustomException(System.Label.Error_Msg_For_Custom_Setting_Not_Exists);
                        }

                        //Check for either value being populated
                        if (pmsValueforBack.size() > 0){

                            for(String strB : pmsValueforBack)
                            { 
                                createAssociatedFeatureRecords.add(new Associated_Features__c(RecordTypeId = recordTypesForAssociatedFeature, 
                                                                                            Feature_Type__c = 'Color', 
                                                                                            Color_Placement__c = 'Back', 
                                                                                            PMS__c = strB, 
                                                                                            Job_Ticket_MtM__c = jobTicketMtMId
                                                                                            ));
                            }
                        }
                        
                        if (String.isNotBlank(optionValueForBack)) 
                        {
                            createAssociatedFeatureRecords.add(new Associated_Features__c(RecordTypeId = recordTypesForAssociatedFeature, 
                                                                                            Feature_Type__c = 'Color', 
                                                                                            Color_Placement__c = 'Back', 
                                                                                            Job_Ticket_MtM__c = jobTicketMtMId,
                                                                                            PMS__c = selectedVarnishColorLabelForBack,
                                                                                            C__c = Boolean.valueOf(mapOfAFFieldWithValueForBack.get('C__c')),
                                                                                            M__c = Boolean.valueOf(mapOfAFFieldWithValueForBack.get('M__c')),
                                                                                            Y__c = Boolean.valueOf(mapOfAFFieldWithValueForBack.get('Y__c')),
                                                                                            K__c = Boolean.valueOf(mapOfAFFieldWithValueForBack.get('K__c')),
                                                                                            Spot_Dull_Varnish__c = Boolean.valueOf(mapOfAFFieldWithValueForBack.get('Spot_Dull_Varnish__c')),
                                                                                            Spot_Gloss_Varnish__c = Boolean.valueOf(mapOfAFFieldWithValueForBack.get('Spot_Gloss_Varnish__c')),
                                                                                            Spot_Matte_Varnish__c = Boolean.valueOf(mapOfAFFieldWithValueForBack.get('Spot_Matte_Varnish__c')),
                                                                                            CMYK__c = Boolean.valueOf(mapOfAFFieldWithValueForBack.get('CMYK__c'))
                                                                                         ));

                        }

                    }
                    //End Here
                    if(createAssociatedFeatureRecords.size()>0)
                    {
                        Util.BypassAllTriggers = true;
                        insert createAssociatedFeatureRecords;  
                        Util.BypassAllTriggers = false;
                    }
                }
            }    
        }
        catch (Exception e) 
        {
            throw new AuraHandledException('Exception occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n'); 
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static void deleteAssociatedFeaturesRecords(list<Id> listofAssociatedFeaturesIds)
    {
        try 
        {
            List<Associated_Features__c> listAFToDelete = new List<Associated_Features__c>();
            for(Id aF : listofAssociatedFeaturesIds) 
            {
                listAFToDelete.add(new Associated_Features__c(Id = aF));
            }
            if(listAFToDelete.size() > 0) 
            {
                Util.BypassAllTriggers = true;
                delete ListAFToDelete;
                Util.BypassAllTriggers = false;
            }    
        }
        catch (Exception e) 
        {
            throw new AuraHandledException('Exception occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n'); 
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Job_Print_Ticket_View_Manager__mdt fetchFieldsOfJobTicketMtM(String jobMtMId)
    {
        try 
        {
            if(String.isNotBlank(jobMtMId)) 
            {
                Map<String, Job_Print_Ticket_View_Manager__mdt> mapOfComponentTypeWithDetails = new Map<String, Job_Print_Ticket_View_Manager__mdt>();
                mapOfComponentTypeWithDetails = CustomMetadataTypesUtilities.getMapOfJTMTypesJobTicketMappings();
                if(mapOfComponentTypeWithDetails.values().size() > 0) 
                {
                    List<Job_Ticket_MtM__c> jobTicketMTMs = JobTicketMtMQueryBuilder.getJobTicketMtMDetails(jobMtMId);
                    if(jobTicketMTMs.size() > 0) 
                    {
                        if(mapOfComponentTypeWithDetails.containsKey(jobTicketMTMs[0].Job_Ticket_Component__r.Component__c)) 
                        {
                            return mapOfComponentTypeWithDetails.get(jobTicketMTMs[0].Job_Ticket_Component__r.Component__c); 	    
                        }	
                        else 
                        {
                            throw new AuraHandledException('Mapping does not exist for the selected component type.' + '\r\n');    
                        }
                    }
                    else 
                    {
                        throw new AuraHandledException('Unable to access Job Ticket MTM Details.' + '\r\n');    
                    }
                }
                else 
                {
                    throw new AuraHandledException('Mapping does not exists for Job Ticket Type v/s field set related details' + '\r\n');    
                }
            }
            else 
            {
                throw new AuraHandledException('Unable to access Job Ticket MTM Details.' + '\r\n');
            }    
        }
        catch (Exception e) 
        {
            throw new AuraHandledException('Exception occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n'); 
        }
    }
    
    
    @AuraEnabled(cacheable=false)
    public static List<Job_Ticket_MTM__c> saveJobTicketMtm(String jobTicketId, 
                                                           String selectedjobTicketComponent) 
    {
        try 
        {
            if(String.isNotBlank(selectedjobTicketComponent) 
               && String.isNotBlank(jobTicketId)		
              ) 
            {
                List<Job_Ticket_MTM__c> jobTicketMtmsToBeCreated = new List<Job_Ticket_MTM__c>();
                List<String> selectedJobtickets = (List<String>) JSON.deserialize(selectedjobTicketComponent , List<String>.class);
                if(selectedJobtickets != null && selectedJobtickets.size() > 0) 
                {
                    Set<String> setOfJobTicketIds = new Set<String>();
                    for(String jbTId : selectedJobtickets) 
                    {
                        setOfJobTicketIds.add(jbTId);    
                    }
                    //Query on the Job ticket Component to get all the selected ones with their component types.
                    Map<Id, Job_Ticket_Component__c> mapJobTicketComponents = new Map<Id, Job_Ticket_Component__c> ([Select Id, Component__c 
                                                                                                                     From Job_Ticket_Component__c Where Id IN: setOfJobTicketIds]);
                    
                    for(String jcId : mapJobTicketComponents.KeySet()) 
                    {
                        Job_Ticket_MTM__c jTM = new Job_Ticket_MTM__c();
                        jTM.Job_Ticket__c = jobTicketId;
                        jTM.Job_Ticket_Component__c = jcId;
                        jTM.Component_Type__c = mapJobTicketComponents.get(jcId).Component__c;
                        jobTicketMtmsToBeCreated.add(jTM);
                    }
                    if(jobTicketMtmsToBeCreated.size() > 0) 
                    {   
                        JobTicketTriggerHelper.Bypass_changeReasonRequiredForLockedRecord = true;
                        insert jobTicketMtmsToBeCreated;
                        JobTicketTriggerHelper.Bypass_changeReasonRequiredForLockedRecord = false;
                        return jobTicketMtmsToBeCreated; 
                    }
                    else
                    {
                        return null;
                    }
                }  
                else
                {
                    throw new AuraHandledException('Unable to deserialize Selected Job Ticket Component.' + '\r\n');
                }
            }
            else 
            {
                throw new AuraHandledException('Unable to access Selected Job Ticket Component details.' + '\r\n');
            }    
        }
        catch (Exception e) 
        {   
            String errorMessage = e.getMessage();
            List<String> splittedByValidationExceptions = new List<String>();
            if(errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
            {
                splittedByValidationExceptions = errorMessage.split('FIELD_CUSTOM_VALIDATION_EXCEPTION');
                errorMessage = errorMessage.split('FIELD_CUSTOM_VALIDATION_EXCEPTION')[splittedByValidationExceptions.size() - 1];
                errorMessage = errorMessage.removeStart(',').removeEnd('[]').trim();
            }
            throw new AuraHandledException(errorMessage);
        }        
    }

    //Modified by - Dipesh Gupta - 03-11-2020 - CR-20200303-13825(Color count per component should include CMYK and varnishes)
    @AuraEnabled(cacheable=true)
    public static List<JTMToAFWrapper> fetchJTMToAssociatedFeaturesPickList()
    {
        try
        {
            List<JTM_to_Associated_Features_Picklist__mdt> listOfJTMToAFPicklistRecords = CustomMetadataTypesQueryBuilder.getJTMToAssociatedFeaturesPicklistMapping();
            List<JTMToAFWrapper> listOfJTMToAF = new List<JTMToAFWrapper>();
            if(listOfJTMToAFPicklistRecords !=null && listOfJTMToAFPicklistRecords.size() > 0)
            {
                for(JTM_to_Associated_Features_Picklist__mdt jtmToAf : listOfJTMToAFPicklistRecords)
                {
                    JTMToAFWrapper newWrapper = new JTMToAFWrapper(jtmToAf.Picklist_Value__c,
                                                                   jtmToAf.Associated_Feature_Field__c,
                                                                   jtmToAf.Value_if_Selected__c);
                    listOfJTMToAF.add(newWrapper);
                }
            }
            else 
            {
                throw new CustomException(System.Label.Error_Msg_For_Custom_Setting_Not_Exists);    
            }
            return listOfJTMToAF;
        }
        catch(Exception e)
        {
            throw new CustomException('Exception occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n'); 
        }
    }

    
    
    
    
    //Modified By - Abhinav Sharma - 05/19/2021 - CR-20210518-15161 - Update the mthod "approveJobTicketMTM" so then "Cannot_Edit_Locked_Job_Ticket_Records" validation rule will
    //			    					      not excute un-necessary
    //Added by - Abhinav Sharma - 02/24/2021 - CR-20201111-14688 - Create Print PT when JT MtM is created
    //Modified By - Abhinav Sharma - 06/08/2021 - CR-20210607-15195 - Add condition for Digital when excluding forms from PT creation
    //Modified By - Nikita Kumari - 10/04/2021 - CR-20210924-15459 - Added boolean "executePopulatesAvailablePriorYearInventoryOnJobTicket" check
    @AuraEnabled(cacheable=false)
    public static LightningResponseEntity approveJobTicketMtM(List<Id> listOfJobTicketMtm)
    {
        LightningResponseEntity res = new LightningResponseEntity();
        try 
        {
            if(listOfJobTicketMtm != null && listOfJobTicketMtm.size() > 0) 
            {
                List<Job_Ticket_MtM__c> listOfJobTicketMtmToBeUpdate = new List<Job_Ticket_MtM__c>();
                List<Production_Tracking__c> listOfProdTrackingToBeInsert = new List<Production_Tracking__c>();
                
                //get Print RT of PT id
                Id recordTypePrintId = Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByName().get('Print').getRecordTypeId();
                
                //Modified By - Abhinav Sharma - 05/17/2021 - CR-20210513-15145 - (Add fields in the query which is populated on Production Tracking records)
                //Modified By - Abhinav Sharma - 06/08/2021 - CR-20210607-15195 - (Add Job_Ticket__r.Vendor_Type__c in the query)
                for(Job_Ticket_MtM__c jTM : [SELECT Id, Approved_DateTime__c, Status__c, Component_Type__c, Job_Ticket__c, Paper_Weightx__c, 
                                             Job_Ticket_Component__r.Size__c, Paper_Typex__c, Window_Size__c, Fold__c, Print_Method__c, Front_of_Colors__c,
                                             Back_of_Colors__c, Job_Ticket__r.Art_Director__c, Job_Ticket__r.Production_Manager__c, Notes__c, Component_Code__c,
                                             Front_Colors_PMS__c, Job_Ticket__r.Vendor_Type__c
                                             FROM Job_Ticket_MtM__c
                                             WHERE Id IN: listOfJobTicketMtm 
                                             AND Status__c != null
                                             AND Status__c != 'Approved'])
                {
                    //Modified By - Abhinav Sharma - 05/19/2021 - CR-20210518-15161 - Add the condition for component code/paper type/paper weight etc and
                    //						                      set Production_Tracking_Created__c is true 
                    if(String.isBlank(jTM.Paper_Typex__c) || String.isBlank(jTM.Paper_Weightx__c) || String.isBlank(jTM.Component_Code__c) || 
                       (jTM.Front_of_Colors__c == null && String.isBlank(jTM.Front_Colors_PMS__c)))
                    {
                        throw new CustomException(Label.Before_Status_As_Approved_Msg);    
                    }
                    else
                    {
                        listOfJobTicketMtmToBeUpdate.add(new Job_Ticket_MtM__c(Id = jTM.Id, Status__c = Label.Status_Approved, Approved_DateTime__c = System.now(),
                                                                               Production_Tracking_Created__c = true));
                    }
                    
                    //Modified By - Abhinav Sharma - 06/08/2021 - CR-20210607-15195 - (Add condition Job_Ticket__r.Vendor_Type__c)
                    if((jTM.Component_Type__c != 'Form' && jTM.Job_Ticket__r.Vendor_Type__c == 'Digital') || jTM.Job_Ticket__r.Vendor_Type__c == 'Offset')
                    {
		    	//Modified By - Abhinav Sharma - 06/04/2021 - CR-20210524-15178 - add in list part i.e. Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL
                        //Modified By - Abhinav Sharma - 05/17/2021 - CR-20210513-15145 - (Populate the additionally fields on Production Tracking record)
                        listOfProdTrackingToBeInsert.add(new Production_Tracking__c(Job_Ticket__c = jTM.Job_Ticket__c, Job_Ticket_MtM__c = jTM.Id, 
                                                                                    RecordTypeId = recordTypePrintId, Component__c = jTM.Component_Type__c,
                                                                                    Status__c = Label.Print_Production_Tracking_Creation_Status,
                                                                                    Paper_Weight__c = jTM.Paper_Weightx__c, Size__c = jTM.Job_Ticket_Component__r.Size__c,
                                                                                    Paper_Type__c = jTM.Paper_Typex__c, Window__c = jTM.Window_Size__c,
                                                                                    Type_of_Fold__c = jTM.Fold__c, Print__c = jTM.Print_Method__c,
                                                                                    of_Colors_Front__c = jTM.Front_of_Colors__c, of_Colors_Back__c = jTM.Back_of_Colors__c,
                                                                                    JT_Art_Director_LU__c = jTM.Job_Ticket__r.Art_Director__c,
                                                                                    Print_Production_Manager__c = jTM.Job_Ticket__r.Production_Manager__c,
                                                                                    Print_Shop_Notes__c = jTM.Notes__c, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL));
                    }
                }
                
                if(listOfJobTicketMtmToBeUpdate.size() > 0)
                {
                    Util.BypassAllTriggers = true;
                    //Added By - Nikita Kumari - 10/04/2021 - CR-20210924-15459 - Added boolean "executePopulatesAvailablePriorYearInventoryOnJobTicket" check
                    executePopulatesAvailablePriorYearInventoryOnJobTicket = true;
                    Update listOfJobTicketMtmToBeUpdate;
                    Util.BypassAllTriggers = false;
                    res.setBody(listOfJobTicketMtmToBeUpdate);
                    res.setSuccess(true);
                } 
                
                if(listOfProdTrackingToBeInsert.size() > 0){
                    Insert listOfProdTrackingToBeInsert;
                    res.setBody(listOfProdTrackingToBeInsert);
                    res.setSuccess(true);
                    
                    //Added By - Abhinav Sharma - 06/04/2021 - CR-20210524-15178 - OE/BRE-Automation QA/Issues Fixes
                    Set<Id> setJobTicketIds = new Set<Id>{listOfProdTrackingToBeInsert[0].Job_Ticket__c};
                    
                    if(listOfProdTrackingToBeInsert[0].Job_Ticket__r.Box_Folder_Id__c == null){
                        Batch_CreateBoxFolderForJT batchJobTicket = new Batch_CreateBoxFolderForJT(setJobTicketIds);
                        Database.executeBatch(batchJobTicket, 1);
                    }else{
                        Batch_CreateBoxFolderForPT batchProductionTracking = new Batch_CreateBoxFolderForPT(setJobTicketIds);
                        Database.executeBatch(batchProductionTracking, 1);
                    }
                }
                //Added By - Nikita Kumari - 10/01/2021 - CR-20210929-15468 -  Added condition to show error message when user approve job ticket mtm's whose status is blank.
                if(listOfJobTicketMtmToBeUpdate.size() == 0 && listOfProdTrackingToBeInsert.size() == 0)
                    res.setError(Label.JTM_Status_Blank_Error_Msg);
            }
            return res;
        }
        catch (Exception e) 
        {
            System.debug('##e.getMessage()' + e.getMessage() +' - '+ e.getLineNumber());
            String errorMessage = e.getMessage();
            List<String> splittedByValidationExceptions = new List<String>();
            if(errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
            {
                splittedByValidationExceptions = errorMessage.split('FIELD_CUSTOM_VALIDATION_EXCEPTION');
                errorMessage = errorMessage.split('FIELD_CUSTOM_VALIDATION_EXCEPTION')[splittedByValidationExceptions.size() - 1];
                errorMessage = errorMessage.removeStart(',').removeEnd('[]').trim();
            }
            res.setError(errorMessage);
            return res;
        }
    }
    
    public class JobTicketComponentWrapper 
    {
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public String JobCompName {get;set;}
        @AuraEnabled public String JobCompComponent {get;set;}
        @AuraEnabled public String JobCompPaperWeight {get;set;}
        @AuraEnabled public String JobCompPaperType {get;set;}
        @AuraEnabled public String JobCompSize {get;set;}
        @AuraEnabled public String ColorBreakdown {get;set;}
        @AuraEnabled public String PMSColorBreakdown {get;set;}
        @AuraEnabled public String JobTicketCompNameForTab {get;set;}
        //Added By - Abhinav Sharma - 02/23/2021 - CR-20201111-14688 - Create Print PT when JT MtM is created
        @AuraEnabled public String JobTicketCompStatus {get;set;} 
        
        public JobTicketComponentWrapper (String jobMtMID, String jobMtMName, String JobCompName, 
                                          String JobCompComponent, String JobCompPaperWeight, String JobCompPaperType, String JobCompSize, 
                                          String ColorBreakdown, String PMSColorBreakdown,String JobCompForTab, String JobTicketMtmStatus) 
        {
            this.Id = jobMtMID;
            this.Name = jobMtMName;
            this.JobCompName = JobCompName;
            this.JobCompComponent = JobCompComponent;
            this.JobCompPaperWeight = JobCompPaperWeight;
            this.JobCompPaperType = JobCompPaperType;
            this.JobCompSize = JobCompSize;
            this.ColorBreakdown = ColorBreakdown;
            this.PMSColorBreakdown = PMSColorBreakdown;
            this.JobTicketCompNameForTab = JobCompForTab;
	    //Added By - Abhinav Sharma - 02/23/2021 - CR-20201111-14688 - Create Print PT when JT MtM is created
            this.JobTicketCompStatus = JobTicketMtmStatus;
        }
    }
    
    public class AssociatedFeatureWrapper 
    {
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public String JobTicketComponent {get;set;}
        @AuraEnabled public String PMS {get;set;}
        @AuraEnabled public String ColorPlacement {get;set;}
        @AuraEnabled public String JobTicketMtMName {get;set;}
        @AuraEnabled public Boolean C {get;set;}
        @AuraEnabled public Boolean M {get;set;}
        @AuraEnabled public Boolean Y {get;set;}
        @AuraEnabled public Boolean K {get;set;}
        @AuraEnabled public Boolean SpotDullVarnish {get;set;}
        @AuraEnabled public Boolean SpotGlossVarnish {get;set;}
        @AuraEnabled public Boolean SpotMatteVarnish {get;set;}
        @AuraEnabled public Boolean CMYK;
        public AssociatedFeatureWrapper (String associatedFeatureId, String associatedFeatureName, 
                                         String JobTicketComponent, String PMS, String ColorPlacement, 
                                         String JobTicketMtMName, Boolean C, Boolean M, Boolean Y, Boolean K, Boolean SpotDullVarnish,
                                         Boolean SpotGlossVarnish, Boolean SpotMatteVarnish, Boolean CMYK) 
        {
            this.Id = associatedFeatureId;
            this.Name = associatedFeatureName;
            this.JobTicketComponent = JobTicketComponent;
            this.PMS = PMS;
            this.ColorPlacement = ColorPlacement;
            this.JobTicketMtMName = JobTicketMtMName;
            this.C = C;
            this.M = M;
            this.Y = Y;
            this.K = K;
            this.SpotDullVarnish = SpotDullVarnish;
            this.SpotGlossVarnish = SpotGlossVarnish;
            this.SpotMatteVarnish = SpotMatteVarnish;
            this.CMYK = CMYK;
        }
    }

    public class JTMToAFWrapper
    {
        @auraEnabled public String AFlabel {get;set;}
        @auraEnabled public String AFApiName {get;set;}
        @auraEnabled public String AFvalue {get;set;}
        public JTMToAFWrapper(String AFlabel, String AFApiName, String AFvalue)
        {
            this.AFlabel = AFlabel;
            this.AFApiName = AFApiName;
            this.AFvalue = AFvalue;
        }
    }
    
}