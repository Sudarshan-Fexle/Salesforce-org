/*
    Purpose         :   Generic class to hold the lightning response details in form of an entity for uniformity everywhere.
    
    Created By      :   Abhinav Sharma
    
    Created Date    :   04/12/2019
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created
                        V_1.1 Modified By -Abhinav Sharma - 6/5/2020 -  CR-20200524-14104 - Access modifier based changes here for the @auraenabled properties
*/
public with sharing class LightningResponseEntity 
{
    
    public static final String SUCCESS = 'success';
    public static final String WARNING = 'warning';
    public static final String ERROR = 'error';
    
    @AuraEnabled public String status {get;set;}
    @AuraEnabled public Boolean isSuccess {get;set;}
    @AuraEnabled public String message {get;set;}
    @AuraEnabled public Object body {get;set;}
    
    public LightningResponseEntity() 
    {
        this.status = SUCCESS;
        this.isSuccess = true;
    }
    
    public static LightningResponseEntity create() 
    {
        return new LightningResponseEntity();
    }
    
    public static LightningResponseEntity create(Object body) 
    {
        return LightningResponseEntity.create().setBody(body);
    }
    
    public LightningResponseEntity setSuccess(Boolean isSuccess) 
    {
        this.status = isSuccess ? SUCCESS : ERROR;
        this.isSuccess = isSuccess;
        return this;
    }
    
    public LightningResponseEntity setError(String errorMessage) 
    {
        this.status = ERROR;
        this.isSuccess = false;
        return this.setMessage(errorMessage);
    }
    
    public LightningResponseEntity setWarning(String warningMessage) 
    {
        this.status = WARNING;
        return this.setMessage(warningMessage);
    }
    
    public LightningResponseEntity setMessage(String message) 
    {
        this.message = message;
        return this;
    }
    
    public LightningResponseEntity setBody(Object body) 
    {
        this.body = body;
        return this;
    }
    
    public static LightningResponseEntity success(Object body) 
    {
        return LightningResponseEntity.create(body);
    }
    
    public static LightningResponseEntity success(String successMessage) 
    {
        return LightningResponseEntity.create().setMessage(successMessage);
    }
    
    public static LightningResponseEntity success(Object body, String successMessage) 
    {
        return LightningResponseEntity.create(body).setMessage(successMessage);
    }
    
    public static LightningResponseEntity error(Object body) 
    {
        return LightningResponseEntity.create(body).setSuccess(false);
    }
    
    public static LightningResponseEntity error(String errorMessage) 
    {
        return LightningResponseEntity.create().setError(errorMessage);
    }
    
    public static LightningResponseEntity error(Object body, String errorMessage) 
    {
        return LightningResponseEntity.create(body).setError(errorMessage);
    }  
}