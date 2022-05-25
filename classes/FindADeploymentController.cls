/** 
* Description   :   Controller Class for DeploymentWizardFindADeployment screen - OneClick Deployment
*
* Created By    :   Rajeev Jain(Simplyforce)
*
* Created Date  :   03/26/2018
*
* Version       :   V1.0 Created
*                   
**/ 
public class FindADeploymentController {
    
    //================ Find A Deployment Properties ======================================
    
    //Holding the Reference of the Deployment Track Object
    public Deployment_Track__c deploymentTrackRef{get;set;}
    
    //Deployment Track blank instance to utilize in Search Deployment and applying Filteres
    public Deployment_Track__c deploymentTrackForSearch{
        get{
        	
            if(deploymentTrackForSearch == null)
                deploymentTrackForSearch = new Deployment_Track__c();
			return deploymentTrackForSearch;
        }
        set;
    }
    
    //Hold the Reference of App Properties
    public DeploymentWizardBean appPropertiesRef{get;set;}
    
    //Standard Set Controller
    public Apexpages.Standardsetcontroller setCont{get;set;}
    
    //Map to Hold List of Deployment Track Object corrosponding to Key
    public Map<Integer,List<Deployment_Track__c>> mapDeploymentList = new Map<Integer,List<Deployment_Track__c>>();
    
    //User Selected Step
    public Integer userSelectedStep{get;set;}
    
    //Hold flag to Show is Result diplayed was default or filtered
    public Boolean isResultFiltered{get;set;}
    
    //Hold Selected Shipment Category either My Deployment or All Deployment
    public String selectedDeploymentCategory{get;set;}
    
    //Get the Select Recurrence type
    public List<SelectOption> deploymentCategories {
        get{
            
            //List of select option
            List<SelectOption> options = new List<SelectOption>(); 
            
            options.add(new SelectOption('My Deployment','My Deployment')); 
            options.add(new SelectOption('All Deployment','All Deployment')); 
            return options; 
        }
    }
    
    //property to hold Selected Status
    public String selectedProcessStatus{get;set;}
    
    public List<Deployment_Track__c> searchedDeploymentList{
        get{
            //Temp List
            List<Deployment_Track__c> tempList = new List<Deployment_Track__c>();
            
            ///Loop get current Selected page records
            if(mapDeploymentList.containsKey(userSelectedStep)){
                tempList = mapDeploymentList.get(userSelectedStep);
                
            }
            
            return tempList;
        }
    }
    
    //Class Constructor
    public FindADeploymentController(){
        defaultSearch(); 
    }
    
    /**
*  @description    :   Method for default Search
* 			
*  @args           :   
* 
*  @return         :   void
* 
**/
    private void defaultSearch(){
        
        //Default Values
        userSelectedStep = 1;
        selectedDeploymentCategory = 'My Deployment';
        isResultFiltered = false;
        
        //Default Search 
        List<Deployment_Track__c> searchedResult = DeploymentHelper.searchDefaultDeployments(DeploymentHelper.DEFAULT_PAGE_SIZE);
        
        //Temp List to Hold Instances of Shipment object
        List<Deployment_Track__c> tempDeploymentList = new List<Deployment_Track__c>();
        
        Integer counter = 1;
        mapDeploymentList = new Map<Integer,List<Deployment_Track__c>>();
        
        //Check that there is record or not
        if(searchedResult != null && searchedResult.size() > 0) {
            //Loop over searched Result
            for(Integer i=0;i<searchedResult.size();i++){
                
                tempDeploymentList.add(searchedResult[i]);
                
                if(tempDeploymentList.size() == DeploymentHelper.DEFAULT_PAGE_SIZE){
                    
                    mapDeploymentList.put(counter,tempDeploymentList);
                    tempDeploymentList = new List<Deployment_Track__c>();
                    counter++;
                }
            }
        }
        if(tempDeploymentList.size()>0){
            mapDeploymentList.put(counter,tempDeploymentList);   
        }
    }
    
    /**
*  @description    :   Method to Search All Deployment Records Using Search Deployment data and fill the Deployment List
* 			
*  @args           :   
* 
*  @return         :   void
* 
**/
    public void searchDeployments(){
        
        try{
            
            //Call Helper Class method and Serch the Shipment Records(Filter Search) 
            List<Deployment_Track__c> searchedReuslts = DeploymentHelper.searchFilteredDeployments(deploymentTrackForSearch, selectedDeploymentCategory);
            
            //Temp List to Hold Instances of Shipment object
            List<Deployment_Track__c> tempDeploymentList = new List<Deployment_Track__c>();
            
            //Reset User Selected Step
            userSelectedStep = 1;
            
            //Initialize
            Integer counter = 1;
            mapDeploymentList = new Map<Integer,List<Deployment_Track__c>>();
            
            //Check that there is record or not
            if(searchedReuslts != null && searchedReuslts.size() > 0) {
                //Loop over searched Result
                for(Integer i=0;i<searchedReuslts.size();i++){
                    
                    tempDeploymentList.add(searchedReuslts[i]);
                    
                    if(tempDeploymentList.size() == DeploymentHelper.DEFAULT_PAGE_SIZE){
                        
                        mapDeploymentList.put(counter,tempDeploymentList);
                        tempDeploymentList = new List<Deployment_Track__c>();
                        counter++;
                    }
                }
            }
            
            if(tempDeploymentList.size()>0){
                mapDeploymentList.put(counter,tempDeploymentList);   
            }
            
            //Set flag to true
            isResultFiltered = true;
            
            
        }catch(Exception e){
            DeploymentHelper.displayErrorMessages(e.getMessage());
        }
    }
    
    /**
*  @description    :   Method to Clear Search Results and Set to Defual State
* 			
*  @args           :   
* 
*  @return         :   void
* 
**/
    public void clearSearch(){
        
        defaultSearch();
    }
    
    /**
*  @description    :   Method to return whether previous page exists
* 			
*  @args           :   
* 
*  @return         :   Boolean flag
* 
**/
    public Boolean hasPrevious{
        get{
            //Get List from map and if size is greater then zero means its have previous
            List<Deployment_Track__c> tempList = mapDeploymentList.get(userSelectedStep-1);
            if( tempList != null && tempList.size() >0)
                return true;
            return false;
        }
    }
    
    /**
*  @description    :   Method to return whether next page exists
* 			
*  @args           :   
* 
*  @return         :   Boolean flag
* 
**/
    public Boolean hasNext{
        get{
            //Get List from map and if size is greater then zero means its have previous
            List<Deployment_Track__c> tempList = mapDeploymentList.get(userSelectedStep+1);
            if( tempList != null && tempList.size() >0)
                return true;
            return false;
        }
    }
    
    public void next(){
        
        userSelectedStep += 1; 
    }
    public void previous(){
        userSelectedStep -= 1;
    } 
    
    /**
*  @description    :   Method to get Page Number
* 			
*  @args           :   
* 
*  @return         :   void
* 
**/	
    public Integer pageNumber{
        get{
            return userSelectedStep;
        }
    }
    
    /* List To hold Total Paging Numbers */ 
    public List<Integer> pagingNumbers{
        get{
            List<Integer> numbers = new List<Integer>();
            for(Integer i=1;i<=mapDeploymentList.size();i++){
                numbers.add(i);
            }
            return numbers;       
        }
    }
    
    public void setSelectedStep(){
        userSelectedStep = userSelectedStep;
    }
}