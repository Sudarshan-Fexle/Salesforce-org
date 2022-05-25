/** 
* Description   :   Helper class for Deployment Package Retrieval Operations in PackageRetrievalController for DeploymentWizard Application - OneClick Deployment
*
* Created By    :   Rajeev Jain(Simplyforce)
*
* Created Date  :   03/13/2018
*
* Version       :   V1.0 Created
*                   
**/ 
public class PackageRetrievalHelper {
   
    /**
     * @Description :  Populate Retrieval Results for the Package Retrieval Screen, when Retrieve Package button clicked on the screen
     *         :  Or work on the Load of the screen if PackageRetrieval attempt has already been made.
     * 
     * @Modifcation  :  Added By - Rajeev Jain - 03/13/2018
     * 
     * @args    :  Deployment Process Summary Record Id
     * 
     * @Return    :  List<Package_Retrieval_Result__c>
     * */
    public static List<Package_Retrieval_Result__c> populateRetrievalResults(Id retrievalResultSummaryId){
      
        //Query on Retreival Results
        List<Package_Retrieval_Result__c> results = [SELECT Id, Errors__c, Resolution__c, Resolution_by__c, Package_Retrieval_Summary__c 
                                                     FROM Package_Retrieval_Result__c
                                                    where Package_Retrieval_Summary__c = :retrievalResultSummaryId];
        return results;
    }
    
    /**
     * @Description :  Method to preapre the package.xml file and attach it on the Retrieval Summary Record
     * 
     * @Modifcation  :  Added By - Rajeev Jain - 03/13/2018
     * 
     * @args    :  Deployment Track Reference, Prcoess Summary Instance
     * 
     * @Return    :  List<Package_Retrieval_Result__c>
     * */
    public static Id createPackageAndAttach(Deployment_Track__c trackRef, Deployment_Process_Summary__c retrievalSummary, DeploymentWizardBean appProperties, List<IS_System_Modification__c> excludedMods){
        
        //Set to hold the Releases, CRs and Mods
         Set<String> setOfReleases = new Set<String>();
        Set<String> setOfCRs = new Set<String>();
        Set<String> setOfSfdcMods = new Set<String>();
         
        //Add Release Name and CR Name in the Set
        setOfReleases.add(appProperties.releaseName);
        setOfCRs.add(appProperties.crName);

        //For the Groupings of CR. We are cheking on the Deployment Groups and check if there are back sync Deployment Tracks. 
        if(String.isNotBlank(trackRef.Deployment_Group__c)) {
            setOfReleases = new Set<String>();
            setOfCRs = new Set<String>();

            //Adding the CRs from the Group. 
            setOfCRs =  DeploymentWizardHelper.fetchCRNumbersOfAGroup(trackRef.Deployment_Group__c);
        }
        
        //Variable to Hold Parent Id, will be needed while attaching the package file
        Id parentId = retrievalSummary.Id;
        
        //Query on Retrieval Summary Record To Get it's Name
        Deployment_Process_Summary__c processSummaryInstance = [select Name from Deployment_Process_Summary__c where Id = :retrievalSummary.id Limit 1]; 
            
        //String to hold Parent record name on which package file is attached
        String parentName = '';
        if(processSummaryInstance != null)
            parentName = processSummaryInstance.Name;
        
        //Place Holder Set to Ignore Mod, CR based on name and status
        //Populate Sets for Criteria
        //To Do - Will use in future logic
        Set<String> ignoredCRs = new Set<String>();
        Set<String> ignoredMods = new Set<String>();
        Set<String> ignoredCrStatus = new Set<String>();
        
        //Populate Ignored Mods Set
        //Get Exluded Mods List and add each mod name in the ignoredMods set
        for(IS_System_Modification__c mod : excludedMods)
            ignoredMods.add(mod.Name);
        
        //Populate Default Ignored CR Status - Exclude 'Hold' and 'Cancelled' Crs from Populating in case of Whole Release Deployment
        if(String.isNotBlank(appProperties.releaseName)){
            ignoredCrStatus.add('Cancelled');
            ignoredCrStatus.add('On Hold');
        }
            
        PackageFileHelper packageHelper = new PackageFileHelper(setOfReleases, setOfCRs, setOfSfdcMods, ignoredCrStatus, 
                                                                    ignoredCRs, ignoredMods, false);
        
        //Total Componets included in the Package
        //Populate Total Component Information
         retrievalSummary.Total_Component__c = packageHelper.numberOfQueredModification;
        System.debug('packageHelper.numberOfQueredModification;'+packageHelper.numberOfQueredModification);
        
        
        Attachment attach = packageHelper.createPackageAndAttach(System.Label.DEPLOYMENT_PACKAGE_FILE_VERSION, parentId, parentName, false);
        system.debug('attach'+attach);
        return attach.Id;
    }
    
    /**
     * @Description :  Method to hit Heroku WebService and Run the Package Retrieval Operations and Save the Retreival Errors Back to the Salesforce
     * 
     * @Modifcation  :  Added By - Rajeev Jain - 03/21/2018
     * 
     * @args    :  Deployment Track Reference, Prcoess Summary Instance
     * 
     * @Return    :  List<Package_Retrieval_Result__c>
     * */
    @future(callout=true)
    public static void retrievePackage(String trackRef, String retrievalSummary){
        Deployment_Track__c trackRefX = (Deployment_Track__c)JSON.deserialize(trackRef, Deployment_Track__c.class);
        Deployment_Process_Summary__c summaryRef = (Deployment_Process_Summary__c)JSON.deserialize(retrievalSummary, Deployment_Process_Summary__c.class);
       
        HttpRequest request = OneClick_HttpRequestBuilder.CreateRequest(DeploymentWizardConstants.DEPLOYMENT_PROCESS_REQUEST_TYPE_PECKAGE_RETRIEVAL,trackRefX, summaryRef);
        Http http = new Http();
        
        if(!Test.isRunningTest())
      HttpResponse httpResponse = http.send(request); 
    }
    
     /**
     * @Description :  Method to get Excluded Mods List
     * 
     * @Modifcation  :  Added By - Rajeev Jain - 04/10/2018
     * 
     * @args    :  Deployment Track Reference, Prcoess Summary Instance
     * 
     * @Return    :  List<Is_System_Modification__C>
     * */
    public static List<IS_System_Modification__c> getExcludedModsList(Deployment_Track__c deploymentTrackRef,  DeploymentWizardBean appProperties){
      
        //Utilize Based Query Method to filter out first level of Mods and Reutilization of Where clause logics
        String baseQuery = DeploymentWizardHelper.getBaseQueryForIsSystemMod(deploymentTrackRef, appProperties);
        
        //Query to get first level of mods
        List<IS_System_Modification__c> mods = Database.query(baseQuery);
        
        //Query on Mods to filter out "Custom Object" mods 
        List<IS_System_Modification__c> excludedMods = [select Id, Name, IS_System_Component__r.Object_API_Name__c, Type_of_Modification__c, 
                                                        LastModifiedById, LastModifiedBy.Name, LastModifiedDate, Description__c, Object_Label__c,
                                                        Change_Request__c, Change_Request__r.Name
                                                        from IS_System_Modification__c 
                                                        where Id IN :mods AND Type_of_Modification__c = 'Modify' AND IS_System_Component__r.Object_Type__c = 'Custom Object'];
        
        return excludedMods;
    }
}