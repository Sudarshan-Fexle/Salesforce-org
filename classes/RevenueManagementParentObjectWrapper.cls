/**
 *  Purpose            :    This class is to hold parent object details in form of a wrapper that will be utilized on Revenue Management Page.  
 *
 *  Created By         :    Abhinav Sharma
 *
 *  Created Date       :    06/13/2017
 *
 *  Revision Log       :    V_1.0 - Created - Revenue Management Phase 2
**/
public class RevenueManagementParentObjectWrapper {
    
    //properties to hold the parent object name and ID value
    public String parentObjectName {get; set;}
    public ID parentRecordID {get; set;}
    
    //parent record name variable
    public String parentRecordName {get; set;}
    
    //Properties to hold the payer account name and ID value
    public String payerAccountID {get; set;}
    public String payerAccountName {get; set;}
    
    //properties to hold the start date and end date
    public Date startDate {get; set;}
    public Date endDate {get; set;}
    
    //properties to hold the program ID and program name
    public String programID {get; set;}
    public String programName {get; set;}    
    
    //Recognized to Date Negotiated field variable
    public Decimal recognizedToDateNegotiated {get; set;}
    
    //Recognized to Date GAAP
    public Decimal recognizedToDateGAAP {get; set;}
    
    //variable to hold the term type
    public String termType {get; set;}
    
    //Variable to hold the negotiatedAmount
    public Decimal negotiatedAmount {get; set;}
    
    //Adjusted Accounting Contract Value
    public Decimal adjustedAccountingContractValue {get; set;}
    
    //Gaap Negotiated Postage cost
    public Decimal gaapNegoPostageCost {get; set;}
    
    //Gaap Negotiated Media cost
    public Decimal gaapNegoMediaCost {get; set;}
    
    //Setup in negotiated
    public Integer setupInNegotiated {get; set;}
    
    //Map to hold the fields mapping
    public Map<Integer, String> mapOfFieldsMappingWithIndex {get; set;}
    
    //Contract ABC instance
    public Contract__c contractABC {get; set;}
    
    //CPQ Subscription
    public SBQQ__Subscription__c sBQQSubcription {get; set;}
    
    //Standard Contract
    Public Contract standardCon {get; set;}
    
    //Boolean to check if the process is initiated from Standard contract page. 
    Public boolean isStandardContract {get; set;}

