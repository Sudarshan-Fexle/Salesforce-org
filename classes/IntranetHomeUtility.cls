//V_1.1 - Modified By - Abhinav Sharma - CR-20150219-8692 - 04/29/2015
//V_1.2 - Modified By - Rajeev Jain - CR-20141003-7624 - 08/07/2015 - BoardRoom Phase 2
//V_1.3 - Modified By - Mahendra Swarnkar - CR-20170918-11372 - 09/28/2017
//V_1.4 - Modified By - Rajeev Jain CR-20180919-12608   
public class IntranetHomeUtility {
    
    public static String UserBrowser;
    public static String UserDevice;
    public static Integer ScreenSize;
    public static String NetworkAccess;
    
    //Constants
    public final static String NONE = 'NONE';
    public final static String TYPE_DPA = 'DPA';
    public final static String IMPORTANCE = 'Importance';
    public final static String OFFICE = 'Office';
    public final static String MANAGER = 'Manager';
    public final static String LEVEL = 'Level';
    public final static String FULL = 'Full';
    public final static String DATEonly = 'Date';
    public final static String DEPARTMENT = 'Department';
    public final static String DIVISION = 'Division';
    public final static String FUNCTION = 'Function';
    public final static String TIME_FRAME_EMPHASIS_BREAK_POINT = 'TimeframeEmphasisBreakpoint';
    public final static String CRITICAL_VISIBILITY = 'CriticalVisible';
    
    public final static String ALL = 'All';
    public final static String SAME = 'Same';
    public final static String LOCAL = 'Local';
    public final static String OTHER = 'Other';
    public final static String TIME_FRAME_EMPHASIS_START = 'Start';
    public final static String TIME_FRAME_EMPHASIS_END = 'End';
    
    public final static String HTTP = 'http://';
    public final static String HTTPS = 'https://';
    
    public final static string RTName_Office = 'Settings_Office';
    public final static string DEFAULT_OFFICE_NAME = 'DC Office';

    public final static string TALENTIMAGESET_MANAGER = 'TalentImageSet_Manager';
    public final static string TALENTIMAGESET_NONMANAGER = 'TalentImageSet_NonManager';

    private static Map<String, Intranet_Settings__c> mIntranetSettings;
    public static Map<String, Intranet_Settings__c> IntranetSettings {
        get {
            if(mIntranetSettings == null)
                mIntranetSettings = Intranet_Settings__c.getAll();
            return mIntranetSettings;
        }
    }
    public static string LookupIntranetSetting(string key) {
        if(IntranetSettings.containsKey(key)) {
            return IntranetSettings.get(key).Value__c;                             
        }
        return null;
    }
    
    private static Map<String, Intranet_Defaults__c> mIntranetDefaults;
    private static Map<String, Intranet_Defaults__c> mIntranetDefaultsByName;
    public static Map<String, Intranet_Defaults__c> IntranetDefaults {
        get {
            if(mIntranetDefaults == null) {
                mIntranetDefaults = new Map<String, Intranet_Defaults__c>();
                mIntranetDefaultsByName = new Map<String, Intranet_Defaults__c>();
                Map<String, Intranet_Defaults__c> defaults = Intranet_Defaults__c.getAll();
                for(Intranet_Defaults__c idf : defaults.values()) {
                    mIntranetDefaults.put(idf.Item_Type__c, idf);
                    mIntranetDefaultsByName.put(idf.name, idf);
                }
            }
            return mIntranetDefaults;
        }
    }
    public static Intranet_Defaults__c LookupIntranetDefault(string itemType) {
        if(IntranetDefaults.containsKey(itemType)) {
            return IntranetDefaults.get(itemType);                             
        }
        return null;
    }
    public static Intranet_Defaults__c LookupIntranetDefaultByName(String name) {
        if(IntranetDefaults != null && mIntranetDefaultsByName.containsKey(name)) {
            return mIntranetDefaultsByName.get(name);                             
        }
        return null;
    }

