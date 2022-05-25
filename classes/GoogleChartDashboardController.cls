/**
*  Description      :   Controller class for Google Chart Dashboard.
*
*  Created By       :   Simplyforce Hackathon Team (The Brain Trust) [Abhinav, Subhash, Deepak, Abhishek and Jatin]
*
*  Created Date     :   04/22/2017
*
*  Revision Logs    :   V_1.0 - Created - Simplyforce Hackathon Team (The Brain Trust) [Primary Owner = Abhinav]
*
**/
public class GoogleChartDashboardController {
    
    //Properties
    public transient ID packageId {get; set;}
    public transient List<GoogleChartWrapper> googleChartWrappers {get; set;}
    
    //Constructor
    public GoogleChartDashboardController(ApexPages.StandardController stc){
        
        //Get the targetId 
        packageId = stc.getId();
        googleChartWrappers = new List<GoogleChartWrapper>();
    }
    
    //Chart Manager mdt 
    public Map<Integer, List<Chart_Manager__mdt>> mapOfOrderWithChartManagerMetaData {
        get {
        
            if (mapOfOrderWithChartManagerMetaData == null) {

                //Memory allocation
                mapOfOrderWithChartManagerMetaData = new Map<Integer, List<Chart_Manager__mdt>>();
                transient String sObjectTypeName = packageId.getSobjectType().getDescribe().getName().toLowerCase().trim();

                //Loop through gantt chart metadata records
                for(Chart_Manager__mdt cMM : [SELECT Id, Label, X10th_Field_API_Name__c, 
                                              X10th_Field_Chart_Title__c, X11th_Field_API_Name__c, 
                                              X11th_Field_Chart_Title__c, X12th_Field_API_Name__c, 
                                              X12th_Field_Chart_Title__c, X1st_Field_API_Name__c, 
                                              X1st_Field_Chart_Title__c, X2nd_Field_API_Name__c, 
                                              X2nd_Field_Chart_Title__c, X3rd_Field_API_Name__c, 
                                              X3rd_Field_Chart_Title__c, X4th_Field_API_Name__c,
                                              X4th_Field_Chart_Title__c, X5th_Field_API_Name__c, 
                                              X5th_Field_Chart_Title__c, X6th_Field_API_Name__c, 
                                              X6th_Field_Chart_Title__c, X7th_Field_API_Name__c, 
                                              X7th_Field_Chart_Title__c, X8th_Field_API_Name__c, 
                                              X8th_Field_Chart_Title__c, X9th_Field_API_Name__c, 
                                              X9th_Field_Chart_Title__c, Chart_Main_Title__c, Chart_Type__c, Order__c, 
                                              Parent_Object_API_Name__c, Row_Number__c, Active__c
                        FROM Chart_Manager__mdt 
                                              WHERE Parent_Object_API_Name__c != null
                                              AND Parent_Object_API_Name__c =: sObjectTypeName
                                              AND Row_Number__c != null
                                              AND Order__c != null AND Active__c = true
                                              ORDER By Order__c ASC]) {
                    if(mapOfOrderWithChartManagerMetaData.containsKey(Integer.valueOf(cMM.Row_Number__c)))
                        mapOfOrderWithChartManagerMetaData.get(Integer.valueOf(cMM.Row_Number__c)).add(cMM);
                    else
                        mapOfOrderWithChartManagerMetaData.put(Integer.valueOf(cMM.Row_Number__c), new List<Chart_Manager__mdt>{cMM});
                                                  
                    //Google Wrapper
                    transient GoogleChartWrapper googleChartWrapper = new GoogleChartWrapper();
                                                    
                    //Populating map with fields API Names and field Title
                    if(String.isNotBlank(cMM.X1st_Field_API_Name__c)) {
                        googleChartWrapper.firstFieldAPINameStr = cMM.X1st_Field_API_Name__c;
                        googleChartWrapper.firstFieldChartTitle = cMM.X1st_Field_Chart_Title__c;
                    }
                                                    
                    //Populating map with fields API Names and field Title
                    if(String.isNotBlank(cMM.X2nd_Field_API_Name__c)) {
                        googleChartWrapper.secondFieldAPINameStr = cMM.X2nd_Field_API_Name__c;
                        googleChartWrapper.secondFieldChartTitle = cMM.X2nd_Field_Chart_Title__c;
                    }
                                                    
                    //Populating map with fields API Names and field Title
                    if(String.isNotBlank(cMM.X3rd_Field_API_Name__c)) {
                        googleChartWrapper.thirdFieldAPINameStr = cMM.X3rd_Field_API_Name__c;
                        googleChartWrapper.thirdFieldChartTitle = cMM.X3rd_Field_Chart_Title__c;
                    }
                                                    
                    //Populating map with fields API Names and field Title
                    if(String.isNotBlank(cMM.X4th_Field_API_Name__c)) {
                        googleChartWrapper.fourthFieldAPINameStr = cMM.X4th_Field_API_Name__c;
                        googleChartWrapper.fourthFieldChartTitle = cMM.X4th_Field_Chart_Title__c;
                    }
                                                    
                    //Populating map with fields API Names and field Title
                    if(String.isNotBlank(cMM.X5th_Field_API_Name__c)) {
                        googleChartWrapper.fifthFieldAPINameStr = cMM.X5th_Field_API_Name__c;
                        googleChartWrapper.fifthFieldChartTitle = cMM.X5th_Field_Chart_Title__c;
                    }
                                                  
                    //Populating map with fields API Names and field Title
                    if(String.isNotBlank(cMM.X6th_Field_API_Name__c)) {
                        googleChartWrapper.sixthFieldAPINameStr = cMM.X6th_Field_API_Name__c;
                        googleChartWrapper.sixthFieldChartTitle = cMM.X6th_Field_Chart_Title__c;
                    }
                                                  
                    //Populating map with fields API Names and field Title
                    if(String.isNotBlank(cMM.X7th_Field_API_Name__c)) {
                        googleChartWrapper.seventhFieldAPINameStr = cMM.X7th_Field_API_Name__c;
                        googleChartWrapper.seventhFieldChartTitle = cMM.X7th_Field_Chart_Title__c;
                    }
                                                  
                    //Populating map with fields API Names and field Title
                    if(String.isNotBlank(cMM.X8th_Field_API_Name__c)) {
                        googleChartWrapper.eightFieldAPINameStr = cMM.X8th_Field_API_Name__c;
                        googleChartWrapper.eightFieldChartTitle = cMM.X8th_Field_Chart_Title__c;
                    }
                                                  
                    //Populating map with fields API Names and field Title
                    if(String.isNotBlank(cMM.X9th_Field_API_Name__c)) {
                        googleChartWrapper.ninthFieldAPINameStr = cMM.X9th_Field_API_Name__c;
                        googleChartWrapper.ninthFieldChartTitle = cMM.X9th_Field_Chart_Title__c;
                    }
                                                  
                    //Populating map with fields API Names and field Title
                    if(String.isNotBlank(cMM.X10th_Field_API_Name__c)) {
                        googleChartWrapper.tenthFieldAPINameStr = cMM.X10th_Field_API_Name__c;
                        googleChartWrapper.tenthFieldChartTitle = cMM.X10th_Field_Chart_Title__c;
                    }
                                                  
                    //Populating map with fields API Names and field Title
                    if(String.isNotBlank(cMM.X11th_Field_API_Name__c)) {
                        googleChartWrapper.eleventhFieldAPINameStr = cMM.X11th_Field_API_Name__c;
                        googleChartWrapper.eleventhFieldChartTitle = cMM.X11th_Field_Chart_Title__c;
                    }
                                                  
                    //Populating map with fields API Names and field Title
                    if(String.isNotBlank(cMM.X12th_Field_API_Name__c)) {
                        googleChartWrapper.twelveFieldAPINameStr = cMM.X12th_Field_API_Name__c;
                        googleChartWrapper.twelveFieldChartTitle = cMM.X12th_Field_Chart_Title__c;
                    }
                    
                    googleChartWrapper.chartMainTitle = cMM.Chart_Main_Title__c;
                                                    
                    googleChartWrappers.add(googleChartWrapper); 
                }
            }
            
            return mapOfOrderWithChartManagerMetaData;
        }
        set;
    }  
}