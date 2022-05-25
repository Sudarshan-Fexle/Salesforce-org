/**
 *  Desription      :   Base Wrapper Class for CommonAuth Request
 *
 *  Created By      :   Jeffery Sun
 *  Created Date    :   02/22/2014
 *  Revision Logs   :   V1.0 - Created
 **/
public virtual class CommonAuthBaseRequest {
    public String Command { get; set; }
    
    public Static CommonAuthBaseRequest fromJSON(String jsonString) {
        // Escape all single quotes
        jsonString = jsonString.replace('\'','\\\'');
        return (CommonAuthBaseRequest)JSON.deserialize(jsonString, CommonAuthBaseRequest.class);
    }
}