    private static Map<String, Set<String>> mMapItemCategoryTypes;
    public static Map<String, Set<String>> getIntranetItemCategoryTypeMaps() {
        if(mMapItemCategoryTypes == null) {
            mMapItemCategoryTypes = new Map<String, Set<String>>();
            Map<String, String> mapItemTypeCategory = new Map<String, String>();
            for(String itemType : IntranetDefaults.keyset()) {
                if(itemType == null) continue;

                Intranet_Defaults__c intranetDefault = IntranetDefaults.get(itemType);
                if(intranetDefault == null) continue;

                String category = intranetDefault.SearchCategory__c;
                if(category == null || category == 'Exclude') continue;

                if(!mapItemTypeCategory.containsKey(itemType)) {
                    mapItemTypeCategory.put(itemType, category);
                    Set<string> existingTypes = mMapItemCategoryTypes.get(category);
                    if(existingTypes == null) existingTypes = new Set<String>();
                    if(!existingTypes.contains(itemType)) existingTypes.add(itemType);
                    mMapItemCategoryTypes.put(category, existingTypes);
                }
            }
        }

        return mMapItemCategoryTypes;
    }


    private static Intranet_Constants__c mIntranetConstants;
    public static Intranet_Constants__c IntranetConstants {
        get {
            if(mIntranetConstants == null)
                mIntranetConstants = Intranet_Constants__c.getOrgDefaults();
            return mIntranetConstants;
        }
    }


    /**
     *  @description    :   This  method is to convert the Integer ScreenSize to a appropriate values as defined in Minimum Visible Picklist field in Intranet Container
     * 
     *  @args           :   Integer Screen Size
     * 
     *  @return         :   Matching Minimum Visible Picklist value
     *
     **/
    public static String convertScreenSizeToString(Integer intScreenSize) {
        
        //If screen size is not null
        if(intScreenSize != null) {
            
            //Convert the value in Text
            String screenSizeStringVal = String.valueOf(intScreenSize);
            
            //Describe Picklist value
            for(Schema.PicklistEntry pE : Intranet_Container__c.Minimum_Visible_Screen__c.getDescribe().getpicklistValues()) {
                
                //Check if user selected value match with any picklist value
                if(pE.getValue().containsIgnoreCase(screenSizeStringVal)) {
                    
                    //return picklist values
                    return pE.getValue();
                } else if(pE.getValue().containsIgnoreCase('<')) {
                    
                    //Get numeric value
                    List<String> pairedNumeric = pE.getValue().split('<');
                    if(pairedNumeric.size() > 1) {
                        
                        //Numeric Val
                        List<String> numericScreenSize = pairedNumeric[1].split(' ');
                        if(numericScreenSize.size() > 0) {
                            
                            //Screen Size()
                            if(Integer.valueOf(numericScreenSize[0]) > intScreenSize)
                                return pE.getValue();
                        }
                    }
                } else if(pE.getValue().containsIgnoreCase('>')) {
                    
                    //Get numeric value
                    List<String> pairedNumeric = pE.getValue().split('>');
                    if(pairedNumeric.size() > 1) {
                        
                        //Numeric Val
                        List<String> numericScreenSize = pairedNumeric[1].split(' ');
                        if(numericScreenSize.size() > 0) {
                            
                            //Screen Size()
                            if(Integer.valueOf(numericScreenSize[0]) < intScreenSize)
                                return pE.getValue();
                        }
                    }   
                }
                
            }
        }
        
        //return null
        return null;
    }
    
    /**
     *  @description    :   This method is to get the Job Level from the Complete String
                                Example value:  10 B1 Early Professional        ‘B’ needs to be extracted
     * 
     *  @args           :   String
     * 
     *  @return         :   Job Level Code
     * 
     **/
    public static String getJobLevelCode(String jLevel) {
        
        //Only process is Job level is not null
        if(String.isNotBlank(jLevel)) {
            
            //Split by spaces
            List<String> pairs = jLevel.split(' ');
            
            //Get the code
            if(pairs.size() >= 2 && pairs[1].trim().length() > 0) {
                 
                 return pairs[1].trim().left(1);
            }
        }
        
        return null;
    }
    
