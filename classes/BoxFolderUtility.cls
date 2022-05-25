/**
*   Description     :   This class is having all the logics to create and share the files. 
*
*   Created by      :   Abhinav Sharma
*
*   Created Date    :   04/03/2020
*
*   Revision Log    :   V1.0 - Created - Abhinav Sharma - CR-20200325-13887  
*/
public class BoxFolderUtility {
    
    //This method returns the sharable link of folders. 
    public Static String fetchSharableURL(BoxPlatformApiConnection api, String folderId) {
        
        String sharingURL = '';
        
       
        
        BoxFolder folder = new BoxFolder(api, folderId);
        BoxSharedLink.Permissions permissions = new BoxSharedLink.Permissions();
        BoxSharedLink.Info linkInfo = folder.createSharedLink(BoxSharedLink.Access.COMPANY, null, permissions);
       	sharingURL = linkInfo.url;
        
        return sharingURL;
    }
	
    //This method returns the sharable link of folders. 
    public Static String parseFolderCreationReponse(BoxFolder.Info childFolderInfo) {
        
        String folderId = '';
        
        //This error occurs when same name folder already exists
        if(childFolderInfo.children.get('status') == '409') {
            
            if(childFolderInfo.children.get('context_info') != null) {
                ResponseWrapper wrap = (ResponseWrapper) JSON.deserialize(childFolderInfo.children.get('context_info'), ResponseWrapper.class);
                folderId =  (wrap.conflicts != null && wrap.conflicts.size() > 0) ?  wrap.conflicts[0].id : '';
            }
        }else {
            folderId = childFolderInfo.Id;
            System.debug('FolderId -- '+ childFolderInfo.Id);
        }
        
        
        return folderId;
    }
    
    public Class ResponseWrapper {
        public List<Conflicts> conflicts {get;set;} 
    }
    
    public Class Conflicts {
        public String type_Z {get;set;} // in json: type
		public String id {get;set;} 
		public String sequence_id {get;set;} 
		public String etag {get;set;} 
		public String name {get;set;} 
    }

}