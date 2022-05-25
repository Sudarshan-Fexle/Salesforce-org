/**
 *  @description    :   helper class to make accessing value -> Color codes easy
 * 
 *  @revision log	:	09/27/2019 - Victor Hanson - Created - CR-20181208-12776
 * 
**/
public class ValueToColorHelper {
	
    /**
     *  @description    :   get map of fieldValue -> colorCode__mdt
     * 
     *  @args           :   String, String
     * 
     *  @return         :   Map<String, Value_to_Color_Code__mdt>
     * 
     *  @revision log	:	09/27/2019 - Victor Hanson - Created
     * 
    **/ 
    public static Map<String, Value_to_Color_Code__mdt> getValueToColorCodeMap(String sObjAPIName, String fieldAPIName) {
        Map<String, Value_to_Color_Code__mdt> valueToColorCodeMap = new Map<String, Value_to_Color_Code__mdt>();
        for (Value_to_Color_Code__mdt valToColorCode : [SELECT Id, Field_Value__c, HTML_Color_Code__c, Display_Value__c
                                                        FROM Value_to_Color_Code__mdt 
                                                        WHERE Field_Reference__r.Object__c = :sObjAPIName AND Field_Reference__r.Field_API_Name__c = :fieldAPIName]) 
        {
            valueToColorCodeMap.put(valToColorCode.Field_Value__c, valToColorCode);
        }
        
        return valueToColorCodeMap;
    }
    
    /**
     *  @description    :   get map of fieldValue -> color
     * 
     *  @args           :   String, String
     * 
     *  @return         :   Map<String, String>
     * 
     *  @revision log	:	09/27/2019 - Victor Hanson - Created
     * 
    **/ 
    public static Map<String, String> getValueToHTMLColorMap(String sObjAPIName, String fieldAPIName) {
        Map<String, String> valueToHTMLColorMap = new Map<String, String>();
        for (Value_to_Color_Code__mdt valToColorCode : [SELECT Id, Field_Value__c, HTML_Color_Code__c, Display_Value__c
                                                        FROM Value_to_Color_Code__mdt 
                                                        WHERE Field_Reference__r.Object__c = :sObjAPIName AND Field_Reference__r.Field_API_Name__c = :fieldAPIName]) 
        {
            valueToHTMLColorMap.put(valToColorCode.Field_Value__c, valToColorCode.HTML_Color_Code__c);
        }
        
        return valueToHTMLColorMap;
    }
    
}