    /**
     *  @description    :   This method is to populate the UserSession
     *
     *  @args           :   
     *
     *  @return         :   UserSession
     *
     **/
    public static IntranetType.UserSession getUserSession {
        get {
            
            if (getUserSession == null) {
                
                //Modified By Mahendra Swarnkar - CR-20170918-11372 - 09/28/2017  - Added "Entity__c" field in the query.
                //Get the Current user information from database and  populate the User Session instance
                User currentUser = [Select Id, FirstName, LastName, Office__c, Workspace__c, Job_Level__c, ABC_Department__c,
                    ABC_Division__c, ABC_Function__c, ManagerId, IsManager__c, Entity__c from User where Id =: UserInfo.getUserId()];
                
                //Popuate the Session Instance
                getUserSession = new IntranetType.UserSession();
                getUserSession.FirstName = currentUser.FirstName;
                getUserSession.LastName = currentUser.LastName;
                getUserSession.UserId = currentUser.Id;
                getUserSession.AssignedOffice = currentUser.Office__c;
                getUserSession.Workspace = currentUser.Workspace__c;
                getUserSession.JobLevel = IntranetHomeUtility.getJobLevelCode(currentUser.Job_Level__c);
                getUserSession.Department = currentUser.ABC_Department__c;
                getUserSession.Division = currentUser.ABC_Division__c;
                getUserSession.Function = currentUser.ABC_Function__c;
                getUserSession.ScreenSize = IntranetHomeUtility.convertScreenSizeToString(IntranetHomeUtility.ScreenSize);
                getUserSession.AccessLocation = IntranetHomeUtility.NetworkAccess;
                getUserSession.Browser = IntranetHomeUtility.UserBrowser;
                getUserSession.Device = IntranetHomeUtility.UserDevice;
                getUserSession.Manager = currentUser.IsManager__c != null && currentUser.IsManager__c;
				
				//Added By Mahendra Swarnkar - CR-20170918-11372 - 09/28/2017  - Starts from here
				getUserSession.UserEntity = currentUser.Entity__c;
				//Added By Mahendra Swarnkar - CR-20170918-11372 - 09/28/2017  - Ends here
				
				
                //V_1.2 - Modified By - Rajeev Jain - CR-20141003-7624 - 08/07/2015 - BoardRoom Phase 2
                //To Access Actual Job Level
                getUserSession.JobLevelActual = currentUser.Job_Level__c;
                
                // Set default Office
                if(getUserSession.AssignedOffice == null) {
                    for(SelectOption option : OfficeSelectList) {
                        if(option.getLabel() == DEFAULT_OFFICE_NAME) {
                            getUserSession.AssignedOffice = option.getValue();
                            break;
                        }
                    }
                }
            }
            
            //Return getUserSession
            return getUserSession;
        }
        set;
    }
    
    /*
    public static IntranetType.FooterContainer getFooterContent(Id FooterId){
        
        IntranetType.FooterContainer FooterRecord = new IntranetType.FooterContainer();
        
        List <Intranet_Container__c> FooterList = [SELECT Id, RecordType.DeveloperName, Name, Container_Type__c, Container_Level__c, Content_Types_Allowed__c, Display_Name__c, Default_Content_Item__c, Has_SubContainers__c, Height__c, Max_Content_Items__c, Minimum_Visible_Screen__c, Position__c, Reference_Number__c, Screen_Priority__c, Show_Expand_Link__c, Show_Feedback_Link__c, Status__c, Width__c, Parent_Container__c 
                                                   FROM Intranet_Container__c
                                                   WHERE Id = :FooterId or Parent_Container__c = :FooterId
                                                   Order by CreatedDate];
        
        FooterRecord = IntranetType.LoadFooterContainer(FooterList);
        
        return FooterRecord;
        
    }
    
    public static IntranetType.Container getContainers (Id BodyId){
        
        IntranetType.Container ContainerRecord = new IntranetType.Container ();
        
        List <Intranet_Container__c> BodyContainer = [SELECT Id, RecordType.DeveloperName, Name, Container_Type__c, Container_Level__c, Content_Types_Allowed__c, Display_Name__c, Default_Content_Item__c, Has_SubContainers__c, Height__c, Max_Content_Items__c, Minimum_Visible_Screen__c, Position__c, Reference_Number__c, Screen_Priority__c, Show_Expand_Link__c, Show_Feedback_Link__c, Status__c, Width__c, Parent_Container__c 
                                                   FROM Intranet_Container__c
                                                   WHERE Id = :BodyId or Parent_Container__c = :BodyId
                                                   Order by CreatedDate];
        
        ContainerRecord = IntranetType.LoadBodyContainers(BodyContainer);
        
        return ContainerRecord;
    }
    */
    
