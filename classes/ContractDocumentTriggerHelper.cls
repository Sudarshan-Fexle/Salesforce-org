/*
    Purpose         :   This class is helper class for trigger on Contract Document.
                
    Create By       :   Dipesh Gupta
    
    Created Date    :   04/06/2020
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created
*/
public with sharing class ContractDocumentTriggerHelper 
{
    /**
     *  @description    :  This Method is used to populate the name of user who created the latest contract document in related list. 
     * 
     *  @args           :  List<Contract_Document__c> newContractDocuments, Map<Id, Contract_Document__c> oldContractDocuments
     * 
     *  @return         :  void
     * 
     *  @revision log   :  V1.0 Created By - Dipesh Gupta - 04/06/2020 - CR-20200403-13902 - Create new field on Membership period.
     *                    
     **/
    public static void populateUserOfLatestContractDocument(List<Contract_Document__c> newContractDocuments, Map<Id, Contract_Document__c> oldContractDocuments)
    {
        Set<Id> setOfProgramPackageIds = new Set<Id>();
        
        List<Program_Package__c> listOfProgramPackageToBeUpdated = new List<Program_Package__c>();
        
        for(Contract_Document__c conDoc : newContractDocuments != null ? newContractDocuments : oldContractDocuments.values())
        {
        	if(String.isNotBlank(conDoc.Program_Package_Royall__c))
            {
            	setOfProgramPackageIds.add(conDoc.Program_Package_Royall__c);
            }
        }
        
        if(setOfProgramPackageIds.size() > 0)
        { 
            for(Program_Package__c progPack : [SELECT Id,Latest_Contract_Document_Created_By__c, (SELECT Id, Program_Package_Royall__c, CreatedBy.Name FROM
                                               Contract_Documents__r ORDER BY CreatedDate DESC)                                                  
                                               FROM Program_Package__c WHERE Id IN : setOfProgramPackageIds 
                                               ])
            {
                if(progPack.Contract_Documents__r.size() > 0)
                {
                    progPack.Latest_Contract_Document_Created_By__c = progPack.Contract_Documents__r[0].CreatedBy.Name;
                    listOfProgramPackageToBeUpdated.add(progPack);
                }
                else
                {
                	progPack.Latest_Contract_Document_Created_By__c = '';
                    listOfProgramPackageToBeUpdated.add(progPack);
                }
            }
            
            if(listOfProgramPackageToBeUpdated.size() > 0)
            {
            	update listOfProgramPackageToBeUpdated;    
            }
        }
    }
}