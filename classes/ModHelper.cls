/**
*  Desription      :   Helper class to have all the methods for supporting the functionality of Deployment Automation 
* 
*  Created By      :   Team = The Griffin. (As a part of Heckthon - 4-22-2017)
* 
*  Created Date    :   4/22/2017
* 
*  Revision Logs   :  V1.0 - Created
*           :  V1.1 - Modified by - Saurabh Kumar - 08/25/2017 - CR-20170821-11154. Improve the functionality
            v1.3 - Modified by Mahaendra Swarnkar - CR-20190501-13061 - Spring cleanup
*
**/ 
public class ModHelper {
    
    // Date Instance to hold the Sand Box referesh date
    public Date sandBoxRefreshDate {set; get;}
    
    //V1.1 - Modified by - Saurabh Kumar - 08/29/2017 - CR-20170821-11154. Variable to hold user info message
    public String information {get;set;}
    
    //V1.1 - Modified by - Saurabh Kumar - 09/15/2017 - CR-20170821-11154. Variable to hold overlap summary
    public String summaryString {get; set;}
    
    //For Individual Use case
    //Individual CR/Release/Modification Instances
    public SFDC_Change_Request__c indidualCR {get; set;}
    public IS_System_Modification__c indidualMod {get; set;}
    public SFDC_Release__c indidualRelease {get; set;}
    public Id parentId {get; set;}
    
    //For the Grouo of Releases/CRs/Modification.
    //String variables to hold the group of CRs/Releases/Modifications
    public string groupOfCRs {get; set;}
    public String groupOfModifications {get; set;}
    public String groupOfReleases {get; set;}
    
    //Boolean flag to check if Profile Mods are included in the Cross Check
    public Boolean byPassProfileMods = true;
    
    //Boolean flag to check if Cancelled or onHold CRs will be included in the Cross Check
    public Boolean byPassCanelledORHOldCRs = false;
    
    //Boolean flag to check if Cancelled or onHold CRs will be included in the Cross Check
    public Boolean isIndividual {get; set;}
    
    //Global variable to hold subject of the mail
    public String subject;
    
    //Global variable to hold sandbox name
    public String sandboxName;
    
    //Variable to hold parent record name
    public String parentName;
    
    //Variable to hold email address
    public String emailAddress;
    
    //Constants 
    //Default CR Status
    public static final String defaultCRstatus = '09-In IS QA,10-In UAT,11-Ready for Deployment';
    
    //Default CR Status
    public static final String anchorLinkStart = '<a href="';
    
    //Class Constructor
    public ModHelper(Date sandBoxRefreshDate, SFDC_Change_Request__c indidualCR, IS_System_Modification__c indidualMod, 
                     SFDC_Release__c indidualRelease, Id parentId, String parentName, String groupOfCRs, String groupOfModifications, 
                     String groupOfReleases, Boolean byPassProfileMods, Boolean byPassCanelledORHOldCRs, Boolean isIndividual, 
                     String crStatusForCrossCheck ) {
        
        this.sandBoxRefreshDate = sandBoxRefreshDate;
        this.indidualCR = indidualCR;
        this.indidualMod = indidualMod;
        this.indidualRelease = indidualRelease;
        this.parentId = parentId;
        this.groupOfCRs = groupOfCRs;
        this.groupOfModifications = groupOfModifications; 
        this.groupOfReleases = groupOfReleases;
        this.byPassProfileMods = byPassProfileMods;
        this.byPassCanelledORHOldCRs = byPassCanelledORHOldCRs;
        this.isIndividual = isIndividual;
        this.crStatusForCrossCheck = crStatusForCrossCheck;
        this.parentName = parentName;
        
        information = '';
        summaryString = '';
    }
    