    /**
     *  @description    :   This method is to calculate the DPA score
     * 
     *  @args           :   CurrentUserSession, CurrentIntranetSchedule, CurrentIntranetItem
     * 
     *  @return         :   Score
     * 
     **/
    public static Decimal calculateDPAScore(IntranetType.UserSession UserSession, Intranet_Schedule__c intranetSchedule, Intranet_Item__c intranetItem) {
        
        //Added By Mahendra Swarnkar - CR-20170918-11372 - 09/28/2017  - Starts from here
        
        //variable to holds the Entity Score 
        Integer entityScore;
        
        //Check entity type fpr the current user and on the Intranet schedule and then accordingly set the value for EntityScore to 0(if not mathed) or 1(If matched)  
        if( intranetSchedule != null 
        	&& UserSession != null
        	&& isVisibleForUserEntity(intranetSchedule.Entity__c, UserSession.UserEntity)
        ){
        	//Set the Entity score to 1
			entityScore = 1;
        }
        else{
        	//Set the entity Score to 0
        	entityScore = 0;
        }
        //Added By Mahendra Swarnkar - CR-20170918-11372 - 09/28/2017  - Ends here
        
        
        //Variable to hold key
        String key;
        
        //Get the DPA Score Type
        String DPAScoreType = intranetSchedule.Intranet_Container__r.DPA_Score_Type__c;
         
        /********** Importance Score **********/
        //Set default
        Integer importanceScore = 50;
        
        //Check if importance is not blank, then get the data from custom setting
        if(String.isNotBlank(intranetSchedule.Importance__c)) {
            
            //Generate Key
            key = IntranetHomeUtility.IMPORTANCE + '_' + intranetSchedule.Importance__c;
            
            //Key DPA Score is defined for this key
            if(IntranetSettings.containsKey(key) 
                && IntranetSettings.get(key).Type__c == IntranetHomeUtility.TYPE_DPA 
                && IntranetSettings.get(key).Value__c !=  null) {
                
                //Get Score 
                importanceScore = Integer.valueOf(IntranetSettings.get(key).Value__c);
            }
        }
        /********** End of Importance Score **********/
        
        /********** Office Score **********/
        //Set default
        Integer officeScore = 1;
        String officeType = IntranetHomeUtility.OTHER;
        
        //Check is user office and Item Office are Same
        //JRB if(intranetSchedule.Office__r.Name == IntranetHomeUtility.ALL) {
        
        if(IntranetSettings.containsKey('AllOfficeShortName') 
        && intranetSchedule.Office__r.Office_Short_Name__c == IntranetSettings.get('AllOfficeShortName').value__c) 
        {
            
                officeType = IntranetHomeUtility.ALL;
        }
        else if(IntranetSettings.containsKey('AllOfficeShortName') &&
        UserSession.AssignedOffice == string.valueOf(intranetSchedule.Office__c)) 
        {
            
            officeType = IntranetHomeUtility.LOCAL;
        }
        
        //Generate Key
        key = IntranetHomeUtility.OFFICE + '_' + officeType;
        
        //Key DPA Score is defined for this key
        if(IntranetSettings.containsKey(key) 
            && IntranetSettings.get(key).Type__c == IntranetHomeUtility.TYPE_DPA 
            && IntranetSettings.get(key).Value__c !=  null) {
           
            //Get Score 
            officeScore = Integer.valueOf(IntranetSettings.get(key).Value__c);
        }
        /********** End of Office Score **********/
        
        /********** Job Level **********/
        //Set default
        Integer jobLevelScore = 1;
        String levelType = IntranetHomeUtility.OTHER;
        
        //Check is user level and Item Job Level are Same
        if(String.isBlank(intranetSchedule.Level__c) || (UserSession.JobLevel != null && intranetSchedule.Level__c.contains(UserSession.JobLevel))) {
            
            levelType = IntranetHomeUtility.SAME;
        } 
        
        //Generate Key
        key = IntranetHomeUtility.LEVEL + '_' + levelType;
        
        //Key DPA Score is defined for this key
        if(IntranetSettings.containsKey(key) 
            && IntranetSettings.get(key).Type__c == IntranetHomeUtility.TYPE_DPA 
            && IntranetSettings.get(key).Value__c !=  null) {
            
            //Get Score 
            jobLevelScore = Integer.valueOf(IntranetSettings.get(key).Value__c);
        }
        /********** End of Job Level **********/
        
        /********** Department **********/
        //Set default
        Integer departmentScore = 1;
        String departmentType;
        
        //Check is user level and Item Job Level are Same
        if(String.isNotBlank(intranetSchedule.Department__c) && (UserSession.Department != null && String.isNotBlank(UserSession.Department))) {
            
            //Chekc if both are of same
            if(UserSession.Department == intranetSchedule.Department__c) {
                
                departmentType = IntranetHomeUtility.SAME;
            } else {
                
                departmentType = IntranetHomeUtility.OTHER;
            }
        }
        
        //Generate Key
        key = IntranetHomeUtility.DEPARTMENT + '_' + departmentType;
        
        //Key DPA Score is defined for this key
        if(IntranetSettings.containsKey(key) 
            && IntranetSettings.get(key).Type__c == IntranetHomeUtility.TYPE_DPA 
            && IntranetSettings.get(key).Value__c !=  null) {
            
            //Get Score 
            departmentScore = Integer.valueOf(IntranetSettings.get(key).Value__c);
        }
        /********** End of Department **********/
        
        /********** Division **********/
        //Set default
        Integer divisionScore = 1;
        String divisionType;
        
        //Check is user level and Item Job Level are Same
        if(String.isNotBlank(intranetSchedule.Division__c) && (UserSession.Division != null && String.isNotBlank(UserSession.Division))) {
            
            //Chekc if both are of same
            if(UserSession.Division == intranetSchedule.Division__c) {
                
                divisionType = IntranetHomeUtility.SAME;
            } else {
                
                divisionType = IntranetHomeUtility.OTHER;
            }
        }
        
        //Generate Key
        key = IntranetHomeUtility.DIVISION + '_' + divisionType;
        
        //Key DPA Score is defined for this key
        if(IntranetSettings.containsKey(key) 
            && IntranetSettings.get(key).Type__c == IntranetHomeUtility.TYPE_DPA 
            && IntranetSettings.get(key).Value__c !=  null) {
            
            //Get Score 
            divisionScore = Integer.valueOf(IntranetSettings.get(key).Value__c);
        }
        /********** End of Division **********/
        
        /********** Function **********/
        //Set default
        Integer functionScore = 1;
        String functionType;
        
        //Check is user level and Item Job Level are Same
        if(String.isNotBlank(intranetSchedule.Function__c) && (UserSession.Function != null && String.isNotBlank(UserSession.Function))) {
            
            //Chekc if both are of same
            if(UserSession.Function == intranetSchedule.Function__c) {
                
                functionType = IntranetHomeUtility.SAME;
            } else {
                
                functionType = IntranetHomeUtility.OTHER;
            }
        }
        
        //Generate Key
        key = IntranetHomeUtility.FUNCTION + '_' + functionType;
        
        //Key DPA Score is defined for this key
        if(IntranetSettings.containsKey(key) 
            && IntranetSettings.get(key).Type__c == IntranetHomeUtility.TYPE_DPA 
            && IntranetSettings.get(key).Value__c !=  null) {
            
            //Get Score 
            functionScore = Integer.valueOf(IntranetSettings.get(key).Value__c);
        }
        /********** End of Function **********/
        
        /********** Timeframe Emphasis **********/
        //Set default
        Decimal timeframeEmphasisScore = 1.0;
        
        if(IntranetSettings.containsKey(IntranetHomeUtility.TIME_FRAME_EMPHASIS_BREAK_POINT)
            && intranetSchedule.Start_Date_Time__c != null 
            && intranetSchedule.End_Date_Time__c != null
            && (intranetSchedule.Timeline_Emphasis__c == IntranetHomeUtility.TIME_FRAME_EMPHASIS_START || intranetSchedule.Timeline_Emphasis__c == IntranetHomeUtility.TIME_FRAME_EMPHASIS_END)
        ) {
        
            //BreakPoint    
            Integer TimeframeEmphasisBreakpoint = Integer.valueOf(IntranetSettings.get(IntranetHomeUtility.TIME_FRAME_EMPHASIS_BREAK_POINT).Value__c);
            Integer daysVisible = intranetSchedule.Start_Date_Time__c.date().daysBetween(intranetSchedule.End_Date_Time__c.date());
            Integer daysRemaining  = Date.today().daysBetween(intranetSchedule.End_Date_Time__c.date());
            Integer daysIn = intranetSchedule.Start_Date_Time__c.date().daysBetween(Date.today());
            
            //Check for the Start and End multiplier
            if(intranetSchedule.Timeline_Emphasis__c == IntranetHomeUtility.TIME_FRAME_EMPHASIS_START && daysVisible > 0 && daysRemaining > 0)
                timeframeEmphasisScore = Math.log10(((daysRemaining*1.0)/daysVisible)*100.0)/Math.log10(TimeframeEmphasisBreakpoint * 1.0);
            else if(intranetSchedule.Timeline_Emphasis__c == IntranetHomeUtility.TIME_FRAME_EMPHASIS_END && daysVisible > 0 && daysIn > 0)
                timeframeEmphasisScore = Math.log10(((daysIn*1.0)/daysVisible)*100.0)/Math.log10(TimeframeEmphasisBreakpoint * 1.0);
        }
        /********** End of Timeframe Emphasis **********/
        
        /********** Manager **********/
        Integer managerScore = 1;
        
        //Check for the Manager Score
        if(intranetSchedule.Manager_Level_Only__c == true && UserSession.Manager != true)
            managerScore = 0;
        /********** End of Manager **********/
        
        /********** Critical Visibility **********/
        Integer criticalVisibilityScore = 0;
        
        //Check for the Manager Score
        if(intranetSchedule.Critical_Visibility__c == true && IntranetSettings.containsKey(IntranetHomeUtility.CRITICAL_VISIBILITY))
            criticalVisibilityScore = Integer.valueOf(IntranetSettings.get(IntranetHomeUtility.CRITICAL_VISIBILITY).Value__c);
        /********** End of Critical Visibility **********/
        
        /********** DPA Calculations **********/
        
        //Modified By Mahendra Swarnkar - CR-20170918-11372 - 09/28/2017  - Added EntityScore in the visibilityMultiplier calculation.
        //Pre Calculations
        Integer visibilityMultiplier = officeScore * jobLevelScore * managerScore * entityScore;
        if(visibilityMultiplier > 0)
            visibilityMultiplier = 1;
        
        //Check for the DPA Score Type and calculate
        if(String.isNotBlank(DPAScoreType) && !DPAScoreType.equalsIgnoreCase(IntranetHomeUtility.NONE)) {
            
            Decimal DPAScoreResult = 0;
            
            //Office
            if(DPAScoreType.equalsIgnoreCase(IntranetHomeUtility.OFFICE)) {
                
                //Uses Office, Importance, Timeline Emphasis, Critical Visible elements
                DPAScoreResult = ((((importanceScore + officeScore)/2) * timeframeEmphasisScore) + criticalVisibilityScore) * visibilityMultiplier;
                
                //Date
            }else if(DPAScoreType.equalsIgnoreCase(IntranetHomeUtility.DATEonly)) {
                //Uses Timeline Emphasis, Critical Visible elements
                DPAScoreResult = ((timeframeEmphasisScore + criticalVisibilityScore) * visibilityMultiplier);
                
                //Level
            }else if(DPAScoreType.equalsIgnoreCase(IntranetHomeUtility.LEVEL)) {
                //Uses Timeline Emphasis, Importance, Level, and Critical Visible  elements
                DPAScoreResult = ((((importanceScore + jobLevelScore)/3) * criticalVisibilityScore) + criticalVisibilityScore) * visibilityMultiplier;
                
                //Manager
            }else if(DPAScoreType.equalsIgnoreCase(IntranetHomeUtility.MANAGER)) {
                //Uses Manager, Critical Visible elements
                DPAScoreResult = (ManagerScore) * timeframeEmphasisScore;
                
                //Full DPA Calculation
            }else if(DPAScoreType.equalsIgnoreCase(IntranetHomeUtility.FULL)) {
                //Uses All - Importance, Critical Invisible, Timeline Emphasis, Office, Job Level, Department, Division, Function elements
                DPAScoreResult = ((((importanceScore + officeScore + jobLevelScore + departmentScore + divisionScore + functionScore)/7) * timeframeEmphasisScore) + criticalVisibilityScore) * visibilityMultiplier;
            }
            
            if(DPAScoreResult != null){
                return DPAScoreResult;
            }
            
            if(UserSession.Function == intranetSchedule.Function__c) {            } else if(DPAScoreType.equalsIgnoreCase(IntranetHomeUtility.MANAGER)) {
                
                return managerScore > 0 ? 1 : 0;
                //} else if(DPAScoreType.equalsIgnoreCase(IntranetHomeUtility.LEVEL)) {
                // 
                //    System.debug(officeScore + '-' + jobLevelScore + '-' + departmentScore + '-' + divisionScore + '-' + functionScore + '-' + timeframeEmphasisScore + '-' + criticalVisibilityScore + '-' + visibilityMultiplier);
                //    return ((((officeScore + jobLevelScore + departmentScore + divisionScore + functionScore)/5) * timeframeEmphasisScore) + criticalVisibilityScore) * visibilityMultiplier;
                //} else if(DPAScoreType.equalsIgnoreCase(IntranetHomeUtility.FULL)) {
                //    
                //    return ((((importanceScore + officeScore + jobLevelScore + departmentScore + divisionScore + functionScore)/6) * timeframeEmphasisScore) + criticalVisibilityScore) * visibilityMultiplier;
            }
        }
        
        return null;
    }
    
