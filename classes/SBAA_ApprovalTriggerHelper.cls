/**
*   Description     :   Helper class for the SBAA_Approval trigger
*                
*   Created by      :   Victor Hanson
*
*   Created Date    :   08/04/2017
*
*   Revision Log    :   V1.0 - Created - Issue--CR10808--QA--00004965
*/
public class SBAA_ApprovalTriggerHelper {
	
    public static final set<String> APPROVAL_CLOSED_STATUS_VALUES = new set<String>{'Approved','Rejected'};
    
    /**
     * @description		: 	populate the Pending Approver field based on any open approvals on the related quote
     *
     *  @args           :   map<Id, sbaa__Approval__c>, map<Id, sbaa__Approval__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.0 - Created - 08/04/2017 - Victor Hanson - Issue--CR10808--QA--00004965
     * 
     **/
    public static void setApprovalFields(map<Id, sbaa__Approval__c> mapApprovals, map<Id, sbaa__Approval__c> mapOldApprovals) {
        
        set<Id> approvedQuoteIds = new set<Id>();
        
        //get all newly approved quotes
        for (sbaa__Approval__c a : mapApprovals.values()) {
            
            if (a.Quote__c != null 
                && mapOldApprovals != null 
                && mapOldApprovals.get(a.Id).SBAA__Status__c != a.SBAA__Status__c 
                && a.sbaa__Status__c == 'Approved') {
                    
                    approvedQuoteIds.add(a.Quote__c);
                }
        }
        
        //create a map of QuoteID -> Open Approval so we can populate the remaining approver's name
        map<Id, SBAA__Approval__c> mapQuoteIdToOpenApproval = new map<Id, SBAA__Approval__c>();
        
        if (approvedQuoteIds.size() > 0) {
            
            //get the quotes that still need approval
            for (SBQQ__Quote__c q : [SELECT Id, 
                                     (
                                         SELECT Id, SBAA__Approver__r.Name 
                                         FROM Approvals__r 
                                         WHERE SBAA__Status__c NOT IN :APPROVAL_CLOSED_STATUS_VALUES
                                         AND Id NOT IN :Trigger.newMap.keySet()
                                     )
                                     FROM SBQQ__Quote__c 
                                     WHERE Id IN :approvedQuoteIds
                                     AND Id IN (SELECT Quote__c FROM SBAA__Approval__c)])
            {
                
                if (q.Approvals__r.size() > 0) {
                    
                    //add the quoteId -> Approval to our map
                    mapQuoteIdToOpenApproval.put(q.Id, q.Approvals__r[0]);
                }
            }
            
            
            
            //set the pending approver field so we can use this field in our email template
            for (sbaa__Approval__c a : mapApprovals.values()) {
                
                if (mapQuoteIdToOpenApproval.containsKey(a.Quote__c)) {
                    
                    a.Pending_Approver__c = mapQuoteIdToOpenApproval.get(a.Quote__c).SBAA__Approver__r.Name;
                }
            }
        }
    }
    
}