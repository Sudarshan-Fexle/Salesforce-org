@istest
private class SFListener_Test {
    static testMethod void testConstructors() {
        SFListener.EventUpdateResult sfEventUpdateResult = new SFListener.EventUpdateResult();
        SFListener.ArrayOfEventUpdate sfArrayOfEventUpdate = new SFListener.ArrayOfEventUpdate();
        SFListener.DeleteAppointmentsResponse_element sfDeleteAppointmentsResponse_element = new SFListener.DeleteAppointmentsResponse_element();
        SFListener.AuthHeader authHeader = new SFListener.AuthHeader();
		
		authHeader.SystemName = 'Test';
		authHeader.UserName = 'test@test.com';
		authHeader.Password = 'sf#12345';
		
		SFListener.DeleteAppointments_element sfDeleteAppointments_element = new SFListener.DeleteAppointments_element();
        SFListener.ArrayOfEventUpdateResult sfArrayOfEventUpdateResult = new SFListener.ArrayOfEventUpdateResult();
        SFListener.EventUpdate sfEventUpdate = new SFListener.EventUpdate();
        SFListener.UpsertAppointments_element upsertAppointments_element = new SFListener.UpsertAppointments_element();
        SFListener.UpsertAppointmentsResponse_element sfUpsertAppointmentsResponse_element = new SFListener.UpsertAppointmentsResponse_element();
        SFListener.SFListenerSoap sfListenerSoap = new SFListener.SFListenerSoap();
		
	try {	
		sfListenerSoap.UpsertAppointments(sfArrayOfEventUpdate);
		
	} catch (Exception e) {
		
	}

	try {

	     sfListenerSoap.DeleteAppointments(sfArrayOfEventUpdate);
	}catch (Exception e) {

	}

    }
}