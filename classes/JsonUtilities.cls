/**
 *  Purpose         :   Utilities class for common manipulation of json format data
 *
 *  Create By       :  
 *
 *  Created Date    :   
 *
 *  Revision Log    :   V_1.0 Created - CR-20210128-14854
 * 
 *
 */
public with sharing class JsonUtilities {

    public class JsonUtilException extends Exception {}
    
    private static final String JSON_DESERIALIZATION_ERROR = 'Could not deserialize JSON';
    private static final String DOUBLE_QUOTE = '"';
    private static final String DOUBLE_QUOTE_COLON = DOUBLE_QUOTE + ':';
    private static final String REGULAR_EXPRESSION = '"\\s{0,}:';
    
    public static String replaceFields(String json, Map<String, String> fieldsToReplace) {
        try 
        {
            // In some cases, external APIs may use APEX keywords as field names. To make deserialization easier these fields can be renamed using this map.
            if (fieldsToReplace != null)
            {
                Set<String> fields = fieldsToReplace.keySet();
                for (String field : fields)
                {
                    String replacement = fieldsToReplace.get(field);
                    json = json.replaceAll(DOUBLE_QUOTE + field + REGULAR_EXPRESSION, DOUBLE_QUOTE + replacement + DOUBLE_QUOTE_COLON);
                }
            }
            
            return json;
        }
        catch (Exception e)
        {
            System.debug(LoggingLevel.ERROR, json);
            throw new customException(JSON_DESERIALIZATION_ERROR, e);
        }
    }
}