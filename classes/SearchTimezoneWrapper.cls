/**
 *  Purpose         :	Wrapper class for Search Timezone callout results from Azure
 *
 *  Revision Logs   :	V_1.0 - 07/13/2020 - CR-20200706-14269 - Victor Hanson - Created
 * 
**/
public class SearchTimezoneWrapper {
    public String ReferenceUtcTimestamp{get;set;}
    public list<TimeZones> TimeZones{get;set;}
    public String Version{get;set;}
    public class TimeZones{
        public Names Names{get;set;}
        public ReferenceTime ReferenceTime{get;set;}
        public String Id{get;set;}
    }
    public class ReferenceTime{
        public String StandardOffset{get;set;}
        public String DaylightSavings{get;set;}
        public String Tag{get;set;}
        public String WallTime{get;set;}
        public String Sunrise{get;set;}
        public String PosixTz{get;set;}
        public String Sunset{get;set;}
        public Integer PosixTzValidYear{get;set;}
    }
    public class Names{
        public String Daylight{get;set;}
        public String Generic{get;set;}
        public String ISO6391LanguageCode{get;set;}
        public String Standard{get;set;}
    }
}