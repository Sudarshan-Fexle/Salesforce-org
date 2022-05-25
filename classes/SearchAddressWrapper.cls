/**
 *  Purpose         :	Wrapper class for Search Address callout results from Azure
 *
 *  Revision Logs   :	V_1.0 - 07/13/2020 - CR-20200706-14269 - Victor Hanson - Created
 * 
**/
public class SearchAddressWrapper {
    public list<results> results{get;set;}
    public summary summary{get;set;}
    public class viewport{
        public topLeftPoint topLeftPoint{get;set;}
        public btmRightPoint btmRightPoint{get;set;}
    }
    public class topLeftPoint{
        public Decimal lon{get;set;}
        public Decimal lat{get;set;}
    }
    public class summary{
        public Integer totalResults{get;set;}
        public Integer numResults{get;set;}
        public Integer queryTime{get;set;}
        public Integer offset{get;set;}
        public String queryType{get;set;}
        public Integer fuzzyLevel{get;set;}
        public String query{get;set;}
    }
    public class results{
        public address address{get;set;}
        public Decimal score{get;set;}
        public position position{get;set;}
        public String id{get;set;}
        public viewport viewport{get;set;}
        public String type{get;set;}
    }
    public class position{
        public Decimal lon{get;set;}
        public Decimal lat{get;set;}
    }
    public class btmRightPoint{
        public Decimal lat{get;set;}
        public Decimal lon{get;set;}
    }
    public class address{
        public String countryCode{get;set;}
        public String postalCode{get;set;}
        public String countrySubdivisionName{get;set;}
        public String country{get;set;}
        public String countrySubdivision{get;set;}
        public String countryCodeISO3{get;set;}
        public String countrySecondarySubdivision{get;set;}
        public String freeformAddress{get;set;}
        public String municipality{get;set;}
        public String localName{get;set;}
        public String streetName{get;set;}
    }
}