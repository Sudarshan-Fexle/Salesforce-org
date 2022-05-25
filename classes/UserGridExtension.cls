/**
*  Description     :  Helper class for the userGrid LWC
*
*  Revision Logs   :  V_1.0 - 09/20/2019 - Victor Hanson - Created
*                     V_1.1 - Updated By - Abhinav Sharma - 08/18/2020 - Add the logic to show all the stretegic leader even if have duplicated user as field value.
**/
public without sharing class UserGridExtension {
    
    //constructor
    public UserGridExtension() {}
    
/**
*  Description     :	get user list
* 
*  Return Type	   :	List<userWrapper>
*
*  Revision Logs   :	09/20/2019 - Victor Hanson - Created
                        Updated By - Abhinav Sharma - 08/18/2020 - Add the logic to show all the stretegic leader even if have duplicated user as field value.
**/
    @AuraEnabled(cacheable=true)
    public static List<userWrapper> getUserList(Id recordId, String fieldAPINamesCSV, String fieldLabelMap) 
    {
        List<userWrapper> userWrappers = new List<userWrapper>();
        Set<String> userIds = new Set<String>();
        String qryString = 'SELECT Id,' + fieldAPINamesCSV + ' FROM ' + recordId.getSObjectType() + ' WHERE Id = :recordId';
        List<SObject> objList = database.query(qryString);
        if (objList.size() > 0) 
        {
            //get the map of field api names to label
            Map<String, String> fLabelMap = new Map<String, String>();
            Map<String, List<String>> IdToFieldMap = new Map<String, List<String>>();
            if (fieldLabelMap != null) 
            {
                try 
                {
                    fLabelMap = (Map<String, String>)JSON.deserialize(fieldLabelMap.replaceAll('\'', '"'), Map<String, String>.class);
                }
                catch(Exception e) 
                {
                    system.debug('@@EXCEPTION:' + e.getMessage() + '\r\n' + e.getStackTraceString());
                }
            }
            SObject sobj = objList[0];
           
            for (String fieldName : fieldAPINamesCSV.split(',')) 
            {
                if (sobj.get(fieldName) != null) 
                {
                    userIds.add((String)sobj.get(fieldName) );
                    if(!IdToFieldMap.containskey((String)sobj.get(fieldName)))
                    {
                        IdToFieldMap.put((String)sobj.get(fieldName), new List<String>{});
                    }
                    IdToFieldMap.get((String)sobj.get(fieldName)).add(fieldName); //ie: Map<[ContactID], List[FieldName]>
                }
            }
 
            if (userIds.size() > 0) 
            {
                Map<Id,User> mapOfUsers = new Map<Id,User>([SELECT Id, FullPhotoUrl, Email, Name, Slack_Id__c 
                                                            FROM User 
                                                            WHERE Id IN :IdToFieldMap.keyset()]);
                
                if(mapOfUsers.values().size() > 0)
                {
                    for(String userId : userIds)
                    {
                        if(IdToFieldMap.containskey(userId))
                        {
                            for(String fieldName : IdToFieldMap.get(userId))
                            {
                                //get the field name this user corresponds with
                                String label = fLabelMap.get(fieldName);
                                userWrappers.add(new userWrapper(mapOfUsers.get(userId), label));
                            } 
                        } 
                    }
                        
                }
            }
        }
        if(userWrappers.size() > 0) 
        {
            system.debug('userWrappers before sort --- '+ userWrappers);
            userWrappers.sort();
            system.debug('userWrappers After sort --- '+ userWrappers);
        }
        return userWrappers;
    }
}