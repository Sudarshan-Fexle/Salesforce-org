/*
Purpose         :   Options/Picklist Options (Dynamic Related List)
Created By      :   Abhinav Sharma
Created Date    :   07/24/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 07/24/2021
*/
public without sharing class dynlistOption 
{    
    @AuraEnabled
    public String label { get; set; }
    
    @AuraEnabled
    public String value { get; set; }
    
    public dynlistOption(String value, String label) 
    {
        this.value = value;
        this.label = label;
    }
}