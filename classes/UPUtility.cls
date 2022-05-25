/*
    Purpose     :   utility class for UltimateParentController class
    
    Create By   :   Rajeev Jain - 06/16/2016 - SFDC schema Release - Manual Code Migration from Royall Enviournment
     
    Revision Log:   v1.0 - (Rajeev) Created Code
*/
public with sharing class UPUtility 
{
    public static List<set<Id>> generateHierarchy(String strParentId, integer maxListSize, integer maxLevels)
    {
        Map<Id, Account> mapChildren;
        List<Set<Id>> lstSetIds = new List<Set<Id>>();
        Set<Id> setParentIds, setLessChilds, setAllChilds; 
        setParentIds = setAllChilds = new Set<Id>{ strParentId };  
        setLessChilds =  new Set<Id>{ strParentId };           
        do
        {
            // Creating the map for all Childs
            mapChildren = new Map<Id, Account>([Select Id, Name, ParentId from Account where ParentId IN : setParentIds order by Parent.Name ASC]);                
            setAllChilds.addAll(mapChildren.keyset()); 
            if(setLessChilds.size() < maxListSize)  
            {
                if(setLessChilds.size() + mapChildren.keyset().size() < maxListSize)
                    setLessChilds.addAll(mapChildren.keyset());
                else
                {
                    for(Id parentId : mapChildren.keyset())
                    {
                        if(setLessChilds.size() < maxListSize)
                            setLessChilds.add(parentId);
                        else
                        {
                            break;
                        }
                    }
                }   
            }                           
            if(Limits.getQueries() == maxLevels) break;  
            
            // Children would become parents
            setParentIds = mapChildren.keyset();  
                                   
        } while(!mapChildren.values().isEmpty());
        lstSetIds.add(setLessChilds);
        lstSetIds.add(setAllChilds);
        return lstSetIds;
    }
    /*@isTest
    private static void testUPUtility()
    {   
        List<Account> lstAcc = new List<Account>();
        List<Account> lstAcc1 = new List<Account>(); 
        Account a = new Account(Name = 'test Account 999');
        insert a;
        UPUtility.generateHierarchy(a.Id, 2, 3);
        Account a1 = new Account(Name = 'test Account 111', parentId = a.Id);
        lstAcc.add(a1);
        Account a2 = new Account(Name = 'test Account 222', parentId = a.Id);
        lstAcc.add(a2);
        insert lstAcc;
        system.assertEquals(a.Id,a1.ParentId);
        UPUtility.generateHierarchy(a.Id, 2, 3);
    }*/

}