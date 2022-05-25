/*
Purpose         :   Lookup Wrapper Class
Created By      :   Abhinav Sharma
Created Date    :   07/25/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 07/25/2021
*/
public without sharing class dynlistLookup 
{
    //Properties to hold the selected record name and record Id
    @AuraEnabled
    public String selectedRecordName { get; set; }
    
    @AuraEnabled
    public String selectedRecordId { get; set; }
    
    @AuraEnabled
    public String selectRecordURL { get; set; }
    
    @AuraEnabled
    public String fieldName { get; set; }
    
    @AuraEnabled
    public String objectName { get; set; }
    
    public dynlistLookup() 
    {
        this.selectedRecordName = dynlistConstants.CHAR_BLANK_STRING;
        this.selectedRecordId = dynlistConstants.CHAR_BLANK_STRING;
    }
    
    public dynlistLookup(String selectedRecordId, String selectedRecordName) 
    {
        this.selectedRecordName = selectedRecordName;
        this.selectedRecordId = selectedRecordId;
        if (selectedRecordId != null) 
        {
            selectRecordURL = dynlistUtilities.DYNLIST_ORG_HOST_URL + selectedRecordId;
        } else 
        {
            selectRecordURL = dynlistConstants.CHAR_BLANK_STRING;
        }
    }
    
    public dynlistLookup(
        String selectedRecordId,
        String selectedRecordName,
        String fieldName,
        String objectName
    ) 
    {
        this.selectedRecordName = selectedRecordName;
        this.selectedRecordId = selectedRecordId;
        this.fieldName = fieldName;
        this.objectName = objectName;
        if (selectedRecordId != null) 
        {
            if (
                String.isNotBlank(fieldName) &&
                fieldName == dynlistConstants.RECORD_TYPE_ID_FIELD_NAME
            ) 
            {
                selectRecordURL =
                    dynlistUtilities.DYNLIST_RECORD_TYPE_HOST_URL +
                    dynlistConstants.CHAR_BACK_SLASH +
                    objectName +
                    dynlistConstants.TEXT_RECORD_TYPES_WITH_BACK_SLASHES +
                    selectedRecordId +
                    dynlistConstants.TEXT_VIEW_WITH_BACK_SLASH;
            } else 
            {
                selectRecordURL = dynlistUtilities.DYNLIST_ORG_HOST_URL + selectedRecordId;
            }
        } else 
        {
            selectRecordURL = dynlistConstants.CHAR_BLANK_STRING;
        }
    }
}