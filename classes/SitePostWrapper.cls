/**
 *   Purpose:    Wrapper class for deserializing JSON sent back from WordPress site
 *   
 *   Revision Log:      v1.00 - 05/16/2019 - Victor Hanson - Created
                        V1.1 - 03/23/2019 - Dipesh Gupta - Added a new variable webProgramAccessIds to the wrapper - CR-20190510-13102
**/
public class SitePostWrapper {
    public String id_x { get; set; }
    public String post_title{ get; set; }
    public String guid{ get; set; }
    public Set<String> webProgramAccessIds {get; set;}
    
    /*public TitleWrapper title { get; set; }
    public String title_string {
        get {
            if (title != null) {
                title_string = title.rendered;
            }
            return title_string;
        }
        set;
    }
    
    public class TitleWrapper {
        public String rendered { get; set; }
    }*/
}