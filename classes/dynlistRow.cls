/*
Purpose         :   Row (Dynamic Related List)
Created By      :   Abhinav Sharma
Created Date    :   07/24/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 07/24/2021
*/
public without sharing class dynlistRow 
{    
    @AuraEnabled
    public String recId { get; set; }
    
    @AuraEnabled
    public String title { get; set; }
    
    @AuraEnabled
    public Integer rowNumber { get; set; }
    
    @AuraEnabled
    public Boolean selected { get; set; }
    
    @AuraEnabled
    public Boolean isAlreadyProcessed { get; set; }
    
    @AuraEnabled
    public Boolean editMode { get; set; }
    
    @AuraEnabled
    public Boolean needToRemovedExplicitly { get; set; }
    
    @AuraEnabled
    public List<dynlistField> fields { get; set; }
    
    @AuraEnabled
    public String groupByFieldValue { get; set; }
    
    @AuraEnabled
    public String summarizeByFieldValue { get; set; }
    
    @AuraEnabled
    public String errorMessageForRow { get; set; }
    
    public dynlistRow() 
    {
        this.title = dynlistConstants.CHAR_BLANK_STRING;
        this.selected = false;
        this.editMode = false;
        this.fields = new List<dynlistField>();
        this.isAlreadyProcessed = false;
        this.needToRemovedExplicitly = false;
    }
    
    public dynlistRow(String recId, Integer rowNo) 
    {
        this.recId = recId;
        this.title = dynlistConstants.CHAR_BLANK_STRING;
        this.rowNumber = rowNumber;
        this.selected = false;
        this.editMode = false;
        this.fields = new List<dynlistField>();
        this.isAlreadyProcessed = false;
        this.needToRemovedExplicitly = false;
    }
    
    public dynlistRow(String recId, Integer rowNo, String errorMessageForRow) 
    {
        this.recId = recId;
        this.title = dynlistConstants.CHAR_BLANK_STRING;
        this.rowNumber = rowNumber;
        this.selected = false;
        this.editMode = false;
        this.fields = new List<dynlistField>();
        this.errorMessageForRow = errorMessageForRow; 
        this.isAlreadyProcessed = false;
        this.needToRemovedExplicitly = false;
    }
}