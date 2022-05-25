public class WorkdayHumanResources {
    //soap headers need to be generated and inserted for authentication against WSSE web-services
    public class Security {
        public UsernameToken usernameToken;
        private String[] usernameToken_type_info = new String[]{'UsernameToken','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','UsernameToken','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
        private String[] field_order_type_info = new String[]{'usernameToken'};
	}
	public class UsernameToken {
		public String username;
		public String password;
		private String[] username_type_info = new String[]{'Username','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','string','0','1','true'};
		private String[] password_type_info = new String[]{'Password','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','string','1','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
		private String[] field_order_type_info = new String[]{'username','password'};
	}
    
    // Messages
    public class External_Integration_ID_Reference_DataType {
        public IDType ID;
        private String[] ID_type_info = new String[]{'ID','urn:com.workday/bsvc','IDType','1','1','false'};
        public String Descriptor;
        public String[] Descriptor_att_info = new String[]{'Descriptor'};
        private String[] apex_schema_type_info = new String[]{'urn:com.workday/bsvc','true','false'};
        private String[] field_order_type_info = new String[]{'ID'};
    }
    
    //Warning: Simple Content Types with Attributes are not supported by WebServiceCallout.invoke
    public class IDType {
        public String input;
        private String[] input_type_info = new String[]{'input','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        public String System_ID;
        public String[] System_ID_att_info = new String[]{'System_ID'};
        private String[] apex_schema_type_info = new String[]{'urn:com.workday/bsvc','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class Organization_Add_UpdateType {
        public Organization_DataType Organization_Data;
        private String[] Organization_Data_type_info = new String[]{'Organization_Data','urn:com.workday/bsvc','Organization_DataType','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:com.workday/bsvc','true','false'};
        private String[] field_order_type_info = new String[]{'Organization_Data'};
    }
    public class Organization_DataType {
        public String Organization_Reference_ID;
        public String Organization_Name;
        public Date Availability_Date;
        public Boolean Include_Organization_Code_In_Name;
        public String Organization_Code;
        public Organization_Type_Reference_DataType Organization_Type_Reference;
        public Organization_Subtype_Reference_DataType Organization_Subtype_Reference;
        public Organization_Visibility_Reference_DataType Organization_Visibility_Reference;
        private String[] Organization_Reference_ID_type_info = new String[]{'Organization_Reference_ID','urn:com.workday/bsvc','string','0','1','false'};
        private String[] Organization_Name_type_info = new String[]{'Organization_Name','urn:com.workday/bsvc','string','0','1','false'};
        private String[] Availability_Date_type_info = new String[]{'Availability_Date','urn:com.workday/bsvc','date','0','1','false'};
        private String[] Include_Organization_Code_In_Name_type_info = new String[]{'Include_Organization_Code_In_Name','urn:com.workday/bsvc','boolean','0','1','false'};
        private String[] Organization_Code_type_info = new String[]{'Organization_Code','urn:com.workday/bsvc','string','0','1','false'};
        private String[] Organization_Type_Reference_type_info = new String[]{'Organization_Type_Reference','urn:com.workday/bsvc','Organization_Type_Reference_DataType','0','1','false'};
        private String[] Organization_Subtype_Reference_type_info = new String[]{'Organization_Subtype_Reference','urn:com.workday/bsvc','Organization_Subtype_Reference_DataType','0','1','false'};
        private String[] Organization_Visibility_Reference_type_info = new String[]{'Organization_Visibility_Reference','urn:com.workday/bsvc','Organization_Visibility_Reference_DataType','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:com.workday/bsvc','true','false'};
        private String[] field_order_type_info = new String[]{'Organization_Reference_ID','Organization_Name','Availability_Date','Include_Organization_Code_In_Name','Organization_Code','Organization_Type_Reference','Organization_Subtype_Reference','Organization_Visibility_Reference'};
    }
    public class Organization_ReferenceRootType {
        public External_Integration_ID_Reference_DataType Integration_ID_Reference;
        private String[] Integration_ID_Reference_type_info = new String[]{'Integration_ID_Reference','urn:com.workday/bsvc','External_Integration_ID_Reference_DataType','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:com.workday/bsvc','true','false'};
        private String[] field_order_type_info = new String[]{'Integration_ID_Reference'};
    }
    public class Organization_Subtype_Reference_DataType {
        public String Organization_Subtype_Name;
        private String[] Organization_Subtype_Name_type_info = new String[]{'Organization_Subtype_Name','urn:com.workday/bsvc','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:com.workday/bsvc','true','false'};
        private String[] field_order_type_info = new String[]{'Organization_Subtype_Name'};
    }
    public class Organization_Type_Reference_DataType {
        public String Organization_Type_Name;
        private String[] Organization_Type_Name_type_info = new String[]{'Organization_Type_Name','urn:com.workday/bsvc','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:com.workday/bsvc','true','false'};
        private String[] field_order_type_info = new String[]{'Organization_Type_Name'};
    }
    public class Organization_Visibility_Reference_DataType {
        public String Organization_Visibility_Name;
        private String[] Organization_Visibility_Name_type_info = new String[]{'Organization_Visibility_Name','urn:com.workday/bsvc','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:com.workday/bsvc','true','false'};
        private String[] field_order_type_info = new String[]{'Organization_Visibility_Name'};
    }

    // Service Wrapper
    public class Human_Resources {
        public String endpoint_x;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
		//instantiate the header
		public Security Header;
		private String Header_hns = 'Security=http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd';
		//end
        private String[] ns_map_type_info = new String[]{'urn:com.workday/bsvc','WorkdayHumanResources'};
                        
        public External_Integration_ID_Reference_DataType Add_Update_Organization(Organization_DataType Organization_Data) {
            Organization_Add_UpdateType request_x = new Organization_Add_UpdateType();
            Organization_ReferenceRootType response_x;
            request_x.Organization_Data = Organization_Data;
            Map<String, Organization_ReferenceRootType> response_map_x = new Map<String, Organization_ReferenceRootType>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]
                {
                    endpoint_x,
                	'',
                	'urn:com.workday/bsvc',
                	'Organization_Add_Update',
                	'urn:com.workday/bsvc',
                	'Organization_Reference',
                	'WorkdayHumanResources.Organization_ReferenceRootType'
            	}
            );
            response_x = response_map_x.get('response_x');
            return response_x.Integration_ID_Reference;
        }
    }
}