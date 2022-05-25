/**
*   Desription      :   Controller class to hold the logic to draw VF Table-Grid for constructing dynamic related lists
* 
*   Created By      :   Mahendra Swarnkar
* 
*   Created Date    :   04/30/2016
* 
*   Revision Logs   :   V1.0 - Created
                        V1.1 - Modified By - Mahendra Swarnakar - CR-20160308-9682
						V1.2 - Modified By - Mahendra Swarnakar - CR-20160526-9880 - 8/28/2016 - Added new field in "fielsNameString" String in line 151
						V1.3 - Modified By - Rajeev Jain - 08/20/2018 - CR-20170812-11145 - Change the Staff Assignment Related List on Institution Page.
						V1.4 - Modified By - Colin McGloin - 10/13/2018 - CR-20181012-12668 - Membership Key Contact field changes on list displayed/ordering
						V1.5 - Modified By Abhinav sharma - 12/18/2018 - CR-20181213-12785 - Added Role_Type__c,Membership__c in query. 
*
**/
public with sharing class TableGridWrapperController {
    
    //Constants Variables
    public final static String STAFF_ASSIGNMENT_OBJECT_API_NAME = 'Team_Membership__c';
    public final static String STAFF_ASSIGNMENT_RELATED_LIST_FIELDS_STRING = 'Name, Staff_member__c, Institution__c, Assigned_To__c, Role__c, Program_Perspectives__c, Start_date__c, End_date__c, RecordTypeId';
    public final static String BLANK_STR = '';
    public final static String PARENT_OBJECT_API_NAME_FOR_SA = 'Opportunity__c';
    public final static String BLANK_SPACE = ' ';
    public final static String SORT_BY_FIELD_NAME_FOR_SA = 'Institution__c';
    public final static String STAFF_ASSIGNMENT_RELATED_LIST_UNIQUE_NAME = 'Opp_SA_Related_List';
    public final static String RELATED_LIST_DISPLAY_MODE_LIST = 'list';
    public final static Integer DEFAULT_PAGE_SIZE = 10;
    public final static String STAFF_ASSIGNMENT_OBJECT_LABEL = 'Staff Assignments';
    
    /*Added By Rajeev Jain - 08/20/2018 - CR-20170812-11145 - Starts here */
    //Variable to hold the filter criteria for the account related Staff assignment. 
	public String staffAssignmentFilterCriteria{get; set;} 
    /*Added By Rajeev Jain - 08/20/2018 - CR-20170812-11145 - Ends here */

    //properties
    public Id masterRecordId {get; set;} 
    public String childObjectName {get; set;}
    public String recordTypeName {get; set;} 
    
    //Wrapper list to hold "Visualforce TableGrid" instance(s) for drawing either one or multple child objects 
    //associated related list(s) on the overrided VF page in detail view
    public List<DynamicRelatedListTableGridWrapper> dynamicRelatedListWrapperList { 
        get {
            
            //Initialize the wrapper class instance
            List<DynamicRelatedListTableGridWrapper> dynamicRelatedListWrapperListTemp = new List<DynamicRelatedListTableGridWrapper>();
            
            //Get the sObjectType from Id value
            SObjectType sObjType = masterRecordId.getSObjectType();
            
            //Default wrapper instance for New records
            SObject defaultSObjectInstance = Schema.getGlobalDescribe().get(childObjectName).newSObject();
                
            //Check for the opporutnity object
            if(sObjType == Schema.Opportunity.SObjectType) {
                
                //Recotrd Type Opportunity
                List<RecordType> oppRecordType = [Select Id from RecordType where DeveloperName = 'Opportunity_Staff_Assignments' AND SobjectType = 'Team_Membership__c' AND IsActive = true limit 1];
                if(oppRecordType.size() == 0)
                    return null;
                
                //Populating wrapper instance with properties values necessary to draw staff assignment dynamic list on
                //Opportunity detail page (Record type = Consulting & Management)
                DynamicRelatedListTableGridWrapper wrapper = new DynamicRelatedListTableGridWrapper();
                wrapper.childObjectAPIName = STAFF_ASSIGNMENT_OBJECT_API_NAME;
                wrapper.fielsNameString = STAFF_ASSIGNMENT_RELATED_LIST_FIELDS_STRING;
                wrapper.requiredFielsNameString = 'Name, Staff_member__c, Institution__c, Role__c, Start_date__c';
                
                //Wrapper instances helpful in populating filter related instance
                wrapper.filterCriteriaString = BLANK_STR;
                wrapper.parentObjectFieldAPIName = PARENT_OBJECT_API_NAME_FOR_SA;
                wrapper.parentRecordId= masterRecordId;    
                
                //Checking "wrapper.filterCriteriaString" for blank/null value
                //Accordingly constructing a dtring like "AccountId = `{!Account.Id}`"                         
                if(String.isNotBlank(wrapper.filterCriteriaString))
                    wrapper.filterCriteriaString = wrapper.filterCriteriaString +BLANK_SPACE 
                                                    + wrapper.parentObjectFieldAPIName + ' = \'' + wrapper.parentRecordId +'\'';
                else
                    wrapper.filterCriteriaString = wrapper.parentObjectFieldAPIName + ' = \'' + wrapper.parentRecordId +'\'';
        
                wrapper.relatedListName =  STAFF_ASSIGNMENT_OBJECT_LABEL;
                wrapper.sortByFieldName = SORT_BY_FIELD_NAME_FOR_SA;
                wrapper.sortByOrderDescending = true;
                wrapper.relatedListUniqueName = STAFF_ASSIGNMENT_RELATED_LIST_UNIQUE_NAME;
                wrapper.relatedListDisplayMode = RELATED_LIST_DISPLAY_MODE_LIST;
                //wrapper.relatedListCustomizeFields = true;
                //wrapper.relatedListCustomizeFilter = true; 
                wrapper.relatedListSaveSettings = true;
                wrapper.relatedlistPageSize = DEFAULT_PAGE_SIZE;
                wrapper.hiddenFieldsString = 'recordtypeid';
                
                //Populate the SObject with the default values. Later, it will be handled by database in phase2.
                wrapper.defaultSObjectInstance = defaultSObjectInstance;
                wrapper.defaultSObjectInstance.put('name', 'Will Auto-Populate');
                wrapper.defaultSObjectInstance.put('recordtypeid', oppRecordType[0].Id);
                wrapper.defaultSObjectInstance.put(wrapper.parentObjectFieldAPIName, wrapper.parentRecordId);
                
                //Populating wrapper list with instance
                dynamicRelatedListWrapperListTemp.add(wrapper);
            
            } else if(sObjType == Schema.Account.SObjectType ) {
                
                //Staff Assignment Record Type for Account Type 
                List<RecordType> accRecordType = [Select Id from RecordType where DeveloperName = 'Default' AND SobjectType = 'Team_Membership__c' AND IsActive = true limit 1];
                if(accRecordType.size() == 0)
                    return null;
                
                //Populating wrapper instance with properties values necessary to draw staff assignment dynamic list on
                //Opportunity detail page (Record type = Consulting & Management)
                DynamicRelatedListTableGridWrapper wrapper = new DynamicRelatedListTableGridWrapper();
                wrapper.childObjectAPIName = STAFF_ASSIGNMENT_OBJECT_API_NAME;
                wrapper.fielsNameString = 'Name, Staff_member__c, Institution__c, Role__c, Program_Perspectives__c, Start_date__c, End_date__c, RecordTypeId';
                wrapper.requiredFielsNameString = 'Name, Staff_member__c, Institution__c, Role__c, Start_date__c';
                
                /*Modify by Rajeev Jain - 08/20/2018 - CR-20170812-11145 - Starts here - Commented out BLANK_STR in the Filter Criteria */
                //Wrapper instances helpful in populating filter related instance
                //wrapper.filterCriteriaString = BLANK_STR;
                wrapper.filterCriteriaString = staffAssignmentFilterCriteria ;
                /*Modify by Rajeev Jain - 08/20/2018 - CR-20170812-11145 - Ends here */
 
                
                wrapper.parentObjectFieldAPIName = 'Institution__c';
                wrapper.parentRecordId = masterRecordId;    
                wrapper.hiddenFieldsString = 'recordtypeid';
                
                //Checking "wrapper.filterCriteriaString" for blank/null value
                //Accordingly constructing a dtring like "AccountId = `{!Account.Id}`"                         
                if(String.isNotBlank(wrapper.filterCriteriaString))
                    wrapper.filterCriteriaString = wrapper.filterCriteriaString +BLANK_SPACE + 'AND' + BLANK_SPACE
                                                    + wrapper.parentObjectFieldAPIName + ' = \'' + wrapper.parentRecordId +'\'';
                else
                    wrapper.filterCriteriaString = wrapper.parentObjectFieldAPIName + ' = \'' + wrapper.parentRecordId +'\'';
        
                wrapper.relatedListName = STAFF_ASSIGNMENT_OBJECT_LABEL;
                
                /*Added By Rajeev Jain - 08/20/2018 - CR-20170812-11145 - Starts here */
                wrapper.sortByFieldName = 'Role__c';
                wrapper.sortByOrderDescending = false;
                /*Added By Rajeev Jain - 08/20/2018 - CR-20170812-11145 - Ends here */
                
                wrapper.relatedListUniqueName = STAFF_ASSIGNMENT_RELATED_LIST_UNIQUE_NAME;
                wrapper.relatedListDisplayMode = RELATED_LIST_DISPLAY_MODE_LIST;
                //wrapper.relatedListCustomizeFields = true;
                //wrapper.relatedListCustomizeFilter = true; 
                wrapper.relatedListSaveSettings = true;
                wrapper.relatedlistPageSize = DEFAULT_PAGE_SIZE;
                //wrapper.changeNoOfRecordsOnPage = True;
                
                //Populate the SObject with the default values. Later, it will be handled by database in phase2.
                wrapper.defaultSObjectInstance = defaultSObjectInstance;
                wrapper.defaultSObjectInstance.put('name', 'Will Auto-Populate');
                wrapper.defaultSObjectInstance.put('RecordTypeId', accRecordType[0].Id);
                wrapper.defaultSObjectInstance.put(wrapper.parentObjectFieldAPIName, wrapper.parentRecordId);
                
                //Populating wrapper list with instance
                dynamicRelatedListWrapperListTemp.add(wrapper);
            }
            else
            //Check for Membership Object
             if(sObjType == Schema.Membership__c.SObjectType ) {
                
                //Populating wrapper instance with properties values necessary to draw staff assignment dynamic list on
                //Opportunity detail page (Record type = Consulting & Management)
                DynamicRelatedListTableGridWrapper wrapper = new DynamicRelatedListTableGridWrapper();
                wrapper.childObjectAPIName = childObjectName;
                 
                //Modified By - Mahendra Swarnakar - CR-20160526-9880 - 8/28/2016
                //Modified By - Colin McGloin - CR-20181012-12668
                //Modified By Abhinav sharma - 12/18/2018 - CR-20181213-12785 - Added Role_Type__c, Membership__cin query. 
                //Start from here
                wrapper.fielsNameString = 'Name, Contact__c, Role__c, Role_Type__c, Site_Profile_Status__c, Contact_Status__c, Contact_Institution__c,Membership__c';
                //Upto here
                 
                 wrapper.requiredFielsNameString ='Name, Membership__c, Contact__c';
                wrapper.hiddenFieldsString = 'recordtypeid,membership__c';
                 
                //Wrapper instances helpful in populating filter related instance
                wrapper.filterCriteriaString = BLANK_STR;
                wrapper.parentObjectFieldAPIName = 'Membership__c';
                wrapper.parentRecordId = masterRecordId;    
                
                //Checking "wrapper.filterCriteriaString" for blank/null value
                //Accordingly constructing a string like "AccountId = `{!Account.Id}`"                         
                if(String.isNotBlank(wrapper.filterCriteriaString))
                    wrapper.filterCriteriaString = wrapper.filterCriteriaString +BLANK_SPACE 
                                                    + wrapper.parentObjectFieldAPIName + ' = \'' + wrapper.parentRecordId +'\'';
                else
                    wrapper.filterCriteriaString = wrapper.parentObjectFieldAPIName + ' = \'' + wrapper.parentRecordId +'\'';
        
                wrapper.relatedListName = 'Membership Key Contacts';
                
                wrapper.sortByFieldName = 'Role__c';
                wrapper.sortByOrderDescending = true;
                wrapper.relatedListUniqueName = 'TG_Membership_Key_Contacts';
                wrapper.relatedListDisplayMode = RELATED_LIST_DISPLAY_MODE_LIST;
                //wrapper.relatedListCustomizeFields = true;
                //wrapper.relatedListCustomizeFilter = true; 
                wrapper.relatedListSaveSettings = true;
                wrapper.relatedlistPageSize = 5;
                wrapper.relatedlistImage = '/img/icon/custom51_100/keys32.png';
                
                //Populate the SObject with the default values. Later, it will be handled by database in phase2.
                wrapper.defaultSObjectInstance = defaultSObjectInstance;
                wrapper.defaultSObjectInstance.put('name', 'Will Auto-Populate');
                wrapper.defaultSObjectInstance.put(wrapper.parentObjectFieldAPIName, wrapper.parentRecordId);
                
                //Populating wrapper list with instance
                dynamicRelatedListWrapperListTemp.add(wrapper);
            }
            
            return dynamicRelatedListWrapperListTemp;
        }
    }
}