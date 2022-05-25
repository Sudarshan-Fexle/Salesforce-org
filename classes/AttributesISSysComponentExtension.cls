/**
*   Purpose:    Contains properties and methods referenced by the Visualforce page AttributesISComponent
*               
*   Created By:  Jason Bennett
*    
*    Revision Log: 	V1.0 - (Code Added)- Jason Bennett - 10/16/2015 - Created
*					V1.1 - (Code Added) - Victor Hanson - 11/5/2015 - Modified to make the class more dynamic using generic sobjects
*					V1.2 - Dipesh Gupta, applied the 			
*
**/
public class AttributesISSysComponentExtension {
    
    //Current record
    public sObject obj;
    public string objectType;
    
    /** attributes **/
    public boolean isSOX {get; set;}
    public boolean isIntegration {get; set;}
    public boolean isHighImpact {get; set;}
    public boolean isDoubleDeployment {get; set;}
    public boolean isManagedPackage {get; set;}
    public boolean isDuplicateModCR {get; set;}
    public boolean isDuplicateModRelease {get; set;}
    //Added by Colin McGloin - CR-20190403-12982
    public boolean isESMarketing {get; set;}
    public boolean isESCore {get; set;}
    //Added by Colin McGloin - CR-20190829-13294
    public boolean isXactly {get; set;}
    public boolean isXactlyComp {get; set;}
    
    public AttributesISSysComponentExtension(ApexPages.StandardController stdController){
        
        //Get the current record Id
        Id sysComponentId = stdController.getId();
        
        if(String.isBlank(sysComponentId))
            return;
        
        objectType = string.valueOf(sysComponentId.getSobjectType());
        system.debug('@@sysComponentId :'+sysComponentId + '  objectType:' + objectType);
        
        //Query all fields on the current record
        if(sysComponentId != null){
            Set<String> additionalFields = new Set<String>();
            //additionalFields.add('');
            string queryString = FieldDescribes.FullItemBaseQuery(objectType, additionalFields) + ' WHERE Id = \'' + sysComponentId + '\'';
            obj = database.query(queryString);
        }
        
        getAttributes();
        
    }
    
    /**
     * 
     * @description:	determine the attributes
     * 
     **/
    public void getAttributes() {
        
        //Modification Variables
        isSOX = getField('SOX_Object__c');
        isIntegration = getField('Integration_Use__c');
        isManagedPackage = getField('Managed_Package_Related__c');
        isHighImpact = getField('High_Impact_Mod__c');
        isDoubleDeployment = getField('Double_Deployment__c');
        isDuplicateModCR = getField('Duplicate_Mod_on_CR__c');
        isDuplicateModRelease = getField('Duplicate_Mod_on_Release__c');
        //Added by Colin McGloin - CR-20190403-12982
        isESMarketing = getField('ES_Marketing_Related__c');
        isESCore = getField('ES_Core_Related__c');
        //Added by Colin McGloin - CR-20190829-13294
        isXactly = getField('Xactly_Related__c');
        
        //Component Variables - if different API Names
        isXactlyComp = getField('Xactly_Integration__c');

    }
    
    /**
     * 
     * @description:	return true/false and catch any errors that may occur if attempting to get the value from a field that does not exist on the sObect
     * 
     **/
    public boolean getField(string fieldAPIName) {
        boolean fldVal = false;
        try {
            fldVal = (boolean)obj.get(fieldAPIName);
        }
        catch(Exception e) {
            //catch the error if the field is not available on the sobject
        }
        return fldVal;
    }
    
    /**
     * 
     * @description:	add icons to the page
     * 
     **/
     //Commented out by Colin McGloin - CR-20190403-12982
     /*
    public Component.Apex.OutputPanel getDynamicOutputPanel() {
        Component.Apex.OutputPanel dynPanel = new Component.Apex.OutputPanel(style='display:block; margin-left:18%;');
        
        //create attribute image controls based on field value, and add to the dynamic panel
        if(isSOX){
            Component.Apex.Image imgSOX = AttributesIcon.createAttributeImage('HasSOXObject');
            dynPanel.childComponents.add(imgSOX);
        }
        if(isIntegration){
            Component.Apex.Image imgIntegration = AttributesIcon.createAttributeImage('HasIntegration');
            dynPanel.childComponents.add(imgIntegration);
        }
        if(isManagedPackage){
            Component.Apex.Image imgManagedPackage = AttributesIcon.createAttributeImage('HasManagedPackage');
            dynPanel.childComponents.add(imgManagedPackage);
        }
        if(isHighImpact){
            Component.Apex.Image imgHighImpact = AttributesIcon.createAttributeImage('HasHighImpact');
            dynPanel.childComponents.add(imgHighImpact);
        }
        if(isDoubleDeployment){
            Component.Apex.Image imgDoubleDeployment = AttributesIcon.createAttributeImage('HasDoubleDeployment');
            dynPanel.childComponents.add(imgDoubleDeployment);
        }
        if(isDuplicateModCR){
            Component.Apex.Image imgDuplicateModCR = AttributesIcon.createAttributeImage('HasDuplicateModCR');
            dynPanel.childComponents.add(imgDuplicateModCR);
        }
        if(isDuplicateModRelease){
            Component.Apex.Image imgDuplicateModRelease = AttributesIcon.createAttributeImage('HasDuplicateModRelease');
            dynPanel.childComponents.add(imgDuplicateModRelease);
        }
        
        return dynPanel;
    }*/
    
}