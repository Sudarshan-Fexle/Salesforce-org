/**
* Description   :   Class acting as jason parser for ApexCodeCoverage object json resonse
*
* Created By    :   Ishan Arora
*
* Created Date  :   16/03/2018
*
* Version       :   V1.0 Created
*             
**/ 
public class ApexCodeCoverageJsonParser {
    public Integer size;	//7359
    public Integer totalSize;	//7359
    public boolean done;
    public String nextRecordsUrl;	///services/data/v41.0/tooling/query/01g1D0000032SWPQA2-2000
    public String queryLocator;	//01g1D0000032SWPQA2-2000
    public String entityTypeName;	//ApexCodeCoverage
    public cls_records[] records;
    public class cls_records {
        public cls_attributes attributes;
        public cls_ApexClassOrTrigger ApexClassOrTrigger;
        public cls_ApexTestClass ApexTestClass;
    }
    public class cls_attributes {
        public String type;	//ApexClass
        public String url;	///services/data/v41.0/tooling/sobjects/ApexClass/01p1D000000MmtAQAS
    }
    public class cls_ApexClassOrTrigger {
        public cls_attributes attributes;
        public String Id;	//01p1D000000Mmt5QAC
        public String Name;	//ApexCodeCoverageJsonParser
    }
    public class cls_ApexTestClass {
        public cls_attributes attributes;
        public String Name;	//ApexCodeCoverageJsonParser_Test
    }
    public static ApexCodeCoverageJsonParser parse(String json){
        return (ApexCodeCoverageJsonParser) System.JSON.deserialize(json, ApexCodeCoverageJsonParser.class);
    }
    
}