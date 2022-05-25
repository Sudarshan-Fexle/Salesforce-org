/**
 *	Purpose			:	Controller class for MemberTravelCompSite_Json VF page.
 *
 *	Create By		:	Mahendra Swarnkar - 08/14/2017 - CR-20170509-10928
 *	
 *	Revision Log		:	V1.0 -  Created By - Mahendra Swarnkar - 08/14/2017 - CR-20170509-10928
 *					V1.1 - Modified By - Victor Hanson - 01/18/2018 - CR-20180118-11892
 *					V1.2 - Modified By - Abhinav sharma - 03/21/2018 - CR-20170915-11367- Additional check in the Query of Approvaed status while filling the registrationList.
 *					V1.3 - Modified By - Rajeev Jain - 11/14/2018 - CR-20181113-12745 - Changed the Endpoint from Hard coded to Custom Label. Method- webServiceCallOutForTravelComp
 *					V1.4 - Modified By - Chirag Soni - 07/28/2021 - CR-20210511-15133 - Changes performed from Meeting Utilization to Registration -  Button moved to Registration
 *					V1.5 - Modified By - Chirag Soni - 10/27/2021 - CR-20210511-15133 - Created a new lwc and Aura component for lightning Action button
**/
public class MemberTravelCompSiteController {
    /*
    //Properties
    public string JSONResponse { get; set;}
    //Commented By - Chirag Soni - 07/28/2021 - CR-20210511-15133 - Changes performed from Meeting Utilization to Registration
    //public List<Meeting_Utilization__c> mUlist {get; set;}
    //Added By - Chirag Soni - 07/28/2021 - CR-20210511-15133 - Changes performed from Meeting Utilization to Registration
    public List<Registration__c> registrationList {get; set;}
    public Id recordID { get; set;}
    
    //Added By Abhinav - CR-20170915-11367 - 03/21/2018
    public boolean isError {get; set;}
    public boolean isSuccess {get; set;}

    //Constructor
    public MemberTravelCompSiteController() {
        
        JSONResponse = '';
        isError = false;
        isSuccess = false;
        recordID = ApexPages.currentPage().getParameters().get('id');
        
        if(recordID != null){*/
         
