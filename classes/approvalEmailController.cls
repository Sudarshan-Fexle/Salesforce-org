/**
*   Description     :   Logic Controller which is used by the approvalDetailLevelLines component for the Approval Request Email
*                
*   Created by      :   Colin McGloin
*
*   Created Date    :   06/05/2017
*
*   Revision Log    :   V1.0 - Created - CR-20161124-10488
*		        V1.1 - Modified - 03/12/2019 - Victor Hanson - CR-20181019-12685 - added to SOQL query for use in the ApprovalDetailLevelLines component
*			V1.2 - Modified - 05/03/2021 - Subhash Garhwal - CR-20210421-15094 
*/

public with sharing class approvalEmailController {

	//Variables for records
	public Id quoteId {get; set;}
    	public Boolean ESAM_ESOAM_Without_NewPreInquiry {get; set;}
    	public Boolean ESAM_Without_NewPreInquiry {get; set;}
    	public Boolean ESOAM_Without_NewPreInquiry {get; set;}
    	public Boolean WebApplication_WithAny_NewPreInquiry {get; set;}
	public List <SBQQ__QuoteLine__c> associatedQuoteLines {get; set;}
    	public Set <String> setNewPreInquiryProductCodes = new Set<String>{'ESIPESOAM', 'ESPNESOAM', 'ESNNESOAM', 'ESIPESAM', 'ESPNESAM', 'ESNNESAM'};
    

	public approvalEmailController() {
		
	}

	/**
     * @description: Grabs the data needed for the approvalDetailLevelLines vf component used in Approval Request emails
     **/

	public List <SBQQ__QuoteLine__c> getQuoteLines () {

		if (associatedQuoteLines == null) {
			
            		ESAM_Without_NewPreInquiry = false;
            		ESOAM_Without_NewPreInquiry = false;
            		WebApplication_WithAny_NewPreInquiry = false;
            
			associatedQuoteLines = getQuoteLinesData();

		}

		return associatedQuoteLines;

	}

	public List <SBQQ__QuoteLine__c> getQuoteLinesData () {
		
        //Updated By Mahendra Swarnkar - 05/23/2019 - CR-20181019-12685 - Added "SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.Related_Product__c, SBQQ__TotalDiscountAmount__c" fields in the query.
	List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        
        //Added By Subhash Garhwal - CR-20210421-15094 - 05/03/2021 - Starts From here
        //Map Quotelines
        Map<Id, SBQQ__QuoteLine__c> mapQuotelines = new Map<Id, SBQQ__QuoteLine__c>();
        
        //Map Parent Lines with Child Lines i.e. (ESAM line Id with Inquiry Pool lines) OR (Inquiry Pool line Id with Program Cost lines) 
        Map<Id, List<SBQQ__QuoteLine__c>> mapParentLineIdWIthChildLines = new Map<Id, List<SBQQ__QuoteLine__c>>();
        
        for(SBQQ__QuoteLine__c qLine : [SELECT Id, Name, SBQQ__Product__c, Program_Name_Member_Facing__c, SBQQ__StartDate__c,
                                            SBQQ__EndDate__c, SBQQ__ListPrice__c, SBQQ__Uplift__c, Feature_Category__c,
                                            SBQQ__AdditionalDiscount__c, SBQQ__Quote__c, Related_Product__c, SBQQ__TotalDiscountRate__c,
                                            SBQQ__ProductName__c, Top_Parent_Product__r.Parent_Bundle_s__c, Is_This_A_Standalone_FAO_Client__c,
                                            Related_Product_with_Parent_Product__c, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.Related_Product__c, 
                                            SBQQ__TotalDiscountAmount__c, Is_Discount_On_YouVisit_Implementation__c, Is_Eligible_For_Approval__c,
                                            Web_Application_Versions_Other__c,Is_this_a_Mini_Virtual_Tour__c,SBQQ__ProductCode__c
					    FROM SBQQ__QuoteLine__c
                                            WHERE SBQQ__Quote__c = :quoteId 
                                            ORDER BY Sort__c ASC, Program_Name_Member_Facing__c ASC])
        {
	    quoteLines.add(qLine); 
            mapQuotelines.put(qLine.Id, qLine);
            
            if(qLine.SBQQ__RequiredBy__c != null) {
                if(!mapParentLineIdWIthChildLines.containsKey(qLine.SBQQ__RequiredBy__c))
                	mapParentLineIdWIthChildLines.put(qLine.SBQQ__RequiredBy__c, new List<SBQQ__QuoteLine__c>());
                mapParentLineIdWIthChildLines.get(qLine.SBQQ__RequiredBy__c).add(qLine);
            }
	}
        
        boolean iscontainsESAM = false;
        boolean iscontainsESOAM = false;
        boolean iscontainsESAMInquiryPreNew = false;
        boolean iscontainsESOAMInquiryPreNew = false;
        boolean iscontainsESWAP = false;
        
        for(SBQQ__QuoteLine__c quoteline: mapQuotelines.values()){
            
            if(mapParentLineIdWIthChildLines.size() > 0 
                && mapParentLineIdWIthChildLines.containsKey(quoteline.Id)
                && mapParentLineIdWIthChildLines.get(quoteline.Id) != null
               	&& mapParentLineIdWIthChildLines.get(quoteline.Id).size() > 0)
            {
                if(quoteline.SBQQ__ProductCode__c == 'ESAM')
                    iscontainsESAM = true;
                
                if(quoteline.SBQQ__ProductCode__c == 'ESOAM')
                    iscontainsESOAM = true;
                
                if(iscontainsESAM || iscontainsESOAM) {
                    
                    for(SBQQ__QuoteLine__c qline : mapParentLineIdWIthChildLines.get(quoteline.Id)){
                        
                        if(iscontainsESAM && setNewPreInquiryProductCodes.contains(qline.SBQQ__ProductCode__c))
                        	iscontainsESAMInquiryPreNew = true;
                        
                        if(iscontainsESOAM && setNewPreInquiryProductCodes.contains(qline.SBQQ__ProductCode__c))
                        	iscontainsESOAMInquiryPreNew = true;
                        
                        if(iscontainsESAM &&  qline.SBQQ__ProductCode__c == 'ESWAP')
                            iscontainsESWAP = true;
                    }
                }
            }
        }
        
        if(iscontainsESAM && !iscontainsESAMInquiryPreNew)
            ESAM_Without_NewPreInquiry = true;
        
        if(iscontainsESOAM && !iscontainsESOAMInquiryPreNew)
            ESOAM_Without_NewPreInquiry = true;
        
        if( iscontainsESWAP && (iscontainsESOAMInquiryPreNew))
            WebApplication_WithAny_NewPreInquiry = true;
        //Added By Subhash Garhwal - CR-20210421-15094 - 05/03/2021 - Ends here
        
        return quoteLines;
	}
}