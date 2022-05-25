//Primary Page Controller
//New Name: IntranetMainPage
//Pass through values to IntranetContainerController

public class IntranetHomeController {
    
    public final static Id HOMEPAGEID = Label.IntranetMainPage;
    
    public Id IntranetMainPageId {get; set;}
    public IntranetContainer MainContainer {get; set;}
    
    
    public IntranetHomeController() {
        if(MainContainer == null){
            GetMainPageContainer();
        }
        
    }
    
    //Get the MainPageId & Search for Header & Footer Containers associated with that
    public void GetMainPageContainer() {
        IntranetMainPageId = HOMEPAGEID;
        List <Intranet_Container__c> IntranetContainerList = [SELECT Id, Name, Status__c,Header_Container__c, Footer_Container__c, Top_Parent_Container__c, Top_Parent_Container_Id__c 
                                                              FROM Intranet_Container__c 
                                                              WHERE Id = :IntranetMainPageId];
        
        MainContainer = new IntranetContainer(IntranetContainerList[0]);
        
    }
}