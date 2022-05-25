public class Change_Objects_Permission {
    
    public static String permissionText;
    public static String packageText;
    public static void createPermissionNode(){
        
        Map<String, String> mapObjPluralWithAPIName = new Map<String, String>();
        Map<String, String> mapObjApiNameWithPermission = new Map<String, String>();
        Map<String, Schema.SObjectType> globalSchemaDesc = Schema.getGlobalDescribe();
        
        for ( Schema.SObjectType obj : Schema.getGlobalDescribe().values() )
        {
            Schema.DescribeSObjectResult objResult = obj.getDescribe();
            mapObjPluralWithAPIName.put(objResult.getLabelPlural(), objResult.getName());
        }
        
        for(String objPluralName : Change_Objects_Permission_Constants.LIST_Of_OBJECTS_WITH_PERMISSION.keySet()){
            
            if(mapObjPluralWithAPIName.containsKey(objPluralName))
                mapObjApiNameWithPermission.put(mapObjPluralWithAPIName.get(objPluralName), 
                                               Change_Objects_Permission_Constants.LIST_Of_OBJECTS_WITH_PERMISSION.get(objPluralName));
        }
        
        //createNode(mapObjApiNameWithPermission);
    }
    
    public static void createNode(Map<String, String> mapObjApiNameWithPermission, List<String> profiles){
        
        //
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        
        permissionText = '<?xml version="1.0" encoding="UTF-8"?> \n';
        permissionText += '<Profile xmlns="http://soap.sforce.com/2006/04/metadata"> \n';
        permissionText += '\t<custom>true</custom> \n';
        packageText = '<?xml version="1.0" encoding="UTF-8"?> \n';
        packageText += '<Package xmlns="http://soap.sforce.com/2006/04/metadata"> \n';
        packageText += '\t<types>\n';

        for(String profile : profiles) {

            for(String objName : mapObjApiNameWithPermission.keySet()){
                
                //Call a method for required Permission
                permissionText  += setRequiredPermission(objName, mapObjApiNameWithPermission.get(objName));
            }
            packageText  += '\t\t<members>'+profile+'</members> \n';
            
            /*permissionText += '\t <userPermissions> \n';
            permissionText += '\t\t <enabled>true</enabled> \n';
            permissionText += '\t\t <name>ViewAllData</name> \n';
            permissionText += '\t </userPermissions> \n'; */
            permissionText += '</Profile>';
            
            Messaging.Emailfileattachment efa1= new Messaging.Emailfileattachment();
            efa1.setContentType('text/plain');
            efa1.setFileName('abc.profile');
            efa1.setBody(Blob.valueOf(permissionText));
            fileAttachments.add(efa1);
        }
        
        packageText += '\t\t<name>Profile</name> \n';
        packageText += '\t</types>\n';
        packageText += '\t<version>37.0</version>\n';
        packageText += '</Package>\n';
        
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setContentType('text/plain');
        efa.setFileName('package.xml');
        efa.setBody(Blob.valueOf(packageText));
        fileAttachments.add(efa);
        
        //List of SingleEmailMessage
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        //Instance of SingleEmailMessage
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        //Set to address (Receiver)
        mail.setToAddresses(new List <String> { UserInfo.getUserEmail() });
        
        //Set subject
        mail.setSubject('Permissions');
        
        String mailBody = 'Hi '+UserInfo.getFirstName()+', <br><br>';
        mailBody += 'Please find the attached package file. <br><br><br>';
        
        mailBody += 'Thank You!';
        
        //Set mail body
        mail.setHtmlBody(mailBody);
        
        mail.setFileAttachments(fileAttachments);
        
        //Mail add to list
        mails.add(mail);
        
        //Send email
        Messaging.sendEmail(mails);
    }
    //Add permission for a particluar object
    public static String setRequiredPermission(String ObjectAPIName, String Permission) {

        //Set to hold permission
        Set<String> setPermission = new Set<String>();
        setPermission.addAll(Permission.split(','));
 
        permissionText += '\t <objectPermissions> \n';

        if(setPermission.contains('No Access')) {
            
            //
            permissionText += '\t\t<allowCreate>false</allowCreate>\n';
            permissionText += '\t\t<allowEdit>false</allowDelete>\n';
            permissionText += '\t\t<allowread>false</allowDelete>\n';
            permissionText += '\t\t<allowDelete>false</allowDelete>\n';
            permissionText += '\t\t<modifyAllRecords>false</allowDelete>\n';
            
        } else {

                //Check for create access
                if(setPermission.contains('create'))
                    permissionText += '\t\t<allowCreate>true</allowCreate>\n';
                else
                    permissionText += '\t\t<allowCreate>false</allowCreate>\n';
    
                if(setPermission.contains('delete'))
                    permissionText += '\t\t<allowDelete>true</allowDelete>\n';
                else 
                    permissionText += '\t\t<allowDelete>false</allowDelete>\n';
                if(setPermission.contains('edit'))
                    permissionText += '\t\t<allowEdit>true</allowEdit>\n';
                else
                    permissionText += '\t\t<allowEdit>false</allowEdit>\n';
                if(setPermission.contains('read'))
                    permissionText += '\t\t<allowRead>false</allowRead>\n';
                else
                    permissionText += '\t\t<allowRead>false</allowRead>\n';
                if(setPermission.contains('Modify All'))
                    permissionText += '\t\t<modifyAllRecords>true</modifyAllRecords>\n';
                else 
                    permissionText += '\t\t<modifyAllRecords>false</modifyAllRecords>\n';

            }
            permissionText += '\t\t<object>'+ObjectAPIName+'</object>\n';
            if(setPermission.contains('View All'))
                permissionText += '\t\t<viewAllRecords>true</viewAllRecords>\n';
            else
                permissionText += '\t\t<viewAllRecords>false</viewAllRecords>\n';
    
            permissionText += '\t </objectPermissions> \n';
      
        return permissionText;
    }
}