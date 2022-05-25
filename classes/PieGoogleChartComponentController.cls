/**
*  Description      :   Controller class for Google Pie Chart Component.
*
*  Created By       :   Simplyforce Hackathon Team (The Brain Trust) [Abhinav, Subhash, Deepak, Abhishek and Jatin]
*
*  Created Date     :   04/22/2017
*
*  Revision Logs    :   v1.0 - Created - Simplyforce Hackathon Team (The Brain Trust) [Primary Owner = Abhinav]
*
**/
public class PieGoogleChartComponentController {

    //Properties
    public transient Id sobjectId {get; set;}
    public transient Integer currentChartCount {get; set;}
    public transient List<GoogleChartWrapper> chartWrapperInstances {get; set;}
    public transient String dataString {get; set;}
    
    transient Set<String> setOfFieldsAPIName = new Set<String>();
    
    //Constructors
    public PieGoogleChartComponentController() {
        currentChartCount = 0;
        dataString = '[[' + '\'' + string.escapeSingleQuotes('Task, ') + '\'' + string.escapeSingleQuotes('Hours per Day') + '\'' + '],[';
    }
    
    public Boolean init {
        get{
            init();
            return false;
        }
    }
    
    public void init(){
    
       //put all your initlization logic here.
       //your assigned properties will be set when this executes
       //Check for sobjectId is null
       If(sobjectId != null) {
            
            //Get the SobjectName
            transient String sObjectName = sobjectId.getSObjectType().getDescribe().getName();
           
            for(GoogleChartWrapper chartWrapperInstance : chartWrapperInstances) {
              
                if(String.isNotBlank(chartWrapperInstance.firstFieldAPINameStr))
                   setOfFieldsAPIName.add(chartWrapperInstance.firstFieldAPINameStr);
                
                if(String.isNotBlank(chartWrapperInstance.secondFieldAPINameStr))
                   setOfFieldsAPIName.add(chartWrapperInstance.secondFieldAPINameStr);
                
                if(String.isNotBlank(chartWrapperInstance.thirdFieldAPINameStr))
                   setOfFieldsAPIName.add(chartWrapperInstance.thirdFieldAPINameStr);
                
                if(String.isNotBlank(chartWrapperInstance.fourthFieldAPINameStr))
                   setOfFieldsAPIName.add(chartWrapperInstance.fourthFieldAPINameStr);
                
                if(String.isNotBlank(chartWrapperInstance.fifthFieldAPINameStr))
                   setOfFieldsAPIName.add(chartWrapperInstance.fifthFieldAPINameStr);
                
                if(String.isNotBlank(chartWrapperInstance.sixthFieldAPINameStr))
                   setOfFieldsAPIName.add(chartWrapperInstance.sixthFieldAPINameStr);
                
                if(String.isNotBlank(chartWrapperInstance.seventhFieldAPINameStr))
                   setOfFieldsAPIName.add(chartWrapperInstance.seventhFieldAPINameStr);
                
                if(String.isNotBlank(chartWrapperInstance.eightFieldAPINameStr))
                   setOfFieldsAPIName.add(chartWrapperInstance.eightFieldAPINameStr);
                
                if(String.isNotBlank(chartWrapperInstance.ninthFieldAPINameStr))
                   setOfFieldsAPIName.add(chartWrapperInstance.ninthFieldAPINameStr);
                
                if(String.isNotBlank(chartWrapperInstance.tenthFieldAPINameStr))
                   setOfFieldsAPIName.add(chartWrapperInstance.tenthFieldAPINameStr);
                
                if(String.isNotBlank(chartWrapperInstance.eleventhFieldAPINameStr))
                   setOfFieldsAPIName.add(chartWrapperInstance.eleventhFieldAPINameStr);
                
                if(String.isNotBlank(chartWrapperInstance.twelveFieldAPINameStr))
                   setOfFieldsAPIName.add(chartWrapperInstance.twelveFieldAPINameStr);
            }
           
            retrieveData(sObjectName);
        }
    }
    