    //V1.1 - Modified by - Saurabh Kumar - 08/25/2017 - CR-20170821-11154. Add the default status which should be always included
    //String variable to hold the CR status passed by the Users
    public String crStatusForCrossCheck {
        get {
            
            //Check for size 
            if(String.isBlank(crStatusForCrossCheck)) {
                crStatusForCrossCheck = defaultCRstatus;
            }else
            	crStatusForCrossCheck += defaultCRstatus;
            
            //return statement
            return crStatusForCrossCheck;
        }
        set;
    }
    
    //Mp to hold the Mods API name (Mod.Component.APINames) with a modwrapper instance 
    //modWtapper will have a list of overlapping mods
    public map <string, modWrapper> overlappingModMap {
        get {
            
            //Check for size
            if (overlappingModMap == null) {
                
                //Instantiate the map
                overlappingModMap = new map < string, modWrapper > ();
                
                //Call the cross check method to popuate the map
                doCrossCheck(isIndividual);
            }
            
            //Return statement
            return overlappingModMap;
        }
        set;
    }
    
    //Method to build the URL for Mod/CR/Release By taking the Mod Id
    public string buildURL(string id, string name) {
        
        //Temporary string variable to hold the url string
        String urlString = '';
        
        //Check for the id value
        if(String.isNotBlank(id) )
            urlString = anchorLinkStart + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + id + '" style="padding:5px;">' + name + '</a>';
        
        //Return statement
        return urlString;
    }
    
    //Method to get the Set of String literals from the Coma separated String
    public Set<String> parseComaSeparatedString (String comaSeparatedString) {
        
        //Set to hold the String literals
        Set<String> setOfSeparatedStringLiterals = new Set<String>();
        
        //Check for the size
        if(String.isNotBlank(comaSeparatedString)) {
            
            //Split the Coma separated String and populate the set of separated String literals
            for(String str : comaSeparatedString.split(',')) {
                str = str.replace('\'', '');
                
                //Check for size
                if(String.isNotBlank(str) )
                	
                    //Populate the Set
                    setOfSeparatedStringLiterals.add(str.trim());
            }
        }
        
        return setOfSeparatedStringLiterals;
    }
    
    Set<String> setReleases1;
    Set<String> setCRs1;
    Set<String> setModifications1;
    Set<String> setOfCRStatus1;
    
