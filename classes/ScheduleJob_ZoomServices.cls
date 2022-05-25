/**
* 
* Desription      :   This class is used to schedule invokeRegistrantsZoomService future method.
*
* Revision Logs   :   V1.0 - 07/14/2021 - Created - CR-20210709-15278 - Chirag Soni.
*		  :   V1.1 - 11/16/2021 - Modified - CR-20211112-15583 - Chirag Soni - commented apporved callout and its associated variable 
*                 :   V1.2 - 12/06/2021 - Modified - CR-20211112-15583 - Chirag Soni - QA/UAT Issue #114 - Comment out the cancel call out to zoom and its related variables 
**/

public class ScheduleJob_ZoomServices implements Schedulable,Database.AllowsCallouts  {
    
    //set of ids which holds registration ids for sync, cancel and approved with zoom 
    Set<Id> registrationIdsToSyncWithZoom ;
    //12/06/2021 - CR-20211112-15583 - Chirag Soni - QA/UAT Issue #114 - Comment out the cancel call out to zoom and its related variables 
    //Set<Id> registrationIdsToCancelInZoom ;
    //11/16/2021 - CR-20211112-15583 - Chirag soni - Commented 
    //Set<Id> registrationIdsToUpdateApprovedInZoom ;
    
    
    map<integer, Set<Id>> mapOfRegistrationIdsToSync = new map<integer, Set<Id>>();
    
    //12/06/2021 - Modified - CR-20211112-15583 - Chirag Soni - QA/UAT Issue #114 - Comment out the cancel call out to zoom and its related variables 
    //map<integer, Set<Id>> mapOfRegistrationIdsCancel = new map<integer, Set<Id>>();
    
    //11/16/2021 - CR-20211112-15583 - Chirag soni - Commented mapOfRegistrationIdsToApprove
    // map<integer, Set<Id>> mapOfRegistrationIdsToApprove = new map<integer, Set<Id>>();
    
    integer indx;
    //Constructor 
    //12/06/2021 - Modified - CR-20211112-15583 - Chirag Soni - QA/UAT Issue #114 - Comment out the cancel call out to zoom and its related variables 
    //11/16/2021 - CR-20211112-15583 - Chirag soni - Commented mapOfRegistrationIdsToApprove
    public ScheduleJob_ZoomServices(map<integer, Set<Id>> mapOfRegistrationIdsToSync,/* map<integer, Set<Id>> mapOfRegistrationIdsCancel, map<integer, Set<Id>> mapOfRegistrationIdsToApprove,*/ integer index) 
    {
        this.registrationIdsToSyncWithZoom =  mapOfRegistrationIdsToSync.containsKey(index) ? mapOfRegistrationIdsToSync.get(index) : new Set<Id>();
        
        //12/06/2021 - Modified - CR-20211112-15583 - Chirag Soni - QA/UAT Issue #114 - Comment out the cancel call out to zoom and its related variables 
        //this.registrationIdsToCancelInZoom =  mapOfRegistrationIdsCancel.containsKey(index) ?mapOfRegistrationIdsCancel.get(index) : new Set<Id>();
        
        //11/16/2021 - CR-20211112-15583 - Chirag soni - Commented mapOfRegistrationIdsToApprove
        //this.registrationIdsToUpdateApprovedInZoom = mapOfRegistrationIdsToApprove.containsKey(index) ? mapOfRegistrationIdsToApprove.get(index) : new Set<Id>();
        
       
        this.mapOfRegistrationIdsToSync = mapOfRegistrationIdsToSync;
        
        //12/06/2021 - Modified - CR-20211112-15583 - Chirag Soni - QA/UAT Issue #114 - Comment out the cancel call out to zoom and its related variables 
        //this.mapOfRegistrationIdsCancel = mapOfRegistrationIdsCancel;
        //11/16/2021 - CR-20211112-15583 - Chirag soni - Commented
        //this.mapOfRegistrationIdsToApprove = mapOfRegistrationIdsToApprove;
        this.indx = index;
        
    }
    
