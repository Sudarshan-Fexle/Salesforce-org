/*
Purpose         :   Data Grid Request (Dynamic Related List)
Created By      :   Abhinav Sharma
Created Date    :   07/24/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 07/24/2021
*/
public without sharing class dynlistDataGridRequestWrapper 
{    
    public String view { get; set; }
    public Integer pageSize { get; set; }
    public String objectName { get; set; }
    public String fieldSetName { get; set; }
    public String sOQLSelectFieldsString { get; set; }
    public String whereClauseString { get; set; }
    public String groupByFieldName { get; set; }
    public String summarizeByFieldName { get; set; }
    public String defaultSortFieldName { get; set; }
    public String defaultSortDirection { get; set; }
    public String nullFirstOrLastString { get; set; }
    public Integer limitValue { get; set; }
    public Integer offSetValue { get; set; }
    public String correctContextRecordId {get; set;}
    public String searchByString { get; set; }
    public Boolean enforceWithSecurityMode { get; set; }
    public Boolean isColumnsAndFiltersSectionNeeded { get; set; }
    public String recordPageParentFieldAPIName { get; set; }
    public String recordPageParentObjectAPIName { get; set; }
    public String recordPageParentToParentFieldNameMappings { get; set; }
    public Boolean isSystemMode { get; set; }
}