    /**
     *  @description    :   This method is to check if URL is valid or not and update this accordingly
     * 
     *  @args           :   Link URL
     * 
     *  @return         :   Valid URL
     * 
     **/
    public static String validateAndFormatURL(String linkURL) {
        if(linkURL == null) return '';
        
        //check if  linkURL is not blank
        if(String.isNotBlank(linkURL)) {
        
            // JS: Skip this for the relative links
            if(linkURL.startsWith('/')) {
                return linkURL;
            }

            //Check if link doesn't start with http or https, then update it
            if(!linkURL.startsWithIgnoreCase(IntranetHomeUtility.HTTPS) && !linkURL.startsWithIgnoreCase(IntranetHomeUtility.HTTP)) {
                
                //Update Link URL and add HTTP link
                if(linkURL.contains('//')) {
                    linkURL = linkURL.subString(linkURL.indexOf('//')+2, linkURL.length());
                    linkURL = IntranetHomeUtility.HTTP + linkURL;
                } else
                    linkURL = IntranetHomeUtility.HTTP + linkURL;
            }   
        }
            
        return linkURL;
    }
    
    /**
     *  @description    :   This method is to return the list of offices in a list for selection by the ABC Office component
     * 
     *  @args           :   none
     * 
     *  @return         :   List of Offices in a SelectOption format
     * 
     *  @Change Log		:	v1.2 - Modified - Victor Hanson - 10/05/2017 - CR-20171003-11642 added reference to Entity field
     * 
     **/

