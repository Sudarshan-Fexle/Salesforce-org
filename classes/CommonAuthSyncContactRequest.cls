/**
 *  Desription      :   Wrapper Class for CommonAuth SyncContact Request
 *
 *  Created By      :   Jeffery Sun
 *  Created Date    :   02/22/2014
 *  Revision Logs   :   V1.0 - Created
 **/
public with sharing class CommonAuthSyncContactRequest extends CommonAuthBaseRequest {
    public String CrimsonGuid { get; set; }
    public String CrimsonEmail { get; set; }
    public String FirstName { get; set; }
    public String LastName { get; set; }
    public List<String> ProjectIds { get; set; }
    
    public Static CommonAuthSyncContactRequest fromJSON(String jsonString) {
        // Escape all single quotes
        jsonString = jsonString.replace('\'','\\\'');
        CommonAuthSyncContactRequest request = (CommonAuthSyncContactRequest)JSON.deserializeStrict(jsonString, CommonAuthSyncContactRequest.class);
        
        // Trim ProjectIds
        List<String> pIds = new List<String>();
        for(String projectId : request.ProjectIds) pIds.add(projectId.trim());
        request.ProjectIds = pIds;
        
        return request;
    }
}