    //Dynamic Query For the Croscheck 
    public String getQueryString(Boolean isModsFromSource, Boolean isIndividual) { 

        //Set of release 
        Set<String> setReleases = new Set<String>();
        
        //Set of CRs
        Set<String> setCRs = new Set<String>();
        
        //Set of Modifications
        Set<String> setModifications = new Set<String>();
        
        //Check for for the cross check type i.e. for Individual mod/CR/Release 
        if(isIndividual) {
            
            String temp;
            
            //Populate the set with values
            if(indidualRelease != null) {
                temp = indidualRelease.Name;
                setReleases.add(temp);
            }
            
            //Populate the set with values
            if(indidualCR != null){
                temp = indidualCR.Name;
                setCRs.add(temp);
            }
            
            //Populate the set with values
            if(indidualMod != null) {
                temp = indidualMod.Name;
                setModifications.add(temp);
            }   
        }
        
        else {
            
            //Populate the set with values
            if(String.isNotBlank(groupOfReleases))
                setReleases.addAll(parseComaSeparatedString(groupOfReleases));
            
            //Populate the set with values
            if(String.isNotBlank(groupOfCRs))
                setCRs.addAll(parseComaSeparatedString(groupOfCRs));
            
            //Populate the set with values
            if(String.isNotBlank(groupOfModifications))
                setModifications.addAll(parseComaSeparatedString(groupOfModifications));
        }
        //Modified by Mahaendra Swarnkar - CR-20190501-13061 - Spring cleanup
        //String to hold the base query
        String baseQuery = 'SELECT Id, Name, Type_of_Modification__c, CR_Status__c, Object_Type__c, Release__c, LastModifiedDate, LastModifiedBy.Name, ' +
            'IS_System_Component__c, IS_System_Component__r.Object_API_Name__c,'+
            'Change_Request__c, Change_Request__r.Name,'+
            'Change_Request__r.Release__c, Change_Request__r.Release__r.Name '+
           /* 'Change_Request__r.Release__r.Dev_Sandbox__r.Name '+*/
            'FROM IS_System_Modification__c ';
        
        setReleases1 = setReleases;
        setCRs1 = setCRs;
        setModifications1 = setModifications;

        //Where Clause for getting all the mods of source mods/CR/Release
        String whereClause = 'WHERE '+      
            '('+ 
            '('+ 
            'Change_Request__r.Release__c != null AND Change_Request__r.Release__r.Name IN : setReleases1 '+ // Set of Release Names
            ') '+ 
            'OR '+ 
            'Change_Request__r.Name IN : setCRs1 '+  // Set of CR Names
            'OR '+ 
            'Name IN : setModifications1 '+  // Set of Modifications
            ')'+
            ' AND Delete_from_Design__c = false '+
            'AND ( Include_in_Change_Set__c = true OR Potential_Overlapping__c = true)';
        
        //Check to bypass the Profile related mods in the cross check 
        //if yes then add the check for it in the where clause  
        if (byPassProfileMods) 
            whereClause += ' AND Object_Type__c != \'Profile\' ';
        
        //Check if Cancelled or onhold CRs are included or not  
        if(!byPassCanelledORHOldCRs) 
            whereClause += ' AND (CR_Status__c != \'Cancelled\' AND CR_Status__c != \'On Hold\')';
        
        Set<String> setOfCRStatus = parseComaSeparatedString(crStatusForCrossCheck);
        
        setOfCRStatus1 = setOfCRStatus;
        
        //setOfCRStatus1 = new Set<String>();
        //setOfCRStatus1.add('12-Deployed');
        //Where Clause for getting all the mods other than source mods/CR/Release  
        String whereOverlapStr = ' WHERE (Change_Request__r.Release__r.Name NOT IN : setReleases1 AND Change_Request__r.Name NOT IN : setCRs1 AND Name NOT IN : setModifications1 ) '  // Set of Release Names and Set of CRs 
            + 'AND (Change_Request__r.Release__r.Actual_Release_Date__c >=: sandBoxRefreshDate OR Change_Request__r.Release__r.Target_Release_Date__c >=: sandBoxRefreshDate '
            + 'OR CR_Status__c IN : setOfCRStatus1) '    //Set of CR status
            + 'AND Delete_from_Design__c = false AND (Include_in_Change_Set__c = true OR Potential_Overlapping__c = true) ORDER BY LastModifiedDate DESC';
        
        //Get query for the Source Release
        if(isModsFromSource)
            return (baseQuery + whereClause + 'ORDER BY Object_Type__c ASC');
        else{
		
		   //Get query for the all other Release
            return (baseQuery + whereOverlapStr);    

        }
    }
    
    //V1.1 - Modified by - Saurabh Kumar - 08/29/2017 - CR-20170821-11154. - Added try catch to better error handling
    // This Method is responsible to query out the modification either from the All other or Source release/CR/Mods as per the boolean flag 
    public void getListOfModifications( Boolean isModsFromSource, Boolean isIndividual) {
        
       try{
		
        	//first, add all mods for the source release
	        list < IS_System_Modification__c > mods = database.query( getQueryString(isModsFromSource, isIndividual) );

	        //Call the method to do Identify the overlappings and then add them into the overlapping mods map
	        identifyOverlappingMods(mods, isModsFromSource);
        
        }catch(Exception e){
        	
        	information = 'Error: '+e.getMessage();	
        }
    }
    
    //This Method is responsible to do the cross check by finding the Overlapping mods 
    public void doCrossCheck(Boolean isIndividual) {

        //first, Query the add all mods for the source release
        getListOfModifications(true, isIndividual);
        
        //get all mods for the other releases
        getListOfModifications(false, isIndividual);
        
    }
    
