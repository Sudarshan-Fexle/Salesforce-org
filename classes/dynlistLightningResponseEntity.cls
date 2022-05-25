public with sharing class dynlistLightningResponseEntity 
{
    public static final String SUCCESS = 'success';
    public static final String WARNING = 'warning';
    public static final String ERROR = 'error';
    
    @AuraEnabled public String status {get;set;}
    @AuraEnabled public Boolean isSuccess {get;set;}
    @AuraEnabled public String message {get;set;}
    @AuraEnabled public Object body {get;set;}
    
    public dynlistLightningResponseEntity() 
    {
        this.status = SUCCESS;
        this.isSuccess = true;
    }
    
    public static dynlistLightningResponseEntity create() 
    {
        return new dynlistLightningResponseEntity();
    }
    
    public static dynlistLightningResponseEntity create(Object body) 
    {
        return dynlistLightningResponseEntity.create().setBody(body);
    }
    
    public dynlistLightningResponseEntity setSuccess(Boolean isSuccess) 
    {
        this.status = isSuccess ? SUCCESS : ERROR;
        this.isSuccess = isSuccess;
        return this;
    }
    
    public dynlistLightningResponseEntity setError(String errorMessage) 
    {
        this.status = ERROR;
        this.isSuccess = false;
        return this.setMessage(errorMessage);
    }
    
    public dynlistLightningResponseEntity setWarning(String warningMessage) 
    {
        this.status = WARNING;
        return this.setMessage(warningMessage);
    }
    
    public dynlistLightningResponseEntity setMessage(String message) 
    {
        this.message = message;
        return this;
    }
    
    public dynlistLightningResponseEntity setBody(Object body) 
    {
        this.body = body;
        return this;
    }
    
    public static dynlistLightningResponseEntity success(Object body) 
    {
        return dynlistLightningResponseEntity.create(body);
    }
    
    public static dynlistLightningResponseEntity success(String successMessage) 
    {
        return dynlistLightningResponseEntity.create().setMessage(successMessage);
    }
    
    public static dynlistLightningResponseEntity success(Object body, String successMessage) 
    {
        return dynlistLightningResponseEntity.create(body).setMessage(successMessage);
    }
    
    public static dynlistLightningResponseEntity error(Object body) 
    {
        return dynlistLightningResponseEntity.create(body).setSuccess(false);
    }
    
    public static dynlistLightningResponseEntity error(String errorMessage) 
    {
        return dynlistLightningResponseEntity.create().setError(errorMessage);
    }
    
    public static dynlistLightningResponseEntity error(Object body, String errorMessage) 
    {
        return dynlistLightningResponseEntity.create(body).setError(errorMessage);
    }  
}