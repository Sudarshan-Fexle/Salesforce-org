/**
*  Description     :    Class is used to convert jSon Data in map of sObject form
*
*  Created Date    :    09/22/2021
* 
*  Revision Logs   :    V_1.0 - Created By - Mahendar Swarnkar - CR-20210909-15418
*/
public without sharing class CreateCatalystTestDataRecordUtil {
    
    
    /**
    *  @description    :  This method is used to convert json data in map of string and sobject form                                          
    * 
    *  @args           :   string jSONString, String objectName
    * 
    *  @return         :   Map<String, sObject>
    * 
    *  @revision Log   :   V1.0 - Created By - Mahendar Swarnkar - 09/22/2021 - CR-20210909-15418
    * 
    * */
    public static Map<String, sObject> parseJSONstring(string jSONString, String objectName)
    {
        Map<String, Sobject> maprecordUniqueKeyWithRecords = new Map<String, sObject>();
        if(jSONString != null && String.isNotBlank(jSONString) && objectName != null && String.isNotBlank(objectName))
        {
         maprecordUniqueKeyWithRecords = (Map<String, Sobject>)Json.deserializeStrict(jSONString, Type.forName('Map<String,'+objectName+'>'));
        }
        return maprecordUniqueKeyWithRecords;
    }
}