    //This method is responsible to identify the overlapping mods and populate the map for overlapping mod(Component API name) with a wrapper instance ie. mods wrapper overlapped mods 
    //Actually this Wrapper have the list of overlapped mods. 
    public void identifyOverlappingMods(list < IS_System_Modification__c > mods, boolean isModsFromSource) {
        
        //Loop over the list of mods 
        for (IS_System_Modification__c mod: mods) {

            //Check for the mod if its related to source Release/CR/Mods 
            if (isModsFromSource) {
                
                //Populate the map for overlappe
                overlappingModMap.put(mod.IS_System_Component__r.Object_API_Name__c, new modWrapper(mod));
                
            } 

            //else Check if the already in the overlapping map, if yess the populate the list of overlapping mods 
            else if ( overlappingModMap != null 
            	&& String.IsNotBlank(mod.IS_System_Component__r.Object_API_Name__c) 
                &&  overlappingModMap.containsKey(mod.IS_System_Component__r.Object_API_Name__c)
                && overlappingModMap.get(mod.IS_System_Component__r.Object_API_Name__c) != null
            ) {
                        
                //get the wrapper instance 
                modWrapper mWrapper = overlappingModMap.get(mod.IS_System_Component__r.Object_API_Name__c);
                
                //Populate the overlapping mods list
                mWrapper.overlappingMods.add(mod);
                
                //Now again populate the map overlapping.
                overlappingModMap.put(mod.IS_System_Component__r.Object_API_Name__c, mWrapper);
            }
        }
    }
    
    //This Method is used to place a chatter on the CR record This is the part of te Pahase 2
    public Map<string, modWrapper> crossCheckAndDisplay() {

        //Reset the flag
        information = '';
        
        //Call the method to do the cross check and identify the overlapping mods
        doCrossCheck(isIndividual);
		
        //Return Statement
        return overlappingModMap;
    }
	
	//V1.1 - Modified by - Saurabh Kumar - 08/30/2017 - CR-20170821-11154. two arguments are added  
    //this Method will be used to do the cros check and send an email to the respective CR and attach the File on the CR/Release Record.
    public void crossCheckAndSendEmail(String sandboxName, String emailAddress) {
        
        //Reset the flag
        information = '';
        
        //Assigning the value in global variables
        this.sandboxName = sandboxName;
        this.emailAddress = emailAddress;
        
        //Call the method to do the cross check and identify the overlapping mods
        doCrossCheck(isIndividual);
        
        //Call the method to sent an email to the logged in user Current user 
        //emailOverlappingModsListToUsers(true, parentId);
        Attachment attachment1 = emailOverlappingModsListToUsers(true, parentId);
    }   
    
    //This Method is used to attach the File on the CR/Release record
    public Attachment crossCheckAndattachFileOnRecord() {
        
        //Reset the flag
        information = '';
        
        //Call the method to do the cross check and identify the overlapping mods
        doCrossCheck(isIndividual);
        
        //Attach the the file on any one of the record.
        // If Mod then attach on the CR Record 
        // If CR then attach on the any of the Release Record 
        //If Release then attach in the Release Record.
        Attachment attachment1 = emailOverlappingModsListToUsers(false, parentId);
        return attachment1;
    }
    
