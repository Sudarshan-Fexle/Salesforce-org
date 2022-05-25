/*
 * Purpose		:	Trigger to populate Institution in Site Content Recommendation when insert
 * 
 * CreatedDate	:	21-10-2019
 * 
 * RevisionLog	:	V_1.0 - Created - Dipesh Gupta
*/
trigger SiteContentRecommendationTrigger on Site_Content_Recommendation__c (before insert, before update) 
{
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert || Trigger.isUpdate)
            SiteContentRecommendationTriggerHelper.updateInstitutionOnSiteContentRecommendation(Trigger.New, Trigger.OldMap);
    }
}