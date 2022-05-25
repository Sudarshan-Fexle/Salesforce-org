/**
 *  Description     :  Helper class for the MembershipComp aura component
 *
 *	Revision Logs   :  V_1.0 - 09/20/2019 - Victor Hanson - Created
 *			   		   V_1.1 - 12/02/2019 - Victor Hanson - Modified - CR-20191111-13507 - changed TCV to Current CV
 * 			           V_1.2 - 23/10/2020 - Abhinav Sharma - Modified - CR-20201008-14592 - Update P360 Membership Logic
 * 			           V_1.3 - 14/04/2022 - Shalu Sharma - Modified - CR-20220215-15918 - Update Method i.e. getActiveMembershipWrapperList() for add Account_SL__c field
**/
public without sharing class MembershipCompExtension {
    
    //gray color used for unknown product types
    public static final String COLOR_CODE_GRAY = '#aeaeae';
    
    /**
     *  Description     :  return list of memberships
     * 
     *  @args           :   List<Id>
     * 
     *  @returns		:	List<Membership__c>
     *
     *	Revision Logs   :  09/20/2019 - Victor Hanson - Created
    **/
    @AuraEnabled
    public static List<Membership__c> getMemberships(List<Id> accountIds) {
        List<String> statusList = new List<String> { 'Prospect - Recent Drop', 'Prospect - Past Member' };
            return [SELECT Id, Name, Program_Acronym__c, Membership_Status__c, Program__r.Program_Formal_Name__c, End_Date_on_Last_Contract__c,
                    Renewal_Opp_Owner__c, Active_Contract_Negotiated_Amount__c, Join_Date_Earliest__c
                    FROM Membership__c
                    WHERE Account_Name__c IN :accountIds AND Membership_Status__c IN :statusList
                    ORDER BY Program__r.Program_Acronym__c ASC];
    }
    
    @AuraEnabled
    public static List<Account> getChildAccounts(List<Id> accountIds) {
        Map<Id, Account> childAcctMap = new Map<Id, Account>([SELECT Id FROM Account 
                                                              WHERE ParentId IN :accountIds
                                                              AND EAB_Relationship_Status_Text__c = :Constants.MEMBER]);
        return [SELECT Id, Account_Formal_Name__c,
                Active_PT_Memberships__c, Tech_Current_Period_Value_Rolled_Up__c, BI_Memberships__c,
               	Active_RI_Memberships__c, Research_Current_Period_Value_Rolled_Up__c,Core_Memberships__c,
               	Active_ES_Memberships__c, Enrollment_Contract_Value__c
               FROM Account WHERE Id IN :childAcctMap.keySet() ORDER BY Account_Formal_Name__c DESC];
    }
    
    /**
     *  Description     :  return list of memberships
     *
     *	Revision Logs   :  09/20/2019 - Victor Hanson - Created
    **/
    public static Map<String, Value_to_Color_Code__mdt> productFamilyValueToColorCodeMap {
        get {
            if (productFamilyValueToColorCodeMap == null) {
                productFamilyValueToColorCodeMap = ValueToColorHelper.getValueToColorCodeMap('Product2', 'Family');
                
            }
            return productFamilyValueToColorCodeMap;
        }
        set;
    }
    
    /**
     *  Description     :  return list of membership wrappers
     *
     *	Revision Logs   :  09/20/2019 - Victor Hanson - Created
    **/
    @AuraEnabled
    public static List<membershipFamilyWrapper> getActiveMembershipWrapperList(List<Id> accountIds) {
        
        //get map of all contracts with related documents
        Map<Id, ContentDocumentLink> contractIdToDocumentMap = new Map<Id, ContentDocumentLink>();
        for (Contract c : [SELECT Id, 
                           (SELECT Id,contentDocument.Title,contentDocument.LatestPublishedVersionId FROM ContentDocumentLinks WHERE ContentDocument.FileType = 'PDF' ORDER BY ContentDocument.CreatedDate DESC LIMIT 1) 
                           FROM Contract WHERE AccountId IN :accountIds]) 
        {
            //if there is a content document, add it to the map of ContractId -> ContentDocumentId
            if (c.ContentDocumentLinks != null && c.ContentDocumentLinks.size() > 0)
                contractIdToDocumentMap.put(c.Id, c.ContentDocumentLinks[0]);
        }
        
        //get royall programs
        Map<Id, Program_Package__c> programPkgMap = programPackageMap(accountIds[0]);
	    
        //Modified By - Shalu Sharma - 14/4/2022 - CR-20220215-15918 - Added Account_SL__c field in query 
        Map<String, membershipFamilyWrapper> membershipFamilyWrapperMap = new Map<String, membershipFamilyWrapper>();
        for (Membership__c mem : [SELECT Id, Name, Program__c, Program_Acronym__c, Program__r.Program_Formal_Name__c, Program__r.Program_Line__c,
                                  Membership_Status__c, Renewal_Opp_Owner__c,Join_Date_Earliest__c,End_Date_on_Last_Contract__c,
                                  Active_Contract_Negotiated_Amount__c, Most_Recent_QA_Call_Grade__c, Program__r.Product__r.Family,
                                  Current_Year_Program_Package__c, Current_Year_Program_Package__r.Total_Adjusted_Contracted_Cost__c,
                                  Active_Subscription__r.SBQQ__Contract__c, Current_Year_Program_Cost__c, Sum_Of_Current_Period_Fees__c, Account_SL__c, Account_SL__r.Name,
                                  (SELECT Id, Name, Fiscal_Year__c, Client_Status_New__c FROM Program_Packages_Royall_HD__r ORDER BY Fiscal_Year__c DESC),
                                  (SELECT Id, Name, SBQQ__ProductName__c, Status__c, Negotiated_Amount_Subscription__c, Customer_Amount__c, SBQQ__Contract__r.Negotiated_Amount_Contract__c 
                                   FROM Subscriptions__r
                                   WHERE SBQQ__Product__r.SBQQ__Component__c = true AND Active_Subscription__c = true
                                   ORDER BY SBQQ__ProductName__c DESC LIMIT 1)
                                  FROM Membership__c
                                  WHERE Account_Name__c IN :accountIds 
                                  AND Membership_Status__c LIKE 'Member%' 
                                  AND Program__r.Product__r.Family != 'Renewal Only'
                                  ORDER BY Program_Acronym__c ASC]) 
        {
            membershipFamilyWrapper familyWrapper = new membershipFamilyWrapper();
            
            //get product family
            String productFamily;
            productFamily = mem.Program__r.Product__r.Family;
            
            //Modified by - Abhinav Sharma - 23/10/2020 - CR-20201008-14592 - Update P360 Membership Logic - Start from here
            //only include certain product families
            /*if (productFamily == null || (!productFamily.contains('Tech') && !productFamily.contains('Research') && !productFamily.contains('Enrollment'))) {
                continue;
            }*/
            
            if (productFamily == null || (!productFamilyValueToColorCodeMap.containsKey(productFamily) )) {
                continue;
            }
            
            //Modified by - Abhinav Sharma - 23/10/2020 - CR-20201008-14592 - Update P360 Membership Logic - End here
            
            //get the colorCode based on product family
            familyWrapper.valueToColorCode = productFamilyValueToColorCodeMap.get(productFamily);
            
            //if blank, setup a default value with a gray color
            if (familyWrapper.valueToColorCode == null) {
                familyWrapper.valueToColorCode = new Value_to_Color_Code__mdt(Display_Value__c = productFamily, HTML_Color_Code__c = COLOR_CODE_GRAY);
            }
            
            familyWrapper.bgColor = familyWrapper.valueToColorCode.HTML_Color_Code__c;
            
            //if there is a display value, override the productFamily
            if (String.isNotBlank(familyWrapper.valueToColorCode.Display_Value__c)) {
                familyWrapper.productFamily = familyWrapper.valueToColorCode.Display_Value__c;
            }
            else {
                familyWrapper.productFamily = productFamily;
            }
            
            if (membershipFamilyWrapperMap.containsKey(familyWrapper.productFamily)) {
                familyWrapper = membershipFamilyWrapperMap.get(familyWrapper.productFamily);
            }
            
            //add to the membership count & total contract value that will be displayed in the header of active memberships section
            familyWrapper.membershipCount++;
            
            Decimal currentYearCV = mem.Sum_Of_Current_Period_Fees__c;
            
            //if this is an ES Product, get the contract value from the current year program package
            if ((currentYearCV == null || currentYearCV == 0) && mem.Current_Year_Program_Package__c != null && mem.Current_Year_Program_Package__r.Total_Adjusted_Contracted_Cost__c > 0) {
                currentYearCV = mem.Current_Year_Program_Package__r.Total_Adjusted_Contracted_Cost__c;
            }
            
            //add to the total contract value for the Product Family
            if (currentYearCV != null) {
                familyWrapper.currentYearCV += currentYearCV;
            }
            
            //create the membership wrapper
            membershipWrapper memWrapper = new membershipWrapper();
            memWrapper.membership = mem;
            
            //populate contract document with the latest document added on the Standard Contract
            if (mem.Active_Subscription__c != null && mem.Active_Subscription__r.SBQQ__Contract__c != null) {
                memWrapper.contractDocument = contractIdToDocumentMap.get(mem.Active_Subscription__r.SBQQ__Contract__c);
            }
            
            //populate membership wrapper with program packages, if applicable
            if (mem.Current_Year_Program_Package__c != null && programPkgMap.containsKey(mem.Current_Year_Program_Package__c)) {
                memWrapper.royallPrograms = programPkgMap.get(mem.Current_Year_Program_Package__c).Programs__r;
            }
            
            //add the membership wrapper to the list
            familyWrapper.memberships.add(memWrapper);
            
            membershipFamilyWrapperMap.put(familyWrapper.productFamily, familyWrapper);
        }
        return membershipFamilyWrapperMap.values();
        
    }
    
    //get all royall programs
    public static Map<Id, Program_Package__c> programPackageMap(Id acctId) {
        return new Map<Id, Program_Package__c>([SELECT Id, 
                                               (SELECT Id, Name, toLabel(Campaign_New__c), Campaign_SubType__c, Contact_Quantity__c, Program_Cost__c, Postage_Cost__c, Media_Cost__c, Contract_Signature_Date__c 
                                                FROM Programs__r ORDER BY Campaign_New__c ASC,Program_Cost__c DESC) 
                                               FROM Program_Package__c WHERE Membership__r.Account_Name__c = :acctId]);
    }
    
    /**
     *  Description     :  wrapper or Inner class with @AuraEnabled {get;set;} properties* 
     *
     *	Revision Logs   :  09/20/2019 - Victor Hanson - Created
    **/
    public class membershipFamilyWrapper {
        
        @AuraEnabled public String productFamily { get;set; }
        @AuraEnabled public String bgColor { get; set; }
        @AuraEnabled public Value_to_Color_Code__mdt valueToColorCode { get; set; }
        
        @AuraEnabled public List<membershipWrapper> memberships {
            get {
                if (memberships == null) memberships = new List<membershipWrapper>();
                return memberships;
            }
            set;
        }
        @AuraEnabled public Integer membershipCount {
            get {
                if (membershipCount == null) membershipCount = 0;
                return membershipCount;
            }
            set;
        }
        @AuraEnabled public Decimal currentYearCV {
            get {
                if (currentYearCV == null) currentYearCV = 0;
                return currentYearCV;
            }
            set;
        }
    }
    
    /**
     *  Description     :  wrapper class for membership
     *
     *	Revision Logs   :  09/20/2019 - Victor Hanson - Created
    **/
    public class membershipWrapper {
        
        @AuraEnabled public Membership__c membership { get; set; }
        @AuraEnabled public ContentDocumentLink contractDocument { get; set; }
        @AuraEnabled public List<Royall_Program__c> royallPrograms {
            get {
                if (royallPrograms == null) royallPrograms = new List<Royall_Program__c>();
                return royallPrograms;
            }
            set;
        }
    }
}