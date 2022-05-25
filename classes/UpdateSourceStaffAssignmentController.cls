/**
 *  Purpose         :   Controller for UpdateSourceStaffAssignment VF page. 
 * 
 *  Created By      :   Subhash Garhwal
 * 
 *  Created Date    :   07/02/2015 
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20150618-9014
 * 
 **/
public with sharing class UpdateSourceStaffAssignmentController {
    
    //Variable to hold source record Id
    public String sourceRecId {get;set;}
    
    //Constructor
    public UpdateSourceStaffAssignmentController() {
        
        sourceRecId = '';
    }
    
    /**
     *  @description    :   This method is to update source record end date with new record's Start Date - 1
     *
     *  @args           :
     *
     *  @return         :   PageR
     *
     **/
    public Pagereference redirect() {
        
        //Get Parameters from URL
        String sourceDetails = Apexpages.currentPage().getParameters().get('sourceId');
        String newId = Apexpages.currentPage().getParameters().get('newid');
            
        try {
        
            //Source details
            String sourceId;
            String cloneRPPs;
            
            //Check if string contains -
            if(String.isNotBlank(sourceDetails) && sourceDetails.contains('-')) {
                
                //Get source details
                sourceId =  sourceDetails.split('-')[0];
                cloneRPPs = sourceDetails.split('-')[1];
            }
            
            //Assign source Id
            sourceRecId = sourceId;
            
            //Check for URL parameters
            if(String.isNotBlank(sourceId) && String.isNotBlank(newId) && sourceId instanceof Id && newId instanceof Id) {
                
                //Query through new staff assignments
                List<Team_Membership__c> teamMemberships = [Select Id, Start_date__c, End_date__c From Team_Membership__c Where Id =: newId OR Id =: sourceId ORDER BY CreatedDate ASC ];
                
                //Check for size
                if(teamMemberships.size() == 2) {
                    
                    //Update source record
                    update new Team_Membership__c(Id = sourceId, End_date__c = teamMemberships[1].Start_date__c -1);
                
                    
                    //Check for clone String
                    if(String.isNotBlank(cloneRPPs) && cloneRPPs.equalsIgnoreCase('true')) {
                        
                        //SOQL String to  build dynamic query string for RPP
                        String SOQL = 'Select ';
                        
                        //Sobject getDescribe method to fatch all the RPP fields and add fields in SOQL query string
                        for(String rPPField : Role_Program_Perspective__c.getSobjectType().getDescribe().fields.getMap().KeySet())
                            SOQL +=  rPPField + ',';
                        
                        //Add Where clouse
                        SOQL = SOQL.removeEnd(',') + ' From Role_Program_Perspective__c Where Staff_Assignment__c =\'' + sourceId + '\'';
                        
                        //Query through RPP
                        List<Role_Program_Perspective__c> rPPs = Database.query(SOQL);
                        
                        //Check for RPP list
                        if(rPPs.size() > 0) {
                            
                            //Clone Role Program Perspective using Salesforce standard method deepClone
                            List<Role_Program_Perspective__c> clonedRPPs = rPPs.deepClone(false,true);
                            
                            //Check for Staff Assignment
                            if(teamMemberships.size() > 0) {
                                
                                //Loop through Clone RPPs list to assign RPP to new Staff Assignmet
                                for(Role_Program_Perspective__c rPP : clonedRPPs) {
                                    
                                    //Change Staff Assignment
                                    rPP.Staff_Assignment__c = newId;
                                    
                                    //Populate effective dates
                                    rPP.Effective_Start__c = teamMemberships[1].Start_date__c;
                                    rPP.Effective_End__c = teamMemberships[1].End_date__c;
                                }   
                            
                                //Insert cloned RPPs
                                insert clonedRPPs;
                            }
                        }
                        
                    }
                }
                //Return
                return new Pagereference('/' + newId);
            }
        }catch(DMLException dmlExp) {
            
            //Delete New Staff Assignment record
            delete [Select Id From Team_Membership__c Where Id =: newId];
            
            //Add Error on page
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,dmlExp.getDmlMessage(0)));
            return null;
            
        }catch(Exception e) {
            
            //Delete New Staff Assignment record
            delete [Select Id From Team_Membership__c Where Id =: newId];
            
            //Add Error on page
            ApexPages.addMessages(e);
            return null;
        }
        
        //Return
        return null;
    }
}