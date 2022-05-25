/**
 *  Description     :   Helper class for scope object trigger
 * 
 *  Created By      :   Abhinav Sharma  
 * 
 *  Created Date    :   11/26/2015
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20151022-9346 - Added new method - scopeDuplicatePreventer
 * 					:	V_1.1 - Modified By - Mahendra Swarnkar - 12/08/2015 - CR-20151022-9346 - Added new method - deleteScopeMTMWithScope            
**/ 
public class ScopeHelper {
	
    //Added By - Abhinav Sharma - CR-20151022-9346 - 11/26/2015
    /**
     *  @description    :   This method will ensure the uniqueness for the name field of Scope Object. 
     * 						This means no two scope records can have the same name field value with them.   
     * 
     *  @args           :   List of scope, Map of Old scopes
     * 
     *  @return         :   void
     * 
    **/ 
    public static void scopeDuplicatePreventer(List<Scope__c> newScopes, Map<Id, Scope__c> mapOldScopes) {
        
        //Map of Scopes
        Map<String, Scope__c> mapOfScopes = new Map<String, Scope__c>();
        
        //Loop through scope records
		for (Scope__c sc : newScopes) {

            //Make sure we don't treat a name that isn't changing during an update as a duplicate.
			if((sc.Name != null) 
            	&& 
               	(
               		mapOldScopes == null 
                	||
                	(mapOldScopes != null && sc.Name != mapOldScopes.get(sc.Id).Name)
            	)
            ) {

				//Make sure another new scope isn't also a duplicate
				if(mapOfScopes.containsKey(sc.Name.trim().toLowerCase()))
					sc.Name.addError(System.Label.ERROR_ANOTHER_SCOPE_HAS_SAME_NAME);
				else
					mapOfScopes.put(sc.Name.trim().toLowerCase(), sc);
			}
		}
        
        //Checking for size value
        if(mapOfScopes.keySet().size() > 0) {
            
            //Using a single database query, find all the scopes in 
			//the database that have the same name as any 
			//of the scopes being inserted or updated. 
			for (Scope__c s : [SELECT Name FROM Scope__c WHERE Name != null AND Name IN : mapOfScopes.KeySet()]) {
				Scope__c newScope = mapOfScopes.get(s.Name.trim().toLowerCase());
                if(newScope != null)
					newScope.Name.addError(System.Label.ERROR_A_SCOPE_WITH_SAME_NAME_EXIST);
            }        
		}
    }
    
    //Added By - Mahendra Swarnkar - CR-20151022-9346 - 12/08/2015
    /**
     *  @description    :   This method will delete the related scopeMtM records, if parent scope record will be deleted    
     * 
     *  @args           :   Map of Old scopes
     * 
     *  @return         :   void
     * 
    **/ 
    public static void deleteScopeMTMWithScope(Map<Id, Scope__c> mapOldScopes) {
        
        //Checking map for null value and then for size value
        if(mapOldScopes != null && mapOldScopes.values().size() > 0) {
            
    		//Query to fetch the related scopeMtM records of scope record
        	List<Scope_MtM__c> scopeMtMToBeDeleted = [Select Id From Scope_MtM__c where Scope__c != null 
                                                  		AND Scope__c IN : mapOldScopes.keySet()];
        
            //Check for size
            if(scopeMtMToBeDeleted != null && scopeMtMToBeDeleted.size() > 0){
            
                //Delete related scope MtM records 
                delete scopeMtMToBeDeleted;
        	}        
        }
    }
}