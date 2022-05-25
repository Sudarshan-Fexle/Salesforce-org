/**
*  Description      :   This Apex class is used for GanttViewMainComp. 
*
*  Created By       :   Simplyforce Hackathon Team (The Brain Trust)
*
*  Created Date     :   04/22/2017
*
*  Revision Logs    :   V_1.0 - Created - Simplyforce Hackathon Team (The Brain Trust)
*
**/
public class GanttViewMainCompController {
    
    //Variable to hold the detail page based record ID
    public String mytarget {get; 
                set {
                              this.mytarget = value;
                                init();
                            }
                           }
                           
    public Gantt_View_Manager__mdt applicableConfigInstance {get; set;}
    public Integer orderNumber {get; set;}
    
    //Variable to hold the JSON data string for the Gantt Chart
    public String ganttChartJSON {get;set;}
    
    //sObject List
    transient private List<Sobject> sobjectList;
    
    //REGEX
    private static final String REGEXP_QUOTES    = '(?<!\\\\)"';
    
    //Constructor
    public GanttViewMainCompController() {
      init();
    }
    
    //inIt Method
    private void init() {
        if (myTarget != null) {
        if(applicableConfigInstance != null)
          retrieveData();    
        }
    }
    
    //Get 
    public String getGanttChartJSON() {
        return ganttChartJSON;
    }
    
    //Retrieve the data doing a dynamic query by object type.
    private void retrieveData() {
        
        try {
            
            String queryStr = getSoqlQuery((sObject)applicableConfigInstance);
            queryStr += '\'' + string.escapeSingleQuotes(mytarget) + '\'';
            queryStr += ' ORDER BY ' + applicableConfigInstance.Order_By_Field_API_Name__c + ' ' + applicableConfigInstance.Sort_Order_Type__c;
            
            sobjectList = Database.query(queryStr);
            
            //Build JSON String for displaying output
            ganttChartJSON = buildGanttChartJSON();
            
        } catch(Exception ex) {
            throw new CustomException('[retrieveData] Unable to retrieve data and Line No. is ' + ex.getLineNumber() + ' Error Message is ' + ex.getMessage());
        }
    }
    
