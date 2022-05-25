/*
    Purpose:    Before Insert: NBB fields
                    Name = NBB - [Opportunity.Account.Name] - [Opportunity.Program.Program Acronym] - [Owner LastName] - [ATL Date MM/DD/YYYY]
                    OwnerID = Marketer__c on NBB.
            
                After Insert, Update, Delete: 
                Opportunity fields (roll-ups from NBB to Opp)
                Field NBB__c is a Sum of NBB1__r.NBB__c (Currency) for all records in NBB1__r
                Field NBB_Units__c is Sum of NBB1__r.Units__c for all the same records
    
    Create By:          Pierre Eymard (SAP Contractor)
    
    Last Modified By:   Nathan Banas (SAP) - 2/9/2011
    
    Current Version:    v1.7
    
    Revision Log:       v1.0 - (PE) Created code
                        v1.1 - (NB-2011-01-25) - Added header, code comments, and reviewed code coverage
                        v1.2 - (NB-2011-02-09) - Added criteria (line 115) to filter by NBB Type when summing up NBB and NBB Units on Opportunities
                        v1.3 - Bhavi Sharma - 11/15/2013 Code added for populate Sharing on NBB with related ATM - CR-20130517-3034
                        v1.4 - Bhavi Sharma - 12/16/2013 - Code added for deleting old manual NBB_Share record - CR-20130517-3034
                        v1.5 - Abhinav Sharma - 05/23/2014 - CR-20140415-5083 - Updates to NBB fields
                        v1.6 - Bhavi Sharma - 06/27/2014 - CR-20140626-5982 - Do not set the NBB__c and NBB_Units__c to 0 by default
                        v1.7 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
                        v1.8 - Modified By - Abhinav Sharma - 06/09/2015 - CR-20141217-8348 - Update NBB Roll-up Fields
                        v1.9 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
                        v2.0 - Modified By - Deepak Kumawat - 10/05/2017 - Apollo Release -  Added a new call for Entity field.
                        v2.1 - Modified By - Abhishek Mishra - 5/20/2021 - CR-20210504-15115 - Add null check
*/
trigger NBB_NameAndOppNBBFields on NBB__c (before insert, before update, after insert, after delete, after update) {
    
    try {
      
      //Check for trigger
      if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate) && !OpportunityMergeController.isOpportunityMerge)
        Util.validateEntityValue(Trigger.new, Trigger.oldMap, 'NBB__c', 'Entity__c','Program__c', 'Entity__c', 'Program__r', 'Program__c');
        
      //return immediately if method returns true  
      if(Util.areTriggersOnThisObjectBypassed('NBB__c')) return;  
      
        if(!Util.IsBatch) {
            
            // Flag this trigger is running to any following processes
            Util.IsTrigger_NBBOppFields = true;
            
            //List to store NBBs from this trigger
            List<NBB__c> nbbs; 
            
            //Set to store marketer ids
            set<id> ownerids = new Set<id>();
                
            //opps associated to nbb__c in trigger
            Set<id> oppids = new Set<id>();
            
            // List to store Opps
            List<Opportunity> opps; 
            
            // If this trigger was called by a delete action, add the Trigger.old NBBs to the NBB list, otherwise add the Trigger.new NBBs to the NBB list
            if (Trigger.isDelete)
                nbbs = Trigger.old;
            else
                nbbs = Trigger.new;
               
            // Loop through NBBs
            for (NBB__c n : nbbs) {
                
                // Add Opportunity Ids of these NBBs to a list only if there is an associated Opportunity on this NBB
                if (n.opportunity__c != null)
                    oppids.add(n.opportunity__c);
                
                // Add the NBB Marketer (User) Id to a list
                ownerids.add(n.Marketer__c);
            }
            
            if (Trigger.IsBefore) {
                
                /** Name and Owner Change/Update**/ 
            
                // Variable to store Account Name Length for truncation if necessary
                Integer maxaccnamelength = 55;
                
                // Get a map of Opportunities for these NBBs w/ the Opp Id as the key
                map<id, Opportunity> oppid2oppmap = new map<id, Opportunity>([select id, Marketer__c, Program__c, Program__r.Program_Acronym__c, 
                    AccountId, Account.Name, Account.Primary_City__c, Account.Primary_State_Province__c 
                    from Opportunity where id in :oppids]);
                
                // Get a map of Users for these NBBs w/ the User's Id as the key
                map<id, User> userid2usermap = new map<id, User>([select Lastname from User where id in :ownerids]);
                
                // Loop through NBBs
                for (NBB__c n : Trigger.new) {
                    
                    // Retrieve this NBB's Opportunity record
                    
                    //Added By - Abhishek Mishra - 5/20/2021 - CR-20210504-15115 - From here 
                    Opportunity o = new Opportunity();   
                    if(n.Opportunity__c !=null && oppid2oppmap.containskey(n.Opportunity__c))
                    	o = oppid2oppmap.get(n.Opportunity__c);
                    //Added By - Abhishek Mishra - 5/20/2021 - CR-20210504-15115 - till here 
                    
                    //fix NBB owner to be the same as NBB Marketer
                    if (n.Marketer__c != null)
                        n.OwnerID = n.Marketer__c; 
                    
                    // Variable to store the NBB Owner
                    User nbbowner = userid2usermap.get(n.OwnerID);
                    
                    //fix NBB name
                    String newname = 'NBB - ';
                    
                    // Add the NBB's Opportunity Account Name to the Name if it is present
                    if ((o.AccountId != null) && (o.Account.Name != null))
                        newname += o.Account.Name.substring(0,(Math.min(maxaccnamelength, o.Account.Name.length()))) + ' - ';
                    
                    // Add the NBB's Opportunity Program Acronym to the Name if it is present
                    if ((o.Program__c != null) && (o.Program__r.Program_Acronym__c != null))
                        newname += o.Program__r.Program_Acronym__c + ' - ';
                    
                    // Add the NBB Owner's Last Name to the Name if it is present
                    if ((nbbowner != null) && (nbbowner.LastName != null))
                        newname += nbbowner.LastName + ' - ';
                    
                    // Add the ATL Date to the Name if it is present
                    if (n.ATL_Date__c != null)
                        newname += n.ATL_Date__c.format();  
                    
                    // Truncate Name at 80 characters or current length if less than 80
                    n.Name = newname.substring(0,Math.min(newname.length(), 80));
                }
            } else if (Trigger.isAfter) { 
            
                //Modified By - Abhinav Sharma - 06/09/2015 - CR-20141217-8348 - Update NBB Roll-up Fields
                //Modified By - Abhinav Sharma - CR-20140415-5083 - 05/23/2014 (Included NBB Type = Shadow Credit in the inline query)
                // Get a list of Opportunities and associated NBBs that match the filter criteria (NBB_Type__c)
                opps = new List<opportunity>([SELECT Id, NBB__c, NBB_Units__c, Trigger_Update__c,
                                              Current_YTD_NBB_New__c, Current_YTD_NBB_Units_New__c,
                                              Previous_YTD_NBB_New__c, Previous_YTD_NBB_Units_New__c,
                                              Previous_Year_NBB_New__c, Previous_Year_NBB_Units_New__c,
                                                  (SELECT NBB__c, Unit__c, NBB_Type__c, Current_YTD_ATL_NBB__c,
                                                  Current_YTD_ATL_NBB_Units__c, Prev_YTD_ATL_NBB__c,
                                                  Prev_YTD_ATL_NBB_Units__c, Prev_Year_ATL_NBB__c, 
                                                  Prev_Year_ATL_NBB_Units__c FROM NBB1__r 
                                                  WHERE NBB_Type__c = 'Shadow Credit' or NBB_Type__c = 'Base Fee' or NBB_Type__c = 'Posted Risk') 
                    						  FROM opportunity where Id IN : oppids]);
                
                // Loop through Opportunities
                for (Opportunity o : opps) {
                    
                    // Set NBB and NBB Units equal to zero
                    //Updated By - Bhavi Sharma - 06/27/2014 - CR-20140626-5982 - Do not set the NBB__c and NBB_Units__c to 0 by default
                    o.NBB__c = null;
                    o.NBB_Units__c = null;
                    o.Trigger_Update__c = true; // Flag used to bypass Opportunity Validation Rules if necessary
               		
                    //Initialization
                    o.Current_YTD_NBB_New__c = null;
                    o.Current_YTD_NBB_Units_New__c = null;
                    o.Previous_YTD_NBB_New__c = null;
                    o.Previous_YTD_NBB_Units_New__c = null ;
                    
                    //Added By - Mahendra Swarnkar - 07/22/2015 -CR-20150626-9028
                    //Starts from here
                    o.Previous_Year_NBB_New__c = null ;
                    o.Previous_Year_NBB_Units_New__c = null ;
               		//Ends here
               		
                    // Loop through all NBBs associated w/ these Opportunities, not just those calling this trigger
                    for (NBB__c nbb : o.NBB1__r) {
                        
    					//Total of Current_YTD_ATL_NBB__c => Opp.Current_YTD_NBB_New__c
                        if(nbb.Current_YTD_ATL_NBB__c != null) {
                            if(o.Current_YTD_NBB_New__c != null) 
                                o.Current_YTD_NBB_New__c += nbb.Current_YTD_ATL_NBB__c;
                            else 
                                o.Current_YTD_NBB_New__c = nbb.Current_YTD_ATL_NBB__c;
                        }

						//Total of Current_YTD_ATL_NBB_Units__c => Opp.Current_YTD_NBB_Units_New__c
						if(nbb.Current_YTD_ATL_NBB_Units__c != null) {
                            if(o.Current_YTD_NBB_Units_New__c != null) 
                                o.Current_YTD_NBB_Units_New__c += nbb.Current_YTD_ATL_NBB_Units__c;
                            else 
                                o.Current_YTD_NBB_Units_New__c = nbb.Current_YTD_ATL_NBB_Units__c;
                        }
						
                        //Total of Prev_YTD_ATL_NBB__c => Opp.Previous_YTD_NBB_New__c
						if(nbb.Prev_YTD_ATL_NBB__c != null) {
                            if(o.Previous_YTD_NBB_New__c != null) 
                                o.Previous_YTD_NBB_New__c += nbb.Prev_YTD_ATL_NBB__c;
                            else 
                                o.Previous_YTD_NBB_New__c = nbb.Prev_YTD_ATL_NBB__c;
                        }
						
                        //Total of Prev_YTD_ATL_NBB_Units__c => Opp.Previous_YTD_NBB_Units_New__c
						if(nbb.Prev_YTD_ATL_NBB_Units__c != null) {
                            if(o.Previous_YTD_NBB_Units_New__c != null) 
                                o.Previous_YTD_NBB_Units_New__c += nbb.Prev_YTD_ATL_NBB_Units__c;
                            else 
                                o.Previous_YTD_NBB_Units_New__c = nbb.Prev_YTD_ATL_NBB_Units__c;
                        }
                        
                        // Add NBB & NBB Unit totals to the Opportunity NBB and NBB Unit fields
                        if(nbb.NBB__c != null) {
                            if(o.NBB__c != null)
                                o.NBB__c += nbb.NBB__c;
                            else
                                o.NBB__c = nbb.NBB__c;
                        }
                        
                        if(nbb.Unit__c != null) {
                            if(o.NBB_Units__c != null)
                                o.NBB_Units__c += nbb.Unit__c;
                            else
                                o.NBB_Units__c = nbb.Unit__c;
                        }
                        
                        //Added By - Mahendra Swarnkar - 07/22/2015 -CR-20150626-9028
                        //Starts from here
                        //Total of Prev_Year_ATL_NBB__c => Opp.Previous_Year_NBB_New__c
                        if(nbb.Prev_Year_ATL_NBB__c != null) {
                            if(o.Previous_Year_NBB_New__c != null) 
                                o.Previous_Year_NBB_New__c += nbb.Prev_Year_ATL_NBB__c;
                            else 
                                o.Previous_Year_NBB_New__c = nbb.Prev_Year_ATL_NBB__c;
                        }
                        
                        //Total of Prev_Year_ATL_NBB_Units__c => Opp.Previous_Year_NBB_Units_New__c
                        if(nbb.Prev_Year_ATL_NBB_Units__c != null) {
                            if(o.Previous_Year_NBB_Units_New__c != null) 
                                o.Previous_Year_NBB_Units_New__c += nbb.Prev_Year_ATL_NBB_Units__c;
                            else 
                                o.Previous_Year_NBB_Units_New__c = nbb.Prev_Year_ATL_NBB_Units__c;
                        }
						//Ends here
                    }
                }
                
                // Update the Opportunities
                try {
                    if (opps.size() > 0)
                        update opps;
                } catch (Exception e) {
                    // Display any errors that occured during the Opportunity Update
                    for (NBB__c n : nbbs) {
                        n.addError(e.getMessage());
                    }
                }
                
                //Code added for Populate Sharing on NBB - Bhavi Sharma - 11/15/2013 - CR-20130517-3034
                if(Trigger.isInsert || Trigger.isUpdate) {
                    NBBTriggerHelper.populateSharingOnNBB(Trigger.new, Trigger.OldMap);
                }
            }
        } //end if !Util.IsBatch
    //Catching DML Exceptions
    } catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));

    //Catching all Exceptions
    } catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}