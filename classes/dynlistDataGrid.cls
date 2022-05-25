/*
Purpose         :   Data Grid (Dynamic Related List)
Created By      :   Abhinav Sharma
Created Date    :   07/24/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 07/24/2021
*/
public without sharing class dynlistDataGrid 
{    
    @AuraEnabled
    public String view { get; set; }
    
    @AuraEnabled
    public Integer pageSize { get; set; }
    
    @AuraEnabled
    public List<dynlistRow> rows { get; set; }
    
    @AuraEnabled
    public String status { get; set; }
    
    @AuraEnabled
    public Boolean isSuccess { get; set; }
    
    @AuraEnabled
    public List<String> messages { get; set; }
    
    @AuraEnabled
    public Map<String, List<dynlistRow>> kanbanRows { get; set; }
    
    @AuraEnabled
    public List<dynlistColumn> columns { get; set; }
    
    @AuraEnabled
    public Boolean viewable { get; set; }
    
    @AuraEnabled
    public Object body { get; set; }
    
    @AuraEnabled
    public Boolean isAllFieldsInAccessible { get; set; }
    
    @AuraEnabled
    public Boolean isObjAccessible { get; set; }
    
    @AuraEnabled
    public Boolean isObjUpdatable { get; set; }
    
    @AuraEnabled
    public Boolean isObjDeletable { get; set; }
    
    @AuraEnabled
    public Boolean isObjCreatable { get; set; }
    
    @AuraEnabled
    public Boolean isUndeletable { get; set; }
    
    @AuraEnabled
    public Boolean isCustom { get; set; }
    
    @AuraEnabled
    public String nameSynonymFieldName { get; set; }
    
    @AuraEnabled
    public Boolean specialObjStandardNewNotAllowed { get; set; }
    
    @AuraEnabled
    public Boolean specialObjStandardEditNotAllowed { get; set; }
    
    @AuraEnabled
    public Boolean specialObjStandardDeleteNotAllowed { get; set; }
    
    @AuraEnabled
    public List<dynlistColumn> allColumns { get; set; }
    
    public dynlistDataGrid(List<String> errorMessages) 
    {
        messages = new List<String>();
        messages = errorMessages;
        rows = new List<dynlistRow>();
        kanbanRows = new Map<String, List<dynlistRow>>();
        columns = new List<dynlistColumn>();
        allColumns = new List<dynlistColumn>();
        isAllFieldsInAccessible = false;
        specialObjStandardNewNotAllowed = false;
        specialObjStandardEditNotAllowed = false;
        specialObjStandardDeleteNotAllowed = false;
    }
    
    public dynlistDataGrid() 
    {
        this.status = dynlistConstants.SUCCESS;
        this.isSuccess = true;
        messages = new List<String>();
        rows = new List<dynlistRow>();
        kanbanRows = new Map<String, List<dynlistRow>>();
        isAllFieldsInAccessible = true;
        specialObjStandardNewNotAllowed = false;
        specialObjStandardEditNotAllowed = false;
        specialObjStandardDeleteNotAllowed = false;
    }
    
    public static dynlistDataGrid create() 
    {
        return new dynlistDataGrid();
    }
    
    public static dynlistDataGrid create(Object body) 
    {
        return dynlistDataGrid.create().setBody(body);
    }
    
    public dynlistDataGrid setSuccess(Boolean isSuccess) 
    {
        this.status = isSuccess ? dynlistConstants.SUCCESS : dynlistConstants.ERROR;
        this.isSuccess = isSuccess;
        return this;
    }
    
    public dynlistDataGrid setError(String errorMessage) 
    {
        this.status = dynlistConstants.ERROR;
        this.isSuccess = false;
        return this.setMessage(errorMessage);
    }
    
    public dynlistDataGrid setWarning(String warningMessage) 
    {
        this.status = dynlistConstants.WARNING;
        return this.setMessage(warningMessage);
    }
    
    public dynlistDataGrid setMessage(String message) 
    {
        this.messages.add(message);
        return this;
    }
    
    public dynlistDataGrid setBody(Object body) 
    {
        this.body = body;
        return this;
    }
    
    public static dynlistDataGrid success(Object body) 
    {
        return dynlistDataGrid.create(body);
    }
    
    public static dynlistDataGrid success(String successMessage) 
    {
        return dynlistDataGrid.create().setMessage(successMessage);
    }
    
    public static dynlistDataGrid success(Object body, String successMessage) 
    {
        return dynlistDataGrid.create(body).setMessage(successMessage);
    }
    
    public static dynlistDataGrid error(Object body) 
    {
        return dynlistDataGrid.create(body).setSuccess(false);
    }
    
    public static dynlistDataGrid error(String errorMessage) 
    {
        return dynlistDataGrid.create().setError(errorMessage);
    }
    
    public static dynlistDataGrid error(Object body, String errorMessage) 
    {
        return dynlistDataGrid.create(body).setError(errorMessage);
    }
}