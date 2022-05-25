/**
 *  Desription      :   Wrapper Class for CommonAuth DeactivateContact Request
 *
 *  Created By      :   Jeffery Sun
 *  Created Date    :   02/22/2014
 *  Revision Logs   :   V1.0 - Created
 **/
public with sharing class CommonAuthDeactivateContactRequest extends CommonAuthBaseRequest {
    public String CrimsonEmail { get; set; }
    
    public Static CommonAuthDeactivateContactRequest fromJSON(String jsonString) {
        // Escape all single quotes
        jsonString = jsonString.replace('\'','\\\'');
        return (CommonAuthDeactivateContactRequest)JSON.deserializeStrict(jsonString, CommonAuthDeactivateContactRequest.class);
    }
}