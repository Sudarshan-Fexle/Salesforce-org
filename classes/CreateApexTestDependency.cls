/**
* Description   :   Class to store Apex class dependencies with test class on Apex Test Dependencies object
*
* Created By    :   Ishan Arora
*
* Created Date  :   16/03/2018
*
* Version       :   V1.0 Created
*             
**/ 
public class CreateApexTestDependency {
    
    /*  @description    :  Meathod to save dependencies record in object
    *
    *  @args           	:  none
    *
    *  @return         	:   void
    *
    **/
    public void saveDependencies(){
        
        //Query to get source org instance url
        List<Connection__c> selfConnectionData = [Select Id , Instance_Url__c from Connection__c Where Name='Self Connection'];
        //Initialize parser class
        ApexCodeCoverageJsonParser classData;
        //Initialize callout class object
        OneClick_HttpCallout obj = new  OneClick_HttpCallout();
        //Initialize mapping data structure
        Map<Id,Map<String,Set<String>>> mapping  = new Map<Id,Map<String,Set<String>>>();
        //Initialize http respose holder
        HttpResponse res;
        
        //Base url request
        String url = selfConnectionData[0].Instance_Url__c +'/services/data/v41.0/tooling/query?q=Select+ApexClassorTrigger.Id,ApexClassorTrigger.Name,ApexTestClass.Name+from+ApexCodeCoverage';
        System.debug(url);
        //Loop to qery more records from next record url
        
        while(true){
            //Obtain callout response from callout calss
            res = obj.sendCallout(url);
            System.debug(res.getBody());
            //Parse response body
            classData = ApexCodeCoverageJsonParser.parse(res.getBody());
            
            //Loop on parser data for mapping of data
            for(ApexCodeCoverageJsonParser.cls_records coverageData :classData.records ){
                //Check if class id is not inserted
                if(!mapping.containsKey(coverageData.ApexClassOrTrigger.Id)){
                    //adding id of main calss and inialize map of id and string
                    mapping.put(coverageData.ApexClassOrTrigger.Id,new Map<String,Set<String>>());
                }
                //Check for if Main class is not present
                if(!mapping.get(coverageData.ApexClassOrTrigger.Id).containsKey(coverageData.ApexClassorTrigger.Name))
                {
                    //Adding main class and initalize Set of string to store list of test classes
                    mapping.get(coverageData.ApexClassOrTrigger.Id).put(coverageData.ApexClassorTrigger.Name,new Set<String>());  
                }
                //Adding test class name
                mapping.get(coverageData.ApexClassOrTrigger.Id).get(coverageData.ApexClassorTrigger.Name).add(coverageData.ApexTestClass.Name);   
            }
            //Check if there are more records to fetch
            if(classData.nextRecordsUrl != null){
                //Build url for next set of records
                url = selfConnectionData[0].Instance_Url__c +classData.nextRecordsUrl;   
            }
            else{
                break;
            }
        }
        //List of Apex_Test_Dependency__c object
        List<Apex_Test_Dependency__c> data = new List<Apex_Test_Dependency__c>();
        
        //String to hold main class name
        String mainClassName = null;
        
        //String to hold concatinated value of test classes
        String testClasses = '';
        
        //Loop in map if main class to test class
        for(String classId: mapping.keySet()){
            //Set variable to blank
            testClasses = '';
            
            //Add main class id
            for(String mainClass :mapping.get(classId).keySet()){
                //assign value to variable
                mainClassName=mainClass;
                //Initialize list to hold value of test classes
                List<String> listOfTestClasses = new List<String>();
                listOfTestClasses.addAll(mapping.get(classId).get(mainClass));
                
                for(String testClass :listOfTestClasses){
         			//concat test classes into string
                    testClasses += testClass +'|';  
                } 
            }
            //Add records to save 
            Apex_Test_Dependency__c record = new  Apex_Test_Dependency__c(Name =mainClassName ,Main_Class_ID__c = classId ,Test_Classes__c = testClasses  );
            //Adding 
            data.add(record);       
        }
        //Insert record 
        Database.insert(data);
        
    }
}