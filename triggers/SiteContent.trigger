/**
 *   Purpose:    Trigger to support Site Content object logic
 *   
 *   Revision Log:      v1.00 - 07/30/2019 - CR-20190510-13101 - Victor Hanson - Created
 * 
**/
trigger SiteContent on Site_Content__c (after insert, after update) {

    if (trigger.isAfter) {
        
        SiteContentHelper.updateSiteContentMtM(Trigger.new, Trigger.oldMap);
    }
}