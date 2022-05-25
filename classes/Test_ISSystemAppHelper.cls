/**
 * Desription      :   	test class for the ISSystemHelper class
 * 
 * Revision Logs   :   	v1.0 - Victor Hanson - 11/05/2015 - Created
 **/
@isTest
public class Test_ISSystemAppHelper {
	
    public static final string systemName = 'Salesforce';
    public static final string appName = 'App';
    public static final string processName = 'Reference Vetting';
    
    @testSetup
    static void setup() {
        //create the is system app (system)
        IS_System__c isSys = new IS_System__c(RecordTypeId = Schema.SObjectType.IS_System__c.getRecordTypeInfosByName().get('System').getRecordTypeId(),
                                              Name = systemName,
                                              Short_Name__c = 'SF',
                                              Status__c = 'Active',
                                              Type__c = 'Platform');
        insert isSys;
        
        //create the is system app (app)
        IS_System__c isSysApp = new IS_System__c(RecordTypeId = Schema.SObjectType.IS_System__c.getRecordTypeInfosByName().get('Application').getRecordTypeId(),
                                                 Name = appName,
                                                 Primary_System__c = isSys.Id,
                                                 Short_Name__c = 'RefTracking',
                                                 Status__c = 'Pre-Launch');
        insert isSysApp;
       
        //create the is function
        //IS_Business_Process__c isProcess = new IS_Business_Process__c(RecordTypeId = Schema.SObjectType.IS_Business_Process__c.getRecordTypeInfosByName().get('Business Process').getRecordTypeId(),
        //                                                              Name = processName,
        //                                                              //Parent_System__c = isSysApp.Id,
        //                                                              Status__c = 'Active',
        //                                                              Initial_Launch_Date__c = date.today());
        //insert isProcess; 
    }
    
    /**
     * @description: 
     **/
    static testmethod void testInactiveParent() {
        //get the is system
        IS_System__c isSys = [SELECT id, Status__c FROM IS_System__c WHERE Name = :systemName];
        isSys.Status__c = ISSystemAppHelper.SYSTEM_APP_STATUS_INACTIVE;
        isSys.Out_of_Service_Date__c = date.today();
        string err;
        //log the error message when updating
        try {
            update isSys;
        }
        catch(Exception e) {
            err = e.getMessage();
        }
        system.assert(err.containsIgnoreCase(Label.IS_System_App_Active_Child_Error), 'Should have thrown an error.');
        
        //get the is system app
        //IS_System__c isSysApp = [SELECT id, Status__c, Out_of_Service_Date__c FROM IS_System__c WHERE Name = :appName];
        //isSysApp.Status__c = ISSystemAppHelper.SYSTEM_APP_STATUS_INACTIVE;
        //isSysApp.Out_of_Service_Date__c = date.today();
        //err = null;
        ////log the error message when updating
        //try {
        //    update isSysApp;
        //}
        //catch(Exception e) {
        //    err = e.getMessage();
        //}
        //system.assert(err.containsIgnoreCase(Label.IS_System_App_Active_Child_Error), 'Should have thrown an error.');
        
        //get the is system app and update it to inactive, then update the is system
        IS_System__c isSysApp = [SELECT id, Status__c, Out_of_Service_Date__c FROM IS_System__c WHERE Name = :appName];
        isSysApp.Status__c = ISSystemAppHelper.SYSTEM_APP_STATUS_INACTIVE;
        isSysApp.Out_of_Service_Date__c = date.today();
        err = null;
        //log any error that mayoccur
        try {
            update isSysApp;
        }
        catch(Exception e) {
            err = e.getMessage();
        }
        system.assertEquals(null, err);
        
        //now that the is process is inactive, update the is app to inactive
        try {
            update isSys;
        }
        catch(Exception e) {
            err = e.getMessage();
        }
        system.assertEquals(null, err); 
    }

}