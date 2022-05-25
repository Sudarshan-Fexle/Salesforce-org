/**
 *  @description    :   Created to support the OpportunityFunnelChart VF Page
 * 
 *  @revision log	:	09/13/2019 - Victor Hanson - Created - CR-20181208-12776
 * 						12/09/2019 - Victor Hanson - Modified - CR-20191101-13490 - added next step date to query
 * 						12/30/2019 - Victor Hanson - CR-20191101-13490 - added getOppReportId
 * 
**/
public without sharing class OpportunityCompController {
	
    /**
     *  @description    :   get variables for funnel chart
     * 
     *  @args           :   void
     * 
     *  @return         :   String
     * 
     *  @revision log	:	09/13/2019 - Victor Hanson - Created
     * 
    **/ 
    @auraEnabled
    public static List<oppSummary> getOpportunitySummaries(List<Id> accountIds){
        List<oppSummary> myOppSummaries = new List<oppSummary>();
        
        ReportChartWrapper w = new ReportChartWrapper(Label.opportunityFunnelReportDevName, accountIds[0]);
        
        for (String key : w.keyToGroup.keySet()) {
            String label = w.keyToGroup.get(key).getLabel();
            Decimal amount = (Decimal)w.results.getFactMap().get(key + '!T').getAggregates()[0].getValue();
            Decimal quantity = (Decimal)w.results.getFactMap().get(key + '!T').getAggregates()[1].getValue();
            String color = ReportChartWrapper.oppStageToColorMap.get(label);
            myOppSummaries.add(new oppSummary(label, quantity, amount, color));
        }
        
        return myOppSummaries;
    }
    
    /**
     *  @description    :   class to hold each data point
     * 
     *  @revision log	:	12/30/2019 - CR-20191101-13490 - Victor Hanson - Created so we can add a link to the report within the component
     * 
    **/
    @auraEnabled
    public static String getOppReportId() {
        // Get the report ID
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report where 
                                    DeveloperName = :Label.opportunityFunnelReportDevName];
        String reportId;
        if (reportList.size() > 0) reportId = reportList[0].Id;
        return reportId;
    }
    
    /**
     *  @description    :   class to hold each data point
     * 
     *  @revision log	:	09/13/2019 - Victor Hanson - Created
     * 
    **/
    public class oppSummary {
        
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public Decimal quantity { get; set; }
        @AuraEnabled public Decimal amount { get; set; }
        @AuraEnabled public String bgColor { get; set; }
        
        oppSummary(String label, Decimal quantity, Decimal amount, String bgColor) {
            this.label = label;
            this.quantity = quantity;
            this.amount = amount;
            
            //default background color if no color is specified
            if (bgColor == '' || bgColor == null) this.bgColor = '#b5b5b5';
            else this.bgColor = bgColor;
        }
    }
    
    /**
     *  @description    :   get open opportunities for accounts
     * 
     *  @args           :   List<Id>
     * 
     *  @return         :   List<opportunityWrapper>
     * 
     *  @revision log	:	09/13/2019 - Victor Hanson - Created
     * 
    **/
    @AuraEnabled
    public static List<opportunityWrapper> getOpenOpps(List<Id> accountIds) {
        List<opportunityWrapper> oppWrappers = new List<opportunityWrapper>();
        for (Opportunity o : [SELECT Id, Opp_Programs__c, StageName, CloseDate, Amount, Owner.Name, 
                SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__r.Name, RecordType.Name,
                Probability, Next_Step_Date__c,
                (select Id, CreatedDate, Field, CreatedBy.Name, OldValue, NewValue from Histories WHERE Field = 'Probability' ORDER BY CreatedDate DESC LIMIT 1)
                FROM Opportunity
                WHERE AccountId IN :accountIds 
                    AND CloseDate >= TODAY
                    AND CloseDate <= NEXT_N_DAYS:365
                    AND ISClosed = false
                ORDER BY CloseDate ASC]) 
        {
            OpportunityWrapper oWrapper = new OpportunityWrapper();
            oWrapper.opp = o;
            oWrapper.productNames = '';
            
            //get the full name of each product so we can add it to card
            if (o.Opp_Programs__c != null) {
                List<String> acronyms = o.Opp_Programs__c.split(';');
                for (String acronym : acronyms) {
                    //get the full product name based on the acronym
                    String productName = acronymToNameMap.get(acronym);
                    if (productName != null) {
                        if (oWrapper.productNames != '') oWrapper.productNames += '; ';
                        oWrapper.productNames += productName;
                    }
                }
            }
            
            oppWrappers.add(oWrapper);
        }
        
        return oppWrappers;
    }
    
    // opportunity wrapper
    public class opportunityWrapper {
        @AuraEnabled public Opportunity opp { get; set; }
        @AuraEnabled public String productNames { get; set; }
    }
    
    //TODO: add this to system cache
    /**
     *  @description    :   returns program acronym to name map
     * 
     *  @return         :   Map<String, String>
     * 
     *  @revision log	:	09/13/2019 - Victor Hanson - Created
     * 
    **/
    public static Map<String, String> acronymToNameMap {
        get {
            if (acronymToNameMap == null) {
                acronymToNameMap = new Map<String, String>();
                for (Product2 p : [SELECT Id, ProductCode, Name FROM Product2 WHERE IsActive = true AND SBQQ__Component__c = false]) {
                    acronymToNameMap.put(p.ProductCode, p.Name);
                }
            }
            return acronymToNameMap;
        }
        set;
    }
}