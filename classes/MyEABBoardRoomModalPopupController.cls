/**
*   Description     :   Controller class of MyEABBoardRoomModalPopup component to show the Popup for the specific container/Scheduler Ids or page, 
*                       and redirect the user to new bordroom portal
*
*   Created By      :   Mahendar Swarnkar
*
*   Created Date    :   10/05/2021
*
*   Revision Logs   :   V_1.0 - Created By - Mahendar Swarnkar - CR-20210921-15452
*
**/
public without sharing class MyEABBoardRoomModalPopupController 
{
    public String myEABBoardRoomModalcurrentvfpage 
    {
        get;
        set 
        {
            myEABBoardRoomModalcurrentvfpage = value;	    
        }
    }                                  
    public String myEABBoardRoomRedirectLink {set;get;}
    
    public Boolean showPopUp 
    { 
        set; 
        get
        {
            init();
            return showPopUp;
        }
    }
    
    public List<My_EAB_BoardRoom_Mapping__mdt> listOfMetadataRecords 
    {
        set;
        get
        {
            if(listOfMetadataRecords == null)
            {
                listOfMetadataRecords = [SELECT ID, Active__c, Identifier__c, Redirect_URL__c, Category__c 
                                FROM My_EAB_BoardRoom_Mapping__mdt 
                                WHERE Active__c = true];
            }
            return listOfMetadataRecords;
        } 
    }
    
    public void init() 
    {    
        String myBoardRoomURL = ApexPages.currentPage().getURL();
        if(String.isNotBlank(myBoardRoomURL) && listOfMetadataRecords.size() > 0)
        {
            for(My_EAB_BoardRoom_Mapping__mdt mappingRecord : listOfMetadataRecords)
            {
                if(myBoardRoomURL.trim().containsIgnoreCase(mappingRecord.Identifier__c)) 
                {
                    showPopUp = true;
                    myEABBoardRoomRedirectLink = mappingRecord.Redirect_URL__c;
                }
            }
        }
    }
}