/*
* Description       :       Controller for allRelatedListRecords vf page that show all related list records of Standard Contract when clicked on Show All link beside Show more link 
*							in the detail page of Standard Contract Object record.
* 
* Created Date      :       26/09/19
* 
* Revision Log      :       V_1.0  Created By : Mahendra Swarnkar - CR-20190212-12878 - Custom labels which are created :- 
Program_Subscription_Related_List_Label for - Program Subscription, Subscription Period
Component_Subscription_Related_List_Label for - Component Subscription
* */
public without sharing class AllRelatedListRecordsController 
{	
    
    public static List<Subscription_Period__c> listOfSubscriptionPeriod{get;set;}
    public static List<SBQQ__Subscription__c> listOfSBQQSubscription{get;set;}
    public Boolean isSubscriptionPeriod{get;set;}
    public Boolean isProgramSubscription{get;set;}
    public Boolean isComponentSubscription{get;set;}
    public List<String> fieldAPINames{get;set;}
    public Contract contracts{get;set;}
    
    private Map<String, String> mapOfFieldAPINameWithLabel;
    
    // GlobalDescribe Call
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
    
    /*
* @Method Name			:		showRelatedListRecords
* 
* @Args					:		String parentId, String objectName, String fieldSetName
* 
* @Return				:		PageReference
* 
* @Purpose				:		This method is used to display Program Subscription, Subscription Period, Component Subscription records dynamically acordind to their fieldSet					
* */	
    
    public void showRelatedListRecords()
    {
        String objectName = ApexPages.currentPage().getParameters().get('objectName');
        String parentId = ApexPages.currentPage().getParameters().get('parentId');
        String recordType = ApexPages.currentPage().getParameters().get('recordType');
     	
       
        
        if(String.isNotBlank(objectName) && String.isNotBlank(parentId))
        {
            contracts = [SELECT Id, Name, ContractNumber FROM Contract WHERE Id =: parentId];
            
            if(String.valueOf(objectName).equals('Subscription_Period__c'))
            {
                mapOfFieldAPINameWithLabel = returnFieldSetForSpecificObject(objectName, System.Label.Subscription_Period_Related_List);
                isSubscriptionPeriod = true;
                listOfSubscriptionPeriod = new List<Subscription_Period__c>();
                String sOQLQueryResult = 'SELECT Id, ';
                if(mapOfFieldAPINameWithLabel != null && mapOfFieldAPINameWithLabel.size() > 0)
                {
                    for(String fieldStr : mapOfFieldAPINameWithLabel.keySet())
                    {
                        sOQLQueryResult += fieldStr + ',';
                    }   
                    sOQLQueryResult = sOQLQueryResult.removeEnd(',');
                    sOQLQueryResult += ' FROM '+ objectName +' WHERE Contract__c =\'' + parentId +'\'';
                    listOfSubscriptionPeriod = (List<Subscription_Period__c>)Database.query(sOQLQueryResult);
                }
                else 
                {
                    system.debug('mapOfFieldAPINameWithLabel...'+mapOfFieldAPINameWithLabel);
                }
                
            }
            
            else if(String.valueOf(objectName).equals('SBQQ__Subscription__c') && recordType == 'Program')
            {
                mapOfFieldAPINameWithLabel = returnFieldSetForSpecificObject(objectName, System.Label.Program_Subscription_Related_List_Label);
                isProgramSubscription = true;
                listOfSBQQSubscription = new List<SBQQ__Subscription__c>();
                String sOQLQueryResult = 'SELECT Id, ';
                if(mapOfFieldAPINameWithLabel != null && mapOfFieldAPINameWithLabel.size() > 0)
                {
                    for(String fieldStr : mapOfFieldAPINameWithLabel.keySet())
                    {
                        sOQLQueryResult += fieldStr + ',';
                    }
                    sOQLQueryResult = sOQLQueryResult.removeEnd(',');
                    sOQLQueryResult += ' FROM '+ objectName +' WHERE SBQQ__Contract__c =\'' + parentId +'\' AND RecordType.DeveloperName =\''+ recordType +'\'';                    
                    listOfSBQQSubscription = (List<SBQQ__Subscription__c>)Database.query(sOQLQueryResult);
                }
                else 
                {
                    system.debug('mapOfFieldAPINameWithLabel...'+mapOfFieldAPINameWithLabel);
                }
            }
            
            else if(String.valueOf(objectName).equals('SBQQ__Subscription__c') && recordType == 'Component')
            {
                mapOfFieldAPINameWithLabel = returnFieldSetForSpecificObject(objectName, System.Label.Component_Subscription_Related_List_Label);
                isComponentSubscription = true;
                listOfSBQQSubscription = new List<SBQQ__Subscription__c>();
                String sOQLQueryResult = 'SELECT Id, ';
                if(mapOfFieldAPINameWithLabel != null && mapOfFieldAPINameWithLabel.size() > 0)
                {
                    for(String fieldStr : mapOfFieldAPINameWithLabel.keySet())
                    {
                        sOQLQueryResult += fieldStr + ',';
                    }
                    sOQLQueryResult = sOQLQueryResult.removeEnd(',');
                    sOQLQueryResult += ' FROM '+ objectName +' WHERE SBQQ__Contract__c =\'' + parentId +'\' AND RecordType.DeveloperName =\''+recordType + '\' ';
                    listOfSBQQSubscription = (List<SBQQ__Subscription__c>)Database.query(sOQLQueryResult);
                }
                else 
                {
                    system.debug('mapOfFieldAPINameWithLabel...'+mapOfFieldAPINameWithLabel);
                }
            }
        }
        else 
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'No Object Specified.'));
        }
        
    }
    
    /*
     * @Method Name			: 		returnFieldSetForSpecificObject
     * 
     * @Args				:		String objectName, String fieldSetName
     * 
     * @Return Type			:		Map<String, String>
     * 
     * @Description			:		This method is used to get the fieldSet fields for ia particular object of Standard Contract related list.
     * */
    
    public Map<String, String> returnFieldSetForSpecificObject(String objectName, String fieldSetName)
    {
        Map<String, String> mapOfFieldsetAPINameWithLabel = new Map<String, String>();
        fieldAPINames = new List<String>();
        mapOfFieldAPINameWithLabel = new Map<String, String>();
        Schema.DescribeSObjectResult DescribeSObjectResultObj = gd.get(objectName).getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        if(fieldSetObj != null)
        {
            for(Schema.FieldSetMember fields : fieldSetObj.getFields())
            {
                fieldAPINames.add(fields.getFieldPath());
                mapOfFieldsetAPINameWithLabel.put(fields.getFieldPath(), fields.getLabel()+'-'+fields.getType());
            }
        }
        else 
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'FieldSet Not Found.'));
        }
        
        return mapOfFieldsetAPINameWithLabel;
    }
    
    /*
     * @Method Name			: 		goBackToParentRecord
     * 
     * @Args				:		
     * 
     * @Return Type			:		PageReference
     * 
     * @Description			:		This method is invoked and redirect back to the Contract record from where the Show All link is clicked.
     * */
    public PageReference goBackToParentRecord()
    {
        PageReference ref = new PageReference('/'+contracts.Id);
        ref.setRedirect(true);
        return ref;
    }
}