    static map<Id, String> mapOffices; 
    public static List<SelectOption> OfficeSelectList {
        get {
            if (OfficeSelectList == null) {
                
                //get the offices to add to the list
                List<Intranet_Item__c> offices = [select id, Office_Name__c, Office_Short_Name__c, Entity__c from Intranet_Item__c 
                                                  where RecordType.DeveloperName = :RTName_Office and Active_Status__c = 'Active' order by Office_Short_Name__c];
                
                string allOfficesName;
                if(Intranet_Settings__c.getInstance('AllOfficeShortName') != null){
                    allOfficesName = Intranet_Settings__c.getInstance('AllOfficeShortName').Value__c;
                }
                
                //prepare the list of selectOptions
                OfficeSelectList = new list<SelectOption>();
                mapOffices = new map<Id, String>();
                for(Intranet_Item__c o : offices){
                    
                    //10/05/2017 - VH - make sure office is visible for user's entity
                    if(o.Office_Short_Name__c != allOfficesName && isVisibleForUserEntity(o.Entity__c, getUserSession.userEntity)){
                        OfficeSelectList.add(new SelectOption(o.Id, o.Office_Short_Name__c + ' Office'));
                        mapOffices.put(o.Id, o.Office_Short_Name__c);
                    }
                }
                
                //OfficeSelectList.sort();
            }
            return OfficeSelectList;
        }
        set;
    }
    public static string LookupOfficeNameById(Id officeId) {
        if(OfficeSelectList.size() > 0  && mapOffices != null && officeId != null) {
            return mapOffices.get(officeId);
        }

        return 'DC';
    }
    
