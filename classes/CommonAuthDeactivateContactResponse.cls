/**
 *  Desription      :   Wrapper Class for CommonAuth DeactivateContact Response
 *
 *  Created By      :   Jeffery Sun
 *  Created Date    :   02/22/2014
 *  Revision Logs   :   V1.0 - Created
 **/
public with sharing class CommonAuthDeactivateContactResponse{
    public Boolean Successful  { get; set; }
    public String ErrorMessage { get; set; }
    
    public string toJSON() {
        return JSON.serialize(this);
    }
}