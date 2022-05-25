/**
*  Description      :   Class to hold the Utility methods related to the "Mass Create Bundle Opportunity" functionality.
*
*  Created By       :   Abhinav Sharma
*
*  Created Date     :   09/15/2014
*
*  Revision Logs    :   V_1.0 - Created - CR-20140429-5272
*
**/
public class MassCreateBundleOppUtility {
    
    /**
    *   @description    :  Method to get opportunity Stage field picklsit values.
    *
    *   @args           :  String sOQLString
    *
    *   @return         :  string 
    *
    **/
    public static Map<String, Integer> mapOpportunityStages() {
    
        //Set to hold the stages
        Map<String, Integer> mapOfStages = new Map<String, Integer>();
  
        //This is some generic code to retrieve the current stage names using
        //Dynamic Apex in case the Stage Names change in the future
        Schema.DescribeFieldResult F = Opportunity.StageName.getDescribe();
        List<schema.picklistentry> typeList = F.getPicklistValues();
        
        //Integer variable
        Integer cnt = 1;
        
        //Populating select option list with options
        for (Schema.PicklistEntry typeItem : typeList) {
            mapOfStages.put(typeItem.getValue(), cnt);
            cnt++;    
        }
        
        //Debugging for the values
        System.debug('@@@@@@@ mapOfStages ' + mapOfStages);
        
        //Returning stage values
        return mapOfStages; 
    }
    
    //Added By - Abhinav Sharma - 09/15/2014 - CR-20140429-5272
    /**
    *   @description    :  Method to retrieve out the corresponding probability value for the selected opportunity stage.
    *
    *   @args           :  String stageName
    *
    *   @return         :  Decimal 
    *
    **/
    public static Decimal retrievingProbabilityForOpportunityStage(String stageName) {

        //Checking string variable for blank/null value
        if(String.isNotBlank(stageName)) {

            // The user changed the Opportunity StageName. 
            //Set the Probability to the correct value, based on the defaults set up in the OpportunityStage object.
            transient Map<String, Decimal> probabilityStageNameMap;

            //Checking map for null value
            if (probabilityStageNameMap == null) {
                probabilityStageNameMap = new Map<String, Decimal>();

            //Loop through opportunity stages and populating map with correct combination of the values
            for (OpportunityStage oppStage : [Select MasterLabel, DefaultProbability From OpportunityStage WHERE IsActive = true]) {
                probabilityStageNameMap.put(oppStage.MasterLabel, oppStage.DefaultProbability);
            }

            //Checking for value in the map
            if (probabilityStageNameMap != null && probabilityStageNameMap.get(stageName) != null)
                return probabilityStageNameMap.get(stageName);
            }
        }

        //Returning null value in case no valid selection found for stageName
        return null;
    }
    
    //Added By - Abhinav Sharma - 09/16/2014 - CR-20140429-5272
    /**
    *   @description    :   Method to dynamically build the SOQL Query string for the opportunity fields.
    *
    *   @args           :   void
    *
    *   @return         :   string
    *
    **/
    public static String dynamicBuildingOpportunityQueryString() {
    
        //Dynamically fetching Opportunities fields
        Map<String, Schema.SObjectField> opportunityFieldsMap = Schema.SObjectType.Opportunity.fields.getMap();
        List<Schema.SObjectField> opportunityFieldsMapValues = opportunityFieldsMap.values();

        //String to hold the dynamic query
        String theQuery = 'SELECT ';

        //Loop through opportunity fields and building query string with the help of it
        for(Schema.SObjectField s : opportunityFieldsMapValues) {
            if(((s.getDescribe().isAccessible()) || s.getDescribe().isUpdateable()) && !s.getDescribe().isCalculated())
                theQuery += s.getDescribe().getName() + ',';
        }
        
        
        
        // Trim last comma
        theQuery = theQuery.subString(0, theQuery.length() - 1);
        
        // Finalize query string
        theQuery += ' FROM Opportunity ';
        return theQuery; 
    }
}