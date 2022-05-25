/**
 *  Desription      :   Wrapper Class for CommonAuth SyncContact Response
 *
 *  Created By      :   Jeffery Sun
 *  Created Date    :   02/22/2014
 *  Revision Logs   :   V1.0 - Created
 **/
public with sharing class CommonAuthSyncContactResponse {
    public Boolean Successful  { get; set; }
    public String ErrorMessage { get; set; }
    public SFContactDetail ContactDetail { get; set; }
    
    public CommonAuthSyncContactResponse() {
        ContactDetail = new SFContactDetail();
    }
    
    public string toJSON() {
        return JSON.serialize(this);
    }
    
    public class SFContactDetail {
    	public String SFContactId  { get; set; }
        public String CounterId  { get; set; }
        public String SFAccountId  { get; set; }
    }
}