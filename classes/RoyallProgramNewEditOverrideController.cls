/**
 *  Description     :   Helper class for Program_New_Edit_Override VF page.
 *  
 *  Created By      :   Subhash Garhwal (Simplyforce)
 *
 *  Created Date    :   02/11/2016
 *
 *  Deprecated      :   
 *
 *  Revision Logs   :  v1.0 - Created
 * 		    :  V1.0 - Modified - Rajeev Jain - 06/16/2016 - SFDC schema Release - Manual Code Migration from Royall Enviournment, Rename this class with Preceeding text Royall
 *		    :  V1.1 - Modified - Mahendra Swarnkar - 01/04/2017 - CR-20161128-10501 - added a new method "doRedirect"  
 *		    :  V1.2 - Modified - Nikita Kumari - 08/05/2021 - CR-20210804-15332 - M&A: Changes to triggers due to new Acquisition record type  	
 *  
 **/
public with sharing class RoyallProgramNewEditOverrideController {
    
    //Properties
    
    //Program (Royall) instancc
    public Royall_Program__c program {get;set;}
    
    public Boolean isAcquisition {get;set;}
    
    //Constructor
    public RoyallProgramNewEditOverrideController(ApexPages.StandardController controller) {
        
        //Get Record
        program = (Royall_Program__c) controller.getRecord();
    }
    
    /**
     *  @description    :   Method is used to save the program record
     *
     *  @args           :
     *
     *  @return         :   Pagereference
     *
     *  @created By     :   Subhash Garhwal (Simplyforce)
     *
     *  @revision Logs  :   V1.1 - 02/11/2016 - Created
     *
     **/
    public Pagereference doSave() {
         
        //Save Point to roll back changes
        Savepoint sp = Database.setSavepoint();
            
        try {
        
            //Check for program
            if(program != null) {
                
                //Check for Campaign SubType
                if(String.isNotBlank(program.Campaign_SubType__c)){
                    
                    //Check for Sub Type picklist values and remove corresponding field values
                    
                    if(!program.Campaign_SubType__c.contains(ProgramConstants.CAMPAIGN_SUBTYPE_AM_IP_NAME))
                        program.QTY_AM_IP_Name__c = null;
                    
                    if(!program.Campaign_SubType__c.contains(ProgramConstants.CAMPAIGN_SUBTYPE_AM_NEW_NAME))
                        program.QTY_AM_new_name__c = null;
                        
                    if(!program.Campaign_SubType__c.contains(ProgramConstants.CAMPAIGN_SUBTYPE_AM_PRE_NAME))
                        program.QTY_AM_PRE_Name__c = null;
                    
                    if(!program.Campaign_SubType__c.contains(ProgramConstants.CAMPAIGN_SUBTYPE_SE_IP_NAME_CLIENT_PROVIDED))
                        program.QTY_SE_IP_Name_Client__c = null;
                    
                    if(!program.Campaign_SubType__c.contains(ProgramConstants.CAMPAIGN_SUBTYPE_SE_IP_NAME_ROYALL_GENERATED))
                        program.QTY_SE_IP_Name_Royall__c = null;
                    
                    if(!program.Campaign_SubType__c.contains(ProgramConstants.CAMPAIGN_SUBTYPE_SE_NEW_NAME))
                        program.QTY_SE_New_Name__c = null;
                    
                    if(!program.Campaign_SubType__c.contains(ProgramConstants.CAMPAIGN_SUBTYPE_SE_PRE_NAME))
                        program.QTY_SE_PRE_Name__c = null;
                    
                    if(!program.Campaign_SubType__c.contains(ProgramConstants.CAMPAIGN_SUBTYPE_SS_PRE_NEW_NAME)) {
                        
                        //Set fields to null
                        program.QTY_SS_New_Name__c = null;
                        program.Postage_Cost_SS_New__c = null;
                        program.Program_Cost_SS_New__c = null;
                    }
                    
                    if(!program.Campaign_SubType__c.contains(ProgramConstants.CAMPAIGN_SUBTYPE_SS_PRE_PRE_NAME)) {
                        
                        //Set fields to null
                        program.QTY_SS_PRE_Name__c = null;
                        program.Postage_Cost_SS_PRE__c = null;
                        program.Program_Cost_SS_PRE__c = null;
                    }
                } else {
                	
                	//Set all the properties to null
                	program.QTY_AM_IP_Name__c = null;
					program.QTY_AM_new_name__c = null;
					program.QTY_AM_PRE_Name__c = null;
					program.QTY_SE_IP_Name_Client__c = null;
					program.QTY_SE_IP_Name_Royall__c = null;
					program.QTY_SE_New_Name__c = null;
					program.QTY_SE_PRE_Name__c = null;
					program.QTY_SS_New_Name__c = null;
					program.Postage_Cost_SS_New__c = null;
					program.Program_Cost_SS_New__c = null;
					program.QTY_SS_PRE_Name__c = null;
					program.Postage_Cost_SS_PRE__c = null;
					program.Program_Cost_SS_PRE__c = null;
                }
                
                //Get parameter values from URL
                String isClone = ApexPages.currentPage().getParameters().get('clone');
                
                //Check for value
                if(String.isNotBlank(isClone) && isClone == '1') {
                	
                	//Clone the current record
                	Royall_Program__c clonedProgram = program.clone();
                	
                	//Insert
                	insert clonedProgram;
                	
                	//Return 
                	return new Pagereference('/' +clonedProgram.Id);
                } else {
                	
                	//Upsert program
	                upsert program;
	                    
	                //Return 
	                return new Pagereference('/' +program.Id);	
                }
            }
        }catch(Exception e) {
                
            //Roll Back changes
            Database.rollback(sp);
            
            //Add Error on page
            ApexPages.addMessages(e);
            return null;
        }
        
        return null;
    }
    /**
     *  @description    :   Method is used to redirect the user to standrd salesforce page layout for HD type program record
     *
     *  @args           :
     *
     *  @return         :   Pagereference
     *
     *  @created By     :   Mahendra swarnkar (Simplyforce)
     *
     *  @revision Logs  :   V1.1 - 01/04/2017 - Created - CR-20161128-10501 
     * 			:   V1.2 - Modified - Nikita Kumari - 08/05/2021 - CR-20210804-15332 - M&A: Changes to triggers due to new Acquisition record type  
     *
     **/
    public Pagereference doRedirect() {

        //Check for the HD Program(Royall) record type
        if(program != null 
          	&& program.RecordTypeId != null
          	&& (Program.RecordTypeId == Util.RecordTypeId(RoyallProgramTriggerHelper.ROYALL_PROGRAM_OBJECT_API_NAME, RoyallProgramTriggerHelper.ROYALL_PROGRAM_HD_RECORD_TYPE_LABEL))
            
          )
        {
            //String variable to hold the attribute present in the current page URL
            String returnURL = ApexPages.currentPage().getParameters().get('retURL');
            //Edit case i.e. Check is the Program (Royall) record is existing one 
            if(program.Id != null){
                
                if(ApexPages.currentPage().getURL().containsIgnoreCase('RoyallProgramDetailOverride'))
                    return new Pagereference('/' +program.Id+ '?nooverride=1');
            	return new Pagereference('/' +program.Id+ '/e?nooverride=1&retURL=' + returnURL);   
            }
            //New Program (Royall) record case
            else{
                
                String newURL = doRedirectStandardNewEditPage();
                
                //return statement
                return new Pagereference(newURL);
            }
        }
        else {

            //if the program package field is populated, default the program package record type
            if (program != null && program.Program_Package__c != null && program.Id == null) {

                Program_Package__c pkg = [SELECT Id, RecordType.Name FROM Program_Package__c WHERE Id = :program.Program_Package__c];
                
                if (pkg.RecordType.Name != null && pkg.RecordType.Name.equalsIgnoreCase(RoyallProgramTriggerHelper.PROGRAM_PACKAGE_HD_RECORD_TYPE_LABEL)) {
                    program.RecordTypeId = Schema.SObjectType.Royall_Program__c.getRecordTypeInfosByName().get(RoyallProgramTriggerHelper.ROYALL_PROGRAM_HD_RECORD_TYPE_LABEL).getRecordTypeId();
                }
                else if (pkg.RecordType.Name != null && pkg.RecordType.Name.equalsIgnoreCase('Royall')) {
                    program.RecordTypeId = Schema.SObjectType.Royall_Program__c.getRecordTypeInfosByName().get('Royall').getRecordTypeId();
                }
                
                //Modified By - Nikita Kumari - 08/05/2021 - CR-20210804-15332 - M&A: Changes to triggers due to new Acquisition record type  
                else if (pkg.RecordType.Name != null && pkg.RecordType.Name.equalsIgnoreCase('Acquisition')) {
                    isAcquisition = true;
                    program.RecordTypeId = Schema.SObjectType.Royall_Program__c.getRecordTypeInfosByName().get('Acquisition').getRecordTypeId();

                }
            }
            else{
                if(program!= null){
                    List<Program_Package__c> pkg = [SELECT Id, RecordType.Name FROM Program_Package__c WHERE Id = :program.Program_Package__c];
                    if(pkg.size() > 0){
                        if (pkg[0].RecordType.Name != null && pkg[0].RecordType.Name.equalsIgnoreCase('Acquisition')) {
                            isAcquisition = true;
                        }
                    }
                }
            }
            //return statement
            return null;  
        }
             
    }
    
    public String doRedirectStandardNewEditPage() {
        String isLightning = UserInfo.getUiTheme();
        
        //String variable to hold the attribute present in the current page URL
        String returnURL = ApexPages.currentPage().getParameters().get('retURL');

        //String variable to hold the attribute present in the current page URL
        String ent = ApexPages.currentPage().getParameters().get('ent');
        String newURL;
        newURL = '/aBZ/e?retURL=' + returnURL +'&RecordType='+program.recordTypeId + '&ent=' + ent + '&nooverride=1';
        
	//Check for parent field
        if(program.Program_Package__c != null){
        	
            //Get parent name field value
            String parentName = ApexPages.currentPage().getParameters().get('CF00NC0000006dZOM');
            
            //Popualate the parent field 
            newURL = newURL+ '&CF00NC0000006dZOM='+parentName+'&CF00NC0000006dZOM_lkid='+program.Program_Package__c;
        }
        
        //return statement
        return newURL;
        
    }
    
}