    public void execute(SchedulableContext context) {
        
        // call future method invokeRegistrantsZoomService
         //11/16/2021 - CR-20211112-15583 - Chirag soni - Commented registrationIdsToUpdateApprovedInZoom
         //12/06/2021 - Modified - CR-20211112-15583 - Chirag Soni - QA/UAT Issue #114 - Comment out the cancel call out to zoom and its related variables 
        invokeRegistrantsZoomService(registrationIdsToSyncWithZoom /*, registrationIdsToCancelInZoom , registrationIdsToUpdateApprovedInZoom*/);
        
        
         //11/16/2021 - CR-20211112-15583 - Chirag soni - Commented mapOfRegistrationIdsToApprove
         //12/06/2021 - Modified - CR-20211112-15583 - Chirag Soni - QA/UAT Issue #114 - Comment out the cancel call out to zoom and its related variables 
          if(mapOfRegistrationIdsToSync.containsKey(indx+1) /*|| mapOfRegistrationIdsCancel.containsKey(indx+1) || mapOfRegistrationIdsToApprove.containsKey(indx+1)*/){
            
            map<integer, Set<Id>> mapOfNextRegistrationIdsToSync = mapOfRegistrationIdsToSync.containsKey(indx+1) ? mapOfRegistrationIdsToSync : new map<integer, Set<Id>>();
            
            //12/06/2021 - Modified - CR-20211112-15583 - Chirag Soni - QA/UAT Issue #114 - Comment out the cancel call out to zoom and its related variables 
            //map<integer, Set<Id>> mapOfNextRegistrationIdsToCancel = mapOfRegistrationIdsCancel.containsKey(indx+1) ? mapOfRegistrationIdsCancel :  new map<integer, Set<Id>>();
            
            //11/16/2021 - CR-20211112-15583 - Chirag soni - Commented 
            //map<integer, Set<Id>> mapOfNextRegistrationIdsToApprove = mapOfRegistrationIdsToApprove.containsKey(indx+1) ? mapOfRegistrationIdsToApprove : new map<integer, Set<Id>>();
            
            //create croj exp to schedule after 15 seconds
            DateTime sysTime = dateTime.now().addSeconds(15);
            String cronExpr = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            
            //String to hold Apex Job Name
            String apexJobName = 'ScheduleJob_ZoomServices' + ' ' + dateTime.now()+' '+math.random();
            
            // passs set of registration ids to constructor of this class 
            //v1.1 - 11/16/2021 - CR-20211112-15583 - Chirag soni - Commented mapOfNextRegistrationIdsToApprove
            //12/06/2021 - Modified - CR-20211112-15583 - Chirag Soni - QA/UAT Issue #114 - Comment out the cancel call out to zoom and its related variables 
            ScheduleJob_ZoomServices scheduleJobZoomServices = new ScheduleJob_ZoomServices(mapOfNextRegistrationIdsToSync/*, mapOfNextRegistrationIdsToCancel , mapOfNextRegistrationIdsToApprove*/, indx+1);
            if(!Util.IsTesting){
            	System.schedule(apexJobName , cronExpr , scheduleJobZoomServices);      
            }
        }
    }
    
    /**
*  @description    : This method is used to create registration, update registration and cancel registration on zoom.
*
*  @arg            : Set<Id> registrationIdsToSyncWithZoom, Set<Id> registrationIdsToCancelInZoom, Set<Id> registrationIdsToUpdateApprovedInZoom
* 
*  @return         : Void
* 
*  @revision       : V1.0 - 07/14/2021 - Created -  CR-20210709-15278 - Chirag Soni
* 		   : V1.1 - 11/16/2021 - Modified - CR-20211112-15583 - Chirag Soni - commented apporved callout and its associated variable 
*		   : V1.2 - 12/06/2021 - Modified - CR-20211112-15583 - Chirag Soni - QA/UAT Issue #114 - Comment out the cancel call out to zoom and its related variables 
* */
    
    @Future(callout=true)//11/16/2021 - CR-20211112-15583 - Chirag soni - Commented registrationIdsToUpdateApprovedInZoom
    //12/06/2021 - Modified - CR-20211112-15583 - Chirag Soni - QA/UAT Issue #114 - Comment out the cancel call out to zoom and its related variables 
    public static void invokeRegistrantsZoomService(Set<Id> registrationIdsToSyncWithZoom) /*,  Set<Id> registrationIdsToCancelInZoom) , Set<Id> registrationIdsToUpdateApprovedInZoom)*/{
        
        Map<Id, Registration__c> regs = new Map<Id, Registration__c>();
        
        //11/16/2021 - CR-20211112-15583 - Chirag soni - Commented 
        /* if(registrationIdsToUpdateApprovedInZoom.size() > 0){
            
            for(Registration__c reg : ZoomServices.updateZoomRegistrantStatus(registrationIdsToUpdateApprovedInZoom, ZoomServices.ZOOM_STATUS_APPROVE))
                regs.put(reg.Id, reg);
        }*/
        
        if(registrationIdsToSyncWithZoom.size() > 0)
            ZoomServices.addZoomRegistrant(registrationIdsToSyncWithZoom);
        
        //12/06/2021 - Modified - CR-20211112-15583 - Chirag Soni - QA/UAT Issue #114 - Comment out the cancel call out to zoom and its related variables 
        /*if(registrationIdsToCancelInZoom.size() > 0){
            
            //Added by - Chirag soni - 11/16/2021 - CR-20211112-15583
            List<Registration__c> cancelledRegistrations = ZoomServices.updateZoomRegistrantStatus(registrationIdsToCancelInZoom, ZoomServices.ZOOM_STATUS_CANCEL);
            if(cancelledRegistrations != null && cancelledRegistrations.size()>0)
            {
                for(Registration__c reg : cancelledRegistrations)
                    regs.put(reg.Id, reg);
            }
        }
        if(regs.size() > 0)
         update regs.values(); */
    }
}