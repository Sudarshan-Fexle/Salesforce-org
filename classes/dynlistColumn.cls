/*
Purpose         :   Column (Dynamic Related List)
Created By      :   Abhinav Sharma
Created Date    :   07/24/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 07/24/2021
*/
public without sharing class dynlistColumn implements Comparable 
{    
    @AuraEnabled
    public String label { get; set; }
    
    @AuraEnabled
    public String name { get; set; }
    
    @AuraEnabled
    public String value { get; set; }
    
    @AuraEnabled
    public Boolean isDropEnabled { get; set; }
    
    @AuraEnabled
    public Decimal summarizedAmount { get; set; }
    
    @AuraEnabled
    public Decimal totalRecordsCount { get; set; }
    
    @AuraEnabled
    public Boolean isSortable { get; set; }
    
    @AuraEnabled
    public Boolean displaySortingIcon { get; set; }
    
    @AuraEnabled
    public Boolean displayArrowUpIcon { get; set; }
    
    @AuraEnabled
    public Boolean displayArrowDownIcon { get; set; }
    
    // Implement the compareTo() method
    public Integer compareTo(Object compareTo) 
    {
        dynlistColumn compareToEmp = (dynlistColumn) compareTo;
        if (label == compareToEmp.label)
            return 0;
        if (label > compareToEmp.label)
            return 1;
        return -1;
    }
}