/*
Purpose         :   Data Grid Query Wrapper class (Dynamic Related List)
Created By      :   Abhinav Sharma
Created Date    :   08/16/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 08/16/2021
*/
public without sharing class dynlistQueryWrapper 
{
    @AuraEnabled
    public String queryString { get; set; }
    
    @AuraEnabled
    public Boolean isAllFieldsInAccessible { get; set; }
    
    @AuraEnabled
    public Set<String> setOfNonQueryableFields { get; set; }
    
    @AuraEnabled
    public String selectQueryForInAccessibilityCheck { get; set; }
}