    public static void DebugContainer(String prefix, IntranetContainer container) {
        system.debug(prefix + container.ToString(''));
    }
    public static void DebugContainers(String prefix, List<IntranetContainer> containers) {
        String printOut = '';
        for(IntranetContainer container : containers) {
            printOut = printOut + container.ToString('') + '<br>';
        }
    }
    
    /**
     *  @description    :   This method is to get the appropriate custom setting intranet defaults record 
     *
     *  @args           :   Category Name, Trend Source
     *
     *  @return         :   List of Intranet Defaults           
     *
     **/
    public static List<Intranet_Defaults__c> getIntranetDefaultByCategoryAndSource(String categoryName, String sourceName) {
        
        //Trending Container Id
        List<Intranet_Defaults__c> defaults = new List<Intranet_Defaults__c>();
        if(String.isNotBlank(categoryName) && String.isNotBlank(sourceName))
            defaults = [Select Intranet_Container__c, Item_RecordTypeId__c, Active_Status__c, Approval_Status__c, Item_Type__c, Link_Action__c, Link_Type__c, Schedule_recordTypeId__c from Intranet_Defaults__c where Category__c =: categoryName AND Create_Source__c =: sourceName AND Intranet_Container__c != null limit 1];
        return defaults;
    }

    public static Id GetImagesetImage(Boolean forManager) {
        Id imageItemId;
        if(forManager) {
            imageItemId = IntranetHomeUtility.LookupIntranetSetting(IntranetHomeUtility.TALENTIMAGESET_MANAGER);
        } else {
            imageItemId = IntranetHomeUtility.LookupIntranetSetting(IntranetHomeUtility.TALENTIMAGESET_NONMANAGER);
        }
        Intranet_Item__c imageset = [SELECT Image_for_Main_Content__c FROM Intranet_Item__c WHERE ID = :imageItemId];
        
        return imageset != null? imageset.Image_for_Main_Content__c : null;
    }
    
