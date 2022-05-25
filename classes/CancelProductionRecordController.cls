/**
*	Description     :   Cancel Production Tracking controller class
* 
*	Created By      :   Nikita Kuamri    
* 
*	Created Date    :   09/07/2021
* 
*	Revision Logs   :   V_1.0 - Created By - Nikita Kumari - 09/07/2021 - CR-20210825-15380 
*                       
**/  
public with sharing class CancelProductionRecordController {
    
    /**
    *	Description     :   This method is used to get Cancellation Reason Picklist values 
    *	Revision Logs   :   V_1.0 - Created - Nikita Kumari - 09/07/2021 - CR-20210825-15380
    *                       
    **/ 
    @AuraEnabled(cacheable=true)
    public static LightningResponseEntity getCancellationReasonPicklistValues() {

        //To hold data and message to display on screen
        LightningResponseEntity res = new LightningResponseEntity();
        try
        {
            //to hold all picklist values in label and value combo
            List<cancellationResonsOptionWrap> cancellationResonsOptionWrap = new List<cancellationResonsOptionWrap>();
            
            //get picklist field described result
            Schema.DescribeFieldResult fieldResult = Production_Tracking__c.Cancellation_Reason__c.getDescribe();
            //loop over all picklist entries
            for(Schema.PicklistEntry f : fieldResult.getPicklistValues())
            {
                cancellationResonsOptionWrap resonOpt = new cancellationResonsOptionWrap(f.getLabel(), f.getValue());
                cancellationResonsOptionWrap.add(resonOpt);
            }

            //set response body
            res.setBody(cancellationResonsOptionWrap);
        }   
        catch(Exception e)
        {
            //set error in response
            res.setError('Error occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n');   
        }
        return res;
    }

    /**
    *	Description     :   This method is used to Cancel Production Tracking once user confirmed
    *	Revision Logs   :   V_1.0 - Created - Nikita Kumari - 09/07/2021 - CR-20210825-15380
    *                       
    **/ 
    @AuraEnabled
    public static LightningResponseEntity cancelProductionTracking(Id recordId, String status, String cancellationReason) {
        
        //To hold data and message to display on screen
        LightningResponseEntity res = new LightningResponseEntity();
        
        try
        {
            //check the values shoudn't be null
            if(String.isNotBlank(status) && recordId != null){

                //set values
                Production_Tracking__c updatePTRecord = new Production_Tracking__c(Id = recordId, Status__c = status, Cancellation_Reason__c = cancellationReason);
                
                //bypass all triggers before dml
                util.bypassAllTriggers = true;
                Update updatePTRecord;
                util.bypassAllTriggers = false;
            }
           
            //set response
            res.setSuccess(true);
        } 
        catch(DmlException e){

            //to hold error message
            String errorMessage = e.getMessage();
            List<String> splittedByValidationExceptions = new List<String>();

            //to get custom validation rule exception
            if(errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
            {
                splittedByValidationExceptions = errorMessage.split('FIELD_CUSTOM_VALIDATION_EXCEPTION');
                errorMessage = errorMessage.split('FIELD_CUSTOM_VALIDATION_EXCEPTION')[splittedByValidationExceptions.size() - 1];
                errorMessage = errorMessage.removeStart(',').removeEnd('[]').trim();
                errorMessage = errorMessage.replace('&quot;', '"');
                errorMessage = errorMessage.replace(':', '');
            }

            //throw DML exception message
            res.setError(errorMessage);
             
        }  
        catch(Exception e)
        {
            //throw error
            res.setError(' Error occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n');   
        }

        return res;
        
    }

    /**
    *	Description     :   This wrapper is used to set Cancellation Reason Picklist values 
    *                       
    **/ 
    public class cancellationResonsOptionWrap{

        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}

        public cancellationResonsOptionWrap(String label, String value){
            this.label = label;
            this.value = value;
        }
    } 
}