    //Constructor
    public RevenueManagementParentObjectWrapper(Map<Integer, String> mapOfFieldsMappingWithIndex, String parentObjectName, ID parentRecordID, Map<String, String> mapObjectAPINameWithSOQL) {
        
        //Checking for the null/blank value
        if(String.isNotBlank(parentObjectName) 
            && parentRecordID != null
            && mapOfFieldsMappingWithIndex != null
            && mapOfFieldsMappingWithIndex.values().size() > 0
        ) {
            
            this.mapOfFieldsMappingWithIndex = mapOfFieldsMappingWithIndex;
            this.parentObjectName = parentObjectName;
            this.parentRecordID = parentRecordID;
            
            //list of parent objects
            List<Contract__c> contractABCs = new List<Contract__c>();
            List<SBQQ__Subscription__c> cPQSubscriptions = new List<SBQQ__Subscription__c>();
        	List<Contract> standardContracts = new List<Contract>();
            
            //String literal to hold the query
            String sOQLQuery = '';
            
            //list to hold the fields API Name
            List<String> fieldsAPINames = new List<String>();
            
            //Boolean initialisation.
            isStandardContract = false;
            
            //Loop throgh map and populating collection with the values
            for(Integer inx : mapOfFieldsMappingWithIndex.keySet())
                fieldsAPINames.add(mapOfFieldsMappingWithIndex.get(inx));
            
            //Checking if the parent object is "Contract ABC"
            if(parentObjectName.equalsIgnoreCase(RMConstants.CONTRACT_ABC_OBJ_API_NAME) && fieldsAPINames.size() > 0) {
                
                //Checking for SOQL String literal in the map
                if(mapObjectAPINameWithSOQL.containsKey(RMConstants.CONTRACT_ABC_OBJ_API_NAME_LOWERCASE)
                    && mapObjectAPINameWithSOQL.get(RMConstants.CONTRACT_ABC_OBJ_API_NAME_LOWERCASE) != null  
                ) {
                    sOQLQuery = mapObjectAPINameWithSOQL.get(RMConstants.CONTRACT_ABC_OBJ_API_NAME_LOWERCASE) + ' :parentRecordID';
                    contractABCs = Database.query(sOQLQuery);
                } else {
                    
                    //Querying for the contract ABC details
                    sOQLQuery = 'SELECT ID, ' + String.join(fieldsAPINames, ', ') + ' FROM Contract__c WHERE Id = :parentRecordID';
                    contractABCs = Database.query(sOQLQuery);
                }
                
            } else if(parentObjectName.equalsIgnoreCase(RMConstants.CPQ_SUBSCRIPTION_OBJ_API_NAME) && fieldsAPINames.size() > 0) {
                
                //Checking for SOQL String literal in the map
                if(mapObjectAPINameWithSOQL.containsKey(RMConstants.CPQ_SUBSCRIPTION_OBJ_API_NAME_LOWERCASE)
                    && mapObjectAPINameWithSOQL.get(RMConstants.CPQ_SUBSCRIPTION_OBJ_API_NAME_LOWERCASE) != null  
                ) {
                    sOQLQuery = mapObjectAPINameWithSOQL.get(RMConstants.CPQ_SUBSCRIPTION_OBJ_API_NAME_LOWERCASE) + ' :parentRecordID';
                    cPQSubscriptions = Database.query(sOQLQuery);
                } else {
                    //Querying for the subscription details
                    sOQLQuery = 'SELECT ID, ' + String.join(fieldsAPINames, ', ') + ' FROM SBQQ__Subscription__c WHERE Id = :parentRecordID';
                    cPQSubscriptions = Database.query(sOQLQuery);        
                }
            } else if(parentObjectName.equalsIgnoreCase(RMConstants.STANDARD_Contract_OBJ_API_NAME) && fieldsAPINames.size() > 0) {
            
            	 //Checking for SOQL String literal in the map
                if(mapObjectAPINameWithSOQL.containsKey(RMConstants.STANDARD_Contract_OBJ_API_NAME_LOWERCASE)
                    && mapObjectAPINameWithSOQL.get(RMConstants.STANDARD_Contract_OBJ_API_NAME_LOWERCASE) != null  
                ) {
                    sOQLQuery = mapObjectAPINameWithSOQL.get(RMConstants.STANDARD_Contract_OBJ_API_NAME_LOWERCASE) + ' :parentRecordID';
                    standardContracts = Database.query(sOQLQuery);
                } else {
                    //Querying for the subscription details
                    sOQLQuery = 'SELECT ID, ' + String.join(fieldsAPINames, ', ') + ' FROM Contract WHERE Id = :parentRecordID';
                    standardContracts = Database.query(sOQLQuery);        
                }
            }
            
            //Checking list for its size
            if(contractABCs.size() > 0) {
                
                //Integer to hold the total properties count
                Integer totalPropertiesCount = 11;
            
                //Sobject instance
                sObject sObjContractABC = (sObject)contractABCs[0];
                contractABC = contractABCs[0];
                
                //Loop through total properties counts
                for(Integer i = 1; i <= totalPropertiesCount; i++) {
                    
                    //Checking for the index number in the map and populating wrapper properties accordingly
                    if(mapOfFieldsMappingWithIndex.containsKey(i)) {
                        
                        //CHecking for integer current value and accordingly setting wrapper properties
                        if(i == 1) {
                            payerAccountID = String.valueOf(sObjContractABC.get(mapOfFieldsMappingWithIndex.get(i)));
                            
                            //Looping through account records and get the name related details
                            for(Account acc : [SELECT ID, Name 
                                                FROM Account 
                                                WHERE ID =: payerAccountID])
                                payerAccountName = acc.Name;
                        }
                            
                        if(i == 2)
                            startDate = Date.valueOf(sObjContractABC.get(mapOfFieldsMappingWithIndex.get(i)));
                        
                        if(i == 3)
                            endDate = Date.valueOf(sObjContractABC.get(mapOfFieldsMappingWithIndex.get(i)));
                        
                        if(i == 4) {
                            programID = String.valueOf(sObjContractABC.get(mapOfFieldsMappingWithIndex.get(i)));
                            
                            //Looping through account records and get the name related details
                            for(Program__c prog : [SELECT ID, Name 
                                                    FROM Program__c 
                                                    WHERE ID =: programID])
                                programName = prog.Name;
                        }
                            
                        if(i == 5)
                            recognizedToDateNegotiated = (Decimal)(sObjContractABC.get(mapOfFieldsMappingWithIndex.get(i)));
                        
                        if(i == 6)
                            parentRecordName = String.valueOf(sObjContractABC.get(mapOfFieldsMappingWithIndex.get(i)));
                        
                        if(i == 7)
                            termType = String.valueOf(sObjContractABC.get(mapOfFieldsMappingWithIndex.get(i)));
                        
                        if(i == 8)
                            recognizedToDateGAAP = (Decimal)(sObjContractABC.get(mapOfFieldsMappingWithIndex.get(i)));
                        
                        if(i == 9)
                            negotiatedAmount = (Decimal)(sObjContractABC.get(mapOfFieldsMappingWithIndex.get(i)));
                        
                        if(i== 10)
                            adjustedAccountingContractValue = (Decimal)(sObjContractABC.get(mapOfFieldsMappingWithIndex.get(i)));
                        
                        if(i==11)
                            setupInNegotiated = Integer.valueOf(sObjContractABC.get(mapOfFieldsMappingWithIndex.get(i)));
                    }
                }
            }
            
            //Checking list for its size
            if(cPQSubscriptions.size() > 0) {
                
                //Integer to hold the total properties count
                Integer totalPropertiesCount = 13;
            
                //Sobject instance
                sObject sObjSubscription = (sObject)cPQSubscriptions[0];
                sBQQSubcription = cPQSubscriptions[0];
                
                //Loop through total properties counts
                for(Integer i = 1; i <= totalPropertiesCount; i++) {
                    
                    //Checking for the index number in the map and populating wrapper properties accordingly
                    if(mapOfFieldsMappingWithIndex.containsKey(i)) {
                        
                        //CHecking for integer current value and accordingly setting wrapper properties
                        if(i == 1) {
                            payerAccountID = String.valueOf(sObjSubscription.get(mapOfFieldsMappingWithIndex.get(i)));
                            
                            //Looping through account records and get the name related details
                            for(Account acc : [SELECT ID, Name 
                                                FROM Account 
                                                WHERE ID =: payerAccountID])
                                payerAccountName = acc.Name;
                        }
                        
                        if(i == 2)
                            startDate = Date.valueOf(sObjSubscription.get(mapOfFieldsMappingWithIndex.get(i)));
                        
                        if(i == 3)
                            endDate = Date.valueOf(sObjSubscription.get(mapOfFieldsMappingWithIndex.get(i)));
                        
                        if(i == 4) {
                            programID = String.valueOf(sObjSubscription.get(mapOfFieldsMappingWithIndex.get(i)));
                            
                            //Looping through account records and get the name related details
                            for(Program__c prog : [SELECT ID, Name 
                                                    FROM Program__c 
                                                    WHERE ID =: programID])
                                programName = prog.Name;
                        }
                            
                        if(i == 5)
                            recognizedToDateNegotiated = (Decimal)(sObjSubscription.get(mapOfFieldsMappingWithIndex.get(i)));
                        
                        if(i == 6)
                            parentRecordName = String.valueOf(sObjSubscription.get(mapOfFieldsMappingWithIndex.get(i)));
                        
                        if(i == 7)
                            termType = String.valueOf(sObjSubscription.get(mapOfFieldsMappingWithIndex.get(i)));
                        
                        if(i == 8)
                            recognizedToDateGAAP = (Decimal)(sObjSubscription.get(mapOfFieldsMappingWithIndex.get(i)));
                        
                        if(i == 9)
                            negotiatedAmount = (Decimal)(sObjSubscription.get(mapOfFieldsMappingWithIndex.get(i)));
                        
                        if(i == 10)
                            adjustedAccountingContractValue = (Decimal)(sObjSubscription.get(mapOfFieldsMappingWithIndex.get(i)));
                            
                        if(i == 11)
                            setupInNegotiated = Integer.valueOf(sObjSubscription.get(mapOfFieldsMappingWithIndex.get(i)));
                        
                        if(i == 12)
                            gaapNegoPostageCost = (Decimal)(sObjSubscription.get(mapOfFieldsMappingWithIndex.get(i)));
                        
                        if(i == 13)
                            gaapNegoMediaCost = (Decimal)(sObjSubscription.get(mapOfFieldsMappingWithIndex.get(i)));
                        
                    }
                }                                            
            }
            //Checking list for its size
            if(standardContracts.size() > 0) {
                
                //Marking the flag to true.
                isStandardContract = true;
            	
                //Integer to hold the total properties count
                Integer totalPropertiesCount = 4;
            
                //Sobject instance
                sObject sObjContract = (sObject)standardContracts[0];
                standardCon = standardContracts[0];
                
                //Loop through total properties counts
                for(Integer i = 1; i <= totalPropertiesCount; i++) {
                
                     //Checking for the index number in the map and populating wrapper properties accordingly
                     if(mapOfFieldsMappingWithIndex.containsKey(i)) {
                        
                        //CHecking for integer current value and accordingly setting wrapper properties
                        if(i == 1) {
                            payerAccountID = String.valueOf(sObjContract.get(mapOfFieldsMappingWithIndex.get(i)));
                            
                            //Looping through account records and get the name related details
                            for(Account acc : [SELECT ID, Name 
                                               FROM Account 
                                               WHERE ID =: payerAccountID])
                                payerAccountName = acc.Name;
                        }
                        
                        if(i == 2)
                            startDate = Date.valueOf(sObjContract.get(mapOfFieldsMappingWithIndex.get(i)));
                        
                        if(i == 3)
                            parentRecordName = String.valueOf(sObjContract.get(mapOfFieldsMappingWithIndex.get(i)));
                        
                        if(i == 4) {
                            endDate = Date.valueOf(sObjContract.get(mapOfFieldsMappingWithIndex.get(i))); 
                        }
                    }
                }
            }
        }
    }
}