public with sharing class JobNumberSearchController {
    
    @AuraEnabled(cacheable=true)
    public static List<JobNoWrapper> retrievejobNumberSearch(String searchString){
        
        List<JobNoWrapper> jobNoWrapperList = new List<JobNoWrapper>();
        if(String.isNotBlank(searchString)){
            searchString = searchString.trim();
            String srchstring = '%'+searchString+'%';
            
            JobNoWrapper wrap = new JobNoWrapper();
            List<Royall_Program__c> royallprgmList = [select Name,Program_Package__r.Membership__r.Program__r.Product__r.Name,Program_Package__c,Program_Package__r.Account__c,Program_Package__r.Account__r.Name, Fiscal_Year__c FROM Royall_Program__c 
                                                       WHERE Name Like : srchstring OR (Program_Package__r.Account__r.Name Like : srchstring and Name != null)];
            if(royallprgmList.size () > 0){			
            	wrap.programList = royallprgmList;
            }

			 List<SBQQ__QuoteLine__c>  quoteLineList = [Select Name,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__Account__c,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Product__r.Name,SBQQ__Product__c,Job_No__c,Fiscal_Year__c FROM SBQQ__QuoteLine__c 
															WHERE Job_No__c Like : srchstring Or (SBQQ__Quote__r.SBQQ__Account__r.Name Like : srchstring AND Job_No__c != null)];
					if(quoteLineList.size () > 0){
						wrap.quoteLineList = quoteLineList;
                    }
            
            List<Subscription_Period__c>  subscriptionPeriodList = [Select Name,Program_Subscription__r.SBQQ__Product__r.Name,Program_Subscription__c,Program_Subscription__r.SBQQ__Product__c,Institution__c,Institution__r.Name,Job_No__c FROM Subscription_Period__c 
                                                                    WHERE Job_No__c Like : srchstring OR (Institution__r.Name Like : srchstring AND Job_No__c != null)] ;
            if(subscriptionPeriodList.size () > 0){
            wrap.subscriptionPeriodList = subscriptionPeriodList;
            }
            
             List<Job_Ticket__c>  jobTicketList = [Select Name,Program__c,Program__r.Product__c,Program__r.Product__r.Name,Mail_Vendor__c,Mail_Vendor__r.Name,Job_Code__c,Fiscal_Year__c FROM Job_Ticket__c 
                                                                    WHERE Job_Code__c Like : srchstring OR (Mail_Vendor__r.Name Like : srchstring AND Job_Code__c != null)] ;
            if(jobTicketList.size () > 0){
            wrap.jobTicketList = jobTicketList;
            }
            
            if(quoteLineList.size() > 0 || jobTicketList.size() > 0 || royallprgmList.size() > 0 || subscriptionPeriodList.size() > 0){
            	jobNoWrapperList.add(wrap);
            }
        }
        return jobNoWrapperList;
    }
    
    public class JobNoWrapper{
        @AuraEnabled  public List<Royall_Program__c> programList {get;set;}
        @AuraEnabled  public List<SBQQ__QuoteLine__c> quoteLineList {get;set;}
        @AuraEnabled  public List<Subscription_Period__c> subscriptionPeriodList {get;set;}
        @AuraEnabled  public List<Job_Ticket__c> jobTicketList {get;set;} 
    }
}