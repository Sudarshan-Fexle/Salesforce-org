/**
*  Purpose         :	This Class is having all the automation logic method on Job Ticket MTM object.
* 
*  Created By      :	Mahendra Swarnkar
*
*  Created Date    : 	
*
*  Revision Logs   :	V_1.0 - Created - Mahendra - CR-20210325-15028
*                     
**/
public without sharing class PackageComponentMtMTriggerHelper {

    /**
    *  Purpose         :	Sets the Job Ticket field on Package Component MtM
    *
    *  Revision Logs   :	V_1.0 - 04/28/2020 - Victor Hanson - Created
    *                     
    **/
    public static void populateJobTicket(List<Package_Component_MtM__c> newPackageComponentMtMs) {
        
        //Map to Holf the Mail Package ID with list of Package Component MtMs
        Map<Id, List<Package_Component_MtM__c>> mapMailPkgIdsWithPkgMTM = new Map<Id, List<Package_Component_MtM__c>>();
        
        for(Package_Component_MtM__c pkgMtm : newPackageComponentMtMs){
            
            if(pkgMtm.Mail_Package__c != null){
                
                if(!mapMailPkgIdsWithPkgMTM.containsKey(pkgMtm.Mail_Package__c))
                    mapMailPkgIdsWithPkgMTM.put(pkgMtm.Mail_Package__c, new List<Package_Component_MtM__c>());
                
                mapMailPkgIdsWithPkgMTM.get(pkgMtm.Mail_Package__c).add(pkgMtm);  
            }
        }
        
        //Check for size
        if(mapMailPkgIdsWithPkgMTM.size() > 0 && mapMailPkgIdsWithPkgMTM.keySet().size() > 0){
            
            //Query over the mail Packages
            for(Mail_Package__c mailPkg : [SELECT ID, Creative_Package__r.Job_Ticket__c From Mail_Package__c 
                                           	WHERE Creative_Package__c != null AND Creative_Package__r.Job_Ticket__c != null 
                                           	AND Id IN : mapMailPkgIdsWithPkgMTM.keySet()])
            {
                if(mapMailPkgIdsWithPkgMTM.containsKey(mailPkg.Id) && mapMailPkgIdsWithPkgMTM.get(mailPkg.Id) != null) {
					
                	for(Package_Component_MtM__c pkgMtm : mapMailPkgIdsWithPkgMTM.get(mailPkg.Id)) {
                        
                        //Populate the Job ticket on the Package Component MtMs 
                        pkgMtm.Job_Ticket__c = mailPkg.Creative_Package__r.Job_Ticket__c;
                    }
                }
            }
        }
    }
}