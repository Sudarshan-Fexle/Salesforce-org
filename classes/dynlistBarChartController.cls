/*
Purpose         :   Bar Chart Controller Class (Dynamic Related List)
Created By      :   Abhinav Sharma
Created Date    :   11/09/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 11/09/2021
*/
public without sharing class dynlistBarChartController 
{
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getOpportunities(String selectedRecordsIds)
    {
        if(String.isNotBlank(selectedRecordsIds)) 
        {
            Set<String> setOfOpportunityRecordsIds = new Set<String>();
            for(String selectedOppId : selectedRecordsIds.split(dynlistConstants.CHAR_COMMA)) 
            {
                setOfOpportunityRecordsIds.add(selectedOppId);    
            }
            if(setOfOpportunityRecordsIds.size() > 0) 
            {
                return [SELECT SUM(ExpectedRevenue) expectRevenue, SUM(Amount) amount, StageName stage 
                        FROM Opportunity 
                        WHERE ID IN : setOfOpportunityRecordsIds 
                        GROUP BY StageName];    
            }
        }
        return null;
    }
}