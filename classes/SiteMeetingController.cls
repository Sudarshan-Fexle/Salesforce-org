/**
    Desription      :   This class is used to store the helper methods for site meeting functionality on eab.com.

    Revision Logs   :   v1.0 - Created
						v1.1 - 06/11/2019 - Modified - Victor Hanson - CR-20190611-13177 - updated to use eab.com Encryption & updated class name

 **/ 
public without sharing class SiteMeetingController {
	
	public static SiteMeeting originalSiteMeeting { get; set; }

	public String JSONResponse { get; set; }
	
	public SiteMeetingController() {
		
	}
	
	public void Initialize() {
		String request = ApexPages.currentPage().getParameters().get('req');
		SiteMeeting sMeeting = new SiteMeeting(request);

		//holds the original siteMeeting prior to processing (for logging purposes)
    	originalSiteMeeting = sMeeting.clone();

		//VH added 06/21/2019 - for upsertRegistration request, perform the action, then get User and send all user details (including registration) back
		if (sMeeting.mWrapper.Command != null && sMeeting.mWrapper.Command.equalsIgnoreCase('upsertRegistration')) {
			system.debug('@@JSON.serialize(sMeeting.sUser):' + JSON.serialize(sMeeting.sUser, true));
			// return the results
			JSONResponse = EncryptionHelper.encryptString(JSON.serialize(sMeeting, true));
			//log meeting requests
			SiteProfileLogger.log(originalSiteMeeting, sMeeting, sMeeting.sUser);
		}
		else {
			//else, just send the siteMeeting wrapper back
			system.debug('@@JSON.serialize sMeeting:' + JSON.serialize(sMeeting, true));
			// return the results
			JSONResponse = EncryptionHelper.encryptString(JSON.serialize(sMeeting, true));

			//log meeting requests
			SiteProfileLogger.log(originalSiteMeeting, sMeeting);
		}
	}
	
}