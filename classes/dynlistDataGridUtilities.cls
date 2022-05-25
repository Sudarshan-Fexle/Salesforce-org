/*
Purpose         :   Data Grid Utilities (Dynamic Related List)
Created By      :   Abhinav Sharma
Created Date    :   07/24/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 07/24/2021
*/
public without sharing class dynlistDataGridUtilities 
{
    public static String doPrimaryValidations(
        dynlistDataGridRequestWrapper requestWrapper
    ) 
    {
        if (requestWrapper != null) 
        {
            if (String.isBlank(requestWrapper.view)) 
            {
                return System.Label.DYNLIST_ERROR_PLEASE_SPECIFY_DEFAULT_VIEW;
            }
            if (requestWrapper.pageSize == null) 
            {
                return System.Label.DYNLIST_PLEASE_SPECIFY_PAGE_SIZE;
            }
            if (requestWrapper.pageSize <= 0) 
            {
                return System.Label.DYNLIST_PLEASE_SPECIFY_VALID_PAGE_SIZE;
            }
            if (String.isBlank(requestWrapper.objectName)) 
            {
                return System.Label.DYNLIST_ERROR_PLEASE_SPECIFY_OBJECT_NAME;
            }
            if (String.isBlank(requestWrapper.defaultSortFieldName)) 
            {
                return System.Label.DYNLIST_ERROR_PLEASE_SPECIFY_SORT_BY_FIELD_NAME;
            }
            if (String.isBlank(requestWrapper.defaultSortDirection)) 
            {
                return System.Label.DYNLIST_ERROR_PLEASE_SPECIFY_DEFAULT_SORT_DIRECTION;
            }
            if (
                String.isBlank(requestWrapper.fieldSetName) &&
                String.isBlank(requestWrapper.sOQLSelectFieldsString)
            ) 
            {
                return System.Label.DYNLIST_ERROR_PLEASE_SPECIFY_EITHER_FIELD_SET_NAME_OR_SELECT_FIELDS;
            }
        }
        return null;
    }
}