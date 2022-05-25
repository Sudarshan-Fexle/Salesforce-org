/*
*   Description     :   This class is used to handle operations on deployment package file.
*
*   Created by      :   Saurabh Kumar
*
*   Created Date    :   04/22/2017
*
*   Revision Log    :   V1.0 Created
*                   :   V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/28/2017. Improve the functionality
*          :  V1.2 - Modifird by Rajeev Jain - OneClick Enhancments Release - 04/11/2018 - Made Counter Variables visible to utilize in OneCLick deployment wizard App.
*          :   V1.3 - Modified by - Dipesh Gupta - 04/01/2019 - Added the deletion mods.            
*/
public with sharing class PackageFileHelper {
    
    //Map to hold key = Object type and value = List of Components corresponding to object type
    Map<String, List<IS_System_Modification__c>> mapOfObjectTypeAndModifications;
    
    //Variable to hold the number of component 
    public Integer numberOfAddedLines {get;set;}
    
    //Variable to hold any user information
    public String information {get; set;}
    
    //V1.2 - Modifird by Rajeev Jain
    //Variable to hold number of modification
    public Integer noOfModification;
    
    //Global variable to hold subject of the mail
    String subject;

    //V1.2 - Modifird by Rajeev Jain
    //Variable to hold number of quered modification
    public Integer numberOfQueredModification;
    
    //V1.2 - Modifird by Rajeev Jain
    //Variable to hold number of duplicate components
    public Integer numberOfDuplicates;
    
    /*
    *   Description     :   Constructor
    *
    *   Created by      :   Saurabh Kumar
    *
    *   Created Date    :   04/22/2017
    *
    *   @args           :   Set of Releases
                            Set of Change Request
                            Set of Modifications
                            Set of CR status which should not include in package file
                            Set of Change Requests which should not include in package file
                            Set of Modifications which should not include
    *
    *   Revision Log    :   V1.0 Created
    */
    public PackageFileHelper(Set<String> setOfReleases, Set<String> setOfCRs, Set<String> setOfMods, Set<String> ignoredCrStatus, 
                            Set<String> ignoredCRs, Set<String> ignoredMods, Boolean isDeletionPackageNeeded){
        
        numberOfAddedLines = 0;
        information = '';
        noOfModification = 0;
        numberOfQueredModification = 0;
        numberOfDuplicates = 0;
        

        System.debug('setOfReleases-----'+setOfReleases);
        System.debug('setOfCRs-------'+setOfCRs);
        System.debug('setOfMods-------'+setOfMods);
        System.debug('ignoredCrStatus----'+ignoredCrStatus);
        System.debug('ignoredCRs-----'+ignoredCRs);
        System.debug('ignoredMods-----'+ignoredMods);
        System.debug('isDeletionPackageNeeded-----'+isDeletionPackageNeeded);

        
        

        //List to hold Is System Component
        List<IS_System_Modification__c> isSystemModifications = new List<IS_System_Modification__c>();
        
        //Check for the Deletion.
        if(isDeletionPackageNeeded) {
                                    
            //Quesry on Is System Modification based on release name
            isSystemModifications = [Select Id, Name, IS_System_Component__r.Object_API_Name__c, IS_System_Component__r.Object_Type__c, 
                                     IS_System_Component__r.Parent_API_Name__c, IS_System_Component__r.Item_API_Name__c From IS_System_Modification__c 
                                     Where Include_in_Change_Set__c = true AND Type_of_Modification__c = 'Delete'
                                     AND Delete_from_Design__c = false 
                                     AND CR_Status__c NOT IN : ignoredCrStatus
                                     AND Change_Request__r.Name NOT IN : ignoredCRs
                                     AND Name NOT IN :ignoredMods
                                     AND ((Release__c IN : setOfReleases AND Release__c != NULL)
                                          OR (Change_Request__r.Name IN : setOfCRs AND Change_Request__c != NULL)
                                          OR (Name IN : setOfMods AND Name != null)) ];
            }else {
                                    
          //Quesry on Is System Modification based on release name
            isSystemModifications = [Select Id, Name, IS_System_Component__r.Object_API_Name__c, IS_System_Component__r.Object_Type__c, 
                                     IS_System_Component__r.Parent_API_Name__c, IS_System_Component__r.Item_API_Name__c From IS_System_Modification__c 
                                     Where Include_in_Change_Set__c = true AND Type_of_Modification__c != 'Delete'
                                     AND Delete_from_Design__c = false 
                                     AND CR_Status__c NOT IN : ignoredCrStatus
                                     AND Change_Request__r.Name NOT IN : ignoredCRs
                                     AND Name NOT IN :ignoredMods
                                     AND ((Release__c IN : setOfReleases AND Release__c != NULL)
                                          OR (Change_Request__r.Name IN : setOfCRs AND Change_Request__c != NULL)
                                          OR (Name IN : setOfMods AND Name != null)) ];
         }
                                   
                                
         System.debug('ignoredCrStatus----> '+ ignoredCrStatus +'------ignoredCRs-- ' +ignoredCRs + 'ignoredMods---'+ignoredMods + 'setOfReleases=== '+ setOfReleases +  '---' + setOfCRs + '--- '+ setOfMods);
         system.debug('isSystemModifications'+isSystemModifications);
               
         //Checking if record is not found then display a message and return
         if(isSystemModifications == null || isSystemModifications.size() == 0){
             
             information = System.Label.ONE_CLICK_NO_RECORD_FOUND;
             return;
         }
        
        //Initialization of the map
        mapOfObjectTypeAndModifications = new Map<String, List<IS_System_Modification__c>>();
        
        //Looping on isSystemModifications to put in map crossponding to object type
        for(IS_System_Modification__c mod : isSystemModifications){
                
            if(mapOfObjectTypeAndModifications.containsKey(mod.IS_System_Component__r.Object_Type__c)){
                    
                List<IS_System_Modification__c> listOfMods =  mapOfObjectTypeAndModifications.get(mod.IS_System_Component__r.Object_Type__c);
                listOfMods.add(mod);
                mapOfObjectTypeAndModifications.put(mod.IS_System_Component__r.Object_Type__c, listOfMods);
            }
            else
                mapOfObjectTypeAndModifications.put(mod.IS_System_Component__r.Object_Type__c, new List<IS_System_Modification__c>{mod});
        }
        
        //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 09/16/2017. Keeping the counter of quered modification
        numberOfQueredModification = isSystemModifications.size();
                            
        //Extract subjects of the mail
        subject = '';
        if(setOfReleases.size() > 0) {
            
            for(String str: setOfReleases)
                subject += str + ',';
        }
        else if(setOfCRs.size() > 0){
            
            for(String str: setOfCRs)
                subject += str + ',';
        }
        if(setOfMods.size() > 0){
            
            for(String str: setOfMods)
                subject += str + ',';
        }
        subject = subject.removeEnd(',');
    }
    
    /*
    *   Description     :   The method is used to create deployment (package.xml) file.
    *
    *   Created by      :   Saurabh Kumar
    *
    *   Created Date    :   04/22/2017
    *
    *   @args           :   xml version of the package file, Boolean isWithDuplicates
    *
    *   @return         :   String (Text body of package.xml file)
    *
    *   Revision Log    :   V1.0 Created
    *                   :   V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/28/2017 - Improve the functionality
    *          :  V1.2 - Modified by Saurabh Kumar - CR-20170821-11154 - 09/16/2017 - one argument is added Boolean isWithDuplicates. Added more messages for the total counter
    */
    public String createXML(String xmlVersion, Boolean isWithDuplicates){
        
        try {
            system.debug('mapOfObjectTypeAndModifications'+mapOfObjectTypeAndModifications);
            //Checking for map size and xml version. If anyone is blank then return null and display a message
            if(mapOfObjectTypeAndModifications == null || mapOfObjectTypeAndModifications.size() == 0  || String.isBlank(xmlVersion)){
                
                information = System.Label.ONE_CLICK_NO_RECORD_FOUND;
                return null;
            }
                
            //Local variables
            Set<String> uniqueComponentName;
            Integer numberOfComponents = 0;
            numberOfDuplicates = 0;
            noOfModification = 0;
            
            //variable to hold body part of package file in proper xml format
            String textBody = '<?xml version="1.0" encoding="UTF-8"?> \n';
            textBody += '<Package xmlns="http://soap.sforce.com/2006/04/metadata"> \n';
            textBody += '<!-- Package file for '+subject+' -->\n';
            numberOfAddedLines += 3;
            
            //Processing on the map to create xml file based on Advisory Is System Component Type and ANT format
            for(String objType : mapOfObjectTypeAndModifications.keySet()){
                
                //Set to hold unique components to avoid duplicate components while creating XML file
                uniqueComponentName = new Set<String>();
                numberOfComponents = 0;
                
                textBody += '\t<types>\n';
                numberOfAddedLines ++;
                
                //Processing on the map using component type
                for(Integer i=0;  i< mapOfObjectTypeAndModifications.get(objType).size(); i++){
                    
                    //Maintain the counter of component type
                    numberOfComponents++;
                    
                    //Checking for object type and check whether in ant format or not.  
                    if(mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Object_API_Name__c != null && mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Object_API_Name__c.contains('.') && (objType.equals('Button/Link') || 
                    objType.equals('Custom Field') || objType.equals('Field Set') || objType.equals('List View') || objType.equals('Validation Rule') ||
                    objType.equals('Workflow Email Alert') || objType.equals('Workflow Field Update') || objType.equals('Workflow Rule') || objType.equals('Workflow Task') || objType.equals('Record Type') || objType.equals('Assignment Rule') || objType.equals('Auto-Response Rule') )){
                        
                        //Checking whether set the component is already processed then skip the futher process and continue for the next.
                        if(uniqueComponentName.contains(mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Object_API_Name__c)){
                            
                            //Checking whether the all components are added for the object type, then mention the object type and close the type.
                            if(numberOfComponents == mapOfObjectTypeAndModifications.get(objType).size() && !isWithDuplicates){
                            
                                textBody += '\t\t<name>'+DeploymentConstants.mapOfObjectTypes.get(objType)+'</name>\n';
                                textBody += '\t</types>\n';
                                numberOfAddedLines += 2;
                                
                            }
                            
                            //Increase the duplicate counter
                            numberOfDuplicates ++;
                            
                            //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 09/16/2017 - Continue only if isWithDuplicates is false
                            if(!isWithDuplicates)
                              continue;
                        }
                        else
                            uniqueComponentName.add(mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Object_API_Name__c);
                        
                        textBody += '\t\t<members>' + mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Object_API_Name__c + '</members>\n';
                        numberOfAddedLines++;
                        
                        //Increase the counter for add elements
                        noOfModification++;
                    }
                    
                    //Checking for object type and check whether in ant format or not.
                    else if(mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Object_API_Name__c != null && !mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Object_API_Name__c.contains('.') && (objType.equals('Button/Link') || 
                    objType.equals('Custom Field') || objType.equals('Field Set') || objType.equals('List View') || objType.equals('Validation Rule') ||
                    objType.equals('Workflow Email Alert') || objType.equals('Workflow Field Update') || objType.equals('Workflow Rule') || objType.equals('Workflow Task') || objType.equals('Record Type') || objType.equals('Assignment Rule') || objType.equals('Auto-Response Rule'))){
                        
                        //Checking whether set the component is already processed then skip the futher process and continue for the next.
                        if(uniqueComponentName.contains(mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Object_API_Name__c)){
                            
                            //Checking whether the all components are added for the object type, then mention the object type and close the type.
                            if(numberOfComponents == mapOfObjectTypeAndModifications.get(objType).size() && !isWithDuplicates){
                            
                                textBody += '\t\t<name>'+DeploymentConstants.mapOfObjectTypes.get(objType)+'</name>\n';
                                textBody += '\t</types>\n';
                                numberOfAddedLines += 2;
                                
                            }
                            //Increase the duplicate counter
                            numberOfDuplicates ++;
                            
                            //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 09/16/2017 - Continue only if isWithDuplicates is false
                            if(!isWithDuplicates)
                              continue;
                        }
                        else
                            uniqueComponentName.add(mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Parent_API_Name__c +'.'+ mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Item_API_Name__c);
                            
                        textBody += '\t\t<members>' + mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Parent_API_Name__c +'.'+ mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Item_API_Name__c + '</members>\n';
                        numberOfAddedLines++;
                        
                        //Increase the counter for add elements
                        noOfModification++;
                    }
                    
                    //Checking for object type and check whether in ant format or not.
                    else if(mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Object_API_Name__c != null && 
                    mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Object_API_Name__c.contains('/') && (objType.equals('Dashboard') ||
                    objType.equals('Document') || objType.equals('Email Template') || objType.equals('Report')) ){
                        
                        //Checking whether set the component is already processed then skip the futher process and continue for the next.
                        if(uniqueComponentName.contains(mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Object_API_Name__c)){
                            
                            //Checking whether the all components are added for the object type, then mention the object type and close the type.
                            if(numberOfComponents == mapOfObjectTypeAndModifications.get(objType).size() && !isWithDuplicates){
                            
                                textBody += '\t\t<name>'+DeploymentConstants.mapOfObjectTypes.get(objType)+'</name>\n';
                                textBody += '\t</types>\n';
                                numberOfAddedLines += 2;
                                
                            }
                            //Increase the duplicate counter
                            numberOfDuplicates ++;
                            
                            //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 09/16/2017 - Continue only if isWithDuplicates is false
                            if(!isWithDuplicates)
                              continue;
                        }
                        else
                            uniqueComponentName.add(mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Object_API_Name__c);
                            
                        textBody += '\t\t<members>' + mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Object_API_Name__c + '</members>\n';
                        numberOfAddedLines++;
                        
                        //Increase the counter for add elements
                        noOfModification++;
                    }
                    
                    //Checking for object type and check whether in ant format or not.
                    else if(mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Object_API_Name__c != null &&
                    !mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Object_API_Name__c.contains('/') && (objType.equals('Dashboard') ||
                    objType.equals('Document') || objType.equals('Email Template') || objType.equals('Report'))){
                        
                        //Checking whether set the component is already processed then skip the futher process and continue for the next.
                        if(uniqueComponentName.contains(mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Object_API_Name__c)){
                        
                            //Checking whether the all components are added for the object type, then mention the object type and close the type.
                            if(numberOfComponents == mapOfObjectTypeAndModifications.get(objType).size() && !isWithDuplicates){
                            
                                textBody += '\t\t<name>'+DeploymentConstants.mapOfObjectTypes.get(objType)+'</name>\n';
                                textBody += '\t</types>\n';
                                numberOfAddedLines += 2;
                                
                            }
                            //Increase the duplicate counter
                            numberOfDuplicates ++;
                            
                            //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 09/16/2017 - Continue only if isWithDuplicates is false
                            if(!isWithDuplicates)
                              continue;
                        }
                        else
                            uniqueComponentName.add(mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Parent_API_Name__c +'/'+ mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Item_API_Name__c);
                            
                        textBody += '\t\t<members>' + mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Parent_API_Name__c +'/'+ mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Item_API_Name__c + '</members>\n';
                        numberOfAddedLines++;
                        
                        //Increase the counter for add elements
                        noOfModification++;
                    }
                    
                    //All other object types which are not defined in Advisory system/other type/ generic type, will be handled from here
                    else{
                        
                        //Checking whether set the component is already processed then skip the futher process and continue for the next.
                        if(uniqueComponentName.contains(mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Object_API_Name__c)){
                        
                            //Checking whether the all components are added for the object type, then mention the object type and close the type.
                            if(numberOfComponents == mapOfObjectTypeAndModifications.get(objType).size() && !isWithDuplicates){
                            
                                textBody += '\t\t<name>'+DeploymentConstants.mapOfObjectTypes.get(objType)+'</name>\n';
                                textBody += '\t</types>\n';
                                numberOfAddedLines += 2;
                                
                            }
                            //Increase the duplicate counter
                            numberOfDuplicates ++;
                            
                            //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 09/16/2017 - Continue only if isWithDuplicates is false
                            if(!isWithDuplicates)
                              continue;
                        }
                        
                        else if(objType.equals('Other') || objType.equals('Generic Object')) 
                            uniqueComponentName.add(mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Object_API_Name__c + mapOfObjectTypeAndModifications.get(objType)[i].Name);
                        else
                            uniqueComponentName.add(mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Object_API_Name__c);
                        
                        textBody += '\t\t<members>' + mapOfObjectTypeAndModifications.get(objType)[i].IS_System_Component__r.Object_API_Name__c + '</members>\n';
                        numberOfAddedLines++;
                        
                        //Increase the counter for added elements
                        noOfModification++;
                    }
                    
                    //Checking whether object type is Other/Generic obbject then mention the modification number as a comment for futher verification
                    if(objType.equals('Other') || objType.equals('Generic Object')){
                        
                        textBody += '\t\t<!--Please Verify above component. It\'s mod number = '+ mapOfObjectTypeAndModifications.get(objType)[i].Name+' -->\n';
                        numberOfAddedLines++;
                    }
                    
                    //Checking whether the all components are added for the object type, then mention the object type and close the type.
                    if(numberOfComponents == mapOfObjectTypeAndModifications.get(objType).size()){
                        
                        textBody += '\t\t<name>'+DeploymentConstants.mapOfObjectTypes.get(objType)+'</name>\n';
                        textBody += '\t</types>\n';
                        numberOfAddedLines += 2;
                        
                    }
                }
            }
            
            //Mention the xml version and close the package
            textBody += '\t<version>'+xmlVersion+'</version>\n';
            textBody += '</Package>';
            numberOfAddedLines += 2;
            
            //Checking if body is not contain any member then display the message
            if(!textBody.contains('</members>'))
                information = System.Label.ONE_CLICK_NO_RECORD_FOUND;
            
            //V1.2 - Modified by Saurabh Kumar - CR-20170821-11154 - 09/16/2017 - Adding message to display counter
            information = 'Total Comoponent(s) : '+numberOfQueredModification+'</br>';
            information += 'Total Added Component(s) : '+noOfModification+'</br>';
      information += 'Total Duplicate Component(s) : '+numberOfDuplicates+'</br>';
      //system.debug('textBody'+textBody);
            //Return the body
            return textBody;
            
        } catch(Exception e){
          
            information = 'Error: '+ e.getMessage();
            return null;
        }
    }
    
    /*
    *   Description     :   The method is used to insert attachemnt on the any record
    *
    *   Created by      :   Saurabh Kumar
    *
    *   Created Date    :   04/22/2017
    *
    *   @args           :   Parent Id
                            TextBody
    *
    *   @return         :   Attachment
    *
    *   Revision Log    :   V1.0 Created
    */
    public Attachment attachFile(Id parentId, String textBody){
        
        //Instance of Attachment
        Attachment attachment = new Attachment();
        
        try{
        
            //checking for arguments
            if(parentId == null || textBody == null)
                return null;
            
            //Adding the attributes of the attachment
            attachment.Name = String.valueOf('package.xml'); 
            attachment.Body = Blob.valueOf(textBody);
            attachment.ParentId = parentId;
                
            //Inserting attchment
            insert attachment;
            
            //Return attachment
            return attachment;
        
        }catch(Exception e){
            
            information = 'Error: '+e.getMessage();
            return null;
        }
    }
    
    /*
    *   Description     :   The method is used to send email.
    *
    *   Created by      :   Saurabh Kumar
    *
    *   Created Date    :   04/22/2017
    *
    *   @args           :   List of ToAddresses
                            TextBody
    *
    *   @return         :   Void
    *
    *   Revision Log    :   V1.0 Created
    */
    public void sendEmail(Set<String> toAddresses, String textBody){
        
        try {
            
            //Return the control if textBody is null
            if(String.isBlank(textBody))
                return;
                
            //Local variable
            String mailBody = '';
            
            //Subject for the mail
            String sub = 'Package file for '+ subject;
            
            //List to hold to addresses
            List<String> listToAddresses;
            
            //Checking whether toAddresses is null. If yes, assign current logged in user email
            if(toAddresses.size() == 0)
                listToAddresses = new List<String> { UserInfo.getUserEmail() };
            else
                listToAddresses = new List<String> ( toAddresses );
            
            //Instance of Email file attachment to prepare attachment file for the mail
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setContentType('text/plain');
            efa.setFileName('package.xml');
            efa.setBody(Blob.valueOf(textBody));
            
            //Adding file attachment to the list 
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            fileAttachments.add(efa);
            
            //List of SingleEmailMessage
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            
            //Instance of SingleEmailMessage to prepare mail body
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            //Set to addresses (Receivers)
            mail.setToAddresses(listToAddresses);
            
            //Set subject
            mail.setSubject('Script File For '+subject);
            
            //Preparing mail body
            mailBody = 'Hi,<br><br>';
            mailBody += 'Please find the attached package file. <br><br>';
            mailBody += 'Total Comoponent(s) : '+numberOfQueredModification+'<br>';
            mailBody += 'Total Added Component(s) : '+noOfModification +'<br>';
            mailBody += 'Total Duplicate Component(s) : '+numberOfDuplicates +'<br><br><br>';
            
            mailBody += 'Thank You!';
            
            //Set mail body
            mail.setHtmlBody(mailBody);
            
            //Attaching the file on the mail
            mail.setFileAttachments(fileAttachments);
            
            //Adding mail to the list of SingleMessaging
            mails.add(mail);
            
            //Send email to the receiver
            Messaging.sendEmail(mails);
            
        } catch(Exception e){
            
            information = 'Error: '+ e.getMessage();
        }
    }
    
    /*
    *   Description     :   The method is used to create package file and attach on the parent record
    *
    *   Created by      :   Saurabh Kumar
    *
    *   Created Date    :   04/22/2017
    *
    *   @args           :   Xml version of the package file
                            Parent Id
                            String parentName
                            Boolean isWithDuplicates
    *
    *   @return         :   Void
    *
    *   Revision Log    :   V1.0 Created
    *          :  V1.1 - Updated by - Saurabh Kumar - CR-20170821-11154 - 08/28/2017 - 
                     1 - User message is added.
                     2 - One More parameter is added that's parentName
                V1.2 - Modified by Saurabh Kumar - CR-20170821-11154 - 09/16/2017. One argument is added Boolean isWithDuplicates
    */
    public Attachment createPackageAndAttach(String xmlVersion, Id parentId, String parentName, Boolean isWithDuplicates){
        
        //Checking whether xml and parentId then return null
        if(String.isBlank(xmlVersion) || String.isBlank(parentId))
            return null;
        
        //Calling method to create package file
        String textBody = createXML(xmlVersion, isWithDuplicates);

        //system.debug('textBody'+textBody);
        //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/28/2017. Checking for the xml body not blank then only call the method
        if(String.isNotBlank(textBody)){
            
            //Calling method to attach the file on parent record
            Attachment attachment = attachFile(parentId, textBody);
            
            //V1.2 - Modified by Saurabh Kumar - CR-20170821-11154 - 09/16/2017 - Adding message to display counter
            information = 'Total Comoponent(s) : '+numberOfQueredModification+'</br>';
            information += 'Total Added Component(s) : '+noOfModification+'</br>';
      information += 'Total Duplicate Component(s) : '+numberOfDuplicates+'</br>';
      information += 'Package file is attached to the "'+parentName+'" record.';
            
            //Return the Attachment
            return attachment;
        }
        
        return null;
    }
    
    /*
    *   Description     :   The method is used to create package file and send email.
    *
    *   Created by      :   Saurabh Kumar
    *
    *   Created Date    :   04/22/2017
    *
    *   @args           :   Xml version of the package file
                            Parent Id
    *
    *   @return         :   Void
    *
    *   Revision Log    :   V1.0 Created
    *          :  V1.1 - Updated by - Saurabh Kumar - CR-20170821-11154 - 08/28/2017 - User message is added.
    *          :  V1.2 - Modified by Saurabh Kumar - CR-20170821-11154 - 09/16/2017. One argument is added Boolean isWithDuplicates
    */
    public String createPackageAndEmail(String xmlVersion, String toAddress, Boolean isWithDuplicates){
        
        //Checking for the xml version and to address
        if(String.isBlank(xmlVersion) || String.isBlank(toAddress))
            return null;
        
        //Calling method to create package file
        String textBody = createXML(xmlVersion, isWithDuplicates);
        
        //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/28/2017. Checking for xml body if not null then only send the email 
        if(String.isNotBlank(textBody)){
            
            //Calling method to send email
            sendEmail(new Set<String>{toAddress}, textBody);
            
            //V1.2 - Modified by Saurabh Kumar - CR-20170821-11154 - 09/16/2017 - Adding message to display counter
            information = 'Total Comoponent(s) : '+numberOfQueredModification+'</br>';
            information += 'Total Added Component(s) : '+noOfModification+'</br>';
      information += 'Total Duplicate Component(s) : '+numberOfDuplicates+'</br>';
            information += 'Email has been sent to "'+toAddress+'".';
            
            //Return the body of xml file
            return textBody;
        }
        
        return null;
        
    }
}