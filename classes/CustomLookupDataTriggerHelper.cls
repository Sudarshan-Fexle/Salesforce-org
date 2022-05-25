/**
 *  Purpose         :   Helper class for the Custom Lookup Data trigger
 *
 *  Created By      :   Victor Hanson
 *
 *  Created Date    :   04/26/2018
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/ 
public class CustomLookupDataTriggerHelper {
    
    public static final string PROPOSAL_GRADE_BATCH_NAME = 'Batch_ProposalGradeUpdate';
    public static final Id GRADE_CRITERIA_RT_ID = Schema.SObjectType.Custom_Lookup_Data__c.getRecordTypeInfosByName().get('Grade Criteria').getRecordTypeId();
    
	/**
     *
     *   @description    :   get field set
     *
     *   @revision Log   :   V_1.0 - Created - Victor Hanson - 04/28/2018
     *
     **/
    public static List<Schema.FieldSetMember> recalculationFields {
        get {
            if (recalculationFields == null) recalculationFields = SObjectType.Custom_Lookup_Data__c.FieldSets.Grade_Recalculation_Fields.getFields();
            return recalculationFields;
        }
        set;
    }
    
    /**
     *
     *   @description    :   When fields that are in the 'Grade Recalculation Fields' field set are updated on
     * 						a Custom Lookup Data record where RecordType = Grade Criteria, it calls a batch job that
     * 						updates the Execute Price Rules field, which causes the CPQ Price Rules to execute on non-contracted proposals 
     *
     *   @revision Log   :   V_1.0 - Created - Victor Hanson - 04/28/2018
     *
     **/
    public static void recalculateProposalGrades(list<Custom_Lookup_Data__c> newListCustomLookup, map<Id, Custom_Lookup_Data__c> oldMapCustomLookup) {
        
        boolean executeJob = false;
        
        if (oldMapCustomLookup == null) return;
        
        for (Custom_Lookup_Data__c customLookup : newListCustomLookup) {
            
            //don't process if this isn't a "Grade Criteria" record type
            if (customLookup.RecordTypeId != GRADE_CRITERIA_RT_ID) continue;
            
            //check if any field on the custom lookup data record has been changed
            Custom_Lookup_Data__c oldCustomLookup = oldMapCustomLookup.get(customLookup.Id);
            if (oldCustomLookup != null) {
                for (Schema.FieldSetMember f : recalculationFields) {
                    if (customLookup.get(f.getFieldPath()) != oldCustomLookup.get(f.getFieldPath())) {
                        
                        executeJob = true;
                        break;
                    }
                }
            }
        }
        
        if (executeJob) {
            
            //execute the job
            Id gradeJobId = Database.executeBatch(new Batch_ProposalGradeUpdate(), 5);
            
            //cancel any other executions of this job
            for (AsyncApexJob aJob : [SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = :PROPOSAL_GRADE_BATCH_NAME AND Id != :gradeJobId])
                System.AbortJob(aJob.Id);
        }
    }
    
   /**
    *
    *   @description    :   URL Encodes the name of the Grade Criteria record, which is referenced in a Custom Action URL
    *
    *   @revision Log   :   V_1.0 - Created - Victor Hanson - 04/28/2018
    *
    **/
    public static void populateURLEncodedName(list<Custom_Lookup_Data__c> newListCustomLookup) {
        for (Custom_Lookup_Data__c customLookup : newListCustomLookup) {
            string encodedName = customLookup.Name.replace('%', '%25').replace('+', '%2B');
            customLookup.URL_Encoded_Name__c = EncodingUtil.urlEncode(customLookup.Name, 'UTF-8').replace('+', '%20');
        }
    }
}