/** Description		:	Mock test class to hold fake response for Portal search on Wordpress based system from IntranetSearch page
  * 
  * Created Date	:	09/07/2015
  *
  * Created By		:   Rajeev Jain(Simplyforce)
  *  
  * Current vision	:	v1.0
  *  
  * Revision Logs	:	v1.0 - Created - For - CR-20141002-7579 - To improve code coverage of IntranetItemTrigger Helper class class.
  **/
@isTest
global class VimeoMockCallOut implements HttpCalloutMock {
   
    /*XML response string for a vimeo video Callout to fetch its video image*/
    public static String responseVimeo = '<oembed>'
                                            +'<type>video</type>'
                                            +'<version>1.0</version>'
                                            +'<provider_name>Vimeo</provider_name>'
                                            +'<provider_url>https://vimeo.com/</provider_url>'
                                            +'<title>CABEZONES - 5 MIN</title>'
                                            +'<author_name>SLEF</author_name>'
                                            +'<author_url>https://vimeo.com/slef</author_url>'
                                            +'<is_plus>0</is_plus>'
                                            +'<width>1280</width>'
                                            +'<height>720</height>'
                                            +'<duration>303</duration>'
                                            +'<description/>'
                                            +'<thumbnail_url>https://i.vimeocdn.com/video/512806123_1280.webp</thumbnail_url>'
                                            +'<thumbnail_width>1280</thumbnail_width>'
                                            +'<thumbnail_height>720</thumbnail_height>'
                                            +'<video_id>123456789</video_id>'
                                            +'<uri>/videos/123456789</uri>'
                                        +'</oembed>';
                       
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
    
        // Create a fake response
        HttpResponse res = new HttpResponse();
        
        res.setHeader('Content-Type', 'text/xml');
        res.setBody(responseVimeo);
        res.setStatusCode(200);
        res.setStatus('OK');
        
        return res;
    }       
}