    //Retrieve the data doing a dynamic query by object type.
    private void retrieveData(String sObjectNameStr) {
        
        try {
            
            transient String queryStr = 'SELECT ID, ';
            
            //Loop through field API Name string
            for(String fieldAPIName : setOfFieldsAPIName) {
              queryStr += fieldAPIName + ',';
            }
            
            //Query string
            queryStr = queryStr.trim();
            
            //If query ends with ',' 
            if(queryStr.endsWith(',')) {
       
                //fetching the value in between two 'AND's
                queryStr = queryStr.subString(0, queryStr.lastIndexOf(',')); 
            }
            
            queryStr += ' FROM ' + sObjectNameStr + ' WHERE ID = ' + '\'' + string.escapeSingleQuotes(sobjectId) + '\'';
            
            transient List<sObject> sobjectList = Database.query(queryStr);
            
            //Checking for the size and null value
            if(!sobjectList.isEmpty()) {
                
                for(GoogleChartWrapper chartWrapperInstance : chartWrapperInstances) {
                
                    if(String.isNotBlank(chartWrapperInstance.firstFieldAPINameStr)) {
                      if(sobjectList[0].get(chartWrapperInstance.firstFieldAPINameStr) != null)  
                          chartWrapperInstance.firstFieldValue = Decimal.valueOf(String.valueOf(sobjectList[0].get(chartWrapperInstance.firstFieldAPINameStr)));
                    }
                        
                    if(String.isNotBlank(chartWrapperInstance.secondFieldAPINameStr)) {
                        if(sobjectList[0].get(chartWrapperInstance.secondFieldAPINameStr) != null)
                        chartWrapperInstance.secondFieldValue = Decimal.valueOf(String.valueOf(sobjectList[0].get(chartWrapperInstance.secondFieldAPINameStr)));
                    }
                        
                    if(String.isNotBlank(chartWrapperInstance.thirdFieldAPINameStr)) {
                        if(sobjectList[0].get(chartWrapperInstance.thirdFieldAPINameStr) != null)
                        chartWrapperInstance.thirdFieldValue = Decimal.valueOf(String.valueOf(sobjectList[0].get(chartWrapperInstance.thirdFieldAPINameStr)));
                    }
                    
                    if(String.isNotBlank(chartWrapperInstance.fourthFieldAPINameStr)) {
                      if(sobjectList[0].get(chartWrapperInstance.fourthFieldAPINameStr) != null)
                          chartWrapperInstance.fourthFieldValue = Decimal.valueOf(String.valueOf(sobjectList[0].get(chartWrapperInstance.fourthFieldAPINameStr)));
                    }
                        
                    if(String.isNotBlank(chartWrapperInstance.fifthFieldAPINameStr)) {
                      if(sobjectList[0].get(chartWrapperInstance.fifthFieldAPINameStr) != null)
                          chartWrapperInstance.fifthFieldValue = Decimal.valueOf(String.valueOf(sobjectList[0].get(chartWrapperInstance.fifthFieldAPINameStr)));
                    }
                        
                    if(String.isNotBlank(chartWrapperInstance.sixthFieldAPINameStr)) {
                      if(sobjectList[0].get(chartWrapperInstance.sixthFieldAPINameStr) != null)
                          chartWrapperInstance.sixthFieldValue = Decimal.valueOf(String.valueOf(sobjectList[0].get(chartWrapperInstance.sixthFieldAPINameStr)));
                    }
                        
                    if(String.isNotBlank(chartWrapperInstance.seventhFieldAPINameStr)) {
                        if(sobjectList[0].get(chartWrapperInstance.seventhFieldAPINameStr) != null)
                          chartWrapperInstance.seventhFieldValue = Decimal.valueOf(String.valueOf(sobjectList[0].get(chartWrapperInstance.seventhFieldAPINameStr)));
                    }
                        
                    if(String.isNotBlank(chartWrapperInstance.eightFieldAPINameStr)) {
                        if(sobjectList[0].get(chartWrapperInstance.eightFieldAPINameStr) != null)
                          chartWrapperInstance.eightFieldValue = Decimal.valueOf(String.valueOf(sobjectList[0].get(chartWrapperInstance.eightFieldAPINameStr)));
                    }
                        
                    if(String.isNotBlank(chartWrapperInstance.ninthFieldAPINameStr)) {
                        if(sobjectList[0].get(chartWrapperInstance.ninthFieldAPINameStr) != null)
                          chartWrapperInstance.ninthFieldValue = Decimal.valueOf(String.valueOf(sobjectList[0].get(chartWrapperInstance.ninthFieldAPINameStr)));
                    }
                        
                    if(String.isNotBlank(chartWrapperInstance.tenthFieldAPINameStr)) {
                      if(sobjectList[0].get(chartWrapperInstance.tenthFieldAPINameStr) != null)
                          chartWrapperInstance.tenthFieldValue = Decimal.valueOf(String.valueOf(sobjectList[0].get(chartWrapperInstance.tenthFieldAPINameStr)));
                    }
                        
                    if(String.isNotBlank(chartWrapperInstance.eleventhFieldAPINameStr)) {
                        if(sobjectList[0].get(chartWrapperInstance.eleventhFieldAPINameStr) != null)
                          chartWrapperInstance.eleventhFieldValue = Decimal.valueOf(String.valueOf(sobjectList[0].get(chartWrapperInstance.eleventhFieldAPINameStr)));
                    }
                        
                    if(String.isNotBlank(chartWrapperInstance.twelveFieldAPINameStr)) {
                    if(sobjectList[0].get(chartWrapperInstance.twelveFieldAPINameStr) != null)
                          chartWrapperInstance.twelveFieldValue = Decimal.valueOf(String.valueOf(sobjectList[0].get(chartWrapperInstance.twelveFieldAPINameStr)));
                    }
                }
            }
            
            for(GoogleChartWrapper wrap : chartWrapperInstances) {
                
                if(String.isNotBlank(wrap.firstFieldChartTitle) && wrap.firstFieldValue != null)
                  dataString += '\'' + wrap.firstFieldChartTitle + '\''  + ', ' + '\'' + wrap.firstFieldValue + '\'' + '],';
                
                if(String.isNotBlank(wrap.secondFieldChartTitle) && wrap.secondFieldValue != null)
                  dataString += '[' + '\'' + wrap.secondFieldChartTitle + '\''  + ', ' + '\'' + + wrap.secondFieldValue + '\'' + ']]';
                
                if(String.isNotBlank(wrap.thirdFieldChartTitle) && wrap.thirdFieldValue != null)
                  dataString += '[' + '\'' + wrap.thirdFieldChartTitle + '\''  + ', ' + '\'' + + wrap.thirdFieldValue + '\'' + ']]';
                
                if(String.isNotBlank(wrap.fourthFieldChartTitle) && wrap.fourthFieldValue != null)
                  dataString += '[' + '\'' + wrap.fourthFieldChartTitle + '\''  + ', ' + '\'' + + wrap.fourthFieldValue + '\'' + ']]';
                
                if(String.isNotBlank(wrap.fifthFieldChartTitle) && wrap.fifthFieldValue != null)
                  dataString += '[' + '\'' + wrap.fifthFieldChartTitle + '\''  + ', ' + '\'' + + wrap.fifthFieldValue + '\'' + ']]';
                
                if(String.isNotBlank(wrap.sixthFieldChartTitle) && wrap.sixthFieldValue != null)
                  dataString += '[' + '\'' + wrap.sixthFieldChartTitle + '\''  + ', ' + '\'' + + wrap.sixthFieldValue + '\'' + ']]';
                
                if(String.isNotBlank(wrap.seventhFieldChartTitle) && wrap.seventhFieldValue != null)
                  dataString += '[' + '\'' + wrap.seventhFieldChartTitle + '\''  + ', ' + '\'' + + wrap.seventhFieldValue + '\'' + ']]';
                
                if(String.isNotBlank(wrap.eightFieldChartTitle) && wrap.eightFieldValue != null)
                  dataString += '[' + '\'' + wrap.eightFieldChartTitle + '\''  + ', ' + '\'' + + wrap.eightFieldValue + '\'' + ']]';
                
                if(String.isNotBlank(wrap.ninthFieldChartTitle) && wrap.ninthFieldValue != null)
                  dataString += '[' + '\'' + wrap.ninthFieldChartTitle + '\''  + ', ' + '\'' + + wrap.ninthFieldValue + '\'' + ']]';
                
                if(String.isNotBlank(wrap.tenthFieldChartTitle) && wrap.tenthFieldValue != null)
                  dataString += '[' + '\'' + wrap.tenthFieldChartTitle + '\''  + ', ' + '\'' + + wrap.tenthFieldValue + '\'' + ']]';
                
                if(String.isNotBlank(wrap.eleventhFieldChartTitle) && wrap.eleventhFieldValue != null)
                  dataString += '[' + '\'' + wrap.eleventhFieldChartTitle + '\''  + ', ' + '\'' + + wrap.eleventhFieldValue + '\'' + ']]';
                
                if(String.isNotBlank(wrap.twelveFieldChartTitle) && wrap.twelveFieldValue != null)
                  dataString += '[' + '\'' + wrap.twelveFieldChartTitle + '\''  + ', ' + '\'' + + wrap.twelveFieldValue + '\'' + ']]';
            }
            
            //throw new customException('@@@@@ ' + dataString);
            
            /*[
              ['Task', 'Hours per Day'],
              ['Work',     1],
              ['Eat',      2],
              ['Commute',  2],
              ['Watch TV', 2],
              ['Sleep',    7]
            ]*/
            
        } catch(Exception ex) {
            throw new CustomException('[retrieveData] Unable to retrieve data and Line No. is ' + ex.getLineNumber() + ' Error Message is ' + ex.getMessage());
        }
    }
}