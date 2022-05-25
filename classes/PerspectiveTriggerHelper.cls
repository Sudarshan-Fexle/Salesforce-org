/**
 *  Description     :  Helper class for Trigger_Perspective trigger.
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  06/25/2015
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20150618-9014           
 *                      V_1.0 - Added - Subhash Garhwal - 08/04/2015 - CR-20150729-9114 - incentiveChangeLog method called
 *                      V_1.1 - Modified - Rajeev Jain - 04/19/2016 - CR-20151120-9402 - Removed incentiveChangeLog method usage
 **/
public without sharing class PerspectiveTriggerHelper {

    /**
     *  @description    :   Method to check Perspective name. The Name value must be unique across all Perspective
     *
     *  @args           :   List<Perspective__c>, Map<Id, Perspective__c>
     *
     *  @return         :   void
     *
     **/
    public static void validatePerspective(List<Perspective__c> perspectives, Map<Id, Perspective__c> mapOldPerspectives) {
        
        //Set to hold Perspective name
        Set<String> setPerspectiveName = new Set<String>();

        //Loop through the Group Purpose
        for(Perspective__c pers : perspectives) {
            
            //Check appropriate condition
            if(mapOldPerspectives == null || pers.Name != mapOldPerspectives.get(pers.Id).Name) {
                
                //Check Perspective name in set
                if(setPerspectiveName.contains(pers.Name))
                    throw new CustomException(Label.DUPLICATE_PERSPECTIVE);
                
                //Add Perspective name in set
                setPerspectiveName.add(pers.Name);
            }
        }

        //Query through the Group Purpose
        List<Perspective__c> perspective = [Select Id, Name From Perspective__c Where Name IN : setPerspectiveName LIMIT 1];
        
        //Check for list size
        if(perspective.size() > 0) {
            
            //Throw exception
            throw new CustomException(Label.DUPLICATE_PERSPECTIVE);
        }
    }

    /**
     *  @description    :   Method to check related Program Perspective's In Use values on record delation, If "In Use" values > 0, then throw error.
     *
     *  @args           :   List<Program_Group__c>
     *
     *  @return         :   void
     *
     **/
    public static void validateBeforeDelete(List<Perspective__c> perspectives) {

        //Query through Program_Perspective__c
        List<Program_Perspective__c> programPerspectives = [Select Id, In_use_Plans_Direct__c, In_use_Plans_Indirect__c, In_use_Staff_Direct__c, In_use_Staff_Indirect__c From Program_Perspective__c Where (Perspective__c != null AND Perspective__c IN: perspectives AND (In_use_Plans_Direct__c > 0 OR In_use_Plans_Indirect__c > 0 OR In_use_Staff_Direct__c > 0 OR In_use_Staff_Indirect__c > 0)) LIMIT 1]; 
        
        //If there is any Program Perspective which is having In Use value > 0, throw an eror message to user
        if(programPerspectives.size() > 0)
            throw new CustomException(Label.PERSPECTIVE_IN_USE);
    }
    
    //Code added 08/04/2015 - Subhash Garhwal - CR-20150729-9114 - Added new incentiveChangeLog method
    //Code Commented By - Rajeev Jain - 04/19/2016 - CR-20151120-9402
    /**
     *  @description    :   This method is used to create Incentive Change Log when Short name and Effective Dates change.
     *  
     *  @args           :   List<Program_Group__c>, map<Id, Program_Group__c>
     *
     *  @return         :   void
     *
     **/
    /* public static void incentiveChangeLog(List<Perspective__c> perspectives,Map<Id, Perspective__c> mapOldPerspective){
        
        //List of Incentive Change Log
        List<Incentive_Change_Log__c> insertIcg = new List<Incentive_Change_Log__c>();
        
        //Loop Through Trigger.new
         for(Perspective__c perspective : perspectives){
            
            //Check Short Name modified
            if(perspective.Short_Name__c != mapOldPerspective.get(perspective.Id).Short_Name__c){
                
                //List to insert ICL
                insertIcg.add(new Incentive_Change_Log__c(Perspective__c = perspective.Id, Change_Type__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_TEXT));
            }
         }
         
         //Insert ICG
         insert insertIcg;
     }*/        
}