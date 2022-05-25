/** 
* Description   :   Helper class for Crosscheck Operations in Crosscheck Controller for DeploymentWizard Application - OneClick Deployment
*
* Created By    :   Rajeev Jain(Simplyforce)
*
* Created Date  :   02/23/2018
*
* Version       :   V1.0 Created
					v1.1 Modified by Mahendra Swarnkar - CR-20190501-13061 - Spring cleanup
*                   
**/ 
public class CrosscheckHelper {
	
     /**
     * @Description :	Populate Crosscheck Results for the Crosscheck Screen, when Run Crosscheck button clicked on the screen
     * 				:	Or work on the Load of the screen if crosscheck attempt has already been done
     * 
     * @Modifcation	:	Added By - Rajeev Jain - 02/23/2018
     * 
     * @args		:	Deployment Process Summary Record Id
     * 
     * @Return		:	List<CrosscheckResultsWrapper>
     * */
    
    public static List<CrosscheckResultsWrapper> populateCrosscheckResults(String recentCrosscheckId){
        
        //Query on Crosscheck Results based on most Recent Crosschek Id
        //First Get Parent Crosscheck Records.
        List<Crosscheck_Result__c> crosscheckResults = [select Id, Component_Name__c, CR_Number__c, CR_Number__r.Name, Crosscheck_Summary__c, 
                                                        /* Dev_Environment__c,*/ IS_System_Mod__c, IS_System_Mod__r.Name, Last_Modified_By__c, 
                                                         Last_Modified_By__r.Name, Last_Modified_Date__c, Object_Type__c, Overlapping_Crosscheck__c, 
                                                         Release_Name__c, Release_Name__r.Name, Type_of_Mod__c, CR_Status__c
                                                         from Crosscheck_Result__c 
                                                         where Crosscheck_Summary__c = :recentCrosscheckId];
        
        
        //Map to Hold the List of Crosscheck Results which are found as Matching Overlapping Resulst corrosponding to Main Result
        Map<Id, List<Crosscheck_Result__c>> mapMatchingResults = new Map<Id, List<Crosscheck_Result__c>>();
        
        //Map to Hold the Main Crosscheck Results Corrosponding to it's Id
        Map<Id, Crosscheck_Result__c> mapMainResults = new Map<Id, Crosscheck_Result__c>();
        
        //Loop over crosschek Summary Records
        for(Crosscheck_Result__c result : crosscheckResults){
            
            //Check for matching Record or Child Record, here we are having self lookup of Crosscheck_Results
            if(result.Overlapping_Crosscheck__c != null){
               
                if(mapMatchingResults.containsKey(result.Overlapping_Crosscheck__c))
                    mapMatchingResults.get(result.Overlapping_Crosscheck__c).add(result);
                else
                    mapMatchingResults.put(result.Overlapping_Crosscheck__c, new List<Crosscheck_Result__c>{result});
            }else{
                //Put Main Overlapping records or Parent Records
                mapMainResults.put(result.Id, result);
            }    
        }
        
        //Now Populate List of Crosscheck Results Wrapper(Transform Overlapping Results in Relational Format - Parent Child Relationship)
        List<CrosscheckResultsWrapper> resultsWrapper = new List<CrosscheckResultsWrapper>();
        
        //Loop over main Map Results
        for(Id resultId : mapMainResults.keySet()){
            
            //Check With Matching Results
            if(mapMatchingResults.containsKey(resultId)){
                
                //Prepare Result Wrapper Instance
                CrosscheckResultsWrapper wrapper = new CrosscheckResultsWrapper(mapMainResults.get(resultId));
                wrapper.overlappingMods.addAll(mapMatchingResults.get(resultId));
                resultsWrapper.add(wrapper);
            }
        }
        
        return resultsWrapper;
    }
    
