/**
*   Purpose         :   This class is helper class for Trigger on Opportunity and ROI Object.
*
*   Create By       :   Abhinav Sharma
*
*   Created Date    :   02/07/0219
*
*   Current Version :   v1.0
*
*   Revision Logs   :   Created by Abhinav Sharma - CR-20181026-12714
**/

public without sharing class OpportunityAndRoiTriggerHelper {
	
    /**
     *  @description    :   This method is used to update the related project. 
     *
     *  @args           :   List<Opportunity_And_ROI__c>, Map<Id, Opportunity_And_ROI__c>
     *
     *  @return         :   void
     *
    **/
    public static void populateProjectFieldsFromOpportunityAndROI(List<Opportunity_And_ROI__c> newROIS, Map<Id, Opportunity_And_ROI__c> oldMapOppAndROIs) {
    	
        //set to hold the new record Id of Opportunity and ROI. 
        set<Id> setOppROIIds = new set<Id>();
        
        //check for the new list.
        if(newROIS != null && newROIS.size() > 0) {
            
            //Loop on the list. 
            for(Opportunity_And_ROI__c oAR : newROIS) {
            		
                if(oldMapOppAndROIs == null || (oldMapOppAndROIs != null && (oldMapOppAndROIs.get(oAR.Id).Name != oAR.name))){
                	
                    //checking for the record name if that contains the spcified character in the name we will consider this record for the futher updates on Project. 
                    if(oAR.Name.containsIgnoreCase('(A) Impact') || oAR.Name.containsIgnoreCase('(B) Impact')) {
                        setOppROIIds.add(oAR.Project__c);
                    }
                }
            }
            
            //check for the set size. 
            if(setOppROIIds.size() > 0) {
                
                //Map to hold the Project with the created Date
				Map<Id, DateTime> mapAImpact = new Map<Id, DateTime>();
                
                //Map to hold the Project with the created Date
				Map<Id, DateTime> mapBImpact = new Map<Id, DateTime>();
                    
                //Query on the Opportunity ROI.
                for(Opportunity_And_ROI__c oppROI : [Select Id, CreatedDate, Name, 
                                                     Project__c From Opportunity_And_ROI__c 
                                                     Where Project__c IN: setOppROIIds Order by Project__c]) {
                	
               		//Check for the A Impact in the Name
                  	if(oppROI.Name.containsIgnoreCase('(A) Impact')) {
						
                    	//Adding to the map. 
                    	if(!mapAImpact.containskey(oppROI.Project__c))  
                            mapAImpact.put(oppROI.Project__c, oppROI.CreatedDate);
                        else {
                            //Check for the if condition. If next iteration's creatd date is greater for the same project than override map.
                            if(oppROI.CreatedDate > mapAImpact.get(oppROI.Project__c))
                        		mapAImpact.put(oppROI.Project__c, oppROI.CreatedDate);
                        }
                    }else {
                        //Check for the B impact in the Name.
                        if(oppROI.Name.containsIgnoreCase('(B) Impact')) {
                        	
                            //Adding to the map. 
                            if(!mapBImpact.containskey(oppROI.Project__c))  
                                mapBImpact.put(oppROI.Project__c, oppROI.CreatedDate);
                            else {
                                //Check for the if condition. If next iteration's creatd date is greater for the same project than override map.
                                if(oppROI.CreatedDate > mapBImpact.get(oppROI.Project__c))
                                    mapBImpact.put(oppROI.Project__c, oppROI.CreatedDate);
                            }
                        }
                    }	
                }
                
                System.debug('mapBImpact==='+mapBImpact);
                System.debug('mapAImpact==='+mapAImpact);
                
                //Map to hold the id with the Project. 
                Map<Id, Project__c> mapProjectsToBeUpdated = new Map<Id, Project__c>();
                
                //check for the size of map. 
                if(mapAImpact.size() > 0 || mapBImpact.size() > 0) {
                	
					for(Id proj : mapAImpact.keyset())
                   		mapProjectsToBeUpdated.put(proj, new Project__c(Id = proj, Last_Impact_A__c = mapAImpact.get(proj), Last_Impact_B__c = null)); 
                    
                    for(Id proj : mapBImpact.keyset()) {
                    	
                        if(!mapProjectsToBeUpdated.containsKey(proj))
                        	mapProjectsToBeUpdated.put(proj, new Project__c(Id= Proj, Last_Impact_A__c = null, Last_Impact_B__c = mapBImpact.get(proj))); 
                    	else
                            mapProjectsToBeUpdated.get(proj).Last_Impact_B__c = mapBImpact.get(proj);
                    }
                }
                
                System.debug('mapProjectsToBeUpdated==='+mapProjectsToBeUpdated);
                //Check for thrr size. 
                if(mapProjectsToBeUpdated != null && mapProjectsToBeUpdated.size() > 0) {
                    
                    Util.ByPassAllTriggers = true;
                    update mapProjectsToBeUpdated.values();
                    Util.ByPassAllTriggers = false;
                } 
            }
        }
    }
}