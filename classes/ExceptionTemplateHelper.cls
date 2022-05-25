/*
    Purpose         :   Helper class for Exception Template trigger
    
    Revision Logs   :   V_1.0 - 03/20/2019 - Created - Victor Hanson - CR-20181019-12685
*/
public class ExceptionTemplateHelper {
	
    //static final variables
    public static final String EXCEPTION_TEMPLATE_MASTER_RT_ID = 
        Schema.SObjectType.Exception_Template__c.getRecordTypeInfosByDeveloperName().get('Master_Template').getRecordTypeId();
    
    public static final String EXCEPTION_TEMPLATE_VERSION_RT_ID = 
        Schema.SObjectType.Exception_Template__c.getRecordTypeInfosByDeveloperName().get('Version').getRecordTypeId();
    
    /**
     * 
     * @description: increments the master template version if any of the key fields were updated
     * 
     * @revision log: 03/20/2019 - Created - Victor Hanson - CR-20181019-12685
     * 
     **/
    public static void incrementTemplateVersion(List<Exception_Template__c> templates, Map<Id, Exception_Template__c> oldTemplateMap) {
        
        for(Exception_Template__c template : templates) {
            Exception_Template__c oldTemplate;
            if (oldTemplateMap != null) oldTemplate = oldTemplateMap.get(template.Id);
            boolean isNewVersion = requiresNewVersion(template, oldTemplate);
            
            //if this is a new version, increment version number and clone a version Exception Template record
            if (isNewVersion) {
                Decimal version = template.Version__c != null ? template.Version__c : 0;
                version += 1;
                template.Version__c = version;
            }
        }
    }
    
    //clone the master exception template to create a new version if key fields were updated
    public static void createExceptionVersion(List<Exception_Template__c> templates, Map<Id, Exception_Template__c> oldTemplateMap) {
        
        List<Exception_Template__c> versionsToInsert = new List<Exception_Template__c>();
        
        for(Exception_Template__c template : templates) {
            Exception_Template__c oldTemplate;
            if (oldTemplateMap != null) oldTemplate = oldTemplateMap.get(template.Id);
            boolean isNewVersion = requiresNewVersion(template, oldTemplate);
            
            //if this is a new version, increment version number and clone a version Exception Template record
            if (isNewVersion) {
                Exception_Template__c newVersion = template.clone();
                newVersion.RecordTypeId = EXCEPTION_TEMPLATE_VERSION_RT_ID;
                newVersion.Parent_Template__c = template.Id;
                versionsToInsert.add(newVersion);
            }
        }
        
        if (versionsToInsert.size() > 0) {
            insert versionsToInsert;
        }
    }
    
    /**
     * 
     * @description: check to see if any key fields were modified
     * 
     * @revision log: 03/20/2019 - Created - Victor Hanson - CR-20181019-12685
     * 
     **/
    public static boolean requiresNewVersion(Exception_Template__c template, Exception_Template__c oldTemplate) {
        return (template.RecordTypeId == EXCEPTION_TEMPLATE_MASTER_RT_ID
                && (oldTemplate == null
                    || oldTemplate.Alternative_Language_Header__c != template.Alternative_Language_Header__c
                    || oldTemplate.Alternative_Language__c != template.Alternative_Language__c
                    || oldTemplate.Section_Name__c != template.Section_Name__c
                    || oldTemplate.Section__c != template.Section__c
                    || oldTemplate.Name != template.Name));
    }
    
    /**
     *  @description    :   This method is used to perform the logic:- 
     * 						When the master template changes, 
     * 						then any CPQ Contract Exceptions that use this master template (Proposal should be in 'Draft', 'In Review', 'Approved' status, CPQ Template Request is in 'Draft' or 'Request Legal Approval' status), 
	 * 						should be updated to use the new template/version.
     * 
     *  @args           :   List<Exception_Template__c>, Map<Id, Exception_Template__c>
     *
     *  @return         :   void
     *
     *  @Version        :   V1.0 - Created By - Mahendra Swarnkar - 06/10/2019 - CR-20181019-12685
     *
    **/
    public static void updateContractExceptions(List<Exception_Template__c> templates, Map<Id, Exception_Template__c> oldTemplateMap) {
    	
    	//Set to Hold the Master Exception Templates Ids
    	Set<Id> setMasterExceptionIds = new Set<Id>();
    	
    	//Loop over the Master Exception Templates 
    	for(Exception_Template__c template : templates){
    	
    		//Update case
    		if(template.RecordTypeId == EXCEPTION_TEMPLATE_MASTER_RT_ID && template.Version__c > 1 && oldTemplateMap != null && template.Version__c !=  oldTemplateMap.get(template.Id).Version__c){
    			setMasterExceptionIds.add(template.Id);
    		}
    	}
    	
    	//check for size
    	if(setMasterExceptionIds.size() > 0){
    		
    		//Execute the batch to update the CPQ Contract Exceptions
    		BatchUpdateContractExceptionTemplate b = new BatchUpdateContractExceptionTemplate(setMasterExceptionIds);
    		Database.executeBatch(b, 200);
    	}
    }
    
    /**
     *  @description    :   This method is used to update the version templates to archived when master Template is changese from active to archived.
     * 
     *  @args           :   List<Exception_Template__c>, Map<Id, Exception_Template__c>
     *
     *  @return         :   void
     *
     *  @Version        :   V1.0 - Created By - Mahendra Swarnkar - 06/21/2019 - CR-20181019-12685
     *
    **/
    public static void updateVersionTemplateToArchived(List<Exception_Template__c> templates, Map<Id, Exception_Template__c> oldTemplateMap) {
    	
    	//Set to Hold the Master Exception Templates Ids
    	Set<Id> setMasterExceptionIds = new Set<Id>();
    	
    	//Loop over the Master Exception Templates 
    	for(Exception_Template__c template : templates){
    	
    		//insert/Update case
    		if(template.RecordTypeId == EXCEPTION_TEMPLATE_MASTER_RT_ID && template.Status__c == 'Archived' && (oldTemplateMap != null && template.Status__c !=  oldTemplateMap.get(template.Id).Status__c)){
    			setMasterExceptionIds.add(template.Id);
    		}
    	}
    	
    	//check for size
    	if(setMasterExceptionIds.size() > 0){
    		
            //List TO hold the version exception Templates to be marked as Archived
            List<Exception_Template__c> listArchivedVersionTemplates = new List<Exception_Template__c>();
            
            //Query Version Excepion Templates
            for(Exception_Template__c version : [Select Id, Status__c From Exception_Template__c Where Parent_Template__c != null AND Parent_Template__c IN : setMasterExceptionIds AND RecordTypeId =: EXCEPTION_TEMPLATE_VERSION_RT_ID]) {
                version.Status__c = 'Archived';
                listArchivedVersionTemplates.add(version);
            }
            
            //check for the size
            if(listArchivedVersionTemplates.size() > 0){
                
                //Bypass all the triggers
                Util.BypassAllTriggers = true;
                
                //Update the versions
                update listArchivedVersionTemplates; 
                
                //Enable all triggers
                Util.BypassAllTriggers = false;   
            }
    	}
    }
}