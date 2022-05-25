/**
 * Description		:	This class used to create acquia json
 * 						Logic: https://quip.com/mVgUANJsjJCU/Acquia-Automate-creation-of-segments-CR-20210128-14855
 * 
 * Created Date		:	03/17/2021
 * 
 * Revision Log		:	V1.0 - Created - Saurabh Kumar - 03/17/2021 - CR-20210128-14855
 * 
 * */
public class AcquiaSegment {
	
    /**
     * 	Description		:	Method to generate json for Acquia Segment
     * 
     *  @args			:	String name, String filter
     * 
     *  @return			:	String
     * 
     *  @revision log		:	V1.0 - Created - Saurabh Kumar - 03/18/2021 - CR-20210114-14812
     * 					V1.1 - Modified segmentRequest as it contained incorrect parameters - Lawrence Lam - 06/28/2021 - CR-20210606-15193
     * */
    public static String newSegmentRequestJsonGenerator(String name, String filter){
        
        String requestJson = '{'
                               +'"name": "'+name+'",'
                               +' "isPublished": true,'
                                /* - commented out as it causes the callout to fail - LL 6/28/2021
            					+'"filters": ['
                                 +   '{'
                                 +      '"glue": "and",'
                                 +       '"field": "cmf_23",'
                                 +      '"object": "custom_object",'
                                 +       '"type": "int",'
                                 +       '"operator": "=",'
                                 +       '"properties": {'
                                 +           '"filter": "'+filter+'"' 
                                 +       '}'
                                 +   '}'
                                 +'],'
				 */
                                +'"isGlobal": true,'
                                +'"isPreferenceCenter": false'
                            +'}';
        return requestJson;
    }
    
    /**
     * 	Description		:	Method to generate json for Acquia Campaign
     * 
     *  @args			:	String name, Boolean isPublished, String acquiaSegmentId
     * 
     *  @return			:	String
     * 
     *  @revision log	        :	V1.0 - Created - Saurabh Kumar - 03/18/2021 - CR-20210128-14855
     * */
    public static String acquiaCampaignRequestJsonGenerator(String name, Boolean isPublished, String acquiaSegmentId){
        
        String requestJson = '{'
                				+'"isPublished": '+isPublished+','
                				+'"id":' +acquiaSegmentId+','
                				+'"name": "'+name+'",' 
                				+'"lists": ['
                    			+'{'
                        		+'"id":'+acquiaSegmentId
                    			+'}'
                				+']'
            				+'}';
        return requestJson;
    }
}