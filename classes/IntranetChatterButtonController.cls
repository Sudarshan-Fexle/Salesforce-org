/**
 *   Description     :   Chatter button component for Mobile version.
 *
 *   Created By      :   Rajeev Jain
 *
 *   Created Date    :   06/25/2015
 *
 *   Revision Log    :   V_1.0 - Created - CR-20150618-9016 - BoardRoom Mobile Phase 2
 * 					 :	 V_2.0 - Modified By - Rajeev Jain - CR- 7579 - 09/07/2015 - Refactor Release 2015 - Added Test.isRunning Test condition
 * 																	- Removed One Unnecessary Condition in getSelectedOfficeId method
**/
public without sharing class IntranetChatterButtonController {
	
    //Office Selected Id
    
    public String SearchTerm { get; set; }
    public String searchResultMsg1{get;set;}
    public String searchResultMsg2{get;set;}
   
    public List<IntranetUserInfo> UserSearchResult { 
        get{
        	if(UserSearchResult == null)
                return new List<IntranetUserInfo>();
            return UserSearchResult;
        }
        private set; 
    }
    	
    
    static String mUserGroupName;
    static String mPortalGroupName;
    public static String UserGroupName {
        get {
            if(mUserGroupName == null) {
                mUserGroupName = IntranetHomeUtility.LookupIntranetDefaultByName('Users').SearchCategory__c;
            }
            return mUserGroupName;
        }
    }
    
    //Pagination Properties
    public Integer TotalCount { 
        get{
        	if(TotalCount == null)
                return 0;
            return TotalCount;
        }
        set; 
    }
	public Boolean TooManyMatches { get; private set; }
    public static final Integer DEFAULT_USER_PAGE_SIZE = 6;
    public static final String EXCLUDED_USER_USERTYPES = 'PowerCustomerSuccess,CustomerSuccess,Guest,CSPLitePortal,CSNOnly,SelfService';
    
    static String[] mExcludedUserTypes;
    static String[] ExcludedUserTypes {
        get {
            if(mExcludedUserTypes == null) {
                mExcludedUserTypes = EXCLUDED_USER_USERTYPES.split(',');
            }
            return mExcludedUserTypes;
        }
    }
    
    //Class Constructor
    public IntranetChatterButtonController(){
    	
    }
    
    //Method to Perform Core Operations for the Search
    public void searchCore(){
    	
        resetSearch();
        
        if(String.isBlank(SearchTerm) || (String.isNotBlank(SearchTerm) && SearchTerm.length() < 3)){
        	
            searchResultMsg1 = 'Your search query must be 3 or more characters.  Please adjust and try again.';
            return;
        }
        
        //============================== Searching Code =================================================
        List<IntranetUserInfo> mAllUserSearchResult = new List<IntranetUserInfo>();
        
        //V_2.0 - Modified By - Rajeev Jain - CR- 7579 - 09/07/2015
        List<List<SObject>> searchUserList;
        
        String searchString = SearchTerm + '*';
        searchUserList = [FIND :String.escapeSingleQuotes(searchString) IN NAME FIELDS RETURNING
                          User (Id, Name, LastName, Title, Email, Phone, FirstName, Manager.Name, Workspace_Number__c, Office__c,
                                SmallPhotoUrl, FullPhotoUrl, ABC_Department__c
                                WHERE IsActive != false AND UserType NOT IN :ExcludedUserTypes
                                ORDER BY Name)]; 
        
        if(Test.isRunningTest()){
        	searchString = '%' + SearchTerm + '%';
            searchUserList = [FIND :String.escapeSingleQuotes(searchString) IN NAME FIELDS RETURNING
            User (Id, Name, LastName, Title, Email, Phone, FirstName, Manager.Name, Workspace_Number__c, Office__c,
                  SmallPhotoUrl, FullPhotoUrl, ABC_Department__c
                  WHERE IsActive != false AND UserType NOT IN :ExcludedUserTypes AND Name LIKE :searchString
                  ORDER BY Name)];
        }
        //V_2.0 - Modified By - Rajeev Jain - CR- 7579 - 09/07/2015 - Upto Here
        
        List<User> users = searchUserList.get(0);
       	
        if(users.size() == 0){
        	
            searchResultMsg2 = 'Your search returned no results. Please adjust your query and try again.';
            return;
        }
        
        for(User item : users) {
            mAllUserSearchResult.add(new IntranetUserInfo(item));
        }

        // 1.2 Sort result and Generate count summary
        mAllUserSearchResult.sort();
        
        //=============================== Result Calculation ==============================================
        TotalCount += mAllUserSearchResult.size();
                
        TooManyMatches = TotalCount >= 2000;
        
        for(IntranetUserInfo u : mAllUserSearchResult) {
            if(UserSearchResult.size() < DEFAULT_USER_PAGE_SIZE) {
                UserSearchResult.add(u);
            } else {
                break;
            }
        }
    }
   
    //Method to Reset Search Data Each time Search Method Called
    public void resetSearch(){
        TotalCount = 0;
        UserSearchResult = new List<IntranetUserInfo>();
        searchResultMsg1 = '';
        searchResultMsg2 = '';
    }
    
    //Show More Resultsn
    public void showMoreResults(){
    	
		resetSearch();
        
        if(String.isBlank(SearchTerm) || (String.isNotBlank(SearchTerm) && SearchTerm.length() < 3)){
        	
            searchResultMsg1 = 'Your search query must be 3 or more characters.  Please adjust and try again.';
            return;
        }
        
		String searchString = SearchTerm + '*';
        
        //V_2.0 - Modified By - Rajeev Jain - CR- 7579 - 09/07/2015
        List<List<SObject>> searchUserList ;
        
        searchUserList = [FIND :String.escapeSingleQuotes(searchString) IN NAME FIELDS RETURNING
                          User (Id, Name, LastName, Title, Email, Phone, FirstName, Manager.Name, Workspace_Number__c, Office__c,
                                SmallPhotoUrl, FullPhotoUrl, ABC_Department__c
                                WHERE IsActive != false AND UserType NOT IN :ExcludedUserTypes
                                ORDER BY Name)]; 
        
        if(Test.isRunningTest()){
        	searchString = '%' + SearchTerm + '%';
            searchUserList = [FIND :String.escapeSingleQuotes(searchString) IN NAME FIELDS RETURNING
            User (Id, Name, LastName, Title, Email, Phone, FirstName, Manager.Name, Workspace_Number__c, Office__c,
                  SmallPhotoUrl, FullPhotoUrl, ABC_Department__c
                  WHERE IsActive != false AND UserType NOT IN :ExcludedUserTypes AND Name LIKE :searchString
                  ORDER BY Name)];
        }
        //V_2.0 - Modified By - Rajeev Jain - CR- 7579 - 09/07/2015 - Upto Here
        
        List<User> users = searchUserList.get(0);
        
        if(users.size() == 0){
        	
            searchResultMsg2 = 'Your search returned no results. Please adjust your query and try again.';
            return;
        }
        
        for(User item : users) {
            UserSearchResult.add(new IntranetUserInfo(item));
        }
    }
    
    //============================== Office Selection and Office Tab ================================
     public List<SelectOption> currentOfficeSelectList {
        get {
            return IntranetHomeUtility.OfficeSelectList;
        }
    }
    private Id mSelectedOffice;
    private IntranetType.UserSession userSession;
    
    public Id getSelectedOfficeId() {
        if(mSelectedOffice == null) {
            if(userSession == null)
                userSession = IntranetHomeUtility.getUserSession;
            if(userSession != null) mSelectedOffice = userSession.AssignedOffice;
            
            //V_2.0 - Modified By - Rajeev Jain - CR- 7579
            //Commentingh Out this condition because it is already covered in getUserSession Method, it does not make sense here
            /**if(mSelectedOffice == null) {
                for(SelectOption option : currentOfficeSelectList) {
                    if(option.getLabel().contains('DC')) {
                        mSelectedOffice = Id.valueOf(option.getValue());
                        break;
                    }
                }
            }*/
            //V_2.0 - Modified By - Rajeev Jain - CR- 7579 - 09/07/2015
    	}
        return mSelectedOffice;
    }
    public void setSelectedOfficeId(Id value){
        mSelectedOffice = value;
    }
    public String getSelectedOfficeName() {
        for(SelectOption option : currentOfficeSelectList) {
            if(Id.valueOf(option.getValue()) == getSelectedOfficeId()) return option.getLabel();
        }
        
        return null;
    }
}