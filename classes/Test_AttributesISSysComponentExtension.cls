/**
    *   Purpose:   Test class for AttributesISComponent
    *               
    *   Created By:  Dipesh Gupta
    *    
    *   Revision Log: 	V1.1 - Created
    *					
    *
**/
@istest    
    public class Test_AttributesISSysComponentExtension {
	
    @testsetup static void mydata() {
       
        //Creating is system component. 
        IS_System_Component__c component1 = new IS_System_Component__c(Name = 'will auto-populate',
                                                                       Object_Label__c = 'Account',
                                                                       Object_API_Name__c = 'Account',
                                                                       Object_Type__c = 'Object',
                                                                       SOX_Object__c = TRUE);
        
        
        insert component1;
        
    }
    
    @istest static void checkAttributeIsSystemComponentExtension() {
        
        //Query is system component. 
        List<IS_System_Component__c> systemCom = [Select Id From IS_System_Component__c];
        System.assert(systemCom.size() == 1);
        
       ApexPages.StandardController sc = new ApexPages.StandardController(systemCom[0]);
       AttributesISSysComponentExtension attributeIsSystem = new AttributesISSysComponentExtension(sc);
        
    }
}