    /**
     *  @description    :   This method returns whether or not the item should be visible based on itemEntity & userEntity
     *
     *  @args           :   Intranet Item Entity, User Entity
     *
     *  @return         :   boolean         
     *
     **/
    public static boolean isVisibleForUserEntity(string itemEntity, string userEntity) {
        return (itemEntity == 'All'
                ||
        		( itemEntity == 'HC' && userEntity == 'HC' )
        		||
        		( 
        			( itemEntity == 'EAB' || itemEntity == 'Royall' )
        			&& 
        			( userEntity == 'EAB' || userEntity == 'Royall' )
        		));
    }
    
      /**
     *  @description    :   This method returns list of boardroom color codes metadata
     *
     *  @args           :   
     *
     *  @return         :    Map<String, String>
     * 						Created by Rajeev Jain CR-20180919-12608      
     *
     **/
    public static Map<String, String> boardRoomColorCode {
        get{
            Map<String, String> boradRoomColor = new Map<String, String> ();
            
            if(boardRoomColorCode == null){
                
                List<BoardRoom_Color_Code__mdt> codeColorData = [Select Instructor_Name__c,HTML_Color_Code__c,Color__c 
                                                                 From BoardRoom_Color_Code__mdt ];
                
                if(codeColorData.size() > 0){
                   
                    for(BoardRoom_Color_Code__mdt bcc : codeColorData){
						
                        if(!boradRoomColor.containsKey(bcc.Instructor_Name__c))                        
                            boradRoomColor.put(bcc.Instructor_Name__c, bcc.Color__c);
                    }   
                }
            }
            
           return boradRoomColor;
        }
        
        set;
    } 
}