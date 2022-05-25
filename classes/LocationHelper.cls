/**
 *  Purpose         :	Location helper class
 *
 *  Revision Logs   :	V_1.0 - 07/13/2020 - CR-20200706-14269 - Victor Hanson - Created
 * 
**/
public class LocationHelper {
	
    //static final variables
    public static final String SEARCH_ADDRESS = 'search/address';
    public static final String TIMEZONE_BY_COORDINATES = 'timezone/byCoordinates';
    public static final String READY_FOR_BATCH = 'Ready for Batch';
    public static final String COMPLETED_SUCCESS = 'Completed - Success';
    public static final String COMPLETED_FAIL = 'Completed - Fail';
    
    public Id acctId { get; set; }
    public List<Web_Service_Log__c> wsLogs {
        get {
            if (wsLogs == null) wsLogs = new List<Web_Service_Log__c>();
            return wsLogs;
        }
        set;
    }
    
    /**
     *  Purpose         :	Sends a callout to azure
     *
     *  Revision Logs   :	V_1.0 - 07/13/2020 - CR-20200706-14269 - Victor Hanson - created
     *                     
    **/
    public HttpResponse sendCallout(String searchEndpoint, String query) {
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        Http h = new Http();
        String response;
        String endpointWithParams;
        try {
            
            //Based on the mail shop vendor, determine callout credentials for vendor
            List<API_Endpoints__mdt> apiEndpoints = [SELECT Id, Endpoint_URL__c, Authorization_Token__c
                                                     FROM API_Endpoints__mdt
                                                     WHERE DeveloperName = 'Azure_API']; 
            //replace param arguments {0} and {1} with Token and Query
            endpointWithParams = apiEndpoints[0].Endpoint_URL__c + searchEndpoint
                + String.format(Label.AzureEndpointParams,
                                new List<String> { apiEndpoints[0].Authorization_Token__c, query });
            req.setEndpoint(endpointWithParams);
            req.setMethod(Constants.HTTP_REQUEST_GET_TYPE);
            req.setTimeout(120000);
            req.setHeader('Content-Type', 'application/json');
            res = h.send(req);
            //set response as the response callout body
            response = res.getBody();
            system.debug('@@getStatusCode:' + '-' + res.getStatusCode() + '-' + res.getBody() + '-' + res.getStatus());
        }
        catch (exception e) {
            response = e.getMessage() + '\r\n\r\n' + e.getStackTraceString();
        }
        
        wsLogs.add(new Web_Service_Log__c(RecordTypeId = Schema.SObjectType.Web_Service_Log__c.getRecordTypeInfosByDeveloperName().get('Institution').getRecordTypeId(),
                                                                  Institution__c = acctId,
                                                                  Web_Service_Method__c = searchEndpoint,
                                                                  Request_Sent__c = system.now(),
                                                                  Request_Message_Log__c = endpointWithParams,
                                                                  Response_Message__c = String.valueOf(res.getStatusCode()),
                                                                  Response_Message_Log__c = response,
                                                                  Requested_By__c = UserInfo.getUserName()));
        
        return res;
    }

    /**
     *  Purpose         :	Returns geolocation from azure based on url encoded address
     *
     *  Revision Logs   :	V_1.0 - 07/13/2020 - CR-20200706-14269 - Victor Hanson - created
     *                     
    **/
    public SearchAddressWrapper getGeolocation(String urlEncodedAddress) {
        urlEncodedAddress += '&countrySet=' + getCountryCode(acctId);
        HttpResponse res = sendCallout(SEARCH_ADDRESS, urlEncodedAddress);
        return (SearchAddressWrapper)JSON.deserialize(res.getBody(), SearchAddressWrapper.class);
    }
    
    /**
     *  Purpose         :	Returns timezone from azure based on comma-delimited [Lat],[Lon] (ie: 47.63988,-122.12438)
     *
     *  Revision Logs   :	V_1.0 - 07/13/2020 - CR-20200706-14269 - Victor Hanson - created
     *                     
    **/
    public SearchTimezoneWrapper getTimezone(String coordinates) {
        HttpResponse res = sendCallout(TIMEZONE_BY_COORDINATES, coordinates);
        return (SearchTimezoneWrapper)JSON.deserialize(res.getBody(), SearchTimezoneWrapper.class);
    }
    
