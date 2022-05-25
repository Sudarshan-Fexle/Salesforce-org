/**
 * 
 * 	Description		:	Convert DateTime to a given Timezone and Format
 * 
 * 	Revision Logs		:	v1.0 - 07/20/2020 - CR-20200708-14279 - Victor Hanson - Created
 * 					V1.1 - 07/29/2020 - CR-20200729-14380 - Victor Hanson - added timezone null check
 * 					V1.2 - 08/04/2020 - CR-20200804-14400 - Victor Hanson - updated to replace AM/PM with a.m./p.m.
 * 
 **/
public class FormattedDateTimeController {
    public DateTime date_time {
        get;
        set;
    } //property that reads the datetime value from component attribute tag
    public String defined_format {
        get;
        set;
    } //property that reads the string value from component attribute tag
    public String timezone {
        get;
        set;
    } //property that reads the string value from component attribute tag
    public String getFormattedDatetime() {
        if (date_time == null) {
            return '';
        } else {
            if (defined_format == null) defined_format = 'EEEE, MMMM d | h:mm a';
            if (defined_format != null) defined_format.replace(' a', ' [a]'); //add [] so we can find/replace am/pm easier
            if (timezone == null) timezone = 'America/New_York';
            
            return date_time.format(defined_format, timezone).replace('[AM]', 'a.m.').replace('[PM]', 'p.m.'); //Specify Time zone like America/New_York
        }
    }
}