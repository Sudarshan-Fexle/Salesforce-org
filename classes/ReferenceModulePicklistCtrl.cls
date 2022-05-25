/**
 *  Description     :  Controller class for the ReferenceModulePicklist component
 *
 *  Revision Logs   :   v1.0 - 12/10/2015 - Created - Victor Hanson - Reference Tracking project (CR-20150826-9191)
 **/
public class ReferenceModulePicklistCtrl {
    
    public string rtName;
	public string getrtName(){ return rtName; }
    public void setRTName(String s){
        if (rtName == null) {
            rtName = s;
            ReferenceModulePicklistCtrl();
        }
	}
    public map<string, set<string>> referenceModuleMap = new map<string, set<string>>();
    
    public ReferenceModulePicklistCtrl() { }
	
    public void ReferenceModulePicklistCtrl() {
        //get the reference module map of values
        ReferenceModuleHelper moduleHelper = new ReferenceModuleHelper(rtName);
        referenceModuleMap = moduleHelper.referenceModuleMap;
    }
    
    /**
     * @description: convert map to json for easy processing on the page
     **/
    public string referenceModuleMap_JSON {
        get {
            if (referenceModuleMap_JSON == null) {
                referenceModuleMap_JSON = JSON.serialize(referenceModuleMap);
            }
            return referenceModuleMap_JSON;
        }
        set;
    }
}