    public static String getCountryCode(Id acctId) {
        Account acct = [SELECT Id, Primary_Country__c FROM Account WHERE Id = :acctId];
        String countryCode = mapCountryNameToCode.get(acct.Primary_Country__c);
        if (countryCode == null) {
            throw new customException('No country code found for country (' + acct.Primary_Country__c + ')');
        }
        return countryCode;
    }
    
    public static Map<String, String> mapCountryNameToCode {
        get {
            if (mapCountryNameToCode == null) {
                mapCountryNameToCode = new Map<String, String>{
                    'Afghanistan'=>'AF',
                        'Albania'=>'AL',
                        'Algeria'=>'DZ',
                        'American Samoa'=>'AS',
                        'Andorra'=>'AD',
                        'Angola'=>'AO',
                        'Anguilla'=>'AI',
                        'Antarctica'=>'AQ',
                        'Antigua and Barbuda'=>'AG',
                        'Argentina'=>'AR',
                        'Armenia'=>'AM',
                        'Aruba'=>'AW',
                        'Australia'=>'AU',
                        'Austria'=>'AT',
                        'Azerbaijan'=>'AZ',
                        'Bahamas (the)'=>'BS',
                        'Bahrain'=>'BH',
                        'Bangladesh'=>'BD',
                        'Barbados'=>'BB',
                        'Belarus'=>'BY',
                        'Belgium'=>'BE',
                        'Belize'=>'BZ',
                        'Benin'=>'BJ',
                        'Bermuda'=>'BM',
                        'Bhutan'=>'BT',
                        'Bolivia (Plurinational State of)'=>'BO',
                        'Bonaire, Sint Eustatius and Saba'=>'BQ',
                        'Bosnia and Herzegovina'=>'BA',
                        'Botswana'=>'BW',
                        'Bouvet Island'=>'BV',
                        'Brazil'=>'BR',
                        'British Indian Ocean Territory (the)'=>'IO',
                        'Brunei Darussalam'=>'BN',
                        'Bulgaria'=>'BG',
                        'Burkina Faso'=>'BF',
                        'Burundi'=>'BI',
                        'Cabo Verde'=>'CV',
                        'Cambodia'=>'KH',
                        'Cameroon'=>'CM',
                        'Canada'=>'CA',
                        'Cayman Islands (the)'=>'KY',
                        'Central African Republic (the)'=>'CF',
                        'Chad'=>'TD',
                        'Chile'=>'CL',
                        'China'=>'CN',
                        'Christmas Island'=>'CX',
                        'Cocos (Keeling) Islands (the)'=>'CC',
                        'Colombia'=>'CO',
                        'Comoros (the)'=>'KM',
                        'Congo (the Democratic Republic of the)'=>'CD',
                        'Congo (the)'=>'CG',
                        'Cook Islands (the)'=>'CK',
                        'Costa Rica'=>'CR',
                        'Croatia'=>'HR',
                        'Cuba'=>'CU',
                        'Curaçao'=>'CW',
                        'Cyprus'=>'CY',
                        'Czechia'=>'CZ',
                        'Côte d\'Ivoire'=>'CI',
                        'Denmark'=>'DK',
                        'Djibouti'=>'DJ',
                        'Dominica'=>'DM',
                        'Dominican Republic (the)'=>'DO',
                        'Ecuador'=>'EC',
                        'Egypt'=>'EG',
                        'El Salvador'=>'SV',
                        'Equatorial Guinea'=>'GQ',
                        'Eritrea'=>'ER',
                        'Estonia'=>'EE',
                        'Eswatini'=>'SZ',
                        'Ethiopia'=>'ET',
                        'Falkland Islands (the) [Malvinas]'=>'FK',
                        'Faroe Islands (the)'=>'FO',
                        'Fiji'=>'FJ',
                        'Finland'=>'FI',
                        'France'=>'FR',
                        'French Guiana'=>'GF',
                        'French Polynesia'=>'PF',
                        'French Southern Territories (the)'=>'TF',
                        'Gabon'=>'GA',
                        'Gambia (the)'=>'GM',
                        'Georgia'=>'GE',
                        'Germany'=>'DE',
                        'Ghana'=>'GH',
                        'Gibraltar'=>'GI',
                        'Greece'=>'GR',
                        'Greenland'=>'GL',
                        'Grenada'=>'GD',
                        'Guadeloupe'=>'GP',
                        'Guam'=>'GU',
                        'Guatemala'=>'GT',
                        'Guernsey'=>'GG',
                        'Guinea'=>'GN',
                        'Guinea-Bissau'=>'GW',
                        'Guyana'=>'GY',
                        'Haiti'=>'HT',
                        'Heard Island and McDonald Islands'=>'HM',
                        'Holy See (the)'=>'VA',
                        'Honduras'=>'HN',
                        'Hong Kong'=>'HK',
                        'Hungary'=>'HU',
                        'Iceland'=>'IS',
                        'India'=>'IN',
                        'Indonesia'=>'ID',
                        'Iran (Islamic Republic of)'=>'IR',
                        'Iraq'=>'IQ',
                        'Ireland'=>'IE',
                        'Isle of Man'=>'IM',
                        'Israel'=>'IL',
                        'Italy'=>'IT',
                        'Jamaica'=>'JM',
                        'Japan'=>'JP',
                        'Jersey'=>'JE',
                        'Jordan'=>'JO',
                        'Kazakhstan'=>'KZ',
                        'Kenya'=>'KE',
                        'Kiribati'=>'KI',
                        'Korea (the Democratic People\'s Republic of)'=>'KP',
                        'Korea (the Republic of)'=>'KR',
                        'Kuwait'=>'KW',
                        'Kyrgyzstan'=>'KG',
                        'Lao People\'s Democratic Republic (the)'=>'LA',
                        'Latvia'=>'LV',
                        'Lebanon'=>'LB',
                        'Lesotho'=>'LS',
                        'Liberia'=>'LR',
                        'Libya'=>'LY',
                        'Liechtenstein'=>'LI',
                        'Lithuania'=>'LT',
                        'Luxembourg'=>'LU',
                        'Macao'=>'MO',
                        'Madagascar'=>'MG',
                        'Malawi'=>'MW',
                        'Malaysia'=>'MY',
                        'Maldives'=>'MV',
                        'Mali'=>'ML',
                        'Malta'=>'MT',
                        'Marshall Islands (the)'=>'MH',
                        'Martinique'=>'MQ',
                        'Mauritania'=>'MR',
                        'Mauritius'=>'MU',
                        'Mayotte'=>'YT',
                        'Mexico'=>'MX',
                        'Micronesia (Federated States of)'=>'FM',
                        'Moldova (the Republic of)'=>'MD',
                        'Monaco'=>'MC',
                        'Mongolia'=>'MN',
                        'Montenegro'=>'ME',
                        'Montserrat'=>'MS',
                        'Morocco'=>'MA',
                        'Mozambique'=>'MZ',
                        'Myanmar'=>'MM',
                        'Namibia'=>'NA',
                        'Nauru'=>'NR',
                        'Nepal'=>'NP',
                        'Netherlands (the)'=>'NL',
                        'New Caledonia'=>'NC',
                        'New Zealand'=>'NZ',
                        'Nicaragua'=>'NI',
                        'Niger (the)'=>'NE',
                        'Nigeria'=>'NG',
                        'Niue'=>'NU',
                        'Norfolk Island'=>'NF',
                        'Northern Mariana Islands (the)'=>'MP',
                        'Norway'=>'NO',
                        'Oman'=>'OM',
                        'Pakistan'=>'PK',
                        'Palau'=>'PW',
                        'Palestine, State of'=>'PS',
                        'Panama'=>'PA',
                        'Papua New Guinea'=>'PG',
                        'Paraguay'=>'PY',
                        'Peru'=>'PE',
                        'Philippines (the)'=>'PH',
                        'Pitcairn'=>'PN',
                        'Poland'=>'PL',
                        'Portugal'=>'PT',
                        'Puerto Rico'=>'PR',
                        'Qatar'=>'QA',
                        'Republic of North Macedonia'=>'MK',
                        'Romania'=>'RO',
                        'Russian Federation (the)'=>'RU',
                        'Rwanda'=>'RW',
                        'Réunion'=>'RE',
                        'Saint Barthélemy'=>'BL',
                        'Saint Helena, Ascension and Tristan da Cunha'=>'SH',
                        'Saint Kitts and Nevis'=>'KN',
                        'Saint Lucia'=>'LC',
                        'Saint Martin (French part)'=>'MF',
                        'Saint Pierre and Miquelon'=>'PM',
                        'Saint Vincent and the Grenadines'=>'VC',
                        'Samoa'=>'WS',
                        'San Marino'=>'SM',
                        'Sao Tome and Principe'=>'ST',
                        'Saudi Arabia'=>'SA',
                        'Senegal'=>'SN',
                        'Serbia'=>'RS',
                        'Seychelles'=>'SC',
                        'Sierra Leone'=>'SL',
                        'Singapore'=>'SG',
                        'Sint Maarten (Dutch part)'=>'SX',
                        'Slovakia'=>'SK',
                        'Slovenia'=>'SI',
                        'Solomon Islands'=>'SB',
                        'Somalia'=>'SO',
                        'South Africa'=>'ZA',
                        'South Georgia and the South Sandwich Islands'=>'GS',
                        'South Sudan'=>'SS',
                        'Spain'=>'ES',
                        'Sri Lanka'=>'LK',
                        'Sudan (the)'=>'SD',
                        'Suriname'=>'SR',
                        'Svalbard and Jan Mayen'=>'SJ',
                        'Sweden'=>'SE',
                        'Switzerland'=>'CH',
                        'Syrian Arab Republic'=>'SY',
                        'Taiwan (Province of China)'=>'TW',
                        'Tajikistan'=>'TJ',
                        'Tanzania, United Republic of'=>'TZ',
                        'Thailand'=>'TH',
                        'Timor-Leste'=>'TL',
                        'Togo'=>'TG',
                        'Tokelau'=>'TK',
                        'Tonga'=>'TO',
                        'Trinidad and Tobago'=>'TT',
                        'Tunisia'=>'TN',
                        'Turkey'=>'TR',
                        'Turkmenistan'=>'TM',
                        'Turks and Caicos Islands (the)'=>'TC',
                        'Tuvalu'=>'TV',
                        'Uganda'=>'UG',
                        'Ukraine'=>'UA',
                        'United Arab Emirates'=>'AE',
                        'United Kingdom'=>'GB',
                        'United States Minor Outlying Islands (the)'=>'UM',
                        'United States'=>'US',
                        'USA'=>'US',
                        'Uruguay'=>'UY',
                        'Uzbekistan'=>'UZ',
                        'Vanuatu'=>'VU',
                        'Venezuela (Bolivarian Republic of)'=>'VE',
                        'Viet Nam'=>'VN',
                        'Virgin Islands (British)'=>'VG',
                        'Virgin Islands (U.S.)'=>'VI',
                        'Wallis and Futuna'=>'WF',
                        'Western Sahara'=>'EH',
                        'Yemen'=>'YE',
                        'Zambia'=>'ZM',
                        'Zimbabwe'=>'ZW'
                };
            }
            return mapCountryNameToCode;
        }
        set;
    }
    
    /**
     *  Purpose         :	returns the list of countries that should include State/Province in the address search
     *
     *  Revision Logs   :	V_1.0 - 07/13/2020 - CR-20200706-14269 - Victor Hanson - created
     *                     
    **/
    public static List<String> listCountryWithStates {
        get {
            if (listCountryWithStates == null) {
                listCountryWithStates = new List<String>();
                listCountryWithStates.add('USA');
                listCountryWithStates.add('United States');
                listCountryWithStates.add('Canada');
            }
            return listCountryWithStates;
        }
        set;
    }
       
}