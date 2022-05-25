/**
*  Description      :   GanttView_At_PackageDetailController Class
*
*  Created By       :   Simplyforce Hackathon Team (The Brain Trust)
*
*  Created Date     :   04/22/2017
*
*  Revision Logs    :   V_1.0 - Created - Simplyforce Hackathon Team (The Brain Trust)
*
**/
public with sharing class GanttView_At_PackageDetailController {

	public String packageId {get;set;}
	public Boolean allowView {get;set;}
    
    public Gantt_View_Manager__mdt applicableConfigInstance {get; set;}
	
	//Variable to hold the order value
    public Integer orderNumber {get; set;}
    public List<SelectOption> orderOptions {get; set;}
    
	//Gantt Chart Configuration Manager
    public Map<String, List<Gantt_View_Manager__mdt>> mapOfGanttManagerConfigurationManager {
        get {
            if (mapOfGanttManagerConfigurationManager == null) {
                
                //Memory allocation
                mapOfGanttManagerConfigurationManager = new Map<String, List<Gantt_View_Manager__mdt>>();
                
                String sObjectName = ID.valueOf(packageId).getSobjectType().getDescribe().getName().toLowerCase();
                
                //Loop through gantt chart metadata records
                for(Gantt_View_Manager__mdt gCCM : [SELECT Id, Label, X1st_Child_End_Date_Field_API_Name__c, X1st_Child_Name_Field_API_Name__c,
                												X1st_Child_Object_API_Name__c, X1st_Child_Start_Date_Field_API_Name__c, 
                												X2nd_Child_End_Date_Field_API_Name__c, X2nd_Child_Name_Field_API_Name__c,
                												X2nd_Child_Object_API_Name__c, X2nd_Child_Start_Date_Field_API_Name__c, 
                												X3rd_Child_End_Date_Field_API_Name__c,X3rd_Child_Name_Field_API_Name__c, 
                												X3rd_Child_Object_API_Name__c, X3rd_Child_Start_Date_Field_API_Name__c,
                												X4th_Child_End_Date_Field_API_Name__c, X4th_Child_Name_Field_API_Name__c, 
                												X4th_Child_Object_API_Name__c, X4th_Child_Start_Date_Field_API_Name__c,
                												Multi_Level__c, Parent_Object_API_Name__c, Order__c, SOQL_Query_Literal_1__c, 
                												SOQL_Query_Literal_2__c, SOQL_Query_Literal_3__c, SOQL_Query_Literal_4__c,
                                                    			X1st_Child_Completed_Color_ASCII_Code__c, X1st_Child_Current_Color_ASCII_Code__c,
                                                    			X1st_Child_Future_Color_ASCII_Code__c, X1st_Child_Late_Color_ASCII_Code__c,
                                                    			X2nd_Child_Completed_Color_ASCII_Code__c, X2nd_Child_Current_Color_ASCII_Code__c,
                                                    			X2nd_Child_Future_Color_ASCII_Code__c, X2nd_Child_Late_Color_ASCII_Code__c,
                                                    			X3rd_Child_Completed_Color_ASCII_Code__c, X3rd_Child_Current_Color_ASCII_Code__c,
                                                    			X3rd_Child_Future_Color_ASCII_Code__c, X3rd_Child_Late_Color_ASCII_Code__c,
                                                    			X4th_Child_Completed_Color_ASCII_Code__c, X4th_Child_Current_Color_ASCII_Code__c,
                                                    			X4th_Child_Future_Color_ASCII_Code__c, X4th_Child_Late_Color_ASCII_Code__c,
                                                    			X1st_Child_Completed_Field_API_Name__c, X2nd_Child_Completed_Field_API_Name__c,
                                                    			X3rd_Child_Completed_Field_API_Name__c, X4th_Child_Completed_Field_API_Name__c,
                                                    			Order_By_Field_API_Name__c, Sort_Order_Type__c, X1st_Child_Object_Is_A_Custom_Object__c,
                                                    			X2nd_Child_Object_Is_A_Custom_Object__c, X3rd_Child_Object_Is_A_Custom_Object__c,
                                                    			X4th_Child_Object_Is_A_Custom_Object__c, X1st_Child_Relationship_Field_API_Name__c,
                                                    			X2nd_Child_Relationship_Field_API_Name__c, X3rd_Child_Relationship_Field_API_Name__c
                												FROM Gantt_View_Manager__mdt 
                                                                WHERE Parent_Object_API_Name__c != null
                                                    			AND Parent_Object_API_Name__c =: sObjectName
                                                                ORDER By Order__c ASC NULLS LAST]) {
                                                                   
        			if(mapOfGanttManagerConfigurationManager.containsKey(gCCM.Parent_Object_API_Name__c.toLowerCase()))
         				mapOfGanttManagerConfigurationManager.get(gCCM.Parent_Object_API_Name__c.toLowerCase()).add(gCCM);
        			else
          				mapOfGanttManagerConfigurationManager.put(gCCM.Parent_Object_API_Name__c.toLowerCase(), new List<Gantt_View_Manager__mdt>{gCCM}); 
            	
                	//Populating selection options list
                	if(gCCM.Order__c != null && String.isNotBlank(gCCM.Label))    
                		orderOptions.add(new SelectOption(String.valueOf(gCCM.Order__c), gCCM.Label));                                                
            	}
            }
            return mapOfGanttManagerConfigurationManager;
        }
        set;
    }
	    
	public GanttView_At_PackageDetailController(ApexPages.StandardController stc){
		packageId = stc.getId();
        allowView = Apexpages.currentPage().getParameters().get('p') == null;
        orderOptions = new List<SelectOption>(); 
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
       If(packageId != null) {
            applicableConfigInstance = new Gantt_View_Manager__mdt();
            populateAttributes();
        }
    }
	
    //Method to set various attributes with desired values
    private void populateAttributes() {
        
        //Checking for null/blank value
        if(String.isNotBlank(packageId) && packageId instanceOf ID) {
            
            //sObject Name in lowercase
            String sObjectName = ID.valueOf(packageId).getSobjectType().getDescribe().getName().toLowerCase();
            
            //Checking for key existance in the map
            if(mapOfGanttManagerConfigurationManager.containsKey(sObjectName) 
            	&& mapOfGanttManagerConfigurationManager.get(sObjectName) != null) {
            	
                //If order is not specified while passing the value to the gantt chart component
                //Go with record having order = 1 for the specified object
                if(orderNumber == null) {
                	if(mapOfGanttManagerConfigurationManager.get(sObjectName)[0].Order__c != null
               			&& mapOfGanttManagerConfigurationManager.get(sObjectName)[0].Order__c == 1)
                        applicableConfigInstance = mapOfGanttManagerConfigurationManager.get(sObjectName)[0];
            	} else {
                    for(Gantt_View_Manager__mdt gCC : mapOfGanttManagerConfigurationManager.get(sObjectName)) {
                        if(gCC.Order__c != null && gCC.Order__c == orderNumber)
                			applicableConfigInstance = gCC;
                	}
               	}
            }
        } else {
        	throw new CustomException('[populateAttributes] Unable to generate JSON for ' + packageId);
        }
    }
}