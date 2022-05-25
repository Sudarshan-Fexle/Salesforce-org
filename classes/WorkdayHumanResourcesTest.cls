@isTest
public class WorkdayHumanResourcesTest {
	@isTest
    static void coverGeneratedCodeTypes() {
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
		Test.setMock(WebServiceMock.class, new WorkdayHumanResourcesMockImpl());
		WorkdayHumanResources parentObject = new WorkdayHumanResources();
        new WorkdayHumanResources.Security();
        new WorkdayHumanResources.UsernameToken();
		new WorkdayHumanResources.External_Integration_ID_Reference_DataType();
		new WorkdayHumanResources.IDType();
		new WorkdayHumanResources.Organization_Add_UpdateType();
		new WorkdayHumanResources.Organization_DataType();
		new WorkdayHumanResources.Organization_ReferenceRootType();
		new WorkdayHumanResources.Organization_Subtype_Reference_DataType();
		new WorkdayHumanResources.Organization_Type_Reference_DataType();
		new WorkdayHumanResources.Organization_Visibility_Reference_DataType();
/*
  		new WorkdayHumanResources.Organization_ReferenceType();
		new WorkdayHumanResources.Processing_FaultType();
		new WorkdayHumanResources.Validation_ErrorType();
		new WorkdayHumanResources.Validation_FaultType();
*/
	}
    
    static void coverCodeForAdd_Update_Organization() {
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
		Test.setMock(WebServiceMock.class, new WorkdayHumanResourcesMockImpl());
        
		WorkdayHumanResources.Human_Resources stub = new WorkdayHumanResources.Human_Resources();
        stub.endpoint_x = 'Web Service Url';
        stub.Header = new WorkdayHumanResources.Security();
		stub.Header.usernameToken = new WorkdayHumanResources.UsernameToken();
		stub.Header.usernameToken.username = 'Web Service User Name';
		stub.Header.usernameToken.password = 'Web Service Password';
        
        WorkdayHumanResources.Organization_DataType cc = new WorkdayHumanResources.Organization_DataType();
        cc.Organization_Reference_ID = 'Code-Cost Center Name';
        cc.Organization_Name = 'Cost Center Name';
        cc.Availability_Date = date.today();
        cc.Include_Organization_Code_In_Name = TRUE;
        cc.Organization_Code = 'Code';
        cc.Organization_Type_Reference = new WorkdayHumanResources.Organization_Type_Reference_DataType();
        cc.Organization_Type_Reference.Organization_Type_Name = 'Cost Center';
        cc.Organization_Subtype_Reference = new WorkdayHumanResources.Organization_Subtype_Reference_DataType();
        cc.Organization_Subtype_Reference.Organization_Subtype_Name = 'Cost Center';
        cc.Organization_Visibility_Reference = new WorkdayHumanResources.Organization_Visibility_Reference_DataType();
        cc.Organization_Visibility_Reference.Organization_Visibility_Name = 'Everyone';
        
        WorkdayHumanResources.External_Integration_ID_Reference_DataType result = stub.Add_Update_Organization(cc);
        system.assertEquals('Cost Center Name', result.Descriptor);
	}
    
    @TestVisible
    public class WorkdayHumanResourcesMockImpl implements WebServiceMock {
        public void doInvoke(
                Object stub,
                Object request,
                Map<String, Object> response,
                String endpoint,
                String soapAction,
                String requestName,
                String responseNS,
                String responseName,
                String responseType) {
           /*
           System.debug(LoggingLevel.INFO, 'WorkdayHumanResourcesMockImpl.doInvoke() - ' +
                '\n request: ' + request +
                '\n response: ' + response +
                '\n endpoint: ' + endpoint +
                '\n soapAction: ' + soapAction +
                '\n requestName: ' + requestName +
                '\n responseNS: ' + responseNS +
                '\n responseName: ' + responseName +
                '\n responseType: ' + responseType);
    		*/
            if(request instanceOf WorkdayHumanResources.Organization_Add_UpdateType) {
                WorkdayHumanResources.Organization_Add_UpdateType input = (WorkdayHumanResources.Organization_Add_UpdateType) request;
                WorkdayHumanResources.External_Integration_ID_Reference_DataType IDReference =
                    new WorkdayHumanResources.External_Integration_ID_Reference_DataType();
                IDReference.ID = new WorkdayHumanResources.IDType();
                IDReference.Descriptor = input.Organization_Data.Organization_Name;
                WorkdayHumanResources.Organization_ReferenceRootType output = 
                    new WorkdayHumanResources.Organization_ReferenceRootType();
                output.Integration_ID_Reference = IDReference;
                response.put('response_x', output);
            }
        }
    }
}