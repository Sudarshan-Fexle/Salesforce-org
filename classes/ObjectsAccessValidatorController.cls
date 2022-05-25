/**
 *  Description     :  This class is used to check the current user permission for parent object as well as child object.
 *
 *  Created By      :  Dipesh Gupta
 *
 *  Created Date    :  07/27/2017
 *
 *  Revision Logs   :  v1.0 Created -- CR-20170109-10600
 *             v1.1 Modified by Rajeev Jain -CR-20180904-12545
 **/

public class ObjectsAccessValidatorController {
    //Modified by Rajeev Jain -CR-20180904-12545
    public String parentObjectRecordId{get; set;}
    public String parentObjectAPIName{get; set;}
    public String childrenObjectsAPIName{get; set;}
    public String cloneId {get; set;}
    public Boolean result {get; set;}
    
    //Modified by Rajeev Jain -CR-20180904-12545
    //Controller
    public ObjectsAccessValidatorController(){
        cloneId = '';
        result= true;
        
    }
    
    
    //Class variable to hold the object details
    public  Map<String, Schema.SobjectType> mapAllObject = new Map<String, Schema.SobjectType>();
    
    /**
     *  Description     :  This method is used to check the current user permission for parent object as well as child object.
     *
     *  Created By      :  Dipesh Gupta
     *
     *  Created Date    :  07/27/2017  
     *           
     * Revision Logs   : v1.0 Created -- CR-20170109-10600
 *             v1.1  Modified by Rajeev Jain -CR-20180904-12545
    **/
     public void checkForObjectsCreateAccess(/*String parentObjectRecordId, String parentObjectAPIName, String childrenObjectsAPIName*/) {
        
        //Boolean to check the parent object and child object permission.
        Boolean objectAccessible  =  false;
        Boolean childAccessible = false;
        Boolean isParentChildAccessible = false;  
        
        //Check for the null/Blanks parameters/Variables
        if(String.isNotBlank(parentObjectRecordId) && String.isNotBlank(parentObjectAPIName) && String.isNotBlank(childrenObjectsAPIName)) {
        
            //Checking parent Object accessibility.
            mapAllObject = Schema.getGlobalDescribe();
            
            //Sobject type to get the 
            DescribeSobjectResult  dSR = mapAllObject.get(parentObjectAPIName).getDescribe();
            
            //object Access 
            objectAccessible = dSR.isCreateable() ;
            
            //get the child object details 
            DescribeSobjectResult dSR1  = mapAllObject.get(childrenObjectsAPIName).getDescribe();
            
            childAccessible = dSR1.isCreateable();
            
            //Check if the parent and child both have the create access.
            if(objectAccessible == true && childAccessible == true) {
                
                //Changing flags value
                isParentChildAccessible = true; 
            }
        }  
            
      result = isParentChildAccessible;
         if(isParentChildAccessible){
             
             Id parentID = Id.valueOf(parentObjectRecordId);
             
           cloneId = cloneWithProgram(parentID);
             
         }
        // return cloneId;
    }
    
    
    /**
     *  Description     :  This method is to deep clone the records.
     *
     *  Created By      :  Dipesh Gupta    
     *
     *  Created Date    :  07/27/2017 
    **/
    public string cloneWithProgram(Id parentObjectRecordId1) {
        
        //Set save point to control the transaction
        Savepoint sp = Database.setSavepoint();
        String errorMessage= '';
        try{
            System.debug('@@@###0'+ parentObjectRecordId1);
          //Check for blank value check
          if(String.IsNotBlank(parentObjectRecordId1)) {
              
               //map to hold the fields of Sobject
               Map<String, SObjectField> mapOfFields =  new Map<String, SObjectField>();
               
                //Filling the map for the program package object fields
                mapOfFields = Schema.SObjectType.Program_Package__c.fields.getmap();
                
                //Set to hold the standard created date , last modified date 
                Set<String> setofStandardFields = new Set<String> { 'LastModifiedDate', 'Owner','CreatedBy', 'CurrencyIsoCode', 'ownerid', 'isdeleted',  'currencyisocode', 'createddate', 'createdbyid', 'lastmodifieddate', 'lastmodifiedbyid', 'systemmodstamp', 'lastactivitydate', 'lastvieweddate', 'lastreferenceddate', 'connectionreceivedid', 'connectionsentid'};
                
                //String to hold all the fields 
                String allFields = '';
              
              //Loop through the map of fields
              for(String fieldsOfProgram : mapOfFields.keySet()) {
                
                //Check if the set contains field
                if(!setofStandardFields.contains(fieldsOfProgram)) {
                  
                  //Creating string of commamseprated fields 
                  allFields += fieldsOfProgram + ', ';
                  
                }
              }
              
              //String to hold the dynamic query
              String query = 'Select ' + allFields.removeEnd(', ') + ' From  Program_Package__c  Where Id = \'' + parentObjectRecordId1 + '\'';
              
              //List to hold the dynammic query result.
              List<Program_Package__c> programPackage = database.query(query);
              
              //List to deep clone.
              List<Program_Package__c> newProgramId = programPackage.deepClone(false,true);  
                
              system.debug('newId-----'+newProgramId);
              
              //Checking for the size of list
              if(newProgramId.size() > 0)
                
                insert newProgramId;
              
              /*Cloning child record*/
              
              mapOfFields = new Map<String, SObjectField>();
              
              //Filling the map for the program package object fields
               mapOfFields = Schema.SObjectType.Royall_Program__c.fields.getmap();
               
               //String to hold the all child fields
               String childFields = '';
               
               //Loop through the map of fields
              for(String fieldsOfProgram : mapOfFields.keySet()) {
                
                //Check if the set contains field
                if(!setofStandardFields.contains(fieldsOfProgram)) {
                  
                  //Creating string of commamseprated fields 
                  childFields += fieldsOfProgram + ', ';
                  
                }
              }
              
              //Query fro the royall objet
              String royallObjQuery = 'Select ' + childFields.removeEnd(', ') + ' FROM Royall_Program__c  Where Program_Package__c = \'' + parentObjectRecordId1 + '\'';
              
              system.debug('royallObjQuery===='+royallObjQuery);
                
              //List to hold the Royall program record from the dynaic query
              List<Royall_Program__c> oldRoyallRecords = database.query(royallObjQuery);
        
            //List to hold the New  royall programs
            List<Royall_Program__c> newRoyallRecords = new List<Royall_Program__c>();
            
            //Cloned royall Program
            List<Royall_Program__c> clonedRoyallProgram = oldRoyallRecords.deepClone(false,true);
              
              system.debug('clonedRoyallProgram===='+clonedRoyallProgram);
            
              //Loop through the royall records 
              for(Royall_Program__c royalProgram : clonedRoyallProgram) {
                
                //Changing the program package with the new one
                royalProgram.Program_Package__c = newProgramId[0].Id;
                
                newRoyallRecords.add(royalProgram);
              }
              
              system.debug('newRoyallRecords----'+newRoyallRecords);
              
              //Checking for the size of list
              if(newRoyallRecords.size() > 0)
                //Inserting the new 
                insert newRoyallRecords;
              
              //return newId.Id;   
              return newProgramId[0].Id;       
              
          }  
          return null;  
        
       }catch(Exception e) {
            Database.rollback(sp);
             errorMessage = e.getMessage();
           return errorMessage;
        }
    }
}