    //Generate the output in json format to be rendered in the jquery gantt.
  private String buildGanttChartJSON() {
        
        try {
          
            //Initializing variables
            String ret = 'var ganttData' + mytarget + ' = [{id: 1, name: "", series: [';
          Boolean addComma = false;
            Date startDate, endDate;
            String colorASCIICodeStr = '';
            Boolean isGotCompleted = false;
            
            //Checking if "Multi level" checkbox is enable on the selected metadata row
            if(applicableConfigInstance.Multi_Level__c) {
              
              //Checking upto which level we have to display the children records on the gantt chart
              //if we have to display the records upto 4th level 
              //means (Package (0th level) --> SFDC Release (1st Level) --> Change Request (2nd Level) --> Mods (3rd Level) --> CRA (5th Level))
              if(String.isNotBlank(applicableConfigInstance.Parent_Object_API_Name__c)
                && String.isNotBlank(applicableConfigInstance.X1st_Child_Object_API_Name__c)
                && String.isNotBlank(applicableConfigInstance.X2nd_Child_Object_API_Name__c)
                && String.isNotBlank(applicableConfigInstance.X3rd_Child_Object_API_Name__c)
                && String.isNotBlank(applicableConfigInstance.X4th_Child_Object_API_Name__c) 
            ) {
                    
                    return null;
                  
              //if we have to display the records upto 3rd level     
            } else if(String.isNotBlank(applicableConfigInstance.Parent_Object_API_Name__c)
                && String.isNotBlank(applicableConfigInstance.X1st_Child_Object_API_Name__c)
                && String.isNotBlank(applicableConfigInstance.X2nd_Child_Object_API_Name__c)
                && String.isNotBlank(applicableConfigInstance.X3rd_Child_Object_API_Name__c)
                && String.isBlank(applicableConfigInstance.X4th_Child_Object_API_Name__c)
              ) {
                
                //Map of sObjects
                
                //SFDC Release ID with Change Requests
              transient Map<String, List<sObject>> mapOf1stLevelParentIdWith2ndLevelChildren = new Map<String, List<sObject>>();
              
              //Change Request ID With IS System Mods
              transient Map<String, List<sObject>> mapOf2ndLevelParentIdWith3rdLevelChildren = new Map<String, List<sObject>>();
                    
                    //SFDC Release ID with IS System Mods instance (Queried and having all the respective details)
                    transient Map<String, sObject> mapParentIdWithChildHavingAllRetrievedDetails = new Map<String, sObject>();
              
              //Set to maintain the uniqueness
              Set<String> setToMaintainTheUniqueness = new Set<String>();
              
              //List of sObjects
              for(sObject ob : sobjectList) {
                  
                        //SFDC Release ID with Change Requests
                  if(ob.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c + '__r').get(applicableConfigInstance.X1st_Child_Object_API_Name__c) != null) {
                    
                            //Checking if parent record ID is already exist as key in the map
                    if(mapOf1stLevelParentIdWith2ndLevelChildren.containsKey(String.valueOf(ob.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c  + '__r').get(applicableConfigInstance.X1st_Child_Object_API_Name__c)))) {
                      
                                //Checking for the uniqueness
                      if(!setToMaintainTheUniqueness.contains(String.valueOf(ob.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c  + '__r').get('id')))) {
                        
                        //SObject Instance
                        Schema.SObjectType sobjectType = (Id.valueOf(String.valueOf(ob.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c  + '__r').get('id')))).getSObjectType();
                        sObject cRSObj = sobjectType.newSObject(ID.valueOf(String.valueOf(ob.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c  + '__r').get('id'))));
                        cRSObj.put(applicableConfigInstance.X2nd_Child_Start_Date_Field_API_Name__c, Date.valueOf(ob.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c  + '__r').get(applicableConfigInstance.X2nd_Child_Start_Date_Field_API_Name__c)));
                        cRSObj.put(applicableConfigInstance.X2nd_Child_End_Date_Field_API_Name__c, Date.valueOf(ob.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c  + '__r').get(applicableConfigInstance.X2nd_Child_End_Date_Field_API_Name__c)));
                        cRSObj.put(applicableConfigInstance.X2nd_Child_Completed_Field_API_Name__c, Boolean.valueOf(ob.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c  + '__r').get(applicableConfigInstance.X2nd_Child_Completed_Field_API_Name__c)));
                        cRSObj.put(applicableConfigInstance.X2nd_Child_Name_Field_API_Name__c, String.valueOf(ob.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c  + '__r').get(applicableConfigInstance.X2nd_Child_Name_Field_API_Name__c)));
                        setToMaintainTheUniqueness.add(String.valueOf(ob.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c  + '__r').get('id')));
                        mapOf1stLevelParentIdWith2ndLevelChildren.get(String.valueOf(ob.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c + '__r').get(applicableConfigInstance.X1st_Child_Object_API_Name__c))).add(cRSObj);
                        }
                                
                    } else {
                        
                                //Checking for the uniqueness
                        if(!setToMaintainTheUniqueness.contains(String.valueOf(ob.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c  + '__r').get('id')))) {
                        
                        //SObject Instance
                        Schema.SObjectType sobjeType = (Id.valueOf(String.valueOf(ob.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c  + '__r').get('id')))).getSObjectType();
                        sObject cSObj = sobjeType.newSObject(ID.valueOf(String.valueOf(ob.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c  + '__r').get('id'))));
                        cSObj.put(applicableConfigInstance.X2nd_Child_Start_Date_Field_API_Name__c, Date.valueOf(ob.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c  + '__r').get(applicableConfigInstance.X2nd_Child_Start_Date_Field_API_Name__c)));
                        cSObj.put(applicableConfigInstance.X2nd_Child_End_Date_Field_API_Name__c, Date.valueOf(ob.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c  + '__r').get(applicableConfigInstance.X2nd_Child_End_Date_Field_API_Name__c)));
                        cSObj.put(applicableConfigInstance.X2nd_Child_Completed_Field_API_Name__c, Boolean.valueOf(ob.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c  + '__r').get(applicableConfigInstance.X2nd_Child_Completed_Field_API_Name__c)));
                        cSObj.put(applicableConfigInstance.X2nd_Child_Name_Field_API_Name__c, String.valueOf(ob.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c  + '__r').get(applicableConfigInstance.X2nd_Child_Name_Field_API_Name__c)));
                        setToMaintainTheUniqueness.add(String.valueOf(ob.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c  + '__r').get('id')));
                        mapOf1stLevelParentIdWith2ndLevelChildren.put(String.valueOf(ob.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c + '__r').get(applicableConfigInstance.X1st_Child_Object_API_Name__c)), new List<sObject>{cSObj});     
                        }
                      }
                            
                            //Populating map with values
                            mapParentIdWithChildHavingAllRetrievedDetails.put(String.valueOf(ob.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c + '__r').get(applicableConfigInstance.X1st_Child_Object_API_Name__c)), ob);
                  }
                
                        //Change Requests ID with IS System Mods
                  if(ob.get(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c + '__c') != null) {
                    
                            //Checking for key existance in the map
                    if(mapOf2ndLevelParentIdWith3rdLevelChildren.containsKey(String.valueOf(ob.get(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c + '__c')))) {
                        mapOf2ndLevelParentIdWith3rdLevelChildren.get(String.valueOf(ob.get(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c + '__c'))).add(ob);
                      } else {
                        mapOf2ndLevelParentIdWith3rdLevelChildren.put(String.valueOf(ob.get(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c + '__c')), new List<sObject>{ob});     
                      }
                  }
                    }
                      
              //List of sObjects
              //SFDC Release IDs
              for (String parentRecId : mapOf1stLevelParentIdWith2ndLevelChildren.keySet()) {
                  
                  //sObject Instance having all the queried details
                  transient sObject currentSobj = mapParentIdWithChildHavingAllRetrievedDetails.get(parentRecId);
                  
                        //Start Date Determination (SFDC Release)
            if(currentSobj.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c + '__r').getSobject(applicableConfigInstance.X1st_Child_Relationship_Field_API_Name__c + '__r').get(applicableConfigInstance.X1st_Child_Start_Date_Field_API_Name__c) == null)
                      startDate = Date.today();
                  else
                      startDate = Date.valueOf(currentSobj.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c + '__r').getSobject(applicableConfigInstance.X1st_Child_Relationship_Field_API_Name__c + '__r').get(applicableConfigInstance.X1st_Child_Start_Date_Field_API_Name__c));
                  
                        //End Date Determination (SFDC Release)
                  if(currentSobj.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c + '__r').getSobject(applicableConfigInstance.X1st_Child_Relationship_Field_API_Name__c + '__r').get(applicableConfigInstance.X1st_Child_End_Date_Field_API_Name__c) == null)
                      endDate = startDate;
                  else
                      endDate = Date.valueOf(currentSobj.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c + '__r').getSobject(applicableConfigInstance.X1st_Child_Relationship_Field_API_Name__c + '__r').get(applicableConfigInstance.X1st_Child_End_Date_Field_API_Name__c));
                  
                  //Completed? Determination (SFDC Release)
                    if(currentSobj.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c + '__r').getSobject(applicableConfigInstance.X1st_Child_Relationship_Field_API_Name__c + '__r').get(applicableConfigInstance.X1st_Child_Completed_Field_API_Name__c) == true)
                        isGotCompleted = true;
                    else
                        isGotCompleted = false;
                      
                  if (addComma) { ret += ','; }
                      
                    //Color Determination
                    colorASCIICodeStr = colorDeterminationForFirstChild(isGotCompleted, colorASCIICodeStr, startDate, endDate);
                  
                        //JSON String (SFDC Release Records)
                    ret +=   '{'+
                            'id: "' + currentSobj.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c + '__r').getSobject(applicableConfigInstance.X1st_Child_Relationship_Field_API_Name__c + '__r').get('id') + '",' + 
                            'name: "' + escapeDoubleQuotes(String.valueOf(currentSobj.getSobject(applicableConfigInstance.X2nd_Child_Relationship_Field_API_Name__c + '__r').getSobject(applicableConfigInstance.X1st_Child_Relationship_Field_API_Name__c + '__r').get(applicableConfigInstance.X1st_Child_Name_Field_API_Name__c))) + '",' +
                            'start: new Date(' + startDate.year() + ',' + (startDate.month()-1) + ',' + startDate.day() + '),' +
                            'end: new Date(' + endDate.year() + ',' + (endDate.month()-1) + ',' + endDate.day() + '),' +
                            'color: "' + colorASCIICodeStr + '",' +
                              'childlevel: "' + 'first' + '"' +
                            '}';
      
                addComma=true;
              
                //Re-initialization
                      colorASCIICodeStr = '';
                        
                    //Loop through sObject records
                    //IS System Mods Records
                  for(sObject curSobj : mapOf1stLevelParentIdWith2ndLevelChildren.get(parentRecId)) {
                      
                      //Start Date Determination (Change Request)
                      if(curSobj.get(applicableConfigInstance.X2nd_Child_Start_Date_Field_API_Name__c) == null)
                          startDate = Date.today();
                      else
                          startDate = Date.valueOf(curSobj.get(applicableConfigInstance.X2nd_Child_Start_Date_Field_API_Name__c));
                      
                      //End Date Determination (Change Request)
                      if(curSobj.get(applicableConfigInstance.X2nd_Child_End_Date_Field_API_Name__c) == null)
                          endDate = startDate;
                      else
                          endDate = Date.valueOf(curSobj.get(applicableConfigInstance.X2nd_Child_End_Date_Field_API_Name__c));
                    
                    //Completed? Determination (Change Request)
                      if(curSobj.get(applicableConfigInstance.X2nd_Child_Completed_Field_API_Name__c) == true)
                          isGotCompleted = true;
                      else
                          isGotCompleted = false;
                    
                      if (addComma) { ret += ','; }
                          
                      //Color Determination
                      colorASCIICodeStr = colorDeterminationForFirstChild(isGotCompleted, colorASCIICodeStr, startDate, endDate);
                         
                            //JSON String (Change Request Records)
                      ret +=   '{'+
                              'id: "' + curSobj.get('id') + '",' + 
                              'name: "' + escapeDoubleQuotes(String.valueOf(curSobj.get(applicableConfigInstance.X2nd_Child_Name_Field_API_Name__c))) + '",' +
                              'start: new Date(' + startDate.year() + ',' + (startDate.month()-1) + ',' + startDate.day() + '),' +
                              'end: new Date(' + endDate.year() + ',' + (endDate.month()-1) + ',' + endDate.day() + '),' +
                              'color: "' + colorASCIICodeStr + '",' +
                                  'childlevel: "' + 'second' + '"' +
                              '}';
                      
                      addComma=true;
                      
                      //Re-initialization
                        colorASCIICodeStr = '';
                      
                      //Loop through sObject records
                      //IS System Mods records (With respect to change request)
                    for(sObject cobj : mapOf2ndLevelParentIdWith3rdLevelChildren.get(String.valueOf(curSobj.get('id')))) {
                      
                      //Start Date Determination (IS System Mods)
                        if(cobj.get(applicableConfigInstance.X3rd_Child_Start_Date_Field_API_Name__c) == null)
                            startDate = Date.today();
                        else
                            startDate = Date.valueOf(cobj.get(applicableConfigInstance.X3rd_Child_Start_Date_Field_API_Name__c));
                        
                        //End Date Determination (IS System Mods)
                        if(cobj.get(applicableConfigInstance.X3rd_Child_End_Date_Field_API_Name__c) == null)
                            endDate = startDate;
                        else
                            endDate = Date.valueOf(cobj.get(applicableConfigInstance.X3rd_Child_End_Date_Field_API_Name__c));
                      
                      //Completed? Determination (IS System Mods)
                        if(cobj.get(applicableConfigInstance.X3rd_Child_Completed_Field_API_Name__c) == true)
                            isGotCompleted = true;
                        else
                            isGotCompleted = false;
                      
                        if (addComma) { ret += ','; }
                            
                        //Color Determination
                        colorASCIICodeStr = colorDeterminationForFirstChild(isGotCompleted, colorASCIICodeStr, startDate, endDate);
                           
                                //JSON String (IS System Mods Records)
                        ret +=   '{'+
                                'id: "' + cobj.get('id') + '",' + 
                                'name: "' + escapeDoubleQuotes(String.valueOf(cobj.get(applicableConfigInstance.X3rd_Child_Name_Field_API_Name__c))) + '",' +
                                'start: new Date(' + startDate.year() + ',' + (startDate.month()-1) + ',' + startDate.day() + '),' +
                                'end: new Date(' + endDate.year() + ',' + (endDate.month()-1) + ',' + endDate.day() + '),' +
                                'color: "' + colorASCIICodeStr + '",' +
                                    'childlevel: "' + 'third' + '"' +
                                '}';
                        
                        addComma=true;
                        
                        //Re-initialization
                          colorASCIICodeStr = '';
                      }
                    }
                    
                        ret+=']}];';
                  return ret;
              }
              
              //return null    
              return null;  
              
            //if we have to display the records upto 2nd level   
            } else if(String.isNotBlank(applicableConfigInstance.Parent_Object_API_Name__c)
                && String.isNotBlank(applicableConfigInstance.X1st_Child_Object_API_Name__c)
                && String.isNotBlank(applicableConfigInstance.X2nd_Child_Object_API_Name__c)
                && String.isBlank(applicableConfigInstance.X3rd_Child_Object_API_Name__c)
                && String.isBlank(applicableConfigInstance.X4th_Child_Object_API_Name__c)
              ) {
                
                //Map of sObjects
              transient Map<String, List<sObject>> mapOfParentIdWithChildren = new Map<String, List<sObject>>();
              
              //List of sObjects
              for(sObject ob : sobjectList) {
                  if(ob.get(applicableConfigInstance.X1st_Child_Object_API_Name__c) != null) {
                    if(mapOfParentIdWithChildren.containsKey(String.valueOf(ob.get(applicableConfigInstance.X1st_Child_Object_API_Name__c)))) {
                        mapOfParentIdWithChildren.get(String.valueOf(ob.get(applicableConfigInstance.X1st_Child_Object_API_Name__c))).add(ob);
                      } else {
                        mapOfParentIdWithChildren.put(String.valueOf(ob.get(applicableConfigInstance.X1st_Child_Object_API_Name__c)), new List<sObject>{ob});     
                      }
                  }
              }
          
                //List of sObjects
              for (String parentRecId : mapOfParentIdWithChildren.keySet()) {
                  
                  //1st child record instance
                  transient sObject currentSobj = mapOfParentIdWithChildren.get(parentRecId)[0];
                  
                  if(currentSobj.getSobject(applicableConfigInstance.X1st_Child_Relationship_Field_API_Name__c + '__r').get(applicableConfigInstance.X1st_Child_Start_Date_Field_API_Name__c) == null)
                      startDate = Date.today();
                  else
                      startDate = Date.valueOf(currentSobj.getSobject(applicableConfigInstance.X1st_Child_Relationship_Field_API_Name__c + '__r').get(applicableConfigInstance.X1st_Child_Start_Date_Field_API_Name__c));
                    
                  if(currentSobj.getSobject(applicableConfigInstance.X1st_Child_Relationship_Field_API_Name__c + '__r').get(applicableConfigInstance.X1st_Child_End_Date_Field_API_Name__c) == null)
                      endDate = startDate;
                  else
                      endDate = Date.valueOf(currentSobj.getSobject(applicableConfigInstance.X1st_Child_Relationship_Field_API_Name__c + '__r').get(applicableConfigInstance.X1st_Child_End_Date_Field_API_Name__c));
                    
                  //Completed? Determination
                    if(currentSobj.getSobject(applicableConfigInstance.X1st_Child_Relationship_Field_API_Name__c + '__r').get(applicableConfigInstance.X1st_Child_Completed_Field_API_Name__c) == true)
                        isGotCompleted = true;
                    else
                        isGotCompleted = false;
                        
                  if (addComma) { ret += ','; }
                      
                    //Color Determination
                    colorASCIICodeStr = colorDeterminationForFirstChild(isGotCompleted, colorASCIICodeStr, startDate, endDate);
                  
                    ret +=   '{'+
                            'id: "' + currentSobj.getSobject(applicableConfigInstance.X1st_Child_Relationship_Field_API_Name__c + '__r').get('id') + '",' + 
                            'name: "' + escapeDoubleQuotes(String.valueOf(currentSobj.getSobject(applicableConfigInstance.X1st_Child_Relationship_Field_API_Name__c + '__r').get(applicableConfigInstance.X1st_Child_Name_Field_API_Name__c))) + '",' +
                            'start: new Date(' + startDate.year() + ',' + (startDate.month()-1) + ',' + startDate.day() + '),' +
                            'end: new Date(' + endDate.year() + ',' + (endDate.month()-1) + ',' + endDate.day() + '),' +
                            'color: "' + colorASCIICodeStr + '",' +
                              'childlevel: "' + 'first' + '"' +
                            '}';
      
                addComma=true;
                
                //Re-initialization
                      colorASCIICodeStr = '';
                  
                  //Loop through sObject records
                  for(sObject curSobj : mapOfParentIdWithChildren.get(parentRecId)) {
                    
                      //Start Date Determination
                      if(curSobj.get(applicableConfigInstance.X2nd_Child_Start_Date_Field_API_Name__c) == null)
                          startDate = Date.today();
                      else
                          startDate = Date.valueOf(curSobj.get(applicableConfigInstance.X2nd_Child_Start_Date_Field_API_Name__c));
                      
                      //End Date Determination
                      if(curSobj.get(applicableConfigInstance.X2nd_Child_End_Date_Field_API_Name__c) == null)
                          endDate = startDate;
                      else
                          endDate = Date.valueOf(curSobj.get(applicableConfigInstance.X2nd_Child_End_Date_Field_API_Name__c));
                    
                    //Completed? Determination
                      if(curSobj.get(applicableConfigInstance.X2nd_Child_Completed_Field_API_Name__c) == true)
                          isGotCompleted = true;
                      else
                          isGotCompleted = false;
                    
                      if (addComma) { ret += ','; }
                          
                      //Color Determination
                      colorASCIICodeStr = colorDeterminationForFirstChild(isGotCompleted, colorASCIICodeStr, startDate, endDate);
                         
                      ret +=   '{'+
                              'id: "' + curSobj.get('id') + '",' + 
                              'name: "' + escapeDoubleQuotes(String.valueOf(curSobj.get(applicableConfigInstance.X2nd_Child_Name_Field_API_Name__c))) + '",' +
                              'start: new Date(' + startDate.year() + ',' + (startDate.month()-1) + ',' + startDate.day() + '),' +
                              'end: new Date(' + endDate.year() + ',' + (endDate.month()-1) + ',' + endDate.day() + '),' +
                              'color: "' + colorASCIICodeStr + '",' +
                                  'childlevel: "' + 'second' + '"' +
                              '}';
                      
                      addComma=true;
                  }
              }
                    
                    ret+=']}];';
                return ret;
              }
              
              //return null    
            return null;  
              
          } else {
              
              //Loop through sObject records
              for(sObject currentSobj : sobjectList) {
                  
                  //Start Date Determination
                  if(currentSobj.get(applicableConfigInstance.X1st_Child_Start_Date_Field_API_Name__c) == null)
                      startDate = Date.today();
                  else
                      startDate = Date.valueOf(currentSobj.get(applicableConfigInstance.X1st_Child_Start_Date_Field_API_Name__c));
                  
                  //End Date Determination
                  if(currentSobj.get(applicableConfigInstance.X1st_Child_End_Date_Field_API_Name__c) == null)
                      endDate = startDate;
                  else
                      endDate = Date.valueOf(currentSobj.get(applicableConfigInstance.X1st_Child_End_Date_Field_API_Name__c));
                  
                  //Completed? Determination
                  if(currentSobj.get(applicableConfigInstance.X1st_Child_Completed_Field_API_Name__c) == true)
                      isGotCompleted = true;
                  else
                      isGotCompleted = false;
                  
                  if (addComma) { ret += ','; }
                      
                  //Color Determination
                  colorASCIICodeStr = colorDeterminationForFirstChild(isGotCompleted, colorASCIICodeStr, startDate, endDate);
                  
                  ret +=   '{'+
                          'id: "' + currentSobj.get('id') + '",' + 
                          'name: "' + escapeDoubleQuotes(String.valueOf(currentSobj.get(applicableConfigInstance.X1st_Child_Name_Field_API_Name__c))) + '",' +
                          'start: new Date(' + startDate.year() + ',' + (startDate.month()-1) + ',' + startDate.day() + '),' +
                          'end: new Date(' + endDate.year() + ',' + (endDate.month()-1) + ',' + endDate.day() + '),' +
                          'color: "' + colorASCIICodeStr + '",' +
                          'childlevel: "' + 'first' + '"' +
                          '}';
                  
                  addComma=true;
                  
              }
                
                ret+=']}];';
              return ret;
            }
            
        } catch(Exception ex) { 
            throw new CustomException('[buildGanttChartJSON] Unable to retrieve data and Line No. is ' + ex.getLineNumber() + ' Error Message is ' + ex.getMessage());
            return null;
        }
    }
    
    public static string getSoqlQuery(sObject metadataObj) {
        
        //Variable to hold the Query literal
        string qry = (string) metadataObj.get('SOQL_Query_Literal_1__c');
        
        if (metadataObj.get('SOQL_Query_Literal_2__c') != null) {
            qry += (string) metadataObj.get('SOQL_Query_Literal_2__c');
        }
        
        if (metadataObj.get('SOQL_Query_Literal_3__c') != null) {
            qry += (string) metadataObj.get('SOQL_Query_Literal_3__c');
        }
        
        if (metadataObj.get('SOQL_Query_Literal_4__c') != null) {
            qry += (string) metadataObj.get('SOQL_Query_Literal_4__c');
        }
        
        //Return query string
        return qry;
    }
    
    private String escapeDoubleQuotes(String word){
        return word.replaceAll(REGEXP_QUOTES,'\\\\"');
  }
    
    //Color Determination for 1st child
    public string colorDeterminationForFirstChild(Boolean isCompleted, String colorStr, Date startDate, Date endDate) {
    
        //Color Determination logic
        if (isCompleted)
      colorStr = applicableConfigInstance.X1st_Child_Completed_Color_ASCII_Code__c;
    else if (endDate < Date.today())
      colorStr = applicableConfigInstance.X1st_Child_Late_Color_ASCII_Code__c;
    else if (startDate > Date.today())
        colorStr = applicableConfigInstance.X1st_Child_Future_Color_ASCII_Code__c;
        else
            colorStr = applicableConfigInstance.X1st_Child_Current_Color_ASCII_Code__c;
        
        //return color ASCII code string
        return colorStr;
  }
    
    //Color Determination for 2nd Child
    public string colorDeterminationForSecondChild(Boolean isCompleted, String colorStr, Date startDate, Date endDate) {
        
        //Color Determination logic
        if (isCompleted)
      colorStr = applicableConfigInstance.X2nd_Child_Completed_Color_ASCII_Code__c;
    else if (endDate < Date.today())
      colorStr = applicableConfigInstance.X2nd_Child_Late_Color_ASCII_Code__c;
    else if (startDate > Date.today())
        colorStr = applicableConfigInstance.X2nd_Child_Future_Color_ASCII_Code__c;
        else
            colorStr = applicableConfigInstance.X2nd_Child_Current_Color_ASCII_Code__c;
      
        //return color ASCII code string
        return colorStr;
    }
    
    //Color Determination for 3rd Child
    public string colorDeterminationForThirdChild(Boolean isCompleted, String colorStr, Date startDate, Date endDate) {
        
        //Color Determination logic
        if (isCompleted)
      colorStr = applicableConfigInstance.X3rd_Child_Completed_Color_ASCII_Code__c;
    else if (endDate < Date.today())
      colorStr = applicableConfigInstance.X3rd_Child_Late_Color_ASCII_Code__c;
    else if (startDate > Date.today())
        colorStr = applicableConfigInstance.X3rd_Child_Future_Color_ASCII_Code__c;
        else
            colorStr = applicableConfigInstance.X3rd_Child_Current_Color_ASCII_Code__c;
    
      //return color ASCII code string
        return colorStr;
        
    }
    
    //Color Deterination for 4th Child
    public string colorDeterminationForFourthChild(Boolean isCompleted, String colorStr, Date startDate, Date endDate) {
      
        //Color Determination logic
        if (isCompleted)
      colorStr = applicableConfigInstance.X4th_Child_Completed_Color_ASCII_Code__c;
    else if (endDate < Date.today())
      colorStr = applicableConfigInstance.X4th_Child_Late_Color_ASCII_Code__c;
    else if (startDate > Date.today())
        colorStr = applicableConfigInstance.X4th_Child_Future_Color_ASCII_Code__c;
        else
            colorStr = applicableConfigInstance.X4th_Child_Current_Color_ASCII_Code__c;
        
        //return color ASCII code string
        return colorStr;
    }    
}