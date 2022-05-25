public class DateTimeFormatController {
    private DateTime mValue;
    public void setThisValue(DateTime s) {
        mValue = s;
    }
    public DateTime getThisValue() {
        return mValue;
    }
    
    private String mFormatString;
    public void setThisFormatString(String s) {
        mFormatString = s;
    }
    public String getThisFormatString() {
        return mFormatString;
    }
    
    private String mTimezone;
    public void setThisTimezone(String s) {
        mTimezone = s;
    }
    public String getThisTimezone() {
        return mTimezone;
    }
    
    public String getFormatedValue() {
        if(getThisValue() == null || getThisFormatString() == null) return '';
        
        Integer day;
        String display;
        String dayDisplay;
        if(getThisTimezone() == null) {
            day = Integer.valueOf(getThisValue().format('d', UserInfo.getTimeZone().getID()));
            display = getThisValue().format(getThisFormatString(), UserInfo.getTimeZone().getID());
        } else {
            day = Integer.valueOf(getThisValue().format('d', getThisTimezone()));
            display = getThisValue().format(getThisFormatString(), getThisTimezone());
        }
        dayDisplay = getDayOfMonthSuffix(day);
        
        return display.replace('[[stnd]]', dayDisplay)
                      .replace('[[STND]]', dayDisplay.ToUpperCase());
    }
    
    private static String getDayOfMonthSuffix(Integer day) {
        if (day == null) {
            return '';
        }
        if (day >= 11 && day <= 13) {
            return 'th';
        }
    
        Integer modResult = Math.mod(day, 10);        
        if (modResult == 1) { 
            return 'st'; 
        } else if (modResult == 2) { 
            return 'nd'; 
        } else if (modResult == 3) { 
            return 'rd'; 
        } else { 
            return 'th';
        }
    }
}