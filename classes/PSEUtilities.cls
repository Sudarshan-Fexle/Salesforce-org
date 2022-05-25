/**
 *  Description     :   Apex class to hold Utilities methods associated with pse (namespace) objects. 
 * 
 *  Created By      :   Abhinav Sharma    
 * 
 *  Created Date    :   01/24/2017
 * 
 *  Revision Logs   :   V_1.0 - Created
 * 			V_1.1 - Modified by Colin McGloin - Added method to allow records to be mass approved from List View
 *                      V_1.2 - Removed all Legacy Sharing Code (Backup Code stored on CR-20201020-14618), Added method for adding user to Public Groups based on Practice set on Contact record
 *
**/ 
public without sharing class PSEUtilities {
    
    /**
     *  @description    :   Method to :-
	 * 							a) Add "Edit" manual sharing access for pse__Resource__r.pse__Salesforce_User__c on the associated project record. 
     * 
     *  @args           :   Set<Id> setOfResourcesIds, Set<Id> setOfProjectsIds, List<pse__Assignment__c> listOfRLSAssignments
     * 
     *  @return         :   void
     * 
     * Version          : V1.1 - Modified by Abhinav Sharma - 10/31/2018 - Issue--CR12599--QA--00008503, CR-20180917-12599 
     * 					  Modified the method to comment the references of "pse__Proj__Share", changing sharing setting for the object from Private to the Read/Write. 
    **/ 
    public static void syncUpManualSharingForProjects(Set<Id> setOfResourcesIds, Set<Id> setOfProjectsIds, List<pse__Assignment__c> listOfRLSAssignments) {
            
    	//Checking list for it's size
       /* if(listOfRLSAssignments != null && listOfRLSAssignments.size() > 0 && setOfResourcesIds !=null && setOfResourcesIds.size() > 0) {
            
            //Map to hold the resource ID as key and corresponding user record ID as value
            Map<Id, Id> sfUsersByResource = new Map<Id, Id>();
            
            //Checking set for null and size value
            if(setOfResourcesIds != null && setOfResourcesIds.size() > 0)
                sfUsersByResource = PSEUtilities.retrieveUserForTheResource(setOfResourcesIds);
            
            //Set to hold the UserOrGroupId and ParentId as value
            //Set<String> setOfResourcesAndProjectsIdsKeys = new Set<String>();
            
            //Checking set for null and size value
            if(setOfProjectsIds != null && setOfProjectsIds.size() > 0 && sfUsersByResource != null && sfUsersByResource.values().size() > 0)
            	setOfResourcesAndProjectsIdsKeys = PSEUtilities.retrieveExistingProjectShareRecords(sfUsersByResource, setOfProjectsIds);
            
            //V1.1 - Modified by Abhinav Sharma - 10/31/2018 - Issue--CR12599--QA--00008503, CR-20180917-12599 
            //List of new project manual sharing records
            //List<pse__Proj__Share> newProjectShares = new List<pse__Proj__Share>();
               
            //Checking list for size value
            if(listOfRLSAssignments.size() > 0) {
                
                //Loop through assignment records
                for (pse__Assignment__c assignment : listOfRLSAssignments) {
                    
                    //Checking for the resource and project field value for null/blank
                    if (assignment.pse__Resource__c != null && assignment.pse__Project__c != null) {
                        
                        //Checking for key presence in the map
                        if (sfUsersByResource.containsKey(assignment.pse__Resource__c)
                        	&& sfUsersByResource.get(assignment.pse__Resource__c) != null
                        ) {
                            
                            //Temp string to hold the key string
                            String resourceAndProject = String.valueOf(sfUsersByResource.get(assignment.pse__Resource__c)) + String.valueOf(assignment.pse__Project__c);
                            
                            //Checking for key presence in the map
                            if (!setOfResourcesAndProjectsIdsKeys.contains(resourceAndProject)) {
								
								//Adding new sharing records into the list
                                newProjectShares.add(new pse__Proj__Share(ParentId = assignment.pse__Project__c,
                                                                          UserOrGroupId = sfUsersByResource.get(assignment.pse__Resource__c),
                                                                          RowCause = Schema.pse__Proj__Share.RowCause.pse__PSE_Member_Share__c,
                                                                          AccessLevel = 'Edit'
                                                                         )); 
                            }
                        }
                    }
                }
                
               //Checking list for size and null value
                if (newProjectShares != null && newProjectShares.size() > 0) {
                    Util.byPassAllTriggers = true;
                    insert newProjectShares;
                    Util.byPassAllTriggers = false;
                } 
            }
        }*/
    }
    
    /**
     *  @description    :   Method to :-
	 * 							a) Add "Edit" manual sharing access for pse__Project_Manager__r.pse__Salesforce_User__c of the associated project on the expense record.
	 *							b) Add "Edit" manual sharing access for Group_Manager__c of the associated project on the expense record.
	 *							
	 *							//Added via CR-20170109-10604
	 *                          c) Add "Read" manual sharing access for Group_Manager__r.ManagerId of the associated project on the expense record.
	 *                          d) Add "Read" manual sharing access for pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId of the associated project on the expense record.
	 *							e) Add "Read" manual sharing access for owner user's manager (owner.Manager) on the context record itself.
     *
     *  @args           :   Set<Id> setOfProjectsIds, List<pse__Expense__c> listOfRLSExpenses, Set<Id> setOfResourcesIds
     * 
     *  @return         :   void
     * 
    **/ 
    public static void syncUpManualSharingForExpenses(Set<Id> setOfProjectsIds, List<pse__Expense__c> listOfRLSExpenses, Set<Id> setOfResourcesIds) {
    	
        //Checking for null and size value
    	if(listOfRLSExpenses != null && listOfRLSExpenses.size() > 0) {
    		
    		//Share with PM (List to hold the manual sharing records)
            List<pse__Expense__Share> eShares = new List<pse__Expense__Share>();
            
            //Set to maintain the uniqueness in between the manual sharing records
            Set<String> setToMaintainTheUniqueness = new Set<String>();
            
            //Set to hold the users IDs
            Set<Id> setOfUsersIds = new Set<Id>();
            
            //Map of projects
            Map<Id, pse__Proj__c> mapOfProjects = new Map<Id, pse__Proj__c>();
	
    		//Checking for size and null value
    		if(setOfProjectsIds != null && setOfProjectsIds.size() > 0) {
    			
    			//Map to hold the projects details
	            mapOfProjects = new Map<Id, pse__Proj__c>([SELECT Id,
                                                           pse__Project_Manager__c, pse__Project_Manager__r.pse__Salesforce_User__r.IsActive,
                                                           pse__Project_Manager__r.pse__Salesforce_User__c,
                                                           pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId,
                                                           Group_Manager__c, Group_Manager__r.ManagerId
                                                           FROM pse__Proj__c
                                                           WHERE Id IN : setOfProjectsIds
                                                          ]);
            }    
	
            //Loop through expense records
            for (pse__Expense__c expense : listOfRLSExpenses) {
                    
                //Adding owner user ID in the set
                if(expense.OwnerId != null)
                    setOfUsersIds.add(expense.OwnerId);
	
                //Checking for key presence
                if (expense.pse__Project__c != null 
                    && mapOfProjects.containsKey(expense.pse__Project__c)
                    && mapOfProjects.get(expense.pse__Project__c) != null		
                ) {
							
                	//Project	
                    pse__Proj__c project = mapOfProjects.get(expense.pse__Project__c);
                       
                    //Checking for null value
                    if (project.pse__Project_Manager__c != null 
                        && 
                        project.pse__Project_Manager__r.pse__Salesforce_User__c != null 
                        &&
                        project.pse__Project_Manager__r.pse__Salesforce_User__r.IsActive
                           
                    ) {
	                    	
                        //a) Add "Edit" manual sharing access for pse__Project_Manager__r.pse__Salesforce_User__c of the associated project on the expense record.
                        //Checking with respect to expense record owner to see the difference in between values
                        //Since owner of a record by defult have full access of the records
                        if(expense.OwnerId != project.pse__Project_Manager__r.pse__Salesforce_User__c) {
                            
                            //Adding "project.pse__Project_Manager__r.pse__Salesforce_User__c" user instance to the set
                            setToMaintainTheUniqueness.add(expense.Id + ' ' + project.pse__Project_Manager__r.pse__Salesforce_User__c);
                            
                            //Sharing record instance
                            pse__Expense__Share eShare = new pse__Expense__Share(
                                ParentId = expense.Id,
                                UserOrGroupId = project.pse__Project_Manager__r.pse__Salesforce_User__c,
                                RowCause = Schema.pse__Expense__Share.RowCause.pse__PSE_PM_Share__c,
                                AccessLevel = 'Edit'
                            );
                            
                            //Adding record into the list    
                            eShares.add(eShare);
                        }
                    }
						
                    //Checking field for the null value
                    if (project.Group_Manager__c != null) {
                        
                        //b) Add "Edit" manual sharing access for Group_Manager__c of the associated project on the assignment record.
                        //Checking "Group Manager" for eligibility
                        if(expense.OwnerId != project.Group_Manager__c
                           && !setToMaintainTheUniqueness.contains(expense.Id + ' ' + project.Group_Manager__c)
                        ) {
                              
                        	//Adding "project.Group_Manager__c" user instance to the set
                            setToMaintainTheUniqueness.add(expense.Id + ' ' + project.Group_Manager__c);
                            
                            //Expense Share records
                            pse__Expense__Share eShare2 = new pse__Expense__Share(
                                ParentId = expense.Id,
                                UserOrGroupId = project.Group_Manager__c,
                                RowCause = Schema.pse__Expense__Share.RowCause.pse__PSE_Member_Share__c,
                                AccessLevel = 'Edit'
                            );
		
                            //Adding record into the list 
                            eShares.add(eShare2);		
                        }
                        		                    	 
                        //c) Add "Read" manual sharing access for Group_Manager__r.ManagerId of the associated project on the expense record.
                        //Checking "Group Manager" manager for eligibility
                        if(project.Group_Manager__r.ManagerId != null
                           && expense.OwnerId != project.Group_Manager__r.ManagerId
                           && !setToMaintainTheUniqueness.contains(expense.Id + ' ' + project.Group_Manager__r.ManagerId)
                        ) {
                               
                            //Adding "project.Group_Manager__c" user instance to the set
                            setToMaintainTheUniqueness.add(expense.Id + ' ' + project.Group_Manager__r.ManagerId);
                               
                            //Expense Share records
                            pse__Expense__Share eShare3 = new pse__Expense__Share(
                                ParentId = expense.Id,
                                UserOrGroupId = project.Group_Manager__r.ManagerId,
                                RowCause = Schema.pse__Expense__Share.RowCause.pse__PSE_Member_Share__c,
                                AccessLevel = 'Read'
                            );
		                        
                            //Adding record into the list 
                            eShares.add(eShare3);
                        }
                    } 
	                    
                    //Checking for null value
                    if (project.pse__Project_Manager__c != null 
                        && 
                        project.pse__Project_Manager__r.pse__Salesforce_User__c != null 
                        &&
                        project.pse__Project_Manager__r.pse__Salesforce_User__r.IsActive
                    ) {
	                    
                    	//d) Add "Read" manual sharing access for pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId of the associated project on 
                        //the expense record.
                        //Checking for uniqueness with respect to the set existing values
                        if(project.pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId != null
                           &&
                           !setToMaintainTheUniqueness.contains(expense.Id + ' ' + project.pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId)
                           &&
                           project.pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId != expense.OwnerId
                        ) {
		                        	
                            //Adding "project.pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId" user instance to the set
                            setToMaintainTheUniqueness.add(expense.Id + ' ' + project.pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId);
                            
                            //Sharing record instance
                            pse__Expense__Share eShare4 = new pse__Expense__Share(
                                ParentId = expense.Id,
                                UserOrGroupId = project.pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId,
                                RowCause = Schema.pse__Expense__Share.RowCause.pse__PSE_PM_Share__c,
                                AccessLevel = 'Read'
                            );
		                        
                            //Adding record into the list 
                            eShares.add(eShare4);
                        }		
	                }
	            }
			}
            
            //e) Add "Read" manual sharing access for owner user's manager (owner.Manager) on the context record itself.
 			//Checking set for it's size value
            if(setOfUsersIds.size() > 0) {
                
                //Map of Users
                Map<Id, User> mapOfUsers = new Map<Id, User>();
                
                //Loop through user records
        		for(User usr : [SELECT ID, ManagerId 
                                FROM User 
                                WHERE ID IN : setOfUsersIds])
                    mapOfUsers.put(usr.Id, usr);
                
                //Checking for size value
                if(mapOfUsers.values().size() > 0) {
                    
                    //Loop through expense records
            		for (pse__Expense__c exp : listOfRLSExpenses) {
                        
                        //Checking for key presence in the map and for the null value
                        if(exp.OwnerId != null 
                        	&& mapOfUsers.containsKey(exp.OwnerId)
                        	&& mapOfUsers.get(exp.OwnerId) != null
                        ) {
                        	
                            //Checking "Manager" for eligibility
                            if(mapOfUsers.get(exp.OwnerId).ManagerId != null
                            	&&
                            	!setToMaintainTheUniqueness.contains(exp.Id + ' ' + mapOfUsers.get(exp.OwnerId).ManagerId)
                            	&&
                                mapOfUsers.get(exp.OwnerId).ManagerId != exp.OwnerId
                            ) {
                               
                            	//Adding "project.pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId" user instance to the set
                                setToMaintainTheUniqueness.add(exp.Id + ' ' + mapOfUsers.get(exp.OwnerId).ManagerId);
            
                                //Sharing record instance
                                pse__Expense__Share eShare5 = new pse__Expense__Share(
                                    ParentId = exp.Id,
                                    UserOrGroupId = mapOfUsers.get(exp.OwnerId).ManagerId,
                                    RowCause = Schema.pse__Expense__Share.RowCause.pse__PSE_PM_Share__c,
                                    AccessLevel = 'Read'
                                );
                                    
                                //Adding record into the list 
                                eShares.add(eShare5);    
                            }
                        }
                    }
            	}
            }
            
            //Checking for size and null value
            if (eShares != null && eShares.size() > 0) {
                Util.BypassAllTriggers = true;
                insert eShares;
                Util.BypassAllTriggers = false;
            }
        }		
    }
    
    /**
     *  @description    :   Method to :-
	 * 							a) Add "Edit" manual sharing access for pse__Project_Manager__r.pse__Salesforce_User__c of the associated project on the expense report record.
	 *							b) Add "Edit" manual sharing access for Group_Manager__c of the associated project on the expense report record.
	 *							
	 *							//Added via CR-20170109-10604
	 *                          c) Add "Read" manual sharing access for Group_Manager__r.ManagerId of the associated project on the expense report record.
	 *                          d) Add "Read" manual sharing access for pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId of the associated project on the expense report record.
	 *							e) Add "Read" manual sharing access for owner user's manager (owner.Manager) on the context record itself.
     *
     *  @args           :   Set<Id> setOfProjectsIds, List<pse__Expense_Report__c> listOfRLSExpenseReports, Set<Id> setOfResourcesIds
     * 
     *  @return         :   void
     * 
    **/ 
    public static void syncUpManualSharingForExpenseReports(Set<Id> setOfProjectsIds, List<pse__Expense_Report__c> listOfRLSExpenseReports, Set<Id> setOfResourcesIds) {
    	
        //Checking for null and size value
    	if(listOfRLSExpenseReports != null && listOfRLSExpenseReports.size() > 0) {
    		
    		//Share with PM (List to hold the manual sharing records)
            List<pse__Expense_Report__Share> eShares = new List<pse__Expense_Report__Share>();
            
            //Set to maintain the uniqueness in between the manual sharing records
            Set<String> setToMaintainTheUniqueness = new Set<String>();
            
            //Set to hold the users IDs
            Set<Id> setOfUsersIds = new Set<Id>();
            
            //Map of projects
            Map<Id, pse__Proj__c> mapOfProjects = new Map<Id, pse__Proj__c>();
	
    		//Checking for size and null value
    		if(setOfProjectsIds != null && setOfProjectsIds.size() > 0) {
    			
    			//Map to hold the projects details
	            mapOfProjects = new Map<Id, pse__Proj__c>([SELECT Id,
                                                           pse__Project_Manager__c, pse__Project_Manager__r.pse__Salesforce_User__r.IsActive,
                                                           pse__Project_Manager__r.pse__Salesforce_User__c,
                                                           pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId,
                                                           Group_Manager__c, Group_Manager__r.ManagerId
                                                           FROM pse__Proj__c
                                                           WHERE Id IN : setOfProjectsIds
                                                          ]);
            }    
	
            //Loop through expense report records
            for (pse__Expense_Report__c expenseR : listOfRLSExpenseReports) {
                    
                //Adding owner user ID in the set
                if(expenseR.OwnerId != null)
                    setOfUsersIds.add(expenseR.OwnerId);
	
                //Checking for key presence
                if (expenseR.pse__Project__c != null 
                    && mapOfProjects.containsKey(expenseR.pse__Project__c)
                    && mapOfProjects.get(expenseR.pse__Project__c) != null		
                ) {
							
                	//Project	
                    pse__Proj__c project = mapOfProjects.get(expenseR.pse__Project__c);
                       
                    //Checking for null value
                    if (project.pse__Project_Manager__c != null 
                        && 
                        project.pse__Project_Manager__r.pse__Salesforce_User__c != null 
                        &&
                        project.pse__Project_Manager__r.pse__Salesforce_User__r.IsActive
                           
                    ) {
	                    	
                        //a) Add "Edit" manual sharing access for pse__Project_Manager__r.pse__Salesforce_User__c of the associated project on the expense report record.
                        //Checking with respect to expense record owner to see the difference in between values
                        //Since owner of a record by defult have full access of the records
                        if(expenseR.OwnerId != project.pse__Project_Manager__r.pse__Salesforce_User__c) {
                            
                            //Adding "project.pse__Project_Manager__r.pse__Salesforce_User__c" user instance to the set
                            setToMaintainTheUniqueness.add(expenseR.Id + ' ' + project.pse__Project_Manager__r.pse__Salesforce_User__c);
                            
                            //Sharing record instance
                            pse__Expense_Report__Share eShare = new pse__Expense_Report__Share(
                                                                    ParentId = expenseR.Id,
                                                                    UserOrGroupId = project.pse__Project_Manager__r.pse__Salesforce_User__c,
                                                                    RowCause = Schema.pse__Expense_Report__Share.RowCause.pse__PSE_PM_Share__c,
                                                                    AccessLevel = 'Edit'
                            );
                            
                            //Adding record into the list    
                            eShares.add(eShare);
                        }
                    }
						
                    //Checking field for the null value
                    if (project.Group_Manager__c != null) {
                        
                        //b) Add "Edit" manual sharing access for Group_Manager__c of the associated project on the expense report record.
                        //Checking "Group Manager" for eligibility
                        if(expenseR.OwnerId != project.Group_Manager__c
                           && !setToMaintainTheUniqueness.contains(expenseR.Id + ' ' + project.Group_Manager__c)
                        ) {
                              
                        	//Adding "project.Group_Manager__c" user instance to the set
                            setToMaintainTheUniqueness.add(expenseR.Id + ' ' + project.Group_Manager__c);
                            
                            //Expense report Share records
                            pse__Expense_Report__Share eShare2 = new pse__Expense_Report__Share(
                                                                    ParentId = expenseR.Id,
                                                                    UserOrGroupId = project.Group_Manager__c,
                                                                    RowCause = Schema.pse__Expense_Report__Share.RowCause.pse__PSE_Member_Share__c,
                                                                    AccessLevel = 'Edit'
                            );
		
                            //Adding record into the list 
                            eShares.add(eShare2);		
                        }
	                    		                    	
                        //c) Add "Read" manual sharing access for Group_Manager__r.ManagerId of the associated project on the expense report record.
                        //Checking "Group Manager" manager for eligibility
                        if(project.Group_Manager__r.ManagerId != null
                           && expenseR.OwnerId != project.Group_Manager__r.ManagerId
                           && !setToMaintainTheUniqueness.contains(expenseR.Id + ' ' + project.Group_Manager__r.ManagerId)
                        ) {
                               
                            //Adding "project.Group_Manager__c" user instance to the set
                            setToMaintainTheUniqueness.add(expenseR.Id + ' ' + project.Group_Manager__r.ManagerId);
                               
                            //Expense report Share records
                            pse__Expense_Report__Share eShare3 = new pse__Expense_Report__Share(
                                                                            ParentId = expenseR.Id,
                                                                            UserOrGroupId = project.Group_Manager__r.ManagerId,
                                                                            RowCause = Schema.pse__Expense_Report__Share.RowCause.pse__PSE_Member_Share__c,
                                                                            AccessLevel = 'Read'
                            );
		                        
                            //Adding record into the list 
                            eShares.add(eShare3);
                        }
                    } 
	                    
                    //Checking for null value
                    if (project.pse__Project_Manager__c != null 
                        && 
                        project.pse__Project_Manager__r.pse__Salesforce_User__c != null 
                        &&
                        project.pse__Project_Manager__r.pse__Salesforce_User__r.IsActive
                    ) {
	                    
                    	//d) Add "Read" manual sharing access for pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId of the associated project on 
                        //the expense report record.
                        //Checking for uniqueness with respect to the set existing values
                        if(project.pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId != null
                           &&
                           !setToMaintainTheUniqueness.contains(expenseR.Id + ' ' + project.pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId)
                           &&
                           project.pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId != expenseR.OwnerId
                        ) {
		                        	
                            //Adding "project.pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId" user instance to the set
                            setToMaintainTheUniqueness.add(expenseR.Id + ' ' + project.pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId);
                            
                            //Sharing record instance
                            pse__Expense_Report__Share eShare4 = new pse__Expense_Report__Share(
                                                                        ParentId = expenseR.Id,
                                                                        UserOrGroupId = project.pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId,
                                                                        RowCause = Schema.pse__Expense_Report__Share.RowCause.pse__PSE_PM_Share__c,
                                                                        AccessLevel = 'Read'
                            );
		                        
                            //Adding record into the list 
                            eShares.add(eShare4);
                        }		
	                }
	            }
			}
            
            //e) Add "Read" manual sharing access for owner user's manager (owner.Manager) on the context record itself.
 			//Checking set for it's size value
            if(setOfUsersIds.size() > 0) {
                
                //Map of Users
                Map<Id, User> mapOfUsers = new Map<Id, User>();
                
                //Loop through user records
        		for(User usr : [SELECT ID, ManagerId 
                                FROM User 
                                WHERE ID IN : setOfUsersIds])
                    mapOfUsers.put(usr.Id, usr);
                
                //Checking for size value
                if(mapOfUsers.values().size() > 0) {
                    
                    //Loop through expense records
            		for (pse__Expense_Report__c exp : listOfRLSExpenseReports) {
                        
                        //Checking for key presence in the map and for the null value
                        if(exp.OwnerId != null 
                        	&& mapOfUsers.containsKey(exp.OwnerId)
                        	&& mapOfUsers.get(exp.OwnerId) != null
                        ) {
                        	
                            //Checking "Manager" for eligibility
                            if(mapOfUsers.get(exp.OwnerId).ManagerId != null
                            	&&
                            	!setToMaintainTheUniqueness.contains(exp.ID + ' ' + mapOfUsers.get(exp.OwnerId).ManagerId)
                            	&&
                                mapOfUsers.get(exp.OwnerId).ManagerId != exp.OwnerId
                            ) {
                               
                            	//Adding "project.pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId" user instance to the set
                                setToMaintainTheUniqueness.add(exp.Id + ' ' + mapOfUsers.get(exp.OwnerId).ManagerId);
            
                                //Sharing record instance
                                pse__Expense_Report__Share eShare5 = new pse__Expense_Report__Share(
                                                                                ParentId = exp.Id,
                                                                                UserOrGroupId = mapOfUsers.get(exp.OwnerId).ManagerId,
                                                                                RowCause = Schema.pse__Expense_Report__Share.RowCause.pse__PSE_PM_Share__c,
                                                                                AccessLevel = 'Read'
                                );
                                    
                                //Adding record into the list 
                                eShares.add(eShare5);    
                            }
                        }
                    }
            	}
            }
            
            //Checking for size and null value
            if (eShares != null && eShares.size() > 0) {
                Util.BypassAllTriggers = true;
                insert eShares;
                Util.BypassAllTriggers = false;
            }
        }		
    }
    
    /**
     *  @description    :   Method to :-
	 * 							a) Add "Edit" manual sharing access for pse__Project_Manager__r.pse__Salesforce_User__c of the associated project on the timecard record.
	 *							b) Add "Edit" manual sharing access for Group_Manager__c of the associated project on the timecard record.
	 *							
	 *							//Added via CR-20170109-10604
	 *                          c) Add "Read" manual sharing access for Group_Manager__r.ManagerId of the associated project on the timecard record.
	 *                          d) Add "Read" manual sharing access for pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId of the associated project on the timecard record.
	 *							e) Add "Read" manual sharing access for owner user's manager (owner.Manager) on the context record itself.
     *
     *  @args           :   Set<Id> setOfProjectsIds, List<pse__Timecard_Header__c> listOfRLSTimecards, Set<Id> setOfResourcesIds
     * 
     *  @return         :   void
     * 
    **/ 
    public static void syncUpManualSharingForTimecards(Set<Id> setOfProjectsIds, List<pse__Timecard_Header__c> listOfRLSTimecards, Set<Id> setOfResourcesIds) {
    	
        //Checking for null and size value
    	if(listOfRLSTimecards != null && listOfRLSTimecards.size() > 0) {
    		
    		//Share with PM (List to hold the manual sharing records)
            List<pse__Timecard_Header__Share> eShares = new List<pse__Timecard_Header__Share>();
            
            //Set to maintain the uniqueness in between the manual sharing records
            Set<String> setToMaintainTheUniqueness = new Set<String>();
            
            //Set to hold the users IDs
            Set<Id> setOfUsersIds = new Set<Id>();
            
            //Map of projects
            Map<Id, pse__Proj__c> mapOfProjects = new Map<Id, pse__Proj__c>();
	
    		//Checking for size and null value
    		if(setOfProjectsIds != null && setOfProjectsIds.size() > 0) {
    			
    			//Map to hold the projects details
	            mapOfProjects = new Map<Id, pse__Proj__c>([SELECT Id,
                                                           pse__Project_Manager__c, pse__Project_Manager__r.pse__Salesforce_User__r.IsActive,
                                                           pse__Project_Manager__r.pse__Salesforce_User__c,
                                                           pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId,
                                                           Group_Manager__c, Group_Manager__r.ManagerId
                                                           FROM pse__Proj__c
                                                           WHERE Id IN : setOfProjectsIds
                                                          ]);
            }    
	
            //Loop through timecard records
            for (pse__Timecard_Header__c timecard : listOfRLSTimecards) {
                    
                //Adding owner user ID in the set
                if(timecard.OwnerId != null)
                    setOfUsersIds.add(timecard.OwnerId);
	
                //Checking for key presence
                if (timecard.pse__Project__c != null 
                    && mapOfProjects.containsKey(timecard.pse__Project__c)
                    && mapOfProjects.get(timecard.pse__Project__c) != null		
                ) {
							
                	//Project	
                    pse__Proj__c project = mapOfProjects.get(timecard.pse__Project__c);
                       
                    //Checking for null value
                    if (project.pse__Project_Manager__c != null 
                        && 
                        project.pse__Project_Manager__r.pse__Salesforce_User__c != null 
                        &&
                        project.pse__Project_Manager__r.pse__Salesforce_User__r.IsActive
                           
                    ) {
	                    	
                        //a) Add "Edit" manual sharing access for pse__Project_Manager__r.pse__Salesforce_User__c of the associated project on the timcard record.
                        //Checking with respect to expense record owner to see the difference in between values
                        //Since owner of a record by defult have full access of the records
                        if(timecard.OwnerId != project.pse__Project_Manager__r.pse__Salesforce_User__c) {
                            
                            //Adding "project.pse__Project_Manager__r.pse__Salesforce_User__c" user instance to the set
                            setToMaintainTheUniqueness.add(timecard.Id + ' ' + project.pse__Project_Manager__r.pse__Salesforce_User__c);
                            
                            //Sharing record instance
                            pse__Timecard_Header__Share eShare = new pse__Timecard_Header__Share(
                                                                    ParentId = timecard.Id,
                                                                    UserOrGroupId = project.pse__Project_Manager__r.pse__Salesforce_User__c,
                                                                    RowCause = Schema.pse__Timecard_Header__Share.RowCause.pse__PSE_PM_Share__c,
                                                                    AccessLevel = 'Edit'
                            );
                            
                            //Adding record into the list    
                            eShares.add(eShare);
                        }
                    }
						
                    //Checking field for the null value
                    if (project.Group_Manager__c != null) {
                        
                        //b) Add "Edit" manual sharing access for Group_Manager__c of the associated project on the timcard record.
                        //Checking "Group Manager" for eligibility
                        if(timecard.OwnerId != project.Group_Manager__c
                           && !setToMaintainTheUniqueness.contains(timecard.Id + ' ' + project.Group_Manager__c)
                        ) {
                              
                        	//Adding "project.Group_Manager__c" user instance to the set
                            setToMaintainTheUniqueness.add(timecard.Id + ' ' + project.Group_Manager__c);
                            
                            //Timecard Share records
                            pse__Timecard_Header__Share eShare2 = new pse__Timecard_Header__Share(
                                                                    ParentId = timecard.Id,
                                                                    UserOrGroupId = project.Group_Manager__c,
                                                                    RowCause = Schema.pse__Timecard_Header__Share.RowCause.pse__PSE_Member_Share__c,
                                                                    AccessLevel = 'Edit'
                            );
		
                            //Adding record into the list 
                            eShares.add(eShare2);		
                        }
	                    		                    	
                        //c) Add "Read" manual sharing access for Group_Manager__r.ManagerId of the associated project on the timcard record.
                        //Checking "Group Manager" manager for eligibility
                        if(project.Group_Manager__r.ManagerId != null
                           && timecard.OwnerId != project.Group_Manager__r.ManagerId
                           && !setToMaintainTheUniqueness.contains(timecard.Id + ' ' + project.Group_Manager__r.ManagerId)
                        ) {
                               
                            //Adding "project.Group_Manager__c" user instance to the set
                            setToMaintainTheUniqueness.add(timecard.Id + ' ' + project.Group_Manager__r.ManagerId);
                               
                            //Timecard Share records
                            pse__Timecard_Header__Share eShare3 = new pse__Timecard_Header__Share(
                                                                            ParentId = timecard.Id,
                                                                            UserOrGroupId = project.Group_Manager__r.ManagerId,
                                                                            RowCause = Schema.pse__Timecard_Header__Share.RowCause.pse__PSE_Member_Share__c,
                                                                            AccessLevel = 'Read'
                            );
		                        
                            //Adding record into the list 
                            eShares.add(eShare3);
                        }
                    } 
	                    
                    //Checking for null value
                    if (project.pse__Project_Manager__c != null 
                        && 
                        project.pse__Project_Manager__r.pse__Salesforce_User__c != null 
                        &&
                        project.pse__Project_Manager__r.pse__Salesforce_User__r.IsActive
                    ) {
	                    
                    	//d) Add "Read" manual sharing access for pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId of the associated project on 
                        //the timecard record.
                        //Checking for uniqueness with respect to the set existing values
                        if(project.pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId != null
                           &&
                           !setToMaintainTheUniqueness.contains(timecard.Id + ' ' + project.pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId)
                           &&
                           project.pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId != timecard.OwnerId
                        ) {
		                        	
                            //Adding "project.pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId" user instance to the set
                            setToMaintainTheUniqueness.add(timecard.Id + ' ' + project.pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId);
                            
                            //Sharing record instance
                            pse__Timecard_Header__Share eShare4 = new pse__Timecard_Header__Share(
                                                                        ParentId = timecard.Id,
                                                                        UserOrGroupId = project.pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId,
                                                                        RowCause = Schema.pse__Timecard_Header__Share.RowCause.pse__PSE_PM_Share__c,
                                                                        AccessLevel = 'Read'
                            );
		                        
                            //Adding record into the list 
                            eShares.add(eShare4);
                        }		
	                }
	            }
			}
            
            //e) Add "Read" manual sharing access for owner user's manager (owner.Manager) on the context record itself.
 			//Checking set for it's size value
            if(setOfUsersIds.size() > 0) {
                
                //Map of Users
                Map<Id, User> mapOfUsers = new Map<Id, User>();
                
                //Loop through user records
        		for(User usr : [SELECT ID, ManagerId 
                                FROM User 
                                WHERE ID IN : setOfUsersIds])
                    mapOfUsers.put(usr.Id, usr);
                
                //Checking for size value
                if(mapOfUsers.values().size() > 0) {
                    
                    //Loop through expense records
            		for (pse__Timecard_Header__c tmpc : listOfRLSTimecards) {
                        
                        //Checking for key presence in the map and for the null value
                        if(tmpc.OwnerId != null 
                        	&& mapOfUsers.containsKey(tmpc.OwnerId)
                        	&& mapOfUsers.get(tmpc.OwnerId) != null
                        ) {
                        	
                            //Checking "Manager" for eligibility
                            if(mapOfUsers.get(tmpc.OwnerId).ManagerId != null
                            	&&
                            	!setToMaintainTheUniqueness.contains(tmpc.ID + ' ' + mapOfUsers.get(tmpc.OwnerId).ManagerId)
                            	&&
                                mapOfUsers.get(tmpc.OwnerId).ManagerId != tmpc.OwnerId
                            ) {
                               
                            	//Adding "project.pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId" user instance to the set
                                setToMaintainTheUniqueness.add(tmpc.Id + ' ' + mapOfUsers.get(tmpc.OwnerId).ManagerId);
            
                                //Sharing record instance
                                pse__Timecard_Header__Share eShare5 = new pse__Timecard_Header__Share(
                                                                                ParentId = tmpc.Id,
                                                                                UserOrGroupId = mapOfUsers.get(tmpc.OwnerId).ManagerId,
                                                                                RowCause = Schema.pse__Timecard_Header__Share.RowCause.pse__PSE_PM_Share__c,
                                                                                AccessLevel = 'Read'
                                );
                                    
                                //Adding record into the list 
                                eShares.add(eShare5);    
                            }
                        }
                    }
            	}
            }
            
            //Checking for size and null value
            if (eShares != null && eShares.size() > 0) {
                Util.BypassAllTriggers = true;
                insert eShares;
                Util.BypassAllTriggers = false;
            }
        }		
    }
    
    /**
     *  @description    :   Method to retrieve users details for the resources.
     * 
     *  @args           :   Set<Id> setResourceIds
     * 
     *  @return         :   Map<Id, Id>
     * 
    **/
    public static Map<Id, Id> retrieveUserForTheResource(Set<Id> setResourceIds) {
        
        //Map to hold the resource ID as key and corresponding user record ID as value
        Map<Id, Id> sfUserByResource = new Map<Id, Id>();
        
        //Checking set for null and size value
        if(setResourceIds != null && setResourceIds.size() > 0) {
            
            //Loop through resource
            for (Contact res : [SELECT Id, pse__Salesforce_User__c, pse__Salesforce_User__r.ManagerId
                                     FROM Contact 
                                     WHERE Id IN : setResourceIds 
                                     AND pse__Salesforce_User__c != null 
                                     AND pse__Salesforce_User__r.IsActive = true
                                    ])
                sfUserByResource.put(res.Id, res.pse__Salesforce_User__c);
        }
        
        //returning map
        return sfUserByResource;
    }
    
    /**
     *  @description    :   Method to populate a set with key strings for existing manual sharing records associated with pse_Proj__c records.
     * 
     *  @args           :   Map<Id, Id> sfUsersByResource, Set<Id> setProjectsIds
     * 
     *  @return         :   Map<Id, Id>
     * 
    **/
    public static Set<String> retrieveExistingProjectShareRecords (Map<Id, Id> sfUsersByResource, Set<Id> setProjectsIds) {
        
        //Set to hold the UserOrGroupId and ParentId as value
        Set<String> setResourcesAndProjectsIdsKeys = new Set<String>();
        
        /*Modified by Abhinav Sharma - 10/31/2018 - Issue--CR12599--QA--00008503, CR-20180917-12599 
     	Modified the method to comment the references of "pse__Proj__Share", changing sharing setting for the object from Private */
        //Checking for the null and size value
        /*if(sfUsersByResource != null && sfUsersByResource.values().size() > 0 && setProjectsIds != null && setProjectsIds.size() > 0) {
          
            //Loop through existing project share records
            for (pse__Proj__Share projShare : [SELECT ParentId, UserOrGroupId
                                                   FROM pse__Proj__Share
                                                   WHERE ParentId != null 
                                                   AND ParentId IN : setProjectsIds
                                                   AND UserOrGroupId != null
                                                   AND UserOrGroupId IN : sfUsersByResource.values()]) {
                                                      
                //Constructing key and adding it to the collection of set type                                               
                String keyUserOrGroupIdWithProjectId = String.valueOf(projShare.UserOrGroupId) + String.valueOf(projShare.ParentId);
                setResourcesAndProjectsIdsKeys.add(keyUserOrGroupIdWithProjectId);
            }
        }*/
        
        //returning set
        return setResourcesAndProjectsIdsKeys;
    }
    
        /**
     *  @description    :   Method to mass approve records via the List View
     * 
     *  @args           :   List<pse__Timecard_Header__c> Timecard records selected via the List View
     * 
     *  @return         :   None
     * 
    **/
    
    public static void bulkApproveTimecardRecords (List<pse__Timecard_Header__c> timecardRecords){
        
        //List for storing the Approval Request records related to our Timecard
        List<ProcessInstance > timecardProcInst = new List<ProcessInstance >();
        
        //List for storing the Work Items associated with the Request
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest> ();
        
        //Set for storing our Ids
        Set<Id> timecardIds = new Set<Id>();
        
        //Loop through our records and populate into a Set
        for (pse__Timecard_Header__c th : timecardRecords){
            timecardIds.add(th.Id);
        }
        
        //Query for the Approval Request records related to our Timecard
        timecardProcInst = [SELECT Id FROM ProcessInstance WHERE TargetObjectId IN :timecardIds];
        
        //If we have records then proceed
        if (timecardProcInst.size() > 0){
            
            //Loop through and create ProcessInstanceWorkItems to approve our records
            for (ProcessInstanceWorkItem wi : [Select Id from ProcessInstanceWorkItem where ProcessInstanceId IN :timecardProcInst]){
                
                //If there's a work item - set the action to Approved, add comments and add to a list for execution
                Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                req2.setAction('Approve');
                req2.setComments ('Approving Record via Bulk Approval');
                req2.setWorkitemId(wi.Id);
                requests.add(req2);
            }
            
        }
        
        //If we have Requests then submit for Approval
        if (requests.size() >0) {
            
            //Send our records through for approval
            Approval.ProcessResult[] processResults = null;
            processResults = Approval.process(requests, true);
            
        }
        
    }

    /**
     *  @description    :   Method to Add Users to the necessary Public Group for reports/views purposes based on the Practice value set on their account
     * 
     *  @args           :  
     * 
     *  @return         :   None
     * 
    **/
    
    public static void runPSAPracticeToPublicGroupLogic (List<Contact> newContacts, Map<Id, Contact> oldContactMap){

        //Map for associating Contact with Practice IDs
        Map <Id, String> mapUserToPSAPracticeId = new Map<Id, String>();

        //Map for associating Contact with their Old Practice ID
        Map <Id, String> mapUserToOldPSAPracticeId = new Map<Id, String>();

        //List for Contacts no longer associated with Practices
        List<Id> noPracticeContacts = new List<Id>();

        //List of GroupMembers to upsert or delete
        List<GroupMember> groupMembersToAdd = new List<GroupMember>();
        List<GroupMember> groupMembersToDelete = new List<GroupMember>();

        //Scenario One - New Contact Added
        if (oldContactMap == null && newContacts != null){

            //Loop through Contacts
            for (Contact con : newContacts){

                //Check for PSA Practice field
                if (con.pse__Practice__c != null && con.pse__Salesforce_User__c != null){
                    mapUserToPSAPracticeId.put(con.pse__Salesforce_User__c, con.pse__Practice__c);
                }

            }

        }

        //Scenario Two - Practice Updated on existing Contact
        if (oldContactMap != null && newContacts != null){

            //Loop through Contacts
            for (Contact con : newContacts){

                //Check for Update to Practice
                if (con.pse__Salesforce_User__c != null && con.pse__Practice__c != oldContactMap.get(con.Id).pse__Practice__c){

                    //Check for blank field
                    if (con.pse__Practice__c != null){
                        mapUserToPSAPracticeId.put(con.pse__Salesforce_User__c, con.pse__Practice__c);
                    } else {
                        noPracticeContacts.add(con.pse__Salesforce_User__c);
                    }

                    if (con.pse__Practice__c != null && oldContactMap.get(con.Id).pse__Practice__c != null){
                        mapUserToOldPSAPracticeId.put(con.pse__Salesforce_User__c, oldContactMap.get(con.Id).pse__Practice__c);
                    }
                    
                }

            }

        }

        //Check for records in our Map
        if (mapUserToPSAPracticeId.values().size() > 0){

            //Run a query to get our Metadata records
            Map<String, String> psaPracToGroupRecords = returnAllPSAPracticeGroupRecords();
            System.debug('Metadata Records: ' + psaPracToGroupRecords);
            Map<Id, String> psaPracticeIdToName = returnAllPSAPracticeRecords();

            //Run a Query to get our Group Members in these Groups
            List<Group> allGroups = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN :psaPracToGroupRecords.values()];
            List<GroupMember> allGroupMembers = [SELECT Id, GroupId, Group.DeveloperName, UserOrGroupId FROM GroupMember WHERE Group.DeveloperName IN :psaPracToGroupRecords.values()];

            //Map our Unique Identifier to User Id
            Map<String, Id> mapGroupNameToId = new Map<String, Id>();
            Map<String, Id> mapUserGroupToGroupMemberID = new Map<String, Id>();

            //Loop through Groups and populate Map
            if (allGroups.size() > 0){

                //Loop through Groups
                for (Group grp : allGroups){
                    if (mapGroupNameToId.get(grp.Id) == null){
                        mapGroupNameToId.put(grp.DeveloperName, grp.Id);
                    }
                }
            }

            //Loop through our Group Members
            if (allGroupMembers.size() > 0){

                //Loop through records
                for (GroupMember gM : allGroupMembers){

                    //Build our Unique Id
                    String uniqueIdentifier = gM.Group.DeveloperName + '-' + gM.UserOrGroupId;

                    //Check Map
                    if (mapUserGroupToGroupMemberID.get(uniqueIdentifier) == null){
                        mapUserGroupToGroupMemberID.put(uniqueIdentifier, gM.Id);
                    }

                }

            }

            //Loop through our Contacts
            for (Id contactUserID : mapUserToPSAPracticeId.keySet()){

                //Get our Practice Name
                Id practiceId = mapUserToPSAPracticeId.get(contactUserID);
                String practiceName = psaPracticeIdToName.get(practiceId);

                //String for groupID & unique Identifier
                String groupName;
                String uniqueIdentifier;

                //Get our Group ID from Metadata Record
                if (psaPracToGroupRecords.get(practiceName) != null){
                    groupName = psaPracToGroupRecords.get(practiceName);
                }

                system.debug('groupName' + groupName);

                //Check for null value on Group Id
                if (groupName != null){
                    uniqueIdentifier = groupName + '-' + contactUserID;
                }

                system.debug('uniqueIdentifier' + uniqueIdentifier);

                //Check for null on uniqueIdentifier
                if (uniqueIdentifier != null){

                    //Check our existing Group Members for a record and create a new record if needed
                    if (mapUserGroupToGroupMemberID.get(uniqueIdentifier) == null) {

                        //Parse our Unique ID and create GroupMember record
                        List<String> uniquePieces = uniqueIdentifier.split('-');
                        System.debug('Group Name: ' + mapGroupNameToId.get(uniquePieces[0]));

                        //Get our Group Name
                        if (mapGroupNameToId.get(uniquePieces[0]) != null){
                            GroupMember newGM = new GroupMember(GroupId = mapGroupNameToId.get(uniquePieces[0]), UserOrGroupId = Id.valueof(uniquePieces[1]));
                            groupMembersToAdd.add(newGM);
                        }
                        
                    }

                }

            }

            //Check to see if there are GroupMembers to remove
            if (mapUserToOldPSAPracticeId.values().size() > 0){

                //Loop through our Contacts
                for (Id contactUserID : mapUserToOldPSAPracticeId.keySet()){

                    //Get our Practice Name
                    Id practiceId = mapUserToOldPSAPracticeId.get(contactUserID);
                    String practiceName = psaPracticeIdToName.get(practiceId);

                    //String for groupID & unique Identifier
                    String groupName;
                    String uniqueIdentifier;

                    //Get our Group ID from Metadata Record
                    if (psaPracToGroupRecords.get(practiceName) != null){
                        groupName = psaPracToGroupRecords.get(practiceName);
                    }

                    //Check for null value on Group Id
                    if (groupName != null){
                        uniqueIdentifier = groupName + '-' + contactUserID;
                    }

                    //Check for null on uniqueIdentifier
                    if (uniqueIdentifier != null){

                        //Check our existing Group Members for a record and create a new record if needed
                        if (mapUserGroupToGroupMemberID.get(uniqueIdentifier) != null) {

                            //Get our Group Member ID and add to list for deletion
                            Id groupMemberId = mapUserGroupToGroupMemberID.get(uniqueIdentifier);
                            GroupMember grpMem = new GroupMember (Id = groupMemberId);
                            groupMembersToDelete.add(grpMem);
                            
                        }

                    }

                }

            }

        }

        //Check for No Practice Contacts
        if (noPracticeContacts.size() > 0){

            //Query to get our Groups and Group Members
            Map<String, String> psaPracToGroupRecords = returnAllPSAPracticeGroupRecords();

            //Run a Query to get our Group Members in these Groups
            List<Group> allGroups = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN :psaPracToGroupRecords.values()];
            List<GroupMember> groupMembersNotNeeded= [SELECT Id, GroupId, Group.DeveloperName, UserOrGroupId FROM GroupMember WHERE Group.DeveloperName IN :psaPracToGroupRecords.values() AND UserOrGroupId IN :noPracticeContacts];

            //Check for Group Members
            if (groupMembersNotNeeded.size() > 0){
                groupMembersToDelete.addAll(groupMembersNotNeeded);
            }

        }

        //Check for upsert group size
        if (groupMembersToAdd.size() > 0) {
            String jsonString = json.serialize(groupMembersToAdd);
            insertGroupMemberRecords(jsonString);
        }

        //Check for Group Members to delete size
        if (groupMembersToDelete.size() > 0){
            String jsonString = json.serialize(groupMembersToDelete);
            deleteGroupMemberRecords(jsonString);
        }

    }

    public static Map<Id, String> returnAllPSAPracticeRecords (){

        //Query for our Metadata records
        List <pse__Practice__c> allPracticeRecords = [SELECT Id, Name FROM pse__Practice__c];

        //Build our Map
        Map<Id, String> psaPracticeIdToName = new Map<Id, String>();

        //Check for Query Size
        if (allPracticeRecords.size() > 0){

            //Loop through records
            for (pse__Practice__c record : allPracticeRecords){
                if (psaPracticeIdToName.get(record.Id) == null){
                    psaPracticeIdToName.put(record.Id, record.Name);
                }
            }
        }

        return psaPracticeIdToName;

    }

    public static Map<String, String> returnAllPSAPracticeGroupRecords (){

        //Query for our Metadata records
        List <PSA_Practice_to_Public_Group__mdt> allPracticeToGroupRecords = [SELECT Id, Group_Name__c, Practice_Name__c FROM PSA_Practice_to_Public_Group__mdt];

        //Build our Map
        Map<String, String> psaPracticeToGroupName = new Map<String, String>();

        //Check for Query Size
        if (allPracticeToGroupRecords.size() > 0){

            //Loop through records
            for (PSA_Practice_to_Public_Group__mdt record : allPracticeToGroupRecords){
                if (psaPracticeToGroupName.get(record.Practice_Name__c) == null){
                    psaPracticeToGroupName.put(record.Practice_Name__c, record.Group_Name__c);
                }
            }
        }

        return psaPracticeToGroupName;

    }

    @future
    public static void deleteGroupMemberRecords (String records) {

        //Loop through and create a Group Member List
        List<GroupMember> groupMembersToDelete = (List<GroupMember>)Json.deserialize(records ,List<GroupMember>.class);

        delete groupMembersToDelete;

    }

    @future
    public static void insertGroupMemberRecords (String records) {

        //Get our Records from the JSON String
        List<GroupMember> groupMembersToInsert = (List<GroupMember>)Json.deserialize(records ,List<GroupMember>.class);

        //Insert Records
        insert groupMembersToInsert;
    }

    @AuraEnabled(cacheable=true)
    public static List<pse__Assignment__c> getAssignmentRecords (Id projectID) {

        //Query for our Assignments
        List<pse__Assignment__c> relatedAssignments = [SELECT Id, Name, pse__Resource__c, Resource_Name__c, New_Resource__c, pse__Project__c, pse__Planned_Bill_Rate__c FROM pse__Assignment__c WHERE pse__Project__c = :projectID];

        return relatedAssignments;


    }

    @AuraEnabled
    public static string updateAssignment(String oldResource, String newResource, Id projectID) {

        //Wrapper Class List for capturing our JSON Strings
        //List<LookupSearchResult> originalResourceData = new List<LookupSearchResult>();
        //List<LookupSearchResult> newResourceData = new List<LookupSearchResult>();

        //LookupSearchResult originalResourceData = (LookupSearchResult) Json.deserialize(oldResource,  LookupSearchResult.class);
        //LookupSearchResult newResourceData = (LookupSearchResult) Json.deserialize(newResource,  LookupSearchResult.class);

        //Get our Old Resource Data
        /*List<Id> oldResourceUserId = new List<Id>();

        for(LookupSearchResult userData : originalResourceData)
        oldResourceUserId.add(userData.Id);

        //Get our New Resource Data
        List<Id> newResourceUserId = new List<Id>();

        for(LookupSearchResult userData : newResourceData)
        newResourceUserId.add(userData.Id);*/

        Map<String, Id> mapContactNameToId = new Map<String, Id>();

        //Query for our Contacts
        List<Contact> allPSAContacts = [SELECT Id, Name FROM Contact WHERE pse__Is_Resource_Active__c = true AND pse__Is_Resource__c = true];

        //Loop through and populate our Map
        for (Contact c : allPSAContacts){
            mapContactNameToId.put(c.Name, c.Id);
        }

        System.debug('Contact List Size: ' + allPSAContacts.size());
       
        //Get our List of Assignments
        List<pse__Assignment__c> assignmentsToCheck = getAssignmentRecords(projectID);
        System.debug('Assignment List Size : ' + assignmentsToCheck.size());

        //List to be used later for update
        List<pse__Assignment__c> assignmentsForUpdate = new List<pse__Assignment__c>();

        if(oldResource.contains('"')) {
            oldResource =  oldResource.replace('"', '');
        }

        if(newResource.contains('"')) {
            newResource =  newResource.replace('"', '');
        }

        System.debug('Old Resource: ' + oldResource);
        System.debug('New Resource: ' + newResource);

        Id oldContactID;
        Id newContactID;

        //Get our Resource IDs
        if (mapContactNameToId.get(oldResource) != null){
            oldContactID = mapContactNameToId.get(oldResource);
        }

        if (mapContactNameToId.get(newResource) != null){
            newContactID = mapContactNameToId.get(newResource);
        }


        System.debug('Old Resource Id: ' + oldContactID);
        System.debug('New Resource Id: ' + newContactID);

        //Now we have our List of Assignment records let's map our new value to the Resource field
        for (pse__Assignment__c assignment : assignmentsToCheck){

            System.debug('Assignment Resource ID: ' + assignment.pse__Resource__c);

            //Check for New Resource Value
            if (assignment.pse__Resource__c == oldContactID){

                System.debug('Replacing Resource Value');

                //Assign our New Resource value to the Resource field
                assignment.pse__Resource__c = newContactID;
                assignmentsForUpdate.add(assignment);
				System.debug('After Replacing Resource Value' +assignment.pse__Resource__c);
            }

        }

        //If we have records to Update
        if (assignmentsForUpdate.size() > 0){

            try {
                System.debug('### assignmentsForUpdate '+ assignmentsForUpdate);
                Util.ByPassAllTriggers = true;
                update assignmentsForUpdate;
                 Util.ByPassAllTriggers = false;
                System.debug('Update Complete');
                return 'Success: Assignments updated successfully';
            }
            catch (Exception e) {
                //Added By - Mahendra Swarnakar - 12/01/2020
                String errorMessage = e.getMessage();
                List<String> splittedByValidationExceptions = new List<String>();
                if(errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
                {
                    splittedByValidationExceptions = errorMessage.split('FIELD_CUSTOM_VALIDATION_EXCEPTION');
                    errorMessage = errorMessage.split('FIELD_CUSTOM_VALIDATION_EXCEPTION')[splittedByValidationExceptions.size() - 1];
                    errorMessage = errorMessage.removeStart(',').removeEnd('[]').trim();
                }
                throw new CustomException(errorMessage);
                //End Here
                
                //return 'The following exception has occurred: ' + e.getMessage();
            }

        } else {

            return 'No Update Needed';

        }

        
    }

    
}