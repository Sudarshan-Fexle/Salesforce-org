global class ContactEmailHandler implements Messaging.InboundEmailHandler {
	  global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		  /*Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
		  // kick off batch job
		  database.executeBatch(new Batch_UpdateContactFromQueue(), 1);
			*/
          return null;
      }
  }