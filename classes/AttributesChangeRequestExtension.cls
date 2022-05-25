/**
*   Purpose:    Contains properties and methods referenced by the Visualforce page AttributesChangeRequest
*               
*   Created By:  Jason Bennett
*    
*    Revision Log: 	V1.0 - (Code Added)- Jason Bennett - 12/03/2015 - Created
*                   V1.1 - Modified By - Colin McGloin - 04/23/2019 - CR-20190403-12982 - Added ES Core & ES Marketing Attributes and modified code to display Lightning Icons
*					V1.2 - Modified By - Dipesh Gupta - 10/09/2019 - CR-20190829-13294 - Added new Xactly_Related__c field to the query on IS Modification in constructor
*					V1.3 - Modified By - Dipesh Gupta - 10/09/2019 - CR-20190829-13294 - Added "hasXactlyMod" attribute for Xactly in the getAttributes method and populate it to True using the
*																	 same logic for all other fields (based on Xactly Related field)
*
**/
public class AttributesChangeRequestExtension {
    
    //Current record
    public list<IS_System_Modification__c> ism;
    public string objType;
    public sObject obj;
    
    /** attributes **/
    public boolean hasSOX {get; set;}
    public boolean hasIntegration {get; set;}
    public boolean hasHighImpact {get; set;}
    public boolean hasDoubleDeployment {get; set;}
    public boolean hasManagedPackage {get; set;}
    public boolean hasDuplicateModCR {get; set;}
    public boolean hasDuplicateModRelease {get; set;}
    //Added by Colin McGloin - CR-20190403-12982
    public boolean hasESMarketing {get; set;}
    public boolean hasESCore {get; set;}
    // Added by Dipesh Gupta - CR-20190829-13294
    public boolean hasXactlyMod {get; set;}
    
    public AttributesChangeRequestExtension(ApexPages.StandardController stdController){
        
        //Get the current record Id
        Id recordId = stdController.getId();
        system.debug('AttributesChangeRequestExtension - @@recordId :'+recordId);
        
        //Query for all related all fields on the current record
        ism = new list<IS_System_Modification__c>();
        if(recordId != null){
        	if(recordId.getSobjectType() == SFDC_Change_Request__c.getSobjectType()){
	        	objType = 'SFDC_Change_Request__c';
	        	ism = [SELECT Id, SOX_Object__c, Integration_Use__c, Managed_Package_Related__c, High_Impact_Mod__c, Double_Deployment__c, Duplicate_Mod_on_CR__c, 
                        Duplicate_Mod_on_Release__c, ES_Marketing_Related__c, ES_Core_Related__c, Xactly_Related__c
	        			FROM IS_System_Modification__c WHERE Change_Request__c = :recordId];
        	}else if (recordId.getSobjectType() == SFDC_Release__c.getSobjectType()){
	        	objType = 'SFDC_Release__c';
	        	ism = [SELECT Id, SOX_Object__c, Integration_Use__c, Managed_Package_Related__c, High_Impact_Mod__c, Double_Deployment__c, Duplicate_Mod_on_CR__c, 
                        Duplicate_Mod_on_Release__c, ES_Marketing_Related__c, ES_Core_Related__c, Xactly_Related__c
	        			FROM IS_System_Modification__c WHERE Change_Request__r.Release__c = :recordId];
	        }
        }
        system.debug('AttributesChangeRequestExtension - ism: ' + ism);
        
        getAttributes();
        
    }
    
    /**
     * 
     * @description:	determine the attributes
     * 
     **/
    public void getAttributes() {

        //Set out Attributes to false
        hasSOX = false;
        hasIntegration = false;
        hasHighImpact = false;
        hasDoubleDeployment = false;
        hasManagedPackage = false;
        hasDuplicateModCR = false;
        hasDuplicateModRelease = false;
        hasESMarketing = false;
        hasESCore = false;
        hasXactlyMod = false;

        //Run through our Mods and check as needed 
        for(IS_System_Modification__c i : ism) {
        	if(i.SOX_Object__c) hasSOX = TRUE;
        	if(i.Integration_Use__c) hasIntegration = TRUE;
        	if(i.Managed_Package_Related__c) hasManagedPackage = TRUE;
        	if(i.High_Impact_Mod__c) hasHighImpact = TRUE;
        	if(i.Double_Deployment__c) hasDoubleDeployment = TRUE;
        	if(i.Duplicate_Mod_on_CR__c) hasDuplicateModCR = TRUE;
        	if(i.Duplicate_Mod_on_Release__c) hasDuplicateModRelease = TRUE;
            if(i.ES_Marketing_Related__c) hasESMarketing = TRUE;
            if(i.ES_Core_Related__c) hasESCore = TRUE;
            if(i.Xactly_Related__c) hasXactlyMod = TRUE;
        	}

    }
    
    
    /**
     * 
     * @description:	add icons to the page
     * 
     **/
     //Commented out by Colin McGloin - CR-20190403-12982
    /*public Component.Apex.OutputPanel getDynamicOutputPanel() {
        Component.Apex.OutputPanel dynPanel = new Component.Apex.OutputPanel(style='display:block; margin-left:18%;');
        
        //create attribute image controls based on field value, and add to the dynamic panel
        if(hasSOX){
            Component.Apex.Image imgSOX = AttributesIcon.createAttributeImage('HasSOXObject');
            dynPanel.childComponents.add(imgSOX);
        }
        if(hasIntegration){
            Component.Apex.Image imgIntegration = AttributesIcon.createAttributeImage('HasIntegration');
            dynPanel.childComponents.add(imgIntegration);
        }
        if(hasManagedPackage){
            Component.Apex.Image imgManagedPackage = AttributesIcon.createAttributeImage('HasManagedPackage');
            dynPanel.childComponents.add(imgManagedPackage);
        }
        if(hasHighImpact){
            Component.Apex.Image imgHighImpact = AttributesIcon.createAttributeImage('HasHighImpact');
            dynPanel.childComponents.add(imgHighImpact);
        }
        if(hasDoubleDeployment){
            Component.Apex.Image imgDoubleDeployment = AttributesIcon.createAttributeImage('HasDoubleDeployment');
            dynPanel.childComponents.add(imgDoubleDeployment);
        }
        if(hasDuplicateModCR){
            Component.Apex.Image imgDuplicateModCR = AttributesIcon.createAttributeImage('HasDuplicateModCR');
            dynPanel.childComponents.add(imgDuplicateModCR);
        }
        if(objType == 'SFDC_Release__c'){
        	if(hasDuplicateModRelease){
            	Component.Apex.Image imgDuplicateModRelease = AttributesIcon.createAttributeImage('HasDuplicateModRelease');
            	dynPanel.childComponents.add(imgDuplicateModRelease);
        	}
        }
        
        return dynPanel;
    }*/
    
}