    //This Method is used to place a chatter on te CR record This is the part of te Pahase 2
    /*public void crossCheckAndPlaceChatterOnRespectiveCRRecord() {

}
*/
    //Method to get the coma separated String of Source CRs/Mods/Release
    public String sourceListToComaSeparatedString()
    {
        String combinedComaSeparatedString = '';
        
        //Check for size
        if(indidualCR != null)
            combinedComaSeparatedString = combinedComaSeparatedString + ', '+ indidualCR.Name;
        
        //Check for size
        if(indidualMod != null)
            combinedComaSeparatedString = combinedComaSeparatedString + ', '+ indidualMod.Name;
        
        //Check for size
        if(indidualRelease != null)
            combinedComaSeparatedString = combinedComaSeparatedString + ', '+ indidualRelease.Name;
        
        //Check for size
        if(String.isNotBlank(groupOfCRs))
            combinedComaSeparatedString = combinedComaSeparatedString + ', '+ groupOfCRs;
        
        //Check for size
        if(String.isNotBlank(groupOfModifications))
            combinedComaSeparatedString = combinedComaSeparatedString + ', '+ groupOfModifications;
        
        //Check for size
        if(String.isNotBlank(groupOfReleases))
            combinedComaSeparatedString = combinedComaSeparatedString + ', '+ groupOfReleases;
        
        //V1.1 - Modified by - Saurabh Kumar - 08/30/2017 - CR-20170821-11154. - Remove the additional comma
        if(combinedComaSeparatedString.startsWith(','))
        	combinedComaSeparatedString = combinedComaSeparatedString.substring(combinedComaSeparatedString.indexOf(',')+1);
        
        //Return statement
        return  combinedComaSeparatedString.trim();    
    }
    
