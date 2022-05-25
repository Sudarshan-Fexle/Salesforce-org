public abstract class IntranetBaseController {
    
    private String Preview;
    public String SchedId {get; private set;}
	public String PreviewContentId {get; protected set;}
    public String PreviewContainerId {get; protected set;}
    public String IntranetMainPageId {get; protected set;}
    
    public boolean IsPreview {
        get {
            return Preview != null && Preview.toLowerCase() == 'true' && SchedId != null;
        }
    }
    
    public void ProcessPreviewParameters() {
    	Map<String, String> params = ApexPages.currentPage().getParameters();
       	
        if(params.containsKey('Preview'))
            Preview = params.get('Preview');
        if(params.containsKey('SchedId'))
            SchedId = params.get('SchedId');
        if(params.containsKey('TopContainerId'))
            IntranetMainPageId = params.get('TopContainerId');
    }
    
	public IntranetBaseController () {
        ProcessPreviewParameters();
	}
    
    protected virtual void init(){}
}