     /**
     * @Description :	This method is to run each time a new crosscheck and stamp latest Crosscheck results on "Deployment Process Summary" record.
     * 
     * @Modifcation	:	Added By - Rajeev Jain - 02/26/2018
     * 
     * @args		:	Deployment Process Summary Record Id
     * 
     * @Return		:	List<CrosscheckResultsWrapper>
     * */
    public static List<CrosscheckResultsWrapper> runAndSaveCrosscheckResults(Deployment_Track__c deploymentTrackRef, Deployment_Process_Summary__c processSummary){
    	
        //At Present this Method only support to do crosscheck for Individual CR or Release
        SFDC_Change_Request__c individualCR;
        SFDC_Release__c individualRelease;
        
        //Variable to hold parent Id where file should attach
        Id parentId;
        //Variable to hold parent record name
		String parentName = '';
        
        //If Deployment is for the Change Request then get Change Request Instance
        if(deploymentTrackRef.Deployment_Change_Request__c != null){
            List<SFDC_Change_Request__c> changeRequests = [select Id, Name from SFDC_Change_Request__c where Id = :deploymentTrackRef.Deployment_Change_Request__c LIMIT 1];
            if(changeRequests.size() > 0){
                individualCR = changeRequests[0];
                parentId = changeRequests[0].id;
                parentName = changeRequests[0].Name;
            }
        }
        
        //If deployment is for Individual Release then get Release Instance
        if(deploymentTrackRef.Deployment_Release_Project__c != null){
            List<SFDC_Release__c> releases = [select Id, Name from SFDC_Release__c where Id = :deploymentTrackRef.Deployment_Release_Project__c LIMIT 1];
            if(releases.size() > 0){
                individualRelease = releases[0];
                parentId = releases[0].id;
                parentName = releases[0].Name;
            }
        }
        
        //Hold the Overlapping Results after Crosscheck completion
        Map<String, modWrapper> overlappingMods = new Map<String, modWrapper>();
        
        //Map to hold the Filtered Overlapping Components which exclude Generic Types of the Components
        Map<String, ModWrapper> modTempWrapper = new Map<String, ModWrapper>();
        
        //List to hold the crosscheck records to be inserted as a Main Results from the Source CR or Release
		List<Crosscheck_Result__c> crosscheckMainResults = new List<Crosscheck_Result__c>();
        
        //Do the Crosscheck using Mod Helper class, which handle all kind of the Operations
        //Either it is a Individual crosscheck or Group Crosscheck
        //Or Display the result, attach the result or email the results.
        ModHelper modHelper = new ModHelper(deploymentTrackRef.Sandbox_Refresh_Date__c, individualCR, null, 
                                      individualRelease, parentId, parentName, '', '', 
                                      '', true, false, true, '');
        
        //Calling method to get overlapping result
		overlappingMods = modHelper.crossCheckAndDisplay();
        
        //Processing on the overlapping result and arranging them
        for(String str : overlappingMods.keySet()){
            
            //Filter Out the Generic Type of Component from Crosscheck Report
            if(overlappingMods.containsKey(str) 
               && overlappingMods.get(str).overlappingMods.size() > 0 
               && !DeploymentWizardConstants.excludeIsSystemComponentSet.contains(str)){
					
                   if(!modTempWrapper.containsKey(str)){
                   	
                       ModWrapper wrapper = overlappingMods.get(str);
                       
                       //Add to set to bypass generic types of the components
                       modTempWrapper.put(str, wrapper);
                      
                      //Modified by Mahaendra Swarnkar - CR-20190501-13061 - Spring cleanup 
                       //Add Main Crosscheck Results
                       crosscheckMainResults.add(new Crosscheck_Result__c(Release_Name__c = wrapper.mainMod.Change_Request__r.Release__c,
                                                                           CR_Number__c = wrapper.mainMod.Change_Request__c,
                                                                           IS_System_Mod__c = wrapper.mainMod.Id,
                                                                          /* Dev_Environment__c = wrapper.mainMod.Change_Request__r.Release__r.Dev_Sandbox__r.Id,*/
                                                                           Component_Name__c = str,
                                                                           Object_Type__c = wrapper.mainMod.Object_Type__c,
                                                                           Type_of_Mod__c = wrapper.mainMod.Type_of_Modification__c,
                                                                           Last_Modified_Date__c = wrapper.mainMod.LastModifiedDate,
                                                                           Crosscheck_Summary__c = processSummary.Id,
                                                                           Last_Modified_By__c  = wrapper.mainMod.LastModifiedById,
                                                                           CR_Status__c = wrapper.mainMod.CR_Status__c));
                   }
               }
        }
        
        //ReAssign Filtered Component in Main Map
        overlappingMods = modTempWrapper;
        
        if(crosscheckMainResults.size() > 0){
            
            //Insert the Crosscheck Results
            insert crosscheckMainResults;
            
            //List to hold the Matching Overlapping Results
			List<Crosscheck_Result__c> matchingResults = new List<Crosscheck_Result__c>();
            
            //Loop over Main Overlapping results to find Corrosponding Matching Results, Preapre the List of the Matching Results
            for(Crosscheck_Result__c result : crosscheckMainResults){
                
                if(overlappingMods.containsKey(result.Component_Name__c) && overlappingMods.get(result.Component_Name__c).overlappingMods.size() > 0){
                	
                    //Loop over matching overlapping records to corrosponding to Main Overlapping record
                    for(IS_System_Modification__c mod : overlappingMods.get(result.Component_Name__c).overlappingMods){
                        
                        //Modified by Mahaendra Swarnkar - CR-20190501-13061 - Spring cleanup
                        Crosscheck_Result__c crosscheckResult = new Crosscheck_Result__c(Release_Name__c = mod.Change_Request__r.Release__c,
                                                                                           CR_Number__c = mod.Change_Request__c,
                                                                                           IS_System_Mod__c = mod.Id,
                                                                                          /* Dev_Environment__c = mod.Change_Request__r.Release__r.Dev_Sandbox__r.Id,*/
                                                                                           Component_Name__c = mod.IS_System_Component__r.Object_API_Name__c,
                                                                                           Object_Type__c = mod.Object_Type__c,
                                                                                           Type_of_Mod__c = mod.Type_of_Modification__c,
                                                                                           Last_Modified_Date__c = mod.LastModifiedDate,
                                                                                           Crosscheck_Summary__c = processSummary.Id,
                                                                                           Last_Modified_By__c  = mod.LastModifiedById,
                                                                                           Overlapping_Crosscheck__c = result.Id,
                                                                                           CR_Status__c = mod.CR_Status__c
                                                                                          );
                        matchingResults.add(crosscheckResult);
                    }
                }
            }
			if(matchingResults.size() > 0){
                insert matchingResults;
            }
        }
        
        //Instantiate Blank Instance of Crosscheck Results Wrapper
        //If No Overlapping found then return Blank List
        return populateCrosscheckResults(processSummary.Id);
    }
}