	    //Query on the Meeting Utilization object
            //Commented By - Chirag Soni - 07/28/2021 - CR-20210511-15133 - Changes performed from Meeting Utilization to Registration
            /*muList = [Select Id, Travel_Assistance_Request__c, Main_Contact_and_or_Decision_Maker__c, Is_There_a_Meeting_Scheduled_With_Guest__c, 
                        What_Travel_is_Being_Offered__c, Maximum_Hotel_Nights__c, Must_Arrive_at_Meeting_Location_By__c, Department_Authorization_Contact__c,
                        Must_Depart_No_Earlier_Than__c, Upsert_ID__c, Requester_Name__r.Name, Department_Authorization__r.Name, Requester_Name_Contact__c
                        From Meeting_Utilization__c 
                        where Id =: recordID AND Approval_Status__c	= 'Approved'];*/
	    /*
            //Query on the Registration object
            registrationList = [Select Id, Travel_Assistance_Request__c, Main_Contact_and_or_Decision_Maker__c, Is_There_a_Meeting_Scheduled_With_Guest__c, 
                                What_Travel_is_Being_Offered__c, Maximum_Hotel_Nights__c, Must_Arrive_at_Meeting_Location_By__c, Department_Authorization_Contact__c,
                                Must_Depart_No_Earlier_Than__c, Requester_Name__r.Name, Department_Authorization__r.Name, Requester_Name_Contact__c
                                From Registration__c 
                                where Id =: recordID AND Travel_Compensation_Approval_Status__c	= 'Approved'];
            
            //Check for the Size
            if(registrationList.size() > 0) {
               	//Method calling
                generateJson();
                
                //Setting the flag as true 
                isSuccess = true;
            }
               
            else
                //Setting the flag as false 
                isError = true;
		}
    }*/
    /*
    //Method for generate json
    public void generateJson() {
        
        JSONResponse = '';
        
        //If list size to check 
        if(registrationList.size() > 0) {
           
			//String variable  
			JSONResponse = JSON.serialize(registrationList);
              
            
			blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(JSON.serialize(JSONResponse)));
          	
            JSONResponse = EncodingUtil.base64Encode(encryptedBlob);
            webServiceCallOutForTravelComp(JSONResponse); 
        }
    }
    */ 
    /**
     * 
     * @description: Method for webservice call out
     * 
     * @revision log: Modified - Victor Hanson - 01/18/2018 - CR-20180118-11892 - added reference to MemberTravelCompSite_SOAPWrapper
     *                         - Rajeev Jain - 11/14/2018 - CR-20181113-12745 - Changed the Endpoint from Hard coded to Custom Label.
     **/
    /*
    public void webServiceCallOutForTravelComp(String JSONResponse){
        
        //New http request
        HttpRequest req = new HttpRequest(); 

        //Set HTTPRequest header properties
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        req.setHeader('SOAPAction', 'http://travelcompemails.advisory.com/SFListener/SendEmails');
        req.setEndpoint(Label.Travel_Comp_Endpoint);
        req.setTimeout(120000);
        
        //Set the HTTPRequest body
        String payloadString = String.format(Label.MemberTravelCompSite_SOAPWrapper, 
                                             new List<String>{ JSONResponse });
        req.setBody(payloadString);
        
        Http http = new Http();
        try {
        
            //Execute web service call here		
            HTTPResponse res = http.send(req);
            
            //parse the response to return errors if necessary
            parseResponse(res);
        
            //Helpful debug messages
            if(res.getStatusCode() != 200){
                throw new CustomException('@@@STATUS: ' + res.getStatus() + ' @@@STATUS_CODE: '+res.getStatusCode() + ' @@@Response:: ' +res.toString()+ ' @@@Response body:: ' +res.getBody() ); 
            }
            else{
                System.debug('@@@@200STATUS: ' + res.getStatus() + ' STATUS_CODE: '+res.getStatusCode() + ' Response:: ' +res.toString() + ' ### Response body::: ' +res.getBody() );
            }
        } catch(Exception e) {
            System.debug('Message Exception : ' + e.getMessage());
        }
    }*/
    
    /**
     * 
     * @description: parses the response and determines what to display to the user
     * 
     * @revision log: Created - Victor Hanson - 01/18/2018 - CR-20180118-11892 - added because if there is an error on the server side, it still returns StatusCode=200 but includes error msg
     * 
     **/
    /*
    @TestVisible private static void parseResponse(HTTPResponse res) {
        
        boolean success = false;
        string errorMessage = '';
        
        // Generate the HTTP response as an XML stream
        XmlStreamReader reader = res.getXmlStreamReader();
        
        // Read through the XML
        while(reader.hasNext()) {
            
            if (reader.getLocalName() != null && reader.getEventType() == XmlTag.START_ELEMENT) {
                
                string evtType = string.valueOf(reader.getLocalName());
                
                if (evtType.equalsIgnoreCase('SUCCESS') && reader.hasNext()) {
                    reader.next();
                    if (reader.getEventType() == XmlTag.CHARACTERS) {
                        if (reader.getText().equalsIgnoreCase('TRUE')) success = true;
                    }
                }
                
                else if (evtType.equalsIgnoreCase('ERROR')) {
                    reader.next();
                    if (reader.getEventType() == XmlTag.CHARACTERS) errorMessage += reader.getText() + ' ';
                }
                
                else if (evtType.equalsIgnoreCase('MESSAGE') && reader.hasNext()) {
                    reader.next();
                    if (reader.getEventType() == XmlTag.CHARACTERS) errorMessage += reader.getText() + ' ';
                }
            }
            
            reader.next();
        }
        
        if (!success) {
            throw new customException(errorMessage);
        }
    }*/
}