    //This Method is responsible to sent out an Email to the logged inn user and on the list email addresses as provided by the User 
    public Attachment emailOverlappingModsListToUsers(Boolean sentEmail, Id parentId) {
        
        try{
        	
        	String combinedComaSeparatedString = sourceListToComaSeparatedString();
        
	        //variable to hold the test for heading  and summary for in the email 
	        string topString;
	        
	        //V1.1 - Modified by - Saurabh Kumar - 08/30/2017 - CR-20170821-11154. Adding the sandbox name too for the mail
	        //TopString to hold the details or the Cross check results Like SB refresh date etc.
	        topString = '<div style="font-family:Arial; font-size: 18px; color:#444445; font-weight:bold;">Mod Overlap Report</div>';
	        topString += '<div style="font-family:Arial; font-size: 15px; color:#616161">Comparing <b> (' + combinedComaSeparatedString + ')</b> mods with mods on Releases with ';
	        if(sandBoxRefreshDate != null)
	            topString += 'Target or Actual Deployment date on or after <b>' + sandBoxRefreshDate.format() + '</b> against <b>'+sandboxName+'</b> sandbox.'+'</div><br/>';
	        
	        //Summary of cross check report
	        summaryString = '<div style="font-family:Arial; font-size: 14px; color:#444445;text-decoration:underline;">Cross Check Completed. Overlapping found as:-</div><br/>';
	        
	        //Draw Table starts from here
	        string crossCheckReportBody = '<table style="width:97%; border: 0px solid white; font-family:Arial; font-size: 13px;" border="0">';
	        String crossCheckCSVReportBody = '';
	        
	        //Counter
	        Integer counter = 1;
	        
	        //Loop over the ket set of overlaping mods map 
	        for (string componentName: overlappingModMap.keySet()) {
	            
	            //Check for size
	            //Check if the mod have a list of overlapped mods if not ten continue
	            if (overlappingModMap.get(componentName).overlappingMods.size() == 0) continue;
	            
	            //else get the Wrapper instance which is having the list of overlapping mods.
	            modWrapper wrapper = overlappingModMap.get(componentName);
	            
	            //Draw the row for headers (Column) for  Table 
	            crossCheckReportBody += '<tr style="border-collapse: collapse; background-color:#6C8CB4; color:white;">';
	            
	            //Headers columns
	            crossCheckReportBody += '<th align="left">Release Name</th><th align="left">CR Number</th><th align="left">IS System Mod</th><th align="left">Dev Environment</th><th align="left">Component Name</th><th align="left">Object Type</th><th align="left">Type of Mod</th><th align="left">CR Status</th><th align="left">Last Modified By</th><th align="left">Last Modified Date</th></tr>';
	            crossCheckCSVReportBody += '\n' + 'Release Name,CR Number,IS System Mod,Dev Environment,Component Name,Object Type,Type of Mod,CR Status,Last Modified By,Last Modified Date';
	            
	            //Draw Table row- columns  with values  
	            crossCheckReportBody += '<tr style="border-collapse: collapse; background-color:#f9e9dd;">';
	            
	            //V1.1 - Modified by - Saurabh Kumar - 08/25/2017 - CR-20170821-11154. Create hyper link of release name
	            crossCheckReportBody += '<td>' + buildURL(wrapper.mainMod.Change_Request__r.Release__c, wrapper.mainMod.Release__c) + '</td>';
	            
              crossCheckReportBody += '<td>' + buildURL(wrapper.mainMod.Change_Request__c, wrapper.mainMod.Change_Request__r.Name) + '</td>';
              crossCheckReportBody += '<td>' + buildURL(wrapper.mainMod.Id, wrapper.mainMod.Name) + '</td>';
                //Modified by Mahaendra Swarnkar - CR-20190501-13061 - Spring cleanup
              crossCheckReportBody += '<td>' + /*wrapper.mainMod.Change_Request__r.Release__r.Dev_Sandbox__r.Name +*/ '</td>';
              crossCheckReportBody += '<td>' + componentName + '</td>';
              crossCheckReportBody += '<td>' + wrapper.mainMod.Object_Type__c + '</td>';
              crossCheckReportBody += '<td>' + wrapper.mainMod.Type_of_Modification__c + '</td>';
              crossCheckReportBody += '<td>' + wrapper.mainMod.CR_Status__c + '</td>';
              crossCheckReportBody += '<td>' + wrapper.mainMod.LastModifiedBy.Name + '</td>';
              crossCheckReportBody += '<td>' + wrapper.mainMod.LastModifiedDate.format() + '</td>';
              crossCheckReportBody += '</tr>';
              
              crossCheckCSVReportBody += '\n' + wrapper.mainMod.Release__c + ',' + wrapper.mainMod.Change_Request__r.Name + ',' + wrapper.mainMod.Name + ',' +/* wrapper.mainMod.Change_Request__r.Release__r.Dev_Sandbox__r.Name +*/ ',' + componentName + ',' + wrapper.mainMod.Object_Type__c + ',' + wrapper.mainMod.Type_of_Modification__c + ',' + wrapper.mainMod.CR_Status__c + ',' + wrapper.mainMod.LastModifiedBy.Name + ',' + wrapper.mainMod.LastModifiedDate.format();
              
              //Summary Strings 
              summaryString += '<div style="font-family:Arial; font-size: 12px; color:#444445;">'+counter+ ' - ' + wrapper.mainMod.Change_Request__r.Name + ' ('+ wrapper.mainMod.Name+') ';
              
              //Loop over the list of overlapping mods
              for (IS_System_Modification__c m: wrapper.overlappingMods) {
                  
                  crossCheckReportBody += '<tr style="border-collapse: collapse; background-color:#f6f6f6;"">';
                  
                  //V1.1 - Modified by - Saurabh Kumar - 08/25/2017 - CR-20170821-11154. Create hyper link of release name
                  crossCheckReportBody += '<td>' + buildURL(m.Change_Request__r.Release__c, m.Release__c) + '</td>';
                  
                  crossCheckReportBody += '<td>' + buildURL(m.Change_Request__c, m.Change_Request__r.Name) + '</td>';
                  crossCheckReportBody += '<td>' + buildURL(m.Id, m.Name) + '</td>';
                    //Modified by Mahaendra Swarnkar - CR-20190501-13061 - Spring cleanup
                  crossCheckReportBody += '<td>' +/* m.Change_Request__r.Release__r.Dev_Sandbox__r.Name +*/ '</td>';
                  crossCheckReportBody += '<td>' + m.IS_System_Component__r.Object_API_Name__c + '</td>';
                  crossCheckReportBody += '<td>' + m.Object_Type__c + '</td>';
                  crossCheckReportBody += '<td>' + m.Type_of_Modification__c + '</td>';
                  crossCheckReportBody += '<td>' + m.CR_Status__c + '</td>';
                  crossCheckReportBody += '<td>' + m.LastModifiedBy.Name + '</td>';
                  crossCheckReportBody += '<td>' + m.LastModifiedDate.format() + '</td>';
                  crossCheckReportBody += '</tr>';
                  
                  crossCheckCSVReportBody += '\n' + m.Release__c + ',' + m.Change_Request__r.Name + ',' + m.Name + ',' + /*m.Change_Request__r.Release__r.Dev_Sandbox__r.Name +*/ ',' + m.IS_System_Component__r.Object_API_Name__c + ',' + m.Object_Type__c + ',' + m.Type_of_Modification__c + ',' + m.CR_Status__c + ',' + m.LastModifiedBy.Name + ',' + m.LastModifiedDate.format();
                  
                  //Add the Change request Name in the Summary String
                  summaryString += ' & '+ m.Change_Request__r.Name + ' ('+ m.Name + ') ' + '<b>- ' + m.Change_Request__r.Release__r.Name + '</b>'; 
              }
              crossCheckCSVReportBody += '\n';
              
              //Add the component Name in the Summary String      
              summaryString += '- ' + componentName + '</div><br/>';
              
              //Increase the counter
              counter++;
              
              crossCheckReportBody += '<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr></tr>';
          }
          
          //Draw table ends here
          crossCheckReportBody += '</table>';
          
          //V1.1 - Modified by - Saurabh Kumar - 08/30/2017 - CR-20170821-11154. Checking if cross check body is empty then display a message and return
          if(String.isBlank(crossCheckCSVReportBody)){
            
            information = System.Label.ONE_CLICK_NO_OVERLAPPING_FOUND;
            return null;
          }
          
          //Concating the Top String and Summary String
          String finalData = topString + summaryString + crossCheckReportBody;
          
          //Check if email should be sent
          if(sentEmail) {
              
              //Checking for email address
              if(String.isBlank(emailAddress))
                emailAddress = UserInfo.getUserEmail();
                
              //Send an email to logged in User i.e. Current User
              util.sendSingleEmail
                  ( 
                      util.createSingleEmail
                      (
                          new list < string > { emailAddress },
                          UserInfo.getUserEmail(),
                          UserInfo.getUserName(),
                          'Overlapping Mods for \'[' + combinedComaSeparatedString +'] - '+sandboxName+'\'', finalData
                      )
                  );
              
              //Message to display after sending email
            information = 'Email has been sent to "'+emailAddress+'" .';
          }
          //Else attach the file on the CR/Mod/Release
          else if(!sentEmail && String.isNotBlank(parentId)){
              
              //Set the subject String 
              subject = combinedComaSeparatedString;
              
              //Call the attachment Method
              Attachment attach = attachFile(parentId, crossCheckCSVReportBody, false );
              
              //Message to display after attaching the file
            information = 'File has been attached on "'+parentName+'" record.';
            
              return attach;
              
          }
        
        }catch(Exception e){
        	
        	information = 'Error: '+e.getMessage();
        }
        return null;
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
    public Attachment attachFile(Id parentId, String textBody, Boolean isPackage){
        
        //Instance of Attachment
        Attachment attachment = new Attachment();
        
        try {
            
            //checking for arguments
            if(parentId == null || String.isBlank(textBody))
                return null;
            
            //Adding the attributes of the attachment
            //Check for file type
            if(isPackage)
                
                //Set the Atttachment Name
                attachment.Name = String.valueOf('Package file for '+subject + '.csv');
            
            else {
                
                //Set the Atttachment Name
                attachment.Name = String.valueOf(' Cross Check Report   for ' + subject + '.csv');
                attachment.ParentId = parentId;
            }
            
            attachment.ContentType = 'application/vnd.ms-excel';
            
            //Set the attachment Body
            attachment.Body = Blob.valueOf(textBody);
            
            //Inserting attchment
            insert attachment;
            
            //Return attachment
            return attachment;
            
        }catch(Exception e){
            
            information = 'Error: '+e.getMessage();
            return null;
        }
    }
}